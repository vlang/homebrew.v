module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/clang_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:config_dir) { Pathname(TEST_TMPDIR)/"clang-config" }` at line 8.
pub fn ruby_clang_spec_l8_d1_config_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config_dir', ...args)
}

// Ruby specify `specify "writes Clang system configuration files" do` at line 12.
pub fn ruby_clang_spec_l12_d2_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/clang"
// 5:
// 6: RSpec.describe Utils::Clang, :needs_macos do
// 7:   sig { returns(Pathname) }
// 8:   let(:config_dir) { Pathname(TEST_TMPDIR)/"clang-config" }
// 9:
// 10:   after { FileUtils.rm_rf config_dir }
// 11:
// 12:   specify "writes Clang system configuration files" do
// 13:     macos_version = MacOSVersion.new("14")
// 14:     allow(MacOS).to receive(:version).and_return(macos_version)
// 15:
// 16:     described_class.write_system_config_files(
// 17:       config_dir:,
// 18:       macos_version:,
// 19:       kernel_version: Version.new("23"),
// 20:       arch:           :arm64,
// 21:     )
// 22:
// 23:     expect(config_dir.children.map { |path| path.basename.to_s }).to contain_exactly(
// 24:       "aarch64-apple-darwin23.cfg",
// 25:       "aarch64-apple-macosx14.cfg",
// 26:       "arm64-apple-darwin23.cfg",
// 27:       "arm64-apple-macosx14.cfg",
// 28:       "x86_64-apple-darwin23.cfg",
// 29:       "x86_64-apple-macosx14.cfg",
// 30:     )
// 31:     expect((config_dir/"arm64-apple-macosx14.cfg").read)
// 32:       .to eq("-isysroot #{MacOS::CLT::PKG_PATH}/SDKs/MacOSX14.sdk\n")
// 33:   end
// 34: end
