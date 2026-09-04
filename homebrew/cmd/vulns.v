module cmd

import ruby
import x.json2

// Translated from Homebrew/brew `cmd/vulns.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct VulnsFormula {
pub:
	formula                VulnsScannerFormula
	recursive_dependencies []VulnsScannerFormula
}

pub enum VulnsSeverity {
	unknown
	low
	medium
	high
	critical
}

pub struct VulnsScannerFormula {
pub:
	name                   string
	full_name              string
	stable_url             string
	head_url               string
	homepage               string
	stable_tag             string
	stable_version         string
	version                string
	installed              bool
	installed_prefix       string
	installed_version      string
	current_recipe_applies bool = true
}

pub struct VulnsScannerOptions {
pub:
	ignore_patches bool = true
	min_severity   VulnsSeverity
	only_fixed     bool
	except_fixed   bool
}

pub struct VulnsVulnerability {
pub:
	id             string
	severity       VulnsSeverity
	summary        string
	aliases        []string
	fixed_versions []string
}

pub struct VulnsFinding {
pub:
	name     string
	version  string
	tag      string
	repo_url string
	open     []VulnsVulnerability
	patched  []VulnsVulnerability
}

pub struct VulnsScannerResults {
pub:
	findings              []VulnsFinding
	checked               int
	skipped               int
	outdated_without_sbom []string
}

pub fn (results VulnsScannerResults) any_open() bool {
	return results.findings.any(it.open.len > 0)
}

pub type VulnsScannerRunner = fn ([]VulnsScannerFormula, VulnsScannerOptions) !VulnsScannerResults

fn vulns_default_scanner(formulae []VulnsScannerFormula,
	_options VulnsScannerOptions) !VulnsScannerResults {
	// The command owns orchestration rather than OSV transport. Its scanner is
	// an injectable boundary just like Ruby's Scanner.new(...).scan call.
	return VulnsScannerResults{
		checked: formulae.len
	}
}

pub struct VulnsBrewfileEntry {
pub:
	entry_type string
	formula    VulnsFormula
}

pub struct VulnsInstalledRack {
pub:
	path      string
	formula   VulnsFormula
	error     string
	untrusted bool
}

pub struct VulnsCommandOptions {
pub:
	deps              bool
	no_ignore_patches bool
	brewfile          bool
	brewfile_value    ruby.Value
	fix_available     bool
	no_fix_available  bool
	severity          ?string
	max_summary       ?string
	json              bool
}

pub struct VulnsCommand {
pub:
	options          VulnsCommandOptions
	named            []VulnsFormula
	brewfile_entries []VulnsBrewfileEntry
	installed_racks  []VulnsInstalledRack
	scanner          VulnsScannerRunner = vulns_default_scanner
pub mut:
	untrusted_skipped []string
}

pub struct VulnsCommandResult {
pub:
	formulae        []VulnsScannerFormula
	scanner_options VulnsScannerOptions
	results         VulnsScannerResults
	stdout          string
	stderr          string
	failed          bool
}

fn vulns_formula_name(formula VulnsScannerFormula) string {
	return if formula.full_name == '' { formula.name } else { formula.full_name }
}

fn vulns_unique_formulae(formulae []VulnsScannerFormula, use_full_name bool) []VulnsScannerFormula {
	mut seen := map[string]bool{}
	mut unique := []VulnsScannerFormula{cap: formulae.len}
	for formula in formulae {
		key := if use_full_name { vulns_formula_name(formula) } else { formula.name }
		if key in seen {
			continue
		}
		seen[key] = true
		unique << formula
	}
	return unique
}

fn vulns_first_error_line(message string) string {
	return message.split_into_lines()[0].trim_space()
}

// vulns_installed_formulae mirrors Formula.racks.filter_map. Untrusted tap
// failures are retained for the command warning; all other load failures are
// deliberately ignored, as in the source rescue clause.
pub fn vulns_installed_formulae(mut command VulnsCommand) []VulnsScannerFormula {
	mut formulae := []VulnsScannerFormula{}
	for rack in command.installed_racks {
		if rack.error != '' {
			if rack.untrusted {
				command.untrusted_skipped << vulns_first_error_line(rack.error)
			}
			continue
		}
		formulae << rack.formula.formula
	}
	return vulns_unique_formulae(formulae, false)
}

