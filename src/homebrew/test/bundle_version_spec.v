module test

import brew_runtime

// Translated from Homebrew/brew `test/bundle_version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "compares both the `short_version` and `version`" do` at line 8.
pub fn ruby_bundle_version_spec_l8_d1_compares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compares', ...args)
}

// Ruby it `it "compares `version` first" do` at line 15.
pub fn ruby_bundle_version_spec_l15_d2_compares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compares', ...args)
}

// Ruby it `it "does not fail when `short_version` or `version` is missing" do` at line 19.
pub fn ruby_bundle_version_spec_l19_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "maps (#{short_version.inspect}, expect(described_class.new(short_version, version).nice_version) .to eq expected_version end end end  describe "#to_h" do it "returns a hash containing non-nil instance variables" do expect(described_class.new("1.2.3", "3000").to_h) .to eq({ short_version: "1.2.3", version: "3000" }) expect(described_class.new(nil, "3000").to_h) .to eq({ version: "3000" }) expect(described_class.new("1.2.3", nil).to_h) .to eq({ short_version: "1.2.3" }) end end end` at line 45.
pub fn ruby_bundle_version_spec_l45_d4_maps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('maps', ...args)
}

// Ruby it `it "returns a hash containing non-nil instance variables" do` at line 53.
pub fn ruby_bundle_version_spec_l53_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
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
