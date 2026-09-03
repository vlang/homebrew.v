module homebrew

import brew_runtime

// Translated from Homebrew/brew `github_runner_matrix.rb`.
// The original source is retained below until every stub has a typed V body.
const github_actions_long_timeout = 2160
const github_actions_short_timeout = 60
const github_actions_runner_timeout = 360

pub struct GitHubRunnerMatrixOptions {
pub:
	all_supported         bool
	dependent_matrix      bool
	dependent_shards      int = 1
	github_run_id         string
	linux_self_hosted     bool
	macos_long_timeout    bool
	macos_build_on_github bool
	linux_arm_runner      string = 'ubuntu-24.04-arm'
	dependent_formulae    []TestRunnerFormulaDefinition
	intel_bottle_tags     map[string][]string
	oldest_macos_runner   string = 'sonoma'
	newest_macos_runner   string = 'tahoe'
	newest_intel_runner   string = 'sonoma'
}

pub struct GitHubRunnerMatrix {
pub:
	testing_formulae []TestRunnerFormula
	deleted_formulae []string
	options          GitHubRunnerMatrixOptions
pub mut:
	runners []GitHubRunner
}

fn github_runner_spec_name(spec GitHubRunnerSpec) string {
	return match spec {
		LinuxRunnerSpec { spec.name }
		MacOSRunnerSpec { spec.name }
	}
}

fn github_runner_spec_runner(spec GitHubRunnerSpec) string {
	return match spec {
		LinuxRunnerSpec { spec.runner }
		MacOSRunnerSpec { spec.runner }
	}
}

fn github_runner_spec_formulae(spec GitHubRunnerSpec) []string {
	return match spec {
		LinuxRunnerSpec { spec.testing_formulae }
		MacOSRunnerSpec { spec.testing_formulae }
	}
}

fn github_runner_spec_with_formulae(spec GitHubRunnerSpec, formulae []string) GitHubRunnerSpec {
	return match spec {
		LinuxRunnerSpec {
			LinuxRunnerSpec{
				...spec
				testing_formulae: formulae.clone()
			}
		}
		MacOSRunnerSpec {
			MacOSRunnerSpec{
				...spec
				testing_formulae: formulae.clone()
			}
		}
	}
}

pub fn github_runner_spec_to_map(spec GitHubRunnerSpec) map[string]brew_runtime.Value {
	return match spec {
		LinuxRunnerSpec { linux_runner_spec_to_map(spec) }
		MacOSRunnerSpec { macos_runner_spec_to_map(spec) }
	}
}

pub fn new_github_runner_matrix(testing_formulae []TestRunnerFormula, deleted_formulae []string,
	options GitHubRunnerMatrixOptions) !GitHubRunnerMatrix {
	if options.all_supported && (testing_formulae.len > 0 || deleted_formulae.len > 0 || options.dependent_matrix) {
		return error('all_supported is mutually exclusive to other arguments')
	}
	mut matrix := GitHubRunnerMatrix{
		testing_formulae: testing_formulae.clone()
		deleted_formulae: deleted_formulae.clone()
		options: options
	}
	github_runner_matrix_generate_runners(mut matrix)!
	return matrix
}

pub fn github_runner_matrix_active_specs(matrix GitHubRunnerMatrix) []map[string]brew_runtime.Value {
	mut specs := []map[string]brew_runtime.Value{}
	for runner in matrix.runners {
		if runner.active {
			specs << github_runner_spec_to_map(runner.spec)
		}
	}
	shards := if matrix.options.dependent_shards > 0 { matrix.options.dependent_shards } else { 1 }
	if !matrix.options.dependent_matrix || shards == 1 {
		return specs
	}
	mut sharded := []map[string]brew_runtime.Value{}
	for spec in specs {
		for shard in 1 .. shards + 1 {
			mut entry := spec.clone()
			name := spec['name'].as_string()
			runner := spec['runner'].as_string()
			entry['name'] = brew_runtime.string_value('${name} shard ${shard}/${shards}')
			entry['runner'] = brew_runtime.string_value(runner.replace_once('-deps', '-deps${shard}'))
			entry['formulae_dependents_shard'] = brew_runtime.string_value('${shard}/${shards}')
			sharded << entry
		}
	}
	return sharded
}

