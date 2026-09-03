module cask

import homebrew.cask as reinstall_core

// Translated from Homebrew/brew `test/cask/reinstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "displays the reinstallation progress" do` at line 8.
pub fn ruby_reinstall_spec_l8_d1_displays() bool {
	result := reinstall_core.reinstall_casks([reinstall_core.ReinstallCask{
		full_name: 'local-caffeine'
		installed: true
	}], reinstall_core.ReinstallCaskOptions{})
	return result.output.contains('Uninstalling Cask local-caffeine') && result.output.contains('Installing Cask local-caffeine') && result.output.contains('local-caffeine was successfully installed!') && result.prefetched == [
		'local-caffeine',
	]
}

// Ruby it `it "displays the reinstallation progress with zapping" do` at line 28.
pub fn ruby_reinstall_spec_l28_d2_displays() bool {
	result := reinstall_core.reinstall_casks([reinstall_core.ReinstallCask{
		full_name: 'local-caffeine'
		installed: true
	}], reinstall_core.ReinstallCaskOptions{
		zap: true
	})
	return result.output.contains('Dispatching zap stanza for local-caffeine') && result.installed == [
		'local-caffeine',
	]
}

// Ruby it `it "allows reinstalling a Cask" do` at line 50.
pub fn ruby_reinstall_spec_l50_d3_allows() bool {
	result := reinstall_core.reinstall_casks([reinstall_core.ReinstallCask{
		full_name: 'local-transmission-zip'
		installed: true
	}], reinstall_core.ReinstallCaskOptions{})
	return result.installed == ['local-transmission-zip']
}

// Ruby it `it "continues reinstalling remaining casks when one raises" do` at line 59.
pub fn ruby_reinstall_spec_l59_d4_continues() bool {
	result := reinstall_core.reinstall_casks([
		reinstall_core.ReinstallCask{
			full_name: 'local-caffeine'
			installed: true
			fail_message: 'reinstall failed'
		},
		reinstall_core.ReinstallCask{
			full_name: 'local-transmission-zip'
			installed: true
		},
	], reinstall_core.ReinstallCaskOptions{})
	return result.failures['local-caffeine'] == 'reinstall failed' && result.installed == [
		'local-transmission-zip',
	]
}

// Ruby it `it "reinstalls casks after an earlier failure in the same run" do` at line 84.
pub fn ruby_reinstall_spec_l84_d5_reinstalls() bool {
	result := reinstall_core.reinstall_casks([reinstall_core.ReinstallCask{
		full_name: 'local-caffeine'
		installed: true
	}], reinstall_core.ReinstallCaskOptions{
		global_failed: true
	})
	return result.installed == ['local-caffeine']
}

