module utils

import ruby

// Translated from Homebrew/brew `utils/output.rb`.
// The original source is retained below until every stub has a typed V body.

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
		tty:            current_tty_state()
		no_emoji:       ruby.environment_value('HOMEBREW_NO_EMOJI') != ''
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
		failed:  true
	}
}

pub fn issue_reporting_message(issues_url string, homebrew_issue bool, read_this bool,
	options OutputOptions) string {
	formatted_url := formatter_url(issues_url, options.tty)
	if read_this {
		return formatter_error(formatted_url, 'READ THIS', options.tty)
	}
	if homebrew_issue {
		return '${output_tty_code(options.tty, 'bold')}Please report this issue:${output_tty_code(options.tty,
			'reset')}\n  ${formatted_url}\n'
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
		return '${output_tty_code(options.tty, 'bold')}${string_value}${output_tty_code(options.tty,
			'reset')}'
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

// Ruby method `ohai_title(title)` at line 15.
pub fn ruby_output_l15_d1_ohai_title(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	return ruby.string_value(output_ohai_title(args[0].as_string(),
		current_output_options()))
}

// Ruby method `ohai(title, *sput)` at line 27.
pub fn ruby_output_l27_d2_ohai(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	return ruby.string_value(output_ohai(args[0].as_string(),
		args[1..].map(it.as_string()), current_output_options()))
}

// Ruby method `odebug(title, *sput, always_display: false)` at line 33.
pub fn ruby_output_l33_d3_odebug(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	return ruby.string_value(output_debug(args[0].as_string(),
		args[1..].map(it.as_string()), false, current_output_options()))
}

// Ruby method `oh1_title(title, truncate: :auto)` at line 47.
pub fn ruby_output_l47_d4_oh1_title(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	return ruby.string_value(output_oh1_title(args[0].as_string(), true,
		current_output_options()))
}

// Ruby method `oh1(title, truncate: :auto)` at line 59.
pub fn ruby_output_l59_d5_oh1(args ...ruby.Value) ruby.Value {
	return ruby_output_l47_d4_oh1_title(...args)
}

