module cmd

import ruby
import x.json2

// Translated from Homebrew/brew `cmd/outdated.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn outdated_bool(value ruby.Value, key string) bool {
	if item := value.map_data[key] {
		return item.bool_data
	}
	raw := value.attributes[key] or { return false }
	return raw in ['true', '1']
}

fn outdated_string(value ruby.Value, key string) string {
	if item := value.map_data[key] {
		return item.as_string()
	}
	return value.attributes[key] or { '' }
}

fn outdated_strings(value ruby.Value, key string) []string {
	if item := value.map_data[key] {
		return item.as_string_array() or { []string{} }
	}
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn outdated_values(value ruby.Value, key string) []ruby.Value {
	item := value.map_data[key] or { return [] }
	return item.as_array() or { [] }
}

fn outdated_keg_from_value(value ruby.Value) OutdatedKeg {
	return OutdatedKeg{
		full_name: outdated_string(value, 'full_name')
		version: outdated_string(value, 'version')
		version_scheme: outdated_string(value, 'version_scheme').int()
	}
}

fn outdated_formula_from_value(value ruby.Value) OutdatedFormula {
	name := outdated_string(value, 'name')
	full_name := if outdated_string(value, 'full_name') != '' {
		outdated_string(value, 'full_name')
	} else {
		name
	}
	return OutdatedFormula{
		name: name
		full_name: full_name
		full_installed_name: if outdated_string(value, 'full_installed_name') != '' {
			outdated_string(value, 'full_installed_name')
		} else {
			full_name
		}
		pkg_version: outdated_string(value, 'pkg_version')
		latest_formula_name: outdated_string(value, 'latest_formula_name')
		latest_formula_version: outdated_string(value, 'latest_formula_version')
		latest_version_installed: outdated_bool(value, 'latest_version_installed')
		latest_head_pkg_version: outdated_string(value, 'latest_head_pkg_version')
		version_scheme: outdated_string(value, 'version_scheme').int()
		outdated: outdated_bool(value, 'outdated')
		head: outdated_bool(value, 'head')
		alias_changed: outdated_bool(value, 'alias_changed')
		pinned: outdated_bool(value, 'pinned')
		pinned_version: outdated_string(value, 'pinned_version')
		installed_kegs: outdated_values(value, 'installed_kegs').map(outdated_keg_from_value(it))
		outdated_kegs: outdated_values(value, 'outdated_kegs').map(outdated_keg_from_value(it))
	}
}

fn outdated_cask_from_value(value ruby.Value) OutdatedCask {
	return OutdatedCask{
		token: outdated_string(value, 'token')
		version: outdated_string(value, 'version')
		installed_version: outdated_string(value, 'installed_version')
		has_version: if 'has_version' in value.attributes || 'has_version' in value.map_data {
			outdated_bool(value, 'has_version')
		} else {
			true
		}
		version_latest: outdated_bool(value, 'version_latest')
		auto_updates: outdated_bool(value, 'auto_updates')
		upgrade_auto_updates_casks: if 'upgrade_auto_updates_casks' in value.attributes || 'upgrade_auto_updates_casks' in value.map_data {
			outdated_bool(value, 'upgrade_auto_updates_casks')
		} else {
			true
		}
		auto_updates_bundle_outdated: outdated_bool(value, 'auto_updates_bundle_outdated')
		outdated_download_sha: outdated_bool(value, 'outdated_download_sha')
		pinned: outdated_bool(value, 'pinned')
		pinned_version: outdated_string(value, 'pinned_version')
	}
}

fn outdated_package_from_value(value ruby.Value) OutdatedPackage {
	return if value.type_name in ['Cask', 'Cask::Cask', 'OutdatedCask'] {
		OutdatedPackage(outdated_cask_from_value(value))
	} else {
		OutdatedPackage(outdated_formula_from_value(value))
	}
}

fn outdated_options_from_value(value ruby.Value) OutdatedCommandOptions {
	return OutdatedCommandOptions{
		quiet: outdated_bool(value, 'quiet')
		verbose: outdated_bool(value, 'verbose')
		context_verbose: outdated_bool(value, 'context_verbose')
		stdout_tty: outdated_bool(value, 'stdout_tty')
		formula: outdated_bool(value, 'formula')
		cask: outdated_bool(value, 'cask')
		json: outdated_string(value, 'json')
		minimum_version: outdated_string(value, 'minimum_version')
		min_version: outdated_string(value, 'min_version')
		fetch_head: outdated_bool(value, 'fetch_head')
		greedy: outdated_bool(value, 'greedy')
		greedy_latest: outdated_bool(value, 'greedy_latest')
		greedy_auto_updates: outdated_bool(value, 'greedy_auto_updates')
		upgrade_greedy_casks: outdated_strings(value, 'upgrade_greedy_casks')
		named: outdated_strings(value, 'named')
		formulae: outdated_values(value, 'formulae').map(outdated_formula_from_value(it))
		casks: outdated_values(value, 'casks').map(outdated_cask_from_value(it))
	}
}

fn outdated_keg_value(keg OutdatedKeg) ruby.Value {
	return ruby.structured_value('Keg', keg.version, {
		'full_name':      keg.full_name
		'version':        keg.version
		'version_scheme': keg.version_scheme.str()
	})
}

pub fn outdated_formula_value(formula OutdatedFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'name':                     formula.name
			'full_name':                formula.full_name
			'full_installed_name':      formula.full_installed_name
			'pkg_version':              formula.pkg_version
			'latest_formula_name':      formula.latest_formula_name
			'latest_formula_version':   formula.latest_formula_version
			'latest_version_installed': formula.latest_version_installed.str()
			'latest_head_pkg_version':  formula.latest_head_pkg_version
			'version_scheme':           formula.version_scheme.str()
			'outdated':                 formula.outdated.str()
			'head':                     formula.head.str()
			'alias_changed':            formula.alias_changed.str()
			'pinned':                   formula.pinned.str()
			'pinned_version':           formula.pinned_version
		}
		map_data: {
			'installed_kegs': ruby.array_value(formula.installed_kegs.map(outdated_keg_value(it)))
			'outdated_kegs':  ruby.array_value(formula.outdated_kegs.map(outdated_keg_value(it)))
		}
	}
}

