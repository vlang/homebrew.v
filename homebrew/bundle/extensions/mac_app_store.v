module extensions

import brew_runtime
import json2

// Translated from Homebrew/brew `bundle/extensions/mac_app_store.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn mac_app_store_entry(name string, options map[string]brew_runtime.Value) !ExtensionEntry {
	id := options['id'] or { return error('options[:id](nil) should be an Integer object') }
	if id.type_name != 'Integer' {
		return error('options[:id](${id.repr}) should be an Integer object')
	}
	return ExtensionEntry{
		entry_type: 'mas'
		name: name
		options: {
			'id': id
		}
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

fn mac_app_store_app_value(app MacAppStoreApp) brew_runtime.Value {
	return brew_runtime.map_value({
		'id':   brew_runtime.string_value(app.id)
		'name': brew_runtime.string_value(app.name)
	})
}

fn mac_app_store_app_from_value(value brew_runtime.Value) MacAppStoreApp {
	values := value.map_data.clone()
	return MacAppStoreApp{ id: (values['id'] or { brew_runtime.string_value('') }).as_string(), name: (values['name'] or { brew_runtime.string_value('') }).as_string() }
}

pub fn mac_app_store_state_value(state MacAppStoreState) brew_runtime.Value {
	return brew_runtime.map_value({
		'brew_file':                brew_runtime.string_value(state.brew_file)
		'executable':               brew_runtime.string_value(state.executable)
		'list_output':              brew_runtime.string_value(state.list_output)
		'outdated_output':          brew_runtime.string_value(state.outdated_output)
		'apps':                     brew_runtime.array_value(state.apps.map(mac_app_store_app_value(it)))
		'apps_loaded':              brew_runtime.bool_value(state.apps_loaded)
		'packages':                 brew_runtime.array_value(state.packages.map(mac_app_store_app_value(it)))
		'packages_loaded':          brew_runtime.bool_value(state.packages_loaded)
		'installed_app_ids':        brew_runtime.string_array_value(state.installed_app_ids)
		'installed_ids_loaded':     brew_runtime.bool_value(state.installed_ids_loaded)
		'outdated_app_ids':         brew_runtime.string_array_value(state.outdated_app_ids)
		'outdated_ids_loaded':      brew_runtime.bool_value(state.outdated_ids_loaded)
		'manager_install_succeeds': brew_runtime.bool_value(state.manager_install_succeeds)
		'upgrade_succeeds':         brew_runtime.bool_value(state.upgrade_succeeds)
		'install_succeeds':         brew_runtime.bool_value(state.install_succeeds)
		'get_succeeds':             brew_runtime.bool_value(state.get_succeeds)
		'executable_after_install': brew_runtime.string_value(state.executable_after_install)
		'commands':                 brew_runtime.array_value(state.commands.map(brew_runtime.string_array_value(it)))
		'output':                   brew_runtime.string_array_value(state.output)
	})
}

pub fn mac_app_store_state_from_value(value brew_runtime.Value) MacAppStoreState {
	values := value.map_data.clone()
	mut commands := [][]string{}
	for command in (values['commands'] or { brew_runtime.array_value([]) }).as_array() or { []brew_runtime.Value{} } {
		commands << (command.as_string_array() or { []string{} })
	}
	return MacAppStoreState{
		brew_file: (values['brew_file'] or { brew_runtime.string_value('brew') }).as_string()
		executable: (values['executable'] or { brew_runtime.string_value('') }).as_string()
		list_output: (values['list_output'] or { brew_runtime.string_value('') }).as_string()
		outdated_output: (values['outdated_output'] or { brew_runtime.string_value('') }).as_string()
		apps: ((values['apps'] or { brew_runtime.array_value([]) }).as_array() or { []brew_runtime.Value{} }).map(mac_app_store_app_from_value(it))
		apps_loaded: (values['apps_loaded'] or { brew_runtime.bool_value(false) }).bool_data
		packages: ((values['packages'] or { brew_runtime.array_value([]) }).as_array() or { []brew_runtime.Value{} }).map(mac_app_store_app_from_value(it))
		packages_loaded: (values['packages_loaded'] or { brew_runtime.bool_value(false) }).bool_data
		installed_app_ids: (values['installed_app_ids'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		installed_ids_loaded: (values['installed_ids_loaded'] or { brew_runtime.bool_value(false) }).bool_data
		outdated_app_ids: (values['outdated_app_ids'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		outdated_ids_loaded: (values['outdated_ids_loaded'] or { brew_runtime.bool_value(false) }).bool_data
		manager_install_succeeds: (values['manager_install_succeeds'] or { brew_runtime.bool_value(false) }).bool_data
		upgrade_succeeds: (values['upgrade_succeeds'] or { brew_runtime.bool_value(false) }).bool_data
		install_succeeds: (values['install_succeeds'] or { brew_runtime.bool_value(false) }).bool_data
		get_succeeds: (values['get_succeeds'] or { brew_runtime.bool_value(false) }).bool_data
		executable_after_install: (values['executable_after_install'] or { brew_runtime.string_value('') }).as_string()
		commands: commands
		output: (values['output'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
	}
}

fn mac_app_store_apps_value(apps []MacAppStoreApp) brew_runtime.Value {
	return brew_runtime.array_value(apps.map(mac_app_store_app_value(it)))
}

fn mac_app_store_checkables_from_value(value brew_runtime.Value) []MacAppStoreCheckable {
	mut packages := []MacAppStoreCheckable{}
	for item in value.as_array() or { []brew_runtime.Value{} } {
		parts := item.as_array() or { continue }
		if parts.len >= 2 {
			packages << MacAppStoreCheckable{ id: parts[0].int_data, name: parts[1].as_string() }
		}
	}
	return packages
}

fn mac_app_store_checkables_value(packages []MacAppStoreCheckable) brew_runtime.Value {
	return brew_runtime.array_value(packages.map(brew_runtime.array_value([
		brew_runtime.int_value(it.id),
		brew_runtime.string_value(it.name),
	])))
}

// Ruby method `type = :mas` at line 18.
pub fn ruby_mac_app_store_l18_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('mas')
}

// Ruby method `check_label = "App"` at line 21.
pub fn ruby_mac_app_store_l21_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('App')
}

// Ruby method `banner_name = "Mac App Store dependencies"` at line 24.
pub fn ruby_mac_app_store_l24_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Mac App Store dependencies')
}

// Ruby method `legacy_check_step` at line 27.
pub fn ruby_mac_app_store_l27_d4_legacy_check_step(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('apps_to_install')
}

// Ruby method `add_supported?` at line 32.
pub fn ruby_mac_app_store_l32_d5_add_supported(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `cleanup_heading` at line 37.
pub fn ruby_mac_app_store_l37_d6_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('Mac App Store apps')
}

// Ruby method `entry(name, options = {})` at line 42.
pub fn ruby_mac_app_store_l42_d7_entry(args ...brew_runtime.Value) brew_runtime.Value {
	entry := mac_app_store_entry((args[0] or { brew_runtime.string_value('') }).as_string(), (args[1] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).map_data.clone()) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.map_value({
		'type':    brew_runtime.string_value(entry.entry_type)
		'name':    brew_runtime.string_value(entry.name)
		'options': brew_runtime.map_value(entry.options)
	})
}

// Ruby method `reset!` at line 50.
pub fn ruby_mac_app_store_l50_d8_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	mac_app_store_reset(mut state)
	return mac_app_store_state_value(state)
}

// Ruby method `apps` at line 58.
pub fn ruby_mac_app_store_l58_d9_apps(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return mac_app_store_apps_value(mac_app_store_apps(mut state))
}

// Ruby method `app_ids` at line 82.
pub fn ruby_mac_app_store_l82_d10_app_ids(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.string_array_value(mac_app_store_app_ids(mut state))
}

// Ruby method `packages` at line 87.
pub fn ruby_mac_app_store_l87_d11_packages(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return mac_app_store_apps_value(mac_app_store_packages(mut state))
}

// Ruby method `installed_packages` at line 95.
pub fn ruby_mac_app_store_l95_d12_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_mac_app_store_l87_d11_packages(...args)
}

// Ruby method `installed_app_ids` at line 100.
pub fn ruby_mac_app_store_l100_d13_installed_app_ids(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.string_array_value(mac_app_store_installed_app_ids(mut state))
}

// Ruby method `dump_entry(package)` at line 108.
pub fn ruby_mac_app_store_l108_d14_dump_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_dump_entry(mac_app_store_app_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })))
}

