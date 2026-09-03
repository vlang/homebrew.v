module options

import brew_runtime
import homebrew.options as option_types

// Translated from Homebrew/brew `test/options/deprecated_option_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:option) { described_class.new("foo", "bar") }` at line 7.
pub fn ruby_deprecated_option_spec_l7_d1_option(args ...brew_runtime.Value) brew_runtime.Value {
	old := if args.len > 0 { args[0].as_string() } else { 'foo' }
	current := if args.len > 1 { args[1].as_string() } else { 'bar' }
	option := option_types.new_deprecated_option(old, current)
	return brew_runtime.structured_value('DeprecatedOption', '${old}:${current}', {
		'old':          option.old
		'old_flag':     option.old_flag()
		'current':      option.current
		'current_flag': option.current_flag()
	})
}

// Ruby specify `specify do` at line 9.
pub fn ruby_deprecated_option_spec_l9_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	option := option_types.new_deprecated_option('foo', 'bar')
	return brew_runtime.bool_value(option.old == 'foo' && option.old_flag() == '--foo'
		&& option.current == 'bar' && option.current_flag() == '--bar')
}

// Ruby specify `specify "equality" do` at line 16.
pub fn ruby_deprecated_option_spec_l16_d3_equality(args ...brew_runtime.Value) brew_runtime.Value {
	option := option_types.new_deprecated_option('foo', 'bar')
	foobar := option_types.new_deprecated_option('foo', 'bar')
	boofar := option_types.new_deprecated_option('boo', 'far')
	return brew_runtime.bool_value(foobar.equal(option) && option.equal(foobar)
		&& !boofar.equal(option) && !option.equal(boofar))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "options"
// 5:
// 6: RSpec.describe DeprecatedOption do
// 7:   subject(:option) { described_class.new("foo", "bar") }
// 8:
// 9:   specify do
// 10:     expect(option.old).to eq("foo")
// 11:     expect(option.old_flag).to eq("--foo")
// 12:     expect(option.current).to eq("bar")
// 13:     expect(option.current_flag).to eq("--bar")
// 14:   end
// 15:
// 16:   specify "equality" do
// 17:     foobar = described_class.new("foo", "bar")
// 18:     boofar = described_class.new("boo", "far")
// 19:     expect(foobar).to eq(option)
// 20:     expect(option).to eq(foobar)
// 21:     expect(boofar).not_to eq(option)
// 22:     expect(option).not_to eq(boofar)
// 23:   end
// 24: end
