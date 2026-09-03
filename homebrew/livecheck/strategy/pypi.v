module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/pypi.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PypiInputValues {
pub:
	present bool
	url     string
}

pub struct PypiFindRequest {
pub:
	url         string
	regex       ?JsonRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int = 1
	block       JsonVersionsBlock = unsafe { nil }
}

fn pypi_package_from_filename(filename string) ?string {
	dot := filename.last_index('.') or { return none }
	if dot == 0 || dot + 1 == filename.len || !filename[dot + 1..].bytes().all(it.is_alnum()) {
		return none
	}
	stem := filename[..dot]
	hyphen := stem.last_index('-') or { return none }
	if hyphen == 0 {
		return none
	}
	return stem[..hyphen]
}

pub fn pypi_matches_url(url string) bool {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://files.pythonhosted.org/packages/') {
		'https://files.pythonhosted.org/packages/'.len
	} else if lower.starts_with('http://files.pythonhosted.org/packages/') {
		'http://files.pythonhosted.org/packages/'.len
	} else {
		return false
	}
	parts := url[prefix_length..].split('/')
	if parts.len < 2 || parts.any(it == '') {
		return false
	}
	return pypi_package_from_filename(parts.last()) != none
}

pub fn pypi_generate_input_values(url string) PypiInputValues {
	filename := url.all_after_last('/')
	package_name := pypi_package_from_filename(filename) or { return PypiInputValues{} }
	return PypiInputValues{
		present: true
		url: 'https://pypi.org/pypi/${package_name.replace('%20', '-').replace('_', '-')}/json'
	}
}

