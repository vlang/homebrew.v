module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `unpack_strategy/uncompressed.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions = []` at line 10.
pub fn ruby_uncompressed_l10_d1_self_extensions() []string {
	return uncompressed_extensions()
}

// Ruby method `self.can_extract?(_path) = false` at line 13.
pub fn ruby_uncompressed_l13_d2_self_can_extract(path string) bool {
	return uncompressed_can_extract(path)
}

// Ruby method `extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)` at line 23.
pub fn ruby_uncompressed_l23_d3_extract_nestedly(strategy Strategy, options ExtractOptions) ! {
	strategy.extract(options)!
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose: false)` at line 30.
pub fn ruby_uncompressed_l30_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	uncompressed_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn uncompressed_extensions() []string {
	return []
}

pub fn uncompressed_can_extract(path string) bool {
	_ = path
	return false
}

pub fn uncompressed_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = verbose
	name := strip_download_digest(basename)
	if !safe_basename(name) {
		return error('unsafe uncompressed basename: ${basename}')
	}
	os.cp(path, brew_runtime.join_path(unpack_dir, name))!
}

fn strip_download_digest(name string) string {
	if name.len > 66 && name[64..66] == '--' {
		for byte in name[..64].bytes() {
			if !byte.is_hex_digit() || (byte >= `A` && byte <= `F`) {
				return name
			}
		}
		return name[66..]
	}
	return name
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking uncompressed files.
// 6:   class Uncompressed
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions = []
// 11:
// 12:     sig { override.params(_path: Pathname).returns(T::Boolean) }
// 13:     def self.can_extract?(_path) = false
// 14:
// 15:     sig {
// 16:       params(
// 17:         to:                   T.nilable(Pathname),
// 18:         basename:             T.nilable(T.any(String, Pathname)),
// 19:         verbose:              T::Boolean,
// 20:         prioritize_extension: T::Boolean,
// 21:       ).returns(T.untyped)
// 22:     }
// 23:     def extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)
// 24:       extract(to:, basename:, verbose:)
// 25:     end
// 26:
// 27:     private
// 28:
// 29:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 30:     def extract_to_dir(unpack_dir, basename:, verbose: false)
// 31:       FileUtils.cp path, unpack_dir/basename.sub(/^[\da-f]{64}--/, ""), preserve: true, verbose:
// 32:     end
// 33:   end
// 34: end
