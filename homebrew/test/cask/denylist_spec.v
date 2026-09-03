module cask

import brew_runtime
import homebrew.cask as brew_cask

// Translated from Homebrew/brew `test/cask/denylist_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby matcher `matcher :disallow do |name|` at line 8.
pub fn ruby_denylist_spec_l8_d1_disallow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0
		&& brew_cask.denylist_reason(args[0].as_string()) != none)
}

// Ruby specify `specify(:aggregate_failures) do` at line 14.
pub fn ruby_denylist_spec_l14_d2_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	disallowed := ['adobe-after-effects', 'adobe-illustrator', 'adobe-indesign', 'adobe-photoshop',
		'adobe-premiere', 'pharo']
	return brew_runtime.bool_value(brew_cask.denylist_reason('adobe-air') == none
		&& disallowed.all(brew_cask.denylist_reason(it) != none)
		&& brew_cask.denylist_reason('allowed-cask') == none)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/denylist"
// 5:
// 6: RSpec.describe Cask::Denylist, :cask do
// 7:   describe "::reason" do
// 8:     matcher :disallow do |name|
// 9:       match do |expected|
// 10:         expected.reason(name)
// 11:       end
// 12:     end
// 13:
// 14:     specify(:aggregate_failures) do
// 15:       expect(described_class).not_to disallow("adobe-air")
// 16:       expect(described_class).to disallow("adobe-after-effects")
// 17:       expect(described_class).to disallow("adobe-illustrator")
// 18:       expect(described_class).to disallow("adobe-indesign")
// 19:       expect(described_class).to disallow("adobe-photoshop")
// 20:       expect(described_class).to disallow("adobe-premiere")
// 21:       expect(described_class).to disallow("pharo")
// 22:       expect(described_class).not_to disallow("allowed-cask")
// 23:     end
// 24:   end
// 25: end
