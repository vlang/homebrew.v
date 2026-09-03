module vulns

import homebrew.vulns as osv_export
import os
import x.json2

// Translated from Homebrew/brew `test/vulns/osv_export_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const osv_export_spec_now = '2026-06-28T12:00:00Z'
const osv_export_spec_earlier = '2026-06-01T00:00:00Z'

fn osv_export_spec_nvi_fixture(revision int) osv_export.OsvExportFormula {
	pkg_version := if revision == 0 { '1.81.6' } else { '1.81.6_${revision}' }
	return osv_export.OsvExportFormula{
		name: 'nvi'
		pkg_version: pkg_version
		serialized_patches: [osv_export.OsvExportPatch{
			file: 'Patches/nvi/patch-common__db.h'
		}, osv_export.OsvExportPatch{
			patch_type: 'backport'
			url: 'https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6-17.debian.tar.xz'
			apply: ['patches/31regex_heap_overflow.patch']
			resolves: [osv_export.OsvExportResolve{
				resolve_type: 'security'
				id: 'CVE-2015-2305'
			}]
		}]
	}
}

fn osv_export_spec_libquicktime_fixture() osv_export.OsvExportFormula {
	return osv_export.OsvExportFormula{
		name: 'libquicktime'
		pkg_version: '1.2.4_5'
		serialized_patches: [osv_export.OsvExportPatch{
			url: 'https://deb.debian.org/debian/pool/main/libq/libquicktime/libquicktime_1.2.4-12.debian.tar.xz'
			resolves: [osv_export.OsvExportResolve{
				resolve_type: 'security'
				id: 'CVE-2016-2399'
			}, osv_export.OsvExportResolve{
				resolve_type: 'security'
				id: 'CVE-2017-9122'
			}]
		}]
	}
}

fn osv_export_spec_fetch_empty(_ string) !osv_export.OsvExportUpstream {
	return osv_export.OsvExportUpstream{}
}

fn osv_export_spec_fetch_enriched(_ string) !osv_export.OsvExportUpstream {
	return osv_export.OsvExportUpstream{
		summary: 'New summary'
	}
}

fn osv_export_spec_fetch_cached(_ string) !osv_export.OsvExportUpstream {
	return osv_export.OsvExportUpstream{
		summary: 'Cached summary'
		aliases: ['GHSA-aaaa-bbbb-cccc']
	}
}

fn osv_export_spec_fetch_failed(_ string) !osv_export.OsvExportUpstream {
	return error('OSV unavailable')
}

fn osv_export_spec_fetch_count_path() string {
	return os.join_path(os.temp_dir(), 'brew-v-osv-export-fetch-count-${os.getpid()}')
}

fn osv_export_spec_fetch_counted(_ string) !osv_export.OsvExportUpstream {
	path := osv_export_spec_fetch_count_path()
	count := (os.read_file(path) or { '0' }).int() + 1
	os.write_file(path, count.str())!
	return osv_export.OsvExportUpstream{}
}

fn osv_export_spec_first_fixed(_ osv_export.OsvExportFormula, _ string) ?string {
	return '1.2.4_2'
}

fn osv_export_spec_no_fixed(_ osv_export.OsvExportFormula, _ string) ?string {
	return none
}

fn osv_export_spec_dir(name string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-osv-export-${os.getpid()}-${name}')
	os.rmdir_all(path) or {}
	os.mkdir_all(path)!
	return path
}

fn osv_export_spec_record(formula osv_export.OsvExportFormula, id string,
	patches []osv_export.OsvExportPatch, fixed string,
	upstream ?osv_export.OsvExportUpstream, now string) osv_export.OsvExportRecord {
	return osv_export.ruby_osv_export_l121_d3_self_record_for(formula, id, patches, fixed, upstream, now)
}

fn osv_export_spec_run(formula osv_export.OsvExportFormula, dir string,
	options osv_export.OsvExportRunOptions) ![]string {
	return osv_export.ruby_osv_export_l54_d1_self_run([osv_export.OsvExportAnnotated{
		formula: formula
		patches: formula.serialized_patches
	}], dir, options)
}

fn osv_export_spec_read(path string) !osv_export.OsvExportRecord {
	return json2.decode[osv_export.OsvExportRecord](os.read_file(path)!)!
}

// Ruby let `let(:now) { Time.utc(2026, 6, 28, 12, 0, 0) }` at line 7.
pub fn ruby_osv_export_spec_l7_d1_now() string {
	return osv_export_spec_now
}

// Ruby let `let(:nvi) do` at line 9.
pub fn ruby_osv_export_spec_l9_d2_nvi() osv_export.OsvExportFormula {
	return osv_export_spec_nvi_fixture(6)
}

// Ruby let `let(:libquicktime) do` at line 28.
pub fn ruby_osv_export_spec_l28_d3_libquicktime() osv_export.OsvExportFormula {
	return osv_export_spec_libquicktime_fixture()
}

// Ruby it `it "builds a minimal record without upstream data" do` at line 42.
pub fn ruby_osv_export_spec_l42_d4_builds() bool {
	formula := osv_export_spec_nvi_fixture(6)
	record := osv_export_spec_record(formula, 'CVE-2015-2305', formula.serialized_patches, formula.pkg_version, none, osv_export_spec_now)
	return record.schema_version == '1.7.3' && record.id == 'BREW-nvi-CVE-2015-2305' && record.published == osv_export_spec_now && record.modified == osv_export_spec_now && record.upstream == [
		'CVE-2015-2305',
	] && record.database_specific.source == 'generated' && record.summary == none && record.references.len == 0
}

