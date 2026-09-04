module homebrew

import ruby

// Translated from Homebrew/brew `formula_name_cask_token_auditor.rb`.

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

fn formula_name_cask_token_auditor_boundary_value(auditor FormulaNameCaskTokenAuditor) ruby.Value {
	return ruby.structured_value('FormulaNameCaskTokenAuditor', auditor.token, {
		'token': auditor.token
	})
}

fn formula_name_cask_token_auditor_from_boundary(value ruby.Value) FormulaNameCaskTokenAuditor {
	if value.type_name != 'FormulaNameCaskTokenAuditor' {
		panic('expected FormulaNameCaskTokenAuditor, got ${value.type_name}')
	}
	return new_formula_name_cask_token_auditor(value.attribute('token') or { panic(err) })
}
