module artifact

import brew_runtime

// Translated from Homebrew/brew `test/cask/artifact/two_apps_correct_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-correct")) }` at line 6.
pub fn ruby_two_apps_correct_spec_l6_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:install_phase) do` at line 8.
pub fn ruby_two_apps_correct_spec_l8_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby let `let(:source_path_mini) { cask.staged_path.join("Caffeine Mini.app") }` at line 14.
pub fn ruby_two_apps_correct_spec_l14_d3_source_path_mini(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path_mini', ...args)
}

// Ruby let `let(:target_path_mini) { Pathname(cask.config.appdir).join("Caffeine Mini.app") }` at line 15.
pub fn ruby_two_apps_correct_spec_l15_d4_target_path_mini(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path_mini', ...args)
}

// Ruby let `let(:source_path_pro) { cask.staged_path.join("Caffeine Pro.app") }` at line 17.
pub fn ruby_two_apps_correct_spec_l17_d5_source_path_pro(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path_pro', ...args)
}

// Ruby let `let(:target_path_pro) { Pathname(cask.config.appdir).join("Caffeine Pro.app") }` at line 18.
pub fn ruby_two_apps_correct_spec_l18_d6_target_path_pro(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_path_pro', ...args)
}

// Ruby it `it "installs both apps using the proper target directory" do` at line 24.
pub fn ruby_two_apps_correct_spec_l24_d7_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-subdir")) }` at line 35.
pub fn ruby_two_apps_correct_spec_l35_d8_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby let `let(:source_path_mini) { cask.staged_path.join("Caffeines", "Caffeine Mini.app") }` at line 37.
pub fn ruby_two_apps_correct_spec_l37_d9_source_path_mini(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path_mini', ...args)
}

// Ruby let `let(:source_path_pro) { cask.staged_path.join("Caffeines", "Caffeine Pro.app") }` at line 38.
pub fn ruby_two_apps_correct_spec_l38_d10_source_path_pro(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_path_pro', ...args)
}

// Ruby it `it "installs both apps using the proper target directory" do` at line 40.
pub fn ruby_two_apps_correct_spec_l40_d11_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installs', ...args)
}

// Ruby it `it "only uses apps when they are specified" do` at line 51.
pub fn ruby_two_apps_correct_spec_l51_d12_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "when the first app of two already exists" do` at line 64.
pub fn ruby_two_apps_correct_spec_l64_d13_when(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('when', ...args)
}

// Ruby it `it "when the second app of two already exists" do` at line 78.
pub fn ruby_two_apps_correct_spec_l78_d14_when(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('when', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::App, :cask do
// 5:   describe "multiple apps" do
// 6:     let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-correct")) }
// 7:
// 8:     let(:install_phase) do
// 9:       cask.artifacts.grep(described_class).each do |artifact|
// 10:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 11:       end
// 12:     end
// 13:
// 14:     let(:source_path_mini) { cask.staged_path.join("Caffeine Mini.app") }
// 15:     let(:target_path_mini) { Pathname(cask.config.appdir).join("Caffeine Mini.app") }
// 16:
// 17:     let(:source_path_pro) { cask.staged_path.join("Caffeine Pro.app") }
// 18:     let(:target_path_pro) { Pathname(cask.config.appdir).join("Caffeine Pro.app") }
// 19:
// 20:     before do
// 21:       InstallHelper.install_without_artifacts(cask)
// 22:     end
// 23:
// 24:     it "installs both apps using the proper target directory" do
// 25:       install_phase
// 26:
// 27:       expect(target_path_mini).to be_a_directory
// 28:       expect(source_path_mini).to be_a_symlink
// 29:
// 30:       expect(target_path_pro).to be_a_directory
// 31:       expect(source_path_pro).to be_a_symlink
// 32:     end
// 33:
// 34:     describe "when apps are in a subdirectory" do
// 35:       let(:cask) { Cask::CaskLoader.load(cask_path("with-two-apps-subdir")) }
// 36:
// 37:       let(:source_path_mini) { cask.staged_path.join("Caffeines", "Caffeine Mini.app") }
// 38:       let(:source_path_pro) { cask.staged_path.join("Caffeines", "Caffeine Pro.app") }
// 39:
// 40:       it "installs both apps using the proper target directory" do
// 41:         install_phase
// 42:
// 43:         expect(target_path_mini).to be_a_directory
// 44:         expect(source_path_mini).to be_a_symlink
// 45:
// 46:         expect(target_path_pro).to be_a_directory
// 47:         expect(source_path_pro).to be_a_symlink
// 48:       end
// 49:     end
// 50:
// 51:     it "only uses apps when they are specified" do
// 52:       FileUtils.cp_r source_path_mini, source_path_mini.sub("Caffeine Mini.app", "Caffeine Deluxe.app")
// 53:
// 54:       install_phase
// 55:
// 56:       expect(target_path_mini).to be_a_directory
// 57:       expect(source_path_mini).to be_a_symlink
// 58:
// 59:       expect(Pathname(cask.config.appdir).join("Caffeine Deluxe.app")).not_to exist
// 60:       expect(cask.staged_path.join("Caffeine Deluxe.app")).to exist
// 61:     end
// 62:
// 63:     describe "avoids clobbering an existing app" do
// 64:       it "when the first app of two already exists" do
// 65:         target_path_mini.mkpath
// 66:
// 67:         expect do
// 68:           expect { install_phase }.to output(<<~EOS).to_stdout
// 69:             ==> Moving App 'Caffeine Pro.app' to '#{target_path_pro}'
// 70:           EOS
// 71:         end.to raise_error(Cask::CaskError, "It seems there is already an App at '#{target_path_mini}'.")
// 72:
// 73:         expect(source_path_mini).to be_a_directory
// 74:         expect(target_path_mini).to be_a_directory
// 75:         expect(File.identical?(source_path_mini, target_path_mini)).to be false
// 76:       end
// 77:
// 78:       it "when the second app of two already exists" do
// 79:         target_path_pro.mkpath
// 80:
// 81:         expect do
// 82:           expect { install_phase }.to output(<<~EOS).to_stdout
// 83:             ==> Moving App 'Caffeine Mini.app' to '#{target_path_mini}'
// 84:           EOS
// 85:         end.to raise_error(Cask::CaskError, "It seems there is already an App at '#{target_path_pro}'.")
// 86:
// 87:         expect(source_path_pro).to be_a_directory
// 88:         expect(target_path_pro).to be_a_directory
// 89:         expect(File.identical?(source_path_pro, target_path_pro)).to be false
// 90:       end
// 91:     end
// 92:   end
// 93: end
