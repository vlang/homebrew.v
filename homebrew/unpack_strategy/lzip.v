module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/lzip.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_lzip_l10_d1_self_extensions() []string {
	return lzip_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_lzip_l15_d2_self_can_extract(path string) bool {
	return lzip_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_lzip_l20_d3_dependencies() []string {
	return lzip_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_lzip_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	lzip_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn lzip_extensions() []string {
	return ['.lz']
}

pub fn lzip_can_extract(path string) bool {
	return file_starts_with(path, 'LZIP'.bytes())
}

pub fn lzip_dependencies() []string {
	return ['lzip']
}

pub fn lzip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut args := ['-d']
	if !verbose { args << '-q' }
	args << target
	checked_command(command_path('lzip')!, args)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking lzip archives.
// 6:   class Lzip
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".lz"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\ALZIP/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["lzip"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       FileUtils.cp path, unpack_dir/basename, preserve: true
// 29:       quiet_flags = verbose ? [] : ["-q"]
// 30:       system_command! "lzip",
// 31:                       args:    ["-d", *quiet_flags, unpack_dir/basename],
// 32:                       env:     Utils::Path.formula_opt_bin_env("lzip"),
// 33:                       verbose:
// 34:     end
// 35:   end
// 36: end
