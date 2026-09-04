module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/audit.rb`.

pub struct AuditSystem {
pub:
	os   string
	arch string
}

pub struct AuditLocation {
pub:
	has_location bool
	has_line     bool
	line         int
	has_column   bool
	column       int
}

pub struct AuditProblem {
pub:
	message   string
	location  AuditLocation
	corrected bool
}

pub struct AuditProblemSet {
pub:
	os       string
	arch     string
	problems []AuditProblem
}

pub struct AuditFormula {
pub:
	full_name            string
	path                 string
	tap_name             string
	core                 bool
	problems             []AuditProblem
	new_formula_problems []AuditProblem
}

pub struct AuditCask {
pub:
	full_name        string
	path             string
	tap_name         string
	depends_on_macos bool
	supports_linux   bool = true
	supports_macos   bool = true
	loadable         bool = true
	problem_sets     []AuditProblemSet
	refreshed_os     string
}

pub struct AuditTap {
pub:
	name         string
	path         string
	formulae     []AuditFormula
	casks        []AuditCask
	tap_problems []AuditProblem
}

pub struct AuditChangedFile {
pub:
	path       string
	exists     bool = true
	is_formula bool
	is_cask    bool
	formula    AuditFormula
	cask       AuditCask
}

pub struct AuditOptions {
pub:
	os_arch_combinations []AuditSystem
	strict               bool
	git                  bool
	online               bool
	installed            bool
	eval_all             bool
	new_formula          bool
	changed              bool
	tap                  string
	fix                  bool
	debug                bool
	verbose              bool
	display_filename     bool
	skip_style           bool
	audit_debug          bool
	only                 []string
	excluded             []string
	only_cops            []string
	except_cops          []string
	named                []string
}

// AuditEnvironment makes the Ruby command's filesystem, tap, formula, cask and
// GitHub collaborators explicit. The command still performs the same selection,
// filtering and aggregation; callers provide the observations those Ruby
// collaborators would have returned.
pub struct AuditEnvironment {
pub:
	current_tap_present                   bool
	current_tap                           AuditTap
	fetched_tap_present                   bool
	fetched_tap                           AuditTap
	changed_files                         []AuditChangedFile
	installed_formulae                    []AuditFormula
	installed_casks                       []AuditCask
	all_formulae                          []AuditFormula
	all_casks                             []AuditCask
	named_formulae                        []AuditFormula
	named_casks                           []AuditCask
	installed_taps                        []AuditTap
	tap_trust_configured                  bool
	automatically_set_no_install_from_api bool
	github_actions                        bool
}

pub struct AuditAnnotation {
pub:
	message    string
	file       string
	line       int
	column     int
	has_line   bool
	has_column bool
}

pub struct AuditNamedProblems {
pub:
	name     string
	path     string
	problems []AuditProblem
}

pub struct AuditRunResult {
pub mut:
	stdout                                   []string
	stderr                                   []string
	gem_groups                               []string
	selected_formulae                        []string
	selected_casks                           []string
	strict                                   bool
	online                                   bool
	tap_audit                                bool
	skip_style                               bool
	no_named_args                            bool
	style_files                              []string
	style_only_cops                          []string
	style_except_cops                        []string
	formula_only                             []string
	api_access_enabled_during_external_audit bool
	tap_problem_count                        int
	formula_problem_count                    int
	cask_problem_count                       int
	corrected_problem_count                  int
	annotations                              []AuditAnnotation
}

@[heap]
pub struct AuditRunInput {
pub:
	options     AuditOptions
	environment AuditEnvironment
}

@[heap]
pub struct AuditCaskForAuditInput {
pub:
	cask AuditCask
	os   string
	arch string
}

@[heap]
pub struct AuditPrintProblemsInput {
pub:
	results          []AuditNamedProblems
	display_filename bool
}

@[heap]
pub struct AuditFormatProblemsInput {
pub:
	problems []AuditProblem
}

pub fn audit_run_input_boundary(input &AuditRunInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Audit::RunInput', '', {
		'audit_run_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_cask_for_audit_input_boundary(input &AuditCaskForAuditInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Audit::CaskForAuditInput', '', {
		'audit_cask_for_audit_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_print_problems_input_boundary(input &AuditPrintProblemsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Audit::PrintProblemsInput', '', {
		'audit_print_problems_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_format_problems_input_boundary(input &AuditFormatProblemsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Audit::FormatProblemsInput', '', {
		'audit_format_problems_input_address': u64(voidptr(input)).str()
	})
}

fn audit_run_input_from_value(value ruby.Value) !&AuditRunInput {
	address := value.attributes['audit_run_input_address'] or {
		return error('invalid Audit command input')
	}
	return unsafe { &AuditRunInput(voidptr(address.u64())) }
}

fn audit_cask_for_audit_input_from_value(value ruby.Value) !&AuditCaskForAuditInput {
	address := value.attributes['audit_cask_for_audit_input_address'] or {
		return error('invalid Audit cask input')
	}
	return unsafe { &AuditCaskForAuditInput(voidptr(address.u64())) }
}

fn audit_print_problems_input_from_value(value ruby.Value) !&AuditPrintProblemsInput {
	address := value.attributes['audit_print_problems_input_address'] or {
		return error('invalid Audit print input')
	}
	return unsafe { &AuditPrintProblemsInput(voidptr(address.u64())) }
}

fn audit_format_problems_input_from_value(value ruby.Value) !&AuditFormatProblemsInput {
	address := value.attributes['audit_format_problems_input_address'] or {
		return error('invalid Audit format input')
	}
	return unsafe { &AuditFormatProblemsInput(voidptr(address.u64())) }
}

fn audit_problem_value(problem AuditProblem) ruby.Value {
	return ruby.map_value({
		'message':      ruby.string_value(problem.message)
		'corrected':    ruby.bool_value(problem.corrected)
		'has_location': ruby.bool_value(problem.location.has_location)
		'line':         ruby.int_value(problem.location.line)
		'column':       ruby.int_value(problem.location.column)
	})
}

fn audit_cask_value(cask AuditCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.full_name, {
		'full_name':    cask.full_name
		'path':         cask.path
		'refreshed_os': cask.refreshed_os
	})
}

fn audit_run_result_value(result AuditRunResult) ruby.Value {
	return ruby.map_value({
		'stdout':                  ruby.string_array_value(result.stdout)
		'stderr':                  ruby.string_array_value(result.stderr)
		'gem_groups':              ruby.string_array_value(result.gem_groups)
		'selected_formulae':       ruby.string_array_value(result.selected_formulae)
		'selected_casks':          ruby.string_array_value(result.selected_casks)
		'strict':                  ruby.bool_value(result.strict)
		'online':                  ruby.bool_value(result.online)
		'tap_audit':               ruby.bool_value(result.tap_audit)
		'skip_style':              ruby.bool_value(result.skip_style)
		'no_named_args':           ruby.bool_value(result.no_named_args)
		'style_files':             ruby.string_array_value(result.style_files)
		'style_only_cops':         ruby.string_array_value(result.style_only_cops)
		'style_except_cops':       ruby.string_array_value(result.style_except_cops)
		'formula_only':            ruby.string_array_value(result.formula_only)
		'api_access_enabled':      ruby.bool_value(result.api_access_enabled_during_external_audit)
		'tap_problem_count':       ruby.int_value(result.tap_problem_count)
		'formula_problem_count':   ruby.int_value(result.formula_problem_count)
		'cask_problem_count':      ruby.int_value(result.cask_problem_count)
		'corrected_problem_count': ruby.int_value(result.corrected_problem_count)
		'annotations':             ruby.array_value(result.annotations.map(ruby.map_value({
			'message': ruby.string_value(it.message)
			'file':    ruby.string_value(it.file)
			'line':    ruby.int_value(it.line)
			'column':  ruby.int_value(it.column)
		})))
	})
}

fn audit_ruby_chomp(value string) string {
	if value.ends_with('\r\n') {
		return value[..value.len - 2]
	}
	if value.ends_with('\n') || value.ends_with('\r') {
		return value[..value.len - 1]
	}
	return value
}

pub fn format_audit_problem_lines(problems []AuditProblem) []string {
	mut lines := []string{cap: problems.len}
	for problem in problems {
		status := if problem.corrected { ' [corrected]' } else { '' }
		mut location := ''
		if problem.location.has_location {
			if problem.location.has_line {
				location += 'line ${problem.location.line}'
			}
			if problem.location.has_column {
				location += ', col ${problem.location.column}'
			}
			location += ': '
		}
		message := audit_ruby_chomp(problem.message).replace('\n', '\n    ')
		lines << '* ${location}${message}${status}'
	}
	return lines
}

pub fn print_audit_problems(results []AuditNamedProblems, display_filename bool) []string {
	mut output := []string{}
	for result in results {
		problem_lines := format_audit_problem_lines(result.problems)
		if display_filename {
			for line in problem_lines {
				output << '${result.path}: ${line}'
			}
		} else {
			output << result.name
			output << problem_lines.map('  ${it}')
		}
	}
	return output
}

pub fn cask_for_audit(cask AuditCask, cask_audit_os string, cask_audit_arch string) ?AuditCask {
	_ = cask_audit_arch
	if !cask.loadable {
		return none
	}
	if cask_audit_os == 'linux' {
		if cask.depends_on_macos || !cask.supports_linux {
			return none
		}
		return AuditCask{
			...cask
			refreshed_os: 'linux'
		}
	}
	return AuditCask{
		...cask
		refreshed_os: cask_audit_os
	}
}

fn audit_problems_for_system(problem_sets []AuditProblemSet, system AuditSystem) []AuditProblem {
	for set in problem_sets {
		if (set.os == '' || set.os == system.os) && (set.arch == '' || set.arch == system.arch) {
			return set.problems.clone()
		}
	}
	return []AuditProblem{}
}

fn audit_problem_equal(left AuditProblem, right AuditProblem) bool {
	return left.message == right.message && left.corrected == right.corrected
		&& left.location == right.location
}

fn audit_unique_problems(problems []AuditProblem) []AuditProblem {
	mut unique := []AuditProblem{}
	for problem in problems {
		if !unique.any(audit_problem_equal(it, problem)) {
			unique << problem
		}
	}
	return unique
}

fn audit_pluralize(word string, count int) string {
	suffix := if count == 1 { '' } else { 's' }
	return '${count} ${word}${suffix}'
}

fn audit_to_sentence(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} and ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')}, and ${values.last()}'
}

fn audit_named_taps(formulae []AuditFormula, casks []AuditCask) []string {
	mut taps := []string{}
	for formula in formulae {
		if formula.tap_name != '' && formula.tap_name !in taps {
			taps << formula.tap_name
		}
	}
	for cask in casks {
		if cask.tap_name != '' && cask.tap_name !in taps {
			taps << cask.tap_name
		}
	}
	return taps
}

pub fn run_audit(options AuditOptions, environment AuditEnvironment) !AuditRunResult {
	mut systems := options.os_arch_combinations.clone()
	if systems.len == 0 {
		systems = [AuditSystem{ os: 'macos' }]
	}
	mut cask_audit_system := systems[0]
	for system in systems {
		if system.os != 'linux' {
			cask_audit_system = system
			break
		}
	}

	mut result := AuditRunResult{}
	result.strict = options.new_formula || options.strict
	result.online = options.new_formula || options.online
	result.tap_audit = options.tap != ''
	result.skip_style = options.skip_style || options.named.len == 0 || result.tap_audit
	result.gem_groups = ['audit', 'ast']
	if !result.skip_style {
		result.gem_groups << 'style'
	}

	mut formulae := []AuditFormula{}
	mut casks := []AuditCask{}
	if options.changed {
		if !environment.current_tap_present {
			return error('`brew audit --changed` must be run inside a tap!')
		}
		result.no_named_args = true
		for changed_file in environment.changed_files {
			if !changed_file.exists || !changed_file.path.ends_with('.rb') {
				continue
			}
			if changed_file.is_formula {
				formulae << changed_file.formula
			} else if changed_file.is_cask {
				if cask := cask_for_audit(changed_file.cask, cask_audit_system.os, cask_audit_system.arch) {
					casks << cask
				}
			}
		}
	} else if options.tap != '' {
		if !environment.fetched_tap_present {
			return error('tap `${options.tap}` is unavailable')
		}
		formulae = environment.fetched_tap.formulae.clone()
		for candidate in environment.fetched_tap.casks {
			if cask := cask_for_audit(candidate, cask_audit_system.os, cask_audit_system.arch) {
				casks << cask
			}
		}
	} else if options.installed {
		result.no_named_args = true
		formulae = environment.installed_formulae.clone()
		casks = environment.installed_casks.clone()
	} else if options.named.len == 0 {
		result.no_named_args = true
		formulae = environment.all_formulae.clone()
		casks = environment.all_casks.clone()
	} else {
		formulae = environment.named_formulae.clone()
		casks = environment.named_casks.clone()
	}

	result.selected_formulae = formulae.map(it.full_name)
	result.selected_casks = casks.map(it.full_name)
	if formulae.len == 0 && casks.len == 0 && options.tap == '' {
		result.stderr << 'No matching formulae or casks to audit!'
		return result
	}
	if !result.skip_style {
		result.style_files = options.named.clone()
	}
	if options.only_cops.len > 0 {
		result.style_only_cops = options.only_cops.clone()
		result.formula_only = ['style']
	} else if options.new_formula {
		// `--new` deliberately leaves RuboCop's configured cop set unchanged.
	} else if options.except_cops.len > 0 {
		result.style_except_cops = options.except_cops.clone()
	} else if !result.strict {
		result.style_except_cops = ['FormulaAuditStrict']
	}
	if result.formula_only.len == 0 {
		result.formula_only = options.only.clone()
	}

	mut tap_results := []AuditNamedProblems{}
	named_taps := audit_named_taps(formulae, casks)
	for tap in environment.installed_taps {
		if options.tap != '' && tap.name != options.tap {
			continue
		}
		if options.tap == '' && !result.no_named_args && tap.name !in named_taps {
			continue
		}
		if tap.tap_problems.len > 0 {
			tap_results << AuditNamedProblems{
				name: tap.name
				path: tap.path
				problems: tap.tap_problems.clone()
			}
		}
	}

	mut formula_results := []AuditNamedProblems{}
	formulae.sort_with_compare(fn (left &AuditFormula, right &AuditFormula) int {
		return compare_strings(left.full_name, right.full_name)
	})
	for formula in formulae {
		mut problems := []AuditProblem{}
		for _ in systems {
			problems << formula.problems
			problems << formula.new_formula_problems
		}
		problems = audit_unique_problems(problems)
		if !formula.core && environment.automatically_set_no_install_from_api {
			result.api_access_enabled_during_external_audit = true
		}
		if problems.len > 0 {
			formula_results << AuditNamedProblems{
				name: formula.full_name
				path: formula.path
				problems: problems
			}
		}
	}

	mut cask_results := []AuditNamedProblems{}
	for cask in casks {
		mut problems := []AuditProblem{}
		for original_system in systems {
			mut audit_system := original_system
			if audit_system.os != 'linux' && !cask.supports_macos {
				audit_system = AuditSystem{
					os: 'linux'
					arch: audit_system.arch
				}
			}
			problems << audit_problems_for_system(cask.problem_sets, audit_system)
		}
		problems = audit_unique_problems(problems)
		if problems.len > 0 {
			cask_results << AuditNamedProblems{
				name: cask.full_name
				path: cask.path
				problems: problems
			}
		}
	}

	result.stdout << print_audit_problems(tap_results, options.display_filename)
	result.stdout << print_audit_problems(formula_results, options.display_filename)
	result.stdout << print_audit_problems(cask_results, options.display_filename)
	for entry in tap_results {
		result.tap_problem_count += entry.problems.len
	}
	for entry in formula_results {
		result.formula_problem_count += entry.problems.len
		result.corrected_problem_count += entry.problems.filter(it.corrected).len
	}
	for entry in cask_results {
		result.cask_problem_count += entry.problems.len
		result.corrected_problem_count += entry.problems.filter(it.corrected).len
	}
	total := result.tap_problem_count + result.formula_problem_count + result.cask_problem_count
	if total > 0 {
		mut sources := []string{}
		if formula_results.len > 0 {
			sources << audit_pluralize('formula', formula_results.len)
		}
		if cask_results.len > 0 {
			sources << audit_pluralize('cask', cask_results.len)
		}
		if tap_results.len > 0 {
			sources << audit_pluralize('tap', tap_results.len)
		}
		mut summary := audit_pluralize('problem', total)
		if sources.len > 0 {
			summary += ' in ${audit_to_sentence(sources)}'
		}
		summary += ' detected'
		if result.corrected_problem_count > 0 {
			summary += ', ${audit_pluralize('problem', result.corrected_problem_count)} corrected'
		}
		result.stderr << '${summary}.'
	}

	if environment.github_actions {
		for entry in formula_results {
			for problem in entry.problems {
				result.annotations << AuditAnnotation{
					message: problem.message
					file: entry.path
					line: problem.location.line
					column: problem.location.column
					has_line: problem.location.has_line
					has_column: problem.location.has_column
				}
			}
		}
		for entry in cask_results {
			for problem in entry.problems {
				result.annotations << AuditAnnotation{
					message: problem.message
					file: entry.path
					line: problem.location.line
					column: problem.location.column
					has_line: problem.location.has_line
					has_column: problem.location.has_column
				}
			}
		}
	}
	return result
}
