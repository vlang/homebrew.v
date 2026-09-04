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
				'cask'} else {
				'formula'}}
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 93.
pub fn ruby_info_l93_d1_run(args ...ruby.Value) ruby.Value {
	config := if args.len > 0 { args[0] } else { ruby.map_value({}) }
	if info_bool_attr(config, 'sizes', false) {
		return ruby_info_l950_d38_print_sizes(config, config.map_data['formulae'] or {
			ruby.array_value([])
		}, config.map_data['casks'] or { ruby.array_value([]) })
	}
	if info_bool_attr(config, 'analytics', false) {
		days := config.attributes['days'] or { '' }
		if days != '' && days !in ['30', '90', '365'] {
			return ruby.object_value('UsageError', '`--days` must be one of 30, 90, 365.')
		}
		category := config.attributes['category'] or { '' }
		named := info_values(config, 'named')
		if category != '' && named.len > 0 && category !in ['install', 'install-on-request',
			'build-error'] {
			return ruby.object_value('UsageError', '`--category` must be one of install, install-on-request, build-error when querying formulae.')
		}
		if category != '' && category !in ['install', 'install-on-request', 'build-error',
			'cask-install', 'os-version'] {
			return ruby.object_value('UsageError', '`--category` must be one of install, install-on-request, build-error, cask-install, os-version.')
		}
		return ruby_info_l643_d22_print_analytics(config)
	}
	json_value := config.map_data['json'] or { info_nil() }
	if json_value.type_name != 'NilClass' && json_value.type_name != '' {
		return ruby_info_l729_d29_print_json(config, json_value, ruby.bool_value(info_bool_attr(config, 'eval_all', false)))
	}
	if info_bool_attr(config, 'installed', false) {
		mut blocks := []string{}
		for value in info_values(config, 'installed_packages') {
			blocks << ruby_info_l685_d25_info_formula_or_cask(value, ruby.bool_value(!info_bool_attr(config, 'verbose', false))).as_string()
		}
		return ruby.string_value(blocks.join('\n\n') + if blocks.len > 0 {
			'\n'
		} else {
			''
		})
	}
	if info_bool_attr(config, 'github', false) {
		objects := info_values(config, 'named')
		if objects.len == 0 {
			return ruby.object_value('FormulaOrCaskUnspecifiedError', 'Formula or cask unspecified')
		}
		return ruby.string_array_value(objects.map(ruby_info_l371_d18_github_info(it).as_string()))
	}
	if info_values(config, 'named').len == 0 {
		return ruby_info_l635_d21_print_statistics(config)
	}
	return ruby_info_l318_d15_print_info(config, ruby.bool_value(info_bool_attr(config, 'quiet', false)))
}

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

// Ruby method `self.requirement_for_other_os?(requirement)` at line 199.
pub fn ruby_info_l199_d7_self_requirement_for_other_os(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('requirement_for_other_os requires a requirement') }
	return ruby.bool_value(info_requirement_from_value(args[0]).other_os)
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

// Ruby method `self.installed_dependent_names(full_name, name)` at line 213.
pub fn ruby_info_l213_d9_self_installed_dependent_names(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('installed_dependent_names requires full_name and name') }
	full_name := args[0].as_string()
	name := args[1].as_string()
	racks := if args.len > 2 { args[2].as_array() or { [] } } else { []ruby.Value{} }
	mut result := []string{}
	for rack in racks {
		content := rack.attributes['receipt_content'] or { '' }
		if content != '' && !content.contains(name) {
			continue
		}
		deps := info_string_list(rack, 'runtime_dependencies')
		if deps.any(it == full_name || it.all_after_last('/') == name) {
			result << (rack.attributes['name'] or { rack.repr })
		}
	}
	result.sort()
	return ruby.string_array_value(info_unique_strings(result))
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

// Ruby method `self.collect_cask_dependency_names(cask, formula_dependencies, cask_dependencies, visited_casks)` at line 282.
pub fn ruby_info_l282_d14_self_collect_cask_dependency_names(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('collect_cask_dependency_names requires a cask') }
	mut formulae := if args.len > 1 { args[1].as_string_array() or { [] } } else { []string{} }
	mut casks := if args.len > 2 { args[2].as_string_array() or { [] } } else { []string{} }
	mut visited := if args.len > 3 { args[3].as_string_array() or { [] } } else { []string{} }
	mut pending := [args[0]]
	for pending.len > 0 {
		current := pending[0]
		pending.delete(0)
		for name in info_string_list(current, 'formula_dependencies') {
			if name !in formulae { formulae << name }
			runtime_map := current.map_data['formula_runtime_dependencies'] or { ruby.map_value({}) }
			if runtime := runtime_map.map_data[name] {
				for dep in runtime.as_string_array() or { [] } {
					if dep !in formulae { formulae << dep }
				}
			}
		}
		dependency_map := current.map_data['cask_dependency_values'] or { ruby.map_value({}) }
		for token in info_string_list(current, 'cask_dependencies') {
			if token in visited {
				continue
			}
			visited << token
			if token !in casks { casks << token }
			if dependency := dependency_map.map_data[token] {
				if dependency.type_name != 'CaskUnavailableError' { pending << dependency }
			}
		}
	}
	return ruby.map_value({
		'formula_dependencies': ruby.string_array_value(formulae)
		'cask_dependencies':    ruby.string_array_value(casks)
		'visited_casks':        ruby.string_array_value(visited)
	})
}

// Ruby method `print_info(quiet: false)` at line 318.
pub fn ruby_info_l318_d15_print_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('print_info requires a command context') }
	context := args[0]
	quiet := args.len > 1 && args[1].bool_data
	objects := info_values(context, 'objects')
	inputs := info_string_list(context, 'input_names')
	mut resolved := []ruby.Value{}
	for index, object in objects {
		qualified := index < inputs.len && inputs[index].contains('/')
		if info_package_from_value(object).kind == 'formula' {
			resolved << ruby_info_l678_d24_display_resolution(object, ruby.bool_value(qualified))
		} else {
			resolved << ruby.array_value([object, info_nil()])
		}
	}
	unique := ruby_info_l668_d23_unique_by_display_name(ruby.array_value(resolved)).as_array() or { [] }
	mut output := []string{}
	mut errors := []string{}
	for pair in unique {
		parts := pair.as_array() or { [] }
		if parts.len == 0 {
			continue
		}
		object := parts[0]
		if object.type_name == 'FormulaOrCaskUnavailableError' {
			errors << object.repr
			if reason := object.map_data['reason'] {
				if reason.type_name != 'NilClass' && reason.repr != '' { errors << reason.repr }
			}
			continue
		}
		shadowed := if parts.len > 1 { parts[1] } else { info_nil() }
		output << ruby_info_l685_d25_info_formula_or_cask(object, ruby.bool_value(quiet), shadowed).as_string().trim_string_right('\n')
	}
	return ruby.Value{
		type_name: 'InfoResult'
		repr: if output.len > 0 { output.join('\n\n') + '\n' } else { '' }
		map_data: {
			'stderr': ruby.string_value(if errors.len > 0 {
				errors.join('\n') + '\n'} else {
				''})
		}
	}
}

// Ruby method `formula_qualified_by_user?(formula_or_cask, qualified_inputs)` at line 347.
pub fn ruby_info_l347_d16_formula_qualified_by_user(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('formula_qualified_by_user requires a package and names') }
	qualified := args[1].as_string_array() or { [] }
	if qualified.len == 0 {
		return ruby.bool_value(false)
	}
	package := info_package_from_value(args[0])
	mut names := [package.full_name.to_lower()]
	if package.tap.name != '' { names << '${package.tap.name}/${package.name}'.to_lower() }
	return ruby.bool_value(names.any(it in qualified.map(it.to_lower())))
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

// Ruby method `github_info(formula_or_cask)` at line 371.
pub fn ruby_info_l371_d18_github_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('github_info requires a formula or cask') }
	return ruby.string_value(info_github_path(args[0]))
}

// Ruby method `info_formula_summary(formula)` at line 404.
pub fn ruby_info_l404_d19_info_formula_summary(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('info_formula_summary requires a formula') }
	return ruby.string_value(info_formula_summary_text(args[0]))
}

