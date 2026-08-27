module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/pyenv-sync.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_pyenv_sync_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `link_pyenv_versions(path, pyenv_versions)` at line 50.
pub fn ruby_pyenv_sync_l50_d2_link_pyenv_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link_pyenv_versions', ...args)
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
