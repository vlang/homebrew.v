module utils

import brew_runtime

// Translated from Homebrew/brew `utils/shebang.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :regex` at line 16.
pub fn ruby_shebang_l16_d1_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby attr_reader `attr_reader :max_length` at line 19.
pub fn ruby_shebang_l19_d2_max_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_length', ...args)
}

// Ruby attr_reader `attr_reader :replacement` at line 22.
pub fn ruby_shebang_l22_d3_replacement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replacement', ...args)
}

// Ruby method `initialize(regex, max_length, replacement)` at line 25.
pub fn ruby_shebang_l25_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `rewrite_shebang(rewrite_info, *paths)` at line 42.
pub fn ruby_shebang_l42_d5_rewrite_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rewrite_shebang', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper functions for manipulating shebang lines.
// 6:   module Shebang
// 7:     extend T::Helpers
// 8:
// 9:     requires_ancestor { Kernel }
// 10:
// 11:     module_function
// 12:
// 13:     # Specification on how to rewrite a given shebang.
// 14:     class RewriteInfo
// 15:       sig { returns(Regexp) }
// 16:       attr_reader :regex
// 17:
// 18:       sig { returns(Integer) }
// 19:       attr_reader :max_length
// 20:
// 21:       sig { returns(T.any(String, Pathname)) }
// 22:       attr_reader :replacement
// 23:
// 24:       sig { params(regex: Regexp, max_length: Integer, replacement: T.any(String, Pathname)).void }
// 25:       def initialize(regex, max_length, replacement)
// 26:         @regex = regex
// 27:         @max_length = max_length
// 28:         @replacement = replacement
// 29:       end
// 30:     end
// 31:
// 32:     # Rewrite shebang for the given `paths` using the given `rewrite_info`.
// 33:     #
// 34:     # ### Example
// 35:     #
// 36:     # ```ruby
// 37:     # rewrite_shebang detected_python_shebang, bin/"script.py"
// 38:     # ```
// 39:     #
// 40:     # @api public
// 41:     sig { params(rewrite_info: RewriteInfo, paths: T.any(String, Pathname)).void }
// 42:     def rewrite_shebang(rewrite_info, *paths)
// 43:       paths.each do |f|
// 44:         f = Pathname(f)
// 45:         next unless f.file?
// 46:         next unless rewrite_info.regex.match?(f.read(rewrite_info.max_length))
// 47:
// 48:         Utils::Inreplace.inreplace f.to_s, rewrite_info.regex, "#!#{rewrite_info.replacement}"
// 49:       end
// 50:     end
// 51:   end
// 52: end
