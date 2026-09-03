module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type CleanupDslLoader = fn(global bool, file string) !CleanupDsl

pub type CleanupConfirmer = fn(action string) bool

pub type CleanupCommandRunner = fn(argv []string, suppress_stderr bool) !string

pub type CleanupTrustReplacer = fn(entries []CleanupTrustEntry) !string

pub type CleanupFormulaMarker = fn(entries []CleanupDslEntry) !string

pub type CleanupExtensionRunner = fn(type_name string, items []string) !string

pub type CleanupResetter = fn() !string

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
	result := brew_runtime.run_captured_command(argv, brew_runtime.CapturedCommandOptions{
		environment: brew_runtime.environment()
	})!
	if result.exit_code != 0 {
		return error('command failed with status ${result.exit_code}')
	}
	return result.stdout
}

fn cleanup_entry_value(entry CleanupDslEntry) brew_runtime.Value {
	return brew_runtime.structured_value('CleanupDslEntry', entry.name, {
		'entry_type':     entry.entry_type.str()
		'name':           entry.name
		'full_name':      entry.full_name
		'extension_type': entry.extension_type
		'trusted':        entry.trusted.str()
	})
}

fn cleanup_entry_from_value(value brew_runtime.Value) CleanupDslEntry {
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

pub fn cleanup_dsl_value(dsl CleanupDsl) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'CleanupDsl'
		repr: dsl.source
		array_data: dsl.entries.map(cleanup_entry_value(it))
		attributes: {
			'source': dsl.source
		}
	}
}

fn cleanup_dsl_from_value(value brew_runtime.Value) CleanupDsl {
	return CleanupDsl{
		entries: value.array_data.map(cleanup_entry_from_value(it))
		source: value.attributes['source'] or { value.as_string() }
	}
}

