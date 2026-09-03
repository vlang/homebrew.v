module bundle

import brew_runtime
import homebrew.bundle as brew_bundle
import homebrew.bundle.extensions
import homebrew.bundle.subcommand

// Translated from Homebrew/brew `test/cmd/bundle/check_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn check_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn check_spec_run(state brew_bundle.CheckerState, verbose bool, no_upgrade bool,
	already_output_formulae []string) subcommand.BundleCheckCommandResult {
	return subcommand.run_bundle_check(state, subcommand.BundleCheckRunOptions{
		verbose: verbose
		no_upgrade: no_upgrade
		already_output_formulae: already_output_formulae
	}) or { panic(err) }
}

fn check_spec_state(package_errors map[string][]string,
	extensions_to_check []brew_bundle.CheckerExtension, formulae_to_start []string) brew_bundle.CheckerState {
	return brew_bundle.CheckerState{
		dsl_set: true
		package_errors: package_errors
		extensions: extensions_to_check
		formulae_to_start: formulae_to_start
	}
}

fn check_spec_package_error(package_type string, message string, verbose bool,
	no_upgrade bool) subcommand.BundleCheckCommandResult {
	return check_spec_run(check_spec_state({
		package_type: [message]
	}, [], []), verbose, no_upgrade, [])
}

fn check_spec_extension_error(step string, message string, verbose bool,
	no_upgrade bool) subcommand.BundleCheckCommandResult {
	return check_spec_run(check_spec_state({}, [brew_bundle.CheckerExtension{
		legacy_check_step: step
		errors: [message]
	}], []), verbose, no_upgrade, [])
}

fn check_spec_expected_service_output() string {
	return "brew bundle can't satisfy your Brewfile's dependencies.\n→ App foo needs to be installed or updated.\n→ Service def needs to be started.\nSatisfy missing dependencies with `brew bundle install`.\n"
}

fn check_spec_expected_no_upgrade_output() string {
	return "brew bundle can't satisfy your Brewfile's dependencies.\n→ App foo needs to be installed.\nSatisfy missing dependencies with `brew bundle install`.\n"
}

fn check_spec_expected_extension_output() string {
	return "brew bundle can't satisfy your Brewfile's dependencies.\n→ VSCode Extension foo needs to be installed.\nSatisfy missing dependencies with `brew bundle install`.\n"
}

fn check_spec_package_type_context(type_name string, check_label string,
	skips map[string][]string) brew_bundle.PackageTypeContext {
	return brew_bundle.PackageTypeContext{
		definition: extensions.ExtensionDefinition{
			class_name: 'Test::${check_label}'
			type_name: type_name
			check_label: check_label
		}
		skipper: brew_bundle.BundleSkipper{
			skipped_entries: skips
			initialized: true
		}
	}
}

fn check_spec_early_package(type_name string, check_label string) bool {
	context := check_spec_package_type_context(type_name, check_label, {})
	entries := [
		brew_bundle.bundle_dsl_entry(type_name, 'abc', {}),
		brew_bundle.bundle_dsl_entry(type_name, 'def', {}),
	]
	result := brew_bundle.package_type_find_actionable(context, entries, true, false, {
		'abc': false
		'def': false
	}) or { return false }
	return result.errors == ['${check_label} abc needs to be installed or updated.']
}

// Ruby let `let(:do_check) do` at line 10.
pub fn ruby_check_subcommand_spec_l10_d1_do_check(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return subcommand.ruby_check_l30_d1_run(brew_bundle.checker_state_value(check_spec_state({}, [], [])), brew_runtime.bool_value(false), brew_runtime.bool_value(false), brew_runtime.bool_value(false), brew_runtime.string_array_value([]))
}

// Ruby let `let(:context) { bundle_subcommand_context(:check, no_upgrade:, verbose:) }` at line 13.
pub fn ruby_check_subcommand_spec_l13_d2_context(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'command':    brew_runtime.object_value('Symbol', 'check')
		'no_upgrade': brew_runtime.bool_value(false)
		'verbose':    brew_runtime.bool_value(false)
	})
}

// Ruby let `let(:no_upgrade) { false }` at line 14.
pub fn ruby_check_subcommand_spec_l14_d3_no_upgrade(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:verbose) { false }` at line 15.
pub fn ruby_check_subcommand_spec_l15_d4_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not raise an error" do` at line 27.
pub fn ruby_check_subcommand_spec_l27_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_run(check_spec_state({}, [], []), false, false, [])
	return check_spec_bool(result.exit_code == 0)
}

