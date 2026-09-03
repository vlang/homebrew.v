module strategy

import encoding.xml
import homebrew
import homebrew.livecheck
import time

// Translated from Homebrew/brew `livecheck/strategy/sparkle.rb`.
// The original source is retained below until every stub has a typed V body.
pub const sparkle_priority = 0
pub const sparkle_macos_strings = ['macos', 'osx']

pub struct SparkleItem {
pub mut:
	title                  ?string
	link                   ?string
	channel                ?string
	release_notes_link     ?string
	pub_date               i64
	os                     ?string
	url                    ?string
	bundle_version         ?homebrew.BundleVersion
	minimum_system_version ?homebrew.MacOSVersion
}

pub enum SparkleBlockParameter {
	item
	items
	anonymous
	invalid
}

pub type SparkleVersionsBlock = fn([]SparkleItem, ?XmlRegex) !livecheck.StrategyBlockValue

pub struct SparkleVersionsRequest {
pub:
	content         string
	regex           ?XmlRegex
	has_block       bool
	block_parameter SparkleBlockParameter = .invalid
	block           SparkleVersionsBlock = unsafe { nil }
}

pub struct SparkleFindVersionsRequest {
pub:
	url             string
	regex           ?XmlRegex
	content         ?string
	options         livecheck.StrategyOptions
	has_block       bool
	block_parameter SparkleBlockParameter = .invalid
	block           SparkleVersionsBlock = unsafe { nil }
}

pub struct SparkleMatchData {
pub:
	matches       map[string]string
	regex         ?XmlRegex
	url           string
	cached        bool
	has_cached    bool
	content       string
	has_content   bool
	final_url     string
	has_final_url bool
	messages      []string
	has_messages  bool
}

fn sparkle_present(value ?string) ?string {
	if text := value {
		if text.trim_space() != '' {
			return text.trim_space()
		}
	}
	return none
}

fn sparkle_attribute(element xml.XMLNode, key string) ?string {
	return sparkle_present(element.attributes[key] or { return none })
}

fn sparkle_macos_version(value ?string) ?homebrew.MacOSVersion {
	text := value or { return none }
	mut start := 0
	for start < text.len && !text[start].is_digit() {
		start++
	}
	mut end := text.len
	for end > start && !text[end - 1].is_digit() {
		end--
	}
	if start == end {
		return none
	}
	return homebrew.new_macos_version(text[start..end]) or { return none }
}

fn sparkle_title_versions(title ?string) (?string, ?string) {
	mut text := title or { return none, none }
	text = text.trim_right(' \t\r\n')
	mut full_version := ?string(none)
	if text.ends_with(')') {
		open := text.last_index('(') or { -1 }
		if open >= 0 {
			full_version = text[open..]
			text = text[..open].trim_right(' \t\r\n')
		}
	}
	mut start := text.len
	for start > 0 {
		character := text[start - 1]
		if character.is_digit() || character == `.` {
			start--
		} else {
			break
		}
	}
	candidate := text[start..]
	if candidate == '' || candidate.starts_with('.') || candidate.ends_with('.') {
		return none, none
	}
	for part in candidate.split('.') {
		if part == '' || !part.bytes().all(it.is_digit()) {
			return none, none
		}
	}
	return candidate, full_version
}

fn sparkle_bundle_version(short_version ?string,
	version ?string) ?homebrew.BundleVersion {
	if short_version == none && version == none {
		return none
	}
	return homebrew.new_bundle_version(short_version, version) or { return none }
}

fn sparkle_item_version(item SparkleItem) ?string {
	if bundle := item.bundle_version {
		return bundle.version
	}
	return none
}

fn sparkle_item_short_version(item SparkleItem) ?string {
	if bundle := item.bundle_version {
		return bundle.short_version
	}
	return none
}

fn sparkle_item_nice_version(item SparkleItem) ?string {
	if bundle := item.bundle_version {
		nice := bundle.nice_version()
		if nice != '' {
			return nice
		}
	}
	return none
}

pub fn sparkle_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

