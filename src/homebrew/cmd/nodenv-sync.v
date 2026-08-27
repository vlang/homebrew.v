module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/nodenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_nodenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `link_nodenv_versions(path, nodenv_versions)` at line 51.
pub fn ruby_nodenv_sync_l51_d2_link_nodenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link_nodenv_versions', ...args)
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
