module utils

import ruby
import homebrew.utils as curl

const curl_spec_default_user_agent = 'Homebrew/curl'
const curl_spec_browser_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/17.0 Safari/605.1.15'

fn curl_spec_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn curl_spec_value_headers(headers map[string][]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, entries in headers {
		values[name] = if entries.len == 1 {
			ruby.string_value(entries[0])
		} else {
			ruby.string_array_value(entries)
		}
	}
	return ruby.map_value(values)
}

fn curl_spec_detail_value(detail curl.CurlHttpDetails) ruby.Value {
	return ruby.map_value({
		'url':            ruby.string_value(detail.url)
		'final_url':      if detail.final_url == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.final_url)
		}
		'exit_status':    ruby.int_value(detail.exit_status)
		'status_code':    if detail.status_code == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.status_code)
		}
		'headers':        curl_spec_value_headers(detail.headers)
		'etag':           if detail.etag == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.etag)
		}
		'content_length': if detail.content_length == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.content_length)
		}
		'file':           if detail.file_contents == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.file_contents)
		}
		'file_hash':      if detail.file_hash == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.file_hash)
		}
		'responses':      ruby.array_value(detail.responses.map(curl.curl_response_value(it)))
	})
}

fn curl_spec_site_detail_value(detail curl.CurlHttpDetails) ruby.Value {
	return ruby.map_value({
		'url':            ruby.string_value(detail.url)
		'final_url':      if detail.final_url == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.final_url)
		}
		'status_code':    ruby.string_value(detail.status_code)
		'headers':        curl_spec_value_headers(detail.headers)
		'etag':           if detail.etag == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.etag)
		}
		'content_length': ruby.string_value(detail.content_length)
		'file':           ruby.string_value(detail.file_contents)
		'file_hash':      if detail.file_hash == '' {
			curl_spec_nil()
		} else {
			ruby.string_value(detail.file_hash)
		}
	})
}

fn curl_spec_normal_headers() map[string][]string {
	return {
		'age':            ['123456']
		'cache-control':  ['max-age=604800']
		'content-type':   ['text/html; charset=UTF-8']
		'date':           ['Wed, 1 Jan 2020 01:23:45 GMT']
		'etag':           ['"3147526947+ident"']
		'expires':        ['Wed, 31 Jan 2020 01:23:45 GMT']
		'last-modified':  ['Wed, 1 Jan 2020 00:00:00 GMT']
		'server':         ['ECS (dcb/7EA2)']
		'vary':           ['Accept-Encoding']
		'x-cache':        ['HIT']
		'content-length': ['3']
	}
}

fn curl_spec_normal(status string, cookies []string) curl.CurlHttpDetails {
	mut headers := curl_spec_normal_headers()
	if cookies.len > 0 {
		headers['set-cookie'] = cookies.clone()
	}
	return curl.CurlHttpDetails{
		url: 'https://www.example.com/'
		status_code: status
		headers: headers
		etag: '3147526947+ident'
		content_length: '3'
		file_contents: '...'
	}
}

fn curl_spec_cloudflare(cookies []string, server string, has_server bool) curl.CurlHttpDetails {
	mut headers := {
		'date':            ['Wed, 1 Jan 2020 01:23:45 GMT']
		'content-type':    ['text/plain; charset=UTF-8']
		'content-length':  ['16']
		'x-frame-options': ['SAMEORIGIN']
		'referrer-policy': ['same-origin']
		'cache-control':   [
			'private, max-age=0, no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
		]
		'expires':         ['Thu, 01 Jan 1970 00:00:01 GMT']
		'expect-ct':       [
			'max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"',
		]
		'set-cookie':      cookies.clone()
		'cf-ray':          ['0123456789abcdef-IAD']
		'alt-svc':         ['h3=":443"; ma=86400, h3-29=":443"; ma=86400']
	}
	if has_server {
		headers['server'] = [server]
	}
	return curl.CurlHttpDetails{
		url: 'https://www.example.com/'
		status_code: '403'
		headers: headers
		content_length: '16'
		file_contents: 'error code: 1020'
	}
}

fn curl_spec_response_fixtures() map[string]curl.CurlResponse {
	base_headers := {
		'cache-control':  ['max-age=604800']
		'content-type':   ['text/html; charset=UTF-8']
		'date':           ['Wed, 1 Jan 2020 01:23:45 GMT']
		'expires':        ['Wed, 31 Jan 2020 01:23:45 GMT']
		'last-modified':  ['Thu, 1 Jan 2019 01:23:45 GMT']
		'content-length': ['123']
	}
	mut blank_value_headers := base_headers.clone()
	blank_value_headers['range'] = ['']
	mut redirect_headers := base_headers.clone()
	redirect_headers['location'] = ['https://example.com/example/']
	mut redirect1_headers := base_headers.clone()
	redirect1_headers['location'] = ['https://example.com/example1/']
	mut redirect2_headers := base_headers.clone()
	redirect2_headers['location'] = ['https://example.com/example2/']
	mut no_scheme_headers := base_headers.clone()
	no_scheme_headers['location'] = ['//www.example.com/example/']
	mut root_relative_headers := base_headers.clone()
	root_relative_headers['location'] = ['/example/']
	mut parent_relative_headers := base_headers.clone()
	parent_relative_headers['location'] = ['./example/']
	mut duplicate_headers := base_headers.clone()
	duplicate_headers['set-cookie'] = [
		'example1=first',
		'example2=second; Expires Wed, 31 Jan 2020 01:23:45 GMT',
		'example3=third',
	]
	return {
		'ok':                          curl.CurlResponse{ status_code: '200', status_text: 'OK', headers: base_headers }
		'ok_no_status_text':           curl.CurlResponse{ status_code: '200', headers: base_headers }
		'ok_blank_header_value':       curl.CurlResponse{ status_code: '200', status_text: 'OK', headers: blank_value_headers }
		'redirection':                 curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: redirect_headers }
		'redirection1':                curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: redirect1_headers }
		'redirection2':                curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: redirect2_headers }
		'redirection_no_scheme':       curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: no_scheme_headers }
		'redirection_root_relative':   curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: root_relative_headers }
		'redirection_parent_relative': curl.CurlResponse{ status_code: '301', status_text: 'Moved Permanently', headers: parent_relative_headers }
		'duplicate_header':            curl.CurlResponse{ status_code: '200', status_text: 'OK', headers: duplicate_headers }
	}
}

fn curl_spec_response_texts() map[string]string {
	responses := curl_spec_response_fixtures()
	ok := 'HTTP/1.1 200 OK\r\nCache-Control: max-age=604800\r\nContent-Type: text/html; charset=UTF-8\r\nDate: Wed, 1 Jan 2020 01:23:45 GMT\r\nExpires: Wed, 31 Jan 2020 01:23:45 GMT\r\nLast-Modified: Thu, 1 Jan 2019 01:23:45 GMT\r\nContent-Length: 123\r\n\r\n'
	no_status := ok.replace_once(' 200 OK\r', ' 200\r')
	blank_name := ok.replace_once('Wed, 1 Jan 2020 01:23:45 GMT\r\n', 'Wed, 1 Jan 2020 01:23:45 GMT\r\n: Test\r\n')
	blank_value := ok.replace_once('Wed, 1 Jan 2020 01:23:45 GMT\r\n', 'Wed, 1 Jan 2020 01:23:45 GMT\r\nRange:\r\n')
	redirect := ok.replace_once('HTTP/1.1 200 OK\r', 'HTTP/1.1 301 Moved Permanently\r\nLocation: https://example.com/example/\r')
	redirect1 := redirect.replace_once('https://example.com/example/', 'https://example.com/example1/')
	redirect2 := redirect.replace_once('https://example.com/example/', 'https://example.com/example2/')
	duplicate := ok.trim_right('\r\n') + '\r\nSet-Cookie: ${responses['duplicate_header'].headers['set-cookie'][0]}\r\nSet-Cookie: ${responses['duplicate_header'].headers['set-cookie'][1]}\r\nSet-Cookie: ${responses['duplicate_header'].headers['set-cookie'][2]}\r\n\r\n'
	return {
		'ok':                    ok
		'ok_no_status_text':     no_status
		'ok_blank_header_name':  blank_name
		'ok_blank_header_value': blank_value
		'redirection':           redirect
		'redirection_to_ok':     redirect + ok
		'redirections_to_ok':    redirect2 + '\n' + redirect1 + '\n' + redirect + '\n' + ok + '\n'
		'duplicate_header':      duplicate
	}
}

fn curl_spec_bodies() map[string]string {
	default_body := '<!DOCTYPE html>\n<html>\n  <head>\n    <meta charset="utf-8">\n    <title>Example</title>\n  </head>\n  <body>\n    <h1>Example</h1>\n    <p>Hello, world!</p>\n  </body>\n</html>\n'
	return {
		'default':               default_body
		'with_carriage_returns': default_body.replace_once('<html>\n', '<html>\r\n\r\n')
		'with_http_status_line': default_body.replace_once('<html>', 'HTTP/1.1 200\r\n<html>')
	}
}

fn curl_spec_response_equal(left curl.CurlResponse, right curl.CurlResponse) bool {
	return left.status_code == right.status_code && left.status_text == right.status_text && left.headers == right.headers
}

fn curl_spec_parsed_equal(parsed curl.CurlParsedOutput, expected []curl.CurlResponse, body string) bool {
	if parsed.body != body || parsed.responses.len != expected.len {
		return false
	}
	for index, response in parsed.responses {
		if !curl_spec_response_equal(response, expected[index]) {
			return false
		}
	}
	return true
}

fn curl_spec_args(options curl.CurlArgsOptions) []string {
	return curl.curl_args(options) or { [] }
}

fn curl_spec_has_pair(arguments []string, option string, value string) bool {
	index := arguments.index(option)
	return index >= 0 && index + 1 < arguments.len && arguments[index + 1] == value
}

fn curl_spec_runtime_runner(_ string, arguments []string, _ map[string]string, _ ?f64) !curl.CurlCommandResult {
	if arguments == ['--homebrew=print-path'] {
		return curl.CurlCommandResult{ stdout: '/usr/bin/curl\n', arguments: arguments }
	}
	if arguments == ['-V'] {
		return curl.CurlCommandResult{ stdout: 'curl 8.9.1 (arm64) libcurl/8.9.1', arguments: arguments }
	}
	return curl.CurlCommandResult{ arguments: arguments }
}

fn curl_spec_response(status string, exit_status int) curl.CurlHttpDetails {
	return curl.CurlHttpDetails{
		url: 'https://brew.sh/'
		exit_status: exit_status
		status_code: status
		headers: map[string][]string{}
	}
}

fn curl_spec_fetch_require_https_head(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.url == 'https://brew.sh/' && request.head_only {
		curl_spec_response('200', 0)
	} else {
		curl_spec_response('500', 0)
	}
}

fn curl_spec_fetch_require_http_body(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if !request.head_only { curl_spec_response('200', 0) } else { curl_spec_response('', 6) }
}

fn curl_spec_fetch_head_405_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only {
		curl_spec_response('405', 0)
	} else {
		curl_spec_response('200', 0)
	}
}

fn curl_spec_fetch_head_405_get_500(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only {
		curl_spec_response('405', 0)
	} else {
		curl_spec_response('500', 0)
	}
}

fn curl_spec_fetch_head_28_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only { curl_spec_response('', 28) } else { curl_spec_response('200', 0) }
}

fn curl_spec_fetch_head_52_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only { curl_spec_response('', 52) } else { curl_spec_response('200', 0) }
}

fn curl_spec_fetch_head_56_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only { curl_spec_response('', 56) } else { curl_spec_response('200', 0) }
}

fn curl_spec_fetch_head_6_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only { curl_spec_response('', 6) } else { curl_spec_response('200', 0) }
}

fn curl_spec_fetch_head_7_get_200(request curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return if request.head_only { curl_spec_response('', 7) } else { curl_spec_response('200', 0) }
}

fn curl_spec_fetch_always_28(_ curl.CurlFetchRequest) !curl.CurlHttpDetails {
	return curl_spec_response('', 28)
}

fn curl_spec_check(fetch curl.CurlContentFetcher) string {
	return curl.curl_check_http_content(curl.CurlCheckRequest{
		url: 'https://brew.sh/'
		url_type: 'homepage URL'
	}, fetch) or { err.msg() }
}