pub fn outdated_cask_value(cask OutdatedCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.token, {
		'token':                        cask.token
		'version':                      cask.version
		'installed_version':            cask.installed_version
		'has_version':                  cask.has_version.str()
		'version_latest':               cask.version_latest.str()
		'auto_updates':                 cask.auto_updates.str()
		'upgrade_auto_updates_casks':   cask.upgrade_auto_updates_casks.str()
		'auto_updates_bundle_outdated': cask.auto_updates_bundle_outdated.str()
		'outdated_download_sha':        cask.outdated_download_sha.str()
		'pinned':                       cask.pinned.str()
		'pinned_version':               cask.pinned_version
	})
}

pub fn outdated_options_value(options OutdatedCommandOptions) ruby.Value {
	return ruby.Value{
		type_name: 'OutdatedCommandOptions'
		attributes: {
			'quiet':                options.quiet.str()
			'verbose':              options.verbose.str()
			'context_verbose':      options.context_verbose.str()
			'stdout_tty':           options.stdout_tty.str()
			'formula':              options.formula.str()
			'cask':                 options.cask.str()
			'json':                 options.json
			'minimum_version':      options.minimum_version
			'min_version':          options.min_version
			'fetch_head':           options.fetch_head.str()
			'greedy':               options.greedy.str()
			'greedy_latest':        options.greedy_latest.str()
			'greedy_auto_updates':  options.greedy_auto_updates.str()
			'upgrade_greedy_casks': options.upgrade_greedy_casks.join('\x1f')
			'named':                options.named.join('\x1f')
		}
		map_data: {
			'formulae': ruby.array_value(options.formulae.map(outdated_formula_value(it)))
			'casks':    ruby.array_value(options.casks.map(outdated_cask_value(it)))
		}
	}
}

fn outdated_info_value(info OutdatedInfo) ruby.Value {
	return ruby.map_value({
		'name':               ruby.string_value(info.name)
		'installed_versions': ruby.string_array_value(info.installed_versions)
		'current_version':    ruby.string_value(info.current_version)
		'pinned':             ruby.bool_value(info.pinned)
		'pinned_version':     if info.pinned_version == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.string_value(info.pinned_version)
		}
	})
}

