module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/cleaner.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `executable_path?(path)` at line 10.
pub fn ruby_cleaner_l10_d1_executable_path(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len >= 2 && executable_path(args[0].as_bool() or { false }, args[1].as_bool() or {
		false
	}))
}

pub fn executable_path(text_executable bool, mach_o_executable bool) bool {
	return text_executable || mach_o_executable
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Cleaner
// 7:       private
// 8:
// 9:       sig { params(path: ::Pathname).returns(T::Boolean) }
// 10:       def executable_path?(path)
// 11:         return true if path.text_executable?
// 12:
// 13:         path = MachOPathname.wrap(path)
// 14:         path.mach_o_executable?
// 15:       end
// 16:     end
// 17:   end
// 18: end
// 19:
// 20: Cleaner.prepend(OS::Mac::Cleaner)
