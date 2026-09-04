module extend

// Translated from Homebrew/brew `extend/os/mac/extend/pathname.rb`.
pub struct MachOShimPath {
pub:
	path string
}

pub fn wrap_macho_path(path string) MachOShimPath {
	return MachOShimPath{
		path: path
	}
}

// Ruby method `wrap(path)` at line 9.
pub fn ruby_pathname_l9_d1_wrap(path string) MachOShimPath {
	return wrap_macho_path(path)
}
