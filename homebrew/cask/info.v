module cask

import ruby
import homebrew.extend.pathname as path_usage
import homebrew.utils as brew_utils
import os
import time

// Translated from Homebrew/brew `cask/info.rb`.
pub struct CaskInfoTap {
pub:
	present            bool
	custom_remote      bool
	remote             string
	default_remote     string
	relative_cask_path string
	core_cask_tap      bool
}

pub struct CaskInfoTab {
pub:
	installed_on_request     bool
	tabfile                  string
	tabfile_exists           bool
	loaded_from_api          bool
	loaded_from_internal_api bool
	time                     i64
	text                     string
}

pub struct CaskInfoDependency {
pub:
	name      string
	installed bool
}

pub struct CaskInfoRequirement {
pub:
	display                    string
	kind                       string = 'required'
	satisfied                  bool
	macos_requirement          bool
	cask_dependent_requirement bool
}

pub struct CaskInfoArtifact {
pub:
	display       string
	install_phase bool = true
	ordinary      bool = true
}

pub struct CaskInfoModel {
pub:
	token                          string
	names                          []string
	version                        string
	auto_updates                   bool
	desc                           string
	homepage                       string
	deprecate_disable              string
	installed                      bool
	installed_version              string
	caskroom_path                  string
	tab                            CaskInfoTab
	pinned                         bool
	pinned_version                 string
	pin_time                       i64
	tap                            CaskInfoTap
	formula_dependencies           []CaskInfoDependency
	cask_dependencies              []CaskInfoDependency
	recursive_formula_dependencies []CaskInfoDependency
	recursive_cask_dependencies    []CaskInfoDependency
	requirements                   []CaskInfoRequirement
	supports_linux                 bool
	languages                      []string
	artifacts                      []CaskInfoArtifact
	caveats                        string
	tty                            bool
}

fn cask_info_bool_attr(value ruby.Value, name string, fallback bool) bool {
	raw := value.attributes[name] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn cask_info_int_attr(value ruby.Value, name string, fallback i64) i64 {
	return (value.attributes[name] or { return fallback }).i64()
}

fn cask_info_values(value ruby.Value, name string) []ruby.Value {
	entry := value.map_data[name] or { return [] }
	return entry.as_array() or { [] }
}

fn cask_info_strings(value ruby.Value, name string) []string {
	entry := value.map_data[name] or { return [] }
	return entry.as_string_array() or { [] }
}

fn cask_info_dependency_from_value(value ruby.Value) CaskInfoDependency {
	return CaskInfoDependency{
		name: value.attributes['name'] or { value.repr }
		installed: cask_info_bool_attr(value, 'installed', false)
	}
}

fn cask_info_requirement_from_value(value ruby.Value) CaskInfoRequirement {
	return CaskInfoRequirement{
		display: value.attributes['display'] or { value.repr }
		kind: value.attributes['kind'] or { 'required' }
		satisfied: cask_info_bool_attr(value, 'satisfied', false)
		macos_requirement: cask_info_bool_attr(value, 'macos_requirement', value.type_name == 'MacOSRequirement')
		cask_dependent_requirement: cask_info_bool_attr(value, 'cask_dependent_requirement', value.type_name == 'CaskDependent::Requirement')
	}
}

fn cask_info_artifact_from_value(value ruby.Value) CaskInfoArtifact {
	return CaskInfoArtifact{
		display: value.attributes['display'] or { value.repr }
		install_phase: cask_info_bool_attr(value, 'install_phase', true)
		ordinary: cask_info_bool_attr(value, 'ordinary', true)
	}
}

fn cask_info_tap_from_value(value ruby.Value) CaskInfoTap {
	return CaskInfoTap{
		present: cask_info_bool_attr(value, 'present', value.type_name != '' && value.type_name != 'NilClass')
		custom_remote: cask_info_bool_attr(value, 'custom_remote', false)
		remote: value.attributes['remote'] or { '' }
		default_remote: value.attributes['default_remote'] or { '' }
		relative_cask_path: value.attributes['relative_cask_path'] or { '' }
		core_cask_tap: cask_info_bool_attr(value, 'core_cask_tap', false)
	}
}

fn cask_info_tab_from_value(value ruby.Value) CaskInfoTab {
	return CaskInfoTab{
		installed_on_request: cask_info_bool_attr(value, 'installed_on_request', false)
		tabfile: value.attributes['tabfile'] or { '' }
		tabfile_exists: cask_info_bool_attr(value, 'tabfile_exists', false)
		loaded_from_api: cask_info_bool_attr(value, 'loaded_from_api', false)
		loaded_from_internal_api: cask_info_bool_attr(value, 'loaded_from_internal_api', false)
		time: cask_info_int_attr(value, 'time', 0)
		text: value.attributes['text'] or { value.repr }
	}
}

fn cask_info_from_value(value ruby.Value) CaskInfoModel {
	tap_value := value.map_data['tap'] or { ruby.Value{} }
	tab_value := value.map_data['tab'] or { ruby.Value{} }
	return CaskInfoModel{
		token: value.attributes['token'] or { value.repr }
		names: cask_info_strings(value, 'names')
		version: value.attributes['version'] or { '' }
		auto_updates: cask_info_bool_attr(value, 'auto_updates', false)
		desc: value.attributes['desc'] or { '' }
		homepage: value.attributes['homepage'] or { '' }
		deprecate_disable: value.attributes['deprecate_disable'] or { '' }
		installed: cask_info_bool_attr(value, 'installed', false)
		installed_version: value.attributes['installed_version'] or { '' }
		caskroom_path: value.attributes['caskroom_path'] or { '' }
		tab: cask_info_tab_from_value(tab_value)
		pinned: cask_info_bool_attr(value, 'pinned', false)
		pinned_version: value.attributes['pinned_version'] or { '' }
		pin_time: cask_info_int_attr(value, 'pin_time', 0)
		tap: cask_info_tap_from_value(tap_value)
		formula_dependencies: cask_info_values(value, 'formula_dependencies').map(cask_info_dependency_from_value(it))
		cask_dependencies: cask_info_values(value, 'cask_dependencies').map(cask_info_dependency_from_value(it))
		recursive_formula_dependencies: cask_info_values(value, 'recursive_formula_dependencies').map(cask_info_dependency_from_value(it))
		recursive_cask_dependencies: cask_info_values(value, 'recursive_cask_dependencies').map(cask_info_dependency_from_value(it))
		requirements: cask_info_values(value, 'requirements').map(cask_info_requirement_from_value(it))
		supports_linux: cask_info_bool_attr(value, 'supports_linux', false)
		languages: cask_info_strings(value, 'languages')
		artifacts: cask_info_values(value, 'artifacts').map(cask_info_artifact_from_value(it))
		caveats: value.attributes['caveats'] or { '' }
		tty: cask_info_bool_attr(value, 'tty', false)
	}
}

fn cask_info_dependency_value(dependency CaskInfoDependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name':      dependency.name
		'installed': dependency.installed.str()
	})
}

