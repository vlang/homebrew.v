module extensions

import json2

// Translated from Homebrew/brew `bundle/extensions/mac_app_store.rb`.
pub struct MacAppStoreApp {
pub:
	id   string
	name string
}

pub struct MacAppStoreState {
pub:
	brew_file string = 'brew'
pub mut:
	executable               string
	list_output              string
	outdated_output          string
	apps                     []MacAppStoreApp
	apps_loaded              bool
	packages                 []MacAppStoreApp
	packages_loaded          bool
	installed_app_ids        []string
	installed_ids_loaded     bool
	outdated_app_ids         []string
	outdated_ids_loaded      bool
	manager_install_succeeds bool
	upgrade_succeeds         bool
	install_succeeds         bool
	get_succeeds             bool
	executable_after_install string
	commands                 [][]string
	output                   []string
}

pub struct MacAppStoreCheckable {
pub:
	id   i64
	name string
}

pub fn mac_app_store_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::MacAppStore'
		type_name: 'mas'
		banner_name: 'Mac App Store dependencies'
		check_label: 'App'
		cleanup_heading: 'Mac App Store apps'
	}
}

pub fn mac_app_store_reset(mut state MacAppStoreState) {
	state.apps = []
	state.apps_loaded = false
	state.packages = []
	state.packages_loaded = false
	state.installed_app_ids = []
	state.installed_ids_loaded = false
	state.outdated_app_ids = []
	state.outdated_ids_loaded = false
}

fn mac_app_store_printable_name(value string) string {
	mut output := ''
	for character in value.runes() {
		code := u32(character)
		if code < 32 || (code >= 127 && code <= 159) || (code >= 0x200b && code <= 0x200f) || (code >= 0x202a && code <= 0x202e) || (code >= 0x2060 && code <= 0x206f) || code == 0xfeff {
			continue
		}
		output += character.str()
	}
	return output
}

pub fn mac_app_store_parse_apps(output string) []MacAppStoreApp {
	mut apps := []MacAppStoreApp{}
	for raw_line in output.split_into_lines() {
		line := raw_line.trim_space()
		if line == '' {
			continue
		}
		mut id_end := 0
		for id_end < line.len && line[id_end] >= `0` && line[id_end] <= `9` {
			id_end++
		}
		if id_end == 0 || id_end >= line.len {
			continue
		}
		id := line[..id_end]
		rest := line[id_end..].trim_space()
		version_start := rest.last_index(' (') or { continue }
		if !rest.ends_with(')') {
			continue
		}
		version := rest[version_start + 2..rest.len - 1]
		if version == '' || version.bytes().any((it < `0` || it > `9`) && it != `.`) {
			continue
		}
		name := mac_app_store_printable_name(rest[..version_start].trim_space())
		if name != '' { apps << MacAppStoreApp{ id: id, name: name } }
	}
	return apps
}

pub fn mac_app_store_apps(mut state MacAppStoreState) []MacAppStoreApp {
	if state.apps_loaded {
		return state.apps.clone()
	}
	state.apps = if state.executable == '' {
		[]
	} else {
		mac_app_store_parse_apps(state.list_output)
	}
	state.apps_loaded = true
	return state.apps.clone()
}

pub fn mac_app_store_app_ids(mut state MacAppStoreState) []string {
	return mac_app_store_apps(mut state).map(it.id)
}

pub fn mac_app_store_packages(mut state MacAppStoreState) []MacAppStoreApp {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = mac_app_store_apps(mut state)
	state.packages.sort(a.name.to_lower() < b.name.to_lower())
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn mac_app_store_installed_app_ids(mut state MacAppStoreState) []string {
	if state.installed_ids_loaded {
		return state.installed_app_ids.clone()
	}
	state.installed_app_ids = mac_app_store_app_ids(mut state)
	state.installed_ids_loaded = true
	return state.installed_app_ids.clone()
}

pub fn mac_app_store_dump_entry(app MacAppStoreApp) string {
	return 'mas ${extension_quote(app.name)}, id: ${app.id}'
}

pub fn mac_app_store_dump(mut state MacAppStoreState) string {
	return mac_app_store_packages(mut state).map(mac_app_store_dump_entry(it)).join('\n')
}

pub fn mac_app_store_cleanup_item(app MacAppStoreApp) string {
	return json2.encode({
		'id':   app.id
		'name': app.name
	})
}

pub fn mac_app_store_parse_cleanup_item(item string) !MacAppStoreApp {
	decoded := json2.decode[json2.Any](item) or { return error('Invalid Mac App Store cleanup item: ${item}') }
	if decoded !is map[string]json2.Any {
		return error('Invalid Mac App Store cleanup item: ${item}')
	}
	values := decoded as map[string]json2.Any
	id_value := values['id'] or { return error('Invalid Mac App Store cleanup item: ${item}') }
	name_value := values['name'] or { return error('Invalid Mac App Store cleanup item: ${item}') }
	if id_value !is string || name_value !is string {
		return error('Invalid Mac App Store cleanup item: ${item}')
	}
	return MacAppStoreApp{ id: id_value as string, name: name_value as string }
}

pub fn mac_app_store_cleanup_item_name(item string) !string {
	app := mac_app_store_parse_cleanup_item(item)!
	return '${app.name} (${app.id})'
}

pub fn mac_app_store_cleanup_items(mut state MacAppStoreState,
	entries []ExtensionEntry) []string {
	if state.executable == '' {
		return []
	}
	mut kept_ids := []string{}
	for entry in entries {
		if entry.entry_type == 'mas' {
			id := entry.options['id'] or { continue }
			kept_ids << id.int_data.str()
		}
	}
	if kept_ids.len == 0 {
		return []
	}
	mut items := []string{}
	for app in mac_app_store_packages(mut state) {
		if app.id.int() != 0 && !kept_ids.any(it.int() == app.id.int()) {
			items << mac_app_store_cleanup_item(app)
		}
	}
	return items
}

pub fn mac_app_store_cleanup(mut state MacAppStoreState, items []string) ! {
	if state.executable == '' {
		return
	}
	for item in items {
		app := mac_app_store_parse_cleanup_item(item)!
		state.commands << [state.executable, 'uninstall', app.id]
	}
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} Mac App Store app${suffix}'
}

