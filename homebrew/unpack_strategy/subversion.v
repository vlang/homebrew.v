module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/subversion.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_extract?(path)` at line 10.
pub fn ruby_subversion_l10_d1_self_can_extract(path string) bool {
	return subversion_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 17.
pub fn ruby_subversion_l17_d2_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	subversion_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn subversion_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.svn'))
}

pub fn subversion_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	checked_command_in_directory(command_path('svn')!, ['export', '--force', '.', unpack_dir], path)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "directory"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Subversion repositories.
// 8:   class Subversion < Directory
// 9:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 10:     def self.can_extract?(path)
// 11:       !!(super && (path/".svn").directory?)
// 12:     end
// 13:
// 14:     private
// 15:
// 16:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 17:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 18:       system_command! "svn",
// 19:                       args:    ["export", "--force", ".", unpack_dir],
// 20:                       chdir:   path.to_s,
// 21:                       verbose:
// 22:     end
// 23:   end
// 24: end
