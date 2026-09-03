module update_report

import brew_runtime
import os

// Translated from Homebrew/brew `cmd/update_report/reporter.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ReporterRename {
pub:
	old_name string
	new_name string
}

pub struct ReporterReport {
pub mut:
	added_formulae    []string
	added_casks       []string
	deleted_formulae  []string
	deleted_casks     []string
	modified_formulae []string
	modified_casks    []string
	renamed_formulae  []ReporterRename
	renamed_casks     []ReporterRename
	tap_migrations    []string
}

pub struct ReporterTap {
pub:
	name                  string
	path                  string
	repository_var_suffix string
	formula_directory     string = 'Formula'
	core_tap              bool
	core_cask_tap         bool
	installed             bool = true
	trusted               bool
	official              bool
	formula_renames       map[string]string
	cask_renames          map[string]string
	tap_migrations        map[string]string
	cask_tokens           []string
}

pub struct Reporter {
pub mut:
	tap                  ReporterTap
	initial_revision     string
	current_revision     string
	api_names_txt        string
	api_names_before_txt string
	api_dir_prefix       string
	diff_output          string
	cached_diff          string
	has_cached_diff      bool
	cached_report        ReporterReport
	has_cached_report    bool
}

pub struct ReporterMigrationPackage {
pub:
	name             string
	installed        bool
	installed_tap    string
	oldname_racks    map[string]bool
	oldname_nonempty map[string]bool
	needs_migration  bool
	oldnames         []string
}

pub struct ReporterMigrationContext {
pub:
	formulae           []ReporterMigrationPackage
	casks              []string
	installed_casks    []string
	taps               map[string]ReporterTap
	caskroom_available bool
	developer          bool
}

pub struct ReporterMigrationResult {
pub mut:
	actions           []string
	warnings          []string
	installed_taps    []string
	updated_formulae  []string
	migrated_casks    []string
	migrated_formulae []string
}

pub struct ReporterTrustResult {
pub:
	allowed       bool
	installed_tap bool
	warning       string
}

fn reporter_name_from_full_name(full_name string) string {
	parts := full_name.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { full_name }
}

