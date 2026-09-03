module dev_cmd

import brew_runtime
import homebrew.livecheck as livecheck_core
import os

// Translated from Homebrew/brew `dev-cmd/livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

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
	checks                  []brew_runtime.Value
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

pub fn livecheck_command_input_boundary(input &LivecheckCommandInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::LivecheckCmd::Input', '', {
		'livecheck_command_input_address': u64(voidptr(input)).str()
	})
}

fn livecheck_command_input_from_value(value brew_runtime.Value) &LivecheckCommandInput {
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

fn livecheck_run_options_value(options LivecheckRunOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'json':                 brew_runtime.bool_value(options.json)
		'full_name':            brew_runtime.bool_value(options.full_name)
		'handle_name_conflict': brew_runtime.bool_value(options.handle_name_conflict)
		'check_resources':      brew_runtime.bool_value(options.check_resources)
		'newer_only':           brew_runtime.bool_value(options.newer_only)
		'extract_plist':        brew_runtime.bool_value(options.extract_plist)
		'quiet':                brew_runtime.bool_value(options.quiet)
		'debug':                brew_runtime.bool_value(options.debug)
		'verbose':              brew_runtime.bool_value(options.verbose)
	})
}

fn livecheck_command_info_name(info brew_runtime.Value) string {
	for key in ['formula', 'cask', 'resource'] {
		if value := info.map_data[key] {
			return value.as_string()
		}
	}
	return ''
}

