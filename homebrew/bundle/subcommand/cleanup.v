module subcommand

import ruby

// Translated from Homebrew/brew `bundle/subcommand/cleanup.rb`.
pub enum CleanupDslEntryType {
	brew
	cask
	tap
	extension_entry
	other
}

pub struct CleanupDslEntry {
pub:
	entry_type     CleanupDslEntryType
	name           string
	full_name      string
	extension_type string
	trusted        bool
}

pub struct CleanupDsl {
pub:
	entries []CleanupDslEntry
	source  string
}

pub struct CleanupFormula {
pub:
	full_name          string
	dependencies       []string
	build_dependencies []string
	poured_from_bottle bool
	keepme_refs        []string
	tap                string
	available          bool = true
}

pub struct CleanupCask {
pub:
	name                 string
	formula_dependencies []string
}

pub struct CleanupExtensionInventory {
pub:
	type_name         string
	cleanup_heading   string
	installed_items   []string
	kept_items        []string
	cleanup_supported bool = true
	case_insensitive  bool
}

pub struct CleanupInventory {
pub:
	formulae      []CleanupFormula
	casks         []CleanupCask
	taps          []string
	aliases       map[string]string
	oldnames      map[string]string
	cask_oldnames map[string]string
	extensions    []CleanupExtensionInventory
}

pub struct CleanupSelection {
pub:
	formulae        bool = true
	casks           bool = true
	taps            bool = true
	extension_types map[string]bool
}

pub struct CleanupOptions {
pub:
	global             bool
	file               string
	force              bool
	zap                bool
	ask                bool
	dry_cleanup_output string
	selection          CleanupSelection = CleanupSelection{}
}

// CleanupCommandContext is the translated view of the subcommand parser/context
// consumed by `run`; extension types are injected from Bundle's registered
// cleanup-capable extensions, preserving their runtime-defined set.
pub struct CleanupCommandContext {
pub:
	force              bool
	zap                bool
	ask                bool
	all                bool
	no_type_args       bool
	formulae_selected  bool
	formulae_disabled  bool
	casks_selected     bool
	casks_disabled     bool
	taps_selected      bool
	taps_disabled      bool
	extension_types    []string
	extension_selected map[string]bool
	extension_disabled map[string]bool
}

pub fn cleanup_options_from_command(context CleanupCommandContext) CleanupOptions {
	mut extension_types := map[string]bool{}
	for extension_type in context.extension_types {
		extension_types[extension_type] = !(context.extension_disabled[extension_type] or { false }) && ((context.extension_selected[extension_type] or { false }) || context.all || context.no_type_args)
	}
	return CleanupOptions{
		force: context.force
		zap: context.zap
		ask: context.ask || !context.force
		selection: CleanupSelection{
			formulae: !context.formulae_disabled && (context.formulae_selected || context.all || context.no_type_args)
			casks: !context.casks_disabled && (context.casks_selected || context.all || context.no_type_args)
			taps: !context.taps_disabled && (context.taps_selected || context.all || context.no_type_args)
			extension_types: extension_types
		}
	}
}

pub struct CleanupState {
pub mut:
	dsl               CleanupDsl
	has_dsl           bool
	kept_formulae     []string
	has_kept_formulae bool
	kept_casks        []string
	has_kept_casks    bool
	checked_formulae  []string
	reset_epoch       int
}

pub struct CleanupExtensionPlan {
pub:
	type_name string
	heading   string
	items     []string
}

pub struct CleanupTrustEntry {
pub:
	entry_type CleanupDslEntryType
	name       string
}

pub struct CleanupPlan {
pub:
	formulae    []string
	casks       []string
	taps        []string
	extensions  []CleanupExtensionPlan
	trust       []CleanupTrustEntry
	would_clean bool
}

pub struct CleanupResult {
pub:
	plan              CleanupPlan
	force             bool
	confirmed         bool
	changed           bool
	exit_code         int
	output            []string
	commands          [][]string
	trust_replaced    bool
	formulae_marked   bool
	extension_actions []string
}

pub type CleanupDslLoader = fn (global bool, file string) !CleanupDsl

pub type CleanupConfirmer = fn (action string) bool

pub type CleanupCommandRunner = fn (argv []string, suppress_stderr bool) !string

pub type CleanupTrustReplacer = fn (entries []CleanupTrustEntry) !string

pub type CleanupFormulaMarker = fn (entries []CleanupDslEntry) !string

