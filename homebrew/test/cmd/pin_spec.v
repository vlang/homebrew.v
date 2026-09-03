module cmd

import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/pin_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "pins a Formula's version", :integration_test do` at line 10.
pub fn ruby_pin_spec_l10_d1_pins() bool {
	mut packages := [brew_cmd.PinPackageState{
		kind: .formula
		full_name: 'testball'
		version: '1.0'
		installed: true
		pinnable: true
	}]
	result := brew_cmd.pin_packages(mut packages)
	pinned_version := packages[0].pinned_version or { '' }
	return !result.failed() && packages[0].pinned && packages[0].pin_symlink && pinned_version == '1.0'
}

// Ruby it `it "pins a Cask's version", :cask do` at line 16.
pub fn ruby_pin_spec_l16_d2_pins() bool {
	mut packages := [brew_cmd.PinPackageState{
		kind: .cask
		full_name: 'local-caffeine'
		version: '1.2.3'
		installed: true
		pinnable: true
	}]
	result := brew_cmd.pin_packages(mut packages)
	pinned_version := packages[0].pinned_version or { '' }
	return result.warnings.len == 0 && !result.failed() && packages[0].pinned && pinned_version == '1.2.3'
}

// Ruby it `it "warns when pinning a Cask with auto_updates true", :cask do` at line 28.
pub fn ruby_pin_spec_l28_d3_warns() bool {
	mut packages := [brew_cmd.PinPackageState{
		kind: .cask
		full_name: 'auto-updates'
		version: '2.0'
		auto_updates: true
		installed: true
		pinnable: true
	}]
	result := brew_cmd.pin_packages(mut packages)
	return packages[0].pinned && result.warnings.len == 1 && result.warnings[0].contains('auto-updates has `auto_updates true`') && result.warnings[0].contains('outside Homebrew')
}

// Ruby it `it "fails with an uninstalled Formula" do` at line 39.
pub fn ruby_pin_spec_l39_d4_fails() bool {
	mut packages := [brew_cmd.PinPackageState{
		kind: .formula
		full_name: 'testball'
		version: '1.0'
		installed: false
		pinnable: false
	}]
	result := brew_cmd.pin_packages(mut packages)
	return result.failed() && result.failures == ['testball not installed'] && !packages[0].pinned
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/pin"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Pin do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "pins a Formula's version", :integration_test do
// 11:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 12:
// 13:     expect { brew "pin", "testball" }.to be_a_success
// 14:   end
// 15:
// 16:   it "pins a Cask's version", :cask do
// 17:     cask = Cask::CaskLoader.load("local-caffeine")
// 18:     InstallHelper.stub_cask_installation(cask)
// 19:
// 20:     expect { described_class.new(["--cask", "local-caffeine"]).run }
// 21:       .to not_to_output.to_stderr
// 22:
// 23:     expect(cask).to be_pinned
// 24:     expect(cask.pinned_version).to eq("1.2.3")
// 25:     cask.unpin
// 26:   end
// 27:
// 28:   it "warns when pinning a Cask with auto_updates true", :cask do
// 29:     cask = Cask::CaskLoader.load("auto-updates")
// 30:     InstallHelper.stub_cask_installation(cask)
// 31:
// 32:     expect do
// 33:       described_class.new(["--cask", "auto-updates"]).run
// 34:     end.to output(/auto-updates has `auto_updates true`.*outside Homebrew/).to_stderr
// 35:
// 36:     cask.unpin
// 37:   end
// 38:
// 39:   it "fails with an uninstalled Formula" do
// 40:     package = instance_double(Formula, pinned?: false, pinnable?: false, full_name: "testball")
// 41:     cmd = described_class.new(["testball"])
// 42:     allow(cmd.args.named).to receive(:to_resolved_formulae_to_casks).and_return([[package], []])
// 43:
// 44:     expect { cmd.run }
// 45:       .to output(/testball not installed/).to_stderr
// 46:     expect(Homebrew).to have_failed
// 47:   end
// 48: end
