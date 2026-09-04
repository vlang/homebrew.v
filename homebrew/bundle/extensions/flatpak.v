module extensions

import ruby

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

fn flatpak_error(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
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

pub fn flatpak_package_value(package FlatpakPackage) ruby.Value {
	return ruby.map_value({
		'name':       ruby.string_value(package.name)
		'remote':     ruby.string_value(package.remote)
		'remote_url': if package.remote_url == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.string_value(package.remote_url)
		}
	})
}

pub fn flatpak_package_from_value(value ruby.Value) FlatpakPackage {
	values := value.as_map() or {
		return FlatpakPackage{
			name: value.as_string()
			remote: 'flathub'
		}
	}
	if 'options' in values {
		options := values['options'].as_map() or { map[string]ruby.Value{} }
		return FlatpakPackage{
			name: if 'name' in values { values['name'].as_string() } else { '' }
			remote: if 'remote' in options { options['remote'].as_string() } else { 'flathub' }
			remote_url: if 'url' in options && options['url'].type_name != 'NilClass' {
				options['url'].as_string()
			} else {
				''
			}
		}
	}
	return FlatpakPackage{
		name: if 'name' in values { values['name'].as_string() } else { '' }
		remote: if 'remote' in values { values['remote'].as_string() } else { 'flathub' }
		remote_url: if 'remote_url' in values && values['remote_url'].type_name != 'NilClass' {
			values['remote_url'].as_string()
		} else {
			''
		}
	}
}

pub fn flatpak_packages_value(packages []FlatpakPackage) ruby.Value {
	return ruby.array_value(packages.map(flatpak_package_value(it)))
}

pub fn flatpak_packages_from_value(value ruby.Value) []FlatpakPackage {
	items := value.as_array() or { return [] }
	return items.map(flatpak_package_from_value(it))
}

fn flatpak_string_map_value(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

fn flatpak_string_map_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return {} }
	mut mapped := map[string]string{}
	for key, item in values {
		mapped[key] = item.as_string()
	}
	return mapped
}

pub fn flatpak_state_value(state FlatpakState) ruby.Value {
	return ruby.map_value({
		'_definition':           extension_definition_value(flatpak_definition())
		'executable':            if state.executable == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.object_value('Pathname', state.executable)
		}
		'packages':              ruby.string_array_value(state.packages)
		'packages_with_remotes': flatpak_packages_value(state.packages_with_remotes)
		'installed_packages':    flatpak_packages_value(state.installed_packages)
		'remote_urls':           flatpak_string_map_value(state.remote_urls)
		'output':                ruby.string_array_value(state.output)
		'commands':              ruby.array_value(state.commands.map(ruby.string_array_value(it)))
	})
}

pub fn flatpak_state_from_value(value ruby.Value) FlatpakState {
	values := value.as_map() or { return FlatpakState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return FlatpakState{
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()
		} else {
			''
		}
		packages: if 'packages' in values {
			values['packages'].as_string_array() or { [] }
		} else {
			[]
		}
		packages_with_remotes: if 'packages_with_remotes' in values {
			flatpak_packages_from_value(values['packages_with_remotes'])
		} else {
			[]
		}
		installed_packages: if 'installed_packages' in values {
			flatpak_packages_from_value(values['installed_packages'])
		} else {
			[]
		}
		remote_urls: if 'remote_urls' in values {
			flatpak_string_map_from_value(values['remote_urls'])
		} else {
			map[string]string{}
		}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn flatpak_entry(name string, options map[string]ruby.Value) !ExtensionEntry {
	mut unknown := []string{}
	for key in options.keys() {
		if key !in ['remote', 'url'] {
			unknown << ':${key}'
		}
	}
	if unknown.len > 0 {
		return error('unknown options([${unknown.join(', ')}]) for flatpak')
	}
	remote_value := options['remote'] or { ruby.object_value('NilClass', '') }
	url_value := options['url'] or { ruby.object_value('NilClass', '') }
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
		'remote': ruby.string_value(remote)
	}
	if url_value.type_name == 'String' {
		normalized['url'] = ruby.string_value(url_value.as_string())
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