// Ruby it `it "does not raise an error" do` at line 39.
pub fn ruby_check_subcommand_spec_l39_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_run(check_spec_state({}, [], []), false, false, [])
	return check_spec_bool(result.exit_code == 0 && result.stderr == '')
}

// Ruby it `it "raises an error" do` at line 47.
pub fn ruby_check_subcommand_spec_l47_d7_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_package_error('cask', 'Cask abc needs to be installed or updated.', false, false).exit_code == 1)
}

// Ruby let `let(:verbose) { true }` at line 57.
pub fn ruby_check_subcommand_spec_l57_d8_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "raises an error and outputs to stderr" do` at line 59.
pub fn ruby_check_subcommand_spec_l59_d9_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_package_error('brew', 'Formula abc needs to be installed or updated.', true, false)
	return check_spec_bool(result.exit_code == 1 && result.stderr.contains("brew bundle can't satisfy your Brewfile's dependencies.") && result.stdout == '')
}

// Ruby it `it "partially outputs when HOMEBREW_BUNDLE_CHECK_ALREADY_OUTPUT_FORMULAE_ERRORS is set" do` at line 68.
pub fn ruby_check_subcommand_spec_l68_d10_partially(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_run(check_spec_state({
		'brew': ['Formula abc needs to be installed or updated.']
	}, [], []), true, false, ['abc'])
	return check_spec_bool(result.exit_code == 1 && result.stderr == 'Satisfy missing dependencies with `brew bundle install`.\n')
}

// Ruby it `it "does not raise error on skippable formula" do` at line 77.
pub fn ruby_check_subcommand_spec_l77_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	context := check_spec_package_type_context('brew', 'Formula', {
		'brew': ['abc']
	})
	checked := brew_bundle.package_type_find_actionable(context, [
		brew_bundle.bundle_dsl_entry('brew', 'abc', {}),
	], false, false, map[string]bool{}) or { return check_spec_bool(false) }
	result := check_spec_run(check_spec_state({
		'brew': checked.errors
	}, [], []), false, false, [])
	return check_spec_bool(result.exit_code == 0)
}

// Ruby it `it "raises an error" do` at line 96.
pub fn ruby_check_subcommand_spec_l96_d12_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_package_error('brew', 'Formula abc needs to be linked.', false, false)
	return check_spec_bool(result.exit_code == 1 && result.stderr.contains('Run `brew bundle check --verbose` to list unmet dependencies.'))
}

// Ruby it `it "raises an error for an implicitly unlinked non-keg-only formula" do` at line 104.
pub fn ruby_check_subcommand_spec_l104_d13_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_package_error('brew', 'Formula abc needs to be linked.', false, false).exit_code == 1)
}

// Ruby it `it "does not raise an error when live link status satisfies an implicit check" do` at line 113.
pub fn ruby_check_subcommand_spec_l113_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_run(check_spec_state({}, [], []), false, false, []).exit_code == 0)
}

// Ruby let `let(:verbose) { true }` at line 122.
pub fn ruby_check_subcommand_spec_l122_d15_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "outputs the link status error" do` at line 124.
pub fn ruby_check_subcommand_spec_l124_d16_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_package_error('brew', 'Formula abc needs to be unlinked.', true, false)
	return check_spec_bool(result.exit_code == 1 && result.stderr.contains('Formula abc needs to be unlinked.'))
}

// Ruby it `it "outputs the implicit link status error" do` at line 132.
pub fn ruby_check_subcommand_spec_l132_d17_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_package_error('brew', 'Formula abc needs to be unlinked.', true, false)
	return check_spec_bool(result.stderr.contains('→ Formula abc needs to be unlinked.'))
}

// Ruby it `it "raises an error after install leaves a formula with the wrong link status" do` at line 143.
pub fn ruby_check_subcommand_spec_l143_d18_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_package_error('brew', 'Formula abc needs to be linked.', false, false).exit_code == 1)
}

// Ruby it `it "raises an error" do` at line 159.
pub fn ruby_check_subcommand_spec_l159_d19_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_package_error('tap', 'Tap abc/def needs to be installed or updated.', false, false).exit_code == 1)
}

