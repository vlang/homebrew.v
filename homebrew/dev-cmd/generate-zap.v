module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/generate-zap.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn generate_zap_run_input_boundary(input &GenerateZapRunInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::GenerateZap::Input', '', {
		'generate_zap_input_address': u64(voidptr(input)).str()
	})
}

pub fn generate_zap_cask_boundary(cask &GenerateZapCask) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Cask', cask.token, {
		'generate_zap_cask_address': u64(voidptr(cask)).str()
	})
}

pub fn generate_zap_artifact_boundary(artifact &GenerateZapArtifact) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Artifact::App', artifact.target, {
		'generate_zap_artifact_address': u64(voidptr(artifact)).str()
	})
}

fn generate_zap_run_input_from_value(value brew_runtime.Value) &GenerateZapRunInput {
	address := value.attributes['generate_zap_input_address'] or {
		panic('invalid GenerateZap run input')
	}
	return unsafe { &GenerateZapRunInput(voidptr(address.u64())) }
}

fn generate_zap_cask_from_value(value brew_runtime.Value) &GenerateZapCask {
	address := value.attributes['generate_zap_cask_address'] or {
		panic('invalid GenerateZap cask input')
	}
	return unsafe { &GenerateZapCask(voidptr(address.u64())) }
}

fn generate_zap_artifact_from_value(value brew_runtime.Value) &GenerateZapArtifact {
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
	converted := brew_runtime.run_captured_command([plutil, '-convert', 'xml1', '-o', '-',
		info_plist], brew_runtime.CapturedCommandOptions{
		environment: brew_runtime.environment()
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

fn generate_zap_required_argument(args []brew_runtime.Value, index int, name string) brew_runtime.Value {
	if index >= args.len {
		panic('GenerateZap `${name}` is missing argument ${index + 1}')
	}
	return args[index]
}

fn generate_zap_result_value(result GenerateZapRunResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'patterns': brew_runtime.string_array_value(result.patterns)
		'trash':    brew_runtime.string_array_value(result.trash_paths)
		'delete':   brew_runtime.string_array_value(result.delete_paths)
		'rmdir':    brew_runtime.string_array_value(result.rmdir_paths)
		'info':     brew_runtime.string_array_value(result.info)
		'warnings': brew_runtime.string_array_value(result.warnings)
		'stdout':   brew_runtime.string_value(result.stdout)
	})
}

// Ruby method `run` at line 95.
pub fn ruby_generate_zap_l95_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	input := generate_zap_run_input_from_value(generate_zap_required_argument(args, 0, 'run'))
	result := generate_zap_run(*input) or {
		return brew_runtime.structured_value('RuntimeError', err.msg(), {
			'message': err.msg()
		})
	}
	return generate_zap_result_value(result)
}

// Ruby method `resolve_patterns_from_cask(cask)` at line 133.
pub fn ruby_generate_zap_l133_d2_resolve_patterns_from_cask(args ...brew_runtime.Value) brew_runtime.Value {
	cask := generate_zap_cask_from_value(generate_zap_required_argument(args, 0, 'resolve_patterns_from_cask'))
	patterns := generate_zap_resolve_patterns_from_cask(*cask) or {
		return brew_runtime.structured_value('RuntimeError', err.msg(), {
			'message': err.msg()
		})
	}
	return brew_runtime.string_array_value(patterns)
}

// Ruby method `bundle_identifiers(app_artifact)` at line 146.
pub fn ruby_generate_zap_l146_d3_bundle_identifiers(args ...brew_runtime.Value) brew_runtime.Value {
	artifact := generate_zap_artifact_from_value(generate_zap_required_argument(args, 0, 'bundle_identifiers'))
	identifiers := generate_zap_bundle_identifiers(*artifact) or {
		return brew_runtime.structured_value('RuntimeError', err.msg(), {
			'message': err.msg()
		})
	}
	return brew_runtime.string_array_value(identifiers)
}

// Ruby method `scan_directories(directories, home_relative:, patterns:)` at line 164.
pub fn ruby_generate_zap_l164_d4_scan_directories(args ...brew_runtime.Value) brew_runtime.Value {
	directories := generate_zap_required_argument(args, 0, 'scan_directories').as_string_array() or {
		panic(err)
	}
	home_relative := generate_zap_required_argument(args, 1, 'scan_directories').as_bool() or {
		panic(err)
	}
	patterns := generate_zap_required_argument(args, 2, 'scan_directories').as_string_array() or {
		panic(err)
	}
	home := if args.len > 3 { args[3].as_string() } else { '' }
	return brew_runtime.string_array_value(generate_zap_scan_directories(directories, home_relative, patterns, home))
}

