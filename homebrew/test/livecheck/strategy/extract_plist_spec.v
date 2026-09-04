module strategy

import ruby
import homebrew
import homebrew.cask as cask_core
import homebrew.livecheck
import homebrew.livecheck.strategy as extract_plist_core
import regex

// Translated from Homebrew/brew `test/livecheck/strategy/extract_plist_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn extract_plist_spec_bundle(version string) homebrew.BundleVersion {
	return homebrew.new_bundle_version(none, version) or { panic(err) }
}

fn extract_plist_spec_items() extract_plist_core.ExtractPlistItems {
	return extract_plist_core.ExtractPlistItems({
		'first':  extract_plist_core.ExtractPlistItem{
			bundle_version: extract_plist_spec_bundle('1.2')
		}
		'second': extract_plist_core.ExtractPlistItem{
			bundle_version: extract_plist_spec_bundle('1.2.3')
		}
	})
}

fn extract_plist_spec_multipart_items() extract_plist_core.ExtractPlistItems {
	return extract_plist_core.ExtractPlistItems({
		'first':  extract_plist_core.ExtractPlistItem{
			bundle_version: extract_plist_spec_bundle('1.2.3-45')
		}
		'second': extract_plist_core.ExtractPlistItem{
			bundle_version: extract_plist_spec_bundle('1.2.3-45-abcdef')
		}
	})
}

fn extract_plist_spec_string_block(items extract_plist_core.ExtractPlistItems,
	_ ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	version := extract_plist_core.ruby_extract_plist_l39_d1_version(items['first']) or { '' }
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: version
	}
}

fn extract_plist_spec_array_block(items extract_plist_core.ExtractPlistItems,
	_ ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	mut values := []livecheck.StrategyBlockItem{}
	for _, item in items {
		bundle := item.bundle_version or { continue }
		values << livecheck.StrategyBlockItem{
			kind: .string_value
			value: bundle.nice_version()
		}
	}
	return livecheck.StrategyBlockValue{
		kind: .array
		values: values
	}
}

fn extract_plist_spec_caffeine_block(items extract_plist_core.ExtractPlistItems,
	_ ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	version := extract_plist_core.ruby_extract_plist_l39_d1_version(items['com.caffeine']) or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: version
	}
}

fn extract_plist_spec_multipart_capture(value string,
	provided ?extract_plist_core.XmlRegex) !string {
	config := provided or { return '' }
	mut expression := regex.regex_opt(config.pattern.replace('[._-]', '[-._]'))!
	if config.case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return ''
	}
	mut captures := []string{}
	for group in 0 .. 3 {
		capture := expression.get_group_by_id(value, group)
		if capture != '' {
			captures << capture
		}
	}
	return captures.join(',')
}

fn extract_plist_spec_multipart_string_block(items extract_plist_core.ExtractPlistItems,
	provided ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	item := items['first']
	version := extract_plist_core.ruby_extract_plist_l39_d1_version(item) or { '' }
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: extract_plist_spec_multipart_capture(version, provided)!
	}
}

fn extract_plist_spec_multipart_array_block(items extract_plist_core.ExtractPlistItems,
	provided ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	mut values := []livecheck.StrategyBlockItem{}
	for _, item in items {
		version := extract_plist_core.ruby_extract_plist_l39_d1_version(item) or { '' }
		values << livecheck.StrategyBlockItem{
			kind: .string_value
			value: extract_plist_spec_multipart_capture(version, provided)!
		}
	}
	return livecheck.StrategyBlockValue{
		kind: .array
		values: values
	}
}

fn extract_plist_spec_nil_block(_ extract_plist_core.ExtractPlistItems,
	_ ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .nil_value
	}
}

fn extract_plist_spec_invalid_block(_ extract_plist_core.ExtractPlistItems,
	_ ?extract_plist_core.XmlRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .invalid
	}
}

