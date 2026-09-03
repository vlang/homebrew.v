module strategy

import homebrew
import homebrew.livecheck as strategy_core
import homebrew.livecheck.strategy as sparkle_core
import homebrew.utils
import time

// Translated from Homebrew/brew `test/livecheck/strategy/sparkle_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SparkleItemFixture {
pub:
	title                  string
	link                   string
	release_notes_link     string
	pub_date               string
	os                     string
	url                    string
	short_version          string
	version                string
	minimum_system_version string
}

fn sparkle_spec_optional(value string) ?string {
	return if value == '' { none } else { value }
}

fn sparkle_spec_fixture_item(fixture SparkleItemFixture) sparkle_core.SparkleItem {
	minimum := homebrew.new_macos_version(fixture.minimum_system_version) or {
		homebrew.null_macos_version()
	}
	bundle := homebrew.new_bundle_version(sparkle_spec_optional(fixture.short_version), sparkle_spec_optional(fixture.version)) or { homebrew.BundleVersion{} }
	parsed := time.parse_rfc2822(fixture.pub_date) or { time.unix(0) }
	return sparkle_core.SparkleItem{
		title: sparkle_spec_optional(fixture.title)
		link: sparkle_spec_optional(fixture.link)
		release_notes_link: sparkle_spec_optional(fixture.release_notes_link)
		pub_date: parsed.unix()
		os: sparkle_spec_optional(fixture.os)
		url: sparkle_spec_optional(if fixture.url != '' { fixture.url } else { fixture.link })
		bundle_version: bundle
		minimum_system_version: minimum
	}
}

fn sparkle_spec_option_text(value ?string) string {
	return value or { '' }
}

fn sparkle_spec_item_equal(left sparkle_core.SparkleItem,
	right sparkle_core.SparkleItem) bool {
	left_bundle := if bundle := left.bundle_version { bundle.to_h() } else { map[string]string{} }
	right_bundle := if bundle := right.bundle_version { bundle.to_h() } else { map[string]string{} }
	left_macos := if version := left.minimum_system_version { version.str() } else { '' }
	right_macos := if version := right.minimum_system_version { version.str() } else { '' }
	return sparkle_spec_option_text(left.title) == sparkle_spec_option_text(right.title) && sparkle_spec_option_text(left.link) == sparkle_spec_option_text(right.link) && sparkle_spec_option_text(left.channel) == sparkle_spec_option_text(right.channel) && sparkle_spec_option_text(left.release_notes_link) == sparkle_spec_option_text(right.release_notes_link) && left.pub_date == right.pub_date && sparkle_spec_option_text(left.os) == sparkle_spec_option_text(right.os) && sparkle_spec_option_text(left.url) == sparkle_spec_option_text(right.url) && left_bundle == right_bundle && left_macos == right_macos
}

fn sparkle_spec_items_equal(left []sparkle_core.SparkleItem,
	right []sparkle_core.SparkleItem) bool {
	if left.len != right.len {
		return false
	}
	for index, item in left {
		if !sparkle_spec_item_equal(item, right[index]) {
			return false
		}
	}
	return true
}

fn sparkle_spec_item_xml(fixture SparkleItemFixture, enclosure bool) string {
	mut lines := ['<item>', '<title>${fixture.title}</title>']
	if fixture.link != '' {
		lines << '<link>${fixture.link}</link>'
	}
	lines << '<sparkle:minimumSystemVersion>${fixture.minimum_system_version}</sparkle:minimumSystemVersion>'
	lines << '<sparkle:releaseNotesLink>${fixture.release_notes_link}</sparkle:releaseNotesLink>'
	lines << '<pubDate>${fixture.pub_date}</pubDate>'
	if enclosure {
		os_attribute := if fixture.os == '' { '' } else { ' os="${fixture.os}"' }
		lines << '<enclosure${os_attribute} url="${fixture.url}" sparkle:shortVersionString="${fixture.short_version}" sparkle:version="${fixture.version}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF" />'
	} else {
		lines << '<sparkle:version>${fixture.version}</sparkle:version>'
		lines << '<sparkle:shortVersionString>${fixture.short_version}</sparkle:shortVersionString>'
	}
	lines << '</item>'
	return lines.join('\n')
}

fn sparkle_spec_string(value string) strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{ kind: .string_value, value: value }
}