fn reporter_tap_from_full_name(full_name string) ?string {
	parts := full_name.split_nth('/', 3)
	if parts.len != 3 {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

fn reporter_pair_in(values []ReporterRename, value ReporterRename) bool {
	return values.any(it.old_name == value.old_name && it.new_name == value.new_name)
}

fn reporter_unique_strings(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	return result
}

fn reporter_without(values []string, removed []string) []string {
	return values.filter(it !in removed)
}

fn reporter_basename_without_rb(path string) string {
	base := os.base(path)
	return if base.ends_with('.rb') { base[..base.len - 3] } else { base }
}

fn (tap ReporterTap) file_to_name(path string) string {
	base := reporter_basename_without_rb(path)
	if tap.core_tap || tap.core_cask_tap {
		return base
	}
	return '${tap.name}/${base}'
}

fn (tap ReporterTap) cask_file(path string) bool {
	return path.starts_with('Casks/') && path.ends_with('.rb') && path.len > 'Casks/.rb'.len
}

fn (tap ReporterTap) formula_file(path string, status string) bool {
	if !path.ends_with('.rb') {
		return false
	}
	prefix := tap.formula_directory.trim_string_right('/')
	if prefix == '' || prefix == '.' {
		return !path.contains('/')
	}
	if path.starts_with('${prefix}/') && path.len > prefix.len + 4 {
		return true
	}
	// The Ruby source explicitly recognises deleted legacy HomebrewFormula files.
	return status == 'D' && (path.starts_with('Formula/') || path.starts_with('HomebrewFormula/'))
}

pub fn new_reporter(tap ReporterTap, environment map[string]string, api_names_txt string,
	api_names_before_txt string, api_dir_prefix string) !Reporter {
	if reporter_installed_from_api(api_names_txt, api_names_before_txt, api_dir_prefix) {
		return Reporter{
			tap: tap
			api_names_txt: api_names_txt
			api_names_before_txt: api_names_before_txt
			api_dir_prefix: api_dir_prefix
		}
	}
	initial_var := 'HOMEBREW_UPDATE_BEFORE${tap.repository_var_suffix}'
	initial := environment[initial_var] or { '' }
	if initial == '' {
		return error('${initial_var} is unset!')
	}
	current_var := 'HOMEBREW_UPDATE_AFTER${tap.repository_var_suffix}'
	current := environment[current_var] or { '' }
	if current == '' {
		return error('${current_var} is unset!')
	}
	return Reporter{
		tap: tap
		initial_revision: initial
		current_revision: current
	}
}

pub fn reporter_installed_from_api(api_names_txt string, api_names_before_txt string,
	api_dir_prefix string) bool {
	return api_names_txt != '' && api_names_before_txt != '' && api_dir_prefix != ''
}

pub fn (reporter Reporter) installed_from_api() bool {
	return reporter_installed_from_api(reporter.api_names_txt, reporter.api_names_before_txt, reporter.api_dir_prefix)
}

pub fn (reporter Reporter) updated() bool {
	return if reporter.installed_from_api() {
		reporter.diff().trim_space() != ''
	} else {
		reporter.initial_revision != reporter.current_revision
	}
}

pub fn reporter_api_diff(diff_output string, api_dir_prefix string) string {
	mut counts := map[string]int{}
	mut order := []string{}
	directory := os.base(api_dir_prefix.trim_string_right('/'))
	for raw_line in diff_output.split_into_lines() {
		if raw_line.starts_with('--- ') || raw_line.starts_with('+++ ') || raw_line == '' {
			continue
		}
		first := raw_line[0]
		if first != `+` && first != `-` {
			continue
		}
		name := raw_line[1..].trim_string_right('\r')
		file := '${directory}/${name}.rb'
		if file !in counts {
			order << file
		}
		counts[file] = (counts[file] or { 0 }) + if first == `+` { 1 } else { -1 }
	}
	mut lines := []string{}
	for file in order {
		count := counts[file]
		if count > 0 {
			lines << 'A ${file}'
		} else if count < 0 {
			lines << 'D ${file}'
		}
	}
	return lines.join('\n')
}

pub fn (reporter Reporter) diff() string {
	if reporter.has_cached_diff {
		return reporter.cached_diff
	}
	if reporter.installed_from_api() {
		return reporter_api_diff(reporter.diff_output, reporter.api_dir_prefix)
	}
	return reporter.diff_output
}

pub fn (mut reporter Reporter) report(auto_update bool) ReporterReport {
	if reporter.has_cached_report {
		return reporter.cached_report
	}
	mut report := ReporterReport{}
	if !reporter.updated() {
		reporter.cached_report = report
		reporter.has_cached_report = true
		return report
	}
	for raw_line in reporter.diff().split_into_lines() {
		fields := raw_line.fields()
		if fields.len < 2 {
			continue
		}
		status := fields[0]
		paths := fields[1..]
		src := paths[0]
		dst := paths[paths.len - 1]
		if !dst.ends_with('.rb') {
			continue
		}
		if paths.any(reporter.tap.cask_file(it)) {
			match true {
				status == 'A' { report.added_casks << reporter.tap.file_to_name(src) }
				status == 'D' { report.deleted_casks << reporter.tap.file_to_name(src) }
				status == 'M' { report.modified_casks << reporter.tap.file_to_name(src) }
				status.starts_with('R') {
					src_name := reporter.tap.file_to_name(src)
					dst_name := reporter.tap.file_to_name(dst)
					if src_name != dst_name {
						report.deleted_casks << src_name
						report.added_casks << dst_name
					}
				}
				else {}
			}
		}
		if !paths.any(reporter.tap.formula_file(it, status)) {
			continue
		}
		if status == 'A' || status == 'D' {
			full_name := reporter.tap.file_to_name(src)
			name := reporter_name_from_full_name(full_name)
			migration := reporter.tap.tap_migrations[name] or { '' }
			if migration == '' {
				if status == 'A' {
					report.added_formulae << full_name
				} else {
					report.deleted_formulae << full_name
				}
			} else if status == 'D' {
				report.tap_migrations << full_name
			}
		} else if status == 'M' {
			report.modified_formulae << reporter.tap.file_to_name(src)
		} else if status.starts_with('R') {
			src_name := reporter.tap.file_to_name(src)
			dst_name := reporter.tap.file_to_name(dst)
			if src_name != dst_name {
				report.deleted_formulae << src_name
				report.added_formulae << dst_name
			}
		}
	}
	mut renamed_casks := []ReporterRename{}
	for old_full_name in report.deleted_casks {
		old_name := reporter_name_from_full_name(old_full_name)
		new_name := reporter.tap.cask_renames[old_name] or { continue }
		new_full_name := if reporter.tap.core_cask_tap {
			new_name
		} else {
			'${reporter.tap.name}/${new_name}'
		}
		pair := ReporterRename{ old_name: old_full_name, new_name: new_full_name }
		if new_full_name in report.added_casks && !reporter_pair_in(renamed_casks, pair) {
			renamed_casks << pair
		}
	}
	for new_full_name in report.added_casks {
		new_name := reporter_name_from_full_name(new_full_name)
		mut old_name := ''
		for candidate, renamed in reporter.tap.cask_renames {
			if renamed == new_name {
				old_name = candidate
				break
			}
		}
		if old_name == '' {
			continue
		}
		old_full_name := if reporter.tap.core_cask_tap {
			old_name
		} else {
			'${reporter.tap.name}/${old_name}'
		}
		pair := ReporterRename{ old_name: old_full_name, new_name: new_full_name }
		if !reporter_pair_in(renamed_casks, pair) {
			renamed_casks << pair
		}
	}
	if renamed_casks.len > 0 {
		report.added_casks = reporter_without(report.added_casks, renamed_casks.map(it.new_name))
		report.deleted_casks = reporter_without(report.deleted_casks, renamed_casks.map(it.old_name))
		report.renamed_casks = renamed_casks
	}
	mut renamed_formulae := []ReporterRename{}
	for old_full_name in report.deleted_formulae {
		old_name := reporter_name_from_full_name(old_full_name)
		new_name := reporter.tap.formula_renames[old_name] or { continue }
		new_full_name := if reporter.tap.core_tap {
			new_name
		} else {
			'${reporter.tap.name}/${new_name}'
		}
		pair := ReporterRename{ old_name: old_full_name, new_name: new_full_name }
		if new_full_name in report.added_formulae && !reporter_pair_in(renamed_formulae, pair) {
			renamed_formulae << pair
		}
	}
	for new_full_name in report.added_formulae {
		new_name := reporter_name_from_full_name(new_full_name)
		mut old_name := ''
		for candidate, renamed in reporter.tap.formula_renames {
			if renamed == new_name {
				old_name = candidate
				break
			}
		}
		if old_name == '' {
			continue
		}
		old_full_name := if reporter.tap.core_tap {
			old_name
		} else {
			'${reporter.tap.name}/${old_name}'
		}
		pair := ReporterRename{ old_name: old_full_name, new_name: new_full_name }
		if !reporter_pair_in(renamed_formulae, pair) {
			renamed_formulae << pair
		}
	}
	if renamed_formulae.len > 0 {
		report.added_formulae = reporter_without(report.added_formulae, renamed_formulae.map(it.new_name))
		report.deleted_formulae = reporter_without(report.deleted_formulae, renamed_formulae.map(it.old_name))
		report.renamed_formulae = renamed_formulae
	}
	formula_overlap := report.added_formulae.filter(it in report.deleted_formulae)
	cask_overlap := report.added_casks.filter(it in report.deleted_casks)
	report.added_formulae = reporter_without(report.added_formulae, formula_overlap)
	report.deleted_formulae = reporter_without(report.deleted_formulae, formula_overlap)
	report.added_casks = reporter_without(report.added_casks, cask_overlap)
	report.deleted_casks = reporter_without(report.deleted_casks, cask_overlap)
	reporter.cached_report = report
	reporter.has_cached_report = true
	return report
}

pub fn reporter_ensure_trusted_tap_installed(name string, new_name string,
	new_tap ReporterTap) ReporterTrustResult {
	if new_tap.installed {
		return ReporterTrustResult{ allowed: true }
	}
	if !new_tap.trusted && !new_tap.official {
		new_bare_name := reporter_name_from_full_name(new_name)
		new_full_name := '${new_tap.name}/${new_bare_name}'
		complete_command := if new_bare_name == name {
			'brew reinstall ${name}'
		} else {
			'brew migrate ${name}'
		}
		return ReporterTrustResult{
			warning: 'Not automatically tapping ${new_tap.name} to migrate ${name} as it is not a\ntrusted tap. To complete the migration yourself, run:\n  brew tap ${new_tap.name}\n  brew trust ${new_full_name}\n  ${complete_command}'
		}
	}
	return ReporterTrustResult{ allowed: true, installed_tap: true }
}

pub fn reporter_migrate_tap_migrations(report ReporterReport, tap ReporterTap,
	context ReporterMigrationContext) ReporterMigrationResult {
	mut result := ReporterMigrationResult{}
	mut migration_names := report.deleted_formulae.clone()
	migration_names << report.deleted_casks
	migration_names << report.tap_migrations
	for full_name in migration_names {
		name := reporter_name_from_full_name(full_name)
		migration_target := tap.tap_migrations[name] or { continue }
		mut new_tap_name := ''
		mut new_name := ''
		mut new_full_name := ''
		if migrated_tap := reporter_tap_from_full_name(migration_target) {
			new_name = reporter_name_from_full_name(migration_target)
			new_tap_name = migrated_tap
			new_full_name = migration_target
		} else if migration_target.contains('/') {
			new_tap_name = migration_target
			new_name = name
			new_full_name = '${new_tap_name}/${name}'
		} else {
			new_tap_name = tap.name
			new_name = migration_target
			new_full_name = '${new_tap_name}/${migration_target}'
		}
		new_tap := context.taps[new_tap_name] or { ReporterTap{ name: new_tap_name } }
		if full_name in report.deleted_casks {
			if name !in context.installed_casks {
				continue
			}
			trust := reporter_ensure_trusted_tap_installed(name, new_name, new_tap)
			if !trust.allowed {
				result.warnings << trust.warning
				continue
			}
			if trust.installed_tap {
				result.installed_taps << new_tap_name
			}
			result.actions << '${name} has been moved to Homebrew.'
			if !context.formulae.any(it.name == reporter_name_from_full_name(new_name) && it.installed) {
				result.actions << 'brew install --overwrite ${new_full_name}'
			}
			continue
		}
		package := context.formulae.filter(it.name == name && it.installed)
		if package.len == 0 || package[0].installed_tap != tap.name {
			continue
		}
		is_cask := new_tap.core_cask_tap || new_full_name in new_tap.cask_tokens || new_name in new_tap.cask_tokens
		if is_cask {
			migration_message := if new_tap.name == tap.name {
				'${full_name} has been migrated from a formula to a cask.'
			} else {
				'${name} has been moved to ${new_tap_name}.'
			}
			result.actions << migration_message
			if new_tap.installed && context.caskroom_available {
				result.actions << ['brew unlink ${name}', 'brew cleanup',
					'brew install --cask ${new_full_name}']
			} else {
				result.actions << ['brew uninstall --formula --force ${name}',
					'brew tap ${new_tap_name}', 'brew install --cask ${new_full_name}']
			}
			result.migrated_casks << new_full_name
		} else {
			trust := reporter_ensure_trusted_tap_installed(name, new_name, new_tap)
			if !trust.allowed {
				result.warnings << trust.warning
				continue
			}
			if trust.installed_tap {
				result.installed_taps << new_tap_name
			}
			result.updated_formulae << name
		}
	}
	return ReporterMigrationResult{
		...result
		installed_taps: reporter_unique_strings(result.installed_taps)
		updated_formulae: reporter_unique_strings(result.updated_formulae)
		migrated_casks: reporter_unique_strings(result.migrated_casks)
	}
}

pub fn reporter_migrate_cask_renames(casks []string) []string {
	return casks.clone()
}

pub fn reporter_migrate_formula_renames(formulae []ReporterMigrationPackage) []string {
	mut migrated := []string{}
	for formula in formulae {
		if !formula.installed || !formula.needs_migration {
			continue
		}
		mut oldnames := []string{}
		for oldname in formula.oldnames {
			if !(formula.oldname_racks[oldname] or { false }) {
				continue
			}
			if !(formula.oldname_nonempty[oldname] or { false }) {
				continue
			}
			oldnames << oldname
		}
		if oldnames.len > 0 {
			migrated << formula.name
		}
	}
	return migrated
}

fn reporter_report_to_value(report ReporterReport) brew_runtime.Value {
	renames := report.renamed_formulae.map(brew_runtime.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
		'old_name': it.old_name
		'new_name': it.new_name
	}))
	cask_renames := report.renamed_casks.map(brew_runtime.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
		'old_name': it.old_name
		'new_name': it.new_name
	}))
	return brew_runtime.map_value({
		'A':  brew_runtime.string_array_value(report.added_formulae)
		'AC': brew_runtime.string_array_value(report.added_casks)
		'D':  brew_runtime.string_array_value(report.deleted_formulae)
		'DC': brew_runtime.string_array_value(report.deleted_casks)
		'M':  brew_runtime.string_array_value(report.modified_formulae)
		'MC': brew_runtime.string_array_value(report.modified_casks)
		'R':  brew_runtime.array_value(renames)
		'RC': brew_runtime.array_value(cask_renames)
		'T':  brew_runtime.string_array_value(report.tap_migrations)
	})
}

