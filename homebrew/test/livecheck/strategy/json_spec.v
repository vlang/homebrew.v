module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as json_core
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `test/livecheck/strategy/json_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct JsonSpecMatches {
pub:
	content []string
	simple  []string
}

pub struct JsonSpecMatchData {
pub:
	fetched        json_core.JsonMatchData
	cached         json_core.JsonMatchData
	cached_default json_core.JsonMatchData
}

fn json_spec_block_value(value string) livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: value
	}
}

fn json_spec_block_values(values []string) livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .array
		values: values.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn json_spec_capture(value string, provided json_core.JsonRegex) ?string {
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

fn json_spec_simple_block(document json2.Any,
	_ ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	values := document.as_map()
	version := (values['version'] or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}).str()
	return json_spec_block_value(version)
}

fn json_spec_simple_regex_block(document json2.Any,
	_ ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	values := document.as_map()
	version := (values['version'] or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}).str()
	capture := json_spec_capture(version, ruby_json_spec_l11_d4_regex()) or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}
	return json_spec_block_value(capture)
}

fn json_spec_versions_block(document json2.Any,
	provided ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	regex_value := provided or { ruby_json_spec_l11_d4_regex() }
	root := document.as_map()
	items := (root['versions'] or { return json_spec_block_values([]) }).as_array()
	mut versions := []string{}
	for item in items {
		value := item.as_map()['version'] or { continue }
		if capture := json_spec_capture(value.str(), regex_value) {
			versions << capture
		}
	}
	return json_spec_block_values(versions)
}

fn json_spec_constant_block(_ json2.Any,
	_ ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	return json_spec_block_value('1.2.3')
}

fn json_spec_nil_block(_ json2.Any, _ ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

fn json_spec_invalid_block(_ json2.Any,
	_ ?json_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{ kind: .invalid }
}

fn json_spec_fetched(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${ruby_json_spec_l12_d5_content()}'
		exit_status: 0
	}
}

fn json_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached JSON content unexpectedly fetched')
}

fn json_spec_matches_map(values []string) map[string]string {
	mut matches := map[string]string{}
	for value in values {
		matches[value] = value
	}
	return matches
}

fn json_spec_regex_equal(left ?json_core.JsonRegex, right ?json_core.JsonRegex) bool {
	left_value := left or { json_core.JsonRegex{} }
	right_value := right or { json_core.JsonRegex{} }
	return left_value == right_value
}

fn json_spec_match_data_equal(left json_core.JsonMatchData,
	right json_core.JsonMatchData) bool {
	return left.matches == right.matches && json_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:json) { described_class }` at line 7.
pub fn ruby_json_spec_l7_d1_json() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Json')
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 9.
pub fn ruby_json_spec_l9_d2_http_url() string {
	return 'https://brew.sh/blog/'
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_json_spec_l10_d3_non_http_url() string {
	return 'ftp://brew.sh/'
}

// Ruby let `let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 11.
pub fn ruby_json_spec_l11_d4_regex() json_core.JsonRegex {
	return json_core.JsonRegex{
		pattern: r'^v?(\d+(?:\.\d+)+)$'
		case_insensitive: true
	}
}

// Ruby let `let(:content) do` at line 12.
pub fn ruby_json_spec_l12_d5_content() string {
	return '{\n  "versions": [\n    { "version": "1.1.2" },\n    { "version": "1.1.2b" },\n    { "version": "1.1.2a" },\n    { "version": "1.1.1" },\n    { "version": "1.1.0" },\n    { "version": "1.1.0-rc3" },\n    { "version": "1.1.0-rc2" },\n    { "version": "1.1.0-rc1" },\n    { "version": "1.0.x-last" },\n    { "version": "1.0.3" },\n    { "version": "1.0.3-rc3" },\n    { "version": "1.0.3-rc2" },\n    { "version": "1.0.3-rc1" },\n    { "version": "1.0.2" },\n    { "version": "1.0.2-rc1" },\n    { "version": "1.0.1" },\n    { "version": "1.0.1-rc1" },\n    { "version": "1.0.0" },\n    { "version": "1.0.0-rc1" },\n    { "other": "version is omitted from this object for testing" }\n  ]\n}\n'
}

// Ruby let `let(:content_simple) { '{"version":"1.2.3"}' }` at line 40.
pub fn ruby_json_spec_l40_d6_content_simple() string {
	return '{"version":"1.2.3"}'
}

// Ruby let `let(:matches) do` at line 41.
pub fn ruby_json_spec_l41_d7_matches() JsonSpecMatches {
	return JsonSpecMatches{
		content: ['1.1.2', '1.1.1', '1.1.0', '1.0.3', '1.0.2', '1.0.1', '1.0.0']
		simple: ['1.2.3']
	}
}

// Ruby it `it "returns true for an HTTP URL" do` at line 49.
pub fn ruby_json_spec_l49_d8_returns() bool {
	return json_core.json_matches(ruby_json_spec_l9_d2_http_url())
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 53.
pub fn ruby_json_spec_l53_d9_returns() bool {
	return !json_core.json_matches(ruby_json_spec_l10_d3_non_http_url())
}

// Ruby it `it "returns an object when given valid content" do` at line 59.
pub fn ruby_json_spec_l59_d10_returns() bool {
	value := json_core.json_parse_json(ruby_json_spec_l40_d6_content_simple()) or { return false }
	return value is map[string]json2.Any
}

// Ruby it `it "returns an empty array when given a block but content is blank" do` at line 65.
pub fn ruby_json_spec_l65_d11_returns() bool {
	versions := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 1
		block: json_spec_constant_block
	}) or { return false }
	return versions.len == 0
}

