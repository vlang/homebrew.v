module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `test/unpack_strategy/p7zip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.7z" }` at line 7.
pub fn ruby_p7zip_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := os.join_path(spec_temp_dir('p7zip'), 'container.7z')
	return brew_runtime.string_value(spec_write_bytes(path, [u8(`7`), `z`, 0xbc, 0xaf, 0x27, 0x1c]))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::P7Zip do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.7z" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10: end
