module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as ruby_gems_core
import homebrew.utils
import x.json2

fn ruby_gems_spec_content() string {
	return '{\n  "version": "1.2.3"\n}\n'
}

fn ruby_gems_spec_version_block(document json2.Any,
	_ ?ruby_gems_core.JsonRegex) !livecheck.StrategyBlockValue {
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

fn ruby_gems_spec_missing_block(_ json2.Any,
	_ ?ruby_gems_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{ kind: .nil_value }
}

fn ruby_gems_spec_constant_block(_ json2.Any,
	_ ?ruby_gems_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: '1.2.3'
	}
}

fn ruby_gems_spec_fetched(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${ruby_gems_spec_content()}'
		exit_status: 0
	}
}

fn ruby_gems_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached RubyGems content unexpectedly fetched')
}

fn ruby_gems_spec_regex_equal(left ?ruby_gems_core.JsonRegex,
	right ?ruby_gems_core.JsonRegex) bool {
	left_value := left or { ruby_gems_core.JsonRegex{} }
	right_value := right or { ruby_gems_core.JsonRegex{} }
	return left_value == right_value
}

fn ruby_gems_spec_match_data_equal(left ruby_gems_core.JsonMatchData,
	right ruby_gems_core.JsonMatchData) bool {
	return left.matches == right.matches && ruby_gems_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Translated from Homebrew/brew `test/livecheck/strategy/ruby_gems_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:ruby_gems) { described_class }` at line 7.
pub fn ruby_ruby_gems_spec_l7_d1_ruby_gems() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::RubyGems')
}

// Ruby let `let(:ruby_gems_url) { "https://rubygems.org/downloads/example-package-1.2.3.gem" }` at line 9.
pub fn ruby_ruby_gems_spec_l9_d2_ruby_gems_url() string {
	return 'https://rubygems.org/downloads/example-package-1.2.3.gem'
}

// Ruby let `let(:platform_ruby_gems_url) { "https://rubygems.org/downloads/example-package-1.2.3-arm64-darwin.gem" }` at line 10.
pub fn ruby_ruby_gems_spec_l10_d3_platform_ruby_gems_url() string {
	return 'https://rubygems.org/downloads/example-package-1.2.3-arm64-darwin.gem'
}

// Ruby let `let(:non_ruby_gems_url) { "https://brew.sh/test" }` at line 11.
pub fn ruby_ruby_gems_spec_l11_d4_non_ruby_gems_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 12.
pub fn ruby_ruby_gems_spec_l12_d5_generated() ruby_gems_core.RubyGemsInputValues {
	return ruby_gems_core.RubyGemsInputValues{
		present: true
		url: 'https://rubygems.org/api/v1/versions/example-package/latest.json'
	}
}

// Ruby let `let(:content) do` at line 17.
pub fn ruby_ruby_gems_spec_l17_d6_content() string {
	return ruby_gems_spec_content()
}

// Ruby it `it "returns true for a RubyGems URL" do` at line 26.
pub fn ruby_ruby_gems_spec_l26_d7_returns() bool {
	return ruby_gems_core.rubygems_matches_url(ruby_ruby_gems_spec_l9_d2_ruby_gems_url()) && ruby_gems_core.rubygems_matches_url(ruby_ruby_gems_spec_l10_d3_platform_ruby_gems_url())
}

// Ruby it `it "returns false for a non-RubyGems URL" do` at line 31.
pub fn ruby_ruby_gems_spec_l31_d8_returns() bool {
	return !ruby_gems_core.rubygems_matches_url(ruby_ruby_gems_spec_l11_d4_non_ruby_gems_url())
}

// Ruby it `it "returns a hash containing url for a RubyGems URL" do` at line 37.
pub fn ruby_ruby_gems_spec_l37_d9_returns() bool {
	expected := ruby_ruby_gems_spec_l12_d5_generated()
	return ruby_gems_core.rubygems_generate_input_values(ruby_ruby_gems_spec_l9_d2_ruby_gems_url()) == expected && ruby_gems_core.rubygems_generate_input_values(ruby_ruby_gems_spec_l10_d3_platform_ruby_gems_url()) == expected
}

