module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/advisory_database_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `record(id, formula, events:, fix: nil, upstream: nil, summary: nil, severity: nil)` at line 7.
pub fn ruby_advisory_database_spec_l7_d1_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('record', ...args)
}

// Ruby method `db(by_formula)` at line 21.
pub fn ruby_advisory_database_spec_l21_d2_db(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('db', ...args)
}

// Ruby it `it "raises Error when the top-level value is not a JSON object" do` at line 27.
pub fn ruby_advisory_database_spec_l27_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises Error when the advisories key is missing" do` at line 32.
pub fn ruby_advisory_database_spec_l32_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "distinguishes a wrong-type advisories value from a missing key" do` at line 37.
pub fn ruby_advisory_database_spec_l37_d5_distinguishes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('distinguishes', ...args)
}

// Ruby it `it "wraps each record for the formula in a Vulnerability" do` at line 44.
pub fn ruby_advisory_database_spec_l44_d6_wraps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wraps', ...args)
}

// Ruby it `it "returns [] for a formula with no records" do` at line 51.
pub fn ruby_advisory_database_spec_l51_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:corpus) do` at line 57.
pub fn ruby_advisory_database_spec_l57_d8_corpus(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('corpus', ...args)
}

// Ruby it `it "partitions into open (still in range), patched (fix: patch, past range), and fixed_count" do` at line 75.
pub fn ruby_advisory_database_spec_l75_d9_partitions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('partitions', ...args)
}

// Ruby it `it "counts a patch record whose fixed boundary is above pkg_version as open" do` at line 86.
pub fn ruby_advisory_database_spec_l86_d10_counts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('counts', ...args)
}

// Ruby it `it "returns nil when the corpus has no records for the formula" do` at line 93.
pub fn ruby_advisory_database_spec_l93_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "ignores :not_applicable records rather than counting them as fixed or patched" do` at line 97.
pub fn ruby_advisory_database_spec_l97_d12_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "compacts nil fields out of each entry hash" do` at line 110.
pub fn ruby_advisory_database_spec_l110_d13_compacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compacts', ...args)
}

