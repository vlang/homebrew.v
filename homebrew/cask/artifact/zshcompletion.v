module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/zshcompletion.rb`.
pub fn resolve_zsh_completion_target(target string, completion_directory string) string {
	name := if target.starts_with('_') {
		target
	} else {
		'_${os.base(target).trim_string_right(os.file_ext(target))}'
	}
	return ruby.join_path(completion_directory, name)
}
