module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/generate-zap.rb`.

pub const generate_zap_user_trash_paths = [
	'Desktop',
	'Documents',
	'Library',
	'Library/Application Scripts',
	'Library/Application Support',
	'Library/Application Support/CrashReporter',
	'Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments',
	'Library/Caches',
	'Library/Caches/com.apple.helpd/Generated',
	'Library/Caches/com.apple.helpd/SDMHelpData/Other/English/HelpSDMIndexFile',
	'Library/Containers',
	'Library/Cookies',
	'Library/Group Containers',
	'Library/HTTPStorages',
	'Library/Internet Plug-Ins',
	'Library/LaunchAgents',
	'Library/Logs',
	'Library/Logs/DiagnosticReports',
	'Library/PreferencePanes',
	'Library/Preferences',
	'Library/Preferences/ByHost',
	'Library/Saved Application State',
	'Library/WebKit',
	'Music',
]

pub const generate_zap_system_delete_paths = [
	'/Library/Application Support',
	'/Library/Caches',
	'/Library/Frameworks',
	'/Library/LaunchAgents',
	'/Library/LaunchDaemons',
	'/Library/Logs',
	'/Library/PreferencePanes',
	'/Library/Preferences',
	'/Library/PrivilegedHelperTools',
	'/Library/Screen Savers',
	'/Library/ScriptingAdditions',
	'/Library/Services',
	'/Users/Shared',
	'/etc/newsyslog.d',
]

const generate_zap_rmdir_exclusions = [
	'Library/Application Support/CrashReporter',
	'Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments',
	'/Library/Application Support',
	'/Library/Caches',
	'/Library/Preferences',
]

pub struct GenerateZapArtifact {
pub:
	kind   string
	target string
}

pub struct GenerateZapCask {
pub:
	token     string
	artifacts []GenerateZapArtifact
}

pub struct GenerateZapCommandOptions {
pub:
	name  bool
	named []string
}

@[heap]
pub struct GenerateZapRunInput {
pub:
	options                GenerateZapCommandOptions
	cask                   GenerateZapCask
	home                   string
	user_trash_paths       []string
	system_delete_paths    []string
	directories_configured bool
	full_disk_access       bool = true
	privacy_preference     string = 'System Settings > Privacy & Security > Full Disk Access'
}

pub struct GenerateZapRunResult {
pub:
	patterns     []string
	trash_paths  []string
	delete_paths []string
	rmdir_paths  []string
	info         []string
	warnings     []string
	stdout       string
}

pub fn generate_zap_run_input_boundary(input &GenerateZapRunInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateZap::Input', '', {
		'generate_zap_input_address': u64(voidptr(input)).str()
	})
}

pub fn generate_zap_cask_boundary(cask &GenerateZapCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.token, {
		'generate_zap_cask_address': u64(voidptr(cask)).str()
	})
}

pub fn generate_zap_artifact_boundary(artifact &GenerateZapArtifact) ruby.Value {
	return ruby.structured_value('Cask::Artifact::App', artifact.target, {
		'generate_zap_artifact_address': u64(voidptr(artifact)).str()
	})
}

fn generate_zap_run_input_from_value(value ruby.Value) &GenerateZapRunInput {
	address := value.attributes['generate_zap_input_address'] or {
		panic('invalid GenerateZap run input')
	}
	return unsafe { &GenerateZapRunInput(voidptr(address.u64())) }
}

fn generate_zap_cask_from_value(value ruby.Value) &GenerateZapCask {
	address := value.attributes['generate_zap_cask_address'] or {
		panic('invalid GenerateZap cask input')
	}
	return unsafe { &GenerateZapCask(voidptr(address.u64())) }
}

fn generate_zap_artifact_from_value(value ruby.Value) &GenerateZapArtifact {
	address := value.attributes['generate_zap_artifact_address'] or {
		panic('invalid GenerateZap artifact input')
	}
	return unsafe { &GenerateZapArtifact(voidptr(address.u64())) }
}

fn generate_zap_home(home string) string {
	if home != '' {
		return os.norm_path(home)
	}
	return os.home_dir()
}

fn generate_zap_unique_sorted(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	result.sort()
	return result
}

fn generate_zap_xml_unescape(value string) string {
	return value.replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&apos;', "'").replace('&amp;', '&')
}

fn generate_zap_plist_string(contents string, key string) ?string {
	marker := '<key>${key}</key>'
	key_index := contents.index(marker) or { return none }
	after_key := key_index + marker.len
	opening := '<string>'
	opening_relative := contents[after_key..].index(opening) or { return none }
	start := after_key + opening_relative + opening.len
	closing_relative := contents[start..].index('</string>') or { return none }
	return generate_zap_xml_unescape(contents[start..start + closing_relative].trim_space())
}

pub fn generate_zap_bundle_identifiers(app_artifact GenerateZapArtifact) ![]string {
	info_plist := os.join_path(app_artifact.target, 'Contents', 'Info.plist')
	if !os.is_file(info_plist) {
		return []
	}
	mut readable_file := os.open(info_plist) or { return [] }
	readable_file.close()
	plutil := if os.is_file('/usr/bin/plutil') { '/usr/bin/plutil' } else { 'plutil' }
	converted := ruby.run_captured_command([plutil, '-convert', 'xml1', '-o', '-', info_plist], ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	if converted.exit_code != 0 {
		return error('plutil failed to read ${info_plist}: ${converted.stderr.trim_space()}')
	}
	bundle_identifier := generate_zap_plist_string(converted.stdout, 'CFBundleIdentifier') or {
		return []
	}
	return [bundle_identifier]
}

pub fn generate_zap_resolve_patterns_from_cask(cask GenerateZapCask) ![]string {
	for artifact in cask.artifacts {
		if artifact.kind != 'app' {
			continue
		}
		mut app_name := os.base(artifact.target)
		if app_name.ends_with('.app') {
			app_name = app_name[..app_name.len - 4]
		}
		mut patterns := [app_name]
		patterns << generate_zap_bundle_identifiers(artifact)!
		return generate_zap_unique_in_order(patterns)
	}
	mut words := []string{}
	for word in cask.token.replace('-', ' ').fields() {
		if word.len == 0 {
			continue
		}
		words << word[..1].to_upper() + word[1..].to_lower()
	}
	return [words.join(' ')]
}

fn generate_zap_unique_in_order(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	return result
}

pub fn generate_zap_each_readable_child(directory string) []string {
	return os.ls(directory) or { [] }
}

pub fn generate_zap_normalize_path(path string, home string) string {
	effective_home := generate_zap_home(home)
	if path.starts_with(effective_home) {
		return path.replace_once(effective_home, '~')
	}
	return path
}

pub fn generate_zap_scan_directories(directories []string, home_relative bool, patterns []string,
	home string) []string {
	effective_home := generate_zap_home(home)
	downcased_patterns := patterns.map(it.to_lower())
	mut matches := []string{}
	for directory in directories {
		full_directory := if home_relative {
			os.join_path(effective_home, directory)
		} else {
			directory
		}
		if !os.is_dir(full_directory) {
			continue
		}
		for entry in generate_zap_each_readable_child(full_directory) {
			downcased_entry := entry.to_lower()
			if downcased_patterns.any(downcased_entry.contains(it)) {
				matches << generate_zap_normalize_path(os.join_path(full_directory, entry), effective_home)
			}
		}
	}
	return generate_zap_unique_sorted(matches)
}

pub fn generate_zap_scan_home_root(patterns []string, home string) []string {
	effective_home := generate_zap_home(home)
	downcased_patterns := patterns.map(it.to_lower())
	mut matches := []string{}
	for entry in generate_zap_each_readable_child(effective_home) {
		if !entry.starts_with('.') {
			continue
		}
		downcased_entry := entry.to_lower()
		if downcased_patterns.any(downcased_entry.contains(it)) {
			matches << generate_zap_normalize_path(os.join_path(effective_home, entry), effective_home)
		}
	}
	matches.sort()
	return matches
}

pub fn generate_zap_find_wildcard_groups(basenames []string) []string {
	if basenames.len <= 1 {
		return basenames.clone()
	}
	mut used := []bool{len: basenames.len}
	mut result := []string{}
	for index, name in basenames {
		if used[index] {
			continue
		}
		mut group_indices := [index]
		for other_index, other in basenames {
			if index == other_index || used[other_index] || !other.starts_with(name) {
				continue
			}
			group_indices << other_index
		}
		if group_indices.len > 1 {
			result << '${name}*'
			for grouped_index in group_indices {
				used[grouped_index] = true
			}
		} else {
			result << name
		}
	}
	return result
}

pub fn generate_zap_collapse_to_wildcards(paths []string) []string {
	mut directory_order := []string{}
	mut grouped := map[string][]string{}
	for path in paths {
		directory := os.dir(path)
		if directory !in grouped {
			directory_order << directory
		}
		grouped[directory] << path
	}
	mut result := []string{}
	for directory in directory_order {
		entries := grouped[directory]
		if entries.len == 1 {
			result << entries[0]
			continue
		}
		basenames := entries.map(os.base(it))
		for name in generate_zap_find_wildcard_groups(basenames) {
			result << os.join_path(directory, name)
		}
	}
	return generate_zap_unique_sorted(result)
}

fn generate_zap_is_hex(character u8) bool {
	return (character >= `0` && character <= `9`) || (character >= `a` && character <= `f`)
		|| (character >= `A` && character <= `F`)
}

fn generate_zap_is_uuid_at(value string, start int) bool {
	if start + 36 > value.len {
		return false
	}
	for offset in 0 .. 36 {
		if offset in [8, 13, 18, 23] {
			if value[start + offset] != `-` {
				return false
			}
		} else if !generate_zap_is_hex(value[start + offset]) {
			return false
		}
	}
	return true
}

fn generate_zap_replace_uuids_in_path(path string) string {
	mut result := ''
	mut index := 0
	for index < path.len {
		if generate_zap_is_uuid_at(path, index) {
			result += '*'
			index += 36
		} else {
			result += path[index].ascii_str()
			index++
		}
	}
	return result
}

pub fn generate_zap_replace_uuids(paths []string) []string {
	return generate_zap_unique_sorted(paths.map(generate_zap_replace_uuids_in_path(it)))
}

pub fn generate_zap_glob_shared_filelists(paths []string) []string {
	mut result := []string{}
	for path in paths {
		if path.len >= 5 && path[path.len - 5..path.len - 1] == '.sfl'
			&& path[path.len - 1] >= `0` && path[path.len - 1] <= `9` {
			result << path[..path.len - 1] + '*'
		} else {
			result << path
		}
	}
	return generate_zap_unique_sorted(result)
}

pub fn generate_zap_derive_rmdir_candidates(paths []string, home string) []string {
	effective_home := generate_zap_home(home)
	mut candidates := []string{}
	for path in paths {
		expanded := if path.starts_with('~/') {
			os.join_path(effective_home, path[2..])
		} else {
			path
		}
		parent := os.dir(expanded)
		if !parent.contains('/Application Support/') && !parent.contains('/Containers/')
			&& !parent.contains('/Group Containers/') {
			continue
		}
		normalized := generate_zap_normalize_path(parent, effective_home)
		mut excluded := false
		for exclusion in generate_zap_rmdir_exclusions {
			if normalized == '~/${exclusion}' || normalized == exclusion {
				excluded = true
				break
			}
		}
		if !excluded && normalized !in paths {
			candidates << normalized
		}
	}
	return generate_zap_unique_sorted(candidates)
}

pub fn generate_zap_format_directive(key string, paths []string) string {
	if paths.len == 1 {
		return '${key}: "${paths[0]}"'
	}
	items := paths.map('       "${it}"').join(',\n')
	return '${key}: [\n${items},\n     ]'
}

pub fn generate_zap_format_stanza(trash []string, delete []string, rmdir []string) string {
	mut directives := []string{}
	if trash.len > 0 {
		directives << generate_zap_format_directive('trash', trash)
	}
	if delete.len > 0 {
		directives << generate_zap_format_directive('delete', delete)
	}
	if rmdir.len > 0 {
		directives << generate_zap_format_directive('rmdir', rmdir)
	}
	return 'zap ' + directives.join(',\n')
}

pub fn generate_zap_format_patterns(patterns []string) string {
	quoted := patterns.map('"${it}"')
	if quoted.len == 0 {
		return ''
	}
	if quoted.len == 1 {
		return quoted[0]
	}
	if quoted.len == 2 {
		return '${quoted[0]} and ${quoted[1]}'
	}
	return quoted[..quoted.len - 1].join(', ') + ', and ' + quoted.last()
}

pub fn generate_zap_run(input GenerateZapRunInput) !GenerateZapRunResult {
	if input.options.named.len != 1 {
		return error('exactly one cask token or application name is required')
	}
	mut info := []string{}
	patterns := if input.options.name {
		[input.options.named[0]]
	} else {
		if !input.cask.artifacts.any(it.kind == 'app') {
			info << 'No app artifact found in cask "${input.cask.token}"; using token as app name.'
		}
		generate_zap_resolve_patterns_from_cask(input.cask)!
	}
	formatted_patterns := generate_zap_format_patterns(patterns)
	info << 'Scanning for files matching ${formatted_patterns}...'
	home := generate_zap_home(input.home)
	user_directories := if input.directories_configured {
		input.user_trash_paths
	} else {
		generate_zap_user_trash_paths
	}
	system_directories := if input.directories_configured {
		input.system_delete_paths
	} else {
		generate_zap_system_delete_paths
	}
	mut trash_paths := generate_zap_scan_directories(user_directories, true, patterns, home)
	trash_paths << generate_zap_scan_home_root(patterns, home)
	trash_paths = generate_zap_glob_shared_filelists(generate_zap_replace_uuids(generate_zap_collapse_to_wildcards(trash_paths)))
	delete_paths := generate_zap_glob_shared_filelists(generate_zap_replace_uuids(generate_zap_collapse_to_wildcards(generate_zap_scan_directories(system_directories, false, patterns, home))))
	mut all_paths := trash_paths.clone()
	all_paths << delete_paths
	rmdir_paths := generate_zap_derive_rmdir_candidates(all_paths, home)
	mut warnings := []string{}
	mut stdout := ''
	if trash_paths.len == 0 && delete_paths.len == 0 {
		warnings << 'No files found matching ${formatted_patterns}.'
		stdout = '# No zap stanza required'
	} else {
		stdout = generate_zap_format_stanza(trash_paths, delete_paths, rmdir_paths)
	}
	return GenerateZapRunResult{
		patterns: patterns
		trash_paths: trash_paths
		delete_paths: delete_paths
		rmdir_paths: rmdir_paths
		info: info
		warnings: warnings
		stdout: stdout
	}
}

fn generate_zap_required_argument(args []ruby.Value, index int, name string) ruby.Value {
	if index >= args.len {
		panic('GenerateZap `${name}` is missing argument ${index + 1}')
	}
	return args[index]
}

fn generate_zap_result_value(result GenerateZapRunResult) ruby.Value {
	return ruby.map_value({
		'patterns': ruby.string_array_value(result.patterns)
		'trash':    ruby.string_array_value(result.trash_paths)
		'delete':   ruby.string_array_value(result.delete_paths)
		'rmdir':    ruby.string_array_value(result.rmdir_paths)
		'info':     ruby.string_array_value(result.info)
		'warnings': ruby.string_array_value(result.warnings)
		'stdout':   ruby.string_value(result.stdout)
	})
}
