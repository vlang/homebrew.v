module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/output_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `vuln(id, severity: "HIGH", summary: nil, aliases: [], fixed: [])` at line 9.
pub fn ruby_output_spec_l9_d1_vuln(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('vuln', ...args)
}

// Ruby method `finding(name:, version:, tag: "v#{version}", repo_url: "https://github.com/x/#{name}", open: [], patched: [])` at line 17.
pub fn ruby_output_spec_l17_d2_finding(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finding', ...args)
}

// Ruby method `results(findings, checked: findings.size, skipped: 0)` at line 21.
pub fn ruby_output_spec_l21_d3_results(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('results', ...args)
}

// Ruby method `render(res, **opts)` at line 26.
pub fn ruby_output_spec_l26_d4_render(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('render', ...args)
}

// Ruby it `it "prints a clean message when there are no findings" do` at line 32.
pub fn ruby_output_spec_l32_d5_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "distinguishes the clean message when only patched findings exist" do` at line 36.
pub fn ruby_output_spec_l36_d6_distinguishes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('distinguishes', ...args)
}

// Ruby it `it "prints formula, version, vuln id, severity and summary" do` at line 43.
pub fn ruby_output_spec_l43_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints fixed versions when present" do` at line 51.
pub fn ruby_output_spec_l51_d8_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "prints a totals line" do` at line 57.
pub fn ruby_output_spec_l57_d9_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "truncates summaries at max_summary" do` at line 63.
pub fn ruby_output_spec_l63_d10_truncates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('truncates', ...args)
}

// Ruby it `it "disables truncation when max_summary is 0" do` at line 70.
pub fn ruby_output_spec_l70_d11_disables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disables', ...args)
}

// Ruby it `it "omits the summary segment when the summary is nil" do` at line 77.
pub fn ruby_output_spec_l77_d12_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "strips terminal escape sequences from OSV-sourced fields" do` at line 84.
pub fn ruby_output_spec_l84_d13_strips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strips', ...args)
}

// Ruby it `it "prints a patched summary section" do` at line 102.
pub fn ruby_output_spec_l102_d14_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "sorts formulae by highest severity first, and vulns within each formula the same" do` at line 112.
pub fn ruby_output_spec_l112_d15_sorts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sorts', ...args)
}

// Ruby it `it "reports checked and skipped counts" do` at line 121.
pub fn ruby_output_spec_l121_d16_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `render(res)` at line 129.
pub fn ruby_output_spec_l129_d17_render(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('render', ...args)
}

