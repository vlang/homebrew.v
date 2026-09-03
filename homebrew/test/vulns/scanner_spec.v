module vulns

import homebrew.vulns as scanner_core
import os

// Translated from Homebrew/brew `test/vulns/scanner_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct ScannerSpecBatch {
	repo string
	tag  string
	ids  []string
}

fn scanner_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-scanner-${os.getpid()}-${name}')
	if os.exists(path) {
		os.rmdir_all(path) or { panic(err) }
	}
	os.mkdir_all(path) or { panic(err) }
	return path
}

fn scanner_spec_cleanup(path string) {
	if os.exists(path) {
		os.rmdir_all(path) or { panic(err) }
	}
}

fn scanner_spec_write_sbom(prefix string, url string, version string) ! {
	contents := '{"packages":[{"SPDXID":"SPDXRef-Archive-test-src","downloadLocation":"${url}","versionInfo":"${version}"}]}'
	os.write_file(os.join_path(prefix, scanner_core.scanner_sbom_filename), contents)!
}

fn scanner_spec_record(id string, severity scanner_core.OutputSeverity, aliases []string,
	affected []scanner_core.ScannerAffected) scanner_core.ScannerVulnerability {
	return scanner_core.ScannerVulnerability{
		id: id
		severity: severity
		aliases: aliases.clone()
		affected: affected.clone()
	}
}

fn scanner_spec_semver(events []scanner_core.ScannerEvent) []scanner_core.ScannerAffected {
	return [scanner_core.ScannerAffected{
		ranges: [scanner_core.ScannerRange{
			range_type: 'SEMVER'
			events: events.clone()
		}]
	}]
}

fn scanner_spec_git(events []scanner_core.ScannerEvent) []scanner_core.ScannerAffected {
	return [scanner_core.ScannerAffected{
		package: scanner_core.ScannerAffectedPackage{
			ecosystem: 'GIT'
		}
		ranges: [scanner_core.ScannerRange{
			range_type: 'GIT'
			events: events.clone()
		}]
	}]
}

fn scanner_spec_scanner(formulae []scanner_core.ScannerFormula, batches []ScannerSpecBatch,
	vulnerabilities []scanner_core.ScannerVulnerability,
	options scanner_core.ScannerOptions) scanner_core.Scanner {
	mut batch_results := map[string][]string{}
	mut records := map[string]scanner_core.ScannerVulnerability{}
	for vulnerability in vulnerabilities {
		records[vulnerability.id] = vulnerability
	}
	for batch in batches {
		key := scanner_core.scanner_query_key(scanner_core.OsvPackage{
			ecosystem: 'GIT'
			name: batch.repo
			version: batch.tag
		})
		batch_results[key] = batch.ids.clone()
		for id in batch.ids {
			if id !in records {
				records[id] = scanner_spec_record(id, .high, []string{}, []scanner_core.ScannerAffected{})
			}
		}
	}
	return scanner_core.new_scanner(formulae, options, scanner_core.ScannerProvider{
		batch_results: batch_results
		records: records
	})
}

fn scanner_spec_act() scanner_core.ScannerFormula {
	return scanner_core.ScannerFormula{
		name: 'act'
		full_name: 'act'
		stable_url: 'https://github.com/nektos/act/archive/refs/tags/v0.2.84.tar.gz'
		stable_version: '0.2.84'
		version: '0.2.84'
	}
}

fn scanner_spec_openssl() scanner_core.ScannerFormula {
	return scanner_core.ScannerFormula{
		name: 'openssl@3'
		full_name: 'openssl@3'
		stable_url: 'https://github.com/openssl/openssl/releases/download/openssl-3.0.0/openssl-3.0.0.tar.gz'
		stable_version: '3.0.0'
		version: '3.0.0'
	}
}

fn scanner_spec_unsupported() scanner_core.ScannerFormula {
	return scanner_core.ScannerFormula{
		name: 'aom'
		full_name: 'aom'
		stable_url: 'https://aomedia.googlesource.com/aom.git'
		stable_tag: 'v3.13.1'
		stable_version: '3.13.1'
		version: '3.13.1'
	}
}

fn scanner_spec_libquicktime() scanner_core.ScannerFormula {
	return scanner_core.ScannerFormula{
		name: 'libquicktime'
		full_name: 'libquicktime'
		stable_url: 'https://github.com/owner/libquicktime/archive/refs/tags/v1.2.4.tar.gz'
		stable_version: '1.2.4'
		version: '1.2.4'
		serialized_patches: [scanner_core.ScannerPatch{
			url: 'https://deb.debian.org/debian/pool/main/libq/libquicktime/libquicktime_1.2.4-12.debian.tar.xz'
			resolves: [scanner_core.ScannerResolve{
				resolve_type: 'security'
				id: 'CVE-2016-2399'
			}, scanner_core.ScannerResolve{
				resolve_type: 'security'
				id: 'CVE-2017-9122'
			}]
		}]
	}
}

fn scanner_spec_act_batch(ids []string) ScannerSpecBatch {
	return ScannerSpecBatch{
		repo: 'https://github.com/nektos/act'
		tag: 'v0.2.84'
		ids: ids.clone()
	}
}

fn scanner_spec_libquicktime_batch(ids []string) ScannerSpecBatch {
	return ScannerSpecBatch{
		repo: 'https://github.com/owner/libquicktime'
		tag: 'v1.2.4'
		ids: ids.clone()
	}
}

// Ruby it `it "collects security-type resolves across all patches, uppercased and deduplicated" do` at line 8.
pub fn ruby_scanner_spec_l8_d1_collects() bool {
	patches := [scanner_core.ScannerPatch{
		resolves: [
			scanner_core.ScannerResolve{ resolve_type: 'security', id: 'CVE-2016-2399' },
			scanner_core.ScannerResolve{ resolve_type: 'security', id: 'CVE-2017-9122' },
		]
	}, scanner_core.ScannerPatch{
		resolves: [
			scanner_core.ScannerResolve{
				resolve_type: 'security'
				id: 'GHSA-xr7r-f8xq-vfvv'
			},
			scanner_core.ScannerResolve{ resolve_type: 'security', id: 'CVE-2017-9122' },
		]
	}]
	return scanner_core.scanner_resolved_ids(patches) == ['CVE-2016-2399', 'CVE-2017-9122',
		'GHSA-XR7R-F8XQ-VFVV']
}

// Ruby it `it "ignores defect-type resolves" do` at line 21.
pub fn ruby_scanner_spec_l21_d2_ignores() bool {
	return scanner_core.scanner_resolved_ids([scanner_core.ScannerPatch{
		resolves: [scanner_core.ScannerResolve{
			resolve_type: 'defect'
			id: 'https://bugs.example.com/1234'
		}, scanner_core.ScannerResolve{ resolve_type: 'security', id: 'CVE-2024-0001' }]
	}]) == ['CVE-2024-0001']
}

// Ruby it `it "returns empty for no patches" do` at line 29.
pub fn ruby_scanner_spec_l29_d3_returns() bool {
	return scanner_core.scanner_resolved_ids([]scanner_core.ScannerPatch{}).len == 0
}

