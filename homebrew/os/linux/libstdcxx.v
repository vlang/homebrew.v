module linux

import brew_runtime
import homebrew

// Translated from Homebrew/brew `os/linux/libstdcxx.rb`.
// The original source is retained below until every stub has a typed V body.
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
		candidate_path := brew_runtime.join_path(path, libstdcxx_soname)
		if !brew_runtime.path_exists(candidate_path) {
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
	prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
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
	real_basename := libstdcxx_basename(brew_runtime.real_path(library_path))
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

// Ruby attr_writer `attr_writer :system_version` at line 15.
pub fn ruby_libstdcxx_l15_d1_system_version(version ?homebrew.Version) ?homebrew.Version {
	return set_libstdcxx_system_version(version)
}

// Ruby method `self.below_ci_version?` at line 19.
pub fn ruby_libstdcxx_l19_d2_self_below_ci_version() bool {
	return libstdcxx_below_ci_version()
}

// Ruby method `self.system_version` at line 24.
pub fn ruby_libstdcxx_l24_d3_self_system_version() homebrew.Version {
	return system_libstdcxx_version()
}

// Ruby method `self.system_path` at line 34.
pub fn ruby_libstdcxx_l34_d4_self_system_path() ?string {
	return system_libstdcxx_path()
}

// Ruby method `self.find_library(paths)` at line 41.
pub fn ruby_libstdcxx_l41_d5_self_find_library(paths []string) ?string {
	return find_libstdcxx_library(paths, brew_runtime.environment_value('HOMEBREW_PREFIX'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/ld"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     # Helper functions for querying `libstdc++` information.
// 9:     module Libstdcxx
// 10:       SOVERSION = 6
// 11:       SONAME = T.let("libstdc++.so.#{SOVERSION}".freeze, String)
// 12:
// 13:       class << self
// 14:         sig { params(system_version: T.nilable(Version)).returns(T.nilable(Version)) }
// 15:         attr_writer :system_version
// 16:       end
// 17:
// 18:       sig { returns(T::Boolean) }
// 19:       def self.below_ci_version?
// 20:         system_version < LINUX_LIBSTDCXX_CI_VERSION
// 21:       end
// 22:
// 23:       sig { returns(Version) }
// 24:       def self.system_version
// 25:         @system_version ||= T.let(nil, T.nilable(Version))
// 26:         @system_version ||= if (path = system_path)
// 27:           Version.new("#{SOVERSION}#{path.realpath.basename.to_s.delete_prefix!(SONAME)}")
// 28:         else
// 29:           Version::NULL
// 30:         end
// 31:       end
// 32:
// 33:       sig { returns(T.nilable(::Pathname)) }
// 34:       def self.system_path
// 35:         @system_path ||= T.let(nil, T.nilable(::Pathname))
// 36:         @system_path ||= find_library(OS::Linux::Ld.library_paths(brewed: false))
// 37:         @system_path ||= find_library(OS::Linux::Ld.system_dirs(brewed: false))
// 38:       end
// 39:
// 40:       sig { params(paths: T::Array[String]).returns(T.nilable(::Pathname)) }
// 41:       private_class_method def self.find_library(paths)
// 42:         paths.each do |path|
// 43:           next if path.start_with?(HOMEBREW_PREFIX)
// 44:
// 45:           candidate = Pathname(path)/SONAME
// 46:           elf_candidate = ELFPathname.wrap(candidate)
// 47:           return candidate if candidate.exist? && elf_candidate.elf?
// 48:         end
// 49:         nil
// 50:       end
// 51:     end
// 52:   end
// 53: end
