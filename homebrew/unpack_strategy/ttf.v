module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/ttf.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_ttf_l10_d1_self_extensions() []string {
	return ttf_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_ttf_l15_d2_self_can_extract(path string) bool {
	return ttf_can_extract(path)
}

pub fn ttf_extensions() []string {
	return ['.ttc', '.ttf']
}

pub fn ttf_can_extract(path string) bool {
	return file_starts_with(path, [u8(0), 1, 0, 0, 0]) || file_starts_with(path, 'ttcf'.bytes())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking TrueType fonts.
// 8:   class Ttf < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".ttc", ".ttf"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       # TrueType Font
// 17:       path.magic_number.match?(/\A\000\001\000\000\000/n) ||
// 18:         # Truetype Font Collection
// 19:         path.magic_number.match?(/\Attcf/n)
// 20:     end
// 21:   end
// 22: end
