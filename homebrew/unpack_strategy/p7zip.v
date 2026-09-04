module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/p7zip.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_p7zip_l10_d1_self_extensions() []string {
	return p7zip_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_p7zip_l15_d2_self_can_extract(path string) bool {
	return p7zip_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_p7zip_l20_d3_dependencies() []string {
	return p7zip_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_p7zip_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	p7zip_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn p7zip_extensions() []string {
	return ['.7z']
}

pub fn p7zip_can_extract(path string) bool {
	return file_starts_with(path, [u8(`7`), `z`, 0xbc, 0xaf, 0x27, 0x1c])
}

pub fn p7zip_dependencies() []string {
	return ['p7zip']
}

pub fn p7zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	seven_zip := command_path('7zr')!
	listing := checked_command(seven_zip, ['l', '-slt', '--', path])!
	mut members := []string{}
	for line in listing.output.split_into_lines() {
		if line.starts_with('Path = ') {
			member := line.all_after('Path = ').trim_space()
			if member != path && member != ruby.real_path(path) {
				members << member
			}
		}
	}
	validate_archive_members(members)!
	checked_command(seven_zip, ['x', '-y', '-bd', '-bso0', path, '-o${unpack_dir}'])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking P7ZIP archives.
// 6:   class P7Zip
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".7z"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A7z\xBC\xAF\x27\x1C/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["p7zip"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       system_command! "7zr",
// 29:                       args:    ["x", "-y", "-bd", "-bso0", path, "-o#{unpack_dir}"],
// 30:                       env:     Utils::Path.formula_opt_bin_env("p7zip"),
// 31:                       verbose:
// 32:     end
// 33:   end
// 34: end