// Ruby method `info_formula(formula, shadowed_by: nil)` at line 426.
pub fn ruby_info_l426_d20_info_formula(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('info_formula requires a formula') }
	shadowed_by := if args.len > 1 && args[1].type_name != 'NilClass' {
		info_tap_from_value(args[1]).name
	} else {
		''
	}
	verbose := args.len > 2 && args[2].bool_data
	return ruby.string_value(info_formula_text(args[0], verbose, shadowed_by))
}

// Ruby method `print_statistics` at line 635.
pub fn ruby_info_l635_d21_print_statistics(args ...ruby.Value) ruby.Value {
	if args.len == 0 || !info_bool_attr(args[0], 'cellar_exists', false) {
		return ruby.string_value('')
	}
	count := info_int_attr(args[0], 'rack_count', 0)
	size := info_int_attr(args[0], 'cellar_size', 0)
	return ruby.string_value('${count} ${if count == 1 { 'keg' } else { 'kegs' }}, ${size}B\n')
}

// Ruby method `print_analytics` at line 643.
pub fn ruby_info_l643_d22_print_analytics(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	context := args[0]
	objects := info_values(context, 'named')
	if objects.len == 0 {
		return context.map_data['global_analytics'] or { ruby.string_value('') }
	}
	mut blocks := []string{}
	for object in objects {
		if analytics := object.map_data['analytics'] {
			blocks << analytics.as_string()
		}
	}
	return ruby.string_value(blocks.join('\n\n') + if blocks.len > 0 { '\n' } else { '' })
}

// Ruby method `unique_by_display_name(resolved)` at line 668.
pub fn ruby_info_l668_d23_unique_by_display_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	pairs := args[0].as_array() or { [] }
	mut seen := map[string]bool{}
	mut result := []ruby.Value{}
	for pair in pairs {
		items := pair.as_array() or { [] }
		if items.len == 0 {
			continue
		}
		object := items[0]
		package := info_package_from_value(object)
		key := if package.kind in ['formula', 'cask'] {
			package.full_name
		} else {
			'${object.type_name}:${object.repr}'
		}
		if seen[key] or { false } {
			continue
		}
		seen[key] = true
		result << pair
	}
	return ruby.array_value(result)
}

// Ruby method `display_resolution(formula, user_qualified:)` at line 678.
pub fn ruby_info_l678_d24_display_resolution(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('display_resolution requires a formula') }
	if args.len > 1 && args[1].bool_data {
		return ruby.array_value([args[0], info_nil()])
	}
	return ruby_info_l358_d17_installed_resolution(args[0])
}

// Ruby method `info_formula_or_cask(formula_or_cask, quiet:, shadowed_by: nil)` at line 685.
pub fn ruby_info_l685_d25_info_formula_or_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('info_formula_or_cask requires a package') }
	quiet := args.len > 1 && args[1].bool_data
	shadowed := if args.len > 2 { args[2] } else { info_nil() }
	package := info_package_from_value(args[0])
	if package.kind == 'formula' {
		return if quiet {
			ruby_info_l404_d19_info_formula_summary(args[0])
		} else {
			ruby_info_l426_d20_info_formula(args[0], shadowed, ruby.bool_value(info_bool_attr(args[0], 'verbose', false)))
		}
	}
	return if quiet {
		ruby_info_l900_d36_info_cask_summary(args[0])
	} else {
		ruby_info_l893_d35_info_cask(args[0])
	}
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

// Ruby method `swap_to_installed_formula(formula, qualified_inputs)` at line 709.
pub fn ruby_info_l709_d27_swap_to_installed_formula(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('swap_to_installed_formula requires formula and qualified inputs') }
	if ruby_info_l347_d16_formula_qualified_by_user(args[0], args[1]).bool_data {
		return args[0]
	}
	resolution := ruby_info_l358_d17_installed_resolution(args[0]).as_array() or { return args[0] }
	return if resolution.len > 0 { resolution[0] } else { args[0] }
}

// Ruby method `json_version(version)` at line 716.
pub fn ruby_info_l716_d28_json_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('json_version requires a value') }
	version := if args[0].type_name == 'Bool' && args[0].bool_data {
		'default'
	} else {
		args[0].as_string()
	}
	if version !in ['default', 'v1', 'v2'] {
		return ruby.object_value('UsageError', 'invalid JSON version: ${version}')
	}
	return ruby.object_value('Symbol', ':${version}')
}

// Ruby method `print_json(json, eval_all)` at line 729.
pub fn ruby_info_l729_d29_print_json(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('print_json requires context and version') }
	context := args[0]
	eval_all := args.len > 2 && args[2].bool_data
	installed := info_bool_attr(context, 'installed', false)
	named := info_values(context, 'named_formulae')
	named_casks := info_values(context, 'named_casks')
	if !eval_all && !installed && named.len == 0 && named_casks.len == 0 {
		return ruby.object_value('FormulaOrCaskUnspecifiedError', 'Formula or cask unspecified')
	}
	version := ruby_info_l716_d28_json_version(args[1])
	if version.type_name == 'UsageError' {
		return version
	}
	qualified := ruby.string_array_value(info_string_list(context, 'qualified_inputs'))
	mut formulae := if eval_all {
		info_values(context, 'all_formulae')
	} else if installed {
		info_values(context, 'installed_formulae')
	} else {
		named.clone()
	}
	if !eval_all && !installed {
		formulae = formulae.map(ruby_info_l709_d27_swap_to_installed_formula(it, qualified))
	}
	if version.repr in [':default', ':v1'] {
		if info_bool_attr(context, 'cask_only', false) {
			return ruby.object_value('UsageError', 'Cannot specify `--cask` when using `--json=v1`!')
		}
		result := ruby.array_value(formulae.map(info_package_hash(it)))
		return ruby.string_value('${json2.encode(info_value_to_json(result), prettify: true)}\n')
	}
	mut casks := if eval_all {
		info_values(context, 'all_casks')
	} else if installed {
		info_values(context, 'installed_casks')
	} else {
		named_casks.clone()
	}
	if info_bool_attr(context, 'formula_only', false) {
		casks = []
	}
	if info_bool_attr(context, 'cask_only', false) {
		formulae = []
	}
	result := ruby.map_value({
		'formulae': ruby.array_value(formulae.map(info_package_hash(it)))
		'casks':    ruby.array_value(casks.map(info_package_hash(it)))
	})
	return ruby.string_value('${json2.encode(info_value_to_json(result), prettify: true)}\n')
}

// Ruby method `info_summary_title(name, description, installed:)` at line 792.
pub fn ruby_info_l792_d30_info_summary_title(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('info_summary_title requires name and description') }
	installed := args.len > 2 && args[2].bool_data
	tty := args.len > 3 && args[3].bool_data
	mut name := args[0].as_string()
	if installed && tty {
		name += ' ✔'
	}
	description := args[1].as_string()
	return ruby.string_value(name + if description != '' { ': ${description}' } else { '' })
}

// Ruby method `installed_section_lines(formula, verbose: false)` at line 799.
pub fn ruby_info_l799_d31_installed_section_lines(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('installed_section_lines requires a formula') }
	verbose := args.len > 1 && args[1].bool_data
	return ruby.string_array_value(info_installed_section_lines(args[0], verbose))
}

// Ruby method `decorate_dependencies(dependencies, tab_runtime_deps: nil, mark_uninstalled: true,` at line 854.
pub fn ruby_info_l854_d32_decorate_dependencies(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	dependencies := (args[0].as_array() or { [] }).map(info_dependency_from_value(it))
	mark_uninstalled := args.len < 3 || args[2].bool_data
	tty := args.len > 4 && args[4].bool_data
	return ruby.string_value(info_decorate_dependencies(dependencies, mark_uninstalled, tty))
}

// Ruby method `decorate_requirements(requirements, mark_uninstalled: true)` at line 877.
pub fn ruby_info_l877_d33_decorate_requirements(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	requirements := (args[0].as_array() or { [] }).map(info_requirement_from_value(it))
	mark_uninstalled := args.len < 2 || args[1].bool_data
	tty := args.len > 2 && args[2].bool_data
	return ruby.string_value(info_decorate_requirements(requirements, mark_uninstalled, tty))
}

