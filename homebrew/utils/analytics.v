module utils

import homebrew.api
import os

// Translated from Homebrew/brew `utils/analytics.rb`.
// The original source is retained below until every stub has a typed V body.
pub const analytics_influx_bucket = 'analytics'
pub const analytics_influx_token = 'iVdsgJ_OjvTYGAA79gOfWlA_fX0QCuj4eYUNdb-qVUTrC3tp3JTWCADVNE9HxV0kp2ZjIK9tuthy_teX4szr9A=='
pub const analytics_influx_host = 'https://eu-central-1-1.aws.cloud2.influxdata.com'
pub const analytics_influx_org = 'd81a3e6d582d485f'
pub const analytics_wsl_suffix = ' [WSL]'
pub const analytics_env_config_commands = ['config', 'fetch', 'install', 'reinstall', 'update',
	'update-report', 'upgrade']

pub struct AnalyticsState {
pub mut:
	settings              map[string]string
	no_analytics          bool
	no_analytics_this_run bool
	no_message_output     bool
	analytics_debug       bool
	test_bot_analytics    bool
	default_prefix        bool
	prefix                string
	ci                    bool
	developer             bool
	devcmdrun             bool
	arch                  string
	os_name               string
	wsl                   bool
	homebrew_version      string
	os_version            string
	now_unix              i64
	curl_executable       string = 'curl'
	formula_api_enabled   bool = true
	cask_api_enabled      bool = true
	github_api_enabled    bool = true
}

pub struct AnalyticsCurlPlan {
pub:
	executable string
	url        string
	args       []string
	debug      bool
	detached   bool
}

pub struct AnalyticsPackageEvent {
pub:
	measurement  string
	package_name string
	tap_name     string
	on_request   bool
	options      string
}

pub struct AnalyticsBuildError {
pub:
	has_formula       bool
	formula_name      string
	has_tap           bool
	tap_name          string
	tap_should_report bool
	options           []string
}

pub struct AnalyticsEnvironmentSample {
pub:
	name        string
	user_set    bool
	non_default bool
}

pub struct AnalyticsCommandRun {
pub:
	command            string
	options            []string
	environment_sample ?AnalyticsEnvironmentSample
}

pub struct AnalyticsOutputArgs {
pub:
	days                      string
	category                  string
	filter                    string
	analytics                 bool
	verbose                   bool
	github_packages_downloads bool
	tty_width                 int = 80
}

pub struct AnalyticsPeriod {
pub:
	days    int
	results map[string]i64
}

pub struct AnalyticsCategory {
pub:
	name    string
	periods []AnalyticsPeriod
}

pub struct AnalyticsGithubVersion {
pub:
	success   bool
	downloads string
}

pub struct AnalyticsFormulaOutput {
pub:
	name            string
	core_formula    bool
	known_to_api    bool
	categories      []AnalyticsCategory
	github_index_ok bool
	github_versions []AnalyticsGithubVersion
}

pub struct AnalyticsCaskOutput {
pub:
	token        string
	known_to_api bool
	categories   []AnalyticsCategory
}

pub fn (state &AnalyticsState) config_true(key string) bool {
	return state.settings[key] or { '' } == 'true'
}

pub fn (state &AnalyticsState) influx_message_displayed() bool {
	return state.config_true('influxanalyticsmessage')
}

pub fn (state &AnalyticsState) messages_displayed() bool {
	return state.config_true('analyticsmessage') && state.config_true('caskanalyticsmessage') && state.influx_message_displayed()
}

pub fn (state &AnalyticsState) disabled() bool {
	return state.no_analytics || state.config_true('analyticsdisabled')
}

pub fn (state &AnalyticsState) not_this_run() bool {
	return state.no_analytics_this_run
}

pub fn (state &AnalyticsState) no_message_output_enabled() bool {
	return state.no_message_output
}

pub fn (mut state AnalyticsState) messages_displayed_set() {
	state.settings['analyticsmessage'] = 'true'
	state.settings['caskanalyticsmessage'] = 'true'
	state.settings['influxanalyticsmessage'] = 'true'
}

pub fn (mut state AnalyticsState) delete_uuid() {
	state.settings.delete('analyticsuuid')
}

pub fn (mut state AnalyticsState) enable() {
	state.settings['analyticsdisabled'] = 'false'
	state.delete_uuid()
	state.messages_displayed_set()
}

pub fn (mut state AnalyticsState) disable() {
	state.settings['analyticsdisabled'] = 'true'
	state.delete_uuid()
}

pub fn analytics_with_wsl_suffix(value string, wsl bool) string {
	if !wsl || value.ends_with(analytics_wsl_suffix) {
		return value
	}
	return '${value}${analytics_wsl_suffix}'
}

pub fn analytics_default_package_tags(state AnalyticsState) map[string]string {
	prefix := if state.default_prefix { state.prefix } else { 'custom-prefix' }
	return {
		'ci':             state.ci.str()
		'prefix':         prefix
		'default_prefix': state.default_prefix.str()
		'developer':      state.developer.str()
		'devcmdrun':      state.devcmdrun.str()
		'arch':           state.arch
		'os':             analytics_with_wsl_suffix(state.os_name, state.wsl)
	}
}

fn analytics_version_field(version string) string {
	mut end := 0
	for end < version.len && (version[end].is_digit() || version[end] == `.`) {
		end++
	}
	if end == 0 {
		return '>=4.1.22'
	}
	return version[..end] + if version.contains('-') { '-dev' } else { '' }
}

pub fn analytics_default_package_fields(state AnalyticsState) map[string]string {
	mut fields := {
		'version': analytics_version_field(state.homebrew_version)
	}
	if state.os_version != '' && state.os_version[0].is_letter() {
		fields['os_name_and_version'] = analytics_with_wsl_suffix(state.os_version, state.wsl)
	}
	return fields
}