// Ruby method `cleanup_item(app)` at line 114.
pub fn ruby_mac_app_store_l114_d15_cleanup_item(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_cleanup_item(mac_app_store_app_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })))
}

// Ruby method `cleanup_item_name(item)` at line 119.
pub fn ruby_mac_app_store_l119_d16_cleanup_item_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_cleanup_item_name((args[0] or { brew_runtime.string_value('') }).as_string()) or { return brew_runtime.object_value('TypeError', err.msg()) })
}

// Ruby method `cleanup_items(entries)` at line 125.
pub fn ruby_mac_app_store_l125_d17_cleanup_items(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	mut entries := []ExtensionEntry{}
	for item in (args[1] or { brew_runtime.array_value([]) }).as_array() or { []brew_runtime.Value{} } {
		values := item.map_data.clone()
		entries << ExtensionEntry{ entry_type: (values['type'] or { brew_runtime.string_value('') }).as_string(), name: (values['name'] or { brew_runtime.string_value('') }).as_string(), options: (values['options'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).map_data.clone() }
	}
	return brew_runtime.string_array_value(mac_app_store_cleanup_items(mut state, entries))
}

// Ruby method `cleanup!(items)` at line 138.
pub fn ruby_mac_app_store_l138_d18_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	mac_app_store_cleanup(mut state, (args[1] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return mac_app_store_state_value(state)
}

// Ruby method `app_id_installed?(id)` at line 149.
pub fn ruby_mac_app_store_l149_d19_app_id_installed(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.bool_value(mac_app_store_app_id_installed(mut state, (args[1] or { brew_runtime.int_value(0) }).int_data))
}

// Ruby method `app_id_upgradable?(id)` at line 154.
pub fn ruby_mac_app_store_l154_d20_app_id_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.bool_value(mac_app_store_app_id_upgradable(mut state, (args[1] or { brew_runtime.int_value(0) }).int_data))
}

// Ruby method `app_id_installed_and_up_to_date?(id, no_upgrade: false)` at line 159.
pub fn ruby_mac_app_store_l159_d21_app_id_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.bool_value(mac_app_store_app_id_installed_and_up_to_date(mut state, (args[1] or { brew_runtime.int_value(0) }).int_data, args.len > 2 && args[2].bool_data))
}