pub fn sparkle_items_from_content(content string) ![]SparkleItem {
	if content.trim_space() == '' {
		return []SparkleItem{}
	}
	document := xml_strip_prefixes(xml_parse_xml(content)!)
	mut items := []SparkleItem{}
	for node in xml_elements(document, '//rss//channel//item') {
		enclosure := xml_child(node, 'enclosure')
		mut url := ?string(none)
		mut short_version := ?string(none)
		mut version := ?string(none)
		mut item_os := ?string(none)
		if enclosure_node := enclosure {
			url = sparkle_attribute(enclosure_node, 'url')
			short_version = sparkle_attribute(enclosure_node, 'shortVersionString')
			version = sparkle_attribute(enclosure_node, 'version')
			item_os = sparkle_attribute(enclosure_node, 'os')
		}
		title := sparkle_present(xml_element_text(node, 'title'))
		link := sparkle_present(xml_element_text(node, 'link'))
		if url == none {
			url = link
		}
		channel := sparkle_present(xml_element_text(node, 'channel'))
		release_notes_link := sparkle_present(xml_element_text(node, 'releaseNotesLink'))
		if short_version == none {
			short_version = sparkle_present(xml_element_text(node, 'shortVersionString'))
		}
		if version == none {
			version = sparkle_present(xml_element_text(node, 'version'))
		}
		minimum_system_version := sparkle_macos_version(xml_element_text(node, 'minimumSystemVersion'))
		mut pub_date := i64(0)
		if date_text := xml_element_text(node, 'pubDate') {
			parsed := time.parse_rfc2822(date_text) or { time.unix(0) }
			pub_date = parsed.unix()
		}
		title_short, title_version := sparkle_title_versions(title)
		if short_version == none {
			short_version = title_short
		}
		if version == none {
			version = title_version
		}
		bundle_version := sparkle_bundle_version(short_version, version)
		if title == none && link == none && channel == none && release_notes_link == none && item_os == none && url == none && bundle_version == none && minimum_system_version == none && pub_date == 0 {
			continue
		}
		items << SparkleItem{
			title: title
			link: link
			channel: channel
			release_notes_link: release_notes_link
			pub_date: pub_date
			os: item_os
			url: url
			bundle_version: bundle_version
			minimum_system_version: minimum_system_version
		}
	}
	return items
}

pub fn sparkle_filter_items(items []SparkleItem, newest_unsupported string) ![]SparkleItem {
	mut selected := []SparkleItem{}
	for item in items {
		if item_os := item.os {
			if item_os !in sparkle_macos_strings {
				continue
			}
		}
		if minimum := item.minimum_system_version {
			if minimum.strip_patch().prerelease(newest_unsupported)! {
				continue
			}
		}
		selected << item
	}
	return selected
}

fn sparkle_compare_items(left SparkleItem, right SparkleItem) int {
	if left.pub_date != right.pub_date {
		return if left.pub_date > right.pub_date { -1 } else { 1 }
	}
	if left_bundle := left.bundle_version {
		if right_bundle := right.bundle_version {
			return -left_bundle.compare_to(right_bundle)
		}
		return -1
	}
	return if right.bundle_version == none { 0 } else { 1 }
}

pub fn sparkle_sort_items(items []SparkleItem) []SparkleItem {
	mut sorted := items.clone()
	for index in 1 .. sorted.len {
		mut position := index
		for position > 0 && sparkle_compare_items(sorted[position], sorted[position - 1]) < 0 {
			temporary := sorted[position - 1]
			sorted[position - 1] = sorted[position]
			sorted[position] = temporary
			position--
		}
	}
	return sorted
}

pub fn sparkle_versions_from_content(request SparkleVersionsRequest,
	newest_unsupported string) ![]string {
	items := sparkle_sort_items(sparkle_filter_items(sparkle_items_from_content(request.content)!, newest_unsupported)!)
	if items.len == 0 {
		return []string{}
	}
	if request.has_block {
		if request.block_parameter == .invalid {
			return error('First argument of Sparkle `strategy` block must be `item` or `items`')
		}
		passed_items := if request.block_parameter in [.item, .anonymous] {
			[items[0]]
		} else {
			items
		}
		value := request.block(passed_items, request.regex)!
		return livecheck.strategy_handle_block_return(value)
	}
	version := sparkle_item_nice_version(items[0]) or { return []string{} }
	return [version]
}

