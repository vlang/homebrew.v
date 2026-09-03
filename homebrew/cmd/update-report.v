module cmd

import brew_runtime
import homebrew.cmd.update_report
import os

// Translated from Homebrew/brew `cmd/update-report.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct UpdateReportOptions {
pub:
	auto_update bool
	force       bool
	quiet       bool
	verbose     bool
	stdout_tty  bool
}

pub struct UpdateReportAnalyticsState {
pub:
	messages_displayed       bool
	no_message_output        bool
	disabled                 bool
	influx_message_displayed bool
}

pub struct UpdateReportRedirect {
pub:
	tap_path                  string
	redirected_remote         string
	old_repository_var_suffix string
	new_repository_var_suffix string
	allowed                   bool = true
	installed                 bool
	branch                    string
	origin_branch             string
	error_message             string
}

pub struct UpdateReportCoreTap {
pub:
	name                         string
	installed                    bool
	git_branch                   string
	last_commit_older_than_month bool
}

pub struct UpdateReportContext {
pub mut:
	environment                     map[string]string
	settings                        map[string]string
	repository                      string
	caskroom                        string
	cask_migration_results          map[string]string
	cask_migration_errors           map[string]string
	redirects                       []UpdateReportRedirect
	core_taps                       []UpdateReportCoreTap
	reporters                       []update_report.Reporter
	hub_dump_context                update_report.ReporterHubDumpContext
	analytics                       UpdateReportAnalyticsState
	no_install_from_api             bool
	automatically_no_install_api    bool
	developer                       bool
	disable_load_formula            bool
	docker_prefix                   bool
	github_runner                   bool
	dev_command_run                 bool
	update_test                     bool
	latest_tag                      string
	new_tag                         string
	api_formula_names_exists        bool
	api_formula_names_before_exists bool
	api_cask_names_exists           bool
	api_cask_names_before_exists    bool
	api_formula_reporter            update_report.Reporter
	api_cask_reporter               update_report.Reporter
	commands_completion_ok          bool = true
	links_ok                        bool = true
	vendor_changed                  bool
	homebrew_failed                 bool
}

pub struct UpdateReportResult {
pub:
	stdout               string
	stderr               string
	actions              []string
	warnings             []string
	updated              bool
	updated_taps         []string
	new_tag              string
	homebrew_failed      bool
	prewarm              bool
	reinstall_pkgconf    bool
	rebuilt_completions  bool
	linked_documentation bool
	migrated_caskfiles   []string
}

pub fn update_report_no_changes_message() string {
	return 'No changes to formulae or casks.'
}

pub fn update_report_donation_message(mut settings map[string]string, stdout_tty bool) string {
	if settings['donationmessage'] or { '' } == 'true' {
		return ''
	}
	if stdout_tty {
		settings['donationmessage'] = 'true'
	}
	return '==> Homebrew is run entirely by unpaid volunteers. Please consider donating:\n  https://github.com/Homebrew/brew#-donations\n\n'
}

pub fn update_report_analytics_message(state UpdateReportAnalyticsState,
	stdout_tty bool) (string, bool) {
	if state.messages_displayed || state.no_message_output {
		return '', false
	}
	mut output := ''
	mut suppress_this_run := false
	if state.disabled && !state.influx_message_displayed {
		output = "==> Homebrew's analytics have entirely moved to our InfluxDB instance in the EU.\nWe gather less data than before and have destroyed all Google Analytics data:\n  https://docs.brew.sh/Analytics\nPlease reconsider re-enabling analytics to help our volunteer maintainers with:\n  brew analytics on\n"
	} else if !state.disabled {
		suppress_this_run = true
		output = '\a==> Homebrew collects anonymous analytics.\nRead the analytics documentation (and how to opt-out) here:\n  https://docs.brew.sh/Analytics\nNo analytics have been recorded yet (nor will be during this `brew` run).\n\n'
	}
	return output, suppress_this_run || stdout_tty
}

pub fn update_report_install_from_api_message(mut settings map[string]string,
	no_install_from_api bool, automatically_set bool, stdout_tty bool) string {
	if settings['installfromapimessage'] or { '' } == 'true' || !no_install_from_api || automatically_set {
		return ''
	}
	if stdout_tty {
		settings['installfromapimessage'] = 'true'
	}
	return '==> You have `\$HOMEBREW_NO_INSTALL_FROM_API` set\nHomebrew >=4.1.0 is dramatically faster and less error-prone when installing\nfrom the JSON API. Please consider unsetting `\$HOMEBREW_NO_INSTALL_FROM_API`.\nThis message will only be printed once.\n\n\n'
}

pub fn update_report_shorten_revision(repository string, revision string) !string {
	result := brew_runtime.run_command('git', ['-C', repository, 'rev-parse', '--short', revision])
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result.output.trim_space()
}

pub fn update_report_migrate_caskroom(caskroom string, migration_results map[string]string,
	migration_errors map[string]string) ([]string, []string) {
	if !os.is_dir(caskroom) {
		return []string{}, []string{}
	}
	mut files := []string{}
	files << os.glob(os.join_path(caskroom, '*', '.metadata', '*', '*', 'Casks', '*.json')) or { []string{} }
	files << os.glob(os.join_path(caskroom, '*', '.metadata', '*', '*', 'Casks', '*.rb')) or { []string{} }
	files.sort()
	mut migrated_files := []string{}
	mut migration_warnings := []string{}
	for caskfile in files {
		if failure := migration_errors[caskfile] {
			migration_warnings << 'Failed to migrate ${caskfile} to JSON metadata: ${failure}'
			continue
		}
		if migrated := migration_results[caskfile] {
			if migrated != '' {
				migrated_files << migrated
			}
		}
	}
	return migrated_files, migration_warnings
}

