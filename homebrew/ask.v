module homebrew

import brew_runtime
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `ask.rb`.
// The original source is retained below until every stub has a typed V body.

pub enum ConfirmationKeyAction {
	accept
	cancel
	retry
}

// confirmation_key_action translates the normalization and key selection in
// lines 24-31 independently of terminal I/O so every source branch is directly
// testable.
pub fn confirmation_key_action(character int) ConfirmationKeyAction {
	if character < 0 || character in [3, 4, 27] {
		return .cancel
	}
	key := rune(character).str().trim_space().to_lower()
	return match key {
		'y' { .accept }
		'n' { .cancel }
		else { .retry }
	}
}

pub fn confirm(action string) !bool {
	if !brew_runtime.stdin_is_terminal() || !brew_runtime.stdout_is_terminal() {
		return false
	}

	println(brew_utils.output_ohai('Do you want to proceed with the ${action}? [y/n]', [],
		brew_utils.current_output_options()))
	for {
		character := brew_runtime.read_terminal_character() or {
			return error('confirmation aborted')
		}
		match confirmation_key_action(character) {
			.accept {
				return true
			}
			.cancel {
				return error('confirmation aborted')
			}
			.retry {
				println("Invalid input. Please press 'y' to proceed, or 'n' to abort.")
			}
		}
	}
	return false
}

// Ruby method `self.confirm?(action:)` at line 12.
pub fn ruby_ask_l12_d1_self_confirm(args ...brew_runtime.Value) brew_runtime.Value {
	action := if args.len > 0 { args[0].as_string() } else { '' }
	confirmed := confirm(action) or {
		return brew_runtime.structured_value('SystemExit', err.msg(), {
			'exit_code': '1'
		})
	}
	return brew_runtime.bool_value(confirmed)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "io/console"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   module Ask
// 9:     extend Utils::Output::Mixin
// 10:
// 11:     sig { params(action: String).returns(T::Boolean) }
// 12:     def self.confirm?(action:)
// 13:       return false if !$stdin.tty? || !$stdout.tty?
// 14:
// 15:       ohai "Do you want to proceed with the #{action}? [y/n]"
// 16:       loop do
// 17:         result = begin
// 18:           $stdin.getch
// 19:         rescue Interrupt
// 20:           exit 1
// 21:         end
// 22:         exit 1 unless result
// 23:
// 24:         result = result.chomp.strip.downcase
// 25:         if result == "y"
// 26:           return true
// 27:         # N, Escape, Ctrl-C and Ctrl-D.
// 28:         elsif ["n", "\e", "\u0003", "\u0004"].include?(result)
// 29:           exit 1
// 30:         else
// 31:           puts "Invalid input. Please press 'y' to proceed, or 'n' to abort."
// 32:         end
// 33:       end
// 34:     end
// 35:   end
// 36: end
