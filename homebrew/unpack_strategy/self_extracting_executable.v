module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/self_extracting_executable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_self_extracting_executable_l10_d1_self_extensions() []string {
	return self_extracting_executable_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_self_extracting_executable_l15_d2_self_can_extract(path string) bool {
	return self_extracting_executable_can_extract(path)
}

pub fn self_extracting_executable_extensions() []string {
	return []
}

pub fn self_extracting_executable_can_extract(path string) bool {
	if !file_starts_with(path, 'MZ'.bytes()) { return false }
	file := command_path('file') or { return false }
	result := ruby.run_command(file, ['-b', path])
	return result.exit_code == 0 && result.output.to_lower().contains('self-extracting archive')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "generic_unar"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking self-extracting executables.
// 8:   class SelfExtractingExecutable < GenericUnar
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       []
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\AMZ/n) &&
// 17:         path.file_type.include?("self-extracting archive")
// 18:     end
// 19:   end
// 20: end