// Ruby it `it "populates affected package and range" do` at line 55.
pub fn ruby_osv_export_spec_l55_d5_populates() bool {
	formula := osv_export_spec_nvi_fixture(6)
	affected := osv_export.ruby_osv_export_l157_d4_self_affected_entry(formula, 'CVE-2015-2305', formula.serialized_patches, formula.pkg_version)
	return affected.package.ecosystem == 'Homebrew' && affected.package.name == 'nvi' && affected.package.purl == 'pkg:brew/nvi' && affected.ranges[0].events[0].introduced == '0' && affected.ranges[0].events[1].fixed == '1.81.6_6'
}

// Ruby it `it "lists only the patches that resolve the given id in ecosystem_specific" do` at line 64.
pub fn ruby_osv_export_spec_l64_d6_lists() bool {
	formula := osv_export_spec_nvi_fixture(6)
	affected := osv_export.osv_export_affected_entry(formula, 'CVE-2015-2305', formula.serialized_patches, formula.pkg_version)
	refs := affected.ecosystem_specific.patches
	return affected.ecosystem_specific.fix == 'patch' && refs.len == 1 && refs[0].patch_type == 'backport' && refs[0].apply == [
		'patches/31regex_heap_overflow.patch',
	]
}

// Ruby it `it "emits file for local patches and drops entries with no locator" do` at line 77.
pub fn ruby_osv_export_spec_l77_d7_emits() bool {
	patches := [osv_export.OsvExportPatch{
		file: 'Patches/x/fix.patch'
		resolves: [osv_export.OsvExportResolve{
			resolve_type: 'security'
			id: 'CVE-2024-0001'
		}]
	}, osv_export.OsvExportPatch{
		url: 'https://example.com/x/fix.patch'
		resolves: [osv_export.OsvExportResolve{
			resolve_type: 'security'
			id: 'CVE-2024-0001'
		}]
	}, osv_export.OsvExportPatch{
		resolves: [osv_export.OsvExportResolve{
			resolve_type: 'security'
			id: 'CVE-2024-0001'
		}]
	}]
	refs := osv_export.osv_export_affected_entry(osv_export.OsvExportFormula{
		name: 'x'
		pkg_version: '1.0'
	}, 'CVE-2024-0001', patches, '1.0').ecosystem_specific.patches
	return refs.len == 2 && refs[0].file == 'Patches/x/fix.patch' && refs[1].url == 'https://example.com/x/fix.patch'
}

// Ruby it `it "reads the given patches list rather than the formula's own serialized_patches" do` at line 99.
pub fn ruby_osv_export_spec_l99_d8_reads() bool {
	patches := [osv_export.OsvExportPatch{
		url: 'https://example.com/linux.patch'
		resolves: [osv_export.OsvExportResolve{
			resolve_type: 'security'
			id: 'CVE-2024-0003'
		}]
	}]
	refs := osv_export.osv_export_affected_entry(osv_export.OsvExportFormula{
		name: 'x'
		pkg_version: '1.0'
	}, 'CVE-2024-0003', patches, '1.0').ecosystem_specific.patches
	return refs.len == 1 && refs[0].url == 'https://example.com/linux.patch'
}

// Ruby it `it "merges upstream summary, details, aliases, severity and references" do` at line 110.
pub fn ruby_osv_export_spec_l110_d9_merges() bool {
	formula := osv_export_spec_nvi_fixture(6)
	upstream := osv_export.OsvExportUpstream{
		summary: 'Integer overflow in regcomp'
		details: 'Long description.'
		aliases: ['GHSA-aaaa-bbbb-cccc']
		severity: [osv_export.OsvExportSeverity{
			severity_type: 'CVSS_V3'
			score: 'CVSS:3.1/AV:N'
		}]
		references: [osv_export.OsvExportReference{
			reference_type: 'ADVISORY'
			url: 'https://bugs.debian.org/778412'
		}]
	}
	record := osv_export_spec_record(formula, 'CVE-2015-2305', formula.serialized_patches, formula.pkg_version, upstream, osv_export_spec_now)
	return record.summary or { '' } == 'Integer overflow in regcomp' && record.details or { '' } == 'Long description.' && record.upstream == [
		'CVE-2015-2305',
		'GHSA-aaaa-bbbb-cccc',
	] && record.severity == upstream.severity && record.references == upstream.references
}

// Ruby it `it "deduplicates references that differ only by percent-encoding, preserving distinct types" do` at line 128.
pub fn ruby_osv_export_spec_l128_d10_deduplicates() bool {
	formula := osv_export_spec_nvi_fixture(6)
	upstream := osv_export.OsvExportUpstream{
		references: [osv_export.OsvExportReference{
			reference_type: 'WEB'
			url: 'https://lists.example.org/announce%40lists/msg'
		}, osv_export.OsvExportReference{
			reference_type: 'WEB'
			url: 'https://lists.example.org/announce@lists/msg'
		}, osv_export.OsvExportReference{
			reference_type: 'REPORT'
			url: 'https://bugs.example.org/+bug/1'
		}, osv_export.OsvExportReference{
			reference_type: 'ADVISORY'
			url: 'https://bugs.example.org/+bug/1'
		}]
	}
	record := osv_export_spec_record(formula, 'CVE-2015-2305', formula.serialized_patches, formula.pkg_version, upstream, osv_export_spec_now)
	return record.references.len == 3 && record.references[0].url.contains('%40') && record.references[1].reference_type == 'REPORT' && record.references[2].reference_type == 'ADVISORY'
}

