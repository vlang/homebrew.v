module cmd

import ruby
import os

// Translated from Homebrew/brew `cmd/pyenv-sync.rb`.
const pyenv_unversioned_executables = ['python3', 'pip3', 'wheel3', 'idle3', 'pydoc3']

pub struct InstalledPythonVersion {
pub:
	path    string
	version string
}

pub struct PyenvSyncResult {
pub:
	skipped_busy bool
pub mut:
	created  []string
	skipped  []string
	removed  []string
	warnings []string
}

pub fn pyenv_version_aliases(version string, strict bool) ![]string {
	parts := version.split('.')
	if parts.len < 3 {
		return error('Python version `${version}` must have major, minor, and patch components')
	}
	major := rbenv_numeric_component(parts[0])!
	minor := rbenv_numeric_component(parts[1])!
	patch := rbenv_numeric_component(parts[2])!
	start := if strict { patch } else { 0 }
	mut aliases := []string{}
	for patch_value in start .. patch + 1 {
		aliases << '${major}.${minor}.${patch_value}'
	}
	return aliases
}

pub fn link_pyenv_versions(installed InstalledPythonVersion, versions_path string, strict bool) !PyenvSyncResult {
	os.mkdir_all(versions_path)!
	parts := installed.version.split('.')
	if parts.len < 2 {
		return error('Python version `${installed.version}` must have a minor component')
	}
	minor := rbenv_numeric_component(parts[1])!
	mut result := PyenvSyncResult{}
	for alias in pyenv_version_aliases(installed.version, strict)! {
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
		for executable in pyenv_unversioned_executables {
			major_link_path := os.join_path(link_path, 'bin', executable)
			if os.exists(major_link_path) && !os.is_link(major_link_path) {
				result.skipped << major_link_path
				continue
			}
			executable_link_path := os.join_path(link_path, 'bin', '${executable}.${minor}')
			if os.is_link(major_link_path) {
				os.rm(major_link_path) or {
					result.warnings << 'Failed to remove ${major_link_path}: ${err.msg()}'
					continue
				}
			}
			os.symlink(executable_link_path, major_link_path) or {
				result.warnings << 'Failed to link ${executable_link_path} to ${major_link_path}: ${err.msg()}'
				continue
			}
			result.created << major_link_path
		}
	}
	return result
}

pub fn sync_pyenv_versions(pyenv_root string, installed []InstalledPythonVersion, strict bool) !PyenvSyncResult {
	running := os.join_path(pyenv_root, '.pyenv_sync_running')
	if os.exists(running) {
		return PyenvSyncResult{
			skipped_busy: true
		}
	}
	versions_path := os.join_path(pyenv_root, 'versions')
	os.mkdir_all(versions_path)!
	os.write_file(running, '')!
	defer {
		os.rm(running) or {}
	}
	mut result := PyenvSyncResult{}
	for python_version in installed {
		linked := link_pyenv_versions(python_version, versions_path, strict)!
		result.created << linked.created
		result.skipped << linked.skipped
		result.warnings << linked.warnings
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

pub fn installed_python_version_value(version InstalledPythonVersion) ruby.Value {
	return ruby.structured_value('InstalledPythonVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_python_version_from_value(value ruby.Value) InstalledPythonVersion {
	return InstalledPythonVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn pyenv_sync_result_value(result PyenvSyncResult) ruby.Value {
	return ruby.Value{
		type_name: 'PyenvSyncResult'
		repr: result.created.str()
		attributes: {
			'skipped_busy': result.skipped_busy.str()
		}
		map_data: {
			'created':  ruby.string_array_value(result.created)
			'skipped':  ruby.string_array_value(result.skipped)
			'removed':  ruby.string_array_value(result.removed)
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}
