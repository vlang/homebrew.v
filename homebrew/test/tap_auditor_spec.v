module test

import homebrew
import os
import time
import x.json2

// Translated from Homebrew/brew `test/tap_auditor_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn tap_auditor_spec_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-tap-auditor-${label}-${os.getpid()}-${time.now().unix_nano()}')
}

fn tap_auditor_spec_tap_at(path string, formulae []string, casks []string,
	formula_renames map[string]string, cask_renames map[string]string) homebrew.TapAuditorTap {
	return homebrew.TapAuditorTap{
		name: 'homebrew/foo'
		path: path
		official: true
		formula_names: formulae.map('homebrew/foo/${it}')
		cask_tokens: casks.map('homebrew/foo/${it}')
		formula_renames: formula_renames.clone()
		cask_renames: cask_renames.clone()
	}
}

fn tap_auditor_spec_problem(problems []homebrew.TapAuditProblem, needle string) ?homebrew.TapAuditProblem {
	for problem in problems {
		if problem.message.contains(needle) {
			return problem
		}
	}
	return none
}

fn tap_auditor_spec_run_cask_renames(label string, renames map[string]string,
	casks []string) ![]homebrew.TapAuditProblem {
	root := tap_auditor_spec_temp(label)
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	for cask in casks {
		ruby_tap_auditor_spec_l11_d4_write_cask(cask, os.join_path(root, 'Casks', '${cask}.rb'))!
	}
	os.write_file(os.join_path(root, 'cask_renames.json'), json2.encode(renames))!
	mut auditor := homebrew.new_tap_auditor(tap_auditor_spec_tap_at(root, []string{}, casks, map[string]string{}, renames), false)
	auditor.audit()
	return auditor.problems.clone()
}

fn tap_auditor_spec_run_formula_renames(label string, renames map[string]string,
	formulae []string) ![]homebrew.TapAuditProblem {
	root := tap_auditor_spec_temp(label)
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	for formula in formulae {
		ruby_tap_auditor_spec_l23_d5_write_formula(formula, os.join_path(root, 'Formula', '${formula}.rb'))!
	}
	os.write_file(os.join_path(root, 'formula_renames.json'), json2.encode(renames))!
	mut auditor := homebrew.new_tap_auditor(tap_auditor_spec_tap_at(root, formulae, []string{}, renames, map[string]string{}), false)
	auditor.audit()
	return auditor.problems.clone()
}

// Ruby let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 7.
pub fn ruby_tap_auditor_spec_l7_d1_tap() homebrew.TapAuditorTap {
	return tap_auditor_spec_tap_at(tap_auditor_spec_temp('tap'), []string{}, []string{}, map[string]string{}, map[string]string{})
}

// Ruby let `let(:tap_path) { tap.path }` at line 8.
pub fn ruby_tap_auditor_spec_l8_d2_tap_path(tap homebrew.TapAuditorTap) string {
	return tap.path
}

// Ruby let `let(:auditor) { described_class.new(tap, strict: false) }` at line 9.
pub fn ruby_tap_auditor_spec_l9_d3_auditor(tap homebrew.TapAuditorTap) homebrew.TapAuditor {
	return homebrew.new_tap_auditor(tap, false)
}

// Ruby method `write_cask(token, path = tap_path/"Casks"/"#{token}.rb")` at line 11.
pub fn ruby_tap_auditor_spec_l11_d4_write_cask(token string, path string) !string {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, 'cask "${token}" do\n  version "1.0"\n  url "https://brew.sh/${token}-1.0.dmg"\n  name "${token.capitalize()} Cask"\n  homepage "https://brew.sh"\nend\n')!
	return path
}

// Ruby method `write_formula(name, path = tap_path/"Formula"/"#{name}.rb")` at line 23.
pub fn ruby_tap_auditor_spec_l23_d5_write_formula(name string, path string) !string {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, 'class ${name.capitalize()} < Formula\n  url "https://brew.sh/${name}-1.0.tar.gz"\n  version "1.0"\nend\n')!
	return path
}

// Ruby subject `subject(:problems) do` at line 39.
pub fn ruby_tap_auditor_spec_l39_d6_problems(mut auditor homebrew.TapAuditor) []homebrew.TapAuditProblem {
	auditor.audit()
	return auditor.problems.clone()
}