// Translated from Homebrew/brew `test/utils/curl_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:details) do` at line 9.
pub fn ruby_curl_spec_l9_d1_details(args ...ruby.Value) ruby.Value {
	mut blank := curl_spec_normal('403', [])
	blank = curl.CurlHttpDetails{
		...blank
		headers: map[string][]string{}
	}
	cloudflare_cookie := '__cf_bm=0123456789abcdef; path=/; expires=Wed, 31-Jan-20 01:23:45 GMT; domain=www.example.com; HttpOnly; Secure; SameSite=None'
	cloudflare_multi := [
		'first_cookie=for_testing',
		'__cf_bm=abcdef0123456789; path=/; expires=Thu, 28-Apr-22 18:38:40 GMT; domain=www.example.com; HttpOnly; Secure; SameSite=None',
		'last_cookie=also_for_testing',
	]
	return ruby.map_value({
		'normal':     ruby.map_value({
			'no_cookie':        curl_spec_site_detail_value(curl_spec_normal('403', []))
			'ok':               curl_spec_site_detail_value(curl_spec_normal('200', []))
			'single_cookie':    curl_spec_site_detail_value(curl_spec_normal('403', [
				'a_cookie=for_testing',
			]))
			'multiple_cookies': curl_spec_site_detail_value(curl_spec_normal('403', [
				'first_cookie=for_testing',
				'last_cookie=also_for_testing',
			]))
			'blank_headers':    curl_spec_site_detail_value(blank)
		})
		'cloudflare': ruby.map_value({
			'single_cookie':    curl_spec_site_detail_value(curl_spec_cloudflare([
				cloudflare_cookie,
			], 'cloudflare', true))
			'multiple_cookies': curl_spec_site_detail_value(curl_spec_cloudflare(cloudflare_multi, 'cloudflare', true))
			'no_server':        curl_spec_site_detail_value(curl_spec_cloudflare([
				cloudflare_cookie,
			], '', false))
			'wrong_server':     curl_spec_site_detail_value(curl_spec_cloudflare([
				cloudflare_cookie,
			], 'nginx 1.2.3', true))
		})
		'incapsula':  ruby.map_value({
			'single_cookie_visid_incap':    curl_spec_site_detail_value(curl_spec_normal('403', [
				'visid_incap_something=something',
			]))
			'single_cookie_incap_ses':      curl_spec_site_detail_value(curl_spec_normal('403', [
				'incap_ses_something=something',
			]))
			'multiple_cookies_visid_incap': curl_spec_site_detail_value(curl_spec_normal('403', [
				'first_cookie=for_testing',
				'visid_incap_something=something',
				'last_cookie=also_for_testing',
			]))
			'multiple_cookies_incap_ses':   curl_spec_site_detail_value(curl_spec_normal('403', [
				'first_cookie=for_testing',
				'incap_ses_something=something',
				'last_cookie=also_for_testing',
			]))
		})
	})
}

// Ruby let `let(:location_urls) do` at line 118.
pub fn ruby_curl_spec_l118_d2_location_urls(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value([
		'https://example.com/example/',
		'https://example.com/example1/',
		'https://example.com/example2/',
	])
}

// Ruby let `let(:response_hash) do` at line 126.
pub fn ruby_curl_spec_l126_d3_response_hash(args ...ruby.Value) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, response in curl_spec_response_fixtures() {
		values[name] = curl.curl_response_value(response)
	}
	return ruby.map_value(values)
}

// Ruby let `let(:response_text) do` at line 253.
pub fn ruby_curl_spec_l253_d4_response_text(args ...ruby.Value) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, response_text in curl_spec_response_texts() {
		values[name] = ruby.string_value(response_text)
	}
	return ruby.map_value(values)
}

// Ruby let `let(:body) do` at line 302.
pub fn ruby_curl_spec_l302_d5_body(args ...ruby.Value) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, body in curl_spec_bodies() {
		values[name] = ruby.string_value(body)
	}
	return ruby.map_value(values)
}

// Ruby it `it "returns HOMEBREW_BREWED_CURL_PATH when `use_homebrew_curl` is `true`" do` at line 327.
pub fn ruby_curl_spec_l327_d6_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl.curl_executable(true, '/homebrew/opt/curl/bin/curl', '/homebrew/shims/shared/curl') == '/homebrew/opt/curl/bin/curl')
}

// Ruby it `it "returns curl shim path when `use_homebrew_curl` is `false` or omitted" do` at line 331.
pub fn ruby_curl_spec_l331_d7_returns(args ...ruby.Value) ruby.Value {
	shim := '/homebrew/shims/shared/curl'
	return ruby.bool_value(curl.curl_executable(false, '/homebrew/opt/curl/bin/curl', shim) == shim && curl.curl_executable(false, '/homebrew/opt/curl/bin/curl', shim) == shim)
}

// Ruby it `it "returns a curl path string" do` at line 339.
pub fn ruby_curl_spec_l339_d8_returns(args ...ruby.Value) ruby.Value {
	mut runtime := curl.CurlRuntime{
		shim_path: '/homebrew/shims/shared/curl'
		brewed_path: '/homebrew/opt/curl/bin/curl'
		runner: curl_spec_runtime_runner
	}
	path := runtime.path() or { return ruby.bool_value(false) }
	return ruby.bool_value(path == '/usr/bin/curl')
}

// Ruby let `let(:args) { ["foo"] }` at line 347.
pub fn ruby_curl_spec_l347_d9_args(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['foo'])
}

// Ruby let `let(:user_agent_string) { "Lorem ipsum dolor sit amet" }` at line 348.
pub fn ruby_curl_spec_l348_d10_user_agent_string(args ...ruby.Value) ruby.Value {
	return ruby.string_value('Lorem ipsum dolor sit amet')
}

// Ruby it `it "returns `--disable` as the first argument when HOMEBREW_CURLRC is not set" do` at line 350.
pub fn ruby_curl_spec_l350_d11_returns(args ...ruby.Value) ruby.Value {
	arguments := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'] })
	return ruby.bool_value(arguments.len > 0 && arguments[0] == '--disable')
}

// Ruby it `it "doesn't return `--disable` as the first argument when HOMEBREW_CURLRC is set but not a path" do` at line 355.
pub fn ruby_curl_spec_l355_d12_doesn(args ...ruby.Value) ruby.Value {
	arguments := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		curlrc_present: true
		curlrc: '1'
	})
	return ruby.bool_value(arguments.len > 0 && arguments[0] != '--disable')
}

// Ruby it `it "doesn't return `--config` when HOMEBREW_CURLRC is unset" do` at line 360.
pub fn ruby_curl_spec_l360_d13_doesn(args ...ruby.Value) ruby.Value {
	arguments := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'] })
	return ruby.bool_value(!arguments.any(it.starts_with('--config')))
}

// Ruby it `it "returns `--config` when HOMEBREW_CURLRC is a valid path" do` at line 364.
pub fn ruby_curl_spec_l364_d14_returns(args ...ruby.Value) ruby.Value {
	path := '/tmp/homebrew-curlrc'
	arguments := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		curlrc_present: true
		curlrc: path
	})
	return ruby.bool_value(arguments.len > 0 && arguments[0] == '--disable' && curl_spec_has_pair(arguments, '--config', path))
}

// Ruby it `it "uses `--connect-timeout` when `:connect_timeout` is Numeric" do` at line 376.
pub fn ruby_curl_spec_l376_d15_uses(args ...ruby.Value) ruby.Value {
	first := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], connect_timeout: 123.0 })
	second := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], connect_timeout: 123.4 })
	third := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], connect_timeout: 123.4567 })
	return ruby.bool_value(curl_spec_has_pair(first, '--connect-timeout', '123') && curl_spec_has_pair(second, '--connect-timeout', '123.4') && curl_spec_has_pair(third, '--connect-timeout', '123.457'))
}

// Ruby it `it "uses `--max-time` when `:max_time` is Numeric" do` at line 382.
pub fn ruby_curl_spec_l382_d16_uses(args ...ruby.Value) ruby.Value {
	first := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], max_time: 123.0 })
	second := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], max_time: 123.4 })
	third := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], max_time: 123.4567 })
	return ruby.bool_value(curl_spec_has_pair(first, '--max-time', '123') && curl_spec_has_pair(second, '--max-time', '123.4') && curl_spec_has_pair(third, '--max-time', '123.457'))
}

// Ruby it `it "uses `--retry 3` when HOMEBREW_CURL_RETRIES is unset" do` at line 388.
pub fn ruby_curl_spec_l388_d17_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_has_pair(curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
	}), '--retry', '3'))
}

// Ruby it `it "uses the given value for `--retry` when HOMEBREW_CURL_RETRIES is set" do` at line 392.
pub fn ruby_curl_spec_l392_d18_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_has_pair(curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		retries: 10
	}), '--retry', '10'))
}

// Ruby it `it "uses `--retry` when `:retries` is a positive Integer" do` at line 397.
pub fn ruby_curl_spec_l397_d19_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_has_pair(curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		retries: 5
	}), '--retry', '5'))
}

// Ruby it `it "doesn't use `--retry` when `:retries` is nil or a non-positive Integer" do` at line 401.
pub fn ruby_curl_spec_l401_d20_doesn(args ...ruby.Value) ruby.Value {
	nil_retry := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], retries_present: false })
	zero := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], retries: 0 })
	negative := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], retries: -1 })
	return ruby.bool_value('--retry' !in nil_retry && '--retry' !in zero && '--retry' !in negative)
}

// Ruby it `it "uses `--retry-max-time` when `:retry_max_time` is Numeric" do` at line 407.
pub fn ruby_curl_spec_l407_d21_uses(args ...ruby.Value) ruby.Value {
	first := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], retry_max_time: 123.0 })
	second := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], retry_max_time: 123.4 })
	return ruby.bool_value(curl_spec_has_pair(first, '--retry-max-time', '123') && curl_spec_has_pair(second, '--retry-max-time', '123'))
}

// Ruby it `it "uses `--show-error` when :show_error is `true`" do` at line 412.
pub fn ruby_curl_spec_l412_d22_uses(args ...ruby.Value) ruby.Value {
	shown := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], show_error: true })
	hidden := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], show_error: false })
	return ruby.bool_value('--show-error' in shown && '--show-error' !in hidden)
}

// Ruby it `it "uses `--cookie` with argument when :cookies is present" do` at line 417.
pub fn ruby_curl_spec_l417_d23_uses(args ...ruby.Value) ruby.Value {
	arguments := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		cookies: {
			'cookie_key': 'cookie_value'
		}
		cookies_present: true
	})
	return ruby.bool_value(curl_spec_has_pair(arguments, '--cookie', 'cookie_key=cookie_value'))
}

// Ruby it `it "uses `--header` with argument when :header is present" do` at line 425.
pub fn ruby_curl_spec_l425_d24_uses(args ...ruby.Value) ruby.Value {
	single := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		headers: [
			'Accept: */*',
		]
	})
	multiple := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		headers: ['Accept: */*', 'X-Requested-With: XMLHttpRequest']
	})
	return ruby.bool_value(single.join(' ').contains('--header Accept: */*') && multiple.join(' ').contains('--header Accept: */* --header X-Requested-With: XMLHttpRequest'))
}

// Ruby it `it "uses `--referer` when :referer is present" do` at line 432.
pub fn ruby_curl_spec_l432_d25_uses(args ...ruby.Value) ruby.Value {
	arguments := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], referer: 'https://brew.sh' })
	return ruby.bool_value(curl_spec_has_pair(arguments, '--referer', 'https://brew.sh'))
}

// Ruby it `it "doesn't use `--referer` when :referer is nil" do` at line 436.
pub fn ruby_curl_spec_l436_d26_doesn(args ...ruby.Value) ruby.Value {
	return ruby.bool_value('--referer' !in curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
	}))
}

// Ruby it `it "omits `--user-agent` when `:user_agent` is `:curl`" do` at line 440.
pub fn ruby_curl_spec_l440_d27_omits(args ...ruby.Value) ruby.Value {
	return ruby.bool_value('--user-agent' !in curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		user_agent: 'curl'
	}))
}

// Ruby it `it "uses HOMEBREW_USER_AGENT_FAKE_SAFARI when `:user_agent` is `:browser` or `:fake`" do` at line 444.
pub fn ruby_curl_spec_l444_d28_uses(args ...ruby.Value) ruby.Value {
	browser := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], user_agent: 'browser' })
	fake := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], user_agent: 'fake' })
	return ruby.bool_value(curl_spec_has_pair(browser, '--user-agent', curl_spec_browser_user_agent) && curl_spec_has_pair(fake, '--user-agent', curl_spec_browser_user_agent))
}

