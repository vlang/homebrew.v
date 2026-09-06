module extensions

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

pub fn winget_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Winget'
		type_name: 'winget'
		banner_name: 'WinGet packages'
		check_label: 'WinGet Package'
		cleanup_heading: 'WinGet packages'
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
				entry.options['source'].as_string()
			} else {
				winget_default_source
			}
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
