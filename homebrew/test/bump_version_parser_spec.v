module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/bump_version_parser_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:general_version) { "1.2.3" }` at line 7.
pub fn ruby_bump_version_parser_spec_l7_d1_general_version() string {
	return '1.2.3'
}

// Ruby let `let(:intel_version) { "2.3.4" }` at line 8.
pub fn ruby_bump_version_parser_spec_l8_d2_intel_version() string {
	return '2.3.4'
}

// Ruby let `let(:arm_version) { "3.4.5" }` at line 9.
pub fn ruby_bump_version_parser_spec_l9_d3_arm_version() string {
	return '3.4.5'
}

// Ruby it `it "raises a usage error" do` at line 12.
pub fn ruby_bump_version_parser_spec_l12_d4_raises() bool {
	homebrew.new_bump_version_parser(none, none, none) or {
		return err.msg() == 'Invalid usage: `--version` must not be empty.'
	}
	return false
}

// Ruby let `let(:new_version_arm) { described_class.new(arm: arm_version) }` at line 21.
pub fn ruby_bump_version_parser_spec_l21_d5_new_version_arm() !homebrew.BumpVersionParser {
	return homebrew.new_bump_version_parser_from_strings(none, ruby_bump_version_parser_spec_l9_d3_arm_version(), none)
}

// Ruby it `it "correctly parses arm version" do` at line 23.
pub fn ruby_bump_version_parser_spec_l23_d6_correctly() bool {
	parser := ruby_bump_version_parser_spec_l21_d5_new_version_arm() or { return false }
	return bump_version_spec_text(parser.arm) == ruby_bump_version_parser_spec_l9_d3_arm_version()
}

// Ruby let `let(:new_version_intel) { described_class.new(intel: intel_version) }` at line 29.
pub fn ruby_bump_version_parser_spec_l29_d7_new_version_intel() !homebrew.BumpVersionParser {
	return homebrew.new_bump_version_parser_from_strings(none, none, ruby_bump_version_parser_spec_l8_d2_intel_version())
}

// Ruby it `it "correctly parses intel version" do` at line 31.
pub fn ruby_bump_version_parser_spec_l31_d8_correctly() bool {
	parser := ruby_bump_version_parser_spec_l29_d7_new_version_intel() or { return false }
	return bump_version_spec_text(parser.intel) == ruby_bump_version_parser_spec_l8_d2_intel_version()
}

// Ruby let `let(:new_version_arm_intel) { described_class.new(arm: arm_version, intel: intel_version) }` at line 37.
pub fn ruby_bump_version_parser_spec_l37_d9_new_version_arm_intel() !homebrew.BumpVersionParser {
	return homebrew.new_bump_version_parser_from_strings(none, ruby_bump_version_parser_spec_l9_d3_arm_version(), ruby_bump_version_parser_spec_l8_d2_intel_version())
}

// Ruby it `it "correctly parses arm and intel versions" do` at line 39.
pub fn ruby_bump_version_parser_spec_l39_d10_correctly() bool {
	parser := ruby_bump_version_parser_spec_l37_d9_new_version_arm_intel() or {
		return false
	}
	return bump_version_spec_text(parser.arm) == ruby_bump_version_parser_spec_l9_d3_arm_version() && bump_version_spec_text(parser.intel) == ruby_bump_version_parser_spec_l8_d2_intel_version()
}

// Ruby let `let(:new_version) { described_class.new(general: general_version, arm: arm_version, intel: intel_version) }` at line 46.
pub fn ruby_bump_version_parser_spec_l46_d11_new_version() !homebrew.BumpVersionParser {
	return homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), ruby_bump_version_parser_spec_l9_d3_arm_version(), ruby_bump_version_parser_spec_l8_d2_intel_version())
}

// Ruby let `let(:new_version_version) do` at line 47.
pub fn ruby_bump_version_parser_spec_l47_d12_new_version_version() !homebrew.BumpVersionParser {
	general := homebrew.new_version(ruby_bump_version_parser_spec_l7_d1_general_version())!
	arm := homebrew.new_version(ruby_bump_version_parser_spec_l9_d3_arm_version())!
	intel := homebrew.new_version(ruby_bump_version_parser_spec_l8_d2_intel_version())!
	return homebrew.new_bump_version_parser(homebrew.new_formula_bump_version(general), homebrew.new_formula_bump_version(arm), homebrew.new_formula_bump_version(intel))
}

// Ruby specify `specify do` at line 55.
pub fn ruby_bump_version_parser_spec_l55_d13_do() bool {
	from_strings := ruby_bump_version_parser_spec_l46_d11_new_version() or { return false }
	from_versions := ruby_bump_version_parser_spec_l47_d12_new_version_version() or {
		return false
	}
	return bump_version_spec_text(from_strings.general) == ruby_bump_version_parser_spec_l7_d1_general_version() && bump_version_spec_text(from_versions.general) == ruby_bump_version_parser_spec_l7_d1_general_version() && bump_version_spec_text(from_strings.arm) == ruby_bump_version_parser_spec_l9_d3_arm_version() && bump_version_spec_text(from_versions.arm) == ruby_bump_version_parser_spec_l9_d3_arm_version() && bump_version_spec_text(from_strings.intel) == ruby_bump_version_parser_spec_l8_d2_intel_version() && bump_version_spec_text(from_versions.intel) == ruby_bump_version_parser_spec_l8_d2_intel_version() && bump_version_spec_source(from_versions.general) == .formula
}

// Ruby it `it "returns a version object for latest" do` at line 65.
pub fn ruby_bump_version_parser_spec_l65_d14_returns() bool {
	parser := homebrew.new_bump_version_parser_from_strings('latest', none, none) or {
		return false
	}
	version := parser.general or { return false }
	return version.str() == 'latest' && version.latest && version.source == .cask
}

// Ruby it `it "returns a version object for the given version" do` at line 71.
pub fn ruby_bump_version_parser_spec_l71_d15_returns() bool {
	parser := homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), none, none) or {
		return false
	}
	return bump_version_spec_text(parser.general) == ruby_bump_version_parser_spec_l7_d1_general_version()
}

// Ruby it `it "returns false if any version is present" do` at line 79.
pub fn ruby_bump_version_parser_spec_l79_d16_returns() bool {
	parser := homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), '', '') or {
		return false
	}
	return !parser.is_blank() && parser.arm == none && parser.intel == none
}

// Ruby let `let(:new_version) { described_class.new(general: general_version, arm: arm_version, intel: intel_version) }` at line 87.
pub fn ruby_bump_version_parser_spec_l87_d17_new_version() !homebrew.BumpVersionParser {
	return ruby_bump_version_parser_spec_l46_d11_new_version()
}

// Ruby it `it "returns false" do` at line 90.
pub fn ruby_bump_version_parser_spec_l90_d18_returns() bool {
	parser := ruby_bump_version_parser_spec_l87_d17_new_version() or { return false }
	equal := homebrew.ruby_bump_version_parser_l57_d8_anonymous(homebrew.bump_version_parser_value(parser), ruby.object_value('Version', '1.2.3')).as_bool() or {
		return false
	}
	return !equal
}

// Ruby it `it "returns true" do` at line 96.
pub fn ruby_bump_version_parser_spec_l96_d19_returns() bool {
	parser := ruby_bump_version_parser_spec_l87_d17_new_version() or { return false }
	same_version := ruby_bump_version_parser_spec_l46_d11_new_version() or { return false }
	return parser.equals(same_version)
}

// Ruby it `it "returns false" do` at line 104.
pub fn ruby_bump_version_parser_spec_l104_d20_returns() bool {
	parser := ruby_bump_version_parser_spec_l87_d17_new_version() or { return false }
	different_versions := [
		homebrew.new_bump_version_parser_from_strings('3.2.1', ruby_bump_version_parser_spec_l9_d3_arm_version(), ruby_bump_version_parser_spec_l8_d2_intel_version()) or { return false },
		homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), '4.3.2', ruby_bump_version_parser_spec_l8_d2_intel_version()) or { return false },
		homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), ruby_bump_version_parser_spec_l9_d3_arm_version(), '5.4.3') or { return false },
		homebrew.new_bump_version_parser_from_strings('3.2.1', '4.3.2', ruby_bump_version_parser_spec_l8_d2_intel_version()) or { return false },
		homebrew.new_bump_version_parser_from_strings(ruby_bump_version_parser_spec_l7_d1_general_version(), '4.3.2', '5.4.3') or { return false },
		homebrew.new_bump_version_parser_from_strings('3.2.1', ruby_bump_version_parser_spec_l9_d3_arm_version(), '5.4.3') or { return false },
	]
	return different_versions.all(!parser.equals(it))
}

fn bump_version_spec_text(version ?homebrew.BumpVersion) string {
	parsed := version or { return '' }
	return parsed.str()
}

fn bump_version_spec_source(version ?homebrew.BumpVersion) homebrew.BumpVersionSource {
	parsed := version or { return .cask }
	return parsed.source
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bump_version_parser"
// 5:
// 6: RSpec.describe Homebrew::BumpVersionParser do
// 7:   let(:general_version) { "1.2.3" }
// 8:   let(:intel_version) { "2.3.4" }
// 9:   let(:arm_version) { "3.4.5" }
// 10:
// 11:   context "when initializing with no versions" do
// 12:     it "raises a usage error" do
// 13:       expect do
// 14:         described_class.new
// 15:       end.to raise_error(UsageError,
// 16:                          "Invalid usage: `--version` must not be empty.")
// 17:     end
// 18:   end
// 19:
// 20:   context "when initializing with only an arm version" do
// 21:     let(:new_version_arm) { described_class.new(arm: arm_version) }
// 22:
// 23:     it "correctly parses arm version" do
// 24:       expect(new_version_arm.arm).to eq(Cask::DSL::Version.new(arm_version.to_s))
// 25:     end
// 26:   end
// 27:
// 28:   context "when initializing with only an intel version" do
// 29:     let(:new_version_intel) { described_class.new(intel: intel_version) }
// 30:
// 31:     it "correctly parses intel version" do
// 32:       expect(new_version_intel.intel).to eq(Cask::DSL::Version.new(intel_version.to_s))
// 33:     end
// 34:   end
// 35:
// 36:   context "when initializing with arm and intel versions" do
// 37:     let(:new_version_arm_intel) { described_class.new(arm: arm_version, intel: intel_version) }
// 38:
// 39:     it "correctly parses arm and intel versions" do
// 40:       expect(new_version_arm_intel.arm).to eq(Cask::DSL::Version.new(arm_version.to_s))
// 41:       expect(new_version_arm_intel.intel).to eq(Cask::DSL::Version.new(intel_version.to_s))
// 42:     end
// 43:   end
// 44:
// 45:   context "when initializing with all versions" do
// 46:     let(:new_version) { described_class.new(general: general_version, arm: arm_version, intel: intel_version) }
// 47:     let(:new_version_version) do
// 48:       described_class.new(
// 49:         general: Version.new(general_version),
// 50:         arm:     Version.new(arm_version),
// 51:         intel:   Version.new(intel_version),
// 52:       )
// 53:     end
// 54:
// 55:     specify do
// 56:       expect(new_version.general).to eq(Cask::DSL::Version.new(general_version.to_s))
// 57:       expect(new_version_version.general).to eq(Cask::DSL::Version.new(general_version.to_s))
// 58:       expect(new_version.arm).to eq(Cask::DSL::Version.new(arm_version.to_s))
// 59:       expect(new_version_version.arm).to eq(Cask::DSL::Version.new(arm_version.to_s))
// 60:       expect(new_version.intel).to eq(Cask::DSL::Version.new(intel_version.to_s))
// 61:       expect(new_version_version.intel).to eq(Cask::DSL::Version.new(intel_version.to_s))
// 62:     end
// 63:
// 64:     context "when the version is latest" do
// 65:       it "returns a version object for latest" do
// 66:         new_version = described_class.new(general: "latest")
// 67:         expect(new_version.general.to_s).to eq("latest")
// 68:       end
// 69:
// 70:       context "when the version is not latest" do
// 71:         it "returns a version object for the given version" do
// 72:           new_version = described_class.new(general: general_version)
// 73:           expect(new_version.general.to_s).to eq(general_version)
// 74:         end
// 75:       end
// 76:     end
// 77:
// 78:     context "when checking if VersionParser is blank" do
// 79:       it "returns false if any version is present" do
// 80:         new_version = described_class.new(general: general_version.to_s, arm: "", intel: "")
// 81:         expect(new_version.blank?).to be(false)
// 82:       end
// 83:     end
// 84:   end
// 85:
// 86:   describe "#==" do
// 87:     let(:new_version) { described_class.new(general: general_version, arm: arm_version, intel: intel_version) }
// 88:
// 89:     context "when other object is not a `BumpVersionParser`" do
// 90:       it "returns false" do
// 91:         expect(new_version == Version.new("1.2.3")).to be(false)
// 92:       end
// 93:     end
// 94:
// 95:     context "when comparing objects with equal versions" do
// 96:       it "returns true" do
// 97:         same_version = described_class.new(general: general_version, arm: arm_version,
// 98:                                            intel: intel_version)
// 99:         expect(new_version == same_version).to be(true)
// 100:       end
// 101:     end
// 102:
// 103:     context "when comparing objects with different versions" do
// 104:       it "returns false" do
// 105:         different_general_version = described_class.new(general: "3.2.1", arm: arm_version,
// 106:                                                         intel: intel_version)
// 107:         different_arm_version = described_class.new(general: general_version, arm: "4.3.2",
// 108:                                                     intel: intel_version)
// 109:         different_intel_version = described_class.new(general: general_version, arm: arm_version,
// 110:                                                       intel: "5.4.3")
// 111:         different_general_arm_versions = described_class.new(general: "3.2.1", arm: "4.3.2",
// 112:                                                              intel: intel_version)
// 113:         different_arm_intel_versions = described_class.new(general: general_version, arm: "4.3.2",
// 114:                                                            intel: "5.4.3")
// 115:         different_general_intel_versions = described_class.new(general: "3.2.1", arm: arm_version,
// 116:                                                                intel: "5.4.3")
// 117:
// 118:         expect(new_version == different_general_version).to be(false)
// 119:         expect(new_version == different_arm_version).to be(false)
// 120:         expect(new_version == different_intel_version).to be(false)
// 121:         expect(new_version == different_general_arm_versions).to be(false)
// 122:         expect(new_version == different_arm_intel_versions).to be(false)
// 123:         expect(new_version == different_general_intel_versions).to be(false)
// 124:       end
// 125:     end
// 126:   end
// 127: end
