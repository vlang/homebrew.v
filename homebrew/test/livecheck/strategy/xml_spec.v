module strategy

import encoding.xml
import homebrew.livecheck as strategy_core
import homebrew.livecheck.strategy as xml_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/xml_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn xml_spec_string(value string) strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{
		kind: .string_value
		value: value
	}
}

fn xml_spec_strings(values []string) strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{
		kind: .array
		values: values.map(strategy_core.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn xml_spec_version_capture(value string) ?string {
	mut candidate := value.trim_space()
	if candidate.len > 0 && candidate[0] in [`v`, `V`] {
		candidate = candidate[1..]
	}
	parts := candidate.split('.')
	if parts.len < 2 || parts.any(it == '' || !it.bytes().all(it >= `0` && it <= `9`)) {
		return none
	}
	return candidate
}

fn xml_spec_simple_block(document xml.XMLDocument,
	regex ?xml_core.XmlRegex) !strategy_core.StrategyBlockValue {
	value := xml_core.xml_element_text(document.root, none) or {
		return strategy_core.StrategyBlockValue{ kind: .nil_value }
	}
	if _ := regex {
		capture := xml_spec_version_capture(value) or {
			return strategy_core.StrategyBlockValue{ kind: .nil_value }
		}
		return xml_spec_string(capture)
	}
	return xml_spec_string(value)
}

fn xml_spec_versions_block(document xml.XMLDocument,
	_ ?xml_core.XmlRegex) !strategy_core.StrategyBlockValue {
	mut versions := []string{}
	for node in xml_core.xml_elements(document, '/versions/version') {
		text := xml_core.xml_element_text(node, none) or { continue }
		if version := xml_spec_version_capture(text) {
			versions << version
		}
	}
	return xml_spec_strings(versions)
}

fn xml_spec_attributes_block(document xml.XMLDocument,
	_ ?xml_core.XmlRegex) !strategy_core.StrategyBlockValue {
	mut versions := []string{}
	for node in xml_core.xml_elements(document, '/items/item') {
		text := node.attributes['version'] or { continue }
		if version := xml_spec_version_capture(text) {
			versions << version
		}
	}
	return xml_spec_strings(versions)
}

fn xml_spec_nil_block(_ xml.XMLDocument,
	_ ?xml_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{ kind: .nil_value }
}

fn xml_spec_invalid_block(_ xml.XMLDocument,
	_ ?xml_core.XmlRegex) !strategy_core.StrategyBlockValue {
	return strategy_core.StrategyBlockValue{ kind: .invalid }
}

fn xml_spec_fetched_content(_ strategy_core.StrategyCurlRequest) !utils.CurlCommandResult {
	content := ruby_xml_spec_l14_d5_content_version_text()
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/xml\r\n\r\n${content}'
		exit_status: 0
	}
}

fn xml_spec_unused_fetcher(_ strategy_core.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached content unexpectedly fetched')
}

fn xml_spec_missing_prefix_parser(_ string) !xml.XMLDocument {
	return error('Undefined namespace')
}

fn xml_spec_repeated_prefix_parser(_ string) !xml.XMLDocument {
	return error('Undefined prefix something found')
}

fn xml_spec_regex() xml_core.XmlRegex {
	return xml_core.XmlRegex{
		pattern: r'^v?(\d+(?:\.\d+)+)$'
		case_insensitive: true
	}
}

fn xml_spec_find_request(url string, content ?string, regex ?xml_core.XmlRegex,
	block xml_core.XmlVersionsBlock, block_arity int) xml_core.XmlFindVersionsRequest {
	return xml_core.XmlFindVersionsRequest{
		url: url
		content: content
		regex: regex
		has_block: true
		block_arity: block_arity
		block: block
	}
}

fn xml_spec_match_equal(left xml_core.XmlMatchData, right xml_core.XmlMatchData) bool {
	left_regex := if value := left.regex { value.pattern } else { '' }
	right_regex := if value := right.regex { value.pattern } else { '' }
	return left.matches == right.matches && left_regex == right_regex && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:xml) { described_class }` at line 9.
pub fn ruby_xml_spec_l9_d1_xml() string {
	return 'Xml'
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 11.
pub fn ruby_xml_spec_l11_d2_http_url() string {
	return 'https://brew.sh/blog/'
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 12.
pub fn ruby_xml_spec_l12_d3_non_http_url() string {
	return 'ftp://brew.sh/'
}

// Ruby let `let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 13.
pub fn ruby_xml_spec_l13_d4_regex() xml_core.XmlRegex {
	return xml_spec_regex()
}

// Ruby let `let(:content_version_text) do` at line 14.
pub fn ruby_xml_spec_l14_d5_content_version_text() string {
	versions := ['1.1.2', '1.1.2b', '1.1.2a', '1.1.1', '1.1.0', '1.1.0-rc3', '1.1.0-rc2', '1.1.0-rc1',
		'1.0.x-last', '1.0.3', '1.0.3-rc3', '1.0.3-rc2', '1.0.3-rc1', '1.0.2', '1.0.2-rc1', '1.0.1',
		'1.0.1-rc1', '1.0.0', '1.0.0-rc1']
	mut lines := ['<?xml version="1.0" encoding="utf-8"?>', '<versions>']
	lines << versions.map('  <version>${it}</version>')
	lines << '</versions>'
	return lines.join('\n') + '\n'
}

// Ruby let `let(:content_version_attr) do` at line 40.
pub fn ruby_xml_spec_l40_d6_content_version_attr() string {
	versions := ['1.1.2', '1.1.2b', '1.1.2a', '1.1.1', '1.1.0', '1.1.0-rc3', '1.1.0-rc2', '1.1.0-rc1',
		'1.0.x-last', '1.0.3', '1.0.3-rc3', '1.0.3-rc2', '1.0.3-rc1', '1.0.2', '1.0.2-rc1', '1.0.1',
		'1.0.1-rc1', '1.0.0', '1.0.0-rc1']
	mut lines := ['<?xml version="1.0" encoding="utf-8"?>', '<items>']
	lines << versions.map('  <item version="${it}" />')
	lines << '</items>'
	return lines.join('\n') + '\n'
}

// Ruby let `let(:content_simple) do` at line 66.
pub fn ruby_xml_spec_l66_d7_content_simple() string {
	return '<?xml version="1.0" encoding="utf-8"?>\n<version>1.2.3</version>\n'
}

// Ruby let `let(:content_undefined_namespace) do` at line 72.
pub fn ruby_xml_spec_l72_d8_content_undefined_namespace() string {
	return '<?xml version="1.0" encoding="utf-8"?>\n<something:version>1.2.3</something:version>\n'
}

// Ruby let `let(:parent_child_text) { { parent: "1.2.3", child: "4.5.6" } }` at line 78.
pub fn ruby_xml_spec_l78_d9_parent_child_text() map[string]string {
	return {
		'parent': '1.2.3'
		'child':  '4.5.6'
	}
}

// Ruby let `let(:content_parent_child) do` at line 79.
pub fn ruby_xml_spec_l79_d10_content_parent_child() string {
	return '<?xml version="1.0" encoding="utf-8"?>\n<elements>\n  <parent>\n    1.2.3\n    <child> 4.5.6 </child>\n  </parent>\n  <blank-parent>\n    <blank-child></blank-child>\n  </blank-parent>\n</elements>\n'
}

// Ruby let `let(:matches) do` at line 95.
pub fn ruby_xml_spec_l95_d11_matches() map[string][]string {
	return {
		'content': ['1.1.2', '1.1.1', '1.1.0', '1.0.3', '1.0.2', '1.0.1', '1.0.0']
		'simple':  ['1.2.3']
	}
}

// Ruby it `it "returns true for an HTTP URL" do` at line 103.
pub fn ruby_xml_spec_l103_d12_returns() bool {
	return xml_core.ruby_xml_l49_d1_self_match(ruby_xml_spec_l11_d2_http_url())
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 107.
pub fn ruby_xml_spec_l107_d13_returns() bool {
	return !xml_core.ruby_xml_l49_d1_self_match(ruby_xml_spec_l12_d3_non_http_url())
}

// Ruby it `it "returns an REXML::Document when given XML content" do` at line 114.
pub fn ruby_xml_spec_l114_d14_returns() bool {
	document := xml_core.ruby_xml_l57_d2_self_parse_xml(ruby_xml_spec_l14_d5_content_version_text()) or {
		return false
	}
	return document.root.name == 'versions'
}

// Ruby it `it "returns an REXML::Document when given XML content with an undefined namespace" do` at line 118.
pub fn ruby_xml_spec_l118_d15_returns() bool {
	document := xml_core.ruby_xml_l57_d2_self_parse_xml(ruby_xml_spec_l72_d8_content_undefined_namespace()) or {
		return false
	}
	return document.root.name == 'something:version' || document.root.name == 'version'
}

// Ruby it `it "errors if an undefined prefix name is not provided in the UndefinedNamespaceException" do` at line 122.
pub fn ruby_xml_spec_l122_d16_errors() bool {
	xml_core.xml_parse_xml_with(ruby_xml_spec_l72_d8_content_undefined_namespace(), xml_spec_missing_prefix_parser) or {
		return err.msg() == 'Could not identify undefined prefix.'
	}
	return false
}

// Ruby it `it "errors if XML cannot be parsed after removing undefined prefix" do` at line 129.
pub fn ruby_xml_spec_l129_d17_errors() bool {
	xml_core.xml_parse_xml_with(ruby_xml_spec_l72_d8_content_undefined_namespace(), xml_spec_repeated_prefix_parser) or {
		return err.msg() == 'Could not parse XML after removing undefined prefix.'
	}
	return false
}

// Ruby let `let(:parent_child_doc) { xml.parse_xml(content_parent_child) }` at line 138.
pub fn ruby_xml_spec_l138_d18_parent_child_doc() !xml.XMLDocument {
	return xml_core.ruby_xml_l57_d2_self_parse_xml(ruby_xml_spec_l79_d10_content_parent_child())
}

// Ruby let `let(:parent) { parent_child_doc.get_elements("/elements/parent").first }` at line 139.
pub fn ruby_xml_spec_l139_d19_parent() !xml.XMLNode {
	document := ruby_xml_spec_l138_d18_parent_child_doc()!
	return xml_core.xml_elements(document, '/elements/parent')[0]
}

// Ruby let `let(:blank_parent) { parent_child_doc.get_elements("/elements/blank-parent").first }` at line 140.
pub fn ruby_xml_spec_l140_d20_blank_parent() !xml.XMLNode {
	document := ruby_xml_spec_l138_d18_parent_child_doc()!
	return xml_core.xml_elements(document, '/elements/blank-parent')[0]
}

// Ruby it `it "returns the element text if child_name is not provided" do` at line 142.
pub fn ruby_xml_spec_l142_d21_returns() bool {
	parent := ruby_xml_spec_l139_d19_parent() or { return false }
	return xml_core.ruby_xml_l91_d3_self_element_text(parent, none) or { '' } == ruby_xml_spec_l78_d9_parent_child_text()['parent']
}

// Ruby it `it "returns the child element text if child_name is provided" do` at line 146.
pub fn ruby_xml_spec_l146_d22_returns() bool {
	parent := ruby_xml_spec_l139_d19_parent() or { return false }
	return xml_core.ruby_xml_l91_d3_self_element_text(parent, 'child') or { '' } == ruby_xml_spec_l78_d9_parent_child_text()['child']
}

// Ruby it `it "returns `nil` if the provided child element does not exist" do` at line 150.
pub fn ruby_xml_spec_l150_d23_returns() bool {
	parent := ruby_xml_spec_l139_d19_parent() or { return false }
	if _ := xml_core.ruby_xml_l91_d3_self_element_text(parent, 'nonexistent') {
		return false
	}
	return true
}

// Ruby it `it "returns `nil` if the retrieved text is blank" do` at line 154.
pub fn ruby_xml_spec_l154_d24_returns() bool {
	parent := ruby_xml_spec_l140_d20_blank_parent() or { return false }
	if _ := xml_core.ruby_xml_l91_d3_self_element_text(parent, none) {
		return false
	}
	if _ := xml_core.ruby_xml_l91_d3_self_element_text(parent, 'blank-child') {
		return false
	}
	return true
}

// Ruby it `it "returns an empty array when given a block but content is blank" do` at line 161.
pub fn ruby_xml_spec_l161_d25_returns() bool {
	result := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		regex: xml_spec_regex()
		has_block: true
		block_arity: 1
		block: xml_spec_simple_block
	}) or { return false }
	return result.len == 0
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 165.
pub fn ruby_xml_spec_l165_d26_returns() bool {
	simple := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l66_d7_content_simple()
		has_block: true
		block_arity: 1
		block: xml_spec_simple_block
	}) or { return false }
	simple_regex := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l66_d7_content_simple()
		regex: xml_spec_regex()
		has_block: true
		block_arity: 1
		block: xml_spec_simple_block
	}) or { return false }
	text_versions := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l14_d5_content_version_text()
		regex: xml_spec_regex()
		has_block: true
		block_arity: 2
		block: xml_spec_versions_block
	}) or { return false }
	attribute_versions := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l40_d6_content_version_attr()
		regex: xml_spec_regex()
		has_block: true
		block_arity: 2
		block: xml_spec_attributes_block
	}) or { return false }
	expected := ruby_xml_spec_l95_d11_matches()
	return simple == expected['simple'] && simple_regex == expected['simple'] && text_versions == expected['content'] && attribute_versions == expected['content']
}