pub fn github_runner_matrix_ephemeral_suffix(matrix GitHubRunnerMatrix) string {
	mut suffix := '-${matrix.options.github_run_id}'
	if matrix.options.dependent_matrix {
		suffix += '-deps'
	}
	if matrix.options.macos_long_timeout {
		suffix += '-long'
	}
	return suffix
}

pub fn github_runner_matrix_linux_spec(matrix GitHubRunnerMatrix, arch string,
	self_hosted bool) !LinuxRunnerSpec {
	suffix := github_runner_matrix_ephemeral_suffix(matrix)
	linux_runner := match arch {
		'arm64' {
			if self_hosted { 'linux-arm64${suffix}' } else { matrix.options.linux_arm_runner }
		}
		'x86_64' {
			if self_hosted { 'linux-x86_64${suffix}' } else { 'ubuntu-latest' }
		}
		else {
			return error('Unknown Linux architecture: ${arch}')
		}
	}
	return LinuxRunnerSpec{
		name: 'Linux ${arch}'
		runner: linux_runner
		container: if self_hosted {
			none} else {
			LinuxRunnerContainer{
				image: 'ghcr.io/homebrew/brew:main'
				options: '--init --user linuxbrew'
			}}
		workdir: if self_hosted { '' } else { '/github/home' }
		timeout: github_actions_long_timeout
		cleanup: false
	}
}

pub fn github_runner_matrix_runner_enabled(macos_version string, oldest_symbol string,
	newest_symbol string) bool {
	version := new_macos_version(macos_version) or { return false }
	oldest := macos_version_from_symbol(oldest_symbol) or { return false }
	newest := macos_version_from_symbol(newest_symbol) or { return false }
	return version.compare(oldest) >= 0 && version.compare(newest) <= 0
}

