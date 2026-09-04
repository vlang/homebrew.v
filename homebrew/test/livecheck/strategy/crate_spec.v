module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as crate_core
import homebrew.utils
import regex
import x.json2

// Translated from Homebrew/brew `test/livecheck/strategy/crate_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CrateSpecMatchData {
pub:
	fetched        crate_core.JsonMatchData
	cached         crate_core.JsonMatchData
	cached_default crate_core.JsonMatchData
}

fn crate_spec_content() string {
	return '{\n  "versions": [\n    {"crate":"example","created_at":"2023-01-03T00:00:00.000000+00:00","num":"1.0.2","updated_at":"2023-01-03T00:00:00.000000+00:00","yanked":true},\n    {"crate":"example","created_at":"2023-01-02T00:00:00.000000+00:00","num":"1.0.1","updated_at":"2023-01-02T00:00:00.000000+00:00","yanked":false},\n    {"crate":"example","created_at":"2023-01-01T00:00:00.000000+00:00","num":"1.0.0","updated_at":"2023-01-01T00:00:00.000000+00:00","yanked":false}\n  ]\n}\n'
}

fn crate_spec_capture(value string, provided crate_core.JsonRegex) ?string {
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

fn crate_spec_versions(document json2.Any,
	provided crate_core.JsonRegex) livecheck.StrategyBlockValue {
	mut versions := []string{}
	if document is map[string]json2.Any {
		raw_versions := document['versions'] or {
			return livecheck.StrategyBlockValue{ kind: .nil_value }
		}
		if raw_versions is []json2.Any {
			for raw_version in raw_versions {
				if raw_version is map[string]json2.Any {
					yanked := raw_version['yanked'] or { json2.Any(false) }
					if yanked is bool {
						if yanked {
							continue
						}
					}
					num := raw_version['num'] or { continue }
					if num is string {
						if captured := crate_spec_capture(num, provided) {
							versions << captured
						}
					}
				}
			}
		}
	}
	return if versions.len == 0 {
		livecheck.StrategyBlockValue{ kind: .nil_value }
	} else {
		livecheck.StrategyBlockValue{
			kind: .array
			values: versions.map(livecheck.StrategyBlockItem{
				kind: .string_value
				value: it
			})
		}
	}
}

fn crate_spec_two_arg_block(document json2.Any,
	provided ?crate_core.JsonRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	return crate_spec_versions(document, match_regex)
}

fn crate_spec_one_arg_block(document json2.Any,
	_ ?crate_core.JsonRegex) !livecheck.StrategyBlockValue {
	return crate_spec_versions(document, ruby_crate_spec_l13_d4_regex())
}

fn crate_spec_fetched(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return utils.CurlCommandResult{
		stdout: 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${crate_spec_content()}'
		exit_status: 0
	}
}

fn crate_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached crate content unexpectedly fetched')
}

fn crate_spec_regex_equal(left ?crate_core.JsonRegex, right ?crate_core.JsonRegex) bool {
	left_value := left or { crate_core.JsonRegex{} }
	right_value := right or { crate_core.JsonRegex{} }
	return left_value == right_value
}

