module strategy

import brew_runtime
import homebrew
import homebrew.livecheck
import homebrew.utils

// Translated from Homebrew/brew `livecheck/strategy/gnome.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GnomeInputValues {
pub:
	present bool
	url     string
	regex   PageMatchRegex
}

pub struct GnomeFindRequest {
pub:
	url       string
	regex     ?PageMatchRegex
	content   ?string
	options   livecheck.StrategyOptions
	has_block bool
	block     PageMatchVersionsBlock = unsafe { nil }
}

fn gnome_package_name(url string) ?string {
	lower := url.to_lower()
	prefix_length := if lower.starts_with('https://download.gnome.org/sources/') {
		'https://download.gnome.org/sources/'.len
	} else if lower.starts_with('http://download.gnome.org/sources/') {
		'http://download.gnome.org/sources/'.len
	} else {
		return none
	}
	remainder := url[prefix_length..]
	package_end := remainder.index('/') or { return none }
	if package_end == 0 {
		return none
	}
	return remainder[..package_end]
}

fn gnome_regex_escape(value string) string {
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
	// removes that escape with `gsub("\\-")`.
	return escaped
}

pub fn gnome_matches_url(url string) bool {
	if _ := gnome_package_name(url) {
		return true
	}
	return false
}

pub fn gnome_generate_input_values(url string) GnomeInputValues {
	package_name := gnome_package_name(url) or { return GnomeInputValues{} }
	regex_name := gnome_regex_escape(package_name)

	// GNOME archive files seem to use a standard filename format, so we
	// count on the delimiter between the package name and numeric
	// version being a hyphen and the file being a tarball.
	return GnomeInputValues{
		present: true
		url: 'https://download.gnome.org/sources/${package_name}/cache.json'
		regex: PageMatchRegex{
			pattern: '${regex_name}-(\\d+(?:\\.\\d+)*)\\.t'
			case_insensitive: true
		}
	}
}

fn gnome_unstable_version(version_text string) !bool {
	version := homebrew.new_version(version_text)!
	major := version.major() or { return false }
	if homebrew.token_operand_relation(major, '>=', 40)! {
		return false
	}
	minor := version.minor() or { return false }
	if minor.to_s().int() % 2 != 0 || homebrew.token_operand_relation(minor, '>=', 90)! {
		return true
	}
	if patch := version.patch() {
		return homebrew.token_operand_relation(patch, '>=', 90)!
	}
	return false
}

pub fn gnome_find_versions(request GnomeFindRequest,
	fetcher livecheck.StrategyContentFetcher) !PageMatchData {
	generated := gnome_generate_input_values(request.url)
	generated_regex := if generated.present { ?PageMatchRegex(generated.regex) } else { none }
	effective_regex := if provided := request.regex {
		?PageMatchRegex(provided)
	} else {
		generated_regex
	}
	match_data := page_match_find_versions(PageMatchFindVersionsRequest{
		url: if generated.present { generated.url } else { '' }
		regex: effective_regex
		content: request.content
		options: request.options
		has_block: request.has_block
		block: request.block
	}, fetcher)!
	if request.regex != none {
		return match_data
	}

	// Filter out unstable versions using the old version scheme where
	// the major version is below 40.
	mut matches := map[string]string{}
	for match_text, version_text in match_data.matches {
		if !gnome_unstable_version(version_text)! {
			matches[match_text] = version_text
		}
	}
	return PageMatchData{
		...match_data
		matches: matches
	}
}

fn gnome_empty_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		exit_status: 1
	}
}

fn gnome_match_data_value(result PageMatchData) brew_runtime.Value {
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

// Ruby method `self.match?(url)` at line 44.
pub fn ruby_gnome_l44_d1_self_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(gnome_matches_url(args[0].as_string()))
}

