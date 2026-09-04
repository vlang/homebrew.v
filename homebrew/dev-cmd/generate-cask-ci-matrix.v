module dev_cmd

import ruby
import math
import os
import rand
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-cask-ci-matrix.rb`.

const cask_ci_max_jobs = 256

pub struct CaskCIRunner {
pub:
	symbol string
	name   string
	arch   string
	weight f64
}

pub struct CaskCIContainer {
pub:
	image   string
	options string
}

pub struct CaskCIItem {
pub:
	token               string
	path                string
	supports_macos      bool
	supports_linux      bool
	macos_architectures []string
	linux_architectures []string
	variations          []string
	minimum_macos       string
	maximum_macos       string
}

pub struct CaskCITap {
pub:
	name             string
	path             string
	cask_paths       map[string]string
	cask_directories []string
}

pub struct CaskCIChangedFiles {
pub:
	modified_files                []string
	added_files                   []string
	modified_ruby_files           []string
	modified_command_files        []string
	modified_github_actions_files []string
	modified_cask_files           []string
}

pub struct CaskCIRunnerArchPair {
pub:
	runner             CaskCIRunner
	arch               string
	native_runner_arch bool
}

pub struct CaskCIRunnersResult {
pub:
	runners  []CaskCIRunner
	multi_os bool
}

pub struct CaskCIJob {
pub:
	kind          string
	name          string
	tap           string
	runner        string
	stable        bool
	skip_audit    bool
	cask_token    string
	cask_path     string
	audit_args    []string
	fetch_args    []string
	skip_install  bool
	container     CaskCIContainer
	has_container bool
}

pub struct GenerateCaskCIMatrixInput {
pub:
	tap                    CaskCITap
	tap_present            bool
	labels                 []string
	cask_names             []string
	skip_install           bool
	new_cask               bool
	changed_files          CaskCIChangedFiles
	changed_files_provided bool
	casks                  map[string]CaskCIItem
	random_samples         []f64
}

pub struct GenerateCaskCICommandOptions {
pub:
	repository             string
	named                  []string
	casks_mode             bool
	url_mode               bool
	skip_install           bool
	new_cask               bool
	syntax_only            bool
	labels                 []string
	github_output          string
	tap                    CaskCITap
	changed_files          CaskCIChangedFiles
	changed_files_provided bool
	casks                  map[string]CaskCIItem
	random_samples         []f64
}

pub struct GenerateCaskCICommandResult {
pub:
	jobs                []CaskCIJob
	matrix_json         string
	stdout              string
	github_output       string
	github_output_wrote bool
}

@[heap]
pub struct GenerateCaskCICommandInput {
pub:
	options GenerateCaskCICommandOptions
}

@[heap]
pub struct CaskCIRunnerPairsInput {
pub:
	runners  []CaskCIRunner
	multi_os bool
}

@[heap]
pub struct CaskCIArchitecturesInput {
pub:
	cask             CaskCIItem
	operating_system string
}

@[heap]
pub struct CaskCIRandomRunnerInput {
pub:
	runners []CaskCIRunner
	samples []f64
}

fn cask_ci_x86_macos_runners() []CaskCIRunner {
	return [CaskCIRunner{
		symbol: 'sequoia'
		name: 'macos-15-intel'
		arch: 'intel'
		weight: 1.0
	}]
}

fn cask_ci_x86_linux_runners() []CaskCIRunner {
	return [CaskCIRunner{
		symbol: 'linux'
		name: 'ubuntu-latest'
		arch: 'intel'
		weight: 1.0
	}]
}

fn cask_ci_arm_macos_runners() []CaskCIRunner {
	return [
		CaskCIRunner{
			symbol: 'sonoma'
			name: 'macos-14'
			arch: 'arm'
			weight: 0.0
		},
		CaskCIRunner{
			symbol: 'sequoia'
			name: 'macos-15'
			arch: 'arm'
			weight: 0.0
		},
		CaskCIRunner{
			symbol: 'tahoe'
			name: 'macos-26'
			arch: 'arm'
			weight: 1.0
		},
	]
}

fn cask_ci_arm_linux_runners() []CaskCIRunner {
	return [CaskCIRunner{
		symbol: 'linux'
		name: 'ubuntu-24.04-arm'
		arch: 'arm'
		weight: 1.0
	}]
}

pub fn cask_ci_macos_runners() []CaskCIRunner {
	mut runners := cask_ci_x86_macos_runners()
	runners << cask_ci_arm_macos_runners()
	return runners
}

pub fn cask_ci_linux_runners() []CaskCIRunner {
	mut runners := cask_ci_x86_linux_runners()
	runners << cask_ci_arm_linux_runners()
	return runners
}

pub fn cask_ci_all_runners() []CaskCIRunner {
	mut runners := cask_ci_macos_runners()
	runners << cask_ci_linux_runners()
	return runners
}

fn cask_ci_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

fn cask_ci_macos_version_number(symbol string) int {
	return match symbol {
		'big_sur' { 11 }
		'monterey' { 12 }
		'ventura' { 13 }
		'sonoma' { 14 }
		'sequoia' { 15 }
		'tahoe' { 26 }
		else { symbol.int() }
	}
}

fn cask_ci_macos_allowed(cask CaskCIItem, runner CaskCIRunner) bool {
	version := cask_ci_macos_version_number(runner.symbol)
	if cask.minimum_macos != '' && version < cask_ci_macos_version_number(cask.minimum_macos) {
		return false
	}
	if cask.maximum_macos != '' && version > cask_ci_macos_version_number(cask.maximum_macos) {
		return false
	}
	return true
}

// cask_ci_architectures translates the two tag refreshes performed by the Ruby
// implementation. The typed cask stores the resulting per-OS dependency values.
pub fn cask_ci_architectures(cask CaskCIItem, operating_system string) []string {
	configured := if operating_system == 'linux' {
		cask.linux_architectures
	} else {
		cask.macos_architectures
	}
	if configured.len == 0 {
		return ['arm', 'intel']
	}
	return cask_ci_unique(configured)
}

pub fn cask_ci_filter_runners(cask CaskCIItem) []CaskCIRunner {
	mut filtered := []CaskCIRunner{}
	if cask.supports_macos {
		macos_architectures := cask_ci_architectures(cask, 'macos')
		for runner in cask_ci_macos_runners() {
			if cask_ci_macos_allowed(cask, runner) && runner.arch in macos_architectures {
				filtered << runner
			}
		}
	}
	if cask.supports_linux {
		linux_architectures := cask_ci_architectures(cask, 'linux')
		for runner in cask_ci_linux_runners() {
			if runner.arch in linux_architectures {
				filtered << runner
			}
		}
	}
	return filtered
}

pub fn cask_ci_runner_arch_pairs(runners []CaskCIRunner, multi_os bool) []CaskCIRunnerArchPair {
	macos_architectures := cask_ci_unique(runners.filter(it.symbol != 'linux').map(it.arch))
	linux_architectures := cask_ci_unique(runners.filter(it.symbol == 'linux').map(it.arch))
	mut product_architectures := macos_architectures.clone()
	for arch in linux_architectures {
		if arch !in product_architectures {
			product_architectures << arch
		}
	}
	mut pairs := []CaskCIRunnerArchPair{}
	for runner in runners {
		for arch in product_architectures {
			native := arch == runner.arch
			if runner.symbol == 'linux' && !native {
				continue
			}
			if runner.symbol == 'sequoia' && !native {
				continue
			}
			if runner.symbol != 'linux' && !native && arch !in macos_architectures {
				continue
			}
			if !native && !multi_os {
				continue
			}
			pairs << CaskCIRunnerArchPair{
				runner: runner
				arch: arch
				native_runner_arch: native
			}
		}
	}
	return pairs
}

pub fn cask_ci_random_runner(available []CaskCIRunner, samples []f64) !CaskCIRunner {
	if available.len == 0 {
		return error('unexpected nil max_runner')
	}
	mut maximum_key := -1.0
	mut maximum_runner := available[0]
	for index, runner in available {
		sample := if index < samples.len { samples[index] } else { rand.f64() }
		key := if runner.weight <= 0.0 { 0.0 } else { math.pow(sample, 1.0 / runner.weight) }
		if key > maximum_key {
			maximum_key = key
			maximum_runner = runner
		}
	}
	return maximum_runner
}

pub fn cask_ci_runners(cask CaskCIItem, samples []f64) !CaskCIRunnersResult {
	filtered := cask_ci_filter_runners(cask)
	for runner in filtered {
		if runner.symbol in cask.variations {
			return CaskCIRunnersResult{
				runners: filtered
				multi_os: true
			}
		}
	}
	mut selected := []CaskCIRunner{}
	mut sample_offset := 0
	for arch in cask_ci_unique(filtered.filter(it.symbol != 'linux').map(it.arch)) {
		arch_runners := filtered.filter(it.symbol != 'linux' && it.arch == arch)
		arch_samples := if sample_offset < samples.len { samples[sample_offset..] } else { []f64{} }
		selected << cask_ci_random_runner(arch_runners, arch_samples)!
		sample_offset += arch_runners.len
	}
	selected << filtered.filter(it.symbol == 'linux')
	return CaskCIRunnersResult{
		runners: selected
		multi_os: false
	}
}

fn cask_ci_contains(values []string, sought string) bool {
	return sought in values
}

fn cask_ci_difference(left []string, right []string) []string {
	return left.filter(it !in right)
}

fn cask_ci_path_token(path string) string {
	name := os.file_name(path)
	return if name.ends_with('.rb') { name[..name.len - 3] } else { name }
}

fn cask_ci_lookup_cask(input GenerateCaskCIMatrixInput, path string) !CaskCIItem {
	if cask := input.casks[path] {
		return cask
	}
	token := cask_ci_path_token(path)
	if cask := input.casks[token] {
		return cask
	}
	return error('Cask unavailable: ${token}')
}

pub fn generate_cask_ci_matrix(input GenerateCaskCIMatrixInput) ![]CaskCIJob {
	if !input.tap_present {
		return error('This command must be run from inside a tap directory.')
	}
	changed := if input.changed_files_provided {
		input.changed_files
	} else {
		cask_ci_find_changed_files(input.tap)!
	}
	mut allowed_ruby_files := changed.modified_cask_files.clone()
	allowed_ruby_files << changed.modified_command_files
	allowed_ruby_files << changed.modified_github_actions_files
	wrong_directory := cask_ci_difference(changed.modified_ruby_files, allowed_ruby_files)
	if wrong_directory.len > 0 {
		return error('Found Ruby files in wrong directory:\n${wrong_directory.join('\n')}')
	}

	mut cask_files := []string{}
	if input.cask_names.len > 0 {
		for name in input.cask_names {
			path := input.tap.cask_paths[name] or { return error('Cask unavailable: ${name}') }
			cask_files << path
		}
	} else {
		cask_files = changed.modified_cask_files.clone()
	}
	if cask_files.len > cask_ci_max_jobs {
		return error('Maximum job matrix size exceeded: ${cask_files.len}/${cask_ci_max_jobs}')
	}

	mut jobs := []CaskCIJob{}
	for path in cask_files {
		token := cask_ci_path_token(path)
		mut audit_args := ['--online']
		if path in changed.added_files || input.new_cask {
			audit_args << '--new'
		}
		mut audit_exceptions := []string{}
		if cask_ci_contains(input.labels, 'ci-skip-homepage') {
			audit_exceptions << 'homepage_https_availability'
		}
		if cask_ci_contains(input.labels, 'ci-skip-livecheck') {
			audit_exceptions << ['hosting_with_livecheck', 'livecheck_https_availability',
				'livecheck_version', 'min_os']
		}
		if cask_ci_contains(input.labels, 'ci-skip-livecheck-min-os') {
			audit_exceptions << 'min_os'
		}
		if cask_ci_contains(input.labels, 'ci-skip-repository') {
			audit_exceptions << ['github_repository', 'github_prerelease_version', 'gitlab_repository',
				'gitlab_prerelease_version', 'forgejo_repository', 'forgejo_prerelease_version',
				'bitbucket_repository']
		}
		if cask_ci_contains(input.labels, 'ci-skip-token') {
			audit_exceptions << ['token_valid', 'token_bad_words']
		}
		if audit_exceptions.len > 0 {
			audit_args << '--except'
			audit_args << audit_exceptions.join(',')
		}

		cask := cask_ci_lookup_cask(input, path)!
		selected := cask_ci_runners(cask, input.random_samples)!
		for pair in cask_ci_runner_arch_pairs(selected.runners, selected.multi_os) {
			arch_args := if pair.native_runner_arch {
				[]string{}
			} else {
				[
					'--arch=${pair.arch}',
				]
			}
			mut job_audit_args := audit_args.clone()
			job_audit_args << arch_args
			mut job := CaskCIJob{
				kind: 'cask'
				name: 'test ${token} (${pair.runner.name}, ${pair.arch})'
				tap: input.tap.name
				runner: pair.runner.name
				cask_token: token
				cask_path: './${path}'
				audit_args: job_audit_args
				fetch_args: arch_args
				skip_install: cask_ci_contains(input.labels, 'ci-skip-install')
					|| !pair.native_runner_arch || input.skip_install
			}
			if pair.runner.symbol == 'linux' {
				job = CaskCIJob{
					...job
					container: CaskCIContainer{
						image: 'ghcr.io/homebrew/brew:main'
						options: '--user=linuxbrew'
					}
					has_container: true
				}
			}
			jobs << job
		}
	}
	return jobs
}

fn cask_ci_job_value(job CaskCIJob) ruby.Value {
	mut value := {
		'name':   ruby.string_value(job.name)
		'tap':    ruby.string_value(job.tap)
		'runner': ruby.string_value(job.runner)
	}
	if job.kind == 'syntax' {
		value['stable'] = ruby.bool_value(job.stable)
		if job.skip_audit {
			value['skip_audit'] = ruby.bool_value(true)
		}
	} else {
		value['cask'] = ruby.map_value({
			'token': ruby.string_value(job.cask_token)
			'path':  ruby.string_value(job.cask_path)
		})
		value['audit_args'] = ruby.string_array_value(job.audit_args)
		value['fetch_args'] = ruby.string_array_value(job.fetch_args)
		value['skip_install'] = ruby.bool_value(job.skip_install)
		if job.has_container {
			value['container'] = ruby.map_value({
				'image':   ruby.string_value(job.container.image)
				'options': ruby.string_value(job.container.options)
			})
		}
	}
	return ruby.map_value(value)
}

fn cask_ci_jobs_value(jobs []CaskCIJob) ruby.Value {
	return ruby.array_value(jobs.map(cask_ci_job_value(it)))
}

pub fn run_generate_cask_ci_matrix(options GenerateCaskCICommandOptions) !GenerateCaskCICommandResult {
	if options.repository.trim_space() == '' {
		return error('The `\$GITHUB_REPOSITORY` environment variable must be set.')
	}
	if !options.syntax_only && !options.casks_mode && !options.url_mode {
		return error('Either `--cask` or `--url` must be specified.')
	}
	if !options.syntax_only && options.named.len == 0 {
		return error('Please provide a `--cask` or `--url` argument.')
	}
	if options.url_mode && options.named.len > 1 {
		return error('Only one `--url` can be specified.')
	}

	random := cask_ci_random_runner(cask_ci_arm_macos_runners(), options.random_samples)!
	mut cask_jobs := []CaskCIJob{}
	if !options.syntax_only && 'ci-syntax-only' !in options.labels {
		cask_jobs = generate_cask_ci_matrix(GenerateCaskCIMatrixInput{
			tap: options.tap
			tap_present: options.tap.name != '' || options.tap.path != ''
			labels: options.labels
			cask_names: if options.casks_mode { options.named } else { []string{} }
			skip_install: options.skip_install
			new_cask: options.new_cask
			changed_files: options.changed_files
			changed_files_provided: options.changed_files_provided
			casks: options.casks
			random_samples: options.random_samples
		})!
	}
	mut jobs := [
		CaskCIJob{
			kind: 'syntax'
			name: 'tap_syntax (${random.name})'
			tap: options.tap.name
			runner: random.name
			stable: false
			skip_audit: cask_jobs.len > 0
		},
		CaskCIJob{
			kind: 'syntax'
			name: 'tap_syntax (stable) (${random.name})'
			tap: options.tap.name
			runner: random.name
			stable: true
			skip_audit: true
		},
	]
	jobs << cask_jobs
	if jobs.len > cask_ci_max_jobs {
		return error('Maximum job matrix size exceeded: ${jobs.len}/${cask_ci_max_jobs}')
	}
	jobs_value := cask_ci_jobs_value(jobs)
	matrix_json := ruby.json_value_to_string(jobs_value)
	stdout := json2.encode(ruby.json_any_from_value(jobs_value), prettify: true) + '\n'
	mut wrote := false
	if options.github_output != '' {
		mut output := os.open_append(options.github_output)!
		defer {
			output.close()
		}
		output.writeln('matrix=${matrix_json}')!
		wrote = true
	}
	return GenerateCaskCICommandResult{
		jobs: jobs
		matrix_json: matrix_json
		stdout: stdout
		github_output: options.github_output
		github_output_wrote: wrote
	}
}

fn cask_ci_git_read(tap CaskCITap, arguments []string) !string {
	mut command := ['git']
	if tap.path != '' {
		command << ['-C', tap.path]
	}
	command << arguments
	result := os.execute(command.map(os.quoted_path(it)).join(' '))
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result.output.trim_space()
}

fn cask_ci_output_paths(output string) []string {
	if output == '' {
		return []string{}
	}
	return output.split_into_lines().filter(it != '')
}

fn cask_ci_is_command_file(path string) bool {
	normalized := path.replace('\\', '/')
	return normalized.starts_with('cmd/') || normalized.contains('/cmd/')
}

fn cask_ci_is_cask_file(tap CaskCITap, path string) bool {
	normalized := path.replace('\\', '/')
	directories := if tap.cask_directories.len > 0 {
		tap.cask_directories
	} else {
		[
			'Casks',
		]
	}
	for directory in directories {
		prefix := directory.trim('/').replace('\\', '/') + '/'
		if normalized.starts_with(prefix) && normalized.ends_with('.rb') {
			return true
		}
	}
	return false
}

pub fn cask_ci_classify_changed_files(tap CaskCITap, modified []string, added []string) CaskCIChangedFiles {
	return CaskCIChangedFiles{
		modified_files: modified
		added_files: added
		modified_ruby_files: modified.filter(it.ends_with('.rb'))
		modified_command_files: modified.filter(cask_ci_is_command_file(it))
		modified_github_actions_files: modified.filter(it.replace('\\', '/').starts_with('.github/actions/'))
		modified_cask_files: modified.filter(cask_ci_is_cask_file(tap, it))
	}
}

pub fn cask_ci_find_changed_files(tap CaskCITap) !CaskCIChangedFiles {
	start := cask_ci_git_read(tap, ['rev-parse', 'origin'])!
	end := cask_ci_git_read(tap, ['rev-parse', 'HEAD'])!
	range := '${start}...${end}'
	modified := cask_ci_output_paths(cask_ci_git_read(tap, ['diff', '--name-only', '--diff-filter=AMR',
		range])!)
	added := cask_ci_output_paths(cask_ci_git_read(tap, ['diff', '--name-only', '--diff-filter=A',
		range])!)
	return cask_ci_classify_changed_files(tap, modified, added)
}

fn cask_ci_runner_value(runner CaskCIRunner) ruby.Value {
	return ruby.map_value({
		'symbol': ruby.string_value(runner.symbol)
		'name':   ruby.string_value(runner.name)
		'arch':   ruby.string_value(runner.arch)
		'weight': ruby.float_value(runner.weight)
	})
}

fn cask_ci_pointer_value(type_name string, key string, pointer voidptr) ruby.Value {
	return ruby.structured_value(type_name, '', {
		key: u64(pointer).str()
	})
}

pub fn generate_cask_ci_command_input_value(input &GenerateCaskCICommandInput) ruby.Value {
	return cask_ci_pointer_value('GenerateCaskCICommandInput', 'command_address', voidptr(input))
}

pub fn cask_ci_cask_value(cask &CaskCIItem) ruby.Value {
	return cask_ci_pointer_value('CaskCIItem', 'cask_address', voidptr(cask))
}

pub fn cask_ci_runner_pairs_input_value(input &CaskCIRunnerPairsInput) ruby.Value {
	return cask_ci_pointer_value('CaskCIRunnerPairsInput', 'runner_pairs_address', voidptr(input))
}

pub fn cask_ci_architectures_input_value(input &CaskCIArchitecturesInput) ruby.Value {
	return cask_ci_pointer_value('CaskCIArchitecturesInput', 'architectures_address', voidptr(input))
}

pub fn cask_ci_random_runner_input_value(input &CaskCIRandomRunnerInput) ruby.Value {
	return cask_ci_pointer_value('CaskCIRandomRunnerInput', 'random_runner_address', voidptr(input))
}

pub fn generate_cask_ci_matrix_input_value(input &GenerateCaskCIMatrixInput) ruby.Value {
	return cask_ci_pointer_value('GenerateCaskCIMatrixInput', 'matrix_address', voidptr(input))
}

pub fn cask_ci_tap_value(tap &CaskCITap) ruby.Value {
	return cask_ci_pointer_value('CaskCITap', 'tap_address', voidptr(tap))
}
