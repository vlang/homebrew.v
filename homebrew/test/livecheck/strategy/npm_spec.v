module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as npm_core
import homebrew.utils
import x.json2

// NpmSpecMatchData translates the three expected `find_versions` hashes.
pub struct NpmSpecMatchData {
pub:
	fetched        npm_core.JsonMatchData
	cached         npm_core.JsonMatchData
	cached_default npm_core.JsonMatchData
}

fn npm_spec_url(name string) string {
	return match name {
		'typical' { 'https://registry.npmjs.org/abc/-/def-1.2.3.tgz' }
		'org_scoped' { 'https://registry.npmjs.org/@example/abc/-/def-1.2.3.tgz' }
		else { '' }
	}
}

fn npm_spec_content() string {
	return '{\n  "name": "example",\n  "version": "1.2.3"\n}\n'
}

fn npm_spec_version_block(document json2.Any,
	_ ?npm_core.JsonRegex) !livecheck.StrategyBlockValue {
	if document is map[string]json2.Any {
		version := document['version'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if version is string {
			return livecheck.StrategyBlockValue{
				kind: .string_value
				value: version
			}
		}
	}
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

fn npm_spec_missing_block(_ json2.Any,
	_ ?npm_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

fn npm_spec_constant_block(_ json2.Any,
	_ ?npm_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: '1.2.3'
	}
}

fn npm_spec_fetched(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${npm_spec_content()}'
		exit_status: 0
	}
}

fn npm_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached npm content unexpectedly fetched')
}

fn npm_spec_regex_equal(left ?npm_core.JsonRegex, right ?npm_core.JsonRegex) bool {
	left_value := left or { npm_core.JsonRegex{} }
	right_value := right or { npm_core.JsonRegex{} }
	return left_value == right_value
}

fn npm_spec_match_data_equal(left npm_core.JsonMatchData,
	right npm_core.JsonMatchData) bool {
	return left.matches == right.matches && npm_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Translated from Homebrew/brew `test/livecheck/strategy/npm_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:npm) { described_class }` at line 7.
pub fn ruby_npm_spec_l7_d1_npm() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Npm')
}

// Ruby let `let(:npm_urls) do` at line 9.
pub fn ruby_npm_spec_l9_d2_npm_urls() map[string]string {
	return {
		'typical':    npm_spec_url('typical')
		'org_scoped': npm_spec_url('org_scoped')
	}
}

// Ruby let `let(:non_npm_url) { "https://brew.sh/test" }` at line 15.
pub fn ruby_npm_spec_l15_d3_non_npm_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 16.
pub fn ruby_npm_spec_l16_d4_generated() map[string]npm_core.NpmInputValues {
	return {
		'typical':    npm_core.NpmInputValues{
			present: true
			url: 'https://registry.npmjs.org/abc/latest'
		}
		'org_scoped': npm_core.NpmInputValues{
			present: true
			url: 'https://registry.npmjs.org/%40example%2Fabc/latest'
		}
	}
}

// Ruby let `let(:content) do` at line 28.
pub fn ruby_npm_spec_l28_d5_content() string {
	return npm_spec_content()
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 36.
pub fn ruby_npm_spec_l36_d6_matches() []string {
	return ['1.2.3']
}

// Ruby it `it "returns true for an npm URL" do` at line 39.
pub fn ruby_npm_spec_l39_d7_returns() bool {
	return npm_core.npm_matches_url(npm_spec_url('typical')) && npm_core.npm_matches_url(npm_spec_url('org_scoped'))
}

// Ruby it `it "returns false for a non-npm URL" do` at line 44.
pub fn ruby_npm_spec_l44_d8_returns() bool {
	return !npm_core.npm_matches_url(ruby_npm_spec_l15_d3_non_npm_url())
}

// Ruby it `it "returns a hash containing url and regex for an npm URL" do` at line 50.
pub fn ruby_npm_spec_l50_d9_returns() bool {
	expected := ruby_npm_spec_l16_d4_generated()
	return npm_core.npm_generate_input_values(npm_spec_url('typical')) == expected['typical'] && npm_core.npm_generate_input_values(npm_spec_url('org_scoped')) == expected['org_scoped']
}

// Ruby it `it "returns an empty hash for a non-npm URL" do` at line 55.
pub fn ruby_npm_spec_l55_d10_returns() bool {
	return !npm_core.npm_generate_input_values(ruby_npm_spec_l15_d3_non_npm_url()).present
}

// Ruby let `let(:match_data) do` at line 61.
pub fn ruby_npm_spec_l61_d11_match_data() NpmSpecMatchData {
	url := ruby_npm_spec_l16_d4_generated()['typical'].url
	matches := {
		'1.2.3': '1.2.3'
	}
	return NpmSpecMatchData{
		fetched: npm_core.JsonMatchData{
			matches: matches
			url: url
			content: npm_spec_content()
			has_content: true
		}
		cached: npm_core.JsonMatchData{
			matches: matches
			url: url
			cached: true
			has_cached: true
		}
		cached_default: npm_core.JsonMatchData{
			matches: map[string]string{}
			url: url
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 75.
pub fn ruby_npm_spec_l75_d12_finds() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		url: npm_spec_url('typical')
	}, npm_spec_fetched) or { return false }
	return npm_spec_match_data_equal(actual, ruby_npm_spec_l61_d11_match_data().fetched)
}

// Ruby it `it "finds versions in provided content" do` at line 82.
pub fn ruby_npm_spec_l82_d13_finds() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		url: npm_spec_url('typical')
		content: npm_spec_content()
	}, npm_spec_unused_fetcher) or { return false }
	return npm_spec_match_data_equal(actual, ruby_npm_spec_l61_d11_match_data().cached)
}

