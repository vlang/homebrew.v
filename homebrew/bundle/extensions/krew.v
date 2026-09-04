module extensions

import ruby
import os

// Translated from Homebrew/brew `bundle/extensions/krew.rb`.
@[heap]
pub struct KrewState {
pub mut:
	executable                string
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

pub fn new_krew_state() &KrewState {
	return &KrewState{
		last_environment: map[string]string{}
	}
}

pub fn krew_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Krew'
		type_name: 'krew'
		banner_name: 'Krew plugins'
		check_label: 'Krew Plugin'
		cleanup_heading: 'Krew plugins'
	}
}

pub fn krew_parse_plugin_list(output string) []string {
	mut plugins := []string{}
	for line in output.split_into_lines() {
		fields := line.trim_space().fields()
		if fields.len == 0 || fields[0] in plugins {
			continue
		}
		plugins << fields[0]
	}
	return plugins
}

pub fn krew_environment(executable string, original_path string) map[string]string {
	return {
		'PATH': '${os.dir(executable)}:${original_path}'
	}
}

pub fn krew_dump(packages []string) string {
	return packages.map(extension_dump_entry(krew_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn krew_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'krew' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn krew_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} krew plugin. krew installation failed.')
	}
	return name !in installed
}

pub fn (mut state KrewState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
	state.executable = ''
}

pub fn (mut state KrewState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' {
		[]
	} else {
		state.last_environment = krew_environment(state.executable, state.original_path)
		krew_parse_plugin_list(state.list_output)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state KrewState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state KrewState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('krew is not installed')
	}
	state.last_environment = krew_environment(state.executable, state.original_path)
	state.commands << [state.executable, 'install', name]
	return result
}

pub fn (mut state KrewState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} krew plugin. It is not currently installed.'
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

pub fn (mut state KrewState) uninstall(name string, executable string) {
	state.last_environment = krew_environment(executable, state.original_path)
	state.commands << [executable, 'uninstall', name]
}

pub fn (mut state KrewState) cleanup(items []string) {
	if state.executable == '' {
		return
	}
	for item in items {
		state.uninstall(item, state.executable)
	}
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} ${krew_definition().banner_name}${suffix}'
}

fn krew_state_value(state &KrewState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Krew', '', {
		'krew_state_address': u64(voidptr(state)).str()
	})
}

fn krew_state_from_args(args []ruby.Value, method string) &KrewState {
	if args.len == 0 || 'krew_state_address' !in args[0].attributes {
		panic('Krew.${method} requires translated Krew state')
	}
	return unsafe { &KrewState(voidptr(args[0].attributes['krew_state_address'].u64())) }
}

pub fn krew_state_boundary(state &KrewState) ruby.Value {
	return krew_state_value(state)
}
