module cmd

// Translated from Homebrew/brew `cmd/bundle.rb`.
pub const bundle_command_subcommands = ['add', 'check', 'cleanup', 'dump', 'edit', 'env', 'exec',
	'install', 'list', 'remove', 'sh', 'upgrade']

pub const bundle_command_extension_types = ['cargo', 'flatpak', 'go', 'krew', 'mas', 'npm', 'uv',
	'vscode', 'winget']

pub struct BundleDependencyCheck {
pub:
	work_to_be_done bool
	errors          []string
}

pub struct BundleCheckCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub struct BundleExecInvocationOptions {
pub:
	check      bool
	no_secrets bool
	services   bool
	global     bool
	file       string
}

pub struct BundleExecInvocation {
pub:
	command string
	args    []string
	options BundleExecInvocationOptions
}

pub struct BundleCommandConfig {
pub:
	environment      map[string]string
	processor_count  int = 1
	dependency_check BundleDependencyCheck
}

pub struct BundleCommandArgs {
pub mut:
	subcommand       string = 'install'
	named            []string
	global           bool
	file             ?string
	verbose          bool
	quiet            bool
	force            bool
	cleanup          bool
	force_cleanup    bool
	zap              bool
	upgrade          bool
	no_upgrade       bool
	jobs             string
	jobs_set         bool
	all              bool
	install          bool
	check            bool
	services         bool
	no_secrets       bool
	describe         bool
	no_describe      bool
	selected_types   map[string]bool
	disabled_types   map[string]bool
	dump_disabled    map[string]bool
	cleanup_disabled map[string]bool
}

pub struct BundleSubcommandContext {
pub:
	subcommand   string
	global       bool
	file         ?string
	no_upgrade   bool
	verbose      bool
	force        bool
	ask          bool
	jobs         int
	zap          bool
	no_type_args bool
}

pub struct BundleCommandResult {
pub:
	args                BundleCommandArgs
	context             BundleSubcommandContext
	dispatched          string
	install_before      bool
	ask_environment_off bool
	environment_after   map[string]string
	external_invocation BundleExecInvocation
	check_result        BundleCheckCommandResult
}

fn bundle_env_enabled(environment map[string]string, name string) bool {
	value := environment[name] or { return false }
	return value != '' && value.to_lower() !in ['false', 'no', 'off', 'nil', '0']
}

fn bundle_env_jobs(environment map[string]string) string {
	if bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_NO_JOBS') {
		return ''
	}
	value := environment['HOMEBREW_BUNDLE_JOBS'] or { return 'auto' }
	return if value == '' { 'auto' } else { value }
}

fn bundle_all_types() []string {
	mut types := ['brew', 'cask', 'tap']
	types << bundle_command_extension_types
	return types
}

fn bundle_canonical_type_flag(argument string) ?string {
	return match argument {
		'--formula', '--formulae', '--brews' { 'brew' }
		'--cask', '--casks' { 'cask' }
		'--tap', '--taps' { 'tap' }
		else {
			name := argument.trim_left('-')
			if name in bundle_command_extension_types { name } else { none }
		}
	}
}

fn bundle_canonical_disabled_type_flag(argument string) ?string {
	return match argument {
		'--no-formula', '--no-formulae', '--no-brews' { 'brew' }
		'--no-cask', '--no-casks' { 'cask' }
		'--no-tap', '--no-taps' { 'tap' }
		else {
			if argument.starts_with('--no-') {
				name := argument['--no-'.len..]
				if name in bundle_command_extension_types { name } else { none }
			} else {
				none
			}
		}
	}
}

fn bundle_select_type(mut parsed BundleCommandArgs, type_name string) ! {
	if parsed.disabled_types[type_name] {
		return error('options `--${type_name}` and `--no-${type_name}` are mutually exclusive')
	}
	parsed.selected_types[type_name] = true
	parsed.dump_disabled.delete(type_name)
	parsed.cleanup_disabled.delete(type_name)
}

fn bundle_disable_type(mut parsed BundleCommandArgs, type_name string) ! {
	if parsed.selected_types[type_name] {
		return error('options `--${type_name}` and `--no-${type_name}` are mutually exclusive')
	}
	parsed.disabled_types[type_name] = true
}

fn bundle_apply_environment(mut parsed BundleCommandArgs, environment map[string]string) {
	if parsed.subcommand == 'install' && parsed.global {
		parsed.cleanup = parsed.cleanup || bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_INSTALL_CLEANUP')
		parsed.force_cleanup = parsed.force_cleanup || bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP')
	}
	if parsed.subcommand == 'dump' {
		for type_name in bundle_all_types() {
			key := 'HOMEBREW_BUNDLE_DUMP_NO_${type_name.to_upper()}'
			if bundle_env_enabled(environment, key) && !parsed.selected_types[type_name] {
				parsed.dump_disabled[type_name] = true
			}
		}
	}
	if parsed.subcommand == 'cleanup' {
		for type_name in bundle_all_types() {
			key := 'HOMEBREW_BUNDLE_CLEANUP_NO_${type_name.to_upper()}'
			if bundle_env_enabled(environment, key) && !parsed.selected_types[type_name] {
				parsed.cleanup_disabled[type_name] = true
			}
		}
	}
}