pub fn update_report_tap_or_untap(context UpdateReportContext) ([]string, string) {
	if context.update_test {
		return []string{}, ''
	}
	if context.no_install_from_api {
		if context.automatically_no_install_api {
			return []string{}, ''
		}
		for tap in context.core_taps {
			if tap.name == 'homebrew/core' && !tap.installed {
				return ['tap ${tap.name}'], ''
			}
		}
		return []string{}, ''
	}
	if context.developer || context.dev_command_run || context.github_runner || context.docker_prefix {
		return []string{}, ''
	}
	mut tap_actions := []string{}
	mut lines := []string{}
	mut header := false
	for tap in context.core_taps {
		if !tap.installed {
			continue
		}
		if tap.git_branch in ['main', 'master'] && tap.last_commit_older_than_month {
			lines << '==> ${tap.name} is old and unneeded, untapping to save space...'
			tap_actions << 'untap ${tap.name}'
		} else {
			if !header {
				lines << 'Installing from the API is now the default behaviour!'
				lines << 'You can save space and time by running:'
				header = true
			}
			lines << '  brew untap ${tap.name}'
		}
	}
	return tap_actions, if lines.len > 0 { lines.join('\n') + '\n' } else { '' }
}

fn update_report_version_parts(version string) (int, int, int) {
	parts := version.trim_string_left('v').split('.')
	if parts.len >= 3 {
		return parts[0].int(), parts[1].int(), parts[2].all_before('-').int()
	}
	if parts.len == 2 {
		return parts[0].int(), parts[1].int(), 0
	}
	return version.int(), 0, 0
}

fn update_report_plural_taps(taps []string) string {
	return if taps.len == 1 {
		'1 tap (${taps[0]})'
	} else {
		'${taps.len} taps (${taps.join(', ')})'
	}
}

