module requirements

import brew_runtime

// Translated from Homebrew/brew `requirements/linux_requirement.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `display_s` at line 13.
pub fn ruby_linux_requirement_l13_d1_display_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('display_s', ...args)
}

// Ruby method `message` at line 18.
pub fn ruby_linux_requirement_l18_d2_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('message', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A requirement on Linux.
// 5: class LinuxRequirement < Requirement
// 6:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 7:
// 8:   fatal true
// 9:
// 10:   satisfy(build_env: false) { OS.linux? }
// 11:
// 12:   sig { returns(String) }
// 13:   def display_s
// 14:     "Linux"
// 15:   end
// 16:
// 17:   sig { returns(String) }
// 18:   def message
// 19:     "Linux is required for this software."
// 20:   end
// 21: end
