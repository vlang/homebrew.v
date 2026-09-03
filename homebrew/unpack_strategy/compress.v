module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/compress.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_compress_l10_d1_self_extensions() []string {
	return compress_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_compress_l15_d2_self_can_extract(path string) bool {
	return compress_can_extract(path)
}

pub fn compress_extensions() []string {
	return ['.Z']
}

pub fn compress_can_extract(path string) bool {
	return file_starts_with(path, [u8(0x1f), 0x9d])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "tar"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking compress archives.
// 8:   class Compress < Tar
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".Z"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A\037\235/n)
// 17:     end
// 18:   end
// 19: end