fn reporter_renames_from_value(value brew_runtime.Value) []ReporterRename {
	mut renames := []ReporterRename{}
	for entry in value.array_data {
		old_name := entry.attributes['old_name'] or { '' }
		new_name := entry.attributes['new_name'] or { '' }
		if old_name != '' || new_name != '' {
			renames << ReporterRename{ old_name: old_name, new_name: new_name }
		}
	}
	return renames
}

fn reporter_report_from_value(value brew_runtime.Value) ReporterReport {
	return ReporterReport{
		added_formulae: (value.map_data['A'] or { brew_runtime.string_array_value([]) }).string_array_data
		added_casks: (value.map_data['AC'] or { brew_runtime.string_array_value([]) }).string_array_data
		deleted_formulae: (value.map_data['D'] or { brew_runtime.string_array_value([]) }).string_array_data
		deleted_casks: (value.map_data['DC'] or { brew_runtime.string_array_value([]) }).string_array_data
		modified_formulae: (value.map_data['M'] or { brew_runtime.string_array_value([]) }).string_array_data
		modified_casks: (value.map_data['MC'] or { brew_runtime.string_array_value([]) }).string_array_data
		renamed_formulae: reporter_renames_from_value(value.map_data['R'] or { brew_runtime.array_value([]) })
		renamed_casks: reporter_renames_from_value(value.map_data['RC'] or { brew_runtime.array_value([]) })
		tap_migrations: (value.map_data['T'] or { brew_runtime.string_array_value([]) }).string_array_data
	}
}

