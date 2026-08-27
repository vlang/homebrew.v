module language

import brew_runtime

// Translated from Homebrew/brew `language/perl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `perl_shebang_rewrite_info(perl_path)` at line 27.
pub fn ruby_perl_l27_d1_perl_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('perl_shebang_rewrite_info', ...args)
}

// Ruby method `detected_perl_shebang(formula = T.cast(self, Formula))` at line 36.
pub fn ruby_perl_l36_d2_detected_perl_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detected_perl_shebang', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Language
// 7:   # Helper functions for Perl formulae.
// 8:   #
// 9:   # @api public
// 10:   module Perl
// 11:     # Helper module for replacing `perl` shebangs.
// 12:     module Shebang
// 13:       extend T::Helpers
// 14:
// 15:       requires_ancestor { Formula }
// 16:
// 17:       module_function
// 18:
// 19:       # A regex to match potential shebang permutations.
// 20:       PERL_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?perl( |$)}
// 21:
// 22:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 23:       PERL_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env perl ".length, Integer)
// 24:
// 25:       # @private
// 26:       sig { params(perl_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 27:       def perl_shebang_rewrite_info(perl_path)
// 28:         Utils::Shebang::RewriteInfo.new(
// 29:           PERL_SHEBANG_REGEX,
// 30:           PERL_SHEBANG_MAX_LENGTH,
// 31:           "#{perl_path}\\1",
// 32:         )
// 33:       end
// 34:
// 35:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 36:       def detected_perl_shebang(formula = T.cast(self, Formula))
// 37:         perl_deps = formula.declared_deps.select { |dep| dep.required? && dep.name == "perl" }
// 38:         raise ShebangDetectionError.new("Perl", "formula does not depend on Perl") if perl_deps.empty?
// 39:
// 40:         perl_path = if perl_deps.any? { |dep| !dep.uses_from_macos? || !dep.use_macos_install? }
// 41:           Utils::Path.formula_opt_bin("perl")/"perl"
// 42:         else
// 43:           "/usr/bin/perl#{MacOS.preferred_perl_version}"
// 44:         end
// 45:
// 46:         perl_shebang_rewrite_info(perl_path)
// 47:       end
// 48:     end
// 49:   end
// 50: end
