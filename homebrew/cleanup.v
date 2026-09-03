module homebrew

import brew_runtime
import os
import time

const cleanup_default_days = 30
const cleanup_gh_actions_days = 3

pub struct CleanupPath {
pub:
	path          string
	exists        bool
	directory     bool
	file          bool
	symlink       bool
	resolved_file bool
	mtime         i64
	ctime         i64
	disk_usage    i64
	locked        bool
}

pub struct CleanupEntry {
pub:
	path      CleanupPath
	type_name string
}

pub struct CleanupFormula {
pub:
	name                     string
	aliases                  []string
	latest_version_installed bool
	pkg_version              string
	installed_versions       []string
	eligible_versions        []string
	resource_versions        map[string]string
	patch_versions           []string
	bottle_version           string
	bottle_rebuild           int
	bottle_outdated          bool
	untrusted                bool
}

pub struct CleanupCask {
pub:
	token             string
	version           string
	installed_version string
	latest            bool
	url               string
	caskroom_path     string
}

pub struct Cleanup {
pub mut:
	args                  []string
	days                  int
	cache                 string
	disk_cleanup_size     i64
	dry_run               bool
	prune                 bool
	scrub                 bool
	cleaned_up_paths      map[string]bool
	formula_cache_paths   map[string][]string
	formula_cache_indexed bool
	unremovable_kegs      []brew_runtime.Value
	output                []string
}

fn cleanup_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn cleanup_bool_attr(value brew_runtime.Value, name string, fallback bool) bool {
	raw := value.attributes[name] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn cleanup_int_attr(value brew_runtime.Value, name string, fallback i64) i64 {
	return (value.attributes[name] or { return fallback }).i64()
}

fn cleanup_string_list(value brew_runtime.Value, name string) []string {
	raw := value.attributes[name] or { return [] }
	if raw == '' {
		return []
	}
	return raw.split('\x1f')
}

fn cleanup_path_from_value(value brew_runtime.Value) CleanupPath {
	path := value.as_string()
	exists := cleanup_bool_attr(value, 'exists', os.exists(path))
	symlink := cleanup_bool_attr(value, 'symlink', os.is_link(path))
	directory := cleanup_bool_attr(value, 'directory', os.is_dir(path))
	file := cleanup_bool_attr(value, 'file', os.is_file(path))
	mtime := cleanup_int_attr(value, 'mtime', if os.exists(path) {
		os.file_last_mod_unix(path)
	} else {
		0
	})
	ctime := cleanup_int_attr(value, 'ctime', mtime)
	return CleanupPath{
		path: path
		exists: exists
		directory: directory
		file: file
		symlink: symlink
		resolved_file: cleanup_bool_attr(value, 'resolved_file', file)
		mtime: mtime
		ctime: ctime
		disk_usage: cleanup_int_attr(value, 'disk_usage', if os.is_file(path) {
			i64(os.file_size(path))} else {
			0})
		locked: cleanup_bool_attr(value, 'locked', false)
	}
}

fn cleanup_path_value(path CleanupPath) brew_runtime.Value {
	return brew_runtime.structured_value('Pathname', path.path, {
		'exists':        path.exists.str()
		'directory':     path.directory.str()
		'file':          path.file.str()
		'symlink':       path.symlink.str()
		'resolved_file': path.resolved_file.str()
		'mtime':         path.mtime.str()
		'ctime':         path.ctime.str()
		'disk_usage':    path.disk_usage.str()
		'locked':        path.locked.str()
	})
}

fn cleanup_entry_from_value(value brew_runtime.Value) CleanupEntry {
	path_value := value.map_data['path'] or { value }
	type_value := value.map_data['type'] or { cleanup_nil() }
	return CleanupEntry{
		path: cleanup_path_from_value(path_value)
		type_name: if type_value.type_name == 'NilClass' {
			''} else {
			type_value.as_string().trim_left(':')}
	}
}

fn cleanup_entry_value(entry CleanupEntry) brew_runtime.Value {
	return brew_runtime.map_value({
		'path': cleanup_path_value(entry.path)
		'type': if entry.type_name == '' {
			cleanup_nil()
		} else {
			brew_runtime.object_value('Symbol', ':${entry.type_name}')
		}
	})
}

fn cleanup_formula_from_value(value brew_runtime.Value) CleanupFormula {
	mut resources := map[string]string{}
	if resource_values := value.map_data['resource_versions'] {
		for key, item in resource_values.map_data {
			resources[key] = item.as_string()
		}
	}
	return CleanupFormula{
		name: value.attributes['name'] or { value.as_string() }
		aliases: cleanup_string_list(value, 'aliases')
		latest_version_installed: cleanup_bool_attr(value, 'latest_version_installed', false)
		pkg_version: value.attributes['pkg_version'] or { '' }
		installed_versions: cleanup_string_list(value, 'installed_versions')
		eligible_versions: cleanup_string_list(value, 'eligible_versions')
		resource_versions: resources
		patch_versions: cleanup_string_list(value, 'patch_versions')
		bottle_version: value.attributes['bottle_version'] or { '' }
		bottle_rebuild: int(cleanup_int_attr(value, 'bottle_rebuild', 0))
		bottle_outdated: cleanup_bool_attr(value, 'bottle_outdated', false)
		untrusted: cleanup_bool_attr(value, 'untrusted', false)
	}
}

fn cleanup_formula_value(formula CleanupFormula) brew_runtime.Value {
	mut resources := map[string]brew_runtime.Value{}
	for key, version in formula.resource_versions {
		resources[key] = brew_runtime.string_value(version)
	}
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: formula.name
		map_data: {
			'resource_versions': brew_runtime.map_value(resources)
		}
		attributes: {
			'name':                     formula.name
			'aliases':                  formula.aliases.join('\x1f')
			'latest_version_installed': formula.latest_version_installed.str()
			'pkg_version':              formula.pkg_version
			'installed_versions':       formula.installed_versions.join('\x1f')
			'eligible_versions':        formula.eligible_versions.join('\x1f')
			'patch_versions':           formula.patch_versions.join('\x1f')
			'bottle_version':           formula.bottle_version
			'bottle_rebuild':           formula.bottle_rebuild.str()
			'bottle_outdated':          formula.bottle_outdated.str()
			'untrusted':                formula.untrusted.str()
		}
	}
}

fn cleanup_cask_from_value(value brew_runtime.Value) CleanupCask {
	return CleanupCask{
		token: value.attributes['token'] or { value.as_string() }
		version: value.attributes['version'] or { '' }
		installed_version: value.attributes['installed_version'] or { '' }
		latest: cleanup_bool_attr(value, 'latest', false)
		url: value.attributes['url'] or { '' }
		caskroom_path: value.attributes['caskroom_path'] or { '' }
	}
}

fn cleanup_cask_value(cask CleanupCask) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Cask', cask.token, {
		'token':             cask.token
		'version':           cask.version
		'installed_version': cask.installed_version
		'latest':            cask.latest.str()
		'url':               cask.url
		'caskroom_path':     cask.caskroom_path
	})
}

fn cleanup_new(arguments []string, dry_run bool, scrub bool, days ?int, cache string) &Cleanup {
	return &Cleanup{
		args: arguments.clone()
		days: days or { cleanup_default_days }
		cache: cache
		disk_cleanup_size: 0
		dry_run: dry_run
		prune: days != none
		scrub: scrub
		cleaned_up_paths: map[string]bool{}
		formula_cache_paths: map[string][]string{}
		unremovable_kegs: []brew_runtime.Value{}
		output: []string{}
	}
}

fn cleanup_value(cleanup &Cleanup) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Homebrew::Cleanup'
		repr: 'Homebrew::Cleanup'
		array_data: cleanup.unremovable_kegs.clone()
		map_data: {
			'output': brew_runtime.string_array_value(cleanup.output)
		}
		attributes: {
			'cleanup_address':   u64(voidptr(cleanup)).str()
			'dry_run':           cleanup.dry_run.str()
			'scrub':             cleanup.scrub.str()
			'prune':             cleanup.prune.str()
			'days':              cleanup.days.str()
			'cache':             cleanup.cache
			'disk_cleanup_size': cleanup.disk_cleanup_size.str()
			'args':              cleanup.args.join('\x1f')
		}
	}
}

fn cleanup_from_value(value brew_runtime.Value) &Cleanup {
	address := value.attributes['cleanup_address'] or { panic('invalid Cleanup receiver') }
	return unsafe { &Cleanup(voidptr(address.u64())) }
}

fn cleanup_output_value(cleanup &Cleanup) brew_runtime.Value {
	return brew_runtime.string_value(if cleanup.output.len == 0 {
		''
	} else {
		cleanup.output.join('\n') + '\n'
	})
}

fn cleanup_remove(path string) {
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path) or { panic(err) }
	} else if os.exists(path) || os.is_link(path) {
		os.rm(path) or { panic(err) }
	}
}

fn cleanup_each_path(root string) []string {
	if !os.is_dir(root) {
		return []
	}
	mut result := []string{}
	for name in os.ls(root) or { [] } {
		path := os.join_path(root, name)
		result << path
		if os.is_dir(path) && !os.is_link(path) {
			result << cleanup_each_path(path)
		}
	}
	return result
}

pub fn cleanup_incomplete(path CleanupPath) bool {
	return os.file_ext(path.path).ends_with('.incomplete')
}

pub fn cleanup_nested_cache(path CleanupPath) bool {
	return path.directory && os.base(path.path) in [
		'cargo_cache',
		'go_cache',
		'go_mod_cache',
		'glide_home',
		'java_cache',
		'npm_cache',
		'pip_cache',
		'gclient_cache',
	]
}

pub fn cleanup_go_cache_directory(path CleanupPath) bool {
	return path.directory && os.base(path.path) in ['go_cache', 'go_mod_cache']
}

pub fn cleanup_prune(path CleanupPath, days ?int, now i64) bool {
	prune_days := days or { return false }
	if prune_days == 0 {
		return true
	}
	if path.symlink && !path.exists {
		return true
	}
	threshold := now - i64(prune_days) * 24 * 60 * 60
	return path.mtime < threshold && path.ctime < threshold
}

pub fn cleanup_cask_cache_file_current(path CleanupPath, cask CleanupCask, name string) bool {
	basename := os.base(path.path)
	prefix := '${name}--${cask.version}'
	return basename == prefix || basename.starts_with('${prefix}.')
}

pub fn cleanup_stale_cask_download(path CleanupPath, cask CleanupCask, name string,
	scrub bool, now i64) bool {
	if !path.exists || !cleanup_cask_cache_file_current(path, cask, name) {
		return true
	}
	if scrub && cask.installed_version != cask.version {
		return true
	}
	if cask.latest {
		return cleanup_prune(path, cleanup_default_days, now)
	}
	return false
}

pub fn cleanup_stale_api_source(path CleanupPath, scrub bool, package_found bool,
	package_git_head string) bool {
	if scrub {
		return true
	}
	parts := path.path.split('/').filter(it != '')
	mut source_index := -1
	for index in 0 .. parts.len {
		if parts[index] == 'api-source' {
			source_index = index
		}
	}
	if source_index < 0 || parts.len - source_index - 1 < 4 || !os.base(path.path).ends_with('.rb') {
		return false
	}
	relative := parts[source_index + 1..]
	type_name := relative[3]
	if type_name !in ['Cask', 'Formula'] {
		return false
	}
	if !package_found {
		return true
	}
	return package_git_head != relative[2]
}

pub fn cleanup_excluded_versions(formula CleanupFormula) []string {
	mut result := []string{}
	for version in formula.installed_versions {
		if version !in formula.eligible_versions {
			result << version
		}
	}
	return result
}

fn cleanup_cache_components(path CleanupPath) (string, string, string) {
	basename := os.base(path.path)
	extension := os.file_ext(basename)
	mut stem := if extension == '' { basename } else { basename[..basename.len - extension.len] }
	if path.path.contains('#resolved-version=') {
		resolved := path.path.all_after_last('#resolved-version=')
		stem = stem.all_before('#resolved-version=')
		parts := stem.split('--')
		return parts[0], if parts.len > 2 { parts[1] } else { '' }, resolved
	}
	parts := stem.split('--')
	if parts.len >= 2 {
		return parts[0], if parts.len > 2 { parts[1] } else { '' }, parts.last()
	}
	mut separator := stem.last_index('-') or { return '', '', '' }
	if separator > 0 && stem[separator - 1] == `-` {
		separator--
	}
	return stem[..separator], '', stem[separator + 1..]
}

