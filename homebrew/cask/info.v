module cask

import ruby
import homebrew.extend.pathname as path_usage
import homebrew.utils as brew_utils
import os
import time

// Translated from Homebrew/brew `cask/info.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.get_info(cask)` at line 13.
pub fn ruby_info_l13_d1_self_get_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('get_info requires a cask')
	}
	return ruby.string_value(cask_info_get(cask_info_from_value(args[0])))
}

// Ruby method `self.info(cask, args:)` at line 43.
pub fn ruby_info_l43_d2_self_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('info requires a cask')
	}
	// The typed boundary returns the text that Ruby writes to stdout. The tap
	// analytics side effect is intentionally represented by the caller-facing
	// output boundary and is only eligible for core-cask taps, as in Ruby.
	return ruby.string_value(cask_info_get(cask_info_from_value(args[0])))
}

// Ruby method `self.title_info(cask, installed:)` at line 53.
pub fn ruby_info_l53_d3_self_title_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('title_info requires a cask')
	}
	cask := cask_info_from_value(args[0])
	installed := if args.len > 1 { args[1].bool_data } else { cask.installed }
	return ruby.string_value(cask_info_title(cask, installed))
}

// Ruby method `self.installation_info(cask, installed:)` at line 67.
pub fn ruby_info_l67_d4_self_installation_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('installation_info requires a cask')
	}
	cask := cask_info_from_value(args[0])
	installed := if args.len > 1 { args[1].bool_data } else { cask.installed }
	return ruby.string_value(cask_info_installation(cask, installed))
}

// Ruby method `self.deps_info(cask, mark_uninstalled: true)` at line 88.
pub fn ruby_info_l88_d5_self_deps_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('deps_info requires a cask')
	}
	cask := cask_info_from_value(args[0])
	mark_uninstalled := if args.len > 1 { args[1].bool_data } else { true }
	if output := cask_info_dependencies(cask, mark_uninstalled) {
		return ruby.string_value(output)
	}
	return cask_info_nil()
}

// Ruby method `self.decorate_dependency(dep, installed:, mark_uninstalled: true)` at line 137.
pub fn ruby_info_l137_d6_self_decorate_dependency(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('decorate_dependency requires a dependency and installed state')
	}
	installed := args[1].bool_data
	mark_uninstalled := if args.len > 2 { args[2].bool_data } else { true }
	tty := if args.len > 3 { args[3].bool_data } else { false }
	return ruby.string_value(cask_info_decorate_dependency(args[0].as_string(), installed, mark_uninstalled, CaskInfoModel{
		tty: tty
	}))
}

// Ruby method `self.requirements_info(cask, mark_uninstalled: true)` at line 142.
pub fn ruby_info_l142_d7_self_requirements_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('requirements_info requires a cask')
	}
	cask := cask_info_from_value(args[0])
	mark_uninstalled := if args.len > 1 { args[1].bool_data } else { true }
	if output := cask_info_requirements(cask, mark_uninstalled) {
		return ruby.string_value(output)
	}
	return cask_info_nil()
}

// Ruby method `self.language_info(cask)` at line 182.
pub fn ruby_info_l182_d8_self_language_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('language_info requires a cask')
	}
	if output := cask_info_languages(cask_info_from_value(args[0])) {
		return ruby.string_value(output)
	}
	return cask_info_nil()
}

// Ruby method `self.repo_info(cask)` at line 192.
pub fn ruby_info_l192_d9_self_repo_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('repo_info requires a cask')
	}
	if output := cask_info_repository(cask_info_from_value(args[0])) {
		return ruby.string_value(output)
	}
	return cask_info_nil()
}

