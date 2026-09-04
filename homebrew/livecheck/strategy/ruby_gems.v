module strategy

import ruby
import homebrew.livecheck
import homebrew.utils
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/ruby_gems.rb`.
pub struct RubyGemsInputValues {
pub:
	present bool
	url     string
}

pub struct RubyGemsFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn ruby_gems_ascii_alphanumeric(character u8) bool {
	return (character >= `0` && character <= `9`) || (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`)
}

fn ruby_gems_valid_version(value string) bool {
	if value == '' {
		return false
	}
	mut index := 0
	for index < value.len && value[index] >= `0` && value[index] <= `9` {
		index++
	}
	if index == 0 {
		return false
	}
	for index < value.len {
		if value[index] != `.` {
			return false
		}
		index++
		segment_start := index
		for index < value.len && ruby_gems_ascii_alphanumeric(value[index]) {
			index++
		}
		if index == segment_start {
			return false
		}
	}
	return true
}

fn ruby_gems_version_and_platform_valid(value string) bool {
	if platform_separator := value.index('-') {
		return platform_separator > 0 && platform_separator + 1 < value.len && ruby_gems_valid_version(value[..platform_separator])
	}
	return ruby_gems_valid_version(value)
}

fn ruby_gems_filename_gem_name(filename string) ?string {
	candidate := if filename.ends_with('\n') {
		filename[..filename.len - 1]
	} else {
		filename
	}
	if candidate.contains('\n') || candidate.len <= '.gem'.len || !candidate.to_lower().ends_with('.gem') {
		return none
	}
	body := candidate[..candidate.len - '.gem'.len]
	mut separator := body.len - 1
	for separator > 0 {
		if body[separator] == `-` && ruby_gems_version_and_platform_valid(body[separator + 1..]) {
			return body[..separator]
		}
		separator--
	}
	return none
}

fn ruby_gems_url_gem_name(url string) ?string {
	lower := url.to_lower()
	mut path_start := 0
	if lower.starts_with('https://rubygems.org/') {
		path_start = 'https://rubygems.org/'.len
	} else if lower.starts_with('http://rubygems.org/') {
		path_start = 'http://rubygems.org/'.len
	} else {
		return none
	}
	path := url[path_start..]
	lower_path := lower[path_start..]
	if lower_path.starts_with('downloads/') {
		return ruby_gems_filename_gem_name(path['downloads/'.len..])
	}
	if !lower_path.starts_with('gems/') {
		return none
	}
	gems_path := path['gems/'.len..]
	versions_separator := gems_path.index('/') or { return none }
	if versions_separator == 0 {
		return none
	}
	versions_prefix := '/versions/'
	if !gems_path[versions_separator..].to_lower().starts_with(versions_prefix) {
		return none
	}
	filename_start := versions_separator + versions_prefix.len
	return ruby_gems_filename_gem_name(gems_path[filename_start..])
}

fn ruby_gems_encode_www_form_component(value string) string {
	hex := '0123456789ABCDEF'
	mut encoded := []u8{cap: value.len}
	for character in value.bytes() {
		if ruby_gems_ascii_alphanumeric(character) || character in [`*`, `-`, `.`, `_`] {
			encoded << character
		} else if character == ` ` {
			encoded << `+`
		} else {
			encoded << `%`
			encoded << hex[character >> 4]
			encoded << hex[character & 15]
		}
	}
	return encoded.bytestr()
}

pub fn rubygems_matches_url(url string) bool {
	return ruby_gems_url_gem_name(url) != none
}

pub fn rubygems_generate_input_values(url string) RubyGemsInputValues {
	gem_name := ruby_gems_url_gem_name(url) or { return RubyGemsInputValues{} }
	return RubyGemsInputValues{
		present: true
		url: 'https://rubygems.org/api/v1/versions/${ruby_gems_encode_www_form_component(gem_name)}/latest.json'
	}
}

fn ruby_gems_default_block(document json2.Any,
	_ ?JsonRegex) !livecheck.StrategyBlockValue {
	if document is map[string]json2.Any {
		version := document['version'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if version is string {
			return livecheck.StrategyBlockValue{
				kind: .string_value
				value: version
			}
		}
	}
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

pub fn rubygems_find_versions(request RubyGemsFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := rubygems_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
		}
	}
	return json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: request.regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 1 }
		block: if request.has_block { request.block } else { ruby_gems_default_block }
	}, fetcher)
}

fn ruby_gems_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}