// Ruby let `let(:cask_renames_path) { tap_path/"cask_renames.json" }` at line 45.
pub fn ruby_tap_auditor_spec_l45_d7_cask_renames_path(tap_path string) string {
	return os.join_path(tap_path, 'cask_renames.json')
}

// Ruby let `let(:renames_data) { {} }` at line 46.
pub fn ruby_tap_auditor_spec_l46_d8_renames_data() map[string]string {
	return map[string]string{}
}

// Ruby let `let(:renames_data) { { "oldcask.rb" => "newcask" } }` at line 53.
pub fn ruby_tap_auditor_spec_l53_d9_renames_data() map[string]string {
	return {
		'oldcask.rb': 'newcask'
	}
}

// Ruby it `it "detects the invalid format" do` at line 59.
pub fn ruby_tap_auditor_spec_l59_d10_detects() bool {
	problems := tap_auditor_spec_run_cask_renames('old-extension', ruby_tap_auditor_spec_l53_d9_renames_data(), [
		'newcask',
	]) or { return false }
	return problems.len == 1 && problems[0].message == 'cask_renames.json contains entries with \'.rb\' file extensions.\nRename entries should use formula/cask names only, without \'.rb\' extensions.\nInvalid entries: "oldcask.rb": "newcask"\n'
}

// Ruby let `let(:renames_data) { { "oldcask" => "newcask.rb" } }` at line 72.
pub fn ruby_tap_auditor_spec_l72_d11_renames_data() map[string]string {
	return {
		'oldcask': 'newcask.rb'
	}
}

// Ruby it `it "detects the invalid format" do` at line 78.
pub fn ruby_tap_auditor_spec_l78_d12_detects() bool {
	problems := tap_auditor_spec_run_cask_renames('new-extension', ruby_tap_auditor_spec_l72_d11_renames_data(), [
		'newcask',
	]) or { return false }
	format := tap_auditor_spec_problem(problems, "entries with '.rb' file extensions") or {
		return false
	}
	target := tap_auditor_spec_problem(problems, 'Invalid targets') or { return false }
	return problems.len == 2 && format.message == 'cask_renames.json contains entries with \'.rb\' file extensions.\nRename entries should use formula/cask names only, without \'.rb\' extensions.\nInvalid entries: "oldcask": "newcask.rb"\n' && target.message == 'cask_renames.json contains renames to casks that do not exist in the homebrew/foo tap.\nInvalid targets: newcask.rb\n'
}

// Ruby let `let(:renames_data) { { "oldcask" => "nonexistent" } }` at line 105.
pub fn ruby_tap_auditor_spec_l105_d13_renames_data() map[string]string {
	return {
		'oldcask': 'nonexistent'
	}
}

// Ruby it `it "detects the missing target" do` at line 107.
pub fn ruby_tap_auditor_spec_l107_d14_detects() bool {
	problems := tap_auditor_spec_run_cask_renames('missing-target', ruby_tap_auditor_spec_l105_d13_renames_data(), []string{}) or { return false }
	return problems.len == 1 && problems[0].message == 'cask_renames.json contains renames to casks that do not exist in the homebrew/foo tap.\nInvalid targets: nonexistent\n'
}

// Ruby let `let(:renames_data) do` at line 119.
pub fn ruby_tap_auditor_spec_l119_d15_renames_data() map[string]string {
	return {
		'oldcask': 'newcask'
		'newcask': 'finalcask'
	}
}

// Ruby it `it "detects the chained renames" do` at line 130.
pub fn ruby_tap_auditor_spec_l130_d16_detects() bool {
	problems := tap_auditor_spec_run_cask_renames('chained', ruby_tap_auditor_spec_l119_d15_renames_data(), [
		'finalcask',
	]) or { return false }
	return problems.len == 1 && problems[0].message == 'cask_renames.json contains chained renames that should be collapsed.\nChained renames don\'t work automatically; each old name should point directly to the final target:\n  "oldcask": "finalcask" (instead of chained rename)\n'
}

// Ruby let `let(:renames_data) do` at line 143.
pub fn ruby_tap_auditor_spec_l143_d17_renames_data() map[string]string {
	return {
		'oldcask':          'newcask'
		'newcask':          'intermediatecask'
		'intermediatecask': 'finalcask'
	}
}

