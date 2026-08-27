module artifact

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cask/artifact/moved.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `backup_copy_args(target, source)` at line 14.
pub fn ruby_moved_l14_d1_backup_copy_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backup_copy_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Artifact
// 8:         module Moved
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { ::Cask::Artifact::Moved }
// 12:
// 13:           sig { params(target: ::Pathname, source: ::Pathname).returns(T::Array[T.any(String, ::Pathname)]) }
// 14:           def backup_copy_args(target, source)
// 15:             # GNU `cp --reflink=auto` reduces I/O when the filesystem supports it.
// 16:             ["--reflink=auto", *super]
// 17:           end
// 18:         end
// 19:       end
// 20:     end
// 21:   end
// 22: end
// 23:
// 24: Cask::Artifact::Moved.prepend(OS::Linux::Cask::Artifact::Moved)
