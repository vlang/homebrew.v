module homebrew

import brew_runtime

// Translated from Homebrew/brew `unlink.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.unlink_link_overwrite_formulae(formula, verbose: false)` at line 8.
pub fn ruby_unlink_l8_d1_self_unlink_link_overwrite_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unlink_link_overwrite_formulae', ...args)
}

// Ruby method `self.unlink(keg, dry_run: false, verbose: false)` at line 20.
pub fn ruby_unlink_l20_d2_self_unlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unlink', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # Provides helper methods for unlinking formulae and kegs with consistent output.
// 6:   module Unlink
// 7:     sig { params(formula: Formula, verbose: T::Boolean).void }
// 8:     def self.unlink_link_overwrite_formulae(formula, verbose: false)
// 9:       overwrite_formulae = formula.link_overwrite_formulae.select(&:linked?)
// 10:       overwrite_formulae.select!(&:keg_only?) unless formula.keg_only?
// 11:
// 12:       overwrite_formulae.filter_map(&:any_installed_keg)
// 13:                         .select(&:directory?)
// 14:                         .each do |keg|
// 15:         unlink(keg, verbose:)
// 16:       end
// 17:     end
// 18:
// 19:     sig { params(keg: Keg, dry_run: T::Boolean, verbose: T::Boolean).void }
// 20:     def self.unlink(keg, dry_run: false, verbose: false)
// 21:       options = { dry_run:, verbose: }
// 22:
// 23:       keg.lock do
// 24:         print "Unlinking #{keg}... "
// 25:         puts if verbose
// 26:         puts "#{keg.unlink(**options)} symlinks removed."
// 27:       end
// 28:     end
// 29:   end
// 30: end
