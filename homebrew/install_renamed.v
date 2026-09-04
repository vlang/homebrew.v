module homebrew

import homebrew.extend
import os

// Translated from Homebrew/brew `install_renamed.rb`.

pub fn install_renamed_install_p(destination string, source string, new_basename string, cellar string) ! {
	target := os.join_path(destination, new_basename)
	if os.is_dir(source) && !os.is_link(source) && os.is_dir(target) && !os.is_link(target) {
		mut children := os.ls(source)!
		children.sort()
		for child in children {
			install_renamed_install_p(target, os.join_path(source, child), child, cellar)!
		}
		if os.ls(source)!.len == 0 {
			os.rmdir(source) or {}
		}
		return
	}
	selected := install_renamed_append_default_if_different(source, target, cellar)!
	extend.pathname_install_p(os.dir(selected), source, os.base(selected))!
}

pub fn install_renamed_cp_path_sub(path string, pattern string, replacement string, cellar string) !string {
	if !os.exists(path) && !os.is_link(path) {
		return error('${path} does not exist')
	}
	destination := path.replace_once(pattern, replacement)
	if destination == path {
		return error('${path} is the same file as ${destination}')
	}
	selected := install_renamed_append_default_if_different(path, destination, cellar)!
	os.mkdir_all(os.dir(selected))!
	if os.is_dir(path) && !os.is_link(path) {
		os.cp_all(path, selected, true)!
	} else {
		os.cp(path, selected)!
	}
	return selected
}

pub fn install_renamed_add(path string, other string) string {
	return path + other
}

pub fn install_renamed_join(path string, other string) string {
	return os.join_path(path, other)
}

pub fn install_renamed_append_default_if_different(source string, destination string, cellar string) !string {
	if !os.is_file(destination) || install_renamed_identical(source, destination) {
		return destination
	}
	resolved_source := if os.is_link(source) {
		os.join_path(os.real_path(os.dir(source)), os.base(source))
	} else {
		os.real_path(source)
	}
	if cellar != '' {
		mut ancestor := resolved_source
		for {
			if os.base(ancestor) == '.bottle' && os.norm_path(os.dir(os.dir(os.dir(ancestor)))) == os.norm_path(cellar) {
				formula_directory := os.dir(os.dir(ancestor))
				relative_source := install_renamed_relative_path(resolved_source, ancestor)
				for version in os.ls(formula_directory) or { []string{} } {
					prefix := os.join_path(formula_directory, version)
					if os.norm_path(prefix) == os.norm_path(os.dir(ancestor)) {
						continue
					}
					default_file := os.join_path(prefix, '.bottle', relative_source)
					if os.is_file(default_file) && install_renamed_identical(destination, default_file) {
						return destination
					}
				}
				break
			}
			parent := os.dir(ancestor)
			if parent == ancestor || ancestor == '' {
				break
			}
			ancestor = parent
		}
	}
	return '${destination}.default'
}

fn install_renamed_identical(first string, second string) bool {
	if !os.is_file(first) || !os.is_file(second) || os.file_size(first) != os.file_size(second) {
		return false
	}
	return os.read_bytes(first) or { return false } == os.read_bytes(second) or { return false }
}

fn install_renamed_relative_path(path string, base string) string {
	clean_path := os.norm_path(path)
	clean_base := os.norm_path(base)
	prefix := if clean_base.ends_with(os.path_separator) {
		clean_base
	} else {
		clean_base + os.path_separator
	}
	return if clean_path.starts_with(prefix) {
		clean_path[prefix.len..]
	} else {
		os.base(clean_path)
	}
}