// Ruby method `self.artifact_info(cask)` at line 205.
pub fn ruby_info_l205_d10_self_artifact_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('artifact_info requires a cask')
	}
	return ruby.string_value(cask_info_artifacts(cask_info_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "cmd/info"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class Info
// 10:     extend ::Utils::Output::Mixin
// 11:
// 12:     sig { params(cask: Cask).returns(String) }
// 13:     def self.get_info(cask)
// 14:       require "cask/installer"
// 15:
// 16:       installed = cask.installed?
// 17:       output = "#{title_info(cask, installed:)}\n"
// 18:       output << "#{cask.desc}\n" if cask.desc
// 19:       output << "#{Formatter.url(cask.homepage)}\n" if cask.homepage
// 20:       deprecate_disable = DeprecateDisable.message(cask)
// 21:       if deprecate_disable.present?
// 22:         deprecate_disable.tap { |message| message[0] = message[0].upcase }
// 23:         output << "#{deprecate_disable}\n"
// 24:       end
// 25:       output << "#{installation_info(cask, installed:)}\n"
// 26:       metadata = Homebrew::Cmd::Info.metadata_lines(cask)
// 27:       output << "#{metadata.join("\n")}\n" if metadata.present?
// 28:       repo = repo_info(cask)
// 29:       output << "#{repo}\n" if repo
// 30:       deps = deps_info(cask, mark_uninstalled: installed)
// 31:       output << deps if deps
// 32:       requirements = requirements_info(cask, mark_uninstalled: installed)
// 33:       output << requirements if requirements
// 34:       language = language_info(cask)
// 35:       output << language if language
// 36:       output << "#{artifact_info(cask)}\n"
// 37:       caveats = Installer.caveats(cask)
// 38:       output << caveats if caveats
// 39:       output
// 40:     end
// 41:
// 42:     sig { params(cask: Cask, args: Homebrew::Cmd::Info::Args).void }
// 43:     def self.info(cask, args:)
// 44:       puts get_info(cask)
// 45:
// 46:       return unless cask.tap&.core_cask_tap?
// 47:
// 48:       require "utils/analytics"
// 49:       ::Utils::Analytics.cask_output(cask, args:)
// 50:     end
// 51:
// 52:     sig { params(cask: Cask, installed: T::Boolean).returns(String) }
// 53:     def self.title_info(cask, installed:)
// 54:       name_with_status = if installed
// 55:         pretty_installed(cask.token)
// 56:       else
// 57:         pretty_uninstalled(cask.token)
// 58:       end
// 59:       title = oh1_title(name_with_status).to_s
// 60:       title += " (#{cask.name.join(", ")})" unless cask.name.empty?
// 61:       title += ": #{cask.version}"
// 62:       title += " (auto_updates)" if cask.auto_updates
// 63:       title
// 64:     end
// 65:
// 66:     sig { params(cask: Cask, installed: T::Boolean).returns(String) }
// 67:     def self.installation_info(cask, installed:)
// 68:       return "Not installed" unless installed
// 69:       return "No installed version" unless (installed_version = cask.installed_version).present?
// 70:
// 71:       versioned_staged_path = cask.caskroom_path.join(installed_version)
// 72:       tab = Tab.for_cask(cask)
// 73:
// 74:       unless versioned_staged_path.exist?
// 75:         return "#{Homebrew::Cmd::Info.installation_status(tab)}\n" \
// 76:                "#{versioned_staged_path} (#{Formatter.error("does not exist")})\n"
// 77:       end
// 78:
// 79:       path_details = versioned_staged_path.children.sum(&:disk_usage)
// 80:
// 81:       info = [Homebrew::Cmd::Info.installation_status(tab)]
// 82:       info << "#{versioned_staged_path} (#{Formatter.disk_usage_readable(path_details)})"
// 83:       info << "  #{tab}" if tab.tabfile&.exist?
// 84:       info.join("\n")
// 85:     end
// 86:
// 87:     sig { params(cask: Cask, mark_uninstalled: T::Boolean).returns(T.nilable(String)) }
// 88:     def self.deps_info(cask, mark_uninstalled: true)
// 89:       depends_on = cask.depends_on
// 90:
// 91:       formula_deps = Array(depends_on[:formula]).map do |dep|
// 92:         name = dep.to_s
// 93:         rack = HOMEBREW_CELLAR/::Utils.name_from_full_name(name)
// 94:         decorate_dependency(
// 95:           name,
// 96:           installed:        rack.directory? && !rack.subdirs.empty?,
// 97:           mark_uninstalled:,
// 98:         )
// 99:       end
// 100:
// 101:       cask_deps = Array(depends_on[:cask]).map do |dep|
// 102:         name = dep.to_s
// 103:         decorate_dependency(
// 104:           "#{name} (cask)",
// 105:           installed:        (Caskroom.path/name).directory?,
// 106:           mark_uninstalled:,
// 107:         )
// 108:       end
// 109:
// 110:       all_deps = formula_deps + cask_deps
// 111:       return if all_deps.empty?
// 112:
// 113:       formula_dependencies = T.let(Set.new, T::Set[String])
// 114:       cask_dependencies = T.let(Set.new, T::Set[String])
// 115:       Homebrew::Cmd::Info.collect_cask_dependency_names(cask, formula_dependencies, cask_dependencies,
// 116:                                                         Set[cask.token])
// 117:       recursive_count = formula_dependencies.count + cask_dependencies.count
// 118:       lines = T.let(
// 119:         [ohai_title("Dependencies").to_s, "Required (#{all_deps.count}): #{all_deps.join(", ")}"],
// 120:         T::Array[String],
// 121:       )
// 122:       unless recursive_count.zero?
// 123:         installed_count = formula_dependencies.count do |name|
// 124:           rack = HOMEBREW_CELLAR/::Utils.name_from_full_name(name)
// 125:           rack.directory? && !rack.subdirs.empty?
// 126:         end + cask_dependencies.count do |name|
// 127:           (Caskroom.path/name).directory?
// 128:         end
// 129:         lines << "Recursive Runtime (#{recursive_count}): " \
// 130:                  "#{Homebrew::Cmd::Info.dependency_status_counts(installed_count, recursive_count)}"
// 131:       end
// 132:
// 133:       "#{lines.join("\n")}\n"
// 134:     end
// 135:
// 136:     sig { params(dep: String, installed: T::Boolean, mark_uninstalled: T::Boolean).returns(String) }
// 137:     def self.decorate_dependency(dep, installed:, mark_uninstalled: true)
// 138:       pretty_install_status(dep, installed:, mark_uninstalled:)
// 139:     end
// 140:
// 141:     sig { params(cask: Cask, mark_uninstalled: T::Boolean).returns(T.nilable(String)) }
// 142:     def self.requirements_info(cask, mark_uninstalled: true)
// 143:       require "cask_dependent"
// 144:
// 145:       requirements = CaskDependent.new(cask).requirements.grep_v(CaskDependent::Requirement)
// 146:       return if requirements.empty?
// 147:
// 148:       supports_linux = cask.supports_linux?
// 149:       output = "#{ohai_title("Requirements")}\n"
// 150:       %w[build required recommended optional].each do |type|
// 151:         reqs = case type
// 152:         when "build"
// 153:           requirements.select(&:build?)
// 154:         when "required"
// 155:           requirements.select(&:required?)
// 156:         when "recommended"
// 157:           requirements.select(&:recommended?)
// 158:         when "optional"
// 159:           requirements.select(&:optional?)
// 160:         else
// 161:           []
// 162:         end
// 163:         next if reqs.empty?
// 164:
// 165:         output << "#{type.capitalize}: #{reqs.map do |requirement|
// 166:           requirement_s = if requirement.is_a?(MacOSRequirement) && !supports_linux
// 167:             requirement.display_s.delete_suffix(" (or Linux)")
// 168:           else
// 169:             requirement.display_s
// 170:           end
// 171:           pretty_install_status(
// 172:             requirement_s,
// 173:             installed:        requirement.satisfied?,
// 174:             mark_uninstalled:,
// 175:           )
// 176:         end.join(", ")}\n"
// 177:       end
// 178:       output
// 179:     end
// 180:
// 181:     sig { params(cask: Cask).returns(T.nilable(String)) }
// 182:     def self.language_info(cask)
// 183:       return if cask.languages.empty?
// 184:
// 185:       <<~EOS
// 186:         #{ohai_title("Languages")}
// 187:         #{cask.languages.join(", ")}
// 188:       EOS
// 189:     end
// 190:
// 191:     sig { params(cask: Cask).returns(T.nilable(String)) }
// 192:     def self.repo_info(cask)
// 193:       return unless (tap = cask.tap)
// 194:
// 195:       url = if tap.custom_remote? && !tap.remote.nil?
// 196:         tap.remote
// 197:       else
// 198:         "#{tap.default_remote}/blob/HEAD/#{tap.relative_cask_path(cask.token)}"
// 199:       end
// 200:
// 201:       "From: #{Formatter.url(url)}"
// 202:     end
// 203:
// 204:     sig { params(cask: Cask).returns(String) }
// 205:     def self.artifact_info(cask)
// 206:       artifact_output = ohai_title("Artifacts").dup
// 207:       cask.artifacts.each do |artifact|
// 208:         next unless artifact.respond_to?(:install_phase)
// 209:         next unless DSL::ORDINARY_ARTIFACT_CLASSES.include?(artifact.class)
// 210:
// 211:         artifact_output << "\n" << artifact.to_s
// 212:       end
// 213:       artifact_output.freeze
// 214:     end
// 215:   end
// 216: end
