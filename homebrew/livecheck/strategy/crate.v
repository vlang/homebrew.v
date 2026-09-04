module strategy

import ruby
import homebrew.livecheck
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/crate.rb`.
pub struct CrateInputValues {
pub:
	present bool
	url     string
}

pub struct CrateFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn crate_package(url string) ?string {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://static.crates.io/crates/') {
		'https://static.crates.io/crates/'.len
	} else if lower.starts_with('http://static.crates.io/crates/') {
		'http://static.crates.io/crates/'.len
	} else {
		return none
	}
	remainder := url[prefix_length..]
	separator := remainder.index('/') or { return none }
	if separator == 0 {
		return none
	}
	filename := remainder[separator + 1..]
	crate_suffix := filename.to_lower().index('.crate') or { return none }
	if crate_suffix == 0 {
		return none
	}
	return remainder[..separator]
}

pub fn crate_matches_url(url string) bool {
	return crate_package(url) != none
}

pub fn crate_generate_input_values(url string) CrateInputValues {
	package_name := crate_package(url) or { return CrateInputValues{} }
	return CrateInputValues{
		present: true
		url: 'https://crates.io/api/v1/crates/${package_name}/versions'
	}
}

fn crate_capture_version(value string, provided JsonRegex) ?string {
	mut expression := regex.regex_opt(provided.pattern) or { return none }
	if provided.case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	capture := expression.get_group_by_id(value, 0)
	return if capture == '' { none } else { capture }
}

fn crate_default_block(document json2.Any,
	provided ?JsonRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	mut versions := []string{}
	if document is map[string]json2.Any {
		raw_versions := document['versions'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if raw_versions is []json2.Any {
			for raw_version in raw_versions {
				if raw_version is map[string]json2.Any {
					yanked := raw_version['yanked'] or { json2.Any(false) }
					if yanked is bool {
						if yanked {
							continue
						}
					}
					num := raw_version['num'] or { continue }
					if num is string {
						if matched := crate_capture_version(num, match_regex) {
							versions << matched
						}
					}
				}
			}
		}
	}
	return if versions.len == 0 {
		livecheck.StrategyBlockValue{ kind: .nil_value }
	} else {
		livecheck.StrategyBlockValue{
			kind: .array
			values: versions.map(livecheck.StrategyBlockItem{
				kind: .string_value
				value: it
			})
		}
	}
}

pub fn crate_find_versions(request CrateFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := crate_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
			cached: request.content != none
			has_cached: request.content != none
		}
	}
	effective_regex := request.regex or {
		JsonRegex{
			pattern: r'^v?(\d+(?:\.\d+)+)$'
			case_insensitive: true
		}
	}
	result := json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 2 }
		block: if request.has_block { request.block } else { crate_default_block }
	}, fetcher)!
	return JsonMatchData{
		...result
		regex: request.regex
	}
}

fn crate_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn crate_match_data_value(result JsonMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version in result.matches.keys() {
		matches[version] = ruby.object_value('Version', version)
	}
	regex_value := result.regex or { JsonRegex{} }
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
