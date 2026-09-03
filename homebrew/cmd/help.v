module cmd

// Translated from Homebrew/brew `cmd/help.rb`.
// The original source is retained below until every stub has a typed V body.
pub type HelpOutputRenderer = fn() !string

pub fn help_command_output(render HelpOutputRenderer) !string {
	return render()
}

// Ruby method `run` at line 20.
pub fn ruby_help_l20_d1_run(render HelpOutputRenderer) !string {
	return help_command_output(render)
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "help"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class HelpCmd < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Outputs the usage instructions for `brew` <command>.
// 13:           Equivalent to `brew --help` <command>.
// 14:         EOS
// 15:
// 16:         named_args [:command]
// 17:       end
// 18:
// 19:       sig { override.void }
// 20:       def run
// 21:         Help.help
// 22:       end
// 23:     end
// 24:   end
// 25: end
