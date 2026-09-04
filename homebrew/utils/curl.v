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
	runner      ?fn (string, []string, map[string]string, ?f64) !CurlCommandResult
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

pub type CurlContentFetcher = fn (CurlFetchRequest) !CurlHttpDetails

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
			[]
		}.map(it.as_string())
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
			[]
		}.map(it.as_string())
		curlrc_present: 'curlrc' in values
		curlrc: (values['curlrc'] or { ruby.string_value('') }).as_string()
		connect_timeout: if item := values['connect_timeout'] {
			item.as_float() or { 0.0 }
		} else {
			none
		}
		max_time: if item := values['max_time'] { item.as_float() or { 0.0 } } else { none }
		retries: int((values['retries'] or { ruby.int_value(3) }).int_data)
		retries_present: if item := values['retries'] { item.type_name != 'NilClass' } else { true }
		retry_max_time: if item := values['retry_max_time'] {
			item.as_float() or { 0.0 }
		} else {
			none
		}
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