pub fn mac_app_store_app_id_installed(mut state MacAppStoreState, id i64) bool {
	return mac_app_store_installed_app_ids(mut state).any(it.int() == id)
}

pub fn mac_app_store_outdated_app_ids(mut state MacAppStoreState) []string {
	if state.outdated_ids_loaded {
		return state.outdated_app_ids.clone()
	}
	state.outdated_app_ids = if state.executable == '' {
		[]
	} else {
		state.outdated_output.split_into_lines().map(it.split(' ')[0])
	}
	state.outdated_ids_loaded = true
	return state.outdated_app_ids.clone()
}

pub fn mac_app_store_app_id_upgradable(mut state MacAppStoreState, id i64) bool {
	return mac_app_store_outdated_app_ids(mut state).any(it.int() == id)
}

pub fn mac_app_store_app_id_installed_and_up_to_date(mut state MacAppStoreState, id i64,
	no_upgrade bool) bool {
	if !mac_app_store_app_id_installed(mut state, id) {
		return false
	}
	return no_upgrade || !mac_app_store_app_id_upgradable(mut state, id)
}

pub fn mac_app_store_preinstall(mut state MacAppStoreState, name string, id ?i64,
	no_upgrade bool, verbose bool) !bool {
	app_id := id or { return error('missing keyword: id') }
	if state.executable == '' {
		if verbose { state.output << 'Installing mas. It is not currently installed.' }
		state.commands << [state.brew_file, 'install', 'mas']
		if state.manager_install_succeeds {
			state.executable = state.executable_after_install
		}
		if state.executable == '' {
			return error('Unable to install ${name} app. mas installation failed.')
		}
	}
	if mac_app_store_app_id_installed(mut state, app_id) && (no_upgrade || !mac_app_store_app_id_upgradable(mut state, app_id)) {
		if verbose { state.output << 'Skipping install of ${name} app. It is already installed.' }
		return false
	}
	return true
}

pub fn mac_app_store_install(mut state MacAppStoreState, name string, id ?i64,
	preinstall bool, verbose bool) !bool {
	app_id := id or { return error('missing keyword: id') }
	if !preinstall {
		return true
	}
	if state.executable == '' {
		return error('mas is not installed')
	}
	if mac_app_store_app_id_installed(mut state, app_id) {
		if verbose { state.output << 'Upgrading ${name} app. It is installed but not up-to-date.' }
		state.commands << [state.executable, 'upgrade', app_id.str()]
		return state.upgrade_succeeds
	}
	if verbose { state.output << 'Installing ${name} app. It is not currently installed.' }
	state.commands << [state.executable, 'install', app_id.str()]
	mut installed := state.install_succeeds
	if !installed {
		state.commands << [state.executable, 'get', app_id.str()]
		installed = state.get_succeeds
	}
	if !installed {
		return false
	}
	if !state.apps.any(it.id.int() == app_id) {
		state.apps << MacAppStoreApp{ id: app_id.str(), name: name }
	}
	if !state.packages.any(it.id.int() == app_id) {
		state.packages << MacAppStoreApp{ id: app_id.str(), name: name }
	}
	if !state.installed_app_ids.any(it.int() == app_id) { state.installed_app_ids << app_id.str() }
	return true
}

pub fn mac_app_store_format_checkable(entries []ExtensionEntry) []MacAppStoreCheckable {
	mut packages := []MacAppStoreCheckable{}
	for entry in entries {
		if entry.entry_type != 'mas' {
			continue
		}
		id := entry.options['id'] or { continue }
		packages << MacAppStoreCheckable{ id: id.int_data, name: entry.name }
	}
	return packages
}

pub fn mac_app_store_failure_reason(name string, no_upgrade bool) string {
	reason := if no_upgrade {
		'needs to be installed.'
	} else {
		'needs to be installed or updated.'
	}
	return 'App ${name} ${reason}'
}

pub fn mac_app_store_exit_early_check(mut state MacAppStoreState,
	packages []MacAppStoreCheckable, no_upgrade bool) []string {
	for package in packages {
		if !mac_app_store_app_id_installed_and_up_to_date(mut state, package.id, no_upgrade) {
			return [mac_app_store_failure_reason(package.name, no_upgrade)]
		}
	}
	return []
}

pub fn mac_app_store_full_check(mut state MacAppStoreState,
	packages []MacAppStoreCheckable, no_upgrade bool) []string {
	mut failures := []string{}
	for package in packages {
		if !mac_app_store_app_id_installed_and_up_to_date(mut state, package.id, no_upgrade) {
			failures << mac_app_store_failure_reason(package.name, no_upgrade)
		}
	}
	return failures
}