pub fn run_update_report(options UpdateReportOptions,
	mut context UpdateReportContext) !UpdateReportResult {
	mut stdout := ''
	mut stderr := ''
	mut warnings := []string{}
	mut actions := []string{}
	mut output := ''
	if context.environment['HOMEBREW_ADDITIONAL_GOOGLE_ANALYTICS_ID'] or { '' } != '' {
		warnings << 'HOMEBREW_ADDITIONAL_GOOGLE_ANALYTICS_ID is now a no-op so can be unset.'
		output += 'All Homebrew Google Analytics code and data was destroyed.\n'
	}
	if context.environment['HOMEBREW_NO_GOOGLE_ANALYTICS'] or { '' } != '' {
		warnings << 'HOMEBREW_NO_GOOGLE_ANALYTICS is now a no-op so can be unset.'
		output += 'All Homebrew Google Analytics code and data was destroyed.\n'
	}
	if !options.quiet {
		analytics_output, analytics_changed := update_report_analytics_message(context.analytics, options.stdout_tty)
		output += analytics_output
		if analytics_changed {
			context.environment['HOMEBREW_NO_ANALYTICS_THIS_RUN'] = '1'
		}
		output += update_report_donation_message(mut context.settings, options.stdout_tty)
		output += update_report_install_from_api_message(mut context.settings, context.no_install_from_api, context.automatically_no_install_api, options.stdout_tty)
	}
	mut denied := []string{}
	for redirect in context.redirects {
		if !redirect.allowed {
			before := context.environment['HOMEBREW_UPDATE_BEFORE${redirect.old_repository_var_suffix}'] or { '' }
			if before != '' && redirect.installed {
				actions << 'git -C ${redirect.tap_path} reset --hard -q ${before}'
				branch := if redirect.branch != '' {
					redirect.branch
				} else {
					redirect.origin_branch
				}
				if branch != '' {
					actions << 'git -C ${redirect.tap_path} update-ref refs/remotes/origin/${branch} ${before}'
				}
			}
			denied << redirect.error_message
			continue
		}
		if redirect.old_repository_var_suffix != redirect.new_repository_var_suffix {
			for prefix in ['HOMEBREW_UPDATE_BEFORE', 'HOMEBREW_UPDATE_AFTER'] {
				old_value := context.environment['${prefix}${redirect.old_repository_var_suffix}'] or { '' }
				new_key := '${prefix}${redirect.new_repository_var_suffix}'
				if old_value != '' && (context.environment[new_key] or { '' }) == '' {
					context.environment[new_key] = old_value
				}
			}
		}
	}
	if denied.len > 0 {
		return error(denied.join('\n\n'))
	}
	tap_actions, tap_output := update_report_tap_or_untap(context)
	actions << tap_actions
	output += tap_output
	initial_revision := context.environment['HOMEBREW_UPDATE_BEFORE'] or { '' }
	current_revision := context.environment['HOMEBREW_UPDATE_AFTER'] or { '' }
	if initial_revision == '' || current_revision == '' {
		return error('update-report should not be called directly!')
	}
	mut updated := false
	mut old_tag := context.latest_tag
	new_tag := context.new_tag
	mut auto_header_printed := false
	if initial_revision != current_revision {
		if options.auto_update {
			output += '==> Auto-updated Homebrew!\n'
			auto_header_printed = true
		}
		updated = true
		if new_tag != old_tag {
			context.settings['latesttag'] = new_tag
		}
		initial_short := update_report_shorten_revision(context.repository, initial_revision) or { initial_revision }
		current_short := update_report_shorten_revision(context.repository, current_revision) or { current_revision }
		if new_tag == old_tag {
			output += '==> Updated Homebrew from ${initial_short} to ${current_short}.\n'
		} else if old_tag == '' {
			output += '==> Updated Homebrew from ${initial_short} to ${new_tag} (${current_short}).\n'
		} else {
			output += '==> Updated Homebrew from ${old_tag} (${initial_short}) to ${new_tag} (${current_short}).\n'
		}
	}
	if !context.no_install_from_api {
		actions << 'write names and aliases'
	}
	if context.environment['HOMEBREW_UPDATE_FAILED'] or { '' } != '' {
		context.homebrew_failed = true
	}
	migrated_caskfiles, cask_warnings := update_report_migrate_caskroom(context.caskroom, context.cask_migration_results, context.cask_migration_errors)
	warnings << cask_warnings
	if context.disable_load_formula {
		if options.stdout_tty {
			stdout = output
		} else {
			stderr = output
		}
		return UpdateReportResult{
			stdout: stdout
			stderr: stderr
			actions: actions
			warnings: warnings
			updated: updated
			new_tag: new_tag
			homebrew_failed: context.homebrew_failed
			migrated_caskfiles: migrated_caskfiles
		}
	}
	actions << 'migrate gcc dependents if needed'
	mut hub := update_report.ReporterHub{}
	mut updated_taps := []string{}
	for mut reporter in context.reporters {
		if reporter.updated() {
			updated_taps << reporter.tap.name
			hub.add(mut reporter, options.auto_update)
		}
	}
	if !context.no_install_from_api {
		if context.api_formula_names_exists {
			if context.api_formula_names_before_exists {
				mut reporter := context.api_formula_reporter
				if reporter.updated() {
					updated_taps << reporter.tap.name
					hub.add(mut reporter, options.auto_update)
				}
			} else {
				actions << 'copy formula_names.txt to formula_names.before.txt'
			}
		}
		if context.api_cask_names_exists {
			if context.api_cask_names_before_exists {
				mut reporter := context.api_cask_reporter
				if reporter.updated() {
					updated_taps << reporter.tap.name
					hub.add(mut reporter, options.auto_update)
				}
			} else {
				actions << 'copy cask_names.txt to cask_names.before.txt'
			}
		}
	}
	if updated_taps.len > 0 {
		if options.auto_update && !auto_header_printed {
			output += '==> Auto-updated Homebrew!\n'
			auto_header_printed = true
		}
		output += 'Updated ${update_report_plural_taps(updated_taps)}.\n'
		updated = true
	}
	if updated {
		if hub.empty() {
			if !options.quiet {
				output += update_report_no_changes_message() + '\n'
			}
		} else {
			if context.environment['HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED'] or { '' } != '' {
				warnings << 'HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED is now the default behaviour, so you can unset it from your environment.'
			}
			if !options.quiet {
				output += hub.dump(update_report.ReporterHubDumpContext{
					...context.hub_dump_context
					auto_update: options.auto_update
				})
			}
			actions << ['migrate tap migrations', 'migrate cask renames', 'migrate formula renames',
				'update formula descriptions', 'update cask descriptions']
		}
		if options.auto_update {
			output += '\n'
		}
	} else if !options.auto_update && (context.environment['HOMEBREW_UPDATE_FAILED'] or { '' }) == '' && !options.quiet {
		output += 'Already up-to-date.\n'
	}
	actions << ['reinstall pkgconf if needed', 'rebuild commands completion list',
		'link completions, manpages and docs']
	prewarm := !options.auto_update && initial_revision != current_revision && context.vendor_changed
	if prewarm {
		actions << 'prewarm bootsnap'
	}
	missing := context.environment['HOMEBREW_MISSING_REMOTE_REF_DIRS'] or { '' }
	if missing != '' {
		warnings << 'Some taps failed to update!\nThe following taps can not read their remote branches:\n  ${missing.split_into_lines().join('\n  ')}\nThis is happening because the remote branch was renamed or deleted.\nReset taps to point to the correct remote branches by running `brew tap --repair`'
	}
	if new_tag != '' && new_tag != old_tag && !options.quiet {
		major, minor, patch := update_report_version_parts(new_tag)
		old_major, old_minor, _ := update_report_version_parts(if old_tag == '' {
			'0'
		} else {
			old_tag
		})
		output += '\n'
		if major != old_major || minor != old_minor {
			output += 'The ${major}.${minor}.0 release notes are available on the Homebrew Blog:\n  https://brew.sh/blog/${major}.${minor}.0\n'
		}
		if patch != 0 {
			output += 'The ${new_tag} changelog can be found at:\n  https://github.com/Homebrew/brew/releases/tag/${new_tag}\n'
		}
	}
	if options.stdout_tty {
		stdout = output
	} else {
		stderr = output
	}
	return UpdateReportResult{
		stdout: stdout
		stderr: stderr
		actions: actions
		warnings: warnings
		updated: updated
		updated_taps: updated_taps
		new_tag: new_tag
		homebrew_failed: context.homebrew_failed
		prewarm: prewarm
		reinstall_pkgconf: true
		rebuilt_completions: true
		linked_documentation: context.links_ok
		migrated_caskfiles: migrated_caskfiles
	}
}

pub fn update_report_link_plan(repository string) []string {
	command := 'brew update'
	return ['link completions ${repository} (${command})',
		'link manpages ${repository} (${command})', 'link docs ${repository} (${command})']
}