fn crate_spec_match_data_equal(left crate_core.JsonMatchData,
	right crate_core.JsonMatchData) bool {
	return left.matches == right.matches && crate_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:crate) { described_class }` at line 7.
pub fn ruby_crate_spec_l7_d1_crate() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::Crate')
}

// Ruby let `let(:crate_url) { "https://static.crates.io/crates/example/example-0.1.0.crate" }` at line 9.
pub fn ruby_crate_spec_l9_d2_crate_url() string {
	return 'https://static.crates.io/crates/example/example-0.1.0.crate'
}

// Ruby let `let(:non_crate_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_crate_spec_l10_d3_non_crate_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:regex) { /v?(\d+(?:\.\d+)+)/i }` at line 13.
pub fn ruby_crate_spec_l13_d4_regex() crate_core.JsonRegex {
	return crate_core.JsonRegex{
		pattern: r'v?(\d+(?:\.\d+)+)'
		case_insensitive: true
	}
}

// Ruby let `let(:generated) do` at line 14.
pub fn ruby_crate_spec_l14_d5_generated() crate_core.CrateInputValues {
	return crate_core.CrateInputValues{
		present: true
		url: 'https://crates.io/api/v1/crates/example/versions'
	}
}

// Ruby let `let(:content) do` at line 19.
pub fn ruby_crate_spec_l19_d6_content() string {
	return crate_spec_content()
}

// Ruby let `let(:matches) { ["1.0.0", "1.0.1"] }` at line 48.
pub fn ruby_crate_spec_l48_d7_matches() []string {
	return ['1.0.0', '1.0.1']
}

// Ruby it `it "returns true for a crate URL" do` at line 51.
pub fn ruby_crate_spec_l51_d8_returns() bool {
	return crate_core.crate_matches_url(ruby_crate_spec_l9_d2_crate_url())
}

// Ruby it `it "returns false for a non-crate URL" do` at line 55.
pub fn ruby_crate_spec_l55_d9_returns() bool {
	return !crate_core.crate_matches_url(ruby_crate_spec_l10_d3_non_crate_url())
}

// Ruby it `it "returns a hash containing url for a crate URL" do` at line 61.
pub fn ruby_crate_spec_l61_d10_returns() bool {
	return crate_core.crate_generate_input_values(ruby_crate_spec_l9_d2_crate_url()) == ruby_crate_spec_l14_d5_generated()
}

// Ruby it `it "returns an empty hash for a non-crate URL" do` at line 65.
pub fn ruby_crate_spec_l65_d11_returns() bool {
	return !crate_core.crate_generate_input_values(ruby_crate_spec_l10_d3_non_crate_url()).present
}

// Ruby let `let(:match_data) do` at line 71.
pub fn ruby_crate_spec_l71_d12_match_data() CrateSpecMatchData {
	base := crate_core.JsonMatchData{
		matches: {
			'1.0.0': '1.0.0'
			'1.0.1': '1.0.1'
		}
		url: ruby_crate_spec_l14_d5_generated().url
	}
	return CrateSpecMatchData{
		fetched: crate_core.JsonMatchData{
			...base
			content: crate_spec_content()
			has_content: true
		}
		cached: crate_core.JsonMatchData{
			...base
			cached: true
			has_cached: true
		}
		cached_default: crate_core.JsonMatchData{
			...base
			matches: map[string]string{}
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in fetched content" do` at line 85.
pub fn ruby_crate_spec_l85_d13_finds() bool {
	expected := ruby_crate_spec_l71_d12_match_data().fetched
	with_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		regex: ruby_crate_spec_l13_d4_regex()
	}, crate_spec_fetched) or { return false }
	without_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
	}, crate_spec_fetched) or { return false }
	return crate_spec_match_data_equal(with_regex, crate_core.JsonMatchData{
		...expected
		regex: ruby_crate_spec_l13_d4_regex()
	}) && crate_spec_match_data_equal(without_regex, expected)
}

// Ruby it `it "finds versions in provided content" do` at line 93.
pub fn ruby_crate_spec_l93_d14_finds() bool {
	expected := ruby_crate_spec_l71_d12_match_data().cached
	with_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		regex: ruby_crate_spec_l13_d4_regex()
		content: crate_spec_content()
	}, crate_spec_unused_fetcher) or { return false }
	without_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		content: crate_spec_content()
	}, crate_spec_unused_fetcher) or { return false }
	return crate_spec_match_data_equal(with_regex, crate_core.JsonMatchData{
		...expected
		regex: ruby_crate_spec_l13_d4_regex()
	}) && crate_spec_match_data_equal(without_regex, expected)
}

// Ruby it `it "finds versions in provided content using a block" do` at line 101.
pub fn ruby_crate_spec_l101_d15_finds() bool {
	expected := ruby_crate_spec_l71_d12_match_data().cached
	with_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		regex: ruby_crate_spec_l13_d4_regex()
		content: crate_spec_content()
		has_block: true
		block_arity: 2
		block: crate_spec_two_arg_block
	}, crate_spec_unused_fetcher) or { return false }
	without_regex := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		content: crate_spec_content()
		has_block: true
		block_arity: 1
		block: crate_spec_one_arg_block
	}, crate_spec_unused_fetcher) or { return false }
	return crate_spec_match_data_equal(with_regex, crate_core.JsonMatchData{
		...expected
		regex: ruby_crate_spec_l13_d4_regex()
	}) && crate_spec_match_data_equal(without_regex, expected)
}

