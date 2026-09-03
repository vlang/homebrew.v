module test

import homebrew

// Translated from Homebrew/brew `test/github_runner_matrix_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn runner_matrix_spec_formula(name string, dependency string, platform string, arch string,
	macos_version string, disabled bool, deprecated bool) homebrew.TestRunnerFormula {
	mut requirements := []homebrew.TestRunnerRequirement{}
	if arch != '' {
		requirements << homebrew.TestRunnerRequirement{
			kind: .arch
			arch: arch
		}
	}
	if macos_version != '' {
		requirements << homebrew.TestRunnerRequirement{
			kind: .macos
			version: macos_version
			version_specified: true
		}
	}
	dependencies := if dependency == '' { []string{} } else { [dependency] }
	return homebrew.new_test_runner_formula(homebrew.TestRunnerFormulaDefinition{
		name: name
		supports_macos: platform != 'linux'
		supports_linux: platform != 'macos' && macos_version == ''
		requirements: requirements
		dependencies: dependencies
		disabled: disabled
		deprecated: deprecated
	}, true)
}

fn runner_matrix_spec_testball() homebrew.TestRunnerFormula {
	return runner_matrix_spec_formula('testball', '', '', '', '', false, false)
}

fn runner_matrix_spec_depender(platform string, arch string, macos_version string,
	disabled bool, deprecated bool) homebrew.TestRunnerFormula {
	mut suffix := if platform != '' { '-${platform}' } else { '' }
	if arch != '' {
		suffix = if arch == 'x86_64' { '-intel' } else { '-arm' }
	}
	if macos_version != '' {
		suffix = '-newest'
	}
	return runner_matrix_spec_formula('testball-depender${suffix}', 'testball', platform, arch, macos_version, disabled, deprecated)
}

fn runner_matrix_spec_options(dependent bool, candidates []homebrew.TestRunnerFormula,
	shards int, oldest string, long_timeout bool) homebrew.GitHubRunnerMatrixOptions {
	return homebrew.GitHubRunnerMatrixOptions{
		dependent_matrix: dependent
		dependent_shards: shards
		github_run_id: '12345'
		linux_arm_runner: 'ubuntu-24.04-arm'
		dependent_formulae: candidates.map(it.formula)
		oldest_macos_runner: oldest
		macos_long_timeout: long_timeout
	}
}

fn runner_matrix_spec_matrix(testing []homebrew.TestRunnerFormula, deleted []string,
	dependent bool, candidates []homebrew.TestRunnerFormula) homebrew.GitHubRunnerMatrix {
	return homebrew.new_github_runner_matrix(testing, deleted, runner_matrix_spec_options(dependent, candidates, 1, 'sonoma', false)) or { panic(err) }
}

fn runner_matrix_spec_names(matrix homebrew.GitHubRunnerMatrix, predicate string) []string {
	mut names := []string{}
	for runner in matrix.runners {
		selected := match predicate {
			'macos' { runner.macos() }
			'linux' { runner.linux() }
			'x86_64' { runner.x86_64() }
			'arm64' { runner.arm64() }
			else { runner.active }
		}
		if selected {
			names << match runner.spec {
				homebrew.LinuxRunnerSpec { runner.spec.name }
				homebrew.MacOSRunnerSpec { runner.spec.name }
			}
		}
	}
	return names
}

// Ruby let `let(:newest_supported_macos) do` at line 8.
pub fn ruby_github_runner_matrix_spec_l8_d1_newest_supported_macos() string {
	return 'tahoe:26'
}

// Ruby let `let(:testball) { setup_test_runner_formula("testball") }` at line 11.
pub fn ruby_github_runner_matrix_spec_l11_d2_testball() homebrew.TestRunnerFormula {
	return runner_matrix_spec_testball()
}

// Ruby let `let(:testball_depender) { setup_test_runner_formula("testball-depender", ["testball"]) }` at line 12.
pub fn ruby_github_runner_matrix_spec_l12_d3_testball_depender() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('', '', '', false, false)
}

// Ruby let `let(:testball_depender_linux) { setup_test_runner_formula("testball-depender-linux", ["testball", :linux]) }` at line 13.
pub fn ruby_github_runner_matrix_spec_l13_d4_testball_depender_linux() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('linux', '', '', false, false)
}

// Ruby let `let(:testball_depender_macos) { setup_test_runner_formula("testball-depender-macos", ["testball", :macos]) }` at line 14.
pub fn ruby_github_runner_matrix_spec_l14_d5_testball_depender_macos() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('macos', '', '', false, false)
}

