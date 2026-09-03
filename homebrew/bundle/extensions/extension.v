module extensions

import brew_runtime
import json2
import os

// Translated from Homebrew/brew `bundle/extensions/extension.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ExtensionDefinition {
pub:
	class_name      string
	type_name       string
	banner_name     string
	check_label     string
	original_paths  []string
	cleanup_heading ?string
}

pub struct ExtensionPackage {
pub:
	name string
	with []string
}

pub struct ExtensionEntry {
pub:
	entry_type string
	name       string
	options    map[string]brew_runtime.Value
}

pub struct ExtensionState {
pub:
	definition ExtensionDefinition
pub mut:
	executable         string
	packages           []ExtensionPackage
	installed_packages []ExtensionPackage
	output             []string
	uninstalled        []string
	reset_count        int
}

pub type ExtensionExecutableLookup = fn(name string, paths []string) !string

pub type ExtensionEnvironmentRunner = fn(executable string, environment map[string]string) !string

pub type ExtensionActionableFinder = fn(entries []ExtensionEntry, exit_on_first_error bool, no_upgrade bool, verbose bool) ![]string

pub type ExtensionResetter = fn() !

pub type ExtensionManagerInstaller = fn(manager string, package_name string, verbose bool) !string

pub type ExtensionPackageInstaller = fn(name string, with []string, verbose bool) !bool

pub type ExtensionPackageUninstaller = fn(name string, executable string, environment map[string]string) !

pub struct ExtensionCollaborators {
pub:
	find_executable   ExtensionExecutableLookup @[required]
	with_environment  ExtensionEnvironmentRunner @[required]
	find_actionable   ExtensionActionableFinder @[required]
	reset             ExtensionResetter @[required]
	install_manager   ExtensionManagerInstaller @[required]
	install_package   ExtensionPackageInstaller @[required]
	uninstall_package ExtensionPackageUninstaller @[required]
}

pub struct ExtensionRegistry {
pub mut:
	extensions    []ExtensionDefinition
	package_types []ExtensionDefinition
}

pub fn extension_switch_description(description string) string {
	return description
}

pub fn extension_entry(definition ExtensionDefinition, name string,
	options map[string]brew_runtime.Value) !ExtensionEntry {
	if options.len > 0 {
		mut option_symbols := []string{}
		for key in options.keys() {
			option_symbols << ':${key}'
		}
		unknown := '[${option_symbols.join(', ')}]'
		return error('unknown options(${unknown}) for ${definition.type_name}')
	}
	return ExtensionEntry{
		entry_type: definition.type_name
		name: name
		options: map[string]brew_runtime.Value{}
	}
}

pub fn extension_flag(definition ExtensionDefinition) string {
	return definition.type_name.replace('_', '-')
}

pub fn extension_predicate_method(definition ExtensionDefinition) string {
	return '${definition.type_name}?'
}

pub fn extension_package_manager_name(definition ExtensionDefinition) string {
	return extension_flag(definition)
}

pub fn extension_package_manager_executable(state ExtensionState,
	collaborators ExtensionCollaborators) !string {
	if state.executable != '' {
		return state.executable
	}
	return collaborators.find_executable(extension_package_manager_name(state.definition), state.definition.original_paths)
}

pub fn extension_package_manager_env(state ExtensionState, executable string) map[string]string {
	return {
		'PATH': '${os.dir(executable)}:${state.definition.original_paths.join(':')}'
	}
}

pub fn extension_with_package_manager_env(state ExtensionState,
	collaborators ExtensionCollaborators) !string {
	executable := extension_package_manager_executable(state, collaborators)!
	if executable == '' {
		return error('${extension_package_manager_name(state.definition)} is not installed')
	}
	return collaborators.with_environment(executable, extension_package_manager_env(state, executable))
}

pub fn extension_package_description(definition ExtensionDefinition) string {
	return definition.check_label.to_lower()
}

pub fn extension_dump_disable_description(definition ExtensionDefinition) string {
	return '`dump` without ${definition.banner_name}.'
}

pub fn extension_dump_disable_env(definition ExtensionDefinition) string {
	return 'bundle_dump_no_${definition.type_name}'
}

pub fn extension_cleanup_disable_env(definition ExtensionDefinition) string {
	return 'bundle_cleanup_no_${definition.type_name}'
}

pub fn extension_cleanup_disable_description(definition ExtensionDefinition) string {
	return '`cleanup` without ${definition.banner_name}.'
}

pub fn extension_disable_predicate_method(definition ExtensionDefinition) string {
	return 'no_${definition.type_name}?'
}

pub fn extension_cleanup_supported(definition ExtensionDefinition) bool {
	if _ := definition.cleanup_heading {
		return true
	}
	return false
}

pub fn extension_reset(mut state ExtensionState, collaborators ExtensionCollaborators) ! {
	collaborators.reset()!
	state.packages = []
	state.installed_packages = []
	state.reset_count++
}

pub fn extension_quote(value string) string {
	return json2.encode(value, escape_unicode: true)
}

pub fn extension_dump_entry(definition ExtensionDefinition, package ExtensionPackage) string {
	line := '${definition.type_name} ${extension_quote(package.name)}'
	if package.with.len == 0 {
		return line
	}
	formatted_with := package.with.map(extension_quote(it)).join(', ')
	return '${line}, with: [${formatted_with}]'
}

pub fn extension_dump(state ExtensionState) string {
	return state.packages.map(extension_dump_entry(state.definition, it)).join('\n')
}

