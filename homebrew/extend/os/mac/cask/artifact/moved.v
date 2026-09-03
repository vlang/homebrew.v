module artifact

import brew_runtime
import homebrew.cask as cask_macos
import homebrew.cask.artifact as base_artifact

pub fn mac_moved_undeletable(target string) bool {
	return cask_macos.macos_undeletable(target)
}

pub fn mac_moved_backup_copy_args(target string, source string, macos_major int,
	target_device u64, source_parent_device u64) []string {
	base := base_artifact.moved_backup_copy_args(target, source)
	if macos_major < 14 || target_device != source_parent_device {
		return base
	}
	mut arguments := ['-c']
	arguments << base
	return arguments
}

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/moved.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `undeletable?(target)` at line 16.
pub fn ruby_moved_l16_d1_undeletable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('undeletable? requires a target') }
	return brew_runtime.bool_value(mac_moved_undeletable(args[0].as_string()))
}

// Ruby method `backup_copy_args(target, source)` at line 21.
pub fn ruby_moved_l21_d2_backup_copy_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('backup_copy_args requires target and source') }
	major := if args.len > 2 { int(args[2].as_int() or { panic(err) }) } else { 14 }
	target_device := if args.len > 3 { u64(args[3].as_int() or { panic(err) }) } else { u64(1) }
	source_device := if args.len > 4 {
		u64(args[4].as_int() or { panic(err) })
	} else {
		target_device
	}
	return brew_runtime.string_array_value(mac_moved_backup_copy_args(args[0].as_string(), args[1].as_string(), major, target_device, source_device))
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
