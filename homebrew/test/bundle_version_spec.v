module test

import homebrew

// Translated from Homebrew/brew `test/bundle_version_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn bundle_version_spec_new(short_version ?string, version ?string) ?homebrew.BundleVersion {
	return homebrew.new_bundle_version(short_version, version) or { return none }
}

fn bundle_version_spec_nice(short_version ?string, version ?string, expected string) bool {
	bundle := bundle_version_spec_new(short_version, version) or { return false }
	return bundle.nice_version() == expected
}

// Ruby it `it "compares both the `short_version` and `version`" do` at line 8.
pub fn ruby_bundle_version_spec_l8_d1_compares() bool {
	v3000 := bundle_version_spec_new('1.2.3', '3000') or { return false }
	v4000 := bundle_version_spec_new('1.2.3', '4000') or { return false }
	v124 := bundle_version_spec_new('1.2.4', '4000') or { return false }
	return v3000.compare_to(v4000) < 0 && v4000.compare_to(v4000) <= 0 && v4000.compare_to(v4000) >= 0 && v124.compare_to(v4000) > 0
}

// Ruby it `it "compares `version` first" do` at line 15.
pub fn ruby_bundle_version_spec_l15_d2_compares() bool {
	left := bundle_version_spec_new('1.2.4', '3000') or { return false }
	right := bundle_version_spec_new('1.2.3', '4000') or { return false }
	return left.compare_to(right) < 0
}

// Ruby it `it "does not fail when `short_version` or `version` is missing" do` at line 19.
pub fn ruby_bundle_version_spec_l19_d3_does() bool {
	short_106 := bundle_version_spec_new('1.06', none) or { return false }
	both_112 := bundle_version_spec_new('1.12', '1.12') or { return false }
	both_471 := bundle_version_spec_new('1.06', '471') or { return false }
	version_311 := bundle_version_spec_new(none, '311') or { return false }
	short_123 := bundle_version_spec_new('1.2.3', none) or { return false }
	short_124 := bundle_version_spec_new('1.2.4', none) or { return false }
	version_123 := bundle_version_spec_new(none, '1.2.3') or { return false }
	version_124 := bundle_version_spec_new(none, '1.2.4') or { return false }
	return short_106.compare_to(both_112) < 0 && both_471.compare_to(version_311) > 0 && short_123.compare_to(short_124) < 0 && version_123.compare_to(version_124) < 0 && short_123.compare_to(version_123) < 0 && version_123.compare_to(short_123) > 0
}

// Ruby it `it "maps (#{short_version.inspect}, #{version.inspect}) to #{expected_version.inspect}" do` at line 45.
pub fn ruby_bundle_version_spec_l45_d4_maps() bool {
	return bundle_version_spec_nice('1.2', none, '1.2') && bundle_version_spec_nice(none, '1.2.3', '1.2.3') && bundle_version_spec_nice('1.2', '1.2.3', '1.2.3') && bundle_version_spec_nice('1.2.3', '1.2', '1.2.3') && bundle_version_spec_nice('1.2.3', '8312', '1.2.3,8312') && bundle_version_spec_nice('2021', '2006', '2021,2006') && bundle_version_spec_nice('1.0', '1', '1.0') && bundle_version_spec_nice('1.0', '0', '1.0') && bundle_version_spec_nice('1.2.3.4000', '4000', '1.2.3.4000') && bundle_version_spec_nice('5', '5.0.45', '5.0.45') && bundle_version_spec_nice('2.5.2(3329)', '3329', '2.5.2,3329')
}

// Ruby it `it "returns a hash containing non-nil instance variables" do` at line 53.
pub fn ruby_bundle_version_spec_l53_d5_returns() bool {
	both := bundle_version_spec_new('1.2.3', '3000') or { return false }
	version := bundle_version_spec_new(none, '3000') or { return false }
	short_version := bundle_version_spec_new('1.2.3', none) or { return false }
	return both.to_h() == {
		'short_version': '1.2.3'
		'version':       '3000'
	} && version.to_h() == {
		'version': '3000'
	} && short_version.to_h() == {
		'short_version': '1.2.3'
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5:
// 6: RSpec.describe Homebrew::BundleVersion do
// 7:   describe "#<=>" do
// 8:     it "compares both the `short_version` and `version`" do
// 9:       expect(described_class.new("1.2.3", "3000")).to be < described_class.new("1.2.3", "4000")
// 10:       expect(described_class.new("1.2.3", "4000")).to be <= described_class.new("1.2.3", "4000")
// 11:       expect(described_class.new("1.2.3", "4000")).to be >= described_class.new("1.2.3", "4000")
// 12:       expect(described_class.new("1.2.4", "4000")).to be > described_class.new("1.2.3", "4000")
// 13:     end
// 14:
// 15:     it "compares `version` first" do
// 16:       expect(described_class.new("1.2.4", "3000")).to be < described_class.new("1.2.3", "4000")
// 17:     end
// 18:
// 19:     it "does not fail when `short_version` or `version` is missing" do
// 20:       expect(described_class.new("1.06", nil)).to be < described_class.new("1.12", "1.12")
// 21:       expect(described_class.new("1.06", "471")).to be > described_class.new(nil, "311")
// 22:       expect(described_class.new("1.2.3", nil)).to be < described_class.new("1.2.4", nil)
// 23:       expect(described_class.new(nil, "1.2.3")).to be < described_class.new(nil, "1.2.4")
// 24:       expect(described_class.new("1.2.3", nil)).to be < described_class.new(nil, "1.2.3")
// 25:       expect(described_class.new(nil, "1.2.3")).to be > described_class.new("1.2.3", nil)
// 26:     end
// 27:   end
// 28:
// 29:   describe "#nice_version" do
// 30:     expected_mappings = {
// 31:       ["1.2", nil]            => "1.2",
// 32:       [nil, "1.2.3"]          => "1.2.3",
// 33:       ["1.2", "1.2.3"]        => "1.2.3",
// 34:       ["1.2.3", "1.2"]        => "1.2.3",
// 35:       ["1.2.3", "8312"]       => "1.2.3,8312",
// 36:       ["2021", "2006"]        => "2021,2006",
// 37:       ["1.0", "1"]            => "1.0",
// 38:       ["1.0", "0"]            => "1.0",
// 39:       ["1.2.3.4000", "4000"]  => "1.2.3.4000",
// 40:       ["5", "5.0.45"]         => "5.0.45",
// 41:       ["2.5.2(3329)", "3329"] => "2.5.2,3329",
// 42:     }
// 43:
// 44:     expected_mappings.each do |(short_version, version), expected_version|
// 45:       it "maps (#{short_version.inspect}, #{version.inspect}) to #{expected_version.inspect}" do
// 46:         expect(described_class.new(short_version, version).nice_version)
// 47:           .to eq expected_version
// 48:       end
// 49:     end
// 50:   end
// 51:
// 52:   describe "#to_h" do
// 53:     it "returns a hash containing non-nil instance variables" do
// 54:       expect(described_class.new("1.2.3", "3000").to_h)
// 55:         .to eq({ short_version: "1.2.3", version: "3000" })
// 56:       expect(described_class.new(nil, "3000").to_h)
// 57:         .to eq({ version: "3000" })
// 58:       expect(described_class.new("1.2.3", nil).to_h)
// 59:         .to eq({ short_version: "1.2.3" })
// 60:     end
// 61:   end
// 62: end
