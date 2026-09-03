module vulns

import os
import x.json2

// Translated from Homebrew/brew `vulns/scanner.rb`.
// The original source is retained below until every stub has a typed V body.
pub const scanner_sbom_filename = 'sbom.spdx.json'

pub struct ScannerResolve {
pub:
	resolve_type string
	id           string
}

pub struct ScannerPatch {
pub:
	url      string
	resolves []ScannerResolve
}

pub struct ScannerFormula {
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
	serialized_patches     []ScannerPatch
}

pub struct ScannerSbomSource {
pub:
	url     string
	version string
}

pub struct ScannerTarget {
pub:
	repo_url               string
	tag                    string
	version                string
	from_installed_sbom    bool
	current_recipe_applies bool
}

pub struct ScannerEvent {
pub:
	introduced    string
	fixed         string
	last_affected string
	limit         string
}

pub struct ScannerRange {
pub:
	range_type string
	repo       string
	events     []ScannerEvent
}

pub struct ScannerAffectedPackage {
pub:
	ecosystem string
	name      string
}

pub struct ScannerAffected {
pub:
	package  ScannerAffectedPackage
	versions []string
	ranges   []ScannerRange
}

pub struct ScannerVulnerability {
pub:
	id       string
	severity OutputSeverity
	summary  string
	aliases  []string
	affected []ScannerAffected
}

pub struct ScannerFinding {
pub:
	name     string
	version  string
	tag      string
	repo_url string
	open     []ScannerVulnerability
	patched  []ScannerVulnerability
}

pub struct ScannerResults {
pub:
	findings              []ScannerFinding
	checked               int
	skipped               int
	outdated_without_sbom []string
}

pub fn (results ScannerResults) any_open() bool {
	return results.findings.any(it.open.len > 0)
}

pub struct ScannerProvider {

	// batch_results is keyed by `ecosystem\nname\nversion`. Keeping the
	// provider data-only makes scans deterministic and offline in tests while
	// retaining the same query/fetch split as OSV.
pub:
	batch_results map[string][]string
	records       map[string]ScannerVulnerability
	query_error   string
	fetch_errors  map[string]string
}

pub fn scanner_query_key(package OsvPackage) string {
	return '${package.ecosystem}\n${package.name}\n${package.version or { '' }}'
}

pub fn (provider ScannerProvider) query_batch(packages []OsvPackage) ![][]string {
	if provider.query_error != '' {
		return error(provider.query_error)
	}
	mut results := [][]string{cap: packages.len}
	for package in packages {
		results << (provider.batch_results[scanner_query_key(package)] or { []string{} }).clone()
	}
	return results
}

pub fn (provider ScannerProvider) vulnerability(id string) !ScannerVulnerability {
	if message := provider.fetch_errors[id] {
		return error(message)
	}
	return provider.records[id] or { error('OSV vulnerability `${id}` was not provided') }
}

pub struct ScannerOptions {
pub:
	ignore_patches bool = true
	min_severity   OutputSeverity = .unknown
	only_fixed     bool
	except_fixed   bool
}

pub struct Scanner {
pub:
	formulae []ScannerFormula
	options  ScannerOptions
	provider ScannerProvider
pub mut:
	last_queries []OsvPackage
mut:
	targets       map[string]ScannerTarget
	target_misses map[string]bool
}

pub fn new_scanner(formulae []ScannerFormula, options ScannerOptions,
	provider ScannerProvider) Scanner {
	return Scanner{
		formulae: formulae.clone()
		options: options
		provider: provider
		targets: map[string]ScannerTarget{}
		target_misses: map[string]bool{}
	}
}

fn scanner_formula_key(formula ScannerFormula) string {
	return if formula.full_name == '' { formula.name } else { formula.full_name }
}

fn scanner_strip_wayback(url string) string {
	for prefix in ['http://web.archive.org/web/', 'https://web.archive.org/web/'] {
		if url.starts_with(prefix) {
			remainder := url[prefix.len..]
			if slash := remainder.index('/') {
				return remainder[slash + 1..]
			}
		}
	}
	return url
}

fn scanner_url_path(url string, host string) ?string {
	for scheme in ['https://', 'http://'] {
		prefix := '${scheme}${host}'
		if url.starts_with(prefix) {
			if url.len == prefix.len {
				return ''
			}
			if url[prefix.len] != `/` {
				return none
			}
			return url[prefix.len + 1..]
		}
	}
	return none
}

