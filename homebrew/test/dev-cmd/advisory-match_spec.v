module dev_cmd

import homebrew.vulns
import os
import time
import x.json2

// Translated from Homebrew/brew `test/dev-cmd/advisory-match_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AdvisoryMatchSpecCommand {
pub:
	args     AdvisoryMatchArgs
	formulae []vulns.MatchFormula
}

fn advisory_match_spec_root(line int) string {
	return os.join_path(os.temp_dir(), 'brew-v-advisory-match-${os.getpid()}-${line}-${time.now().unix_micro()}')
}

fn advisory_match_spec_empty_repology() !vulns.RepologyDatabase {
	return vulns.new_repology_database(json2.Any({
		'meta':     json2.Any(map[string]json2.Any{})
		'formulae': json2.Any(map[string]json2.Any{})
	}))
}

fn advisory_match_spec_empty_cpansa() !vulns.CpanSecDatabase {
	return vulns.new_cpan_sec_database(json2.Any({
		'meta':  json2.Any(map[string]json2.Any{})
		'dists': json2.Any(map[string]json2.Any{})
	}))
}

fn advisory_match_spec_matcher() !vulns.MatchMatcher {
	return vulns.new_matcher(advisory_match_spec_empty_repology()!, advisory_match_spec_empty_cpansa()!, false)
}

fn advisory_match_spec_loader(name string) !vulns.MatchFormula {
	if name == 'requests' {
		return ruby_advisory_match_spec_l8_d1_requests()
	}
	return error('boom')
}

fn advisory_match_spec_query(packages []vulns.OsvPackage) ![][]vulns.OsvVulnerability {
	return packages.map([vulns.OsvVulnerability{
		id: 'CVE-2024-1234'
	}])
}

fn advisory_match_spec_query_outage(_ []vulns.OsvPackage) ![][]vulns.OsvVulnerability {
	return error('503')
}

fn advisory_match_spec_vulnerability(fixed string,
	introduced string) vulns.MatchVulnerability {
	return vulns.MatchVulnerability{
		id: 'CVE-2024-1234'
		summary: 's'
		affected: [vulns.AdvisoryAffected{
			package: vulns.AdvisoryPackage{
				ecosystem: 'GIT'
				name: 'https://github.com/psf/requests'
			}
			ranges: [vulns.AdvisoryRange{
				range_type: 'ECOSYSTEM'
				events: [vulns.AdvisoryEvent{
					introduced: introduced
				}, vulns.AdvisoryEvent{
					fixed: fixed
				}]
			}]
		}]
	}
}

fn advisory_match_spec_fetch(id string) ?vulns.MatchVulnerability {
	if id == 'CVE-2024-1234' {
		return advisory_match_spec_vulnerability('2.28.1', '0')
	}
	return none
}

fn advisory_match_spec_fetch_not_applicable(id string) ?vulns.MatchVulnerability {
	if id == 'CVE-2024-1234' {
		return advisory_match_spec_vulnerability('3.0.4', '3.0.0')
	}
	return none
}

fn advisory_match_spec_run(argv []string, core_formula_names []string,
	query vulns.MatchQueryBatch, fetch vulns.MatchVulnerabilityFetch) !AdvisoryRunResult {
	command := ruby_advisory_match_spec_l29_d2_cmd_for(argv, [
		ruby_advisory_match_spec_l8_d1_requests(),
	])!
	return run_advisory_match(AdvisoryRunInput{
		args: command.args
		named_formulae: command.formulae
		core_formula_names: core_formula_names
		matcher: advisory_match_spec_matcher()!
		query_batch: query
		fetch: fetch
		formula_loader: advisory_match_spec_loader
		now: '2026-08-31T00:00:00Z'
	})
}

fn advisory_match_spec_database_string(record vulns.MatchBrewRecord, key string) string {
	value := record.database_specific[key] or { return '' }
	if value is string {
		return value
	}
	return ''
}

