module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/launchpad.rb`.
// The original source is retained below until every stub has a typed V body.
// V's regex dot spans line breaks, so `[^<]+` preserves Ruby's capture ending
// before the closing element instead of consuming later elements in the page.
pub const launchpad_default_pattern = r'class="[^"]*version[^"]*"[^>]*>\s*Latest version is ([^<]+)\s*</'

pub struct LaunchpadInputValues {
pub:
	present bool
	url     string
}

pub struct LaunchpadFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn launchpad_project_name(url string) ?string {
	lower := url.to_lower()
	scheme_length := if lower.starts_with('https://') {
		'https://'.len
	} else if lower.starts_with('http://') {
		'http://'.len
	} else {
		return none
	}
	remainder := url[scheme_length..]
	host_end := remainder.index('/') or { return none }
	host := lower[scheme_length..scheme_length + host_end]
	if host != 'launchpad.net' && !(host.ends_with('.launchpad.net') && host.len > '.launchpad.net'.len) {
		return none
	}
	path := remainder[host_end + 1..]
	project_end := path.index('/') or { path.len }
	if project_end == 0 {
		return none
	}
	return path[..project_end]
}

pub fn launchpad_matches_url(url string) bool {
	return launchpad_project_name(url) != none
}

pub fn launchpad_generate_input_values(url string) LaunchpadInputValues {
	project_name := launchpad_project_name(url) or { return LaunchpadInputValues{} }

	// The main page for the project on Launchpad
	return LaunchpadInputValues{
		present: true
		url: 'https://launchpad.net/${project_name}/'
	}
}

pub fn launchpad_find_versions(request LaunchpadFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := launchpad_generate_input_values(request.url)
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		?PageMatchRegex(PageMatchRegex{
			pattern: launchpad_default_pattern
		})
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

fn launchpad_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn launchpad_match_data_value(result PageMatchData) brew_runtime.Value {
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

// Ruby method `self.match?(url)` at line 45.
pub fn ruby_launchpad_l45_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(launchpad_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 57.
pub fn ruby_launchpad_l57_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := launchpad_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url': brew_runtime.string_value(generated.url)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 86.
pub fn ruby_launchpad_l86_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := launchpad_find_versions(LaunchpadFindRequest{
		url: args[0].as_string()
		content: content
	}, launchpad_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return launchpad_match_data_value(result)
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
// 9:       # The {Launchpad} strategy identifies versions of software at
// 10:       # launchpad.net by checking the main page for a project.
// 11:       #
// 12:       # Launchpad URLs take a variety of formats but all the current formats
// 13:       # contain the project name as the first part of the URL path:
// 14:       #
// 15:       # * `https://launchpad.net/example/1.2/1.2.3/+download/example-1.2.3.tar.gz`
// 16:       # * `https://launchpad.net/example/trunk/1.2.3/+download/example-1.2.3.tar.gz`
// 17:       # * `https://code.launchpad.net/example/1.2/1.2.3/+download/example-1.2.3.tar.gz`
// 18:       #
// 19:       # The default regex identifies the latest version within an HTML element
// 20:       # found on the main page for a project:
// 21:       #
// 22:       # <pre><div class="version">
// 23:       #   Latest version is 1.2.3
// 24:       # </div></pre>
// 25:       #
// 26:       # @api public
// 27:       class Launchpad
// 28:         extend Strategic
// 29:
// 30:         # The `Regexp` used to determine if the strategy applies to the URL.
// 31:         URL_MATCH_REGEX = %r{
// 32:           ^https?://(?:[^/]+?\.)*launchpad\.net
// 33:           /(?<project_name>[^/]+) # The Launchpad project name
// 34:         }ix
// 35:
// 36:         # The default regex used to identify the latest version when a regex
// 37:         # isn't provided.
// 38:         DEFAULT_REGEX = %r{class="[^"]*version[^"]*"[^>]*>\s*Latest version is (.+)\s*</}
// 39:
// 40:         # Whether the strategy can be applied to the provided URL.
// 41:         #
// 42:         # @param url [String] the URL to match against
// 43:         # @return [Boolean]
// 44:         sig { override.params(url: String).returns(T::Boolean) }
// 45:         def self.match?(url)
// 46:           URL_MATCH_REGEX.match?(url)
// 47:         end
// 48:
// 49:         # Extracts information from a provided URL and uses it to generate
// 50:         # various input values used by the strategy to check for new versions.
// 51:         # Some of these values act as defaults and can be overridden in a
// 52:         # `livecheck` block.
// 53:         #
// 54:         # @param url [String] the URL used to generate values
// 55:         # @return [Hash]
// 56:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 57:         def self.generate_input_values(url)
// 58:           values = {}
// 59:
// 60:           match = url.match(URL_MATCH_REGEX)
// 61:           return values if match.blank?
// 62:
// 63:           # The main page for the project on Launchpad
// 64:           values[:url] = "https://launchpad.net/#{match[:project_name]}/"
// 65:
// 66:           values
// 67:         end
// 68:
// 69:         # Generates a URL and regex (if one isn't provided) and passes them
// 70:         # to {PageMatch.find_versions} to identify versions in the content.
// 71:         #
// 72:         # @param url [String] the URL of the content to check
// 73:         # @param regex [Regexp, nil] a regex for matching versions in content
// 74:         # @param content [String, nil] content to check instead of fetching
// 75:         # @param options [Options] options to modify behavior
// 76:         # @return [Hash]
// 77:         sig {
// 78:           override.params(
// 79:             url:     String,
// 80:             regex:   T.nilable(Regexp),
// 81:             content: T.nilable(String),
// 82:             options: Options,
// 83:             block:   T.nilable(Proc),
// 84:           ).returns(T::Hash[Symbol, T.anything])
// 85:         }
// 86:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 87:           generated = generate_input_values(url)
// 88:
// 89:           PageMatch.find_versions(
// 90:             url:     generated[:url],
// 91:             regex:   regex || DEFAULT_REGEX,
// 92:             content:,
// 93:             options:,
// 94:             &block
// 95:           )
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
