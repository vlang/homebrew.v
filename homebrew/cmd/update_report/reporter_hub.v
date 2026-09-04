module update_report

import ruby

// Translated from Homebrew/brew `cmd/update_report/reporter_hub.rb`.
pub struct ReporterHub {
pub mut:
	reporters []Reporter
	report    ReporterReport
}

pub struct ReporterHubDumpContext {
pub:
	auto_update               bool
	auto_update_quiet         bool
	no_update_report_new      bool
	no_install_from_api       bool
	any_casks_installed       bool
	running_on_linux          bool
	auto_update_skip_outdated bool
	installed_formulae        []string
	installed_casks           []string
	outdated_formulae         []string
	outdated_casks            []string
	formula_descriptions      map[string]string
	cask_descriptions         map[string]string
}

fn reporter_hub_merge(mut destination []string, source []string) {
	destination << source
}

pub fn (mut hub ReporterHub) add(mut reporter Reporter, auto_update bool) {
	hub.reporters << reporter
	report := reporter.report(auto_update)
	reporter_hub_merge(mut hub.report.added_formulae, report.added_formulae)
	reporter_hub_merge(mut hub.report.added_casks, report.added_casks)
	reporter_hub_merge(mut hub.report.deleted_formulae, report.deleted_formulae)
	reporter_hub_merge(mut hub.report.deleted_casks, report.deleted_casks)
	reporter_hub_merge(mut hub.report.modified_formulae, report.modified_formulae)
	reporter_hub_merge(mut hub.report.modified_casks, report.modified_casks)
	hub.report.renamed_formulae << report.renamed_formulae
	hub.report.renamed_casks << report.renamed_casks
	reporter_hub_merge(mut hub.report.tap_migrations, report.tap_migrations)
}

pub fn (hub ReporterHub) empty() bool {
	return hub.report.added_formulae.len == 0 && hub.report.added_casks.len == 0 && hub.report.deleted_formulae.len == 0 && hub.report.deleted_casks.len == 0 && hub.report.modified_formulae.len == 0 && hub.report.modified_casks.len == 0 && hub.report.renamed_formulae.len == 0 && hub.report.renamed_casks.len == 0 && hub.report.tap_migrations.len == 0
}

pub fn reporter_hub_select(report ReporterReport, key string) ![]string {
	return match key {
		'A' { report.added_formulae.clone() }
		'AC' { report.added_casks.clone() }
		'D' { report.deleted_formulae.clone() }
		'DC' { report.deleted_casks.clone() }
		'M' { report.modified_formulae.clone() }
		'MC' { report.modified_casks.clone() }
		'T' { report.tap_migrations.clone() }
		'R', 'RC' {
			return error('key ${key} contains rename pairs')
		}
		else {
			return error('Unsupported key ${key}')
		}
	}
}

pub fn reporter_hub_select_renames(report ReporterReport, key string) ![]ReporterRename {
	return match key {
		'R' { report.renamed_formulae.clone() }
		'RC' { report.renamed_casks.clone() }
		else {
			return error('Unsupported rename key ${key}')
		}
	}
}

pub fn reporter_hub_installed(formula string, installed_formulae []string) bool {
	return reporter_name_from_full_name(formula) in installed_formulae
}

pub fn reporter_hub_cask_installed(cask string, installed_casks []string) bool {
	return reporter_name_from_full_name(cask) in installed_casks
}

pub fn reporter_hub_description(formula string, context ReporterHubDumpContext) ?string {
	if context.no_install_from_api && formula.contains('/') {
		return none
	}
	description := context.formula_descriptions[formula] or {
		context.formula_descriptions[reporter_name_from_full_name(formula)] or { return none }
	}
	return if description.trim_space() == '' { none } else { description }
}

pub fn reporter_hub_cask_description(cask string, context ReporterHubDumpContext) ?string {
	if context.no_install_from_api && cask.contains('/') {
		return none
	}
	description := context.cask_descriptions[cask] or { return none }
	return if description.trim_space() == '' { none } else { description }
}

pub fn reporter_hub_output_report(title string, entries []string) string {
	if entries.len == 0 {
		return ''
	}
	mut sorted := entries.clone()
	sorted.sort()
	return '==> ${title}\n${sorted.join('\n')}\n'
}

pub fn reporter_hub_dump_new_formula_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	mut formulae := report.added_formulae.filter(!reporter_hub_installed(it, context.installed_formulae))
	formulae.sort()
	if formulae.len == 0 {
		return ''
	}
	display_descriptions := !context.no_install_from_api || formulae.len <= 100
	mut lines := ['==> New Formulae']
	for formula in formulae {
		if display_descriptions {
			if description := reporter_hub_description(formula, context) {
				lines << '${formula}: ${description}'
				continue
			}
		}
		lines << formula
	}
	return lines.join('\n') + '\n'
}

