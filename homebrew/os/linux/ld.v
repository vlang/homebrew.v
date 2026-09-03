module linux

import brew_runtime

// Translated from Homebrew/brew `os/linux/ld.rb`.
// The original source is retained below until every stub has a typed V body.
pub const dynamic_linkers = [
	'/lib64/ld-linux-x86-64.so.2',
	'/lib64/ld64.so.2',
	'/lib/ld-linux.so.3',
	'/lib/ld-linux.so.2',
	'/lib/ld-linux-aarch64.so.1',
	'/lib/ld-linux-armhf.so.3',
	'/system/bin/linker64',
	'/system/bin/linker',
]

pub struct LdState {
pub mut:
	system_ld_so ?string
}

pub fn (mut state LdState) set_system_ld_so(path ?string) ?string {
	state.system_ld_so = path
	return path
}

fn ld_path_executable(path string) bool {
	if !brew_runtime.path_exists(path) {
		return false
	}
	return brew_runtime.run_command('/usr/bin/test', ['-x', path]).exit_code == 0
}

pub fn find_system_ld_so_in(candidates []string, executable fn(string) bool) ?string {
	for candidate in candidates {
		if executable(candidate) {
			return candidate
		}
	}
	return none
}

pub fn system_ld_so() ?string {
	return find_system_ld_so_in(dynamic_linkers, ld_path_executable)
}

pub fn ld_so_diagnostics_for(linker ?string) string {
	path := linker or { return '' }
	if !brew_runtime.path_exists(path) {
		return ''
	}
	result := brew_runtime.run_command(path, ['--list-diagnostics'])
	return if result.exit_code == 0 { result.output } else { '' }
}

pub fn ld_so_diagnostics(brewed bool) string {
	if brewed {
		prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
		return ld_so_diagnostics_for(brew_runtime.join_path(prefix, 'lib/ld.so'))
	}
	return ld_so_diagnostics_for(system_ld_so())
}

pub fn sysconfdir_from_diagnostics(diagnostics string) string {
	prefix := 'path.sysconfdir="'
	for line in diagnostics.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with(prefix) && trimmed.ends_with('"') {
			value := trimmed[prefix.len..trimmed.len - 1]
			if value != '' {
				return value
			}
		}
	}
	return '/etc'
}

pub fn ld_sysconfdir(brewed bool) string {
	return sysconfdir_from_diagnostics(ld_so_diagnostics(brewed))
}

pub fn system_dirs_from_diagnostics(diagnostics string) []string {
	mut directories := []string{}
	for line in diagnostics.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('path.system_dirs[0x') {
			continue
		}
		separator := trimmed.index(']="') or { continue }
		if !trimmed.ends_with('"') {
			continue
		}
		directories << trimmed[separator + 3..trimmed.len - 1]
	}
	return directories
}

pub fn ld_system_dirs(brewed bool) []string {
	return system_dirs_from_diagnostics(ld_so_diagnostics(brewed))
}

fn ld_dirname(path string) string {
	trimmed := path.trim_right('/')
	separator := trimmed.last_index('/') or { return '.' }
	return if separator == 0 { '/' } else { trimmed[..separator] }
}

fn ld_join_path(directory string, path string) string {
	return if path.starts_with('/') { path } else { brew_runtime.join_path(directory, path) }
}

fn ld_glob_component_matches(pattern string, name string) bool {
	mut pattern_index := 0
	mut name_index := 0
	mut star_index := -1
	mut star_match := 0
	for name_index < name.len {
		if pattern_index < pattern.len && (pattern[pattern_index] == `?` || pattern[pattern_index] == name[name_index]) {
			pattern_index++
			name_index++
		} else if pattern_index < pattern.len && pattern[pattern_index] == `*` {
			star_index = pattern_index
			pattern_index++
			star_match = name_index
		} else if star_index >= 0 {
			pattern_index = star_index + 1
			star_match++
			name_index = star_match
		} else {
			return false
		}
	}
	for pattern_index < pattern.len && pattern[pattern_index] == `*` {
		pattern_index++
	}
	return pattern_index == pattern.len
}

