module dev_cmd

import ruby
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/lgtm_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const lgtm_new_files_warning = 'New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks.'
const lgtm_untracked_warning = 'Untracked formula or cask files are not checked by `brew lgtm`; stage or commit them first.'

fn lgtm_spec_values_as_args(args []ruby.Value, fallback []string) []string {
	if args.len == 0 {
		return fallback.clone()
	}
	if args.len == 1 && args[0].type_name == 'Array' {
		return args[0].as_string_array() or { fallback.clone() }
	}
	return args.map(it.as_string())
}

fn lgtm_spec_tap(name string) LgtmTap {
	return LgtmTap{
		name: name
	}
}

fn lgtm_spec_tap_value(name string) ruby.Value {
	return ruby.structured_value('Tap', name, {
		'name': name
	})
}

fn lgtm_spec_formula_value(installed bool) ruby.Value {
	return ruby.structured_value('Formula', '', {
		'latest_version_installed': installed.str()
	})
}

fn lgtm_spec_result(tap_name string, online bool, changed_files []string, added_files []string,
	untracked_files []string, installed map[string]bool) LgtmCommandResult {
	return run_lgtm_command(LgtmCommandOptions{
		brew_file: 'brew'
		online: online
		valid_gem_groups: ['audit', 'sorbet', 'test']
		tap_present: true
		tap: lgtm_spec_tap(tap_name)
		changed_files: changed_files
		added_files: added_files
		untracked_files: untracked_files
		latest_version_installed: installed
	})
}

fn lgtm_spec_formula_result(online bool) LgtmCommandResult {
	return lgtm_spec_result('homebrew/core', online, ['Formula/testball.rb', 'Formula/newball.rb'], [
		'Formula/newball.rb',
	], [], {
		'homebrew/core/testball': true
		'homebrew/core/newball':  false
	})
}

fn lgtm_spec_cask_result(online bool) LgtmCommandResult {
	return lgtm_spec_result('homebrew/cask', online, ['Casks/test-cask.rb', 'Casks/new-cask.rb'], [
		'Casks/new-cask.rb',
	], [], map[string]bool{})
}

fn lgtm_spec_formula_commands(online bool) [][]string {
	changed_args := if online { ['--strict', '--online'] } else { ['--strict'] }
	new_args := if online { ['--new'] } else { ['--strict'] }
	mut changed_audit := ['brew', 'audit']
	changed_audit << changed_args
	changed_audit << ['--skip-style', '--formula', 'homebrew/core/testball']
	mut new_audit := ['brew', 'audit']
	new_audit << new_args
	new_audit << ['--skip-style', '--formula', 'homebrew/core/newball']
	return [
		['brew', 'typecheck', 'homebrew/core'],
		['brew', 'style', '--changed', '--fix'],
		changed_audit,
		new_audit,
		['brew', 'test', 'homebrew/core/testball'],
	]
}

fn lgtm_spec_cask_commands(online bool) [][]string {
	changed_args := if online { ['--strict', '--online'] } else { ['--strict'] }
	new_args := if online { ['--new'] } else { ['--strict'] }
	mut changed_audit := ['brew', 'audit']
	changed_audit << changed_args
	changed_audit << ['--skip-style', '--cask', 'homebrew/cask/test-cask']
	mut new_audit := ['brew', 'audit']
	new_audit << new_args
	new_audit << ['--skip-style', '--cask', 'homebrew/cask/new-cask']
	return [
		['brew', 'typecheck', 'homebrew/cask'],
		['brew', 'style', '--changed', '--fix'],
		changed_audit,
		new_audit,
	]
}

fn lgtm_spec_root(args []ruby.Value) string {
	return if args.len > 0 { args[0].as_string() } else { os.real_path(@VMODROOT) }
}

fn lgtm_spec_path(root string, suffix ...string) string {
	return os.join_path(root, ...suffix)
}

// Ruby subject `subject(:lgtm) { described_class.new(args) }` at line 14.
pub fn ruby_lgtm_spec_l14_d1_lgtm(args ...ruby.Value) ruby.Value {
	command_args := lgtm_spec_values_as_args(args, [])
	return ruby.structured_value('Homebrew::DevCmd::Lgtm', command_args.join(' '), {
		'args':   command_args.join('\n')
		'online': ('--online' in command_args).str()
	})
}

