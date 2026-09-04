module extend

// Translated from Homebrew/brew `extend/os/linux/extend/pathname.rb`.
pub struct ElfShimPath {
pub:
	path string
}

pub fn wrap_elf_path(path string) ElfShimPath {
	return ElfShimPath{
		path: path
	}
}

// Ruby method `wrap(path)` at line 9.
pub fn ruby_pathname_l9_d1_wrap(path string) ElfShimPath {
	return wrap_elf_path(path)
}
