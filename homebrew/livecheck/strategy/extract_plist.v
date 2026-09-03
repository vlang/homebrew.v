module strategy

import brew_runtime
import homebrew
import homebrew.cask as cask_core
import homebrew.livecheck
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/extract_plist.rb`.
// The original source is retained below until every stub has a typed V body.
pub const extract_plist_priority = 0

pub struct ExtractPlistItem {
pub:
	bundle_version ?homebrew.BundleVersion
}

pub type ExtractPlistItems = map[string]ExtractPlistItem

pub type ExtractPlistVersionsBlock = fn(ExtractPlistItems, ?XmlRegex) !livecheck.StrategyBlockValue

pub struct ExtractPlistVersionsRequest {
pub:
	items     ExtractPlistItems
	regex     ?XmlRegex
	has_block bool
	block     ExtractPlistVersionsBlock = unsafe { nil }
}

pub struct ExtractPlistCask {
pub:
	token           string
	sourcefile_path ?string
	url             cask_core.CaskURL
	all_versions    map[string]homebrew.BundleVersion
}

pub struct ExtractPlistFindVersionsRequest {
pub:
	cask      ExtractPlistCask
	url       ?string
	regex     ?XmlRegex
	content   ?string
	options   livecheck.LivecheckOptions
	has_block bool
	block     ExtractPlistVersionsBlock = unsafe { nil }
}

pub struct ExtractPlistMatchData {
pub:
	matches     map[string]string
	regex       ?XmlRegex
	url         ?string
	cached      bool
	has_cached  bool
	content     string
	has_content bool
}

fn extract_plist_item_version(item ExtractPlistItem) ?string {
	if bundle_version := item.bundle_version {
		return bundle_version.version
	}
	return none
}

fn extract_plist_item_short_version(item ExtractPlistItem) ?string {
	if bundle_version := item.bundle_version {
		return bundle_version.short_version
	}
	return none
}

pub fn extract_plist_item_to_value(item ExtractPlistItem) brew_runtime.Value {
	bundle_version := item.bundle_version or {
		return brew_runtime.map_value({})
	}
	mut values := map[string]brew_runtime.Value{}
	for key, value in bundle_version.to_h() {
		values[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'bundle_version': brew_runtime.map_value(values)
	})
}

pub fn extract_plist_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

pub fn extract_plist_versions_from_content(request ExtractPlistVersionsRequest) ![]string {
	if request.has_block {
		return livecheck.strategy_handle_block_return(request.block(request.items, request.regex)!)
	}
	mut versions := []string{}
	for _, item in request.items {
		if bundle_version := item.bundle_version {
			version := bundle_version.nice_version()
			if version != '' && version !in versions {
				versions << version
			}
		}
	}
	return versions
}

const extract_plist_cask_url_keywords = ['verified', 'using', 'tag', 'branch', 'revisions', 'revision',
	'trust_cert', 'cookies', 'referer', 'header', 'user_agent', 'data', 'only_path']

pub fn extract_plist_cask_with_url(cask ExtractPlistCask, url string,
	url_options map[string]brew_runtime.Value) !ExtractPlistCask {
	mut unused_options := []string{}
	mut supported_options := map[string]brew_runtime.Value{}
	for key, value in url_options {
		if value.type_name == 'NilClass' {
			continue
		}
		if key !in extract_plist_cask_url_keywords {
			unused_options << key
			continue
		}
		supported_options[key] = value
	}
	if unused_options.len > 0 {
		unused_options.sort()
		label := if unused_options.len == 1 { 'option' } else { 'options' }
		return error('Cask `url` does not support `${unused_options.join('`, `')}` ${label} from `livecheck` block')
	}
	if cask.sourcefile_path == none {
		return error('unexpected nil cask.sourcefile_path')
	}
	return ExtractPlistCask{
		...cask
		url: cask_core.new_cask_url(url, supported_options)!
	}
}

fn extract_plist_json_optional_string(values map[string]json2.Any, key string) ?string {
	value := values[key] or { return none }
	text := value.str()
	return if text == '' || text == 'null' { none } else { text }
}

pub fn extract_plist_items_from_json(content string) !ExtractPlistItems {
	decoded := json2.decode[json2.Any](content) or { return error('Content could not be parsed as JSON.') }
	mut items := ExtractPlistItems{}
	for key, raw_item in decoded.as_map() {
		item_values := raw_item.as_map()
		bundle_values := (item_values['bundle_version'] or { continue }).as_map()
		short_version := extract_plist_json_optional_string(bundle_values, 'short_version')
		version := extract_plist_json_optional_string(bundle_values, 'version')
		bundle_version := homebrew.new_bundle_version(short_version, version) or { continue }
		items[key] = ExtractPlistItem{
			bundle_version: bundle_version
		}
	}
	return items
}

fn extract_plist_json_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
}

pub fn extract_plist_items_json(items ExtractPlistItems) string {
	mut keys := items.keys()
	keys.sort()
	mut entries := []string{cap: keys.len}
	for key in keys {
		item := items[key]
		bundle := item.bundle_version or { continue }
		mut fields := []string{}
		if short_version := bundle.short_version {
			fields << '"short_version":"${extract_plist_json_escape(short_version)}"'
		}
		if version := bundle.version {
			fields << '"version":"${extract_plist_json_escape(version)}"'
		}
		entries << '"${extract_plist_json_escape(key)}":{"bundle_version":{${fields.join(',')}}}'
	}
	return '{${entries.join(',')}}'
}

pub fn extract_plist_find_versions(request ExtractPlistFindVersionsRequest) !ExtractPlistMatchData {
	if regex := request.regex {
		if regex.pattern.trim_space() != '' && !request.has_block {
			return error('ExtractPlist only supports a regex when using a `strategy` block')
		}
	}
	mut match_data := ExtractPlistMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut items := ExtractPlistItems{}
	if content := request.content {
		match_data = ExtractPlistMatchData{
			...match_data
			cached: true
			has_cached: true
		}
		items = extract_plist_items_from_json(content)!
	} else {
		mut checked_cask := request.cask
		if url := request.url {
			if url.trim_space() != '' && url != request.cask.url.uri {
				checked_cask = extract_plist_cask_with_url(request.cask, url, request.options.url_options())!
			}
		}
		for key, bundle_version in checked_cask.all_versions {
			items[key] = ExtractPlistItem{
				bundle_version: bundle_version
			}
		}
	}
	if items.len == 0 {
		return match_data
	}
	versions := extract_plist_versions_from_content(ExtractPlistVersionsRequest{
		items: items
		regex: request.regex
		has_block: request.has_block
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	match_data = ExtractPlistMatchData{
		...match_data
		matches: matches
	}
	if !match_data.has_cached {
		match_data = ExtractPlistMatchData{
			...match_data
			content: extract_plist_items_json(items)
			has_content: true
		}
	}
	return match_data
}

pub fn extract_plist_match_data_to_value(data ExtractPlistMatchData) brew_runtime.Value {
	mut matches := map[string]brew_runtime.Value{}
	for version, parsed in data.matches {
		matches[version] = brew_runtime.object_value('Version', parsed)
	}
	mut values := map[string]brew_runtime.Value{}
	values['matches'] = brew_runtime.map_value(matches)
	values['regex'] = if regex := data.regex {
		brew_runtime.object_value('Regexp', regex.pattern)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
	values['url'] = if url := data.url {
		brew_runtime.string_value(url)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
	if data.has_cached {
		values['cached'] = brew_runtime.bool_value(data.cached)
	}
	if data.has_content {
		values['content'] = brew_runtime.string_value(data.content)
	}
	return brew_runtime.map_value(values)
}

// Ruby delegate `delegate version: :bundle_version` at line 39.
pub fn ruby_extract_plist_l39_d1_version(item ExtractPlistItem) ?string {
	return extract_plist_item_version(item)
}

// Ruby delegate `delegate short_version: :bundle_version` at line 45.
pub fn ruby_extract_plist_l45_d2_short_version(item ExtractPlistItem) ?string {
	return extract_plist_item_short_version(item)
}

// Ruby method `to_h` at line 48.
pub fn ruby_extract_plist_l48_d3_to_h(item ExtractPlistItem) brew_runtime.Value {
	return extract_plist_item_to_value(item)
}

// Ruby method `self.match?(url)` at line 60.
pub fn ruby_extract_plist_l60_d4_self_match(url string) bool {
	return extract_plist_matches(url)
}

// Ruby method `self.versions_from_content(items, regex = nil, &block)` at line 77.
pub fn ruby_extract_plist_l77_d5_self_versions_from_content(request ExtractPlistVersionsRequest) ![]string {
	return extract_plist_versions_from_content(request)
}

// Ruby method `self.cask_with_url(cask, url, url_options)` at line 104.
pub fn ruby_extract_plist_l104_d6_self_cask_with_url(cask ExtractPlistCask, url string,
	url_options map[string]brew_runtime.Value) !ExtractPlistCask {
	return extract_plist_cask_with_url(cask, url, url_options)
}

// Ruby method `self.find_versions(cask:, url: nil, regex: nil, content: nil, options: Options.new, &block)` at line 167.
pub fn ruby_extract_plist_l167_d7_self_find_versions(request ExtractPlistFindVersionsRequest) !ExtractPlistMatchData {
	return extract_plist_find_versions(request)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5: require "livecheck/strategic"
// 6: require "unversioned_cask_checker"
// 7:
// 8: module Homebrew
// 9:   module Livecheck
// 10:     module Strategy
// 11:       # The {ExtractPlist} strategy downloads the file at a URL and extracts
// 12:       # versions from contained `.plist` files using {UnversionedCaskChecker}.
// 13:       #
// 14:       # In practice, this strategy operates by downloading very large files,
// 15:       # so it's both slow and data-intensive. As such, the {ExtractPlist}
// 16:       # strategy should only be used as an absolute last resort.
// 17:       #
// 18:       # This strategy is not applied automatically and it's necessary to use
// 19:       # `strategy :extract_plist` in a `livecheck` block to apply it.
// 20:       class ExtractPlist
// 21:         extend Strategic
// 22:
// 23:         # A priority of zero causes livecheck to skip the strategy. We do this
// 24:         # for {ExtractPlist} so we can selectively apply it when appropriate.
// 25:         PRIORITY = 0
// 26:
// 27:         # The `Regexp` used to determine if the strategy applies to the URL.
// 28:         URL_MATCH_REGEX = %r{^https?://}i
// 29:
// 30:         Item = Struct.new(
// 31:           :bundle_version,
// 32:         ) do
// 33:           extend Forwardable
// 34:
// 35:           # The full version string from the bundle.
// 36:           #
// 37:           # @!attribute [r] version
// 38:           # @api public
// 39:           delegate version: :bundle_version
// 40:
// 41:           # The short version string from the bundle.
// 42:           #
// 43:           # @!attribute [r] short_version
// 44:           # @api public
// 45:           delegate short_version: :bundle_version
// 46:
// 47:           sig { returns(T::Hash[Symbol, T::Hash[Symbol, String]]) }
// 48:           def to_h
// 49:             {
// 50:               bundle_version: bundle_version&.to_h,
// 51:             }.compact
// 52:           end
// 53:         end
// 54:
// 55:         # Whether the strategy can be applied to the provided URL.
// 56:         #
// 57:         # @param url [String] the URL to match against
// 58:         # @return [Boolean]
// 59:         sig { override.params(url: String).returns(T::Boolean) }
// 60:         def self.match?(url)
// 61:           URL_MATCH_REGEX.match?(url)
// 62:         end
// 63:
// 64:         # Identify versions from `Item`s produced using
// 65:         # {UnversionedCaskChecker} version information.
// 66:         #
// 67:         # @param items [Hash] a hash of `Item`s containing version information
// 68:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 69:         # @return [Array]
// 70:         sig {
// 71:           params(
// 72:             items: T::Hash[String, Item],
// 73:             regex: T.nilable(Regexp),
// 74:             block: T.nilable(Proc),
// 75:           ).returns(T::Array[String])
// 76:         }
// 77:         def self.versions_from_content(items, regex = nil, &block)
// 78:           if block
// 79:             block_return_value = regex.present? ? yield(items, regex) : yield(items)
// 80:             return Strategy.handle_block_return(block_return_value)
// 81:           end
// 82:
// 83:           items.filter_map do |_key, item|
// 84:             item.bundle_version.nice_version
// 85:           end.uniq
// 86:         end
// 87:
// 88:         # Creates a copy of the cask with the artifact URL replaced by the
// 89:         # provided URL, using the provided `url_options`. This will error if
// 90:         # `url_options` contains any non-nil values with keys that aren't
// 91:         # found in the `Cask::URL.initialize` keyword parameters.
// 92:         # @param cask [Cask::Cask] the cask to copy and modify to use the
// 93:         #   provided URL and options
// 94:         # @param url [String] the replacement URL
// 95:         # @param url_options [Hash] options to use when replacing the URL
// 96:         # @return [Cask::Cask]
// 97:         sig {
// 98:           params(
// 99:             cask:        Cask::Cask,
// 100:             url:         String,
// 101:             url_options: T::Hash[Symbol, T.untyped],
// 102:           ).returns(Cask::Cask)
// 103:         }
// 104:         def self.cask_with_url(cask, url, url_options)
// 105:           # Collect the `Cask::URL` initializer keyword parameter symbols
// 106:           @cask_url_kw_params ||= T.let(
// 107:             (T::Utils.signature_for_method(Cask::URL.instance_method(:initialize))&.parameters ||
// 108:              Cask::URL.instance_method(:initialize).parameters).filter_map { |type, sym| sym if type == :key },
// 109:             T.nilable(T::Array[Symbol]),
// 110:           )
// 111:
// 112:           # Collect `livecheck` block URL options supported by `Cask::URL`
// 113:           unused_opts = []
// 114:           url_kwargs = url_options.select do |key, value|
// 115:             next if value.nil?
// 116:
// 117:             unless @cask_url_kw_params.include?(key)
// 118:               unused_opts << key
// 119:               next
// 120:             end
// 121:
// 122:             true
// 123:           end
// 124:
// 125:           unless unused_opts.empty?
// 126:             raise ArgumentError,
// 127:                   "Cask `url` does not support `#{unused_opts.join("`, `")}` " \
// 128:                   "#{Utils.pluralize("option", unused_opts.length)} from " \
// 129:                   "`livecheck` block"
// 130:           end
// 131:
// 132:           # Create a copy of the cask that overrides the artifact URL with the
// 133:           # provided URL and supported `livecheck` block URL options
// 134:           sourcefile_path = cask.sourcefile_path
// 135:           raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 136:
// 137:           cask_copy = Cask::CaskLoader.load(sourcefile_path)
// 138:           cask_copy.allow_reassignment = true
// 139:           cask_copy.url(url, **url_kwargs)
// 140:           cask_copy
// 141:         end
// 142:
// 143:         # Uses {UnversionedCaskChecker} on the provided cask to identify
// 144:         # versions from `plist` files.
// 145:         #
// 146:         # @param cask [Cask::Cask] the cask to check for version information
// 147:         # @param url [String, nil] an alternative URL to check for version
// 148:         #   information
// 149:         # @param content [String, nil] content to check instead of fetching
// 150:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 151:         # @param options [Options] options to modify behavior
// 152:         # @return [Hash]
// 153:         sig {
// 154:           # `find_versions` requires a `cask`, unlike the `Strategic` interface,
// 155:           # so `Livecheck` passes it via reflection on the strategy's parameters.
// 156:           # rubocop:disable Sorbet/AllowIncompatibleOverride
// 157:           override(allow_incompatible: true).params(
// 158:             cask:    Cask::Cask,
// 159:             url:     T.nilable(String),
// 160:             regex:   T.nilable(Regexp),
// 161:             content: T.nilable(String),
// 162:             options: Options,
// 163:             block:   T.nilable(Proc),
// 164:           ).returns(T::Hash[Symbol, T.anything])
// 165:           # rubocop:enable Sorbet/AllowIncompatibleOverride
// 166:         }
// 167:         def self.find_versions(cask:, url: nil, regex: nil, content: nil, options: Options.new, &block)
// 168:           if regex.present? && !block_given?
// 169:             raise ArgumentError,
// 170:                   "#{Utils.demodulize(name)} only supports a regex when using a `strategy` block"
// 171:           end
// 172:
// 173:           match_data = { matches: {}, regex:, url: }
// 174:
// 175:           items = if content
// 176:             match_data[:cached] = true
// 177:             Json.parse_json(content).transform_values do |obj|
// 178:               short_version = obj.dig("bundle_version", "short_version")
// 179:               version = obj.dig("bundle_version", "version")
// 180:               Item.new(bundle_version: BundleVersion.new(short_version, version))
// 181:             end
// 182:           else
// 183:             unversioned_cask_checker = if url.present? && url != cask.url.to_s
// 184:               UnversionedCaskChecker.new(cask_with_url(cask, url, options.url_options))
// 185:             else
// 186:               UnversionedCaskChecker.new(cask)
// 187:             end
// 188:
// 189:             unversioned_cask_checker.all_versions.transform_values { |v| Item.new(bundle_version: v) }
// 190:           end
// 191:           return match_data if items.blank?
// 192:
// 193:           versions_from_content(items, regex, &block).each do |version_text|
// 194:             match_data[:matches][version_text] = Version.new(version_text)
// 195:           end
// 196:
// 197:           require "json"
// 198:           match_data[:content] = JSON.generate(items.transform_values(&:to_h)) unless match_data[:cached]
// 199:           match_data
// 200:         end
// 201:       end
// 202:     end
// 203:   end
// 204: end