fn cask_info_requirement_value(requirement CaskInfoRequirement) ruby.Value {
	return ruby.structured_value(if requirement.macos_requirement {
		'MacOSRequirement'
	} else {
		'Requirement'
	}, requirement.display, {
		'display':                    requirement.display
		'kind':                       requirement.kind
		'satisfied':                  requirement.satisfied.str()
		'macos_requirement':          requirement.macos_requirement.str()
		'cask_dependent_requirement': requirement.cask_dependent_requirement.str()
	})
}

fn cask_info_artifact_value(artifact CaskInfoArtifact) ruby.Value {
	return ruby.structured_value('Artifact', artifact.display, {
		'display':       artifact.display
		'install_phase': artifact.install_phase.str()
		'ordinary':      artifact.ordinary.str()
	})
}

pub fn cask_info_value(cask CaskInfoModel) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		attributes: {
			'token':             cask.token
			'version':           cask.version
			'auto_updates':      cask.auto_updates.str()
			'desc':              cask.desc
			'homepage':          cask.homepage
			'deprecate_disable': cask.deprecate_disable
			'installed':         cask.installed.str()
			'installed_version': cask.installed_version
			'caskroom_path':     cask.caskroom_path
			'pinned':            cask.pinned.str()
			'pinned_version':    cask.pinned_version
			'pin_time':          cask.pin_time.str()
			'supports_linux':    cask.supports_linux.str()
			'caveats':           cask.caveats
			'tty':               cask.tty.str()
		}
		map_data: {
			'names':                          ruby.string_array_value(cask.names)
			'tap':                            ruby.structured_value('Tap', cask.tap.default_remote, {
				'present':            cask.tap.present.str()
				'custom_remote':      cask.tap.custom_remote.str()
				'remote':             cask.tap.remote
				'default_remote':     cask.tap.default_remote
				'relative_cask_path': cask.tap.relative_cask_path
				'core_cask_tap':      cask.tap.core_cask_tap.str()
			})
			'tab':                            ruby.structured_value('Cask::Tab', cask.tab.text, {
				'installed_on_request':     cask.tab.installed_on_request.str()
				'tabfile':                  cask.tab.tabfile
				'tabfile_exists':           cask.tab.tabfile_exists.str()
				'loaded_from_api':          cask.tab.loaded_from_api.str()
				'loaded_from_internal_api': cask.tab.loaded_from_internal_api.str()
				'time':                     cask.tab.time.str()
				'text':                     cask.tab.text
			})
			'formula_dependencies':           ruby.array_value(cask.formula_dependencies.map(cask_info_dependency_value(it)))
			'cask_dependencies':              ruby.array_value(cask.cask_dependencies.map(cask_info_dependency_value(it)))
			'recursive_formula_dependencies': ruby.array_value(cask.recursive_formula_dependencies.map(cask_info_dependency_value(it)))
			'recursive_cask_dependencies':    ruby.array_value(cask.recursive_cask_dependencies.map(cask_info_dependency_value(it)))
			'requirements':                   ruby.array_value(cask.requirements.map(cask_info_requirement_value(it)))
			'languages':                      ruby.string_array_value(cask.languages)
			'artifacts':                      ruby.array_value(cask.artifacts.map(cask_info_artifact_value(it)))
		}
	}
}

