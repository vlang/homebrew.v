module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/match_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:repology) do` at line 7.
pub fn ruby_match_spec_l7_d1_repology(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repology', ...args)
}

// Ruby let `let(:cpan_sec) do` at line 12.
pub fn ruby_match_spec_l12_d2_cpan_sec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpan_sec', ...args)
}

// Ruby let `let(:matcher) { described_class.new(repology:, cpan_sec:) }` at line 20.
pub fn ruby_match_spec_l20_d3_matcher(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matcher', ...args)
}

// Ruby method `stub_repology_lookup(result = {})` at line 22.
pub fn ruby_match_spec_l22_d4_stub_repology_lookup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_repology_lookup', ...args)
}

// Ruby method `vuln(data)` at line 26.
pub fn ruby_match_spec_l26_d5_vuln(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('vuln', ...args)
}

// Ruby method `ev(strategy, ecosystem: nil, name: nil, subject_version: nil, key: "k", resource: nil, advisory: nil)` at line 30.
pub fn ruby_match_spec_l30_d6_ev(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ev', ...args)
}

// Ruby method `make_hit(vulnerability, *evidence)` at line 35.
pub fn ruby_match_spec_l35_d7_make_hit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('make_hit', ...args)
}

// Ruby it `it "derives git repo/tag, primary registry package, resources and distro packages" do` at line 40.
pub fn ruby_match_spec_l40_d8_derives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('derives', ...args)
}

// Ruby it `it "falls back to Repology.lookup when the index has no entry (single-formula mode)" do` at line 67.
pub fn ruby_match_spec_l67_d9_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "does not fall back to Repology.lookup in bulk mode" do` at line 77.
pub fn ruby_match_spec_l77_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "swallows a Repology lookup error to an empty distro map" do` at line 88.
pub fn ruby_match_spec_l88_d11_swallows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swallows', ...args)
}

// Ruby it `it "reports identifiable? false when nothing is derivable" do` at line 99.
pub fn ruby_match_spec_l99_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `pkg(ecosystem:, name:, version:, purl:)` at line 111.
pub fn ruby_match_spec_l111_d13_pkg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkg', ...args)
}

// Ruby it `it "emits versionless GIT/registry/distro queries with subject_version carried on the evidence" do` at line 115.
pub fn ruby_match_spec_l115_d14_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "excludes CPAN packages from OSV queries and omits GIT when no repo derived" do` at line 142.
pub fn ruby_match_spec_l142_d15_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "returns the registry-entry status when GIT ranges are uncomparable" do` at line 156.
pub fn ruby_match_spec_l156_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when the only matching entry has GIT-type ranges" do` at line 174.
pub fn ruby_match_spec_l174_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "evaluates CPANSA constraint strings for :cpansa evidence" do` at line 185.
pub fn ruby_match_spec_l185_d18_evaluates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('evaluates', ...args)
}

// Ruby it `it "checks a distro-resolved upstream CVE against attached own-identity evidence" do` at line 196.
pub fn ruby_match_spec_l196_d19_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby it `it "skips evidence with no subject_version" do` at line 210.
pub fn ruby_match_spec_l210_d20_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "checks each evidence against its own source record after dedup merges hits" do` at line 215.
pub fn ruby_match_spec_l215_d21_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby it `it "reports :affected when a resource subject is affected even if the primary is :not_applicable" do` at line 239.
pub fn ruby_match_spec_l239_d22_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports :affected when a resource is affected even if the primary is :fixed" do` at line 258.
pub fn ruby_match_spec_l258_d23_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports :not_applicable only when every comparable subject is not_applicable" do` at line 275.
pub fn ruby_match_spec_l275_d24_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby let `let(:cpan_sec) do` at line 290.
pub fn ruby_match_spec_l290_d25_cpan_sec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpan_sec', ...args)
}

// Ruby it `it "scopes a synthesised fallback to the CVE being handled when OSV lacks it" do` at line 300.
pub fn ruby_match_spec_l300_d26_scopes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scopes', ...args)
}

// Ruby it `it "builds a hit directly from a CPANSA advisory that has no CVE alias" do` at line 325.
pub fn ruby_match_spec_l325_d27_builds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('builds', ...args)
}

// Ruby let `let(:identity) do` at line 346.
pub fn ruby_match_spec_l346_d28_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('identity', ...args)
}

// Ruby it `it "splits a multi-CVE distro advisory into one hit per upstream CVE with own-identity evidence" do` at line 353.
pub fn ruby_match_spec_l353_d29_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "follows upstream transitively (USN -> UBUNTU-CVE-* -> CVE-*) with cycle protection" do` at line 370.
pub fn ruby_match_spec_l370_d30_follows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('follows', ...args)
}

// Ruby it `it "consults related for bare CVE ids only for ALSA-* records with no upstream" do` at line 384.
pub fn ruby_match_spec_l384_d31_consults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('consults', ...args)
}

// Ruby it `it "does not consult related for a non-ALSA record with no upstream" do` at line 395.
pub fn ruby_match_spec_l395_d32_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "ignores related when upstream is present" do` at line 403.
pub fn ruby_match_spec_l403_d33_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "keeps a record whose id/aliases already include a CVE as-is" do` at line 414.
pub fn ruby_match_spec_l414_d34_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "keeps a record with no CVE anywhere as a low-confidence hit rather than dropping it" do` at line 422.
pub fn ruby_match_spec_l422_d35_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "keeps a record as-is when its upstream CVE cannot be fetched" do` at line 430.
pub fn ruby_match_spec_l430_d36_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "sends every formula's queries through one OSV.query_batch and yields per-formula hits" do` at line 441.
pub fn ruby_match_spec_l441_d37_sends(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sends', ...args)
}

// Ruby let `let(:exiftool) do` at line 469.
pub fn ruby_match_spec_l469_d38_exiftool(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exiftool', ...args)
}

// Ruby it `it "queries versionlessly, resolves distro upstream to CVEs, and dedups by CVE alias" do` at line 479.
pub fn ruby_match_spec_l479_d39_queries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('queries', ...args)
}

// Ruby it `it "returns [] without hitting OSV when nothing is identifiable" do` at line 513.
pub fn ruby_match_spec_l513_d40_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "caches OSV.vulnerability lookups across calls" do` at line 524.
pub fn ruby_match_spec_l524_d41_caches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caches', ...args)
}

// Ruby let `let(:requests) do` at line 536.
pub fn ruby_match_spec_l536_d42_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requests', ...args)
}

// Ruby let `let(:now) { Time.utc(2026, 7, 27, 12, 0, 0) }` at line 545.
pub fn ruby_match_spec_l545_d43_now(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('now', ...args)
}

// Ruby method `registry_hit(affected_events:, subject_version: "2.31.0", resource: nil, name: "requests")` at line 547.
pub fn ruby_match_spec_l547_d44_registry_hit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registry_hit', ...args)
}

// Ruby it `it "emits fixed=pkg_version and fix: bump when the range says the shipped version is not affected" do` at line 559.
pub fn ruby_match_spec_l559_d45_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits no fixed event and fix: nil when the range says the shipped version is still affected" do` at line 578.
pub fn ruby_match_spec_l578_d46_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits fix: nil and demotes confidence when no comparable range exists (GIT-only)" do` at line 588.
pub fn ruby_match_spec_l588_d47_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "records not_applicable and does not emit fixed for a version below every introduced" do` at line 604.
pub fn ruby_match_spec_l604_d48_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "prefers an explicit first_fixed over the derived value" do` at line 613.
pub fn ruby_match_spec_l613_d49_prefers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefers', ...args)
}

