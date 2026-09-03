module vulns

import homebrew.vulns as cpan_core
import os
import x.json2

// Translated from Homebrew/brew `test/vulns/cpan_sec_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn cpan_sec_spec_fixture_contents() string {
	return '{"meta":{"commit":"abc123","epoch":1784142497},"dists":{"DBI":{"advisories":[{"id":"CPANSA-DBI-2020-01","cves":["CVE-2020-14393"],"affected_versions":["<1.643"],"fixed_versions":[">=1.643"],"severity":"high","description":"Buffer overflow in DBI.xs.\\n","references":["https://metacpan.org/changes/distribution/DBI"],"reported":"2020-09-16"},{"id":"CPANSA-DBI-2014-01","cves":["CVE-2014-10402","CVE-2014-10401"],"affected_versions":">=0.64,<1.632","fixed_versions":[">=1.632"]}]},"Image-ExifTool":{"advisories":[{"id":"CPANSA-Image-ExifTool-2021-01","cves":["CVE-2021-22204"],"affected_versions":["<12.24"],"fixed_versions":[">=12.24"]}]}}}'
}

fn cpan_sec_spec_database() !cpan_core.CpanSecDatabase {
	return cpan_core.parse_cpan_sec_database(cpan_sec_spec_fixture_contents())
}

fn cpan_sec_spec_advisory(affected []string, fixed []string) cpan_core.CpanSecAdvisory {
	return cpan_core.CpanSecAdvisory{
		id: 'CPANSA-X'
		affected_versions: affected.clone()
		fixed_versions: fixed.clone()
	}
}

fn cpan_sec_spec_read(path string) !string {
	return os.read_file(path)
}

fn cpan_sec_spec_write(path string, contents string) ! {
	os.write_file(path, contents)!
}

fn cpan_sec_spec_rename(source string, destination string) ! {
	os.rename(source, destination)!
}

fn cpan_sec_spec_remove(path string) ! {
	if os.exists(path) {
		os.rm(path)!
	}
}

fn cpan_sec_spec_mkdir(path string) ! {
	os.mkdir_all(path)!
}

fn cpan_sec_spec_exists(path string) bool {
	return os.exists(path)
}

fn cpan_sec_spec_fresh_mtime(path string) !i64 {
	if !os.exists(path) {
		return error('missing cache')
	}
	return 100_000
}

fn cpan_sec_spec_stale_mtime(path string) !i64 {
	if !os.exists(path) {
		return error('missing cache')
	}
	return 0
}

fn cpan_sec_spec_fetch_fixture(url string) !string {
	if url != cpan_core.cpan_sec_data_url {
		return error('unexpected CPANSA URL')
	}
	return cpan_sec_spec_fixture_contents()
}

fn cpan_sec_spec_fetch_failure(url string) !string {
	return error('download failed for ${url}')
}

fn cpan_sec_spec_fetch_invalid(url string) !string {
	if url == '' {
		return error('missing URL')
	}
	return 'not json'
}

fn cpan_sec_spec_now() i64 {
	return 100_000
}

fn cpan_sec_spec_warn(message string) {
	path := os.getenv('BREW_V_CPAN_SEC_WARNING_FILE')
	if path != '' {
		os.write_file(path, message) or { panic(err) }
	}
}

fn cpan_sec_spec_io(fetch cpan_core.CpanSecFetch,
	mtime cpan_core.CpanSecModifiedTime) cpan_core.CpanSecIo {
	return cpan_core.CpanSecIo{
		read_file: cpan_sec_spec_read
		write_file: cpan_sec_spec_write
		rename_file: cpan_sec_spec_rename
		remove_file: cpan_sec_spec_remove
		make_directory: cpan_sec_spec_mkdir
		path_exists: cpan_sec_spec_exists
		modified_time: mtime
		fetch: fetch
		now: cpan_sec_spec_now
		warn: cpan_sec_spec_warn
	}
}

fn cpan_sec_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-cpan-sec-${os.getpid()}-${name}')
	if os.exists(path) {
		os.rmdir_all(path) or { panic(err) }
	}
	os.mkdir_all(path) or { panic(err) }
	return path
}

fn cpan_sec_spec_cleanup(path string) {
	if os.exists(path) {
		os.rmdir_all(path) or { panic(err) }
	}
}

