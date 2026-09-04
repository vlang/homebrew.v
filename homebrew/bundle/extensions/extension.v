module extensions

import ruby
import json2
import os

// Translated from Homebrew/brew `bundle/extensions/extension.rb`.
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
	options    map[string]ruby.Value
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

pub type ExtensionExecutableLookup = fn (name string, paths []string) !string

pub type ExtensionEnvironmentRunner = fn (executable string, environment map[string]string) !string

pub type ExtensionActionableFinder = fn (entries []ExtensionEntry, exit_on_first_error bool, no_upgrade bool, verbose bool) ![]string

pub type ExtensionResetter = fn () !

pub type ExtensionManagerInstaller = fn (manager string, package_name string, verbose bool) !string

pub type ExtensionPackageInstaller = fn (name string, with []string, verbose bool) !bool

pub type ExtensionPackageUninstaller = fn (name string, executable string, environment map[string]string) !

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
	options map[string]ruby.Value) !ExtensionEntry {
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
		options: map[string]ruby.Value{}
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

pub fn extension_definition_value(definition ExtensionDefinition) ruby.Value {
	cleanup_heading := if heading := definition.cleanup_heading {
		ruby.string_value(heading)
	} else {
		ruby.object_value('NilClass', '')
	}
	return ruby.map_value({
		'class_name':      ruby.string_value(definition.class_name)
		'type_name':       ruby.string_value(definition.type_name)
		'banner_name':     ruby.string_value(definition.banner_name)
		'check_label':     ruby.string_value(definition.check_label)
		'original_paths':  ruby.string_array_value(definition.original_paths)
		'cleanup_heading': cleanup_heading
	})
}

pub fn extension_definition_from_value(value ruby.Value) ExtensionDefinition {
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
			values['original_paths'].as_string_array() or { [] }
		} else {
			[]
		}
		cleanup_heading: if 'cleanup_heading' in values && values['cleanup_heading'].type_name != 'NilClass' {
			values['cleanup_heading'].as_string()
		} else {
			none
		}
	}
}

pub fn extension_package_value(package ExtensionPackage) ruby.Value {
	return ruby.map_value({
		'name': ruby.string_value(package.name)
		'with': ruby.string_array_value(package.with)
	})
}

pub fn extension_package_from_value(value ruby.Value) ExtensionPackage {
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

pub fn extension_packages_value(packages []ExtensionPackage) ruby.Value {
	return ruby.array_value(packages.map(extension_package_value(it)))
}

fn extension_packages_from_value(value ruby.Value) []ExtensionPackage {
	values := value.as_array() or { return [] }
	return values.map(extension_package_from_value(it))
}

pub fn extension_entry_value(entry ExtensionEntry) ruby.Value {
	return ruby.map_value({
		'type':    ruby.object_value('Symbol', entry.entry_type)
		'name':    ruby.string_value(entry.name)
		'options': ruby.map_value(entry.options)
	})
}

pub fn extension_entry_from_value(value ruby.Value) ExtensionEntry {
	values := value.as_map() or { return ExtensionEntry{} }
	return ExtensionEntry{
		entry_type: if 'type' in values { values['type'].as_string() } else { '' }
		name: if 'name' in values { values['name'].as_string() } else { '' }
		options: if 'options' in values {
			values['options'].as_map() or { map[string]ruby.Value{} }
		} else {
			map[string]ruby.Value{}
		}
	}
}

fn extension_entries_from_value(value ruby.Value) []ExtensionEntry {
	values := value.as_array() or { return [] }
	return values.map(extension_entry_from_value(it))
}

pub fn extension_state_value(state ExtensionState) ruby.Value {
	return ruby.map_value({
		'_definition':        extension_definition_value(state.definition)
		'executable':         ruby.string_value(state.executable)
		'packages':           extension_packages_value(state.packages)
		'installed_packages': extension_packages_value(state.installed_packages)
		'output':             ruby.string_array_value(state.output)
		'uninstalled':        ruby.string_array_value(state.uninstalled)
		'reset_count':        ruby.int_value(state.reset_count)
	})
}

pub fn extension_state_from_value(value ruby.Value) ExtensionState {
	values := value.as_map() or {
		return ExtensionState{
			definition: extension_definition_from_value(value)
		}
	}
	return ExtensionState{
		definition: extension_definition_from_value(value)
		executable: if 'executable' in values { values['executable'].as_string() } else { '' }
		packages: if 'packages' in values {
			extension_packages_from_value(values['packages'])
		} else {
			[]
		}
		installed_packages: if 'installed_packages' in values {
			extension_packages_from_value(values['installed_packages'])
		} else {
			[]
		}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		uninstalled: if 'uninstalled' in values {
			values['uninstalled'].as_string_array() or { [] }
		} else {
			[]
		}
		reset_count: if 'reset_count' in values {
			int(values['reset_count'].as_int() or { 0 })
		} else {
			0
		}
	}
}

pub fn extension_definitions_value(definitions []ExtensionDefinition) ruby.Value {
	return ruby.array_value(definitions.map(extension_definition_value(it)))
}

fn extension_definitions_from_value(value ruby.Value) []ExtensionDefinition {
	values := value.as_array() or { return [] }
	return values.map(extension_definition_from_value(it))
}

pub fn extension_registry_value(registry ExtensionRegistry) ruby.Value {
	return ruby.map_value({
		'extensions':    extension_definitions_value(registry.extensions)
		'package_types': extension_definitions_value(registry.package_types)
	})
}

pub fn extension_registry_from_value(value ruby.Value) ExtensionRegistry {
	values := value.as_map() or { return ExtensionRegistry{} }
	return ExtensionRegistry{
		extensions: if 'extensions' in values {
			extension_definitions_from_value(values['extensions'])
		} else {
			[]
		}
		package_types: if 'package_types' in values {
			extension_definitions_from_value(values['package_types'])
		} else {
			[]
		}
	}
}

fn extension_state_from_boundary(args []ruby.Value) !ExtensionState {
	if args.len == 0 {
		return error('extension receiver is required')
	}
	return extension_state_from_value(args[0])
}

fn extension_definition_from_boundary(args []ruby.Value) !ExtensionDefinition {
	if args.len == 0 {
		return error('extension receiver is required')
	}
	return extension_definition_from_value(args[0])
}

fn extension_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn extension_boundary_error(type_name string, message string) ruby.Value {
	return ruby.object_value(type_name, message)
}
