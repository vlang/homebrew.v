module utils

import ruby
import crypto.sha256
import net.urllib
import os

const curl_https_redirect_args = ['--proto-redir', '=https']
const curl_default_user_agent = 'Homebrew/curl'
const curl_browser_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/17.0 Safari/605.1.15'

pub struct CurlArgsOptions {
pub:
	extra_args         []string
	curlrc_present     bool
	curlrc             string
	connect_timeout    ?f64
	max_time           ?f64
	retries            int = 3
	retries_present    bool = true
	retry_max_time     ?f64
	show_output        bool
	show_error         bool = true
	cookies            map[string]string
	cookies_present    bool
	headers            []string
	referer            string
	user_agent         string = 'default'
	custom_user_agent  string
	verbose_context    bool
	quiet_context      bool
	curl_verbose       bool
	stdout_tty         bool = true
	default_user_agent string = curl_default_user_agent
	browser_user_agent string = curl_browser_user_agent
}

pub struct CurlCommandResult {
pub:
	stdout      string
	stderr      string
	exit_status int
	arguments   []string
}

pub fn (result CurlCommandResult) success() bool {
	return result.exit_status == 0
}

pub struct CurlResponse {
pub:
	status_code string
	status_text string
	headers     map[string][]string
}

pub struct CurlParsedOutput {
pub:
	responses []CurlResponse
	body      string
}

pub struct CurlHttpDetails {
pub:
	url            string
	final_url      string
	exit_status    int
	status_code    string
	headers        map[string][]string
	etag           string
	content_length string
	file_contents  string
	file_hash      string
	responses      []CurlResponse
}

pub struct CurlRuntime {
pub mut:
	path_cache    string
	version_cache map[string]string
pub:
	shim_path   string
	brewed_path string
	runner      ?fn(string, []string, map[string]string, ?f64) !CurlCommandResult
}

pub struct CurlCheckRequest {
pub:
	url               string
	url_type          string
	user_agents       []string = ['default']
	referer           string
	check_content     bool
	strict            bool
	no_insecure       bool
	details           []CurlHttpDetails
	secure_details    []CurlHttpDetails
	github_repository bool = true
}

pub struct CurlRunRequest {
pub:
	args              []string
	argument_options  CurlArgsOptions
	environment       map[string]string
	timeout           ?f64
	use_homebrew_curl bool
	no_insecure       bool
}

pub struct CurlDownloadRequest {
pub:
	args        []string
	destination string
	try_partial bool
	headers     map[string][]string
	run         CurlRunRequest
}

pub struct CurlDownloadResult {
pub:
	skipped bool
	command CurlCommandResult
}

pub struct CurlHeadersRequest {
pub:
	args           []string
	wanted_headers []string
	run            CurlRunRequest
	version        string
}

pub struct CurlFetchRequest {
pub:
	url               string
	specs             map[string]ruby.Value
	hash_needed       bool
	head_only         bool
	use_homebrew_curl bool
	user_agent        string = 'default'
	referer           string
}

pub type CurlContentFetcher = fn(CurlFetchRequest) !CurlHttpDetails

fn curl_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn curl_number_string(value f64, decimals int) string {
	mut rounded := value
	if decimals == 3 {
		rounded = f64(i64(value * 1000.0 + if value >= 0 { 0.5 } else { -0.5 })) / 1000.0
	} else {
		rounded = f64(i64(value + if value >= 0 { 0.5 } else { -0.5 }))
	}
	if rounded == f64(i64(rounded)) {
		return i64(rounded).str()
	}
	return rounded.str()
}

pub fn curl_executable(use_homebrew_curl bool, brewed_path string, shim_path string) string {
	return if use_homebrew_curl { brewed_path } else { shim_path }
}

pub fn (mut runtime CurlRuntime) executable(use_homebrew_curl bool) string {
	return curl_executable(use_homebrew_curl, runtime.brewed_path, runtime.shim_path)
}

pub fn (mut runtime CurlRuntime) path() !string {
	if runtime.path_cache != '' {
		return runtime.path_cache
	}
	runner := runtime.runner or { return error('Failed to get curl path') }
	result := runner(runtime.executable(false), ['--homebrew=print-path'], map[string]string{}, none)!
	path := result.stdout.trim_space()
	if path == '' {
		return error('Failed to get curl path')
	}
	runtime.path_cache = path
	return path
}

pub fn (mut runtime CurlRuntime) clear_path_cache() {
	runtime.path_cache = ''
}

pub fn curl_args(options CurlArgsOptions) ![]string {
	mut arguments := []string{}
	if options.curlrc_present {
		if options.curlrc.starts_with('/') {
			arguments << ['--disable', '--config', options.curlrc]
		}
	} else {
		arguments << '--disable'
	}
	mut cookie_values := []string{}
	mut cookie_keys := options.cookies.keys()
	cookie_keys.sort()
	for key in cookie_keys {
		cookie_values << '${key}=${options.cookies[key]}'
	}
	arguments << ['--cookie', if options.cookies_present || options.cookies.len > 0 {
		cookie_values.join(';')
	} else {
		os.path_devnull
	}]
	arguments << '--globoff'
	if options.show_error {
		arguments << '--show-error'
	}
	if options.user_agent != 'curl' {
		agent := match options.user_agent {
			'browser', 'fake' { options.browser_user_agent }
			'default', '' { options.default_user_agent }
			'string' { options.custom_user_agent }
			else {
				return error(':user_agent must be :browser/:fake, :default, :curl, or a String')
			}
		}
		arguments << ['--user-agent', agent]
	}
	arguments << ['--header', 'Accept-Language: en']
	for header in options.headers {
		arguments << ['--header', header.trim_space()]
	}
	if !options.show_output {
		arguments << '--fail'
		if !options.verbose_context {
			arguments << '--progress-bar'
		}
		if options.curl_verbose {
			arguments << '--verbose'
		}
		if !options.stdout_tty || options.quiet_context {
			arguments << '--silent'
		}
	}
	if timeout := options.connect_timeout {
		arguments << ['--connect-timeout', curl_number_string(timeout, 3)]
	}
	if timeout := options.max_time {
		arguments << ['--max-time', curl_number_string(timeout, 3)]
	}
	if options.retries_present && options.retries > 0 {
		arguments << ['--retry', options.retries.str()]
	}
	if timeout := options.retry_max_time {
		arguments << ['--retry-max-time', curl_number_string(timeout, 0)]
	}
	if options.referer != '' {
		arguments << ['--referer', options.referer]
	}
	arguments << options.extra_args
	return arguments
}

pub fn curl_insecure_redirect(url string, resolved_url string, no_insecure_redirect bool) bool {
	return no_insecure_redirect && url.starts_with('https://') && !resolved_url.starts_with('https://')
}

pub fn curl_no_insecure_redirect_args(input []string, no_insecure_redirect bool) []string {
	if !no_insecure_redirect {
		return input.clone()
	}
	mut filtered := []string{}
	for index, argument in input {
		if argument == '--proto-redir' || (index > 0 && input[index - 1] == '--proto-redir') || argument.starts_with('--proto-redir=') {
			continue
		}
		filtered << argument
	}
	if '--location' !in filtered {
		return filtered
	}
	mut result := curl_https_redirect_args.clone()
	result << filtered
	return result
}

pub fn curl_strip_progress_bar(input string) string {
	mut lines := []string{}
	for line in input.split_into_lines() {
		mut index := 0
		for index < line.len && (line[index] == `#` || line[index].is_space()) {
			index++
		}
		start_digits := index
		for index < line.len && line[index].is_digit() {
			index++
		}
		valid_digits := index > start_digits && index - start_digits <= 3
		if valid_digits && index + 2 < line.len && line[index] == `.` && line[index + 1].is_digit() && line[index + 2] == `%` {
			index += 3
			for index < line.len && line[index].is_space() {
				index++
			}
			lines << line[index..]
		} else {
			lines << line
		}
	}
	mut result := lines.join('\n')
	if input.ends_with('\n') {
		result += '\n'
	}
	return result
}

pub fn curl_http_status_ok(status ?string) bool {
	value := status or { return false }
	code := value.int()
	return code >= 100 && code <= 299
}

pub fn curl_parse_response(response_text string) CurlResponse {
	mut lines := response_text.replace('\r\n', '\n').split_into_lines()
	if lines.len == 0 || !lines[0].starts_with('HTTP/') {
		return CurlResponse{}
	}
	status_parts := lines[0].fields()
	if status_parts.len < 2 || status_parts[1].bytes().any(!it.is_digit()) {
		return CurlResponse{}
	}
	mut headers := map[string][]string{}
	for line in lines[1..] {
		separator := line.index(':') or { continue }
		name := line[..separator].trim_space().to_lower()
		if name == '' {
			continue
		}
		headers[name] << line[separator + 1..].trim_space()
	}
	return CurlResponse{
		status_code: status_parts[1]
		status_text: if status_parts.len > 2 { status_parts[2..].join(' ') } else { '' }
		headers: headers
	}
}

pub fn curl_parse_output(input string, max_iterations int) !CurlParsedOutput {
	mut output := input.trim_left(' \t\r\n')
	mut responses := []CurlResponse{}
	mut iterations := 0
	for output.starts_with('HTTP/') {
		mut separator := output.index('\r\n\r\n') or { -1 }
		mut separator_length := 4
		if separator < 0 {
			separator = output.index('\n\n') or { -1 }
			separator_length = 2
		}
		if separator < 0 {
			break
		}
		iterations++
		if iterations > max_iterations {
			return error('Too many redirects (max = ${max_iterations})')
		}
		response := curl_parse_response(output[..separator].trim_right('\r\n'))
		if response.status_code != '' {
			responses << response
		}
		output = output[separator + separator_length..].trim_left(' \t\r\n')
	}
	return CurlParsedOutput{
		responses: responses
		body: output
	}
}

