module dev_cmd

import brew_runtime
import math
import os
import rand
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-cask-ci-matrix.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn cask_ci_job_value(job CaskCIJob) brew_runtime.Value {
	mut value := {
		'name':   brew_runtime.string_value(job.name)
		'tap':    brew_runtime.string_value(job.tap)
		'runner': brew_runtime.string_value(job.runner)
	}
	if job.kind == 'syntax' {
		value['stable'] = brew_runtime.bool_value(job.stable)
		if job.skip_audit {
			value['skip_audit'] = brew_runtime.bool_value(true)
		}
	} else {
		value['cask'] = brew_runtime.map_value({
			'token': brew_runtime.string_value(job.cask_token)
			'path':  brew_runtime.string_value(job.cask_path)
		})
		value['audit_args'] = brew_runtime.string_array_value(job.audit_args)
		value['fetch_args'] = brew_runtime.string_array_value(job.fetch_args)
		value['skip_install'] = brew_runtime.bool_value(job.skip_install)
		if job.has_container {
			value['container'] = brew_runtime.map_value({
				'image':   brew_runtime.string_value(job.container.image)
				'options': brew_runtime.string_value(job.container.options)
			})
		}
	}
	return brew_runtime.map_value(value)
}

fn cask_ci_jobs_value(jobs []CaskCIJob) brew_runtime.Value {
	return brew_runtime.array_value(jobs.map(cask_ci_job_value(it)))
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
	matrix_json := brew_runtime.json_value_to_string(jobs_value)
	stdout := json2.encode(brew_runtime.json_any_from_value(jobs_value), prettify: true) + '\n'
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

fn cask_ci_runner_value(runner CaskCIRunner) brew_runtime.Value {
	return brew_runtime.map_value({
		'symbol': brew_runtime.string_value(runner.symbol)
		'name':   brew_runtime.string_value(runner.name)
		'arch':   brew_runtime.string_value(runner.arch)
		'weight': brew_runtime.float_value(runner.weight)
	})
}

fn cask_ci_pointer_value(type_name string, key string, pointer voidptr) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, '', {
		key: u64(pointer).str()
	})
}

pub fn generate_cask_ci_command_input_value(input &GenerateCaskCICommandInput) brew_runtime.Value {
	return cask_ci_pointer_value('GenerateCaskCICommandInput', 'command_address', voidptr(input))
}

pub fn cask_ci_cask_value(cask &CaskCIItem) brew_runtime.Value {
	return cask_ci_pointer_value('CaskCIItem', 'cask_address', voidptr(cask))
}

pub fn cask_ci_runner_pairs_input_value(input &CaskCIRunnerPairsInput) brew_runtime.Value {
	return cask_ci_pointer_value('CaskCIRunnerPairsInput', 'runner_pairs_address', voidptr(input))
}

pub fn cask_ci_architectures_input_value(input &CaskCIArchitecturesInput) brew_runtime.Value {
	return cask_ci_pointer_value('CaskCIArchitecturesInput', 'architectures_address', voidptr(input))
}

pub fn cask_ci_random_runner_input_value(input &CaskCIRandomRunnerInput) brew_runtime.Value {
	return cask_ci_pointer_value('CaskCIRandomRunnerInput', 'random_runner_address', voidptr(input))
}

pub fn generate_cask_ci_matrix_input_value(input &GenerateCaskCIMatrixInput) brew_runtime.Value {
	return cask_ci_pointer_value('GenerateCaskCIMatrixInput', 'matrix_address', voidptr(input))
}

pub fn cask_ci_tap_value(tap &CaskCITap) brew_runtime.Value {
	return cask_ci_pointer_value('CaskCITap', 'tap_address', voidptr(tap))
}

// Ruby method `run` at line 63.
pub fn ruby_generate_cask_ci_matrix_l63_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'command_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := unsafe { &GenerateCaskCICommandInput(voidptr(args[0].attributes['command_address'].u64())) }
	result := run_generate_cask_ci_matrix(input.options) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return brew_runtime.map_value({
		'matrix':              cask_ci_jobs_value(result.jobs)
		'matrix_json':         brew_runtime.string_value(result.matrix_json)
		'stdout':              brew_runtime.string_value(result.stdout)
		'github_output_wrote': brew_runtime.bool_value(result.github_output_wrote)
	})
}

