module utils

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cask/utils/trash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `trash(*paths, command: nil)` at line 14.
pub fn ruby_trash_l14_d1_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trash', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Utils
// 8:         module Trash
// 9:           module ClassMethods
// 10:             sig {
// 11:               params(paths: ::Pathname, command: T.nilable(T.class_of(SystemCommand)))
// 12:                 .returns([T::Array[String], T::Array[String]])
// 13:             }
// 14:             def trash(*paths, command: nil)
// 15:               freedesktop_trash(*paths)
// 16:             end
// 17:           end
// 18:         end
// 19:       end
// 20:     end
// 21:   end
// 22: end
// 23:
// 24: Cask::Utils::Trash.singleton_class.prepend(OS::Linux::Cask::Utils::Trash::ClassMethods)
