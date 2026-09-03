module extensions

import brew_runtime
import json2

pub const winget_default_source = 'winget'
pub const winget_sources = ['winget', 'msstore']

pub struct WingetApp {
pub:
	id     string
	name   string
	source string
}

pub struct WingetRecord {
pub:
	id     string
	source string
}

pub struct WingetState {
pub mut:
	is_wsl     bool
	executable string
	apps       []WingetApp
	packages   []WingetApp
	records    []WingetRecord
	output     []string
	commands   [][]string
}

pub struct WingetCommandResult {
pub:
	success bool
	output  string
}

pub fn winget_command_result_value(result WingetCommandResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'success': brew_runtime.bool_value(result.success)
		'output':  brew_runtime.string_value(result.output)
	})
}

pub fn winget_command_result_from_value(value brew_runtime.Value) WingetCommandResult {
	values := value.as_map() or { return WingetCommandResult{} }
	return WingetCommandResult{
		success: if 'success' in values { values['success'].as_bool() or { false } } else { false }
		output: if 'output' in values { values['output'].as_string() } else { '' }
	}
}

fn winget_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

pub fn winget_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Winget'
		type_name: 'winget'
		banner_name: 'WinGet packages'
		check_label: 'WinGet Package'
		cleanup_heading: 'WinGet packages'
	}
}

pub fn winget_app_value(app WingetApp) brew_runtime.Value {
	return brew_runtime.map_value({
		'id':     brew_runtime.string_value(app.id)
		'name':   brew_runtime.string_value(app.name)
		'source': brew_runtime.string_value(app.source)
	})
}

pub fn winget_app_from_value(value brew_runtime.Value) WingetApp {
	values := value.as_map() or {
		return WingetApp{
			id: value.as_string()
			name: value.as_string()
			source: winget_default_source
		}
	}
	return WingetApp{
		id: if 'id' in values { values['id'].as_string() } else { '' }
		name: if 'name' in values { values['name'].as_string() } else { '' }
		source: if 'source' in values {
			values['source'].as_string()} else {
			winget_default_source}
	}
}

pub fn winget_apps_value(apps []WingetApp) brew_runtime.Value {
	return brew_runtime.array_value(apps.map(winget_app_value(it)))
}

pub fn winget_apps_from_value(value brew_runtime.Value) []WingetApp {
	items := value.as_array() or { return [] }
	return items.map(winget_app_from_value(it))
}

fn winget_records_value(records []WingetRecord) brew_runtime.Value {
	return brew_runtime.array_value(records.map(brew_runtime.array_value([
		brew_runtime.string_value(it.id),
		brew_runtime.string_value(it.source),
	])))
}

fn winget_records_from_value(value brew_runtime.Value) []WingetRecord {
	items := value.as_array() or { return [] }
	mut records := []WingetRecord{}
	for item in items {
		parts := item.as_array() or { continue }
		if parts.len >= 2 {
			records << WingetRecord{
				id: parts[0].as_string()
				source: parts[1].as_string()
			}
		}
	}
	return records
}

pub fn winget_state_value(state WingetState) brew_runtime.Value {
	return brew_runtime.map_value({
		'_definition': extension_definition_value(winget_definition())
		'is_wsl':      brew_runtime.bool_value(state.is_wsl)
		'executable':  if state.executable == '' {
			brew_runtime.object_value('NilClass', '')
		} else {
			brew_runtime.object_value('Pathname', state.executable)
		}
		'apps':        winget_apps_value(state.apps)
		'packages':    winget_apps_value(state.packages)
		'records':     winget_records_value(state.records)
		'output':      brew_runtime.string_array_value(state.output)
		'commands':    brew_runtime.array_value(state.commands.map(brew_runtime.string_array_value(it)))
	})
}

