module homebrew

import ruby
import homebrew.cli
import homebrew.cmd
import homebrew.api
import os

// Translated from Homebrew/brew `brew.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: phase_timings_output = ENV.delete("HOMEBREW_PHASE_TIMINGS")
// 5: if phase_timings_output
// 6:   phase_timings_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f
// 7:   phase_timings_command = ARGV.dup
// 8: end
// 9:
// 10: # `HOMEBREW_STACKPROF` should be set via `brew prof --stackprof`, not manually.
// 11: if ENV["HOMEBREW_STACKPROF"]
// 12:   require "rubygems"
// 13:   require "stackprof"
// 14:   StackProf.start(mode: :wall, raw: true)
// 15: end
// 16:
// 17: raise "HOMEBREW_BREW_FILE was not exported! Please call bin/brew directly!" unless ENV["HOMEBREW_BREW_FILE"]
// 18: if $PROGRAM_NAME != __FILE__ && !$PROGRAM_NAME.end_with?("/bin/ruby-prof")
// 19:   raise "#{__FILE__} must not be loaded via `require`."
// 20: end
// 21:
// 22: std_trap = trap("INT") { exit! 130 } # no backtrace thanks
// 23:
// 24: require_relative "global"
// 25: require "utils/output"
// 26:
// 27: require "utils/phase_timings"
// 28: if phase_timings_output
// 29:   Homebrew::PhaseTimings.start!(
// 30:     output_path: phase_timings_output,
// 31:     started_at:  phase_timings_started_at,
// 32:     command:     phase_timings_command,
// 33:   )
// 34: end
// 35:
// 36: begin
// 37:   trap("INT", std_trap) # restore default CTRL-C handler
// 38:
// 39:   if ENV["CI"]
// 40:     $stdout.sync = true
// 41:     $stderr.sync = true
// 42:   end
// 43:
// 44:   empty_argv = ARGV.empty?
// 45:   help_flag_list = %w[-h --help --usage -?]
// 46:   help_flag = !ENV["HOMEBREW_HELP"].nil?
// 47:   help_cmd_index = T.let(nil, T.nilable(Integer))
// 48:   cmd = T.let(nil, T.nilable(String))
// 49:
// 50:   ARGV.each_with_index do |arg, i|
// 51:     break if help_flag && cmd
// 52:
// 53:     if arg == "help" && !cmd
// 54:       # Command-style help: `help <cmd>` is fine, but `<cmd> help` is not.
// 55:       help_flag = true
// 56:       help_cmd_index = i
// 57:     elsif !cmd && help_flag_list.exclude?(arg)
// 58:       cmd = ARGV.delete_at(i)
// 59:     end
// 60:   end
// 61:
// 62:   ARGV.delete_at(help_cmd_index) if help_cmd_index
// 63:
// 64:   args = Homebrew::PhaseTimings.measure("cli_parse") do
// 65:     require "cli/parser"
// 66:     Homebrew::CLI::Parser.new(Homebrew::Cmd::Brew).parse(ARGV.dup.freeze, ignore_invalid_options: true)
// 67:   end
// 68:   Context.current = args.context
// 69:
// 70:   path = PATH.new(ENV.fetch("PATH"))
// 71:   homebrew_path = PATH.new(ENV.fetch("HOMEBREW_PATH"))
// 72:
// 73:   # Add shared wrappers.
// 74:   path.prepend(HOMEBREW_SHIMS_PATH/"shared")
// 75:   homebrew_path.prepend(HOMEBREW_SHIMS_PATH/"shared")
// 76:
// 77:   ENV["PATH"] = path.to_s
// 78:
// 79:   require "commands"
// 80:
// 81:   internal_cmd = T.let(false, T::Boolean)
// 82:   external_ruby_v2_cmd = T.let(false, T::Boolean)
// 83:   external_ruby_cmd_path = T.let(nil, T.nilable(Pathname))
// 84:   external_cmd_path = T.let(nil, T.nilable(Pathname))
// 85:
// 86:   # `valid_internal_cmd?` requires the command's file, so this covers the
// 87:   # command's entire `require` graph: usually the largest phase of all.
// 88:   Homebrew::PhaseTimings.measure("command_load") do
// 89:     if cmd
// 90:       cmd = Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.fetch(cmd, cmd)
// 91:       internal_cmd = Commands.valid_internal_cmd?(cmd) || Commands.valid_internal_dev_cmd?(cmd)
// 92:
// 93:       unless internal_cmd
// 94:         # Add contributed commands to PATH before checking.
// 95:         homebrew_path.append(Commands.tap_cmd_directories)
// 96:
// 97:         # External commands expect a normal PATH
// 98:         ENV["PATH"] = homebrew_path.to_s
// 99:
// 100:         external_ruby_v2_cmd = !Commands.external_ruby_v2_cmd_path(cmd).nil?
// 101:         external_ruby_cmd_path = Commands.external_ruby_cmd_path(cmd) unless external_ruby_v2_cmd
// 102:         external_cmd_path = Commands.external_cmd_path(cmd) if !external_ruby_v2_cmd && external_ruby_cmd_path.nil?
// 103:       end
// 104:     end
// 105:   end
// 106:
// 107:   # Usage instructions should be displayed if and only if one of:
// 108:   # - a help flag is passed AND a command is matched
// 109:   # - a help flag is passed AND there is no command specified
// 110:   # - no arguments are passed
// 111:   if empty_argv || help_flag
// 112:     require "help"
// 113:     # `Homebrew::Help.help` may defer to a self-documenting external command's own
// 114:     # `--help` (e.g. `brew help <cmd>`). Pass `--help`, not the Homebrew help flag
// 115:     # that triggered this (`-h`, `--usage`, `-?`), which the command may not know.
// 116:     if external_cmd_path
// 117:       ARGV.reject! { |arg| help_flag_list.include?(arg) }
// 118:       ARGV.push("--help")
// 119:     end
// 120:     Homebrew::Help.help cmd, remaining_args: args.remaining, empty_argv:
// 121:     # `Homebrew::Help.help` never returns, except for unknown and deferred commands.
// 122:   end
// 123:
// 124:   if cmd.nil?
// 125:     raise UsageError, "Unknown command: brew #{ARGV.join(" ")}"
// 126:   elsif internal_cmd || external_ruby_v2_cmd
// 127:     cmd_class = Homebrew::AbstractCommand.command(cmd)
// 128:     if cmd_class&.include?(Homebrew::ShellCommand)
// 129:       exec (HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew").to_s, cmd, *ARGV
// 130:     end
// 131:     Homebrew.running_command = cmd
// 132:     if cmd_class
// 133:       install_from_api = !Homebrew::EnvConfig.no_install_from_api?
// 134:       require "api" if install_from_api
// 135:       Homebrew::PhaseTimings.install! if phase_timings_output
// 136:       Homebrew::API.fetch_api_files! if install_from_api
// 137:
// 138:       command_instance = Homebrew::PhaseTimings.measure("cli_parse") { cmd_class.new }
// 139:
// 140:       require "utils/analytics"
// 141:       Utils::Analytics.report_command_run(command_instance)
// 142:       command_instance.run
// 143:     else
// 144:       Utils::Output.odisabled "Calling `brew #{cmd}` without subclassing `AbstractCommand`",
// 145:                               "subclassing of `Homebrew::AbstractCommand` " \
// 146:                               "(see https://docs.brew.sh/External-Commands)"
// 147:       begin
// 148:         Homebrew.public_send Commands.method_name(cmd)
// 149:       rescue NoMethodError => e
// 150:         converted_cmd = cmd.downcase.tr("-", "_")
// 151:         case_error = "undefined method `#{converted_cmd}' for module Homebrew"
// 152:         private_method_error = "private method `#{converted_cmd}' called for module Homebrew"
// 153:         Utils::Output.odie "Unknown command: brew #{cmd}" if [case_error, private_method_error].include?(e.message)
// 154:
// 155:         raise
// 156:       end
// 157:     end
// 158:   elsif external_ruby_cmd_path
// 159:     Homebrew.running_command = cmd
// 160:     Homebrew.require?(external_ruby_cmd_path)
// 161:     exit Homebrew.failed? ? 1 : 0
// 162:   elsif external_cmd_path
// 163:     ENV["HOMEBREW_CACHE"] = HOMEBREW_CACHE.to_s
// 164:     ENV["HOMEBREW_LIBRARY_PATH"] = HOMEBREW_LIBRARY_PATH.to_s
// 165:     exec external_cmd_path.to_s, *ARGV
// 166:   else
// 167:     raise UsageError, "Unknown command: brew #{cmd}#{Commands.suggestion_message(cmd)}"
// 168:   end
// 169: rescue UsageError => e
// 170:   require "help"
// 171:   Homebrew::Help.help cmd, remaining_args: args&.remaining || [], usage_error: e.message
// 172: rescue SystemExit => e
// 173:   Utils::Output.onoe "Kernel.exit" if args&.debug? && !e.success?
// 174:   if args&.debug? || ARGV.include?("--debug")
// 175:     require "utils/backtrace"
// 176:     $stderr.puts Utils::Backtrace.clean(e)
// 177:   end
// 178:   raise
// 179: rescue Interrupt
// 180:   $stderr.puts # seemingly a newline is typical
// 181:   exit 130
// 182: rescue BuildError => e
// 183:   Utils::Analytics.report_build_error(e)
// 184:   e.dump(verbose: args&.verbose? || false)
// 185:
// 186:   if OS.not_tier_one_configuration?
// 187:     $stderr.puts <<~EOS
// 188:       This build failure was expected, as this is not a Tier 1 configuration:
// 189:         #{Formatter.url("https://docs.brew.sh/Support-Tiers")}
// 190:       #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 191:       Read the above document instead before opening any issues or PRs.
// 192:     EOS
// 193:   elsif (formula = e.formula) && (formula.head? || formula.deprecated? || formula.disabled?)
// 194:     reason = if formula.head?
// 195:       "was built from an unstable upstream --HEAD"
// 196:     elsif formula.deprecated?
// 197:       "is deprecated"
// 198:     elsif formula.disabled?
// 199:       "is disabled"
// 200:     end
// 201:     $stderr.puts <<~EOS
// 202:       #{formula.name}'s formula #{reason}.
// 203:       This build failure is expected behaviour.
// 204:     EOS
// 205:   end
// 206:
// 207:   exit 1
// 208: rescue RuntimeError, SystemCallError => e
// 209:   raise if e.message.empty?
// 210:
// 211:   Utils::Output.onoe e
// 212:   if args&.debug? || ARGV.include?("--debug")
// 213:     require "utils/backtrace"
// 214:     $stderr.puts Utils::Backtrace.clean(e)
// 215:   end
// 216:
// 217:   exit 1
// 218: # Catch any other types of exceptions.
// 219: rescue Exception => e # rubocop:disable Lint/RescueException
// 220:   Utils::Output.onoe e
// 221:
// 222:   method_deprecated_error = e.is_a?(MethodDeprecatedError)
// 223:   require "utils/backtrace"
// 224:   $stderr.puts Utils::Backtrace.clean(e) if args&.debug? || ARGV.include?("--debug") || !method_deprecated_error
// 225:
// 226:   if OS.not_tier_one_configuration?
// 227:     $stderr.puts <<~EOS
// 228:       This error was expected, as this is not a Tier 1 configuration:
// 229:         #{Formatter.url("https://docs.brew.sh/Support-Tiers")}
// 230:       #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 231:       Read the above document instead before opening any issues or PRs.
// 232:     EOS
// 233:   elsif Homebrew::EnvConfig.no_auto_update? &&
// 234:         (fetch_head = HOMEBREW_REPOSITORY/".git/FETCH_HEAD") &&
// 235:         (!fetch_head.exist? || (fetch_head.mtime.to_date < Date.today))
// 236:     $stderr.puts "#{Tty.bold}You have disabled automatic updates and have not updated today.#{Tty.reset}"
// 237:     $stderr.puts "#{Tty.bold}Do not report this issue until you've run `brew update` and tried again.#{Tty.reset}"
// 238:   elsif (issues_url = (method_deprecated_error && e.issues_url) || Utils::Backtrace.tap_error_url(e))
// 239:     $stderr.puts Utils::Output.issue_reporting_message(issues_url)
// 240:   elsif internal_cmd && !method_deprecated_error
// 241:     if OS.nix_managed_homebrew?
// 242:       $stderr.puts Utils::Output.issue_reporting_message(OS::ISSUES_URL)
// 243:     else
// 244:       $stderr.puts Utils::Output.issue_reporting_message(OS::ISSUES_URL, homebrew: true)
// 245:     end
// 246:   end
// 247:
// 248:   exit 1
// 249: else
// 250:   exit 1 if Homebrew.failed?
// 251: ensure
// 252:   if ENV["HOMEBREW_STACKPROF"]
// 253:     StackProf.stop
// 254:     StackProf.results("prof/stackprof.dump")
// 255:   end
// 256:   Homebrew::PhaseTimings.write! if phase_timings_output
// 257: end
