module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/command-not-found-init.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct CommandNotFoundInitOptions {
pub:
	stdout_tty      bool
	parent_shell    string
	preferred_shell string
	handler_sh      string
	handler_fish    string
}

pub struct CommandNotFoundInitResult {
pub:
	shell  string
	mode   string
	stdout string
}

pub fn command_not_found_shell(parent_shell string, preferred_shell string) string {
	return if parent_shell.len > 0 { parent_shell } else { preferred_shell }
}

pub fn command_not_found_init_output(shell string, handler_sh string, handler_fish string) !string {
	return match shell {
		'bash', 'zsh' { if handler_sh.ends_with('\n') { handler_sh } else { '${handler_sh}\n' } }
		'fish' { if handler_fish.ends_with('\n') { handler_fish } else { '${handler_fish}\n' } }
		else { return error('Unsupported shell type ${shell}') }
	}
}

pub fn command_not_found_help_output(shell string) !string {
	return match shell {
		'bash', 'zsh' {
			'# To enable command-not-found\n# Add the following lines to ~/.${shell}rc\n\nHOMEBREW_COMMAND_NOT_FOUND_HANDLER="\$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"\nif [ -f "\$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then\n  source "\$HOMEBREW_COMMAND_NOT_FOUND_HANDLER";\nfi\n'
		}
		'fish' {
			'# To enable command-not-found\n# Add the following line to ~/.config/fish/config.fish\n\nset HOMEBREW_COMMAND_NOT_FOUND_HANDLER (brew --repository)/Library/Homebrew/command-not-found/handler.fish\nif test -f \$HOMEBREW_COMMAND_NOT_FOUND_HANDLER\n  source \$HOMEBREW_COMMAND_NOT_FOUND_HANDLER\nend\n'
		}
		else { return error('Unsupported shell type ${shell}') }
	}
}

pub fn run_command_not_found_init(options CommandNotFoundInitOptions) !CommandNotFoundInitResult {
	shell := command_not_found_shell(options.parent_shell, options.preferred_shell)
	if options.stdout_tty {
		return CommandNotFoundInitResult{
			shell: shell
			mode: 'help'
			stdout: command_not_found_help_output(shell)!
		}
	}
	return CommandNotFoundInitResult{
		shell: shell
		mode: 'init'
		stdout: command_not_found_init_output(shell, options.handler_sh, options.handler_fish)!
	}
}

@[heap]
pub struct CommandNotFoundInitInput {
pub:
	options CommandNotFoundInitOptions
}

pub fn command_not_found_init_input_boundary(input &CommandNotFoundInitInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::CommandNotFoundInit::Input', '', {
		'command_not_found_init_input_address': u64(voidptr(input)).str()
	})
}

fn command_not_found_init_input_from_value(value brew_runtime.Value) &CommandNotFoundInitInput {
	address := value.attributes['command_not_found_init_input_address'] or {
		panic('invalid CommandNotFoundInit input')
	}
	return unsafe { &CommandNotFoundInitInput(voidptr(address.u64())) }
}

fn command_not_found_init_result_value(result CommandNotFoundInitResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'shell': brew_runtime.object_value('Symbol', result.shell)
		'mode': brew_runtime.object_value('Symbol', result.mode)
		'stdout': brew_runtime.string_value(result.stdout)
	})
}

// Ruby method `run` at line 25.
pub fn ruby_command_not_found_init_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return command_not_found_init_result_value(run_command_not_found_init(command_not_found_init_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	})
}

// Ruby method `shell` at line 34.
pub fn ruby_command_not_found_init_l34_d2_shell(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := command_not_found_init_input_from_value(args[0]).options
	shell := command_not_found_shell(options.parent_shell, options.preferred_shell)
	return if shell.len > 0 {
		brew_runtime.object_value('Symbol', shell)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
}

// Ruby method `init` at line 39.
pub fn ruby_command_not_found_init_l39_d3_init(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := command_not_found_init_input_from_value(args[0]).options
	shell := command_not_found_shell(options.parent_shell, options.preferred_shell)
	return brew_runtime.string_value(command_not_found_init_output(shell, options.handler_sh,
		options.handler_fish) or { return brew_runtime.object_value('RuntimeError', err.msg()) })
}

// Ruby method `help` at line 51.
pub fn ruby_command_not_found_init_l51_d4_help(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := command_not_found_init_input_from_value(args[0]).options
	shell := command_not_found_shell(options.parent_shell, options.preferred_shell)
	return brew_runtime.string_value(command_not_found_help_output(shell) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # License: MIT
// 5: # The license text can be found in Library/Homebrew/command-not-found/LICENSE
// 6:
// 7: require "abstract_command"
// 8: require "utils/shell"
// 9:
// 10: module Homebrew
// 11:   module Cmd
// 12:     class CommandNotFoundInit < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Print instructions for setting up the command-not-found hook for your shell.
// 16:           If the output is not to a tty, print the appropriate handler script for your shell.
// 17:
// 18:           For more information, see:
// 19:             https://docs.brew.sh/Command-Not-Found
// 20:         EOS
// 21:         named_args :none
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         if $stdout.tty?
// 27:           help
// 28:         else
// 29:           init
// 30:         end
// 31:       end
// 32:
// 33:       sig { returns(T.nilable(Symbol)) }
// 34:       def shell
// 35:         Utils::Shell.parent || Utils::Shell.preferred
// 36:       end
// 37:
// 38:       sig { void }
// 39:       def init
// 40:         case shell
// 41:         when :bash, :zsh
// 42:           puts File.read(File.expand_path("#{File.dirname(__FILE__)}/../command-not-found/handler.sh"))
// 43:         when :fish
// 44:           puts File.read(File.expand_path("#{File.dirname(__FILE__)}/../command-not-found/handler.fish"))
// 45:         else
// 46:           raise "Unsupported shell type #{shell}"
// 47:         end
// 48:       end
// 49:
// 50:       sig { void }
// 51:       def help
// 52:         case shell
// 53:         when :bash, :zsh
// 54:           puts <<~EOS
// 55:             # To enable command-not-found
// 56:             # Add the following lines to ~/.#{shell}rc
// 57:
// 58:             HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"
// 59:             if [ -f "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then
// 60:               source "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER";
// 61:             fi
// 62:           EOS
// 63:         when :fish
// 64:           puts <<~EOS
// 65:             # To enable command-not-found
// 66:             # Add the following line to ~/.config/fish/config.fish
// 67:
// 68:             set HOMEBREW_COMMAND_NOT_FOUND_HANDLER (brew --repository)/Library/Homebrew/command-not-found/handler.fish
// 69:             if test -f $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
// 70:               source $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
// 71:             end
// 72:           EOS
// 73:         else
// 74:           raise "Unsupported shell type #{shell}"
// 75:         end
// 76:       end
// 77:     end
// 78:   end
// 79: end