// Ruby it `it "suggests final target" do` at line 156.
pub fn ruby_tap_auditor_spec_l156_d18_suggests() bool {
	problems := tap_auditor_spec_run_cask_renames('multi-level', ruby_tap_auditor_spec_l143_d17_renames_data(), [
		'intermediatecask',
		'finalcask',
	]) or {
		return false
	}
	chained := tap_auditor_spec_problem(problems, 'chained renames') or { return false }
	conflict := tap_auditor_spec_problem(problems, 'conflict') or { return false }
	return problems.len == 2 && chained.message == 'cask_renames.json contains chained renames that should be collapsed.\nChained renames don\'t work automatically; each old name should point directly to the final target:\n  "oldcask": "finalcask" (instead of chained rename)\n  "newcask": "finalcask" (instead of chained rename)\n' && conflict.message == 'cask_renames.json contains old names that conflict with existing casks in the homebrew/foo tap.\nRenames only work after the old casks are deleted. Conflicting names: intermediatecask\n'
}

// Ruby let `let(:renames_data) do` at line 180.
pub fn ruby_tap_auditor_spec_l180_d19_renames_data() map[string]string {
	return {
		'veryoldcask':      'intermediatecask'
		'intermediatecask': 'finalcask'
	}
}

// Ruby it `it "reports chained rename error, not invalid target error" do` at line 191.
pub fn ruby_tap_auditor_spec_l191_d20_reports() bool {
	problems := tap_auditor_spec_run_cask_renames('missing-intermediate', ruby_tap_auditor_spec_l180_d19_renames_data(), [
		'finalcask',
	]) or { return false }
	return problems.len == 1 && problems[0].message == 'cask_renames.json contains chained renames that should be collapsed.\nChained renames don\'t work automatically; each old name should point directly to the final target:\n  "veryoldcask": "finalcask" (instead of chained rename)\n'
}

// Ruby let `let(:renames_data) { { "newcask" => "anothercask" } }` at line 204.
pub fn ruby_tap_auditor_spec_l204_d21_renames_data() map[string]string {
	return {
		'newcask': 'anothercask'
	}
}

// Ruby it `it "detects the conflict" do` at line 211.
pub fn ruby_tap_auditor_spec_l211_d22_detects() bool {
	problems := tap_auditor_spec_run_cask_renames('conflict', ruby_tap_auditor_spec_l204_d21_renames_data(), [
		'newcask',
		'anothercask',
	]) or {
		return false
	}
	return problems.len == 1 && problems[0].message == 'cask_renames.json contains old names that conflict with existing casks in the homebrew/foo tap.\nRenames only work after the old casks are deleted. Conflicting names: newcask\n'
}

// Ruby let `let(:renames_data) { { "oldcask" => "newcask" } }` at line 223.
pub fn ruby_tap_auditor_spec_l223_d23_renames_data() map[string]string {
	return {
		'oldcask': 'newcask'
	}
}

// Ruby it `it "passes validation" do` at line 229.
pub fn ruby_tap_auditor_spec_l229_d24_passes() bool {
	problems := tap_auditor_spec_run_cask_renames('valid', ruby_tap_auditor_spec_l223_d23_renames_data(), [
		'newcask',
	]) or { return false }
	return problems.filter(it.message.contains('cask_renames')).len == 0
}

// Ruby let `let(:formula_renames_path) { tap_path/"formula_renames.json" }` at line 237.
pub fn ruby_tap_auditor_spec_l237_d25_formula_renames_path(tap_path string) string {
	return os.join_path(tap_path, 'formula_renames.json')
}

// Ruby let `let(:renames_data) { {} }` at line 238.
pub fn ruby_tap_auditor_spec_l238_d26_renames_data() map[string]string {
	return map[string]string{}
}

// Ruby let `let(:renames_data) { { "oldformula.rb" => "newformula" } }` at line 245.
pub fn ruby_tap_auditor_spec_l245_d27_renames_data() map[string]string {
	return {
		'oldformula.rb': 'newformula'
	}
}