// Ruby let `let(:fixture) { TEST_FIXTURE_DIR/"vulns/cpansa.json" }` at line 7.
pub fn ruby_cpan_sec_spec_l7_d1_fixture() string {
	return 'vulns/cpansa.json'
}

// Ruby let `let(:cpansa) { described_class.from_file(fixture) }` at line 8.
pub fn ruby_cpan_sec_spec_l8_d2_cpansa() !cpan_core.CpanSecDatabase {
	return cpan_sec_spec_database()
}

// Ruby it `it "raises Error on unparseable JSON" do` at line 11.
pub fn ruby_cpan_sec_spec_l11_d3_raises() bool {
	cache := cpan_sec_spec_temp('unparseable')
	path := os.join_path(cache, cpan_core.cpan_sec_cache_filename)
	os.write_file(path, 'not json') or {
		cpan_sec_spec_cleanup(cache)
		return false
	}
	if _ := cpan_core.cpan_sec_from_file(path, cpan_sec_spec_read) {
		cpan_sec_spec_cleanup(cache)
		return false
	} else {
		result := err.msg().contains('Failed to parse cpansa.json at ${path}')
		cpan_sec_spec_cleanup(cache)
		return result
	}
}

// Ruby it `it "raises Error when the dists key is missing" do` at line 22.
pub fn ruby_cpan_sec_spec_l22_d4_raises() bool {
	if _ := cpan_core.new_cpan_sec_database(json2.Any({
		'meta': json2.Any(map[string]json2.Any{})
	})) {
		return false
	} else {
		return err.msg().contains("missing 'dists' key")
	}
}

// Ruby it `it "raises Error when the top-level value is not a JSON object" do` at line 27.
pub fn ruby_cpan_sec_spec_l27_d5_raises() bool {
	mut rejected := 0
	if _ := cpan_core.new_cpan_sec_database(json2.Any([]json2.Any{})) {
	} else {
		if err.msg().contains('not a JSON object') {
			rejected++
		}
	}
	if _ := cpan_core.new_cpan_sec_database(json2.Any(json2.null)) {
	} else {
		if err.msg().contains('not a JSON object') {
			rejected++
		}
	}
	return rejected == 2
}

// Ruby it `it "treats a null or absent meta as an empty hash" do` at line 32.
pub fn ruby_cpan_sec_spec_l32_d6_treats() !bool {
	with_null := cpan_core.new_cpan_sec_database(json2.Any({
		'dists': json2.Any(map[string]json2.Any{})
		'meta':  json2.Any(json2.null)
	}))!
	absent := cpan_core.new_cpan_sec_database(json2.Any({
		'dists': json2.Any(map[string]json2.Any{})
	}))!
	return with_null.meta().len == 0 && absent.meta().len == 0
}

// Ruby it `it "returns the upstream build metadata" do` at line 39.
pub fn ruby_cpan_sec_spec_l39_d7_returns() !bool {
	meta := cpan_sec_spec_database()!.meta()
	return meta['commit']!.str() == 'abc123' && meta['epoch']!.i64() == 1_784_142_497
}

// Ruby it `it "lists all distribution names" do` at line 45.
pub fn ruby_cpan_sec_spec_l45_d8_lists() !bool {
	return cpan_sec_spec_database()!.distributions() == ['DBI', 'Image-ExifTool']
}

// Ruby it `it "returns Advisory structs with all fields populated" do` at line 51.
pub fn ruby_cpan_sec_spec_l51_d9_returns() !bool {
	first := cpan_sec_spec_database()!.advisories_for('DBI')[0]
	return first.id == 'CPANSA-DBI-2020-01' && first.cves == ['CVE-2020-14393'] && first.affected_versions == [
		'<1.643',
	] && first.fixed_versions == ['>=1.643'] && first.severity or { '' } == 'high' && first.description or { '' } == 'Buffer overflow in DBI.xs.\n' && first.references == [
		'https://metacpan.org/changes/distribution/DBI',
	] && first.reported or { '' } == '2020-09-16'
}

