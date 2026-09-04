module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `test/unpack_strategy/lha_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"test.lha" }` at line 7.
pub fn ruby_lha_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	path := os.join_path(spec_temp_dir('lha'), 'test.lha')
	return ruby.string_value(spec_write_bytes(path, [u8(0), 0, `-`, `l`, `h`, `5`, `-`,
		0]))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Lha do
// 7:   let(:path) { TEST_FIXTURE_DIR/"test.lha" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10: end
