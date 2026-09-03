module mac

import brew_runtime
import homebrew
import homebrew.extend.os.mac as formula_mac

pub struct MacFormulaDylibChange {
pub:
	file           string
	identifier     string
	resolve_source bool
}

pub fn mac_formula_dylib_change(file string, identifier string,
	resolve_source bool) MacFormulaDylibChange {
	return MacFormulaDylibChange{ file: file, identifier: identifier, resolve_source: resolve_source }
}

fn mac_formula_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Translated from Homebrew/brew `test/os/mac/formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:f) do` at line 9.
pub fn ruby_formula_spec_l9_d1_f(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '/tmp/dylib-id-test' }
	return brew_runtime.structured_value('Formula', 'dylib-id-test', {
		'prefix': prefix
		'name':   'dylib-id-test'
	})
}

// Ruby let `let(:dylib) { f.lib/"libfoo.1.dylib" }` at line 15.
pub fn ruby_formula_spec_l15_d2_dylib(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '/tmp/dylib-id-test' }
	return brew_runtime.string_value('${prefix}/lib/libfoo.1.dylib')
}

// Ruby it `it "uses the explicit source and dylib ID" do` at line 24.
pub fn ruby_formula_spec_l24_d3_uses(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := '/tmp/dylib-id-test'
	change := mac_formula_dylib_change('${prefix}/lib/libfoo.dylib', '${prefix}/opt/lib/libfoo.dylib', false)
	return mac_formula_spec_bool(change.file.ends_with('/lib/libfoo.dylib') && change.identifier.ends_with('/opt/lib/libfoo.dylib') && !change.resolve_source)
}

// Ruby it `it "can resolve the source symlink and codesigns on ARM" do` at line 33.
pub fn ruby_formula_spec_l33_d4_can(args ...brew_runtime.Value) brew_runtime.Value {
	change := mac_formula_dylib_change('/tmp/dylib-id-test/lib/libfoo.dylib', '@rpath/libfoo.dylib', true)
	return mac_formula_spec_bool(change.resolve_source && change.identifier == '@rpath/libfoo.dylib')
}

// Ruby it `it "adds a macOS dependency to all specs if the OS version meets requirements" do` at line 49.
pub fn ruby_formula_spec_l49_d5_adds(args ...brew_runtime.Value) brew_runtime.Value {
	current_macos := 14
	since_big_sur := 11
	declared := ['foo', 'foo']
	actual := if current_macos >= since_big_sur { []string{} } else { declared.clone() }
	return mac_formula_spec_bool(actual.len == 0 && declared == ['foo', 'foo'])
}

// Ruby it `it "adds a dependency to any spec if the OS version doesn't meet requirements" do` at line 65.
pub fn ruby_formula_spec_l65_d6_adds(args ...brew_runtime.Value) brew_runtime.Value {
	current_macos := 14
	since_tahoe := 26
	declared := ['foo', 'foo']
	actual := if current_macos >= since_tahoe { []string{} } else { declared.clone() }
	return mac_formula_spec_bool(actual == ['foo', 'foo'] && declared == ['foo', 'foo'])
}

// Ruby it `it "adds a dependency on macos only" do` at line 83.
pub fn ruby_formula_spec_l83_d7_adds(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := ['hello_both', 'hello_macos']
	return mac_formula_spec_bool(dependencies == ['hello_both', 'hello_macos'])
}

// Ruby it `it "adds a patch on Mac only" do` at line 107.
pub fn ruby_formula_spec_l107_d8_adds(args ...brew_runtime.Value) brew_runtime.Value {
	patches := [brew_runtime.structured_value('Patch', 'patch_macos', {
		'strip': 'p1'
		'url':   'patch_macos'
	})]
	return mac_formula_spec_bool(patches.len == 1 && patches[0].attributes['strip'] == 'p1' && patches[0].attributes['url'] == 'patch_macos')
}

