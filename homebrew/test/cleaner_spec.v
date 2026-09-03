module test

import brew_runtime
import homebrew
import homebrew.api
import os
import time

// Translated from Homebrew/brew `test/cleaner_spec.rb`.
// Each example uses its own temporary formula prefix and runs the translated
// Cleaner against real files, directories, permissions, and symlinks.
fn cleaner_spec_root(line int) string {
	return os.join_path(os.temp_dir(), 'brew-v-cleaner-spec-${os.getpid()}-${line}-${time.now().unix_nano()}')
}

fn cleaner_spec_formula(root string, skip_paths []string) homebrew.Formula {
	return homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: 'cleaner_test'
			full_name: 'cleaner_test'
			tap: 'homebrew/core'
			stable_version: '1.0'
			source_url: 'foo-1.0'
			core_tap: true
		}
		prefix: root
		cellar: os.join_path(root, 'Cellar')
		skip_clean_paths: skip_paths.clone()
	}) or { panic(err) }
}

fn cleaner_spec_write(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

fn cleaner_spec_write_bytes(path string, contents []u8) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file_array(path, contents)!
}

fn cleaner_spec_mode(path string) int {
	return int(os.stat(path) or { return -1 }.get_mode().bitmask()) & 0o777
}

fn cleaner_spec_mach_o(file_type u8) []u8 {
	return [u8(0xfe), 0xed, 0xfa, 0xcf, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, file_type]
}

fn cleaner_spec_elf() []u8 {
	return [u8(0x7f), `E`, `L`, `F`, 0, 0, 0, 0]
}

