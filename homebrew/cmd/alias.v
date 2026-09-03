module cmd

import homebrew.aliases

// Translated from Homebrew/brew `cmd/alias.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn run_alias(config aliases.AliasConfig, named ?string, edit bool,
	editor aliases.AliasEditor) ![]string {
	aliases.init_aliases(config)!
	if argument := named {
		mut name := argument
		mut command := ?string(none)
		if separator := argument.index('=') {
			name = argument[..separator]
			command = argument[separator + 1..]
		}
		if value := command {
			aliases.add_alias(config, name, value)!
			if edit {
				aliases.edit_alias(config, name, none, editor)!
			}
			return []string{}
		}
		if edit {
			aliases.edit_alias(config, name, none, editor)!
			return []string{}
		}
		return aliases.show_aliases(config, [name])
	}
	if edit {
		aliases.edit_all_aliases(config, editor)!
		return []string{}
	}
	return aliases.show_aliases(config, []string{})
}

// Ruby method `run` at line 23.
pub fn ruby_alias_l23_d1_run(config aliases.AliasConfig, named ?string, edit bool,
	editor aliases.AliasEditor) ![]string {
	return run_alias(config, named, edit, editor)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "aliases/aliases"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Alias < AbstractCommand
// 10:       cmd_args do
// 11:         usage_banner "`alias` [`--edit`] [<alias>|<alias>=<command>]"
// 12:         description <<~EOS
// 13:           Show an alias's command. If no alias is given, print the whole list.
// 14:         EOS
// 15:         switch "--edit",
// 16:                description: "Edit aliases in a text editor. Either one or all aliases may be opened at once. " \
// 17:                             "If the given alias doesn't exist it'll be pre-populated with a template."
// 18:
// 19:         named_args max: 1
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         name = args.named.first
// 25:         name, command = name.split("=", 2) if name.present?
// 26:
// 27:         Aliases.init
// 28:
// 29:         if name.nil?
// 30:           if args.edit?
// 31:             Aliases.edit_all
// 32:           else
// 33:             Aliases.show
// 34:           end
// 35:         elsif command.nil?
// 36:           if args.edit?
// 37:             Aliases.edit name
// 38:           else
// 39:             Aliases.show name
// 40:           end
// 41:         else
// 42:           Aliases.add name, command
// 43:           Aliases.edit name if args.edit?
// 44:         end
// 45:       end
// 46:     end
// 47:   end
// 48: end
