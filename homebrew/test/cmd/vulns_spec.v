module cmd

import brew_runtime
import homebrew.cmd as production_cmd
import os

// Translated from Homebrew/brew `test/cmd/vulns_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn vulns_spec_formula(name string) production_cmd.VulnsFormula {
	return production_cmd.VulnsFormula{
		formula: production_cmd.VulnsScannerFormula{
			name: name
			full_name: name
			stable_url: 'https://github.com/nektos/${name}/archive/refs/tags/v0.2.84.tar.gz'
			stable_tag: 'v0.2.84'
			stable_version: '0.2.84'
			version: '0.2.84'
		}
	}
}

fn vulns_spec_empty_scanner(formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	return production_cmd.VulnsScannerResults{
		checked: formulae.len
	}
}

fn vulns_spec_open_scanner(formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	return production_cmd.VulnsScannerResults{
		findings: [production_cmd.VulnsFinding{
			name: 'act'
			version: '0.2.84'
			tag: 'v0.2.84'
			repo_url: 'https://github.com/nektos/act'
			open: [production_cmd.VulnsVulnerability{
				id: 'CVE-2024-1234'
			}]
		}]
		checked: formulae.len
	}
}

fn vulns_spec_patched_scanner(formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	return production_cmd.VulnsScannerResults{
		findings: [production_cmd.VulnsFinding{
			name: 'act'
			version: '0.2.84'
			tag: 'v0.2.84'
			repo_url: 'https://github.com/nektos/act'
			patched: [production_cmd.VulnsVulnerability{
				id: 'CVE-2016-2399'
			}]
		}]
		checked: formulae.len
	}
}

fn vulns_spec_outdated_scanner(formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	return production_cmd.VulnsScannerResults{
		checked: formulae.len
		outdated_without_sbom: ['openssl@3']
	}
}

fn vulns_spec_severity_scanner(_formulae []production_cmd.VulnsScannerFormula,
	options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	if options.min_severity != .high {
		return error('expected high minimum severity')
	}
	return production_cmd.VulnsScannerResults{}
}

fn vulns_spec_patches_scanner(_formulae []production_cmd.VulnsScannerFormula,
	options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	if options.ignore_patches {
		return error('expected formula patches to be included')
	}
	return production_cmd.VulnsScannerResults{}
}

fn vulns_spec_only_fixed_scanner(_formulae []production_cmd.VulnsScannerFormula,
	options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	if !options.only_fixed || options.except_fixed {
		return error('expected only vulnerabilities with fixes')
	}
	return production_cmd.VulnsScannerResults{}
}

fn vulns_spec_except_fixed_scanner(_formulae []production_cmd.VulnsScannerFormula,
	options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	if options.only_fixed || !options.except_fixed {
		return error('expected vulnerabilities without fixes')
	}
	return production_cmd.VulnsScannerResults{}
}

fn vulns_spec_unexpected_scanner(_formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	return error('scanner was constructed before option validation')
}

fn vulns_spec_trusted_only_scanner(formulae []production_cmd.VulnsScannerFormula,
	_options production_cmd.VulnsScannerOptions) !production_cmd.VulnsScannerResults {
	if formulae.map(it.full_name) != ['act'] {
		return error('untrusted formula was passed to the scanner')
	}
	return production_cmd.VulnsScannerResults{
		checked: formulae.len
	}
}

fn vulns_spec_named_command(options production_cmd.VulnsCommandOptions,
	scanner production_cmd.VulnsScannerRunner) production_cmd.VulnsCommand {
	return production_cmd.VulnsCommand{
		options: options
		named: [vulns_spec_formula('act')]
		scanner: scanner
	}
}

fn vulns_spec_untrusted_command(scanner production_cmd.VulnsScannerRunner) production_cmd.VulnsCommand {
	return production_cmd.VulnsCommand{
		options: production_cmd.VulnsCommandOptions{
			json: true
		}
		installed_racks: [
			production_cmd.VulnsInstalledRack{
				path: '/homebrew/Cellar/act'
				formula: vulns_spec_formula('act')
			},
			production_cmd.VulnsInstalledRack{
				path: '/homebrew/Cellar/foo'
				error: 'Refusing to load formula someone/tap/foo from untrusted tap someone/tap.'
				untrusted: true
			},
		]
		scanner: scanner
	}
}

fn vulns_spec_run(options production_cmd.VulnsCommandOptions,
	scanner production_cmd.VulnsScannerRunner) !production_cmd.VulnsCommandResult {
	mut command := vulns_spec_named_command(options, scanner)
	return production_cmd.run_vulns_command(mut command)
}

