module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/advisory-match_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:requests) do` at line 8.
pub fn ruby_advisory_match_spec_l8_d1_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requests', ...args)
}

// Ruby method `cmd_for(*argv, formulae: [requests])` at line 29.
pub fn ruby_advisory_match_spec_l29_d2_cmd_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cmd_for', ...args)
}

// Ruby method `stub_osv_hit(cve, fixed:)` at line 35.
pub fn ruby_advisory_match_spec_l35_d3_stub_osv_hit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_osv_hit', ...args)
}

// Ruby it `it "writes matched records to --output=<dir> with merge_existing semantics" do` at line 47.
pub fn ruby_advisory_match_spec_l47_d4_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "drops :not_applicable hits instead of emitting them as open ranges" do` at line 69.
pub fn ruby_advisory_match_spec_l69_d5_drops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('drops', ...args)
}

// Ruby it `it "does not overwrite an existing source: generated record" do` at line 82.
pub fn ruby_advisory_match_spec_l82_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "emits records as JSON with --json" do` at line 97.
pub fn ruby_advisory_match_spec_l97_d7_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "prints a per-hit summary in text mode" do` at line 105.
pub fn ruby_advisory_match_spec_l105_d8_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "loads the Repology index from --repology=<file> instead of the published feed" do` at line 113.
pub fn ruby_advisory_match_spec_l113_d9_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "raises on an unreadable --repology file" do` at line 128.
pub fn ruby_advisory_match_spec_l128_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "reports an OSV outage and finishes the emitter without raising" do` at line 133.
pub fn ruby_advisory_match_spec_l133_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "iterates every core formula with --all and streams to --output" do` at line 142.
pub fn ruby_advisory_match_spec_l142_d12_iterates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('iterates', ...args)
}

