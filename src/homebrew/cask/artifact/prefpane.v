module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/prefpane.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 11.
pub fn ruby_prefpane_l11_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `prefpane` stanza.
// 9:     class Prefpane < Moved
// 10:       sig { override.returns(String) }
// 11:       def self.english_name
// 12:         "Preference Pane"
// 13:       end
// 14:     end
// 15:   end
// 16: end
