module cmd

import homebrew.cli

// Translated from Homebrew/brew `cmd/install.rb`.
pub struct InstallCommandOptions {
pub:
	parsed                   cli.Args
	names                    []string
	package_type             string
	dry_run                  bool
	no_ask                   bool
	ask                      bool
	force                    bool
	verbose                  bool
	quiet                    bool
	debug                    bool
	formula                  bool
	cask                     bool
	ignore_dependencies      bool
	only_dependencies        bool
	build_from_source        bool
	force_bottle             bool
	include_test             bool
	head                     bool
	fetch_head               bool
	keep_tmp                 bool
	debug_symbols            bool
	build_bottle             bool
	skip_post_install        bool
	skip_link                bool
	as_dependency            bool
	interactive              bool
	git                      bool
	overwrite                bool
	binaries                 bool
	require_sha              bool
	adopt                    bool
	skip_cask_dependencies   bool
	zap                      bool
	display_times            bool
	environment              string
	compiler                 string
	bottle_architecture      string
	preferred_cask_languages []string
}

pub struct InstallCommandPlan {
pub:
	options  InstallCommandOptions
	warnings []string
}

pub struct InstallPackageReference {
pub:
	name string
	kind string
}

pub struct InstallCommandTap {
pub:
	name         string
	ensure_error string
}

pub struct InstallCommandFormula {
pub:
	name           string
	full_name      string
	dependencies   []InstallCommandDependency
	ignore_deps    bool
	prelude_error  string
	enqueue_error  string
	install_error  string
	linked         bool
	outdated       bool
	head           bool
	install        bool = true
	bottled        bool = true
	decision_error string
}

pub struct InstallCommandCask {
pub:
	full_name            string
	installed            bool
	installed_version    string
	version              string
	outdated             bool
	dependencies         []InstallCommandDependency
	runtime_dependencies []InstallCommandDependency
	prelude_error        string
	enqueue_error        string
	install_error        string
}

pub struct InstallCommandDependency {
pub:
	name      string
	full_name string
	installed bool
}

pub struct InstallCommandEnvironment {
pub:
	development_tools_installed bool = true
	developer                   bool
	no_install_upgrade          bool
	verify_attestations         bool
}

pub struct InstallCommandContext {
pub:
	arguments             []string
	formulae              []InstallCommandFormula
	casks                 []InstallCommandCask
	taps                  []InstallCommandTap
	environment           InstallCommandEnvironment
	dependant_upgradeable []string
	failed_downloads      []string
	stdin_tty             bool
	stdout_tty            bool
	ask_characters        []int
	ask_interrupt_index   int = -1
	prior_failed          bool
	unavailable_name      string
	unavailable_message   string
	missing_reason        string
	search_formulae       []string
	search_casks          []string
	cask_dry_run_output   string
	cask_ask_output       string
	cask_prompt_needed    bool
	formula_ask_output    string
	formula_prompt_needed bool
	confirmations         []InstallCommandConfirmation
	downloads_heading     string
}

pub struct InstallCommandConfirmation {
pub:
	output   string
	accepted bool
	exited   bool
}

pub struct InstallCommandRunResult {
pub:
	options               InstallCommandOptions
	stdout                string
	stderr                string
	events                []string
	formulae_installed    []string
	casks_installed       []string
	casks_upgraded        []string
	failed                bool
	returned_early        bool
	download_queue_closed bool
}