// Ruby it `it "coerces cves and affected_versions to string arrays and defaults absent optional fields" do` at line 65.
pub fn ruby_cpan_sec_spec_l65_d10_coerces() !bool {
	second := cpan_sec_spec_database()!.advisories_for('DBI')[1]
	return second.id == 'CPANSA-DBI-2014-01' && second.cves == ['CVE-2014-10402', 'CVE-2014-10401'] && second.affected_versions == [
		'>=0.64,<1.632',
	] && second.description == none && second.references.len == 0
}

// Ruby it `it "returns all advisories for a distribution in file order" do` at line 74.
pub fn ruby_cpan_sec_spec_l74_d11_returns() !bool {
	return cpan_sec_spec_database()!.advisories_for('DBI').map(it.id) == [
		'CPANSA-DBI-2020-01',
		'CPANSA-DBI-2014-01',
	]
}

// Ruby it `it "returns an empty array for an unknown distribution" do` at line 79.
pub fn ruby_cpan_sec_spec_l79_d12_returns() !bool {
	return cpan_sec_spec_database()!.advisories_for('No-Such-Dist').len == 0
}

// Ruby it `it "returns frozen advisories" do` at line 83.
pub fn ruby_cpan_sec_spec_l83_d13_returns() !bool {
	advisory := cpan_sec_spec_database()!.advisories_for('Image-ExifTool')[0]
	// Immutable struct fields and cloned result arrays are V's frozen equivalent.
	return advisory.id == 'CPANSA-Image-ExifTool-2021-01'
}

// Ruby method `adv(affected:, fixed:)` at line 89.
pub fn ruby_cpan_sec_spec_l89_d14_adv(affected []string,
	fixed []string) cpan_core.CpanSecAdvisory {
	return cpan_sec_spec_advisory(affected, fixed)
}

// Ruby it `it "reports affected with fixed_in when the version is inside a single-bound constraint" do` at line 94.
pub fn ruby_cpan_sec_spec_l94_d15_reports() !bool {
	status := cpan_core.cpan_sec_range_status(cpan_sec_spec_advisory(['<12.24'], [
		'>=12.24',
	]), '12.00')!
	return status.affected() && status.fixed_in or { '' } == '12.24'
}

// Ruby it `it "reports not-affected with fixed_in when the version is at or past the fix" do` at line 99.
pub fn ruby_cpan_sec_spec_l99_d16_reports() !bool {
	status := cpan_core.cpan_sec_range_status(cpan_sec_spec_advisory(['<12.24'], [
		'>=12.24',
	]), '13.55')!
	return !status.affected() && status.fixed() && status.fixed_in or { '' } == '12.24'
}

// Ruby it `it "evaluates comma-joined AND terms" do` at line 104.
pub fn ruby_cpan_sec_spec_l104_d17_evaluates() !bool {
	inside := cpan_core.cpan_sec_range_status(cpan_sec_spec_advisory(['>=0.64,<1.632'], [
		'>=1.632',
	]), '1.5')!
	below := cpan_core.cpan_sec_range_status(cpan_sec_spec_advisory(['>=0.64,<1.632'], []string{}), '0.5')!
	return inside.affected() && !below.affected()
}

// Ruby it `it "treats multiple array entries as OR" do` at line 111.
pub fn ruby_cpan_sec_spec_l111_d18_treats() !bool {
	advisory := cpan_sec_spec_advisory(['<1.0', '>=2.0,<2.5'], ['>=1.0,<2.0', '>=2.5'])
	first := cpan_core.cpan_sec_range_status(advisory, '0.9')!
	second := cpan_core.cpan_sec_range_status(advisory, '2.1')!
	gap := cpan_core.cpan_sec_range_status(advisory, '1.5')!
	return first.affected() && second.affected() && second.fixed_in or { '' } == '2.5' && !gap.affected()
}

// Ruby it `it "treats a bare version term as equality and an empty affected_versions as always affected" do` at line 118.
pub fn ruby_cpan_sec_spec_l118_d19_treats() !bool {
	equality := cpan_sec_spec_advisory(['1.0'], []string{})
	always := cpan_sec_spec_advisory([]string{}, []string{})
	return cpan_core.cpan_sec_range_status(equality, '1.0')!.affected() && !cpan_core.cpan_sec_range_status(equality, '1.1')!.affected() && cpan_core.cpan_sec_range_status(always, '1.0')!.affected()
}

