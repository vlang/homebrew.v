module ffi

import ruby
import os

pub fn foundation_trash_item(path string, trash_directory string) !string {
	if !os.exists(path) {
		return ''
	}
	os.mkdir_all(trash_directory)!
	base := os.base(path)
	mut destination := os.join_path(trash_directory, base)
	mut suffix := 1
	for os.exists(destination) {
		destination = os.join_path(trash_directory, '${base}.${suffix}')
		suffix++
	}
	os.mv(path, destination)!
	return destination
}

pub fn foundation_trash_paths(paths []string, trash_directory string) ([]string, []string) {
	mut trashed := []string{}
	mut untrashable := []string{}
	for path in paths {
		result := foundation_trash_item(path, trash_directory) or {
			untrashable << path
			continue
		}
		if result != '' { trashed << result } else { untrashable << path }
	}
	return trashed, untrashable
}

// Translated from Homebrew/brew `os/mac/ffi/foundation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.trash_item(path)` at line 12.
pub fn ruby_foundation_l12_d1_self_trash_item(args ...ruby.Value) ruby.Value {
	trash_directory := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path(os.home_dir(), '.Trash')
	}
	result := foundation_trash_item(args[0].as_string(), trash_directory) or {
		return ruby.object_value('NilClass', 'nil')
	}
	if result == '' {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(result)
}

// Ruby method `self.trash_paths(paths)` at line 49.
pub fn ruby_foundation_l49_d2_self_trash_paths(args ...ruby.Value) ruby.Value {
	paths := args[0].as_array() or { [] }.map(it.as_string())
	trash_directory := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path(os.home_dir(), '.Trash')
	}
	trashed, untrashable := foundation_trash_paths(paths, trash_directory)
	return ruby.array_value([
		ruby.string_array_value(trashed),
		ruby.string_array_value(untrashable),
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/core_foundation"
// 5: require "os/mac/ffi/objective_c"
// 6:
// 7: module OS
// 8:   module Mac
// 9:     module FFI
// 10:       module Foundation
// 11:         sig { params(path: String).returns(T.nilable(String)) }
// 12:         def self.trash_item(path)
// 13:           result_url = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
// 14:           error = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
// 15:           result_url[0, Fiddle::SIZEOF_VOIDP] = [0].pack("J")
// 16:           error[0, Fiddle::SIZEOF_VOIDP] = [0].pack("J")
// 17:
// 18:           success = ObjectiveC.message_send(
// 19:             ObjectiveC.message_send(
// 20:               ObjectiveC.class_get("NSFileManager"),
// 21:               "defaultManager",
// 22:               [],
// 23:               Fiddle::TYPE_VOIDP,
// 24:             ),
// 25:             "trashItemAtURL:resultingItemURL:error:",
// 26:             [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
// 27:             Fiddle::TYPE_BOOL,
// 28:             ObjectiveC.message_send(
// 29:               ObjectiveC.class_get("NSURL"),
// 30:               "fileURLWithPath:",
// 31:               [Fiddle::TYPE_VOIDP],
// 32:               Fiddle::TYPE_VOIDP,
// 33:               CoreFoundation.string_create(path),
// 34:             ),
// 35:             result_url,
// 36:             error,
// 37:           )
// 38:           return unless success
// 39:
// 40:           ObjectiveC.message_send(
// 41:             ObjectiveC.message_send(result_url.ptr, "path", [], Fiddle::TYPE_VOIDP),
// 42:             "UTF8String",
// 43:             [],
// 44:             Fiddle::TYPE_VOIDP,
// 45:           ).to_s
// 46:         end
// 47:
// 48:         sig { params(paths: T::Array[String]).returns([T::Array[String], T::Array[String]]) }
// 49:         def self.trash_paths(paths)
// 50:           trashed = T.let([], T::Array[String])
// 51:           untrashable = T.let([], T::Array[String])
// 52:
// 53:           paths.each do |path|
// 54:             trashed_path = trash_item(path)
// 55:             if trashed_path
// 56:               trashed << trashed_path
// 57:             else
// 58:               untrashable << path
// 59:             end
// 60:           rescue
// 61:             untrashable << path
// 62:           end
// 63:
// 64:           [trashed, untrashable]
// 65:         end
// 66:       end
// 67:     end
// 68:   end
// 69: end
