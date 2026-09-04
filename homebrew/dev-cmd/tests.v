module dev_cmd

import ruby
import homebrew.dev_tests

// Translated from Homebrew/brew `dev-cmd/tests.rb`.
pub struct DevTestsArgs {
pub:
	coverage    bool
	generic     bool
	online      bool
	debug       bool
	verbose     bool
	changed     bool
	fail_fast   bool
	no_parallel bool
	stackprof   bool
	vernier     bool
	ruby_prof   bool
	only        ?string
	profile     ?string
	seed        ?int
}

pub struct DevTestsContext {
pub:
	valid_gem_groups   []string
	environment        map[string]string
	env_config_keys    []string
	developer          bool
	library_path       string
	cache              string
	temp               string
	prefix             string
	real_home          string
	username           string
	ci                 bool
	hardware_arm       bool
	hardware_intel     bool
	all_spec_files     []string
	only_test_files    map[string][]string
	changed_files      []string
	test_file_contents map[string]string
	existing_paths     []string
	os_name            string
	generated_seed     int = 1
	test_success       bool = true
}

pub struct DevTestsCommand {
pub:
	program   string
	arguments []string
	shell     bool
}

pub struct DevTestsEnvironmentResult {
pub:
	environment   map[string]string
	commands      []DevTestsCommand
	removed_files []string
	fetched_api   bool
}

pub struct DevTestsRunPlan {
pub:
	groups      []string
	files       []string
	environment map[string]string
	commands    []DevTestsCommand
	warnings    []string
	output      []string
	failed      bool
	parallel    bool
	seed        int
}

pub fn dev_tests_setup_environment(context DevTestsContext,
	args DevTestsArgs) DevTestsEnvironmentResult {
	setup := dev_tests.setup_environment(dev_tests.SetupInput{
		environment: context.environment
		env_config_keys: context.env_config_keys
		developer: context.developer
		library_path: context.library_path
		cache: context.cache
		temp: context.temp
		prefix: context.prefix
		real_home: context.real_home
		username: context.username
		coverage: args.coverage
		generic: args.generic
		online: args.online
		debug: args.debug
		verbose: args.verbose
		existing_paths: context.existing_paths
	})
	commands := setup.commands.map(DevTestsCommand{
		program: it.program
		arguments: it.arguments
	})
	return DevTestsEnvironmentResult{
		environment: setup.environment
		commands: commands
		removed_files: setup.removed_files
		fetched_api: true
	}
}

pub fn dev_tests_check_test_environment() ! {}

fn dev_tests_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	return result
}

pub fn dev_tests_file_uses_rspec_tag(content string, tag string) bool {
	return dev_tests.file_uses_rspec_tag(content, tag)
}

fn dev_tests_changed_input(context DevTestsContext) dev_tests.ChangedFilesInput {
	return dev_tests.ChangedFilesInput{
		changed_files: context.changed_files
		all_spec_files: context.all_spec_files
		test_file_contents: context.test_file_contents
		existing_paths: context.existing_paths
	}
}

pub fn dev_tests_tests_tagged_with(context DevTestsContext, tag string) []string {
	return dev_tests.tests_tagged_with(dev_tests_changed_input(context), tag)
}

pub fn dev_tests_shared_context_test_files(context DevTestsContext,
	filestub string) []string {
	return dev_tests.shared_context_test_files(dev_tests_changed_input(context), filestub)
}

pub fn dev_tests_changed_test_files(context DevTestsContext) []string {
	return dev_tests.changed_test_files(dev_tests_changed_input(context))
}

pub fn dev_tests_non_macos_bundle_args(bundle_args []string, ci bool,
	online bool) []string {
	mut result := bundle_args.clone()
	if ci {
		result << ['--tag', '~needs_homebrew_core']
	}
	if !online {
		result << ['--tag', '~needs_svnadmin', '--tag', '~needs_svn']
	}
	result << ['--tag', '~needs_macos', '--tag', '~cask']
	return result
}

pub fn dev_tests_non_linux_bundle_args(bundle_args []string) []string {
	mut result := bundle_args.clone()
	result << ['--tag', '~needs_linux', '--tag', '~needs_systemd']
	return result
}

pub fn dev_tests_os_bundle_args(bundle_args []string, os_name string, ci bool,
	online bool) []string {
	return match os_name {
		'mac' { dev_tests_non_linux_bundle_args(bundle_args) }
		'linux' { dev_tests_non_macos_bundle_args(bundle_args, ci, online) }
		else {
			dev_tests_non_linux_bundle_args(dev_tests_non_macos_bundle_args(bundle_args, ci, online))
		}
	}
}

pub fn dev_tests_non_macos_files(files []string) []string {
	return files.filter(!(it.starts_with('test/os/mac/') || it == 'test/os/mac_spec.rb' || it.starts_with('test/cask/') || it == 'test/cask_spec.rb'))
}

pub fn dev_tests_non_linux_files(files []string) []string {
	return files.filter(!(it.starts_with('test/os/linux/') || it == 'test/os/linux_spec.rb'))
}

