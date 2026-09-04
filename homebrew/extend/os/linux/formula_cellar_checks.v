module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/formula_cellar_checks.rb`.

pub fn valid_library_extension(filename string, base_valid bool) bool {
	return base_valid || filename.all_after_last('/').contains('.so.')
}
