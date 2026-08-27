module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/repology_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:fixture) { TEST_FIXTURE_DIR/"vulns/repology.json" }` at line 7.
pub fn ruby_repology_spec_l7_d1_fixture(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixture', ...args)
}

// Ruby let `let(:index) { described_class.from_file(fixture) }` at line 8.
pub fn ruby_repology_spec_l8_d2_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('index', ...args)
}

// Ruby it `it "raises Error when the top-level value is not a JSON object" do` at line 11.
pub fn ruby_repology_spec_l11_d3_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises Error when the formulae key is missing" do` at line 16.
pub fn ruby_repology_spec_l16_d4_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "exposes the meta block and formula names" do` at line 23.
pub fn ruby_repology_spec_l23_d5_exposes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exposes', ...args)
}

// Ruby it `it "returns the ecosystem => srcnames map for a known formula" do` at line 31.
pub fn ruby_repology_spec_l31_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns multiple candidate srcnames per ecosystem" do` at line 38.
pub fn ruby_repology_spec_l38_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "falls back to the base name for an @-versioned formula" do` at line 42.
pub fn ruby_repology_spec_l42_d8_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "returns an empty hash for an unknown formula" do` at line 47.
pub fn ruby_repology_spec_l47_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns frozen values" do` at line 51.
pub fn ruby_repology_spec_l51_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "drops malformed entries when coercing" do` at line 57.
pub fn ruby_repology_spec_l57_d11_drops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('drops', ...args)
}

// Ruby it `it "generates deduplicated normalisation variants" do` at line 65.
pub fn ruby_repology_spec_l65_d12_generates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generates', ...args)
}

// Ruby it `it "strips an @-version suffix and applies affix variants to the base" do` at line 70.
pub fn ruby_repology_spec_l70_d13_strips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strips', ...args)
}

// Ruby it `it "strips a trailing 2" do` at line 75.
pub fn ruby_repology_spec_l75_d14_strips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strips', ...args)
}

// Ruby it `it "returns just the name when no variant applies" do` at line 79.
pub fn ruby_repology_spec_l79_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "does not yield an empty candidate for a bare 'lib' name" do` at line 83.
pub fn ruby_repology_spec_l83_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:entries) do` at line 89.
pub fn ruby_repology_spec_l89_d17_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entries', ...args)
}

// Ruby it `it "collapses versioned repos, drops legacy, uses binname for FreeBSD, ignores unmapped repos" do` at line 101.
pub fn ruby_repology_spec_l101_d18_collapses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collapses', ...args)
}

// Ruby it `it "collects all distinct srcnames per ecosystem, sorted" do` at line 106.
pub fn ruby_repology_spec_l106_d19_collects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collects', ...args)
}

// Ruby it `it "returns an empty hash for no mappable entries" do` at line 114.
pub fn ruby_repology_spec_l114_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby method `project(homebrew:, distros:, status: "newest")` at line 120.
pub fn ruby_repology_spec_l120_d21_project(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('project', ...args)
}

// Ruby it `it "tries name candidates until one contains the requested formula in its Homebrew entries" do` at line 125.
pub fn ruby_repology_spec_l125_d22_tries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tries', ...args)
}

// Ruby it `it "rejects a candidate whose Homebrew entries do not include the requested formula" do` at line 133.
pub fn ruby_repology_spec_l133_d23_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "accepts a candidate that lists the @-stripped base name" do` at line 141.
pub fn ruby_repology_spec_l141_d24_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a project that also lists sibling formulae with a different base name" do` at line 149.
pub fn ruby_repology_spec_l149_d25_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "still rejects a candidate whose Homebrew entries do not include the requested formula at all" do` at line 160.
pub fn ruby_repology_spec_l160_d26_still(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('still', ...args)
}

// Ruby it `it "continues past a candidate with no mapped OSV distros" do` at line 170.
pub fn ruby_repology_spec_l170_d27_continues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('continues', ...args)
}

// Ruby it `it "resolves two matching candidates by preferred Homebrew status" do` at line 180.
pub fn ruby_repology_spec_l180_d28_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolves', ...args)
}

// Ruby it `it "prefers a sole exact-name contribution over a preferred base-name contribution" do` at line 190.
pub fn ruby_repology_spec_l190_d29_prefers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefers', ...args)
}

// Ruby it `it "falls back to a resolved base pool when the exact pool is an unresolvable collision" do` at line 203.
pub fn ruby_repology_spec_l203_d30_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "contributes a project listing both exact and base names to both pools" do` at line 216.
pub fn ruby_repology_spec_l216_d31_contributes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contributes', ...args)
}