fn cleanup_formula_value(formula CleanupFormula) brew_runtime.Value {
	return brew_runtime.structured_value('CleanupFormula', formula.full_name, {
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

fn cleanup_formula_from_value(value brew_runtime.Value) CleanupFormula {
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

fn cleanup_string_map_value(values map[string]string) brew_runtime.Value {
	mut mapped := map[string]brew_runtime.Value{}
	for key, value in values {
		mapped[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(mapped)
}

fn cleanup_string_map_from_value(value brew_runtime.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

pub fn cleanup_inventory_value(inventory CleanupInventory) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'CleanupInventory'
		map_data: {
			'formulae':      brew_runtime.array_value(inventory.formulae.map(cleanup_formula_value(it)))
			'casks':         brew_runtime.array_value(inventory.casks.map(fn (cask CleanupCask) brew_runtime.Value {
				return brew_runtime.structured_value('CleanupCask', cask.name, {
					'name':                 cask.name
					'formula_dependencies': cask.formula_dependencies.join('\x1f')
				})
			}))
			'taps':          brew_runtime.string_array_value(inventory.taps)
			'aliases':       cleanup_string_map_value(inventory.aliases)
			'oldnames':      cleanup_string_map_value(inventory.oldnames)
			'cask_oldnames': cleanup_string_map_value(inventory.cask_oldnames)
			'extensions':    brew_runtime.array_value(inventory.extensions.map(fn (extension CleanupExtensionInventory) brew_runtime.Value {
				return brew_runtime.structured_value('CleanupExtensionInventory', extension.type_name, {
					'type_name':         extension.type_name
					'cleanup_heading':   extension.cleanup_heading
					'installed_items':   extension.installed_items.join('\x1f')
					'kept_items':        extension.kept_items.join('\x1f')
					'cleanup_supported': extension.cleanup_supported.str()
					'case_insensitive':  extension.case_insensitive.str()
				})
			}))
		}
	}
}

fn cleanup_inventory_from_value(value brew_runtime.Value) CleanupInventory {
	return CleanupInventory{
		formulae: (value.map_data['formulae'] or { brew_runtime.array_value([]) }).array_data.map(cleanup_formula_from_value(it))
		casks: (value.map_data['casks'] or { brew_runtime.array_value([]) }).array_data.map(fn (item brew_runtime.Value) CleanupCask {
			return CleanupCask{
				name: item.attributes['name'] or { item.as_string() }
				formula_dependencies: cleanup_strings_attribute(item.attributes['formula_dependencies'] or { '' })
			}
		})
		taps: (value.map_data['taps'] or { brew_runtime.string_array_value([]) }).string_array_data
		aliases: cleanup_string_map_from_value(value.map_data['aliases'] or { brew_runtime.map_value({}) })
		oldnames: cleanup_string_map_from_value(value.map_data['oldnames'] or { brew_runtime.map_value({}) })
		cask_oldnames: cleanup_string_map_from_value(value.map_data['cask_oldnames'] or { brew_runtime.map_value({}) })
		extensions: (value.map_data['extensions'] or { brew_runtime.array_value([]) }).array_data.map(fn (item brew_runtime.Value) CleanupExtensionInventory {
			return CleanupExtensionInventory{
				type_name: item.attributes['type_name'] or { item.as_string() }
				cleanup_heading: item.attributes['cleanup_heading'] or { '' }
				installed_items: cleanup_strings_attribute(item.attributes['installed_items'] or { '' })
				kept_items: cleanup_strings_attribute(item.attributes['kept_items'] or { '' })
				cleanup_supported: (item.attributes['cleanup_supported'] or { 'true' }) == 'true'
				case_insensitive: (item.attributes['case_insensitive'] or { 'false' }) == 'true'
			}
		})
	}
}

pub fn cleanup_state_value(state CleanupState) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'CleanupState'
		map_data: {
			'dsl':              cleanup_dsl_value(state.dsl)
			'kept_formulae':    brew_runtime.string_array_value(state.kept_formulae)
			'kept_casks':       brew_runtime.string_array_value(state.kept_casks)
			'checked_formulae': brew_runtime.string_array_value(state.checked_formulae)
		}
		attributes: {
			'has_dsl':           state.has_dsl.str()
			'has_kept_formulae': state.has_kept_formulae.str()
			'has_kept_casks':    state.has_kept_casks.str()
			'reset_epoch':       state.reset_epoch.str()
		}
	}
}

fn cleanup_state_from_value(value brew_runtime.Value) CleanupState {
	return CleanupState{
		dsl: cleanup_dsl_from_value(value.map_data['dsl'] or { cleanup_dsl_value(CleanupDsl{}) })
		has_dsl: (value.attributes['has_dsl'] or { 'false' }) == 'true'
		kept_formulae: (value.map_data['kept_formulae'] or { brew_runtime.string_array_value([]) }).string_array_data
		has_kept_formulae: (value.attributes['has_kept_formulae'] or { 'false' }) == 'true'
		kept_casks: (value.map_data['kept_casks'] or { brew_runtime.string_array_value([]) }).string_array_data
		has_kept_casks: (value.attributes['has_kept_casks'] or { 'false' }) == 'true'
		checked_formulae: (value.map_data['checked_formulae'] or { brew_runtime.string_array_value([]) }).string_array_data
		reset_epoch: (value.attributes['reset_epoch'] or { '0' }).int()
	}
}

pub fn cleanup_options_value(options CleanupOptions) brew_runtime.Value {
	mut extension_values := map[string]brew_runtime.Value{}
	for name, selected in options.selection.extension_types {
		extension_values[name] = brew_runtime.bool_value(selected)
	}
	return brew_runtime.Value{
		type_name: 'CleanupOptions'
		map_data: {
			'extension_types': brew_runtime.map_value(extension_values)
		}
		attributes: {
			'global':             options.global.str()
			'file':               options.file
			'force':              options.force.str()
			'zap':                options.zap.str()
			'ask':                options.ask.str()
			'dry_cleanup_output': options.dry_cleanup_output
			'formulae':           options.selection.formulae.str()
			'casks':              options.selection.casks.str()
			'taps':               options.selection.taps.str()
		}
	}
}

fn cleanup_options_from_value(value brew_runtime.Value) CleanupOptions {
	mut extension_types := map[string]bool{}
	for name, selected in (value.map_data['extension_types'] or { brew_runtime.map_value({}) }).map_data {
		extension_types[name] = selected.bool_data
	}
	return CleanupOptions{
		global: (value.attributes['global'] or { 'false' }) == 'true'
		file: value.attributes['file'] or { '' }
		force: (value.attributes['force'] or { 'false' }) == 'true'
		zap: (value.attributes['zap'] or { 'false' }) == 'true'
		ask: (value.attributes['ask'] or { 'false' }) == 'true'
		dry_cleanup_output: value.attributes['dry_cleanup_output'] or { '' }
		selection: CleanupSelection{
			formulae: (value.attributes['formulae'] or { 'true' }) == 'true'
			casks: (value.attributes['casks'] or { 'true' }) == 'true'
			taps: (value.attributes['taps'] or { 'true' }) == 'true'
			extension_types: extension_types
		}
	}
}

fn cleanup_plan_value(plan CleanupPlan) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'CleanupPlan'
		map_data: {
			'formulae':   brew_runtime.string_array_value(plan.formulae)
			'casks':      brew_runtime.string_array_value(plan.casks)
			'taps':       brew_runtime.string_array_value(plan.taps)
			'extensions': brew_runtime.array_value(plan.extensions.map(fn (extension CleanupExtensionPlan) brew_runtime.Value {
				return brew_runtime.structured_value('CleanupExtensionPlan', extension.type_name, {
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

fn cleanup_result_value(result CleanupResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'CleanupResult'
		map_data: {
			'plan':     cleanup_plan_value(result.plan)
			'output':   brew_runtime.string_array_value(result.output)
			'commands': brew_runtime.array_value(result.commands.map(brew_runtime.string_array_value(it)))
		}
		attributes: {
			'force':           result.force.str()
			'confirmed':       result.confirmed.str()
			'changed':         result.changed.str()
			'exit_code':       result.exit_code.str()
			'trust_replaced':  result.trust_replaced.str()
			'formulae_marked': result.formulae_marked.str()
		}
	}
}

fn cleanup_boundary_inputs(args []brew_runtime.Value) !(CleanupState, CleanupDsl, CleanupInventory, CleanupOptions) {
	if args.len < 4 {
		return error('expected state, dsl, inventory, and options')
	}
	return cleanup_state_from_value(args[0]), cleanup_dsl_from_value(args[1]), cleanup_inventory_from_value(args[2]), cleanup_options_from_value(args[3])
}

// Ruby method `run` at line 78.
pub fn ruby_cleanup_l78_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, dsl, inventory, options := cleanup_boundary_inputs(args) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := run_cleanup(mut state, dsl, inventory, options, cleanup_default_callbacks()) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return cleanup_result_value(result)
}

// Ruby method `self.reset!` at line 100.
pub fn ruby_cleanup_l100_d2_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { cleanup_state_from_value(args[0]) } else { CleanupState{} }
	reset_cleanup_state(mut state, cleanup_no_reset) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return cleanup_state_value(state)
}

// Ruby method `self.cleanup(global: false, file: nil, force: false, zap: false, dsl: nil,` at line 121.
pub fn ruby_cleanup_l121_d3_self_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	mut state, dsl, inventory, options := cleanup_boundary_inputs(args) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	read_cleanup_dsl(mut state, dsl, options.global, options.file, cleanup_no_dsl_loader) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	result := execute_cleanup(mut state, inventory, options, cleanup_default_callbacks()) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return cleanup_result_value(result)
}

// Ruby method `self.read_dsl_from_brewfile!(global: false, file: nil, dsl: nil)` at line 233.
pub fn ruby_cleanup_l233_d4_self_read_dsl_from_brewfile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and DSL')
	}
	mut state := cleanup_state_from_value(args[0])
	read_cleanup_dsl(mut state, cleanup_dsl_from_value(args[1]), false, '', cleanup_no_dsl_loader) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return cleanup_state_value(state)
}

// Ruby method `self.dsl` at line 246.
pub fn ruby_cleanup_l246_d5_self_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	state := cleanup_state_from_value(args[0])
	return cleanup_dsl_value(cleanup_dsl(state) or {
		return brew_runtime.object_value('NilClass', 'nil')
	})
}

// Ruby method `self.casks_to_uninstall(global: false, file: nil)` at line 251.
pub fn ruby_cleanup_l251_d6_self_casks_to_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and inventory')
	}
	mut state := cleanup_state_from_value(args[0])
	items := cleanup_casks_to_uninstall(mut state, cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return brew_runtime.string_array_value(items)
}

// Ruby method `self.formulae_to_uninstall(global: false, file: nil)` at line 259.
pub fn ruby_cleanup_l259_d7_self_formulae_to_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and inventory')
	}
	mut state := cleanup_state_from_value(args[0])
	items := cleanup_formulae_to_uninstall(mut state, cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return brew_runtime.string_array_value(items)
}