pub fn winget_state_from_value(value brew_runtime.Value) WingetState {
	values := value.as_map() or { return WingetState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return WingetState{
		is_wsl: if 'is_wsl' in values { values['is_wsl'].as_bool() or { false } } else { false }
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()} else {
			''}
		apps: if 'apps' in values { winget_apps_from_value(values['apps']) } else { [] }
		packages: if 'packages' in values { winget_apps_from_value(values['packages']) } else { [] }
		records: if 'records' in values { winget_records_from_value(values['records']) } else { [] }
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn winget_entry(name string, options map[string]brew_runtime.Value) !ExtensionEntry {
	mut unknown_options := []string{}
	for key in options.keys() {
		if key !in ['id', 'source'] {
			unknown_options << ':${key}'
		}
	}
	if unknown_options.len > 0 {
		return error('unknown options([${unknown_options.join(', ')}]) for winget')
	}
	id := if 'id' in options { options['id'] } else { brew_runtime.string_value(name) }
	if id.type_name != 'String' {
		return error('options[:id](${id.repr}) should be a String object')
	}
	source := if 'source' in options {
		options['source']
	} else {
		brew_runtime.string_value(winget_default_source)
	}
	if source.type_name != 'String' {
		return error('options[:source](${source.repr}) should be a String object')
	}
	if source.as_string() !in winget_sources {
		return error('options[:source](${source.repr}) should be one of ["winget", "msstore"]')
	}
	return ExtensionEntry{
		entry_type: 'winget'
		name: name
		options: {
			'id':     id
			'source': source
		}
	}
}

pub fn winget_windows_path_to_wsl_path(path string) ?string {
	normalized := path.replace('\\', '/')
	if normalized.starts_with('/') {
		return normalized
	}
	if normalized.len < 4 || normalized[1..3] != ':/' || !((normalized[0] >= `A` && normalized[0] <= `Z`) || (normalized[0] >= `a` && normalized[0] <= `z`)) {
		return none
	}
	drive := normalized[0].ascii_str().to_lower()
	return '/mnt/${drive}/${normalized[3..]}'
}

pub fn winget_windows_apps_executables(environment map[string]string, detected_local_appdata string) []string {
	mut windows_paths := []string{}
	if local := environment['LOCALAPPDATA'] {
		windows_paths << '${local}\\Microsoft\\WindowsApps\\winget.exe'
	}
	if profile := environment['USERPROFILE'] {
		windows_paths << '${profile}\\AppData\\Local\\Microsoft\\WindowsApps\\winget.exe'
	}
	if detected_local_appdata != '' {
		windows_paths << '${detected_local_appdata}\\Microsoft\\WindowsApps\\winget.exe'
	}
	mut paths := []string{}
	for path in windows_paths {
		if path.contains('%') {
			continue
		}
		converted := winget_windows_path_to_wsl_path(path) or { continue }
		if converted !in paths {
			paths << converted
		}
	}
	return paths
}

pub fn winget_parse_list_names(output string) map[string]string {
	lines := output.replace('\r', '').split_into_lines()
	mut header_index := -1
	for index, line in lines {
		name_position := line.index('Name') or { -1 }
		id_position := line.index('Id') or { -1 }
		version_position := line.index('Version') or { -1 }
		if name_position >= 0 && id_position > name_position && version_position > id_position {
			header_index = index
			break
		}
	}
	if header_index < 0 {
		return {}
	}
	header := lines[header_index]
	header_start := header.index('Name') or { return {} }
	id_column := header.index_after('Id', header_start) or { return {} }
	version_column := header.index_after('Version', header_start) or { return {} }
	mut names := map[string]string{}
	for index in header_index + 1 .. lines.len {
		line := lines[index]
		if line.trim_space() == '' || line.len <= header_start || line[header_start..].trim_space().trim('-') == '' {
			continue
		}
		if line.len < version_column {
			continue
		}
		name := line[header_start..id_column].trim_space()
		id := line[id_column..version_column].trim_space()
		if name != '' && id != '' {
			names[id.to_lower()] = name
		}
	}
	return names
}

pub fn winget_export_apps(exported []WingetApp, names map[string]string) []WingetApp {
	return exported.map(WingetApp{
		id: it.id
		name: names[it.id.to_lower()] or { it.name }
		source: it.source
	})
}

pub fn winget_parse_export(output string, source string) []WingetApp {
	decoded := json2.decode[json2.Any](output) or { return [] }
	if decoded !is map[string]json2.Any {
		return []
	}
	export := decoded as map[string]json2.Any
	sources_value := export['Sources'] or { return [] }
	if sources_value !is []json2.Any {
		return []
	}
	mut apps := []WingetApp{}
	for source_value in sources_value as []json2.Any {
		if source_value !is map[string]json2.Any {
			continue
		}
		source_export := source_value as map[string]json2.Any
		packages_value := source_export['Packages'] or { continue }
		if packages_value !is []json2.Any {
			continue
		}
		for package_value in packages_value as []json2.Any {
			if package_value !is map[string]json2.Any {
				continue
			}
			package := package_value as map[string]json2.Any
			id_value := package['PackageIdentifier'] or { continue }
			if id_value !is string {
				continue
			}
			id := id_value as string
			if id.trim_space() == '' {
				continue
			}
			apps << WingetApp{
				id: id
				name: id
				source: source
			}
		}
	}
	return apps
}

fn winget_ascii_word(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_`
}

fn winget_word_prefix(value string, prefix string) bool {
	return value == prefix || (value.starts_with(prefix) && value.len > prefix.len && !winget_ascii_word(value[prefix.len]))
}

fn winget_contains_word(value string, word string) bool {
	mut position := 0
	for position <= value.len - word.len {
		index := value.index_after(word, position) or { return false }
		end := index + word.len
		if (index == 0 || !winget_ascii_word(value[index - 1])) && (end == value.len || !winget_ascii_word(value[end])) {
			return true
		}
		position = index + 1
	}
	return false
}

pub fn winget_internal_package(app WingetApp) bool {
	for value in [app.id, app.name] {
		lower := value.to_lower()
		if lower in ['app installer', '9nblggh4nns1', 'microsoft store', 'store experience host',
			'microsoft.onedrive', 'microsoft.wsl', 'nvidia.physx'] {
			return true
		}
		if lower in ['windows feature experience pack', 'windows web experience pack'] {
			return true
		}
		if lower.starts_with('microsoft visual c++') || lower.starts_with('windows app runtime') || lower.starts_with('microsoft.vcredist.') {
			return true
		}
		for prefix in ['microsoft.appinstaller', 'microsoft.desktopappinstaller', 'microsoft.directx',
			'microsoft.dotnet', 'microsoft.edge', 'microsoft.edgewebview2runtime',
			'microsoft.gameinput', 'microsoft.hevcvideoextension', 'microsoft.net.native',
			'microsoft.rawimageextension', 'microsoft.services.store.engagement',
			'microsoft.storepurchaseapp', 'microsoft.ui.xaml', 'microsoft.vclibs',
			'microsoft.windowsappruntime', 'microsoft.windowsstore', 'microsoft.webmediaextensions',
			'microsoft.webpimageextension', 'microsoft.vp9videoextensions'] {
			if winget_word_prefix(lower, prefix) {
				return true
			}
		}
	}
	return false
}

pub fn winget_packages(apps []WingetApp) []WingetApp {
	mut packages := apps.filter(!winget_internal_package(it))
	packages.sort_with_compare(fn (a &WingetApp, b &WingetApp) int {
		a_index := winget_sources.index(a.source)
		b_index := winget_sources.index(b.source)
		a_source := if a_index < 0 { winget_sources.len } else { a_index }
		b_source := if b_index < 0 { winget_sources.len } else { b_index }
		if a_source != b_source {
			return a_source - b_source
		}
		return a.name.to_lower().compare(b.name.to_lower())
	})
	return packages
}

pub fn winget_app_installed(records []WingetRecord, id string, source string) bool {
	return records.any(it.id.to_lower() == id.to_lower() && it.source == source)
}

pub fn winget_dump_entry(app WingetApp) string {
	mut line := 'winget ${extension_quote(app.name)}'
	if app.id != app.name {
		line += ', id: ${extension_quote(app.id)}'
	}
	if app.source != winget_default_source {
		line += ', source: ${extension_quote(app.source)}'
	}
	return line
}

pub fn winget_cleanup_item(app WingetApp) string {
	return '{"id":${extension_quote(app.id)},"name":${extension_quote(app.name)},"source":${extension_quote(app.source)}}'
}

pub fn winget_parse_cleanup_item(item string) !WingetApp {
	decoded := json2.decode[json2.Any](item) or { return error('Invalid WinGet cleanup item: ${item}') }
	if decoded !is map[string]json2.Any {
		return error('Invalid WinGet cleanup item: ${item}')
	}
	parsed := decoded as map[string]json2.Any
	id_value := parsed['id'] or { return error('Invalid WinGet cleanup item: ${item}') }
	name_value := parsed['name'] or { return error('Invalid WinGet cleanup item: ${item}') }
	source_value := parsed['source'] or { return error('Invalid WinGet cleanup item: ${item}') }
	if id_value !is string || name_value !is string || source_value !is string {
		return error('Invalid WinGet cleanup item: ${item}')
	}
	return WingetApp{
		id: id_value as string
		name: name_value as string
		source: source_value as string
	}
}

pub fn winget_cleanup_item_name(item string) !string {
	app := winget_parse_cleanup_item(item)!
	if app.name == app.id && app.source == winget_default_source {
		return app.id
	}
	if app.name == app.id {
		return '${app.id} (${app.source})'
	}
	if app.source == winget_default_source {
		return '${app.name} (${app.id})'
	}
	return '${app.name} (${app.id}, ${app.source})'
}

pub fn winget_cleanup_items(entries []ExtensionEntry, executable string, exported []WingetApp) []string {
	mut kept := []WingetRecord{}
	for entry in entries {
		if entry.entry_type != 'winget' {
			continue
		}
		kept << WingetRecord{
			id: if 'id' in entry.options { entry.options['id'].as_string() } else { entry.name }
			source: if 'source' in entry.options {
				entry.options['source'].as_string()} else {
				winget_default_source}
		}
	}
	if kept.len == 0 || executable == '' {
		return []
	}
	return winget_packages(exported).filter(!winget_app_installed(kept, it.id, it.source)).map(winget_cleanup_item(it))
}

pub fn winget_powershell_quote(value string) string {
	return "'${value.replace("'", "''")}'"
}

pub fn winget_elevation_failure(output string) bool {
	lower := output.to_lower()
	return lower.contains('installer failed with exit code: 1603') || winget_contains_word(lower, 'admin') || winget_contains_word(lower, 'administrator') || winget_contains_word(lower, 'elevat') || winget_contains_word(lower, 'uac')
}

pub fn winget_installer_ui_failure(output string) bool {
	lower := output.to_lower()
	return winget_contains_word(lower, 'interactive') || lower.contains('user input') || lower.contains('user cancelled')
}

pub fn winget_report_install_failure(name string, id string, source string, output string) []string {
	mut lines := ['WinGet failed to install ${name} (${id}) from ${source}.']
	if winget_elevation_failure(output) {
		lines << 'The installer may require Windows UAC/elevation.'
		lines << 'Try installing it from an elevated Windows Terminal:'
		lines << '  winget install --id ${id} --exact --source ${source} --disable-interactivity'
	} else if winget_installer_ui_failure(output) {
		lines << 'The installer appears to require installer UI or user input, which brew bundle does not automate.'
		lines << 'Install it manually from Windows:'
		lines << '  winget install --id ${id} --exact --source ${source}'
	} else {
		lines << 'Try installing it manually from Windows:'
		lines << '  winget install --id ${id} --exact --source ${source}'
	}
	return lines
}

pub fn winget_install_args(id string, source string) []string {
	return ['install', '--id', id, '--exact', '--source', source, '--accept-source-agreements',
		'--accept-package-agreements', '--disable-interactivity']
}

// Translated from Homebrew/brew `bundle/extensions/winget.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :winget` at line 49.
pub fn ruby_winget_l49_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'winget')
}

// Ruby method `check_label = "WinGet Package"` at line 52.
pub fn ruby_winget_l52_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('WinGet Package')
}

// Ruby method `banner_name = "WinGet packages"` at line 55.
pub fn ruby_winget_l55_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('WinGet packages')
}

// Ruby method `switch_description(description)` at line 58.
pub fn ruby_winget_l58_d4_switch_description(args ...brew_runtime.Value) brew_runtime.Value {
	description := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_value('${extension_switch_description(description)} Note: WSL only.')
}

// Ruby method `add_supported?` at line 63.
pub fn ruby_winget_l63_d5_add_supported(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby method `cleanup_heading` at line 68.
pub fn ruby_winget_l68_d6_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('WinGet packages')
}

// Ruby method `entry(name, options = {})` at line 73.
pub fn ruby_winget_l73_d7_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('ArgumentError', 'name is required')
	}
	options := if args.len > 1 {
		args[1].as_map() or { return winget_error('ArgumentError', err.msg()) }
	} else {
		map[string]brew_runtime.Value{}
	}
	entry := winget_entry(args[0].as_string(), options) or { return winget_error('RuntimeError', err.msg()) }
	return extension_entry_value(entry)
}

// Ruby method `package_manager_executable` at line 90.
pub fn ruby_winget_l90_d8_package_manager_executable(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	if !state.is_wsl || state.executable == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.object_value('Pathname', state.executable)
}

// Ruby method `windows_apps_executables` at line 97.
pub fn ruby_winget_l97_d9_windows_apps_executables(args ...brew_runtime.Value) brew_runtime.Value {
	environment := if args.len > 0 {
		args[0].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	mut strings := map[string]string{}
	for key, value in environment {
		strings[key] = value.as_string()
	}
	detected := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.array_value(winget_windows_apps_executables(strings, detected).map(brew_runtime.object_value('Pathname', it)))
}

// Ruby method `windows_local_appdata` at line 108.
pub fn ruby_winget_l108_d10_windows_local_appdata(args ...brew_runtime.Value) brew_runtime.Value {
	cmd_executable := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	output := if args.len > 1 { args[1].as_string().trim_space() } else { '' }
	if !cmd_executable || output == '' {
		return brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.string_value(output)
}

// Ruby method `windows_path_to_wsl_path(path)` at line 116.
pub fn ruby_winget_l116_d11_windows_path_to_wsl_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	if path := winget_windows_path_to_wsl_path(args[0].as_string()) {
		return brew_runtime.object_value('Pathname', path)
	}
	return brew_runtime.object_value('NilClass', '')
}

// Ruby method `reset!` at line 131.
pub fn ruby_winget_l131_d12_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	state.apps = []
	state.packages = []
	state.records = []
	return winget_state_value(state)
}

// Ruby method `apps` at line 138.
pub fn ruby_winget_l138_d13_apps(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	if state.apps.len > 0 {
		return winget_apps_value(state.apps)
	}
	if state.executable == '' {
		return winget_apps_value([])
	}
	if args.len > 1 {
		return winget_apps_value(winget_apps_from_value(args[1]))
	}
	return winget_apps_value(state.apps)
}

// Ruby method `export_apps(winget, source:)` at line 153.
pub fn ruby_winget_l153_d14_export_apps(args ...brew_runtime.Value) brew_runtime.Value {
	exported := if args.len > 1 { winget_apps_from_value(args[1]) } else { [] }
	name_values := if args.len > 2 {
		args[2].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	mut names := map[string]string{}
	for key, value in name_values {
		names[key] = value.as_string()
	}
	return winget_apps_value(winget_export_apps(exported, names))
}

// Ruby method `exported_apps(winget, source:)` at line 161.
pub fn ruby_winget_l161_d15_exported_apps(args ...brew_runtime.Value) brew_runtime.Value {
	success := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	if !success {
		return winget_apps_value([])
	}
	output := if args.len > 3 { args[3].as_string() } else { '' }
	source := if args.len > 1 { args[1].as_string() } else { winget_default_source }
	return winget_apps_value(winget_parse_export(output, source))
}

// Ruby method `listed_app_names(winget, source:)` at line 172.
pub fn ruby_winget_l172_d16_listed_app_names(args ...brew_runtime.Value) brew_runtime.Value {
	output := if args.len > 2 {
		args[2].as_string()
	} else if args.len > 0 { args[0].as_string() } else { '' }
	mut names := map[string]brew_runtime.Value{}
	for key, value in winget_parse_list_names(output) {
		names[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(names)
}

// Ruby method `parse_list_names(output)` at line 180.
pub fn ruby_winget_l180_d17_parse_list_names(args ...brew_runtime.Value) brew_runtime.Value {
	output := if args.len > 0 { args[0].as_string() } else { '' }
	mut names := map[string]brew_runtime.Value{}
	for key, value in winget_parse_list_names(output) {
		names[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(names)
}

// Ruby method `windows_export_path(path)` at line 206.
pub fn ruby_winget_l206_d18_windows_export_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { '' }
	converted := if args.len > 1 { args[1].as_string().trim_space() } else { '' }
	failed := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return brew_runtime.string_value(if !failed && converted != '' { converted } else { path })
}

// Ruby method `parse_export(output, source:)` at line 216.
pub fn ruby_winget_l216_d19_parse_export(args ...brew_runtime.Value) brew_runtime.Value {
	output := if args.len > 0 { args[0].as_string() } else { '' }
	source := if args.len > 1 { args[1].as_string() } else { winget_default_source }
	return winget_apps_value(winget_parse_export(output, source))
}

// Ruby method `packages` at line 243.
pub fn ruby_winget_l243_d20_packages(args ...brew_runtime.Value) brew_runtime.Value {
	apps := if args.len > 0 { winget_apps_from_value(args[0]) } else { [] }
	return winget_apps_value(winget_packages(apps))
}

// Ruby method `installed_packages` at line 252.
pub fn ruby_winget_l252_d21_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	apps := if args.len > 0 { winget_apps_from_value(args[0]) } else { [] }
	return winget_apps_value(apps)
}

// Ruby method `internal_package?(app)` at line 257.
pub fn ruby_winget_l257_d22_internal_package(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(winget_internal_package(winget_app_from_value(args[0])))
}

// Ruby method `installed_app_records` at line 264.
pub fn ruby_winget_l264_d23_installed_app_records(args ...brew_runtime.Value) brew_runtime.Value {
	apps := if args.len > 0 { winget_apps_from_value(args[0]) } else { [] }
	return winget_records_value(apps.map(WingetRecord{ id: it.id, source: it.source }))
}

// Ruby method `dump_name(package)` at line 272.
pub fn ruby_winget_l272_d24_dump_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(winget_app_from_value(args[0]).name)
}

// Ruby method `dump_entry(package)` at line 277.
pub fn ruby_winget_l277_d25_dump_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('ArgumentError', 'package is required')
	}
	return brew_runtime.string_value(winget_dump_entry(winget_app_from_value(args[0])))
}

// Ruby method `cleanup_item(app)` at line 287.
pub fn ruby_winget_l287_d26_cleanup_item(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('ArgumentError', 'app is required')
	}
	return brew_runtime.string_value(winget_cleanup_item(winget_app_from_value(args[0])))
}

// Ruby method `cleanup_item_name(item)` at line 292.
pub fn ruby_winget_l292_d27_cleanup_item_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('ArgumentError', 'item is required')
	}
	name := winget_cleanup_item_name(args[0].as_string()) or { return winget_error('TypeError', err.msg()) }
	return brew_runtime.string_value(name)
}

// Ruby method `cleanup_items(entries)` at line 303.
pub fn ruby_winget_l303_d28_cleanup_items(args ...brew_runtime.Value) brew_runtime.Value {
	entries_value := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	entries := entries_value.map(extension_entry_from_value(it))
	executable := if args.len > 1 { args[1].as_string() } else { '' }
	exported := if args.len > 2 { winget_apps_from_value(args[2]) } else { [] }
	return brew_runtime.string_array_value(winget_cleanup_items(entries, executable, exported))
}

// Ruby method `cleanup!(items)` at line 326.
pub fn ruby_winget_l326_d29_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	items := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	if state.executable == '' {
		return winget_state_value(state)
	}
	for item in items {
		app := winget_parse_cleanup_item(item) or { return winget_error('TypeError', err.msg()) }
		state.commands << [state.executable, 'uninstall', '--id', app.id, '--exact', '--source',
			app.source, '--accept-source-agreements', '--disable-interactivity']
	}
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} WinGet package${suffix}'
	return winget_state_value(state)
}

// Ruby method `app_installed?(id, source:)` at line 339.
pub fn ruby_winget_l339_d30_app_installed(args ...brew_runtime.Value) brew_runtime.Value {
	records := if args.len > 0 { winget_records_from_value(args[0]) } else { [] }
	id := if args.len > 1 { args[1].as_string() } else { '' }
	source := if args.len > 2 { args[2].as_string() } else { winget_default_source }
	return brew_runtime.bool_value(winget_app_installed(records, id, source))
}

// Ruby method `preinstall!(name, id: nil, with: nil, no_upgrade: false, verbose: false, source: DEFAULT_SOURCE,` at line 354.
pub fn ruby_winget_l354_d31_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	id := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { name }
	source := if args.len > 3 { args[3].as_string() } else { winget_default_source }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	if state.executable == '' {
		return winget_error('RuntimeError', 'Unable to install ${name} WinGet package. winget.exe is not installed.')
	}
	if winget_app_installed(state.records, id, source) {
		if verbose {
			return brew_runtime.map_value({
				'result': brew_runtime.bool_value(false)
				'output': brew_runtime.string_value('Skipping install of ${name} WinGet package. It is already installed.')
			})
		}
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `install!(name, id: nil, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 387.
pub fn ruby_winget_l387_d32_install(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := if args.len > 0 { winget_state_from_value(args[0]) } else { WingetState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	id := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { name }
	source := if args.len > 3 { args[3].as_string() } else { winget_default_source }
	preinstall := if args.len > 4 { args[4].as_bool() or { true } } else { true }
	if !preinstall {
		return brew_runtime.bool_value(true)
	}
	if state.executable == '' {
		return winget_error('RuntimeError', 'winget.exe is not installed')
	}
	normal := if args.len > 5 {
		winget_command_result_from_value(args[5])
	} else {
		WingetCommandResult{}
	}
	mut success := normal.success
	mut output := normal.output
	state.commands << ([state.executable] as []string)
	state.commands[state.commands.len - 1] << winget_install_args(id, source)
	if !success && winget_elevation_failure(output) {
		state.output << 'WinGet install for ${name} may require Windows UAC/elevation; retrying elevated.'
		elevated := if args.len > 6 {
			winget_command_result_from_value(args[6])
		} else {
			WingetCommandResult{}
		}
		success = elevated.success
		if elevated.output != '' {
			output = elevated.output
		}
	}
	if !success {
		state.output << winget_report_install_failure(name, id, source, output)
		return brew_runtime.map_value({
			'result': brew_runtime.bool_value(false)
			'state':  winget_state_value(state)
		})
	}
	if !state.apps.any(it.id.to_lower() == id.to_lower() && it.source == source) {
		state.apps << WingetApp{ id: id, name: name, source: source }
		state.packages = winget_packages(state.apps)
	}
	if !winget_app_installed(state.records, id, source) {
		state.records << WingetRecord{ id: id, source: source }
	}
	return brew_runtime.map_value({
		'result': brew_runtime.bool_value(true)
		'state':  winget_state_value(state)
	})
}

// Ruby method `run_install_command(winget, args, verbose:, elevated:)` at line 430.
pub fn ruby_winget_l430_d33_run_install_command(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 4 {
		return args[4]
	}
	return winget_command_result_value(WingetCommandResult{})
}

// Ruby method `run_elevated_install_command(winget, args, verbose:)` at line 448.
pub fn ruby_winget_l448_d34_run_elevated_install_command(args ...brew_runtime.Value) brew_runtime.Value {
	winget := if args.len > 0 { args[0].as_string() } else { '' }
	command_args := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	powershell := if args.len > 2 { args[2].as_string() } else { '' }
	if powershell == '' {
		return winget_command_result_value(WingetCommandResult{ output: 'powershell.exe is not available.\n' })
	}
	winget_path := if winget.contains('/') && args.len > 3 && args[3].as_string() != '' {
		args[3].as_string()
	} else {
		winget
	}
	argument_list := command_args.map(winget_powershell_quote(it)).join(', ')
	script := "\$startProcessArgs = @{\n  FilePath = ${winget_powershell_quote(winget_path)}\n  ArgumentList = @(${argument_list})\n  Verb = 'RunAs'\n  Wait = \$true\n  PassThru = \$true\n}\n\$process = Start-Process @startProcessArgs\n\$process.WaitForExit()\nexit \$process.ExitCode\n"
	success := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	return brew_runtime.map_value({
		'success':    brew_runtime.bool_value(success)
		'output':     brew_runtime.string_value('')
		'powershell': brew_runtime.object_value('Pathname', powershell)
		'script':     brew_runtime.string_value(script)
	})
}

// Ruby method `powershell_quote(value)` at line 472.
pub fn ruby_winget_l472_d35_powershell_quote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(winget_powershell_quote(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `elevation_failure?(output)` at line 477.
pub fn ruby_winget_l477_d36_elevation_failure(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(winget_elevation_failure(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `installer_ui_failure?(output)` at line 482.
pub fn ruby_winget_l482_d37_installer_ui_failure(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(winget_installer_ui_failure(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `report_install_failure(name, id:, source:, output:)` at line 487.
pub fn ruby_winget_l487_d38_report_install_failure(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	id := if args.len > 1 { args[1].as_string() } else { name }
	source := if args.len > 2 { args[2].as_string() } else { winget_default_source }
	output := if args.len > 3 { args[3].as_string() } else { '' }
	return brew_runtime.string_array_value(winget_report_install_failure(name, id, source, output))
}

// Ruby method `parse_cleanup_item(item)` at line 504.
pub fn ruby_winget_l504_d39_parse_cleanup_item(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return winget_error('TypeError', 'Invalid WinGet cleanup item: ')
	}
	app := winget_parse_cleanup_item(args[0].as_string()) or { return winget_error('TypeError', err.msg()) }
	return winget_app_value(app)
}

// Ruby method `format_checkable(entries)` at line 520.
pub fn ruby_winget_l520_d40_format_checkable(args ...brew_runtime.Value) brew_runtime.Value {
	entries_value := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	mut apps := []WingetApp{}
	for entry_value in entries_value {
		entry := extension_entry_from_value(entry_value)
		if entry.entry_type != 'winget' {
			continue
		}
		apps << WingetApp{
			id: if 'id' in entry.options { entry.options['id'].as_string() } else { entry.name }
			name: entry.name
			source: if 'source' in entry.options {
				entry.options['source'].as_string()} else {
				winget_default_source}
		}
	}
	return winget_apps_value(apps)
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 528.
pub fn ruby_winget_l528_d41_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	records := winget_records_from_value(args[0])
	app := winget_app_from_value(args[1])
	return brew_runtime.bool_value(winget_app_installed(records, app.id, app.source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5: require "json"
// 6: require "tempfile"
// 7: require "utils/popen"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     # Support dumping and installing Windows packages through WinGet from WSL.
// 12:     class Winget < Extension
// 13:       # Parsed WinGet package details.
// 14:       class App < T::Struct
// 15:         const :id, String
// 16:         const :name, String
// 17:         const :source, String
// 18:       end
// 19:
// 20:       DEFAULT_SOURCE = "winget"
// 21:       SOURCES = T.let([DEFAULT_SOURCE, "msstore"].freeze, T::Array[String])
// 22:       ELEVATED_INSTALL_FAILURE_PATTERNS = T.let([
// 23:         /Installer failed with exit code:\s*1603/i,
// 24:         /\b(?:admin|administrator|elevat|UAC)\b/i,
// 25:       ].freeze, T::Array[Regexp])
// 26:       INSTALLER_UI_FAILURE_PATTERNS = T.let([
// 27:         /\b(?:interactive|user input|user cancelled)\b/i,
// 28:       ].freeze, T::Array[Regexp])
// 29:       INTERNAL_PACKAGE_PATTERNS = T.let([
// 30:         /\AApp Installer\z/i,
// 31:         /\A9NBLGGH4NNS1\z/i,
// 32:         /\AMicrosoft Store\z/i,
// 33:         /\AStore Experience Host\z/i,
// 34:         /\AWindows (?:Feature|Web) Experience Pack\z/i,
// 35:         /\AMicrosoft Edge WebView2 Runtime\z/i,
// 36:         /\AMicrosoft Visual C\+\+/i,
// 37:         /\AWindows App Runtime/i,
// 38:         /\AMicrosoft\.(?:AppInstaller|DesktopAppInstaller|DirectX|DotNet|Edge|EdgeWebView2Runtime|GameInput)\b/i,
// 39:         /\AMicrosoft\.(?:HEVCVideoExtension|NET\.Native|RawImageExtension)\b/i,
// 40:         /\AMicrosoft\.(?:OneDrive|WSL)\z/i,
// 41:         /\AMicrosoft\.(?:Services\.Store\.Engagement|StorePurchaseApp|UI\.Xaml|VCLibs|WindowsAppRuntime)\b/i,
// 42:         /\AMicrosoft\.(?:WindowsStore|WebMediaExtensions|WebpImageExtension|VP9VideoExtensions)\b/i,
// 43:         /\AMicrosoft\.VCRedist\./i,
// 44:         /\ANvidia\.PhysX\z/i,
// 45:       ].freeze, T::Array[Regexp])
// 46:
// 47:       class << self
// 48:         sig { override.returns(Symbol) }
// 49:         def type = :winget
// 50:
// 51:         sig { override.returns(String) }
// 52:         def check_label = "WinGet Package"
// 53:
// 54:         sig { override.returns(String) }
// 55:         def banner_name = "WinGet packages"
// 56:
// 57:         sig { override.params(description: String).returns(String) }
// 58:         def switch_description(description)
// 59:           "#{super} Note: WSL only."
// 60:         end
// 61:
// 62:         sig { override.returns(T::Boolean) }
// 63:         def add_supported?
// 64:           false
// 65:         end
// 66:
// 67:         sig { override.returns(T.nilable(String)) }
// 68:         def cleanup_heading
// 69:           banner_name
// 70:         end
// 71:
// 72:         sig { override.params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 73:         def entry(name, options = {})
// 74:           unknown_options = options.keys - [:id, :source]
// 75:           raise "unknown options(#{unknown_options.inspect}) for winget" if unknown_options.present?
// 76:
// 77:           id = options.fetch(:id, name)
// 78:           raise "options[:id](#{id.inspect}) should be a String object" unless id.is_a?(String)
// 79:
// 80:           source = options.fetch(:source, DEFAULT_SOURCE)
// 81:           raise "options[:source](#{source.inspect}) should be a String object" unless source.is_a?(String)
// 82:           unless SOURCES.include?(source)
// 83:             raise "options[:source](#{source.inspect}) should be one of #{SOURCES.inspect}"
// 84:           end
// 85:
// 86:           Dsl::Entry.new(type, name, id:, source:)
// 87:         end
// 88:
// 89:         sig { override.returns(T.nilable(Pathname)) }
// 90:         def package_manager_executable
// 91:           return unless OS.wsl?
// 92:
// 93:           which("winget.exe", ORIGINAL_PATHS) || windows_apps_executables.find(&:executable?)
// 94:         end
// 95:
// 96:         sig { returns(T::Array[Pathname]) }
// 97:         def windows_apps_executables
// 98:           [
// 99:             ENV.fetch("LOCALAPPDATA", nil)&.+("\\Microsoft\\WindowsApps\\winget.exe"),
// 100:             ENV.fetch("USERPROFILE", nil)&.+("\\AppData\\Local\\Microsoft\\WindowsApps\\winget.exe"),
// 101:             windows_local_appdata&.+("\\Microsoft\\WindowsApps\\winget.exe"),
// 102:           ].compact.uniq.filter_map do |path|
// 103:             windows_path_to_wsl_path(path) if path.exclude?("%")
// 104:           end
// 105:         end
// 106:
// 107:         sig { returns(T.nilable(String)) }
// 108:         def windows_local_appdata
// 109:           cmd = which("cmd.exe", ORIGINAL_PATHS) || Pathname.new("/mnt/c/Windows/System32/cmd.exe")
// 110:           return unless cmd.executable?
// 111:
// 112:           `"#{cmd}" /d /c echo %LOCALAPPDATA% 2>/dev/null`.strip.presence
// 113:         end
// 114:
// 115:         sig { params(path: String).returns(T.nilable(Pathname)) }
// 116:         def windows_path_to_wsl_path(path)
// 117:           path = path.tr("\\", "/")
// 118:           return Pathname.new(path) if path.start_with?("/")
// 119:
// 120:           match = path.match(%r{\A([A-Za-z]):/(.+)\z})
// 121:           return if match.nil?
// 122:
// 123:           drive = match[1]
// 124:           relative_path = match[2]
// 125:           return if drive.nil? || relative_path.nil?
// 126:
// 127:           Pathname.new("/mnt/#{drive.downcase}/#{relative_path}")
// 128:         end
// 129:
// 130:         sig { override.void }
// 131:         def reset!
// 132:           @apps = T.let(nil, T.nilable(T::Array[App]))
// 133:           @packages = T.let(nil, T.nilable(T::Array[App]))
// 134:           @installed_app_records = T.let(nil, T.nilable(T::Array[[String, String]]))
// 135:         end
// 136:
// 137:         sig { returns(T::Array[App]) }
// 138:         def apps
// 139:           apps = @apps
// 140:           return apps if apps
// 141:
// 142:           @apps = if (winget = package_manager_executable)
// 143:             SOURCES.flat_map do |source|
// 144:               export_apps(winget, source:)
// 145:             end
// 146:           end
// 147:           return [] if @apps.nil?
// 148:
// 149:           @apps
// 150:         end
// 151:
// 152:         sig { params(winget: Pathname, source: String).returns(T::Array[App]) }
// 153:         def export_apps(winget, source:)
// 154:           names = listed_app_names(winget, source:)
// 155:           exported_apps(winget, source:).map do |app|
// 156:             App.new(id: app.id, name: names.fetch(app.id.downcase, app.name), source: app.source)
// 157:           end
// 158:         end
// 159:
// 160:         sig { params(winget: Pathname, source: String).returns(T::Array[App]) }
// 161:         def exported_apps(winget, source:)
// 162:           Tempfile.create(["brew-bundle-winget", ".json"]) do |file|
// 163:             next [] unless Kernel.system(winget.to_s, "export", "--source", source, "--output",
// 164:                                          windows_export_path(file.path), "--accept-source-agreements",
// 165:                                          "--disable-interactivity", out: File::NULL, err: File::NULL)
// 166:
// 167:             parse_export(File.read(file.path), source:)
// 168:           end
// 169:         end
// 170:
// 171:         sig { params(winget: Pathname, source: String).returns(T::Hash[String, String]) }
// 172:         def listed_app_names(winget, source:)
// 173:           output = Utils.popen_read(winget, "list", "--source", source, "--accept-source-agreements",
// 174:                                     "--disable-interactivity", "--nowarn", err: :close)
// 175:
// 176:           parse_list_names(output)
// 177:         end
// 178:
// 179:         sig { params(output: String).returns(T::Hash[String, String]) }
// 180:         def parse_list_names(output)
// 181:           lines = output.encode("UTF-8", invalid: :replace, undef: :replace)
// 182:                         .delete("\r")
// 183:                         .lines
// 184:                         .map(&:chomp)
// 185:           header_index = lines.index { |line| line.match?(/\bName\s+Id\s+Version\b/) }
// 186:           return {} if header_index.nil?
// 187:
// 188:           header = lines[header_index]
// 189:           return {} if header.nil?
// 190:
// 191:           header_start = header.index("Name")
// 192:           id_column = header.index("Id", header_start || 0)
// 193:           version_column = header.index("Version", header_start || 0)
// 194:           return {} if header_start.nil? || id_column.nil? || version_column.nil?
// 195:
// 196:           lines.drop(header_index + 1).each_with_object({}) do |line, names|
// 197:             next if line.blank? || line[header_start..].to_s.match?(/\A-+\z/)
// 198:
// 199:             name = line[header_start...id_column].to_s.strip
// 200:             id = line[id_column...version_column].to_s.strip
// 201:             names[id.downcase] = name if name.present? && id.present?
// 202:           end
// 203:         end
// 204:
// 205:         sig { params(path: String).returns(String) }
// 206:         def windows_export_path(path)
// 207:           wslpath = which("wslpath", ORIGINAL_PATHS)
// 208:           return path if wslpath.nil?
// 209:
// 210:           Utils.safe_popen_read(wslpath, "-w", path, err: :close).chomp.presence || path
// 211:         rescue ErrorDuringExecution
// 212:           path
// 213:         end
// 214:
// 215:         sig { params(output: String, source: String).returns(T::Array[App]) }
// 216:         def parse_export(output, source:)
// 217:           export = JSON.parse(output)
// 218:           return [] unless export.is_a?(Hash)
// 219:
// 220:           sources = export["Sources"]
// 221:           return [] unless sources.is_a?(Array)
// 222:
// 223:           sources.flat_map do |source_export|
// 224:             next [] unless source_export.is_a?(Hash)
// 225:
// 226:             packages = source_export["Packages"]
// 227:             next [] unless packages.is_a?(Array)
// 228:
// 229:             packages.filter_map do |package|
// 230:               next unless package.is_a?(Hash)
// 231:
// 232:               id = package["PackageIdentifier"]
// 233:               next if !id.is_a?(String) || id.blank?
// 234:
// 235:               App.new(id:, name: id, source:)
// 236:             end
// 237:           end
// 238:         rescue JSON::ParserError
// 239:           []
// 240:         end
// 241:
// 242:         sig { override.returns(T::Array[App]) }
// 243:         def packages
// 244:           packages = @packages
// 245:           return packages if packages
// 246:
// 247:           @packages = apps.reject { |app| internal_package?(app) }
// 248:                           .sort_by { |app| [SOURCES.index(app.source) || SOURCES.length, app.name.downcase] }
// 249:         end
// 250:
// 251:         sig { override.returns(T::Array[App]) }
// 252:         def installed_packages
// 253:           apps
// 254:         end
// 255:
// 256:         sig { params(app: App).returns(T::Boolean) }
// 257:         def internal_package?(app)
// 258:           INTERNAL_PACKAGE_PATTERNS.any? do |pattern|
// 259:             pattern.match?(app.id) || pattern.match?(app.name)
// 260:           end
// 261:         end
// 262:
// 263:         sig { returns(T::Array[[String, String]]) }
// 264:         def installed_app_records
// 265:           installed_app_records = @installed_app_records
// 266:           return installed_app_records if installed_app_records
// 267:
// 268:           @installed_app_records = apps.map { |app| [app.id, app.source] }
// 269:         end
// 270:
// 271:         sig { override.params(package: Object).returns(String) }
// 272:         def dump_name(package)
// 273:           T.cast(package, App).name
// 274:         end
// 275:
// 276:         sig { override.params(package: Object).returns(String) }
// 277:         def dump_entry(package)
// 278:           app = T.cast(package, App)
// 279:           line = "winget #{quote(app.name)}"
// 280:           line += ", id: #{quote(app.id)}" if app.id != app.name
// 281:           return line if app.source == DEFAULT_SOURCE
// 282:
// 283:           "#{line}, source: #{quote(app.source)}"
// 284:         end
// 285:
// 286:         sig { params(app: App).returns(String) }
// 287:         def cleanup_item(app)
// 288:           JSON.generate("id" => app.id, "name" => app.name, "source" => app.source)
// 289:         end
// 290:
// 291:         sig { params(item: String).returns(String) }
// 292:         def cleanup_item_name(item)
// 293:           app = parse_cleanup_item(item)
// 294:           return app.id if app.name == app.id && app.source == DEFAULT_SOURCE
// 295:           return "#{app.id} (#{app.source})" if app.name == app.id
// 296:
// 297:           return "#{app.name} (#{app.id})" if app.source == DEFAULT_SOURCE
// 298:
// 299:           "#{app.name} (#{app.id}, #{app.source})"
// 300:         end
// 301:
// 302:         sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[String]) }
// 303:         def cleanup_items(entries)
// 304:           kept_apps = entries.filter_map do |entry|
// 305:             next if entry.type != type
// 306:
// 307:             [entry.options.fetch(:id, entry.name).to_s, entry.options.fetch(:source, DEFAULT_SOURCE).to_s]
// 308:           end
// 309:           return [].freeze if kept_apps.empty?
// 310:
// 311:           winget = package_manager_executable
// 312:           return [].freeze if winget.nil?
// 313:
// 314:           cleanup_packages = SOURCES.flat_map { |source| exported_apps(winget, source:) }
// 315:                                     .reject { |app| internal_package?(app) }
// 316:                                     .sort_by do |app|
// 317:                                       [SOURCES.index(app.source) || SOURCES.length, app.name.downcase]
// 318:                                     end
// 319:           packages_to_cleanup = cleanup_packages.reject do |app|
// 320:             kept_apps.any? { |id, source| app.id.casecmp?(id) && app.source == source }
// 321:           end
// 322:           packages_to_cleanup.map { |app| cleanup_item(app) }
// 323:         end
// 324:
// 325:         sig { override.params(items: T::Array[String]).void }
// 326:         def cleanup!(items)
// 327:           winget = package_manager_executable
// 328:           return if winget.nil?
// 329:
// 330:           items.each do |item|
// 331:             app = parse_cleanup_item(item)
// 332:             Bundle.system(winget, "uninstall", "--id", app.id, "--exact", "--source", app.source,
// 333:                           "--accept-source-agreements", "--disable-interactivity", verbose: false)
// 334:           end
// 335:           puts "Uninstalled #{items.size} WinGet package#{"s" if items.size != 1}"
// 336:         end
// 337:
// 338:         sig { params(id: String, source: String).returns(T::Boolean) }
// 339:         def app_installed?(id, source:)
// 340:           installed_app_records.any? { |app_id, app_source| app_id.casecmp?(id) && app_source == source }
// 341:         end
// 342:
// 343:         sig {
// 344:           override.params(
// 345:             name:       String,
// 346:             id:         T.nilable(String),
// 347:             with:       T.nilable(T::Array[String]),
// 348:             no_upgrade: T::Boolean,
// 349:             verbose:    T::Boolean,
// 350:             source:     String,
// 351:             options:    Homebrew::Bundle::EntryOption,
// 352:           ).returns(T::Boolean)
// 353:         }
// 354:         def preinstall!(name, id: nil, with: nil, no_upgrade: false, verbose: false, source: DEFAULT_SOURCE,
// 355:                         **options)
// 356:           _ = with
// 357:           _ = no_upgrade
// 358:           _ = options
// 359:
// 360:           id ||= name
// 361:
// 362:           unless package_manager_installed?
// 363:             raise "Unable to install #{name} WinGet package. winget.exe is not installed."
// 364:           end
// 365:
// 366:           if app_installed?(id, source:)
// 367:             puts "Skipping install of #{name} WinGet package. It is already installed." if verbose
// 368:             return false
// 369:           end
// 370:
// 371:           true
// 372:         end
// 373:
// 374:         sig {
// 375:           override.params(
// 376:             name:       String,
// 377:             id:         T.nilable(String),
// 378:             with:       T.nilable(T::Array[String]),
// 379:             preinstall: T::Boolean,
// 380:             no_upgrade: T::Boolean,
// 381:             verbose:    T::Boolean,
// 382:             force:      T::Boolean,
// 383:             source:     String,
// 384:             options:    Homebrew::Bundle::EntryOption,
// 385:           ).returns(T::Boolean)
// 386:         }
// 387:         def install!(name, id: nil, with: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 388:                      source: DEFAULT_SOURCE, **options)
// 389:           _ = with
// 390:           _ = no_upgrade
// 391:           _ = force
// 392:           _ = options
// 393:
// 394:           return true unless preinstall
// 395:
// 396:           id ||= name
// 397:           winget = package_manager_executable!
// 398:           args = ["install", "--id", id, "--exact", "--source", source,
// 399:                   "--accept-source-agreements", "--accept-package-agreements",
// 400:                   "--disable-interactivity"]
// 401:           success, output = run_install_command(winget, args, verbose:, elevated: false)
// 402:           if !success && elevation_failure?(output)
// 403:             puts "WinGet install for #{name} may require Windows UAC/elevation; retrying elevated."
// 404:             success, elevated_output = run_install_command(winget, args, verbose:, elevated: true)
// 405:             output = elevated_output.presence || output
// 406:           end
// 407:           unless success
// 408:             report_install_failure(name, id:, source:, output:)
// 409:             return false
// 410:           end
// 411:
// 412:           unless apps.any? { |app| app.id.casecmp?(id) && app.source == source }
// 413:             apps << App.new(id:, name:, source:)
// 414:             @packages = nil
// 415:           end
// 416:           installed_app_records << [id, source] unless installed_app_records.any? do |app_id, app_source|
// 417:             app_id.casecmp?(id) && app_source == source
// 418:           end
// 419:           true
// 420:         end
// 421:
// 422:         sig {
// 423:           params(
// 424:             winget:   Pathname,
// 425:             args:     T::Array[String],
// 426:             verbose:  T::Boolean,
// 427:             elevated: T::Boolean,
// 428:           ).returns([T::Boolean, String])
// 429:         }
// 430:         def run_install_command(winget, args, verbose:, elevated:)
// 431:           return run_elevated_install_command(winget, args, verbose:) if elevated
// 432:
// 433:           logs = T.let([], T::Array[String])
// 434:           success = T.let(false, T::Boolean)
// 435:           IO.popen([winget.to_s, *args], err: [:child, :out]) do |pipe|
// 436:             while (line = pipe.gets)
// 437:               print line if verbose
// 438:               logs << line
// 439:             end
// 440:             Process.wait(pipe.pid)
// 441:             success = $CHILD_STATUS.success?
// 442:             pipe.close
// 443:           end
// 444:           [success, logs.join]
// 445:         end
// 446:
// 447:         sig { params(winget: Pathname, args: T::Array[String], verbose: T::Boolean).returns([T::Boolean, String]) }
// 448:         def run_elevated_install_command(winget, args, verbose:)
// 449:           powershell = which("powershell.exe", ORIGINAL_PATHS) ||
// 450:                        Pathname.new("/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe")
// 451:           return [false, "powershell.exe is not available.\n"] unless powershell.executable?
// 452:
// 453:           winget_path = winget.to_s.include?("/") ? windows_export_path(winget.to_s) : winget.to_s
// 454:           argument_list = args.map { |arg| powershell_quote(arg) }.join(", ")
// 455:           script = <<~POWERSHELL
// 456:             $startProcessArgs = @{
// 457:               FilePath = #{powershell_quote(winget_path)}
// 458:               ArgumentList = @(#{argument_list})
// 459:               Verb = 'RunAs'
// 460:               Wait = $true
// 461:               PassThru = $true
// 462:             }
// 463:             $process = Start-Process @startProcessArgs
// 464:             $process.WaitForExit()
// 465:             exit $process.ExitCode
// 466:           POWERSHELL
// 467:
// 468:           [Bundle.system(powershell, "-NoProfile", "-Command", script, verbose:), ""]
// 469:         end
// 470:
// 471:         sig { params(value: String).returns(String) }
// 472:         def powershell_quote(value)
// 473:           "'#{value.gsub("'", "''")}'"
// 474:         end
// 475:
// 476:         sig { params(output: String).returns(T::Boolean) }
// 477:         def elevation_failure?(output)
// 478:           ELEVATED_INSTALL_FAILURE_PATTERNS.any? { |pattern| output.match?(pattern) }
// 479:         end
// 480:
// 481:         sig { params(output: String).returns(T::Boolean) }
// 482:         def installer_ui_failure?(output)
// 483:           INSTALLER_UI_FAILURE_PATTERNS.any? { |pattern| output.match?(pattern) }
// 484:         end
// 485:
// 486:         sig { params(name: String, id: String, source: String, output: String).void }
// 487:         def report_install_failure(name, id:, source:, output:)
// 488:           puts "WinGet failed to install #{name} (#{id}) from #{source}."
// 489:           if elevation_failure?(output)
// 490:             puts "The installer may require Windows UAC/elevation."
// 491:             puts "Try installing it from an elevated Windows Terminal:"
// 492:             puts "  winget install --id #{id} --exact --source #{source} --disable-interactivity"
// 493:           elsif installer_ui_failure?(output)
// 494:             puts "The installer appears to require installer UI or user input, which brew bundle does not automate."
// 495:             puts "Install it manually from Windows:"
// 496:             puts "  winget install --id #{id} --exact --source #{source}"
// 497:           else
// 498:             puts "Try installing it manually from Windows:"
// 499:             puts "  winget install --id #{id} --exact --source #{source}"
// 500:           end
// 501:         end
// 502:
// 503:         sig { params(item: String).returns(App) }
// 504:         def parse_cleanup_item(item)
// 505:           parsed = JSON.parse(item)
// 506:           raise TypeError, "Invalid WinGet cleanup item: #{item}" unless parsed.is_a?(Hash)
// 507:
// 508:           id = parsed["id"]
// 509:           name = parsed["name"]
// 510:           source = parsed["source"]
// 511:           if !id.is_a?(String) || !name.is_a?(String) || !source.is_a?(String)
// 512:             raise TypeError, "Invalid WinGet cleanup item: #{item}"
// 513:           end
// 514:
// 515:           App.new(id:, name:, source:)
// 516:         end
// 517:       end
// 518:
// 519:       sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 520:       def format_checkable(entries)
// 521:         checkable_entries(entries).map do |entry|
// 522:           App.new(id: T.cast(entry.options.fetch(:id), String), name: entry.name,
// 523:                   source: T.cast(entry.options.fetch(:source), String))
// 524:         end
// 525:       end
// 526:
// 527:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 528:       def installed_and_up_to_date?(package, no_upgrade: false)
// 529:         _ = no_upgrade
// 530:
// 531:         app = T.cast(package, App)
// 532:         self.class.app_installed?(app.id, source: app.source)
// 533:       end
// 534:     end
// 535:   end
// 536: end
