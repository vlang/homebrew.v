module cask

import ruby

// Translated from Homebrew/brew `cask/cache.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.path` at line 8.
pub fn ruby_cache_l8_d1_self_path(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby.environment_value('HOMEBREW_CACHE')
	}
	return ruby.object_value('Pathname', cask_cache_path(root))
}

pub fn cask_cache_path(homebrew_cache string) string {
	return ruby.join_path(homebrew_cache, 'Cask')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   # Helper functions for the cask cache.
// 6:   module Cache
// 7:     sig { returns(Pathname) }
// 8:     def self.path
// 9:       @path ||= T.let(HOMEBREW_CACHE/"Cask", T.nilable(Pathname))
// 10:     end
// 11:   end
// 12: end