// Ruby let `let(:testball_depender_intel) do` at line 15.
pub fn ruby_github_runner_matrix_spec_l15_d6_testball_depender_intel() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('', 'x86_64', '', false, false)
}

// Ruby let `let(:testball_depender_arm) { setup_test_runner_formula("testball-depender-arm", ["testball", { arch: :arm64 }]) }` at line 18.
pub fn ruby_github_runner_matrix_spec_l18_d7_testball_depender_arm() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('', 'arm64', '', false, false)
}

// Ruby let `let(:testball_depender_newest) do` at line 19.
pub fn ruby_github_runner_matrix_spec_l19_d8_testball_depender_newest() homebrew.TestRunnerFormula {
	return runner_matrix_spec_depender('', '', '26', false, false)
}

// Ruby it `it "is not newer than HOMEBREW_MACOS_OLDEST_SUPPORTED" do` at line 38.
pub fn ruby_github_runner_matrix_spec_l38_d9_is() bool {
	oldest := homebrew.macos_version_from_symbol('sonoma') or { return false }
	supported := homebrew.new_macos_version('14') or { return false }
	return oldest.compare(supported) <= 0
}

// Ruby it `it "returns an object that responds to `#to_json`" do` at line 45.
pub fn ruby_github_runner_matrix_spec_l45_d10_returns() bool {
	matrix := runner_matrix_spec_matrix([], ['deleted'], false, [])
	return homebrew.github_runner_matrix_active_specs(matrix).len > 0
}

// Ruby it `it "uses unprivileged Linux containers" do` at line 53.
pub fn ruby_github_runner_matrix_spec_l53_d11_uses() bool {
	matrix := runner_matrix_spec_matrix([], ['deleted'], false, [])
	containers := homebrew.github_runner_matrix_active_specs(matrix).filter('container' in it).map(it['container'])
	return containers.len == 2 && containers.all(it.attributes['image'] == 'ghcr.io/homebrew/brew:main' && it.attributes['options'] == '--init --user linuxbrew')
}

// Ruby it `it "is idempotent" do` at line 68.
pub fn ruby_github_runner_matrix_spec_l68_d12_is() bool {
	mut matrix := runner_matrix_spec_matrix([], [], false, [])
	before := runner_matrix_spec_names(matrix, 'all')
	homebrew.github_runner_matrix_generate_runners(mut matrix) or { return false }
	return runner_matrix_spec_names(matrix, 'all') == before
}

// Ruby it `it "activates no test runners" do` at line 78.
pub fn ruby_github_runner_matrix_spec_l78_d13_activates() bool {
	return !runner_matrix_spec_matrix([], [], false, []).runners.any(it.active)
}

// Ruby it `it "activates no dependent runners" do` at line 83.
pub fn ruby_github_runner_matrix_spec_l83_d14_activates() bool {
	return !runner_matrix_spec_matrix([], [], true, []).runners.any(it.active)
}

// Ruby it `it "activates all runners" do` at line 90.
pub fn ruby_github_runner_matrix_spec_l90_d15_activates() bool {
	options := homebrew.GitHubRunnerMatrixOptions{ all_supported: true, github_run_id: '12345' }
	matrix := homebrew.new_github_runner_matrix([], [], options) or { return false }
	return matrix.runners.all(it.active)
}

// Ruby it `it "activates all runners" do` at line 99.
pub fn ruby_github_runner_matrix_spec_l99_d16_activates() bool {
	matrix := runner_matrix_spec_matrix([runner_matrix_spec_testball()], [], false, [])
	return matrix.runners.all(it.active)
}

// Ruby it `it "activates only the Linux runners" do` at line 108.
pub fn ruby_github_runner_matrix_spec_l108_d17_activates() bool {
	matrix := runner_matrix_spec_matrix([
		runner_matrix_spec_depender('linux', '', '', false, false),
	], [], false, [])
	return runner_matrix_spec_names(matrix, 'active') == ['Linux arm64', 'Linux x86_64']
}

// Ruby it `it "activates only the macOS runners" do` at line 120.
pub fn ruby_github_runner_matrix_spec_l120_d18_activates() bool {
	matrix := runner_matrix_spec_matrix([
		runner_matrix_spec_depender('macos', '', '', false, false),
	], [], false, [])
	return runner_matrix_spec_names(matrix, 'active') == runner_matrix_spec_names(matrix, 'macos')
}

