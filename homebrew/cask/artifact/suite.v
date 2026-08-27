module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/suite.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 11.
pub fn ruby_suite_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Ruby method `self.dirmethod` at line 16.
pub fn ruby_suite_l16_d2_self_dirmethod(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dirmethod', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `suite` stanza.
// 9:     class Suite < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "App Suite"
// 13:       end
// 14:
// 15:       sig { override.returns(Symbol) }
// 16:       def self.dirmethod
// 17:         :appdir
// 18:       end
// 19:     end
// 20:   end
// 21: end
