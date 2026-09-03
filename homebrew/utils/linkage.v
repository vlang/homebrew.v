module utils

import brew_runtime

// Translated from Homebrew/brew `utils/linkage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.binary_linked_to_library?(binary, library)` at line 9.
pub fn ruby_linkage_l9_d1_self_binary_linked_to_library(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(binary_linked_to_library(args[0].as_string(),
		args[1].as_string(), brew_runtime.environment_value('HOMEBREW_PREFIX')))
}

fn normalize_linkage_path(path string, prefix string) string {
	if prefix != '' && path.starts_with(prefix) && brew_runtime.path_exists(path) {
		return brew_runtime.real_path(path)
	}
	return path
}

pub fn dynamically_linked_libraries(binary string) []string {
	kernel := brew_runtime.kernel_info().name
	if kernel == 'Darwin' {
		result := brew_runtime.run_command('/usr/bin/otool', ['-L', binary])
		if result.exit_code != 0 {
			return []
		}
		return result.output.split_into_lines()[1..].map(it.trim_space().all_before(' (')).filter(it != '')
	}
	ldd := brew_runtime.find_executable('ldd') or { return [] }
	result := brew_runtime.run_command(ldd, [binary])
	if result.exit_code != 0 {
		return []
	}
	mut libraries := []string{}
	for line in result.output.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed == '' || trimmed.contains('not found') {
			continue
		}
		path := if trimmed.contains(' => ') {
			trimmed.all_after(' => ').all_before(' (').trim_space()
		} else {
			trimmed.all_before(' (').trim_space()
		}
		if path.starts_with('/') {
			libraries << path
		}
	}
	return libraries
}

pub fn binary_linked_to_library(binary string, library string, prefix string) bool {
	expected := normalize_linkage_path(library, prefix)
	return dynamically_linked_libraries(binary).any(normalize_linkage_path(it, prefix) == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # @api internal
// 6:   sig {
// 7:     params(binary: T.any(String, Pathname), library: T.any(String, Pathname)).returns(T::Boolean)
// 8:   }
// 9:   def self.binary_linked_to_library?(binary, library)
// 10:     library = library.to_s
// 11:     library = File.realpath(library) if library.start_with?(HOMEBREW_PREFIX.to_s)
// 12:
// 13:     binary_path = BinaryPathname.wrap(binary)
// 14:     binary_path.dynamically_linked_libraries.any? do |dll|
// 15:       dll = File.realpath(dll) if dll.start_with?(HOMEBREW_PREFIX.to_s)
// 16:       dll == library
// 17:     end
// 18:   end
// 19: end
