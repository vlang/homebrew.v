module cmd

import brew_runtime
import os

// Translated from Homebrew/brew `cmd/pyenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn installed_python_version_value(version InstalledPythonVersion) brew_runtime.Value {
	return brew_runtime.structured_value('InstalledPythonVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_python_version_from_value(value brew_runtime.Value) InstalledPythonVersion {
	return InstalledPythonVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn pyenv_sync_result_value(result PyenvSyncResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'PyenvSyncResult'
		repr: result.created.str()
		attributes: {
			'skipped_busy': result.skipped_busy.str()
		}
		map_data: {
			'created':  brew_runtime.string_array_value(result.created)
			'skipped':  brew_runtime.string_array_value(result.skipped)
			'removed':  brew_runtime.string_array_value(result.removed)
			'warnings': brew_runtime.string_array_value(result.warnings)
		}
	}
}

// Ruby method `run` at line 23.
pub fn ruby_pyenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'pyenv-sync requires the pyenv root')
	}
	installed_values := if args.len > 1 {
		args[1].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := sync_pyenv_versions(args[0].as_string(), installed_values.map(installed_python_version_from_value(it)), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return pyenv_sync_result_value(result)
}

// Ruby method `link_pyenv_versions(path, pyenv_versions)` at line 50.
pub fn ruby_pyenv_sync_l50_d2_link_pyenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'link_pyenv_versions requires a Python version and versions path')
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := link_pyenv_versions(installed_python_version_from_value(args[0]), args[1].as_string(), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return pyenv_sync_result_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "keg"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class PyenvSync < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Create symlinks for Homebrew's installed Python versions in `~/.pyenv/versions`.
// 14:
// 15:           Note that older patch version symlinks will be created and linked to the minor
// 16:           version so e.g. Python 3.11.0 will also be symlinked to 3.11.3.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         pyenv_root = Pathname(ENV.fetch("HOMEBREW_PYENV_ROOT", Pathname(Dir.home)/".pyenv"))
// 25:
// 26:         # Don't run multiple times at once.
// 27:         pyenv_sync_running = pyenv_root/".pyenv_sync_running"
// 28:         return if pyenv_sync_running.exist?
// 29:
// 30:         begin
// 31:           pyenv_versions = pyenv_root/"versions"
// 32:           pyenv_versions.mkpath
// 33:           FileUtils.touch pyenv_sync_running
// 34:           HOMEBREW_CELLAR.glob("python{,@*}")
// 35:                          .flat_map(&:children)
// 36:                          .each { |path| link_pyenv_versions(path, pyenv_versions) }
// 37:
// 38:           pyenv_versions.children
// 39:                         .select(&:symlink?)
// 40:                         .reject(&:exist?)
// 41:                         .each { |path| FileUtils.rm_f path }
// 42:         ensure
// 43:           pyenv_sync_running.unlink if pyenv_sync_running.exist?
// 44:         end
// 45:       end
// 46:
// 47:       private
// 48:
// 49:       sig { params(path: Pathname, pyenv_versions: Pathname).void }
// 50:       def link_pyenv_versions(path, pyenv_versions)
// 51:         pyenv_versions.mkpath
// 52:
// 53:         version = Keg.new(path).version
// 54:         major_version = version.major.to_i
// 55:         minor_version = version.minor.to_i
// 56:         patch_version = version.patch.to_i
// 57:
// 58:         patch_version_range = if Homebrew::EnvConfig.env_sync_strict?
// 59:           # Only create symlinks for the exact installed patch version.
// 60:           # e.g. 3.11.0 => 3.11.0
// 61:           [patch_version]
// 62:         else
// 63:           # Create folder symlinks for all patch versions to the latest patch version
// 64:           # e.g. 3.11.0 => 3.11.3
// 65:           0..patch_version
// 66:         end
// 67:
// 68:         patch_version_range.each do |patch|
// 69:           link_path = pyenv_versions/"#{major_version}.#{minor_version}.#{patch}"
// 70:
// 71:           # Don't clobber existing user installations.
// 72:           next if link_path.exist? && !link_path.symlink?
// 73:
// 74:           FileUtils.rm_f link_path
// 75:           FileUtils.ln_s path, link_path
// 76:
// 77:           # Create an unversioned symlinks
// 78:           # This is what pyenv expects to find in ~/.pyenv/versions/___/bin'.
// 79:           # Without this, `python3`, `pip3` do not exist and pyenv falls back to system Python.
// 80:           # (eg. python3 -> python3.11, pip3 -> pip3.11)
// 81:           executables = %w[python3 pip3 wheel3 idle3 pydoc3]
// 82:           executables.each do |executable|
// 83:             major_link_path = link_path/"bin/#{executable}"
// 84:
// 85:             # Don't clobber existing user installations.
// 86:             next if major_link_path.exist? && !major_link_path.symlink?
// 87:
// 88:             executable_link_path = link_path/"bin/#{executable}.#{minor_version}"
// 89:             FileUtils.rm_f major_link_path
// 90:
// 91:             begin
// 92:               FileUtils.ln_s executable_link_path, major_link_path
// 93:             rescue => e
// 94:               opoo "Failed to link #{executable_link_path} to #{major_link_path}: #{e}"
// 95:             end
// 96:           end
// 97:         end
// 98:       end
// 99:     end
// 100:   end
// 101: end