fn analytics_escape_tag(value string) string {
	return value.replace(' ', '\\ ').replace(',', '\\,').replace('=', '\\=')
}

pub fn analytics_deferred_curl(state AnalyticsState, url string, args []string) AnalyticsCurlPlan {
	mut curl_args := args.clone()
	curl_args << ['--silent', '--output', os.path_devnull]
	return AnalyticsCurlPlan{
		executable: state.curl_executable
		url: url
		args: curl_args
		debug: state.analytics_debug
		detached: !state.analytics_debug
	}
}

pub fn analytics_report_influx(state AnalyticsState, measurement string, tags map[string]string,
	fields map[string]string) ?AnalyticsCurlPlan {
	if state.not_this_run() || state.disabled() {
		return none
	}
	mut tag_parts := []string{cap: tags.len}
	for key, value in tags {
		tag_parts << '${key}=${analytics_escape_tag(value)}'
	}
	mut field_parts := []string{cap: fields.len}
	for key, value in fields {
		field_parts << '${key}="${value}"'
	}
	args := ['--max-time', '3', '--header', 'Authorization: Token ${analytics_influx_token}',
		'--header', 'Content-Type: text/plain; charset=utf-8', '--header', 'Accept: application/json',
		'--data-binary',
		'${measurement},${tag_parts.join(',')} ${field_parts.join(',')} ${state.now_unix}']
	url := '${analytics_influx_host}/api/v2/write?bucket=${analytics_influx_bucket}&precision=s'
	return analytics_deferred_curl(state, url, args)
}

pub fn analytics_report_package_event(state AnalyticsState,
	event AnalyticsPackageEvent) ?AnalyticsCurlPlan {
	if state.not_this_run() || state.disabled() {
		return none
	}
	mut tags := analytics_default_package_tags(state)
	tags['on_request'] = event.on_request.str()
	mut fields := analytics_default_package_fields(state)
	fields['package'] = event.package_name
	fields['tap_name'] = event.tap_name
	if event.options.trim_space() != '' {
		fields['options'] = event.options
	}
	return analytics_report_influx(state, event.measurement, tags, fields)
}

fn analytics_sorted_unique(values []string) []string {
	mut result := values.clone()
	result.sort()
	mut unique := []string{}
	for value in result {
		if unique.len == 0 || unique.last() != value {
			unique << value
		}
	}
	return unique
}

pub fn analytics_report_build_error(state AnalyticsState,
	build_error AnalyticsBuildError) ?AnalyticsCurlPlan {
	if state.not_this_run() || state.disabled() || !build_error.has_formula || !build_error.has_tap || !build_error.tap_should_report {
		return none
	}
	options := analytics_sorted_unique(build_error.options.filter(it != '')).join(' ')
	return analytics_report_package_event(state, AnalyticsPackageEvent{
		measurement: 'build_error'
		package_name: build_error.formula_name
		tap_name: build_error.tap_name
		options: options
	})
}

fn analytics_sanitized_options(options []string) string {
	mut sanitized := []string{}
	for option in options {
		mut value := option
		if equals := value.index('=') {
			value = value[..equals + 1]
		}
		if value.starts_with('--with-') || value.starts_with('--without-') {
			continue
		}
		sanitized << value
	}
	return analytics_sorted_unique(sanitized).join(' ')
}

pub fn analytics_report_command_run(state AnalyticsState,
	command AnalyticsCommandRun) ?AnalyticsCurlPlan {
	if state.not_this_run() || state.disabled() {
		return none
	}
	mut tags := {
		'command':   command.command
		'ci':        state.ci.str()
		'devcmdrun': state.devcmdrun.str()
		'developer': state.developer.str()
	}
	if command.command in analytics_env_config_commands {
		if sample := command.environment_sample {
			tags['env_config'] = sample.name
			tags['env_config_state'] = if !sample.user_set {
				'unset'
			} else if sample.non_default {
				'non_default'
			} else {
				'default'
			}
		}
	}
	return analytics_report_influx(state, 'command_run', tags, {
		'options': analytics_sanitized_options(command.options)
	})
}

pub fn analytics_report_test_bot_test(state AnalyticsState, step_command_short string,
	passed bool) ?AnalyticsCurlPlan {
	if state.not_this_run() || state.disabled() || !state.test_bot_analytics {
		return none
	}
	mut command_and_package := []string{}
	mut options := []string{}
	for argument in step_command_short.fields() {
		value := if equals := argument.index('=') { argument[..equals + 1] } else { argument }
		if value.starts_with('-') {
			options << value
		} else {
			command_and_package << value
		}
	}
	options.sort()
	command_and_package << options
	return analytics_report_influx(state, 'test_bot_test', {
		'passed': passed.str()
		'arch':   state.arch
		'os':     state.os_name
	}, {
		'command': command_and_package.join(' ')
	})
}

pub fn analytics_format_count(count i64) string {
	return formatter_number_readable(count)
}

pub fn analytics_format_percent(percent f64) string {
	return '${percent:.2f}'
}

fn analytics_truncate(value string, width int) string {
	if width <= 0 {
		return ''
	}
	return if value.len <= width { value } else { value[..width] }
}

fn analytics_max(first int, second int) int {
	return if first > second { first } else { second }
}

fn analytics_pad_left(value string, width int, padding string) string {
	return if value.len >= width { value } else { padding.repeat(width - value.len) + value }
}

fn analytics_pad_right(value string, width int, padding string) string {
	return if value.len >= width { value } else { value + padding.repeat(width - value.len) }
}

