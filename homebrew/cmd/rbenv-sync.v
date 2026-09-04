module cmd

import ruby
import os

// Translated from Homebrew/brew `cmd/rbenv-sync.rb`.
pub struct InstalledRubyVersion {
pub:
	path    string
	version string
}

pub struct RbenvSyncResult {
pub:
	skipped_busy bool
pub mut:
	created []string
	skipped []string
	removed []string
}

fn rbenv_numeric_component(component string) !int {
	mut end := 0
	for end < component.len && component[end] >= `0` && component[end] <= `9` {
		end++
	}
	if end == 0 {
		return error('invalid Ruby version component `${component}`')
	}
	return component[..end].int()
}

pub fn rbenv_version_aliases(version string, strict bool) ![]string {
	parts := version.split('.')
	if parts.len < 3 {
		return error('Ruby version `${version}` must have major, minor, and patch components')
	}
	major := rbenv_numeric_component(parts[0])!
	minor := rbenv_numeric_component(parts[1])!
	patch := rbenv_numeric_component(parts[2])!
	start := if strict { patch } else { 0 }
	mut aliases := []string{}
	for value in start .. patch + 1 {
		aliases << '${major}.${minor}.${value}'
	}
	return aliases
}

pub fn link_rbenv_versions(installed InstalledRubyVersion, versions_path string, strict bool) !RbenvSyncResult {
	os.mkdir_all(versions_path)!
	mut created := []string{}
	mut skipped := []string{}
	for alias in rbenv_version_aliases(installed.version, strict)! {
		link_path := os.join_path(versions_path, alias)
		if os.exists(link_path) && !os.is_link(link_path) {
			skipped << link_path
			continue
		}
		if os.is_link(link_path) {
			os.rm(link_path)!
		}
		os.symlink(installed.path, link_path)!
		created << link_path
	}
	return RbenvSyncResult{
		created: created
		skipped: skipped
	}
}

pub fn sync_rbenv_versions(rbenv_root string, installed []InstalledRubyVersion, strict bool) !RbenvSyncResult {
	running := os.join_path(rbenv_root, '.rbenv_sync_running')
	if os.exists(running) {
		return RbenvSyncResult{
			skipped_busy: true
		}
	}
	versions_path := os.join_path(rbenv_root, 'versions')
	os.mkdir_all(versions_path)!
	os.write_file(running, '')!
	defer {
		os.rm(running) or {}
	}
	mut result := RbenvSyncResult{}
	for ruby_version in installed {
		linked := link_rbenv_versions(ruby_version, versions_path, strict)!
		result.created << linked.created
		result.skipped << linked.skipped
	}
	for entry in os.ls(versions_path)! {
		path := os.join_path(versions_path, entry)
		if os.is_link(path) && !os.exists(path) {
			os.rm(path)!
			result.removed << path
		}
	}
	return result
}

pub fn installed_ruby_version_value(version InstalledRubyVersion) ruby.Value {
	return ruby.structured_value('InstalledRubyVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_ruby_version_from_value(value ruby.Value) InstalledRubyVersion {
	return InstalledRubyVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn rbenv_sync_result_value(result RbenvSyncResult) ruby.Value {
	return ruby.Value{
		type_name: 'RbenvSyncResult'
		repr: result.created.str()
		attributes: {
			'skipped_busy': result.skipped_busy.str()
		}
		map_data: {
			'created': ruby.string_array_value(result.created)
			'skipped': ruby.string_array_value(result.skipped)
			'removed': ruby.string_array_value(result.removed)
		}
	}
}