// Ruby it `it "activates only the Intel runners" do` at line 132.
pub fn ruby_github_runner_matrix_spec_l132_d19_activates() bool {
	matrix := runner_matrix_spec_matrix([
		runner_matrix_spec_depender('', 'x86_64', '', false, false),
	], [], false, [])
	return runner_matrix_spec_names(matrix, 'active') == runner_matrix_spec_names(matrix, 'x86_64')
}

// Ruby it `it "activates only the ARM runners" do` at line 144.
pub fn ruby_github_runner_matrix_spec_l144_d20_activates() bool {
	matrix := runner_matrix_spec_matrix([
		runner_matrix_spec_depender('', 'arm64', '', false, false),
	], [], false, [])
	return runner_matrix_spec_names(matrix, 'active') == runner_matrix_spec_names(matrix, 'arm64')
}

// Ruby it `it "activates only the suitable macOS runners" do` at line 156.
pub fn ruby_github_runner_matrix_spec_l156_d21_activates() bool {
	matrix := runner_matrix_spec_matrix([
		runner_matrix_spec_depender('', '', '26', false, false),
	], [], false, [])
	return runner_matrix_spec_names(matrix, 'active') == ['macOS 26-arm64']
}

// Ruby it `it "activates no runners" do` at line 171.
pub fn ruby_github_runner_matrix_spec_l171_d22_activates() bool {
	testball := runner_matrix_spec_testball()
	return !runner_matrix_spec_matrix([testball], [], true, [testball]).runners.any(it.active)
}

// Ruby it `it "activates all runners" do` at line 183.
pub fn ruby_github_runner_matrix_spec_l183_d23_activates() bool {
	testball := runner_matrix_spec_testball()
	depender := runner_matrix_spec_depender('', '', '', false, false)
	return runner_matrix_spec_matrix([testball], [], true, [testball, depender]).runners.all(it.active)
}

// Ruby it `it "splits active runners into shards" do` at line 192.
pub fn ruby_github_runner_matrix_spec_l192_d24_splits() bool {
	testball := runner_matrix_spec_testball()
	depender := runner_matrix_spec_depender('', '', '', false, false)
	options := runner_matrix_spec_options(true, [testball, depender], 2, 'tahoe', true)
	matrix := homebrew.new_github_runner_matrix([testball], [], options) or { return false }
	specs := homebrew.github_runner_matrix_active_specs(matrix)
	return specs.map(it['formulae_dependents_shard'].as_string()) == ['1/2', '2/2', '1/2', '2/2',
		'1/2', '2/2'] && specs.map(it['runner'].as_string()) == ['ubuntu-24.04-arm',
		'ubuntu-24.04-arm', 'ubuntu-latest', 'ubuntu-latest', '26-arm64-12345-deps1-long',
		'26-arm64-12345-deps2-long']
}

// Ruby it `it "activates only Linux runners" do` at line 224.
pub fn ruby_github_runner_matrix_spec_l224_d25_activates() bool {
	return runner_matrix_spec_dependent_names(runner_matrix_spec_depender('linux', '', '', false, false), 'linux')
}

// Ruby it `it "activates only macOS runners" do` at line 235.
pub fn ruby_github_runner_matrix_spec_l235_d26_activates() bool {
	return runner_matrix_spec_dependent_names(runner_matrix_spec_depender('macos', '', '', false, false), 'macos')
}

// Ruby it `it "activates only Intel runners" do` at line 246.
pub fn ruby_github_runner_matrix_spec_l246_d27_activates() bool {
	return runner_matrix_spec_dependent_names(runner_matrix_spec_depender('', 'x86_64', '', false, false), 'x86_64')
}

// Ruby it `it "activates only ARM runners" do` at line 257.
pub fn ruby_github_runner_matrix_spec_l257_d28_activates() bool {
	return runner_matrix_spec_dependent_names(runner_matrix_spec_depender('', 'arm64', '', false, false), 'arm64')
}

// Ruby it `it "activates no runners" do` at line 268.
pub fn ruby_github_runner_matrix_spec_l268_d29_activates() bool {
	testball := runner_matrix_spec_testball()
	dependent := runner_matrix_spec_depender('', '', '', true, false)
	return !runner_matrix_spec_matrix([testball], [], true, [testball, dependent]).runners.any(it.active)
}

// Ruby it `it "activates no runners" do` at line 281.
pub fn ruby_github_runner_matrix_spec_l281_d30_activates() bool {
	testball := runner_matrix_spec_testball()
	dependent := runner_matrix_spec_depender('', '', '', false, true)
	return !runner_matrix_spec_matrix([testball], [], true, [testball, dependent]).runners.any(it.active)
}