pub fn analytics_table_output(category string, days string, results map[string]i64,
	os_version bool, cask_install bool, tty_width int) string {
	mut total_count := i64(0)
	for _, count in results {
		total_count += count
	}
	formatted_total_count := analytics_format_count(total_count)
	formatted_total_percent := analytics_format_percent(100.0)
	index_header := 'Index'
	count_header := 'Count'
	percent_header := 'Percent'
	name_header := if os_version {
		'macOS Version'
	} else if cask_install {
		'Token'
	} else {
		'Name (with options)'
	}
	max_index_width := results.len.str().len
	index_width := analytics_max(index_header.len, analytics_max('Total'.len, max_index_width))
	count_width := analytics_max(count_header.len, formatted_total_count.len)
	percent_width := analytics_max(percent_header.len, formatted_total_percent.len)
	name_width := analytics_max(1, tty_width - index_width - count_width - percent_width - 10)
	mut lines := ['==> ${category} (${days} days)']
	lines << '${analytics_pad_left(index_header, index_width, ' ')} | ${analytics_pad_right(analytics_truncate(name_header, name_width), name_width, ' ')} | ${analytics_pad_left(count_header, count_width, ' ')} |  ${analytics_pad_left(percent_header, percent_width, ' ')}'
	lines << '${'-'.repeat(index_width)}:|-${'-'.repeat(name_width)}-|-${'-'.repeat(count_width)}:|-${'-'.repeat(percent_width)}:'
	mut index := 0
	for name, count in results {
		index++
		formatted_index := analytics_pad_right(analytics_pad_left(index.str(), max_index_width, '0'), index_width, ' ')
		formatted_name := analytics_pad_right(analytics_truncate(name, name_width), name_width, ' ')
		formatted_count := analytics_pad_left(analytics_format_count(count), count_width, ' ')
		percent := if total_count == 0 { 0.0 } else { f64(count) * 100.0 / f64(total_count) }
		formatted_percent := analytics_pad_left(analytics_format_percent(percent), percent_width, ' ')
		lines << '${formatted_index} | ${formatted_name} | ${formatted_count} | ${formatted_percent}%'
	}
	if results.len > 1 {
		lines << '${analytics_pad_right('Total', index_width, ' ')} | ${analytics_pad_right('', name_width, ' ')} | ${analytics_pad_left(formatted_total_count, count_width, ' ')} | ${analytics_pad_left(formatted_total_percent, percent_width, ' ')}%'
	}
	return '${lines.join('\n')}\n'
}

pub fn analytics_output(response api.AnalyticsResponse, args AnalyticsOutputArgs) string {
	days := if args.days == '' { '30' } else { args.days }
	category := if args.category == '' { 'install' } else { args.category }
	if response.items.len == 0 {
		return ''
	}
	mut results := map[string]i64{}
	for item in response.items {
		key := if category == 'os-version' {
			item.os_version
		} else if category == 'cask-install' {
			item.cask
		} else {
			item.formula
		}
		if args.filter != '' && key != args.filter && !key.starts_with('${args.filter} ') {
			continue
		}
		results[key] = item.count.replace(',', '').i64()
	}
	if args.filter != '' && results.len == 0 {
		return 'Error: No results matching `${args.filter}` found!\n'
	}
	return analytics_table_output(category, days, results, category == 'os-version', category == 'cask-install', args.tty_width)
}

pub fn analytics_output_categories(categories []AnalyticsCategory,
	args AnalyticsOutputArgs) string {
	full := args.analytics || args.verbose
	mut output := '==> Analytics\n'
	for category in categories {
		name := category.name.replace('_', '-')
		mut summaries := []string{}
		for period in category.periods {
			if full {
				if args.days != '' && args.days.int() != period.days {
					continue
				}
				if args.category != '' && args.category != name {
					continue
				}
				output += analytics_table_output(name, period.days.str(), period.results, false, false, args.tty_width)
			} else {
				mut total := i64(0)
				for _, count in period.results {
					total += count
				}
				summaries << '${formatter_number_readable(total)} (${period.days} days)'
			}
		}
		if !full {
			output += '${name}: ${summaries.join(', ')}\n'
		}
	}
	return output
}

fn analytics_download_count(value string) i64 {
	clean := value.replace(',', '')
	if clean.ends_with('M') {
		return i64(clean.trim_string_right('M').f64() * 1_000_000.0)
	}
	return clean.i64()
}

pub fn analytics_output_github_packages(formula AnalyticsFormulaOutput,
	args AnalyticsOutputArgs) string {
	if !args.github_packages_downloads || !formula.core_formula || !formula.github_index_ok {
		return ''
	}
	mut count := i64(0)
	for version in formula.github_versions {
		if version.success && version.downloads != '' {
			count += analytics_download_count(version.downloads)
		}
	}
	return '==> GitHub Packages Downloads\n${formatter_number_readable(count)} (30 days)\n'
}

pub fn analytics_formula_output(state AnalyticsState, formula AnalyticsFormulaOutput,
	args AnalyticsOutputArgs) string {
	if state.no_analytics || !state.github_api_enabled || !state.formula_api_enabled || !formula.known_to_api || formula.categories.len == 0 {
		return ''
	}
	return analytics_output_categories(formula.categories, args) + analytics_output_github_packages(formula, args)
}

pub fn analytics_cask_output(state AnalyticsState, cask AnalyticsCaskOutput,
	args AnalyticsOutputArgs) string {
	if state.no_analytics || !state.github_api_enabled || !state.cask_api_enabled || !cask.known_to_api || cask.categories.len == 0 {
		return ''
	}
	return analytics_output_categories(cask.categories, args)
}

// Ruby method `report_influx(measurement, tags, fields)` at line 34.
pub fn ruby_analytics_l34_d1_report_influx(state AnalyticsState, measurement string,
	tags map[string]string, fields map[string]string) ?AnalyticsCurlPlan {
	return analytics_report_influx(state, measurement, tags, fields)
}

