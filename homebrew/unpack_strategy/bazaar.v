module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `unpack_strategy/bazaar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_extract?(path)` at line 10.
pub fn ruby_bazaar_l10_d1_self_can_extract(path string) bool {
	return bazaar_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 17.
pub fn ruby_bazaar_l17_d2_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	bazaar_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn bazaar_can_extract(path string) bool {
	return directory_can_extract(path) && brew_runtime.is_dir(brew_runtime.join_path(path, '.bzr'))
}

pub fn bazaar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	directory_extract_to_dir(path, unpack_dir, basename, verbose, false)!
	metadata := brew_runtime.join_path(unpack_dir, '.bzr')
	if brew_runtime.is_dir(metadata) { os.rmdir_all(metadata)! }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "directory"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Bazaar archives.
// 8:   class Bazaar < Directory
// 9:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 10:     def self.can_extract?(path)
// 11:       !!(super && (path/".bzr").directory?)
// 12:     end
// 13:
// 14:     private
// 15:
// 16:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 17:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 18:       super
// 19:
// 20:       # The export command doesn't work on checkouts (see https://bugs.launchpad.net/bzr/+bug/897511).
// 21:       FileUtils.rm_r(unpack_dir/".bzr")
// 22:     end
// 23:   end
// 24: end
