module strategy

import ruby
import homebrew
import homebrew.cask as cask_core
import homebrew.livecheck
import x.json2

// Translated from Homebrew/brew `livecheck/strategy/extract_plist.rb`.
pub const extract_plist_priority = 0

pub struct ExtractPlistItem {
pub:
	bundle_version ?homebrew.BundleVersion
}

pub type ExtractPlistItems = map[string]ExtractPlistItem

pub type ExtractPlistVersionsBlock = fn (ExtractPlistItems, ?XmlRegex) !livecheck.StrategyBlockValue

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

pub fn extract_plist_item_to_value(item ExtractPlistItem) ruby.Value {
	bundle_version := item.bundle_version or {
		return ruby.map_value({})
	}
	mut values := map[string]ruby.Value{}
	for key, value in bundle_version.to_h() {
		values[key] = ruby.string_value(value)
	}
	return ruby.map_value({
		'bundle_version': ruby.map_value(values)
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
	url_options map[string]ruby.Value) !ExtractPlistCask {
	mut unused_options := []string{}
	mut supported_options := map[string]ruby.Value{}
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

pub fn extract_plist_match_data_to_value(data ExtractPlistMatchData) ruby.Value {
	mut matches := map[string]ruby.Value{}
	for version, parsed in data.matches {
		matches[version] = ruby.object_value('Version', parsed)
	}
	mut values := map[string]ruby.Value{}
	values['matches'] = ruby.map_value(matches)
	values['regex'] = if regex := data.regex {
		ruby.object_value('Regexp', regex.pattern)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	values['url'] = if url := data.url {
		ruby.string_value(url)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	if data.has_cached {
		values['cached'] = ruby.bool_value(data.cached)
	}
	if data.has_content {
		values['content'] = ruby.string_value(data.content)
	}
	return ruby.map_value(values)
}