fn scanner_clean_url_path(path string) string {
	mut result := path
	for separator in ['?', '#'] {
		if index := result.index(separator) {
			result = result[..index]
		}
	}
	return result.trim_right('/')
}

pub fn scanner_repo_url(urls ...string) ?string {
	for raw_url in urls {
		if raw_url == '' {
			continue
		}
		url := scanner_strip_wayback(raw_url)
		for host in ['github.com', 'codeberg.org'] {
			path_value := scanner_url_path(url, host) or { continue }
			path := scanner_clean_url_path(path_value)
			segments := path.split('/')
			if segments.len < 2 || segments[0] == '' || segments[1] == '' {
				continue
			}
			mut repo_path := '${segments[0]}/${segments[1]}'.trim_string_right('.git')
			if host == 'github.com' {
				repo_path = repo_path.to_lower()
			}
			return 'https://${host}/${repo_path}'
		}
		for host in ['gitlab.com', 'gitlab.gnome.org', 'gitlab.freedesktop.org', 'invent.kde.org'] {
			path_value := scanner_url_path(url, host) or { continue }
			mut path := scanner_clean_url_path(path_value)
			for marker in ['/-/', '/uploads/', '/wikis/'] {
				if index := path.index(marker) {
					path = path[..index]
				}
			}
			path = path.trim_string_right('.git').trim_right('/')
			segments := path.split('/')
			if segments.len < 2 || segments[0] in ['-', 'api'] || segments.any(it == '') {
				continue
			}
			return 'https://${host}/${path}'
		}
	}
	return none
}

fn scanner_archive_tag(url string, marker string, suffix string) ?string {
	index := url.index(marker) or { return none }
	start := index + marker.len
	if !url.ends_with(suffix) || start >= url.len - suffix.len {
		return none
	}
	value := url[start..url.len - suffix.len]
	if value == '' || value.contains('/') {
		return none
	}
	return value
}

pub fn scanner_tag(url string) ?string {
	if url == '' {
		return none
	}
	for suffix in ['.tar.gz', '.zip'] {
		if tag := scanner_archive_tag(url, '/archive/refs/tags/', suffix) {
			return tag
		}
		if tag := scanner_archive_tag(url, '/archive/', suffix) {
			return tag
		}
	}
	if index := url.index('/releases/download/') {
		remaining := url[index + '/releases/download/'.len..]
		if slash := remaining.index('/') {
			if slash > 0 {
				return remaining[..slash]
			}
		}
	}
	if index := url.index('/tarball/') {
		value := url[index + '/tarball/'.len..]
		if value != '' && !value.contains('/') {
			return value
		}
	}
	return none
}

pub fn scanner_target_repo_url(source_url string, head_url string, homepage string) ?string {
	if repo := scanner_repo_url(source_url, head_url, homepage) {
		return repo
	}
	if scanner_tag(source_url) != none {
		return source_url
	}
	if head_url != '' {
		return head_url
	}
	return none
}

fn scanner_json_string(value json2.Any) string {
	return if value is string { value } else { '' }
}

pub fn scanner_source_from_sbom(prefix string) ?ScannerSbomSource {
	file := os.join_path(prefix, scanner_sbom_filename)
	if !os.is_file(file) {
		return none
	}
	data := json2.decode[json2.Any](os.read_file(file) or { return none }) or { return none }
	if data !is map[string]json2.Any {
		return none
	}
	packages := data.as_map()['packages'] or { return none }
	if packages !is []json2.Any {
		return none
	}
	for raw_package in packages.as_array() {
		if raw_package !is map[string]json2.Any {
			continue
		}
		package := raw_package.as_map()
		spdx_id := if raw := package['SPDXID'] { scanner_json_string(raw) } else { '' }
		if !spdx_id.starts_with('SPDXRef-Archive-') || !spdx_id.ends_with('-src') {
			continue
		}
		mut url := if raw := package['downloadLocation'] { scanner_json_string(raw) } else { '' }
		mut version := if raw := package['versionInfo'] { scanner_json_string(raw) } else { '' }
		if url == 'NOASSERTION' {
			url = ''
		}
		if version == 'NOASSERTION' {
			version = ''
		}
		if url == '' && version == '' {
			return none
		}
		return ScannerSbomSource{
			url: url
			version: version
		}
	}
	return none
}