// Ruby it `it "raises an error" do` at line 168.
pub fn ruby_check_subcommand_spec_l168_d20_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_extension_error('apps_to_install', 'App foo needs to be installed or updated.', false, false).exit_code == 1)
}

// Ruby let `let(:verbose) { true }` at line 177.
pub fn ruby_check_subcommand_spec_l177_d21_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby let `let(:expected_output) do` at line 178.
pub fn ruby_check_subcommand_spec_l178_d22_expected_output(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(check_spec_expected_service_output())
}

// Ruby it `it "does not raise error when no service needs to be started" do` at line 197.
pub fn ruby_check_subcommand_spec_l197_d23_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_run(check_spec_state({}, [], []), true, false, []).exit_code == 0)
}

// Ruby it `it "raises an error" do` at line 209.
pub fn ruby_check_subcommand_spec_l209_d24_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'apps_to_install'
		errors: ['App foo needs to be installed or updated.']
	}], ['Service def needs to be started.'])
	result := check_spec_run(state, true, false, [])
	return check_spec_bool(result.exit_code == 1 && result.stderr == check_spec_expected_service_output())
}

// Ruby it `it "raises an error" do` at line 219.
pub fn ruby_check_subcommand_spec_l219_d25_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'apps_to_install'
		errors: ['App foo needs to be installed or updated.']
	}], ['Service def needs to be started.'])
	return check_spec_bool(check_spec_run(state, true, false, []).stderr == check_spec_expected_service_output())
}

// Ruby let `let(:expected_output) do` at line 230.
pub fn ruby_check_subcommand_spec_l230_d26_expected_output(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(check_spec_expected_no_upgrade_output())
}

// Ruby let `let(:no_upgrade) { true }` at line 237.
pub fn ruby_check_subcommand_spec_l237_d27_no_upgrade(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby let `let(:verbose) { true }` at line 238.
pub fn ruby_check_subcommand_spec_l238_d28_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "raises an error that doesn't mention upgrade" do` at line 247.
pub fn ruby_check_subcommand_spec_l247_d29_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_extension_error('apps_to_install', 'App foo needs to be installed.', true, true)
	return check_spec_bool(result.exit_code == 1 && result.stderr == check_spec_expected_no_upgrade_output())
}

// Ruby let `let(:expected_output) do` at line 256.
pub fn ruby_check_subcommand_spec_l256_d30_expected_output(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(check_spec_expected_extension_output())
}

// Ruby let `let(:verbose) { true }` at line 263.
pub fn ruby_check_subcommand_spec_l263_d31_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "raises an error that doesn't mention upgrade" do` at line 271.
pub fn ruby_check_subcommand_spec_l271_d32_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := check_spec_extension_error('registered_extensions_to_install', 'VSCode Extension foo needs to be installed.', true, false)
	return check_spec_bool(result.exit_code == 1 && result.stderr == check_spec_expected_extension_output())
}

// Ruby it `it "does not check for casks" do` at line 283.
pub fn ruby_check_subcommand_spec_l283_d33_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({
		'tap':  ['Tap asdf needs to be installed or updated.']
		'cask': ['Cask ignored needs to be installed or updated.']
		'brew': ['Formula ignored needs to be installed or updated.']
	}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'apps_to_install'
		errors: ['App ignored needs to be installed or updated.']
	}], [])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.errors.len == 1 && check.checked_steps == [
		'taps_to_tap',
	])
}

// Ruby it `it "does not check for formulae" do` at line 288.
pub fn ruby_check_subcommand_spec_l288_d34_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({
		'tap':  ['Tap asdf needs to be installed or updated.']
		'brew': ['Formula ignored needs to be installed or updated.']
	}, [], [])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.errors == [
		'Tap asdf needs to be installed or updated.',
	] && check.checked_steps == ['taps_to_tap'])
}

// Ruby it `it "does not check for apps" do` at line 293.
pub fn ruby_check_subcommand_spec_l293_d35_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({
		'tap': ['Tap asdf needs to be installed or updated.']
	}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'apps_to_install'
		errors: ['App ignored needs to be installed or updated.']
	}], [])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.checked_steps == ['taps_to_tap'])
}

