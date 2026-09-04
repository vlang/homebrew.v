module utils

import ruby
import homebrew.cask.utils as base_trash
import homebrew.os.mac.ffi
import os

pub type MacTrashRetry = fn(string) !string

pub fn mac_trash_paths(paths []string, trash_directory string,
	retry MacTrashRetry) base_trash.TrashResult {
	trashed, untrashable := ffi.foundation_trash_paths(paths, trash_directory)
	mut retried := []string{}
	mut still_untrashable := []string{}
	for path in untrashable {
		destination := retry(path) or {
			still_untrashable << path
			continue
		}
		if destination == '' {
			still_untrashable << path
		} else {
			retried << destination
		}
	}
	mut all_trashed := trashed.clone()
	all_trashed << retried
	return base_trash.TrashResult{ trashed: all_trashed, untrashable: still_untrashable }
}

fn mac_trash_fixture_retry(path string) !string {
	trash_directory := os.join_path(os.home_dir(), '.Trash')
	return ffi.foundation_trash_item(path, trash_directory)
}

// Translated from Homebrew/brew `extend/os/mac/cask/utils/trash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `trash(*paths, command: nil)` at line 16.
pub fn ruby_trash_l16_d1_trash(args ...ruby.Value) ruby.Value {
	paths := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_array() or { []ruby.Value{} }.map(it.as_string())
	} else {
		args.filter(it.type_name in ['String', 'Pathname']).map(it.as_string())
	}
	trash_directory := if args.len > 1 && args[1].type_name == 'String' {
		args[1].as_string()
	} else {
		os.join_path(os.home_dir(), '.Trash')
	}
	return base_trash.trash_result_value(mac_trash_paths(paths, trash_directory, mac_trash_fixture_retry))
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
