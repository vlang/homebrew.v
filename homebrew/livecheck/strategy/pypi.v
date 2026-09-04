module strategy

import ruby
import homebrew.livecheck
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/pypi.rb`.
pub struct PypiInputValues {
pub:
	present bool
	url     string
}

pub struct PypiFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn pypi_package_from_filename(filename string) ?string {
	dot := filename.last_index('.') or { return none }
	if dot == 0 || dot + 1 == filename.len || !filename[dot + 1..].bytes().all(it.is_alnum()) {
		return none
	}
	stem := filename[..dot]
	hyphen := stem.last_index('-') or { return none }
	if hyphen == 0 {
		return none
	}
	return stem[..hyphen]
}

pub fn pypi_matches_url(url string) bool {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://files.pythonhosted.org/packages/') {
		'https://files.pythonhosted.org/packages/'.len
	} else if lower.starts_with('http://files.pythonhosted.org/packages/') {
		'http://files.pythonhosted.org/packages/'.len
	} else {
		return false
	}
	parts := url[prefix_length..].split('/')
	if parts.len < 2 || parts.any(it == '') {
		return false
	}
	return pypi_package_from_filename(parts.last()) != none
}

pub fn pypi_generate_input_values(url string) PypiInputValues {
	filename := url.all_after_last('/')
	package_name := pypi_package_from_filename(filename) or { return PypiInputValues{} }
	return PypiInputValues{
		present: true
		url: 'https://pypi.org/pypi/${package_name.replace('%20', '-').replace('_', '-')}/json'
	}
}

fn pypi_capture_version(value string, provided JsonRegex) ?string {
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

fn pypi_default_block(document json2.Any,
	provided ?JsonRegex) !livecheck.StrategyBlockValue {
	if document is map[string]json2.Any {
		info := document['info'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if info is map[string]json2.Any {
			version_value := info['version'] or {
				return livecheck.StrategyBlockValue{ kind: .nil_value }
			}
			if version_value is string {
				if version_value.trim_space() == '' {
					return livecheck.StrategyBlockValue{ kind: .nil_value }
				}
				version := if regex_value := provided {
					pypi_capture_version(version_value, regex_value) or {
						return livecheck.StrategyBlockValue{ kind: .nil_value }
					}
				} else {
					version_value
				}
				return livecheck.StrategyBlockValue{
					kind: .string_value
					value: version
				}
			}
		}
	}
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

pub fn pypi_find_versions(request PypiFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := pypi_generate_input_values(request.url)
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
		block_arity: if request.has_block { request.block_arity } else { 2 }
		block: if request.has_block { request.block } else { pypi_default_block }
	}, fetcher)
}

fn pypi_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn pypi_match_data_value(result JsonMatchData) ruby.Value {
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
