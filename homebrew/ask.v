module homebrew

import ruby
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `ask.rb`.

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
	if !ruby.stdin_is_terminal() || !ruby.stdout_is_terminal() {
		return false
	}

	println(brew_utils.output_ohai('Do you want to proceed with the ${action}? [y/n]', [], brew_utils.current_output_options()))
	for {
		character := ruby.read_terminal_character() or {
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
