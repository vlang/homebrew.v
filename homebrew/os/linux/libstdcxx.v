module linux

import ruby
import homebrew

// Translated from Homebrew/brew `os/linux/libstdcxx.rb`.
pub const libstdcxx_soversion = 6
pub const libstdcxx_soname = 'libstdc++.so.6'
pub const linux_libstdcxx_ci_version = '6.0.33'

pub fn set_libstdcxx_system_version(version ?homebrew.Version) ?homebrew.Version {
	return version
}

pub fn libstdcxx_below_ci_version_for(version homebrew.Version) bool {
	ci_version := homebrew.new_version(linux_libstdcxx_ci_version) or { return false }
	return version.compare_to(ci_version) < 0
}

pub fn find_libstdcxx_library(paths []string, homebrew_prefix string) ?string {
	for path in paths {
		if homebrew_prefix != '' && path.starts_with(homebrew_prefix) {
			continue
		}
		candidate_path := ruby.join_path(path, libstdcxx_soname)
		if !ruby.path_exists(candidate_path) {
			continue
		}
		candidate := new_elf_path(candidate_path) or { continue }
		if candidate.is_elf() {
			return candidate_path
		}
	}
	return none
}

pub fn system_libstdcxx_path() ?string {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	if path := find_libstdcxx_library(ld_library_paths('ld.so.conf', false), prefix) {
		return path
	}
	return find_libstdcxx_library(ld_system_dirs(false), prefix)
}

fn libstdcxx_basename(path string) string {
	return path.trim_right('/').all_after_last('/')
}

pub fn libstdcxx_version_from_path(path ?string) homebrew.Version {
	library_path := path or { return homebrew.null_version() }
	real_basename := libstdcxx_basename(ruby.real_path(library_path))
	suffix := if real_basename.starts_with(libstdcxx_soname) {
		real_basename[libstdcxx_soname.len..]
	} else {
		''
	}
	return homebrew.new_version('${libstdcxx_soversion}${suffix}') or { homebrew.null_version() }
}

pub fn system_libstdcxx_version() homebrew.Version {
	return libstdcxx_version_from_path(system_libstdcxx_path())
}

pub fn libstdcxx_below_ci_version() bool {
	return libstdcxx_below_ci_version_for(system_libstdcxx_version())
}