// Ruby method `self.generate_input_values(url)` at line 56.
pub fn ruby_gnome_l56_d2_self_generate_input_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	generated := gnome_generate_input_values(args[0].as_string())
	if !generated.present {
		return brew_runtime.map_value({})
	}
	return brew_runtime.map_value({
		'url':   brew_runtime.string_value(generated.url)
		'regex': brew_runtime.object_value('Regexp', generated.regex.pattern)
	})
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 91.
pub fn ruby_gnome_l91_d3_self_find_versions(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value({})
	}
	content := if args.len > 1 { ?string(args[1].as_string()) } else { none }
	result := gnome_find_versions(GnomeFindRequest{
		url: args[0].as_string()
		content: content
	}, gnome_empty_fetcher) or { return brew_runtime.object_value('Error', err.msg()) }
	return gnome_match_data_value(result)
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
// 9:       # The {Gnome} strategy identifies versions of software at gnome.org by
// 10:       # checking the available downloads found in a project's `cache.json`
// 11:       # file.
// 12:       #
// 13:       # GNOME URLs generally follow a standard format:
// 14:       #
// 15:       # * `https://download.gnome.org/sources/example/1.2/example-1.2.3.tar.xz`
// 16:       #
// 17:       # Before version 40, GNOME used a version scheme where unstable releases
// 18:       # were indicated with a minor that's 90+ or odd. The newer version scheme
// 19:       # uses trailing alpha/beta/rc text to identify unstable versions
// 20:       # (e.g. `40.alpha`).
// 21:       #
// 22:       # When a regex isn't provided in a `livecheck` block, the strategy uses
// 23:       # a default regex that matches versions which don't include trailing text
// 24:       # after the numeric version (e.g. `40.0` instead of `40.alpha`) and it
// 25:       # selectively filters out unstable versions below 40 using the rules for
// 26:       # the older version scheme.
// 27:       #
// 28:       # @api public
// 29:       class Gnome
// 30:         extend Strategic
// 31:
// 32:         # The `Regexp` used to determine if the strategy applies to the URL.
// 33:         URL_MATCH_REGEX = %r{
// 34:           ^https?://download\.gnome\.org
// 35:           /sources
// 36:           /(?<package_name>[^/]+)/ # The GNOME package name
// 37:         }ix
// 38:
// 39:         # Whether the strategy can be applied to the provided URL.
// 40:         #
// 41:         # @param url [String] the URL to match against
// 42:         # @return [Boolean]
// 43:         sig { override.params(url: String).returns(T::Boolean) }
// 44:         def self.match?(url)
// 45:           URL_MATCH_REGEX.match?(url)
// 46:         end
// 47:
// 48:         # Extracts information from a provided URL and uses it to generate
// 49:         # various input values used by the strategy to check for new versions.
// 50:         # Some of these values act as defaults and can be overridden in a
// 51:         # `livecheck` block.
// 52:         #
// 53:         # @param url [String] the URL used to generate values
// 54:         # @return [Hash]
// 55:         sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
// 56:         def self.generate_input_values(url)
// 57:           values = {}
// 58:
// 59:           match = url.match(URL_MATCH_REGEX)
// 60:           return values if match.blank?
// 61:
// 62:           values[:url] = "https://download.gnome.org/sources/#{match[:package_name]}/cache.json"
// 63:
// 64:           regex_name = Regexp.escape(T.must(match[:package_name])).gsub("\\-", "-")
// 65:
// 66:           # GNOME archive files seem to use a standard filename format, so we
// 67:           # count on the delimiter between the package name and numeric
// 68:           # version being a hyphen and the file being a tarball.
// 69:           values[:regex] = /#{regex_name}-(\d+(?:\.\d+)*)\.t/i
// 70:
// 71:           values
// 72:         end
// 73:
// 74:         # Generates a URL and regex (if one isn't provided) and passes them
// 75:         # to {PageMatch.find_versions} to identify versions in the content.
// 76:         #
// 77:         # @param url [String] the URL of the content to check
// 78:         # @param regex [Regexp, nil] a regex for matching versions in content
// 79:         # @param content [String, nil] content to check instead of fetching
// 80:         # @param options [Options] options to modify behavior
// 81:         # @return [Hash]
// 82:         sig {
// 83:           override.params(
// 84:             url:     String,
// 85:             regex:   T.nilable(Regexp),
// 86:             content: T.nilable(String),
// 87:             options: Options,
// 88:             block:   T.nilable(Proc),
// 89:           ).returns(T::Hash[Symbol, T.anything])
// 90:         }
// 91:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 92:           generated = generate_input_values(url)
// 93:
// 94:           match_data = PageMatch.find_versions(
// 95:             url:     generated[:url],
// 96:             regex:   regex || generated[:regex],
// 97:             content:,
// 98:             options:,
// 99:             &block
// 100:           )
// 101:
// 102:           if regex.blank?
// 103:             # Filter out unstable versions using the old version scheme where
// 104:             # the major version is below 40.
// 105:             match_data[:matches].reject! do |_, version|
// 106:               next if version.major >= 40
// 107:               next if version.minor.blank?
// 108:
// 109:               (version.minor.to_i.odd? || version.minor >= 90) ||
// 110:                 (version.patch.present? && version.patch >= 90)
// 111:             end
// 112:           end
// 113:
// 114:           match_data
// 115:         end
// 116:       end
// 117:     end
// 118:   end
// 119: end