// Ruby it `it "returns an empty hash for a non-RubyGems URL" do` at line 42.
pub fn ruby_ruby_gems_spec_l42_d10_returns() bool {
	return !ruby_gems_core.rubygems_generate_input_values(ruby_ruby_gems_spec_l11_d4_non_ruby_gems_url()).present
}

// Ruby let `let(:match_data) do` at line 48.
pub fn ruby_ruby_gems_spec_l48_d11_match_data() ruby_gems_core.JsonMatchData {
	return ruby_gems_core.JsonMatchData{
		matches: {
			'1.2.3': '1.2.3'
		}
		url: ruby_ruby_gems_spec_l12_d5_generated().url
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 58.
pub fn ruby_ruby_gems_spec_l58_d12_finds() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		url: ruby_ruby_gems_spec_l9_d2_ruby_gems_url()
	}, ruby_gems_spec_fetched) or { return false }
	expected := ruby_gems_core.JsonMatchData{
		...ruby_ruby_gems_spec_l48_d11_match_data()
		content: ruby_gems_spec_content()
		has_content: true
	}
	return ruby_gems_spec_match_data_equal(actual, expected)
}

// Ruby it `it "finds versions in provided content" do` at line 64.
pub fn ruby_ruby_gems_spec_l64_d13_finds() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		url: ruby_ruby_gems_spec_l9_d2_ruby_gems_url()
		content: ruby_gems_spec_content()
	}, ruby_gems_spec_unused_fetcher) or { return false }
	expected := ruby_gems_core.JsonMatchData{
		...ruby_ruby_gems_spec_l48_d11_match_data()
		cached: true
		has_cached: true
	}
	return ruby_gems_spec_match_data_equal(actual, expected)
}

// Ruby it `it "finds versions in provided content using a block" do` at line 68.
pub fn ruby_ruby_gems_spec_l68_d14_finds() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		url: ruby_ruby_gems_spec_l9_d2_ruby_gems_url()
		content: ruby_gems_spec_content()
		has_block: true
		block: ruby_gems_spec_version_block
	}, ruby_gems_spec_unused_fetcher) or { return false }
	expected := ruby_gems_core.JsonMatchData{
		...ruby_ruby_gems_spec_l48_d11_match_data()
		cached: true
		has_cached: true
	}
	return ruby_gems_spec_match_data_equal(actual, expected)
}

// Ruby it `it "returns default match_data when block doesn't return version information" do` at line 74.
pub fn ruby_ruby_gems_spec_l74_d15_returns() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		url: ruby_ruby_gems_spec_l9_d2_ruby_gems_url()
		content: ruby_gems_spec_content()
		has_block: true
		block: ruby_gems_spec_missing_block
	}, ruby_gems_spec_unused_fetcher) or { return false }
	expected := ruby_gems_core.JsonMatchData{
		...ruby_ruby_gems_spec_l48_d11_match_data()
		matches: map[string]string{}
		cached: true
		has_cached: true
	}
	return ruby_gems_spec_match_data_equal(actual, expected)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 80.
pub fn ruby_ruby_gems_spec_l80_d16_returns() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		has_block: true
		block: ruby_gems_spec_constant_block
	}, ruby_gems_spec_unused_fetcher) or { return false }
	return ruby_gems_spec_match_data_equal(actual, ruby_gems_core.JsonMatchData{
		matches: map[string]string{}
	})
}

