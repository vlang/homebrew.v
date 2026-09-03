module test

import homebrew

// Translated from Homebrew/brew `test/pkg_version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "parses versions from a string" do` at line 8.
pub fn ruby_pkg_version_spec_l8_d1_parses() !bool {
	return homebrew.parse_pkg_version('1.0_1')!.equals(homebrew.new_pkg_version(homebrew.new_version('1.0')!, 1)) && homebrew.parse_pkg_version('1.0')!.equals(homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0)) && homebrew.parse_pkg_version('1.0_0')!.equals(homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0)) && homebrew.parse_pkg_version('2.1.4_0')!.equals(homebrew.new_pkg_version(homebrew.new_version('2.1.4')!, 0)) && homebrew.parse_pkg_version('1.0.1e_1')!.equals(homebrew.new_pkg_version(homebrew.new_version('1.0.1e')!, 1))
}

// Ruby specify `specify "#==" do` at line 18.
pub fn ruby_pkg_version_spec_l18_d2_anonymous() !bool {
	version := homebrew.parse_pkg_version('1.0_1')!
	return homebrew.parse_pkg_version('1.0_0')!.equals(homebrew.parse_pkg_version('1.0')!) && version.equals(homebrew.parse_pkg_version('1.0_1')!) && !version.equals(homebrew.parse_pkg_version('1.0_2')!)
}

// Ruby it `it "returns true if the left version is bigger than the right" do` at line 26.
pub fn ruby_pkg_version_spec_l26_d3_returns() !bool {
	return homebrew.parse_pkg_version('1.1')!.compare_to(homebrew.parse_pkg_version('1.0_1')!) > 0
}

// Ruby it `it "returns true if the left version is HEAD" do` at line 30.
pub fn ruby_pkg_version_spec_l30_d4_returns() !bool {
	return homebrew.parse_pkg_version('HEAD')!.compare_to(homebrew.parse_pkg_version('1.0')!) > 0
}

// Ruby it `it "returns true if the left version is smaller than the right" do` at line 36.
pub fn ruby_pkg_version_spec_l36_d5_returns() !bool {
	return homebrew.parse_pkg_version('1.0_1')!.compare_to(homebrew.parse_pkg_version('2.0_1')!) < 0
}

// Ruby it `it "returns true if the right version is HEAD" do` at line 40.
pub fn ruby_pkg_version_spec_l40_d6_returns() !bool {
	return homebrew.parse_pkg_version('1.0')!.compare_to(homebrew.parse_pkg_version('HEAD')!) < 0
}

// Ruby it `it "returns nil if the comparison fails" do` at line 46.
pub fn ruby_pkg_version_spec_l46_d7_returns() ?int {
	// Ruby dispatches this expression to Object#<=> because Object is the left operand.
	return none
}

// Ruby it `it "returns a string of the form 'version_revision'" do` at line 52.
pub fn ruby_pkg_version_spec_l52_d8_returns() !bool {
	return homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0).to_s() == '1.0' && homebrew.new_pkg_version(homebrew.new_version('1.0')!, 1).to_s() == '1.0_1' && homebrew.new_pkg_version(homebrew.new_version('HEAD')!, 1).to_s() == 'HEAD_1' && homebrew.new_pkg_version(homebrew.new_version('HEAD-ffffff')!, 1).to_s() == 'HEAD-ffffff_1'
}

// Ruby let `let(:version_one_revision_one) { described_class.new(Version.new("1.0"), 1) }` at line 63.
pub fn ruby_pkg_version_spec_l63_d9_version_one_revision_one() !homebrew.PkgVersion {
	return homebrew.new_pkg_version(homebrew.new_version('1.0')!, 1)
}

// Ruby let `let(:version_one_dot_one_revision_one) { described_class.new(Version.new("1.1"), 1) }` at line 64.
pub fn ruby_pkg_version_spec_l64_d10_version_one_dot_one_revision_one() !homebrew.PkgVersion {
	return homebrew.new_pkg_version(homebrew.new_version('1.1')!, 1)
}

