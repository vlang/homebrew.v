module homebrew

import ruby
import os

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
	unremovable_kegs      []ruby.Value
	output                []string
}

fn cleanup_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn cleanup_bool_attr(value ruby.Value, name string, fallback bool) bool {
	raw := value.attributes[name] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn cleanup_int_attr(value ruby.Value, name string, fallback i64) i64 {
	return (value.attributes[name] or { return fallback }).i64()
}

fn cleanup_string_list(value ruby.Value, name string) []string {
	raw := value.attributes[name] or { return [] }
	if raw == '' {
		return []
	}
	return raw.split('\x1f')
}

fn cleanup_path_from_value(value ruby.Value) CleanupPath {
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
			i64(os.file_size(path))
		} else {
			0
		})
		locked: cleanup_bool_attr(value, 'locked', false)
	}
}

fn cleanup_path_value(path CleanupPath) ruby.Value {
	return ruby.structured_value('Pathname', path.path, {
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

fn cleanup_entry_from_value(value ruby.Value) CleanupEntry {
	path_value := value.map_data['path'] or { value }
	type_value := value.map_data['type'] or { cleanup_nil() }
	return CleanupEntry{
		path: cleanup_path_from_value(path_value)
		type_name: if type_value.type_name == 'NilClass' {
			''
		} else {
			type_value.as_string().trim_left(':')
		}
	}
}

fn cleanup_entry_value(entry CleanupEntry) ruby.Value {
	return ruby.map_value({
		'path': cleanup_path_value(entry.path)
		'type': if entry.type_name == '' {
			cleanup_nil()
		} else {
			ruby.object_value('Symbol', ':${entry.type_name}')
		}
	})
}

fn cleanup_formula_from_value(value ruby.Value) CleanupFormula {
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

fn cleanup_formula_value(formula CleanupFormula) ruby.Value {
	mut resources := map[string]ruby.Value{}
	for key, version in formula.resource_versions {
		resources[key] = ruby.string_value(version)
	}
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.name
		map_data: {
			'resource_versions': ruby.map_value(resources)
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

fn cleanup_cask_from_value(value ruby.Value) CleanupCask {
	return CleanupCask{
		token: value.attributes['token'] or { value.as_string() }
		version: value.attributes['version'] or { '' }
		installed_version: value.attributes['installed_version'] or { '' }
		latest: cleanup_bool_attr(value, 'latest', false)
		url: value.attributes['url'] or { '' }
		caskroom_path: value.attributes['caskroom_path'] or { '' }
	}
}

fn cleanup_cask_value(cask CleanupCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.token, {
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
		unremovable_kegs: []ruby.Value{}
		output: []string{}
	}
}

fn cleanup_value(cleanup &Cleanup) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::Cleanup'
		repr: 'Homebrew::Cleanup'
		array_data: cleanup.unremovable_kegs.clone()
		map_data: {
			'output': ruby.string_array_value(cleanup.output)
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

fn cleanup_from_value(value ruby.Value) &Cleanup {
	address := value.attributes['cleanup_address'] or { panic('invalid Cleanup receiver') }
	return unsafe { &Cleanup(voidptr(address.u64())) }
}

fn cleanup_output_value(cleanup &Cleanup) ruby.Value {
	return ruby.string_value(if cleanup.output.len == 0 {
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

fn cleanup_entries_value(entries []CleanupEntry) ruby.Value {
	return ruby.array_value(entries.map(cleanup_entry_value(it)))
}

fn cleanup_values(value ruby.Value) []ruby.Value {
	return value.as_array() or { [] }
}

fn cleanup_clone_value(value ruby.Value) ruby.Value {
	return ruby.Value{
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
