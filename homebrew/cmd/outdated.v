module cmd

import x.json2

// Translated from Homebrew/brew `cmd/outdated.rb`.
pub enum OutdatedPackageKind {
	formula
	cask
}

pub enum OutdatedJsonVersion {
	none
	default_version
	v1
	v2
}

pub struct OutdatedKeg {
pub:
	full_name      string
	version        string
	version_scheme int
}

// OutdatedFormula is the command-side projection of the Formula and Keg
// methods queried by `brew outdated`.
pub struct OutdatedFormula {
pub:
	name                     string
	full_name                string
	full_installed_name      string
	pkg_version              string
	latest_formula_name      string
	latest_formula_version   string
	latest_version_installed bool
	latest_head_pkg_version  string
	version_scheme           int
	outdated                 bool
	head                     bool
	alias_changed            bool
	pinned                   bool
	pinned_version           string
	installed_kegs           []OutdatedKeg
	outdated_kegs            []OutdatedKeg
}

// OutdatedCask retains the state used by Cask#outdated_version and
// Cask#outdated_info, including the three independent greedy switches.
pub struct OutdatedCask {
pub:
	token                        string
	version                      string
	installed_version            string
	has_version                  bool = true
	version_latest               bool
	auto_updates                 bool
	upgrade_auto_updates_casks   bool = true
	auto_updates_bundle_outdated bool
	outdated_download_sha        bool
	pinned                       bool
	pinned_version               string
}

pub type OutdatedPackage = OutdatedCask | OutdatedFormula

pub struct OutdatedCommandOptions {
pub:
	quiet                bool
	verbose              bool
	context_verbose      bool
	stdout_tty           bool
	formula              bool
	cask                 bool
	json                 string
	minimum_version      string
	min_version          string
	fetch_head           bool
	greedy               bool
	greedy_latest        bool
	greedy_auto_updates  bool
	upgrade_greedy_casks []string
	named                []string
	formulae             []OutdatedFormula
	casks                []OutdatedCask
}

pub struct OutdatedInfo {
pub:
	name               string
	installed_versions []string
	current_version    string
	pinned             bool
	pinned_version     string
}

pub struct OutdatedCommandResult {
pub:
	stdout       string
	failed       bool
	error        string
	formulae     []OutdatedFormula
	casks        []OutdatedCask
	json_version OutdatedJsonVersion
}

fn outdated_minimum_version(options OutdatedCommandOptions) string {
	return if options.minimum_version != '' {
		options.minimum_version
	} else {
		options.min_version
	}
}

fn outdated_valid_version(value string) bool {
	if value == '' || value.to_lower() == 'latest' {
		return false
	}
	mut has_alphanumeric := false
	for character in value {
		if character.is_alnum() {
			has_alphanumeric = true
			continue
		}
		if character !in [`.`, `-`, `_`, `+`] {
			return false
		}
	}
	return has_alphanumeric
}

// This follows the PkgVersion ordering used by the command: compare version
// components first and a trailing `_revision` as the final numeric component.
fn outdated_compare_versions(left string, right string) !int {
	if !outdated_valid_version(left) || !outdated_valid_version(right) {
		return error('invalid version')
	}
	left_parts := left.trim_left('v').split_any('.-_+')
	right_parts := right.trim_left('v').split_any('.-_+')
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { '0' }
		right_part := if index < right_parts.len { right_parts[index] } else { '0' }
		left_number := left_part.int()
		right_number := right_part.int()
		if left_number != right_number {
			return if left_number < right_number { -1 } else { 1 }
		}
		if left_part != right_part && (left_number == 0 || right_number == 0) {
			return if left_part < right_part { -1 } else { 1 }
		}
	}
	return 0
}

pub fn outdated_json_version(version string) !OutdatedJsonVersion {
	return match version {
		'' { .none }
		'true', 'default' { .default_version }
		'v1' { .v1 }
		'v2' { .v2 }
		else {
			return error('invalid JSON version: ${version}')
		}
	}
}

