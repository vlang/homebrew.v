module extensions

import ruby
import os

// Translated from Homebrew/brew `bundle/extensions/vscode_extension.rb`.
@[heap]
pub struct VscodeExtensionState {
pub mut:
	executable                  string
	original_paths              []string
	list_output                 string
	wsl_distro_name             string
	extensions                  []string
	extensions_loaded           bool
	installed_extensions        []string
	installed_extensions_loaded bool
	cask_installed              bool
	brew_file                   string
	environment                 map[string]string
	commands                    [][]string
	output                      []string
}

pub fn new_vscode_extension_state() &VscodeExtensionState {
	return &VscodeExtensionState{
		environment: map[string]string{}
	}
}

pub fn vscode_extension_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::VscodeExtension'
		type_name: 'vscode'
		banner_name: 'VSCode (and forks/variants) extensions'
		check_label: 'VSCode Extension'
		cleanup_heading: 'VSCode extensions'
	}
}

fn vscode_ascii_alphanumeric(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`)
}

pub fn vscode_valid_extension_id(value string) bool {
	dot := value.index('.') or { return false }
	if dot == 0 || dot == value.len - 1 {
		return false
	}
	for index, character in value.bytes() {
		if index == dot || vscode_ascii_alphanumeric(character) {
			continue
		}
		if index < dot {
			if character != `-` {
				return false
			}
		} else if character !in [`-`, `_`, `.`] {
			return false
		}
	}
	return vscode_ascii_alphanumeric(value[0]) && vscode_ascii_alphanumeric(value[dot + 1])
}

pub fn vscode_parse_extensions(output string) []string {
	mut extensions := []string{}
	for line in output.split_into_lines() {
		extension := line.trim_space()
		if vscode_valid_extension_id(extension) {
			extensions << extension.to_lower()
		}
	}
	return extensions
}

pub fn vscode_find_executable(paths []string) string {
	for executable in ['code', 'codium', 'cursor', 'code-insiders'] {
		for path in paths {
			candidate := os.join_path(path, executable)
			if os.is_file(candidate) && os.is_executable(candidate) {
				return candidate
			}
		}
	}
	return ''
}

pub fn vscode_package_record(name string) string {
	return name.to_lower()
}

pub fn vscode_dump(extensions []string) string {
	return extensions.map(extension_dump_entry(vscode_extension_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn vscode_cleanup_items(entries []ExtensionEntry, extensions []string) []string {
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'vscode' {
			kept << entry.name.to_lower()
		}
	}
	if kept.len == 0 {
		return []
	}
	return extensions.filter(it !in kept)
}

pub fn (mut state VscodeExtensionState) reset() {
	state.extensions = []
	state.extensions_loaded = false
	state.installed_extensions = []
	state.installed_extensions_loaded = false
}

pub fn (mut state VscodeExtensionState) package_manager_executable() string {
	if state.executable != '' {
		return state.executable
	}
	state.executable = vscode_find_executable(state.original_paths)
	return state.executable
}

pub fn (mut state VscodeExtensionState) discover_extensions() []string {
	if state.extensions_loaded {
		return state.extensions.clone()
	}
	state.extensions = if state.package_manager_executable() == '' {
		[]
	} else {
		state.environment['WSL_DISTRO_NAME'] = state.wsl_distro_name
		vscode_parse_extensions(state.list_output)
	}
	state.extensions_loaded = true
	return state.extensions.clone()
}

pub fn (mut state VscodeExtensionState) discover_installed_extensions() []string {
	if state.installed_extensions_loaded {
		return state.installed_extensions.clone()
	}
	state.installed_extensions = state.discover_extensions()
	state.installed_extensions_loaded = true
	return state.installed_extensions.clone()
}

pub fn (mut state VscodeExtensionState) preinstall(name string, verbose bool) !bool {
	if state.package_manager_executable() == '' && state.cask_installed {
		if verbose {
			state.output << 'Installing visual-studio-code. It is not currently installed.'
		}
		state.commands << [state.brew_file, 'install', '--cask', 'visual-studio-code']
	}
	if vscode_package_record(name) in state.discover_installed_extensions() {
		if verbose {
			state.output << 'Skipping install of ${name} VSCode extension. It is already installed.'
		}
		return false
	}
	if state.package_manager_executable() == '' {
		return error('Unable to install ${name} VSCode extension. VSCode is not installed.')
	}
	return true
}

pub fn (mut state VscodeExtensionState) install_package(name string, result bool) !bool {
	executable := state.package_manager_executable()
	if executable == '' {
		return error('vscode is not installed')
	}
	state.commands << [executable, '--install-extension', name]
	return result
}

pub fn (mut state VscodeExtensionState) install(name string, preinstall bool, verbose bool,
	result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} VSCode extension. It is not currently installed.'
	}
	if !state.install_package(name, result)! {
		return false
	}
	package := vscode_package_record(name)
	if package !in state.discover_installed_extensions() {
		state.installed_extensions << package
	}
	if state.extensions_loaded {
		if package !in state.extensions {
			state.extensions << package
		}
	} else {
		state.extensions = [package]
		state.extensions_loaded = true
	}
	return true
}

pub fn (mut state VscodeExtensionState) cleanup(extensions []string) {
	executable := state.package_manager_executable()
	if executable == '' {
		return
	}
	for extension in extensions {
		state.commands << [executable, '--uninstall-extension', extension]
	}
}

fn vscode_state_value(state &VscodeExtensionState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::VscodeExtension', '', {
		'vscode_state_address': u64(voidptr(state)).str()
	})
}

fn vscode_state_from_args(args []ruby.Value, method string) &VscodeExtensionState {
	if args.len == 0 || 'vscode_state_address' !in args[0].attributes {
		panic('VscodeExtension.${method} requires translated state')
	}
	return unsafe { &VscodeExtensionState(voidptr(args[0].attributes['vscode_state_address'].u64())) }
}

pub fn vscode_extension_state_boundary(state &VscodeExtensionState) ruby.Value {
	return vscode_state_value(state)
}
