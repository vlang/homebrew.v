module dev_cmd

import ruby
import homebrew.livecheck as livecheck_core
import os

// Translated from Homebrew/brew `dev-cmd/livecheck.rb`.

pub struct LivecheckCommandOptions {
pub:
	named                []string
	tap                  string
	full_name            bool
	eval_all             bool
	tap_trust_configured bool
	installed            bool
	newer_only           bool
	json                 bool
	resources            bool
	quiet                bool
	formula_only         bool
	cask_only            bool
	extract_plist        bool
	autobump             bool
	livecheck_autobump   bool
	debug                bool
	verbose              bool
	stderr_tty           bool
	livecheck_watchlist  string
	working_directory    string
	user_home            string
	debug_arguments      string
}

pub struct LivecheckWatchlist {
pub:
	exists     bool
	contents   string
	read_error string
}

pub struct LivecheckCommandSources {
pub:
	tap_formulae       []livecheck_core.LivecheckPackage
	tap_casks          []livecheck_core.LivecheckPackage
	installed_formulae []livecheck_core.LivecheckPackage
	installed_casks    []livecheck_core.LivecheckPackage
	named_packages     []livecheck_core.LivecheckPackage
	all_formulae       []livecheck_core.LivecheckPackage
	all_casks          []livecheck_core.LivecheckPackage
	autobump_by_tap    map[string][]string
	watchlist          LivecheckWatchlist
}

pub struct LivecheckRunOptions {
pub:
	json                 bool
	full_name            bool
	handle_name_conflict bool
	check_resources      bool
	newer_only           bool
	extract_plist        bool
	quiet                bool
	debug                bool
	verbose              bool
}

pub struct LivecheckCommandResult {
pub:
	bundler_groups          []string
	selection               string
	eval_all                bool
	selected                []livecheck_core.LivecheckPackage
	skipped_autobump        bool
	skip_messages           []string
	run_options             LivecheckRunOptions
	effective_extract_plist bool
	loaded_strategy_paths   []string
	ran_checks              bool
	checks                  []ruby.Value
	stdout                  []string
	stderr                  []string
	show_progress           bool
}

@[heap]
pub struct LivecheckCommandInput {
pub:
	options LivecheckCommandOptions
	sources LivecheckCommandSources
}

pub fn livecheck_command_input_boundary(input &LivecheckCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::LivecheckCmd::Input', '', {
		'livecheck_command_input_address': u64(voidptr(input)).str()
	})
}

fn livecheck_command_input_from_value(value ruby.Value) &LivecheckCommandInput {
	address := value.attributes['livecheck_command_input_address'] or {
		panic('invalid Livecheck command input')
	}
	return unsafe { &LivecheckCommandInput(voidptr(address.u64())) }
}

pub fn livecheck_watchlist_path(configured string, working_directory string, user_home string) string {
	mut expanded := configured
	if configured == '~' {
		expanded = user_home
	} else if configured.starts_with('~/') {
		expanded = os.join_path(user_home, configured[2..])
	}
	if os.is_abs_path(expanded) {
		return os.norm_path(expanded)
	}
	base := if working_directory == '' { os.getwd() } else { working_directory }
	return os.norm_path(os.join_path(base, expanded))
}

pub fn livecheck_skip_autobump(autobump bool, livecheck_autobump bool) bool {
	return !(autobump || livecheck_autobump)
}

pub fn livecheck_watchlist_names(contents string) []string {
	mut names := []string{}
	for raw_line in contents.split('\n') {
		mut line := raw_line.trim_right('\r')
		if comment_index := line.index('#') {
			if comment_index == 0 {
				continue
			}
			line = line[..comment_index]
		}
		name := line.trim_space()
		if name != '' {
			names << name
		}
	}
	return names
}

fn livecheck_command_package_identity(package livecheck_core.LivecheckPackage) string {
	name := if package.full_name != '' { package.full_name } else { package.name }
	return '${package.kind}:${name}'
}

fn livecheck_command_unique(packages []livecheck_core.LivecheckPackage) []livecheck_core.LivecheckPackage {
	mut unique := []livecheck_core.LivecheckPackage{}
	mut seen := map[string]bool{}
	for package in packages {
		identity := livecheck_command_package_identity(package)
		if identity in seen {
			continue
		}
		seen[identity] = true
		unique << package
	}
	return unique
}

fn livecheck_command_filter_kind(packages []livecheck_core.LivecheckPackage, options LivecheckCommandOptions) []livecheck_core.LivecheckPackage {
	return packages.filter((!options.formula_only || it.kind == 'formula')
		&& (!options.cask_only || it.kind == 'cask'))
}

fn livecheck_command_named_catalog(sources LivecheckCommandSources) []livecheck_core.LivecheckPackage {
	mut catalog := sources.named_packages.clone()
	catalog << sources.tap_formulae
	catalog << sources.tap_casks
	catalog << sources.installed_formulae
	catalog << sources.installed_casks
	catalog << sources.all_formulae
	catalog << sources.all_casks
	return livecheck_command_unique(catalog)
}

