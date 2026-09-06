module cask

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

fn cask_info_output_options(cask CaskInfoModel) brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty: brew_utils.TtyState{
			stream_is_tty: cask.tty
		}
	}
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