// Ruby method `dep_display_s(dep)` at line 886.
pub fn ruby_info_l886_d34_dep_display_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('dep_display_s requires a dependency') }
	return ruby.string_value(info_dep_display(info_dependency_from_value(args[0])))
}

// Ruby method `info_cask(cask)` at line 893.
pub fn ruby_info_l893_d35_info_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('info_cask requires a cask') }
	package := info_package_from_value(args[0])
	return ruby.string_value(if package.info != '' { package.info } else { args[0].repr })
}

// Ruby method `info_cask_summary(cask)` at line 900.
pub fn ruby_info_l900_d36_info_cask_summary(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('info_cask_summary requires a cask') }
	return ruby.string_value(info_cask_summary_text(args[0]))
}

// Ruby method `print_sizes_table(title, items)` at line 928.
pub fn ruby_info_l928_d37_print_sizes_table(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('print_sizes_table requires a title and items') }
	items := (args[1].as_array() or { [] }).map(InfoNameSize{
		name: it.attributes['name'] or { it.repr }
		size: info_int_attr(it, 'size', 0)
	})
	return ruby.string_value(info_sizes_table(args[0].as_string(), items))
}

// Ruby method `print_sizes(formulae: [], casks: [])` at line 950.
pub fn ruby_info_l950_d38_print_sizes(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('print_sizes requires a context') }
	context := args[0]
	mut formulae := if args.len > 1 { args[1].as_array() or { [] } } else { []ruby.Value{} }
	mut casks := if args.len > 2 { args[2].as_array() or { [] } } else { []ruby.Value{} }
	formula_only := info_bool_attr(context, 'formula_only', false)
	cask_only := info_bool_attr(context, 'cask_only', false)
	if formulae.len == 0 && (formula_only || (!cask_only && info_bool_attr(context, 'no_named', true))) {
		formulae = info_values(context, 'installed_formulae')
	}
	if casks.len == 0 && (cask_only || (!formula_only && info_bool_attr(context, 'no_named', true))) {
		casks = info_values(context, 'installed_casks')
	}
	mut output := ''
	if !cask_only {
		mut items := []InfoNameSize{}
		for value in formulae {
			package := info_package_from_value(value)
			mut size := i64(0)
			for keg in package.installed_kegs {
				size += keg.size
			}
			items << InfoNameSize{ name: package.full_name, size: size }
		}
		items.sort_with_compare(fn (left &InfoNameSize, right &InfoNameSize) int {
			return int(right.size - left.size)
		})
		output += info_sizes_table('Formulae sizes:', items)
	}
	if !formula_only {
		mut items := []InfoNameSize{}
		for value in casks {
			package := info_package_from_value(value)
			if package.installed_version != '' && info_bool_attr(value, 'staged_path_exists', true) {
				items << InfoNameSize{ name: package.full_name, size: package.size }
			}
		}
		items.sort_with_compare(fn (left &InfoNameSize, right &InfoNameSize) int {
			return int(right.size - left.size)
		})
		output += info_sizes_table('Casks sizes:', items)
	}
	return ruby.string_value(output)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "missing_formula"