// Ruby it `it "percent-encodes @ in the purl but not the package name" do` at line 147.
pub fn ruby_osv_export_spec_l147_d11_percent_encodes() bool {
	return osv_export.ruby_osv_export_l185_d5_self_purl('glibc@2.13') == 'pkg:brew/glibc%402.13'
}

// Ruby it `it "percent-encodes + in the purl" do` at line 164.
pub fn ruby_osv_export_spec_l164_d12_percent_encodes() bool {
	return osv_export.ruby_osv_export_l185_d5_self_purl('libsigc++') == 'pkg:brew/libsigc%2B%2B'
}

// Ruby it `it "uses an explicit fixed boundary over the current pkg_version" do` at line 181.
pub fn ruby_osv_export_spec_l181_d13_uses() bool {
	formula := osv_export_spec_nvi_fixture(6)
	affected := osv_export.osv_export_affected_entry(formula, 'CVE-2015-2305', formula.serialized_patches, '1.81.6_3')
	return affected.ranges[0].events[1].fixed == '1.81.6_3'
}

// Ruby it `it "omits the revision suffix when revision is zero" do` at line 188.
pub fn ruby_osv_export_spec_l188_d14_omits() bool {
	formula := osv_export.OsvExportFormula{
		name: 'x'
		pkg_version: '1.0'
	}
	return osv_export.osv_export_affected_entry(formula, 'CVE-2024-0001', [], formula.pkg_version).ranges[0].events[1].fixed == '1.0'
}

// Ruby it `it "writes one file per (formula, CVE) pair" do` at line 206.
pub fn ruby_osv_export_spec_l206_d15_writes() !bool {
	dir := osv_export_spec_dir('writes')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formulae := [osv_export_spec_nvi_fixture(6), osv_export_spec_libquicktime_fixture()]
	mut annotated := []osv_export.OsvExportAnnotated{}
	for formula in formulae {
		annotated << osv_export.OsvExportAnnotated{
			formula: formula
			patches: formula.serialized_patches
		}
	}
	written := osv_export.osv_export_run(annotated, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	mut names := written.map(os.base(it))
	names.sort()
	return names == ['BREW-libquicktime-CVE-2016-2399.json', 'BREW-libquicktime-CVE-2017-9122.json',
		'BREW-nvi-CVE-2015-2305.json'] && osv_export_spec_read(written[0])!.affected[0].package.ecosystem == 'Homebrew'
}

// Ruby it `it "calls first_fixed only for records with no existing file" do` at line 225.
pub fn ruby_osv_export_spec_l225_d16_calls() !bool {
	dir := osv_export_spec_dir('first-fixed')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_libquicktime_fixture()
	existing_id := 'CVE-2016-2399'
	existing_path := os.join_path(dir, 'BREW-libquicktime-${existing_id}.json')
	existing := osv_export_spec_record(formula, existing_id, formula.serialized_patches, formula.pkg_version, none, osv_export_spec_now)
	os.write_file(existing_path, json2.encode(existing))!
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
		first_fixed: osv_export_spec_first_fixed
	})!
	new_record := osv_export_spec_read(os.join_path(dir, 'BREW-libquicktime-CVE-2017-9122.json'))!
	old_record := osv_export_spec_read(existing_path)!
	return new_record.affected[0].ranges[0].events[1].fixed == '1.2.4_2' && old_record.affected[0].ranges[0].events[1].fixed == formula.pkg_version
}

// Ruby it `it "falls back to pkg_version when first_fixed returns nil" do` at line 245.
pub fn ruby_osv_export_spec_l245_d17_falls() !bool {
	dir := osv_export_spec_dir('fixed-fallback')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	written := osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
		first_fixed: osv_export_spec_no_fixed
	})!
	return osv_export_spec_read(written[0])!.affected[0].ranges[0].events[1].fixed == '1.81.6_6'
}

// Ruby it `it "fetches each upstream vuln id once, even when shared across formulae" do` at line 256.
pub fn ruby_osv_export_spec_l256_d18_fetches() !bool {
	dir := osv_export_spec_dir('shared-id')!
	count_path := osv_export_spec_fetch_count_path()
	os.rm(count_path) or {}
	defer {
		os.rmdir_all(dir) or {}
		os.rm(count_path) or {}
	}
	patches := [osv_export.OsvExportPatch{
		url: 'https://example.com/fix.patch'
		resolves: [osv_export.OsvExportResolve{
			resolve_type: 'security'
			id: 'CVE-2024-9999'
		}]
	}]
	mut annotated := []osv_export.OsvExportAnnotated{}
	for name in ['a', 'b'] {
		annotated << osv_export.OsvExportAnnotated{
			formula: osv_export.OsvExportFormula{
				name: name
				pkg_version: '1.0'
			}
			patches: patches.clone()
		}
	}
	written := osv_export.osv_export_run(annotated, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_counted
	})!
	mut names := written.map(os.base(it))
	names.sort()
	return names == ['BREW-a-CVE-2024-9999.json', 'BREW-b-CVE-2024-9999.json'] && os.read_file(count_path)! == '1'
}