fn update_report_result_value(result UpdateReportResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'stdout':       brew_runtime.string_value(result.stdout)
		'stderr':       brew_runtime.string_value(result.stderr)
		'actions':      brew_runtime.string_array_value(result.actions)
		'warnings':     brew_runtime.string_array_value(result.warnings)
		'updated':      brew_runtime.bool_value(result.updated)
		'updated_taps': brew_runtime.string_array_value(result.updated_taps)
		'new_tag':      brew_runtime.string_value(result.new_tag)
		'prewarm':      brew_runtime.bool_value(result.prewarm)
	})
}

fn update_report_context_from_value(value brew_runtime.Value) UpdateReportContext {
	mut environment := value.attributes.clone()
	if 'HOMEBREW_UPDATE_BEFORE' !in environment {
		environment['HOMEBREW_UPDATE_BEFORE'] = 'unchanged'
	}
	if 'HOMEBREW_UPDATE_AFTER' !in environment {
		environment['HOMEBREW_UPDATE_AFTER'] = environment['HOMEBREW_UPDATE_BEFORE']
	}
	return UpdateReportContext{
		environment: environment
		repository: value.attributes['repository'] or { '.' }
		caskroom: value.attributes['caskroom'] or { '' }
		no_install_from_api: (value.attributes['no_install_from_api'] or { 'true' }) == 'true'
		automatically_no_install_api: (value.attributes['automatically_no_install_api'] or { 'true' }) == 'true'
		disable_load_formula: (value.attributes['disable_load_formula'] or { 'true' }) == 'true'
		developer: (value.attributes['developer'] or { 'false' }) == 'true'
		update_test: (value.attributes['update_test'] or { 'true' }) == 'true'
		latest_tag: value.attributes['latest_tag'] or { '' }
		new_tag: value.attributes['new_tag'] or { '' }
	}
}

// Ruby method `run` at line 34.
pub fn ruby_update_report_l34_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 {
		args[0]
	} else {
		brew_runtime.structured_value('UpdateReport', '', {})
	}
	mut context := update_report_context_from_value(value)
	result := run_update_report(UpdateReportOptions{
		auto_update: (value.attributes['auto_update'] or { 'false' }) == 'true'
		force: (value.attributes['force'] or { 'false' }) == 'true'
		quiet: (value.attributes['quiet'] or { 'false' }) == 'true'
		verbose: (value.attributes['verbose'] or { 'false' }) == 'true'
		stdout_tty: (value.attributes['stdout_tty'] or { 'false' }) == 'true'
	}, mut context) or { return brew_runtime.object_value('SystemExit', err.msg()) }
	return update_report_result_value(result)
}

// Ruby method `migrate_caskroom_caskfiles_to_json` at line 43.
pub fn ruby_update_report_l43_d2_migrate_caskroom_caskfiles_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { '' }
	migrated, warnings := update_report_migrate_caskroom(path, map[string]string{}, map[string]string{})
	return brew_runtime.map_value({
		'migrated': brew_runtime.string_array_value(migrated)
		'warnings': brew_runtime.string_array_value(warnings)
	})
}

// Ruby method `donation_message` at line 54.
pub fn ruby_update_report_l54_d3_donation_message(args ...brew_runtime.Value) brew_runtime.Value {
	mut settings := map[string]string{}
	if args.len > 0 {
		settings = args[0].attributes.clone()
	}
	return brew_runtime.string_value(update_report_donation_message(mut settings, args.len > 1 && args[1].bool_data))
}

// Ruby method `auto_update_header` at line 67.
pub fn ruby_update_report_l67_d4_auto_update_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(if args.len > 0 && args[0].bool_data {
		'==> Auto-updated Homebrew!\n'
	} else {
		''
	})
}

// Ruby method `output_update_report` at line 75.
pub fn ruby_update_report_l75_d5_output_update_report(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_update_report_l34_d1_run(...args)
}

// Ruby method `no_changes_message` at line 322.
pub fn ruby_update_report_l322_d6_no_changes_message(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(update_report_no_changes_message())
}

// Ruby method `shorten_revision(revision)` at line 327.
pub fn ruby_update_report_l327_d7_shorten_revision(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	repository := if args.len > 1 { args[1].as_string() } else { '.' }
	short := update_report_shorten_revision(repository, args[0].as_string()) or {
		return brew_runtime.object_value('ErrorDuringExecution', err.msg())
	}
	return brew_runtime.string_value(short)
}

// Ruby method `tap_or_untap_core_taps_if_necessary` at line 332.
pub fn ruby_update_report_l332_d8_tap_or_untap_core_taps_if_necessary(args ...brew_runtime.Value) brew_runtime.Value {
	context := if args.len > 0 {
		update_report_context_from_value(args[0])
	} else {
		UpdateReportContext{ update_test: true }
	}
	actions, output := update_report_tap_or_untap(context)
	return brew_runtime.map_value({
		'actions': brew_runtime.string_array_value(actions)
		'output':  brew_runtime.string_value(output)
	})
}

// Ruby method `link_completions_manpages_and_docs(repository = HOMEBREW_REPOSITORY)` at line 372.
pub fn ruby_update_report_l372_d9_link_completions_manpages_and_docs(args ...brew_runtime.Value) brew_runtime.Value {
	repository := if args.len > 0 { args[0].as_string() } else { '.' }
	return brew_runtime.string_array_value(update_report_link_plan(repository))
}

