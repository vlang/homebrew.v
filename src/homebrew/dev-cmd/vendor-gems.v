module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/vendor-gems.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 28.
pub fn ruby_vendor_gems_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `run_bundle(*args)` at line 97.
pub fn ruby_vendor_gems_l97_d2_run_bundle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_bundle', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/git"
// 6: require "fileutils"
// 7: require "utils/github"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class VendorGems < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Install and commit Homebrew's vendored gems.
// 15:         EOS
// 16:         comma_array "--update",
// 17:                     description: "Update the specified list of vendored gems to the latest version."
// 18:         switch "--no-commit",
// 19:                description: "Do not generate a new commit upon completion."
// 20:         switch "--non-bundler-gems",
// 21:                description: "Update vendored gems that aren't using Bundler.",
// 22:                hidden:      true
// 23:
// 24:         named_args :none
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         Homebrew.setup_gem_environment!
// 30:         ENV["PATH"] = (ENV.fetch("PATH").split(":") | ENV.fetch("HOMEBREW_PATH", "").split(":")).join(":")
// 31:         ENV["BUNDLE_WITH"] = Homebrew.valid_gem_groups.join(":")
// 32:
// 33:         ohai "cd #{HOMEBREW_LIBRARY_PATH}"
// 34:         HOMEBREW_LIBRARY_PATH.cd do
// 35:           if args.update
// 36:             ohai "bundle update"
// 37:             run_bundle "update", *args.update
// 38:
// 39:             unless args.no_commit?
// 40:               ohai "git add Gemfile.lock"
// 41:               system "git", "add", "Gemfile.lock"
// 42:             end
// 43:           end
// 44:
// 45:           ohai "bundle install --standalone"
// 46:           run_bundle "install", "--standalone"
// 47:
// 48:           if GitHub::Actions.env_set? && HOMEBREW_PREFIX.to_s == HOMEBREW_LINUX_DEFAULT_PREFIX
// 49:             ohai "chmod +t -R /home/linuxbrew/"
// 50:             system "sudo", "chmod", "+t", "-R", "/home/linuxbrew/"
// 51:           end
// 52:
// 53:           ohai "bundle pristine"
// 54:           run_bundle "pristine"
// 55:
// 56:           ohai "bundle clean"
// 57:           run_bundle "clean"
// 58:
// 59:           system "git", "add", "Gemfile.lock" unless args.no_commit?
// 60:
// 61:           if args.non_bundler_gems?
// 62:             %w[
// 63:               mechanize
// 64:             ].each do |gem|
// 65:               (HOMEBREW_LIBRARY_PATH/"vendor/gems").cd do
// 66:                 Pathname.glob("#{gem}-*/").each { |path| FileUtils.rm_r(path) }
// 67:               end
// 68:               ohai "gem install #{gem}"
// 69:               safe_system "gem", "install", gem, "--install-dir", "vendor",
// 70:                           "--no-document", "--no-wrappers", "--ignore-dependencies", "--force"
// 71:               (HOMEBREW_LIBRARY_PATH/"vendor/gems").cd do
// 72:                 source = Pathname.glob("#{gem}-*/").first
// 73:                 next unless source
// 74:
// 75:                 # We cannot use `#ln_sf` here because that has unintended consequences when
// 76:                 # the symlink we want to create exists and points to an existing directory.
// 77:                 FileUtils.rm_f gem
// 78:                 FileUtils.ln_s source, gem
// 79:               end
// 80:             end
// 81:           end
// 82:
// 83:           unless args.no_commit?
// 84:             ohai "git add vendor"
// 85:             system "git", "add", "vendor"
// 86:
// 87:             Utils::Git.set_name_email!
// 88:             Utils::Git.setup_gpg!
// 89:
// 90:             ohai "git commit"
// 91:             system "git", "commit", "--message", "brew vendor-gems: commit updates."
// 92:           end
// 93:         end
// 94:       end
// 95:
// 96:       sig { params(args: String).void }
// 97:       def run_bundle(*args)
// 98:         Process.wait(fork do
// 99:           # Native build scripts fail if EUID != UID
// 100:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 101:           exec "bundle", *args
// 102:         end)
// 103:
// 104:         raise ErrorDuringExecution.new(["bundle", *args], status: $CHILD_STATUS) unless $CHILD_STATUS.success?
// 105:       end
// 106:     end
// 107:   end
// 108: end
