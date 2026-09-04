module cmd

import ruby
import os
import time
import x.json2

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

fn info_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn info_bool_attr(value ruby.Value, name string, fallback bool) bool {
	raw := value.attributes[name] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn info_int_attr(value ruby.Value, name string, fallback i64) i64 {
	return (value.attributes[name] or { return fallback }).i64()
}

fn info_string_list(value ruby.Value, name string) []string {
	raw := value.attributes[name] or { return [] }
	if raw == '' {
		return []
	}
	return raw.split('\x1f')
}

fn info_values(value ruby.Value, key string) []ruby.Value {
	items := value.map_data[key] or { return [] }
	return items.as_array() or { [] }
}

fn info_tab_from_value(value ruby.Value) InfoTabModel {
	return InfoTabModel{
		installed_on_request_present: info_bool_attr(value, 'installed_on_request_present', 'installed_on_request' in value.attributes)
		installed_on_request: info_bool_attr(value, 'installed_on_request', false)
		source_tap: value.attributes['source_tap'] or { '' }
		source_path: value.attributes['source_path'] or { '' }
		runtime_dependencies: info_string_list(value, 'runtime_dependencies')
		poured_from_bottle: info_bool_attr(value, 'poured_from_bottle', false)
		time: info_int_attr(value, 'time', 0)
		text: value.attributes['text'] or { '' }
	}
}

fn info_keg_from_value(value ruby.Value) InfoKegModel {
	tab_value := value.map_data['tab'] or { ruby.Value{} }
	return InfoKegModel{
		name: value.attributes['name'] or { value.repr }
		version: value.attributes['version'] or { value.repr }
		size: info_int_attr(value, 'size', 0)
		linked: info_bool_attr(value, 'linked', false)
		head: info_bool_attr(value, 'head', false)
		binaries: info_string_list(value, 'binaries')
		tab: info_tab_from_value(tab_value)
	}
}

fn info_dependency_from_value(value ruby.Value) InfoDependencyModel {
	return InfoDependencyModel{
		name: value.attributes['name'] or { value.repr }
		kind: value.attributes['kind'] or { 'required' }
		option_tags: info_string_list(value, 'option_tags')
		installed: info_bool_attr(value, 'installed', false)
		any_version_installed: info_bool_attr(value, 'any_version_installed', false)
		outdated: info_bool_attr(value, 'outdated', false)
		available: info_bool_attr(value, 'available', true)
		missing_library: info_bool_attr(value, 'missing_library', false)
	}
}

fn info_requirement_from_value(value ruby.Value) InfoRequirementModel {
	return InfoRequirementModel{
		display: value.attributes['display'] or { value.repr }
		kind: value.attributes['kind'] or { 'required' }
		satisfied: info_bool_attr(value, 'satisfied', false)
		other_os: info_bool_attr(value, 'other_os', value.type_name in [
			'MacOSRequirement',
			'LinuxRequirement',
		])
		type_name: value.type_name
	}
}

fn info_tap_from_value(value ruby.Value) InfoTapModel {
	return InfoTapModel{
		name: value.attributes['name'] or { value.repr }
		path: value.attributes['path'] or { '' }
		remote: value.attributes['remote'] or { '' }
		default_remote: value.attributes['default_remote'] or { '' }
		official: info_bool_attr(value, 'official', false)
	}
}

fn info_package_from_value(value ruby.Value) InfoPackageModel {
	tap_value := value.map_data['tap'] or { ruby.Value{} }
	mut conflicts := []InfoConflictModel{}
	for item in info_values(value, 'conflicts') {
		conflicts << InfoConflictModel{
			name: item.attributes['name'] or { item.repr }
			resolved_full_name: item.attributes['resolved_full_name'] or { '' }
			reason: item.attributes['reason'] or { '' }
		}
	}
	return InfoPackageModel{
		kind: value.attributes['kind'] or {
			if value.type_name.contains('Cask') {
				'cask'
			} else {
				'formula'
			}
		}
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		description: value.attributes['description'] or { '' }
		display_names: info_string_list(value, 'display_names')
		homepage: value.attributes['homepage'] or { '' }
		version: value.attributes['version'] or { '' }
		stable_version: value.attributes['stable_version'] or { value.attributes['version'] or { '' } }
		has_stable: info_bool_attr(value, 'has_stable', true)
		has_head: info_bool_attr(value, 'has_head', false)
		stable_bottled: info_bool_attr(value, 'stable_bottled', false)
		pour_bottle: info_bool_attr(value, 'pour_bottle', true)
		keg_only: info_bool_attr(value, 'keg_only', false)
		installed_version: value.attributes['installed_version'] or { '' }
		installed_kegs: info_values(value, 'installed_kegs').map(info_keg_from_value(it))
		any_version_installed: info_bool_attr(value, 'any_version_installed', info_values(value, 'installed_kegs').len > 0)
		outdated: info_bool_attr(value, 'outdated', false)
		pinned: info_bool_attr(value, 'pinned', false)
		pinned_version: value.attributes['pinned_version'] or { '' }
		pin_path: value.attributes['pin_path'] or { '' }
		pin_mtime: info_int_attr(value, 'pin_mtime', 0)
		deprecated: info_bool_attr(value, 'deprecated', false)
		disabled: info_bool_attr(value, 'disabled', false)
		aliases: info_string_list(value, 'aliases')
		old_names: info_string_list(value, 'old_names')
		license: value.attributes['license'] or { '' }
		caveats: value.attributes['caveats'] or { '' }
		path: value.attributes['path'] or { '' }
		sourcefile_path: value.attributes['sourcefile_path'] or { '' }
		tap: info_tap_from_value(tap_value)
		conflicts: conflicts
		dependencies: info_values(value, 'dependencies').map(info_dependency_from_value(it))
		requirements: info_values(value, 'requirements').map(info_requirement_from_value(it))
		dependent_names: info_string_list(value, 'dependent_names')
		runtime_dependency_installed: info_string_list(value, 'runtime_dependency_installed')
		options: info_string_list(value, 'options')
		deprecate_message: value.attributes['deprecate_message'] or { '' }
		bottle_size: info_int_attr(value, 'bottle_size', 0)
		installed_size: info_int_attr(value, 'installed_size', 0)
		bottle_binaries: info_string_list(value, 'bottle_binaries')
		related: info_values(value, 'related')
		resolution_formula: value.map_data['resolution_formula'] or { ruby.Value{} }
		installed_tap: value.attributes['installed_tap'] or { '' }
		installed_keg_name: value.attributes['installed_keg_name'] or { value.attributes['name'] or { value.repr } }
		available: info_bool_attr(value, 'available', true)
		info: value.attributes['info'] or { '' }
		size: info_int_attr(value, 'size', 0)
		tty: info_bool_attr(value, 'tty', false)
	}
}

fn info_tab_value(tab InfoTabModel) ruby.Value {
	return ruby.structured_value('Tab', 'Tab', {
		'installed_on_request_present': tab.installed_on_request_present.str()
		'installed_on_request':         tab.installed_on_request.str()
		'source_tap':                   tab.source_tap
		'source_path':                  tab.source_path
		'runtime_dependencies':         tab.runtime_dependencies.join('\x1f')
		'poured_from_bottle':           tab.poured_from_bottle.str()
		'time':                         tab.time.str()
		'text':                         tab.text
	})
}

fn info_keg_value(keg InfoKegModel) ruby.Value {
	return ruby.Value{
		type_name: 'Keg'
		repr: keg.version
		map_data: {
			'tab': info_tab_value(keg.tab)
		}
		attributes: {
			'name':     keg.name
			'version':  keg.version
			'size':     keg.size.str()
			'linked':   keg.linked.str()
			'head':     keg.head.str()
			'binaries': keg.binaries.join('\x1f')
		}
	}
}

fn info_tap_value(tap InfoTapModel) ruby.Value {
	if tap.name == '' {
		return info_nil()
	}
	return ruby.structured_value('Tap', tap.name, {
		'name':           tap.name
		'path':           tap.path
		'remote':         tap.remote
		'default_remote': tap.default_remote
		'official':       tap.official.str()
	})
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

fn info_value_to_json(value ruby.Value) json2.Any {
	return match value.type_name {
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'Array' {
			mut items := []json2.Any{}
			for item in value.as_array() or { [] } {
				items << info_value_to_json(item)
			}
			json2.Any(items)
		}
		'Hash' {
			mut items := map[string]json2.Any{}
			for key, item in value.map_data {
				items[key] = info_value_to_json(item)
			}
			json2.Any(items)
		}
		'NilClass' { json2.null }
		else { json2.Any(value.repr) }
	}
}

fn info_package_hash(value ruby.Value) ruby.Value {
	package := info_package_from_value(value)
	if hash := value.map_data['json'] {
		return hash
	}
	return ruby.map_value({
		'name':      ruby.string_value(package.name)
		'full_name': ruby.string_value(package.full_name)
		'tap':       ruby.string_value(package.tap.name)
		'version':   ruby.string_value(package.version)
	})
}

fn info_github_path(value ruby.Value) string {
	package := info_package_from_value(value)
	if package.kind == 'formula' {
		if package.tap.name == '' || package.tap.remote == '' {
			return package.path
		}
		prefix := package.tap.path.trim_string_right('/') + '/'
		if !package.path.starts_with(prefix) {
			return package.path
		}
		relative := package.path[prefix.len..]
		return ruby_info_l147_d2_github_remote_path(ruby.string_value(package.tap.remote), ruby.string_value(relative)).as_string()
	}
	if package.tap.name == '' || package.tap.remote == '' {
		return package.sourcefile_path
	}
	if package.sourcefile_path == '' || !package.sourcefile_path.ends_with('.rb') {
		return '${package.tap.default_remote}/blob/HEAD/Casks/${package.name}.rb'
	}
	prefix := package.tap.path.trim_string_right('/') + '/'
	relative := if package.sourcefile_path.starts_with(prefix) {
		package.sourcefile_path[prefix.len..]
	} else {
		package.sourcefile_path
	}
	return ruby_info_l147_d2_github_remote_path(ruby.string_value(package.tap.remote), ruby.string_value(relative)).as_string()
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

fn info_installed_section_lines(value ruby.Value, verbose bool) []string {
	package := info_package_from_value(value)
	mut related_values := [value]
	for item in package.related {
		candidate := info_package_from_value(item)
		if related_values.all(info_package_from_value(it).full_name != candidate.full_name) {
			related_values << item
		}
	}
	mut installed := related_values.filter(info_package_from_value(it).installed_kegs.len > 0)
	installed.sort_with_compare(fn (left &ruby.Value, right &ruby.Value) int {
		left_package := info_package_from_value(*left)
		right_package := info_package_from_value(*right)
		mut left_version := left_package.version
		for keg in left_package.installed_kegs {
			if info_version_compare(keg.version, left_version) > 0 {
				left_version = keg.version
			}
		}
		mut right_version := right_package.version
		for keg in right_package.installed_kegs {
			if info_version_compare(keg.version, right_version) > 0 {
				right_version = keg.version
			}
		}
		return -info_version_compare(left_version, right_version)
	})
	mut result := []string{}
	for item in installed {
		current := info_package_from_value(item)
		mut kegs := current.installed_kegs.clone()
		kegs.sort_with_compare(fn (left &InfoKegModel, right &InfoKegModel) int {
			if left.head != right.head {
				return if left.head { -1 } else { 1 }
			}
			if left.head {
				return int(right.tab.time - left.tab.time)
			}
			return -info_version_compare(left.version, right.version)
		})
		for index, keg in kegs {
			if !verbose && index > 0 && !keg.linked {
				continue
			}
			mut version := keg.version
			if index == 0 && current.outdated && current.version != '' && current.version != keg.version {
				version += ' → ${current.version}'
			}
			name := info_status_text(current.full_name, true, current.outdated, false, false, false, false, current.tty)
			mut line := '${name} ${version} (${keg.size}B)'
			if keg.linked {
				line += ' [Linked]'
			}
			result << line
			if verbose && keg.tab.text != '' { result << '  ${keg.tab.text}' }
		}
	}
	return result
}

fn info_formula_summary_text(value ruby.Value) string {
	package := info_package_from_value(value)
	mut lines := [
		'==> ${info_summary_title(package, package.installed_kegs.len > 0)}',
	]
	if package.installed_kegs.len == 0 {
		lines << 'Formula from ${info_github_path(value)}'
		lines << 'Not installed'
	} else {
		mut kegs := package.installed_kegs.clone()
		kegs.sort_with_compare(fn (left &InfoKegModel, right &InfoKegModel) int {
			return info_version_compare(left.version, right.version)
		})
		version := kegs.map(it.version).join(', ')
		tab := kegs.last().tab
		source := if package.tap.name != '' {
			package.tap.name
		} else if tab.source_tap != '' {
			tab.source_tap
		} else if tab.source_path != '' {
			tab.source_path
		} else {
			info_github_path(value)
		}
		lines << 'Formula from ${source}'
		lines << ruby_info_l192_d6_self_installation_summary(ruby.string_value(version), info_tab_value(tab)).as_string()
	}
	return lines.join('\n') + '\n'
}

fn info_cask_summary_text(value ruby.Value) string {
	package := info_package_from_value(value)
	installed := package.installed_version != ''
	mut lines := ['==> ${info_summary_title(package, installed)}']
	if installed {
		tab_value := value.map_data['tab'] or { ruby.Value{} }
		tab := info_tab_from_value(tab_value)
		source := if package.tap.name != '' {
			package.tap.name
		} else if tab.source_tap != '' {
			tab.source_tap
		} else if package.sourcefile_path != '' {
			package.sourcefile_path
		} else if tab.source_path != '' {
			tab.source_path
		} else {
			info_github_path(value)
		}
		lines << 'Cask from ${source}'
		lines << ruby_info_l192_d6_self_installation_summary(ruby.string_value(package.installed_version), info_tab_value(tab)).as_string()
	} else {
		lines << 'Cask from ${info_github_path(value)}'
		lines << 'Not installed'
	}
	return lines.join('\n') + '\n'
}

fn info_formula_text(value ruby.Value, verbose bool, shadowed_by string) string {
	package := info_package_from_value(value)
	shadowing_value := ruby_info_l703_d26_shadowing_installed_formula(value)
	has_shadowing := shadowing_value.type_name != 'NilClass'
	kegs := if has_shadowing { []InfoKegModel{} } else { package.installed_kegs.clone() }
	mut specs := []string{}
	if package.has_stable && package.stable_version != '' {
		mut stable := 'stable ${package.stable_version}'
		if package.stable_bottled && package.pour_bottle {
			stable += ' (bottled)'
		}
		specs << stable
	}
	if package.has_head { specs << 'HEAD' }
	installed := kegs.len > 0
	if installed && package.outdated && specs.len > 0 {
		mut newest := kegs[0].version
		for keg in kegs {
			if info_version_compare(keg.version, newest) > 0 {
				newest = keg.version
			}
		}
		specs[0] = '${newest} → ${specs[0]}'
	}
	title_name := if has_shadowing && package.tap.name != '' {
		'${package.tap.name}/${package.name}'
	} else if shadowed_by != '' {
		package.name
	} else {
		package.full_name
	}
	status_name := info_status_text(title_name, installed, package.outdated, package.deprecated, package.disabled, false, false, package.tty)
	mut headline := '==> ${status_name}: ${specs.join(', ')}'
	if package.keg_only {
		headline += ' [keg-only]'
	}
	mut lines := [headline]
	if shadowed_by != '' {
		lines << 'Warning: `${package.name}` shadows `${shadowed_by}/${package.name}`.'
	}
	if package.description != '' { lines << package.description }
	if package.homepage != '' { lines << package.homepage }
	if package.aliases.len > 0 { lines << 'Aliases: ${package.aliases.join(', ')}' }
	if package.old_names.len > 0 { lines << 'Old Names: ${package.old_names.join(', ')}' }
	if package.deprecate_message != '' {
		lines << package.deprecate_message[..1].to_upper() + package.deprecate_message[1..]
	}
	mut conflicts := []string{}
	for conflict in package.conflicts {
		if conflict.resolved_full_name == package.full_name {
			continue
		}
		name := if conflict.resolved_full_name != '' {
			conflict.resolved_full_name
		} else {
			conflict.name
		}
		conflicts << name + if conflict.reason != '' { ' (because ${conflict.reason})' } else { '' }
	}
	conflicts.sort()
	if conflicts.len > 0 { lines << 'Conflicts with:\n  ${conflicts.join('\n  ')}' }
	if !installed {
		lines << 'Not installed'
		if package.bottle_size > 0 { lines << 'Bottle Size: ${package.bottle_size}B' }
		if package.installed_size > 0 { lines << 'Installed Size: ${package.installed_size}B' }
	} else {
		lines << ruby_info_l178_d4_self_installation_status(info_tab_value(kegs.last().tab)).as_string()
	}
	lines << 'From: ${info_github_path(value)}'
	if package.tap.name != '' && !package.tap.official { lines << 'Tap: ${package.tap.name}' }
	if package.license != '' { lines << 'License: ${package.license}' }
	if info_bool_attr(value, 'tty', false) {
		metadata := ruby_info_l156_d3_self_metadata_lines(value, ruby.bool_value(true)).as_string_array() or { [] }
		lines << metadata
	}
	installed_lines := info_installed_section_lines(if has_shadowing {
		shadowing_value
	} else {
		value
	}, verbose)
	if installed_lines.len > 0 {
		lines << if verbose { '==> Installed Kegs and Versions' } else { '==> Installed Versions' }
		lines << installed_lines
	}
	mut dependency_lines := []string{}
	for kind in ['build', 'required', 'recommended', 'optional'] {
		if kind == 'build' {
			all_poured := installed && kegs.all(it.tab.poured_from_bottle)
			would_pour := !installed && (package.requirements.any(it.other_os) || (package.has_stable && package.stable_bottled && package.pour_bottle) || (!package.has_stable && !package.has_head))
			if all_poured || would_pour {
				continue
			}
		}
		deps := package.dependencies.filter(it.kind == kind)
		if deps.len > 0 {
			dependency_lines << '${kind.capitalize()} (${deps.len}): ${info_decorate_dependencies(deps, installed, package.tty)}'
		}
	}
	runtime_deps := if installed {
		kegs.last().tab.runtime_dependencies
	} else {
		[]string{}
	}
	if dependency_lines.len > 0 || runtime_deps.len > 0 || package.dependent_names.len > 0 {
		lines << '==> Dependencies'
		lines << dependency_lines
		if runtime_deps.len > 0 {
			installed_count := runtime_deps.filter(it in package.runtime_dependency_installed).len
			lines << 'Recursive Runtime (${runtime_deps.len}): ${ruby_info_l204_d8_self_dependency_status_counts(ruby.int_value(installed_count), ruby.int_value(runtime_deps.len)).as_string()}'
		}
		if package.dependent_names.len > 0 {
			mut names := package.dependent_names.clone()
			names.sort()
			lines << if verbose {
				'Dependents (${names.len}): ${names.join(', ')}'
			} else {
				'Dependents: ${names.len}'
			}
		}
	}
	if package.requirements.len > 0 {
		lines << '==> Requirements'
		for kind in ['build', 'required', 'recommended', 'optional'] {
			requirements := package.requirements.filter(it.kind == kind)
			if requirements.len > 0 {
				lines << '${kind.capitalize()}: ${info_decorate_requirements(requirements, installed, package.tty)}'
			}
		}
	}
	if package.options.len > 0 || package.has_head {
		lines << '==> Options'
		lines << package.options
	}
	if verbose {
		mut binaries := []string{}
		if installed {
			mut selected := kegs.last()
			for keg in kegs {
				if keg.linked {
					selected = keg
					break
				}
			}
			binaries = selected.binaries.clone()
		} else {
			binaries = package.bottle_binaries.map(os.base(it))
		}
		binaries.sort()
		binaries = info_unique_strings(binaries)
		if binaries.len > 0 {
			lines << '==> Binaries'
			lines << binaries
		}
	}
	if package.caveats != '' {
		lines << '==> Caveats'
		lines << package.caveats
	}
	return lines.join('\n') + '\n'
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

// Ruby method `github_remote_path(remote, path)` at line 147.
pub fn ruby_info_l147_d2_github_remote_path(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('github_remote_path requires remote and path') }
	remote := args[0].as_string().trim_string_right('/')
	path := args[1].as_string().trim_string_left('/')
	mut repository := ''
	if remote.starts_with('https://github.com/') || remote.starts_with('http://github.com/') || remote.starts_with('git://github.com/') {
		repository = remote.all_after('github.com/')
	} else if remote.starts_with('git@github.com:') {
		repository = remote.all_after('git@github.com:')
	}
	if repository != '' {
		repository = repository.trim_string_right('.git')
		return ruby.string_value('https://github.com/${repository}/blob/HEAD/${path}')
	}
	return ruby.string_value('${remote}/${path}')
}

// Ruby method `self.metadata_lines(formula_or_cask)` at line 156.
pub fn ruby_info_l156_d3_self_metadata_lines(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('metadata_lines requires a formula or cask') }
	tty := args.len < 2 || args[1].bool_data
	if !tty {
		return ruby.string_array_value([])
	}
	package := info_package_from_value(args[0])
	if package.kind == 'cask' {
		if !package.pinned {
			return ruby.string_array_value([])
		}
		mut line := 'Pinned: ${package.pinned_version}'
		mtime := if package.pin_mtime > 0 {
			package.pin_mtime
		} else {
			pin := ruby_info_l264_d12_self_pin_path_mtime(ruby.object_value('Pathname', package.pin_path))
			if pin.type_name == 'Integer' { pin.int_data } else { i64(0) }
		}
		if mtime > 0 {
			line += ' on ${ruby_info_l257_d11_self_formatted_time(ruby.int_value(mtime)).as_string()}'
		}
		return ruby.string_array_value([line])
	}
	return ruby_info_l238_d10_self_formula_metadata_lines(args[0])
}

// Ruby method `self.installation_status(tab)` at line 178.
pub fn ruby_info_l178_d4_self_installation_status(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('installation_status requires a tab') }
	tab := info_tab_from_value(args[0])
	return ruby.string_value(if tab.installed_on_request {
		'Installed (on request)'
	} else {
		'Installed (as dependency)'
	})
}

// Ruby method `self.installation_reason(tab)` at line 185.
pub fn ruby_info_l185_d5_self_installation_reason(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('installation_reason requires a tab') }
	tab := info_tab_from_value(args[0])
	if !tab.installed_on_request_present {
		return ruby.string_value('-')
	}
	return ruby.string_value(if tab.installed_on_request {
		'on request'
	} else {
		'dependency'
	})
}