// Ruby let `let(:version_one_revision_zero) { described_class.new(Version.new("1.0"), 0) }` at line 65.
pub fn ruby_pkg_version_spec_l65_d11_version_one_revision_zero() !homebrew.PkgVersion {
	return homebrew.new_pkg_version(homebrew.new_version('1.0')!, 0)
}

// Ruby it `it "returns a hash based on the version and revision" do` at line 67.
pub fn ruby_pkg_version_spec_l67_d12_returns() !bool {
	one_revision_one := ruby_pkg_version_spec_l63_d9_version_one_revision_one()!
	return one_revision_one.hash() == homebrew.new_pkg_version(homebrew.new_version('1.0')!, 1).hash() && one_revision_one.hash() != ruby_pkg_version_spec_l64_d10_version_one_dot_one_revision_one()!.hash() && one_revision_one.hash() != ruby_pkg_version_spec_l65_d11_version_one_revision_zero()!.hash()
}

// Ruby it `it "returns package version" do` at line 75.
pub fn ruby_pkg_version_spec_l75_d13_returns() !bool {
	return homebrew.parse_pkg_version('1.2.3_4')!.version.equals(homebrew.new_version('1.2.3')!)
}

// Ruby it `it "returns package revision" do` at line 81.
pub fn ruby_pkg_version_spec_l81_d14_returns() !bool {
	return homebrew.parse_pkg_version('1.2.3_4')!.revision == 4
}

// Ruby it `it "returns major version token" do` at line 87.
pub fn ruby_pkg_version_spec_l87_d15_returns() !bool {
	token := homebrew.parse_pkg_version('1.2.3_4')!.major() or { return false }
	return token.to_s() == '1'
}

// Ruby it `it "returns minor version token" do` at line 93.
pub fn ruby_pkg_version_spec_l93_d16_returns() !bool {
	token := homebrew.parse_pkg_version('1.2.3_4')!.minor() or { return false }
	return token.to_s() == '2'
}

// Ruby it `it "returns patch version token" do` at line 99.
pub fn ruby_pkg_version_spec_l99_d17_returns() !bool {
	token := homebrew.parse_pkg_version('1.2.3_4')!.patch() or { return false }
	return token.to_s() == '3'
}

// Ruby it `it "returns major.minor version" do` at line 105.
pub fn ruby_pkg_version_spec_l105_d18_returns() !bool {
	return homebrew.parse_pkg_version('1.2.3_4')!.major_minor().equals(homebrew.new_version('1.2')!)
}

