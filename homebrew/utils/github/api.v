module github

import ruby
import time
import x.json2

// Translated from Homebrew/brew `utils/github/api.rb`.
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

pub type GitHubApiCommand = fn (GitHubApiCommandRequest) !GitHubApiCommandResult

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

pub type GitHubApiCurl = fn (GitHubApiCurlRequest) !GitHubApiCurlResult

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

pub type GitHubApiRestBlock = fn (json2.Any) !json2.Any

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

pub type GitHubApiOpenRest = fn (mut GitHubApiState, GitHubApiRestRequest) !json2.Any

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

pub type GitHubApiOpenGraphql = fn (mut GitHubApiState, GitHubApiGraphqlRequest) !json2.Any

pub type GitHubApiGraphqlPage = fn (json2.Any) !GitHubApiPageInfo

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

fn github_api_credentials_type_from_string(value string) GitHubApiCredentialsType {
	return match value.trim_left(':') {
		'env_token' { .env_token }
		'github_cli_token' { .github_cli_token }
		'keychain_username_password' { .keychain_username_password }
		else { .none }
	}
}

pub struct GitHubApiCommitRequest {
pub:
	url            string
	request_method string
}

pub type GitHubApiCommitOpenRest = fn (GitHubApiCommitRequest) !json2.Any

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
