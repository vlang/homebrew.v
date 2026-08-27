module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/generate-vulns-advisories_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "writes advisories for core formulae with security patch resolves" do` at line 10.
pub fn ruby_generate_vulns_advisories_spec_l10_d1_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "writes nothing with --dry-run" do` at line 49.
pub fn ruby_generate_vulns_advisories_spec_l49_d2_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby subject `subject(:cmd) { described_class.new(["out"]) }` at line 77.
pub fn ruby_generate_vulns_advisories_spec_l77_d3_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd', ...args)
}

// Ruby it `it "unions base patches with every variation's patches, deduplicated" do` at line 79.
pub fn ruby_generate_vulns_advisories_spec_l79_d4_unions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unions', ...args)
}

// Ruby it `it "returns base patches when there are no variations" do` at line 94.
pub fn ruby_generate_vulns_advisories_spec_l94_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby subject `subject(:cmd) { described_class.new(["out"]) }` at line 105.
pub fn ruby_generate_vulns_advisories_spec_l105_d6_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd', ...args)
}

// Ruby let `let(:current) { formula("x") { url "https://example.com/x-1.2.tar.gz" } }` at line 107.
pub fn ruby_generate_vulns_advisories_spec_l107_d7_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current', ...args)
}

// Ruby method `with_history(revisions)` at line 109.
pub fn ruby_generate_vulns_advisories_spec_l109_d8_with_history(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_history', ...args)
}

// Ruby method `old_formula(pkg_version:, resolves_ids: [])` at line 121.
pub fn ruby_generate_vulns_advisories_spec_l121_d9_old_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_formula', ...args)
}