pub fn dev_tests_os_files(files []string, os_name string) []string {
	return match os_name {
		'mac' { dev_tests_non_linux_files(files) }
		'linux' { dev_tests_non_macos_files(files) }
		else { dev_tests_non_linux_files(dev_tests_non_macos_files(files)) }
	}
}

pub fn dev_tests_run(context DevTestsContext, args DevTestsArgs) !DevTestsRunPlan {
	mut groups := context.valid_gem_groups.filter(it != 'sorbet')
	if args.stackprof || args.vernier || args.ruby_prof {
		groups << 'prof'
	}
	setup := dev_tests_setup_environment(context, args)
	dev_tests_check_test_environment()!
	mut environment := setup.environment.clone()
	mut commands := [DevTestsCommand{
		program: 'install_bundler_gems'
		arguments: groups.clone()
	}]
	commands << setup.commands
	mut parallel := !args.no_parallel
	mut files := []string{}
	if only := args.only {
		for test in only.split(',') {
			if separator := test.index(':') {
				test_name := test[..separator]
				line := test[separator + 1..]
				if line != '' {
					parallel = false
					files << 'test/${test_name}_spec.rb:${line}'
					continue
				}
			}
			matched := context.only_test_files[test] or { []string{} }
			if matched.len == 0 {
				return error('Invalid `--only` argument: ${test}')
			}
			files << matched
		}
	} else if args.changed {
		files = dev_tests_changed_test_files(context)
	} else {
		files = context.all_spec_files.clone()
	}
	mut warnings := []string{}
	if files.len == 0 {
		if args.only != none {
			return error('The `--only` argument requires a valid file or folder name!')
		}
		if args.changed {
			warnings << 'No tests are directly associated with the changed files!'
			return DevTestsRunPlan{
				groups: groups
				environment: environment
				commands: commands
				warnings: warnings
				parallel: parallel
			}
		}
	}
	mut log_name := 'parallel_runtime_rspec'
	if args.generic {
		log_name += '.generic'
	}
	if args.online {
		log_name += '.online'
	}
	log_name += '.log'
	log_path := if context.ci {
		'tests/${log_name}'
	} else {
		ruby.join_path(context.cache, log_name)
	}
	environment['PARALLEL_RSPEC_LOG_PATH'] = log_path
	parallel_args := if context.ci {
		['--combine-stderr', '--serialize-stdout', '--runtime-log', log_path]
	} else {
		['--nice']
	}
	seed := args.seed or { context.generated_seed }
	mut bundle_args := ['-I', ruby.join_path(context.library_path, 'test'), '--seed', seed.str(),
		'--color', '--require', 'spec_helper']
	if args.fail_fast {
		bundle_args << '--fail-fast'
	}
	if profile := args.profile {
		bundle_args << ['--profile', profile]
	}
	if !context.hardware_arm {
		bundle_args << ['--tag', '~needs_arm']
	}
	if !context.hardware_intel {
		bundle_args << ['--tag', '~needs_intel']
	}
	if !args.online {
		bundle_args << ['--tag', '~needs_network']
	}
	if !context.ci {
		bundle_args << ['--tag', '~needs_ci']
	}
	bundle_args = dev_tests_os_bundle_args(bundle_args, context.os_name, context.ci, args.online)
	files = dev_tests_os_files(files, context.os_name)
	mut output := ['Randomized with seed ${seed}']
	if args.debug {
		environment['HOMEBREW_DEBUG'] = '1'
	}
	test_prof := ruby.join_path(context.library_path, 'tmp/test_prof')
	mut prof_input_filename := ''
	mut prof_filename := ''
	if args.stackprof {
		environment['TEST_STACK_PROF'] = '1'
		prof_input_filename = ruby.join_path(test_prof, 'stack-prof-report-wall-raw-total.dump')
		prof_filename = ruby.join_path(test_prof, 'stack-prof-report-wall-raw-total.html')
	} else if args.vernier {
		environment['TEST_VERNIER'] = '1'
	} else if args.ruby_prof {
		environment['TEST_RUBY_PROF'] = 'call_stack'
		prof_filename = ruby.join_path(test_prof, 'ruby-prof-report-call_stack-wall-total.html')
	}
	if parallel {
		mut command_args := ['exec', 'parallel_rspec']
		command_args << parallel_args
		command_args << '--'
		command_args << bundle_args
		command_args << '--'
		command_args << files
		commands << DevTestsCommand{
			program: 'bundle'
			arguments: command_args
		}
	} else {
		mut command_args := ['exec', 'rspec']
		command_args << bundle_args
		command_args << '--'
		command_args << files
		commands << DevTestsCommand{
			program: 'bundle'
			arguments: command_args
		}
	}
	if args.stackprof {
		commands << DevTestsCommand{
			program: 'stackprof'
			arguments: ['--d3-flamegraph', prof_input_filename, '>', prof_filename]
			shell: true
		}
	}
	if prof_filename != '' {
		commands << DevTestsCommand{
			program: 'browser'
			arguments: [prof_filename]
		}
	}
	return DevTestsRunPlan{
		groups: groups
		files: files
		environment: environment
		commands: commands
		warnings: warnings
		output: output
		failed: !context.test_success
		parallel: parallel
		seed: seed
	}
}