// Ruby it `it "handles patches without a resolves key" do` at line 33.
pub fn ruby_scanner_spec_l33_d4_handles() bool {
	return scanner_core.scanner_resolved_ids([scanner_core.ScannerPatch{
		url: 'https://example.com/x.diff'
	}]).len == 0
}

// Ruby it `it "returns the -src package downloadLocation and versionInfo" do` at line 39.
pub fn ruby_scanner_spec_l39_d5_returns() !bool {
	prefix := scanner_spec_temp('source')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz', '0.2.80')!
	source := scanner_core.scanner_source_from_sbom(prefix) or { return false }
	return source.url == 'https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz' && source.version == '0.2.80'
}

// Ruby it `it "returns nil when no SBOM file exists" do` at line 45.
pub fn ruby_scanner_spec_l45_d6_returns() bool {
	return scanner_core.scanner_source_from_sbom('/nonexistent') == none
}

// Ruby it `it "returns the versionInfo when downloadLocation is NOASSERTION" do` at line 49.
pub fn ruby_scanner_spec_l49_d7_returns() !bool {
	prefix := scanner_spec_temp('no-url')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'NOASSERTION', '1.2.3')!
	source := scanner_core.scanner_source_from_sbom(prefix) or { return false }
	return source.url == '' && source.version == '1.2.3'
}

// Ruby it `it "returns nil when both downloadLocation and versionInfo are NOASSERTION" do` at line 59.
pub fn ruby_scanner_spec_l59_d8_returns() !bool {
	prefix := scanner_spec_temp('no-source')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'NOASSERTION', 'NOASSERTION')!
	return scanner_core.scanner_source_from_sbom(prefix) == none
}

// Ruby it `it "returns nil when the SBOM is unparseable" do` at line 71.
pub fn ruby_scanner_spec_l71_d9_returns() !bool {
	prefix := scanner_spec_temp('bad-json')
	defer { scanner_spec_cleanup(prefix) }
	os.write_file(os.join_path(prefix, scanner_core.scanner_sbom_filename), 'not json')!
	return scanner_core.scanner_source_from_sbom(prefix) == none
}

// Ruby it `it "derives repo from head and tag from stable version for a non-forge tarball" do` at line 81.
pub fn ruby_scanner_spec_l81_d10_derives() bool {
	formula := scanner_core.ScannerFormula{
		name: 'curl'
		stable_url: 'https://curl.se/download/curl-8.5.0.tar.bz2'
		head_url: 'https://github.com/curl/curl.git'
		stable_version: '8.5.0'
		version: '8.5.0'
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == 'https://github.com/curl/curl' && target.tag == '8.5.0' && target.version == '8.5.0'
}

// Ruby it `it "queries a non-forge head URL verbatim when no candidate is a supported forge" do` at line 95.
pub fn ruby_scanner_spec_l95_d11_queries() bool {
	formula := scanner_core.ScannerFormula{
		name: 'bash'
		stable_url: 'https://ftpmirror.gnu.org/gnu/bash/bash-5.3.tar.gz'
		head_url: 'https://git.savannah.gnu.org/git/bash.git'
		homepage: 'https://www.gnu.org/software/bash/'
		stable_version: '5.3'
		version: '5.3'
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == formula.head_url && target.tag == '5.3'
}

// Ruby it `it "queries a non-forge stable URL verbatim when its path yields a tag" do` at line 109.
pub fn ruby_scanner_spec_l109_d12_queries() bool {
	formula := scanner_core.ScannerFormula{
		name: 'thing'
		stable_url: 'https://gitea.example.com/owner/thing/archive/v1.2.3.tar.gz'
		stable_version: '1.2.3'
		version: '1.2.3'
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == formula.stable_url && target.tag == 'v1.2.3'
}

// Ruby it `it "prefers an explicit stable tag over the derived version" do` at line 121.
pub fn ruby_scanner_spec_l121_d13_prefers() bool {
	formula := scanner_core.ScannerFormula{
		name: 'aom'
		stable_url: 'https://aomedia.googlesource.com/aom.git'
		homepage: 'https://github.com/AomediaOrg/aom'
		stable_tag: 'v3.13.1'
		stable_version: '3.13.1'
		version: '3.13.1'
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == 'https://github.com/aomediaorg/aom' && target.tag == 'v3.13.1'
}

// Ruby it `it "queries the SBOM versionInfo when the SBOM downloadLocation has no extractable tag" do` at line 134.
pub fn ruby_scanner_spec_l134_d14_queries() !bool {
	prefix := scanner_spec_temp('curl-installed')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://curl.se/download/curl-8.4.0.tar.bz2', '8.4.0')!
	formula := scanner_core.ScannerFormula{
		name: 'curl'
		stable_url: 'https://curl.se/download/curl-8.5.0.tar.bz2'
		head_url: 'https://github.com/curl/curl.git'
		stable_version: '8.5.0'
		version: '8.5.0'
		installed: true
		installed_prefix: prefix
		installed_version: '8.4.0'
		current_recipe_applies: false
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == 'https://github.com/curl/curl' && target.tag == '8.4.0' && target.from_installed_sbom
}

// Ruby it `it "queries a non-forge head URL verbatim when the SBOM downloadLocation host is unsupported" do` at line 160.
pub fn ruby_scanner_spec_l160_d15_queries() !bool {
	prefix := scanner_spec_temp('bash-installed')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://ftpmirror.gnu.org/gnu/bash/bash-5.2.tar.gz', '5.2')!
	formula := scanner_core.ScannerFormula{
		name: 'bash'
		stable_url: 'https://ftpmirror.gnu.org/gnu/bash/bash-5.3.tar.gz'
		head_url: 'https://git.savannah.gnu.org/git/bash.git'
		homepage: 'https://www.gnu.org/software/bash/'
		stable_version: '5.3'
		version: '5.3'
		installed: true
		installed_prefix: prefix
		installed_version: '5.2'
		current_recipe_applies: false
	}
	scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	target := scanner.build_target(formula) or { return false }
	return target.repo_url == formula.head_url && target.tag == '5.2' && target.from_installed_sbom
}

// Ruby let `let(:act) do` at line 189.
pub fn ruby_scanner_spec_l189_d16_act() scanner_core.ScannerFormula {
	return scanner_spec_act()
}

// Ruby let `let(:openssl) do` at line 196.
pub fn ruby_scanner_spec_l196_d17_openssl() scanner_core.ScannerFormula {
	return scanner_spec_openssl()
}

// Ruby let `let(:unsupported) do` at line 203.
pub fn ruby_scanner_spec_l203_d18_unsupported() scanner_core.ScannerFormula {
	return scanner_spec_unsupported()
}

// Ruby let `let(:libquicktime) do` at line 210.
pub fn ruby_scanner_spec_l210_d19_libquicktime() scanner_core.ScannerFormula {
	return scanner_spec_libquicktime()
}

// Ruby method `osv_record(id, severity: "HIGH", **extra)` at line 222.
pub fn ruby_scanner_spec_l222_d20_osv_record(id string, severity scanner_core.OutputSeverity,
	aliases []string, affected []scanner_core.ScannerAffected) scanner_core.ScannerVulnerability {
	return scanner_spec_record(id, severity, aliases, affected)
}

// Ruby it `it "returns findings for formulae with open vulnerabilities" do` at line 230.
pub fn ruby_scanner_spec_l230_d21_returns() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_act(), scanner_spec_openssl()], [
		scanner_spec_act_batch(['CVE-2024-1111']),
	], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	if results.checked != 2 || results.skipped != 0 || !results.any_open() || results.findings.len != 1 {
		return false
	}
	finding := results.findings[0]
	return finding.name == 'act' && finding.version == '0.2.84' && finding.tag == 'v0.2.84' && finding.repo_url == 'https://github.com/nektos/act' && finding.open.map(it.id) == [
		'CVE-2024-1111',
	] && finding.patched.len == 0
}

// Ruby it `it "reports empty results when nothing is found" do` at line 250.
pub fn ruby_scanner_spec_l250_d22_reports() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_act(), scanner_spec_openssl()], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return !results.any_open() && results.findings.len == 0
}

// Ruby it `it "skips formulae without a queryable repo URL and tag" do` at line 257.
pub fn ruby_scanner_spec_l257_d23_skips() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_act(), scanner_spec_unsupported()], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return results.checked == 1 && results.skipped == 1 && scanner.last_queries.len == 1
}

