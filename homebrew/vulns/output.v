module vulns

import x.json2

// Translated from Homebrew/brew `vulns/output.rb`.
pub const output_default_max_summary = 60

pub enum OutputSeverity {
	unknown
	low
	medium
	high
	critical
}

pub struct OutputVulnerability {
pub:
	id             string
	severity       OutputSeverity
	summary        ?string
	aliases        []string
	fixed_versions []string
}

pub struct OutputFinding {
pub:
	name     string
	version  string
	tag      string
	repo_url string
	open     []OutputVulnerability
	patched  []OutputVulnerability
}

pub struct OutputResults {
pub:
	findings []OutputFinding
	checked  int
	skipped  int
}

pub struct OutputTableRow {
pub:
	formula        string
	version        string
	vulnerability  string
	severity       OutputSeverity
	severity_label string
	summary        ?string
	fixed_versions []string
}

pub struct OutputTable {
pub:
	rows []OutputTableRow
}

pub struct OutputVulnerabilityJson {
pub:
	id             string
	severity       string
	summary        ?string @[json_null]
	aliases        []string
	fixed_versions []string
}

pub struct OutputFindingJson {
pub:
	formula         string
	version         string
	tag             string
	repo_url        string
	vulnerabilities []OutputVulnerabilityJson
	patched         []OutputVulnerabilityJson
}

pub struct OutputSarifMessage {
pub:
	text string
}

pub struct OutputSarifArtifactLocation {
pub:
	uri string
}

pub struct OutputSarifPhysicalLocation {
pub:
	artifact_location OutputSarifArtifactLocation @[json: 'artifactLocation']
}

pub struct OutputSarifLocation {
pub:
	physical_location OutputSarifPhysicalLocation @[json: 'physicalLocation']
}

pub struct OutputSarifResult {
pub:
	rule_id   string @[json: 'ruleId']
	level     string
	message   OutputSarifMessage
	locations []OutputSarifLocation
}

pub struct OutputSarifDriver {
pub:
	name string
}

pub struct OutputSarifTool {
pub:
	driver OutputSarifDriver
}

pub struct OutputSarifRun {
pub:
	tool    OutputSarifTool
	results []OutputSarifResult
}

pub struct OutputSarifDocument {
pub:
	schema  string @[json: '$schema']
	version string
	runs    []OutputSarifRun
}

pub fn output_severity(value ?string) OutputSeverity {
	if raw := value {
		return match raw.to_upper() {
			'CRITICAL' { .critical }
			'HIGH' { .high }
			'MEDIUM', 'MODERATE' { .medium }
			'LOW' { .low }
			else { .unknown }
		}
	}
	return .unknown
}

pub fn (severity OutputSeverity) display() string {
	return match severity {
		.critical { 'CRITICAL' }
		.high { 'HIGH' }
		.medium { 'MEDIUM' }
		.low { 'LOW' }
		.unknown { 'UNKNOWN' }
	}
}

pub fn (severity OutputSeverity) level() int {
	return match severity {
		.critical { 4 }
		.high { 3 }
		.medium { 2 }
		.low { 1 }
		.unknown { 0 }
	}
}

pub fn new_output_vulnerability(id string, severity ?string, summary ?string, aliases []string,
	fixed_versions []string) OutputVulnerability {
	return OutputVulnerability{
		id: id
		severity: output_severity(severity)
		summary: summary
		aliases: aliases.clone()
		fixed_versions: fixed_versions.clone()
	}
}

pub fn new_output_finding(name string, version string, tag string, repo_url string,
	open []OutputVulnerability, patched []OutputVulnerability) OutputFinding {
	return OutputFinding{
		name: name
		version: version
		tag: tag
		repo_url: repo_url
		open: open.clone()
		patched: patched.clone()
	}
}

pub fn new_output_results(findings []OutputFinding, checked int, skipped int) OutputResults {
	return OutputResults{
		findings: findings.clone()
		checked: checked
		skipped: skipped
	}
}

fn output_plural(noun string, count int) string {
	return '${count} ${noun}${if count == 1 { '' } else { 's' }}'
}

fn output_vulnerability_plural(count int) string {
	return if count == 1 { '1 vulnerability' } else { '${count} vulnerabilities' }
}