fn cleanup_version_base(version string) string {
	if dash := version.last_index('-') {
		suffix := version[dash + 1..]
		if suffix != '' && suffix.bytes().all(it.is_digit()) {
			return version[..dash]
		}
	}
	return version
}

fn cleanup_version_greater(left string, right string) bool {
	left_parts := left.split_any('.-_').map(it.int())
	right_parts := right.split_any('.-_').map(it.int())
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value != right_value {
			return left_value > right_value
		}
	}
	return false
}

pub fn cleanup_stale_formula(path CleanupPath, scrub bool, cellar_exists bool,
	formula ?CleanupFormula) bool {
	if !cellar_exists {
		return false
	}
	formula_name, resource_name, version := cleanup_cache_components(path)
	if formula_name == '' || version == '' {
		return false
	}
	loaded_formula := formula or { return false }
	if loaded_formula.untrusted {
		return false
	}
	mut actual_name := formula_name
	if formula_name.ends_with('_bottle_manifest') {
		actual_name = formula_name.trim_string_right('_bottle_manifest')
		if actual_name != loaded_formula.name {
			return false
		}
		excluded := cleanup_excluded_versions(loaded_formula)
		if version in excluded || cleanup_version_base(version) in excluded {
			return false
		}
		if !loaded_formula.latest_version_installed {
			return false
		}
		if loaded_formula.bottle_version == '' {
			return false
		}
		expected := if loaded_formula.bottle_rebuild > 0 {
			'${loaded_formula.bottle_version}-${loaded_formula.bottle_rebuild}'
		} else {
			loaded_formula.bottle_version
		}
		return version != expected
	}
	if actual_name != loaded_formula.name {
		return false
	}
	if resource_name == 'patch' {
		return version !in loaded_formula.patch_versions
	}
	if resource_name != '' && resource_name in loaded_formula.resource_versions {
		return loaded_formula.resource_versions[resource_name] != version
	}
	if version in cleanup_excluded_versions(loaded_formula) {
		return false
	}
	if (loaded_formula.latest_version_installed && loaded_formula.pkg_version != version) || cleanup_version_greater(loaded_formula.pkg_version, version) {
		return true
	}
	if scrub && !loaded_formula.latest_version_installed {
		return true
	}
	return loaded_formula.bottle_outdated
}

pub fn cleanup_stale_cask(path CleanupPath, scrub bool, cask ?CleanupCask, now i64) bool {
	basename := os.base(path.path)
	separator := basename.index('--') or { return false }
	name := basename[..separator]
	loaded_cask := cask or { return false }
	return cleanup_stale_cask_download(path, loaded_cask, name, scrub, now)
}

pub fn cleanup_stale(entry CleanupEntry, scrub bool, now i64, package_found bool,
	package_git_head string, formula ?CleanupFormula, cask ?CleanupCask, cellar_exists bool) bool {
	if !entry.path.resolved_file {
		return false
	}
	return match entry.type_name {
		'api_package' { scrub }
		'api_source' {
			cleanup_stale_api_source(entry.path, scrub, package_found, package_git_head)
		}
		'cask' { cleanup_stale_cask(entry.path, scrub, cask, now) }
		'gh_actions_artifact' { scrub || cleanup_prune(entry.path, cleanup_gh_actions_days, now) }
		else { cleanup_stale_formula(entry.path, scrub, cellar_exists, formula) }
	}
}

pub fn cleanup_formula_paths(mut cleanup Cleanup, formula CleanupFormula) []string {
	if !os.is_dir(cleanup.cache) {
		return []
	}
	if !cleanup.formula_cache_indexed {
		for basename in os.ls(cleanup.cache) or { [] } {
			prefix, separator := basename.split_once('--') or { continue }
			if prefix.starts_with('.') || separator == '' {
				continue
			}
			cleanup.formula_cache_paths[prefix] << os.join_path(cleanup.cache, basename)
		}
		cleanup.formula_cache_indexed = true
	}
	mut paths := (cleanup.formula_cache_paths[formula.name] or { [] }).clone()
	paths << (cleanup.formula_cache_paths['${formula.name}_bottle_manifest'] or { [] })
	paths.sort()
	return paths
}

pub fn cleanup_path_action(mut cleanup Cleanup, path CleanupPath, recursive bool) bool {
	if !path.exists && !path.symlink {
		return false
	}
	if path.path in cleanup.cleaned_up_paths {
		return false
	}
	cleanup.cleaned_up_paths[path.path] = true
	cleanup.disk_cleanup_size += path.disk_usage
	if cleanup.dry_run {
		cleanup.output << 'Would remove: ${path.path} (${path.disk_usage}B)'
	} else {
		cleanup.output << 'Removing: ${path.path}... (${path.disk_usage}B)'
		if recursive {
			cleanup_remove(path.path)
		} else if os.exists(path.path) || os.is_link(path.path) {
			os.rm(path.path) or { panic(err) }
		}
	}
	return true
}

fn cleanup_entries_value(entries []CleanupEntry) brew_runtime.Value {
	return brew_runtime.array_value(entries.map(cleanup_entry_value(it)))
}

fn cleanup_values(value brew_runtime.Value) []brew_runtime.Value {
	return value.as_array() or { [] }
}

fn cleanup_clone_value(value brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: value.type_name
		repr: value.repr.clone()
		bool_data: value.bool_data
		int_data: value.int_data
		float_data: value.float_data
		string_array_data: value.string_array_data.clone()
		array_data: value.array_data.clone()
		map_data: value.map_data.clone()
		attributes: value.attributes.clone()
	}
}

fn cleanup_disable_message(no_env_hints bool, no_install_cleanup bool) string {
	if no_env_hints || no_install_cleanup {
		return ''
	}
	return 'Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.\nHide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).'
}

// Translated from Homebrew/brew `cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `incomplete?(pathname)` at line 24.
pub fn ruby_cleanup_l24_d1_incomplete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_incomplete(cleanup_path_from_value(args[0])))
}

// Ruby method `nested_cache?(pathname)` at line 29.
pub fn ruby_cleanup_l29_d2_nested_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_nested_cache(cleanup_path_from_value(args[0])))
}

// Ruby method `go_cache_directory?(pathname)` at line 43.
pub fn ruby_cleanup_l43_d3_go_cache_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_go_cache_directory(cleanup_path_from_value(args[0])))
}

// Ruby method `prune?(pathname, days)` at line 50.
pub fn ruby_cleanup_l50_d4_prune(args ...brew_runtime.Value) brew_runtime.Value {
	days := if args.len < 2 || args[1].type_name == 'NilClass' {
		?int(none)
	} else {
		?int(int(args[1].as_int() or { 0 }))
	}
	now := if args.len > 2 { args[2].as_int() or { time.now().unix() } } else { time.now().unix() }
	return brew_runtime.bool_value(cleanup_prune(cleanup_path_from_value(args[0]), days, now))
}

// Ruby method `stale?(entry, scrub: false)` at line 60.
pub fn ruby_cleanup_l60_d5_stale(args ...brew_runtime.Value) brew_runtime.Value {
	entry := cleanup_entry_from_value(args[0])
	scrub := args.len > 1 && args[1].bool_data
	formula_value := args[0].map_data['formula'] or { cleanup_nil() }
	cask_value := args[0].map_data['cask'] or { cleanup_nil() }
	formula := if formula_value.type_name == 'NilClass' {
		?CleanupFormula(none)
	} else {
		?CleanupFormula(cleanup_formula_from_value(formula_value))
	}
	cask := if cask_value.type_name == 'NilClass' {
		?CleanupCask(none)
	} else {
		?CleanupCask(cleanup_cask_from_value(cask_value))
	}
	return brew_runtime.bool_value(cleanup_stale(entry, scrub, cleanup_int_attr(args[0], 'now', time.now().unix()), cleanup_bool_attr(args[0], 'package_found', false), args[0].attributes['package_git_head'] or { '' }, formula, cask, cleanup_bool_attr(args[0], 'cellar_exists', true)))
}

// Ruby method `cask_cache_file_current?(pathname, cask, name)` at line 79.
pub fn ruby_cleanup_l79_d6_cask_cache_file_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_cask_cache_file_current(cleanup_path_from_value(args[0]), cleanup_cask_from_value(args[1]), args[2].as_string()))
}

// Ruby method `stale_cask_download?(pathname, cask, name, scrub:)` at line 84.
pub fn ruby_cleanup_l84_d7_stale_cask_download(args ...brew_runtime.Value) brew_runtime.Value {
	scrub := args.len > 3 && args[3].bool_data
	now := if args.len > 4 { args[4].as_int() or { time.now().unix() } } else { time.now().unix() }
	return brew_runtime.bool_value(cleanup_stale_cask_download(cleanup_path_from_value(args[0]), cleanup_cask_from_value(args[1]), args[2].as_string(), scrub, now))
}

// Ruby method `stale_api_source?(pathname, scrub)` at line 100.
pub fn ruby_cleanup_l100_d8_stale_api_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_stale_api_source(cleanup_path_from_value(args[0]), args[1].bool_data, args.len > 2 && cleanup_bool_attr(args[2], 'found', true), if args.len > 2 {
		args[2].attributes['tap_git_head'] or { '' }
	} else {
		''
	}))
}

// Ruby method `excluded_versions_from_cleanup(formula)` at line 139.
pub fn ruby_cleanup_l139_d9_excluded_versions_from_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(cleanup_excluded_versions(cleanup_formula_from_value(args[0])))
}

// Ruby method `stale_formula?(pathname, scrub)` at line 148.
pub fn ruby_cleanup_l148_d10_stale_formula(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 2 && args[2].type_name != 'NilClass' {
		?CleanupFormula(cleanup_formula_from_value(args[2]))
	} else {
		?CleanupFormula(none)
	}
	cellar_exists := if args.len > 3 { args[3].bool_data } else { true }
	return brew_runtime.bool_value(cleanup_stale_formula(cleanup_path_from_value(args[0]), args[1].bool_data, cellar_exists, formula))
}

// Ruby method `stale_cask?(pathname, scrub)` at line 238.
pub fn ruby_cleanup_l238_d11_stale_cask(args ...brew_runtime.Value) brew_runtime.Value {
	cask := if args.len > 2 && args[2].type_name != 'NilClass' {
		?CleanupCask(cleanup_cask_from_value(args[2]))
	} else {
		?CleanupCask(none)
	}
	now := if args.len > 3 { args[3].as_int() or { time.now().unix() } } else { time.now().unix() }
	return brew_runtime.bool_value(cleanup_stale_cask(cleanup_path_from_value(args[0]), args[1].bool_data, cask, now))
}

// Ruby attr_reader `attr_reader :args` at line 257.
pub fn ruby_cleanup_l257_d12_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(cleanup_from_value(args[0]).args)
}

// Ruby attr_reader `attr_reader :days` at line 260.
pub fn ruby_cleanup_l260_d13_days(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(cleanup_from_value(args[0]).days)
}

// Ruby attr_reader `attr_reader :cache` at line 263.
pub fn ruby_cleanup_l263_d14_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', cleanup_from_value(args[0]).cache)
}

// Ruby attr_reader `attr_reader :disk_cleanup_size` at line 266.
pub fn ruby_cleanup_l266_d15_disk_cleanup_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(cleanup_from_value(args[0]).disk_cleanup_size)
}

// Ruby method `initialize(*args, dry_run: false, scrub: false, days: nil, cache: HOMEBREW_CACHE)` at line 271.
pub fn ruby_cleanup_l271_d16_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut arguments := []string{}
	mut options := brew_runtime.map_value({})
	if args.len > 0 && args[0].type_name == 'Array' {
		arguments = (args[0].as_array() or { [] }).map(it.as_string())
		if args.len > 1 {
			options = args[1]
		}
	} else {
		for value in args {
			if value.type_name == 'Hash' {
				options = value
			} else {
				arguments << value.as_string()
			}
		}
	}
	dry_run := (options.map_data['dry_run'] or { brew_runtime.bool_value(false) }).bool_data
	scrub := (options.map_data['scrub'] or { brew_runtime.bool_value(false) }).bool_data
	days_value := options.map_data['days'] or { cleanup_nil() }
	days := if days_value.type_name == 'NilClass' {
		?int(none)
	} else {
		?int(int(days_value.as_int() or { cleanup_default_days }))
	}
	cache := (options.map_data['cache'] or {
		brew_runtime.string_value(brew_runtime.environment_value('HOMEBREW_CACHE'))
	}).as_string()
	return cleanup_value(cleanup_new(arguments, dry_run, scrub, days, cache))
}

