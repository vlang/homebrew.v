module extensions

import brew_runtime

pub struct FlatpakPackage {
pub:
	name       string
	remote     string
	remote_url string
}

pub struct FlatpakState {
pub mut:
	executable            string
	packages              []string
	packages_with_remotes []FlatpakPackage
	installed_packages    []FlatpakPackage
	remote_urls           map[string]string
	output                []string
	commands              [][]string
}

fn flatpak_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

pub fn flatpak_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Flatpak'
		type_name: 'flatpak'
		banner_name: 'Flatpak packages'
		check_label: 'Flatpak'
		cleanup_heading: 'flatpaks'
	}
}

pub fn flatpak_package_value(package FlatpakPackage) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':       brew_runtime.string_value(package.name)
		'remote':     brew_runtime.string_value(package.remote)
		'remote_url': if package.remote_url == '' {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.string_value(package.remote_url)
		}
	})
}

pub fn flatpak_package_from_value(value brew_runtime.Value) FlatpakPackage {
	values := value.as_map() or {
		return FlatpakPackage{
			name: value.as_string()
			remote: 'flathub'
		}
	}
	if 'options' in values {
		options := values['options'].as_map() or { map[string]brew_runtime.Value{} }
		return FlatpakPackage{
			name: if 'name' in values { values['name'].as_string() } else { '' }
			remote: if 'remote' in options { options['remote'].as_string() } else { 'flathub' }
			remote_url: if 'url' in options && options['url'].type_name != 'NilClass' {
				options['url'].as_string()} else {
				''}
		}
	}
	return FlatpakPackage{
		name: if 'name' in values { values['name'].as_string() } else { '' }
		remote: if 'remote' in values { values['remote'].as_string() } else { 'flathub' }
		remote_url: if 'remote_url' in values && values['remote_url'].type_name != 'NilClass' {
			values['remote_url'].as_string()} else {
			''}
	}
}

pub fn flatpak_packages_value(packages []FlatpakPackage) brew_runtime.Value {
	return brew_runtime.array_value(packages.map(flatpak_package_value(it)))
}

pub fn flatpak_packages_from_value(value brew_runtime.Value) []FlatpakPackage {
	items := value.as_array() or { return [] }
	return items.map(flatpak_package_from_value(it))
}