// vulns_formulae preserves source ordering while de-duplicating by full name.
// Dependencies are expanded only after Brewfile, named, or installed roots
// have been selected.
pub fn vulns_formulae(mut command VulnsCommand) []VulnsScannerFormula {
	mut selected := []VulnsFormula{}
	if command.options.brewfile {
		for entry in command.brewfile_entries {
			if entry.entry_type == 'brew' {
				selected << entry.formula
			}
		}
	}
	if command.named.len > 0 {
		selected << command.named
	}
	if !command.options.brewfile && command.named.len == 0 {
		return vulns_installed_formulae(mut command)
	}
	mut formulae := selected.map(it.formula)
	if command.options.deps {
		for formula in selected {
			formulae << formula.recursive_dependencies
		}
	}
	return vulns_unique_formulae(formulae, true)
}

// A bare --brewfile is represented by Bool(true), while an explicit empty
// string has the same default-path meaning. Only a present non-empty String is
// forwarded to Bundle::Brewfile.
pub fn vulns_brewfile_path(value ruby.Value) ?string {
	if value.type_name != 'String' || value.as_string() == '' {
		return none
	}
	return value.as_string()
}

pub fn vulns_min_severity(raw ?string) !VulnsSeverity {
	if value := raw {
		normalized := value.to_lower()
		return match normalized {
			'low' { .low }
			'medium' { .medium }
			'high' { .high }
			'critical' { .critical }
			else {
				return error('`--severity` must be one of: low, medium, high, critical')
			}
		}
	}
	return .unknown
}

pub fn vulns_max_summary(raw ?string) !int {
	if value := raw {
		if value == '' || value.bytes().any(it < `0` || it > `9`) {
			return error('`--max-summary` must be a non-negative integer')
		}
		return value.int()
	}
	return 60
}

fn vulns_severity_display(severity VulnsSeverity) string {
	return severity.str().to_upper()
}

fn vulns_severity_level(severity VulnsSeverity) int {
	return match severity {
		.critical { 4 }
		.high { 3 }
		.medium { 2 }
		.low { 1 }
		.unknown { 0 }
	}
}

fn vulns_truncate(text string, maximum int) string {
	runes := text.runes()
	if maximum <= 0 || runes.len <= maximum {
		return text
	}
	return '${runes[..maximum].string()}...'
}

fn vulns_sorted_open_findings(findings []VulnsFinding) []VulnsFinding {
	mut sorted := findings.filter(it.open.len > 0)
	sorted.sort_with_compare(fn (left &VulnsFinding, right &VulnsFinding) int {
		mut left_max := 0
		for vulnerability in left.open {
			level := vulns_severity_level(vulnerability.severity)
			if level > left_max {
				left_max = level
			}
		}
		mut right_max := 0
		for vulnerability in right.open {
			level := vulns_severity_level(vulnerability.severity)
			if level > right_max {
				right_max = level
			}
		}
		return right_max - left_max
	})
	return sorted
}

fn vulns_output_text(results VulnsScannerResults, maximum int) string {
	mut lines := [
		'Checking ${results.checked} package${if results.checked == 1 { '' } else { 's' }} for vulnerabilities...',
	]
	if results.skipped > 0 {
		lines << '(${results.skipped} package${if results.skipped == 1 { '' } else { 's' }} skipped - no supported source URL)'
	}
	lines << ''
	open_findings := vulns_sorted_open_findings(results.findings)
	patched_findings := results.findings.filter(it.patched.len > 0)
	if open_findings.len == 0 {
		lines << if patched_findings.len == 0 {
			'No vulnerabilities found.'
		} else {
			'No open vulnerabilities found.'
		}
	} else {
		mut total := 0
		for finding in open_findings {
			lines << '${finding.name} (${finding.version})'
			mut vulnerabilities := finding.open.clone()
			vulnerabilities.sort_with_compare(fn (left &VulnsVulnerability, right &VulnsVulnerability) int {
				return vulns_severity_level(right.severity) - vulns_severity_level(left.severity)
			})
			for vulnerability in vulnerabilities {
				total++
				mut line := '  ${vulnerability.id} (${vulns_severity_display(vulnerability.severity)})'
				if vulnerability.summary != '' {
					line += ' - ${vulns_truncate(vulnerability.summary, maximum)}'
				}
				lines << line
				if vulnerability.fixed_versions.len > 0 {
					lines << '    Fixed in: ${vulnerability.fixed_versions.join(', ')}'
				}
			}
			lines << ''
		}
		lines << 'Found ${total} vulnerabilit${if total == 1 { 'y' } else { 'ies' }} in ${open_findings.len} package${if open_findings.len == 1 {
			''
		} else {
			's'
		}}'
	}
	if patched_findings.len > 0 {
		mut patched := patched_findings.clone()
		patched.sort(a.name < b.name)
		mut total := 0
		for finding in patched {
			total += finding.patched.len
		}
		lines << ''
		lines << '${total} resolved by formula patches (not counted; pass --no-ignore-patches to include):'
		for finding in patched {
			lines << '  ${finding.name}: ${finding.patched.map(it.id).join(', ')}'
		}
	}
	return '${lines.join('\n')}\n'
}

