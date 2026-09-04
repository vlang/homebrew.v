module shared_examples

import ruby
import homebrew.extend.os.mac as reinstall_mac

// Translated from Homebrew/brew `test/cmd/shared_examples/reinstall_pkgconf_if_needed.rb`.
// The original source is retained below for exact boundary auditing.

pub fn shared_pkgconf_reinstall_case(is_mac bool, mismatch string, warning string, dry_run bool,
	fail bool) reinstall_mac.MacPkgconfReinstallResult {
	if !is_mac {
		return reinstall_mac.MacPkgconfReinstallResult{}
	}
	return reinstall_mac.mac_reinstall_pkgconf_if_needed(reinstall_mac.mac_pkgconf_reinstall_fixture(mismatch, warning, fail), dry_run)
}

// Ruby let `let(:formula) { instance_double(Formula) }` at line 10.
pub fn ruby_reinstall_pkgconf_if_needed_l10_d1_formula(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Formula', 'pkgconf', {
		'name': 'pkgconf'
	})
}

// Ruby let `let(:formula_installer) do` at line 11.
pub fn ruby_reinstall_pkgconf_if_needed_l11_d2_formula_installer(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('FormulaInstaller', '#<FormulaInstaller pkgconf>', {
		'formula':       'pkgconf'
		'prelude_fetch': 'true'
		'prelude':       'true'
		'fetch':         'true'
	})
}

// Ruby let `let(:context) { instance_double(Homebrew::Reinstall::InstallationContext, formula_installer:) }` at line 14.
pub fn ruby_reinstall_pkgconf_if_needed_l14_d3_context(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Homebrew::Reinstall::InstallationContext', '#<InstallationContext pkgconf>', {
		'formula_installer': 'pkgconf'
	})
}

// Ruby it `it "does nothing" do` at line 24.
pub fn ruby_reinstall_pkgconf_if_needed_l24_d4_does(args ...ruby.Value) ruby.Value {
	_ = args
	result := shared_pkgconf_reinstall_case(true, '', 'warning', false, false)
	return ruby.bool_value(!result.mismatch_found && !result.reinstalled
		&& result.warnings.len == 0)
}

// Ruby it `it "prints a warning and does not reinstall" do` at line 33.
pub fn ruby_reinstall_pkgconf_if_needed_l33_d5_prints(args ...ruby.Value) ruby.Value {
	_ = args
	result := shared_pkgconf_reinstall_case(true, '13|14', 'warning', true, false)
	return ruby.bool_value(result.dry_run && !result.reinstalled && result.warnings.len == 1
		&& result.warnings[0].contains('would be reinstalled'))
}

// Ruby it `it "reinstalls pkgconf and prints success" do` at line 46.
pub fn ruby_reinstall_pkgconf_if_needed_l46_d6_reinstalls(args ...ruby.Value) ruby.Value {
	_ = args
	result := shared_pkgconf_reinstall_case(true, '13|14', 'warning', false, false)
	return ruby.bool_value(result.reinstalled && result.infos.len == 1
		&& result.infos[0].contains('Reinstalled pkgconf'))
}

// Ruby it `it "rescues and prints the mismatch warning" do` at line 57.
pub fn ruby_reinstall_pkgconf_if_needed_l57_d7_rescues(args ...ruby.Value) ruby.Value {
	_ = args
	result := shared_pkgconf_reinstall_case(true, '13|14', 'warning', false, true)
	return ruby.bool_value(!result.reinstalled && result.failures == ['warning'])
}