// Ruby it `it "queries nothing when no formula is queryable" do` at line 268.
pub fn ruby_scanner_spec_l268_d24_queries() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_unsupported()], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return results.checked == 0 && results.skipped == 1 && results.findings.len == 0 && scanner.last_queries.len == 0
}

// Ruby it `it "fetches full records for each returned vuln id" do` at line 276.
pub fn ruby_scanner_spec_l276_d25_fetches() !bool {
	ids := ['CVE-2024-1111', 'CVE-2024-2222']
	records := [scanner_spec_record(ids[0], .critical, []string{}, []scanner_core.ScannerAffected{}),
		scanner_spec_record(ids[1], .low, []string{}, []scanner_core.ScannerAffected{})]
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [
		scanner_spec_act_batch(ids),
	], records, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return results.findings.len == 1 && results.findings[0].open.map(it.id) == ids
}

// Ruby it `it "drops vulnerabilities that do not affect the queried tag" do` at line 291.
pub fn ruby_scanner_spec_l291_d26_drops() !bool {
	vulnerability := scanner_spec_record('CVE-2024-1111', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
		scanner_core.ScannerEvent{ fixed: '0.2.0' },
	]))
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [scanner_spec_act_batch([
		vulnerability.id,
	])], [vulnerability], scanner_core.ScannerOptions{})
	return scanner.scan()!.findings.len == 0
}

// Ruby it `it "filters below the minimum severity" do` at line 305.
pub fn ruby_scanner_spec_l305_d27_filters() !bool {
	ids := ['CVE-LOW', 'CVE-CRIT']
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [
		scanner_spec_act_batch(ids),
	], [
		scanner_spec_record(ids[0], .low, []string{}, []scanner_core.ScannerAffected{}),
		scanner_spec_record(ids[1], .critical, []string{}, []scanner_core.ScannerAffected{}),
	], scanner_core.ScannerOptions{
		min_severity: .high
	})
	results := scanner.scan()!
	return results.findings[0].open.map(it.id) == ['CVE-CRIT']
}

// Ruby it `it "moves vulnerabilities resolved by formula patches into patched" do` at line 318.
pub fn ruby_scanner_spec_l318_d28_moves() !bool {
	ids := ['CVE-2016-2399', 'CVE-2024-9999']
	mut scanner := scanner_spec_scanner([scanner_spec_libquicktime()], [
		scanner_spec_libquicktime_batch(ids),
	], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	finding := results.findings[0]
	return finding.open.map(it.id) == ['CVE-2024-9999'] && finding.patched.map(it.id) == [
		'CVE-2016-2399',
	] && results.any_open()
}

// Ruby it `it "matches patch resolves against vulnerability aliases case-insensitively" do` at line 334.
pub fn ruby_scanner_spec_l334_d29_matches() !bool {
	vulnerability := scanner_spec_record('GHSA-x', .high, ['cve-2017-9122'], []scanner_core.ScannerAffected{})
	mut scanner := scanner_spec_scanner([scanner_spec_libquicktime()], [
		scanner_spec_libquicktime_batch([vulnerability.id]),
	], [vulnerability], scanner_core.ScannerOptions{})
	results := scanner.scan()!
	finding := results.findings[0]
	return finding.open.len == 0 && finding.patched.map(it.id) == ['GHSA-x'] && !results.any_open()
}

// Ruby it `it "does not conflate formulae with the same short name from different taps" do` at line 347.
pub fn ruby_scanner_spec_l347_d30_does() !bool {
	core := scanner_core.ScannerFormula{
		name: 'thing'
		full_name: 'thing'
		stable_url: 'https://github.com/owner-a/thing/archive/refs/tags/v1.0.0.tar.gz'
		stable_version: '1.0.0'
		version: '1.0.0'
	}
	tapped := scanner_core.ScannerFormula{
		name: 'thing'
		full_name: 'someone/tap/thing'
		stable_url: 'https://github.com/owner-b/thing/archive/refs/tags/v2.0.0.tar.gz'
		stable_version: '2.0.0'
		version: '2.0.0'
	}
	mut scanner := scanner_spec_scanner([core, tapped], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	_ := scanner.scan()!
	return scanner.last_queries.map(it.name) == ['https://github.com/owner-a/thing',
		'https://github.com/owner-b/thing'] && scanner.last_queries.map(it.version or { '' }) == [
		'v1.0.0',
		'v2.0.0',
	]
}

// Ruby it `it "keeps resolved vulnerabilities in open when ignore_patches is false" do` at line 372.
pub fn ruby_scanner_spec_l372_d31_keeps() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_libquicktime()], [
		scanner_spec_libquicktime_batch(['CVE-2016-2399']),
	], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{
		ignore_patches: false
	})
	finding := scanner.scan()!.findings[0]
	return finding.open.map(it.id) == ['CVE-2016-2399'] && finding.patched.len == 0
}

