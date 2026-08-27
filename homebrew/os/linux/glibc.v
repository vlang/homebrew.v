module linux

import brew_runtime

// Translated from Homebrew/brew `os/linux/glibc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `system_version` at line 11.
pub fn ruby_glibc_l11_d1_system_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_version', ...args)
}

// Ruby method `version` at line 24.
pub fn ruby_glibc_l24_d2_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `minimum_version` at line 37.
pub fn ruby_glibc_l37_d3_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minimum_version', ...args)
}

// Ruby method `below_minimum_version?` at line 42.
pub fn ruby_glibc_l42_d4_below_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('below_minimum_version?', ...args)
}

// Ruby method `below_ci_version?` at line 47.
pub fn ruby_glibc_l47_d5_below_ci_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('below_ci_version?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for querying `glibc` information.
// 7:     module Glibc
// 8:       module_function
// 9:
// 10:       sig { returns(Version) }
// 11:       def system_version
// 12:         @system_version ||= T.let(nil, T.nilable(Version))
// 13:         @system_version ||= begin
// 14:           version = Utils.popen_read("/usr/bin/ldd", "--version")[/ (\d+\.\d+)/, 1]
// 15:           if version
// 16:             Version.new version
// 17:           else
// 18:             Version::NULL
// 19:           end
// 20:         end
// 21:       end
// 22:
// 23:       sig { returns(Version) }
// 24:       def version
// 25:         @version ||= T.let(nil, T.nilable(Version))
// 26:         @version ||= begin
// 27:           version = Utils.popen_read(HOMEBREW_PREFIX/"opt/glibc/bin/ldd", "--version")[/ (\d+\.\d+)/, 1]
// 28:           if version
// 29:             Version.new version
// 30:           else
// 31:             system_version
// 32:           end
// 33:         end
// 34:       end
// 35:
// 36:       sig { returns(Version) }
// 37:       def minimum_version
// 38:         Version.new(ENV.fetch("HOMEBREW_LINUX_MINIMUM_GLIBC_VERSION"))
// 39:       end
// 40:
// 41:       sig { returns(T::Boolean) }
// 42:       def below_minimum_version?
// 43:         system_version < minimum_version
// 44:       end
// 45:
// 46:       sig { returns(T::Boolean) }
// 47:       def below_ci_version?
// 48:         system_version < LINUX_GLIBC_CI_VERSION
// 49:       end
// 50:     end
// 51:   end
// 52: end