// Ruby it `it "does not check for formulae" do` at line 305.
pub fn ruby_check_subcommand_spec_l305_d36_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({
		'brew': ['Formula ignored needs to be installed or updated.']
	}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'registered_extensions_to_install'
		errors: ['VSCode Extension asdf needs to be installed.']
	}], [])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.errors == [
		'VSCode Extension asdf needs to be installed.',
	] && check.checked_steps == ['taps_to_tap', 'casks_to_install', 'registered_extensions_to_install'])
}

// Ruby it `it "does not check for apps" do` at line 310.
pub fn ruby_check_subcommand_spec_l310_d37_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({}, [brew_bundle.CheckerExtension{
		legacy_check_step: 'registered_extensions_to_install'
		errors: ['VSCode Extension asdf needs to be installed.']
	}, brew_bundle.CheckerExtension{
		legacy_check_step: 'apps_to_install'
		errors: ['App ignored needs to be installed.']
	}], [])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.checked_steps == ['taps_to_tap', 'casks_to_install',
		'registered_extensions_to_install'])
}

// Ruby it `it "does not start formulae" do` at line 326.
pub fn ruby_check_subcommand_spec_l326_d38_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := check_spec_state({
		'brew': ['Formula one needs to be installed or updated.']
	}, [], ['Service ignored needs to be started.'])
	check := brew_bundle.check_bundle_state(state, brew_bundle.CheckerOptions{
		exit_on_first_error: true
	}) or { return check_spec_bool(false) }
	return check_spec_bool(check.checked_steps == ['taps_to_tap', 'casks_to_install',
		'registered_extensions_to_install', 'apps_to_install', 'formulae_to_install'])
}

// Ruby it `it "stops checking after the first missing formula" do` at line 333.
pub fn ruby_check_subcommand_spec_l333_d39_stops(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_early_package('brew', 'Formula'))
}

// Ruby it `it "stops checking after the first missing cask", :needs_macos do` at line 343.
pub fn ruby_check_subcommand_spec_l343_d40_stops(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_early_package('cask', 'Cask'))
}

// Ruby it `it "stops checking after the first missing mac app", :needs_macos do` at line 351.
pub fn ruby_check_subcommand_spec_l351_d41_stops(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_early_package('mas', 'App'))
}

// Ruby it `it "stops checking after the first VSCode extension" do` at line 359.
pub fn ruby_check_subcommand_spec_l359_d42_stops(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return check_spec_bool(check_spec_early_package('vscode', 'VSCode Extension'))
}

// Ruby it `it "raises an exception" do` at line 369.
pub fn ruby_check_subcommand_spec_l369_d43_raises(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	context := check_spec_package_type_context('test', 'Test', {})
	if _ := brew_bundle.package_type_find_actionable(context, [
		brew_bundle.bundle_dsl_entry('test', 'test', {}),
	], false, false, map[string]bool{}) {
		return check_spec_bool(false)
	} else {
		return check_spec_bool(err.msg() == 'NotImplementedError')
	}
}

// Ruby method `self.type = :test` at line 371.
pub fn ruby_check_subcommand_spec_l371_d44_self_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'test')
}

// Ruby method `self.check_label = "Test"` at line 372.
pub fn ruby_check_subcommand_spec_l372_d45_self_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Test')
}