// Ruby it `it "rejects --all with --json" do` at line 159.
pub fn ruby_advisory_match_spec_l159_d13_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "emits the formula-identity index with --index" do` at line 163.
pub fn ruby_advisory_match_spec_l163_d14_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby method `capture_stdout` at line 175.
pub fn ruby_advisory_match_spec_l175_d15_capture_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('capture_stdout', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/advisory-match"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::AdvisoryMatch do
// 8:   let(:requests) do
// 9:     formula("requests") do
// 10:       T.bind(self, T.class_of(Formula))
// 11:       url "https://files.pythonhosted.org/packages/aa/bb/cc/requests-2.31.0.tar.gz"
// 12:       head "https://github.com/psf/requests.git"
// 13:     end
// 14:   end
// 15:
// 16:   before do
// 17:     allow(Formulary).to receive(:enable_factory_cache!)
// 18:     allow(Homebrew::Vulns::Repology).to receive_messages(
// 19:       load:   Homebrew::Vulns::Repology.new({ "meta" => {}, "formulae" => {} }),
// 20:       lookup: {},
// 21:     )
// 22:     allow(Homebrew::Vulns::CPANSec).to receive(:load).and_return(
// 23:       Homebrew::Vulns::CPANSec.new({ "meta" => {}, "dists" => {} }),
// 24:     )
// 25:   end
// 26:
// 27:   it_behaves_like "parseable arguments"
// 28:
// 29:   def cmd_for(*argv, formulae: [requests])
// 30:     cmd = described_class.new(argv)
// 31:     allow(cmd.args.named).to receive(:to_resolved_formulae).and_return(formulae)
// 32:     cmd
// 33:   end
// 34:
// 35:   def stub_osv_hit(cve, fixed:)
// 36:     allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => cve }], []])
// 37:     allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with(cve).and_return(
// 38:       { "id" => cve, "summary" => "s",
// 39:         "affected" => [{
// 40:           "package" => { "ecosystem" => "GIT", "name" => "https://github.com/psf/requests" },
// 41:           "ranges"  => [{ "type"   => "ECOSYSTEM",
// 42:                           "events" => [{ "introduced" => "0" }, { "fixed" => fixed }] }],
// 43:         }] },
// 44:     )
// 45:   end
// 46:
// 47:   it "writes matched records to --output=<dir> with merge_existing semantics" do
// 48:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 49:
// 50:     Dir.mktmpdir do |dir|
// 51:       expect { cmd_for("requests", "--output", dir, "--no-history").run }
// 52:         .to output(/1 records written/).to_stdout
// 53:
// 54:       path = File.join(dir, "BREW-requests-CVE-2024-1234.json")
// 55:       record = JSON.parse(File.read(path))
// 56:       expect(record.dig("affected", 0, "package"))
// 57:         .to eq("ecosystem" => "Homebrew", "name" => "requests", "purl" => "pkg:brew/requests")
// 58:       expect(record.dig("affected", 0, "ranges", 0, "events", 1))
// 59:         .to eq("fixed" => requests.pkg_version.to_s)
// 60:       expect(record.dig("database_specific", "source")).to eq "matched"
// 61:       expect(record.dig("database_specific", "strategy")).to eq "git"
// 62:
// 63:       # A second run with the same output should report 0 written / 1 unchanged.
// 64:       expect { cmd_for("requests", "--output", dir, "--no-history").run }
// 65:         .to output(/0 records written to #{Regexp.escape(dir)} \(1 unchanged, 0 generated/).to_stdout
// 66:     end
// 67:   end
// 68:
// 69:   it "drops :not_applicable hits instead of emitting them as open ranges" do
// 70:     allow(Homebrew::Vulns::OSV).to receive(:query_batch).and_return([[{ "id" => "CVE-2024-1234" }], []])
// 71:     allow(Homebrew::Vulns::OSV).to receive(:vulnerability).with("CVE-2024-1234").and_return(
// 72:       { "id" => "CVE-2024-1234", "affected" => [{
// 73:         "package" => { "ecosystem" => "GIT", "name" => "https://github.com/psf/requests" },
// 74:         "ranges"  => [{ "type"   => "ECOSYSTEM",
// 75:                         "events" => [{ "introduced" => "3.0.0" }, { "fixed" => "3.0.4" }] }],
// 76:       }] },
// 77:     )
// 78:
// 79:     expect(JSON.parse(capture_stdout { cmd_for("requests", "--json", "--no-history").run })).to eq []
// 80:   end
// 81:
// 82:   it "does not overwrite an existing source: generated record" do
// 83:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 84:
// 85:     Dir.mktmpdir do |dir|
// 86:       path = File.join(dir, "BREW-requests-CVE-2024-1234.json")
// 87:       File.write(path, JSON.generate({ "id"                => "BREW-requests-CVE-2024-1234",
// 88:                                        "database_specific" => { "source" => "generated" },
// 89:                                        "affected"          => [{ "ecosystem_specific" => { "fix" => "patch" } }] }))
// 90:
// 91:       expect { cmd_for("requests", "--output", dir, "--no-history").run }
// 92:         .to output(/0 records written.*1 generated left as-is/).to_stdout
// 93:       expect(JSON.parse(File.read(path)).dig("affected", 0, "ecosystem_specific", "fix")).to eq "patch"
// 94:     end
// 95:   end
// 96:
// 97:   it "emits records as JSON with --json" do
// 98:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 99:
// 100:     records = JSON.parse(capture_stdout { cmd_for("requests", "--json", "--no-history").run })
// 101:     expect(records.length).to eq 1
// 102:     expect(records.first["id"]).to eq "BREW-requests-CVE-2024-1234"
// 103:   end
// 104:
// 105:   it "prints a per-hit summary in text mode" do
// 106:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 107:
// 108:     expect { cmd_for("requests", "--no-history").run }
// 109:       .to output(/requests 2\.31\.0.*CVE-2024-1234 \[git, high\].*fixed \(upstream 2\.28\.1\).*1 candidate/m)
// 110:       .to_stdout
// 111:   end
// 112:
// 113:   it "loads the Repology index from --repology=<file> instead of the published feed" do
// 114:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 115:
// 116:     Dir.mktmpdir do |dir|
// 117:       path = File.join(dir, "repology.json")
// 118:       File.write(path, JSON.generate({ "meta" => {}, "formulae" => {} }))
// 119:       expect(Homebrew::Vulns::Repology).not_to receive(:load)
// 120:
// 121:       records = JSON.parse(capture_stdout do
// 122:         cmd_for("requests", "--json", "--no-history", "--repology", path).run
// 123:       end)
// 124:       expect(records.first["id"]).to eq "BREW-requests-CVE-2024-1234"
// 125:     end
// 126:   end
// 127:
// 128:   it "raises on an unreadable --repology file" do
// 129:     expect { cmd_for("requests", "--json", "--repology", "/nonexistent/repology.json").run }
// 130:       .to raise_error(Errno::ENOENT)
// 131:   end
// 132:
// 133:   it "reports an OSV outage and finishes the emitter without raising" do
// 134:     allow(Homebrew::Vulns::OSV).to receive(:query_batch)
// 135:       .and_raise(Homebrew::Vulns::OSV::ApiError, "503")
// 136:
// 137:     expect { cmd_for("requests", "--json").run }
// 138:       .to output("[]\n").to_stdout.and output(/OSV query failed: 503/).to_stderr
// 139:     expect(Homebrew.failed?).to be true
// 140:   end
// 141:
// 142:   it "iterates every core formula with --all and streams to --output" do
// 143:     requests
// 144:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core",
// 145:                                formula_names: ["requests", "broken"])
// 146:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 147:     allow(Formulary).to receive(:factory).with("requests").and_return(requests)
// 148:     allow(Formulary).to receive(:factory).with("broken").and_raise(RuntimeError, "boom")
// 149:     stub_osv_hit("CVE-2024-1234", fixed: "2.28.1")
// 150:
// 151:     Dir.mktmpdir do |dir|
// 152:       expect { described_class.new(["--all", "--output", dir, "--no-history"]).run }
// 153:         .to output(/1 records written/).to_stdout
// 154:         .and output(/Error loading formula 'broken': boom/).to_stderr
// 155:       expect(File).to exist(File.join(dir, "BREW-requests-CVE-2024-1234.json"))
// 156:     end
// 157:   end
// 158:
// 159:   it "rejects --all with --json" do
// 160:     expect { described_class.new(["--all", "--json"]) }.to raise_error(UsageError, /mutually exclusive/)
// 161:   end
// 162:
// 163:   it "emits the formula-identity index with --index" do
// 164:     requests
// 165:     core_tap = instance_double(CoreTap, installed?: true, name: "homebrew/core", formula_names: ["requests"])
// 166:     allow(CoreTap).to receive(:instance).and_return(core_tap)
// 167:     allow(Formulary).to receive(:factory).with("requests").and_return(requests)
// 168:
// 169:     output = capture_stdout { described_class.new(["--index"]).run }
// 170:     index = JSON.parse(output)
// 171:     expect(index.dig("requests", "git_repo")).to eq "https://github.com/psf/requests"
// 172:     expect(index.dig("requests", "primary_package", "ecosystem")).to eq "PyPI"
// 173:   end
// 174:
// 175:   def capture_stdout
// 176:     out = StringIO.new
// 177:     old = $stdout
// 178:     $stdout = out
// 179:     yield
// 180:     out.string
// 181:   ensure
// 182:     $stdout = old
// 183:   end
// 184: end