fn extract_plist_spec_cask(artifact_url string) extract_plist_core.ExtractPlistCask {
	return extract_plist_core.ExtractPlistCask{
		token: 'livecheck-extract-plist'
		sourcefile_path: '/fixtures/Casks/livecheck/livecheck-extract-plist.rb'
		url: cask_core.new_cask_url(artifact_url, {}) or { panic(err) }
		all_versions: {
			'com.caffeine': extract_plist_spec_bundle('1.2.3')
		}
	}
}

fn extract_plist_spec_match_data_equal(left extract_plist_core.ExtractPlistMatchData,
	right extract_plist_core.ExtractPlistMatchData) bool {
	left_url := left.url or { '' }
	right_url := right.url or { '' }
	return left.matches == right.matches && left.regex == right.regex && left_url == right_url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content
}

fn extract_plist_spec_expected(url ?string, cached bool, has_cached bool, content string,
	has_content bool, matches map[string]string) extract_plist_core.ExtractPlistMatchData {
	return extract_plist_core.ExtractPlistMatchData{
		matches: matches
		url: url
		cached: cached
		has_cached: has_cached
		content: content
		has_content: has_content
	}
}

// Ruby subject `subject(:extract_plist) { described_class }` at line 8.
pub fn ruby_extract_plist_spec_l8_d1_extract_plist() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::ExtractPlist')
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 10.
pub fn ruby_extract_plist_spec_l10_d2_http_url() string {
	return 'https://brew.sh/blog/'
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 11.
pub fn ruby_extract_plist_spec_l11_d3_non_http_url() string {
	return 'ftp://brew.sh/'
}

// Ruby let `let(:items) do` at line 12.
pub fn ruby_extract_plist_spec_l12_d4_items() extract_plist_core.ExtractPlistItems {
	return extract_plist_spec_items()
}

// Ruby let `let(:multipart_items) do` at line 22.
pub fn ruby_extract_plist_spec_l22_d5_multipart_items() extract_plist_core.ExtractPlistItems {
	return extract_plist_spec_multipart_items()
}

// Ruby let `let(:multipart_regex) { /^v?(\d+(?:\.\d+)+)(?:[._-](\d+))?(?:[._-]([0-9a-f]+))?$/i }` at line 32.
pub fn ruby_extract_plist_spec_l32_d6_multipart_regex() extract_plist_core.XmlRegex {
	return extract_plist_core.XmlRegex{
		pattern: r'^v?(\d+(?:\.\d+)+)(?:[._-](\d+))?(?:[._-]([0-9a-f]+))?$'
		case_insensitive: true
	}
}

// Ruby let `let(:versions) { ["1.2", "1.2.3"] }` at line 33.
pub fn ruby_extract_plist_spec_l33_d7_versions() []string {
	return ['1.2', '1.2.3']
}

// Ruby let `let(:multipart_versions) { ["1.2.3,45", "1.2.3,45,abcdef"] }` at line 34.
pub fn ruby_extract_plist_spec_l34_d8_multipart_versions() []string {
	return ['1.2.3,45', '1.2.3,45,abcdef']
}

// Ruby it `it "returns a hash containing non-nil values" do` at line 38.
pub fn ruby_extract_plist_spec_l38_d9_returns() bool {
	first := extract_plist_core.extract_plist_item_to_value(extract_plist_spec_items()['first'])
	empty := extract_plist_core.extract_plist_item_to_value(extract_plist_core.ExtractPlistItem{})
	bundle := first.map_data['bundle_version'] or { return false }
	return (bundle.map_data['version'] or { return false }).as_string() == '1.2' && empty.map_data.len == 0
}

// Ruby it `it "returns true for an HTTP URL" do` at line 48.
pub fn ruby_extract_plist_spec_l48_d10_returns() bool {
	return extract_plist_core.extract_plist_matches(ruby_extract_plist_spec_l10_d2_http_url())
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 52.
pub fn ruby_extract_plist_spec_l52_d11_returns() bool {
	return !extract_plist_core.extract_plist_matches(ruby_extract_plist_spec_l11_d3_non_http_url())
}

// Ruby it `it "returns an empty array if Items hash is empty" do` at line 58.
pub fn ruby_extract_plist_spec_l58_d12_returns() bool {
	versions := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{}) or {
		return false
	}
	return versions.len == 0
}

// Ruby it `it "returns an array of version strings when given Items" do` at line 62.
pub fn ruby_extract_plist_spec_l62_d13_returns() bool {
	versions := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_items()
	}) or { return false }
	return versions == ruby_extract_plist_spec_l33_d7_versions()
}

