module utils

import brew_runtime

// Translated from Homebrew/brew `utils/linkage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.binary_linked_to_library?(binary, library)` at line 9.
pub fn ruby_linkage_l9_d1_self_binary_linked_to_library(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.binary_linked_to_library?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # @api internal
// 6:   sig {
// 7:     params(binary: T.any(String, Pathname), library: T.any(String, Pathname)).returns(T::Boolean)
// 8:   }
// 9:   def self.binary_linked_to_library?(binary, library)
// 10:     library = library.to_s
// 11:     library = File.realpath(library) if library.start_with?(HOMEBREW_PREFIX.to_s)
// 12:
// 13:     binary_path = BinaryPathname.wrap(binary)
// 14:     binary_path.dynamically_linked_libraries.any? do |dll|
// 15:       dll = File.realpath(dll) if dll.start_with?(HOMEBREW_PREFIX.to_s)
// 16:       dll == library
// 17:     end
// 18:   end
// 19: end