// Ruby method `outdated_app_ids` at line 167.
pub fn ruby_mac_app_store_l167_d22_outdated_app_ids(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.string_array_value(mac_app_store_outdated_app_ids(mut state))
}

// Ruby method `preinstall!(name, id = nil, with: nil, no_upgrade: false, verbose: false, **options)` at line 191.
pub fn ruby_mac_app_store_l191_d23_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	id := if args.len > 2 && args[2].type_name == 'Integer' { ?i64(args[2].int_data) } else { none }
	result := mac_app_store_preinstall(mut state, (args[1] or { brew_runtime.string_value('') }).as_string(), id, args.len > 3 && args[3].bool_data, args.len > 4 && args[4].bool_data) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'state':  mac_app_store_state_value(state)
	})
}

// Ruby method `install!(name, id = nil, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 223.
pub fn ruby_mac_app_store_l223_d24_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	id := if args.len > 2 && args[2].type_name == 'Integer' { ?i64(args[2].int_data) } else { none }
	result := mac_app_store_install(mut state, (args[1] or { brew_runtime.string_value('') }).as_string(), id, args.len <= 3 || args[3].bool_data, args.len > 4 && args[4].bool_data) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(result)
		'state':  mac_app_store_state_value(state)
	})
}

// Ruby method `parse_cleanup_item(item)` at line 255.
pub fn ruby_mac_app_store_l255_d25_parse_cleanup_item(args ...brew_runtime.Value) brew_runtime.Value {
	return mac_app_store_app_value(mac_app_store_parse_cleanup_item((args[0] or { brew_runtime.string_value('') }).as_string()) or { return brew_runtime.object_value('TypeError', err.msg()) })
}

