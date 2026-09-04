module livecheck

import encoding.utf8
import homebrew.utils
import json2
import net.urllib

// Translated from Homebrew/brew `livecheck/strategy.rb`.
pub const strategy_default_priority = 5
pub const strategy_curl_connect_timeout = 10
pub const strategy_curl_max_time = 15
pub const strategy_curl_process_timeout = 20
pub const strategy_max_redirections = 5
pub const strategy_max_parse_iterations = 6

pub enum StrategyKind {
	generic
	page_match
	json
	xml
	yaml
}

pub type StrategyMatcher = fn (string) bool

pub struct StrategyConstant {
pub:
	name         string
	is_class     bool
	kind         StrategyKind
	priority     int
	has_priority bool
	has_matcher  bool
	matcher      StrategyMatcher = unsafe { nil }
}

pub struct StrategyDefinition {
pub:
	symbol       string
	name         string
	kind         StrategyKind
	priority     int
	has_priority bool
	has_matcher  bool
	matcher      StrategyMatcher = unsafe { nil }
}

pub struct StrategyRegistry {
pub:
	entries []StrategyDefinition
}

pub struct StrategyFromUrlRequest {
pub:
	url                string
	livecheck_strategy ?string
	regex_provided     bool
	block_provided     bool
}

pub struct StrategyPostForm {
pub:
	present bool
	values  map[string]string
	order   []string
}

pub struct StrategyPostJson {
pub:
	present bool
	values  map[string]json2.Any
	order   []string
}

pub struct StrategyPostRequest {
pub:
	form StrategyPostForm
	json StrategyPostJson
}

pub struct StrategyOptions {
pub:
	compressed                   ?bool
	cookies                      map[string]string
	has_cookies                  bool
	headers                      []string
	has_headers                  bool
	homebrew_curl                bool
	post_form                    StrategyPostForm
	post_json                    StrategyPostJson
	referer                      string
	user_agent                   ?string
	curl_supports_fail_with_body bool = true
}

pub struct StrategyCurlRequest {
pub:
	arguments         []string
	wanted_headers    []string
	use_homebrew_curl bool
	cookies           map[string]string
	has_cookies       bool
	headers           []string
	has_headers       bool
	referer           string
	user_agent        string
	print_stdout      bool
	print_stderr      bool
	debug             bool
	verbose           bool
	timeout           int = strategy_curl_process_timeout
	connect_timeout   int = strategy_curl_connect_timeout
	max_time          int = strategy_curl_max_time
	retries           int
}

pub type StrategyHeadersFetcher = fn (StrategyCurlRequest) !utils.CurlParsedOutput

pub type StrategyContentFetcher = fn (StrategyCurlRequest) !utils.CurlCommandResult

pub struct StrategyContentData {
pub:
	content       string
	has_content   bool
	final_url     string
	has_final_url bool
	messages      []string
	has_messages  bool
}

pub enum StrategyBlockItemKind {
	string_value
	version_value
	other_value
	nil_value
}

pub struct StrategyBlockItem {
pub:
	kind  StrategyBlockItemKind
	value string
}

pub enum StrategyBlockValueKind {
	string_value
	version_value
	array
	nil_value
	invalid
}

pub struct StrategyBlockValue {
pub:
	kind   StrategyBlockValueKind
	value  string
	values []StrategyBlockItem
}

fn strategy_underscore(value string) string {
	mut result := []u8{}
	bytes := value.bytes()
	for index, character in bytes {
		if character >= `A` && character <= `Z` {
			if index > 0 && (bytes[index - 1] < `A` || bytes[index - 1] > `Z` || (index + 1 < bytes.len && bytes[index + 1] >= `a` && bytes[index + 1] <= `z`)) {
				result << `_`
			}
			result << character + 32
		} else {
			result << character
		}
	}
	return result.bytestr()
}