fn reporter_migration_result_to_value(result ReporterMigrationResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'actions':           brew_runtime.string_array_value(result.actions)
		'warnings':          brew_runtime.string_array_value(result.warnings)
		'installed_taps':    brew_runtime.string_array_value(result.installed_taps)
		'updated_formulae':  brew_runtime.string_array_value(result.updated_formulae)
		'migrated_casks':    brew_runtime.string_array_value(result.migrated_casks)
		'migrated_formulae': brew_runtime.string_array_value(result.migrated_formulae)
	})
}

fn reporter_migration_packages_from_value(value brew_runtime.Value) []ReporterMigrationPackage {
	values := if value.array_data.len > 0 { value.array_data } else { []brew_runtime.Value{} }
	mut packages := []ReporterMigrationPackage{}
	for item in values {
		mut racks := map[string]bool{}
		mut nonempty := map[string]bool{}
		oldnames := (item.map_data['oldnames'] or { brew_runtime.string_array_value([]) }).string_array_data
		for oldname in oldnames {
			racks[oldname] = (item.attributes['rack_${oldname}'] or { 'false' }) == 'true'
			nonempty[oldname] = (item.attributes['nonempty_${oldname}'] or { 'false' }) == 'true'
		}
		packages << ReporterMigrationPackage{
			name: item.attributes['name'] or { item.repr }
			installed: (item.attributes['installed'] or { 'false' }) == 'true'
			installed_tap: item.attributes['installed_tap'] or { '' }
			oldname_racks: racks
			oldname_nonempty: nonempty
			needs_migration: (item.attributes['needs_migration'] or { 'false' }) == 'true'
			oldnames: oldnames
		}
	}
	return packages
}

pub fn reporter_to_value(reporter Reporter) brew_runtime.Value {
	return brew_runtime.structured_value('Reporter', reporter.tap.name, {
		'tap_name':              reporter.tap.name
		'tap_path':              reporter.tap.path
		'repository_var_suffix': reporter.tap.repository_var_suffix
		'initial_revision':      reporter.initial_revision
		'current_revision':      reporter.current_revision
		'api_names_txt':         reporter.api_names_txt
		'api_names_before_txt':  reporter.api_names_before_txt
		'api_dir_prefix':        reporter.api_dir_prefix
		'diff_output':           reporter.diff_output
		'core_tap':              reporter.tap.core_tap.str()
		'core_cask_tap':         reporter.tap.core_cask_tap.str()
	})
}

fn reporter_from_value(value brew_runtime.Value) Reporter {
	return Reporter{
		tap: ReporterTap{
			name: value.attributes['tap_name'] or { value.repr }
			path: value.attributes['tap_path'] or { '' }
			repository_var_suffix: value.attributes['repository_var_suffix'] or { '' }
			core_tap: (value.attributes['core_tap'] or { 'false' }) == 'true'
			core_cask_tap: (value.attributes['core_cask_tap'] or { 'false' }) == 'true'
		}
		initial_revision: value.attributes['initial_revision'] or { '' }
		current_revision: value.attributes['current_revision'] or { '' }
		api_names_txt: value.attributes['api_names_txt'] or { '' }
		api_names_before_txt: value.attributes['api_names_before_txt'] or { '' }
		api_dir_prefix: value.attributes['api_dir_prefix'] or { '' }
		diff_output: value.attributes['diff_output'] or { '' }
	}
}

// Ruby method `initialize(var_name)` at line 25.
pub fn ruby_reporter_l25_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.object_value('Reporter::ReporterRevisionUnsetError', '${name} is unset!')
}

// Ruby method `initialize(tap, api_names_txt: nil, api_names_before_txt: nil, api_dir_prefix: nil)` at line 34.
pub fn ruby_reporter_l34_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'tap is required')
	}
	value := args[0]
	tap := ReporterTap{
		name: value.attributes['name'] or { value.repr }
		path: value.attributes['path'] or { '' }
		repository_var_suffix: value.attributes['repository_var_suffix'] or { '' }
		core_tap: (value.attributes['core_tap'] or { 'false' }) == 'true'
		core_cask_tap: (value.attributes['core_cask_tap'] or { 'false' }) == 'true'
	}
	mut environment := map[string]string{}
	if args.len > 1 {
		environment = args[1].attributes.clone()
	}
	reporter := new_reporter(tap, environment, value.attributes['api_names_txt'] or { '' }, value.attributes['api_names_before_txt'] or { '' }, value.attributes['api_dir_prefix'] or { '' }) or {
		return brew_runtime.object_value('Reporter::ReporterRevisionUnsetError', err.msg())
	}
	return reporter_to_value(reporter)
}

