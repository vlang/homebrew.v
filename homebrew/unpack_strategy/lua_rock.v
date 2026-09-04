module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/lua_rock.rb`.

pub fn lua_rock_extensions() []string {
	return ['.rock']
}

pub fn lua_rock_can_extract(path string) bool {
	if !zip_can_extract(path) {
		return false
	}
	for member in zip_member_names(path) or { return false } {
		if !member.contains('/') && member.ends_with('.rockspec') {
			return true
		}
	}
	return false
}
