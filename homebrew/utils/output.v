module utils

import ruby

// Translated from Homebrew/brew `utils/output.rb`.

pub struct OutputOptions {
pub:
	tty            TtyState
	verbose        bool
	debug          bool
	no_emoji       bool
	github_actions bool
}

pub struct OutputFailure {
pub:
	message string
	failed  bool
}

pub struct InstallStatusOptions {
pub:
	installed        bool
	warning          bool
	outdated         bool
	deprecated       bool
	disabled         bool
	mark_uninstalled bool = true
	bold             ?bool
}

pub struct DeprecationOptions {
pub:
	replacement            ?string
	disable                bool
	disable_on             string
	disable_for_developers bool = true
	developer              bool
	raise_exceptions       bool
	auditing               bool
	caller                 []string
	cache_path             string
}

pub fn current_output_options() OutputOptions {
	return OutputOptions{
		tty: current_tty_state()
		no_emoji: ruby.environment_value('HOMEBREW_NO_EMOJI') != ''
		github_actions: ruby.environment_value('GITHUB_ACTIONS') != ''
	}
}

fn output_tty_code(state TtyState, name string) string {
	mut current := state
	current.escape_sequence = state.escape_sequence.clone()
	current.add_code(name) or { return '' }
	return current.str()
}

pub fn output_ohai_title(title string, options OutputOptions) string {
	visible_title := if options.tty.stream_is_tty && !options.verbose {
		tty_truncate(title, tty_width())
	} else {
		title
	}
	return formatter_headline(visible_title, 'blue', options.tty)
}

pub fn output_ohai(title string, sput []string, options OutputOptions) string {
	mut lines := [output_ohai_title(title, options)]
	lines << sput
	return lines.join('\n')
}

pub fn output_debug(title string, sput []string, always_display bool,
	options OutputOptions) string {
	if !options.debug && !always_display {
		return ''
	}
	mut lines := [formatter_headline(title, 'magenta', options.tty)]
	lines << sput
	return lines.join('\n')
}

pub fn output_oh1_title(title string, truncate_auto bool, options OutputOptions) string {
	visible_title := if options.tty.stream_is_tty && !options.verbose && truncate_auto {
		tty_truncate(title, tty_width())
	} else {
		title
	}
	return formatter_headline(visible_title, 'green', options.tty)
}

pub fn output_warning(message string, options OutputOptions) string {
	if options.github_actions {
		return '::warning::${message}'
	}
	return formatter_warning(message, 'Warning', options.tty)
}

pub fn output_warning_without_annotation(message string, options OutputOptions) string {
	return formatter_warning(message, 'Warning', options.tty)
}

pub fn output_warning_outside_github_actions(message string, options OutputOptions) string {
	return if options.github_actions { '' } else { output_warning(message, options) }
}

pub fn output_error(message string, options OutputOptions) string {
	if options.github_actions {
		return '::error::${message}'
	}
	return formatter_error(message, 'Error', options.tty)
}

pub fn output_fail(message string, options OutputOptions) OutputFailure {
	return OutputFailure{
		message: output_error(message, options)
		failed: true
	}
}

pub fn issue_reporting_message(issues_url string, homebrew_issue bool, read_this bool,
	options OutputOptions) string {
	formatted_url := formatter_url(issues_url, options.tty)
	if read_this {
		return formatter_error(formatted_url, 'READ THIS', options.tty)
	}
	if homebrew_issue {
		return '${output_tty_code(options.tty, 'bold')}Please report this issue:${output_tty_code(options.tty, 'reset')}\n  ${formatted_url}\n'
	}
	return 'If reporting this issue please do so at (not Homebrew/* repositories):\n  ${formatted_url}\n'
}

pub fn output_deprecated(method string, options DeprecationOptions,
	output_options OutputOptions) !string {
	replacement_message := if replacement := options.replacement {
		'Use ${replacement} instead.'
	} else {
		'There is no replacement.'
	}
	mut disable := options.disable
	mut verb := 'deprecated'
	if options.disable_on != '' {
		// Dates in the past are disabled by the caller; future dates retain the
		// exact source wording without introducing an implicit clock dependency.
		verb = 'deprecated and will be disabled on ${options.disable_on}'
	}
	if disable {
		verb = 'disabled'
	}
	for line in options.caller {
		if (options.cache_path != '' && line.contains(options.cache_path))
			|| line.contains('/.brew/') || line.contains('/.metadata/') {
			return ''
		}
	}
	mut tap_message := ''
	for line in options.caller {
		marker := '/Taps/'
		if !line.contains(marker) {
			continue
		}
		tap_path := line.all_after(marker)
		parts := tap_path.split('/')
		if parts.len >= 2 {
			tap_name := '${parts[0]}/${parts[1]}'
			tap_message = '\nPlease report this issue to the ${tap_name} tap (not Homebrew/* repositories)'
			if options.replacement != none {
				tap_message += ', or even better, submit a PR to fix it'
			}
			tap_message += ':\n  ${line.all_before(':')}\n\n'
		}
		break
	}
	message := 'Calling ${method} is ${verb}! ${replacement_message}${tap_message}'
	disable = disable || (options.disable_for_developers && options.developer)
	if disable || options.raise_exceptions {
		return error(message)
	}
	return if options.auditing { '' } else { output_warning(message, output_options) }
}

