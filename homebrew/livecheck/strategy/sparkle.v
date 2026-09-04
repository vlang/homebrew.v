module strategy

import encoding.xml
import homebrew
import homebrew.livecheck
import time

// Translated from Homebrew/brew `livecheck/strategy/sparkle.rb`.
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

pub type SparkleVersionsBlock = fn ([]SparkleItem, ?XmlRegex) !livecheck.StrategyBlockValue

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
