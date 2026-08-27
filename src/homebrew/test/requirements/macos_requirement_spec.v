module requirements

import brew_runtime

// Translated from Homebrew/brew `test/requirements/macos_requirement_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:requirement) { described_class.new }` at line 7.
pub fn ruby_macos_requirement_spec_l7_d1_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requirement', ...args)
}

// Ruby let `let(:macos_oldest_allowed) { MacOSVersion.new(HOMEBREW_MACOS_OLDEST_ALLOWED) }` at line 9.
pub fn ruby_macos_requirement_spec_l9_d2_macos_oldest_allowed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_oldest_allowed', ...args)
}

// Ruby let `let(:macos_newest_allowed) { MacOSVersion.new(HOMEBREW_MACOS_NEWEST_UNSUPPORTED) }` at line 10.
pub fn ruby_macos_requirement_spec_l10_d3_macos_newest_allowed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_newest_allowed', ...args)
}

// Ruby let `let(:tahoe_major) { MacOSVersion.new("26.0") }` at line 11.
pub fn ruby_macos_requirement_spec_l11_d4_tahoe_major(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tahoe_major', ...args)
}

// Ruby it `it "returns true" do` at line 15.
pub fn ruby_macos_requirement_spec_l15_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "supports version symbols" do` at line 19.
pub fn ruby_macos_requirement_spec_l19_d6_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "supports maximum versions" do` at line 24.
pub fn ruby_macos_requirement_spec_l24_d7_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "returns false" do` at line 31.
pub fn ruby_macos_requirement_spec_l31_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby specify `specify "#minimum_version" do` at line 41.
pub fn ruby_macos_requirement_spec_l41_d9_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#minimum_version', ...args)
}

// Ruby specify `specify "#maximum_version" do` at line 54.
pub fn ruby_macos_requirement_spec_l54_d10_maximum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#maximum_version', ...args)
}

// Ruby specify `specify "#allows?" do` at line 67.
pub fn ruby_macos_requirement_spec_l67_d11_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#allows?', ...args)
}

// Ruby let `let(:min_requirement) { described_class.new([:tahoe], comparator: ">=") }` at line 81.
pub fn ruby_macos_requirement_spec_l81_d12_min_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('min_requirement', ...args)
}

// Ruby let `let(:max_requirement) { described_class.new([:monterey], comparator: "<=") }` at line 82.
pub fn ruby_macos_requirement_spec_l82_d13_max_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_requirement', ...args)
}

// Ruby let `let(:no_requirement) { described_class.new }` at line 83.
pub fn ruby_macos_requirement_spec_l83_d14_no_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_requirement', ...args)
}

// Ruby it `it "reflects the dependent type" do` at line 86.
pub fn ruby_macos_requirement_spec_l86_d15_reflects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reflects', ...args)
}

// Ruby it `it "always outputs incompatible OS" do` at line 99.
pub fn ruby_macos_requirement_spec_l99_d16_always(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('always', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirements/macos_requirement"
// 5:
// 6: RSpec.describe MacOSRequirement do
// 7:   subject(:requirement) { described_class.new }
// 8:
// 9:   let(:macos_oldest_allowed) { MacOSVersion.new(HOMEBREW_MACOS_OLDEST_ALLOWED) }
// 10:   let(:macos_newest_allowed) { MacOSVersion.new(HOMEBREW_MACOS_NEWEST_UNSUPPORTED) }
// 11:   let(:tahoe_major) { MacOSVersion.new("26.0") }
// 12:
// 13:   describe "#satisfied?" do
// 14:     context "when running on macOS", :needs_macos do
// 15:       it "returns true" do
// 16:         expect(requirement.satisfied?).to be true
// 17:       end
// 18:
// 19:       it "supports version symbols" do
// 20:         requirement = described_class.new([MacOS.version.to_sym])
// 21:         expect(requirement).to be_satisfied
// 22:       end
// 23:
// 24:       it "supports maximum versions" do
// 25:         requirement = described_class.new([:catalina], comparator: "<=")
// 26:         expect(requirement.satisfied?).to eq MacOS.version <= :catalina
// 27:       end
// 28:     end
// 29:
// 30:     context "when running on Linux", :needs_linux do
// 31:       it "returns false" do
// 32:         expect(requirement.satisfied?).to be false
// 33:         requirement = described_class.new([macos_newest_allowed.to_sym])
// 34:         expect(requirement.satisfied?).to be false
// 35:         requirement = described_class.new([macos_newest_allowed.to_sym], comparator: "<=")
// 36:         expect(requirement.satisfied?).to be false
// 37:       end
// 38:     end
// 39:   end
// 40:
// 41:   specify "#minimum_version" do
// 42:     no_requirement = described_class.new
// 43:     max_requirement = described_class.new([:tahoe], comparator: "<=")
// 44:     min_requirement = described_class.new([:tahoe], comparator: ">=")
// 45:     exact_requirement = described_class.new([:tahoe], comparator: "==")
// 46:     range_requirement = described_class.new([[:sonoma, :tahoe]], comparator: "==")
// 47:     expect(no_requirement.minimum_version).to eq macos_oldest_allowed
// 48:     expect(max_requirement.minimum_version).to eq macos_oldest_allowed
// 49:     expect(min_requirement.minimum_version).to eq tahoe_major
// 50:     expect(exact_requirement.minimum_version).to eq tahoe_major
// 51:     expect(range_requirement.minimum_version).to eq "14"
// 52:   end
// 53:
// 54:   specify "#maximum_version" do
// 55:     no_requirement = described_class.new
// 56:     max_requirement = described_class.new([:tahoe], comparator: "<=")
// 57:     min_requirement = described_class.new([:tahoe], comparator: ">=")
// 58:     exact_requirement = described_class.new([:tahoe], comparator: "==")
// 59:     range_requirement = described_class.new([[:sonoma, :tahoe]], comparator: "==")
// 60:     expect(no_requirement.maximum_version).to eq macos_newest_allowed
// 61:     expect(max_requirement.maximum_version).to eq tahoe_major
// 62:     expect(min_requirement.maximum_version).to eq macos_newest_allowed
// 63:     expect(exact_requirement.maximum_version).to eq tahoe_major
// 64:     expect(range_requirement.maximum_version).to eq tahoe_major
// 65:   end
// 66:
// 67:   specify "#allows?" do
// 68:     no_requirement = described_class.new
// 69:     max_requirement = described_class.new([:sequoia], comparator: "<=")
// 70:     min_requirement = described_class.new([:ventura], comparator: ">=")
// 71:     exact_requirement = described_class.new([:tahoe], comparator: "==")
// 72:     range_requirement = described_class.new([[:sonoma, :tahoe]], comparator: "==")
// 73:     expect(no_requirement.allows?(tahoe_major)).to be true
// 74:     expect(max_requirement.allows?(tahoe_major)).to be false
// 75:     expect(min_requirement.allows?(tahoe_major)).to be true
// 76:     expect(exact_requirement.allows?(tahoe_major)).to be true
// 77:     expect(range_requirement.allows?(tahoe_major)).to be true
// 78:   end
// 79:
// 80:   describe "#message" do
// 81:     let(:min_requirement) { described_class.new([:tahoe], comparator: ">=") }
// 82:     let(:max_requirement) { described_class.new([:monterey], comparator: "<=") }
// 83:     let(:no_requirement) { described_class.new }
// 84:
// 85:     context "when running on macOS", :needs_macos do
// 86:       it "reflects the dependent type" do
// 87:         expect(min_requirement.message)
// 88:           .to eq "This formula does not run on macOS versions older than Tahoe."
// 89:         expect(min_requirement.message(type: :cask))
// 90:           .to eq "This cask does not run on macOS versions older than Tahoe."
// 91:         expect(max_requirement.message(type: :cask))
// 92:           .to eq "This cask does not run on macOS versions newer than Monterey."
// 93:         expect(no_requirement.message).to eq "This formula requires macOS."
// 94:         expect(no_requirement.message(type: :cask)).to eq "This cask requires macOS."
// 95:       end
// 96:     end
// 97:
// 98:     context "when running on Linux", :needs_linux do
// 99:       it "always outputs incompatible OS" do
// 100:         expect(min_requirement.message).to eq "This formula requires macOS."
// 101:         expect(min_requirement.message(type: :cask)).to eq "This cask requires macOS."
// 102:         expect(max_requirement.message(type: :cask)).to eq "This cask requires macOS."
// 103:         expect(no_requirement.message).to eq "This formula requires macOS."
// 104:         expect(no_requirement.message(type: :cask)).to eq "This cask requires macOS."
// 105:       end
// 106:     end
// 107:   end
// 108: end
