module utils

import ruby

// Translated from Homebrew/brew `utils/linkage.rb`.

fn normalize_linkage_path(path string, prefix string) string {
	if prefix != '' && path.starts_with(prefix) && ruby.path_exists(path) {
		return ruby.real_path(path)
	}
	return path
}

pub fn dynamically_linked_libraries(binary string) []string {
	kernel := ruby.kernel_info().name
	if kernel == 'Darwin' {
		result := ruby.run_command('/usr/bin/otool', ['-L', binary])
		if result.exit_code != 0 {
			return []
		}
		return result.output.split_into_lines()[1..].map(it.trim_space().all_before(' (')).filter(it != '')
	}
	ldd := ruby.find_executable('ldd') or { return [] }
	result := ruby.run_command(ldd, [binary])
	if result.exit_code != 0 {
		return []
	}
	mut libraries := []string{}
	for line in result.output.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed == '' || trimmed.contains('not found') {
			continue
		}
		path := if trimmed.contains(' => ') {
			trimmed.all_after(' => ').all_before(' (').trim_space()
		} else {
			trimmed.all_before(' (').trim_space()
		}
		if path.starts_with('/') {
			libraries << path
		}
	}
	return libraries
}

pub fn binary_linked_to_library(binary string, library string, prefix string) bool {
	expected := normalize_linkage_path(library, prefix)
	return dynamically_linked_libraries(binary).any(normalize_linkage_path(it, prefix) == expected)
}
