module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/apache.rb`.
pub struct ApacheInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct ApacheFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

struct ApacheUrlParts {
	path   string
	prefix string
	suffix string
}

fn apache_version_end(value string, start int) ?int {
	mut index := start
	if index < value.len && value[index] in [`v`, `V`] {
		index++
	}
	digit_start := index
	for index < value.len && value[index].is_digit() {
		index++
	}
	if index == digit_start {
		return none
	}
	mut dots := 0
	for index + 1 < value.len && value[index] == `.` && value[index + 1].is_digit() {
		index++
		for index < value.len && value[index].is_digit() {
			index++
		}
		dots++
	}
	return if dots == 0 { none } else { index }
}

fn apache_path_and_files(url string) []string {
	lower := url.to_lower()
	scheme_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return []string{}
	}
	remainder := url[scheme_length..]
	lower_remainder := lower[scheme_length..]
	for base in ['archive.apache.org/dist/', 'dlcdn.apache.org/', 'downloads.apache.org/'] {
		if lower_remainder.starts_with(base) {
			return [remainder[base.len..]]
		}
	}
	dynamic_base := 'www.apache.org/dyn/'
	if !lower_remainder.starts_with(dynamic_base) {
		return []string{}
	}
	dynamic_value := remainder[dynamic_base.len..]
	lower_dynamic_value := lower_remainder[dynamic_base.len..]
	// The `.+` before `(?:path|filename)` is greedy in `URL_MATCH_REGEX`, so
	// parameter candidates are attempted from right to left. The optional `/`
	// after `=` is greedy but can be restored when the remaining match fails.
	mut candidates := []string{}
	for index := lower_dynamic_value.len - 1; index >= 1; index-- {
		for parameter in ['path=', 'filename='] {
			if lower_dynamic_value[index..].starts_with(parameter) {
				path_and_file := dynamic_value[index + parameter.len..]
				if path_and_file.starts_with('/') {
					candidates << path_and_file[1..]
				}
				candidates << path_and_file
			}
		}
	}
	return candidates
}

fn apache_parts_from_path_and_file(path_and_file string) ?ApacheUrlParts {
	// `(?<path>.+?)/` and `(?<prefix>[^/]*?)` are lazy, so test path
	// separators and version starts from left to right.
	for separator := 1; separator < path_and_file.len; separator++ {
		if path_and_file[separator] != `/` {
			continue
		}
		remainder := path_and_file[separator + 1..]
		segment_end := remainder.index('/') or { remainder.len }
		for version_start := 0; version_start < segment_end; version_start++ {
			version_end := apache_version_end(remainder, version_start) or { continue }
			if version_end > segment_end {
				continue
			}
			suffix := if version_end < remainder.len && remainder[version_end] == `/` {
				'/'
			} else {
				remainder[version_end..segment_end]
			}
			return ApacheUrlParts{
				path: path_and_file[..separator]
				prefix: remainder[..version_start]
				suffix: suffix
			}
		}
	}
	return none
}

fn apache_url_parts(url string) ?ApacheUrlParts {
	for path_and_file in apache_path_and_files(url) {
		if parts := apache_parts_from_path_and_file(path_and_file) {
			return parts
		}
	}
	return none
}

fn apache_regex_escape(value string) string {
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

fn apache_normalize_tarball_suffix(suffix string) string {
	lower := suffix.to_lower()
	for extension in ['.tar.bz2', '.tar.gz', '.tar.lz', '.tar.lzma', '.tar.lzo', '.tar.xz', '.tar.z',
		'.tar.zst', '.tar', '.tb2', '.tbz2', '.tbz', '.tz2', '.taz', '.tgz', '.tlzma', '.tlz', '.txz',
		'.tzst', '.tz'] {
		if lower.ends_with(extension) {
			return suffix[..suffix.len - extension.len] + '.t'
		}
	}
	return suffix
}

pub fn apache_matches_url(url string) bool {
	if _ := apache_url_parts(url) {
		return true
	}
	return false
}

pub fn apache_generate_input_values(url string) ApacheInputValues {
	parts := apache_url_parts(url) or { return ApacheInputValues{} }
	regex_prefix := apache_regex_escape(parts.prefix)
	regex_suffix := apache_regex_escape(apache_normalize_tarball_suffix(parts.suffix))
	return ApacheInputValues{
		present: true
		url: 'https://archive.apache.org/dist/${parts.path}/'
		regex: PageMatchRegex{
			pattern: 'href=["\']?${regex_prefix}v?(\\d+(?:\\.\\d+)+)${regex_suffix}'
			case_insensitive: true
		}
	}
}

pub fn apache_find_versions(request ApacheFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := apache_generate_input_values(request.url)
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

fn apache_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn apache_match_data_value(result PageMatchData) ruby.Value {
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