// Ruby it `it "records resource name and purl and evaluates against the resource's pinned version" do` at line 621.
pub fn ruby_match_spec_l621_d50_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby let `let(:requests) do` at line 635.
pub fn ruby_match_spec_l635_d51_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requests', ...args)
}

// Ruby method `stub_history(versions_newest_first)` at line 642.
pub fn ruby_match_spec_l642_d52_stub_history(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_history', ...args)
}

// Ruby method `hit_with_range(*events)` at line 666.
pub fn ruby_match_spec_l666_d53_hit_with_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hit_with_range', ...args)
}

// Ruby method `hit_fixed_at(fixed)` at line 676.
pub fn ruby_match_spec_l676_d54_hit_fixed_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hit_fixed_at', ...args)
}

// Ruby it `it "returns the pkg_version at the oldest revision still at or past upstream fixed_in" do` at line 680.
pub fn ruby_match_spec_l680_d55_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "honours last_affected inclusivity by re-running the range per revision" do` at line 685.
pub fn ruby_match_spec_l685_d56_honours(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('honours', ...args)
}

// Ruby it `it "returns :never_affected when Homebrew jumped from below introduced straight past fixed" do` at line 692.
pub fn ruby_match_spec_l692_d57_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns :never_affected when the formula was already past fixed at its first revision" do` at line 712.
pub fn ruby_match_spec_l712_d58_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "keeps versionless (distro) evidence uncheckable at historical revisions too" do` at line 717.
pub fn ruby_match_spec_l717_d59_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "aggregates every subject per revision so a fixed primary does not mask a later-fixed resource" do` at line 741.
pub fn ruby_match_spec_l741_d60_aggregates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregates', ...args)
}

// Ruby it `it "stops at an unloadable revision and returns the last known fixed pkg_version" do` at line 766.
pub fn ruby_match_spec_l766_d61_stops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stops', ...args)
}

// Ruby it `it "returns nil when the current version is still affected" do` at line 771.
pub fn ruby_match_spec_l771_d62_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when there is no comparable range" do` at line 776.
pub fn ruby_match_spec_l776_d63_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "sorts evidence by descending strategy precision and reports the highest as` at line 783.
pub fn ruby_match_spec_l783_d64_sorts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sorts', ...args)
}

