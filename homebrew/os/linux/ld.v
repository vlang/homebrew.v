module linux

import ruby

// Translated from Homebrew/brew `os/linux/ld.rb`.
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
	if !ruby.path_exists(path) {
		return false
	}
	return ruby.run_command('/usr/bin/test', ['-x', path]).exit_code == 0
}

pub fn find_system_ld_so_in(candidates []string, executable fn (string) bool) ?string {
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
	if !ruby.path_exists(path) {
		return ''
	}
	result := ruby.run_command(path, ['--list-diagnostics'])
	return if result.exit_code == 0 { result.output } else { '' }
}

pub fn ld_so_diagnostics(brewed bool) string {
	if brewed {
		prefix := ruby.environment_value('HOMEBREW_PREFIX')
		return ld_so_diagnostics_for(ruby.join_path(prefix, 'lib/ld.so'))
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
	return if path.starts_with('/') { path } else { ruby.join_path(directory, path) }
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
		if ruby.path_exists(directory) {
			matches << directory
		}
		return
	}
	component := components[index]
	if !component.contains_any('*?') {
		ld_glob_walk(ld_join_path(directory, component), components, index + 1, mut matches)
		return
	}
	mut entries := ruby.list_dir(directory) or { return }
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
	if !ruby.is_file(conf_file) {
		return []
	}
	real_conf_file := ruby.real_path(conf_file)
	if seen[real_conf_file] {
		return []
	}
	seen[real_conf_file] = true
	contents := ruby.read_file(real_conf_file) or { return [] }
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
