module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/otf.rb`.

pub fn otf_extensions() []string {
	return ['.otf']
}

pub fn otf_can_extract(path string) bool {
	return file_starts_with(path, 'OTTO'.bytes())
}
