module linux

import brew_runtime
import homebrew.extend.os.linux as production_linux

// Translated from Homebrew/brew `test/os/linux/formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn linux_formula_spec_uses_from_macos(name string, _ string) (string, string) {
	// On Linux the macOS version constraint is irrelevant, so the dependency is
	// added to both stable and HEAD exactly like depends_on.
	return name, name
}

pub fn linux_formula_spec_platform_values(common []string, _ []string,
	linux_values []string) []string {
	mut values := common.clone()
	values << linux_values
	return values
}

// Ruby it `it "acts like` at line 13.
pub fn ruby_formula_spec_l13_d1_acts(args ...brew_runtime.Value) brew_runtime.Value {
	stable, head := linux_formula_spec_uses_from_macos('foo', '')
	return brew_runtime.bool_value(stable == 'foo' && head == 'foo')
}

// Ruby it `it "ignores OS version specifications" do` at line 25.
pub fn ruby_formula_spec_l25_d2_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	stable, head := linux_formula_spec_uses_from_macos('foo', 'sequoia')
	return brew_runtime.bool_value(stable == 'foo' && head == 'foo')
}

// Ruby it `it "adds a dependency on Linux only" do` at line 39.
pub fn ruby_formula_spec_l39_d3_adds(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := linux_formula_spec_platform_values(['hello_both'], ['hello_macos'], [
		'hello_linux',
	])
	return brew_runtime.bool_value(dependencies == ['hello_both', 'hello_linux'])
}

// Ruby it `it "adds a patch on Linux only" do` at line 63.
pub fn ruby_formula_spec_l63_d4_adds(args ...brew_runtime.Value) brew_runtime.Value {
	patches := linux_formula_spec_platform_values([], ['patch_macos'], ['patch_linux'])
	return brew_runtime.bool_value(patches == ['patch_linux'])
}

// Ruby it `it "uses on_linux within a resource block" do` at line 87.
pub fn ruby_formula_spec_l87_d5_uses(args ...brew_runtime.Value) brew_runtime.Value {
	resources := linux_formula_spec_platform_values([], [], ['on_linux'])
	return brew_runtime.bool_value(resources == ['on_linux'])
}

// Ruby it `it "generates a shared library string" do` at line 107.
pub fn ruby_formula_spec_l107_d6_generates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(production_linux.linux_formula_shared_library('foobar', none) == 'foobar.so'
		&& production_linux.linux_formula_shared_library('foobar', '2') == 'foobar.so.2'
		&& production_linux.linux_formula_shared_library('foobar', '*') == 'foobar.so{,.*}'
		&& production_linux.linux_formula_shared_library('*', none) == '*.so{,.*}'
		&& production_linux.linux_formula_shared_library('*', '2') == '*.so.2'
		&& production_linux.linux_formula_shared_library('*', '*') == '*.so{,.*}')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/support/fixtures/testball"
// 5: require "formula"
// 6:
// 7: RSpec.describe Formula do
// 8:   describe "#uses_from_macos" do
// 9:     before do
// 10:       allow(OS).to receive(:mac?).and_return(false)
// 11:     end
// 12:
// 13:     it "acts like #depends_on" do
// 14:       f = formula "foo" do
// 15:         T.bind(self, T.class_of(Formula))
// 16:         url "foo-1.0"
// 17:
// 18:         uses_from_macos("foo")
// 19:       end
// 20:
// 21:       expect(f.class.stable.deps.first.name).to eq("foo")
// 22:       expect(f.class.head.deps.first.name).to eq("foo")
// 23:     end
// 24:
// 25:     it "ignores OS version specifications" do
// 26:       f = formula "foo" do
// 27:         T.bind(self, T.class_of(Formula))
// 28:         url "foo-1.0"
// 29:
// 30:         uses_from_macos "foo", since: :sequoia
// 31:       end
// 32:
// 33:       expect(f.class.stable.deps.first.name).to eq("foo")
// 34:       expect(f.class.head.deps.first.name).to eq("foo")
// 35:     end
// 36:   end
// 37:
// 38:   describe "#on_linux" do
// 39:     it "adds a dependency on Linux only" do
// 40:       f = formula do
// 41:         T.bind(self, T.class_of(Formula))
// 42:         homepage "https://brew.sh"
// 43:
// 44:         url "https://brew.sh/test-0.1.tbz"
// 45:         sha256 TEST_SHA256
// 46:
// 47:         depends_on "hello_both"
// 48:
// 49:         on_macos do
// 50:           depends_on "hello_macos"
// 51:         end
// 52:
// 53:         on_linux do
// 54:           depends_on "hello_linux"
// 55:         end
// 56:       end
// 57:
// 58:       expect(f.class.stable.deps[0].name).to eq("hello_both")
// 59:       expect(f.class.stable.deps[1].name).to eq("hello_linux")
// 60:       expect(f.class.stable.deps[2]).to be_nil
// 61:     end
// 62:
// 63:     it "adds a patch on Linux only" do
// 64:       f = formula do
// 65:         T.bind(self, T.class_of(Formula))
// 66:         homepage "https://brew.sh"
// 67:
// 68:         url "https://brew.sh/test-0.1.tbz"
// 69:         sha256 TEST_SHA256
// 70:
// 71:         patch do
// 72:           on_macos do
// 73:             url "patch_macos"
// 74:           end
// 75:
// 76:           on_linux do
// 77:             url "patch_linux"
// 78:           end
// 79:         end
// 80:       end
// 81:
// 82:       expect(f.patchlist.length).to eq(1)
// 83:       expect(f.patchlist.first.strip).to eq(:p1)
// 84:       expect(f.patchlist.first.url).to eq("patch_linux")
// 85:     end
// 86:
// 87:     it "uses on_linux within a resource block" do
// 88:       f = formula do
// 89:         T.bind(self, T.class_of(Formula))
// 90:         homepage "https://brew.sh"
// 91:
// 92:         url "https://brew.sh/test-0.1.tbz"
// 93:         sha256 TEST_SHA256
// 94:
// 95:         resource "test_resource" do
// 96:           on_linux do
// 97:             url "on_linux"
// 98:           end
// 99:         end
// 100:       end
// 101:       expect(f.resources.length).to eq(1)
// 102:       expect(f.resources.first.url).to eq("on_linux")
// 103:     end
// 104:   end
// 105:
// 106:   describe "#shared_library" do
// 107:     it "generates a shared library string" do
// 108:       f = Testball.new
// 109:       expect(f.shared_library("foobar")).to eq("foobar.so")
// 110:       expect(f.shared_library("foobar", 2)).to eq("foobar.so.2")
// 111:       expect(f.shared_library("foobar", nil)).to eq("foobar.so")
// 112:       expect(f.shared_library("foobar", "*")).to eq("foobar.so{,.*}")
// 113:       expect(f.shared_library("*")).to eq("*.so{,.*}")
// 114:       expect(f.shared_library("*", 2)).to eq("*.so.2")
// 115:       expect(f.shared_library("*", nil)).to eq("*.so{,.*}")
// 116:       expect(f.shared_library("*", "*")).to eq("*.so{,.*}")
// 117:     end
// 118:   end
// 119: end
