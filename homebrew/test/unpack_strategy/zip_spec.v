module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `test/unpack_strategy/zip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/MyFancyApp.zip" }` at line 7.
pub fn ruby_zip_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(spec_zip_fixture())
}

// Ruby let `let(:path) do` at line 16.
pub fn ruby_zip_spec_l16_d2_path(args ...ruby.Value) ruby.Value {
	path := os.join_path(spec_temp_dir('corrupt-zip'), 'test.zip')
	return ruby.string_value(spec_write_bytes(path, []u8{}))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Zip do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/MyFancyApp.zip" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10:
// 11:   context "when unzip is available", :needs_unzip do
// 12:     include_examples "#extract", children: ["MyFancyApp"]
// 13:   end
// 14:
// 15:   context "when ZIP archive is corrupted" do
// 16:     let(:path) do
// 17:       (mktmpdir/"test.zip").tap do |path|
// 18:         FileUtils.touch path
// 19:       end
// 20:     end
// 21:
// 22:     include_examples "UnpackStrategy::detect"
// 23:   end
// 24: end
