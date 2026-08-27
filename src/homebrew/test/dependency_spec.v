module test

import brew_runtime

// Translated from Homebrew/brew `test/dependency_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby alias_matcher `alias_matcher :be_a_build_dependency, :be_build` at line 7.
pub fn ruby_dependency_spec_l7_d1_be_a_build_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_a_build_dependency', ...args)
}

// Ruby it `it "accepts a single tag" do` at line 10.
pub fn ruby_dependency_spec_l10_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts multiple tags" do` at line 15.
pub fn ruby_dependency_spec_l15_d3_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "preserves symbol tags" do` at line 20.
pub fn ruby_dependency_spec_l20_d4_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "accepts symbol and string tags" do` at line 25.
pub fn ruby_dependency_spec_l25_d5_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "merges duplicate dependencies" do` at line 32.
pub fn ruby_dependency_spec_l32_d6_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "merges necessity tags" do` at line 47.
pub fn ruby_dependency_spec_l47_d7_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "merges temporality tags" do` at line 71.
pub fn ruby_dependency_spec_l71_d8_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby specify `specify "equality" do` at line 81.
pub fn ruby_dependency_spec_l81_d9_equality(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('equality', ...args)
}

// Ruby it `it "returns a tap passed a fully-qualified name" do` at line 102.
pub fn ruby_dependency_spec_l102_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns no tap passed a simple name" do` at line 107.
pub fn ruby_dependency_spec_l107_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby specify `specify "#option_names" do` at line 113.
pub fn ruby_dependency_spec_l113_d12_option_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#option_names', ...args)
}

// Ruby it `it "marks dependency as no_linkage" do` at line 119.
pub fn ruby_dependency_spec_l119_d13_marks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('marks', ...args)
}

// Ruby subject `subject(:dependency) { described_class.new("foo") }` at line 129.
pub fn ruby_dependency_spec_l129_d14_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency', ...args)
}

// Ruby it `it "accepts macOS bottle_os_version parameter" do` at line 131.
pub fn ruby_dependency_spec_l131_d15_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 135.
pub fn ruby_dependency_spec_l135_d16_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby subject `subject(:dependency) { described_class.new("foo") }` at line 141.
pub fn ruby_dependency_spec_l141_d17_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency', ...args)
}

// Ruby it `it "accepts bottle_os_version parameter" do` at line 143.
pub fn ruby_dependency_spec_l143_d18_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 147.
pub fn ruby_dependency_spec_l147_d19_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby subject `subject(:uses_from_macos) { described_class.new("foo", bounds: { since: :sonoma }) }` at line 153.
pub fn ruby_dependency_spec_l153_d20_uses_from_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses_from_macos', ...args)
}

