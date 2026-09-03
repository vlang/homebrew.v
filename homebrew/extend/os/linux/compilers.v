module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/compilers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `preferred_gcc` at line 13.
pub fn ruby_compilers_l13_d1_preferred_gcc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(preferred_gcc())
}

pub fn preferred_gcc() string {
	return 'gcc@13'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module CompilerSelector
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { T.class_of(::CompilerSelector) }
// 11:
// 12:         sig { returns(String) }
// 13:         def preferred_gcc
// 14:           OS::LINUX_PREFERRED_GCC_COMPILER_FORMULA
// 15:         end
// 16:       end
// 17:     end
// 18:   end
// 19: end
// 20:
// 21: CompilerSelector.singleton_class.prepend(OS::Linux::CompilerSelector::ClassMethods)
