module utils

import brew_runtime

// Translated from Homebrew/brew `utils/tar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `available?` at line 17.
pub fn ruby_tar_l17_d1_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available?', ...args)
}

// Ruby method `executable` at line 22.
pub fn ruby_tar_l22_d2_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable', ...args)
}

// Ruby method `validate_file(path)` at line 31.
pub fn ruby_tar_l31_d3_validate_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_file', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/output"
// 6:
// 7: module Utils
// 8:   # Helper functions for interacting with tar files.
// 9:   module Tar
// 10:     class << self
// 11:       include SystemCommand::Mixin
// 12:       include Utils::Output::Mixin
// 13:
// 14:       TAR_FILE_EXTENSIONS = %w[.tar .tb2 .tbz .tbz2 .tgz .tlz .txz .tZ].freeze
// 15:
// 16:       sig { returns(T::Boolean) }
// 17:       def available?
// 18:         !!executable
// 19:       end
// 20:
// 21:       sig { returns(T.nilable(Pathname)) }
// 22:       def executable
// 23:         return @executable if defined?(@executable)
// 24:
// 25:         gnu_tar_gtar_path = HOMEBREW_PREFIX/"opt/gnu-tar/bin/gtar"
// 26:         gnu_tar_gtar = gnu_tar_gtar_path if gnu_tar_gtar_path.executable?
// 27:         @executable = T.let(which("gtar") || gnu_tar_gtar || which("tar"), T.nilable(Pathname))
// 28:       end
// 29:
// 30:       sig { params(path: T.any(Pathname, String)).void }
// 31:       def validate_file(path)
// 32:         return unless available?
// 33:
// 34:         path = Pathname.new(path)
// 35:         return unless TAR_FILE_EXTENSIONS.include? path.extname
// 36:
// 37:         stdout, _, status = system_command(T.must(executable), args:         ["--list", "--file", path],
// 38:                                                                print_stderr: false).to_a
// 39:         odie "#{path} is not a valid tar file!" if !status.success? || stdout.blank?
// 40:       end
// 41:     end
// 42:   end
// 43: end
