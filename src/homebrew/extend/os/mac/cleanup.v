module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `use_system_ruby?` at line 8.
pub fn ruby_cleanup_l8_d1_use_system_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_system_ruby?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Cleanup
// 7:       sig { returns(T::Boolean) }
// 8:       def use_system_ruby?
// 9:         return false if Homebrew::EnvConfig.force_vendor_ruby?
// 10:
// 11:         ::Homebrew::EnvConfig.developer? && ENV["HOMEBREW_USE_RUBY_FROM_PATH"].present?
// 12:       end
// 13:     end
// 14:   end
// 15: end
// 16:
// 17: Homebrew::Cleanup.prepend(OS::Mac::Cleanup)