// Ruby method `scan_home_root(patterns)` at line 186.
pub fn ruby_generate_zap_l186_d5_scan_home_root(args ...brew_runtime.Value) brew_runtime.Value {
	patterns := generate_zap_required_argument(args, 0, 'scan_home_root').as_string_array() or {
		panic(err)
	}
	home := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_array_value(generate_zap_scan_home_root(patterns, home))
}

// Ruby method `each_readable_child(dir, &block)` at line 204.
pub fn ruby_generate_zap_l204_d6_each_readable_child(args ...brew_runtime.Value) brew_runtime.Value {
	directory := generate_zap_required_argument(args, 0, 'each_readable_child').as_string()
	return brew_runtime.string_array_value(generate_zap_each_readable_child(directory))
}

// Ruby method `collapse_to_wildcards(paths)` at line 212.
pub fn ruby_generate_zap_l212_d7_collapse_to_wildcards(args ...brew_runtime.Value) brew_runtime.Value {
	paths := generate_zap_required_argument(args, 0, 'collapse_to_wildcards').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_array_value(generate_zap_collapse_to_wildcards(paths))
}

// Ruby method `replace_uuids(paths)` at line 235.
pub fn ruby_generate_zap_l235_d8_replace_uuids(args ...brew_runtime.Value) brew_runtime.Value {
	paths := generate_zap_required_argument(args, 0, 'replace_uuids').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_array_value(generate_zap_replace_uuids(paths))
}

// Ruby method `glob_shared_filelists(paths)` at line 240.
pub fn ruby_generate_zap_l240_d9_glob_shared_filelists(args ...brew_runtime.Value) brew_runtime.Value {
	paths := generate_zap_required_argument(args, 0, 'glob_shared_filelists').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_array_value(generate_zap_glob_shared_filelists(paths))
}

// Ruby method `derive_rmdir_candidates(paths)` at line 245.
pub fn ruby_generate_zap_l245_d10_derive_rmdir_candidates(args ...brew_runtime.Value) brew_runtime.Value {
	paths := generate_zap_required_argument(args, 0, 'derive_rmdir_candidates').as_string_array() or {
		panic(err)
	}
	home := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_array_value(generate_zap_derive_rmdir_candidates(paths, home))
}

// Ruby method `normalize_path(path)` at line 266.
pub fn ruby_generate_zap_l266_d11_normalize_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := generate_zap_required_argument(args, 0, 'normalize_path').as_string()
	home := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_value(generate_zap_normalize_path(path, home))
}

// Ruby method `format_stanza(trash:, delete:, rmdir:)` at line 278.
pub fn ruby_generate_zap_l278_d12_format_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	trash := generate_zap_required_argument(args, 0, 'format_stanza').as_string_array() or {
		panic(err)
	}
	delete := generate_zap_required_argument(args, 1, 'format_stanza').as_string_array() or {
		panic(err)
	}
	rmdir := generate_zap_required_argument(args, 2, 'format_stanza').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_value(generate_zap_format_stanza(trash, delete, rmdir))
}

// Ruby method `format_patterns(patterns)` at line 291.
pub fn ruby_generate_zap_l291_d13_format_patterns(args ...brew_runtime.Value) brew_runtime.Value {
	patterns := generate_zap_required_argument(args, 0, 'format_patterns').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_value(generate_zap_format_patterns(patterns))
}

// Ruby method `find_wildcard_groups(basenames)` at line 296.
pub fn ruby_generate_zap_l296_d14_find_wildcard_groups(args ...brew_runtime.Value) brew_runtime.Value {
	basenames := generate_zap_required_argument(args, 0, 'find_wildcard_groups').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_array_value(generate_zap_find_wildcard_groups(basenames))
}