pub fn scanner_resolved_ids(patches []ScannerPatch) []string {
	mut ids := []string{}
	for patch in patches {
		for resolve in patch.resolves {
			if resolve.resolve_type != 'security' {
				continue
			}
			id := resolve.id.to_upper()
			if id !in ids {
				ids << id
			}
		}
	}
	return ids
}

pub fn (scanner Scanner) build_target(formula ScannerFormula) ?ScannerTarget {
	stable_repo_url := scanner_target_repo_url(formula.stable_url, formula.head_url, formula.homepage)
	stable_tag := scanner_tag(formula.stable_url) or {
		if formula.stable_tag != '' { formula.stable_tag } else { formula.stable_version }
	}
	if formula.installed {
		installed_version := formula.installed_version
		if formula.installed_prefix != '' {
			if sbom := scanner_source_from_sbom(formula.installed_prefix) {
				repo_url := scanner_target_repo_url(sbom.url, formula.head_url, formula.homepage) or { '' }
				tag := scanner_tag(sbom.url) or {
					if sbom.version != '' { sbom.version } else { installed_version }
				}
				if repo_url != '' && tag != '' {
					return ScannerTarget{
						repo_url: repo_url
						tag: tag
						version: installed_version
						from_installed_sbom: true
						current_recipe_applies: formula.current_recipe_applies
					}
				}
			}
		}
		repo_url := stable_repo_url or { return none }
		if stable_tag == '' {
			return none
		}
		return ScannerTarget{
			repo_url: repo_url
			tag: stable_tag
			version: installed_version
			current_recipe_applies: formula.current_recipe_applies
		}
	}
	repo_url := stable_repo_url or { return none }
	if stable_tag == '' {
		return none
	}
	return ScannerTarget{
		repo_url: repo_url
		tag: stable_tag
		version: if formula.version == '' { formula.stable_version } else { formula.version }
		current_recipe_applies: true
	}
}

pub fn (mut scanner Scanner) target_for(formula ScannerFormula) ?ScannerTarget {
	key := scanner_formula_key(formula)
	if target := scanner.targets[key] {
		return target
	}
	if scanner.target_misses[key] {
		return none
	}
	target := scanner.build_target(formula) or {
		scanner.target_misses[key] = true
		return none
	}
	scanner.targets[key] = target
	return target
}

pub fn (mut scanner Scanner) stale_target(formula ScannerFormula) bool {
	target := scanner.target_for(formula) or { return false }
	return !target.from_installed_sbom && !target.current_recipe_applies
}

fn scanner_normalize_version(version string) string {
	return if version.starts_with('v') || version.starts_with('V') { version[1..] } else { version }
}

struct ScannerInterval {
	lower           string
	upper           string
	upper_inclusive bool
	fix             string
}

fn scanner_intervals(events []ScannerEvent) []ScannerInterval {
	mut result := []ScannerInterval{}
	mut lower := ''
	mut has_lower := false
	for event in events {
		if event.introduced != '' {
			if has_lower {
				result << ScannerInterval{ lower: lower }
			}
			introduced := scanner_normalize_version(event.introduced)
			has_lower = introduced != '0'
			lower = if has_lower { introduced } else { '' }
		} else if event.fixed != '' {
			fixed := scanner_normalize_version(event.fixed)
			result << ScannerInterval{
				lower: if has_lower { lower } else { '' }
				upper: fixed
				fix: fixed
			}
			has_lower = false
			lower = ''
		} else if event.last_affected != '' {
			result << ScannerInterval{
				lower: if has_lower { lower } else { '' }
				upper: scanner_normalize_version(event.last_affected)
				upper_inclusive: true
			}
			has_lower = false
			lower = ''
		} else if event.limit != '' {
			result << ScannerInterval{
				lower: if has_lower { lower } else { '' }
				upper: if event.limit == '*' { '' } else { scanner_normalize_version(event.limit) }
			}
			has_lower = false
			lower = ''
		}
	}
	if has_lower || result.len == 0 {
		result << ScannerInterval{ lower: if has_lower { lower } else { '' } }
	}
	return result
}

fn scanner_interval_strict(target string, interval ScannerInterval) ?bool {
	if interval.lower != '' {
		comparison := compare_semver(target, interval.lower) or { return none }
		if comparison < 0 {
			return false
		}
	}
	if interval.upper != '' {
		comparison := compare_semver(target, interval.upper) or { return none }
		return if interval.upper_inclusive { comparison <= 0 } else { comparison < 0 }
	}
	return true
}