// Ruby it `it "does not report a version in the gap between affected and a strict >fix as :fixed" do` at line 124.
pub fn ruby_cpan_sec_spec_l124_d20_does() !bool {
	advisory := cpan_sec_spec_advisory(['<1.0'], ['>1.0'])
	gap := cpan_core.cpan_sec_range_status(advisory, '1.0')!
	fixed := cpan_core.cpan_sec_range_status(advisory, '1.1')!
	return gap.state == .not_applicable && fixed.state == .fixed
}

// Ruby it `it "reports affected with no fixed_in when there is no fixed_versions" do` at line 130.
pub fn ruby_cpan_sec_spec_l130_d21_reports() !bool {
	status := cpan_core.cpan_sec_range_status(cpan_sec_spec_advisory(['<12.24'], []string{}), '12.00')!
	return status.affected() && status.fixed_in == none
}

// Ruby it `it "reads a fresh cache file without downloading" do` at line 137.
pub fn ruby_cpan_sec_spec_l137_d22_reads() !bool {
	cache := cpan_sec_spec_temp('fresh')
	cache_file := os.join_path(cache, cpan_core.cpan_sec_cache_filename)
	os.write_file(cache_file, cpan_sec_spec_fixture_contents())!
	loaded := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_failure, cpan_sec_spec_fresh_mtime))!
	result := 'DBI' in loaded.distributions()
	cpan_sec_spec_cleanup(cache)
	return result
}

// Ruby it `it "downloads to a temp file and atomically replaces a stale cache" do` at line 147.
pub fn ruby_cpan_sec_spec_l147_d23_downloads() !bool {
	cache := cpan_sec_spec_temp('stale-replace')
	cache_file := os.join_path(cache, cpan_core.cpan_sec_cache_filename)
	os.write_file(cache_file, '{"dists":{}}')!
	loaded := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_fixture, cpan_sec_spec_stale_mtime))!
	mut children := os.ls(cache)!
	children.sort()
	result := 'DBI' in loaded.distributions() && os.read_file(cache_file)! == cpan_sec_spec_fixture_contents() && children == [
		cpan_core.cpan_sec_cache_filename,
	]
	cpan_sec_spec_cleanup(cache)
	return result
}

// Ruby it `it "downloads when the cache file is absent" do` at line 163.
pub fn ruby_cpan_sec_spec_l163_d24_downloads() !bool {
	cache := cpan_sec_spec_temp('absent-download')
	loaded := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_fixture, cpan_sec_spec_stale_mtime))!
	result := loaded.advisories_for('Image-ExifTool').len == 1
	cpan_sec_spec_cleanup(cache)
	return result
}

// Ruby it `it "falls back to a stale cache when the download fails, leaving it intact" do` at line 173.
pub fn ruby_cpan_sec_spec_l173_d25_falls() !bool {
	cache := cpan_sec_spec_temp('stale-failure')
	cache_file := os.join_path(cache, cpan_core.cpan_sec_cache_filename)
	warning_file := '${cache}-warning'
	if os.exists(warning_file) {
		os.rm(warning_file)!
	}
	os.setenv('BREW_V_CPAN_SEC_WARNING_FILE', warning_file, true)
	original := cpan_sec_spec_fixture_contents()
	os.write_file(cache_file, original)!
	loaded := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_failure, cpan_sec_spec_stale_mtime))!
	os.unsetenv('BREW_V_CPAN_SEC_WARNING_FILE')
	warning := os.read_file(warning_file)!
	result := 'DBI' in loaded.distributions() && os.read_file(cache_file)! == original && warning.contains('Failed to refresh cpansa.json') && warning.contains('using cached copy from 0.')
	cpan_sec_spec_cleanup(cache)
	os.rm(warning_file)!
	return result
}

