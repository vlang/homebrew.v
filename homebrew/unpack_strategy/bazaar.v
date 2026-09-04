module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/bazaar.rb`.

pub fn bazaar_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.bzr'))
}

pub fn bazaar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	directory_extract_to_dir(path, unpack_dir, basename, verbose, false)!
	metadata := ruby.join_path(unpack_dir, '.bzr')
	if ruby.is_dir(metadata) { os.rmdir_all(metadata)! }
}
