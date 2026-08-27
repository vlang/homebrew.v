module shared_examples

import brew_runtime

// Translated from Homebrew/brew `test/cask/dsl/shared_examples/base.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "supports the token method" do` at line 7.
pub fn ruby_base_l7_d1_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "supports the version method" do` at line 11.
pub fn ruby_base_l11_d2_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "supports the caskroom_path method" do` at line 15.
pub fn ruby_base_l15_d3_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "supports the staged_path method" do` at line 19.
pub fn ruby_base_l19_d4_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Ruby it `it "supports the appdir method" do` at line 23.
pub fn ruby_base_l23_d5_supports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/dsl/base"
// 5:
// 6: RSpec.shared_examples Cask::DSL::Base do
// 7:   it "supports the token method" do
// 8:     expect(dsl.token).to eq(cask.token)
// 9:   end
// 10:
// 11:   it "supports the version method" do
// 12:     expect(dsl.version).to eq(cask.version)
// 13:   end
// 14:
// 15:   it "supports the caskroom_path method" do
// 16:     expect(dsl.caskroom_path).to eq(cask.caskroom_path)
// 17:   end
// 18:
// 19:   it "supports the staged_path method" do
// 20:     expect(dsl.staged_path).to eq(cask.staged_path)
// 21:   end
// 22:
// 23:   it "supports the appdir method" do
// 24:     expect(dsl.appdir).to eq(cask.appdir)
// 25:   end
// 26: end