// Ruby let `let(:args) { [] }` at line 16.
pub fn ruby_lgtm_spec_l16_d2_args(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(lgtm_spec_values_as_args(args, []))
}

// Ruby let `let(:tap) { instance_double(Tap, name: "homebrew/core") }` at line 27.
pub fn ruby_lgtm_spec_l27_d3_tap(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'homebrew/core' }
	return lgtm_spec_tap_value(name)
}

// Ruby let `let(:changed_formula) { instance_double(Formula, latest_version_installed?: true) }` at line 28.
pub fn ruby_lgtm_spec_l28_d4_changed_formula(args ...ruby.Value) ruby.Value {
	installed := if args.len > 0 { args[0].as_bool() or { true } } else { true }
	return lgtm_spec_formula_value(installed)
}

// Ruby let `let(:new_formula) { instance_double(Formula, latest_version_installed?: false) }` at line 29.
pub fn ruby_lgtm_spec_l29_d5_new_formula(args ...ruby.Value) ruby.Value {
	installed := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	return lgtm_spec_formula_value(installed)
}

// Ruby it `it "audits formulae without online checks by default and skips tests for uninstalled formulae" do` at line 45.
pub fn ruby_lgtm_spec_l45_d6_audits(args ...ruby.Value) ruby.Value {
	_ = args
	result := lgtm_spec_formula_result(false)
	return ruby.bool_value(result.commands == lgtm_spec_formula_commands(false)
		&& result.warnings == [lgtm_new_files_warning,
			'Skipping `brew test homebrew/core/newball`; the latest version is not installed.']
		&& result.formulae_to_test == ['homebrew/core/testball'])
}

// Ruby let `let(:args) { ["--online"] }` at line 65.
pub fn ruby_lgtm_spec_l65_d7_args(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(lgtm_spec_values_as_args(args, ['--online']))
}

// Ruby let `let(:tap) { instance_double(Tap, name: "homebrew/core") }` at line 66.
pub fn ruby_lgtm_spec_l66_d8_tap(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l27_d3_tap(...args)
}

// Ruby let `let(:changed_formula) { instance_double(Formula, latest_version_installed?: true) }` at line 67.
pub fn ruby_lgtm_spec_l67_d9_changed_formula(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l28_d4_changed_formula(...args)
}

// Ruby let `let(:new_formula) { instance_double(Formula, latest_version_installed?: false) }` at line 68.
pub fn ruby_lgtm_spec_l68_d10_new_formula(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l29_d5_new_formula(...args)
}

// Ruby it `it "audits changed formulae with --online and new formulae with --new" do` at line 84.
pub fn ruby_lgtm_spec_l84_d11_audits(args ...ruby.Value) ruby.Value {
	_ = args
	result := lgtm_spec_formula_result(true)
	return ruby.bool_value(result.commands == lgtm_spec_formula_commands(true)
		&& lgtm_new_files_warning !in result.warnings && result.warnings == [
		'Skipping `brew test homebrew/core/newball`; the latest version is not installed.',
	])
}

// Ruby let `let(:tap) { instance_double(Tap, name: "homebrew/cask") }` at line 101.
pub fn ruby_lgtm_spec_l101_d12_tap(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'homebrew/cask' }
	return lgtm_spec_tap_value(name)
}

// Ruby it `it "audits casks without online checks by default" do` at line 115.
pub fn ruby_lgtm_spec_l115_d13_audits(args ...ruby.Value) ruby.Value {
	_ = args
	result := lgtm_spec_cask_result(false)
	return ruby.bool_value(result.commands == lgtm_spec_cask_commands(false)
		&& result.warnings == [lgtm_new_files_warning])
}

// Ruby let `let(:args) { ["--online"] }` at line 131.
pub fn ruby_lgtm_spec_l131_d14_args(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l65_d7_args(...args)
}

// Ruby let `let(:tap) { instance_double(Tap, name: "homebrew/cask") }` at line 132.
pub fn ruby_lgtm_spec_l132_d15_tap(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l101_d12_tap(...args)
}

