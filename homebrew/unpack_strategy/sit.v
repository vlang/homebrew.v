module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/sit.rb`.

pub fn sit_extensions() []string {
	return ['.sit']
}

pub fn sit_can_extract(path string) bool {
	return file_starts_with(path, 'StuffIt'.bytes())
}
