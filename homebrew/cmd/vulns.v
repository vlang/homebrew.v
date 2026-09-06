module cmd

import ruby
import x.json2

// Translated from Homebrew/brew `cmd/vulns.rb`.

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