// Ruby it `it "activates all runners" do` at line 298.
pub fn ruby_github_runner_matrix_spec_l298_d31_activates() bool {
	return runner_matrix_spec_matrix([], ['deleted'], false, []).runners.all(it.active)
}

// Ruby it `it "activates no runners" do` at line 308.
pub fn ruby_github_runner_matrix_spec_l308_d32_activates() bool {
	return !runner_matrix_spec_matrix([], ['deleted'], true, []).runners.any(it.active)
}

// Ruby it `it "activates no runners" do` at line 317.
pub fn ruby_github_runner_matrix_spec_l317_d33_activates() bool {
	testball := runner_matrix_spec_testball()
	return !runner_matrix_spec_matrix([testball], ['deleted'], true, [testball]).runners.any(it.active)
}

// Ruby it `it "activates the applicable runners" do` at line 331.
pub fn ruby_github_runner_matrix_spec_l331_d34_activates() bool {
	testball := runner_matrix_spec_testball()
	dependent := runner_matrix_spec_depender('', '', '', false, false)
	return runner_matrix_spec_matrix([testball], ['deleted'], true, [testball, dependent]).runners.all(it.active)
}

// Ruby it `it "activates the applicable runners" do` at line 344.
pub fn ruby_github_runner_matrix_spec_l344_d35_activates() bool {
	testball := runner_matrix_spec_testball()
	dependent := runner_matrix_spec_depender('linux', '', '', false, false)
	matrix := runner_matrix_spec_matrix([testball], ['deleted'], true, [testball, dependent])
	return runner_matrix_spec_names(matrix, 'active') == ['Linux arm64', 'Linux x86_64']
}

// Ruby it `it "activates the applicable runners" do` at line 357.
pub fn ruby_github_runner_matrix_spec_l357_d36_activates() bool {
	testball := runner_matrix_spec_testball()
	dependent := runner_matrix_spec_depender('macos', '', '', false, false)
	matrix := runner_matrix_spec_matrix([testball], ['deleted'], true, [testball, dependent])
	return runner_matrix_spec_names(matrix, 'active') == runner_matrix_spec_names(matrix, 'macos')
}

// Ruby method `get_runner_names(runner_matrix, predicate = :active)` at line 369.
pub fn ruby_github_runner_matrix_spec_l369_d37_get_runner_names(matrix homebrew.GitHubRunnerMatrix,
	predicate string) []string {
	return runner_matrix_spec_names(matrix, predicate)
}

// Ruby method `setup_test_runner_formula(name, dependencies = [], **kwargs)` at line 375.
pub fn ruby_github_runner_matrix_spec_l375_d38_setup_test_runner_formula(name string,
	dependency string, platform string, arch string, macos_version string) homebrew.TestRunnerFormula {
	return runner_matrix_spec_formula(name, dependency, platform, arch, macos_version, false, false)
}