// Ruby let `let(:earlier) { Time.utc(2026, 6, 1, 0, 0, 0) }` at line 272.
pub fn ruby_osv_export_spec_l272_d19_earlier() string {
	return osv_export_spec_earlier
}

// Ruby let `let(:nvi_bumped) do` at line 273.
pub fn ruby_osv_export_spec_l273_d20_nvi_bumped() osv_export.OsvExportFormula {
	return osv_export_spec_nvi_fixture(7)
}

// Ruby method `seed(dir, formula)` at line 293.
pub fn ruby_osv_export_spec_l293_d21_seed(dir string,
	formula osv_export.OsvExportFormula) ![]string {
	return osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})
}

// Ruby it `it "preserves the existing fixed boundary and published timestamp when core bumps the version" do` at line 297.
pub fn ruby_osv_export_spec_l297_d22_preserves() !bool {
	dir := osv_export_spec_dir('preserves')!
	defer {
		os.rmdir_all(dir) or {}
	}
	osv_export_spec_run(osv_export_spec_nvi_fixture(6), dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})!
	osv_export_spec_run(osv_export_spec_nvi_fixture(7), dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	record := osv_export_spec_read(os.join_path(dir, 'BREW-nvi-CVE-2015-2305.json'))!
	return record.published == osv_export_spec_earlier && record.affected[0].ranges[0].events[1].fixed == '1.81.6_6'
}

// Ruby it `it "does not rewrite when nothing has changed" do` at line 310.
pub fn ruby_osv_export_spec_l310_d23_does() !bool {
	dir := osv_export_spec_dir('unchanged')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})!
	written := osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	record := osv_export_spec_read(os.join_path(dir, 'BREW-nvi-CVE-2015-2305.json'))!
	return written.len == 0 && record.modified == osv_export_spec_earlier
}

// Ruby it `it "updates modified when refreshed upstream data differs" do` at line 322.
pub fn ruby_osv_export_spec_l322_d24_updates() !bool {
	dir := osv_export_spec_dir('updates')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})!
	written := osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_enriched
	})!
	if written.len != 1 {
		return false
	}
	record := osv_export_spec_read(written[0])!
	return record.summary or { '' } == 'New summary' && record.published == osv_export_spec_earlier && record.modified == osv_export_spec_now
}

// Ruby it `it "leaves an existing enriched record untouched when the upstream fetch fails" do` at line 338.
pub fn ruby_osv_export_spec_l338_d25_leaves() !bool {
	dir := osv_export_spec_dir('outage-existing')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_cached
	})!
	path := os.join_path(dir, 'BREW-nvi-CVE-2015-2305.json')
	before := os.read_file(path)!
	written := osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_failed
	})!
	return written.len == 0 && os.read_file(path)! == before
}

// Ruby it `it "backfills published from an existing modified when the record predates the published field" do` at line 354.
pub fn ruby_osv_export_spec_l354_d26_backfills() !bool {
	dir := osv_export_spec_dir('legacy')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})!
	path := os.join_path(dir, 'BREW-nvi-CVE-2015-2305.json')
	decoded := json2.decode[json2.Any](os.read_file(path)!)!.as_map()
	mut legacy := decoded.clone()
	legacy.delete('published')
	os.write_file(path, '${json2.encode(json2.Any(legacy), prettify: true)}\n')!
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	record := osv_export_spec_read(path)!
	return record.published == osv_export_spec_earlier && record.modified == osv_export_spec_now
}

// Ruby it `it "does not rewrite when the existing file has a different key order" do` at line 369.
pub fn ruby_osv_export_spec_l369_d27_does() !bool {
	dir := osv_export_spec_dir('key-order')!
	defer {
		os.rmdir_all(dir) or {}
	}
	formula := osv_export_spec_nvi_fixture(6)
	osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_earlier
		fetch: osv_export_spec_fetch_empty
	})!
	path := os.join_path(dir, 'BREW-nvi-CVE-2015-2305.json')
	decoded := json2.decode[json2.Any](os.read_file(path)!)!.as_map()
	mut keys := decoded.keys()
	keys.sort(a > b)
	mut reordered := map[string]json2.Any{}
	for key in keys {
		reordered[key] = decoded[key] or { continue }
	}
	os.write_file(path, '${json2.encode(json2.Any(reordered), prettify: true)}\n')!
	written := osv_export_spec_run(formula, dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	return written.len == 0 && osv_export_spec_read(path)!.modified == osv_export_spec_earlier
}

// Ruby it `it "leaves other files in the directory untouched" do` at line 384.
pub fn ruby_osv_export_spec_l384_d28_leaves() !bool {
	dir := osv_export_spec_dir('other-files')!
	defer {
		os.rmdir_all(dir) or {}
	}
	curated := os.join_path(dir, 'BREW-2026-0001.json')
	orphan := os.join_path(dir, 'BREW-gone-CVE-2020-0001.json')
	os.write_file(curated, '{"id":"BREW-2026-0001"}')!
	os.write_file(orphan, '{"id":"BREW-gone-CVE-2020-0001","database_specific":{"source":"generated"}}')!
	osv_export_spec_run(osv_export_spec_nvi_fixture(6), dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_empty
	})!
	return os.read_file(curated)! == '{"id":"BREW-2026-0001"}' && os.is_file(orphan)
}

