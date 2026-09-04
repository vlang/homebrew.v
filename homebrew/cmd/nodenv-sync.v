module cmd

import ruby
import os

// Translated from Homebrew/brew `cmd/nodenv-sync.rb`.
pub struct InstalledNodeVersion {
pub:
	path    string
	version string
}

pub struct NodenvSyncResult {
pub:
	skipped_busy bool
pub mut:
	created []string
	skipped []string
	removed []string
}

pub fn nodenv_version_aliases(version string, strict bool) ![]string {
	parts := version.split('.')
	if parts.len < 3 {
		return error('Node version `${version}` must have major, minor, and patch components')
	}
	major := rbenv_numeric_component(parts[0])!
	minor := rbenv_numeric_component(parts[1])!
	patch := rbenv_numeric_component(parts[2])!
	minor_start := if strict { minor } else { 0 }
	patch_start := if strict { patch } else { 0 }
	mut aliases := []string{}
	for minor_value in minor_start .. minor + 1 {
		for patch_value in patch_start .. patch + 1 {
			aliases << '${major}.${minor_value}.${patch_value}'
		}
	}
	return aliases
}

pub fn link_nodenv_versions(installed InstalledNodeVersion, versions_path string, strict bool) !NodenvSyncResult {
	os.mkdir_all(versions_path)!
	mut result := NodenvSyncResult{}
	for alias in nodenv_version_aliases(installed.version, strict)! {
		link_path := os.join_path(versions_path, alias)
		if os.exists(link_path) && !os.is_link(link_path) {
			result.skipped << link_path
			continue
		}
		if os.is_link(link_path) {
			os.rm(link_path)!
		}
		os.symlink(installed.path, link_path)!
		result.created << link_path
	}
	return result
}

pub fn sync_nodenv_versions(nodenv_root string, installed []InstalledNodeVersion, strict bool) !NodenvSyncResult {
	running := os.join_path(nodenv_root, '.nodenv_sync_running')
	if os.exists(running) {
		return NodenvSyncResult{
			skipped_busy: true
		}
	}
	versions_path := os.join_path(nodenv_root, 'versions')
	os.mkdir_all(versions_path)!
	os.write_file(running, '')!
	defer {
		os.rm(running) or {}
	}
	mut result := NodenvSyncResult{}
	for node_version in installed {
		linked := link_nodenv_versions(node_version, versions_path, strict)!
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

pub fn installed_node_version_value(version InstalledNodeVersion) ruby.Value {
	return ruby.structured_value('InstalledNodeVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_node_version_from_value(value ruby.Value) InstalledNodeVersion {
	return InstalledNodeVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn nodenv_sync_result_value(result NodenvSyncResult) ruby.Value {
	return ruby.Value{
		type_name: 'NodenvSyncResult'
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
