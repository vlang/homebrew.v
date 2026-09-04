module utils

import ruby
import os

#include <pwd.h>

struct C.passwd {
	pw_dir &char
}

fn C.getpwuid(uid u32) &C.passwd

// Translated from Homebrew/brew `utils/uid.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.uid_home` at line 7.
pub fn ruby_uid_l7_d1_self_uid_home(args ...ruby.Value) ruby.Value {
	return if directory := uid_home() {
		ruby.string_value(directory)
	} else {
		ruby.object_value('Nil', '')
	}
}

// uid_home reads the passwd entry for the process UID, matching Etc.getpwuid
// rather than trusting a potentially overridden HOME environment variable.
pub fn uid_home() ?string {
	$if windows {
		return none
	} $else {
		entry := C.getpwuid(u32(os.getuid()))
		if isnil(entry) || isnil(entry.pw_dir) {
			return none
		}
		return unsafe { cstring_to_vstring(entry.pw_dir) }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   module UID
// 6:     sig { returns(T.nilable(String)) }
// 7:     def self.uid_home
// 8:       require "etc"
// 9:       Etc.getpwuid(Process.uid)&.dir
// 10:     rescue ArgumentError
// 11:       # Cover for misconfigured NSS setups
// 12:       nil
// 13:     end
// 14:   end
// 15: end
