module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `test/unpack_strategy/lzip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"test.lz" }` at line 7.
pub fn ruby_lzip_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := os.join_path(spec_temp_dir('lzip'), 'test.lz')
	return brew_runtime.string_value(spec_write_bytes(path, 'LZIP'.bytes()))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Lzip do
// 7:   let(:path) { TEST_FIXTURE_DIR/"test.lz" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10: end
