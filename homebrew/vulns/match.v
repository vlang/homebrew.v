module vulns

import x.json2

// Translated from Homebrew/brew `vulns/match.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum MatchStrategy {
	git
	registry
	cpansa
	distro
}

pub struct MatchRegistryPackage {
pub:
	ecosystem string
	name      string
	version   string
	purl      string
}

pub struct MatchResource {
pub:
	name    string
	url     string
	version string
}

pub struct MatchFormulaSnapshot {
pub:
	pkg_version string
	resources   map[string]string
	loadable    bool = true
}

pub struct MatchFormula {
pub:
	name        string
	pkg_version string
	stable_url  string
	stable_tag  string
	head_url    string
	homepage    string
	resources   []MatchResource
	history     []MatchFormulaSnapshot
}

pub struct MatchIdentity {
pub:
	git_repo          ?string
	git_tag           ?string
	primary_package   ?MatchRegistryPackage
	resource_packages map[string]MatchRegistryPackage
	distro_packages   RepologyDistroMap
}

pub fn (identity MatchIdentity) identifiable() bool {
	return identity.git_repo != none || identity.primary_package != none || identity.resource_packages.len > 0 || identity.distro_packages.len > 0
}

pub struct MatchVulnerability {
pub:
	id               string
	summary          ?string
	details          ?string
	aliases          []string
	upstream         []string
	related          []string
	references       []OsvExportReference
	severity_entries []OsvExportSeverity
	affected         []AdvisoryAffected
}

pub fn (record MatchVulnerability) identifiers() []string {
	mut result := [record.id]
	for alias in record.aliases {
		if alias !in result {
			result << alias
		}
	}
	return result
}

pub fn match_is_cve(id string) bool {
	parts := id.split('-')
	return parts.len == 3 && parts[0] == 'CVE' && parts[1].len == 4 && parts[1].bytes().all(it >= `0` && it <= `9`) && parts[2].len >= 1 && parts[2].bytes().all(it >= `0` && it <= `9`)
}

pub fn (record MatchVulnerability) cve_ids() []string {
	mut result := []string{}
	for id in record.identifiers() {
		if match_is_cve(id) && id !in result {
			result << id
		}
	}
	result.sort()
	return result
}

pub fn (record MatchVulnerability) range_status(ecosystem string, name string,
	version string) ?AdvisoryRangeStatus {
	return AdvisoryRecord{
		id: record.id
		affected: record.affected
	}.range_status(ecosystem, name, version)
}

pub struct MatchEvidence {
pub:
	strategy        MatchStrategy
	ecosystem       string
	name            string
	subject_version ?string
	key             string
	resource        ?string
	advisory        ?CpanSecAdvisory
	source_record   ?MatchVulnerability
}

pub fn (evidence MatchEvidence) with_source(record MatchVulnerability) MatchEvidence {
	if evidence.source_record != none {
		return evidence
	}
	return MatchEvidence{
		...evidence
		source_record: record
	}
}

fn match_strategy_precision(strategy MatchStrategy) int {
	return match strategy {
		.git { 4 }
		.registry { 3 }
		.cpansa { 2 }
		.distro { 1 }
	}
}

fn (evidence MatchEvidence) precision() int {
	return match_strategy_precision(evidence.strategy)
}

pub struct MatchHit {
pub:
	vulnerability MatchVulnerability
	evidence      []MatchEvidence
}

pub fn new_match_hit(vulnerability MatchVulnerability, evidence []MatchEvidence) !MatchHit {
	if evidence.len == 0 {
		return error('Hit requires at least one Evidence')
	}
	mut attached := evidence.map(it.with_source(vulnerability))
	attached.sort(a.precision() > b.precision())
	return MatchHit{
		vulnerability: vulnerability
		evidence: attached
	}
}

pub fn (hit MatchHit) primary_evidence() MatchEvidence {
	return hit.evidence[0]
}

pub fn (hit MatchHit) strategy() MatchStrategy {
	return hit.primary_evidence().strategy
}

pub fn (hit MatchHit) resource() ?string {
	return hit.primary_evidence().resource
}

pub fn (hit MatchHit) canonical_id() string {
	cves := hit.vulnerability.cve_ids()
	return if cves.len > 0 { cves[0] } else { hit.vulnerability.id }
}

pub struct MatchQuery {
pub:
	package  OsvPackage
	evidence MatchEvidence
}

pub struct MatchRangeResult {
pub:
	status   AdvisoryRangeStatus
	evidence MatchEvidence
}

pub struct MatchMatcher {
pub:
	repology                 RepologyDatabase
	cpan_sec                 CpanSecDatabase
	bulk                     bool
	fallback_distro_packages map[string]RepologyDistroMap
pub mut:
	vulnerability_cache map[string]?MatchVulnerability
}

pub fn new_matcher(repology RepologyDatabase, cpan_sec CpanSecDatabase,
	bulk bool) MatchMatcher {
	return MatchMatcher{
		repology: repology
		cpan_sec: cpan_sec
		bulk: bulk
	}
}

pub fn (matcher MatchMatcher) distro_packages_for(name string) RepologyDistroMap {
	indexed := matcher.repology.distro_packages_for(name)
	if indexed.len > 0 || matcher.bulk {
		return indexed
	}
	return (matcher.fallback_distro_packages[name] or { RepologyDistroMap{} }).clone()
}

fn match_repo_url(urls ...string) ?string {
	for raw in urls {
		if raw == '' {
			continue
		}
		for host in ['github.com/', 'gitlab.com/'] {
			index := raw.index(host) or { continue }
			mut path := raw[index + host.len..].all_before('?').all_before('#')
			for boundary in ['/archive/', '/releases/', '/-/archive/', '/refs/'] {
				path = path.all_before(boundary)
			}
			path = path.trim_string_right('/').trim_string_right('.git')
			parts := path.split('/')
			if parts.len >= 2 {
				return 'https://${host.trim_string_right('/')}/${parts[0]}/${parts[1]}'
			}
		}
	}
	return none
}

fn match_filename(url string) string {
	return url.all_before('?').all_before('#').trim_string_right('/').all_after_last('/')
}

fn match_registry_package(url string) ?MatchRegistryPackage {
	filename := match_filename(url)
	if url.contains('pythonhosted.org') || url.contains('pypi.org') {
		base := filename.replace('.tar.gz', '').replace('.tar.bz2', '').replace('.zip', '')
		mut cut := -1
		for i, character in base {
			if character == `-` && i + 1 < base.len && base[i + 1].is_digit() {
				cut = i
			}
		}
		if cut > 0 {
			name := base[..cut].to_lower().replace('_', '-')
			version := base[cut + 1..]
			return MatchRegistryPackage{
				ecosystem: 'PyPI'
				name: name
				version: version
				purl: 'pkg:pypi/${name}@${version}'
			}
		}
	}
	if url.contains('cpan') || url.contains('metacpan') {
		base := filename.replace('.tar.gz', '').replace('.tar.bz2', '').replace('.zip', '')
		mut cut := -1
		for i, character in base {
			if character == `-` && i + 1 < base.len && (base[i + 1].is_digit() || base[i + 1] == `v`) {
				cut = i
			}
		}
		if cut > 0 {
			name := base[..cut]
			version := base[cut + 1..]
			return MatchRegistryPackage{
				ecosystem: 'CPAN'
				name: name
				version: version
				purl: 'pkg:cpan/${name}@${version}'
			}
		}
	}
	return none
}

fn match_tag(url string) ?string {
	filename := match_filename(url).replace('.tar.gz', '').replace('.tar.bz2', '').replace('.zip', '')
	for prefix in ['v', 'V'] {
		if index := filename.last_index('-${prefix}') {
			return filename[index + 1..]
		}
	}
	if filename.starts_with('v') {
		return filename
	}
	return none
}

pub fn (matcher MatchMatcher) identify(formula MatchFormula) MatchIdentity {
	mut resource_packages := map[string]MatchRegistryPackage{}
	for resource in formula.resources {
		if mut package := match_registry_package(resource.url) {
			if resource.version != '' {
				package = MatchRegistryPackage{
					...package
					version: resource.version
					purl: package.purl.all_before_last('@') + '@${resource.version}'
				}
			}
			resource_packages[resource.name] = package
		}
	}
	return MatchIdentity{
		git_repo: match_repo_url(formula.stable_url, formula.head_url, formula.homepage)
		git_tag: if formula.stable_tag != '' {
			formula.stable_tag} else {
			match_tag(formula.stable_url) or { formula.pkg_version }}
		primary_package: match_registry_package(formula.stable_url)
		resource_packages: resource_packages
		distro_packages: matcher.distro_packages_for(formula.name)
	}
}