// Ruby let `let(:installed) { instance_double(Formula, full_name: "curl", recursive_dependencies: []) }` at line 12.
pub fn ruby_vulns_spec_l12_d1_installed(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_cmd.vulns_formula_value(vulns_spec_formula('curl'))
}

// Ruby it `it "scans installed formulae when no arguments are given, never Formula.all" do` at line 14.
pub fn ruby_vulns_spec_l14_d2_scans(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := production_cmd.VulnsCommand{
		installed_racks: [production_cmd.VulnsInstalledRack{
			path: '/homebrew/Cellar/curl'
			formula: vulns_spec_formula('curl')
		}]
	}
	formulae := production_cmd.vulns_formulae(mut command)
	return brew_runtime.bool_value(formulae.map(it.full_name) == ['curl'])
}

// Ruby it `it "scans named formulae" do` at line 22.
pub fn ruby_vulns_spec_l22_d3_scans(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := production_cmd.VulnsCommand{
		named: [vulns_spec_formula('act')]
	}
	formulae := production_cmd.vulns_formulae(mut command)
	return brew_runtime.bool_value(formulae.map(it.full_name) == ['act'])
}

// Ruby it `it "scans the union of --brewfile entries and named arguments" do` at line 28.
pub fn ruby_vulns_spec_l28_d4_scans(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := production_cmd.VulnsCommand{
		options: production_cmd.VulnsCommandOptions{
			brewfile: true
			brewfile_value: brew_runtime.bool_value(true)
		}
		named: [vulns_spec_formula('act')]
		brewfile_entries: [production_cmd.VulnsBrewfileEntry{
			entry_type: 'brew'
			formula: vulns_spec_formula('wget')
		}]
	}
	formulae := production_cmd.vulns_formulae(mut command)
	return brew_runtime.bool_value(formulae.map(it.full_name) == ['wget', 'act'])
}

// Ruby it `it "reads the default Brewfile when --brewfile is passed without a path" do` at line 42.
pub fn ruby_vulns_spec_l42_d5_reads(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	default_path := production_cmd.vulns_brewfile_path(brew_runtime.bool_value(true))
	explicit_path := production_cmd.vulns_brewfile_path(brew_runtime.string_value('Brewfile.dev'))
	explicit_path_value := explicit_path or { '' }
	mut command := production_cmd.VulnsCommand{
		options: production_cmd.VulnsCommandOptions{
			brewfile: true
			brewfile_value: brew_runtime.bool_value(true)
		}
		brewfile_entries: [production_cmd.VulnsBrewfileEntry{
			entry_type: 'brew'
			formula: vulns_spec_formula('act')
		}]
	}
	return brew_runtime.bool_value(default_path == none && explicit_path_value == 'Brewfile.dev'
		&& production_cmd.vulns_formulae(mut command).map(it.full_name) == ['act'])
}

// Ruby it `it "validates --severity before enumerating formulae" do` at line 56.
pub fn ruby_vulns_spec_l56_d6_validates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := production_cmd.VulnsCommand{
		options: production_cmd.VulnsCommandOptions{
			severity: 'urgent'
		}
		installed_racks: [production_cmd.VulnsInstalledRack{
			path: '/homebrew/Cellar/foo'
			error: 'untrusted rack should not be enumerated'
			untrusted: true
		}]
		scanner: vulns_spec_unexpected_scanner
	}
	production_cmd.run_vulns_command(mut command) or {
		return brew_runtime.bool_value(err.msg().contains('`--severity` must be one of')
			&& command.untrusted_skipped.len == 0)
	}
	return brew_runtime.bool_value(false)
}

// Ruby method `stub_scan(findings)` at line 63.
pub fn ruby_vulns_spec_l63_d7_stub_scan(args ...brew_runtime.Value) brew_runtime.Value {
	ids := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	results := production_cmd.VulnsScannerResults{
		findings: ids.map(production_cmd.VulnsFinding{
			name: 'act'
			open: [production_cmd.VulnsVulnerability{
				id: it
			}]
		})
		checked: 1
	}
	return brew_runtime.Value{
		type_name: 'Homebrew::Vulns::Scanner::Results'
		attributes: {
			'checked': results.checked.str()
			'skipped': results.skipped.str()
		}
		map_data: {
			'findings': brew_runtime.string_array_value(results.findings.map(it.open[0].id))
		}
	}
}