pub fn (vulnerability ScannerVulnerability) identifiers() []string {
	mut ids := [vulnerability.id]
	for alias in vulnerability.aliases {
		if alias !in ids {
			ids << alias
		}
	}
	return ids
}

pub fn (vulnerability ScannerVulnerability) affects_version(version string) bool {
	if vulnerability.affected.len == 0 {
		return true
	}
	target := scanner_normalize_version(version)
	mut checkable := false
	for affected in vulnerability.affected {
		if affected.versions.len > 0 {
			checkable = true
			if affected.versions.any(scanner_normalize_version(it) == target) {
				return true
			}
		}
		for range in affected.ranges {
			if range.range_type != 'SEMVER' {
				return true
			}
			checkable = true
			for interval in scanner_intervals(range.events) {
				inside := scanner_interval_strict(target, interval) or { return true }
				if inside {
					return true
				}
			}
		}
	}
	return !checkable
}

fn scanner_normalized_repo(url string) string {
	return url.to_lower().trim_right('/').trim_string_right('.git').trim_right('/')
}

fn scanner_affected_relevant(affected ScannerAffected, repo_url string) bool {
	if repo_url == '' {
		return true
	}
	if affected.package.ecosystem != '' && affected.package.ecosystem != 'GIT' {
		return false
	}
	git_ranges := affected.ranges.filter(it.range_type == 'GIT')
	if git_ranges.len == 0 {
		return true
	}
	normalized := scanner_normalized_repo(repo_url)
	return git_ranges.any(it.repo == '' || scanner_normalized_repo(it.repo) == normalized)
}

fn scanner_non_semver_fix_available(target string, range ScannerRange) bool {
	if range.events.len == 0 {
		return false
	}
	mut uncomparable := false
	for interval in scanner_intervals(range.events) {
		inside := scanner_interval_strict(target, interval) or {
			uncomparable = true
			continue
		}
		if inside {
			return interval.fix != ''
		}
	}
	if !uncomparable {
		return false
	}
	return range.events.last().fixed != ''
}

pub fn (vulnerability ScannerVulnerability) fix_available(version string, repo_url string) bool {
	if vulnerability.affected.len == 0 {
		return false
	}
	target := scanner_normalize_version(version)
	for affected in vulnerability.affected {
		if !scanner_affected_relevant(affected, repo_url) {
			continue
		}
		mut version_matched := affected.versions.any(scanner_normalize_version(it) == target)
		semver_ranges := affected.ranges.filter(it.range_type == 'SEMVER')
		non_semver_ranges := affected.ranges.filter(it.range_type != 'SEMVER')
		if non_semver_ranges.len > 0 {
			version_matched = true
		}
		mut matched_semver_range := false
		mut fix_found := false
		for range in semver_ranges {
			for interval in scanner_intervals(range.events) {
				inside := scanner_interval_strict(target, interval) or { continue }
				if inside {
					matched_semver_range = true
					if interval.fix != '' {
						fix_found = true
					}
				}
			}
		}
		version_matched = version_matched || matched_semver_range
		if !version_matched {
			continue
		}
		if fix_found {
			return true
		}
		for range in non_semver_ranges {
			if scanner_non_semver_fix_available(target, range) {
				return true
			}
		}
	}
	return false
}

pub fn (scanner Scanner) fetch_vulnerabilities(ids []string) ![]ScannerVulnerability {
	mut records := []ScannerVulnerability{cap: ids.len}
	for id in ids {
		records << scanner.provider.vulnerability(id)!
	}
	return records
}

pub fn (scanner Scanner) partition_patched(formula ScannerFormula, target ScannerTarget,
	vulnerabilities []ScannerVulnerability) ([]ScannerVulnerability, []ScannerVulnerability) {
	if !scanner.options.ignore_patches || !target.current_recipe_applies {
		return vulnerabilities.clone(), []ScannerVulnerability{}
	}
	resolved := scanner_resolved_ids(formula.serialized_patches)
	if resolved.len == 0 {
		return vulnerabilities.clone(), []ScannerVulnerability{}
	}
	mut open := []ScannerVulnerability{}
	mut patched := []ScannerVulnerability{}
	for vulnerability in vulnerabilities {
		if vulnerability.identifiers().any(it.to_upper() in resolved) {
			patched << vulnerability
		} else {
			open << vulnerability
		}
	}
	return open, patched
}