fn ld_glob_walk(directory string, components []string, index int, mut matches []string) {
	if index == components.len {
		if brew_runtime.path_exists(directory) {
			matches << directory
		}
		return
	}
	component := components[index]
	if !component.contains_any('*?') {
		ld_glob_walk(ld_join_path(directory, component), components, index + 1, mut matches)
		return
	}
	mut entries := brew_runtime.list_dir(directory) or { return }
	entries.sort()
	for entry in entries {
		if ld_glob_component_matches(component, entry) {
			ld_glob_walk(ld_join_path(directory, entry), components, index + 1, mut matches)
		}
	}
}

fn ld_expand_glob(pattern string) []string {
	mut matches := []string{}
	if pattern.starts_with('/') {
		components := pattern.trim_left('/').split('/').filter(it != '')
		ld_glob_walk('/', components, 0, mut matches)
	} else {
		components := pattern.split('/').filter(it != '')
		ld_glob_walk('.', components, 0, mut matches)
	}
	return matches
}

fn read_library_paths(conf_file string, mut seen map[string]bool) []string {
	if !brew_runtime.is_file(conf_file) {
		return []
	}
	real_conf_file := brew_runtime.real_path(conf_file)
	if seen[real_conf_file] {
		return []
	}
	seen[real_conf_file] = true
	contents := brew_runtime.read_file(real_conf_file) or { return [] }
	directory := ld_dirname(real_conf_file)
	mut paths := []string{}
	for raw_line in contents.split_into_lines() {
		mut line := raw_line.trim_space()
		if comment := line.index('#') {
			line = line[..comment].trim_space()
		}
		if line.starts_with('include ') {
			wildcard := ld_join_path(directory, line['include '.len..].trim_space())
			for include_file in ld_expand_glob(wildcard) {
				for path in read_library_paths(include_file, mut seen) {
					if path !in paths {
						paths << path
					}
				}
			}
		} else if line != '' && line !in paths {
			paths << line
		}
	}
	return paths
}

pub fn library_paths_from_file(conf_file string) []string {
	mut seen := map[string]bool{}
	return read_library_paths(conf_file, mut seen)
}

pub fn ld_library_paths(conf_path string, brewed bool) []string {
	conf_file := ld_join_path(ld_sysconfdir(brewed), conf_path)
	return library_paths_from_file(conf_file)
}

// Ruby attr_writer `attr_writer :system_ld_so` at line 24.
pub fn ruby_ld_l24_d1_system_ld_so(mut state LdState, path ?string) ?string {
	return state.set_system_ld_so(path)
}

// Ruby method `self.system_ld_so` at line 29.
pub fn ruby_ld_l29_d2_self_system_ld_so() ?string {
	return system_ld_so()
}

// Ruby method `self.ld_so_diagnostics(brewed: true)` at line 38.
pub fn ruby_ld_l38_d3_self_ld_so_diagnostics(brewed bool) string {
	return ld_so_diagnostics(brewed)
}

// Ruby method `self.sysconfdir(brewed: true)` at line 62.
pub fn ruby_ld_l62_d4_self_sysconfdir(brewed bool) string {
	return ld_sysconfdir(brewed)
}

// Ruby method `self.system_dirs(brewed: true)` at line 72.
pub fn ruby_ld_l72_d5_self_system_dirs(brewed bool) []string {
	return ld_system_dirs(brewed)
}