pub type CleanupExtensionRunner = fn (type_name string, items []string) !string

pub type CleanupResetter = fn () !string

pub struct CleanupCallbacks {
pub:
	load_dsl          CleanupDslLoader @[required]
	confirm           CleanupConfirmer @[required]
	run_command       CleanupCommandRunner @[required]
	replace_trust     CleanupTrustReplacer @[required]
	mark_formulae     CleanupFormulaMarker @[required]
	cleanup_extension CleanupExtensionRunner @[required]
	reset_modules     CleanupResetter @[required]
}

fn cleanup_no_dsl_loader(_ bool, _ string) !CleanupDsl {
	return error('no Brewfile DSL was provided')
}

fn cleanup_no_confirm(_ string) bool {
	return false
}

fn cleanup_no_command(_ []string, _ bool) !string {
	return ''
}

fn cleanup_no_trust(_ []CleanupTrustEntry) !string {
	return ''
}

fn cleanup_no_marker(_ []CleanupDslEntry) !string {
	return ''
}

fn cleanup_no_extension(_ string, _ []string) !string {
	return ''
}

fn cleanup_no_reset() !string {
	return ''
}

pub fn cleanup_default_callbacks() CleanupCallbacks {
	return CleanupCallbacks{
		load_dsl: cleanup_no_dsl_loader
		confirm: cleanup_no_confirm
		run_command: cleanup_no_command
		replace_trust: cleanup_no_trust
		mark_formulae: cleanup_no_marker
		cleanup_extension: cleanup_no_extension
		reset_modules: cleanup_no_reset
	}
}

fn cleanup_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value == '' || value in seen {
			continue
		}
		seen[value] = true
		result << value
	}
	return result
}

fn cleanup_name_from_full_name(name string) string {
	parts := name.split('/')
	return parts[parts.len - 1]
}

fn cleanup_tap_from_full_name(name string) string {
	parts := name.split('/')
	if parts.len < 3 {
		return ''
	}
	return '${parts[0]}/${parts[1]}'
}

fn cleanup_formula_matches(formula string, kept []string, inventory CleanupInventory) bool {
	if formula in kept || cleanup_name_from_full_name(formula) in kept {
		return true
	}
	old_name := inventory.oldnames[formula] or {
		inventory.oldnames[cleanup_name_from_full_name(formula)] or { '' }
	}
	if old_name != '' && old_name in kept {
		return true
	}
	resolved := inventory.aliases[formula] or { '' }
	return resolved != '' && (resolved in kept || cleanup_name_from_full_name(resolved) in kept)
}

pub fn reset_cleanup_state(mut state CleanupState, resetter CleanupResetter) !string {
	state.dsl = CleanupDsl{}
	state.has_dsl = false
	state.kept_formulae = []
	state.has_kept_formulae = false
	state.kept_casks = []
	state.has_kept_casks = false
	state.checked_formulae = []
	state.reset_epoch++
	return resetter()!
}

pub fn read_cleanup_dsl(mut state CleanupState, injected ?CleanupDsl, global bool, file string,
	loader CleanupDslLoader) !CleanupDsl {
	state.dsl = if dsl := injected { dsl } else { loader(global, file)! }
	state.has_dsl = true
	state.kept_formulae = []
	state.has_kept_formulae = false
	state.kept_casks = []
	state.has_kept_casks = false
	state.checked_formulae = []
	return state.dsl
}

pub fn cleanup_dsl(state CleanupState) ?CleanupDsl {
	if !state.has_dsl {
		return none
	}
	return state.dsl
}

pub fn cleanup_kept_casks(mut state CleanupState, inventory CleanupInventory) ![]string {
	if state.has_kept_casks {
		return state.kept_casks.clone()
	}
	if !state.has_dsl {
		return error('dsl is unset!')
	}
	mut kept := []string{}
	for entry in state.dsl.entries {
		if entry.entry_type != .cask {
			continue
		}
		kept << inventory.cask_oldnames[entry.name] or { entry.name }
	}
	state.kept_casks = cleanup_unique(kept)
	state.has_kept_casks = true
	return state.kept_casks.clone()
}

fn cleanup_formula_by_name(formulae []CleanupFormula, name string) ?CleanupFormula {
	for formula in formulae {
		if formula.full_name == name {
			return formula
		}
	}
	return none
}

