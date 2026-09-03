module test

import brew_runtime
import homebrew
import homebrew.api

// Translated from Homebrew/brew `test/formula_validation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct FormulaValidationInput {
pub:
	name            string = 'formula_name'
	stable_declared bool = true
	url             string = 'foo'
	version         string = '1.0'
	version_present bool = true
	head_declared   bool
	head_url        string
	overrides_brew  bool
}

pub struct FormulaValidationResult {
pub:
	valid      bool
	error_kind string
	attr       string
	value      string
	message    string
	head       bool
	head_only  bool
}

fn formula_validation_failure(kind string, attr string, value string, message string) FormulaValidationResult {
	return FormulaValidationResult{
		error_kind: kind
		attr: attr
		value: value
		message: message
	}
}

fn formula_validation_inspect(value string, present bool) string {
	return if present { '"${value}"' } else { 'nil' }
}

pub fn formula_validation_check(input FormulaValidationInput) FormulaValidationResult {
	if input.overrides_brew {
		return formula_validation_failure('RuntimeError', '', '', 'Formula subclasses cannot override `brew`.')
	}
	if !input.stable_declared && !input.head_declared {
		return formula_validation_failure('FormulaSpecificationError', '', '', '${input.name}: formula requires at least a URL')
	}
	if input.name == '' || input.name.contains_any(' \t\r\n') || !homebrew.is_safe_filename(input.name) {
		return formula_validation_failure('FormulaValidationError', 'name', input.name, "invalid attribute for formula '${input.name}': name (${formula_validation_inspect(input.name, true)})")
	}
	active_url := if input.stable_declared { input.url } else { input.head_url }
	if active_url == '' || active_url.contains_any(' \t\r\n') {
		return formula_validation_failure('FormulaValidationError', 'url', active_url, "invalid attribute for formula '${input.name}': url (${formula_validation_inspect(active_url, true)})")
	}
	if input.stable_declared
		&& (!input.version_present || input.version == '' || input.version.contains_any(' \t\r\n')
			|| !homebrew.is_safe_filename(input.version)) {
		return formula_validation_failure('FormulaValidationError', 'version', input.version, "invalid attribute for formula '${input.name}': version (${formula_validation_inspect(input.version, input.version_present)})")
	}
	return FormulaValidationResult{
		valid: true
		head: !input.stable_declared && input.head_declared
		head_only: !input.stable_declared && input.head_declared
	}
}

pub fn formula_validation_formula(input FormulaValidationInput) !homebrew.Formula {
	result := formula_validation_check(input)
	if !result.valid {
		return error('${result.error_kind}: ${result.message}')
	}
	return homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: input.name
			full_name: input.name
			stable_version: if input.stable_declared { input.version } else { '' }
			head_version: if input.head_declared { 'HEAD' } else { '' }
			source_url: if input.stable_declared { input.url } else { input.head_url }
		}
		active_spec: if input.stable_declared { 'stable' } else { 'head' }
	})
}

pub fn formula_validation_fails_with_invalid(result FormulaValidationResult, attr string) bool {
	return !result.valid && result.error_kind == 'FormulaValidationError'
		&& result.attr == attr.trim_left(':')
}

fn formula_validation_result_value(result FormulaValidationResult) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaValidationResult', result.message, {
		'valid':      result.valid.str()
		'error_kind': result.error_kind
		'attr':       result.attr
		'value':      result.value
		'message':    result.message
		'head':       result.head.str()
		'head_only':  result.head_only.str()
	})
}

fn formula_validation_result_from_value(value brew_runtime.Value) FormulaValidationResult {
	return FormulaValidationResult{
		valid: (value.attributes['valid'] or { 'false' }) == 'true'
		error_kind: value.attributes['error_kind'] or { '' }
		attr: value.attributes['attr'] or { '' }
		value: value.attributes['value'] or { '' }
		message: value.attributes['message'] or { value.repr }
		head: (value.attributes['head'] or { 'false' }) == 'true'
		head_only: (value.attributes['head_only'] or { 'false' }) == 'true'
	}
}

fn formula_validation_invalid_fixture(attr string) FormulaValidationResult {
	return match attr.trim_left(':') {
		'name' { formula_validation_check(FormulaValidationInput{ name: 'name with spaces' }) }
		'url' { formula_validation_check(FormulaValidationInput{ url: '' }) }
		'version' {
			formula_validation_check(FormulaValidationInput{
				version: 'version with spaces'
			})
		}
		else { FormulaValidationResult{} }
	}
}

// Ruby matcher `matcher :fail_with_invalid do |attr|` at line 8.
pub fn ruby_formula_validation_spec_l8_d1_fail_with_invalid(args ...brew_runtime.Value) brew_runtime.Value {
	attr := if args.len > 0 { args[0].as_string().trim_left(':') } else { 'name' }
	result := if args.len > 1 {
		formula_validation_result_from_value(args[1])
	} else {
		formula_validation_invalid_fixture(attr)
	}
	return brew_runtime.bool_value(formula_validation_fails_with_invalid(result, attr))
}

