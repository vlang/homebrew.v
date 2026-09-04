module utils

import homebrew.api
import os

// Translated from Homebrew/brew `utils/analytics.rb`.
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