// new_install_parser translates InstallCmd's cmd_args declaration. Parsing is
// deliberately separate from package loading so option and conflict behaviour
// remains available while Formula and Cask construction is still untranslated.
pub fn new_install_parser() cli.Parser {
	mut parser := cli.new_parser('install')
	parser.add_switch(['--display-times'], cli.OptionConfig{})
	parser.add_switch(['-f', '--force'], cli.OptionConfig{})
	parser.add_switch(['-n', '--dry-run'], cli.OptionConfig{})
	parser.add_switch(['--no-ask', '--yes', '-y'], cli.OptionConfig{})
	parser.add_switch(['--ask'], cli.OptionConfig{})

	formula_switches := [
		['--formula', '--formulae'],
		['--ignore-dependencies'],
		['--only-dependencies'],
		['-s', '--build-from-source'],
		['--force-bottle'],
		['--include-test'],
		['--HEAD'],
		['--fetch-HEAD'],
		['--keep-tmp'],
		['--build-bottle'],
		['--skip-post-install'],
		['--skip-link'],
		['--as-dependency'],
		['-i', '--interactive'],
		['-g', '--git'],
		['--overwrite'],
	]
	for names in formula_switches {
		parser.add_switch(names, cli.OptionConfig{})
		parser.add_conflicts(['--cask', names[names.len - 1]])
	}
	parser.add_flag(['--env='], cli.OptionConfig{
		hidden: true
	})
	parser.add_conflicts(['--cask', '--env'])
	parser.add_flag(['--cc='], cli.OptionConfig{})
	parser.add_conflicts(['--cask', '--cc'])
	parser.add_switch(['--debug-symbols'], cli.OptionConfig{
		depends_on: '--build-from-source'
	})
	parser.add_conflicts(['--cask', '--debug-symbols'])
	parser.add_flag(['--bottle-arch='], cli.OptionConfig{
		depends_on: '--build-bottle'
	})
	parser.add_conflicts(['--cask', '--bottle-arch'])

	cask_switches := [
		['--cask', '--casks'],
		['--[no-]binaries'],
		['--require-sha'],
		['--adopt'],
		['--skip-cask-deps'],
		['--zap'],
	]
	for names in cask_switches {
		parser.add_switch(names, cli.OptionConfig{})
		parser.add_conflicts(['--formula', names[names.len - 1]])
	}
	cask_directory_flags := [
		'--appdir=',
		'--appimagedir=',
		'--keyboard-layoutdir=',
		'--colorpickerdir=',
		'--prefpanedir=',
		'--qlplugindir=',
		'--mdimporterdir=',
		'--dictionarydir=',
		'--fontdir=',
		'--servicedir=',
		'--input-methoddir=',
		'--internet-plugindir=',
		'--audio-unit-plugindir=',
		'--vst-plugindir=',
		'--vst3-plugindir=',
		'--screen-saverdir=',
	]
	for flag in cask_directory_flags {
		parser.add_flag([flag], cli.OptionConfig{})
		parser.add_conflicts(['--formula', flag])
	}
	parser.add_comma_array('--language=', cli.OptionConfig{})
	parser.add_conflicts(['--formula', '--language'])

	parser.add_conflicts(['--ignore-dependencies', '--only-dependencies'])
	parser.add_conflicts(['--ask', '--no-ask'])
	parser.add_conflicts(['--build-from-source', '--build-bottle', '--force-bottle'])
	parser.add_conflicts(['--adopt', '--force'])
	parser.set_named_args(['formula', 'cask'], 1, none)
	return parser
}

pub fn parse_install_arguments(arguments []string) !InstallCommandOptions {
	mut parser := new_install_parser()
	parsed := parser.parse(arguments, false)!
	package_type := parsed.only_formula_or_cask() or { '' }
	binaries := parsed.switch_value('binaries') or { true }
	return InstallCommandOptions{
		parsed: parsed
		names: parsed.named.values.clone()
		package_type: package_type
		dry_run: parsed.has('dry_run')
		no_ask: parsed.has('no_ask')
		ask: parsed.has('ask')
		force: parsed.has('force')
		verbose: parsed.has('verbose')
		quiet: parsed.has('quiet')
		debug: parsed.has('debug')
		formula: parsed.has('formula')
		cask: parsed.has('cask')
		ignore_dependencies: parsed.has('ignore_dependencies')
		only_dependencies: parsed.has('only_dependencies')
		build_from_source: parsed.has('build_from_source')
		force_bottle: parsed.has('force_bottle')
		include_test: parsed.has('include_test')
		head: parsed.has('HEAD')
		fetch_head: parsed.has('fetch_HEAD')
		keep_tmp: parsed.has('keep_tmp')
		debug_symbols: parsed.has('debug_symbols')
		build_bottle: parsed.has('build_bottle')
		skip_post_install: parsed.has('skip_post_install')
		skip_link: parsed.has('skip_link')
		as_dependency: parsed.has('as_dependency')
		interactive: parsed.has('interactive')
		git: parsed.has('git')
		overwrite: parsed.has('overwrite')
		binaries: binaries
		require_sha: parsed.has('require_sha')
		adopt: parsed.has('adopt')
		skip_cask_dependencies: parsed.has('skip_cask_deps')
		zap: parsed.has('zap')
		display_times: parsed.has('display_times')
		environment: parsed.flag_value('env') or { '' }
		compiler: parsed.flag_value('cc') or { '' }
		bottle_architecture: parsed.flag_value('bottle_arch') or { '' }
		preferred_cask_languages: parsed.comma_array_value('language') or { []string{} }
	}
}

