module homebrew

import brew_runtime

// Translated from Homebrew/brew `shell_command.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 11.
pub fn ruby_shell_command_l11_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	command_name := if args.len > 0 { args[0].as_string() } else { '' }
	dev_cmd := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	panic(shell_command_error(command_name, dev_cmd).msg())
}

// shell_command_error preserves the deliberate failure used by command classes
// that only exist so shell completions can discover them.
pub fn shell_command_error(command_name string, dev_cmd bool) IError {
	directory := if dev_cmd { 'dev-cmd' } else { 'cmd' }
	path := '${directory}/${command_name}.sh'
	return error('This command is just here for completions generation. It\'s actually defined in `${path}` instead.')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module ShellCommand
// 6:     extend T::Helpers
// 7:
// 8:     requires_ancestor { AbstractCommand }
// 9:
// 10:     sig { void }
// 11:     def run
// 12:       T.bind(self, AbstractCommand)
// 13:
// 14:       sh_cmd_path = "#{self.class.dev_cmd? ? "dev-cmd" : "cmd"}/#{self.class.command_name}.sh"
// 15:       raise StandardError,
// 16:             "This command is just here for completions generation. " \
// 17:             "It's actually defined in `#{sh_cmd_path}` instead."
// 18:     end
// 19:   end
// 20: end