// Ruby it `it "does not suppress via patches when the scanned keg predates the current recipe" do` at line 381.
pub fn ruby_scanner_spec_l381_d32_does() !bool {
	formula := scanner_core.ScannerFormula{
		...scanner_spec_libquicktime()
		installed: true
		installed_prefix: '/nonexistent'
		installed_version: '1.2.3'
		current_recipe_applies: false
	}
	mut scanner := scanner_spec_scanner([formula], [scanner_spec_libquicktime_batch([
		'CVE-2016-2399',
	])], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	finding := scanner.scan()!.findings[0]
	return finding.open.map(it.id) == ['CVE-2016-2399'] && finding.patched.len == 0
}

// Ruby it `it "does not suppress when the opt-linked keg is old even if the current version is also installed" do` at line 395.
pub fn ruby_scanner_spec_l395_d33_does() !bool {
	formula := scanner_core.ScannerFormula{
		...scanner_spec_libquicktime()
		installed: true
		installed_prefix: '/nonexistent'
		installed_version: '1.2.3'
		current_recipe_applies: false
	}
	mut scanner := scanner_spec_scanner([formula], [scanner_spec_libquicktime_batch([
		'CVE-2016-2399',
	])], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return results.findings[0].open.map(it.id) == ['CVE-2016-2399'] && results.outdated_without_sbom == [
		'libquicktime',
	]
}

// Ruby it `it "suppresses via patches when the scanned keg matches the current recipe" do` at line 412.
pub fn ruby_scanner_spec_l412_d34_suppresses() !bool {
	formula := scanner_core.ScannerFormula{
		...scanner_spec_libquicktime()
		installed: true
		installed_prefix: '/nonexistent'
		installed_version: '1.2.4'
		current_recipe_applies: true
	}
	mut scanner := scanner_spec_scanner([formula], [scanner_spec_libquicktime_batch([
		'CVE-2016-2399',
	])], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	return scanner.scan()!.findings[0].patched.map(it.id) == ['CVE-2016-2399']
}

// Ruby it `it "suppresses via patches when the formula is not installed at all" do` at line 425.
pub fn ruby_scanner_spec_l425_d35_suppresses() !bool {
	mut scanner := scanner_spec_scanner([scanner_spec_libquicktime()], [
		scanner_spec_libquicktime_batch(['CVE-2016-2399']),
	], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	return scanner.scan()!.findings[0].patched.map(it.id) == ['CVE-2016-2399']
}

// Ruby let `let(:installed_prefix) { TEST_FIXTURE_DIR/"vulns" }` at line 435.
pub fn ruby_scanner_spec_l435_d36_installed_prefix() string {
	return os.join_path(os.temp_dir(), 'brew-v-scanner-installed-vulns')
}

// Ruby it `it "queries OSV using the installed keg's SBOM source URL, not the current formula" do` at line 445.
pub fn ruby_scanner_spec_l445_d37_queries() !bool {
	prefix := scanner_spec_temp('act-query-installed')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz', '0.2.80')!
	formula := scanner_core.ScannerFormula{
		...scanner_spec_act()
		installed: true
		installed_prefix: prefix
		installed_version: '0.2.80'
		current_recipe_applies: false
	}
	mut scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	_ := scanner.scan()!
	return scanner.last_queries.len == 1 && scanner.last_queries[0].name == 'https://github.com/nektos/act' && scanner.last_queries[0].version or { '' } == 'v0.2.80'
}

// Ruby it `it "reports the installed version in findings" do` at line 457.
pub fn ruby_scanner_spec_l457_d38_reports() !bool {
	prefix := scanner_spec_temp('act-report-installed')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz', '0.2.80')!
	formula := scanner_core.ScannerFormula{
		...scanner_spec_act()
		installed: true
		installed_prefix: prefix
		installed_version: '0.2.80'
		current_recipe_applies: false
	}
	batch := ScannerSpecBatch{
		repo: 'https://github.com/nektos/act'
		tag: 'v0.2.80'
		ids: ['CVE-2024-1111']
	}
	mut scanner := scanner_spec_scanner([formula], [batch], []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	finding := scanner.scan()!.findings[0]
	return finding.version == '0.2.80' && finding.tag == 'v0.2.80'
}

// Ruby it `it "filters affects_version? against the installed tag" do` at line 466.
pub fn ruby_scanner_spec_l466_d39_filters() !bool {
	prefix := scanner_spec_temp('act-affects-installed')
	defer { scanner_spec_cleanup(prefix) }
	scanner_spec_write_sbom(prefix, 'https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz', '0.2.80')!
	formula := scanner_core.ScannerFormula{
		...scanner_spec_act()
		installed: true
		installed_prefix: prefix
		installed_version: '0.2.80'
		current_recipe_applies: false
	}
	vulnerability := scanner_spec_record('CVE-2024-1111', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
		scanner_core.ScannerEvent{ fixed: '0.2.81' },
	]))
	mut scanner := scanner_spec_scanner([formula], [ScannerSpecBatch{
		repo: 'https://github.com/nektos/act'
		tag: 'v0.2.80'
		ids: [vulnerability.id]
	}], [vulnerability], scanner_core.ScannerOptions{})
	return scanner.scan()!.findings[0].open.map(it.id) == ['CVE-2024-1111']
}

// Ruby it `it "falls back to the current formula URL when the keg has no SBOM" do` at line 480.
pub fn ruby_scanner_spec_l480_d40_falls() !bool {
	formula := scanner_core.ScannerFormula{
		...scanner_spec_act()
		installed: true
		installed_prefix: '/nonexistent'
		installed_version: '0.2.80'
		current_recipe_applies: false
	}
	mut scanner := scanner_spec_scanner([formula], []ScannerSpecBatch{}, []scanner_core.ScannerVulnerability{}, scanner_core.ScannerOptions{})
	results := scanner.scan()!
	return scanner.last_queries[0].name == 'https://github.com/nektos/act' && scanner.last_queries[0].version or { '' } == 'v0.2.84' && results.outdated_without_sbom == [
		'act',
	]
}

// Ruby it `it "filters out vulnerabilities that do not have a fix available when only_fixed is true" do` at line 494.
pub fn ruby_scanner_spec_l494_d41_filters() !bool {
	no_fix := scanner_spec_record('CVE-NO-FIX', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
	]))
	with_fix := scanner_spec_record('CVE-WITH-FIX', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
		scanner_core.ScannerEvent{ fixed: '1.2.3' },
	]))
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [scanner_spec_act_batch([
		no_fix.id,
		with_fix.id,
	])], [no_fix, with_fix], scanner_core.ScannerOptions{
		only_fixed: true
	})
	return scanner.scan()!.findings[0].open.map(it.id) == ['CVE-WITH-FIX']
}

// Ruby it `it "filters out vulnerabilities that do have a fix available when except_fixed is true" do` at line 518.
pub fn ruby_scanner_spec_l518_d42_filters() !bool {
	no_fix := scanner_spec_record('CVE-NO-FIX', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
	]))
	with_fix := scanner_spec_record('CVE-WITH-FIX', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
		scanner_core.ScannerEvent{ fixed: '1.2.3' },
	]))
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [scanner_spec_act_batch([
		no_fix.id,
		with_fix.id,
	])], [no_fix, with_fix], scanner_core.ScannerOptions{
		except_fixed: true
	})
	return scanner.scan()!.findings[0].open.map(it.id) == ['CVE-NO-FIX']
}

// Ruby it `it "filters out vulnerabilities that are matched in an open-ended interval when only_fixed is true" do` at line 542.
pub fn ruby_scanner_spec_l542_d43_filters() !bool {
	vulnerability := scanner_spec_record('CVE-REOPENED', .high, []string{}, scanner_spec_semver([
		scanner_core.ScannerEvent{ introduced: '0' },
		scanner_core.ScannerEvent{ fixed: '0.2.80' },
		scanner_core.ScannerEvent{ introduced: '0.2.83' },
	]))
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [scanner_spec_act_batch([
		vulnerability.id,
	])], [vulnerability], scanner_core.ScannerOptions{
		only_fixed: true
	})
	return scanner.scan()!.findings.len == 0
}