// Ruby it `it "returns an array of version strings when given Items and a block" do` at line 66.
pub fn ruby_extract_plist_spec_l66_d14_returns() bool {
	one := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_items()
		has_block: true
		block: extract_plist_spec_string_block
	}) or { return false }
	all := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_items()
		has_block: true
		block: extract_plist_spec_array_block
	}) or { return false }
	return one == ['1.2'] && all == ruby_extract_plist_spec_l33_d7_versions()
}

// Ruby it `it "returns an array of version strings when given `Item`s, a regex and a block" do` at line 84.
pub fn ruby_extract_plist_spec_l84_d15_returns() bool {
	provided_regex := ruby_extract_plist_spec_l32_d6_multipart_regex()
	one := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_multipart_items()
		regex: provided_regex
		has_block: true
		block: extract_plist_spec_multipart_string_block
	}) or { return false }
	all := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_multipart_items()
		regex: provided_regex
		has_block: true
		block: extract_plist_spec_multipart_array_block
	}) or { return false }
	return one == ['1.2.3,45'] && all == ruby_extract_plist_spec_l34_d8_multipart_versions()
}

// Ruby it `it "allows a nil return from a block" do` at line 108.
pub fn ruby_extract_plist_spec_l108_d16_allows() bool {
	versions := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_items()
		has_block: true
		block: extract_plist_spec_nil_block
	}) or { return false }
	return versions.len == 0
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 112.
pub fn ruby_extract_plist_spec_l112_d17_errors() bool {
	if _ := extract_plist_core.extract_plist_versions_from_content(extract_plist_core.ExtractPlistVersionsRequest{
		items: extract_plist_spec_items()
		has_block: true
		block: extract_plist_spec_invalid_block
	}) {
		return false
	} else {
		return err.msg() == 'Return value of a strategy block must be a string or array of strings.'
	}
}

// Ruby it `it "returns a cask using the url and supported options from the `livecheck` block" do` at line 119.
pub fn ruby_extract_plist_spec_l119_d18_returns() bool {
	url := 'https://example.com/livecheck.zip'
	options := {
		'cookies':    ruby.map_value({
			'key': ruby.string_value('value')
		})
		'header':     ruby.string_value('Origin: https://example.com')
		'referer':    ruby.string_value('https://example.com/referer')
		'user_agent': ruby.object_value('Symbol', 'browser')
	}
	returned := extract_plist_core.extract_plist_cask_with_url(extract_plist_spec_cask('https://example.com/artifact.zip'), url, options) or { return false }
	cookies := (returned.url.options['cookies'] or { return false }).map_data.clone()
	header_values := (returned.url.options['header'] or { return false }).as_array() or {
		return false
	}
	headers := header_values.map(it.as_string())
	return returned.url.uri == url && (cookies['key'] or { return false }).as_string() == 'value' && headers == [
		'Origin: https://example.com',
	] && (returned.url.options['referer'] or { return false }).as_string() == 'https://example.com/referer' && (returned.url.options['user_agent'] or { return false }).as_string() == 'browser'
}

