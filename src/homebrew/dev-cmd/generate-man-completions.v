module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-man-completions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 26.
pub fn ruby_generate_man_completions_l26_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "completions"
// 7: require "manpages"
// 8: require "system_command"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class GenerateManCompletions < AbstractCommand
// 13:       include SystemCommand::Mixin
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Generate Homebrew's manpages and shell completions.
// 18:         EOS
// 19:
// 20:         switch "--no-exit-code", description: "Exit with code 0 even if no changes were made."
// 21:
// 22:         named_args :none
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         Homebrew.install_bundler_gems!(groups: ["man"])
// 28:
// 29:         Commands.rebuild_internal_commands_completion_list
// 30:         Manpages.regenerate_man_pages(quiet: args.quiet?)
// 31:         Completions.update_shell_completions!
// 32:
// 33:         diff = system_command "git", args: [
// 34:           "-C", HOMEBREW_REPOSITORY,
// 35:           "diff", "--shortstat", "--patch", "--exit-code", "docs/Manpage.md", "manpages", "completions"
// 36:         ]
// 37:         status, message = if diff.status.success?
// 38:           [:failure, "No changes to manpage or completions."]
// 39:         elsif /1 file changed, 1 insertion\(\+\), 1 deletion\(-\).*-\.TH "BREW" "1" "\w+ \d+"/m.match?(diff.stdout)
// 40:           [:failure, "No changes to manpage or completions other than the date."]
// 41:         else
// 42:           [:success, "Manpage and completions updated."]
// 43:         end
// 44:
// 45:         if status == :failure && !args.no_exit_code?
// 46:           ofail message
// 47:         else
// 48:           puts message
// 49:         end
// 50:       end
// 51:     end
// 52:   end
// 53: end