// Ruby method `self.kept_formulae(global: false, file: nil)` at line 280.
pub fn ruby_cleanup_l280_d8_self_kept_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and inventory')
	}
	mut state := cleanup_state_from_value(args[0])
	items := cleanup_kept_formulae(mut state, cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return brew_runtime.string_array_value(items)
}

// Ruby method `self.kept_casks(global: false, file: nil)` at line 304.
pub fn ruby_cleanup_l304_d9_self_kept_casks(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and inventory')
	}
	mut state := cleanup_state_from_value(args[0])
	items := cleanup_kept_casks(mut state, cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return brew_runtime.string_array_value(items)
}

// Ruby method `self.recursive_dependencies(current_formulae, formulae_names, top_level: true)` at line 322.
pub fn ruby_cleanup_l322_d10_self_recursive_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected formulae and names')
	}
	formulae := args[0].array_data.map(cleanup_formula_from_value(it))
	names := args[1].as_string_array() or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	mut state := CleanupState{}
	return brew_runtime.string_array_value(cleanup_recursive_dependencies(mut state, formulae, names))
}

// Ruby method `self.taps_to_untap(global: false, file: nil)` at line 352.
pub fn ruby_cleanup_l352_d11_self_taps_to_untap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected state and inventory')
	}
	mut state := cleanup_state_from_value(args[0])
	items := cleanup_taps_to_untap(mut state, cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('CleanupError', err.msg())
	}
	return brew_runtime.string_array_value(items)
}

