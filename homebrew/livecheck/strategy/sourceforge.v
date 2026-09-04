module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/sourceforge.rb`.
pub struct SourceforgeInputValues {
pub:
	present bool
	url     string
	has_url bool
	regex   PageMatchRegex
}

pub struct SourceforgeFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn sourceforge_project(url string) ?string {
	lower := url.to_lower()
	protocol_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return none
	}
	host_end_relative := url[protocol_length..].index('/') or { return none }
	host_end := protocol_length + host_end_relative
	host := lower[protocol_length..host_end]
	if !(host == 'sourceforge.net' || host.ends_with('.sourceforge.net') || host == 'sf.net' || host.ends_with('.sf.net')) {
		return none
	}
	path := url[host_end..]
	for prefix in ['/projects/', '/project/', '/p/', ':/cvsroot/', '/cvsroot/', '/'] {
		if path.starts_with(prefix) {
			name := path[prefix.len..].all_before('/')
			if name != '' {
				return name.all_before('?')
			}
		}
	}
	return none
}

fn sourceforge_regex_escape(value string) string {
	mut escaped := value
	for character in ['\\', '.', '+', '*', '?', '^', '\$', '(', ')', '[', ']', '{', '}', '|'] {
		escaped = escaped.replace(character, '\\${character}')
	}
	return escaped.replace('\\-', '-')
}

pub fn sourceforge_matches_url(url string) bool {
	return sourceforge_project(url) != none
}

pub fn sourceforge_generate_input_values(url string) SourceforgeInputValues {
	project_name := sourceforge_project(url) or { return SourceforgeInputValues{} }
	lower := url.to_lower()
	rss_index := lower.index('/rss') or { -1 }
	has_rss_suffix := rss_index >= 0 && (rss_index + 4 == lower.len || lower[rss_index + 4] == `/` || lower[rss_index + 4] == `?`)
	regex_name := sourceforge_regex_escape(project_name)
	return SourceforgeInputValues{
		present: true
		url: if has_rss_suffix {
			''
		} else {
			'https://sourceforge.net/projects/${project_name}/rss'
		}
		has_url: !has_rss_suffix
		regex: PageMatchRegex{
			pattern: 'url=.*?/${regex_name}/files/.*?[-_/](\\d+(?:[-.]\\d+)+)[-_/%.]'
			case_insensitive: true
		}
	}
}

pub fn sourceforge_find_versions(request SourceforgeFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := sourceforge_generate_input_values(request.url)
	generated_regex := if generated.present {
		?PageMatchRegex(generated.regex)
	} else {
		none
	}
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	return page_match_find_versions(PageMatchFindVersionsRequest{
		url: if generated.has_url { generated.url } else { request.url }
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)
}

fn sourceforge_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn sourceforge_match_data_value(result PageMatchData) ruby.Value {
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