// Ruby it `it "detects the invalid format" do` at line 251.
pub fn ruby_tap_auditor_spec_l251_d28_detects() bool {
	problems := tap_auditor_spec_run_formula_renames('formula-extension', ruby_tap_auditor_spec_l245_d27_renames_data(), [
		'newformula',
	]) or { return false }
	return problems.len == 1 && problems[0].message == 'formula_renames.json contains entries with \'.rb\' file extensions.\nRename entries should use formula/cask names only, without \'.rb\' extensions.\nInvalid entries: "oldformula.rb": "newformula"\n'
}

// Ruby let `let(:renames_data) do` at line 264.
pub fn ruby_tap_auditor_spec_l264_d29_renames_data() map[string]string {
	return {
		'oldformula': 'newformula'
		'newformula': 'finalformula'
	}
}

// Ruby it `it "detects the chained renames" do` at line 275.
pub fn ruby_tap_auditor_spec_l275_d30_detects() bool {
	problems := tap_auditor_spec_run_formula_renames('formula-chain', ruby_tap_auditor_spec_l264_d29_renames_data(), [
		'finalformula',
	]) or { return false }
	return problems.len == 1 && problems[0].message == 'formula_renames.json contains chained renames that should be collapsed.\nChained renames don\'t work automatically; each old name should point directly to the final target:\n  "oldformula": "finalformula" (instead of chained rename)\n'
}

// Ruby let `let(:renames_data) { { "oldformula" => "newformula" } }` at line 288.
pub fn ruby_tap_auditor_spec_l288_d31_renames_data() map[string]string {
	return {
		'oldformula': 'newformula'
	}
}