// Ruby it `it "returns major.minor.patch version" do` at line 111.
pub fn ruby_pkg_version_spec_l111_d19_returns() !bool {
	return homebrew.parse_pkg_version('1.2.3_4')!.major_minor_patch().equals(homebrew.new_version('1.2.3')!)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "pkg_version"
// 5:
// 6: RSpec.describe PkgVersion do
// 7:   describe "::parse" do
// 8:     it "parses versions from a string" do
// 9:       expect(described_class.parse("1.0_1")).to eq(described_class.new(Version.new("1.0"), 1))
// 10:       expect(described_class.parse("1.0_1")).to eq(described_class.new(Version.new("1.0"), 1))
// 11:       expect(described_class.parse("1.0")).to eq(described_class.new(Version.new("1.0"), 0))
// 12:       expect(described_class.parse("1.0_0")).to eq(described_class.new(Version.new("1.0"), 0))
// 13:       expect(described_class.parse("2.1.4_0")).to eq(described_class.new(Version.new("2.1.4"), 0))
// 14:       expect(described_class.parse("1.0.1e_1")).to eq(described_class.new(Version.new("1.0.1e"), 1))
// 15:     end
// 16:   end
// 17:
// 18:   specify "#==" do
// 19:     expect(described_class.parse("1.0_0")).to eq described_class.parse("1.0")
// 20:     version_to_compare = described_class.parse("1.0_1")
// 21:     expect(version_to_compare == described_class.parse("1.0_1")).to be true
// 22:     expect(version_to_compare == described_class.parse("1.0_2")).to be false
// 23:   end
// 24:
// 25:   describe "#>" do
// 26:     it "returns true if the left version is bigger than the right" do
// 27:       expect(described_class.parse("1.1")).to be > described_class.parse("1.0_1")
// 28:     end
// 29:
// 30:     it "returns true if the left version is HEAD" do
// 31:       expect(described_class.parse("HEAD")).to be > described_class.parse("1.0")
// 32:     end
// 33:   end
// 34:
// 35:   describe "#<" do
// 36:     it "returns true if the left version is smaller than the right" do
// 37:       expect(described_class.parse("1.0_1")).to be < described_class.parse("2.0_1")
// 38:     end
// 39:
// 40:     it "returns true if the right version is HEAD" do
// 41:       expect(described_class.parse("1.0")).to be < described_class.parse("HEAD")
// 42:     end
// 43:   end
// 44:
// 45:   describe "#<=>" do
// 46:     it "returns nil if the comparison fails" do
// 47:       expect(Object.new <=> described_class.new(Version.new("1.0"), 0)).to be_nil
// 48:     end
// 49:   end
// 50:
// 51:   describe "#to_s" do
// 52:     it "returns a string of the form 'version_revision'" do
// 53:       expect(described_class.new(Version.new("1.0"), 0).to_s).to eq("1.0")
// 54:       expect(described_class.new(Version.new("1.0"), 1).to_s).to eq("1.0_1")
// 55:       expect(described_class.new(Version.new("1.0"), 0).to_s).to eq("1.0")
// 56:       expect(described_class.new(Version.new("1.0"), 0).to_s).to eq("1.0")
// 57:       expect(described_class.new(Version.new("HEAD"), 1).to_s).to eq("HEAD_1")
// 58:       expect(described_class.new(Version.new("HEAD-ffffff"), 1).to_s).to eq("HEAD-ffffff_1")
// 59:     end
// 60:   end
// 61:
// 62:   describe "#hash" do
// 63:     let(:version_one_revision_one) { described_class.new(Version.new("1.0"), 1) }
// 64:     let(:version_one_dot_one_revision_one) { described_class.new(Version.new("1.1"), 1) }
// 65:     let(:version_one_revision_zero) { described_class.new(Version.new("1.0"), 0) }
// 66:
// 67:     it "returns a hash based on the version and revision" do
// 68:       expect(version_one_revision_one.hash).to eq(described_class.new(Version.new("1.0"), 1).hash)
// 69:       expect(version_one_revision_one.hash).not_to eq(version_one_dot_one_revision_one.hash)
// 70:       expect(version_one_revision_one.hash).not_to eq(version_one_revision_zero.hash)
// 71:     end
// 72:   end
// 73:
// 74:   describe "#version" do
// 75:     it "returns package version" do
// 76:       expect(described_class.parse("1.2.3_4").version).to eq Version.new("1.2.3")
// 77:     end
// 78:   end
// 79:
// 80:   describe "#revision" do
// 81:     it "returns package revision" do
// 82:       expect(described_class.parse("1.2.3_4").revision).to eq 4
// 83:     end
// 84:   end
// 85:
// 86:   describe "#major" do
// 87:     it "returns major version token" do
// 88:       expect(described_class.parse("1.2.3_4").major).to eq Version::Token.create("1")
// 89:     end
// 90:   end
// 91:
// 92:   describe "#minor" do
// 93:     it "returns minor version token" do
// 94:       expect(described_class.parse("1.2.3_4").minor).to eq Version::Token.create("2")
// 95:     end
// 96:   end
// 97:
// 98:   describe "#patch" do
// 99:     it "returns patch version token" do
// 100:       expect(described_class.parse("1.2.3_4").patch).to eq Version::Token.create("3")
// 101:     end
// 102:   end
// 103:
// 104:   describe "#major_minor" do
// 105:     it "returns major.minor version" do
// 106:       expect(described_class.parse("1.2.3_4").major_minor).to eq Version.new("1.2")
// 107:     end
// 108:   end
// 109:
// 110:   describe "#major_minor_patch" do
// 111:     it "returns major.minor.patch version" do
// 112:       expect(described_class.parse("1.2.3_4").major_minor_patch).to eq Version.new("1.2.3")
// 113:     end
// 114:   end
// 115: end
