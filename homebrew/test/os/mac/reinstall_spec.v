module mac

import brew_runtime
import homebrew.extend.os.mac as reinstall_mac

// Translated from Homebrew/brew `test/os/mac/reinstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula) { instance_double(Formula) }` at line 9.
pub fn ruby_reinstall_spec_l9_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', 'pkgconf', {
		'name': 'pkgconf'
	})
}

// Ruby let `let(:formula_installer) do` at line 10.
pub fn ruby_reinstall_spec_l10_d2_formula_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaInstaller', '#<FormulaInstaller pkgconf>', {
		'formula':       'pkgconf'
		'prelude_fetch': 'true'
		'prelude':       'true'
		'fetch':         'true'
	})
}

// Ruby let `let(:context) { instance_double(Homebrew::Reinstall::InstallationContext, formula_installer:) }` at line 13.
pub fn ruby_reinstall_spec_l13_d3_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Reinstall::InstallationContext', '#<InstallationContext pkgconf>', {
		'formula_installer': 'pkgconf'
	})
}

// Ruby it `it "does nothing" do` at line 22.
pub fn ruby_reinstall_spec_l22_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := reinstall_mac.mac_reinstall_pkgconf_if_needed(reinstall_mac.mac_pkgconf_reinstall_fixture('', 'warning', false), false)
	return brew_runtime.bool_value(!result.mismatch_found && !result.reinstalled && result.warnings.len == 0)
}

// Ruby it `it "prints a warning and does not reinstall" do` at line 31.
pub fn ruby_reinstall_spec_l31_d5_prints(args ...brew_runtime.Value) brew_runtime.Value {
	result := reinstall_mac.mac_reinstall_pkgconf_if_needed(reinstall_mac.mac_pkgconf_reinstall_fixture('mismatch', 'warning', false), true)
	return brew_runtime.bool_value(result.dry_run && !result.reinstalled && result.warnings.len == 1 && result.warnings[0].contains('would be reinstalled'))
}

// Ruby it `it "reinstalls pkgconf and prints success" do` at line 44.
pub fn ruby_reinstall_spec_l44_d6_reinstalls(args ...brew_runtime.Value) brew_runtime.Value {
	result := reinstall_mac.mac_reinstall_pkgconf_if_needed(reinstall_mac.mac_pkgconf_reinstall_fixture('mismatch', 'warning', false), false)
	return brew_runtime.bool_value(result.reinstalled && result.infos.len == 1 && result.infos[0].contains('Reinstalled pkgconf'))
}

// Ruby it `it "rescues and prints the mismatch warning" do` at line 54.
pub fn ruby_reinstall_spec_l54_d7_rescues(args ...brew_runtime.Value) brew_runtime.Value {
	result := reinstall_mac.mac_reinstall_pkgconf_if_needed(reinstall_mac.mac_pkgconf_reinstall_fixture('mismatch', 'warning', true), false)
	return brew_runtime.bool_value(!result.reinstalled && result.failures == ['warning'])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "reinstall"
// 5: require "extend/os/mac/pkgconf"
// 6:
// 7: RSpec.describe Homebrew::Reinstall do
// 8:   describe ".reinstall_pkgconf_if_needed!" do
// 9:     let(:formula) { instance_double(Formula) }
// 10:     let(:formula_installer) do
// 11:       instance_double(FormulaInstaller, formula:, prelude_fetch: true, prelude: true, fetch: true)
// 12:     end
// 13:     let(:context) { instance_double(Homebrew::Reinstall::InstallationContext, formula_installer:) }
// 14:
// 15:     before do
// 16:       allow(Formula).to receive(:[]).with("pkgconf").and_return(formula)
// 17:       allow(Homebrew::Install).to receive(:fetch_formulae).with([formula_installer])
// 18:       allow(described_class).to receive(:build_install_context).and_return(context)
// 19:     end
// 20:
// 21:     context "when there is no macOS SDK mismatch" do
// 22:       it "does nothing" do
// 23:         allow(Homebrew::Pkgconf).to receive(:macos_sdk_mismatch).and_return(nil)
// 24:         expect(described_class).not_to receive(:reinstall_formula)
// 25:
// 26:         described_class.reinstall_pkgconf_if_needed!
// 27:       end
// 28:     end
// 29:
// 30:     context "when dry_run is true" do
// 31:       it "prints a warning and does not reinstall" do
// 32:         allow(Homebrew::Pkgconf).to receive_messages(
// 33:           macos_sdk_mismatch:       :mismatch,
// 34:           mismatch_warning_message: "warning",
// 35:         )
// 36:         expect(described_class).not_to receive(:reinstall_formula)
// 37:         expect(described_class).to receive(:opoo).with(/would be reinstalled/)
// 38:
// 39:         described_class.reinstall_pkgconf_if_needed!(dry_run: true)
// 40:       end
// 41:     end
// 42:
// 43:     context "when there is a mismatch and reinstall succeeds" do
// 44:       it "reinstalls pkgconf and prints success" do
// 45:         allow(Homebrew::Pkgconf).to receive(:macos_sdk_mismatch).and_return(:mismatch)
// 46:         expect(described_class).to receive(:reinstall_formula).with(context)
// 47:         expect(described_class).to receive(:ohai).with(/Reinstalled pkgconf/)
// 48:
// 49:         described_class.reinstall_pkgconf_if_needed!
// 50:       end
// 51:     end
// 52:
// 53:     context "when reinstall_formula raises an error" do
// 54:       it "rescues and prints the mismatch warning" do
// 55:         allow(Homebrew::Pkgconf).to receive_messages(
// 56:           macos_sdk_mismatch:       :mismatch,
// 57:           mismatch_warning_message: "warning",
// 58:         )
// 59:         allow(described_class).to receive(:reinstall_formula).and_raise(RuntimeError)
// 60:
// 61:         expect(described_class).to receive(:ofail).with("warning")
// 62:
// 63:         described_class.reinstall_pkgconf_if_needed!
// 64:       end
// 65:     end
// 66:   end
// 67: end