// Ruby it `it "passes validation" do` at line 294.
pub fn ruby_tap_auditor_spec_l294_d32_passes() bool {
	problems := tap_auditor_spec_run_formula_renames('formula-valid', ruby_tap_auditor_spec_l288_d31_renames_data(), [
		'newformula',
	]) or { return false }
	return problems.filter(it.message.contains('formula_renames')).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "tap_auditor"
// 5:
// 6: RSpec.describe Homebrew::TapAuditor do
// 7:   let(:tap) { Tap.fetch("homebrew", "foo") }
// 8:   let(:tap_path) { tap.path }
// 9:   let(:auditor) { described_class.new(tap, strict: false) }
// 10:
// 11:   def write_cask(token, path = tap_path/"Casks"/"#{token}.rb")
// 12:     path.dirname.mkpath
// 13:     path.write <<~RUBY
// 14:       cask "#{token}" do
// 15:         version "1.0"
// 16:         url "https://brew.sh/#{token}-1.0.dmg"
// 17:         name "#{token.capitalize} Cask"
// 18:         homepage "https://brew.sh"
// 19:       end
// 20:     RUBY
// 21:   end
// 22:
// 23:   def write_formula(name, path = tap_path/"Formula"/"#{name}.rb")
// 24:     path.dirname.mkpath
// 25:     path.write <<~RUBY
// 26:       class #{name.capitalize} < Formula
// 27:         url "https://brew.sh/#{name}-1.0.tar.gz"
// 28:         version "1.0"
// 29:       end
// 30:     RUBY
// 31:   end
// 32:
// 33:   before do
// 34:     tap_path.mkpath
// 35:     tap.clear_cache
// 36:   end
// 37:
// 38:   describe "#audit" do
// 39:     subject(:problems) do
// 40:       auditor.audit
// 41:       auditor.problems
// 42:     end
// 43:
// 44:     context "with cask_renames.json" do
// 45:       let(:cask_renames_path) { tap_path/"cask_renames.json" }
// 46:       let(:renames_data) { {} }
// 47:
// 48:       before do
// 49:         cask_renames_path.write JSON.pretty_generate(renames_data)
// 50:       end
// 51:
// 52:       context "when .rb extension in old cask name (key)" do
// 53:         let(:renames_data) { { "oldcask.rb" => "newcask" } }
// 54:
// 55:         before do
// 56:           write_cask("newcask")
// 57:         end
// 58:
// 59:         it "detects the invalid format" do
// 60:           expect(problems.count).to eq(1)
// 61:           expect(problems.first[:message]).to eq(
// 62:             <<~EOS,
// 63:               cask_renames.json contains entries with '.rb' file extensions.
// 64:               Rename entries should use formula/cask names only, without '.rb' extensions.
// 65:               Invalid entries: "oldcask.rb": "newcask"
// 66:             EOS
// 67:           )
// 68:         end
// 69:       end
// 70:
// 71:       context "when .rb extension in new cask name (value)" do
// 72:         let(:renames_data) { { "oldcask" => "newcask.rb" } }
// 73:
// 74:         before do
// 75:           write_cask("newcask")
// 76:         end
// 77:
// 78:         it "detects the invalid format" do
// 79:           expect(problems.count).to eq(2)
// 80:
// 81:           invalid_format_problem = problems.find do |p|
// 82:             p[:message].include?("entries with '.rb' file extensions")
// 83:           end
// 84:           expect(invalid_format_problem[:message]).to eq(
// 85:             <<~EOS,
// 86:               cask_renames.json contains entries with '.rb' file extensions.
// 87:               Rename entries should use formula/cask names only, without '.rb' extensions.
// 88:               Invalid entries: "oldcask": "newcask.rb"
// 89:             EOS
// 90:           )
// 91:
// 92:           invalid_target_problem = problems.find do |p|
// 93:             p[:message].include?("Invalid targets")
// 94:           end
// 95:           expect(invalid_target_problem[:message]).to eq(
// 96:             <<~EOS,
// 97:               cask_renames.json contains renames to casks that do not exist in the homebrew/foo tap.
// 98:               Invalid targets: newcask.rb
// 99:             EOS
// 100:           )
// 101:         end
// 102:       end
// 103:
// 104:       context "when missing target cask" do
// 105:         let(:renames_data) { { "oldcask" => "nonexistent" } }
// 106:
// 107:         it "detects the missing target" do
// 108:           expect(problems.count).to eq(1)
// 109:           expect(problems.first[:message]).to eq(
// 110:             <<~EOS,
// 111:               cask_renames.json contains renames to casks that do not exist in the homebrew/foo tap.
// 112:               Invalid targets: nonexistent
// 113:             EOS
// 114:           )
// 115:         end
// 116:       end
// 117:
// 118:       context "with chained renames" do
// 119:         let(:renames_data) do
// 120:           {
// 121:             "oldcask" => "newcask",
// 122:             "newcask" => "finalcask",
// 123:           }
// 124:         end
// 125:
// 126:         before do
// 127:           write_cask("finalcask")
// 128:         end
// 129:
// 130:         it "detects the chained renames" do
// 131:           expect(problems.count).to eq(1)
// 132:           expect(problems.first[:message]).to eq(
// 133:             <<~EOS,
// 134:               cask_renames.json contains chained renames that should be collapsed.
// 135:               Chained renames don't work automatically; each old name should point directly to the final target:
// 136:                 "oldcask": "finalcask" (instead of chained rename)
// 137:             EOS
// 138:           )
// 139:         end
// 140:       end
// 141:
// 142:       context "with multi-level chained renames" do
// 143:         let(:renames_data) do
// 144:           {
// 145:             "oldcask"          => "newcask",
// 146:             "newcask"          => "intermediatecask",
// 147:             "intermediatecask" => "finalcask",
// 148:           }
// 149:         end
// 150:
// 151:         before do
// 152:           write_cask("intermediatecask")
// 153:           write_cask("finalcask")
// 154:         end
// 155:
// 156:         it "suggests final target" do
// 157:           expect(problems.count).to eq(2)
// 158:
// 159:           chained_problem = problems.find { |p| p[:message].include?("chained renames") }
// 160:           expect(chained_problem[:message]).to eq(
// 161:             <<~EOS,
// 162:               cask_renames.json contains chained renames that should be collapsed.
// 163:               Chained renames don't work automatically; each old name should point directly to the final target:
// 164:                 "oldcask": "finalcask" (instead of chained rename)
// 165:                 "newcask": "finalcask" (instead of chained rename)
// 166:             EOS
// 167:           )
// 168:
// 169:           conflict_problem = problems.find { |p| p[:message].include?("conflict") }
// 170:           expect(conflict_problem[:message]).to eq(
// 171:             <<~EOS,
// 172:               cask_renames.json contains old names that conflict with existing casks in the homebrew/foo tap.
// 173:               Renames only work after the old casks are deleted. Conflicting names: intermediatecask
// 174:             EOS
// 175:           )
// 176:         end
// 177:       end
// 178:
// 179:       context "with chained renames where intermediates don't exist" do
// 180:         let(:renames_data) do
// 181:           {
// 182:             "veryoldcask"      => "intermediatecask",
// 183:             "intermediatecask" => "finalcask",
// 184:           }
// 185:         end
// 186:
// 187:         before do
// 188:           write_cask("finalcask")
// 189:         end
// 190:
// 191:         it "reports chained rename error, not invalid target error" do
// 192:           expect(problems.count).to eq(1)
// 193:           expect(problems.first[:message]).to eq(
// 194:             <<~EOS,
// 195:               cask_renames.json contains chained renames that should be collapsed.
// 196:               Chained renames don't work automatically; each old name should point directly to the final target:
// 197:                 "veryoldcask": "finalcask" (instead of chained rename)
// 198:             EOS
// 199:           )
// 200:         end
// 201:       end
// 202:
// 203:       context "when old name conflicts with existing cask" do
// 204:         let(:renames_data) { { "newcask" => "anothercask" } }
// 205:
// 206:         before do
// 207:           write_cask("newcask")
// 208:           write_cask("anothercask")
// 209:         end
// 210:
// 211:         it "detects the conflict" do
// 212:           expect(problems.count).to eq(1)
// 213:           expect(problems.first[:message]).to eq(
// 214:             <<~EOS,
// 215:               cask_renames.json contains old names that conflict with existing casks in the homebrew/foo tap.
// 216:               Renames only work after the old casks are deleted. Conflicting names: newcask
// 217:             EOS
// 218:           )
// 219:         end
// 220:       end
// 221:
// 222:       context "with correct rename entries" do
// 223:         let(:renames_data) { { "oldcask" => "newcask" } }
// 224:
// 225:         before do
// 226:           write_cask("newcask")
// 227:         end
// 228:
// 229:         it "passes validation" do
// 230:           rename_problems = problems.select { |p| p[:message].include?("cask_renames") }
// 231:           expect(rename_problems).to be_empty
// 232:         end
// 233:       end
// 234:     end
// 235:
// 236:     context "with formula_renames.json" do
// 237:       let(:formula_renames_path) { tap_path/"formula_renames.json" }
// 238:       let(:renames_data) { {} }
// 239:
// 240:       before do
// 241:         formula_renames_path.write JSON.pretty_generate(renames_data)
// 242:       end
// 243:
// 244:       context "when .rb extension in formula rename keys" do
// 245:         let(:renames_data) { { "oldformula.rb" => "newformula" } }
// 246:
// 247:         before do
// 248:           write_formula("newformula")
// 249:         end
// 250:
// 251:         it "detects the invalid format" do
// 252:           expect(problems.count).to eq(1)
// 253:           expect(problems.first[:message]).to eq(
// 254:             <<~EOS,
// 255:               formula_renames.json contains entries with '.rb' file extensions.
// 256:               Rename entries should use formula/cask names only, without '.rb' extensions.
// 257:               Invalid entries: "oldformula.rb": "newformula"
// 258:             EOS
// 259:           )
// 260:         end
// 261:       end
// 262:
// 263:       context "with chained formula renames" do
// 264:         let(:renames_data) do
// 265:           {
// 266:             "oldformula" => "newformula",
// 267:             "newformula" => "finalformula",
// 268:           }
// 269:         end
// 270:
// 271:         before do
// 272:           write_formula("finalformula")
// 273:         end
// 274:
// 275:         it "detects the chained renames" do
// 276:           expect(problems.count).to eq(1)
// 277:           expect(problems.first[:message]).to eq(
// 278:             <<~EOS,
// 279:               formula_renames.json contains chained renames that should be collapsed.
// 280:               Chained renames don't work automatically; each old name should point directly to the final target:
// 281:                 "oldformula": "finalformula" (instead of chained rename)
// 282:             EOS
// 283:           )
// 284:         end
// 285:       end
// 286:
// 287:       context "with correct formula rename entries" do
// 288:         let(:renames_data) { { "oldformula" => "newformula" } }
// 289:
// 290:         before do
// 291:           write_formula("newformula")
// 292:         end
// 293:
// 294:         it "passes validation" do
// 295:           rename_problems = problems.select { |p| p[:message].include?("formula_renames") }
// 296:           expect(rename_problems).to be_empty
// 297:         end
// 298:       end
// 299:     end
// 300:   end
// 301: end
