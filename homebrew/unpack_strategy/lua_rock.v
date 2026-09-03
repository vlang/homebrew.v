module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/lua_rock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_lua_rock_l10_d1_self_extensions() []string {
	return lua_rock_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_lua_rock_l15_d2_self_can_extract(path string) bool {
	return lua_rock_can_extract(path)
}

pub fn lua_rock_extensions() []string {
	return ['.rock']
}

pub fn lua_rock_can_extract(path string) bool {
	if !zip_can_extract(path) { return false }
	for member in zip_member_names(path) or { return false } {
		if !member.contains('/') && member.ends_with('.rockspec') { return true }
	}
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "uncompressed"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking LuaRock archives.
// 8:   class LuaRock < Uncompressed
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".rock"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       return false unless Zip.can_extract?(path)
// 17:
// 18:       # Check further if the ZIP is a LuaRocks package.
// 19:       path.zipinfo.grep(%r{\A[^/]+.rockspec\Z}).any?
// 20:     end
// 21:   end
// 22: end
