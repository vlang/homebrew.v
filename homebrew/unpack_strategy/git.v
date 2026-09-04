module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/git.rb`.

pub fn git_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.git'))
}