// Ruby method `filter_runners(cask)` at line 136.
pub fn ruby_generate_cask_ci_matrix_l136_d2_filter_runners(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'cask_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'cask is required')
	}
	cask := unsafe { &CaskCIItem(voidptr(args[0].attributes['cask_address'].u64())) }
	return brew_runtime.array_value(cask_ci_filter_runners(*cask).map(cask_ci_runner_value(it)))
}

// Ruby method `runner_arch_pairs(runners:, multi_os:)` at line 176.
pub fn ruby_generate_cask_ci_matrix_l176_d3_runner_arch_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'runner_pairs_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'runner pair input is required')
	}
	input := unsafe { &CaskCIRunnerPairsInput(voidptr(args[0].attributes['runner_pairs_address'].u64())) }
	mut values := []brew_runtime.Value{}
	for pair in cask_ci_runner_arch_pairs(input.runners, input.multi_os) {
		values << brew_runtime.array_value([
			cask_ci_runner_value(pair.runner),
			brew_runtime.string_value(pair.arch),
			brew_runtime.bool_value(pair.native_runner_arch),
		])
	}
	return brew_runtime.array_value(values)
}

// Ruby method `runners(cask:)` at line 196.
pub fn ruby_generate_cask_ci_matrix_l196_d4_runners(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'cask_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'cask is required')
	}
	cask := unsafe { &CaskCIItem(voidptr(args[0].attributes['cask_address'].u64())) }
	selected := cask_ci_runners(*cask, []f64{}) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.map_value({
		'runners':  brew_runtime.array_value(selected.runners.map(cask_ci_runner_value(it)))
		'multi_os': brew_runtime.bool_value(selected.multi_os)
	})
}

// Ruby method `architectures(cask:, os:)` at line 220.
pub fn ruby_generate_cask_ci_matrix_l220_d5_architectures(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'architectures_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'architectures input is required')
	}
	input := unsafe { &CaskCIArchitecturesInput(voidptr(args[0].attributes['architectures_address'].u64())) }
	return brew_runtime.string_array_value(cask_ci_architectures(input.cask, input.operating_system))
}

// Ruby method `random_runner(available_runners = ARM_MACOS_RUNNERS)` at line 241.
pub fn ruby_generate_cask_ci_matrix_l241_d6_random_runner(args ...brew_runtime.Value) brew_runtime.Value {
	mut runners := cask_ci_arm_macos_runners()
	mut samples := []f64{}
	if args.len > 0 && 'random_runner_address' in args[0].attributes {
		input := unsafe { &CaskCIRandomRunnerInput(voidptr(args[0].attributes['random_runner_address'].u64())) }
		runners = input.runners.clone()
		samples = input.samples.clone()
	}
	runner := cask_ci_random_runner(runners, samples) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return cask_ci_runner_value(runner)
}

// Ruby method `generate_matrix(tap, labels: [], cask_names: [], skip_install: false, new_cask: false)` at line 253.
pub fn ruby_generate_cask_ci_matrix_l253_d7_generate_matrix(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'matrix_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'matrix input is required')
	}
	input := unsafe { &GenerateCaskCIMatrixInput(voidptr(args[0].attributes['matrix_address'].u64())) }
	jobs := generate_cask_ci_matrix(*input) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return cask_ci_jobs_value(jobs)
}

