module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as pypi_core
import homebrew.utils
import regex
import x.json2

pub struct PypiSpecMatchData {
pub:
	cached         pypi_core.JsonMatchData
	cached_default pypi_core.JsonMatchData
	cached_regex   pypi_core.JsonMatchData
}

fn pypi_spec_content() string {
	return '{\n  "info": {\n    "version": "1.2.3-456"\n  }\n}\n'
}

fn pypi_spec_capture(value string, provided pypi_core.JsonRegex) ?string {
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

fn pypi_spec_version(document json2.Any) ?string {
	if document is map[string]json2.Any {
		info := document['info'] or { return none }
		if info is map[string]json2.Any {
			value := info['version'] or { return none }
			if value is string {
				return if value.trim_space() == '' { none } else { value }
			}
		}
	}
	return none
}

fn pypi_spec_regex_block(document json2.Any,
	provided ?pypi_core.JsonRegex) !livecheck.StrategyBlockValue {
	version := pypi_spec_version(document) or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	matched := pypi_spec_capture(version, match_regex) or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: matched
	}
}

fn pypi_spec_version_block(document json2.Any,
	_ ?pypi_core.JsonRegex) !livecheck.StrategyBlockValue {
	version := pypi_spec_version(document) or {
		return livecheck.StrategyBlockValue{ kind: .nil_value }
	}
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: version
	}
}

fn pypi_spec_constant_block(_ json2.Any,
	_ ?pypi_core.JsonRegex) !livecheck.StrategyBlockValue {
	return livecheck.StrategyBlockValue{
		kind: .string_value
		value: '1.2.3'
	}
}

fn pypi_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached PyPI content unexpectedly fetched')
}

fn pypi_spec_regex_equal(left ?pypi_core.JsonRegex, right ?pypi_core.JsonRegex) bool {
	left_value := left or { pypi_core.JsonRegex{} }
	right_value := right or { pypi_core.JsonRegex{} }
	return left_value == right_value
}

fn pypi_spec_match_data_equal(left pypi_core.JsonMatchData,
	right pypi_core.JsonMatchData) bool {
	return left.matches == right.matches && pypi_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Translated from Homebrew/brew `test/livecheck/strategy/pypi_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:pypi) { described_class }` at line 7.
pub fn ruby_pypi_spec_l7_d1_pypi() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Pypi')
}

// Ruby let `let(:pypi_url) { "https://files.pythonhosted.org/packages/ab/cd/efg/example-package-1.2.3.tar.gz" }` at line 9.
pub fn ruby_pypi_spec_l9_d2_pypi_url() string {
	return 'https://files.pythonhosted.org/packages/ab/cd/efg/example-package-1.2.3.tar.gz'
}

// Ruby let `let(:non_pypi_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_pypi_spec_l10_d3_non_pypi_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:regex) { /^v?(\d+(?:\.\d+)+)/i }` at line 11.
pub fn ruby_pypi_spec_l11_d4_regex() pypi_core.JsonRegex {
	return pypi_core.JsonRegex{
		pattern: r'^v?(\d+(?:\.\d+)+)'
		case_insensitive: true
	}
}

// Ruby let `let(:generated) do` at line 12.
pub fn ruby_pypi_spec_l12_d5_generated() pypi_core.PypiInputValues {
	return pypi_core.PypiInputValues{
		present: true
		url: 'https://pypi.org/pypi/example-package/json'
	}
}

// Ruby let `let(:content) do` at line 20.
pub fn ruby_pypi_spec_l20_d6_content() string {
	return pypi_spec_content()
}

// Ruby let `let(:matches) { ["1.2.3-456"] }` at line 29.
pub fn ruby_pypi_spec_l29_d7_matches() []string {
	return ['1.2.3-456']
}

// Ruby it `it "returns true for a PyPI URL" do` at line 32.
pub fn ruby_pypi_spec_l32_d8_returns() bool {
	return pypi_core.pypi_matches_url(ruby_pypi_spec_l9_d2_pypi_url())
}

// Ruby it `it "returns false for a non-PyPI URL" do` at line 36.
pub fn ruby_pypi_spec_l36_d9_returns() bool {
	return !pypi_core.pypi_matches_url(ruby_pypi_spec_l10_d3_non_pypi_url())
}

// Ruby it `it "returns a hash containing url and regex for an PyPI URL" do` at line 42.
pub fn ruby_pypi_spec_l42_d10_returns() bool {
	return pypi_core.pypi_generate_input_values(ruby_pypi_spec_l9_d2_pypi_url()) == ruby_pypi_spec_l12_d5_generated()
}

// Ruby it `it "returns an empty hash for a non-PyPI URL" do` at line 46.
pub fn ruby_pypi_spec_l46_d11_returns() bool {
	return !pypi_core.pypi_generate_input_values(ruby_pypi_spec_l10_d3_non_pypi_url()).present
}

