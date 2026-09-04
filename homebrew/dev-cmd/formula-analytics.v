module dev_cmd

import ruby
import os
import time
import x.json2

// Translated from Homebrew/brew `dev-cmd/formula-analytics.rb`.
// The original source is retained below until every stub has a typed V body.

pub const formula_analytics_first_influxdb_date_unix = i64(1_679_875_200)
pub const formula_analytics_influx_host = 'eu-central-1-1.aws.cloud2.influxdata.com'
pub const formula_analytics_influx_org = 'd81a3e6d582d485f'
pub const formula_analytics_influx_bucket = 'analytics'
pub const formula_analytics_wsl_suffix = ' [WSL]'

pub struct FormulaAnalyticsCommandRequest {
pub:
	argv        []string
	environment map[string]string
}

pub struct FormulaAnalyticsCommandResponse {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub type FormulaAnalyticsCommandRunner = fn (FormulaAnalyticsCommandRequest) !FormulaAnalyticsCommandResponse

pub struct FormulaAnalyticsBridgeRequest {
pub:
	python       string
	script       string
	request_json string
	query        string
	host         string
	organization string
	database     string
}

pub struct FormulaAnalyticsBridgeResponse {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub type FormulaAnalyticsBridgeRunner = fn (FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse

pub struct FormulaAnalyticsRecord {
pub:
	fields map[string]string
	count  i64
}

pub struct FormulaAnalyticsOptions {
pub:
	library_path                 string
	home_directory               string
	python_version               string
	uv_path                      string
	original_paths               []string
	environment                  map[string]string
	days_ago                     int = 30
	install                      bool
	install_on_request           bool
	cask_install                 bool
	build_error                  bool
	os_version                   bool
	homebrew_devcmdrun_developer bool
	homebrew_env_config          bool
	homebrew_os_arch_ci          bool
	homebrew_prefixes            bool
	homebrew_versions            bool
	brew_command_run             bool
	brew_command_run_options     bool
	brew_test_bot_test           bool
	json                         bool
	all_core_formulae_json       bool
	setup                        bool
	now_unix                     i64
	command_runner               FormulaAnalyticsCommandRunner = formula_analytics_default_command_runner
	bridge_runner                FormulaAnalyticsBridgeRunner = formula_analytics_default_bridge_runner
}

pub struct FormulaAnalyticsSetupResult {
pub:
	uv_path         string
	venv_root       string
	formula_root    string
	command         []string
	environment     map[string]string
	removed_entries []string
}

pub struct FormulaAnalyticsItem {
pub mut:
	number                int
	dimension_key         string
	dimension             string
	count                 i64
	formatted_count       string
	non_default_count     i64
	set_default_count     i64
	unset_count           i64
	formatted_non_default string
	formatted_set_default string
	formatted_unset       string
	percent               string
	default_value         string
	has_default_value     bool
}

pub struct FormulaAnalyticsReport {
pub mut:
	category    string
	total_items int
	start_date  string
	end_date    string
	total_count i64
	items       []FormulaAnalyticsItem
	formulae    map[string][]FormulaAnalyticsItem
	query       string
}

pub struct FormulaAnalyticsRunResult {
pub:
	setup    FormulaAnalyticsSetupResult
	reports  []FormulaAnalyticsReport
	warnings []string
	output   string
}

@[heap]
pub struct FormulaAnalyticsInput {
pub:
	options FormulaAnalyticsOptions
}

@[heap]
pub struct FormulaAnalyticsEachInput {
pub:
	query   string
	options FormulaAnalyticsOptions
}

struct FormulaAnalyticsCategoryPlan {
	category      string
	dimension_key string
	groups        []string
	bucket        string
	where_clause  string
}

fn formula_analytics_default_command_runner(request FormulaAnalyticsCommandRequest) !FormulaAnalyticsCommandResponse {
	mut assignments := []string{}
	mut keys := request.environment.keys()
	keys.sort()
	for key in keys {
		assignments << '${key}=${os.quoted_path(request.environment[key])}'
	}
	prefix := if assignments.len == 0 { '' } else { assignments.join(' ') + ' ' }
	result := os.execute(prefix + request.argv.map(os.quoted_path(it)).join(' '))
	return FormulaAnalyticsCommandResponse{
		exit_code: result.exit_code
		stdout: result.output
	}
}

fn formula_analytics_default_bridge_runner(request FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse {
	root := os.join_path(os.temp_dir(), 'brew-v-formula-analytics-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	request_path := os.join_path(root, 'request.json')
	stdout_path := os.join_path(root, 'stdout.jsonl')
	stderr_path := os.join_path(root, 'stderr.txt')
	os.write_file(request_path, request.request_json)!
	command := '${os.quoted_path(request.python)} ${os.quoted_path(request.script)} < ${os.quoted_path(request_path)} > ${os.quoted_path(stdout_path)} 2> ${os.quoted_path(stderr_path)}'
	result := os.execute(command)
	return FormulaAnalyticsBridgeResponse{
		exit_code: result.exit_code
		stdout: if os.exists(stdout_path) { os.read_file(stdout_path)! } else { '' }
		stderr: if os.exists(stderr_path) { os.read_file(stderr_path)! } else { '' }
	}
}

fn formula_analytics_environment(options FormulaAnalyticsOptions, name string) string {
	if name in options.environment {
		return options.environment[name]
	}
	return os.getenv(name)
}

pub fn formula_analytics_root(options FormulaAnalyticsOptions) string {
	library := if options.library_path == '' {
		os.getenv('HOMEBREW_LIBRARY')
	} else {
		options.library_path
	}
	return os.join_path(library, 'Homebrew/formula-analytics')
}

pub fn formula_analytics_influxdb_query_script(options FormulaAnalyticsOptions) string {
	return os.join_path(formula_analytics_root(options), 'influxdb-query.py')
}

pub fn formula_analytics_venv_root(options FormulaAnalyticsOptions) !string {
	root := formula_analytics_root(options)
	python_version := if options.python_version == '' {
		os.read_file(os.join_path(root, '.python-version'))!.trim_space()
	} else {
		options.python_version.trim_space()
	}
	if python_version == '' {
		return error('formula-analytics Python version is empty')
	}
	home := if options.home_directory == '' { os.home_dir() } else { options.home_directory }
	return os.join_path(home, '.brew-formula-analytics/vendor/python', python_version)
}

pub fn formula_analytics_venv_python(options FormulaAnalyticsOptions) !string {
	return os.join_path(formula_analytics_venv_root(options)!, 'bin/python')
}

fn formula_analytics_find_uv(options FormulaAnalyticsOptions) ?string {
	if options.uv_path != '' {
		return options.uv_path
	}
	paths := if options.original_paths.len > 0 {
		options.original_paths
	} else {
		os.getenv('PATH').split(os.path_delimiter)
	}
	for path in paths {
		candidate := os.join_path(path, 'uv')
		if os.is_file(candidate) {
			return candidate
		}
	}
	return none
}

pub fn setup_formula_analytics_python(options FormulaAnalyticsOptions) !FormulaAnalyticsSetupResult {
	uv := formula_analytics_find_uv(options) or {
		return error('`uv` is required. Try:\n  brew install uv')
	}
	venv_root := formula_analytics_venv_root(options)!
	vendor_python := os.dir(venv_root)
	mut removed_entries := []string{}
	if os.is_dir(vendor_python) {
		for child_name in os.ls(vendor_python)! {
			child := os.join_path(vendor_python, child_name)
			if child == venv_root {
				continue
			}
			if os.is_dir(child) {
				os.rmdir_all(child)!
			} else {
				os.rm(child)!
			}
			removed_entries << child
		}
	}
	formula_root := formula_analytics_root(options)
	command := [uv, 'sync', '--frozen', '--project', formula_root]
	environment := {
		'UV_PROJECT_ENVIRONMENT': venv_root
	}
	response := options.command_runner(FormulaAnalyticsCommandRequest{
		argv: command
		environment: environment
	})!
	if response.exit_code != 0 {
		message := if response.stderr != '' { response.stderr } else { response.stdout }
		return error('Failed executing `${command.join(' ')}`: ${message.trim_space()}')
	}
	return FormulaAnalyticsSetupResult{
		uv_path: uv
		venv_root: venv_root
		formula_root: formula_root
		command: command
		environment: environment
		removed_entries: removed_entries
	}
}

fn formula_analytics_request_json(query string) string {
	return ruby.json_value_to_string(ruby.map_value({
		'host':     ruby.string_value(formula_analytics_influx_host)
		'org':      ruby.string_value(formula_analytics_influx_org)
		'database': ruby.string_value(formula_analytics_influx_bucket)
		'query':    ruby.string_value(query)
	}))
}

fn formula_analytics_record_from_value(value ruby.Value) !FormulaAnalyticsRecord {
	values := value.as_map()!
	mut fields := map[string]string{}
	mut count := i64(0)
	for key, entry in values {
		if key == 'count' {
			count = entry.as_int() or { entry.as_string().i64() }
			continue
		}
		fields[key] = match entry.type_name {
			'Bool' { entry.bool_data.str() }
			'Integer' { entry.int_data.str() }
			'Float' { entry.float_data.str() }
			'NilClass' { '' }
			else { entry.as_string() }
		}
	}
	return FormulaAnalyticsRecord{
		fields: fields
		count: count
	}
}

pub fn each_formula_analytics_influx_record(query string, options FormulaAnalyticsOptions) ![]FormulaAnalyticsRecord {
	request_json := formula_analytics_request_json(query)
	response := options.bridge_runner(FormulaAnalyticsBridgeRequest{
		python: formula_analytics_venv_python(options)!
		script: formula_analytics_influxdb_query_script(options)
		request_json: request_json
		query: query
		host: formula_analytics_influx_host
		organization: formula_analytics_influx_org
		database: formula_analytics_influx_bucket
	})!
	if response.exit_code != 0 {
		if response.stderr.contains('unauthenticated') {
			return error('Could not authenticate with InfluxDB! Please check your `\$HOMEBREW_INFLUXDB_TOKEN`!')
		}
		return error('InfluxDB query failed:\n${response.stderr}')
	}
	mut records := []FormulaAnalyticsRecord{}
	for line in response.stdout.split_into_lines() {
		if line.trim_space() == '' {
			continue
		}
		records << formula_analytics_record_from_value(ruby.parse_json_value(line)!)!
	}
	return records
}

fn formula_analytics_categories(options FormulaAnalyticsOptions) []string {
	mut categories := []string{}
	if options.build_error { categories << 'build_error' }
	if options.cask_install { categories << 'cask_install' }
	if options.install { categories << 'formula_install' }
	if options.install_on_request { categories << 'formula_install_on_request' }
	if options.homebrew_devcmdrun_developer { categories << 'homebrew_devcmdrun_developer' }
	if options.homebrew_env_config { categories << 'homebrew_env_config' }
	if options.homebrew_os_arch_ci { categories << 'homebrew_os_arch_ci' }
	if options.homebrew_prefixes { categories << 'homebrew_prefixes' }
	if options.homebrew_versions { categories << 'homebrew_versions' }
	if options.os_version { categories << 'os_versions' }
	if options.brew_command_run { categories << 'command_run' }
	if options.brew_command_run_options { categories << 'command_run_options' }
	if options.brew_test_bot_test { categories << 'test_bot_test' }
	if categories.len == 0 {
		categories << 'formula_install'
	}
	return categories
}

fn formula_analytics_plan(category string, all_core_formulae_json bool) FormulaAnalyticsCategoryPlan {
	mut where_clause := if all_core_formulae_json {
		" AND tap_name ~ '^homebrew/(core|cask)\$'"
	} else {
		''
	}
	mut dimension_key := 'formula'
	mut groups := ['package', 'tap_name', 'options']
	bucket := if category in ['build_error', 'cask_install', 'command_run', 'test_bot_test'] {
		category
	} else if category in ['command_run_options', 'homebrew_env_config'] {
		'command_run'
	} else {
		'formula_install'
	}
	match category {
		'homebrew_devcmdrun_developer' {
			dimension_key = 'devcmdrun_developer'
			groups = ['devcmdrun', 'developer']
		}
		'homebrew_env_config' {
			dimension_key = 'env_config'
			groups = ['env_config', 'env_config_state']
			// Events predating the user-set-aware `env_config_state` tag
			// counted brew's own exports as configuration, so drop them.
			where_clause += ' AND env_config_state IS NOT NULL'
		}
		'homebrew_os_arch_ci' {
			dimension_key = 'os_arch_ci'
			groups = ['os', 'arch', 'ci']
		}
		'homebrew_prefixes' {
			dimension_key = 'prefix'
			groups = ['prefix', 'os', 'arch']
		}
		'homebrew_versions' {
			dimension_key = 'version'
			groups = ['version']
		}
		'os_versions' {
			dimension_key = 'os_version'
			groups = ['os_name_and_version']
		}
		'command_run' {
			dimension_key = 'command_run'
			groups = ['command']
		}
		'command_run_options' {
			dimension_key = 'command_run_options'
			groups = ['command', 'options', 'devcmdrun', 'developer']
		}
		'test_bot_test' {
			dimension_key = 'test_bot_test'
			groups = ['command', 'passed', 'arch', 'os']
		}
		'cask_install' {
			dimension_key = 'cask'
			groups = ['package', 'tap_name']
		}
		else {
			if category == 'formula_install_on_request' {
				where_clause += " AND on_request = 'true'"
			}
		}
	}
	return FormulaAnalyticsCategoryPlan{
		category: category
		dimension_key: dimension_key
		groups: groups
		bucket: bucket
		where_clause: where_clause
	}
}

fn formula_analytics_env_config_names() []string {
	return [
		'HOMEBREW_ALLOWED_TAPS',
		'HOMEBREW_API_AUTO_UPDATE_SECS',
		'HOMEBREW_API_DOMAIN',
		'HOMEBREW_ARCH',
		'HOMEBREW_ARTIFACT_DOMAIN',
		'HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK',
		'HOMEBREW_ASK',
		'HOMEBREW_AUTO_UPDATE_QUIET',
		'HOMEBREW_AUTO_UPDATE_SECS',
		'HOMEBREW_AVOID_NESTED_SANDBOXING',
		'HOMEBREW_BAT',
		'HOMEBREW_BAT_CONFIG_PATH',
		'HOMEBREW_BAT_THEME',
		'HOMEBREW_BOTTLE_DOMAIN',
		'HOMEBREW_BREW_GIT_REMOTE',
		'HOMEBREW_BROWSER',
		'HOMEBREW_BUNDLE_DESCRIBE',
		'HOMEBREW_BUNDLE_DUMP_DESCRIBE',
		'HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_JOBS',
		'HOMEBREW_BUNDLE_NO_DESCRIBE',
		'HOMEBREW_BUNDLE_NO_JOBS',
		'HOMEBREW_BUNDLE_NO_SECRETS',
		'HOMEBREW_BUNDLE_SECRETS',
		'HOMEBREW_BUNDLE_USER_CACHE',
		'HOMEBREW_CACHE',
		'HOMEBREW_CASK_OPTS',
		'HOMEBREW_CASK_OPTS_BINARIES',
		'HOMEBREW_CASK_OPTS_REQUIRE_SHA',
		'HOMEBREW_CLEANUP_MAX_AGE_DAYS',
		'HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS',
		'HOMEBREW_COLOR',
		'HOMEBREW_CORE_GIT_REMOTE',
		'HOMEBREW_CURLRC',
		'HOMEBREW_CURL_PATH',
		'HOMEBREW_CURL_RETRIES',
		'HOMEBREW_CURL_VERBOSE',
		'HOMEBREW_DEBUG',
		'HOMEBREW_DEVELOPER',
		'HOMEBREW_DISABLE_DEBREW',
		'HOMEBREW_DISABLE_LOAD_FORMULA',
		'HOMEBREW_DISPLAY',
		'HOMEBREW_DISPLAY_INSTALL_TIMES',
		'HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN',
		'HOMEBREW_DOCKER_REGISTRY_TOKEN',
		'HOMEBREW_DOWNLOAD_CONCURRENCY',
		'HOMEBREW_EDITOR',
		'HOMEBREW_ENV_SYNC_STRICT',
		'HOMEBREW_EVAL_ALL',
		'HOMEBREW_FAIL_LOG_LINES',
		'HOMEBREW_FORBIDDEN_CASKS',
		'HOMEBREW_FORBIDDEN_CASK_ARTIFACTS',
		'HOMEBREW_FORBIDDEN_FORMULAE',
		'HOMEBREW_FORBIDDEN_LICENSES',
		'HOMEBREW_FORBIDDEN_OWNER',
		'HOMEBREW_FORBIDDEN_OWNER_CONTACT',
		'HOMEBREW_FORBIDDEN_TAPS',
		'HOMEBREW_FORBID_CASKS',
		'HOMEBREW_FORBID_PACKAGES_FROM_PATHS',
		'HOMEBREW_FORCE_API_AUTO_UPDATE',
		'HOMEBREW_FORCE_BREWED_CA_CERTIFICATES',
		'HOMEBREW_FORCE_BREWED_CURL',
		'HOMEBREW_FORCE_BREWED_GIT',
		'HOMEBREW_FORCE_BREW_WRAPPER',
		'HOMEBREW_FORCE_BREW_WRAPPER_HELP_MESSAGE',
		'HOMEBREW_FORCE_VENDOR_RUBY',
		'HOMEBREW_FORMULA_BUILD_NETWORK',
		'HOMEBREW_FORMULA_POSTINSTALL_NETWORK',
		'HOMEBREW_FORMULA_TEST_NETWORK',
		'HOMEBREW_GITHUB_API_TOKEN',
		'HOMEBREW_GITHUB_PACKAGES_TOKEN',
		'HOMEBREW_GITHUB_PACKAGES_USER',
		'HOMEBREW_GIT_COMMITTER_EMAIL',
		'HOMEBREW_GIT_COMMITTER_NAME',
		'HOMEBREW_GIT_EMAIL',
		'HOMEBREW_GIT_NAME',
		'HOMEBREW_GIT_PATH',
		'HOMEBREW_INSTALL_BADGE',
		'HOMEBREW_LIVECHECK_AUTOBUMP',
		'HOMEBREW_LIVECHECK_WATCHLIST',
		'HOMEBREW_LOCK_CONTEXT',
		'HOMEBREW_LOGS',
		'HOMEBREW_MAKE_JOBS',
		'HOMEBREW_NO_ANALYTICS',
		'HOMEBREW_NO_ASK',
		'HOMEBREW_NO_AUTOREMOVE',
		'HOMEBREW_NO_AUTO_UPDATE',
		'HOMEBREW_NO_BOOTSNAP',
		'HOMEBREW_NO_CLEANUP_FORMULAE',
		'HOMEBREW_NO_COLOR',
		'HOMEBREW_NO_EMOJI',
		'HOMEBREW_NO_ENV_HINTS',
		'HOMEBREW_NO_EVAL_ENV_SCRUBBING',
		'HOMEBREW_NO_FORCE_BREW_WRAPPER',
		'HOMEBREW_NO_GITHUB_API',
		'HOMEBREW_NO_INSECURE_REDIRECT',
		'HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK',
		'HOMEBREW_NO_INSTALL_CLEANUP',
		'HOMEBREW_NO_INSTALL_FROM_API',
		'HOMEBREW_NO_INSTALL_UPGRADE',
		'HOMEBREW_NO_PATH_SHADOW_CHECK',
		'HOMEBREW_NO_REQUIRE_TAP_TRUST',
		'HOMEBREW_NO_SANDBOX_CASK',
		'HOMEBREW_NO_SANDBOX_LINUX',
		'HOMEBREW_NO_UPDATE_REPORT_NEW',
		'HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_NO_UPGRADE_QUIT_CASKS',
		'HOMEBREW_NO_VERIFY_ATTESTATIONS',
		'HOMEBREW_PIP_INDEX_URL',
		'HOMEBREW_PRY',
		'HOMEBREW_REQUIRE_TAP_TRUST',
		'HOMEBREW_SANDBOX_LINUX',
		'HOMEBREW_SBOM',
		'HOMEBREW_SIMULATE_MACOS_ON_LINUX',
		'HOMEBREW_SKIP_OR_LATER_BOTTLES',
		'HOMEBREW_SORBET_RECURSIVE',
		'HOMEBREW_SORBET_RUNTIME',
		'HOMEBREW_SSH_CONFIG_PATH',
		'HOMEBREW_SUDO_THROUGH_SUDO_USER',
		'HOMEBREW_SVN',
		'HOMEBREW_SYSTEM_ENV_TAKES_PRIORITY',
		'HOMEBREW_TEMP',
		'HOMEBREW_UPDATE_TO_TAG',
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_UPGRADE_GREEDY',
		'HOMEBREW_UPGRADE_GREEDY_CASKS',
		'HOMEBREW_USE_INTERNAL_API',
		'HOMEBREW_VERBOSE',
		'HOMEBREW_VERBOSE_USING_DOTS',
		'HOMEBREW_VERIFY_ATTESTATIONS',
		'SUDO_ASKPASS',
		'all_proxy',
		'ftp_proxy',
		'http_proxy',
		'https_proxy',
		'no_proxy',
		'HOMEBREW_BUNDLE_CLEANUP_NO_BREW',
		'HOMEBREW_BUNDLE_CLEANUP_NO_CASK',
		'HOMEBREW_BUNDLE_CLEANUP_NO_TAP',
		'HOMEBREW_BUNDLE_DUMP_NO_BREW',
		'HOMEBREW_BUNDLE_DUMP_NO_CASK',
		'HOMEBREW_BUNDLE_DUMP_NO_TAP',
		'HOMEBREW_BUNDLE_CLEANUP_NO_CARGO',
		'HOMEBREW_BUNDLE_CLEANUP_NO_FLATPAK',
		'HOMEBREW_BUNDLE_CLEANUP_NO_GO',
		'HOMEBREW_BUNDLE_CLEANUP_NO_KREW',
		'HOMEBREW_BUNDLE_CLEANUP_NO_MAS',
		'HOMEBREW_BUNDLE_CLEANUP_NO_NPM',
		'HOMEBREW_BUNDLE_CLEANUP_NO_UV',
		'HOMEBREW_BUNDLE_CLEANUP_NO_VSCODE',
		'HOMEBREW_BUNDLE_CLEANUP_NO_WINGET',
		'HOMEBREW_BUNDLE_DUMP_NO_CARGO',
		'HOMEBREW_BUNDLE_DUMP_NO_FLATPAK',
		'HOMEBREW_BUNDLE_DUMP_NO_GO',
		'HOMEBREW_BUNDLE_DUMP_NO_KREW',
		'HOMEBREW_BUNDLE_DUMP_NO_MAS',
		'HOMEBREW_BUNDLE_DUMP_NO_NPM',
		'HOMEBREW_BUNDLE_DUMP_NO_UV',
		'HOMEBREW_BUNDLE_DUMP_NO_VSCODE',
		'HOMEBREW_BUNDLE_DUMP_NO_WINGET',
	]
}

fn formula_analytics_default_description(name string) ?string {
	return match name {
		'HOMEBREW_MAKE_JOBS' { 'The number of available CPU cores.' }
		else { none }
	}
}

fn formula_analytics_field(record FormulaAnalyticsRecord, name string) string {
	return record.fields[name] or { '' }
}

fn formula_analytics_dimension(record FormulaAnalyticsRecord, plan FormulaAnalyticsCategoryPlan) ?string {
	return match plan.category {
		'homebrew_devcmdrun_developer' {
			'devcmdrun=${formula_analytics_field(record, 'devcmdrun')} HOMEBREW_DEVELOPER=${formula_analytics_field(record, 'developer')}'
		}
		'homebrew_os_arch_ci' {
			ci := if formula_analytics_field(record, 'ci') == 'true' { ' (CI)' } else { '' }
			'${formula_analytics_field(record, 'os')} ${formula_analytics_field(record, 'arch')}${ci}'
		}
		'homebrew_prefixes' {
			prefix := formula_analytics_field(record, 'prefix')
			standard := ['/opt/homebrew', '/usr/local', '/home/linuxbrew/.linuxbrew'].any(it.to_lower() == prefix.to_lower())
			if standard {
				prefix
			} else {
				'custom-prefix (${formula_analytics_field(record, 'os')} ${formula_analytics_field(record, 'arch')})'
			}
		}
		'os_versions' {
			format_os_version_dimension(formula_analytics_field(record, 'os_name_and_version'))
		}
		'command_run_options' {
			mut options := formula_analytics_field(record, 'options').split(' ').filter(it != '')
			options.sort()
			'${formula_analytics_field(record, 'command')} ${options.join(' ')}'
		}
		'test_bot_test' {
			formula_analytics_test_bot_dimension(record)
		}
		else {
			formula_analytics_field(record, plan.groups[0])
		}
	}
}

fn formula_analytics_test_bot_dimension(record FormulaAnalyticsRecord) ?string {
	mut command_and_package := []string{}
	mut options := []string{}
	for argument in formula_analytics_field(record, 'command').split(' ').filter(it != '') {
		if argument.starts_with('-') {
			options << argument
		} else {
			command_and_package << argument
		}
	}
	if command_and_package.len == 0
		|| command_and_package[0] !in ['audit', 'install', 'linkage', 'style', 'test'] || command_and_package.last().contains('/') || options.any(it.starts_with('--tap='))
		|| '--only-dependencies' in options || '--cached' in options {
		return none
	}
	options.sort()
	passed := if formula_analytics_field(record, 'passed') == 'true' { 'PASSED' } else { 'FAILED' }
	mut command_and_options := command_and_package.clone()
	command_and_options << options
	return '${command_and_options.join(' ')} (${formula_analytics_field(record, 'os')} ${formula_analytics_field(record, 'arch')}) (${passed})'
}

fn formula_analytics_process_record(mut report FormulaAnalyticsReport, record FormulaAnalyticsRecord,
	plan FormulaAnalyticsCategoryPlan, all_core_formulae_json bool) {
	if plan.category == 'homebrew_env_config' {
		state := formula_analytics_field(record, 'env_config_state')
		name := formula_analytics_field(record, 'env_config')
		if state !in ['unset', 'default', 'non_default'] || name !in formula_analytics_env_config_names() {
			return
		}
		report.total_count += record.count
		report.items << FormulaAnalyticsItem{
			dimension_key: plan.dimension_key
			dimension: name
			count: record.count
			non_default_count: if state == 'non_default' { record.count } else { 0 }
			set_default_count: if state == 'default' { record.count } else { 0 }
			unset_count: if state == 'unset' { record.count } else { 0 }
		}
		return
	}
	mut dimension := formula_analytics_dimension(record, plan) or { return }
	if dimension.trim_space() == '' {
		return
	}
	tap_name := formula_analytics_field(record, 'tap_name')
	if tap_name != '' && ((tap_name != 'homebrew/cask' && plan.dimension_key == 'cask')
		|| (tap_name != 'homebrew/core' && plan.dimension_key == 'formula')) {
		dimension = '${tap_name}/${dimension}'
	}
	options := formula_analytics_field(record, 'options')
	if (all_core_formulae_json || plan.category == 'build_error') && options != '' {
		selected_options := if all_core_formulae_json {
			if '--HEAD' in options.split(' ') { '--HEAD' } else { '' }
		} else {
			options
		}
		dimension = '${dimension} ${selected_options}'
	}
	dimension = dimension.trim_space()
	if dimension.contains('<') || dimension.contains('>') {
		return
	}
	report.total_items++
	report.total_count += record.count
	report.items << FormulaAnalyticsItem{
		dimension_key: plan.dimension_key
		dimension: dimension
		count: record.count
	}
}

fn formula_analytics_dedupe(mut report FormulaAnalyticsReport, category string) {
	mut positions := map[string]int{}
	mut deduped := []FormulaAnalyticsItem{}
	for item in report.items {
		if item.dimension in positions {
			index := positions[item.dimension]
			deduped[index].count += item.count
			if category == 'homebrew_env_config' {
				deduped[index].non_default_count += item.non_default_count
				deduped[index].set_default_count += item.set_default_count
				deduped[index].unset_count += item.unset_count
			}
		} else {
			positions[item.dimension] = deduped.len
			deduped << item
		}
	}
	report.items = deduped
	if category == 'homebrew_env_config' {
		report.total_items = report.items.len
	}
}

fn formula_analytics_finish_report(mut report FormulaAnalyticsReport, all_core_formulae_json bool) {
	formula_analytics_dedupe(mut report, report.category)
	if all_core_formulae_json {
		mut formulae := map[string][]FormulaAnalyticsItem{}
		for mut item in report.items {
			formula_name := item.dimension.split(' ')[0]
			if formula_name.contains('/') {
				continue
			}
			item.formatted_count = format_formula_analytics_count(item.count)
			mut values := formulae[formula_name] or { []FormulaAnalyticsItem{} }
			values << item
			formulae[formula_name] = values
		}
		for name in formulae.keys() {
			mut values := formulae[name]
			values.sort(a.count > b.count)
			formulae[name] = values
		}
		report.formulae = formulae.clone()
		report.items = []
		return
	}
	if report.category == 'homebrew_env_config' {
		report.items.sort_with_compare(fn (left &FormulaAnalyticsItem, right &FormulaAnalyticsItem) int {
			left_ratio := left.non_default_count * right.count
			right_ratio := right.non_default_count * left.count
			if left_ratio > right_ratio {
				return -1
			}
			if left_ratio < right_ratio {
				return 1
			}
			return 0
		})
	} else {
		report.items.sort(a.count > b.count)
	}
	for index, mut item in report.items {
		item.number = index + 1
		percent := if report.category == 'homebrew_env_config' {
			f64(item.non_default_count) / f64(item.count) * 100.0
		} else {
			f64(item.count) / f64(report.total_count) * 100.0
		}
		item.percent = format_formula_analytics_percent(percent)
		item.formatted_count = format_formula_analytics_count(item.count)
		if report.category == 'homebrew_env_config' {
			item.formatted_non_default = format_formula_analytics_count(item.non_default_count)
			item.formatted_set_default = format_formula_analytics_count(item.set_default_count)
			item.formatted_unset = format_formula_analytics_count(item.unset_count)
			if description := formula_analytics_default_description(item.dimension) {
				item.default_value = description
				item.has_default_value = true
			}
		}
	}
}

fn formula_analytics_item_value(item FormulaAnalyticsItem, env_config bool) ruby.Value {
	mut values := {
		'number':           ruby.int_value(item.number)
		item.dimension_key: ruby.string_value(item.dimension)
		'count':            ruby.string_value(item.formatted_count)
	}
	if env_config {
		values['non_default_count'] = ruby.string_value(item.formatted_non_default)
		values['set_default_count'] = ruby.string_value(item.formatted_set_default)
		values['unset_count'] = ruby.string_value(item.formatted_unset)
		values['percent'] = ruby.string_value(item.percent)
		values['default_value'] = if item.has_default_value {
			ruby.string_value(item.default_value)
		} else {
			ruby.object_value('NilClass', 'nil')
		}
	} else if item.percent != '' {
		values['percent'] = ruby.string_value(item.percent)
	}
	return ruby.map_value(values)
}

fn formula_analytics_report_value(report FormulaAnalyticsReport) ruby.Value {
	mut values := {
		'category':    ruby.object_value('Symbol', report.category)
		'total_items': ruby.int_value(report.total_items)
		'start_date':  ruby.string_value(report.start_date)
		'end_date':    ruby.string_value(report.end_date)
		'total_count': ruby.int_value(report.total_count)
	}
	if report.formulae.len > 0 {
		mut formulae := map[string]ruby.Value{}
		mut names := report.formulae.keys()
		names.sort()
		for name in names {
			formulae[name] = ruby.array_value(report.formulae[name].map(formula_analytics_item_value(it, false)))
		}
		values['formulae'] = ruby.map_value(formulae)
	} else {
		values['items'] = ruby.array_value(report.items.map(formula_analytics_item_value(it, report.category == 'homebrew_env_config')))
	}
	return ruby.map_value(values)
}

fn formula_analytics_report_json(report FormulaAnalyticsReport) string {
	return json2.encode(ruby.json_any_from_value(formula_analytics_report_value(report)),
		prettify: true
	)
}

pub fn run_formula_analytics_query(options FormulaAnalyticsOptions) !([]FormulaAnalyticsReport, []string) {
	if options.setup {
		command := [formula_analytics_venv_python(options)!,
			formula_analytics_influxdb_query_script(options), '--check']
		response := options.command_runner(FormulaAnalyticsCommandRequest{
			argv: command
		})!
		if response.exit_code != 0 {
			return error('Failed executing `${command.join(' ')}`: ${response.stderr}${response.stdout}')
		}
		return []FormulaAnalyticsReport{}, []string{}
	}
	if formula_analytics_environment(options, 'HOMEBREW_NO_ANALYTICS') != '' {
		return error('`\$HOMEBREW_NO_ANALYTICS` is set!')
	}
	if formula_analytics_environment(options, 'HOMEBREW_INFLUXDB_TOKEN') == '' {
		return error('No InfluxDB credentials found in `\$HOMEBREW_INFLUXDB_TOKEN`!')
	}
	now_unix := if options.now_unix == 0 { time.now().unix() } else { options.now_unix }
	max_days_ago := int((now_unix - formula_analytics_first_influxdb_date_unix) / 86_400)
	mut days_ago := options.days_ago
	mut warnings := []string{}
	if days_ago > max_days_ago {
		warnings << 'Analytics started 2023-03-27. `--days-ago` set to maximum value.'
		days_ago = max_days_ago
	}
	if days_ago > 365 {
		warnings << 'Analytics are only retained for 1 year, setting `--days-ago=365`.'
		days_ago = 365
	}
	end_date := time.unix(now_unix).format_ss()[..10]
	start_date := time.unix(now_unix - i64(days_ago) * 86_400).format_ss()[..10]
	mut reports := []FormulaAnalyticsReport{}
	for category in formula_analytics_categories(options) {
		plan := formula_analytics_plan(category, options.all_core_formulae_json)
		sql_groups := plan.groups.map('"${it}"').join(',')
		query := 'SELECT ${sql_groups}, COUNT(*) AS "count" FROM "${plan.bucket}" WHERE time >= now() - INTERVAL \'${days_ago} day\'${plan.where_clause} GROUP BY ${sql_groups}\n'
		records := each_formula_analytics_influx_record(query, options)!
		mut report := FormulaAnalyticsReport{
			category: category
			start_date: start_date
			end_date: end_date
			query: query
		}
		for record in records {
			formula_analytics_process_record(mut report, record, plan, options.all_core_formulae_json)
		}
		if report.total_count == 0 {
			return error('No data returned')
		}
		formula_analytics_finish_report(mut report, options.all_core_formulae_json)
		reports << report
	}
	return reports, warnings
}

pub fn run_formula_analytics(options FormulaAnalyticsOptions) !FormulaAnalyticsRunResult {
	setup := setup_formula_analytics_python(options)!
	reports, warnings := run_formula_analytics_query(options)!
	mut output_parts := []string{}
	for report in reports {
		output_parts << formula_analytics_report_json(report)
	}
	output := if output_parts.len == 0 { '' } else { output_parts.join('\n') + '\n' }
	return FormulaAnalyticsRunResult{
		setup: setup
		reports: reports
		warnings: warnings
		output: output
	}
}

pub fn format_formula_analytics_count(count i64) string {
	negative := count < 0
	digits := if negative { (-count).str() } else { count.str() }
	mut grouped := []string{}
	mut end := digits.len
	for end > 3 {
		grouped.prepend(digits[end - 3..end])
		end -= 3
	}
	grouped.prepend(digits[..end])
	return (if negative { '-' } else { '' }) + grouped.join(',')
}

pub fn format_formula_analytics_percent(percent f64) string {
	formatted := '${percent:.2f}'
	return if formatted.ends_with('.00') { formatted[..formatted.len - 3] } else { formatted }
}

fn formula_analytics_all_digits(value string) bool {
	return value != '' && value.bytes().all(it >= `0` && it <= `9`)
}

fn formula_analytics_numeric_prefix(value string) string {
	mut result := ''
	for character in value.bytes() {
		if (character >= `0` && character <= `9`) || character == `.` {
			result += character.ascii_str()
		} else {
			break
		}
	}
	return result.trim_right('.')
}

fn formula_analytics_macos_dimension(value string) ?string {
	parts := value.split('.')
	if parts.len == 0 || parts.len > 3 || parts[0].len < 2
		|| parts.any(!formula_analytics_all_digits(it)) {
		return none
	}
	major := parts[0].int()
	stripped := if major >= 11 {
		major.str()
	} else if parts.len >= 2 {
		'${major}.${parts[1].int()}'
	} else {
		return none
	}
	pretty := match stripped {
		'27' { 'Golden Gate' }
		'26' { 'Tahoe' }
		'15' { 'Sequoia' }
		'14' { 'Sonoma' }
		'13' { 'Ventura' }
		'12' { 'Monterey' }
		'11' { 'Big Sur' }
		'10.15' { 'Catalina' }
		else {
			return none
		}
	}
	return 'macOS ${pretty} (${stripped})'
}

fn formula_analytics_version_after(value string, marker string) ?string {
	index := value.index(marker) or { return none }
	remainder := value[index + marker.len..].trim_space()
	if remainder == '' {
		return none
	}
	return formula_analytics_numeric_prefix(remainder)
}

pub fn format_os_version_dimension(input string) ?string {
	if input.trim_space() == '' {
		return none
	}
	wsl := input.ends_with(formula_analytics_wsl_suffix)
	mut dimension := if wsl {
		input[..input.len - formula_analytics_wsl_suffix.len]
	} else {
		input
	}
	if dimension.starts_with('Intel ') {
		dimension = dimension[6..]
	} else if dimension.starts_with('Intel') {
		dimension = dimension[5..]
	}
	if dimension.starts_with('macOS ') {
		dimension = dimension[6..]
	} else if dimension.starts_with('macOS') {
		dimension = dimension[5..]
	}
	if dimension.ends_with(')') {
		if suffix := dimension.index(' (') {
			dimension = dimension[..suffix]
		}
	}
	mut formatted := if macos := formula_analytics_macos_dimension(dimension) {
		macos
	} else {
		formula_analytics_linux_dimension(dimension)
	}
	if wsl && !formatted.ends_with(formula_analytics_wsl_suffix) {
		formatted += formula_analytics_wsl_suffix
	}
	return formatted
}

fn formula_analytics_linux_dimension(dimension string) string {
	ubuntu_marker := if dimension.contains('Ubuntu-Server ') { 'Ubuntu-Server ' } else { 'Ubuntu ' }
	if version := formula_analytics_version_after(dimension, ubuntu_marker) {
		parts := version.split('.')
		if parts.len >= 2 && parts[0] in ['14', '16', '18', '20', '22', '24']
			&& parts[1] == '04' {
			return 'Ubuntu ${parts[0]}.04 LTS'
		}
		if parts.len >= 3 {
			lts := if dimension.contains('LTS') { ' LTS' } else { '' }
			return 'Ubuntu ${parts[0]}.${parts[1]}${lts}'
		}
	}
	if version := formula_analytics_version_after(dimension, 'Debian GNU/Linux ') {
		parts := version.split('.')
		if parts.len >= 2 {
			return 'Debian ${parts[0]} '
		}
	}
	if index := dimension.index('CentOS ') {
		words := dimension[index..].split(' ')
		if words.len >= 3 && formula_analytics_all_digits(formula_analytics_numeric_prefix(words[2])) {
			return 'CentOS ${words[1]} ${formula_analytics_numeric_prefix(words[2])}'
		}
	}
	if version := formula_analytics_version_after(dimension, 'Fedora Linux ') {
		parts := version.split('.')
		if parts.len > 0 && formula_analytics_all_digits(parts[0]) {
			return 'Fedora Linux ${parts[0]}'
		}
	}
	if dimension.contains('Fedora Linux Rawhide') {
		return 'Fedora Linux Rawhide'
	}
	if index := dimension.index('KDE neon ') {
		remainder := dimension[index + 9..]
		mut start := -1
		for position, character in remainder.bytes() {
			if character >= `0` && character <= `9` {
				start = position
				break
			}
		}
		if start >= 0 {
			return 'KDE neon ${formula_analytics_numeric_prefix(remainder[start..])}'
		}
	}
	if version := formula_analytics_version_after(dimension, 'Amazon Linux ') {
		parts := version.split('.')
		if parts.len >= 2 {
			return 'Amazon Linux ${parts[0]}'
		}
	}
	if dimension.starts_with('Armbian') {
		words := dimension.split(' ')
		for index, word in words {
			version := formula_analytics_numeric_prefix(word)
			parts := version.split('.')
			if parts.len >= 2 && formula_analytics_all_digits(parts[0])
				&& formula_analytics_all_digits(parts[1]) {
				codename := if index + 1 < words.len {
					' ${words[index + 1].to_lower()}'
				} else {
					''
				}
				return 'Armbian ${parts[0]}.${parts[1].int()}${codename}'
			}
		}
	}
	if version := formula_analytics_version_after(dimension, 'Red Hat Enterprise Linux CoreOS ') {
		parts := version.split('.')
		if parts.len >= 2 {
			return 'Red Hat Enterprise Linux CoreOS ${parts[0]}.${parts[1]}'
		}
	}
	words := dimension.split(' ').filter(it != '')
	if words.len >= 2 {
		last := words.last()
		parts := last.split('.')
		if parts.len >= 2 && formula_analytics_all_digits(parts[0]) && parts[1].len == 8
			&& formula_analytics_all_digits(parts[1]) {
			return '${words[..words.len - 1].join(' ')} ${parts[0]}'
		}
	}
	if dimension.starts_with('10.14') {
		return 'macOS Mojave (10.14)'
	}
	if dimension.starts_with('10.13') {
		return 'macOS High Sierra (10.13)'
	}
	if dimension.starts_with('10.12') {
		return 'macOS Sierra (10.12)'
	}
	if dimension.starts_with('10.') {
		minor := formula_analytics_numeric_prefix(dimension[3..]).split('.')[0]
		return 'macOS 10.${minor}'
	}
	return dimension
}

pub fn formula_analytics_input_boundary(input &FormulaAnalyticsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::FormulaAnalytics::Input', '', {
		'formula_analytics_input_address': u64(voidptr(input)).str()
	})
}

fn formula_analytics_input_from_value(value ruby.Value) !&FormulaAnalyticsInput {
	address := value.attributes['formula_analytics_input_address'] or {
		return error('invalid FormulaAnalytics input')
	}
	return unsafe { &FormulaAnalyticsInput(voidptr(address.u64())) }
}

pub fn formula_analytics_each_input_boundary(input &FormulaAnalyticsEachInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::FormulaAnalytics::EachInput', '', {
		'formula_analytics_each_input_address': u64(voidptr(input)).str()
	})
}

fn formula_analytics_each_input_from_value(value ruby.Value) !&FormulaAnalyticsEachInput {
	address := value.attributes['formula_analytics_each_input_address'] or {
		return error('invalid FormulaAnalytics each-record input')
	}
	return unsafe { &FormulaAnalyticsEachInput(voidptr(address.u64())) }
}

fn formula_analytics_error(kind string, message string) ruby.Value {
	return ruby.object_value(kind, message)
}

fn formula_analytics_setup_value(result FormulaAnalyticsSetupResult) ruby.Value {
	return ruby.map_value({
		'uv_path':         ruby.object_value('Pathname', result.uv_path)
		'venv_root':       ruby.object_value('Pathname', result.venv_root)
		'formula_root':    ruby.object_value('Pathname', result.formula_root)
		'command':         ruby.string_array_value(result.command)
		'removed_entries': ruby.string_array_value(result.removed_entries)
	})
}

fn formula_analytics_run_value(result FormulaAnalyticsRunResult) ruby.Value {
	return ruby.map_value({
		'setup':    formula_analytics_setup_value(result.setup)
		'reports':  ruby.array_value(result.reports.map(formula_analytics_report_value(it)))
		'warnings': ruby.string_array_value(result.warnings)
		'output':   ruby.string_value(result.output)
	})
}

// Ruby method `run` at line 66.
pub fn ruby_formula_analytics_l66_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return formula_analytics_run_value(run_formula_analytics(input.options) or {
		return formula_analytics_error('FatalError', err.msg())
	})
}