pub fn build_match_osv_queries(identity MatchIdentity, formula_version string) []MatchQuery {
	mut queries := []MatchQuery{}
	if repo := identity.git_repo {
		queries << MatchQuery{
			package: OsvPackage{ ecosystem: 'GIT', name: repo }
			evidence: MatchEvidence{ strategy: .git, ecosystem: 'GIT', name: repo, subject_version: identity.git_tag or { formula_version }, key: repo }
		}
	}
	if package := identity.primary_package {
		if package.ecosystem != 'CPAN' {
			queries << MatchQuery{
				package: OsvPackage{ ecosystem: package.ecosystem, name: package.name }
				evidence: MatchEvidence{ strategy: .registry, ecosystem: package.ecosystem, name: package.name, subject_version: package.version, key: package.purl }
			}
		}
	}
	mut resources := identity.resource_packages.keys()
	resources.sort()
	for resource in resources {
		package := identity.resource_packages[resource]
		if package.ecosystem != 'CPAN' {
			queries << MatchQuery{
				package: OsvPackage{ ecosystem: package.ecosystem, name: package.name }
				evidence: MatchEvidence{ strategy: .registry, ecosystem: package.ecosystem, name: package.name, subject_version: package.version, key: package.purl, resource: resource }
			}
		}
	}
	mut ecosystems := identity.distro_packages.keys()
	ecosystems.sort()
	for ecosystem in ecosystems {
		mut names := identity.distro_packages[ecosystem].clone()
		names.sort()
		for name in names {
			queries << MatchQuery{
				package: OsvPackage{ ecosystem: ecosystem, name: name }
				evidence: MatchEvidence{ strategy: .distro, ecosystem: ecosystem, name: name, key: '${ecosystem}/${name}' }
			}
		}
	}
	return queries
}

pub fn cpan_match_evidence(identity MatchIdentity) []MatchEvidence {
	mut result := []MatchEvidence{}
	if package := identity.primary_package {
		if package.ecosystem == 'CPAN' {
			result << MatchEvidence{ strategy: .cpansa, ecosystem: 'CPAN', name: package.name, subject_version: package.version, key: package.purl }
		}
	}
	mut resources := identity.resource_packages.keys()
	resources.sort()
	for resource in resources {
		package := identity.resource_packages[resource]
		if package.ecosystem == 'CPAN' {
			result << MatchEvidence{ strategy: .cpansa, ecosystem: 'CPAN', name: package.name, subject_version: package.version, key: package.purl, resource: resource }
		}
	}
	return result
}

pub fn cpansa_match_vulnerability(advisory CpanSecAdvisory, id string) MatchVulnerability {
	description := advisory.description or { '' }
	return MatchVulnerability{
		id: id
		summary: if description == '' {
			none} else {
			description.split_into_lines()[0].trim_space()}
		details: advisory.description
		references: advisory.references.map(OsvExportReference{ reference_type: 'WEB', url: it })
	}
}

pub fn own_match_evidence(identity MatchIdentity) []MatchEvidence {
	mut result := []MatchEvidence{}
	if repo := identity.git_repo {
		result << MatchEvidence{ strategy: .distro, ecosystem: 'GIT', name: repo, subject_version: identity.git_tag, key: 'upstream:${repo}' }
	}
	if package := identity.primary_package {
		result << MatchEvidence{ strategy: .distro, ecosystem: package.ecosystem, name: package.name, subject_version: package.version, key: 'upstream:${package.purl}' }
	}
	return result
}

pub type MatchVulnerabilityFetch = fn(string) ?MatchVulnerability

pub type MatchQueryBatch = fn([]OsvPackage) ![][]OsvVulnerability

pub fn resolve_match_to_cves(record MatchVulnerability, mut seen map[string]bool, budget int,
	fetch MatchVulnerabilityFetch) []MatchVulnerability {
	if record.cve_ids().len > 0 {
		return [record]
	}
	if budget == 0 {
		return []MatchVulnerability{}
	}
	mut follow := record.upstream.clone()
	if follow.len == 0 && record.id.starts_with('ALSA-') {
		follow = record.related.filter(match_is_cve(it))
	}
	mut resolved := []MatchVulnerability{}
	for id in follow {
		if seen[id] {
			continue
		}
		seen[id] = true
		if upstream := fetch(id) {
			for candidate in resolve_match_to_cves(upstream, mut seen, budget - 1, fetch) {
				if !resolved.any(it.id == candidate.id) {
					resolved << candidate
				}
			}
		}
	}
	return resolved
}

pub fn resolve_match_upstream(id_evidence map[string][]MatchEvidence, identity MatchIdentity,
	fetch MatchVulnerabilityFetch) ![]MatchHit {
	mut hits := []MatchHit{}
	mut ids := id_evidence.keys()
	ids.sort()
	for id in ids {
		record := fetch(id) or { continue }
		mut seen := {
			id: true
		}
		resolved := resolve_match_to_cves(record, mut seen, 5, fetch)
		if resolved.len == 0 {
			hits << new_match_hit(record, id_evidence[id])!
			continue
		}
		for candidate in resolved {
			mut evidence := id_evidence[id].clone()
			if candidate.id != record.id {
				evidence << own_match_evidence(identity)
			}
			hits << new_match_hit(candidate, evidence)!
		}
	}
	return hits
}

pub fn match_hits_from(id_evidence map[string][]MatchEvidence, identity MatchIdentity,
	cpan_sec CpanSecDatabase, fetch MatchVulnerabilityFetch) ![]MatchHit {
	mut hits := resolve_match_upstream(id_evidence, identity, fetch)!
	for evidence in cpan_match_evidence(identity) {
		for advisory in cpan_sec.advisories_for(evidence.name) {
			annotated := MatchEvidence{
				...evidence
				advisory: advisory
			}
			if advisory.cves.len > 0 {
				for cve in advisory.cves {
					record := fetch(cve) or { cpansa_match_vulnerability(advisory, cve) }
					hits << new_match_hit(record, [annotated])!
				}
			} else {
				hits << new_match_hit(cpansa_match_vulnerability(advisory, advisory.id), [
					annotated,
				])!
			}
		}
	}
	return dedup_match_hits(hits)
}

pub fn match_advisories_for(identity MatchIdentity, formula_version string,
	cpan_sec CpanSecDatabase, query_batch MatchQueryBatch,
	fetch MatchVulnerabilityFetch) ![]MatchHit {
	if !identity.identifiable() {
		return []MatchHit{}
	}
	queries := build_match_osv_queries(identity, formula_version)
	responses := if queries.len > 0 {
		query_batch(queries.map(it.package))!
	} else {
		[][]OsvVulnerability{}
	}
	if responses.len != queries.len {
		return error('OSV query result count did not match labelled queries')
	}
	mut id_evidence := map[string][]MatchEvidence{}
	for index, records in responses {
		for record in records {
			id_evidence[record.id] << queries[index].evidence
		}
	}
	return match_hits_from(id_evidence, identity, cpan_sec, fetch)
}

pub fn match_each_advisory_batch(identities []MatchIdentity, versions []string,
	cpan_sec CpanSecDatabase, query_batch MatchQueryBatch,
	fetch MatchVulnerabilityFetch) ![][]MatchHit {
	mut labelled := []MatchQuery{}
	mut owners := []int{}
	for index, identity in identities {
		if !identity.identifiable() {
			continue
		}
		version := if index < versions.len { versions[index] } else { '' }
		for query in build_match_osv_queries(identity, version) {
			labelled << query
			owners << index
		}
	}
	responses := if labelled.len > 0 {
		query_batch(labelled.map(it.package))!
	} else {
		[][]OsvVulnerability{}
	}
	if responses.len != labelled.len {
		return error('OSV query result count did not match labelled queries')
	}
	mut by_identity := []map[string][]MatchEvidence{len: identities.len}
	for index, records in responses {
		for record in records {
			by_identity[owners[index]][record.id] << labelled[index].evidence
		}
	}
	mut result := [][]MatchHit{cap: identities.len}
	for index, identity in identities {
		if identity.identifiable() {
			result << match_hits_from(by_identity[index], identity, cpan_sec, fetch)!
		} else {
			result << []MatchHit{}
		}
	}
	return result
}