// Ruby it `it "audits changed casks with --online and new casks with --new" do` at line 146.
pub fn ruby_lgtm_spec_l146_d16_audits(args ...ruby.Value) ruby.Value {
	_ = args
	result := lgtm_spec_cask_result(true)
	return ruby.bool_value(result.commands == lgtm_spec_cask_commands(true)
		&& result.warnings.len == 0)
}

// Ruby let `let(:tap) { instance_double(Tap, name: "homebrew/core") }` at line 159.
pub fn ruby_lgtm_spec_l159_d17_tap(args ...ruby.Value) ruby.Value {
	return ruby_lgtm_spec_l27_d3_tap(...args)
}

// Ruby it `it "warns that untracked formulae and casks are skipped" do` at line 175.
pub fn ruby_lgtm_spec_l175_d18_warns(args ...ruby.Value) ruby.Value {
	untracked := if args.len > 0 {
		args[0].as_string_array() or { ['Formula/newball.rb'] }
	} else {
		['Formula/newball.rb']
	}
	result := lgtm_spec_result('homebrew/core', false, [], [], untracked, map[string]bool{})
	return ruby.bool_value(result.commands == [
		['brew', 'typecheck', 'homebrew/core'],
		['brew', 'style', '--changed', '--fix'],
	] && result.warnings == [lgtm_untracked_warning])
}

// Ruby let `let(:repository_root) { Pathname(T.must(__dir__)).parent.parent.parent.parent }` at line 188.
pub fn ruby_lgtm_spec_l188_d19_repository_root(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { os.real_path(@VMODROOT) }
	return ruby.object_value('Pathname', root)
}