// Ruby it `it "errors if provided content is not valid JSON" do` at line 69.
pub fn ruby_json_spec_l69_d12_errors() bool {
	if _ := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: 'not valid JSON'
		has_block: true
		block_arity: 1
		block: json_spec_nil_block
	}) {
		return false
	} else {
		return err.msg() == 'Content could not be parsed as JSON.'
	}
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 74.
pub fn ruby_json_spec_l74_d13_returns() bool {
	matches := ruby_json_spec_l41_d7_matches()
	plain := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: ruby_json_spec_l40_d6_content_simple()
		has_block: true
		block_arity: 1
		block: json_spec_simple_block
	}) or { return false }
	regex_simple := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: ruby_json_spec_l40_d6_content_simple()
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 1
		block: json_spec_simple_regex_block
	}) or { return false }
	content_versions := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: ruby_json_spec_l12_d5_content()
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 2
		block: json_spec_versions_block
	}) or { return false }
	return plain == matches.simple && regex_simple == matches.simple && content_versions == matches.content
}

// Ruby it `it "allows a nil return from a block" do` at line 88.
pub fn ruby_json_spec_l88_d14_allows() bool {
	versions := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: ruby_json_spec_l40_d6_content_simple()
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 1
		block: json_spec_nil_block
	}) or { return false }
	return versions.len == 0
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 92.
pub fn ruby_json_spec_l92_d15_errors() bool {
	if _ := json_core.json_versions_from_content(json_core.JsonVersionsRequest{
		content: ruby_json_spec_l40_d6_content_simple()
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 1
		block: json_spec_invalid_block
	}) {
		return false
	} else {
		return err.msg() == 'Return value of a strategy block must be a string or array of strings.'
	}
}

// Ruby let `let(:match_data) do` at line 99.
pub fn ruby_json_spec_l99_d16_match_data() JsonSpecMatchData {
	url := ruby_json_spec_l9_d2_http_url()
	provided_regex := ruby_json_spec_l11_d4_regex()
	matches := json_spec_matches_map(ruby_json_spec_l41_d7_matches().content)
	return JsonSpecMatchData{
		fetched: json_core.JsonMatchData{
			matches: matches
			regex: provided_regex
			url: url
			content: ruby_json_spec_l12_d5_content()
			has_content: true
		}
		cached: json_core.JsonMatchData{
			matches: matches
			regex: provided_regex
			url: url
			cached: true
			has_cached: true
		}
		cached_default: json_core.JsonMatchData{
			matches: map[string]string{}
			regex: provided_regex
			url: url
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 113.
pub fn ruby_json_spec_l113_d17_finds() bool {
	actual := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: ruby_json_spec_l9_d2_http_url()
		regex: ruby_json_spec_l11_d4_regex()
		has_block: true
		block_arity: 2
		block: json_spec_versions_block
	}, json_spec_fetched) or { return false }
	return json_spec_match_data_equal(actual, ruby_json_spec_l99_d16_match_data().fetched)
}

// Ruby it `it "finds versions in content using a block" do` at line 122.
pub fn ruby_json_spec_l122_d18_finds() bool {
	url := ruby_json_spec_l9_d2_http_url()
	content := ruby_json_spec_l12_d5_content()
	with_regex := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: url
		regex: ruby_json_spec_l11_d4_regex()
		content: content
		has_block: true
		block_arity: 2
		block: json_spec_versions_block
	}, json_spec_unused_fetcher) or { return false }
	without_regex := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: url
		content: content
		has_block: true
		block_arity: 1
		block: json_spec_versions_block
	}, json_spec_unused_fetcher) or { return false }
	expected := ruby_json_spec_l99_d16_match_data().cached
	return json_spec_match_data_equal(with_regex, expected) && json_spec_match_data_equal(without_regex, json_core.JsonMatchData{
		...expected
		regex: none
	})
}