pub fn outdated_verbose(options OutdatedCommandOptions) bool {
	return (options.stdout_tty || options.context_verbose || options.verbose) && !options.quiet
}

pub fn outdated_formula_kegs(formula OutdatedFormula, minimum_version string,
	_fetch_head bool) ![]OutdatedKeg {
	if minimum_version.trim_space() == '' {
		return formula.outdated_kegs.clone()
	}
	if !outdated_valid_version(minimum_version) {
		return error('invalid `--minimum-version`: ${minimum_version}')
	}
	mut selected := []OutdatedKeg{}
	for keg in formula.installed_kegs {
		comparison := outdated_compare_versions(keg.version, minimum_version) or { continue }
		if keg.version_scheme < formula.version_scheme || (keg.version_scheme == formula.version_scheme && comparison < 0) {
			selected << keg
		}
	}
	return selected
}

pub fn outdated_cask_version(cask OutdatedCask, greedy bool, greedy_latest bool,
	greedy_auto_updates bool) string {
	if !cask.has_version {
		return ''
	}
	if cask.version_latest {
		return if (greedy || greedy_latest) && cask.outdated_download_sha {
			cask.installed_version
		} else {
			''
		}
	}
	if cask.installed_version == cask.version {
		return ''
	}
	if cask.auto_updates && !greedy && !greedy_auto_updates {
		if !cask.upgrade_auto_updates_casks {
			return ''
		}
		return if cask.auto_updates_bundle_outdated { cask.installed_version } else { '' }
	}
	return cask.installed_version
}

pub fn outdated_upgrade_greedy_cask(greedy bool, cask OutdatedCask,
	upgrade_greedy_casks []string) bool {
	return greedy || cask.token in upgrade_greedy_casks
}

fn outdated_formula_selected(formula OutdatedFormula, options OutdatedCommandOptions) !bool {
	minimum := outdated_minimum_version(options)
	if minimum != '' {
		return outdated_formula_kegs(formula, minimum, options.fetch_head)!.len > 0
	}
	return formula.outdated
}

fn outdated_cask_selected(cask OutdatedCask, options OutdatedCommandOptions) !bool {
	minimum := outdated_minimum_version(options)
	if minimum != '' {
		if !outdated_valid_version(minimum) {
			return error('invalid `--minimum-version`: ${minimum}')
		}
		if cask.installed_version == '' || !outdated_valid_version(cask.installed_version) {
			return false
		}
		return outdated_compare_versions(cask.installed_version, minimum)! < 0
	}
	greedy := outdated_upgrade_greedy_cask(options.greedy, cask, options.upgrade_greedy_casks)
	return outdated_cask_version(cask, greedy, options.greedy_latest, options.greedy_auto_updates) != ''
}

pub fn select_outdated(packages []OutdatedPackage, options OutdatedCommandOptions) ![]OutdatedPackage {
	mut selected := []OutdatedPackage{}
	for package in packages {
		match package {
			OutdatedFormula {
				if outdated_formula_selected(package, options)! {
					selected << package
				}
			}
			OutdatedCask {
				if outdated_cask_selected(package, options)! {
					selected << package
				}
			}
		}
	}
	return selected
}

fn outdated_named_formula(formula OutdatedFormula, names []string) bool {
	return names.len == 0 || formula.name in names || formula.full_name in names
}

fn outdated_named_cask(cask OutdatedCask, names []string) bool {
	return names.len == 0 || cask.token in names
}

pub fn outdated_formulae(options OutdatedCommandOptions) ![]OutdatedFormula {
	mut selected := []OutdatedFormula{}
	for formula in options.formulae {
		if outdated_named_formula(formula, options.named) && outdated_formula_selected(formula, options)! {
			selected << formula
		}
	}
	selected.sort(a.full_name < b.full_name)
	return selected
}

