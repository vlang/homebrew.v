module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/compress.rb`.

pub fn compress_extensions() []string {
	return ['.Z']
}

pub fn compress_can_extract(path string) bool {
	return file_starts_with(path, [u8(0x1f), 0x9d])
}