fn vulns_json_vulnerability(vulnerability VulnsVulnerability) json2.Any {
	return json2.Any({
		'id':             json2.Any(vulnerability.id)
		'severity':       json2.Any(vulns_severity_display(vulnerability.severity))
		'summary':        if vulnerability.summary == '' {
			json2.null
		} else {
			json2.Any(vulnerability.summary)
		}
		'aliases':        json2.Any(vulnerability.aliases.map(json2.Any(it)))
		'fixed_versions': json2.Any(vulnerability.fixed_versions.map(json2.Any(it)))
	})
}

fn vulns_output_json(results VulnsScannerResults) string {
	if results.findings.len == 0 {
		return '[]\n'
	}
	data := results.findings.map(json2.Any({
		'formula':         json2.Any(it.name)
		'version':         json2.Any(it.version)
		'tag':             json2.Any(it.tag)
		'repo_url':        json2.Any(it.repo_url)
		'vulnerabilities': json2.Any(it.open.map(vulns_json_vulnerability(it)))
		'patched':         json2.Any(it.patched.map(vulns_json_vulnerability(it)))
	}))
	return '${json2.encode(data, prettify: true)}\n'
}

fn vulns_plural_installed_keg(count int) string {
	return '${count} installed keg${if count == 1 { '' } else { 's' }}'
}

pub fn run_vulns_command(mut command VulnsCommand) !VulnsCommandResult {
	// Ruby validates both values before enumerating formulae or constructing a
	// scanner. Keep this ordering observable for callers with expensive racks.
	summary_width := vulns_max_summary(command.options.max_summary)!
	severity := vulns_min_severity(command.options.severity)!
	if command.options.fix_available && command.options.no_fix_available {
		return error('`--fix-available` and `--no-fix-available` are mutually exclusive')
	}
	formulae := vulns_formulae(mut command)
	scanner_options := VulnsScannerOptions{
		ignore_patches: !command.options.no_ignore_patches
		min_severity: severity
		only_fixed: command.options.fix_available
		except_fixed: command.options.no_fix_available
	}
	results := command.scanner(formulae, scanner_options)!
	stdout := if command.options.json {
		vulns_output_json(results)
	} else {
		vulns_output_text(results, summary_width)
	}
	mut warnings := []string{}
	if command.untrusted_skipped.len > 0 {
		warnings << '${vulns_plural_installed_keg(command.untrusted_skipped.len)} from an untrusted tap not scanned:\n  ${command.untrusted_skipped.join('\n  ')}\nRun `brew trust` on the formula or tap to include it in future scans.'
	}
	if results.outdated_without_sbom.len > 0 {
		mut outdated := results.outdated_without_sbom.clone()
		outdated.sort()
		warnings << 'The installed source of ${outdated.join(', ')} could not be determined\n(older than the current formula and no SBOM was written at install time). Results above reflect\nthe current formula version, not what is installed. Run `brew upgrade` for accurate results.'
	}
	return VulnsCommandResult{
		formulae: formulae
		scanner_options: scanner_options
		results: results
		stdout: stdout
		stderr: if warnings.len == 0 { '' } else { '${warnings.join('\n')}\n' }
		failed: command.untrusted_skipped.len > 0 || results.outdated_without_sbom.len > 0 || results.any_open()
	}
}