pub fn outdated_casks(options OutdatedCommandOptions) ![]OutdatedCask {
	mut selected := []OutdatedCask{}
	for cask in options.casks {
		if outdated_named_cask(cask, options.named) && outdated_cask_selected(cask, options)! {
			selected << cask
		}
	}
	return selected
}

pub fn outdated_formulae_casks(options OutdatedCommandOptions) !([]OutdatedFormula, []OutdatedCask) {
	return outdated_formulae(options)!, outdated_casks(options)!
}

fn outdated_formula_current_version(formula OutdatedFormula, kegs []OutdatedKeg,
	options OutdatedCommandOptions) string {
	minimum := outdated_minimum_version(options)
	if minimum != '' {
		return minimum
	}
	latest_name := if formula.latest_formula_name != '' {
		formula.latest_formula_name
	} else {
		formula.name
	}
	latest_version := if formula.latest_formula_version != '' {
		formula.latest_formula_version
	} else {
		formula.pkg_version
	}
	if formula.alias_changed && !formula.latest_version_installed {
		return '${latest_name} (${latest_version})'
	}
	if formula.head {
		if kegs.any(it.version == formula.latest_head_pkg_version) {
			// There is a newer HEAD but the version number has not changed.
			return 'latest HEAD'
		}
		return formula.latest_head_pkg_version
	}
	return latest_version
}

fn outdated_formula_version_list(kegs []OutdatedKeg) string {
	mut names := []string{}
	mut versions := map[string][]string{}
	for keg in kegs {
		name := keg.full_name
		if name !in versions {
			names << name
		}
		versions[name] << keg.version
	}
	names.sort()
	return names.map('${it} (${versions[it].join(', ')})').join(', ')
}

pub fn print_outdated(packages []OutdatedPackage, options OutdatedCommandOptions) !string {
	mut lines := []string{}
	for package in packages {
		match package {
			OutdatedFormula {
				if outdated_verbose(options) {
					kegs := outdated_formula_kegs(package, outdated_minimum_version(options), options.fetch_head)!
					current := outdated_formula_current_version(package, kegs, options)
					pinned := if package.pinned {
						' [pinned at ${package.pinned_version}]'
					} else {
						''
					}
					lines << '${outdated_formula_version_list(kegs)} < ${current}${pinned}'
				} else {
					lines << if package.full_installed_name != '' {
						package.full_installed_name
					} else {
						package.full_name
					}
				}
			}
			OutdatedCask {
				minimum := outdated_minimum_version(options)
				if minimum != '' {
					if outdated_verbose(options) {
						pinned := if package.pinned {
							' [pinned at ${package.pinned_version}]'
						} else {
							''
						}
						lines << '${package.token} (${package.installed_version}) < ${minimum}${pinned}'
					} else {
						lines << package.token
					}
				} else if !outdated_verbose(options) {
					lines << package.token
				} else {
					greedy := outdated_upgrade_greedy_cask(options.greedy, package, options.upgrade_greedy_casks)
					installed := outdated_cask_version(package, greedy, options.greedy_latest, options.greedy_auto_updates)
					pinned := if package.pinned {
						' [pinned at ${package.pinned_version}]'
					} else {
						''
					}
					lines << '${package.token} (${installed}) != ${package.version}${pinned}'
				}
			}
		}
	}
	return if lines.len == 0 { '' } else { lines.join('\n') + '\n' }
}

