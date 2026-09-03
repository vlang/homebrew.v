module dev_cmd

import crypto.sha256
import brew_runtime
import homebrew.dev_cmd as production_dev_cmd
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/bump-formula-pr_spec.rb`.
// The original source is retained below for source-by-source auditability.

fn bump_formula_pr_spec_formula() production_dev_cmd.BumpFormula {
	return production_dev_cmd.BumpFormula{
		name: 'test'
		full_name: 'test'
		contents: 'class Test < Formula\n  url "https://brew.sh/test-1.2.3.tgz"\nend\n'
		version: '1.2.3'
		url: 'https://brew.sh/test-1.2.3.tgz'
		tap_name: 'test/tap'
		tap_remote_repository: 'test/tap'
	}
}

fn bump_formula_pr_spec_throttle_formula(name string, rate ?int, days ?int,
	allows_bump bool) production_dev_cmd.BumpFormula {
	return production_dev_cmd.BumpFormula{
		name: name
		full_name: 'test/tap/${name}'
		contents: 'class Test < Formula\n  url "https://brew.sh/test-1.2.3.tgz"\nend\n'
		version: '1.2.3'
		url: 'https://brew.sh/test-1.2.3.tgz'
		tap_name: 'test/tap'
		tap_remote_repository: 'test/tap'
		throttle_rate: rate
		throttle_days: days
		throttle_allows_bump: allows_bump
	}
}

fn bump_formula_pr_spec_matching_formula() production_dev_cmd.BumpFormula {
	return production_dev_cmd.BumpFormula{
		name: 'test'
		full_name: 'test'
		contents: 'class Test < Formula\n  url "https://brew.sh/test-1.2.3.tgz"\n\n  resource "parent" do\n    url "https://brew.sh/parent-1.2.3.tar.gz"\n  end\n\n  resource "no-parent" do\n    url "https://brew.sh/no-parent-1.2.3.tar.gz"\n  end\nend\n'
		version: '1.2.3'
		url: 'https://brew.sh/test-1.2.3.tgz'
		resources: [
			production_dev_cmd.BumpFormulaResource{
				name: 'parent'
				version: '1.2.3'
				url: 'https://brew.sh/parent-1.2.3.tar.gz'
				livecheck_parent: true
				fetched_version: '1.2.4'
			},
			production_dev_cmd.BumpFormulaResource{
				name: 'no-parent'
				version: '1.2.3'
				url: 'https://brew.sh/no-parent-1.2.3.tar.gz'
				fetched_version: '1.2.4'
			},
		]
		tap_name: 'test/tap'
		tap_remote_repository: 'test/tap'
	}
}

fn bump_formula_pr_spec_resource_formula() production_dev_cmd.BumpFormula {
	return production_dev_cmd.BumpFormula{
		name: 'test'
		full_name: 'test'
		contents: 'class Test < Formula\n  url "https://brew.sh/test-1.0.0.tgz"\n\n  resource "foo" do\n    url "https://brew.sh/foo-1.2.3.tar.gz"\n  end\nend\n'
		version: '1.0.0'
		url: 'https://brew.sh/test-1.0.0.tgz'
		resources: [production_dev_cmd.BumpFormulaResource{
			name: 'foo'
			version: '1.2.3'
			url: 'https://brew.sh/foo-1.2.3.tar.gz'
		}]
		tap_name: 'test/tap'
		tap_remote_repository: 'test/tap'
	}
}

fn bump_formula_pr_spec_versions(current string,
	latest string) map[string]production_dev_cmd.BumpFormulaResourceVersion {
	return {
		'foo': production_dev_cmd.BumpFormulaResourceVersion{
			current_version: current
			latest_version: latest
		}
	}
}

fn bump_formula_pr_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Ruby subject `subject(:bump_formula_pr) { described_class.new(["test"]) }` at line 9.
pub fn ruby_bump_formula_pr_spec_l9_d1_bump_formula_pr(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.structured_value('Homebrew::DevCmd::BumpFormulaPr', 'test', {
		'named': 'test'
	})
}

// Ruby let `let(:f) do` at line 11.
pub fn ruby_bump_formula_pr_spec_l11_d2_f(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_formula())
}

// Ruby it `it "adds updated mirrors as string literals" do` at line 21.
pub fn ruby_bump_formula_pr_spec_l21_d3_adds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := os.join_path(os.temp_dir(), 'brew-v-bump-formula-pr-spec-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(root) or { return bump_formula_pr_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	formula_path := os.join_path(root, 'couchdb.rb')
	resource_path := os.join_path(root, 'apache-couchdb-3.5.2.tar.gz')
	contents := 'class Couchdb < Formula\n  url "https://www.apache.org/dyn/closer.lua?path=couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz"\n  mirror "https://archive.apache.org/dist/couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz"\n  sha256 "${'a'.repeat(64)}"\nend\n'
	os.write_file(formula_path, contents) or { return bump_formula_pr_spec_bool(false) }
	os.write_file(resource_path, 'couchdb') or { return bump_formula_pr_spec_bool(false) }
	updated_mirror := 'https://archive.apache.org/dist/couchdb/source/3.5.2/apache-couchdb-3.5.2.tar.gz'
	digest := sha256.sum256('couchdb'.bytes()).hex()
	result := production_dev_cmd.bump_formula_run(production_dev_cmd.BumpFormulaRunRequest{
		formula: production_dev_cmd.BumpFormula{
			name: 'couchdb'
			full_name: 'homebrew/core/couchdb'
			path: formula_path
			contents: contents
			version: '3.5.1'
			url: 'https://www.apache.org/dyn/closer.lua?path=couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz'
			checksum: 'a'.repeat(64)
			mirrors: [
				'https://archive.apache.org/dist/couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz',
			]
			tap_name: 'homebrew/core'
			tap_path: root
			tap_remote_repository: 'Homebrew/homebrew-core'
			tap_official: true
			download_path: resource_path
			fetched_version: '3.5.2'
		}
		options: production_dev_cmd.BumpFormulaOptions{
			url: 'https://www.apache.org/dyn/closer.lua?path=couchdb/source/3.5.2/apache-couchdb-3.5.2.tar.gz'
			write_only: true
			no_audit: true
		}
	})
	written := os.read_file(formula_path) or { return bump_formula_pr_spec_bool(false) }
	return bump_formula_pr_spec_bool(result.error == ''
		&& written.contains('  mirror "${updated_mirror}"\n  sha256 "${digest}"\n'))
}

// Ruby let `let(:tap) { Tap.fetch("test", "tap") }` at line 66.
pub fn ruby_bump_formula_pr_spec_l66_d4_tap(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.structured_value('Tap', 'test/tap', {
		'user':       'test'
		'repository': 'tap'
	})
}

// Ruby let `let(:f_throttle) do` at line 68.
pub fn ruby_bump_formula_pr_spec_l68_d5_f_throttle(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_throttle_formula('throttle-test', 5, none, true))
}

// Ruby let `let(:f_throttle_days) do` at line 79.
pub fn ruby_bump_formula_pr_spec_l79_d6_f_throttle_days(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_throttle_formula('throttle-days-test', none, 1, true))
}

// Ruby let `let(:f_throttle_rate_and_days) do` at line 90.
pub fn ruby_bump_formula_pr_spec_l90_d7_f_throttle_rate_and_days(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_throttle_formula('throttle-rate-and-days-test', 5, 1, true))
}

// Ruby let `let(:throttle_error) { "Error: throttle-test should only be updated every 5 releases on multiples of 5\n" }` at line 101.
pub fn ruby_bump_formula_pr_spec_l101_d8_throttle_error(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Error: throttle-test should only be updated every 5 releases on multiples of 5\n')
}

// Ruby let `let(:throttle_days_error) { "Error: throttle-days-test should only be updated every 1 day\n" }` at line 102.
pub fn ruby_bump_formula_pr_spec_l102_d9_throttle_days_error(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Error: throttle-days-test should only be updated every 1 day\n')
}

// Ruby let `let(:throttle_rate_days_error) do` at line 103.
pub fn ruby_bump_formula_pr_spec_l103_d10_throttle_rate_days_error(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('Error: throttle-rate-and-days-test should only be updated every 5 releases on multiples of 5 or 1 day\n')
}

// Ruby it `it "outputs nothing" do` at line 108.
pub fn ruby_bump_formula_pr_spec_l108_d11_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut formula := bump_formula_pr_spec_formula()
	formula = production_dev_cmd.BumpFormula{
		...formula
		tap_present: false
	}
	result := production_dev_cmd.bump_formula_check_throttle(formula, '1.2.4')
	return bump_formula_pr_spec_bool(result.allowed && result.error == '' && result.output.len == 0)
}

// Ruby it `it "does not throttle" do` at line 116.
pub fn ruby_bump_formula_pr_spec_l116_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_formula(), '1.2.4')
	return bump_formula_pr_spec_bool(result.allowed && result.error == '' && result.output.len == 0)
}

// Ruby it `it "does not throttle" do` at line 124.
pub fn ruby_bump_formula_pr_spec_l124_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-test', 5, none, true), '1.2.5')
	return bump_formula_pr_spec_bool(result.allowed && result.error == '' && result.output.len == 0)
}

// Ruby it `it "throttles version" do` at line 132.
pub fn ruby_bump_formula_pr_spec_l132_d14_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-test', 5, none, false), '1.2.4')
	stderr := if result.error == '' { '' } else { 'Error: ${result.error}\n' }
	return bump_formula_pr_spec_bool(!result.allowed
		&& stderr == ruby_bump_formula_pr_spec_l101_d8_throttle_error().as_string())
}

// Ruby it `it "throttles version when throttle interval has not elapsed" do` at line 148.
pub fn ruby_bump_formula_pr_spec_l148_d15_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-rate-and-days-test', 5, 1, false), '1.2.4')
	stderr := if result.error == '' { '' } else { 'Error: ${result.error}\n' }
	return bump_formula_pr_spec_bool(!result.allowed
		&& stderr == ruby_bump_formula_pr_spec_l103_d10_throttle_rate_days_error().as_string())
}

// Ruby it `it "does not throttle when throttle interval has elapsed" do` at line 158.
pub fn ruby_bump_formula_pr_spec_l158_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-rate-and-days-test', 5, 1, true), '1.2.4')
	return bump_formula_pr_spec_bool(result.allowed && result.error == '' && result.output.len == 0)
}

// Ruby it `it "throttles version when throttle interval has not elapsed" do` at line 170.
pub fn ruby_bump_formula_pr_spec_l170_d17_throttles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-days-test', none, 1, false), '1.2.4')
	stderr := if result.error == '' { '' } else { 'Error: ${result.error}\n' }
	return bump_formula_pr_spec_bool(!result.allowed
		&& stderr == ruby_bump_formula_pr_spec_l102_d9_throttle_days_error().as_string())
}

// Ruby it `it "does not throttle when throttle interval has elapsed" do` at line 180.
pub fn ruby_bump_formula_pr_spec_l180_d18_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.bump_formula_check_throttle(bump_formula_pr_spec_throttle_formula('throttle-days-test', none, 1, true), '1.2.4')
	return bump_formula_pr_spec_bool(result.allowed && result.error == '' && result.output.len == 0)
}

// Ruby let `let(:f) do` at line 191.
pub fn ruby_bump_formula_pr_spec_l191_d19_f(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_matching_formula())
}

// Ruby let `let(:resource) { f.resource("parent") }` at line 208.
pub fn ruby_bump_formula_pr_spec_l208_d20_resource(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_resource_value(bump_formula_pr_spec_matching_formula().resources[0])
}

// Ruby let `let(:version) { "1.2.4" }` at line 209.
pub fn ruby_bump_formula_pr_spec_l209_d21_version(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('1.2.4')
}

// Ruby it `it "only updates `:parent` resource" do` at line 211.
pub fn ruby_bump_formula_pr_spec_l211_d22_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	updates := production_dev_cmd.bump_formula_update_matching_version_resources(bump_formula_pr_spec_matching_formula(), '1.2.4', map[string]production_dev_cmd.BumpFormulaResourceVersion{})
	return bump_formula_pr_spec_bool(updates.statuses == {
		'parent': 'success'
	}
		&& updates.contents.contains('parent-1.2.4.tar.gz')
		&& updates.contents.contains('no-parent-1.2.3.tar.gz'))
}

// Ruby it `it "does not update `:parent` resource if set in `--resource-versions`" do` at line 216.
pub fn ruby_bump_formula_pr_spec_l216_d23_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	updates := production_dev_cmd.bump_formula_update_matching_version_resources(bump_formula_pr_spec_matching_formula(), '1.2.4', {
		'parent': production_dev_cmd.BumpFormulaResourceVersion{
			current_version: '1.2.3'
			latest_version: '1.2.4'
		}
	})
	return bump_formula_pr_spec_bool(updates.statuses.len == 0
		&& updates.contents == bump_formula_pr_spec_matching_formula().contents)
}

// Ruby let `let(:f) do` at line 224.
pub fn ruby_bump_formula_pr_spec_l224_d24_f(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_value(bump_formula_pr_spec_resource_formula())
}

// Ruby let `let(:r) { f.resource("foo") }` at line 234.
pub fn ruby_bump_formula_pr_spec_l234_d25_r(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bump_formula_resource_value(bump_formula_pr_spec_resource_formula().resources[0])
}

// Ruby it `it "updates to requested version" do` at line 236.
pub fn ruby_bump_formula_pr_spec_l236_d26_updates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	updates := production_dev_cmd.bump_formula_update_resources(bump_formula_pr_spec_resource_formula(), bump_formula_pr_spec_versions('1.2.3', '2.1.0'))
	return bump_formula_pr_spec_bool(updates.statuses == {
		'foo': 'success'
	}
		&& updates.contents.contains('foo-2.1.0.tar.gz'))
}

// Ruby it `it "downgrades to requested version" do` at line 243.
pub fn ruby_bump_formula_pr_spec_l243_d27_downgrades(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	updates := production_dev_cmd.bump_formula_update_resources(bump_formula_pr_spec_resource_formula(), bump_formula_pr_spec_versions('1.2.3', '0.1.2'))
	return bump_formula_pr_spec_bool(updates.statuses == {
		'foo': 'downgraded'
	}
		&& updates.contents.contains('foo-0.1.2.tar.gz'))
}

// Ruby it `it "returns update failures" do` at line 250.
pub fn ruby_bump_formula_pr_spec_l250_d28_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := bump_formula_pr_spec_resource_formula()
	unchanged := production_dev_cmd.BumpFormula{
		...formula
		contents: formula.contents.replace('foo-1.2.3.tar.gz', 'foo.tar.gz')
		resources: [production_dev_cmd.BumpFormulaResource{
			...formula.resources[0]
			url: 'https://brew.sh/foo.tar.gz'
		}]
	}
	updates := production_dev_cmd.bump_formula_update_resources(unchanged, bump_formula_pr_spec_versions('1.2.3', '0.1.2'))
	return bump_formula_pr_spec_bool(updates.statuses == {
		'foo': 'url_unchanged'
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/bump-formula-pr"
// 6: require "utils/pypi"
// 7:
// 8: RSpec.describe Homebrew::DevCmd::BumpFormulaPr do
// 9:   subject(:bump_formula_pr) { described_class.new(["test"]) }
// 10:
// 11:   let(:f) do
// 12:     formula("test") do
// 13:       T.bind(self, T.class_of(Formula))
// 14:       url "https://brew.sh/test-1.2.3.tgz"
// 15:     end
// 16:   end
// 17:
// 18:   it_behaves_like "parseable arguments"
// 19:
// 20:   describe "#run" do
// 21:     it "adds updated mirrors as string literals" do
// 22:       formula_path = CoreTap.instance.new_formula_path("couchdb")
// 23:       formula_path.dirname.mkpath
// 24:       formula_path.write <<~RUBY
// 25:         class Couchdb < Formula
// 26:           url "https://www.apache.org/dyn/closer.lua?path=couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz"
// 27:           mirror "https://archive.apache.org/dist/couchdb/source/3.5.1/apache-couchdb-3.5.1.tar.gz"
// 28:           sha256 "#{"a" * 64}"
// 29:         end
// 30:       RUBY
// 31:       CoreTap.instance.clear_cache
// 32:       Formulary.clear_cache
// 33:       Formula.clear_cache
// 34:       formula = Formulary.from_contents("couchdb", formula_path, formula_path.read)
// 35:
// 36:       resource_path = mktmpdir/"apache-couchdb-3.5.2.tar.gz"
// 37:       resource_path.write("couchdb")
// 38:       updated_mirror = "https://archive.apache.org/dist/couchdb/source/3.5.2/apache-couchdb-3.5.2.tar.gz"
// 39:       command = described_class.new(["--write-only", "--no-audit", "--version=3.5.2", "couchdb"])
// 40:
// 41:       allow(Homebrew).to receive(:install_bundler_gems!)
// 42:       allow(CoreTap.instance).to receive_messages(allow_bump?: true, git?: true,
// 43:                                                   remote_repository: "Homebrew/homebrew-core")
// 44:       allow(command).to receive(:check_new_version)
// 45:       allow(command).to receive(:fetch_resource_and_forced_version).and_return([resource_path, false])
// 46:       allow(command).to receive_messages(run_audit: false, update_matching_version_resources!: {})
// 47:       allow(PyPI).to receive(:update_python_resources!)
// 48:       allow(Utils::Tar).to receive(:validate_file).with(resource_path)
// 49:       allow(command.args.named).to receive(:to_formulae).and_return([formula])
// 50:       allow(Formula).to receive(:[]).with("couchdb").and_return(formula)
// 51:       expect_any_instance_of(Utils::AST::FormulaAST)
// 52:         .to receive(:add_stable_stanzas_after) do |formula_ast, name, stanzas|
// 53:         expect(name).to eq(:url)
// 54:         expect(stanzas).to include([:mirror, "mirror #{updated_mirror.inspect}"])
// 55:         formula_ast.add_stanzas_after(name, stanzas, parent: formula_ast.stanza(:stable, type: :block_call))
// 56:       end
// 57:
// 58:       command.run
// 59:
// 60:       expect(formula_path.read).to include "  mirror #{updated_mirror.inspect}\n  " \
// 61:                                            "sha256 #{resource_path.sha256.inspect}\n"
// 62:     end
// 63:   end
// 64:
// 65:   describe "::check_throttle" do
// 66:     let(:tap) { Tap.fetch("test", "tap") }
// 67:
// 68:     let(:f_throttle) do
// 69:       formula("throttle-test") do
// 70:         T.bind(self, T.class_of(Formula))
// 71:         url "https://brew.sh/test-1.2.3.tgz"
// 72:
// 73:         livecheck do
// 74:           throttle 5
// 75:         end
// 76:       end
// 77:     end
// 78:
// 79:     let(:f_throttle_days) do
// 80:       formula("throttle-days-test") do
// 81:         T.bind(self, T.class_of(Formula))
// 82:         url "https://brew.sh/test-1.2.3.tgz"
// 83:
// 84:         livecheck do
// 85:           throttle days: 1
// 86:         end
// 87:       end
// 88:     end
// 89:
// 90:     let(:f_throttle_rate_and_days) do
// 91:       formula("throttle-rate-and-days-test") do
// 92:         T.bind(self, T.class_of(Formula))
// 93:         url "https://brew.sh/test-1.2.3.tgz"
// 94:
// 95:         livecheck do
// 96:           throttle 5, days: 1
// 97:         end
// 98:       end
// 99:     end
// 100:
// 101:     let(:throttle_error) { "Error: throttle-test should only be updated every 5 releases on multiples of 5\n" }
// 102:     let(:throttle_days_error) { "Error: throttle-days-test should only be updated every 1 day\n" }
// 103:     let(:throttle_rate_days_error) do
// 104:       "Error: throttle-rate-and-days-test should only be updated every 5 releases on multiples of 5 or 1 day\n"
// 105:     end
// 106:
// 107:     context "when formula is not in a tap" do
// 108:       it "outputs nothing" do
// 109:         allow(f).to receive(:tap).and_return(nil)
// 110:
// 111:         expect { bump_formula_pr.check_throttle(f, "1.2.4") }.not_to output.to_stderr
// 112:       end
// 113:     end
// 114:
// 115:     context "when a livecheck throttle value isn't present" do
// 116:       it "does not throttle" do
// 117:         allow(f).to receive(:tap).and_return(tap)
// 118:
// 119:         expect { bump_formula_pr.check_throttle(f, "1.2.4") }.not_to output.to_stderr
// 120:       end
// 121:     end
// 122:
// 123:     context "when patch version is a multiple of throttle rate" do
// 124:       it "does not throttle" do
// 125:         allow(f_throttle).to receive(:tap).and_return(tap)
// 126:
// 127:         expect { bump_formula_pr.check_throttle(f_throttle, "1.2.5") }.not_to output.to_stderr
// 128:       end
// 129:     end
// 130:
// 131:     context "when patch version is not a multiple of throttle rate" do
// 132:       it "throttles version" do
// 133:         allow(f_throttle).to receive(:tap).and_return(tap)
// 134:
// 135:         expect do
// 136:           bump_formula_pr.check_throttle(f_throttle, "1.2.4")
// 137:         rescue SystemExit
// 138:           nil
// 139:         end.to output(throttle_error).to_stderr
// 140:       end
// 141:     end
// 142:
// 143:     context "when patch version is not a multiple and throttle days are set" do
// 144:       before do
// 145:         allow(f_throttle_rate_and_days).to receive(:tap).and_return(tap)
// 146:       end
// 147:
// 148:       it "throttles version when throttle interval has not elapsed" do
// 149:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 150:
// 151:         expect do
// 152:           bump_formula_pr.check_throttle(f_throttle_rate_and_days, "1.2.4")
// 153:         rescue SystemExit
// 154:           nil
// 155:         end.to output(throttle_rate_days_error).to_stderr
// 156:       end
// 157:
// 158:       it "does not throttle when throttle interval has elapsed" do
// 159:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 160:
// 161:         expect { bump_formula_pr.check_throttle(f_throttle_rate_and_days, "1.2.4") }.not_to output.to_stderr
// 162:       end
// 163:     end
// 164:
// 165:     context "when only throttle days is set" do
// 166:       before do
// 167:         allow(f_throttle_days).to receive(:tap).and_return(tap)
// 168:       end
// 169:
// 170:       it "throttles version when throttle interval has not elapsed" do
// 171:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 172:
// 173:         expect do
// 174:           bump_formula_pr.check_throttle(f_throttle_days, "1.2.4")
// 175:         rescue SystemExit
// 176:           next
// 177:         end.to output(throttle_days_error).to_stderr
// 178:       end
// 179:
// 180:       it "does not throttle when throttle interval has elapsed" do
// 181:         allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 182:
// 183:         expect do
// 184:           bump_formula_pr.check_throttle(f_throttle_days, "1.2.4")
// 185:         end.not_to output.to_stderr
// 186:       end
// 187:     end
// 188:   end
// 189:
// 190:   describe "::update_matching_version_resources!" do
// 191:     let(:f) do
// 192:       formula("test") do
// 193:         T.bind(self, T.class_of(Formula))
// 194:         url "https://brew.sh/test-1.2.3.tgz"
// 195:
// 196:         resource "parent" do
// 197:           url "https://brew.sh/parent-1.2.3.tar.gz"
// 198:           livecheck do
// 199:             formula :parent
// 200:           end
// 201:         end
// 202:
// 203:         resource "no-parent" do
// 204:           url "https://brew.sh/no-parent-1.2.3.tar.gz"
// 205:         end
// 206:       end
// 207:     end
// 208:     let(:resource) { f.resource("parent") }
// 209:     let(:version) { "1.2.4" }
// 210:
// 211:     it "only updates `:parent` resource" do
// 212:       expect(bump_formula_pr).to receive(:update_resource_block!).with(f, resource, version).and_return(:success)
// 213:       expect(bump_formula_pr.update_matching_version_resources!(f, version:)).to eq({ "parent" => :success })
// 214:     end
// 215:
// 216:     it "does not update `:parent` resource if set in `--resource-versions`" do
// 217:       resource_versions = { "parent" => { current_version: "1.2.3", latest_version: version } }
// 218:       expect(bump_formula_pr).not_to receive(:update_resource_block!)
// 219:       expect(bump_formula_pr.update_matching_version_resources!(f, version:, resource_versions:)).to eq({})
// 220:     end
// 221:   end
// 222:
// 223:   describe "::update_resources!" do
// 224:     let(:f) do
// 225:       formula("test") do
// 226:         T.bind(self, T.class_of(Formula))
// 227:         url "https://brew.sh/test-1.0.0.tgz"
// 228:
// 229:         resource "foo" do
// 230:           url "https://brew.sh/foo-1.2.3.tar.gz"
// 231:         end
// 232:       end
// 233:     end
// 234:     let(:r) { f.resource("foo") }
// 235:
// 236:     it "updates to requested version" do
// 237:       version = "2.1.0"
// 238:       resource_versions = { "foo" => { current_version: "1.2.3", latest_version: version } }
// 239:       expect(bump_formula_pr).to receive(:update_resource_block!).with(f, r, version).and_return(:success)
// 240:       expect(bump_formula_pr.update_resources!(f, resource_versions:)).to eq({ "foo" => :success })
// 241:     end
// 242:
// 243:     it "downgrades to requested version" do
// 244:       version = "0.1.2"
// 245:       resource_versions = { "foo" => { current_version: "1.2.3", latest_version: version } }
// 246:       expect(bump_formula_pr).to receive(:update_resource_block!).with(f, r, version).and_return(:success)
// 247:       expect(bump_formula_pr.update_resources!(f, resource_versions:)).to eq({ "foo" => :downgraded })
// 248:     end
// 249:
// 250:     it "returns update failures" do
// 251:       version = "0.1.2"
// 252:       resource_versions = { "foo" => { current_version: "1.2.3", latest_version: version } }
// 253:       expect(bump_formula_pr).to receive(:update_resource_block!).with(f, r, version).and_return(:url_unchanged)
// 254:       expect(bump_formula_pr.update_resources!(f, resource_versions:)).to eq({ "foo" => :url_unchanged })
// 255:     end
// 256:   end
// 257: end