// Ruby method `find_changed_files(tap)` at line 351.
pub fn ruby_generate_cask_ci_matrix_l351_d8_find_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || 'tap_address' !in args[0].attributes {
		return brew_runtime.object_value('ArgumentError', 'tap is required')
	}
	tap := unsafe { &CaskCITap(voidptr(args[0].attributes['tap_address'].u64())) }
	changed := cask_ci_find_changed_files(*tap) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.map_value({
		'modified_files':                brew_runtime.string_array_value(changed.modified_files)
		'added_files':                   brew_runtime.string_array_value(changed.added_files)
		'modified_ruby_files':           brew_runtime.string_array_value(changed.modified_ruby_files)
		'modified_command_files':        brew_runtime.string_array_value(changed.modified_command_files)
		'modified_github_actions_files': brew_runtime.string_array_value(changed.modified_github_actions_files)
		'modified_cask_files':           brew_runtime.string_array_value(changed.modified_cask_files)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6: require "utils/github/api"
// 7: require "cli/parser"
// 8: require "system_command"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class GenerateCaskCiMatrix < AbstractCommand
// 13:       MAX_JOBS = 256
// 14:
// 15:       # Weight for each arch must add up to 1.0.
// 16:       X86_MACOS_RUNNERS = T.let({
// 17:         { symbol: :sequoia, name: "macos-15-intel", arch: :intel } => 1.0,
// 18:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 19:       X86_LINUX_RUNNERS = T.let({
// 20:         { symbol: :linux, name: "ubuntu-latest", arch: :intel } => 1.0,
// 21:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 22:       ARM_MACOS_RUNNERS = T.let({
// 23:         { symbol: :sonoma,  name: "macos-14", arch: :arm } => 0.0,
// 24:         { symbol: :sequoia, name: "macos-15", arch: :arm } => 0.0,
// 25:         { symbol: :tahoe,   name: "macos-26", arch: :arm } => 1.0,
// 26:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 27:       ARM_LINUX_RUNNERS = T.let({
// 28:         { symbol: :linux, name: OS::LINUX_CI_ARM_RUNNER, arch: :arm } => 1.0,
// 29:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 30:       MACOS_RUNNERS = T.let(X86_MACOS_RUNNERS.merge(ARM_MACOS_RUNNERS).freeze,
// 31:                             T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 32:       LINUX_RUNNERS = T.let(X86_LINUX_RUNNERS.merge(ARM_LINUX_RUNNERS).freeze,
// 33:                             T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 34:       RUNNERS = T.let(MACOS_RUNNERS.merge(LINUX_RUNNERS).freeze,
// 35:                       T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 36:
// 37:       cmd_args do
// 38:         description <<~EOS
// 39:           Generate a GitHub Actions matrix for a given pull request URL or list of cask names.
// 40:           For internal use in Homebrew taps.
// 41:         EOS
// 42:         switch "--url",
// 43:                description: "Treat named argument as a pull request URL."
// 44:         switch "--cask", "--casks",
// 45:                description: "Treat all named arguments as cask tokens."
// 46:         switch "--skip-install",
// 47:                description: "Skip installing casks."
// 48:         switch "--new",
// 49:                description: "Run new cask checks."
// 50:         switch "--syntax-only",
// 51:                description: "Only run syntax checks."
// 52:
// 53:         conflicts "--url", "--cask"
// 54:         conflicts "--syntax-only", "--skip-install"
// 55:         conflicts "--syntax-only", "--new"
// 56:
// 57:         named_args [:cask, :url], min: 0
// 58:
// 59:         hide_from_man_page!
// 60:       end
// 61:
// 62:       sig { override.void }
// 63:       def run
// 64:         skip_install = args.skip_install?
// 65:         new_cask = args.new?
// 66:         casks = args.named if args.casks?
// 67:         pr_url = args.named if args.url?
// 68:         syntax_only = args.syntax_only?
// 69:
// 70:         repository = ENV.fetch("GITHUB_REPOSITORY", nil)
// 71:         raise UsageError, "The `$GITHUB_REPOSITORY` environment variable must be set." if repository.blank?
// 72:
// 73:         tap = T.let(Tap.fetch(repository), Tap)
// 74:
// 75:         unless syntax_only
// 76:           raise UsageError, "Either `--cask` or `--url` must be specified." if !args.casks? && !args.url?
// 77:           raise UsageError, "Please provide a `--cask` or `--url` argument." if casks.blank? && pr_url.blank?
// 78:         end
// 79:         raise UsageError, "Only one `--url` can be specified." if pr_url&.count&.> 1
// 80:
// 81:         labels = if pr_url && (first_pr_url = pr_url.first)
// 82:           pr = GitHub::API.open_rest(first_pr_url)
// 83:           pr.fetch("labels").map { |l| l.fetch("name") }
// 84:         else
// 85:           []
// 86:         end
// 87:
// 88:         runner = random_runner[:name]
// 89:         syntax_job = {
// 90:           name:   "tap_syntax",
// 91:           tap:    tap.name,
// 92:           runner:,
// 93:           stable: false,
// 94:         }
// 95:         stable_syntax_job = syntax_job.merge(name: "tap_syntax (stable)", stable: true, skip_audit: true)
// 96:
// 97:         matrix = [syntax_job, stable_syntax_job]
// 98:
// 99:         if !syntax_only && !labels&.include?("ci-syntax-only")
// 100:           cask_jobs = if casks&.any?
// 101:             generate_matrix(tap, labels:, cask_names: casks, skip_install:, new_cask:)
// 102:           else
// 103:             generate_matrix(tap, labels:, skip_install:, new_cask:)
// 104:           end
// 105:
// 106:           if cask_jobs.any?
// 107:             # If casks were changed, skip `audit` for whole tap.
// 108:             syntax_job[:skip_audit] = true
// 109:
// 110:             # The syntax job only runs `style` at this point, which should work on Linux.
// 111:             # Running on macOS is currently faster though, since `homebrew/cask` and
// 112:             # `homebrew/core` are already tapped on macOS CI machines.
// 113:             # syntax_job[:runner] = "ubuntu-latest"
// 114:           end
// 115:
// 116:           matrix += cask_jobs
// 117:         end
// 118:
// 119:         jobs = matrix.count
// 120:         odie "Maximum job matrix size exceeded: #{jobs}/#{MAX_JOBS}" if jobs > MAX_JOBS
// 121:
// 122:         [syntax_job, stable_syntax_job].each do |job|
// 123:           job[:name] += " (#{job[:runner]})"
// 124:         end
// 125:
// 126:         puts JSON.pretty_generate(matrix)
// 127:         github_output = ENV.fetch("GITHUB_OUTPUT", nil)
// 128:         return unless github_output
// 129:
// 130:         File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 131:           f.puts "matrix=#{JSON.generate(matrix)}"
// 132:         end
// 133:       end
// 134:
// 135:       sig { params(cask: Cask::Cask).returns(T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float]) }
// 136:       def filter_runners(cask)
// 137:         filtered_runners = T.let({}, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 138:         if cask.supports_macos?
// 139:           # Skip macOS if no runner satisfies the cask's min/max macOS requirements.
// 140:           macos_requirements = [cask.depends_on.macos, cask.depends_on.maximum_macos]
// 141:                                .compact.select(&:version_specified?)
// 142:
// 143:           filtered_runners = if macos_requirements.empty?
// 144:             MACOS_RUNNERS.dup
// 145:           else
// 146:             MACOS_RUNNERS.select do |runner, _|
// 147:               macos_version = MacOSVersion.from_symbol(runner.fetch(:symbol).to_sym)
// 148:               macos_requirements.all? { |requirement| requirement.allows?(macos_version) }
// 149:             end
// 150:           end
// 151:
// 152:           if filtered_runners.any?
// 153:             macos_archs = architectures(cask:, os: :macos)
// 154:             filtered_runners.select! do |runner, _|
// 155:               macos_archs.include?(runner.fetch(:arch))
// 156:             end
// 157:           end
// 158:         end
// 159:
// 160:         return filtered_runners unless cask.supports_linux?
// 161:
// 162:         linux_archs = architectures(cask:, os: :linux)
// 163:         linux_runners = LINUX_RUNNERS.select do |runner, _|
// 164:           linux_archs.include?(runner.fetch(:arch))
// 165:         end
// 166:
// 167:         filtered_runners.merge(linux_runners)
// 168:       end
// 169:
// 170:       sig {
// 171:         params(
// 172:           runners:  T::Array[T::Hash[Symbol, T.any(Symbol, String)]],
// 173:           multi_os: T::Boolean,
// 174:         ).returns(T::Array[[T::Hash[Symbol, T.any(Symbol, String)], T.any(Symbol, String), T::Boolean]])
// 175:       }
// 176:       def runner_arch_pairs(runners:, multi_os:)
// 177:         macos_archs = runners.reject { |r| r.fetch(:symbol) == :linux }.map { |r| r.fetch(:arch) }.uniq
// 178:         linux_archs = runners.select { |r| r.fetch(:symbol) == :linux }.map { |r| r.fetch(:arch) }.uniq
// 179:         product_archs = macos_archs | linux_archs
// 180:         runners.product(product_archs).filter_map do |runner, arch|
// 181:           native_runner_arch = arch == runner.fetch(:arch)
// 182:           # we don't need to run simulated archs on Linux or macOS Sequoia
// 183:           # because they exist as real GitHub hosted runners
// 184:           next if runner.fetch(:symbol) == :linux && !native_runner_arch
// 185:           next if runner.fetch(:symbol) == :sequoia && !native_runner_arch
// 186:           # skip macOS runners simulating architectures not supported on macOS
// 187:           next if runner.fetch(:symbol) != :linux && !native_runner_arch && macos_archs.exclude?(arch)
// 188:           # if it's just a single OS test then we can just use the two real arch runners
// 189:           next if !native_runner_arch && !multi_os
// 190:
// 191:           [runner, arch, native_runner_arch]
// 192:         end
// 193:       end
// 194:
// 195:       sig { params(cask: Cask::Cask).returns([T::Array[T::Hash[Symbol, T.any(Symbol, String)]], T::Boolean]) }
// 196:       def runners(cask:)
// 197:         filtered_runners = filter_runners(cask)
// 198:
// 199:         filtered_macos_found = filtered_runners.keys.any? do |runner|
// 200:           cask.to_hash_with_variations["variations"].key?(runner.fetch(:symbol).to_sym)
// 201:         end
// 202:
// 203:         if filtered_macos_found
// 204:           # If the cask varies on a MacOS version, test it on every possible macOS version.
// 205:           [filtered_runners.keys, true]
// 206:         else
// 207:           macos_runners, linux_runners = filtered_runners.partition do |runner, _|
// 208:             runner.fetch(:symbol) != :linux
// 209:           end
// 210:           selected_runners = macos_runners.group_by { |runner, _| runner.fetch(:arch) }.map do |_, runners|
// 211:             random_runner(runners.to_h)
// 212:           end + linux_runners.map(&:first)
// 213:           [selected_runners, false]
// 214:         end
// 215:       end
// 216:
// 217:       private
// 218:
// 219:       sig { params(cask: Cask::Cask, os: Symbol).returns(T::Array[Symbol]) }
// 220:       def architectures(cask:, os:)
// 221:         architectures = T.let([], T::Array[Symbol])
// 222:         [:arm, :intel].each do |arch|
// 223:           tag = Utils::Bottles::Tag.new(system: os, arch:)
// 224:           cask.refresh_for_tag(tag) do
// 225:             if cask.depends_on.arch.blank?
// 226:               architectures = RUNNERS.keys.map { |r| r.fetch(:arch).to_sym }.uniq.sort
// 227:               next
// 228:             end
// 229:
// 230:             architectures = cask.depends_on.arch.map { |arch| arch[:type] }
// 231:           end
// 232:         end
// 233:
// 234:         architectures
// 235:       end
// 236:
// 237:       sig {
// 238:         params(available_runners: T::Hash[T::Hash[Symbol, T.any(Symbol, String)],
// 239:                                           Float]).returns(T::Hash[Symbol, T.any(Symbol, String)])
// 240:       }
// 241:       def random_runner(available_runners = ARM_MACOS_RUNNERS)
// 242:         max_runner = available_runners.max_by { |(_, weight)| rand ** (1.0 / weight) }
// 243:         raise "unexpected nil max_runner" unless max_runner
// 244:
// 245:         max_runner.first
// 246:       end
// 247:
// 248:       sig {
// 249:         params(tap: T.nilable(Tap), labels: T::Array[String], cask_names: T::Array[String], skip_install: T::Boolean,
// 250:                new_cask: T::Boolean).returns(T::Array[T::Hash[Symbol,
// 251:                                                               T.any(String, T::Boolean, T::Array[String])]])
// 252:       }
// 253:       def generate_matrix(tap, labels: [], cask_names: [], skip_install: false, new_cask: false)
// 254:         odie "This command must be run from inside a tap directory." unless tap
// 255:
// 256:         changed_files = find_changed_files(tap)
// 257:
// 258:         ruby_files_in_wrong_directory =
// 259:           changed_files[:modified_ruby_files] - (
// 260:             changed_files[:modified_cask_files] +
// 261:             changed_files[:modified_command_files] +
// 262:             changed_files[:modified_github_actions_files]
// 263:           )
// 264:
// 265:         if ruby_files_in_wrong_directory.any?
// 266:           ruby_files_in_wrong_directory.each do |path|
// 267:             puts "::error file=#{path}::File is in wrong directory."
// 268:           end
// 269:
// 270:           odie "Found Ruby files in wrong directory:\n#{ruby_files_in_wrong_directory.join("\n")}"
// 271:         end
// 272:
// 273:         cask_files_to_check = if cask_names.any?
// 274:           cask_names.map do |cask_name|
// 275:             Cask::CaskLoader.find_cask_in_tap(cask_name, tap).relative_path_from(tap.path)
// 276:           end
// 277:         else
// 278:           changed_files[:modified_cask_files]
// 279:         end
// 280:
// 281:         jobs = cask_files_to_check.count
// 282:         odie "Maximum job matrix size exceeded: #{jobs}/#{MAX_JOBS}" if jobs > MAX_JOBS
// 283:
// 284:         cask_files_to_check.flat_map do |path|
// 285:           cask_token = path.basename(".rb")
// 286:
// 287:           audit_args = ["--online"]
// 288:           audit_args << "--new" if changed_files.fetch(:added_files).include?(path) || new_cask
// 289:
// 290:           audit_exceptions = []
// 291:
// 292:           audit_exceptions << %w[homepage_https_availability] if labels.include?("ci-skip-homepage")
// 293:
// 294:           if labels.include?("ci-skip-livecheck")
// 295:             audit_exceptions << %w[hosting_with_livecheck livecheck_https_availability livecheck_version min_os]
// 296:           end
// 297:
// 298:           audit_exceptions << "min_os" if labels.include?("ci-skip-livecheck-min-os")
// 299:
// 300:           if labels.include?("ci-skip-repository")
// 301:             audit_exceptions << %w[github_repository github_prerelease_version
// 302:                                    gitlab_repository gitlab_prerelease_version
// 303:                                    forgejo_repository forgejo_prerelease_version
// 304:                                    bitbucket_repository]
// 305:           end
// 306:
// 307:           audit_exceptions << %w[token_valid token_bad_words] if labels.include?("ci-skip-token")
// 308:
// 309:           audit_args << "--except" << audit_exceptions.join(",") if audit_exceptions.any?
// 310:
// 311:           cask = Cask::CaskLoader.load(path.expand_path)
// 312:
// 313:           runners, multi_os = runners(cask:)
// 314:           runner_arch_pairs(runners:, multi_os:).map do |runner, arch, native_runner_arch|
// 315:             arch_args = native_runner_arch ? [] : ["--arch=#{arch}"]
// 316:             runner_output = {
// 317:               name:         "test #{cask_token} (#{runner.fetch(:name)}, #{arch})",
// 318:               tap:          tap.name,
// 319:               cask:         {
// 320:                 token: cask_token,
// 321:                 path:  "./#{path}",
// 322:               },
// 323:               audit_args:   audit_args + arch_args,
// 324:               fetch_args:   arch_args,
// 325:               skip_install: labels.include?("ci-skip-install") || !native_runner_arch || skip_install,
// 326:               runner:       runner.fetch(:name),
// 327:             }
// 328:
// 329:             if runner.fetch(:symbol) == :linux
// 330:               runner_output[:container] = {
// 331:                 image:   "ghcr.io/homebrew/brew:main",
// 332:                 options: "--user=linuxbrew",
// 333:               }
// 334:             end
// 335:
// 336:             runner_output
// 337:           end
// 338:         end
// 339:       end
// 340:
// 341:       sig {
// 342:         params(tap: Tap).returns({
// 343:           modified_files:                T::Array[Pathname],
// 344:           added_files:                   T::Array[Pathname],
// 345:           modified_ruby_files:           T::Array[Pathname],
// 346:           modified_command_files:        T::Array[Pathname],
// 347:           modified_github_actions_files: T::Array[Pathname],
// 348:           modified_cask_files:           T::Array[Pathname],
// 349:         })
// 350:       }
// 351:       def find_changed_files(tap)
// 352:         commit_range_start = Utils.safe_popen_read("git", "rev-parse", "origin").chomp
// 353:         commit_range_end = Utils.safe_popen_read("git", "rev-parse", "HEAD").chomp
// 354:         commit_range = "#{commit_range_start}...#{commit_range_end}"
// 355:
// 356:         modified_files = Utils.safe_popen_read("git", "diff", "--name-only", "--diff-filter=AMR", commit_range)
// 357:                               .split("\n")
// 358:                               .map do |path|
// 359:           Pathname(path)
// 360:         end
// 361:
// 362:         added_files = Utils.safe_popen_read("git", "diff", "--name-only", "--diff-filter=A", commit_range)
// 363:                            .split("\n")
// 364:                            .map do |path|
// 365:           Pathname(path)
// 366:         end
// 367:
// 368:         modified_ruby_files = modified_files.select { |path| path.extname == ".rb" }
// 369:         modified_command_files = modified_files.select { |path| path.ascend.to_a.last.to_s == "cmd" }
// 370:         modified_github_actions_files = modified_files.select do |path|
// 371:           path.to_s.start_with?(".github/actions/")
// 372:         end
// 373:         modified_cask_files = modified_files.select { |path| tap.cask_file?(path.to_s) }
// 374:
// 375:         {
// 376:           modified_files:,
// 377:           added_files:,
// 378:           modified_ruby_files:,
// 379:           modified_command_files:,
// 380:           modified_github_actions_files:,
// 381:           modified_cask_files:,
// 382:         }
// 383:       end
// 384:     end
// 385:   end
// 386: end
