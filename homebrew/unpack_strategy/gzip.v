module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/gzip.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_gzip_l10_d1_self_extensions() []string {
	return gzip_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_gzip_l15_d2_self_can_extract(path string) bool {
	return gzip_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 22.
pub fn ruby_gzip_l22_d3_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	gzip_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn gzip_extensions() []string {
	return ['.gz']
}

pub fn gzip_can_extract(path string) bool {
	return file_starts_with(path, [u8(0x1f), 0x8b])
}

pub fn gzip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-N', '--', target]
	checked_command(command_path('gunzip')!, arguments)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking gzip archives.
// 6:   class Gzip
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".gz"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\A\037\213/n)
// 17:     end
// 18:
// 19:     private
// 20:
// 21:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 22:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 23:       FileUtils.cp path, unpack_dir/basename, preserve: true
// 24:       quiet_flags = verbose ? [] : ["-q"]
// 25:       system_command! "gunzip",
// 26:                       args:    [*quiet_flags, "-N", "--", unpack_dir/basename],
// 27:                       verbose:
// 28:     end
// 29:   end
// 30: end
