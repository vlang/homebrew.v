module vulns

import os
import x.json2

// Translated from Homebrew/brew `vulns/scanner.rb`.
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