pub fn sparkle_find_versions(request SparkleFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher, newest_unsupported string) !SparkleMatchData {
	if _ := request.regex {
		if !request.has_block {
			return error('Sparkle only supports a regex when using a `strategy` block')
		}
	}
	mut match_data := SparkleMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied := request.content {
		match_data = SparkleMatchData{ ...match_data, cached: true, has_cached: true }
		content = supplied
	}
	if request.url.trim_space() == '' {
		return match_data
	}
	if !match_data.has_cached {
		page := livecheck.strategy_page_content(request.url, request.options, fetcher)!
		match_data = SparkleMatchData{
			...match_data
			content: page.content
			has_content: page.has_content
			final_url: page.final_url
			has_final_url: page.has_final_url
			messages: page.messages.clone()
			has_messages: page.has_messages
		}
		content = page.content
	}
	if content.trim_space() == '' {
		return match_data
	}
	versions := sparkle_versions_from_content(SparkleVersionsRequest{
		content: content
		regex: request.regex
		has_block: request.has_block
		block_parameter: request.block_parameter
		block: request.block
	}, newest_unsupported)!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return SparkleMatchData{ ...match_data, matches: matches }
}

// Ruby method `self.match?(url)` at line 33.
pub fn ruby_sparkle_l33_d1_self_match(url string) bool {
	return sparkle_matches(url)
}

// Ruby delegate `delegate version: :bundle_version` at line 71.
pub fn ruby_sparkle_l71_d2_version(item SparkleItem) ?string {
	return sparkle_item_version(item)
}

// Ruby delegate `delegate short_version: :bundle_version` at line 77.
pub fn ruby_sparkle_l77_d3_short_version(item SparkleItem) ?string {
	return sparkle_item_short_version(item)
}

// Ruby delegate `delegate nice_version: :bundle_version` at line 83.
pub fn ruby_sparkle_l83_d4_nice_version(item SparkleItem) ?string {
	return sparkle_item_nice_version(item)
}

// Ruby method `self.items_from_content(content)` at line 91.
pub fn ruby_sparkle_l91_d5_self_items_from_content(content string) ![]SparkleItem {
	return sparkle_items_from_content(content)
}

// Ruby method `self.filter_items(items)` at line 170.
pub fn ruby_sparkle_l170_d6_self_filter_items(items []SparkleItem,
	newest_unsupported string) ![]SparkleItem {
	return sparkle_filter_items(items, newest_unsupported)
}

