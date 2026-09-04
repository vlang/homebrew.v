module github

import ruby
import time
import x.json2

// Translated from Homebrew/brew `utils/github/api.rb`.
// The original source is retained below until every stub has a typed V body.
pub const github_api_url = 'https://api.github.com'
pub const github_api_max_pages = 50
pub const github_api_max_items = 5000
pub const github_api_paginate_retry_count = 3
pub const github_api_all_scopes = ['gist', 'repo', 'workflow']

pub enum GitHubApiCredentialsType {
	env_token
	github_cli_token
	keychain_username_password
	none
}

pub fn (credentials_type GitHubApiCredentialsType) label() string {
	return match credentials_type {
		.env_token { 'HOMEBREW_GITHUB_API_TOKEN' }
		.github_cli_token { 'GitHub CLI login' }
		.keychain_username_password { 'macOS Keychain GitHub' }
		.none { 'none' }
	}
}

pub enum GitHubApiErrorKind {
	generic
	git_repository_is_empty
	http_not_found
	rate_limit_exceeded
	authentication_failed
	missing_authentication
	validation_failed
	json_parser
}

pub struct GitHubApiError {
pub:
	kind              GitHubApiErrorKind
	message           string
	github_message    string
	reset             i64
	resource          string
	limit             int
	validation_errors []string
}

pub fn (api_error GitHubApiError) msg() string {
	return api_error.message
}

pub fn (_ GitHubApiError) code() int {
	return 1
}

pub struct GitHubApiCommandRequest {
pub:
	executable      string
	arguments       []string
	input           []string
	environment     map[string]string
	print_stderr    bool
	run_as_real_uid bool
}

pub struct GitHubApiCommandResult {
pub:
	stdout  string
	stderr  string
	success bool
}

pub type GitHubApiCommand = fn(GitHubApiCommandRequest) !GitHubApiCommandResult

pub struct GitHubApiCurlRequest {
pub:
	url       string
	arguments []string
	secrets   []string
	data_json string
}

pub struct GitHubApiCurlResult {
pub:
	stdout  string
	stderr  string
	headers string
	success bool
}

pub type GitHubApiCurl = fn(GitHubApiCurlRequest) !GitHubApiCurlResult

pub fn github_api_unavailable_command(request GitHubApiCommandRequest) !GitHubApiCommandResult {
	return error('system command unavailable: ${request.executable}')
}

pub fn github_api_unavailable_curl(request GitHubApiCurlRequest) !GitHubApiCurlResult {
	return error('GitHub REST transport unavailable for ${request.url}')
}

@[heap]
pub struct GitHubApiState {
pub:
	env_token     string
	uid_home      string
	no_github_api bool
	now           i64
	command       GitHubApiCommand = github_api_unavailable_command
	curl          GitHubApiCurl = github_api_unavailable_curl
pub mut:
	credentials_cache         string
	credentials_cached        bool
	credentials_error_message string
	warnings                  []string
	errors                    []string
	transport_calls           map[string]int
}

pub struct GitHubApiSleepState {
pub mut:
	slept_seconds []int
	warnings      []string
}

pub type GitHubApiRestBlock = fn(json2.Any) !json2.Any

pub fn github_api_identity_rest_block(value json2.Any) !json2.Any {
	return value
}

pub struct GitHubApiRestRequest {
pub:
	url              string
	data             json2.Any = json2.null
	has_data         bool
	data_binary_path string
	request_method   string
	scopes           []string
	parse_json       bool = true
	block_given      bool
	block            GitHubApiRestBlock = github_api_identity_rest_block
}

pub struct GitHubApiRestPage {
pub:
	result json2.Any
	page   int
}

pub type GitHubApiOpenRest = fn(mut GitHubApiState, GitHubApiRestRequest) !json2.Any

pub struct GitHubApiGraphqlRequest {
pub:
	query        string
	variables    map[string]json2.Any
	scopes       []string
	raise_errors bool = true
}

pub struct GitHubApiPageInfo {
pub:
	has_next_page bool
	end_cursor    string
}

pub type GitHubApiOpenGraphql = fn(mut GitHubApiState, GitHubApiGraphqlRequest) !json2.Any

pub type GitHubApiGraphqlPage = fn(json2.Any) !GitHubApiPageInfo

fn github_api_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn github_api_error_type(kind GitHubApiErrorKind) string {
	return match kind {
		.generic { 'GitHub::API::Error' }
		.git_repository_is_empty { 'GitHub::API::GitRepositoryIsEmptyError' }
		.http_not_found { 'GitHub::API::HTTPNotFoundError' }
		.rate_limit_exceeded { 'GitHub::API::RateLimitExceededError' }
		.authentication_failed { 'GitHub::API::AuthenticationFailedError' }
		.missing_authentication { 'GitHub::API::MissingAuthenticationError' }
		.validation_failed { 'GitHub::API::ValidationFailedError' }
		.json_parser { 'JSON::ParserError' }
	}
}

pub fn github_api_error_value(api_error GitHubApiError) ruby.Value {
	return ruby.structured_value(github_api_error_type(api_error.kind), api_error.message, {
		'github_message': api_error.github_message
		'reset':          api_error.reset.str()
		'resource':       api_error.resource
		'limit':          api_error.limit.str()
		'errors':         api_error.validation_errors.str()
	})
}

fn github_api_error_from_value(value ruby.Value) GitHubApiError {
	kind := match value.type_name {
		'GitHub::API::GitRepositoryIsEmptyError' { GitHubApiErrorKind.git_repository_is_empty }
		'GitHub::API::HTTPNotFoundError' { GitHubApiErrorKind.http_not_found }
		'GitHub::API::RateLimitExceededError' { GitHubApiErrorKind.rate_limit_exceeded }
		'GitHub::API::AuthenticationFailedError' { GitHubApiErrorKind.authentication_failed }
		'GitHub::API::MissingAuthenticationError' { GitHubApiErrorKind.missing_authentication }
		'GitHub::API::ValidationFailedError' { GitHubApiErrorKind.validation_failed }
		'JSON::ParserError' { GitHubApiErrorKind.json_parser }
		else { GitHubApiErrorKind.generic }
	}
	return GitHubApiError{
		kind: kind
		message: value.repr
		github_message: value.attributes['github_message'] or { value.repr }
		reset: (value.attributes['reset'] or { '0' }).i64()
		resource: value.attributes['resource'] or { '' }
		limit: (value.attributes['limit'] or { '0' }).int()
	}
}