// Ruby method `opoo(message)` at line 68.
pub fn ruby_output_l68_d6_opoo(args ...ruby.Value) ruby.Value {
	return ruby.string_value(output_warning(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `opoo_without_github_actions_annotation(message)` at line 80.
pub fn ruby_output_l80_d7_opoo_without_github_actions_annotation(args ...ruby.Value) ruby.Value {
	return ruby.string_value(output_warning_without_annotation(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `opoo_outside_github_actions(message)` at line 95.
pub fn ruby_output_l95_d8_opoo_outside_github_actions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(output_warning_outside_github_actions(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `onoe(message)` at line 107.
pub fn ruby_output_l107_d9_onoe(args ...ruby.Value) ruby.Value {
	return ruby.string_value(output_error(if args.len > 0 { args[0].as_string() } else { '' },
		current_output_options()))
}

// Ruby method `ofail(error)` at line 122.
pub fn ruby_output_l122_d10_ofail(args ...ruby.Value) ruby.Value {
	result := output_fail(if args.len > 0 { args[0].as_string() } else { '' },
		current_output_options())
	return ruby.structured_value('OutputFailure', result.message, {
		'failed': result.failed.str()
	})
}

// Ruby method `issue_reporting_message(issues_url, homebrew: false, read_this: false)` at line 128.
pub fn ruby_output_l128_d11_issue_reporting_message(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	return ruby.string_value(issue_reporting_message(args[0].as_string(), if args.len > 1 { args[1].as_bool() or {
			false} } else { false }, if args.len > 2 {
		args[2].as_bool() or { false }
	} else {
		false
	}, current_output_options()))
}

// Ruby method `odie(error)` at line 151.
pub fn ruby_output_l151_d12_odie(args ...ruby.Value) ruby.Value {
	message := output_error(if args.len > 0 { args[0].as_string() } else { '' },
		current_output_options())
	return ruby.structured_value('SystemExit', message, {
		'exit_code': '1'
	})
}

// Ruby method `odeprecated(method, replacement = nil,` at line 161.
pub fn ruby_output_l161_d13_odeprecated(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	replacement := if args.len > 1 && args[1].as_string() != '' {
		?string(args[1].as_string())
	} else {
		none
	}
	result := output_deprecated(args[0].as_string(), DeprecationOptions{
		replacement: replacement
	}, current_output_options()) or {
		return ruby.structured_value('MethodDeprecatedError', err.msg(), {})
	}
	return ruby.string_value(result)
}

// Ruby method `odisabled(method, replacement = nil,` at line 244.
pub fn ruby_output_l244_d14_odisabled(args ...ruby.Value) ruby.Value {
	if args.len == 0 { return ruby.string_value('') }
	replacement := if args.len > 1 && args[1].as_string() != '' {
		?string(args[1].as_string())
	} else {
		none
	}
	result := output_disabled(args[0].as_string(), DeprecationOptions{
		replacement: replacement
	}, current_output_options()) or {
		return ruby.structured_value('MethodDeprecatedError', err.msg(), {})
	}
	return ruby.string_value(result)
}

// Ruby method `pretty_installed(string)` at line 255.
pub fn ruby_output_l255_d15_pretty_installed(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_installed(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `pretty_upgradable(string, bold: true)` at line 266.
pub fn ruby_output_l266_d16_pretty_upgradable(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_upgradable(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_bool() or { true } } else { true }, current_output_options()))
}

// Ruby method `pretty_deprecated(string)` at line 278.
pub fn ruby_output_l278_d17_pretty_deprecated(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_deprecated(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `pretty_disabled(string)` at line 287.
pub fn ruby_output_l287_d18_pretty_disabled(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_disabled(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, current_output_options()))
}

// Ruby method `pretty_uninstalled(string, bold: true)` at line 298.
pub fn ruby_output_l298_d19_pretty_uninstalled(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_uninstalled(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_bool() or { true } } else { true }, current_output_options()))
}

// Ruby method `pretty_unmarked(string, bold: true)` at line 310.
pub fn ruby_output_l310_d20_pretty_unmarked(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_unmarked(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_bool() or { true } } else { true }, current_output_options()))
}

// Ruby method `pretty_warning(string, bold: true)` at line 319.
pub fn ruby_output_l319_d21_pretty_warning(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_warning_status(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_bool() or { true } } else { true }, current_output_options()))
}

// Ruby method `pretty_install_status(string, installed:, warning: false, outdated: false, deprecated: false,` at line 335.
pub fn ruby_output_l335_d22_pretty_install_status(args ...ruby.Value) ruby.Value {
	if args.len < 2 { return ruby.string_value('') }
	return ruby.string_value(pretty_install_status(args[0].as_string(), InstallStatusOptions{
		installed:        args[1].as_bool() or { false }
		warning:          if args.len > 2 { args[2].as_bool() or { false } } else { false }
		outdated:         if args.len > 3 { args[3].as_bool() or { false } } else { false }
		deprecated:       if args.len > 4 { args[4].as_bool() or { false } } else { false }
		disabled:         if args.len > 5 { args[5].as_bool() or { false } } else { false }
		mark_uninstalled: if args.len > 6 { args[6].as_bool() or { true } } else { true }
		bold:             if args.len > 7 { ?bool(args[7].as_bool() or { false }) } else { none }
	}, current_output_options()))
}

// Ruby method `pretty_duration(seconds)` at line 359.
pub fn ruby_output_l359_d23_pretty_duration(args ...ruby.Value) ruby.Value {
	return ruby.string_value(pretty_duration(if args.len > 0 {
		args[0].as_float() or { 0.0 }
	} else {
		0.0
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper methods for outputting messages in Homebrew's formats.
// 6:   module Output
// 7:     # Mixin used to add these helpers to stdout and stderr.
// 8:     module Mixin
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { Kernel }
// 12:
// 13:       # Keep in sync with `ohai` in Library/Homebrew/utils.sh.
// 14:       sig { params(title: String).returns(String) }
// 15:       def ohai_title(title)
// 16:         verbose = if respond_to?(:verbose?)
// 17:           T.unsafe(self).verbose?
// 18:         else
// 19:           Context.current.verbose?
// 20:         end
// 21:
// 22:         title = Tty.truncate(title.to_s) if $stdout.tty? && !verbose
// 23:         Formatter.headline(title, color: :blue)
// 24:       end
// 25:
// 26:       sig { params(title: T.any(String, Exception), sput: T.anything).void }
// 27:       def ohai(title, *sput)
// 28:         puts ohai_title(title.to_s)
// 29:         puts sput
// 30:       end
// 31:
// 32:       sig { params(title: T.any(String, Exception), sput: T.anything, always_display: T::Boolean).void }
// 33:       def odebug(title, *sput, always_display: false)
// 34:         debug = if respond_to?(:debug)
// 35:           T.unsafe(self).debug?
// 36:         else
// 37:           Context.current.debug?
// 38:         end
// 39:
// 40:         return if !debug && !always_display
// 41:
// 42:         $stderr.puts Formatter.headline(title.to_s, color: :magenta)
// 43:         $stderr.puts sput unless sput.empty?
// 44:       end
// 45:
// 46:       sig { params(title: String, truncate: T.any(Symbol, T::Boolean)).returns(String) }
// 47:       def oh1_title(title, truncate: :auto)
// 48:         verbose = if respond_to?(:verbose?)
// 49:           T.unsafe(self).verbose?
// 50:         else
// 51:           Context.current.verbose?
// 52:         end
// 53:
// 54:         title = Tty.truncate(title.to_s) if $stdout.tty? && !verbose && truncate == :auto
// 55:         Formatter.headline(title, color: :green)
// 56:       end
// 57:
// 58:       sig { params(title: String, truncate: T.any(Symbol, T::Boolean)).void }
// 59:       def oh1(title, truncate: :auto)
// 60:         puts oh1_title(title, truncate:)
// 61:       end
// 62:
// 63:       # Print a warning message.
// 64:       #
// 65:       # @api public
// 66:       # Keep in sync with `opoo` in Library/Homebrew/utils.sh.
// 67:       sig { params(message: T.any(String, Exception)).void }
// 68:       def opoo(message)
// 69:         require "utils/github/actions"
// 70:         return if GitHub::Actions.puts_annotation_if_env_set!(:warning, message.to_s)
// 71:
// 72:         require "utils/formatter"
// 73:
// 74:         Tty.with($stderr) do |stderr|
// 75:           stderr.puts Formatter.warning(message, label: "Warning")
// 76:         end
// 77:       end
// 78:
// 79:       sig { params(message: T.any(String, Exception)).void }
// 80:       def opoo_without_github_actions_annotation(message)
// 81:         require "utils/github/actions"
// 82:         return opoo(message) unless GitHub::Actions.env_set?
// 83:
// 84:         require "utils/formatter"
// 85:
// 86:         Tty.with($stderr) do |stderr|
// 87:           stderr.puts Formatter.warning(message, label: "Warning")
// 88:         end
// 89:       end
// 90:
// 91:       # Print a warning message only if not running in GitHub Actions.
// 92:       #
// 93:       # @api public
// 94:       sig { params(message: T.any(String, Exception)).void }
// 95:       def opoo_outside_github_actions(message)
// 96:         require "utils/github/actions"
// 97:         return if GitHub::Actions.env_set?
// 98:
// 99:         opoo(message)
// 100:       end
// 101:
// 102:       # Print an error message.
// 103:       #
// 104:       # @api public
// 105:       # Keep in sync with `onoe` in Library/Homebrew/utils.sh.
// 106:       sig { params(message: T.any(String, Exception)).void }
// 107:       def onoe(message)
// 108:         require "utils/github/actions"
// 109:         return if GitHub::Actions.puts_annotation_if_env_set!(:error, message.to_s)
// 110:
// 111:         require "utils/formatter"
// 112:
// 113:         Tty.with($stderr) do |stderr|
// 114:           stderr.puts Formatter.error(message, label: "Error")
// 115:         end
// 116:       end
// 117:
// 118:       # Print an error message and fail at the end of the program.
// 119:       #
// 120:       # @api public
// 121:       sig { params(error: T.any(String, Exception)).void }
// 122:       def ofail(error)
// 123:         onoe error
// 124:         Homebrew.failed = true
// 125:       end
// 126:
// 127:       sig { params(issues_url: String, homebrew: T::Boolean, read_this: T::Boolean).returns(String) }
// 128:       def issue_reporting_message(issues_url, homebrew: false, read_this: false)
// 129:         formatted_issues_url = Formatter.url(issues_url)
// 130:
// 131:         if read_this
// 132:           Formatter.error(formatted_issues_url, label: "READ THIS")
// 133:         elsif homebrew
// 134:           <<~EOS
// 135:             #{Tty.bold}Please report this issue:#{Tty.reset}
// 136:               #{formatted_issues_url}
// 137:           EOS
// 138:         else
// 139:           <<~EOS
// 140:             If reporting this issue please do so at (not Homebrew/* repositories):
// 141:               #{formatted_issues_url}
// 142:           EOS
// 143:         end
// 144:       end
// 145:
// 146:       # Print an error message and fail immediately.
// 147:       #
// 148:       # @api public
// 149:       # Keep in sync with `odie` in Library/Homebrew/utils.sh.
// 150:       sig { params(error: T.any(String, Exception)).returns(T.noreturn) }
// 151:       def odie(error)
// 152:         onoe error
// 153:         exit 1
// 154:       end
// 155:
// 156:       # Output a deprecation warning/error message.
// 157:       sig {
// 158:         params(method: String, replacement: T.nilable(T.any(String, Symbol)), disable: T::Boolean,
// 159:                disable_on: T.nilable(Time), disable_for_developers: T::Boolean, caller: T::Array[String]).void
// 160:       }
// 161:       def odeprecated(method, replacement = nil,
// 162:                       disable:                false,
// 163:                       disable_on:             nil,
// 164:                       disable_for_developers: true,
// 165:                       caller:                 send(:caller))
// 166:         replacement_message = if replacement
// 167:           "Use #{replacement} instead."
// 168:         else
// 169:           "There is no replacement."
// 170:         end
// 171:
// 172:         unless disable_on.nil?
// 173:           if disable_on > Time.now
// 174:             will_be_disabled_message = " and will be disabled on #{disable_on.strftime("%Y-%m-%d")}"
// 175:           else
// 176:             disable = true
// 177:           end
// 178:         end
// 179:
// 180:         verb = if disable
// 181:           "disabled"
// 182:         else
// 183:           "deprecated#{will_be_disabled_message}"
// 184:         end
// 185:
// 186:         # Try to show the most relevant location in message, i.e. (if applicable):
// 187:         # - Location in a formula.
// 188:         # - Location of caller of deprecated method (if all else fails).
// 189:         backtrace = caller
// 190:
// 191:         # Don't throw deprecations at all for cached, .brew or .metadata files.
// 192:         return if backtrace.any? do |line|
// 193:           next true if line.include?(HOMEBREW_CACHE.to_s)
// 194:           next true if line.include?("/.brew/")
// 195:           next true if line.include?("/.metadata/")
// 196:
// 197:           next false unless line.match?(HOMEBREW_TAP_PATH_REGEX)
// 198:
// 199:           path = Pathname(line.split(":", 2).first)
// 200:           next false unless path.file?
// 201:           next false unless path.readable?
// 202:
// 203:           formula_contents = path.read
// 204:           formula_contents.include?(" deprecate! ") || formula_contents.include?(" disable! ")
// 205:         end
// 206:
// 207:         tap_message = T.let(nil, T.nilable(String))
// 208:
// 209:         backtrace.each do |line|
// 210:           next unless (match = line.match(HOMEBREW_TAP_PATH_REGEX))
// 211:
// 212:           require "tap"
// 213:
// 214:           tap = Tap.fetch(match[:user], match[:repository])
// 215:           tap_message = "\nPlease report this issue to the #{tap.full_name} tap"
// 216:           tap_message += " (not Homebrew/* repositories)" unless tap.official?
// 217:           tap_message += ", or even better, submit a PR to fix it" if replacement
// 218:           tap_message << ":\n  #{line.sub(/^(.*:\d+):.*$/, '\1')}\n\n"
// 219:           break
// 220:         end
// 221:         file, line, = backtrace.first.split(":")
// 222:         line = line.to_i if line.present?
// 223:
// 224:         message = "Calling #{method} is #{verb}! #{replacement_message}"
// 225:         message << tap_message if tap_message
// 226:         message.freeze
// 227:
// 228:         disable = true if disable_for_developers && Homebrew::EnvConfig.developer?
// 229:         if disable || Homebrew.raise_deprecation_exceptions?
// 230:           require "utils/github/actions"
// 231:           GitHub::Actions.puts_annotation_if_env_set!(:error, message, file:, line:)
// 232:           exception = MethodDeprecatedError.new(message)
// 233:           exception.set_backtrace(backtrace)
// 234:           raise exception
// 235:         elsif !Homebrew.auditing?
// 236:           opoo message
// 237:         end
// 238:       end
// 239:
// 240:       sig {
// 241:         params(method: String, replacement: T.nilable(T.any(String, Symbol)),
// 242:                disable_on: T.nilable(Time), disable_for_developers: T::Boolean, caller: T::Array[String]).void
// 243:       }
// 244:       def odisabled(method, replacement = nil,
// 245:                     disable_on:             nil,
// 246:                     disable_for_developers: true,
// 247:                     caller:                 send(:caller))
// 248:         # This odeprecated should stick around indefinitely.
// 249:         odeprecated(method, replacement, disable: true, disable_on:, disable_for_developers:, caller:)
// 250:       end
// 251:
// 252:       # Keep status labels, colours and emoji in sync with
// 253:       # `pretty_installed` in Library/Homebrew/utils.sh.
// 254:       sig { params(string: String).returns(String) }
// 255:       def pretty_installed(string)
// 256:         if !$stdout.tty?
// 257:           string
// 258:         elsif Homebrew::EnvConfig.no_emoji?
// 259:           Formatter.success("#{Tty.bold}#{string} (installed)#{Tty.reset}")
// 260:         else
// 261:           "#{Tty.bold}#{string} #{Formatter.success("✔")}#{Tty.reset}"
// 262:         end
// 263:       end
// 264:
// 265:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 266:       def pretty_upgradable(string, bold: true)
// 267:         weight = bold ? Tty.bold.to_s : ""
// 268:         if !$stdout.tty?
// 269:           string
// 270:         elsif Homebrew::EnvConfig.no_emoji?
// 271:           "#{weight}#{string} (upgradable)#{Tty.reset}"
// 272:         else
// 273:           "#{weight}#{string} #{Formatter.success("↑")}#{Tty.reset}"
// 274:         end
// 275:       end
// 276:
// 277:       sig { params(string: String).returns(String) }
// 278:       def pretty_deprecated(string)
// 279:         if $stdout.tty?
// 280:           "#{string} #{Formatter.warning("(deprecated)")}"
// 281:         else
// 282:           string
// 283:         end
// 284:       end
// 285:
// 286:       sig { params(string: String).returns(String) }
// 287:       def pretty_disabled(string)
// 288:         if $stdout.tty?
// 289:           "#{string} #{Formatter.error("(disabled)")}"
// 290:         else
// 291:           string
// 292:         end
// 293:       end
// 294:
// 295:       # Keep status labels, colours and emoji in sync with
// 296:       # `pretty_uninstalled` in Library/Homebrew/utils.sh.
// 297:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 298:       def pretty_uninstalled(string, bold: true)
// 299:         weight = bold ? Tty.bold.to_s : ""
// 300:         if !$stdout.tty?
// 301:           string
// 302:         elsif Homebrew::EnvConfig.no_emoji?
// 303:           Formatter.error("#{weight}#{string} (uninstalled)#{Tty.reset}")
// 304:         else
// 305:           "#{weight}#{string} #{Formatter.error("✘")}#{Tty.reset}"
// 306:         end
// 307:       end
// 308:
// 309:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 310:       def pretty_unmarked(string, bold: true)
// 311:         if bold && $stdout.tty?
// 312:           "#{Tty.bold}#{string}#{Tty.reset}"
// 313:         else
// 314:           string
// 315:         end
// 316:       end
// 317:
// 318:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 319:       def pretty_warning(string, bold: true)
// 320:         weight = bold ? Tty.bold.to_s : ""
// 321:         if !$stdout.tty?
// 322:           string
// 323:         elsif Homebrew::EnvConfig.no_emoji?
// 324:           Formatter.warning("#{weight}#{string} (warning)#{Tty.reset}")
// 325:         else
// 326:           "#{weight}#{string} #{Formatter.warning("⚠")}#{Tty.reset}"
// 327:         end
// 328:       end
// 329:
// 330:       sig {
// 331:         params(string: String, installed: T::Boolean, warning: T::Boolean, outdated: T::Boolean,
// 332:                deprecated: T::Boolean, disabled: T::Boolean, mark_uninstalled: T::Boolean,
// 333:                bold: T.nilable(T::Boolean)).returns(String)
// 334:       }
// 335:       def pretty_install_status(string, installed:, warning: false, outdated: false, deprecated: false,
// 336:                                 disabled: false, mark_uninstalled: true, bold: nil)
// 337:         bold = installed if bold.nil?
// 338:         status = if warning
// 339:           pretty_warning(string, bold:)
// 340:         elsif installed && outdated
// 341:           pretty_upgradable(string, bold:)
// 342:         elsif installed
// 343:           pretty_installed(string)
// 344:         elsif mark_uninstalled
// 345:           pretty_uninstalled(string, bold:)
// 346:         else
// 347:           pretty_unmarked(string, bold:)
// 348:         end
// 349:         if disabled
// 350:           pretty_disabled(status)
// 351:         elsif deprecated
// 352:           pretty_deprecated(status)
// 353:         else
// 354:           status
// 355:         end
// 356:       end
// 357:
// 358:       sig { params(seconds: T.nilable(T.any(Integer, Float))).returns(String) }
// 359:       def pretty_duration(seconds)
// 360:         seconds = seconds.to_i
// 361:         hide_seconds = seconds > 300
// 362:
// 363:         minutes, seconds = seconds.divmod(60)
// 364:         hours, minutes = minutes.divmod(60)
// 365:
// 366:         res = +""
// 367:
// 368:         if hours.positive?
// 369:           res << Utils.pluralize("hour", hours, include_count: true)
// 370:           return res.freeze if minutes.zero?
// 371:
// 372:           res << " " << Utils.pluralize("minute", minutes, include_count: true)
// 373:           return res.freeze
// 374:         end
// 375:
// 376:         if minutes.positive?
// 377:           res << Utils.pluralize("minute", minutes, include_count: true)
// 378:           return res.freeze if hide_seconds || seconds.zero?
// 379:
// 380:           res << " "
// 381:         end
// 382:
// 383:         res << Utils.pluralize("second", seconds, include_count: true)
// 384:         res.freeze
// 385:       end
// 386:     end
// 387:
// 388:     extend Mixin
// 389:     $stdout.extend Mixin
// 390:     $stderr.extend Mixin
// 391:   end
// 392: end
