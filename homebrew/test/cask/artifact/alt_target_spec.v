module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/alt_target_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-alt-target")) }` at line 6.
pub fn ruby_alt_target_spec_l6_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 8.
pub fn ruby_alt_target_spec_l8_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path) { cask.staged_path.join("Caffeine.app") }` at line 13.
pub fn ruby_alt_target_spec_l13_d3_source_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path', ...args)
}

// Ruby let `let(:target_path) { Pathname(cask.config.appdir).join("AnotherName.app") }` at line 14.
pub fn ruby_alt_target_spec_l14_d4_target_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path', ...args)
}

// Ruby it `it "installs the given apps using the proper target directory" do` at line 16.
pub fn ruby_alt_target_spec_l16_d5_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:cask) do` at line 29.
pub fn ruby_alt_target_spec_l29_d6_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "installs the given apps using the proper target directory" do` at line 39.
pub fn ruby_alt_target_spec_l39_d7_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby it `it "only uses apps when they are specified" do` at line 50.
pub fn ruby_alt_target_spec_l50_d8_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "avoids clobbering an existing app by moving over it" do` at line 64.
pub fn ruby_alt_target_spec_l64_d9_avoids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avoids', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::App, :cask do
// 5:   describe "activate to alternate target" do
// 6:     let(:cask) { Cask::CaskLoader.load(cask_path("with-alt-target")) }
// 7:
// 8:     let(:install_phase) do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:     let(:source_path) { cask.staged_path.join("Caffeine.app") }
// 14:     let(:target_path) { Pathname(cask.config.appdir).join("AnotherName.app") }
// 15:
// 16:     it "installs the given apps using the proper target directory" do
// 17:       source_path.mkpath
// 18:
// 19:       expect(source_path).to be_a_directory
// 20:       expect(target_path).not_to exist
// 21:
// 22:       install_phase
// 23:
// 24:       expect(target_path).to be_a_directory
// 25:       expect(source_path).to be_a_symlink
// 26:     end
// 27:
// 28:     describe "when app is in a subdirectory" do
// 29:       let(:cask) do
// 30:         Cask::Cask.new("subdir") do
// 31:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 32:           homepage "https://brew.sh/local-caffeine"
// 33:           version "1.2.3"
// 34:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 35:           app "subdir/Caffeine.app", target: "AnotherName.app"
// 36:         end
// 37:       end
// 38:
// 39:       it "installs the given apps using the proper target directory" do
// 40:         appsubdir = cask.staged_path.join("subdir").tap(&:mkpath)
// 41:         (appsubdir/"Caffeine.app").mkpath
// 42:
// 43:         install_phase
// 44:
// 45:         expect(target_path).to be_a_directory
// 46:         expect(appsubdir.join("Caffeine.app")).to be_a_symlink
// 47:       end
// 48:     end
// 49:
// 50:     it "only uses apps when they are specified" do
// 51:       source_path.mkpath
// 52:       staged_app_copy = source_path.sub("Caffeine.app", "Caffeine Deluxe.app")
// 53:       staged_app_copy.mkpath
// 54:
// 55:       install_phase
// 56:
// 57:       expect(target_path).to be_a_directory
// 58:       expect(source_path).to be_a_symlink
// 59:
// 60:       expect(Pathname(cask.config.appdir).join("Caffeine Deluxe.app")).not_to exist
// 61:       expect(cask.staged_path.join("Caffeine Deluxe.app")).to be_a_directory
// 62:     end
// 63:
// 64:     it "avoids clobbering an existing app by moving over it" do
// 65:       source_path.mkpath
// 66:       target_path.mkpath
// 67:
// 68:       expect { install_phase }
// 69:         .to raise_error(Cask::CaskError, "It seems there is already an App at '#{target_path}'.")
// 70:
// 71:       expect(source_path).to be_a_directory
// 72:       expect(target_path).to be_a_directory
// 73:       expect(File.identical?(source_path, target_path)).to be false
// 74:     end
// 75:   end
// 76: end
