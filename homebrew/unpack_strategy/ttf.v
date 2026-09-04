module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/ttf.rb`.

pub fn ttf_extensions() []string {
	return ['.ttc', '.ttf']
}

pub fn ttf_can_extract(path string) bool {
	return file_starts_with(path, [u8(0), 1, 0, 0, 0]) || file_starts_with(path, 'ttcf'.bytes())
}