fn outdated_result_value(result OutdatedCommandResult) ruby.Value {
	return ruby.Value{
		type_name: if result.error == '' { 'OutdatedCommandResult' } else { 'UsageError' }
		repr: if result.error == '' { result.stdout } else { result.error }
		bool_data: result.failed
		attributes: {
			'stdout':       result.stdout
			'failed':       result.failed.str()
			'error':        result.error
			'json_version': result.json_version.str()
		}
		map_data: {
			'formulae': ruby.array_value(result.formulae.map(outdated_formula_value(it)))
			'casks':    ruby.array_value(result.casks.map(outdated_cask_value(it)))
		}
	}
}

// Ruby method `run` at line 53.
pub fn ruby_outdated_l53_d1_run(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 {
		outdated_options_from_value(args[0])
	} else {
		OutdatedCommandOptions{}
	}
	result := run_outdated(options) or {
		return outdated_result_value(OutdatedCommandResult{
			error: err.msg()
		})
	}
	return outdated_result_value(result)
}

// Ruby method `select_outdated(formulae_or_casks)` at line 96.
pub fn ruby_outdated_l96_d2_select_outdated(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([])
	}
	options := outdated_options_from_value(args[0])
	packages := args[1].as_array() or { [] }.map(outdated_package_from_value(it))
	selected := select_outdated(packages, options) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value(selected.map(match it {
		OutdatedFormula { outdated_formula_value(it) }
		OutdatedCask { outdated_cask_value(it) }
	}))
}

// Ruby method `print_outdated(formulae_or_casks)` at line 121.
pub fn ruby_outdated_l121_d3_print_outdated(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	options := outdated_options_from_value(args[0])
	packages := args[1].as_array() or { [] }.map(outdated_package_from_value(it))
	return ruby.string_value(print_outdated(packages, options) or {
		return ruby.object_value('UsageError', err.msg())
	})
}

// Ruby method `json_info(formulae_or_casks)` at line 182.
pub fn ruby_outdated_l182_d4_json_info(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([])
	}
	options := outdated_options_from_value(args[0])
	packages := args[1].as_array() or { [] }.map(outdated_package_from_value(it))
	information := outdated_json_info(packages, options) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value(information.map(outdated_info_value(it)))
}

// Ruby method `verbose?` at line 222.
pub fn ruby_outdated_l222_d5_verbose(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 {
		outdated_options_from_value(args[0])
	} else {
		OutdatedCommandOptions{}
	}
	return ruby.bool_value(outdated_verbose(options))
}

// Ruby method `json_version(version)` at line 227.
pub fn ruby_outdated_l227_d6_json_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args.last().type_name == 'NilClass' {
		return ruby.object_value('NilClass', 'nil')
	}
	value := args.last()
	version := if value.type_name == 'Bool' && value.bool_data { 'true' } else { value.as_string() }
	parsed := outdated_json_version(version) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.object_value('Symbol', match parsed {
		.none { 'nil' }
		.default_version { ':default' }
		.v1 { ':v1' }
		.v2 { ':v2' }
	})
}

// Ruby method `minimum_version = args.minimum_version || args.min_version` at line 238.
pub fn ruby_outdated_l238_d7_minimum_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	version := outdated_minimum_version(outdated_options_from_value(args[0]))
	return if version == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(version)
	}
}

// Ruby method `outdated_formulae` at line 241.
pub fn ruby_outdated_l241_d8_outdated_formulae(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	formulae := outdated_formulae(outdated_options_from_value(args[0])) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value(formulae.map(outdated_formula_value(it)))
}

// Ruby method `outdated_casks` at line 249.
pub fn ruby_outdated_l249_d9_outdated_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	casks := outdated_casks(outdated_options_from_value(args[0])) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value(casks.map(outdated_cask_value(it)))
}

// Ruby method `outdated_formulae_casks` at line 260.
pub fn ruby_outdated_l260_d10_outdated_formulae_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([ruby.array_value([]), ruby.array_value([])])
	}
	formulae, casks := outdated_formulae_casks(outdated_options_from_value(args[0])) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value([
		ruby.array_value(formulae.map(outdated_formula_value(it))),
		ruby.array_value(casks.map(outdated_cask_value(it))),
	])
}

