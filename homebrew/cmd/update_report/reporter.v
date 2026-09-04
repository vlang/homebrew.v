module update_report

import ruby
import os

// Translated from Homebrew/brew `cmd/update_report/reporter.rb`.
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

fn reporter_report_to_value(report ReporterReport) ruby.Value {
	renames := report.renamed_formulae.map(ruby.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
		'old_name': it.old_name
		'new_name': it.new_name
	}))
	cask_renames := report.renamed_casks.map(ruby.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
		'old_name': it.old_name
		'new_name': it.new_name
	}))
	return ruby.map_value({
		'A':  ruby.string_array_value(report.added_formulae)
		'AC': ruby.string_array_value(report.added_casks)
		'D':  ruby.string_array_value(report.deleted_formulae)
		'DC': ruby.string_array_value(report.deleted_casks)
		'M':  ruby.string_array_value(report.modified_formulae)
		'MC': ruby.string_array_value(report.modified_casks)
		'R':  ruby.array_value(renames)
		'RC': ruby.array_value(cask_renames)
		'T':  ruby.string_array_value(report.tap_migrations)
	})
}

fn reporter_renames_from_value(value ruby.Value) []ReporterRename {
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

fn reporter_report_from_value(value ruby.Value) ReporterReport {
	return ReporterReport{
		added_formulae: (value.map_data['A'] or { ruby.string_array_value([]) }).string_array_data
		added_casks: (value.map_data['AC'] or { ruby.string_array_value([]) }).string_array_data
		deleted_formulae: (value.map_data['D'] or { ruby.string_array_value([]) }).string_array_data
		deleted_casks: (value.map_data['DC'] or { ruby.string_array_value([]) }).string_array_data
		modified_formulae: (value.map_data['M'] or { ruby.string_array_value([]) }).string_array_data
		modified_casks: (value.map_data['MC'] or { ruby.string_array_value([]) }).string_array_data
		renamed_formulae: reporter_renames_from_value(value.map_data['R'] or { ruby.array_value([]) })
		renamed_casks: reporter_renames_from_value(value.map_data['RC'] or { ruby.array_value([]) })
		tap_migrations: (value.map_data['T'] or { ruby.string_array_value([]) }).string_array_data
	}
}

fn reporter_migration_result_to_value(result ReporterMigrationResult) ruby.Value {
	return ruby.map_value({
		'actions':           ruby.string_array_value(result.actions)
		'warnings':          ruby.string_array_value(result.warnings)
		'installed_taps':    ruby.string_array_value(result.installed_taps)
		'updated_formulae':  ruby.string_array_value(result.updated_formulae)
		'migrated_casks':    ruby.string_array_value(result.migrated_casks)
		'migrated_formulae': ruby.string_array_value(result.migrated_formulae)
	})
}

fn reporter_migration_packages_from_value(value ruby.Value) []ReporterMigrationPackage {
	values := if value.array_data.len > 0 { value.array_data } else { []ruby.Value{} }
	mut packages := []ReporterMigrationPackage{}
	for item in values {
		mut racks := map[string]bool{}
		mut nonempty := map[string]bool{}
		oldnames := (item.map_data['oldnames'] or { ruby.string_array_value([]) }).string_array_data
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

pub fn reporter_to_value(reporter Reporter) ruby.Value {
	return ruby.structured_value('Reporter', reporter.tap.name, {
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

fn reporter_from_value(value ruby.Value) Reporter {
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