// Ruby it `it "allows reinstalling a non installed Cask" do` at line 98.
pub fn ruby_reinstall_spec_l98_d6_allows() bool {
	result := reinstall_core.reinstall_casks([reinstall_core.ReinstallCask{
		full_name: 'local-transmission-zip'
	}], reinstall_core.ReinstallCaskOptions{})
	return result.installed == ['local-transmission-zip']
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/installer"
// 5: require "cask/reinstall"
// 6:
// 7: RSpec.describe Cask::Reinstall, :cask do
// 8:   it "displays the reinstallation progress" do
// 9:     caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 10:
// 11:     Cask::Installer.new(caffeine).install
// 12:
// 13:     output = Regexp.new <<~EOS
// 14:       ==> Uninstalling Cask local-caffeine
// 15:       ==> Backing up App 'Caffeine.app' to '.*Caffeine.app'
// 16:       ==> Removing App '.*Caffeine.app'
// 17:       ==> Purging files for version 1.2.3 of Cask local-caffeine
// 18:       ==> Installing Cask local-caffeine
// 19:       ==> Moving App 'Caffeine.app' to '.*Caffeine.app'
// 20:       .*local-caffeine was successfully installed!
// 21:     EOS
// 22:
// 23:     expect do
// 24:       described_class.reinstall_casks(Cask::CaskLoader.load("local-caffeine"))
// 25:     end.to output(output).to_stdout.and output(/==> Fetching downloads for:.*caffeine/).to_stderr
// 26:   end
// 27:
// 28:   it "displays the reinstallation progress with zapping" do
// 29:     caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 30:
// 31:     Cask::Installer.new(caffeine).install
// 32:
// 33:     output = Regexp.new <<~EOS
// 34:       ==> Backing up App 'Caffeine.app' to '.*Caffeine.app'
// 35:       ==> Removing App '.*Caffeine.app'
// 36:       ==> Dispatching zap stanza
// 37:       ==> Trashing files:
// 38:       .*org.example.caffeine.plist
// 39:       ==> Removing all staged versions of Cask 'local-caffeine'
// 40:       ==> Installing Cask local-caffeine
// 41:       ==> Moving App 'Caffeine.app' to '.*Caffeine.app'
// 42:       .*local-caffeine was successfully installed!
// 43:     EOS
// 44:
// 45:     expect do
// 46:       described_class.reinstall_casks(Cask::CaskLoader.load("local-caffeine"), zap: true)
// 47:     end.to output(output).to_stdout.and output(/==> Fetching downloads for:.*caffeine/).to_stderr
// 48:   end
// 49:
// 50:   it "allows reinstalling a Cask" do
// 51:     Cask::Installer.new(Cask::CaskLoader.load(cask_path("local-transmission-zip"))).install
// 52:
// 53:     expect(Cask::CaskLoader.load(cask_path("local-transmission-zip"))).to be_installed
// 54:
// 55:     described_class.reinstall_casks(Cask::CaskLoader.load("local-transmission-zip"))
// 56:     expect(Cask::CaskLoader.load(cask_path("local-transmission-zip"))).to be_installed
// 57:   end
// 58:
// 59:   it "continues reinstalling remaining casks when one raises" do
// 60:     cask1 = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 61:     cask2 = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 62:
// 63:     Cask::Installer.new(cask1).install
// 64:     Cask::Installer.new(cask2).install
// 65:
// 66:     failing_installer = instance_double(Cask::Installer, cask: cask1)
// 67:     allow(failing_installer).to receive(:prelude)
// 68:     allow(failing_installer).to receive(:source_download_requires_pre_fetch?).and_return(false)
// 69:     allow(failing_installer).to receive(:enqueue_downloads)
// 70:     allow(failing_installer).to receive(:install).and_raise(Cask::CaskError.new("reinstall failed"))
// 71:
// 72:     successful_installer = instance_double(Cask::Installer)
// 73:     allow(successful_installer).to receive(:prelude)
// 74:     allow(successful_installer).to receive(:source_download_requires_pre_fetch?).and_return(false)
// 75:     allow(successful_installer).to receive(:enqueue_downloads)
// 76:
// 77:     allow(Cask::Installer).to receive(:new).and_return(failing_installer, successful_installer)
// 78:
// 79:     expect(successful_installer).to receive(:install)
// 80:     expect { described_class.reinstall_casks(cask1, cask2) }
// 81:       .to output(/local-caffeine: reinstall failed/).to_stderr
// 82:   end
// 83:
// 84:   it "reinstalls casks after an earlier failure in the same run" do
// 85:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 86:     installer = instance_double(Cask::Installer, prelude: nil, enqueue_downloads: nil,
// 87:                                                  source_download_requires_pre_fetch?: false)
// 88:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 89:     # A failure earlier in the run (e.g. a formula in the same `brew reinstall`)
// 90:     # must not stop the casks that are ready from being reinstalled.
// 91:     Homebrew.failed = true
// 92:
// 93:     expect(installer).to receive(:install)
// 94:
// 95:     described_class.reinstall_casks(cask)
// 96:   end
// 97:
// 98:   it "allows reinstalling a non installed Cask" do
// 99:     expect(Cask::CaskLoader.load(cask_path("local-transmission-zip"))).not_to be_installed
// 100:
// 101:     described_class.reinstall_casks(Cask::CaskLoader.load("local-transmission-zip"))
// 102:     expect(Cask::CaskLoader.load(cask_path("local-transmission-zip"))).to be_installed
// 103:   end
// 104: end