pub fn dedup_match_hits(hits []MatchHit) ![]MatchHit {
	mut grouped := map[string][]MatchHit{}
	for hit in hits {
		grouped[hit.canonical_id()] << hit
	}
	mut ids := grouped.keys()
	ids.sort()
	mut result := []MatchHit{}
	for id in ids {
		group := grouped[id]
		mut primary := group[0]
		mut evidence := []MatchEvidence{}
		for hit in group {
			if match_strategy_precision(hit.strategy()) > match_strategy_precision(primary.strategy()) {
				primary = hit
			}
			for item in hit.evidence {
				if !evidence.any(it.strategy == item.strategy && it.key == item.key && match_optional_strings_equal(it.resource, item.resource)) {
					evidence << item
				}
			}
		}
		result << new_match_hit(primary.vulnerability, evidence)!
	}
	return result
}

fn match_optional_strings_equal(left ?string, right ?string) bool {
	left_value := left or { return right == none }
	right_value := right or { return false }
	return left_value == right_value
}

pub fn match_evidence_range_status(evidence MatchEvidence,
	subject_version ?string) ?AdvisoryRangeStatus {
	version := subject_version or { return none }
	if evidence.strategy == .cpansa {
		advisory := evidence.advisory or { return none }
		status := cpan_sec_range_status(advisory, version) or { return none }
		return AdvisoryRangeStatus{
			state: match status.state {
				.affected { .affected }
				.fixed { .fixed }
				.not_applicable { .not_applicable }
			}
			fixed_in: status.fixed_in
		}
	}
	record := evidence.source_record or { return none }
	return record.range_status(evidence.ecosystem, evidence.name, version)
}

pub fn match_range_status(hit MatchHit) ?MatchRangeResult {
	mut results := []MatchRangeResult{}
	for evidence in hit.evidence {
		if status := match_evidence_range_status(evidence, evidence.subject_version) {
			results << MatchRangeResult{ status: status, evidence: evidence }
		}
	}
	for state in [AdvisoryRangeState.affected, .fixed, .not_applicable] {
		for result in results {
			if result.status.state == state {
				return result
			}
		}
	}
	return none
}

pub fn match_confidence(hit MatchHit, comparable bool) string {
	base := match hit.strategy() {
		.git, .registry { 'high' }
		.cpansa { 'medium' }
		.distro { 'low' }
	}
	return if comparable {
		base
	} else if base == 'high' { 'medium' } else { 'low' }
}

pub struct MatchEcosystemSpecific {
pub:
	fix               ?string
	range_state       ?string
	upstream_fixed_in ?string
	resource          ?string
	resource_purl     ?string
}

pub struct MatchAffectedEntry {
pub:
	package            OsvExportPackage
	ranges             []OsvExportRange
	ecosystem_specific MatchEcosystemSpecific
}

pub struct MatchBrewRecord {
pub:
	schema_version    string
	id                string
	published         string
	modified          string
	upstream          []string
	affected          []MatchAffectedEntry
	database_specific map[string]json2.Any
	summary           ?string
	details           ?string
	severity          []OsvExportSeverity
	references        []OsvExportReference
}

pub fn match_affected_entry(formula MatchFormula, hit MatchHit, events []OsvExportEvent,
	fixed ?string, status ?AdvisoryRangeStatus, status_evidence ?MatchEvidence) MatchAffectedEntry {
	mut resource := hit.resource()
	mut resource_purl := ?string(none)
	if evidence := status_evidence {
		if evidence.resource != none {
			resource = evidence.resource
			resource_purl = evidence.key
		}
	}
	if resource_purl == none {
		if name := resource {
			for evidence in hit.evidence {
				if evidence_resource := evidence.resource {
					if evidence_resource == name {
						resource_purl = evidence.key
						break
					}
				}
			}
		}
	}
	return MatchAffectedEntry{
		package: OsvExportPackage{ ecosystem: osv_export_ecosystem, name: formula.name, purl: osv_export_purl(formula.name) }
		ranges: [OsvExportRange{ range_type: 'ECOSYSTEM', events: events }]
		ecosystem_specific: MatchEcosystemSpecific{
			fix: if fixed != none { 'bump' } else { none }
			range_state: if value := status { value.state.str() } else { none }
			upstream_fixed_in: if value := status { value.fixed_in } else { none }
			resource: resource
			resource_purl: resource_purl
		}
	}
}

pub fn match_to_brew_record(formula MatchFormula, hit MatchHit, first_fixed ?string,
	now string) MatchBrewRecord {
	status_result := match_range_status(hit)
	mut fixed := first_fixed
	if fixed == none {
		if result := status_result {
			if result.status.state == .fixed {
				fixed = formula.pkg_version
			}
		}
	}
	mut events := [OsvExportEvent{ introduced: '0' }]
	if value := fixed {
		events << OsvExportEvent{ fixed: value }
	}
	mut database_specific := {
		'source':     json2.Any('matched')
		'strategy':   json2.Any(hit.strategy().str())
		'confidence': json2.Any(match_confidence(hit, status_result != none))
	}
	database_specific['evidence_count'] = json2.Any(hit.evidence.len)
	return MatchBrewRecord{
		schema_version: osv_export_schema_version
		id: '${osv_export_id_prefix}-${formula.name}-${hit.canonical_id()}'
		published: now
		modified: now
		upstream: hit.vulnerability.identifiers()
		affected: [match_affected_entry(formula, hit, events, fixed, if value := status_result {
			value.status} else {
			none}, if value := status_result { value.evidence } else { none })]
		database_specific: database_specific
		summary: hit.vulnerability.summary
		details: hit.vulnerability.details
		severity: hit.vulnerability.severity_entries
		references: dedup_match_references(hit.vulnerability.references)
	}
}

fn dedup_match_references(references []OsvExportReference) []OsvExportReference {
	mut result := []OsvExportReference{}
	for reference in references {
		key := '${reference.reference_type}|${reference.url.replace('%40', '@').replace('%2B', '+').replace('%2b', '+')}'
		if !result.any('${it.reference_type}|${it.url.replace('%40', '@').replace('%2B', '+').replace('%2b', '+')}' == key) {
			result << reference
		}
	}
	return result
}

pub fn match_subject_version(formula MatchFormulaSnapshot, resource ?string) ?string {
	if name := resource {
		return formula.resources[name] or { none }
	}
	return formula.pkg_version
}

pub fn match_aggregate_state_at(formula MatchFormulaSnapshot, hit MatchHit) ?AdvisoryRangeState {
	mut statuses := []AdvisoryRangeStatus{}
	for evidence in hit.evidence {
		if evidence.subject_version == none {
			continue
		}
		if status := match_evidence_range_status(evidence, match_subject_version(formula, evidence.resource)) {
			statuses << status
		}
	}
	if statuses.any(it.state == .affected) {
		return .affected
	}
	if statuses.any(it.state == .fixed) {
		return .fixed
	}
	if statuses.len > 0 {
		return .not_applicable
	}
	return none
}

pub fn match_first_fixed_version(formula MatchFormula, hit MatchHit) ?string {
	current := match_range_status(hit) or { return none }
	if current.status.state != .fixed {
		return none
	}
	mut last_fixed := formula.pkg_version
	for snapshot in formula.history {
		if !snapshot.loadable {
			return last_fixed
		}
		state := match_aggregate_state_at(snapshot, hit) or { continue }
		if state == .not_applicable {
			return 'never_affected'
		}
		if state != .fixed {
			return last_fixed
		}
		last_fixed = snapshot.pkg_version
	}
	return 'never_affected'
}

// Ruby method `identifiable?` at line 47.
pub fn ruby_match_l47_d1_identifiable(identity MatchIdentity) bool {
	return identity.identifiable()
}

// Ruby method `with_source(record)` at line 66.
pub fn ruby_match_l66_d2_with_source(evidence MatchEvidence, record MatchVulnerability) MatchEvidence {
	return evidence.with_source(record)
}