// Ruby it `it "errors if the `livecheck` block uses options not supported by `Cask::URL`" do` at line 143.
pub fn ruby_extract_plist_spec_l143_d19_errors() bool {
	cask := extract_plist_spec_cask('https://example.com/artifact.zip')
	if _ := extract_plist_core.extract_plist_cask_with_url(cask, 'https://example.com/livecheck.zip', {
		'post_form':  ruby.map_value({
			'key': ruby.string_value('value')
		})
		'user_agent': ruby.object_value('Symbol', 'browser')
	}) {
		return false
	} else {
		if err.msg() != 'Cask `url` does not support `post_form` option from `livecheck` block' {
			return false
		}
	}
	if _ := extract_plist_core.extract_plist_cask_with_url(cask, 'https://example.com/livecheck.zip', {
		'homebrew_curl': ruby.bool_value(true)
		'post_form':     ruby.map_value({
			'key': ruby.string_value('value')
		})
	}) {
		return false
	} else {
		return err.msg() == 'Cask `url` does not support `homebrew_curl`, `post_form` options from `livecheck` block'
	}
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("livecheck/livecheck-extract-plist")) }` at line 171.
pub fn ruby_extract_plist_spec_l171_d20_cask() extract_plist_core.ExtractPlistCask {
	return extract_plist_spec_cask('file:///fixtures/cask/caffeine-with-plist.zip')
}

// Ruby let `let(:content) { '{"com.caffeine":{"bundle_version":{"version":"1.2.3"}}}' }` at line 172.
pub fn ruby_extract_plist_spec_l172_d21_content() string {
	return '{"com.caffeine":{"bundle_version":{"version":"1.2.3"}}}'
}

// Ruby let `let(:match_data) do` at line 173.
pub fn ruby_extract_plist_spec_l173_d22_match_data() ruby.Value {
	base_matches := {
		'1.2.3': '1.2.3'
	}
	return ruby.map_value({
		'uncached':       extract_plist_core.extract_plist_match_data_to_value(extract_plist_spec_expected(none, false, false, ruby_extract_plist_spec_l172_d21_content(), true, base_matches))
		'cached':         extract_plist_core.extract_plist_match_data_to_value(extract_plist_spec_expected(none, true, true, '', false, base_matches))
		'cached_default': extract_plist_core.extract_plist_match_data_to_value(extract_plist_spec_expected(none, true, true, '', false, {}))
	})
}

// Ruby it `it "raises an error if a regex is provided with no block" do` at line 187.
pub fn ruby_extract_plist_spec_l187_d23_raises() bool {
	if _ := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: ruby_extract_plist_spec_l171_d20_cask()
		regex: ruby_extract_plist_spec_l32_d6_multipart_regex()
	}) {
		return false
	} else {
		return err.msg() == 'ExtractPlist only supports a regex when using a `strategy` block'
	}
}

// Ruby it `it "finds versions using provided content" do` at line 193.
pub fn ruby_extract_plist_spec_l193_d24_finds() bool {
	cask := ruby_extract_plist_spec_l171_d20_cask()
	content := ruby_extract_plist_spec_l172_d21_content()
	expected := extract_plist_spec_expected(none, true, true, '', false, {
		'1.2.3': '1.2.3'
	})
	direct := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: cask
		content: content
	}) or { return false }
	blocked := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: cask
		content: content
		has_block: true
		block: extract_plist_spec_caffeine_block
	}) or { return false }
	return extract_plist_spec_match_data_equal(direct, expected) && extract_plist_spec_match_data_equal(blocked, expected)
}

// Ruby it `it "returns default match_data when provided content is blank" do` at line 204.
pub fn ruby_extract_plist_spec_l204_d25_returns() bool {
	actual := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: ruby_extract_plist_spec_l171_d20_cask()
		content: '{}'
	}) or { return false }
	return extract_plist_spec_match_data_equal(actual, extract_plist_spec_expected(none, true, true, '', false, {}))
}

// Ruby it `it "checks the cask using the livecheck URL string", :needs_macos do` at line 209.
pub fn ruby_extract_plist_spec_l209_d26_checks() bool {
	cask := extract_plist_spec_cask('file:///fixtures/cask/caffeine-suite.zip')
	livecheck_url := 'file:///fixtures/cask/caffeine-with-plist.zip'
	actual := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: cask
		url: livecheck_url
	}) or { return false }
	expected := extract_plist_spec_expected(livecheck_url, false, false, ruby_extract_plist_spec_l172_d21_content(), true, {
		'1.2.3': '1.2.3'
	})
	return extract_plist_spec_match_data_equal(actual, expected)
}

// Ruby it `it "checks the original cask if the provided URL is the same as the artifact URL", :needs_macos do` at line 218.
pub fn ruby_extract_plist_spec_l218_d27_checks() bool {
	cask := ruby_extract_plist_spec_l171_d20_cask()
	actual := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: cask
		url: cask.url.uri
	}) or { return false }
	expected := extract_plist_spec_expected(cask.url.uri, false, false, ruby_extract_plist_spec_l172_d21_content(), true, {
		'1.2.3': '1.2.3'
	})
	return extract_plist_spec_match_data_equal(actual, expected)
}

// Ruby it `it "checks the original cask if a URL is not provided", :needs_macos do` at line 225.
pub fn ruby_extract_plist_spec_l225_d28_checks() bool {
	actual := extract_plist_core.extract_plist_find_versions(extract_plist_core.ExtractPlistFindVersionsRequest{
		cask: ruby_extract_plist_spec_l171_d20_cask()
	}) or { return false }
	expected := extract_plist_spec_expected(none, false, false, ruby_extract_plist_spec_l172_d21_content(), true, {
		'1.2.3': '1.2.3'
	})
	return extract_plist_spec_match_data_equal(actual, expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5: require "bundle_version"
// 6:
// 7: RSpec.describe Homebrew::Livecheck::Strategy::ExtractPlist do
// 8:   subject(:extract_plist) { described_class }
// 9:
// 10:   let(:http_url) { "https://brew.sh/blog/" }
// 11:   let(:non_http_url) { "ftp://brew.sh/" }
// 12:   let(:items) do
// 13:     {
// 14:       "first"  => Homebrew::Livecheck::Strategy::ExtractPlist::Item.new(
// 15:         bundle_version: Homebrew::BundleVersion.new(nil, "1.2"),
// 16:       ),
// 17:       "second" => Homebrew::Livecheck::Strategy::ExtractPlist::Item.new(
// 18:         bundle_version: Homebrew::BundleVersion.new(nil, "1.2.3"),
// 19:       ),
// 20:     }
// 21:   end
// 22:   let(:multipart_items) do
// 23:     {
// 24:       "first"  => Homebrew::Livecheck::Strategy::ExtractPlist::Item.new(
// 25:         bundle_version: Homebrew::BundleVersion.new(nil, "1.2.3-45"),
// 26:       ),
// 27:       "second" => Homebrew::Livecheck::Strategy::ExtractPlist::Item.new(
// 28:         bundle_version: Homebrew::BundleVersion.new(nil, "1.2.3-45-abcdef"),
// 29:       ),
// 30:     }
// 31:   end
// 32:   let(:multipart_regex) { /^v?(\d+(?:\.\d+)+)(?:[._-](\d+))?(?:[._-]([0-9a-f]+))?$/i }
// 33:   let(:versions) { ["1.2", "1.2.3"] }
// 34:   let(:multipart_versions) { ["1.2.3,45", "1.2.3,45,abcdef"] }
// 35:
// 36:   describe "Item" do
// 37:     describe "#to_h" do
// 38:       it "returns a hash containing non-nil values" do
// 39:         expect(items["first"].to_h).to eq({
// 40:           bundle_version: { version: "1.2" },
// 41:         })
// 42:         expect(Homebrew::Livecheck::Strategy::ExtractPlist::Item.new.to_h).to eq({})
// 43:       end
// 44:     end
// 45:   end
// 46:
// 47:   describe "::match?" do
// 48:     it "returns true for an HTTP URL" do
// 49:       expect(extract_plist.match?(http_url)).to be true
// 50:     end
// 51:
// 52:     it "returns false for a non-HTTP URL" do
// 53:       expect(extract_plist.match?(non_http_url)).to be false
// 54:     end
// 55:   end
// 56:
// 57:   describe "::versions_from_content" do
// 58:     it "returns an empty array if Items hash is empty" do
// 59:       expect(extract_plist.versions_from_content({})).to eq([])
// 60:     end
// 61:
// 62:     it "returns an array of version strings when given Items" do
// 63:       expect(extract_plist.versions_from_content(items)).to eq(versions)
// 64:     end
// 65:
// 66:     it "returns an array of version strings when given Items and a block" do
// 67:       # Returning a string from block
// 68:       expect(
// 69:         extract_plist.versions_from_content(items) do |items|
// 70:           items["first"].version
// 71:         end,
// 72:       ).to eq(["1.2"])
// 73:
// 74:       # Returning an array of strings from block
// 75:       expect(
// 76:         extract_plist.versions_from_content(items) do |items|
// 77:           items.map do |_key, item|
// 78:             item.bundle_version.nice_version
// 79:           end
// 80:         end,
// 81:       ).to eq(versions)
// 82:     end
// 83:
// 84:     it "returns an array of version strings when given `Item`s, a regex and a block" do
// 85:       # Returning a string from block
// 86:       expect(
// 87:         extract_plist.versions_from_content(multipart_items, multipart_regex) do |items, regex|
// 88:           match = items["first"].version.match(regex)
// 89:           next if match.blank?
// 90:
// 91:           match[1..].compact.join(",")
// 92:         end,
// 93:       ).to eq(["1.2.3,45"])
// 94:
// 95:       # Returning an array of strings from block
// 96:       expect(
// 97:         extract_plist.versions_from_content(multipart_items, multipart_regex) do |items, regex|
// 98:           items.map do |_key, item|
// 99:             match = item.version.match(regex)
// 100:             next if match.blank?
// 101:
// 102:             match[1..].compact.join(",")
// 103:           end
// 104:         end,
// 105:       ).to eq(multipart_versions)
// 106:     end
// 107:
// 108:     it "allows a nil return from a block" do
// 109:       expect(extract_plist.versions_from_content(items) { next }).to eq([])
// 110:     end
// 111:
// 112:     it "errors on an invalid return type from a block" do
// 113:       expect { extract_plist.versions_from_content(items) { 123 } }
// 114:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 115:     end
// 116:   end
// 117:
// 118:   describe "::cask_with_url" do
// 119:     it "returns a cask using the url and supported options from the `livecheck` block" do
// 120:       cask = Cask::CaskLoader.load(cask_path("livecheck/livecheck-extract-plist-with-url"))
// 121:       cask.livecheck.url(
// 122:         cask.livecheck.url,
// 123:         cookies:    { "key" => "value" },
// 124:         header:     "Origin: https://example.com",
// 125:         referer:    "https://example.com/referer",
// 126:         user_agent: :browser,
// 127:       )
// 128:       livecheck_url = cask.livecheck.url
// 129:       url_options = cask.livecheck.options.url_options
// 130:
// 131:       returned_cask = extract_plist.cask_with_url(cask, livecheck_url, url_options)
// 132:       returned_cask_url = returned_cask.url
// 133:
// 134:       expect(returned_cask_url.to_s).to eq(livecheck_url)
// 135:       # NOTE: `Cask::URL` converts symbol keys to strings
// 136:       expect(returned_cask_url.cookies).to eq(url_options[:cookies].transform_keys(&:to_s))
// 137:       # NOTE: `Cask::URL` creates an array from a header string argument
// 138:       expect(returned_cask_url.header).to eq([url_options[:header]])
// 139:       expect(returned_cask_url.referer).to eq(url_options[:referer])
// 140:       expect(returned_cask_url.user_agent).to eq(url_options[:user_agent])
// 141:     end
// 142:
// 143:     it "errors if the `livecheck` block uses options not supported by `Cask::URL`" do
// 144:       cask = Cask::CaskLoader.load(cask_path("livecheck/livecheck-extract-plist-with-url"))
// 145:       livecheck_url = cask.livecheck.url
// 146:       cask.livecheck.url(
// 147:         livecheck_url,
// 148:         post_form:  { key: "value" },
// 149:         user_agent: :browser,
// 150:       )
// 151:       options = cask.livecheck.options
// 152:
// 153:       expect do
// 154:         extract_plist.cask_with_url(cask, livecheck_url, options.url_options)
// 155:       end.to raise_error(
// 156:         ArgumentError,
// 157:         "Cask `url` does not support `post_form` option from `livecheck` block",
// 158:       )
// 159:
// 160:       options.homebrew_curl = true
// 161:       expect do
// 162:         extract_plist.cask_with_url(cask, livecheck_url, options.url_options)
// 163:       end.to raise_error(
// 164:         ArgumentError,
// 165:         "Cask `url` does not support `homebrew_curl`, `post_form` options from `livecheck` block",
// 166:       )
// 167:     end
// 168:   end
// 169:
// 170:   describe "::find_versions" do
// 171:     let(:cask) { Cask::CaskLoader.load(cask_path("livecheck/livecheck-extract-plist")) }
// 172:     let(:content) { '{"com.caffeine":{"bundle_version":{"version":"1.2.3"}}}' }
// 173:     let(:match_data) do
// 174:       base = {
// 175:         matches: { "1.2.3" => Version.new("1.2.3") },
// 176:         regex:   nil,
// 177:         url:     nil,
// 178:       }
// 179:
// 180:       {
// 181:         uncached:       base.merge({ content: }),
// 182:         cached:         base.merge({ cached: true }),
// 183:         cached_default: base.merge({ matches: {}, cached: true }),
// 184:       }
// 185:     end
// 186:
// 187:     it "raises an error if a regex is provided with no block" do
// 188:       expect do
// 189:         extract_plist.find_versions(cask:, regex: multipart_regex)
// 190:       end.to raise_error(ArgumentError, "ExtractPlist only supports a regex when using a `strategy` block")
// 191:     end
// 192:
// 193:     it "finds versions using provided content" do
// 194:       expect(extract_plist.find_versions(cask:, content:))
// 195:         .to eq(match_data[:cached])
// 196:
// 197:       # This `strategy` block is unnecessary but it's intended to test using a
// 198:       # regex in a `strategy` block.
// 199:       expect(extract_plist.find_versions(cask:, content:) do |items|
// 200:         items["com.caffeine"]&.version
// 201:       end).to eq(match_data[:cached])
// 202:     end
// 203:
// 204:     it "returns default match_data when provided content is blank" do
// 205:       expect(extract_plist.find_versions(cask:, content: "{}"))
// 206:         .to eq(match_data[:cached_default])
// 207:     end
// 208:
// 209:     it "checks the cask using the livecheck URL string", :needs_macos do
// 210:       cask_with_url = Cask::CaskLoader.load(cask_path("livecheck/livecheck-extract-plist-with-url"))
// 211:       livecheck_url = cask_with_url.livecheck.url
// 212:
// 213:       expect(
// 214:         extract_plist.find_versions(cask: cask_with_url, url: livecheck_url),
// 215:       ).to eq(match_data[:uncached].merge({ url: livecheck_url }))
// 216:     end
// 217:
// 218:     it "checks the original cask if the provided URL is the same as the artifact URL", :needs_macos do
// 219:       cask_url = cask.url.to_s
// 220:
// 221:       expect(extract_plist.find_versions(cask:, url: cask_url))
// 222:         .to eq(match_data[:uncached].merge({ url: cask_url }))
// 223:     end
// 224:
// 225:     it "checks the original cask if a URL is not provided", :needs_macos do
// 226:       expect(extract_plist.find_versions(cask:)).to eq(match_data[:uncached])
// 227:     end
// 228:   end
// 229: end
