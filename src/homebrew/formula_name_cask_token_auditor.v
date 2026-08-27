module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_name_cask_token_auditor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :token` at line 7.
pub fn ruby_formula_name_cask_token_auditor_l7_d1_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('token', ...args)
}

// Ruby method `initialize(token)` at line 10.
pub fn ruby_formula_name_cask_token_auditor_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `errors` at line 15.
pub fn ruby_formula_name_cask_token_auditor_l15_d3_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   class FormulaNameCaskTokenAuditor
// 6:     sig { returns(String) }
// 7:     attr_reader :token
// 8:
// 9:     sig { params(token: String).void }
// 10:     def initialize(token)
// 11:       @token = token
// 12:     end
// 13:
// 14:     sig { returns(T::Array[String]) }
// 15:     def errors
// 16:       errors = []
// 17:
// 18:       errors << "uppercase letters" if token.match?(/[A-Z]/)
// 19:       errors << "whitespace" if token.match?(/\s/)
// 20:       errors << "non-ASCII characters" unless token.ascii_only?
// 21:       errors << "double hyphens" if token.include?("--")
// 22:
// 23:       errors << "a leading @" if token.start_with?("@")
// 24:       errors << "a trailing @" if token.end_with?("@")
// 25:       errors << "a leading hyphen" if token.start_with?("-")
// 26:       errors << "a trailing hyphen" if token.end_with?("-")
// 27:
// 28:       errors << "multiple @ symbols" if token.count("@") > 1
// 29:
// 30:       errors << "a hyphen followed by an @" if token.include? "-@"
// 31:       errors << "an @ followed by a hyphen" if token.include? "@-"
// 32:
// 33:       errors
// 34:     end
// 35:   end
// 36: end