// Ruby attr_reader `attr_reader :vulnerability` at line 73.
pub fn ruby_match_l73_d3_vulnerability(hit MatchHit) MatchVulnerability {
	return hit.vulnerability
}

// Ruby attr_reader `attr_reader :evidence` at line 76.
pub fn ruby_match_l76_d4_evidence(hit MatchHit) []MatchEvidence {
	return hit.evidence.clone()
}

// Ruby method `initialize(vulnerability:, evidence:)` at line 79.
pub fn ruby_match_l79_d5_initialize(vulnerability MatchVulnerability, evidence []MatchEvidence) !MatchHit {
	return new_match_hit(vulnerability, evidence)
}

// Ruby method `primary_evidence` at line 91.
pub fn ruby_match_l91_d6_primary_evidence(hit MatchHit) MatchEvidence {
	return hit.primary_evidence()
}

// Ruby method `strategy` at line 96.
pub fn ruby_match_l96_d7_strategy(hit MatchHit) MatchStrategy {
	return hit.strategy()
}

// Ruby method `resource` at line 101.
pub fn ruby_match_l101_d8_resource(hit MatchHit) ?string {
	return hit.resource()
}

// Ruby method `canonical_id` at line 106.
pub fn ruby_match_l106_d9_canonical_id(hit MatchHit) string {
	return hit.canonical_id()
}

// Ruby method `initialize(repology: nil, cpan_sec: nil, bulk: false)` at line 112.
pub fn ruby_match_l112_d10_initialize(repology RepologyDatabase, cpan_sec CpanSecDatabase, bulk bool) MatchMatcher {
	return new_matcher(repology, cpan_sec, bulk)
}

// Ruby method `repology` at line 122.
pub fn ruby_match_l122_d11_repology(matcher MatchMatcher) RepologyDatabase {
	return matcher.repology
}

// Ruby method `cpan_sec` at line 127.
pub fn ruby_match_l127_d12_cpan_sec(matcher MatchMatcher) CpanSecDatabase {
	return matcher.cpan_sec
}

// Ruby method `identify(formula)` at line 132.
pub fn ruby_match_l132_d13_identify(matcher MatchMatcher, formula MatchFormula) MatchIdentity {
	return matcher.identify(formula)
}

// Ruby method `advisories_for(formula)` at line 154.
pub fn ruby_match_l154_d14_advisories_for(identity MatchIdentity, formula_version string,
	cpan_sec CpanSecDatabase, query_batch MatchQueryBatch,
	fetch MatchVulnerabilityFetch) ![]MatchHit {
	return match_advisories_for(identity, formula_version, cpan_sec, query_batch, fetch)
}

// Ruby method `each_advisory_batch(formulae, &_blk)` at line 173.
pub fn ruby_match_l173_d15_each_advisory_batch(identities []MatchIdentity,
	versions []string, cpan_sec CpanSecDatabase, query_batch MatchQueryBatch,
	fetch MatchVulnerabilityFetch) ![][]MatchHit {
	return match_each_advisory_batch(identities, versions, cpan_sec, query_batch, fetch)
}

// Ruby method `hits_from(id_evidence, identity)` at line 207.
pub fn ruby_match_l207_d16_hits_from(id_evidence map[string][]MatchEvidence,
	identity MatchIdentity, cpan_sec CpanSecDatabase,
	fetch MatchVulnerabilityFetch) ![]MatchHit {
	return match_hits_from(id_evidence, identity, cpan_sec, fetch)
}

// Ruby method `cpansa_vulnerability(adv, id:)` at line 231.
pub fn ruby_match_l231_d17_cpansa_vulnerability(advisory CpanSecAdvisory, id string) MatchVulnerability {
	return cpansa_match_vulnerability(advisory, id)
}

// Ruby method `build_osv_queries(identity, formula_version)` at line 244.
pub fn ruby_match_l244_d18_build_osv_queries(identity MatchIdentity, formula_version string) []MatchQuery {
	return build_match_osv_queries(identity, formula_version)
}

// Ruby method `cpan_evidence(identity)` at line 280.
pub fn ruby_match_l280_d19_cpan_evidence(identity MatchIdentity) []MatchEvidence {
	return cpan_match_evidence(identity)
}

// Ruby method `resolve_upstream(id_evidence, identity)` at line 316.
pub fn ruby_match_l316_d20_resolve_upstream(id_evidence map[string][]MatchEvidence,
	identity MatchIdentity, fetch MatchVulnerabilityFetch) ![]MatchHit {
	return resolve_match_upstream(id_evidence, identity, fetch)
}

// Ruby method `resolve_to_cves(record, seen, budget)` at line 352.
pub fn ruby_match_l352_d21_resolve_to_cves(record MatchVulnerability, mut seen map[string]bool,
	budget int, fetch MatchVulnerabilityFetch) []MatchVulnerability {
	return resolve_match_to_cves(record, mut seen, budget, fetch)
}

// Ruby method `own_evidence(identity)` at line 371.
pub fn ruby_match_l371_d22_own_evidence(identity MatchIdentity) []MatchEvidence {
	return own_match_evidence(identity)
}

// Ruby method `distro_packages_for(name)` at line 388.
pub fn ruby_match_l388_d23_distro_packages_for(matcher MatchMatcher, name string) RepologyDistroMap {
	return matcher.distro_packages_for(name)
}

// Ruby method `prefetch_vulnerabilities(ids)` at line 405.
pub fn ruby_match_l405_d24_prefetch_vulnerabilities(mut matcher MatchMatcher,
	ids []string, fetch MatchVulnerabilityFetch) {
	for id in ids {
		if id !in matcher.vulnerability_cache {
			matcher.vulnerability_cache[id] = fetch(id)
		}
	}
}

// Ruby method `fetch_vulnerability(id)` at line 414.
pub fn ruby_match_l414_d25_fetch_vulnerability(mut matcher MatchMatcher, id string,
	fetch MatchVulnerabilityFetch) ?MatchVulnerability {
	if cached := matcher.vulnerability_cache[id] {
		return cached
	}
	loaded := fetch(id)
	matcher.vulnerability_cache[id] = loaded
	return loaded
}

// Ruby method `load_vulnerability(id)` at line 419.
pub fn ruby_match_l419_d26_load_vulnerability(id string, fetch MatchVulnerabilityFetch) ?MatchVulnerability {
	return fetch(id)
}

// Ruby method `dedup_by_cve(hits)` at line 427.
pub fn ruby_match_l427_d27_dedup_by_cve(hits []MatchHit) ![]MatchHit {
	return dedup_match_hits(hits)
}

// Ruby method `range_status(hit)` at line 447.
pub fn ruby_match_l447_d28_range_status(hit MatchHit) ?MatchRangeResult {
	return match_range_status(hit)
}

// Ruby method `evidence_range_status(evidence, subject_version)` at line 463.
pub fn ruby_match_l463_d29_evidence_range_status(evidence MatchEvidence,
	version ?string) ?AdvisoryRangeStatus {
	return match_evidence_range_status(evidence, version)
}

// Ruby method `to_brew_record(formula, hit, first_fixed: nil, now: Time.now.utc)` at line 488.
pub fn ruby_match_l488_d30_to_brew_record(formula MatchFormula, hit MatchHit,
	first_fixed ?string, now string) MatchBrewRecord {
	return match_to_brew_record(formula, hit, first_fixed, now)
}

// Ruby method `confidence_for(hit, status)` at line 526.
pub fn ruby_match_l526_d31_confidence_for(hit MatchHit, comparable bool) string {
	return match_confidence(hit, comparable)
}

// Ruby method `affected_entry(formula, hit, events, fixed, status, status_evidence)` at line 540.
pub fn ruby_match_l540_d32_affected_entry(formula MatchFormula, hit MatchHit,
	events []OsvExportEvent, fixed ?string, status ?AdvisoryRangeStatus,
	status_evidence ?MatchEvidence) MatchAffectedEntry {
	return match_affected_entry(formula, hit, events, fixed, status, status_evidence)
}

// Ruby method `first_fixed_version(formula, hit)` at line 583.
pub fn ruby_match_l583_d33_first_fixed_version(formula MatchFormula, hit MatchHit) ?string {
	return match_first_fixed_version(formula, hit)
}