// Ruby it `it "finds versions in provided content using a block" do` at line 87.
pub fn ruby_npm_spec_l87_d14_finds() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		url: npm_spec_url('typical')
		content: npm_spec_content()
		has_block: true
		block_arity: 1
		block: npm_spec_version_block
	}, npm_spec_unused_fetcher) or { return false }
	return npm_spec_match_data_equal(actual, ruby_npm_spec_l61_d11_match_data().cached)
}

// Ruby it `it "returns default match_data when block doesn't return version information" do` at line 95.
pub fn ruby_npm_spec_l95_d15_returns() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		url: npm_spec_url('typical')
		content: npm_spec_content()
		has_block: true
		block_arity: 1
		block: npm_spec_missing_block
	}, npm_spec_unused_fetcher) or { return false }
	return npm_spec_match_data_equal(actual, ruby_npm_spec_l61_d11_match_data().cached_default)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 101.
pub fn ruby_npm_spec_l101_d16_returns() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		has_block: true
		block_arity: 1
		block: npm_spec_constant_block
	}, npm_spec_unused_fetcher) or { return false }
	return npm_spec_match_data_equal(actual, npm_core.JsonMatchData{
		matches: map[string]string{}
	})
}

// Ruby it `it "returns default match_data when content is blank" do` at line 106.
pub fn ruby_npm_spec_l106_d17_returns() bool {
	actual := npm_core.npm_find_versions(npm_core.NpmFindRequest{
		url: npm_spec_url('typical')
		content: ''
	}, npm_spec_unused_fetcher) or { return false }
	return npm_spec_match_data_equal(actual, ruby_npm_spec_l61_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Npm do
// 7:   subject(:npm) { described_class }
// 8:
// 9:   let(:npm_urls) do
// 10:     {
// 11:       typical:    "https://registry.npmjs.org/abc/-/def-1.2.3.tgz",
// 12:       org_scoped: "https://registry.npmjs.org/@example/abc/-/def-1.2.3.tgz",
// 13:     }
// 14:   end
// 15:   let(:non_npm_url) { "https://brew.sh/test" }
// 16:   let(:generated) do
// 17:     {
// 18:       typical:    {
// 19:         url: "https://registry.npmjs.org/abc/latest",
// 20:       },
// 21:       org_scoped: {
// 22:         url: "https://registry.npmjs.org/%40example%2Fabc/latest",
// 23:       },
// 24:     }
// 25:   end
// 26:   # This is a limited subset of a `latest` response object, for the sake of
// 27:   # testing.
// 28:   let(:content) do
// 29:     <<~JSON
// 30:       {
// 31:         "name": "example",
// 32:         "version": "1.2.3"
// 33:       }
// 34:     JSON
// 35:   end
// 36:   let(:matches) { ["1.2.3"] }
// 37:
// 38:   describe "::match?" do
// 39:     it "returns true for an npm URL" do
// 40:       expect(npm.match?(npm_urls[:typical])).to be true
// 41:       expect(npm.match?(npm_urls[:org_scoped])).to be true
// 42:     end
// 43:
// 44:     it "returns false for a non-npm URL" do
// 45:       expect(npm.match?(non_npm_url)).to be false
// 46:     end
// 47:   end
// 48:
// 49:   describe "::generate_input_values" do
// 50:     it "returns a hash containing url and regex for an npm URL" do
// 51:       expect(npm.generate_input_values(npm_urls[:typical])).to eq(generated[:typical])
// 52:       expect(npm.generate_input_values(npm_urls[:org_scoped])).to eq(generated[:org_scoped])
// 53:     end
// 54:
// 55:     it "returns an empty hash for a non-npm URL" do
// 56:       expect(npm.generate_input_values(non_npm_url)).to eq({})
// 57:     end
// 58:   end
// 59:
// 60:   describe "::find_versions" do
// 61:     let(:match_data) do
// 62:       base = {
// 63:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 64:         regex:   nil,
// 65:         url:     generated[:typical][:url],
// 66:       }
// 67:
// 68:       {
// 69:         fetched:        base.merge({ content: }),
// 70:         cached:         base.merge({ cached: true }),
// 71:         cached_default: base.merge({ matches: {}, cached: true }),
// 72:       }
// 73:     end
// 74:
// 75:     it "finds versions in fetched content" do
// 76:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 77:
// 78:       expect(npm.find_versions(url: npm_urls[:typical]))
// 79:         .to eq(match_data[:fetched])
// 80:     end
// 81:
// 82:     it "finds versions in provided content" do
// 83:       expect(npm.find_versions(url: npm_urls[:typical], content:))
// 84:         .to eq(match_data[:cached])
// 85:     end
// 86:
// 87:     it "finds versions in provided content using a block" do
// 88:       # This `strategy` block is unnecessary but it's only intended to test
// 89:       # using a provided `strategy` block.
// 90:       expect(npm.find_versions(url: npm_urls[:typical], content:) do |json|
// 91:         json["version"]
// 92:       end).to eq(match_data[:cached])
// 93:     end
// 94:
// 95:     it "returns default match_data when block doesn't return version information" do
// 96:       expect(npm.find_versions(url: npm_urls[:typical], content:) do |json|
// 97:         json["nonexistentValue"]
// 98:       end).to eq(match_data[:cached_default])
// 99:     end
// 100:
// 101:     it "returns default match_data when url is blank" do
// 102:       expect(npm.find_versions(url: "") { "1.2.3" })
// 103:         .to eq({ matches: {}, regex: nil, url: "" })
// 104:     end
// 105:
// 106:     it "returns default match_data when content is blank" do
// 107:       expect(npm.find_versions(url: npm_urls[:typical], content: ""))
// 108:         .to eq(match_data[:cached_default])
// 109:     end
// 110:   end
// 111: end