fn cleaner_spec_case(line int) bool {
	root := cleaner_spec_root(line)
	os.mkdir_all(root) or { return false }
	defer {
		if os.exists(root) {
			os.rmdir_all(root) or {}
		}
	}
	skip_paths := match line {
		222, 231 { ['bin'] }
		242 { ['symlink'] }
		253 { ['c'] }
		268 { ['a'] }
		283 { [':la'] }
		296 { ['lib/subdir'] }
		308 { ['bin/a'] }
		else { []string{} }
	}
	formula := cleaner_spec_formula(root, skip_paths)
	prefix := formula.prefix()
	os.mkdir_all(prefix) or { return false }
	mut cleaner := homebrew.new_cleaner(formula)
	match line {
		24 {
			bin := os.join_path(prefix, 'bin')
			lib := os.join_path(prefix, 'lib')
			os.mkdir_all(bin) or { return false }
			os.mkdir_all(lib) or { return false }
			$if macos {
				cleaner_spec_write_bytes(os.join_path(bin, 'a.out'), cleaner_spec_mach_o(2)) or { return false }
				for name in ['fat.dylib', 'x86_64.dylib', 'i386.dylib'] {
					cleaner_spec_write_bytes(os.join_path(lib, name), cleaner_spec_mach_o(6)) or { return false }
				}
			} $else $if linux {
				cleaner_spec_write_bytes(os.join_path(bin, 'hello'), cleaner_spec_elf()) or { return false }
				cleaner_spec_write_bytes(os.join_path(lib, 'libhello.so.0'), cleaner_spec_elf()) or { return false }
			}
			cleaner.clean() or { return false }
			$if macos {
				return cleaner_spec_mode(os.join_path(bin, 'a.out')) == 0o555 && cleaner_spec_mode(os.join_path(lib, 'fat.dylib')) == 0o444 && cleaner_spec_mode(os.join_path(lib, 'x86_64.dylib')) == 0o444 && cleaner_spec_mode(os.join_path(lib, 'i386.dylib')) == 0o444
			} $else $if linux {
				return cleaner_spec_mode(os.join_path(bin, 'hello')) == 0o555 && cleaner_spec_mode(os.join_path(lib, 'libhello.so.0')) == 0o555
			} $else {
				return true
			}
		}
		49 {
			cleaner.clean() or { return false }
			return !os.is_dir(prefix)
		}
		54 {
			bin := os.join_path(prefix, 'bin')
			subdir := os.join_path(bin, 'subdir')
			os.mkdir_all(subdir) or { return false }
			cleaner.clean() or { return false }
			return !os.is_dir(bin) && !os.is_dir(subdir)
		}
		64, 78 {
			directory := os.join_path(prefix, 'b')
			symlink := os.join_path(prefix, if line == 64 { 'a' } else { 'c' })
			os.mkdir_all(directory) or { return false }
			os.symlink(os.base(directory), symlink) or { return false }
			cleaner.clean() or { return false }
			return !os.exists(directory) && !os.is_link(symlink) && !os.exists(symlink)
		}
		92 {
			symlink := os.join_path(prefix, 'symlink')
			os.symlink('target', symlink) or { return false }
			cleaner.clean() or { return false }
			return !os.is_link(symlink)
		}
		101, 112, 123, 134 {
			file := match line {
				101 { os.join_path(prefix, 'lib', 'foo.la') }
				112 {
					os.join_path(prefix, 'lib', 'perl5', 'darwin-thread-multi-2level', 'perllocal.pod')
				}
				123 {
					os.join_path(prefix, 'lib', 'perl5', 'darwin-thread-multi-2level', 'auto', 'test', '.packlist')
				}
				else { os.join_path(prefix, 'lib', 'charset.alias') }
			}
			cleaner_spec_write(file, '') or { return false }
			cleaner.clean() or { return false }
			return !os.exists(file)
		}
		145 {
			info := os.join_path(prefix, 'share', 'info')
			file := os.join_path(info, 'dir')
			arch_file := os.join_path(info, 'i686-elf', 'dir')
			name_file := os.join_path(info, formula.name(), 'dir')
			for path in [file, arch_file, name_file] {
				cleaner_spec_write(path, '') or { return false }
			}
			cleaner.clean() or { return false }
			return !os.exists(file) && !os.exists(arch_file) && os.exists(name_file)
		}
		165, 183 {
			directory := os.join_path(prefix, 'lib', 'python3.12', 'site-packages', 'test.dist-info')
			basename := if line == 165 { 'direct_url.json' } else { 'RECORD' }
			file := os.join_path(directory, basename)
			unrelated_file := os.join_path(directory, 'METADATA')
			unrelated_directory_file := os.join_path(prefix, 'lib', basename)
			for path in [file, unrelated_file, unrelated_directory_file] {
				cleaner_spec_write(path, '') or { return false }
			}
			cleaner.clean() or { return false }
			return !os.exists(file) && os.exists(unrelated_file) && os.exists(unrelated_directory_file)
		}
		201 {
			file := os.join_path(prefix, 'lib', 'python3.12', 'site-packages', 'test.dist-info', 'INSTALLER')
			cleaner_spec_write(file, 'pip\n') or { return false }
			cleaner.clean() or { return false }
			return os.read_file(file) or { return false } == 'brew\n'
		}
		222 {
			bin := os.join_path(prefix, 'bin')
			os.mkdir_all(bin) or { return false }
			cleaner.clean() or { return false }
			return os.is_dir(bin)
		}
		231 {
			bin := os.join_path(prefix, 'bin')
			subdir := os.join_path(bin, 'subdir')
			os.mkdir_all(subdir) or { return false }
			cleaner.clean() or { return false }
			return os.is_dir(bin) && os.is_dir(subdir)
		}
		242 {
			symlink := os.join_path(prefix, 'symlink')
			os.symlink('target', symlink) or { return false }
			cleaner.clean() or { return false }
			return os.is_link(symlink)
		}
		253, 268 {
			directory := os.join_path(prefix, 'b')
			symlink := os.join_path(prefix, if line == 253 { 'c' } else { 'a' })
			os.mkdir_all(directory) or { return false }
			os.symlink(os.base(directory), symlink) or { return false }
			cleaner.clean() or { return false }
			return !os.exists(directory) && os.is_link(symlink) && !os.exists(symlink)
		}
		283 {
			file := os.join_path(prefix, 'lib', 'foo.la')
			cleaner_spec_write(file, '') or { return false }
			cleaner.clean() or { return false }
			return os.exists(file)
		}
		296 {
			directory := os.join_path(prefix, 'lib', 'subdir')
			os.mkdir_all(directory) or { return false }
			cleaner.clean() or { return false }
			return os.is_dir(directory)
		}
		308 {
			directory_one := os.join_path(prefix, 'bin', 'a')
			directory_two := os.join_path(prefix, 'lib', 'bin', 'a')
			os.mkdir_all(directory_one) or { return false }
			os.mkdir_all(directory_two) or { return false }
			cleaner.clean() or { return false }
			return os.exists(directory_one) && !os.exists(directory_two)
		}
		else {
			return false
		}
	}
}