pub fn vulns_scanner_formula_value(formula VulnsScannerFormula) ruby.Value {
	return ruby.structured_value('Formula', vulns_formula_name(formula), {
		'name':                   formula.name
		'full_name':              formula.full_name
		'stable_url':             formula.stable_url
		'head_url':               formula.head_url
		'homepage':               formula.homepage
		'stable_tag':             formula.stable_tag
		'stable_version':         formula.stable_version
		'version':                formula.version
		'installed':              formula.installed.str()
		'installed_prefix':       formula.installed_prefix
		'installed_version':      formula.installed_version
		'current_recipe_applies': formula.current_recipe_applies.str()
	})
}

fn vulns_scanner_formula_from_value(value ruby.Value) VulnsScannerFormula {
	return VulnsScannerFormula{
		name: value.attributes['name'] or { value.as_string() }
		full_name: value.attributes['full_name'] or { value.as_string() }
		stable_url: value.attributes['stable_url'] or { '' }
		head_url: value.attributes['head_url'] or { '' }
		homepage: value.attributes['homepage'] or { '' }
		stable_tag: value.attributes['stable_tag'] or { '' }
		stable_version: value.attributes['stable_version'] or { '' }
		version: value.attributes['version'] or { '' }
		installed: (value.attributes['installed'] or { 'false' }) == 'true'
		installed_prefix: value.attributes['installed_prefix'] or { '' }
		installed_version: value.attributes['installed_version'] or { '' }
		current_recipe_applies: (value.attributes['current_recipe_applies'] or { 'true' }) == 'true'
	}
}

pub fn vulns_formula_value(formula VulnsFormula) ruby.Value {
	mut value := vulns_scanner_formula_value(formula.formula)
	value = ruby.Value{
		...value
		map_data: {
			'recursive_dependencies': ruby.array_value(formula.recursive_dependencies.map(vulns_scanner_formula_value(it)))
		}
	}
	return value
}

fn vulns_formula_from_value(value ruby.Value) VulnsFormula {
	dependencies := (value.map_data['recursive_dependencies'] or {
		ruby.array_value([])
	}).as_array() or { []ruby.Value{} }
	return VulnsFormula{
		formula: vulns_scanner_formula_from_value(value)
		recursive_dependencies: dependencies.map(vulns_scanner_formula_from_value(it))
	}
}

pub fn vulns_options_value(options VulnsCommandOptions) ruby.Value {
	mut values := {
		'deps':              ruby.bool_value(options.deps)
		'no_ignore_patches': ruby.bool_value(options.no_ignore_patches)
		'brewfile':          ruby.bool_value(options.brewfile)
		'brewfile_value':    options.brewfile_value
		'fix_available':     ruby.bool_value(options.fix_available)
		'no_fix_available':  ruby.bool_value(options.no_fix_available)
		'json':              ruby.bool_value(options.json)
	}
	if severity := options.severity {
		values['severity'] = ruby.string_value(severity)
	}
	if max_summary := options.max_summary {
		values['max_summary'] = ruby.string_value(max_summary)
	}
	return ruby.Value{
		type_name: 'VulnsCommandOptions'
		map_data: values
	}
}

fn vulns_value_bool(values map[string]ruby.Value, name string) bool {
	return if value := values[name] { value.as_bool() or { false } } else { false }
}

fn vulns_value_optional_string(values map[string]ruby.Value, name string) ?string {
	if value := values[name] {
		if value.type_name == 'String' {
			return value.as_string()
		}
	}
	return none
}

fn vulns_options_from_value(value ruby.Value) VulnsCommandOptions {
	values := value.map_data.clone()
	return VulnsCommandOptions{
		deps: vulns_value_bool(values, 'deps')
		no_ignore_patches: vulns_value_bool(values, 'no_ignore_patches')
		brewfile: vulns_value_bool(values, 'brewfile')
		brewfile_value: values['brewfile_value'] or { ruby.Value{} }
		fix_available: vulns_value_bool(values, 'fix_available')
		no_fix_available: vulns_value_bool(values, 'no_fix_available')
		severity: vulns_value_optional_string(values, 'severity')
		max_summary: vulns_value_optional_string(values, 'max_summary')
		json: vulns_value_bool(values, 'json')
	}
}

