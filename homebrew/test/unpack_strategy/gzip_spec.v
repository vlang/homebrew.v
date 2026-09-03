module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/gzip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.gz" }` at line 7.
pub fn ruby_gzip_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(spec_compressed_fixture('gzip', 'gzip', '.gz', [
		u8(0x1f),
		0x8b,
	]))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Gzip do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.gz" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10:   include_examples "#extract", children: ["container"], verbose: true
// 11: end
