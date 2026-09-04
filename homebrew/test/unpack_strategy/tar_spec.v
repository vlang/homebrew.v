module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `test/unpack_strategy/tar_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.tar.gz" }` at line 7.
pub fn ruby_tar_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(spec_tar_fixture())
}

// Ruby let `let(:path) do` at line 13.
pub fn ruby_tar_spec_l13_d2_path(args ...ruby.Value) ruby.Value {
	path := os.join_path(spec_temp_dir('corrupt-tar'), 'test.tar')
	return ruby.string_value(spec_write_bytes(path, []u8{}))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Tar do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.tar.gz" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10:   include_examples "#extract", children: ["container"]
// 11:
// 12:   context "when TAR archive is corrupted" do
// 13:     let(:path) do
// 14:       (mktmpdir/"test.tar").tap do |path|
// 15:         FileUtils.touch path
// 16:       end
// 17:     end
// 18:
// 19:     include_examples "UnpackStrategy::detect"
// 20:   end
// 21: end