// Ruby method `self.sort_items(items)` at line 190.
pub fn ruby_sparkle_l190_d7_self_sort_items(items []SparkleItem) []SparkleItem {
	return sparkle_sort_items(items)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 209.
pub fn ruby_sparkle_l209_d8_self_versions_from_content(request SparkleVersionsRequest,
	newest_unsupported string) ![]string {
	return sparkle_versions_from_content(request, newest_unsupported)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 247.
pub fn ruby_sparkle_l247_d9_self_find_versions(request SparkleFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher, newest_unsupported string) !SparkleMatchData {
	return sparkle_find_versions(request, fetcher, newest_unsupported)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5: require "livecheck/strategic"
// 6:
// 7: module Homebrew
// 8:   module Livecheck
// 9:     module Strategy
// 10:       # The {Sparkle} strategy fetches content at a URL and parses it as a
// 11:       # Sparkle appcast in XML format.
// 12:       #
// 13:       # This strategy is not applied automatically and it's necessary to use
// 14:       # `strategy :sparkle` in a `livecheck` block to apply it.
// 15:       class Sparkle
// 16:         extend Strategic
// 17:
// 18:         # A priority of zero causes livecheck to skip the strategy. We do this
// 19:         # for {Sparkle} so we can selectively apply it when appropriate.
// 20:         PRIORITY = 0
// 21:
// 22:         # The `Regexp` used to determine if the strategy applies to the URL.
// 23:         URL_MATCH_REGEX = %r{^https?://}i
// 24:
// 25:         # Common `os` values used in appcasts to refer to macOS.
// 26:         APPCAST_MACOS_STRINGS = ["macos", "osx"].freeze
// 27:
// 28:         # Whether the strategy can be applied to the provided URL.
// 29:         #
// 30:         # @param url [String] the URL to match against
// 31:         # @return [Boolean]
// 32:         sig { override.params(url: String).returns(T::Boolean) }
// 33:         def self.match?(url)
// 34:           URL_MATCH_REGEX.match?(url)
// 35:         end
// 36:
// 37:         Item = Struct.new(
// 38:           # The title of the Sparkle feed item.
// 39:           # @api public
// 40:           :title,
// 41:           # The download link for the item.
// 42:           # @api public
// 43:           :link,
// 44:           # The release channel name.
// 45:           # @api public
// 46:           :channel,
// 47:           # The URL for the release notes.
// 48:           # @api public
// 49:           :release_notes_link,
// 50:           # The publication date of the item.
// 51:           # @api public
// 52:           :pub_date,
// 53:           # The target operating system.
// 54:           # @api public
// 55:           :os,
// 56:           # The download URL for the update.
// 57:           # @api public
// 58:           :url,
// 59:           # @api private
// 60:           :bundle_version,
// 61:           # The minimum required system version.
// 62:           # @api public
// 63:           :minimum_system_version,
// 64:         ) do
// 65:           extend Forwardable
// 66:
// 67:           # The full version string from the bundle.
// 68:           #
// 69:           # @!attribute [r] version
// 70:           # @api public
// 71:           delegate version: :bundle_version
// 72:
// 73:           # The short version string from the bundle.
// 74:           #
// 75:           # @!attribute [r] short_version
// 76:           # @api public
// 77:           delegate short_version: :bundle_version
// 78:
// 79:           # The combined version and short version string.
// 80:           #
// 81:           # @!attribute [r] nice_version
// 82:           # @api public
// 83:           delegate nice_version: :bundle_version
// 84:         end
// 85:
// 86:         # Identifies version information from a Sparkle appcast.
// 87:         #
// 88:         # @param content [String] the text of the Sparkle appcast
// 89:         # @return [Item, nil]
// 90:         sig { params(content: String).returns(T::Array[Item]) }
// 91:         def self.items_from_content(content)
// 92:           require "rexml/document"
// 93:           xml = Xml.parse_xml(content)
// 94:
// 95:           # Remove prefixes, so we can reliably identify elements and attributes
// 96:           xml.root&.each_recursive do |node|
// 97:             node.prefix = ""
// 98:             node.attributes.each_attribute do |attribute|
// 99:               attribute.prefix = ""
// 100:             end
// 101:           end
// 102:
// 103:           xml.get_elements("//rss//channel//item").filter_map do |item|
// 104:             enclosure = item.elements["enclosure"]
// 105:
// 106:             if enclosure
// 107:               url = enclosure["url"].presence
// 108:               short_version = enclosure["shortVersionString"].presence
// 109:               version = enclosure["version"].presence
// 110:               os = enclosure["os"].presence
// 111:             end
// 112:
// 113:             title = Xml.element_text(item, "title")
// 114:             link = Xml.element_text(item, "link")
// 115:             url ||= link
// 116:             channel = Xml.element_text(item, "channel")
// 117:             release_notes_link = Xml.element_text(item, "releaseNotesLink")
// 118:             short_version ||= Xml.element_text(item, "shortVersionString")
// 119:             version ||= Xml.element_text(item, "version")
// 120:
// 121:             minimum_system_version_text =
// 122:               Xml.element_text(item, "minimumSystemVersion")&.gsub(/\A\D+|\D+\z/, "")
// 123:             if minimum_system_version_text.present?
// 124:               minimum_system_version = begin
// 125:                 MacOSVersion.new(minimum_system_version_text)
// 126:               rescue MacOSVersion::Error
// 127:                 nil
// 128:               end
// 129:             end
// 130:
// 131:             pub_date = Xml.element_text(item, "pubDate")&.then do |date_string|
// 132:               Time.parse(date_string)
// 133:             rescue ArgumentError
// 134:               # Omit unparsable strings (e.g. non-English dates)
// 135:               nil
// 136:             end
// 137:
// 138:             if (match = title&.match(/(\d+(?:\.\d+)*)\s*(\([^)]+\))?\Z/))
// 139:               short_version ||= match[1]
// 140:               version ||= match[2]
// 141:             end
// 142:
// 143:             bundle_version = BundleVersion.new(short_version, version) if short_version || version
// 144:
// 145:             data = {
// 146:               title:,
// 147:               link:,
// 148:               channel:,
// 149:               release_notes_link:,
// 150:               pub_date:,
// 151:               os:,
// 152:               url:,
// 153:               bundle_version:,
// 154:               minimum_system_version:,
// 155:             }.compact
// 156:             next if data.empty?
// 157:
// 158:             # Set a default `pub_date` (for sorting) if one isn't provided
// 159:             data[:pub_date] ||= Time.new(0)
// 160:
// 161:             Item.new(**data)
// 162:           end
// 163:         end
// 164:
// 165:         # Filters out items that aren't suitable for Homebrew.
// 166:         #
// 167:         # @param items [Array] appcast items
// 168:         # @return [Array]
// 169:         sig { params(items: T::Array[Item]).returns(T::Array[Item]) }
// 170:         def self.filter_items(items)
// 171:           items.select do |item|
// 172:             # Omit items with an explicit `os` value that isn't macOS
// 173:             next false if item.os && APPCAST_MACOS_STRINGS.none?(item.os)
// 174:
// 175:             # Omit items for prerelease macOS versions
// 176:             if (minimum_system_version = item.minimum_system_version) &&
// 177:                minimum_system_version.strip_patch.prerelease?
// 178:               next false
// 179:             end
// 180:
// 181:             true
// 182:           end.compact
// 183:         end
// 184:
// 185:         # Sorts items from newest to oldest.
// 186:         #
// 187:         # @param items [Array] appcast items
// 188:         # @return [Array]
// 189:         sig { params(items: T::Array[Item]).returns(T::Array[Item]) }
// 190:         def self.sort_items(items)
// 191:           items.sort_by { |item| [item.pub_date, item.bundle_version] }
// 192:                .reverse
// 193:         end
// 194:
// 195:         # Uses `#items_from_content` to identify versions from the Sparkle
// 196:         # appcast content or, if a block is provided, passes the content to
// 197:         # the block to handle matching.
// 198:         #
// 199:         # @param content [String] the content to check
// 200:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 201:         # @return [Array]
// 202:         sig {
// 203:           params(
// 204:             content: String,
// 205:             regex:   T.nilable(Regexp),
// 206:             block:   T.nilable(Proc),
// 207:           ).returns(T::Array[String])
// 208:         }
// 209:         def self.versions_from_content(content, regex = nil, &block)
// 210:           items = sort_items(filter_items(items_from_content(content)))
// 211:           return [] if items.empty?
// 212:
// 213:           item = items.fetch(0)
// 214:
// 215:           if block
// 216:             block_return_value = case block.parameters[0]
// 217:             when [:opt, :item], [:req, :item], [:rest], [:req]
// 218:               regex.present? ? yield(item, regex) : yield(item)
// 219:             when [:opt, :items], [:req, :items]
// 220:               regex.present? ? yield(items, regex) : yield(items)
// 221:             else
// 222:               raise ArgumentError, "First argument of Sparkle `strategy` block must be `item` or `items`"
// 223:             end
// 224:             return Strategy.handle_block_return(block_return_value)
// 225:           end
// 226:
// 227:           version = item.bundle_version&.nice_version
// 228:           version.present? ? [version] : []
// 229:         end
// 230:
// 231:         # Checks the content at the URL for new versions.
// 232:         #
// 233:         # @param url [String] the URL of the content to check
// 234:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 235:         # @param content [String, nil] content to check instead of fetching
// 236:         # @param options [Options] options to modify behavior
// 237:         # @return [Hash]
// 238:         sig {
// 239:           override.params(
// 240:             url:     String,
// 241:             regex:   T.nilable(Regexp),
// 242:             content: T.nilable(String),
// 243:             options: Options,
// 244:             block:   T.nilable(Proc),
// 245:           ).returns(T::Hash[Symbol, T.anything])
// 246:         }
// 247:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 248:           if regex.present? && !block_given?
// 249:             raise ArgumentError,
// 250:                   "#{Utils.demodulize(name)} only supports a regex when using a `strategy` block"
// 251:           end
// 252:
// 253:           match_data = { matches: {}, regex:, url: }
// 254:           match_data[:cached] = true if content
// 255:           return match_data if url.blank?
// 256:
// 257:           unless match_data[:cached]
// 258:             match_data.merge!(Strategy.page_content(url, options:))
// 259:             content = match_data[:content]
// 260:           end
// 261:           return match_data if content.blank?
// 262:
// 263:           versions_from_content(content, regex, &block).each do |version_text|
// 264:             match_data[:matches][version_text] = Version.new(version_text)
// 265:           end
// 266:
// 267:           match_data
// 268:         end
// 269:       end
// 270:     end
// 271:   end
// 272: end
