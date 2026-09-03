module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `unpack_strategy/zstd.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_zstd_l10_d1_self_extensions() []string {
	return zstd_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_zstd_l15_d2_self_can_extract(path string) bool {
	return zstd_can_extract(path)
}

// Ruby method `dependencies` at line 20.
pub fn ruby_zstd_l20_d3_dependencies() []string {
	return zstd_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 27.
pub fn ruby_zstd_l27_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	zstd_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn zstd_extensions() []string {
	return ['.zst']
}

pub fn zstd_can_extract(path string) bool {
	return file_prefix_contains(path, [u8(0x28), 0xb5, 0x2f, 0xfd])
}

pub fn zstd_dependencies() []string {
	return ['zstd']
}

pub fn zstd_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := brew_runtime.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut args := []string{}
	if !verbose { args << '-q' }
	args << ['-T0', '--rm', '--', target]
	unzstd := command_path('unzstd') or { command_path('zstd')! }
	if os.file_name(unzstd) == 'zstd' { args.prepend('-d') }
	checked_command(unzstd, args)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking zstd archives.
// 6:   class Zstd
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".zst"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\x28\xB5\x2F\xFD/n)
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Formula]) }
// 20:     def dependencies
// 21:       @dependencies ||= T.let([Formula["zstd"]], T.nilable(T::Array[Formula]))
// 22:     end
// 23:
// 24:     private
// 25:
// 26:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 27:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 28:       FileUtils.cp path, unpack_dir/basename, preserve: true
// 29:       quiet_flags = verbose ? [] : ["-q"]
// 30:       system_command! "unzstd",
// 31:                       args:    [*quiet_flags, "-T0", "--rm", "--", unpack_dir/basename],
// 32:                       env:     Utils::Path.formula_opt_bin_env("zstd"),
// 33:                       verbose:
// 34:     end
// 35:   end
// 36: end