// Ruby it `it "does nothing and does not crash" do` at line 79.
pub fn ruby_reinstall_pkgconf_if_needed_l79_d8_does(args ...ruby.Value) ruby.Value {
	_ = args
	result := shared_pkgconf_reinstall_case(false, '13|14', 'warning', false, false)
	return ruby.bool_value(!result.mismatch_found && !result.reinstalled
		&& result.warnings.len == 0 && result.infos.len == 0 && result.failures.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "reinstall"
// 5: require "formula_installer"
// 6:
// 7: RSpec.shared_examples "reinstall_pkgconf_if_needed" do
// 8:   context "when running on macOS", :needs_macos do
// 9:     describe ".reinstall_pkgconf_if_needed!" do
// 10:       let(:formula) { instance_double(Formula) }
// 11:       let(:formula_installer) do
// 12:         instance_double(FormulaInstaller, formula:, prelude_fetch: true, prelude: true, fetch: true)
// 13:       end
// 14:       let(:context) { instance_double(Homebrew::Reinstall::InstallationContext, formula_installer:) }
// 15:
// 16:       before do
// 17:         allow(OS).to receive(:mac?).and_return(true)
// 18:         allow(Formula).to receive(:[]).with("pkgconf").and_return(formula)
// 19:         allow(Homebrew::Install).to receive(:fetch_formulae).with([formula_installer])
// 20:         allow(Homebrew::Reinstall).to receive(:build_install_context).and_return(context)
// 21:       end
// 22:
// 23:       context "when there is no macOS SDK mismatch" do
// 24:         it "does nothing" do
// 25:           allow(Homebrew::Pkgconf).to receive(:macos_sdk_mismatch).and_return(nil)
// 26:           expect(Homebrew::Reinstall).not_to receive(:reinstall_formula)
// 27:
// 28:           Homebrew::Reinstall.reinstall_pkgconf_if_needed!
// 29:         end
// 30:       end
// 31:
// 32:       context "when dry_run is true" do
// 33:         it "prints a warning and does not reinstall" do
// 34:           allow(Homebrew::Pkgconf).to receive_messages(
// 35:             macos_sdk_mismatch:       %w[13 14],
// 36:             mismatch_warning_message: "warning",
// 37:           )
// 38:           expect(Homebrew::Reinstall).not_to receive(:reinstall_formula)
// 39:           expect(Homebrew::Reinstall).to receive(:opoo).with(/would be reinstalled/)
// 40:
// 41:           Homebrew::Reinstall.reinstall_pkgconf_if_needed!(dry_run: true)
// 42:         end
// 43:       end
// 44:
// 45:       context "when there is a mismatch and reinstall succeeds" do
// 46:         it "reinstalls pkgconf and prints success" do
// 47:           allow(Homebrew::Pkgconf).to receive(:macos_sdk_mismatch).and_return(%w[13 14])
// 48:           expect(Homebrew::Reinstall).to receive(:reinstall_formula).with(context)
// 49:           expect(Homebrew::Reinstall).to receive(:ohai).with(/Reinstalled pkgconf/)
// 50:           allow(Homebrew::Reinstall).to receive(:restore_backup)
// 51:
// 52:           Homebrew::Reinstall.reinstall_pkgconf_if_needed!
// 53:         end
// 54:       end
// 55:
// 56:       context "when reinstall_formula raises an error" do
// 57:         it "rescues and prints the mismatch warning" do
// 58:           allow(Homebrew::Pkgconf).to receive_messages(
// 59:             macos_sdk_mismatch:       %w[13 14],
// 60:             mismatch_warning_message: "warning",
// 61:           )
// 62:           allow(Homebrew::Reinstall).to receive(:reinstall_formula).and_raise(RuntimeError)
// 63:           allow(Homebrew::Reinstall).to receive(:restore_backup)
// 64:           allow(Homebrew::Reinstall).to receive(:backup)
// 65:
// 66:           expect(Homebrew::Reinstall).to receive(:ofail).with("warning")
// 67:
// 68:           Homebrew::Reinstall.reinstall_pkgconf_if_needed!
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73:
// 74:   context "when on a non-macOS platform" do
// 75:     before do
// 76:       allow(OS).to receive(:mac?).and_return(false)
// 77:     end
// 78:
// 79:     it "does nothing and does not crash" do
// 80:       expect(Homebrew::Reinstall).not_to receive(:reinstall_formula)
// 81:
// 82:       expect { Homebrew::Reinstall.reinstall_pkgconf_if_needed! }.not_to raise_error
// 83:     end
// 84:   end
// 85: end