// Ruby let `let(:act) do` at line 68.
pub fn ruby_vulns_spec_l68_d8_act(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_cmd.vulns_formula_value(vulns_spec_formula('act'))
}

// Ruby it `it "rejects an unknown --severity value" do` at line 79.
pub fn ruby_vulns_spec_l79_d9_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		severity: 'urgent'
	}, vulns_spec_unexpected_scanner) or {
		return brew_runtime.bool_value(err.msg().contains('`--severity` must be one of'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "rejects a non-numeric --max-summary value" do` at line 84.
pub fn ruby_vulns_spec_l84_d10_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		max_summary: 'lots'
	}, vulns_spec_unexpected_scanner) or {
		return brew_runtime.bool_value(err.msg().contains('`--max-summary` must be a non-negative integer'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "rejects a negative --max-summary value" do` at line 89.
pub fn ruby_vulns_spec_l89_d11_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		max_summary: '-5'
	}, vulns_spec_unexpected_scanner) or {
		return brew_runtime.bool_value(err.msg().contains('`--max-summary` must be a non-negative integer'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "validates options before constructing the scanner" do` at line 94.
pub fn ruby_vulns_spec_l94_d12_validates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut max_summary_rejected := false
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		max_summary: 'bad'
		json: true
	}, vulns_spec_unexpected_scanner) or {
		max_summary_rejected = err.msg().contains('`--max-summary`')
	}
	mut severity_rejected := false
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		severity: 'urgent'
	}, vulns_spec_unexpected_scanner) or {
		severity_rejected = err.msg().contains('`--severity`')
	}
	return brew_runtime.bool_value(max_summary_rejected && severity_rejected)
}

// Ruby it `it "prints text output and does not set Homebrew.failed when nothing is found" do` at line 100.
pub fn ruby_vulns_spec_l100_d13_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{}, vulns_spec_empty_scanner) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.stdout.contains('No vulnerabilities found')
		&& !result.failed)
}

// Ruby it `it "sets Homebrew.failed when open vulnerabilities are found" do` at line 106.
pub fn ruby_vulns_spec_l106_d14_sets(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{}, vulns_spec_open_scanner) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.stdout.contains('CVE-2024-1234') && result.failed)
}

// Ruby it `it "does not set Homebrew.failed when only patched vulnerabilities exist" do` at line 115.
pub fn ruby_vulns_spec_l115_d15_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{}, vulns_spec_patched_scanner) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.stdout.contains('No open vulnerabilities found')
		&& !result.failed)
}

// Ruby it `it "emits JSON with --json" do` at line 124.
pub fn ruby_vulns_spec_l124_d16_emits(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		json: true
	}, vulns_spec_empty_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '[]\n')
}

// Ruby it `it "warns to stderr and fails when installed versions could not be checked, even with --json" do` at line 129.
pub fn ruby_vulns_spec_l129_d17_warns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		json: true
	}, vulns_spec_outdated_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.stdout == '[]\n' && result.stderr.contains('openssl@3')
		&& result.stderr.contains('could not be determined') && result.stderr.contains('brew upgrade')
		&& result.failed)
}

// Ruby it `it "passes --severity to the scanner" do` at line 141.
pub fn ruby_vulns_spec_l141_d18_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		severity: 'high'
		json: true
	}, vulns_spec_severity_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.scanner_options.min_severity == .high)
}

// Ruby it `it "passes --no-ignore-patches to the scanner" do` at line 151.
pub fn ruby_vulns_spec_l151_d19_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		no_ignore_patches: true
		json: true
	}, vulns_spec_patches_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.scanner_options.ignore_patches)
}

// Ruby it `it "passes --fix-available to the scanner" do` at line 161.
pub fn ruby_vulns_spec_l161_d20_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		fix_available: true
		json: true
	}, vulns_spec_only_fixed_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.scanner_options.only_fixed)
}

// Ruby it `it "passes --no-fix-available to the scanner" do` at line 171.
pub fn ruby_vulns_spec_l171_d21_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := vulns_spec_run(production_cmd.VulnsCommandOptions{
		no_fix_available: true
		json: true
	}, vulns_spec_except_fixed_scanner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.scanner_options.except_fixed)
}

// Ruby it `it "rejects passing both --fix-available and --no-fix-available" do` at line 181.
pub fn ruby_vulns_spec_l181_d22_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	vulns_spec_run(production_cmd.VulnsCommandOptions{
		fix_available: true
		no_fix_available: true
	}, vulns_spec_unexpected_scanner) or {
		return brew_runtime.bool_value(err.msg().contains('mutually exclusive'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:trusted_rack) { HOMEBREW_CELLAR/"act" }` at line 190.
pub fn ruby_vulns_spec_l190_d23_trusted_rack(args ...brew_runtime.Value) brew_runtime.Value {
	cellar := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew/Cellar'
	}
	return brew_runtime.string_value(os.join_path(cellar, 'act'))
}

// Ruby let `let(:untrusted_rack) { HOMEBREW_CELLAR/"foo" }` at line 191.
pub fn ruby_vulns_spec_l191_d24_untrusted_rack(args ...brew_runtime.Value) brew_runtime.Value {
	cellar := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew/Cellar'
	}
	return brew_runtime.string_value(os.join_path(cellar, 'foo'))
}

// Ruby it `it "does not pass the untrusted formula to the scanner" do` at line 204.
pub fn ruby_vulns_spec_l204_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := vulns_spec_untrusted_command(vulns_spec_trusted_only_scanner)
	result := production_cmd.run_vulns_command(mut command) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.formulae.map(it.full_name) == ['act']
		&& result.results.checked == 1)
}

