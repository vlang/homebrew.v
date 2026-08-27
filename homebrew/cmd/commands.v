module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/commands.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 23.
pub fn ruby_commands_l23_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class CommandsCmd < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Show lists of built-in and external commands.
// 12:         EOS
// 13:         switch "-q", "--quiet",
// 14:                description: "List only the names of commands without category headers."
// 15:         switch "--include-aliases",
// 16:                depends_on:  "--quiet",
// 17:                description: "Include aliases of internal commands."
// 18:
// 19:         named_args :none
// 20:       end
// 21:
// 22:       sig { override.void }
// 23:       def run
// 24:         if args.quiet?
// 25:           puts Formatter.columns(Commands.commands(aliases: args.include_aliases?))
// 26:           return
// 27:         end
// 28:
// 29:         prepend_separator = T.let(false, T::Boolean)
// 30:
// 31:         {
// 32:           "Built-in commands"           => Commands.internal_commands,
// 33:           "Built-in developer commands" => Commands.internal_developer_commands,
// 34:           "External commands"           => Commands.external_commands,
// 35:         }.each do |title, commands|
// 36:           next if commands.blank?
// 37:
// 38:           puts if prepend_separator
// 39:           ohai title, Formatter.columns(commands)
// 40:
// 41:           prepend_separator ||= true
// 42:         end
// 43:       end
// 44:     end
// 45:   end
// 46: end