// Ruby method `setup_python` at line 72.
pub fn ruby_formula_analytics_l72_d2_setup_python(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return formula_analytics_setup_value(setup_formula_analytics_python(input.options) or {
		return formula_analytics_error('FatalError', err.msg())
	})
}

// Ruby method `formula_analytics_root` at line 88.
pub fn ruby_formula_analytics_l88_d3_formula_analytics_root(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', formula_analytics_root(input.options))
}

// Ruby method `influxdb_query_script` at line 93.
pub fn ruby_formula_analytics_l93_d4_influxdb_query_script(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', formula_analytics_influxdb_query_script(input.options))
}

// Ruby method `venv_root` at line 98.
pub fn ruby_formula_analytics_l98_d5_venv_root(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', formula_analytics_venv_root(input.options) or {
		return formula_analytics_error('SystemCallError', err.msg())
	})
}

// Ruby method `venv_python` at line 104.
pub fn ruby_formula_analytics_l104_d6_venv_python(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	return ruby.object_value('Pathname', formula_analytics_venv_python(input.options) or {
		return formula_analytics_error('SystemCallError', err.msg())
	})
}

// Ruby method `each_influx_record(query, &_block)` at line 109.
pub fn ruby_formula_analytics_l109_d7_each_influx_record(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics each-record input is required')
	}
	input := formula_analytics_each_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	records := each_formula_analytics_influx_record(input.query, input.options) or {
		return formula_analytics_error('FatalError', err.msg())
	}
	return ruby.array_value(records.map(fn (record FormulaAnalyticsRecord) ruby.Value {
		mut values := map[string]ruby.Value{}
		for key, value in record.fields {
			values[key] = ruby.string_value(value)
		}
		values['count'] = ruby.int_value(record.count)
		return ruby.map_value(values)
	}))
}

