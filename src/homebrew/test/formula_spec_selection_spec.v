module test

import brew_runtime

// Translated from Homebrew/brew `test/formula_spec_selection_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "selects stable by default" do` at line 8.
pub fn ruby_formula_spec_selection_spec_l8_d1_selects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selects', ...args)
}

// Ruby it `it "selects stable when exclusive" do` at line 18.
pub fn ruby_formula_spec_selection_spec_l18_d2_selects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selects', ...args)
}

// Ruby it `it "selects HEAD when exclusive" do` at line 26.
pub fn ruby_formula_spec_selection_spec_l26_d3_selects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selects', ...args)
}

// Ruby it `it "does not select an incomplete spec" do` at line 34.
pub fn ruby_formula_spec_selection_spec_l34_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not set an incomplete stable spec" do` at line 45.
pub fn ruby_formula_spec_selection_spec_l45_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "selects HEAD when requested" do` at line 56.
pub fn ruby_formula_spec_selection_spec_l56_d6_selects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selects', ...args)
}

// Ruby it `it "does not raise an error for a missing spec" do` at line 66.
pub fn ruby_formula_spec_selection_spec_l66_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: RSpec.describe Formula do
// 7:   describe "::new" do
// 8:     it "selects stable by default" do
// 9:       f = formula do
// 10:         T.bind(self, T.class_of(Formula))
// 11:         url "foo-1.0"
// 12:         head "foo"
// 13:       end
// 14:
// 15:       expect(f).to be_stable
// 16:     end
// 17:
// 18:     it "selects stable when exclusive" do
// 19:       f = formula do
// 20:         T.bind(self, T.class_of(Formula))
// 21:         url "foo-1.0"
// 22:       end
// 23:       expect(f).to be_stable
// 24:     end
// 25:
// 26:     it "selects HEAD when exclusive" do
// 27:       f = formula do
// 28:         T.bind(self, T.class_of(Formula))
// 29:         head "foo"
// 30:       end
// 31:       expect(f).to be_head
// 32:     end
// 33:
// 34:     it "does not select an incomplete spec" do
// 35:       f = formula do
// 36:         T.bind(self, T.class_of(Formula))
// 37:         sha256 TEST_SHA256
// 38:         version "1.0"
// 39:         head "foo"
// 40:       end
// 41:
// 42:       expect(f).to be_head
// 43:     end
// 44:
// 45:     it "does not set an incomplete stable spec" do
// 46:       f = formula do
// 47:         T.bind(self, T.class_of(Formula))
// 48:         sha256 TEST_SHA256
// 49:         head "foo"
// 50:       end
// 51:
// 52:       expect(f.stable).to be_nil
// 53:       expect(f).to be_head
// 54:     end
// 55:
// 56:     it "selects HEAD when requested" do
// 57:       f = formula("test", spec: :head) do
// 58:         T.bind(self, T.class_of(Formula))
// 59:         url "foo-1.0"
// 60:         head "foo"
// 61:       end
// 62:
// 63:       expect(f).to be_head
// 64:     end
// 65:
// 66:     it "does not raise an error for a missing spec" do
// 67:       f = formula("test", spec: :head) do
// 68:         T.bind(self, T.class_of(Formula))
// 69:         url "foo-1.0"
// 70:       end
// 71:
// 72:       expect(f).to be_stable
// 73:     end
// 74:   end
// 75: end