// Ruby method `report(auto_update: false)` at line 56.
pub fn ruby_reporter_l56_d3_report(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return reporter_report_to_value(ReporterReport{})
	}
	mut reporter := reporter_from_value(args[0])
	return reporter_report_to_value(reporter.report(if args.len > 1 {
		args[1].bool_data
	} else {
		false
	}))
}

// Ruby method `updated?` at line 211.
pub fn ruby_reporter_l211_d4_updated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && reporter_from_value(args[0]).updated())
}

// Ruby method `migrate_tap_migration` at line 220.
pub fn ruby_reporter_l220_d5_migrate_tap_migration(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return reporter_migration_result_to_value(reporter_migrate_tap_migrations(ReporterReport{}, ReporterTap{}, ReporterMigrationContext{}))
	}
	mut reporter := reporter_from_value(args[0])
	report := if report_value := args[0].map_data['report'] {
		reporter_report_from_value(report_value)
	} else {
		reporter.report(false)
	}
	packages := if args.len > 1 {
		reporter_migration_packages_from_value(args[1])
	} else {
		[]ReporterMigrationPackage{}
	}
	result := reporter_migrate_tap_migrations(report, reporter.tap, ReporterMigrationContext{
		formulae: packages
		installed_casks: if args.len > 2 { args[2].string_array_data } else { []string{} }
		caskroom_available: args.len > 3 && args[3].bool_data
	})
	return reporter_migration_result_to_value(result)
}

// Ruby method `migrate_cask_rename` at line 313.
pub fn ruby_reporter_l313_d6_migrate_cask_rename(args ...brew_runtime.Value) brew_runtime.Value {
	values := if args.len > 0 { args[0].string_array_data } else { []string{} }
	return brew_runtime.string_array_value(reporter_migrate_cask_renames(values))
}

// Ruby method `migrate_formula_rename(force:, verbose:)` at line 320.
pub fn ruby_reporter_l320_d7_migrate_formula_rename(args ...brew_runtime.Value) brew_runtime.Value {
	packages := if args.len > 0 {
		reporter_migration_packages_from_value(args[0])
	} else {
		[]ReporterMigrationPackage{}
	}
	return brew_runtime.string_array_value(reporter_migrate_formula_renames(packages))
}

// Ruby method `ensure_trusted_tap_installed!(name, new_name, new_tap)` at line 342.
pub fn ruby_reporter_l342_d8_ensure_trusted_tap_installed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	tap_value := args[2]
	result := reporter_ensure_trusted_tap_installed(args[0].as_string(), args[1].as_string(), ReporterTap{
		name: tap_value.attributes['name'] or { tap_value.repr }
		installed: (tap_value.attributes['installed'] or { 'false' }) == 'true'
		trusted: (tap_value.attributes['trusted'] or { 'false' }) == 'true'
		official: (tap_value.attributes['official'] or { 'false' }) == 'true'
	})
	return brew_runtime.structured_value('TrustResult', result.warning, {
		'allowed':       result.allowed.str()
		'installed_tap': result.installed_tap.str()
		'warning':       result.warning
	})
}

// Ruby method `diff` at line 370.
pub fn ruby_reporter_l370_d9_diff(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).diff()
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :tap` at line 414.
pub fn ruby_reporter_l414_d10_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	reporter := reporter_from_value(args[0])
	return brew_runtime.structured_value('Tap', reporter.tap.name, {
		'name': reporter.tap.name
		'path': reporter.tap.path
	})
}

// Ruby attr_reader `attr_reader :initial_revision` at line 417.
pub fn ruby_reporter_l417_d11_initial_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).initial_revision
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :current_revision` at line 420.
pub fn ruby_reporter_l420_d12_current_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).current_revision
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :api_names_txt` at line 423.
pub fn ruby_reporter_l423_d13_api_names_txt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).api_names_txt
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :api_names_before_txt` at line 426.
pub fn ruby_reporter_l426_d14_api_names_before_txt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).api_names_before_txt
	} else {
		''
	})
}

// Ruby attr_reader `attr_reader :api_dir_prefix` at line 429.
pub fn ruby_reporter_l429_d15_api_dir_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 {
		reporter_from_value(args[0]).api_dir_prefix
	} else {
		''
	})
}

