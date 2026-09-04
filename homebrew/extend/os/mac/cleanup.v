module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `use_system_ruby?` at line 8.
pub fn ruby_cleanup_l8_d1_use_system_ruby(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(use_system_ruby(args[0].as_bool() or { false }, args[1].as_bool() or {
		false
	}, args[2].as_bool() or { false }))
}

pub fn use_system_ruby(force_vendor_ruby bool, developer bool, ruby_from_path_present bool) bool {
	return !force_vendor_ruby && developer && ruby_from_path_present
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
