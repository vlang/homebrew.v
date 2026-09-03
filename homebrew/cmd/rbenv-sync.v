module cmd

import brew_runtime
import os

// Translated from Homebrew/brew `cmd/rbenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn installed_ruby_version_value(version InstalledRubyVersion) brew_runtime.Value {
	return brew_runtime.structured_value('InstalledRubyVersion', version.path, {
		'path':    version.path
		'version': version.version
	})
}

fn installed_ruby_version_from_value(value brew_runtime.Value) InstalledRubyVersion {
	return InstalledRubyVersion{
		path: value.attribute('path') or { value.as_string() }
		version: value.attribute('version') or { '' }
	}
}

fn rbenv_sync_result_value(result RbenvSyncResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'RbenvSyncResult'
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
pub fn ruby_rbenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'rbenv-sync requires the rbenv root')
	}
	installed_values := if args.len > 1 {
		args[1].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := sync_rbenv_versions(args[0].as_string(), installed_values.map(installed_ruby_version_from_value(it)), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return rbenv_sync_result_value(result)
}

// Ruby method `link_rbenv_versions(path, rbenv_versions)` at line 51.
pub fn ruby_rbenv_sync_l51_d2_link_rbenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'link_rbenv_versions requires a Ruby and versions path')
	}
	strict := args.len > 2 && (args[2].as_bool() or { false })
	result := link_rbenv_versions(installed_ruby_version_from_value(args[0]), args[1].as_string(), strict) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return rbenv_sync_result_value(result)
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
// 10:     class RbenvSync < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Create symlinks for Homebrew's installed Ruby versions in `~/.rbenv/versions`.
// 14:
// 15:           Note that older version symlinks will also be created so e.g. Ruby 3.2.1 will
// 16:           also be symlinked to 3.2.0.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         rbenv_root = Pathname(ENV.fetch("HOMEBREW_RBENV_ROOT", Pathname(Dir.home)/".rbenv"))
// 25:
// 26:         # Don't run multiple times at once.
// 27:         rbenv_sync_running = rbenv_root/".rbenv_sync_running"
// 28:         return if rbenv_sync_running.exist?
// 29:
// 30:         begin
// 31:           rbenv_versions = rbenv_root/"versions"
// 32:           rbenv_versions.mkpath
// 33:           FileUtils.touch rbenv_sync_running
// 34:
// 35:           HOMEBREW_CELLAR.glob("ruby{,@*}")
// 36:                          .flat_map(&:children)
// 37:                          .each { |path| link_rbenv_versions(path, rbenv_versions) }
// 38:
// 39:           rbenv_versions.children
// 40:                         .select(&:symlink?)
// 41:                         .reject(&:exist?)
// 42:                         .each { |path| FileUtils.rm_f path }
// 43:         ensure
// 44:           rbenv_sync_running.unlink if rbenv_sync_running.exist?
// 45:         end
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(path: Pathname, rbenv_versions: Pathname).void }
// 51:       def link_rbenv_versions(path, rbenv_versions)
// 52:         rbenv_versions.mkpath
// 53:
// 54:         version = Keg.new(path).version
// 55:         major_version = version.major.to_i
// 56:         minor_version = version.minor.to_i
// 57:         patch_version = version.patch.to_i
// 58:
// 59:         patch_version_range = if Homebrew::EnvConfig.env_sync_strict?
// 60:           # Only create symlinks for the exact installed patch version.
// 61:           # e.g. 3.4.0 => 3.4.0
// 62:           [patch_version]
// 63:         else
// 64:           # Create folder symlinks for all patch versions to the latest patch version
// 65:           # e.g. 3.4.0 => 3.4.2
// 66:           0..patch_version
// 67:         end
// 68:
// 69:         patch_version_range.each do |patch|
// 70:           link_path = rbenv_versions/"#{major_version}.#{minor_version}.#{patch}"
// 71:           # Don't clobber existing user installations.
// 72:           next if link_path.exist? && !link_path.symlink?
// 73:
// 74:           FileUtils.rm_f link_path
// 75:           FileUtils.ln_s path, link_path
// 76:         end
// 77:       end
// 78:     end
// 79:   end
// 80: end
