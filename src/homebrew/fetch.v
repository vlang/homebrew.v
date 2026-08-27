module homebrew

import brew_runtime

// Translated from Homebrew/brew `fetch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fetch_bottle?(formula, force_bottle:, bottle_tag:, build_from_source_formulae:, os:, arch:)` at line 16.
pub fn ruby_fetch_l16_d1_fetch_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch_bottle?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Fetch
// 6:     sig {
// 7:       params(
// 8:         formula:                    Formula,
// 9:         force_bottle:               T::Boolean,
// 10:         bottle_tag:                 T.nilable(Symbol),
// 11:         build_from_source_formulae: T::Array[String],
// 12:         os:                         T.nilable(Symbol),
// 13:         arch:                       T.nilable(Symbol),
// 14:       ).returns(T::Boolean)
// 15:     }
// 16:     def fetch_bottle?(formula, force_bottle:, bottle_tag:, build_from_source_formulae:, os:, arch:)
// 17:       bottle = formula.bottle
// 18:
// 19:       return true if force_bottle && bottle.present?
// 20:       if os.present?
// 21:         return true
// 22:       elsif ENV["HOMEBREW_TEST_GENERIC_OS"].present?
// 23:         # `:generic` bottles don't exist and `--os` flag is not specified.
// 24:         return false
// 25:       end
// 26:       return true if arch.present?
// 27:       return true if bottle_tag.present? && formula.bottled?(bottle_tag)
// 28:
// 29:       bottle.present? &&
// 30:         formula.pour_bottle? &&
// 31:         build_from_source_formulae.exclude?(formula.full_name) &&
// 32:         bottle.compatible_locations?
// 33:     end
// 34:   end
// 35: end
