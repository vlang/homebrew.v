module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/mercurial.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_extract?(path)` at line 10.
pub fn ruby_mercurial_l10_d1_self_can_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_extract?', ...args)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 17.
pub fn ruby_mercurial_l17_d2_extract_to_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_to_dir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "directory"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Mercurial repositories.
// 8:   class Mercurial < Directory
// 9:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 10:     def self.can_extract?(path)
// 11:       !!(super && (path/".hg").directory?)
// 12:     end
// 13:
// 14:     private
// 15:
// 16:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 17:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 18:       system_command! "hg",
// 19:                       args:    ["--cwd", path, "archive", "--subrepos", "-y", "-t", "files", unpack_dir],
// 20:                       env:     Utils::Path.formula_opt_bin_env("mercurial"),
// 21:                       verbose:
// 22:     end
// 23:   end
// 24: end