fn curl_response_location(response CurlResponse) string {
	locations := response.headers['location'] or { return '' }
	return if locations.len == 0 { '' } else { locations[locations.len - 1] }
}

pub fn curl_join_url(base_url string, location string) string {
	base := urllib.parse(base_url) or { return location }
	reference := urllib.parse(location) or { return location }
	resolved := base.resolve_reference(&reference) or { return location }
	return resolved.str()
}

pub fn curl_response_last_location(responses []CurlResponse, absolutize bool,
	base_url string) ?string {
	for offset in 0 .. responses.len {
		response := responses[responses.len - 1 - offset]
		location := curl_response_location(response)
		if location == '' {
			continue
		}
		return if absolutize && base_url != '' {
			curl_join_url(base_url, location)
		} else {
			location
		}
	}
	return none
}

pub fn curl_response_follow_redirections(responses []CurlResponse, initial_url string) string {
	mut url := initial_url
	for response in responses {
		location := curl_response_location(response)
		if location != '' {
			url = curl_join_url(url, location)
		}
	}
	return url
}

pub fn curl_url_protected_by_cloudflare(response CurlResponse) bool {
	if response.headers.len == 0 || response.status_code !in ['403', '503'] {
		return false
	}
	servers := response.headers['server'] or { return false }
	return servers.any(it.to_lower().starts_with('cloudflare'))
}

pub fn curl_url_protected_by_incapsula(response CurlResponse) bool {
	if response.headers.len == 0 || response.status_code != '403' {
		return false
	}
	cookies := response.headers['set-cookie'] or { return false }
	return cookies.any(it.to_lower().starts_with('visid_incap_') || it.to_lower().starts_with('incap_ses_'))
}

pub fn curl_version_from_output(output string) !string {
	start := output.index('curl ') or { return error('Failed to parse curl version from ${output}') }
	rest := output[start + 5..]
	version := rest.fields()[0]
	if version == '' || version.bytes().any(!(it.is_digit() || it == `.`)) {
		return error('Failed to parse curl version from ${output}')
	}
	return version
}

pub fn curl_compare_versions(left string, right string) int {
	left_parts := left.split('.').map(it.int())
	right_parts := right.split('.').map(it.int())
	max_len := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. max_len {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
	}
	return 0
}

pub fn curl_with_workarounds(mut runtime CurlRuntime, request CurlRunRequest) !CurlCommandResult {
	runner := runtime.runner or { return error('curl command runner is required') }
	mut raw_args := curl_no_insecure_redirect_args(request.args, request.no_insecure)
	mut options := request.argument_options
	options = CurlArgsOptions{
		...options
		extra_args: raw_args
	}
	mut result := runner(runtime.executable(request.use_homebrew_curl), curl_args(options)!, request.environment, request.timeout)!
	if result.success() || '--http1.1' in raw_args {
		return result
	}
	if timeout := request.timeout {
		if timeout >= 0 && result.exit_status == 28 {
			last_line := result.stderr.trim_right('\r\n').split_into_lines().last()
			return error(last_line)
		}
	}
	if result.exit_status == 16 {
		raw_args << '--http1.1'
		options = CurlArgsOptions{
			...options
			extra_args: raw_args
		}
		return runner(runtime.executable(request.use_homebrew_curl), curl_args(options)!, request.environment, request.timeout)
	}
	if result.exit_status == 56 {
		version_result := runner(runtime.executable(request.use_homebrew_curl), ['-V'], map[string]string{}, none) or { return result }
		if version_result.stdout.contains('HTTP2') {
			version := curl_version_from_output(version_result.stdout) or { return result }
			if curl_compare_versions(version, '7.60.0') < 0 {
				raw_args << '--http1.1'
				options = CurlArgsOptions{
					...options
					extra_args: raw_args
				}
				return runner(runtime.executable(request.use_homebrew_curl), curl_args(options)!, request.environment, request.timeout)
			}
		}
	}
	return result
}

pub fn curl_command(mut runtime CurlRuntime, request CurlRunRequest) !CurlCommandResult {
	result := curl_with_workarounds(mut runtime, request)!
	if !result.success() {
		return error('curl failed with exit status ${result.exit_status}: ${result.stderr.trim_space()}')
	}
	return result
}

pub fn curl_output(mut runtime CurlRuntime, request CurlRunRequest) !CurlCommandResult {
	return curl_with_workarounds(mut runtime, CurlRunRequest{
		...request
		argument_options: CurlArgsOptions{
			...request.argument_options
			show_output: true
		}
	})
}

pub fn curl_download(mut runtime CurlRuntime, request CurlDownloadRequest) !CurlDownloadResult {
	os.mkdir_all(os.dir(request.destination))!
	mut args := ['--location']
	args << request.args
	if request.try_partial && os.exists(request.destination) {
		accept_ranges := request.headers['accept-ranges'] or { []string{} }
		content_lengths := request.headers['content-length'] or { []string{} }
		supports_partial := accept_ranges.len > 0 && accept_ranges.last() != 'none'
		content_length := if content_lengths.len > 0 { content_lengths.last().int() } else { -1 }
		if supports_partial {
			if content_length >= 0 && os.file_size(request.destination) == u64(content_length) {
				return CurlDownloadResult{ skipped: true }
			}
			mut continued_args := ['--continue-at', '-']
			continued_args << args
			args = continued_args.clone()
		}
	}
	mut output_args := ['--remote-time', '--output', request.destination]
	output_args << args
	args = output_args.clone()
	command := curl_command(mut runtime, CurlRunRequest{
		...request.run
		args: args
	})!
	return CurlDownloadResult{ command: command }
}

pub fn curl_headers(mut runtime CurlRuntime, request CurlHeadersRequest) !CurlParsedOutput {
	mut base_args := ['--fail', '--location', '--silent']
	mut retry_args := []string{}
	is_post := 'POST' in request.args
	if is_post {
		base_args << ['--dump-header', '-']
	} else {
		base_args << '--head'
		retry_args << ['--request', 'GET']
	}
	if curl_compare_versions(request.version, '8.7') >= 0 && curl_compare_versions(request.version, '8.10') < 0 {
		retry_args << '--http1.1'
	}
	for attempt in [([]string{}), retry_args] {
		mut args := base_args.clone()
		args << attempt
		args << request.args
		result := curl_output(mut runtime, CurlRunRequest{
			...request.run
			args: args
		})!
		if result.success() || result.exit_status in [8, 22, 56] {
			parsed := curl_parse_output(result.stdout, 25)!
			if is_post {
				return parsed
			}
			if attempt.len == 0 {
				mut wanted_found := request.wanted_headers.len == 0
				for response in parsed.responses {
					for wanted in request.wanted_headers {
						if wanted.to_lower() in response.headers {
							wanted_found = true
						}
					}
				}
				last_status := if parsed.responses.len > 0 {
					parsed.responses.last().status_code.int()
				} else {
					0
				}
				if !wanted_found || (last_status >= 400 && last_status <= 499) {
					continue
				}
			}
			if result.success() || result.exit_status == 8 {
				return parsed
			}
		}
		return error('curl failed with exit status ${result.exit_status}: ${result.stderr.trim_space()}')
	}
	return CurlParsedOutput{}
}

pub fn curl_http_content_args(request CurlFetchRequest, output_path string) []string {
	mut arguments := []string{}
	mut keys := request.specs.keys()
	keys.sort()
	for key in keys {
		value := request.specs[key]
		if value.type_name == 'Bool' && !value.bool_data {
			continue
		}
		arguments << '--${key.replace('_', '-')}'
		if value.type_name != 'Bool' || !value.bool_data {
			arguments << value.as_string()
		}
	}
	if request.head_only {
		arguments << '--head'
	} else {
		arguments << ['--dump-header', '-', '--output', output_path]
	}
	arguments << ['--location', request.url]
	return arguments
}

pub fn curl_http_content_headers_and_checksum(mut runtime CurlRuntime,
	request CurlFetchRequest) !CurlHttpDetails {
	temporary_path := os.join_path(os.temp_dir(), 'brew-v-curl-${os.getpid()}-${request.url.len}')
	defer {
		if os.exists(temporary_path) {
			os.rm(temporary_path) or {}
		}
	}
	args := curl_http_content_args(request, temporary_path)
	max_time := if request.hash_needed { 600.0 } else { 25.0 }
	result := curl_output(mut runtime, CurlRunRequest{
		args: args
		argument_options: CurlArgsOptions{
			connect_timeout: 15.0
			max_time: max_time
			retry_max_time: max_time
			user_agent: request.user_agent
			referer: request.referer
		}
		use_homebrew_curl: request.use_homebrew_curl
	})!
	parsed := curl_parse_output(result.stdout, 25)!
	mut status_code := ''
	mut headers := map[string][]string{}
	if parsed.responses.len > 0 {
		status_code = parsed.responses.last().status_code
		headers = parsed.responses.last().headers.clone()
	}
	etags := headers['etag'] or { []string{} }
	mut etag := ''
	if etags.len > 0 {
		mut raw_etag := etags.last()
		if raw_etag.to_lower().starts_with('w/') {
			raw_etag = raw_etag[2..]
		}
		if raw_etag.len >= 2 && raw_etag[0] == `"` {
			end := raw_etag.last_index('"') or { -1 }
			if end > 0 {
				etag = raw_etag[1..end]
			}
		}
	}
	lengths := headers['content-length'] or { []string{} }
	mut contents := ''
	mut digest := ''
	if !request.head_only && result.success() && os.exists(temporary_path) {
		bytes := os.read_bytes(temporary_path)!
		if request.hash_needed {
			digest = sha256.sum256(bytes).hex()
		}
		if bytes.len <= 100 * 1024 * 1024 {
			contents = bytes.bytestr()
		}
	}
	return CurlHttpDetails{
		url: request.url
		final_url: curl_response_last_location(parsed.responses, false, '') or { '' }
		exit_status: result.exit_status
		status_code: status_code
		headers: headers
		etag: etag
		content_length: if lengths.len > 0 { lengths.last() } else { '' }
		file_contents: contents
		file_hash: digest
		responses: parsed.responses
	}
}

