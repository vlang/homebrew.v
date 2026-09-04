module vulns

import x.json2

// Translated from Homebrew/brew `vulns/match.rb`.
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
			formula.stable_tag
		} else {
			match_tag(formula.stable_url) or { formula.pkg_version }
		}
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
			none
		} else {
			description.split_into_lines()[0].trim_space()
		}
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

pub type MatchVulnerabilityFetch = fn (string) ?MatchVulnerability

pub type MatchQueryBatch = fn ([]OsvPackage) ![][]OsvVulnerability

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
			value.status
		} else {
			none
		}, if value := status_result { value.evidence } else { none })]
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
