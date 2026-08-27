module test

import brew_runtime

// Translated from Homebrew/brew `test/formula_validation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby matcher `matcher :fail_with_invalid do |attr|` at line 8.
pub fn ruby_formula_validation_spec_l8_d1_fail_with_invalid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fail_with_invalid', ...args)
}

// Ruby method `supports_block_expectations?` at line 18.
pub fn ruby_formula_validation_spec_l18_d2_supports_block_expectations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports_block_expectations?', ...args)
}

// Ruby it `it "can't override the `brew` method" do` at line 23.
pub fn ruby_formula_validation_spec_l23_d3_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby method `brew; end` at line 27.
pub fn ruby_formula_validation_spec_l27_d4_brew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew', ...args)
}

// Ruby it `it "validates the `name`" do` at line 38.
pub fn ruby_formula_validation_spec_l38_d5_validates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validates', ...args)
}

// Ruby it `it "validates the `url`" do` at line 48.
pub fn ruby_formula_validation_spec_l48_d6_validates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validates', ...args)
}

// Ruby it `it "validates the `version`" do` at line 58.
pub fn ruby_formula_validation_spec_l58_d7_validates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validates', ...args)
}

// Ruby specify `specify "HEAD-only is valid" do` at line 84.
pub fn ruby_formula_validation_spec_l84_d8_head_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('HEAD-only', ...args)
}

// Ruby it `it "fails when Formula is empty" do` at line 93.
pub fn ruby_formula_validation_spec_l93_d9_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
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