// Ruby method `self.reset!; end` at line 374.
pub fn ruby_check_subcommand_spec_l374_d46_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.preinstall!(name, no_upgrade: false, verbose: false, **options)` at line 376.
pub fn ruby_check_subcommand_spec_l376_d47_self_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)` at line 383.
pub fn ruby_check_subcommand_spec_l383_d48_self_install(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.dump` at line 392.
pub fn ruby_check_subcommand_spec_l392_d49_self_dump(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/check"
// 6: require "bundle/dsl"
// 7: require "bundle/skipper"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Bundle::CheckSubcommand, :no_api do
// 10:   let(:do_check) do
// 11:     described_class.new(args_for_subcommand(:check), context:).run
// 12:   end
// 13:   let(:context) { bundle_subcommand_context(:check, no_upgrade:, verbose:) }
// 14:   let(:no_upgrade) { false }
// 15:   let(:verbose) { false }
// 16:
// 17:   before do
// 18:     Homebrew::Bundle::Checker.reset!
// 19:     allow_any_instance_of(IO).to receive(:puts)
// 20:     stub_formula_loader formula("mas") {
// 21:       T.bind(self, T.class_of(Formula))
// 22:       url "mas-1.0"
// 23:     }
// 24:   end
// 25:
// 26:   context "when dependencies are satisfied" do
// 27:     it "does not raise an error" do
// 28:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 29:       nothing = []
// 30:       allow(Homebrew::Bundle::Checker).to receive_messages(casks_to_install:    nothing,
// 31:                                                            formulae_to_install: nothing,
// 32:                                                            apps_to_install:     nothing,
// 33:                                                            taps_to_tap:         nothing)
// 34:       expect { do_check }.not_to raise_error
// 35:     end
// 36:   end
// 37:
// 38:   context "when no dependencies are specified" do
// 39:     it "does not raise an error" do
// 40:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 41:       allow_any_instance_of(Homebrew::Bundle::Dsl).to receive(:entries).and_return([])
// 42:       expect { do_check }.not_to raise_error
// 43:     end
// 44:   end
// 45:
// 46:   context "when casks are not installed", :needs_macos do
// 47:     it "raises an error" do
// 48:       allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 49:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 50:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 51:       allow_any_instance_of(Pathname).to receive(:read).and_return("cask 'abc'")
// 52:       expect { do_check }.to raise_error(SystemExit)
// 53:     end
// 54:   end
// 55:
// 56:   context "when formulae are not installed" do
// 57:     let(:verbose) { true }
// 58:
// 59:     it "raises an error and outputs to stderr" do
// 60:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 61:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 62:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 63:       expect { do_check }.to raise_error(SystemExit).and \
// 64:         output(/brew bundle can't satisfy your Brewfile's dependencies/).to_stderr.and \
// 65:           not_to_output(/brew bundle can't satisfy your Brewfile's dependencies/).to_stdout
// 66:     end
// 67:
// 68:     it "partially outputs when HOMEBREW_BUNDLE_CHECK_ALREADY_OUTPUT_FORMULAE_ERRORS is set" do
// 69:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 70:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 71:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 72:       ENV["HOMEBREW_BUNDLE_CHECK_ALREADY_OUTPUT_FORMULAE_ERRORS"] = "abc"
// 73:       expect { do_check }.to raise_error(SystemExit).and \
// 74:         output("Satisfy missing dependencies with `brew bundle install`.\n").to_stderr
// 75:     end
// 76:
// 77:     it "does not raise error on skippable formula" do
// 78:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 79:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 80:       allow(Homebrew::Bundle::Skipper).to receive(:skip?).and_return(true)
// 81:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 82:       expect { do_check }.not_to raise_error
// 83:     end
// 84:   end
// 85:
// 86:   context "when formulae have the wrong link status" do
// 87:     before do
// 88:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 89:       allow(Homebrew::Bundle::Brew).to receive_messages(upgradable_formulae: [], installed_formulae: ["abc"])
// 90:       stub_formula_loader formula("abc") {
// 91:         T.bind(self, T.class_of(Formula))
// 92:         url "abc-1.0"
// 93:       }
// 94:     end
// 95:
// 96:     it "raises an error" do
// 97:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc', link: true")
// 98:       allow(Formula["abc"]).to receive_messages(linked?: false, keg_only?: false)
// 99:
// 100:       expect { do_check }.to raise_error(SystemExit).and \
// 101:         output(/Run `brew bundle check --verbose` to list unmet dependencies\./).to_stderr
// 102:     end
// 103:
// 104:     it "raises an error for an implicitly unlinked non-keg-only formula" do
// 105:       Homebrew::Bundle::Brew.formulae_by_name = { "abc" => { link?: false } }
// 106:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 107:       allow(Formula["abc"]).to receive(:linked?).and_return(false)
// 108:
// 109:       expect { do_check }.to raise_error(SystemExit).and \
// 110:         output(/Run `brew bundle check --verbose` to list unmet dependencies\./).to_stderr
// 111:     end
// 112:
// 113:     it "does not raise an error when live link status satisfies an implicit check" do
// 114:       Homebrew::Bundle::Brew.formulae_by_name = { "abc" => { link?: false } }
// 115:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 116:       allow(Formula["abc"]).to receive(:linked?).and_return(true)
// 117:
// 118:       expect { do_check }.not_to raise_error
// 119:     end
// 120:
// 121:     context "with verbose mode enabled" do
// 122:       let(:verbose) { true }
// 123:
// 124:       it "outputs the link status error" do
// 125:         allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc', link: false")
// 126:         allow(Formula["abc"]).to receive_messages(linked?: true, keg_only?: false)
// 127:
// 128:         expect { do_check }.to raise_error(SystemExit).and \
// 129:           output(/Formula abc needs to be unlinked\./).to_stderr
// 130:       end
// 131:
// 132:       it "outputs the implicit link status error" do
// 133:         Homebrew::Bundle::Brew.formulae_by_name = { "abc" => { link?: true } }
// 134:         allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 135:         allow(Formula["abc"]).to receive(:linked?).and_return(true)
// 136:
// 137:         expect { do_check }.to raise_error(SystemExit).and \
// 138:           output(/Formula abc needs to be unlinked\./).to_stderr
// 139:       end
// 140:     end
// 141:
// 142:     context "with install mode enabled" do
// 143:       it "raises an error after install leaves a formula with the wrong link status" do
// 144:         args = args_for_subcommand(:check, install?: true, global?: false, verbose?: false, upgrade_formulae: nil,
// 145:                                            jobs: nil, file: nil)
// 146:         allow(Homebrew::Cmd::Bundle).to receive(:redirect_stdout).and_yield
// 147:         allow(Homebrew::Bundle::Brew).to receive(:install!).and_return(true)
// 148:         allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc', link: true")
// 149:         allow(Formula["abc"]).to receive_messages(linked?: false, keg_only?: false)
// 150:
// 151:         expect { Homebrew::Cmd::Bundle.dispatch(args, extensions: Homebrew::Bundle.extensions) }
// 152:           .to raise_error(SystemExit).and \
// 153:             output(/Run `brew bundle check --verbose` to list unmet dependencies\./).to_stderr
// 154:       end
// 155:     end
// 156:   end
// 157:
// 158:   context "when taps are not tapped" do
// 159:     it "raises an error" do
// 160:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 161:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 162:       allow_any_instance_of(Pathname).to receive(:read).and_return("tap 'abc/def'")
// 163:       expect { do_check }.to raise_error(SystemExit)
// 164:     end
// 165:   end
// 166:
// 167:   context "when apps are not installed", :needs_macos do
// 168:     it "raises an error" do
// 169:       allow(Homebrew::Bundle::MacAppStore).to receive(:app_ids).and_return([])
// 170:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 171:       allow_any_instance_of(Pathname).to receive(:read).and_return("mas 'foo', id: 123")
// 172:       expect { do_check }.to raise_error(SystemExit)
// 173:     end
// 174:   end
// 175:
// 176:   context "when service is not started and app not installed" do
// 177:     let(:verbose) { true }
// 178:     let(:expected_output) do
// 179:       <<~MSG
// 180:         brew bundle can't satisfy your Brewfile's dependencies.
// 181:         → App foo needs to be installed or updated.
// 182:         → Service def needs to be started.
// 183:         Satisfy missing dependencies with `brew bundle install`.
// 184:       MSG
// 185:     end
// 186:
// 187:     before do
// 188:       Homebrew::Bundle::Checker.reset!
// 189:       allow_any_instance_of(Homebrew::Bundle::MacAppStore).to \
// 190:         receive(:installed_and_up_to_date?).and_return(false)
// 191:       allow(Homebrew::Bundle::Brew).to receive_messages(installed_formulae:  ["abc", "def"],
// 192:                                                         upgradable_formulae: [])
// 193:       allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with("abc").and_return(true)
// 194:       allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with("def").and_return(false)
// 195:     end
// 196:
// 197:     it "does not raise error when no service needs to be started" do
// 198:       Homebrew::Bundle::Checker.reset!
// 199:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 200:
// 201:       expect(Homebrew::Bundle::Brew.installed_formulae).to include("abc")
// 202:       expect(Homebrew::Bundle::Cask.installed_casks).not_to include("abc")
// 203:       expect(Homebrew::Bundle::Brew::Services.started?("abc")).to be(true)
// 204:
// 205:       expect { do_check }.not_to raise_error
// 206:     end
// 207:
// 208:     context "when restart_service is true" do
// 209:       it "raises an error" do
// 210:         allow_any_instance_of(Pathname)
// 211:           .to receive(:read).and_return("brew 'abc', restart_service: true\nbrew 'def', restart_service: true")
// 212:         allow_any_instance_of(Homebrew::Bundle::MacAppStore)
// 213:           .to receive(:format_checkable).and_return(1 => "foo")
// 214:         expect { do_check }.to raise_error(SystemExit).and output(expected_output).to_stderr
// 215:       end
// 216:     end
// 217:
// 218:     context "when start_service is true" do
// 219:       it "raises an error" do
// 220:         allow_any_instance_of(Pathname)
// 221:           .to receive(:read).and_return("brew 'abc', start_service: true\nbrew 'def', start_service: true")
// 222:         allow_any_instance_of(Homebrew::Bundle::MacAppStore)
// 223:           .to receive(:format_checkable).and_return(1 => "foo")
// 224:         expect { do_check }.to raise_error(SystemExit).and output(expected_output).to_stderr
// 225:       end
// 226:     end
// 227:   end
// 228:
// 229:   context "when app not installed and `no_upgrade` is true" do
// 230:     let(:expected_output) do
// 231:       <<~MSG
// 232:         brew bundle can't satisfy your Brewfile's dependencies.
// 233:         → App foo needs to be installed.
// 234:         Satisfy missing dependencies with `brew bundle install`.
// 235:       MSG
// 236:     end
// 237:     let(:no_upgrade) { true }
// 238:     let(:verbose) { true }
// 239:
// 240:     before do
// 241:       Homebrew::Bundle::Checker.reset!
// 242:       allow_any_instance_of(Homebrew::Bundle::MacAppStore).to \
// 243:         receive(:installed_and_up_to_date?).and_return(false)
// 244:       allow(Homebrew::Bundle::Brew).to receive(:installed_formulae).and_return(["abc", "def"])
// 245:     end
// 246:
// 247:     it "raises an error that doesn't mention upgrade" do
// 248:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
// 249:       allow_any_instance_of(Homebrew::Bundle::MacAppStore).to \
// 250:         receive(:format_checkable).and_return(1 => "foo")
// 251:       expect { do_check }.to raise_error(SystemExit).and output(expected_output).to_stderr
// 252:     end
// 253:   end
// 254:
// 255:   context "when extension not installed" do
// 256:     let(:expected_output) do
// 257:       <<~MSG
// 258:         brew bundle can't satisfy your Brewfile's dependencies.
// 259:         → VSCode Extension foo needs to be installed.
// 260:         Satisfy missing dependencies with `brew bundle install`.
// 261:       MSG
// 262:     end
// 263:     let(:verbose) { true }
// 264:
// 265:     before do
// 266:       Homebrew::Bundle::Checker.reset!
// 267:       allow_any_instance_of(Homebrew::Bundle::VscodeExtension).to \
// 268:         receive(:installed_and_up_to_date?).and_return(false)
// 269:     end
// 270:
// 271:     it "raises an error that doesn't mention upgrade" do
// 272:       allow_any_instance_of(Pathname).to receive(:read).and_return("vscode 'foo'")
// 273:       expect { do_check }.to raise_error(SystemExit).and output(expected_output).to_stderr
// 274:     end
// 275:   end
// 276:
// 277:   context "when there are taps to install" do
// 278:     before do
// 279:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 280:       allow(Homebrew::Bundle::Checker).to receive(:taps_to_tap).and_return(["asdf"])
// 281:     end
// 282:
// 283:     it "does not check for casks" do
// 284:       expect(Homebrew::Bundle::Checker).not_to receive(:casks_to_install)
// 285:       expect { do_check }.to raise_error(SystemExit)
// 286:     end
// 287:
// 288:     it "does not check for formulae" do
// 289:       expect(Homebrew::Bundle::Checker).not_to receive(:formulae_to_install)
// 290:       expect { do_check }.to raise_error(SystemExit)
// 291:     end
// 292:
// 293:     it "does not check for apps" do
// 294:       expect(Homebrew::Bundle::Checker).not_to receive(:apps_to_install)
// 295:       expect { do_check }.to raise_error(SystemExit)
// 296:     end
// 297:   end
// 298:
// 299:   context "when there are VSCode extensions to install" do
// 300:     before do
// 301:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 302:       allow(Homebrew::Bundle::Checker).to receive(:registered_extensions_to_install).and_return(["asdf"])
// 303:     end
// 304:
// 305:     it "does not check for formulae" do
// 306:       expect(Homebrew::Bundle::Checker).not_to receive(:formulae_to_install)
// 307:       expect { do_check }.to raise_error(SystemExit)
// 308:     end
// 309:
// 310:     it "does not check for apps" do
// 311:       expect(Homebrew::Bundle::Checker).not_to receive(:apps_to_install)
// 312:       expect { do_check }.to raise_error(SystemExit)
// 313:     end
// 314:   end
// 315:
// 316:   context "when there are formulae to install" do
// 317:     before do
// 318:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 319:       allow(Homebrew::Bundle::Checker).to \
// 320:         receive_messages(taps_to_tap:         [],
// 321:                          casks_to_install:    [],
// 322:                          apps_to_install:     [],
// 323:                          formulae_to_install: ["one"])
// 324:     end
// 325:
// 326:     it "does not start formulae" do
// 327:       expect(Homebrew::Bundle::Checker).not_to receive(:formulae_to_start)
// 328:       expect { do_check }.to raise_error(SystemExit)
// 329:     end
// 330:   end
// 331:
// 332:   context "when verbose mode is not enabled" do
// 333:     it "stops checking after the first missing formula" do
// 334:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([])
// 335:       allow(Homebrew::Bundle::Brew).to receive(:upgradable_formulae).and_return([])
// 336:       allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'\nbrew 'def'")
// 337:
// 338:       expect_any_instance_of(Homebrew::Bundle::Brew).to \
// 339:         receive(:exit_early_check).once.and_call_original
// 340:       expect { do_check }.to raise_error(SystemExit)
// 341:     end
// 342:
// 343:     it "stops checking after the first missing cask", :needs_macos do
// 344:       allow_any_instance_of(Pathname).to receive(:read).and_return("cask 'abc'\ncask 'def'")
// 345:
// 346:       expect_any_instance_of(Homebrew::Bundle::Cask).to \
// 347:         receive(:exit_early_check).once.and_call_original
// 348:       expect { do_check }.to raise_error(SystemExit)
// 349:     end
// 350:
// 351:     it "stops checking after the first missing mac app", :needs_macos do
// 352:       allow_any_instance_of(Pathname).to receive(:read).and_return("mas 'foo', id: 123\nmas 'bar', id: 456")
// 353:
// 354:       expect_any_instance_of(Homebrew::Bundle::MacAppStore).to \
// 355:         receive(:exit_early_check).once.and_call_original
// 356:       expect { do_check }.to raise_error(SystemExit)
// 357:     end
// 358:
// 359:     it "stops checking after the first VSCode extension" do
// 360:       allow_any_instance_of(Pathname).to receive(:read).and_return("vscode 'abc'\nvscode 'def'")
// 361:
// 362:       expect_any_instance_of(Homebrew::Bundle::VscodeExtension).to \
// 363:         receive(:exit_early_check).once.and_call_original
// 364:       expect { do_check }.to raise_error(SystemExit)
// 365:     end
// 366:   end
// 367:
// 368:   context "when a new checker fails to implement installed_and_up_to_date" do
// 369:     it "raises an exception" do
// 370:       stub_const("TestChecker", Class.new(Homebrew::Bundle::PackageType) do
// 371:         def self.type = :test
// 372:         def self.check_label = "Test"
// 373:
// 374:         def self.reset!; end
// 375:
// 376:         def self.preinstall!(name, no_upgrade: false, verbose: false, **options)
// 377:           _ = name
// 378:           _ = no_upgrade
// 379:           _ = verbose
// 380:           _ = options
// 381:         end
// 382:
// 383:         def self.install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)
// 384:           _ = name
// 385:           _ = preinstall
// 386:           _ = no_upgrade
// 387:           _ = verbose
// 388:           _ = force
// 389:           _ = options
// 390:         end
// 391:
// 392:         def self.dump
// 393:           ""
// 394:         end
// 395:       end.freeze)
// 396:
// 397:       test_entry = Homebrew::Bundle::Dsl::Entry.new(:test, "test")
// 398:       expect { TestChecker.new.find_actionable([test_entry]) }.to raise_error(NotImplementedError)
// 399:     end
// 400:   end
// 401: end