// Ruby it `it "returns default match_data when content is blank" do` at line 85.
pub fn ruby_ruby_gems_spec_l85_d17_returns() bool {
	actual := ruby_gems_core.rubygems_find_versions(ruby_gems_core.RubyGemsFindRequest{
		url: ruby_ruby_gems_spec_l9_d2_ruby_gems_url()
		content: ''
	}, ruby_gems_spec_unused_fetcher) or { return false }
	expected := ruby_gems_core.JsonMatchData{
		...ruby_ruby_gems_spec_l48_d11_match_data()
		matches: map[string]string{}
		cached: true
		has_cached: true
	}
	return ruby_gems_spec_match_data_equal(actual, expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::RubyGems do
// 7:   subject(:ruby_gems) { described_class }
// 8:
// 9:   let(:ruby_gems_url) { "https://rubygems.org/downloads/example-package-1.2.3.gem" }
// 10:   let(:platform_ruby_gems_url) { "https://rubygems.org/downloads/example-package-1.2.3-arm64-darwin.gem" }
// 11:   let(:non_ruby_gems_url) { "https://brew.sh/test" }
// 12:   let(:generated) do
// 13:     {
// 14:       url: "https://rubygems.org/api/v1/versions/example-package/latest.json",
// 15:     }
// 16:   end
// 17:   let(:content) do
// 18:     <<~JSON
// 19:       {
// 20:         "version": "1.2.3"
// 21:       }
// 22:     JSON
// 23:   end
// 24:
// 25:   describe "::match?" do
// 26:     it "returns true for a RubyGems URL" do
// 27:       expect(ruby_gems.match?(ruby_gems_url)).to be true
// 28:       expect(ruby_gems.match?(platform_ruby_gems_url)).to be true
// 29:     end
// 30:
// 31:     it "returns false for a non-RubyGems URL" do
// 32:       expect(ruby_gems.match?(non_ruby_gems_url)).to be false
// 33:     end
// 34:   end
// 35:
// 36:   describe "::generate_input_values" do
// 37:     it "returns a hash containing url for a RubyGems URL" do
// 38:       expect(ruby_gems.generate_input_values(ruby_gems_url)).to eq(generated)
// 39:       expect(ruby_gems.generate_input_values(platform_ruby_gems_url)).to eq(generated)
// 40:     end
// 41:
// 42:     it "returns an empty hash for a non-RubyGems URL" do
// 43:       expect(ruby_gems.generate_input_values(non_ruby_gems_url)).to eq({})
// 44:     end
// 45:   end
// 46:
// 47:   describe "::find_versions" do
// 48:     let(:match_data) do
// 49:       {
// 50:         matches: {
// 51:           "1.2.3" => Version.new("1.2.3"),
// 52:         },
// 53:         regex:   nil,
// 54:         url:     generated[:url],
// 55:       }
// 56:     end
// 57:
// 58:     it "finds versions in fetched content" do
// 59:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 60:
// 61:       expect(ruby_gems.find_versions(url: ruby_gems_url)).to eq(match_data.merge({ content: }))
// 62:     end
// 63:
// 64:     it "finds versions in provided content" do
// 65:       expect(ruby_gems.find_versions(url: ruby_gems_url, content:)).to eq(match_data.merge({ cached: true }))
// 66:     end
// 67:
// 68:     it "finds versions in provided content using a block" do
// 69:       expect(ruby_gems.find_versions(url: ruby_gems_url, content:) do |json|
// 70:         json["version"]
// 71:       end).to eq(match_data.merge({ cached: true }))
// 72:     end
// 73:
// 74:     it "returns default match_data when block doesn't return version information" do
// 75:       expect(ruby_gems.find_versions(url: ruby_gems_url, content:) do |json|
// 76:         json["nonexistent_value"]
// 77:       end).to eq(match_data.merge({ matches: {}, cached: true }))
// 78:     end
// 79:
// 80:     it "returns default match_data when url is blank" do
// 81:       expect(ruby_gems.find_versions(url: "") { "1.2.3" })
// 82:         .to eq({ matches: {}, regex: nil, url: "" })
// 83:     end
// 84:
// 85:     it "returns default match_data when content is blank" do
// 86:       expect(ruby_gems.find_versions(url: ruby_gems_url, content: ""))
// 87:         .to eq(match_data.merge({ matches: {}, cached: true }))
// 88:     end
// 89:   end
// 90: end