pub fn strategy_discover(constants []StrategyConstant) StrategyRegistry {
	mut sorted := constants.clone()
	sorted.sort(a.name < b.name)
	mut entries := []StrategyDefinition{}
	for constant in sorted {
		if !constant.is_class {
			continue
		}
		entries << StrategyDefinition{
			symbol: strategy_underscore(constant.name)
			name: constant.name
			kind: constant.kind
			priority: constant.priority
			has_priority: constant.has_priority
			has_matcher: constant.has_matcher
			matcher: constant.matcher
		}
	}
	return StrategyRegistry{ entries: entries }
}

pub fn strategy_from_symbol(registry StrategyRegistry, symbol ?string) ?StrategyDefinition {
	requested := symbol or { return none }
	for strategy in registry.entries {
		if strategy.symbol == requested {
			return strategy
		}
	}
	return none
}

pub fn strategy_from_url(registry StrategyRegistry,
	request StrategyFromUrlRequest) []StrategyDefinition {
	mut usable := []StrategyDefinition{}
	for strategy in registry.entries {
		if strategy.kind == .page_match {
			if !request.regex_provided && !request.block_provided {
				continue
			}
		} else if strategy.kind in [.json, .xml, .yaml] {
			if requested := request.livecheck_strategy {
				if requested != strategy.symbol || !request.block_provided {
					continue
				}
			} else {
				continue
			}
		} else if strategy.has_priority && strategy.priority <= 0 {
			selected := request.livecheck_strategy or { '' }
			if selected != strategy.symbol {
				continue
			}
		}
		if strategy.has_matcher && strategy.matcher(request.url) {
			usable << strategy
		}
	}
	usable.sort_with_compare(fn (left &StrategyDefinition, right &StrategyDefinition) int {
		left_priority := if left.has_priority { left.priority } else { strategy_default_priority }
		right_priority := if right.has_priority {
			right.priority
		} else {
			strategy_default_priority
		}
		if left_priority > right_priority {
			return -1
		}
		if left_priority < right_priority {
			return 1
		}
		return 0
	})
	return usable
}

fn strategy_post_keys(order []string, values map[string]string) []string {
	if order.len > 0 {
		return order.clone()
	}
	return values.keys()
}

fn strategy_post_form_string(form StrategyPostForm) string {
	mut fields := []string{}
	for key in strategy_post_keys(form.order, form.values) {
		value := form.values[key] or { continue }
		fields << '${urllib.query_escape(key)}=${urllib.query_escape(value)}'
	}
	return fields.join('&')
}

fn strategy_post_json_string(data StrategyPostJson) string {
	mut fields := []string{}
	mut keys := data.order.clone()
	if keys.len == 0 {
		keys = data.values.keys()
	}
	for key in keys {
		value := data.values[key] or { continue }
		fields << '${json2.encode(key)}:${json2.encode(value)}'
	}
	return '{${fields.join(',')}}'
}

pub fn strategy_post_args(request StrategyPostRequest) []string {
	mut arguments := []string{}
	if request.form.present && request.form.values.len > 0 {
		arguments = ['--data', strategy_post_form_string(request.form)]
	} else if request.json.present && request.json.values.len > 0 {
		arguments = ['--json', strategy_post_json_string(request.json)]
	}
	if arguments.len > 1 {
		arguments << ['--header', 'Content-Length: ${arguments[1].runes().len}']
	}
	return arguments
}

fn strategy_redirection_args() []string {
	return ['--max-redirs', strategy_max_redirections.str(), '--proto-redir', '=https']
}

fn strategy_user_agents(options StrategyOptions) []string {
	if user_agent := options.user_agent {
		return [user_agent]
	}
	return ['default', 'browser']
}

fn strategy_curl_request(arguments []string, options StrategyOptions,
	user_agent string) StrategyCurlRequest {
	return StrategyCurlRequest{
		arguments: arguments
		use_homebrew_curl: options.homebrew_curl
		cookies: options.cookies.clone()
		has_cookies: options.has_cookies
		headers: options.headers.clone()
		has_headers: options.has_headers
		referer: options.referer
		user_agent: user_agent
	}
}