// Ruby method `migrate_gcc_dependents_if_needed` at line 385.
pub fn ruby_update_report_l385_d10_migrate_gcc_dependents_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `analytics_message` at line 390.
pub fn ruby_update_report_l390_d11_analytics_message(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		UpdateReportAnalyticsState{
			messages_displayed: (args[0].attributes['messages_displayed'] or { 'false' }) == 'true'
			no_message_output: (args[0].attributes['no_message_output'] or { 'false' }) == 'true'
			disabled: (args[0].attributes['disabled'] or { 'false' }) == 'true'
			influx_message_displayed: (args[0].attributes['influx_message_displayed'] or { 'false' }) == 'true'
		}
	} else {
		UpdateReportAnalyticsState{}
	}
	output, changed := update_report_analytics_message(state, args.len > 1 && args[1].bool_data)
	return brew_runtime.map_value({
		'output':  brew_runtime.string_value(output)
		'changed': brew_runtime.bool_value(changed)
	})
}

// Ruby method `install_from_api_message` at line 420.
pub fn ruby_update_report_l420_d12_install_from_api_message(args ...brew_runtime.Value) brew_runtime.Value {
	mut settings := map[string]string{}
	if args.len > 0 {
		settings = args[0].attributes.clone()
	}
	return brew_runtime.string_value(update_report_install_from_api_message(mut settings, args.len > 1 && args[1].bool_data, args.len > 2 && args[2].bool_data, args.len > 3 && args[3].bool_data))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "migrator"
// 6: require "formulary"
// 7: require "cask/cask_loader"
// 8: require "cask/caskroom"
// 9: require "cask/migrator"
// 10: require "descriptions"
// 11: require "cleanup"
// 12: require "description_cache_store"
// 13: require "settings"
// 14: require "reinstall"
// 15: require "version"
// 16:
// 17: module Homebrew
// 18:   module Cmd
// 19:     class UpdateReport < AbstractCommand
// 20:       cmd_args do
// 21:         description <<~EOS
// 22:           The Ruby implementation of `brew update`. Never called manually.
// 23:         EOS
// 24:         switch "--auto-update", "--preinstall",
// 25:                description: "Run in 'auto-update' mode (faster, less output)."
// 26:         switch "-f", "--force",
// 27:                description: "Treat installed and updated formulae as if they are from " \
// 28:                             "the same taps and migrate them anyway."
// 29:
// 30:         hide_from_man_page!
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def run
// 35:         return output_update_report if $stdout.tty?
// 36:
// 37:         redirect_stdout($stderr) do
// 38:           output_update_report
// 39:         end
// 40:       end
// 41:
// 42:       sig { void }
// 43:       def migrate_caskroom_caskfiles_to_json
// 44:         return unless Cask::Caskroom.path.directory?
// 45:
// 46:         Cask::Caskroom.path.glob("*/.metadata/*/*/Casks/*.{json,rb}").each do |caskfile|
// 47:           Cask::Caskroom.migrate_caskfile_to_json(caskfile)
// 48:         rescue => e
// 49:           opoo "Failed to migrate #{caskfile} to JSON metadata: #{e}"
// 50:         end
// 51:       end
// 52:
// 53:       sig { void }
// 54:       def donation_message
// 55:         return if Settings.read("donationmessage") == "true"
// 56:
// 57:         ohai "Homebrew is run entirely by unpaid volunteers. Please consider donating:"
// 58:         puts "  #{Formatter.url("https://github.com/Homebrew/brew#-donations")}\n\n"
// 59:
// 60:         # Consider the message possibly missed if not a TTY.
// 61:         Settings.write "donationmessage", true if $stdout.tty?
// 62:       end
// 63:
// 64:       private
// 65:
// 66:       sig { void }
// 67:       def auto_update_header
// 68:         @auto_update_header ||= T.let(begin
// 69:           ohai "Auto-updated Homebrew!" if args.auto_update?
// 70:           true
// 71:         end, T.nilable(T::Boolean))
// 72:       end
// 73:
// 74:       sig { void }
// 75:       def output_update_report
// 76:         if ENV["HOMEBREW_ADDITIONAL_GOOGLE_ANALYTICS_ID"].present?
// 77:           opoo "HOMEBREW_ADDITIONAL_GOOGLE_ANALYTICS_ID is now a no-op so can be unset."
// 78:           puts "All Homebrew Google Analytics code and data was destroyed."
// 79:         end
// 80:
// 81:         if ENV["HOMEBREW_NO_GOOGLE_ANALYTICS"].present?
// 82:           opoo "HOMEBREW_NO_GOOGLE_ANALYTICS is now a no-op so can be unset."
// 83:           puts "All Homebrew Google Analytics code and data was destroyed."
// 84:         end
// 85:
// 86:         unless args.quiet?
// 87:           analytics_message
// 88:           donation_message
// 89:           install_from_api_message
// 90:         end
// 91:
// 92:         if (redirected_remotes_file = ENV.fetch("HOMEBREW_REDIRECTED_REMOTES_FILE", nil)).present?
// 93:           redirected_remotes_path = Pathname(redirected_remotes_file)
// 94:           if redirected_remotes_path.file?
// 95:             begin
// 96:               denied_redirects = []
// 97:               redirected_remotes_path.each_line do |line|
// 98:                 tap_path, redirected_remote = line.chomp.split("\t", 2)
// 99:                 next if tap_path.blank? || redirected_remote.blank?
// 100:                 next unless (tap = Tap.from_path(tap_path))
// 101:
// 102:                 old_repository_var_suffix = tap.repository_var_suffix
// 103:                 begin
// 104:                   tap.apply_redirected_remote!(redirected_remote, quiet: args.quiet?)
// 105:                 rescue TapRedirectNotAllowedError => e
// 106:                   # update.sh may already have merged redirected content, so roll back every denied tap.
// 107:                   before_revision = ENV.fetch("HOMEBREW_UPDATE_BEFORE#{old_repository_var_suffix}", nil)
// 108:                   if before_revision.present? && tap.installed?
// 109:                     git_args = ["-C", tap.path.to_s]
// 110:                     safe_system "git", *git_args, "reset", "--hard", "-q", before_revision
// 111:                     branch = Utils.popen_read("git", *git_args, "symbolic-ref", "--short", "-q", "HEAD").chomp
// 112:                     branch = branch.presence || tap.git_repository.origin_branch_name
// 113:                     if branch.present?
// 114:                       safe_system "git", *git_args, "update-ref", "refs/remotes/origin/#{branch}", before_revision
// 115:                     end
// 116:                   end
// 117:                   denied_redirects << e.message
// 118:                   next
// 119:                 end
// 120:                 new_repository_var_suffix = tap.repository_var_suffix
// 121:                 next if old_repository_var_suffix == new_repository_var_suffix
// 122:
// 123:                 ["HOMEBREW_UPDATE_BEFORE", "HOMEBREW_UPDATE_AFTER"].each do |prefix|
// 124:                   old_var = "#{prefix}#{old_repository_var_suffix}"
// 125:                   old_value = ENV.fetch(old_var, nil)
// 126:                   next if old_value.blank?
// 127:
// 128:                   ENV["#{prefix}#{new_repository_var_suffix}"] ||= old_value
// 129:                 end
// 130:               end
// 131:               odie denied_redirects.join("\n\n") if denied_redirects.any?
// 132:             ensure
// 133:               redirected_remotes_path.unlink if redirected_remotes_path.exist?
// 134:             end
// 135:           end
// 136:         end
// 137:         tap_or_untap_core_taps_if_necessary
// 138:
// 139:         updated = false
// 140:         new_tag = nil
// 141:
// 142:         initial_revision = ENV["HOMEBREW_UPDATE_BEFORE"].to_s
// 143:         current_revision = ENV["HOMEBREW_UPDATE_AFTER"].to_s
// 144:         odie "update-report should not be called directly!" if initial_revision.empty? || current_revision.empty?
// 145:
// 146:         if initial_revision != current_revision
// 147:           auto_update_header
// 148:
// 149:           updated = true
// 150:
// 151:           old_tag = Settings.read "latesttag"
// 152:
// 153:           new_tag = Utils.popen_read(
// 154:             "git", "-C", HOMEBREW_REPOSITORY, "tag", "--list", "--sort=-version:refname", "*.*"
// 155:           ).lines.fetch(0).chomp
// 156:
// 157:           Settings.write "latesttag", new_tag if new_tag != old_tag
// 158:
// 159:           if new_tag == old_tag
// 160:             ohai "Updated Homebrew from #{shorten_revision(initial_revision)} " \
// 161:                  "to #{shorten_revision(current_revision)}."
// 162:           elsif old_tag.blank?
// 163:             ohai "Updated Homebrew from #{shorten_revision(initial_revision)} " \
// 164:                  "to #{new_tag} (#{shorten_revision(current_revision)})."
// 165:           else
// 166:             ohai "Updated Homebrew from #{old_tag} (#{shorten_revision(initial_revision)}) " \
// 167:                  "to #{new_tag} (#{shorten_revision(current_revision)})."
// 168:           end
// 169:         end
// 170:
// 171:         # Check if we can parse the JSON and do any Ruby-side follow-up.
// 172:         Homebrew::API.write_names_and_aliases unless Homebrew::EnvConfig.no_install_from_api?
// 173:
// 174:         Homebrew.failed = true if ENV["HOMEBREW_UPDATE_FAILED"]
// 175:         migrate_caskroom_caskfiles_to_json
// 176:         return if Homebrew::EnvConfig.disable_load_formula?
// 177:
// 178:         migrate_gcc_dependents_if_needed
// 179:
// 180:         hub = ReporterHub.new
// 181:
// 182:         updated_taps = []
// 183:         Tap.installed.each do |tap|
// 184:           next if !tap.git? || tap.git_repository.origin_url.nil?
// 185:           next if (tap.core_tap? || tap.core_cask_tap?) && !Homebrew::EnvConfig.no_install_from_api?
// 186:
// 187:           begin
// 188:             reporter = Reporter.new(tap)
// 189:           rescue Reporter::ReporterRevisionUnsetError => e
// 190:             if Homebrew::EnvConfig.developer?
// 191:               require "utils/backtrace"
// 192:               onoe "#{e.message}\n#{Utils::Backtrace.clean(e)&.join("\n")}"
// 193:             end
// 194:             next
// 195:           end
// 196:           if reporter.updated?
// 197:             updated_taps << tap.name
// 198:             hub.add(reporter, auto_update: args.auto_update?)
// 199:           end
// 200:         end
// 201:
// 202:         # If we're installing from the API: we cannot use Git to check for #
// 203:         # differences in packages so instead use {formula,cask}_names.txt to do so.
// 204:         # The first time this runs: we won't yet have a base state
// 205:         # ({formula,cask}_names.before.txt) to compare against so we don't output a
// 206:         # anything and just copy the files for next time.
// 207:         unless Homebrew::EnvConfig.no_install_from_api?
// 208:           api_cache = Homebrew::API::HOMEBREW_CACHE_API
// 209:           core_tap = CoreTap.instance
// 210:           cask_tap = CoreCaskTap.instance
// 211:           [
// 212:             [:formula, core_tap, core_tap.formula_dir],
// 213:             [:cask,    cask_tap, cask_tap.cask_dir],
// 214:           ].each do |type, tap, dir|
// 215:             names_txt = api_cache/"#{type}_names.txt"
// 216:             next unless names_txt.exist?
// 217:
// 218:             names_before_txt = api_cache/"#{type}_names.before.txt"
// 219:             if names_before_txt.exist?
// 220:               reporter = Reporter.new(
// 221:                 tap,
// 222:                 api_names_txt:        names_txt,
// 223:                 api_names_before_txt: names_before_txt,
// 224:                 api_dir_prefix:       dir,
// 225:               )
// 226:               if reporter.updated?
// 227:                 updated_taps << tap.name
// 228:                 hub.add(reporter, auto_update: args.auto_update?)
// 229:               end
// 230:             else
// 231:               FileUtils.cp names_txt, names_before_txt
// 232:             end
// 233:           end
// 234:         end
// 235:
// 236:         unless updated_taps.empty?
// 237:           auto_update_header
// 238:           puts "Updated #{Utils.pluralize("tap", updated_taps.count,
// 239:                                           include_count: true)} (#{updated_taps.to_sentence})."
// 240:           updated = true
// 241:         end
// 242:
// 243:         if updated
// 244:           if hub.empty?
// 245:             puts no_changes_message unless args.quiet?
// 246:           else
// 247:             if ENV.fetch("HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED", false)
// 248:               opoo "HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED is now the default behaviour, " \
// 249:                    "so you can unset it from your environment."
// 250:             end
// 251:
// 252:             hub.dump(auto_update: args.auto_update?) unless args.quiet?
// 253:             hub.reporters.each(&:migrate_tap_migration)
// 254:             hub.reporters.each(&:migrate_cask_rename)
// 255:             hub.reporters.each { |r| r.migrate_formula_rename(force: args.force?, verbose: args.verbose?) }
// 256:
// 257:             CacheStoreDatabase.use(:descriptions) do |db|
// 258:               DescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 259:                                    .update_from_report!(hub)
// 260:             end
// 261:             CacheStoreDatabase.use(:cask_descriptions) do |db|
// 262:               CaskDescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 263:                                        .update_from_report!(hub)
// 264:             end
// 265:           end
// 266:           puts if args.auto_update?
// 267:         elsif !args.auto_update? && !ENV["HOMEBREW_UPDATE_FAILED"]
// 268:           puts "Already up-to-date." unless args.quiet?
// 269:         end
// 270:
// 271:         Homebrew::Reinstall.reinstall_pkgconf_if_needed!
// 272:
// 273:         Commands.rebuild_commands_completion_list
// 274:         link_completions_manpages_and_docs
// 275:         Tap.installed.each(&:link_completions_and_manpages)
// 276:
// 277:         # Only prewarm when the update changed `Library/Homebrew/vendor`:
// 278:         # portable Ruby bumps rotate the whole Bootsnap cache key and
// 279:         # vendored gem bumps rewrite gem trees this run never loads, while
// 280:         # for code-only updates this run has already recompiled most of
// 281:         # what the next command needs.
// 282:         if !args.auto_update? && initial_revision != current_revision &&
// 283:            !quiet_system("git", "-C", HOMEBREW_REPOSITORY.to_s, "diff", "--quiet",
// 284:                          initial_revision, current_revision, "--", "Library/Homebrew/vendor")
// 285:           Homebrew::Bootsnap.prewarm!
// 286:         end
// 287:
// 288:         failed_fetch_dirs = ENV["HOMEBREW_MISSING_REMOTE_REF_DIRS"]&.split("\n")
// 289:         if failed_fetch_dirs.present?
// 290:           failed_fetch_taps = failed_fetch_dirs.map { |dir| Tap.from_path(dir) }
// 291:
// 292:           ofail <<~EOS
// 293:             Some taps failed to update!
// 294:             The following taps can not read their remote branches:
// 295:               #{failed_fetch_taps.join("\n  ")}
// 296:             This is happening because the remote branch was renamed or deleted.
// 297:             Reset taps to point to the correct remote branches by running `brew tap --repair`
// 298:           EOS
// 299:         end
// 300:
// 301:         return if new_tag.blank? || new_tag == old_tag || args.quiet?
// 302:
// 303:         puts
// 304:
// 305:         new_version = ::Version.new(new_tag)
// 306:         if new_version.major_minor > ::Version.new(old_tag || "0").major_minor
// 307:           puts <<~EOS
// 308:             The #{new_version.major_minor}.0 release notes are available on the Homebrew Blog:
// 309:               #{Formatter.url("https://brew.sh/blog/#{new_version.major_minor}.0")}
// 310:           EOS
// 311:         end
// 312:
// 313:         return if new_version.patch.to_i.zero?
// 314:
// 315:         puts <<~EOS
// 316:           The #{new_tag} changelog can be found at:
// 317:             #{Formatter.url("https://github.com/Homebrew/brew/releases/tag/#{new_tag}")}
// 318:         EOS
// 319:       end
// 320:
// 321:       sig { returns(String) }
// 322:       def no_changes_message
// 323:         "No changes to formulae or casks."
// 324:       end
// 325:
// 326:       sig { params(revision: String).returns(String) }
// 327:       def shorten_revision(revision)
// 328:         Utils.popen_read("git", "-C", HOMEBREW_REPOSITORY, "rev-parse", "--short", revision).chomp
// 329:       end
// 330:
// 331:       sig { void }
// 332:       def tap_or_untap_core_taps_if_necessary
// 333:         return if ENV["HOMEBREW_UPDATE_TEST"]
// 334:
// 335:         if Homebrew::EnvConfig.no_install_from_api?
// 336:           return if Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 337:
// 338:           core_tap = CoreTap.instance
// 339:           return if core_tap.installed?
// 340:
// 341:           core_tap.ensure_installed!
// 342:           revision = CoreTap.instance.git_head
// 343:           ENV["HOMEBREW_UPDATE_BEFORE_HOMEBREW_HOMEBREW_CORE"] = revision
// 344:           ENV["HOMEBREW_UPDATE_AFTER_HOMEBREW_HOMEBREW_CORE"] = revision
// 345:         else
// 346:           return if Homebrew::EnvConfig.developer? || ENV["HOMEBREW_DEV_CMD_RUN"]
// 347:           return if ENV["HOMEBREW_GITHUB_HOSTED_RUNNER"] || ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"]
// 348:           return if (HOMEBREW_PREFIX/".homebrewdocker").exist?
// 349:
// 350:           tap_output_header_printed = T.let(false, T::Boolean)
// 351:           default_branches = %w[main master].freeze
// 352:           [CoreTap.instance, CoreCaskTap.instance].each do |tap|
// 353:             next unless tap.installed?
// 354:
// 355:             if default_branches.include?(tap.git_branch) &&
// 356:                (Date.parse(T.must(tap.git_repository.last_commit_date)) <= Date.today.prev_month)
// 357:               ohai "#{tap.name} is old and unneeded, untapping to save space..."
// 358:               tap.uninstall
// 359:             else
// 360:               unless tap_output_header_printed
// 361:                 puts "Installing from the API is now the default behaviour!"
// 362:                 puts "You can save space and time by running:"
// 363:                 tap_output_header_printed = true
// 364:               end
// 365:               puts "  brew untap #{tap.name}"
// 366:             end
// 367:           end
// 368:         end
// 369:       end
// 370:
// 371:       sig { params(repository: Pathname).void }
// 372:       def link_completions_manpages_and_docs(repository = HOMEBREW_REPOSITORY)
// 373:         command = "brew update"
// 374:         Utils::Link.link_completions(repository, command)
// 375:         Utils::Link.link_manpages(repository, command)
// 376:         Utils::Link.link_docs(repository, command)
// 377:       rescue => e
// 378:         ofail <<~EOS
// 379:           Failed to link all completions, docs and manpages:
// 380:             #{e}
// 381:         EOS
// 382:       end
// 383:
// 384:       sig { void }
// 385:       def migrate_gcc_dependents_if_needed
// 386:         # do nothing
// 387:       end
// 388:
// 389:       sig { void }
// 390:       def analytics_message
// 391:         return if Utils::Analytics.messages_displayed?
// 392:         return if Utils::Analytics.no_message_output?
// 393:
// 394:         if Utils::Analytics.disabled? && !Utils::Analytics.influx_message_displayed?
// 395:           ohai "Homebrew's analytics have entirely moved to our InfluxDB instance in the EU."
// 396:           puts "We gather less data than before and have destroyed all Google Analytics data:"
// 397:           puts "  #{Formatter.url("https://docs.brew.sh/Analytics")}#{Tty.reset}"
// 398:           puts "Please reconsider re-enabling analytics to help our volunteer maintainers with:"
// 399:           puts "  brew analytics on"
// 400:         elsif !Utils::Analytics.disabled?
// 401:           ENV["HOMEBREW_NO_ANALYTICS_THIS_RUN"] = "1"
// 402:           # Use the shell's audible bell.
// 403:           print "\a"
// 404:
// 405:           # Use an extra newline and bold to avoid this being missed.
// 406:           ohai "Homebrew collects anonymous analytics."
// 407:           puts <<~EOS
// 408:             #{Tty.bold}Read the analytics documentation (and how to opt-out) here:
// 409:               #{Formatter.url("https://docs.brew.sh/Analytics")}#{Tty.reset}
// 410:             No analytics have been recorded yet (nor will be during this `brew` run).
// 411:
// 412:           EOS
// 413:         end
// 414:
// 415:         # Consider the messages possibly missed if not a TTY.
// 416:         Utils::Analytics.messages_displayed! if $stdout.tty?
// 417:       end
// 418:
// 419:       sig { void }
// 420:       def install_from_api_message
// 421:         return if Settings.read("installfromapimessage") == "true"
// 422:
// 423:         no_install_from_api_set = Homebrew::EnvConfig.no_install_from_api? &&
// 424:                                   !Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 425:         return unless no_install_from_api_set
// 426:
// 427:         ohai "You have `$HOMEBREW_NO_INSTALL_FROM_API` set"
// 428:         puts "Homebrew >=4.1.0 is dramatically faster and less error-prone when installing"
// 429:         puts "from the JSON API. Please consider unsetting `$HOMEBREW_NO_INSTALL_FROM_API`."
// 430:         puts "This message will only be printed once."
// 431:         puts "\n\n"
// 432:
// 433:         # Consider the message possibly missed if not a TTY.
// 434:         Settings.write "installfromapimessage", true if $stdout.tty?
// 435:       end
// 436:     end
// 437:   end
// 438: end
// 439:
// 440: require "extend/os/cmd/update-report"
// 441: require "cmd/update_report/reporter"
// 442: require "cmd/update_report/reporter_hub"