// Ruby let `let(:requests) do` at line 8.
pub fn ruby_advisory_match_spec_l8_d1_requests() vulns.MatchFormula {
	return vulns.MatchFormula{
		name: 'requests'
		pkg_version: '2.31.0'
		stable_url: 'https://files.pythonhosted.org/packages/aa/bb/cc/requests-2.31.0.tar.gz'
		head_url: 'https://github.com/psf/requests.git'
	}
}

// Ruby method `cmd_for(*argv, formulae: [requests])` at line 29.
pub fn ruby_advisory_match_spec_l29_d2_cmd_for(argv []string,
	formulae []vulns.MatchFormula) !AdvisoryMatchSpecCommand {
	return AdvisoryMatchSpecCommand{
		args: parse_advisory_match_args(argv)!
		formulae: formulae.clone()
	}
}

// Ruby method `stub_osv_hit(cve, fixed:)` at line 35.
pub fn ruby_advisory_match_spec_l35_d3_stub_osv_hit(cve string,
	fixed string) !vulns.MatchHit {
	formula := ruby_advisory_match_spec_l8_d1_requests()
	vulnerability := vulns.MatchVulnerability{
		...advisory_match_spec_vulnerability(fixed, '0')
		id: cve
	}
	return vulns.new_match_hit(vulnerability, [vulns.MatchEvidence{
		strategy: .git
		ecosystem: 'GIT'
		name: 'https://github.com/psf/requests'
		subject_version: formula.pkg_version
		key: 'https://github.com/psf/requests'
	}])
}

