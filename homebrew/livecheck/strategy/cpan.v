module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/cpan.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn cpan_match_data_value(result PageMatchData) brew_runtime.Value {
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

// Ruby method `self.match?(url)` at line 38.
pub fn ruby_cpan_l38_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cpan_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 49.
pub fn ruby_cpan_l49_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := cpan_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url':   brew_runtime.string_value(generated.url)
		'regex': brew_runtime.object_value('Regexp', generated.regex.pattern)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 87.
pub fn ruby_cpan_l87_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := cpan_find_versions(CpanFindRequest{
		url: args[0].as_string()
		content: content
	}, cpan_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return cpan_match_data_value(result)
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
// 9:       # The {Cpan} strategy identifies versions of software at
// 10:       # cpan.metacpan.org by checking directory listing pages.
// 11:       #
// 12:       # CPAN URLs take the following formats:
// 13:       #
// 14:       # * `https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/Brew-v1.2.3.tar.gz`
// 15:       # * `https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/brew/brew-v1.2.3.tar.gz`
// 16:       #
// 17:       # In these examples, `HOMEBREW` is the author name and the preceding `H`
// 18:       # and `HO` directories correspond to the first letter(s). Some authors
// 19:       # also store files in subdirectories, as in the second example above.
// 20:       #
// 21:       # @api public
// 22:       class Cpan
// 23:         extend Strategic
// 24:
// 25:         # The `Regexp` used to determine if the strategy applies to the URL.
// 26:         URL_MATCH_REGEX = %r{
// 27:           ^https?://(?:cpan\.metacpan\.org|www\.cpan\.org)
// 28:           (?<path>/authors/id(?:/[^/]+){3,}/) # Path before the filename
// 29:           (?<prefix>[^/]+) # Filename text before the version
// 30:           -v?\d+(?:\.\d+)* # The numeric version
// 31:           (?<suffix>[^/]+) # Filename text after the version
// 32:         }ix
// 33:
// 34:         # Whether the strategy can be applied to the provided URL.
// 35:         #
// 36:         # @param url [String] the URL to match against
// 37:         sig { override.params(url: String).returns(T::Boolean) }
// 38:         def self.match?(url)
// 39:           URL_MATCH_REGEX.match?(url)
// 40:         end
// 41:
// 42:         # Extracts information from a provided URL and uses it to generate
// 43:         # various input values used by the strategy to check for new versions.
// 44:         # Some of these values act as defaults and can be overridden in a
// 45:         # `livecheck` block.
// 46:         #
// 47:         # @param url [String] the URL used to generate values
// 48:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 49:         def self.generate_input_values(url)
// 50:           values = {}
// 51:
// 52:           match = url.match(URL_MATCH_REGEX)
// 53:           return values if match.blank?
// 54:
// 55:           # The directory listing page where the archive files are found
// 56:           values[:url] = "https://www.cpan.org#{match[:path]}"
// 57:
// 58:           regex_prefix = Regexp.escape(T.must(match[:prefix])).gsub("\\-", "-")
// 59:
// 60:           # Use `\.t` instead of specific tarball extensions (e.g. .tar.gz)
// 61:           suffix = T.must(match[:suffix]).sub(Strategy::TARBALL_EXTENSION_REGEX, ".t")
// 62:           regex_suffix = Regexp.escape(suffix).gsub("\\-", "-")
// 63:
// 64:           # Example regex: `/href=.*?Brew[._-]v?(\d+(?:\.\d+)*)\.t/i`
// 65:           values[:regex] = /href=.*?#{regex_prefix}[._-]v?(\d+(?:\.\d+)*)#{regex_suffix}/i
// 66:
// 67:           values
// 68:         end
// 69:
// 70:         # Generates a URL and regex (if one isn't provided) and passes them
// 71:         # to {PageMatch.find_versions} to identify versions in the content.
// 72:         #
// 73:         # @param url [String] the URL of the content to check
// 74:         # @param regex [Regexp, nil] a regex for matching versions in content
// 75:         # @param content [String, nil] content to check instead of fetching
// 76:         # @param options [Options] options to modify behavior
// 77:         # @return [Hash]
// 78:         sig {
// 79:           override.params(
// 80:             url:     String,
// 81:             regex:   T.nilable(Regexp),
// 82:             content: T.nilable(String),
// 83:             options: Options,
// 84:             block:   T.nilable(Proc),
// 85:           ).returns(T::Hash[Symbol, T.anything])
// 86:         }
// 87:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 88:           generated = generate_input_values(url)
// 89:
// 90:           PageMatch.find_versions(
// 91:             url:     generated[:url],
// 92:             regex:   regex || generated[:regex],
// 93:             content:,
// 94:             options:,
// 95:             &block
// 96:           )
// 97:         end
// 98:       end
// 99:     end
// 100:   end
// 101: end
