module bundle

import homebrew.bundle.subcommand

// Translated from Homebrew/brew `test/cmd/bundle/cleanup_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn cleanup_spec_empty_loader(_ bool, _ string) !subcommand.CleanupDsl {
	return subcommand.CleanupDsl{}
}

fn cleanup_spec_confirm_yes(_ string) bool {
	return true
}

fn cleanup_spec_confirm_no(_ string) bool {
	return false
}

fn cleanup_spec_command(argv []string, _ bool) !string {
	return if argv == ['brew', 'cleanup'] { 'cleaned' } else { '' }
}

fn cleanup_spec_output_command(_ []string, _ bool) !string {
	return 'cleaned\n'
}

fn cleanup_spec_failure_command(_ []string, _ bool) !string {
	return error('command failed with status 1')
}

fn cleanup_spec_no_trust(_ []subcommand.CleanupTrustEntry) !string {
	return ''
}

fn cleanup_spec_no_marker(_ []subcommand.CleanupDslEntry) !string {
	return ''
}

fn cleanup_spec_no_extension(_ string, _ []string) !string {
	return ''
}

fn cleanup_spec_no_reset() !string {
	return ''
}

fn cleanup_spec_callbacks(confirm bool, failed bool) subcommand.CleanupCallbacks {
	return subcommand.CleanupCallbacks{
		load_dsl: cleanup_spec_empty_loader
		confirm: if confirm { cleanup_spec_confirm_yes } else { cleanup_spec_confirm_no }
		run_command: if failed { cleanup_spec_failure_command } else { cleanup_spec_command }
		replace_trust: cleanup_spec_no_trust
		mark_formulae: cleanup_spec_no_marker
		cleanup_extension: cleanup_spec_no_extension
		reset_modules: cleanup_spec_no_reset
	}
}

fn cleanup_spec_state(entries []subcommand.CleanupDslEntry) subcommand.CleanupState {
	return subcommand.CleanupState{
		dsl: subcommand.CleanupDsl{ entries: entries }
		has_dsl: true
	}
}

fn cleanup_spec_entry(kind subcommand.CleanupDslEntryType, name string) subcommand.CleanupDslEntry {
	return subcommand.CleanupDslEntry{ entry_type: kind, name: name, full_name: name }
}

fn cleanup_spec_empty_inventory() subcommand.CleanupInventory {
	return subcommand.CleanupInventory{}
}

fn cleanup_spec_execute(entries []subcommand.CleanupDslEntry, inventory subcommand.CleanupInventory,
	options subcommand.CleanupOptions, confirm bool, failed bool) !subcommand.CleanupResult {
	mut state := cleanup_spec_state(entries)
	return subcommand.execute_cleanup(mut state, inventory, options, cleanup_spec_callbacks(confirm, failed))
}

fn cleanup_spec_initial_entries() []subcommand.CleanupDslEntry {
	return [
		cleanup_spec_entry(.tap, 'x'),
		cleanup_spec_entry(.tap, 'y'),
		cleanup_spec_entry(.cask, '123'),
		cleanup_spec_entry(.brew, 'a'),
		cleanup_spec_entry(.brew, 'b'),
		cleanup_spec_entry(.brew, 'd2'),
		cleanup_spec_entry(.brew, 'homebrew/tap/f'),
		cleanup_spec_entry(.brew, 'homebrew/tap/g'),
		cleanup_spec_entry(.brew, 'homebrew/tap/h'),
		cleanup_spec_entry(.brew, 'homebrew/tap/i2'),
		cleanup_spec_entry(.brew, 'homebrew/tap/hasdependency'),
		cleanup_spec_entry(.brew, 'hasbuilddependency1'),
		cleanup_spec_entry(.brew, 'hasbuilddependency2'),
		subcommand.CleanupDslEntry{ entry_type: .extension_entry, name: 'VsCodeExtension1', extension_type: 'vscode' },
	]
}