// Ruby it `it "still writes a record when the upstream fetch fails" do` at line 400.
pub fn ruby_osv_export_spec_l400_d29_still() !bool {
	dir := osv_export_spec_dir('outage-new')!
	defer {
		os.rmdir_all(dir) or {}
	}
	written := osv_export_spec_run(osv_export_spec_nvi_fixture(6), dir, osv_export.OsvExportRunOptions{
		now: osv_export_spec_now
		fetch: osv_export_spec_fetch_failed
	})!
	if written.len != 1 {
		return false
	}
	record := osv_export_spec_read(written[0])!
	return record.upstream == ['CVE-2015-2305'] && record.summary == none
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/osv_export"
// 5:
// 6: RSpec.describe Homebrew::Vulns::OsvExport do
// 7:   let(:now) { Time.utc(2026, 6, 28, 12, 0, 0) }
// 8:
// 9:   let(:nvi) do
// 10:     formula("nvi") do
// 11:       T.bind(self, T.class_of(Formula))
// 12:       url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6.orig.tar.gz"
// 13:       version "1.81.6"
// 14:       revision 6
// 15:       patch :p0 do
// 16:         file "Patches/nvi/patch-common__db.h"
// 17:       end
// 18:       patch do
// 19:         url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6-17.debian.tar.xz"
// 20:         sha256 "abc"
// 21:         type :backport
// 22:         apply "patches/31regex_heap_overflow.patch"
// 23:         resolves "CVE-2015-2305"
// 24:       end
// 25:     end
// 26:   end
// 27:
// 28:   let(:libquicktime) do
// 29:     formula("libquicktime") do
// 30:       T.bind(self, T.class_of(Formula))
// 31:       url "https://downloads.sourceforge.net/project/libquicktime/libquicktime-1.2.4.tar.gz"
// 32:       revision 5
// 33:       patch do
// 34:         url "https://deb.debian.org/debian/pool/main/libq/libquicktime/libquicktime_1.2.4-12.debian.tar.xz"
// 35:         sha256 "abc"
// 36:         resolves "CVE-2016-2399", "CVE-2017-9122"
// 37:       end
// 38:     end
// 39:   end
// 40:
// 41:   describe ".record_for" do
// 42:     it "builds a minimal record without upstream data" do
// 43:       record = described_class.record_for(nvi, "CVE-2015-2305", now:)
// 44:
// 45:       expect(record[:schema_version]).to eq "1.7.3"
// 46:       expect(record[:id]).to eq "BREW-nvi-CVE-2015-2305"
// 47:       expect(record[:published]).to eq "2026-06-28T12:00:00Z"
// 48:       expect(record[:modified]).to eq "2026-06-28T12:00:00Z"
// 49:       expect(record[:upstream]).to eq ["CVE-2015-2305"]
// 50:       expect(record[:database_specific]).to eq({ source: "generated" })
// 51:       expect(record).not_to have_key(:summary)
// 52:       expect(record).not_to have_key(:references)
// 53:     end
// 54:
// 55:     it "populates affected package and range" do
// 56:       affected = described_class.record_for(nvi, "CVE-2015-2305", now:)[:affected].first
// 57:
// 58:       expect(affected[:package][:ecosystem]).to eq "Homebrew"
// 59:       expect(affected[:package][:name]).to eq "nvi"
// 60:       expect(affected[:package][:purl]).to eq "pkg:brew/nvi"
// 61:       expect(affected[:ranges].first[:events]).to eq [{ introduced: "0" }, { fixed: "1.81.6_6" }]
// 62:     end
// 63:
// 64:     it "lists only the patches that resolve the given id in ecosystem_specific" do
// 65:       eco = described_class.record_for(nvi, "CVE-2015-2305", now:).dig(:affected, 0, :ecosystem_specific)
// 66:
// 67:       expect(eco[:fix]).to eq "patch"
// 68:       expect(eco[:patches]).to eq [
// 69:         {
// 70:           type:  "backport",
// 71:           url:   "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6-17.debian.tar.xz",
// 72:           apply: ["patches/31regex_heap_overflow.patch"],
// 73:         },
// 74:       ]
// 75:     end
// 76:
// 77:     it "emits file for local patches and drops entries with no locator" do
// 78:       f = formula("x") do
// 79:         T.bind(self, T.class_of(Formula))
// 80:         url "https://example.com/x-1.0.tar.gz"
// 81:         patch do
// 82:           file "Patches/x/fix.patch"
// 83:           resolves "CVE-2024-0001"
// 84:         end
// 85:         patch do
// 86:           url "https://example.com/x/fix.patch"
// 87:           sha256 "abc"
// 88:           resolves "CVE-2024-0001"
// 89:         end
// 90:       end
// 91:       patches = f.serialized_patches + [{ "resolves" => [{ "type" => "security", "id" => "CVE-2024-0001" }] }]
// 92:
// 93:       refs = described_class.record_for(f, "CVE-2024-0001", patches:, now:)
// 94:                             .dig(:affected, 0, :ecosystem_specific, :patches)
// 95:
// 96:       expect(refs).to eq [{ file: "Patches/x/fix.patch" }, { url: "https://example.com/x/fix.patch" }]
// 97:     end
// 98:
// 99:     it "reads the given patches list rather than the formula's own serialized_patches" do
// 100:       f = formula("x") { url "https://example.com/x-1.0.tar.gz" }
// 101:       linux_only = [{ "url"      => "https://example.com/linux.patch",
// 102:                       "resolves" => [{ "type" => "security", "id" => "CVE-2024-0003" }] }]
// 103:
// 104:       eco = described_class.record_for(f, "CVE-2024-0003", patches: linux_only, now:)
// 105:                            .dig(:affected, 0, :ecosystem_specific)
// 106:
// 107:       expect(eco[:patches]).to eq [{ url: "https://example.com/linux.patch" }]
// 108:     end
// 109:
// 110:     it "merges upstream summary, details, aliases, severity and references" do
// 111:       upstream = {
// 112:         "summary"    => "Integer overflow in regcomp",
// 113:         "details"    => "Long description.",
// 114:         "aliases"    => ["GHSA-aaaa-bbbb-cccc"],
// 115:         "severity"   => [{ "type" => "CVSS_V3", "score" => "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H" }],
// 116:         "references" => [{ "type" => "ADVISORY", "url" => "https://bugs.debian.org/778412" }],
// 117:       }
// 118:
// 119:       record = described_class.record_for(nvi, "CVE-2015-2305", upstream:, now:)
// 120:
// 121:       expect(record[:summary]).to eq "Integer overflow in regcomp"
// 122:       expect(record[:details]).to eq "Long description."
// 123:       expect(record[:upstream]).to eq ["CVE-2015-2305", "GHSA-aaaa-bbbb-cccc"]
// 124:       expect(record[:severity]).to eq upstream["severity"]
// 125:       expect(record[:references]).to eq upstream["references"]
// 126:     end
// 127:
// 128:     it "deduplicates references that differ only by percent-encoding, preserving distinct types" do
// 129:       upstream = {
// 130:         "references" => [
// 131:           { "type" => "WEB", "url" => "https://lists.example.org/announce%40lists/msg" },
// 132:           { "type" => "WEB", "url" => "https://lists.example.org/announce@lists/msg" },
// 133:           { "type" => "REPORT", "url" => "https://bugs.example.org/+bug/1" },
// 134:           { "type" => "ADVISORY", "url" => "https://bugs.example.org/+bug/1" },
// 135:         ],
// 136:       }
// 137:
// 138:       record = described_class.record_for(nvi, "CVE-2015-2305", upstream:, now:)
// 139:
// 140:       expect(record[:references]).to eq [
// 141:         { "type" => "WEB", "url" => "https://lists.example.org/announce%40lists/msg" },
// 142:         { "type" => "REPORT", "url" => "https://bugs.example.org/+bug/1" },
// 143:         { "type" => "ADVISORY", "url" => "https://bugs.example.org/+bug/1" },
// 144:       ]
// 145:     end
// 146:
// 147:     it "percent-encodes @ in the purl but not the package name" do
// 148:       glibc = formula("glibc@2.13") do
// 149:         T.bind(self, T.class_of(Formula))
// 150:         url "https://ftp.gnu.org/gnu/glibc/glibc-2.13.tar.gz"
// 151:         patch do
// 152:           url "https://example.com/fix.patch"
// 153:           sha256 "abc"
// 154:           resolves "CVE-2024-2961"
// 155:         end
// 156:       end
// 157:
// 158:       affected = described_class.record_for(glibc, "CVE-2024-2961", now:).dig(:affected, 0)
// 159:
// 160:       expect(affected[:package][:purl]).to eq "pkg:brew/glibc%402.13"
// 161:       expect(affected[:package][:name]).to eq "glibc@2.13"
// 162:     end
// 163:
// 164:     it "percent-encodes + in the purl" do
// 165:       libsigcxx = formula("libsigc++") do
// 166:         T.bind(self, T.class_of(Formula))
// 167:         url "https://download.gnome.org/sources/libsigc++/3.6/libsigc++-3.6.0.tar.xz"
// 168:         patch do
// 169:           url "https://example.com/fix.patch"
// 170:           sha256 "abc"
// 171:           resolves "CVE-2024-0002"
// 172:         end
// 173:       end
// 174:
// 175:       affected = described_class.record_for(libsigcxx, "CVE-2024-0002", now:).dig(:affected, 0)
// 176:
// 177:       expect(affected[:package][:purl]).to eq "pkg:brew/libsigc%2B%2B"
// 178:       expect(affected[:package][:name]).to eq "libsigc++"
// 179:     end
// 180:
// 181:     it "uses an explicit fixed boundary over the current pkg_version" do
// 182:       events = described_class.record_for(nvi, "CVE-2015-2305", fixed: "1.81.6_3", now:)
// 183:                               .dig(:affected, 0, :ranges, 0, :events)
// 184:
// 185:       expect(events[1]).to eq({ fixed: "1.81.6_3" })
// 186:     end
// 187:
// 188:     it "omits the revision suffix when revision is zero" do
// 189:       f = formula("x") do
// 190:         T.bind(self, T.class_of(Formula))
// 191:         url "https://example.com/x-1.0.tar.gz"
// 192:         patch do
// 193:           url "https://example.com/fix.patch"
// 194:           sha256 "abc"
// 195:           resolves "CVE-2024-0001"
// 196:         end
// 197:       end
// 198:
// 199:       events = described_class.record_for(f, "CVE-2024-0001", now:).dig(:affected, 0, :ranges, 0, :events)
// 200:
// 201:       expect(events[1]).to eq({ fixed: "1.0" })
// 202:     end
// 203:   end
// 204:
// 205:   describe ".run" do
// 206:     it "writes one file per (formula, CVE) pair" do
// 207:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_return({})
// 208:
// 209:       Dir.mktmpdir do |dir|
// 210:         annotated = [[nvi, nvi.serialized_patches], [libquicktime, libquicktime.serialized_patches]]
// 211:         written = described_class.run(annotated, dir, now:)
// 212:
// 213:         expect(written.map { |p| File.basename(p) }.sort).to eq [
// 214:           "BREW-libquicktime-CVE-2016-2399.json",
// 215:           "BREW-libquicktime-CVE-2017-9122.json",
// 216:           "BREW-nvi-CVE-2015-2305.json",
// 217:         ]
// 218:         written.each do |p|
// 219:           record = JSON.parse(File.read(p))
// 220:           expect(record["affected"][0]["package"]["ecosystem"]).to eq "Homebrew"
// 221:         end
// 222:       end
// 223:     end
// 224:
// 225:     it "calls first_fixed only for records with no existing file" do
// 226:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_return({})
// 227:       calls = []
// 228:       first_fixed = lambda { |f, id|
// 229:         calls << [f.name, id]
// 230:         "1.2.4_2"
// 231:       }
// 232:
// 233:       Dir.mktmpdir do |dir|
// 234:         File.write("#{dir}/BREW-libquicktime-CVE-2016-2399.json",
// 235:                    JSON.generate(described_class.record_for(libquicktime, "CVE-2016-2399", now:)))
// 236:
// 237:         described_class.run([[libquicktime, libquicktime.serialized_patches]], dir, first_fixed:, now:)
// 238:
// 239:         expect(calls).to eq [["libquicktime", "CVE-2017-9122"]]
// 240:         record = JSON.parse(File.read("#{dir}/BREW-libquicktime-CVE-2017-9122.json"))
// 241:         expect(record["affected"][0]["ranges"][0]["events"][1]).to eq({ "fixed" => "1.2.4_2" })
// 242:       end
// 243:     end
// 244:
// 245:     it "falls back to pkg_version when first_fixed returns nil" do
// 246:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_return({})
// 247:
// 248:       Dir.mktmpdir do |dir|
// 249:         described_class.run([[nvi, nvi.serialized_patches]], dir, first_fixed: ->(_f, _id) {}, now:)
// 250:
// 251:         record = JSON.parse(File.read("#{dir}/BREW-nvi-CVE-2015-2305.json"))
// 252:         expect(record["affected"][0]["ranges"][0]["events"][1]).to eq({ "fixed" => "1.81.6_6" })
// 253:       end
// 254:     end
// 255:
// 256:     it "fetches each upstream vuln id once, even when shared across formulae" do
// 257:       shared = [{ "url"      => "https://example.com/fix.patch",
// 258:                   "resolves" => [{ "type" => "security", "id" => "CVE-2024-9999" }] }]
// 259:       a = formula("a") { url "https://example.com/a-1.0.tar.gz" }
// 260:       b = formula("b") { url "https://example.com/b-1.0.tar.gz" }
// 261:
// 262:       expect(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-9999").once.and_return({})
// 263:
// 264:       Dir.mktmpdir do |dir|
// 265:         written = described_class.run([[a, shared], [b, shared]], dir, now:)
// 266:         expect(written.map { |p| File.basename(p) }.sort)
// 267:           .to eq ["BREW-a-CVE-2024-9999.json", "BREW-b-CVE-2024-9999.json"]
// 268:       end
// 269:     end
// 270:
// 271:     context "with an existing record on disk" do
// 272:       let(:earlier) { Time.utc(2026, 6, 1, 0, 0, 0) }
// 273:       let(:nvi_bumped) do
// 274:         formula("nvi") do
// 275:           T.bind(self, T.class_of(Formula))
// 276:           url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6.orig.tar.gz"
// 277:           version "1.81.6"
// 278:           revision 7
// 279:           patch do
// 280:             url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6-17.debian.tar.xz"
// 281:             sha256 "abc"
// 282:             type :backport
// 283:             apply "patches/31regex_heap_overflow.patch"
// 284:             resolves "CVE-2015-2305"
// 285:           end
// 286:         end
// 287:       end
// 288:
// 289:       before do
// 290:         allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_return({})
// 291:       end
// 292:
// 293:       def seed(dir, formula)
// 294:         described_class.run([[formula, formula.serialized_patches]], dir, now: earlier)
// 295:       end
// 296:
// 297:       it "preserves the existing fixed boundary and published timestamp when core bumps the version" do
// 298:         Dir.mktmpdir do |dir|
// 299:           seed(dir, nvi)
// 300:           expect(nvi_bumped.pkg_version.to_s).to eq "1.81.6_7"
// 301:
// 302:           described_class.run([[nvi_bumped, nvi_bumped.serialized_patches]], dir, now:)
// 303:
// 304:           record = JSON.parse(File.read("#{dir}/BREW-nvi-CVE-2015-2305.json"))
// 305:           expect(record["published"]).to eq "2026-06-01T00:00:00Z"
// 306:           expect(record["affected"][0]["ranges"][0]["events"][1]).to eq({ "fixed" => "1.81.6_6" })
// 307:         end
// 308:       end
// 309:
// 310:       it "does not rewrite when nothing has changed" do
// 311:         Dir.mktmpdir do |dir|
// 312:           seed(dir, nvi)
// 313:
// 314:           written = described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 315:
// 316:           expect(written).to eq []
// 317:           record = JSON.parse(File.read("#{dir}/BREW-nvi-CVE-2015-2305.json"))
// 318:           expect(record["modified"]).to eq "2026-06-01T00:00:00Z"
// 319:         end
// 320:       end
// 321:
// 322:       it "updates modified when refreshed upstream data differs" do
// 323:         Dir.mktmpdir do |dir|
// 324:           seed(dir, nvi)
// 325:           allow(Homebrew::Vulns::OSV).to receive(:vulnerability)
// 326:             .and_return({ "summary" => "New summary" })
// 327:
// 328:           written = described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 329:
// 330:           expect(written).to eq ["#{dir}/BREW-nvi-CVE-2015-2305.json"]
// 331:           record = JSON.parse(File.read(written.first))
// 332:           expect(record["summary"]).to eq "New summary"
// 333:           expect(record["published"]).to eq "2026-06-01T00:00:00Z"
// 334:           expect(record["modified"]).to eq "2026-06-28T12:00:00Z"
// 335:         end
// 336:       end
// 337:
// 338:       it "leaves an existing enriched record untouched when the upstream fetch fails" do
// 339:         Dir.mktmpdir do |dir|
// 340:           allow(Homebrew::Vulns::OSV).to receive(:vulnerability)
// 341:             .and_return({ "summary" => "Cached summary", "aliases" => ["GHSA-aaaa-bbbb-cccc"] })
// 342:           seed(dir, nvi)
// 343:           before = File.read("#{dir}/BREW-nvi-CVE-2015-2305.json")
// 344:           expect(JSON.parse(before)["summary"]).to eq "Cached summary"
// 345:
// 346:           allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_raise(Homebrew::Vulns::OSV::ApiError)
// 347:           written = described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 348:
// 349:           expect(written).to eq []
// 350:           expect(File.read("#{dir}/BREW-nvi-CVE-2015-2305.json")).to eq before
// 351:         end
// 352:       end
// 353:
// 354:       it "backfills published from an existing modified when the record predates the published field" do
// 355:         Dir.mktmpdir do |dir|
// 356:           seed(dir, nvi)
// 357:           path = "#{dir}/BREW-nvi-CVE-2015-2305.json"
// 358:           legacy = JSON.parse(File.read(path)).tap { |h| h.delete("published") }
// 359:           File.write(path, "#{JSON.pretty_generate(legacy)}\n")
// 360:
// 361:           described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 362:
// 363:           record = JSON.parse(File.read(path))
// 364:           expect(record["published"]).to eq "2026-06-01T00:00:00Z"
// 365:           expect(record["modified"]).to eq "2026-06-28T12:00:00Z"
// 366:         end
// 367:       end
// 368:
// 369:       it "does not rewrite when the existing file has a different key order" do
// 370:         Dir.mktmpdir do |dir|
// 371:           seed(dir, nvi)
// 372:           path = "#{dir}/BREW-nvi-CVE-2015-2305.json"
// 373:           reordered = JSON.parse(File.read(path)).sort.reverse.to_h
// 374:           File.write(path, "#{JSON.pretty_generate(reordered)}\n")
// 375:           expect(reordered.keys.first).to eq "upstream"
// 376:
// 377:           written = described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 378:
// 379:           expect(written).to eq []
// 380:           expect(JSON.parse(File.read(path))["modified"]).to eq "2026-06-01T00:00:00Z"
// 381:         end
// 382:       end
// 383:
// 384:       it "leaves other files in the directory untouched" do
// 385:         Dir.mktmpdir do |dir|
// 386:           curated = "#{dir}/BREW-2026-0001.json"
// 387:           File.write(curated, JSON.generate(id: "BREW-2026-0001"))
// 388:           orphan = "#{dir}/BREW-gone-CVE-2020-0001.json"
// 389:           File.write(orphan, JSON.generate(id:                "BREW-gone-CVE-2020-0001",
// 390:                                            database_specific: { source: "generated" }))
// 391:
// 392:           described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 393:
// 394:           expect(File.read(curated)).to eq JSON.generate(id: "BREW-2026-0001")
// 395:           expect(File.exist?(orphan)).to be true
// 396:         end
// 397:       end
// 398:     end
// 399:
// 400:     it "still writes a record when the upstream fetch fails" do
// 401:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_raise(Homebrew::Vulns::OSV::ApiError)
// 402:
// 403:       Dir.mktmpdir do |dir|
// 404:         written = described_class.run([[nvi, nvi.serialized_patches]], dir, now:)
// 405:
// 406:         expect(written.size).to eq 1
// 407:         record = JSON.parse(File.read(written.first))
// 408:         expect(record["upstream"]).to eq ["CVE-2015-2305"]
// 409:         expect(record).not_to have_key("summary")
// 410:       end
// 411:     end
// 412:   end
// 413: end