fn sparkle_spec_strings(values []string) strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{
		kind: .array
		values: values.map(strategy_core.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn sparkle_spec_nice(item sparkle_core.SparkleItem) string {
	return sparkle_core.ruby_sparkle_l83_d4_nice_version(item) or { '' }
}

fn sparkle_spec_title_capture(title string) ?string {
	marker := 'version '
	index := title.to_lower().index(marker) or { return none }
	mut value := title[index + marker.len..].trim_space()
	if value.starts_with('v') || value.starts_with('V') {
		value = value[1..]
	}
	if value == '' || value.split('.').any(it == '' || !it.bytes().all(it.is_digit())) {
		return none
	}
	return value
}

fn sparkle_spec_sub_item(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return sparkle_spec_string(sparkle_spec_nice(items[0]).replace_once('1', '0'))
}

fn sparkle_spec_sub_items(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return sparkle_spec_strings(items.map(sparkle_spec_nice(it).replace_once('1', '0')))
}

fn sparkle_spec_stable_channel(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	for item in items {
		if item.channel == none {
			return sparkle_spec_string(sparkle_spec_nice(item))
		}
	}
	return strategy_core.StrategyBlockValue{ kind: .nil_value }
}

fn sparkle_spec_title_item(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	title := items[0].title or { return strategy_core.StrategyBlockValue{ kind: .nil_value } }
	return sparkle_spec_string(sparkle_spec_title_capture(title) or { '' })
}

fn sparkle_spec_title_items(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	mut versions := []string{}
	for item in items {
		title := item.title or { continue }
		versions << sparkle_spec_title_capture(title) or { continue }
	}
	return sparkle_spec_strings(versions)
}

fn sparkle_spec_title_array(items []sparkle_core.SparkleItem,
	regex ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return sparkle_spec_title_items(items, regex)
}

fn sparkle_spec_title_combined(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	item := items[0]
	title := item.title or { return strategy_core.StrategyBlockValue{ kind: .nil_value } }
	short := sparkle_spec_title_capture(title) or {
		return strategy_core.StrategyBlockValue{ kind: .nil_value }
	}
	version := sparkle_core.ruby_sparkle_l71_d2_version(item) or { '' }
	return sparkle_spec_string('${short},${version}')
}

fn sparkle_spec_short_version(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return sparkle_spec_string(sparkle_core.ruby_sparkle_l77_d3_short_version(items[0]) or { '' })
}

fn sparkle_spec_nil(_ []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{ kind: .nil_value }
}

fn sparkle_spec_invalid(_ []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{ kind: .invalid }
}

fn sparkle_spec_url_capture(items []sparkle_core.SparkleItem,
	_ ?sparkle_core.XmlRegex) !strategy_core.StrategyBlockValue {
	url := items[0].url or { return strategy_core.StrategyBlockValue{ kind: .nil_value } }
	marker := '/example-'
	start := url.index(marker) or { return strategy_core.StrategyBlockValue{ kind: .nil_value } }
	rest := url[start + marker.len..]
	version := rest.all_before('.tar')
	return sparkle_spec_string('${version},${version.replace('.', '')}')
}

fn sparkle_spec_fetched(_ strategy_core.StrategyCurlRequest) !utils.CurlCommandResult {
	content := ruby_sparkle_spec_l68_d6_xml()['appcast'] or { '' }
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/xml\r\n\r\n${content}'
		exit_status: 0
	}
}

fn sparkle_spec_unused_fetcher(_ strategy_core.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached content unexpectedly fetched')
}

fn sparkle_spec_match_equal(left sparkle_core.SparkleMatchData,
	right sparkle_core.SparkleMatchData) bool {
	left_regex := if value := left.regex { value.pattern } else { '' }
	right_regex := if value := right.regex { value.pattern } else { '' }
	return left.matches == right.matches && left_regex == right_regex && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:sparkle) { described_class }` at line 8.
pub fn ruby_sparkle_spec_l8_d1_sparkle() string {
	return 'Sparkle'
}

// Ruby let `let(:appcast_url) { "https://www.example.com/example/appcast.xml" }` at line 10.
pub fn ruby_sparkle_spec_l10_d2_appcast_url() string {
	return 'https://www.example.com/example/appcast.xml'
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 11.
pub fn ruby_sparkle_spec_l11_d3_non_http_url() string {
	return 'ftp://brew.sh/'
}

// Ruby let `let(:title_regex) { /Version\s+v?(\d+(?:\.\d+)+)\s*$/i }` at line 12.
pub fn ruby_sparkle_spec_l12_d4_title_regex() sparkle_core.XmlRegex {
	return sparkle_core.XmlRegex{
		pattern: r'Version\s+v?(\d+(?:\.\d+)+)\s*$'
		case_insensitive: true
	}
}

// Ruby let `let(:item_hashes) do` at line 15.
pub fn ruby_sparkle_spec_l15_d5_item_hashes() map[string]SparkleItemFixture {
	return {
		'v124': SparkleItemFixture{ title: 'Version 1.2.4', release_notes_link: 'https://www.example.com/example/1.2.4.html', pub_date: 'Fri, 02 Jan 2021 01:23:45 +0000', url: 'https://www.example.com/example/example-1.2.4.tar.gz', short_version: '1.2.4', version: '124', minimum_system_version: '10.10' }
		'v123': SparkleItemFixture{ title: 'Version 1.2.3', release_notes_link: 'https://www.example.com/example/1.2.3.html', pub_date: 'Fri, 01 Jan 2021 01:23:45 +0000', url: 'https://www.example.com/example/example-1.2.3.tar.gz', short_version: '1.2.3', version: '123', minimum_system_version: '10.10' }
		'v122': SparkleItemFixture{ title: 'Version 1.2.2', release_notes_link: 'https://www.example.com/example/1.2.2.html', pub_date: 'Not a parseable date string', link: 'https://www.example.com/example/example-1.2.2.tar.gz', short_version: '1.2.2', version: '122', minimum_system_version: '10.10' }
		'v121': SparkleItemFixture{ title: 'Version 1.2.1', release_notes_link: 'https://www.example.com/example/1.2.1.html', pub_date: 'Thu, 31 Dec 2020 01:23:45 +0000', os: 'osx', url: 'https://www.example.com/example/example-1.2.1.tar.gz', short_version: '1.2.1', version: '121', minimum_system_version: '10.10' }
		'v120': SparkleItemFixture{ title: 'Version 1.2.0', release_notes_link: 'https://www.example.com/example/1.2.0.html', pub_date: 'Wed, 30 Dec 2020 01:23:45 +0000', os: 'macos', url: 'https://www.example.com/example/example-1.2.0.tar.gz', short_version: '1.2.0', version: '120', minimum_system_version: '10.10' }
	}
}

// Ruby let `let(:xml) do` at line 68.
pub fn ruby_sparkle_spec_l68_d6_xml() map[string]string {
	fixtures := ruby_sparkle_spec_l15_d5_item_hashes()
	v123 := fixtures['v123'] or { SparkleItemFixture{} }
	v122 := fixtures['v122'] or { SparkleItemFixture{} }
	v121 := fixtures['v121'] or { SparkleItemFixture{} }
	v120 := fixtures['v120'] or { SparkleItemFixture{} }
	v123_xml := sparkle_spec_item_xml(v123, true)
	appcast := ruby_sparkle_spec_l280_d10_create_appcast_xml([v123_xml,
		sparkle_spec_item_xml(v122, false), sparkle_spec_item_xml(v121, true),
		sparkle_spec_item_xml(v120, true)].join('\n'))
	omitted_os := v123_xml.replace('<enclosure ', '<enclosure os="not-osx-or-macos" ')
	omitted_minimum := v123_xml.replace('>10.10</sparkle:minimumSystemVersion>', '>100</sparkle:minimumSystemVersion>')
	bad_macos := appcast.replace_once('>10.10</sparkle:minimumSystemVersion>', '>a1b2c3d</sparkle:minimumSystemVersion>')
	beta := appcast.replace_once('<title>${v123.title}</title>', '<title>${v123.title}</title>\n<sparkle:channel>beta</sparkle:channel>')
	no_versions := ruby_sparkle_spec_l280_d10_create_appcast_xml('<item>\n<title>Version</title>\n<sparkle:minimumSystemVersion>${v123.minimum_system_version}</sparkle:minimumSystemVersion>\n<sparkle:releaseNotesLink>${v123.release_notes_link}</sparkle:releaseNotesLink>\n<pubDate>${v123.pub_date}</pubDate>\n<enclosure url="${v123.url}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF" />\n</item>')
	return {
		'appcast':             appcast
		'omitted_items':       ruby_sparkle_spec_l280_d10_create_appcast_xml('${omitted_os}\n${omitted_minimum}\n<item>\n</item>')
		'bad_macos_version':   bad_macos
		'beta_channel_item':   beta
		'no_versions_item':    no_versions
		'no_items':            ruby_sparkle_spec_l280_d10_create_appcast_xml('')
		'undefined_namespace': appcast.replace(' xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"', '')
	}
}

// Ruby let `let(:items) do` at line 173.
pub fn ruby_sparkle_spec_l173_d7_items() map[string]sparkle_core.SparkleItem {
	fixtures := ruby_sparkle_spec_l15_d5_item_hashes()
	mut items := map[string]sparkle_core.SparkleItem{}
	for key, fixture in fixtures {
		items[key] = sparkle_spec_fixture_item(fixture)
	}
	return items
}

// Ruby let `let(:item_arrays) do` at line 237.
pub fn ruby_sparkle_spec_l237_d8_item_arrays() map[string][]sparkle_core.SparkleItem {
	items := ruby_sparkle_spec_l173_d7_items()
	v123 := items['v123'] or { sparkle_core.SparkleItem{} }
	v122 := items['v122'] or { sparkle_core.SparkleItem{} }
	v121 := items['v121'] or { sparkle_core.SparkleItem{} }
	v120 := items['v120'] or { sparkle_core.SparkleItem{} }
	mut bad_macos := v123
	bad_macos.minimum_system_version = none
	mut beta := v123
	beta.channel = 'beta'
	mut no_versions := v123
	no_versions.title = 'Version'
	no_versions.bundle_version = none
	return {
		'appcast':           [v123, v122, v121, v120]
		'appcast_sorted':    [v123, v121, v120, v122]
		'bad_macos_version': [bad_macos, v122, v121, v120]
		'beta_channel_item': [beta, v122, v121, v120]
		'no_versions_item':  [no_versions]
	}
}

// Ruby let `let(:matches) { ["1.2.3,123"] }` at line 278.
pub fn ruby_sparkle_spec_l278_d9_matches() []string {
	return ['1.2.3,123']
}

// Ruby method `create_appcast_xml(items_str = "")` at line 280.
pub fn ruby_sparkle_spec_l280_d10_create_appcast_xml(items_str string) string {
	return '<?xml version="1.0" encoding="utf-8"?>\n<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">\n<channel>\n<title>Example Changelog</title>\n<link>${ruby_sparkle_spec_l10_d2_appcast_url()}</link>\n<description>Most recent changes with links to updates.</description>\n<language>en</language>\n${items_str}\n</channel>\n</rss>\n'
}

// Ruby it `it "returns true for an HTTP URL" do` at line 296.
pub fn ruby_sparkle_spec_l296_d11_returns() bool {
	return sparkle_core.ruby_sparkle_l33_d1_self_match(ruby_sparkle_spec_l10_d2_appcast_url())
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 300.
pub fn ruby_sparkle_spec_l300_d12_returns() bool {
	return !sparkle_core.ruby_sparkle_l33_d1_self_match(ruby_sparkle_spec_l11_d3_non_http_url())
}

// Ruby let `let(:items_from_appcast) { sparkle.items_from_content(xml[:appcast]) }` at line 306.
pub fn ruby_sparkle_spec_l306_d13_items_from_appcast() ![]sparkle_core.SparkleItem {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	return sparkle_core.ruby_sparkle_l91_d5_self_items_from_content(xml_data['appcast'] or { '' })
}

// Ruby it `it "returns nil if content is blank" do` at line 308.
pub fn ruby_sparkle_spec_l308_d14_returns() bool {
	return (sparkle_core.ruby_sparkle_l91_d5_self_items_from_content('') or { return false }).len == 0
}

// Ruby it `it "returns an array of Items when given XML data" do` at line 312.
pub fn ruby_sparkle_spec_l312_d15_returns() bool {
	actual := ruby_sparkle_spec_l306_d13_items_from_appcast() or { return false }
	arrays := ruby_sparkle_spec_l237_d8_item_arrays()
	if !sparkle_spec_items_equal(actual, arrays['appcast'] or { return false }) {
		return false
	}
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	for key in ['bad_macos_version', 'beta_channel_item', 'no_versions_item'] {
		parsed := sparkle_core.ruby_sparkle_l91_d5_self_items_from_content(xml_data[key] or { return false }) or { return false }
		if !sparkle_spec_items_equal(parsed, arrays[key] or { return false }) {
			return false
		}
	}
	return true
}

// Ruby let `let(:items_non_mac_os) do` at line 327.
pub fn ruby_sparkle_spec_l327_d16_items_non_mac_os() []sparkle_core.SparkleItem {
	items := ruby_sparkle_spec_l173_d7_items()
	arrays := ruby_sparkle_spec_l237_d8_item_arrays()
	mut excluded := items['v124'] or { sparkle_core.SparkleItem{} }
	excluded.os = 'not-osx-or-macos'
	mut values := (arrays['appcast'] or { []sparkle_core.SparkleItem{} }).clone()
	values << excluded
	return values
}

// Ruby let `let(:items_prerelease_minimum_system_version) do` at line 333.
pub fn ruby_sparkle_spec_l333_d17_items_prerelease_minimum_system_version() []sparkle_core.SparkleItem {
	items := ruby_sparkle_spec_l173_d7_items()
	arrays := ruby_sparkle_spec_l237_d8_item_arrays()
	mut excluded := items['v124'] or { sparkle_core.SparkleItem{} }
	minimum := homebrew.new_macos_version('100') or { homebrew.null_macos_version() }
	excluded.minimum_system_version = minimum
	mut values := (arrays['appcast'] or { []sparkle_core.SparkleItem{} }).clone()
	values << excluded
	return values
}

// Ruby it `it "removes items with a non-mac OS" do` at line 339.
pub fn ruby_sparkle_spec_l339_d18_removes() bool {
	actual := sparkle_core.ruby_sparkle_l170_d6_self_filter_items(ruby_sparkle_spec_l327_d16_items_non_mac_os(), '27') or { return false }
	expected := ruby_sparkle_spec_l237_d8_item_arrays()['appcast'] or { return false }
	return sparkle_spec_items_equal(actual, expected)
}

// Ruby it `it "removes items with a prerelease minimumSystemVersion" do` at line 343.
pub fn ruby_sparkle_spec_l343_d19_removes() bool {
	actual := sparkle_core.ruby_sparkle_l170_d6_self_filter_items(ruby_sparkle_spec_l333_d17_items_prerelease_minimum_system_version(), '27') or { return false }
	expected := ruby_sparkle_spec_l237_d8_item_arrays()['appcast'] or { return false }
	return sparkle_spec_items_equal(actual, expected)
}

// Ruby it `it "returns a sorted array of items" do` at line 349.
pub fn ruby_sparkle_spec_l349_d20_returns() bool {
	arrays := ruby_sparkle_spec_l237_d8_item_arrays()
	actual := sparkle_core.ruby_sparkle_l190_d7_self_sort_items(arrays['appcast'] or { return false })
	return sparkle_spec_items_equal(actual, arrays['appcast_sorted'] or { return false })
}

// Ruby let `let(:versions) { [items[:v123].nice_version] }` at line 359.
pub fn ruby_sparkle_spec_l359_d21_versions() []string {
	items := ruby_sparkle_spec_l173_d7_items()
	return [sparkle_spec_nice(items['v123'] or { sparkle_core.SparkleItem{} })]
}

// Ruby let `let(:subbed_items) { item_arrays[:appcast_sorted].map { |item| item.nice_version.sub("1", "0") } }` at line 360.
pub fn ruby_sparkle_spec_l360_d22_subbed_items() []string {
	arrays := ruby_sparkle_spec_l237_d8_item_arrays()
	return (arrays['appcast_sorted'] or { []sparkle_core.SparkleItem{} }).map(sparkle_spec_nice(it).replace_once('1', '0'))
}

// Ruby it `it "returns an array of version strings when given content" do` at line 362.
pub fn ruby_sparkle_spec_l362_d23_returns() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	for key in ['appcast', 'beta_channel_item', 'undefined_namespace'] {
		actual := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
			content: xml_data[key] or { return false }
		}, '27') or { return false }
		if actual != ruby_sparkle_spec_l359_d21_versions() {
			return false
		}
	}
	for key in ['omitted_items', 'no_versions_item'] {
		actual := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
			content: xml_data[key] or { return false }
		}, '27') or { return false }
		if actual.len != 0 {
			return false
		}
	}
	return true
}

// Ruby it `it "returns an empty array if no items are found" do` at line 370.
pub fn ruby_sparkle_spec_l370_d24_returns() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	actual := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: xml_data['no_items'] or { return false }
	}, '27') or { return false }
	return actual.len == 0
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 374.
pub fn ruby_sparkle_spec_l374_d25_returns() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	appcast := xml_data['appcast'] or { return false }
	one := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: appcast
		has_block: true
		block_parameter: .item
		block: sparkle_spec_sub_item
	}, '27') or { return false }
	all := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: appcast
		has_block: true
		block_parameter: .items
		block: sparkle_spec_sub_items
	}, '27') or { return false }
	stable := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: xml_data['beta_channel_item'] or { return false }
		has_block: true
		block_parameter: .items
		block: sparkle_spec_stable_channel
	}, '27') or { return false }
	items := ruby_sparkle_spec_l173_d7_items()
	return one == [ruby_sparkle_spec_l360_d22_subbed_items()[0]] && all == ruby_sparkle_spec_l360_d22_subbed_items() && stable == [
		sparkle_spec_nice(items['v121'] or { return false }),
	]
}

// Ruby it `it "returns an array of version strings when given content, a regex and a block" do` at line 396.
pub fn ruby_sparkle_spec_l396_d26_returns() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	content := xml_data['appcast'] or { return false }
	regex := ruby_sparkle_spec_l12_d4_title_regex()
	mut requests := [
		sparkle_core.SparkleVersionsRequest{ content: content, regex: regex, has_block: true, block_parameter: .item, block: sparkle_spec_title_item },
		sparkle_core.SparkleVersionsRequest{ content: content, regex: regex, has_block: true, block_parameter: .items, block: sparkle_spec_title_combined },
		sparkle_core.SparkleVersionsRequest{ content: content, regex: regex, has_block: true, block_parameter: .item, block: sparkle_spec_title_array },
		sparkle_core.SparkleVersionsRequest{ content: content, has_block: true, block_parameter: .anonymous, block: sparkle_spec_short_version },
		sparkle_core.SparkleVersionsRequest{ content: content, regex: regex, has_block: true, block_parameter: .items, block: sparkle_spec_title_items },
	]
	expected := [
		['1.2.3'],
		['1.2.3,123'],
		['1.2.3'],
		['1.2.3'],
		['1.2.3', '1.2.1', '1.2.0', '1.2.2'],
	]
	for index, request in requests {
		actual := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(request, '27') or { return false }
		if actual != expected[index] {
			return false
		}
	}
	return true
}

// Ruby it `it "allows a nil return from a block" do` at line 433.
pub fn ruby_sparkle_spec_l433_d27_allows() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	actual := sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: xml_data['appcast'] or { return false }
		has_block: true
		block_parameter: .item
		block: sparkle_spec_nil
	}, '27') or { return false }
	return actual.len == 0
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 442.
pub fn ruby_sparkle_spec_l442_d28_errors() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: xml_data['appcast'] or { return false }
		has_block: true
		block_parameter: .item
		block: sparkle_spec_invalid
	}, '27') or {
		return err.msg() == 'Return value of a strategy block must be a string or array of strings.'
	}
	return false
}

// Ruby it `it "errors if the first block argument uses an unhandled name" do` at line 451.
pub fn ruby_sparkle_spec_l451_d29_errors() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	sparkle_core.ruby_sparkle_l209_d8_self_versions_from_content(sparkle_core.SparkleVersionsRequest{
		content: xml_data['appcast'] or { return false }
		has_block: true
		block_parameter: .invalid
		block: sparkle_spec_invalid
	}, '27') or {
		return err.msg() == 'First argument of Sparkle `strategy` block must be `item` or `items`'
	}
	return false
}

// Ruby let `let(:match_data) do` at line 458.
pub fn ruby_sparkle_spec_l458_d30_match_data() map[string]sparkle_core.SparkleMatchData {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	content := xml_data['appcast'] or { '' }
	base := sparkle_core.SparkleMatchData{
		matches: {
			'1.2.3,123': '1.2.3,123'
		}
		url: ruby_sparkle_spec_l10_d2_appcast_url()
	}
	return {
		'fetched':        sparkle_core.SparkleMatchData{ ...base, content: content, has_content: true }
		'cached':         sparkle_core.SparkleMatchData{ ...base, cached: true, has_cached: true }
		'cached_default': sparkle_core.SparkleMatchData{ ...base, matches: map[string]string{}, cached: true, has_cached: true }
	}
}

// Ruby let `let(:appcast_regex) { %r{/example[._-]v?(\d+(?:\.\d+)+)\.t}i }` at line 472.
pub fn ruby_sparkle_spec_l472_d31_appcast_regex() sparkle_core.XmlRegex {
	return sparkle_core.XmlRegex{
		pattern: r'/example[._-]v?(\d+(?:\.\d+)+)\.t'
		case_insensitive: true
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 474.
pub fn ruby_sparkle_spec_l474_d32_finds() bool {
	actual := sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		url: ruby_sparkle_spec_l10_d2_appcast_url()
	}, sparkle_spec_fetched, '27') or { return false }
	expected := ruby_sparkle_spec_l458_d30_match_data()['fetched'] or { return false }
	return sparkle_spec_match_equal(actual, expected)
}

// Ruby it `it "finds versions in provided content" do` at line 481.
pub fn ruby_sparkle_spec_l481_d33_finds() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	content := xml_data['appcast'] or { return false }
	cached := sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		url: ruby_sparkle_spec_l10_d2_appcast_url()
		content: content
	}, sparkle_spec_unused_fetcher, '27') or { return false }
	with_regex := sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		url: ruby_sparkle_spec_l10_d2_appcast_url()
		content: content
		regex: ruby_sparkle_spec_l472_d31_appcast_regex()
		has_block: true
		block_parameter: .item
		block: sparkle_spec_url_capture
	}, sparkle_spec_unused_fetcher, '27') or { return false }
	expected := ruby_sparkle_spec_l458_d30_match_data()['cached'] or { return false }
	expected_regex := sparkle_core.SparkleMatchData{ ...expected, regex: ruby_sparkle_spec_l472_d31_appcast_regex() }
	return sparkle_spec_match_equal(cached, expected) && sparkle_spec_match_equal(with_regex, expected_regex)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 495.
pub fn ruby_sparkle_spec_l495_d34_returns() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	actual := sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		content: xml_data['appcast'] or { return false }
	}, sparkle_spec_unused_fetcher, '27') or { return false }
	expected := ruby_sparkle_spec_l458_d30_match_data()['cached_default'] or { return false }
	return sparkle_spec_match_equal(actual, sparkle_core.SparkleMatchData{ ...expected, url: '' })
}

// Ruby it `it "returns default match_data when content is blank" do` at line 500.
pub fn ruby_sparkle_spec_l500_d35_returns() bool {
	actual := sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		url: ruby_sparkle_spec_l10_d2_appcast_url()
		content: ''
	}, sparkle_spec_unused_fetcher, '27') or { return false }
	expected := ruby_sparkle_spec_l458_d30_match_data()['cached_default'] or { return false }
	return sparkle_spec_match_equal(actual, expected)
}

// Ruby it `it "errors if a regex is provided without a `strategy` block" do` at line 505.
pub fn ruby_sparkle_spec_l505_d36_errors() bool {
	xml_data := ruby_sparkle_spec_l68_d6_xml()
	sparkle_core.ruby_sparkle_l247_d9_self_find_versions(sparkle_core.SparkleFindVersionsRequest{
		url: ruby_sparkle_spec_l10_d2_appcast_url()
		content: xml_data['appcast'] or { return false }
		regex: ruby_sparkle_spec_l472_d31_appcast_regex()
	}, sparkle_spec_unused_fetcher, '27') or {
		return err.msg() == 'Sparkle only supports a regex when using a `strategy` block'
	}
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5: require "bundle_version"
// 6:
// 7: RSpec.describe Homebrew::Livecheck::Strategy::Sparkle do
// 8:   subject(:sparkle) { described_class }
// 9:
// 10:   let(:appcast_url) { "https://www.example.com/example/appcast.xml" }
// 11:   let(:non_http_url) { "ftp://brew.sh/" }
// 12:   let(:title_regex) { /Version\s+v?(\d+(?:\.\d+)+)\s*$/i }
// 13:   # The `item_hashes` data is used to create test appcast XML and expected
// 14:   # `Sparkle::Item` objects.
// 15:   let(:item_hashes) do
// 16:     {
// 17:       # The 1.2.4 version is only used in tests as the basis for an item that
// 18:       # should be excluded (after modifications).
// 19:       v124: {
// 20:         title:                  "Version 1.2.4",
// 21:         release_notes_link:     "https://www.example.com/example/1.2.4.html",
// 22:         pub_date:               "Fri, 02 Jan 2021 01:23:45 +0000",
// 23:         url:                    "https://www.example.com/example/example-1.2.4.tar.gz",
// 24:         short_version:          "1.2.4",
// 25:         version:                "124",
// 26:         minimum_system_version: "10.10",
// 27:       },
// 28:       v123: {
// 29:         title:                  "Version 1.2.3",
// 30:         release_notes_link:     "https://www.example.com/example/1.2.3.html",
// 31:         pub_date:               "Fri, 01 Jan 2021 01:23:45 +0000",
// 32:         url:                    "https://www.example.com/example/example-1.2.3.tar.gz",
// 33:         short_version:          "1.2.3",
// 34:         version:                "123",
// 35:         minimum_system_version: "10.10",
// 36:       },
// 37:       v122: {
// 38:         title:                  "Version 1.2.2",
// 39:         release_notes_link:     "https://www.example.com/example/1.2.2.html",
// 40:         pub_date:               "Not a parseable date string",
// 41:         link:                   "https://www.example.com/example/example-1.2.2.tar.gz",
// 42:         short_version:          "1.2.2",
// 43:         version:                "122",
// 44:         minimum_system_version: "10.10",
// 45:       },
// 46:       v121: {
// 47:         title:                  "Version 1.2.1",
// 48:         release_notes_link:     "https://www.example.com/example/1.2.1.html",
// 49:         pub_date:               "Thu, 31 Dec 2020 01:23:45 +0000",
// 50:         os:                     "osx",
// 51:         url:                    "https://www.example.com/example/example-1.2.1.tar.gz",
// 52:         short_version:          "1.2.1",
// 53:         version:                "121",
// 54:         minimum_system_version: "10.10",
// 55:       },
// 56:       v120: {
// 57:         title:                  "Version 1.2.0",
// 58:         release_notes_link:     "https://www.example.com/example/1.2.0.html",
// 59:         pub_date:               "Wed, 30 Dec 2020 01:23:45 +0000",
// 60:         os:                     "macos",
// 61:         url:                    "https://www.example.com/example/example-1.2.0.tar.gz",
// 62:         short_version:          "1.2.0",
// 63:         version:                "120",
// 64:         minimum_system_version: "10.10",
// 65:       },
// 66:     }
// 67:   end
// 68:   let(:xml) do
// 69:     v123_item = <<~XML
// 70:       <item>
// 71:         <title>#{item_hashes[:v123][:title]}</title>
// 72:         <sparkle:minimumSystemVersion>#{item_hashes[:v123][:minimum_system_version]}</sparkle:minimumSystemVersion>
// 73:         <sparkle:releaseNotesLink>#{item_hashes[:v123][:release_notes_link]}</sparkle:releaseNotesLink>
// 74:         <pubDate>#{item_hashes[:v123][:pub_date]}</pubDate>
// 75:         <enclosure url="#{item_hashes[:v123][:url]}" sparkle:shortVersionString="#{item_hashes[:v123][:short_version]}" sparkle:version="#{item_hashes[:v123][:version]}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF+GHIJKLMNOPQRSTUVWXYZab/cdefghijklmnopqrst/uvwxyz1234567==" />
// 76:       </item>
// 77:     XML
// 78:
// 79:     v122_item = <<~XML
// 80:       <item>
// 81:         <title>#{item_hashes[:v122][:title]}</title>
// 82:         <link>#{item_hashes[:v122][:link]}</link>
// 83:         <sparkle:minimumSystemVersion>#{item_hashes[:v122][:minimum_system_version]}</sparkle:minimumSystemVersion>
// 84:         <sparkle:releaseNotesLink>#{item_hashes[:v122][:release_notes_link]}</sparkle:releaseNotesLink>
// 85:         <pubDate>#{item_hashes[:v122][:pub_date]}</pubDate>
// 86:         <sparkle:version>#{item_hashes[:v122][:version]}</sparkle:version>
// 87:         <sparkle:shortVersionString>#{item_hashes[:v122][:short_version]}</sparkle:shortVersionString>
// 88:       </item>
// 89:     XML
// 90:
// 91:     v121_item_with_osx_os = <<~XML
// 92:       <item>
// 93:         <title>#{item_hashes[:v121][:title]}</title>
// 94:         <sparkle:minimumSystemVersion>#{item_hashes[:v121][:minimum_system_version]}</sparkle:minimumSystemVersion>
// 95:         <sparkle:releaseNotesLink>#{item_hashes[:v121][:release_notes_link]}</sparkle:releaseNotesLink>
// 96:         <pubDate>#{item_hashes[:v121][:pub_date]}</pubDate>
// 97:         <enclosure os="#{item_hashes[:v121][:os]}" url="#{item_hashes[:v121][:url]}" sparkle:shortVersionString="#{item_hashes[:v121][:short_version]}" sparkle:version="#{item_hashes[:v121][:version]}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF+GHIJKLMNOPQRSTUVWXYZab/cdefghijklmnopqrst/uvwxyz1234567==" />
// 98:       </item>
// 99:     XML
// 100:
// 101:     v120_item_with_macos_os = <<~XML
// 102:       <item>
// 103:         <title>#{item_hashes[:v120][:title]}</title>
// 104:         <sparkle:minimumSystemVersion>#{item_hashes[:v120][:minimum_system_version]}</sparkle:minimumSystemVersion>
// 105:         <sparkle:releaseNotesLink>#{item_hashes[:v120][:release_notes_link]}</sparkle:releaseNotesLink>
// 106:         <pubDate>#{item_hashes[:v120][:pub_date]}</pubDate>
// 107:         <enclosure os="#{item_hashes[:v120][:os]}" url="#{item_hashes[:v120][:url]}" sparkle:shortVersionString="#{item_hashes[:v120][:short_version]}" sparkle:version="#{item_hashes[:v120][:version]}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF+GHIJKLMNOPQRSTUVWXYZab/cdefghijklmnopqrst/uvwxyz1234567==" />
// 108:       </item>
// 109:     XML
// 110:
// 111:     # This main `appcast` data is intended as a relatively normal example.
// 112:     # As such, it also serves as a base for some other test data.
// 113:     appcast = create_appcast_xml <<~XML
// 114:       #{v123_item}
// 115:       #{v122_item}
// 116:       #{v121_item_with_osx_os}
// 117:       #{v120_item_with_macos_os}
// 118:     XML
// 119:
// 120:     omitted_items = create_appcast_xml <<~XML
// 121:       #{v123_item.sub(%r{<(enclosure[^>]+?)\s*?/>}, '<\1 os="not-osx-or-macos" />')}
// 122:       #{v123_item.sub(/(<sparkle:minimumSystemVersion>)[^<]+?</m, '\1100<')}
// 123:       <item>
// 124:       </item>
// 125:     XML
// 126:
// 127:     # Set the first item in a copy of `appcast` to a bad `minimumSystemVersion`
// 128:     # value, to test `MacOSVersion::Error` handling. The version string needs
// 129:     # to be something that cannot be adequately cleaned up by the related
// 130:     # `#gsub` call in `items_from_content`.
// 131:     bad_macos_version = appcast.sub(
// 132:       v123_item,
// 133:       v123_item.sub(
// 134:         /(<sparkle:minimumSystemVersion>)[^<]+?</m,
// 135:         '\1a1b2c3d<',
// 136:       ),
// 137:     )
// 138:
// 139:     # Set the first item in a copy of `appcast` to the "beta" channel, to test
// 140:     # filtering items by channel using a `strategy` block.
// 141:     beta_channel_item = appcast.sub(
// 142:       v123_item,
// 143:       v123_item.sub(
// 144:         "</title>",
// 145:         "</title>\n<sparkle:channel>beta</sparkle:channel>",
// 146:       ),
// 147:     )
// 148:
// 149:     no_versions_item = create_appcast_xml <<~XML
// 150:       <item>
// 151:         <title>Version</title>
// 152:         <sparkle:minimumSystemVersion>#{item_hashes[:v123][:minimum_system_version]}</sparkle:minimumSystemVersion>
// 153:         <sparkle:releaseNotesLink>#{item_hashes[:v123][:release_notes_link]}</sparkle:releaseNotesLink>
// 154:         <pubDate>#{item_hashes[:v123][:pub_date]}</pubDate>
// 155:         <enclosure url="#{item_hashes[:v123][:url]}" length="12345678" type="application/octet-stream" sparkle:dsaSignature="ABCDEF+GHIJKLMNOPQRSTUVWXYZab/cdefghijklmnopqrst/uvwxyz1234567==" />
// 156:       </item>
// 157:     XML
// 158:
// 159:     no_items = create_appcast_xml
// 160:
// 161:     undefined_namespace = appcast.sub(/\s*xmlns:sparkle="[^"]+"/, "")
// 162:
// 163:     {
// 164:       appcast:,
// 165:       omitted_items:,
// 166:       bad_macos_version:,
// 167:       beta_channel_item:,
// 168:       no_versions_item:,
// 169:       no_items:,
// 170:       undefined_namespace:,
// 171:     }
// 172:   end
// 173:   let(:items) do
// 174:     {
// 175:       v124: Homebrew::Livecheck::Strategy::Sparkle::Item.new(
// 176:         title:                  item_hashes[:v124][:title],
// 177:         release_notes_link:     item_hashes[:v124][:release_notes_link],
// 178:         pub_date:               Time.parse(item_hashes[:v124][:pub_date]),
// 179:         url:                    item_hashes[:v124][:url],
// 180:         bundle_version:         Homebrew::BundleVersion.new(
// 181:           item_hashes[:v124][:short_version],
// 182:           item_hashes[:v124][:version],
// 183:         ),
// 184:         minimum_system_version: MacOSVersion.new(item_hashes[:v124][:minimum_system_version]),
// 185:       ),
// 186:       v123: Homebrew::Livecheck::Strategy::Sparkle::Item.new(
// 187:         title:                  item_hashes[:v123][:title],
// 188:         release_notes_link:     item_hashes[:v123][:release_notes_link],
// 189:         pub_date:               Time.parse(item_hashes[:v123][:pub_date]),
// 190:         url:                    item_hashes[:v123][:url],
// 191:         bundle_version:         Homebrew::BundleVersion.new(
// 192:           item_hashes[:v123][:short_version],
// 193:           item_hashes[:v123][:version],
// 194:         ),
// 195:         minimum_system_version: MacOSVersion.new(item_hashes[:v123][:minimum_system_version]),
// 196:       ),
// 197:       v122: Homebrew::Livecheck::Strategy::Sparkle::Item.new(
// 198:         title:                  item_hashes[:v122][:title],
// 199:         link:                   item_hashes[:v122][:link],
// 200:         release_notes_link:     item_hashes[:v122][:release_notes_link],
// 201:         # `#items_from_content` falls back to a default `pub_date` when
// 202:         # one isn't provided or can't be successfully parsed.
// 203:         pub_date:               Time.new(0),
// 204:         url:                    item_hashes[:v122][:link],
// 205:         bundle_version:         Homebrew::BundleVersion.new(
// 206:           item_hashes[:v122][:short_version],
// 207:           item_hashes[:v122][:version],
// 208:         ),
// 209:         minimum_system_version: MacOSVersion.new(item_hashes[:v122][:minimum_system_version]),
// 210:       ),
// 211:       v121: Homebrew::Livecheck::Strategy::Sparkle::Item.new(
// 212:         title:                  item_hashes[:v121][:title],
// 213:         release_notes_link:     item_hashes[:v121][:release_notes_link],
// 214:         pub_date:               Time.parse(item_hashes[:v121][:pub_date]),
// 215:         os:                     item_hashes[:v121][:os],
// 216:         url:                    item_hashes[:v121][:url],
// 217:         bundle_version:         Homebrew::BundleVersion.new(
// 218:           item_hashes[:v121][:short_version],
// 219:           item_hashes[:v121][:version],
// 220:         ),
// 221:         minimum_system_version: MacOSVersion.new(item_hashes[:v121][:minimum_system_version]),
// 222:       ),
// 223:       v120: Homebrew::Livecheck::Strategy::Sparkle::Item.new(
// 224:         title:                  item_hashes[:v120][:title],
// 225:         release_notes_link:     item_hashes[:v120][:release_notes_link],
// 226:         pub_date:               Time.parse(item_hashes[:v120][:pub_date]),
// 227:         os:                     item_hashes[:v120][:os],
// 228:         url:                    item_hashes[:v120][:url],
// 229:         bundle_version:         Homebrew::BundleVersion.new(
// 230:           item_hashes[:v120][:short_version],
// 231:           item_hashes[:v120][:version],
// 232:         ),
// 233:         minimum_system_version: MacOSVersion.new(item_hashes[:v120][:minimum_system_version]),
// 234:       ),
// 235:     }
// 236:   end
// 237:   let(:item_arrays) do
// 238:     item_arrays = {
// 239:       appcast:        [
// 240:         items[:v123],
// 241:         items[:v122],
// 242:         items[:v121],
// 243:         items[:v120],
// 244:       ],
// 245:       appcast_sorted: [
// 246:         items[:v123],
// 247:         items[:v121],
// 248:         items[:v120],
// 249:         items[:v122],
// 250:       ],
// 251:     }
// 252:
// 253:     bad_macos_version_item = items[:v123].clone
// 254:     bad_macos_version_item.minimum_system_version = nil
// 255:     item_arrays[:bad_macos_version] = [
// 256:       bad_macos_version_item,
// 257:       items[:v122],
// 258:       items[:v121],
// 259:       items[:v120],
// 260:     ]
// 261:
// 262:     beta_channel_item = items[:v123].clone
// 263:     beta_channel_item.channel = "beta"
// 264:     item_arrays[:beta_channel_item] = [
// 265:       beta_channel_item,
// 266:       items[:v122],
// 267:       items[:v121],
// 268:       items[:v120],
// 269:     ]
// 270:
// 271:     no_versions_item = items[:v123].clone
// 272:     no_versions_item.title = "Version"
// 273:     no_versions_item.bundle_version = nil
// 274:     item_arrays[:no_versions_item] = [no_versions_item]
// 275:
// 276:     item_arrays
// 277:   end
// 278:   let(:matches) { ["1.2.3,123"] }
// 279:
// 280:   def create_appcast_xml(items_str = "")
// 281:     <<~XML
// 282:       <?xml version="1.0" encoding="utf-8"?>
// 283:       <rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
// 284:         <channel>
// 285:           <title>Example Changelog</title>
// 286:           <link>#{appcast_url}</link>
// 287:           <description>Most recent changes with links to updates.</description>
// 288:           <language>en</language>
// 289:           #{items_str}
// 290:         </channel>
// 291:       </rss>
// 292:     XML
// 293:   end
// 294:
// 295:   describe "::match?" do
// 296:     it "returns true for an HTTP URL" do
// 297:       expect(sparkle.match?(appcast_url)).to be true
// 298:     end
// 299:
// 300:     it "returns false for a non-HTTP URL" do
// 301:       expect(sparkle.match?(non_http_url)).to be false
// 302:     end
// 303:   end
// 304:
// 305:   describe "::items_from_content" do
// 306:     let(:items_from_appcast) { sparkle.items_from_content(xml[:appcast]) }
// 307:
// 308:     it "returns nil if content is blank" do
// 309:       expect(sparkle.items_from_content("")).to eq([])
// 310:     end
// 311:
// 312:     it "returns an array of Items when given XML data" do
// 313:       expect(items_from_appcast).to eq(item_arrays[:appcast])
// 314:       expect(items_from_appcast[0].title).to eq(item_hashes[:v123][:title])
// 315:       expect(items_from_appcast[0].pub_date).to eq(Time.parse(item_hashes[:v123][:pub_date]))
// 316:       expect(items_from_appcast[0].url).to eq(item_hashes[:v123][:url])
// 317:       expect(items_from_appcast[0].short_version).to eq(item_hashes[:v123][:short_version])
// 318:       expect(items_from_appcast[0].version).to eq(item_hashes[:v123][:version])
// 319:
// 320:       expect(sparkle.items_from_content(xml[:bad_macos_version])).to eq(item_arrays[:bad_macos_version])
// 321:       expect(sparkle.items_from_content(xml[:beta_channel_item])).to eq(item_arrays[:beta_channel_item])
// 322:       expect(sparkle.items_from_content(xml[:no_versions_item])).to eq(item_arrays[:no_versions_item])
// 323:     end
// 324:   end
// 325:
// 326:   describe "::filter_items" do
// 327:     let(:items_non_mac_os) do
// 328:       item = items[:v124].clone
// 329:       item.os = "not-osx-or-macos"
// 330:       item_arrays[:appcast] + [item]
// 331:     end
// 332:
// 333:     let(:items_prerelease_minimum_system_version) do
// 334:       item = items[:v124].clone
// 335:       item.minimum_system_version = MacOSVersion.new("100")
// 336:       item_arrays[:appcast] + [item]
// 337:     end
// 338:
// 339:     it "removes items with a non-mac OS" do
// 340:       expect(sparkle.filter_items(items_non_mac_os)).to eq(item_arrays[:appcast])
// 341:     end
// 342:
// 343:     it "removes items with a prerelease minimumSystemVersion" do
// 344:       expect(sparkle.filter_items(items_prerelease_minimum_system_version)).to eq(item_arrays[:appcast])
// 345:     end
// 346:   end
// 347:
// 348:   describe "::sort_items" do
// 349:     it "returns a sorted array of items" do
// 350:       expect(sparkle.sort_items(item_arrays[:appcast])).to eq(item_arrays[:appcast_sorted])
// 351:     end
// 352:   end
// 353:
// 354:   # `#versions_from_content` sorts items by `pub_date` and `bundle_version`, so
// 355:   # these tests have to account for this behavior in the expected output.
// 356:   # For example, the version 122 item doesn't have a parseable `pub_date` and
// 357:   # the substituted default will cause it to be sorted last.
// 358:   describe "::versions_from_content" do
// 359:     let(:versions) { [items[:v123].nice_version] }
// 360:     let(:subbed_items) { item_arrays[:appcast_sorted].map { |item| item.nice_version.sub("1", "0") } }
// 361:
// 362:     it "returns an array of version strings when given content" do
// 363:       expect(sparkle.versions_from_content(xml[:appcast])).to eq(versions)
// 364:       expect(sparkle.versions_from_content(xml[:omitted_items])).to eq([])
// 365:       expect(sparkle.versions_from_content(xml[:beta_channel_item])).to eq(versions)
// 366:       expect(sparkle.versions_from_content(xml[:no_versions_item])).to eq([])
// 367:       expect(sparkle.versions_from_content(xml[:undefined_namespace])).to eq(versions)
// 368:     end
// 369:
// 370:     it "returns an empty array if no items are found" do
// 371:       expect(sparkle.versions_from_content(xml[:no_items])).to eq([])
// 372:     end
// 373:
// 374:     it "returns an array of version strings when given content and a block" do
// 375:       # Returning a string from block
// 376:       expect(
// 377:         sparkle.versions_from_content(xml[:appcast]) do |item|
// 378:           item.nice_version&.sub("1", "0")
// 379:         end,
// 380:       ).to eq([subbed_items[0]])
// 381:
// 382:       # Returning an array of strings from block
// 383:       expect(
// 384:         sparkle.versions_from_content(xml[:appcast]) do |items|
// 385:           items.map { |item| item.nice_version&.sub("1", "0") }
// 386:         end,
// 387:       ).to eq(subbed_items)
// 388:
// 389:       expect(
// 390:         sparkle.versions_from_content(xml[:beta_channel_item]) do |items|
// 391:           items.find { |item| item.channel.nil? }&.nice_version
// 392:         end,
// 393:       ).to eq([items[:v121].nice_version])
// 394:     end
// 395:
// 396:     it "returns an array of version strings when given content, a regex and a block" do
// 397:       # Returning a string from the block
// 398:       expect(
// 399:         sparkle.versions_from_content(xml[:appcast], title_regex) do |item, regex|
// 400:           item.title[regex, 1]
// 401:         end,
// 402:       ).to eq([item_hashes[:v123][:short_version]])
// 403:
// 404:       expect(
// 405:         sparkle.versions_from_content(xml[:appcast], title_regex) do |items, regex|
// 406:           next if (item = items[0]).blank?
// 407:
// 408:           match = item&.title&.match(regex)
// 409:           next if match.blank?
// 410:
// 411:           "#{match[1]},#{item.version}"
// 412:         end,
// 413:       ).to eq(["#{item_hashes[:v123][:short_version]},#{item_hashes[:v123][:version]}"])
// 414:
// 415:       # Returning an array of strings from the block
// 416:       expect(
// 417:         sparkle.versions_from_content(xml[:appcast], title_regex) do |item, regex|
// 418:           [item.title[regex, 1]]
// 419:         end,
// 420:       ).to eq([item_hashes[:v123][:short_version]])
// 421:
// 422:       expect(
// 423:         sparkle.versions_from_content(xml[:appcast], &:short_version),
// 424:       ).to eq([item_hashes[:v123][:short_version]])
// 425:
// 426:       expect(
// 427:         sparkle.versions_from_content(xml[:appcast], title_regex) do |items, regex|
// 428:           items.map { |item| item.title[regex, 1] }
// 429:         end,
// 430:       ).to eq(item_arrays[:appcast_sorted].map(&:short_version))
// 431:     end
// 432:
// 433:     it "allows a nil return from a block" do
// 434:       expect(
// 435:         sparkle.versions_from_content(xml[:appcast]) do |item|
// 436:           _ = item # To appease `brew style` without modifying arg name
// 437:           next
// 438:         end,
// 439:       ).to eq([])
// 440:     end
// 441:
// 442:     it "errors on an invalid return type from a block" do
// 443:       expect do
// 444:         sparkle.versions_from_content(xml[:appcast]) do |item|
// 445:           _ = item # To appease `brew style` without modifying arg name
// 446:           123
// 447:         end
// 448:       end.to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 449:     end
// 450:
// 451:     it "errors if the first block argument uses an unhandled name" do
// 452:       expect { sparkle.versions_from_content(xml[:appcast]) { |something| something } }
// 453:         .to raise_error(ArgumentError, "First argument of Sparkle `strategy` block must be `item` or `items`")
// 454:     end
// 455:   end
// 456:
// 457:   describe "::find_versions" do
// 458:     let(:match_data) do
// 459:       base = {
// 460:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 461:         regex:   nil,
// 462:         url:     appcast_url,
// 463:       }
// 464:
// 465:       {
// 466:         fetched:        base.merge({ content: xml[:appcast] }),
// 467:         cached:         base.merge({ cached: true }),
// 468:         cached_default: base.merge({ matches: {}, cached: true }),
// 469:       }
// 470:     end
// 471:
// 472:     let(:appcast_regex) { %r{/example[._-]v?(\d+(?:\.\d+)+)\.t}i }
// 473:
// 474:     it "finds versions in fetched content" do
// 475:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: xml[:appcast] })
// 476:
// 477:       expect(sparkle.find_versions(url: appcast_url))
// 478:         .to eq(match_data[:fetched])
// 479:     end
// 480:
// 481:     it "finds versions in provided content" do
// 482:       expect(sparkle.find_versions(url: appcast_url, content: xml[:appcast]))
// 483:         .to eq(match_data[:cached])
// 484:
// 485:       # This `strategy` block is unnecessary but it's intended to test using a
// 486:       # regex in a `strategy` block.
// 487:       expect(sparkle.find_versions(url: appcast_url, regex: appcast_regex, content: xml[:appcast]) do |item, regex|
// 488:         match = item.url.match(regex)
// 489:         next if match.blank?
// 490:
// 491:         "#{match[1]},#{match[1].tr(".", "")}"
// 492:       end).to eq(match_data[:cached].merge({ regex: appcast_regex }))
// 493:     end
// 494:
// 495:     it "returns default match_data when url is blank" do
// 496:       expect(sparkle.find_versions(url: "", content: xml[:appcast]))
// 497:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 498:     end
// 499:
// 500:     it "returns default match_data when content is blank" do
// 501:       expect(sparkle.find_versions(url: appcast_url, content: ""))
// 502:         .to eq(match_data[:cached_default])
// 503:     end
// 504:
// 505:     it "errors if a regex is provided without a `strategy` block" do
// 506:       expect { sparkle.find_versions(url: appcast_url, regex: appcast_regex, content: xml[:appcast]) }
// 507:         .to raise_error(ArgumentError, "Sparkle only supports a regex when using a `strategy` block")
// 508:     end
// 509:   end
// 510: end
