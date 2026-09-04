module utils

import ruby
import homebrew.utils as path_utils
import os

// Translated from Homebrew/brew `test/utils/path_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "recognizes a path as its own child" do` at line 8.
pub fn ruby_path_spec_l8_d1_recognizes(args ...ruby.Value) ruby.Value {
	return path_spec_bool(path_utils.path_child_of('/foo/bar', '/foo/bar'))
}

// Ruby it `it "recognizes a path that is a child of the parent" do` at line 12.
pub fn ruby_path_spec_l12_d2_recognizes(args ...ruby.Value) ruby.Value {
	return path_spec_bool(path_utils.path_child_of('/foo', '/foo/bar'))
}

// Ruby it `it "recognizes a path that is a grandchild of the parent" do` at line 16.
pub fn ruby_path_spec_l16_d3_recognizes(args ...ruby.Value) ruby.Value {
	return path_spec_bool(path_utils.path_child_of('/foo', '/foo/bar/baz'))
}

// Ruby it `it "does not recognize a path that is not a child" do` at line 20.
pub fn ruby_path_spec_l20_d4_does(args ...ruby.Value) ruby.Value {
	return path_spec_bool(!path_utils.path_child_of('/foo', '/bar/baz'))
}

// Ruby it `it "handles . and .. in paths correctly" do` at line 24.
pub fn ruby_path_spec_l24_d5_handles(args ...ruby.Value) ruby.Value {
	return path_spec_bool(path_utils.path_child_of('/foo', '/foo/./bar') && path_utils.path_child_of('/foo/bar', '/foo/../foo/bar/baz'))
}

// Ruby it `it "handles relative paths correctly" do` at line 29.
pub fn ruby_path_spec_l29_d6_handles(args ...ruby.Value) ruby.Value {
	return path_spec_bool(!path_utils.path_child_of('foo', './bar/baz') && path_utils.path_child_of('../foo', './bar/baz/../../../foo/bar/baz'))
}

// Ruby it `it "allows a path that is a child of the parent" do` at line 36.
pub fn ruby_path_spec_l36_d7_allows(args ...ruby.Value) ruby.Value {
	path_utils.path_ensure_child_of('/foo', '/foo/bar', 'outside') or { return path_spec_bool(false) }
	return path_spec_bool(true)
}

// Ruby it `it "raises the provided message for a path that is not a child" do` at line 40.
pub fn ruby_path_spec_l40_d8_raises(args ...ruby.Value) ruby.Value {
	path_utils.path_ensure_child_of('/foo', '/bar/baz', 'outside') or {
		return path_spec_bool(err.msg() == 'outside')
	}
	return path_spec_bool(false)
}

// Ruby it `it "returns a formula opt prefix without loading a Formula object" do` at line 46.
pub fn ruby_path_spec_l46_d9_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('opt-prefix')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_prefix(prefix, 'foo') == os.join_path(prefix, 'opt', 'foo'))
}

// Ruby it `it "returns a formula opt prefix for a fully qualified formula name" do` at line 50.
pub fn ruby_path_spec_l50_d10_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('qualified-opt-prefix')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_prefix(prefix, 'homebrew/core/foo') == os.join_path(prefix, 'opt', 'foo'))
}

// Ruby it `it "returns a formula opt bin path without loading a Formula object" do` at line 56.
pub fn ruby_path_spec_l56_d11_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('opt-bin')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_bin(prefix, 'foo') == os.join_path(prefix, 'opt', 'foo', 'bin'))
}

// Ruby it `it "returns a formula opt lib path without loading a Formula object" do` at line 62.
pub fn ruby_path_spec_l62_d12_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('opt-lib')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_lib(prefix, 'foo') == os.join_path(prefix, 'opt', 'foo', 'lib'))
}

// Ruby it `it "returns a formula opt libexec path without loading a Formula object" do` at line 68.
pub fn ruby_path_spec_l68_d13_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('opt-libexec')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_libexec(prefix, 'foo') == os.join_path(prefix, 'opt', 'foo', 'libexec'))
}

// Ruby it `it "returns a formula opt include path without loading a Formula object" do` at line 74.
pub fn ruby_path_spec_l74_d14_returns(args ...ruby.Value) ruby.Value {
	prefix := path_spec_root('opt-include')
	defer { os.rmdir_all(prefix) or {} }
	return path_spec_bool(path_utils.path_formula_opt_include(prefix, 'foo') == os.join_path(prefix, 'opt', 'foo', 'include'))
}

