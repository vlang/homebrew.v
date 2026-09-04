module unpack_strategy

import ruby
import homebrew.unpack_strategy as typed_unpack
import os

// Translated from Homebrew/brew `test/unpack_strategy/zstd_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.tar.zst" }` at line 7.
pub fn ruby_zstd_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	path := os.join_path(spec_temp_dir('zstd'), 'container.tar.zst')
	return ruby.string_value(spec_write_bytes(path, [u8(0x28), 0xb5, 0x2f, 0xfd]))
}

// Ruby it `it "is correctly detected" do` at line 9.
pub fn ruby_zstd_spec_l9_d2_is(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { ruby_zstd_spec_l7_d1_path().as_string() }
	kind := typed_unpack.detect(path, typed_unpack.DetectOptions{}).kind
	return spec_bool(kind in [.zstd, .tar])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Zstd do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.tar.zst" }
// 8:
// 9:   it "is correctly detected" do
// 10:     # `UnpackStrategy.detect(path)` for a `.tar.XXX` file returns either `UnpackStrategy::Tar` if
// 11:     # the host's `tar` is able to extract that compressed file or `UnpackStrategy::XXX` otherwise,
// 12:     # such as `UnpackStrategy::Zstd`. On macOS `UnpackStrategy.detect("container.tar.zst")`
// 13:     # returns `UnpackStrategy::Zstd` and on Ubuntu 22.04 it returns `UnpackStrategy::Tar`,
// 14:     # because the host's version of `tar` is recent enough and `zstd` is installed.
// 15:     expect(UnpackStrategy.detect(path)).to(be_a(described_class).or(be_a(UnpackStrategy::Tar)))
// 16:   end
// 17: end