// Ruby method `format_checkable(entries)` at line 268.
pub fn ruby_mac_app_store_l268_d26_format_checkable(args ...brew_runtime.Value) brew_runtime.Value {
	mut entries := []ExtensionEntry{}
	for item in (args[0] or { brew_runtime.array_value([]) }).as_array() or { []brew_runtime.Value{} } {
		values := item.map_data.clone()
		entries << ExtensionEntry{ entry_type: (values['type'] or { brew_runtime.string_value('') }).as_string(), name: (values['name'] or { brew_runtime.string_value('') }).as_string(), options: (values['options'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).map_data.clone() }
	}
	return mac_app_store_checkables_value(mac_app_store_format_checkable(entries))
}

// Ruby method `exit_early_check(packages, no_upgrade:)` at line 275.
pub fn ruby_mac_app_store_l275_d27_exit_early_check(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.string_array_value(mac_app_store_exit_early_check(mut state, mac_app_store_checkables_from_value(args[1] or { brew_runtime.array_value([]) }), args.len > 2 && args[2].bool_data))
}

// Ruby method `full_check(packages, no_upgrade:)` at line 285.
pub fn ruby_mac_app_store_l285_d28_full_check(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.string_array_value(mac_app_store_full_check(mut state, mac_app_store_checkables_from_value(args[1] or { brew_runtime.array_value([]) }), args.len > 2 && args[2].bool_data))
}

// Ruby method `failure_reason(package, no_upgrade:)` at line 292.
pub fn ruby_mac_app_store_l292_d29_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(mac_app_store_failure_reason((args[0] or { brew_runtime.string_value('') }).as_string(), args.len > 1 && args[1].bool_data))
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 298.
pub fn ruby_mac_app_store_l298_d30_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := mac_app_store_state_from_value(args[0] or { mac_app_store_state_value(MacAppStoreState{}) })
	return brew_runtime.bool_value(mac_app_store_app_id_installed_and_up_to_date(mut state, (args[1] or { brew_runtime.int_value(0) }).int_data, args.len > 2 && args[2].bool_data))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5: require "json"
// 6:
// 7: module Homebrew
// 8:   module Bundle
// 9:     class MacAppStore < Extension
// 10:       class App < T::Struct
// 11:         const :id, String
// 12:         const :name, String
// 13:       end
// 14:       CheckablePackages = T.type_alias { T.any(T::Array[Object], T::Hash[Integer, String]) }
// 15:
// 16:       class << self
// 17:         sig { override.returns(Symbol) }
// 18:         def type = :mas
// 19:
// 20:         sig { override.returns(String) }
// 21:         def check_label = "App"
// 22:
// 23:         sig { override.returns(String) }
// 24:         def banner_name = "Mac App Store dependencies"
// 25:
// 26:         sig { override.returns(Symbol) }
// 27:         def legacy_check_step
// 28:           :apps_to_install
// 29:         end
// 30:
// 31:         sig { override.returns(T::Boolean) }
// 32:         def add_supported?
// 33:           false
// 34:         end
// 35:
// 36:         sig { override.returns(T.nilable(String)) }
// 37:         def cleanup_heading
// 38:           "Mac App Store apps"
// 39:         end
// 40:
// 41:         sig { override.params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 42:         def entry(name, options = {})
// 43:           id = options[:id]
// 44:           raise "options[:id](#{id}) should be an Integer object" unless id.is_a? Integer
// 45:
// 46:           Dsl::Entry.new(type, name, id:)
// 47:         end
// 48:
// 49:         sig { override.void }
// 50:         def reset!
// 51:           @apps = T.let(nil, T.nilable(T::Array[[String, String]]))
// 52:           @packages = T.let(nil, T.nilable(T::Array[App]))
// 53:           @installed_app_ids = T.let(nil, T.nilable(T::Array[String]))
// 54:           @outdated_app_ids = T.let(nil, T.nilable(T::Array[String]))
// 55:         end
// 56:
// 57:         sig { returns(T::Array[[String, String]]) }
// 58:         def apps
// 59:           apps = @apps
// 60:           return apps if apps
// 61:
// 62:           @apps = if (mas = package_manager_executable)
// 63:             `#{mas} list 2>/dev/null`.split("\n").filter_map do |app|
// 64:               app_details = app.match(/\A\s*(?<id>\d+)\s+(?<name>.*?)\s+\((?<version>[\d.]*)\)\Z/)
// 65:               next if app_details.nil?
// 66:
// 67:               id = app_details[:id]
// 68:               name = app_details[:name]
// 69:               next if id.nil? || name.nil?
// 70:
// 71:               # Only add the application details should we have a valid match.
// 72:               # Strip unprintable characters
// 73:               [id, name.gsub(/[[:cntrl:]]|\p{C}/, "")]
// 74:             end
// 75:           end
// 76:           return [] if @apps.nil?
// 77:
// 78:           @apps
// 79:         end
// 80:
// 81:         sig { returns(T::Array[String]) }
// 82:         def app_ids
// 83:           apps.map(&:first)
// 84:         end
// 85:
// 86:         sig { override.returns(T::Array[App]) }
// 87:         def packages
// 88:           packages = @packages
// 89:           return packages if packages
// 90:
// 91:           @packages = apps.sort_by { |_, name| name.downcase }.map { |id, name| App.new(id:, name:) }
// 92:         end
// 93:
// 94:         sig { override.returns(T::Array[App]) }
// 95:         def installed_packages
// 96:           packages
// 97:         end
// 98:
// 99:         sig { returns(T::Array[String]) }
// 100:         def installed_app_ids
// 101:           installed_app_ids = @installed_app_ids
// 102:           return installed_app_ids if installed_app_ids
// 103:
// 104:           @installed_app_ids = app_ids
// 105:         end
// 106:
// 107:         sig { override.params(package: Object).returns(String) }
// 108:         def dump_entry(package)
// 109:           app = T.cast(package, App)
// 110:           "mas #{quote(app.name)}, id: #{app.id}"
// 111:         end
// 112:
// 113:         sig { params(app: App).returns(String) }
// 114:         def cleanup_item(app)
// 115:           JSON.generate("id" => app.id, "name" => app.name)
// 116:         end
// 117:
// 118:         sig { override.params(item: String).returns(String) }
// 119:         def cleanup_item_name(item)
// 120:           app = parse_cleanup_item(item)
// 121:           "#{app.name} (#{app.id})"
// 122:         end
// 123:
// 124:         sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[String]) }
// 125:         def cleanup_items(entries)
// 126:           return [].freeze unless package_manager_installed?
// 127:
// 128:           kept_app_ids = entries.filter_map do |entry|
// 129:             entry.options[:id].to_s if entry.type == type
// 130:           end
// 131:           return [].freeze if kept_app_ids.empty?
// 132:
// 133:           packages.reject { |app| app.id.to_i.zero? || kept_app_ids.any? { |id| app.id.to_i == id.to_i } }
// 134:                   .map { |app| cleanup_item(app) }
// 135:         end
// 136:
// 137:         sig { override.params(items: T::Array[String]).void }
// 138:         def cleanup!(items)
// 139:           mas = package_manager_executable
// 140:           return if mas.nil?
// 141:
// 142:           items.each do |item|
// 143:             Bundle.system(mas, "uninstall", parse_cleanup_item(item).id, verbose: false)
// 144:           end
// 145:           puts "Uninstalled #{items.size} Mac App Store app#{"s" if items.size != 1}"
// 146:         end
// 147:
// 148:         sig { params(id: Integer).returns(T::Boolean) }
// 149:         def app_id_installed?(id)
// 150:           installed_app_ids.any? { |app_id| app_id.to_i == id }
// 151:         end
// 152:
// 153:         sig { params(id: Integer).returns(T::Boolean) }
// 154:         def app_id_upgradable?(id)
// 155:           outdated_app_ids.any? { |app_id| app_id.to_i == id }
// 156:         end
// 157:
// 158:         sig { params(id: Integer, no_upgrade: T::Boolean).returns(T::Boolean) }
// 159:         def app_id_installed_and_up_to_date?(id, no_upgrade: false)
// 160:           return false unless app_id_installed?(id)
// 161:           return true if no_upgrade
// 162:
// 163:           !app_id_upgradable?(id)
// 164:         end
// 165:
// 166:         sig { returns(T::Array[String]) }
// 167:         def outdated_app_ids
// 168:           outdated_app_ids = @outdated_app_ids
// 169:           return outdated_app_ids if outdated_app_ids
// 170:
// 171:           @outdated_app_ids = if (mas = package_manager_executable)
// 172:             `#{mas} outdated 2>/dev/null`.split("\n").map do |app|
// 173:               app.split(" ", 2).first.to_s
// 174:             end
// 175:           end
// 176:           return [] if @outdated_app_ids.nil?
// 177:
// 178:           @outdated_app_ids
// 179:         end
// 180:
// 181:         sig {
// 182:           override.params(
// 183:             name:       String,
// 184:             id:         T.nilable(Integer),
// 185:             with:       T.nilable(T::Array[String]),
// 186:             no_upgrade: T::Boolean,
// 187:             verbose:    T::Boolean,
// 188:             options:    Homebrew::Bundle::EntryOption,
// 189:           ).returns(T::Boolean)
// 190:         }
// 191:         def preinstall!(name, id = nil, with: nil, no_upgrade: false, verbose: false, **options)
// 192:           _ = with
// 193:           id ||= T.cast(options[:id], T.nilable(Integer))
// 194:           raise ArgumentError, "missing keyword: id" if id.nil?
// 195:
// 196:           unless package_manager_installed?
// 197:             puts "Installing mas. It is not currently installed." if verbose
// 198:             Bundle.system(HOMEBREW_BREW_FILE, "install", "mas", verbose:)
// 199:             raise "Unable to install #{name} app. mas installation failed." unless package_manager_installed?
// 200:           end
// 201:
// 202:           if app_id_installed?(id) &&
// 203:              (no_upgrade || !app_id_upgradable?(id))
// 204:             puts "Skipping install of #{name} app. It is already installed." if verbose
// 205:             return false
// 206:           end
// 207:
// 208:           true
// 209:         end
// 210:
// 211:         sig {
// 212:           override.params(
// 213:             name:       String,
// 214:             id:         T.nilable(Integer),
// 215:             with:       T.nilable(T::Array[String]),
// 216:             preinstall: T::Boolean,
// 217:             no_upgrade: T::Boolean,
// 218:             verbose:    T::Boolean,
// 219:             force:      T::Boolean,
// 220:             options:    Homebrew::Bundle::EntryOption,
// 221:           ).returns(T::Boolean)
// 222:         }
// 223:         def install!(name, id = nil, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 224:                      **options)
// 225:           _ = with
// 226:           id ||= T.cast(options[:id], T.nilable(Integer))
// 227:           raise ArgumentError, "missing keyword: id" if id.nil?
// 228:
// 229:           _ = no_upgrade
// 230:           _ = force
// 231:
// 232:           return true unless preinstall
// 233:
// 234:           mas = package_manager_executable!
// 235:
// 236:           if app_id_installed?(id)
// 237:             puts "Upgrading #{name} app. It is installed but not up-to-date." if verbose
// 238:             return false unless Bundle.system(mas, "upgrade", id.to_s, verbose:)
// 239:
// 240:             return true
// 241:           end
// 242:
// 243:           puts "Installing #{name} app. It is not currently installed." if verbose
// 244:           installed = Bundle.system(mas, "install", id.to_s, verbose:) ||
// 245:                       Bundle.system(mas, "get", id.to_s, verbose:)
// 246:           return false unless installed
// 247:
// 248:           apps << [id.to_s, name] unless apps.any? { |app_id, _app_name| app_id.to_i == id }
// 249:           packages << App.new(id: id.to_s, name:) unless packages.any? { |app| app.id.to_i == id }
// 250:           installed_app_ids << id.to_s unless installed_app_ids.include?(id.to_s)
// 251:           true
// 252:         end
// 253:
// 254:         sig { params(item: String).returns(App) }
// 255:         def parse_cleanup_item(item)
// 256:           parsed = JSON.parse(item)
// 257:           raise TypeError, "Invalid Mac App Store cleanup item: #{item}" unless parsed.is_a?(Hash)
// 258:
// 259:           id = parsed["id"]
// 260:           name = parsed["name"]
// 261:           raise TypeError, "Invalid Mac App Store cleanup item: #{item}" if !id.is_a?(String) || !name.is_a?(String)
// 262:
// 263:           App.new(id:, name:)
// 264:         end
// 265:       end
// 266:
// 267:       sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 268:       def format_checkable(entries)
// 269:         checkable_entries(entries).map do |entry|
// 270:           [T.cast(entry.options.fetch(:id), Integer), entry.name]
// 271:         end
// 272:       end
// 273:
// 274:       sig { override.params(packages: CheckablePackages, no_upgrade: T::Boolean).returns(T::Array[String]) }
// 275:       def exit_early_check(packages, no_upgrade:)
// 276:         (packages.is_a?(Hash) ? packages.to_a : packages).each do |id, name|
// 277:           next if installed_and_up_to_date?(id, no_upgrade:)
// 278:
// 279:           return [failure_reason(name, no_upgrade:)]
// 280:         end
// 281:         []
// 282:       end
// 283:
// 284:       sig { override.params(packages: CheckablePackages, no_upgrade: T::Boolean).returns(T::Array[String]) }
// 285:       def full_check(packages, no_upgrade:)
// 286:         (packages.is_a?(Hash) ? packages.to_a : packages)
// 287:           .reject { |id, _name| installed_and_up_to_date?(id, no_upgrade:) }
// 288:           .map { |_id, name| failure_reason(name, no_upgrade:) }
// 289:       end
// 290:
// 291:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(String) }
// 292:       def failure_reason(package, no_upgrade:)
// 293:         reason = no_upgrade ? "needs to be installed." : "needs to be installed or updated."
// 294:         "#{self.class.check_label} #{package} #{reason}"
// 295:       end
// 296:
// 297:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 298:       def installed_and_up_to_date?(package, no_upgrade: false)
// 299:         self.class.app_id_installed_and_up_to_date?(T.cast(package, Integer), no_upgrade:)
// 300:       end
// 301:     end
// 302:   end
// 303: end
