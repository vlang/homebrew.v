module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/audit.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn audit_run_input_boundary(input &AuditRunInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Audit::RunInput', '', {
		'audit_run_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_cask_for_audit_input_boundary(input &AuditCaskForAuditInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Audit::CaskForAuditInput', '', {
		'audit_cask_for_audit_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_print_problems_input_boundary(input &AuditPrintProblemsInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Audit::PrintProblemsInput', '', {
		'audit_print_problems_input_address': u64(voidptr(input)).str()
	})
}

pub fn audit_format_problems_input_boundary(input &AuditFormatProblemsInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Audit::FormatProblemsInput', '', {
		'audit_format_problems_input_address': u64(voidptr(input)).str()
	})
}

fn audit_run_input_from_value(value brew_runtime.Value) !&AuditRunInput {
	address := value.attributes['audit_run_input_address'] or {
		return error('invalid Audit command input')
	}
	return unsafe { &AuditRunInput(voidptr(address.u64())) }
}

fn audit_cask_for_audit_input_from_value(value brew_runtime.Value) !&AuditCaskForAuditInput {
	address := value.attributes['audit_cask_for_audit_input_address'] or {
		return error('invalid Audit cask input')
	}
	return unsafe { &AuditCaskForAuditInput(voidptr(address.u64())) }
}

fn audit_print_problems_input_from_value(value brew_runtime.Value) !&AuditPrintProblemsInput {
	address := value.attributes['audit_print_problems_input_address'] or {
		return error('invalid Audit print input')
	}
	return unsafe { &AuditPrintProblemsInput(voidptr(address.u64())) }
}

fn audit_format_problems_input_from_value(value brew_runtime.Value) !&AuditFormatProblemsInput {
	address := value.attributes['audit_format_problems_input_address'] or {
		return error('invalid Audit format input')
	}
	return unsafe { &AuditFormatProblemsInput(voidptr(address.u64())) }
}

fn audit_problem_value(problem AuditProblem) brew_runtime.Value {
	return brew_runtime.map_value({
		'message':      brew_runtime.string_value(problem.message)
		'corrected':    brew_runtime.bool_value(problem.corrected)
		'has_location': brew_runtime.bool_value(problem.location.has_location)
		'line':         brew_runtime.int_value(problem.location.line)
		'column':       brew_runtime.int_value(problem.location.column)
	})
}

fn audit_cask_value(cask AuditCask) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Cask', cask.full_name, {
		'full_name':    cask.full_name
		'path':         cask.path
		'refreshed_os': cask.refreshed_os
	})
}

fn audit_run_result_value(result AuditRunResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'stdout':                  brew_runtime.string_array_value(result.stdout)
		'stderr':                  brew_runtime.string_array_value(result.stderr)
		'gem_groups':              brew_runtime.string_array_value(result.gem_groups)
		'selected_formulae':       brew_runtime.string_array_value(result.selected_formulae)
		'selected_casks':          brew_runtime.string_array_value(result.selected_casks)
		'strict':                  brew_runtime.bool_value(result.strict)
		'online':                  brew_runtime.bool_value(result.online)
		'tap_audit':               brew_runtime.bool_value(result.tap_audit)
		'skip_style':              brew_runtime.bool_value(result.skip_style)
		'no_named_args':           brew_runtime.bool_value(result.no_named_args)
		'style_files':             brew_runtime.string_array_value(result.style_files)
		'style_only_cops':         brew_runtime.string_array_value(result.style_only_cops)
		'style_except_cops':       brew_runtime.string_array_value(result.style_except_cops)
		'formula_only':            brew_runtime.string_array_value(result.formula_only)
		'api_access_enabled':      brew_runtime.bool_value(result.api_access_enabled_during_external_audit)
		'tap_problem_count':       brew_runtime.int_value(result.tap_problem_count)
		'formula_problem_count':   brew_runtime.int_value(result.formula_problem_count)
		'cask_problem_count':      brew_runtime.int_value(result.cask_problem_count)
		'corrected_problem_count': brew_runtime.int_value(result.corrected_problem_count)
		'annotations':             brew_runtime.array_value(result.annotations.map(brew_runtime.map_value({
			'message': brew_runtime.string_value(it.message)
			'file':    brew_runtime.string_value(it.file)
			'line':    brew_runtime.int_value(it.line)
			'column':  brew_runtime.int_value(it.column)
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

// Ruby method `run` at line 98.
pub fn ruby_audit_l98_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := audit_run_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := run_audit(input.options, input.environment) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return audit_run_result_value(result)
}

// Ruby method `cask_for_audit(path, cask_audit_os, cask_audit_arch)` at line 365.
pub fn ruby_audit_l365_d2_cask_for_audit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'cask input is required')
	}
	input := audit_cask_for_audit_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	cask := cask_for_audit(input.cask, input.os, input.arch) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return audit_cask_value(cask)
}

// Ruby method `print_problems(results)` at line 390.
pub fn ruby_audit_l390_d3_print_problems(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'results are required')
	}
	input := audit_print_problems_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.string_array_value(print_audit_problems(input.results, input.display_filename))
}