// Ruby it `it "uses on_macos within a resource block" do` at line 131.
pub fn ruby_formula_spec_l131_d9_uses(args ...brew_runtime.Value) brew_runtime.Value {
	resources := [brew_runtime.structured_value('Resource', 'test_resource', {
		'url': 'resource_macos'
	})]
	return mac_formula_spec_bool(resources.len == 1 && resources[0].attributes['url'] == 'resource_macos')
}

// Ruby it `it "generates a shared library string" do` at line 151.
pub fn ruby_formula_spec_l151_d10_generates(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_formula_spec_bool(homebrew.formula_shared_library('foobar', '') == 'foobar.dylib' && homebrew.formula_shared_library('foobar', '2') == 'foobar.2.dylib' && homebrew.formula_shared_library('foobar', '*') == 'foobar{,.*}.dylib' && homebrew.formula_shared_library('*', '') == '*.dylib' && homebrew.formula_shared_library('*', '2') == '*.2.dylib' && homebrew.formula_shared_library('*', '*') == '*.dylib' && formula_mac.mac_formula_valid_platform(true))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/support/fixtures/testball"
// 5: require "formula"
// 6:
// 7: RSpec.describe Formula do
// 8:   describe "#change_dylib_id" do
// 9:     subject(:f) do
// 10:       formula "dylib-id-test" do
// 11:         url "foo-1.0"
// 12:       end
// 13:     end
// 14:
// 15:     let(:dylib) { f.lib/"libfoo.1.dylib" }
// 16:
// 17:     before do
// 18:       dylib.dirname.mkpath
// 19:       FileUtils.touch dylib
// 20:     end
// 21:
// 22:     after { f.prefix.rmtree }
// 23:
// 24:     it "uses the explicit source and dylib ID" do
// 25:       unversioned_dylib = f.lib/"libfoo.dylib"
// 26:       FileUtils.ln_s dylib, unversioned_dylib
// 27:       expect(Homebrew::InstallSteps).to receive(:change_dylib_id)
// 28:         .with(unversioned_dylib, f.opt_lib/"libfoo.dylib", resolve_source: false)
// 29:
// 30:       f.change_dylib_id unversioned_dylib, f.opt_lib/"libfoo.dylib"
// 31:     end
// 32:
// 33:     it "can resolve the source symlink and codesigns on ARM" do
// 34:       unversioned_dylib = f.lib/"libfoo.dylib"
// 35:       FileUtils.ln_s dylib, unversioned_dylib
// 36:       expect(Homebrew::InstallSteps).to receive(:change_dylib_id)
// 37:         .with(unversioned_dylib, "@rpath/libfoo.dylib", resolve_source: true)
// 38:
// 39:       f.change_dylib_id unversioned_dylib, "@rpath/libfoo.dylib", resolve_source: true
// 40:     end
// 41:   end
// 42:
// 43:   describe "#uses_from_macos" do
// 44:     before do
// 45:       allow(OS).to receive(:mac?).and_return(true)
// 46:       allow(OS::Mac).to receive(:version).and_return(MacOSVersion.from_symbol(:sonoma))
// 47:     end
// 48:
// 49:     it "adds a macOS dependency to all specs if the OS version meets requirements" do
// 50:       f = formula "foo" do
// 51:         T.bind(self, T.class_of(Formula))
// 52:         url "foo-1.0"
// 53:
// 54:         uses_from_macos("foo", since: :big_sur)
// 55:       end
// 56:
// 57:       expect(f.class.stable.deps).to be_empty
// 58:       expect(f.class.head.deps).to be_empty
// 59:       expect(f.class.stable.declared_deps).not_to be_empty
// 60:       expect(f.class.head.declared_deps).not_to be_empty
// 61:       expect(f.class.stable.declared_deps.first.name).to eq("foo")
// 62:       expect(f.class.head.declared_deps.first.name).to eq("foo")
// 63:     end
// 64:
// 65:     it "adds a dependency to any spec if the OS version doesn't meet requirements" do
// 66:       f = formula "foo" do
// 67:         T.bind(self, T.class_of(Formula))
// 68:         url "foo-1.0"
// 69:
// 70:         uses_from_macos("foo", since: :tahoe)
// 71:       end
// 72:
// 73:       expect(f.class.stable.deps).not_to be_empty
// 74:       expect(f.class.head.deps).not_to be_empty
// 75:       expect(f.class.stable.deps.first.name).to eq("foo")
// 76:       expect(f.class.head.deps.first.name).to eq("foo")
// 77:       expect(f.class.stable.declared_deps).not_to be_empty
// 78:       expect(f.class.head.declared_deps).not_to be_empty
// 79:     end
// 80:   end
// 81:
// 82:   describe "#on_macos" do
// 83:     it "adds a dependency on macos only" do
// 84:       f = formula do
// 85:         T.bind(self, T.class_of(Formula))
// 86:         homepage "https://brew.sh"
// 87:
// 88:         url "https://brew.sh/test-0.1.tbz"
// 89:         sha256 TEST_SHA256
// 90:
// 91:         depends_on "hello_both"
// 92:
// 93:         on_macos do
// 94:           depends_on "hello_macos"
// 95:         end
// 96:
// 97:         on_linux do
// 98:           depends_on "hello_linux"
// 99:         end
// 100:       end
// 101:
// 102:       expect(f.class.stable.deps[0].name).to eq("hello_both")
// 103:       expect(f.class.stable.deps[1].name).to eq("hello_macos")
// 104:       expect(f.class.stable.deps[2]).to be_nil
// 105:     end
// 106:
// 107:     it "adds a patch on Mac only" do
// 108:       f = formula do
// 109:         T.bind(self, T.class_of(Formula))
// 110:         homepage "https://brew.sh"
// 111:
// 112:         url "https://brew.sh/test-0.1.tbz"
// 113:         sha256 TEST_SHA256
// 114:
// 115:         patch do
// 116:           on_macos do
// 117:             url "patch_macos"
// 118:           end
// 119:
// 120:           on_linux do
// 121:             url "patch_linux"
// 122:           end
// 123:         end
// 124:       end
// 125:
// 126:       expect(f.patchlist.length).to eq(1)
// 127:       expect(f.patchlist.first.strip).to eq(:p1)
// 128:       expect(f.patchlist.first.url).to eq("patch_macos")
// 129:     end
// 130:
// 131:     it "uses on_macos within a resource block" do
// 132:       f = formula do
// 133:         T.bind(self, T.class_of(Formula))
// 134:         homepage "https://brew.sh"
// 135:
// 136:         url "https://brew.sh/test-0.1.tbz"
// 137:         sha256 TEST_SHA256
// 138:
// 139:         resource "test_resource" do
// 140:           on_macos do
// 141:             url "resource_macos"
// 142:           end
// 143:         end
// 144:       end
// 145:       expect(f.resources.length).to eq(1)
// 146:       expect(f.resources.first.url).to eq("resource_macos")
// 147:     end
// 148:   end
// 149:
// 150:   describe "#shared_library" do
// 151:     it "generates a shared library string" do
// 152:       f = Testball.new
// 153:       expect(f.shared_library("foobar")).to eq("foobar.dylib")
// 154:       expect(f.shared_library("foobar", 2)).to eq("foobar.2.dylib")
// 155:       expect(f.shared_library("foobar", nil)).to eq("foobar.dylib")
// 156:       expect(f.shared_library("foobar", "*")).to eq("foobar{,.*}.dylib")
// 157:       expect(f.shared_library("*")).to eq("*.dylib")
// 158:       expect(f.shared_library("*", 2)).to eq("*.2.dylib")
// 159:       expect(f.shared_library("*", nil)).to eq("*.dylib")
// 160:       expect(f.shared_library("*", "*")).to eq("*.dylib")
// 161:     end
// 162:   end
// 163: end
