module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/pax.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_pax_l10_d1_self_extensions() []string {
	return pax_extensions()
}

// Ruby method `self.can_extract?(_path)` at line 15.
pub fn ruby_pax_l15_d2_self_can_extract(path string) bool {
	return pax_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 22.
pub fn ruby_pax_l22_d3_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	pax_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn pax_extensions() []string {
	return ['.pax']
}

pub fn pax_can_extract(path string) bool {
	_ = path
	return false
}

pub fn pax_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	pax := command_path('pax')!
	members := archive_listing(pax, ['-f', path])!
	validate_archive_members(members)!
	checked_command_in_directory(pax, ['-rf', path], unpack_dir)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking pax archives.
// 6:   class Pax
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".pax"]
// 12:     end
// 13:
// 14:     sig { override.params(_path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(_path)
// 16:       false
// 17:     end
// 18:
// 19:     private
// 20:
// 21:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 22:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 23:       system_command! "pax",
// 24:                       args:    ["-rf", path],
// 25:                       chdir:   unpack_dir,
// 26:                       verbose:
// 27:     end
// 28:   end
// 29: end
