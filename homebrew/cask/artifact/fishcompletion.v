module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/fishcompletion.rb`.
pub fn resolve_fish_completion_target(target string, completion_directory string) string {
	name := if target.ends_with('.fish') {
		target
	} else {
		'${os.base(target).trim_string_right(os.file_ext(target))}.fish'
	}
	return ruby.join_path(completion_directory, name)
}