fn livecheck_command_render(checks []brew_runtime.Value, options LivecheckCommandOptions, mut stdout []string, mut stderr []string) {
	if options.json {
		stdout << brew_runtime.json_value_to_string(brew_runtime.array_value(checks))
		return
	}
	for info in checks {
		status := (info.map_data['status'] or { brew_runtime.string_value('') }).as_string()
		if status == 'error' {
			if options.quiet {
				continue
			}
			name := livecheck_command_info_name(info)
			messages := (info.map_data['messages'] or { brew_runtime.string_array_value([]string{}) }).as_string_array() or {
				[]string{}
			}
			for message in messages {
				stderr << '${name}: ${message}'
			}
			continue
		}
		stdout << livecheck_core.ruby_livecheck_l492_d10_self_print_latest_version(info, brew_runtime.map_value({
			'verbose': brew_runtime.bool_value(options.verbose)
		})).as_string()
		if resources := info.map_data['resources'] {
			resource_lines := livecheck_core.ruby_livecheck_l515_d11_self_print_resources_info(resources, brew_runtime.map_value({
				'verbose': brew_runtime.bool_value(options.verbose)
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
	mut checks := []brew_runtime.Value{}
	mut ran_checks := false
	if selected.len > 0 {
		ran_checks = true
		package_values := selected.map(livecheck_core.livecheck_package_value(it))
		checks = livecheck_core.ruby_livecheck_l160_d5_self_run_checks(brew_runtime.array_value(package_values), livecheck_run_options_value(run_options)).as_array() or {
			[]brew_runtime.Value{}
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

fn livecheck_command_result_value(result LivecheckCommandResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bundler_groups':          brew_runtime.string_array_value(result.bundler_groups)
		'selection':               brew_runtime.string_value(result.selection)
		'eval_all':                brew_runtime.bool_value(result.eval_all)
		'selected':                brew_runtime.array_value(result.selected.map(livecheck_core.livecheck_package_value(it)))
		'skipped_autobump':        brew_runtime.bool_value(result.skipped_autobump)
		'skip_messages':           brew_runtime.string_array_value(result.skip_messages)
		'run_options':             livecheck_run_options_value(result.run_options)
		'effective_extract_plist': brew_runtime.bool_value(result.effective_extract_plist)
		'loaded_strategy_paths':   brew_runtime.string_array_value(result.loaded_strategy_paths)
		'ran_checks':              brew_runtime.bool_value(result.ran_checks)
		'checks':                  brew_runtime.array_value(result.checks)
		'stdout':                  brew_runtime.string_array_value(result.stdout)
		'stderr':                  brew_runtime.string_array_value(result.stderr)
		'show_progress':           brew_runtime.bool_value(result.show_progress)
	})
}

// Ruby method `run` at line 57.
pub fn ruby_livecheck_l57_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := livecheck_command_input_from_value(args[0])
	result := run_livecheck_command(input.options, input.sources) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return livecheck_command_result_value(result)
}

// Ruby method `watchlist_path` at line 155.
pub fn ruby_livecheck_l155_d2_watchlist_path(args ...brew_runtime.Value) brew_runtime.Value {
	configured := if args.len > 0 { args[0].as_string() } else { '' }
	working_directory := if args.len > 1 { args[1].as_string() } else { os.getwd() }
	user_home := if args.len > 2 { args[2].as_string() } else { os.getenv('HOME') }
	return brew_runtime.string_value(livecheck_watchlist_path(configured, working_directory, user_home))
}

// Ruby method `skip_autobump?` at line 160.
pub fn ruby_livecheck_l160_d3_skip_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	autobump := args.len > 0 && (args[0].as_bool() or { false })
	livecheck_autobump := args.len > 1 && (args[1].as_bool() or { false })
	return brew_runtime.bool_value(livecheck_skip_autobump(autobump, livecheck_autobump))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "livecheck/livecheck"
// 7: require "livecheck/strategy"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class LivecheckCmd < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check for newer versions of formulae and/or casks from upstream.
// 15:           If no formula or cask argument is passed, the list of formulae and
// 16:           casks to check is taken from `$HOMEBREW_LIVECHECK_WATCHLIST` or
// 17:           `${XDG_CONFIG_HOME}/homebrew/livecheck_watchlist.txt` if
// 18:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/livecheck_watchlist.txt`
// 19:           otherwise.
// 20:         EOS
// 21:         switch "--full-name",
// 22:                description: "Print formulae and casks with fully-qualified names."
// 23:         flag   "--tap=",
// 24:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 25:         switch "--eval-all",
// 26:                description: "Evaluate all available formulae and casks, whether installed or not, to check them.",
// 27:                env:         :eval_all,
// 28:                odeprecated: true
// 29:         switch "--installed",
// 30:                description: "Check formulae and casks that are currently installed."
// 31:         switch "--newer-only",
// 32:                description: "Show the latest version only if it's newer than the current formula or cask version."
// 33:         switch "--json",
// 34:                description: "Output information in JSON format."
// 35:         switch "-r", "--resources",
// 36:                description: "Also check resources for formulae."
// 37:         switch "-q", "--quiet",
// 38:                description: "Suppress warnings, don't print a progress bar for JSON output."
// 39:         switch "--formula", "--formulae",
// 40:                description: "Only check formulae."
// 41:         switch "--cask", "--casks",
// 42:                description: "Only check casks."
// 43:         switch "--extract-plist",
// 44:                description: "Enable checking multiple casks with ExtractPlist strategy."
// 45:         switch "--autobump",
// 46:                description: "Include packages that are autobumped by BrewTestBot. By default these are skipped."
// 47:
// 48:         conflicts "--tap", "--installed", "--eval-all"
// 49:         conflicts "--json", "--debug"
// 50:         conflicts "--formula", "--cask"
// 51:         conflicts "--formula", "--extract-plist"
// 52:
// 53:         named_args [:formula, :cask], without_api: true
// 54:       end
// 55:
// 56:       sig { override.void }
// 57:       def run
// 58:         Homebrew.install_bundler_gems!(groups: ["livecheck"])
// 59:
// 60:         eval_all = args.eval_all?
// 61:         eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 62:
// 63:         if args.debug? && args.verbose?
// 64:           puts args
// 65:           puts Homebrew::EnvConfig.livecheck_watchlist if Homebrew::EnvConfig.livecheck_watchlist.present?
// 66:         end
// 67:
// 68:         formulae_and_casks_to_check = T.let(
// 69:           Homebrew.with_no_api_env do
// 70:             if args.tap
// 71:               tap = Tap.fetch(args.tap)
// 72:               formulae = args.cask? ? [] : tap.formula_files.map { |path| Formulary.factory(path) }
// 73:               casks = args.formula? ? [] : tap.cask_files.map { |path| Cask::CaskLoader.load(path) }
// 74:               formulae + casks
// 75:             elsif args.installed?
// 76:               formulae = args.cask? ? [] : Formula.installed
// 77:               casks = args.formula? ? [] : Cask::Caskroom.casks
// 78:               formulae + casks
// 79:             elsif args.named.present?
// 80:               args.named.to_formulae_and_casks_with_taps
// 81:             elsif eval_all
// 82:               formulae = args.cask? ? [] : Formula.all(eval_all:)
// 83:               casks = args.formula? ? [] : Cask::Cask.all(eval_all:)
// 84:               formulae + casks
// 85:             elsif File.exist?(watchlist_path)
// 86:               begin
// 87:                 # This removes blank lines, comment lines, and trailing comments
// 88:                 names = Pathname.new(watchlist_path).read.lines
// 89:                                 .filter_map do |line|
// 90:                                   comment_index = line.index("#")
// 91:                                   next if comment_index&.zero?
// 92:
// 93:                                   line = line[0...comment_index] if comment_index
// 94:                                   line&.strip.presence
// 95:                                 end
// 96:
// 97:                 named_args = CLI::NamedArgs.new(*names, parent: args)
// 98:                 named_args.to_formulae_and_casks(ignore_unavailable: true)
// 99:               rescue Errno::ENOENT => e
// 100:                 onoe e
// 101:               end
// 102:             else
// 103:               raise UsageError,
// 104:                     "`brew livecheck` with no arguments needs a watchlist file, " \
// 105:                     "`HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 106:             end
// 107:           end,
// 108:           T::Array[T.any(Formula, Cask::Cask)],
// 109:         )
// 110:
// 111:         skipped_autobump = T.let(false, T::Boolean)
// 112:         if skip_autobump?
// 113:           autobump_lists = {}
// 114:
// 115:           formulae_and_casks_to_check = formulae_and_casks_to_check.reject do |formula_or_cask|
// 116:             tap = formula_or_cask.tap
// 117:             next false if tap.nil?
// 118:
// 119:             autobump_lists[tap] ||= tap.autobump
// 120:
// 121:             name = Utils.name_or_token(formula_or_cask)
// 122:             next unless autobump_lists[tap].include?(name)
// 123:
// 124:             odebug "Skipping #{name} as it is autobumped in #{tap}."
// 125:             skipped_autobump = true
// 126:             true
// 127:           end
// 128:         end
// 129:
// 130:         formulae_and_casks_to_check = formulae_and_casks_to_check.sort_by do |formula_or_cask|
// 131:           Utils.name_or_token(formula_or_cask)
// 132:         end
// 133:
// 134:         raise UsageError, "No formulae or casks to check." if formulae_and_casks_to_check.blank? && !skipped_autobump
// 135:         return if formulae_and_casks_to_check.blank?
// 136:
// 137:         options = {
// 138:           json:                 args.json?,
// 139:           full_name:            args.full_name?,
// 140:           handle_name_conflict: !args.formula? && !args.cask?,
// 141:           check_resources:      args.resources?,
// 142:           newer_only:           args.newer_only?,
// 143:           extract_plist:        args.extract_plist?,
// 144:           quiet:                args.quiet?,
// 145:           debug:                args.debug?,
// 146:           verbose:              args.verbose?,
// 147:         }.compact
// 148:
// 149:         Livecheck.run_checks(formulae_and_casks_to_check, **options)
// 150:       end
// 151:
// 152:       private
// 153:
// 154:       sig { returns(String) }
// 155:       def watchlist_path
// 156:         @watchlist_path ||= T.let(File.expand_path(Homebrew::EnvConfig.livecheck_watchlist), T.nilable(String))
// 157:       end
// 158:
// 159:       sig { returns(T::Boolean) }
// 160:       def skip_autobump?
// 161:         !(args.autobump? || Homebrew::EnvConfig.livecheck_autobump?)
// 162:       end
// 163:     end
// 164:   end
// 165: end