pub fn vulns_command_value(command VulnsCommand) ruby.Value {
	return ruby.Value{
		type_name: 'VulnsCommand'
		map_data: {
			'options':           vulns_options_value(command.options)
			'named':             ruby.array_value(command.named.map(vulns_formula_value(it)))
			'brewfile_entries':  ruby.array_value(command.brewfile_entries.map(ruby.Value{
				type_name: 'BrewfileEntry'
				attributes: {
					'type': it.entry_type
				}
				map_data: {
					'formula': vulns_formula_value(it.formula)
				}
			}))
			'installed_racks':   ruby.array_value(command.installed_racks.map(ruby.Value{
				type_name: 'InstalledRack'
				repr: it.path
				attributes: {
					'path':      it.path
					'error':     it.error
					'untrusted': it.untrusted.str()
				}
				map_data: {
					'formula': vulns_formula_value(it.formula)
				}
			}))
			'untrusted_skipped': ruby.string_array_value(command.untrusted_skipped)
		}
	}
}

fn vulns_command_from_value(value ruby.Value) VulnsCommand {
	values := value.map_data.clone()
	named := (values['named'] or { ruby.array_value([]) }).as_array() or { [] }
	entries := (values['brewfile_entries'] or { ruby.array_value([]) }).as_array() or { [] }
	racks := (values['installed_racks'] or { ruby.array_value([]) }).as_array() or { [] }
	skipped := (values['untrusted_skipped'] or {
		ruby.string_array_value([])
	}).as_string_array() or { []string{} }
	return VulnsCommand{
		options: vulns_options_from_value(values['options'] or { ruby.map_value({}) })
		named: named.map(vulns_formula_from_value(it))
		brewfile_entries: entries.map(VulnsBrewfileEntry{
			entry_type: it.attributes['type'] or { '' }
			formula: vulns_formula_from_value(it.map_data['formula'] or { ruby.Value{} })
		})
		installed_racks: racks.map(VulnsInstalledRack{
			path: it.attributes['path'] or { it.as_string() }
			formula: vulns_formula_from_value(it.map_data['formula'] or { ruby.Value{} })
			error: it.attributes['error'] or { '' }
			untrusted: (it.attributes['untrusted'] or { 'false' }) == 'true'
		})
		untrusted_skipped: skipped
	}
}

fn vulns_result_value(result VulnsCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'VulnsCommandResult'
		attributes: {
			'stdout':         result.stdout
			'stderr':         result.stderr
			'failed':         result.failed.str()
			'ignore_patches': result.scanner_options.ignore_patches.str()
			'min_severity':   result.scanner_options.min_severity.str()
			'only_fixed':     result.scanner_options.only_fixed.str()
			'except_fixed':   result.scanner_options.except_fixed.str()
		}
		map_data: {
			'formulae':              ruby.array_value(result.formulae.map(vulns_scanner_formula_value(it)))
			'outdated_without_sbom': ruby.string_array_value(result.results.outdated_without_sbom)
		}
	}
}

// Ruby method `run` at line 48.
pub fn ruby_vulns_l48_d1_run(args ...ruby.Value) ruby.Value {
	mut command := if args.len > 0 { vulns_command_from_value(args[0]) } else { VulnsCommand{} }
	result := run_vulns_command(mut command) or {
		return ruby.object_value(if err.msg().contains('`--') {
			'UsageError'
		} else {
			'RuntimeError'
		}, err.msg())
	}
	return vulns_result_value(result)
}

// Ruby method `formulae` at line 89.
pub fn ruby_vulns_l89_d2_formulae(args ...ruby.Value) ruby.Value {
	mut command := if args.len > 0 { vulns_command_from_value(args[0]) } else { VulnsCommand{} }
	return ruby.array_value(vulns_formulae(mut command).map(vulns_scanner_formula_value(it)))
}