fn livecheck_command_resolve_names(names []string, sources LivecheckCommandSources, options LivecheckCommandOptions, ignore_unavailable bool) ![]livecheck_core.LivecheckPackage {
	catalog := livecheck_command_filter_kind(livecheck_command_named_catalog(sources), options)
	mut resolved := []livecheck_core.LivecheckPackage{}
	for name in names {
		matches := catalog.filter(it.name == name || it.full_name == name)
		if matches.len == 0 {
			if ignore_unavailable {
				continue
			}
			return error('No available formula or cask with the name "${name}".')
		}
		resolved << matches
	}
	return livecheck_command_unique(resolved)
}

fn livecheck_command_validate_options(options LivecheckCommandOptions) ! {
	if options.formula_only && options.cask_only {
		return error('Options `--formula` and `--cask` are mutually exclusive.')
	}
	if options.json && options.debug {
		return error('Options `--json` and `--debug` are mutually exclusive.')
	}
	if options.formula_only && options.extract_plist {
		return error('Options `--formula` and `--extract-plist` are mutually exclusive.')
	}
	mut exclusive_sources := 0
	if options.tap != '' {
		exclusive_sources++
	}
	if options.installed {
		exclusive_sources++
	}
	if options.eval_all {
		exclusive_sources++
	}
	if exclusive_sources > 1 {
		return error('Options `--tap`, `--installed` and `--eval-all` are mutually exclusive.')
	}
}

fn livecheck_command_tap_packages(sources LivecheckCommandSources, options LivecheckCommandOptions) []livecheck_core.LivecheckPackage {
	mut packages := []livecheck_core.LivecheckPackage{}
	if !options.cask_only {
		packages << sources.tap_formulae.filter(it.tap_name == '' || it.tap_name == options.tap)
	}
	if !options.formula_only {
		packages << sources.tap_casks.filter(it.tap_name == '' || it.tap_name == options.tap)
	}
	return packages
}

fn livecheck_command_installed_packages(sources LivecheckCommandSources, options LivecheckCommandOptions) []livecheck_core.LivecheckPackage {
	mut packages := []livecheck_core.LivecheckPackage{}
	if !options.cask_only {
		packages << sources.installed_formulae
	}
	if !options.formula_only {
		packages << sources.installed_casks
	}
	return packages
}

fn livecheck_command_all_packages(sources LivecheckCommandSources, options LivecheckCommandOptions) []livecheck_core.LivecheckPackage {
	mut packages := []livecheck_core.LivecheckPackage{}
	if !options.cask_only {
		packages << sources.all_formulae
	}
	if !options.formula_only {
		packages << sources.all_casks
	}
	return packages
}

fn livecheck_run_options_value(options LivecheckRunOptions) ruby.Value {
	return ruby.map_value({
		'json':                 ruby.bool_value(options.json)
		'full_name':            ruby.bool_value(options.full_name)
		'handle_name_conflict': ruby.bool_value(options.handle_name_conflict)
		'check_resources':      ruby.bool_value(options.check_resources)
		'newer_only':           ruby.bool_value(options.newer_only)
		'extract_plist':        ruby.bool_value(options.extract_plist)
		'quiet':                ruby.bool_value(options.quiet)
		'debug':                ruby.bool_value(options.debug)
		'verbose':              ruby.bool_value(options.verbose)
	})
}

fn livecheck_command_info_name(info ruby.Value) string {
	for key in ['formula', 'cask', 'resource'] {
		if value := info.map_data[key] {
			return value.as_string()
		}
	}
	return ''
}

fn livecheck_command_render(checks []ruby.Value, options LivecheckCommandOptions, mut stdout []string, mut stderr []string) {
	if options.json {
		stdout << ruby.json_value_to_string(ruby.array_value(checks))
		return
	}
	for info in checks {
		status := (info.map_data['status'] or { ruby.string_value('') }).as_string()
		if status == 'error' {
			if options.quiet {
				continue
			}
			name := livecheck_command_info_name(info)
			messages := (info.map_data['messages'] or { ruby.string_array_value([]string{}) }).as_string_array() or {
				[]string{}
			}
			for message in messages {
				stderr << '${name}: ${message}'
			}
			continue
		}
		stdout << livecheck_core.ruby_livecheck_l492_d10_self_print_latest_version(info, ruby.map_value({
			'verbose': ruby.bool_value(options.verbose)
		})).as_string()
		if resources := info.map_data['resources'] {
			resource_lines := livecheck_core.ruby_livecheck_l515_d11_self_print_resources_info(resources, ruby.map_value({
				'verbose': ruby.bool_value(options.verbose)
			})).as_string()
			if resource_lines != '' {
				stdout << resource_lines
			}
		}
	}
}