pub fn strategy_page_headers(url string, options StrategyOptions,
	fetcher StrategyHeadersFetcher) []map[string][]string {
	mut headers := []map[string][]string{}
	mut post_arguments := []string{}
	if options.post_form.present || options.post_json.present {
		post_arguments = ['--request', 'POST']
		post_arguments << strategy_post_args(StrategyPostRequest{
			form: options.post_form
			json: options.post_json
		})
	}
	for user_agent in strategy_user_agents(options) {
		mut arguments := post_arguments.clone()
		arguments << strategy_redirection_args()
		arguments << url
		mut request := strategy_curl_request(arguments, options, user_agent)
		request = StrategyCurlRequest{
			...request
			wanted_headers: ['location', 'content-disposition']
		}
		parsed := fetcher(request) or { continue }
		for response in parsed.responses {
			headers << response.headers.clone()
		}
		if headers.len > 0 {
			break
		}
	}
	return headers
}

fn strategy_scrub_utf8(value string) string {
	if utf8.validate_str(value) {
		return value
	}
	mut output := []u8{}
	mut index := 0
	bytes := value.bytes()
	for index < bytes.len {
		first := bytes[index]
		mut length := 1
		if first >= 0xc2 && first <= 0xdf {
			length = 2
		} else if first >= 0xe0 && first <= 0xef {
			length = 3
		} else if first >= 0xf0 && first <= 0xf4 {
			length = 4
		} else if first < 0x80 {
			output << first
			index++
			continue
		}
		mut valid := length > 1 && index + length <= bytes.len
		if valid {
			for offset in 1 .. length {
				if bytes[index + offset] < 0x80 || bytes[index + offset] > 0xbf {
					valid = false
					break
				}
			}
		}
		if valid {
			output << bytes[index..index + length]
			index += length
		} else {
			output << [u8(0xef), 0xbf, 0xbd]
			index++
		}
	}
	return output.bytestr()
}

pub fn strategy_page_content(url string, options StrategyOptions,
	fetcher StrategyContentFetcher) !StrategyContentData {
	mut post_arguments := []string{}
	if options.post_form.present || options.post_json.present {
		post_arguments = ['--request', 'POST']
		post_arguments << strategy_post_args(StrategyPostRequest{
			form: options.post_form
			json: options.post_json
		})
	}
	mut page_arguments := ['--fail-with-body', '--include', '--location']
	page_arguments << strategy_redirection_args()
	page_arguments << '--silent'
	compressed := options.compressed or { true }
	if compressed {
		page_arguments << '--compressed'
	}
	mut last_stderr := ''
	for user_agent in strategy_user_agents(options) {
		mut arguments := post_arguments.clone()
		arguments << page_arguments
		arguments << url
		mut request := strategy_curl_request(arguments, options, user_agent)
		request = StrategyCurlRequest{
			...request
			use_homebrew_curl: options.homebrew_curl || !options.curl_supports_fail_with_body
		}
		result := fetcher(request)!
		last_stderr = result.stderr
		if !result.success() {
			continue
		}
		parsed := utils.curl_parse_output(strategy_scrub_utf8(result.stdout), strategy_max_parse_iterations)!
		final_url := utils.curl_response_last_location(parsed.responses, true, url) or { '' }
		return StrategyContentData{
			content: parsed.body
			has_content: true
			final_url: final_url
			has_final_url: final_url != '' && final_url != url
		}
	}
	mut messages := []string{}
	for line in last_stderr.split_into_lines() {
		if line.starts_with('curl:') && line.len > 'curl:'.len {
			messages << line
		}
	}
	if messages.len == 0 {
		messages << 'cURL failed without a detectable error'
	}
	return StrategyContentData{
		messages: messages
		has_messages: true
	}
}

pub fn strategy_handle_block_return(value StrategyBlockValue) ![]string {
	match value.kind {
		.string_value, .version_value {
			return [value.value]
		}
		.array {
			mut values := []string{}
			for item in value.values {
				if item.kind != .nil_value && item.value !in values {
					values << item.value
				}
			}
			return values
		}
		.nil_value {
			return []string{}
		}
		.invalid {
			return error('Return value of a strategy block must be a string or array of strings.')
		}
	}
}