// Ruby it `it "returns default match_data when block doesn't return version information" do` at line 121.
pub fn ruby_crate_spec_l121_d16_returns() bool {
	expected := ruby_crate_spec_l71_d12_match_data().cached_default
	for request in [
		crate_core.CrateFindRequest{
			url: ruby_crate_spec_l9_d2_crate_url()
			content: '{"other":true}'
		},
		crate_core.CrateFindRequest{
			url: ruby_crate_spec_l9_d2_crate_url()
			content: '{"versions":[{}]}'
		},
	] {
		actual := crate_core.crate_find_versions(request, crate_spec_unused_fetcher) or {
			return false
		}
		if !crate_spec_match_data_equal(actual, expected) {
			return false
		}
	}
	no_match_regex := crate_core.JsonRegex{
		pattern: 'will_not_match'
		case_insensitive: true
	}
	actual := crate_core.crate_find_versions(crate_core.CrateFindRequest{
		url: ruby_crate_spec_l9_d2_crate_url()
		regex: no_match_regex
		content: crate_spec_content()
	}, crate_spec_unused_fetcher) or { return false }
	return crate_spec_match_data_equal(actual, crate_core.JsonMatchData{
		...expected
		regex: no_match_regex
	})
}

// Ruby it `it "returns default match_data when url is blank" do` at line 132.
pub fn ruby_crate_spec_l132_d17_returns() bool {
	actual := crate_core.crate_find_versions(crate_core.CrateFindRequest{}, crate_spec_unused_fetcher) or {
		return false
	}
	return crate_spec_match_data_equal(actual, crate_core.JsonMatchData{
		matches: map[string]string{}
	})
}