// Ruby it `it "treats a reopened GIT range with no closing fixed event as no fix available" do` at line 562.
pub fn ruby_scanner_spec_l562_d44_treats() !bool {
	vulnerability := scanner_spec_record('CVE-GIT-REOPENED', .high, []string{}, scanner_spec_git([
		scanner_core.ScannerEvent{ introduced: 'abc1234' },
		scanner_core.ScannerEvent{ fixed: 'def5678' },
		scanner_core.ScannerEvent{ introduced: 'ghi9012' },
	]))
	mut scanner := scanner_spec_scanner([scanner_spec_act()], [scanner_spec_act_batch([
		vulnerability.id,
	])], [vulnerability], scanner_core.ScannerOptions{
		only_fixed: true
	})
	return scanner.scan()!.findings.len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/scanner"
// 5:
// 6: RSpec.describe Homebrew::Vulns::Scanner do
// 7:   describe ".resolved_ids" do
// 8:     it "collects security-type resolves across all patches, uppercased and deduplicated" do
// 9:       patches = [
// 10:         { "url"      => "https://deb.debian.org/foo.debian.tar.xz",
// 11:           "resolves" => [{ "type" => "security", "id" => "CVE-2016-2399" },
// 12:                          { "type" => "security", "id" => "CVE-2017-9122" }] },
// 13:         { "url"      => "https://example.com/extra.diff",
// 14:           "resolves" => [{ "type" => "security", "id" => "GHSA-xr7r-f8xq-vfvv" },
// 15:                          { "type" => "security", "id" => "CVE-2017-9122" }] },
// 16:       ]
// 17:       expect(described_class.resolved_ids(patches))
// 18:         .to eq ["CVE-2016-2399", "CVE-2017-9122", "GHSA-XR7R-F8XQ-VFVV"]
// 19:     end
// 20:
// 21:     it "ignores defect-type resolves" do
// 22:       patches = [
// 23:         { "resolves" => [{ "type" => "defect", "id" => "https://bugs.example.com/1234" },
// 24:                          { "type" => "security", "id" => "CVE-2024-0001" }] },
// 25:       ]
// 26:       expect(described_class.resolved_ids(patches)).to eq ["CVE-2024-0001"]
// 27:     end
// 28:
// 29:     it "returns empty for no patches" do
// 30:       expect(described_class.resolved_ids([])).to eq []
// 31:     end
// 32:
// 33:     it "handles patches without a resolves key" do
// 34:       expect(described_class.resolved_ids([{ "url" => "https://example.com/x.diff" }])).to eq []
// 35:     end
// 36:   end
// 37:
// 38:   describe ".source_from_sbom" do
// 39:     it "returns the -src package downloadLocation and versionInfo" do
// 40:       prefix = TEST_FIXTURE_DIR/"vulns"
// 41:       expect(described_class.source_from_sbom(prefix))
// 42:         .to eq ["https://github.com/nektos/act/archive/refs/tags/v0.2.80.tar.gz", "0.2.80"]
// 43:     end
// 44:
// 45:     it "returns nil when no SBOM file exists" do
// 46:       expect(described_class.source_from_sbom(Pathname("/nonexistent"))).to be_nil
// 47:     end
// 48:
// 49:     it "returns the versionInfo when downloadLocation is NOASSERTION" do
// 50:       Dir.mktmpdir do |dir|
// 51:         prefix = Pathname(dir)
// 52:         (prefix/"sbom.spdx.json").write JSON.generate(
// 53:           packages: [{ SPDXID: "SPDXRef-Archive-x-src", downloadLocation: "NOASSERTION", versionInfo: "1.2.3" }],
// 54:         )
// 55:         expect(described_class.source_from_sbom(prefix)).to eq [nil, "1.2.3"]
// 56:       end
// 57:     end
// 58:
// 59:     it "returns nil when both downloadLocation and versionInfo are NOASSERTION" do
// 60:       Dir.mktmpdir do |dir|
// 61:         prefix = Pathname(dir)
// 62:         (prefix/"sbom.spdx.json").write JSON.generate(
// 63:           packages: [{ SPDXID:           "SPDXRef-Archive-x-src",
// 64:                        downloadLocation: "NOASSERTION",
// 65:                        versionInfo:      "NOASSERTION" }],
// 66:         )
// 67:         expect(described_class.source_from_sbom(prefix)).to be_nil
// 68:       end
// 69:     end
// 70:
// 71:     it "returns nil when the SBOM is unparseable" do
// 72:       Dir.mktmpdir do |dir|
// 73:         prefix = Pathname(dir)
// 74:         (prefix/"sbom.spdx.json").write "not json"
// 75:         expect(described_class.source_from_sbom(prefix)).to be_nil
// 76:       end
// 77:     end
// 78:   end
// 79:
// 80:   describe "#build_target" do
// 81:     it "derives repo from head and tag from stable version for a non-forge tarball" do
// 82:       curl = formula("curl") do
// 83:         T.bind(self, T.class_of(Formula))
// 84:         url "https://curl.se/download/curl-8.5.0.tar.bz2"
// 85:         head "https://github.com/curl/curl.git"
// 86:       end
// 87:
// 88:       target = described_class.new([curl]).build_target(curl)
// 89:
// 90:       expect(target.repo_url).to eq "https://github.com/curl/curl"
// 91:       expect(target.tag).to eq "8.5.0"
// 92:       expect(target.version).to eq "8.5.0"
// 93:     end
// 94:
// 95:     it "queries a non-forge head URL verbatim when no candidate is a supported forge" do
// 96:       bash = formula("bash") do
// 97:         T.bind(self, T.class_of(Formula))
// 98:         homepage "https://www.gnu.org/software/bash/"
// 99:         url "https://ftpmirror.gnu.org/gnu/bash/bash-5.3.tar.gz"
// 100:         head "https://git.savannah.gnu.org/git/bash.git"
// 101:       end
// 102:
// 103:       target = described_class.new([bash]).build_target(bash)
// 104:
// 105:       expect(target.repo_url).to eq "https://git.savannah.gnu.org/git/bash.git"
// 106:       expect(target.tag).to eq "5.3"
// 107:     end
// 108:
// 109:     it "queries a non-forge stable URL verbatim when its path yields a tag" do
// 110:       thing = formula("thing") do
// 111:         T.bind(self, T.class_of(Formula))
// 112:         url "https://gitea.example.com/owner/thing/archive/v1.2.3.tar.gz"
// 113:       end
// 114:
// 115:       target = described_class.new([thing]).build_target(thing)
// 116:
// 117:       expect(target.repo_url).to eq "https://gitea.example.com/owner/thing/archive/v1.2.3.tar.gz"
// 118:       expect(target.tag).to eq "v1.2.3"
// 119:     end
// 120:
// 121:     it "prefers an explicit stable tag over the derived version" do
// 122:       aom = formula("aom") do
// 123:         T.bind(self, T.class_of(Formula))
// 124:         homepage "https://github.com/AomediaOrg/aom"
// 125:         url "https://aomedia.googlesource.com/aom.git", tag: "v3.13.1"
// 126:       end
// 127:
// 128:       target = described_class.new([aom]).build_target(aom)
// 129:
// 130:       expect(target.repo_url).to eq "https://github.com/aomediaorg/aom"
// 131:       expect(target.tag).to eq "v3.13.1"
// 132:     end
// 133:
// 134:     it "queries the SBOM versionInfo when the SBOM downloadLocation has no extractable tag" do
// 135:       curl = formula("curl") do
// 136:         T.bind(self, T.class_of(Formula))
// 137:         url "https://curl.se/download/curl-8.5.0.tar.bz2"
// 138:         head "https://github.com/curl/curl.git"
// 139:       end
// 140:       Dir.mktmpdir do |dir|
// 141:         prefix = Pathname(dir)
// 142:         (prefix/"sbom.spdx.json").write JSON.generate(
// 143:           packages: [{ SPDXID:           "SPDXRef-Archive-curl-src",
// 144:                        downloadLocation: "https://curl.se/download/curl-8.4.0.tar.bz2",
// 145:                        versionInfo:      "8.4.0" }],
// 146:         )
// 147:         allow(curl).to receive_messages(
// 148:           any_installed_prefix:  prefix,
// 149:           any_installed_version: PkgVersion.parse("8.4.0"),
// 150:         )
// 151:
// 152:         target = described_class.new([curl]).build_target(curl)
// 153:
// 154:         expect(target.repo_url).to eq "https://github.com/curl/curl"
// 155:         expect(target.tag).to eq "8.4.0"
// 156:         expect(target.from_installed_sbom).to be true
// 157:       end
// 158:     end
// 159:
// 160:     it "queries a non-forge head URL verbatim when the SBOM downloadLocation host is unsupported" do
// 161:       bash = formula("bash") do
// 162:         T.bind(self, T.class_of(Formula))
// 163:         homepage "https://www.gnu.org/software/bash/"
// 164:         url "https://ftpmirror.gnu.org/gnu/bash/bash-5.3.tar.gz"
// 165:         head "https://git.savannah.gnu.org/git/bash.git"
// 166:       end
// 167:       Dir.mktmpdir do |dir|
// 168:         prefix = Pathname(dir)
// 169:         (prefix/"sbom.spdx.json").write JSON.generate(
// 170:           packages: [{ SPDXID:           "SPDXRef-Archive-bash-src",
// 171:                        downloadLocation: "https://ftpmirror.gnu.org/gnu/bash/bash-5.2.tar.gz",
// 172:                        versionInfo:      "5.2" }],
// 173:         )
// 174:         allow(bash).to receive_messages(
// 175:           any_installed_prefix:  prefix,
// 176:           any_installed_version: PkgVersion.parse("5.2"),
// 177:         )
// 178:
// 179:         target = described_class.new([bash]).build_target(bash)
// 180:
// 181:         expect(target.repo_url).to eq "https://git.savannah.gnu.org/git/bash.git"
// 182:         expect(target.tag).to eq "5.2"
// 183:         expect(target.from_installed_sbom).to be true
// 184:       end
// 185:     end
// 186:   end
// 187:
// 188:   describe "#scan" do
// 189:     let(:act) do
// 190:       formula("act") do
// 191:         T.bind(self, T.class_of(Formula))
// 192:         url "https://github.com/nektos/act/archive/refs/tags/v0.2.84.tar.gz"
// 193:       end
// 194:     end
// 195:
// 196:     let(:openssl) do
// 197:       formula("openssl@3") do
// 198:         T.bind(self, T.class_of(Formula))
// 199:         url "https://github.com/openssl/openssl/releases/download/openssl-3.0.0/openssl-3.0.0.tar.gz"
// 200:       end
// 201:     end
// 202:
// 203:     let(:unsupported) do
// 204:       formula("aom") do
// 205:         T.bind(self, T.class_of(Formula))
// 206:         url "https://aomedia.googlesource.com/aom.git", tag: "v3.13.1"
// 207:       end
// 208:     end
// 209:
// 210:     let(:libquicktime) do
// 211:       formula("libquicktime") do
// 212:         T.bind(self, T.class_of(Formula))
// 213:         url "https://github.com/owner/libquicktime/archive/refs/tags/v1.2.4.tar.gz"
// 214:         patch do
// 215:           url "https://deb.debian.org/debian/pool/main/libq/libquicktime/libquicktime_1.2.4-12.debian.tar.xz"
// 216:           sha256 "abc"
// 217:           resolves "CVE-2016-2399", "CVE-2017-9122"
// 218:         end
// 219:       end
// 220:     end
// 221:
// 222:     def osv_record(id, severity: "HIGH", **extra)
// 223:       { "id" => id, "database_specific" => { "severity" => severity } }.merge(extra)
// 224:     end
// 225:
// 226:     before do
// 227:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability) { |id| osv_record(id) }
// 228:     end
// 229:
// 230:     it "returns findings for formulae with open vulnerabilities" do
// 231:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return(
// 232:         [[{ "id" => "CVE-2024-1111" }], []],
// 233:       )
// 234:
// 235:       results = described_class.new([act, openssl]).scan
// 236:
// 237:       expect(results.checked).to eq 2
// 238:       expect(results.skipped).to eq 0
// 239:       expect(results.any_open?).to be true
// 240:       expect(results.findings.size).to eq 1
// 241:       f = results.findings.first
// 242:       expect(f.name).to eq "act"
// 243:       expect(f.version).to eq "0.2.84"
// 244:       expect(f.tag).to eq "v0.2.84"
// 245:       expect(f.repo_url).to eq "https://github.com/nektos/act"
// 246:       expect(f.open.map(&:id)).to eq ["CVE-2024-1111"]
// 247:       expect(f.patched).to eq []
// 248:     end
// 249:
// 250:     it "reports empty results when nothing is found" do
// 251:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[], []])
// 252:       results = described_class.new([act, openssl]).scan
// 253:       expect(results.any_open?).to be false
// 254:       expect(results.findings).to eq []
// 255:     end
// 256:
// 257:     it "skips formulae without a queryable repo URL and tag" do
// 258:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).with(
// 259:         [{ ecosystem: "GIT", name: "https://github.com/nektos/act", version: "v0.2.84" }],
// 260:       ).and_return([[]])
// 261:
// 262:       results = described_class.new([act, unsupported]).scan
// 263:
// 264:       expect(results.checked).to eq 1
// 265:       expect(results.skipped).to eq 1
// 266:     end
// 267:
// 268:     it "queries nothing when no formula is queryable" do
// 269:       expect(Homebrew::Vulns::OSV).not_to receive(:query_batch)
// 270:       results = described_class.new([unsupported]).scan
// 271:       expect(results.checked).to eq 0
// 272:       expect(results.skipped).to eq 1
// 273:       expect(results.findings).to eq []
// 274:     end
// 275:
// 276:     it "fetches full records for each returned vuln id" do
// 277:       allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 278:         .and_return([[{ "id" => "CVE-2024-1111" }, { "id" => "CVE-2024-2222" }]])
// 279:       expect(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-1111").and_return(
// 280:         osv_record("CVE-2024-1111", severity: "CRITICAL"),
// 281:       )
// 282:       expect(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-2222").and_return(
// 283:         osv_record("CVE-2024-2222", severity: "LOW"),
// 284:       )
// 285:
// 286:       results = described_class.new([act]).scan
// 287:
// 288:       expect(results.findings.first.open.map(&:id)).to contain_exactly("CVE-2024-1111", "CVE-2024-2222")
// 289:     end
// 290:
// 291:     it "drops vulnerabilities that do not affect the queried tag" do
// 292:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2024-1111" }]])
// 293:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-1111").and_return(
// 294:         osv_record("CVE-2024-1111",
// 295:                    "affected" => [{ "ranges" => [{ "type"   => "SEMVER",
// 296:                                                    "events" => [{ "introduced" => "0" },
// 297:                                                                 { "fixed" => "0.2.0" }] }] }]),
// 298:       )
// 299:
// 300:       results = described_class.new([act]).scan
// 301:
// 302:       expect(results.findings).to eq []
// 303:     end
// 304:
// 305:     it "filters below the minimum severity" do
// 306:       allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 307:         .and_return([[{ "id" => "CVE-LOW" }, { "id" => "CVE-CRIT" }]])
// 308:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-LOW")
// 309:                                                             .and_return(osv_record("CVE-LOW", severity: "LOW"))
// 310:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-CRIT")
// 311:                                                             .and_return(osv_record("CVE-CRIT", severity: "CRITICAL"))
// 312:
// 313:       results = described_class.new([act], min_severity: :high).scan
// 314:
// 315:       expect(results.findings.first.open.map(&:id)).to eq ["CVE-CRIT"]
// 316:     end
// 317:
// 318:     it "moves vulnerabilities resolved by formula patches into patched" do
// 319:       allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 320:         .and_return([[{ "id" => "CVE-2016-2399" }, { "id" => "CVE-2024-9999" }]])
// 321:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2016-2399")
// 322:                                                             .and_return(osv_record("CVE-2016-2399"))
// 323:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-9999")
// 324:                                                             .and_return(osv_record("CVE-2024-9999"))
// 325:
// 326:       results = described_class.new([libquicktime]).scan
// 327:
// 328:       finding = results.findings.first
// 329:       expect(finding.open.map(&:id)).to eq ["CVE-2024-9999"]
// 330:       expect(finding.patched.map(&:id)).to eq ["CVE-2016-2399"]
// 331:       expect(results.any_open?).to be true
// 332:     end
// 333:
// 334:     it "matches patch resolves against vulnerability aliases case-insensitively" do
// 335:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "GHSA-x" }]])
// 336:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("GHSA-x")
// 337:                                                             .and_return(osv_record("GHSA-x",
// 338:                                                                                    "aliases" => ["cve-2017-9122"]))
// 339:
// 340:       results = described_class.new([libquicktime]).scan
// 341:
// 342:       expect(results.findings.first.open).to eq []
// 343:       expect(results.findings.first.patched.map(&:id)).to eq ["GHSA-x"]
// 344:       expect(results.any_open?).to be false
// 345:     end
// 346:
// 347:     it "does not conflate formulae with the same short name from different taps" do
// 348:       core_thing = formula("thing", tap: CoreTap.instance) do
// 349:         T.bind(self, T.class_of(Formula))
// 350:         url "https://github.com/owner-a/thing/archive/refs/tags/v1.0.0.tar.gz"
// 351:       end
// 352:       tap_thing = formula("thing", tap: Tap.fetch("someone", "tap")) do
// 353:         T.bind(self, T.class_of(Formula))
// 354:         url "https://github.com/owner-b/thing/archive/refs/tags/v2.0.0.tar.gz"
// 355:       end
// 356:       expect(core_thing.name).to eq tap_thing.name
// 357:
// 358:       queried = nil
// 359:       allow(Homebrew::Vulns::OSV).to receive(:query_batch) do |packages|
// 360:         queried = packages
// 361:         Array.new(packages.size) { [] }
// 362:       end
// 363:
// 364:       described_class.new([core_thing, tap_thing]).scan
// 365:
// 366:       expect(queried).to eq [
// 367:         { ecosystem: "GIT", name: "https://github.com/owner-a/thing", version: "v1.0.0" },
// 368:         { ecosystem: "GIT", name: "https://github.com/owner-b/thing", version: "v2.0.0" },
// 369:       ]
// 370:     end
// 371:
// 372:     it "keeps resolved vulnerabilities in open when ignore_patches is false" do
// 373:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2016-2399" }]])
// 374:
// 375:       results = described_class.new([libquicktime], ignore_patches: false).scan
// 376:
// 377:       expect(results.findings.first.open.map(&:id)).to eq ["CVE-2016-2399"]
// 378:       expect(results.findings.first.patched).to eq []
// 379:     end
// 380:
// 381:     it "does not suppress via patches when the scanned keg predates the current recipe" do
// 382:       allow(libquicktime).to receive_messages(
// 383:         any_installed_prefix:  Pathname("/nonexistent"),
// 384:         any_installed_version: PkgVersion.parse("1.2.3"),
// 385:         installed_kegs:        [instance_double(Keg, version: PkgVersion.parse("1.2.3"))],
// 386:       )
// 387:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2016-2399" }]])
// 388:
// 389:       results = described_class.new([libquicktime]).scan
// 390:
// 391:       expect(results.findings.first.open.map(&:id)).to eq ["CVE-2016-2399"]
// 392:       expect(results.findings.first.patched).to eq []
// 393:     end
// 394:
// 395:     it "does not suppress when the opt-linked keg is old even if the current version is also installed" do
// 396:       allow(libquicktime).to receive_messages(
// 397:         any_installed_prefix:      Pathname("/nonexistent"),
// 398:         any_installed_version:     PkgVersion.parse("1.2.3"),
// 399:         installed_kegs:            [instance_double(Keg, version: PkgVersion.parse("1.2.3")),
// 400:                                     instance_double(Keg, version: libquicktime.pkg_version)],
// 401:         latest_version_installed?: true,
// 402:       )
// 403:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2016-2399" }]])
// 404:
// 405:       results = described_class.new([libquicktime]).scan
// 406:
// 407:       expect(results.findings.first.open.map(&:id)).to eq ["CVE-2016-2399"]
// 408:       expect(results.findings.first.patched).to eq []
// 409:       expect(results.outdated_without_sbom).to eq ["libquicktime"]
// 410:     end
// 411:
// 412:     it "suppresses via patches when the scanned keg matches the current recipe" do
// 413:       allow(libquicktime).to receive_messages(
// 414:         any_installed_prefix:  Pathname("/nonexistent"),
// 415:         any_installed_version: libquicktime.pkg_version,
// 416:         installed_kegs:        [instance_double(Keg, version: libquicktime.pkg_version)],
// 417:       )
// 418:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2016-2399" }]])
// 419:
// 420:       results = described_class.new([libquicktime]).scan
// 421:
// 422:       expect(results.findings.first.patched.map(&:id)).to eq ["CVE-2016-2399"]
// 423:     end
// 424:
// 425:     it "suppresses via patches when the formula is not installed at all" do
// 426:       allow(libquicktime).to receive(:installed_kegs).and_return([])
// 427:       allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2016-2399" }]])
// 428:
// 429:       results = described_class.new([libquicktime]).scan
// 430:
// 431:       expect(results.findings.first.patched.map(&:id)).to eq ["CVE-2016-2399"]
// 432:     end
// 433:
// 434:     context "when an outdated keg is installed" do
// 435:       let(:installed_prefix) { TEST_FIXTURE_DIR/"vulns" }
// 436:
// 437:       before do
// 438:         allow(act).to receive_messages(
// 439:           any_installed_prefix:  installed_prefix,
// 440:           any_installed_version: PkgVersion.parse("0.2.80"),
// 441:           installed_kegs:        [instance_double(Keg, version: PkgVersion.parse("0.2.80"))],
// 442:         )
// 443:       end
// 444:
// 445:       it "queries OSV using the installed keg's SBOM source URL, not the current formula" do
// 446:         queried = nil
// 447:         allow(Homebrew::Vulns::OSV).to receive(:query_batch) do |packages|
// 448:           queried = packages
// 449:           Array.new(packages.size) { [] }
// 450:         end
// 451:
// 452:         described_class.new([act]).scan
// 453:
// 454:         expect(queried).to eq [{ ecosystem: "GIT", name: "https://github.com/nektos/act", version: "v0.2.80" }]
// 455:       end
// 456:
// 457:       it "reports the installed version in findings" do
// 458:         allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2024-1111" }]])
// 459:
// 460:         results = described_class.new([act]).scan
// 461:
// 462:         expect(results.findings.first.version).to eq "0.2.80"
// 463:         expect(results.findings.first.tag).to eq "v0.2.80"
// 464:       end
// 465:
// 466:       it "filters affects_version? against the installed tag" do
// 467:         allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2024-1111" }]])
// 468:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-1111").and_return(
// 469:           osv_record("CVE-2024-1111",
// 470:                      "affected" => [{ "ranges" => [{ "type"   => "SEMVER",
// 471:                                                      "events" => [{ "introduced" => "0" },
// 472:                                                                   { "fixed" => "0.2.81" }] }] }]),
// 473:         )
// 474:
// 475:         results = described_class.new([act]).scan
// 476:
// 477:         expect(results.findings.first.open.map(&:id)).to eq ["CVE-2024-1111"]
// 478:       end
// 479:
// 480:       it "falls back to the current formula URL when the keg has no SBOM" do
// 481:         allow(act).to receive(:any_installed_prefix).and_return(Pathname("/nonexistent"))
// 482:         queried = nil
// 483:         allow(Homebrew::Vulns::OSV).to receive(:query_batch) do |packages|
// 484:           queried = packages
// 485:           Array.new(packages.size) { [] }
// 486:         end
// 487:
// 488:         results = described_class.new([act]).scan
// 489:
// 490:         expect(queried).to eq [{ ecosystem: "GIT", name: "https://github.com/nektos/act", version: "v0.2.84" }]
// 491:         expect(results.outdated_without_sbom).to eq ["act"]
// 492:       end
// 493:
// 494:       it "filters out vulnerabilities that do not have a fix available when only_fixed is true" do
// 495:         no_fix_vuln = osv_record("CVE-NO-FIX", "affected" => [{
// 496:           "ranges" => [{
// 497:             "type"   => "SEMVER",
// 498:             "events" => [{ "introduced" => "0" }],
// 499:           }],
// 500:         }])
// 501:         with_fix_vuln = osv_record("CVE-WITH-FIX", "affected" => [{
// 502:           "ranges" => [{
// 503:             "type"   => "SEMVER",
// 504:             "events" => [{ "introduced" => "0" }, { "fixed" => "1.2.3" }],
// 505:           }],
// 506:         }])
// 507:
// 508:         allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 509:           .and_return([[{ "id" => "CVE-NO-FIX" }, { "id" => "CVE-WITH-FIX" }]])
// 510:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-NO-FIX").and_return(no_fix_vuln)
// 511:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-WITH-FIX").and_return(with_fix_vuln)
// 512:
// 513:         results = described_class.new([act], only_fixed: true).scan
// 514:
// 515:         expect(results.findings.first.open.map(&:id)).to eq ["CVE-WITH-FIX"]
// 516:       end
// 517:
// 518:       it "filters out vulnerabilities that do have a fix available when except_fixed is true" do
// 519:         no_fix_vuln = osv_record("CVE-NO-FIX", "affected" => [{
// 520:           "ranges" => [{
// 521:             "type"   => "SEMVER",
// 522:             "events" => [{ "introduced" => "0" }],
// 523:           }],
// 524:         }])
// 525:         with_fix_vuln = osv_record("CVE-WITH-FIX", "affected" => [{
// 526:           "ranges" => [{
// 527:             "type"   => "SEMVER",
// 528:             "events" => [{ "introduced" => "0" }, { "fixed" => "1.2.3" }],
// 529:           }],
// 530:         }])
// 531:
// 532:         allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 533:           .and_return([[{ "id" => "CVE-NO-FIX" }, { "id" => "CVE-WITH-FIX" }]])
// 534:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-NO-FIX").and_return(no_fix_vuln)
// 535:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-WITH-FIX").and_return(with_fix_vuln)
// 536:
// 537:         results = described_class.new([act], except_fixed: true).scan
// 538:
// 539:         expect(results.findings.first.open.map(&:id)).to eq ["CVE-NO-FIX"]
// 540:       end
// 541:
// 542:       it "filters out vulnerabilities that are matched in an open-ended interval when only_fixed is true" do
// 543:         reopened_vuln = osv_record("CVE-REOPENED", "affected" => [{
// 544:           "ranges" => [{
// 545:             "type"   => "SEMVER",
// 546:             "events" => [
// 547:               { "introduced" => "0" },
// 548:               { "fixed" => "0.2.80" },
// 549:               { "introduced" => "0.2.83" },
// 550:             ],
// 551:           }],
// 552:         }])
// 553:
// 554:         allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-REOPENED" }]])
// 555:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-REOPENED").and_return(reopened_vuln)
// 556:
// 557:         results = described_class.new([act], only_fixed: true).scan
// 558:
// 559:         expect(results.findings).to be_empty
// 560:       end
// 561:
// 562:       it "treats a reopened GIT range with no closing fixed event as no fix available" do
// 563:         reopened_git_vuln = osv_record("CVE-GIT-REOPENED", "affected" => [{
// 564:           "ranges" => [{
// 565:             "type"   => "GIT",
// 566:             "events" => [
// 567:               { "introduced" => "abc1234" },
// 568:               { "fixed" => "def5678" },
// 569:               { "introduced" => "ghi9012" },
// 570:             ],
// 571:           }],
// 572:         }])
// 573:
// 574:         allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-GIT-REOPENED" }]])
// 575:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-GIT-REOPENED").and_return(reopened_git_vuln)
// 576:
// 577:         results = described_class.new([act], only_fixed: true).scan
// 578:
// 579:         expect(results.findings).to be_empty
// 580:       end
// 581:     end
// 582:   end
// 583: end