// Ruby let `let(:match_data) do` at line 52.
pub fn ruby_pypi_spec_l52_d12_match_data() PypiSpecMatchData {
	base := pypi_core.JsonMatchData{
		matches: {
			'1.2.3-456': '1.2.3-456'
		}
		url: ruby_pypi_spec_l12_d5_generated().url
		cached: true
		has_cached: true
	}
	return PypiSpecMatchData{
		cached: base
		cached_default: pypi_core.JsonMatchData{
			...base
			matches: map[string]string{}
		}
		cached_regex: pypi_core.JsonMatchData{
			...base
			matches: {
				'1.2.3': '1.2.3'
			}
			regex: ruby_pypi_spec_l11_d4_regex()
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 70.
pub fn ruby_pypi_spec_l70_d13_finds() bool {
	with_regex := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		url: ruby_pypi_spec_l9_d2_pypi_url()
		regex: ruby_pypi_spec_l11_d4_regex()
		content: pypi_spec_content()
	}, pypi_spec_unused_fetcher) or { return false }
	without_regex := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		url: ruby_pypi_spec_l9_d2_pypi_url()
		content: pypi_spec_content()
	}, pypi_spec_unused_fetcher) or { return false }
	expected := ruby_pypi_spec_l52_d12_match_data()
	return pypi_spec_match_data_equal(with_regex, expected.cached_regex) && pypi_spec_match_data_equal(without_regex, expected.cached)
}

// Ruby it `it "finds versions in provided content using a block" do` at line 78.
pub fn ruby_pypi_spec_l78_d14_finds() bool {
	with_regex := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		url: ruby_pypi_spec_l9_d2_pypi_url()
		regex: ruby_pypi_spec_l11_d4_regex()
		content: pypi_spec_content()
		has_block: true
		block_arity: 2
		block: pypi_spec_regex_block
	}, pypi_spec_unused_fetcher) or { return false }
	without_regex := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		url: ruby_pypi_spec_l9_d2_pypi_url()
		content: pypi_spec_content()
		has_block: true
		block_arity: 1
		block: pypi_spec_version_block
	}, pypi_spec_unused_fetcher) or { return false }
	expected := ruby_pypi_spec_l52_d12_match_data()
	return pypi_spec_match_data_equal(with_regex, expected.cached_regex) && pypi_spec_match_data_equal(without_regex, expected.cached)
}

// Ruby it `it "returns default match_data when block doesn't return version information" do` at line 93.
pub fn ruby_pypi_spec_l93_d15_returns() bool {
	expected := ruby_pypi_spec_l52_d12_match_data().cached_default
	for request in [
		pypi_core.PypiFindRequest{
			url: ruby_pypi_spec_l9_d2_pypi_url()
			content: '{"info":{"version":""}}'
		},
		pypi_core.PypiFindRequest{
			url: ruby_pypi_spec_l9_d2_pypi_url()
			content: '{"other":true}'
		},
	] {
		actual := pypi_core.pypi_find_versions(request, pypi_spec_unused_fetcher) or {
			return false
		}
		if !pypi_spec_match_data_equal(actual, expected) {
			return false
		}
	}
	no_match_regex := pypi_core.JsonRegex{
		pattern: 'will_not_match'
		case_insensitive: true
	}
	actual := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		url: ruby_pypi_spec_l9_d2_pypi_url()
		regex: no_match_regex
		content: pypi_spec_content()
	}, pypi_spec_unused_fetcher) or { return false }
	return pypi_spec_match_data_equal(actual, pypi_core.JsonMatchData{
		...expected
		regex: no_match_regex
	})
}

// Ruby it `it "returns default match_data when url is blank" do` at line 104.
pub fn ruby_pypi_spec_l104_d16_returns() bool {
	actual := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
		has_block: true
		block_arity: 1
		block: pypi_spec_constant_block
	}, pypi_spec_unused_fetcher) or { return false }
	return pypi_spec_match_data_equal(actual, pypi_core.JsonMatchData{
		matches: map[string]string{}
	})
}

