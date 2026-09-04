module homebrew

import ruby

// Translated from Homebrew/brew `github_runner_matrix.rb`.
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

pub fn github_runner_spec_to_map(spec GitHubRunnerSpec) map[string]ruby.Value {
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

pub fn github_runner_matrix_active_specs(matrix GitHubRunnerMatrix) []map[string]ruby.Value {
	mut specs := []map[string]ruby.Value{}
	for runner in matrix.runners {
		if runner.active {
			specs << github_runner_spec_to_map(runner.spec)
		}
	}
	shards := if matrix.options.dependent_shards > 0 { matrix.options.dependent_shards } else { 1 }
	if !matrix.options.dependent_matrix || shards == 1 {
		return specs
	}
	mut sharded := []map[string]ruby.Value{}
	for spec in specs {
		for shard in 1 .. shards + 1 {
			mut entry := spec.clone()
			name := spec['name'].as_string()
			runner := spec['runner'].as_string()
			entry['name'] = ruby.string_value('${name} shard ${shard}/${shards}')
			entry['runner'] = ruby.string_value(runner.replace_once('-deps', '-deps${shard}'))
			entry['formulae_dependents_shard'] = ruby.string_value('${shard}/${shards}')
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
			none
		} else {
			LinuxRunnerContainer{
				image: 'ghcr.io/homebrew/brew:main'
				options: '--init --user linuxbrew'
			}
		}
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
				''
			} else {
				(new_macos_version(runner.macos_version) or { null_macos_version() }).to_symbol()
			}
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