fn github_api_string_map_from_value(value ruby.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

fn github_api_json_from_value(value ruby.Value) json2.Any {
	return match value.type_name {
		'NilClass' { json2.Any(json2.null) }
		'Bool' { json2.Any(value.bool_data) }
		'Integer' { json2.Any(value.int_data) }
		'Float' { json2.Any(value.float_data) }
		'Array' {
			if value.array_data.len > 0 {
				json2.Any(value.array_data.map(github_api_json_from_value(it)))
			} else {
				json2.Any(value.string_array_data.map(json2.Any(it)))
			}
		}
		'Hash' {
			mut mapped := map[string]json2.Any{}
			for key, item in value.map_data {
				mapped[key] = github_api_json_from_value(item)
			}
			json2.Any(mapped)
		}
		else { json2.Any(value.as_string()) }
	}
}

fn github_api_value_from_json(value json2.Any) ruby.Value {
	if value is json2.Null {
		return github_api_nil_value()
	}
	if value is bool {
		return ruby.bool_value(value)
	}
	if value is int {
		return ruby.int_value(value)
	}
	if value is i64 {
		return ruby.int_value(value)
	}
	if value is f64 {
		return ruby.float_value(value)
	}
	if value is string {
		return ruby.string_value(value)
	}
	if value is []json2.Any {
		return ruby.array_value(value.map(github_api_value_from_json(it)))
	}
	if value is map[string]json2.Any {
		mut mapped := map[string]ruby.Value{}
		for key, item in value {
			mapped[key] = github_api_value_from_json(item)
		}
		return ruby.map_value(mapped)
	}
	return ruby.string_value(value.str())
}

pub fn github_api_pat_blurb(scopes []string) string {
	return 'Create a GitHub personal access token:\n  https://github.com/settings/tokens/new?scopes=${scopes.join(',')}&description=Homebrew\n' + "echo 'export HOMEBREW_GITHUB_API_TOKEN=your_token_here' >> ~/.profile\n"
}

pub fn github_api_new_error(message string, github_message string) GitHubApiError {
	return GitHubApiError{
		kind: .generic
		message: message
		github_message: github_message
	}
}

pub fn github_api_new_git_repository_is_empty_error(github_message string) GitHubApiError {
	return GitHubApiError{
		kind: .git_repository_is_empty
		github_message: github_message
	}
}

pub fn github_api_new_http_not_found_error(github_message string) GitHubApiError {
	return GitHubApiError{
		kind: .http_not_found
		github_message: github_message
	}
}

fn github_api_pluralized(unit string, count int) string {
	return '${count} ${unit}${if count == 1 { '' } else { 's' }}'
}

pub fn github_api_pretty_duration(seconds_value f64) string {
	mut seconds := int(seconds_value)
	hide_seconds := seconds > 300
	minutes_total := seconds / 60
	seconds %= 60
	hours := minutes_total / 60
	minutes := minutes_total % 60
	if hours > 0 {
		mut result := github_api_pluralized('hour', hours)
		if minutes > 0 {
			result += ' ' + github_api_pluralized('minute', minutes)
		}
		return result
	}
	if minutes > 0 {
		mut result := github_api_pluralized('minute', minutes)
		if !hide_seconds && seconds > 0 {
			result += ' ' + github_api_pluralized('second', seconds)
		}
		return result
	}
	return github_api_pluralized('second', seconds)
}

pub fn github_api_new_rate_limit_error(github_message string, reset i64, resource string,
	limit int, credentials string, now i64) GitHubApiError {
	new_pat_message := if credentials.trim_space() == '' {
		', or:\n${github_api_pat_blurb(github_api_all_scopes)}'
	} else {
		''
	}
	message := 'GitHub API Error: ${github_message}\n' + 'Rate limit exceeded for ${resource} resource (${limit} limit).\n' + 'Try again in ${github_api_pretty_duration(f64(reset - now))}${new_pat_message}\n'
	return GitHubApiError{
		kind: .rate_limit_exceeded
		message: message
		github_message: github_message
		reset: reset
		resource: resource
		limit: limit
	}
}

pub fn github_api_new_authentication_failed_error(credentials_type GitHubApiCredentialsType,
	github_message string) GitHubApiError {
	mut message := 'GitHub API Error: ${github_message}\n'
	message += match credentials_type {
		.github_cli_token {
			'Your GitHub CLI login session may be invalid.\nRefresh it with:\n  gh auth login --hostname github.com\n'
		}
		.keychain_username_password {
			'The GitHub credentials in the macOS keychain may be invalid.\nClear them with:\n  printf "protocol=https\\\\nhost=github.com\\\\n" | git credential-osxkeychain erase\n'
		}
		.env_token {
			'`\$HOMEBREW_GITHUB_API_TOKEN` may be invalid or expired; check:\n  https://github.com/settings/tokens\n'
		}
		.none { github_api_no_credentials_message() }
	}
	return GitHubApiError{
		kind: .authentication_failed
		message: message
		github_message: github_message
	}
}

pub fn github_api_no_credentials_message() string {
	return 'No GitHub credentials found in macOS Keychain, GitHub CLI or the environment.\n${github_api_pat_blurb(github_api_all_scopes)}'
}

pub fn github_api_new_missing_authentication_error() GitHubApiError {
	return GitHubApiError{
		kind: .missing_authentication
		message: github_api_no_credentials_message()
	}
}

pub fn github_api_new_validation_failed_error(github_message string,
	errors []string) GitHubApiError {
	message := if errors.len > 0 {
		'${github_message}: ${json2.encode(errors)}'
	} else {
		github_message
	}
	return GitHubApiError{
		kind: .validation_failed
		message: message
		github_message: message
		validation_errors: errors.clone()
	}
}

pub fn github_api_sleep_for_rate_limit(api_error GitHubApiError, now i64,
	mut state GitHubApiSleepState) int {
	sleep_seconds := if api_error.reset - now > 1 { int(api_error.reset - now) } else { 1 }
	state.warnings << 'GitHub rate limit exceeded, sleeping for ${sleep_seconds} seconds...'
	state.slept_seconds << sleep_seconds
	return sleep_seconds
}

fn github_api_token_from_command_result(result GitHubApiCommandResult) ?string {
	if !result.success {
		return none
	}
	token := result.stdout.trim_right('\r\n')
	return if token == '' { none } else { token }
}

pub fn github_api_github_cli_token(state &GitHubApiState) ?string {
	result := state.command(GitHubApiCommandRequest{
		executable: 'gh'
		arguments: ['auth', 'token', '--hostname', 'github.com']
		environment: {
			'HOME': state.uid_home
		}
		print_stderr: false
		run_as_real_uid: true
	}) or { return none }
	return github_api_token_from_command_result(result)
}

fn github_api_is_ascii_alphanumeric(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`)
}

pub fn github_api_access_token_valid(token string) bool {
	if token.len == 40 && token.bytes().all((it >= `a` && it <= `f`) || (it >= `0` && it <= `9`)) {
		return true
	}
	for prefix in ['ghp_', 'gho_', 'ghu_', 'ghr_', 'github_pat_'] {
		if token.starts_with(prefix) {
			tail := token[prefix.len..]
			return tail.len >= 36 && tail.len <= 251 && tail.bytes().all(github_api_is_ascii_alphanumeric(it) || it == `_`)
		}
	}
	if token.starts_with('ghs_') {
		tail := token[4..]
		return tail.len >= 36 && tail.bytes().all(github_api_is_ascii_alphanumeric(it) || it in [
			`.`,
			`-`,
			`_`,
		])
	}
	return false
}

pub fn github_api_keychain_username_password_from_result(result GitHubApiCommandResult) ?string {
	if !result.success {
		return none
	}
	mut username := ''
	mut password := ''
	for line in result.stdout.split_into_lines() {
		if line.starts_with('username=') {
			username = line.all_after('username=')
		} else if line.starts_with('password=') {
			password = line.all_after('password=')
		}
	}
	if username == '' || !github_api_access_token_valid(password) {
		return none
	}
	return if password == '' { none } else { password }
}

pub fn github_api_keychain_username_password(state &GitHubApiState) ?string {
	result := state.command(GitHubApiCommandRequest{
		executable: 'git'
		arguments: ['credential-osxkeychain', 'get']
		input: ['protocol=https\n', 'host=github.com\n']
		environment: {
			'HOME': state.uid_home
		}
		print_stderr: false
		run_as_real_uid: true
	}) or { return none }
	return github_api_keychain_username_password_from_result(result)
}

pub fn github_api_credentials(mut state GitHubApiState) ?string {
	if state.credentials_cached {
		return if state.credentials_cache == '' { none } else { state.credentials_cache }
	}
	mut credentials := state.env_token.trim_space()
	if credentials == '' {
		credentials = github_api_github_cli_token(state) or { '' }
	}
	if credentials == '' {
		credentials = github_api_keychain_username_password(state) or { '' }
	}
	state.credentials_cache = credentials
	state.credentials_cached = true
	return if credentials == '' { none } else { credentials }
}

pub fn github_api_credentials_type(state &GitHubApiState) GitHubApiCredentialsType {
	if state.env_token.trim_space() != '' {
		return .env_token
	}
	if _ := github_api_github_cli_token(state) {
		return .github_cli_token
	}
	if _ := github_api_keychain_username_password(state) {
		return .keychain_username_password
	}
	return .none
}

fn github_api_split_scopes(value string) []string {
	if value.trim_space() == '' {
		return []string{}
	}
	return value.split(', ').filter(it != '')
}

fn github_api_scope_subset(needed []string, present []string) bool {
	for scope in needed {
		if scope !in present {
			return false
		}
	}
	return true
}

pub fn github_api_credentials_error_message(mut state GitHubApiState,
	response_headers map[string]string, needed_scopes []string) ?string {
	if response_headers.len == 0 {
		return none
	}
	accepted_scopes := github_api_split_scopes(response_headers['x-accepted-oauth-scopes'] or {
		''
	})
	required := if accepted_scopes.len > 0 { accepted_scopes } else { needed_scopes }
	credentials_scopes_raw := response_headers['x-oauth-scopes'] or { '' }
	credentials_scopes := github_api_split_scopes(credentials_scopes_raw)
	if github_api_scope_subset(required, credentials_scopes) {
		return none
	}
	if state.credentials_error_message != '' {
		return state.credentials_error_message
	}
	required_text := if required.len > 0 { required.join(', ') } else { 'none' }
	present_text := if credentials_scopes_raw.trim_space() != '' {
		credentials_scopes_raw
	} else {
		'none'
	}
	message := 'Your ${github_api_credentials_type(state).label()} credentials do not have sufficient scope!\n' + 'Scopes required: ${required_text}\n' + 'Scopes present:  ${present_text}\n' + github_api_pat_blurb(required)
	state.credentials_error_message = message
	state.errors << message
	return message
}

fn github_api_any_blank(value json2.Any) bool {
	if value is json2.Null {
		return true
	}
	if value is string {
		return value == ''
	}
	if value is []json2.Any {
		return value.len == 0
	}
	if value is map[string]json2.Any {
		return value.len == 0
	}
	if value is bool {
		return !value
	}
	return false
}

fn github_api_split_http_output(stdout string) (string, string) {
	index := stdout.last_index('\n') or { return '', stdout }
	return stdout[..index], stdout[index + 1..]
}

pub fn github_api_open_rest(mut state GitHubApiState,
	request GitHubApiRestRequest) !json2.Any {
	if state.no_github_api {
		empty := json2.Any(map[string]json2.Any{})
		return if request.block_given { request.block(empty) } else { empty }
	}
	mut arguments := ['--header', 'Accept: application/vnd.github+json', '--write-out',
		'\n%{http_code}']
	token := github_api_credentials(mut state) or { '' }
	if github_api_credentials_type(state) != .none {
		arguments << '--header'
		arguments << 'Authorization: token ${token}'
	}
	arguments << '--header'
	arguments << 'X-GitHub-Api-Version:2022-11-28'
	mut data_json := ''
	if request.has_data {
		data_json = json2.encode(request.data, prettify: true)
	}
	if request.data_binary_path != '' {
		arguments << '--data-binary'
		arguments << '@${request.data_binary_path}'
		arguments << '--header'
		arguments << 'Content-Type: application/gzip'
	}
	if request.has_data {
		arguments << '--data'
		arguments << '@github_api_post'
		if request.request_method != '' {
			arguments << '--request'
			arguments << request.request_method
		}
	}
	arguments << '--dump-header'
	arguments << 'github_api_headers'
	result := state.curl(GitHubApiCurlRequest{
		url: request.url
		arguments: arguments
		secrets: if token == '' { []string{} } else { [token] }
		data_json: data_json
	})!
	mut output, mut http_code := github_api_split_http_output(result.stdout)
	if http_code == '000' {
		output, http_code = github_api_split_http_output(output)
	}
	if !http_code.starts_with('2') || !result.success {
		github_api_raise_error(mut state, output, result.stderr, http_code, result.headers, request.scopes)!
	}
	if http_code == '204' {
		return json2.Any(json2.null)
	}
	mut parsed := json2.Any(output)
	if !request.parse_json {
		return if request.block_given { request.block(parsed) } else { parsed }
	}
	parsed = json2.decode[json2.Any](output) or {
		return GitHubApiError{
			kind: .generic
			message: 'Failed to parse JSON response\n${err.msg()}'
		}
	}
	return if request.block_given { request.block(parsed) } else { parsed }
}

// Ruby method `self.pat_blurb(scopes = ALL_SCOPES)` at line 11.
pub fn ruby_api_l11_d1_self_pat_blurb(args ...ruby.Value) ruby.Value {
	scopes := if args.len > 0 {
		args[0].as_string_array() or { github_api_all_scopes }
	} else {
		github_api_all_scopes
	}
	return ruby.string_value(github_api_pat_blurb(scopes))
}

// Ruby method `initialize(message = nil, github_message = T.unsafe(nil))` at line 58.
pub fn ruby_api_l58_d2_initialize(args ...ruby.Value) ruby.Value {
	message := if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	}
	github_message := if args.len > 1 { args[1].as_string() } else { '' }
	return github_api_error_value(github_api_new_error(message, github_message))
}

// Ruby method `initialize(github_message)` at line 67.
pub fn ruby_api_l67_d3_initialize(args ...ruby.Value) ruby.Value {
	return github_api_error_value(github_api_new_git_repository_is_empty_error(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `initialize(github_message)` at line 75.
pub fn ruby_api_l75_d4_initialize(args ...ruby.Value) ruby.Value {
	return github_api_error_value(github_api_new_http_not_found_error(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `initialize(github_message, reset:, resource:, limit:)` at line 83.
pub fn ruby_api_l83_d5_initialize(args ...ruby.Value) ruby.Value {
	github_message := if args.len > 0 { args[0].as_string() } else { '' }
	reset := if args.len > 1 { args[1].as_int() or { i64(0) } } else { i64(0) }
	resource := if args.len > 2 { args[2].as_string() } else { '' }
	limit := if args.len > 3 { int(args[3].as_int() or { i64(0) }) } else { 0 }
	credentials := if args.len > 4 { args[4].as_string() } else { '' }
	now := if args.len > 5 { args[5].as_int() or { time.now().unix() } } else { time.now().unix() }
	return github_api_error_value(github_api_new_rate_limit_error(github_message, reset, resource, limit, credentials, now))
}

// Ruby attr_reader `attr_reader :reset` at line 95.
pub fn ruby_api_l95_d6_reset(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.int_value(0)
	}
	return ruby.int_value(github_api_error_from_value(args[0]).reset)
}

// Ruby method `pretty_ratelimit_reset` at line 98.
pub fn ruby_api_l98_d7_pretty_ratelimit_reset(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value(github_api_pretty_duration(0))
	}
	api_error := github_api_error_from_value(args[0])
	now := if args.len > 1 { args[1].as_int() or { time.now().unix() } } else { time.now().unix() }
	return ruby.string_value(github_api_pretty_duration(f64(api_error.reset - now)))
}

// Ruby method `initialize(credentials_type, github_message)` at line 117.
pub fn ruby_api_l117_d8_initialize(args ...ruby.Value) ruby.Value {
	credentials_type := github_api_credentials_type_from_string(if args.len > 0 {
		args[0].as_string()
	} else {
		'none'
	})
	github_message := if args.len > 1 { args[1].as_string() } else { '' }
	return github_api_error_value(github_api_new_authentication_failed_error(credentials_type, github_message))
}

// Ruby method `initialize` at line 148.
pub fn ruby_api_l148_d9_initialize(args ...ruby.Value) ruby.Value {
	_ = args
	return github_api_error_value(github_api_new_missing_authentication_error())
}

// Ruby method `initialize(github_message, errors)` at line 156.
pub fn ruby_api_l156_d10_initialize(args ...ruby.Value) ruby.Value {
	github_message := if args.len > 0 { args[0].as_string() } else { '' }
	errors := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	return github_api_error_value(github_api_new_validation_failed_error(github_message, errors))
}

// Ruby method `self.sleep_for_rate_limit(exception)` at line 174.
pub fn ruby_api_l174_d11_self_sleep_for_rate_limit(args ...ruby.Value) ruby.Value {
	api_error := if args.len > 0 { github_api_error_from_value(args[0]) } else { GitHubApiError{} }
	now := if args.len > 1 { args[1].as_int() or { time.now().unix() } } else { time.now().unix() }
	mut sleep_state := GitHubApiSleepState{}
	seconds := github_api_sleep_for_rate_limit(api_error, now, mut sleep_state)
	return ruby.structured_value('GitHubApiSleep', seconds.str(), {
		'seconds': seconds.str()
		'warning': sleep_state.warnings[0]
	})
}

// Ruby method `self.github_cli_token` at line 182.
pub fn ruby_api_l182_d12_self_github_cli_token(args ...ruby.Value) ruby.Value {
	result := GitHubApiCommandResult{
		stdout: if args.len > 0 { args[0].as_string() } else { '' }
		success: if args.len > 1 { args[1].as_bool() or { false } } else { false }
	}
	return if token := github_api_token_from_command_result(result) {
		ruby.string_value(token)
	} else {
		github_api_nil_value()
	}
}

// Ruby method `self.keychain_username_password` at line 199.
pub fn ruby_api_l199_d13_self_keychain_username_password(args ...ruby.Value) ruby.Value {
	result := GitHubApiCommandResult{
		stdout: if args.len > 0 { args[0].as_string() } else { '' }
		success: if args.len > 1 { args[1].as_bool() or { false } } else { false }
	}
	return if token := github_api_keychain_username_password_from_result(result) {
		ruby.string_value(token)
	} else {
		github_api_nil_value()
	}
}

// Ruby method `self.credentials` at line 223.
pub fn ruby_api_l223_d14_self_credentials(args ...ruby.Value) ruby.Value {
	for argument in args {
		if argument.as_string().trim_space() != '' && argument.type_name != 'NilClass' {
			return ruby.string_value(argument.as_string())
		}
	}
	return github_api_nil_value()
}

fn github_api_credentials_type_from_string(value string) GitHubApiCredentialsType {
	return match value.trim_left(':') {
		'env_token' { .env_token }
		'github_cli_token' { .github_cli_token }
		'keychain_username_password' { .keychain_username_password }
		else { .none }
	}
}

// Ruby method `self.credentials_type` at line 231.
pub fn ruby_api_l231_d15_self_credentials_type(args ...ruby.Value) ruby.Value {
	env_token := if args.len > 0 { args[0].as_string() } else { '' }
	cli_token := if args.len > 1 { args[1].as_string() } else { '' }
	keychain_token := if args.len > 2 { args[2].as_string() } else { '' }
	credentials_type := if env_token.trim_space() != '' {
		GitHubApiCredentialsType.env_token
	} else if cli_token.trim_space() != '' {
		GitHubApiCredentialsType.github_cli_token
	} else if keychain_token.trim_space() != '' {
		GitHubApiCredentialsType.keychain_username_password
	} else {
		GitHubApiCredentialsType.none
	}
	return ruby.object_value('Symbol', credentials_type.str())
}

// Ruby method `self.credentials_error_message(response_headers, needed_scopes)` at line 253.
pub fn ruby_api_l253_d16_self_credentials_error_message(args ...ruby.Value) ruby.Value {
	headers := if args.len > 0 {
		github_api_string_map_from_value(args[0])
	} else {
		map[string]string{}
	}
	scopes := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	mut state := GitHubApiState{
		env_token: if args.len > 2 { args[2].as_string() } else { '' }
	}
	return if message := github_api_credentials_error_message(mut state, headers, scopes) {
		ruby.string_value(message)
	} else {
		github_api_nil_value()
	}
}

// Ruby method `self.open_rest(url, data: T.unsafe(nil), data_binary_path: T.unsafe(nil), request_method: T.unsafe(nil),` at line 289.
pub fn ruby_api_l289_d17_self_open_rest(mut state GitHubApiState,
	request GitHubApiRestRequest) !json2.Any {
	return github_api_open_rest(mut state, request)
}

pub struct GitHubApiCommitRequest {
pub:
	url            string
	request_method string
}

pub type GitHubApiCommitOpenRest = fn(GitHubApiCommitRequest) !json2.Any

fn github_api_encode_uri_component(value string) string {
	mut encoded := ''
	for character in value.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`-`,
			`_`,
			`.`,
			`~`,
		] {
			encoded += character.ascii_str()
		} else {
			encoded += '%${character:02X}'
		}
	}
	return encoded
}

pub fn github_api_commit(user string, repo string, branch string,
	open_rest GitHubApiCommitOpenRest) !map[string]json2.Any {
	response := open_rest(GitHubApiCommitRequest{
		url: 'https://api.github.com/repos/${user}/${repo}/commits/${github_api_encode_uri_component(branch)}'
		request_method: 'GET'
	})!
	if response is map[string]json2.Any {
		return response.clone()
	}
	return error('expected GitHub commit object')
}

// Ruby method `self.commit(user, repo, branch: "main")` at line 364.
pub fn ruby_api_l364_d18_self_commit(user string, repo string, branch string,
	open_rest GitHubApiCommitOpenRest) !map[string]json2.Any {
	return github_api_commit(user, repo, branch, open_rest)
}

pub fn github_api_paginate_rest(mut state GitHubApiState, url string,
	additional_query_params string, per_page int, scopes []string,
	open_rest GitHubApiOpenRest) ![]GitHubApiRestPage {
	mut pages := []GitHubApiRestPage{}
	for page in 1 .. github_api_max_pages + 1 {
		mut retry_count := 1
		mut result := json2.Any(json2.null)
		for {
			result = open_rest(mut state, GitHubApiRestRequest{
				url: '${url}?per_page=${per_page}&page=${page}&${additional_query_params}'
				scopes: scopes
			}) or {
				if err is GitHubApiError && retry_count < github_api_paginate_retry_count {
					retry_count++
					continue
				}
				return err
			}
			break
		}
		if github_api_any_blank(result) {
			break
		}
		pages << GitHubApiRestPage{
			result: result
			page: page
		}
	}
	return pages
}

fn github_api_error_messages(value json2.Any) []string {
	if value !is []json2.Any {
		return []string{}
	}
	items := value as []json2.Any
	mut messages := []string{}
	for item in items {
		if item is map[string]json2.Any {
			if message := item['message'] {
				messages << message.str()
			}
		} else {
			messages << item.str()
		}
	}
	return messages
}

pub fn github_api_open_graphql(mut state GitHubApiState, request GitHubApiGraphqlRequest,
	open_rest GitHubApiOpenRest) !json2.Any {
	result := open_rest(mut state, GitHubApiRestRequest{
		url: '${github_api_url}/graphql'
		data: json2.Any({
			'query':     json2.Any(request.query)
			'variables': json2.Any(request.variables.clone())
		})
		has_data: true
		request_method: 'POST'
		scopes: request.scopes
	})!
	if !request.raise_errors {
		return result
	}
	if result is map[string]json2.Any {
		messages := github_api_error_messages(result['errors'] or { json2.Any(json2.null) })
		if messages.len > 0 {
			return github_api_new_error(messages.join('\n'), messages.join('\n'))
		}
		return result['data'] or { json2.Any(json2.null) }
	}
	return json2.Any(json2.null)
}

pub fn github_api_paginate_graphql(mut state GitHubApiState,
	request GitHubApiGraphqlRequest, open_graphql GitHubApiOpenGraphql,
	page GitHubApiGraphqlPage) !int {
	mut variables := request.variables.clone()
	mut result := open_graphql(mut state, GitHubApiGraphqlRequest{
		...request
		variables: variables
	})!
	mut page_count := 0
	for {
		page_info := page(result)!
		page_count++
		if !page_info.has_next_page {
			break
		}
		variables['after'] = json2.Any(page_info.end_cursor)
		result = open_graphql(mut state, GitHubApiGraphqlRequest{
			...request
			variables: variables
		})!
	}
	return page_count
}

fn github_api_headers(headers string) map[string]string {
	mut meta := map[string]string{}
	for raw_line in headers.split_into_lines() {
		line := raw_line.replace(':', '')
		separator := line.index(' ') or { continue }
		key := line[..separator].to_lower().trim_space()
		if key == '' {
			continue
		}
		meta[key] = line[separator + 1..].trim_space()
	}
	return meta
}

fn github_api_response_message(output string, errors string) (string, json2.Any) {
	json := json2.decode[json2.Any](output) or {
		return 'curl failed! ${errors}', json2.Any(json2.null)
	}
	if json is map[string]json2.Any {
		if message := json['message'] {
			return message.str(), json
		}
	}
	return 'curl failed! ${errors}', json
}

pub fn github_api_raise_error(mut state GitHubApiState, output string, errors string,
	http_code string, headers string, scopes []string) ! {
	message, json := github_api_response_message(output, errors)
	meta := github_api_headers(headers)
	github_api_credentials_error_message(mut state, meta, scopes)
	credentials_type := github_api_credentials_type(state)
	match http_code {
		'401' {
			return github_api_new_authentication_failed_error(credentials_type, message)
		}
		'403' {
			remaining := (meta['x-ratelimit-remaining'] or { '1' }).int()
			if remaining <= 0 {
				return github_api_new_rate_limit_error(message, (meta['x-ratelimit-reset'] or {
					'0'
				}).i64(), meta['x-ratelimit-resource'] or { '' }, (meta['x-ratelimit-limit'] or {
					'0'
				}).int(), github_api_credentials(mut state) or { '' }, if state.now != 0 {
					state.now
				} else {
					time.now().unix()
				})
			}
			return github_api_new_authentication_failed_error(credentials_type, message)
		}
		'404' {
			if credentials_type == .none && scopes.len > 0 {
				return github_api_new_missing_authentication_error()
			}
			return github_api_new_http_not_found_error(message)
		}
		'409' {
			if message.to_lower().contains('git repository is empty') {
				return github_api_new_git_repository_is_empty_error(message)
			}
			return github_api_new_error(message, message)
		}
		'422' {
			mut validation_errors := []string{}
			if json is map[string]json2.Any {
				validation_errors = github_api_error_messages(json['errors'] or {
					json2.Any(json2.null)
				})
			}
			return github_api_new_validation_failed_error(message, validation_errors)
		}
		else {
			return github_api_new_error(message, message)
		}
	}
}

// Ruby method `self.paginate_rest(url, additional_query_params: T.unsafe(nil), per_page: 100, scopes: [].freeze, &_block)` at line 379.
pub fn ruby_api_l379_d19_self_paginate_rest(mut state GitHubApiState, url string,
	additional_query_params string, per_page int, scopes []string,
	open_rest GitHubApiOpenRest) ![]GitHubApiRestPage {
	return github_api_paginate_rest(mut state, url, additional_query_params, per_page, scopes, open_rest)
}

// Ruby method `self.open_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true)` at line 406.
pub fn ruby_api_l406_d20_self_open_graphql(mut state GitHubApiState,
	request GitHubApiGraphqlRequest, open_rest GitHubApiOpenRest) !json2.Any {
	return github_api_open_graphql(mut state, request, open_rest)
}

// Ruby method `self.paginate_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true, &_block)` at line 428.
pub fn ruby_api_l428_d21_self_paginate_graphql(mut state GitHubApiState,
	request GitHubApiGraphqlRequest, open_graphql GitHubApiOpenGraphql,
	page GitHubApiGraphqlPage) !int {
	return github_api_paginate_graphql(mut state, request, open_graphql, page)
}

// Ruby method `self.raise_error(output, errors, http_code, headers, scopes)` at line 451.
pub fn ruby_api_l451_d22_self_raise_error(mut state GitHubApiState, output string,
	errors string, http_code string, headers string, scopes []string) ! {
	return github_api_raise_error(mut state, output, errors, http_code, headers, scopes)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "uri"
// 6: require "utils/output"
// 7: require "utils/path"
// 8:
// 9: module GitHub
// 10:   sig { params(scopes: T::Array[String]).returns(String) }
// 11:   def self.pat_blurb(scopes = ALL_SCOPES)
// 12:     require "utils/formatter"
// 13:     require "utils/shell"
// 14:     <<~EOS
// 15:       Create a GitHub personal access token:
// 16:         #{Formatter.url(
// 17:           "https://github.com/settings/tokens/new?scopes=#{scopes.join(",")}&description=Homebrew",
// 18:         )}
// 19:       #{Utils::Shell.set_variable_in_profile("HOMEBREW_GITHUB_API_TOKEN", "your_token_here")}
// 20:     EOS
// 21:   end
// 22:
// 23:   API_URL = "https://api.github.com"
// 24:   API_MAX_PAGES = 50
// 25:   private_constant :API_MAX_PAGES
// 26:   API_MAX_ITEMS = 5000
// 27:   private_constant :API_MAX_ITEMS
// 28:   PAGINATE_RETRY_COUNT = 3
// 29:   private_constant :PAGINATE_RETRY_COUNT
// 30:
// 31:   CREATE_GIST_SCOPES = ["gist"].freeze
// 32:   CREATE_ISSUE_FORK_OR_PR_SCOPES = ["repo"].freeze
// 33:   CREATE_WORKFLOW_SCOPES = ["workflow"].freeze
// 34:   ALL_SCOPES = T.let((CREATE_GIST_SCOPES + CREATE_ISSUE_FORK_OR_PR_SCOPES + CREATE_WORKFLOW_SCOPES).freeze,
// 35:                      T::Array[String])
// 36:   private_constant :ALL_SCOPES
// 37:   GITHUB_ACCESS_TOKEN_REGEX = %r{
// 38:     ^(?:
// 39:       [a-f0-9]{40}                       | # legacy 40-char hex PAT
// 40:       (?:gh[pour]|github_pat)_\w{36,251} | # PAT / OAuth / user / refresh tokens
// 41:       ghs_[A-Za-z0-9.\-_]{36,}             # GitHub App installation token
// 42:     )$
// 43:   }x
// 44:   private_constant :GITHUB_ACCESS_TOKEN_REGEX
// 45:
// 46:   # Helper functions for accessing the GitHub API.
// 47:   #
// 48:   # @api internal
// 49:   module API
// 50:     extend SystemCommand::Mixin
// 51:     extend Utils::Output::Mixin
// 52:
// 53:     # Generic API error.
// 54:     class Error < RuntimeError
// 55:       include Utils::Output::Mixin
// 56:
// 57:       sig { params(message: T.nilable(String), github_message: String).void }
// 58:       def initialize(message = nil, github_message = T.unsafe(nil))
// 59:         @github_message = T.let(github_message, T.nilable(String))
// 60:         super(message)
// 61:       end
// 62:     end
// 63:
// 64:     # Error when the Git repository to be queried is empty.
// 65:     class GitRepositoryIsEmptyError < Error
// 66:       sig { params(github_message: String).void }
// 67:       def initialize(github_message)
// 68:         super(nil, github_message)
// 69:       end
// 70:     end
// 71:
// 72:     # Error when the requested URL is not found.
// 73:     class HTTPNotFoundError < Error
// 74:       sig { params(github_message: String).void }
// 75:       def initialize(github_message)
// 76:         super(nil, github_message)
// 77:       end
// 78:     end
// 79:
// 80:     # Error when the API rate limit is exceeded.
// 81:     class RateLimitExceededError < Error
// 82:       sig { params(github_message: String, reset: Integer, resource: String, limit: Integer).void }
// 83:       def initialize(github_message, reset:, resource:, limit:)
// 84:         @reset = reset
// 85:         new_pat_message = ", or:\n#{GitHub.pat_blurb}" if API.credentials.blank?
// 86:         message = <<~EOS
// 87:           GitHub API Error: #{github_message}
// 88:           Rate limit exceeded for #{resource} resource (#{limit} limit).
// 89:           Try again in #{pretty_ratelimit_reset}#{new_pat_message}
// 90:         EOS
// 91:         super(message, github_message)
// 92:       end
// 93:
// 94:       sig { returns(Integer) }
// 95:       attr_reader :reset
// 96:
// 97:       sig { returns(String) }
// 98:       def pretty_ratelimit_reset
// 99:         pretty_duration(Time.at(@reset) - Time.now)
// 100:       end
// 101:     end
// 102:
// 103:     GITHUB_IP_ALLOWLIST_ERROR = Regexp.new(
// 104:       "Although you appear to have the correct authorization credentials, " \
// 105:       "the `(.+)` organization has an IP allow list enabled, " \
// 106:       "and your IP address is not permitted to access this resource",
// 107:     ).freeze
// 108:
// 109:     NO_CREDENTIALS_MESSAGE = T.let(<<~MESSAGE.freeze, String)
// 110:       No GitHub credentials found in macOS Keychain, GitHub CLI or the environment.
// 111:       #{GitHub.pat_blurb}
// 112:     MESSAGE
// 113:
// 114:     # Error when authentication fails.
// 115:     class AuthenticationFailedError < Error
// 116:       sig { params(credentials_type: Symbol, github_message: String).void }
// 117:       def initialize(credentials_type, github_message)
// 118:         message = "GitHub API Error: #{github_message}\n"
// 119:         message << case credentials_type
// 120:         when :github_cli_token
// 121:           <<~EOS
// 122:             Your GitHub CLI login session may be invalid.
// 123:             Refresh it with:
// 124:               gh auth login --hostname github.com
// 125:           EOS
// 126:         when :keychain_username_password
// 127:           <<~EOS
// 128:             The GitHub credentials in the macOS keychain may be invalid.
// 129:             Clear them with:
// 130:               printf "protocol=https\\nhost=github.com\\n" | git credential-osxkeychain erase
// 131:           EOS
// 132:         when :env_token
// 133:           require "utils/formatter"
// 134:           <<~EOS
// 135:             `$HOMEBREW_GITHUB_API_TOKEN` may be invalid or expired; check:
// 136:               #{Formatter.url("https://github.com/settings/tokens")}
// 137:           EOS
// 138:         when :none
// 139:           NO_CREDENTIALS_MESSAGE
// 140:         end
// 141:         super message.freeze, github_message
// 142:       end
// 143:     end
// 144:
// 145:     # Error when the user has no GitHub API credentials set at all (macOS keychain, GitHub CLI or env var).
// 146:     class MissingAuthenticationError < Error
// 147:       sig { void }
// 148:       def initialize
// 149:         super NO_CREDENTIALS_MESSAGE
// 150:       end
// 151:     end
// 152:
// 153:     # Error when the API returns a validation error.
// 154:     class ValidationFailedError < Error
// 155:       sig { params(github_message: String, errors: T::Array[String]).void }
// 156:       def initialize(github_message, errors)
// 157:         github_message = "#{github_message}: #{errors}" unless errors.empty?
// 158:
// 159:         super(github_message, github_message)
// 160:       end
// 161:     end
// 162:
// 163:     ERRORS = [
// 164:       AuthenticationFailedError,
// 165:       GitRepositoryIsEmptyError,
// 166:       HTTPNotFoundError,
// 167:       RateLimitExceededError,
// 168:       Error,
// 169:       JSON::ParserError,
// 170:     ].freeze
// 171:
// 172:     # Sleeps until the rate limit from the given exception has reset.
// 173:     sig { params(exception: RateLimitExceededError).void }
// 174:     def self.sleep_for_rate_limit(exception)
// 175:       sleep_seconds = [exception.reset - Time.now.to_i, 1].max
// 176:       opoo "GitHub rate limit exceeded, sleeping for #{sleep_seconds} seconds..."
// 177:       sleep sleep_seconds
// 178:     end
// 179:
// 180:     # Gets the token from the GitHub CLI for github.com.
// 181:     sig { returns(T.nilable(String)) }
// 182:     def self.github_cli_token
// 183:       require "utils/uid"
// 184:       # Avoid `Formula["gh"].opt_bin` so this method works even with `HOMEBREW_DISABLE_LOAD_FORMULA`.
// 185:       env = Utils::Path.formula_opt_bin_env("gh").merge("HOME" => Utils::UID.uid_home).compact
// 186:       gh_out, _, result = system_command("gh",
// 187:                                          args:            ["auth", "token", "--hostname", "github.com"],
// 188:                                          env:,
// 189:                                          print_stderr:    false,
// 190:                                          run_as_real_uid: true).to_a
// 191:       return unless result.success?
// 192:
// 193:       gh_out.chomp.presence
// 194:     end
// 195:
// 196:     # Gets the password field from `git-credential-osxkeychain` for github.com,
// 197:     # but only if that password looks like a GitHub access token.
// 198:     sig { returns(T.nilable(String)) }
// 199:     def self.keychain_username_password
// 200:       require "utils/uid"
// 201:       git_credential_out, _, result = system_command("git",
// 202:                                                      args:            ["credential-osxkeychain", "get"],
// 203:                                                      input:           ["protocol=https\n", "host=github.com\n"],
// 204:                                                      env:             { "HOME" => Utils::UID.uid_home }.compact,
// 205:                                                      print_stderr:    false,
// 206:                                                      run_as_real_uid: true).to_a
// 207:       return unless result.success?
// 208:
// 209:       git_credential_out.force_encoding("ASCII-8BIT")
// 210:       github_username = git_credential_out[/^username=(.+)/, 1]
// 211:       github_password = git_credential_out[/^password=(.+)/, 1]
// 212:       return unless github_username
// 213:
// 214:       # Don't use passwords from the keychain unless they look like
// 215:       # GitHub access tokens:
// 216:       #   https://github.com/Homebrew/brew/issues/6862#issuecomment-572610344
// 217:       return unless GITHUB_ACCESS_TOKEN_REGEX.match?(github_password)
// 218:
// 219:       github_password.presence
// 220:     end
// 221:
// 222:     sig { returns(T.nilable(String)) }
// 223:     def self.credentials
// 224:       @credentials ||= T.let(nil, T.nilable(String))
// 225:       @credentials ||= Homebrew::EnvConfig.github_api_token.presence
// 226:       @credentials ||= github_cli_token
// 227:       @credentials ||= keychain_username_password
// 228:     end
// 229:
// 230:     sig { returns(Symbol) }
// 231:     def self.credentials_type
// 232:       if Homebrew::EnvConfig.github_api_token.present?
// 233:         :env_token
// 234:       elsif github_cli_token.present?
// 235:         :github_cli_token
// 236:       elsif keychain_username_password.present?
// 237:         :keychain_username_password
// 238:       else
// 239:         :none
// 240:       end
// 241:     end
// 242:
// 243:     CREDENTIAL_NAMES = T.let({
// 244:       env_token:                  "HOMEBREW_GITHUB_API_TOKEN",
// 245:       github_cli_token:           "GitHub CLI login",
// 246:       keychain_username_password: "macOS Keychain GitHub",
// 247:       none:                       "none",
// 248:     }.freeze, T::Hash[Symbol, String])
// 249:
// 250:     # Given an API response from GitHub, warn the user if their credentials
// 251:     # have insufficient permissions.
// 252:     sig { params(response_headers: T::Hash[String, String], needed_scopes: T::Array[String]).void }
// 253:     def self.credentials_error_message(response_headers, needed_scopes)
// 254:       return if response_headers.empty?
// 255:
// 256:       scopes = response_headers["x-accepted-oauth-scopes"].to_s.split(", ").presence
// 257:       needed_scopes = Set.new(scopes || needed_scopes)
// 258:       credentials_scopes = response_headers["x-oauth-scopes"]
// 259:       return if needed_scopes.subset?(Set.new(credentials_scopes.to_s.split(", ")))
// 260:
// 261:       github_permission_link = GitHub.pat_blurb(needed_scopes.to_a)
// 262:       needed_scopes = needed_scopes.to_a.join(", ").presence || "none"
// 263:       credentials_scopes = "none" if credentials_scopes.blank?
// 264:
// 265:       what = CREDENTIAL_NAMES.fetch(credentials_type)
// 266:       @credentials_error_message ||= T.let(begin
// 267:         error_message = <<~EOS
// 268:           Your #{what} credentials do not have sufficient scope!
// 269:           Scopes required: #{needed_scopes}
// 270:           Scopes present:  #{credentials_scopes}
// 271:           #{github_permission_link}
// 272:         EOS
// 273:         onoe error_message
// 274:         error_message
// 275:       end, T.nilable(String))
// 276:     end
// 277:
// 278:     T::Sig::WithoutRuntime.sig {
// 279:       params(
// 280:         url:              T.any(String, URI::Generic),
// 281:         data:             T::Hash[Symbol, T.untyped],
// 282:         data_binary_path: String,
// 283:         request_method:   Symbol,
// 284:         scopes:           T::Array[String],
// 285:         parse_json:       T::Boolean,
// 286:         _block:           T.nilable(T.proc.params(data: T::Hash[String, T.untyped]).returns(T.untyped)),
// 287:       ).returns(T.untyped)
// 288:     }
// 289:     def self.open_rest(url, data: T.unsafe(nil), data_binary_path: T.unsafe(nil), request_method: T.unsafe(nil),
// 290:                        scopes: [].freeze, parse_json: true, &_block)
// 291:       # This is a no-op if the user is opting out of using the GitHub API.
// 292:       return block_given? ? yield({}) : {} if Homebrew::EnvConfig.no_github_api?
// 293:
// 294:       # This is a Curl format token, not a Ruby one.
// 295:       # rubocop:disable Style/FormatStringToken
// 296:       args = ["--header", "Accept: application/vnd.github+json", "--write-out", "\n%{http_code}"]
// 297:       # rubocop:enable Style/FormatStringToken
// 298:
// 299:       token = credentials
// 300:       args += ["--header", "Authorization: token #{token}"] if credentials_type != :none
// 301:       args += ["--header", "X-GitHub-Api-Version:2022-11-28"]
// 302:
// 303:       require "tempfile"
// 304:       data_tmpfile = nil
// 305:       if data
// 306:         begin
// 307:           data = JSON.pretty_generate data
// 308:           data_tmpfile = Tempfile.new("github_api_post", HOMEBREW_TEMP)
// 309:         rescue JSON::ParserError => e
// 310:           raise Error, "Failed to parse JSON request:\n#{e.message}\n#{data}", e.backtrace
// 311:         end
// 312:       end
// 313:
// 314:       if data_binary_path.present?
// 315:         args += ["--data-binary", "@#{data_binary_path}"]
// 316:         args += ["--header", "Content-Type: application/gzip"]
// 317:       end
// 318:
// 319:       headers_tmpfile = Tempfile.new("github_api_headers", HOMEBREW_TEMP)
// 320:       begin
// 321:         if data_tmpfile
// 322:           data_tmpfile.write data
// 323:           data_tmpfile.close
// 324:           args += ["--data", "@#{data_tmpfile.path}"]
// 325:
// 326:           args += ["--request", request_method.to_s] if request_method
// 327:         end
// 328:
// 329:         args += ["--dump-header", T.must(headers_tmpfile.path)]
// 330:
// 331:         require "utils/curl"
// 332:         result = Utils::Curl.curl_output("--location", url.to_s, *args, secrets: token ? [token] : [])
// 333:         output, _, http_code = result.stdout.rpartition("\n")
// 334:         output, _, http_code = output.rpartition("\n") if http_code == "000"
// 335:         headers = headers_tmpfile.read
// 336:       ensure
// 337:         if data_tmpfile
// 338:           data_tmpfile.close
// 339:           data_tmpfile.unlink
// 340:         end
// 341:         headers_tmpfile.close
// 342:         headers_tmpfile.unlink
// 343:       end
// 344:
// 345:       begin
// 346:         if !http_code.start_with?("2") || !result.status.success?
// 347:           raise_error(output, result.stderr, http_code, headers || "", scopes)
// 348:         end
// 349:
// 350:         return if http_code == "204" # No Content
// 351:
// 352:         output = JSON.parse output if parse_json
// 353:         if block_given?
// 354:           yield output
// 355:         else
// 356:           output
// 357:         end
// 358:       rescue JSON::ParserError => e
// 359:         raise Error, "Failed to parse JSON response\n#{e.message}", e.backtrace
// 360:       end
// 361:     end
// 362:
// 363:     sig { params(user: String, repo: String, branch: String).returns(T::Hash[String, T.untyped]) }
// 364:     def self.commit(user, repo, branch: "main")
// 365:       open_rest("#{API_URL}/repos/#{user}/#{repo}/commits/#{URI.encode_uri_component(branch)}", request_method: :GET)
// 366:     end
// 367:
// 368:     T::Sig::WithoutRuntime.sig {
// 369:       params(
// 370:         url:                     T.any(String, URI::Generic),
// 371:         additional_query_params: String,
// 372:         per_page:                Integer,
// 373:         scopes:                  T::Array[String],
// 374:         _block:                  T.proc
// 375:                                   .params(result: T.untyped, page: Integer)
// 376:                                   .returns(T.untyped),
// 377:       ).void
// 378:     }
// 379:     def self.paginate_rest(url, additional_query_params: T.unsafe(nil), per_page: 100, scopes: [].freeze, &_block)
// 380:       (1..API_MAX_PAGES).each do |page|
// 381:         retry_count = 1
// 382:         result = begin
// 383:           API.open_rest("#{url}?per_page=#{per_page}&page=#{page}&#{additional_query_params}", scopes:)
// 384:         rescue Error
// 385:           if retry_count < PAGINATE_RETRY_COUNT
// 386:             retry_count += 1
// 387:             retry
// 388:           end
// 389:
// 390:           raise
// 391:         end
// 392:         break if result.blank?
// 393:
// 394:         yield(result, page)
// 395:       end
// 396:     end
// 397:
// 398:     sig {
// 399:       params(
// 400:         query:        String,
// 401:         variables:    T::Hash[Symbol, T.untyped],
// 402:         scopes:       T::Array[String],
// 403:         raise_errors: T::Boolean,
// 404:       ).returns(T.untyped)
// 405:     }
// 406:     def self.open_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true)
// 407:       data = { query:, variables: }
// 408:       result = open_rest("#{API_URL}/graphql", scopes:, data:, request_method: :POST)
// 409:
// 410:       if raise_errors
// 411:         raise Error, result["errors"].map { |e| e["message"] }.join("\n") if result["errors"].present?
// 412:
// 413:         result["data"]
// 414:       else
// 415:         result
// 416:       end
// 417:     end
// 418:
// 419:     sig {
// 420:       params(
// 421:         query:        String,
// 422:         variables:    T::Hash[Symbol, T.untyped],
// 423:         scopes:       T::Array[String],
// 424:         raise_errors: T::Boolean,
// 425:         _block:       T.proc.params(data: T::Hash[String, T.untyped]).returns(T.untyped),
// 426:       ).void
// 427:     }
// 428:     def self.paginate_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true, &_block)
// 429:       result = API.open_graphql(query, variables:, scopes:, raise_errors:)
// 430:
// 431:       has_next_page = T.let(true, T::Boolean)
// 432:       while has_next_page
// 433:         page_info = yield result
// 434:         has_next_page = page_info["hasNextPage"]
// 435:         if has_next_page
// 436:           variables[:after] = page_info["endCursor"]
// 437:           result = API.open_graphql(query, variables:, scopes:, raise_errors:)
// 438:         end
// 439:       end
// 440:     end
// 441:
// 442:     sig {
// 443:       params(
// 444:         output:    String,
// 445:         errors:    String,
// 446:         http_code: String,
// 447:         headers:   String,
// 448:         scopes:    T::Array[String],
// 449:       ).void
// 450:     }
// 451:     def self.raise_error(output, errors, http_code, headers, scopes)
// 452:       json = begin
// 453:         JSON.parse(output)
// 454:       rescue
// 455:         nil
// 456:       end
// 457:       message = json&.[]("message") || "curl failed! #{errors}"
// 458:
// 459:       meta = {}
// 460:       headers.lines.each do |l|
// 461:         key, _, value = l.delete(":").partition(" ")
// 462:         key = key.downcase.strip
// 463:         next if key.empty?
// 464:
// 465:         meta[key] = value.strip
// 466:       end
// 467:
// 468:       credentials_error_message(meta, scopes)
// 469:
// 470:       case http_code
// 471:       when "401"
// 472:         raise AuthenticationFailedError.new(credentials_type, message)
// 473:       when "403"
// 474:         if meta.fetch("x-ratelimit-remaining", 1).to_i <= 0
// 475:           reset = meta.fetch("x-ratelimit-reset").to_i
// 476:           resource = meta.fetch("x-ratelimit-resource")
// 477:           limit = meta.fetch("x-ratelimit-limit").to_i
// 478:           raise RateLimitExceededError.new(message, reset:, resource:, limit:)
// 479:         end
// 480:
// 481:         raise AuthenticationFailedError.new(credentials_type, message)
// 482:       when "404"
// 483:         raise MissingAuthenticationError if credentials_type == :none && scopes.present?
// 484:
// 485:         raise HTTPNotFoundError, message
// 486:       when "409"
// 487:         raise GitRepositoryIsEmptyError, message if message.downcase.include? "git repository is empty"
// 488:
// 489:         raise Error, message
// 490:       when "422"
// 491:         errors = json&.[]("errors") || []
// 492:         raise ValidationFailedError.new(message, errors)
// 493:       else
// 494:         raise Error, message
// 495:       end
// 496:     end
// 497:   end
// 498: end
