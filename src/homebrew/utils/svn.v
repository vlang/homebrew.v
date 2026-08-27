module utils

import brew_runtime

// Translated from Homebrew/brew `utils/svn.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `available?` at line 15.
pub fn ruby_svn_l15_d1_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available?', ...args)
}

// Ruby method `version` at line 20.
pub fn ruby_svn_l20_d2_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `remote_exists?(url)` at line 29.
pub fn ruby_svn_l29_d3_remote_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remote_exists?', ...args)
}

// Ruby method `invalid_cert_flags` at line 41.
pub fn ruby_svn_l41_d4_invalid_cert_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('invalid_cert_flags', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/output"
// 6:
// 7: module Utils
// 8:   # Helper functions for querying SVN information.
// 9:   module Svn
// 10:     class << self
// 11:       include SystemCommand::Mixin
// 12:       include Utils::Output::Mixin
// 13:
// 14:       sig { returns(T::Boolean) }
// 15:       def available?
// 16:         version.present?
// 17:       end
// 18:
// 19:       sig { returns(T.nilable(String)) }
// 20:       def version
// 21:         return @version if defined?(@version)
// 22:
// 23:         stdout, _, status = system_command(HOMEBREW_SHIMS_PATH/"shared/svn", args:         ["--version"],
// 24:                                                                              print_stderr: false).to_a
// 25:         @version = T.let(status.success? ? stdout.chomp[/svn, version (\d+(?:\.\d+)*)/, 1] : nil, T.nilable(String))
// 26:       end
// 27:
// 28:       sig { params(url: String).returns(T::Boolean) }
// 29:       def remote_exists?(url)
// 30:         return true unless available?
// 31:
// 32:         args = ["ls", url, "--depth", "empty"]
// 33:         _, stderr, status = system_command("svn", args:, print_stderr: false).to_a
// 34:         return !!status.success? unless stderr.include?("certificate verification failed")
// 35:
// 36:         # OK to unconditionally trust here because we're just checking if a URL exists.
// 37:         system_command("svn", args: args.concat(invalid_cert_flags), print_stderr: false).success?
// 38:       end
// 39:
// 40:       sig { returns(T::Array[String]) }
// 41:       def invalid_cert_flags
// 42:         opoo "Ignoring Subversion certificate errors!"
// 43:         args = ["--non-interactive", "--trust-server-cert"]
// 44:         if Version.new(version || "-1") >= Version.new("1.9")
// 45:           args << "--trust-server-cert-failures=expired,not-yet-valid"
// 46:         end
// 47:         args
// 48:       end
// 49:     end
// 50:   end
// 51: end
