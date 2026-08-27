module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/update-maintainers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_update_maintainers_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/github"
// 6: require "manpages"
// 7: require "system_command"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class UpdateMaintainers < AbstractCommand
// 12:       include SystemCommand::Mixin
// 13:
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Update the list of maintainers in the `Homebrew/brew` README.
// 17:         EOS
// 18:
// 19:         named_args :none
// 20:
// 21:         hide_from_man_page!
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         # Needed for Manpages.regenerate_man_pages below
// 27:         Homebrew.install_bundler_gems!(groups: ["man"])
// 28:
// 29:         lead_maintainers = GitHub.members_by_team("Homebrew", "lead-maintainers")
// 30:         maintainers = GitHub.members_by_team("Homebrew", "maintainers")
// 31:                             .reject { |login, _| lead_maintainers.key?(login) }
// 32:         members = { lead_maintainers:, maintainers: }
// 33:
// 34:         sentences = {}
// 35:         members.each do |group, hash|
// 36:           hash.each { |login, name| hash[login] = "[#{name}](https://github.com/#{login})" }
// 37:           sentences[group] = hash.values.sort_by { |s| s.unicode_normalize(:nfd).gsub(/\P{L}+/, "") }.to_sentence
// 38:         end
// 39:
// 40:         readme = HOMEBREW_REPOSITORY/"README.md"
// 41:
// 42:         content = readme.read
// 43:         content.gsub!(/(Homebrew's \[Lead Maintainers.* (are|is)) .*\./,
// 44:                       "\\1 #{sentences[:lead_maintainers]}.")
// 45:         content.gsub!(/(Homebrew's other Maintainers (are|is)) .*\./,
// 46:                       "\\1 #{sentences[:maintainers]}.")
// 47:
// 48:         File.write(readme, content)
// 49:
// 50:         diff = system_command "git", args: ["-C", HOMEBREW_REPOSITORY, "diff", "--exit-code", "README.md"]
// 51:         if diff.status.success?
// 52:           ofail "No changes to list of maintainers."
// 53:         else
// 54:           Manpages.regenerate_man_pages(quiet: true)
// 55:           puts "List of maintainers updated in the README and the generated man pages."
// 56:         end
// 57:       end
// 58:     end
// 59:   end
// 60: end
