module strategy

import ruby
import regex

// Translated from Homebrew/brew `livecheck/strategy/electron_builder.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ElectronBuilderSelector {
	default_version
	path_regex
	version_regex
}

pub struct ElectronBuilderRequest {
pub:
	url              string
	regex            ?string
	content          ?string
	selector         ElectronBuilderSelector
	case_insensitive bool = true
}

pub struct ElectronBuilderMatchData {
pub:
	matches map[string]string
	regex   ?string
	url     string
	cached  bool
}

pub fn electron_builder_matches_url(url string) bool {
	lower := url.to_lower()
	if !lower.starts_with('http://') && !lower.starts_with('https://') {
		return false
	}
	mut resource := url
	if query_index := resource.index('?') {
		query := resource[query_index + 1..]
		if query == '' || query.contains('/') || query.contains('?') {
			return false
		}
		resource = resource[..query_index]
	}
	path_start := if lower.starts_with('https://') { 8 } else { 7 }
	if resource.len <= path_start || !resource[path_start..].contains('/') {
		return false
	}
	filename := resource.all_after_last('/').to_lower()
	return filename != '' && (filename.ends_with('.yml') || filename.ends_with('.yaml'))
}

fn electron_builder_yaml_scalar(content string, key string) ?string {
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		prefix := '${key}:'
		if !trimmed.starts_with(prefix) {
			continue
		}
		mut value := trimmed[prefix.len..].trim_space()
		if value.len >= 2 && ((value.starts_with("'") && value.ends_with("'")) || (value.starts_with('"') && value.ends_with('"'))) {
			value = value[1..value.len - 1]
		}
		return value
	}
	return none
}

fn electron_builder_capture(pattern string, value string, case_insensitive bool) ?string {
	// Ruby accepts a trailing hyphen in a character class. Normalizing it to the
	// first position keeps the source regex's meaning with V's regex parser.
	v_pattern := pattern.replace('[._-]', '[-._]').replace('[_-]', '[-_]')
	mut expression := regex.regex_opt(v_pattern) or { return none }
	if case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	capture := expression.get_group_by_id(value, 0)
	if capture == '' {
		return none
	}
	return capture
}

pub fn electron_builder_find_versions(request ElectronBuilderRequest) !ElectronBuilderMatchData {
	if supplied_regex := request.regex {
		if supplied_regex != '' && request.selector == .default_version {
			return error('ElectronBuilder only supports a regex when using a `strategy` block')
		}
	}
	mut versions := map[string]string{}
	if request.url == '' {
		return ElectronBuilderMatchData{
			matches: versions
			regex: request.regex
			url: request.url
			cached: true
		}
	}
	content := request.content or { '' }
	if content == '' {
		return ElectronBuilderMatchData{
			matches: versions
			regex: request.regex
			url: request.url
			cached: true
		}
	}
	mut version := ''
	match request.selector {
		.default_version {
			version = electron_builder_yaml_scalar(content, 'version') or { '' }
		}
		.path_regex {
			path := electron_builder_yaml_scalar(content, 'path') or { '' }
			pattern := request.regex or { '' }
			version = electron_builder_capture(pattern, path, request.case_insensitive) or { '' }
		}
		.version_regex {
			value := electron_builder_yaml_scalar(content, 'version') or { '' }
			pattern := request.regex or { r'^v?(\d+(?:\.\d+)+)$' }
			version = electron_builder_capture(pattern, value, request.case_insensitive) or { '' }
		}
	}
	if version != '' {
		versions[version] = version
	}
	return ElectronBuilderMatchData{
		matches: versions
		regex: request.regex
		url: request.url
		cached: true
	}
}

pub fn electron_builder_match_data_to_value(data ElectronBuilderMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version, parsed in data.matches {
		matches[version] = ruby.object_value('Version', parsed)
	}
	regex_value := if value := data.regex {
		ruby.object_value('Regexp', value)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return ruby.map_value({
		'matches': ruby.map_value(matches)
		'regex':   regex_value
		'url':     ruby.string_value(data.url)
		'cached':  ruby.bool_value(data.cached)
	})
}

fn electron_builder_request_from_value(value ruby.Value) !ElectronBuilderRequest {
	values := value.as_map()!
	mut supplied_regex := ?string(none)
	if regex_value := values['regex'] {
		if regex_value.type_name != 'NilClass' && regex_value.as_string() != '' {
			supplied_regex = regex_value.as_string()
		}
	}
	mut content := ?string(none)
	if content_value := values['content'] {
		if content_value.type_name != 'NilClass' {
			content = content_value.as_string()
		}
	}
	selector := match values['selector'] or { ruby.string_value('default_version') }.as_string() {
		'path_regex' { ElectronBuilderSelector.path_regex }
		'version_regex' { ElectronBuilderSelector.version_regex }
		else { ElectronBuilderSelector.default_version }
	}
	return ElectronBuilderRequest{
		url: values['url'] or { ruby.string_value('') }.as_string()
		regex: supplied_regex
		content: content
		selector: selector
	}
}

// Ruby method `self.match?(url)` at line 28.
pub fn ruby_electron_builder_l28_d1_self_match(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(electron_builder_matches_url(args[0].as_string()))
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 48.
pub fn ruby_electron_builder_l48_d2_self_find_versions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'ElectronBuilder request is required')
	}
	request := electron_builder_request_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := electron_builder_find_versions(request) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return electron_builder_match_data_to_value(result)
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
// 9:       # The {ElectronBuilder} strategy fetches content at a URL and parses it
// 10:       # as an electron-builder appcast in YAML format.
// 11:       #
// 12:       # This strategy is not applied automatically and it's necessary to use
// 13:       # `strategy :electron_builder` in a `livecheck` block to apply it.
// 14:       class ElectronBuilder
// 15:         extend Strategic
// 16:
// 17:         # A priority of zero causes livecheck to skip the strategy. We do this
// 18:         # for {ElectronBuilder} so we can selectively apply it when appropriate.
// 19:         PRIORITY = 0
// 20:
// 21:         # The `Regexp` used to determine if the strategy applies to the URL.
// 22:         URL_MATCH_REGEX = %r{^https?://.+/[^/]+\.ya?ml(?:\?[^/?]+)?$}i
// 23:
// 24:         # Whether the strategy can be applied to the provided URL.
// 25:         #
// 26:         # @param url [String] the URL to match against
// 27:         sig { override.params(url: String).returns(T::Boolean) }
// 28:         def self.match?(url)
// 29:           URL_MATCH_REGEX.match?(url)
// 30:         end
// 31:
// 32:         # Checks the YAML content at the URL for new versions.
// 33:         #
// 34:         # @param url [String] the URL of the content to check
// 35:         # @param regex [Regexp, nil] a regex for matching versions in content
// 36:         # @param content [String, nil] content to check instead of fetching
// 37:         # @param options [Options] options to modify behavior
// 38:         # @return [Hash]
// 39:         sig {
// 40:           override.params(
// 41:             url:     String,
// 42:             regex:   T.nilable(Regexp),
// 43:             content: T.nilable(String),
// 44:             options: Options,
// 45:             block:   T.nilable(Proc),
// 46:           ).returns(T::Hash[Symbol, T.anything])
// 47:         }
// 48:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 49:           if regex.present? && !block_given?
// 50:             raise ArgumentError,
// 51:                   "#{Utils.demodulize(name)} only supports a regex when using a `strategy` block"
// 52:           end
// 53:
// 54:           Yaml.find_versions(
// 55:             url:,
// 56:             regex:,
// 57:             content:,
// 58:             options:,
// 59:             &block || proc { |yaml| yaml["version"] }
// 60:           )
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
