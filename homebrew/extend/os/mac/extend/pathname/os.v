module pathname

import ruby

// Translated from Homebrew/brew `extend/os/mac/extend/pathname/os.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `activate_extensions!` at line 13.
pub fn ruby_os_l13_d1_activate_extensions(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(active_pathname_extensions())
}

pub fn active_pathname_extensions() []string {
	return ['WriteMkpathExtension', 'MachOShim']
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Pathname
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { T.class_of(::Pathname) }
// 11:
// 12:         sig { void }
// 13:         def activate_extensions!
// 14:           super
// 15:
// 16:           prepend(MachOShim)
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