pub fn outdated_json_info(packages []OutdatedPackage, options OutdatedCommandOptions) ![]OutdatedInfo {
	mut information := []OutdatedInfo{}
	for package in packages {
		match package {
			OutdatedFormula {
				kegs := outdated_formula_kegs(package, outdated_minimum_version(options), options.fetch_head)!
				versions := kegs.map(it.version)
				minimum := outdated_minimum_version(options)
				current := if minimum != '' {
					minimum
				} else if package.head && versions.any(it == package.pkg_version) {
					'HEAD'
				} else {
					package.pkg_version
				}
				information << OutdatedInfo{
					name: package.full_name
					installed_versions: versions
					current_version: current
					pinned: package.pinned
					pinned_version: package.pinned_version
				}
			}
			OutdatedCask {
				minimum := outdated_minimum_version(options)
				greedy := outdated_upgrade_greedy_cask(options.greedy, package, options.upgrade_greedy_casks)
				installed := if minimum != '' {
					package.installed_version
				} else {
					outdated_cask_version(package, greedy, options.greedy_latest, options.greedy_auto_updates)
				}
				information << OutdatedInfo{
					name: package.token
					installed_versions: [installed]
					current_version: if minimum != '' { minimum } else { package.version }
					pinned: package.pinned
					pinned_version: package.pinned_version
				}
			}
		}
	}
	return information
}

fn outdated_json_string(value string) string {
	return json2.encode(value)
}

fn outdated_render_versions(versions []string) []string {
	if versions.len == 0 {
		return ['      "installed_versions": [],']
	}
	mut lines := ['      "installed_versions": [']
	for index, version in versions {
		comma := if index + 1 < versions.len { ',' } else { '' }
		lines << '        ${outdated_json_string(version)}${comma}'
	}
	lines << '      ],'
	return lines
}

fn outdated_render_info(info OutdatedInfo) []string {
	mut lines := ['    {', '      "name": ${outdated_json_string(info.name)},']
	lines << outdated_render_versions(info.installed_versions)
	lines << '      "current_version": ${outdated_json_string(info.current_version)},'
	lines << '      "pinned": ${info.pinned},'
	lines << if info.pinned_version == '' {
		'      "pinned_version": null'
	} else {
		'      "pinned_version": ${outdated_json_string(info.pinned_version)}'
	}
	lines << '    }'
	return lines
}

fn outdated_render_info_array(key string, values []OutdatedInfo, comma bool) []string {
	if values.len == 0 {
		return ['  "${key}": []${if comma { ',' } else { '' }}']
	}
	mut lines := ['  "${key}": [']
	for index, value in values {
		mut object_lines := outdated_render_info(value)
		if index + 1 < values.len {
			object_lines[object_lines.len - 1] += ','
		}
		lines << object_lines
	}
	lines << '  ]${if comma { ',' } else { '' }}'
	return lines
}

pub fn outdated_json_output(formulae []OutdatedInfo, casks []OutdatedInfo) string {
	mut lines := ['{']
	lines << outdated_render_info_array('formulae', formulae, true)
	lines << outdated_render_info_array('casks', casks, false)
	lines << '}'
	return lines.join('\n') + '\n'
}

pub fn run_outdated(options OutdatedCommandOptions) !OutdatedCommandResult {
	minimum := outdated_minimum_version(options)
	if minimum != '' && options.named.len != 1 {
		return error('`--minimum-version` requires exactly one formula or cask argument.')
	}
	version := outdated_json_version(options.json)!
	if version == .v1 {
		return error('`brew outdated --json=v1` is no longer supported. Use brew outdated --json=v2 instead.')
	}
	mut formulae := []OutdatedFormula{}
	mut casks := []OutdatedCask{}
	if options.formula {
		formulae = outdated_formulae(options)!
	} else if options.cask {
		casks = outdated_casks(options)!
	} else {
		formulae, casks = outdated_formulae_casks(options)!
	}
	mut output := ''
	if version in [.v2, .default_version] {
		formula_packages := formulae.map(OutdatedPackage(it))
		cask_packages := casks.map(OutdatedPackage(it))
		output = outdated_json_output(outdated_json_info(formula_packages, options)!, outdated_json_info(cask_packages, options)!)
	} else {
		mut packages := []OutdatedPackage{}
		packages << formulae.map(OutdatedPackage(it))
		packages << casks.map(OutdatedPackage(it))
		output = print_outdated(packages, options)!
	}
	return OutdatedCommandResult{
		stdout: output
		failed: options.named.len > 0 && formulae.len + casks.len > 0
		formulae: formulae
		casks: casks
		json_version: version
	}
}
