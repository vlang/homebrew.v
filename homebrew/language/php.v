module language

import brew_runtime

// Translated from Homebrew/brew `language/php.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `php_shebang_rewrite_info(php_path)` at line 27.
pub fn ruby_php_l27_d1_php_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('php_shebang_rewrite_info', ...args)
}

// Ruby method `detected_php_shebang(formula = T.cast(self, Formula))` at line 36.
pub fn ruby_php_l36_d2_detected_php_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detected_php_shebang', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Language
// 7:   # Helper functions for PHP formulae.
// 8:   #
// 9:   # @api public
// 10:   module PHP
// 11:     # Helper module for replacing `php` shebangs.
// 12:     module Shebang
// 13:       extend T::Helpers
// 14:
// 15:       requires_ancestor { Formula }
// 16:
// 17:       module_function
// 18:
// 19:       # A regex to match potential shebang permutations.
// 20:       PHP_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?php( |$)}
// 21:
// 22:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 23:       PHP_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env php ".length, Integer)
// 24:
// 25:       # @private
// 26:       sig { params(php_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 27:       def php_shebang_rewrite_info(php_path)
// 28:         Utils::Shebang::RewriteInfo.new(
// 29:           PHP_SHEBANG_REGEX,
// 30:           PHP_SHEBANG_MAX_LENGTH,
// 31:           "#{php_path}\\1",
// 32:         )
// 33:       end
// 34:
// 35:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 36:       def detected_php_shebang(formula = T.cast(self, Formula))
// 37:         php_deps = formula.deps.select(&:required?).map(&:name).grep(/^php(@.+)?$/)
// 38:         raise ShebangDetectionError.new("PHP", "formula does not depend on PHP") if php_deps.empty?
// 39:         raise ShebangDetectionError.new("PHP", "formula has multiple PHP dependencies") if php_deps.length > 1
// 40:
// 41:         php_shebang_rewrite_info(Utils::Path.formula_opt_bin(php_deps.first)/"php")
// 42:       end
// 43:     end
// 44:   end
// 45: end
