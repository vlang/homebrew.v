module linux

import brew_runtime

// Translated from Homebrew/brew `os/linux/libstdcxx.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :system_version` at line 15.
pub fn ruby_libstdcxx_l15_d1_system_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_version=', ...args)
}

// Ruby method `self.below_ci_version?` at line 19.
pub fn ruby_libstdcxx_l19_d2_self_below_ci_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.below_ci_version?', ...args)
}

// Ruby method `self.system_version` at line 24.
pub fn ruby_libstdcxx_l24_d3_self_system_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.system_version', ...args)
}

// Ruby method `self.system_path` at line 34.
pub fn ruby_libstdcxx_l34_d4_self_system_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.system_path', ...args)
}

// Ruby method `self.find_library(paths)` at line 41.
pub fn ruby_libstdcxx_l41_d5_self_find_library(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_library', ...args)
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