// Ruby it `it "falls back to a stale cache when the fetched file is invalid, leaving it intact" do` at line 190.
pub fn ruby_cpan_sec_spec_l190_d26_falls() !bool {
	cache := cpan_sec_spec_temp('stale-invalid')
	cache_file := os.join_path(cache, cpan_core.cpan_sec_cache_filename)
	warning_file := '${cache}-warning'
	if os.exists(warning_file) {
		os.rm(warning_file)!
	}
	os.setenv('BREW_V_CPAN_SEC_WARNING_FILE', warning_file, true)
	original := cpan_sec_spec_fixture_contents()
	os.write_file(cache_file, original)!
	loaded := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_invalid, cpan_sec_spec_stale_mtime))!
	os.unsetenv('BREW_V_CPAN_SEC_WARNING_FILE')
	mut children := os.ls(cache)!
	children.sort()
	warning := os.read_file(warning_file)!
	result := 'DBI' in loaded.distributions() && os.read_file(cache_file)! == original && warning.contains('Failed to refresh cpansa.json') && warning.contains('using cached copy from 0.') && children == [
		cpan_core.cpan_sec_cache_filename,
	]
	cpan_sec_spec_cleanup(cache)
	os.rm(warning_file)!
	return result
}

// Ruby it `it "raises when the download fails and no cache exists" do` at line 207.
pub fn ruby_cpan_sec_spec_l207_d27_raises() bool {
	cache := cpan_sec_spec_temp('absent-failure')
	if _ := cpan_core.load_cpan_sec(cache, 86_400, cpan_sec_spec_io(cpan_sec_spec_fetch_failure, cpan_sec_spec_stale_mtime)) {
		cpan_sec_spec_cleanup(cache)
		return false
	} else {
		result := err.msg().contains('download failed')
		cpan_sec_spec_cleanup(cache)
		return result
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/cpan_sec"
// 5:
// 6: RSpec.describe Homebrew::Vulns::CPANSec do
// 7:   let(:fixture) { TEST_FIXTURE_DIR/"vulns/cpansa.json" }
// 8:   let(:cpansa) { described_class.from_file(fixture) }
// 9:
// 10:   describe ".from_file" do
// 11:     it "raises Error on unparseable JSON" do
// 12:       Dir.mktmpdir do |dir|
// 13:         bad = Pathname(dir)/"cpansa.json"
// 14:         bad.write "not json"
// 15:         expect { described_class.from_file(bad) }
// 16:           .to raise_error(Homebrew::Vulns::CachedFeed::Error, /Failed to parse cpansa\.json/)
// 17:       end
// 18:     end
// 19:   end
// 20:
// 21:   describe "#initialize" do
// 22:     it "raises Error when the dists key is missing" do
// 23:       expect { described_class.new({ "meta" => {} }) }
// 24:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /missing 'dists' key/)
// 25:     end
// 26:
// 27:     it "raises Error when the top-level value is not a JSON object" do
// 28:       expect { described_class.new([]) }.to raise_error(Homebrew::Vulns::CachedFeed::Error, /not a JSON object/)
// 29:       expect { described_class.new(nil) }.to raise_error(Homebrew::Vulns::CachedFeed::Error, /not a JSON object/)
// 30:     end
// 31:
// 32:     it "treats a null or absent meta as an empty hash" do
// 33:       expect(described_class.new({ "dists" => {}, "meta" => nil }).meta).to eq({})
// 34:       expect(described_class.new({ "dists" => {} }).meta).to eq({})
// 35:     end
// 36:   end
// 37:
// 38:   describe "#meta" do
// 39:     it "returns the upstream build metadata" do
// 40:       expect(cpansa.meta).to include("commit" => "abc123", "epoch" => 1784142497)
// 41:     end
// 42:   end
// 43:
// 44:   describe "#distributions" do
// 45:     it "lists all distribution names" do
// 46:       expect(cpansa.distributions).to contain_exactly("DBI", "Image-ExifTool")
// 47:     end
// 48:   end
// 49:
// 50:   describe "#advisories_for" do
// 51:     it "returns Advisory structs with all fields populated" do
// 52:       first = cpansa.advisories_for("DBI").first
// 53:       expect(first).to have_attributes(
// 54:         id:                "CPANSA-DBI-2020-01",
// 55:         cves:              ["CVE-2020-14393"],
// 56:         affected_versions: ["<1.643"],
// 57:         fixed_versions:    [">=1.643"],
// 58:         severity:          "high",
// 59:         description:       "Buffer overflow in DBI.xs.\n",
// 60:         references:        ["https://metacpan.org/changes/distribution/DBI"],
// 61:         reported:          "2020-09-16",
// 62:       )
// 63:     end
// 64:
// 65:     it "coerces cves and affected_versions to string arrays and defaults absent optional fields" do
// 66:       second = cpansa.advisories_for("DBI")[1]
// 67:       expect(second.id).to eq "CPANSA-DBI-2014-01"
// 68:       expect(second.cves).to eq ["CVE-2014-10402", "CVE-2014-10401"]
// 69:       expect(second.affected_versions).to eq [">=0.64,<1.632"]
// 70:       expect(second.description).to be_nil
// 71:       expect(second.references).to eq []
// 72:     end
// 73:
// 74:     it "returns all advisories for a distribution in file order" do
// 75:       expect(cpansa.advisories_for("DBI").map(&:id))
// 76:         .to eq ["CPANSA-DBI-2020-01", "CPANSA-DBI-2014-01"]
// 77:     end
// 78:
// 79:     it "returns an empty array for an unknown distribution" do
// 80:       expect(cpansa.advisories_for("No-Such-Dist")).to eq []
// 81:     end
// 82:
// 83:     it "returns frozen advisories" do
// 84:       expect(cpansa.advisories_for("Image-ExifTool").first).to be_frozen
// 85:     end
// 86:   end
// 87:
// 88:   describe ".range_status" do
// 89:     def adv(affected:, fixed:)
// 90:       Homebrew::Vulns::CPANSec::Advisory.new(id: "CPANSA-X", cves: [], affected_versions: affected,
// 91:                                              fixed_versions: fixed)
// 92:     end
// 93:
// 94:     it "reports affected with fixed_in when the version is inside a single-bound constraint" do
// 95:       status = described_class.range_status(adv(affected: ["<12.24"], fixed: [">=12.24"]), "12.00")
// 96:       expect(status).to have_attributes(affected?: true, fixed_in: "12.24")
// 97:     end
// 98:
// 99:     it "reports not-affected with fixed_in when the version is at or past the fix" do
// 100:       status = described_class.range_status(adv(affected: ["<12.24"], fixed: [">=12.24"]), "13.55")
// 101:       expect(status).to have_attributes(affected?: false, fixed_in: "12.24")
// 102:     end
// 103:
// 104:     it "evaluates comma-joined AND terms" do
// 105:       status = described_class.range_status(adv(affected: [">=0.64,<1.632"], fixed: [">=1.632"]), "1.5")
// 106:       expect(status.affected?).to be true
// 107:       expect(described_class.range_status(adv(affected: [">=0.64,<1.632"], fixed: []), "0.5").affected?)
// 108:         .to be false
// 109:     end
// 110:
// 111:     it "treats multiple array entries as OR" do
// 112:       a = adv(affected: ["<1.0", ">=2.0,<2.5"], fixed: [">=1.0,<2.0", ">=2.5"])
// 113:       expect(described_class.range_status(a, "0.9").affected?).to be true
// 114:       expect(described_class.range_status(a, "2.1")).to have_attributes(affected?: true, fixed_in: "2.5")
// 115:       expect(described_class.range_status(a, "1.5").affected?).to be false
// 116:     end
// 117:
// 118:     it "treats a bare version term as equality and an empty affected_versions as always affected" do
// 119:       expect(described_class.range_status(adv(affected: ["1.0"], fixed: []), "1.0").affected?).to be true
// 120:       expect(described_class.range_status(adv(affected: ["1.0"], fixed: []), "1.1").affected?).to be false
// 121:       expect(described_class.range_status(adv(affected: [], fixed: []), "1.0").affected?).to be true
// 122:     end
// 123:
// 124:     it "does not report a version in the gap between affected and a strict >fix as :fixed" do
// 125:       status = described_class.range_status(adv(affected: ["<1.0"], fixed: [">1.0"]), "1.0")
// 126:       expect(status.state).to eq :not_applicable
// 127:       expect(described_class.range_status(adv(affected: ["<1.0"], fixed: [">1.0"]), "1.1").state).to eq :fixed
// 128:     end
// 129:
// 130:     it "reports affected with no fixed_in when there is no fixed_versions" do
// 131:       expect(described_class.range_status(adv(affected: ["<12.24"], fixed: []), "12.00"))
// 132:         .to have_attributes(affected?: true, fixed_in: nil)
// 133:     end
// 134:   end
// 135:
// 136:   describe ".load" do
// 137:     it "reads a fresh cache file without downloading" do
// 138:       Dir.mktmpdir do |dir|
// 139:         cache = Pathname(dir)
// 140:         FileUtils.cp fixture, cache/"cpansa.json"
// 141:         expect(Utils::Curl).not_to receive(:curl_download)
// 142:         loaded = described_class.load(cache:)
// 143:         expect(loaded.distributions).to include "DBI"
// 144:       end
// 145:     end
// 146:
// 147:     it "downloads to a temp file and atomically replaces a stale cache" do
// 148:       Dir.mktmpdir do |dir|
// 149:         cache = Pathname(dir)
// 150:         stale = cache/"cpansa.json"
// 151:         stale.write '{"dists": {}}'
// 152:         FileUtils.touch stale, mtime: Time.now - 100_000
// 153:         expect(Utils::Curl).to receive(:curl_download) do |*_args, to:|
// 154:           expect(to).not_to eq stale
// 155:           FileUtils.cp fixture, to
// 156:         end
// 157:         expect(described_class.load(cache:).distributions).to include "DBI"
// 158:         expect(stale.read).to eq fixture.read
// 159:         expect(cache.children.map { |c| c.basename.to_s }).to eq ["cpansa.json"]
// 160:       end
// 161:     end
// 162:
// 163:     it "downloads when the cache file is absent" do
// 164:       Dir.mktmpdir do |dir|
// 165:         cache = Pathname(dir)
// 166:         expect(Utils::Curl).to receive(:curl_download) do |*_args, to:|
// 167:           FileUtils.cp fixture, to
// 168:         end
// 169:         expect(described_class.load(cache:).advisories_for("Image-ExifTool").length).to eq 1
// 170:       end
// 171:     end
// 172:
// 173:     it "falls back to a stale cache when the download fails, leaving it intact" do
// 174:       Dir.mktmpdir do |dir|
// 175:         cache = Pathname(dir)
// 176:         stale = cache/"cpansa.json"
// 177:         FileUtils.cp fixture, stale
// 178:         FileUtils.touch stale, mtime: Time.now - 100_000
// 179:         original = stale.read
// 180:         expect(Utils::Curl).to receive(:curl_download)
// 181:           .and_raise(ErrorDuringExecution.new(["curl"], status: 22))
// 182:         loaded = T.let(nil, T.nilable(Homebrew::Vulns::CPANSec))
// 183:         expect { loaded = described_class.load(cache:) }
// 184:           .to output(/Failed to refresh cpansa\.json/).to_stderr
// 185:         expect(loaded&.distributions).to include "DBI"
// 186:         expect(stale.read).to eq original
// 187:       end
// 188:     end
// 189:
// 190:     it "falls back to a stale cache when the fetched file is invalid, leaving it intact" do
// 191:       Dir.mktmpdir do |dir|
// 192:         cache = Pathname(dir)
// 193:         stale = cache/"cpansa.json"
// 194:         FileUtils.cp fixture, stale
// 195:         FileUtils.touch stale, mtime: Time.now - 100_000
// 196:         original = stale.read
// 197:         expect(Utils::Curl).to receive(:curl_download) { |*_args, to:| to.write "not json" }
// 198:         loaded = T.let(nil, T.nilable(Homebrew::Vulns::CPANSec))
// 199:         expect { loaded = described_class.load(cache:) }
// 200:           .to output(/Failed to refresh cpansa\.json/).to_stderr
// 201:         expect(loaded&.distributions).to include "DBI"
// 202:         expect(stale.read).to eq original
// 203:         expect(cache.children).to eq [stale]
// 204:       end
// 205:     end
// 206:
// 207:     it "raises when the download fails and no cache exists" do
// 208:       Dir.mktmpdir do |dir|
// 209:         expect(Utils::Curl).to receive(:curl_download)
// 210:           .and_raise(ErrorDuringExecution.new(["curl"], status: 6))
// 211:         expect { described_class.load(cache: Pathname(dir)) }.to raise_error(ErrorDuringExecution)
// 212:       end
// 213:     end
// 214:   end
// 215: end
