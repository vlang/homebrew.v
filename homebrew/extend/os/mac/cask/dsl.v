module cask

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/dsl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `os_version` at line 15.
pub fn ruby_dsl_l15_d1_os_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module DSL
// 10:         extend T::Helpers
// 11:
// 12:         requires_ancestor { ::Cask::DSL }
// 13:
// 14:         sig { returns(T.nilable(MacOSVersion)) }
// 15:         def os_version
// 16:           MacOS.full_version
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
// 22:
// 23: Cask::DSL.prepend(OS::Mac::Cask::DSL)