// Ruby it `it "reports the skipped keg and fails" do` at line 209.
pub fn ruby_vulns_spec_l209_d26_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut command := vulns_spec_untrusted_command(vulns_spec_empty_scanner)
	result := production_cmd.run_vulns_command(mut command) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.stderr.contains('untrusted tap')
		&& result.stderr.contains('not scanned') && result.stderr.contains('someone/tap/foo')
		&& result.stderr.contains('brew trust') && result.failed)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/vulns"
// 5: require "vulns"
// 6: require "cmd/shared_examples/args_parse"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Vulns do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   describe "#formulae" do
// 12:     let(:installed) { instance_double(Formula, full_name: "curl", recursive_dependencies: []) }
// 13:
// 14:     it "scans installed formulae when no arguments are given, never Formula.all" do
// 15:       rack = HOMEBREW_CELLAR/"curl"
// 16:       allow(Formula).to receive(:racks).and_return([rack])
// 17:       allow(Formulary).to receive(:from_rack).with(rack).and_return(installed)
// 18:       expect(Formula).not_to receive(:all)
// 19:       expect(described_class.new([]).formulae).to eq [installed]
// 20:     end
// 21:
// 22:     it "scans named formulae" do
// 23:       named = instance_double(Formula, full_name: "act", recursive_dependencies: [])
// 24:       allow_any_instance_of(Homebrew::CLI::NamedArgs).to receive(:to_resolved_formulae).and_return([named])
// 25:       expect(described_class.new(["act"]).formulae).to eq [named]
// 26:     end
// 27:
// 28:     it "scans the union of --brewfile entries and named arguments" do
// 29:       require "bundle/brewfile"
// 30:       entry = instance_double(Homebrew::Bundle::Dsl::Entry, type: :brew, name: "wget")
// 31:       dsl = instance_double(Homebrew::Bundle::Dsl, entries: [entry])
// 32:       from_brewfile = instance_double(Formula, full_name: "wget", recursive_dependencies: [])
// 33:       named = instance_double(Formula, full_name: "act", recursive_dependencies: [])
// 34:       allow(Homebrew::Bundle::Brewfile).to receive(:read).with(file: nil).and_return(dsl)
// 35:       allow(Formulary).to receive(:resolve).with("wget").and_return(from_brewfile)
// 36:       allow_any_instance_of(Homebrew::CLI::NamedArgs).to receive(:to_resolved_formulae).and_return([named])
// 37:
// 38:       expect(described_class.new(["act", "--brewfile"]).formulae).to contain_exactly(from_brewfile, named)
// 39:     end
// 40:   end
// 41:
// 42:   it "reads the default Brewfile when --brewfile is passed without a path" do
// 43:     require "bundle/brewfile"
// 44:     entry = instance_double(Homebrew::Bundle::Dsl::Entry, type: :brew, name: "act")
// 45:     dsl = instance_double(Homebrew::Bundle::Dsl, entries: [entry])
// 46:     formula = instance_double(Formula, full_name: "act")
// 47:     allow(Formulary).to receive(:resolve).with("act").and_return(formula)
// 48:
// 49:     expect(Homebrew::Bundle::Brewfile).to receive(:read).with(file: nil).and_return(dsl)
// 50:     expect(described_class.new(["--brewfile"]).formulae).to eq [formula]
// 51:
// 52:     expect(Homebrew::Bundle::Brewfile).to receive(:read).with(file: "Brewfile.dev").and_return(dsl)
// 53:     expect(described_class.new(["--brewfile=Brewfile.dev"]).formulae).to eq [formula]
// 54:   end
// 55:
// 56:   it "validates --severity before enumerating formulae" do
// 57:     cmd = described_class.new(["--severity=urgent"])
// 58:     expect(cmd).not_to receive(:formulae)
// 59:     expect { cmd.run }.to raise_error(UsageError)
// 60:   end
// 61:
// 62:   describe "#run" do
// 63:     def stub_scan(findings)
// 64:       results = Homebrew::Vulns::Scanner::Results.new(findings:, checked: 1, skipped: 0)
// 65:       allow_any_instance_of(Homebrew::Vulns::Scanner).to receive(:scan).and_return(results)
// 66:     end
// 67:
// 68:     let(:act) do
// 69:       formula("act") do
// 70:         T.bind(self, T.class_of(Formula))
// 71:         url "https://github.com/nektos/act/archive/refs/tags/v0.2.84.tar.gz"
// 72:       end
// 73:     end
// 74:
// 75:     before do
// 76:       allow_any_instance_of(described_class).to receive(:formulae).and_return([act])
// 77:     end
// 78:
// 79:     it "rejects an unknown --severity value" do
// 80:       expect { described_class.new(["--severity=urgent"]).run }
// 81:         .to raise_error(UsageError, /`--severity` must be one of/)
// 82:     end
// 83:
// 84:     it "rejects a non-numeric --max-summary value" do
// 85:       expect { described_class.new(["--max-summary=lots"]).run }
// 86:         .to raise_error(UsageError, /`--max-summary` must be a non-negative integer/)
// 87:     end
// 88:
// 89:     it "rejects a negative --max-summary value" do
// 90:       expect { described_class.new(["--max-summary=-5"]).run }
// 91:         .to raise_error(UsageError, /`--max-summary` must be a non-negative integer/)
// 92:     end
// 93:
// 94:     it "validates options before constructing the scanner" do
// 95:       expect(Homebrew::Vulns::Scanner).not_to receive(:new)
// 96:       expect { described_class.new(["--max-summary=bad", "--json"]).run }.to raise_error(UsageError)
// 97:       expect { described_class.new(["--severity=urgent"]).run }.to raise_error(UsageError)
// 98:     end
// 99:
// 100:     it "prints text output and does not set Homebrew.failed when nothing is found" do
// 101:       stub_scan([])
// 102:       expect { described_class.new([]).run }.to output(/No vulnerabilities found/).to_stdout
// 103:       expect(Homebrew.failed?).to be false
// 104:     end
// 105:
// 106:     it "sets Homebrew.failed when open vulnerabilities are found" do
// 107:       stub_scan([Homebrew::Vulns::Scanner::Finding.new(
// 108:         name: "act", version: "0.2.84", tag: "v0.2.84", repo_url: "https://github.com/nektos/act",
// 109:         open: [Homebrew::Vulns::Vulnerability.new("id" => "CVE-2024-1234")], patched: []
// 110:       )])
// 111:       expect { described_class.new([]).run }.to output(/CVE-2024-1234/).to_stdout
// 112:       expect(Homebrew.failed?).to be true
// 113:     end
// 114:
// 115:     it "does not set Homebrew.failed when only patched vulnerabilities exist" do
// 116:       stub_scan([Homebrew::Vulns::Scanner::Finding.new(
// 117:         name: "act", version: "0.2.84", tag: "v0.2.84", repo_url: "https://github.com/nektos/act",
// 118:         open: [], patched: [Homebrew::Vulns::Vulnerability.new("id" => "CVE-2016-2399")]
// 119:       )])
// 120:       expect { described_class.new([]).run }.to output(/No open vulnerabilities found/).to_stdout
// 121:       expect(Homebrew.failed?).to be false
// 122:     end
// 123:
// 124:     it "emits JSON with --json" do
// 125:       stub_scan([])
// 126:       expect { described_class.new(["--json"]).run }.to output("[]\n").to_stdout
// 127:     end
// 128:
// 129:     it "warns to stderr and fails when installed versions could not be checked, even with --json" do
// 130:       results = Homebrew::Vulns::Scanner::Results.new(
// 131:         findings: [], checked: 1, skipped: 0, outdated_without_sbom: ["openssl@3"],
// 132:       )
// 133:       allow_any_instance_of(Homebrew::Vulns::Scanner).to receive(:scan).and_return(results)
// 134:
// 135:       expect { described_class.new(["--json"]).run }
// 136:         .to output("[]\n").to_stdout
// 137:         .and output(/openssl@3.*could not be determined.*brew upgrade/m).to_stderr
// 138:       expect(Homebrew.failed?).to be true
// 139:     end
// 140:
// 141:     it "passes --severity to the scanner" do
// 142:       expect(Homebrew::Vulns::Scanner).to receive(:new)
// 143:         .with(anything, hash_including(min_severity: :high))
// 144:         .and_return(
// 145:           instance_double(Homebrew::Vulns::Scanner,
// 146:                           scan: Homebrew::Vulns::Scanner::Results.new(findings: [], checked: 0, skipped: 0)),
// 147:         )
// 148:       described_class.new(["--severity=high", "--json"]).run
// 149:     end
// 150:
// 151:     it "passes --no-ignore-patches to the scanner" do
// 152:       expect(Homebrew::Vulns::Scanner).to receive(:new)
// 153:         .with(anything, hash_including(ignore_patches: false))
// 154:         .and_return(
// 155:           instance_double(Homebrew::Vulns::Scanner,
// 156:                           scan: Homebrew::Vulns::Scanner::Results.new(findings: [], checked: 0, skipped: 0)),
// 157:         )
// 158:       described_class.new(["--no-ignore-patches", "--json"]).run
// 159:     end
// 160:
// 161:     it "passes --fix-available to the scanner" do
// 162:       expect(Homebrew::Vulns::Scanner).to receive(:new)
// 163:         .with(anything, hash_including(only_fixed: true))
// 164:         .and_return(
// 165:           instance_double(Homebrew::Vulns::Scanner,
// 166:                           scan: Homebrew::Vulns::Scanner::Results.new(findings: [], checked: 0, skipped: 0)),
// 167:         )
// 168:       described_class.new(["--fix-available", "--json"]).run
// 169:     end
// 170:
// 171:     it "passes --no-fix-available to the scanner" do
// 172:       expect(Homebrew::Vulns::Scanner).to receive(:new)
// 173:         .with(anything, hash_including(except_fixed: true))
// 174:         .and_return(
// 175:           instance_double(Homebrew::Vulns::Scanner,
// 176:                           scan: Homebrew::Vulns::Scanner::Results.new(findings: [], checked: 0, skipped: 0)),
// 177:         )
// 178:       described_class.new(["--no-fix-available", "--json"]).run
// 179:     end
// 180:
// 181:     it "rejects passing both --fix-available and --no-fix-available" do
// 182:       expect { described_class.new(["--fix-available", "--no-fix-available"]).run }
// 183:         .to raise_error(
// 184:           UsageError,
// 185:           /mutually exclusive/,
// 186:         )
// 187:     end
// 188:
// 189:     context "with an installed keg from an untrusted tap" do
// 190:       let(:trusted_rack) { HOMEBREW_CELLAR/"act" }
// 191:       let(:untrusted_rack) { HOMEBREW_CELLAR/"foo" }
// 192:
// 193:       before do
// 194:         allow_any_instance_of(described_class).to receive(:formulae).and_call_original
// 195:         allow(Formula).to receive(:racks).and_return([trusted_rack, untrusted_rack])
// 196:         allow(Formulary).to receive(:from_rack).with(trusted_rack).and_return(act)
// 197:         allow(Formulary).to receive(:from_rack).with(untrusted_rack).and_raise(
// 198:           Homebrew::UntrustedTapError,
// 199:           "Refusing to load formula someone/tap/foo from untrusted tap someone/tap.",
// 200:         )
// 201:         stub_scan([])
// 202:       end
// 203:
// 204:       it "does not pass the untrusted formula to the scanner" do
// 205:         expect(Homebrew::Vulns::Scanner).to receive(:new).with([act], anything).and_call_original
// 206:         described_class.new(["--json"]).run
// 207:       end
// 208:
// 209:       it "reports the skipped keg and fails" do
// 210:         expect { described_class.new(["--json"]).run }
// 211:           .to output(%r{untrusted tap.*not scanned.*someone/tap/foo.*brew trust}m).to_stderr
// 212:         expect(Homebrew.failed?).to be true
// 213:       end
// 214:     end
// 215:   end
// 216: end
