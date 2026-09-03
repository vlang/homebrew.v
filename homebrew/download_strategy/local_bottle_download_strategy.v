module download_strategy

// Translated from Homebrew/brew `download_strategy/local_bottle_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(path)` at line 9.
pub fn ruby_local_bottle_download_strategy_l9_d1_initialize(path string) LocalBottleDownloadStrategy {
	return new_local_bottle_download_strategy(path)
}

// Ruby method `clear_cache` at line 15.
pub fn ruby_local_bottle_download_strategy_l15_d2_clear_cache(strategy &LocalBottleDownloadStrategy) {
	strategy.clear_cache()
}

pub struct LocalBottleDownloadStrategy {
pub mut:
	file AbstractFileDownloadStrategy
}

pub fn new_local_bottle_download_strategy(path string) LocalBottleDownloadStrategy {
	mut file := new_abstract_file_download_strategy('', '', '', DownloadMeta{})
	file.cached_location_value = path
	return LocalBottleDownloadStrategy{
		file: file
	}
}

pub fn (strategy &LocalBottleDownloadStrategy) cached_location() string {
	return strategy.file.cached_location_value
}

// A local bottle path is consumed directly and must never be removed by cache
// cleanup.
pub fn (strategy &LocalBottleDownloadStrategy) clear_cache() {
	_ = strategy
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
