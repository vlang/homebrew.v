module cmd

import homebrew.cli

// Translated from Homebrew/brew `cmd/install.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 186.
pub fn ruby_install_l186_d1_run(context InstallCommandContext) !InstallCommandRunResult {
	return execute_install_command(context)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cask/config"
// 6: require "cask/installer"
// 7: require "cask/upgrade"
// 8:
// 9: require "cask_dependent"
// 10: require "missing_formula"
// 11: require "formula_installer"
// 12: require "development_tools"
// 13: require "install"
// 14: require "cleanup"
// 15: require "upgrade"
// 16: require "trust"
// 17:
// 18: module Homebrew
// 19:   module Cmd
// 20:     class InstallCmd < AbstractCommand
// 21:       cmd_args do
// 22:         description <<~EOS
// 23:           Install a <formula> or <cask>. Additional options specific to a <formula> may be
// 24:           appended to the command.
// 25:
// 26:           Unless `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set, `brew upgrade` or `brew reinstall` will be run for
// 27:           outdated dependents and dependents with broken linkage, respectively.
// 28:
// 29:           Unless `$HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for
// 30:           the installed formulae or, every 30 days, for all formulae.
// 31:
// 32:           Unless `$HOMEBREW_NO_INSTALL_UPGRADE` is set, `brew install` <formula> will upgrade <formula> if it
// 33:           is already installed but outdated.
// 34:         EOS
// 35:         switch "-d", "--debug",
// 36:                description: "If brewing fails, open an interactive debugging session with access to IRB " \
// 37:                             "or a shell inside the temporary build directory."
// 38:         switch "--display-times",
// 39:                description: "Print install times for each package at the end of the run.",
// 40:                env:         :display_install_times
// 41:         switch "-f", "--force",
// 42:                description: "Install formulae without checking for previously installed keg-only or " \
// 43:                             "non-migrated versions. When installing casks, overwrite existing files " \
// 44:                             "(binaries and symlinks are excluded, unless originally from the same cask)."
// 45:         switch "-v", "--verbose",
// 46:                description: "Print the verification and post-install steps."
// 47:         switch "-n", "--dry-run",
// 48:                description: "Show what would be installed, but do not actually install anything."
// 49:         switch "--no-ask", "--yes", "-y",
// 50:                description: "Do not ask for confirmation before downloading and installing. Ask mode is the default.",
// 51:                env:         :no_ask
// 52:         switch "--ask",
// 53:                description: "Ask for confirmation before downloading and installing. " \
// 54:                             "Print the same plan as `--dry-run` before prompting. Only prompts if the plan " \
// 55:                             "includes dependencies or dependants; if the requested formulae or casks are the " \
// 56:                             "only things to install, it only prints the plan. The confirmation prompt is " \
// 57:                             "skipped without a TTY. This is the default unless `$HOMEBREW_NO_ASK` is set.",
// 58:                env:         :ask,
// 59:                replacement: "the default behaviour",
// 60:                odeprecated: true
// 61:         [
// 62:           [:switch, "--formula", "--formulae", {
// 63:             description: "Treat all named arguments as formulae.",
// 64:           }],
// 65:           [:flag, "--env=", {
// 66:             description: "Disabled other than for internal Homebrew use.",
// 67:             hidden:      true,
// 68:           }],
// 69:           [:switch, "--ignore-dependencies", {
// 70:             description: "An unsupported Homebrew development option to skip installing any dependencies of any " \
// 71:                          "kind. If the dependencies are not already present, the formula will have issues. If " \
// 72:                          "you're not developing Homebrew, consider adjusting your PATH rather than using this " \
// 73:                          "option.",
// 74:           }],
// 75:           [:switch, "--only-dependencies", {
// 76:             description: "Install the dependencies with specified options but do not install the " \
// 77:                          "formula itself.",
// 78:           }],
// 79:           [:flag, "--cc=", {
// 80:             description: "Attempt to compile using the specified <compiler>, which should be the name of the " \
// 81:                          "compiler's executable, e.g. `gcc-9` for GCC 9. In order to use LLVM's clang, specify " \
// 82:                          "`llvm_clang`. To use the Apple-provided clang, specify `clang`. This option will only " \
// 83:                          "accept compilers that are provided by Homebrew or bundled with macOS. Please do not " \
// 84:                          "file issues if you encounter errors while using this option.",
// 85:           }],
// 86:           [:switch, "-s", "--build-from-source", {
// 87:             description: "Compile <formula> from source even if a bottle is provided. " \
// 88:                          "Dependencies will still be installed from bottles if they are available.",
// 89:           }],
// 90:           [:switch, "--force-bottle", {
// 91:             description: "Install from a bottle if it exists for the current or newest version of " \
// 92:                          "macOS, even if it would not normally be used for installation.",
// 93:           }],
// 94:           [:switch, "--include-test", {
// 95:             description: "Install testing dependencies required to run `brew test` <formula>.",
// 96:           }],
// 97:           [:switch, "--HEAD", {
// 98:             description: "If <formula> defines it, install the HEAD version, aka. main, trunk, unstable, master.",
// 99:           }],
// 100:           [:switch, "--fetch-HEAD", {
// 101:             description: "Fetch the upstream repository to detect if the HEAD installation of the " \
// 102:                          "formula is outdated. Otherwise, the repository's HEAD will only be checked for " \
// 103:                          "updates when a new stable or development version has been released.",
// 104:           }],
// 105:           [:switch, "--keep-tmp", {
// 106:             description: "Retain the temporary files created during installation.",
// 107:           }],
// 108:           [:switch, "--debug-symbols", {
// 109:             depends_on:  "--build-from-source",
// 110:             description: "Generate debug symbols on build. Source will be retained in a cache directory.",
// 111:           }],
// 112:           [:switch, "--build-bottle", {
// 113:             description: "Prepare the formula for eventual bottling during installation, skipping any " \
// 114:                          "post-install steps.",
// 115:           }],
// 116:           [:switch, "--skip-post-install", {
// 117:             description: "Install but skip any post-install steps.",
// 118:           }],
// 119:           [:switch, "--skip-link", {
// 120:             description: "Install but skip linking the keg into the prefix.",
// 121:           }],
// 122:           [:switch, "--as-dependency", {
// 123:             description: "Install but mark as installed as a dependency and not installed on request.",
// 124:           }],
// 125:           [:flag, "--bottle-arch=", {
// 126:             depends_on:  "--build-bottle",
// 127:             description: "Optimise bottles for the specified architecture rather than the oldest " \
// 128:                          "architecture supported by the version of macOS the bottles are built on.",
// 129:           }],
// 130:           [:switch, "-i", "--interactive", {
// 131:             description: "Download and patch <formula>, then open a shell. This allows the user to " \
// 132:                          "run `./configure --help` and otherwise determine how to turn the software " \
// 133:                          "package into a Homebrew package.",
// 134:           }],
// 135:           [:switch, "-g", "--git", {
// 136:             description: "Create a Git repository, useful for creating patches to the software.",
// 137:           }],
// 138:           [:switch, "--overwrite", {
// 139:             description: "Delete files that already exist in the prefix while linking.",
// 140:           }],
// 141:         ].each do |args|
// 142:           options = args.pop
// 143:           send(*args, **options)
// 144:           conflicts "--cask", args.last
// 145:         end
// 146:         formula_options
// 147:         [
// 148:           [:switch, "--cask", "--casks", {
// 149:             description: "Treat all named arguments as casks.",
// 150:           }],
// 151:           [:switch, "--[no-]binaries", {
// 152:             description: "Disable/enable linking of helper executables (default: enabled).",
// 153:             env:         :cask_opts_binaries,
// 154:           }],
// 155:           [:switch, "--require-sha", {
// 156:             description: "Require all casks to have a checksum.",
// 157:             env:         :cask_opts_require_sha,
// 158:           }],
// 159:           [:switch, "--adopt", {
// 160:             description: "Adopt existing artifacts in the destination that are identical to those being installed. " \
// 161:                          "Cannot be combined with `--force`.",
// 162:           }],
// 163:           [:switch, "--skip-cask-deps", {
// 164:             description: "Skip installing cask dependencies.",
// 165:           }],
// 166:           [:switch, "--zap", {
// 167:             description: "For use with `brew reinstall --cask`. Remove all files associated with a cask. " \
// 168:                          "*May remove files which are shared between applications.*",
// 169:           }],
// 170:         ].each do |args|
// 171:           options = args.pop
// 172:           send(*args, **options)
// 173:           conflicts "--formula", args.last
// 174:         end
// 175:         cask_options
// 176:
// 177:         conflicts "--ignore-dependencies", "--only-dependencies"
// 178:         conflicts "--ask", "--no-ask"
// 179:         conflicts "--build-from-source", "--build-bottle", "--force-bottle"
// 180:         conflicts "--adopt", "--force"
// 181:
// 182:         named_args [:formula, :cask], min: 1
// 183:       end
// 184:
// 185:       sig { override.void }
// 186:       def run
// 187:         if args.env.present?
// 188:           # Can't use `replacement: false` because `install_args` are used by
// 189:           # `build.rb`. Instead, `hide_from_man_page` and don't do anything with
// 190:           # this argument here.
// 191:           # This odisabled should stick around indefinitely.
// 192:           odisabled "`brew install --env`", "`env :std` in specific formula files"
// 193:         end
// 194:
// 195:         args.named.each do |name|
// 196:           if (tap_with_name = Tap.with_formula_name(name))
// 197:             tap, = tap_with_name
// 198:           elsif (tap_with_token = Tap.with_cask_token(name))
// 199:             tap, = tap_with_token
// 200:           end
// 201:
// 202:           tap&.ensure_installed!
// 203:         end
// 204:         Homebrew::Trust.trust_fully_qualified_items!(args.named, type: args.only_formula_or_cask)
// 205:
// 206:         if args.ignore_dependencies?
// 207:           opoo <<~EOS
// 208:             #{Tty.bold}`--ignore-dependencies` is an unsupported Homebrew developer option!#{Tty.reset}
// 209:             Adjust your PATH to put any preferred versions of applications earlier in the
// 210:             PATH rather than using this unsupported option!
// 211:
// 212:           EOS
// 213:         end
// 214:
// 215:         formulae, casks = T.cast(
// 216:           args.named.to_formulae_and_casks(warn: false).partition { it.is_a?(Formula) },
// 217:           [T::Array[Formula], T::Array[Cask::Cask]],
// 218:         )
// 219:         ask = !args.no_ask?
// 220:
// 221:         installed_casks = T.let([], T::Array[Cask::Cask])
// 222:         new_casks = T.let([], T::Array[Cask::Cask])
// 223:         upgrade_casks = T.let([], T::Array[Cask::Cask])
// 224:         fetch_casks = T.let([], T::Array[Cask::Cask])
// 225:         if casks.any?
// 226:           if args.dry_run?
// 227:             Install.print_dry_run_casks(casks, skip_cask_deps: args.skip_cask_deps?, include_installed: false)
// 228:             return
// 229:           end
// 230:
// 231:           require "cask/installer"
// 232:
// 233:           installed_casks, new_casks = casks.partition(&:installed?)
// 234:
// 235:           fetch_casks = if Homebrew::EnvConfig.no_install_upgrade?
// 236:             new_casks
// 237:           else
// 238:             upgrade_casks = Cask::Upgrade.outdated_casks(casks, args:, force: true, quiet: true)
// 239:             new_casks | upgrade_casks
// 240:           end
// 241:           Install.ask_casks fetch_casks, skip_cask_deps: args.skip_cask_deps? if ask
// 242:         end
// 243:
// 244:         if Homebrew::EnvConfig.verify_attestations?
// 245:           formulae = Homebrew::Attestation.sort_formulae_for_install(formulae)
// 246:         end
// 247:
// 248:         # if the user's flags will prevent bottle only-installations when no
// 249:         # developer tools are available, we need to stop them early on
// 250:         build_flags = []
// 251:         unless DevelopmentTools.installed?
// 252:           build_flags << "--HEAD" if args.HEAD?
// 253:           build_flags << "--build-bottle" if args.build_bottle?
// 254:           build_flags << "--build-from-source" if args.build_from_source?
// 255:
// 256:           raise BuildFlagsError.new(build_flags, bottled: formulae.all?(&:bottled?)) if build_flags.present?
// 257:         end
// 258:
// 259:         if build_flags.present? && !Homebrew::EnvConfig.developer?
// 260:           opoo "building from source is not supported!"
// 261:           puts "You're on your own. Failures are expected so don't create any issues, please!"
// 262:         end
// 263:
// 264:         installed_formulae = formulae.select do |f|
// 265:           Install.install_formula?(
// 266:             f,
// 267:             head:              args.HEAD?,
// 268:             fetch_head:        args.fetch_HEAD?,
// 269:             only_dependencies: args.only_dependencies?,
// 270:             force:             args.force?,
// 271:             quiet:             args.quiet?,
// 272:             skip_link:         args.skip_link?,
// 273:             overwrite:         args.overwrite?,
// 274:           )
// 275:         end
// 276:
// 277:         return if formulae.any? && installed_formulae.empty? && casks.empty?
// 278:
// 279:         formulae_installer = Install.formula_installers(
// 280:           installed_formulae,
// 281:           installed_on_request:       !args.as_dependency?,
// 282:           build_bottle:               args.build_bottle?,
// 283:           force_bottle:               args.force_bottle?,
// 284:           bottle_arch:                args.bottle_arch,
// 285:           ignore_deps:                args.ignore_dependencies?,
// 286:           only_deps:                  args.only_dependencies?,
// 287:           include_test_formulae:      args.include_test_formulae,
// 288:           build_from_source_formulae: args.build_from_source_formulae,
// 289:           cc:                         args.cc,
// 290:           git:                        args.git?,
// 291:           interactive:                args.interactive?,
// 292:           keep_tmp:                   args.keep_tmp?,
// 293:           debug_symbols:              args.debug_symbols?,
// 294:           force:                      args.force?,
// 295:           overwrite:                  args.overwrite?,
// 296:           debug:                      args.debug?,
// 297:           quiet:                      args.quiet?,
// 298:           verbose:                    args.verbose?,
// 299:           dry_run:                    args.dry_run?,
// 300:           skip_post_install:          args.skip_post_install?,
// 301:           skip_link:                  args.skip_link?,
// 302:         )
// 303:
// 304:         shared_download_queue = T.let(nil, T.nilable(Homebrew::DownloadQueue))
// 305:         if !args.dry_run? && formulae_installer.any?
// 306:           shared_download_queue = Homebrew::DownloadQueue.new(pour: true)
// 307:           # Start bottle manifest (and, once downloads are confirmed, bottle)
// 308:           # transfers before the local-only work below.
// 309:           formulae_installer = Install.prelude_fetch_formulae(formulae_installer,
// 310:                                                               download_queue: shared_download_queue,
// 311:                                                               metadata_only:  ask)
// 312:         end
// 313:
// 314:         begin
// 315:           Install.perform_preinstall_checks_once
// 316:           Install.check_cc_argv(args.cc)
// 317:
// 318:           dependants = Upgrade.dependants(
// 319:             installed_formulae,
// 320:             flags:                      args.flags_only,
// 321:             ask:                        ask,
// 322:             installed_on_request:       !args.as_dependency?,
// 323:             force_bottle:               args.force_bottle?,
// 324:             build_from_source_formulae: args.build_from_source_formulae,
// 325:             interactive:                args.interactive?,
// 326:             keep_tmp:                   args.keep_tmp?,
// 327:             debug_symbols:              args.debug_symbols?,
// 328:             force:                      args.force?,
// 329:             debug:                      args.debug?,
// 330:             quiet:                      args.quiet?,
// 331:             verbose:                    args.verbose?,
// 332:             dry_run:                    args.dry_run?,
// 333:           )
// 334:
// 335:           # Main block: if asking the user is enabled, show dry-run information.
// 336:           if ask
// 337:             shared_download_queue&.fetch(only: Resource::BottleManifest,
// 338:                                          heading: "Downloading bottle manifests", allow_failures: true)
// 339:             Install.ask_formulae(
// 340:               formulae_installer,
// 341:               dependants,
// 342:               flags:                      args.flags_only,
// 343:               force_bottle:               args.force_bottle?,
// 344:               build_from_source_formulae: args.build_from_source_formulae,
// 345:               interactive:                args.interactive?,
// 346:               keep_tmp:                   args.keep_tmp?,
// 347:               debug_symbols:              args.debug_symbols?,
// 348:               force:                      args.force?,
// 349:               debug:                      args.debug?,
// 350:               quiet:                      args.quiet?,
// 351:               verbose:                    args.verbose?,
// 352:             )
// 353:           end
// 354:         # Ensure the early download queue is shut down on interrupts and declined prompts.
// 355:         rescue Exception # rubocop:disable Lint/RescueException
// 356:           shared_download_queue&.shutdown
// 357:           raise
// 358:         end
// 359:
// 360:         if !args.dry_run? && (formulae_installer.any? || fetch_casks.any?)
// 361:           download_queue = T.let(shared_download_queue || Homebrew::DownloadQueue.new(pour: true),
// 362:                                  Homebrew::DownloadQueue)
// 363:           shared_download_queue = nil
// 364:           begin
// 365:             Cask::Upgrade.show_upgrade_summary(
// 366:               upgrade_casks.map { |cask| "#{cask.full_name} #{cask.installed_version} -> #{cask.version}" },
// 367:             )
// 368:
// 369:             formulae_installer = Install.enqueue_formulae(formulae_installer, download_queue:)
// 370:
// 371:             if fetch_casks.any?
// 372:               fetch_cask_installers = fetch_casks.map do |cask|
// 373:                 Cask::Installer.new(
// 374:                   cask,
// 375:                   reinstall:      true,
// 376:                   binaries:       args.binaries?,
// 377:                   verbose:        args.verbose?,
// 378:                   force:          args.force?,
// 379:                   skip_cask_deps: args.skip_cask_deps?,
// 380:                   require_sha:    args.require_sha?,
// 381:                   zap:            args.zap?,
// 382:                   download_queue:,
// 383:                   defer_fetch:    true,
// 384:                 )
// 385:               end
// 386:
// 387:               Install.enqueue_cask_installers(fetch_cask_installers, download_queue:)
// 388:             end
// 389:
// 390:             download_queue.fetch(heading: Install.combined_fetch_downloads_heading(
// 391:               formula_names: formulae_installer.map { |fi| fi.formula.name },
// 392:               cask_names:    fetch_casks.map(&:full_name),
// 393:             ))
// 394:             # Install everything that did download, rather than aborting the
// 395:             # whole run; the failures above still exit nonzero at the end.
// 396:             formulae_installer = Install.reject_failed_downloads(formulae_installer, download_queue:)
// 397:           ensure
// 398:             download_queue.shutdown
// 399:           end
// 400:         end
// 401:         shared_download_queue&.shutdown
// 402:
// 403:         Install.install_formulae(formulae_installer,
// 404:                                  dry_run: args.dry_run?,
// 405:                                  verbose: args.verbose?)
// 406:
// 407:         Upgrade.upgrade_dependents(
// 408:           dependants, installed_formulae,
// 409:           flags:                      args.flags_only,
// 410:           dry_run:                    args.dry_run?,
// 411:           force_bottle:               args.force_bottle?,
// 412:           build_from_source_formulae: args.build_from_source_formulae,
// 413:           interactive:                args.interactive?,
// 414:           keep_tmp:                   args.keep_tmp?,
// 415:           debug_symbols:              args.debug_symbols?,
// 416:           force:                      args.force?,
// 417:           debug:                      args.debug?,
// 418:           quiet:                      args.quiet?,
// 419:           verbose:                    args.verbose?
// 420:         )
// 421:
// 422:         if casks.any?
// 423:           new_casks.each do |cask|
// 424:             Cask::Installer.new(
// 425:               cask,
// 426:               adopt:          args.adopt?,
// 427:               binaries:       args.binaries?,
// 428:               defer_fetch:    fetch_casks.include?(cask),
// 429:               force:          args.force?,
// 430:               quiet:          args.quiet?,
// 431:               require_sha:    args.require_sha?,
// 432:               skip_cask_deps: args.skip_cask_deps?,
// 433:               verbose:        args.verbose?,
// 434:             ).install
// 435:           rescue => e
// 436:             ofail "#{cask.full_name}: #{e}"
// 437:           end
// 438:
// 439:           if !Homebrew::EnvConfig.no_install_upgrade? && installed_casks.any?
// 440:             begin
// 441:               Cask::Upgrade.upgrade_casks!(
// 442:                 *installed_casks,
// 443:                 force:                args.force?,
// 444:                 dry_run:              args.dry_run?,
// 445:                 binaries:             args.binaries?,
// 446:                 require_sha:          args.require_sha?,
// 447:                 skip_cask_deps:       args.skip_cask_deps?,
// 448:                 verbose:              args.verbose?,
// 449:                 quiet:                args.quiet?,
// 450:                 skip_prefetch:        true,
// 451:                 show_upgrade_summary: false,
// 452:                 args:,
// 453:               )
// 454:             rescue => e
// 455:               ofail e
// 456:             end
// 457:           end
// 458:         end
// 459:
// 460:         Cleanup.periodic_clean!(dry_run: args.dry_run?)
// 461:
// 462:         Homebrew.messages.display_messages(display_times: args.display_times?)
// 463:       rescue FormulaUnreadableError, FormulaClassUnavailableError,
// 464:              TapFormulaUnreadableError, TapFormulaClassUnavailableError => e
// 465:         require "utils/backtrace"
// 466:
// 467:         # Need to rescue before `FormulaUnavailableError` (superclass of this)
// 468:         # is handled, as searching for a formula doesn't make sense here (the
// 469:         # formula was found, but there's a problem with its implementation).
// 470:         $stderr.puts Utils::Backtrace.clean(e) if Homebrew::EnvConfig.developer?
// 471:         ofail e.message
// 472:       rescue FormulaOrCaskUnavailableError, Cask::CaskUnavailableError => e
// 473:         Homebrew.failed = true
// 474:
// 475:         # formula name or cask token
// 476:         name = case e
// 477:         when FormulaOrCaskUnavailableError then e.name
// 478:         when Cask::CaskUnavailableError then e.token
// 479:         else T.absurd(e)
// 480:         end
// 481:
// 482:         if name == "updog"
// 483:           ofail "What's updog?"
// 484:           return
// 485:         end
// 486:
// 487:         opoo e
// 488:
// 489:         reason = MissingFormula.reason(name, silent: true)
// 490:         if !args.cask? && reason
// 491:           $stderr.puts reason
// 492:           return
// 493:         end
// 494:
// 495:         # We don't seem to get good search results when the tap is specified
// 496:         # so we might as well return early.
// 497:         return if name.include?("/")
// 498:
// 499:         require "search"
// 500:
// 501:         package_types = []
// 502:         package_types << "formulae" unless args.cask?
// 503:         package_types << "casks" unless args.formula?
// 504:
// 505:         ohai "Searching for similarly named #{package_types.join(" and ")}..."
// 506:
// 507:         # Don't treat formula/cask name as a regex
// 508:         string_or_regex = name
// 509:         all_formulae, all_casks = Search.search_names(string_or_regex, args)
// 510:
// 511:         if all_formulae.any?
// 512:           ohai "Formulae", Formatter.columns(all_formulae)
// 513:           first_formula = all_formulae.first.to_s
// 514:           puts <<~EOS
// 515:
// 516:             To install #{first_formula}, run:
// 517:               brew install #{first_formula}
// 518:           EOS
// 519:         end
// 520:         puts if all_formulae.any? && all_casks.any?
// 521:         if all_casks.any?
// 522:           ohai "Casks", Formatter.columns(all_casks)
// 523:           first_cask = all_casks.first.to_s
// 524:           puts <<~EOS
// 525:
// 526:             To install #{first_cask}, run:
// 527:               brew install --cask #{first_cask}
// 528:           EOS
// 529:         end
// 530:         return if all_formulae.any? || all_casks.any?
// 531:
// 532:         odie "No #{package_types.join(" or ")} found for #{name}."
// 533:       end
// 534:     end
// 535:   end
// 536: end
