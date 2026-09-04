module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `test/unpack_strategy/rar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.rar" }` at line 7.
pub fn ruby_rar_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	path := os.join_path(spec_temp_dir('rar'), 'container.rar')
	return ruby.string_value(spec_write_bytes(path, 'Rar!'.bytes()))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Rar do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.rar" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10: end