// Ruby method `installed_from_api?(api_names_txt = @api_names_txt, api_names_before_txt = @api_names_before_txt,` at line 435.
pub fn ruby_reporter_l435_d16_installed_from_api(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len >= 3 {
		return brew_runtime.bool_value(reporter_installed_from_api(args[0].as_string(), args[1].as_string(), args[2].as_string()))
	}
	return brew_runtime.bool_value(args.len > 0 && reporter_from_value(args[0]).installed_from_api())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "trust"
// 5:
// 6: class Reporter
// 7:   include Utils::Output::Mixin
// 8:
// 9:   Report = T.type_alias do
// 10:     {
// 11:       A:  T::Array[String],
// 12:       AC: T::Array[String],
// 13:       D:  T::Array[String],
// 14:       DC: T::Array[String],
// 15:       M:  T::Array[String],
// 16:       MC: T::Array[String],
// 17:       R:  T::Array[[String, String]],
// 18:       RC: T::Array[[String, String]],
// 19:       T:  T::Array[String],
// 20:     }
// 21:   end
// 22:
// 23:   class ReporterRevisionUnsetError < RuntimeError
// 24:     sig { params(var_name: String).void }
// 25:     def initialize(var_name)
// 26:       super "#{var_name} is unset!"
// 27:     end
// 28:   end
// 29:
// 30:   sig {
// 31:     params(tap: Tap, api_names_txt: T.nilable(Pathname), api_names_before_txt: T.nilable(Pathname),
// 32:            api_dir_prefix: T.nilable(Pathname)).void
// 33:   }
// 34:   def initialize(tap, api_names_txt: nil, api_names_before_txt: nil, api_dir_prefix: nil)
// 35:     @tap = tap
// 36:
// 37:     # This is slightly involved/weird but all the #report logic is shared so it's worth it.
// 38:     if installed_from_api?(api_names_txt, api_names_before_txt, api_dir_prefix)
// 39:       @api_names_txt = T.let(api_names_txt, T.nilable(Pathname))
// 40:       @api_names_before_txt = T.let(api_names_before_txt, T.nilable(Pathname))
// 41:       @api_dir_prefix = T.let(api_dir_prefix, T.nilable(Pathname))
// 42:     else
// 43:       initial_revision_var = "HOMEBREW_UPDATE_BEFORE#{tap.repository_var_suffix}"
// 44:       @initial_revision = T.let(ENV[initial_revision_var].to_s, String)
// 45:       raise ReporterRevisionUnsetError, initial_revision_var if @initial_revision.empty?
// 46:
// 47:       current_revision_var = "HOMEBREW_UPDATE_AFTER#{tap.repository_var_suffix}"
// 48:       @current_revision = T.let(ENV[current_revision_var].to_s, String)
// 49:       raise ReporterRevisionUnsetError, current_revision_var if @current_revision.empty?
// 50:     end
// 51:
// 52:     @report = T.let(nil, T.nilable(Report))
// 53:   end
// 54:
// 55:   sig { params(auto_update: T::Boolean).returns(Report) }
// 56:   def report(auto_update: false)
// 57:     return @report if @report
// 58:
// 59:     @report = {
// 60:       A: [], AC: [], D: [], DC: [], M: [], MC: [], R: T.let([], T::Array[[String, String]]),
// 61:       RC: T.let([], T::Array[[String, String]]), T: []
// 62:     }
// 63:     return @report unless updated?
// 64:
// 65:     diff.each_line do |line|
// 66:       status, *paths = line.split
// 67:       src = Pathname.new paths.first
// 68:       dst = Pathname.new paths.last
// 69:
// 70:       next if dst.extname != ".rb"
// 71:
// 72:       if paths.any? { |p| tap.cask_file?(p) }
// 73:         case status
// 74:         when "A"
// 75:           # Have a dedicated report array for new casks.
// 76:           @report[:AC] << tap.formula_file_to_name(src)
// 77:         when "D"
// 78:           # Have a dedicated report array for deleted casks.
// 79:           @report[:DC] << tap.formula_file_to_name(src)
// 80:         when "M"
// 81:           # Report updated casks
// 82:           @report[:MC] << tap.formula_file_to_name(src)
// 83:         when /^R\d{0,3}/
// 84:           src_full_name = tap.formula_file_to_name(src)
// 85:           dst_full_name = tap.formula_file_to_name(dst)
// 86:           # Don't report formulae that are moved within a tap but not renamed
// 87:           next if src_full_name == dst_full_name
// 88:
// 89:           @report[:DC] << src_full_name
// 90:           @report[:AC] << dst_full_name
// 91:         end
// 92:       end
// 93:
// 94:       next unless paths.any? do |p|
// 95:         tap.formula_file?(p) ||
// 96:         # Need to check for case where Formula directory was deleted
// 97:         (status == "D" && File.fnmatch?("{Homebrew,}Formula/**/*.rb", p, File::FNM_EXTGLOB | File::FNM_PATHNAME))
// 98:       end
// 99:
// 100:       case status
// 101:       when "A", "D"
// 102:         full_name = tap.formula_file_to_name(src)
// 103:         name = Utils.name_from_full_name(full_name)
// 104:         new_tap = tap.tap_migrations[name]
// 105:         if new_tap.blank?
// 106:           @report[T.must(status).to_sym] << full_name
// 107:         elsif status == "D"
// 108:           # Retain deleted formulae for tap migrations separately to avoid reporting as deleted
// 109:           @report[:T] << full_name
// 110:         end
// 111:       when "M"
// 112:         name = tap.formula_file_to_name(src)
// 113:
// 114:         @report[:M] << name
// 115:       when /^R\d{0,3}/
// 116:         src_full_name = tap.formula_file_to_name(src)
// 117:         dst_full_name = tap.formula_file_to_name(dst)
// 118:         # Don't report formulae that are moved within a tap but not renamed
// 119:         next if src_full_name == dst_full_name
// 120:
// 121:         @report[:D] << src_full_name
// 122:         @report[:A] << dst_full_name
// 123:       end
// 124:     end
// 125:
// 126:     renamed_casks = Set.new
// 127:     @report[:DC].each do |old_full_name|
// 128:       old_name = Utils.name_from_full_name(old_full_name)
// 129:       new_name = tap.cask_renames[old_name]
// 130:       next unless new_name
// 131:
// 132:       new_full_name = if tap.core_cask_tap?
// 133:         new_name
// 134:       else
// 135:         "#{tap}/#{new_name}"
// 136:       end
// 137:
// 138:       renamed_casks << [old_full_name, new_full_name] if @report[:AC].include?(new_full_name)
// 139:     end
// 140:
// 141:     @report[:AC].each do |new_full_name|
// 142:       new_name = Utils.name_from_full_name(new_full_name)
// 143:       old_name = tap.cask_renames.key(new_name)
// 144:       next unless old_name
// 145:
// 146:       old_full_name = if tap.core_cask_tap?
// 147:         old_name
// 148:       else
// 149:         "#{tap}/#{old_name}"
// 150:       end
// 151:
// 152:       renamed_casks << [old_full_name, new_full_name]
// 153:     end
// 154:
// 155:     if renamed_casks.any?
// 156:       @report[:AC] -= renamed_casks.map(&:last)
// 157:       @report[:DC] -= renamed_casks.map(&:first)
// 158:       @report[:RC] = renamed_casks.to_a
// 159:     end
// 160:
// 161:     renamed_formulae = Set.new
// 162:     @report[:D].each do |old_full_name|
// 163:       old_name = Utils.name_from_full_name(old_full_name)
// 164:       new_name = tap.formula_renames[old_name]
// 165:       next unless new_name
// 166:
// 167:       new_full_name = if tap.core_tap?
// 168:         new_name
// 169:       else
// 170:         "#{tap}/#{new_name}"
// 171:       end
// 172:
// 173:       renamed_formulae << [old_full_name, new_full_name] if @report[:A].include? new_full_name
// 174:     end
// 175:
// 176:     @report[:A].each do |new_full_name|
// 177:       new_name = Utils.name_from_full_name(new_full_name)
// 178:       old_name = tap.formula_renames.key(new_name)
// 179:       next unless old_name
// 180:
// 181:       old_full_name = if tap.core_tap?
// 182:         old_name
// 183:       else
// 184:         "#{tap}/#{old_name}"
// 185:       end
// 186:
// 187:       renamed_formulae << [old_full_name, new_full_name]
// 188:     end
// 189:
// 190:     if renamed_formulae.any?
// 191:       @report[:A] -= renamed_formulae.map(&:last)
// 192:       @report[:D] -= renamed_formulae.map(&:first)
// 193:       @report[:R] = renamed_formulae.to_a
// 194:     end
// 195:
// 196:     # If any formulae/casks are marked as added and deleted, remove them from
// 197:     # the report as we've not detected things correctly.
// 198:     if (added_and_deleted_formulae = (@report[:A] & @report[:D]).presence)
// 199:       @report[:A] -= added_and_deleted_formulae
// 200:       @report[:D] -= added_and_deleted_formulae
// 201:     end
// 202:     if (added_and_deleted_casks = (@report[:AC] & @report[:DC]).presence)
// 203:       @report[:AC] -= added_and_deleted_casks
// 204:       @report[:DC] -= added_and_deleted_casks
// 205:     end
// 206:
// 207:     @report
// 208:   end
// 209:
// 210:   sig { returns(T::Boolean) }
// 211:   def updated?
// 212:     if installed_from_api?
// 213:       diff.present?
// 214:     else
// 215:       initial_revision != current_revision
// 216:     end
// 217:   end
// 218:
// 219:   sig { void }
// 220:   def migrate_tap_migration
// 221:     [report[:D], report[:DC], report[:T]].flatten.each do |full_name|
// 222:       name = Utils.name_from_full_name(full_name)
// 223:       migration_target = tap.tap_migrations[name]
// 224:       next if migration_target.nil? # skip if not in tap_migrations list.
// 225:
// 226:       migrated_tap_name = Utils.tap_from_full_name(migration_target)
// 227:       new_name = if migrated_tap_name
// 228:         new_full_name = Utils.name_from_full_name(migration_target)
// 229:         new_tap_name = migrated_tap_name
// 230:         new_full_name
// 231:       elsif migration_target.include?("/")
// 232:         new_tap_name = migration_target
// 233:         new_full_name = "#{new_tap_name}/#{name}"
// 234:         name
// 235:       else
// 236:         new_tap_name = tap.name
// 237:         new_full_name = "#{new_tap_name}/#{migration_target}"
// 238:         migration_target
// 239:       end
// 240:
// 241:       # This means it is a cask
// 242:       if Array(report[:DC]).include? full_name
// 243:         next unless (HOMEBREW_PREFIX/"Caskroom"/name).exist?
// 244:
// 245:         new_tap = Tap.fetch(new_tap_name)
// 246:         next unless ensure_trusted_tap_installed!(name, new_name, new_tap)
// 247:
// 248:         ohai "#{name} has been moved to Homebrew.", <<~EOS
// 249:           To uninstall the cask, run:
// 250:             brew uninstall --cask --force #{name}
// 251:         EOS
// 252:         next if (HOMEBREW_CELLAR/Utils.name_from_full_name(new_name)).directory?
// 253:
// 254:         ohai "Installing #{new_name}..."
// 255:         begin
// 256:           system HOMEBREW_BREW_FILE.to_s, "install", "--overwrite", new_full_name
// 257:         # Rescue any possible exception types.
// 258:         rescue Exception => e # rubocop:disable Lint/RescueException
// 259:           if Homebrew::EnvConfig.developer?
// 260:             require "utils/backtrace"
// 261:             onoe "#{e.message}\n#{Utils::Backtrace.clean(e)&.join("\n")}"
// 262:           end
// 263:         end
// 264:         next
// 265:       end
// 266:
// 267:       next unless (dir = HOMEBREW_CELLAR/name).exist? # skip if formula is not installed.
// 268:
// 269:       tabs = dir.subdirs.map { |d| Keg.new(d).tab }
// 270:       next if tabs.first.tap != tap # skip if installed formula is not from this tap.
// 271:
// 272:       new_tap = Tap.fetch(new_tap_name)
// 273:       # For formulae migrated to cask: Auto-install cask or provide install instructions.
// 274:       # Check if the migration target is a cask (either in homebrew/cask or any other tap)
// 275:       if new_tap.core_cask_tap? || new_tap.cask_tokens.intersect?([new_full_name, new_name])
// 276:         migration_message = if new_tap == tap
// 277:           "#{full_name} has been migrated from a formula to a cask."
// 278:         else
// 279:           "#{name} has been moved to #{new_tap_name}."
// 280:         end
// 281:         if new_tap.installed? && (HOMEBREW_PREFIX/"Caskroom").directory?
// 282:           ohai migration_message
// 283:           ohai "brew unlink #{name}"
// 284:           system HOMEBREW_BREW_FILE.to_s, "unlink", name
// 285:           ohai "brew cleanup"
// 286:           system HOMEBREW_BREW_FILE.to_s, "cleanup"
// 287:           ohai "brew install --cask #{new_full_name}"
// 288:           system HOMEBREW_BREW_FILE.to_s, "install", "--cask", new_full_name
// 289:           ohai migration_message, <<~EOS
// 290:             The existing keg has been unlinked.
// 291:             Please uninstall the formula when convenient by running:
// 292:               brew uninstall --formula --force #{name}
// 293:           EOS
// 294:         else
// 295:           ohai migration_message, <<~EOS
// 296:             To uninstall the formula and install the cask, run:
// 297:               brew uninstall --formula --force #{name}
// 298:               brew tap #{new_tap_name}
// 299:               brew install --cask #{new_full_name}
// 300:           EOS
// 301:         end
// 302:       else
// 303:         next unless ensure_trusted_tap_installed!(name, new_name, new_tap)
// 304:
// 305:         # update tap for each Tab
// 306:         tabs.each { |tab| tab.tap = new_tap }
// 307:         tabs.each(&:write)
// 308:       end
// 309:     end
// 310:   end
// 311:
// 312:   sig { void }
// 313:   def migrate_cask_rename
// 314:     Cask::Caskroom.casks.each do |cask|
// 315:       Cask::Migrator.migrate_if_needed(cask)
// 316:     end
// 317:   end
// 318:
// 319:   sig { params(force: T::Boolean, verbose: T::Boolean).void }
// 320:   def migrate_formula_rename(force:, verbose:)
// 321:     Formula.installed.each do |formula|
// 322:       next unless Migrator.needs_migration?(formula)
// 323:
// 324:       oldnames_to_migrate = formula.oldnames.select do |oldname|
// 325:         oldname_rack = HOMEBREW_CELLAR/oldname
// 326:         next false unless oldname_rack.exist?
// 327:
// 328:         if oldname_rack.subdirs.empty?
// 329:           oldname_rack.rmdir_if_possible
// 330:           next false
// 331:         end
// 332:
// 333:         true
// 334:       end
// 335:       next if oldnames_to_migrate.empty?
// 336:
// 337:       Migrator.migrate_if_needed(formula, force:)
// 338:     end
// 339:   end
// 340:
// 341:   sig { params(name: String, new_name: String, new_tap: Tap).returns(T::Boolean) }
// 342:   def ensure_trusted_tap_installed!(name, new_name, new_tap)
// 343:     return true if new_tap.installed?
// 344:
// 345:     unless Homebrew::Trust.trusted_tap?(new_tap)
// 346:       new_bare_name = Utils.name_from_full_name(new_name)
// 347:       new_full_name = "#{new_tap.name}/#{new_bare_name}"
// 348:       # `brew migrate` only migrates renamed packages, so a tap-only migration
// 349:       # (unchanged name) needs a reinstall from the new tap instead.
// 350:       complete_command = if new_bare_name == name
// 351:         "brew reinstall #{name}"
// 352:       else
// 353:         "brew migrate #{name}"
// 354:       end
// 355:       opoo <<~EOS
// 356:         Not automatically tapping #{new_tap} to migrate #{name} as it is not a
// 357:         trusted tap. To complete the migration yourself, run:
// 358:           brew tap #{new_tap}
// 359:           brew trust #{new_full_name}
// 360:           #{complete_command}
// 361:       EOS
// 362:       return false
// 363:     end
// 364:
// 365:     new_tap.ensure_installed!
// 366:     true
// 367:   end
// 368:
// 369:   sig { returns(String) }
// 370:   def diff
// 371:     @diff ||= T.let(nil, T.nilable(String))
// 372:     @diff ||= if installed_from_api?
// 373:       # Hack `git diff` output with regexes to look like `git diff-tree` output.
// 374:       # Yes, I know this is a bit filthy but it saves duplicating the #report logic.
// 375:       diff_output = Utils.popen_read("git", "diff", "--no-ext-diff", api_names_before_txt, api_names_txt)
// 376:       header_regex = /^(---|\+\+\+) /
// 377:       add_delete_characters = ["+", "-"].freeze
// 378:
// 379:       api_dir_prefix_basename = T.must(api_dir_prefix).basename
// 380:
// 381:       diff_hash = diff_output.lines.each_with_object({}) do |line, hash|
// 382:         next if line.match?(header_regex)
// 383:         next unless add_delete_characters.include?(line[0])
// 384:
// 385:         name = line.chomp.delete_prefix("+").delete_prefix("-")
// 386:         file = "#{api_dir_prefix_basename}/#{name}.rb"
// 387:
// 388:         hash[file] ||= 0
// 389:         if line.start_with?("+")
// 390:           hash[file] += 1
// 391:         elsif line.start_with?("-")
// 392:           hash[file] -= 1
// 393:         end
// 394:       end
// 395:
// 396:       diff_hash.filter_map do |file, count|
// 397:         if count.positive?
// 398:           "A #{file}"
// 399:         elsif count.negative?
// 400:           "D #{file}"
// 401:         end
// 402:       end.join("\n")
// 403:     else
// 404:       Utils.popen_read(
// 405:         "git", "-C", tap.path, "diff-tree", "-r", "--name-status", "--diff-filter=AMDR",
// 406:         "-M85%", initial_revision, current_revision
// 407:       )
// 408:     end
// 409:   end
// 410:
// 411:   private
// 412:
// 413:   sig { returns(Tap) }
// 414:   attr_reader :tap
// 415:
// 416:   sig { returns(String) }
// 417:   attr_reader :initial_revision
// 418:
// 419:   sig { returns(String) }
// 420:   attr_reader :current_revision
// 421:
// 422:   sig { returns(T.nilable(Pathname)) }
// 423:   attr_reader :api_names_txt
// 424:
// 425:   sig { returns(T.nilable(Pathname)) }
// 426:   attr_reader :api_names_before_txt
// 427:
// 428:   sig { returns(T.nilable(Pathname)) }
// 429:   attr_reader :api_dir_prefix
// 430:
// 431:   sig {
// 432:     params(api_names_txt: T.nilable(Pathname), api_names_before_txt: T.nilable(Pathname),
// 433:            api_dir_prefix: T.nilable(Pathname)).returns(T::Boolean)
// 434:   }
// 435:   def installed_from_api?(api_names_txt = @api_names_txt, api_names_before_txt = @api_names_before_txt,
// 436:                           api_dir_prefix = @api_dir_prefix)
// 437:     !api_names_txt.nil? && !api_names_before_txt.nil? && !api_dir_prefix.nil?
// 438:   end
// 439: end