pub fn parse_bundle_command_args(argv []string, environment map[string]string) !BundleCommandArgs {
	mut parsed := BundleCommandArgs{
		no_upgrade: bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_NO_UPGRADE')
		check: bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_CHECK')
		no_secrets: !bundle_env_enabled(environment, 'HOMEBREW_BUNDLE_SECRETS')
		selected_types: map[string]bool{}
		disabled_types: map[string]bool{}
		dump_disabled: map[string]bool{}
		cleanup_disabled: map[string]bool{}
	}
	mut index := 0
	if argv.len > 0 && !argv[0].starts_with('-') && argv[0] in bundle_command_subcommands {
		parsed.subcommand = if argv[0] == 'upgrade' { 'install' } else { argv[0] }
		parsed.upgrade = argv[0] == 'upgrade'
		index++
	}
	for index < argv.len {
		argument := argv[index]
		if argument == '--' {
			parsed.named << argv[index + 1..]
			break
		}
		if selected_type := bundle_canonical_type_flag(argument) {
			bundle_select_type(mut parsed, selected_type)!
			index++
			continue
		}
		if disabled_type := bundle_canonical_disabled_type_flag(argument) {
			bundle_disable_type(mut parsed, disabled_type)!
			index++
			continue
		}
		match argument {
			'--global', '-g' {
				parsed.global = true
			}
			'--verbose', '-v' {
				parsed.verbose = true
			}
			'--quiet', '-q' {
				parsed.quiet = true
			}
			'--force', '-f' {
				parsed.force = true
			}
			'--cleanup' {
				parsed.cleanup = true
			}
			'--force-cleanup' {
				parsed.force_cleanup = true
			}
			'--zap' {
				parsed.zap = true
			}
			'--upgrade' {
				parsed.upgrade = true
			}
			'--no-upgrade' {
				parsed.no_upgrade = true
			}
			'--all' {
				parsed.all = true
			}
			'--install' {
				parsed.install = true
			}
			'--check' {
				parsed.check = true
			}
			'--services' {
				parsed.services = true
			}
			'--no-secrets' {
				parsed.no_secrets = true
			}
			'--describe' {
				parsed.describe = true
			}
			'--no-describe' {
				parsed.no_describe = true
			}
			'--no-dump-brew' {
				parsed.dump_disabled['brew'] = true
			}
			'--no-dump-cask' {
				parsed.dump_disabled['cask'] = true
			}
			'--no-dump-tap' {
				parsed.dump_disabled['tap'] = true
			}
			'--no-cleanup-brew' {
				parsed.cleanup_disabled['brew'] = true
			}
			'--no-cleanup-cask' {
				parsed.cleanup_disabled['cask'] = true
			}
			'--no-cleanup-tap' {
				parsed.cleanup_disabled['tap'] = true
			}
			else {
				if argument.starts_with('--file=') {
					parsed.file = argument.all_after('=')
				} else if argument == '--file' {
					if index + 1 >= argv.len {
						return error('`--file` requires a value')
					}
					index++
					parsed.file = argv[index]
				} else if argument.starts_with('--jobs=') {
					parsed.jobs = argument.all_after('=')
					parsed.jobs_set = true
				} else if argument.starts_with('--no-dump-') {
					type_name := argument['--no-dump-'.len..]
					if type_name !in bundle_command_extension_types {
						return error('Unknown option: ${argument}')
					}
					parsed.dump_disabled[type_name] = true
				} else if argument.starts_with('--no-cleanup-') {
					type_name := argument['--no-cleanup-'.len..]
					if type_name !in bundle_command_extension_types {
						return error('Unknown option: ${argument}')
					}
					parsed.cleanup_disabled[type_name] = true
				} else if argument.starts_with('-') && !argument.starts_with('--') {
					for short_option in argument[1..] {
						match short_option {
							`f` {
								parsed.force = true
							}
							`g` {
								parsed.global = true
							}
							`q` {
								parsed.quiet = true
							}
							`v` {
								parsed.verbose = true
							}
							else {
								return error('Unknown option: -${short_option.ascii_str()}')
							}
						}
					}
				} else if argument.starts_with('--') {
					return error('Unknown option: ${argument}')
				} else {
					parsed.named << argument
				}
			}
		}
		index++
	}
	if parsed.global && parsed.file != none {
		return error('options `--file` and `--global` are mutually exclusive')
	}
	if parsed.subcommand != 'install' && parsed.jobs_set {
		return error('`${parsed.subcommand}` subcommand does not accept the `--jobs` flag')
	}
	if parsed.upgrade {
		parsed.no_upgrade = false
	}
	bundle_apply_environment(mut parsed, environment)
	return parsed
}

