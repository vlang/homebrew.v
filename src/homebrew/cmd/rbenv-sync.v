module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/rbenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_rbenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `link_rbenv_versions(path, rbenv_versions)` at line 51.
pub fn ruby_rbenv_sync_l51_d2_link_rbenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link_rbenv_versions', ...args)
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