pub fn github_runner_matrix_compatible_formulae(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []TestRunnerFormula {
	mut result := []TestRunnerFormula{}
	for formula in matrix.testing_formulae {
		if runner.macos_version != '' && !formula.compatible_with(runner.macos_version) {
			continue
		}
		if runner.macos() && !formula.macos_compatible() {
			continue
		}
		if runner.linux() && !formula.linux_compatible() {
			continue
		}
		if runner.arm64() && !formula.arm64_compatible() {
			continue
		}
		if runner.x86_64() && !formula.x86_64_compatible() {
			continue
		}
		result << formula
	}
	return result
}

pub fn github_runner_matrix_formulae_with_untested_dependents(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []TestRunnerFormula {
	mut result := []TestRunnerFormula{}
	testing_names := matrix.testing_formulae.map(it.name)
	for formula in github_runner_matrix_compatible_formulae(matrix, runner) {
		system := TestRunnerSystem{
			platform: runner.platform
			arch: runner.arch
			macos_version: if runner.macos_version == '' {
				''} else {
				(new_macos_version(runner.macos_version) or { null_macos_version() }).to_symbol()}
		}
		dependents := formula.dependents(matrix.options.dependent_formulae, system)
		mut has_untested := false
		for dependent in dependents {
			if runner.macos_version != '' && !dependent.compatible_with(runner.macos_version) {
				continue
			}
			if runner.macos() && !dependent.macos_compatible() {
				continue
			}
			if runner.linux() && !dependent.linux_compatible() {
				continue
			}
			if runner.arm64() && !dependent.arm64_compatible() {
				continue
			}
			if runner.x86_64() && !dependent.x86_64_compatible() {
				continue
			}
			if dependent.formula.disabled || dependent.formula.deprecated {
				continue
			}
			if dependent.name !in testing_names {
				has_untested = true
				break
			}
		}
		if has_untested {
			result << formula
		}
	}
	return result
}

pub fn github_runner_matrix_testable_formulae(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []string {
	formulae := if matrix.options.dependent_matrix {
		github_runner_matrix_formulae_with_untested_dependents(matrix, runner)
	} else {
		github_runner_matrix_compatible_formulae(matrix, runner)
	}
	return formulae.map(it.name)
}

pub fn github_runner_matrix_active_runner(matrix GitHubRunnerMatrix, runner GitHubRunner) bool {
	return matrix.options.all_supported || (matrix.deleted_formulae.len > 0 && !matrix.options.dependent_matrix) || github_runner_spec_formulae(runner.spec).len > 0
}

pub fn github_runner_matrix_create_runner(matrix GitHubRunnerMatrix, platform string, arch string,
	spec GitHubRunnerSpec, macos_version string) !GitHubRunner {
	if platform !in ['macos', 'linux'] {
		return error('Unexpected platform: ${platform}')
	}
	if arch !in ['arm64', 'x86_64'] {
		return error('Unexpected arch: ${arch}')
	}
	mut runner := new_github_runner(platform, arch, spec, macos_version)
	formulae := github_runner_matrix_testable_formulae(matrix, runner)
	runner = GitHubRunner{
		...runner
		spec: github_runner_spec_with_formulae(spec, formulae)
	}
	runner.active = github_runner_matrix_active_runner(matrix, runner)
	return runner
}

pub fn github_runner_matrix_generate_runners(mut matrix GitHubRunnerMatrix) ! {
	if matrix.runners.len > 0 {
		return
	}
	if !matrix.options.all_supported || matrix.options.linux_self_hosted {
		for arch in ['arm64', 'x86_64'] {
			spec := github_runner_matrix_linux_spec(matrix, arch, matrix.options.linux_self_hosted)!
			matrix.runners << github_runner_matrix_create_runner(matrix, 'linux', arch, spec, '')!
		}
	}
	if matrix.testing_formulae.any(it.name.starts_with('portable-')) {
		cross_specs := [
			GitHubRunner{
				platform: 'macos'
				arch: 'x86_64'
				spec: MacOSRunnerSpec{ name: 'macOS 10.15-cross x86_64', runner: '10.15-cross-${matrix.options.github_run_id}', timeout: github_actions_long_timeout, cleanup: true }
				macos_version: '10.15'
			},
			GitHubRunner{
				platform: 'macos'
				arch: 'arm64'
				spec: MacOSRunnerSpec{ name: 'macOS 11-cross arm64', runner: '11-arm64-cross-${matrix.options.github_run_id}', timeout: github_actions_long_timeout, cleanup: true }
				macos_version: '11'
			},
		]
		for candidate in cross_specs {
			matrix.runners << github_runner_matrix_create_runner(matrix, candidate.platform, candidate.arch, candidate.spec, candidate.macos_version)!
		}
		return
	}
	runner_timeout := if matrix.options.macos_long_timeout {
		github_actions_long_timeout
	} else {
		github_actions_short_timeout
	}
	mut use_github_runner := matrix.options.macos_build_on_github || matrix.options.dependent_matrix
	use_github_runner = use_github_runner && runner_timeout <= github_actions_runner_timeout
	for symbol in ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur',
		'catalina'] {
		macos := macos_version_from_symbol(symbol) or { continue }
		version := macos.str()
		if !github_runner_matrix_runner_enabled(version, matrix.options.oldest_macos_runner, matrix.options.newest_macos_runner) {
			continue
		}
		arm_github_available := symbol in ['sonoma', 'sequoia', 'tahoe']
		mut arm_runner := ''
		mut arm_timeout := runner_timeout
		if use_github_runner && arm_github_available {
			arm_runner = 'macos-${version}'
			arm_timeout = github_actions_runner_timeout
		} else {
			arm_runner = '${version}-arm64${github_runner_matrix_ephemeral_suffix(matrix)}'
		}
		if matrix.options.dependent_matrix && arm_timeout < github_actions_runner_timeout {
			arm_timeout *= 2
		}
		arm_spec := MacOSRunnerSpec{
			name: 'macOS ${version}-arm64'
			runner: arm_runner
			timeout: arm_timeout
			cleanup: !arm_runner.ends_with(github_runner_matrix_ephemeral_suffix(matrix))
		}
		matrix.runners << github_runner_matrix_create_runner(matrix, 'macos', 'arm64', arm_spec, version)!

		mut skip_intel := !matrix.options.all_supported && macos.compare_symbol(matrix.options.newest_intel_runner) > 0
		if skip_intel && !matrix.options.dependent_matrix {
			skip_intel = true
			for formula in matrix.testing_formulae {
				tags := matrix.options.intel_bottle_tags[formula.name] or { []string{} }
				if symbol in tags && 'all' !in tags {
					skip_intel = false
					break
				}
			}
		}
		if skip_intel {
			continue
		}
		intel_github_available := symbol == 'ventura'
		mut intel_runner := ''
		mut intel_timeout := runner_timeout
		if use_github_runner && intel_github_available {
			intel_runner = 'macos-${version}'
			intel_timeout = github_actions_runner_timeout
		} else {
			intel_runner = '${version}-x86_64${github_runner_matrix_ephemeral_suffix(matrix)}'
		}
		if macos.compare_symbol('monterey') <= 0 {
			intel_timeout += 30
		}
		if !(use_github_runner && intel_github_available) && intel_timeout < github_actions_long_timeout {
			intel_timeout *= 2
		}
		intel_spec := MacOSRunnerSpec{
			name: 'macOS ${version}-x86_64'
			runner: intel_runner
			timeout: intel_timeout
			cleanup: !intel_runner.ends_with(github_runner_matrix_ephemeral_suffix(matrix))
		}
		matrix.runners << github_runner_matrix_create_runner(matrix, 'macos', 'x86_64', intel_spec, version)!
	}
}

// Ruby attr_reader `attr_reader :runners` at line 22.
pub fn ruby_github_runner_matrix_l22_d1_runners(matrix GitHubRunnerMatrix) []GitHubRunner {
	return matrix.runners
}

// Ruby method `initialize(testing_formulae, deleted_formulae, all_supported:, dependent_matrix:, dependent_shards: nil)` at line 33.
pub fn ruby_github_runner_matrix_l33_d2_initialize(testing_formulae []TestRunnerFormula,
	deleted_formulae []string, options GitHubRunnerMatrixOptions) !GitHubRunnerMatrix {
	return new_github_runner_matrix(testing_formulae, deleted_formulae, options)
}

// Ruby method `active_runner_specs_hash` at line 70.
pub fn ruby_github_runner_matrix_l70_d3_active_runner_specs_hash(matrix GitHubRunnerMatrix) []map[string]brew_runtime.Value {
	return github_runner_matrix_active_specs(matrix)
}

// Ruby method `generate_runners!` at line 88.
pub fn ruby_github_runner_matrix_l88_d4_generate_runners(mut matrix GitHubRunnerMatrix) ! {
	github_runner_matrix_generate_runners(mut matrix)!
}

// Ruby method `linux_runner_spec(arch, self_hosted:)` at line 192.
pub fn ruby_github_runner_matrix_l192_d5_linux_runner_spec(matrix GitHubRunnerMatrix, arch string,
	self_hosted bool) !LinuxRunnerSpec {
	return github_runner_matrix_linux_spec(matrix, arch, self_hosted)
}

// Ruby method `create_runner(platform, arch, spec, macos_version = nil)` at line 229.
pub fn ruby_github_runner_matrix_l229_d6_create_runner(matrix GitHubRunnerMatrix, platform string,
	arch string, spec GitHubRunnerSpec, macos_version string) !GitHubRunner {
	return github_runner_matrix_create_runner(matrix, platform, arch, spec, macos_version)
}

// Ruby method `runner_enabled?(macos_version)` at line 240.
pub fn ruby_github_runner_matrix_l240_d7_runner_enabled(matrix GitHubRunnerMatrix,
	macos_version string) bool {
	return github_runner_matrix_runner_enabled(macos_version, matrix.options.oldest_macos_runner, matrix.options.newest_macos_runner)
}

// Ruby method `ephemeral_suffix` at line 245.
pub fn ruby_github_runner_matrix_l245_d8_ephemeral_suffix(matrix GitHubRunnerMatrix) string {
	return github_runner_matrix_ephemeral_suffix(matrix)
}

// Ruby method `testable_formulae(runner)` at line 264.
pub fn ruby_github_runner_matrix_l264_d9_testable_formulae(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []string {
	return github_runner_matrix_testable_formulae(matrix, runner)
}

// Ruby method `active_runner?(runner)` at line 275.
pub fn ruby_github_runner_matrix_l275_d10_active_runner(matrix GitHubRunnerMatrix,
	runner GitHubRunner) bool {
	return github_runner_matrix_active_runner(matrix, runner)
}

// Ruby method `compatible_testing_formulae(runner)` at line 283.
pub fn ruby_github_runner_matrix_l283_d11_compatible_testing_formulae(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []TestRunnerFormula {
	return github_runner_matrix_compatible_formulae(matrix, runner)
}

// Ruby method `formulae_with_untested_dependents(runner)` at line 302.
pub fn ruby_github_runner_matrix_l302_d12_formulae_with_untested_dependents(matrix GitHubRunnerMatrix,
	runner GitHubRunner) []TestRunnerFormula {
	return github_runner_matrix_formulae_with_untested_dependents(matrix, runner)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_runner_formula"
// 5: require "github_runner"
// 6:
// 7: class GitHubRunnerMatrix
// 8:   # When bumping newest runner, run e.g. `git log -p --reverse -G "sha256 tahoe"`
// 9:   # on homebrew/core and tag the first commit with a bottle e.g.
// 10:   # `git tag 15-sequoia f42c4a659e4da887fc714f8f41cc26794a4bb320`
// 11:   # to allow people to jump to specific commits based on their macOS version.
// 12:   NEWEST_HOMEBREW_CORE_MACOS_RUNNER = :tahoe
// 13:   OLDEST_HOMEBREW_CORE_MACOS_RUNNER = :sonoma
// 14:   NEWEST_HOMEBREW_CORE_INTEL_MACOS_RUNNER = :sonoma
// 15:
// 16:   RunnerSpec = T.type_alias { T.any(LinuxRunnerSpec, MacOSRunnerSpec) }
// 17:   private_constant :RunnerSpec
// 18:
// 19:   RunnerSpecHash = T.type_alias { T::Hash[Symbol, T.untyped] }
// 20:   private_constant :RunnerSpecHash
// 21:   sig { returns(T::Array[GitHubRunner]) }
// 22:   attr_reader :runners
// 23:
// 24:   sig {
// 25:     params(
// 26:       testing_formulae: T::Array[TestRunnerFormula],
// 27:       deleted_formulae: T::Array[String],
// 28:       all_supported:    T::Boolean,
// 29:       dependent_matrix: T::Boolean,
// 30:       dependent_shards: T.nilable(Integer),
// 31:     ).void
// 32:   }
// 33:   def initialize(testing_formulae, deleted_formulae, all_supported:, dependent_matrix:, dependent_shards: nil)
// 34:     if all_supported && (testing_formulae.present? || deleted_formulae.present? || dependent_matrix)
// 35:       raise ArgumentError, "all_supported is mutually exclusive to other arguments"
// 36:     end
// 37:
// 38:     @testing_formulae = testing_formulae
// 39:     @deleted_formulae = deleted_formulae
// 40:     @all_supported = all_supported
// 41:     @dependent_matrix = dependent_matrix
// 42:     @dependent_shards = T.let(dependent_shards || 1, Integer)
// 43:     @compatible_testing_formulae = T.let({}, T::Hash[GitHubRunner, T::Array[TestRunnerFormula]])
// 44:     @formulae_with_untested_dependents = T.let({}, T::Hash[GitHubRunner, T::Array[TestRunnerFormula]])
// 45:
// 46:     # gracefully handle non-GitHub Actions environments
// 47:     @github_run_id = T.let(
// 48:       if ENV.key?("GITHUB_ACTIONS")
// 49:         ENV.fetch("GITHUB_RUN_ID")
// 50:       else
// 51:         ENV.fetch("GITHUB_RUN_ID", "")
// 52:       end, String
// 53:     )
// 54:     @linux_self_hosted = T.let(ENV.fetch("HOMEBREW_LINUX_SELF_HOSTED", "false") == "true", T::Boolean)
// 55:     @runner_timeout = T.let(
// 56:       if ENV.fetch("HOMEBREW_MACOS_LONG_TIMEOUT", "false") == "true"
// 57:         GITHUB_ACTIONS_LONG_TIMEOUT
// 58:       else
// 59:         GITHUB_ACTIONS_SHORT_TIMEOUT
// 60:       end, Integer
// 61:     )
// 62:
// 63:     @runners = T.let([], T::Array[GitHubRunner])
// 64:     generate_runners!
// 65:
// 66:     freeze
// 67:   end
// 68:
// 69:   sig { returns(T::Array[RunnerSpecHash]) }
// 70:   def active_runner_specs_hash
// 71:     specs = runners.select(&:active)
// 72:                    .map(&:spec)
// 73:                    .map(&:to_h)
// 74:     return specs if !@dependent_matrix || @dependent_shards == 1
// 75:
// 76:     specs.flat_map do |spec|
// 77:       (1..@dependent_shards).map do |shard|
// 78:         spec.merge(
// 79:           name:                      "#{spec.fetch(:name)} shard #{shard}/#{@dependent_shards}",
// 80:           runner:                    spec.fetch(:runner).sub("-deps", "-deps#{shard}").to_s,
// 81:           formulae_dependents_shard: "#{shard}/#{@dependent_shards}",
// 82:         )
// 83:       end
// 84:     end
// 85:   end
// 86:
// 87:   sig { void }
// 88:   def generate_runners!
// 89:     return if @runners.present?
// 90:
// 91:     if !@all_supported || @linux_self_hosted
// 92:       VALID_ARCHES.each do |arch|
// 93:         @runners << create_runner(:linux, arch, linux_runner_spec(arch, self_hosted: @linux_self_hosted))
// 94:       end
// 95:     end
// 96:
// 97:     # Portable Ruby logic
// 98:     if @testing_formulae.any? { |tf| tf.name.start_with?("portable-") }
// 99:       x86_64_spec = MacOSRunnerSpec.new(
// 100:         name:    "macOS 10.15-cross x86_64",
// 101:         runner:  "10.15-cross-#{@github_run_id}",
// 102:         timeout: GITHUB_ACTIONS_LONG_TIMEOUT,
// 103:         cleanup: true,
// 104:       )
// 105:       x86_64_macos_version = MacOSVersion.new("10.15")
// 106:       @runners << create_runner(:macos, :x86_64, x86_64_spec, x86_64_macos_version)
// 107:
// 108:       # odisabled: remove support for Big Sur September (or later) 2027
// 109:       arm64_spec = MacOSRunnerSpec.new(
// 110:         name:    "macOS 11-cross arm64",
// 111:         runner:  "11-arm64-cross-#{@github_run_id}",
// 112:         timeout: GITHUB_ACTIONS_LONG_TIMEOUT,
// 113:         cleanup: true,
// 114:       )
// 115:       arm64_macos_version = MacOSVersion.new("11")
// 116:       @runners << create_runner(:macos, :arm64, arm64_spec, arm64_macos_version)
// 117:       return
// 118:     end
// 119:
// 120:     # Use GitHub Actions macOS Runner for testing dependents if compatible with timeout.
// 121:     use_github_runner = ENV.fetch("HOMEBREW_MACOS_BUILD_ON_GITHUB_RUNNER", "false") == "true"
// 122:     use_github_runner ||= @dependent_matrix
// 123:     use_github_runner &&= @runner_timeout <= GITHUB_ACTIONS_RUNNER_TIMEOUT
// 124:
// 125:     MacOSVersion::SYMBOLS.each_value do |version|
// 126:       macos_version = MacOSVersion.new(version)
// 127:       next unless runner_enabled?(macos_version)
// 128:
// 129:       github_runner_available = macos_version.between?(OLDEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER,
// 130:                                                        NEWEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER)
// 131:
// 132:       runner, timeout = if use_github_runner && github_runner_available
// 133:         ["macos-#{version}", GITHUB_ACTIONS_RUNNER_TIMEOUT]
// 134:       elsif macos_version >= :monterey
// 135:         ["#{version}-arm64#{ephemeral_suffix}", @runner_timeout]
// 136:       else
// 137:         ["#{version}-arm64", @runner_timeout]
// 138:       end
// 139:
// 140:       # We test recursive dependents on ARM macOS, so they can be slower than our Intel runners.
// 141:       timeout *= 2 if @dependent_matrix && timeout < GITHUB_ACTIONS_RUNNER_TIMEOUT
// 142:       spec = MacOSRunnerSpec.new(
// 143:         name:    "macOS #{version}-arm64",
// 144:         runner:,
// 145:         timeout:,
// 146:         cleanup: !runner.end_with?(ephemeral_suffix),
// 147:       )
// 148:       @runners << create_runner(:macos, :arm64, spec, macos_version)
// 149:
// 150:       skip_intel_runner = !@all_supported && macos_version > NEWEST_HOMEBREW_CORE_INTEL_MACOS_RUNNER
// 151:       skip_intel_runner &&= @dependent_matrix || @testing_formulae.none? do |testing_formula|
// 152:         bottle_spec = testing_formula.formula.bottle_specification
// 153:         bottle_spec.tag?(Utils::Bottles.tag(macos_version.to_sym), no_older_versions: true) &&
// 154:           !bottle_spec.tag?(Utils::Bottles.tag(:all), no_older_versions: true)
// 155:       end
// 156:       next if skip_intel_runner
// 157:
// 158:       github_runner_available = macos_version.between?(OLDEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER,
// 159:                                                        NEWEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER)
// 160:
// 161:       runner, timeout = if use_github_runner && github_runner_available
// 162:         ["macos-#{version}", GITHUB_ACTIONS_RUNNER_TIMEOUT]
// 163:       else
// 164:         ["#{version}-x86_64#{ephemeral_suffix}", @runner_timeout]
// 165:       end
// 166:
// 167:       # macOS 12-x86_64 is usually slower.
// 168:       timeout += 30 if macos_version <= :monterey
// 169:       # The ARM runners are typically over twice as fast as the Intel runners.
// 170:       timeout *= 2 if !(use_github_runner && github_runner_available) && timeout < GITHUB_ACTIONS_LONG_TIMEOUT
// 171:       spec = MacOSRunnerSpec.new(
// 172:         name:    "macOS #{version}-x86_64",
// 173:         runner:,
// 174:         timeout:,
// 175:         cleanup: !runner.end_with?(ephemeral_suffix),
// 176:       )
// 177:       @runners << create_runner(:macos, :x86_64, spec, macos_version)
// 178:     end
// 179:
// 180:     @runners.freeze
// 181:   end
// 182:
// 183:   private
// 184:
// 185:   # ARM macOS timeout, keep this under 1/2 of GitHub's job execution time limit for self-hosted runners.
// 186:   # https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners#usage-limits
// 187:   GITHUB_ACTIONS_LONG_TIMEOUT = 2160 # 36 hours
// 188:   GITHUB_ACTIONS_SHORT_TIMEOUT = 60
// 189:   private_constant :GITHUB_ACTIONS_LONG_TIMEOUT, :GITHUB_ACTIONS_SHORT_TIMEOUT
// 190:
// 191:   sig { params(arch: Symbol, self_hosted: T::Boolean).returns(LinuxRunnerSpec) }
// 192:   def linux_runner_spec(arch, self_hosted:)
// 193:     linux_runner = case arch
// 194:     when :arm64 then self_hosted ? "linux-arm64#{ephemeral_suffix}" : OS::LINUX_CI_ARM_RUNNER
// 195:     when :x86_64 then self_hosted ? "linux-x86_64#{ephemeral_suffix}" : "ubuntu-latest"
// 196:     else raise "Unknown Linux architecture: #{arch}"
// 197:     end
// 198:
// 199:     unless self_hosted
// 200:       container = {
// 201:         image:   "ghcr.io/homebrew/brew:main",
// 202:         options: "--init --user linuxbrew",
// 203:       }
// 204:       workdir = "/github/home"
// 205:     end
// 206:
// 207:     LinuxRunnerSpec.new(
// 208:       name:      "Linux #{arch}",
// 209:       runner:    linux_runner,
// 210:       container:,
// 211:       workdir:,
// 212:       timeout:   GITHUB_ACTIONS_LONG_TIMEOUT,
// 213:       cleanup:   false,
// 214:     )
// 215:   end
// 216:
// 217:   VALID_PLATFORMS = [:macos, :linux].freeze
// 218:   VALID_ARCHES = [:arm64, :x86_64].freeze
// 219:   private_constant :VALID_PLATFORMS, :VALID_ARCHES
// 220:
// 221:   sig {
// 222:     params(
// 223:       platform:      Symbol,
// 224:       arch:          Symbol,
// 225:       spec:          RunnerSpec,
// 226:       macos_version: T.nilable(MacOSVersion),
// 227:     ).returns(GitHubRunner)
// 228:   }
// 229:   def create_runner(platform, arch, spec, macos_version = nil)
// 230:     raise "Unexpected platform: #{platform}" if VALID_PLATFORMS.exclude?(platform)
// 231:     raise "Unexpected arch: #{arch}" if VALID_ARCHES.exclude?(arch)
// 232:
// 233:     runner = GitHubRunner.new(platform:, arch:, spec:, macos_version:)
// 234:     runner.spec.testing_formulae += testable_formulae(runner)
// 235:     runner.active = active_runner?(runner)
// 236:     runner.freeze
// 237:   end
// 238:
// 239:   sig { params(macos_version: MacOSVersion).returns(T::Boolean) }
// 240:   def runner_enabled?(macos_version)
// 241:     macos_version.between?(OLDEST_HOMEBREW_CORE_MACOS_RUNNER, NEWEST_HOMEBREW_CORE_MACOS_RUNNER)
// 242:   end
// 243:
// 244:   sig { returns(String) }
// 245:   def ephemeral_suffix
// 246:     @ephemeral_suffix ||= T.let(begin
// 247:       suffix = "-#{@github_run_id}"
// 248:       suffix << "-deps" if @dependent_matrix
// 249:       suffix << "-long" if @runner_timeout == GITHUB_ACTIONS_LONG_TIMEOUT
// 250:       suffix.freeze
// 251:     end, T.nilable(String))
// 252:   end
// 253:
// 254:   NEWEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER = :ventura
// 255:   OLDEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER = :ventura
// 256:   NEWEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER = :tahoe
// 257:   OLDEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER = :sonoma
// 258:   GITHUB_ACTIONS_RUNNER_TIMEOUT = 360
// 259:   private_constant :NEWEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER, :OLDEST_GITHUB_ACTIONS_INTEL_MACOS_RUNNER,
// 260:                    :NEWEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER, :OLDEST_GITHUB_ACTIONS_ARM_MACOS_RUNNER,
// 261:                    :GITHUB_ACTIONS_RUNNER_TIMEOUT
// 262:
// 263:   sig { params(runner: GitHubRunner).returns(T::Array[String]) }
// 264:   def testable_formulae(runner)
// 265:     formulae = if @dependent_matrix
// 266:       formulae_with_untested_dependents(runner)
// 267:     else
// 268:       compatible_testing_formulae(runner)
// 269:     end
// 270:
// 271:     formulae.map(&:name)
// 272:   end
// 273:
// 274:   sig { params(runner: GitHubRunner).returns(T::Boolean) }
// 275:   def active_runner?(runner)
// 276:     return true if @all_supported
// 277:     return true if @deleted_formulae.present? && !@dependent_matrix
// 278:
// 279:     runner.spec.testing_formulae.present?
// 280:   end
// 281:
// 282:   sig { params(runner: GitHubRunner).returns(T::Array[TestRunnerFormula]) }
// 283:   def compatible_testing_formulae(runner)
// 284:     @compatible_testing_formulae[runner] ||= begin
// 285:       platform = runner.platform
// 286:       arch = runner.arch
// 287:       macos_version = runner.macos_version
// 288:
// 289:       @testing_formulae.select do |formula|
// 290:         Homebrew::SimulateSystem.with(os: platform, arch: Homebrew::SimulateSystem.arch_symbols.fetch(arch)) do
// 291:           simulated_formula = TestRunnerFormula.new(Formulary.factory(formula.name))
// 292:           next false if macos_version && !simulated_formula.compatible_with?(macos_version)
// 293:
// 294:           simulated_formula.public_send(:"#{platform}_compatible?") &&
// 295:             simulated_formula.public_send(:"#{arch}_compatible?")
// 296:         end
// 297:       end
// 298:     end
// 299:   end
// 300:
// 301:   sig { params(runner: GitHubRunner).returns(T::Array[TestRunnerFormula]) }
// 302:   def formulae_with_untested_dependents(runner)
// 303:     @formulae_with_untested_dependents[runner] ||= begin
// 304:       platform = runner.platform
// 305:       arch = runner.arch
// 306:       macos_version = runner.macos_version
// 307:
// 308:       compatible_testing_formulae(runner).select do |formula|
// 309:         compatible_dependents = formula.dependents(platform:, arch:, macos_version: macos_version&.to_sym)
// 310:                                        .select do |dependent_f|
// 311:           Homebrew::SimulateSystem.with(os: platform, arch: Homebrew::SimulateSystem.arch_symbols.fetch(arch)) do
// 312:             simulated_dependent_f = dependent_f
// 313:             next false if macos_version && !simulated_dependent_f.compatible_with?(macos_version)
// 314:
// 315:             simulated_dependent_f.public_send(:"#{platform}_compatible?") &&
// 316:               simulated_dependent_f.public_send(:"#{arch}_compatible?") &&
// 317:               !simulated_dependent_f.formula.disabled? &&
// 318:               !simulated_dependent_f.formula.deprecated?
// 319:           end
// 320:         end
// 321:
// 322:         # These arrays will generally have been generated by different Formulary caches,
// 323:         # so we can only compare them by name and not directly.
// 324:         (compatible_dependents.map(&:name) - @testing_formulae.map(&:name)).present?
// 325:       end
// 326:     end
// 327:   end
// 328: end
