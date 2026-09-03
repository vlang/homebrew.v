module options

import brew_runtime
import homebrew.options as option_types

// Translated from Homebrew/brew `test/options/option_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:option) { described_class.new("foo") }` at line 7.
pub fn ruby_option_spec_l7_d1_option(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'foo' }
	description := if args.len > 1 { args[1].as_string() } else { '' }
	option := option_types.new_option(name, description)
	return brew_runtime.structured_value('Option', option.str(), {
		'name':        option.name
		'flag':        option.flag
		'description': option.description
		'inspect':     option.inspect()
	})
}

// Ruby specify `specify do` at line 9.
pub fn ruby_option_spec_l9_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	option := option_types.new_option('foo')
	described := option_types.new_option('foo', 'foo')
	return brew_runtime.bool_value(option.str() == '--foo' && option.description == ''
		&& described.description == 'foo' && option.inspect() == '#<Option: "--foo">')
}

// Ruby specify `specify "equality" do` at line 16.
pub fn ruby_option_spec_l16_d3_equality(args ...brew_runtime.Value) brew_runtime.Value {
	option := option_types.new_option('foo')
	foo := option_types.new_option('foo')
	bar := option_types.new_option('bar')
	return brew_runtime.bool_value(option.equal(foo) && !option.equal(bar))
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