fn cask_info_output_options(cask CaskInfoModel) brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty: brew_utils.TtyState{
			stream_is_tty: cask.tty
		}
	}
}

fn cask_info_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn cask_info_title(cask CaskInfoModel, installed bool) string {
	options := cask_info_output_options(cask)
	name_with_status := if installed {
		brew_utils.pretty_installed(cask.token, options)
	} else {
		brew_utils.pretty_uninstalled(cask.token, true, options)
	}
	mut title := brew_utils.output_oh1_title(name_with_status, true, options)
	if cask.names.len > 0 {
		title += ' (${cask.names.join(', ')})'
	}
	title += ': ${cask.version}'
	if cask.auto_updates {
		title += ' (auto_updates)'
	}
	return title
}

fn cask_info_children_disk_usage(path string) i64 {
	mut total := i64(0)
	for child in os.ls(path) or { [] } {
		total += path_usage.pathname_disk_usage(os.join_path(path, child)) or { 0 }
	}
	return total
}

fn cask_info_tab_text(tab CaskInfoTab) string {
	if tab.text != '' {
		return tab.text
	}
	if tab.loaded_from_api && tab.time > 0 {
		kind := if tab.loaded_from_internal_api {
			'internal formulae.brew.sh'
		} else {
			'formulae.brew.sh'
		}
		formatted := time.unix(tab.time).local().strftime('%Y-%m-%d at %H:%M:%S')
		return 'Installed using the ${kind} API on ${formatted}'
	}
	return ''
}

fn cask_info_installation_status(tab CaskInfoTab) string {
	return if tab.installed_on_request {
		'Installed (on request)'
	} else {
		'Installed (as dependency)'
	}
}

pub fn cask_info_installation(cask CaskInfoModel, installed bool) string {
	if !installed {
		return 'Not installed'
	}
	if cask.installed_version == '' {
		return 'No installed version'
	}
	versioned_staged_path := os.join_path(cask.caskroom_path, cask.installed_version)
	status := cask_info_installation_status(cask.tab)
	if !os.exists(versioned_staged_path) {
		error_text := brew_utils.formatter_error('does not exist', none, cask_info_output_options(cask).tty)
		return '${status}\n${versioned_staged_path} (${error_text})\n'
	}
	mut info := [status,
		'${versioned_staged_path} (${brew_utils.formatter_disk_usage_readable(f64(cask_info_children_disk_usage(versioned_staged_path)))})']
	tab_text := cask_info_tab_text(cask.tab)
	if (cask.tab.tabfile_exists || (cask.tab.tabfile != '' && os.exists(cask.tab.tabfile))) && tab_text != '' {
		info << '  ${tab_text}'
	}
	return info.join('\n')
}

pub fn cask_info_decorate_dependency(dep string, installed bool, mark_uninstalled bool,
	cask CaskInfoModel) string {
	return brew_utils.pretty_install_status(dep, brew_utils.InstallStatusOptions{
		installed: installed
		mark_uninstalled: mark_uninstalled
	}, cask_info_output_options(cask))
}

fn cask_info_dependency_status_counts(installed int, total int, cask CaskInfoModel) string {
	missing := total - installed
	state := cask_info_output_options(cask).tty
	success := brew_utils.formatter_success('✔', none, state)
	if missing == 0 {
		return 'all installed ${success}'
	}
	error_text := brew_utils.formatter_error('✘', none, state)
	return '${installed} installed ${success}, ${missing} missing ${error_text}'
}

fn cask_info_recursive_dependencies(direct []CaskInfoDependency,
	recursive []CaskInfoDependency) []CaskInfoDependency {
	mut result := []CaskInfoDependency{}
	mut positions := map[string]int{}
	for dependency in direct {
		positions[dependency.name] = result.len
		result << dependency
	}
	for dependency in recursive {
		if position := positions[dependency.name] {
			if dependency.installed && !result[position].installed {
				result[position] = dependency
			}
			continue
		}
		positions[dependency.name] = result.len
		result << dependency
	}
	return result
}

