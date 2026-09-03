module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_name_cask_token_auditor.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct FormulaNameCaskTokenAuditor {
pub:
	token string
}

pub fn new_formula_name_cask_token_auditor(token string) FormulaNameCaskTokenAuditor {
	return FormulaNameCaskTokenAuditor{
		token: token
	}
}

// errors preserves the source order so callers can show every naming violation
// in the same deterministic sequence as Homebrew.
pub fn (auditor FormulaNameCaskTokenAuditor) errors() []string {
	mut errors := []string{}
	mut has_uppercase := false
	mut has_whitespace := false
	mut ascii_only := true
	for character in auditor.token.bytes() {
		if character >= `A` && character <= `Z` {
			has_uppercase = true
		}
		if character == 9 || character == 10 || character == 11 || character == 12
			|| character == 13 || character == 32 {
			has_whitespace = true
		}
		if character > 127 {
			ascii_only = false
		}
	}
	if has_uppercase {
		errors << 'uppercase letters'
	}
	if has_whitespace {
		errors << 'whitespace'
	}
	if !ascii_only {
		errors << 'non-ASCII characters'
	}
	if auditor.token.contains('--') {
		errors << 'double hyphens'
	}
	if auditor.token.starts_with('@') {
		errors << 'a leading @'
	}
	if auditor.token.ends_with('@') {
		errors << 'a trailing @'
	}
	if auditor.token.starts_with('-') {
		errors << 'a leading hyphen'
	}
	if auditor.token.ends_with('-') {
		errors << 'a trailing hyphen'
	}
	if auditor.token.count('@') > 1 {
		errors << 'multiple @ symbols'
	}
	if auditor.token.contains('-@') {
		errors << 'a hyphen followed by an @'
	}
	if auditor.token.contains('@-') {
		errors << 'an @ followed by a hyphen'
	}
	return errors
}

fn formula_name_cask_token_auditor_boundary_value(auditor FormulaNameCaskTokenAuditor) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaNameCaskTokenAuditor', auditor.token, {
		'token': auditor.token
	})
}

fn formula_name_cask_token_auditor_from_boundary(value brew_runtime.Value) FormulaNameCaskTokenAuditor {
	if value.type_name != 'FormulaNameCaskTokenAuditor' {
		panic('expected FormulaNameCaskTokenAuditor, got ${value.type_name}')
	}
	return new_formula_name_cask_token_auditor(value.attribute('token') or { panic(err) })
}

// Ruby attr_reader `attr_reader :token` at line 7.
pub fn ruby_formula_name_cask_token_auditor_l7_d1_token(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('FormulaNameCaskTokenAuditor#token requires a receiver')
	}
	return brew_runtime.string_value(formula_name_cask_token_auditor_from_boundary(args[0]).token)
}

// Ruby method `initialize(token)` at line 10.
pub fn ruby_formula_name_cask_token_auditor_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('FormulaNameCaskTokenAuditor#initialize requires a token')
	}
	return formula_name_cask_token_auditor_boundary_value(new_formula_name_cask_token_auditor(args[0].as_string()))
}

// Ruby method `errors` at line 15.
pub fn ruby_formula_name_cask_token_auditor_l15_d3_errors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('FormulaNameCaskTokenAuditor#errors requires a receiver')
	}
	return brew_runtime.string_array_value(formula_name_cask_token_auditor_from_boundary(args[0]).errors())
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