// Ruby it `it "returns installed prefixes for formula names" do` at line 80.
pub fn ruby_path_spec_l80_d15_returns(args ...ruby.Value) ruby.Value {
	cellar := path_spec_root('installed-prefixes')
	defer { os.rmdir_all(cellar) or {} }
	os.mkdir_all(os.join_path(cellar, 'old-foo', '1.0')) or { return path_spec_bool(false) }
	os.mkdir_all(os.join_path(cellar, 'foo', '2.0')) or { return path_spec_bool(false) }
	return path_spec_bool(path_utils.path_formula_installed_prefixes(cellar, ['foo', 'old-foo']) == [
		os.join_path(cellar, 'old-foo', '1.0'),
		os.join_path(cellar, 'foo', '2.0'),
	])
}

// Ruby it `it "does not list kegs twice when a name is a symlink to another rack" do` at line 90.
pub fn ruby_path_spec_l90_d16_does(args ...ruby.Value) ruby.Value {
	cellar := path_spec_root('installed-alias')
	defer { os.rmdir_all(cellar) or {} }
	os.mkdir_all(os.join_path(cellar, 'foo', '1.0')) or { return path_spec_bool(false) }
	os.symlink(os.join_path(cellar, 'foo'), os.join_path(cellar, 'foo-alias')) or {
		return path_spec_bool(false)
	}
	return path_spec_bool(path_utils.path_formula_installed_prefixes(cellar, ['foo', 'foo-alias']) == [
		os.join_path(cellar, 'foo', '1.0'),
	])
}

// Ruby it `it "checks whether any formula keg has an install receipt without loading a Formula object" do` at line 102.
pub fn ruby_path_spec_l102_d17_checks(args ...ruby.Value) ruby.Value {
	cellar := path_spec_root('installed-receipt')
	defer { os.rmdir_all(cellar) or {} }
	before := !path_utils.path_formula_any_version_installed(cellar, ['foo'])
	os.mkdir_all(os.join_path(cellar, 'foo', '1.0')) or { return path_spec_bool(false) }
	without_receipt := !path_utils.path_formula_any_version_installed(cellar, ['foo'])
	os.write_file(os.join_path(cellar, 'foo', '1.0', 'INSTALL_RECEIPT.json'), '{}') or {
		return path_spec_bool(false)
	}
	return path_spec_bool(before && without_receipt && path_utils.path_formula_any_version_installed(cellar, [
		'foo',
	]))
}

// Ruby it `it "checks fully qualified formula names" do` at line 114.
pub fn ruby_path_spec_l114_d18_checks(args ...ruby.Value) ruby.Value {
	cellar := path_spec_root('qualified-installed')
	defer { os.rmdir_all(cellar) or {} }
	receipt := os.join_path(cellar, 'foo', '1.0', 'INSTALL_RECEIPT.json')
	os.mkdir_all(os.dir(receipt)) or { return path_spec_bool(false) }
	os.write_file(receipt, '{}') or { return path_spec_bool(false) }
	return path_spec_bool(path_utils.path_formula_any_version_installed(cellar, [
		'homebrew/core/foo',
	]))
}

// Ruby it `it "checks multiple possible formula names" do` at line 125.
pub fn ruby_path_spec_l125_d19_checks(args ...ruby.Value) ruby.Value {
	cellar := path_spec_root('multiple-installed')
	defer { os.rmdir_all(cellar) or {} }
	receipt := os.join_path(cellar, 'old-foo', '1.0', 'INSTALL_RECEIPT.json')
	os.mkdir_all(os.dir(receipt)) or { return path_spec_bool(false) }
	os.write_file(receipt, '{}') or { return path_spec_bool(false) }
	return path_spec_bool(path_utils.path_formula_any_version_installed(cellar, ['foo', 'old-foo']))
}

// Ruby it `it "prepends a formula opt bin path to the current PATH by default" do` at line 138.
pub fn ruby_path_spec_l138_d20_prepends(args ...ruby.Value) ruby.Value {
	prefix := '/homebrew'
	current_path := '/bin:/sbin'
	return path_spec_bool(path_utils.path_formula_opt_bin_path(prefix, 'foo', [], current_path) == [
		os.join_path(prefix, 'opt', 'foo', 'bin'),
		current_path,
	].join(os.path_delimiter))
}

