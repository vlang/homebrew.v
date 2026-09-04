module strategy

import ruby
import homebrew.livecheck
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/crate.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CrateInputValues {
pub:
	present bool
	url     string
}

pub struct CrateFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn crate_package(url string) ?string {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://static.crates.io/crates/') {
		'https://static.crates.io/crates/'.len
	} else if lower.starts_with('http://static.crates.io/crates/') {
		'http://static.crates.io/crates/'.len
	} else {
		return none
	}
	remainder := url[prefix_length..]
	separator := remainder.index('/') or { return none }
	if separator == 0 {
		return none
	}
	filename := remainder[separator + 1..]
	crate_suffix := filename.to_lower().index('.crate') or { return none }
	if crate_suffix == 0 {
		return none
	}
	return remainder[..separator]
}

pub fn crate_matches_url(url string) bool {
	return crate_package(url) != none
}

pub fn crate_generate_input_values(url string) CrateInputValues {
	package_name := crate_package(url) or { return CrateInputValues{} }
	return CrateInputValues{
		present: true
		url: 'https://crates.io/api/v1/crates/${package_name}/versions'
	}
}

fn crate_capture_version(value string, provided JsonRegex) ?string {
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

fn crate_default_block(document json2.Any,
	provided ?JsonRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	mut versions := []string{}
	if document is map[string]json2.Any {
		raw_versions := document['versions'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if raw_versions is []json2.Any {
			for raw_version in raw_versions {
				if raw_version is map[string]json2.Any {
					yanked := raw_version['yanked'] or { json2.Any(false) }
					if yanked is bool {
						if yanked {
							continue
						}
					}
					num := raw_version['num'] or { continue }
					if num is string {
						if matched := crate_capture_version(num, match_regex) {
							versions << matched
						}
					}
				}
			}
		}
	}
	return if versions.len == 0 {
		livecheck.StrategyBlockValue{ kind: .nil_value }
	} else {
		livecheck.StrategyBlockValue{
			kind: .array
			values: versions.map(livecheck.StrategyBlockItem{
				kind: .string_value
				value: it
			})
		}
	}
}

pub fn crate_find_versions(request CrateFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := crate_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
			cached: request.content != none
			has_cached: request.content != none
		}
	}
	effective_regex := request.regex or {
		JsonRegex{
			pattern: r'^v?(\d+(?:\.\d+)+)$'
			case_insensitive: true
		}
	}
	result := json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 2 }
		block: if request.has_block { request.block } else { crate_default_block }
	}, fetcher)!
	return JsonMatchData{
		...result
		regex: request.regex
	}
}

fn crate_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn crate_match_data_value(result JsonMatchData) ruby.Value {
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

// Ruby method `self.match?(url)` at line 53.
pub fn ruby_crate_l53_d1_self_match(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(crate_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 62.
pub fn ruby_crate_l62_d2_self_generate_input_values(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	generated := crate_generate_input_values(args[0].as_string())
	if !generated.present {
		return ruby.map_value({})
	}
	return ruby.map_value({
		'url': ruby.string_value(generated.url)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 88.
pub fn ruby_crate_l88_d3_self_find_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := crate_find_versions(CrateFindRequest{
		url: args[0].as_string()
		content: content
	}, crate_empty_fetcher) or { return ruby.object_value('Error', err.msg()) }
	return crate_match_data_value(result)
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
// 9:       # The {Crate} strategy identifies versions of a Rust crate by checking
// 10:       # the information from the `versions` API endpoint.
// 11:       #
// 12:       # Crate URLs have the following format:
// 13:       #   `https://static.crates.io/crates/example/example-1.2.3.crate`
// 14:       #
// 15:       # The default regex identifies versions like `1.2.3`/`v1.2.3` from the
// 16:       # version `num` field. This is a common version format but a different
// 17:       # regex can be provided in a `livecheck` block to override the default
// 18:       # if a package uses a different format (e.g. `1.2.3d`, `1.2.3-4`, etc.).
// 19:       #
// 20:       # @api public
// 21:       class Crate
// 22:         extend Strategic
// 23:
// 24:         # The default regex used to identify versions when a regex isn't
// 25:         # provided.
// 26:         DEFAULT_REGEX = /^v?(\d+(?:\.\d+)+)$/i
// 27:
// 28:         # The default `strategy` block used to extract version information when
// 29:         # a `strategy` block isn't provided.
// 30:         DEFAULT_BLOCK = T.let(proc do |json, regex|
// 31:           json["versions"]&.map do |version|
// 32:             next if version["yanked"]
// 33:             next unless (match = version["num"]&.match(regex))
// 34:
// 35:             match[1]
// 36:           end
// 37:         end.freeze, T.proc.params(
// 38:           arg0: T::Hash[String, T.anything],
// 39:           arg1: Regexp,
// 40:         ).returns(T.any(String, T::Array[String])))
// 41:
// 42:         # The `Regexp` used to determine if the strategy applies to the URL.
// 43:         URL_MATCH_REGEX = %r{
// 44:           ^https?://static\.crates\.io/crates
// 45:           /(?<package>[^/]+) # The name of the package
// 46:           /.+\.crate # The crate filename
// 47:         }ix
// 48:
// 49:         # Whether the strategy can be applied to the provided URL.
// 50:         #
// 51:         # @param url [String] the URL to match against
// 52:         sig { override.params(url: String).returns(T::Boolean) }
// 53:         def self.match?(url)
// 54:           URL_MATCH_REGEX.match?(url)
// 55:         end
// 56:
// 57:         # Extracts information from a provided URL and uses it to generate
// 58:         # various input values used by the strategy to check for new versions.
// 59:         #
// 60:         # @param url [String] the URL used to generate values
// 61:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 62:         def self.generate_input_values(url)
// 63:           values = {}
// 64:           return values unless (match = url.match(URL_MATCH_REGEX))
// 65:
// 66:           values[:url] = "https://crates.io/api/v1/crates/#{match[:package]}/versions"
// 67:
// 68:           values
// 69:         end
// 70:
// 71:         # Generates a URL and checks the content at the URL for new versions
// 72:         # using {Json.versions_from_content}.
// 73:         #
// 74:         # @param url [String] the URL of the content to check
// 75:         # @param regex [Regexp, nil] a regex for matching versions in content
// 76:         # @param content [String, nil] content to check instead of fetching
// 77:         # @param options [Options] options to modify behavior
// 78:         # @return [Hash]
// 79:         sig {
// 80:           override.params(
// 81:             url:     String,
// 82:             regex:   T.nilable(Regexp),
// 83:             content: T.nilable(String),
// 84:             options: Options,
// 85:             block:   T.nilable(Proc),
// 86:           ).returns(T::Hash[Symbol, T.anything])
// 87:         }
// 88:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 89:           match_data = { matches: {}, regex:, url: }
// 90:           match_data[:cached] = true if content
// 91:
// 92:           generated = generate_input_values(url)
// 93:           return match_data if generated.blank?
// 94:
// 95:           match_data[:url] = generated[:url]
// 96:
// 97:           unless match_data[:cached]
// 98:             match_data.merge!(Strategy.page_content(match_data[:url], options:))
// 99:             content = match_data[:content]
// 100:           end
// 101:           return match_data if content.blank?
// 102:
// 103:           Json.versions_from_content(content, regex || DEFAULT_REGEX, &block || DEFAULT_BLOCK).each do |match_text|
// 104:             match_data[:matches][match_text] = Version.new(match_text)
// 105:           end
// 106:
// 107:           match_data
// 108:         end
// 109:       end
// 110:     end
// 111:   end
// 112: end
