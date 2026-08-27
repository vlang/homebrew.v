module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/cpan_sec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:fixture) { TEST_FIXTURE_DIR/"vulns/cpansa.json" }` at line 7.
pub fn ruby_cpan_sec_spec_l7_d1_fixture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixture', ...args)
}

// Ruby let `let(:cpansa) { described_class.from_file(fixture) }` at line 8.
pub fn ruby_cpan_sec_spec_l8_d2_cpansa(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpansa', ...args)
}

// Ruby it `it "raises Error on unparseable JSON" do` at line 11.
pub fn ruby_cpan_sec_spec_l11_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises Error when the dists key is missing" do` at line 22.
pub fn ruby_cpan_sec_spec_l22_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises Error when the top-level value is not a JSON object" do` at line 27.
pub fn ruby_cpan_sec_spec_l27_d5_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "treats a null or absent meta as an empty hash" do` at line 32.
pub fn ruby_cpan_sec_spec_l32_d6_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('treats', ...args)
}

// Ruby it `it "returns the upstream build metadata" do` at line 39.
pub fn ruby_cpan_sec_spec_l39_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "lists all distribution names" do` at line 45.
pub fn ruby_cpan_sec_spec_l45_d8_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "returns Advisory structs with all fields populated" do` at line 51.
pub fn ruby_cpan_sec_spec_l51_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "coerces cves and affected_versions to string arrays and defaults absent optional fields" do` at line 65.
pub fn ruby_cpan_sec_spec_l65_d10_coerces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('coerces', ...args)
}

// Ruby it `it "returns all advisories for a distribution in file order" do` at line 74.
pub fn ruby_cpan_sec_spec_l74_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array for an unknown distribution" do` at line 79.
pub fn ruby_cpan_sec_spec_l79_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns frozen advisories" do` at line 83.
pub fn ruby_cpan_sec_spec_l83_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby method `adv(affected:, fixed:)` at line 89.
pub fn ruby_cpan_sec_spec_l89_d14_adv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adv', ...args)
}

// Ruby it `it "reports affected with fixed_in when the version is inside a single-bound constraint" do` at line 94.
pub fn ruby_cpan_sec_spec_l94_d15_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports not-affected with fixed_in when the version is at or past the fix" do` at line 99.
pub fn ruby_cpan_sec_spec_l99_d16_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "evaluates comma-joined AND terms" do` at line 104.
pub fn ruby_cpan_sec_spec_l104_d17_evaluates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('evaluates', ...args)
}

// Ruby it `it "treats multiple array entries as OR" do` at line 111.
pub fn ruby_cpan_sec_spec_l111_d18_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('treats', ...args)
}

// Ruby it `it "treats a bare version term as equality and an empty affected_versions as always affected" do` at line 118.
pub fn ruby_cpan_sec_spec_l118_d19_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('treats', ...args)
}

// Ruby it `it "does not report a version in the gap between affected and a strict >fix as :fixed" do` at line 124.
pub fn ruby_cpan_sec_spec_l124_d20_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reports affected with no fixed_in when there is no fixed_versions" do` at line 130.
pub fn ruby_cpan_sec_spec_l130_d21_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reads a fresh cache file without downloading" do` at line 137.
pub fn ruby_cpan_sec_spec_l137_d22_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "downloads to a temp file and atomically replaces a stale cache" do` at line 147.
pub fn ruby_cpan_sec_spec_l147_d23_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloads', ...args)
}

// Ruby it `it "downloads when the cache file is absent" do` at line 163.
pub fn ruby_cpan_sec_spec_l163_d24_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloads', ...args)
}

// Ruby it `it "falls back to a stale cache when the download fails, leaving it intact" do` at line 173.
pub fn ruby_cpan_sec_spec_l173_d25_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "falls back to a stale cache when the fetched file is invalid, leaving it intact" do` at line 190.
pub fn ruby_cpan_sec_spec_l190_d26_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "raises when the download fails and no cache exists" do` at line 207.
pub fn ruby_cpan_sec_spec_l207_d27_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
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