pub fn extension_check(entries []ExtensionEntry, exit_on_first_error bool, no_upgrade bool,
	verbose bool, collaborators ExtensionCollaborators) ![]string {
	return collaborators.find_actionable(entries, exit_on_first_error, no_upgrade, verbose)
}

pub fn extension_cleanup_items(state ExtensionState, entries []ExtensionEntry,
	collaborators ExtensionCollaborators) ![]string {
	if extension_package_manager_executable(state, collaborators)! == '' {
		return []
	}
	mut kept_packages := []string{}
	for entry in entries {
		if entry.entry_type == state.definition.type_name {
			kept_packages << entry.name
		}
	}
	if kept_packages.len == 0 {
		return []
	}
	mut cleanup := []string{}
	for package in state.packages {
		if package.name !in kept_packages {
			cleanup << package.name
		}
	}
	return cleanup
}

pub fn extension_cleanup(mut state ExtensionState, items []string,
	collaborators ExtensionCollaborators) ! {
	executable := extension_package_manager_executable(state, collaborators)!
	if executable == '' {
		return
	}
	environment := extension_package_manager_env(state, executable)
	for name in items {
		collaborators.uninstall_package(name, executable, environment)!
		state.uninstalled << name
	}
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} ${state.definition.banner_name}${suffix}'
}

pub fn extension_uninstall_package_base(definition ExtensionDefinition, _ string, _ string) ! {
	return error('${definition.class_name} must override `uninstall_package!` or `cleanup!`.')
}

pub fn extension_package_record(name string, _ []string) ExtensionPackage {
	return ExtensionPackage{
		name: name
	}
}

pub fn extension_package_installed(state ExtensionState, name string, with []string) bool {
	return extension_package_record(name, with) in state.installed_packages
}

pub fn extension_ensure_package_manager_installed(mut state ExtensionState, package_name string,
	verbose bool, collaborators ExtensionCollaborators) ! {
	if extension_package_manager_executable(state, collaborators)! != '' {
		return
	}
	if verbose {
		state.output << 'Installing ${extension_package_manager_name(state.definition)}. It is not currently installed.'
	}
	state.executable = collaborators.install_manager(extension_package_manager_name(state.definition), package_name, verbose)!
	if extension_package_manager_executable(state, collaborators)! == '' {
		return error('Unable to install ${package_name} ${extension_package_description(state.definition)}. ${extension_package_manager_name(state.definition)} installation failed.')
	}
}

pub fn extension_preinstall(mut state ExtensionState, name string, with []string, _ bool,
	verbose bool, collaborators ExtensionCollaborators) !bool {
	extension_ensure_package_manager_installed(mut state, name, verbose, collaborators)!
	if extension_package_installed(state, name, with) {
		if verbose {
			state.output << 'Skipping install of ${name} ${extension_package_description(state.definition)}. It is already installed.'
		}
		return false
	}
	return true
}

pub fn extension_install(mut state ExtensionState, name string, with []string, preinstall bool,
	_ bool, verbose bool, _ bool, collaborators ExtensionCollaborators) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} ${extension_package_description(state.definition)}. It is not currently installed.'
	}
	if !collaborators.install_package(name, with, verbose)! {
		return false
	}
	package := extension_package_record(name, with)
	if package !in state.installed_packages {
		state.installed_packages << package
	}
	if package !in state.packages {
		state.packages << package
	}
	return true
}

pub fn extension_failure_reason(state ExtensionState, package ExtensionPackage) string {
	return '${state.definition.check_label} ${package.name} needs to be installed.'
}

pub fn extension_installed_and_up_to_date(state ExtensionState, package ExtensionPackage) bool {
	return extension_package_installed(state, package.name, package.with)
}

pub fn extension_install_package_base(definition ExtensionDefinition, _ string, _ []string,
	_ bool) !bool {
	return error('${definition.class_name} must override `install_package!` or `install!`.')
}

pub fn register_extension(mut registry ExtensionRegistry, definition ExtensionDefinition) {
	registry.extensions = registry.extensions.filter(it.class_name != definition.class_name)
	registry.extensions << definition
}

pub fn registered_extension(registry ExtensionRegistry, type_name string) ?ExtensionDefinition {
	requested_type := type_name.trim_string_left(':')
	for definition in registry.extensions {
		if definition.type_name == requested_type {
			return definition
		}
	}
	return none
}

pub fn extension_installable(registry ExtensionRegistry, type_name string) ?ExtensionDefinition {
	requested_type := type_name.trim_string_left(':')
	for definition in registry.package_types {
		if definition.type_name == requested_type {
			return definition
		}
	}
	return registered_extension(registry, requested_type)
}

// Ruby method `self.inherited(subclass)` at line 16.
pub fn ruby_extension_l16_d1_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'extension subclass is required')
	}
	definition := extension_definition_from_value(args[0])
	mut registry := if args.len > 1 {
		extension_registry_from_value(args[1])
	} else {
		ExtensionRegistry{}
	}
	register_extension(mut registry, definition)
	return extension_registry_value(registry)
}

// Ruby method `self.banner_name; end` at line 22.
pub fn ruby_extension_l22_d2_self_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('NotImplementedError', err.msg())
	}
	return brew_runtime.string_value(definition.banner_name)
}

// Ruby method `self.switch_description(description)` at line 25.
pub fn ruby_extension_l25_d3_self_switch_description(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'description is required')
	}
	return brew_runtime.string_value(extension_switch_description(args[0].as_string()))
}

// Ruby method `self.entry(name, options = {})` at line 30.
pub fn ruby_extension_l30_d4_self_entry(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	options := if args.len > 2 {
		args[2].as_map() or {
			return extension_boundary_error('ArgumentError', err.msg())
		}
	} else {
		map[string]brew_runtime.Value{}
	}
	entry := extension_entry(state.definition, args[1].as_string(), options) or {
		return extension_boundary_error('RuntimeError', err.msg())
	}
	return extension_entry_value(entry)
}

