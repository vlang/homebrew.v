module extensions

import ruby
import os

// Translated from Homebrew/brew `bundle/extensions/go.rb`.
@[heap]
pub struct GoState {
pub mut:
	executable                string
	gobin                     string
	gopath                    string
	packages                  []string
	packages_loaded           bool
	installed_packages        []string
	installed_packages_loaded bool
	version_outputs           map[string]string
	output                    []string
	commands                  [][]string
	removed_binaries          []string
}

pub fn new_go_state() &GoState {
	return &GoState{
		version_outputs: map[string]string{}
	}
}

pub fn go_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Go'
		type_name: 'go'
		banner_name: 'Go packages'
		check_label: 'Go Package'
		cleanup_heading: 'Go packages'
	}
}

pub fn go_bin_directory(gobin string, gopath string) string {
	return if gobin == '' { os.join_path(gopath, 'bin') } else { gobin }
}

pub fn go_module_path(output string) ?string {
	for line in output.split_into_lines() {
		if !line.trim_space().starts_with('path\t') {
			continue
		}
		parts := line.split('\t')
		if parts.len < 3 {
			return none
		}
		path := parts[2].trim_space()
		if path == '' || path == 'command-line-arguments' {
			return none
		}
		return path
	}
	return none
}

pub fn go_discover_packages(bin_directory string, version_outputs map[string]string) []string {
	if !os.is_dir(bin_directory) {
		return []
	}
	mut packages := []string{}
	mut names := os.ls(bin_directory) or { return [] }
	names.sort()
	for name in names {
		binary := os.join_path(bin_directory, name)
		if !os.is_file(binary) || !os.is_executable(binary) || os.is_link(binary) {
			continue
		}
		output := version_outputs[binary] or { continue }
		package := go_module_path(output) or { continue }
		if package !in packages {
			packages << package
		}
	}
	return packages
}

pub fn go_dump(packages []string) string {
	return packages.map(extension_dump_entry(go_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn go_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'go' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn go_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} go package. go installation failed.')
	}
	return name !in installed
}

pub fn (mut state GoState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
}

pub fn (mut state GoState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' {
		[]
	} else {
		go_discover_packages(go_bin_directory(state.gobin, state.gopath), state.version_outputs)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state GoState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state GoState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('go is not installed')
	}
	state.commands << [state.executable, 'install', '${name}@latest']
	return result
}

pub fn (mut state GoState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} go package. It is not currently installed.'
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

pub fn (mut state GoState) cleanup(items []string) !int {
	if state.executable == '' {
		return 0
	}
	bin_directory := go_bin_directory(state.gobin, state.gopath)
	if !os.is_dir(bin_directory) {
		return 0
	}
	mut removed := 0
	mut names := os.ls(bin_directory)!
	names.sort()
	for name in names {
		binary := os.join_path(bin_directory, name)
		if !os.is_file(binary) || !os.is_executable(binary) || os.is_link(binary) {
			continue
		}
		output := state.version_outputs[binary] or { continue }
		module_path := go_module_path(output) or { continue }
		if module_path !in items {
			continue
		}
		os.rm(binary)!
		state.removed_binaries << binary
		removed++
	}
	suffix := if removed == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${removed} ${go_definition().banner_name}${suffix}'
	return removed
}

fn go_state_value(state &GoState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Go', '', {
		'go_state_address': u64(voidptr(state)).str()
	})
}

fn go_state_from_args(args []ruby.Value, method string) &GoState {
	if args.len == 0 || 'go_state_address' !in args[0].attributes {
		panic('Go.${method} requires translated Go state')
	}
	return unsafe { &GoState(voidptr(args[0].attributes['go_state_address'].u64())) }
}

pub fn go_state_boundary(state &GoState) ruby.Value {
	return go_state_value(state)
}