// Ruby method `self.lookup_formula(formula)` at line 373.
pub fn ruby_cleanup_l373_d12_self_lookup_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'expected formula and inventory')
	}
	formula := cleanup_lookup_formula(args[0].as_string(), cleanup_inventory_from_value(args[1])) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return cleanup_formula_value(formula)
}

// Ruby method `self.system_output_no_stderr(cmd, *args)` at line 381.
pub fn ruby_cleanup_l381_d13_self_system_output_no_stderr(args ...brew_runtime.Value) brew_runtime.Value {
	mut argv := []string{}
	for argument in args {
		if argument.type_name == 'Array' {
			argv << argument.as_string_array() or { return brew_runtime.object_value('ArgumentError', err.msg()) }
		} else {
			argv << argument.as_string()
		}
	}
	output := cleanup_system_output_no_stderr(argv, cleanup_real_command) or {
		return brew_runtime.object_value('ErrorDuringExecution', err.msg())
	}
	return brew_runtime.string_value(output)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6: require "cleanup"
// 7:
// 8: require "utils/formatter"
// 9: require "utils"
// 10: require "bundle/dsl"
// 11: require "bundle/extensions"
// 12: require "bundle/trust"
// 13: require "trust"
// 14: require "ask"
// 15: module Homebrew
// 16:   module Cmd
// 17:     class Bundle < Homebrew::AbstractCommand
// 18:       class CleanupSubcommand < Homebrew::AbstractSubcommand
// 19:         subcommand_args do
// 20:           usage_banner <<~EOS
// 21:             `brew bundle cleanup`:
// 22:             Uninstall all dependencies not present in the `Brewfile`.
// 23:
// 24:             This workflow is useful for maintainers or testers who regularly install lots of formulae.
// 25:
// 26:             When cleanup is performed, Homebrew's global trust store is reset to the trust values declared by the `Brewfile`, removing trust entries not declared there.
// 27:
// 28:             Unless `--force` is passed, this prompts before removing anything and returns a 1 exit code if the prompt is declined or cannot be shown.
// 29:           EOS
// 30:           named_args :none
// 31:           switch "--install",
// 32:                  description: "Run `install` before cleaning up dependencies."
// 33:           switch "-f", "--force",
// 34:                  description: "Actually perform cleanup operations and reset Homebrew's global trust store " \
// 35:                               "to the `Brewfile` values."
// 36:           switch "--all",
// 37:                  description: "Clean up all supported dependencies."
// 38:           switch "--formula", "--formulae", "--brews",
// 39:                  description: "Clean up Homebrew formula dependencies."
// 40:           switch "--no-formula", "--no-formulae", "--no-brews",
// 41:                  description: "Clean up without Homebrew formula dependencies. " \
// 42:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_BREW` is set."
// 43:           switch "--no-cleanup-brew",
// 44:                  description: "Clean up without Homebrew formula dependencies.",
// 45:                  env:         :bundle_cleanup_no_brew
// 46:           switch "--cask", "--casks",
// 47:                  description: "Clean up Homebrew cask dependencies."
// 48:           switch "--no-cask", "--no-casks",
// 49:                  description: "Clean up without Homebrew cask dependencies. " \
// 50:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_CASK` is set."
// 51:           switch "--no-cleanup-cask",
// 52:                  description: "Clean up without Homebrew cask dependencies.",
// 53:                  env:         :bundle_cleanup_no_cask
// 54:           switch "--tap", "--taps",
// 55:                  description: "Clean up Homebrew tap dependencies."
// 56:           switch "--no-tap", "--no-taps",
// 57:                  description: "Clean up without Homebrew tap dependencies. " \
// 58:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_TAP` is set."
// 59:           switch "--no-cleanup-tap",
// 60:                  description: "Clean up without Homebrew tap dependencies.",
// 61:                  env:         :bundle_cleanup_no_tap
// 62:           Homebrew::Bundle.extensions.select(&:cleanup_supported?).each do |extension|
// 63:             env = "HOMEBREW_#{extension.cleanup_disable_env.to_s.upcase}"
// 64:             switch "--#{extension.flag}",
// 65:                    description: extension.switch_description("Clean up #{extension.banner_name}.")
// 66:             switch "--no-#{extension.flag}",
// 67:                    description: "#{extension.cleanup_disable_description} " \
// 68:                                 "Enabled by default if `$#{env}` is set."
// 69:             switch "--no-cleanup-#{extension.flag}",
// 70:                    description: extension.cleanup_disable_description,
// 71:                    env:         extension.cleanup_disable_env
// 72:           end
// 73:           switch "--zap",
// 74:                  description: "Clean up casks using the `zap` command instead of `uninstall`."
// 75:         end
// 76:
// 77:         sig { override.void }
// 78:         def run
// 79:           core_type_options = context.core_type_options(args, "cleanup", all: args.all?)
// 80:           self.class.cleanup(
// 81:             global:          context.global,
// 82:             file:            context.file,
// 83:             force:           context.force,
// 84:             zap:             context.zap,
// 85:             ask:             context.ask || !context.force,
// 86:             formulae:        core_type_options.fetch(:formulae),
// 87:             casks:           core_type_options.fetch(:casks),
// 88:             taps:            core_type_options.fetch(:taps),
// 89:             extension_types: context.extensions.select(&:cleanup_supported?).to_h do |extension|
// 90:               [
// 91:                 extension.type,
// 92:                 !context.extension_disabled?(args, extension) &&
// 93:                   (context.extension_selected?(args, extension) || args.all? || context.no_type_args),
// 94:               ]
// 95:             end,
// 96:           )
// 97:         end
// 98:
// 99:         sig { void }
// 100:         def self.reset!
// 101:           require "bundle/cask"
// 102:           require "bundle/brew"
// 103:           require "bundle/tap"
// 104:           require "bundle/brew_services"
// 105:
// 106:           @dsl = T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 107:           @kept_casks = nil
// 108:           @kept_formulae = nil
// 109:           Homebrew::Bundle::Cask.reset!
// 110:           Homebrew::Bundle::Brew.reset!
// 111:           Homebrew::Bundle::Tap.reset!
// 112:           Homebrew::Bundle::Brew::Services.reset!
// 113:           Homebrew::Bundle.extensions.each(&:reset!)
// 114:         end
// 115:
// 116:         sig {
// 117:           params(global: T::Boolean, file: T.nilable(String), force: T::Boolean, zap: T::Boolean,
// 118:                  dsl: T.nilable(Homebrew::Bundle::Dsl), formulae: T::Boolean, casks: T::Boolean, taps: T::Boolean,
// 119:                  ask: T::Boolean, extension_types: Homebrew::Bundle::ExtensionTypes).void
// 120:         }
// 121:         def self.cleanup(global: false, file: nil, force: false, zap: false, dsl: nil,
// 122:                          formulae: true, casks: true, taps: true, ask: false, extension_types: {})
// 123:           read_dsl_from_brewfile!(global:, file:, dsl:)
// 124:
// 125:           cleanup_formulae = formulae
// 126:           cleanup_casks = casks
// 127:           cleanup_taps = taps
// 128:           extension_types = Homebrew::Bundle.extensions.select(&:cleanup_supported?).to_h do |extension|
// 129:             [extension.type, true]
// 130:           end.merge(extension_types)
// 131:           casks = if casks
// 132:             casks_to_uninstall(global:, file:)
// 133:           else
// 134:             []
// 135:           end
// 136:           formulae = if formulae
// 137:             formulae_to_uninstall(global:, file:)
// 138:           else
// 139:             []
// 140:           end
// 141:           taps = if taps
// 142:             taps_to_untap(global:, file:)
// 143:           else
// 144:             []
// 145:           end
// 146:           cleanup_extensions = Homebrew::Bundle.extensions.select(&:cleanup_supported?).filter_map do |extension|
// 147:             next unless extension_types.fetch(extension.type, false)
// 148:             raise ArgumentError, "dsl is unset!" unless @dsl
// 149:
// 150:             [extension, extension.cleanup_items(@dsl.entries)]
// 151:           end
// 152:           if force
// 153:             dsl = @dsl
// 154:             raise ArgumentError, "dsl is unset!" unless dsl
// 155:
// 156:             Homebrew::Trust.replace!(Homebrew::Bundle::Trust.entries(dsl.entries))
// 157:
// 158:             if casks.any?
// 159:               args = if zap
// 160:                 ["--zap"]
// 161:               else
// 162:                 []
// 163:               end
// 164:               Kernel.system HOMEBREW_BREW_FILE, "uninstall", "--cask", *args, "--force", *casks
// 165:               puts "Uninstalled #{casks.size} cask#{"s" if casks.size != 1}"
// 166:             end
// 167:
// 168:             if formulae.any?
// 169:               # Mark Brewfile formulae as installed_on_request to prevent autoremove
// 170:               # from removing them when their dependents are uninstalled
// 171:               Homebrew::Bundle.mark_as_installed_on_request!(dsl.entries)
// 172:
// 173:               Kernel.system HOMEBREW_BREW_FILE, "uninstall", "--formula", "--force", *formulae
// 174:               puts "Uninstalled #{formulae.size} formula#{"e" if formulae.size != 1}"
// 175:             end
// 176:
// 177:             Kernel.system HOMEBREW_BREW_FILE, "untap", *taps if taps.any?
// 178:
// 179:             cleanup_extensions.each do |extension, items|
// 180:               next if items.empty?
// 181:
// 182:               extension.cleanup!(items)
// 183:             end
// 184:
// 185:             cleanup = system_output_no_stderr(HOMEBREW_BREW_FILE, "cleanup")
// 186:             puts cleanup unless cleanup.empty?
// 187:           else
// 188:             would_uninstall = false
// 189:
// 190:             if casks.any?
// 191:               puts "Would uninstall casks:"
// 192:               puts Formatter.columns casks
// 193:               would_uninstall = true
// 194:             end
// 195:
// 196:             if formulae.any?
// 197:               puts "Would uninstall formulae:"
// 198:               puts Formatter.columns formulae
// 199:               would_uninstall = true
// 200:             end
// 201:
// 202:             if taps.any?
// 203:               puts "Would untap:"
// 204:               puts Formatter.columns taps
// 205:               would_uninstall = true
// 206:             end
// 207:
// 208:             cleanup_extensions.each do |extension, items|
// 209:               next if items.empty?
// 210:
// 211:               puts "Would uninstall #{extension.cleanup_heading}:"
// 212:               puts Formatter.columns items.map { |item| extension.cleanup_item_name(item) }
// 213:               would_uninstall = true
// 214:             end
// 215:
// 216:             would_cleanup = Cleanup.printed_dry_run_output?(Cleanup.dry_run_output)
// 217:             would_change = would_uninstall || would_cleanup
// 218:
// 219:             # `Ask.confirm?` only prints a prompt on a TTY; when it does, don't
// 220:             # also tell the user to rerun with `--force`.
// 221:             if ask && would_change && Homebrew::Ask.confirm?(action: "cleanup")
// 222:               cleanup(global:, file:, force: true, zap:, dsl: @dsl, formulae: cleanup_formulae, casks: cleanup_casks,
// 223:                       taps: cleanup_taps, extension_types:)
// 224:               return
// 225:             end
// 226:
// 227:             puts "Run `brew bundle cleanup --force` to make these changes." if would_change
// 228:             exit 1 if would_uninstall
// 229:           end
// 230:         end
// 231:
// 232:         sig { params(global: T::Boolean, file: T.nilable(String), dsl: T.nilable(Homebrew::Bundle::Dsl)).void }
// 233:         def self.read_dsl_from_brewfile!(global: false, file: nil, dsl: nil)
// 234:           @dsl = T.let(
// 235:             if dsl
// 236:               dsl
// 237:             else
// 238:               require "bundle/brewfile"
// 239:               Homebrew::Bundle::Brewfile.read(global:, file:)
// 240:             end,
// 241:             T.nilable(Homebrew::Bundle::Dsl),
// 242:           )
// 243:         end
// 244:
// 245:         sig { returns(T.nilable(Homebrew::Bundle::Dsl)) }
// 246:         def self.dsl
// 247:           T.let(@dsl, T.nilable(Homebrew::Bundle::Dsl))
// 248:         end
// 249:
// 250:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 251:         def self.casks_to_uninstall(global: false, file: nil)
// 252:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 253:
// 254:           require "bundle/cask"
// 255:           Homebrew::Bundle::Cask.cask_names - kept_casks(global:, file:)
// 256:         end
// 257:
// 258:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 259:         def self.formulae_to_uninstall(global: false, file: nil)
// 260:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 261:
// 262:           kept_formulae = self.kept_formulae(global:, file:)
// 263:
// 264:           require "bundle/brew"
// 265:           current_formulae = Homebrew::Bundle::Brew.formulae
// 266:           current_formulae.reject! do |f|
// 267:             Homebrew::Bundle::Brew.formula_in_array?(f[:full_name], kept_formulae)
// 268:           end
// 269:
// 270:           # Don't try to uninstall formulae with keepme references
// 271:           current_formulae.reject! do |f|
// 272:             Formula[f[:full_name]].installed_kegs.any? do |keg|
// 273:               keg.keepme_refs.present?
// 274:             end
// 275:           end
// 276:           current_formulae.map { |f| f[:full_name] }
// 277:         end
// 278:
// 279:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 280:         private_class_method def self.kept_formulae(global: false, file: nil)
// 281:           require "bundle/brew"
// 282:           require "bundle/cask"
// 283:
// 284:           @kept_formulae ||= T.let(
// 285:             begin
// 286:               raise ArgumentError, "dsl is unset!" unless @dsl
// 287:
// 288:               kept_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
// 289:               kept_formulae += Homebrew::Bundle::Cask.formula_dependencies(kept_casks)
// 290:               kept_formulae.map! do |f|
// 291:                 Homebrew::Bundle::Brew.formula_aliases.fetch(
// 292:                   f,
// 293:                   Homebrew::Bundle::Brew.formula_oldnames.fetch(f, f),
// 294:                 )
// 295:               end
// 296:
// 297:               kept_formulae + recursive_dependencies(Homebrew::Bundle::Brew.formulae, kept_formulae)
// 298:             end,
// 299:             T.nilable(T::Array[String]),
// 300:           )
// 301:         end
// 302:
// 303:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 304:         private_class_method def self.kept_casks(global: false, file: nil)
// 305:           return @kept_casks if @kept_casks
// 306:           raise ArgumentError, "dsl is unset!" unless @dsl
// 307:
// 308:           kept_casks = @dsl.entries.select { |e| e.type == :cask }.flat_map(&:name)
// 309:           kept_casks.map! do |c|
// 310:             Homebrew::Bundle::Cask.cask_oldnames.fetch(c, c)
// 311:           end
// 312:           @kept_casks = T.let(kept_casks, T.nilable(T::Array[String]))
// 313:           raise "kept_casks is nil" unless @kept_casks
// 314:
// 315:           @kept_casks
// 316:         end
// 317:
// 318:         sig {
// 319:           params(current_formulae: T::Array[T::Hash[Symbol, T.untyped]], formulae_names: T::Array[String],
// 320:                  top_level: T::Boolean).returns(T::Array[String])
// 321:         }
// 322:         private_class_method def self.recursive_dependencies(current_formulae, formulae_names, top_level: true)
// 323:           @checked_formulae_names = T.let([], T.nilable(T::Array[String])) if top_level
// 324:           dependencies = T.let([], T::Array[String])
// 325:
// 326:           formulae_names.each do |name|
// 327:             raise "checked_formulae_names is unset!" unless @checked_formulae_names
// 328:             next if @checked_formulae_names.include?(name)
// 329:
// 330:             formula = current_formulae.find { |f| f[:full_name] == name }
// 331:             next unless formula
// 332:
// 333:             f_deps = formula[:dependencies]
// 334:             unless formula[:poured_from_bottle?]
// 335:               f_deps += formula[:build_dependencies]
// 336:               f_deps.uniq!
// 337:             end
// 338:             next unless f_deps
// 339:             next if f_deps.empty?
// 340:
// 341:             @checked_formulae_names << name
// 342:             f_deps += recursive_dependencies(current_formulae, f_deps, top_level: false)
// 343:             dependencies += f_deps
// 344:           end
// 345:
// 346:           dependencies.uniq
// 347:         end
// 348:
// 349:         IGNORED_TAPS = %w[homebrew/core].freeze
// 350:
// 351:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 352:         def self.taps_to_untap(global: false, file: nil)
// 353:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 354:
// 355:           require "bundle/tap"
// 356:
// 357:           kept_formulae = self.kept_formulae(global:, file:).filter_map { lookup_formula(it) }
// 358:           kept_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
// 359:           kept_taps += @dsl.entries.filter_map do |entry|
// 360:             case entry.type
// 361:             when :brew
// 362:               Utils.tap_from_full_name(entry.name)
// 363:             when :cask
// 364:               Utils.tap_from_full_name(T.cast(entry.options.fetch(:full_name, entry.name), String))
// 365:             end
// 366:           end
// 367:           kept_taps += kept_formulae.filter_map(&:tap).map(&:name)
// 368:           current_taps = Homebrew::Bundle::Tap.tap_names
// 369:           current_taps - kept_taps - IGNORED_TAPS
// 370:         end
// 371:
// 372:         sig { params(formula: String).returns(T.nilable(Formula)) }
// 373:         private_class_method def self.lookup_formula(formula)
// 374:           Formulary.factory(formula)
// 375:         rescue TapFormulaUnavailableError
// 376:           # ignore these as an unavailable formula implies there is no tap to worry about
// 377:           nil
// 378:         end
// 379:
// 380:         sig { params(cmd: T.any(Pathname, String), args: T.anything).returns(String) }
// 381:         def self.system_output_no_stderr(cmd, *args)
// 382:           Utils.safe_popen_read(cmd, *args, err: File::NULL)
// 383:         end
// 384:       end
// 385:     end
// 386:   end
// 387: end