fn cleanup_recursive_dependencies_inner(formulae []CleanupFormula, names []string,
	mut checked []string) []string {
	mut dependencies := []string{}
	for name in names {
		if name in checked {
			continue
		}
		formula := cleanup_formula_by_name(formulae, name) or { continue }
		mut formula_dependencies := formula.dependencies.clone()
		if !formula.poured_from_bottle {
			formula_dependencies << formula.build_dependencies
			formula_dependencies = cleanup_unique(formula_dependencies)
		}
		if formula_dependencies.len == 0 {
			continue
		}
		checked << name
		dependencies << formula_dependencies
		dependencies << cleanup_recursive_dependencies_inner(formulae, formula_dependencies, mut checked)
	}
	return cleanup_unique(dependencies)
}

pub fn cleanup_recursive_dependencies(mut state CleanupState, formulae []CleanupFormula,
	names []string) []string {
	state.checked_formulae = []
	return cleanup_recursive_dependencies_inner(formulae, names, mut state.checked_formulae)
}

pub fn cleanup_kept_formulae(mut state CleanupState, inventory CleanupInventory) ![]string {
	if state.has_kept_formulae {
		return state.kept_formulae.clone()
	}
	if !state.has_dsl {
		return error('dsl is unset!')
	}
	mut kept := []string{}
	for entry in state.dsl.entries {
		if entry.entry_type == .brew {
			kept << entry.name
		}
	}
	for kept_cask in cleanup_kept_casks(mut state, inventory)! {
		for cask in inventory.casks {
			if cask.name == kept_cask {
				kept << cask.formula_dependencies
			}
		}
	}
	for index, name in kept {
		kept[index] = inventory.aliases[name] or { inventory.oldnames[name] or { name } }
	}
	kept = cleanup_unique(kept)
	kept << cleanup_recursive_dependencies(mut state, inventory.formulae, kept)
	state.kept_formulae = cleanup_unique(kept)
	state.has_kept_formulae = true
	return state.kept_formulae.clone()
}

pub fn cleanup_casks_to_uninstall(mut state CleanupState, inventory CleanupInventory) ![]string {
	kept := cleanup_kept_casks(mut state, inventory)!
	return inventory.casks.map(it.name).filter(it !in kept)
}

pub fn cleanup_formulae_to_uninstall(mut state CleanupState, inventory CleanupInventory) ![]string {
	kept := cleanup_kept_formulae(mut state, inventory)!
	mut result := []string{}
	for formula in inventory.formulae {
		if cleanup_formula_matches(formula.full_name, kept, inventory) || formula.keepme_refs.len > 0 {
			continue
		}
		result << formula.full_name
	}
	return result
}

pub fn cleanup_lookup_formula(name string, inventory CleanupInventory) ?CleanupFormula {
	formula := cleanup_formula_by_name(inventory.formulae, name) or { return none }
	if !formula.available {
		return none
	}
	return formula
}

pub fn cleanup_taps_to_untap(mut state CleanupState, inventory CleanupInventory) ![]string {
	if !state.has_dsl {
		return error('dsl is unset!')
	}
	mut kept := []string{}
	for entry in state.dsl.entries {
		match entry.entry_type {
			.tap { kept << entry.name }
			.brew { kept << cleanup_tap_from_full_name(entry.name) }
			.cask {
				kept << cleanup_tap_from_full_name(if entry.full_name != '' {
					entry.full_name
				} else {
					entry.name
				})
			}
			else {}
		}
	}
	for name in cleanup_kept_formulae(mut state, inventory)! {
		if formula := cleanup_lookup_formula(name, inventory) {
			kept << formula.tap
		}
	}
	kept = cleanup_unique(kept)
	return inventory.taps.filter(it !in kept && it != 'homebrew/core')
}

fn cleanup_trust_entries(entries []CleanupDslEntry) []CleanupTrustEntry {
	mut result := []CleanupTrustEntry{}
	for entry in entries {
		if entry.trusted {
			name := if entry.full_name != '' { entry.full_name } else { entry.name }
			result << CleanupTrustEntry{entry.entry_type, name}
		}
	}
	return result
}