fn cleaner_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Ruby subject `subject(:cleaner) { described_class.new(f) }` at line 11.
pub fn ruby_cleaner_spec_l11_d1_cleaner(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := cleaner_spec_formula(cleaner_spec_root(11), []string{})
	return homebrew.ruby_cleaner_l22_d1_initialize(homebrew.formula_boundary_value(formula))
}

// Ruby let `let(:f) do` at line 13.
pub fn ruby_cleaner_spec_l13_d2_f(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return homebrew.formula_boundary_value(cleaner_spec_formula(cleaner_spec_root(13), []string{}))
}

// Ruby it `it "cleans files" do` at line 24.
pub fn ruby_cleaner_spec_l24_d3_cleans(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(24))
}

// Ruby it `it "prunes the prefix if it is empty" do` at line 49.
pub fn ruby_cleaner_spec_l49_d4_prunes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(49))
}

// Ruby it `it "prunes empty directories" do` at line 54.
pub fn ruby_cleaner_spec_l54_d5_prunes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(54))
}

// Ruby it `it "removes a symlink when its target was pruned before" do` at line 64.
pub fn ruby_cleaner_spec_l64_d6_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(64))
}

// Ruby it `it "removes symlinks pointing to an empty directory" do` at line 78.
pub fn ruby_cleaner_spec_l78_d7_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(78))
}

// Ruby it `it "removes broken symlinks" do` at line 92.
pub fn ruby_cleaner_spec_l92_d8_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(92))
}

// Ruby it `it "removes '.la' files" do` at line 101.
pub fn ruby_cleaner_spec_l101_d9_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(101))
}

// Ruby it `it "removes 'perllocal' files" do` at line 112.
pub fn ruby_cleaner_spec_l112_d10_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(112))
}

// Ruby it `it "removes '.packlist' files" do` at line 123.
pub fn ruby_cleaner_spec_l123_d11_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(123))
}

// Ruby it `it "removes 'charset.alias' files" do` at line 134.
pub fn ruby_cleaner_spec_l134_d12_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(134))
}

// Ruby it `it "removes 'info/**/dir' files except for 'info/<name>/dir'" do` at line 145.
pub fn ruby_cleaner_spec_l145_d13_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(145))
}

// Ruby it `it "removes '*.dist-info/direct_url.json' files" do` at line 165.
pub fn ruby_cleaner_spec_l165_d14_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(165))
}

// Ruby it `it "removes '*.dist-info/RECORD' files" do` at line 183.
pub fn ruby_cleaner_spec_l183_d15_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(183))
}

// Ruby it `it "modifies '*.dist-info/INSTALLER' files" do` at line 201.
pub fn ruby_cleaner_spec_l201_d16_modifies(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(201))
}

// Ruby method `stub_formula_skip_clean(skip_paths)` at line 213.
pub fn ruby_cleaner_spec_l213_d17_stub_formula_skip_clean(args ...brew_runtime.Value) brew_runtime.Value {
	mut paths := []string{}
	if args.len > 0 {
		if values := args[0].as_string_array() {
			paths = values.clone()
		} else {
			paths = [args[0].as_string()]
		}
	}
	return homebrew.formula_boundary_value(cleaner_spec_formula(cleaner_spec_root(213), paths))
}

// Ruby it `it "adds paths that should be skipped" do` at line 222.
pub fn ruby_cleaner_spec_l222_d18_adds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(222))
}

// Ruby it `it "also skips empty sub-directories under the added paths" do` at line 231.
pub fn ruby_cleaner_spec_l231_d19_also(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(231))
}

