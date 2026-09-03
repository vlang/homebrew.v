module requirements

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/requirements/xcode_requirement.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `xcode_installed_version!` at line 8.
pub fn ruby_xcode_requirement_l8_d1_xcode_installed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(xcode_installed_version())
}

pub fn xcode_installed_version() bool {
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5:
// 6: class XcodeRequirement < Requirement
// 7:   sig { returns(T::Boolean) }
// 8:   def xcode_installed_version!
// 9:     true
// 10:   end
// 11: end
