module linux

import brew_runtime
import homebrew

// Translated from Homebrew/brew `os/linux/glibc.rb`.
// The original source is retained below until every stub has a typed V body.
pub const linux_glibc_ci_version = '2.39'

pub fn glibc_version_from_ldd_output(output string) homebrew.Version {
	for index in 0 .. output.len {
		if output[index] != ` ` || index + 3 >= output.len || !output[index + 1].is_digit() {
			continue
		}
		mut finish := index + 1
		for finish < output.len && output[finish].is_digit() {
			finish++
		}
		if finish >= output.len || output[finish] != `.` {
			continue
		}
		finish++
		minor_start := finish
		for finish < output.len && output[finish].is_digit() {
			finish++
		}
		if finish == minor_start {
			continue
		}
		return homebrew.new_version(output[index + 1..finish]) or { homebrew.null_version() }
	}
	return homebrew.null_version()
}

pub fn glibc_version_from_program(program string) homebrew.Version {
	result := brew_runtime.run_command(program, ['--version'])
	return glibc_version_from_ldd_output(result.output)
}

pub fn system_glibc_version() homebrew.Version {
	return glibc_version_from_program('/usr/bin/ldd')
}

pub fn brewed_glibc_version() homebrew.Version {
	prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
	version := glibc_version_from_program(brew_runtime.join_path(prefix, 'opt/glibc/bin/ldd'))
	return if version.is_null() { system_glibc_version() } else { version }
}

pub fn minimum_glibc_version() !homebrew.Version {
	value := brew_runtime.environment_value('HOMEBREW_LINUX_MINIMUM_GLIBC_VERSION')
	if value == '' {
		return error('HOMEBREW_LINUX_MINIMUM_GLIBC_VERSION is not set')
	}
	return homebrew.new_version(value)
}

pub fn glibc_below_minimum_version_for(system_version homebrew.Version,
	minimum_version homebrew.Version) bool {
	return system_version.compare_to(minimum_version) < 0
}

pub fn glibc_below_minimum_version() !bool {
	return glibc_below_minimum_version_for(system_glibc_version(), minimum_glibc_version()!)
}

pub fn glibc_below_ci_version_for(system_version homebrew.Version) bool {
	ci_version := homebrew.new_version(linux_glibc_ci_version) or { return false }
	return system_version.compare_to(ci_version) < 0
}

pub fn glibc_below_ci_version() bool {
	return glibc_below_ci_version_for(system_glibc_version())
}

// Ruby method `system_version` at line 11.
pub fn ruby_glibc_l11_d1_system_version() homebrew.Version {
	return system_glibc_version()
}

// Ruby method `version` at line 24.
pub fn ruby_glibc_l24_d2_version() homebrew.Version {
	return brewed_glibc_version()
}

// Ruby method `minimum_version` at line 37.
pub fn ruby_glibc_l37_d3_minimum_version() !homebrew.Version {
	return minimum_glibc_version()
}

// Ruby method `below_minimum_version?` at line 42.
pub fn ruby_glibc_l42_d4_below_minimum_version() !bool {
	return glibc_below_minimum_version()
}

// Ruby method `below_ci_version?` at line 47.
pub fn ruby_glibc_l47_d5_below_ci_version() bool {
	return glibc_below_ci_version()
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
