module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/executable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_executable_l10_d1_self_extensions() []string {
	return executable_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_executable_l15_d2_self_can_extract(path string) bool {
	return executable_can_extract(path)
}

pub fn executable_extensions() []string {
	return ['.sh', '.bash']
}

pub fn executable_can_extract(path string) bool {
	bytes := read_file_prefix(path, 256) or { return false }
	if bytes.len >= 2 && bytes[..2] == [u8(`M`), `Z`] { return true }
	if bytes.len < 2 || bytes[..2] != [u8(`#`), `!`] { return false }
	mut index := 2
	for index < bytes.len && bytes[index].is_space() {
		index++
	}
	return index < bytes.len && !bytes[index].is_space()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking executables.
// 8:   class Executable < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".sh", ".bash"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A#!\s*\S+/n) ||
// 17:         path.magic_number.match?(/\AMZ/n)
// 18:     end
// 19:   end
// 20: end