fn curl_normalize_protocols(input string) string {
	return input.replace('https://', '/').replace('http://', '/').replace('https:\\/\\/', '/').replace('http:\\/\\/', '/')
}

pub fn curl_check_http_content(request CurlCheckRequest, fetch CurlContentFetcher) !string {
	if !request.url.starts_with('http') {
		return ''
	}
	secure_url := if request.url.starts_with('http:') {
		'https:' + request.url[5..]
	} else {
		request.url
	}
	mut secure := CurlHttpDetails{}
	mut has_secure := false
	mut hash_needed := false
	mut agents := request.user_agents.clone()
	if request.url != secure_url {
		for agent in agents {
			candidate := fetch(CurlFetchRequest{
				url: secure_url
				hash_needed: true
				user_agent: agent
				referer: request.referer
			}) or { continue }
			secure = candidate
			has_secure = true
			if curl_http_status_ok(candidate.status_code) {
				hash_needed = true
				agents = [agent]
				break
			}
		}
	}
	mut details := CurlHttpDetails{}
	mut attempts := 0
	mut found := false
	mut head_only := request.url == secure_url
	for agent in agents {
		for {
			details = fetch(CurlFetchRequest{
				url: request.url
				hash_needed: hash_needed
				head_only: head_only
				user_agent: agent
				referer: request.referer
			})!
			found = true
			head_rejected := if details.status_code != '' {
				!curl_http_status_ok(details.status_code)
			} else {
				details.exit_status in [28, 52, 56]
			}
			if head_only && head_rejected {
				head_only = false
				continue
			}
			if details.exit_status !in [52, 56] {
				break
			}
			attempts++
			if attempts >= 3 {
				break
			}
		}
		if curl_http_status_ok(details.status_code) {
			break
		}
	}
	if !found || details.status_code == '' {
		return 'The ${request.url_type} ${request.url} is not reachable'
	}
	if !curl_http_status_ok(details.status_code) {
		for response in details.responses {
			if curl_url_protected_by_cloudflare(response) || curl_url_protected_by_incapsula(response) {
				return ''
			}
		}
		return 'The ${request.url_type} ${request.url} is not reachable (HTTP status code ${details.status_code})'
	}
	if details.final_url != '' && curl_insecure_redirect(request.url, details.final_url, request.no_insecure) {
		return 'The ${request.url_type} ${request.url} redirects back to HTTP'
	}
	if !has_secure || !curl_http_status_ok(secure.status_code) {
		return ''
	}
	matching_metadata := (details.etag != '' && details.etag == secure.etag) || (details.content_length != '' && details.content_length == secure.content_length) || details.file_hash == secure.file_hash
	https_available := request.url.starts_with('http://') && secure.final_url.starts_with('https://')
	if matching_metadata && https_available {
		return 'The ${request.url_type} ${request.url} should use HTTPS rather than HTTP'
	}
	if !request.check_content {
		return ''
	}
	http_content := curl_normalize_protocols(details.file_contents)
	https_content := curl_normalize_protocols(secure.file_contents)
	if http_content == https_content && https_available {
		return 'The ${request.url_type} ${request.url} should use HTTPS rather than HTTP'
	}
	if !request.strict || http_content.len == 0 {
		return ''
	}
	if http_content.len == https_content.len {
		return 'The ${request.url_type} ${request.url} may be able to use HTTPS rather than HTTP. Please verify it in a browser.'
	}
	ratio := https_content.len * 100 / http_content.len
	if ratio >= 90 && ratio <= 110 {
		return 'The ${request.url_type} ${request.url} may be able to use HTTPS rather than HTTP. Please verify it in a browser.'
	}
	return ''
}

pub fn (mut runtime CurlRuntime) version() !string {
	path := runtime.path()!
	if cached := runtime.version_cache[path] {
		return cached
	}
	runner := runtime.runner or { return error('curl command runner is required') }
	result := runner(runtime.executable(false), ['-V'], map[string]string{}, none)!
	version := curl_version_from_output(result.stdout)!
	runtime.version_cache[path] = version
	return version
}

pub fn curl_supports_fail_with_body(version string) bool {
	return curl_compare_versions(version, '7.76.0') >= 0
}

pub fn curl_supports_tls13(result CurlCommandResult) bool {
	return result.success()
}

pub fn curl_response_value(response CurlResponse) ruby.Value {
	mut header_values := map[string]ruby.Value{}
	for name, values in response.headers {
		header_values[name] = if values.len == 1 {
			ruby.string_value(values[0])
		} else {
			ruby.string_array_value(values)
		}
	}
	mut values := {
		'status_code': ruby.string_value(response.status_code)
		'headers':     ruby.map_value(header_values)
	}
	if response.status_text != '' {
		values['status_text'] = ruby.string_value(response.status_text)
	}
	return ruby.map_value(values)
}

pub fn curl_response_from_value(value ruby.Value) CurlResponse {
	values := value.map_data.clone()
	mut headers := map[string][]string{}
	if header_value := values['headers'] {
		for name, raw in header_value.map_data {
			headers[name] = if raw.type_name == 'Array' {
				raw.as_array() or { [] }.map(it.as_string())
			} else {
				[raw.as_string()]
			}
		}
	}
	return CurlResponse{
		status_code: (values['status_code'] or { ruby.string_value('') }).as_string()
		status_text: (values['status_text'] or { ruby.string_value('') }).as_string()
		headers: headers
	}
}

pub fn curl_parsed_output_value(parsed CurlParsedOutput) ruby.Value {
	return ruby.map_value({
		'responses': ruby.array_value(parsed.responses.map(curl_response_value(it)))
		'body':      ruby.string_value(parsed.body)
	})
}

fn curl_result_from_value(value ruby.Value) CurlCommandResult {
	values := value.map_data.clone()
	return CurlCommandResult{
		stdout: (values['stdout'] or { ruby.string_value(value.repr) }).as_string()
		stderr: (values['stderr'] or { ruby.string_value('') }).as_string()
		exit_status: int((values['exit_status'] or { ruby.int_value(0) }).int_data)
		arguments: (values['arguments'] or { ruby.string_array_value([]) }).as_array() or {
			[]}.map(it.as_string())
	}
}

fn curl_result_value(result CurlCommandResult) ruby.Value {
	return ruby.map_value({
		'stdout':      ruby.string_value(result.stdout)
		'stderr':      ruby.string_value(result.stderr)
		'exit_status': ruby.int_value(result.exit_status)
		'arguments':   ruby.string_array_value(result.arguments)
	})
}

fn curl_options_from_value(value ruby.Value) CurlArgsOptions {
	values := value.map_data.clone()
	mut cookies := map[string]string{}
	if cookie_value := values['cookies'] {
		for key, item in cookie_value.map_data {
			cookies[key] = item.as_string()
		}
	}
	headers := if header_value := values['header'] {
		if header_value.type_name == 'Array' {
			header_value.as_array() or { [] }.map(it.as_string())
		} else {
			[header_value.as_string()]
		}
	} else {
		[]string{}
	}
	user_agent_value := values['user_agent'] or { ruby.object_value('Symbol', 'default') }
	user_agent := if user_agent_value.type_name == 'String' {
		'string'
	} else {
		user_agent_value.as_string()
	}
	custom_user_agent := if user_agent_value.type_name == 'String' {
		user_agent_value.as_string()
	} else {
		(values['custom_user_agent'] or { ruby.string_value('') }).as_string()
	}
	return CurlArgsOptions{
		extra_args: (values['args'] or { ruby.string_array_value([]) }).as_array() or {
			[]}.map(it.as_string())
		curlrc_present: 'curlrc' in values
		curlrc: (values['curlrc'] or { ruby.string_value('') }).as_string()
		connect_timeout: if item := values['connect_timeout'] {
			item.as_float() or { 0.0 }} else {
			none}
		max_time: if item := values['max_time'] { item.as_float() or { 0.0 } } else { none }
		retries: int((values['retries'] or { ruby.int_value(3) }).int_data)
		retries_present: if item := values['retries'] { item.type_name != 'NilClass' } else { true }
		retry_max_time: if item := values['retry_max_time'] {
			item.as_float() or { 0.0 }} else {
			none}
		show_output: (values['show_output'] or { ruby.bool_value(false) }).bool_data
		show_error: (values['show_error'] or { ruby.bool_value(true) }).bool_data
		cookies: cookies
		cookies_present: 'cookies' in values
		headers: headers
		referer: (values['referer'] or { ruby.string_value('') }).as_string()
		user_agent: user_agent
		custom_user_agent: custom_user_agent
		verbose_context: (values['verbose'] or { ruby.bool_value(false) }).bool_data
		quiet_context: (values['quiet'] or { ruby.bool_value(false) }).bool_data
		curl_verbose: (values['curl_verbose'] or { ruby.bool_value(false) }).bool_data
		stdout_tty: (values['stdout_tty'] or { ruby.bool_value(true) }).bool_data
	}
}