fn flatpak_string_map_value(values map[string]string) brew_runtime.Value {
	mut mapped := map[string]brew_runtime.Value{}
	for key, value in values {
		mapped[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(mapped)
}

fn flatpak_string_map_from_value(value brew_runtime.Value) map[string]string {
	values := value.as_map() or { return {} }
	mut mapped := map[string]string{}
	for key, item in values {
		mapped[key] = item.as_string()
	}
	return mapped
}

pub fn flatpak_state_value(state FlatpakState) brew_runtime.Value {
	return brew_runtime.map_value({
		'_definition':           extension_definition_value(flatpak_definition())
		'executable':            if state.executable == '' {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.object_value('Pathname', state.executable)
		}
		'packages':              brew_runtime.string_array_value(state.packages)
		'packages_with_remotes': flatpak_packages_value(state.packages_with_remotes)
		'installed_packages':    flatpak_packages_value(state.installed_packages)
		'remote_urls':           flatpak_string_map_value(state.remote_urls)
		'output':                brew_runtime.string_array_value(state.output)
		'commands':              brew_runtime.array_value(state.commands.map(brew_runtime.string_array_value(it)))
	})
}

pub fn flatpak_state_from_value(value brew_runtime.Value) FlatpakState {
	values := value.as_map() or { return FlatpakState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return FlatpakState{
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()} else {
			''}
		packages: if 'packages' in values {
			values['packages'].as_string_array() or { [] }} else {
			[]}
		packages_with_remotes: if 'packages_with_remotes' in values {
			flatpak_packages_from_value(values['packages_with_remotes'])} else {
			[]}
		installed_packages: if 'installed_packages' in values {
			flatpak_packages_from_value(values['installed_packages'])} else {
			[]}
		remote_urls: if 'remote_urls' in values {
			flatpak_string_map_from_value(values['remote_urls'])} else {
			map[string]string{}}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn flatpak_entry(name string, options map[string]brew_runtime.Value) !ExtensionEntry {
	mut unknown := []string{}
	for key in options.keys() {
		if key !in ['remote', 'url'] {
			unknown << ':${key}'
		}
	}
	if unknown.len > 0 {
		return error('unknown options([${unknown.join(', ')}]) for flatpak')
	}
	remote_value := options['remote'] or { brew_runtime.object_value('NilClass', '') }
	url_value := options['url'] or { brew_runtime.object_value('NilClass', '') }
	if remote_value.type_name !in ['String', 'NilClass'] {
		return error('options[:remote](${remote_value.repr}) should be a String object')
	}
	if url_value.type_name !in ['String', 'NilClass'] {
		return error('options[:url](${url_value.repr}) should be a String object')
	}
	remote := if remote_value.type_name == 'String' { remote_value.as_string() } else { 'flathub' }
	if url_value.type_name == 'String' && (remote.starts_with('http://') || remote.starts_with('https://')) {
		return error('url: parameter cannot be used when remote: is already a URL')
	}
	mut normalized := {
		'remote': brew_runtime.string_value(remote)
	}
	if url_value.type_name == 'String' {
		normalized['url'] = brew_runtime.string_value(url_value.as_string())
	}
	return ExtensionEntry{
		entry_type: 'flatpak'
		name: name
		options: normalized
	}
}

pub fn flatpak_parse_remote_urls(output string) map[string]string {
	mut urls := map[string]string{}
	for line in output.trim_space().split_into_lines() {
		parts := line.trim_space().split('\t')
		if parts.len >= 2 {
			urls[parts[0]] = parts[1]
		}
	}
	return urls
}

pub fn flatpak_parse_packages(output string, remote_urls map[string]string) []FlatpakPackage {
	mut packages := []FlatpakPackage{}
	for line in output.trim_space().split_into_lines() {
		parts := line.trim_space().split('\t')
		if parts.len == 0 || parts[0] == '' {
			continue
		}
		remote := if parts.len > 1 { parts[1] } else { 'flathub' }
		packages << FlatpakPackage{
			name: parts[0]
			remote: remote
			remote_url: remote_urls[remote] or { '' }
		}
	}
	packages.sort_with_compare(fn (a &FlatpakPackage, b &FlatpakPackage) int {
		return a.name.compare(b.name)
	})
	return packages
}

pub fn flatpak_dump_entry(package FlatpakPackage) string {
	name := extension_quote(package.name)
	if package.remote == 'flathub' {
		return 'flatpak ${name}'
	}
	if package.remote.ends_with('-origin') {
		if package.remote_url != '' {
			return 'flatpak ${name}, remote: ${extension_quote(package.remote_url)}'
		}
		return 'flatpak ${name}, remote: ${extension_quote(package.remote)}'
	}
	if package.remote_url != '' {
		return 'flatpak ${name}, remote: ${extension_quote(package.remote)}, url: ${extension_quote(package.remote_url)}'
	}
	return 'flatpak ${name}, remote: ${extension_quote(package.remote)}'
}

pub fn flatpak_get_remote_url(output string, remote_name string) string {
	for line in output.trim_space().split_into_lines() {
		parts := line.split('\t')
		if parts.len > 1 && parts[0] == remote_name {
			return parts[1]
		}
	}
	return ''
}

pub fn flatpak_add_remote_command(executable string, remote_name string, url string) []string {
	mut command := [executable, 'remote-add', '--if-not-exists', '--system']
	if !url.ends_with('.flatpakrepo') {
		command << '--no-gpg-verify'
	}
	command << remote_name
	command << url
	return command
}

pub fn flatpak_ensure_single_app_remote(executable string, remote_name string, url string,
	existing_url string, verbose bool) ([][]string, []string) {
	mut commands := [][]string{}
	mut output := []string{}
	if existing_url != '' && existing_url != url {
		if verbose {
			output << 'Replacing single-app remote ${remote_name} (URL changed)'
		}
		commands << [executable, 'remote-delete', '--system', '--force', remote_name]
	}
	if existing_url == '' || existing_url != url {
		if verbose {
			output << 'Adding single-app remote ${remote_name} from ${url}'
		}
		commands << flatpak_add_remote_command(executable, remote_name, url)
	}
	return commands, output
}

pub fn flatpak_ensure_named_remote(executable string, remote_name string, url string,
	existing_url string, verbose bool) ([][]string, []string) {
	if existing_url != '' && existing_url != url {
		return [][]string{}, [
			"Warning: Remote '${remote_name}' exists with different URL (${existing_url}), using existing",
		]
	}
	if existing_url != '' {
		return [][]string{}, []string{}
	}
	mut output := []string{}
	if verbose {
		output << 'Adding named remote ${remote_name} from ${url}'
	}
	return [flatpak_add_remote_command(executable, remote_name, url)], output
}

pub fn flatpak_package_installed(installed []FlatpakPackage, name string, remote ?string) bool {
	if requested_remote := remote {
		return installed.any(it.name == name && it.remote == requested_remote)
	}
	return installed.any(it.name == name)
}

pub fn flatpak_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'flatpak' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn flatpak_install(mut state FlatpakState, name string, remote string, url string,
	preinstall bool, verbose bool, existing_url string, install_success bool,
	flatpakref_list_output string) bool {
	if state.executable == '' || !preinstall {
		return true
	}
	mut actual_remote := remote
	if url != '' {
		if verbose {
			state.output << 'Installing ${name} Flatpak from ${remote} (${url}). It is not currently installed.'
		}
		commands, messages := flatpak_ensure_named_remote(state.executable, remote, url, existing_url, verbose)
		state.commands << commands
		state.output << messages
	} else if remote.starts_with('http://') || remote.starts_with('https://') {
		if remote.ends_with('.flatpakref') {
			if verbose {
				state.output << 'Installing ${name} Flatpak from ${remote}. It is not currently installed.'
			}
			state.commands << [state.executable, 'install', '-y', '--system', remote]
			if !install_success {
				return false
			}
			actual_remote = '${name}-origin'
			for line in flatpakref_list_output.trim_space().split_into_lines() {
				if line.starts_with(name) {
					parts := line.split('\t')
					if parts.len > 1 && parts[1] != '' {
						actual_remote = parts[1]
					}
					break
				}
			}
			package := FlatpakPackage{
				name: name
				remote: actual_remote
			}
			state.packages_with_remotes << package
			state.installed_packages = state.packages_with_remotes.clone()
			state.packages = state.packages_with_remotes.map(it.name)
			return true
		}
		actual_remote = '${name}-origin'
		if verbose {
			state.output << 'Installing ${name} Flatpak from ${actual_remote} (${remote}). It is not currently installed.'
		}
		commands, messages := flatpak_ensure_single_app_remote(state.executable, actual_remote, remote, existing_url, verbose)
		state.commands << commands
		state.output << messages
	} else if verbose {
		state.output << 'Installing ${name} Flatpak from ${remote}. It is not currently installed.'
	}
	state.commands << [state.executable, 'install', '-y', '--system', actual_remote, name]
	if !install_success {
		return false
	}
	package := FlatpakPackage{
		name: name
		remote: actual_remote
		remote_url: url
	}
	state.packages_with_remotes << package
	state.installed_packages = state.packages_with_remotes.clone()
	state.packages = state.packages_with_remotes.map(it.name)
	return true
}

// Translated from Homebrew/brew `bundle/extensions/flatpak.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :flatpak` at line 13.
pub fn ruby_flatpak_l13_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'flatpak')
}

// Ruby method `check_label = "Flatpak"` at line 16.
pub fn ruby_flatpak_l16_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Flatpak')
}

// Ruby method `banner_name = "Flatpak packages"` at line 19.
pub fn ruby_flatpak_l19_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Flatpak packages')
}

