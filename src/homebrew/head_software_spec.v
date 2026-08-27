module homebrew

import brew_runtime

// Translated from Homebrew/brew `head_software_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(flags: [])` at line 8.
pub fn ruby_head_software_spec_l8_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `verify_download_integrity(_filename)` at line 14.
pub fn ruby_head_software_spec_l14_d2_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_download_integrity', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "software_spec"
// 5:
// 6: class HeadSoftwareSpec < SoftwareSpec
// 7:   sig { params(flags: T::Array[String]).void }
// 8:   def initialize(flags: [])
// 9:     super
// 10:     @resource.version(Version.new("HEAD"))
// 11:   end
// 12:
// 13:   sig { params(_filename: Pathname).returns(NilClass) }
// 14:   def verify_download_integrity(_filename)
// 15:     # no-op
// 16:   end
// 17: end