pub fn output_disabled(method string, options DeprecationOptions,
	output_options OutputOptions) !string {
	return output_deprecated(method, DeprecationOptions{
		...options
		disable: true
	}, output_options)
}

pub fn pretty_installed(string_value string, options OutputOptions) string {
	if !options.tty.stream_is_tty {
		return string_value
	}
	bold := output_tty_code(options.tty, 'bold')
	reset := output_tty_code(options.tty, 'reset')
	if options.no_emoji {
		return formatter_success('${bold}${string_value} (installed)${reset}', none, options.tty)
	}
	return '${bold}${string_value} ${formatter_success('✔', none, options.tty)}${reset}'
}

pub fn pretty_upgradable(string_value string, bold_enabled bool, options OutputOptions) string {
	if !options.tty.stream_is_tty {
		return string_value
	}
	weight := if bold_enabled { output_tty_code(options.tty, 'bold') } else { '' }
	reset := output_tty_code(options.tty, 'reset')
	if options.no_emoji {
		return '${weight}${string_value} (upgradable)${reset}'
	}
	return '${weight}${string_value} ${formatter_success('↑', none, options.tty)}${reset}'
}

pub fn pretty_deprecated(string_value string, options OutputOptions) string {
	return if options.tty.stream_is_tty {
		'${string_value} ${formatter_warning('(deprecated)', none, options.tty)}'
	} else {
		string_value
	}
}

pub fn pretty_disabled(string_value string, options OutputOptions) string {
	return if options.tty.stream_is_tty {
		'${string_value} ${formatter_error('(disabled)', none, options.tty)}'
	} else {
		string_value
	}
}

pub fn pretty_uninstalled(string_value string, bold_enabled bool, options OutputOptions) string {
	if !options.tty.stream_is_tty {
		return string_value
	}
	weight := if bold_enabled { output_tty_code(options.tty, 'bold') } else { '' }
	reset := output_tty_code(options.tty, 'reset')
	if options.no_emoji {
		return formatter_error('${weight}${string_value} (uninstalled)${reset}', none, options.tty)
	}
	return '${weight}${string_value} ${formatter_error('✘', none, options.tty)}${reset}'
}

pub fn pretty_unmarked(string_value string, bold_enabled bool, options OutputOptions) string {
	if bold_enabled && options.tty.stream_is_tty {
		return '${output_tty_code(options.tty, 'bold')}${string_value}${output_tty_code(options.tty, 'reset')}'
	}
	return string_value
}

pub fn pretty_warning_status(string_value string, bold_enabled bool,
	options OutputOptions) string {
	if !options.tty.stream_is_tty {
		return string_value
	}
	weight := if bold_enabled { output_tty_code(options.tty, 'bold') } else { '' }
	reset := output_tty_code(options.tty, 'reset')
	if options.no_emoji {
		return formatter_warning('${weight}${string_value} (warning)${reset}', none, options.tty)
	}
	return '${weight}${string_value} ${formatter_warning('⚠', none, options.tty)}${reset}'
}

pub fn pretty_install_status(string_value string, status InstallStatusOptions,
	options OutputOptions) string {
	bold_enabled := status.bold or { status.installed }
	mut result := if status.warning {
		pretty_warning_status(string_value, bold_enabled, options)
	} else if status.installed && status.outdated {
		pretty_upgradable(string_value, bold_enabled, options)
	} else if status.installed {
		pretty_installed(string_value, options)
	} else if status.mark_uninstalled {
		pretty_uninstalled(string_value, bold_enabled, options)
	} else {
		pretty_unmarked(string_value, bold_enabled, options)
	}
	if status.disabled {
		result = pretty_disabled(result, options)
	} else if status.deprecated {
		result = pretty_deprecated(result, options)
	}
	return result
}

fn pluralized(unit string, count int) string {
	return '${count} ${unit}${if count == 1 {
		''
	} else {
		's'
	}}'
}

pub fn pretty_duration(seconds_value f64) string {
	mut seconds := int(seconds_value)
	hide_seconds := seconds > 300
	minutes_total := seconds / 60
	seconds %= 60
	hours := minutes_total / 60
	minutes := minutes_total % 60
	if hours > 0 {
		mut result := pluralized('hour', hours)
		if minutes > 0 {
			result += ' ' + pluralized('minute', minutes)
		}
		return result
	}
	if minutes > 0 {
		mut result := pluralized('minute', minutes)
		if !hide_seconds && seconds > 0 {
			result += ' ' + pluralized('second', seconds)
		}
		return result
	}
	return pluralized('second', seconds)
}