// Ruby it `it "allows skipping broken symlinks" do` at line 242.
pub fn ruby_cleaner_spec_l242_d20_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(242))
}

// Ruby it `it "allows skipping symlinks pointing to an empty directory" do` at line 253.
pub fn ruby_cleaner_spec_l253_d21_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(253))
}

// Ruby it `it "allows skipping symlinks whose target was pruned before" do` at line 268.
pub fn ruby_cleaner_spec_l268_d22_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(268))
}

// Ruby it `it "allows skipping '.la' files" do` at line 283.
pub fn ruby_cleaner_spec_l283_d23_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(283))
}

// Ruby it `it "allows skipping sub-directories" do` at line 296.
pub fn ruby_cleaner_spec_l296_d24_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(296))
}

// Ruby it `it "allows skipping paths relative to prefix" do` at line 308.
pub fn ruby_cleaner_spec_l308_d25_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cleaner_spec_bool(cleaner_spec_case(308))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cleaner"
// 5: require "formula"
// 6:
// 7: RSpec.describe Cleaner do
// 8:   include FileUtils
// 9:
// 10:   describe "#clean" do
// 11:     subject(:cleaner) { described_class.new(f) }
// 12:
// 13:     let(:f) do
// 14:       formula("cleaner_test") do
// 15:         T.bind(self, T.class_of(Formula))
// 16:         url "foo-1.0"
// 17:       end
// 18:     end
// 19:
// 20:     before do
// 21:       f.prefix.mkpath
// 22:     end
// 23:
// 24:     it "cleans files" do
// 25:       f.bin.mkpath
// 26:       f.lib.mkpath
// 27:
// 28:       if OS.mac?
// 29:         cp "#{TEST_FIXTURE_DIR}/mach/a.out", f.bin
// 30:         cp Dir["#{TEST_FIXTURE_DIR}/mach/*.dylib"], f.lib
// 31:       elsif OS.linux?
// 32:         cp "#{TEST_FIXTURE_DIR}/elf/hello", f.bin
// 33:         cp Dir["#{TEST_FIXTURE_DIR}/elf/libhello.so.0"], f.lib
// 34:       end
// 35:
// 36:       cleaner.clean
// 37:
// 38:       if OS.mac?
// 39:         expect((f.bin/"a.out").stat.mode).to eq(0100555)
// 40:         expect((f.lib/"fat.dylib").stat.mode).to eq(0100444)
// 41:         expect((f.lib/"x86_64.dylib").stat.mode).to eq(0100444)
// 42:         expect((f.lib/"i386.dylib").stat.mode).to eq(0100444)
// 43:       elsif OS.linux?
// 44:         expect((f.bin/"hello").stat.mode).to eq(0100555)
// 45:         expect((f.lib/"libhello.so.0").stat.mode).to eq(0100555)
// 46:       end
// 47:     end
// 48:
// 49:     it "prunes the prefix if it is empty" do
// 50:       cleaner.clean
// 51:       expect(f.prefix).not_to be_a_directory
// 52:     end
// 53:
// 54:     it "prunes empty directories" do
// 55:       subdir = f.bin/"subdir"
// 56:       subdir.mkpath
// 57:
// 58:       cleaner.clean
// 59:
// 60:       expect(f.bin).not_to be_a_directory
// 61:       expect(subdir).not_to be_a_directory
// 62:     end
// 63:
// 64:     it "removes a symlink when its target was pruned before" do
// 65:       dir = f.prefix/"b"
// 66:       symlink = f.prefix/"a"
// 67:
// 68:       dir.mkpath
// 69:       ln_s dir.basename, symlink
// 70:
// 71:       cleaner.clean
// 72:
// 73:       expect(dir).not_to exist
// 74:       expect(symlink).not_to be_a_symlink
// 75:       expect(symlink).not_to exist
// 76:     end
// 77:
// 78:     it "removes symlinks pointing to an empty directory" do
// 79:       dir = f.prefix/"b"
// 80:       symlink = f.prefix/"c"
// 81:
// 82:       dir.mkpath
// 83:       ln_s dir.basename, symlink
// 84:
// 85:       cleaner.clean
// 86:
// 87:       expect(dir).not_to exist
// 88:       expect(symlink).not_to be_a_symlink
// 89:       expect(symlink).not_to exist
// 90:     end
// 91:
// 92:     it "removes broken symlinks" do
// 93:       symlink = f.prefix/"symlink"
// 94:       ln_s "target", symlink
// 95:
// 96:       cleaner.clean
// 97:
// 98:       expect(symlink).not_to be_a_symlink
// 99:     end
// 100:
// 101:     it "removes '.la' files" do
// 102:       file = f.lib/"foo.la"
// 103:
// 104:       file.dirname.mkpath
// 105:       touch file
// 106:
// 107:       cleaner.clean
// 108:
// 109:       expect(file).not_to exist
// 110:     end
// 111:
// 112:     it "removes 'perllocal' files" do
// 113:       file = f.lib/"perl5/darwin-thread-multi-2level/perllocal.pod"
// 114:
// 115:       file.dirname.mkpath
// 116:       touch file
// 117:
// 118:       cleaner.clean
// 119:
// 120:       expect(file).not_to exist
// 121:     end
// 122:
// 123:     it "removes '.packlist' files" do
// 124:       file = f.lib/"perl5/darwin-thread-multi-2level/auto/test/.packlist"
// 125:
// 126:       file.dirname.mkpath
// 127:       touch file
// 128:
// 129:       cleaner.clean
// 130:
// 131:       expect(file).not_to exist
// 132:     end
// 133:
// 134:     it "removes 'charset.alias' files" do
// 135:       file = f.lib/"charset.alias"
// 136:
// 137:       file.dirname.mkpath
// 138:       touch file
// 139:
// 140:       cleaner.clean
// 141:
// 142:       expect(file).not_to exist
// 143:     end
// 144:
// 145:     it "removes 'info/**/dir' files except for 'info/<name>/dir'" do
// 146:       file = f.info/"dir"
// 147:       arch_file = f.info/"i686-elf/dir"
// 148:       name_file = f.info/f.name/"dir"
// 149:
// 150:       file.dirname.mkpath
// 151:       arch_file.dirname.mkpath
// 152:       name_file.dirname.mkpath
// 153:
// 154:       touch file
// 155:       touch arch_file
// 156:       touch name_file
// 157:
// 158:       cleaner.clean
// 159:
// 160:       expect(file).not_to exist
// 161:       expect(arch_file).not_to exist
// 162:       expect(name_file).to exist
// 163:     end
// 164:
// 165:     it "removes '*.dist-info/direct_url.json' files" do
// 166:       dir = f.lib/"python3.12/site-packages/test.dist-info"
// 167:       file = dir/"direct_url.json"
// 168:       unrelated_file = dir/"METADATA"
// 169:       unrelated_dir_file = f.lib/"direct_url.json"
// 170:
// 171:       dir.mkpath
// 172:       touch file
// 173:       touch unrelated_file
// 174:       touch unrelated_dir_file
// 175:
// 176:       cleaner.clean
// 177:
// 178:       expect(file).not_to exist
// 179:       expect(unrelated_file).to exist
// 180:       expect(unrelated_dir_file).to exist
// 181:     end
// 182:
// 183:     it "removes '*.dist-info/RECORD' files" do
// 184:       dir = f.lib/"python3.12/site-packages/test.dist-info"
// 185:       file = dir/"RECORD"
// 186:       unrelated_file = dir/"METADATA"
// 187:       unrelated_dir_file = f.lib/"RECORD"
// 188:
// 189:       dir.mkpath
// 190:       touch file
// 191:       touch unrelated_file
// 192:       touch unrelated_dir_file
// 193:
// 194:       cleaner.clean
// 195:
// 196:       expect(file).not_to exist
// 197:       expect(unrelated_file).to exist
// 198:       expect(unrelated_dir_file).to exist
// 199:     end
// 200:
// 201:     it "modifies '*.dist-info/INSTALLER' files" do
// 202:       file = f.lib/"python3.12/site-packages/test.dist-info/INSTALLER"
// 203:       file.dirname.mkpath
// 204:       file.write "pip\n"
// 205:
// 206:       cleaner.clean
// 207:
// 208:       expect(file.read).to eq "brew\n"
// 209:     end
// 210:   end
// 211:
// 212:   describe "::skip_clean" do
// 213:     def stub_formula_skip_clean(skip_paths)
// 214:       formula("cleaner_test") do
// 215:         T.bind(self, T.class_of(Formula))
// 216:         url "foo-1.0"
// 217:
// 218:         skip_clean skip_paths
// 219:       end
// 220:     end
// 221:
// 222:     it "adds paths that should be skipped" do
// 223:       f = stub_formula_skip_clean("bin")
// 224:       f.bin.mkpath
// 225:
// 226:       described_class.new(f).clean
// 227:
// 228:       expect(f.bin).to be_a_directory
// 229:     end
// 230:
// 231:     it "also skips empty sub-directories under the added paths" do
// 232:       f = stub_formula_skip_clean("bin")
// 233:       subdir = f.bin/"subdir"
// 234:       subdir.mkpath
// 235:
// 236:       described_class.new(f).clean
// 237:
// 238:       expect(f.bin).to be_a_directory
// 239:       expect(subdir).to be_a_directory
// 240:     end
// 241:
// 242:     it "allows skipping broken symlinks" do
// 243:       f = stub_formula_skip_clean("symlink")
// 244:       f.prefix.mkpath
// 245:       symlink = f.prefix/"symlink"
// 246:       ln_s "target", symlink
// 247:
// 248:       described_class.new(f).clean
// 249:
// 250:       expect(symlink).to be_a_symlink
// 251:     end
// 252:
// 253:     it "allows skipping symlinks pointing to an empty directory" do
// 254:       f = stub_formula_skip_clean("c")
// 255:       dir = f.prefix/"b"
// 256:       symlink = f.prefix/"c"
// 257:
// 258:       dir.mkpath
// 259:       ln_s dir.basename, symlink
// 260:
// 261:       described_class.new(f).clean
// 262:
// 263:       expect(dir).not_to exist
// 264:       expect(symlink).to be_a_symlink
// 265:       expect(symlink).not_to exist
// 266:     end
// 267:
// 268:     it "allows skipping symlinks whose target was pruned before" do
// 269:       f = stub_formula_skip_clean("a")
// 270:       dir = f.prefix/"b"
// 271:       symlink = f.prefix/"a"
// 272:
// 273:       dir.mkpath
// 274:       ln_s dir.basename, symlink
// 275:
// 276:       described_class.new(f).clean
// 277:
// 278:       expect(dir).not_to exist
// 279:       expect(symlink).to be_a_symlink
// 280:       expect(symlink).not_to exist
// 281:     end
// 282:
// 283:     it "allows skipping '.la' files" do
// 284:       f = stub_formula_skip_clean(:la)
// 285:
// 286:       file = f.lib/"foo.la"
// 287:
// 288:       f.lib.mkpath
// 289:       touch file
// 290:
// 291:       described_class.new(f).clean
// 292:
// 293:       expect(file).to exist
// 294:     end
// 295:
// 296:     it "allows skipping sub-directories" do
// 297:       f = stub_formula_skip_clean("lib/subdir")
// 298:
// 299:       dir = f.lib/"subdir"
// 300:
// 301:       dir.mkpath
// 302:
// 303:       described_class.new(f).clean
// 304:
// 305:       expect(dir).to be_a_directory
// 306:     end
// 307:
// 308:     it "allows skipping paths relative to prefix" do
// 309:       f = stub_formula_skip_clean("bin/a")
// 310:
// 311:       dir1 = f.bin/"a"
// 312:       dir2 = f.lib/"bin/a"
// 313:
// 314:       dir1.mkpath
// 315:       dir2.mkpath
// 316:
// 317:       described_class.new(f).clean
// 318:
// 319:       expect(dir1).to exist
// 320:       expect(dir2).not_to exist
// 321:     end
// 322:   end
// 323: end
