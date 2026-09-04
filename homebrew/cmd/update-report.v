module cmd

import ruby
import homebrew.cmd.update_report
import os

// Translated from Homebrew/brew `cmd/update-report.rb`.
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
	result := ruby.run_command('git', ['-C', repository, 'rev-parse', '--short', revision])
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

fn update_report_result_value(result UpdateReportResult) ruby.Value {
	return ruby.map_value({
		'stdout':       ruby.string_value(result.stdout)
		'stderr':       ruby.string_value(result.stderr)
		'actions':      ruby.string_array_value(result.actions)
		'warnings':     ruby.string_array_value(result.warnings)
		'updated':      ruby.bool_value(result.updated)
		'updated_taps': ruby.string_array_value(result.updated_taps)
		'new_tag':      ruby.string_value(result.new_tag)
		'prewarm':      ruby.bool_value(result.prewarm)
	})
}

fn update_report_context_from_value(value ruby.Value) UpdateReportContext {
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