pub fn (mut scanner Scanner) scan() !ScannerResults {
	mut queryable := []ScannerFormula{}
	mut targets := []ScannerTarget{}
	mut skipped := 0
	mut outdated_without_sbom := []string{}
	for formula in scanner.formulae {
		target := scanner.target_for(formula) or {
			skipped++
			continue
		}
		queryable << formula
		targets << target
		if !target.from_installed_sbom && !target.current_recipe_applies {
			outdated_without_sbom << formula.name
		}
	}
	if queryable.len == 0 {
		return ScannerResults{
			skipped: skipped
			outdated_without_sbom: outdated_without_sbom
		}
	}
	scanner.last_queries = targets.map(OsvPackage{
		ecosystem: 'GIT'
		name: it.repo_url
		version: it.tag
	})
	batch := scanner.provider.query_batch(scanner.last_queries)!
	if batch.len != queryable.len {
		return error('OSV query batch returned ${batch.len} results for ${queryable.len} targets')
	}
	mut findings := []ScannerFinding{}
	for index, formula in queryable {
		ids := batch[index]
		if ids.len == 0 {
			continue
		}
		target := targets[index]
		mut vulnerabilities := scanner.fetch_vulnerabilities(ids)!
		vulnerabilities = vulnerabilities.filter(it.affects_version(target.tag))
		vulnerabilities = vulnerabilities.filter(it.severity.level() >= scanner.options.min_severity.level())
		if scanner.options.only_fixed {
			vulnerabilities = vulnerabilities.filter(it.fix_available(target.tag, target.repo_url))
		}
		if scanner.options.except_fixed {
			vulnerabilities = vulnerabilities.filter(!it.fix_available(target.tag, target.repo_url))
		}
		if vulnerabilities.len == 0 {
			continue
		}
		open, patched := scanner.partition_patched(formula, target, vulnerabilities)
		if open.len == 0 && patched.len == 0 {
			continue
		}
		findings << ScannerFinding{
			name: formula.name
			version: target.version
			tag: target.tag
			repo_url: target.repo_url
			open: open
			patched: patched
		}
	}
	return ScannerResults{
		findings: findings
		checked: queryable.len
		skipped: skipped
		outdated_without_sbom: outdated_without_sbom
	}
}

// Ruby method `self.target_repo_url(source_url, head_url, homepage)` at line 16.
pub fn ruby_scanner_l16_d1_self_target_repo_url(source_url string, head_url string,
	homepage string) ?string {
	return scanner_target_repo_url(source_url, head_url, homepage)
}

// Ruby method `self.source_from_sbom(prefix)` at line 27.
pub fn ruby_scanner_l27_d2_self_source_from_sbom(prefix string) ?ScannerSbomSource {
	return scanner_source_from_sbom(prefix)
}

// Ruby method `self.resolved_ids(serialized_patches)` at line 47.
pub fn ruby_scanner_l47_d3_self_resolved_ids(patches []ScannerPatch) []string {
	return scanner_resolved_ids(patches)
}

// Ruby attr_reader `attr_reader :findings` at line 59.
pub fn ruby_scanner_l59_d4_findings(results ScannerResults) []ScannerFinding {
	return results.findings.clone()
}

// Ruby attr_reader `attr_reader :checked, :skipped` at line 62.
pub fn ruby_scanner_l62_d5_checked(results ScannerResults) int {
	return results.checked
}

// Ruby attr_reader `attr_reader :checked, :skipped` at line 62.
pub fn ruby_scanner_l62_d6_skipped(results ScannerResults) int {
	return results.skipped
}

// Ruby attr_reader `attr_reader :outdated_without_sbom` at line 65.
pub fn ruby_scanner_l65_d7_outdated_without_sbom(results ScannerResults) []string {
	return results.outdated_without_sbom.clone()
}

// Ruby method `initialize(findings:, checked:, skipped:, outdated_without_sbom: [])` at line 71.
pub fn ruby_scanner_l71_d8_initialize(findings []ScannerFinding, checked int, skipped int,
	outdated_without_sbom []string) ScannerResults {
	return ScannerResults{
		findings: findings.clone()
		checked: checked
		skipped: skipped
		outdated_without_sbom: outdated_without_sbom.clone()
	}
}

