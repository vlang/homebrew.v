module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `test/unpack_strategy/bzip2_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.bz2" }` at line 7.
pub fn ruby_bzip2_spec_l7_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby it `it "extracts with bzip2" do` at line 12.
pub fn ruby_bzip2_spec_l12_d2_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extracts', ...args)
}

// Ruby it `it "adds Homebrew bzip2 to PATH without resolving a formula" do` at line 29.
pub fn ruby_bzip2_spec_l29_d3_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Bzip2 do
// 7:   let(:path) { TEST_FIXTURE_DIR/"cask/container.bz2" }
// 8:
// 9:   include_examples "UnpackStrategy::detect"
// 10:   include_examples "#extract", children: ["container"]
// 11:
// 12:   it "extracts with bzip2" do
// 13:     strategy = described_class.new(path)
// 14:
// 15:     Dir.mktmpdir do |dir|
// 16:       unpack_dir = Pathname(dir)
// 17:       target = unpack_dir/path.basename
// 18:       expect(strategy).to receive(:system_command!).with(
// 19:         "bzip2",
// 20:         args:    ["-q", "-d", target],
// 21:         env:     { "PATH" => an_instance_of(String) },
// 22:         verbose: false,
// 23:       )
// 24:
// 25:       strategy.extract(to: unpack_dir)
// 26:     end
// 27:   end
// 28:
// 29:   it "adds Homebrew bzip2 to PATH without resolving a formula" do
// 30:     strategy = described_class.new(path)
// 31:
// 32:     Dir.mktmpdir do |dir|
// 33:       unpack_dir = Pathname(dir)
// 34:       target = unpack_dir/path.basename
// 35:       expect(Formula).not_to receive(:[])
// 36:       expect(strategy).to receive(:system_command!).with(
// 37:         "bzip2",
// 38:         args:    ["-q", "-d", target],
// 39:         env:     Utils::Path.formula_opt_bin_env("bzip2", ORIGINAL_PATHS),
// 40:         verbose: false,
// 41:       )
// 42:
// 43:       strategy.extract(to: unpack_dir)
// 44:     end
// 45:   end
// 46: end
