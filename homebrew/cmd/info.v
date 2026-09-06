module cmd

import ruby

pub struct InfoTabModel {
pub:
	installed_on_request_present bool
	installed_on_request         bool
	source_tap                   string
	source_path                  string
	runtime_dependencies         []string
	poured_from_bottle           bool
	time                         i64
	text                         string
}

pub struct InfoKegModel {
pub:
	name     string
	version  string
	size     i64
	linked   bool
	head     bool
	binaries []string
	tab      InfoTabModel
}

pub struct InfoDependencyModel {
pub:
	name                  string
	kind                  string
	option_tags           []string
	installed             bool
	any_version_installed bool
	outdated              bool
	available             bool = true
	missing_library       bool
}

pub struct InfoRequirementModel {
pub:
	display   string
	kind      string
	satisfied bool
	other_os  bool
	type_name string
}

pub struct InfoConflictModel {
pub:
	name               string
	resolved_full_name string
	reason             string
}

pub struct InfoTapModel {
pub:
	name           string
	path           string
	remote         string
	default_remote string
	official       bool
}

pub struct InfoPackageModel {
pub:
	kind                         string
	name                         string
	full_name                    string
	description                  string
	display_names                []string
	homepage                     string
	version                      string
	stable_version               string
	has_stable                   bool
	has_head                     bool
	stable_bottled               bool
	pour_bottle                  bool
	keg_only                     bool
	installed_version            string
	installed_kegs               []InfoKegModel
	any_version_installed        bool
	outdated                     bool
	pinned                       bool
	pinned_version               string
	pin_path                     string
	pin_mtime                    i64
	deprecated                   bool
	disabled                     bool
	aliases                      []string
	old_names                    []string
	license                      string
	caveats                      string
	path                         string
	sourcefile_path              string
	tap                          InfoTapModel
	conflicts                    []InfoConflictModel
	dependencies                 []InfoDependencyModel
	requirements                 []InfoRequirementModel
	dependent_names              []string
	runtime_dependency_installed []string
	options                      []string
	deprecate_message            string
	bottle_size                  i64
	installed_size               i64
	bottle_binaries              []string
	related                      []ruby.Value
	resolution_formula           ruby.Value
	installed_tap                string
	installed_keg_name           string
	available                    bool = true
	info                         string
	size                         i64
	tty                          bool
}

pub struct InfoNameSize {
pub:
	name string
	size i64
}

fn info_values(value ruby.Value, key string) []ruby.Value {
	items := value.map_data[key] or { return [] }
	return items.as_array() or { [] }
}

fn info_semver_parts(version string) []int {
	return version.trim_left('v').split_any('.-_').map(it.int())
}

fn info_unique_strings(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if seen[value] or { false } {
			continue
		}
		seen[value] = true
		result << value
	}
	return result
}

fn info_version_compare(left string, right string) int {
	left_parts := info_semver_parts(left)
	right_parts := info_semver_parts(right)
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
	}
	return 0
}

fn info_status_text(name string, installed bool, outdated bool, deprecated bool,
	disabled bool, mark_uninstalled bool, warning bool, tty bool) string {
	mut result := name
	if !tty {
		return result
	}
	if warning {
		result += ' ⚠'
	} else if installed && outdated {
		result += ' ↑'
	} else if installed {
		result += ' ✔'
	} else if mark_uninstalled {
		result += ' ✘'
	}
	if disabled {
		result += ' (disabled)'
	} else if deprecated {
		result += ' (deprecated)'
	}
	return result
}

fn info_dep_display(dep InfoDependencyModel) string {
	if dep.option_tags.len == 0 {
		return dep.name
	}
	return '${dep.name} ${dep.option_tags.map('--\${it}').join(' ')}'
}

fn info_decorate_dependencies(dependencies []InfoDependencyModel, mark_uninstalled bool,
	tty bool) string {
	return dependencies.map(info_status_text(info_dep_display(it), it.installed || it.any_version_installed, it.outdated, false, false, mark_uninstalled, it.missing_library, tty)).join(', ')
}

fn info_decorate_requirements(requirements []InfoRequirementModel, mark_uninstalled bool,
	tty bool) string {
	return requirements.map(info_status_text(it.display, it.satisfied, false, false, false, mark_uninstalled, false, tty)).join(', ')
}

fn info_summary_title(package InfoPackageModel, installed bool) string {
	mut title := info_status_text(package.full_name, installed, false, false, false, false, false, package.tty)
	mut description := package.description
	if package.kind == 'cask' && description != '' && package.display_names.len > 0 {
		description = '(${package.display_names.join(', ')}) ${description}'
	}
	if description != '' {
		title += ': ${description}'
	}
	return title
}

fn info_sizes_table(title string, items []InfoNameSize) string {
	if items.len == 0 {
		return ''
	}
	mut result := ['==> ${title}']
	mut total := i64(0)
	for item in items {
		total += item.size
		result << '${item.name} ${item.size}B'
	}
	result << 'Total ${total}B'
	return result.join('\n') + '\n'
}

// Translated from Homebrew/brew `cmd/info.rb`.
