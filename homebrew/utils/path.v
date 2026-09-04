module utils

import ruby
import os

// Translated from Homebrew/brew `utils/path.rb`.

pub struct PathLoadOptions {
pub:
	forbid_packages_from_paths bool
	library                    string
	cellar                     string
	caskroom                   string
}

pub fn path_child_of(parent string, child string) bool {
	parent_path := os.norm_path(os.abs_path(parent))
	mut current := os.norm_path(os.abs_path(child))
	for {
		if current == parent_path {
			return true
		}
		next := os.dir(current)
		if next == current {
			break
		}
		current = next
	}
	return false
}

pub fn path_ensure_child_of(parent string, child string, message string) ! {
	if !path_child_of(parent, child) {
		return error(message)
	}
}

pub fn path_formula_opt_prefix(prefix string, formula_name string) string {
	return os.join_path(prefix, 'opt', path_name_from_full_name(formula_name))
}

pub fn path_formula_opt_bin(prefix string, formula_name string) string {
	return os.join_path(path_formula_opt_prefix(prefix, formula_name), 'bin')
}

pub fn path_formula_opt_lib(prefix string, formula_name string) string {
	return os.join_path(path_formula_opt_prefix(prefix, formula_name), 'lib')
}

pub fn path_formula_opt_libexec(prefix string, formula_name string) string {
	return os.join_path(path_formula_opt_prefix(prefix, formula_name), 'libexec')
}

pub fn path_formula_opt_include(prefix string, formula_name string) string {
	return os.join_path(path_formula_opt_prefix(prefix, formula_name), 'include')
}

pub fn path_formula_installed_prefixes(cellar string, formula_names []string) []string {
	mut seen_racks := map[string]bool{}
	mut prefixes := []string{}
	for formula_name in formula_names {
		rack := os.join_path(cellar, path_name_from_full_name(formula_name))
		if !os.is_dir(rack) {
			continue
		}
		real_rack := os.real_path(rack)
		if real_rack in seen_racks {
			continue
		}
		seen_racks[real_rack] = true
		for child in os.ls(rack) or { []string{} } {
			prefix := os.join_path(rack, child)
			if os.is_dir(prefix) { prefixes << prefix }
		}
	}
	prefixes.sort_with_compare(fn (left &string, right &string) int {
		return compare_strings(os.base(*left), os.base(*right))
	})
	return prefixes
}

pub fn path_formula_any_version_installed(cellar string, formula_names []string) bool {
	return path_formula_installed_prefixes(cellar, formula_names).any(os.is_file(os.join_path(it, 'INSTALL_RECEIPT.json')))
}

pub fn path_formula_opt_bin_path(prefix string, formula_name string, extra_paths []string, current_path string) string {
	mut paths := [path_formula_opt_bin(prefix, formula_name)]
	paths << extra_paths
	if current_path != '' { paths << current_path }
	return paths.join(os.path_delimiter)
}

pub fn path_loadable_package_path(path string, package_type string, options PathLoadOptions) !bool {
	if !options.forbid_packages_from_paths {
		return true
	}
	path_string := path
	path_realpath := if os.exists(path) {
		os.real_path(path)
	} else {
		os.norm_path(os.abs_path(path))
	}
	mut allowed_paths := [
		path_trusted_package_root(os.join_path(options.library, 'Taps')),
	]
	allowed_paths << path_trusted_package_root(if package_type == 'formula' {
		options.cellar
	} else {
		options.caskroom
	})
	extensions := if package_type == 'cask' { ['.rb', '.json'] } else { ['.rb'] }
	if extensions.all(!path_realpath.ends_with(it) && !path_string.ends_with(it)) {
		return true
	}
	if allowed_paths.any(path_child_of(it, path_realpath) || path_child_of(it, path)) {
		return true
	}
	if path_string.contains('./') || path_string.ends_with('.rb') || path_string.count('/') != 2 {
		plural := '${package_type}s'
		different := if path_realpath != path_string { ' (${path_realpath})' } else { '' }
		create_flag := if package_type == 'cask' { ' --cask' } else { '' }
		return error('Homebrew requires ${plural} to be in a tap, rejecting:\n  ${path_string}${different}\n\nTo create a tap, run e.g.\n  brew tap-new <user|org>/<repository>\nTo create a ${package_type} in a tap run e.g.\n  brew create${create_flag} <url> --tap=<user|org>/<repository>')
	}
	return path_string.count('/') != 2
}

pub fn path_trusted_package_root(path string) string {
	return if os.exists(path) { os.real_path(path) } else { os.norm_path(os.abs_path(path)) }
}

fn path_names_from_value(value ruby.Value) []string {
	return if value.type_name == 'Array' {
		value.as_string_array() or { value.array_data.map(it.as_string()) }
	} else {
		[value.as_string()]
	}
}

fn path_name_from_full_name(full_name string) string {
	return full_name.all_after_last('/')
}

fn path_homebrew_prefix() string {
	value := ruby.environment_value('HOMEBREW_PREFIX')
	return if value != '' { value } else { '/usr/local' }
}

fn path_homebrew_cellar() string {
	value := ruby.environment_value('HOMEBREW_CELLAR')
	return if value != '' { value } else { os.join_path(path_homebrew_prefix(), 'Cellar') }
}
