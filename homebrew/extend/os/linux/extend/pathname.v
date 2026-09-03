module extend

// Translated from Homebrew/brew `extend/os/linux/extend/pathname.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/elf"
// 5:
// 6: module ELFPathname
// 7:   module ClassMethods
// 8:     sig { params(path: T.any(Pathname, String, ELFShim)).returns(ELFShim) }
// 9:     def wrap(path)
// 10:       return path if path.is_a?(ELFShim)
// 11:
// 12:       path = ::Pathname.new(path)
// 13:       path.extend(ELFShim)
// 14:       T.cast(path, ELFShim)
// 15:     end
// 16:   end
// 17:
// 18:   extend ClassMethods
// 19: end
// 20:
// 21: BinaryPathname.singleton_class.prepend(ELFPathname::ClassMethods)
// 22: require "extend/os/linux/extend/pathname/os"
// 23:
// 24: Pathname.singleton_class.prepend(OS::Linux::Pathname::ClassMethods)
