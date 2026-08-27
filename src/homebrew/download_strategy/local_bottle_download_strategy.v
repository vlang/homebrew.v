module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/local_bottle_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(path)` at line 9.
pub fn ruby_local_bottle_download_strategy_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `clear_cache` at line 15.
pub fn ruby_local_bottle_download_strategy_l15_d2_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_cache', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for extracting local binary packages.
// 5: class LocalBottleDownloadStrategy < AbstractFileDownloadStrategy
// 6:   # TODO: Call `super` here
// 7:   # rubocop:disable Lint/MissingSuper
// 8:   sig { params(path: Pathname).void }
// 9:   def initialize(path)
// 10:     @cached_location = path
// 11:   end
// 12:   # rubocop:enable Lint/MissingSuper
// 13:
// 14:   sig { override.void }
// 15:   def clear_cache
// 16:     # Path is used directly and not cached.
// 17:   end
// 18: end