// Ruby it `it "returns default match_data when content is blank" do` at line 137.
pub fn ruby_crate_spec_l137_d18_returns() bool {
	expected := ruby_crate_spec_l71_d12_match_data().cached_default
	for content in ['{}', ''] {
		actual := crate_core.crate_find_versions(crate_core.CrateFindRequest{
			url: ruby_crate_spec_l9_d2_crate_url()
			content: content
		}, crate_spec_unused_fetcher) or { return false }
		if !crate_spec_match_data_equal(actual, expected) {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Crate do
// 7:   subject(:crate) { described_class }
// 8:
// 9:   let(:crate_url) { "https://static.crates.io/crates/example/example-0.1.0.crate" }
// 10:   let(:non_crate_url) { "https://brew.sh/test" }
// 11:   # This only differs from the `DEFAULT_REGEX` so we can distinguish between a
// 12:   # provided regex and the default strategy regex in testing.
// 13:   let(:regex) { /v?(\d+(?:\.\d+)+)/i }
// 14:   let(:generated) do
// 15:     { url: "https://crates.io/api/v1/crates/example/versions" }
// 16:   end
// 17:   # This is a limited subset of a `versions` response object, for the sake of
// 18:   # testing.
// 19:   let(:content) do
// 20:     <<~JSON
// 21:       {
// 22:         "versions": [
// 23:           {
// 24:             "crate": "example",
// 25:             "created_at": "2023-01-03T00:00:00.000000+00:00",
// 26:             "num": "1.0.2",
// 27:             "updated_at": "2023-01-03T00:00:00.000000+00:00",
// 28:             "yanked": true
// 29:           },
// 30:           {
// 31:             "crate": "example",
// 32:             "created_at": "2023-01-02T00:00:00.000000+00:00",
// 33:             "num": "1.0.1",
// 34:             "updated_at": "2023-01-02T00:00:00.000000+00:00",
// 35:             "yanked": false
// 36:           },
// 37:           {
// 38:             "crate": "example",
// 39:             "created_at": "2023-01-01T00:00:00.000000+00:00",
// 40:             "num": "1.0.0",
// 41:             "updated_at": "2023-01-01T00:00:00.000000+00:00",
// 42:             "yanked": false
// 43:           }
// 44:         ]
// 45:       }
// 46:     JSON
// 47:   end
// 48:   let(:matches) { ["1.0.0", "1.0.1"] }
// 49:
// 50:   describe "::match?" do
// 51:     it "returns true for a crate URL" do
// 52:       expect(crate.match?(crate_url)).to be true
// 53:     end
// 54:
// 55:     it "returns false for a non-crate URL" do
// 56:       expect(crate.match?(non_crate_url)).to be false
// 57:     end
// 58:   end
// 59:
// 60:   describe "::generate_input_values" do
// 61:     it "returns a hash containing url for a crate URL" do
// 62:       expect(crate.generate_input_values(crate_url)).to eq(generated)
// 63:     end
// 64:
// 65:     it "returns an empty hash for a non-crate URL" do
// 66:       expect(crate.generate_input_values(non_crate_url)).to eq({})
// 67:     end
// 68:   end
// 69:
// 70:   describe "::find_versions" do
// 71:     let(:match_data) do
// 72:       base = {
// 73:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 74:         regex:   nil,
// 75:         url:     generated[:url],
// 76:       }
// 77:
// 78:       {
// 79:         fetched:        base.merge({ content: }),
// 80:         cached:         base.merge({ cached: true }),
// 81:         cached_default: base.merge({ matches: {}, cached: true }),
// 82:       }
// 83:     end
// 84:
// 85:     it "finds versions in fetched content" do
// 86:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 87:
// 88:       expect(crate.find_versions(url: crate_url, regex:))
// 89:         .to eq(match_data[:fetched].merge({ regex: }))
// 90:       expect(crate.find_versions(url: crate_url)).to eq(match_data[:fetched])
// 91:     end
// 92:
// 93:     it "finds versions in provided content" do
// 94:       expect(crate.find_versions(url: crate_url, regex:, content:))
// 95:         .to eq(match_data[:cached].merge({ regex: }))
// 96:
// 97:       expect(crate.find_versions(url: crate_url, content:))
// 98:         .to eq(match_data[:cached])
// 99:     end
// 100:
// 101:     it "finds versions in provided content using a block" do
// 102:       expect(crate.find_versions(url: crate_url, regex:, content:) do |json, regex|
// 103:         json["versions"]&.map do |version|
// 104:           next if version["yanked"] == true
// 105:           next if (match = version["num"]&.match(regex)).blank?
// 106:
// 107:           match[1]
// 108:         end
// 109:       end).to eq(match_data[:cached].merge({ regex: }))
// 110:
// 111:       expect(crate.find_versions(url: crate_url, content:) do |json|
// 112:         json["versions"]&.map do |version|
// 113:           next if version["yanked"] == true
// 114:           next if (match = version["num"]&.match(regex)).blank?
// 115:
// 116:           match[1]
// 117:         end
// 118:       end).to eq(match_data[:cached])
// 119:     end
// 120:
// 121:     it "returns default match_data when block doesn't return version information" do
// 122:       no_match_regex = /will_not_match/i
// 123:
// 124:       expect(crate.find_versions(url: crate_url, content: '{"other":true}'))
// 125:         .to eq(match_data[:cached_default])
// 126:       expect(crate.find_versions(url: crate_url, content: '{"versions":[{}]}'))
// 127:         .to eq(match_data[:cached_default])
// 128:       expect(crate.find_versions(url: crate_url, regex: no_match_regex, content:))
// 129:         .to eq(match_data[:cached_default].merge({ regex: no_match_regex }))
// 130:     end
// 131:
// 132:     it "returns default match_data when url is blank" do
// 133:       expect(crate.find_versions(url: ""))
// 134:         .to eq({ matches: {}, regex: nil, url: "" })
// 135:     end
// 136:
// 137:     it "returns default match_data when content is blank" do
// 138:       expect(crate.find_versions(url: crate_url, content: "{}"))
// 139:         .to eq(match_data[:cached_default])
// 140:       expect(crate.find_versions(url: crate_url, content: ""))
// 141:         .to eq(match_data[:cached_default])
// 142:     end
// 143:   end
// 144: end