fn output_sorted_vulnerabilities(values []OutputVulnerability) []OutputVulnerability {
	mut sorted := values.clone()
	// Insertion sort deliberately retains source order for equal severities, as
	// Ruby's sort_by does.
	for index in 1 .. sorted.len {
		mut cursor := index
		for cursor > 0 && sorted[cursor - 1].severity.level() < sorted[cursor].severity.level() {
			sorted[cursor - 1], sorted[cursor] = sorted[cursor], sorted[cursor - 1]
			cursor--
		}
	}
	return sorted
}

fn output_finding_max_severity(finding OutputFinding) int {
	mut highest := 0
	for vulnerability in finding.open {
		if vulnerability.severity.level() > highest {
			highest = vulnerability.severity.level()
		}
	}
	return highest
}

fn output_sorted_open_findings(findings []OutputFinding) []OutputFinding {
	mut sorted := findings.filter(it.open.len > 0)
	for index in 1 .. sorted.len {
		mut cursor := index
		for cursor > 0 && output_finding_max_severity(sorted[cursor - 1]) < output_finding_max_severity(sorted[cursor]) {
			sorted[cursor - 1], sorted[cursor] = sorted[cursor], sorted[cursor - 1]
			cursor--
		}
	}
	return sorted
}

pub fn output_table(results OutputResults) OutputTable {
	mut rows := []OutputTableRow{}
	for finding in output_sorted_open_findings(results.findings) {
		for vulnerability in output_sorted_vulnerabilities(finding.open) {
			rows << OutputTableRow{
				formula: finding.name
				version: finding.version
				vulnerability: vulnerability.id
				severity: vulnerability.severity
				severity_label: vulnerability.severity.display()
				summary: vulnerability.summary
				fixed_versions: vulnerability.fixed_versions.clone()
			}
		}
	}
	return OutputTable{
		rows: rows
	}
}

pub fn output_truncate(text string, max int) string {
	runes := text.runes()
	if max <= 0 || runes.len <= max {
		return text
	}
	return '${runes[..max].string()}...'
}

fn output_csi_end(runes []rune, start int) int {
	for index in start .. runes.len {
		if runes[index] >= `@` && runes[index] <= `~` {
			return index
		}
	}
	return -1
}

fn output_osc_end(runes []rune, start int, eight_bit bool) int {
	for index in start .. runes.len {
		if runes[index] == `\a` || (eight_bit && runes[index] == rune(0x9c)) {
			return index
		}
		if !eight_bit && runes[index] == rune(0x1b) && index + 1 < runes.len && runes[index + 1] == `\\` {
			return index + 1
		}
	}
	return -1
}

pub fn output_sanitize(text string) string {
	runes := text.runes()
	mut clean := []rune{cap: runes.len}
	mut index := 0
	for index < runes.len {
		current := runes[index]
		if current == rune(0x1b) && index + 1 < runes.len && runes[index + 1] == `]` {
			end := output_osc_end(runes, index + 2, false)
			if end >= 0 {
				index = end + 1
				continue
			}
		}
		if current == rune(0x9d) {
			end := output_osc_end(runes, index + 1, true)
			if end >= 0 {
				index = end + 1
				continue
			}
		}
		if current == rune(0x1b) && index + 1 < runes.len && runes[index + 1] == `[` {
			end := output_csi_end(runes, index + 2)
			if end >= 0 {
				index = end + 1
				continue
			}
		}
		if current == rune(0x9b) {
			end := output_csi_end(runes, index + 1)
			if end >= 0 {
				index = end + 1
				continue
			}
		}
		if current == rune(0x1b) || current == `\b` || current == `\r` || current == `\a` || (current >= rune(0x80) && current <= rune(0x9f)) {
			index++
			continue
		}
		clean << current
		index++
	}
	return clean.string()
}

pub fn output_colorize_severity(severity OutputSeverity, display string) string {
	return match severity {
		.critical { '\x1b[1m\x1b[31m${display}\x1b[0m' }
		.high { '\x1b[31m${display}\x1b[0m' }
		.medium { '\x1b[33m${display}\x1b[0m' }
		.low { '\x1b[32m${display}\x1b[0m' }
		.unknown { display }
	}
}

