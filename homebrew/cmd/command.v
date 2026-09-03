module cmd

// Translated from Homebrew/brew `cmd/command.rb`.
// The original source is retained below until every stub has a typed V body.
pub type CommandPathResolver = fn(string) ?string

pub fn command_paths(commands []string, resolver CommandPathResolver) ![]string {
	mut paths := []string{cap: commands.len}
	for command in commands {
		path := resolver(command) or { return error('Unknown command: brew ${command}') }
		paths << path
	}
	return paths
}

// Ruby method `run` at line 19.
pub fn ruby_command_l19_d1_run(commands []string, resolver CommandPathResolver) ![]string {
	return command_paths(commands, resolver)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "commands"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Command < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Display the path to the file being used when invoking `brew` <cmd>.
// 13:         EOS
// 14:
// 15:         named_args :command, min: 1
// 16:       end
// 17:
// 18:       sig { override.void }
// 19:       def run
// 20:         args.named.each do |cmd|
// 21:           path = Commands.path(cmd)
// 22:           odie "Unknown command: brew #{cmd}" unless path
// 23:           puts path
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