fn curl_boundary_strings(args []ruby.Value) []string {
	mut values := []string{}
	for argument in args {
		if argument.type_name == 'Array' {
			values << argument.as_array() or { [] }.map(it.as_string())
		} else if argument.type_name != 'Hash' {
			values << argument.as_string()
		}
	}
	return values
}

// Translated from Homebrew/brew `utils/curl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `curl_executable(use_homebrew_curl: false)` at line 77.
pub fn ruby_curl_l77_d1_curl_executable(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { args[0].map_data } else { map[string]ruby.Value{} }
	use_brewed := (options['use_homebrew_curl'] or { ruby.bool_value(false) }).bool_data
	brewed := (options['brewed_path'] or { ruby.string_value('/homebrew/curl') }).as_string()
	shim := (options['shim_path'] or { ruby.string_value('shared/curl') }).as_string()
	return ruby.string_value(curl_executable(use_brewed, brewed, shim))
}

// Ruby method `curl_path` at line 84.
pub fn ruby_curl_l84_d2_curl_path(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string().trim_space() } else { '' }
	if path == '' {
		panic('Failed to get curl path')
	}
	return ruby.string_value(path)
}

// Ruby method `clear_path_cache` at line 94.
pub fn ruby_curl_l94_d3_clear_path_cache(args ...ruby.Value) ruby.Value {
	return curl_nil_value()
}

// Ruby method `curl_args(` at line 113.
pub fn ruby_curl_l113_d4_curl_args(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 && args.last().type_name == 'Hash' {
		curl_options_from_value(args.last())
	} else {
		CurlArgsOptions{ extra_args: curl_boundary_strings(args) }
	}
	return ruby.string_array_value(curl_args(options) or { panic(err) })
}

// Ruby method `insecure_redirect?(url:, resolved_url:)` at line 193.
pub fn ruby_curl_l193_d5_insecure_redirect(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { args[0].map_data } else { map[string]ruby.Value{} }
	url := (options['url'] or { ruby.string_value('') }).as_string()
	resolved := (options['resolved_url'] or { ruby.string_value('') }).as_string()
	policy := (options['no_insecure_redirect'] or { ruby.bool_value(true) }).bool_data
	return ruby.bool_value(curl_insecure_redirect(url, resolved, policy))
}

// Ruby method `https_redirect_curl_args` at line 199.
pub fn ruby_curl_l199_d6_https_redirect_curl_args(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(curl_https_redirect_args.clone())
}

// Ruby method `no_insecure_redirect_curl_args(args)` at line 204.
pub fn ruby_curl_l204_d7_no_insecure_redirect_curl_args(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_array() or { [] }.map(it.as_string())
	} else {
		[]string{}
	}
	policy := if args.len > 1 { args[1].bool_data } else { true }
	return ruby.string_array_value(curl_no_insecure_redirect_args(values, policy))
}

// Ruby method `curl_with_workarounds(` at line 239.
pub fn ruby_curl_l239_d8_curl_with_workarounds(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('curl_with_workarounds requires a command result')
	}
	result := curl_result_from_value(args.last())
	if result.exit_status == 28 {
		panic(result.stderr.trim_space())
	}
	return curl_result_value(result)
}

// Ruby method `curl(*args, print_stdout: true, **options)` at line 297.
pub fn ruby_curl_l297_d9_curl(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('curl requires a command result')
	}
	result := curl_result_from_value(args.last())
	if !result.success() {
		panic('curl failed with exit status ${result.exit_status}: ${result.stderr.trim_space()}')
	}
	return curl_result_value(result)
}

// Ruby method `curl_download(*args, to:, try_partial: false, **options)` at line 311.
pub fn ruby_curl_l311_d10_curl_download(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { args.last().map_data } else { map[string]ruby.Value{} }
	destination := (options['to'] or { ruby.string_value('') }).as_string()
	if destination == '' {
		panic('curl_download requires `to`')
	}
	os.mkdir_all(os.dir(destination)) or { panic(err) }
	mut command_args := ['--remote-time', '--output', destination, '--location']
	command_args << curl_boundary_strings(args[..args.len - 1])
	return ruby.string_array_value(command_args)
}

// Ruby method `strip_progress_bar(string)` at line 346.
pub fn ruby_curl_l346_d11_strip_progress_bar(args ...ruby.Value) ruby.Value {
	return ruby.string_value(curl_strip_progress_bar(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `curl_output(*args, **options)` at line 351.
pub fn ruby_curl_l351_d12_curl_output(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return curl_result_value(CurlCommandResult{})
	}
	return curl_result_value(curl_result_from_value(args.last()))
}

// Ruby method `curl_headers(*args, wanted_headers: [], **options)` at line 362.
pub fn ruby_curl_l362_d13_curl_headers(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return curl_parsed_output_value(CurlParsedOutput{})
	}
	result := curl_result_from_value(args.last())
	return curl_parsed_output_value(curl_parse_output(result.stdout, 25) or { panic(err) })
}

// Ruby method `url_protected_by_cloudflare?(response)` at line 412.
pub fn ruby_curl_l412_d14_url_protected_by_cloudflare(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && curl_url_protected_by_cloudflare(curl_response_from_value(args[0])))
}

// Ruby method `url_protected_by_incapsula?(response)` at line 424.
pub fn ruby_curl_l424_d15_url_protected_by_incapsula(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && curl_url_protected_by_incapsula(curl_response_from_value(args[0])))
}

// Ruby method `curl_check_http_content(url, url_type, specs: {}, user_agents: [:default], referer: nil,` at line 444.
pub fn ruby_curl_l444_d16_curl_check_http_content(args ...ruby.Value) ruby.Value {
	if args.len == 0 || !args[0].as_string().starts_with('http') {
		return curl_nil_value()
	}
	url_type := if args.len > 1 { args[1].as_string() } else { 'URL' }
	if args.len < 3 || args[2].type_name == 'NilClass' {
		return ruby.string_value('The ${url_type} ${args[0].as_string()} is not reachable')
	}
	details := args[2].map_data.clone()
	status := (details['status_code'] or { ruby.string_value('') }).as_string()
	if status == '' {
		return ruby.string_value('The ${url_type} ${args[0].as_string()} is not reachable')
	}
	if !curl_http_status_ok(status) {
		return ruby.string_value('The ${url_type} ${args[0].as_string()} is not reachable (HTTP status code ${status})')
	}
	return curl_nil_value()
}

// Ruby method `curl_http_content_headers_and_checksum(` at line 605.
pub fn ruby_curl_l605_d17_curl_http_content_headers_and_checksum(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('curl_http_content_headers_and_checksum requires a URL')
	}
	options := if args.len > 1 { args[1].map_data } else { map[string]ruby.Value{} }
	request := CurlFetchRequest{
		url: args[0].as_string()
		head_only: (options['head_only'] or { ruby.bool_value(false) }).bool_data
		hash_needed: (options['hash_needed'] or { ruby.bool_value(false) }).bool_data
	}
	return ruby.string_array_value(curl_http_content_args(request, (options['output'] or { ruby.string_value('temporary-file') }).as_string()))
}

// Ruby method `curl_version` at line 698.
pub fn ruby_curl_l698_d18_curl_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('curl_version requires curl -V output')
	}
	return ruby.string_value(curl_version_from_output(args[0].as_string()) or { panic(err) })
}

// Ruby method `curl_supports_fail_with_body?` at line 710.
pub fn ruby_curl_l710_d19_curl_supports_fail_with_body(args ...ruby.Value) ruby.Value {
	version := if args.len > 0 { args[0].as_string() } else { '0' }
	return ruby.bool_value(curl_supports_fail_with_body(version))
}

// Ruby method `curl_supports_tls13?` at line 718.
pub fn ruby_curl_l718_d20_curl_supports_tls13(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && curl_supports_tls13(curl_result_from_value(args[0])))
}

// Ruby method `http_status_ok?(status)` at line 726.
pub fn ruby_curl_l726_d21_http_status_ok(args ...ruby.Value) ruby.Value {
	status := if args.len == 0 || args[0].type_name == 'NilClass' {
		none
	} else {
		?string(args[0].as_string())
	}
	return ruby.bool_value(curl_http_status_ok(status))
}

// Ruby method `parse_curl_output(output, max_iterations: 25)` at line 745.
pub fn ruby_curl_l745_d22_parse_curl_output(args ...ruby.Value) ruby.Value {
	output := if args.len > 0 { args[0].as_string() } else { '' }
	maximum := if args.len > 1 { int(args[1].int_data) } else { 25 }
	return curl_parsed_output_value(curl_parse_output(output, maximum) or { panic(err) })
}

// Ruby method `curl_response_last_location(responses, absolutize: false, base_url: nil)` at line 782.
pub fn ruby_curl_l782_d23_curl_response_last_location(args ...ruby.Value) ruby.Value {
	responses := if args.len > 0 {
		args[0].as_array() or { [] }.map(curl_response_from_value(it))
	} else {
		[]CurlResponse{}
	}
	options := if args.len > 1 { args[1].map_data } else { map[string]ruby.Value{} }
	location := curl_response_last_location(responses, (options['absolutize'] or { ruby.bool_value(false) }).bool_data, (options['base_url'] or { ruby.string_value('') }).as_string()) or {
		return curl_nil_value()
	}
	return ruby.string_value(location)
}

// Ruby method `curl_response_follow_redirections(responses, base_url)` at line 807.
pub fn ruby_curl_l807_d24_curl_response_follow_redirections(args ...ruby.Value) ruby.Value {
	responses := if args.len > 0 {
		args[0].as_array() or { [] }.map(curl_response_from_value(it))
	} else {
		[]CurlResponse{}
	}
	base := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_value(curl_response_follow_redirections(responses, base))
}