// Ruby it `it "accepts macOS bottle_os_version parameter" do` at line 155.
pub fn ruby_dependency_spec_l155_d21_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts Ubuntu bottle_os_version parameter" do` at line 159.
pub fn ruby_dependency_spec_l159_d22_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependency"
// 5:
// 6: RSpec.describe Dependency do
// 7:   alias_matcher :be_a_build_dependency, :be_build
// 8:
// 9:   describe "::new" do
// 10:     it "accepts a single tag" do
// 11:       dep = described_class.new("foo", %w[bar])
// 12:       expect(dep.tags).to eq(%w[bar])
// 13:     end
// 14:
// 15:     it "accepts multiple tags" do
// 16:       dep = described_class.new("foo", %w[bar baz])
// 17:       expect(dep.tags.sort).to eq(%w[bar baz].sort)
// 18:     end
// 19:
// 20:     it "preserves symbol tags" do
// 21:       dep = described_class.new("foo", [:build])
// 22:       expect(dep.tags).to eq([:build])
// 23:     end
// 24:
// 25:     it "accepts symbol and string tags" do
// 26:       dep = described_class.new("foo", [:build, "bar"])
// 27:       expect(dep.tags).to eq([:build, "bar"])
// 28:     end
// 29:   end
// 30:
// 31:   describe "::merge_repeats" do
// 32:     it "merges duplicate dependencies" do
// 33:       dep = described_class.new("foo", [:build])
// 34:       dep2 = described_class.new("foo", ["bar"])
// 35:       dep3 = described_class.new("xyz", ["abc"])
// 36:       merged = described_class.merge_repeats([dep, dep2, dep3])
// 37:       expect(merged.count).to eq(2)
// 38:       expect(merged.first).to be_a described_class
// 39:
// 40:       foo_named_dep = T.must(merged.find { |d| d.name == "foo" })
// 41:       expect(foo_named_dep.tags).to eq(["bar"])
// 42:
// 43:       xyz_named_dep = T.must(merged.find { |d| d.name == "xyz" })
// 44:       expect(xyz_named_dep.tags).to eq(["abc"])
// 45:     end
// 46:
// 47:     it "merges necessity tags" do
// 48:       required_dep = described_class.new("foo")
// 49:       recommended_dep = described_class.new("foo", [:recommended])
// 50:       optional_dep = described_class.new("foo", [:optional])
// 51:
// 52:       deps = described_class.merge_repeats([required_dep, recommended_dep])
// 53:       expect(deps.count).to eq(1)
// 54:       expect(deps.first).to be_required
// 55:       expect(deps.first).not_to be_recommended
// 56:       expect(deps.first).not_to be_optional
// 57:
// 58:       deps = described_class.merge_repeats([required_dep, optional_dep])
// 59:       expect(deps.count).to eq(1)
// 60:       expect(deps.first).to be_required
// 61:       expect(deps.first).not_to be_recommended
// 62:       expect(deps.first).not_to be_optional
// 63:
// 64:       deps = described_class.merge_repeats([recommended_dep, optional_dep])
// 65:       expect(deps.count).to eq(1)
// 66:       expect(deps.first).not_to be_required
// 67:       expect(deps.first).to be_recommended
// 68:       expect(deps.first).not_to be_optional
// 69:     end
// 70:
// 71:     it "merges temporality tags" do
// 72:       normal_dep = described_class.new("foo")
// 73:       build_dep = described_class.new("foo", [:build])
// 74:
// 75:       deps = described_class.merge_repeats([normal_dep, build_dep])
// 76:       expect(deps.count).to eq(1)
// 77:       expect(deps.first).not_to be_a_build_dependency
// 78:     end
// 79:   end
// 80:
// 81:   specify "equality" do
// 82:     foo1 = described_class.new("foo")
// 83:     foo2 = described_class.new("foo")
// 84:     expect(foo1).to eq(foo2)
// 85:     expect(foo1).to eql(foo2)
// 86:
// 87:     bar = described_class.new("bar")
// 88:     expect(foo1).not_to eq(bar)
// 89:     expect(foo1).not_to eql(bar)
// 90:
// 91:     foo3 = described_class.new("foo", [:build])
// 92:     expect(foo1).not_to eq(foo3)
// 93:     expect(foo1).not_to eql(foo3)
// 94:
// 95:     uses_from_macos_ventura = UsesFromMacOSDependency.new("foo", [], bounds: { since: :ventura })
// 96:     uses_from_macos_sonoma = UsesFromMacOSDependency.new("foo", [], bounds: { since: :sonoma })
// 97:     expect(uses_from_macos_ventura).not_to eq(uses_from_macos_sonoma)
// 98:     expect(uses_from_macos_ventura).not_to eql(uses_from_macos_sonoma)
// 99:   end
// 100:
// 101:   describe "#tap" do
// 102:     it "returns a tap passed a fully-qualified name" do
// 103:       dependency = described_class.new("foo/bar/dog")
// 104:       expect(dependency.tap).to eq(Tap.fetch("foo", "bar"))
// 105:     end
// 106:
// 107:     it "returns no tap passed a simple name" do
// 108:       dependency = described_class.new("dog")
// 109:       expect(dependency.tap).to be_nil
// 110:     end
// 111:   end
// 112:
// 113:   specify "#option_names" do
// 114:     dependency = described_class.new("foo/bar/dog")
// 115:     expect(dependency.option_names).to eq(%w[dog])
// 116:   end
// 117:
// 118:   describe "with no_linkage tag" do
// 119:     it "marks dependency as no_linkage" do
// 120:       dep = described_class.new("foo", [:no_linkage])
// 121:       expect(dep).to be_no_linkage
// 122:       expect(dep).to be_required
// 123:       expect(dep).not_to be_build
// 124:       expect(dep).not_to be_test
// 125:     end
// 126:   end
// 127:
// 128:   describe "Dependency#installed? with bottle_os_version" do
// 129:     subject(:dependency) { described_class.new("foo") }
// 130:
// 131:     it "accepts macOS bottle_os_version parameter" do
// 132:       expect { dependency.installed?(bottle_os_version: "macOS 14") }.not_to raise_error
// 133:     end
// 134:
// 135:     it "accepts Ubuntu bottle_os_version parameter" do
// 136:       expect { dependency.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 137:     end
// 138:   end
// 139:
// 140:   describe "Dependency#satisfied? with bottle_os_version" do
// 141:     subject(:dependency) { described_class.new("foo") }
// 142:
// 143:     it "accepts bottle_os_version parameter" do
// 144:       expect { dependency.satisfied?(bottle_os_version: "macOS 14") }.not_to raise_error
// 145:     end
// 146:
// 147:     it "accepts Ubuntu bottle_os_version parameter" do
// 148:       expect { dependency.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 149:     end
// 150:   end
// 151:
// 152:   describe "UsesFromMacOSDependency#installed? with bottle_os_version" do
// 153:     subject(:uses_from_macos) { described_class.new("foo", bounds: { since: :sonoma }) }
// 154:
// 155:     it "accepts macOS bottle_os_version parameter" do
// 156:       expect { uses_from_macos.installed?(bottle_os_version: "macOS 14") }.not_to raise_error
// 157:     end
// 158:
// 159:     it "accepts Ubuntu bottle_os_version parameter" do
// 160:       expect { uses_from_macos.installed?(bottle_os_version: "Ubuntu 22.04") }.not_to raise_error
// 161:     end
// 162:   end
// 163: end
