module homebrew

import ruby
import homebrew.cli
import homebrew.cmd
import homebrew.api
import os

// Translated from Homebrew/brew `brew.rb`.
pub enum DispatchAction {
	help
	execute
	usage_error
}

pub enum CommandTarget {
	none
	internal
	internal_developer
	external
}

pub struct DispatchResult {
pub:
	action         DispatchAction
	command        string
	original       string
	arguments      []string
	parsed         cli.Args
	target         CommandTarget
	command_path   string
	empty_argv     bool
	help_requested bool
	message        string
}

fn root_help(command string) string {
	if command.len > 0 {
		return 'Usage: brew ${command} [options]'
	}
	return 'Usage: brew <command> [options]\n\nRun `brew help <command>` for command-specific help.'
}

fn select_command(argv []string, help_from_environment bool) (string, []string, bool) {
	help_flags := ['-h', '--help', '--usage', '-?']
	mut help_requested := help_from_environment
	mut command := ''
	mut remaining := []string{}
	mut command_style_help := false
	for argument in argv {
		if argument == 'help' && command.len == 0 {
			help_requested = true
			command_style_help = true
			continue
		}
		if argument in help_flags {
			help_requested = true
			remaining << argument
			continue
		}
		if command.len == 0 {
			command = argument
			continue
		}
		remaining << argument
	}
	if command_style_help {
		remaining = remaining.filter(it !in help_flags)
	}
	return command, remaining, help_requested
}

fn resolve_command(command string) (CommandTarget, string) {
	if path := internal_cmd_path(command) {
		return CommandTarget.internal, path
	}
	if path := internal_dev_cmd_path(command) {
		return CommandTarget.internal_developer, path
	}
	if path := external_cmd_path(command) {
		return CommandTarget.external, path
	}
	return CommandTarget.none, ''
}

