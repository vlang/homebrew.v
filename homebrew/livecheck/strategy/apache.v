module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/apache.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn apache_match_data_value(result PageMatchData) brew_runtime.Value {
	mut matches := map[string]brew_runtime.Value{}
	for version in result.matches.keys() {
		matches[version] = brew_runtime.object_value('Version', version)
	}
	regex_value := result.regex or { PageMatchRegex{} }
	mut values := {
		'matches': brew_runtime.map_value(matches)
		'regex':   if regex_value.pattern == '' {
			brew_runtime.object_value('NilClass', 'nil')
		} else {
			brew_runtime.object_value('Regexp', regex_value.pattern)
		}
		'url':     brew_runtime.string_value(result.url)
	}
	if result.has_cached {
		values['cached'] = brew_runtime.bool_value(result.cached)
	}
	if result.has_content {
		values['content'] = brew_runtime.string_value(result.content)
	}
	if result.has_final_url {
		values['final_url'] = brew_runtime.string_value(result.final_url)
	}
	if result.has_messages {
		values['messages'] = brew_runtime.string_array_value(result.messages)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `self.match?(url)` at line 50.
pub fn ruby_apache_l50_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(apache_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 61.
pub fn ruby_apache_l61_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := apache_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url':   brew_runtime.string_value(generated.url)
		'regex': brew_runtime.object_value('Regexp', generated.regex.pattern)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 102.
pub fn ruby_apache_l102_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := apache_find_versions(ApacheFindRequest{
		url: args[0].as_string()
		content: content
	}, apache_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return apache_match_data_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategic"
// 5:
// 6: module Homebrew
// 7:   module Livecheck
// 8:     module Strategy
// 9:       # The {Apache} strategy identifies versions of software at apache.org
// 10:       # by checking directory listing pages.
// 11:       #
// 12:       # Most Apache URLs start with `https://www.apache.org/dyn/` and include
// 13:       # a `filename` or `path` query string parameter where the value is a
// 14:       # path to a file. The path takes one of the following formats:
// 15:       #
// 16:       # * `example/1.2.3/example-1.2.3.tar.gz`
// 17:       # * `example/example-1.2.3/example-1.2.3.tar.gz`
// 18:       # * `example/example-1.2.3-bin.tar.gz`
// 19:       #
// 20:       # This strategy also handles a few common mirror/backup URLs where the
// 21:       # path is provided outside of a query string parameter (e.g.
// 22:       # `https://archive.apache.org/dist/example/1.2.3/example-1.2.3.tar.gz`).
// 23:       #
// 24:       # When the path contains a version directory (e.g. `/1.2.3/`,
// 25:       # `/example-1.2.3/`, etc.), the default regex matches numeric versions
// 26:       # in directory names. Otherwise, the default regex matches numeric
// 27:       # versions in filenames.
// 28:       #
// 29:       # @api public
// 30:       class Apache
// 31:         extend Strategic
// 32:
// 33:         # The `Regexp` used to determine if the strategy applies to the URL.
// 34:         URL_MATCH_REGEX = %r{
// 35:           ^https?://
// 36:           (?:www\.apache\.org/dyn/.+(?:path|filename)=/?|
// 37:           archive\.apache\.org/dist/|
// 38:           dlcdn\.apache\.org/|
// 39:           downloads\.apache\.org/)
// 40:           (?<path>.+?)/      # Path to directory of files or version directories
// 41:           (?<prefix>[^/]*?)  # Any text in filename or directory before version
// 42:           v?\d+(?:\.\d+)+    # The numeric version
// 43:           (?<suffix>/|[^/]*) # Any text in filename or directory after version
// 44:         }ix
// 45:
// 46:         # Whether the strategy can be applied to the provided URL.
// 47:         #
// 48:         # @param url [String] the URL to match against
// 49:         sig { override.params(url: String).returns(T::Boolean) }
// 50:         def self.match?(url)
// 51:           URL_MATCH_REGEX.match?(url)
// 52:         end
// 53:
// 54:         # Extracts information from a provided URL and uses it to generate
// 55:         # various input values used by the strategy to check for new versions.
// 56:         # Some of these values act as defaults and can be overridden in a
// 57:         # `livecheck` block.
// 58:         #
// 59:         # @param url [String] the URL used to generate values
// 60:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 61:         def self.generate_input_values(url)
// 62:           values = {}
// 63:
// 64:           match = url.match(URL_MATCH_REGEX)
// 65:           return values if match.blank?
// 66:
// 67:           # Example URL: `https://archive.apache.org/dist/example/`
// 68:           values[:url] = "https://archive.apache.org/dist/#{match[:path]}/"
// 69:
// 70:           regex_prefix = Regexp.escape(match[:prefix] || "").gsub("\\-", "-")
// 71:
// 72:           # Use `\.t` instead of specific tarball extensions (e.g. .tar.gz)
// 73:           suffix = T.must(match[:suffix]).sub(Strategy::TARBALL_EXTENSION_REGEX, ".t")
// 74:           regex_suffix = Regexp.escape(suffix).gsub("\\-", "-")
// 75:
// 76:           # Example directory regex: `%r{href=["']?v?(\d+(?:\.\d+)+)/}i`
// 77:           # Example file regexes:
// 78:           # * `/href=["']?example-v?(\d+(?:\.\d+)+)\.t/i`
// 79:           # * `/href=["']?example-v?(\d+(?:\.\d+)+)-bin\.zip/i`
// 80:           values[:regex] = /href=["']?#{regex_prefix}v?(\d+(?:\.\d+)+)#{regex_suffix}/i
// 81:
// 82:           values
// 83:         end
// 84:
// 85:         # Generates a URL and regex (if one isn't provided) and passes them
// 86:         # to {PageMatch.find_versions} to identify versions in the content.
// 87:         #
// 88:         # @param url [String] the URL of the content to check
// 89:         # @param regex [Regexp, nil] a regex for matching versions in content
// 90:         # @param content [String, nil] content to check instead of fetching
// 91:         # @param options [Options] options to modify behavior
// 92:         # @return [Hash]
// 93:         sig {
// 94:           override.params(
// 95:             url:     String,
// 96:             regex:   T.nilable(Regexp),
// 97:             content: T.nilable(String),
// 98:             options: Options,
// 99:             block:   T.nilable(Proc),
// 100:           ).returns(T::Hash[Symbol, T.anything])
// 101:         }
// 102:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 103:           generated = generate_input_values(url)
// 104:
// 105:           PageMatch.find_versions(
// 106:             url:     generated[:url],
// 107:             regex:   regex || generated[:regex],
// 108:             content:,
// 109:             options:,
// 110:             &block
// 111:           )
// 112:         end
// 113:       end
// 114:     end
// 115:   end
// 116: end
