module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `unpack_strategy/bzip2.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_bzip2_l10_d1_self_extensions() []string {
	return bzip2_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_bzip2_l15_d2_self_can_extract(path string) bool {
	return bzip2_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_bzip2_l20_d3_dependencies() []string {
	return bzip2_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_bzip2_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	bzip2_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn bzip2_extensions() []string {
	return ['.bz2']
}

pub fn bzip2_can_extract(path string) bool {
	return file_starts_with(path, 'BZh'.bytes())
}

pub fn bzip2_dependencies() []string {
	// Formula resolution is not needed to identify the dependency. The typed
	// name lets the install layer resolve it once Formula is available.
	return ['bzip2']
}

pub fn bzip2_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := brew_runtime.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-d', target]
	checked_command(command_path('bzip2')!, arguments)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking bzip2 archives.
// 6:   class Bzip2
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".bz2"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\ABZh/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["bzip2"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       FileUtils.cp path, unpack_dir/basename, preserve: true
// 29:       quiet_flags = verbose ? [] : ["-q"]
// 30:       system_command! "bzip2",
// 31:                       args:    [*quiet_flags, "-d", unpack_dir/basename],
// 32:                       env:     Utils::Path.formula_opt_bin_env("bzip2", ORIGINAL_PATHS),
// 33:                       verbose:
// 34:     end
// 35:   end
// 36: end
