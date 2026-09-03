module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `test/unpack_strategy/uncompressed_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) do` at line 7.
pub fn ruby_uncompressed_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := os.join_path(spec_temp_dir('uncompressed'), 'test')
	return brew_runtime.string_value(spec_write_bytes(path, []u8{}))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Uncompressed do
// 7:   let(:path) do
// 8:     (mktmpdir/"test").tap do |path|
// 9:       FileUtils.touch path
// 10:     end
// 11:   end
// 12:
// 13:   include_examples "UnpackStrategy::detect"
// 14: end