// Ruby method `parse_curl_response(response_text)` at line 830.
pub fn ruby_curl_l830_d25_parse_curl_response(args ...ruby.Value) ruby.Value {
	response := curl_parse_response(if args.len > 0 { args[0].as_string() } else { '' })
	if response.status_code == '' {
		return ruby.map_value(map[string]ruby.Value{})
	}
	return curl_response_value(response)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "utils/timer"
// 7: require "system_command"
// 8:
// 9: module Utils
// 10:   # Helper function for interacting with `curl`.
// 11:   module Curl
// 12:     include SystemCommand::Mixin
// 13:     extend SystemCommand::Mixin
// 14:     include Utils::Output::Mixin
// 15:     extend Utils::Output::Mixin
// 16:     extend T::Helpers
// 17:
// 18:     requires_ancestor { Kernel }
// 19:
// 20:     # Error returned when the server sent data curl could not parse.
// 21:     CURL_WEIRD_SERVER_REPLY_EXIT_CODE = 8
// 22:
// 23:     # Error returned when `--fail` is used and the HTTP server returns an error
// 24:     # code that is >= 400.
// 25:     CURL_HTTP_RETURNED_ERROR_EXIT_CODE = 22
// 26:
// 27:     # Error returned when an operation took longer than the given timeout.
// 28:     CURL_OPERATION_TIMEOUT_EXIT_CODE = 28
// 29:
// 30:     # Error returned when the server closed the connection without replying.
// 31:     CURL_GOT_NOTHING_EXIT_CODE = 52
// 32:
// 33:     # Error returned when curl gets an error from the lowest networking layers
// 34:     # that the receiving of data failed.
// 35:     CURL_RECV_ERROR_EXIT_CODE = 56
// 36:
// 37:     # Failures that can occur after the request has been sent.
// 38:     CURL_REQUEST_SENT_EXIT_CODES = T.let([
// 39:       CURL_OPERATION_TIMEOUT_EXIT_CODE,
// 40:       CURL_GOT_NOTHING_EXIT_CODE,
// 41:       CURL_RECV_ERROR_EXIT_CODE,
// 42:     ].freeze, T::Array[Integer])
// 43:
// 44:     # This regex is used to extract the part of an ETag within quotation marks,
// 45:     # ignoring any leading weak validator indicator (`W/`). This simplifies
// 46:     # ETag comparison in `#curl_check_http_content`.
// 47:     ETAG_VALUE_REGEX = %r{^(?:[wW]/)?"((?:[^"]|\\")*)"}
// 48:
// 49:     # HTTP responses and body content are typically separated by a double
// 50:     # `CRLF` (whereas HTTP header lines are separated by a single `CRLF`).
// 51:     # In rare cases, this can also be a double newline (`\n\n`).
// 52:     HTTP_RESPONSE_BODY_SEPARATOR = "\r\n\r\n"
// 53:
// 54:     # This regex is used to isolate the parts of an HTTP status line, namely
// 55:     # the status code and any following descriptive text (e.g. `Not Found`).
// 56:     HTTP_STATUS_LINE_REGEX = %r{^HTTP/.* (?<code>\d+)(?: (?<text>[^\r\n]+))?}
// 57:
// 58:     HTTPS_REDIRECT_CURL_ARGS = ["--proto-redir", "=https"].freeze
// 59:
// 60:     # A `--progress-bar` percentage (e.g. "50.0%"); may belong to an earlier,
// 61:     # unrelated request, so it's stripped rather than kept.
// 62:     PROGRESS_BAR_REGEX = /\A#*\s*\d{1,3}\.\d%\s*/
// 63:
// 64:     private_constant :CURL_WEIRD_SERVER_REPLY_EXIT_CODE,
// 65:                      :CURL_HTTP_RETURNED_ERROR_EXIT_CODE,
// 66:                      :CURL_RECV_ERROR_EXIT_CODE,
// 67:                      :CURL_OPERATION_TIMEOUT_EXIT_CODE,
// 68:                      :CURL_GOT_NOTHING_EXIT_CODE,
// 69:                      :CURL_REQUEST_SENT_EXIT_CODES,
// 70:                      :ETAG_VALUE_REGEX, :HTTP_RESPONSE_BODY_SEPARATOR,
// 71:                      :HTTP_STATUS_LINE_REGEX,
// 72:                      :HTTPS_REDIRECT_CURL_ARGS, :PROGRESS_BAR_REGEX
// 73:
// 74:     module_function
// 75:
// 76:     sig { params(use_homebrew_curl: T::Boolean).returns(T.any(Pathname, String)) }
// 77:     def curl_executable(use_homebrew_curl: false)
// 78:       return HOMEBREW_BREWED_CURL_PATH if use_homebrew_curl
// 79:
// 80:       @curl_executable ||= T.let(HOMEBREW_SHIMS_PATH/"shared/curl", T.nilable(T.any(Pathname, String)))
// 81:     end
// 82:
// 83:     sig { returns(String) }
// 84:     def curl_path
// 85:       @curl_path ||= T.let(
// 86:         Utils.popen_read(curl_executable, "--homebrew=print-path").chomp,
// 87:         T.nilable(String),
// 88:       )
// 89:       odie("Failed to get curl path") if @curl_path.blank?
// 90:       @curl_path
// 91:     end
// 92:
// 93:     sig { void }
// 94:     def clear_path_cache
// 95:       @curl_path = nil
// 96:     end
// 97:
// 98:     sig {
// 99:       params(
// 100:         extra_args:      String,
// 101:         connect_timeout: T.nilable(T.any(Integer, Float)),
// 102:         max_time:        T.nilable(T.any(Integer, Float)),
// 103:         retries:         T.nilable(Integer),
// 104:         retry_max_time:  T.nilable(T.any(Integer, Float)),
// 105:         show_output:     T.nilable(T::Boolean),
// 106:         show_error:      T.nilable(T::Boolean),
// 107:         cookies:         T.nilable(T::Hash[String, String]),
// 108:         header:          T.nilable(T.any(String, T::Array[String])),
// 109:         referer:         T.nilable(String),
// 110:         user_agent:      T.nilable(T.any(String, Symbol)),
// 111:       ).returns(T::Array[String])
// 112:     }
// 113:     def curl_args(
// 114:       *extra_args,
// 115:       connect_timeout: nil,
// 116:       max_time: nil,
// 117:       retries: Homebrew::EnvConfig.curl_retries.to_i,
// 118:       retry_max_time: nil,
// 119:       show_output: false,
// 120:       show_error: true,
// 121:       cookies: nil,
// 122:       header: nil,
// 123:       referer: nil,
// 124:       user_agent: nil
// 125:     )
// 126:       args = []
// 127:
// 128:       # do not load .curlrc unless requested (must be the first argument)
// 129:       curlrc = Homebrew::EnvConfig.curlrc
// 130:       if curlrc&.start_with?("/")
// 131:         # If the file exists, we still want to disable loading the default curlrc.
// 132:         args << "--disable" << "--config" << curlrc
// 133:       elsif curlrc
// 134:         # This matches legacy behavior: `HOMEBREW_CURLRC` was a bool,
// 135:         # omitting `--disable` when present.
// 136:       else
// 137:         args << "--disable"
// 138:       end
// 139:
// 140:       args << "--cookie" << if cookies
// 141:         cookies.map { |k, v| "#{k}=#{v}" }.join(";")
// 142:       else
// 143:         # Echo any cookies received on a redirect
// 144:         File::NULL
// 145:       end
// 146:
// 147:       args << "--globoff"
// 148:
// 149:       args << "--show-error" if show_error
// 150:
// 151:       if user_agent != :curl
// 152:         args << "--user-agent" << case user_agent
// 153:         when :browser, :fake
// 154:           HOMEBREW_USER_AGENT_FAKE_SAFARI
// 155:         when :default, nil
// 156:           HOMEBREW_USER_AGENT_CURL
// 157:         when String
// 158:           user_agent
// 159:         else
// 160:           raise TypeError, ":user_agent must be :browser/:fake, :default, :curl, or a String"
// 161:         end
// 162:       end
// 163:
// 164:       args << "--header" << "Accept-Language: en"
// 165:       case header
// 166:       when String
// 167:         args << "--header" << header
// 168:       when Array
// 169:         header.each { |h| args << "--header" << h.strip }
// 170:       end
// 171:
// 172:       if show_output != true
// 173:         args << "--fail"
// 174:         args << "--progress-bar" unless Context.current.verbose?
// 175:         args << "--verbose" if Homebrew::EnvConfig.curl_verbose?
// 176:         args << "--silent" if !$stdout.tty? || Context.current.quiet?
// 177:       end
// 178:
// 179:       args << "--connect-timeout" << connect_timeout.round(3) if connect_timeout.present?
// 180:       args << "--max-time" << max_time.round(3) if max_time.present?
// 181:
// 182:       # A non-positive integer (e.g. 0) or `nil` will omit this argument
// 183:       args << "--retry" << retries if retries&.positive?
// 184:
// 185:       args << "--retry-max-time" << retry_max_time.round if retry_max_time.present?
// 186:
// 187:       args << "--referer" << referer if referer.present?
// 188:
// 189:       (args + extra_args).map(&:to_s)
// 190:     end
// 191:
// 192:     sig { params(url: String, resolved_url: String).returns(T::Boolean) }
// 193:     def insecure_redirect?(url:, resolved_url:)
// 194:       Homebrew::EnvConfig.no_insecure_redirect? &&
// 195:         url.start_with?("https://") && !resolved_url.start_with?("https://")
// 196:     end
// 197:
// 198:     sig { returns(T::Array[String]) }
// 199:     def https_redirect_curl_args
// 200:       HTTPS_REDIRECT_CURL_ARGS
// 201:     end
// 202:
// 203:     sig { params(args: T::Array[String]).returns(T::Array[String]) }
// 204:     def no_insecure_redirect_curl_args(args)
// 205:       return args unless Homebrew::EnvConfig.no_insecure_redirect?
// 206:
// 207:       # `--proto-redir =https` tells `curl --location` to reject any redirect
// 208:       # target that is not HTTPS. Drop caller-provided values first so they
// 209:       # cannot relax the HTTPS-only redirect policy.
// 210:       args = args.each_with_index.filter_map do |arg, i|
// 211:         next if arg == "--proto-redir"
// 212:         next if i.positive? && args.fetch(i - 1) == "--proto-redir"
// 213:         next if arg.start_with?("--proto-redir=")
// 214:
// 215:         arg
// 216:       end
// 217:       return args unless args.include?("--location")
// 218:
// 219:       # This blocks an HTTPS request from following a redirect to HTTP at the
// 220:       # curl layer, including cases where a preflight request saw a different
// 221:       # redirect chain than the real download.
// 222:       [*https_redirect_curl_args, *args]
// 223:     end
// 224:
// 225:     sig {
// 226:       params(
// 227:         args:              String,
// 228:         secrets:           T.any(String, T::Array[String]),
// 229:         print_stdout:      T.any(T::Boolean, Symbol),
// 230:         print_stderr:      T.any(T::Boolean, Symbol),
// 231:         debug:             T.nilable(T::Boolean),
// 232:         verbose:           T.nilable(T::Boolean),
// 233:         env:               T::Hash[String, String],
// 234:         timeout:           T.nilable(T.any(Integer, Float)),
// 235:         use_homebrew_curl: T::Boolean,
// 236:         options:           T.untyped,
// 237:       ).returns(SystemCommand::Result)
// 238:     }
// 239:     def curl_with_workarounds(
// 240:       *args,
// 241:       secrets: [], print_stdout: false, print_stderr: false, debug: nil,
// 242:       verbose: nil, env: {}, timeout: nil, use_homebrew_curl: false, **options
// 243:     )
// 244:       args = no_insecure_redirect_curl_args(args)
// 245:       end_time = Time.now + timeout if timeout
// 246:
// 247:       command_options = {
// 248:         secrets:,
// 249:         print_stdout:,
// 250:         print_stderr:,
// 251:         debug:,
// 252:         verbose:,
// 253:       }.compact
// 254:
// 255:       result = system_command curl_executable(use_homebrew_curl:),
// 256:                               args:    curl_args(*args, **options),
// 257:                               env:,
// 258:                               timeout: Utils::Timer.remaining(end_time),
// 259:                               **command_options
// 260:
// 261:       return result if result.success? || args.include?("--http1.1")
// 262:
// 263:       raise Timeout::Error, result.stderr.lines.fetch(-1).chomp if timeout && result.status.exitstatus == 28
// 264:
// 265:       # Error in the HTTP2 framing layer
// 266:       if result.exit_status == 16
// 267:         return curl_with_workarounds(
// 268:           *args, "--http1.1",
// 269:           timeout: Utils::Timer.remaining(end_time), **command_options, **options
// 270:         )
// 271:       end
// 272:
// 273:       # This is a workaround for https://github.com/curl/curl/issues/1618.
// 274:       if result.exit_status == 56 # Unexpected EOF
// 275:         out = curl_output("-V").stdout
// 276:
// 277:         # If `curl` doesn't support HTTP2, the exception is unrelated to this bug.
// 278:         return result unless out.include?("HTTP2")
// 279:
// 280:         # The bug is fixed in `curl` >= 7.60.0.
// 281:         curl_version = out[/curl (\d+(\.\d+)+)/, 1]
// 282:         return result if Gem::Version.new(curl_version) >= Gem::Version.new("7.60.0")
// 283:
// 284:         return curl_with_workarounds(*args, "--http1.1", **command_options, **options)
// 285:       end
// 286:
// 287:       result
// 288:     end
// 289:
// 290:     sig {
// 291:       overridable.params(
// 292:         args:         String,
// 293:         print_stdout: T.any(T::Boolean, Symbol),
// 294:         options:      T.untyped,
// 295:       ).returns(SystemCommand::Result)
// 296:     }
// 297:     def curl(*args, print_stdout: true, **options)
// 298:       result = curl_with_workarounds(*args, print_stdout:, **options)
// 299:       result.assert_success!
// 300:       result
// 301:     end
// 302:
// 303:     sig {
// 304:       params(
// 305:         args:        String,
// 306:         to:          T.any(Pathname, String),
// 307:         try_partial: T::Boolean,
// 308:         options:     T.untyped,
// 309:       ).returns(T.nilable(SystemCommand::Result))
// 310:     }
// 311:     def curl_download(*args, to:, try_partial: false, **options)
// 312:       destination = Pathname(to)
// 313:       destination.dirname.mkpath
// 314:
// 315:       args = ["--location", *args]
// 316:
// 317:       if try_partial && destination.exist?
// 318:         headers = begin
// 319:           parsed_output = curl_headers(*args, **options, wanted_headers: ["accept-ranges"])
// 320:           parsed_output.fetch(:responses).last&.fetch(:headers) || {}
// 321:         rescue ErrorDuringExecution
// 322:           # Ignore errors here and let actual download fail instead.
// 323:           {}
// 324:         end
// 325:
// 326:         # Any value for `Accept-Ranges` other than `none` indicates that the server
// 327:         # supports partial requests. Its absence indicates no support.
// 328:         supports_partial = headers.fetch("accept-ranges", "none") != "none"
// 329:         content_length = headers["content-length"]&.to_i
// 330:
// 331:         if supports_partial
// 332:           # We've already downloaded all bytes.
// 333:           return if destination.size == content_length
// 334:
// 335:           args = ["--continue-at", "-", *args]
// 336:         end
// 337:       end
// 338:
// 339:       args = ["--remote-time", "--output", destination.to_s, *args]
// 340:
// 341:       curl(*args, **options)
// 342:     end
// 343:
// 344:     # Run after `Tty.collapse_carriage_returns`; a bar-only line becomes empty.
// 345:     sig { params(string: String).returns(String) }
// 346:     def strip_progress_bar(string)
// 347:       string.split("\n", -1).map { |line| line.sub(PROGRESS_BAR_REGEX, "") }.join("\n")
// 348:     end
// 349:
// 350:     sig { overridable.params(args: String, options: T.untyped).returns(SystemCommand::Result) }
// 351:     def curl_output(*args, **options)
// 352:       curl_with_workarounds(*args, print_stderr: false, show_output: true, **options)
// 353:     end
// 354:
// 355:     sig {
// 356:       params(
// 357:         args:           String,
// 358:         wanted_headers: T::Array[String],
// 359:         options:        T.untyped,
// 360:       ).returns(T::Hash[Symbol, T.untyped])
// 361:     }
// 362:     def curl_headers(*args, wanted_headers: [], **options)
// 363:       base_args = ["--fail", "--location", "--silent"]
// 364:       get_retry_args = []
// 365:       if (is_post_request = args.include?("POST"))
// 366:         base_args << "--dump-header" << "-"
// 367:       else
// 368:         base_args << "--head"
// 369:         get_retry_args << "--request" << "GET"
// 370:       end
// 371:
// 372:       # This is a workaround for https://github.com/Homebrew/brew/issues/18213
// 373:       get_retry_args << "--http1.1" if curl_version >= Version.new("8.7") && curl_version < Version.new("8.10")
// 374:
// 375:       [[], get_retry_args].each do |request_args|
// 376:         result = curl_output(*base_args, *request_args, *args, **options)
// 377:
// 378:         # We still receive usable headers with certain non-successful exit
// 379:         # statuses, so we special case them below.
// 380:         if result.success? || [
// 381:           CURL_WEIRD_SERVER_REPLY_EXIT_CODE,
// 382:           CURL_HTTP_RETURNED_ERROR_EXIT_CODE,
// 383:           CURL_RECV_ERROR_EXIT_CODE,
// 384:         ].include?(result.exit_status)
// 385:           parsed_output = parse_curl_output(result.stdout)
// 386:           return parsed_output if is_post_request
// 387:
// 388:           if request_args.empty?
// 389:             # If we didn't get any wanted header yet, retry using `GET`.
// 390:             next if wanted_headers.any? &&
// 391:                     parsed_output.fetch(:responses).none? { |r| r.fetch(:headers).keys.intersect?(wanted_headers) }
// 392:
// 393:             # Some CDNs respond with 400 codes for `HEAD` but resolve with `GET`.
// 394:             next if (400..499).cover?(parsed_output.fetch(:responses).last&.fetch(:status_code).to_i)
// 395:           end
// 396:
// 397:           return parsed_output if result.success? ||
// 398:                                   result.exit_status == CURL_WEIRD_SERVER_REPLY_EXIT_CODE
// 399:         end
// 400:
// 401:         result.assert_success!
// 402:       end
// 403:
// 404:       {}
// 405:     end
// 406:
// 407:     # Check if a URL is protected by CloudFlare (e.g. badlion.net and jaxx.io).
// 408:     # @param response [Hash] A response hash from `#parse_curl_response`.
// 409:     # @return [true, false] Whether a response contains headers indicating that
// 410:     #   the URL is protected by Cloudflare.
// 411:     sig { params(response: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
// 412:     def url_protected_by_cloudflare?(response)
// 413:       return false if response[:headers].blank?
// 414:       return false unless [403, 503].include?(response[:status_code].to_i)
// 415:
// 416:       [*response[:headers]["server"]].any? { |server| server.match?(/^cloudflare/i) }
// 417:     end
// 418:
// 419:     # Check if a URL is protected by Incapsula (e.g. corsair.com).
// 420:     # @param response [Hash] A response hash from `#parse_curl_response`.
// 421:     # @return [true, false] Whether a response contains headers indicating that
// 422:     #   the URL is protected by Incapsula.
// 423:     sig { params(response: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
// 424:     def url_protected_by_incapsula?(response)
// 425:       return false if response[:headers].blank?
// 426:       return false if response[:status_code].to_i != 403
// 427:
// 428:       set_cookie_header = Array(response[:headers]["set-cookie"])
// 429:       set_cookie_header.compact.any? { |cookie| cookie.match?(/^(visid_incap|incap_ses)_/i) }
// 430:     end
// 431:
// 432:     sig {
// 433:       params(
// 434:         url:               String,
// 435:         url_type:          String,
// 436:         specs:             T::Hash[Symbol, String],
// 437:         user_agents:       T::Array[T.any(String, Symbol)],
// 438:         referer:           T.nilable(String),
// 439:         check_content:     T::Boolean,
// 440:         strict:            T::Boolean,
// 441:         use_homebrew_curl: T::Boolean,
// 442:       ).returns(T.nilable(String))
// 443:     }
// 444:     def curl_check_http_content(url, url_type, specs: {}, user_agents: [:default], referer: nil,
// 445:                                 check_content: false, strict: false, use_homebrew_curl: false)
// 446:       return unless url.start_with? "http"
// 447:
// 448:       secure_url = url.sub(/\Ahttp:/, "https:")
// 449:       secure_details = T.let(nil, T.nilable(T::Hash[Symbol, T.untyped]))
// 450:       hash_needed = T.let(false, T::Boolean)
// 451:       if url != secure_url
// 452:         user_agents.each do |user_agent|
// 453:           secure_details = begin
// 454:             curl_http_content_headers_and_checksum(
// 455:               secure_url,
// 456:               specs:,
// 457:               hash_needed:       true,
// 458:               use_homebrew_curl:,
// 459:               user_agent:,
// 460:               referer:,
// 461:             )
// 462:           rescue Timeout::Error
// 463:             next
// 464:           end
// 465:
// 466:           next unless http_status_ok?(secure_details[:status_code])
// 467:
// 468:           hash_needed = true
// 469:           user_agents = [user_agent]
// 470:           break
// 471:         end
// 472:       end
// 473:
// 474:       details = T.let({}, T::Hash[Symbol, T.untyped])
// 475:       attempts = 0
// 476:       # The body is only read to compare an HTTP URL with its HTTPS counterpart.
// 477:       head_only = T.let(url == secure_url, T::Boolean)
// 478:       user_agents.each do |user_agent|
// 479:         loop do
// 480:           details = curl_http_content_headers_and_checksum(
// 481:             url,
// 482:             specs:,
// 483:             hash_needed:,
// 484:             head_only:,
// 485:             use_homebrew_curl:,
// 486:             user_agent:,
// 487:             referer:,
// 488:           )
// 489:
// 490:           # Some servers reject `HEAD` but serve `GET`.
// 491:           # DNS and connection failures happen before the request is sent.
// 492:           head_rejected = if (status_code = details[:status_code])
// 493:             !http_status_ok?(status_code)
// 494:           else
// 495:             CURL_REQUEST_SENT_EXIT_CODES.include?(details[:exit_status])
// 496:           end
// 497:
// 498:           if head_only && head_rejected
// 499:             head_only = false
// 500:             next
// 501:           end
// 502:
// 503:           # Retry on network issues
// 504:           break if details[:exit_status] != 52 && details[:exit_status] != 56
// 505:
// 506:           attempts += 1
// 507:           break if attempts >= Homebrew::EnvConfig.curl_retries.to_i
// 508:         end
// 509:
// 510:         break if http_status_ok?(details[:status_code])
// 511:       end
// 512:
// 513:       return "The #{url_type} #{url} is not reachable" unless details[:status_code]
// 514:
// 515:       unless http_status_ok?(details[:status_code])
// 516:         return if details[:responses].any? do |response|
// 517:           url_protected_by_cloudflare?(response) || url_protected_by_incapsula?(response)
// 518:         end
// 519:
// 520:         # TODO: `utils/shared_audits` requires this file in turn.
// 521:         require "utils/shared_audits"
// 522:
// 523:         # https://github.com/Homebrew/brew/issues/13789
// 524:         # If the `:homepage` of a formula is private, it will fail an `audit`
// 525:         # since there's no way to specify a `strategy` with `using:` and
// 526:         # GitHub does not authorize access to the web UI using token
// 527:         #
// 528:         # Strategy:
// 529:         # If the `:homepage` 404s, it's a GitHub link and we have a token then
// 530:         # check the API (which does use tokens) for the repository
// 531:         repo_details = url.match(%r{https?://github\.com/(?<user>[^/]+)/(?<repo>[^/]+)/?.*})
// 532:         check_github_api = url_type == SharedAudits::URL_TYPE_HOMEPAGE &&
// 533:                            details[:status_code] == "404" &&
// 534:                            repo_details &&
// 535:                            Homebrew::EnvConfig.github_api_token.present?
// 536:
// 537:         unless check_github_api
// 538:           return "The #{url_type} #{url} is not reachable (HTTP status code #{details[:status_code]})"
// 539:         end
// 540:
// 541:         if SharedAudits.github_repo_data(T.must(repo_details[:user]), T.must(repo_details[:repo])).nil?
// 542:           "Unable to find homepage"
// 543:         end
// 544:       end
// 545:
// 546:       if details[:final_url].present? && insecure_redirect?(url:, resolved_url: details[:final_url])
// 547:         return "The #{url_type} #{url} redirects back to HTTP"
// 548:       end
// 549:
// 550:       return unless secure_details
// 551:
// 552:       return if !http_status_ok?(details[:status_code]) || !http_status_ok?(secure_details[:status_code])
// 553:
// 554:       etag_match = details[:etag] &&
// 555:                    details[:etag] == secure_details[:etag]
// 556:       content_length_match =
// 557:         details[:content_length] &&
// 558:         details[:content_length] == secure_details[:content_length]
// 559:       file_match = details[:file_hash] == secure_details[:file_hash]
// 560:
// 561:       http_with_https_available =
// 562:         url.start_with?("http://") &&
// 563:         secure_details[:final_url].present? && secure_details[:final_url].start_with?("https://")
// 564:
// 565:       if (etag_match || content_length_match || file_match) && http_with_https_available
// 566:         return "The #{url_type} #{url} should use HTTPS rather than HTTP"
// 567:       end
// 568:
// 569:       return unless check_content
// 570:
// 571:       no_protocol_file_contents = %r{https?:\\?/\\?/}
// 572:       http_content = details[:file]&.scrub&.gsub(no_protocol_file_contents, "/")
// 573:       https_content = secure_details[:file]&.scrub&.gsub(no_protocol_file_contents, "/")
// 574:
// 575:       # Check for the same content after removing all protocols
// 576:       if http_content && https_content && (http_content == https_content) && http_with_https_available
// 577:         return "The #{url_type} #{url} should use HTTPS rather than HTTP"
// 578:       end
// 579:
// 580:       return unless strict
// 581:
// 582:       # Same size, different content after normalization
// 583:       # (typical causes: Generated ID, Timestamp, Unix time)
// 584:       if http_content.length == https_content.length
// 585:         return "The #{url_type} #{url} may be able to use HTTPS rather than HTTP. Please verify it in a browser."
// 586:       end
// 587:
// 588:       lenratio = (https_content.length * 100 / http_content.length).to_i
// 589:       return unless (90..110).cover?(lenratio)
// 590:
// 591:       "The #{url_type} #{url} may be able to use HTTPS rather than HTTP. Please verify it in a browser."
// 592:     end
// 593:
// 594:     sig {
// 595:       params(
// 596:         url:               String,
// 597:         specs:             T::Hash[Symbol, String],
// 598:         hash_needed:       T::Boolean,
// 599:         head_only:         T::Boolean,
// 600:         use_homebrew_curl: T::Boolean,
// 601:         user_agent:        T.any(String, Symbol),
// 602:         referer:           T.nilable(String),
// 603:       ).returns(T::Hash[Symbol, T.untyped])
// 604:     }
// 605:     def curl_http_content_headers_and_checksum(
// 606:       url, specs: {}, hash_needed: false, head_only: false,
// 607:       use_homebrew_curl: false, user_agent: :default, referer: nil
// 608:     )
// 609:       file = Tempfile.new.tap(&:close)
// 610:
// 611:       # Convert specs to options. This is mostly key-value options,
// 612:       # unless the value is a boolean in which case treat as a flag.
// 613:       specs = specs.flat_map do |option, argument|
// 614:         next [] if argument == false # No flag.
// 615:
// 616:         args = ["--#{option.to_s.tr("_", "-")}"]
// 617:         args << argument if argument != true # It's a flag.
// 618:         args
// 619:       end
// 620:
// 621:       max_time = hash_needed ? 600 : 25
// 622:       # `--head` prints the headers itself, so `--dump-header` would duplicate them.
// 623:       output_args = if head_only
// 624:         ["--head"]
// 625:       else
// 626:         ["--dump-header", "-", "--output", file.path]
// 627:       end
// 628:       output, _, status = curl_output(
// 629:         *specs, *output_args, "--location", url,
// 630:         use_homebrew_curl:,
// 631:         connect_timeout:   15,
// 632:         max_time:,
// 633:         retry_max_time:    max_time,
// 634:         user_agent:,
// 635:         referer:
// 636:       )
// 637:
// 638:       parsed_output = parse_curl_output(output)
// 639:       responses = parsed_output[:responses]
// 640:
// 641:       final_url = curl_response_last_location(responses)
// 642:       headers = if responses.last.present?
// 643:         status_code = responses.last[:status_code]
// 644:         responses.last[:headers]
// 645:       else
// 646:         {}
// 647:       end
// 648:       etag = headers["etag"][ETAG_VALUE_REGEX, 1] if headers["etag"].present?
// 649:       content_length = headers["content-length"]
// 650:
// 651:       if !head_only && status.success? && (file_path = file.path)
// 652:         file_hash = Digest::SHA256.file(file_path).hexdigest if hash_needed
// 653:
// 654:         # Only load file contents for text-based content comparison on small files.
// 655:         # Large binary files don't benefit from content comparison.
// 656:         max_read_size = 100 * 1024 * 1024
// 657:         if File.size(file_path) <= max_read_size
// 658:           open_args = {}
// 659:           content_type = headers["content-type"]
// 660:
// 661:           # Use the last `Content-Type` header if there is more than one instance
// 662:           # in the response
// 663:           content_type = content_type.last if content_type.is_a?(Array)
// 664:
// 665:           # Try to get encoding from Content-Type header
// 666:           # TODO: add guessing encoding by <meta http-equiv="Content-Type" ...> tag
// 667:           if content_type &&
// 668:              (match = content_type.match(/;\s*charset\s*=\s*([^\s]+)/)) &&
// 669:              (charset = match[1])
// 670:             begin
// 671:               open_args[:encoding] = Encoding.find(charset)
// 672:             rescue ArgumentError
// 673:               # Unknown charset in Content-Type header
// 674:             end
// 675:           end
// 676:
// 677:           file_contents = File.read(file_path, **open_args)
// 678:         end
// 679:       end
// 680:
// 681:       {
// 682:         url:,
// 683:         final_url:,
// 684:         exit_status:    status.exitstatus,
// 685:         status_code:,
// 686:         headers:,
// 687:         etag:,
// 688:         content_length:,
// 689:         file:           file_contents,
// 690:         file_hash:,
// 691:         responses:,
// 692:       }
// 693:     ensure
// 694:       T.must(file).unlink
// 695:     end
// 696:
// 697:     sig { returns(Version) }
// 698:     def curl_version
// 699:       @curl_version ||= T.let({}, T.nilable(T::Hash[String, Version]))
// 700:       curl_v_stdout = curl_output("-V").stdout
// 701:       version = curl_v_stdout[/curl (\d+(?:\.\d+)+)/, 1]
// 702:       if version
// 703:         @curl_version[curl_path] ||= Version.new(version)
// 704:       else
// 705:         odie("Failed to parse curl version from #{curl_v_stdout}")
// 706:       end
// 707:     end
// 708:
// 709:     sig { returns(T::Boolean) }
// 710:     def curl_supports_fail_with_body?
// 711:       @curl_supports_fail_with_body ||= T.let(Hash.new do |h, key|
// 712:         h[key] = curl_version >= Version.new("7.76.0")
// 713:       end, T.nilable(T::Hash[T.any(Pathname, String), T::Boolean]))
// 714:       @curl_supports_fail_with_body[curl_path]
// 715:     end
// 716:
// 717:     sig { returns(T::Boolean) }
// 718:     def curl_supports_tls13?
// 719:       @curl_supports_tls13 ||= T.let(Hash.new do |h, key|
// 720:         h[key] = quiet_system(curl_executable, "--tlsv1.3", "--head", "https://brew.sh/")
// 721:       end, T.nilable(T::Hash[T.any(Pathname, String), T::Boolean]))
// 722:       @curl_supports_tls13[curl_path]
// 723:     end
// 724:
// 725:     sig { params(status: T.nilable(String)).returns(T::Boolean) }
// 726:     def http_status_ok?(status)
// 727:       return false if status.nil?
// 728:
// 729:       (100..299).cover?(status.to_i)
// 730:     end
// 731:
// 732:     # Separates the output text from `curl` into an array of HTTP responses and
// 733:     # the final response body (i.e. content). Response hashes contain the
// 734:     # `:status_code`, `:status_text` and `:headers`.
// 735:     # @param output [String] The output text from `curl` containing HTTP
// 736:     #   responses, body content, or both.
// 737:     # @param max_iterations [Integer] The maximum number of iterations for the
// 738:     #   `while` loop that parses HTTP response text. This should correspond to
// 739:     #   the maximum number of requests in the output. If `curl`'s `--max-redirs`
// 740:     #   option is used, `max_iterations` should be `max-redirs + 1`, to
// 741:     #   account for any final response after the redirections.
// 742:     # @return [Hash] A hash containing an array of response hashes and the body
// 743:     #   content, if found.
// 744:     sig { params(output: String, max_iterations: Integer).returns(T::Hash[Symbol, T.untyped]) }
// 745:     def parse_curl_output(output, max_iterations: 25)
// 746:       responses = []
// 747:
// 748:       iterations = 0
// 749:       output = output.lstrip
// 750:       while output.match?(%r{\AHTTP/[\d.]+ \d+}) && output.include?(HTTP_RESPONSE_BODY_SEPARATOR)
// 751:         iterations += 1
// 752:         raise "Too many redirects (max = #{max_iterations})" if iterations > max_iterations
// 753:
// 754:         response_text, _, output = output.partition(HTTP_RESPONSE_BODY_SEPARATOR)
// 755:         output = output.lstrip
// 756:         next if response_text.blank?
// 757:
// 758:         response_text.chomp!
// 759:         response = parse_curl_response(response_text)
// 760:         responses << response if response.present?
// 761:       end
// 762:
// 763:       { responses:, body: output }
// 764:     end
// 765:
// 766:     # Returns the URL from the last location header found in cURL responses,
// 767:     # if any.
// 768:     # @param responses [Array<Hash>] An array of hashes containing response
// 769:     #   status information and headers from `#parse_curl_response`.
// 770:     # @param absolutize [true, false] Whether to make the location URL absolute.
// 771:     # @param base_url [String, nil] The URL to use as a base for making the
// 772:     #   `location` URL absolute.
// 773:     # @return [String, nil] The URL from the last-occurring `location` header
// 774:     #   in the responses or `nil` (if no `location` headers found).
// 775:     sig {
// 776:       params(
// 777:         responses:  T::Array[T::Hash[Symbol, T.untyped]],
// 778:         absolutize: T::Boolean,
// 779:         base_url:   T.nilable(String),
// 780:       ).returns(T.nilable(String))
// 781:     }
// 782:     def curl_response_last_location(responses, absolutize: false, base_url: nil)
// 783:       responses.reverse_each do |response|
// 784:         next if response[:headers].blank?
// 785:
// 786:         location = response[:headers]["location"]
// 787:         next if location.blank?
// 788:
// 789:         absolute_url = URI.join(base_url, location).to_s if absolutize && base_url.present?
// 790:         return absolute_url || location
// 791:       end
// 792:
// 793:       nil
// 794:     end
// 795:
// 796:     # Returns the final URL by following location headers in cURL responses.
// 797:     # @param responses [Array<Hash>] An array of hashes containing response
// 798:     #   status information and headers from `#parse_curl_response`.
// 799:     # @param base_url [String] The URL to use as a base.
// 800:     # @return [String] The final absolute URL after redirections.
// 801:     sig {
// 802:       params(
// 803:         responses: T::Array[T::Hash[Symbol, T.untyped]],
// 804:         base_url:  String,
// 805:       ).returns(String)
// 806:     }
// 807:     def curl_response_follow_redirections(responses, base_url)
// 808:       responses.each do |response|
// 809:         next if response[:headers].blank?
// 810:
// 811:         location = response[:headers]["location"]
// 812:         next if location.blank?
// 813:
// 814:         base_url = URI.join(base_url, location).to_s
// 815:       end
// 816:
// 817:       base_url
// 818:     end
// 819:
// 820:     private
// 821:
// 822:     # Parses HTTP response text from `curl` output into a hash containing the
// 823:     # information from the status line (status code and, optionally,
// 824:     # descriptive text) and headers.
// 825:     # @param response_text [String] The text of a `curl` response, consisting
// 826:     #   of a status line followed by header lines.
// 827:     # @return [Hash] A hash containing the response status information and
// 828:     #   headers (as a hash with header names as keys).
// 829:     sig { params(response_text: String).returns(T::Hash[Symbol, T.untyped]) }
// 830:     def parse_curl_response(response_text)
// 831:       response = {}
// 832:       return response unless (match = response_text.match(HTTP_STATUS_LINE_REGEX))
// 833:
// 834:       # Parse the status line and remove it
// 835:       response[:status_code] = match["code"]
// 836:       response[:status_text] = match["text"] if match["text"].present?
// 837:       response_text = response_text.sub(%r{^HTTP/.* (\d+).*$\s*}, "")
// 838:
// 839:       # Create a hash from the header lines
// 840:       response[:headers] = {}
// 841:       response_text.split("\r\n").each do |line|
// 842:         header_name, header_value = line.split(/:\s*/, 2)
// 843:         next if header_name.blank? || header_value.nil?
// 844:
// 845:         header_name = header_name.strip.downcase
// 846:         header_value.strip!
// 847:
// 848:         case response[:headers][header_name]
// 849:         when String
// 850:           response[:headers][header_name] = [response[:headers][header_name], header_value]
// 851:         when Array
// 852:           response[:headers][header_name].push(header_value)
// 853:         else
// 854:           response[:headers][header_name] = header_value
// 855:         end
// 856:
// 857:         response[:headers][header_name]
// 858:       end
// 859:
// 860:       response
// 861:     end
// 862:   end
// 863: end