// Ruby it `it "returns default match_data when content is blank" do` at line 109.
pub fn ruby_pypi_spec_l109_d17_returns() bool {
	expected := ruby_pypi_spec_l52_d12_match_data().cached_default
	for content in ['{}', ''] {
		actual := pypi_core.pypi_find_versions(pypi_core.PypiFindRequest{
			url: ruby_pypi_spec_l9_d2_pypi_url()
			content: content
			has_block: true
			block_arity: 1
			block: pypi_spec_constant_block
		}, pypi_spec_unused_fetcher) or { return false }
		if !pypi_spec_match_data_equal(actual, expected) {
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
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Pypi do
// 7:   subject(:pypi) { described_class }
// 8:
// 9:   let(:pypi_url) { "https://files.pythonhosted.org/packages/ab/cd/efg/example-package-1.2.3.tar.gz" }
// 10:   let(:non_pypi_url) { "https://brew.sh/test" }
// 11:   let(:regex) { /^v?(\d+(?:\.\d+)+)/i }
// 12:   let(:generated) do
// 13:     {
// 14:       url: "https://pypi.org/pypi/example-package/json",
// 15:     }
// 16:   end
// 17:   # This is a limited subset of a PyPI JSON API response object, for the sake
// 18:   # of testing. Typical versions use a `1.2.3` format but this adds a suffix,
// 19:   # so we can test regex matching.
// 20:   let(:content) do
// 21:     <<~JSON
// 22:       {
// 23:         "info": {
// 24:           "version": "1.2.3-456"
// 25:         }
// 26:       }
// 27:     JSON
// 28:   end
// 29:   let(:matches) { ["1.2.3-456"] }
// 30:
// 31:   describe "::match?" do
// 32:     it "returns true for a PyPI URL" do
// 33:       expect(pypi.match?(pypi_url)).to be true
// 34:     end
// 35:
// 36:     it "returns false for a non-PyPI URL" do
// 37:       expect(pypi.match?(non_pypi_url)).to be false
// 38:     end
// 39:   end
// 40:
// 41:   describe "::generate_input_values" do
// 42:     it "returns a hash containing url and regex for an PyPI URL" do
// 43:       expect(pypi.generate_input_values(pypi_url)).to eq(generated)
// 44:     end
// 45:
// 46:     it "returns an empty hash for a non-PyPI URL" do
// 47:       expect(pypi.generate_input_values(non_pypi_url)).to eq({})
// 48:     end
// 49:   end
// 50:
// 51:   describe "::find_versions" do
// 52:     let(:match_data) do
// 53:       cached = {
// 54:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 55:         regex:   nil,
// 56:         url:     generated[:url],
// 57:         cached:  true,
// 58:       }
// 59:
// 60:       {
// 61:         cached:,
// 62:         cached_default: cached.merge({ matches: {} }),
// 63:         cached_regex:   cached.merge({
// 64:           matches: { "1.2.3" => Version.new("1.2.3") },
// 65:           regex:,
// 66:         }),
// 67:       }
// 68:     end
// 69:
// 70:     it "finds versions in provided content" do
// 71:       expect(pypi.find_versions(url: pypi_url, regex:, content: content))
// 72:         .to eq(match_data[:cached_regex])
// 73:
// 74:       expect(pypi.find_versions(url: pypi_url, content: content))
// 75:         .to eq(match_data[:cached])
// 76:     end
// 77:
// 78:     it "finds versions in provided content using a block" do
// 79:       # NOTE: We only use a regex here to make sure it can be passed into the
// 80:       # block, if necessary.
// 81:       expect(pypi.find_versions(url: pypi_url, regex:, content: content) do |json, regex|
// 82:         match = json.dig("info", "version")&.match(regex)
// 83:         next if match.blank?
// 84:
// 85:         match[1]
// 86:       end).to eq(match_data[:cached_regex])
// 87:
// 88:       expect(pypi.find_versions(url: pypi_url, content: content) do |json|
// 89:         json.dig("info", "version").presence
// 90:       end).to eq(match_data[:cached])
// 91:     end
// 92:
// 93:     it "returns default match_data when block doesn't return version information" do
// 94:       no_match_regex = /will_not_match/i
// 95:
// 96:       expect(pypi.find_versions(url: pypi_url, content: '{"info":{"version":""}}'))
// 97:         .to eq(match_data[:cached_default])
// 98:       expect(pypi.find_versions(url: pypi_url, content: '{"other":true}'))
// 99:         .to eq(match_data[:cached_default])
// 100:       expect(pypi.find_versions(url: pypi_url, regex: no_match_regex, content: content))
// 101:         .to eq(match_data[:cached_default].merge({ regex: no_match_regex }))
// 102:     end
// 103:
// 104:     it "returns default match_data when url is blank" do
// 105:       expect(pypi.find_versions(url: "") { "1.2.3" })
// 106:         .to eq({ matches: {}, regex: nil, url: "" })
// 107:     end
// 108:
// 109:     it "returns default match_data when content is blank" do
// 110:       expect(pypi.find_versions(url: pypi_url, content: "{}") { "1.2.3" })
// 111:         .to eq(match_data[:cached_default])
// 112:       expect(pypi.find_versions(url: pypi_url, content: "") { "1.2.3" })
// 113:         .to eq(match_data[:cached_default])
// 114:     end
// 115:   end
// 116: end