pub fn bundle_command_context(args BundleCommandArgs, config BundleCommandConfig,
	ask bool) BundleSubcommandContext {
	jobs_argument := if args.jobs_set { args.jobs } else { bundle_env_jobs(config.environment) }
	mut jobs := 1
	if jobs_argument == 'auto' {
		processors := if config.processor_count > 0 { config.processor_count } else { 1 }
		jobs = if processors < 4 { processors } else { 4 }
	} else if jobs_argument != '' {
		jobs = jobs_argument.int()
	}
	if jobs < 1 {
		jobs = 1
	}
	return BundleSubcommandContext{
		subcommand: args.subcommand
		global: args.global
		file: args.file
		no_upgrade: if args.upgrade { false } else { args.no_upgrade }
		verbose: args.verbose
		force: args.force
		ask: ask
		jobs: jobs
		zap: args.zap
		no_type_args: args.selected_types.values().all(!it)
	}
}

fn bundle_ask_enabled(environment map[string]string) bool {
	return !bundle_env_enabled(environment, 'HOMEBREW_NO_ASK')
}

fn render_bundle_command_check(check BundleDependencyCheck) BundleCheckCommandResult {
	if !check.work_to_be_done {
		return BundleCheckCommandResult{
			stdout: "The Brewfile's dependencies are satisfied.\n"
		}
	}
	return BundleCheckCommandResult{
		exit_code: 1
		stderr: "brew bundle can't satisfy your Brewfile's dependencies.\n"
	}
}

pub fn dispatch_bundle_command(args BundleCommandArgs,
	config BundleCommandConfig) !BundleCommandResult {
	ask := bundle_ask_enabled(config.environment)
	context := bundle_command_context(args, config, ask)
	mut environment_after := config.environment.clone()
	environment_after.delete('HOMEBREW_ASK')
	environment_after['HOMEBREW_NO_ASK'] = '1'
	mut invocation := BundleExecInvocation{}
	mut check_result := BundleCheckCommandResult{}
	exec_options := BundleExecInvocationOptions{
		check: args.check
		no_secrets: args.no_secrets
		services: args.services
		global: args.global
		file: args.file or { '' }
	}
	match args.subcommand {
		'exec' {
			if args.named.len == 0 || args.named[0] == '' {
				return error('No command to execute was specified!')
			}
			invocation = BundleExecInvocation{
				command: args.named[0]
				args: args.named.clone()
				options: exec_options
			}
		}
		'sh' {
			invocation = BundleExecInvocation{ command: 'sh', args: ['sh'], options: exec_options }
		}
		'env' {
			invocation = BundleExecInvocation{ command: 'env', args: ['env'], options: exec_options }
		}
		'check' {
			check_result = render_bundle_command_check(config.dependency_check)
		}
		'add', 'cleanup', 'dump', 'edit', 'install', 'list', 'remove' {}
		else {
			return error('Unknown subcommand: ${args.subcommand}')
		}
	}
	return BundleCommandResult{
		args: args
		context: context
		dispatched: args.subcommand
		install_before: args.install && args.subcommand != 'install'
		ask_environment_off: true
		environment_after: environment_after
		external_invocation: invocation
		check_result: check_result
	}
}

pub fn run_bundle_command(argv []string, config BundleCommandConfig) !BundleCommandResult {
	parsed := parse_bundle_command_args(argv, config.environment)!
	return dispatch_bundle_command(parsed, config)
}

pub fn bundle_subcommand_options(subcommand string) map[string]string {
	mut options := map[string]string{}
	match subcommand {
		'install' {
			options['--force-cleanup'] = 'Uninstall all dependencies not listed in the Brewfile without prompting. Enabled by `\$HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP` when `--global` is passed.'
		}
		'list' {
			options['--vscode'] = 'List VSCode (and forks/variants) extensions.'
		}
		'dump' {
			options['--vscode'] = 'Dump VSCode (and forks/variants) extensions.'
			options['--no-mas'] = 'Run `dump` without Mac App Store dependencies.'
			options['--no-describe'] = 'Do not include description comments. Description comments are the default.'
		}
		'cleanup' {
			options['--vscode'] = 'Clean up VSCode (and forks/variants) extensions.'
			options['--no-mas'] = 'Run `cleanup` without Mac App Store dependencies.'
			options['--all'] = 'Clean up all supported dependencies.'
			options['--force'] = "Actually perform cleanup operations and reset Homebrew's global trust store to the `Brewfile` values."
		}
		'add' {
			options['--no-describe'] = 'Do not include description comments. Description comments are the default.'
			options['--vscode'] = 'Add entries for VSCode (and forks/variants) extensions.'
		}
		'remove' {
			options['--vscode'] = 'Remove entries for VSCode (and forks/variants) extensions.'
		}
		'upgrade' {
			options['--force'] = 'Run with `--force`/`--overwrite`.'
		}
		else {}
	}
	return options
}

pub fn bundle_help_text(subcommand string) string {
	options := bundle_subcommand_options(subcommand)
	mut names := options.keys()
	names.sort()
	mut lines := ['Usage: brew bundle ${subcommand}']
	for name in names {
		lines << '  ${name}  ${options[name]}'
	}
	return '${lines.join('\n')}\n'
}