// Ruby method `dry_run? = @dry_run` at line 284.
pub fn ruby_cleanup_l284_d17_dry_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_from_value(args[0]).dry_run)
}

// Ruby method `prune? = @prune` at line 287.
pub fn ruby_cleanup_l287_d18_prune(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_from_value(args[0]).prune)
}

// Ruby method `scrub? = @scrub` at line 290.
pub fn ruby_cleanup_l290_d19_scrub(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cleanup_from_value(args[0]).scrub)
}

// Ruby method `self.printed_dry_run_output?(output, ohai: false)` at line 293.
pub fn ruby_cleanup_l293_d20_self_printed_dry_run_output(args ...brew_runtime.Value) brew_runtime.Value {
	output := args[0].as_string()
	if output.trim_space() == '' {
		return brew_runtime.bool_value(false)
	}
	heading := if args.len > 1 && args[1].bool_data {
		'==> Would `brew cleanup`'
	} else {
		'Would `brew cleanup`:'
	}
	text := '${heading}\n${output}${if output.ends_with('\n') { '' } else { '\n' }}'
	return brew_runtime.Value{
		type_name: 'Bool'
		repr: text
		bool_data: true
	}
}

// Ruby method `self.dry_run_output(*args, formulae: [])` at line 307.
pub fn ruby_cleanup_l307_d21_self_dry_run_output(args ...brew_runtime.Value) brew_runtime.Value {
	mut arguments := []string{}
	mut context := brew_runtime.map_value({})
	for value in args {
		if value.type_name == 'Hash' {
			context = value
		} else if value.type_name == 'Array' {
			context = brew_runtime.map_value({
				'formulae': value
			})
		} else {
			arguments << value.as_string()
		}
	}
	mut cleanup := cleanup_new(arguments, true, false, none, (context.map_data['cache'] or {
		brew_runtime.string_value(brew_runtime.environment_value('HOMEBREW_CACHE'))
	}).as_string())
	formulae := cleanup_values(context.map_data['formulae'] or { brew_runtime.array_value([]) })
	if formulae.len == 0 {
		for entry_value in cleanup_values(context.map_data['entries'] or { brew_runtime.array_value([]) }) {
			entry := cleanup_entry_from_value(entry_value)
			cleanup_path_action(mut cleanup, entry.path, entry.path.directory)
		}
	} else {
		for formula_value in formulae {
			for path in cleanup_formula_paths(mut cleanup, cleanup_formula_from_value(formula_value)) {
				cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
			}
		}
	}
	return cleanup_output_value(cleanup)
}

// Ruby method `self.install_cleanup_formulae(formulae)` at line 325.
pub fn ruby_cleanup_l325_d22_self_install_cleanup_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 1 && args[1].bool_data {
		return brew_runtime.array_value([])
	}
	no_cleanup := if args.len > 2 { args[2].as_string().split(',') } else { [] }
	mut result := []brew_runtime.Value{}
	for value in cleanup_values(args[0]) {
		formula := cleanup_formula_from_value(value)
		if formula.latest_version_installed && formula.name !in no_cleanup && !formula.aliases.any(it in no_cleanup) {
			result << value
		}
	}
	return brew_runtime.array_value(result)
}

// Ruby method `self.install_formula_clean!(formula)` at line 334.
pub fn ruby_cleanup_l334_d23_self_install_formula_clean(args ...brew_runtime.Value) brew_runtime.Value {
	selected := ruby_cleanup_l325_d22_self_install_cleanup_formulae(brew_runtime.array_value([
		args[0],
	]), if args.len > 1 { args[1] } else { brew_runtime.bool_value(false) }, if args.len > 2 {
		args[2]
	} else {
		brew_runtime.string_value('')
	})
	if cleanup_values(selected).len == 0 {
		return cleanup_nil()
	}
	formula := cleanup_formula_from_value(args[0])
	return brew_runtime.string_value('Running `brew cleanup ${formula.name}`...')
}

// Ruby method `self.puts_no_install_cleanup_disable_message` at line 343.
pub fn ruby_cleanup_l343_d24_self_puts_no_install_cleanup_disable_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(cleanup_disable_message(args.len > 0 && args[0].bool_data, args.len > 1 && args[1].bool_data))
}

// Ruby method `self.puts_no_install_cleanup_disable_message_if_not_already!` at line 352.
pub fn ruby_cleanup_l352_d25_self_puts_no_install_cleanup_disable_message_if_not_already(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 2 && args[2].bool_data {
		return cleanup_nil()
	}
	return brew_runtime.string_value(cleanup_disable_message(args.len > 0 && args[0].bool_data, args.len > 1 && args[1].bool_data))
}

// Ruby method `self.skip_clean_formula?(formula)` at line 360.
pub fn ruby_cleanup_l360_d26_self_skip_clean_formula(args ...brew_runtime.Value) brew_runtime.Value {
	formula := cleanup_formula_from_value(args[0])
	configured := if args.len > 1 { args[1].as_string() } else { '' }
	if configured.trim_space() == '' {
		return brew_runtime.bool_value(false)
	}
	excluded := configured.split(',')
	return brew_runtime.bool_value(formula.name in excluded || formula.aliases.any(it in excluded))
}

// Ruby method `self.periodic_clean_due?` at line 369.
pub fn ruby_cleanup_l369_d27_self_periodic_clean_due(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 && args[0].bool_data {
		return brew_runtime.bool_value(false)
	}
	path := if args.len > 1 {
		cleanup_path_from_value(args[1])
	} else {
		cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(brew_runtime.environment_value('HOMEBREW_CACHE'), '.cleaned')))
	}
	if !path.exists {
		if path.path != '' {
			os.mkdir_all(os.dir(path.path)) or { panic(err) }
			os.write_file(path.path, '') or { panic(err) }
		}
		return brew_runtime.bool_value(false)
	}
	now := if args.len > 2 { args[2].as_int() or { time.now().unix() } } else { time.now().unix() }
	return brew_runtime.bool_value(path.mtime < now - cleanup_default_days * 24 * 60 * 60)
}

// Ruby method `self.periodic_clean!(dry_run: false)` at line 382.
pub fn ruby_cleanup_l382_d28_self_periodic_clean(args ...brew_runtime.Value) brew_runtime.Value {
	dry_run := args.len > 0 && args[0].bool_data
	no_install := args.len > 1 && args[1].bool_data
	cleaned_file := if args.len > 2 { args[2] } else { brew_runtime.object_value('Pathname', '') }
	now := if args.len > 3 { args[3] } else { brew_runtime.int_value(time.now().unix()) }
	due := ruby_cleanup_l369_d27_self_periodic_clean_due(brew_runtime.bool_value(no_install), cleaned_file, now).bool_data
	if no_install || !due {
		return cleanup_nil()
	}
	return brew_runtime.string_value(if dry_run {
		'Would run `brew cleanup` which has not been run in the last ${cleanup_default_days} days'
	} else {
		'`brew cleanup` has not been run in the last ${cleanup_default_days} days, running now...'
	})
}

// Ruby method `clean!(quiet: false, periodic: false)` at line 399.
pub fn ruby_cleanup_l399_d29_clean(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	context := if args.len > 1 { args[1] } else { brew_runtime.map_value({}) }
	if cleanup.args.len == 0 {
		for formula_value in cleanup_values(context.map_data['formulae'] or { brew_runtime.array_value([]) }) {
			if ruby_cleanup_l360_d26_self_skip_clean_formula(formula_value, context.map_data['no_cleanup_formulae'] or { brew_runtime.string_value('') }).bool_data {
				continue
			}
			for path in cleanup_formula_paths(mut cleanup, cleanup_formula_from_value(formula_value)) {
				cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
			}
		}
		for entry_value in cleanup_values(context.map_data['entries'] or { brew_runtime.array_value([]) }) {
			entry := cleanup_entry_from_value(entry_value)
			if cleanup_incomplete(entry.path) || cleanup_nested_cache(entry.path) || cleanup_prune(entry.path, if cleanup.prune {
				?int(cleanup.days)} else {
				?int(none)}, time.now().unix()) {
				cleanup_path_action(mut cleanup, entry.path, entry.path.directory)
			}
		}
	} else {
		formulae := context.map_data['formulae'] or { brew_runtime.map_value({}) }
		casks := context.map_data['casks'] or { brew_runtime.map_value({}) }
		for name in cleanup.args {
			if formula_value := formulae.map_data[name] {
				for path in cleanup_formula_paths(mut cleanup, cleanup_formula_from_value(formula_value)) {
					cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
				}
			}
			if cask_value := casks.map_data[name] {
				cask := cleanup_cask_from_value(cask_value)
				for path in os.glob(os.join_path(cleanup.cache, 'Cask', '${cask.token}--*')) or { [] } {
					cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
				}
			}
		}
	}
	return cleanup_nil()
}

// Ruby method `unremovable_kegs` at line 466.
pub fn ruby_cleanup_l466_d30_unremovable_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(cleanup_from_value(args[0]).unremovable_kegs)
}

// Ruby method `cache_entries(paths, type:)` at line 474.
pub fn ruby_cleanup_l474_d31_cache_entries(args ...brew_runtime.Value) brew_runtime.Value {
	type_name := if args.len < 3 || args[2].type_name == 'NilClass' {
		''
	} else {
		args[2].as_string().trim_left(':')
	}
	entries := cleanup_values(args[1]).map(CleanupEntry{
		path: cleanup_path_from_value(it)
		type_name: type_name
	})
	return cleanup_entries_value(entries)
}

// Ruby method `cleanup_cache_entries(paths, type:, cleanup_unreferenced: true)` at line 481.
pub fn ruby_cleanup_l481_d32_cleanup_cache_entries(args ...brew_runtime.Value) brew_runtime.Value {
	entries := ruby_cleanup_l474_d31_cache_entries(args[0], args[1], if args.len > 2 {
		args[2]
	} else {
		cleanup_nil()
	})
	return ruby_cleanup_l666_d44_cleanup_cache(args[0], entries, if args.len > 3 {
		args[3]
	} else {
		brew_runtime.bool_value(true)
	})
}

// Ruby method `formula_cache_paths(formula)` at line 490.
pub fn ruby_cleanup_l490_d33_formula_cache_paths(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	return brew_runtime.array_value(cleanup_formula_paths(mut cleanup, cleanup_formula_from_value(args[1])).map(brew_runtime.object_value('Pathname', it)))
}

