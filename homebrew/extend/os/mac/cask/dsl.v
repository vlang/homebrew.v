module cask

import brew_runtime

pub fn mac_cask_dsl_os_version(full_version string) ?string {
	if full_version == '' {
		return none
	}
	return full_version
}

// Translated from Homebrew/brew `extend/os/mac/cask/dsl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `os_version` at line 15.
pub fn ruby_dsl_l15_d1_os_version(args ...brew_runtime.Value) brew_runtime.Value {
	full_version := if args.len > 0 { args[0].as_string() } else { '' }
	version := mac_cask_dsl_os_version(full_version) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.structured_value('MacOSVersion', version, {
		'version': version
	})
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