// Ruby it `it "writes matched records to --output=<dir> with merge_existing semantics" do` at line 47.
pub fn ruby_advisory_match_spec_l47_d4_writes() !bool {
	root := advisory_match_spec_root(47)
	defer {
		os.rmdir_all(root) or {}
	}
	first := advisory_match_spec_run(['requests', '--output', root, '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	path := os.join_path(root, 'BREW-requests-CVE-2024-1234.json')
	record := json2.decode[vulns.MatchBrewRecord](os.read_file(path)!)!
	if first.written != 1 || !first.stdout.contains('1 records written') || record.affected[0].package.ecosystem != 'Homebrew' || record.affected[0].package.name != 'requests' || record.affected[0].package.purl != 'pkg:brew/requests' || record.affected[0].ranges[0].events[1].fixed != '2.31.0' || advisory_match_spec_database_string(record, 'source') != 'matched' || advisory_match_spec_database_string(record, 'strategy') != 'git' {
		return false
	}
	second := advisory_match_spec_run(['requests', '--output', root, '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	return second.written == 0 && second.unchanged == 1 && second.stdout.contains('0 records written to ${root} (1 unchanged, 0 generated')
}

// Ruby it `it "drops :not_applicable hits instead of emitting them as open ranges" do` at line 69.
pub fn ruby_advisory_match_spec_l69_d5_drops() !bool {
	result := advisory_match_spec_run(['requests', '--json', '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch_not_applicable)!
	return result.stdout.trim_space() == '[]' && result.emitted == 0
}

// Ruby it `it "does not overwrite an existing source: generated record" do` at line 82.
pub fn ruby_advisory_match_spec_l82_d6_does() !bool {
	root := advisory_match_spec_root(82)
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	path := os.join_path(root, 'BREW-requests-CVE-2024-1234.json')
	os.write_file(path, '{"id":"BREW-requests-CVE-2024-1234","database_specific":{"source":"generated"},"affected":[{"ecosystem_specific":{"fix":"patch"}}]}')!
	result := advisory_match_spec_run(['requests', '--output', root, '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	contents := os.read_file(path)!
	return result.written == 0 && result.skipped_generated == 1 && result.stdout.contains('1 generated left as-is') && contents.contains('"fix":"patch"')
}

// Ruby it `it "emits records as JSON with --json" do` at line 97.
pub fn ruby_advisory_match_spec_l97_d7_emits() !bool {
	result := advisory_match_spec_run(['requests', '--json', '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	records := json2.decode[[]vulns.MatchBrewRecord](result.stdout)!
	return records.len == 1 && records[0].id == 'BREW-requests-CVE-2024-1234'
}

// Ruby it `it "prints a per-hit summary in text mode" do` at line 105.
pub fn ruby_advisory_match_spec_l105_d8_prints() !bool {
	result := advisory_match_spec_run(['requests', '--no-history'], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	return result.stdout.contains('requests 2.31.0') && result.stdout.contains('CVE-2024-1234 [git, high]') && result.stdout.contains('fixed (upstream 2.28.1)') && result.stdout.contains('1 candidate records')
}

// Ruby it `it "loads the Repology index from --repology=<file> instead of the published feed" do` at line 113.
pub fn ruby_advisory_match_spec_l113_d9_loads() !bool {
	root := advisory_match_spec_root(113)
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	path := os.join_path(root, 'repology.json')
	os.write_file(path, '{"meta":{},"formulae":{}}')!
	loaded := advisory_local_repology(path)!
	result := advisory_match_spec_run([
		'requests',
		'--json',
		'--no-history',
		'--repology',
		path,
	], [], advisory_match_spec_query, advisory_match_spec_fetch)!
	records := json2.decode[[]vulns.MatchBrewRecord](result.stdout)!
	return loaded.configured && loaded.database.formulae().len == 0 && records.len == 1 && records[0].id == 'BREW-requests-CVE-2024-1234'
}

// Ruby it `it "raises on an unreadable --repology file" do` at line 128.
pub fn ruby_advisory_match_spec_l128_d10_raises() bool {
	advisory_match_spec_run([
		'requests',
		'--json',
		'--repology',
		'/nonexistent/repology.json',
	], [], advisory_match_spec_query, advisory_match_spec_fetch) or {
		return err.msg().contains('/nonexistent/repology.json')
	}
	return false
}

// Ruby it `it "reports an OSV outage and finishes the emitter without raising" do` at line 133.
pub fn ruby_advisory_match_spec_l133_d11_reports() !bool {
	result := advisory_match_spec_run(['requests', '--json'], [], advisory_match_spec_query_outage, advisory_match_spec_fetch)!
	return result.stdout == '[]\n' && result.stderr.contains('OSV query failed: 503') && result.failed
}

// Ruby it `it "iterates every core formula with --all and streams to --output" do` at line 142.
pub fn ruby_advisory_match_spec_l142_d12_iterates() !bool {
	root := advisory_match_spec_root(142)
	defer {
		os.rmdir_all(root) or {}
	}
	result := advisory_match_spec_run(['--all', '--output', root, '--no-history'], [
		'requests',
		'broken',
	], advisory_match_spec_query, advisory_match_spec_fetch)!
	return result.written == 1 && result.stdout.contains('1 records written') && result.stderr.contains("Error loading formula 'broken': boom") && os.is_file(os.join_path(root, 'BREW-requests-CVE-2024-1234.json'))
}

// Ruby it `it "rejects --all with --json" do` at line 159.
pub fn ruby_advisory_match_spec_l159_d13_rejects() bool {
	parse_advisory_match_args(['--all', '--json']) or {
		return err.msg().contains('mutually exclusive')
	}
	return false
}

// Ruby it `it "emits the formula-identity index with --index" do` at line 163.
pub fn ruby_advisory_match_spec_l163_d14_emits() !bool {
	result := advisory_match_spec_run(['--index'], ['requests'], advisory_match_spec_query, advisory_match_spec_fetch)!
	data := json2.decode[json2.Any](result.stdout)!
	if data !is map[string]json2.Any {
		return false
	}
	requests := data.as_map()['requests'] or { return false }
	if requests !is map[string]json2.Any {
		return false
	}
	identity := requests.as_map()
	git_repo := identity['git_repo'] or { return false }
	primary := identity['primary_package'] or { return false }
	if git_repo !is string {
		return false
	}
	if primary !is map[string]json2.Any {
		return false
	}
	ecosystem := primary.as_map()['ecosystem'] or { return false }
	if ecosystem !is string {
		return false
	}
	return git_repo.str() == 'https://github.com/psf/requests' && ecosystem.str() == 'PyPI'
}

// Ruby method `capture_stdout` at line 175.
pub fn ruby_advisory_match_spec_l175_d15_capture_stdout(chunks []string) string {
	return if chunks.len == 0 { '' } else { '${chunks.join('\n')}\n' }
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
