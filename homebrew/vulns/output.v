module vulns

import x.json2

// Translated from Homebrew/brew `vulns/output.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.text(results, max_summary: DEFAULT_MAX_SUMMARY, io: $stdout)` at line 15.
pub fn ruby_output_l15_d1_self_text(results OutputResults, max_summary int) string {
	return output_text(results, max_summary)
}

// Ruby method `self.json(results, io: $stdout)` at line 53.
pub fn ruby_output_l53_d2_self_json(results OutputResults) string {
	return output_json(results)
}

// Ruby method `self.vuln_json(vuln)` at line 68.
pub fn ruby_output_l68_d3_self_vuln_json(vulnerability OutputVulnerability) OutputVulnerabilityJson {
	return output_vulnerability_json(vulnerability)
}

// Ruby method `self.patched_summary(patched, io:)` at line 79.
pub fn ruby_output_l79_d4_self_patched_summary(patched []OutputFinding) string {
	return output_patched_summary(patched)
}

// Ruby method `self.truncate(text, max)` at line 91.
pub fn ruby_output_l91_d5_self_truncate(text string, max int) string {
	return output_truncate(text, max)
}

// Ruby method `self.sanitize(text)` at line 104.
pub fn ruby_output_l104_d6_self_sanitize(text string) string {
	return output_sanitize(text)
}

// Ruby method `self.colorize_severity(severity, display)` at line 114.
pub fn ruby_output_l114_d7_self_colorize_severity(severity OutputSeverity, display string) string {
	return output_colorize_severity(severity, display)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "utils/tty"
// 6: require "vulns/scanner"
// 7: require "vulns/vulnerability"
// 8:
// 9: module Homebrew
// 10:   module Vulns
// 11:     module Output
// 12:       DEFAULT_MAX_SUMMARY = 60
// 13:
// 14:       sig { params(results: Scanner::Results, max_summary: Integer, io: T.any(IO, StringIO)).void }
// 15:       def self.text(results, max_summary: DEFAULT_MAX_SUMMARY, io: $stdout)
// 16:         io.puts "Checking #{Utils.pluralize("package", results.checked, include_count: true)} for vulnerabilities..."
// 17:         if results.skipped.positive?
// 18:           io.puts "(#{Utils.pluralize("package", results.skipped, include_count: true)} " \
// 19:                   "skipped - no supported source URL)"
// 20:         end
// 21:         io.puts
// 22:
// 23:         open = results.findings.select { |f| f.open.any? }
// 24:         patched = results.findings.select { |f| f.patched.any? }
// 25:
// 26:         if open.empty?
// 27:           io.puts patched.empty? ? "No vulnerabilities found." : "No open vulnerabilities found."
// 28:           patched_summary(patched, io:)
// 29:           return
// 30:         end
// 31:
// 32:         total = 0
// 33:         open.sort_by { |f| -f.open.map(&:severity_level).max }.each do |f|
// 34:           io.puts "#{sanitize(f.name)} (#{sanitize(f.version)})"
// 35:           f.open.sort_by { |v| -v.severity_level }.each do |v|
// 36:             total += 1
// 37:             line = "  #{sanitize(v.id)} (#{colorize_severity(v.severity, v.severity_display)})"
// 38:             summary = v.summary
// 39:             line += " - #{truncate(sanitize(summary), max_summary)}" if summary
// 40:             io.puts line
// 41:             io.puts "    Fixed in: #{v.fixed_versions.map { |s| sanitize(s) }.join(", ")}" if v.fixed_versions.any?
// 42:           end
// 43:           io.puts
// 44:         end
// 45:
// 46:         io.puts "Found #{Utils.pluralize("vulnerabilit", total, plural: "ies", singular: "y",
// 47: include_count: true)} " \
// 48:                 "in #{Utils.pluralize("package", open.size, include_count: true)}"
// 49:         patched_summary(patched, io:)
// 50:       end
// 51:
// 52:       sig { params(results: Scanner::Results, io: T.any(IO, StringIO)).void }
// 53:       def self.json(results, io: $stdout)
// 54:         data = results.findings.map do |f|
// 55:           {
// 56:             formula:         f.name,
// 57:             version:         f.version,
// 58:             tag:             f.tag,
// 59:             repo_url:        f.repo_url,
// 60:             vulnerabilities: f.open.map { |v| vuln_json(v) },
// 61:             patched:         f.patched.map { |v| vuln_json(v) },
// 62:           }
// 63:         end
// 64:         io.puts JSON.pretty_generate(data)
// 65:       end
// 66:
// 67:       sig { params(vuln: Vulnerability).returns(T::Hash[Symbol, T.untyped]) }
// 68:       private_class_method def self.vuln_json(vuln)
// 69:         {
// 70:           id:             vuln.id,
// 71:           severity:       vuln.severity_display,
// 72:           summary:        vuln.summary,
// 73:           aliases:        vuln.aliases,
// 74:           fixed_versions: vuln.fixed_versions,
// 75:         }
// 76:       end
// 77:
// 78:       sig { params(patched: T::Array[Scanner::Finding], io: T.any(IO, StringIO)).void }
// 79:       private_class_method def self.patched_summary(patched, io:)
// 80:         return if patched.empty?
// 81:
// 82:         total = patched.sum { |f| f.patched.size }
// 83:         io.puts
// 84:         io.puts "#{total} resolved by formula patches (not counted; pass --no-ignore-patches to include):"
// 85:         patched.sort_by(&:name).each do |f|
// 86:           io.puts "  #{sanitize(f.name)}: #{f.patched.map { |v| sanitize(v.id) }.join(", ")}"
// 87:         end
// 88:       end
// 89:
// 90:       sig { params(text: String, max: Integer).returns(String) }
// 91:       private_class_method def self.truncate(text, max)
// 92:         return text if max <= 0 || text.length <= max
// 93:
// 94:         "#{text.slice(0, max)}..."
// 95:       end
// 96:
// 97:       OSC_7BIT = /\e\][^\a\e]*(?:\a|\e\\)/
// 98:       OSC_8BIT = /\u{009d}[^\a\u{009c}]*(?:\a|\u{009c})/
// 99:       CSI_7BIT = %r{\e\[[0-?]*[ -/]*[@-~]}
// 100:       CSI_8BIT = %r{\u{009b}[0-?]*[ -/]*[@-~]}
// 101:       private_constant :OSC_7BIT, :OSC_8BIT, :CSI_7BIT, :CSI_8BIT
// 102:
// 103:       sig { params(text: T.untyped).returns(String) }
// 104:       private_class_method def self.sanitize(text)
// 105:         text.to_s
// 106:             .gsub(OSC_7BIT, "")
// 107:             .gsub(OSC_8BIT, "")
// 108:             .gsub(CSI_7BIT, "")
// 109:             .gsub(CSI_8BIT, "")
// 110:             .delete("\e\b\r\a\u{0080}-\u{009f}")
// 111:       end
// 112:
// 113:       sig { params(severity: T.nilable(Symbol), display: String).returns(String) }
// 114:       private_class_method def self.colorize_severity(severity, display)
// 115:         case severity
// 116:         when :critical then "#{Tty.bold}#{Tty.red}#{display}#{Tty.reset}"
// 117:         when :high then "#{Tty.red}#{display}#{Tty.reset}"
// 118:         when :medium then "#{Tty.yellow}#{display}#{Tty.reset}"
// 119:         when :low then "#{Tty.green}#{display}#{Tty.reset}"
// 120:         else display
// 121:         end
// 122:       end
// 123:     end
// 124:   end
// 125: end