pub fn plan_install_command(arguments []string) !InstallCommandPlan {
	options := parse_install_arguments(arguments)!
	mut warnings := []string{}
	if options.environment.len > 0 {
		warnings << '`brew install --env` is disabled; use `env :std` in specific formula files.'
	}
	if options.ignore_dependencies {
		warnings << '`--ignore-dependencies` is an unsupported Homebrew developer option!\nAdjust your PATH to put any preferred versions of applications earlier in the\nPATH rather than using this unsupported option!'
	}
	if options.compiler.len > 0 {
		warnings << 'You passed `--cc=${options.compiler}`.\n\nThis is a Tier 3 configuration.'
	}
	return InstallCommandPlan{
		options: options
		warnings: warnings
	}
}

// Package loading is the first unavailable object boundary reached by the Ruby
// run method. It is kept source-named instead of delegating to Ruby or brew.
pub fn load_install_packages(options InstallCommandOptions) ![]InstallPackageReference {
	references := options.parsed.named.to_formulae_and_casks()!
	return references.map(InstallPackageReference{
		name: it.full_name
		kind: it.kind.str()
	})
}

fn append_unique_command_cask(mut casks []InstallCommandCask, cask InstallCommandCask) {
	if casks.all(it.full_name != cask.full_name) {
		casks << cask
	}
}

fn install_command_formula_name(formula InstallCommandFormula) string {
	return if formula.name.len > 0 { formula.name } else { formula.full_name }
}

fn install_command_prelude(formulae []InstallCommandFormula,
	events []string, stderr string) ([]InstallCommandFormula, []string, string, bool) {
	mut selected := []InstallCommandFormula{}
	mut next_events := events.clone()
	mut next_stderr := stderr
	mut failed := false
	for formula in formulae {
		name := install_command_formula_name(formula)
		next_events << 'assign_download_queue'
		next_events << 'prelude_fetch:${name}'
		if formula.prelude_error.len > 0 {
			next_stderr += 'Error: ${formula.full_name}: ${formula.prelude_error}\n'
			failed = true
			continue
		}
		selected << formula
	}
	return selected, next_events, next_stderr, failed
}

fn install_command_enqueue_formulae(formulae []InstallCommandFormula,
	events []string, stderr string) ([]InstallCommandFormula, []string, string, bool) {
	mut selected := []InstallCommandFormula{}
	mut next_events := events.clone()
	mut next_stderr := stderr
	mut failed := false
	for formula in formulae {
		name := install_command_formula_name(formula)
		next_events << 'prelude:${name}'
		next_events << 'enqueue_fetch:${name}'
		if formula.enqueue_error.len > 0 {
			next_stderr += 'Error: ${formula.full_name}: ${formula.enqueue_error}\n'
			failed = true
			continue
		}
		selected << formula
	}
	return selected, next_events, next_stderr, failed
}

fn install_command_install_formulae(formulae []InstallCommandFormula, dry_run bool,
	stderr string) ([]string, string, bool) {
	if dry_run {
		return []string{}, stderr, false
	}
	mut installed := []string{}
	mut next_stderr := stderr
	mut failed := false
	for formula in formulae {
		if formula.install_error.len > 0 {
			next_stderr += 'Error: ${formula.full_name}: ${formula.install_error}\n'
			failed = true
			continue
		}
		installed << install_command_formula_name(formula)
	}
	return installed, next_stderr, failed
}

fn install_command_unavailable(context InstallCommandContext,
	options InstallCommandOptions) InstallCommandRunResult {
	name := context.unavailable_name
	mut stderr := ''
	mut stdout := ''
	if name == 'updog' {
		return InstallCommandRunResult{
			options: options
			stderr: "Error: What's updog?\n"
			failed: true
			returned_early: true
		}
	}
	message := if context.unavailable_message.len > 0 {
		context.unavailable_message
	} else {
		'No available formula or cask with the name "${name}".'
	}
	stderr += 'Warning: ${message}\n'
	if !options.cask && context.missing_reason.len > 0 {
		stderr += '${context.missing_reason}\n'
		return InstallCommandRunResult{
			options: options
			stderr: stderr
			failed: true
			returned_early: true
		}
	}
	if name.contains('/') {
		return InstallCommandRunResult{
			options: options
			stderr: stderr
			failed: true
			returned_early: true
		}
	}
	mut package_types := []string{}
	if !options.cask {
		package_types << 'formulae'
	}
	if !options.formula {
		package_types << 'casks'
	}
	stdout += '==> Searching for similarly named ${package_types.join(' and ')}...\n'
	if context.search_formulae.len > 0 {
		stdout += '==> Formulae\n${context.search_formulae.join(' ')}\n\nTo install ${context.search_formulae[0]}, run:\n  brew install ${context.search_formulae[0]}\n'
	}
	if context.search_formulae.len > 0 && context.search_casks.len > 0 {
		stdout += '\n'
	}
	if context.search_casks.len > 0 {
		stdout += '==> Casks\n${context.search_casks.join(' ')}\n\nTo install ${context.search_casks[0]}, run:\n  brew install --cask ${context.search_casks[0]}\n'
	}
	if context.search_formulae.len == 0 && context.search_casks.len == 0 {
		stderr += 'Error: No ${package_types.join(' or ')} found for ${name}.\n'
	}
	return InstallCommandRunResult{
		options: options
		stdout: stdout
		stderr: stderr
		failed: true
		returned_early: true
	}
}

