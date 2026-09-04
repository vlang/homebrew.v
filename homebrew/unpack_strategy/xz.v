module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/xz.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_xz_l10_d1_self_extensions() []string {
	return xz_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_xz_l15_d2_self_can_extract(path string) bool {
	return xz_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_xz_l20_d3_dependencies() []string {
	return xz_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_xz_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	xz_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn xz_extensions() []string {
	return ['.xz']
}

pub fn xz_can_extract(path string) bool {
	return file_starts_with(path, [u8(0xfd), 0x37, 0x7a, 0x58, 0x5a, 0x00])
}

pub fn xz_dependencies() []string {
	return ['xz']
}

pub fn xz_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-T0', '--', target]
	checked_command(command_path('unxz')!, arguments)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking xz archives.
// 6:   class Xz
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".xz"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A\xFD7zXZ\x00/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["xz"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       FileUtils.cp path, unpack_dir/basename, preserve: true
// 29:       quiet_flags = verbose ? [] : ["-q"]
// 30:       system_command! "unxz",
// 31:                       args:    [*quiet_flags, "-T0", "--", unpack_dir/basename],
// 32:                       env:     Utils::Path.formula_opt_bin_env("xz"),
// 33:                       verbose:
// 34:     end
// 35:   end
// 36: end
