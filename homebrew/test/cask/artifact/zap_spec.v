module artifact

import homebrew.cask.artifact as zap_core
import os

// Translated from Homebrew/brew `test/cask/artifact/zap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }` at line 11.
pub fn ruby_zap_spec_l11_d1_artifact() zap_core.ZapArtifact {
	return zap_core.ZapArtifact{
		rmdir: [ruby_zap_spec_l15_d4_empty_directory()]
	}
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 13.
pub fn ruby_zap_spec_l13_d2_fake_system_command() string {
	return 'NeverSudoSystemCommand'
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-zap-rmdir")) }` at line 14.
pub fn ruby_zap_spec_l14_d3_cask() string {
	return 'with-zap-rmdir'
}

// Ruby let `let(:empty_directory) { Pathname.new("#{TEST_TMPDIR}/empty_directory_path") }` at line 15.
pub fn ruby_zap_spec_l15_d4_empty_directory() string {
	return os.join_path(os.temp_dir(), 'brew-v-zap-spec-empty-directory')
}

// Ruby let `let(:empty_directory_tree) { empty_directory.join("nested", "empty_directory_path") }` at line 16.
pub fn ruby_zap_spec_l16_d5_empty_directory_tree() string {
	return os.join_path(ruby_zap_spec_l15_d4_empty_directory(), 'nested', 'empty_directory_path')
}

// Ruby let `let(:ds_store) { empty_directory.join(".DS_Store") }` at line 17.
pub fn ruby_zap_spec_l17_d6_ds_store() string {
	return os.join_path(ruby_zap_spec_l15_d4_empty_directory(), '.DS_Store')
}

// Ruby it `it "is supported" do` at line 28.
pub fn ruby_zap_spec_l28_d7_is() !bool {
	root := ruby_zap_spec_l15_d4_empty_directory()
	if os.exists(root) {
		os.rmdir_all(root)!
	}
	os.mkdir_all(ruby_zap_spec_l16_d5_empty_directory_tree())!
	os.write_file(ruby_zap_spec_l17_d6_ds_store(), '')!
	if !os.is_dir(ruby_zap_spec_l16_d5_empty_directory_tree()) || !os.exists(ruby_zap_spec_l17_d6_ds_store()) {
		return false
	}
	result := zap_core.zap_phase(ruby_zap_spec_l11_d1_artifact())!
	return !os.exists(ruby_zap_spec_l17_d6_ds_store()) && !os.exists(root) && root in result.removed && result.skipped.len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples/uninstall_zap"
// 5:
// 6: RSpec.describe Cask::Artifact::Zap, :cask do
// 7:   describe "#zap_phase" do
// 8:     include_examples "#uninstall_phase or #zap_phase"
// 9:
// 10:     context "when using :rmdir" do
// 11:       subject(:artifact) { cask.artifacts.find { |a| a.is_a?(described_class) } }
// 12:
// 13:       let(:fake_system_command) { NeverSudoSystemCommand }
// 14:       let(:cask) { Cask::CaskLoader.load(cask_path("with-zap-rmdir")) }
// 15:       let(:empty_directory) { Pathname.new("#{TEST_TMPDIR}/empty_directory_path") }
// 16:       let(:empty_directory_tree) { empty_directory.join("nested", "empty_directory_path") }
// 17:       let(:ds_store) { empty_directory.join(".DS_Store") }
// 18:
// 19:       before do
// 20:         empty_directory_tree.mkpath
// 21:         FileUtils.touch ds_store
// 22:       end
// 23:
// 24:       after do
// 25:         FileUtils.rm_rf empty_directory
// 26:       end
// 27:
// 28:       it "is supported" do
// 29:         expect(empty_directory_tree).to exist
// 30:         expect(ds_store).to exist
// 31:
// 32:         artifact.zap_phase(command: fake_system_command)
// 33:
// 34:         expect(ds_store).not_to exist
// 35:         expect(empty_directory).not_to exist
// 36:       end
// 37:     end
// 38:   end
// 39: end
