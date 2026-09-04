module sandbox

import homebrew
import os

// Translated from Homebrew/brew `extend/os/linux/sandbox/backend.rb`.

// Ruby method `full_write_isolation? = true` at line 10.
pub struct LinuxBackend {
pub mut:
	profile                 homebrew.SandboxProfile
	prepared_writable_paths []string
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
