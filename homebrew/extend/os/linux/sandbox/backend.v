module sandbox

import homebrew
import os

// Translated from Homebrew/brew `extend/os/linux/sandbox/backend.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `full_write_isolation? = true` at line 10.
pub struct LinuxBackend {
pub mut:
	profile                 homebrew.SandboxProfile
	prepared_writable_paths []string
}

pub fn ruby_backend_l10_d1_full_write_isolation() bool {
	return true
}

// Ruby method `initialize(profile)` at line 14.
pub fn backend_initialize(profile homebrew.SandboxProfile) LinuxBackend {
	return LinuxBackend{ profile: profile }
}

// Ruby method `run(&block)` at line 20.
pub fn backend_run(mut backend LinuxBackend) {
	for path in backend.prepared_writable_paths.reverse() {
		if os.is_dir(path) { os.rmdir(path) or {} }
	}
	backend.prepared_writable_paths.clear()
}

// Ruby attr_reader `attr_reader :profile` at line 34.
pub fn ruby_backend_l34_d4_profile(backend LinuxBackend) homebrew.SandboxProfile {
	return backend.profile
}

// Ruby method `writable_paths` at line 39.
pub fn backend_writable_paths(backend LinuxBackend) !map[string]homebrew.SandboxFilterType {
	mut paths := map[string]homebrew.SandboxFilterType{}
	for rule in backend.profile.rules {
		if !rule.allow || !rule.operation.starts_with('file-write') || !rule.has_filter {
			continue
		}
		match rule.filter.type_name {
			.literal, .subpath {
				if rule.filter.path !in paths {
					paths[rule.filter.path] = rule.filter.type_name
				}
			}
			.regex {
				return error('Linux sandbox does not support regex path filters: ${rule.filter.path}')
			}
		}
	}
	return paths
}

// Ruby method `profile_paths(allow:, operation:)` at line 58.
pub fn backend_profile_paths(backend LinuxBackend, allow bool, operation string) []string {
	mut result := []string{}
	for rule in backend.profile.rules {
		if rule.allow != allow || !rule.operation.starts_with(operation) || !rule.has_filter || rule.filter.type_name == .regex {
			continue
		}
		if rule.filter.path !in result { result << rule.filter.path }
	}
	return result
}

// Ruby method `deny_all_network?` at line 68.
pub fn backend_deny_all_network(backend LinuxBackend) bool {
	return backend.profile.rules.any(!it.allow && it.operation == 'network*' && !it.has_filter)
}

// Ruby method `prepare_writable_path(path, type)` at line 75.
pub fn backend_prepare_writable_path(mut backend LinuxBackend, path string, type_name homebrew.SandboxFilterType) ! {
	if os.exists(path) {
		return
	}
	if type_name == .literal {
		os.mkdir_all(os.dir(path))!
		os.write_file(path, '')!
	} else {
		os.mkdir_all(path)!
		backend.prepared_writable_paths << path
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5:
// 6: class Sandbox
// 7:   class LinuxBackend
// 8:     class << self
// 9:       sig { returns(T::Boolean) }
// 10:       def full_write_isolation? = true
// 11:     end
// 12:
// 13:     sig { params(profile: SandboxProfile).void }
// 14:     def initialize(profile)
// 15:       @profile = profile
// 16:       @prepared_writable_paths = T.let([], T::Array[::Pathname])
// 17:     end
// 18:
// 19:     sig { params(block: T.proc.void).void }
// 20:     def run(&block)
// 21:       yield
// 22:     ensure
// 23:       @prepared_writable_paths.reverse_each do |path|
// 24:         path.rmdir if path.directory?
// 25:       rescue Errno::ENOENT, Errno::ENOTEMPTY
// 26:         nil
// 27:       end
// 28:       @prepared_writable_paths.clear
// 29:     end
// 30:
// 31:     private
// 32:
// 33:     sig { returns(SandboxProfile) }
// 34:     attr_reader :profile
// 35:
// 36:     public
// 37:
// 38:     sig { returns(T::Hash[String, Symbol]) }
// 39:     def writable_paths
// 40:       profile.rules.each_with_object({}) do |rule, paths|
// 41:         next if !rule.allow || !rule.operation.start_with?("file-write")
// 42:         next unless (filter = rule.filter)
// 43:
// 44:         case filter.type
// 45:         when :literal, :subpath
// 46:           paths[filter.path] ||= filter.type
// 47:         when :regex
// 48:           raise ArgumentError, "Linux sandbox does not support regex path filters: #{filter.path}"
// 49:         else
// 50:           raise ArgumentError, "Invalid path filter type: #{filter.type}"
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     private
// 56:
// 57:     sig { params(allow: T::Boolean, operation: String).returns(T::Array[String]) }
// 58:     def profile_paths(allow:, operation:)
// 59:       profile.rules.filter_map do |rule|
// 60:         next if rule.allow != allow || !rule.operation.start_with?(operation)
// 61:
// 62:         filter = rule.filter
// 63:         filter.path if filter && [:literal, :subpath].include?(filter.type)
// 64:       end.uniq
// 65:     end
// 66:
// 67:     sig { returns(T::Boolean) }
// 68:     def deny_all_network?
// 69:       profile.rules.any? do |rule|
// 70:         !rule.allow && rule.operation == "network*" && rule.filter.nil?
// 71:       end
// 72:     end
// 73:
// 74:     sig { params(path: String, type: Symbol).void }
// 75:     def prepare_writable_path(path, type)
// 76:       pathname = ::Pathname.new(path)
// 77:       return if pathname.exist?
// 78:
// 79:       if type == :literal
// 80:         FileUtils.mkdir_p(pathname.dirname)
// 81:         FileUtils.touch(pathname)
// 82:       else
// 83:         FileUtils.mkdir_p(pathname)
// 84:         @prepared_writable_paths << pathname
// 85:       end
// 86:     end
// 87:   end
// 88: end
