module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/executable.rb`.

pub fn executable_extensions() []string {
	return ['.sh', '.bash']
}

pub fn executable_can_extract(path string) bool {
	bytes := read_file_prefix(path, 256) or { return false }
	if bytes.len >= 2 && bytes[..2] == [u8(`M`), `Z`] {
		return true
	}
	if bytes.len < 2 || bytes[..2] != [u8(`#`), `!`] {
		return false
	}
	mut index := 2
	for index < bytes.len && bytes[index].is_space() {
		index++
	}
	return index < bytes.len && !bytes[index].is_space()
}
