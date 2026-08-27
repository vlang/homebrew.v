module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/mercurial_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:repo) do` at line 7.
pub fn ruby_mercurial_spec_l7_d1_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repo', ...args)
}

// Ruby let `let(:path) { repo }` at line 12.
pub fn ruby_mercurial_spec_l12_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Mercurial do
// 7:   let(:repo) do
// 8:     mktmpdir.tap do |repo|
// 9:       (repo/".hg").mkpath
// 10:     end
// 11:   end
// 12:   let(:path) { repo }
// 13:
// 14:   include_examples "UnpackStrategy::detect"
// 15: end