fn execute_install_dispatch(arguments []string) ! {
	plan := cmd.plan_install_command(arguments)!
	references := plan.options.parsed.named.to_formulae_and_casks()!
	casks := references.filter(it.kind == .cask)
	if casks.len > 0 {
		return error('unimplemented Ruby function `Cask::Upgrade.outdated_casks` at cask install-planning boundary for: ${casks.map(it.full_name).join(', ')}')
	}
	formulae := references.filter(it.kind == .formula)
	mut states := map[string]FormulaInstallState{}
	mut selected_formulae := []api.PackageReference{}
	for formula in formulae {
		state := FormulaInstallState{
			keg_only: formula.keg_only
			pkg_version: formula.stable_version
		}
		states[formula.full_name] = state
		decision := install_formula_decision(formula, state, InstallFormulaCheckOptions{
			head: plan.options.head
			fetch_head: plan.options.fetch_head
			only_dependencies: plan.options.only_dependencies
			force: plan.options.force
			quiet: plan.options.quiet
			skip_link: plan.options.skip_link
			overwrite: plan.options.overwrite
		})!
		if decision.install {
			selected_formulae << formula
		} else if decision.mark_installed_on_request {
			return error('unimplemented Ruby function `Tab#write` while marking `${formula.full_name}` installed on request')
		}
	}
	if selected_formulae.len == 0 {
		return
	}
	build_from_source_formulae := if plan.options.build_from_source || plan.options.head || plan.options.build_bottle {
		selected_formulae.map(it.full_name)
	} else {
		[]string{}
	}
	include_test_formulae := if plan.options.include_test {
		selected_formulae.map(it.full_name)
	} else {
		[]string{}
	}
	prefix_value := ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	mut prefix := prefix_value
	if prefix == '' {
		prefix = current_bottle_tag().default_prefix()
	}
	cellar_value := ruby.environment_value('HOMEBREW_CELLAR').trim_right('/')
	cellar := if cellar_value == '' { '${prefix}/Cellar' } else { cellar_value }
	temporary_cellar_value := ruby.environment_value('HOMEBREW_TEMP_CELLAR').trim_right('/')
	temporary_cellar := if temporary_cellar_value == '' {
		'/tmp/homebrew/Cellar'
	} else {
		temporary_cellar_value
	}
	installers := formula_installers_plan(selected_formulae, FormulaInstallersConfig{
		installed_on_request: !plan.options.as_dependency
		build_bottle: plan.options.build_bottle
		force_bottle: plan.options.force_bottle
		bottle_arch: plan.options.bottle_architecture
		ignore_deps: plan.options.ignore_dependencies
		only_deps: plan.options.only_dependencies
		include_test_formulae: include_test_formulae
		build_from_source_formulae: build_from_source_formulae
		compiler: plan.options.compiler
		git: plan.options.git
		interactive: plan.options.interactive
		keep_tmp: plan.options.keep_tmp
		debug_symbols: plan.options.debug_symbols
		force: plan.options.force
		overwrite: plan.options.overwrite
		debug: plan.options.debug
		quiet: plan.options.quiet
		verbose: plan.options.verbose
		dry_run: plan.options.dry_run
		skip_post_install: plan.options.skip_post_install
		skip_link: plan.options.skip_link
		head: plan.options.head
		states: states
		pour_bottle_allowed: true
		bottle_locations_compatible: true
		prefix: prefix
		cellar: cellar
		temporary_cellar: temporary_cellar
	})!
	if plan.options.dry_run {
		return
	}
	for installer in installers {
		prelude := installer.prelude_fetch_plan(false)!
		match prelude.action {
			.bottle_metadata {
				bottle_tab := installer.fetch_bottle_tab_plan(true)!
				mut manifest := bottle_tab.bottle.new_manifest_resource()!
				mut download_queue := new_download_queue(0, false, true)
				download_queue.enqueue(mut manifest.resource, false, false)!
				download_queue.fetch(?ResourceKind(.bottle_manifest), none, false)!
				manifest.verify_download_integrity('')!
				tab_attributes := manifest.tab()!
				resolution := FormulaDependencyResolutionConfig{
					check_installed: true
					prefix: prefix
					cellar: cellar
				}
				mut dependencies := installer.compute_dependencies(tab_attributes, resolution)!
				early_fetch := installer.fetch_fetch_deps(dependencies)
				if early_fetch.recompute {
					dependencies = installer.compute_dependencies(tab_attributes, resolution)!
				}
				dependencies = installer.fetch_dependencies(dependencies, []string{})
				mut downloads := installer.enqueue_fetch(dependencies)!
				fetch_downloads(mut downloads, mut download_queue, ?string('Fetching downloads for: ${installer.formula.full_name}'))!
				stage_bottle_downloads_in(mut downloads, temporary_cellar)!
				installed := installer.install_poured_downloads(mut downloads, tab_attributes)!
				for result in installed {
					if result.finish.summary != '' && !plan.options.quiet {
						println('==> ${result.formula}: ${result.finish.summary}')
					}
				}
			}
			.source {
				return error('unimplemented Ruby function `Homebrew::API::Formula.source_download` at formula source boundary for: ${installer.formula.full_name}')
			}
			.none {}
		}
	}
}

fn uninstall_kegs_for_name(name string, cellar string, prefix string, force bool) ![]Keg {
	rack := os.join_path(cellar, name)
	if !os.is_dir(rack) {
		return error('NoSuchKegError: ${name}')
	}
	mut kegs := []Keg{}
	for version in os.ls(rack)! {
		path := os.join_path(rack, version)
		if keg := new_keg_with_paths(path, cellar, prefix) {
			kegs << keg
		}
	}
	if kegs.len == 0 {
		return error('NoSuchKegError: ${name}')
	}
	if force || kegs.len == 1 {
		return kegs
	}
	for keg in kegs {
		if keg.linked() || keg.optlinked() {
			return [keg]
		}
	}
	mut latest := kegs[0]
	for keg in kegs[1..] {
		if keg.compare_scheme_and_version(latest) > 0 {
			latest = keg
		}
	}
	return [latest]
}