// Ruby method `format_problem_lines(problems)` at line 405.
pub fn ruby_audit_l405_d4_format_problem_lines(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'problems are required')
	}
	input := audit_format_problems_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.string_array_value(format_audit_problem_lines(input.problems))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "utils/curl"
// 7: require "utils/github/actions"
// 8: require "utils/spdx"
// 9: require "extend/ENV"
// 10: require "formula_cellar_checks"
// 11: require "cmd/search"
// 12: require "style"
// 13: require "date"
// 14: require "missing_formula"
// 15: require "digest"
// 16: require "json"
// 17: require "formula_auditor"
// 18: require "tap_auditor"
// 19: require "utils/git"
// 20:
// 21: module Homebrew
// 22:   module DevCmd
// 23:     class Audit < AbstractCommand
// 24:       cmd_args do
// 25:         description <<~EOS
// 26:           Check <formula> or <cask> for Homebrew coding style violations. This should be run
// 27:           before submitting a new formula or cask. If no <formula> or <cask> are provided, check
// 28:           all locally available formulae and casks and skip style checks. Will exit with a
// 29:           non-zero status if any errors are found.
// 30:         EOS
// 31:         flag   "--os=",
// 32:                description: "Audit the given operating system. (Pass `all` to audit all operating systems.)"
// 33:         flag   "--arch=",
// 34:                description: "Audit the given CPU architecture. (Pass `all` to audit all architectures.)"
// 35:         switch "--strict",
// 36:                description: "Run additional, stricter style checks."
// 37:         switch "--git",
// 38:                description: "Run additional, slower style checks that navigate the Git repository."
// 39:         switch "--online",
// 40:                description: "Run additional, slower style checks that require a network connection."
// 41:         switch "--installed",
// 42:                description: "Only check formulae and casks that are currently installed."
// 43:         switch "--eval-all",
// 44:                description: "Evaluate all available formulae and casks, whether installed or not, to audit them.",
// 45:                env:         :eval_all,
// 46:                odeprecated: true
// 47:         switch "--new",
// 48:                description: "Run various additional style checks to determine if a new formula or cask is eligible " \
// 49:                             "for Homebrew. This should be used when creating new formulae or casks and implies " \
// 50:                             "`--strict` and `--online`."
// 51:         switch "--[no-]signing",
// 52:                description: "Audit for app signatures, which are required by macOS on ARM.",
// 53:                odeprecated: true
// 54:         switch "--changed",
// 55:                description: "Check files that were changed from the `main` branch."
// 56:         flag   "--tap=",
// 57:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 58:         switch "--fix",
// 59:                description: "Fix style violations automatically using RuboCop's auto-correct feature."
// 60:         switch "--display-cop-names",
// 61:                description: "Include the RuboCop cop name for each violation in the output. This is the default.",
// 62:                hidden:      true
// 63:         switch "--display-filename",
// 64:                description: "Prefix every line of output with the file or formula name being audited, to " \
// 65:                             "make output easy to grep."
// 66:         switch "--skip-style",
// 67:                description: "Skip running non-RuboCop style checks. Useful if you plan on running " \
// 68:                             "`brew style` separately. Enabled by default unless a formula is specified by name."
// 69:         switch "-D", "--audit-debug",
// 70:                description: "Enable debugging and profiling of audit methods."
// 71:         comma_array "--only",
// 72:                     description: "Specify a comma-separated <method> list to only run the methods named " \
// 73:                                  "`audit_`<method>."
// 74:         comma_array "--except",
// 75:                     description: "Specify a comma-separated <method> list to skip running the methods named " \
// 76:                                  "`audit_`<method>."
// 77:         comma_array "--only-cops",
// 78:                     description: "Specify a comma-separated <cops> list to check for violations of only the listed " \
// 79:                                  "RuboCop cops."
// 80:         comma_array "--except-cops",
// 81:                     description: "Specify a comma-separated <cops> list to skip checking for violations of the " \
// 82:                                  "listed RuboCop cops."
// 83:         switch "--formula", "--formulae",
// 84:                description: "Treat all named arguments as formulae."
// 85:         switch "--cask", "--casks",
// 86:                description: "Treat all named arguments as casks."
// 87:
// 88:         conflicts "--installed", "--eval-all", "--changed", "--tap"
// 89:         conflicts "--only", "--except"
// 90:         conflicts "--only-cops", "--except-cops", "--strict"
// 91:         conflicts "--only-cops", "--except-cops", "--only"
// 92:         conflicts "--formula", "--cask"
// 93:
// 94:         named_args [:formula, :cask], without_api: true
// 95:       end
// 96:
// 97:       sig { override.void }
// 98:       def run
// 99:         Formulary.enable_factory_cache!
// 100:
// 101:         os_arch_combinations = args.os_arch_combinations
// 102:         cask_audit_os, cask_audit_arch =
// 103:           os_arch_combinations.find { |os, _arch| os != :linux } || os_arch_combinations.fetch(0)
// 104:
// 105:         Homebrew.auditing = true
// 106:         Homebrew.inject_dump_stats!(FormulaAuditor, /^audit_/) if args.audit_debug?
// 107:
// 108:         strict = args.new? || args.strict?
// 109:         online = args.new? || args.online?
// 110:         tap_audit = args.tap.present?
// 111:         skip_style = args.skip_style? || args.no_named? || tap_audit
// 112:         no_named_args = T.let(false, T::Boolean)
// 113:
// 114:         gem_groups = ["audit", "ast"]
// 115:         gem_groups << "style" unless skip_style
// 116:         Homebrew.install_bundler_gems!(groups: gem_groups)
// 117:         require "utils/ast"
// 118:
// 119:         ENV.activate_extensions!
// 120:         ENV.setup_build_environment
// 121:
// 122:         audit_formulae, audit_casks = Homebrew.with_no_api_env do # audit requires full Ruby source
// 123:           if args.changed?
// 124:             tap = Tap.from_path(Dir.pwd)
// 125:             odie "`brew audit --changed` must be run inside a tap!" if tap.blank?
// 126:
// 127:             no_named_args = true
// 128:
// 129:             audit_formulae = []
// 130:             audit_casks = []
// 131:
// 132:             Utils::Git.changed_files(tap.path).each do |file|
// 133:               next unless file.end_with?(".rb")
// 134:
// 135:               absolute_file = File.expand_path(file, tap.path)
// 136:               next unless File.exist?(absolute_file)
// 137:
// 138:               if tap.formula_file?(file)
// 139:                 audit_formulae << Formulary.factory(absolute_file)
// 140:               elsif tap.cask_file?(file) && (cask = cask_for_audit(absolute_file, cask_audit_os, cask_audit_arch))
// 141:                 audit_casks << cask
// 142:               end
// 143:             end
// 144:
// 145:             [audit_formulae, audit_casks]
// 146:           elsif args.tap
// 147:             Tap.fetch(args.tap).then do |tap|
// 148:               [
// 149:                 tap.formula_files.map { |path| Formulary.factory(path) },
// 150:                 tap.cask_files.filter_map { |path| cask_for_audit(path, cask_audit_os, cask_audit_arch) },
// 151:               ]
// 152:             end
// 153:           elsif args.installed?
// 154:             no_named_args = true
// 155:             [Formula.installed, Cask::Caskroom.casks]
// 156:           elsif args.no_named?
// 157:             eval_all = args.eval_all?
// 158:             eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 159:
// 160:             unless eval_all
// 161:               # This odisabled should probably stick around indefinitely.
// 162:               odisabled "`brew audit`",
// 163:                         "set `HOMEBREW_REQUIRE_TAP_TRUST=1`"
// 164:             end
// 165:             no_named_args = true
// 166:             [
// 167:               Formula.all(eval_all:),
// 168:               Cask::Cask.all(eval_all:),
// 169:             ]
// 170:           else
// 171:             if args.named.any? { |named_arg| named_arg.end_with?(".rb") }
// 172:               # This odisabled should probably stick around indefinitely,
// 173:               # until at least we have a way to exclude error on these in the CLI parser.
// 174:               odisabled "`brew audit [path ...]`",
// 175:                         "`brew audit [name ...]`"
// 176:             end
// 177:
// 178:             args.named.to_formulae_and_casks_with_taps
// 179:                 .partition { |formula_or_cask| formula_or_cask.is_a?(Formula) }
// 180:           end
// 181:         end
// 182:
// 183:         if audit_formulae.empty? && audit_casks.empty? && !args.tap
// 184:           ofail "No matching formulae or casks to audit!"
// 185:           return
// 186:         end
// 187:
// 188:         style_files = args.named.to_paths unless skip_style
// 189:
// 190:         only_cops = args.only_cops
// 191:         except_cops = args.except_cops
// 192:         style_options = { fix: args.fix?, debug: args.debug?, verbose: args.verbose? }
// 193:
// 194:         if only_cops
// 195:           style_options[:only_cops] = only_cops
// 196:         elsif args.new?
// 197:           nil
// 198:         elsif except_cops
// 199:           style_options[:except_cops] = except_cops
// 200:         elsif !strict
// 201:           style_options[:except_cops] = %w[FormulaAuditStrict]
// 202:         end
// 203:
// 204:         # Run tap audits first
// 205:         named_arg_taps = [*audit_formulae, *audit_casks].map(&:tap).uniq if !args.tap && !no_named_args
// 206:         tap_problems = Tap.installed.each_with_object({}) do |tap, problems|
// 207:           next if args.tap && tap != args.tap
// 208:           next if named_arg_taps&.exclude?(tap)
// 209:
// 210:           ta = TapAuditor.new(tap, strict: args.strict?)
// 211:           ta.audit
// 212:
// 213:           problems[[tap.name, tap.path]] = ta.problems if ta.problems.any?
// 214:         end
// 215:
// 216:         # Check style in a single batch run up front for performance
// 217:         style_offenses = Style.check_style_json(style_files, **style_options) if style_files
// 218:         # load licenses
// 219:         spdx_license_data = SPDX.license_data
// 220:         spdx_exception_data = SPDX.exception_data
// 221:
// 222:         formula_problems = audit_formulae.sort.each_with_object({}) do |f, problems|
// 223:           path = f.path
// 224:
// 225:           only = only_cops ? ["style"] : args.only
// 226:           options = {
// 227:             new_formula:         args.new?,
// 228:             strict:,
// 229:             online:,
// 230:             git:                 args.git?,
// 231:             only:,
// 232:             except:              args.except,
// 233:             spdx_license_data:,
// 234:             spdx_exception_data:,
// 235:             style_offenses:      style_offenses&.for_path(f.path),
// 236:             tap_audit:,
// 237:           }.compact
// 238:
// 239:           errors = os_arch_combinations.flat_map do |os, arch|
// 240:             SimulateSystem.with(os:, arch:) do
// 241:               odebug "Auditing Formula #{f} on os #{os} and arch #{arch}"
// 242:
// 243:               audit_proc = proc { FormulaAuditor.new(Formulary.factory(path), **options).tap(&:audit) }
// 244:
// 245:               # Audit requires full Ruby source so disable API. We shouldn't do this for taps however so that we
// 246:               # don't unnecessarily require a full Homebrew/core clone.
// 247:               fa = if f.core_formula?
// 248:                 Homebrew.with_no_api_env(&audit_proc)
// 249:               elsif Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 250:                 with_env(
// 251:                   HOMEBREW_NO_INSTALL_FROM_API:                   nil,
// 252:                   HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API: nil,
// 253:                   &audit_proc
// 254:                 )
// 255:               else
// 256:                 audit_proc.call
// 257:               end
// 258:
// 259:               fa.problems + fa.new_formula_problems
// 260:             end
// 261:           end.uniq
// 262:
// 263:           problems[[f.full_name, path]] = errors if errors.any?
// 264:         end
// 265:
// 266:         require "cask/auditor" if audit_casks.any?
// 267:
// 268:         cask_problems = audit_casks.each_with_object({}) do |cask, problems|
// 269:           path = cask.sourcefile_path
// 270:
// 271:           errors = os_arch_combinations.flat_map do |os, arch|
// 272:             # Linux-only casks have no stanza values for macOS, so audit them
// 273:             # under Linux instead.
// 274:             os = :linux if os != :linux && !cask.supports_macos?
// 275:
// 276:             SimulateSystem.with(os:, arch:) do
// 277:               odebug "Auditing Cask #{cask} on os #{os} and arch #{arch}"
// 278:
// 279:               Cask::Auditor.audit(
// 280:                 Cask::CaskLoader.load(path),
// 281:                 # For switches, we add `|| nil` so that `nil` will be passed
// 282:                 # instead of `false` if they aren't set.
// 283:                 # This way, we can distinguish between "not set" and "set to false".
// 284:                 audit_online:   args.online? || nil,
// 285:                 audit_strict:   args.strict? || nil,
// 286:
// 287:                 # No need for `|| nil` for `--[no-]signing`
// 288:                 # because boolean switches are already `nil` if not passed
// 289:                 audit_signing:  args.signing?,
// 290:                 audit_new_cask: args.new? || nil,
// 291:                 any_named_args: !no_named_args,
// 292:                 only:           args.only || [],
// 293:                 except:         args.except || [],
// 294:               ).to_a
// 295:             end
// 296:           end.uniq
// 297:
// 298:           problems[[cask.full_name, path]] = errors if errors.any?
// 299:         end
// 300:
// 301:         print_problems(tap_problems)
// 302:         print_problems(formula_problems)
// 303:         print_problems(cask_problems)
// 304:
// 305:         tap_count = tap_problems.keys.count
// 306:         formula_count = formula_problems.keys.count
// 307:         cask_count = cask_problems.keys.count
// 308:
// 309:         corrected_problem_count = (formula_problems.values + cask_problems.values)
// 310:                                   .sum { |problems| problems.count { |problem| problem.fetch(:corrected) } }
// 311:
// 312:         tap_problem_count = tap_problems.sum { |_, problems| problems.count }
// 313:         formula_problem_count = formula_problems.sum { |_, problems| problems.count }
// 314:         cask_problem_count = cask_problems.sum { |_, problems| problems.count }
// 315:         total_problems_count = formula_problem_count + cask_problem_count + tap_problem_count
// 316:
// 317:         if total_problems_count.positive?
// 318:           errors_summary = Utils.pluralize("problem", total_problems_count, include_count: true)
// 319:
// 320:           error_sources = []
// 321:           error_sources << Utils.pluralize("formula", formula_count, include_count: true) if formula_count.positive?
// 322:           error_sources << Utils.pluralize("cask", cask_count, include_count: true) if cask_count.positive?
// 323:           error_sources << Utils.pluralize("tap", tap_count, include_count: true) if tap_count.positive?
// 324:
// 325:           errors_summary += " in #{error_sources.to_sentence}" if error_sources.any?
// 326:
// 327:           errors_summary += " detected"
// 328:
// 329:           if corrected_problem_count.positive?
// 330:             errors_summary +=
// 331:               ", #{Utils.pluralize("problem", corrected_problem_count, include_count: true)} corrected"
// 332:           end
// 333:
// 334:           ofail "#{errors_summary}."
// 335:         end
// 336:
// 337:         return unless GitHub::Actions.env_set?
// 338:
// 339:         annotations = formula_problems.merge(cask_problems).flat_map do |(_, path), problems|
// 340:           problems.map do |problem|
// 341:             GitHub::Actions::Annotation.new(
// 342:               :error,
// 343:               problem[:message],
// 344:               file:   path,
// 345:               line:   problem[:location]&.line,
// 346:               column: problem[:location]&.column,
// 347:             )
// 348:           end
// 349:         end.compact
// 350:
// 351:         annotations.each do |annotation|
// 352:           puts annotation if annotation.relevant?
// 353:         end
// 354:       end
// 355:
// 356:       private
// 357:
// 358:       sig {
// 359:         params(
// 360:           path:            T.any(String, Pathname),
// 361:           cask_audit_os:   Symbol,
// 362:           cask_audit_arch: Symbol,
// 363:         ).returns(T.nilable(Cask::Cask))
// 364:       }
// 365:       def cask_for_audit(path, cask_audit_os, cask_audit_arch)
// 366:         if cask_audit_os == :linux
// 367:           return if Utils::AST::CaskAST.new(Pathname(path).read).depends_on_macos?
// 368:
// 369:           cask = SimulateSystem.with(os: :macos, arch: cask_audit_arch) do
// 370:             loaded_cask = Cask::CaskLoader.load(path)
// 371:             loaded_cask if loaded_cask.supports_linux?
// 372:           end
// 373:           return unless cask
// 374:
// 375:           SimulateSystem.with(os: :linux, arch: cask_audit_arch) { cask.refresh }
// 376:           return cask
// 377:         end
// 378:
// 379:         SimulateSystem.with(os: cask_audit_os, arch: cask_audit_arch) { Cask::CaskLoader.load(path) }
// 380:       end
// 381:
// 382:       sig {
// 383:         params(
// 384:           results: T::Hash[
// 385:             T::Array[T.any(String, Pathname)],
// 386:             T::Array[T::Hash[Symbol, T.untyped]],
// 387:           ],
// 388:         ).void
// 389:       }
// 390:       def print_problems(results)
// 391:         results.each do |(name, path), problems|
// 392:           problem_lines = format_problem_lines(problems)
// 393:
// 394:           if args.display_filename?
// 395:             problem_lines.each do |l|
// 396:               puts "#{path}: #{l}"
// 397:             end
// 398:           else
// 399:             puts name, problem_lines.map { |l| l.dup.prepend("  ") }
// 400:           end
// 401:         end
// 402:       end
// 403:
// 404:       sig { params(problems: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[String]) }
// 405:       def format_problem_lines(problems)
// 406:         problems.map do |problem|
// 407:           status = " #{Formatter.success("[corrected]")}" if problem.fetch(:corrected)
// 408:           location = problem.fetch(:location)
// 409:           if location
// 410:             location = "#{location.line&.to_s&.prepend("line ")}#{location.column&.to_s&.prepend(", col ")}: "
// 411:           end
// 412:           message = problem.fetch(:message)
// 413:           "* #{location}#{message.chomp.gsub("\n", "\n    ")}#{status}"
// 414:         end
// 415:       end
// 416:     end
// 417:   end
// 418: end
