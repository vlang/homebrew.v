module linux

import brew_runtime

// Translated from Homebrew/brew `os/linux/kernel.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `minimum_version` at line 11.
pub fn ruby_kernel_l11_d1_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minimum_version', ...args)
}

// Ruby method `below_minimum_version?` at line 16.
pub fn ruby_kernel_l16_d2_below_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('below_minimum_version?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for querying Linux kernel information.
// 7:     module Kernel
// 8:       module_function
// 9:
// 10:       sig { returns(Version) }
// 11:       def minimum_version
// 12:         Version.new "3.2"
// 13:       end
// 14:
// 15:       sig { returns(T::Boolean) }
// 16:       def below_minimum_version?
// 17:         OS.kernel_version < minimum_version
// 18:       end
// 19:     end
// 20:   end
// 21: end
