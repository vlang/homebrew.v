module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/xar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.xar" }` at line 7.
pub fn ruby_xar_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(spec_xar_fixture())
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Xar, :needs_macos do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.xar" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10:   include_examples "#extract", children: ["container"]
// 11: end