// Ruby it `it "uses the lowest CVE alias as canonical_id, or the record id when there is none" do` at line 789.
pub fn ruby_match_spec_l789_d65_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "rejects empty evidence" do` at line 795.
pub fn ruby_match_spec_l795_d66_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/match"
// 5:
// 6: RSpec.describe Homebrew::Vulns::Match do
// 7:   let(:repology) do
// 8:     Homebrew::Vulns::Repology.new({ "meta" => {}, "formulae" => {
// 9:       "requests" => { "Debian" => ["requests"], "Alpine" => ["py3-requests"] },
// 10:     } })
// 11:   end
// 12:   let(:cpan_sec) do
// 13:     Homebrew::Vulns::CPANSec.new({ "meta" => {}, "dists" => {
// 14:       "Image-ExifTool" => { "advisories" => [
// 15:         { "id" => "CPANSA-Image-ExifTool-2021-22204", "cves" => ["CVE-2021-22204"],
// 16:           "affected_versions" => ["<12.24"], "fixed_versions" => [">=12.24"] },
// 17:       ] },
// 18:     } })
// 19:   end
// 20:   let(:matcher) { described_class.new(repology:, cpan_sec:) }
// 21:
// 22:   def stub_repology_lookup(result = {})
// 23:     allow(Homebrew::Vulns::Repology).to receive(:lookup).and_return(result)
// 24:   end
// 25:
// 26:   def vuln(data)
// 27:     Homebrew::Vulns::Vulnerability.new(data)
// 28:   end
// 29:
// 30:   def ev(strategy, ecosystem: nil, name: nil, subject_version: nil, key: "k", resource: nil, advisory: nil)
// 31:     Homebrew::Vulns::Match::Evidence.new(strategy:, ecosystem:, name:, subject_version:, key:,
// 32:                                          resource:, advisory:)
// 33:   end
// 34:
// 35:   def make_hit(vulnerability, *evidence)
// 36:     Homebrew::Vulns::Match::Hit.new(vulnerability:, evidence:)
// 37:   end
// 38:
// 39:   describe "#identify" do
// 40:     it "derives git repo/tag, primary registry package, resources and distro packages" do
// 41:       f = formula("requests") do
// 42:         T.bind(self, T.class_of(Formula))
// 43:         homepage "https://requests.readthedocs.io"
// 44:         url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-2.31.0.tar.gz"
// 45:         head "https://github.com/psf/requests.git"
// 46:         resource "certifi" do
// 47:           url "https://files.pythonhosted.org/packages/11/22/33/certifi-2024.2.2.tar.gz"
// 48:         end
// 49:         resource "vendored-c" do
// 50:           url "https://example.com/blob-1.0.tar.gz"
// 51:         end
// 52:       end
// 53:
// 54:       identity = matcher.identify(f)
// 55:
// 56:       expect(identity.git_repo).to eq "https://github.com/psf/requests"
// 57:       expect(identity.git_tag).to eq "2.31.0"
// 58:       expect(identity.primary_package.ecosystem).to eq "PyPI"
// 59:       expect(identity.primary_package.name).to eq "requests"
// 60:       expect(identity.resource_packages.keys).to eq ["certifi"]
// 61:       expect(identity.resource_packages["certifi"].purl).to eq "pkg:pypi/certifi@2024.2.2"
// 62:       expect(identity.distro_packages)
// 63:         .to eq("Debian" => ["requests"], "Alpine" => ["py3-requests"])
// 64:       expect(identity.identifiable?).to be true
// 65:     end
// 66:
// 67:     it "falls back to Repology.lookup when the index has no entry (single-formula mode)" do
// 68:       f = formula("newthing") do
// 69:         T.bind(self, T.class_of(Formula))
// 70:         url "https://example.com/newthing-1.0.tar.gz"
// 71:       end
// 72:       stub_repology_lookup({ "Debian" => ["newthing"] })
// 73:
// 74:       expect(matcher.identify(f).distro_packages).to eq("Debian" => ["newthing"])
// 75:     end
// 76:
// 77:     it "does not fall back to Repology.lookup in bulk mode" do
// 78:       f = formula("newthing") do
// 79:         T.bind(self, T.class_of(Formula))
// 80:         url "https://example.com/newthing-1.0.tar.gz"
// 81:       end
// 82:       expect(Homebrew::Vulns::Repology).not_to receive(:lookup)
// 83:
// 84:       bulk = described_class.new(repology:, cpan_sec:, bulk: true)
// 85:       expect(bulk.identify(f).distro_packages).to eq({})
// 86:     end
// 87:
// 88:     it "swallows a Repology lookup error to an empty distro map" do
// 89:       f = formula("newthing") do
// 90:         T.bind(self, T.class_of(Formula))
// 91:         url "https://example.com/newthing-1.0.tar.gz"
// 92:       end
// 93:       allow(Homebrew::Vulns::Repology).to receive(:lookup)
// 94:         .and_raise(Homebrew::Vulns::CachedFeed::Error, "boom")
// 95:
// 96:       expect(matcher.identify(f).distro_packages).to eq({})
// 97:     end
// 98:
// 99:     it "reports identifiable? false when nothing is derivable" do
// 100:       f = formula("mystery") do
// 101:         T.bind(self, T.class_of(Formula))
// 102:         url "https://example.com/mystery-1.0.tar.gz"
// 103:       end
// 104:       stub_repology_lookup
// 105:
// 106:       expect(matcher.identify(f).identifiable?).to be false
// 107:     end
// 108:   end
// 109:
// 110:   describe "#build_osv_queries" do
// 111:     def pkg(ecosystem:, name:, version:, purl:)
// 112:       Homebrew::Vulns::Identify::RegistryPackage.new(ecosystem:, name:, version:, purl:)
// 113:     end
// 114:
// 115:     it "emits versionless GIT/registry/distro queries with subject_version carried on the evidence" do
// 116:       identity = Homebrew::Vulns::Match::Identity.new(
// 117:         git_repo:          "https://github.com/psf/requests",
// 118:         git_tag:           "v2.31.0",
// 119:         primary_package:   pkg(ecosystem: "PyPI", name: "requests", version: "2.31.0",
// 120:                                purl: "pkg:pypi/requests@2.31.0"),
// 121:         resource_packages: { "certifi" => pkg(ecosystem: "PyPI", name: "certifi", version: "2024.2.2",
// 122:                                               purl: "pkg:pypi/certifi@2024.2.2") },
// 123:         distro_packages:   { "Debian" => ["requests"] },
// 124:       )
// 125:
// 126:       queries = matcher.build_osv_queries(identity, "2.31.0")
// 127:
// 128:       expect(queries.map(&:first)).to eq [
// 129:         { ecosystem: "GIT", name: "https://github.com/psf/requests", version: nil },
// 130:         { ecosystem: "PyPI", name: "requests", version: nil },
// 131:         { ecosystem: "PyPI", name: "certifi", version: nil },
// 132:         { ecosystem: "Debian", name: "requests", version: nil },
// 133:       ]
// 134:       expect(queries.map { |_, e| [e.strategy, e.ecosystem, e.name, e.subject_version, e.resource] }).to eq [
// 135:         [:git, "GIT", "https://github.com/psf/requests", "v2.31.0", nil],
// 136:         [:registry, "PyPI", "requests", "2.31.0", nil],
// 137:         [:registry, "PyPI", "certifi", "2024.2.2", "certifi"],
// 138:         [:distro, "Debian", "requests", nil, nil],
// 139:       ]
// 140:     end
// 141:
// 142:     it "excludes CPAN packages from OSV queries and omits GIT when no repo derived" do
// 143:       identity = Homebrew::Vulns::Match::Identity.new(
// 144:         git_repo:          nil,
// 145:         git_tag:           "13.55",
// 146:         primary_package:   pkg(ecosystem: "CPAN", name: "Image-ExifTool", version: "13.55",
// 147:                                purl: "pkg:cpan/EXIFTOOL/Image-ExifTool@13.55"),
// 148:         resource_packages: {}, distro_packages: {}
// 149:       )
// 150:
// 151:       expect(matcher.build_osv_queries(identity, "13.55")).to eq []
// 152:     end
// 153:   end
// 154:
// 155:   describe "#range_status" do
// 156:     it "returns the registry-entry status when GIT ranges are uncomparable" do
// 157:       v = vuln("id" => "CVE-1", "affected" => [
// 158:         { "package" => { "ecosystem" => "GIT", "name" => "https://github.com/jqlang/jq" },
// 159:           "ranges"  => [{ "type" => "GIT", "events" => [{ "fixed" => "e47e56d" }] }] },
// 160:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 161:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 162:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2.28.1" }] }] },
// 163:       ])
// 164:       hit = make_hit(v,
// 165:                      ev(:git, ecosystem: "GIT", name: "https://github.com/jqlang/jq",
// 166:                               subject_version: "1.8.1"),
// 167:                      ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0"))
// 168:
// 169:       status, evidence = matcher.range_status(hit)
// 170:       expect(status).to have_attributes(state: :fixed, fixed_in: "2.28.1")
// 171:       expect(evidence.strategy).to eq :registry
// 172:     end
// 173:
// 174:     it "returns nil when the only matching entry has GIT-type ranges" do
// 175:       v = vuln("id" => "CVE-2026-32316", "affected" => [
// 176:         { "package" => { "ecosystem" => "GIT", "name" => "https://github.com/jqlang/jq" },
// 177:           "ranges"  => [{ "type" => "GIT", "events" => [{ "fixed" => "e47e56d" }] }] },
// 178:       ])
// 179:       hit = make_hit(v, ev(:git, ecosystem: "GIT", name: "https://github.com/jqlang/jq",
// 180:                                  subject_version: "1.8.1"))
// 181:
// 182:       expect(matcher.range_status(hit)).to be_nil
// 183:     end
// 184:
// 185:     it "evaluates CPANSA constraint strings for :cpansa evidence" do
// 186:       adv = Homebrew::Vulns::CPANSec::Advisory.new(id: "CPANSA-X", cves: ["CVE-1"],
// 187:                                                    affected_versions: ["<12.24"],
// 188:                                                    fixed_versions: [">=12.24"])
// 189:       hit = make_hit(vuln("id" => "CVE-1"),
// 190:                      ev(:cpansa, ecosystem: "CPAN", name: "Image-ExifTool",
// 191:                                  subject_version: "13.55", advisory: adv))
// 192:
// 193:       expect(matcher.range_status(hit)&.first).to have_attributes(state: :fixed, fixed_in: "12.24")
// 194:     end
// 195:
// 196:     it "checks a distro-resolved upstream CVE against attached own-identity evidence" do
// 197:       v = vuln("id" => "CVE-2015-8863", "affected" => [
// 198:         { "package" => { "ecosystem" => "GIT", "name" => "https://github.com/jqlang/jq" },
// 199:           "ranges"  => [{ "type"   => "SEMVER",
// 200:                           "events" => [{ "introduced" => "0" }, { "fixed" => "1.6" }] }] },
// 201:       ])
// 202:       hit = make_hit(v,
// 203:                      ev(:distro, ecosystem: "Debian", name: "jq"),
// 204:                      ev(:distro, ecosystem: "GIT", name: "https://github.com/jqlang/jq",
// 205:                                  subject_version: "1.8.1", key: "upstream:..."))
// 206:
// 207:       expect(matcher.range_status(hit)&.first).to have_attributes(state: :fixed, fixed_in: "1.6")
// 208:     end
// 209:
// 210:     it "skips evidence with no subject_version" do
// 211:       hit = make_hit(vuln("id" => "CVE-1"), ev(:distro, ecosystem: "Debian", name: "jq"))
// 212:       expect(matcher.range_status(hit)).to be_nil
// 213:     end
// 214:
// 215:     it "checks each evidence against its own source record after dedup merges hits" do
// 216:       # CVE record from GIT query: no PyPI affected entry.
// 217:       cve = vuln("id" => "CVE-2024-47081", "affected" => [
// 218:         { "package" => { "ecosystem" => "GIT", "name" => "https://github.com/psf/requests" },
// 219:           "ranges"  => [{ "type" => "GIT", "events" => [{ "fixed" => "abc123" }] }] },
// 220:       ])
// 221:       # GHSA record from PyPI query: carries the PyPI range.
// 222:       ghsa = vuln("id" => "GHSA-9hjg-9r4m-mvj7", "aliases" => ["CVE-2024-47081"], "affected" => [
// 223:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 224:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 225:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2.32.4" }] }] },
// 226:       ])
// 227:       merged = matcher.dedup_by_cve([
// 228:         make_hit(cve, ev(:git, ecosystem: "GIT", name: "https://github.com/psf/requests",
// 229:                                subject_version: "2.31.0")),
// 230:         make_hit(ghsa, ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0")),
// 231:       ])
// 232:
// 233:       expect(merged.length).to eq 1
// 234:       status, evidence = matcher.range_status(merged.first)
// 235:       expect(status).to have_attributes(state: :affected, fixed_in: "2.32.4")
// 236:       expect(evidence.source_record.id).to eq "GHSA-9hjg-9r4m-mvj7"
// 237:     end
// 238:
// 239:     it "reports :affected when a resource subject is affected even if the primary is :not_applicable" do
// 240:       v = vuln("id" => "CVE-1", "affected" => [
// 241:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 242:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 243:                           "events" => [{ "introduced" => "3.0.0" }, { "fixed" => "3.0.4" }] }] },
// 244:         { "package" => { "ecosystem" => "PyPI", "name" => "certifi" },
// 245:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 246:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2025.1.1" }] }] },
// 247:       ])
// 248:       hit = make_hit(v,
// 249:                      ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0"),
// 250:                      ev(:registry, ecosystem: "PyPI", name: "certifi", subject_version: "2024.2.2",
// 251:                                    resource: "certifi"))
// 252:
// 253:       status, evidence = matcher.range_status(hit)
// 254:       expect(status).to have_attributes(state: :affected, fixed_in: "2025.1.1")
// 255:       expect(evidence.resource).to eq "certifi"
// 256:     end
// 257:
// 258:     it "reports :affected when a resource is affected even if the primary is :fixed" do
// 259:       v = vuln("id" => "CVE-1", "affected" => [
// 260:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 261:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 262:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2.28.1" }] }] },
// 263:         { "package" => { "ecosystem" => "PyPI", "name" => "certifi" },
// 264:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 265:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2025.1.1" }] }] },
// 266:       ])
// 267:       hit = make_hit(v,
// 268:                      ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0"),
// 269:                      ev(:registry, ecosystem: "PyPI", name: "certifi", subject_version: "2024.2.2",
// 270:                                    resource: "certifi"))
// 271:
// 272:       expect(matcher.range_status(hit)&.first).to have_attributes(state: :affected)
// 273:     end
// 274:
// 275:     it "reports :not_applicable only when every comparable subject is not_applicable" do
// 276:       v = vuln("id" => "CVE-1", "affected" => [
// 277:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 278:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 279:                           "events" => [{ "introduced" => "3.0.0" }, { "fixed" => "3.0.4" }] }] },
// 280:       ])
// 281:       hit = make_hit(v,
// 282:                      ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0"),
// 283:                      ev(:distro, ecosystem: "Debian", name: "requests"))
// 284:
// 285:       expect(matcher.range_status(hit)&.first&.state).to eq :not_applicable
// 286:     end
// 287:   end
// 288:
// 289:   describe "#hits_from" do
// 290:     let(:cpan_sec) do
// 291:       Homebrew::Vulns::CPANSec.new({ "meta" => {}, "dists" => {
// 292:         "No-CVE-Dist" => { "advisories" => [
// 293:           { "id"                => "CPANSA-No-CVE-Dist-2020-01", "cves" => [],
// 294:             "affected_versions" => ["<1.0"], "fixed_versions" => [">=1.0"],
// 295:             "description" => "d", "references" => ["https://x"] },
// 296:         ] },
// 297:       } })
// 298:     end
// 299:
// 300:     it "scopes a synthesised fallback to the CVE being handled when OSV lacks it" do
// 301:       cpan_sec = Homebrew::Vulns::CPANSec.new({ "meta" => {}, "dists" => {
// 302:         "Multi" => { "advisories" => [
// 303:           { "id" => "CPANSA-Multi-1", "cves" => ["CVE-2022-4988", "CVE-2022-4989"],
// 304:             "affected_versions" => ["<1.0"], "fixed_versions" => [">=1.0"] },
// 305:         ] },
// 306:       } })
// 307:       m = described_class.new(repology:, cpan_sec:)
// 308:       identity = Homebrew::Vulns::Match::Identity.new(
// 309:         git_repo: nil, git_tag: nil,
// 310:         primary_package: Homebrew::Vulns::Identify::RegistryPackage.new(
// 311:           ecosystem: "CPAN", name: "Multi", version: "0.9", purl: "pkg:cpan/X/Multi@0.9",
// 312:         ),
// 313:         resource_packages: {}, distro_packages: {}
// 314:       )
// 315:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2022-4988")
// 316:                                                             .and_raise(Homebrew::Vulns::OSV::ApiError, "404")
// 317:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2022-4989")
// 318:                                                             .and_return({ "id" => "CVE-2022-4989" })
// 319:
// 320:       hits = m.hits_from({}, identity)
// 321:
// 322:       expect(hits.map(&:canonical_id).sort).to eq ["CVE-2022-4988", "CVE-2022-4989"]
// 323:     end
// 324:
// 325:     it "builds a hit directly from a CPANSA advisory that has no CVE alias" do
// 326:       identity = Homebrew::Vulns::Match::Identity.new(
// 327:         git_repo: nil, git_tag: nil,
// 328:         primary_package: Homebrew::Vulns::Identify::RegistryPackage.new(
// 329:           ecosystem: "CPAN", name: "No-CVE-Dist", version: "0.9", purl: "pkg:cpan/X/No-CVE-Dist@0.9",
// 330:         ),
// 331:         resource_packages: {}, distro_packages: {}
// 332:       )
// 333:       expect(Homebrew::Vulns::OSV).not_to receive(:vulnerability)
// 334:
// 335:       hits = matcher.hits_from({}, identity)
// 336:
// 337:       expect(hits.length).to eq 1
// 338:       expect(hits.first.vulnerability.id).to eq "CPANSA-No-CVE-Dist-2020-01"
// 339:       expect(hits.first.vulnerability.references).to eq [{ "type" => "WEB", "url" => "https://x" }]
// 340:       expect(matcher.range_status(hits.first)&.first)
// 341:         .to have_attributes(state: :affected, fixed_in: "1.0")
// 342:     end
// 343:   end
// 344:
// 345:   describe "#resolve_upstream" do
// 346:     let(:identity) do
// 347:       Homebrew::Vulns::Match::Identity.new(
// 348:         git_repo: "https://github.com/jqlang/jq", git_tag: "1.8.1",
// 349:         primary_package: nil, resource_packages: {}, distro_packages: {}
// 350:       )
// 351:     end
// 352:
// 353:     it "splits a multi-CVE distro advisory into one hit per upstream CVE with own-identity evidence" do
// 354:       allow(matcher).to receive(:fetch_vulnerability).with("RHSA-2026:1").and_return(
// 355:         vuln("id" => "RHSA-2026:1", "upstream" => ["CVE-2026-0001", "CVE-2026-0002"]),
// 356:       )
// 357:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2026-0001")
// 358:                                                      .and_return(vuln("id" => "CVE-2026-0001"))
// 359:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2026-0002")
// 360:                                                      .and_return(vuln("id" => "CVE-2026-0002"))
// 361:
// 362:       hits = matcher.resolve_upstream(
// 363:         { "RHSA-2026:1" => [ev(:distro, ecosystem: "Red Hat", name: "jq")] }, identity
// 364:       )
// 365:
// 366:       expect(hits.map { |h| h.vulnerability.id }.sort).to eq ["CVE-2026-0001", "CVE-2026-0002"]
// 367:       expect(hits.first.evidence.map(&:ecosystem)).to include("Red Hat", "GIT")
// 368:     end
// 369:
// 370:     it "follows upstream transitively (USN -> UBUNTU-CVE-* -> CVE-*) with cycle protection" do
// 371:       allow(matcher).to receive(:fetch_vulnerability).with("USN-8202-1").and_return(
// 372:         vuln("id" => "USN-8202-1", "upstream" => ["UBUNTU-CVE-2024-0001"]),
// 373:       )
// 374:       allow(matcher).to receive(:fetch_vulnerability).with("UBUNTU-CVE-2024-0001").and_return(
// 375:         vuln("id" => "UBUNTU-CVE-2024-0001", "upstream" => ["CVE-2024-0001", "USN-8202-1"]),
// 376:       )
// 377:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2024-0001")
// 378:                                                      .and_return(vuln("id" => "CVE-2024-0001"))
// 379:
// 380:       hits = matcher.resolve_upstream({ "USN-8202-1" => [ev(:distro)] }, identity)
// 381:       expect(hits.map { |h| h.vulnerability.id }).to eq ["CVE-2024-0001"]
// 382:     end
// 383:
// 384:     it "consults related for bare CVE ids only for ALSA-* records with no upstream" do
// 385:       allow(matcher).to receive(:fetch_vulnerability).with("ALSA-1").and_return(
// 386:         vuln("id" => "ALSA-1", "related" => ["CVE-2024-0001", "RHSA-2024:1"]),
// 387:       )
// 388:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2024-0001")
// 389:                                                      .and_return(vuln("id" => "CVE-2024-0001"))
// 390:
// 391:       hits = matcher.resolve_upstream({ "ALSA-1" => [ev(:distro)] }, identity)
// 392:       expect(hits.map { |h| h.vulnerability.id }).to eq ["CVE-2024-0001"]
// 393:     end
// 394:
// 395:     it "does not consult related for a non-ALSA record with no upstream" do
// 396:       allow(matcher).to receive(:fetch_vulnerability).with("MGASA-1").and_return(
// 397:         vuln("id" => "MGASA-1", "related" => ["CVE-2024-9999"]),
// 398:       )
// 399:       hits = matcher.resolve_upstream({ "MGASA-1" => [ev(:distro)] }, identity)
// 400:       expect(hits.map { |h| h.vulnerability.id }).to eq ["MGASA-1"]
// 401:     end
// 402:
// 403:     it "ignores related when upstream is present" do
// 404:       allow(matcher).to receive(:fetch_vulnerability).with("DSA-1").and_return(
// 405:         vuln("id" => "DSA-1", "upstream" => ["CVE-2024-0001"], "related" => ["CVE-9999-9999"]),
// 406:       )
// 407:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2024-0001")
// 408:                                                      .and_return(vuln("id" => "CVE-2024-0001"))
// 409:
// 410:       hits = matcher.resolve_upstream({ "DSA-1" => [ev(:distro)] }, identity)
// 411:       expect(hits.map { |h| h.vulnerability.id }).to eq ["CVE-2024-0001"]
// 412:     end
// 413:
// 414:     it "keeps a record whose id/aliases already include a CVE as-is" do
// 415:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2024-0001").and_return(
// 416:         vuln("id" => "CVE-2024-0001", "upstream" => ["CVE-2024-0099"]),
// 417:       )
// 418:       hits = matcher.resolve_upstream({ "CVE-2024-0001" => [ev(:git)] }, identity)
// 419:       expect(hits.map { |h| h.vulnerability.id }).to eq ["CVE-2024-0001"]
// 420:     end
// 421:
// 422:     it "keeps a record with no CVE anywhere as a low-confidence hit rather than dropping it" do
// 423:       allow(matcher).to receive(:fetch_vulnerability).with("ALBA-2022:1788").and_return(
// 424:         vuln("id" => "ALBA-2022:1788", "upstream" => [], "related" => ["RHBA-2022:1788"]),
// 425:       )
// 426:       hits = matcher.resolve_upstream({ "ALBA-2022:1788" => [ev(:distro)] }, identity)
// 427:       expect(hits.map { |h| h.vulnerability.id }).to eq ["ALBA-2022:1788"]
// 428:     end
// 429:
// 430:     it "keeps a record as-is when its upstream CVE cannot be fetched" do
// 431:       allow(matcher).to receive(:fetch_vulnerability).with("DSA-1").and_return(
// 432:         vuln("id" => "DSA-1", "upstream" => ["CVE-2024-0404"]),
// 433:       )
// 434:       allow(matcher).to receive(:fetch_vulnerability).with("CVE-2024-0404").and_return(nil)
// 435:       hits = matcher.resolve_upstream({ "DSA-1" => [ev(:distro)] }, identity)
// 436:       expect(hits.map { |h| h.vulnerability.id }).to eq ["DSA-1"]
// 437:     end
// 438:   end
// 439:
// 440:   describe "#each_advisory_batch" do
// 441:     it "sends every formula's queries through one OSV.query_batch and yields per-formula hits" do
// 442:       a = formula("aa") do
// 443:         T.bind(self, T.class_of(Formula))
// 444:         url "https://github.com/owner/aa/archive/refs/tags/v1.0.tar.gz"
// 445:       end
// 446:       b = formula("bb") do
// 447:         T.bind(self, T.class_of(Formula))
// 448:         url "https://github.com/owner/bb/archive/refs/tags/v2.0.tar.gz"
// 449:       end
// 450:       bulk = described_class.new(repology:, cpan_sec:, bulk: true)
// 451:
// 452:       expect(Homebrew::Vulns::OSV).to receive(:query_batch).once.with(
// 453:         [
// 454:           { ecosystem: "GIT", name: "https://github.com/owner/aa", version: nil },
// 455:           { ecosystem: "GIT", name: "https://github.com/owner/bb", version: nil },
// 456:         ],
// 457:       ).and_return([[{ "id" => "CVE-2024-0001" }], []])
// 458:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-0001")
// 459:                                                             .and_return({ "id" => "CVE-2024-0001" })
// 460:
// 461:       yielded = T.let([], T::Array[[String, T::Array[String]]])
// 462:       bulk.each_advisory_batch([a, b]) { |f, hits| yielded << [f.name, hits.map(&:canonical_id)] }
// 463:
// 464:       expect(yielded).to eq [["aa", ["CVE-2024-0001"]], ["bb", []]]
// 465:     end
// 466:   end
// 467:
// 468:   describe "#advisories_for" do
// 469:     let(:exiftool) do
// 470:       formula("exiftool") do
// 471:         T.bind(self, T.class_of(Formula))
// 472:         url "https://cpan.metacpan.org/authors/id/E/EX/EXIFTOOL/Image-ExifTool-13.55.tar.gz"
// 473:         head "https://github.com/exiftool/exiftool.git"
// 474:       end
// 475:     end
// 476:
// 477:     before { stub_repology_lookup({ "Debian" => ["libimage-exiftool-perl"] }) }
// 478:
// 479:     it "queries versionlessly, resolves distro upstream to CVEs, and dedups by CVE alias" do
// 480:       expect(Homebrew::Vulns::OSV).to receive(:query_batch).with(
// 481:         [
// 482:           { ecosystem: "GIT", name: "https://github.com/exiftool/exiftool", version: nil },
// 483:           { ecosystem: "Debian", name: "libimage-exiftool-perl", version: nil },
// 484:         ],
// 485:       ).and_return(
// 486:         [
// 487:           [{ "id" => "CVE-2021-22204" }],
// 488:           [{ "id" => "DEBIAN-CVE-2021-22204" }, { "id" => "DSA-4910-1" }],
// 489:         ],
// 490:       )
// 491:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2021-22204").and_return(
// 492:         { "id" => "CVE-2021-22204", "aliases" => ["GHSA-xxxx"] },
// 493:       )
// 494:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("DEBIAN-CVE-2021-22204").and_return(
// 495:         { "id" => "DEBIAN-CVE-2021-22204", "upstream" => ["CVE-2021-22204"] },
// 496:       )
// 497:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("DSA-4910-1").and_return(
// 498:         { "id" => "DSA-4910-1", "upstream" => ["CVE-2021-22204", "CVE-2021-99999"] },
// 499:       )
// 500:       allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2021-99999").and_return(
// 501:         { "id" => "CVE-2021-99999" },
// 502:       )
// 503:
// 504:       hits = matcher.advisories_for(exiftool)
// 505:
// 506:       expect(hits.map(&:canonical_id).sort).to eq ["CVE-2021-22204", "CVE-2021-99999"]
// 507:       merged = hits.find { |h| h.canonical_id == "CVE-2021-22204" }
// 508:       expect(T.must(merged).strategy).to eq :git
// 509:       expect(T.must(merged).evidence.map(&:strategy).uniq.sort).to eq [:cpansa, :distro, :git]
// 510:       expect(T.must(merged).evidence.find { |e| e.strategy == :cpansa }&.advisory).not_to be_nil
// 511:     end
// 512:
// 513:     it "returns [] without hitting OSV when nothing is identifiable" do
// 514:       f = formula("mystery") do
// 515:         T.bind(self, T.class_of(Formula))
// 516:         url "https://example.com/mystery-1.0.tar.gz"
// 517:       end
// 518:       stub_repology_lookup
// 519:       expect(Homebrew::Vulns::OSV).not_to receive(:query_batch)
// 520:
// 521:       expect(matcher.advisories_for(f)).to eq []
// 522:     end
// 523:
// 524:     it "caches OSV.vulnerability lookups across calls" do
// 525:       allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 526:         .and_return([[{ "id" => "CVE-2021-22204" }], []])
// 527:       expect(Homebrew::Vulns::OSV).to receive(:vulnerability).once
// 528:                                                              .and_return({ "id" => "CVE-2021-22204" })
// 529:
// 530:       matcher.advisories_for(exiftool)
// 531:       matcher.advisories_for(exiftool)
// 532:     end
// 533:   end
// 534:
// 535:   describe "#to_brew_record" do
// 536:     let(:requests) do
// 537:       formula("requests") do
// 538:         T.bind(self, T.class_of(Formula))
// 539:         url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-2.31.0.tar.gz"
// 540:         resource "certifi" do
// 541:           url "https://files.pythonhosted.org/packages/11/22/33/certifi-2024.2.2.tar.gz"
// 542:         end
// 543:       end
// 544:     end
// 545:     let(:now) { Time.utc(2026, 7, 27, 12, 0, 0) }
// 546:
// 547:     def registry_hit(affected_events:, subject_version: "2.31.0", resource: nil, name: "requests")
// 548:       make_hit(
// 549:         vuln("id" => "CVE-2024-1234", "aliases" => ["GHSA-abcd"], "summary" => "s",
// 550:              "severity" => [{ "type" => "CVSS_V3", "score" => "..." }],
// 551:              "references" => [{ "type" => "ADVISORY", "url" => "https://x" }],
// 552:              "affected" => [{ "package" => { "ecosystem" => "PyPI", "name" => name },
// 553:                               "ranges"  => [{ "type" => "ECOSYSTEM", "events" => affected_events }] }]),
// 554:         ev(:registry, ecosystem: "PyPI", name:, subject_version:,
// 555:                       key: "pkg:pypi/#{name}@#{subject_version}", resource:),
// 556:       )
// 557:     end
// 558:
// 559:     it "emits fixed=pkg_version and fix: bump when the range says the shipped version is not affected" do
// 560:       hit = registry_hit(affected_events: [{ "introduced" => "0" }, { "fixed" => "2.28.1" }])
// 561:
// 562:       record = matcher.to_brew_record(requests, hit, now:)
// 563:
// 564:       expect(record[:id]).to eq "BREW-requests-CVE-2024-1234"
// 565:       expect(record[:upstream]).to eq ["CVE-2024-1234", "GHSA-abcd"]
// 566:       expect(record[:severity]).to eq [{ "type" => "CVSS_V3", "score" => "..." }]
// 567:       expect(record[:references]).to eq [{ "type" => "ADVISORY", "url" => "https://x" }]
// 568:       aff = record[:affected].first
// 569:       expect(aff[:package]).to eq(ecosystem: "Homebrew", name: "requests", purl: "pkg:brew/requests")
// 570:       expect(aff[:ranges]).to eq [{ type:   "ECOSYSTEM",
// 571:                                     events: [{ introduced: "0" }, { fixed: requests.pkg_version.to_s }] }]
// 572:       expect(aff[:ecosystem_specific]).to eq(fix: "bump", range_state: "fixed", upstream_fixed_in: "2.28.1")
// 573:       expect(record.dig(:database_specific, :source)).to eq "matched"
// 574:       expect(record.dig(:database_specific, :strategy)).to eq "registry"
// 575:       expect(record.dig(:database_specific, :confidence)).to eq "high"
// 576:     end
// 577:
// 578:     it "emits no fixed event and fix: nil when the range says the shipped version is still affected" do
// 579:       hit = registry_hit(affected_events: [{ "introduced" => "0" }, { "fixed" => "2.32.0" }])
// 580:
// 581:       record = matcher.to_brew_record(requests, hit, now:)
// 582:
// 583:       aff = record[:affected].first
// 584:       expect(aff[:ranges]).to eq [{ type: "ECOSYSTEM", events: [{ introduced: "0" }] }]
// 585:       expect(aff[:ecosystem_specific]).to eq(fix: nil, range_state: "affected", upstream_fixed_in: "2.32.0")
// 586:     end
// 587:
// 588:     it "emits fix: nil and demotes confidence when no comparable range exists (GIT-only)" do
// 589:       hit = make_hit(
// 590:         vuln("id" => "CVE-2026-32316", "affected" => [
// 591:           { "package" => { "ecosystem" => "GIT", "name" => "https://github.com/jqlang/jq" },
// 592:             "ranges"  => [{ "type" => "GIT", "events" => [{ "fixed" => "e47e56d" }] }] },
// 593:         ]),
// 594:         ev(:git, ecosystem: "GIT", name: "https://github.com/jqlang/jq", subject_version: "1.8.1"),
// 595:       )
// 596:
// 597:       record = matcher.to_brew_record(requests, hit, now:)
// 598:
// 599:       expect(record.dig(:affected, 0, :ranges, 0, :events)).to eq [{ introduced: "0" }]
// 600:       expect(record.dig(:affected, 0, :ecosystem_specific)).to eq(fix: nil)
// 601:       expect(record.dig(:database_specific, :confidence)).to eq "medium"
// 602:     end
// 603:
// 604:     it "records not_applicable and does not emit fixed for a version below every introduced" do
// 605:       hit = registry_hit(affected_events: [{ "introduced" => "3.0.0" }, { "fixed" => "3.0.4" }])
// 606:
// 607:       record = matcher.to_brew_record(requests, hit, now:)
// 608:
// 609:       expect(record.dig(:affected, 0, :ranges, 0, :events)).to eq [{ introduced: "0" }]
// 610:       expect(record.dig(:affected, 0, :ecosystem_specific)).to eq(fix: nil, range_state: "not_applicable")
// 611:     end
// 612:
// 613:     it "prefers an explicit first_fixed over the derived value" do
// 614:       hit = registry_hit(affected_events: [{ "introduced" => "0" }, { "fixed" => "2.28.1" }])
// 615:
// 616:       record = matcher.to_brew_record(requests, hit, first_fixed: "2.28.1_1", now:)
// 617:
// 618:       expect(record.dig(:affected, 0, :ranges, 0, :events)).to eq [{ introduced: "0" }, { fixed: "2.28.1_1" }]
// 619:     end
// 620:
// 621:     it "records resource name and purl and evaluates against the resource's pinned version" do
// 622:       hit = registry_hit(affected_events: [{ "introduced" => "0" }, { "fixed" => "2024.2.2" }],
// 623:                          subject_version: "2024.2.2", resource: "certifi", name: "certifi")
// 624:
// 625:       record = matcher.to_brew_record(requests, hit, now:)
// 626:
// 627:       expect(record.dig(:affected, 0, :ecosystem_specific))
// 628:         .to eq(fix: "bump", range_state: "fixed", upstream_fixed_in: "2024.2.2",
// 629:                resource: "certifi", resource_purl: "pkg:pypi/certifi@2024.2.2")
// 630:       expect(record.dig(:affected, 0, :ranges, 0, :events).last).to eq(fixed: requests.pkg_version.to_s)
// 631:     end
// 632:   end
// 633:
// 634:   describe "#first_fixed_version" do
// 635:     let(:requests) do
// 636:       formula("requests") do
// 637:         T.bind(self, T.class_of(Formula))
// 638:         url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-2.31.0.tar.gz"
// 639:       end
// 640:     end
// 641:
// 642:     def stub_history(versions_newest_first)
// 643:       fv = instance_double(FormulaVersions)
// 644:       revs = versions_newest_first.each_with_index.map { |_, i| ["r#{i}", "Formula/r/requests.rb"] }
// 645:       allow(fv).to receive(:rev_list) { |_, &b| revs.each { |rev, entry| b.call(rev, entry) } }
// 646:       versions_newest_first.each_with_index do |entry, i|
// 647:         primary, res = Array(entry)
// 648:         old = if primary
// 649:           formula("requests") do
// 650:             T.bind(self, T.class_of(Formula))
// 651:             url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-#{primary}.tar.gz"
// 652:             if res
// 653:               resource "certifi" do
// 654:                 url "https://files.pythonhosted.org/packages/11/22/33/certifi-#{res}.tar.gz"
// 655:               end
// 656:             end
// 657:           end
// 658:         end
// 659:         allow(fv).to receive(:formula_at_revision).with("r#{i}", anything) do |&b|
// 660:           old && b.call(old)
// 661:         end
// 662:       end
// 663:       allow(FormulaVersions).to receive(:new).and_return(fv)
// 664:     end
// 665:
// 666:     def hit_with_range(*events)
// 667:       make_hit(
// 668:         vuln("id" => "CVE-1", "affected" => [
// 669:           { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 670:             "ranges"  => [{ "type" => "ECOSYSTEM", "events" => events }] },
// 671:         ]),
// 672:         ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0"),
// 673:       )
// 674:     end
// 675:
// 676:     def hit_fixed_at(fixed)
// 677:       hit_with_range({ "introduced" => "0" }, { "fixed" => fixed })
// 678:     end
// 679:
// 680:     it "returns the pkg_version at the oldest revision still at or past upstream fixed_in" do
// 681:       stub_history(["2.31.0", "2.30.0", "2.28.1", "2.28.0", "2.27.0"])
// 682:       expect(matcher.first_fixed_version(requests, hit_fixed_at("2.28.1"))).to eq "2.28.1"
// 683:     end
// 684:
// 685:     it "honours last_affected inclusivity by re-running the range per revision" do
// 686:       stub_history(["2.31.0", "2.1", "2.0", "1.9"])
// 687:       hit = hit_with_range({ "introduced" => "0" }, { "last_affected" => "2.0" })
// 688:       # 2.0 is the last *affected* version so 2.1 is the first fixed pkg_version.
// 689:       expect(matcher.first_fixed_version(requests, hit)).to eq "2.1"
// 690:     end
// 691:
// 692:     it "returns :never_affected when Homebrew jumped from below introduced straight past fixed" do
// 693:       # Advisory {introduced: 2.0, fixed: 3.0}; Homebrew went 1.0 -> 4.0 and
// 694:       # never shipped a 2.x, so no BREW record should be emitted.
// 695:       stub_history(["4.0", "1.0"])
// 696:       current = formula("requests") do
// 697:         T.bind(self, T.class_of(Formula))
// 698:         url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-4.0.tar.gz"
// 699:       end
// 700:       hit = make_hit(
// 701:         vuln("id" => "CVE-1", "affected" => [
// 702:           { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 703:             "ranges"  => [{ "type"   => "ECOSYSTEM",
// 704:                             "events" => [{ "introduced" => "2.0" }, { "fixed" => "3.0" }] }] },
// 705:         ]),
// 706:         ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "4.0"),
// 707:       )
// 708:
// 709:       expect(matcher.first_fixed_version(current, hit)).to eq :never_affected
// 710:     end
// 711:
// 712:     it "returns :never_affected when the formula was already past fixed at its first revision" do
// 713:       stub_history(["2.31.0"])
// 714:       expect(matcher.first_fixed_version(requests, hit_fixed_at("2.28.1"))).to eq :never_affected
// 715:     end
// 716:
// 717:     it "keeps versionless (distro) evidence uncheckable at historical revisions too" do
// 718:       stub_history(["2.31.0", "2.30.0", "2.28.1", "2.28.0"])
// 719:       # A distro record whose Debian range would spuriously match our formula
// 720:       # version if it were compared: ensure it stays skipped in the walk.
// 721:       distro_record = vuln("id" => "DEBIAN-CVE-1", "affected" => [
// 722:         { "package" => { "ecosystem" => "Debian", "name" => "requests" },
// 723:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 724:                           "events" => [{ "introduced" => "0" }, { "fixed" => "999+deb12u1" }] }] },
// 725:       ])
// 726:       registry_record = vuln("id" => "GHSA-x", "aliases" => ["CVE-1"], "affected" => [
// 727:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 728:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 729:                           "events" => [{ "introduced" => "0" }, { "fixed" => "2.28.1" }] }] },
// 730:       ])
// 731:       hit = matcher.dedup_by_cve([
// 732:         make_hit(registry_record,
// 733:                  ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "2.31.0")),
// 734:         make_hit(distro_record,
// 735:                  ev(:distro, ecosystem: "Debian", name: "requests", subject_version: nil)),
// 736:       ]).first
// 737:
// 738:       expect(matcher.first_fixed_version(requests, hit)).to eq "2.28.1"
// 739:     end
// 740:
// 741:     it "aggregates every subject per revision so a fixed primary does not mask a later-fixed resource" do
// 742:       # Primary requests fixed upstream in 2.0; resource certifi fixed upstream in 100.0.
// 743:       # History (formula pkg_version => [primary, certifi]): the resource crossed its
// 744:       # threshold at formula 3.0; the primary crossed at 2.0. Aggregate is only :fixed
// 745:       # from 3.0 onward.
// 746:       stub_history([["4.0", "101.0"], ["3.0", "100.0"], ["2.5", "99.0"], ["2.0", "98.0"], ["1.0", "97.0"]])
// 747:       v = vuln("id" => "CVE-1", "affected" => [
// 748:         { "package" => { "ecosystem" => "PyPI", "name" => "requests" },
// 749:           "ranges"  => [{ "type" => "ECOSYSTEM", "events" => [{ "introduced" => "0" }, { "fixed" => "2.0" }] }] },
// 750:         { "package" => { "ecosystem" => "PyPI", "name" => "certifi" },
// 751:           "ranges"  => [{ "type" => "ECOSYSTEM", "events" => [{ "introduced" => "0" }, { "fixed" => "100.0" }] }] },
// 752:       ])
// 753:       current = formula("requests") do
// 754:         T.bind(self, T.class_of(Formula))
// 755:         url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-4.0.tar.gz"
// 756:         resource("certifi") { url "https://files.pythonhosted.org/packages/11/22/33/certifi-101.0.tar.gz" }
// 757:       end
// 758:       hit = make_hit(v,
// 759:                      ev(:registry, ecosystem: "PyPI", name: "requests", subject_version: "4.0"),
// 760:                      ev(:registry, ecosystem: "PyPI", name: "certifi", subject_version: "101.0",
// 761:                                    resource: "certifi"))
// 762:
// 763:       expect(matcher.first_fixed_version(current, hit)).to eq "3.0"
// 764:     end
// 765:
// 766:     it "stops at an unloadable revision and returns the last known fixed pkg_version" do
// 767:       stub_history(["2.31.0", "2.30.0", nil, "2.28.0"])
// 768:       expect(matcher.first_fixed_version(requests, hit_fixed_at("2.28.1"))).to eq "2.30.0"
// 769:     end
// 770:
// 771:     it "returns nil when the current version is still affected" do
// 772:       expect(FormulaVersions).not_to receive(:new)
// 773:       expect(matcher.first_fixed_version(requests, hit_fixed_at("2.32.0"))).to be_nil
// 774:     end
// 775:
// 776:     it "returns nil when there is no comparable range" do
// 777:       hit = make_hit(vuln("id" => "CVE-1"), ev(:distro, ecosystem: "Debian", name: "requests"))
// 778:       expect(matcher.first_fixed_version(requests, hit)).to be_nil
// 779:     end
// 780:   end
// 781:
// 782:   describe Homebrew::Vulns::Match::Hit do
// 783:     it "sorts evidence by descending strategy precision and reports the highest as #strategy" do
// 784:       hit = make_hit(vuln("id" => "CVE-1"), ev(:distro), ev(:git), ev(:registry))
// 785:       expect(hit.evidence.map(&:strategy)).to eq [:git, :registry, :distro]
// 786:       expect(hit.strategy).to eq :git
// 787:     end
// 788:
// 789:     it "uses the lowest CVE alias as canonical_id, or the record id when there is none" do
// 790:       expect(make_hit(vuln("id" => "GHSA-x", "aliases" => ["CVE-2024-2", "CVE-2024-1"]),
// 791:                       ev(:git)).canonical_id).to eq "CVE-2024-1"
// 792:       expect(make_hit(vuln("id" => "GHSA-y"), ev(:git)).canonical_id).to eq "GHSA-y"
// 793:     end
// 794:
// 795:     it "rejects empty evidence" do
// 796:       expect { described_class.new(vulnerability: vuln("id" => "CVE-1"), evidence: []) }
// 797:         .to raise_error(ArgumentError)
// 798:     end
// 799:   end
// 800: end
