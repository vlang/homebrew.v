module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/git.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_extract?(path)` at line 10.
pub fn ruby_git_l10_d1_self_can_extract(path string) bool {
	return git_can_extract(path)
}

pub fn git_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.git'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "directory"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Git repositories.
// 8:   class Git < Directory
// 9:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 10:     def self.can_extract?(path)
// 11:       !!(super && (path/".git").directory?)
// 12:     end
// 13:   end
// 14: end