fn runner_matrix_spec_dependent_names(dependent homebrew.TestRunnerFormula,
	predicate string) bool {
	testball := runner_matrix_spec_testball()
	matrix := runner_matrix_spec_matrix([testball], [], true, [testball, dependent])
	return runner_matrix_spec_names(matrix, 'active') == runner_matrix_spec_names(matrix, predicate)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "github_runner_matrix"
// 5: require "test/support/fixtures/testball"
// 6:
// 7: RSpec.describe GitHubRunnerMatrix, :no_api do
// 8:   let(:newest_supported_macos) do
// 9:     MacOSVersion::SYMBOLS.find { |k, _| k == GitHubRunnerMatrix::NEWEST_HOMEBREW_CORE_MACOS_RUNNER }
// 10:   end
// 11:   let(:testball) { setup_test_runner_formula("testball") }
// 12:   let(:testball_depender) { setup_test_runner_formula("testball-depender", ["testball"]) }
// 13:   let(:testball_depender_linux) { setup_test_runner_formula("testball-depender-linux", ["testball", :linux]) }
// 14:   let(:testball_depender_macos) { setup_test_runner_formula("testball-depender-macos", ["testball", :macos]) }
// 15:   let(:testball_depender_intel) do
// 16:     setup_test_runner_formula("testball-depender-intel", ["testball", { arch: :x86_64 }])
// 17:   end
// 18:   let(:testball_depender_arm) { setup_test_runner_formula("testball-depender-arm", ["testball", { arch: :arm64 }]) }
// 19:   let(:testball_depender_newest) do
// 20:     symbol, = newest_supported_macos
// 21:     setup_test_runner_formula("testball-depender-newest", ["testball", { macos: symbol }])
// 22:   end
// 23:
// 24:   before do
// 25:     allow(ENV).to receive(:fetch).and_call_original
// 26:     allow(ENV).to receive(:fetch).with("HOMEBREW_LINUX_SELF_HOSTED", "false").and_return("false")
// 27:     allow(ENV).to receive(:fetch).with("HOMEBREW_MACOS_LONG_TIMEOUT", "false").and_return("false")
// 28:     allow(ENV).to receive(:fetch).with("HOMEBREW_MACOS_BUILD_ON_GITHUB_RUNNER", "false").and_return("false")
// 29:     allow(ENV).to receive(:fetch).with("GITHUB_RUN_ID").and_return("12345")
// 30:     allow(ENV).to receive(:fetch).with("HOMEBREW_EVAL_ALL", nil).and_call_original
// 31:     allow(ENV).to receive(:fetch).with("HOMEBREW_SIMULATE_MACOS_ON_LINUX", nil).and_call_original
// 32:     allow(ENV).to receive(:fetch).with("HOMEBREW_FORBID_PACKAGES_FROM_PATHS", nil).and_call_original
// 33:     allow(ENV).to receive(:fetch).with("HOMEBREW_DEVELOPER", nil).and_call_original
// 34:     allow(ENV).to receive(:fetch).with("HOMEBREW_NO_INSTALL_FROM_API", nil).and_call_original
// 35:   end
// 36:
// 37:   describe "OLDEST_HOMEBREW_CORE_MACOS_RUNNER" do
// 38:     it "is not newer than HOMEBREW_MACOS_OLDEST_SUPPORTED" do
// 39:       oldest_macos_runner = MacOSVersion.from_symbol(GitHubRunnerMatrix::OLDEST_HOMEBREW_CORE_MACOS_RUNNER)
// 40:       expect(oldest_macos_runner).to be <= HOMEBREW_MACOS_OLDEST_SUPPORTED
// 41:     end
// 42:   end
// 43:
// 44:   describe "#active_runner_specs_hash" do
// 45:     it "returns an object that responds to `#to_json`" do
// 46:       expect(
// 47:         described_class.new([], ["deleted"], all_supported: false, dependent_matrix: false)
// 48:                        .active_runner_specs_hash
// 49:                        .respond_to?(:to_json),
// 50:       ).to be(true)
// 51:     end
// 52:
// 53:     it "uses unprivileged Linux containers" do
// 54:       linux_containers = described_class.new([], ["deleted"], all_supported: false, dependent_matrix: false)
// 55:                                         .active_runner_specs_hash
// 56:                                         .filter_map { |runner| runner[:container] }
// 57:
// 58:       expect(linux_containers).to eq(Array.new(2) do
// 59:         {
// 60:           image:   "ghcr.io/homebrew/brew:main",
// 61:           options: "--init --user linuxbrew",
// 62:         }
// 63:       end)
// 64:     end
// 65:   end
// 66:
// 67:   describe "#generate_runners!" do
// 68:     it "is idempotent" do
// 69:       matrix = described_class.new([], [], all_supported: false, dependent_matrix: false)
// 70:       runners = matrix.runners.dup
// 71:       matrix.generate_runners!
// 72:
// 73:       expect(matrix.runners).to eq(runners)
// 74:     end
// 75:   end
// 76:
// 77:   context "when there are no testing formulae and no deleted formulae" do
// 78:     it "activates no test runners" do
// 79:       expect(described_class.new([], [], all_supported: false, dependent_matrix: false).runners.any?(&:active))
// 80:         .to be(false)
// 81:     end
// 82:
// 83:     it "activates no dependent runners" do
// 84:       expect(described_class.new([], [], all_supported: false, dependent_matrix: true).runners.any?(&:active))
// 85:         .to be(false)
// 86:     end
// 87:   end
// 88:
// 89:   context "when passed `--all-supported`" do
// 90:     it "activates all runners" do
// 91:       expect(described_class.new([], [], all_supported: true, dependent_matrix: false).runners.all?(&:active))
// 92:         .to be(true)
// 93:     end
// 94:   end
// 95:
// 96:   context "when there are testing formulae and no deleted formulae" do
// 97:     context "when it is a matrix for the `tests` job" do
// 98:       context "when testing formulae have no requirements" do
// 99:         it "activates all runners" do
// 100:           expect(described_class.new([testball], [], all_supported: false, dependent_matrix: false)
// 101:                                 .runners
// 102:                                 .all?(&:active))
// 103:             .to be(true)
// 104:         end
// 105:       end
// 106:
// 107:       context "when testing formulae require Linux" do
// 108:         it "activates only the Linux runners" do
// 109:           runner_matrix = described_class.new([testball_depender_linux], [],
// 110:                                               all_supported:    false,
// 111:                                               dependent_matrix: false)
// 112:
// 113:           expect(runner_matrix.runners.all?(&:active)).to be(false)
// 114:           expect(runner_matrix.runners.any?(&:active)).to be(true)
// 115:           expect(get_runner_names(runner_matrix)).to eq(["Linux arm64", "Linux x86_64"])
// 116:         end
// 117:       end
// 118:
// 119:       context "when testing formulae require macOS" do
// 120:         it "activates only the macOS runners" do
// 121:           runner_matrix = described_class.new([testball_depender_macos], [],
// 122:                                               all_supported:    false,
// 123:                                               dependent_matrix: false)
// 124:
// 125:           expect(runner_matrix.runners.all?(&:active)).to be(false)
// 126:           expect(runner_matrix.runners.any?(&:active)).to be(true)
// 127:           expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :macos?))
// 128:         end
// 129:       end
// 130:
// 131:       context "when testing formulae require Intel" do
// 132:         it "activates only the Intel runners" do
// 133:           runner_matrix = described_class.new([testball_depender_intel], [],
// 134:                                               all_supported:    false,
// 135:                                               dependent_matrix: false)
// 136:
// 137:           expect(runner_matrix.runners.all?(&:active)).to be(false)
// 138:           expect(runner_matrix.runners.any?(&:active)).to be(true)
// 139:           expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :x86_64?))
// 140:         end
// 141:       end
// 142:
// 143:       context "when testing formulae require ARM" do
// 144:         it "activates only the ARM runners" do
// 145:           runner_matrix = described_class.new([testball_depender_arm], [],
// 146:                                               all_supported:    false,
// 147:                                               dependent_matrix: false)
// 148:
// 149:           expect(runner_matrix.runners.all?(&:active)).to be(false)
// 150:           expect(runner_matrix.runners.any?(&:active)).to be(true)
// 151:           expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :arm64?))
// 152:         end
// 153:       end
// 154:
// 155:       context "when testing formulae require a macOS version" do
// 156:         it "activates only the suitable macOS runners" do
// 157:           _, v = newest_supported_macos
// 158:           runner_matrix = described_class.new([testball_depender_newest], [],
// 159:                                               all_supported:    false,
// 160:                                               dependent_matrix: false)
// 161:
// 162:           expect(runner_matrix.runners.all?(&:active)).to be(false)
// 163:           expect(runner_matrix.runners.any?(&:active)).to be(true)
// 164:           expect(get_runner_names(runner_matrix).sort).to eq(["macOS #{v}-arm64"])
// 165:         end
// 166:       end
// 167:     end
// 168:
// 169:     context "when it is a matrix for the `test_deps` job" do
// 170:       context "when testing formulae have no dependents" do
// 171:         it "activates no runners" do
// 172:           allow(Formula).to receive(:all).and_return([testball].map(&:formula))
// 173:
// 174:           expect(described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 175:                                 .runners
// 176:                                 .any?(&:active))
// 177:             .to be(false)
// 178:         end
// 179:       end
// 180:
// 181:       context "when testing formulae have dependents" do
// 182:         context "when dependents have no requirements" do
// 183:           it "activates all runners" do
// 184:             allow(Formula).to receive(:all).and_return([testball, testball_depender].map(&:formula))
// 185:
// 186:             expect(described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 187:                                   .runners
// 188:                                   .all?(&:active))
// 189:               .to be(true)
// 190:           end
// 191:
// 192:           it "splits active runners into shards" do
// 193:             macos = GitHubRunnerMatrix::NEWEST_HOMEBREW_CORE_MACOS_RUNNER
// 194:             macos_version = MacOSVersion.from_symbol(macos)
// 195:             stub_const("GitHubRunnerMatrix::OLDEST_HOMEBREW_CORE_MACOS_RUNNER", macos)
// 196:             stub_const("OS::LINUX_CI_ARM_RUNNER", "ubuntu-24.04-arm")
// 197:
// 198:             allow(ENV).to receive(:fetch).with("HOMEBREW_MACOS_LONG_TIMEOUT", "false").and_return("true")
// 199:             allow(ENV).to receive(:key?).and_call_original
// 200:             allow(ENV).to receive(:key?).with("GITHUB_ACTIONS").and_return(true)
// 201:             allow(Formula).to receive(:all).and_return([testball, testball_depender].map(&:formula))
// 202:
// 203:             runners = described_class.new([testball], [],
// 204:                                           all_supported:    false,
// 205:                                           dependent_matrix: true,
// 206:                                           dependent_shards: 2)
// 207:                                      .active_runner_specs_hash
// 208:
// 209:             expect(runners).to all(include(:formulae_dependents_shard))
// 210:             expect(runners.map { |runner| runner.fetch(:formulae_dependents_shard) }.uniq).to eq(["1/2", "2/2"])
// 211:             expect(runners.map { |runner| runner.fetch(:name) }).to all(match(%r{ shard [12]/2\z}))
// 212:             expect(runners.map { |runner| runner.fetch(:runner) }).to eq([
// 213:               "ubuntu-24.04-arm",
// 214:               "ubuntu-24.04-arm",
// 215:               "ubuntu-latest",
// 216:               "ubuntu-latest",
// 217:               "#{macos_version}-arm64-12345-deps1-long",
// 218:               "#{macos_version}-arm64-12345-deps2-long",
// 219:             ])
// 220:           end
// 221:         end
// 222:
// 223:         context "when dependents require Linux" do
// 224:           it "activates only Linux runners" do
// 225:             allow(Formula).to receive(:all).and_return([testball, testball_depender_linux].map(&:formula))
// 226:
// 227:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 228:             expect(runner_matrix.runners.all?(&:active)).to be(false)
// 229:             expect(runner_matrix.runners.any?(&:active)).to be(true)
// 230:             expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :linux?))
// 231:           end
// 232:         end
// 233:
// 234:         context "when dependents require macOS" do
// 235:           it "activates only macOS runners" do
// 236:             allow(Formula).to receive(:all).and_return([testball, testball_depender_macos].map(&:formula))
// 237:
// 238:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 239:             expect(runner_matrix.runners.all?(&:active)).to be(false)
// 240:             expect(runner_matrix.runners.any?(&:active)).to be(true)
// 241:             expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :macos?))
// 242:           end
// 243:         end
// 244:
// 245:         context "when dependents require an Intel architecture" do
// 246:           it "activates only Intel runners" do
// 247:             allow(Formula).to receive(:all).and_return([testball, testball_depender_intel].map(&:formula))
// 248:
// 249:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 250:             expect(runner_matrix.runners.all?(&:active)).to be(false)
// 251:             expect(runner_matrix.runners.any?(&:active)).to be(true)
// 252:             expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :x86_64?))
// 253:           end
// 254:         end
// 255:
// 256:         context "when dependents require an ARM architecture" do
// 257:           it "activates only ARM runners" do
// 258:             allow(Formula).to receive(:all).and_return([testball, testball_depender_arm].map(&:formula))
// 259:
// 260:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 261:             expect(runner_matrix.runners.all?(&:active)).to be(false)
// 262:             expect(runner_matrix.runners.any?(&:active)).to be(true)
// 263:             expect(get_runner_names(runner_matrix)).to eq(get_runner_names(runner_matrix, :arm64?))
// 264:           end
// 265:         end
// 266:
// 267:         context "when dependents are disabled" do
// 268:           it "activates no runners" do
// 269:             testball_depender_disabled = setup_test_runner_formula("testball-depender-disabled", ["testball"])
// 270:
// 271:             disabled_formula = testball_depender_disabled.formula
// 272:             allow(disabled_formula).to receive(:disabled?).and_return(true)
// 273:             allow(Formula).to receive(:all).and_return([testball.formula, disabled_formula])
// 274:
// 275:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 276:             expect(runner_matrix.runners.any?(&:active)).to be(false)
// 277:           end
// 278:         end
// 279:
// 280:         context "when dependents are deprecated" do
// 281:           it "activates no runners" do
// 282:             testball_depender_deprecated = setup_test_runner_formula("testball-depender-deprecated", ["testball"])
// 283:
// 284:             deprecated_formula = testball_depender_deprecated.formula
// 285:             allow(deprecated_formula).to receive(:deprecated?).and_return(true)
// 286:             allow(Formula).to receive(:all).and_return([testball.formula, deprecated_formula])
// 287:
// 288:             runner_matrix = described_class.new([testball], [], all_supported: false, dependent_matrix: true)
// 289:             expect(runner_matrix.runners.any?(&:active)).to be(false)
// 290:           end
// 291:         end
// 292:       end
// 293:     end
// 294:   end
// 295:
// 296:   context "when there are deleted formulae" do
// 297:     context "when it is a matrix for the `tests` job" do
// 298:       it "activates all runners" do
// 299:         expect(described_class.new([], ["deleted"], all_supported: false, dependent_matrix: false)
// 300:                               .runners
// 301:                               .all?(&:active))
// 302:           .to be(true)
// 303:       end
// 304:     end
// 305:
// 306:     context "when it is a matrix for the `test_deps` job" do
// 307:       context "when there are no testing formulae" do
// 308:         it "activates no runners" do
// 309:           expect(described_class.new([], ["deleted"], all_supported: false, dependent_matrix: true)
// 310:                                 .runners
// 311:                                 .any?(&:active))
// 312:             .to be(false)
// 313:         end
// 314:       end
// 315:
// 316:       context "when there are testing formulae with no dependents" do
// 317:         it "activates no runners" do
// 318:           testing_formulae = [testball]
// 319:           runner_matrix = described_class.new(testing_formulae, ["deleted"],
// 320:                                               all_supported:    false,
// 321:                                               dependent_matrix: true)
// 322:
// 323:           allow(Formula).to receive(:all).and_return(testing_formulae.map(&:formula))
// 324:
// 325:           expect(runner_matrix.runners.none?(&:active)).to be(true)
// 326:         end
// 327:       end
// 328:
// 329:       context "when there are testing formulae with dependents" do
// 330:         context "when dependent formulae have no requirements" do
// 331:           it "activates the applicable runners" do
// 332:             allow(Formula).to receive(:all).and_return([testball, testball_depender].map(&:formula))
// 333:
// 334:             testing_formulae = [testball]
// 335:             expect(described_class.new(testing_formulae, ["deleted"], all_supported: false, dependent_matrix: true)
// 336:                                   .runners
// 337:                                   .all?(&:active))
// 338:               .to be(true)
// 339:           end
// 340:         end
// 341:
// 342:         context "when dependent formulae have requirements" do
// 343:           context "when dependent formulae require Linux" do
// 344:             it "activates the applicable runners" do
// 345:               allow(Formula).to receive(:all).and_return([testball, testball_depender_linux].map(&:formula))
// 346:
// 347:               matrix = described_class.new([testball], ["deleted"], all_supported: false, dependent_matrix: true)
// 348:               expect(get_runner_names(matrix)).to eq(["Linux arm64", "Linux x86_64"])
// 349:
// 350:               allow(ENV).to receive(:fetch).with("HOMEBREW_LINUX_SELF_HOSTED", "false").and_return("true")
// 351:               matrix = described_class.new([testball], ["deleted"], all_supported: false, dependent_matrix: true)
// 352:               expect(get_runner_names(matrix)).to eq(["Linux arm64", "Linux x86_64"])
// 353:             end
// 354:           end
// 355:
// 356:           context "when dependent formulae require macOS" do
// 357:             it "activates the applicable runners" do
// 358:               allow(Formula).to receive(:all).and_return([testball, testball_depender_macos].map(&:formula))
// 359:
// 360:               matrix = described_class.new([testball], ["deleted"], all_supported: false, dependent_matrix: true)
// 361:               expect(get_runner_names(matrix)).to eq(get_runner_names(matrix, :macos?))
// 362:             end
// 363:           end
// 364:         end
// 365:       end
// 366:     end
// 367:   end
// 368:
// 369:   def get_runner_names(runner_matrix, predicate = :active)
// 370:     runner_matrix.runners
// 371:                  .select(&predicate)
// 372:                  .map { |runner| runner.spec.name }
// 373:   end
// 374:
// 375:   def setup_test_runner_formula(name, dependencies = [], **kwargs)
// 376:     f = formula name do
// 377:       T.bind(self, T.class_of(Formula))
// 378:       url "https://brew.sh/#{name}-1.0.tar.gz"
// 379:       dependencies.each { |dependency| depends_on dependency }
// 380:
// 381:       kwargs.each do |k, v|
// 382:         public_send(:"on_#{k}") do
// 383:           v.each do |dep|
// 384:             depends_on dep
// 385:           end
// 386:         end
// 387:       end
// 388:     end
// 389:
// 390:     stub_formula_loader f
// 391:     TestRunnerFormula.new(f, eval_all: true)
// 392:   end
// 393: end