// Ruby method `influx_analytics(args)` at line 140.
pub fn ruby_formula_analytics_l140_d8_influx_analytics(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'FormulaAnalytics input is required')
	}
	input := formula_analytics_input_from_value(args[0]) or {
		return formula_analytics_error('ArgumentError', err.msg())
	}
	reports, _ := run_formula_analytics_query(input.options) or {
		return formula_analytics_error('FatalError', err.msg())
	}
	return ruby.array_value(reports.map(formula_analytics_report_value(it)))
}

// Ruby method `format_count(count)` at line 416.
pub fn ruby_formula_analytics_l416_d9_format_count(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'count is required')
	}
	count := args[0].as_int() or { args[0].as_string().i64() }
	return ruby.string_value(format_formula_analytics_count(count))
}

// Ruby method `format_percent(percent)` at line 421.
pub fn ruby_formula_analytics_l421_d10_format_percent(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_analytics_error('ArgumentError', 'percent is required')
	}
	percent := args[0].as_float() or { args[0].as_string().f64() }
	return ruby.string_value(format_formula_analytics_percent(percent))
}

// Ruby method `format_os_version_dimension(dimension)` at line 426.
pub fn ruby_formula_analytics_l426_d11_format_os_version_dimension(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.object_value('NilClass', 'nil')
	}
	formatted := format_os_version_dimension(args[0].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(formatted)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class FormulaAnalytics < AbstractCommand
// 9:       cmd_args do
// 10:         usage_banner <<~EOS
// 11:           `formula-analytics`
// 12:
// 13:           Query Homebrew's analytics.
// 14:         EOS
// 15:         flag   "--days-ago=",
// 16:                description: "Query from the specified days ago until the present. The default is 30 days."
// 17:         switch "--install",
// 18:                description: "Output the number of specifically requested installations or installation as " \
// 19:                             "dependencies of formulae. This is the default."
// 20:         switch "--install-on-request",
// 21:                description: "Output the number of specifically requested installations of formulae."
// 22:         switch "--cask-install",
// 23:                description: "Output the number of installations of casks."
// 24:         switch "--build-error",
// 25:                description: "Output the number of build errors for formulae."
// 26:         switch "--os-version",
// 27:                description: "Output the number of events by OS name and version."
// 28:         switch "--homebrew-devcmdrun-developer",
// 29:                description: "Output the number of devcmdrun/HOMEBREW_DEVELOPER events."
// 30:         switch "--homebrew-env-config",
// 31:                description: "Output rates of non-default Homebrew environment configuration variables."
// 32:         switch "--homebrew-os-arch-ci",
// 33:                description: "Output the number of OS/Architecture/CI events."
// 34:         switch "--homebrew-prefixes",
// 35:                description: "Output Homebrew prefixes."
// 36:         switch "--homebrew-versions",
// 37:                description: "Output Homebrew versions."
// 38:         switch "--brew-command-run",
// 39:                description: "Output `brew` commands run."
// 40:         switch "--brew-command-run-options",
// 41:                description: "Output `brew` commands run with options."
// 42:         switch "--brew-test-bot-test",
// 43:                description: "Output `brew test-bot` steps run."
// 44:         switch "--json",
// 45:                description: "Output JSON. This is required: plain text support has been removed."
// 46:         switch "--all-core-formulae-json",
// 47:                description: "Output a different JSON format containing the JSON data for all " \
// 48:                             "Homebrew/homebrew-core formulae."
// 49:         switch "--setup",
// 50:                description: "Install the necessary Python dependencies and exit without running a query."
// 51:
// 52:         conflicts "--install", "--cask-install", "--install-on-request", "--build-error", "--os-version",
// 53:                   "--homebrew-devcmdrun-developer", "--homebrew-env-config", "--homebrew-os-arch-ci",
// 54:                   "--homebrew-prefixes", "--homebrew-versions", "--brew-command-run", "--brew-command-run-options",
// 55:                   "--brew-test-bot-test"
// 56:         conflicts "--json", "--all-core-formulae-json", "--setup"
// 57:
// 58:         named_args :none
// 59:
// 60:         hide_from_man_page!
// 61:       end
// 62:
// 63:       FIRST_INFLUXDB_ANALYTICS_DATE = Date.new(2023, 03, 27).freeze
// 64:
// 65:       sig { override.void }
// 66:       def run
// 67:         setup_python
// 68:         influx_analytics(args)
// 69:       end
// 70:
// 71:       sig { void }
// 72:       def setup_python
// 73:         uv = which("uv", ORIGINAL_PATHS)
// 74:         odie <<~EOS if uv.nil?
// 75:           `uv` is required. Try:
// 76:             brew install uv
// 77:         EOS
// 78:
// 79:         vendor_python = venv_root.dirname
// 80:         vendor_python.children.reject { |path| path == venv_root }.each(&:rmtree) if vendor_python.exist?
// 81:
// 82:         with_env(UV_PROJECT_ENVIRONMENT: venv_root.to_s) do
// 83:           safe_system uv, "sync", "--frozen", "--project", formula_analytics_root, out: :err
// 84:         end
// 85:       end
// 86:
// 87:       sig { returns(Pathname) }
// 88:       def formula_analytics_root
// 89:         HOMEBREW_LIBRARY/"Homebrew/formula-analytics"
// 90:       end
// 91:
// 92:       sig { returns(Pathname) }
// 93:       def influxdb_query_script
// 94:         formula_analytics_root/"influxdb-query.py"
// 95:       end
// 96:
// 97:       sig { returns(Pathname) }
// 98:       def venv_root
// 99:         python_version = (formula_analytics_root/".python-version").read.chomp
// 100:         Pathname.new("~/.brew-formula-analytics/vendor/python").expand_path/python_version
// 101:       end
// 102:
// 103:       sig { returns(Pathname) }
// 104:       def venv_python
// 105:         venv_root/"bin/python"
// 106:       end
// 107:
// 108:       sig { params(query: String, _block: T.proc.params(record: T::Hash[String, T.untyped]).void).void }
// 109:       def each_influx_record(query, &_block)
// 110:         require "json"
// 111:         require "tempfile"
// 112:         require "utils/analytics"
// 113:         require "utils/popen"
// 114:
// 115:         request = {
// 116:           host:     URI.parse(Utils::Analytics::INFLUX_HOST).host,
// 117:           org:      Utils::Analytics::INFLUX_ORG,
// 118:           database: Utils::Analytics::INFLUX_BUCKET,
// 119:           query:,
// 120:         }.to_json
// 121:
// 122:         Tempfile.create("influxdb-query-stderr") do |stderr_file|
// 123:           Utils.popen([venv_python.to_s, influxdb_query_script.to_s], "r+b", { err: stderr_file.path }) do |pipe|
// 124:             pipe.write request
// 125:             pipe.close_write
// 126:             pipe.each_line { |line| yield JSON.parse(line) }
// 127:           end
// 128:
// 129:           next if $CHILD_STATUS.success?
// 130:
// 131:           stderr = stderr_file.read
// 132:           if stderr.include?("unauthenticated")
// 133:             odie "Could not authenticate with InfluxDB! Please check your `$HOMEBREW_INFLUXDB_TOKEN`!"
// 134:           end
// 135:           odie "InfluxDB query failed:\n#{stderr}"
// 136:         end
// 137:       end
// 138:
// 139:       sig { params(args: Homebrew::DevCmd::FormulaAnalytics::Args).void }
// 140:       def influx_analytics(args)
// 141:         require "utils/analytics"
// 142:         require "json"
// 143:
// 144:         if args.setup?
// 145:           safe_system venv_python, influxdb_query_script, "--check"
// 146:           return
// 147:         end
// 148:
// 149:         odie "`$HOMEBREW_NO_ANALYTICS` is set!" if ENV["HOMEBREW_NO_ANALYTICS"]
// 150:
// 151:         odie "No InfluxDB credentials found in `$HOMEBREW_INFLUXDB_TOKEN`!" unless ENV["HOMEBREW_INFLUXDB_TOKEN"]
// 152:
// 153:         max_days_ago = (Date.today - FIRST_INFLUXDB_ANALYTICS_DATE).to_s.to_i
// 154:         days_ago = (args.days_ago || 30).to_i
// 155:         if days_ago > max_days_ago
// 156:           opoo "Analytics started #{FIRST_INFLUXDB_ANALYTICS_DATE}. `--days-ago` set to maximum value."
// 157:           days_ago = max_days_ago
// 158:         end
// 159:         if days_ago > 365
// 160:           opoo "Analytics are only retained for 1 year, setting `--days-ago=365`."
// 161:           days_ago = 365
// 162:         end
// 163:
// 164:         all_core_formulae_json = args.all_core_formulae_json?
// 165:
// 166:         categories = []
// 167:         categories << :build_error if args.build_error?
// 168:         categories << :cask_install if args.cask_install?
// 169:         categories << :formula_install if args.install?
// 170:         categories << :formula_install_on_request if args.install_on_request?
// 171:         categories << :homebrew_devcmdrun_developer if args.homebrew_devcmdrun_developer?
// 172:         categories << :homebrew_env_config if args.homebrew_env_config?
// 173:         categories << :homebrew_os_arch_ci if args.homebrew_os_arch_ci?
// 174:         categories << :homebrew_prefixes if args.homebrew_prefixes?
// 175:         categories << :homebrew_versions if args.homebrew_versions?
// 176:         categories << :os_versions if args.os_version?
// 177:         categories << :command_run if args.brew_command_run?
// 178:         categories << :command_run_options if args.brew_command_run_options?
// 179:         categories << :test_bot_test if args.brew_test_bot_test?
// 180:
// 181:         category_matching_buckets = [:build_error, :cask_install, :command_run, :test_bot_test]
// 182:
// 183:         categories.each do |category|
// 184:           additional_where = all_core_formulae_json ? " AND tap_name ~ '^homebrew/(core|cask)$'" : ""
// 185:           bucket = if category_matching_buckets.include?(category)
// 186:             category
// 187:           elsif [:command_run_options, :homebrew_env_config].include?(category)
// 188:             :command_run
// 189:           else
// 190:             :formula_install
// 191:           end
// 192:
// 193:           case category
// 194:           when :homebrew_devcmdrun_developer
// 195:             dimension_key = "devcmdrun_developer"
// 196:             groups = [:devcmdrun, :developer]
// 197:           when :homebrew_env_config
// 198:             dimension_key = "env_config"
// 199:             groups = [:env_config, :env_config_state]
// 200:             # Events predating the user-set-aware `env_config_state` tag
// 201:             # counted brew's own exports as configuration, so drop them.
// 202:             additional_where += " AND env_config_state IS NOT NULL"
// 203:           when :homebrew_os_arch_ci
// 204:             dimension_key = "os_arch_ci"
// 205:             groups = [:os, :arch, :ci]
// 206:           when :homebrew_prefixes
// 207:             dimension_key = "prefix"
// 208:             groups = [:prefix, :os, :arch]
// 209:             standard_prefixes = %w[/opt/homebrew /usr/local /home/linuxbrew/.linuxbrew]
// 210:           when :homebrew_versions
// 211:             dimension_key = "version"
// 212:             groups = [:version]
// 213:           when :os_versions
// 214:             dimension_key = :os_version
// 215:             groups = [:os_name_and_version]
// 216:           when :command_run
// 217:             dimension_key = "command_run"
// 218:             groups = [:command]
// 219:           when :command_run_options
// 220:             dimension_key = "command_run_options"
// 221:             groups = [:command, :options, :devcmdrun, :developer]
// 222:           when :test_bot_test
// 223:             dimension_key = "test_bot_test"
// 224:             groups = [:command, :passed, :arch, :os]
// 225:           when :cask_install
// 226:             dimension_key = :cask
// 227:             groups = [:package, :tap_name]
// 228:           else
// 229:             dimension_key = :formula
// 230:             additional_where += " AND on_request = 'true'" if category == :formula_install_on_request
// 231:             groups = [:package, :tap_name, :options]
// 232:           end
// 233:
// 234:           sql_groups = groups.map { |e| "\"#{e}\"" }.join(",")
// 235:           query = <<~EOS
// 236:             SELECT #{sql_groups}, COUNT(*) AS "count" FROM "#{bucket}" WHERE time >= now() - INTERVAL '#{days_ago} day'#{additional_where} GROUP BY #{sql_groups}
// 237:           EOS
// 238:
// 239:           json = T.let({
// 240:             category:,
// 241:             total_items: 0,
// 242:             start_date:  Date.today - days_ago.to_i,
// 243:             end_date:    Date.today,
// 244:             total_count: 0,
// 245:             items:       [],
// 246:           }, T::Hash[Symbol, T.untyped])
// 247:
// 248:           each_influx_record(query) do |record|
// 249:             if category == :homebrew_env_config
// 250:               state = record["env_config_state"]
// 251:               env_config_name = record["env_config"].to_s
// 252:               # Drop malformed events from non-standard clients and events
// 253:               # for variables Homebrew no longer supports.
// 254:               next if %w[unset default non_default].exclude?(state)
// 255:               next unless Homebrew::EnvConfig::ENVS.key?(env_config_name.to_sym)
// 256:
// 257:               count = record["count"]
// 258:               json[:total_count] += count
// 259:               json[:items] << {
// 260:                 number: nil,
// 261:                 dimension_key => env_config_name,
// 262:                 count:,
// 263:                 non_default_count: (state == "non_default") ? count : 0,
// 264:                 set_default_count: (state == "default") ? count : 0,
// 265:                 unset_count:       (state == "unset") ? count : 0,
// 266:               }
// 267:               next
// 268:             end
// 269:
// 270:             dimension = case category
// 271:             when :homebrew_devcmdrun_developer
// 272:               "devcmdrun=#{record["devcmdrun"]} HOMEBREW_DEVELOPER=#{record["developer"]}"
// 273:             when :homebrew_os_arch_ci
// 274:               if record["ci"] == "true"
// 275:                 "#{record["os"]} #{record["arch"]} (CI)"
// 276:               else
// 277:                 "#{record["os"]} #{record["arch"]}"
// 278:               end
// 279:             when :homebrew_prefixes
// 280:               prefix = record["prefix"].to_s
// 281:               if T.must(standard_prefixes).none? { |std| std.casecmp?(prefix) }
// 282:                 "custom-prefix (#{record["os"]} #{record["arch"]})"
// 283:               else
// 284:                 prefix
// 285:               end
// 286:             when :os_versions
// 287:               format_os_version_dimension(record["os_name_and_version"])
// 288:             when :command_run_options
// 289:               "#{record["command"]} #{record["options"].to_s.split.sort.join(" ")}"
// 290:             when :test_bot_test
// 291:               command_and_package, options = record["command"].split.partition { |arg| !arg.start_with?("-") }
// 292:
// 293:               # Cleanup bad data before https://github.com/Homebrew/homebrew-test-bot/pull/1043
// 294:               # Can delete this code after 27th April 2025.
// 295:               next if %w[audit install linkage style test].exclude?(command_and_package.first)
// 296:               next if command_and_package.last.include?("/")
// 297:               next if options.include?("--tap=")
// 298:               next if options.include?("--only-dependencies")
// 299:               next if options.include?("--cached")
// 300:
// 301:               command_and_options = (command_and_package + options.sort).join(" ")
// 302:               passed = (record["passed"] == "true") ? "PASSED" : "FAILED"
// 303:
// 304:               "#{command_and_options} (#{record["os"]} #{record["arch"]}) (#{passed})"
// 305:             else
// 306:               record[groups.first.to_s]
// 307:             end
// 308:             next if dimension.blank?
// 309:
// 310:             if (tap_name = record["tap_name"].presence) &&
// 311:                ((tap_name != "homebrew/cask" && dimension_key == :cask) ||
// 312:                 (tap_name != "homebrew/core" && dimension_key == :formula))
// 313:               dimension = "#{tap_name}/#{dimension}"
// 314:             end
// 315:
// 316:             if (all_core_formulae_json || category == :build_error) &&
// 317:                (options = record["options"].presence)
// 318:               # homebrew/core formulae don't have non-HEAD options but they ended up in our analytics anyway.
// 319:               if all_core_formulae_json
// 320:                 options = options.split.include?("--HEAD") ? "--HEAD" : ""
// 321:               end
// 322:               dimension = "#{dimension} #{options}"
// 323:             end
// 324:
// 325:             dimension = dimension.strip
// 326:             next if dimension.match?(/[<>]/)
// 327:
// 328:             count = record["count"]
// 329:
// 330:             json[:total_items] += 1
// 331:             json[:total_count] += count
// 332:
// 333:             json[:items] << {
// 334:               number: nil,
// 335:               dimension_key => dimension,
// 336:               count:,
// 337:             }
// 338:           end
// 339:
// 340:           odie "No data returned" if json[:total_count].zero?
// 341:
// 342:           # Combine identical values
// 343:           deduped_items = {}
// 344:
// 345:           json[:items].each do |item|
// 346:             key = item[dimension_key]
// 347:             if deduped_items.key?(key)
// 348:               deduped_items[key][:count] += item[:count]
// 349:               if category == :homebrew_env_config
// 350:                 deduped_items[key][:non_default_count] += item[:non_default_count]
// 351:                 deduped_items[key][:set_default_count] += item[:set_default_count]
// 352:                 deduped_items[key][:unset_count] += item[:unset_count]
// 353:               end
// 354:             else
// 355:               deduped_items[key] = item
// 356:             end
// 357:           end
// 358:
// 359:           json[:items] = deduped_items.values
// 360:           json[:total_items] = json[:items].length if category == :homebrew_env_config
// 361:
// 362:           if all_core_formulae_json
// 363:             core_formula_items = {}
// 364:
// 365:             json[:items].each do |item|
// 366:               item.delete(:number)
// 367:               formula_name, = item[dimension_key].split.first
// 368:               next if formula_name.include?("/")
// 369:
// 370:               core_formula_items[formula_name] ||= []
// 371:               core_formula_items[formula_name] << item
// 372:             end
// 373:             json.delete(:items)
// 374:
// 375:             core_formula_items.each_value do |items|
// 376:               items.sort_by! { |item| -item[:count] }
// 377:               items.each do |item|
// 378:                 item[:count] = format_count(item[:count])
// 379:               end
// 380:             end
// 381:
// 382:             json[:formulae] = core_formula_items.sort_by { |name, _| name }.to_h
// 383:           else
// 384:             json[:items].sort_by! do |item|
// 385:               if category == :homebrew_env_config
// 386:                 -item[:non_default_count].to_f / item[:count]
// 387:               else
// 388:                 -item[:count]
// 389:               end
// 390:             end
// 391:
// 392:             json[:items].each_with_index do |item, index|
// 393:               item[:number] = index + 1
// 394:
// 395:               percent = if category == :homebrew_env_config
// 396:                 (item[:non_default_count].to_f / item[:count]) * 100
// 397:               else
// 398:                 (item[:count].to_f / json[:total_count]) * 100
// 399:               end
// 400:               item[:percent] = format_percent(percent)
// 401:               item[:count] = format_count(item[:count])
// 402:               next if category != :homebrew_env_config
// 403:
// 404:               item[:non_default_count] = format_count(item[:non_default_count])
// 405:               item[:set_default_count] = format_count(item[:set_default_count])
// 406:               item[:unset_count] = format_count(item[:unset_count])
// 407:               item[:default_value] = Homebrew::EnvConfig.default_description(item[dimension_key].to_sym)
// 408:             end
// 409:           end
// 410:
// 411:           puts JSON.pretty_generate json
// 412:         end
// 413:       end
// 414:
// 415:       sig { params(count: Integer).returns(String) }
// 416:       def format_count(count)
// 417:         count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
// 418:       end
// 419:
// 420:       sig { params(percent: Float).returns(String) }
// 421:       def format_percent(percent)
// 422:         format("%<percent>.2f", percent:).gsub(/\.00$/, "")
// 423:       end
// 424:
// 425:       sig { params(dimension: T.nilable(String)).returns(T.nilable(String)) }
// 426:       def format_os_version_dimension(dimension)
// 427:         return if dimension.blank?
// 428:
// 429:         require "macos_version"
// 430:         require "utils/analytics"
// 431:
// 432:         wsl = dimension.end_with?(Utils::Analytics::WSL_SUFFIX)
// 433:         dimension = dimension.delete_suffix(Utils::Analytics::WSL_SUFFIX)
// 434:         dimension = dimension.gsub(/^Intel ?/, "")
// 435:                              .gsub(/^macOS ?/, "")
// 436:                              .gsub(/ \(.+\)$/, "")
// 437:
// 438:         begin
// 439:           macos_version = ::MacOSVersion.new(dimension)
// 440:           if macos_version.pretty_name.presence && macos_version.to_sym != :dunno
// 441:             return "macOS #{macos_version.pretty_name} (#{macos_version.strip_patch})"
// 442:           end
// 443:         rescue MacOSVersion::Error
// 444:           nil
// 445:         end
// 446:
// 447:         formatted_dimension = case dimension
// 448:         when /Ubuntu(-Server)? (14|16|18|20|22|24)\.04/ then "Ubuntu #{Regexp.last_match(2)}.04 LTS"
// 449:         when /Ubuntu(-Server)? (\d+\.\d+).\d ?(LTS)?/
// 450:           "Ubuntu #{Regexp.last_match(2)} #{Regexp.last_match(3)}".strip
// 451:         when %r{Debian GNU/Linux (\d+)\.\d+} then "Debian #{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 452:         when /CentOS (\w+) (\d+)/ then "CentOS #{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 453:         when /Fedora Linux (\d+)[.\d]*/ then "Fedora Linux #{Regexp.last_match(1)}"
// 454:         when /KDE neon .*?([\d.]+)/ then "KDE neon #{Regexp.last_match(1)}"
// 455:         when /Amazon Linux (\d+)\.[.\d]*/ then "Amazon Linux #{Regexp.last_match(1)}"
// 456:         when /^Armbian\S*(?: OS)? (\d+)\.0?(\d+)\S*(?: (\w+))?/
// 457:           "Armbian #{Regexp.last_match(1)}.#{Regexp.last_match(2)} #{Regexp.last_match(3)&.downcase}".strip
// 458:         when /Fedora Linux Rawhide[.\dn]*/ then "Fedora Linux Rawhide"
// 459:         when /Red Hat Enterprise Linux CoreOS (\d+\.\d+)[-.\d]*/
// 460:           "Red Hat Enterprise Linux CoreOS #{Regexp.last_match(1)}"
// 461:         when /([A-Za-z ]+)\s+(\d+)\.\d{8}[.\d]*/ then "#{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 462:         # odisabled: add new entries when removing support, remove entries when no longer in the data
// 463:         when /^10\.14[.\d]*/ then "macOS Mojave (10.14)"
// 464:         when /^10\.13[.\d]*/ then "macOS High Sierra (10.13)"
// 465:         when /^10\.12[.\d]*/ then "macOS Sierra (10.12)"
// 466:         when /^10\.(\d+)/ then "macOS 10.#{Regexp.last_match(1)}"
// 467:         else dimension
// 468:         end
// 469:
// 470:         Utils::Analytics.with_wsl_suffix_if_needed(formatted_dimension, wsl:)
// 471:       end
// 472:     end
// 473:   end
// 474: end