pub fn build_cleanup_plan(mut state CleanupState, inventory CleanupInventory,
	options CleanupOptions) !CleanupPlan {
	formulae := if options.selection.formulae {
		cleanup_formulae_to_uninstall(mut state, inventory)!
	} else {
		[]string{}
	}
	casks := if options.selection.casks {
		cleanup_casks_to_uninstall(mut state, inventory)!
	} else {
		[]string{}
	}
	taps := if options.selection.taps {
		cleanup_taps_to_untap(mut state, inventory)!
	} else {
		[]string{}
	}
	mut extensions := []CleanupExtensionPlan{}
	for extension in inventory.extensions {
		if !extension.cleanup_supported {
			continue
		}
		selected := options.selection.extension_types[extension.type_name] or { true }
		if !selected {
			continue
		}
		mut kept := extension.kept_items.clone()
		for entry in state.dsl.entries {
			if entry.entry_type == .extension_entry && entry.extension_type == extension.type_name {
				kept << entry.name
			}
		}
		items := if extension.case_insensitive {
			lower_kept := kept.map(it.to_lower())
			extension.installed_items.filter(it.to_lower() !in lower_kept)
		} else {
			extension.installed_items.filter(it !in kept)
		}
		extensions << CleanupExtensionPlan{
			type_name: extension.type_name
			heading: extension.cleanup_heading
			items: items
		}
	}
	return CleanupPlan{
		formulae: formulae
		casks: casks
		taps: taps
		extensions: extensions
		trust: cleanup_trust_entries(state.dsl.entries)
		would_clean: options.dry_cleanup_output.trim_space() != ''
	}
}

fn cleanup_plan_has_uninstalls(plan CleanupPlan) bool {
	return plan.formulae.len > 0 || plan.casks.len > 0 || plan.taps.len > 0 || plan.extensions.any(it.items.len > 0)
}

fn cleanup_plan_output(plan CleanupPlan) []string {
	mut output := []string{}
	if plan.casks.len > 0 {
		output << 'Would uninstall casks:'
		output << plan.casks.join('\n')
	}
	if plan.formulae.len > 0 {
		output << 'Would uninstall formulae:'
		output << plan.formulae.join('\n')
	}
	if plan.taps.len > 0 {
		output << 'Would untap:'
		output << plan.taps.join('\n')
	}
	for extension in plan.extensions {
		if extension.items.len > 0 {
			output << 'Would uninstall ${extension.heading}:'
			output << extension.items.join('\n')
		}
	}
	return output
}

pub fn execute_cleanup(mut state CleanupState, inventory CleanupInventory, options CleanupOptions,
	callbacks CleanupCallbacks) !CleanupResult {
	plan := build_cleanup_plan(mut state, inventory, options)!
	would_uninstall := cleanup_plan_has_uninstalls(plan)
	would_change := would_uninstall || plan.would_clean
	if !options.force {
		mut output := cleanup_plan_output(plan)
		if options.dry_cleanup_output != '' {
			output << 'Would `brew cleanup`:'
			output << options.dry_cleanup_output
		}
		if options.ask && would_change && callbacks.confirm('cleanup') {
			forced_options := CleanupOptions{
				...options
				force: true
			}
			forced := execute_cleanup(mut state, inventory, forced_options, callbacks)!
			return CleanupResult{
				...forced
				confirmed: true
			}
		}
		if would_change {
			output << 'Run `brew bundle cleanup --force` to make these changes.'
		}
		return CleanupResult{
			plan: plan
			changed: would_change
			exit_code: if would_uninstall { 1 } else { 0 }
			output: output
		}
	}

	mut output := []string{}
	mut commands := [][]string{}
	callbacks.replace_trust(plan.trust)!
	if plan.casks.len > 0 {
		mut command := ['brew', 'uninstall', '--cask']
		if options.zap {
			command << '--zap'
		}
		command << '--force'
		command << plan.casks
		commands << command
		callbacks.run_command(command, false)!
		output << 'Uninstalled ${plan.casks.len} cask${if plan.casks.len != 1 { 's' } else { '' }}'
	}
	mut formulae_marked := false
	if plan.formulae.len > 0 {
		callbacks.mark_formulae(state.dsl.entries)!
		formulae_marked = true
		mut command := ['brew', 'uninstall', '--formula', '--force']
		command << plan.formulae
		commands << command
		callbacks.run_command(command, false)!
		output << 'Uninstalled ${plan.formulae.len} formula${if plan.formulae.len != 1 {
			'e'
		} else {
			''
		}}'
	}
	if plan.taps.len > 0 {
		mut command := ['brew', 'untap']
		command << plan.taps
		commands << command
		callbacks.run_command(command, false)!
	}
	mut extension_actions := []string{}
	for extension in plan.extensions {
		if extension.items.len == 0 {
			continue
		}
		callbacks.cleanup_extension(extension.type_name, extension.items)!
		extension_actions << extension.type_name
	}
	cleanup_command := ['brew', 'cleanup']
	commands << cleanup_command
	cleanup_output := callbacks.run_command(cleanup_command, true)!
	if cleanup_output != '' {
		output << cleanup_output
	}
	return CleanupResult{
		plan: plan
		force: true
		changed: would_change
		output: output
		commands: commands
		trust_replaced: true
		formulae_marked: formulae_marked
		extension_actions: extension_actions
	}
}

