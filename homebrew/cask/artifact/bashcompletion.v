module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/bashcompletion.rb`.
pub fn resolve_bash_completion_target(target string, completion_directory string) string {
	extension := os.file_ext(target)
	name := if extension == '' {
		os.base(target)
	} else {
		os.base(target).trim_string_right(extension)
	}
	return ruby.join_path(completion_directory, name)
}

fn cask_artifact_prefix() string {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { '/opt/homebrew' } else { prefix }
}