// Ruby it `it "uses HOMEBREW_USER_AGENT_CURL when `:user_agent` is `:default` or omitted" do` at line 451.
pub fn ruby_curl_spec_l451_d29_uses(args ...ruby.Value) ruby.Value {
	explicit := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], user_agent: 'default' })
	nil_or_omitted := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'] })
	return ruby.bool_value(curl_spec_has_pair(explicit, '--user-agent', curl_spec_default_user_agent) && curl_spec_has_pair(nil_or_omitted, '--user-agent', curl_spec_default_user_agent))
}

// Ruby it `it "uses provided user agent string when `:user_agent` is a `String`" do` at line 457.
pub fn ruby_curl_spec_l457_d30_uses(args ...ruby.Value) ruby.Value {
	agent := 'Lorem ipsum dolor sit amet'
	arguments := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		user_agent: 'string'
		custom_user_agent: agent
	})
	return ruby.bool_value(curl_spec_has_pair(arguments, '--user-agent', agent))
}

// Ruby it `it "errors when `:user_agent` is not a String or supported Symbol" do` at line 462.
pub fn ruby_curl_spec_l462_d31_errors(args ...ruby.Value) ruby.Value {
	if _ := curl.curl_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		user_agent: 'an_unsupported_symbol'
	}) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == ':user_agent must be :browser/:fake, :default, :curl, or a String')
	}
}

// Ruby it `it "uses `--fail` unless `:show_output` is `true`" do` at line 468.
pub fn ruby_curl_spec_l468_d32_uses(args ...ruby.Value) ruby.Value {
	shown_false := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], show_output: false })
	omitted := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'] })
	shown_true := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], show_output: true })
	return ruby.bool_value('--fail' in shown_false && '--fail' in omitted && '--fail' !in shown_true)
}

// Ruby it `it "uses `--progress-bar` outside of a `--verbose` context" do` at line 475.
pub fn ruby_curl_spec_l475_d33_uses(args ...ruby.Value) ruby.Value {
	normal := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'] })
	verbose := curl_spec_args(curl.CurlArgsOptions{ extra_args: ['foo'], verbose_context: true })
	return ruby.bool_value('--progress-bar' in normal && '--progress-bar' !in verbose)
}

// Ruby it `it "uses `--verbose`" do` at line 487.
pub fn ruby_curl_spec_l487_d34_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value('--verbose' in curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		curl_verbose: true
	}))
}

// Ruby it `it "doesn't use `--verbose`" do` at line 497.
pub fn ruby_curl_spec_l497_d35_doesn(args ...ruby.Value) ruby.Value {
	return ruby.bool_value('--verbose' !in curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		curl_verbose: false
	}))
}

// Ruby it `it "uses `--silent`" do` at line 507.
pub fn ruby_curl_spec_l507_d36_uses(args ...ruby.Value) ruby.Value {
	return ruby.bool_value('--silent' in curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		stdout_tty: false
	}))
}

// Ruby it `it "doesn't use `--silent` outside of a `--quiet` context" do` at line 517.
pub fn ruby_curl_spec_l517_d37_doesn(args ...ruby.Value) ruby.Value {
	not_quiet := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		stdout_tty: true
		quiet_context: false
	})
	quiet := curl_spec_args(curl.CurlArgsOptions{
		extra_args: ['foo']
		stdout_tty: true
		quiet_context: true
	})
	return ruby.bool_value('--silent' !in not_quiet && '--silent' in quiet)
}

// Ruby it `it "returns `true` when a URL is protected by Cloudflare" do` at line 530.
pub fn ruby_curl_spec_l530_d38_returns(args ...ruby.Value) ruby.Value {
	single := curl_spec_cloudflare(['__cf_bm=0123456789abcdef'], 'cloudflare', true)
	multiple := curl_spec_cloudflare(['first_cookie=for_testing', '__cf_bm=abcdef0123456789',
		'last_cookie=also_for_testing'], 'cloudflare', true)
	return ruby.bool_value(curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
		status_code: single.status_code
		headers: single.headers
	}) && curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
		status_code: multiple.status_code
		headers: multiple.headers
	}))
}

// Ruby it `it "returns `false` when a URL is not protected by Cloudflare" do` at line 535.
pub fn ruby_curl_spec_l535_d39_returns(args ...ruby.Value) ruby.Value {
	no_server := curl_spec_cloudflare(['__cf_bm=x'], '', false)
	wrong_server := curl_spec_cloudflare(['__cf_bm=x'], 'nginx 1.2.3', true)
	normal := [
		curl_spec_normal('403', []),
		curl_spec_normal('200', []),
		curl_spec_normal('403', ['a_cookie=for_testing']),
		curl_spec_normal('403', ['first_cookie=for_testing', 'last_cookie=also_for_testing']),
	]
	mut protected := curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
		status_code: no_server.status_code
		headers: no_server.headers
	}) || curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
		status_code: wrong_server.status_code
		headers: wrong_server.headers
	})
	for detail in normal {
		protected = protected || curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
			status_code: detail.status_code
			headers: detail.headers
		})
	}
	return ruby.bool_value(!protected)
}

// Ruby it `it "returns `false` when response headers are blank" do` at line 544.
pub fn ruby_curl_spec_l544_d40_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_url_protected_by_cloudflare(curl.CurlResponse{
		status_code: '403'
		headers: map[string][]string{}
	}))
}

// Ruby it `it "returns `true` when a URL is protected by Cloudflare" do` at line 550.
pub fn ruby_curl_spec_l550_d41_returns(args ...ruby.Value) ruby.Value {
	cases := [
		['visid_incap_something=something'],
		['incap_ses_something=something'],
		['first_cookie=for_testing', 'visid_incap_something=something', 'last_cookie=also_for_testing'],
		['first_cookie=for_testing', 'incap_ses_something=something', 'last_cookie=also_for_testing'],
	]
	return ruby.bool_value(cases.all(curl.curl_url_protected_by_incapsula(curl.CurlResponse{
		status_code: '403'
		headers: {
			'set-cookie': it
		}
	})))
}

// Ruby it `it "returns `false` when a URL is not protected by Incapsula" do` at line 557.
pub fn ruby_curl_spec_l557_d42_returns(args ...ruby.Value) ruby.Value {
	cases := [
		[]string{},
		[]string{},
		['a_cookie=for_testing'],
		['first_cookie=for_testing', 'last_cookie=also_for_testing'],
	]
	return ruby.bool_value(cases.all(!curl.curl_url_protected_by_incapsula(curl.CurlResponse{
		status_code: '403'
		headers: if it.len > 0 {
			{
				'set-cookie': it
			}} else {
			map[string][]string{}}
	})))
}

// Ruby it `it "returns `false` when response headers are blank" do` at line 564.
pub fn ruby_curl_spec_l564_d43_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_url_protected_by_incapsula(curl.CurlResponse{
		status_code: '403'
		headers: map[string][]string{}
	}))
}

// Ruby it `it "returns a curl version string" do` at line 570.
pub fn ruby_curl_spec_l570_d44_returns(args ...ruby.Value) ruby.Value {
	mut runtime := curl.CurlRuntime{
		shim_path: '/homebrew/shims/shared/curl'
		brewed_path: '/homebrew/opt/curl/bin/curl'
		runner: curl_spec_runtime_runner
		version_cache: map[string]string{}
	}
	version := runtime.version() or { return ruby.bool_value(false) }
	parts := version.trim_left('v').split('.')
	return ruby.bool_value(parts.len > 1 && parts.all(it.bytes().all(it.is_digit())))
}

// Ruby it `it "returns `true` if curl version is 7.76.0 or higher" do` at line 576.
pub fn ruby_curl_spec_l576_d45_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl.curl_supports_fail_with_body('7.76.0') && curl.curl_supports_fail_with_body('7.76.1'))
}

// Ruby it `it "returns `false` if curl version is lower than 7.76.0" do` at line 584.
pub fn ruby_curl_spec_l584_d46_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_supports_fail_with_body('7.75.0'))
}

// Ruby it `it "returns `true` if curl command is successful" do` at line 591.
pub fn ruby_curl_spec_l591_d47_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl.curl_supports_tls13(curl.CurlCommandResult{
		exit_status: 0
	}))
}

// Ruby it `it "returns `false` if curl command is not successful" do` at line 596.
pub fn ruby_curl_spec_l596_d48_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_supports_tls13(curl.CurlCommandResult{
		exit_status: 1
	}))
}

// Ruby it `it "only allows HTTPS redirects for redirect-following calls" do` at line 607.
pub fn ruby_curl_spec_l607_d49_only(args ...ruby.Value) ruby.Value {
	actual := curl.curl_no_insecure_redirect_args(['--location', 'http://example.com/example.tar.gz'], true)
	return ruby.bool_value(actual == ['--proto-redir', '=https', '--location',
		'http://example.com/example.tar.gz'])
}

// Ruby it `it "drops custom redirect protocol arguments" do` at line 612.
pub fn ruby_curl_spec_l612_d50_drops(args ...ruby.Value) ruby.Value {
	actual := curl.curl_no_insecure_redirect_args(['--location', '--proto-redir', '=all',
		'https://example.com/example.tar.gz'], true)
	return ruby.bool_value(actual == ['--proto-redir', '=https', '--location',
		'https://example.com/example.tar.gz'])
}

// Ruby it `it "drops custom redirect protocol arguments in assignment form" do` at line 618.
pub fn ruby_curl_spec_l618_d51_drops(args ...ruby.Value) ruby.Value {
	actual := curl.curl_no_insecure_redirect_args(['--location', '--proto-redir=all',
		'https://example.com/example.tar.gz'], true)
	return ruby.bool_value(actual == ['--proto-redir', '=https', '--location',
		'https://example.com/example.tar.gz'])
}

// Ruby it `it "enforces HTTPS redirects before running curl" do` at line 626.
pub fn ruby_curl_spec_l626_d52_enforces(args ...ruby.Value) ruby.Value {
	mut runtime := curl.CurlRuntime{
		shim_path: '/homebrew/shims/shared/curl'
		brewed_path: '/homebrew/opt/curl/bin/curl'
		runner: curl_spec_runtime_runner
	}
	result := curl.curl_output(mut runtime, curl.CurlRunRequest{
		args: ['--location', 'https://example.com/example.tar.gz']
		no_insecure: true
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(curl_spec_has_pair(result.arguments, '--proto-redir', '=https'))
}

// Ruby it `it "does not expand deferred environment placeholders" do` at line 639.
pub fn ruby_curl_spec_l639_d53_does(args ...ruby.Value) ruby.Value {
	deferred_url := 'https://example.com/example.tar.gz?private_token={{HOMEBREW_DEFERRED_ENV:HOMEBREW_PRIVATE_TOKEN}}'
	mut runtime := curl.CurlRuntime{
		shim_path: '/homebrew/shims/shared/curl'
		brewed_path: '/homebrew/opt/curl/bin/curl'
		runner: curl_spec_runtime_runner
	}
	result := curl.curl_output(mut runtime, curl.CurlRunRequest{
		args: [deferred_url]
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(deferred_url in result.arguments)
}

// Ruby method `curl_args_for(**options)` at line 657.
pub fn ruby_curl_spec_l657_d54_curl_args_for(args ...ruby.Value) ruby.Value {
	head_only := args.len > 0 && args[0].bool_data
	return ruby.string_array_value(curl.curl_http_content_args(curl.CurlFetchRequest{
		url: 'https://brew.sh/'
		head_only: head_only
	}, '/tmp/homebrew-curl-body'))
}

// Ruby it `it "requests headers only when `head_only` is set" do` at line 667.
pub fn ruby_curl_spec_l667_d55_requests(args ...ruby.Value) ruby.Value {
	arguments := curl.curl_http_content_args(curl.CurlFetchRequest{
		url: 'https://brew.sh/'
		head_only: true
	}, '/tmp/homebrew-curl-body')
	return ruby.bool_value('--head' in arguments)
}

// Ruby it `it "does not write the body to a file when `head_only` is set" do` at line 671.
pub fn ruby_curl_spec_l671_d56_does(args ...ruby.Value) ruby.Value {
	arguments := curl.curl_http_content_args(curl.CurlFetchRequest{
		url: 'https://brew.sh/'
		head_only: true
	}, '/tmp/homebrew-curl-body')
	return ruby.bool_value('--output' !in arguments)
}

// Ruby it `it "does not combine `--dump-header` with `--head`" do` at line 675.
pub fn ruby_curl_spec_l675_d57_does(args ...ruby.Value) ruby.Value {
	arguments := curl.curl_http_content_args(curl.CurlFetchRequest{
		url: 'https://brew.sh/'
		head_only: true
	}, '/tmp/homebrew-curl-body')
	return ruby.bool_value('--dump-header' !in arguments && '--head' in arguments)
}

// Ruby it `it "downloads the body when `head_only` is not set" do` at line 679.
pub fn ruby_curl_spec_l679_d58_downloads(args ...ruby.Value) ruby.Value {
	arguments := curl.curl_http_content_args(curl.CurlFetchRequest{
		url: 'https://brew.sh/'
		head_only: false
	}, '/tmp/homebrew-curl-body')
	return ruby.bool_value('--output' in arguments)
}

// Ruby let `let(:response) do` at line 685.
pub fn ruby_curl_spec_l685_d59_response(args ...ruby.Value) ruby.Value {
	return curl_spec_detail_value(curl_spec_response('200', 0))
}

// Ruby method `record_head_only(*responses)` at line 701.
pub fn ruby_curl_spec_l701_d60_record_head_only(args ...ruby.Value) ruby.Value {
	// The helper returns its newly allocated recording before the mocked fetch is invoked.
	return ruby.array_value([]ruby.Value{})
}

// Ruby it `it "requests headers only for an HTTPS URL" do` at line 710.
pub fn ruby_curl_spec_l710_d61_requests(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_require_https_head) == '')
}

// Ruby it `it "downloads the body for an HTTP URL, which needs it for comparison" do` at line 716.
pub fn ruby_curl_spec_l716_d62_downloads(args ...ruby.Value) ruby.Value {
	result := curl.curl_check_http_content(curl.CurlCheckRequest{
		url: 'http://brew.sh/'
		url_type: 'homepage URL'
	}, curl_spec_fetch_require_http_body) or { err.msg() }
	return ruby.bool_value(result == '')
}

// Ruby it `it "retries as a `GET` when the server rejects `HEAD`" do` at line 722.
pub fn ruby_curl_spec_l722_d63_retries(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_head_405_get_200) == '')
}

