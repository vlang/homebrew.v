module utils

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/utils/trash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `trash(*paths, command: nil)` at line 16.
pub fn ruby_trash_l16_d1_trash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trash', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Utils
// 10:         module Trash
// 11:           module ClassMethods
// 12:             sig {
// 13:               params(paths: ::Pathname, command: T.nilable(T.class_of(::SystemCommand)))
// 14:                 .returns([T::Array[String], T::Array[String]])
// 15:             }
// 16:             def trash(*paths, command: nil)
// 17:               trashed, untrashable = MacOS::FFI::Foundation.trash_paths(paths.map(&:to_s))
// 18:
// 19:               trashed_with_permissions = T.let([], T::Array[String])
// 20:               still_untrashable = T.let([], T::Array[String])
// 21:               untrashable.each do |path|
// 22:                 destination = T.let(nil, T.nilable(String))
// 23:                 ::Cask::Utils.gain_permissions(::Pathname.new(path), ["-R"], ::SystemCommand) do
// 24:                   destination = MacOS::FFI::Foundation.trash_item(path)
// 25:                   Kernel.raise if destination.nil?
// 26:                 end
// 27:
// 28:                 if destination.nil?
// 29:                   still_untrashable << path
// 30:                 else
// 31:                   trashed_with_permissions << destination
// 32:                 end
// 33:               rescue
// 34:                 still_untrashable << path
// 35:               end
// 36:
// 37:               [trashed + trashed_with_permissions, still_untrashable]
// 38:             end
// 39:           end
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
// 45:
// 46: Cask::Utils::Trash.singleton_class.prepend(OS::Mac::Cask::Utils::Trash::ClassMethods)