pub fn run_livecheck_command(options LivecheckCommandOptions, sources LivecheckCommandSources) !LivecheckCommandResult {
	livecheck_command_validate_options(options)!
	eval_all := options.eval_all || (options.named.len == 0 && options.tap_trust_configured)
	mut selected := []livecheck_core.LivecheckPackage{}
	mut selection := ''
	mut stderr := []string{}
	if options.tap != '' {
		selection = 'tap'
		selected = livecheck_command_tap_packages(sources, options)
	} else if options.installed {
		selection = 'installed'
		selected = livecheck_command_installed_packages(sources, options)
	} else if options.named.len > 0 {
		selection = 'named'
		selected = livecheck_command_resolve_names(options.named, sources, options, false)!
	} else if eval_all {
		selection = 'all'
		selected = livecheck_command_all_packages(sources, options)
	} else if sources.watchlist.exists {
		selection = 'watchlist'
		if sources.watchlist.read_error != '' {
			stderr << sources.watchlist.read_error
		} else {
			names := livecheck_watchlist_names(sources.watchlist.contents)
			selected = livecheck_command_resolve_names(names, sources, options, true)!
		}
	} else {
		return error('`brew livecheck` with no arguments needs a watchlist file, `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
	}

	selected = livecheck_command_unique(selected)
	mut skipped_autobump := false
	mut skip_messages := []string{}
	if livecheck_skip_autobump(options.autobump, options.livecheck_autobump) {
		mut retained := []livecheck_core.LivecheckPackage{}
		for package in selected {
			if package.tap_name == '' {
				retained << package
				continue
			}
			autobump_names := sources.autobump_by_tap[package.tap_name] or { []string{} }
			if package.name in autobump_names {
				skipped_autobump = true
				skip_messages << 'Skipping ${package.name} as it is autobumped in ${package.tap_name}.'
			} else {
				retained << package
			}
		}
		selected = retained.clone()
	}
	selected.sort(a.name < b.name)
	if selected.len == 0 && !skipped_autobump {
		return error('No formulae or casks to check.')
	}

	run_options := LivecheckRunOptions{
		json: options.json
		full_name: options.full_name
		handle_name_conflict: !options.formula_only && !options.cask_only
		check_resources: options.resources
		newer_only: options.newer_only
		extract_plist: options.extract_plist
		quiet: options.quiet
		debug: options.debug
		verbose: options.verbose
	}
	mut stdout := []string{}
	if options.debug && options.verbose {
		stdout << if options.debug_arguments != '' {
			options.debug_arguments
		} else {
			options.named.str()
		}
		if options.livecheck_watchlist != '' {
			stdout << options.livecheck_watchlist
		}
	}
	mut checks := []ruby.Value{}
	mut ran_checks := false
	if selected.len > 0 {
		ran_checks = true
		package_values := selected.map(livecheck_core.livecheck_package_value(it))
		checks = livecheck_core.ruby_livecheck_l160_d5_self_run_checks(ruby.array_value(package_values), livecheck_run_options_value(run_options)).as_array() or {
			[]ruby.Value{}
		}
		livecheck_command_render(checks, options, mut stdout, mut stderr)
		if options.newer_only && checks.len == 0 && !options.debug && !options.json && !options.quiet {
			stdout << 'No newer upstream versions.'
		}
	}
	return LivecheckCommandResult{
		bundler_groups: ['livecheck']
		selection: selection
		eval_all: eval_all
		selected: selected
		skipped_autobump: skipped_autobump
		skip_messages: skip_messages
		run_options: run_options
		effective_extract_plist: options.extract_plist || selected.len == 1
		loaded_strategy_paths: livecheck_core.livecheck_other_tap_strategy_paths(selected)
		ran_checks: ran_checks
		checks: checks
		stdout: stdout
		stderr: stderr
		show_progress: ran_checks && options.json && !options.quiet && options.stderr_tty
	}
}

fn livecheck_command_result_value(result LivecheckCommandResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':          ruby.string_array_value(result.bundler_groups)
		'selection':               ruby.string_value(result.selection)
		'eval_all':                ruby.bool_value(result.eval_all)
		'selected':                ruby.array_value(result.selected.map(livecheck_core.livecheck_package_value(it)))
		'skipped_autobump':        ruby.bool_value(result.skipped_autobump)
		'skip_messages':           ruby.string_array_value(result.skip_messages)
		'run_options':             livecheck_run_options_value(result.run_options)
		'effective_extract_plist': ruby.bool_value(result.effective_extract_plist)
		'loaded_strategy_paths':   ruby.string_array_value(result.loaded_strategy_paths)
		'ran_checks':              ruby.bool_value(result.ran_checks)
		'checks':                  ruby.array_value(result.checks)
		'stdout':                  ruby.string_array_value(result.stdout)
		'stderr':                  ruby.string_array_value(result.stderr)
		'show_progress':           ruby.bool_value(result.show_progress)
	})
}