// Ruby it `it "reports the problem from the `GET` when the server rejects `HEAD`" do` at line 728.
pub fn ruby_curl_spec_l728_d64_reports(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_head_405_get_500).contains('HTTP status code 500'))
}

// Ruby it `it "retries as a `GET` when `HEAD` failed with exit status` at line 736.
pub fn ruby_curl_spec_l736_d65_retries(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_head_28_get_200) == '' && curl_spec_check(curl_spec_fetch_head_52_get_200) == '' && curl_spec_check(curl_spec_fetch_head_56_get_200) == '')
}

// Ruby it `it "does not retry as a `GET` when `HEAD` failed with exit status` at line 745.
pub fn ruby_curl_spec_l745_d66_does(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_head_6_get_200).contains('is not reachable') && curl_spec_check(curl_spec_fetch_head_7_get_200).contains('is not reachable'))
}

// Ruby it `it "still reports an unreachable URL when the `GET` retry also fails" do` at line 752.
pub fn ruby_curl_spec_l752_d67_still(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl_spec_check(curl_spec_fetch_always_28).contains('is not reachable'))
}

// Ruby it `it "returns `true` when `status` is 1xx or 2xx" do` at line 760.
pub fn ruby_curl_spec_l760_d68_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl.curl_http_status_ok('200'))
}

// Ruby it `it "returns `false` when `status` is not 1xx or 2xx" do` at line 764.
pub fn ruby_curl_spec_l764_d69_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_http_status_ok('301'))
}

// Ruby it `it "returns `false` when `status` is `nil`" do` at line 768.
pub fn ruby_curl_spec_l768_d70_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!curl.curl_http_status_ok(none))
}

// Ruby it `it "removes the percentage when other text is glued directly onto it" do` at line 774.
pub fn ruby_curl_spec_l774_d71_removes(args ...ruby.Value) ruby.Value {
	glued := "############# 100.0%curl: (7) Failed to connect to example.com port 443: Couldn't connect to server"
	expected := "curl: (7) Failed to connect to example.com port 443: Couldn't connect to server"
	return ruby.bool_value(curl.curl_strip_progress_bar(glued) == expected)
}

// Ruby it `it "reduces a completed progress bar with nothing else on the line to an empty string" do` at line 780.
pub fn ruby_curl_spec_l780_d72_reduces(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(curl.curl_strip_progress_bar('############# 100.0%') == '')
}

// Ruby it `it "leaves plain curl diagnostics without a progress bar unchanged" do` at line 784.
pub fn ruby_curl_spec_l784_d73_leaves(args ...ruby.Value) ruby.Value {
	message := 'curl: (6) Could not resolve host: example.com'
	return ruby.bool_value(curl.curl_strip_progress_bar(message) == message)
}

// Ruby it `it "only strips the line that actually has a progress bar" do` at line 789.
pub fn ruby_curl_spec_l789_d74_only(args ...ruby.Value) ruby.Value {
	glued := 'Warning: retrying\n### 50.0%curl: (7) timeout'
	return ruby.bool_value(curl.curl_strip_progress_bar(glued) == 'Warning: retrying\ncurl: (7) timeout')
}

// Ruby it `it "returns a correct hash when curl output contains response(s) and body" do` at line 796.
pub fn ruby_curl_spec_l796_d75_returns(args ...ruby.Value) ruby.Value {
	texts := curl_spec_response_texts()
	bodies := curl_spec_bodies()
	responses := curl_spec_response_fixtures()
	first := curl.curl_parse_output(texts['ok'] + bodies['default'], 25) or {
		return ruby.bool_value(false)
	}
	second := curl.curl_parse_output(texts['ok'] + bodies['with_carriage_returns'], 25) or {
		return ruby.bool_value(false)
	}
	third := curl.curl_parse_output(texts['ok'] + bodies['with_http_status_line'], 25) or {
		return ruby.bool_value(false)
	}
	fourth := curl.curl_parse_output(texts['redirection_to_ok'] + bodies['default'], 25) or {
		return ruby.bool_value(false)
	}
	fifth := curl.curl_parse_output(texts['redirections_to_ok'] + bodies['default'], 25) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(curl_spec_parsed_equal(first, [responses['ok']], bodies['default']) && curl_spec_parsed_equal(second, [
		responses['ok'],
	], bodies['with_carriage_returns']) && curl_spec_parsed_equal(third, [
		responses['ok'],
	], bodies['with_http_status_line']) && curl_spec_parsed_equal(fourth, [
		responses['redirection'],
		responses['ok'],
	], bodies['default']) && curl_spec_parsed_equal(fifth, [responses['redirection2'],
		responses['redirection1'], responses['redirection'], responses['ok']], bodies['default']))
}

// Ruby it `it "returns a correct hash when curl output contains HTTP response text and no body" do` at line 817.
pub fn ruby_curl_spec_l817_d76_returns(args ...ruby.Value) ruby.Value {
	texts := curl_spec_response_texts()
	responses := curl_spec_response_fixtures()
	parsed := curl.curl_parse_output(texts['ok'], 25) or { return ruby.bool_value(false) }
	return ruby.bool_value(curl_spec_parsed_equal(parsed, [responses['ok']], ''))
}

// Ruby it `it "returns a correct hash when curl output contains body and no HTTP response text" do` at line 821.
pub fn ruby_curl_spec_l821_d77_returns(args ...ruby.Value) ruby.Value {
	bodies := curl_spec_bodies()
	for body in [bodies['default'], bodies['with_carriage_returns'], bodies['with_http_status_line']] {
		parsed := curl.curl_parse_output(body, 25) or { return ruby.bool_value(false) }
		if !curl_spec_parsed_equal(parsed, []curl.CurlResponse{}, body) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns correct hash when curl output is blank" do` at line 829.
pub fn ruby_curl_spec_l829_d78_returns(args ...ruby.Value) ruby.Value {
	parsed := curl.curl_parse_output('', 25) or { return ruby.bool_value(false) }
	return ruby.bool_value(curl_spec_parsed_equal(parsed, []curl.CurlResponse{}, ''))
}

// Ruby it `it "errors if response count exceeds `max_iterations`" do` at line 833.
pub fn ruby_curl_spec_l833_d79_errors(args ...ruby.Value) ruby.Value {
	if _ := curl.curl_parse_output(curl_spec_response_texts()['redirections_to_ok'], 1) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == 'Too many redirects (max = 1)')
	}
}