// Ruby method `switch_description(description)` at line 22.
pub fn ruby_flatpak_l22_d4_switch_description(args ...brew_runtime.Value) brew_runtime.Value {
	description := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_value('${extension_switch_description(description)} Note: Linux only.')
}

// Ruby method `cleanup_heading` at line 27.
pub fn ruby_flatpak_l27_d5_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('flatpaks')
}

// Ruby method `entry(name, options = {})` at line 32.
pub fn ruby_flatpak_l32_d6_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return flatpak_error('ArgumentError', 'name is required')
	}
	options := if args.len > 1 {
		args[1].as_map() or { return flatpak_error('ArgumentError', err.msg()) }
	} else {
		map[string]brew_runtime.Value{}
	}
	entry := flatpak_entry(args[0].as_string(), options) or { return flatpak_error('RuntimeError', err.msg()) }
	return extension_entry_value(entry)
}

// Ruby method `reset!` at line 56.
pub fn ruby_flatpak_l56_d7_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	state.packages = []
	state.packages_with_remotes = []
	state.remote_urls = map[string]string{}
	state.installed_packages = []
	return flatpak_state_value(state)
}

// Ruby method `remote_urls` at line 64.
pub fn ruby_flatpak_l64_d8_remote_urls(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	if state.remote_urls.len > 0 {
		return flatpak_string_map_value(state.remote_urls)
	}
	if state.executable == '' {
		return flatpak_string_map_value({})
	}
	return flatpak_string_map_value(flatpak_parse_remote_urls(if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}))
}

// Ruby method `packages_with_remotes` at line 87.
pub fn ruby_flatpak_l87_d9_packages_with_remotes(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	if state.packages_with_remotes.len > 0 {
		return flatpak_packages_value(state.packages_with_remotes)
	}
	if state.executable == '' {
		return flatpak_packages_value([])
	}
	package_output := if args.len > 1 { args[1].as_string() } else { '' }
	remote_output := if args.len > 2 { args[2].as_string() } else { '' }
	return flatpak_packages_value(flatpak_parse_packages(package_output, flatpak_parse_remote_urls(remote_output)))
}

// Ruby method `packages` at line 116.
pub fn ruby_flatpak_l116_d10_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	if state.packages.len > 0 {
		return brew_runtime.string_array_value(state.packages)
	}
	packages := if args.len > 1 {
		flatpak_packages_from_value(args[1])
	} else {
		state.packages_with_remotes
	}
	return brew_runtime.string_array_value(packages.map(it.name))
}

// Ruby method `installed_packages` at line 124.
pub fn ruby_flatpak_l124_d11_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	if state.installed_packages.len > 0 {
		return flatpak_packages_value(state.installed_packages)
	}
	return flatpak_packages_value(state.packages_with_remotes.clone())
}

// Ruby method `dump_entry(package)` at line 132.
pub fn ruby_flatpak_l132_d12_dump_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return flatpak_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(flatpak_dump_entry(flatpak_package_from_value(args[0])))
}

// Ruby method `dump` at line 159.
pub fn ruby_flatpak_l159_d13_dump(args ...brew_runtime.Value) brew_runtime.Value {
	packages := if args.len > 0 { flatpak_packages_from_value(args[0]) } else { [] }
	return brew_runtime.string_value(packages.map(flatpak_dump_entry(it)).join('\n'))
}

// Ruby method `preinstall!(name, with: nil, no_upgrade: false, verbose: false, remote: "flathub", url: nil, **_options)` at line 174.
pub fn ruby_flatpak_l174_d14_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	if state.executable == '' {
		return brew_runtime.bool_value(false)
	}
	if flatpak_package_installed(state.installed_packages, name, none) {
		if verbose {
			return brew_runtime.map_value({
				'result': brew_runtime.bool_value(false)
				'output': brew_runtime.string_value('Skipping install of ${name} Flatpak. It is already installed.')
			})
		}
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 203.
pub fn ruby_flatpak_l203_d15_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	preinstall := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	verbose := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	remote := if args.len > 7 { args[7].as_string() } else { 'flathub' }
	url := if args.len > 8 && args[8].type_name != 'NilClass' { args[8].as_string() } else { '' }
	existing_url := if args.len > 9 && args[9].type_name != 'NilClass' {
		args[9].as_string()
	} else {
		''
	}
	install_success := if args.len > 10 { args[10].as_bool() or { false } } else { false }
	list_output := if args.len > 11 { args[11].as_string() } else { '' }
	result := flatpak_install(mut state, name, remote, url, preinstall, verbose, existing_url, install_success, list_output)
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'state':  flatpak_state_value(state)
	})
}

