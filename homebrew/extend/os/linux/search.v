module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/search.rb`.

// ignore_cask translates Linux's cask filtering predicate.
pub fn ignore_cask(supports_linux bool) bool {
	return !supports_linux
}
