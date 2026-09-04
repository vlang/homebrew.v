module cask

import ruby

// Translated from Homebrew/brew `cask/cache.rb`.

pub fn cask_cache_path(homebrew_cache string) string {
	return ruby.join_path(homebrew_cache, 'Cask')
}