// Ruby method `install_flatpakref!(flatpak, name, url, verbose:)` at line 257.
pub fn ruby_flatpak_l257_d16_install_flatpakref(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { flatpak_state_from_value(args[0]) } else { FlatpakState{} }
	flatpak := if args.len > 1 { args[1].as_string() } else { state.executable }
	state.executable = flatpak
	name := if args.len > 2 { args[2].as_string() } else { '' }
	url := if args.len > 3 { args[3].as_string() } else { '' }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	result := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	list_output := if args.len > 6 { args[6].as_string() } else { '' }
	installed := flatpak_install(mut state, name, url, '', true, verbose, '', result, list_output)
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(installed)
		'state':  flatpak_state_value(state)
	})
}

// Ruby method `generate_single_app_remote_name(app_id)` at line 277.
pub fn ruby_flatpak_l277_d17_generate_single_app_remote_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('${if args.len > 0 { args[0].as_string() } else { '' }}-origin')
}

// Ruby method `ensure_single_app_remote_exists!(flatpak, remote_name, url, verbose:)` at line 284.
pub fn ruby_flatpak_l284_d18_ensure_single_app_remote_exists(args ...brew_runtime.Value) brew_runtime.Value {
	executable := if args.len > 0 { args[0].as_string() } else { '' }
	remote := if args.len > 1 { args[1].as_string() } else { '' }
	url := if args.len > 2 { args[2].as_string() } else { '' }
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	existing := if args.len > 4 && args[4].type_name != 'NilClass' {
		args[4].as_string()
	} else {
		''
	}
	commands, output := flatpak_ensure_single_app_remote(executable, remote, url, existing, verbose)
	return brew_runtime.map_value({
		'commands': brew_runtime.array_value(commands.map(brew_runtime.string_array_value(it)))
		'output':   brew_runtime.string_array_value(output)
	})
}

// Ruby method `ensure_named_remote_exists!(flatpak, remote_name, url, verbose:)` at line 303.
pub fn ruby_flatpak_l303_d19_ensure_named_remote_exists(args ...brew_runtime.Value) brew_runtime.Value {
	executable := if args.len > 0 { args[0].as_string() } else { '' }
	remote := if args.len > 1 { args[1].as_string() } else { '' }
	url := if args.len > 2 { args[2].as_string() } else { '' }
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	existing := if args.len > 4 && args[4].type_name != 'NilClass' {
		args[4].as_string()
	} else {
		''
	}
	commands, output := flatpak_ensure_named_remote(executable, remote, url, existing, verbose)
	return brew_runtime.map_value({
		'commands': brew_runtime.array_value(commands.map(brew_runtime.string_array_value(it)))
		'output':   brew_runtime.string_array_value(output)
	})
}

// Ruby method `get_remote_url(flatpak, remote_name)` at line 320.
pub fn ruby_flatpak_l320_d20_get_remote_url(args ...brew_runtime.Value) brew_runtime.Value {
	remote := if args.len > 1 { args[1].as_string() } else { '' }
	output := if args.len > 2 { args[2].as_string() } else { '' }
	url := flatpak_get_remote_url(output, remote)
	if url == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(url)
}

// Ruby method `add_remote!(flatpak, remote_name, url, verbose:)` at line 331.
pub fn ruby_flatpak_l331_d21_add_remote(args ...brew_runtime.Value) brew_runtime.Value {
	executable := if args.len > 0 { args[0].as_string() } else { '' }
	remote := if args.len > 1 { args[1].as_string() } else { '' }
	url := if args.len > 2 { args[2].as_string() } else { '' }
	result := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	return brew_runtime.map_value({
		'result':  brew_runtime.bool_value(result)
		'command': brew_runtime.string_array_value(flatpak_add_remote_command(executable, remote, url))
	})
}

// Ruby method `package_installed?(name, with: nil, remote: nil)` at line 349.
pub fn ruby_flatpak_l349_d22_package_installed(args ...brew_runtime.Value) brew_runtime.Value {
	installed := if args.len > 0 { flatpak_packages_from_value(args[0]) } else { [] }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	remote := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		none
	}
	return brew_runtime.bool_value(flatpak_package_installed(installed, name, remote))
}

// Ruby method `cleanup_items(entries)` at line 360.
pub fn ruby_flatpak_l360_d23_cleanup_items(args ...brew_runtime.Value) brew_runtime.Value {
	entry_values := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	entries := entry_values.map(extension_entry_from_value(it))
	executable := if args.len > 1 { args[1].as_string() } else { '' }
	packages := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	return brew_runtime.string_array_value(flatpak_cleanup_items(entries, executable, packages))
}

