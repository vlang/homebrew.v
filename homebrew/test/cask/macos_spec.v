module cask

import brew_runtime
import homebrew.cask as hb_cask
import os

// Translated from Homebrew/brew `test/cask/macos_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify do` at line 5.
pub fn ruby_macos_spec_l5_d1_do(args ...brew_runtime.Value) brew_runtime.Value {
	home := os.home_dir()
	undeletable := [
		'/',
		'/.',
		'/usr/local/Library/Taps/../../../..',
		'/Applications',
		'/Applications/',
		'/Applications/.',
		'/Applications/Mail.app/..',
		home,
		'${home}/',
		'${home}/Documents/..',
		'${home}/Library',
		'${home}/Library/',
		'${home}/Library/.',
		'${home}/Library/Preferences/..',
	]
	return brew_runtime.bool_value(undeletable.all(hb_cask.macos_undeletable(it)) && !hb_cask.macos_undeletable('/Applications/.app') && !hb_cask.macos_undeletable('/Applications/SnakeOil Professional.app'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe MacOS, :cask do
// 5:   specify do
// 6:     expect(described_class).to be_undeletable(
// 7:       "/",
// 8:     )
// 9:     expect(described_class).to be_undeletable(
// 10:       "/.",
// 11:     )
// 12:     expect(described_class).to be_undeletable(
// 13:       "/usr/local/Library/Taps/../../../..",
// 14:     )
// 15:     expect(described_class).to be_undeletable(
// 16:       "/Applications",
// 17:     )
// 18:     expect(described_class).to be_undeletable(
// 19:       "/Applications/",
// 20:     )
// 21:     expect(described_class).to be_undeletable(
// 22:       "/Applications/.",
// 23:     )
// 24:     expect(described_class).to be_undeletable(
// 25:       "/Applications/Mail.app/..",
// 26:     )
// 27:     expect(described_class).to be_undeletable(
// 28:       Dir.home,
// 29:     )
// 30:     expect(described_class).to be_undeletable(
// 31:       "#{Dir.home}/",
// 32:     )
// 33:     expect(described_class).to be_undeletable(
// 34:       "#{Dir.home}/Documents/..",
// 35:     )
// 36:     expect(described_class).to be_undeletable(
// 37:       "#{Dir.home}/Library",
// 38:     )
// 39:     expect(described_class).to be_undeletable(
// 40:       "#{Dir.home}/Library/",
// 41:     )
// 42:     expect(described_class).to be_undeletable(
// 43:       "#{Dir.home}/Library/.",
// 44:     )
// 45:     expect(described_class).to be_undeletable(
// 46:       "#{Dir.home}/Library/Preferences/..",
// 47:     )
// 48:     expect(described_class).not_to be_undeletable(
// 49:       "/Applications/.app",
// 50:     )
// 51:     expect(described_class).not_to be_undeletable(
// 52:       "/Applications/SnakeOil Professional.app",
// 53:     )
// 54:   end
// 55: end
