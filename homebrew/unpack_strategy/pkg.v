module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/pkg.rb`.

pub fn pkg_extensions() []string {
	return ['.pkg', '.mkpg']
}

pub fn pkg_can_extract(path string) bool {
	name := path.to_lower()
	return (name.ends_with('.pkg') || name.ends_with('.mpkg'))
		&& (ruby.is_dir(path) || file_starts_with(path, 'xar!'.bytes()))
}