// Ruby it `it "accepts a PkgVersion" do` at line 115.
pub fn ruby_advisory_database_spec_l115_d14_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "exposes the index keys and meta block" do` at line 122.
pub fn ruby_advisory_database_spec_l122_d15_exposes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exposes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/advisory_database"
// 5:
// 6: RSpec.describe Homebrew::Vulns::AdvisoryDatabase do
// 7:   def record(id, formula, events:, fix: nil, upstream: nil, summary: nil, severity: nil)
// 8:     {
// 9:       "id"       => id,
// 10:       "upstream" => upstream,
// 11:       "summary"  => summary,
// 12:       "severity" => severity,
// 13:       "affected" => [{
// 14:         "package"            => { "ecosystem" => "Homebrew", "name" => formula },
// 15:         "ranges"             => [{ "type" => "ECOSYSTEM", "events" => events }],
// 16:         "ecosystem_specific" => { "fix" => fix },
// 17:       }],
// 18:     }.compact
// 19:   end
// 20:
// 21:   def db(by_formula)
// 22:     described_class.new({ "meta"       => { "count" => by_formula.each_value.sum(&:size) },
// 23:                           "advisories" => by_formula })
// 24:   end
// 25:
// 26:   describe "#initialize" do
// 27:     it "raises Error when the top-level value is not a JSON object" do
// 28:       expect { described_class.new([]) }
// 29:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /not a JSON object/)
// 30:     end
// 31:
// 32:     it "raises Error when the advisories key is missing" do
// 33:       expect { described_class.new({ "meta" => {} }) }
// 34:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /no 'advisories' key/)
// 35:     end
// 36:
// 37:     it "distinguishes a wrong-type advisories value from a missing key" do
// 38:       expect { described_class.new({ "advisories" => [] }) }
// 39:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /'advisories' is not a JSON object/)
// 40:     end
// 41:   end
// 42:
// 43:   describe "#records_for" do
// 44:     it "wraps each record for the formula in a Vulnerability" do
// 45:       d = db({ "unzip" => [record("BREW-unzip-CVE-1", "unzip",
// 46:                                   events: [{ "introduced" => "0" }, { "fixed" => "6.0_29" }])] })
// 47:       expect(d.records_for("unzip").map(&:id)).to eq ["BREW-unzip-CVE-1"]
// 48:       expect(d.records_for("unzip").first).to be_a Homebrew::Vulns::Vulnerability
// 49:     end
// 50:
// 51:     it "returns [] for a formula with no records" do
// 52:       expect(db({}).records_for("nope")).to eq []
// 53:     end
// 54:   end
// 55:
// 56:   describe "#status_for" do
// 57:     let(:corpus) do
// 58:       db({
// 59:         "unzip" => [
// 60:           record("BREW-unzip-CVE-2014-8139", "unzip",
// 61:                  events: [{ "introduced" => "0" }, { "fixed" => "6.0_29" }],
// 62:                  fix: "patch", upstream: ["CVE-2014-8139"], summary: "s",
// 63:                  severity: [{ "type"  => "CVSS_V3",
// 64:                               "score" => "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H" }]),
// 65:           record("BREW-unzip-CVE-2021-4217", "unzip",
// 66:                  events:   [{ "introduced" => "0" }],
// 67:                  upstream: ["CVE-2021-4217"]),
// 68:           record("BREW-unzip-CVE-2016-0001", "unzip",
// 69:                  events: [{ "introduced" => "0" }, { "fixed" => "6.0_10" }],
// 70:                  fix: "bump", upstream: ["CVE-2016-0001"]),
// 71:         ],
// 72:       })
// 73:     end
// 74:
// 75:     it "partitions into open (still in range), patched (fix: patch, past range), and fixed_count" do
// 76:       status = corpus.status_for("unzip", "6.0_29")
// 77:
// 78:       expect(status["open"].map { |e| e["id"] }).to eq ["BREW-unzip-CVE-2021-4217"]
// 79:       expect(status["open"].first["upstream"]).to eq ["CVE-2021-4217"]
// 80:       expect(status["patched"].map { |e| e["id"] }).to eq ["BREW-unzip-CVE-2014-8139"]
// 81:       expect(status["patched"].first["severity"]).to eq "critical"
// 82:       expect(status["patched"].first["fixed_in"]).to eq "6.0_29"
// 83:       expect(status["fixed_count"]).to eq 1
// 84:     end
// 85:
// 86:     it "counts a patch record whose fixed boundary is above pkg_version as open" do
// 87:       status = corpus.status_for("unzip", "6.0_28")
// 88:       expect(status["open"].map { |e| e["id"] })
// 89:         .to contain_exactly("BREW-unzip-CVE-2014-8139", "BREW-unzip-CVE-2021-4217")
// 90:       expect(status["patched"]).to eq []
// 91:     end
// 92:
// 93:     it "returns nil when the corpus has no records for the formula" do
// 94:       expect(corpus.status_for("nope", "1.0")).to be_nil
// 95:     end
// 96:
// 97:     it "ignores :not_applicable records rather than counting them as fixed or patched" do
// 98:       d = db({ "foo" => [
// 99:         record("BREW-foo-CVE-1", "foo",
// 100:                events: [{ "introduced" => "2.0" }, { "fixed" => "3.0" }], fix: "bump"),
// 101:         record("BREW-foo-CVE-2", "foo",
// 102:                events: [{ "introduced" => "2.0" }, { "fixed" => "3.0" }], fix: "patch"),
// 103:       ] })
// 104:       status = d.status_for("foo", "1.0")
// 105:       expect(status["open"]).to eq []
// 106:       expect(status["patched"]).to eq []
// 107:       expect(status["fixed_count"]).to eq 0
// 108:     end
// 109:
// 110:     it "compacts nil fields out of each entry hash" do
// 111:       status = corpus.status_for("unzip", "6.0_29")
// 112:       expect(status["open"].first.keys).to eq %w[id upstream]
// 113:     end
// 114:
// 115:     it "accepts a PkgVersion" do
// 116:       require "pkg_version"
// 117:       expect(corpus.status_for("unzip", PkgVersion.parse("6.0_29"))["fixed_count"]).to eq 1
// 118:     end
// 119:   end
// 120:
// 121:   describe "#formulae and #meta" do
// 122:     it "exposes the index keys and meta block" do
// 123:       d = db({ "a" => [], "b" => [] })
// 124:       expect(d.formulae).to contain_exactly("a", "b")
// 125:       expect(d.meta["count"]).to eq 0
// 126:     end
// 127:   end
// 128: end
