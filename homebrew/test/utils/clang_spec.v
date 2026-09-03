module utils

import brew_runtime
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `test/utils/clang_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:config_dir) { Pathname(TEST_TMPDIR)/"clang-config" }` at line 8.
pub fn ruby_clang_spec_l8_d1_config_dir(args ...brew_runtime.Value) brew_runtime.Value {
	base := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_value(brew_runtime.join_path(base, 'clang-config'))
}

// Ruby specify `specify "writes Clang system configuration files" do` at line 12.
pub fn ruby_clang_spec_l12_d2_writes(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	config_dir := args[0].as_string()
	brew_utils.write_clang_system_config_files(config_dir, '14', '23', 'arm64', '14',
		'/Library/Developer/CommandLineTools/SDKs') or { return brew_runtime.bool_value(false) }
	expected := [
		'aarch64-apple-darwin23.cfg',
		'aarch64-apple-macosx14.cfg',
		'arm64-apple-darwin23.cfg',
		'arm64-apple-macosx14.cfg',
		'x86_64-apple-darwin23.cfg',
		'x86_64-apple-macosx14.cfg',
	]
	mut actual := brew_runtime.list_dir(config_dir) or { return brew_runtime.bool_value(false) }
	actual.sort()
	return brew_runtime.bool_value(actual == expected && brew_runtime.read_file(brew_runtime.join_path(config_dir, 'arm64-apple-macosx14.cfg')) or {
		''
	} == '-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk\n')
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