// Ruby method `cleanup_formula(formula, quiet: false, ds_store: true, cache_db: true, cleanup_unreferenced: true)` at line 507.
pub fn ruby_cleanup_l507_d34_cleanup_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	formula_value := args[1]
	for keg in cleanup_values(formula_value.map_data['eligible_kegs'] or { brew_runtime.array_value([]) }) {
		if cleanup_bool_attr(keg, 'uninstall_error', false) {
			cleanup.unremovable_kegs << cleanup_clone_value(keg)
		} else {
			cleanup_path_action(mut cleanup, cleanup_path_from_value(keg), true)
		}
	}
	for path in cleanup_formula_paths(mut cleanup, cleanup_formula_from_value(formula_value)) {
		cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
	}
	ds_store := if args.len > 3 { args[3].bool_data } else { true }
	if ds_store {
		rack := formula_value.attributes['rack'] or { '' }
		if rack != '' {
			for path in cleanup_each_path(rack).filter(os.base(it) == '.DS_Store') {
				cleanup_remove(path)
			}
		}
	}
	if lock_path := formula_value.attributes['lock_path'] {
		if os.exists(lock_path) {
			os.rm(lock_path) or { panic(err) }
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_cask(cask, ds_store: true)` at line 517.
pub fn ruby_cleanup_l517_d35_cleanup_cask(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	cask := cleanup_cask_from_value(args[1])
	for path in os.glob(os.join_path(cleanup.cache, 'Cask', '${cask.token}--*')) or { [] } {
		path_value := cleanup_path_from_value(brew_runtime.object_value('Pathname', path))
		if cleanup_stale_cask_download(path_value, cask, cask.token, cleanup.scrub, time.now().unix()) {
			cleanup_path_action(mut cleanup, path_value, false)
		}
	}
	ruby_cleanup_l530_d36_cleanup_legacy_cask_downloads(args[0], brew_runtime.array_value([
		args[1],
	]))
	ruby_cleanup_l636_d43_cleanup_unreferenced_downloads(args[0])
	if (if args.len > 2 { args[2].bool_data } else { true }) && cask.caskroom_path != '' {
		for path in cleanup_each_path(cask.caskroom_path).filter(os.base(it) == '.DS_Store') {
			cleanup_remove(path)
		}
	}
	if lock_path := args[1].attributes['lock_path'] {
		if os.exists(lock_path) {
			os.rm(lock_path) or { panic(err) }
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_legacy_cask_downloads(casks)` at line 530.
pub fn ruby_cleanup_l530_d36_cleanup_legacy_cask_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	cask_cache := os.join_path(cleanup.cache, 'Cask')
	if !os.is_dir(cask_cache) {
		return cleanup_nil()
	}
	paths := os.ls(cask_cache) or { [] }
	for cask_value in cleanup_values(args[1]) {
		cask := cleanup_cask_from_value(cask_value)
		if cask.url == '' {
			continue
		}
		legacy_name := os.base(cask.url.all_after('://'))
		if legacy_name == '' || legacy_name == cask.token {
			continue
		}
		for basename in paths {
			if !basename.starts_with('${legacy_name}--') {
				continue
			}
			path := os.join_path(cask_cache, basename)
			path_value := cleanup_path_from_value(brew_runtime.object_value('Pathname', path))
			current_legacy := cleanup_cask_cache_file_current(path_value, cask, legacy_name)
			token_path := os.join_path(cask_cache, '${cask.token}--${cask.version}${os.file_ext(path)}')
			if cleanup_stale_cask_download(path_value, cask, legacy_name, cleanup.scrub, time.now().unix()) || (current_legacy && os.exists(token_path)) {
				cleanup_path_action(mut cleanup, path_value, false)
			}
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_keg(keg)` at line 554.
pub fn ruby_cleanup_l554_d37_cleanup_keg(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	if cleanup_bool_attr(args[1], 'uninstall_error', false) {
		cleanup.unremovable_kegs << cleanup_clone_value(args[1])
		return cleanup_nil()
	}
	cleanup_path_action(mut cleanup, cleanup_path_from_value(args[1]), true)
	return cleanup_nil()
}

// Ruby method `cleanup_logs` at line 562.
pub fn ruby_cleanup_l562_d38_cleanup_logs(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	logs := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_LOGS')
	}
	if !os.is_dir(logs) {
		return cleanup_nil()
	}
	logs_days := if cleanup.days < cleanup_default_days {
		cleanup.days
	} else {
		cleanup_default_days
	}
	now := if args.len > 2 { args[2].as_int() or { time.now().unix() } } else { time.now().unix() }
	for name in os.ls(logs) or { [] } {
		path := cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(logs, name)))
		if path.directory && cleanup_prune(path, logs_days, now) {
			cleanup_path_action(mut cleanup, path, true)
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_temp_cellar` at line 573.
pub fn ruby_cleanup_l573_d39_cleanup_temp_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	root := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_TEMP_CELLAR')
	}
	if os.is_dir(root) {
		for name in os.ls(root) or { [] } {
			cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(root, name))), true)
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_reinstall_kegs` at line 582.
pub fn ruby_cleanup_l582_d40_cleanup_reinstall_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	cellar := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_CELLAR')
	}
	if os.is_dir(cellar) {
		for path in os.glob(os.join_path(cellar, '*', '*.reinstall')) or { [] } {
			cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), true)
		}
	}
	return cleanup_nil()
}

// Ruby method `cache_files` at line 591.
pub fn ruby_cleanup_l591_d41_cache_files(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	mut entries := []CleanupEntry{}
	if os.is_dir(cleanup.cache) {
		for name in os.ls(cleanup.cache) or { [] } {
			entries << CleanupEntry{
				path: cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(cleanup.cache, name)))
			}
		}
	}
	cask_cache := os.join_path(cleanup.cache, 'Cask')
	if os.is_dir(cask_cache) {
		for name in os.ls(cask_cache) or { [] } {
			entries << CleanupEntry{
				path: cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(cask_cache, name)))
				type_name: 'cask'
			}
		}
	}
	api_source := os.join_path(cleanup.cache, 'api-source')
	for path in cleanup_each_path(api_source) {
		if os.is_file(path) || os.is_link(path) {
			entries << CleanupEntry{
				path: cleanup_path_from_value(brew_runtime.object_value('Pathname', path))
				type_name: 'api_source'
			}
		}
	}
	artifacts := os.join_path(cleanup.cache, 'gh-actions-artifact')
	if os.is_dir(artifacts) {
		for name in os.ls(artifacts) or { [] } {
			entries << CleanupEntry{
				path: cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(artifacts, name)))
				type_name: 'gh_actions_artifact'
			}
		}
	}
	return cleanup_entries_value(entries)
}

// Ruby method `cleanup_empty_api_source_directories(directory = cache/"api-source")` at line 623.
pub fn ruby_cleanup_l623_d42_cleanup_empty_api_source_directories(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	if cleanup.dry_run {
		return cleanup_nil()
	}
	directory := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path(cleanup.cache, 'api-source')
	}
	if !os.is_dir(directory) {
		return cleanup_nil()
	}
	mut directories := cleanup_each_path(directory).filter(os.is_dir(it))
	directories.sort_with_compare(fn (left &string, right &string) int {
		return right.len - left.len
	})
	for child in directories {
		if os.is_dir(child) && (os.ls(child) or { [] }).len == 0 {
			os.rmdir(child) or { panic(err) }
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_unreferenced_downloads` at line 636.
pub fn ruby_cleanup_l636_d43_cleanup_unreferenced_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	if cleanup.dry_run {
		return cleanup_nil()
	}
	downloads_root := os.join_path(cleanup.cache, 'downloads')
	if !os.is_dir(downloads_root) {
		return cleanup_nil()
	}
	mut referenced := []string{}
	for entry_value in cleanup_values(ruby_cleanup_l591_d41_cache_files(args[0])) {
		entry := cleanup_entry_from_value(entry_value)
		if entry.path.symlink {
			referenced << os.real_path(entry.path.path)
		}
	}
	for name in os.ls(downloads_root) or { [] } {
		path := os.join_path(downloads_root, name)
		if os.real_path(path) in referenced {
			continue
		}
		cleanup_remove(path)
	}
	return cleanup_nil()
}

// Ruby method `cleanup_cache(entries = nil, cleanup_unreferenced: true)` at line 666.
pub fn ruby_cleanup_l666_d44_cleanup_cache(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	full_cleanup := args.len < 2 || args[1].type_name == 'NilClass'
	entries_value := if full_cleanup { ruby_cleanup_l591_d41_cache_files(args[0]) } else { args[1] }
	for value in cleanup_values(entries_value) {
		entry := cleanup_entry_from_value(value)
		if os.base(entry.path.path) == '.cleaned' {
			continue
		}
		if cleanup_incomplete(entry.path) {
			cleanup_path_action(mut cleanup, entry.path, entry.path.directory)
			continue
		}
		if cleanup_nested_cache(entry.path) {
			cleanup_path_action(mut cleanup, entry.path, true)
			continue
		}
		if cleanup_prune(entry.path, cleanup.days, time.now().unix()) {
			if entry.path.file || entry.path.symlink {
				cleanup_path_action(mut cleanup, entry.path, false)
			} else if entry.path.directory && entry.path.path.contains('--') {
				cleanup_path_action(mut cleanup, entry.path, true)
			}
			continue
		}
		if !cleanup.prune {
			formula_value := value.map_data['formula'] or { cleanup_nil() }
			cask_value := value.map_data['cask'] or { cleanup_nil() }
			formula := if formula_value.type_name == 'NilClass' {
				?CleanupFormula(none)
			} else {
				?CleanupFormula(cleanup_formula_from_value(formula_value))
			}
			cask := if cask_value.type_name == 'NilClass' {
				?CleanupCask(none)
			} else {
				?CleanupCask(cleanup_cask_from_value(cask_value))
			}
			if cleanup_stale(entry, cleanup.scrub, time.now().unix(), cleanup_bool_attr(value, 'package_found', false), value.attributes['package_git_head'] or {
				''}, formula, cask, cleanup_bool_attr(value, 'cellar_exists', true)) {
				cleanup_path_action(mut cleanup, entry.path, false)
			}
		}
	}
	cleanup_unreferenced := if args.len > 2 { args[2].bool_data } else { true }
	if cleanup_unreferenced {
		ruby_cleanup_l636_d43_cleanup_unreferenced_downloads(args[0])
	}
	return cleanup_nil()
}

// Ruby method `cleanup_path(path, &_block)` at line 696.
pub fn ruby_cleanup_l696_d45_cleanup_path(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	recursive := args.len > 2 && args[2].as_string() in ['rm_r', 'rm_rf', 'recursive']
	return brew_runtime.bool_value(cleanup_path_action(mut cleanup, cleanup_path_from_value(args[1]), recursive))
}

// Ruby method `cleanup_lockfiles(*lockfiles)` at line 711.
pub fn ruby_cleanup_l711_d46_cleanup_lockfiles(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	if cleanup.dry_run {
		return cleanup_nil()
	}
	mut lockfiles := if args.len > 1 { args[1..].clone() } else { []brew_runtime.Value{} }
	if lockfiles.len == 0 {
		locks := brew_runtime.environment_value('HOMEBREW_LOCKS')
		if os.is_dir(locks) {
			lockfiles = (os.ls(locks) or { [] }).map(brew_runtime.object_value('Pathname', os.join_path(locks, it)))
		}
	}
	for value in lockfiles {
		path := cleanup_path_from_value(value)
		if path.exists && path.file && !path.locked {
			os.rm(path.path) or { panic(err) }
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_portable_ruby` at line 732.
pub fn ruby_cleanup_l732_d47_cleanup_portable_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	vendor := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path('Library', 'Homebrew', 'vendor')
	}
	version_file := os.join_path(vendor, 'portable-ruby-version')
	if !os.is_file(version_file) {
		return cleanup_nil()
	}
	latest := os.read_file(version_file) or { '' }.trim_space()
	portable_root := os.join_path(vendor, 'portable-ruby')
	use_system := args.len > 2 && args[2].bool_data
	mut removals := []string{}
	if os.is_dir(portable_root) {
		for name in os.ls(portable_root) or { [] } {
			path := os.join_path(portable_root, name)
			if os.is_dir(path) && (use_system || name != latest) && name.contains('.') {
				removals << path
			}
		}
	}
	if removals.len == 0 {
		return cleanup_nil()
	}
	bundle_root := os.join_path(vendor, 'bundle', 'ruby')
	if os.is_dir(bundle_root) {
		version_parts := latest.split('.')
		version_part_count := if version_parts.len < 2 { version_parts.len } else { 2 }
		major_minor := version_parts[..version_part_count].join('.') + '.0'
		current := if args.len > 3 { args[3].as_string() } else { '' }
		for name in os.ls(bundle_root) or { [] } {
			if name == '.homebrew_gem_groups' {
				continue
			}
			path := os.join_path(bundle_root, name)
			if !os.is_dir(path) || (name != major_minor && name != current) {
				cleanup.output << 'git clean ${if cleanup.dry_run { '-nx' } else { '-ffqx' }} ${path}'
			}
		}
	}
	for path in removals {
		cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), true)
	}
	return cleanup_nil()
}

// Ruby method `use_system_ruby?` at line 771.
pub fn ruby_cleanup_l771_d48_use_system_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `cleanup_bootsnap` at line 776.
pub fn ruby_cleanup_l776_d49_cleanup_bootsnap(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	bootsnap := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path(cleanup.cache, 'bootsnap')
	}
	key := if args.len > 2 { args[2].as_string() } else { '' }
	if os.is_dir(bootsnap) {
		for name in os.ls(bootsnap) or { [] } {
			if name != key {
				cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', os.join_path(bootsnap, name))), true)
			}
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_cache_db(rack = nil)` at line 786.
pub fn ruby_cleanup_l786_d50_cleanup_cache_db(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	for name in ['desc_cache.json', 'linkage.db', 'linkage.db.db'] {
		cleanup_remove(os.join_path(cleanup.cache, name))
	}
	rack := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	mut retained := []string{}
	if args.len > 2 {
		for keg in args[2].as_string_array() or { [] } {
			if (rack != '' && !keg.starts_with('${rack}/')) || os.is_dir(keg) {
				retained << keg
			}
		}
	}
	return brew_runtime.string_array_value(retained)
}

// Ruby method `rm_ds_store(dirs = nil)` at line 810.
pub fn ruby_cleanup_l810_d51_rm_ds_store(args ...brew_runtime.Value) brew_runtime.Value {
	cleanup := cleanup_from_value(args[0])
	if cleanup.dry_run {
		return cleanup_nil()
	}
	dirs := if args.len > 1 && args[1].type_name != 'NilClass' {
		cleanup_values(args[1]).map(it.as_string())
	} else {
		[]string{}
	}
	for dir in dirs.filter(os.is_dir(it)) {
		for path in cleanup_each_path(dir).filter(os.base(it) == '.DS_Store') {
			os.rm(path) or {}
		}
	}
	return cleanup_nil()
}

// Ruby method `cleanup_python_site_packages` at line 825.
pub fn ruby_cleanup_l825_d52_cleanup_python_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	prefix := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_PREFIX')
	}
	now := if args.len > 2 { args[2].as_int() or { time.now().unix() } } else { time.now().unix() }
	for site_packages in os.glob(os.join_path(prefix, 'lib', 'python*', 'site-packages')) or { [] } {
		for child_name in os.ls(site_packages) or { [] } {
			child := os.join_path(site_packages, child_name)
			if !os.is_dir(child) || child_name.ends_with('-info') {
				continue
			}
			paths := cleanup_each_path(child).filter(os.is_file(it))
			if child_name == '__pycache__' {
				for path in paths.filter(os.file_ext(it) == '.pyc') {
					info := cleanup_path_from_value(brew_runtime.object_value('Pathname', path))
					if cleanup_prune(info, cleanup.days, now) {
						cleanup_path_action(mut cleanup, info, false)
					}
				}
				continue
			}
			if paths.len > 0 && paths.all(os.file_ext(it) == '.pyc') {
				for path in paths {
					cleanup_path_action(mut cleanup, cleanup_path_from_value(brew_runtime.object_value('Pathname', path)), false)
				}
			}
		}
	}
	return cleanup_nil()
}

// Ruby method `prune_prefix_symlinks_and_directories` at line 875.
pub fn ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleanup := cleanup_from_value(args[0])
	mut roots := if args.len > 1 {
		cleanup_values(args[1]).map(it.as_string())
	} else {
		[]string{}
	}
	mut broken_links := []string{}
	mut directories := []string{}
	for root in roots {
		if !os.is_dir(root) {
			continue
		}
		for path in cleanup_each_path(root) {
			if os.is_link(path) && !os.exists(path) {
				broken_links << path
			} else if os.is_dir(path) && path != root {
				directories << path
			}
		}
	}
	broken_links.sort_with_compare(fn (left &string, right &string) int {
		return right.count('/') - left.count('/')
	})
	mut removed := map[string]bool{}
	for path in broken_links {
		if cleanup.dry_run {
			cleanup.output << 'Would remove (broken link): ${path}'
		} else {
			os.rm(path) or { panic(err) }
		}
		removed[path] = true
	}
	directories.sort_with_compare(fn (left &string, right &string) int {
		return right.count('/') - left.count('/')
	})
	for directory in directories {
		children := os.ls(directory) or { [] }
		empty_after_prune := children.all(removed[os.join_path(directory, it)] or { false })
		if children.len == 0 || empty_after_prune {
			if cleanup.dry_run {
				cleanup.output << 'Would remove (empty directory): ${directory}'
			} else if os.is_dir(directory) {
				os.rmdir(directory) or { continue }
			}
			removed[directory] = true
		}
	}
	if args.len > 2 {
		caskroom := args[2].as_string()
		if os.is_dir(caskroom) {
			for name in os.ls(caskroom) or { [] } {
				path := os.join_path(caskroom, name)
				if !os.is_link(path) || os.exists(path) {
					continue
				}
				if cleanup.dry_run {
					cleanup.output << 'Would remove (broken link): ${path}'
				} else {
					os.rm(path) or { panic(err) }
				}
			}
		}
	}
	return cleanup_nil()
}

// Ruby method `self.autoremove(dry_run: false)` at line 938.
pub fn ruby_cleanup_l938_d54_self_autoremove(args ...brew_runtime.Value) brew_runtime.Value {
	dry_run := args.len > 0 && args[0].bool_data
	mut removable := if args.len > 3 {
		cleanup_values(args[3])
	} else if args.len > 1 {
		cleanup_values(args[1])
	} else {
		[]brew_runtime.Value{}
	}
	no_cleanup := if args.len > 5 { args[5].as_string() } else { '' }
	if no_cleanup != '' {
		removable = removable.filter(!ruby_cleanup_l360_d26_self_skip_clean_formula(it, brew_runtime.string_value(no_cleanup)).bool_data)
	}
	required := if args.len > 4 { args[4].as_string_array() or { [] } } else { [] }
	removable = removable.filter((it.attributes['name'] or { it.as_string() }) !in required)
	if removable.len == 0 {
		return brew_runtime.Value{
			type_name: 'CleanupAutoremoveResult'
			repr: ''
			array_data: []
			attributes: {
				'dry_run':       dry_run.str()
				'cache_cleared': (!dry_run).str()
			}
		}
	}
	mut names := removable.map(it.attributes['full_name'] or {
		it.attributes['name'] or {
			it.as_string()
		}
	})
	names.sort()
	verb := if dry_run { 'Would autoremove' } else { 'Autoremoving' }
	output := '${verb} ${names.len} unneeded formula${if names.len == 1 { '' } else { 'e' }}:\n${names.join('\n')}'
	if !dry_run {
		for formula in removable {
			keg := formula.attributes['any_installed_keg'] or { '' }
			if keg != '' {
				cleanup_remove(keg)
			}
		}
	}
	return brew_runtime.Value{
		type_name: 'CleanupAutoremoveResult'
		repr: output
		array_data: removable
		attributes: {
			'dry_run':       dry_run.str()
			'cache_cleared': (!dry_run).str()
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/bottles"
// 5: require "utils/output"
// 6: require "installed_dependents"
// 7: require "stringio"
// 8:
// 9: require "formula"
// 10: require "cask/cask_loader"
// 11:
// 12: module Homebrew
// 13:   # Helper class for cleaning up the Homebrew cache.
// 14:   class Cleanup
// 15:     extend Utils::Output::Mixin
// 16:     include Utils::Output::Mixin
// 17:
// 18:     CLEANUP_DEFAULT_DAYS = T.let(Homebrew::EnvConfig.cleanup_periodic_full_days.to_i.freeze, Integer)
// 19:     GH_ACTIONS_ARTIFACT_CLEANUP_DAYS = 3
// 20:     private_constant :CLEANUP_DEFAULT_DAYS, :GH_ACTIONS_ARTIFACT_CLEANUP_DAYS
// 21:
// 22:     class << self
// 23:       sig { params(pathname: Pathname).returns(T::Boolean) }
// 24:       def incomplete?(pathname)
// 25:         pathname.extname.end_with?(".incomplete")
// 26:       end
// 27:
// 28:       sig { params(pathname: Pathname).returns(T::Boolean) }
// 29:       def nested_cache?(pathname)
// 30:         pathname.directory? && %w[
// 31:           cargo_cache
// 32:           go_cache
// 33:           go_mod_cache
// 34:           glide_home
// 35:           java_cache
// 36:           npm_cache
// 37:           pip_cache
// 38:           gclient_cache
// 39:         ].include?(pathname.basename.to_s)
// 40:       end
// 41:
// 42:       sig { params(pathname: Pathname).returns(T::Boolean) }
// 43:       def go_cache_directory?(pathname)
// 44:         # Go makes its cache contents read-only to ensure cache integrity,
// 45:         # which makes sense but is something we need to undo for cleanup.
// 46:         pathname.directory? && %w[go_cache go_mod_cache].include?(pathname.basename.to_s)
// 47:       end
// 48:
// 49:       sig { params(pathname: Pathname, days: T.nilable(Integer)).returns(T::Boolean) }
// 50:       def prune?(pathname, days)
// 51:         return false unless days
// 52:         return true if days.zero?
// 53:         return true if pathname.symlink? && !pathname.exist?
// 54:
// 55:         days_ago = (DateTime.now - days).to_time
// 56:         pathname.mtime < days_ago && pathname.ctime < days_ago
// 57:       end
// 58:
// 59:       sig { params(entry: { path: Pathname, type: T.nilable(Symbol) }, scrub: T::Boolean).returns(T::Boolean) }
// 60:       def stale?(entry, scrub: false)
// 61:         pathname = entry[:path]
// 62:         return false unless pathname.resolved_path.file?
// 63:
// 64:         case entry[:type]
// 65:         when :api_package
// 66:           scrub
// 67:         when :api_source
// 68:           stale_api_source?(pathname, scrub)
// 69:         when :cask
// 70:           stale_cask?(pathname, scrub)
// 71:         when :gh_actions_artifact
// 72:           scrub || prune?(pathname, GH_ACTIONS_ARTIFACT_CLEANUP_DAYS)
// 73:         else
// 74:           stale_formula?(pathname, scrub)
// 75:         end
// 76:       end
// 77:
// 78:       sig { params(pathname: Pathname, cask: Cask::Cask, name: String).returns(T::Boolean) }
// 79:       def cask_cache_file_current?(pathname, cask, name)
// 80:         pathname.basename.to_s.match?(/\A#{Regexp.escape(name)}--#{Regexp.escape(cask.version)}(?:\.|\z)/)
// 81:       end
// 82:
// 83:       sig { params(pathname: Pathname, cask: Cask::Cask, name: String, scrub: T::Boolean).returns(T::Boolean) }
// 84:       def stale_cask_download?(pathname, cask, name, scrub:)
// 85:         return true unless pathname.exist?
// 86:         return true unless cask_cache_file_current?(pathname, cask, name)
// 87:         return true if scrub && cask.installed_version != cask.version
// 88:
// 89:         if cask.version.latest?
// 90:           cleanup_threshold = (DateTime.now - CLEANUP_DEFAULT_DAYS).to_time
// 91:           return pathname.mtime < cleanup_threshold && pathname.ctime < cleanup_threshold
// 92:         end
// 93:
// 94:         false
// 95:       end
// 96:
// 97:       private
// 98:
// 99:       sig { params(pathname: Pathname, scrub: T::Boolean).returns(T::Boolean) }
// 100:       def stale_api_source?(pathname, scrub)
// 101:         return true if scrub
// 102:
// 103:         path_parts = pathname.each_filename.to_a
// 104:         api_source_index = path_parts.rindex("api-source")
// 105:         return false if api_source_index.nil?
// 106:
// 107:         relative_path_parts = path_parts.drop(api_source_index + 1)
// 108:         return false if relative_path_parts.length < 4
// 109:
// 110:         org = relative_path_parts.fetch(0)
// 111:         repo = relative_path_parts.fetch(1)
// 112:         git_head = relative_path_parts.fetch(2)
// 113:         type = relative_path_parts.fetch(3)
// 114:         basename = relative_path_parts.fetch(-1)
// 115:         return false unless basename.end_with?(".rb")
// 116:
// 117:         name = "#{org}/#{repo}/#{File.basename(basename, ".rb")}"
// 118:         package = case type
// 119:         when "Cask"
// 120:           begin
// 121:             Cask::CaskLoader.load(name)
// 122:           rescue Cask::CaskError
// 123:             nil
// 124:           end
// 125:         when "Formula"
// 126:           begin
// 127:             Formulary.factory(name)
// 128:           rescue FormulaUnavailableError
// 129:             nil
// 130:           end
// 131:         end
// 132:         return false if package.nil? && %w[Cask Formula].exclude?(type)
// 133:         return true if package.nil?
// 134:
// 135:         package.tap_git_head != git_head
// 136:       end
// 137:
// 138:       sig { params(formula: Formula).returns(T::Set[String]) }
// 139:       def excluded_versions_from_cleanup(formula)
// 140:         @excluded_versions_from_cleanup ||= T.let({}, T.nilable(T::Hash[String, T::Set[String]]))
// 141:         @excluded_versions_from_cleanup[formula.name] ||= begin
// 142:           eligible_kegs_for_cleanup = formula.eligible_kegs_for_cleanup(quiet: true)
// 143:           Set.new((formula.installed_kegs - eligible_kegs_for_cleanup).map { |keg| keg.version.to_s })
// 144:         end
// 145:       end
// 146:
// 147:       sig { params(pathname: Pathname, scrub: T::Boolean).returns(T::Boolean) }
// 148:       def stale_formula?(pathname, scrub)
// 149:         return false unless HOMEBREW_CELLAR.directory?
// 150:
// 151:         version = if HOMEBREW_BOTTLES_EXTNAME_REGEX.match?(to_s)
// 152:           begin
// 153:             Utils::Bottles.resolve_version(pathname).to_s
// 154:           rescue
// 155:             nil
// 156:           end
// 157:         end
// 158:         basename_str = pathname.basename.to_s
// 159:
// 160:         version ||= basename_str[/\A.*(?:--.*?)*--(.*?)#{Regexp.escape(pathname.extname)}\Z/, 1]
// 161:         version ||= basename_str[/\A.*--?(.*?)#{Regexp.escape(pathname.extname)}\Z/, 1]
// 162:
// 163:         return false if version.blank?
// 164:
// 165:         version = Version.new(version)
// 166:
// 167:         unless (formula_name = basename_str[/\A(.*?)(?:--.*?)*--?(?:#{Regexp.escape(version.to_s)})/, 1])
// 168:           return false
// 169:         end
// 170:
// 171:         formula = begin
// 172:           Formulary.from_rack(HOMEBREW_CELLAR/formula_name)
// 173:         rescue Homebrew::UntrustedTapError
// 174:           opoo "Skipping #{formula_name}: tap formula is not trusted"
// 175:           nil
// 176:         rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 177:           nil
// 178:         end
// 179:
// 180:         formula_excluded_versions_from_cleanup = nil
// 181:         if formula.blank? && formula_name.delete_suffix!("_bottle_manifest")
// 182:           formula = begin
// 183:             Formulary.from_rack(HOMEBREW_CELLAR/formula_name)
// 184:           rescue Homebrew::UntrustedTapError
// 185:             opoo "Skipping #{formula_name}: tap formula is not trusted"
// 186:             nil
// 187:           rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 188:             nil
// 189:           end
// 190:
// 191:           return false if formula.blank?
// 192:
// 193:           formula_excluded_versions_from_cleanup = excluded_versions_from_cleanup(formula)
// 194:           return false if formula_excluded_versions_from_cleanup.include?(version.to_s)
// 195:
// 196:           if pathname.to_s.include?("_bottle_manifest")
// 197:             excluded_version = version.to_s
// 198:             excluded_version.sub!(/-\d+$/, "")
// 199:             return false if formula_excluded_versions_from_cleanup.include?(excluded_version)
// 200:           end
// 201:
// 202:           # We can't determine an installed rebuild and parsing manifest version cannot be reliably done.
// 203:           return false unless formula.latest_version_installed?
// 204:
// 205:           return true if (bottle = formula.bottle).blank?
// 206:
// 207:           resource_version = bottle.resource.version
// 208:           return false unless resource_version
// 209:
// 210:           return version != GitHubPackages.version_rebuild(resource_version, bottle.rebuild)
// 211:         end
// 212:
// 213:         return false if formula.blank?
// 214:
// 215:         resource_name = basename_str[/\A.*?--(.*?)--?(?:#{Regexp.escape(version.to_s)})/, 1]
// 216:
// 217:         stable = formula.stable
// 218:         if resource_name == "patch"
// 219:           patch_hashes = stable&.patches&.filter_map { T.cast(it, ExternalPatch).resource.version if it.external? }
// 220:           return true unless patch_hashes&.include?(Checksum.new(version.to_s))
// 221:         elsif resource_name && stable && (resource_version = stable.resources[resource_name]&.version)
// 222:           return true if resource_version != version
// 223:         elsif (formula_excluded_versions_from_cleanup ||= excluded_versions_from_cleanup(formula).presence) &&
// 224:               formula_excluded_versions_from_cleanup.include?(version.to_s)
// 225:           return false
// 226:         elsif (formula.latest_version_installed? && formula.pkg_version.to_s != version) ||
// 227:               formula.pkg_version.to_s > version
// 228:           return true
// 229:         end
// 230:
// 231:         return true if scrub && !formula.latest_version_installed?
// 232:         return true if Utils::Bottles.file_outdated?(formula, pathname)
// 233:
// 234:         false
// 235:       end
// 236:
// 237:       sig { params(pathname: Pathname, scrub: T::Boolean).returns(T::Boolean) }
// 238:       def stale_cask?(pathname, scrub)
// 239:         basename = pathname.basename
// 240:         return false unless (name = basename.to_s[/\A(.*?)--/, 1])
// 241:
// 242:         cask = begin
// 243:           Cask::CaskLoader.load(name, warn: false)
// 244:         rescue Cask::CaskError
// 245:           nil
// 246:         end
// 247:
// 248:         return false if cask.blank?
// 249:
// 250:         stale_cask_download?(pathname, cask, name, scrub:)
// 251:       end
// 252:     end
// 253:
// 254:     PERIODIC_CLEAN_FILE = T.let((HOMEBREW_CACHE/".cleaned").freeze, Pathname)
// 255:
// 256:     sig { returns(T::Array[String]) }
// 257:     attr_reader :args
// 258:
// 259:     sig { returns(Integer) }
// 260:     attr_reader :days
// 261:
// 262:     sig { returns(Pathname) }
// 263:     attr_reader :cache
// 264:
// 265:     sig { returns(Integer) }
// 266:     attr_reader :disk_cleanup_size
// 267:
// 268:     sig {
// 269:       params(args: String, dry_run: T::Boolean, scrub: T::Boolean, days: T.nilable(Integer), cache: Pathname).void
// 270:     }
// 271:     def initialize(*args, dry_run: false, scrub: false, days: nil, cache: HOMEBREW_CACHE)
// 272:       @disk_cleanup_size = T.let(0, Integer)
// 273:       @args = args
// 274:       @dry_run = dry_run
// 275:       @scrub = scrub
// 276:       @prune = T.let(days.present?, T::Boolean)
// 277:       @days = T.let(days || Homebrew::EnvConfig.cleanup_max_age_days.to_i, Integer)
// 278:       @cache = cache
// 279:       @cleaned_up_paths = T.let(Set.new, T::Set[Pathname])
// 280:       @formula_cache_paths = T.let(nil, T.nilable(T::Hash[String, T::Array[Pathname]]))
// 281:     end
// 282:
// 283:     sig { returns(T::Boolean) }
// 284:     def dry_run? = @dry_run
// 285:
// 286:     sig { returns(T::Boolean) }
// 287:     def prune? = @prune
// 288:
// 289:     sig { returns(T::Boolean) }
// 290:     def scrub? = @scrub
// 291:
// 292:     sig { params(output: String, ohai: T::Boolean).returns(T::Boolean) }
// 293:     def self.printed_dry_run_output?(output, ohai: false)
// 294:       return false if output.blank?
// 295:
// 296:       if ohai
// 297:         ohai "Would `brew cleanup`"
// 298:       else
// 299:         puts "Would `brew cleanup`:"
// 300:       end
// 301:       print output
// 302:       puts unless output.end_with?("\n")
// 303:       true
// 304:     end
// 305:
// 306:     sig { params(args: String, formulae: T::Array[Formula]).returns(String) }
// 307:     def self.dry_run_output(*args, formulae: [])
// 308:       output = StringIO.new
// 309:       old_stdout = $stdout
// 310:       begin
// 311:         $stdout = output
// 312:         cleanup = Cleanup.new(*args, dry_run: true)
// 313:         if formulae.empty?
// 314:           cleanup.clean!
// 315:         else
// 316:           formulae.each { |formula| cleanup.cleanup_formula(formula) }
// 317:         end
// 318:       ensure
// 319:         $stdout = old_stdout
// 320:       end
// 321:       output.string
// 322:     end
// 323:
// 324:     sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 325:     def self.install_cleanup_formulae(formulae)
// 326:       return [] if Homebrew::EnvConfig.no_install_cleanup?
// 327:
// 328:       formulae.select do |formula|
// 329:         formula.latest_version_installed? && !skip_clean_formula?(formula)
// 330:       end
// 331:     end
// 332:
// 333:     sig { params(formula: Formula).void }
// 334:     def self.install_formula_clean!(formula)
// 335:       return if install_cleanup_formulae([formula]).blank?
// 336:
// 337:       ohai "Running `brew cleanup #{formula}`..."
// 338:       puts_no_install_cleanup_disable_message_if_not_already!
// 339:       Cleanup.new.cleanup_formula(formula)
// 340:     end
// 341:
// 342:     sig { void }
// 343:     def self.puts_no_install_cleanup_disable_message
// 344:       return if Homebrew::EnvConfig.no_env_hints?
// 345:       return if Homebrew::EnvConfig.no_install_cleanup?
// 346:
// 347:       puts "Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`."
// 348:       puts "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`)."
// 349:     end
// 350:
// 351:     sig { void }
// 352:     def self.puts_no_install_cleanup_disable_message_if_not_already!
// 353:       return if @puts_no_install_cleanup_disable_message_if_not_already
// 354:
// 355:       puts_no_install_cleanup_disable_message
// 356:       @puts_no_install_cleanup_disable_message_if_not_already = T.let(true, T.nilable(TrueClass))
// 357:     end
// 358:
// 359:     sig { params(formula: Formula).returns(T::Boolean) }
// 360:     def self.skip_clean_formula?(formula)
// 361:       no_cleanup_formula = Homebrew::EnvConfig.no_cleanup_formulae
// 362:       return false if no_cleanup_formula.blank?
// 363:
// 364:       @skip_clean_formulae ||= T.let(no_cleanup_formula.split(","), T.nilable(T::Array[String]))
// 365:       @skip_clean_formulae.include?(formula.name) || @skip_clean_formulae.intersect?(formula.aliases)
// 366:     end
// 367:
// 368:     sig { returns(T::Boolean) }
// 369:     def self.periodic_clean_due?
// 370:       return false if Homebrew::EnvConfig.no_install_cleanup?
// 371:
// 372:       unless PERIODIC_CLEAN_FILE.exist?
// 373:         HOMEBREW_CACHE.mkpath
// 374:         FileUtils.touch PERIODIC_CLEAN_FILE
// 375:         return false
// 376:       end
// 377:
// 378:       PERIODIC_CLEAN_FILE.mtime < (DateTime.now - CLEANUP_DEFAULT_DAYS).to_time
// 379:     end
// 380:
// 381:     sig { params(dry_run: T::Boolean).void }
// 382:     def self.periodic_clean!(dry_run: false)
// 383:       return if Homebrew::EnvConfig.no_install_cleanup?
// 384:       return unless periodic_clean_due?
// 385:
// 386:       if dry_run
// 387:         oh1 "Would run `brew cleanup` which has not been run in the last #{CLEANUP_DEFAULT_DAYS} days"
// 388:       else
// 389:         oh1 "`brew cleanup` has not been run in the last #{CLEANUP_DEFAULT_DAYS} days, running now..."
// 390:       end
// 391:
// 392:       puts_no_install_cleanup_disable_message
// 393:       return if dry_run
// 394:
// 395:       Cleanup.new.clean!(quiet: true, periodic: true)
// 396:     end
// 397:
// 398:     sig { params(quiet: T::Boolean, periodic: T::Boolean).void }
// 399:     def clean!(quiet: false, periodic: false)
// 400:       if args.empty?
// 401:         Formula.installed
// 402:                .sort_by(&:name)
// 403:                .reject { |f| Cleanup.skip_clean_formula?(f) }
// 404:                .each do |formula|
// 405:           # Don't `cleanup_unreferenced` here for each formula.
// 406:           # Instead, let it be run once `cleanup_cache` below.
// 407:           cleanup_formula(formula, quiet:, ds_store: false, cache_db: false, cleanup_unreferenced: false)
// 408:         end
// 409:
// 410:         if ENV["HOMEBREW_AUTOREMOVE"].present?
// 411:           opoo "`$HOMEBREW_AUTOREMOVE` is now a no-op as it is the default behaviour. " \
// 412:                "Set `HOMEBREW_NO_AUTOREMOVE=1` to disable it."
// 413:         end
// 414:         Cleanup.autoremove(dry_run: dry_run?) unless Homebrew::EnvConfig.no_autoremove?
// 415:
// 416:         cleanup_cache
// 417:         cleanup_empty_api_source_directories
// 418:         cleanup_bootsnap
// 419:         cleanup_logs
// 420:         cleanup_temp_cellar
// 421:         cleanup_reinstall_kegs
// 422:         cleanup_lockfiles
// 423:         cleanup_python_site_packages
// 424:         prune_prefix_symlinks_and_directories
// 425:
// 426:         unless dry_run?
// 427:           cleanup_cache_db
// 428:           rm_ds_store
// 429:           HOMEBREW_CACHE.mkpath
// 430:           FileUtils.touch PERIODIC_CLEAN_FILE
// 431:         end
// 432:
// 433:         # Cleaning up Ruby needs to be done last to avoid requiring additional
// 434:         # files afterwards. Additionally, don't allow it on periodic cleans to
// 435:         # avoid having to try to do a `brew install` when we've just deleted
// 436:         # the running Ruby process...
// 437:         return if periodic
// 438:
// 439:         cleanup_portable_ruby
// 440:       else
// 441:         args.each do |arg|
// 442:           formula = begin
// 443:             Formulary.resolve(arg)
// 444:           rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 445:             nil
// 446:           end
// 447:
// 448:           cask = begin
// 449:             Cask::CaskLoader.load(arg)
// 450:           rescue Cask::CaskError
// 451:             nil
// 452:           end
// 453:
// 454:           if formula && Cleanup.skip_clean_formula?(formula)
// 455:             onoe "Refusing to clean #{formula} because it is listed in " \
// 456:                  "#{Tty.bold}HOMEBREW_NO_CLEANUP_FORMULAE#{Tty.reset}!"
// 457:           elsif formula
// 458:             cleanup_formula(formula)
// 459:           end
// 460:           cleanup_cask(cask) if cask
// 461:         end
// 462:       end
// 463:     end
// 464:
// 465:     sig { returns(T::Array[Keg]) }
// 466:     def unremovable_kegs
// 467:       @unremovable_kegs ||= T.let([], T.nilable(T::Array[Keg]))
// 468:     end
// 469:
// 470:     sig {
// 471:       params(paths: T::Array[Pathname], type: T.nilable(Symbol))
// 472:         .returns(T::Array[{ path: Pathname, type: T.nilable(Symbol) }])
// 473:     }
// 474:     def cache_entries(paths, type:)
// 475:       paths.map { |path| { path:, type: } }
// 476:     end
// 477:
// 478:     sig {
// 479:       params(paths: T::Array[Pathname], type: T.nilable(Symbol), cleanup_unreferenced: T::Boolean).void
// 480:     }
// 481:     def cleanup_cache_entries(paths, type:, cleanup_unreferenced: true)
// 482:       cleanup_cache(cache_entries(paths, type:), cleanup_unreferenced:)
// 483:     end
// 484:
// 485:     # Returns the cached `<formula>--<version>` and
// 486:     # `<formula>_bottle_manifest--<version>` downloads for a formula. Globbing
// 487:     # these per formula rescans the entire cache each time, which is quadratic
// 488:     # for `brew cleanup`, so index the cache by name prefix once instead.
// 489:     sig { params(formula: Formula).returns(T::Array[Pathname]) }
// 490:     def formula_cache_paths(formula)
// 491:       return [] unless cache.directory?
// 492:
// 493:       index = @formula_cache_paths ||= cache.children.each_with_object({}) do |path, hash|
// 494:         prefix, separator, = path.basename.to_s.partition("--")
// 495:         next if prefix.start_with?(".") || separator.empty?
// 496:
// 497:         (hash[prefix] ||= []) << path
// 498:       end
// 499:
// 500:       [*index.fetch(formula.name, []), *index.fetch("#{formula.name}_bottle_manifest", [])].sort
// 501:     end
// 502:
// 503:     sig {
// 504:       params(formula: Formula, quiet: T::Boolean, ds_store: T::Boolean, cache_db: T::Boolean,
// 505:              cleanup_unreferenced: T::Boolean).void
// 506:     }
// 507:     def cleanup_formula(formula, quiet: false, ds_store: true, cache_db: true, cleanup_unreferenced: true)
// 508:       formula.eligible_kegs_for_cleanup(quiet:)
// 509:              .each { |keg| cleanup_keg(keg) }
// 510:       cleanup_cache_entries(formula_cache_paths(formula), type: nil, cleanup_unreferenced:)
// 511:       rm_ds_store([formula.rack]) if ds_store
// 512:       cleanup_cache_db(formula.rack) if cache_db
// 513:       cleanup_lockfiles(FormulaLock.new(formula.name).path)
// 514:     end
// 515:
// 516:     sig { params(cask: Cask::Cask, ds_store: T::Boolean).void }
// 517:     def cleanup_cask(cask, ds_store: true)
// 518:       cleanup_cache_entries(Pathname.glob(cache/"Cask/#{cask.token}--*"), type: :cask, cleanup_unreferenced: false)
// 519:       cleanup_legacy_cask_downloads([cask])
// 520:       cleanup_unreferenced_downloads
// 521:
// 522:       rm_ds_store([cask.caskroom_path]) if ds_store
// 523:       cleanup_lockfiles(CaskLock.new(cask.token).path)
// 524:     end
// 525:
// 526:     # Added 2026-07-05 for legacy cask cache symlinks named after URL basenames.
// 527:     # Remove after 2026-11-02, once the 120-day fallback stale-file sweep has
// 528:     # had time to prune stale files created before cask downloads were token-named.
// 529:     sig { params(casks: T::Array[Cask::Cask]).void }
// 530:     def cleanup_legacy_cask_downloads(casks)
// 531:       cask_cache = cache/"Cask"
// 532:       return unless cask_cache.directory?
// 533:
// 534:       cask_cache_paths = cask_cache.children.select { |path| path.file? || path.symlink? }
// 535:
// 536:       casks.each do |cask|
// 537:         next unless (url = cask.url)
// 538:
// 539:         legacy_download_name = Utils.safe_filename(File.basename(url.to_s))
// 540:         next if legacy_download_name.blank? || legacy_download_name == cask.token
// 541:
// 542:         cask_cache_paths.each do |path|
// 543:           next unless path.basename.to_s.start_with?("#{legacy_download_name}--")
// 544:           next if !self.class.stale_cask_download?(path, cask, legacy_download_name, scrub: scrub?) &&
// 545:                   (!self.class.cask_cache_file_current?(path, cask, legacy_download_name) ||
// 546:                    !(cask_cache/Utils.safe_filename("#{cask.token}--#{cask.version}#{path.extname}")).exist?)
// 547:
// 548:           cleanup_path(path) { path.unlink }
// 549:         end
// 550:       end
// 551:     end
// 552:
// 553:     sig { params(keg: Keg).void }
// 554:     def cleanup_keg(keg)
// 555:       cleanup_path(Pathname.new(keg)) { keg.uninstall(raise_failures: true) }
// 556:     rescue Errno::EACCES, Errno::ENOTEMPTY => e
// 557:       opoo e.message
// 558:       unremovable_kegs << keg
// 559:     end
// 560:
// 561:     sig { void }
// 562:     def cleanup_logs
// 563:       return unless HOMEBREW_LOGS.directory?
// 564:
// 565:       logs_days = [days, CLEANUP_DEFAULT_DAYS].min
// 566:
// 567:       HOMEBREW_LOGS.subdirs.each do |dir|
// 568:         cleanup_path(dir) { FileUtils.rm_r(dir) } if self.class.prune?(dir, logs_days)
// 569:       end
// 570:     end
// 571:
// 572:     sig { void }
// 573:     def cleanup_temp_cellar
// 574:       return unless HOMEBREW_TEMP_CELLAR.directory?
// 575:
// 576:       HOMEBREW_TEMP_CELLAR.each_child do |child|
// 577:         cleanup_path(child) { FileUtils.rm_r(child) }
// 578:       end
// 579:     end
// 580:
// 581:     sig { void }
// 582:     def cleanup_reinstall_kegs
// 583:       return unless HOMEBREW_CELLAR.directory?
// 584:
// 585:       HOMEBREW_CELLAR.glob("*/*.reinstall").each do |reinstall_keg|
// 586:         cleanup_path(reinstall_keg) { FileUtils.rm_r(reinstall_keg) }
// 587:       end
// 588:     end
// 589:
// 590:     sig { returns(T::Array[{ path: Pathname, type: T.nilable(Symbol) }]) }
// 591:     def cache_files
// 592:       files = cache.directory? ? cache.children : []
// 593:       cask_files = (cache/"Cask").directory? ? (cache/"Cask").children : []
// 594:       api_internal = cache/"api/internal"
// 595:       api_package_files = if scrub? && api_internal.directory?
// 596:         current_api_package_basename = Homebrew::API::Internal.cached_packages_json_file_path.basename.to_s
// 597:         # Keep only the current OS's envelope and its `.payload` and
// 598:         # `.payload.index` sidecars and scrub the rest, including orphaned
// 599:         # sidecars and temp files.
// 600:         # Keep in sync with the previous-OS-version removal in cmd/update.sh.
// 601:         kept_basenames = [
// 602:           current_api_package_basename,
// 603:           "#{current_api_package_basename}.payload",
// 604:           "#{current_api_package_basename}.payload.index",
// 605:         ]
// 606:         api_internal.glob("packages.*.jws.json*").reject do |path|
// 607:           kept_basenames.include?(path.basename.to_s)
// 608:         end
// 609:       else
// 610:         []
// 611:       end
// 612:       api_source_files = (cache/"api-source").glob("*/*/*/**/*").select { |path| path.file? || path.symlink? }
// 613:       gh_actions_artifacts = (cache/"gh-actions-artifact").directory? ? (cache/"gh-actions-artifact").children : []
// 614:
// 615:       cache_entries(files, type: nil) +
// 616:         cache_entries(cask_files, type: :cask) +
// 617:         cache_entries(api_package_files, type: :api_package) +
// 618:         cache_entries(api_source_files, type: :api_source) +
// 619:         cache_entries(gh_actions_artifacts, type: :gh_actions_artifact)
// 620:     end
// 621:
// 622:     sig { params(directory: Pathname).void }
// 623:     def cleanup_empty_api_source_directories(directory = cache/"api-source")
// 624:       return if dry_run?
// 625:       return unless directory.directory?
// 626:
// 627:       directory.each_child do |child|
// 628:         next unless child.directory?
// 629:
// 630:         cleanup_empty_api_source_directories(child)
// 631:         child.rmdir if child.empty?
// 632:       end
// 633:     end
// 634:
// 635:     sig { void }
// 636:     def cleanup_unreferenced_downloads
// 637:       return if dry_run?
// 638:       return unless (cache/"downloads").directory?
// 639:
// 640:       downloads = (cache/"downloads").children
// 641:
// 642:       referenced_downloads = cache_files.map { |file| file[:path] }.select(&:symlink?).map(&:resolved_path)
// 643:
// 644:       (downloads - referenced_downloads).each do |download|
// 645:         if self.class.incomplete?(download)
// 646:           begin
// 647:             DownloadLock.new(download).with_lock do
// 648:               download.unlink
// 649:             end
// 650:           rescue OperationInProgressError
// 651:             # Skip incomplete downloads which are still in progress.
// 652:             next
// 653:           end
// 654:         elsif download.directory?
// 655:           FileUtils.rm_rf download
// 656:         else
// 657:           download.unlink
// 658:         end
// 659:       end
// 660:     end
// 661:
// 662:     sig {
// 663:       params(entries:              T.nilable(T::Array[{ path: Pathname, type: T.nilable(Symbol) }]),
// 664:              cleanup_unreferenced: T::Boolean).void
// 665:     }
// 666:     def cleanup_cache(entries = nil, cleanup_unreferenced: true)
// 667:       full_cache_cleanup = entries.nil?
// 668:       entries ||= cache_files
// 669:
// 670:       entries.each do |entry|
// 671:         path = entry[:path]
// 672:         next if path == PERIODIC_CLEAN_FILE
// 673:
// 674:         FileUtils.chmod_R 0755, path if self.class.go_cache_directory?(path) && !dry_run?
// 675:         next cleanup_path(path) { path.unlink } if self.class.incomplete?(path)
// 676:         next cleanup_path(path) { FileUtils.rm_rf path } if self.class.nested_cache?(path)
// 677:
// 678:         if self.class.prune?(path, days)
// 679:           if path.file? || path.symlink?
// 680:             cleanup_path(path) { path.unlink }
// 681:           elsif path.directory? && path.to_s.include?("--")
// 682:             cleanup_path(path) { FileUtils.rm_rf path }
// 683:           end
// 684:           next
// 685:         end
// 686:
// 687:         # If we've specified --prune don't do the (expensive) .stale? check.
// 688:         cleanup_path(path) { path.unlink } if !prune? && self.class.stale?(entry, scrub: scrub?)
// 689:       end
// 690:
// 691:       cleanup_legacy_cask_downloads(Cask::Caskroom.casks) if full_cache_cleanup
// 692:       cleanup_unreferenced_downloads if cleanup_unreferenced
// 693:     end
// 694:
// 695:     sig { params(path: Pathname, _block: T.proc.void).void }
// 696:     def cleanup_path(path, &_block)
// 697:       return if !path.exist? && !path.symlink?
// 698:       return unless @cleaned_up_paths.add?(path)
// 699:
// 700:       @disk_cleanup_size += path.disk_usage
// 701:
// 702:       if dry_run?
// 703:         puts "Would remove: #{path} (#{path.abv})"
// 704:       else
// 705:         puts "Removing: #{path}... (#{path.abv})"
// 706:         yield
// 707:       end
// 708:     end
// 709:
// 710:     sig { params(lockfiles: Pathname).void }
// 711:     def cleanup_lockfiles(*lockfiles)
// 712:       return if dry_run?
// 713:
// 714:       lockfiles = HOMEBREW_LOCKS.children.select(&:file?) if lockfiles.empty? && HOMEBREW_LOCKS.directory?
// 715:
// 716:       lockfiles.each do |file|
// 717:         next unless file.readable?
// 718:
// 719:         file.open(File::RDWR) do |lockfile|
// 720:           next unless lockfile.flock(File::LOCK_EX | File::LOCK_NB)
// 721:
// 722:           begin
// 723:             file.unlink
// 724:           ensure
// 725:             lockfile.flock(File::LOCK_UN) if file.exist?
// 726:           end
// 727:         end
// 728:       end
// 729:     end
// 730:
// 731:     sig { void }
// 732:     def cleanup_portable_ruby
// 733:       vendor_dir = HOMEBREW_LIBRARY/"Homebrew/vendor"
// 734:       portable_ruby_latest_version = (vendor_dir/"portable-ruby-version").read.chomp
// 735:
// 736:       portable_rubies_to_remove = []
// 737:       Pathname.glob(vendor_dir/"portable-ruby/*.*").select(&:directory?).each do |path|
// 738:         next if !use_system_ruby? && portable_ruby_latest_version == path.basename.to_s
// 739:
// 740:         portable_rubies_to_remove << path
// 741:       end
// 742:
// 743:       return if portable_rubies_to_remove.empty?
// 744:
// 745:       bundler_paths = (vendor_dir/"bundle/ruby").children.select do |child|
// 746:         basename = child.basename.to_s
// 747:
// 748:         next false if basename == ".homebrew_gem_groups"
// 749:         next true unless child.directory?
// 750:
// 751:         [
// 752:           "#{Version.new(portable_ruby_latest_version).major_minor}.0",
// 753:           RbConfig::CONFIG["ruby_version"],
// 754:         ].uniq.exclude?(basename)
// 755:       end
// 756:
// 757:       bundler_paths.each do |bundler_path|
// 758:         if dry_run?
// 759:           puts Utils.popen_read("git", "-C", HOMEBREW_REPOSITORY, "clean", "-nx", bundler_path).chomp
// 760:         else
// 761:           puts Utils.popen_read("git", "-C", HOMEBREW_REPOSITORY, "clean", "-ffqx", bundler_path).chomp
// 762:         end
// 763:       end
// 764:
// 765:       portable_rubies_to_remove.each do |portable_ruby|
// 766:         cleanup_path(portable_ruby) { FileUtils.rm_r(portable_ruby) }
// 767:       end
// 768:     end
// 769:
// 770:     sig { returns(T::Boolean) }
// 771:     def use_system_ruby?
// 772:       false
// 773:     end
// 774:
// 775:     sig { void }
// 776:     def cleanup_bootsnap
// 777:       bootsnap = cache/"bootsnap"
// 778:       return unless bootsnap.directory?
// 779:
// 780:       bootsnap.each_child do |subdir|
// 781:         cleanup_path(subdir) { FileUtils.rm_r(subdir) } if subdir.basename.to_s != Homebrew::Bootsnap.key
// 782:       end
// 783:     end
// 784:
// 785:     sig { params(rack: T.nilable(Pathname)).void }
// 786:     def cleanup_cache_db(rack = nil)
// 787:       FileUtils.rm_rf [
// 788:         cache/"desc_cache.json",
// 789:         cache/"linkage.db",
// 790:         cache/"linkage.db.db",
// 791:       ]
// 792:
// 793:       CacheStoreDatabase.use(:linkage) do |db|
// 794:         break unless db.created?
// 795:
// 796:         db.each_key do |keg|
// 797:           keg = T.cast(keg, String)
// 798:           next if rack && !keg.start_with?("#{rack}/")
// 799:           next if File.directory?(keg)
// 800:
// 801:           LinkageCacheStore.new(
// 802:             keg,
// 803:             T.cast(db, CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]]),
// 804:           ).delete!
// 805:         end
// 806:       end
// 807:     end
// 808:
// 809:     sig { params(dirs: T.nilable(T::Array[Pathname])).void }
// 810:     def rm_ds_store(dirs = nil)
// 811:       dirs ||= Keg.must_exist_directories + [
// 812:         HOMEBREW_PREFIX/"Caskroom",
// 813:       ]
// 814:       dirs.select(&:directory?)
// 815:           .flat_map { |d| Pathname.glob("#{d}/**/.DS_Store") }
// 816:           .each do |dir|
// 817:             dir.unlink
// 818:           rescue Errno::EACCES
// 819:             # don't care if we can't delete a .DS_Store
// 820:             nil
// 821:           end
// 822:     end
// 823:
// 824:     sig { void }
// 825:     def cleanup_python_site_packages
// 826:       pyc_files = Hash.new { |h, k| h[k] = [] }
// 827:       seen_non_pyc_file = Hash.new { |h, k| h[k] = false }
// 828:       unused_pyc_files = []
// 829:
// 830:       HOMEBREW_PREFIX.glob("lib/python*/site-packages").each do |site_packages|
// 831:         site_packages.each_child do |child|
// 832:           next unless child.directory?
// 833:           # TODO: Work out a sensible way to clean up `pip`'s, `setuptools`' and `wheel`'s
// 834:           #       `{dist,site}-info` directories. Alternatively, consider always removing
// 835:           #       all `-info` directories, because we may not be making use of them.
// 836:           next if child.basename.to_s.end_with?("-info")
// 837:
// 838:           # Clean up old *.pyc files in the top-level __pycache__.
// 839:           if child.basename.to_s == "__pycache__"
// 840:             child.find do |path|
// 841:               next if path.extname != ".pyc"
// 842:               next unless self.class.prune?(path, days)
// 843:
// 844:               unused_pyc_files << path
// 845:             end
// 846:
// 847:             next
// 848:           end
// 849:
// 850:           # Look for directories that contain only *.pyc files.
// 851:           child.find do |path|
// 852:             next if path.directory?
// 853:
// 854:             if path.extname == ".pyc"
// 855:               pyc_files[child] << path
// 856:             else
// 857:               seen_non_pyc_file[child] = true
// 858:               break
// 859:             end
// 860:           end
// 861:         end
// 862:       end
// 863:
// 864:       unused_pyc_files += pyc_files.reject { |k,| seen_non_pyc_file[k] }
// 865:                                    .values
// 866:                                    .flatten
// 867:       return if unused_pyc_files.blank?
// 868:
// 869:       unused_pyc_files.each do |pyc|
// 870:         cleanup_path(pyc) { pyc.unlink }
// 871:       end
// 872:     end
// 873:
// 874:     sig { void }
// 875:     def prune_prefix_symlinks_and_directories
// 876:       ObserverPathnameExtension.reset_counts!
// 877:
// 878:       dirs = []
// 879:       children_count = {}
// 880:
// 881:       Keg.must_exist_subdirectories.each do |dir|
// 882:         next unless dir.directory?
// 883:
// 884:         dir.find do |path|
// 885:           path.extend(ObserverPathnameExtension)
// 886:           if path.symlink?
// 887:             unless path.resolved_path_exists?
// 888:               path.uninstall_info if path.to_s.match?(Keg::INFOFILE_RX) && !dry_run?
// 889:
// 890:               if dry_run?
// 891:                 puts "Would remove (broken link): #{path}"
// 892:                 children_count[path.dirname] -= 1 if children_count.key?(path.dirname)
// 893:               else
// 894:                 path.unlink
// 895:               end
// 896:             end
// 897:           elsif path.directory? && Keg.must_exist_subdirectories.exclude?(path)
// 898:             dirs << path
// 899:             children_count[path] = path.children.length if dry_run?
// 900:           end
// 901:         end
// 902:       end
// 903:
// 904:       dirs.reverse_each do |d|
// 905:         if !dry_run?
// 906:           d.rmdir_if_possible
// 907:         elsif children_count[d].zero?
// 908:           puts "Would remove (empty directory): #{d}"
// 909:           children_count[d.dirname] -= 1 if children_count.key?(d.dirname)
// 910:         end
// 911:       end
// 912:
// 913:       require "cask/caskroom"
// 914:       if Cask::Caskroom.path.directory?
// 915:         Cask::Caskroom.path.each_child do |path|
// 916:           path.extend(ObserverPathnameExtension)
// 917:           next if !path.symlink? || path.resolved_path_exists?
// 918:
// 919:           if dry_run?
// 920:             puts "Would remove (broken link): #{path}"
// 921:           else
// 922:             path.unlink
// 923:           end
// 924:         end
// 925:       end
// 926:
// 927:       return if dry_run?
// 928:
// 929:       return if ObserverPathnameExtension.total.zero?
// 930:
// 931:       n, d = ObserverPathnameExtension.counts
// 932:       print "Pruned #{n} symbolic links "
// 933:       print "and #{d} directories " if d.positive?
// 934:       puts "from #{HOMEBREW_PREFIX}"
// 935:     end
// 936:
// 937:     sig { params(dry_run: T::Boolean).void }
// 938:     def self.autoremove(dry_run: false)
// 939:       require "utils/autoremove"
// 940:       require "cask/caskroom"
// 941:
// 942:       # If this runs after install, uninstall, reinstall or upgrade,
// 943:       # the cache of installed formulae may no longer be valid.
// 944:       Formula.clear_cache unless dry_run
// 945:
// 946:       formulae = Formula.installed
// 947:       # Remove formulae listed in HOMEBREW_NO_CLEANUP_FORMULAE and their dependencies.
// 948:       if Homebrew::EnvConfig.no_cleanup_formulae.present?
// 949:         formulae -= formulae.select { skip_clean_formula?(it) }
// 950:                             .flat_map { |f| [f, *f.installed_runtime_formula_dependencies] }
// 951:       end
// 952:       casks = Cask::Caskroom.casks
// 953:
// 954:       removable_formulae = Utils::Autoremove.removable_formulae(formulae, casks)
// 955:       if (candidate_kegs = removable_formulae.filter_map(&:any_installed_keg).presence) &&
// 956:          (required_kegs, = InstalledDependents.find_some_installed_dependents(candidate_kegs)) &&
// 957:          (required_names = Set.new(required_kegs.map(&:name)).presence)
// 958:         removable_formulae.reject! { |formula| required_names.include?(formula.name) }
// 959:       end
// 960:
// 961:       return if removable_formulae.blank?
// 962:
// 963:       formulae_names = removable_formulae.map(&:full_name).sort
// 964:
// 965:       verb = dry_run ? "Would autoremove" : "Autoremoving"
// 966:       oh1 "#{verb} #{formulae_names.count} unneeded #{Utils.pluralize("formula", formulae_names.count)}:"
// 967:       puts formulae_names.join("\n")
// 968:       return if dry_run
// 969:
// 970:       require "uninstall"
// 971:
// 972:       kegs_by_rack = removable_formulae.filter_map(&:any_installed_keg).group_by(&:rack)
// 973:       Uninstall.uninstall_kegs(kegs_by_rack)
// 974:
// 975:       # The installed formula cache will be invalid after uninstalling.
// 976:       Formula.clear_cache
// 977:     end
// 978:   end
// 979: end
// 980:
// 981: require "extend/os/cleanup"