fn execute_uninstall_dispatch(arguments []string) ! {
	options := cmd.parse_uninstall_arguments(arguments)!
	if options.cask || options.zap {
		return error('cask uninstall is not implemented')
	}
	prefix_value := ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	prefix := if prefix_value == '' { current_bottle_tag().default_prefix() } else { prefix_value }
	cellar_value := ruby.environment_value('HOMEBREW_CELLAR').trim_right('/')
	cellar := if cellar_value == '' { os.join_path(prefix, 'Cellar') } else { cellar_value }
	for requested_name in options.named {
		name := requested_name.all_after_last('/').to_lower()
		kegs := uninstall_kegs_for_name(name, cellar, prefix, options.force)!
		pin := os.join_path(prefix, 'var', 'homebrew', 'pinned', name)
		if os.is_link(pin) && !options.force {
			return error('${name} is pinned. You must unpin it to uninstall.')
		}
		for keg in kegs {
			println('Uninstalling ${keg.path}...')
			keg.unlink(false)!
			keg.uninstall()!
		}
		if options.force && os.is_link(pin) {
			os.rm(pin)!
		}
	}
}

// Ruby top-level program body from `brew.rb`. It now returns a typed dispatch
// decision rather than crossing the generic stub boundary or invoking Ruby brew.
pub fn ruby_brew_file_body(argv []string, help_from_environment bool) DispatchResult {
	empty_argv := argv.len == 0
	original_command, remaining, help_requested := select_command(argv, help_from_environment)
	mut parser := cli.new_parser('brew')
	parsed := parser.parse(remaining, true) or {
		return DispatchResult{
			action: .usage_error
			original: original_command
			arguments: remaining
			empty_argv: empty_argv
			help_requested: help_requested
			message: err.msg()
		}
	}
	command := canonical_command(original_command)
	target, path := resolve_command(command)
	if empty_argv || help_requested {
		return DispatchResult{
			action: .help
			command: command
			original: original_command
			arguments: remaining
			parsed: parsed
			target: target
			command_path: path
			empty_argv: empty_argv
			help_requested: help_requested
			message: root_help(command)
		}
	}
	if command.len == 0 {
		return DispatchResult{
			action: .usage_error
			arguments: remaining
			parsed: parsed
			empty_argv: empty_argv
			message: 'Unknown command: brew ${remaining.join(' ')}'
		}
	}
	if target == .none {
		return DispatchResult{
			action: .usage_error
			command: command
			original: original_command
			arguments: remaining
			parsed: parsed
			target: target
			empty_argv: empty_argv
			message: 'Unknown command: brew ${command}${suggestion_message(command)}'
		}
	}
	return DispatchResult{
		action: .execute
		command: command
		original: original_command
		arguments: remaining
		parsed: parsed
		target: target
		command_path: path
		empty_argv: empty_argv
	}
}

// execute_dispatch is the deliberate boundary between translated CLI dispatch
// and command bodies that do not yet have executable V implementations. It
// never invokes Ruby or a native Homebrew executable.
pub fn execute_dispatch(dispatch DispatchResult) ! {
	if dispatch.action != .execute {
		return error('cannot execute a ${dispatch.action} dispatch result')
	}
	if dispatch.command == '--version' {
		for line in cmd.version_lines_from_environment() {
			println(line)
		}
		return
	}
	if dispatch.command == '--repository' {
		for line in cmd.repository_lines_from_environment(dispatch.arguments)! {
			println(line)
		}
		return
	}
	if dispatch.command == '--taps' {
		println(cmd.taps_path_from_environment())
		return
	}
	if dispatch.command == 'install' {
		execute_install_dispatch(dispatch.arguments)!
		return
	}
	if dispatch.command == 'uninstall' {
		execute_uninstall_dispatch(dispatch.arguments)!
		return
	}
	return error('V command `${dispatch.command}` is selected at `${dispatch.command_path}` but its run body is not implemented')
}