// Ruby method `self.flag` at line 37.
pub fn ruby_extension_l37_d5_self_flag(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_flag(definition))
}

// Ruby method `self.predicate_method` at line 42.
pub fn ruby_extension_l42_d6_self_predicate_method(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Symbol', extension_predicate_method(definition))
}

// Ruby method `self.package_manager_name` at line 47.
pub fn ruby_extension_l47_d7_self_package_manager_name(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_package_manager_name(definition))
}

// Ruby method `self.package_manager_installed?` at line 52.
pub fn ruby_extension_l52_d8_self_package_manager_installed(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.bool_value(state.executable != '')
}

// Ruby method `self.package_manager_executable` at line 57.
pub fn ruby_extension_l57_d9_self_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if state.executable == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.object_value('Pathname', state.executable)
}

// Ruby method `self.package_manager_executable!` at line 62.
pub fn ruby_extension_l62_d10_self_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if state.executable == '' {
		return extension_boundary_error('RuntimeError', '${extension_package_manager_name(state.definition)} is not installed')
	}
	return brew_runtime.object_value('Pathname', state.executable)
}

// Ruby method `self.package_manager_env(executable)` at line 67.
pub fn ruby_extension_l67_d11_self_package_manager_env(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'executable is required')
	}
	return extension_string_map_value(extension_package_manager_env(state, args[1].as_string()))
}

// Ruby method `self.with_package_manager_env(&_blk)` at line 76.
pub fn ruby_extension_l76_d12_self_with_package_manager_env(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if state.executable == '' {
		return extension_boundary_error('RuntimeError', '${extension_package_manager_name(state.definition)} is not installed')
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'block result collaborator is required')
	}
	return args[1]
}

// Ruby method `self.package_description` at line 82.
pub fn ruby_extension_l82_d13_self_package_description(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_package_description(definition))
}

// Ruby method `self.dump_supported?` at line 87.
pub fn ruby_extension_l87_d14_self_dump_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `self.dump_disable_description` at line 92.
pub fn ruby_extension_l92_d15_self_dump_disable_description(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_dump_disable_description(definition))
}

// Ruby method `self.dump_disable_env` at line 97.
pub fn ruby_extension_l97_d16_self_dump_disable_env(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Symbol', extension_dump_disable_env(definition))
}

// Ruby method `self.cleanup_disable_env` at line 102.
pub fn ruby_extension_l102_d17_self_cleanup_disable_env(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Symbol', extension_cleanup_disable_env(definition))
}

// Ruby method `self.dump_disable_supported?` at line 107.
pub fn ruby_extension_l107_d18_self_dump_disable_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `self.cleanup_disable_description` at line 112.
pub fn ruby_extension_l112_d19_self_cleanup_disable_description(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_cleanup_disable_description(definition))
}

// Ruby method `self.dump_disable_predicate_method` at line 117.
pub fn ruby_extension_l117_d20_self_dump_disable_predicate_method(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Symbol', extension_disable_predicate_method(definition))
}

// Ruby method `self.disable_predicate_method` at line 122.
pub fn ruby_extension_l122_d21_self_disable_predicate_method(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.object_value('Symbol', extension_disable_predicate_method(definition))
}

// Ruby method `self.add_supported?` at line 127.
pub fn ruby_extension_l127_d22_self_add_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `self.remove_supported?` at line 132.
pub fn ruby_extension_l132_d23_self_remove_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `self.install_supported?` at line 137.
pub fn ruby_extension_l137_d24_self_install_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `self.install_verb(_name = "", _options = {})` at line 142.
pub fn ruby_extension_l142_d25_self_install_verb(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Installing')
}

// Ruby method `self.fetchable_name(name, options = {}, no_upgrade: false)` at line 153.
pub fn ruby_extension_l153_d26_self_fetchable_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.cleanup_heading` at line 162.
pub fn ruby_extension_l162_d27_self_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if heading := definition.cleanup_heading {
		return brew_runtime.string_value(heading)
	}
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.cleanup_supported?` at line 167.
pub fn ruby_extension_l167_d28_self_cleanup_supported(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.bool_value(extension_cleanup_supported(definition))
}

// Ruby method `self.reset!; end` at line 172.
pub fn ruby_extension_l172_d29_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	state.packages = []
	state.installed_packages = []
	state.reset_count++
	return extension_state_value(state)
}

// Ruby method `self.packages; end` at line 175.
pub fn ruby_extension_l175_d30_self_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return extension_packages_value(state.packages)
}

// Ruby method `self.installed_packages; end` at line 178.
pub fn ruby_extension_l178_d31_self_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return extension_packages_value(state.installed_packages)
}

// Ruby method `self.dump_entry(package)` at line 181.
pub fn ruby_extension_l181_d32_self_dump_entry(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(extension_dump_entry(definition, extension_package_from_value(args[1])))
}

// Ruby method `self.quote(value)` at line 191.
pub fn ruby_extension_l191_d33_self_quote(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'value is required')
	}
	return brew_runtime.string_value(extension_quote(args[0].as_string()))
}

// Ruby method `self.dump_name(package)` at line 196.
pub fn ruby_extension_l196_d34_self_dump_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(extension_package_from_value(args[0]).name)
}

// Ruby method `self.dump_with(_package)` at line 201.
pub fn ruby_extension_l201_d35_self_dump_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `self.dump` at line 206.
pub fn ruby_extension_l206_d36_self_dump(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_dump(state))
}