// Ruby it `it "prepends a formula opt bin path to PATH entries" do` at line 143.
pub fn ruby_path_spec_l143_d21_prepends(args ...ruby.Value) ruby.Value {
	prefix := '/homebrew'
	current_path := '/bin:/sbin'
	return path_spec_bool(path_utils.path_formula_opt_bin_path(prefix, 'foo', [
		'/usr/bin',
	], current_path) == [
		os.join_path(prefix, 'opt', 'foo', 'bin'),
		'/usr/bin',
		current_path,
	].join(os.path_delimiter))
}

// Ruby it `it "returns a PATH environment with a formula opt bin path prepended to the current PATH by default" do` at line 151.
pub fn ruby_path_spec_l151_d22_returns(args ...ruby.Value) ruby.Value {
	prefix := '/homebrew'
	current_path := '/bin:/sbin'
	environment := {
		'PATH': path_utils.path_formula_opt_bin_path(prefix, 'foo', [], current_path)
	}
	return path_spec_bool(environment == {
		'PATH': [os.join_path(prefix, 'opt', 'foo', 'bin'), current_path].join(os.path_delimiter)
	})
}

// Ruby it `it "returns a PATH environment with extra PATH entries" do` at line 156.
pub fn ruby_path_spec_l156_d23_returns(args ...ruby.Value) ruby.Value {
	prefix := '/homebrew'
	current_path := '/bin:/sbin'
	environment := {
		'PATH': path_utils.path_formula_opt_bin_path(prefix, 'foo', ['/usr/bin'], current_path)
	}
	return path_spec_bool(environment == {
		'PATH': [os.join_path(prefix, 'opt', 'foo', 'bin'), '/usr/bin', current_path].join(os.path_delimiter)
	})
}

// Ruby it `it "accepts formula paths under a symlinked cellar" do` at line 163.
pub fn ruby_path_spec_l163_d24_accepts(args ...ruby.Value) ruby.Value {
	root := path_spec_root('symlink-cellar')
	defer { os.rmdir_all(root) or {} }
	real_cellar := os.join_path(root, 'real-cellar')
	symlink_cellar := os.join_path(root, 'cellar')
	os.mkdir_all(real_cellar) or { return path_spec_bool(false) }
	os.symlink(real_cellar, symlink_cellar) or { return path_spec_bool(false) }
	formula_path := os.join_path(real_cellar, 'poshtui', '0.16', '.brew', 'poshtui.rb')
	os.mkdir_all(os.dir(formula_path)) or { return path_spec_bool(false) }
	os.write_file(formula_path, 'class Poshtui < Formula; end\n') or { return path_spec_bool(false) }
	accepted := path_utils.path_loadable_package_path(formula_path, 'formula', path_utils.PathLoadOptions{
		forbid_packages_from_paths: true
		library: os.join_path(root, 'Library')
		cellar: symlink_cellar
	}) or { return path_spec_bool(false) }
	return path_spec_bool(accepted)
}

// Ruby it `it "accepts formula paths under a symlinked tap" do` at line 182.
pub fn ruby_path_spec_l182_d25_accepts(args ...ruby.Value) ruby.Value {
	root := path_spec_root('symlink-tap')
	defer { os.rmdir_all(root) or {} }
	library := os.join_path(root, 'Library')
	taps := os.join_path(library, 'Taps', 'homebrew')
	os.mkdir_all(taps) or { return path_spec_bool(false) }
	external_tap := os.join_path(root, 'external', 'homebrew-foo')
	os.mkdir_all(os.join_path(external_tap, 'Formula')) or { return path_spec_bool(false) }
	os.symlink(external_tap, os.join_path(taps, 'homebrew-foo')) or { return path_spec_bool(false) }
	formula_path := os.join_path(taps, 'homebrew-foo', 'Formula', 'foo.rb')
	os.write_file(formula_path, 'class Foo < Formula; end\n') or { return path_spec_bool(false) }
	accepted := path_utils.path_loadable_package_path(formula_path, 'formula', path_utils.PathLoadOptions{
		forbid_packages_from_paths: true
		library: library
		cellar: os.join_path(root, 'Cellar')
	}) or { return path_spec_bool(false) }
	return path_spec_bool(accepted)
}

