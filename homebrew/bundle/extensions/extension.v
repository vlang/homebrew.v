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
