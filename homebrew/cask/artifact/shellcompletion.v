module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/shellcompletion.rb`.

pub fn shell_completion_error() IError {
	return error('Shell completion without shell info')
}