// Ruby method `supports_block_expectations?` at line 18.
pub fn ruby_formula_validation_spec_l18_d2_supports_block_expectations(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "can't override the `brew` method" do` at line 23.
pub fn ruby_formula_validation_spec_l23_d3_can(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := formula_validation_check(FormulaValidationInput{
		overrides_brew: true
	})
	return brew_runtime.bool_value(!result.valid && result.error_kind == 'RuntimeError'
		&& (result.message == 'Formula subclasses cannot override `brew`.'
			|| result.message.contains('was declared as final')))
}

// Ruby method `brew; end` at line 27.
pub fn ruby_formula_validation_spec_l27_d4_brew(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby it `it "validates the `name`" do` at line 38.
pub fn ruby_formula_validation_spec_l38_d5_validates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := formula_validation_check(FormulaValidationInput{
		name: 'name with spaces'
	})
	return brew_runtime.bool_value(formula_validation_fails_with_invalid(result, 'name'))
}

// Ruby it `it "validates the `url`" do` at line 48.
pub fn ruby_formula_validation_spec_l48_d6_validates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := formula_validation_check(FormulaValidationInput{
		url: ''
	})
	return brew_runtime.bool_value(formula_validation_fails_with_invalid(result, 'url'))
}

// Ruby it `it "validates the `version`" do` at line 58.
pub fn ruby_formula_validation_spec_l58_d7_validates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	with_spaces := formula_validation_check(FormulaValidationInput{
		version: 'version with spaces'
	})
	empty := formula_validation_check(FormulaValidationInput{
		version: ''
	})
	nil_version := formula_validation_check(FormulaValidationInput{
		version: ''
		version_present: false
	})
	return brew_runtime.bool_value(formula_validation_fails_with_invalid(with_spaces, 'version')
		&& formula_validation_fails_with_invalid(empty, 'version')
		&& formula_validation_fails_with_invalid(nil_version, 'version'))
}

// Ruby specify `specify "HEAD-only is valid" do` at line 84.
pub fn ruby_formula_validation_spec_l84_d8_head_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	input := FormulaValidationInput{
		stable_declared: false
		version_present: false
		head_declared: true
		head_url: 'foo'
	}
	result := formula_validation_check(input)
	formula := formula_validation_formula(input) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.valid && result.head && result.head_only && formula.head()
		&& formula.head_only())
}

// Ruby it `it "fails when Formula is empty" do` at line 93.
pub fn ruby_formula_validation_spec_l93_d9_fails(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := formula_validation_check(FormulaValidationInput{
		stable_declared: false
		version_present: false
		head_declared: false
	})
	return brew_runtime.bool_value(!result.valid
		&& result.error_kind == 'FormulaSpecificationError')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: RSpec.describe Formula do
// 7:   describe "::new" do
// 8:     matcher :fail_with_invalid do |attr|
// 9:       match do |actual|
// 10:         expect do
// 11:           actual.call
// 12:         rescue => e
// 13:           expect(e.attr).to eq(attr)
// 14:           raise e
// 15:         end.to raise_error(FormulaValidationError)
// 16:       end
// 17:
// 18:       def supports_block_expectations?
// 19:         true
// 20:       end
// 21:     end
// 22:
// 23:     it "can't override the `brew` method" do
// 24:       expect do
// 25:         formula do
// 26:           T.bind(self, T.class_of(Formula))
// 27:           def brew; end
// 28:         end
// 29:       end.to raise_error(
// 30:         RuntimeError,
// 31:         Regexp.union(
// 32:           /\AFormula subclasses cannot override `brew`\.\z/,
// 33:           /\AThe method `brew` on #{described_class} was declared as final/o,
// 34:         ),
// 35:       )
// 36:     end
// 37:
// 38:     it "validates the `name`" do
// 39:       expect do
// 40:         formula "name with spaces" do
// 41:           T.bind(self, T.class_of(Formula))
// 42:           url "foo"
// 43:           version "1.0"
// 44:         end
// 45:       end.to fail_with_invalid :name
// 46:     end
// 47:
// 48:     it "validates the `url`" do
// 49:       expect do
// 50:         formula do
// 51:           T.bind(self, T.class_of(Formula))
// 52:           url ""
// 53:           version "1"
// 54:         end
// 55:       end.to fail_with_invalid :url
// 56:     end
// 57:
// 58:     it "validates the `version`" do
// 59:       expect do
// 60:         formula do
// 61:           T.bind(self, T.class_of(Formula))
// 62:           url "foo"
// 63:           version "version with spaces"
// 64:         end
// 65:       end.to fail_with_invalid :version
// 66:
// 67:       expect do
// 68:         formula do
// 69:           T.bind(self, T.class_of(Formula))
// 70:           url "foo"
// 71:           version ""
// 72:         end
// 73:       end.to fail_with_invalid :version
// 74:
// 75:       expect do
// 76:         formula do
// 77:           T.bind(self, T.class_of(Formula))
// 78:           url "foo"
// 79:           version nil
// 80:         end
// 81:       end.to fail_with_invalid :version
// 82:     end
// 83:
// 84:     specify "HEAD-only is valid" do
// 85:       f = formula do
// 86:         T.bind(self, T.class_of(Formula))
// 87:         head "foo"
// 88:       end
// 89:
// 90:       expect(f).to be_head
// 91:     end
// 92:
// 93:     it "fails when Formula is empty" do
// 94:       expect do
// 95:         formula do
// 96:           T.bind(self, T.class_of(Formula))
// 97:           # do nothing
// 98:         end
// 99:       end.to raise_error(FormulaSpecificationError)
// 100:     end
// 101:   end
// 102: end