// Ruby it `it "returns a correct hash when given HTTP response text" do` at line 841.
pub fn ruby_curl_spec_l841_d80_returns(args ...ruby.Value) ruby.Value {
	texts := curl_spec_response_texts()
	responses := curl_spec_response_fixtures()
	for name in ['ok', 'ok_no_status_text', 'ok_blank_header_value', 'redirection', 'duplicate_header'] {
		if !curl_spec_response_equal(curl.curl_parse_response(texts[name]), responses[name]) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "skips over response header lines with blank header name" do` at line 849.
pub fn ruby_curl_spec_l849_d81_skips(args ...ruby.Value) ruby.Value {
	texts := curl_spec_response_texts()
	return ruby.bool_value(curl_spec_response_equal(curl.curl_parse_response(texts['ok_blank_header_name']), curl_spec_response_fixtures()['ok']))
}

// Ruby it `it "returns an empty hash when given an empty string" do` at line 853.
pub fn ruby_curl_spec_l853_d82_returns(args ...ruby.Value) ruby.Value {
	response := curl.curl_parse_response('')
	return ruby.bool_value(response.status_code == '' && response.status_text == '' && response.headers.len == 0)
}

// Ruby it `it "returns the last location header when given an array of HTTP response hashes" do` at line 859.
pub fn ruby_curl_spec_l859_d83_returns(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	first := curl.curl_response_last_location([responses['redirection'], responses['ok']], false, '') or { '' }
	second := curl.curl_response_last_location([responses['redirection2'], responses['redirection1'],
		responses['redirection'], responses['ok']], false, '') or { '' }
	return ruby.bool_value(first == responses['redirection'].headers['location'][0] && second == responses['redirection'].headers['location'][0])
}

// Ruby it `it "returns the location as given, by default or when absolutize is false" do` at line 873.
pub fn ruby_curl_spec_l873_d84_returns(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	for name in ['redirection_no_scheme', 'redirection_root_relative', 'redirection_parent_relative'] {
		location := curl.curl_response_last_location([responses[name], responses['ok']], false, '') or { return ruby.bool_value(false) }
		if location != responses[name].headers['location'][0] {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns an absolute URL when absolutize is true and a base URL is provided" do` at line 890.
pub fn ruby_curl_spec_l890_d85_returns(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	no_scheme := curl.curl_response_last_location([responses['redirection_no_scheme'],
		responses['ok']], true, 'https://brew.sh/test') or { return ruby.bool_value(false) }
	root_relative := curl.curl_response_last_location([
		responses['redirection_root_relative'],
		responses['ok'],
	], true, 'https://brew.sh/test') or {
		return ruby.bool_value(false)
	}
	parent_relative := curl.curl_response_last_location([
		responses['redirection_parent_relative'],
		responses['ok'],
	], true, 'https://brew.sh/test1/test2') or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(no_scheme == 'https://www.example.com/example/' && root_relative == 'https://brew.sh/example/' && parent_relative == 'https://brew.sh/test1/example/')
}

// Ruby it `it "skips response hashes without a `:headers` value" do` at line 916.
pub fn ruby_curl_spec_l916_d86_skips(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	location := curl.curl_response_last_location([
		responses['redirection'],
		curl.CurlResponse{ status_code: '404', status_text: 'Not Found' },
		responses['ok'],
	], false, '') or { return ruby.bool_value(false) }
	return ruby.bool_value(location == responses['redirection'].headers['location'][0])
}

// Ruby it `it "returns nil when the response hash doesn't contain a location header" do` at line 924.
pub fn ruby_curl_spec_l924_d87_returns(args ...ruby.Value) ruby.Value {
	if _ := curl.curl_response_last_location([curl_spec_response_fixtures()['ok']], false, '') {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns the original URL when there are no location headers" do` at line 930.
pub fn ruby_curl_spec_l930_d88_returns(args ...ruby.Value) ruby.Value {
	initial := 'https://brew.sh/test1/test2'
	return ruby.bool_value(curl.curl_response_follow_redirections([
		curl_spec_response_fixtures()['ok'],
	], initial) == initial)
}

// Ruby it `it "returns the URL relative to base when locations are relative" do` at line 939.
pub fn ruby_curl_spec_l939_d89_returns(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	initial := 'https://brew.sh/test1/test2'
	root_relative := curl.curl_response_follow_redirections([
		responses['redirection_root_relative'],
		responses['ok'],
	], initial)
	parent_relative := curl.curl_response_follow_redirections([
		responses['redirection_parent_relative'],
		responses['ok'],
	], initial)
	two_parent_relative := curl.curl_response_follow_redirections([
		responses['redirection_parent_relative'],
		responses['redirection_parent_relative'],
		responses['ok'],
	], initial)
	return ruby.bool_value(root_relative == 'https://brew.sh/example/' && parent_relative == 'https://brew.sh/test1/example/' && two_parent_relative == 'https://brew.sh/test1/example/example/')
}

// Ruby it `it "returns new base when there are absolute location(s)" do` at line 966.
pub fn ruby_curl_spec_l966_d90_returns(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	initial := 'https://brew.sh/test1/test2'
	absolute := curl.curl_response_follow_redirections([responses['redirection'], responses['ok']], initial)
	absolute_then_relative := curl.curl_response_follow_redirections([
		responses['redirection'],
		responses['redirection_parent_relative'],
		responses['ok'],
	], initial)
	return ruby.bool_value(absolute == 'https://example.com/example/' && absolute_then_relative == 'https://example.com/example/example/')
}

// Ruby it `it "skips response hashes without a `:headers` value" do` at line 982.
pub fn ruby_curl_spec_l982_d91_skips(args ...ruby.Value) ruby.Value {
	responses := curl_spec_response_fixtures()
	actual := curl.curl_response_follow_redirections([
		responses['redirection_root_relative'],
		curl.CurlResponse{ status_code: '404', status_text: 'Not Found' },
		responses['ok'],
	], 'https://brew.sh/test1/test2')
	return ruby.bool_value(actual == 'https://brew.sh/example/')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5:
// 6: RSpec.describe "Utils::Curl" do
// 7:   include Utils::Curl
// 8:
// 9:   let(:details) do
// 10:     details = {
// 11:       normal:     {},
// 12:       cloudflare: {},
// 13:       incapsula:  {},
// 14:     }
// 15:
// 16:     details[:normal][:no_cookie] = {
// 17:       url:            "https://www.example.com/",
// 18:       final_url:      nil,
// 19:       status_code:    "403",
// 20:       headers:        {
// 21:         "age"            => "123456",
// 22:         "cache-control"  => "max-age=604800",
// 23:         "content-type"   => "text/html; charset=UTF-8",
// 24:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 25:         "etag"           => "\"3147526947+ident\"",
// 26:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 27:         "last-modified"  => "Wed, 1 Jan 2020 00:00:00 GMT",
// 28:         "server"         => "ECS (dcb/7EA2)",
// 29:         "vary"           => "Accept-Encoding",
// 30:         "x-cache"        => "HIT",
// 31:         "content-length" => "3",
// 32:       },
// 33:       etag:           "3147526947+ident",
// 34:       content_length: "3",
// 35:       file:           "...",
// 36:       file_hash:      nil,
// 37:     }
// 38:
// 39:     details[:normal][:ok] = details[:normal][:no_cookie].deep_dup
// 40:     details[:normal][:ok][:status_code] = "200"
// 41:
// 42:     details[:normal][:single_cookie] = details[:normal][:no_cookie].deep_dup
// 43:     details[:normal][:single_cookie][:headers]["set-cookie"] = "a_cookie=for_testing"
// 44:
// 45:     details[:normal][:multiple_cookies] = details[:normal][:no_cookie].deep_dup
// 46:     details[:normal][:multiple_cookies][:headers]["set-cookie"] = [
// 47:       "first_cookie=for_testing",
// 48:       "last_cookie=also_for_testing",
// 49:     ]
// 50:
// 51:     details[:normal][:blank_headers] = details[:normal][:no_cookie].deep_dup
// 52:     details[:normal][:blank_headers][:headers] = {}
// 53:
// 54:     details[:cloudflare][:single_cookie] = {
// 55:       url:            "https://www.example.com/",
// 56:       final_url:      nil,
// 57:       status_code:    "403",
// 58:       headers:        {
// 59:         "date"            => "Wed, 1 Jan 2020 01:23:45 GMT",
// 60:         "content-type"    => "text/plain; charset=UTF-8",
// 61:         "content-length"  => "16",
// 62:         "x-frame-options" => "SAMEORIGIN",
// 63:         "referrer-policy" => "same-origin",
// 64:         "cache-control"   => "private, max-age=0, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
// 65:         "expires"         => "Thu, 01 Jan 1970 00:00:01 GMT",
// 66:         "expect-ct"       => "max-age=604800, report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\"",
// 67:         "set-cookie"      => "__cf_bm=0123456789abcdef; path=/; expires=Wed, 31-Jan-20 01:23:45 GMT; " \
// 68:                              "domain=www.example.com; HttpOnly; Secure; SameSite=None",
// 69:         "server"          => "cloudflare",
// 70:         "cf-ray"          => "0123456789abcdef-IAD",
// 71:         "alt-svc"         => "h3=\":443\"; ma=86400, h3-29=\":443\"; ma=86400",
// 72:       },
// 73:       etag:           nil,
// 74:       content_length: "16",
// 75:       file:           "error code: 1020",
// 76:       file_hash:      nil,
// 77:     }
// 78:
// 79:     details[:cloudflare][:multiple_cookies] = details[:cloudflare][:single_cookie].deep_dup
// 80:     details[:cloudflare][:multiple_cookies][:headers]["set-cookie"] = [
// 81:       "first_cookie=for_testing",
// 82:       "__cf_bm=abcdef0123456789; path=/; expires=Thu, 28-Apr-22 18:38:40 GMT; domain=www.example.com; HttpOnly; " \
// 83:       "Secure; SameSite=None",
// 84:       "last_cookie=also_for_testing",
// 85:     ]
// 86:
// 87:     details[:cloudflare][:no_server] = details[:cloudflare][:single_cookie].deep_dup
// 88:     details[:cloudflare][:no_server][:headers].delete("server")
// 89:
// 90:     details[:cloudflare][:wrong_server] = details[:cloudflare][:single_cookie].deep_dup
// 91:     details[:cloudflare][:wrong_server][:headers]["server"] = "nginx 1.2.3"
// 92:
// 93:     # TODO: Make the Incapsula test data more realistic once we can find an
// 94:     #       example website to reference.
// 95:     details[:incapsula][:single_cookie_visid_incap] = details[:normal][:no_cookie].deep_dup
// 96:     details[:incapsula][:single_cookie_visid_incap][:headers]["set-cookie"] = "visid_incap_something=something"
// 97:
// 98:     details[:incapsula][:single_cookie_incap_ses] = details[:normal][:no_cookie].deep_dup
// 99:     details[:incapsula][:single_cookie_incap_ses][:headers]["set-cookie"] = "incap_ses_something=something"
// 100:
// 101:     details[:incapsula][:multiple_cookies_visid_incap] = details[:normal][:no_cookie].deep_dup
// 102:     details[:incapsula][:multiple_cookies_visid_incap][:headers]["set-cookie"] = [
// 103:       "first_cookie=for_testing",
// 104:       "visid_incap_something=something",
// 105:       "last_cookie=also_for_testing",
// 106:     ]
// 107:
// 108:     details[:incapsula][:multiple_cookies_incap_ses] = details[:normal][:no_cookie].deep_dup
// 109:     details[:incapsula][:multiple_cookies_incap_ses][:headers]["set-cookie"] = [
// 110:       "first_cookie=for_testing",
// 111:       "incap_ses_something=something",
// 112:       "last_cookie=also_for_testing",
// 113:     ]
// 114:
// 115:     details
// 116:   end
// 117:
// 118:   let(:location_urls) do
// 119:     %w[
// 120:       https://example.com/example/
// 121:       https://example.com/example1/
// 122:       https://example.com/example2/
// 123:     ]
// 124:   end
// 125:
// 126:   let(:response_hash) do
// 127:     response_hash = {}
// 128:
// 129:     response_hash[:ok] = {
// 130:       status_code: "200",
// 131:       status_text: "OK",
// 132:       headers:     {
// 133:         "cache-control"  => "max-age=604800",
// 134:         "content-type"   => "text/html; charset=UTF-8",
// 135:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 136:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 137:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 138:         "content-length" => "123",
// 139:       },
// 140:     }
// 141:
// 142:     response_hash[:ok_no_status_text] = response_hash[:ok].deep_dup
// 143:     response_hash[:ok_no_status_text].delete(:status_text)
// 144:
// 145:     response_hash[:ok_blank_header_value] = response_hash[:ok].deep_dup
// 146:     response_hash[:ok_blank_header_value][:headers]["range"] = ""
// 147:
// 148:     response_hash[:redirection] = {
// 149:       status_code: "301",
// 150:       status_text: "Moved Permanently",
// 151:       headers:     {
// 152:         "cache-control"  => "max-age=604800",
// 153:         "content-type"   => "text/html; charset=UTF-8",
// 154:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 155:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 156:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 157:         "content-length" => "123",
// 158:         "location"       => location_urls[0],
// 159:       },
// 160:     }
// 161:
// 162:     response_hash[:redirection1] = {
// 163:       status_code: "301",
// 164:       status_text: "Moved Permanently",
// 165:       headers:     {
// 166:         "cache-control"  => "max-age=604800",
// 167:         "content-type"   => "text/html; charset=UTF-8",
// 168:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 169:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 170:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 171:         "content-length" => "123",
// 172:         "location"       => location_urls[1],
// 173:       },
// 174:     }
// 175:
// 176:     response_hash[:redirection2] = {
// 177:       status_code: "301",
// 178:       status_text: "Moved Permanently",
// 179:       headers:     {
// 180:         "cache-control"  => "max-age=604800",
// 181:         "content-type"   => "text/html; charset=UTF-8",
// 182:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 183:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 184:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 185:         "content-length" => "123",
// 186:         "location"       => location_urls[2],
// 187:       },
// 188:     }
// 189:
// 190:     response_hash[:redirection_no_scheme] = {
// 191:       status_code: "301",
// 192:       status_text: "Moved Permanently",
// 193:       headers:     {
// 194:         "cache-control"  => "max-age=604800",
// 195:         "content-type"   => "text/html; charset=UTF-8",
// 196:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 197:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 198:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 199:         "content-length" => "123",
// 200:         "location"       => "//www.example.com/example/",
// 201:       },
// 202:     }
// 203:
// 204:     response_hash[:redirection_root_relative] = {
// 205:       status_code: "301",
// 206:       status_text: "Moved Permanently",
// 207:       headers:     {
// 208:         "cache-control"  => "max-age=604800",
// 209:         "content-type"   => "text/html; charset=UTF-8",
// 210:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 211:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 212:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 213:         "content-length" => "123",
// 214:         "location"       => "/example/",
// 215:       },
// 216:     }
// 217:
// 218:     response_hash[:redirection_parent_relative] = {
// 219:       status_code: "301",
// 220:       status_text: "Moved Permanently",
// 221:       headers:     {
// 222:         "cache-control"  => "max-age=604800",
// 223:         "content-type"   => "text/html; charset=UTF-8",
// 224:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 225:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 226:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 227:         "content-length" => "123",
// 228:         "location"       => "./example/",
// 229:       },
// 230:     }
// 231:
// 232:     response_hash[:duplicate_header] = {
// 233:       status_code: "200",
// 234:       status_text: "OK",
// 235:       headers:     {
// 236:         "cache-control"  => "max-age=604800",
// 237:         "content-type"   => "text/html; charset=UTF-8",
// 238:         "date"           => "Wed, 1 Jan 2020 01:23:45 GMT",
// 239:         "expires"        => "Wed, 31 Jan 2020 01:23:45 GMT",
// 240:         "last-modified"  => "Thu, 1 Jan 2019 01:23:45 GMT",
// 241:         "content-length" => "123",
// 242:         "set-cookie"     => [
// 243:           "example1=first",
// 244:           "example2=second; Expires Wed, 31 Jan 2020 01:23:45 GMT",
// 245:           "example3=third",
// 246:         ],
// 247:       },
// 248:     }
// 249:
// 250:     response_hash
// 251:   end
// 252:
// 253:   let(:response_text) do
// 254:     response_text = {}
// 255:
// 256:     response_text[:ok] = <<~EOS
// 257:       HTTP/1.1 #{response_hash[:ok][:status_code]} #{response_hash[:ok][:status_text]}\r
// 258:       Cache-Control: #{response_hash[:ok][:headers]["cache-control"]}\r
// 259:       Content-Type: #{response_hash[:ok][:headers]["content-type"]}\r
// 260:       Date: #{response_hash[:ok][:headers]["date"]}\r
// 261:       Expires: #{response_hash[:ok][:headers]["expires"]}\r
// 262:       Last-Modified: #{response_hash[:ok][:headers]["last-modified"]}\r
// 263:       Content-Length: #{response_hash[:ok][:headers]["content-length"]}\r
// 264:       \r
// 265:     EOS
// 266:
// 267:     response_text[:ok_no_status_text] = response_text[:ok].sub(" #{response_hash[:ok][:status_text]}", "")
// 268:     response_text[:ok_blank_header_name] = response_text[:ok].sub(
// 269:       "#{response_hash[:ok][:headers]["date"]}\r\n",
// 270:       "#{response_hash[:ok][:headers]["date"]}\r\n: Test\r\n",
// 271:     )
// 272:     response_text[:ok_blank_header_value] = response_text[:ok].sub(
// 273:       "#{response_hash[:ok][:headers]["date"]}\r\n",
// 274:       "#{response_hash[:ok][:headers]["date"]}\r\nRange:\r\n",
// 275:     )
// 276:
// 277:     response_text[:redirection] = response_text[:ok].sub(
// 278:       "HTTP/1.1 #{response_hash[:ok][:status_code]} #{response_hash[:ok][:status_text]}\r",
// 279:       "HTTP/1.1 #{response_hash[:redirection][:status_code]} #{response_hash[:redirection][:status_text]}\r\n" \
// 280:       "Location: #{response_hash[:redirection][:headers]["location"]}\r",
// 281:     )
// 282:
// 283:     response_text[:redirection_to_ok] = "#{response_text[:redirection]}#{response_text[:ok]}"
// 284:
// 285:     response_text[:redirections_to_ok] = <<~EOS
// 286:       #{response_text[:redirection].sub(location_urls[0], location_urls[2])}
// 287:       #{response_text[:redirection].sub(location_urls[0], location_urls[1])}
// 288:       #{response_text[:redirection]}
// 289:       #{response_text[:ok]}
// 290:     EOS
// 291:
// 292:     response_text[:duplicate_header] = response_text[:ok].sub(
// 293:       /\r\n\Z/,
// 294:       "Set-Cookie: #{response_hash[:duplicate_header][:headers]["set-cookie"][0]}\r\n" \
// 295:       "Set-Cookie: #{response_hash[:duplicate_header][:headers]["set-cookie"][1]}\r\n" \
// 296:       "Set-Cookie: #{response_hash[:duplicate_header][:headers]["set-cookie"][2]}\r\n\r\n",
// 297:     )
// 298:
// 299:     response_text
// 300:   end
// 301:
// 302:   let(:body) do
// 303:     body = {}
// 304:
// 305:     body[:default] = <<~HTML
// 306:       <!DOCTYPE html>
// 307:       <html>
// 308:         <head>
// 309:           <meta charset="utf-8">
// 310:           <title>Example</title>
// 311:         </head>
// 312:         <body>
// 313:           <h1>Example</h1>
// 314:           <p>Hello, world!</p>
// 315:         </body>
// 316:       </html>
// 317:     HTML
// 318:
// 319:     body[:with_carriage_returns] = body[:default].sub("<html>\n", "<html>\r\n\r\n")
// 320:
// 321:     body[:with_http_status_line] = body[:default].sub("<html>", "HTTP/1.1 200\r\n<html>")
// 322:
// 323:     body
// 324:   end
// 325:
// 326:   describe "::curl_executable" do
// 327:     it "returns HOMEBREW_BREWED_CURL_PATH when `use_homebrew_curl` is `true`" do
// 328:       expect(curl_executable(use_homebrew_curl: true)).to eq(HOMEBREW_BREWED_CURL_PATH)
// 329:     end
// 330:
// 331:     it "returns curl shim path when `use_homebrew_curl` is `false` or omitted" do
// 332:       curl_shim_path = HOMEBREW_SHIMS_PATH/"shared/curl"
// 333:       expect(curl_executable(use_homebrew_curl: false)).to eq(curl_shim_path)
// 334:       expect(curl_executable).to eq(curl_shim_path)
// 335:     end
// 336:   end
// 337:
// 338:   describe "::curl_path" do
// 339:     it "returns a curl path string" do
// 340:       expect(curl_path).to match(%r{[^/]+(?:/[^/]+)*})
// 341:     end
// 342:   end
// 343:
// 344:   describe "::curl_args" do
// 345:     include Context
// 346:
// 347:     let(:args) { ["foo"] }
// 348:     let(:user_agent_string) { "Lorem ipsum dolor sit amet" }
// 349:
// 350:     it "returns `--disable` as the first argument when HOMEBREW_CURLRC is not set" do
// 351:       # --disable must be the first argument according to "man curl"
// 352:       expect(curl_args(*args).first).to eq("--disable")
// 353:     end
// 354:
// 355:     it "doesn't return `--disable` as the first argument when HOMEBREW_CURLRC is set but not a path" do
// 356:       ENV["HOMEBREW_CURLRC"] = "1"
// 357:       expect(curl_args(*args).first).not_to eq("--disable")
// 358:     end
// 359:
// 360:     it "doesn't return `--config` when HOMEBREW_CURLRC is unset" do
// 361:       expect(curl_args(*args)).not_to include(a_string_starting_with("--config"))
// 362:     end
// 363:
// 364:     it "returns `--config` when HOMEBREW_CURLRC is a valid path" do
// 365:       Tempfile.create do |tmpfile|
// 366:         path = tmpfile.path
// 367:         ENV["HOMEBREW_CURLRC"] = path
// 368:         # We still expect --disable
// 369:         expect(curl_args(*args).first).to eq("--disable")
// 370:         expect(curl_args(*args).join(" ")).to include("--config #{path}")
// 371:       end
// 372:     ensure
// 373:       ENV["HOMEBREW_CURLRC"] = nil
// 374:     end
// 375:
// 376:     it "uses `--connect-timeout` when `:connect_timeout` is Numeric" do
// 377:       expect(curl_args(*args, connect_timeout: 123).join(" ")).to include("--connect-timeout 123")
// 378:       expect(curl_args(*args, connect_timeout: 123.4).join(" ")).to include("--connect-timeout 123.4")
// 379:       expect(curl_args(*args, connect_timeout: 123.4567).join(" ")).to include("--connect-timeout 123.457")
// 380:     end
// 381:
// 382:     it "uses `--max-time` when `:max_time` is Numeric" do
// 383:       expect(curl_args(*args, max_time: 123).join(" ")).to include("--max-time 123")
// 384:       expect(curl_args(*args, max_time: 123.4).join(" ")).to include("--max-time 123.4")
// 385:       expect(curl_args(*args, max_time: 123.4567).join(" ")).to include("--max-time 123.457")
// 386:     end
// 387:
// 388:     it "uses `--retry 3` when HOMEBREW_CURL_RETRIES is unset" do
// 389:       expect(curl_args(*args).join(" ")).to include("--retry 3")
// 390:     end
// 391:
// 392:     it "uses the given value for `--retry` when HOMEBREW_CURL_RETRIES is set" do
// 393:       ENV["HOMEBREW_CURL_RETRIES"] = "10"
// 394:       expect(curl_args(*args).join(" ")).to include("--retry 10")
// 395:     end
// 396:
// 397:     it "uses `--retry` when `:retries` is a positive Integer" do
// 398:       expect(curl_args(*args, retries: 5).join(" ")).to include("--retry 5")
// 399:     end
// 400:
// 401:     it "doesn't use `--retry` when `:retries` is nil or a non-positive Integer" do
// 402:       expect(curl_args(*args, retries: nil).join(" ")).not_to include("--retry")
// 403:       expect(curl_args(*args, retries: 0).join(" ")).not_to include("--retry")
// 404:       expect(curl_args(*args, retries: -1).join(" ")).not_to include("--retry")
// 405:     end
// 406:
// 407:     it "uses `--retry-max-time` when `:retry_max_time` is Numeric" do
// 408:       expect(curl_args(*args, retry_max_time: 123).join(" ")).to include("--retry-max-time 123")
// 409:       expect(curl_args(*args, retry_max_time: 123.4).join(" ")).to include("--retry-max-time 123")
// 410:     end
// 411:
// 412:     it "uses `--show-error` when :show_error is `true`" do
// 413:       expect(curl_args(*args, show_error: true)).to include("--show-error")
// 414:       expect(curl_args(*args, show_error: false)).not_to include("--show-error")
// 415:     end
// 416:
// 417:     it "uses `--cookie` with argument when :cookies is present" do
// 418:       cookies = { "cookie_key" => "cookie_value" }
// 419:       expect(curl_args(*args, cookies:).join(" "))
// 420:         .not_to include("--cookie #{File::NULL}")
// 421:       expect(curl_args(*args, cookies:).join(" "))
// 422:         .to include("--cookie cookie_key=cookie_value")
// 423:     end
// 424:
// 425:     it "uses `--header` with argument when :header is present" do
// 426:       expect(curl_args(*args, header: "Accept: */*").join(" "))
// 427:         .to include("--header Accept: */*")
// 428:       expect(curl_args(*args, header: ["Accept: */*", "X-Requested-With: XMLHttpRequest"]).join(" "))
// 429:         .to include("--header Accept: */* --header X-Requested-With: XMLHttpRequest")
// 430:     end
// 431:
// 432:     it "uses `--referer` when :referer is present" do
// 433:       expect(curl_args(*args, referer: "https://brew.sh").join(" ")).to include("--referer https://brew.sh")
// 434:     end
// 435:
// 436:     it "doesn't use `--referer` when :referer is nil" do
// 437:       expect(curl_args(*args, referer: nil).join(" ")).not_to include("--referer")
// 438:     end
// 439:
// 440:     it "omits `--user-agent` when `:user_agent` is `:curl`" do
// 441:       expect(curl_args(*args, user_agent: :curl).join(" ")).not_to include("--user-agent")
// 442:     end
// 443:
// 444:     it "uses HOMEBREW_USER_AGENT_FAKE_SAFARI when `:user_agent` is `:browser` or `:fake`" do
// 445:       expect(curl_args(*args, user_agent: :browser).join(" "))
// 446:         .to include("--user-agent #{HOMEBREW_USER_AGENT_FAKE_SAFARI}")
// 447:       expect(curl_args(*args, user_agent: :fake).join(" "))
// 448:         .to include("--user-agent #{HOMEBREW_USER_AGENT_FAKE_SAFARI}")
// 449:     end
// 450:
// 451:     it "uses HOMEBREW_USER_AGENT_CURL when `:user_agent` is `:default` or omitted" do
// 452:       expect(curl_args(*args, user_agent: :default).join(" ")).to include("--user-agent #{HOMEBREW_USER_AGENT_CURL}")
// 453:       expect(curl_args(*args, user_agent: nil).join(" ")).to include("--user-agent #{HOMEBREW_USER_AGENT_CURL}")
// 454:       expect(curl_args(*args).join(" ")).to include("--user-agent #{HOMEBREW_USER_AGENT_CURL}")
// 455:     end
// 456:
// 457:     it "uses provided user agent string when `:user_agent` is a `String`" do
// 458:       expect(curl_args(*args, user_agent: user_agent_string).join(" "))
// 459:         .to include("--user-agent #{user_agent_string}")
// 460:     end
// 461:
// 462:     it "errors when `:user_agent` is not a String or supported Symbol" do
// 463:       expect { curl_args(*args, user_agent: :an_unsupported_symbol) }
// 464:         .to raise_error(TypeError, ":user_agent must be :browser/:fake, :default, :curl, or a String")
// 465:       expect { curl_args(*args, user_agent: 123) }.to raise_error(TypeError)
// 466:     end
// 467:
// 468:     it "uses `--fail` unless `:show_output` is `true`" do
// 469:       expect(curl_args(*args, show_output: false).join(" ")).to include("--fail")
// 470:       expect(curl_args(*args, show_output: nil).join(" ")).to include("--fail")
// 471:       expect(curl_args(*args).join(" ")).to include("--fail")
// 472:       expect(curl_args(*args, show_output: true).join(" ")).not_to include("--fail")
// 473:     end
// 474:
// 475:     it "uses `--progress-bar` outside of a `--verbose` context" do
// 476:       expect(curl_args(*args).join(" ")).to include("--progress-bar")
// 477:       with_context verbose: true do
// 478:         expect(curl_args(*args).join(" ")).not_to include("--progress-bar")
// 479:       end
// 480:     end
// 481:
// 482:     context "when `EnvConfig.curl_verbose?` is `true`" do
// 483:       before do
// 484:         allow(Homebrew::EnvConfig).to receive(:curl_verbose?).and_return(true)
// 485:       end
// 486:
// 487:       it "uses `--verbose`" do
// 488:         expect(curl_args(*args).join(" ")).to include("--verbose")
// 489:       end
// 490:     end
// 491:
// 492:     context "when `EnvConfig.curl_verbose?` is `false`" do
// 493:       before do
// 494:         allow(Homebrew::EnvConfig).to receive(:curl_verbose?).and_return(false)
// 495:       end
// 496:
// 497:       it "doesn't use `--verbose`" do
// 498:         expect(curl_args(*args).join(" ")).not_to include("--verbose")
// 499:       end
// 500:     end
// 501:
// 502:     context "when `$stdout.tty?` is `false`" do
// 503:       before do
// 504:         allow($stdout).to receive(:tty?).and_return(false)
// 505:       end
// 506:
// 507:       it "uses `--silent`" do
// 508:         expect(curl_args(*args).join(" ")).to include("--silent")
// 509:       end
// 510:     end
// 511:
// 512:     context "when `$stdout.tty?` is `true`" do
// 513:       before do
// 514:         allow($stdout).to receive(:tty?).and_return(true)
// 515:       end
// 516:
// 517:       it "doesn't use `--silent` outside of a `--quiet` context" do
// 518:         with_context quiet: false do
// 519:           expect(curl_args(*args).join(" ")).not_to include("--silent")
// 520:         end
// 521:
// 522:         with_context quiet: true do
// 523:           expect(curl_args(*args).join(" ")).to include("--silent")
// 524:         end
// 525:       end
// 526:     end
// 527:   end
// 528:
// 529:   describe "::url_protected_by_cloudflare?" do
// 530:     it "returns `true` when a URL is protected by Cloudflare" do
// 531:       expect(url_protected_by_cloudflare?(details[:cloudflare][:single_cookie])).to be(true)
// 532:       expect(url_protected_by_cloudflare?(details[:cloudflare][:multiple_cookies])).to be(true)
// 533:     end
// 534:
// 535:     it "returns `false` when a URL is not protected by Cloudflare" do
// 536:       expect(url_protected_by_cloudflare?(details[:cloudflare][:no_server])).to be(false)
// 537:       expect(url_protected_by_cloudflare?(details[:cloudflare][:wrong_server])).to be(false)
// 538:       expect(url_protected_by_cloudflare?(details[:normal][:no_cookie])).to be(false)
// 539:       expect(url_protected_by_cloudflare?(details[:normal][:ok])).to be(false)
// 540:       expect(url_protected_by_cloudflare?(details[:normal][:single_cookie])).to be(false)
// 541:       expect(url_protected_by_cloudflare?(details[:normal][:multiple_cookies])).to be(false)
// 542:     end
// 543:
// 544:     it "returns `false` when response headers are blank" do
// 545:       expect(url_protected_by_cloudflare?(details[:normal][:blank_headers])).to be(false)
// 546:     end
// 547:   end
// 548:
// 549:   describe "::url_protected_by_incapsula?" do
// 550:     it "returns `true` when a URL is protected by Cloudflare" do
// 551:       expect(url_protected_by_incapsula?(details[:incapsula][:single_cookie_visid_incap])).to be(true)
// 552:       expect(url_protected_by_incapsula?(details[:incapsula][:single_cookie_incap_ses])).to be(true)
// 553:       expect(url_protected_by_incapsula?(details[:incapsula][:multiple_cookies_visid_incap])).to be(true)
// 554:       expect(url_protected_by_incapsula?(details[:incapsula][:multiple_cookies_incap_ses])).to be(true)
// 555:     end
// 556:
// 557:     it "returns `false` when a URL is not protected by Incapsula" do
// 558:       expect(url_protected_by_incapsula?(details[:normal][:no_cookie])).to be(false)
// 559:       expect(url_protected_by_incapsula?(details[:normal][:ok])).to be(false)
// 560:       expect(url_protected_by_incapsula?(details[:normal][:single_cookie])).to be(false)
// 561:       expect(url_protected_by_incapsula?(details[:normal][:multiple_cookies])).to be(false)
// 562:     end
// 563:
// 564:     it "returns `false` when response headers are blank" do
// 565:       expect(url_protected_by_incapsula?(details[:normal][:blank_headers])).to be(false)
// 566:     end
// 567:   end
// 568:
// 569:   describe "::curl_version" do
// 570:     it "returns a curl version string" do
// 571:       expect(curl_version).to match(/^v?(\d+(?:\.\d+)+)$/)
// 572:     end
// 573:   end
// 574:
// 575:   describe "::curl_supports_fail_with_body?" do
// 576:     it "returns `true` if curl version is 7.76.0 or higher" do
// 577:       allow_any_instance_of(Utils::Curl).to receive(:curl_version).and_return(Version.new("7.76.0"))
// 578:       expect(curl_supports_fail_with_body?).to be(true)
// 579:
// 580:       allow_any_instance_of(Utils::Curl).to receive(:curl_version).and_return(Version.new("7.76.1"))
// 581:       expect(curl_supports_fail_with_body?).to be(true)
// 582:     end
// 583:
// 584:     it "returns `false` if curl version is lower than 7.76.0" do
// 585:       allow_any_instance_of(Utils::Curl).to receive(:curl_version).and_return(Version.new("7.75.0"))
// 586:       expect(curl_supports_fail_with_body?).to be(false)
// 587:     end
// 588:   end
// 589:
// 590:   describe "::curl_supports_tls13?" do
// 591:     it "returns `true` if curl command is successful" do
// 592:       allow_any_instance_of(Kernel).to receive(:quiet_system).and_return(true)
// 593:       expect(curl_supports_tls13?).to be(true)
// 594:     end
// 595:
// 596:     it "returns `false` if curl command is not successful" do
// 597:       allow_any_instance_of(Kernel).to receive(:quiet_system).and_return(false)
// 598:       expect(curl_supports_tls13?).to be(false)
// 599:     end
// 600:   end
// 601:
// 602:   describe "::no_insecure_redirect_curl_args" do
// 603:     before do
// 604:       allow(Homebrew::EnvConfig).to receive(:no_insecure_redirect?).and_return(true)
// 605:     end
// 606:
// 607:     it "only allows HTTPS redirects for redirect-following calls" do
// 608:       expect(no_insecure_redirect_curl_args(["--location", "http://example.com/example.tar.gz"]))
// 609:         .to eq(["--proto-redir", "=https", "--location", "http://example.com/example.tar.gz"])
// 610:     end
// 611:
// 612:     it "drops custom redirect protocol arguments" do
// 613:       expect(no_insecure_redirect_curl_args(["--location", "--proto-redir", "=all",
// 614:                                              "https://example.com/example.tar.gz"]))
// 615:         .to eq(["--proto-redir", "=https", "--location", "https://example.com/example.tar.gz"])
// 616:     end
// 617:
// 618:     it "drops custom redirect protocol arguments in assignment form" do
// 619:       expect(no_insecure_redirect_curl_args(["--location", "--proto-redir=all",
// 620:                                              "https://example.com/example.tar.gz"]))
// 621:         .to eq(["--proto-redir", "=https", "--location", "https://example.com/example.tar.gz"])
// 622:     end
// 623:   end
// 624:
// 625:   describe "::curl_output" do
// 626:     it "enforces HTTPS redirects before running curl" do
// 627:       allow(Homebrew::EnvConfig).to receive(:no_insecure_redirect?).and_return(true)
// 628:
// 629:       expect(self).to receive(:system_command).with(
// 630:         /curl/,
// 631:         hash_including(args: array_including("--proto-redir", "=https")),
// 632:       ).and_return(
// 633:         instance_double(SystemCommand::Result, success?: true, stdout: ""),
// 634:       )
// 635:
// 636:       curl_output("--location", "https://example.com/example.tar.gz")
// 637:     end
// 638:
// 639:     it "does not expand deferred environment placeholders" do
// 640:       ENV["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 641:       url = ENV.clear_sensitive_environment_for_eval! do
// 642:         "https://example.com/example.tar.gz?private_token=#{ENV.fetch("HOMEBREW_PRIVATE_TOKEN", nil)}"
// 643:       end
// 644:
// 645:       expect(self).to receive(:system_command).with(
// 646:         /curl/,
// 647:         hash_including(args: array_including(url)),
// 648:       ).and_return(
// 649:         instance_double(SystemCommand::Result, success?: true, stdout: ""),
// 650:       )
// 651:
// 652:       curl_output(url)
// 653:     end
// 654:   end
// 655:
// 656:   describe "::curl_http_content_headers_and_checksum" do
// 657:     def curl_args_for(**options)
// 658:       args = T.let([], T::Array[String])
// 659:       allow(self).to receive(:curl_output) do |*arguments, **_options|
// 660:         args = arguments
// 661:         ["", "", instance_double(Process::Status, success?: false, exitstatus: 0)]
// 662:       end
// 663:       curl_http_content_headers_and_checksum("https://brew.sh/", **options)
// 664:       args
// 665:     end
// 666:
// 667:     it "requests headers only when `head_only` is set" do
// 668:       expect(curl_args_for(head_only: true)).to include("--head")
// 669:     end
// 670:
// 671:     it "does not write the body to a file when `head_only` is set" do
// 672:       expect(curl_args_for(head_only: true)).not_to include("--output")
// 673:     end
// 674:
// 675:     it "does not combine `--dump-header` with `--head`" do
// 676:       expect(curl_args_for(head_only: true)).not_to include("--dump-header")
// 677:     end
// 678:
// 679:     it "downloads the body when `head_only` is not set" do
// 680:       expect(curl_args_for(head_only: false)).to include("--output")
// 681:     end
// 682:   end
// 683:
// 684:   describe "::curl_check_http_content" do
// 685:     let(:response) do
// 686:       {
// 687:         url:            "https://brew.sh/",
// 688:         final_url:      nil,
// 689:         exit_status:    0,
// 690:         status_code:    "200",
// 691:         headers:        {},
// 692:         etag:           nil,
// 693:         content_length: nil,
// 694:         file:           nil,
// 695:         file_hash:      nil,
// 696:         responses:      [],
// 697:       }
// 698:     end
// 699:
// 700:     # Returns the recorded `head_only` of each fetch; responses are used in turn.
// 701:     def record_head_only(*responses)
// 702:       recorded = []
// 703:       allow(self).to receive(:curl_http_content_headers_and_checksum) do |_url, **options|
// 704:         recorded << options[:head_only]
// 705:         responses[[recorded.length - 1, responses.length - 1].min]
// 706:       end
// 707:       recorded
// 708:     end
// 709:
// 710:     it "requests headers only for an HTTPS URL" do
// 711:       recorded = record_head_only(response)
// 712:       curl_check_http_content("https://brew.sh/", "homepage URL")
// 713:       expect(recorded).to eq([true])
// 714:     end
// 715:
// 716:     it "downloads the body for an HTTP URL, which needs it for comparison" do
// 717:       recorded = record_head_only(response)
// 718:       curl_check_http_content("http://brew.sh/", "homepage URL")
// 719:       expect(recorded).to all(be_falsey)
// 720:     end
// 721:
// 722:     it "retries as a `GET` when the server rejects `HEAD`" do
// 723:       recorded = record_head_only(response.merge(status_code: "405"), response)
// 724:       curl_check_http_content("https://brew.sh/", "homepage URL")
// 725:       expect(recorded).to eq([true, false])
// 726:     end
// 727:
// 728:     it "reports the problem from the `GET` when the server rejects `HEAD`" do
// 729:       record_head_only(response.merge(status_code: "405"), response.merge(status_code: "500"))
// 730:       expect(curl_check_http_content("https://brew.sh/", "homepage URL"))
// 731:         .to include("HTTP status code 500")
// 732:     end
// 733:
// 734:     # The request may have reached the server, so `HEAD` could be why it failed.
// 735:     test_each([28, 52, 56]) do |exit_status|
// 736:       it "retries as a `GET` when `HEAD` failed with exit status #{exit_status}" do
// 737:         recorded = record_head_only(response.merge(status_code: nil, exit_status:), response)
// 738:         curl_check_http_content("https://brew.sh/", "homepage URL")
// 739:         expect(recorded).to eq([true, false])
// 740:       end
// 741:     end
// 742:
// 743:     # These happen before the request is sent.
// 744:     test_each([6, 7]) do |exit_status|
// 745:       it "does not retry as a `GET` when `HEAD` failed with exit status #{exit_status}" do
// 746:         recorded = record_head_only(response.merge(status_code: nil, exit_status:))
// 747:         curl_check_http_content("https://brew.sh/", "homepage URL")
// 748:         expect(recorded).to eq([true])
// 749:       end
// 750:     end
// 751:
// 752:     it "still reports an unreachable URL when the `GET` retry also fails" do
// 753:       record_head_only(response.merge(status_code: nil, exit_status: 28))
// 754:       expect(curl_check_http_content("https://brew.sh/", "homepage URL"))
// 755:         .to include("is not reachable")
// 756:     end
// 757:   end
// 758:
// 759:   describe "::http_status_ok?" do
// 760:     it "returns `true` when `status` is 1xx or 2xx" do
// 761:       expect(http_status_ok?("200")).to be(true)
// 762:     end
// 763:
// 764:     it "returns `false` when `status` is not 1xx or 2xx" do
// 765:       expect(http_status_ok?("301")).to be(false)
// 766:     end
// 767:
// 768:     it "returns `false` when `status` is `nil`" do
// 769:       expect(http_status_ok?(nil)).to be(false)
// 770:     end
// 771:   end
// 772:
// 773:   describe "::strip_progress_bar" do
// 774:     it "removes the percentage when other text is glued directly onto it" do
// 775:       glued = "############# 100.0%curl: (7) Failed to connect to example.com port 443: Couldn't connect to server"
// 776:       expected = "curl: (7) Failed to connect to example.com port 443: Couldn't connect to server"
// 777:       expect(strip_progress_bar(glued)).to eq(expected)
// 778:     end
// 779:
// 780:     it "reduces a completed progress bar with nothing else on the line to an empty string" do
// 781:       expect(strip_progress_bar("############# 100.0%")).to eq("")
// 782:     end
// 783:
// 784:     it "leaves plain curl diagnostics without a progress bar unchanged" do
// 785:       message = "curl: (6) Could not resolve host: example.com"
// 786:       expect(strip_progress_bar(message)).to eq(message)
// 787:     end
// 788:
// 789:     it "only strips the line that actually has a progress bar" do
// 790:       glued = "Warning: retrying\n### 50.0%curl: (7) timeout"
// 791:       expect(strip_progress_bar(glued)).to eq("Warning: retrying\ncurl: (7) timeout")
// 792:     end
// 793:   end
// 794:
// 795:   describe "::parse_curl_output" do
// 796:     it "returns a correct hash when curl output contains response(s) and body" do
// 797:       expect(parse_curl_output("#{response_text[:ok]}#{body[:default]}"))
// 798:         .to eq({ responses: [response_hash[:ok]], body: body[:default] })
// 799:       expect(parse_curl_output("#{response_text[:ok]}#{body[:with_carriage_returns]}"))
// 800:         .to eq({ responses: [response_hash[:ok]], body: body[:with_carriage_returns] })
// 801:       expect(parse_curl_output("#{response_text[:ok]}#{body[:with_http_status_line]}"))
// 802:         .to eq({ responses: [response_hash[:ok]], body: body[:with_http_status_line] })
// 803:       expect(parse_curl_output("#{response_text[:redirection_to_ok]}#{body[:default]}"))
// 804:         .to eq({ responses: [response_hash[:redirection], response_hash[:ok]], body: body[:default] })
// 805:       expect(parse_curl_output("#{response_text[:redirections_to_ok]}#{body[:default]}"))
// 806:         .to eq({
// 807:           responses: [
// 808:             response_hash[:redirection2],
// 809:             response_hash[:redirection1],
// 810:             response_hash[:redirection],
// 811:             response_hash[:ok],
// 812:           ],
// 813:           body:      body[:default],
// 814:         })
// 815:     end
// 816:
// 817:     it "returns a correct hash when curl output contains HTTP response text and no body" do
// 818:       expect(parse_curl_output(response_text[:ok])).to eq({ responses: [response_hash[:ok]], body: "" })
// 819:     end
// 820:
// 821:     it "returns a correct hash when curl output contains body and no HTTP response text" do
// 822:       expect(parse_curl_output(body[:default])).to eq({ responses: [], body: body[:default] })
// 823:       expect(parse_curl_output(body[:with_carriage_returns]))
// 824:         .to eq({ responses: [], body: body[:with_carriage_returns] })
// 825:       expect(parse_curl_output(body[:with_http_status_line]))
// 826:         .to eq({ responses: [], body: body[:with_http_status_line] })
// 827:     end
// 828:
// 829:     it "returns correct hash when curl output is blank" do
// 830:       expect(parse_curl_output("")).to eq({ responses: [], body: "" })
// 831:     end
// 832:
// 833:     it "errors if response count exceeds `max_iterations`" do
// 834:       expect do
// 835:         parse_curl_output(response_text[:redirections_to_ok], max_iterations: 1)
// 836:       end.to raise_error("Too many redirects (max = 1)")
// 837:     end
// 838:   end
// 839:
// 840:   describe "::parse_curl_response" do
// 841:     it "returns a correct hash when given HTTP response text" do
// 842:       expect(parse_curl_response(response_text[:ok])).to eq(response_hash[:ok])
// 843:       expect(parse_curl_response(response_text[:ok_no_status_text])).to eq(response_hash[:ok_no_status_text])
// 844:       expect(parse_curl_response(response_text[:ok_blank_header_value])).to eq(response_hash[:ok_blank_header_value])
// 845:       expect(parse_curl_response(response_text[:redirection])).to eq(response_hash[:redirection])
// 846:       expect(parse_curl_response(response_text[:duplicate_header])).to eq(response_hash[:duplicate_header])
// 847:     end
// 848:
// 849:     it "skips over response header lines with blank header name" do
// 850:       expect(parse_curl_response(response_text[:ok_blank_header_name])).to eq(response_hash[:ok])
// 851:     end
// 852:
// 853:     it "returns an empty hash when given an empty string" do
// 854:       expect(parse_curl_response("")).to eq({})
// 855:     end
// 856:   end
// 857:
// 858:   describe "::curl_response_last_location" do
// 859:     it "returns the last location header when given an array of HTTP response hashes" do
// 860:       expect(curl_response_last_location([
// 861:         response_hash[:redirection],
// 862:         response_hash[:ok],
// 863:       ])).to eq(response_hash[:redirection][:headers]["location"])
// 864:
// 865:       expect(curl_response_last_location([
// 866:         response_hash[:redirection2],
// 867:         response_hash[:redirection1],
// 868:         response_hash[:redirection],
// 869:         response_hash[:ok],
// 870:       ])).to eq(response_hash[:redirection][:headers]["location"])
// 871:     end
// 872:
// 873:     it "returns the location as given, by default or when absolutize is false" do
// 874:       expect(curl_response_last_location([
// 875:         response_hash[:redirection_no_scheme],
// 876:         response_hash[:ok],
// 877:       ])).to eq(response_hash[:redirection_no_scheme][:headers]["location"])
// 878:
// 879:       expect(curl_response_last_location([
// 880:         response_hash[:redirection_root_relative],
// 881:         response_hash[:ok],
// 882:       ])).to eq(response_hash[:redirection_root_relative][:headers]["location"])
// 883:
// 884:       expect(curl_response_last_location([
// 885:         response_hash[:redirection_parent_relative],
// 886:         response_hash[:ok],
// 887:       ])).to eq(response_hash[:redirection_parent_relative][:headers]["location"])
// 888:     end
// 889:
// 890:     it "returns an absolute URL when absolutize is true and a base URL is provided" do
// 891:       expect(
// 892:         curl_response_last_location(
// 893:           [response_hash[:redirection_no_scheme], response_hash[:ok]],
// 894:           absolutize: true,
// 895:           base_url:   "https://brew.sh/test",
// 896:         ),
// 897:       ).to eq("https:#{response_hash[:redirection_no_scheme][:headers]["location"]}")
// 898:
// 899:       expect(
// 900:         curl_response_last_location(
// 901:           [response_hash[:redirection_root_relative], response_hash[:ok]],
// 902:           absolutize: true,
// 903:           base_url:   "https://brew.sh/test",
// 904:         ),
// 905:       ).to eq("https://brew.sh#{response_hash[:redirection_root_relative][:headers]["location"]}")
// 906:
// 907:       expect(
// 908:         curl_response_last_location(
// 909:           [response_hash[:redirection_parent_relative], response_hash[:ok]],
// 910:           absolutize: true,
// 911:           base_url:   "https://brew.sh/test1/test2",
// 912:         ),
// 913:       ).to eq(response_hash[:redirection_parent_relative][:headers]["location"].sub(/^\./, "https://brew.sh/test1"))
// 914:     end
// 915:
// 916:     it "skips response hashes without a `:headers` value" do
// 917:       expect(curl_response_last_location([
// 918:         response_hash[:redirection],
// 919:         { status_code: "404", status_text: "Not Found" },
// 920:         response_hash[:ok],
// 921:       ])).to eq(response_hash[:redirection][:headers]["location"])
// 922:     end
// 923:
// 924:     it "returns nil when the response hash doesn't contain a location header" do
// 925:       expect(curl_response_last_location([response_hash[:ok]])).to be_nil
// 926:     end
// 927:   end
// 928:
// 929:   describe "::curl_response_follow_redirections" do
// 930:     it "returns the original URL when there are no location headers" do
// 931:       expect(
// 932:         curl_response_follow_redirections(
// 933:           [response_hash[:ok]],
// 934:           "https://brew.sh/test1/test2",
// 935:         ),
// 936:       ).to eq("https://brew.sh/test1/test2")
// 937:     end
// 938:
// 939:     it "returns the URL relative to base when locations are relative" do
// 940:       expect(
// 941:         curl_response_follow_redirections(
// 942:           [response_hash[:redirection_root_relative], response_hash[:ok]],
// 943:           "https://brew.sh/test1/test2",
// 944:         ),
// 945:       ).to eq("https://brew.sh/example/")
// 946:
// 947:       expect(
// 948:         curl_response_follow_redirections(
// 949:           [response_hash[:redirection_parent_relative], response_hash[:ok]],
// 950:           "https://brew.sh/test1/test2",
// 951:         ),
// 952:       ).to eq("https://brew.sh/test1/example/")
// 953:
// 954:       expect(
// 955:         curl_response_follow_redirections(
// 956:           [
// 957:             response_hash[:redirection_parent_relative],
// 958:             response_hash[:redirection_parent_relative],
// 959:             response_hash[:ok],
// 960:           ],
// 961:           "https://brew.sh/test1/test2",
// 962:         ),
// 963:       ).to eq("https://brew.sh/test1/example/example/")
// 964:     end
// 965:
// 966:     it "returns new base when there are absolute location(s)" do
// 967:       expect(
// 968:         curl_response_follow_redirections(
// 969:           [response_hash[:redirection], response_hash[:ok]],
// 970:           "https://brew.sh/test1/test2",
// 971:         ),
// 972:       ).to eq(location_urls[0])
// 973:
// 974:       expect(
// 975:         curl_response_follow_redirections(
// 976:           [response_hash[:redirection], response_hash[:redirection_parent_relative], response_hash[:ok]],
// 977:           "https://brew.sh/test1/test2",
// 978:         ),
// 979:       ).to eq("#{location_urls[0]}example/")
// 980:     end
// 981:
// 982:     it "skips response hashes without a `:headers` value" do
// 983:       expect(
// 984:         curl_response_follow_redirections(
// 985:           [
// 986:             response_hash[:redirection_root_relative],
// 987:             { status_code: "404", status_text: "Not Found" },
// 988:             response_hash[:ok],
// 989:           ],
// 990:           "https://brew.sh/test1/test2",
// 991:         ),
// 992:       ).to eq("https://brew.sh/example/")
// 993:     end
// 994:   end
// 995: end
