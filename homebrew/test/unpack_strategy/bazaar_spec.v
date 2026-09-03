module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/bazaar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:repo) do` at line 7.
pub fn ruby_bazaar_spec_l7_d1_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(spec_repository_fixture('bazaar', '.bzr', true))
}

// Ruby let `let(:path) { repo }` at line 13.
pub fn ruby_bazaar_spec_l13_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { ruby_bazaar_spec_l7_d1_repo() }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Bazaar do
// 7:   let(:repo) do
// 8:     mktmpdir.tap do |repo|
// 9:       FileUtils.touch repo/"test"
// 10:       (repo/".bzr").mkpath
// 11:     end
// 12:   end
// 13:   let(:path) { repo }
// 14:
// 15:   include_examples "UnpackStrategy::detect"
// 16:   include_examples "#extract", children: ["test"]
// 17: end