pub fn execute_install_command(context InstallCommandContext) !InstallCommandRunResult {
	plan := plan_install_command(context.arguments)!
	options := plan.options
	mut stdout := ''
	mut stderr := ''
	mut events := []string{}
	mut failed := context.prior_failed
	for warning in plan.warnings {
		stderr += 'Warning: ${warning}\n'
	}
	for tap in context.taps {
		events << 'ensure_tap:${tap.name}'
		if tap.ensure_error.len > 0 {
			stderr += 'Error: ${tap.ensure_error}\n'
			return InstallCommandRunResult{
				options: options
				stdout: stdout
				stderr: stderr
				events: events
				failed: true
				returned_early: true
			}
		}
	}
	events << 'trust:${options.names.join(',')}'
	events << 'resolve_packages'
	if context.unavailable_name.len > 0 {
		mut result := install_command_unavailable(context, options)
		result = InstallCommandRunResult{
			...result
			events: events
		}
		return result
	}

	mut formulae := context.formulae.clone()
	if context.environment.verify_attestations {
		// The attestation collaborator supplies the source-defined order.
		events << 'sort_formulae_for_install'
	}
	all_casks := context.casks.clone()
	ask := !options.no_ask
	if all_casks.len > 0 && options.dry_run {
		stdout += context.cask_dry_run_output
		return InstallCommandRunResult{
			options: options
			stdout: stdout
			stderr: stderr
			events: events
			failed: failed
			returned_early: true
		}
	}

	installed_casks := all_casks.filter(it.installed)
	new_casks := all_casks.filter(!it.installed)
	mut upgrade_casks := []InstallCommandCask{}
	mut fetch_casks := []InstallCommandCask{}
	if context.environment.no_install_upgrade {
		fetch_casks = new_casks.clone()
	} else {
		upgrade_casks = all_casks.filter(it.outdated)
		for cask in new_casks {
			append_unique_command_cask(mut fetch_casks, cask)
		}
		for cask in upgrade_casks {
			append_unique_command_cask(mut fetch_casks, cask)
		}
	}
	if fetch_casks.len > 0 && ask {
		stdout += context.cask_ask_output
		if context.cask_prompt_needed && context.stdin_tty && context.stdout_tty {
			confirmation := if context.confirmations.len > 0 {
				context.confirmations[0]
			} else {
				InstallCommandConfirmation{}
			}
			stdout += confirmation.output
			if confirmation.exited {
				return InstallCommandRunResult{
					options: options
					stdout: stdout
					stderr: stderr
					events: events
					failed: true
					returned_early: true
					download_queue_closed: true
				}
			}
		}
	}

	mut build_flags := []string{}
	if !context.environment.development_tools_installed {
		if options.head {
			build_flags << '--HEAD'
		}
		if options.build_bottle {
			build_flags << '--build-bottle'
		}
		if options.build_from_source {
			build_flags << '--build-from-source'
		}
		if build_flags.len > 0 {
			stderr += 'Error: Building from source requires developer tools: ${build_flags.join(', ')}\n'
			return InstallCommandRunResult{
				options: options
				stdout: stdout
				stderr: stderr
				events: events
				failed: true
				returned_early: true
			}
		}
	}
	if build_flags.len > 0 && !context.environment.developer {
		stderr += 'Warning: building from source is not supported!\n'
		stdout += "You're on your own. Failures are expected so don't create any issues, please!\n"
	}

	mut selected := []InstallCommandFormula{}
	for formula in formulae {
		if formula.decision_error.len > 0 {
			stderr += 'Error: ${formula.decision_error}\n'
			failed = true
			continue
		}
		if formula.install {
			selected << formula
		}
	}
	if formulae.len > 0 && selected.len == 0 && all_casks.len == 0 {
		return InstallCommandRunResult{
			options: options
			stdout: stdout
			stderr: stderr
			events: events
			failed: failed
			returned_early: true
		}
	}

	mut queue_closed := false
	if !options.dry_run && selected.len > 0 {
		events << 'new_download_queue'
		mut prelude_failed := false
		selected, events, stderr, prelude_failed = install_command_prelude(selected, events, stderr)
		failed = failed || prelude_failed
	}
	events << 'perform_preinstall_checks_once'
	events << 'check_cc_argv'
	events << 'dependants'
	if ask && selected.len > 0 {
		events << 'download_bottle_manifests'
		stdout += context.formula_ask_output
		if context.formula_prompt_needed && context.stdin_tty && context.stdout_tty {
			confirmation_index := if context.cask_prompt_needed { 1 } else { 0 }
			confirmation := if confirmation_index < context.confirmations.len {
				context.confirmations[confirmation_index]
			} else {
				InstallCommandConfirmation{}
			}
			stdout += confirmation.output
			if confirmation.exited {
				events << 'shutdown'
				return InstallCommandRunResult{
					options: options
					stdout: stdout
					stderr: stderr
					events: events
					failed: true
					returned_early: true
					download_queue_closed: true
				}
			}
		}
	}

	if !options.dry_run && (selected.len > 0 || fetch_casks.len > 0) {
		if !events.contains('new_download_queue') {
			events << 'new_download_queue'
		}
		if upgrade_casks.len > 0 {
			stdout += '==> Upgrading ${upgrade_casks.len} outdated ${if upgrade_casks.len == 1 {
				'package'
			} else {
				'packages'
			}}:\n'
			for cask in upgrade_casks {
				stdout += '${cask.full_name} ${cask.installed_version} -> ${cask.version}\n'
			}
		}
		mut enqueue_failed := false
		selected, events, stderr, enqueue_failed = install_command_enqueue_formulae(selected, events, stderr)
		failed = failed || enqueue_failed
		if fetch_casks.len > 0 {
			for cask in fetch_casks {
				events << 'enqueue_cask_downloads:${cask.full_name}'
				if cask.prelude_error.len > 0 {
					stderr += 'Error: ${cask.full_name}: ${cask.prelude_error}\n'
					failed = true
					continue
				}
				if cask.enqueue_error.len > 0 {
					stderr += 'Error: ${cask.full_name}: ${cask.enqueue_error}\n'
					failed = true
				}
			}
		}
		if context.downloads_heading.len > 0 {
			events << context.downloads_heading
		}
		selected = selected.filter(install_command_formula_name(it) !in context.failed_downloads)
		events << 'shutdown'
		queue_closed = true
	}
	if !queue_closed && selected.len > 0 && !options.dry_run {
		events << 'shutdown'
		queue_closed = true
	}

	mut formula_install_failed := false
	mut formulae_installed := []string{}
	formulae_installed, stderr, formula_install_failed = install_command_install_formulae(selected, options.dry_run, stderr)
	failed = failed || formula_install_failed
	events << 'upgrade_dependents'

	mut casks_installed := []string{}
	for cask in new_casks {
		if cask.install_error.len > 0 {
			stderr += 'Error: ${cask.full_name}: ${cask.install_error}\n'
			failed = true
			continue
		}
		casks_installed << cask.full_name
	}
	mut casks_upgraded := []string{}
	if !context.environment.no_install_upgrade && installed_casks.len > 0 {
		for cask in installed_casks {
			if !cask.outdated {
				continue
			}
			if cask.install_error.len > 0 {
				stderr += 'Error: ${cask.full_name}: ${cask.install_error}\n'
				failed = true
				continue
			}
			casks_upgraded << cask.full_name
		}
	}
	events << 'periodic_clean'
	events << 'display_messages'
	return InstallCommandRunResult{
		options: options
		stdout: stdout
		stderr: stderr
		events: events
		formulae_installed: formulae_installed
		casks_installed: casks_installed
		casks_upgraded: casks_upgraded
		failed: failed
		download_queue_closed: queue_closed
	}
}

pub fn run_install_command(arguments []string) !InstallCommandRunResult {
	plan := plan_install_command(arguments)!
	packages := load_install_packages(plan.options)!
	formulae := packages.filter(it.kind == 'formula').map(InstallCommandFormula{
		name: it.name.all_after_last('/')
		full_name: it.name
	})
	casks := packages.filter(it.kind == 'cask').map(InstallCommandCask{
		full_name: it.name
	})
	return execute_install_command(InstallCommandContext{
		arguments: arguments
		formulae: formulae
		casks: casks
		environment: InstallCommandEnvironment{}
	})
}
