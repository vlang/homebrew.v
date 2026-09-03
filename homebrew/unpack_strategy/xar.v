module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/xar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_xar_l10_d1_self_extensions() []string {
	return xar_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_xar_l15_d2_self_can_extract(path string) bool {
	return xar_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 22.
pub fn ruby_xar_l22_d3_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	xar_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn xar_extensions() []string {
	return ['.xar']
}

pub fn xar_can_extract(path string) bool {
	return file_starts_with(path, 'xar!'.bytes())
}

pub fn xar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	xar := command_path('xar')!
	members := archive_listing(xar, ['-tf', path])!
	validate_archive_members(members)!
	checked_command(xar, ['-x', '-f', path, '-C', unpack_dir])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking xar archives.
// 6:   class Xar
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".xar"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\Axar!/n)
// 17:     end
// 18:
// 19:     private
// 20:
// 21:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 22:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 23:       system_command! "xar",
// 24:                       args:    ["-x", "-f", path, "-C", unpack_dir],
// 25:                       verbose:
// 26:     end
// 27:   end
// 28: end