// Ruby method `self.library_paths(conf_path = "ld.so.conf", brewed: true)` at line 86.
pub fn ruby_ld_l86_d6_self_library_paths(conf_path string, brewed bool) []string {
	return ld_library_paths(conf_path, brewed)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for querying `ld` information.
// 7:     module Ld
// 8:       # This is a list of known paths to the host dynamic linker on Linux if
// 9:       # the host glibc is new enough. Brew will fail to create a symlink for
// 10:       # ld.so if the host linker cannot be found in this list.
// 11:       DYNAMIC_LINKERS = %w[
// 12:         /lib64/ld-linux-x86-64.so.2
// 13:         /lib64/ld64.so.2
// 14:         /lib/ld-linux.so.3
// 15:         /lib/ld-linux.so.2
// 16:         /lib/ld-linux-aarch64.so.1
// 17:         /lib/ld-linux-armhf.so.3
// 18:         /system/bin/linker64
// 19:         /system/bin/linker
// 20:       ].freeze
// 21:
// 22:       class << self
// 23:         sig { params(system_ld_so: T.nilable(::Pathname)).returns(T.nilable(::Pathname)) }
// 24:         attr_writer :system_ld_so
// 25:       end
// 26:
// 27:       # The path to the system's dynamic linker or `nil` if not found
// 28:       sig { returns(T.nilable(::Pathname)) }
// 29:       def self.system_ld_so
// 30:         @system_ld_so ||= T.let(nil, T.nilable(::Pathname))
// 31:         @system_ld_so ||= begin
// 32:           linker = DYNAMIC_LINKERS.find { |s| File.executable? s }
// 33:           Pathname(linker) if linker
// 34:         end
// 35:       end
// 36:
// 37:       sig { params(brewed: T::Boolean).returns(String) }
// 38:       def self.ld_so_diagnostics(brewed: true)
// 39:         @ld_so_diagnostics ||= T.let({}, T.nilable(T::Hash[Pathname, T.nilable(String)]))
// 40:
// 41:         ld_so_target = if brewed
// 42:           ld_so = HOMEBREW_PREFIX/"lib/ld.so"
// 43:           return "" unless ld_so.exist?
// 44:
// 45:           ld_so.readlink
// 46:         else
// 47:           ld_so = system_ld_so
// 48:           return "" unless ld_so&.exist?
// 49:
// 50:           ld_so
// 51:         end
// 52:
// 53:         @ld_so_diagnostics[ld_so_target] ||= begin
// 54:           ld_so_output = Utils.popen_read(ld_so, "--list-diagnostics")
// 55:           ld_so_output if $CHILD_STATUS.success?
// 56:         end
// 57:
// 58:         @ld_so_diagnostics[ld_so_target].to_s
// 59:       end
// 60:
// 61:       sig { params(brewed: T::Boolean).returns(String) }
// 62:       def self.sysconfdir(brewed: true)
// 63:         fallback_sysconfdir = "/etc"
// 64:
// 65:         match = ld_so_diagnostics(brewed:).match(/path.sysconfdir="(.+)"/)
// 66:         return fallback_sysconfdir unless match
// 67:
// 68:         match.captures.compact.first || fallback_sysconfdir
// 69:       end
// 70:
// 71:       sig { params(brewed: T::Boolean).returns(T::Array[String]) }
// 72:       def self.system_dirs(brewed: true)
// 73:         dirs = []
// 74:
// 75:         ld_so_diagnostics(brewed:).split("\n").each do |line|
// 76:           match = line.match(/path.system_dirs\[0x.*\]="(.*)"/)
// 77:           next unless match
// 78:
// 79:           dirs << match.captures.compact.first
// 80:         end
// 81:
// 82:         dirs
// 83:       end
// 84:
// 85:       sig { params(conf_path: T.any(::Pathname, String), brewed: T::Boolean).returns(T::Array[String]) }
// 86:       def self.library_paths(conf_path = "ld.so.conf", brewed: true)
// 87:         conf_file = Pathname(sysconfdir(brewed:))/conf_path
// 88:         return [] unless conf_file.exist?
// 89:         return [] unless conf_file.file?
// 90:         return [] unless conf_file.readable?
// 91:
// 92:         @library_paths_cache ||= T.let({}, T.nilable(T::Hash[String, T::Array[String]]))
// 93:         cache_key = conf_file.to_s
// 94:         if (cached_library_path_contents = @library_paths_cache[cache_key])
// 95:           return cached_library_path_contents
// 96:         end
// 97:
// 98:         paths = Set.new
// 99:         directory = conf_file.realpath.dirname
// 100:
// 101:         conf_file.open("r") do |file|
// 102:           file.each_line do |line|
// 103:             # Remove comments and leading/trailing whitespace
// 104:             line.strip!
// 105:             line.sub!(/\s*#.*$/, "")
// 106:
// 107:             if line.start_with?(/\s*include\s+/)
// 108:               wildcard = Pathname(line.sub(/^\s*include\s+/, "")).expand_path(directory)
// 109:
// 110:               Dir.glob(wildcard.to_s).each do |include_file|
// 111:                 paths += library_paths(include_file)
// 112:               end
// 113:             elsif line.empty?
// 114:               next
// 115:             else
// 116:               paths << line
// 117:             end
// 118:           end
// 119:         end
// 120:
// 121:         @library_paths_cache[cache_key] = paths.to_a
// 122:       end
// 123:     end
// 124:   end
// 125: end
