module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/rar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_rar_l10_d1_self_extensions() []string {
	return rar_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_rar_l15_d2_self_can_extract(path string) bool {
	return rar_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_rar_l20_d3_dependencies() []string {
	return rar_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_rar_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	rar_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn rar_extensions() []string {
	return ['.rar']
}

pub fn rar_can_extract(path string) bool {
	return file_starts_with(path, 'Rar!'.bytes())
}

pub fn rar_dependencies() []string {
	return ['libarchive']
}

pub fn rar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	bsdtar := command_path('bsdtar') or { command_path('tar')! }
	members := archive_listing(bsdtar, ['-tf', path])!
	validate_archive_members(members)!
	checked_command(bsdtar, ['x', '-f', path, '-C', unpack_dir])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking RAR archives.
// 6:   class Rar
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".rar"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\ARar!/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["libarchive"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       system_command! "bsdtar",
// 29:                       args:    ["x", "-f", path, "-C", unpack_dir],
// 30:                       env:     Utils::Path.formula_opt_bin_env("libarchive"),
// 31:                       verbose:
// 32:     end
// 33:   end
// 34: end