// Ruby method `format_directive(key, paths)` at line 325.
pub fn ruby_generate_zap_l325_d15_format_directive(args ...brew_runtime.Value) brew_runtime.Value {
	key := generate_zap_required_argument(args, 0, 'format_directive').as_string()
	paths := generate_zap_required_argument(args, 1, 'format_directive').as_string_array() or {
		panic(err)
	}
	return brew_runtime.string_value(generate_zap_format_directive(key, paths))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cask"
// 6: require "system_command"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class GenerateZap < AbstractCommand
// 11:       include SystemCommand::Mixin
// 12:
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Generate a `zap` stanza for a cask by scanning the system for associated
// 16:           files and directories.
// 17:
// 18:           Accepts a cask token (e.g. `firefox`) or, with `--name`, a raw application
// 19:           name string (e.g. `Firefox`). When a cask token is given, the application
// 20:           name is resolved from the cask's `app` artifact.
// 21:
// 22:           The target application should have been launched at least once so that
// 23:           preference files and caches exist on disk.
// 24:
// 25:           Outputs `trash`, `delete`, and `rmdir` directives suitable for pasting
// 26:           into a cask definition.
// 27:         EOS
// 28:
// 29:         switch "--name",
// 30:                description: "Treat the argument as a raw application name instead of a cask token."
// 31:
// 32:         named_args :cask_or_name, number: 1
// 33:       end
// 34:
// 35:       USER_TRASH_PATHS = [
// 36:         "Desktop",
// 37:         "Documents",
// 38:         "Library",
// 39:         "Library/Application Scripts",
// 40:         "Library/Application Support",
// 41:         "Library/Application Support/CrashReporter",
// 42:         "Library/Application Support/com.apple.sharedfilelist/" \
// 43:         "com.apple.LSSharedFileList.ApplicationRecentDocuments",
// 44:         "Library/Caches",
// 45:         "Library/Caches/com.apple.helpd/Generated",
// 46:         "Library/Caches/com.apple.helpd/SDMHelpData/Other/English/HelpSDMIndexFile",
// 47:         "Library/Containers",
// 48:         "Library/Cookies",
// 49:         "Library/Group Containers",
// 50:         "Library/HTTPStorages",
// 51:         "Library/Internet Plug-Ins",
// 52:         "Library/LaunchAgents",
// 53:         "Library/Logs",
// 54:         "Library/Logs/DiagnosticReports",
// 55:         "Library/PreferencePanes",
// 56:         "Library/Preferences",
// 57:         "Library/Preferences/ByHost",
// 58:         "Library/Saved Application State",
// 59:         "Library/WebKit",
// 60:         "Music",
// 61:       ].freeze
// 62:
// 63:       SYSTEM_DELETE_PATHS = [
// 64:         "/Library/Application Support",
// 65:         "/Library/Caches",
// 66:         "/Library/Frameworks",
// 67:         "/Library/LaunchAgents",
// 68:         "/Library/LaunchDaemons",
// 69:         "/Library/Logs",
// 70:         "/Library/PreferencePanes",
// 71:         "/Library/Preferences",
// 72:         "/Library/PrivilegedHelperTools",
// 73:         "/Library/Screen Savers",
// 74:         "/Library/ScriptingAdditions",
// 75:         "/Library/Services",
// 76:         "/Users/Shared",
// 77:         "/etc/newsyslog.d",
// 78:       ].freeze
// 79:
// 80:       RMDIR_EXCLUSIONS = [
// 81:         "Library/Application Support/CrashReporter",
// 82:         "Library/Application Support/com.apple.sharedfilelist/" \
// 83:         "com.apple.LSSharedFileList.ApplicationRecentDocuments",
// 84:         "/Library/Application Support",
// 85:         "/Library/Caches",
// 86:         "/Library/Preferences",
// 87:       ].freeze
// 88:
// 89:       UUID_PATTERN = /[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}/i
// 90:
// 91:       # Keep in sync with `RuboCop::Cop::Cask::SharedFilelistGlob`.
// 92:       SHARED_FILELIST_PATTERN = /\.sfl\d\z/
// 93:
// 94:       sig { override.void }
// 95:       def run
// 96:         patterns = if args.name?
// 97:           [args.named.fetch(0)]
// 98:         else
// 99:           resolve_patterns_from_cask(args.named.to_casks.fetch(0))
// 100:         end
// 101:
// 102:         ohai "Scanning for files matching #{format_patterns(patterns)}..."
// 103:
// 104:         begin
// 105:           trash_paths = scan_directories(USER_TRASH_PATHS, home_relative: true, patterns:) + scan_home_root(patterns)
// 106:           delete_paths = scan_directories(SYSTEM_DELETE_PATHS, home_relative: false, patterns:)
// 107:         rescue Errno::EACCES, Errno::EPERM => e
// 108:           message = "Unable to generate a complete zap stanza: #{e.message}"
// 109:
// 110:           unless Cask::Utils.full_disk_access_enabled?
// 111:             message += " Please enable Full Disk Access for your terminal under " \
// 112:                        "#{Cask::Utils.privacy_security_preference_pane("Full Disk Access")}."
// 113:           end
// 114:
// 115:           odie message
// 116:         end
// 117:
// 118:         trash_paths  = glob_shared_filelists(replace_uuids(collapse_to_wildcards(trash_paths)))
// 119:         delete_paths = glob_shared_filelists(replace_uuids(collapse_to_wildcards(delete_paths)))
// 120:
// 121:         rmdir_paths = derive_rmdir_candidates(trash_paths + delete_paths)
// 122:
// 123:         if trash_paths.empty? && delete_paths.empty?
// 124:           opoo "No files found matching #{format_patterns(patterns)}."
// 125:           puts "# No zap stanza required"
// 126:           return
// 127:         end
// 128:
// 129:         puts format_stanza(trash: trash_paths, delete: delete_paths, rmdir: rmdir_paths)
// 130:       end
// 131:
// 132:       sig { params(cask: Cask::Cask).returns(T::Array[String]) }
// 133:       def resolve_patterns_from_cask(cask)
// 134:         app_artifact = cask.artifacts.find { |a| a.is_a?(Cask::Artifact::App) }
// 135:         if app_artifact
// 136:           patterns = [app_artifact.target.basename(".app").to_s]
// 137:           patterns.concat(bundle_identifiers(app_artifact))
// 138:           patterns.uniq
// 139:         else
// 140:           ohai "No app artifact found in cask \"#{cask.token}\"; using token as app name."
// 141:           [cask.token.tr("-", " ").split.map(&:capitalize).join(" ")]
// 142:         end
// 143:       end
// 144:
// 145:       sig { params(app_artifact: Cask::Artifact::App).returns(T::Array[String]) }
// 146:       def bundle_identifiers(app_artifact)
// 147:         info_plist = app_artifact.target/"Contents/Info.plist"
// 148:         return [] if !info_plist.exist? || !info_plist.readable?
// 149:
// 150:         plist = system_command!("plutil", args: ["-convert", "xml1", "-o", "-", info_plist]).plist
// 151:         bundle_identifier = plist["CFBundleIdentifier"]
// 152:         return [] unless bundle_identifier.is_a?(String)
// 153:
// 154:         [bundle_identifier]
// 155:       end
// 156:
// 157:       sig {
// 158:         params(
// 159:           directories:   T::Array[String],
// 160:           home_relative: T::Boolean,
// 161:           patterns:      T::Array[String],
// 162:         ).returns(T::Array[String])
// 163:       }
// 164:       def scan_directories(directories, home_relative:, patterns:)
// 165:         home = Dir.home
// 166:         downcased_patterns = patterns.map(&:downcase)
// 167:         matches = []
// 168:
// 169:         directories.each do |dir|
// 170:           full_dir = home_relative ? File.join(home, dir) : dir
// 171:           next unless File.directory?(full_dir)
// 172:
// 173:           each_readable_child(full_dir) do |entry|
// 174:             downcased_entry = entry.downcase
// 175:             next unless downcased_patterns.any? { |pattern| downcased_entry.include?(pattern) }
// 176:
// 177:             full_path = File.join(full_dir, entry)
// 178:             matches << normalize_path(full_path)
// 179:           end
// 180:         end
// 181:
// 182:         matches.uniq.sort
// 183:       end
// 184:
// 185:       sig { params(patterns: T::Array[String]).returns(T::Array[String]) }
// 186:       def scan_home_root(patterns)
// 187:         home = Dir.home
// 188:         downcased_patterns = patterns.map(&:downcase)
// 189:         matches = []
// 190:
// 191:         each_readable_child(home) do |entry|
// 192:           next unless entry.start_with?(".")
// 193:
// 194:           downcased_entry = entry.downcase
// 195:           next unless downcased_patterns.any? { |pattern| downcased_entry.include?(pattern) }
// 196:
// 197:           matches << normalize_path(File.join(home, entry))
// 198:         end
// 199:
// 200:         matches.sort
// 201:       end
// 202:
// 203:       sig { params(dir: String, block: T.proc.params(entry: String).void).void }
// 204:       def each_readable_child(dir, &block)
// 205:         Dir.each_child(dir, &block)
// 206:       rescue Errno::EPERM, Errno::EACCES
// 207:         # Skip directories we lack permission to read, e.g. macOS-protected paths.
// 208:         nil
// 209:       end
// 210:
// 211:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 212:       def collapse_to_wildcards(paths)
// 213:         grouped = paths.group_by { |p| File.dirname(p) }
// 214:
// 215:         result = []
// 216:         grouped.each_value do |entries|
// 217:           if entries.size == 1
// 218:             result << entries.first
// 219:             next
// 220:           end
// 221:
// 222:           basenames = entries.map { |e| File.basename(e) }
// 223:           wildcarded = find_wildcard_groups(basenames)
// 224:
// 225:           dir = File.dirname(entries.fetch(0))
// 226:           wildcarded.each do |name|
// 227:             result << File.join(dir, name)
// 228:           end
// 229:         end
// 230:
// 231:         result.uniq.sort
// 232:       end
// 233:
// 234:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 235:       def replace_uuids(paths)
// 236:         paths.map { |p| p.gsub(UUID_PATTERN, "*") }.uniq.sort
// 237:       end
// 238:
// 239:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 240:       def glob_shared_filelists(paths)
// 241:         paths.map { |p| p.sub(SHARED_FILELIST_PATTERN, ".sfl*") }.uniq.sort
// 242:       end
// 243:
// 244:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 245:       def derive_rmdir_candidates(paths)
// 246:         home = Dir.home
// 247:         candidates = []
// 248:
// 249:         paths.each do |path|
// 250:           expanded = path.start_with?("~") ? File.join(home, path[2..]) : path
// 251:           parent = File.dirname(expanded)
// 252:
// 253:           next unless parent.match?(%r{/(Application Support|Containers|Group Containers)/})
// 254:
// 255:           normalized = normalize_path(parent)
// 256:
// 257:           next if RMDIR_EXCLUSIONS.any? { |excl| normalized == "~/#{excl}" || normalized == excl }
// 258:
// 259:           candidates << normalized unless paths.include?(normalized)
// 260:         end
// 261:
// 262:         candidates.uniq.sort
// 263:       end
// 264:
// 265:       sig { params(path: String).returns(String) }
// 266:       def normalize_path(path)
// 267:         home = Dir.home
// 268:         path.start_with?(home) ? path.sub(home, "~") : path
// 269:       end
// 270:
// 271:       sig {
// 272:         params(
// 273:           trash:  T::Array[String],
// 274:           delete: T::Array[String],
// 275:           rmdir:  T::Array[String],
// 276:         ).returns(String)
// 277:       }
// 278:       def format_stanza(trash:, delete:, rmdir:)
// 279:         directives = []
// 280:         directives << format_directive("trash", trash) unless trash.empty?
// 281:         directives << format_directive("delete", delete) unless delete.empty?
// 282:         directives << format_directive("rmdir", rmdir) unless rmdir.empty?
// 283:
// 284:         directives.join(",\n")
// 285:                   .prepend("zap ")
// 286:       end
// 287:
// 288:       private
// 289:
// 290:       sig { params(patterns: T::Array[String]).returns(String) }
// 291:       def format_patterns(patterns)
// 292:         patterns.map { |pattern| "\"#{pattern}\"" }.to_sentence
// 293:       end
// 294:
// 295:       sig { params(basenames: T::Array[String]).returns(T::Array[String]) }
// 296:       def find_wildcard_groups(basenames)
// 297:         return basenames if basenames.size <= 1
// 298:
// 299:         used = Array.new(basenames.size, false)
// 300:         result = []
// 301:
// 302:         basenames.each_with_index do |name, i|
// 303:           next if used[i]
// 304:
// 305:           group_indices = [i]
// 306:           basenames.each_with_index do |other, j|
// 307:             next if i == j || used[j]
// 308:             next unless other.start_with?(name)
// 309:
// 310:             group_indices << j
// 311:           end
// 312:
// 313:           if group_indices.size > 1
// 314:             result << "#{name}*"
// 315:             group_indices.each { |idx| used[idx] = true }
// 316:           else
// 317:             result << name
// 318:           end
// 319:         end
// 320:
// 321:         result
// 322:       end
// 323:
// 324:       sig { params(key: String, paths: T::Array[String]).returns(String) }
// 325:       def format_directive(key, paths)
// 326:         if paths.size == 1
// 327:           "#{key}: \"#{paths.first}\""
// 328:         else
// 329:           items = paths.map { |p| "       \"#{p}\"" }.join(",\n")
// 330:           "#{key}: [\n#{items},\n     ]"
// 331:         end
// 332:       end
// 333:     end
// 334:   end
// 335: end