// Ruby method `formula_outdated_kegs(formula)` at line 272.
pub fn ruby_outdated_l272_d11_formula_outdated_kegs(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([])
	}
	options := outdated_options_from_value(args[0])
	kegs := outdated_formula_kegs(outdated_formula_from_value(args[1]), outdated_minimum_version(options), options.fetch_head) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.array_value(kegs.map(outdated_keg_value(it)))
}

// Ruby method `upgrade_greedy_cask?(greedy, cask)` at line 277.
pub fn ruby_outdated_l277_d12_upgrade_greedy_cask(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.bool_value(false)
	}
	options := outdated_options_from_value(args[0])
	return ruby.bool_value(outdated_upgrade_greedy_cask(args[1].bool_data, outdated_cask_from_value(args[2]), options.upgrade_greedy_casks))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "api"
// 8: require "minimum_version"
// 9:
// 10: module Homebrew
// 11:   module Cmd
// 12:     class Outdated < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           List installed casks and formulae that have an updated version available. By default, version
// 16:           information is displayed in interactive shells and suppressed otherwise.
// 17:         EOS
// 18:         switch "-q", "--quiet",
// 19:                description: "List only the names of outdated kegs (takes precedence over `--verbose`)."
// 20:         switch "-v", "--verbose",
// 21:                description: "Include detailed version information."
// 22:         switch "--formula", "--formulae",
// 23:                description: "List only outdated formulae."
// 24:         switch "--cask", "--casks",
// 25:                description: "List only outdated casks."
// 26:         flag   "--json",
// 27:                description: "Print output in JSON format. There are two versions: `v1` and `v2`. " \
// 28:                             "`v1` is deprecated and is currently the default if no version is specified. " \
// 29:                             "`v2` prints outdated formulae and casks."
// 30:         flag   "--minimum-version=", "--min-version=",
// 31:                description: "Only list a named formula or cask with an installed version below the given " \
// 32:                             "minimum version."
// 33:         switch "--fetch-HEAD",
// 34:                description: "Fetch the upstream repository to detect if the HEAD installation of the " \
// 35:                             "formula is outdated. Otherwise, the repository's HEAD will only be checked for " \
// 36:                             "updates when a new stable or development version has been released."
// 37:         switch "-g", "--greedy",
// 38:                description: "Also include outdated casks with `version :latest` and `auto_updates true` " \
// 39:                             "casks that would otherwise be skipped.",
// 40:                env:         :upgrade_greedy
// 41:         switch "--greedy-latest",
// 42:                description: "Also include outdated casks including those with `version :latest`."
// 43:         switch "--greedy-auto-updates",
// 44:                description: "Also include outdated `auto_updates true` casks that would otherwise be skipped."
// 45:
// 46:         conflicts "--quiet", "--verbose", "--json"
// 47:         conflicts "--formula", "--cask"
// 48:
// 49:         named_args [:formula, :cask]
// 50:       end
// 51:
// 52:       sig { override.void }
// 53:       def run
// 54:         raise UsageError, "`--minimum-version` requires exactly one formula or cask argument." if
// 55:           minimum_version.present? && args.named.length != 1
// 56:
// 57:         case json_version(args.json)
// 58:         when :v1
// 59:           odie "`brew outdated --json=v1` is no longer supported. Use brew outdated --json=v2 instead."
// 60:         when :v2, :default
// 61:           formulae, casks = if args.formula?
// 62:             [outdated_formulae, []]
// 63:           elsif args.cask?
// 64:             [[], outdated_casks]
// 65:           else
// 66:             outdated_formulae_casks
// 67:           end
// 68:
// 69:           json = {
// 70:             formulae: json_info(formulae),
// 71:             casks:    json_info(casks),
// 72:           }
// 73:           # json v2.8.1 is inconsistent it how it renders empty arrays,
// 74:           # so we use `[]` for consistency:
// 75:           puts JSON.pretty_generate(json).gsub(/\[\n\n\s*\]/, "[]")
// 76:
// 77:           outdated = formulae + casks
// 78:         else
// 79:           outdated = if args.formula?
// 80:             outdated_formulae
// 81:           elsif args.cask?
// 82:             outdated_casks
// 83:           else
// 84:             outdated_formulae_casks.flatten
// 85:           end
// 86:
// 87:           print_outdated(outdated)
// 88:         end
// 89:
// 90:         Homebrew.failed = args.named.present? && outdated.present?
// 91:       end
// 92:
// 93:       sig {
// 94:         params(formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)]).returns(T::Array[T.any(Formula, Cask::Cask)])
// 95:       }
// 96:       def select_outdated(formulae_or_casks)
// 97:         formulae_or_casks.select do |formula_or_cask|
// 98:           if formula_or_cask.is_a?(Formula)
// 99:             if minimum_version.present?
// 100:               formula_outdated_kegs(formula_or_cask).present?
// 101:             else
// 102:               formula_or_cask.outdated?(fetch_head: args.fetch_HEAD?)
// 103:             end
// 104:           else
// 105:             if minimum_version.present?
// 106:               next MinimumVersion.cask_installed_below?(formula_or_cask, T.must(minimum_version))
// 107:             end
// 108:
// 109:             cask_greedy = upgrade_greedy_cask?(args.greedy?, formula_or_cask)
// 110:
// 111:             formula_or_cask.outdated?(greedy:              cask_greedy,
// 112:                                       greedy_latest:       args.greedy_latest?,
// 113:                                       greedy_auto_updates: args.greedy_auto_updates?)
// 114:           end
// 115:         end
// 116:       end
// 117:
// 118:       private
// 119:
// 120:       sig { params(formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)]).void }
// 121:       def print_outdated(formulae_or_casks)
// 122:         formulae_or_casks.each do |formula_or_cask|
// 123:           if formula_or_cask.is_a?(Formula)
// 124:             f = formula_or_cask
// 125:
// 126:             if verbose?
// 127:               outdated_kegs = formula_outdated_kegs(f)
// 128:               latest_formula = f.latest_formula
// 129:
// 130:               current_version = if minimum_version.present?
// 131:                 minimum_version
// 132:               elsif f.alias_changed? && !latest_formula.latest_version_installed?
// 133:                 "#{latest_formula.name} (#{latest_formula.pkg_version})"
// 134:               elsif f.head?
// 135:                 latest_head_version = f.latest_head_pkg_version(fetch_head: args.fetch_HEAD?)
// 136:                 if outdated_kegs.any? { |k| k.version.to_s == latest_head_version.to_s }
// 137:                   # There is a newer HEAD but the version number has not changed.
// 138:                   "latest HEAD"
// 139:                 else
// 140:                   latest_head_version.to_s
// 141:                 end
// 142:               else
// 143:                 latest_formula.pkg_version.to_s
// 144:               end
// 145:
// 146:               outdated_versions = outdated_kegs.group_by { |keg| Formulary.from_keg(keg).full_name }
// 147:                                                .sort_by { |full_name, _kegs| full_name }
// 148:                                                .map do |full_name, kegs|
// 149:                 "#{full_name} (#{kegs.map(&:version).join(", ")})"
// 150:               end.join(", ")
// 151:
// 152:               pinned_version = " [pinned at #{f.pinned_version}]" if f.pinned?
// 153:
// 154:               puts "#{outdated_versions} < #{current_version}#{pinned_version}"
// 155:             else
// 156:               puts f.full_installed_specified_name
// 157:             end
// 158:           else
// 159:             c = formula_or_cask
// 160:
// 161:             if minimum_version.present?
// 162:               if verbose?
// 163:                 pinned_version = " [pinned at #{c.pinned_version}]" if c.pinned?
// 164:
// 165:                 puts "#{c.token} (#{c.installed_version}) < #{minimum_version}#{pinned_version}"
// 166:               else
// 167:                 puts c.token
// 168:               end
// 169:             else
// 170:               puts c.outdated_info(upgrade_greedy_cask?(args.greedy?, formula_or_cask), verbose?,
// 171:                                    false, args.greedy_latest?, args.greedy_auto_updates?)
// 172:             end
// 173:           end
// 174:         end
// 175:       end
// 176:
// 177:       sig {
// 178:         params(
// 179:           formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)],
// 180:         ).returns(T::Array[T::Hash[Symbol, T.untyped]])
// 181:       }
// 182:       def json_info(formulae_or_casks)
// 183:         formulae_or_casks.map do |formula_or_cask|
// 184:           if formula_or_cask.is_a?(Formula)
// 185:             f = formula_or_cask
// 186:
// 187:             outdated_versions = formula_outdated_kegs(f).map(&:version)
// 188:             current_version = if minimum_version.present?
// 189:               minimum_version
// 190:             elsif f.head? && outdated_versions.any? { |v| v.to_s == f.pkg_version.to_s }
// 191:               "HEAD"
// 192:             else
// 193:               f.pkg_version.to_s
// 194:             end
// 195:
// 196:             { name:               f.full_name,
// 197:               installed_versions: outdated_versions.map(&:to_s),
// 198:               current_version:,
// 199:               pinned:             f.pinned?,
// 200:               pinned_version:     f.pinned_version }
// 201:           else
// 202:             c = formula_or_cask
// 203:
// 204:             if minimum_version.present?
// 205:               { name:               c.token,
// 206:                 installed_versions: [T.must(c.installed_version)],
// 207:                 current_version:    T.must(minimum_version),
// 208:                 pinned:             c.pinned?,
// 209:                 pinned_version:     c.pinned_version }
// 210:             else
// 211:               T.cast(
// 212:                 c.outdated_info(upgrade_greedy_cask?(args.greedy?, formula_or_cask),
// 213:                                 verbose?, true, args.greedy_latest?, args.greedy_auto_updates?),
// 214:                 T::Hash[Symbol, T.untyped],
// 215:               )
// 216:             end
// 217:           end
// 218:         end
// 219:       end
// 220:
// 221:       sig { returns(T::Boolean) }
// 222:       def verbose?
// 223:         ($stdout.tty? || Context.current.verbose?) && !Context.current.quiet?
// 224:       end
// 225:
// 226:       sig { params(version: T.nilable(T.any(TrueClass, String))).returns(T.nilable(Symbol)) }
// 227:       def json_version(version)
// 228:         version_hash = {
// 229:           nil  => nil,
// 230:           true => :default,
// 231:           "v1" => :v1,
// 232:           "v2" => :v2,
// 233:         }
// 234:         version_hash.fetch(version) { raise UsageError, "invalid JSON version: #{version}" }
// 235:       end
// 236:
// 237:       sig { returns(T.nilable(String)) }
// 238:       def minimum_version = args.minimum_version || args.min_version
// 239:
// 240:       sig { returns(T::Array[Formula]) }
// 241:       def outdated_formulae
// 242:         T.cast(
// 243:           select_outdated(args.named.to_resolved_formulae.presence || Formula.installed).sort,
// 244:           T::Array[Formula],
// 245:         )
// 246:       end
// 247:
// 248:       sig { returns(T::Array[Cask::Cask]) }
// 249:       def outdated_casks
// 250:         outdated = if args.named.present?
// 251:           select_outdated(args.named.to_casks)
// 252:         else
// 253:           select_outdated(Cask::Caskroom.casks)
// 254:         end
// 255:
// 256:         T.cast(outdated, T::Array[Cask::Cask])
// 257:       end
// 258:
// 259:       sig { returns([T::Array[T.any(Formula, Cask::Cask)], T::Array[T.any(Formula, Cask::Cask)]]) }
// 260:       def outdated_formulae_casks
// 261:         formulae, casks = args.named.to_resolved_formulae_to_casks
// 262:
// 263:         if formulae.blank? && casks.blank?
// 264:           formulae = Formula.installed
// 265:           casks = Cask::Caskroom.casks
// 266:         end
// 267:
// 268:         [select_outdated(formulae).sort, select_outdated(casks)]
// 269:       end
// 270:
// 271:       sig { params(formula: Formula).returns(T::Array[Keg]) }
// 272:       def formula_outdated_kegs(formula)
// 273:         MinimumVersion.formula_outdated_kegs(formula, minimum_version, fetch_head: args.fetch_HEAD?)
// 274:       end
// 275:
// 276:       sig { params(greedy: T::Boolean, cask: Cask::Cask).returns(T::Boolean) }
// 277:       def upgrade_greedy_cask?(greedy, cask)
// 278:         return true if greedy
// 279:
// 280:         @greedy_list ||= T.let(
// 281:           begin
// 282:             upgrade_greedy_casks = Homebrew::EnvConfig.upgrade_greedy_casks.presence
// 283:             upgrade_greedy_casks&.split || []
// 284:           end, T.nilable(T::Array[String])
// 285:         )
// 286:
// 287:         @greedy_list.include?(cask.token)
// 288:       end
// 289:     end
// 290:   end
// 291: end
