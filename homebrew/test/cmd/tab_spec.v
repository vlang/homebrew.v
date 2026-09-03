module cmd

import brew_runtime
import homebrew.cmd as cmd_core

fn tab_spec_formula(installed_on_request bool) cmd_core.TabPackageState {
	return cmd_core.TabPackageState{
		kind: .formula
		name: 'foo'
		any_version_installed: true
		tab_exists: true
		installed_on_request: installed_on_request
	}
}

fn tab_spec_cask(installed_on_request bool, tab_exists bool) cmd_core.TabPackageState {
	return cmd_core.TabPackageState{
		kind: .cask
		name: 'local-caffeine'
		any_version_installed: true
		tab_exists: tab_exists
		installed_on_request: installed_on_request
	}
}

// Translated from Homebrew/brew `test/cmd/tab_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `installed_on_request?(formula)` at line 9.
pub fn ruby_tab_spec_l9_d1_installed_on_request(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 {
		args[0]
	} else {
		cmd_core.tab_package_value(tab_spec_formula(false))
	}
	return brew_runtime.bool_value((formula.attribute('installed_on_request') or { 'false' }) == 'true')
}

// Ruby method `cask_installed_on_request?(cask)` at line 15.
pub fn ruby_tab_spec_l15_d2_cask_installed_on_request(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 0 {
		args[0]
	} else {
		cmd_core.tab_package_value(tab_spec_cask(false, false))
	}
	return brew_runtime.bool_value((cask.attribute('installed_on_request') or { 'false' }) == 'true')
}

// Ruby it `it "marks a formula as installed on request", :integration_test do` at line 23.
pub fn ruby_tab_spec_l23_d3_marks(args ...brew_runtime.Value) brew_runtime.Value {
	result := cmd_core.run_tab_command([tab_spec_formula(false)], true) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.packages[0].installed_on_request && result.messages == [
		'foo is now marked as installed on request.',
	])
}

// Ruby it `it "marks or unmarks a cask as installed on request with a missing tab", :cask do` at line 35.
pub fn ruby_tab_spec_l35_d4_marks(args ...brew_runtime.Value) brew_runtime.Value {
	marked := cmd_core.run_tab_command([tab_spec_cask(false, false)], true) or { return brew_runtime.bool_value(false) }
	unmarked := cmd_core.run_tab_command([tab_spec_cask(false, false)], false) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(marked.packages[0].tab_exists && marked.packages[0].installed_on_request && marked.messages == [
		'local-caffeine is now marked as installed on request.',
	] && unmarked.packages[0].tab_exists && !unmarked.packages[0].installed_on_request && unmarked.messages == [
		'local-caffeine is already marked as not installed on request.',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/tab"
// 5: require "cmd/shared_examples/args_parse"
// 6: require "tab"
// 7:
// 8: RSpec.describe Homebrew::Cmd::TabCmd do
// 9:   def installed_on_request?(formula)
// 10:     # `brew` subprocesses can change the tab, invalidating the cached values.
// 11:     Tab.clear_cache
// 12:     Tab.for_formula(formula).installed_on_request
// 13:   end
// 14:
// 15:   def cask_installed_on_request?(cask)
// 16:     # `brew` subprocesses can change the tab, invalidating the cached values.
// 17:     Cask::Tab.clear_cache
// 18:     cask.tab.installed_on_request
// 19:   end
// 20:
// 21:   it_behaves_like "parseable arguments"
// 22:
// 23:   it "marks a formula as installed on request", :integration_test do
// 24:     setup_test_formula "foo",
// 25:                        tab_attributes: { "installed_on_request" => false }
// 26:     foo = Formula["foo"]
// 27:
// 28:     expect { brew "tab", "--installed-on-request", "foo" }
// 29:       .to be_a_success
// 30:       .and output(/foo is now marked as installed on request/).to_stdout
// 31:       .and not_to_output.to_stderr
// 32:     expect(installed_on_request?(foo)).to be true
// 33:   end
// 34:
// 35:   it "marks or unmarks a cask as installed on request with a missing tab", :cask do
// 36:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 37:     InstallHelper.install_with_caskfile(cask)
// 38:     tab_path = cask.metadata_main_container_path/AbstractTab::FILENAME
// 39:
// 40:     expect(tab_path).not_to exist
// 41:
// 42:     cmd = described_class.new(["--installed-on-request", "--cask", cask.token])
// 43:     allow(cmd.args.named).to receive(:to_formulae_to_casks).and_return([[], [cask]])
// 44:     expect { cmd.run }
// 45:       .to output(/local-caffeine is now marked as installed on request/).to_stdout
// 46:       .and not_to_output.to_stderr
// 47:     expect(tab_path).to exist
// 48:     expect(cask_installed_on_request?(cask)).to be true
// 49:
// 50:     tab_path.delete
// 51:     Cask::Tab.clear_cache
// 52:
// 53:     cmd = described_class.new(["--no-installed-on-request", "--cask", cask.token])
// 54:     allow(cmd.args.named).to receive(:to_formulae_to_casks).and_return([[], [cask]])
// 55:     expect { cmd.run }
// 56:       .to output(/local-caffeine is already marked as not installed on request/).to_stdout
// 57:       .and not_to_output.to_stderr
// 58:     expect(tab_path).to exist
// 59:     expect(cask_installed_on_request?(cask)).to be false
// 60:   end
// 61: end
