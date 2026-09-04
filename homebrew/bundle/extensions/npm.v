module extensions

import ruby
import homebrew.language
import os
import x.json2

// Translated from Homebrew/brew `bundle/extensions/npm.rb`.
@[heap]
pub struct NpmState {
pub mut:
	executable                string
	executable_exists         bool
	cache_dir                 string
	original_path             string
	list_output               string
	packages                  []string
	packages_loaded           bool
	installed_packages        []string
	installed_packages_loaded bool
	last_environment          map[string]string
	commands                  [][]string
	output                    []string
}

pub fn new_npm_state() &NpmState {
	return &NpmState{
		last_environment: map[string]string{}
	}
}

pub fn npm_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Npm'
		type_name: 'npm'
		banner_name: 'npm packages'
		check_label: 'npm Package'
		cleanup_heading: 'npm packages'
	}
}

pub fn npm_parse_package_list(output string) []string {
	if output.trim_space() == '' {
		return []
	}
	decoded := json2.decode[json2.Any](output) or { return [] }
	if decoded !is map[string]json2.Any {
		return []
	}
	root := decoded as map[string]json2.Any
	dependencies_value := root['dependencies'] or { return [] }
	if dependencies_value !is map[string]json2.Any {
		return []
	}
	mut packages := []string{}
	for name in (dependencies_value as map[string]json2.Any).keys() {
		if name != 'npm' {
			packages << name
		}
	}
	return packages
}

pub fn npm_listing_environment(executable string, original_path string) map[string]string {
	return {
		'PATH': '${os.dir(executable)}:${original_path}'
	}
}

pub fn npm_install_command(executable string, cache_dir string, name string) []string {
	mut command := [executable, 'install']
	command << language.npm_install_security_args(cache_dir, true)
	command << '-g'
	command << name
	return command
}

pub fn npm_uninstall_command(executable string, name string) []string {
	return [executable, 'uninstall', '-g', name]
}

pub fn npm_dump(packages []string) string {
	return packages.map(extension_dump_entry(npm_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn npm_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'npm' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn npm_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} npm package. node installation failed.')
	}
	return name !in installed
}

pub fn (mut state NpmState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
}

pub fn (mut state NpmState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' || (state.executable.starts_with('/') && !state.executable_exists && !os.exists(state.executable)) {
		[]
	} else {
		state.last_environment = npm_listing_environment(state.executable, state.original_path)
		npm_parse_package_list(state.list_output)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state NpmState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state NpmState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('npm is not installed')
	}
	state.commands << npm_install_command(state.executable, state.cache_dir, name)
	return result
}

pub fn (mut state NpmState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} npm package. It is not currently installed.'
	}
	if !state.install_package(name, result)! {
		return false
	}
	if name !in state.discover_installed_packages() {
		state.installed_packages << name
	}
	if state.packages_loaded {
		if name !in state.packages {
			state.packages << name
		}
	} else {
		state.packages = [name]
		state.packages_loaded = true
	}
	return true
}

pub fn (mut state NpmState) uninstall(name string, executable string) {
	state.commands << npm_uninstall_command(executable, name)
}

fn npm_state_value(state &NpmState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Npm', '', {
		'npm_state_address': u64(voidptr(state)).str()
	})
}

fn npm_state_from_args(args []ruby.Value, method string) &NpmState {
	if args.len == 0 || 'npm_state_address' !in args[0].attributes {
		panic('Npm.${method} requires translated Npm state')
	}
	return unsafe { &NpmState(voidptr(args[0].attributes['npm_state_address'].u64())) }
}

pub fn npm_state_boundary(state &NpmState) ruby.Value {
	return npm_state_value(state)
}
