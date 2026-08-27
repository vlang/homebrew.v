module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/shared_examples.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "is correctly detected" do` at line 8.
pub fn ruby_shared_examples_l8_d1_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby specify `specify "#extract" do` at line 14.
pub fn ruby_shared_examples_l14_d2_extract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#extract', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "mktemp"
// 5: require "unpack_strategy"
// 6:
// 7: RSpec.shared_examples "UnpackStrategy::detect" do
// 8:   it "is correctly detected" do
// 9:     expect(UnpackStrategy.detect(path)).to be_a described_class
// 10:   end
// 11: end
// 12:
// 13: RSpec.shared_examples "#extract" do |children: [], verbose: false|
// 14:   specify "#extract" do
// 15:     Mktemp.new("homebrew-test-unpack").run(chdir: false) do |mktemp|
// 16:       unpack_dir = T.must(mktemp.tmpdir)
// 17:       described_class.new(path).extract(to: unpack_dir, verbose:)
// 18:       expect(unpack_dir.children(false).map(&:to_s)).to match_array children
// 19:     end
// 20:   end
// 21: end