// Ruby method `self.installation_summary(version, tab)` at line 192.
pub fn ruby_info_l192_d6_self_installation_summary(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('installation_summary requires version and tab') }
	reason := ruby_info_l185_d5_self_installation_reason(args[1]).as_string()
	mut summary := 'Installed: ${args[0].as_string()}'
	if reason != '-' {
		summary += ' (${reason})'
	}
	return ruby.string_value(summary)
}

// Ruby method `self.dependency_status_counts(installed_count, total_count)` at line 204.
pub fn ruby_info_l204_d8_self_dependency_status_counts(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('dependency_status_counts requires two counts') }
	installed := args[0].as_int() or { panic(err) }
	total := args[1].as_int() or { panic(err) }
	missing := total - installed
	if missing == 0 {
		return ruby.string_value('all installed ✔')
	}
	return ruby.string_value('${installed} installed ✔, ${missing} missing ✘')
}

// Ruby method `self.formula_metadata_lines(formula)` at line 238.
pub fn ruby_info_l238_d10_self_formula_metadata_lines(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('formula_metadata_lines requires a formula') }
	package := info_package_from_value(args[0])
	mut metadata := []string{}
	if package.pinned {
		mut pinned := 'Pinned: ${package.pinned_version}'
		mtime := if package.pin_mtime > 0 {
			package.pin_mtime
		} else {
			pin := ruby_info_l264_d12_self_pin_path_mtime(ruby.object_value('Pathname', package.pin_path))
			if pin.type_name == 'Integer' { pin.int_data } else { i64(0) }
		}
		if mtime > 0 {
			pinned += ' on ${ruby_info_l257_d11_self_formatted_time(ruby.int_value(mtime)).as_string()}'
		}
		metadata << pinned
	}
	if !package.any_version_installed && ruby_info_l271_d13_self_formula_installs_from_source(args[0]).bool_data && package.requirements.all(!it.other_os) {
		metadata << 'Installs from source: yes'
	}
	return ruby.string_array_value(metadata)
}