pub fn cask_info_dependencies(cask CaskInfoModel, mark_uninstalled bool) ?string {
	mut all_dependencies := []string{}
	for dependency in cask.formula_dependencies {
		all_dependencies << cask_info_decorate_dependency(dependency.name, dependency.installed, mark_uninstalled, cask)
	}
	for dependency in cask.cask_dependencies {
		all_dependencies << cask_info_decorate_dependency('${dependency.name} (cask)', dependency.installed, mark_uninstalled, cask)
	}
	if all_dependencies.len == 0 {
		return none
	}
	mut lines := [
		brew_utils.output_ohai_title('Dependencies', cask_info_output_options(cask)),
		'Required (${all_dependencies.len}): ${all_dependencies.join(', ')}',
	]
	recursive_formula_dependencies := cask_info_recursive_dependencies(cask.formula_dependencies, cask.recursive_formula_dependencies)
	recursive_cask_dependencies := cask_info_recursive_dependencies(cask.cask_dependencies, cask.recursive_cask_dependencies)
	recursive_count := recursive_formula_dependencies.len + recursive_cask_dependencies.len
	if recursive_count > 0 {
		installed_count := recursive_formula_dependencies.filter(it.installed).len + recursive_cask_dependencies.filter(it.installed).len
		lines << 'Recursive Runtime (${recursive_count}): ${cask_info_dependency_status_counts(installed_count, recursive_count, cask)}'
	}
	return lines.join('\n') + '\n'
}

pub fn cask_info_requirements(cask CaskInfoModel, mark_uninstalled bool) ?string {
	requirements := cask.requirements.filter(!it.cask_dependent_requirement)
	if requirements.len == 0 {
		return none
	}
	mut output := brew_utils.output_ohai_title('Requirements', cask_info_output_options(cask)) + '\n'
	for kind in ['build', 'required', 'recommended', 'optional'] {
		matching := requirements.filter(it.kind == kind)
		if matching.len == 0 {
			continue
		}
		mut decorated := []string{}
		for requirement in matching {
			display := if requirement.macos_requirement && !cask.supports_linux {
				requirement.display.trim_string_right(' (or Linux)')
			} else {
				requirement.display
			}
			decorated << brew_utils.pretty_install_status(display, brew_utils.InstallStatusOptions{
				installed: requirement.satisfied
				mark_uninstalled: mark_uninstalled
			}, cask_info_output_options(cask))
		}
		output += '${kind.capitalize()}: ${decorated.join(', ')}\n'
	}
	return output
}

pub fn cask_info_languages(cask CaskInfoModel) ?string {
	if cask.languages.len == 0 {
		return none
	}
	return '${brew_utils.output_ohai_title('Languages', cask_info_output_options(cask))}\n${cask.languages.join(', ')}\n'
}

pub fn cask_info_repository(cask CaskInfoModel) ?string {
	if !cask.tap.present {
		return none
	}
	url := if cask.tap.custom_remote && cask.tap.remote != '' {
		cask.tap.remote
	} else {
		'${cask.tap.default_remote.trim_string_right('/')}/blob/HEAD/${cask.tap.relative_cask_path.trim_string_left('/')}'
	}
	return 'From: ${brew_utils.formatter_url(url, cask_info_output_options(cask).tty)}'
}

pub fn cask_info_artifacts(cask CaskInfoModel) string {
	mut output := brew_utils.output_ohai_title('Artifacts', cask_info_output_options(cask))
	for artifact in cask.artifacts {
		if artifact.install_phase && artifact.ordinary {
			output += '\n${artifact.display}'
		}
	}
	return output
}

pub fn cask_info_get(cask CaskInfoModel) string {
	mut output := cask_info_title(cask, cask.installed) + '\n'
	if cask.desc != '' {
		output += cask.desc + '\n'
	}
	if cask.homepage != '' {
		output += brew_utils.formatter_url(cask.homepage, cask_info_output_options(cask).tty) + '\n'
	}
	if cask.deprecate_disable != '' {
		message := cask.deprecate_disable[..1].to_upper() + cask.deprecate_disable[1..]
		output += message + '\n'
	}
	output += cask_info_installation(cask, cask.installed) + '\n'
	if cask.pinned {
		mut metadata := 'Pinned: ${cask.pinned_version}'
		if cask.pin_time > 0 {
			metadata += ' on ${time.unix(cask.pin_time).local().strftime('%Y-%m-%d at %H:%M:%S')}'
		}
		output += metadata + '\n'
	}
	if repository := cask_info_repository(cask) {
		output += repository + '\n'
	}
	if dependencies := cask_info_dependencies(cask, cask.installed) {
		output += dependencies
	}
	if requirements := cask_info_requirements(cask, cask.installed) {
		output += requirements
	}
	if languages := cask_info_languages(cask) {
		output += languages
	}
	output += cask_info_artifacts(cask) + '\n'
	if cask.caveats != '' {
		output += cask.caveats
	}
	return output
}
