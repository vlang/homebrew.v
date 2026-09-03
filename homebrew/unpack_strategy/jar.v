module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/jar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_jar_l10_d1_self_extensions() []string {
	return jar_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_jar_l15_d2_self_can_extract(path string) bool {
	return jar_can_extract(path)
}

pub fn jar_extensions() []string {
	return ['.apk', '.jar']
}

pub fn jar_can_extract(path string) bool {
	if !zip_can_extract(path) { return false }
	members := zip_member_names(path) or { return false }
	return 'META-INF/MANIFEST.MF' in members
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking Java archives.
// 8:   class Jar < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".apk", ".jar"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       return false unless Zip.can_extract?(path)
// 17:
// 18:       # Check further if the ZIP is a JAR/WAR.
// 19:       path.zipinfo.include?("META-INF/MANIFEST.MF")
// 20:     end
// 21:   end
// 22: end