// Ruby method `self.formatted_time(time)` at line 257.
pub fn ruby_info_l257_d11_self_formatted_time(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('formatted_time requires a time') }
	seconds := if args[0].type_name == 'Integer' {
		args[0].int_data
	} else {
		info_int_attr(args[0], 'unix', args[0].repr.i64())
	}
	return ruby.string_value(time.unix(seconds).local().custom_format('YYYY-MM-DD at HH:mm:ss'))
}

// Ruby method `self.pin_path_mtime(pin_path)` at line 264.
pub fn ruby_info_l264_d12_self_pin_path_mtime(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('pin_path_mtime requires a path') }
	path := args[0].as_string()
	if !os.exists(path) && !os.is_link(path) {
		return info_nil()
	}
	return ruby.int_value(os.file_last_mod_unix(path))
}

// Ruby method `self.formula_installs_from_source?(formula)` at line 271.
pub fn ruby_info_l271_d13_self_formula_installs_from_source(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('formula_installs_from_source requires a formula') }
	package := info_package_from_value(args[0])
	if !package.has_stable && package.has_head {
		return ruby.bool_value(true)
	}
	if !package.has_stable {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(!package.stable_bottled || !package.pour_bottle)
}

// Ruby method `installed_resolution(formula)` at line 358.
pub fn ruby_info_l358_d17_installed_resolution(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('installed_resolution requires a formula') }
	package := info_package_from_value(args[0])
	if package.installed_kegs.len == 0 || package.installed_tap == '' || package.installed_tap == package.tap.name || package.resolution_formula.type_name == '' {
		return ruby.array_value([args[0], info_nil()])
	}
	return ruby.array_value([package.resolution_formula, info_tap_value(package.tap)])
}

// Ruby method `shadowing_installed_formula(formula)` at line 703.
pub fn ruby_info_l703_d26_shadowing_installed_formula(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('shadowing_installed_formula requires a formula') }
	resolution := ruby_info_l358_d17_installed_resolution(args[0]).as_array() or { [] }
	if resolution.len > 1 && resolution[1].type_name != 'NilClass' {
		return resolution[0]
	}
	return info_nil()
}