pub fn reporter_hub_dump_new_cask_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	if !context.any_casks_installed {
		return ''
	}
	mut casks := report.added_casks.filter(!reporter_hub_cask_installed(it, context.installed_casks))
	casks.sort()
	if casks.len == 0 {
		return ''
	}
	display_descriptions := !context.no_install_from_api || casks.len <= 100
	mut lines := ['==> New Casks']
	for cask in casks {
		token := reporter_name_from_full_name(cask)
		if display_descriptions {
			if description := reporter_hub_cask_description(cask, context) {
				lines << '${token}: ${description}'
				continue
			}
		}
		lines << token
	}
	return lines.join('\n') + '\n'
}

pub fn reporter_hub_dump_deleted_formula_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	formulae := report.deleted_formulae.filter(reporter_hub_installed(it, context.installed_formulae))
	return reporter_hub_output_report('Deleted Installed Formulae', formulae)
}

pub fn reporter_hub_dump_deleted_cask_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	if context.running_on_linux {
		return ''
	}
	casks := report.deleted_casks.filter(reporter_hub_cask_installed(it, context.installed_casks)).map(reporter_name_from_full_name(it))
	return reporter_hub_output_report('Deleted Installed Casks', casks)
}

fn reporter_hub_plural(noun string, count int) string {
	return if count == 1 {
		noun
	} else if noun == 'formula' { 'formulae' } else { '${noun}s' }
}

pub fn (hub ReporterHub) dump(context ReporterHubDumpContext) string {
	if context.auto_update && context.auto_update_quiet {
		return ''
	}
	mut output := ''
	if !context.no_update_report_new {
		output += reporter_hub_dump_new_formula_report(hub.report, context)
		output += reporter_hub_dump_new_cask_report(hub.report, context)
	}
	output += reporter_hub_dump_deleted_formula_report(hub.report, context)
	output += reporter_hub_dump_deleted_cask_report(hub.report, context)
	if !context.auto_update {
		output += reporter_hub_output_report('Outdated Formulae', context.outdated_formulae)
		output += reporter_hub_output_report('Outdated Casks', context.outdated_casks)
	}
	formula_count := context.outdated_formulae.len
	cask_count := context.outdated_casks.len
	if formula_count + cask_count == 0 {
		return output
	}
	mut message := ''
	if formula_count > 0 {
		message = '${formula_count} outdated ${reporter_hub_plural('formula', formula_count)}'
	}
	if cask_count > 0 {
		if message != '' {
			message += ' and '
		}
		message += '${cask_count} outdated ${reporter_hub_plural('cask', cask_count)}'
	}
	if context.auto_update && context.auto_update_skip_outdated {
		return output
	}
	output += '\nYou have ${message} installed.\n'
	if context.auto_update {
		return output
	}
	pronoun := if formula_count + cask_count == 1 { 'it' } else { 'them' }
	return output + 'You can upgrade ${pronoun} with brew upgrade\nor list ${pronoun} with brew outdated.\n'
}

fn reporter_hub_value(hub ReporterHub) ruby.Value {
	return ruby.Value{
		type_name: 'ReporterHub'
		repr: '${hub.reporters.len} reporter(s)'
		attributes: {
			'reporter_count': hub.reporters.len.str()
			'empty':          hub.empty().str()
		}
		map_data: {
			'reporters': ruby.array_value(hub.reporters.map(reporter_to_value(it)))
			'report':    reporter_report_to_value(hub.report)
		}
	}
}

fn reporter_hub_from_value(value ruby.Value) ReporterHub {
	mut reporters := []Reporter{}
	if reporter_values := value.map_data['reporters'] {
		for reporter_value in reporter_values.array_data {
			reporters << reporter_from_value(reporter_value)
		}
	}
	return ReporterHub{
		reporters: reporters
		report: if report_value := value.map_data['report'] {
			reporter_report_from_value(report_value)
		} else {
			ReporterReport{}
		}
	}
}

fn reporter_hub_context_from_value(value ruby.Value) ReporterHubDumpContext {
	return ReporterHubDumpContext{
		auto_update: (value.attributes['auto_update'] or { 'false' }) == 'true'
		auto_update_quiet: (value.attributes['auto_update_quiet'] or { 'false' }) == 'true'
		no_update_report_new: (value.attributes['no_update_report_new'] or { 'false' }) == 'true'
		no_install_from_api: (value.attributes['no_install_from_api'] or { 'false' }) == 'true'
		any_casks_installed: (value.attributes['any_casks_installed'] or { 'false' }) == 'true'
		running_on_linux: (value.attributes['running_on_linux'] or { 'false' }) == 'true'
		auto_update_skip_outdated: (value.attributes['auto_update_skip_outdated'] or { 'false' }) == 'true'
		installed_formulae: (value.map_data['installed_formulae'] or { ruby.string_array_value([]) }).string_array_data
		installed_casks: (value.map_data['installed_casks'] or { ruby.string_array_value([]) }).string_array_data
		outdated_formulae: (value.map_data['outdated_formulae'] or { ruby.string_array_value([]) }).string_array_data
		outdated_casks: (value.map_data['outdated_casks'] or { ruby.string_array_value([]) }).string_array_data
		formula_descriptions: value.attributes.clone()
		cask_descriptions: value.attributes.clone()
	}
}