// Ruby it `it "rejects formula paths that escape a trusted root via `..` segments" do` at line 199.
pub fn ruby_path_spec_l199_d26_rejects(args ...ruby.Value) ruby.Value {
	root := path_spec_root('traversal')
	defer { os.rmdir_all(root) or {} }
	library := os.join_path(root, 'Library')
	os.mkdir_all(os.join_path(library, 'Taps')) or { return path_spec_bool(false) }
	escaped := os.join_path(root, 'evil.rb')
	os.write_file(escaped, 'class Evil < Formula; end\n') or { return path_spec_bool(false) }
	traversal_path := os.join_path(library, 'Taps', '..', '..', 'evil.rb')
	path_utils.path_loadable_package_path(traversal_path, 'formula', path_utils.PathLoadOptions{
		forbid_packages_from_paths: true
		library: library
		cellar: os.join_path(root, 'Cellar')
	}) or {
		return path_spec_bool(err.msg().contains('to be in a tap'))
	}
	return path_spec_bool(false)
}

// Ruby it `it "rejects local JSON cask paths" do` at line 216.
pub fn ruby_path_spec_l216_d27_rejects(args ...ruby.Value) ruby.Value {
	root := path_spec_root('local-json-cask')
	defer { os.rmdir_all(root) or {} }
	library := os.join_path(root, 'Library')
	os.mkdir_all(os.join_path(library, 'Taps')) or { return path_spec_bool(false) }
	cask_path := os.join_path(root, 'evil.json')
	os.write_file(cask_path, '{}\n') or { return path_spec_bool(false) }
	path_utils.path_loadable_package_path(cask_path, 'cask', path_utils.PathLoadOptions{
		forbid_packages_from_paths: true
		library: library
		caskroom: os.join_path(root, 'Caskroom')
	}) or {
		return path_spec_bool(err.msg().contains('to be in a tap'))
	}
	return path_spec_bool(false)
}

