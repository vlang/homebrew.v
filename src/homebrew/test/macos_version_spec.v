module test

import brew_runtime

// Translated from Homebrew/brew `test/macos_version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:version) { described_class.new("10.15") }` at line 7.
pub fn ruby_macos_version_spec_l7_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby let `let(:tahoe_major) { described_class.new("26.0") }` at line 8.
pub fn ruby_macos_version_spec_l8_d2_tahoe_major(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tahoe_major', ...args)
}

// Ruby let `let(:big_sur_major) { described_class.new("11.0") }` at line 9.
pub fn ruby_macos_version_spec_l9_d3_big_sur_major(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('big_sur_major', ...args)
}

// Ruby let `let(:big_sur_update) { described_class.new("11.1") }` at line 10.
pub fn ruby_macos_version_spec_l10_d4_big_sur_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('big_sur_update', ...args)
}

// Ruby let `let(:frozen_version) { described_class.new("10.15").freeze }` at line 11.
pub fn ruby_macos_version_spec_l11_d5_frozen_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('frozen_version', ...args)
}

// Ruby it `it "returns the kernel major version" do` at line 14.
pub fn ruby_macos_version_spec_l14_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "matches the major version returned by OS.kernel_version", :needs_macos do` at line 21.
pub fn ruby_macos_version_spec_l21_d7_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "raises an error if the symbol is not a valid macOS version" do` at line 28.
pub fn ruby_macos_version_spec_l28_d8_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "creates a new version from a valid macOS version" do` at line 34.
pub fn ruby_macos_version_spec_l34_d9_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "raises an error if the version is not a valid macOS version" do` at line 41.
pub fn ruby_macos_version_spec_l41_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "creates a new version from a valid macOS version" do` at line 47.
pub fn ruby_macos_version_spec_l47_d11_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby specify `specify "comparisons" do` at line 53.
pub fn ruby_macos_version_spec_l53_d12_comparisons(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comparisons', ...args)
}

// Ruby specify `specify "comparison with :big_sur" do` at line 86.
pub fn ruby_macos_version_spec_l86_d13_comparison(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comparison', ...args)
}

// Ruby let `let(:catalina_update) { described_class.new("10.15.1") }` at line 102.
pub fn ruby_macos_version_spec_l102_d14_catalina_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('catalina_update', ...args)
}

// Ruby specify `specify do` at line 104.
pub fn ruby_macos_version_spec_l104_d15_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby specify `specify "#to_sym" do` at line 111.
pub fn ruby_macos_version_spec_l111_d16_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#to_sym', ...args)
}

// Ruby specify `specify "#pretty_name" do` at line 126.
pub fn ruby_macos_version_spec_l126_d17_pretty_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#pretty_name', ...args)
}

// Ruby it `it "returns true if version requires a Nehalem CPU" do` at line 146.
pub fn ruby_macos_version_spec_l146_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises an error" do` at line 153.
pub fn ruby_macos_version_spec_l153_d19_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "returns false when version is null" do` at line 160.
pub fn ruby_macos_version_spec_l160_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_version"
// 5:
// 6: RSpec.describe MacOSVersion do
// 7:   let(:version) { described_class.new("10.15") }
// 8:   let(:tahoe_major) { described_class.new("26.0") }
// 9:   let(:big_sur_major) { described_class.new("11.0") }
// 10:   let(:big_sur_update) { described_class.new("11.1") }
// 11:   let(:frozen_version) { described_class.new("10.15").freeze }
// 12:
// 13:   describe "::kernel_major_version" do
// 14:     it "returns the kernel major version" do
// 15:       expect(described_class.kernel_major_version(version)).to eq "19"
// 16:       expect(described_class.kernel_major_version(tahoe_major)).to eq "25"
// 17:       expect(described_class.kernel_major_version(big_sur_major)).to eq "20"
// 18:       expect(described_class.kernel_major_version(big_sur_update)).to eq "20"
// 19:     end
// 20:
// 21:     it "matches the major version returned by OS.kernel_version", :needs_macos do
// 22:       ENV["HOMEBREW_FAKE_MACOS"] = nil
// 23:       expect(described_class.kernel_major_version(OS::Mac.version)).to eq OS.kernel_version.major
// 24:     end
// 25:   end
// 26:
// 27:   describe "::from_symbol" do
// 28:     it "raises an error if the symbol is not a valid macOS version" do
// 29:       expect do
// 30:         described_class.from_symbol(:foo)
// 31:       end.to raise_error(MacOSVersion::Error, "unknown or unsupported macOS version: :foo")
// 32:     end
// 33:
// 34:     it "creates a new version from a valid macOS version" do
// 35:       symbol_version = described_class.from_symbol(:catalina)
// 36:       expect(symbol_version).to eq(version)
// 37:     end
// 38:   end
// 39:
// 40:   describe "#new" do
// 41:     it "raises an error if the version is not a valid macOS version" do
// 42:       expect do
// 43:         described_class.new("1.2")
// 44:       end.to raise_error(MacOSVersion::Error, 'unknown or unsupported macOS version: "1.2"')
// 45:     end
// 46:
// 47:     it "creates a new version from a valid macOS version" do
// 48:       string_version = described_class.new("11")
// 49:       expect(string_version).to eq(:big_sur)
// 50:     end
// 51:   end
// 52:
// 53:   specify "comparisons" do
// 54:     expect(version).to be >= :catalina
// 55:     expect(version).to eq :catalina
// 56:     # We're explicitly testing the `===` operator results here.
// 57:     expect(version).to be === :catalina # rubocop:disable Style/CaseEquality
// 58:     expect(version).to be < :tahoe
// 59:
// 60:     # This should work like a normal comparison but the result won't be added
// 61:     # to the `@comparison_cache` hash because the object is frozen.
// 62:     expect(frozen_version).to eq :catalina
// 63:     expect(frozen_version.comparison_cache).to eq({})
// 64:
// 65:     expect(version).to be > 10
// 66:     expect(version).to be < 11
// 67:     expect(version).to be > "10.3"
// 68:     expect(version).to eq "10.15"
// 69:     # We're explicitly testing the `===` operator results here.
// 70:     expect(version).to be === "10.15" # rubocop:disable Style/CaseEquality
// 71:     expect(version).to be < "11"
// 72:     expect(version).to be > Version.new("10.3")
// 73:     expect(version).to eq Version.new("10.15")
// 74:     # We're explicitly testing the `===` operator results here.
// 75:     expect(version).to be === Version.new("10.15") # rubocop:disable Style/CaseEquality
// 76:     expect(version).to be < Version.new("11")
// 77:     expect(described_class.new("11").inspect).to eq("#<MacOSVersion: \"11\">")
// 78:     expect(described_class.new(MacOSVersion::SYMBOLS.values.first).outdated_release?).to be false
// 79:     expect(described_class.new("10.0").outdated_release?).to be true
// 80:     expect(described_class.new("1000").prerelease?).to be true
// 81:     expect(described_class.new("10.0").unsupported_release?).to be true
// 82:     expect(described_class.new("1000").unsupported_release?).to be true
// 83:   end
// 84:
// 85:   describe "after Big Sur" do
// 86:     specify "comparison with :big_sur" do
// 87:       expect(big_sur_major).to eq :big_sur
// 88:       expect(big_sur_major).to be <= :big_sur
// 89:       expect(big_sur_major).to be >= :big_sur
// 90:       expect(big_sur_major).not_to be > :big_sur
// 91:       expect(big_sur_major).not_to be < :big_sur
// 92:
// 93:       expect(big_sur_update).to eq :big_sur
// 94:       expect(big_sur_update).to be <= :big_sur
// 95:       expect(big_sur_update).to be >= :big_sur
// 96:       expect(big_sur_update).not_to be > :big_sur
// 97:       expect(big_sur_update).not_to be < :big_sur
// 98:     end
// 99:   end
// 100:
// 101:   describe "#strip_patch" do
// 102:     let(:catalina_update) { described_class.new("10.15.1") }
// 103:
// 104:     specify do
// 105:       expect(big_sur_update.strip_patch).to eq(described_class.new("11"))
// 106:       expect(catalina_update.strip_patch).to eq(described_class.new("10.15"))
// 107:       expect(MacOSVersion::NULL.strip_patch).to be MacOSVersion::NULL
// 108:     end
// 109:   end
// 110:
// 111:   specify "#to_sym" do
// 112:     version_symbol = :catalina
// 113:
// 114:     # We call this more than once to exercise the caching logic
// 115:     expect(version.to_sym).to eq(version_symbol)
// 116:     expect(version.to_sym).to eq(version_symbol)
// 117:
// 118:     # This should work like a normal but the symbol won't be stored as the
// 119:     # `@sym` instance variable because the object is frozen.
// 120:     expect(frozen_version.to_sym).to eq(version_symbol)
// 121:     expect(frozen_version.sym).to be_nil
// 122:
// 123:     expect(MacOSVersion::NULL.to_sym).to eq(:dunno)
// 124:   end
// 125:
// 126:   specify "#pretty_name" do
// 127:     version_pretty_name = "Catalina"
// 128:
// 129:     expect(described_class.new("11").pretty_name).to eq("Big Sur")
// 130:
// 131:     # We call this more than once to exercise the caching logic
// 132:     expect(version.pretty_name).to eq(version_pretty_name)
// 133:     expect(version.pretty_name).to eq(version_pretty_name)
// 134:
// 135:     # This should work like a normal but the computed name won't be stored as
// 136:     # the `@pretty_name` instance variable because the object is frozen.
// 137:     expect(frozen_version.pretty_name).to eq(version_pretty_name)
// 138:     # Read the raw ivar: a reader would collide with the memoising `pretty_name`.
// 139:     # rubocop:disable Homebrew/NoInstanceVariableAccessInTests
// 140:     expect(frozen_version.instance_variable_get(:@pretty_name)).to be_nil
// 141:     # rubocop:enable Homebrew/NoInstanceVariableAccessInTests
// 142:   end
// 143:
// 144:   describe "#requires_nehalem_cpu?", :needs_macos do
// 145:     context "when CPU is Intel" do
// 146:       it "returns true if version requires a Nehalem CPU" do
// 147:         allow(Hardware::CPU).to receive(:type).and_return(:intel)
// 148:         expect(described_class.new("10.15").requires_nehalem_cpu?).to be true
// 149:       end
// 150:     end
// 151:
// 152:     context "when CPU is not Intel" do
// 153:       it "raises an error" do
// 154:         allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 155:         expect { described_class.new("10.15").requires_nehalem_cpu? }
// 156:           .to raise_error(ArgumentError)
// 157:       end
// 158:     end
// 159:
// 160:     it "returns false when version is null" do
// 161:       expect(MacOSVersion::NULL.requires_nehalem_cpu?).to be false
// 162:     end
// 163:   end
// 164: end
