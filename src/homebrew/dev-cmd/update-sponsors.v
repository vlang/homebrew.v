module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/update-sponsors.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 27.
pub fn ruby_update_sponsors_l27_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `sponsor_name(sponsor)` at line 67.
pub fn ruby_update_sponsors_l67_d2_sponsor_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sponsor_name', ...args)
}

// Ruby method `sponsor_logo(sponsor)` at line 72.
pub fn ruby_update_sponsors_l72_d3_sponsor_logo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sponsor_logo', ...args)
}

// Ruby method `sponsor_url(sponsor)` at line 77.
pub fn ruby_update_sponsors_l77_d4_sponsor_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sponsor_url', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/github"
// 6: require "system_command"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class UpdateSponsors < AbstractCommand
// 11:       include SystemCommand::Mixin
// 12:
// 13:       NAMED_MONTHLY_AMOUNT = 100
// 14:       URL_MONTHLY_AMOUNT = 1000
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Update the list of GitHub Sponsors in the `Homebrew/brew` README.
// 19:         EOS
// 20:
// 21:         named_args :none
// 22:
// 23:         hide_from_man_page!
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         named_sponsors = []
// 29:         logo_sponsors = []
// 30:         largest_monthly_amount = T.let(0, Integer)
// 31:
// 32:         GitHub.sponsorships("Homebrew").each do |s|
// 33:           largest_monthly_amount = [s[:monthly_amount], s[:closest_tier_monthly_amount]].max
// 34:           if largest_monthly_amount >= NAMED_MONTHLY_AMOUNT
// 35:             named_sponsors << "[#{sponsor_name(s)}](#{sponsor_url(s)})"
// 36:           end
// 37:
// 38:           next if largest_monthly_amount < URL_MONTHLY_AMOUNT
// 39:
// 40:           logo_sponsors << "[![#{sponsor_name(s)}](#{sponsor_logo(s)})](#{sponsor_url(s)})"
// 41:         end
// 42:
// 43:         odie "No sponsorships amounts found! Ensure you have sufficient permissions!" if largest_monthly_amount.zero?
// 44:
// 45:         named_sponsors << "many other users and organisations via [GitHub Sponsors](https://github.com/sponsors/Homebrew)"
// 46:
// 47:         readme = HOMEBREW_REPOSITORY/"README.md"
// 48:         content = readme.read
// 49:         content.gsub!(/(Homebrew is generously supported by) .*\Z/m, "\\1 #{named_sponsors.to_sentence}.\n")
// 50:         content << "\n#{logo_sponsors.join}\n" if logo_sponsors.presence
// 51:
// 52:         File.write(readme, content)
// 53:
// 54:         diff = system_command "git", args: [
// 55:           "-C", HOMEBREW_REPOSITORY, "diff", "--exit-code", "README.md"
// 56:         ]
// 57:         if diff.status.success?
// 58:           ofail "No changes to list of sponsors."
// 59:         else
// 60:           puts "List of sponsors updated in the README."
// 61:         end
// 62:       end
// 63:
// 64:       private
// 65:
// 66:       sig { params(sponsor: T::Hash[Symbol, String]).returns(T.nilable(String)) }
// 67:       def sponsor_name(sponsor)
// 68:         sponsor[:name] || sponsor[:login]
// 69:       end
// 70:
// 71:       sig { params(sponsor: T::Hash[Symbol, String]).returns(String) }
// 72:       def sponsor_logo(sponsor)
// 73:         "https://github.com/#{sponsor[:login]}.png?size=64"
// 74:       end
// 75:
// 76:       sig { params(sponsor: T::Hash[Symbol, String]).returns(String) }
// 77:       def sponsor_url(sponsor)
// 78:         "https://github.com/#{sponsor[:login]}"
// 79:       end
// 80:     end
// 81:   end
// 82: end
