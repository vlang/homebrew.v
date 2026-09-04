module strategy

import ruby
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/bitbucket.rb`.
pub struct BitbucketInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct BitbucketFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

struct BitbucketUrlParts {
	path    string
	dl_type string
	prefix  string
	suffix  string
}

fn bitbucket_version_end(filename string, start int) ?int {
	mut index := start
	if index < filename.len && (filename[index] == `v` || filename[index] == `V`) {
		index++
	}
	digit_start := index
	for index < filename.len && filename[index].is_digit() {
		index++
	}
	if index == digit_start {
		return none
	}
	mut dots := 0
	for index + 1 < filename.len && filename[index] == `.` && filename[index + 1].is_digit() {
		index++
		segment_start := index
		for index < filename.len && filename[index].is_digit() {
			index++
		}
		if index == segment_start {
			return none
		}
		dots++
	}
	return if dots == 0 { none } else { index }
}

fn bitbucket_url_parts(url string) ?BitbucketUrlParts {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://bitbucket.org/') {
		'https://bitbucket.org/'.len
	} else if lower.starts_with('http://bitbucket.org/') {
		'http://bitbucket.org/'.len
	} else {
		return none
	}
	remainder := url[prefix_length..]
	lower_remainder := lower[prefix_length..]
	mut marker := ''
	mut marker_index := -1
	for candidate in ['/get/', '/downloads/'] {
		if index := lower_remainder.index(candidate) {
			if marker_index < 0 || index < marker_index {
				marker = candidate
				marker_index = index
			}
		}
	}
	if marker_index <= 0 {
		return none
	}
	path := remainder[..marker_index]
	filename := remainder[marker_index + marker.len..]
	for start := 0; start < filename.len; start++ {
		if start > 0 && filename[start - 1] !in [`-`, `_`] {
			continue
		}
		end := bitbucket_version_end(filename, start) or { continue }
		if end >= filename.len || filename[end] == `/` {
			continue
		}
		return BitbucketUrlParts{
			path: path
			dl_type: marker.trim('/')
			prefix: filename[..start]
			suffix: filename[end..]
		}
	}
	return none
}

fn bitbucket_regex_escape(value string) string {
	mut escaped := value
	for character in ['\\', '.', '+', '*', '?', '^', '\$', '(', ')', '[', ']', '{', '}', '|'] {
		escaped = escaped.replace(character, '\\${character}')
	}
	return escaped.replace('\\-', '-')
}

fn bitbucket_normalize_tarball_suffix(suffix string) string {
	lower := suffix.to_lower()
	valid := ['.tar', '.tar.bz2', '.tar.gz', '.tar.lz', '.tar.lzma', '.tar.lzo', '.tar.xz', '.tar.z',
		'.tar.zst', '.tb2', '.tbz', '.tbz2', '.tz2', '.taz', '.tgz', '.tlz', '.tlzma', '.txz', '.tz',
		'.tzst']
	return if lower in valid { '.t' } else { suffix }
}

pub fn bitbucket_matches_url(url string) bool {
	return bitbucket_url_parts(url) != none
}

pub fn bitbucket_generate_input_values(url string) BitbucketInputValues {
	parts := bitbucket_url_parts(url) or { return BitbucketInputValues{} }
	regex_prefix := bitbucket_regex_escape(parts.prefix)
	if parts.dl_type == 'get' {
		return BitbucketInputValues{
			present: true
			url: 'https://bitbucket.org/${parts.path}/downloads/?tab=tags&iframe=true&spa=0'
			regex: PageMatchRegex{
				pattern: '<td[^>]*?class="name"[^>]*?>\\s*${regex_prefix}v?(\\d+(?:\\.\\d+)+)\\s*?<'
				case_insensitive: true
			}
		}
	}
	regex_suffix := bitbucket_regex_escape(bitbucket_normalize_tarball_suffix(parts.suffix))
	return BitbucketInputValues{
		present: true
		url: 'https://bitbucket.org/${parts.path}/downloads/?iframe=true&spa=0'
		regex: PageMatchRegex{
			pattern: 'href=.*?${regex_prefix}v?(\\d+(?:\\.\\d+)+)${regex_suffix}'
			case_insensitive: true
		}
	}
}

pub fn bitbucket_find_versions(request BitbucketFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := bitbucket_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	return page_match_find_versions(PageMatchFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)
}

fn bitbucket_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn bitbucket_match_data_value(result PageMatchData) ruby.Value {
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