// Ruby method `deferred_curl(url, args)` at line 60.
pub fn ruby_analytics_l60_d2_deferred_curl(state AnalyticsState, url string,
	args []string) AnalyticsCurlPlan {
	return analytics_deferred_curl(state, url, args)
}

// Ruby method `report_package_event(measurement, package_name:, tap_name:, on_request: false, options: "")` at line 78.
pub fn ruby_analytics_l78_d3_report_package_event(state AnalyticsState,
	event AnalyticsPackageEvent) ?AnalyticsCurlPlan {
	return analytics_report_package_event(state, event)
}

// Ruby method `report_build_error(exception)` at line 95.
pub fn ruby_analytics_l95_d4_report_build_error(state AnalyticsState,
	build_error AnalyticsBuildError) ?AnalyticsCurlPlan {
	return analytics_report_build_error(state, build_error)
}

// Ruby method `report_command_run(command_instance)` at line 110.
pub fn ruby_analytics_l110_d5_report_command_run(state AnalyticsState,
	command AnalyticsCommandRun) ?AnalyticsCurlPlan {
	return analytics_report_command_run(state, command)
}

// Ruby method `report_test_bot_test(step_command_short, passed)` at line 150.
pub fn ruby_analytics_l150_d6_report_test_bot_test(state AnalyticsState, step_command_short string,
	passed bool) ?AnalyticsCurlPlan {
	return analytics_report_test_bot_test(state, step_command_short, passed)
}

// Ruby method `influx_message_displayed?` at line 176.
pub fn ruby_analytics_l176_d7_influx_message_displayed(state AnalyticsState) bool {
	return state.influx_message_displayed()
}

// Ruby method `messages_displayed?` at line 181.
pub fn ruby_analytics_l181_d8_messages_displayed(state AnalyticsState) bool {
	return state.messages_displayed()
}

// Ruby method `disabled?` at line 189.
pub fn ruby_analytics_l189_d9_disabled(state AnalyticsState) bool {
	return state.disabled()
}

// Ruby method `not_this_run?` at line 196.
pub fn ruby_analytics_l196_d10_not_this_run(state AnalyticsState) bool {
	return state.not_this_run()
}

// Ruby method `no_message_output?` at line 201.
pub fn ruby_analytics_l201_d11_no_message_output(state AnalyticsState) bool {
	return state.no_message_output_enabled()
}

// Ruby method `messages_displayed!` at line 207.
pub fn ruby_analytics_l207_d12_messages_displayed(mut state AnalyticsState) {
	state.messages_displayed_set()
}

// Ruby method `enable!` at line 214.
pub fn ruby_analytics_l214_d13_enable(mut state AnalyticsState) {
	state.enable()
}

// Ruby method `disable!` at line 221.
pub fn ruby_analytics_l221_d14_disable(mut state AnalyticsState) {
	state.disable()
}

// Ruby method `delete_uuid!` at line 227.
pub fn ruby_analytics_l227_d15_delete_uuid(mut state AnalyticsState) {
	state.delete_uuid()
}

// Ruby method `output(args:, filter: nil)` at line 232.
pub fn ruby_analytics_l232_d16_output(response api.AnalyticsResponse,
	args AnalyticsOutputArgs) string {
	return analytics_output(response, args)
}

// Ruby method `output_analytics(json, args:)` at line 270.
pub fn ruby_analytics_l270_d17_output_analytics(categories []AnalyticsCategory,
	args AnalyticsOutputArgs) string {
	return analytics_output_categories(categories, args)
}

// Ruby method `output_github_packages_downloads(formula, args:)` at line 300.
pub fn ruby_analytics_l300_d18_output_github_packages_downloads(formula AnalyticsFormulaOutput,
	args AnalyticsOutputArgs) string {
	return analytics_output_github_packages(formula, args)
}

// Ruby method `formula_output(formula, args:)` at line 344.
pub fn ruby_analytics_l344_d19_formula_output(state AnalyticsState,
	formula AnalyticsFormulaOutput, args AnalyticsOutputArgs) string {
	return analytics_formula_output(state, formula, args)
}

// Ruby method `cask_output(cask, args:)` at line 362.
pub fn ruby_analytics_l362_d20_cask_output(state AnalyticsState, cask AnalyticsCaskOutput,
	args AnalyticsOutputArgs) string {
	return analytics_cask_output(state, cask, args)
}

// Ruby method `with_wsl_suffix_if_needed(value, wsl: OS.wsl?)` at line 379.
pub fn ruby_analytics_l379_d21_with_wsl_suffix_if_needed(value string, wsl bool) string {
	return analytics_with_wsl_suffix(value, wsl)
}

// Ruby method `default_package_tags` at line 386.
pub fn ruby_analytics_l386_d22_default_package_tags(state AnalyticsState) map[string]string {
	return analytics_default_package_tags(state)
}

// Ruby method `default_package_fields` at line 407.
pub fn ruby_analytics_l407_d23_default_package_fields(state AnalyticsState) map[string]string {
	return analytics_default_package_fields(state)
}

// Ruby method `table_output(category, days, results, os_version: false, cask_install: false)` at line 434.
pub fn ruby_analytics_l434_d24_table_output(category string, days string,
	results map[string]i64, os_version bool, cask_install bool, tty_width int) string {
	return analytics_table_output(category, days, results, os_version, cask_install, tty_width)
}

// Ruby method `config_true?(key)` at line 522.
pub fn ruby_analytics_l522_d25_config_true(state AnalyticsState, key string) bool {
	return state.config_true(key)
}

// Ruby method `format_count(count)` at line 527.
pub fn ruby_analytics_l527_d26_format_count(count i64) string {
	return analytics_format_count(count)
}

