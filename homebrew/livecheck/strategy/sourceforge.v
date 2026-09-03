module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/sourceforge.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn sourceforge_match_data_value(result PageMatchData) brew_runtime.Value {
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
	return brew_runtime.map_value(values)
}

// Ruby method `self.match?(url)` at line 51.
pub fn ruby_sourceforge_l51_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(sourceforge_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 63.
pub fn ruby_sourceforge_l63_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := sourceforge_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	mut values := {
		'regex': brew_runtime.object_value('Regexp', generated.regex.pattern)
	}
	if generated.has_url {
		values['url'] = brew_runtime.string_value(generated.url)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 101.
pub fn ruby_sourceforge_l101_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := sourceforge_find_versions(SourceforgeFindRequest{
		url: args[0].as_string()
		content: content
	}, sourceforge_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return sourceforge_match_data_value(result)
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
// 9:       # The {Sourceforge} strategy identifies versions of software at
// 10:       # sourceforge.net by checking a project's RSS feed.
// 11:       #
// 12:       # SourceForge URLs take a few different formats:
// 13:       #
// 14:       # * `https://downloads.sourceforge.net/project/example/example-1.2.3.tar.gz`
// 15:       # * `https://svn.code.sf.net/p/example/code/trunk`
// 16:       # * `:pserver:anonymous:@example.cvs.sourceforge.net:/cvsroot/example`
// 17:       #
// 18:       # The RSS feed for a project contains the most recent release archives
// 19:       # and while this is fine for most projects, this approach has some
// 20:       # shortcomings. Some project releases involve so many files that the one
// 21:       # we're interested in isn't present in the feed content. Some projects
// 22:       # contain additional software and the archive we're interested in is
// 23:       # pushed out of the feed (especially if it hasn't been updated recently).
// 24:       #
// 25:       # Usually we address this situation by adding a `livecheck` block to
// 26:       # the formula/cask that checks the page for the relevant directory in the
// 27:       # project instead. In this situation, it's necessary to use
// 28:       # `strategy :page_match` to prevent the {Sourceforge} strategy from
// 29:       # being used.
// 30:       #
// 31:       # The default regex matches within `url` attributes in the RSS feed
// 32:       # and identifies versions within directory names or filenames.
// 33:       #
// 34:       # @api public
// 35:       class Sourceforge
// 36:         extend Strategic
// 37:
// 38:         # The `Regexp` used to determine if the strategy applies to the URL.
// 39:         URL_MATCH_REGEX = %r{
// 40:           ^https?://(?:[^/]+?\.)*(?:sourceforge|sf)\.net
// 41:           (?:/projects?/(?<project_name>[^/]+)/
// 42:           |/p/(?<project_name>[^/]+)/
// 43:           |(?::/cvsroot)?/(?<project_name>[^/]+))
// 44:         }ix
// 45:
// 46:         # Whether the strategy can be applied to the provided URL.
// 47:         #
// 48:         # @param url [String] the URL to match against
// 49:         # @return [Boolean]
// 50:         sig { override.params(url: String).returns(T::Boolean) }
// 51:         def self.match?(url)
// 52:           URL_MATCH_REGEX.match?(url)
// 53:         end
// 54:
// 55:         # Extracts information from a provided URL and uses it to generate
// 56:         # various input values used by the strategy to check for new versions.
// 57:         # Some of these values act as defaults and can be overridden in a
// 58:         # `livecheck` block.
// 59:         #
// 60:         # @param url [String] the URL used to generate values
// 61:         # @return [Hash]
// 62:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 63:         def self.generate_input_values(url)
// 64:           values = {}
// 65:
// 66:           match = url.match(URL_MATCH_REGEX)
// 67:           return values if match.blank?
// 68:
// 69:           # Don't generate a URL if the URL already points to the RSS feed
// 70:           unless url.match?(%r{/rss(?:/?$|\?)})
// 71:             values[:url] = "https://sourceforge.net/projects/#{match[:project_name]}/rss"
// 72:           end
// 73:
// 74:           regex_name = Regexp.escape(T.must(match[:project_name])).gsub("\\-", "-")
// 75:
// 76:           # It may be possible to improve the generated regex but there's quite
// 77:           # a bit of variation between projects and it can be challenging to
// 78:           # create something that works for most URLs.
// 79:           values[:regex] = %r{url=.*?/#{regex_name}/files/.*?[-_/](\d+(?:[-.]\d+)+)[-_/%.]}i
// 80:
// 81:           values
// 82:         end
// 83:
// 84:         # Generates a URL and regex (if one isn't provided) and passes them
// 85:         # to {PageMatch.find_versions} to identify versions in the content.
// 86:         #
// 87:         # @param url [String] the URL of the content to check
// 88:         # @param regex [Regexp, nil] a regex for matching versions in content
// 89:         # @param content [String, nil] content to check instead of fetching
// 90:         # @param options [Options] options to modify behavior
// 91:         # @return [Hash]
// 92:         sig {
// 93:           override.params(
// 94:             url:     String,
// 95:             regex:   T.nilable(Regexp),
// 96:             content: T.nilable(String),
// 97:             options: Options,
// 98:             block:   T.nilable(Proc),
// 99:           ).returns(T::Hash[Symbol, T.anything])
// 100:         }
// 101:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 102:           generated = generate_input_values(url)
// 103:
// 104:           PageMatch.find_versions(
// 105:             url:     generated[:url] || url,
// 106:             regex:   regex || generated[:regex],
// 107:             content:,
// 108:             options:,
// 109:             &block
// 110:           )
// 111:         end
// 112:       end
// 113:     end
// 114:   end
// 115: end