// Ruby it `it "emits an empty array when there are no findings" do` at line 135.
pub fn ruby_output_spec_l135_d18_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits one object per finding with vulnerabilities and patched arrays" do` at line 139.
pub fn ruby_output_spec_l139_d19_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits an empty patched array when nothing is resolved" do` at line 164.
pub fn ruby_output_spec_l164_d20_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/output"
// 5: require "vulns/scanner"
// 6: require "vulns/vulnerability"
// 7:
// 8: RSpec.describe Homebrew::Vulns::Output do
// 9:   def vuln(id, severity: "HIGH", summary: nil, aliases: [], fixed: [])
// 10:     data = { "id" => id, "aliases" => aliases }
// 11:     data["summary"] = summary if summary
// 12:     data["database_specific"] = { "severity" => severity } if severity
// 13:     data["affected"] = [{ "ranges" => [{ "events" => fixed.map { |v| { "fixed" => v } } }] }] if fixed.any?
// 14:     Homebrew::Vulns::Vulnerability.new(data)
// 15:   end
// 16:
// 17:   def finding(name:, version:, tag: "v#{version}", repo_url: "https://github.com/x/#{name}", open: [], patched: [])
// 18:     Homebrew::Vulns::Scanner::Finding.new(name:, version:, tag:, repo_url:, open:, patched:)
// 19:   end
// 20:
// 21:   def results(findings, checked: findings.size, skipped: 0)
// 22:     Homebrew::Vulns::Scanner::Results.new(findings:, checked:, skipped:)
// 23:   end
// 24:
// 25:   describe ".text" do
// 26:     def render(res, **opts)
// 27:       out = +""
// 28:       described_class.text(res, io: StringIO.new(out), **opts)
// 29:       Tty.strip_ansi(out)
// 30:     end
// 31:
// 32:     it "prints a clean message when there are no findings" do
// 33:       expect(render(results([]))).to include "No vulnerabilities found."
// 34:     end
// 35:
// 36:     it "distinguishes the clean message when only patched findings exist" do
// 37:       f = finding(name: "libquicktime", version: "1.2.4", patched: [vuln("CVE-2016-2399")])
// 38:       out = render(results([f]))
// 39:       expect(out).to include "No open vulnerabilities found."
// 40:       expect(out).not_to include "No vulnerabilities found.\n"
// 41:     end
// 42:
// 43:     it "prints formula, version, vuln id, severity and summary" do
// 44:       f = finding(name: "vim", version: "9.1.2050",
// 45:                   open: [vuln("CVE-2024-1234", severity: "HIGH", summary: "Heap overflow")])
// 46:       out = render(results([f]))
// 47:       expect(out).to include "vim (9.1.2050)"
// 48:       expect(out).to include "CVE-2024-1234 (HIGH) - Heap overflow"
// 49:     end
// 50:
// 51:     it "prints fixed versions when present" do
// 52:       f = finding(name: "vim", version: "9.1.2050",
// 53:                   open: [vuln("CVE-2024-1234", fixed: ["v9.1.3000", "v10.0.0"])])
// 54:       expect(render(results([f]))).to include "Fixed in: v9.1.3000, v10.0.0"
// 55:     end
// 56:
// 57:     it "prints a totals line" do
// 58:       f = finding(name: "vim", version: "9.1.2050",
// 59:                   open: [vuln("CVE-2024-1111"), vuln("CVE-2024-2222")])
// 60:       expect(render(results([f]))).to include "Found 2 vulnerabilities in 1 package"
// 61:     end
// 62:
// 63:     it "truncates summaries at max_summary" do
// 64:       f = finding(name: "vim", version: "9.1", open: [vuln("CVE-1", summary: "A" * 100)])
// 65:       out = render(results([f]), max_summary: 60)
// 66:       expect(out).to include "#{"A" * 60}..."
// 67:       expect(out).not_to include "A" * 100
// 68:     end
// 69:
// 70:     it "disables truncation when max_summary is 0" do
// 71:       f = finding(name: "vim", version: "9.1", open: [vuln("CVE-1", summary: "A" * 100)])
// 72:       out = render(results([f]), max_summary: 0)
// 73:       expect(out).to include "A" * 100
// 74:       expect(out).not_to include "A..."
// 75:     end
// 76:
// 77:     it "omits the summary segment when the summary is nil" do
// 78:       f = finding(name: "vim", version: "9.1", open: [vuln("CVE-2024-1234", severity: nil)])
// 79:       out = render(results([f]))
// 80:       expect(out).to include "CVE-2024-1234 (UNKNOWN)"
// 81:       expect(out).not_to match(/CVE-2024-1234 \(UNKNOWN\) - $/)
// 82:     end
// 83:
// 84:     it "strips terminal escape sequences from OSV-sourced fields" do
// 85:       summary = "safe \e[2J\e[31mred\e[0m \e]0;pwned\a c1 \u{009b}2Jblue\u{009d}0;owned\a \rhidden\b text"
// 86:       f = finding(name: "vim", version: "9.1",
// 87:                   open: [vuln("CVE-2024-1234\e[2J", summary:, fixed: ["1.2.3\e[31m"])])
// 88:       out = +""
// 89:       described_class.text(results([f]), io: StringIO.new(out), max_summary: 0)
// 90:       expect(out).to include "safe red  c1 blue hidden text"
// 91:       expect(out).to include "CVE-2024-1234 ("
// 92:       expect(out).to include "Fixed in: 1.2.3"
// 93:       expect(out).not_to include "\e[2J"
// 94:       expect(out).not_to include "\u{009b}"
// 95:       expect(out).not_to include "\u{009d}"
// 96:       expect(out).not_to include "\r"
// 97:       expect(out).not_to include "\b"
// 98:       expect(out).not_to include "pwned"
// 99:       expect(out).not_to include "owned"
// 100:     end
// 101:
// 102:     it "prints a patched summary section" do
// 103:       f = finding(name: "libquicktime", version: "1.2.4",
// 104:                   open:    [vuln("CVE-2024-9999", severity: "CRITICAL")],
// 105:                   patched: [vuln("CVE-2016-2399"), vuln("GHSA-aaaa-bbbb-cccc")])
// 106:       out = render(results([f]))
// 107:       expect(out).to include "Found 1 vulnerability in 1 package"
// 108:       expect(out).to include "2 resolved by formula patches"
// 109:       expect(out).to include "libquicktime: CVE-2016-2399, GHSA-aaaa-bbbb-cccc"
// 110:     end
// 111:
// 112:     it "sorts formulae by highest severity first, and vulns within each formula the same" do
// 113:       low = finding(name: "aa", version: "1", open: [vuln("CVE-LOW", severity: "LOW")])
// 114:       crit = finding(name: "zz", version: "1",
// 115:                      open: [vuln("CVE-MED", severity: "MEDIUM"), vuln("CVE-CRIT", severity: "CRITICAL")])
// 116:       out = render(results([low, crit]))
// 117:       expect(out.index("zz (1)")).to be < out.index("aa (1)")
// 118:       expect(out.index("CVE-CRIT")).to be < out.index("CVE-MED")
// 119:     end
// 120:
// 121:     it "reports checked and skipped counts" do
// 122:       out = render(results([], checked: 5, skipped: 2))
// 123:       expect(out).to include "Checking 5 packages for vulnerabilities"
// 124:       expect(out).to include "(2 packages skipped - no supported source URL)"
// 125:     end
// 126:   end
// 127:
// 128:   describe ".json" do
// 129:     def render(res)
// 130:       out = +""
// 131:       described_class.json(res, io: StringIO.new(out))
// 132:       JSON.parse(out)
// 133:     end
// 134:
// 135:     it "emits an empty array when there are no findings" do
// 136:       expect(render(results([]))).to eq []
// 137:     end
// 138:
// 139:     it "emits one object per finding with vulnerabilities and patched arrays" do
// 140:       f = finding(name: "vim", version: "9.1.2050", tag: "v9.1.2050",
// 141:                   repo_url: "https://github.com/vim/vim",
// 142:                   open:     [vuln("CVE-2024-1234", severity: "HIGH", summary: "Heap overflow",
// 143:                                   aliases: ["GHSA-x"], fixed: ["v10.0.0"])],
// 144:                   patched:  [vuln("CVE-2016-2399")])
// 145:       data = render(results([f]))
// 146:       expect(data).to eq [
// 147:         {
// 148:           "formula"         => "vim",
// 149:           "version"         => "9.1.2050",
// 150:           "tag"             => "v9.1.2050",
// 151:           "repo_url"        => "https://github.com/vim/vim",
// 152:           "vulnerabilities" => [
// 153:             { "id" => "CVE-2024-1234", "severity" => "HIGH", "summary" => "Heap overflow",
// 154:               "aliases" => ["GHSA-x"], "fixed_versions" => ["v10.0.0"] },
// 155:           ],
// 156:           "patched"         => [
// 157:             { "id" => "CVE-2016-2399", "severity" => "HIGH", "summary" => nil,
// 158:               "aliases" => [], "fixed_versions" => [] },
// 159:           ],
// 160:         },
// 161:       ]
// 162:     end
// 163:
// 164:     it "emits an empty patched array when nothing is resolved" do
// 165:       f = finding(name: "vim", version: "9.1", open: [vuln("CVE-2024-1234")])
// 166:       expect(render(results([f])).first["patched"]).to eq []
// 167:     end
// 168:   end
// 169: end
