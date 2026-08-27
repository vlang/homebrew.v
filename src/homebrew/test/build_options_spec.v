module test

import brew_runtime

// Translated from Homebrew/brew `test/build_options_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:build_options) { described_class.new(args, opts) }` at line 8.
pub fn ruby_build_options_spec_l8_d1_build_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_options', ...args)
}

// Ruby let `let(:args) { Options.create(%w[--with-foo --with-bar --without-qux]) }` at line 10.
pub fn ruby_build_options_spec_l10_d2_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby let `let(:opts) { Options.create(%w[--with-foo --with-bar --without-baz --without-qux]) }` at line 11.
pub fn ruby_build_options_spec_l11_d3_opts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opts', ...args)
}

// Ruby alias_matcher `alias_matcher :be_built_with, :be_with` at line 13.
pub fn ruby_build_options_spec_l13_d4_be_built_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_built_with', ...args)
}

// Ruby alias_matcher `alias_matcher :be_built_without, :be_without` at line 14.
pub fn ruby_build_options_spec_l14_d5_be_built_without(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_built_without', ...args)
}

// Ruby specify `specify do` at line 16.
pub fn ruby_build_options_spec_l16_d6_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "build_options"
// 5: require "options"
// 6:
// 7: RSpec.describe BuildOptions do
// 8:   subject(:build_options) { described_class.new(args, opts) }
// 9:
// 10:   let(:args) { Options.create(%w[--with-foo --with-bar --without-qux]) }
// 11:   let(:opts) { Options.create(%w[--with-foo --with-bar --without-baz --without-qux]) }
// 12:
// 13:   alias_matcher :be_built_with, :be_with
// 14:   alias_matcher :be_built_without, :be_without
// 15:
// 16:   specify do
// 17:     expect(build_options).to be_built_with("foo")
// 18:     expect(build_options).to be_built_with("bar")
// 19:     expect(build_options).to be_built_with("baz")
// 20:     expect(build_options).to be_built_without("qux")
// 21:     expect(build_options).to be_built_without("xyz")
// 22:     expect(build_options.used_options).to include("--with-foo")
// 23:     expect(build_options.used_options).to include("--with-bar")
// 24:     expect(build_options.unused_options).to include("--without-baz")
// 25:   end
// 26: end