fn pypi_capture_version(value string, provided JsonRegex) ?string {
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

fn pypi_default_block(document json2.Any,
	provided ?JsonRegex) !livecheck.StrategyBlockValue {
	if document is map[string]json2.Any {
		info := document['info'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if info is map[string]json2.Any {
			version_value := info['version'] or {
				return livecheck.StrategyBlockValue{ kind: .nil_value }
			}
			if version_value is string {
				if version_value.trim_space() == '' {
					return livecheck.StrategyBlockValue{ kind: .nil_value }
				}
				version := if regex_value := provided {
					pypi_capture_version(version_value, regex_value) or {
						return livecheck.StrategyBlockValue{ kind: .nil_value }
					}
				} else {
					version_value
				}
				return livecheck.StrategyBlockValue{
					kind: .string_value
					value: version
				}
			}
		}
	}
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

pub fn pypi_find_versions(request PypiFindRequest,
	fetcher livecheck.StrategyContentFetcher) !JsonMatchData {
	generated := pypi_generate_input_values(request.url)
	if !generated.present {
		return JsonMatchData{
			matches: map[string]string{}
			regex: request.regex
			url: request.url
		}
	}
	return json_find_versions(JsonFindVersionsRequest{
		url: generated.url
		regex: request.regex
		content: request.content
		options: request.options
		has_block: true
		block_arity: if request.has_block { request.block_arity } else { 2 }
		block: if request.has_block { request.block } else { pypi_default_block }
	}, fetcher)
}

fn pypi_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn pypi_match_data_value(result JsonMatchData) brew_runtime.Value {
	mut matches := map[string]brew_runtime.Value{}
	for version in result.matches.keys() {
		matches[version] = brew_runtime.object_value('Version', version)
	}
	regex_value := result.regex or { JsonRegex{} }
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

// Ruby method `self.match?(url)` at line 56.
pub fn ruby_pypi_l56_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(pypi_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 66.
pub fn ruby_pypi_l66_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := pypi_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url': brew_runtime.string_value(generated.url)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 94.
pub fn ruby_pypi_l94_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := pypi_find_versions(PypiFindRequest{
		url: args[0].as_string()
		content: content
	}, pypi_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return pypi_match_data_value(result)
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
// 9:       # The {Pypi} strategy identifies the newest version of a PyPI package by
// 10:       # checking the JSON API endpoint for the project and using the
// 11:       # `info.version` field from the response.
// 12:       #
// 13:       # PyPI URLs have a standard format:
// 14:       #   `https://files.pythonhosted.org/packages/<hex>/<hex>/<long_hex>/example-1.2.3.tar.gz`
// 15:       #
// 16:       # Upstream documentation for the PyPI JSON API can be found at:
// 17:       #   https://docs.pypi.org/api/json/#get-a-project
// 18:       #
// 19:       # @api public
// 20:       class Pypi
// 21:         extend Strategic
// 22:
// 23:         # The default `strategy` block used to extract version information when
// 24:         # a `strategy` block isn't provided.
// 25:         DEFAULT_BLOCK = T.let(proc do |json, regex|
// 26:           version = json.dig("info", "version")
// 27:           next if version.blank?
// 28:
// 29:           regex ? version[regex, 1] : version
// 30:         end.freeze, T.proc.params(
// 31:           json:  T::Hash[String, T.anything],
// 32:           regex: T.nilable(Regexp),
// 33:         ).returns(T.nilable(String)))
// 34:
// 35:         # The `Regexp` used to extract the package name and suffix (e.g. file
// 36:         # extension) from the URL basename.
// 37:         FILENAME_REGEX = /
// 38:           (?<package_name>.+)- # The package name followed by a hyphen
// 39:           .*? # The version string
// 40:           (?<suffix>\.tar\.[a-z0-9]+|\.[a-z0-9]+)$ # Filename extension
// 41:         /ix
// 42:
// 43:         # The `Regexp` used to determine if the strategy applies to the URL.
// 44:         URL_MATCH_REGEX = %r{
// 45:           ^https?://files\.pythonhosted\.org
// 46:           /packages
// 47:           (?:/[^/]+)+ # The hexadecimal paths before the filename
// 48:           /#{FILENAME_REGEX.source.strip} # The filename
// 49:         }ix
// 50:
// 51:         # Whether the strategy can be applied to the provided URL.
// 52:         #
// 53:         # @param url [String] the URL to match against
// 54:         # @return [Boolean]
// 55:         sig { override.params(url: String).returns(T::Boolean) }
// 56:         def self.match?(url)
// 57:           URL_MATCH_REGEX.match?(url)
// 58:         end
// 59:
// 60:         # Extracts the package name from the provided URL and uses it to
// 61:         # generate the PyPI JSON API URL for the project.
// 62:         #
// 63:         # @param url [String] the URL used to generate values
// 64:         # @return [Hash]
// 65:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 66:         def self.generate_input_values(url)
// 67:           values = {}
// 68:
// 69:           match = File.basename(url).match(FILENAME_REGEX)
// 70:           return values if match.blank?
// 71:
// 72:           values[:url] = "https://pypi.org/pypi/#{T.must(match[:package_name]).gsub(/%20|_/, "-")}/json"
// 73:
// 74:           values
// 75:         end
// 76:
// 77:         # Generates a PyPI JSON API URL for the project and identifies new
// 78:         # versions using {Json#find_versions} with a block.
// 79:         #
// 80:         # @param url [String] the URL of the content to check
// 81:         # @param regex [Regexp, nil] a regex for matching versions in content
// 82:         # @param content [String, nil] content to check instead of fetching
// 83:         # @param options [Options] options to modify behavior
// 84:         # @return [Hash]
// 85:         sig {
// 86:           override.params(
// 87:             url:     String,
// 88:             regex:   T.nilable(Regexp),
// 89:             content: T.nilable(String),
// 90:             options: Options,
// 91:             block:   T.nilable(Proc),
// 92:           ).returns(T::Hash[Symbol, T.anything])
// 93:         }
// 94:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 95:           match_data = { matches: {}, regex:, url: }
// 96:
// 97:           generated = generate_input_values(url)
// 98:           return match_data if generated.blank?
// 99:
// 100:           Json.find_versions(
// 101:             url:     generated[:url],
// 102:             regex:,
// 103:             content:,
// 104:             options:,
// 105:             &block || DEFAULT_BLOCK
// 106:           )
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