fn path_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn path_spec_root(name string) string {
	root := os.join_path(os.temp_dir(), 'brew-v-utils-path-${name}')
	os.rmdir_all(root) or {}
	os.mkdir_all(root) or { panic(err) }
	return os.real_path(root)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: RSpec.describe Utils::Path do
// 7:   describe "::child_of?" do
// 8:     it "recognizes a path as its own child" do
// 9:       expect(described_class.child_of?("/foo/bar", "/foo/bar")).to be(true)
// 10:     end
// 11:
// 12:     it "recognizes a path that is a child of the parent" do
// 13:       expect(described_class.child_of?("/foo", "/foo/bar")).to be(true)
// 14:     end
// 15:
// 16:     it "recognizes a path that is a grandchild of the parent" do
// 17:       expect(described_class.child_of?("/foo", "/foo/bar/baz")).to be(true)
// 18:     end
// 19:
// 20:     it "does not recognize a path that is not a child" do
// 21:       expect(described_class.child_of?("/foo", "/bar/baz")).to be(false)
// 22:     end
// 23:
// 24:     it "handles . and .. in paths correctly" do
// 25:       expect(described_class.child_of?("/foo", "/foo/./bar")).to be(true)
// 26:       expect(described_class.child_of?("/foo/bar", "/foo/../foo/bar/baz")).to be(true)
// 27:     end
// 28:
// 29:     it "handles relative paths correctly" do
// 30:       expect(described_class.child_of?("foo", "./bar/baz")).to be(false)
// 31:       expect(described_class.child_of?("../foo", "./bar/baz/../../../foo/bar/baz")).to be(true)
// 32:     end
// 33:   end
// 34:
// 35:   describe "::ensure_child_of!" do
// 36:     it "allows a path that is a child of the parent" do
// 37:       expect { described_class.ensure_child_of!("/foo", "/foo/bar", message: "outside") }.not_to raise_error
// 38:     end
// 39:
// 40:     it "raises the provided message for a path that is not a child" do
// 41:       expect { described_class.ensure_child_of!("/foo", "/bar/baz", message: "outside") }.to raise_error("outside")
// 42:     end
// 43:   end
// 44:
// 45:   describe "::formula_opt_prefix" do
// 46:     it "returns a formula opt prefix without loading a Formula object" do
// 47:       expect(described_class.formula_opt_prefix("foo")).to eq(HOMEBREW_PREFIX/"opt/foo")
// 48:     end
// 49:
// 50:     it "returns a formula opt prefix for a fully qualified formula name" do
// 51:       expect(described_class.formula_opt_prefix("homebrew/core/foo")).to eq(HOMEBREW_PREFIX/"opt/foo")
// 52:     end
// 53:   end
// 54:
// 55:   describe "::formula_opt_bin" do
// 56:     it "returns a formula opt bin path without loading a Formula object" do
// 57:       expect(described_class.formula_opt_bin("foo")).to eq(HOMEBREW_PREFIX/"opt/foo/bin")
// 58:     end
// 59:   end
// 60:
// 61:   describe "::formula_opt_lib" do
// 62:     it "returns a formula opt lib path without loading a Formula object" do
// 63:       expect(described_class.formula_opt_lib("foo")).to eq(HOMEBREW_PREFIX/"opt/foo/lib")
// 64:     end
// 65:   end
// 66:
// 67:   describe "::formula_opt_libexec" do
// 68:     it "returns a formula opt libexec path without loading a Formula object" do
// 69:       expect(described_class.formula_opt_libexec("foo")).to eq(HOMEBREW_PREFIX/"opt/foo/libexec")
// 70:     end
// 71:   end
// 72:
// 73:   describe "::formula_opt_include" do
// 74:     it "returns a formula opt include path without loading a Formula object" do
// 75:       expect(described_class.formula_opt_include("foo")).to eq(HOMEBREW_PREFIX/"opt/foo/include")
// 76:     end
// 77:   end
// 78:
// 79:   describe "::formula_installed_prefixes" do
// 80:     it "returns installed prefixes for formula names" do
// 81:       tmpdir = mktmpdir
// 82:       stub_const("HOMEBREW_CELLAR", tmpdir)
// 83:       (tmpdir/"old-foo/1.0").mkpath
// 84:       (tmpdir/"foo/2.0").mkpath
// 85:
// 86:       expect(described_class.formula_installed_prefixes(["foo", "old-foo"]))
// 87:         .to eq([tmpdir/"old-foo/1.0", tmpdir/"foo/2.0"])
// 88:     end
// 89:
// 90:     it "does not list kegs twice when a name is a symlink to another rack" do
// 91:       tmpdir = mktmpdir
// 92:       stub_const("HOMEBREW_CELLAR", tmpdir)
// 93:       (tmpdir/"foo/1.0").mkpath
// 94:       FileUtils.ln_s(tmpdir/"foo", tmpdir/"foo-alias")
// 95:
// 96:       expect(described_class.formula_installed_prefixes(["foo", "foo-alias"]))
// 97:         .to eq([tmpdir/"foo/1.0"])
// 98:     end
// 99:   end
// 100:
// 101:   describe "::formula_any_version_installed?" do
// 102:     it "checks whether any formula keg has an install receipt without loading a Formula object" do
// 103:       tmpdir = mktmpdir
// 104:       stub_const("HOMEBREW_CELLAR", tmpdir)
// 105:       expect(described_class.formula_any_version_installed?("foo")).to be(false)
// 106:
// 107:       (tmpdir/"foo/1.0").mkpath
// 108:       expect(described_class.formula_any_version_installed?("foo")).to be(false)
// 109:
// 110:       (tmpdir/"foo/1.0/INSTALL_RECEIPT.json").write("{}")
// 111:       expect(described_class.formula_any_version_installed?("foo")).to be(true)
// 112:     end
// 113:
// 114:     it "checks fully qualified formula names" do
// 115:       tmpdir = mktmpdir
// 116:       stub_const("HOMEBREW_CELLAR", tmpdir)
// 117:       (tmpdir/"foo/1.0/INSTALL_RECEIPT.json").tap do |receipt|
// 118:         receipt.dirname.mkpath
// 119:         receipt.write("{}")
// 120:       end
// 121:
// 122:       expect(described_class.formula_any_version_installed?("homebrew/core/foo")).to be(true)
// 123:     end
// 124:
// 125:     it "checks multiple possible formula names" do
// 126:       tmpdir = mktmpdir
// 127:       stub_const("HOMEBREW_CELLAR", tmpdir)
// 128:       (tmpdir/"old-foo/1.0/INSTALL_RECEIPT.json").tap do |receipt|
// 129:         receipt.dirname.mkpath
// 130:         receipt.write("{}")
// 131:       end
// 132:
// 133:       expect(described_class.formula_any_version_installed?(["foo", "old-foo"])).to be(true)
// 134:     end
// 135:   end
// 136:
// 137:   describe "::formula_opt_bin_path" do
// 138:     it "prepends a formula opt bin path to the current PATH by default" do
// 139:       expect(described_class.formula_opt_bin_path("foo")).to eq(PATH.new(HOMEBREW_PREFIX/"opt/foo/bin",
// 140:                                                                          ENV.fetch("PATH")))
// 141:     end
// 142:
// 143:     it "prepends a formula opt bin path to PATH entries" do
// 144:       expect(described_class.formula_opt_bin_path("foo", "/usr/bin")).to eq(PATH.new(HOMEBREW_PREFIX/"opt/foo/bin",
// 145:                                                                                      "/usr/bin",
// 146:                                                                                      ENV.fetch("PATH")))
// 147:     end
// 148:   end
// 149:
// 150:   describe "::formula_opt_bin_env" do
// 151:     it "returns a PATH environment with a formula opt bin path prepended to the current PATH by default" do
// 152:       expect(described_class.formula_opt_bin_env("foo"))
// 153:         .to eq({ "PATH" => PATH.new(HOMEBREW_PREFIX/"opt/foo/bin", ENV.fetch("PATH")).to_s })
// 154:     end
// 155:
// 156:     it "returns a PATH environment with extra PATH entries" do
// 157:       expect(described_class.formula_opt_bin_env("foo", "/usr/bin"))
// 158:         .to eq({ "PATH" => PATH.new(HOMEBREW_PREFIX/"opt/foo/bin", "/usr/bin", ENV.fetch("PATH")).to_s })
// 159:     end
// 160:   end
// 161:
// 162:   describe "::loadable_package_path?" do
// 163:     it "accepts formula paths under a symlinked cellar" do
// 164:       tmpdir = mktmpdir
// 165:       real_cellar = tmpdir/"real-cellar"
// 166:       symlink_cellar = tmpdir/"cellar"
// 167:
// 168:       real_cellar.mkpath
// 169:       FileUtils.ln_s(real_cellar, symlink_cellar)
// 170:       stub_const("HOMEBREW_CELLAR", symlink_cellar)
// 171:       allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(true)
// 172:
// 173:       formula_path = real_cellar/"poshtui/0.16/.brew/poshtui.rb"
// 174:       formula_path.dirname.mkpath
// 175:       formula_path.write <<~RUBY
// 176:         class Poshtui < Formula; end
// 177:       RUBY
// 178:
// 179:       expect(described_class.loadable_package_path?(formula_path, :formula)).to be(true)
// 180:     end
// 181:
// 182:     it "accepts formula paths under a symlinked tap" do
// 183:       tmpdir = mktmpdir.realpath
// 184:       library = tmpdir/"Library"
// 185:       (library/"Taps/homebrew").mkpath
// 186:       stub_const("HOMEBREW_LIBRARY", library)
// 187:       allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(true)
// 188:
// 189:       external_tap = tmpdir/"external/homebrew-foo"
// 190:       (external_tap/"Formula").mkpath
// 191:       FileUtils.ln_s(external_tap, library/"Taps/homebrew/homebrew-foo")
// 192:
// 193:       formula_path = library/"Taps/homebrew/homebrew-foo/Formula/foo.rb"
// 194:       formula_path.write "class Foo < Formula; end\n"
// 195:
// 196:       expect(described_class.loadable_package_path?(formula_path, :formula)).to be(true)
// 197:     end
// 198:
// 199:     it "rejects formula paths that escape a trusted root via `..` segments" do
// 200:       tmpdir = mktmpdir.realpath
// 201:       library = tmpdir/"Library"
// 202:       (library/"Taps").mkpath
// 203:       stub_const("HOMEBREW_LIBRARY", library)
// 204:       allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(true)
// 205:
// 206:       escaped = tmpdir/"evil.rb"
// 207:       escaped.write "class Evil < Formula; end\n"
// 208:
// 209:       # Textually starts under `Taps/` but resolves to `tmpdir/evil.rb` outside it.
// 210:       traversal_path = library/"Taps/../../evil.rb"
// 211:
// 212:       expect { described_class.loadable_package_path?(traversal_path, :formula) }
// 213:         .to raise_error(/to be in a tap/)
// 214:     end
// 215:
// 216:     it "rejects local JSON cask paths" do
// 217:       tmpdir = mktmpdir.realpath
// 218:       (tmpdir/"Library/Taps").mkpath
// 219:       stub_const("HOMEBREW_LIBRARY", tmpdir/"Library")
// 220:       allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(true)
// 221:
// 222:       cask_path = tmpdir/"evil.json"
// 223:       cask_path.write "{}\n"
// 224:
// 225:       expect { described_class.loadable_package_path?(cask_path, :cask) }
// 226:         .to raise_error(/to be in a tap/)
// 227:     end
// 228:   end
// 229: end
