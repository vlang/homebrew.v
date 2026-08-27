module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/readall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "imports all Formulae for a given Tap", :integration_test do` at line 10.
pub fn ruby_readall_spec_l10_d1_imports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('imports', ...args)
}

// Ruby it `it "skips macOS-only casks when loading tap casks on Linux" do` at line 24.
pub fn ruby_readall_spec_l24_d2_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "returns true for valid Ruby files" do` at line 69.
pub fn ruby_readall_spec_l69_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "prints errors for files with invalid syntax" do` at line 78.
pub fn ruby_readall_spec_l78_d4_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints warnings for files with questionable syntax" do` at line 87.
pub fn ruby_readall_spec_l87_d5_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "aggregates failures across parallel worker processes" do` at line 96.
pub fn ruby_readall_spec_l96_d6_aggregates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregates', ...args)
}

// Ruby it `it "validates tap files in parallel worker processes" do` at line 113.
pub fn ruby_readall_spec_l113_d7_validates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validates', ...args)
}

// Ruby it `it "explains nil sha256 values when loading tap casks on Linux" do` at line 145.
pub fn ruby_readall_spec_l145_d8_explains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('explains', ...args)
}

// Ruby it `it "reports Linux architectures missing a checksum despite an `on_macos` macOS dependency" do` at line 174.
pub fn ruby_readall_spec_l174_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "allows Linux architectures excluded by `depends_on arch:`" do` at line 210.
pub fn ruby_readall_spec_l210_d10_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/readall"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::ReadallCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "imports all Formulae for a given Tap", :integration_test do
// 11:     formula_file = setup_test_formula "testball"
// 12:
// 13:     alias_file = CoreTap.instance.alias_dir/"foobar"
// 14:     alias_file.parent.mkpath
// 15:
// 16:     FileUtils.ln_s formula_file, alias_file
// 17:
// 18:     expect { brew "readall", "--aliases", "--syntax", CoreTap.instance.name }
// 19:       .to be_a_success
// 20:       .and not_to_output.to_stdout
// 21:       .and not_to_output.to_stderr
// 22:   end
// 23:
// 24:   it "skips macOS-only casks when loading tap casks on Linux" do
// 25:     tap_path = mktmpdir
// 26:     macos_only_cask_file = tap_path/"Casks/macos-only-example.rb"
// 27:     linux_cask_file = tap_path/"Casks/linux-example.rb"
// 28:     macos_only_cask_file.dirname.mkpath
// 29:     macos_only_cask_file.write <<~RUBY
// 30:       cask "macos-only-example" do
// 31:         version "1.0"
// 32:         sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
// 33:                intel: "1111111111111111111111111111111111111111111111111111111111111111"
// 34:         url "https://example.invalid/x.pkg"
// 35:         name "Example"
// 36:         desc "macOS-only cask"
// 37:         homepage "https://example.invalid/"
// 38:         depends_on macos: :ventura
// 39:         binary "x"
// 40:       end
// 41:     RUBY
// 42:     linux_cask_file.write <<~RUBY
// 43:       cask "linux-example" do
// 44:         version "1.0"
// 45:         sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
// 46:                intel: "1111111111111111111111111111111111111111111111111111111111111111"
// 47:         url "https://example.invalid/x.tar.gz"
// 48:         name "Example"
// 49:         desc "Linux-supported cask"
// 50:         homepage "https://example.invalid/"
// 51:         binary "x"
// 52:       end
// 53:     RUBY
// 54:
// 55:     success = T.let(false, T::Boolean)
// 56:     expect do
// 57:       success = Homebrew::SimulateSystem.with(os: :linux) do
// 58:         Readall.valid_tap?(
// 59:           instance_double(Tap, formula_files: [], cask_files: [macos_only_cask_file, linux_cask_file]),
// 60:           os_arch_combinations: [[:linux, :arm]],
// 61:         )
// 62:       end
// 63:     end.to output(a_string_matching(/\A(?=.*linux-example)(?!.*macos-only-example).*\z/m)).to_stderr
// 64:
// 65:     expect(success).to be false
// 66:   end
// 67:
// 68:   describe "Readall.valid_ruby_syntax?" do
// 69:     it "returns true for valid Ruby files" do
// 70:       file = mktmpdir/"valid.rb"
// 71:       file.write "puts 1\n"
// 72:
// 73:       success = T.let(false, T::Boolean)
// 74:       expect { success = Readall.valid_ruby_syntax?([file]) }.not_to output.to_stderr
// 75:       expect(success).to be true
// 76:     end
// 77:
// 78:     it "prints errors for files with invalid syntax" do
// 79:       file = mktmpdir/"invalid.rb"
// 80:       file.write "def foo(\n"
// 81:
// 82:       success = T.let(true, T::Boolean)
// 83:       expect { success = Readall.valid_ruby_syntax?([file]) }.to output(/syntax error/).to_stderr
// 84:       expect(success).to be false
// 85:     end
// 86:
// 87:     it "prints warnings for files with questionable syntax" do
// 88:       file = mktmpdir/"warning.rb"
// 89:       file.write "def foo\n  bar = 1\n  nil\nend\n"
// 90:
// 91:       success = T.let(true, T::Boolean)
// 92:       expect { success = Readall.valid_ruby_syntax?([file]) }.to output(/unused variable/).to_stderr
// 93:       expect(success).to be false
// 94:     end
// 95:
// 96:     it "aggregates failures across parallel worker processes" do
// 97:       dir = mktmpdir
// 98:       files = (1..9).map do |i|
// 99:         file = dir/"valid#{i}.rb"
// 100:         file.write "puts #{i}\n"
// 101:         file
// 102:       end
// 103:       bad_file = dir/"invalid.rb"
// 104:       bad_file.write "def foo(\n"
// 105:       files << bad_file
// 106:
// 107:       success = T.let(true, T::Boolean)
// 108:       expect { success = Readall.valid_ruby_syntax?(files) }.to output(/syntax error/).to_stderr
// 109:       expect(success).to be false
// 110:     end
// 111:   end
// 112:
// 113:   it "validates tap files in parallel worker processes" do
// 114:     tap_path = mktmpdir
// 115:     cask_files = (1..8).map do |i|
// 116:       file = tap_path/"Casks/linux-example#{i}.rb"
// 117:       file.dirname.mkpath
// 118:       file.write <<~RUBY
// 119:         cask "linux-example#{i}" do
// 120:           version "1.0"
// 121:           sha256 arm: "0000000000000000000000000000000000000000000000000000000000000000"
// 122:           url "https://example.invalid/x.tar.gz"
// 123:           name "Example"
// 124:           desc "Cask missing Linux stanzas"
// 125:           homepage "https://example.invalid/"
// 126:           binary "x"
// 127:         end
// 128:       RUBY
// 129:       file
// 130:     end
// 131:
// 132:     success = T.let(true, T::Boolean)
// 133:     expect do
// 134:       success = Homebrew::SimulateSystem.with(os: :linux) do
// 135:         Readall.valid_tap?(
// 136:           instance_double(Tap, formula_files: [], cask_files:),
// 137:           os_arch_combinations: [[:linux, :arm]],
// 138:         )
// 139:       end
// 140:     end.to output(a_string_matching(/(?=.*linux-example1\.rb)(?=.*linux-example8\.rb)/m)).to_stderr
// 141:
// 142:     expect(success).to be false
// 143:   end
// 144:
// 145:   it "explains nil sha256 values when loading tap casks on Linux" do
// 146:     tap_path = mktmpdir
// 147:     linux_cask_file = tap_path/"Casks/linux-example.rb"
// 148:     linux_cask_file.dirname.mkpath
// 149:     linux_cask_file.write <<~RUBY
// 150:       cask "linux-example" do
// 151:         version "1.0"
// 152:         sha256 arm: "0000000000000000000000000000000000000000000000000000000000000000"
// 153:         url "https://example.invalid/x.tar.gz"
// 154:         name "Example"
// 155:         desc "Linux-supported cask"
// 156:         homepage "https://example.invalid/"
// 157:         binary "x"
// 158:       end
// 159:     RUBY
// 160:
// 161:     success = T.let(false, T::Boolean)
// 162:     expect do
// 163:       success = Homebrew::SimulateSystem.with(os: :linux) do
// 164:         Readall.valid_tap?(
// 165:           instance_double(Tap, formula_files: [], cask_files: [linux_cask_file]),
// 166:           os_arch_combinations: [[:linux, :arm]],
// 167:         )
// 168:       end
// 169:     end.to output(/Missing Linux stanzas.*`depends_on :macos`/m).to_stderr
// 170:
// 171:     expect(success).to be false
// 172:   end
// 173:
// 174:   it "reports Linux architectures missing a checksum despite an `on_macos` macOS dependency" do
// 175:     tap_path = mktmpdir
// 176:     cross_os_cask_file = tap_path/"Casks/cross-os-example.rb"
// 177:     cross_os_cask_file.dirname.mkpath
// 178:     cross_os_cask_file.write <<~RUBY
// 179:       cask "cross-os-example" do
// 180:         version "1.0"
// 181:         sha256 arm:          "0000000000000000000000000000000000000000000000000000000000000000",
// 182:                intel:        "1111111111111111111111111111111111111111111111111111111111111111",
// 183:                x86_64_linux: "2222222222222222222222222222222222222222222222222222222222222222"
// 184:         url "https://example.invalid/x.tar.gz"
// 185:         name "Example"
// 186:         desc "Cross-OS cask"
// 187:         homepage "https://example.invalid/"
// 188:
// 189:         on_macos do
// 190:           depends_on macos: :ventura
// 191:         end
// 192:
// 193:         binary "x"
// 194:       end
// 195:     RUBY
// 196:
// 197:     success = T.let(false, T::Boolean)
// 198:     expect do
// 199:       success = Homebrew::SimulateSystem.with(os: :linux) do
// 200:         Readall.valid_tap?(
// 201:           instance_double(Tap, formula_files: [], cask_files: [cross_os_cask_file]),
// 202:           os_arch_combinations: [[:linux, :arm]],
// 203:         )
// 204:       end
// 205:     end.to output(/Missing Linux stanzas/).to_stderr
// 206:
// 207:     expect(success).to be false
// 208:   end
// 209:
// 210:   it "allows Linux architectures excluded by `depends_on arch:`" do
// 211:     tap_path = mktmpdir
// 212:     linux_intel_cask_file = tap_path/"Casks/linux-intel-example.rb"
// 213:     linux_intel_cask_file.dirname.mkpath
// 214:     linux_intel_cask_file.write <<~RUBY
// 215:       cask "linux-intel-example" do
// 216:         version "1.0"
// 217:         sha256 arm:          "0000000000000000000000000000000000000000000000000000000000000000",
// 218:                intel:        "1111111111111111111111111111111111111111111111111111111111111111",
// 219:                x86_64_linux: "2222222222222222222222222222222222222222222222222222222222222222"
// 220:         url "https://example.invalid/x.tar.gz"
// 221:         name "Example"
// 222:         desc "Intel-only-on-Linux cask"
// 223:         homepage "https://example.invalid/"
// 224:
// 225:         on_linux do
// 226:           depends_on arch: :x86_64
// 227:         end
// 228:
// 229:         binary "x"
// 230:       end
// 231:     RUBY
// 232:
// 233:     success = T.let(false, T::Boolean)
// 234:     expect do
// 235:       success = Homebrew::SimulateSystem.with(os: :linux) do
// 236:         Readall.valid_tap?(
// 237:           instance_double(Tap, formula_files: [], cask_files: [linux_intel_cask_file]),
// 238:           os_arch_combinations: [[:linux, :arm], [:linux, :intel]],
// 239:         )
// 240:       end
// 241:     end.not_to output.to_stderr
// 242:
// 243:     expect(success).to be true
// 244:   end
// 245: end
