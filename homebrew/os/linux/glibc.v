module linux

import ruby
import homebrew

// Translated from Homebrew/brew `os/linux/glibc.rb`.
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
	result := ruby.run_command(program, ['--version'])
	return glibc_version_from_ldd_output(result.output)
}

pub fn system_glibc_version() homebrew.Version {
	return glibc_version_from_program('/usr/bin/ldd')
}

pub fn brewed_glibc_version() homebrew.Version {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	version := glibc_version_from_program(ruby.join_path(prefix, 'opt/glibc/bin/ldd'))
	return if version.is_null() { system_glibc_version() } else { version }
}

pub fn minimum_glibc_version() !homebrew.Version {
	value := ruby.environment_value('HOMEBREW_LINUX_MINIMUM_GLIBC_VERSION')
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
