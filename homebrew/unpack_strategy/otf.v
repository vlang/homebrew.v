module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/otf.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_otf_l10_d1_self_extensions() []string {
	return otf_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_otf_l15_d2_self_can_extract(path string) bool {
	return otf_can_extract(path)
}

pub fn otf_extensions() []string {
	return ['.otf']
}

pub fn otf_can_extract(path string) bool {
	return file_starts_with(path, 'OTTO'.bytes())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking OpenType fonts.
// 8:   class Otf < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".otf"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\AOTTO/n)
// 17:     end
// 18:   end
// 19: end