// Ruby it `it "returns {} when two matching candidates both have preferred status (unresolvable)" do` at line 229.
pub fn ruby_repology_spec_l229_d32_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty hash when no candidate resolves" do` at line 239.
pub fn ruby_repology_spec_l239_d33_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "propagates fetch errors rather than treating them as a miss" do` at line 244.
pub fn ruby_repology_spec_l244_d34_propagates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('propagates', ...args)
}

// Ruby it `it "returns the entries array from ::Repology.single_package_query" do` at line 252.
pub fn ruby_repology_spec_l252_d35_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns [] for a nonexistent project (HTTP 200 with empty array)" do` at line 259.
pub fn ruby_repology_spec_l259_d36_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises Error when the underlying query fails (returns nil)" do` at line 264.
pub fn ruby_repology_spec_l264_d37_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises Error on an unexpected response shape" do` at line 270.
pub fn ruby_repology_spec_l270_d38_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "reads a fresh cache file without downloading" do` at line 278.
pub fn ruby_repology_spec_l278_d39_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Ruby it `it "falls back to a stale cache when the download fails" do` at line 287.
pub fn ruby_repology_spec_l287_d40_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/repology"
// 5:
// 6: RSpec.describe Homebrew::Vulns::Repology do
// 7:   let(:fixture) { TEST_FIXTURE_DIR/"vulns/repology.json" }
// 8:   let(:index) { described_class.from_file(fixture) }
// 9:
// 10:   describe "#initialize" do
// 11:     it "raises Error when the top-level value is not a JSON object" do
// 12:       expect { described_class.new([]) }
// 13:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /not a JSON object/)
// 14:     end
// 15:
// 16:     it "raises Error when the formulae key is missing" do
// 17:       expect { described_class.new({ "meta" => {} }) }
// 18:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /missing 'formulae' key/)
// 19:     end
// 20:   end
// 21:
// 22:   describe "#meta and #formulae" do
// 23:     it "exposes the meta block and formula names" do
// 24:       expect(index.meta["osv_distros"]).to include "Debian"
// 25:       expect(index.meta["ambiguous_projects"]).to eq({ "antlr" => ["antlr", "antlr4-cpp-runtime"] })
// 26:       expect(index.formulae).to contain_exactly("curl", "libgee", "ack", "postgresql")
// 27:     end
// 28:   end
// 29:
// 30:   describe "#distro_packages_for" do
// 31:     it "returns the ecosystem => srcnames map for a known formula" do
// 32:       expect(index.distro_packages_for("curl")).to eq(
// 33:         "Alpine" => ["curl"], "Debian" => ["curl"], "FreeBSD" => ["curl"],
// 34:         "Ubuntu" => ["curl"], "openSUSE" => ["curl"]
// 35:       )
// 36:     end
// 37:
// 38:     it "returns multiple candidate srcnames per ecosystem" do
// 39:       expect(index.distro_packages_for("ack")).to eq("Ubuntu" => ["ack", "ack-grep"])
// 40:     end
// 41:
// 42:     it "falls back to the base name for an @-versioned formula" do
// 43:       expect(index.distro_packages_for("postgresql@16"))
// 44:         .to eq("Debian" => ["postgresql-17"], "Alpine" => ["postgresql17"])
// 45:     end
// 46:
// 47:     it "returns an empty hash for an unknown formula" do
// 48:       expect(index.distro_packages_for("no-such-formula")).to eq({})
// 49:     end
// 50:
// 51:     it "returns frozen values" do
// 52:       result = index.distro_packages_for("libgee")
// 53:       expect(result).to be_frozen
// 54:       expect(result["Debian"]).to be_frozen
// 55:     end
// 56:
// 57:     it "drops malformed entries when coercing" do
// 58:       idx = described_class.new({ "formulae" => { "x" => { "Debian" => ["ok"], 123 => ["bad"],
// 59:                                                             "Empty" => [] } } })
// 60:       expect(idx.distro_packages_for("x")).to eq("Debian" => ["ok"])
// 61:     end
// 62:   end
// 63:
// 64:   describe ".name_candidates" do
// 65:     it "generates deduplicated normalisation variants" do
// 66:       expect(described_class.name_candidates("libmatio"))
// 67:         .to eq ["libmatio", "matio"]
// 68:     end
// 69:
// 70:     it "strips an @-version suffix and applies affix variants to the base" do
// 71:       expect(described_class.name_candidates("gnu-complexity@1"))
// 72:         .to eq ["gnu-complexity@1", "gnu-complexity", "complexity"]
// 73:     end
// 74:
// 75:     it "strips a trailing 2" do
// 76:       expect(described_class.name_candidates("qscintilla2")).to eq ["qscintilla2", "qscintilla"]
// 77:     end
// 78:
// 79:     it "returns just the name when no variant applies" do
// 80:       expect(described_class.name_candidates("curl")).to eq ["curl"]
// 81:     end
// 82:
// 83:     it "does not yield an empty candidate for a bare 'lib' name" do
// 84:       expect(described_class.name_candidates("lib")).to eq ["lib"]
// 85:     end
// 86:   end
// 87:
// 88:   describe ".distil" do
// 89:     let(:entries) do
// 90:       [
// 91:         { "repo" => "debian_12", "srcname" => "curl", "status" => "outdated" },
// 92:         { "repo" => "debian_13", "srcname" => "curl", "status" => "newest" },
// 93:         { "repo" => "alpine_3_17", "srcname" => "old-curl", "status" => "legacy" },
// 94:         { "repo" => "alpine_3_22", "srcname" => "curl", "status" => "newest" },
// 95:         { "repo" => "freebsd", "srcname" => "ftp/curl", "binname" => "curl", "status" => "newest" },
// 96:         { "repo" => "opensuse_games_tumbleweed", "srcname" => "wrong" },
// 97:         { "repo" => "scoop", "binname" => "curl" },
// 98:       ]
// 99:     end
// 100:
// 101:     it "collapses versioned repos, drops legacy, uses binname for FreeBSD, ignores unmapped repos" do
// 102:       expect(described_class.distil(entries))
// 103:         .to eq("Alpine" => ["curl"], "Debian" => ["curl"], "FreeBSD" => ["curl"])
// 104:     end
// 105:
// 106:     it "collects all distinct srcnames per ecosystem, sorted" do
// 107:       multi = [
// 108:         { "repo" => "ubuntu_22_04", "srcname" => "ack" },
// 109:         { "repo" => "ubuntu_18_04", "srcname" => "ack-grep" },
// 110:       ]
// 111:       expect(described_class.distil(multi)).to eq("Ubuntu" => ["ack", "ack-grep"])
// 112:     end
// 113:
// 114:     it "returns an empty hash for no mappable entries" do
// 115:       expect(described_class.distil([{ "repo" => "scoop" }])).to eq({})
// 116:     end
// 117:   end
// 118:
// 119:   describe ".lookup" do
// 120:     def project(homebrew:, distros:, status: "newest")
// 121:       homebrew.map { |n| { "repo" => "homebrew", "srcname" => n, "status" => status } } +
// 122:         distros.map { |repo, n| { "repo" => repo, "srcname" => n } }
// 123:     end
// 124:
// 125:     it "tries name candidates until one contains the requested formula in its Homebrew entries" do
// 126:       allow(described_class).to receive(:fetch_project).with("libmatio").and_return([])
// 127:       allow(described_class).to receive(:fetch_project).with("matio").and_return(
// 128:         project(homebrew: ["libmatio"], distros: [["debian_12", "matio"]]),
// 129:       )
// 130:       expect(described_class.lookup("libmatio")).to eq("Debian" => ["matio"])
// 131:     end
// 132:
// 133:     it "rejects a candidate whose Homebrew entries do not include the requested formula" do
// 134:       allow(described_class).to receive(:fetch_project).with("libc").and_return([])
// 135:       allow(described_class).to receive(:fetch_project).with("c").and_return(
// 136:         project(homebrew: ["c"], distros: [["freebsd", "c"]]),
// 137:       )
// 138:       expect(described_class.lookup("libc")).to eq({})
// 139:     end
// 140:
// 141:     it "accepts a candidate that lists the @-stripped base name" do
// 142:       allow(described_class).to receive(:fetch_project).with("node@20").and_return([])
// 143:       allow(described_class).to receive(:fetch_project).with("node").and_return(
// 144:         project(homebrew: ["node", "node@22"], distros: [["debian_12", "nodejs"]]),
// 145:       )
// 146:       expect(described_class.lookup("node@20")).to eq("Debian" => ["nodejs"])
// 147:     end
// 148:
// 149:     it "accepts a project that also lists sibling formulae with a different base name" do
// 150:       # Repology groups wget + wget2 under one project; the sibling's distro
// 151:       # srcnames come through as extra low-confidence distro queries whose
// 152:       # upstream-CVE range check will not match this formula's identity.
// 153:       allow(described_class).to receive(:fetch_project).with("wget").and_return(
// 154:         project(homebrew: ["wget", "wget2"],
// 155:                 distros:  [["debian_12", "wget"], ["debian_12", "wget2"]]),
// 156:       )
// 157:       expect(described_class.lookup("wget")).to eq("Debian" => ["wget", "wget2"])
// 158:     end
// 159:
// 160:     it "still rejects a candidate whose Homebrew entries do not include the requested formula at all" do
// 161:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 162:         project(homebrew: ["libfoo-utils"], distros: [["debian_12", "wrong"]]),
// 163:       )
// 164:       allow(described_class).to receive(:fetch_project).with("foo").and_return(
// 165:         project(homebrew: ["libfoo"], distros: [["debian_12", "foo"]]),
// 166:       )
// 167:       expect(described_class.lookup("libfoo")).to eq("Debian" => ["foo"])
// 168:     end
// 169:
// 170:     it "continues past a candidate with no mapped OSV distros" do
// 171:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 172:         project(homebrew: ["libfoo"], distros: [["scoop", "foo"]]),
// 173:       )
// 174:       allow(described_class).to receive(:fetch_project).with("foo").and_return(
// 175:         project(homebrew: ["libfoo"], distros: [["alpine_3_22", "foo"]]),
// 176:       )
// 177:       expect(described_class.lookup("libfoo")).to eq("Alpine" => ["foo"])
// 178:     end
// 179:
// 180:     it "resolves two matching candidates by preferred Homebrew status" do
// 181:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 182:         project(homebrew: ["libfoo"], distros: [["debian_12", "libfoo4"]], status: "rolling"),
// 183:       )
// 184:       allow(described_class).to receive(:fetch_project).with("foo").and_return(
// 185:         project(homebrew: ["libfoo"], distros: [["debian_12", "libfoo5"]], status: "newest"),
// 186:       )
// 187:       expect(described_class.lookup("libfoo")).to eq("Debian" => ["libfoo5"])
// 188:     end
// 189:
// 190:     it "prefers a sole exact-name contribution over a preferred base-name contribution" do
// 191:       allow(described_class).to receive(:fetch_project).with("libfoo@1").and_return(
// 192:         [{ "repo" => "homebrew", "srcname" => "libfoo@1", "status" => "rolling" },
// 193:          { "repo" => "homebrew", "srcname" => "libfoo", "status" => "newest" },
// 194:          { "repo" => "debian_12", "srcname" => "exact" }],
// 195:       )
// 196:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 197:         project(homebrew: ["libfoo"], distros: [["debian_12", "base"]]),
// 198:       )
// 199:       allow(described_class).to receive(:fetch_project).with("foo").and_return([])
// 200:       expect(described_class.lookup("libfoo@1")).to eq("Debian" => ["exact"])
// 201:     end
// 202:
// 203:     it "falls back to a resolved base pool when the exact pool is an unresolvable collision" do
// 204:       allow(described_class).to receive(:fetch_project).with("libfoo@1").and_return(
// 205:         project(homebrew: ["libfoo@1"], distros: [["debian_12", "a"]]),
// 206:       )
// 207:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 208:         project(homebrew: ["libfoo@1"], distros: [["debian_12", "b"]]),
// 209:       )
// 210:       allow(described_class).to receive(:fetch_project).with("foo").and_return(
// 211:         project(homebrew: ["libfoo"], distros: [["debian_12", "base"]]),
// 212:       )
// 213:       expect(described_class.lookup("libfoo@1")).to eq("Debian" => ["base"])
// 214:     end
// 215:
// 216:     it "contributes a project listing both exact and base names to both pools" do
// 217:       allow(described_class).to receive(:fetch_project).with("libfoo@1").and_return(
// 218:         project(homebrew: ["libfoo@1", "libfoo"], distros: [["debian_12", "a"]]),
// 219:       )
// 220:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 221:         project(homebrew: ["libfoo@1"], distros: [["debian_12", "b"]]),
// 222:       )
// 223:       allow(described_class).to receive(:fetch_project).with("foo").and_return([])
// 224:       # Exact pool: [a/true, b/true] collides. Base pool: [a/true] (from the
// 225:       # first project, which also lists `libfoo`) resolves.
// 226:       expect(described_class.lookup("libfoo@1")).to eq("Debian" => ["a"])
// 227:     end
// 228:
// 229:     it "returns {} when two matching candidates both have preferred status (unresolvable)" do
// 230:       allow(described_class).to receive(:fetch_project).with("libfoo").and_return(
// 231:         project(homebrew: ["libfoo"], distros: [["debian_12", "a"]]),
// 232:       )
// 233:       allow(described_class).to receive(:fetch_project).with("foo").and_return(
// 234:         project(homebrew: ["libfoo"], distros: [["debian_12", "b"]]),
// 235:       )
// 236:       expect(described_class.lookup("libfoo")).to eq({})
// 237:     end
// 238:
// 239:     it "returns an empty hash when no candidate resolves" do
// 240:       allow(described_class).to receive(:fetch_project).and_return([])
// 241:       expect(described_class.lookup("no-such")).to eq({})
// 242:     end
// 243:
// 244:     it "propagates fetch errors rather than treating them as a miss" do
// 245:       allow(described_class).to receive(:fetch_project)
// 246:         .and_raise(Homebrew::Vulns::CachedFeed::Error, "Repology API request failed")
// 247:       expect { described_class.lookup("curl") }.to raise_error(Homebrew::Vulns::CachedFeed::Error)
// 248:     end
// 249:   end
// 250:
// 251:   describe ".fetch_project" do
// 252:     it "returns the entries array from ::Repology.single_package_query" do
// 253:       entries = [{ "repo" => "debian_12", "srcname" => "curl" }]
// 254:       allow(Repology).to receive(:single_package_query)
// 255:         .with("curl", repository: Repology::HOMEBREW_CORE).and_return({ "curl" => entries })
// 256:       expect(described_class.fetch_project("curl")).to eq entries
// 257:     end
// 258:
// 259:     it "returns [] for a nonexistent project (HTTP 200 with empty array)" do
// 260:       allow(Repology).to receive(:single_package_query).and_return({ "no-such" => [] })
// 261:       expect(described_class.fetch_project("no-such")).to eq []
// 262:     end
// 263:
// 264:     it "raises Error when the underlying query fails (returns nil)" do
// 265:       allow(Repology).to receive(:single_package_query).and_return(nil)
// 266:       expect { described_class.fetch_project("curl") }
// 267:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /request for "curl" failed/)
// 268:     end
// 269:
// 270:     it "raises Error on an unexpected response shape" do
// 271:       allow(Repology).to receive(:single_package_query).and_return({ "curl" => { "oops" => true } })
// 272:       expect { described_class.fetch_project("curl") }
// 273:         .to raise_error(Homebrew::Vulns::CachedFeed::Error, /unexpected shape/)
// 274:     end
// 275:   end
// 276:
// 277:   describe ".load" do
// 278:     it "reads a fresh cache file without downloading" do
// 279:       Dir.mktmpdir do |dir|
// 280:         cache = Pathname(dir)
// 281:         FileUtils.cp fixture, cache/"repology.json"
// 282:         expect(Utils::Curl).not_to receive(:curl_download)
// 283:         expect(described_class.load(cache:).formulae).to include "curl"
// 284:       end
// 285:     end
// 286:
// 287:     it "falls back to a stale cache when the download fails" do
// 288:       Dir.mktmpdir do |dir|
// 289:         cache = Pathname(dir)
// 290:         stale = cache/"repology.json"
// 291:         FileUtils.cp fixture, stale
// 292:         FileUtils.touch stale, mtime: Time.now - (described_class.default_max_age + 1)
// 293:         expect(Utils::Curl).to receive(:curl_download)
// 294:           .and_raise(ErrorDuringExecution.new(["curl"], status: 22))
// 295:         loaded = T.let(nil, T.nilable(Homebrew::Vulns::Repology))
// 296:         expect { loaded = described_class.load(cache:) }
// 297:           .to output(/Failed to refresh repology\.json/).to_stderr
// 298:         expect(loaded&.formulae).to include "curl"
// 299:       end
// 300:     end
// 301:   end
// 302: end
