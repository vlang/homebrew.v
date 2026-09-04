module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/jar.rb`.

pub fn jar_extensions() []string {
	return ['.apk', '.jar']
}

pub fn jar_can_extract(path string) bool {
	if !zip_can_extract(path) {
		return false
	}
	members := zip_member_names(path) or { return false }
	return 'META-INF/MANIFEST.MF' in members
}