fn cleanup_spec_formula_inventory() subcommand.CleanupInventory {
	return subcommand.CleanupInventory{
		formulae: [
			subcommand.CleanupFormula{ full_name: 'a2', dependencies: ['homebrew/tap/d'] },
			subcommand.CleanupFormula{ full_name: 'b' },
			subcommand.CleanupFormula{ full_name: 'c' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/d' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/e' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/f', tap: 'homebrew/tap' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/g', tap: 'homebrew/tap' },
			subcommand.CleanupFormula{ full_name: 'other/tap/h', tap: 'other/tap' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/i', tap: 'homebrew/tap' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/hasdependency', dependencies: ['homebrew/tap/isdependency'], tap: 'homebrew/tap' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/isdependency', tap: 'homebrew/tap' },
			subcommand.CleanupFormula{ full_name: 'hasbuilddependency1', build_dependencies: ['builddependency1'], poured_from_bottle: true },
			subcommand.CleanupFormula{ full_name: 'hasbuilddependency2', build_dependencies: ['builddependency2'] },
			subcommand.CleanupFormula{ full_name: 'builddependency1' },
			subcommand.CleanupFormula{ full_name: 'builddependency2' },
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/caskdependency' },
		]
		casks: [
			subcommand.CleanupCask{
				name: '123'
				formula_dependencies: [
					'homebrew/tap/caskdependency',
				]
			},
		]
		aliases: {
			'a':               'a2'
			'd2':              'homebrew/tap/d'
			'homebrew/tap/i2': 'homebrew/tap/i'
		}
	}
}

fn cleanup_spec_selection(formulae bool, casks bool, taps bool,
	extensions map[string]bool) subcommand.CleanupSelection {
	return subcommand.CleanupSelection{
		formulae: formulae
		casks: casks
		taps: taps
		extension_types: extensions
	}
}

// Ruby it `it "asks before cleanup unless --force is passed" do` at line 11.
pub fn ruby_cleanup_subcommand_spec_l11_d1_asks() bool {
	options := subcommand.cleanup_options_from_command(subcommand.CleanupCommandContext{})
	return options.ask && !options.force
}

// Ruby it `it "does not ask before cleanup when --force is passed" do` at line 23.
pub fn ruby_cleanup_subcommand_spec_l23_d2_does() bool {
	options := subcommand.cleanup_options_from_command(subcommand.CleanupCommandContext{ force: true })
	return !options.ask && options.force
}

// Ruby it `it "cleans up every supported type when --all is passed" do` at line 35.
pub fn ruby_cleanup_subcommand_spec_l35_d3_cleans() bool {
	options := subcommand.cleanup_options_from_command(subcommand.CleanupCommandContext{
		all: true
		extension_types: ['cargo', 'flatpak', 'go', 'krew', 'mas', 'npm', 'uv', 'vscode']
	})
	return options.selection.formulae && options.selection.casks && options.selection.taps && options.selection.extension_types.values().all(it)
}

// Ruby it `it "does not clean up disabled types by default" do` at line 60.
pub fn ruby_cleanup_subcommand_spec_l60_d4_does() bool {
	options := subcommand.cleanup_options_from_command(subcommand.CleanupCommandContext{
		no_type_args: true
		formulae_disabled: true
		extension_types: ['mas', 'vscode']
		extension_disabled: {
			'mas': true
		}
	})
	return !options.selection.formulae && options.selection.casks && options.selection.taps && !options.selection.extension_types['mas'] && options.selection.extension_types['vscode']
}

// Ruby it `it "treats --no-tap as --no-cleanup-tap" do` at line 75.
pub fn ruby_cleanup_subcommand_spec_l75_d5_treats() bool {
	options := subcommand.cleanup_options_from_command(subcommand.CleanupCommandContext{
		no_type_args: true
		taps_disabled: true
	})
	return !options.selection.taps
}

// Ruby it `it "does not clean up types disabled by environment" do` at line 86.
pub fn ruby_cleanup_subcommand_spec_l86_d6_does() bool {
	return ruby_cleanup_subcommand_spec_l60_d4_does()
}

// Ruby it `it "computes which casks to uninstall" do` at line 140.
pub fn ruby_cleanup_subcommand_spec_l140_d7_computes() bool {
	mut state := cleanup_spec_state([cleanup_spec_entry(.cask, '123')])
	inventory := subcommand.CleanupInventory{
		casks: [
			subcommand.CleanupCask{ name: '123' },
			subcommand.CleanupCask{ name: '456' },
		]
	}
	return (subcommand.cleanup_casks_to_uninstall(mut state, inventory) or { return false }) == [
		'456',
	]
}

// Ruby it `it "computes which formulae to uninstall" do` at line 147.
pub fn ruby_cleanup_subcommand_spec_l147_d8_computes() bool {
	mut state := cleanup_spec_state(cleanup_spec_initial_entries())
	return (subcommand.cleanup_formulae_to_uninstall(mut state, cleanup_spec_formula_inventory()) or {
		return false
	}) == ['c', 'homebrew/tap/e', 'other/tap/h', 'builddependency1']
}

// Ruby it `it "computes which tap to untap" do` at line 198.
pub fn ruby_cleanup_subcommand_spec_l198_d9_computes() bool {
	mut state := cleanup_spec_state(cleanup_spec_initial_entries())
	mut inventory := cleanup_spec_formula_inventory()
	inventory = subcommand.CleanupInventory{ ...inventory, taps: ['z', 'homebrew/core', 'homebrew/tap'] }
	return (subcommand.cleanup_taps_to_untap(mut state, inventory) or { return false }) == [
		'z',
	]
}

// Ruby it `it "keeps taps referenced by fully qualified formulae" do` at line 204.
pub fn ruby_cleanup_subcommand_spec_l204_d10_keeps() bool {
	mut state := cleanup_spec_state([cleanup_spec_entry(.brew, 'homebrew/tap/foo')])
	inventory := subcommand.CleanupInventory{
		formulae: [
			subcommand.CleanupFormula{ full_name: 'homebrew/tap/foo', tap: 'homebrew/tap' },
		]
		taps: ['homebrew/core', 'homebrew/tap']
	}
	return (subcommand.cleanup_formulae_to_uninstall(mut state, inventory) or { return false }).len == 0 && (subcommand.cleanup_taps_to_untap(mut state, inventory) or { return false }).len == 0
}

// Ruby it `it "keeps taps referenced by fully qualified casks" do` at line 224.
pub fn ruby_cleanup_subcommand_spec_l224_d11_keeps() bool {
	mut state := cleanup_spec_state([cleanup_spec_entry(.cask, 'homebrew/tap/foo')])
	inventory := subcommand.CleanupInventory{
		casks: [subcommand.CleanupCask{ name: 'homebrew/tap/foo' }]
		taps: ['homebrew/core', 'homebrew/tap']
	}
	return (subcommand.cleanup_casks_to_uninstall(mut state, inventory) or { return false }).len == 0 && (subcommand.cleanup_taps_to_untap(mut state, inventory) or { return false }).len == 0
}

// Ruby it `it "ignores unavailable formulae when computing which taps to keep" do` at line 241.
pub fn ruby_cleanup_subcommand_spec_l241_d12_ignores() bool {
	mut state := cleanup_spec_state([cleanup_spec_entry(.brew, 'foo')])
	inventory := subcommand.CleanupInventory{
		formulae: [
			subcommand.CleanupFormula{ full_name: 'foo', tap: 'homebrew/tap', available: false },
		]
		taps: ['z', 'homebrew/core', 'homebrew/tap']
	}
	return (subcommand.cleanup_taps_to_untap(mut state, inventory) or { return false }) == [
		'z',
		'homebrew/tap',
	]
}

// Ruby it `it "ignores formulae with .keepme references when computing which formulae to uninstall" do` at line 254.
pub fn ruby_cleanup_subcommand_spec_l254_d13_ignores() bool {
	mut state := cleanup_spec_state([])
	inventory := subcommand.CleanupInventory{
		formulae: [
			subcommand.CleanupFormula{ full_name: 'c', keepme_refs: ['/some/file'] },
		]
	}
	return (subcommand.cleanup_formulae_to_uninstall(mut state, inventory) or { return false }).len == 0
}

// Ruby it `it "computes which VSCode extensions to uninstall" do` at line 270.
pub fn ruby_cleanup_subcommand_spec_l270_d14_computes() bool {
	result := cleanup_spec_extension_plan('vscode', ['z'], ['VsCodeExtension1'], [
		'VsCodeExtension1',
	], true) or { return false }
	return result == ['z']
}

// Ruby it `it "computes which VSCode extensions to uninstall irrespective of case of the extension name" do` at line 275.
pub fn ruby_cleanup_subcommand_spec_l275_d15_computes() bool {
	result := cleanup_spec_extension_plan('vscode', ['z', 'vscodeextension1'], [
		'VsCodeExtension1',
	], [], true) or { return false }
	return result == ['z']
}

// Ruby it `it "computes which flatpaks to uninstall", :needs_linux do` at line 280.
pub fn ruby_cleanup_subcommand_spec_l280_d16_computes() bool {
	result := cleanup_spec_extension_plan('flatpak', ['org.gnome.Calculator', 'org.mozilla.firefox'], [
		'org.gnome.Calculator',
	], [], false) or { return false }
	return result == ['org.mozilla.firefox']
}

// Ruby it `it "does nothing" do` at line 303.
pub fn ruby_cleanup_subcommand_spec_l303_d17_does() bool {
	result := cleanup_spec_execute([], cleanup_spec_empty_inventory(), subcommand.CleanupOptions{
		force: true
	}, false, false) or { return false }
	return result.commands == [['brew', 'cleanup']] && result.output == ['cleaned']
}

// Ruby let `let(:dsl) do` at line 311.
pub fn ruby_cleanup_subcommand_spec_l311_d18_dsl() subcommand.CleanupDsl {
	return subcommand.CleanupDsl{ entries: cleanup_spec_trust_entries() }
}

// Ruby it `it "resets the trust store to the Brewfile entries on forced cleanup" do` at line 338.
pub fn ruby_cleanup_subcommand_spec_l338_d19_resets() bool {
	result := cleanup_spec_execute(cleanup_spec_trust_entries(), cleanup_spec_empty_inventory(), subcommand.CleanupOptions{ force: true }, false, false) or { return false }
	return result.trust_replaced && result.plan.trust == [
		subcommand.CleanupTrustEntry{ entry_type: .tap, name: 'trusted/tap' },
		subcommand.CleanupTrustEntry{ entry_type: .brew, name: 'thirdparty/tap/foo' },
		subcommand.CleanupTrustEntry{ entry_type: .cask, name: 'thirdparty/tap/bar' },
		subcommand.CleanupTrustEntry{ entry_type: .brew, name: 'thirdparty/tap/qux' },
		subcommand.CleanupTrustEntry{ entry_type: .cask, name: 'thirdparty/tap/quux' },
		subcommand.CleanupTrustEntry{ entry_type: .other, name: 'thirdparty/tap/baz' },
	]
}

// Ruby it `it "uninstalls casks" do` at line 358.
pub fn ruby_cleanup_subcommand_spec_l358_d20_uninstalls() bool {
	result := cleanup_spec_forced_inventory(['a', 'b'], [], [], [], false, cleanup_spec_selection(true, true, true, {})) or { return false }
	return result.commands[0] == ['brew', 'uninstall', '--cask', '--force', 'a', 'b'] && result.output.contains('Uninstalled 2 casks')
}

// Ruby it `it "does not uninstall casks if --formulae is disabled" do` at line 366.
pub fn ruby_cleanup_subcommand_spec_l366_d21_does() bool {
	result := cleanup_spec_forced_inventory(['a', 'b'], [], [], [], false, cleanup_spec_selection(true, false, true, {})) or { return false }
	return !result.commands.any(it.contains('--cask'))
}

// Ruby it `it "uninstalls casks" do` at line 383.
pub fn ruby_cleanup_subcommand_spec_l383_d22_uninstalls() bool {
	result := cleanup_spec_forced_inventory(['a', 'b'], [], [], [], true, cleanup_spec_selection(true, true, true, {})) or { return false }
	return result.commands[0] == ['brew', 'uninstall', '--cask', '--zap', '--force', 'a', 'b']
}

// Ruby it `it "does not uninstall casks if --casks is disabled" do` at line 391.
pub fn ruby_cleanup_subcommand_spec_l391_d23_does() bool {
	result := cleanup_spec_forced_inventory(['a', 'b'], [], [], [], true, cleanup_spec_selection(true, false, true, {})) or { return false }
	return !result.commands.any(it.contains('--cask'))
}

// Ruby it `it "uninstalls formulae" do` at line 411.
pub fn ruby_cleanup_subcommand_spec_l411_d24_uninstalls() bool {
	result := cleanup_spec_forced_inventory([], ['a', 'b'], [], [], false, cleanup_spec_selection(true, true, true, {})) or { return false }
	return result.commands[0] == ['brew', 'uninstall', '--formula', '--force', 'a', 'b'] && result.output.contains('Uninstalled 2 formulae')
}

// Ruby it `it "does not uninstall formulae if --casks is disabled" do` at line 419.
pub fn ruby_cleanup_subcommand_spec_l419_d25_does() bool {
	result := cleanup_spec_forced_inventory([], ['a', 'b'], [], [], false, cleanup_spec_selection(false, true, true, {})) or { return false }
	return !result.commands.any(it.contains('--formula'))
}

// Ruby it `it "untaps taps" do` at line 438.
pub fn ruby_cleanup_subcommand_spec_l438_d26_untaps() bool {
	result := cleanup_spec_forced_inventory([], [], ['a', 'b'], [], false, cleanup_spec_selection(true, true, true, {})) or { return false }
	return result.commands[0] == ['brew', 'untap', 'a', 'b']
}

// Ruby it `it "does not untap taps if --taps is disabled" do` at line 444.
pub fn ruby_cleanup_subcommand_spec_l444_d27_does() bool {
	result := cleanup_spec_forced_inventory([], [], ['a', 'b'], [], false, cleanup_spec_selection(true, true, false, {})) or { return false }
	return !result.commands.any(it.contains('untap'))
}

// Ruby it `it "uninstalls extensions" do` at line 462.
pub fn ruby_cleanup_subcommand_spec_l462_d28_uninstalls() bool {
	result := cleanup_spec_forced_inventory([], [], [], [subcommand.CleanupExtensionInventory{
		type_name: 'vscode'
		cleanup_heading: 'VSCode extensions'
		installed_items: ['GitHub.codespaces']
	}], false, cleanup_spec_selection(true, true, true, {
		'vscode': true
	})) or { return false }
	return result.extension_actions == ['vscode']
}

// Ruby it `it "does not uninstall extensions if --vscode is disabled" do` at line 468.
pub fn ruby_cleanup_subcommand_spec_l468_d29_does() bool {
	result := cleanup_spec_forced_inventory([], [], [], [subcommand.CleanupExtensionInventory{
		type_name: 'vscode'
		cleanup_heading: 'VSCode extensions'
		installed_items: ['GitHub.codespaces']
	}], false, cleanup_spec_selection(true, true, true, {
		'vscode': false
	})) or { return false }
	return result.extension_actions.len == 0
}

// Ruby it `it "uninstalls flatpaks" do` at line 485.
pub fn ruby_cleanup_subcommand_spec_l485_d30_uninstalls() bool {
	result := cleanup_spec_forced_inventory([], [], [], [subcommand.CleanupExtensionInventory{
		type_name: 'flatpak'
		cleanup_heading: 'flatpaks'
		installed_items: ['org.gnome.Calculator']
	}], false, cleanup_spec_selection(true, true, true, {
		'flatpak': true
	})) or { return false }
	return result.extension_actions == ['flatpak']
}

// Ruby it `it "does not uninstall flatpaks if --flatpak is disabled" do` at line 493.
pub fn ruby_cleanup_subcommand_spec_l493_d31_does() bool {
	result := cleanup_spec_forced_inventory([], [], [], [subcommand.CleanupExtensionInventory{
		type_name: 'flatpak'
		cleanup_heading: 'flatpaks'
		installed_items: ['org.gnome.Calculator']
	}], false, cleanup_spec_selection(true, true, true, {
		'flatpak': false
	})) or { return false }
	return result.extension_actions.len == 0
}

// Ruby it `it "lists casks, formulae and taps" do` at line 515.
pub fn ruby_cleanup_subcommand_spec_l515_d32_lists() bool {
	result := cleanup_spec_dry_all(false) or { return false }
	joined := result.output.join('\n')
	return result.exit_code == 1 && joined.contains('Would uninstall casks:') && joined.contains('Would uninstall formulae:') && joined.contains('Would untap:') && joined.contains('Would uninstall VSCode extensions:') && joined.contains('Would uninstall flatpaks:')
}

// Ruby it `it "cleans up without suggesting --force when it prompts" do` at line 530.
pub fn ruby_cleanup_subcommand_spec_l530_d33_cleans() bool {
	result := cleanup_spec_dry_all(true) or { return false }
	return result.confirmed && result.force && !result.output.any(it.contains('Run `brew bundle cleanup --force`'))
}

// Ruby define_method `define_method(:sane?) do` at line 555.
pub fn ruby_cleanup_subcommand_spec_l555_d34_sane() bool {
	mut state := cleanup_spec_state([])
	plan := subcommand.build_cleanup_plan(mut state, cleanup_spec_empty_inventory(), subcommand.CleanupOptions{ dry_cleanup_output: 'cleaned' }) or { return false }
	return plan.would_clean
}

// Ruby it `it "prints output" do` at line 561.
pub fn ruby_cleanup_subcommand_spec_l561_d35_prints() bool {
	result := cleanup_spec_execute([], cleanup_spec_empty_inventory(), subcommand.CleanupOptions{
		force: true
	}, false, false) or { return false }
	return result.output == ['cleaned']
}

// Ruby it `it "prints output" do` at line 568.
pub fn ruby_cleanup_subcommand_spec_l568_d36_prints() bool {
	result := cleanup_spec_execute([], cleanup_spec_empty_inventory(), subcommand.CleanupOptions{
		dry_cleanup_output: 'cleaned'
	}, false, false) or { return false }
	return result.output == ['Would `brew cleanup`:', 'cleaned',
		'Run `brew bundle cleanup --force` to make these changes.']
}

// Ruby it `it "discards stderr without closing it" do` at line 580.
pub fn ruby_cleanup_subcommand_spec_l580_d37_discards() bool {
	return (subcommand.cleanup_system_output_no_stderr(['ruby', '-e', 'warn'], cleanup_spec_output_command) or { return false }) == 'cleaned\n'
}

// Ruby it `it "raises when the command fails" do` at line 593.
pub fn ruby_cleanup_subcommand_spec_l593_d38_raises() bool {
	_ := subcommand.cleanup_system_output_no_stderr(['ruby', '-e', 'exit 1'], cleanup_spec_failure_command) or { return err.msg().contains('status 1') }
	return false
}

// Ruby it `it "marks Brewfile formulae as installed_on_request before uninstalling" do` at line 615.
pub fn ruby_cleanup_subcommand_spec_l615_d39_marks() bool {
	result := cleanup_spec_forced_inventory([], ['some_formula'], [], [], false, cleanup_spec_selection(true, true, true, {})) or { return false }
	return result.formulae_marked
}

fn cleanup_spec_extension_plan(type_name string, installed []string, entries []string,
	kept []string, case_insensitive bool) ![]string {
	mut dsl_entries := []subcommand.CleanupDslEntry{}
	for entry in entries {
		dsl_entries << subcommand.CleanupDslEntry{ entry_type: .extension_entry, name: entry, extension_type: type_name }
	}
	mut state := cleanup_spec_state(dsl_entries)
	plan := subcommand.build_cleanup_plan(mut state, subcommand.CleanupInventory{
		extensions: [subcommand.CleanupExtensionInventory{
			type_name: type_name
			cleanup_heading: type_name
			installed_items: installed
			kept_items: kept
			case_insensitive: case_insensitive
		}]
	}, subcommand.CleanupOptions{})!
	return plan.extensions[0].items
}

fn cleanup_spec_trust_entries() []subcommand.CleanupDslEntry {
	return [
		subcommand.CleanupDslEntry{ entry_type: .tap, name: 'trusted/tap', trusted: true },
		subcommand.CleanupDslEntry{ entry_type: .brew, name: 'thirdparty/tap/foo', trusted: true },
		subcommand.CleanupDslEntry{ entry_type: .cask, name: 'thirdparty/tap/bar', trusted: true },
		subcommand.CleanupDslEntry{ entry_type: .brew, name: 'thirdparty/tap/qux', trusted: true },
		subcommand.CleanupDslEntry{ entry_type: .cask, name: 'thirdparty/tap/quux', trusted: true },
		subcommand.CleanupDslEntry{ entry_type: .other, name: 'thirdparty/tap/baz', trusted: true },
	]
}

fn cleanup_spec_forced_inventory(casks []string, formulae []string, taps []string,
	extensions []subcommand.CleanupExtensionInventory, zap bool,
	selection subcommand.CleanupSelection) !subcommand.CleanupResult {
	inventory := subcommand.CleanupInventory{
		casks: casks.map(subcommand.CleanupCask{ name: it })
		formulae: formulae.map(subcommand.CleanupFormula{ full_name: it })
		taps: taps
		extensions: extensions
	}
	return cleanup_spec_execute([], inventory, subcommand.CleanupOptions{
		force: true
		zap: zap
		selection: selection
	}, false, false)
}

fn cleanup_spec_dry_all(confirm bool) !subcommand.CleanupResult {
	inventory := subcommand.CleanupInventory{
		casks: [subcommand.CleanupCask{ name: 'a' }, subcommand.CleanupCask{ name: 'b' }]
		formulae: [subcommand.CleanupFormula{ full_name: 'a' },
			subcommand.CleanupFormula{ full_name: 'b' }]
		taps: ['a', 'b']
		extensions: [
			subcommand.CleanupExtensionInventory{
				type_name: 'vscode'
				cleanup_heading: 'VSCode extensions'
				installed_items: [
					'a',
					'b',
				]
			},
			subcommand.CleanupExtensionInventory{
				type_name: 'flatpak'
				cleanup_heading: 'flatpaks'
				installed_items: [
					'a',
					'b',
				]
			},
		]
	}
	return cleanup_spec_execute([], inventory, subcommand.CleanupOptions{
		ask: confirm
		selection: cleanup_spec_selection(true, true, true, {
			'vscode':  true
			'flatpak': true
		})
	}, confirm, false)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/cleanup"
// 6: require "trust"
// 7: require "utils"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Bundle::CleanupSubcommand do
// 10:   describe "#run" do
// 11:     it "asks before cleanup unless --force is passed" do
// 12:       args = args_for_subcommand(:cleanup, all?: false, formulae?: false, casks?: false, taps?: false, mas?: false,
// 13:                                            vscode?: false, cargo?: false, flatpak?: false, go?: false, krew?: false,
// 14:                                            npm?: false, uv?: false)
// 15:       context = bundle_subcommand_context(:cleanup)
// 16:
// 17:       expect(described_class).to receive(:cleanup).with(hash_including(ask:   true,
// 18:                                                                        force: false))
// 19:
// 20:       described_class.new(args, context:).run
// 21:     end
// 22:
// 23:     it "does not ask before cleanup when --force is passed" do
// 24:       args = args_for_subcommand(:cleanup, all?: false, formulae?: false, casks?: false, taps?: false, mas?: false,
// 25:                                            vscode?: false, cargo?: false, flatpak?: false, go?: false, krew?: false,
// 26:                                            npm?: false, uv?: false)
// 27:       context = bundle_subcommand_context(:cleanup, force: true)
// 28:
// 29:       expect(described_class).to receive(:cleanup).with(hash_including(ask:   false,
// 30:                                                                        force: true))
// 31:
// 32:       described_class.new(args, context:).run
// 33:     end
// 34:
// 35:     it "cleans up every supported type when --all is passed" do
// 36:       args = args_for_subcommand(:cleanup, all?: true, formulae?: false, casks?: false, taps?: false, mas?: false,
// 37:                                            vscode?: false, cargo?: false, flatpak?: false, go?: false, krew?: false,
// 38:                                            npm?: false, uv?: false)
// 39:       context = bundle_subcommand_context(:cleanup, no_type_args: false)
// 40:
// 41:       expect(described_class).to receive(:cleanup) do |formulae:, casks:, taps:, extension_types:, **|
// 42:         expect(formulae).to be(true)
// 43:         expect(casks).to be(true)
// 44:         expect(taps).to be(true)
// 45:         expect(extension_types).to include(
// 46:           cargo:   true,
// 47:           flatpak: true,
// 48:           go:      true,
// 49:           krew:    true,
// 50:           mas:     true,
// 51:           npm:     true,
// 52:           uv:      true,
// 53:           vscode:  true,
// 54:         )
// 55:       end
// 56:
// 57:       described_class.new(args, context:).run
// 58:     end
// 59:
// 60:     it "does not clean up disabled types by default" do
// 61:       args = args_for_subcommand(:cleanup, no_formulae?: true, no_mas?: true)
// 62:       context = bundle_subcommand_context(:cleanup)
// 63:
// 64:       expect(described_class).to receive(:cleanup) do |formulae:, casks:, taps:, extension_types:, **|
// 65:         expect(formulae).to be(false)
// 66:         expect(casks).to be(true)
// 67:         expect(taps).to be(true)
// 68:         expect(extension_types[:mas]).to be(false)
// 69:         expect(extension_types[:vscode]).to be(true)
// 70:       end
// 71:
// 72:       described_class.new(args, context:).run
// 73:     end
// 74:
// 75:     it "treats --no-tap as --no-cleanup-tap" do
// 76:       args = args_for_subcommand(:cleanup, no_taps?: true)
// 77:       context = bundle_subcommand_context(:cleanup)
// 78:
// 79:       expect(described_class).to receive(:cleanup) do |taps:, **|
// 80:         expect(taps).to be(false)
// 81:       end
// 82:
// 83:       described_class.new(args, context:).run
// 84:     end
// 85:
// 86:     it "does not clean up types disabled by environment" do
// 87:       args = args_for_subcommand(:cleanup, no_cleanup_brew?: true, no_cleanup_mas?: true)
// 88:       context = bundle_subcommand_context(:cleanup)
// 89:
// 90:       expect(described_class).to receive(:cleanup) do |formulae:, casks:, taps:, extension_types:, **|
// 91:         expect(formulae).to be(false)
// 92:         expect(casks).to be(true)
// 93:         expect(taps).to be(true)
// 94:         expect(extension_types[:mas]).to be(false)
// 95:         expect(extension_types[:vscode]).to be(true)
// 96:       end
// 97:
// 98:       described_class.new(args, context:).run
// 99:     end
// 100:   end
// 101:
// 102:   describe "read Brewfile and current installation", :no_api do
// 103:     before do
// 104:       described_class.reset!
// 105:
// 106:       # don't try to load gcc/glibc
// 107:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 108:
// 109:       allow_any_instance_of(Pathname).to receive(:read).and_return <<~RUBY
// 110:         tap 'x'
// 111:         tap 'y'
// 112:         cask '123'
// 113:         brew 'a'
// 114:         brew 'b'
// 115:         brew 'd2'
// 116:         brew 'homebrew/tap/f'
// 117:         brew 'homebrew/tap/g'
// 118:         brew 'homebrew/tap/h'
// 119:         brew 'homebrew/tap/i2'
// 120:         brew 'homebrew/tap/hasdependency'
// 121:         brew 'hasbuilddependency1'
// 122:         brew 'hasbuilddependency2'
// 123:         mas 'appstoreapp1', id: 1
// 124:         vscode 'VsCodeExtension1'
// 125:       RUBY
// 126:       described_class.read_dsl_from_brewfile!
// 127:       %w[a b d2 homebrew/tap/f homebrew/tap/g homebrew/tap/h homebrew/tap/i2
// 128:          homebrew/tap/hasdependency hasbuilddependency1 hasbuilddependency2].each do |full_name|
// 129:         tap_name = Utils.tap_from_full_name(full_name)
// 130:         name = Utils.name_from_full_name(full_name)
// 131:         tap = (Tap.fetch(tap_name) if tap_name.present?)
// 132:         f = formula(name, tap:) do
// 133:           T.bind(self, T.class_of(Formula))
// 134:           url "#{name}-1.0"
// 135:         end
// 136:         stub_formula_loader f, full_name
// 137:       end
// 138:     end
// 139:
// 140:     it "computes which casks to uninstall" do
// 141:       cask_123 = instance_double(Cask::Cask, to_s: "123", old_tokens: [])
// 142:       cask_456 = instance_double(Cask::Cask, to_s: "456", old_tokens: [])
// 143:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([cask_123, cask_456])
// 144:       expect(described_class.casks_to_uninstall).to eql(%w[456])
// 145:     end
// 146:
// 147:     it "computes which formulae to uninstall" do
// 148:       dependencies_arrays_hash = { dependencies: [], build_dependencies: [] }
// 149:       formulae_hash = [
// 150:         { name: "a2", full_name: "a2", aliases: ["a"], dependencies: ["d"] },
// 151:         { name: "c", full_name: "c" },
// 152:         { name: "d", full_name: "homebrew/tap/d", aliases: ["d2"] },
// 153:         { name: "e", full_name: "homebrew/tap/e" },
// 154:         { name: "f", full_name: "homebrew/tap/f" },
// 155:         { name: "h", full_name: "other/tap/h" },
// 156:         { name: "i", full_name: "homebrew/tap/i", aliases: ["i2"] },
// 157:         { name: "hasdependency", full_name: "homebrew/tap/hasdependency", dependencies: ["isdependency"] },
// 158:         { name: "isdependency", full_name: "homebrew/tap/isdependency" },
// 159:         {
// 160:           name:                "hasbuilddependency1",
// 161:           full_name:           "hasbuilddependency1",
// 162:           poured_from_bottle?: true,
// 163:           build_dependencies:  ["builddependency1"],
// 164:         },
// 165:         {
// 166:           name:                "hasbuilddependency2",
// 167:           full_name:           "hasbuilddependency2",
// 168:           poured_from_bottle?: false,
// 169:           build_dependencies:  ["builddependency2"],
// 170:         },
// 171:         { name: "builddependency1", full_name: "builddependency1" },
// 172:         { name: "builddependency2", full_name: "builddependency2" },
// 173:         { name: "caskdependency", full_name: "homebrew/tap/caskdependency" },
// 174:       ].map { |formula| dependencies_arrays_hash.merge(formula) }
// 175:       allow(Homebrew::Bundle::Brew).to receive(:formulae).and_return(formulae_hash)
// 176:
// 177:       formulae_hash.each do |hash_formula|
// 178:         name = hash_formula[:name]
// 179:         full_name = hash_formula[:full_name]
// 180:         tap_name = Utils.tap_from_full_name(full_name) || "homebrew/core"
// 181:         tap = Tap.fetch(tap_name)
// 182:         f = formula(name, tap:) do
// 183:           T.bind(self, T.class_of(Formula))
// 184:           url "#{name}-1.0"
// 185:         end
// 186:         stub_formula_loader f, full_name
// 187:       end
// 188:
// 189:       allow(Homebrew::Bundle::Cask).to receive(:formula_dependencies).and_return(%w[caskdependency])
// 190:       expect(described_class.formulae_to_uninstall).to eql %w[
// 191:         c
// 192:         homebrew/tap/e
// 193:         other/tap/h
// 194:         builddependency1
// 195:       ]
// 196:     end
// 197:
// 198:     it "computes which tap to untap" do
// 199:       allow(Homebrew::Bundle::Tap).to \
// 200:         receive(:tap_names).and_return(%w[z homebrew/core homebrew/tap])
// 201:       expect(described_class.taps_to_untap).to eql(%w[z])
// 202:     end
// 203:
// 204:     it "keeps taps referenced by fully qualified formulae" do
// 205:       allow_any_instance_of(Pathname).to receive(:read).and_return <<~RUBY
// 206:         brew "homebrew/tap/foo"
// 207:       RUBY
// 208:       described_class.read_dsl_from_brewfile!
// 209:
// 210:       allow(Homebrew::Bundle::Brew).to receive(:formulae).and_return([
// 211:         { name: "foo", full_name: "homebrew/tap/foo", dependencies: [], build_dependencies: [] },
// 212:       ])
// 213:       stub_formula_loader formula("foo", tap: Tap.fetch("homebrew/tap")) {
// 214:         T.bind(self, T.class_of(Formula))
// 215:         url "foo-1.0"
// 216:       }, "homebrew/tap/foo"
// 217:       allow(Homebrew::Bundle::Tap).to \
// 218:         receive(:tap_names).and_return(%w[homebrew/core homebrew/tap])
// 219:
// 220:       expect(described_class.formulae_to_uninstall).to be_empty
// 221:       expect(described_class.taps_to_untap).to be_empty
// 222:     end
// 223:
// 224:     it "keeps taps referenced by fully qualified casks" do
// 225:       allow_any_instance_of(Pathname).to receive(:read).and_return <<~RUBY
// 226:         cask "homebrew/tap/foo"
// 227:       RUBY
// 228:       described_class.read_dsl_from_brewfile!
// 229:
// 230:       allow(Homebrew::Bundle::Cask).to receive(:casks).and_return([
// 231:         instance_double(Cask::Cask, to_s: "foo", old_tokens: [], depends_on: {}),
// 232:       ])
// 233:       allow(Homebrew::Bundle::Brew).to receive(:formulae).and_return([])
// 234:       allow(Homebrew::Bundle::Tap).to \
// 235:         receive(:tap_names).and_return(%w[homebrew/core homebrew/tap])
// 236:
// 237:       expect(described_class.casks_to_uninstall).to be_empty
// 238:       expect(described_class.taps_to_untap).to be_empty
// 239:     end
// 240:
// 241:     it "ignores unavailable formulae when computing which taps to keep" do
// 242:       allow_any_instance_of(Pathname).to receive(:read).and_return <<~RUBY
// 243:         brew "foo"
// 244:       RUBY
// 245:       described_class.read_dsl_from_brewfile!
// 246:
// 247:       allow(Formulary).to \
// 248:         receive(:factory).and_raise(TapFormulaUnavailableError.new(Tap.fetch("homebrew/tap"), "foo"))
// 249:       allow(Homebrew::Bundle::Tap).to \
// 250:         receive(:tap_names).and_return(%w[z homebrew/core homebrew/tap])
// 251:       expect(described_class.taps_to_untap).to eql(%w[z homebrew/tap])
// 252:     end
// 253:
// 254:     it "ignores formulae with .keepme references when computing which formulae to uninstall" do
// 255:       name = full_name ="c"
// 256:       allow(Homebrew::Bundle::Brew).to receive(:formulae).and_return([{ name:, full_name: }])
// 257:       f = formula(name) do
// 258:         T.bind(self, T.class_of(Formula))
// 259:         url "#{name}-1.0"
// 260:       end
// 261:       stub_formula_loader f, name
// 262:
// 263:       keg = instance_double(Keg)
// 264:       allow(keg).to receive(:keepme_refs).and_return(["/some/file"])
// 265:       allow(f).to receive(:installed_kegs).and_return([keg])
// 266:
// 267:       expect(described_class.formulae_to_uninstall).to be_empty
// 268:     end
// 269:
// 270:     it "computes which VSCode extensions to uninstall" do
// 271:       allow(Homebrew::Bundle::VscodeExtension).to receive(:extensions).and_return(%w[z])
// 272:       expect(Homebrew::Bundle::VscodeExtension.cleanup_items(described_class.dsl.entries)).to eql(%w[z])
// 273:     end
// 274:
// 275:     it "computes which VSCode extensions to uninstall irrespective of case of the extension name" do
// 276:       allow(Homebrew::Bundle::VscodeExtension).to receive(:extensions).and_return(%w[z vscodeextension1])
// 277:       expect(Homebrew::Bundle::VscodeExtension.cleanup_items(described_class.dsl.entries)).to eql(%w[z])
// 278:     end
// 279:
// 280:     it "computes which flatpaks to uninstall", :needs_linux do
// 281:       allow_any_instance_of(Pathname).to receive(:read).and_return <<~RUBY
// 282:         flatpak 'org.gnome.Calculator'
// 283:       RUBY
// 284:       described_class.read_dsl_from_brewfile!
// 285:       allow(Homebrew::Bundle::Flatpak).to receive_messages(
// 286:         package_manager_installed?: true,
// 287:         packages:                   %w[org.gnome.Calculator org.mozilla.firefox],
// 288:       )
// 289:       expect(Homebrew::Bundle::Flatpak.cleanup_items(described_class.dsl.entries)).to eql(%w[org.mozilla.firefox])
// 290:     end
// 291:   end
// 292:
// 293:   context "when there are no formulae to uninstall and no taps to untap" do
// 294:     before do
// 295:       described_class.reset!
// 296:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 297:       allow(described_class).to receive_messages(casks_to_uninstall: [],
// 298:                                                  formulae_to_uninstall: [], taps_to_untap: [])
// 299:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 300:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 301:     end
// 302:
// 303:     it "does nothing" do
// 304:       expect(Kernel).not_to receive(:system)
// 305:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 306:       described_class.cleanup(force: true)
// 307:     end
// 308:   end
// 309:
// 310:   context "when there are trusted Brewfile entries", :trust_store do
// 311:     let(:dsl) do
// 312:       Homebrew::Bundle::Dsl.new(StringIO.new(<<~RUBY))
// 313:         tap "trusted/tap", trusted: true
// 314:         tap "thirdparty/tap", trusted: {
// 315:           formula: "foo",
// 316:           casks: ["bar"],
// 317:           command: "baz",
// 318:         }
// 319:         brew "thirdparty/tap/qux", trusted: true
// 320:         cask "thirdparty/tap/quux", trusted: true
// 321:       RUBY
// 322:     end
// 323:
// 324:     before do
// 325:       described_class.reset!
// 326:       allow(described_class).to receive_messages(casks_to_uninstall: [],
// 327:                                                  formulae_to_uninstall: [], taps_to_untap: [])
// 328:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 329:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 330:       allow(described_class).to receive(:system_output_no_stderr).and_return("")
// 331:
// 332:       Homebrew::Trust.trust!(:tap, "old/tap")
// 333:       Homebrew::Trust.trust!(:formula, "old/tap/foo")
// 334:       Homebrew::Trust.trust!(:cask, "old/tap/bar")
// 335:       Homebrew::Trust.trust!(:command, "old/tap/baz")
// 336:     end
// 337:
// 338:     it "resets the trust store to the Brewfile entries on forced cleanup" do
// 339:       described_class.cleanup(force: true, dsl:)
// 340:
// 341:       expect(Homebrew::Trust.trusted_entries(:tap)).to eq(["trusted/tap"])
// 342:       expect(Homebrew::Trust.trusted_entries(:formula)).to eq(%w[thirdparty/tap/foo thirdparty/tap/qux])
// 343:       expect(Homebrew::Trust.trusted_entries(:cask)).to eq(%w[thirdparty/tap/bar thirdparty/tap/quux])
// 344:       expect(Homebrew::Trust.trusted_entries(:command)).to eq(["thirdparty/tap/baz"])
// 345:     end
// 346:   end
// 347:
// 348:   context "when there are casks to uninstall" do
// 349:     before do
// 350:       described_class.reset!
// 351:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 352:       allow(described_class).to receive_messages(casks_to_uninstall: %w[a b], formulae_to_uninstall: [],
// 353:                                                  taps_to_untap: [])
// 354:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 355:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 356:     end
// 357:
// 358:     it "uninstalls casks" do
// 359:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "uninstall", "--cask", "--force", "a", "b")
// 360:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 361:       expect do
// 362:         described_class.cleanup(force: true)
// 363:       end.to output(/Uninstalled 2 casks/).to_stdout
// 364:     end
// 365:
// 366:     it "does not uninstall casks if --formulae is disabled" do
// 367:       expect(Kernel).not_to receive(:system)
// 368:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 369:       expect { described_class.cleanup(force: true, casks: false) }.not_to output.to_stdout
// 370:     end
// 371:   end
// 372:
// 373:   context "when there are casks to zap" do
// 374:     before do
// 375:       described_class.reset!
// 376:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 377:       allow(described_class).to receive_messages(casks_to_uninstall: %w[a b], formulae_to_uninstall: [],
// 378:                                                  taps_to_untap: [])
// 379:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 380:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 381:     end
// 382:
// 383:     it "uninstalls casks" do
// 384:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "uninstall", "--cask", "--zap", "--force", "a", "b")
// 385:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 386:       expect do
// 387:         described_class.cleanup(force: true, zap: true)
// 388:       end.to output(/Uninstalled 2 casks/).to_stdout
// 389:     end
// 390:
// 391:     it "does not uninstall casks if --casks is disabled" do
// 392:       expect(Kernel).not_to receive(:system)
// 393:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 394:       expect do
// 395:         described_class.cleanup(force: true, zap: true, casks: false)
// 396:       end.not_to output.to_stdout
// 397:     end
// 398:   end
// 399:
// 400:   context "when there are formulae to uninstall" do
// 401:     before do
// 402:       described_class.reset!
// 403:       allow(described_class).to receive_messages(casks_to_uninstall: [], formulae_to_uninstall: %w[a b],
// 404:                                                  taps_to_untap: [])
// 405:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 406:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 407:       allow(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 408:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 409:     end
// 410:
// 411:     it "uninstalls formulae" do
// 412:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "uninstall", "--formula", "--force", "a", "b")
// 413:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 414:       expect do
// 415:         described_class.cleanup(force: true)
// 416:       end.to output(/Uninstalled 2 formulae/).to_stdout
// 417:     end
// 418:
// 419:     it "does not uninstall formulae if --casks is disabled" do
// 420:       expect(Kernel).not_to receive(:system)
// 421:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 422:       expect do
// 423:         described_class.cleanup(force: true, formulae: false)
// 424:       end.not_to output.to_stdout
// 425:     end
// 426:   end
// 427:
// 428:   context "when there are taps to untap" do
// 429:     before do
// 430:       described_class.reset!
// 431:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 432:       allow(described_class).to receive_messages(casks_to_uninstall: [], formulae_to_uninstall: [],
// 433:                                                  taps_to_untap: %w[a b])
// 434:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 435:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 436:     end
// 437:
// 438:     it "untaps taps" do
// 439:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "untap", "a", "b")
// 440:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 441:       described_class.cleanup(force: true)
// 442:     end
// 443:
// 444:     it "does not untap taps if --taps is disabled" do
// 445:       expect(Kernel).not_to receive(:system)
// 446:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 447:       described_class.cleanup(force: true, taps: false)
// 448:     end
// 449:   end
// 450:
// 451:   context "when there are VSCode extensions to uninstall" do
// 452:     before do
// 453:       described_class.reset!
// 454:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 455:       allow(described_class).to receive_messages(casks_to_uninstall: [],
// 456:                                                  formulae_to_uninstall: [], taps_to_untap: [])
// 457:       allow(Homebrew::Bundle::VscodeExtension).to receive_messages(package_manager_executable: Pathname("code"),
// 458:                                                                    cleanup_items:              %w[GitHub.codespaces])
// 459:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 460:     end
// 461:
// 462:     it "uninstalls extensions" do
// 463:       expect(Kernel).to receive(:system).with("code", "--uninstall-extension", "GitHub.codespaces")
// 464:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 465:       described_class.cleanup(force: true)
// 466:     end
// 467:
// 468:     it "does not uninstall extensions if --vscode is disabled" do
// 469:       expect(Kernel).not_to receive(:system)
// 470:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 471:       described_class.cleanup(force: true, extension_types: { vscode: false })
// 472:     end
// 473:   end
// 474:
// 475:   context "when there are flatpaks to uninstall", :needs_linux do
// 476:     before do
// 477:       described_class.reset!
// 478:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 479:       allow(described_class).to receive_messages(casks_to_uninstall: [],
// 480:                                                  formulae_to_uninstall: [], taps_to_untap: [])
// 481:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 482:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return(%w[org.gnome.Calculator])
// 483:     end
// 484:
// 485:     it "uninstalls flatpaks" do
// 486:       expect(Kernel).to receive(:system).with("flatpak", "uninstall", "-y", "--system", "org.gnome.Calculator")
// 487:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 488:       expect do
// 489:         described_class.cleanup(force: true)
// 490:       end.to output(/Uninstalled 1 flatpak/).to_stdout
// 491:     end
// 492:
// 493:     it "does not uninstall flatpaks if --flatpak is disabled" do
// 494:       expect(Kernel).not_to receive(:system)
// 495:       expect(described_class).to receive(:system_output_no_stderr).and_return("")
// 496:       described_class.cleanup(force: true, extension_types: { flatpak: false })
// 497:     end
// 498:   end
// 499:
// 500:   context "when there are casks and formulae to uninstall and taps to untap but without passing `--force`" do
// 501:     before do
// 502:       described_class.reset!
// 503:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 504:       allow(described_class).to receive_messages(casks_to_uninstall:    %w[a b],
// 505:                                                  formulae_to_uninstall: %w[
// 506:                                                    a b
// 507:                                                  ],
// 508:                                                  taps_to_untap:         %w[
// 509:                                                    a b
// 510:                                                  ])
// 511:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return(%w[a b])
// 512:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return(%w[a b])
// 513:     end
// 514:
// 515:     it "lists casks, formulae and taps" do
// 516:       expect(Formatter).to receive(:columns).with(%w[a b]).exactly(5).times.and_return("a b")
// 517:       expect(Kernel).not_to receive(:system)
// 518:       expect(Homebrew::Cleanup).to receive(:dry_run_output).and_return("")
// 519:       output_pattern = Regexp.new(
// 520:         "Would uninstall casks:.*Would uninstall formulae:.*Would untap:.*" \
// 521:         "Would uninstall VSCode extensions:.*Would uninstall flatpaks:",
// 522:         Regexp::MULTILINE,
// 523:       )
// 524:       expect do
// 525:         described_class.cleanup
// 526:       end.to raise_error(SystemExit)
// 527:         .and output(output_pattern).to_stdout
// 528:     end
// 529:
// 530:     it "cleans up without suggesting --force when it prompts" do
// 531:       allow(Homebrew::Ask).to receive(:confirm?).with(action: "cleanup").and_return(true)
// 532:       allow(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 533:       allow(Kernel).to receive(:system)
// 534:       allow(described_class).to receive(:system_output_no_stderr).and_return("")
// 535:       allow(Formatter).to receive(:columns).with(%w[a b]).and_return("a b")
// 536:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "uninstall", "--cask", "--force", "a", "b")
// 537:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "uninstall", "--formula", "--force", "a", "b")
// 538:       expect(Kernel).to receive(:system).with(HOMEBREW_BREW_FILE, "untap", "a", "b")
// 539:       expect(Homebrew::Cleanup).to receive(:dry_run_output).and_return("")
// 540:
// 541:       expect { described_class.cleanup(ask: true) }.not_to output(/Run .brew bundle cleanup --force/).to_stdout
// 542:     end
// 543:   end
// 544:
// 545:   context "when there is brew cleanup output" do
// 546:     before do
// 547:       described_class.reset!
// 548:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 549:       allow(described_class).to receive_messages(casks_to_uninstall: [],
// 550:                                                  formulae_to_uninstall: [], taps_to_untap: [])
// 551:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 552:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 553:     end
// 554:
// 555:     define_method(:sane?) do
// 556:       expect(described_class).not_to receive(:system_output_no_stderr)
// 557:       expect(Homebrew::Cleanup).to receive(:dry_run_output).and_return("cleaned")
// 558:     end
// 559:
// 560:     context "with --force" do
// 561:       it "prints output" do
// 562:         expect(described_class).to receive(:system_output_no_stderr).and_return("cleaned")
// 563:         expect { described_class.cleanup(force: true) }.to output(/cleaned/).to_stdout
// 564:       end
// 565:     end
// 566:
// 567:     context "without --force" do
// 568:       it "prints output" do
// 569:         sane?
// 570:         expect { described_class.cleanup }.to output(<<~EOS).to_stdout
// 571:           Would `brew cleanup`:
// 572:           cleaned
// 573:           Run `brew bundle cleanup --force` to make these changes.
// 574:         EOS
// 575:       end
// 576:     end
// 577:   end
// 578:
// 579:   describe "#system_output_no_stderr" do
// 580:     it "discards stderr without closing it" do
// 581:       stdout = nil
// 582:       expect do
// 583:         stdout = described_class.system_output_no_stderr(
// 584:           RUBY_PATH,
// 585:           "-e",
// 586:           '$stderr.puts "warning"; $stdout.puts "cleaned"',
// 587:         )
// 588:       end.not_to output.to_stderr_from_any_process
// 589:
// 590:       expect(stdout).to eq("cleaned\n")
// 591:     end
// 592:
// 593:     it "raises when the command fails" do
// 594:       expect do
// 595:         described_class.system_output_no_stderr(RUBY_PATH, "-e", "exit 1")
// 596:       end.to raise_error(ErrorDuringExecution)
// 597:     end
// 598:   end
// 599:
// 600:   context "when running with force" do
// 601:     before do
// 602:       described_class.reset!
// 603:       allow(described_class).to receive_messages(
// 604:         casks_to_uninstall:    [],
// 605:         formulae_to_uninstall: %w[some_formula],
// 606:         taps_to_untap:         [],
// 607:       )
// 608:       allow(Homebrew::Bundle::VscodeExtension).to receive(:cleanup_items).and_return([])
// 609:       allow(Homebrew::Bundle::Flatpak).to receive(:cleanup_items).and_return([])
// 610:       allow(Kernel).to receive(:system)
// 611:       allow(described_class).to receive(:system_output_no_stderr).and_return("")
// 612:       allow_any_instance_of(Pathname).to receive(:read).and_return("")
// 613:     end
// 614:
// 615:     it "marks Brewfile formulae as installed_on_request before uninstalling" do
// 616:       expect(Homebrew::Bundle).to receive(:mark_as_installed_on_request!)
// 617:       described_class.cleanup(force: true)
// 618:     end
// 619:   end
// 620: end