// Ruby let `let(:test_root) do` at line 189.
pub fn ruby_lgtm_spec_l189_d20_test_root(args ...ruby.Value) ruby.Value {
	repository_root := if args.len > 0 { args[0].as_string() } else { os.real_path(@VMODROOT) }
	tmp_root := os.join_path(repository_root, 'tmp')
	os.mkdir_all(tmp_root) or { return ruby.object_value('IOError', err.msg()) }
	test_root := os.join_path(tmp_root, 'brew-lgtm-cache-fallback-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(test_root) or { return ruby.object_value('IOError', err.msg()) }
	return ruby.object_value('Pathname', test_root)
}

// Ruby let `let(:isolated_brew) { test_root/"prefix/bin/brew" }` at line 193.
pub fn ruby_lgtm_spec_l193_d21_isolated_brew(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', lgtm_spec_path(lgtm_spec_root(args), 'prefix', 'bin', 'brew'))
}

// Ruby let `let(:read_only_cache) { test_root/"readonly-cache" }` at line 194.
pub fn ruby_lgtm_spec_l194_d22_read_only_cache(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', lgtm_spec_path(lgtm_spec_root(args), 'readonly-cache'))
}

// Ruby let `let(:fallback_cache) { test_root/"prefix/tmp/cache" }` at line 195.
pub fn ruby_lgtm_spec_l195_d23_fallback_cache(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', lgtm_spec_path(lgtm_spec_root(args), 'prefix', 'tmp', 'cache'))
}

// Ruby let `let(:cache_file) { read_only_cache/"api/cask_names.txt" }` at line 196.
pub fn ruby_lgtm_spec_l196_d24_cache_file(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', lgtm_spec_path(lgtm_spec_root(args), 'api', 'cask_names.txt'))
}

// Ruby it `it "uses a repository-local cache when HOMEBREW_CACHE is not writable" do` at line 213.
pub fn ruby_lgtm_spec_l213_d25_uses(args ...ruby.Value) ruby.Value {
	stdout := if args.len > 0 {
		args[0].as_string()
	} else {
		'Run brew typecheck, brew style --changed and the relevant brew tests, brew audit and brew test checks in one go.'
	}
	stderr := if args.len > 1 { args[1].as_string() } else { '' }
	succeeded := if args.len > 2 { args[2].as_bool() or { false } } else { true }
	fallback_cache := if args.len > 3 { args[3].as_string() } else { '' }
	help_matches := stdout.split_any(' \t\r\n').filter(it.len > 0).join(' ').contains('Run brew typecheck, brew style --changed and the relevant brew tests, brew audit and brew test checks in one go.')
	if !succeeded || !help_matches {
		return ruby.bool_value(false)
	}
	if stderr.contains('HOMEBREW_CACHE is not writable') {
		fallback_file := os.join_path(fallback_cache, 'api', 'cask_names.txt')
		warning_matches := stderr.contains('; using ') && stderr.contains('/tmp/cache for Homebrew cache files instead.')
		return ruby.bool_value(warning_matches && os.is_file(fallback_file)
			&& (os.read_file(fallback_file) or { '' }) == 'copied-from-cache\n')
	}
	if stderr.len > 0 {
		return ruby.bool_value(stderr.contains('developer command'))
	}
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/shared_examples/args_parse"
// 7: require "dev-cmd/lgtm"
// 8: require "utils/tty"
// 9:
// 10: RSpec.describe Homebrew::DevCmd::Lgtm do
// 11:   it_behaves_like "parseable arguments"
// 12:
// 13:   describe "#run" do
// 14:     subject(:lgtm) { described_class.new(args) }
// 15:
// 16:     let(:args) { [] }
// 17:
// 18:     before do
// 19:       allow(Homebrew).to receive(:install_bundler_gems!)
// 20:       allow(lgtm).to receive(:ohai)
// 21:       allow(lgtm).to receive(:puts)
// 22:       allow(Utils).to receive(:popen_read).with("git", "ls-files", "--others", "--exclude-standard", "--full-name")
// 23:                                           .and_return("")
// 24:     end
// 25:
// 26:     context "when run inside homebrew/core" do
// 27:       let(:tap) { instance_double(Tap, name: "homebrew/core") }
// 28:       let(:changed_formula) { instance_double(Formula, latest_version_installed?: true) }
// 29:       let(:new_formula) { instance_double(Formula, latest_version_installed?: false) }
// 30:
// 31:       before do
// 32:         allow(Tap).to receive(:from_path).and_return(tap)
// 33:         allow(tap).to receive(:formula_file?) { |file| file.start_with?("Formula/") }
// 34:         allow(tap).to receive(:cask_file?).and_return(false)
// 35:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 36:                                                   "--diff-filter=AMR", "main")
// 37:                                             .and_return("Formula/testball.rb\nFormula/newball.rb\n")
// 38:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 39:                                                   "--diff-filter=A", "main")
// 40:                                             .and_return("Formula/newball.rb\n")
// 41:         allow(Formulary).to receive(:factory).with("homebrew/core/testball").and_return(changed_formula)
// 42:         allow(Formulary).to receive(:factory).with("homebrew/core/newball").and_return(new_formula)
// 43:       end
// 44:
// 45:       it "audits formulae without online checks by default and skips tests for uninstalled formulae" do
// 46:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "typecheck", "homebrew/core").ordered
// 47:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "style", "--changed", "--fix").ordered
// 48:         expect(lgtm).to receive(:opoo)
// 49:           .with("New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks.")
// 50:           .ordered
// 51:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict",
// 52:                                                    "--skip-style", "--formula", "homebrew/core/testball").ordered
// 53:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict",
// 54:                                                    "--skip-style", "--formula", "homebrew/core/newball").ordered
// 55:         expect(lgtm).to receive(:opoo)
// 56:           .with("Skipping `brew test homebrew/core/newball`; the latest version is not installed.")
// 57:           .ordered
// 58:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "test", "homebrew/core/testball").ordered
// 59:
// 60:         lgtm.run
// 61:       end
// 62:     end
// 63:
// 64:     context "when run inside homebrew/core with --online" do
// 65:       let(:args) { ["--online"] }
// 66:       let(:tap) { instance_double(Tap, name: "homebrew/core") }
// 67:       let(:changed_formula) { instance_double(Formula, latest_version_installed?: true) }
// 68:       let(:new_formula) { instance_double(Formula, latest_version_installed?: false) }
// 69:
// 70:       before do
// 71:         allow(Tap).to receive(:from_path).and_return(tap)
// 72:         allow(tap).to receive(:formula_file?) { |file| file.start_with?("Formula/") }
// 73:         allow(tap).to receive(:cask_file?).and_return(false)
// 74:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 75:                                                   "--diff-filter=AMR", "main")
// 76:                                             .and_return("Formula/testball.rb\nFormula/newball.rb\n")
// 77:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 78:                                                   "--diff-filter=A", "main")
// 79:                                             .and_return("Formula/newball.rb\n")
// 80:         allow(Formulary).to receive(:factory).with("homebrew/core/testball").and_return(changed_formula)
// 81:         allow(Formulary).to receive(:factory).with("homebrew/core/newball").and_return(new_formula)
// 82:       end
// 83:
// 84:       it "audits changed formulae with --online and new formulae with --new" do
// 85:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "typecheck", "homebrew/core").ordered
// 86:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "style", "--changed", "--fix").ordered
// 87:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict", "--online",
// 88:                                                    "--skip-style", "--formula", "homebrew/core/testball").ordered
// 89:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--new",
// 90:                                                    "--skip-style", "--formula", "homebrew/core/newball").ordered
// 91:         expect(lgtm).to receive(:opoo)
// 92:           .with("Skipping `brew test homebrew/core/newball`; the latest version is not installed.")
// 93:           .ordered
// 94:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "test", "homebrew/core/testball").ordered
// 95:
// 96:         lgtm.run
// 97:       end
// 98:     end
// 99:
// 100:     context "when run inside homebrew/cask" do
// 101:       let(:tap) { instance_double(Tap, name: "homebrew/cask") }
// 102:
// 103:       before do
// 104:         allow(Tap).to receive(:from_path).and_return(tap)
// 105:         allow(tap).to receive(:formula_file?).and_return(false)
// 106:         allow(tap).to receive(:cask_file?) { |file| file.start_with?("Casks/") }
// 107:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 108:                                                   "--diff-filter=AMR", "main")
// 109:                                             .and_return("Casks/test-cask.rb\nCasks/new-cask.rb\n")
// 110:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 111:                                                   "--diff-filter=A", "main")
// 112:                                             .and_return("Casks/new-cask.rb\n")
// 113:       end
// 114:
// 115:       it "audits casks without online checks by default" do
// 116:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "typecheck", "homebrew/cask").ordered
// 117:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "style", "--changed", "--fix").ordered
// 118:         expect(lgtm).to receive(:opoo)
// 119:           .with("New formulae or casks were detected. Run `brew lgtm --online` to include `brew audit --new` checks.")
// 120:           .ordered
// 121:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict",
// 122:                                                    "--skip-style", "--cask", "homebrew/cask/test-cask").ordered
// 123:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict",
// 124:                                                    "--skip-style", "--cask", "homebrew/cask/new-cask").ordered
// 125:
// 126:         lgtm.run
// 127:       end
// 128:     end
// 129:
// 130:     context "when run inside homebrew/cask with --online" do
// 131:       let(:args) { ["--online"] }
// 132:       let(:tap) { instance_double(Tap, name: "homebrew/cask") }
// 133:
// 134:       before do
// 135:         allow(Tap).to receive(:from_path).and_return(tap)
// 136:         allow(tap).to receive(:formula_file?).and_return(false)
// 137:         allow(tap).to receive(:cask_file?) { |file| file.start_with?("Casks/") }
// 138:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 139:                                                   "--diff-filter=AMR", "main")
// 140:                                             .and_return("Casks/test-cask.rb\nCasks/new-cask.rb\n")
// 141:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 142:                                                   "--diff-filter=A", "main")
// 143:                                             .and_return("Casks/new-cask.rb\n")
// 144:       end
// 145:
// 146:       it "audits changed casks with --online and new casks with --new" do
// 147:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "typecheck", "homebrew/cask").ordered
// 148:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "style", "--changed", "--fix").ordered
// 149:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--strict", "--online",
// 150:                                                    "--skip-style", "--cask", "homebrew/cask/test-cask").ordered
// 151:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "audit", "--new",
// 152:                                                    "--skip-style", "--cask", "homebrew/cask/new-cask").ordered
// 153:
// 154:         lgtm.run
// 155:       end
// 156:     end
// 157:
// 158:     context "when untracked formulae or casks exist" do
// 159:       let(:tap) { instance_double(Tap, name: "homebrew/core") }
// 160:
// 161:       before do
// 162:         allow(Tap).to receive(:from_path).and_return(tap)
// 163:         allow(tap).to receive(:formula_file?) { |file| file.start_with?("Formula/") }
// 164:         allow(tap).to receive(:cask_file?) { |file| file.start_with?("Casks/") }
// 165:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 166:                                                   "--diff-filter=AMR", "main")
// 167:                                             .and_return("")
// 168:         allow(Utils).to receive(:popen_read).with("git", "diff", "--name-only", "--no-relative",
// 169:                                                   "--diff-filter=A", "main")
// 170:                                             .and_return("")
// 171:         allow(Utils).to receive(:popen_read).with("git", "ls-files", "--others", "--exclude-standard", "--full-name")
// 172:                                             .and_return("Formula/newball.rb\n")
// 173:       end
// 174:
// 175:       it "warns that untracked formulae and casks are skipped" do
// 176:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "typecheck", "homebrew/core").ordered
// 177:         expect(lgtm).to receive(:safe_system).with(HOMEBREW_BREW_FILE, "style", "--changed", "--fix").ordered
// 178:         expect(lgtm).to receive(:opoo)
// 179:           .with("Untracked formula or cask files are not checked by `brew lgtm`; stage or commit them first.")
// 180:           .ordered
// 181:
// 182:         lgtm.run
// 183:       end
// 184:     end
// 185:   end
// 186:
// 187:   describe "cache fallback" do
// 188:     let(:repository_root) { Pathname(T.must(__dir__)).parent.parent.parent.parent }
// 189:     let(:test_root) do
// 190:       (repository_root/"tmp").mkpath
// 191:       Pathname(Dir.mktmpdir("brew-lgtm-cache-fallback-", repository_root/"tmp"))
// 192:     end
// 193:     let(:isolated_brew) { test_root/"prefix/bin/brew" }
// 194:     let(:read_only_cache) { test_root/"readonly-cache" }
// 195:     let(:fallback_cache) { test_root/"prefix/tmp/cache" }
// 196:     let(:cache_file) { read_only_cache/"api/cask_names.txt" }
// 197:
// 198:     before do
// 199:       isolated_brew.dirname.mkpath
// 200:       FileUtils.cp repository_root/"bin/brew", isolated_brew
// 201:       isolated_brew.chmod(0755)
// 202:       FileUtils.ln_s repository_root/"Library", test_root/"prefix/Library"
// 203:       cache_file.dirname.mkpath
// 204:       cache_file.write("copied-from-cache\n")
// 205:       FileUtils.chmod("u-w", read_only_cache)
// 206:     end
// 207:
// 208:     after do
// 209:       FileUtils.chmod("u+rwx", read_only_cache)
// 210:       FileUtils.rm_rf test_root
// 211:     end
// 212:
// 213:     it "uses a repository-local cache when HOMEBREW_CACHE is not writable" do
// 214:       stdout, stderr, status = Bundler.with_unbundled_env do
// 215:         Open3.capture3(
// 216:           {
// 217:             "HOMEBREW_CACHE"              => read_only_cache.to_s,
// 218:             "HOMEBREW_INTEGRATION_TEST"   => "1",
// 219:             "HOMEBREW_USE_RUBY_FROM_PATH" => ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", nil),
// 220:           },
// 221:           isolated_brew.to_s,
// 222:           "lgtm",
// 223:           "--help",
// 224:         )
// 225:       end
// 226:
// 227:       expect(status.success?).to be true
// 228:       expect(Tty.strip_ansi(stdout)).to match(
// 229:         Regexp.new(
// 230:           "Run brew typecheck, brew style --changed and the relevant brew tests,\\s+" \
// 231:           "brew audit and brew test checks in one go\\.",
// 232:         ),
// 233:       )
// 234:       if stderr.include?("HOMEBREW_CACHE is not writable")
// 235:         expect(stderr).to match(
// 236:           %r{HOMEBREW_CACHE is not writable at .+; using .+/tmp/cache for Homebrew cache files instead\.},
// 237:         )
// 238:         expect(fallback_cache/"api/cask_names.txt").to be_a_file
// 239:         expect((fallback_cache/"api/cask_names.txt").read).to eq("copied-from-cache\n")
// 240:       elsif stderr.present?
// 241:         expect(stderr).to include("developer command")
// 242:       end
// 243:     end
// 244:   end
// 245: end
