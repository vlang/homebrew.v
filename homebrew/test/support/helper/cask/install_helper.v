module cask

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/cask/install_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.install_without_artifacts(cask)` at line 9.
pub fn ruby_install_helper_l9_d1_self_install_without_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_without_artifacts', ...args)
}

// Ruby method `self.install_without_artifacts_with_caskfile(cask)` at line 16.
pub fn ruby_install_helper_l16_d2_self_install_without_artifacts_with_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_without_artifacts_with_caskfile', ...args)
}

// Ruby method `self.stub_cask_installation(cask, create_app_dirs: true)` at line 31.
pub fn ruby_install_helper_l31_d3_self_stub_cask_installation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.stub_cask_installation', ...args)
}

// Ruby method `install_without_artifacts(cask)` at line 56.
pub fn ruby_install_helper_l56_d4_install_without_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_without_artifacts', ...args)
}

// Ruby method `install_with_caskfile(cask)` at line 63.
pub fn ruby_install_helper_l63_d5_install_with_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_with_caskfile', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/installer"
// 5:
// 6: module InstallHelper
// 7:   module_function
// 8:
// 9:   def self.install_without_artifacts(cask)
// 10:     Cask::Installer.new(cask).tap do |i|
// 11:       i.download
// 12:       i.extract_primary_container
// 13:     end
// 14:   end
// 15:
// 16:   def self.install_without_artifacts_with_caskfile(cask)
// 17:     Cask::Installer.new(cask).tap do |i|
// 18:       i.download
// 19:       i.extract_primary_container
// 20:       i.save_caskfile
// 21:     end
// 22:   end
// 23:
// 24:   # Creates a minimal stub installation without downloading or extracting.
// 25:   # This is useful for tests that only need to check installation state
// 26:   # (installed?, installed_version) and artifact paths without performing
// 27:   # actual file operations.
// 28:   #
// 29:   # @param cask [Cask::Cask] the cask to stub install
// 30:   # @param create_app_dirs [Boolean] whether to create stub app directories in appdir
// 31:   def self.stub_cask_installation(cask, create_app_dirs: true)
// 32:     # Create the caskroom path
// 33:     cask.caskroom_path.mkpath
// 34:
// 35:     # Create the staged_path (version directory)
// 36:     cask.staged_path.mkpath
// 37:
// 38:     # Create metadata directory structure and save the caskfile and receipt
// 39:     # This makes installed? and installed_version work
// 40:     Cask::Installer.new(cask).save_caskfile
// 41:     tab = Cask::Tab.create(cask)
// 42:     tab.installed_on_request = true
// 43:     tab.write
// 44:
// 45:     return unless create_app_dirs
// 46:
// 47:     # Create stub app directories in appdir so path existence checks pass
// 48:     cask.artifacts.each do |artifact|
// 49:       next unless artifact.is_a?(Cask::Artifact::App)
// 50:
// 51:       target_path = Pathname(cask.config.appdir).join(artifact.target.basename)
// 52:       target_path.mkpath
// 53:     end
// 54:   end
// 55:
// 56:   def install_without_artifacts(cask)
// 57:     Cask::Installer.new(cask).tap do |i|
// 58:       i.download
// 59:       i.extract_primary_container
// 60:     end
// 61:   end
// 62:
// 63:   def install_with_caskfile(cask)
// 64:     Cask::Installer.new(cask).tap(&:save_caskfile)
// 65:   end
// 66: end
