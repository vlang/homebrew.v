module options

import brew_runtime

// Translated from Homebrew/brew `test/options/option_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:option) { described_class.new("foo") }` at line 7.
pub fn ruby_option_spec_l7_d1_option(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option', ...args)
}

// Ruby specify `specify do` at line 9.
pub fn ruby_option_spec_l9_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby specify `specify "equality" do` at line 16.
pub fn ruby_option_spec_l16_d3_equality(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('equality', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "options"
// 5:
// 6: RSpec.describe Option do
// 7:   subject(:option) { described_class.new("foo") }
// 8:
// 9:   specify do
// 10:     expect(option.to_s).to eq("--foo")
// 11:     expect(option.description).to be_empty
// 12:     expect(described_class.new("foo", "foo").description).to eq("foo")
// 13:     expect(option.inspect).to eq("#<Option: \"--foo\">")
// 14:   end
// 15:
// 16:   specify "equality" do
// 17:     foo = described_class.new("foo")
// 18:     bar = described_class.new("bar")
// 19:     expect(option).to eq(foo)
// 20:     expect(option).not_to eq(bar)
// 21:     expect(option).to eql(foo)
// 22:     expect(option).not_to eql(bar)
// 23:   end
// 24: end