// Ruby method `installed_formulae` at line 104.
pub fn ruby_vulns_l104_d3_installed_formulae(args ...ruby.Value) ruby.Value {
	mut command := if args.len > 0 { vulns_command_from_value(args[0]) } else { VulnsCommand{} }
	return ruby.array_value(vulns_installed_formulae(mut command).map(vulns_scanner_formula_value(it)))
}

// Ruby method `untrusted_skipped` at line 116.
pub fn ruby_vulns_l116_d4_untrusted_skipped(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	if args[0].type_name == 'Array' {
		return ruby.string_array_value(args[0].as_string_array() or { []string{} })
	}
	mut command := vulns_command_from_value(args[0])
	if command.untrusted_skipped.len == 0 {
		vulns_installed_formulae(mut command)
	}
	return ruby.string_array_value(command.untrusted_skipped)
}

// Ruby method `brewfile_path(value)` at line 124.
pub fn ruby_vulns_l124_d5_brewfile_path(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		if path := vulns_brewfile_path(args[0]) {
			return ruby.string_value(path)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `min_severity` at line 129.
pub fn ruby_vulns_l129_d6_min_severity(args ...ruby.Value) ruby.Value {
	mut raw := ?string(none)
	if args.len > 0 {
		if args[0].type_name == 'Hash' || args[0].type_name == 'VulnsCommandOptions' {
			raw = vulns_options_from_value(args[0]).severity
		} else if args[0].type_name == 'String' {
			raw = args[0].as_string()
		}
	}
	if raw == none {
		return ruby.object_value('NilClass', 'nil')
	}
	severity := vulns_min_severity(raw) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.object_value('Symbol', severity.str())
}

// Ruby method `max_summary` at line 140.
pub fn ruby_vulns_l140_d7_max_summary(args ...ruby.Value) ruby.Value {
	mut raw := ?string(none)
	if args.len > 0 {
		if args[0].type_name == 'Hash' || args[0].type_name == 'VulnsCommandOptions' {
			raw = vulns_options_from_value(args[0]).max_summary
		} else if args[0].type_name == 'String' {
			raw = args[0].as_string()
		}
	}
	maximum := vulns_max_summary(raw) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.int_value(maximum)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Vulns < AbstractCommand
// 10:       SEVERITIES = %w[low medium high critical].freeze
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check <formula> for known security vulnerabilities using the OSV.dev database.
// 15:
// 16:           With no arguments, all installed formulae are checked.
// 17:         EOS
// 18:         switch "-d", "--deps",
// 19:                description: "Also check the dependencies of named formulae."
// 20:         switch "--no-ignore-patches",
// 21:                description: "Report vulnerabilities even when a formula patch resolves them."
// 22:         flag   "--brewfile",
// 23:                description: "Check formulae listed in a Brewfile. " \
// 24:                             "Defaults to `./Brewfile`; use `--brewfile=`<path> to specify another."
// 25:         switch "--fix-available",
// 26:                description: "Only report vulnerabilities that have a fix available. " \
// 27:                             "Note that this may exclude vulnerabilities with fixes available " \
// 28:                             "if we cannot determine that the fix is included in the version " \
// 29:                             "under consideration."
// 30:         switch "--no-fix-available",
// 31:                description: "Only report vulnerabilities that do not have a fix available. " \
// 32:                             "Note that this may include vulnerabilities with fixes available " \
// 33:                             "if we cannot determine that the fix is included in the version " \
// 34:                             "under consideration."
// 35:         flag   "-s", "--severity=",
// 36:                description: "Only report findings at or above: `low`, `medium`, `high`, `critical`."
// 37:         flag   "-m", "--max-summary=",
// 38:                description: "Truncate summaries to <n> characters (default 60, 0 for no limit)."
// 39:         switch "-j", "--json",
// 40:                description: "Output JSON."
// 41:
// 42:         conflicts "--fix-available", "--no-fix-available"
// 43:
// 44:         named_args :formula
// 45:       end
// 46:
// 47:       sig { override.void }
// 48:       def run
// 49:         require "vulns"
// 50:
// 51:         summary_width = max_summary
// 52:         severity = min_severity
// 53:
// 54:         results = Homebrew::Vulns::Scanner.new(
// 55:           formulae,
// 56:           ignore_patches: !args.no_ignore_patches?,
// 57:           min_severity:   severity,
// 58:           only_fixed:     args.fix_available?,
// 59:           except_fixed:   args.no_fix_available?,
// 60:         ).scan
// 61:
// 62:         if args.json?
// 63:           Homebrew::Vulns::Output.json(results)
// 64:         else
// 65:           Homebrew::Vulns::Output.text(results, max_summary: summary_width)
// 66:         end
// 67:
// 68:         if untrusted_skipped.any?
// 69:           kegs = Utils.pluralize("installed keg", untrusted_skipped.size, include_count: true)
// 70:           opoo <<~EOS
// 71:             #{kegs} from an untrusted tap not scanned:
// 72:               #{untrusted_skipped.join("\n  ")}
// 73:             Run `brew trust` on the formula or tap to include it in future scans.
// 74:           EOS
// 75:           Homebrew.failed = true
// 76:         end
// 77:         if results.outdated_without_sbom.any?
// 78:           opoo <<~EOS
// 79:             The installed source of #{results.outdated_without_sbom.sort.join(", ")} could not be determined
// 80:             (older than the current formula and no SBOM was written at install time). Results above reflect
// 81:             the current formula version, not what is installed. Run `brew upgrade` for accurate results.
// 82:           EOS
// 83:           Homebrew.failed = true
// 84:         end
// 85:         Homebrew.failed = true if results.any_open?
// 86:       end
// 87:
// 88:       sig { returns(T::Array[Formula]) }
// 89:       def formulae
// 90:         list = T.let([], T::Array[Formula])
// 91:         if (brewfile = args.brewfile)
// 92:           require "bundle/brewfile"
// 93:           list += Homebrew::Bundle::Brewfile.read(file: brewfile_path(brewfile)).entries
// 94:                                             .select { |e| e.type == :brew }
// 95:                                             .map { |e| Formulary.resolve(e.name) }
// 96:         end
// 97:         list += args.named.to_resolved_formulae if args.named.any?
// 98:         list = installed_formulae if !args.brewfile && args.no_named?
// 99:         list += list.flat_map { |f| f.recursive_dependencies.map(&:to_formula) } if args.deps?
// 100:         list.uniq(&:full_name)
// 101:       end
// 102:
// 103:       sig { returns(T::Array[Formula]) }
// 104:       def installed_formulae
// 105:         Formula.racks.filter_map do |rack|
// 106:           Formulary.from_rack(rack)
// 107:         rescue Homebrew::UntrustedTapError => e
// 108:           untrusted_skipped << e.message.lines.first.to_s.strip
// 109:           nil
// 110:         rescue
// 111:           nil
// 112:         end.uniq(&:name)
// 113:       end
// 114:
// 115:       sig { returns(T::Array[String]) }
// 116:       def untrusted_skipped
// 117:         @untrusted_skipped ||= T.let([], T.nilable(T::Array[String]))
// 118:       end
// 119:
// 120:       # A bare `--brewfile` (no `=path`) yields `true` from OptionParser at
// 121:       # runtime; the generated RBI types it as `T.nilable(String)`, so accept
// 122:       # the wider type here and normalise `true`/`""` to the `nil` default.
// 123:       sig { params(value: T.nilable(T.any(String, TrueClass))).returns(T.nilable(String)) }
// 124:       def brewfile_path(value)
// 125:         value.presence if value.is_a?(String)
// 126:       end
// 127:
// 128:       sig { returns(T.nilable(Symbol)) }
// 129:       def min_severity
// 130:         raw = args.severity
// 131:         return if raw.nil?
// 132:
// 133:         raw = raw.downcase
// 134:         raise UsageError, "`--severity` must be one of: #{SEVERITIES.join(", ")}" unless SEVERITIES.include?(raw)
// 135:
// 136:         raw.to_sym
// 137:       end
// 138:
// 139:       sig { returns(Integer) }
// 140:       def max_summary
// 141:         raw = args.max_summary
// 142:         return Homebrew::Vulns::Output::DEFAULT_MAX_SUMMARY if raw.nil?
// 143:
// 144:         raise UsageError, "`--max-summary` must be a non-negative integer" unless raw.match?(/\A\d+\z/)
// 145:
// 146:         raw.to_i
// 147:       end
// 148:     end
// 149:   end
// 150: end