// Ruby method `any_open?` at line 79.
pub fn ruby_scanner_l79_d9_any_open(results ScannerResults) bool {
	return results.any_open()
}

// Ruby method `initialize(formulae, ignore_patches: true, min_severity: nil, only_fixed: false, except_fixed: false)` at line 97.
pub fn ruby_scanner_l97_d10_initialize(formulae []ScannerFormula, options ScannerOptions,
	provider ScannerProvider) Scanner {
	return new_scanner(formulae, options, provider)
}

// Ruby method `scan` at line 110.
pub fn ruby_scanner_l110_d11_scan(mut scanner Scanner) !ScannerResults {
	return scanner.scan()
}

// Ruby method `target_for(formula)` at line 149.
pub fn ruby_scanner_l149_d12_target_for(mut scanner Scanner,
	formula ScannerFormula) ?ScannerTarget {
	return scanner.target_for(formula)
}

// Ruby method `build_target(formula)` at line 157.
pub fn ruby_scanner_l157_d13_build_target(scanner Scanner,
	formula ScannerFormula) ?ScannerTarget {
	return scanner.build_target(formula)
}

// Ruby method `stale_target?(formula)` at line 194.
pub fn ruby_scanner_l194_d14_stale_target(mut scanner Scanner, formula ScannerFormula) bool {
	return scanner.stale_target(formula)
}

// Ruby method `fetch_vulnerabilities(ids)` at line 202.
pub fn ruby_scanner_l202_d15_fetch_vulnerabilities(scanner Scanner,
	ids []string) ![]ScannerVulnerability {
	return scanner.fetch_vulnerabilities(ids)
}

