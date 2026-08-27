module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/lgtm.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_lgtm_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "tap"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Lgtm < AbstractCommand
// 10:       include SystemCommand::Mixin
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Run `brew typecheck`, `brew style --changed` and the relevant `brew tests`,
// 15:           `brew audit` and `brew test` checks in one go.
// 16:         EOS
// 17:         switch "--online",
// 18:                description: "Run additional, slower checks that require a network connection."
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         Homebrew.install_bundler_gems!(groups: Homebrew.valid_gem_groups - ["sorbet"])
// 25:
// 26:         tap = Tap.from_path(Dir.pwd)
// 27:
// 28:         typecheck_args = ["typecheck", tap&.name].compact
// 29:         ohai "brew #{typecheck_args.join(" ")}"
// 30:         safe_system HOMEBREW_BREW_FILE, *typecheck_args
// 31:         puts
// 32:
// 33:         ohai "brew style --changed --fix"
// 34:         safe_system HOMEBREW_BREW_FILE, "style", "--changed", "--fix"
// 35:         puts
// 36:
// 37:         if tap
// 38:           added_files = Utils.popen_read("git", "diff", "--name-only", "--no-relative", "--diff-filter=A", "main")
// 39:                              .split("\n")
// 40:           changed_formulae = []
// 41:           new_formulae = []
// 42:           changed_casks = []
// 43:           new_casks = []
// 44:           changed_audit_args = ["--strict"]
// 45:           changed_audit_args << "--online" if args.online?
// 46:           new_audit_args = args.online? ? ["--new"] : ["--strict"]
// 47:
// 48:           Utils.popen_read("git", "diff", "--name-only", "--no-relative", "--diff-filter=AMR", "main")
// 49:                .split("\n").each do |file|
// 50:             next if file.blank?
// 51:
// 52:             tapped_name = "#{tap.name}/#{Pathname(file).basename(".rb")}"
// 53:
// 54:             if tap.formula_file?(file)
// 55:               (added_files.include?(file) ? new_formulae : changed_formulae) << tapped_name
// 56:             elsif tap.cask_file?(file)
// 57:               (added_files.include?(file) ? new_casks : changed_casks) << tapped_name
// 58:             end
// 59:           end
// 60:
// 61:           if Utils.popen_read("git", "ls-files", "--others", "--exclude-standard", "--full-name")
// 62:                   .split("\n")
// 63:                   .any? { |file| tap.formula_file?(file) || tap.cask_file?(file) }
// 64:             opoo "Untracked formula or cask files are not checked by `brew lgtm`; stage or commit them first."
// 65:           end
// 66:
// 67:           if !args.online? && [*new_formulae, *new_casks].present?
// 68:             opoo "New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks."
// 69:           end
// 70:
// 71:           unless changed_formulae.empty?
// 72:             ohai "brew audit #{changed_audit_args.join(" ")} --skip-style --formula #{changed_formulae.join(" ")}"
// 73:             safe_system HOMEBREW_BREW_FILE, "audit", *changed_audit_args, "--skip-style", "--formula",
// 74:                         *changed_formulae
// 75:             puts
// 76:           end
// 77:
// 78:           unless new_formulae.empty?
// 79:             ohai "brew audit #{new_audit_args.join(" ")} --skip-style --formula #{new_formulae.join(" ")}"
// 80:             safe_system HOMEBREW_BREW_FILE, "audit", *new_audit_args, "--skip-style", "--formula", *new_formulae
// 81:             puts
// 82:           end
// 83:
// 84:           unless changed_casks.empty?
// 85:             ohai "brew audit #{changed_audit_args.join(" ")} --skip-style --cask #{changed_casks.join(" ")}"
// 86:             safe_system HOMEBREW_BREW_FILE, "audit", *changed_audit_args, "--skip-style", "--cask", *changed_casks
// 87:             puts
// 88:           end
// 89:
// 90:           unless new_casks.empty?
// 91:             ohai "brew audit #{new_audit_args.join(" ")} --skip-style --cask #{new_casks.join(" ")}"
// 92:             safe_system HOMEBREW_BREW_FILE, "audit", *new_audit_args, "--skip-style", "--cask", *new_casks
// 93:             puts
// 94:           end
// 95:
// 96:           formulae_to_test = [*changed_formulae, *new_formulae].select do |formula_name|
// 97:             next true if Formulary.factory(formula_name).latest_version_installed?
// 98:
// 99:             opoo "Skipping `brew test #{formula_name}`; the latest version is not installed."
// 100:             false
// 101:           end
// 102:           return if formulae_to_test.empty?
// 103:
// 104:           ohai "brew test #{formulae_to_test.join(" ")}"
// 105:           safe_system HOMEBREW_BREW_FILE, "test", *formulae_to_test
// 106:         else
// 107:           audit_or_tests_args = ["--changed"]
// 108:           audit_or_tests_args << "--online" if args.online?
// 109:           ohai "brew tests #{audit_or_tests_args.join(" ")}"
// 110:           safe_system HOMEBREW_BREW_FILE, "tests", *audit_or_tests_args
// 111:         end
// 112:       end
// 113:     end
// 114:   end
// 115: end