// Ruby method `format_percent(percent)` at line 532.
pub fn ruby_analytics_l532_d27_format_percent(percent f64) string {
	return analytics_format_percent(percent)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "context"
// 5: require "erb"
// 6: require "settings"
// 7: require "cachable"
// 8: require "utils/output"
// 9:
// 10: module Utils
// 11:   # Helper module for fetching and reporting analytics data.
// 12:   module Analytics
// 13:     INFLUX_BUCKET = "analytics"
// 14:     INFLUX_TOKEN = "iVdsgJ_OjvTYGAA79gOfWlA_fX0QCuj4eYUNdb-qVUTrC3tp3JTWCADVNE9HxV0kp2ZjIK9tuthy_teX4szr9A=="
// 15:     INFLUX_HOST = "https://eu-central-1-1.aws.cloud2.influxdata.com"
// 16:     INFLUX_ORG = "d81a3e6d582d485f"
// 17:     WSL_SUFFIX = " [WSL]"
// 18:     ENV_CONFIG_COMMANDS = %w[config fetch install reinstall update update-report upgrade].freeze
// 19:
// 20:     extend Utils::Output::Mixin
// 21:     extend T::Generic
// 22:     extend Cachable
// 23:
// 24:     Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 25:
// 26:     class << self
// 27:       include Context
// 28:
// 29:       sig {
// 30:         params(measurement: Symbol,
// 31:                tags:        T::Hash[Symbol, T.any(T::Boolean, String)],
// 32:                fields:      T::Hash[Symbol, T.any(T::Boolean, String)]).void
// 33:       }
// 34:       def report_influx(measurement, tags, fields)
// 35:         return if not_this_run? || disabled?
// 36:
// 37:         # Tags are always implicitly strings and must have low cardinality.
// 38:         tags_string = tags.map { |k, v| "#{k}=#{v.to_s.gsub(/[ ,=]/) { |char| "\\#{char}" }}" }
// 39:                           .join(",")
// 40:
// 41:         # Fields need explicitly wrapped with quotes and can have high cardinality.
// 42:         fields_string = fields.compact
// 43:                               .map { |k, v| %Q(#{k}="#{v}") }
// 44:                               .join(",")
// 45:
// 46:         args = [
// 47:           "--max-time", "3",
// 48:           "--header", "Authorization: Token #{INFLUX_TOKEN}",
// 49:           "--header", "Content-Type: text/plain; charset=utf-8",
// 50:           "--header", "Accept: application/json",
// 51:           "--data-binary", "#{measurement},#{tags_string} #{fields_string} #{Time.now.to_i}"
// 52:         ]
// 53:
// 54:         # Second precision is highest we can do and has the lowest performance cost.
// 55:         url = "#{INFLUX_HOST}/api/v2/write?bucket=#{INFLUX_BUCKET}&precision=s"
// 56:         deferred_curl(url, args)
// 57:       end
// 58:
// 59:       sig { params(url: String, args: T::Array[String]).void }
// 60:       def deferred_curl(url, args)
// 61:         require "utils/curl"
// 62:
// 63:         curl = Utils::Curl.curl_executable
// 64:         args = Utils::Curl.curl_args(*args, "--silent", "--output", File::NULL, show_error: false)
// 65:         if ENV["HOMEBREW_ANALYTICS_DEBUG"]
// 66:           puts "#{curl} #{args.join(" ")} \"#{url}\""
// 67:           puts Utils.popen_read(curl, *args, url)
// 68:         else
// 69:           pid = spawn curl, *args, url, out: File::NULL, err: File::NULL
// 70:           Process.detach(pid)
// 71:         end
// 72:       end
// 73:
// 74:       sig {
// 75:         params(measurement: Symbol, package_name: String, tap_name: String,
// 76:                on_request: T::Boolean, options: String).void
// 77:       }
// 78:       def report_package_event(measurement, package_name:, tap_name:, on_request: false, options: "")
// 79:         return if not_this_run? || disabled?
// 80:
// 81:         # ensure options are removed (by `.compact` below) if empty
// 82:         options = nil if options.blank?
// 83:
// 84:         # Tags must have low cardinality.
// 85:         tags = default_package_tags.merge(on_request:)
// 86:
// 87:         # Fields can have high cardinality.
// 88:         fields = default_package_fields.merge(package: package_name, tap_name:, options:)
// 89:                                        .compact
// 90:
// 91:         report_influx(measurement, tags, fields)
// 92:       end
// 93:
// 94:       sig { params(exception: BuildError).void }
// 95:       def report_build_error(exception)
// 96:         return if not_this_run? || disabled?
// 97:
// 98:         formula = exception.formula
// 99:         return unless formula
// 100:
// 101:         tap = formula.tap
// 102:         return unless tap
// 103:         return unless tap.should_report_analytics?
// 104:
// 105:         options = exception.options.to_a.compact.map(&:to_s).sort.uniq.join(" ")
// 106:         report_package_event(:build_error, package_name: formula.name, tap_name: tap.name, options:)
// 107:       end
// 108:
// 109:       sig { params(command_instance: Homebrew::AbstractCommand).void }
// 110:       def report_command_run(command_instance)
// 111:         return if not_this_run? || disabled?
// 112:
// 113:         command = command_instance.class.command_name
// 114:
// 115:         options_array = command_instance.args.options_only.to_a.compact
// 116:
// 117:         # Strip out any flag values to reduce cardinality and preserve privacy.
// 118:         options_array.map! { |option| option.sub(/=.*/m, "=") }
// 119:
// 120:         # Strip out --with-* and --without-* options
// 121:         options_array.reject! { |option| option.match(/^--with(out)?-/) }
// 122:
// 123:         options = options_array.sort.uniq.join(" ")
// 124:
// 125:         # Tags must have low cardinality.
// 126:         tags = {
// 127:           command:,
// 128:           ci:        ENV["CI"].present?,
// 129:           devcmdrun: Homebrew::EnvConfig.devcmdrun?,
// 130:           developer: Homebrew::EnvConfig.developer?,
// 131:         }
// 132:         if ENV_CONFIG_COMMANDS.include?(command)
// 133:           variables = Homebrew::EnvConfig::ANALYTICS_VARIABLES
// 134:           env_config = variables.fetch(Random.rand(variables.length))
// 135:           tags[:env_config] = env_config.to_s
// 136:           tags[:env_config_state] = if Homebrew::EnvConfig.user_set_variable?(env_config)
// 137:             Homebrew::EnvConfig.non_default_variable?(env_config) ? "non_default" : "default"
// 138:           else
// 139:             "unset"
// 140:           end
// 141:         end
// 142:
// 143:         # Fields can have high cardinality.
// 144:         fields = { options: }
// 145:
// 146:         report_influx(:command_run, tags, fields)
// 147:       end
// 148:
// 149:       sig { params(step_command_short: String, passed: T::Boolean).void }
// 150:       def report_test_bot_test(step_command_short, passed)
// 151:         return if not_this_run? || disabled?
// 152:         return if ENV["HOMEBREW_TEST_BOT_ANALYTICS"].blank?
// 153:
// 154:         # Tags must have low cardinality.
// 155:         tags = {
// 156:           passed:,
// 157:           arch:   HOMEBREW_PHYSICAL_PROCESSOR,
// 158:           os:     HOMEBREW_SYSTEM,
// 159:         }
// 160:
// 161:         # Strip out any flag values to reduce cardinality and preserve privacy.
// 162:         # Sort options to ensure consistent ordering and improve readability.
// 163:         command_and_package, options =
// 164:           step_command_short.split
// 165:                             .map { |arg| arg.sub(/=.*/, "=") }
// 166:                             .partition { |arg| !arg.start_with?("-") }
// 167:         command = (command_and_package + options.sort).join(" ")
// 168:
// 169:         # Fields can have high cardinality.
// 170:         fields = { command: }
// 171:
// 172:         report_influx(:test_bot_test, tags, fields)
// 173:       end
// 174:
// 175:       sig { returns(T::Boolean) }
// 176:       def influx_message_displayed?
// 177:         config_true?(:influxanalyticsmessage)
// 178:       end
// 179:
// 180:       sig { returns(T::Boolean) }
// 181:       def messages_displayed?
// 182:         return false unless config_true?(:analyticsmessage)
// 183:         return false unless config_true?(:caskanalyticsmessage)
// 184:
// 185:         influx_message_displayed?
// 186:       end
// 187:
// 188:       sig { returns(T::Boolean) }
// 189:       def disabled?
// 190:         return true if Homebrew::EnvConfig.no_analytics?
// 191:
// 192:         config_true?(:analyticsdisabled)
// 193:       end
// 194:
// 195:       sig { returns(T::Boolean) }
// 196:       def not_this_run?
// 197:         ENV["HOMEBREW_NO_ANALYTICS_THIS_RUN"].present?
// 198:       end
// 199:
// 200:       sig { returns(T::Boolean) }
// 201:       def no_message_output?
// 202:         # Used by Homebrew/install
// 203:         ENV["HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT"].present?
// 204:       end
// 205:
// 206:       sig { void }
// 207:       def messages_displayed!
// 208:         Homebrew::Settings.write :analyticsmessage, true
// 209:         Homebrew::Settings.write :caskanalyticsmessage, true
// 210:         Homebrew::Settings.write :influxanalyticsmessage, true
// 211:       end
// 212:
// 213:       sig { void }
// 214:       def enable!
// 215:         Homebrew::Settings.write :analyticsdisabled, false
// 216:         delete_uuid!
// 217:         messages_displayed!
// 218:       end
// 219:
// 220:       sig { void }
// 221:       def disable!
// 222:         Homebrew::Settings.write :analyticsdisabled, true
// 223:         delete_uuid!
// 224:       end
// 225:
// 226:       sig { void }
// 227:       def delete_uuid!
// 228:         Homebrew::Settings.delete :analyticsuuid
// 229:       end
// 230:
// 231:       sig { params(args: Homebrew::Cmd::Info::Args, filter: T.nilable(String)).void }
// 232:       def output(args:, filter: nil)
// 233:         require "api"
// 234:
// 235:         days = args.days || "30"
// 236:         category = args.category || "install"
// 237:         begin
// 238:           json = Homebrew::API::Analytics.fetch category, days
// 239:         rescue ArgumentError
// 240:           # Ignore failed API requests
// 241:           return
// 242:         end
// 243:         return if json.blank? || json["items"].blank?
// 244:
// 245:         os_version = category == "os-version"
// 246:         cask_install = category == "cask-install"
// 247:         results = {}
// 248:         json["items"].each do |item|
// 249:           key = if os_version
// 250:             item["os_version"]
// 251:           elsif cask_install
// 252:             item["cask"]
// 253:           else
// 254:             item["formula"]
// 255:           end
// 256:           next if filter.present? && key != filter && !key.start_with?("#{filter} ")
// 257:
// 258:           results[key] = item["count"].tr(",", "").to_i
// 259:         end
// 260:
// 261:         if filter.present? && results.blank?
// 262:           onoe "No results matching `#{filter}` found!"
// 263:           return
// 264:         end
// 265:
// 266:         table_output(category, days, results, os_version:, cask_install:)
// 267:       end
// 268:
// 269:       sig { params(json: T::Hash[String, T.untyped], args: Homebrew::Cmd::Info::Args).void }
// 270:       def output_analytics(json, args:)
// 271:         full_analytics = args.analytics? || verbose?
// 272:
// 273:         ohai "Analytics"
// 274:         json["analytics"].each do |category, value|
// 275:           category = category.tr("_", "-")
// 276:           analytics = []
// 277:
// 278:           value.each do |days, results|
// 279:             days = days.to_i
// 280:             if full_analytics
// 281:               next if args.days.present? && args.days&.to_i != days
// 282:               next if args.category.present? && args.category != category
// 283:
// 284:               table_output(category, days.to_s, results)
// 285:             else
// 286:               total_count = results.values.sum
// 287:               analytics << "#{Formatter.number_readable(total_count)} (#{days} days)"
// 288:             end
// 289:           end
// 290:
// 291:           puts "#{category}: #{analytics.join(", ")}" unless full_analytics
// 292:         end
// 293:       end
// 294:
// 295:       # This method is undocumented because it is not intended for general use.
// 296:       # It relies on screen scraping some GitHub HTML that's not available as an API.
// 297:       # This seems very likely to break in the future.
// 298:       # That said, it's the only way to get the data we want right now.
// 299:       sig { params(formula: Formula, args: Homebrew::Cmd::Info::Args).void }
// 300:       def output_github_packages_downloads(formula, args:)
// 301:         return unless args.github_packages_downloads?
// 302:         return unless formula.core_formula?
// 303:
// 304:         require "utils/curl"
// 305:
// 306:         escaped_formula_name = GitHubPackages.image_formula_name(formula.name)
// 307:                                              .gsub("/", "%2F")
// 308:         formula_url_suffix = "container/core%2F#{escaped_formula_name}/"
// 309:         formula_url = "https://github.com/Homebrew/homebrew-core/pkgs/#{formula_url_suffix}"
// 310:         output = Utils::Curl.curl_output("--fail", formula_url)
// 311:         return unless output.success?
// 312:
// 313:         formula_version_urls = output.stdout
// 314:                                      .scan(%r{/orgs/Homebrew/packages/#{formula_url_suffix}\d+\?tag=[^"]+})
// 315:                                      .map do |url|
// 316:           T.cast(url, String).sub("/orgs/Homebrew/packages/", "/Homebrew/homebrew-core/pkgs/")
// 317:         end
// 318:         return if formula_version_urls.empty?
// 319:
// 320:         thirty_day_download_count = 0
// 321:         formula_version_urls.each do |formula_version_url_suffix|
// 322:           formula_version_url = "https://github.com#{formula_version_url_suffix}"
// 323:           output = Utils::Curl.curl_output("--fail", formula_version_url)
// 324:           next unless output.success?
// 325:
// 326:           last_thirty_days_match = output.stdout.match(
// 327:             %r{<span class="[\s\-a-z]*">Last 30 days</span>\s*<span class="[\s\-a-z]*">([\d.M,]+)</span>}m,
// 328:           )
// 329:           next if last_thirty_days_match.blank?
// 330:
// 331:           last_thirty_days_downloads = last_thirty_days_match.captures.fetch(0).tr(",", "")
// 332:           thirty_day_download_count += if (millions_match = last_thirty_days_downloads.match(/(\d+\.\d+)M/).presence)
// 333:             (millions_match.captures.first.to_f * 1_000_000).to_i
// 334:           else
// 335:             last_thirty_days_downloads.to_i
// 336:           end
// 337:         end
// 338:
// 339:         ohai "GitHub Packages Downloads"
// 340:         puts "#{Formatter.number_readable(thirty_day_download_count)} (30 days)"
// 341:       end
// 342:
// 343:       sig { params(formula: Formula, args: Homebrew::Cmd::Info::Args).void }
// 344:       def formula_output(formula, args:)
// 345:         return if Homebrew::EnvConfig.no_analytics? || Homebrew::EnvConfig.no_github_api?
// 346:
// 347:         require "api"
// 348:
// 349:         return unless Homebrew::API.formula_name? formula.name
// 350:
// 351:         json = Homebrew::API::Formula.formula_json formula.name
// 352:         return if json.blank? || json["analytics"].blank?
// 353:
// 354:         output_analytics(json, args:)
// 355:         output_github_packages_downloads(formula, args:)
// 356:       rescue ArgumentError
// 357:         # Ignore failed API requests
// 358:         nil
// 359:       end
// 360:
// 361:       sig { params(cask: Cask::Cask, args: Homebrew::Cmd::Info::Args).void }
// 362:       def cask_output(cask, args:)
// 363:         return if Homebrew::EnvConfig.no_analytics? || Homebrew::EnvConfig.no_github_api?
// 364:
// 365:         require "api"
// 366:
// 367:         return unless Homebrew::API.cask_token?(cask.token)
// 368:
// 369:         json = Homebrew::API::Cask.cask_json cask.token
// 370:         return if json.blank? || json["analytics"].blank?
// 371:
// 372:         output_analytics(json, args:)
// 373:       rescue ArgumentError
// 374:         # Ignore failed API requests
// 375:         nil
// 376:       end
// 377:
// 378:       sig { params(value: String, wsl: T::Boolean).returns(String) }
// 379:       def with_wsl_suffix_if_needed(value, wsl: OS.wsl?)
// 380:         return value if !wsl || value.end_with?(WSL_SUFFIX)
// 381:
// 382:         "#{value}#{WSL_SUFFIX}"
// 383:       end
// 384:
// 385:       sig { returns(T::Hash[Symbol, T.any(T::Boolean, String)]) }
// 386:       def default_package_tags
// 387:         cache[:default_package_tags] ||= begin
// 388:           # Only display default prefixes to reduce cardinality and improve privacy
// 389:           prefix = Homebrew.default_prefix? ? HOMEBREW_PREFIX.to_s : "custom-prefix"
// 390:
// 391:           # Tags are always strings and must have low cardinality.
// 392:           {
// 393:             ci:             ENV["CI"].present?,
// 394:             prefix:,
// 395:             default_prefix: Homebrew.default_prefix?,
// 396:             developer:      Homebrew::EnvConfig.developer?,
// 397:             devcmdrun:      Homebrew::EnvConfig.devcmdrun?,
// 398:             arch:           HOMEBREW_PHYSICAL_PROCESSOR,
// 399:             os:             with_wsl_suffix_if_needed(HOMEBREW_SYSTEM),
// 400:           }
// 401:         end
// 402:       end
// 403:
// 404:       # remove os_version starting with " or number
// 405:       # remove macOS patch release
// 406:       sig { returns(T::Hash[Symbol, String]) }
// 407:       def default_package_fields
// 408:         cache[:default_package_fields] ||= begin
// 409:           version = if (match_data = HOMEBREW_VERSION.match(/^[\d.]+/))
// 410:             suffix = "-dev" if HOMEBREW_VERSION.include?("-")
// 411:             T.must(match_data[0]) + suffix.to_s
// 412:           else
// 413:             ">=4.1.22"
// 414:           end
// 415:
// 416:           # Only include OS versions with an actual name.
// 417:           os_name_and_version = if (os_version = OS_VERSION.presence) && os_version.downcase.match?(/^[a-z]/)
// 418:             with_wsl_suffix_if_needed(os_version)
// 419:           end
// 420:
// 421:           {
// 422:             version:,
// 423:             os_name_and_version:,
// 424:           }
// 425:         end
// 426:       end
// 427:
// 428:       sig {
// 429:         params(
// 430:           category: String, days: String, results: T::Hash[String, Integer], os_version: T::Boolean,
// 431:           cask_install: T::Boolean
// 432:         ).void
// 433:       }
// 434:       def table_output(category, days, results, os_version: false, cask_install: false)
// 435:         oh1 "#{category} (#{days} days)"
// 436:         total_count = results.values.sum
// 437:         formatted_total_count = format_count(total_count)
// 438:         formatted_total_percent = format_percent(100)
// 439:
// 440:         index_header = "Index"
// 441:         count_header = "Count"
// 442:         percent_header = "Percent"
// 443:         name_with_options_header = if os_version
// 444:           "macOS Version"
// 445:         elsif cask_install
// 446:           "Token"
// 447:         else
// 448:           "Name (with options)"
// 449:         end
// 450:
// 451:         total_index_footer = "Total"
// 452:         max_index_width = results.length.to_s.length
// 453:         index_width = [
// 454:           index_header.length,
// 455:           total_index_footer.length,
// 456:           max_index_width,
// 457:         ].max
// 458:         count_width = [
// 459:           count_header.length,
// 460:           formatted_total_count.length,
// 461:         ].max
// 462:         percent_width = [
// 463:           percent_header.length,
// 464:           formatted_total_percent.length,
// 465:         ].max
// 466:         name_with_options_width = Tty.width -
// 467:                                   index_width -
// 468:                                   count_width -
// 469:                                   percent_width -
// 470:                                   10 # spacing and lines
// 471:
// 472:         formatted_index_header =
// 473:           format "%#{index_width}s", index_header
// 474:         formatted_name_with_options_header =
// 475:           format "%-#{name_with_options_width}s",
// 476:                  name_with_options_header[0..(name_with_options_width-1)]
// 477:         formatted_count_header =
// 478:           format "%#{count_width}s", count_header
// 479:         formatted_percent_header =
// 480:           format "%#{percent_width}s", percent_header
// 481:         puts "#{formatted_index_header} | #{formatted_name_with_options_header} | " \
// 482:              "#{formatted_count_header} |  #{formatted_percent_header}"
// 483:
// 484:         columns_line = "#{"-"*index_width}:|-#{"-"*name_with_options_width}-|-" \
// 485:                        "#{"-"*count_width}:|-#{"-"*percent_width}:"
// 486:         puts columns_line
// 487:
// 488:         index = 0
// 489:         results.each do |name_with_options, count|
// 490:           index += 1
// 491:           formatted_index = format "%0#{max_index_width}d", index
// 492:           formatted_index = format "%-#{index_width}s", formatted_index
// 493:           formatted_name_with_options =
// 494:             format "%-#{name_with_options_width}s",
// 495:                    name_with_options[0..(name_with_options_width-1)]
// 496:           formatted_count = format "%#{count_width}s", format_count(count)
// 497:           formatted_percent = if total_count.zero?
// 498:             format "%#{percent_width}s", format_percent(0)
// 499:           else
// 500:             format "%#{percent_width}s",
// 501:                    format_percent((count.to_i * 100) / total_count.to_f)
// 502:           end
// 503:           puts "#{formatted_index} | #{formatted_name_with_options} | " \
// 504:                "#{formatted_count} | #{formatted_percent}%"
// 505:           next if index > 10
// 506:         end
// 507:         return if results.length <= 1
// 508:
// 509:         formatted_total_footer =
// 510:           format "%-#{index_width}s", total_index_footer
// 511:         formatted_blank_footer =
// 512:           format "%-#{name_with_options_width}s", ""
// 513:         formatted_total_count_footer =
// 514:           format "%#{count_width}s", formatted_total_count
// 515:         formatted_total_percent_footer =
// 516:           format "%#{percent_width}s", formatted_total_percent
// 517:         puts "#{formatted_total_footer} | #{formatted_blank_footer} | " \
// 518:              "#{formatted_total_count_footer} | #{formatted_total_percent_footer}%"
// 519:       end
// 520:
// 521:       sig { params(key: Symbol).returns(T::Boolean) }
// 522:       def config_true?(key)
// 523:         Homebrew::Settings.read(key) == "true"
// 524:       end
// 525:
// 526:       sig { params(count: Integer).returns(String) }
// 527:       def format_count(count)
// 528:         count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
// 529:       end
// 530:
// 531:       sig { params(percent: T.any(Integer, Float)).returns(String) }
// 532:       def format_percent(percent)
// 533:         format("%<percent>.2f", percent:)
// 534:       end
// 535:     end
// 536:   end
// 537: end
