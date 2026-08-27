module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/abstract_uninstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(artifact_class) } }` at line 10.
pub fn ruby_abstract_uninstall_spec_l10_d1_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifact', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-delete")) }` at line 12.
pub fn ruby_abstract_uninstall_spec_l12_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "skips relative paths" do` at line 22.
pub fn ruby_abstract_uninstall_spec_l22_d3_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips absolute paths containing relative segments" do` at line 28.
pub fn ruby_abstract_uninstall_spec_l28_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips tilde paths containing relative segments" do` at line 48.
pub fn ruby_abstract_uninstall_spec_l48_d5_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips undeletable glob matches after expansion" do` at line 58.
pub fn ruby_abstract_uninstall_spec_l58_d6_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "surfaces Full Disk Access guidance when globbing raises EPERM" do` at line 78.
pub fn ruby_abstract_uninstall_spec_l78_d7_surfaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('surfaces', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::AbstractUninstall, :cask do
// 5:   test_each([
// 6:     [Cask::Artifact::Uninstall, :uninstall],
// 7:     [Cask::Artifact::Zap, :zap],
// 8:   ]) do |(artifact_class, artifact_dsl_key)|
// 9:     describe "#each_resolved_path for #{artifact_dsl_key.inspect}" do
// 10:       subject(:artifact) { cask.artifacts.find { |candidate| candidate.is_a?(artifact_class) } }
// 11:
// 12:       let(:cask) { Cask::CaskLoader.load(cask_path("with-#{artifact_dsl_key}-delete")) }
// 13:
// 14:       around do |example|
// 15:         old_home = Dir.home
// 16:         ENV["HOME"] = TEST_TMPDIR
// 17:         example.run
// 18:       ensure
// 19:         ENV["HOME"] = old_home
// 20:       end
// 21:
// 22:       it "skips relative paths" do
// 23:         expect do
// 24:           expect(artifact.each_resolved_path(:delete, ["relative/path"]).to_a).to be_empty
// 25:         end.to output(%r{Skipping delete for relative path 'relative/path'\.}).to_stderr
// 26:       end
// 27:
// 28:       it "skips absolute paths containing relative segments" do
// 29:         tmpdir = Pathname.new(TEST_TMPDIR)
// 30:         valid_path = tmpdir/"each_resolved_path_#{artifact_dsl_key}"
// 31:
// 32:         FileUtils.touch valid_path
// 33:
// 34:         [
// 35:           tmpdir/"nested/../#{valid_path.basename}",
// 36:           tmpdir/"nested/./#{valid_path.basename}",
// 37:         ].each do |invalid_path|
// 38:           expect do
// 39:             expect(artifact.each_resolved_path(:delete, [invalid_path.to_s]).to_a).to be_empty
// 40:           end.to output(
// 41:             /Skipping delete for path with relative segments '#{Regexp.escape(invalid_path.to_s)}'\./,
// 42:           ).to_stderr
// 43:         end
// 44:       ensure
// 45:         FileUtils.rm_f valid_path
// 46:       end
// 47:
// 48:       it "skips tilde paths containing relative segments" do
// 49:         invalid_path = "~/../each_resolved_path_#{artifact_dsl_key}"
// 50:
// 51:         expect do
// 52:           expect(artifact.each_resolved_path(:delete, [invalid_path]).to_a).to be_empty
// 53:         end.to output(
// 54:           /Skipping delete for path with relative segments '#{Regexp.escape(invalid_path)}'\./,
// 55:         ).to_stderr
// 56:       end
// 57:
// 58:       it "skips undeletable glob matches after expansion" do
// 59:         glob_dir = Pathname.new(TEST_TMPDIR)/"each_resolved_path_glob_#{artifact_dsl_key}"
// 60:         safe_path = glob_dir/"safe.plist"
// 61:         undeletable_path = glob_dir/"undeletable.plist"
// 62:
// 63:         FileUtils.mkdir_p glob_dir
// 64:         FileUtils.touch [safe_path, undeletable_path]
// 65:
// 66:         allow(artifact).to receive(:undeletable?) { |target| target == undeletable_path }
// 67:
// 68:         expect do
// 69:           expect(artifact.each_resolved_path(:delete, ["#{glob_dir}/*.plist"]).to_a)
// 70:             .to eq([["#{glob_dir}/*.plist", [safe_path]]])
// 71:         end.to output(
// 72:           /Skipping delete for undeletable path '#{Regexp.escape(undeletable_path.to_s)}'\./,
// 73:         ).to_stderr
// 74:       ensure
// 75:         FileUtils.rm_rf glob_dir
// 76:       end
// 77:
// 78:       it "surfaces Full Disk Access guidance when globbing raises EPERM" do
// 79:         allow(Pathname).to receive(:glob).and_raise(Errno::EPERM)
// 80:         allow(Cask::Utils).to receive(:full_disk_access_enabled?).and_return(false)
// 81:         allow(MacOS).to receive(:version).and_return(MacOSVersion.from_symbol(:ventura))
// 82:
// 83:         expect do
// 84:           artifact.each_resolved_path(:delete, ["/tmp/each_resolved_path_#{artifact_dsl_key}"]).to_a
// 85:         end.to raise_error(SystemExit)
// 86:           .and output(/Full Disk Access/).to_stderr
// 87:       end
// 88:     end
// 89:   end
// 90: end