// Ruby it `it "returns the pkg_version at the oldest revision where the CVE is resolved" do` at line 126.
pub fn ruby_generate_vulns_advisories_spec_l126_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the oldest resolved version when the CVE is resolved in every revision" do` at line 138.
pub fn ruby_generate_vulns_advisories_spec_l138_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "stops at an unloadable revision and returns the last known resolved version" do` at line 147.
pub fn ruby_generate_vulns_advisories_spec_l147_d12_stops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stops', ...args)
}

// Ruby it `it "returns nil when the CVE is not resolved at the newest revision" do` at line 157.
pub fn ruby_generate_vulns_advisories_spec_l157_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-vulns-advisories"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateVulnsAdvisories do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "writes advisories for core formulae with security patch resolves" do
// 11:     nvi = formula("nvi") do
// 12:       T.bind(self, T.class_of(Formula))
// 13:       url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6.orig.tar.gz"
// 14:       version "1.81.6"
// 15:       revision 6
// 16:       patch do
// 17:         url "https://deb.debian.org/debian/pool/main/n/nvi/nvi_1.81.6-17.debian.tar.xz"
// 18:         sha256 "abc"
// 19:         resolves "CVE-2015-2305"
// 20:       end
// 21:     end
// 22:     plain = formula("plain") { url "https://example.com/plain-1.0.tar.gz" }
// 23:     [nvi, plain].each do |f|
// 24:       allow(f).to receive(:to_hash_with_variations)
// 25:         .and_return({ "patches" => f.serialized_patches, "variations" => {} })
// 26:     end
// 27:
// 28:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core", formula_names: ["nvi", "plain"])
// 29:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 30:     allow(Formulary).to receive(:enable_factory_cache!)
// 31:     allow(Formulary).to receive(:factory).with("nvi").and_return(nvi)
// 32:     allow(Formulary).to receive(:factory).with("plain").and_return(plain)
// 33:     allow(Homebrew::Vulns::OSV).to receive(:vulnerability).and_return({})
// 34:     allow(FormulaVersions).to receive(:new).and_return(instance_double(FormulaVersions, rev_list: nil))
// 35:
// 36:     Dir.mktmpdir do |dir|
// 37:       out = "#{dir}/advisories"
// 38:       described_class.new([out]).run
// 39:
// 40:       files = Dir.children(out).sort
// 41:       expect(files).to eq ["BREW-nvi-CVE-2015-2305.json"]
// 42:
// 43:       record = JSON.parse(File.read("#{out}/BREW-nvi-CVE-2015-2305.json"))
// 44:       expect(record["affected"][0]["package"]["ecosystem"]).to eq "Homebrew"
// 45:       expect(record["affected"][0]["ranges"][0]["events"][1]).to eq({ "fixed" => "1.81.6_6" })
// 46:     end
// 47:   end
// 48:
// 49:   it "writes nothing with --dry-run" do
// 50:     nvi = formula("nvi") do
// 51:       T.bind(self, T.class_of(Formula))
// 52:       url "https://example.com/nvi-1.81.6.tar.gz"
// 53:       patch do
// 54:         url "https://example.com/fix.patch"
// 55:         sha256 "abc"
// 56:         resolves "CVE-2015-2305"
// 57:       end
// 58:     end
// 59:     allow(nvi).to receive(:to_hash_with_variations)
// 60:       .and_return({ "patches" => nvi.serialized_patches, "variations" => {} })
// 61:
// 62:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core", formula_names: ["nvi"])
// 63:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 64:     allow(Formulary).to receive(:enable_factory_cache!)
// 65:     allow(Formulary).to receive(:factory).with("nvi").and_return(nvi)
// 66:
// 67:     Dir.mktmpdir do |dir|
// 68:       out = "#{dir}/nonexistent"
// 69:       expect(Homebrew::Vulns::OSV).not_to receive(:vulnerability)
// 70:       expect { described_class.new(["--dry-run", out]).run }
// 71:         .to output(/^BREW-nvi-CVE-2015-2305$/).to_stdout
// 72:       expect(Dir.exist?(out)).to be false
// 73:     end
// 74:   end
// 75:
// 76:   describe "#all_variation_patches" do
// 77:     subject(:cmd) { described_class.new(["out"]) }
// 78:
// 79:     it "unions base patches with every variation's patches, deduplicated" do
// 80:       f = instance_double(
// 81:         Formula,
// 82:         to_hash_with_variations: {
// 83:           "patches"    => [{ "url" => "a" }, { "url" => "b" }],
// 84:           "variations" => {
// 85:             arm64_linux:  { "patches" => [{ "url" => "a" }, { "url" => "linux-only" }] },
// 86:             x86_64_linux: { "name" => "irrelevant" },
// 87:           },
// 88:         },
// 89:       )
// 90:
// 91:       expect(cmd.all_variation_patches(f)).to eq [{ "url" => "a" }, { "url" => "b" }, { "url" => "linux-only" }]
// 92:     end
// 93:
// 94:     it "returns base patches when there are no variations" do
// 95:       f = instance_double(
// 96:         Formula,
// 97:         to_hash_with_variations: { "patches" => [{ "url" => "a" }], "variations" => {} },
// 98:       )
// 99:
// 100:       expect(cmd.all_variation_patches(f)).to eq [{ "url" => "a" }]
// 101:     end
// 102:   end
// 103:
// 104:   describe "#first_fixed_version" do
// 105:     subject(:cmd) { described_class.new(["out"]) }
// 106:
// 107:     let(:current) { formula("x") { url "https://example.com/x-1.2.tar.gz" } }
// 108:
// 109:     def with_history(revisions)
// 110:       fv = instance_double(FormulaVersions)
// 111:       allow(FormulaVersions).to receive(:new).with(current).and_return(fv)
// 112:       allow(fv).to receive(:rev_list).with("HEAD") do |&blk|
// 113:         revisions.each_key { |rev| blk.call(rev, "Formula/x/x.rb") }
// 114:       end
// 115:       allow(fv).to receive(:formula_at_revision) do |rev, _entry, &blk|
// 116:         old = revisions.fetch(rev)
// 117:         old.nil? ? nil : blk.call(old)
// 118:       end
// 119:     end
// 120:
// 121:     def old_formula(pkg_version:, resolves_ids: [])
// 122:       patches = resolves_ids.map { |id| { "resolves" => [{ "type" => "security", "id" => id }] } }
// 123:       instance_double(Formula, pkg_version: PkgVersion.parse(pkg_version), serialized_patches: patches)
// 124:     end
// 125:
// 126:     it "returns the pkg_version at the oldest revision where the CVE is resolved" do
// 127:       with_history(
// 128:         "r3" => old_formula(pkg_version: "1.2_1", resolves_ids: ["CVE-2024-1"]),
// 129:         "r2" => old_formula(pkg_version: "1.2", resolves_ids: ["CVE-2024-1"]),
// 130:         "r1" => old_formula(pkg_version: "1.1", resolves_ids: []),
// 131:         # Trap: if the walk continued past r1 it would wrongly return 1.0.
// 132:         "r0" => old_formula(pkg_version: "1.0", resolves_ids: ["CVE-2024-1"]),
// 133:       )
// 134:
// 135:       expect(cmd.first_fixed_version(current, "CVE-2024-1")).to eq "1.2"
// 136:     end
// 137:
// 138:     it "returns the oldest resolved version when the CVE is resolved in every revision" do
// 139:       with_history(
// 140:         "r2" => old_formula(pkg_version: "1.1", resolves_ids: ["CVE-2024-1"]),
// 141:         "r1" => old_formula(pkg_version: "1.0", resolves_ids: ["CVE-2024-1"]),
// 142:       )
// 143:
// 144:       expect(cmd.first_fixed_version(current, "CVE-2024-1")).to eq "1.0"
// 145:     end
// 146:
// 147:     it "stops at an unloadable revision and returns the last known resolved version" do
// 148:       with_history(
// 149:         "r3" => old_formula(pkg_version: "1.2", resolves_ids: ["CVE-2024-1"]),
// 150:         "r2" => nil,
// 151:         "r1" => old_formula(pkg_version: "1.0", resolves_ids: ["CVE-2024-1"]),
// 152:       )
// 153:
// 154:       expect(cmd.first_fixed_version(current, "CVE-2024-1")).to eq "1.2"
// 155:     end
// 156:
// 157:     it "returns nil when the CVE is not resolved at the newest revision" do
// 158:       with_history(
// 159:         "r2" => old_formula(pkg_version: "1.2", resolves_ids: []),
// 160:         # Trap: if the walk continued past r2 it would wrongly return 1.0.
// 161:         "r1" => old_formula(pkg_version: "1.0", resolves_ids: ["CVE-2024-1"]),
// 162:       )
// 163:
// 164:       expect(cmd.first_fixed_version(current, "CVE-2024-1")).to be_nil
// 165:     end
// 166:   end
// 167: end