// Ruby method `self.dump_output(describe: false, no_restart: false)` at line 211.
pub fn ruby_extension_l211_d37_self_dump_output(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(extension_dump(state))
}

// Ruby method `self.check(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 226.
pub fn ruby_extension_l226_d38_self_check(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 6 {
		return extension_boundary_error('ArgumentError', 'find_actionable collaborator result is required')
	}
	return args[5]
}

// Ruby method `self.cleanup_items(entries)` at line 231.
pub fn ruby_extension_l231_d39_self_cleanup_items(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if state.executable == '' {
		return brew_runtime.string_array_value([])
	}
	entries := if args.len > 1 { extension_entries_from_value(args[1]) } else { []ExtensionEntry{} }
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == state.definition.type_name {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(state.packages.filter(it.name !in kept).map(it.name))
}

// Ruby method `self.cleanup_item_name(item)` at line 245.
pub fn ruby_extension_l245_d40_self_cleanup_item_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'item is required')
	}
	return brew_runtime.string_value(args[0].as_string())
}

// Ruby method `self.legacy_check_step` at line 250.
pub fn ruby_extension_l250_d41_self_legacy_check_step(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'registered_extensions_to_install')
}

// Ruby method `self.cleanup!(items)` at line 255.
pub fn ruby_extension_l255_d42_self_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if state.executable == '' {
		return extension_state_value(state)
	}
	items := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	state.uninstalled << items
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} ${state.definition.banner_name}${suffix}'
	return extension_state_value(state)
}

// Ruby method `self.uninstall_package!(name, executable: Pathname.new(""))` at line 268.
pub fn ruby_extension_l268_d43_self_uninstall_package(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return extension_boundary_error('NotImplementedError', '${definition.class_name} must override `uninstall_package!` or `cleanup!`.')
}

// Ruby method `self.package_record(name, with: nil)` at line 273.
pub fn ruby_extension_l273_d44_self_package_record(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	name_index := if args[0].type_name == 'Hash' { 1 } else { 0 }
	if args.len <= name_index {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	return extension_package_value(extension_package_record(args[name_index].as_string(), []))
}

// Ruby method `self.package_installed?(name, with: nil)` at line 280.
pub fn ruby_extension_l280_d45_self_package_installed(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	with := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	return brew_runtime.bool_value(extension_package_installed(state, args[1].as_string(), with))
}

// Ruby method `self.preinstall!(name, with: nil, no_upgrade: false, verbose: false, **_options)` at line 293.
pub fn ruby_extension_l293_d46_self_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	name := args[1].as_string()
	with := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	if state.executable == '' {
		if args.len > 5 {
			state.executable = args[5].as_string()
		}
		if state.executable == '' {
			return extension_boundary_error('RuntimeError', 'Unable to install ${name} ${extension_package_description(state.definition)}. ${extension_package_manager_name(state.definition)} installation failed.')
		}
	}
	if extension_package_installed(state, name, with) {
		if verbose {
			state.output << 'Skipping install of ${name} ${extension_package_description(state.definition)}. It is already installed.'
		}
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `self.ensure_package_manager_installed!(name, verbose: false)` at line 307.
pub fn ruby_extension_l307_d47_self_ensure_package_manager_installed(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	if state.executable != '' {
		return extension_state_value(state)
	}
	verbose := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	if verbose {
		state.output << 'Installing ${extension_package_manager_name(state.definition)}. It is not currently installed.'
	}
	state.executable = if args.len > 3 { args[3].as_string() } else { '' }
	if state.executable == '' {
		return extension_boundary_error('RuntimeError', 'Unable to install ${args[1].as_string()} ${extension_package_description(state.definition)}. ${extension_package_manager_name(state.definition)} installation failed.')
	}
	return extension_state_value(state)
}

// Ruby method `self.install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 339.
pub fn ruby_extension_l339_d48_self_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'name is required')
	}
	preinstall := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	if !preinstall {
		return brew_runtime.bool_value(true)
	}
	install_result := if args.len > 7 { args[7].as_bool() or { false } } else { false }
	if !install_result {
		return brew_runtime.bool_value(false)
	}
	with := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	package := extension_package_record(args[1].as_string(), with)
	if package !in state.installed_packages {
		state.installed_packages << package
	}
	if package !in state.packages {
		state.packages << package
	}
	return extension_state_value(state)
}

// Ruby method `failure_reason(package, no_upgrade:)` at line 356.
pub fn ruby_extension_l356_d49_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(extension_failure_reason(state, extension_package_from_value(args[1])))
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 361.
pub fn ruby_extension_l361_d50_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	state := extension_state_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'package is required')
	}
	return brew_runtime.bool_value(extension_installed_and_up_to_date(state, extension_package_from_value(args[1])))
}

// Ruby method `self.install_package!(name, with: nil, verbose: false)` at line 372.
pub fn ruby_extension_l372_d51_self_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	definition := extension_definition_from_boundary(args) or {
		return extension_boundary_error('ArgumentError', err.msg())
	}
	return extension_boundary_error('NotImplementedError', '${definition.class_name} must override `install_package!` or `install!`.')
}

// Ruby method `register_extension(extension)` at line 383.
pub fn ruby_extension_l383_d52_register_extension(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return extension_boundary_error('ArgumentError', 'extension is required')
	}
	mut registry := if args.len > 1 {
		extension_registry_from_value(args[1])
	} else {
		ExtensionRegistry{}
	}
	register_extension(mut registry, extension_definition_from_value(args[0]))
	return extension_registry_value(registry)
}

