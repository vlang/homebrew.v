module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/cpan.rb`.
pub struct CpanInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct CpanFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

struct CpanUrlParts {
	path   string
	prefix string
	suffix string
}

fn cpan_filename_parts(filename string) ?CpanUrlParts {
	if filename == '' || filename.contains('/') {
		return none
	}
	for separator := filename.len - 1; separator >= 1; separator-- {
		if filename[separator] != `-` {
			continue
		}
		mut version_start := separator + 1
		if version_start < filename.len && filename[version_start] in [`v`, `V`] {
			version_start++
		}
		if version_start >= filename.len || !filename[version_start].is_digit() {
			continue
		}
		mut suffix_start := version_start
		for suffix_start < filename.len && filename[suffix_start].is_digit() {
			suffix_start++
		}
		for suffix_start < filename.len && filename[suffix_start] == `.` {
			segment_start := suffix_start + 1
			mut segment_end := segment_start
			for segment_end < filename.len && filename[segment_end].is_digit() {
				segment_end++
			}
			if segment_end == segment_start {
				break
			}
			suffix_start = segment_end
		}
		if suffix_start < filename.len {
			return CpanUrlParts{
				prefix: filename[..separator]
				suffix: filename[suffix_start..]
			}
		}
	}
	return none
}

fn cpan_url_parts(url string) ?CpanUrlParts {
	lower := url.to_lower()
	scheme_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return none
	}
	host_end_relative := lower[scheme_length..].index('/') or { return none }
	host_end := scheme_length + host_end_relative
	host := lower[scheme_length..host_end]
	if host != 'cpan.metacpan.org' && host != 'www.cpan.org' {
		return none
	}
	path_prefix := '/authors/id/'
	path_and_file := url[host_end..]
	if !path_and_file.to_lower().starts_with(path_prefix) {
		return none
	}
	segments := path_and_file[path_prefix.len..].split('/')
	if segments.len < 4 {
		return none
	}
	// `(?:/[^/]+){3,}/` is greedy, so Ruby first tries the rightmost segment
	// as the filename and backtracks to earlier segments when necessary.
	for candidate_index := segments.len - 1; candidate_index >= 3; candidate_index-- {
		mut valid_path := true
		for segment in segments[..candidate_index] {
			if segment == '' {
				valid_path = false
				break
			}
		}
		if !valid_path {
			continue
		}
		parts := cpan_filename_parts(segments[candidate_index]) or { continue }
		return CpanUrlParts{
			path: path_prefix + segments[..candidate_index].join('/') + '/'
			prefix: parts.prefix
			suffix: parts.suffix
		}
	}
	return none
}

fn cpan_regex_escape(value string) string {
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
	// Ruby's `Regexp.escape` escapes hyphens and the source immediately
	// removes that escape with `gsub("\\-", "-")`.
	return escaped
}

fn cpan_normalize_tarball_suffix(suffix string) string {
	lower := suffix.to_lower()
	for extension in ['.tar.bz2', '.tar.lzma', '.tar.lzo', '.tar.zst', '.tar.gz', '.tar.lz', '.tar.xz',
		'.tar.z', '.tar', '.tlzma', '.tbz2', '.tzst', '.tb2', '.tbz', '.tz2', '.taz', '.tgz', '.tlz',
		'.txz', '.tz'] {
		if lower.ends_with(extension) {
			return suffix[..suffix.len - extension.len] + '.t'
		}
	}
	return suffix
}

pub fn cpan_matches_url(url string) bool {
	if _ := cpan_url_parts(url) {
		return true
	}
	return false
}

pub fn cpan_generate_input_values(url string) CpanInputValues {
	parts := cpan_url_parts(url) or { return CpanInputValues{} }
	regex_prefix := cpan_regex_escape(parts.prefix)
	regex_suffix := cpan_regex_escape(cpan_normalize_tarball_suffix(parts.suffix))
	return CpanInputValues{
		present: true
		url: 'https://www.cpan.org${parts.path}'
		regex: PageMatchRegex{
			pattern: 'href=.*?${regex_prefix}[._-]v?(\\d+(?:\\.\\d+)*)${regex_suffix}'
			case_insensitive: true
		}
	}
}

pub fn cpan_find_versions(request CpanFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := cpan_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
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

fn cpan_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn cpan_match_data_value(result PageMatchData) ruby.Value {
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
