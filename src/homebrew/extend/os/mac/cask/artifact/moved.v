module artifact

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/moved.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `undeletable?(target)` at line 16.
pub fn ruby_moved_l16_d1_undeletable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('undeletable?', ...args)
}

// Ruby method `backup_copy_args(target, source)` at line 21.
pub fn ruby_moved_l21_d2_backup_copy_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backup_copy_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Artifact
// 10:         module Moved
// 11:           extend T::Helpers
// 12:
// 13:           requires_ancestor { ::Cask::Artifact::Moved }
// 14:
// 15:           sig { params(target: ::Pathname).returns(T::Boolean) }
// 16:           def undeletable?(target)
// 17:             MacOS.undeletable?(target)
// 18:           end
// 19:
// 20:           sig { params(target: ::Pathname, source: ::Pathname).returns(T::Array[T.any(String, ::Pathname)]) }
// 21:           def backup_copy_args(target, source)
// 22:             args = super
// 23:
// 24:             return args if MacOS.version < :sonoma
// 25:             return args if target.stat.dev != source.dirname.stat.dev
// 26:
// 27:             ["-c", *args]
// 28:           end
// 29:         end
// 30:       end
// 31:     end
// 32:   end
// 33: end
// 34:
// 35: Cask::Artifact::Moved.prepend(OS::Mac::Cask::Artifact::Moved)