// 6: require "caveats"
// 7: require "options"
// 8: require "formula"
// 9: require "formula_pin"
// 10: require "keg"
// 11: require "tab"
// 12: require "json"
// 13: require "cask/cask_loader"
// 14: require "utils/spdx"
// 15: require "deprecate_disable"
// 16: require "api"
// 17:
// 18: module Homebrew
// 19:   module Cmd
// 20:     class Info < AbstractCommand
// 21:       class NameSize < T::Struct
// 22:         const :name, String
// 23:         const :size, Integer
// 24:       end
// 25:       private_constant :NameSize
// 26:
// 27:       VALID_DAYS = %w[30 90 365].freeze
// 28:       VALID_FORMULA_CATEGORIES = %w[install install-on-request build-error].freeze
// 29:       VALID_CATEGORIES = T.let((VALID_FORMULA_CATEGORIES + %w[cask-install os-version]).freeze, T::Array[String])
// 30:
// 31:       cmd_args do
// 32:         description <<~EOS
// 33:           Display brief statistics for your Homebrew installation.
// 34:           If a <formula> or <cask> is provided, show summary of information about it.
// 35:         EOS
// 36:         switch "--analytics",
// 37:                description: "List global Homebrew analytics data or, if specified, installation and " \
// 38:                             "build error data for <formula> (provided neither `$HOMEBREW_NO_ANALYTICS` " \
// 39:                             "nor `$HOMEBREW_NO_GITHUB_API` are set)."
// 40:         flag   "--days=",
// 41:                depends_on:  "--analytics",
// 42:                description: "How many days of analytics data to retrieve. " \
// 43:                             "The value for <days> must be `30`, `90` or `365`. The default is `30`."
// 44:         flag   "--category=",
// 45:                depends_on:  "--analytics",
// 46:                description: "Which type of analytics data to retrieve. " \
// 47:                             "The value for <category> must be `install`, `install-on-request` or `build-error`; " \
// 48:                             "`cask-install` or `os-version` may be specified if <formula> is not. " \
// 49:                             "The default is `install`."
// 50:         switch "--github-packages-downloads",
// 51:                description: "Scrape GitHub Packages download counts from HTML for a core formula.",
// 52:                hidden:      true
// 53:         switch "--github",
// 54:                description: "Open the GitHub source page for <formula> and <cask> in a browser. " \
// 55:                             "To view the history locally: `brew log -p` <formula> or <cask>"
// 56:         switch "--fetch-manifest",
// 57:                description: "Fetch GitHub Packages manifest for extra information when <formula> is not installed.",
// 58:                odeprecated: true
// 59:         flag   "--json",
// 60:                description: "Print a JSON representation. Currently the default value for <version> is `v1`." \
// 61:                             "`v1` is valid for <formula> only. `v2` is valid for both <formula> and <cask>." \
// 62:                             "See the docs for examples of using the JSON output: <https://docs.brew.sh/Querying-Brew>"
// 63:         switch "--installed",
// 64:                description: "Output a human-readable inventory of installed formulae and casks. If `--json` is " \
// 65:                             "passed, print JSON for installed formulae and, with `--json=v2`, installed casks."
// 66:         switch "--eval-all",
// 67:                depends_on:  "--json",
// 68:                description: "Evaluate all available formulae and casks, whether installed or not, to print their " \
// 69:                             "JSON.",
// 70:                env:         :eval_all,
// 71:                odeprecated: true
// 72:         switch "--variations",
// 73:                depends_on:  "--json",
// 74:                description: "Include the variations hash in each formula's JSON output."
// 75:         switch "-v", "--verbose",
// 76:                description: "Show more verbose data for <formula>, or full information with `--installed`."
// 77:         switch "--formula", "--formulae",
// 78:                description: "Treat all named arguments as formulae."
// 79:         switch "--cask", "--casks",
// 80:                description: "Treat all named arguments as casks."
// 81:         switch "--sizes",
// 82:                description: "Show the size of installed formulae and casks."
// 83:
// 84:         conflicts "--installed", "--eval-all"
// 85:         conflicts "--formula", "--cask"
// 86:         conflicts "--fetch-manifest", "--cask"
// 87:         conflicts "--fetch-manifest", "--json"
// 88:
// 89:         named_args [:formula, :cask]
// 90:       end
// 91:
// 92:       sig { override.void }
// 93:       def run
// 94:         if args.sizes?
// 95:           if args.no_named?
// 96:             print_sizes
// 97:           else
// 98:             formulae, casks = args.named.to_formulae_to_casks
// 99:             formulae = T.cast(formulae, T::Array[Formula])
// 100:             print_sizes(formulae:, casks:)
// 101:           end
// 102:         elsif args.analytics?
// 103:           if args.days.present? && VALID_DAYS.exclude?(args.days)
// 104:             raise UsageError, "`--days` must be one of #{VALID_DAYS.join(", ")}."
// 105:           end
// 106:
// 107:           if args.category.present?
// 108:             if args.named.present? && VALID_FORMULA_CATEGORIES.exclude?(args.category)
// 109:               raise UsageError,
// 110:                     "`--category` must be one of #{VALID_FORMULA_CATEGORIES.join(", ")} when querying formulae."
// 111:             end
// 112:
// 113:             unless VALID_CATEGORIES.include?(args.category)
// 114:               raise UsageError, "`--category` must be one of #{VALID_CATEGORIES.join(", ")}."
// 115:             end
// 116:           end
// 117:
// 118:           print_analytics
// 119:         elsif (json = args.json)
// 120:           eval_all = args.eval_all?
// 121:           eval_all ||= args.no_named? && !args.installed? && Homebrew::EnvConfig.tap_trust_configured?
// 122:           print_json(json, eval_all)
// 123:         elsif args.installed?
// 124:           T.let([
// 125:             *(args.cask? ? [] : Formula.installed.sort),
// 126:             *(args.formula? ? [] : Cask::Caskroom.casks.sort_by(&:full_name)),
// 127:           ], T::Array[T.any(Formula, Cask::Cask)]).each_with_index do |formula_or_cask, i|
// 128:             puts unless i.zero?
// 129:
// 130:             info_formula_or_cask(formula_or_cask, quiet: !args.verbose?)
// 131:           end
// 132:         elsif args.github?
// 133:           raise FormulaOrCaskUnspecifiedError if args.no_named?
// 134:
// 135:           exec_browser(*args.named.to_formulae_and_casks.map do |formula_keg_or_cask|
// 136:             formula_or_cask = T.cast(formula_keg_or_cask, T.any(Formula, Cask::Cask))
// 137:             github_info(formula_or_cask)
// 138:           end)
// 139:         elsif args.no_named?
// 140:           print_statistics
// 141:         else
// 142:           print_info(quiet: args.quiet?)
// 143:         end
// 144:       end
// 145:
// 146:       sig { params(remote: String, path: String).returns(String) }
// 147:       def github_remote_path(remote, path)
// 148:         if remote =~ %r{^(?:https?://|git(?:@|://))github\.com[:/](.+)/(.+?)(?:\.git)?$}
// 149:           "https://github.com/#{Regexp.last_match(1)}/#{Regexp.last_match(2)}/blob/HEAD/#{path}"
// 150:         else
// 151:           "#{remote}/#{path}"
// 152:         end
// 153:       end
// 154:
// 155:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T::Array[String]) }
// 156:       def self.metadata_lines(formula_or_cask)
// 157:         return [] unless $stdout.tty?
// 158:
// 159:         case formula_or_cask
// 160:         when Formula
// 161:           formula_metadata_lines(formula_or_cask)
// 162:         when Cask::Cask
// 163:           if formula_or_cask.pinned?
// 164:             pinned = "Pinned: #{formula_or_cask.pinned_version}"
// 165:             if (pinned_time = pin_path_mtime(formula_or_cask.pin_path))
// 166:               pinned << " on #{formatted_time(pinned_time)}"
// 167:             end
// 168:             [pinned]
// 169:           else
// 170:             []
// 171:           end
// 172:         else
// 173:           T.absurd(formula_or_cask)
// 174:         end
// 175:       end
// 176:
// 177:       sig { params(tab: T.any(Tab, Cask::Tab)).returns(String) }
// 178:       def self.installation_status(tab)
// 179:         # TODO: Deprecate reading `installed_as_dependency`; `installed_on_request`
// 180:         # is the only state we need to render install intent.
// 181:         tab.installed_on_request ? "Installed (on request)" : "Installed (as dependency)"
// 182:       end
// 183:
// 184:       sig { params(tab: T.any(Tab, Cask::Tab)).returns(String) }
// 185:       def self.installation_reason(tab)
// 186:         return "-" unless tab.installed_on_request_present?
// 187:
// 188:         tab.installed_on_request ? "on request" : "dependency"
// 189:       end
// 190:
// 191:       sig { params(version: String, tab: T.any(Tab, Cask::Tab)).returns(String) }
// 192:       def self.installation_summary(version, tab)
// 193:         reason = installation_reason(tab)
// 194:
// 195:         "Installed: #{version}#{" (#{reason})" if reason != "-"}"
// 196:       end
// 197:
// 198:       sig { params(requirement: Requirement).returns(T::Boolean) }
// 199:       def self.requirement_for_other_os?(requirement)
// 200:         requirement.instance_of?(MacOSRequirement) || requirement.instance_of?(LinuxRequirement)
// 201:       end
// 202:
// 203:       sig { params(installed_count: Integer, total_count: Integer).returns(String) }
// 204:       def self.dependency_status_counts(installed_count, total_count)
// 205:         missing_count = total_count - installed_count
// 206:         return "all installed #{Formatter.success("✔")}" if missing_count.zero?
// 207:
// 208:         "#{installed_count} installed #{Formatter.success("✔")}, " \
// 209:           "#{missing_count} missing #{Formatter.error("✘")}"
// 210:       end
// 211:
// 212:       sig { params(full_name: String, name: String).returns(T::Array[String]) }
// 213:       def self.installed_dependent_names(full_name, name)
// 214:         Formula.racks.filter_map do |rack|
// 215:           keg = Keg.from_rack(rack)
// 216:           next unless keg
// 217:
// 218:           tab_path = keg/AbstractTab::FILENAME
// 219:           next unless tab_path.file?
// 220:
// 221:           # Fast path: skip JSON parsing when the formula name
// 222:           # does not appear anywhere in the raw receipt.
// 223:           content = File.read(tab_path)
// 224:           next unless content.include?(name)
// 225:
// 226:           tab_deps = Tab.from_file_content(content, tab_path).runtime_dependencies
// 227:           next unless tab_deps
// 228:
// 229:           dependent = tab_deps.any? do |dep|
// 230:             dep_full_name = T.cast(dep, T::Hash[String, T.untyped])["full_name"]
// 231:             dep_full_name == full_name || dep_full_name&.then { Utils.name_from_full_name(it) } == name
// 232:           end
// 233:           keg.name if dependent
// 234:         end.sort.uniq
// 235:       end
// 236:
// 237:       sig { params(formula: Formula).returns(T::Array[String]) }
// 238:       def self.formula_metadata_lines(formula)
// 239:         metadata = T.let([], T::Array[String])
// 240:         if formula.pinned?
// 241:           pinned = "Pinned: #{formula.pinned_version}"
// 242:           if (pinned_time = pin_path_mtime(FormulaPin.new(formula).path))
// 243:             pinned << " on #{formatted_time(pinned_time)}"
// 244:           end
// 245:           metadata << pinned
// 246:         end
// 247:
// 248:         if !formula.any_version_installed? &&
// 249:            formula_installs_from_source?(formula) &&
// 250:            formula.requirements.none? { |requirement| requirement_for_other_os?(requirement) }
// 251:           metadata << "Installs from source: yes"
// 252:         end
// 253:         metadata
// 254:       end
// 255:
// 256:       sig { params(time: T.any(Integer, Time)).returns(String) }
// 257:       def self.formatted_time(time)
// 258:         time = Time.at(time) if time.is_a?(Integer)
// 259:
// 260:         time.strftime("%Y-%m-%d at %H:%M:%S")
// 261:       end
// 262:
// 263:       sig { params(pin_path: Pathname).returns(T.nilable(Time)) }
// 264:       def self.pin_path_mtime(pin_path)
// 265:         pin_path.lstat.mtime if pin_path.symlink? || pin_path.exist?
// 266:       rescue Errno::ENOENT
// 267:         nil
// 268:       end
// 269:
// 270:       sig { params(formula: T.untyped).returns(T::Boolean) }
// 271:       def self.formula_installs_from_source?(formula)
// 272:         return true if formula.stable.blank? && formula.head.present?
// 273:         return false if formula.stable.blank?
// 274:
// 275:         !formula.stable.bottled? || !formula.pour_bottle?
// 276:       end
// 277:
// 278:       sig {
// 279:         params(cask: T.untyped, formula_dependencies: T::Set[String], cask_dependencies: T::Set[String],
// 280:                visited_casks: T::Set[String]).void
// 281:       }
// 282:       def self.collect_cask_dependency_names(cask, formula_dependencies, cask_dependencies, visited_casks)
// 283:         cask.depends_on.formula.each do |name|
// 284:           dep_name = name.to_s
// 285:           formula_dependencies << dep_name
// 286:           rack = HOMEBREW_CELLAR/Utils.name_from_full_name(dep_name)
// 287:           next unless rack.directory?
// 288:
// 289:           keg = Keg.from_rack(rack)
// 290:           next unless keg
// 291:
// 292:           tab_deps = Tab.for_keg(keg).runtime_dependencies
// 293:           tab_deps&.each do |runtime_dep|
// 294:             dep_full_name = T.cast(runtime_dep, T::Hash[String, T.untyped])["full_name"]
// 295:             formula_dependencies << dep_full_name if dep_full_name
// 296:           end
// 297:         end
// 298:
// 299:         cask.depends_on.cask.each do |name|
// 300:           token = name.to_s
// 301:           next if visited_casks.include?(token)
// 302:
// 303:           cask_dependencies << token
// 304:           visited_casks << token
// 305:           begin
// 306:             dependency = Cask::CaskLoader.load(token)
// 307:             collect_cask_dependency_names(dependency, formula_dependencies, cask_dependencies, visited_casks)
// 308:           rescue Cask::CaskUnavailableError
// 309:             next
// 310:           end
// 311:         end
// 312:       end
// 313:
// 314:       private_class_method :formula_metadata_lines, :formatted_time, :pin_path_mtime,
// 315:                            :formula_installs_from_source?
// 316:
// 317:       sig { params(quiet: T::Boolean).void }
// 318:       def print_info(quiet: false)
// 319:         objects = args.named.to_formulae_and_casks_and_unavailable(uniq: false)
// 320:         user_qualified = args.named.downcased_unique_named.map { |name| name.include?("/") }
// 321:
// 322:         resolved = user_qualified.zip(objects).map do |qualified, obj|
// 323:           if obj.is_a?(Formula)
// 324:             display_resolution(obj, user_qualified: qualified)
// 325:           else
// 326:             [obj, nil]
// 327:           end
// 328:         end
// 329:
// 330:         unique_by_display_name(resolved).each_with_index do |(obj, shadowed_by), i|
// 331:           puts unless i.zero?
// 332:
// 333:           if obj.is_a?(FormulaOrCaskUnavailableError)
// 334:             # The formula/cask could not be found
// 335:             ofail obj.message
// 336:             # No formula with this name, try a missing formula lookup
// 337:             if (reason = MissingFormula.reason(obj.name, show_info: true))
// 338:               $stderr.puts reason
// 339:             end
// 340:           else
// 341:             info_formula_or_cask(obj, quiet:, shadowed_by:)
// 342:           end
// 343:         end
// 344:       end
// 345:
// 346:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask), qualified_inputs: T::Set[String]).returns(T::Boolean) }
// 347:       def formula_qualified_by_user?(formula_or_cask, qualified_inputs)
// 348:         return false if qualified_inputs.empty?
// 349:
// 350:         names = T.let([formula_or_cask.full_name.downcase], T::Array[String])
// 351:         if (tap = formula_or_cask.tap)
// 352:           names << "#{tap.name.downcase}/#{Utils.name_or_token(formula_or_cask).downcase}"
// 353:         end
// 354:         names.any? { |n| qualified_inputs.include?(n) }
// 355:       end
// 356:
// 357:       sig { params(formula: Formula).returns([Formula, T.nilable(Tap)]) }
// 358:       def installed_resolution(formula)
// 359:         keg = formula.installed_kegs.last
// 360:         return [formula, nil] if keg.nil?
// 361:
// 362:         installed_tap = keg.tab.tap
// 363:         return [formula, nil] if installed_tap.nil? || installed_tap == formula.tap
// 364:
// 365:         [Formulary.factory("#{installed_tap}/#{keg.name}"), formula.tap]
// 366:       rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 367:         [formula, nil]
// 368:       end
// 369:
// 370:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(String) }
// 371:       def github_info(formula_or_cask)
// 372:         tap = T.let(nil, T.nilable(Tap))
// 373:         path = case formula_or_cask
// 374:         when Formula
// 375:           formula = formula_or_cask
// 376:           tap = formula.tap
// 377:           return formula.path.to_s if tap.blank? || tap.remote.blank?
// 378:           # The formula file may live outside the tap (e.g. loaded from a keg's
// 379:           # `.brew/` directory after the formula was removed from its tap), in
// 380:           # which case there is no meaningful upstream URL to link to.
// 381:           return formula.path.to_s unless formula.path.to_s.start_with?("#{tap.path}/")
// 382:
// 383:           formula.path.relative_path_from(tap.path)
// 384:         when Cask::Cask
// 385:           cask = formula_or_cask
// 386:           tap = cask.tap
// 387:           return cask.sourcefile_path.to_s if tap.blank? || tap.remote.blank?
// 388:
// 389:           sourcefile_path = cask.sourcefile_path
// 390:           if !sourcefile_path || sourcefile_path.extname != ".rb"
// 391:             return "#{tap.default_remote}/blob/HEAD/#{tap.relative_cask_path(cask.token)}"
// 392:           end
// 393:
// 394:           sourcefile_path.relative_path_from(tap.path)
// 395:         end
// 396:
// 397:         remote = tap.remote
// 398:         raise "unexpected nil tap.remote" unless remote
// 399:
// 400:         github_remote_path(remote, path.to_s)
// 401:       end
// 402:
// 403:       sig { params(formula: Formula).void }
// 404:       def info_formula_summary(formula)
// 405:         kegs = formula.installed_kegs
// 406:         tab = Tab.for_formula(formula)
// 407:         version = kegs.sort_by(&:scheme_and_version)
// 408:                       .map { |keg| keg.version.to_s }
// 409:                       .join(", ")
// 410:         version = "-" if version.blank?
// 411:
// 412:         puts oh1_title(info_summary_title(formula.full_name, formula.desc, installed: kegs.any?))
// 413:         if kegs.empty?
// 414:           puts "Formula from #{github_info(formula)}"
// 415:           puts "Not installed"
// 416:         else
// 417:           puts "Formula from #{formula.tap&.name ||
// 418:                                 T.cast(tab.source["tap"], T.nilable(String)) ||
// 419:                                 T.cast(tab.source["path"], T.nilable(String)) ||
// 420:                                 github_info(formula)}"
// 421:           puts self.class.installation_summary(version, tab)
// 422:         end
// 423:       end
// 424:
// 425:       sig { params(formula: Formula, shadowed_by: T.nilable(Tap)).void }
// 426:       def info_formula(formula, shadowed_by: nil)
// 427:         specs = T.let([], T::Array[String])
// 428:
// 429:         if (stable = formula.stable)
// 430:           string = "stable #{stable.version}"
// 431:           string += " (bottled)" if stable.bottled? && formula.pour_bottle?
// 432:           specs << string
// 433:         end
// 434:
// 435:         specs << "HEAD" if formula.head
// 436:
// 437:         attrs = []
// 438:         attrs << "keg-only" if formula.keg_only?
// 439:
// 440:         shadowing_formula = shadowing_installed_formula(formula)
// 441:         kegs = shadowing_formula ? [] : formula.installed_kegs
// 442:         installed = kegs.any?
// 443:         outdated = installed && formula.outdated?
// 444:         missing_libraries, missing_library_deps = formula.missing_library_linkage if installed
// 445:         missing_libraries ||= []
// 446:         missing_library_deps ||= Set.new
// 447:         if outdated && (upgrade_version = specs.first.presence)
// 448:           installed_version = formula.linked_version ||
// 449:                               kegs.max_by(&:scheme_and_version)&.version
// 450:           specs[0] = "#{installed_version} → #{upgrade_version}"
// 451:         end
// 452:         title_name = if shadowing_formula && (formula_tap = formula.tap)
// 453:           "#{formula_tap}/#{formula.name}"
// 454:         elsif shadowed_by
// 455:           formula.name
// 456:         else
// 457:           formula.full_name
// 458:         end
// 459:         name_with_status = pretty_install_status(
// 460:           title_name,
// 461:           warning:    missing_libraries.present?,
// 462:           installed:,
// 463:           outdated:,
// 464:           deprecated: formula.deprecated?,
// 465:           disabled:   formula.disabled?,
// 466:           bold:       true,
// 467:         )
// 468:
// 469:         puts "#{oh1_title(name_with_status)}: #{specs * ", "}#{" [#{attrs * ", "}]" unless attrs.empty?}"
// 470:         if shadowed_by
// 471:           puts Formatter.warning(
// 472:             "`#{formula.name}` shadows `#{shadowed_by.name}/#{formula.name}`.",
// 473:             label: "Warning",
// 474:           )
// 475:         end
// 476:         puts formula.desc if formula.desc
// 477:         puts Formatter.url(formula.homepage) if formula.homepage
// 478:         puts "Aliases: #{formula.aliases.join(", ")}" if formula.aliases.any?
// 479:         puts "Old Names: #{formula.oldnames.join(", ")}" if formula.oldnames.any?
// 480:
// 481:         deprecate_disable_info_string = DeprecateDisable.message(formula)
// 482:         if deprecate_disable_info_string.present?
// 483:           deprecate_disable_info_string.tap { |info_string| info_string[0] = info_string[0].upcase }
// 484:           puts deprecate_disable_info_string
// 485:         end
// 486:
// 487:         conflicts = formula.conflicts.filter_map do |conflict|
// 488:           resolved = begin
// 489:             Formulary.factory(conflict.name)
// 490:           rescue FormulaUnavailableError
// 491:             nil
// 492:           end
// 493:           next if resolved && resolved.full_name == formula.full_name
// 494:
// 495:           conflict_name = resolved&.full_name || conflict.name
// 496:           reason = " (because #{conflict.reason})" if conflict.reason
// 497:           "#{conflict_name}#{reason}"
// 498:         end.sort!
// 499:         unless conflicts.empty?
// 500:           puts <<~EOS
// 501:             Conflicts with:
// 502:               #{conflicts.join("\n  ")}
// 503:           EOS
// 504:         end
// 505:
// 506:         heads, versioned = kegs.partition { |keg| keg.version.head? }
// 507:         kegs = [
// 508:           *heads.sort_by { |keg| -keg.tab.time.to_i },
// 509:           *versioned.sort_by(&:scheme_and_version),
// 510:         ]
// 511:         if kegs.empty?
// 512:           puts "Not installed"
// 513:           if (bottle = formula.bottle)
// 514:             begin
// 515:               bottle.fetch_tab(quiet: !args.debug?) if args.fetch_manifest? || args.verbose?
// 516:               bottle_size = bottle.bottle_size
// 517:               installed_size = bottle.installed_size
// 518:               puts "Bottle Size: #{Formatter.disk_usage_readable(bottle_size)}" if bottle_size
// 519:               puts "Installed Size: #{Formatter.disk_usage_readable(installed_size)}" if installed_size
// 520:             rescue RuntimeError => e
// 521:               odebug e
// 522:             end
// 523:           end
// 524:         else
// 525:           puts self.class.installation_status(Tab.for_formula(formula))
// 526:         end
// 527:
// 528:         puts "From: #{Formatter.url(github_info(formula))}"
// 529:         formula_tap = formula.tap
// 530:         puts "Tap: #{formula_tap.name}" if formula_tap && !formula_tap.official?
// 531:
// 532:         puts "License: #{SPDX.license_expression_to_string formula.license}" if formula.license.present?
// 533:         metadata = self.class.metadata_lines(formula)
// 534:         puts metadata if metadata.present?
// 535:
// 536:         installed_lines = installed_section_lines(shadowing_formula || formula, verbose: args.verbose?)
// 537:         unless installed_lines.empty?
// 538:           ohai(args.verbose? ? "Installed Kegs and Versions" : "Installed Versions")
// 539:           installed_lines.each { |line| puts line }
// 540:         end
// 541:
// 542:         tab_runtime_deps = kegs.last&.runtime_dependencies
// 543:         installed_dependents = if $stdout.tty? && kegs.any?
// 544:           self.class.installed_dependent_names(formula.full_name, formula.name)
// 545:         else
// 546:           [].freeze
// 547:         end
// 548:         dependency_lines = %w[build required recommended optional].filter_map do |type|
// 549:           next if type == "build" &&
// 550:                   (kegs.all? { |keg| keg.tab.poured_from_bottle } ||
// 551:                    (kegs.empty? &&
// 552:                     (formula.requirements.any? { |requirement| self.class.requirement_for_other_os?(requirement) } ||
// 553:                      (stable.present? ? stable.bottled? && formula.pour_bottle? : formula.head.blank?))))
// 554:
// 555:           deps = formula.deps.public_send(type).uniq
// 556:           next if deps.empty?
// 557:
// 558:           tab_deps = (kegs.any? && type != "build") ? tab_runtime_deps : nil
// 559:           "#{type.capitalize} (#{deps.count}): " \
// 560:             "#{decorate_dependencies(deps, tab_runtime_deps: tab_deps, mark_uninstalled: kegs.any?,
// 561:                                      missing_library_deps:)}"
// 562:         end
// 563:         if dependency_lines.present? || tab_runtime_deps.present? || installed_dependents.any?
// 564:           ohai "Dependencies"
// 565:           puts dependency_lines
// 566:           missing_library_names = missing_libraries.map { |lib| File.basename(lib) }.uniq
// 567:           if missing_library_names.present?
// 568:             decorated = missing_library_names.map { |lib| pretty_uninstalled(lib, bold: false) }.join(", ")
// 569:             puts "Missing libraries (#{missing_library_names.count}): #{decorated}"
// 570:           end
// 571:           if tab_runtime_deps.present?
// 572:             installed_count = tab_runtime_deps.count do |dep|
// 573:               dep_name = dep["full_name"]&.then { Utils.name_from_full_name(it) }
// 574:               next false unless dep_name
// 575:
// 576:               rack = HOMEBREW_CELLAR/dep_name
// 577:               rack.directory? && !rack.subdirs.empty?
// 578:             end
// 579:             puts "Recursive Runtime (#{tab_runtime_deps.count}): " \
// 580:                  "#{self.class.dependency_status_counts(installed_count, tab_runtime_deps.count)}"
// 581:           end
// 582:           if installed_dependents.any?
// 583:             if args.verbose?
// 584:               puts "Dependents (#{installed_dependents.count}): #{installed_dependents.join(", ")}"
// 585:             else
// 586:               puts "Dependents: #{installed_dependents.count}"
// 587:             end
// 588:           end
// 589:         end
// 590:
// 591:         unless formula.requirements.to_a.empty?
// 592:           ohai "Requirements"
// 593:           %w[build required recommended optional].map do |type|
// 594:             reqs = formula.requirements.select(&:"#{type}?")
// 595:             next if reqs.to_a.empty?
// 596:
// 597:             puts "#{type.capitalize}: #{decorate_requirements(reqs, mark_uninstalled: kegs.any?)}"
// 598:           end
// 599:         end
// 600:
// 601:         if !formula.options.empty? || formula.head
// 602:           ohai "Options"
// 603:           Options.dump_for_formula formula
// 604:         end
// 605:
// 606:         if args.verbose?
// 607:           binaries_keg = kegs.find(&:linked?) || kegs.last
// 608:           binaries = if binaries_keg
// 609:             binary_files = [binaries_keg/"bin", binaries_keg/"sbin"].select(&:directory?).flat_map do |dir|
// 610:               dir.children.select { |child| child.file? && child.executable? }
// 611:             end
// 612:             binary_files.map { |path| path.basename.to_s }
// 613:           elsif (path_exec_files = formula.bottle&.path_exec_files)
// 614:             path_exec_files.map { |path| File.basename(path) }
// 615:           end
// 616:           if binaries.present?
// 617:             binaries = binaries.sort.uniq
// 618:             ohai "Binaries", Formatter.columns(binaries)
// 619:           end
// 620:         end
// 621:
// 622:         caveats = Caveats.new(formula)
// 623:         if (caveats_string = caveats.to_s.presence)
// 624:           ohai "Caveats", caveats_string
// 625:         end
// 626:
// 627:         return unless formula.core_formula?
// 628:
// 629:         Utils::Analytics.formula_output(formula, args:)
// 630:       end
// 631:
// 632:       private
// 633:
// 634:       sig { void }
// 635:       def print_statistics
// 636:         return unless HOMEBREW_CELLAR.exist?
// 637:
// 638:         count = Formula.racks.length
// 639:         puts "#{Utils.pluralize("keg", count, include_count: true)}, #{HOMEBREW_CELLAR.dup.abv}"
// 640:       end
// 641:
// 642:       sig { void }
// 643:       def print_analytics
// 644:         if args.no_named?
// 645:           Utils::Analytics.output(args:)
// 646:           return
// 647:         end
// 648:
// 649:         args.named.to_formulae_and_casks_and_unavailable.each_with_index do |obj, i|
// 650:           puts unless i.zero?
// 651:
// 652:           case obj
// 653:           when Formula
// 654:             Utils::Analytics.formula_output(obj, args:) if obj.core_formula?
// 655:           when Cask::Cask
// 656:             Utils::Analytics.cask_output(obj, args:) if obj.tap&.core_cask_tap?
// 657:           when FormulaOrCaskUnavailableError
// 658:             Utils::Analytics.output(filter: obj.name, args:)
// 659:           else
// 660:             raise
// 661:           end
// 662:         end
// 663:       end
// 664:
// 665:       sig {
// 666:         params(resolved: T::Array[[T.untyped, T.nilable(Tap)]]).returns(T::Array[[T.untyped, T.nilable(Tap)]])
// 667:       }
// 668:       def unique_by_display_name(resolved)
// 669:         resolved.uniq do |obj, _shadowed_by|
// 670:           case obj
// 671:           when Formula, Cask::Cask then obj.full_name
// 672:           else obj
// 673:           end
// 674:         end
// 675:       end
// 676:
// 677:       sig { params(formula: Formula, user_qualified: T::Boolean).returns([Formula, T.nilable(Tap)]) }
// 678:       def display_resolution(formula, user_qualified:)
// 679:         return [formula, nil] if user_qualified
// 680:
// 681:         installed_resolution(formula)
// 682:       end
// 683:
// 684:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask), quiet: T::Boolean, shadowed_by: T.nilable(Tap)).void }
// 685:       def info_formula_or_cask(formula_or_cask, quiet:, shadowed_by: nil)
// 686:         case formula_or_cask
// 687:         when Formula
// 688:           if quiet
// 689:             info_formula_summary(formula_or_cask)
// 690:           else
// 691:             info_formula(formula_or_cask, shadowed_by:)
// 692:           end
// 693:         when Cask::Cask
// 694:           if quiet
// 695:             info_cask_summary(formula_or_cask)
// 696:           else
// 697:             info_cask(formula_or_cask)
// 698:           end
// 699:         end
// 700:       end
// 701:
// 702:       sig { params(formula: Formula).returns(T.nilable(Formula)) }
// 703:       def shadowing_installed_formula(formula)
// 704:         installed_formula, shadowed_by = installed_resolution(formula)
// 705:         installed_formula if shadowed_by
// 706:       end
// 707:
// 708:       sig { params(formula: Formula, qualified_inputs: T::Set[String]).returns(Formula) }
// 709:       def swap_to_installed_formula(formula, qualified_inputs)
// 710:         return formula if formula_qualified_by_user?(formula, qualified_inputs)
// 711:
// 712:         installed_resolution(formula).first
// 713:       end
// 714:
// 715:       sig { params(version: T.any(T::Boolean, String)).returns(Symbol) }
// 716:       def json_version(version)
// 717:         version_hash = {
// 718:           true => :default,
// 719:           "v1" => :v1,
// 720:           "v2" => :v2,
// 721:         }
// 722:
// 723:         raise UsageError, "invalid JSON version: #{version}" unless version_hash.include?(version)
// 724:
// 725:         version_hash[version]
// 726:       end
// 727:
// 728:       sig { params(json: T.any(T::Boolean, String), eval_all: T::Boolean).void }
// 729:       def print_json(json, eval_all)
// 730:         raise FormulaOrCaskUnspecifiedError if !(eval_all || args.installed?) && args.no_named?
// 731:
// 732:         qualified_inputs = args.named.select { |name| name.include?("/") }.to_set
// 733:
// 734:         json = case json_version(json)
// 735:         when :v1, :default
// 736:           raise UsageError, "Cannot specify `--cask` when using `--json=v1`!" if args.cask?
// 737:
// 738:           formulae = if eval_all
// 739:             Formula.all(eval_all:).sort
// 740:           elsif args.installed?
// 741:             Formula.installed.sort
// 742:           else
// 743:             args.named.to_formulae.map { |f| swap_to_installed_formula(f, qualified_inputs) }
// 744:           end
// 745:
// 746:           if args.variations?
// 747:             formulae.map(&:to_hash_with_variations)
// 748:           else
// 749:             formulae.map(&:to_hash)
// 750:           end
// 751:         when :v2
// 752:           formulae, casks = T.let(
// 753:             if eval_all
// 754:               formulae = [] if args.cask?
// 755:               formulae ||= Formula.all(eval_all:).sort
// 756:               casks = [] if args.formula?
// 757:               casks ||= Cask::Cask.all(eval_all:).sort_by(&:full_name)
// 758:               [formulae, casks]
// 759:             elsif args.installed?
// 760:               formulae = [] if args.cask?
// 761:               formulae ||= Formula.installed.sort
// 762:               casks = [] if args.formula?
// 763:               casks ||= Cask::Caskroom.casks.sort_by(&:full_name)
// 764:               [formulae, casks]
// 765:             else
// 766:               named_formulae, named_casks = T.cast(
// 767:                 args.named.to_formulae_to_casks, [T::Array[Formula], T::Array[Cask::Cask]]
// 768:               )
// 769:               [named_formulae.map { |f| swap_to_installed_formula(f, qualified_inputs) }, named_casks]
// 770:             end, [T::Array[Formula], T::Array[Cask::Cask]]
// 771:           )
// 772:
// 773:           if args.variations?
// 774:             {
// 775:               "formulae" => formulae.map(&:to_hash_with_variations),
// 776:               "casks"    => casks.map(&:to_hash_with_variations),
// 777:             }
// 778:           else
// 779:             {
// 780:               "formulae" => formulae.map(&:to_hash),
// 781:               "casks"    => casks.map(&:to_h),
// 782:             }
// 783:           end
// 784:         else
// 785:           raise
// 786:         end
// 787:
// 788:         puts JSON.pretty_generate(json)
// 789:       end
// 790:
// 791:       sig { params(name: String, description: T.nilable(String), installed: T::Boolean).returns(String) }
// 792:       def info_summary_title(name, description, installed:)
// 793:         name = pretty_installed(name) if installed
// 794:
// 795:         "#{name}#{": #{description}" if description.present?}"
// 796:       end
// 797:
// 798:       sig { params(formula: Formula, verbose: T::Boolean).returns(T::Array[String]) }
// 799:       def installed_section_lines(formula, verbose: false)
// 800:         siblings = formula.versioned_formulae
// 801:         parent = if (parent_name = formula.unversioned_formula_name)
// 802:           begin
// 803:             Formulary.factory(parent_name)
// 804:           rescue FormulaUnavailableError
// 805:             nil
// 806:           end
// 807:         end
// 808:         related = [formula, parent, *siblings].compact.uniq(&:full_name)
// 809:         installed = related.select { |f| f.installed_kegs.any? }
// 810:         return [] if installed.empty?
// 811:
// 812:         ordered = installed.sort_by do |other|
// 813:           newest_keg = other.installed_kegs.max_by(&:scheme_and_version)
// 814:           newest_keg ? newest_keg.scheme_and_version : other.pkg_version
// 815:         end.reverse
// 816:         with_kegs = ordered.flat_map do |other|
// 817:           heads, versioned = other.installed_kegs.partition { |keg| keg.version.head? }
// 818:           ordered_kegs = [
// 819:             *heads.sort_by { |keg| -keg.tab.time.to_i },
// 820:             *versioned.sort_by(&:scheme_and_version).reverse,
// 821:           ]
// 822:           ordered_kegs.each_with_index.map { |keg, index| [other, keg, index.zero?] }
// 823:         end
// 824:         with_kegs = with_kegs.select { |_other, keg, newest| newest || keg.linked? } unless verbose
// 825:         rows = with_kegs.map do |other, keg, newest|
// 826:           name_status = pretty_install_status(other.full_name, installed: true, outdated: other.outdated?)
// 827:           version = keg.version.to_s
// 828:           latest = other.pkg_version.to_s
// 829:           version = "#{version} → #{latest}" if newest && other.outdated? && latest != version
// 830:           linked_marker = keg.linked? ? "[Linked]" : ""
// 831:           [name_status, version, "(#{keg.abv})", linked_marker, keg]
// 832:         end
// 833:         name_width = rows.map { |r| Tty.strip_ansi(r[0]).length }.max || 0
// 834:         version_width = rows.map { |r| r[1].length }.max || 0
// 835:         size_width = rows.map { |r| r[2].length }.max || 0
// 836:         rows.flat_map do |name_status, version, size, linked_marker, keg|
// 837:           padded_name = name_status + (" " * (name_width - Tty.strip_ansi(name_status).length))
// 838:           padded_size = linked_marker.empty? ? size : size.ljust(size_width)
// 839:           line = "#{padded_name} #{version.ljust(version_width)} #{padded_size}" \
// 840:                  "#{" #{linked_marker}" unless linked_marker.empty?}"
// 841:           next [line] unless verbose
// 842:
// 843:           tab_string = keg.tab.to_s
// 844:           tab_string.empty? ? [line] : [line, "  #{tab_string}"]
// 845:         end
// 846:       end
// 847:
// 848:       sig {
// 849:         params(dependencies:         T::Array[Dependency],
// 850:                tab_runtime_deps:     T.nilable(T::Array[T::Hash[String, T.untyped]]),
// 851:                mark_uninstalled:     T::Boolean,
// 852:                missing_library_deps: T::Set[String]).returns(String)
// 853:       }
// 854:       def decorate_dependencies(dependencies, tab_runtime_deps: nil, mark_uninstalled: true,
// 855:                                 missing_library_deps: Set.new)
// 856:         dependencies.map do |dep|
// 857:           display = dep_display_s(dep)
// 858:           full_name = tab_runtime_deps&.find do |d|
// 859:             name = d["full_name"]
// 860:             name == dep.name || name&.then { Utils.name_from_full_name(it) } == dep.name
// 861:           end&.fetch("full_name") || dep.name
// 862:           rack = HOMEBREW_CELLAR/Utils.name_from_full_name(full_name)
// 863:           installed = T.let(rack.directory? && !rack.subdirs.empty?, T::Boolean)
// 864:           formula = begin
// 865:             dep.to_formula
// 866:           rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 867:             nil
// 868:           end
// 869:           installed ||= formula.any_version_installed? if !installed && formula
// 870:           outdated = T.let(installed && formula&.outdated? == true, T::Boolean)
// 871:           warning = missing_library_deps.include?(Utils.name_from_full_name(dep.name))
// 872:           pretty_install_status(display, warning:, installed:, outdated:, mark_uninstalled:, bold: true)
// 873:         end.join(", ")
// 874:       end
// 875:
// 876:       sig { params(requirements: T::Array[Requirement], mark_uninstalled: T::Boolean).returns(String) }
// 877:       def decorate_requirements(requirements, mark_uninstalled: true)
// 878:         req_status = requirements.map do |req|
// 879:           req_s = req.display_s
// 880:           pretty_install_status(req_s, installed: req.satisfied?, mark_uninstalled:, bold: true)
// 881:         end
// 882:         req_status.join(", ")
// 883:       end
// 884:
// 885:       sig { params(dep: Dependency).returns(String) }
// 886:       def dep_display_s(dep)
// 887:         return dep.name if dep.option_tags.empty?
// 888:
// 889:         "#{dep.name} #{dep.option_tags.map { |o| "--#{o}" }.join(" ")}"
// 890:       end
// 891:
// 892:       sig { params(cask: Cask::Cask).void }
// 893:       def info_cask(cask)
// 894:         require "cask/info"
// 895:
// 896:         Cask::Info.info(cask, args:)
// 897:       end
// 898:
// 899:       sig { params(cask: Cask::Cask).void }
// 900:       def info_cask_summary(cask)
// 901:         installed_version = cask.installed_version
// 902:         installed = installed_version.present?
// 903:         tab = Cask::Tab.for_cask(cask)
// 904:
// 905:         puts oh1_title(info_summary_title(
// 906:                          cask.full_name,
// 907:                          cask.desc.presence&.then do |desc|
// 908:                            "#{if cask.name.present?
// 909:                                 "(#{cask.name.join(", ")}) "
// 910:                            end}#{desc}"
// 911:                          end,
// 912:                          installed:,
// 913:                        ))
// 914:         if installed
// 915:           puts "Cask from #{T.cast(cask.tap, T.nilable(Tap))&.name ||
// 916:                              T.cast(tab.source["tap"], T.nilable(String)) ||
// 917:                              cask.sourcefile_path&.to_s ||
// 918:                              T.cast(tab.source["path"], T.nilable(String)) ||
// 919:                              github_info(cask)}"
// 920:           puts self.class.installation_summary(installed_version, tab)
// 921:         else
// 922:           puts "Cask from #{github_info(cask)}"
// 923:           puts "Not installed"
// 924:         end
// 925:       end
// 926:
// 927:       sig { params(title: String, items: T::Array[NameSize]).void }
// 928:       def print_sizes_table(title, items)
// 929:         return if items.blank?
// 930:
// 931:         ohai title
// 932:
// 933:         total_size = items.sum(&:size)
// 934:         total_size_str = Formatter.disk_usage_readable(total_size)
// 935:
// 936:         name_width = (items.map { |item| item.name.length } + [5]).max
// 937:         size_width = (items.map do |item|
// 938:           Formatter.disk_usage_readable(item.size).length
// 939:         end + [total_size_str.length]).max
// 940:
// 941:         items.each do |item|
// 942:           puts format("%-#{name_width}s %#{size_width}s", item.name,
// 943:                       Formatter.disk_usage_readable(item.size))
// 944:         end
// 945:
// 946:         puts format("%-#{name_width}s %#{size_width}s", "Total", total_size_str)
// 947:       end
// 948:
// 949:       sig { params(formulae: T::Array[Formula], casks: T::Array[Cask::Cask]).void }
// 950:       def print_sizes(formulae: [], casks: [])
// 951:         if formulae.blank? &&
// 952:            (args.formulae? || (!args.casks? && args.no_named?))
// 953:           formulae = Formula.installed
// 954:         end
// 955:
// 956:         if casks.blank? &&
// 957:            (args.casks? || (!args.formulae? && args.no_named?))
// 958:           casks = Cask::Caskroom.casks
// 959:         end
// 960:
// 961:         unless args.casks?
// 962:           formula_sizes = formulae.map do |formula|
// 963:             kegs = formula.installed_kegs
// 964:             size = kegs.sum(&:disk_usage)
// 965:             NameSize.new(name: formula.full_name, size:)
// 966:           end
// 967:           formula_sizes.sort_by! { |f| -f.size }
// 968:           print_sizes_table("Formulae sizes:", formula_sizes)
// 969:         end
// 970:
// 971:         return if casks.blank? || args.formulae?
// 972:
// 973:         cask_sizes = casks.filter_map do |cask|
// 974:           installed_version = cask.installed_version
// 975:           next unless installed_version.present?
// 976:
// 977:           versioned_staged_path = cask.caskroom_path.join(installed_version)
// 978:           next unless versioned_staged_path.exist?
// 979:
// 980:           size = versioned_staged_path.children.sum(&:disk_usage)
// 981:           NameSize.new(name: cask.full_name, size:)
// 982:         end
// 983:         cask_sizes.sort_by! { |c| -c.size }
// 984:         print_sizes_table("Casks sizes:", cask_sizes)
// 985:       end
// 986:     end
// 987:   end
// 988: end
// 989:
// 990: require "extend/os/cmd/info"
