module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/cab.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_cab_l10_d1_self_extensions() []string {
	return cab_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_cab_l15_d2_self_can_extract(path string) bool {
	return cab_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_cab_l20_d3_dependencies() []string {
	return cab_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 25.
pub fn ruby_cab_l25_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	cab_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn cab_extensions() []string {
	return ['.cab']
}

pub fn cab_can_extract(path string) bool {
	return file_starts_with(path, 'MSCF'.bytes())
}

pub fn cab_dependencies() []string {
	return ['cabextract']
}

pub fn cab_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	cabextract := command_path('cabextract')!
	listing := checked_command(cabextract, ['-l', path])!
	mut members := []string{}
	for line in listing.output.split_into_lines() {
		fields := line.fields()
		if fields.len >= 3 && fields[0].bytes().all(it.is_digit()) {
			members << fields[2..].join(' ')
		}
	}
	validate_archive_members(members)!
	checked_command(cabextract, ['-d', unpack_dir, '--', path])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking Cabinet archives.
// 6:   class Cab
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".cab"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\AMSCF/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["cabextract"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 25:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 26:       system_command! "cabextract",
// 27:                       args:    ["-d", unpack_dir, "--", path],
// 28:                       env:     Utils::Path.formula_opt_bin_env("cabextract"),
// 29:                       verbose:
// 30:     end
// 31:   end
// 32: end