// Ruby method `cleanup!(flatpaks)` at line 373.
pub fn ruby_flatpak_l373_d24_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	items := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	commands := items.map(brew_runtime.string_array_value(['flatpak', 'uninstall', '-y', '--system',
		it]))
	suffix := if items.len == 1 { '' } else { 's' }
	return brew_runtime.map_value({
		'commands': brew_runtime.array_value(commands)
		'output':   brew_runtime.string_value('Uninstalled ${items.len} flatpak${suffix}')
	})
}

// Ruby method `format_checkable(entries)` at line 382.
pub fn ruby_flatpak_l382_d25_format_checkable(args ...brew_runtime.Value) brew_runtime.Value {
	entry_values := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	mut packages := []FlatpakPackage{}
	for entry_value in entry_values {
		entry := extension_entry_from_value(entry_value)
		if entry.entry_type == 'flatpak' {
			packages << flatpak_package_from_value(entry_value)
		}
	}
	return flatpak_packages_value(packages)
}

// Ruby method `failure_reason(package, no_upgrade:)` at line 389.
pub fn ruby_flatpak_l389_d26_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return flatpak_error('ArgumentError', 'package is required')
	}
	name := if args[0].type_name == 'Hash' {
		flatpak_package_from_value(args[0]).name
	} else {
		args[0].as_string()
	}
	return brew_runtime.string_value('Flatpak ${name} needs to be installed.')
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 401.
pub fn ruby_flatpak_l401_d27_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	installed := flatpak_packages_from_value(args[0])
	package_value := args[1]
	if package_value.type_name != 'Hash' {
		return brew_runtime.bool_value(flatpak_package_installed(installed, package_value.as_string(), none))
	}
	package := flatpak_package_from_value(package_value)
	values := package_value.as_map() or { map[string]brew_runtime.Value{} }
	options := if 'options' in values {
		values['options'].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	url := if 'url' in options { options['url'].as_string() } else { '' }
	remote := if 'remote' in options { options['remote'].as_string() } else { 'flathub' }
	if url == '' && (remote.starts_with('http://') || remote.starts_with('https://')) {
		if remote.ends_with('.flatpakref') {
			return brew_runtime.bool_value(flatpak_package_installed(installed, package.name, none))
		}
		return brew_runtime.bool_value(flatpak_package_installed(installed, package.name, ?string('${package.name}-origin')))
	}
	return brew_runtime.bool_value(flatpak_package_installed(installed, package.name, ?string(remote)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Flatpak < Extension
// 9:       Package = T.type_alias { { name: String, remote: String, remote_url: T.nilable(String) } }
// 10:
// 11:       class << self
// 12:         sig { override.returns(Symbol) }
// 13:         def type = :flatpak
// 14:
// 15:         sig { override.returns(String) }
// 16:         def check_label = "Flatpak"
// 17:
// 18:         sig { override.returns(String) }
// 19:         def banner_name = "Flatpak packages"
// 20:
// 21:         sig { override.params(description: String).returns(String) }
// 22:         def switch_description(description)
// 23:           "#{super} Note: Linux only."
// 24:         end
// 25:
// 26:         sig { override.returns(T.nilable(String)) }
// 27:         def cleanup_heading
// 28:           "flatpaks"
// 29:         end
// 30:
// 31:         sig { override.params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 32:         def entry(name, options = {})
// 33:           unknown_options = options.keys - [:remote, :url]
// 34:           raise "unknown options(#{unknown_options.inspect}) for flatpak" if unknown_options.present?
// 35:
// 36:           remote = options[:remote]
// 37:           url = options[:url]
// 38:           if !remote.nil? && !remote.is_a?(String)
// 39:             raise "options[:remote](#{remote.inspect}) should be a String object"
// 40:           end
// 41:           raise "options[:url](#{url.inspect}) should be a String object" if !url.nil? && !url.is_a?(String)
// 42:
// 43:           # Validate: url: can only be used with a named remote (not a URL remote)
// 44:           if url && remote&.start_with?("http://", "https://")
// 45:             raise "url: parameter cannot be used when remote: is already a URL"
// 46:           end
// 47:
// 48:           normalized_options = {}
// 49:           normalized_options[:remote] = remote || "flathub"
// 50:           normalized_options[:url] = url if url
// 51:
// 52:           Dsl::Entry.new(type, name, normalized_options)
// 53:         end
// 54:
// 55:         sig { override.void }
// 56:         def reset!
// 57:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 58:           @packages_with_remotes = T.let(nil, T.nilable(T::Array[Package]))
// 59:           @remote_urls = T.let(nil, T.nilable(T::Hash[String, String]))
// 60:           @installed_packages = T.let(nil, T.nilable(T::Array[Package]))
// 61:         end
// 62:
// 63:         sig { returns(T::Hash[String, String]) }
// 64:         def remote_urls
// 65:           remote_urls = @remote_urls
// 66:           return remote_urls if remote_urls
// 67:
// 68:           @remote_urls = if (flatpak = package_manager_executable)
// 69:             output = `#{flatpak} remote-list --system --columns=name,url 2>/dev/null`.chomp
// 70:             urls = {}
// 71:             output.split("\n").each do |line|
// 72:               parts = line.strip.split("\t")
// 73:               next if parts.size < 2
// 74:
// 75:               name = parts[0]
// 76:               url = parts[1]
// 77:               urls[name] = url if name && url
// 78:             end
// 79:             urls
// 80:           end
// 81:           return {} if @remote_urls.nil?
// 82:
// 83:           @remote_urls
// 84:         end
// 85:
// 86:         sig { returns(T::Array[Package]) }
// 87:         def packages_with_remotes
// 88:           packages_with_remotes = @packages_with_remotes
// 89:           return packages_with_remotes if packages_with_remotes
// 90:
// 91:           @packages_with_remotes = if (flatpak = package_manager_executable)
// 92:             # List applications with their origin remote
// 93:             # Using --app to filter applications only
// 94:             # Using --columns=application,origin to get app IDs and their remotes
// 95:             output = `#{flatpak} list --app --columns=application,origin 2>/dev/null`.chomp
// 96:
// 97:             packages = output.split("\n").filter_map do |line|
// 98:               parts = line.strip.split("\t")
// 99:               name = parts[0]
// 100:               next if parts.empty? || name.nil? || name.empty?
// 101:
// 102:               remote = parts[1] || "flathub"
// 103:               package = T.let({ name:, remote:, remote_url: T.let(nil, T.nilable(String)) }, Package)
// 104:               remote_url = remote_urls[remote]
// 105:               package[:remote_url] = remote_url
// 106:               package
// 107:             end
// 108:             packages.sort_by { |pkg| pkg[:name].to_s }
// 109:           end
// 110:           return [] if @packages_with_remotes.nil?
// 111:
// 112:           @packages_with_remotes
// 113:         end
// 114:
// 115:         sig { override.returns(T::Array[String]) }
// 116:         def packages
// 117:           packages = @packages
// 118:           return packages if packages
// 119:
// 120:           @packages = packages_with_remotes.map { |pkg| pkg[:name] }
// 121:         end
// 122:
// 123:         sig { override.returns(T::Array[Package]) }
// 124:         def installed_packages
// 125:           installed_packages = @installed_packages
// 126:           return installed_packages if installed_packages
// 127:
// 128:           @installed_packages = packages_with_remotes.dup
// 129:         end
// 130:
// 131:         sig { override.params(package: Object).returns(String) }
// 132:         def dump_entry(package)
// 133:           package = T.cast(package, Package)
// 134:           remote = package[:remote]
// 135:           remote_url = package[:remote_url]
// 136:           name = package[:name]
// 137:
// 138:           if remote == "flathub"
// 139:             # Tier 1: Don't specify remote for flathub (default)
// 140:             "flatpak #{quote(name)}"
// 141:           elsif remote&.end_with?("-origin")
// 142:             # Tier 2: Single-app remote - dump with URL only
// 143:             if remote_url.present?
// 144:               "flatpak #{quote(name)}, remote: #{quote(remote_url)}"
// 145:             else
// 146:               # Fallback if URL not available (shouldn't happen for -origin remotes)
// 147:               "flatpak #{quote(name)}, remote: #{quote(remote)}"
// 148:             end
// 149:           elsif remote_url.present?
// 150:             # Tier 3: Named shared remote - dump with name and URL
// 151:             "flatpak #{quote(name)}, remote: #{quote(remote)}, url: #{quote(remote_url)}"
// 152:           else
// 153:             # Named remote without URL (user-defined or system remote)
// 154:             "flatpak #{quote(name)}, remote: #{quote(remote)}"
// 155:           end
// 156:         end
// 157:
// 158:         sig { override.returns(String) }
// 159:         def dump
// 160:           packages_with_remotes.map { |package| dump_entry(package) }.join("\n")
// 161:         end
// 162:
// 163:         sig {
// 164:           override.params(
// 165:             name:       String,
// 166:             with:       T.nilable(T::Array[String]),
// 167:             no_upgrade: T::Boolean,
// 168:             verbose:    T::Boolean,
// 169:             remote:     String,
// 170:             url:        T.nilable(String),
// 171:             _options:   Homebrew::Bundle::EntryOption,
// 172:           ).returns(T::Boolean)
// 173:         }
// 174:         def preinstall!(name, with: nil, no_upgrade: false, verbose: false, remote: "flathub", url: nil, **_options)
// 175:           _ = with
// 176:           _ = no_upgrade
// 177:           _ = url
// 178:
// 179:           return false unless package_manager_installed?
// 180:
// 181:           # Check if package is installed at all (regardless of remote)
// 182:           if package_installed?(name)
// 183:             puts "Skipping install of #{name} Flatpak. It is already installed." if verbose
// 184:             return false
// 185:           end
// 186:
// 187:           true
// 188:         end
// 189:
// 190:         sig {
// 191:           override.params(
// 192:             name:       String,
// 193:             with:       T.nilable(T::Array[String]),
// 194:             preinstall: T::Boolean,
// 195:             no_upgrade: T::Boolean,
// 196:             verbose:    T::Boolean,
// 197:             force:      T::Boolean,
// 198:             remote:     String,
// 199:             url:        T.nilable(String),
// 200:             _options:   Homebrew::Bundle::EntryOption,
// 201:           ).returns(T::Boolean)
// 202:         }
// 203:         def install!(name, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 204:                      remote: "flathub", url: nil, **_options)
// 205:           _ = with
// 206:           _ = no_upgrade
// 207:           _ = force
// 208:
// 209:           return true unless package_manager_installed?
// 210:           return true unless preinstall
// 211:
// 212:           flatpak = package_manager_executable!.to_s
// 213:
// 214:           # 3-tier remote handling:
// 215:           # - Tier 1: no URL → use named remote (default: flathub)
// 216:           # - Tier 2: URL only → single-app remote (<app-id>-origin)
// 217:           # - Tier 3: URL + name → named shared remote
// 218:
// 219:           if url.present?
// 220:             # Tier 3: Named remote with URL - create shared remote
// 221:             puts "Installing #{name} Flatpak from #{remote} (#{url}). It is not currently installed." if verbose
// 222:             ensure_named_remote_exists!(flatpak, remote, url, verbose:)
// 223:             actual_remote = remote
// 224:           elsif remote.start_with?("http://", "https://")
// 225:             if remote.end_with?(".flatpakref")
// 226:               # .flatpakref files - install directly (Flatpak handles single-app remote natively)
// 227:               puts "Installing #{name} Flatpak from #{remote}. It is not currently installed." if verbose
// 228:               return install_flatpakref!(flatpak, name, remote, verbose:)
// 229:             else
// 230:               # Tier 2: URL only - create single-app remote
// 231:               actual_remote = generate_single_app_remote_name(name)
// 232:               if verbose
// 233:                 puts "Installing #{name} Flatpak from #{actual_remote} (#{remote}). It is not currently installed."
// 234:               end
// 235:               ensure_single_app_remote_exists!(flatpak, actual_remote, remote, verbose:)
// 236:             end
// 237:           else
// 238:             # Tier 1: Named remote (default: flathub)
// 239:             puts "Installing #{name} Flatpak from #{remote}. It is not currently installed." if verbose
// 240:             actual_remote = remote
// 241:           end
// 242:
// 243:           # Install from the remote
// 244:           return false unless Bundle.system(flatpak, "install", "-y", "--system", actual_remote, name, verbose:)
// 245:
// 246:           package = { name:, remote: actual_remote, remote_url: url }
// 247:           packages_with_remotes = T.let(@packages_with_remotes || [], T::Array[Package])
// 248:           packages_with_remotes << package
// 249:           @packages_with_remotes = packages_with_remotes
// 250:           @installed_packages = packages_with_remotes.dup
// 251:           @packages = packages_with_remotes.map { |pkg| pkg[:name] }
// 252:           true
// 253:         end
// 254:
// 255:         # Install from a .flatpakref file (Tier 2 variant - Flatpak handles single-app remote natively)
// 256:         sig { params(flatpak: String, name: String, url: String, verbose: T::Boolean).returns(T::Boolean) }
// 257:         def install_flatpakref!(flatpak, name, url, verbose:)
// 258:           return false unless Bundle.system(flatpak, "install", "-y", "--system", url, verbose:)
// 259:
// 260:           # Get the actual remote name used by Flatpak
// 261:           output = `#{flatpak} list --app --columns=application,origin 2>/dev/null`.chomp
// 262:           installed = output.split("\n").find { |line| line.start_with?(name) }
// 263:           actual_remote = installed ? installed.split("\t")[1] : "#{name}-origin"
// 264:           actual_remote ||= "#{name}-origin"
// 265:           package = { name:, remote: actual_remote, remote_url: nil }
// 266:           packages_with_remotes = T.let(@packages_with_remotes || [], T::Array[Package])
// 267:           packages_with_remotes << package
// 268:           @packages_with_remotes = packages_with_remotes
// 269:           @installed_packages = packages_with_remotes.dup
// 270:           @packages = packages_with_remotes.map { |pkg| pkg[:name] }
// 271:           true
// 272:         end
// 273:
// 274:         # Generate a single-app remote name (Tier 2)
// 275:         # Pattern: <app-id>-origin (matches Flatpak's native behavior for .flatpakref)
// 276:         sig { params(app_id: String).returns(String) }
// 277:         def generate_single_app_remote_name(app_id)
// 278:           "#{app_id}-origin"
// 279:         end
// 280:
// 281:         # Ensure a single-app remote exists (Tier 2)
// 282:         # Safe to replace if URL differs since it's isolated per-app
// 283:         sig { params(flatpak: String, remote_name: String, url: String, verbose: T::Boolean).void }
// 284:         def ensure_single_app_remote_exists!(flatpak, remote_name, url, verbose:)
// 285:           existing_url = get_remote_url(flatpak, remote_name)
// 286:
// 287:           if existing_url && existing_url != url
// 288:             # Single-app remote with different URL - safe to replace
// 289:             puts "Replacing single-app remote #{remote_name} (URL changed)" if verbose
// 290:             Bundle.system(flatpak, "remote-delete", "--system", "--force", remote_name, verbose:)
// 291:             existing_url = nil
// 292:           end
// 293:
// 294:           return if existing_url
// 295:
// 296:           puts "Adding single-app remote #{remote_name} from #{url}" if verbose
// 297:           add_remote!(flatpak, remote_name, url, verbose:)
// 298:         end
// 299:
// 300:         # Ensure a named shared remote exists (Tier 3)
// 301:         # Warn but don't change if URL differs (user explicitly named it)
// 302:         sig { params(flatpak: String, remote_name: String, url: String, verbose: T::Boolean).void }
// 303:         def ensure_named_remote_exists!(flatpak, remote_name, url, verbose:)
// 304:           existing_url = get_remote_url(flatpak, remote_name)
// 305:
// 306:           if existing_url && existing_url != url
// 307:             # Named remote with different URL - warn but don't change (user explicitly named it)
// 308:             puts "Warning: Remote '#{remote_name}' exists with different URL (#{existing_url}), using existing"
// 309:             return
// 310:           end
// 311:
// 312:           return if existing_url
// 313:
// 314:           puts "Adding named remote #{remote_name} from #{url}" if verbose
// 315:           add_remote!(flatpak, remote_name, url, verbose:)
// 316:         end
// 317:
// 318:         # Get URL for an existing remote, or nil if not found
// 319:         sig { params(flatpak: String, remote_name: String).returns(T.nilable(String)) }
// 320:         def get_remote_url(flatpak, remote_name)
// 321:           output = `#{flatpak} remote-list --system --columns=name,url 2>/dev/null`.chomp
// 322:           output.split("\n").each do |line|
// 323:             parts = line.split("\t")
// 324:             return parts[1] if parts[0] == remote_name
// 325:           end
// 326:           nil
// 327:         end
// 328:
// 329:         # Add a remote with appropriate flags
// 330:         sig { params(flatpak: String, remote_name: String, url: String, verbose: T::Boolean).returns(T::Boolean) }
// 331:         def add_remote!(flatpak, remote_name, url, verbose:)
// 332:           if url.end_with?(".flatpakrepo")
// 333:             Bundle.system(flatpak, "remote-add", "--if-not-exists", "--system", remote_name, url, verbose:)
// 334:           else
// 335:             # For bare repository URLs, add with --no-gpg-verify for user repos
// 336:             Bundle.system(
// 337:               flatpak, "remote-add", "--if-not-exists", "--system", "--no-gpg-verify", remote_name, url, verbose:
// 338:             )
// 339:           end
// 340:         end
// 341:
// 342:         sig {
// 343:           override.params(
// 344:             name:   String,
// 345:             with:   T.nilable(T::Array[String]),
// 346:             remote: T.nilable(String),
// 347:           ).returns(T::Boolean)
// 348:         }
// 349:         def package_installed?(name, with: nil, remote: nil)
// 350:           _ = with
// 351:
// 352:           if remote
// 353:             installed_packages.any? { |pkg| pkg[:name] == name && pkg[:remote] == remote }
// 354:           else
// 355:             installed_packages.any? { |pkg| pkg[:name] == name }
// 356:           end
// 357:         end
// 358:
// 359:         sig { params(entries: T::Array[Dsl::Entry]).returns(T::Array[String]) }
// 360:         def cleanup_items(entries)
// 361:           return [].freeze unless package_manager_installed?
// 362:
// 363:           kept_flatpaks = entries.filter_map do |entry|
// 364:             entry.name if entry.type == type
// 365:           end
// 366:
// 367:           return [].freeze if kept_flatpaks.empty?
// 368:
// 369:           packages - kept_flatpaks
// 370:         end
// 371:
// 372:         sig { params(flatpaks: T::Array[String]).void }
// 373:         def cleanup!(flatpaks)
// 374:           flatpaks.each do |flatpak_name|
// 375:             Kernel.system("flatpak", "uninstall", "-y", "--system", flatpak_name)
// 376:           end
// 377:           puts "Uninstalled #{flatpaks.size} flatpak#{"s" if flatpaks.size != 1}"
// 378:         end
// 379:       end
// 380:
// 381:       sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 382:       def format_checkable(entries)
// 383:         checkable_entries(entries).map do |entry|
// 384:           { name: entry.name, options: entry.options }
// 385:         end
// 386:       end
// 387:
// 388:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(String) }
// 389:       def failure_reason(package, no_upgrade:)
// 390:         _ = no_upgrade
// 391:
// 392:         name = if package.is_a?(Hash)
// 393:           package[:name]
// 394:         else
// 395:           package
// 396:         end
// 397:         "#{self.class.check_label} #{name} needs to be installed."
// 398:       end
// 399:
// 400:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 401:       def installed_and_up_to_date?(package, no_upgrade: false)
// 402:         _ = no_upgrade
// 403:
// 404:         return self.class.package_installed?(T.cast(package, String)) unless package.is_a?(Hash)
// 405:
// 406:         flatpak = package
// 407:         name = T.cast(flatpak[:name], String)
// 408:         options = T.cast(flatpak[:options], T::Hash[Symbol, String])
// 409:         remote = options.fetch(:remote, "flathub")
// 410:         url = options[:url]
// 411:
// 412:         # 3-tier remote handling:
// 413:         # - Tier 1: Named remote → check with that remote name
// 414:         # - Tier 2: URL only → resolve to single-app remote name (<app-id>-origin)
// 415:         # - Tier 3: URL + name → check with the named remote
// 416:         actual_remote = if url.blank? && remote.start_with?("http://", "https://")
// 417:           # Tier 2: URL only - resolve to single-app remote name
// 418:           # (.flatpakref - check by name only since remote name varies)
// 419:           return self.class.package_installed?(name) if remote.end_with?(".flatpakref")
// 420:
// 421:           self.class.generate_single_app_remote_name(name)
// 422:         else
// 423:           # Tier 1 (named remote) and Tier 3 (named remote with URL) both use the remote name
// 424:           remote
// 425:         end
// 426:
// 427:         self.class.package_installed?(name, remote: actual_remote)
// 428:       end
// 429:     end
// 430:   end
// 431: end
