module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/gnu.rb`.
pub struct GnuInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct GnuFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn gnu_project_name(url string) ?string {
	lower := url.to_lower()
	scheme_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return none
	}
	remainder := url[scheme_length..]
	lower_remainder := lower[scheme_length..]

	// This is the `(?<project_name>[^/]+)\.gnu\.org/?$` branch of
	// `URL_MATCH_REGEX`.
	direct_host_end := if lower_remainder.ends_with('/') {
		lower_remainder.len - 1
	} else {
		lower_remainder.len
	}
	if !lower_remainder[..direct_host_end].contains('/') {
		host := lower_remainder[..direct_host_end]
		suffix := '.gnu.org'
		if host.ends_with(suffix) && host.len > suffix.len {
			return remainder[..direct_host_end - suffix.len]
		}
	}

	// This is the `gnu.org/(?:gnu|software)/(?<project_name>[^/]+)/`
	// branch of `URL_MATCH_REGEX`.
	host_end := lower_remainder.index('/') or { return none }
	host := lower_remainder[..host_end]
	if host != 'gnu.org' && !(host.ends_with('.gnu.org') && host.len > '.gnu.org'.len) {
		return none
	}
	path := remainder[host_end..]
	lower_path := lower_remainder[host_end..]
	for prefix in ['/gnu/', '/software/'] {
		if lower_path.starts_with(prefix) {
			project_and_rest := path[prefix.len..]
			project_end := project_and_rest.index('/') or { return none }
			if project_end > 0 {
				return project_and_rest[..project_end]
			}
			return none
		}
	}
	return none
}

fn gnu_regex_escape(value string) string {
	mut escaped := ''
	for character in value {
		match character {
			`\t` {
				escaped += r'\t'
			}
			`\n` {
				escaped += r'\n'
			}
			`\r` {
				escaped += r'\r'
			}
			`\f` {
				escaped += r'\f'
			}
			`\\`, `.`, `+`, `*`, `?`, `^`, `$`, `(`, `)`, `[`, `]`, `{`, `}`, `|`, `#`, ` ` {
				escaped += '\\${character.ascii_str()}'
			}
			else {
				escaped += character.ascii_str()
			}
		}
	}
	// Ruby's `Regexp.escape` escapes hyphens, and the source immediately
	// removes that escape with `gsub("\\-", "-")`.
	return escaped
}

pub fn gnu_matches_url(url string) bool {
	if _ := gnu_project_name(url) {
		return !url.contains('savannah.')
	}
	return false
}

pub fn gnu_generate_input_values(url string) GnuInputValues {
	project_name := gnu_project_name(url) or { return GnuInputValues{} }
	regex_name := gnu_regex_escape(project_name)
	return GnuInputValues{
		present: true
		url: 'https://ftpmirror.gnu.org/gnu/${project_name}/'
		regex: PageMatchRegex{
			pattern: 'href=.*?${regex_name}[._-]v?(\\d+(?:\\.\\d+)*)(?:\\.[a-z]+|/)'
			case_insensitive: true
		}
	}
}

pub fn gnu_find_versions(request GnuFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := gnu_generate_input_values(request.url)
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
		url: if generated.present { generated.url } else { '' }
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)
}

fn gnu_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn gnu_match_data_value(result PageMatchData) ruby.Value {
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
	if result.has_final_url {
		values['final_url'] = ruby.string_value(result.final_url)
	}
	if result.has_messages {
		values['messages'] = ruby.string_array_value(result.messages)
	}
	return ruby.map_value(values)
}