// Ruby method `partition_patched(formula, target, vulns)` at line 215.
pub fn ruby_scanner_l215_d16_partition_patched(scanner Scanner, formula ScannerFormula,
	target ScannerTarget,
	vulnerabilities []ScannerVulnerability) ([]ScannerVulnerability, []ScannerVulnerability) {
	return scanner.partition_patched(formula, target, vulnerabilities)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "sbom"
// 5: require "vulns/identify"
// 6: require "vulns/osv"
// 7: require "vulns/vulnerability"
// 8:
// 9: module Homebrew
// 10:   module Vulns
// 11:     class Scanner
// 12:       sig {
// 13:         params(source_url: T.nilable(String), head_url: T.nilable(String),
// 14:                homepage: T.nilable(String)).returns(T.nilable(String))
// 15:       }
// 16:       def self.target_repo_url(source_url, head_url, homepage)
// 17:         url = Identify.repo_url(source_url, head_url, homepage)
// 18:         url ||= source_url if Identify.tag(source_url)
// 19:         url ||= head_url
// 20:         url
// 21:       end
// 22:
// 23:       SBOM_SRC_SPDXID = /\ASPDXRef-Archive-.*-src\z/
// 24:       private_constant :SBOM_SRC_SPDXID
// 25:
// 26:       sig { params(prefix: Pathname).returns(T.nilable([T.nilable(String), T.nilable(String)])) }
// 27:       def self.source_from_sbom(prefix)
// 28:         file = prefix/SBOM::FILENAME
// 29:         return unless file.file?
// 30:
// 31:         data = JSON.parse(file.read)
// 32:         src = Array(data["packages"]).find { |p| p["SPDXID"].to_s.match?(SBOM_SRC_SPDXID) }
// 33:         return if src.nil?
// 34:
// 35:         url = src["downloadLocation"]
// 36:         url = nil if url == "NOASSERTION"
// 37:         version = src["versionInfo"]
// 38:         version = nil if version == "NOASSERTION"
// 39:         return if url.nil? && version.nil?
// 40:
// 41:         [url, version]
// 42:       rescue JSON::ParserError
// 43:         nil
// 44:       end
// 45:
// 46:       sig { params(serialized_patches: T::Array[T::Hash[String, T.untyped]]).returns(T::Array[String]) }
// 47:       def self.resolved_ids(serialized_patches)
// 48:         serialized_patches
// 49:           .flat_map { |p| Array(p["resolves"]) }
// 50:           .select { |r| r.is_a?(Hash) && r["type"] == "security" }
// 51:           .map { |r| r["id"].to_s.upcase }
// 52:           .uniq
// 53:       end
// 54:
// 55:       Finding = Struct.new(:name, :version, :tag, :repo_url, :open, :patched, keyword_init: true)
// 56:
// 57:       class Results
// 58:         sig { returns(T::Array[Finding]) }
// 59:         attr_reader :findings
// 60:
// 61:         sig { returns(Integer) }
// 62:         attr_reader :checked, :skipped
// 63:
// 64:         sig { returns(T::Array[String]) }
// 65:         attr_reader :outdated_without_sbom
// 66:
// 67:         sig {
// 68:           params(findings: T::Array[Finding], checked: Integer, skipped: Integer,
// 69:                  outdated_without_sbom: T::Array[String]).void
// 70:         }
// 71:         def initialize(findings:, checked:, skipped:, outdated_without_sbom: [])
// 72:           @findings = findings
// 73:           @checked = checked
// 74:           @skipped = skipped
// 75:           @outdated_without_sbom = outdated_without_sbom
// 76:         end
// 77:
// 78:         sig { returns(T::Boolean) }
// 79:         def any_open?
// 80:           findings.any? { |f| f.open.any? }
// 81:         end
// 82:       end
// 83:
// 84:       MAX_VULN_FETCH_THREADS = 15
// 85:       private_constant :MAX_VULN_FETCH_THREADS
// 86:
// 87:       SEVERITY_LEVELS = T.let(
// 88:         { low: 1, medium: 2, high: 3, critical: 4 }.freeze,
// 89:         T::Hash[Symbol, Integer],
// 90:       )
// 91:       private_constant :SEVERITY_LEVELS
// 92:
// 93:       sig {
// 94:         params(formulae: T::Array[Formula], ignore_patches: T::Boolean, min_severity: T.nilable(Symbol),
// 95:                only_fixed: T::Boolean, except_fixed: T::Boolean).void
// 96:       }
// 97:       def initialize(formulae, ignore_patches: true, min_severity: nil, only_fixed: false, except_fixed: false)
// 98:         @formulae = formulae
// 99:         @ignore_patches = ignore_patches
// 100:         @min_severity_level = T.let(min_severity ? SEVERITY_LEVELS.fetch(min_severity) : 0, Integer)
// 101:         @only_fixed = only_fixed
// 102:         @except_fixed = except_fixed
// 103:       end
// 104:
// 105:       Target = Struct.new(:repo_url, :tag, :version, :from_installed_sbom, :current_recipe_applies,
// 106:                           keyword_init: true)
// 107:       private_constant :Target
// 108:
// 109:       sig { returns(Results) }
// 110:       def scan
// 111:         queryable, skipped = @formulae.partition { |f| target_for(f) }
// 112:         outdated_without_sbom = queryable.select { |f| stale_target?(f) }.map(&:name)
// 113:         if queryable.empty?
// 114:           return Results.new(findings: [], checked: 0, skipped: skipped.size, outdated_without_sbom:)
// 115:         end
// 116:
// 117:         targets = queryable.map { |f| T.must(target_for(f)) }
// 118:         batch = OSV.query_batch(targets.map { |t| { ecosystem: "GIT", name: t.repo_url, version: t.tag } })
// 119:
// 120:         findings = queryable.each_with_index.filter_map do |formula, index|
// 121:           target = targets.fetch(index)
// 122:           ids = batch.fetch(index)
// 123:           next if ids.empty?
// 124:
// 125:           vulns = fetch_vulnerabilities(ids)
// 126:                   .select { |v| v.affects_version?(target.tag) }
// 127:                   .select { |v| v.severity_level >= @min_severity_level }
// 128:           vulns = vulns.select { |v| v.fix_available?(target.tag, target.repo_url) } if @only_fixed
// 129:           vulns = vulns.reject { |v| v.fix_available?(target.tag, target.repo_url) } if @except_fixed
// 130:           next if vulns.empty?
// 131:
// 132:           open, patched = partition_patched(formula, target, vulns)
// 133:           next if open.empty? && patched.empty?
// 134:
// 135:           Finding.new(
// 136:             name:     formula.name,
// 137:             version:  target.version,
// 138:             tag:      target.tag,
// 139:             repo_url: target.repo_url,
// 140:             open:,
// 141:             patched:,
// 142:           )
// 143:         end
// 144:
// 145:         Results.new(findings:, checked: queryable.size, skipped: skipped.size, outdated_without_sbom:)
// 146:       end
// 147:
// 148:       sig { params(formula: Formula).returns(T.nilable(Target)) }
// 149:       def target_for(formula)
// 150:         @targets ||= T.let({}, T.nilable(T::Hash[String, T.nilable(Target)]))
// 151:         @targets.fetch(formula.full_name) do
// 152:           @targets[formula.full_name] = build_target(formula)
// 153:         end
// 154:       end
// 155:
// 156:       sig { params(formula: Formula).returns(T.nilable(Target)) }
// 157:       def build_target(formula)
// 158:         stable = formula.stable
// 159:         stable_url = stable&.url
// 160:         head_url = formula.head&.url
// 161:         homepage = formula.homepage
// 162:
// 163:         stable_repo_url = self.class.target_repo_url(stable_url, head_url, homepage)
// 164:         stable_tag = Identify.tag(stable_url) || stable&.specs&.[](:tag) || stable&.version&.to_s
// 165:
// 166:         if (prefix = formula.any_installed_prefix)
// 167:           installed_pkg_version = formula.any_installed_version
// 168:           installed_version = installed_pkg_version&.version.to_s
// 169:           current_recipe_applies = installed_pkg_version == formula.pkg_version
// 170:
// 171:           if (sbom = self.class.source_from_sbom(prefix))
// 172:             sbom_url, sbom_version = sbom
// 173:             repo_url = self.class.target_repo_url(sbom_url, head_url, homepage)
// 174:             tag = Identify.tag(sbom_url) || sbom_version || installed_version.presence
// 175:             if repo_url && tag
// 176:               return Target.new(repo_url:, tag:, version: installed_version,
// 177:                                 from_installed_sbom: true, current_recipe_applies:)
// 178:             end
// 179:           end
// 180:
// 181:           return if stable_repo_url.nil? || stable_tag.nil?
// 182:
// 183:           return Target.new(repo_url: stable_repo_url, tag: stable_tag, version: installed_version,
// 184:                             from_installed_sbom: false, current_recipe_applies:)
// 185:         end
// 186:
// 187:         return if stable_repo_url.nil? || stable_tag.nil?
// 188:
// 189:         Target.new(repo_url: stable_repo_url, tag: stable_tag, version: formula.version.to_s,
// 190:                    from_installed_sbom: false, current_recipe_applies: true)
// 191:       end
// 192:
// 193:       sig { params(formula: Formula).returns(T::Boolean) }
// 194:       def stale_target?(formula)
// 195:         target = target_for(formula)
// 196:         return false if target.nil? || target.from_installed_sbom
// 197:
// 198:         !target.current_recipe_applies
// 199:       end
// 200:
// 201:       sig { params(ids: T::Array[T::Hash[String, T.untyped]]).returns(T::Array[Vulnerability]) }
// 202:       def fetch_vulnerabilities(ids)
// 203:         records = ids.each_slice(MAX_VULN_FETCH_THREADS).flat_map do |slice|
// 204:           slice
// 205:             .map { |v| Thread.new { OSV.vulnerability(v.fetch("id")) } }
// 206:             .map { |t| T.cast(t.value, T::Hash[String, T.untyped]) }
// 207:         end
// 208:         Vulnerability.from_osv_list(records)
// 209:       end
// 210:
// 211:       sig {
// 212:         params(formula: Formula, target: Target, vulns: T::Array[Vulnerability])
// 213:           .returns([T::Array[Vulnerability], T::Array[Vulnerability]])
// 214:       }
// 215:       def partition_patched(formula, target, vulns)
// 216:         return [vulns, []] unless @ignore_patches
// 217:         # The current formula's `serialized_patches` reflects the recipe on
// 218:         # disk. If the scanned keg was built from an older recipe it may lack a
// 219:         # patch the recipe has since gained, so its `resolves` must not
// 220:         # suppress findings.
// 221:         return [vulns, []] unless target.current_recipe_applies
// 222:
// 223:         resolved = self.class.resolved_ids(formula.serialized_patches)
// 224:         return [vulns, []] if resolved.empty?
// 225:
// 226:         patched, open = vulns.partition do |v|
// 227:           v.identifiers.any? { |id| resolved.include?(id.to_s.upcase) }
// 228:         end
// 229:         [open, patched]
// 230:       end
// 231:     end
// 232:   end
// 233: end