// Ruby method `aggregate_state_at(formula, hit)` at line 608.
pub fn ruby_match_l608_d34_aggregate_state_at(formula MatchFormulaSnapshot,
	hit MatchHit) ?AdvisoryRangeState {
	return match_aggregate_state_at(formula, hit)
}

// Ruby method `subject_version(formula, resource)` at line 628.
pub fn ruby_match_l628_d35_subject_version(formula MatchFormulaSnapshot,
	resource ?string) ?string {
	return match_subject_version(formula, resource)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_versions"
// 5: require "vulns/cpan_sec"
// 6: require "vulns/identify"
// 7: require "vulns/osv"
// 8: require "vulns/osv_export"
// 9: require "vulns/repology"
// 10: require "vulns/vulnerability"
// 11:
// 12: module Homebrew
// 13:   module Vulns
// 14:     # Authoring-time advisory matcher. For a given {Formula} it derives every
// 15:     # OSV.dev query key it can (forge repository, language-registry package for
// 16:     # the primary URL and each `resource`, distro source packages via
// 17:     # {Repology}, CPAN distribution via {CPANSec}), issues *versionless* queries
// 18:     # against each, resolves distro advisories to their upstream CVEs, and
// 19:     # evaluates each hit's affected range against the version we ship.
// 20:     #
// 21:     # Runs in `Homebrew/advisory-database` CI and the homebrew-core PR bot to
// 22:     # produce candidate `BREW-*` records for human review; never on a user's
// 23:     # machine, so request volume is traded for recall and every candidate
// 24:     # carries a strategy/confidence label for the reviewer.
// 25:     class Match
// 26:       include Utils::Output::Mixin
// 27:
// 28:       # Descending precision. When several strategies reach the same CVE the
// 29:       # highest is reported as the hit's primary strategy; the rest are kept as
// 30:       # supporting evidence.
// 31:       STRATEGY_PRECISION = T.let(
// 32:         { git: 4, registry: 3, cpansa: 2, distro: 1 }.freeze,
// 33:         T::Hash[Symbol, Integer],
// 34:       )
// 35:
// 36:       # Recorded in `database_specific.confidence` for the reviewer.
// 37:       CONFIDENCE = T.let(
// 38:         { git: "high", registry: "high", cpansa: "medium", distro: "low" }.freeze,
// 39:         T::Hash[Symbol, String],
// 40:       )
// 41:
// 42:       Identity = Struct.new(
// 43:         :git_repo, :git_tag, :primary_package, :resource_packages, :distro_packages,
// 44:         keyword_init: true
// 45:       ) do
// 46:         sig { returns(T::Boolean) }
// 47:         def identifiable?
// 48:           !git_repo.nil? || !primary_package.nil? || resource_packages.any? || distro_packages.any?
// 49:         end
// 50:       end
// 51:
// 52:       # `ecosystem`/`name` are the OSV `package` fields queried, so a hit's
// 53:       # `affected[]` entry can be matched back to this evidence.
// 54:       # `subject_version` is the version to evaluate that entry's ranges
// 55:       # against: the formula version for the primary source, the pinned
// 56:       # resource version for a resource, `nil` for distro (whose versions are
// 57:       # not comparable to ours). `advisory` carries the CPANSA record for
// 58:       # `:cpansa` evidence so its constraint strings survive to
// 59:       # {#range_status}. `source_record` is the {Vulnerability} this evidence
// 60:       # was matched against (attached at hit-construction time), so after
// 61:       # {#dedup_by_cve} merges hits each evidence still points at the record
// 62:       # whose `affected[]` it should be checked against.
// 63:       Evidence = Struct.new(:strategy, :ecosystem, :name, :subject_version, :key, :resource,
// 64:                             :advisory, :source_record, keyword_init: true) do
// 65:         sig { params(record: Vulnerability).returns(T.untyped) }
// 66:         def with_source(record)
// 67:           source_record ? self : self.class.new(**to_h, source_record: record).freeze
// 68:         end
// 69:       end
// 70:
// 71:       class Hit
// 72:         sig { returns(Vulnerability) }
// 73:         attr_reader :vulnerability
// 74:
// 75:         sig { returns(T::Array[Evidence]) }
// 76:         attr_reader :evidence
// 77:
// 78:         sig { params(vulnerability: Vulnerability, evidence: T::Array[Evidence]).void }
// 79:         def initialize(vulnerability:, evidence:)
// 80:           raise ArgumentError, "Hit requires at least one Evidence" if evidence.empty?
// 81:
// 82:           @vulnerability = vulnerability
// 83:           @evidence = T.let(
// 84:             evidence.map { |e| e.with_source(vulnerability) }
// 85:                     .sort_by { |e| -STRATEGY_PRECISION.fetch(e.strategy) }.freeze,
// 86:             T::Array[Evidence],
// 87:           )
// 88:         end
// 89:
// 90:         sig { returns(Evidence) }
// 91:         def primary_evidence
// 92:           evidence.fetch(0)
// 93:         end
// 94:
// 95:         sig { returns(Symbol) }
// 96:         def strategy
// 97:           primary_evidence.strategy
// 98:         end
// 99:
// 100:         sig { returns(T.nilable(String)) }
// 101:         def resource
// 102:           primary_evidence.resource
// 103:         end
// 104:
// 105:         sig { returns(String) }
// 106:         def canonical_id
// 107:           vulnerability.cve_ids.min || vulnerability.id
// 108:         end
// 109:       end
// 110:
// 111:       sig { params(repology: T.nilable(Repology), cpan_sec: T.nilable(CPANSec), bulk: T::Boolean).void }
// 112:       def initialize(repology: nil, cpan_sec: nil, bulk: false)
// 113:         @repology = repology
// 114:         @cpan_sec = cpan_sec
// 115:         @bulk = bulk
// 116:         @vuln_cache = T.let({}, T::Hash[String, T.nilable(Vulnerability)])
// 117:         @formula_versions = T.let({}, T::Hash[String, FormulaVersions])
// 118:         @formula_rev_lists = T.let({}, T::Hash[String, T::Array[[String, String]]])
// 119:       end
// 120:
// 121:       sig { returns(Repology) }
// 122:       def repology
// 123:         @repology ||= Repology.load
// 124:       end
// 125:
// 126:       sig { returns(CPANSec) }
// 127:       def cpan_sec
// 128:         @cpan_sec ||= CPANSec.load
// 129:       end
// 130:
// 131:       sig { params(formula: Formula).returns(Identity) }
// 132:       def identify(formula)
// 133:         stable = formula.stable
// 134:         stable_url = stable&.url
// 135:         Identity.new(
// 136:           git_repo:          Identify.repo_url(stable_url, formula.head&.url, formula.homepage),
// 137:           git_tag:           Identify.tag(stable_url) || stable&.specs&.dig(:tag) || stable&.version&.to_s,
// 138:           primary_package:   Identify.registry_package(stable_url),
// 139:           resource_packages: formula.resources.filter_map do |r|
// 140:             pkg = Identify.registry_package(r.url)
// 141:             [r.name, pkg] if pkg
// 142:           end.to_h.freeze,
// 143:           distro_packages:   distro_packages_for(formula.name),
// 144:         ).freeze
// 145:       end
// 146:
// 147:       # Returns one {Hit} per distinct vulnerability (grouped by CVE alias)
// 148:       # reached by any strategy. Distro-ecosystem records are resolved to their
// 149:       # `upstream` CVE(s) so multi-CVE advisories split into per-CVE hits and
// 150:       # collapse onto the same CVE reached via GIT/registry. All queries are
// 151:       # versionless so historic bump-fixed advisories are returned;
// 152:       # {#range_status} evaluates each hit against the shipped version.
// 153:       sig { params(formula: Formula).returns(T::Array[Hit]) }
// 154:       def advisories_for(formula)
// 155:         result = T.let([], T::Array[Hit])
// 156:         each_advisory_batch([formula]) { |_, hits| result = hits }
// 157:         result
// 158:       end
// 159:
// 160:       BULK_CHUNK = 200
// 161:       private_constant :BULK_CHUNK
// 162:
// 163:       # Bulk form of {#advisories_for}: builds the labelled queries for a chunk
// 164:       # of formulae at once, sends them through a single {OSV.query_batch}
// 165:       # (which itself slices at `BATCH_SIZE`), then yields `(formula, hits)` in
// 166:       # input order. Per-formula query counts vary widely (one distro entry per
// 167:       # ecosystem×srcname), so chunking bounds memory without accumulating the
// 168:       # whole tap's queries or records; the `@vuln_cache` still spans chunks.
// 169:       sig {
// 170:         params(formulae: T::Enumerable[Formula],
// 171:                _blk:     T.proc.params(formula: Formula, hits: T::Array[Hit]).void).void
// 172:       }
// 173:       def each_advisory_batch(formulae, &_blk)
// 174:         formulae.each_slice(BULK_CHUNK) do |chunk|
// 175:           identities = chunk.map { |f| [f, identify(f)] }
// 176:           labelled = T.let([], T::Array[[OSV::Package, [Formula, Evidence]]])
// 177:           identities.each do |f, identity|
// 178:             next unless identity.identifiable?
// 179:
// 180:             build_osv_queries(identity, f.version.to_s).each do |query, evidence|
// 181:               labelled << [query, [f, evidence]]
// 182:             end
// 183:           end
// 184:
// 185:           by_formula = T.let({}, T::Hash[Formula, T::Hash[String, T::Array[Evidence]]])
// 186:           if labelled.any?
// 187:             OSV.query_batch(labelled.map(&:first)).each_with_index do |stubs, i|
// 188:               formula, evidence = labelled.fetch(i).last
// 189:               id_evidence = by_formula[formula] ||= {}
// 190:               stubs.each { |stub| (id_evidence[stub.fetch("id")] ||= []) << evidence }
// 191:             end
// 192:           end
// 193:
// 194:           prefetch_vulnerabilities(by_formula.each_value.flat_map(&:keys))
// 195:
// 196:           identities.each do |f, identity|
// 197:             next yield f, [] unless identity.identifiable?
// 198:
// 199:             yield f, hits_from(by_formula[f] || {}, identity)
// 200:           end
// 201:         end
// 202:       end
// 203:
// 204:       sig {
// 205:         params(id_evidence: T::Hash[String, T::Array[Evidence]], identity: Identity).returns(T::Array[Hit])
// 206:       }
// 207:       def hits_from(id_evidence, identity)
// 208:         hits = resolve_upstream(id_evidence, identity)
// 209:         cpan_evidence(identity).each do |ev|
// 210:           cpan_sec.advisories_for(ev.name).each do |adv|
// 211:             annotated = Evidence.new(**ev.to_h, advisory: adv).freeze
// 212:             if adv.cves.any?
// 213:               adv.cves.each do |cve|
// 214:                 record = fetch_vulnerability(cve) || cpansa_vulnerability(adv, id: cve)
// 215:                 hits << Hit.new(vulnerability: record, evidence: [annotated])
// 216:               end
// 217:             else
// 218:               hits << Hit.new(vulnerability: cpansa_vulnerability(adv, id: adv.id.to_s),
// 219:                               evidence:      [annotated])
// 220:             end
// 221:           end
// 222:         end
// 223:         dedup_by_cve(hits)
// 224:       end
// 225:
// 226:       # Synthesise a {Vulnerability} for a CPANSA advisory when OSV has no
// 227:       # record. `id` is scoped to the single CVE (or CPANSA id) being handled
// 228:       # so a multi-CVE advisory whose CVEs are absent from OSV yields distinct
// 229:       # records instead of collapsing under the lowest CVE in dedup.
// 230:       sig { params(adv: CPANSec::Advisory, id: String).returns(Vulnerability) }
// 231:       def cpansa_vulnerability(adv, id:)
// 232:         summary = adv.description.to_s.lines.first&.strip
// 233:         Vulnerability.new({
// 234:           "id"         => id,
// 235:           "summary"    => summary,
// 236:           "details"    => adv.description,
// 237:           "references" => adv.references.map { |u| { "type" => "WEB", "url" => u } },
// 238:         }.compact)
// 239:       end
// 240:
// 241:       sig {
// 242:         params(identity: Identity, formula_version: String).returns(T::Array[[OSV::Package, Evidence]])
// 243:       }
// 244:       def build_osv_queries(identity, formula_version)
// 245:         queries = T.let([], T::Array[[OSV::Package, Evidence]])
// 246:
// 247:         if (repo = identity.git_repo)
// 248:           queries << [{ ecosystem: "GIT", name: repo, version: nil },
// 249:                       Evidence.new(strategy: :git, ecosystem: "GIT", name: repo,
// 250:                                    subject_version: identity.git_tag || formula_version,
// 251:                                    key: repo).freeze]
// 252:         end
// 253:
// 254:         if (pkg = identity.primary_package) && pkg.ecosystem != "CPAN"
// 255:           queries << [{ ecosystem: pkg.ecosystem, name: pkg.name, version: nil },
// 256:                       Evidence.new(strategy: :registry, ecosystem: pkg.ecosystem, name: pkg.name,
// 257:                                    subject_version: pkg.version, key: pkg.purl).freeze]
// 258:         end
// 259:
// 260:         identity.resource_packages.each do |resource, pkg|
// 261:           next if pkg.ecosystem == "CPAN"
// 262:
// 263:           queries << [{ ecosystem: pkg.ecosystem, name: pkg.name, version: nil },
// 264:                       Evidence.new(strategy: :registry, ecosystem: pkg.ecosystem, name: pkg.name,
// 265:                                    subject_version: pkg.version, key: pkg.purl, resource:).freeze]
// 266:         end
// 267:
// 268:         identity.distro_packages.each do |ecosystem, srcnames|
// 269:           srcnames.each do |srcname|
// 270:             queries << [{ ecosystem:, name: srcname, version: nil },
// 271:                         Evidence.new(strategy: :distro, ecosystem:, name: srcname,
// 272:                                      key: "#{ecosystem}/#{srcname}").freeze]
// 273:           end
// 274:         end
// 275:
// 276:         queries
// 277:       end
// 278:
// 279:       sig { params(identity: Identity).returns(T::Array[Evidence]) }
// 280:       def cpan_evidence(identity)
// 281:         result = T.let([], T::Array[Evidence])
// 282:         primary = identity.primary_package
// 283:         if primary&.ecosystem == "CPAN"
// 284:           result << Evidence.new(strategy: :cpansa, ecosystem: "CPAN", name: primary.name,
// 285:                                  subject_version: primary.version, key: primary.purl)
// 286:         end
// 287:         identity.resource_packages.each do |resource, pkg|
// 288:           next if pkg.ecosystem != "CPAN"
// 289:
// 290:           result << Evidence.new(strategy: :cpansa, ecosystem: "CPAN", name: pkg.name,
// 291:                                  subject_version: pkg.version, key: pkg.purl, resource:)
// 292:         end
// 293:         result
// 294:       end
// 295:
// 296:       CVE_ID = /\ACVE-\d{4}-\d+\z/
// 297:       private_constant :CVE_ID
// 298:
// 299:       MAX_UPSTREAM_HOPS = 5
// 300:       private_constant :MAX_UPSTREAM_HOPS
// 301:
// 302:       # Turn `id => [Evidence, ...]` into `[Hit, ...]`, resolving each record to
// 303:       # the CVE(s) it derives from. `upstream` is walked transitively with a
// 304:       # per-walk visited set (chains like `USN -> UBUNTU-CVE-* -> CVE-*` occur
// 305:       # in practice). `related` links to different vulnerabilities per the OSV
// 306:       # schema and is only consulted for its bare CVE ids when `upstream` is
// 307:       # empty (AlmaLinux ALSA records use it that way). A record that is
// 308:       # already a CVE by id or alias, or that reaches no CVE within the hop
// 309:       # budget, is kept as-is. Each resolved hit gains synthesised evidence
// 310:       # pointing at our own identity so {#range_status} can check the CVE
// 311:       # record's `affected[]` against our version.
// 312:       sig {
// 313:         params(id_evidence: T::Hash[String, T::Array[Evidence]], identity: Identity)
// 314:           .returns(T::Array[Hit])
// 315:       }
// 316:       def resolve_upstream(id_evidence, identity)
// 317:         own = own_evidence(identity)
// 318:         hits = T.let([], T::Array[Hit])
// 319:
// 320:         id_evidence.each do |id, evidence|
// 321:           record = fetch_vulnerability(id)
// 322:           next if record.nil?
// 323:
// 324:           resolved = resolve_to_cves(record, Set[id], MAX_UPSTREAM_HOPS)
// 325:           if resolved.empty?
// 326:             hits << Hit.new(vulnerability: record, evidence:)
// 327:             next
// 328:           end
// 329:
// 330:           resolved.each do |cve_record|
// 331:             ev = cve_record.equal?(record) ? evidence : evidence + own
// 332:             hits << Hit.new(vulnerability: cve_record, evidence: ev)
// 333:           end
// 334:         end
// 335:
// 336:         hits
// 337:       end
// 338:
// 339:       # AlmaLinux ALSA-* records list their source CVEs in `related` rather than
// 340:       # `upstream`. That is a data-source quirk; per the OSV schema `related`
// 341:       # otherwise names *different* vulnerabilities and must not be traversed.
// 342:       RELATED_AS_UPSTREAM_PREFIX = "ALSA-"
// 343:       private_constant :RELATED_AS_UPSTREAM_PREFIX
// 344:
// 345:       # Returns the set of CVE records `record` derives from. `[record]` if it
// 346:       # is one already; `[]` if the walk exhausts without reaching a CVE (the
// 347:       # caller then keeps `record` itself as a low-confidence hit).
// 348:       sig {
// 349:         params(record: Vulnerability, seen: T::Set[String], budget: Integer)
// 350:           .returns(T::Array[Vulnerability])
// 351:       }
// 352:       def resolve_to_cves(record, seen, budget)
// 353:         return [record] if record.cve_ids.any?
// 354:         return [] if budget.zero?
// 355:
// 356:         follow = record.upstream.presence
// 357:         follow ||= record.related.grep(CVE_ID) if record.id.start_with?(RELATED_AS_UPSTREAM_PREFIX)
// 358:         Array(follow).uniq.flat_map do |ref|
// 359:           next [] unless seen.add?(ref)
// 360:
// 361:           upstream = fetch_vulnerability(ref)
// 362:           upstream ? resolve_to_cves(upstream, seen, budget - 1) : []
// 363:         end.uniq(&:id)
// 364:       end
// 365:
// 366:       # Evidence rows pointing at our own identity keys (git repo, primary
// 367:       # registry package) with the formula/package version as subject. Attached
// 368:       # to distro-resolved upstream hits so {#range_status} can evaluate the
// 369:       # upstream CVE record's `affected[]` against something comparable.
// 370:       sig { params(identity: Identity).returns(T::Array[Evidence]) }
// 371:       def own_evidence(identity)
// 372:         result = T.let([], T::Array[Evidence])
// 373:         if (repo = identity.git_repo)
// 374:           result << Evidence.new(strategy: :distro, ecosystem: "GIT", name: repo,
// 375:                                  subject_version: identity.git_tag, key: "upstream:#{repo}").freeze
// 376:         end
// 377:         if (pkg = identity.primary_package)
// 378:           result << Evidence.new(strategy: :distro, ecosystem: pkg.ecosystem, name: pkg.name,
// 379:                                  subject_version: pkg.version, key: "upstream:#{pkg.purl}").freeze
// 380:         end
// 381:         result
// 382:       end
// 383:
// 384:       # Bulk mode (the `--all` sweep) trusts the published index; only a
// 385:       # single-formula run (the PR bot, or an explicit named check) may hit the
// 386:       # live Repology API for a formula the index doesn't yet cover.
// 387:       sig { params(name: String).returns(Repology::DistroMap) }
// 388:       def distro_packages_for(name)
// 389:         indexed = repology.distro_packages_for(name)
// 390:         return indexed if indexed.any? || @bulk
// 391:
// 392:         Repology.lookup(name)
// 393:       rescue CachedFeed::Error => e
// 394:         odebug "Repology lookup for #{name} failed: #{e.message}"
// 395:         {}
// 396:       end
// 397:
// 398:       MAX_VULN_FETCH_THREADS = 15
// 399:       private_constant :MAX_VULN_FETCH_THREADS
// 400:
// 401:       # OSV `querybatch` returns id/modified stubs. Warm `@vuln_cache` with the
// 402:       # full records for a chunk's stub ids before per-formula processing so
// 403:       # {#resolve_upstream} reads mostly from cache.
// 404:       sig { params(ids: T::Array[String]).void }
// 405:       def prefetch_vulnerabilities(ids)
// 406:         missing = ids.uniq.reject { |id| @vuln_cache.key?(id) }
// 407:         missing.each_slice(MAX_VULN_FETCH_THREADS) do |slice|
// 408:           slice.map { |id| [id, Thread.new { load_vulnerability(id) }] }
// 409:                .each { |id, t| @vuln_cache[id] = t.value }
// 410:         end
// 411:       end
// 412:
// 413:       sig { params(id: String).returns(T.nilable(Vulnerability)) }
// 414:       def fetch_vulnerability(id)
// 415:         @vuln_cache.fetch(id) { @vuln_cache[id] = load_vulnerability(id) }
// 416:       end
// 417:
// 418:       sig { params(id: String).returns(T.nilable(Vulnerability)) }
// 419:       def load_vulnerability(id)
// 420:         Vulnerability.new(OSV.vulnerability(id))
// 421:       rescue OSV::Error => e
// 422:         odebug "OSV.vulnerability(#{id}) failed: #{e.message}"
// 423:         nil
// 424:       end
// 425:
// 426:       sig { params(hits: T::Array[Hit]).returns(T::Array[Hit]) }
// 427:       def dedup_by_cve(hits)
// 428:         hits.group_by(&:canonical_id).map do |_, group|
// 429:           next group.fetch(0) if group.one?
// 430:
// 431:           primary = T.must(group.max_by { |h| STRATEGY_PRECISION.fetch(h.strategy) })
// 432:           Hit.new(vulnerability: primary.vulnerability,
// 433:                   evidence:      group.flat_map(&:evidence).uniq)
// 434:         end
// 435:       end
// 436:
// 437:       # Evaluate `hit` against every evidence's subject, each against the
// 438:       # record that evidence was matched against, and aggregate: `:affected` if
// 439:       # any subject is affected (a fixed primary must not hide an affected
// 440:       # resource, or vice versa), else `:fixed` if any is fixed, else
// 441:       # `:not_applicable` only when every comparable subject says so. Returns
// 442:       # `[status, evidence]` where `evidence` is the one whose result was
// 443:       # chosen (used by {#first_fixed_version} and for the emitted record's
// 444:       # resource attribution), or `nil` if no evidence produced a checkable
// 445:       # answer.
// 446:       sig { params(hit: Hit).returns(T.nilable([Vulnerability::RangeStatus, Evidence])) }
// 447:       def range_status(hit)
// 448:         results = hit.evidence.filter_map do |ev|
// 449:           status = evidence_range_status(ev, ev.subject_version)
// 450:           [status, ev] if status
// 451:         end
// 452:         return if results.empty?
// 453:
// 454:         results.find { |s, _| s.affected? } ||
// 455:           results.find { |s, _| s.fixed? } ||
// 456:           results.first
// 457:       end
// 458:
// 459:       sig {
// 460:         params(evidence: Evidence, subject_version: T.nilable(String))
// 461:           .returns(T.nilable(Vulnerability::RangeStatus))
// 462:       }
// 463:       def evidence_range_status(evidence, subject_version)
// 464:         return if subject_version.nil?
// 465:
// 466:         if evidence.strategy == :cpansa
// 467:           adv = evidence.advisory
// 468:           CPANSec.range_status(adv, subject_version) if adv
// 469:         else
// 470:           evidence.source_record&.range_status(evidence.ecosystem, evidence.name, subject_version)
// 471:         end
// 472:       end
// 473:
// 474:       # Emit a candidate `BREW-*` OSV record for `hit` against `formula`.
// 475:       #
// 476:       # `first_fixed` is the {PkgVersion} at which Homebrew first shipped a fix
// 477:       # (from {#first_fixed_version} or a hand-set value). Otherwise
// 478:       # {#range_status} is consulted: `affected? == false` sets
// 479:       # `fixed: pkg_version` and `ecosystem_specific.fix: "bump"`;
// 480:       # `affected? == true` (or no comparable range) emits no `fixed` event and
// 481:       # `fix: null`. As with {OsvExport.record_for}, {OsvExport.merge_existing}
// 482:       # preserves on-disk `ranges` on rewrite so a hand-corrected boundary
// 483:       # sticks.
// 484:       sig {
// 485:         params(formula: Formula, hit: Hit, first_fixed: T.nilable(String), now: Time)
// 486:           .returns(T::Hash[Symbol, T.untyped])
// 487:       }
// 488:       def to_brew_record(formula, hit, first_fixed: nil, now: Time.now.utc)
// 489:         vuln = hit.vulnerability
// 490:         timestamp = now.strftime("%Y-%m-%dT%H:%M:%SZ")
// 491:         status, status_evidence = range_status(hit)
// 492:
// 493:         fixed = first_fixed
// 494:         fixed ||= formula.pkg_version.to_s if status&.fixed?
// 495:         events = T.let([{ introduced: "0" }], T::Array[T::Hash[Symbol, String]])
// 496:         events << { fixed: } if fixed
// 497:
// 498:         record = T.let({
// 499:           schema_version:    OsvExport::SCHEMA_VERSION,
// 500:           id:                "#{OsvExport::ID_PREFIX}-#{formula.name}-#{hit.canonical_id}",
// 501:           published:         timestamp,
// 502:           modified:          timestamp,
// 503:           upstream:          vuln.identifiers,
// 504:           affected:          [affected_entry(formula, hit, events, fixed, status, status_evidence)],
// 505:           database_specific: {
// 506:             source:            "matched",
// 507:             strategy:          hit.strategy.to_s,
// 508:             confidence:        confidence_for(hit, status),
// 509:             upstream_evidence: hit.evidence.map { |e| e.to_h.except(:advisory, :source_record).compact },
// 510:           },
// 511:         }, T::Hash[Symbol, T.untyped])
// 512:
// 513:         record[:summary] = vuln.summary if vuln.summary
// 514:         record[:details] = vuln.details if vuln.details
// 515:         record[:severity] = vuln.severity_entries if vuln.severity_entries.any?
// 516:         if (refs = vuln.references).any?
// 517:           record[:references] = refs.uniq { |r| [r["type"], URI::RFC2396_PARSER.unescape(r["url"].to_s)] }
// 518:         end
// 519:
// 520:         record
// 521:       end
// 522:
// 523:       sig {
// 524:         params(hit: Hit, status: T.nilable(Vulnerability::RangeStatus)).returns(String)
// 525:       }
// 526:       def confidence_for(hit, status)
// 527:         base = CONFIDENCE.fetch(hit.strategy)
// 528:         return base if status
// 529:
// 530:         # No comparable range: the reviewer must set the boundary by hand.
// 531:         (base == "high") ? "medium" : "low"
// 532:       end
// 533:
// 534:       sig {
// 535:         params(formula: Formula, hit: Hit, events: T::Array[T::Hash[Symbol, String]],
// 536:                fixed: T.nilable(String), status: T.nilable(Vulnerability::RangeStatus),
// 537:                status_evidence: T.nilable(Evidence))
// 538:           .returns(T::Hash[Symbol, T.untyped])
// 539:       }
// 540:       def affected_entry(formula, hit, events, fixed, status, status_evidence)
// 541:         eco = T.let({ fix: fixed ? "bump" : nil }, T::Hash[Symbol, T.nilable(String)])
// 542:         eco[:range_state] = status.state.to_s if status
// 543:         eco[:upstream_fixed_in] = status.fixed_in if status&.fixed_in
// 544:         # Attribute the resource whose subject decided the state, falling back
// 545:         # to the highest-precision evidence when nothing was comparable.
// 546:         if (resource = status_evidence&.resource || hit.resource)
// 547:           eco[:resource] = resource
// 548:           eco[:resource_purl] = (status_evidence if status_evidence&.resource)&.key ||
// 549:                                 hit.evidence.find { |e| e.resource == resource }&.key
// 550:         end
// 551:         {
// 552:           package:            {
// 553:             ecosystem: OsvExport::ECOSYSTEM,
// 554:             name:      formula.name,
// 555:             purl:      OsvExport.purl(formula.name),
// 556:           },
// 557:           ranges:             [{ type: "ECOSYSTEM", events: }],
// 558:           ecosystem_specific: eco,
// 559:         }
// 560:       end
// 561:
// 562:       # Walk homebrew-core git history (newest first) via {FormulaVersions} and
// 563:       # return the `pkg_version` at the oldest revision where the aggregate of
// 564:       # every checkable subject is still `:fixed`. Re-running the full
// 565:       # per-evidence range check with each revision's subject versions keeps
// 566:       # `last_affected` and exclusive-bound semantics intact and stops as soon
// 567:       # as any subject (primary or a resource) drops back into `:affected`, so
// 568:       # a primary fixed at 2.0 with a resource fixed at 3.0 yields 3.0.
// 569:       #
// 570:       # Returns:
// 571:       # - `nil` when the current aggregate is not `:fixed`.
// 572:       # - `:never_affected` when the walk reaches `:not_applicable` (or the
// 573:       #   start of the formula's history) without ever seeing `:affected`,
// 574:       #   i.e. Homebrew jumped from a version below `introduced` straight past
// 575:       #   `fixed` and never shipped an affected build. The caller drops the
// 576:       #   candidate rather than emitting `{introduced: "0", fixed: <first>}`.
// 577:       # - a `pkg_version` String when the walk hits `:affected`, or when it
// 578:       #   stops at an unloadable revision (best-effort boundary; the reviewer
// 579:       #   can tighten).
// 580:       #
// 581:       # The rev-list and per-revision loads are cached per formula.
// 582:       sig { params(formula: Formula, hit: Hit).returns(T.nilable(T.any(String, Symbol))) }
// 583:       def first_fixed_version(formula, hit)
// 584:         return unless range_status(hit)&.first&.fixed?
// 585:
// 586:         fv = @formula_versions[formula.name] ||= FormulaVersions.new(formula)
// 587:         revs = @formula_rev_lists[formula.name] ||=
// 588:           [].tap { |a| fv.rev_list("HEAD") { |rev, entry| a << [rev, entry] } }
// 589:
// 590:         last_fixed = T.let(formula.pkg_version.to_s, String)
// 591:         revs.each do |rev, entry|
// 592:           state = fv.formula_at_revision(rev, entry) do |old|
// 593:             [aggregate_state_at(old, hit), old.pkg_version.to_s]
// 594:           end
// 595:           # `nil` means the revision failed to load; can't verify further.
// 596:           return last_fixed if state.nil?
// 597:
// 598:           aggregate, pkg_version = state
// 599:           return :never_affected if aggregate == :not_applicable
// 600:           return last_fixed if aggregate != :fixed
// 601:
// 602:           last_fixed = pkg_version
// 603:         end
// 604:         :never_affected
// 605:       end
// 606:
// 607:       sig { params(formula: Formula, hit: Hit).returns(T.nilable(Symbol)) }
// 608:       def aggregate_state_at(formula, hit)
// 609:         results = hit.evidence.filter_map do |ev|
// 610:           # Evidence built without a subject_version (distro queries, own-
// 611:           # identity rows for a formula with no derivable tag) is deliberately
// 612:           # uncheckable and must stay that way at historical revisions too;
// 613:           # substituting the historical formula version would compare it
// 614:           # against the distro record's distro-versioned range.
// 615:           next if ev.subject_version.nil?
// 616:
// 617:           subject = subject_version(formula, ev.resource)&.to_s
// 618:           evidence_range_status(ev, subject)
// 619:         end
// 620:         return if results.empty?
// 621:         return :affected if results.any?(&:affected?)
// 622:         return :fixed if results.any?(&:fixed?)
// 623:
// 624:         :not_applicable
// 625:       end
// 626:
// 627:       sig { params(formula: Formula, resource: T.nilable(String)).returns(T.nilable(Version)) }
// 628:       def subject_version(formula, resource)
// 629:         if resource
// 630:           begin
// 631:             formula.resource(resource)&.version
// 632:           rescue ResourceMissingError
// 633:             nil
// 634:           end
// 635:         else
// 636:           formula.version
// 637:         end
// 638:       end
// 639:     end
// 640:   end
// 641: end
