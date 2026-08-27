module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/install-bundler-gems.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 26.
pub fn ruby_install_bundler_gems_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class InstallBundlerGems < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Install Homebrew's Bundler gems.
// 12:         EOS
// 13:         comma_array "--groups",
// 14:                     description: "Installs the specified comma-separated list of gem groups (default: last used). " \
// 15:                                  "Replaces any previously installed groups."
// 16:         comma_array "--add-groups",
// 17:                     description: "Installs the specified comma-separated list of gem groups, " \
// 18:                                  "in addition to those already installed."
// 19:
// 20:         conflicts "--groups", "--add-groups"
// 21:
// 22:         named_args :none
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         groups = args.groups || args.add_groups || []
// 28:
// 29:         if groups.delete("all")
// 30:           groups |= Homebrew.valid_gem_groups
// 31:         elsif args.groups # if we have been asked to replace
// 32:           Homebrew.forget_user_gem_groups!
// 33:         end
// 34:
// 35:         Homebrew.install_bundler_gems!(groups:)
// 36:       end
// 37:     end
// 38:   end
// 39: end
