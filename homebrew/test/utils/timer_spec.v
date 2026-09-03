module utils

import homebrew.utils as homebrew_utils

// Translated from Homebrew/brew `test/utils/timer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns nil when nil" do` at line 8.
pub fn ruby_timer_spec_l8_d1_returns() bool {
	return homebrew_utils.timer_remaining_at(none, 10.0) == none
}

// Ruby it `it "returns time remaining when there is time remaining" do` at line 12.
pub fn ruby_timer_spec_l12_d2_returns() bool {
	remaining := homebrew_utils.timer_remaining_at(20.0, 10.0) or { return false }
	return remaining > 1
}

// Ruby it `it "returns 0 when there is no time remaining" do` at line 16.
pub fn ruby_timer_spec_l16_d3_returns() bool {
	remaining := homebrew_utils.timer_remaining_at(0.0, 10.0) or { return false }
	return remaining == 0
}

// Ruby it `it "returns nil when nil" do` at line 22.
pub fn ruby_timer_spec_l22_d4_returns() !bool {
	return !homebrew_utils.timer_remaining_or_error_at(none, 10.0)!.has_value
}

// Ruby it `it "returns time remaining when there is time remaining" do` at line 26.
pub fn ruby_timer_spec_l26_d5_returns() !bool {
	remaining := homebrew_utils.timer_remaining_or_error_at(20.0, 10.0)!
	return remaining.has_value && remaining.seconds > 1
}

// Ruby it `it "returns 0 when there is no time remaining" do` at line 30.
pub fn ruby_timer_spec_l30_d6_returns() bool {
	homebrew_utils.timer_remaining_or_error_at(0.0, 10.0) or { return true }
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/timer"
// 5:
// 6: RSpec.describe Utils::Timer do
// 7:   describe "#remaining" do
// 8:     it "returns nil when nil" do
// 9:       expect(described_class.remaining(nil)).to be_nil
// 10:     end
// 11:
// 12:     it "returns time remaining when there is time remaining" do
// 13:       expect(described_class.remaining(Time.now + 10)).to be > 1
// 14:     end
// 15:
// 16:     it "returns 0 when there is no time remaining" do
// 17:       expect(described_class.remaining(Time.now - 10)).to be 0
// 18:     end
// 19:   end
// 20:
// 21:   describe "#remaining!" do
// 22:     it "returns nil when nil" do
// 23:       expect(described_class.remaining!(nil)).to be_nil
// 24:     end
// 25:
// 26:     it "returns time remaining when there is time remaining" do
// 27:       expect(described_class.remaining!(Time.now + 10)).to be > 1
// 28:     end
// 29:
// 30:     it "returns 0 when there is no time remaining" do
// 31:       expect { described_class.remaining!(Time.now - 10) }.to raise_error(Timeout::Error)
// 32:     end
// 33:   end
// 34: end
