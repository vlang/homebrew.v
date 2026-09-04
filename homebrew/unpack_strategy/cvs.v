module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/cvs.rb`.

pub fn cvs_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, 'CVS'))
}