pub fn output_patched_summary(findings []OutputFinding) string {
	mut patched := findings.filter(it.patched.len > 0)
	if patched.len == 0 {
		return ''
	}
	patched.sort(a.name < b.name)
	mut total := 0
	for finding in patched {
		total += finding.patched.len
	}
	mut lines := [
		'',
		'${total} resolved by formula patches (not counted; pass --no-ignore-patches to include):',
	]
	for finding in patched {
		lines << '  ${output_sanitize(finding.name)}: ${finding.patched.map(output_sanitize(it.id)).join(', ')}'
	}
	return '${lines.join('\n')}\n'
}

pub fn output_text(results OutputResults, max_summary int) string {
	mut lines := [
		'Checking ${output_plural('package', results.checked)} for vulnerabilities...',
	]
	if results.skipped > 0 {
		lines << '(${output_plural('package', results.skipped)} skipped - no supported source URL)'
	}
	lines << ''
	open := output_sorted_open_findings(results.findings)
	patched := results.findings.filter(it.patched.len > 0)
	if open.len == 0 {
		lines << if patched.len == 0 {
			'No vulnerabilities found.'
		} else {
			'No open vulnerabilities found.'
		}
		return '${lines.join('\n')}\n${output_patched_summary(patched)}'
	}
	mut total := 0
	for finding in open {
		lines << '${output_sanitize(finding.name)} (${output_sanitize(finding.version)})'
		for vulnerability in output_sorted_vulnerabilities(finding.open) {
			total++
			mut line := '  ${output_sanitize(vulnerability.id)} (${output_colorize_severity(vulnerability.severity, vulnerability.severity.display())})'
			if summary := vulnerability.summary {
				line += ' - ${output_truncate(output_sanitize(summary), max_summary)}'
			}
			lines << line
			if vulnerability.fixed_versions.len > 0 {
				lines << '    Fixed in: ${vulnerability.fixed_versions.map(output_sanitize(it)).join(', ')}'
			}
		}
		lines << ''
	}
	lines << 'Found ${output_vulnerability_plural(total)} in ${output_plural('package', open.len)}'
	return '${lines.join('\n')}\n${output_patched_summary(patched)}'
}

pub fn output_vulnerability_json(vulnerability OutputVulnerability) OutputVulnerabilityJson {
	return OutputVulnerabilityJson{
		id: vulnerability.id
		severity: vulnerability.severity.display()
		summary: vulnerability.summary
		aliases: vulnerability.aliases.clone()
		fixed_versions: vulnerability.fixed_versions.clone()
	}
}

pub fn output_json_data(results OutputResults) []OutputFindingJson {
	return results.findings.map(OutputFindingJson{
		formula: it.name
		version: it.version
		tag: it.tag
		repo_url: it.repo_url
		vulnerabilities: it.open.map(output_vulnerability_json(it))
		patched: it.patched.map(output_vulnerability_json(it))
	})
}

pub fn output_json(results OutputResults) string {
	return '${json2.encode(output_json_data(results), prettify: true)}\n'
}

fn output_sarif_level(severity OutputSeverity) string {
	return match severity {
		.critical, .high { 'error' }
		.medium { 'warning' }
		.low, .unknown { 'note' }
	}
}

pub fn output_sarif_data(results OutputResults) OutputSarifDocument {
	mut sarif_results := []OutputSarifResult{}
	for finding in output_sorted_open_findings(results.findings) {
		for vulnerability in output_sorted_vulnerabilities(finding.open) {
			message := if summary := vulnerability.summary {
				'${vulnerability.id} (${vulnerability.severity.display()}) - ${summary}'
			} else {
				'${vulnerability.id} (${vulnerability.severity.display()})'
			}
			sarif_results << OutputSarifResult{
				rule_id: vulnerability.id
				level: output_sarif_level(vulnerability.severity)
				message: OutputSarifMessage{
					text: message
				}
				locations: [OutputSarifLocation{
					physical_location: OutputSarifPhysicalLocation{
						artifact_location: OutputSarifArtifactLocation{
							uri: finding.repo_url
						}
					}
				}]
			}
		}
	}
	return OutputSarifDocument{
		schema: 'https://json.schemastore.org/sarif-2.1.0.json'
		version: '2.1.0'
		runs: [OutputSarifRun{
			tool: OutputSarifTool{
				driver: OutputSarifDriver{
					name: 'brew-vulns'
				}
			}
			results: sarif_results
		}]
	}
}

pub fn output_sarif(results OutputResults) string {
	return '${json2.encode(output_sarif_data(results), prettify: true)}\n'
}
