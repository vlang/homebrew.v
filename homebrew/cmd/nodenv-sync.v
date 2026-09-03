module cmd

import brew_runtime
import os

// Translated from Homebrew/brew `cmd/nodenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn installed_node_version_value(version InstalledNodeVersion) brew_runtime.Value {
	return brew_runtime.structured_value('InstalledNodeVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_node_version_from_value(value brew_runtime.Value) InstalledNodeVersion {
	return InstalledNodeVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn nodenv_sync_result_value(result NodenvSyncResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NodenvSyncResult'
		repr: result.created.str()
		attributes: {
			'skipped_busy': result.skipped_busy.str()
		}
		map_data: {
			'created': brew_runtime.string_array_value(result.created)
			'skipped': brew_runtime.string_array_value(result.skipped)
			'removed': brew_runtime.string_array_value(result.removed)
		}
	}
}

// Ruby method `run` at line 23.
pub fn ruby_nodenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'nodenv-sync requires the nodenv root')
	}
	installed_values := if args.len > 1 {
		args[1].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := sync_nodenv_versions(args[0].as_string(), installed_values.map(installed_node_version_from_value(it)), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return nodenv_sync_result_value(result)
}

// Ruby method `link_nodenv_versions(path, nodenv_versions)` at line 51.
pub fn ruby_nodenv_sync_l51_d2_link_nodenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'link_nodenv_versions requires a Node version and versions path')
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := link_nodenv_versions(installed_node_version_from_value(args[0]), args[1].as_string(), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return nodenv_sync_result_value(result)
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
// 10:     class NodenvSync < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Create symlinks for Homebrew's installed NodeJS versions in `~/.nodenv/versions`.
// 14:
// 15:           Note that older version symlinks will also be created so e.g. NodeJS 19.1.0 will
// 16:           also be symlinked to 19.0.0.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         nodenv_root = Pathname(ENV.fetch("HOMEBREW_NODENV_ROOT", Pathname(Dir.home)/".nodenv"))
// 25:
// 26:         # Don't run multiple times at once.
// 27:         nodenv_sync_running = nodenv_root/".nodenv_sync_running"
// 28:         return if nodenv_sync_running.exist?
// 29:
// 30:         begin
// 31:           nodenv_versions = nodenv_root/"versions"
// 32:           nodenv_versions.mkpath
// 33:           FileUtils.touch nodenv_sync_running
// 34:
// 35:           HOMEBREW_CELLAR.glob("node{,@*}")
// 36:                          .flat_map(&:children)
// 37:                          .each { |path| link_nodenv_versions(path, nodenv_versions) }
// 38:
// 39:           nodenv_versions.children
// 40:                          .select(&:symlink?)
// 41:                          .reject(&:exist?)
// 42:                          .each { |path| FileUtils.rm_f path }
// 43:         ensure
// 44:           nodenv_sync_running.unlink if nodenv_sync_running.exist?
// 45:         end
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(path: Pathname, nodenv_versions: Pathname).void }
// 51:       def link_nodenv_versions(path, nodenv_versions)
// 52:         nodenv_versions.mkpath
// 53:
// 54:         version = Keg.new(path).version
// 55:         major_version = version.major.to_i
// 56:         minor_version = version.minor.to_i
// 57:         patch_version = version.patch.to_i
// 58:
// 59:         minor_version_range, patch_version_range = if Homebrew::EnvConfig.env_sync_strict?
// 60:           # Only create symlinks for the exact installed patch version.
// 61:           # e.g. 23.9.0 => 23.9.0
// 62:           [[minor_version], [patch_version]]
// 63:         else
// 64:           # Create folder symlinks for all patch versions to the latest patch version
// 65:           # e.g. 23.9.0 => 23.10.1
// 66:           [0..minor_version, 0..patch_version]
// 67:         end
// 68:
// 69:         minor_version_range.each do |minor|
// 70:           patch_version_range.each do |patch|
// 71:             link_path = nodenv_versions/"#{major_version}.#{minor}.#{patch}"
// 72:             # Don't clobber existing user installations.
// 73:             next if link_path.exist? && !link_path.symlink?
// 74:
// 75:             FileUtils.rm_f link_path
// 76:             FileUtils.ln_s path, link_path
// 77:           end
// 78:         end
// 79:       end
// 80:     end
// 81:   end
// 82: end
