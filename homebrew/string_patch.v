module homebrew

import brew_runtime

// Translated from Homebrew/brew `string_patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(strip, str)` at line 9.
pub fn ruby_string_patch_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `filename = "embedded string patch"` at line 15.
pub fn ruby_string_patch_l15_d2_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filename', ...args)
}

// Ruby method `contents` at line 18.
pub fn ruby_string_patch_l18_d3_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contents', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5:
// 6: # A string containing a patch.
// 7: class StringPatch < EmbeddedPatch
// 8:   sig { params(strip: T.any(String, Symbol), str: String).void }
// 9:   def initialize(strip, str)
// 10:     super(strip)
// 11:     @str = str
// 12:   end
// 13:
// 14:   sig { override.returns(String) }
// 15:   def filename = "embedded string patch"
// 16:
// 17:   sig { override.returns(String) }
// 18:   def contents
// 19:     @str
// 20:   end
// 21: end
