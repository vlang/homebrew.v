module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/command-not-found-init.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_command_not_found_init_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `shell` at line 34.
pub fn ruby_command_not_found_init_l34_d2_shell(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shell', ...args)
}

// Ruby method `init` at line 39.
pub fn ruby_command_not_found_init_l39_d3_init(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('init', ...args)
}

// Ruby method `help` at line 51.
pub fn ruby_command_not_found_init_l51_d4_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('help', ...args)
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