pub fn run_cleanup(mut state CleanupState, dsl ?CleanupDsl, inventory CleanupInventory,
	options CleanupOptions, callbacks CleanupCallbacks) !CleanupResult {
	read_cleanup_dsl(mut state, dsl, options.global, options.file, callbacks.load_dsl)!
	return execute_cleanup(mut state, inventory, options, callbacks)
}

pub fn cleanup_system_output_no_stderr(argv []string, runner CleanupCommandRunner) !string {
	return runner(argv, true)
}

fn cleanup_real_command(argv []string, _ bool) !string {
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	if result.exit_code != 0 {
		return error('command failed with status ${result.exit_code}')
	}
	return result.stdout
}

fn cleanup_entry_value(entry CleanupDslEntry) ruby.Value {
	return ruby.structured_value('CleanupDslEntry', entry.name, {
		'entry_type':     entry.entry_type.str()
		'name':           entry.name
		'full_name':      entry.full_name
		'extension_type': entry.extension_type
		'trusted':        entry.trusted.str()
	})
}

fn cleanup_entry_from_value(value ruby.Value) CleanupDslEntry {
	entry_type := match value.attributes['entry_type'] or { '' } {
		'brew' { CleanupDslEntryType.brew }
		'cask' { CleanupDslEntryType.cask }
		'tap' { CleanupDslEntryType.tap }
		'extension_entry' { CleanupDslEntryType.extension_entry }
		else { CleanupDslEntryType.other }
	}
	return CleanupDslEntry{
		entry_type: entry_type
		name: value.attributes['name'] or { value.as_string() }
		full_name: value.attributes['full_name'] or { '' }
		extension_type: value.attributes['extension_type'] or { '' }
		trusted: (value.attributes['trusted'] or { 'false' }) == 'true'
	}
}

fn cleanup_formula_value(formula CleanupFormula) ruby.Value {
	return ruby.structured_value('CleanupFormula', formula.full_name, {
		'full_name':          formula.full_name
		'dependencies':       formula.dependencies.join('\x1f')
		'build_dependencies': formula.build_dependencies.join('\x1f')
		'poured_from_bottle': formula.poured_from_bottle.str()
		'keepme_refs':        formula.keepme_refs.join('\x1f')
		'tap':                formula.tap
		'available':          formula.available.str()
	})
}

fn cleanup_strings_attribute(value string) []string {
	return if value == '' { [] } else { value.split('\x1f') }
}

fn cleanup_formula_from_value(value ruby.Value) CleanupFormula {
	return CleanupFormula{
		full_name: value.attributes['full_name'] or { value.as_string() }
		dependencies: cleanup_strings_attribute(value.attributes['dependencies'] or { '' })
		build_dependencies: cleanup_strings_attribute(value.attributes['build_dependencies'] or { '' })
		poured_from_bottle: (value.attributes['poured_from_bottle'] or { 'false' }) == 'true'
		keepme_refs: cleanup_strings_attribute(value.attributes['keepme_refs'] or { '' })
		tap: value.attributes['tap'] or { '' }
		available: (value.attributes['available'] or { 'true' }) == 'true'
	}
}

fn cleanup_plan_value(plan CleanupPlan) ruby.Value {
	return ruby.Value{
		type_name: 'CleanupPlan'
		map_data: {
			'formulae':   ruby.string_array_value(plan.formulae)
			'casks':      ruby.string_array_value(plan.casks)
			'taps':       ruby.string_array_value(plan.taps)
			'extensions': ruby.array_value(plan.extensions.map(fn (extension CleanupExtensionPlan) ruby.Value {
				return ruby.structured_value('CleanupExtensionPlan', extension.type_name, {
					'type_name': extension.type_name
					'heading':   extension.heading
					'items':     extension.items.join('\x1f')
				})
			}))
		}
		attributes: {
			'would_clean': plan.would_clean.str()
		}
	}
}
