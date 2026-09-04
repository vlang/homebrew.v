module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/xorg.rb`.
pub struct XorgInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct XorgFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

pub struct XorgPageCache {
pub mut:
	page_data map[string]string
}

fn xorg_module_name(url string) ?string {
	file_name := url.all_after_last('/')
	mut separator := -1
	for index := 0; index + 1 < file_name.len; index++ {
		if file_name[index] == `-` && file_name[index + 1].is_digit() {
			separator = index
		}
	}
	if separator <= 0 {
		return none
	}
	return file_name[..separator]
}

fn xorg_regex_escape(value string) string {
	mut escaped := value
	for character in ['\\', '.', '+', '*', '?', '^', '\$', '(', ')', '[', ']', '{', '}', '|'] {
		escaped = escaped.replace(character, '\\${character}')
	}
	return escaped.replace('\\-', '-')
}

pub fn xorg_matches_url(url string) bool {
	lower := url.to_lower()
	protocol_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return false
	}
	host_end_relative := lower[protocol_length..].index('/') or { return false }
	host_end := protocol_length + host_end_relative
	host := lower[protocol_length..host_end]
	path := lower[host_end + 1..]
	valid_location := if host == 'x.org' || host.ends_with('.x.org') {
		path.starts_with('individual/') || path.contains('/individual/')
	} else if host == 'freedesktop.org' || host.ends_with('.freedesktop.org') {
		path.starts_with('archive/') || path.starts_with('dist/') || path.starts_with('software/')
	} else {
		host == 'archive.mesa3d.org'
	}
	return valid_location && xorg_module_name(url) != none
}

pub fn xorg_generate_input_values(url string) XorgInputValues {
	module_name := xorg_module_name(url) or { return XorgInputValues{} }
	file_name := url.all_after_last('/')
	directory_url := url.replace_once('x.org/pub/', 'x.org/archive/').trim_string_right(file_name)
	regex_name := xorg_regex_escape(module_name)
	return XorgInputValues{
		present: true
		url: directory_url
		regex: PageMatchRegex{
			pattern: 'href=.*?${regex_name}[._-]v?(\\d+(?:\\.\\d+)+)\\.t'
			case_insensitive: true
		}
	}
}

pub fn xorg_set_page_data(mut cache XorgPageCache, page_data map[string]string) {
	cache.page_data = page_data.clone()
}

pub fn xorg_find_versions(mut cache XorgPageCache, request XorgFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := xorg_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	mut effective_content := request.content
	if request.content == none && generated.url in cache.page_data {
		effective_content = cache.page_data[generated.url]
	}
	match_data := page_match_find_versions(PageMatchFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: effective_content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)!
	if match_data.has_content && match_data.content.trim_space() != '' {
		cache.page_data[generated.url] = match_data.content
	}
	return match_data
}

fn xorg_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn xorg_match_data_value(result PageMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.object_value('Version', version)
	}
	regex_value := result.regex or { PageMatchRegex{} }
	mut values := {
		'matches': ruby.map_value(matches)
		'regex':   if regex_value.pattern == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.object_value('Regexp', regex_value.pattern)
		}
		'url':     ruby.string_value(result.url)
	}
	if result.has_cached {
		values['cached'] = ruby.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = ruby.string_value(result.content)
	}
	return ruby.map_value(values)
}
