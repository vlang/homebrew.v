module cask

import ruby

// Translated from Homebrew/brew `extend/os/linux/cask/quarantine.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `available? = false` at line 14.
pub fn ruby_quarantine_l14_d1_available(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(quarantine_available())
}

pub fn quarantine_available() bool {
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cask
// 7:       module Quarantine
// 8:         module ClassMethods
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { ::Cask::Quarantine }
// 12:
// 13:           sig { returns(T::Boolean) }
// 14:           def available? = false
// 15:         end
// 16:       end
// 17:     end
// 18:   end
// 19: end
// 20:
// 21: Cask::Quarantine.singleton_class.prepend(OS::Linux::Cask::Quarantine::ClassMethods)