// Ruby it `it "errors if a block is not provided" do` at line 139.
pub fn ruby_json_spec_l139_d19_errors() bool {
	if _ := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: ruby_json_spec_l9_d2_http_url()
		content: ruby_json_spec_l12_d5_content()
	}, json_spec_unused_fetcher) {
		return false
	} else {
		return err.msg() == 'Json requires a `strategy` block'
	}
}

// Ruby it `it "returns default match_data when url is blank" do` at line 144.
pub fn ruby_json_spec_l144_d20_returns() bool {
	actual := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: ''
		regex: ruby_json_spec_l11_d4_regex()
		content: ruby_json_spec_l12_d5_content()
		has_block: true
		block_arity: 1
		block: json_spec_constant_block
	}, json_spec_unused_fetcher) or { return false }
	expected := json_core.JsonMatchData{
		...ruby_json_spec_l99_d16_match_data().cached_default
		url: ''
	}
	return json_spec_match_data_equal(actual, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 149.
pub fn ruby_json_spec_l149_d21_returns() bool {
	actual := json_core.json_find_versions(json_core.JsonFindVersionsRequest{
		url: ruby_json_spec_l9_d2_http_url()
		regex: ruby_json_spec_l11_d4_regex()
		content: ''
		has_block: true
		block_arity: 1
		block: json_spec_constant_block
	}, json_spec_unused_fetcher) or { return false }
	return json_spec_match_data_equal(actual, ruby_json_spec_l99_d16_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Json do
// 7:   subject(:json) { described_class }
// 8:
// 9:   let(:http_url) { "https://brew.sh/blog/" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 12:   let(:content) do
// 13:     <<~JSON
// 14:       {
// 15:         "versions": [
// 16:           { "version": "1.1.2" },
// 17:           { "version": "1.1.2b" },
// 18:           { "version": "1.1.2a" },
// 19:           { "version": "1.1.1" },
// 20:           { "version": "1.1.0" },
// 21:           { "version": "1.1.0-rc3" },
// 22:           { "version": "1.1.0-rc2" },
// 23:           { "version": "1.1.0-rc1" },
// 24:           { "version": "1.0.x-last" },
// 25:           { "version": "1.0.3" },
// 26:           { "version": "1.0.3-rc3" },
// 27:           { "version": "1.0.3-rc2" },
// 28:           { "version": "1.0.3-rc1" },
// 29:           { "version": "1.0.2" },
// 30:           { "version": "1.0.2-rc1" },
// 31:           { "version": "1.0.1" },
// 32:           { "version": "1.0.1-rc1" },
// 33:           { "version": "1.0.0" },
// 34:           { "version": "1.0.0-rc1" },
// 35:           { "other": "version is omitted from this object for testing" }
// 36:         ]
// 37:       }
// 38:     JSON
// 39:   end
// 40:   let(:content_simple) { '{"version":"1.2.3"}' }
// 41:   let(:matches) do
// 42:     {
// 43:       content: ["1.1.2", "1.1.1", "1.1.0", "1.0.3", "1.0.2", "1.0.1", "1.0.0"],
// 44:       simple:  ["1.2.3"],
// 45:     }
// 46:   end
// 47:
// 48:   describe "::match?" do
// 49:     it "returns true for an HTTP URL" do
// 50:       expect(json.match?(http_url)).to be true
// 51:     end
// 52:
// 53:     it "returns false for a non-HTTP URL" do
// 54:       expect(json.match?(non_http_url)).to be false
// 55:     end
// 56:   end
// 57:
// 58:   describe "::parse_json" do
// 59:     it "returns an object when given valid content" do
// 60:       expect(json.parse_json(content_simple)).to be_an_instance_of(Hash)
// 61:     end
// 62:   end
// 63:
// 64:   describe "::versions_from_content" do
// 65:     it "returns an empty array when given a block but content is blank" do
// 66:       expect(json.versions_from_content("", regex) { "1.2.3" }).to eq([])
// 67:     end
// 68:
// 69:     it "errors if provided content is not valid JSON" do
// 70:       expect { json.versions_from_content("not valid JSON") { [] } }
// 71:         .to raise_error(RuntimeError, "Content could not be parsed as JSON.")
// 72:     end
// 73:
// 74:     it "returns an array of version strings when given content and a block" do
// 75:       # Returning a string from block
// 76:       expect(json.versions_from_content(content_simple) { |json| json["version"] }).to eq(matches[:simple])
// 77:       expect(json.versions_from_content(content_simple, regex) do |json|
// 78:         json["version"][regex, 1]
// 79:       end).to eq(matches[:simple])
// 80:
// 81:       # Returning an array of strings from block
// 82:       expect(json.versions_from_content(content, regex) do |json, regex|
// 83:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 84:                         .map { |item| item["version"][regex, 1] }
// 85:       end).to eq(matches[:content])
// 86:     end
// 87:
// 88:     it "allows a nil return from a block" do
// 89:       expect(json.versions_from_content(content_simple, regex) { next }).to eq([])
// 90:     end
// 91:
// 92:     it "errors on an invalid return type from a block" do
// 93:       expect { json.versions_from_content(content_simple, regex) { 123 } }
// 94:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 95:     end
// 96:   end
// 97:
// 98:   describe "::find_versions" do
// 99:     let(:match_data) do
// 100:       base = {
// 101:         matches: matches[:content].to_h { |v| [v, Version.new(v)] },
// 102:         regex:,
// 103:         url:     http_url,
// 104:       }
// 105:
// 106:       {
// 107:         fetched:        base.merge({ content: }),
// 108:         cached:         base.merge({ cached: true }),
// 109:         cached_default: base.merge({ matches: {}, cached: true }),
// 110:       }
// 111:     end
// 112:
// 113:     it "finds versions in fetched content" do
// 114:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 115:
// 116:       expect(json.find_versions(url: http_url, regex:) do |json, regex|
// 117:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 118:                         .map { |item| item["version"][regex, 1] }
// 119:       end).to eq(match_data[:fetched])
// 120:     end
// 121:
// 122:     it "finds versions in content using a block" do
// 123:       expect(json.find_versions(url: http_url, regex:, content:) do |json, regex|
// 124:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 125:                         .map { |item| item["version"][regex, 1] }
// 126:       end).to eq(match_data[:cached])
// 127:
// 128:       # NOTE: A regex should be provided using the `#regex` method in a
// 129:       #       `livecheck` block but we're using a regex literal in the
// 130:       #       `strategy` block here simply to ensure this method works as
// 131:       #       expected when a regex isn't provided.
// 132:       expect(json.find_versions(url: http_url, content:) do |json|
// 133:         regex = /^v?(\d+(?:\.\d+)+)$/i
// 134:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 135:                         .map { |item| item["version"][regex, 1] }
// 136:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 137:     end
// 138:
// 139:     it "errors if a block is not provided" do
// 140:       expect { json.find_versions(url: http_url, content:) }
// 141:         .to raise_error(ArgumentError, "Json requires a `strategy` block")
// 142:     end
// 143:
// 144:     it "returns default match_data when url is blank" do
// 145:       expect(json.find_versions(url: "", regex:, content:) { "1.2.3" })
// 146:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 147:     end
// 148:
// 149:     it "returns default match_data when content is blank" do
// 150:       expect(json.find_versions(url: http_url, regex:, content: "") { "1.2.3" })
// 151:         .to eq(match_data[:cached_default])
// 152:     end
// 153:   end
// 154: end