// Ruby method `extensions` at line 390.
pub fn ruby_extension_l390_d53_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	registry := if args.len > 0 {
		extension_registry_from_value(args[0])
	} else {
		ExtensionRegistry{}
	}
	return extension_definitions_value(registry.extensions)
}

// Ruby method `extension(type)` at line 396.
pub fn ruby_extension_l396_d54_extension(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'registry and type are required')
	}
	registry := extension_registry_from_value(args[0])
	if definition := registered_extension(registry, args[1].as_string()) {
		return extension_definition_value(definition)
	}
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `installable(type)` at line 406.
pub fn ruby_extension_l406_d55_installable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return extension_boundary_error('ArgumentError', 'registry and type are required')
	}
	registry := extension_registry_from_value(args[0])
	if definition := extension_installable(registry, args[1].as_string()) {
		return extension_definition_value(definition)
	}
	return brew_runtime.object_value('NilClass', '')
}

pub fn extension_definition_value(definition ExtensionDefinition) brew_runtime.Value {
	cleanup_heading := if heading := definition.cleanup_heading {
		brew_runtime.string_value(heading)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.map_value({
		'class_name':      brew_runtime.string_value(definition.class_name)
		'type_name':       brew_runtime.string_value(definition.type_name)
		'banner_name':     brew_runtime.string_value(definition.banner_name)
		'check_label':     brew_runtime.string_value(definition.check_label)
		'original_paths':  brew_runtime.string_array_value(definition.original_paths)
		'cleanup_heading': cleanup_heading
	})
}

pub fn extension_definition_from_value(value brew_runtime.Value) ExtensionDefinition {
	values := value.as_map() or {
		return ExtensionDefinition{
			class_name: value.type_name
			type_name: value.repr
		}
	}
	if '_definition' in values {
		return extension_definition_from_value(values['_definition'])
	}
	return ExtensionDefinition{
		class_name: if 'class_name' in values { values['class_name'].as_string() } else { '' }
		type_name: if 'type_name' in values { values['type_name'].as_string() } else { '' }
		banner_name: if 'banner_name' in values { values['banner_name'].as_string() } else { '' }
		check_label: if 'check_label' in values { values['check_label'].as_string() } else { '' }
		original_paths: if 'original_paths' in values {
			values['original_paths'].as_string_array() or { [] }} else {
			[]}
		cleanup_heading: if 'cleanup_heading' in values && values['cleanup_heading'].type_name != 'NilClass' {
			values['cleanup_heading'].as_string()} else {
			none}
	}
}

pub fn extension_package_value(package ExtensionPackage) brew_runtime.Value {
	return brew_runtime.map_value({
		'name': brew_runtime.string_value(package.name)
		'with': brew_runtime.string_array_value(package.with)
	})
}

pub fn extension_package_from_value(value brew_runtime.Value) ExtensionPackage {
	values := value.as_map() or {
		return ExtensionPackage{
			name: value.as_string()
		}
	}
	return ExtensionPackage{
		name: if 'name' in values { values['name'].as_string() } else { value.repr }
		with: if 'with' in values { values['with'].as_string_array() or { [] } } else { [] }
	}
}

pub fn extension_packages_value(packages []ExtensionPackage) brew_runtime.Value {
	return brew_runtime.array_value(packages.map(extension_package_value(it)))
}

fn extension_packages_from_value(value brew_runtime.Value) []ExtensionPackage {
	values := value.as_array() or { return [] }
	return values.map(extension_package_from_value(it))
}

pub fn extension_entry_value(entry ExtensionEntry) brew_runtime.Value {
	return brew_runtime.map_value({
		'type':    brew_runtime.object_value('Symbol', entry.entry_type)
		'name':    brew_runtime.string_value(entry.name)
		'options': brew_runtime.map_value(entry.options)
	})
}

pub fn extension_entry_from_value(value brew_runtime.Value) ExtensionEntry {
	values := value.as_map() or { return ExtensionEntry{} }
	return ExtensionEntry{
		entry_type: if 'type' in values { values['type'].as_string() } else { '' }
		name: if 'name' in values { values['name'].as_string() } else { '' }
		options: if 'options' in values {
			values['options'].as_map() or { map[string]brew_runtime.Value{} }} else {
			map[string]brew_runtime.Value{}}
	}
}

fn extension_entries_from_value(value brew_runtime.Value) []ExtensionEntry {
	values := value.as_array() or { return [] }
	return values.map(extension_entry_from_value(it))
}

pub fn extension_state_value(state ExtensionState) brew_runtime.Value {
	return brew_runtime.map_value({
		'_definition':        extension_definition_value(state.definition)
		'executable':         brew_runtime.string_value(state.executable)
		'packages':           extension_packages_value(state.packages)
		'installed_packages': extension_packages_value(state.installed_packages)
		'output':             brew_runtime.string_array_value(state.output)
		'uninstalled':        brew_runtime.string_array_value(state.uninstalled)
		'reset_count':        brew_runtime.int_value(state.reset_count)
	})
}

pub fn extension_state_from_value(value brew_runtime.Value) ExtensionState {
	values := value.as_map() or {
		return ExtensionState{
			definition: extension_definition_from_value(value)
		}
	}
	return ExtensionState{
		definition: extension_definition_from_value(value)
		executable: if 'executable' in values { values['executable'].as_string() } else { '' }
		packages: if 'packages' in values {
			extension_packages_from_value(values['packages'])} else {
			[]}
		installed_packages: if 'installed_packages' in values {
			extension_packages_from_value(values['installed_packages'])} else {
			[]}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		uninstalled: if 'uninstalled' in values {
			values['uninstalled'].as_string_array() or { [] }} else {
			[]}
		reset_count: if 'reset_count' in values {
			int(values['reset_count'].as_int() or { 0 })} else {
			0}
	}
}

pub fn extension_definitions_value(definitions []ExtensionDefinition) brew_runtime.Value {
	return brew_runtime.array_value(definitions.map(extension_definition_value(it)))
}

fn extension_definitions_from_value(value brew_runtime.Value) []ExtensionDefinition {
	values := value.as_array() or { return [] }
	return values.map(extension_definition_from_value(it))
}

pub fn extension_registry_value(registry ExtensionRegistry) brew_runtime.Value {
	return brew_runtime.map_value({
		'extensions':    extension_definitions_value(registry.extensions)
		'package_types': extension_definitions_value(registry.package_types)
	})
}

pub fn extension_registry_from_value(value brew_runtime.Value) ExtensionRegistry {
	values := value.as_map() or { return ExtensionRegistry{} }
	return ExtensionRegistry{
		extensions: if 'extensions' in values {
			extension_definitions_from_value(values['extensions'])} else {
			[]}
		package_types: if 'package_types' in values {
			extension_definitions_from_value(values['package_types'])} else {
			[]}
	}
}

fn extension_state_from_boundary(args []brew_runtime.Value) !ExtensionState {
	if args.len == 0 {
		return error('extension receiver is required')
	}
	return extension_state_from_value(args[0])
}

fn extension_definition_from_boundary(args []brew_runtime.Value) !ExtensionDefinition {
	if args.len == 0 {
		return error('extension receiver is required')
	}
	return extension_definition_from_value(args[0])
}

fn extension_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

fn extension_boundary_error(type_name string, message string) brew_runtime.Value {
	return brew_runtime.object_value(type_name, message)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/package_type"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     ExtensionTypes = T.type_alias { T::Hash[Symbol, T::Boolean] }
// 9:
// 10:     class Extension < Homebrew::Bundle::PackageType
// 11:       extend T::Helpers
// 12:
// 13:       abstract!
// 14:
// 15:       sig { override.params(subclass: T.class_of(Homebrew::Bundle::PackageType)).void }
// 16:       def self.inherited(subclass)
// 17:         super
// 18:         Homebrew::Bundle.register_extension(T.cast(subclass, T.class_of(Homebrew::Bundle::Extension)))
// 19:       end
// 20:
// 21:       sig { abstract.returns(String) }
// 22:       def self.banner_name; end
// 23:
// 24:       sig { params(description: String).returns(String) }
// 25:       def self.switch_description(description)
// 26:         description
// 27:       end
// 28:
// 29:       sig { params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 30:       def self.entry(name, options = {})
// 31:         raise "unknown options(#{options.keys.inspect}) for #{type}" if options.present?
// 32:
// 33:         Dsl::Entry.new(type, name)
// 34:       end
// 35:
// 36:       sig { returns(String) }
// 37:       def self.flag
// 38:         type.to_s.tr("_", "-")
// 39:       end
// 40:
// 41:       sig { returns(Symbol) }
// 42:       def self.predicate_method
// 43:         :"#{type}?"
// 44:       end
// 45:
// 46:       sig { returns(String) }
// 47:       def self.package_manager_name
// 48:         flag
// 49:       end
// 50:
// 51:       sig { returns(T::Boolean) }
// 52:       def self.package_manager_installed?
// 53:         package_manager_executable.present?
// 54:       end
// 55:
// 56:       sig { returns(T.nilable(Pathname)) }
// 57:       def self.package_manager_executable
// 58:         which(package_manager_name, ORIGINAL_PATHS)
// 59:       end
// 60:
// 61:       sig { returns(Pathname) }
// 62:       def self.package_manager_executable!
// 63:         package_manager_executable || raise("#{package_manager_name} is not installed")
// 64:       end
// 65:
// 66:       sig { params(executable: Pathname).returns(T::Hash[String, String]) }
// 67:       def self.package_manager_env(executable)
// 68:         { "PATH" => "#{executable.dirname}:#{ORIGINAL_PATHS.join(":")}" }
// 69:       end
// 70:
// 71:       sig {
// 72:         type_parameters(:U)
// 73:           .params(_blk: T.proc.params(executable: Pathname).returns(T.type_parameter(:U)))
// 74:           .returns(T.type_parameter(:U))
// 75:       }
// 76:       def self.with_package_manager_env(&_blk)
// 77:         executable = package_manager_executable!
// 78:         with_env(package_manager_env(executable)) { yield executable }
// 79:       end
// 80:
// 81:       sig { returns(String) }
// 82:       def self.package_description
// 83:         check_label.downcase
// 84:       end
// 85:
// 86:       sig { returns(T::Boolean) }
// 87:       def self.dump_supported?
// 88:         true
// 89:       end
// 90:
// 91:       sig { returns(String) }
// 92:       def self.dump_disable_description
// 93:         "`dump` without #{banner_name}."
// 94:       end
// 95:
// 96:       sig { returns(Symbol) }
// 97:       def self.dump_disable_env
// 98:         :"bundle_dump_no_#{type}"
// 99:       end
// 100:
// 101:       sig { returns(Symbol) }
// 102:       def self.cleanup_disable_env
// 103:         :"bundle_cleanup_no_#{type}"
// 104:       end
// 105:
// 106:       sig { returns(T::Boolean) }
// 107:       def self.dump_disable_supported?
// 108:         true
// 109:       end
// 110:
// 111:       sig { returns(String) }
// 112:       def self.cleanup_disable_description
// 113:         "`cleanup` without #{banner_name}."
// 114:       end
// 115:
// 116:       sig { returns(Symbol) }
// 117:       def self.dump_disable_predicate_method
// 118:         disable_predicate_method
// 119:       end
// 120:
// 121:       sig { returns(Symbol) }
// 122:       def self.disable_predicate_method
// 123:         :"no_#{type}?"
// 124:       end
// 125:
// 126:       sig { returns(T::Boolean) }
// 127:       def self.add_supported?
// 128:         true
// 129:       end
// 130:
// 131:       sig { returns(T::Boolean) }
// 132:       def self.remove_supported?
// 133:         true
// 134:       end
// 135:
// 136:       sig { returns(T::Boolean) }
// 137:       def self.install_supported?
// 138:         true
// 139:       end
// 140:
// 141:       sig { override.params(_name: String, _options: Homebrew::Bundle::EntryOptions).returns(String) }
// 142:       def self.install_verb(_name = "", _options = {})
// 143:         "Installing"
// 144:       end
// 145:
// 146:       sig {
// 147:         params(
// 148:           name:       String,
// 149:           options:    Homebrew::Bundle::EntryOptions,
// 150:           no_upgrade: T::Boolean,
// 151:         ).returns(T.nilable(String))
// 152:       }
// 153:       def self.fetchable_name(name, options = {}, no_upgrade: false)
// 154:         _ = name
// 155:         _ = options
// 156:         _ = no_upgrade
// 157:
// 158:         nil
// 159:       end
// 160:
// 161:       sig { returns(T.nilable(String)) }
// 162:       def self.cleanup_heading
// 163:         nil
// 164:       end
// 165:
// 166:       sig { returns(T::Boolean) }
// 167:       def self.cleanup_supported?
// 168:         !cleanup_heading.nil?
// 169:       end
// 170:
// 171:       sig { abstract.void }
// 172:       def self.reset!; end
// 173:
// 174:       sig { abstract.returns(T::Array[T.untyped]) }
// 175:       def self.packages; end
// 176:
// 177:       sig { abstract.returns(T::Array[T.untyped]) }
// 178:       def self.installed_packages; end
// 179:
// 180:       sig { params(package: Object).returns(String) }
// 181:       def self.dump_entry(package)
// 182:         line = "#{type} #{quote(dump_name(package))}"
// 183:         with = dump_with(package)
// 184:         return line if with.blank?
// 185:
// 186:         formatted_with = with.map { |requirement| quote(requirement) }.join(", ")
// 187:         "#{line}, with: [#{formatted_with}]"
// 188:       end
// 189:
// 190:       sig { params(value: String).returns(String) }
// 191:       def self.quote(value)
// 192:         value.inspect
// 193:       end
// 194:
// 195:       sig { params(package: Object).returns(String) }
// 196:       def self.dump_name(package)
// 197:         package.to_s
// 198:       end
// 199:
// 200:       sig { params(_package: Object).returns(T.nilable(T::Array[String])) }
// 201:       def self.dump_with(_package)
// 202:         nil
// 203:       end
// 204:
// 205:       sig { override.returns(String) }
// 206:       def self.dump
// 207:         packages.map { |package| dump_entry(package) }.join("\n")
// 208:       end
// 209:
// 210:       sig { params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 211:       def self.dump_output(describe: false, no_restart: false)
// 212:         _ = describe
// 213:         _ = no_restart
// 214:
// 215:         dump
// 216:       end
// 217:
// 218:       sig {
// 219:         params(
// 220:           entries:             T::Array[Dsl::Entry],
// 221:           exit_on_first_error: T::Boolean,
// 222:           no_upgrade:          T::Boolean,
// 223:           verbose:             T::Boolean,
// 224:         ).returns(T::Array[String])
// 225:       }
// 226:       def self.check(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 227:         new.find_actionable(entries, exit_on_first_error:, no_upgrade:, verbose:)
// 228:       end
// 229:
// 230:       sig { params(entries: T::Array[Dsl::Entry]).returns(T::Array[String]) }
// 231:       def self.cleanup_items(entries)
// 232:         return [].freeze unless package_manager_installed?
// 233:
// 234:         kept_packages = entries.filter_map do |entry|
// 235:           entry.name if entry.type == type
// 236:         end
// 237:
// 238:         return [].freeze if kept_packages.empty?
// 239:
// 240:         installed_names = packages.map { |pkg| dump_name(pkg) }
// 241:         installed_names - kept_packages
// 242:       end
// 243:
// 244:       sig { params(item: String).returns(String) }
// 245:       def self.cleanup_item_name(item)
// 246:         item
// 247:       end
// 248:
// 249:       sig { returns(Symbol) }
// 250:       def self.legacy_check_step
// 251:         :registered_extensions_to_install
// 252:       end
// 253:
// 254:       sig { params(items: T::Array[String]).void }
// 255:       def self.cleanup!(items)
// 256:         executable = package_manager_executable
// 257:         return if executable.nil?
// 258:
// 259:         with_env(package_manager_env(executable)) do
// 260:           items.each do |name|
// 261:             uninstall_package!(name, executable:)
// 262:           end
// 263:         end
// 264:         puts "Uninstalled #{items.size} #{banner_name}#{"s" if items.size != 1}"
// 265:       end
// 266:
// 267:       sig { params(name: String, executable: Pathname).void }
// 268:       def self.uninstall_package!(name, executable: Pathname.new(""))
// 269:         raise NotImplementedError, "#{self} must override `uninstall_package!` or `cleanup!`."
// 270:       end
// 271:
// 272:       sig { params(name: String, with: T.nilable(T::Array[String])).returns(Object) }
// 273:       def self.package_record(name, with: nil)
// 274:         _ = with
// 275:
// 276:         name
// 277:       end
// 278:
// 279:       sig { params(name: String, with: T.nilable(T::Array[String])).returns(T::Boolean) }
// 280:       def self.package_installed?(name, with: nil)
// 281:         installed_packages.include?(package_record(name, with:))
// 282:       end
// 283:
// 284:       sig {
// 285:         override.params(
// 286:           name:       String,
// 287:           with:       T.nilable(T::Array[String]),
// 288:           no_upgrade: T::Boolean,
// 289:           verbose:    T::Boolean,
// 290:           _options:   Homebrew::Bundle::EntryOption,
// 291:         ).returns(T::Boolean)
// 292:       }
// 293:       def self.preinstall!(name, with: nil, no_upgrade: false, verbose: false, **_options)
// 294:         _ = no_upgrade
// 295:
// 296:         ensure_package_manager_installed!(name, verbose:)
// 297:
// 298:         if package_installed?(name, with:)
// 299:           puts "Skipping install of #{name} #{package_description}. It is already installed." if verbose
// 300:           return false
// 301:         end
// 302:
// 303:         true
// 304:       end
// 305:
// 306:       sig { params(name: String, verbose: T::Boolean).void }
// 307:       def self.ensure_package_manager_installed!(name, verbose: false)
// 308:         return if package_manager_installed?
// 309:
// 310:         puts "Installing #{package_manager_name}. It is not currently installed." if verbose
// 311:         Bundle.system(HOMEBREW_BREW_FILE, "install", "--formula", package_manager_name, verbose:)
// 312:         # `formula_versions_from_env` consumes the env vars once at startup, so
// 313:         # keep the cached values across reset when bootstrapping a manager.
// 314:         formula_versions_from_env = T.let(
// 315:           Bundle.formula_versions_from_env_cache,
// 316:           T.nilable(T::Hash[String, String]),
// 317:         )
// 318:         upgrade_formulae = Bundle.upgrade_formulae
// 319:         Bundle.reset!
// 320:         Bundle.formula_versions_from_env_cache = formula_versions_from_env
// 321:         Bundle.upgrade_formulae = upgrade_formulae.join(",")
// 322:         return if package_manager_installed?
// 323:
// 324:         raise "Unable to install #{name} #{package_description}. " \
// 325:               "#{package_manager_name} installation failed."
// 326:       end
// 327:
// 328:       sig {
// 329:         override.params(
// 330:           name:       String,
// 331:           with:       T.nilable(T::Array[String]),
// 332:           preinstall: T::Boolean,
// 333:           no_upgrade: T::Boolean,
// 334:           verbose:    T::Boolean,
// 335:           force:      T::Boolean,
// 336:           _options:   Homebrew::Bundle::EntryOption,
// 337:         ).returns(T::Boolean)
// 338:       }
// 339:       def self.install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 340:                         **_options)
// 341:         _ = no_upgrade
// 342:         _ = force
// 343:
// 344:         return true unless preinstall
// 345:
// 346:         puts "Installing #{name} #{package_description}. It is not currently installed." if verbose
// 347:         return false unless install_package!(name, with:, verbose:)
// 348:
// 349:         package = package_record(name, with:)
// 350:         installed_packages << package unless installed_packages.include?(package)
// 351:         packages << package unless packages.include?(package)
// 352:         true
// 353:       end
// 354:
// 355:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(String) }
// 356:       def failure_reason(package, no_upgrade:)
// 357:         "#{self.class.check_label} #{self.class.dump_name(package)} needs to be installed."
// 358:       end
// 359:
// 360:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 361:       def installed_and_up_to_date?(package, no_upgrade: false)
// 362:         self.class.package_installed?(self.class.dump_name(package), with: self.class.dump_with(package))
// 363:       end
// 364:
// 365:       sig {
// 366:         overridable.params(
// 367:           name:    String,
// 368:           with:    T.nilable(T::Array[String]),
// 369:           verbose: T::Boolean,
// 370:         ).returns(T::Boolean)
// 371:       }
// 372:       def self.install_package!(name, with: nil, verbose: false)
// 373:         _ = name
// 374:         _ = with
// 375:         _ = verbose
// 376:
// 377:         raise NotImplementedError, "#{self} must override `install_package!` or `install!`."
// 378:       end
// 379:     end
// 380:
// 381:     class << self
// 382:       sig { params(extension: T.class_of(Extension)).void }
// 383:       def register_extension(extension)
// 384:         @extensions ||= T.let([], T.nilable(T::Array[T.class_of(Extension)]))
// 385:         @extensions.reject! { |registered| registered.name == extension.name }
// 386:         @extensions << extension
// 387:       end
// 388:
// 389:       sig { returns(T::Array[T.class_of(Extension)]) }
// 390:       def extensions
// 391:         @extensions ||= T.let([], T.nilable(T::Array[T.class_of(Extension)]))
// 392:         @extensions
// 393:       end
// 394:
// 395:       sig { params(type: T.any(Symbol, String)).returns(T.nilable(T.class_of(Extension))) }
// 396:       def extension(type)
// 397:         requested_type = type.to_sym
// 398:         extensions.find { |registered| registered.type == requested_type }
// 399:       end
// 400:
// 401:       sig {
// 402:         params(
// 403:           type: T.any(Symbol, String),
// 404:         ).returns(T.nilable(T.class_of(PackageType)))
// 405:       }
// 406:       def installable(type)
// 407:         package_type(type) || extension(type)
// 408:       end
// 409:     end
// 410:   end
// 411: end
