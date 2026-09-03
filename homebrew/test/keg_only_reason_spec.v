module test

import homebrew

// Translated from Homebrew/brew `test/keg_only_reason_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns the reason provided" do` at line 8.
pub fn ruby_keg_only_reason_spec_l8_d1_returns() bool {
	return homebrew.new_keg_only_reason('provided_by_macos', 'test').str() == 'test'
}

// Ruby it `it "returns a default message when no reason is provided" do` at line 13.
pub fn ruby_keg_only_reason_spec_l13_d2_returns() bool {
	return homebrew.new_keg_only_reason('provided_by_macos', '').str().starts_with('macOS already provides')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg_only_reason"
// 5:
// 6: RSpec.describe KegOnlyReason do
// 7:   describe "#to_s" do
// 8:     it "returns the reason provided" do
// 9:       r = described_class.new :provided_by_macos, "test"
// 10:       expect(r.to_s).to eq("test")
// 11:     end
// 12:
// 13:     it "returns a default message when no reason is provided" do
// 14:       r = described_class.new :provided_by_macos, ""
// 15:       expect(r.to_s).to match(/^macOS already provides/)
// 16:     end
// 17:   end
// 18: end