// Ruby it `it "allows a nil return from a block" do` at line 192.
pub fn ruby_xml_spec_l192_d27_allows() bool {
	result := xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l66_d7_content_simple()
		regex: xml_spec_regex()
		has_block: true
		block_arity: 1
		block: xml_spec_nil_block
	}) or { return false }
	return result.len == 0
}

// Ruby it `it "errors if a block uses two arguments but a regex is not given" do` at line 196.
pub fn ruby_xml_spec_l196_d28_errors() bool {
	xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l66_d7_content_simple()
		has_block: true
		block_arity: 2
		block: xml_spec_simple_block
	}) or {
		return err.msg() == 'Two arguments found in `strategy` block but no regex provided.'
	}
	return false
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 201.
pub fn ruby_xml_spec_l201_d29_errors() bool {
	xml_core.ruby_xml_l114_d4_self_versions_from_content(xml_core.XmlVersionsRequest{
		content: ruby_xml_spec_l66_d7_content_simple()
		regex: xml_spec_regex()
		has_block: true
		block_arity: 0
		block: xml_spec_invalid_block
	}) or {
		return err.msg() == 'Return value of a strategy block must be a string or array of strings.'
	}
	return false
}

// Ruby let `let(:match_data) do` at line 208.
pub fn ruby_xml_spec_l208_d30_match_data() map[string]xml_core.XmlMatchData {
	matches := ruby_xml_spec_l95_d11_matches()['content'].clone()
	mut mapped := map[string]string{}
	for version in matches {
		mapped[version] = version
	}
	base := xml_core.XmlMatchData{
		matches: mapped
		regex: xml_spec_regex()
		url: ruby_xml_spec_l11_d2_http_url()
	}
	return {
		'fetched':        xml_core.XmlMatchData{
			...base
			content: ruby_xml_spec_l14_d5_content_version_text()
			has_content: true
		}
		'cached':         xml_core.XmlMatchData{ ...base, cached: true, has_cached: true }
		'cached_default': xml_core.XmlMatchData{
			...base
			matches: map[string]string{}
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 222.
pub fn ruby_xml_spec_l222_d31_finds() bool {
	actual := xml_core.ruby_xml_l147_d5_self_find_versions(xml_spec_find_request(ruby_xml_spec_l11_d2_http_url(), none, xml_spec_regex(), xml_spec_versions_block, 2), xml_spec_fetched_content) or {
		return false
	}
	return xml_spec_match_equal(actual, ruby_xml_spec_l208_d30_match_data()['fetched'])
}

// Ruby it `it "finds versions in content using a block" do` at line 230.
pub fn ruby_xml_spec_l230_d32_finds() bool {
	content := ruby_xml_spec_l14_d5_content_version_text()
	with_regex := xml_core.ruby_xml_l147_d5_self_find_versions(xml_spec_find_request(ruby_xml_spec_l11_d2_http_url(), content, xml_spec_regex(), xml_spec_versions_block, 2), xml_spec_unused_fetcher) or {
		return false
	}
	without_regex := xml_core.ruby_xml_l147_d5_self_find_versions(xml_spec_find_request(ruby_xml_spec_l11_d2_http_url(), content, none, xml_spec_versions_block, 1), xml_spec_unused_fetcher) or {
		return false
	}
	expected := ruby_xml_spec_l208_d30_match_data()['cached']
	mut expected_without_regex := expected
	expected_without_regex = xml_core.XmlMatchData{ ...expected_without_regex, regex: none }
	return xml_spec_match_equal(with_regex, expected) && xml_spec_match_equal(without_regex, expected_without_regex)
}

// Ruby it `it "errors if a block is not provided" do` at line 245.
pub fn ruby_xml_spec_l245_d33_errors() bool {
	xml_core.ruby_xml_l147_d5_self_find_versions(xml_core.XmlFindVersionsRequest{
		url: ruby_xml_spec_l11_d2_http_url()
		content: ruby_xml_spec_l66_d7_content_simple()
	}, xml_spec_unused_fetcher) or {
		return err.msg() == 'Xml requires a `strategy` block'
	}
	return false
}

// Ruby it `it "returns default match_data when url is blank" do` at line 250.
pub fn ruby_xml_spec_l250_d34_returns() bool {
	actual := xml_core.ruby_xml_l147_d5_self_find_versions(xml_spec_find_request('', ruby_xml_spec_l66_d7_content_simple(), xml_spec_regex(), xml_spec_simple_block, 1), xml_spec_unused_fetcher) or { return false }
	expected := ruby_xml_spec_l208_d30_match_data()['cached_default']
	expected_blank := xml_core.XmlMatchData{ ...expected, url: '' }
	return xml_spec_match_equal(actual, expected_blank)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 255.
pub fn ruby_xml_spec_l255_d35_returns() bool {
	actual := xml_core.ruby_xml_l147_d5_self_find_versions(xml_spec_find_request(ruby_xml_spec_l11_d2_http_url(), '', xml_spec_regex(), xml_spec_simple_block, 1), xml_spec_unused_fetcher) or {
		return false
	}
	return xml_spec_match_equal(actual, ruby_xml_spec_l208_d30_match_data()['cached_default'])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5: require "rexml/document"
// 6: require "rexml/undefinednamespaceexception"
// 7:
// 8: RSpec.describe Homebrew::Livecheck::Strategy::Xml do
// 9:   subject(:xml) { described_class }
// 10:
// 11:   let(:http_url) { "https://brew.sh/blog/" }
// 12:   let(:non_http_url) { "ftp://brew.sh/" }
// 13:   let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 14:   let(:content_version_text) do
// 15:     <<~XML
// 16:       <?xml version="1.0" encoding="utf-8"?>
// 17:       <versions>
// 18:         <version>1.1.2</version>
// 19:         <version>1.1.2b</version>
// 20:         <version>1.1.2a</version>
// 21:         <version>1.1.1</version>
// 22:         <version>1.1.0</version>
// 23:         <version>1.1.0-rc3</version>
// 24:         <version>1.1.0-rc2</version>
// 25:         <version>1.1.0-rc1</version>
// 26:         <version>1.0.x-last</version>
// 27:         <version>1.0.3</version>
// 28:         <version>1.0.3-rc3</version>
// 29:         <version>1.0.3-rc2</version>
// 30:         <version>1.0.3-rc1</version>
// 31:         <version>1.0.2</version>
// 32:         <version>1.0.2-rc1</version>
// 33:         <version>1.0.1</version>
// 34:         <version>1.0.1-rc1</version>
// 35:         <version>1.0.0</version>
// 36:         <version>1.0.0-rc1</version>
// 37:       </versions>
// 38:     XML
// 39:   end
// 40:   let(:content_version_attr) do
// 41:     <<~XML
// 42:       <?xml version="1.0" encoding="utf-8"?>
// 43:       <items>
// 44:         <item version="1.1.2" />
// 45:         <item version="1.1.2b" />
// 46:         <item version="1.1.2a" />
// 47:         <item version="1.1.1" />
// 48:         <item version="1.1.0" />
// 49:         <item version="1.1.0-rc3" />
// 50:         <item version="1.1.0-rc2" />
// 51:         <item version="1.1.0-rc1" />
// 52:         <item version="1.0.x-last" />
// 53:         <item version="1.0.3" />
// 54:         <item version="1.0.3-rc3" />
// 55:         <item version="1.0.3-rc2" />
// 56:         <item version="1.0.3-rc1" />
// 57:         <item version="1.0.2" />
// 58:         <item version="1.0.2-rc1" />
// 59:         <item version="1.0.1" />
// 60:         <item version="1.0.1-rc1" />
// 61:         <item version="1.0.0" />
// 62:         <item version="1.0.0-rc1" />
// 63:       </items>
// 64:     XML
// 65:   end
// 66:   let(:content_simple) do
// 67:     <<~XML
// 68:       <?xml version="1.0" encoding="utf-8"?>
// 69:       <version>1.2.3</version>
// 70:     XML
// 71:   end
// 72:   let(:content_undefined_namespace) do
// 73:     <<~XML
// 74:       <?xml version="1.0" encoding="utf-8"?>
// 75:       <something:version>1.2.3</something:version>
// 76:     XML
// 77:   end
// 78:   let(:parent_child_text) { { parent: "1.2.3", child: "4.5.6" } }
// 79:   let(:content_parent_child) do
// 80:     # This XML deliberately includes unnecessary whitespace, to ensure that
// 81:     # Xml#element_text properly strips the retrieved text.
// 82:     <<~XML
// 83:       <?xml version="1.0" encoding="utf-8"?>
// 84:       <elements>
// 85:         <parent>
// 86:           #{parent_child_text[:parent]}
// 87:           <child> #{parent_child_text[:child]} </child>
// 88:         </parent>
// 89:         <blank-parent>
// 90:           <blank-child></blank-child>
// 91:         </blank-parent>
// 92:       </elements>
// 93:     XML
// 94:   end
// 95:   let(:matches) do
// 96:     {
// 97:       content: ["1.1.2", "1.1.1", "1.1.0", "1.0.3", "1.0.2", "1.0.1", "1.0.0"],
// 98:       simple:  ["1.2.3"],
// 99:     }
// 100:   end
// 101:
// 102:   describe "::match?" do
// 103:     it "returns true for an HTTP URL" do
// 104:       expect(xml.match?(http_url)).to be true
// 105:     end
// 106:
// 107:     it "returns false for a non-HTTP URL" do
// 108:       expect(xml.match?(non_http_url)).to be false
// 109:     end
// 110:   end
// 111:
// 112:   describe "::parse_xml" do
// 113:     # TODO: Should we be comparing against an actual REXML::Document object?
// 114:     it "returns an REXML::Document when given XML content" do
// 115:       expect(xml.parse_xml(content_version_text)).to be_an_instance_of(REXML::Document)
// 116:     end
// 117:
// 118:     it "returns an REXML::Document when given XML content with an undefined namespace" do
// 119:       expect(xml.parse_xml(content_undefined_namespace)).to be_an_instance_of(REXML::Document)
// 120:     end
// 121:
// 122:     it "errors if an undefined prefix name is not provided in the UndefinedNamespaceException" do
// 123:       allow(REXML::Document).to receive(:new).and_raise(REXML::UndefinedNamespaceException.new(nil, nil, nil))
// 124:
// 125:       expect { xml.parse_xml(content_undefined_namespace) }
// 126:         .to raise_error("Could not identify undefined prefix.")
// 127:     end
// 128:
// 129:     it "errors if XML cannot be parsed after removing undefined prefix" do
// 130:       allow(REXML::Document).to receive(:new).and_raise(REXML::UndefinedNamespaceException.new("something", nil, nil))
// 131:
// 132:       expect { xml.parse_xml(content_undefined_namespace) }
// 133:         .to raise_error("Could not parse XML after removing undefined prefix.")
// 134:     end
// 135:   end
// 136:
// 137:   describe "::element_text" do
// 138:     let(:parent_child_doc) { xml.parse_xml(content_parent_child) }
// 139:     let(:parent) { parent_child_doc.get_elements("/elements/parent").first }
// 140:     let(:blank_parent) { parent_child_doc.get_elements("/elements/blank-parent").first }
// 141:
// 142:     it "returns the element text if child_name is not provided" do
// 143:       expect(xml.element_text(parent)).to eq(parent_child_text[:parent])
// 144:     end
// 145:
// 146:     it "returns the child element text if child_name is provided" do
// 147:       expect(xml.element_text(parent, "child")).to eq(parent_child_text[:child])
// 148:     end
// 149:
// 150:     it "returns `nil` if the provided child element does not exist" do
// 151:       expect(xml.element_text(parent, "nonexistent")).to be_nil
// 152:     end
// 153:
// 154:     it "returns `nil` if the retrieved text is blank" do
// 155:       expect(xml.element_text(blank_parent)).to be_nil
// 156:       expect(xml.element_text(blank_parent, "blank-child")).to be_nil
// 157:     end
// 158:   end
// 159:
// 160:   describe "::versions_from_content" do
// 161:     it "returns an empty array when given a block but content is blank" do
// 162:       expect(xml.versions_from_content("", regex) { "1.2.3" }).to eq([])
// 163:     end
// 164:
// 165:     it "returns an array of version strings when given content and a block" do
// 166:       # Returning a string from block
// 167:       expect(xml.versions_from_content(content_simple) do |xml|
// 168:         xml.elements["version"]&.text
// 169:       end).to eq(matches[:simple])
// 170:       expect(xml.versions_from_content(content_simple, regex) do |xml|
// 171:         version = xml.elements["version"]&.text
// 172:         next if version.blank?
// 173:
// 174:         version[regex, 1]
// 175:       end).to eq(matches[:simple])
// 176:
// 177:       # Returning an array of strings from block
// 178:       expect(xml.versions_from_content(content_version_text, regex) do |xml, regex|
// 179:         xml.get_elements("/versions/version").map { |item| item.text[regex, 1] }
// 180:       end).to eq(matches[:content])
// 181:
// 182:       expect(xml.versions_from_content(content_version_attr, regex) do |xml, regex|
// 183:         xml.get_elements("/items/item").map do |item|
// 184:           version = item["version"]
// 185:           next if version.blank?
// 186:
// 187:           version[regex, 1]
// 188:         end
// 189:       end).to eq(matches[:content])
// 190:     end
// 191:
// 192:     it "allows a nil return from a block" do
// 193:       expect(xml.versions_from_content(content_simple, regex) { next }).to eq([])
// 194:     end
// 195:
// 196:     it "errors if a block uses two arguments but a regex is not given" do
// 197:       expect { xml.versions_from_content(content_simple) { |xml, regex| xml["version"][regex, 1] } }
// 198:         .to raise_error("Two arguments found in `strategy` block but no regex provided.")
// 199:     end
// 200:
// 201:     it "errors on an invalid return type from a block" do
// 202:       expect { xml.versions_from_content(content_simple, regex) { 123 } }
// 203:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 204:     end
// 205:   end
// 206:
// 207:   describe "::find_versions" do
// 208:     let(:match_data) do
// 209:       base = {
// 210:         matches: matches[:content].to_h { |v| [v, Version.new(v)] },
// 211:         regex:,
// 212:         url:     http_url,
// 213:       }
// 214:
// 215:       {
// 216:         fetched:        base.merge({ content: content_version_text }),
// 217:         cached:         base.merge({ cached: true }),
// 218:         cached_default: base.merge({ matches: {}, cached: true }),
// 219:       }
// 220:     end
// 221:
// 222:     it "finds versions in fetched content" do
// 223:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: content_version_text })
// 224:
// 225:       expect(xml.find_versions(url: http_url, regex:) do |xml, regex|
// 226:         xml.get_elements("/versions/version").map { |item| item.text[regex, 1] }
// 227:       end).to eq(match_data[:fetched])
// 228:     end
// 229:
// 230:     it "finds versions in content using a block" do
// 231:       expect(xml.find_versions(url: http_url, regex:, content: content_version_text) do |xml, regex|
// 232:         xml.get_elements("/versions/version").map { |item| item.text[regex, 1] }
// 233:       end).to eq(match_data[:cached])
// 234:
// 235:       # NOTE: A regex should be provided using the `#regex` method in a
// 236:       #       `livecheck` block but we're using a regex literal in the
// 237:       #       `strategy` block here simply to ensure this method works as
// 238:       #       expected when a regex isn't provided.
// 239:       expect(xml.find_versions(url: http_url, content: content_version_text) do |xml|
// 240:         regex = /^v?(\d+(?:\.\d+)+)$/i
// 241:         xml.get_elements("/versions/version").map { |item| item.text[regex, 1] }
// 242:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 243:     end
// 244:
// 245:     it "errors if a block is not provided" do
// 246:       expect { xml.find_versions(url: http_url, content: content_simple) }
// 247:         .to raise_error(ArgumentError, "Xml requires a `strategy` block")
// 248:     end
// 249:
// 250:     it "returns default match_data when url is blank" do
// 251:       expect(xml.find_versions(url: "", regex:, content: content_simple) { "1.2.3" })
// 252:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 253:     end
// 254:
// 255:     it "returns default match_data when content is blank" do
// 256:       expect(xml.find_versions(url: http_url, regex:, content: "") { "1.2.3" })
// 257:         .to eq(match_data[:cached_default])
// 258:     end
// 259:   end
// 260: end
