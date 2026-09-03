module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as gnome_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/gnome_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GnomeSpecMatches {
pub:
	all     []string
	default []string
}

pub struct GnomeSpecMatchData {
pub:
	cached         gnome_core.PageMatchData
	cached_default gnome_core.PageMatchData
}

fn gnome_spec_scan_block(page string,
	provided ?gnome_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := gnome_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn gnome_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached GNOME content unexpectedly fetched')
}

fn gnome_spec_regex_equal(left ?gnome_core.PageMatchRegex,
	right ?gnome_core.PageMatchRegex) bool {
	if left_value := left {
		right_value := right or { return false }
		return left_value == right_value
	}
	if _ := right {
		return false
	}
	return true
}

fn gnome_spec_match_data_equal(left gnome_core.PageMatchData,
	right gnome_core.PageMatchData) bool {
	return left.matches == right.matches && gnome_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:gnome) { described_class }` at line 7.
pub fn ruby_gnome_spec_l7_d1_gnome() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Gnome')
}

// Ruby let `let(:gnome_url) { "https://download.gnome.org/sources/abc/1.2/abc-1.2.3.tar.xz" }` at line 9.
pub fn ruby_gnome_spec_l9_d2_gnome_url() string {
	return 'https://download.gnome.org/sources/abc/1.2/abc-1.2.3.tar.xz'
}

// Ruby let `let(:non_gnome_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_gnome_spec_l10_d3_non_gnome_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 11.
pub fn ruby_gnome_spec_l11_d4_generated() gnome_core.GnomeInputValues {
	return gnome_core.GnomeInputValues{
		present: true
		url: 'https://download.gnome.org/sources/abc/cache.json'
		regex: gnome_core.PageMatchRegex{
			pattern: r'abc-(\d+(?:\.\d+)*)\.t'
			case_insensitive: true
		}
	}
}

// Ruby let `let(:content) do` at line 17.
pub fn ruby_gnome_spec_l17_d5_content() string {
	return '[4, {"abc": {"40.1.0": {"news": "40.1/abc-40.1.0.news", "changes": "40.1/abc-40.1.0.changes", "tar.xz": "40.1/abc-40.1.0.tar.xz", "sha256sum": "40.1/abc-40.1.0.sha256sum"}, "1.2.90": {"news": "1.2/abc-1.2.90.news", "changes": "1.2/abc-1.2.90.changes", "tar.xz": "1.2/abc-1.2.90.tar.xz", "sha256sum": "1.2/abc-1.2.90.sha256sum"}, "1.2.4": {"news": "1.2/abc-1.2.4.news", "changes": "1.2/abc-1.2.4.changes", "tar.xz": "1.2/abc-1.2.4.tar.xz", "sha256sum": "1.2/abc-1.2.4.sha256sum"}, "1.2.3": {"news": "1.2/abc-1.2.3.news", "changes": "1.2/abc-1.2.3.changes", "tar.xz": "1.2/abc-1.2.3.tar.xz", "sha256sum": "1.2/abc-1.2.3.sha256sum"}, "1.1.0": {"news": "1.1/abc-1.1.0.news", "changes": "1.1/abc-1.1.0.changes", "tar.xz": "1.1/abc-1.1.0.tar.xz", "sha256sum": "1.1/abc-1.1.0.sha256sum"}, "1": {"news": "1/abc-1.news", "changes": "1/abc-1.changes", "tar.xz": "1/abc-1.tar.xz", "sha256sum": "1/abc-1.sha256sum"}}}, {"abc": ["1", "1.1.0", "1.2.3", "1.2.4", "1.2.90", "40.1.0"]}, {"1": ["LATEST-IS-1"], "1.1": ["LATEST-IS-1.1.0"], "1.2": ["LATEST-IS-1.2.4"], "40": ["LATEST-IS-40.1.0"], ".": ["cache.json"]}]\n\n'
}

// Ruby let `let(:matches) do` at line 23.
pub fn ruby_gnome_spec_l23_d6_matches() GnomeSpecMatches {
	return GnomeSpecMatches{
		all: ['40.1.0', '1.2.90', '1.2.4', '1.2.3', '1.1.0', '1']
		default: ['40.1.0', '1.2.4', '1.2.3', '1']
	}
}

// Ruby it `it "returns true for a GNOME URL" do` at line 31.
pub fn ruby_gnome_spec_l31_d7_returns() bool {
	return gnome_core.gnome_matches_url(ruby_gnome_spec_l9_d2_gnome_url())
}

// Ruby it `it "returns false for a non-GNOME URL" do` at line 35.
pub fn ruby_gnome_spec_l35_d8_returns() bool {
	return !gnome_core.gnome_matches_url(ruby_gnome_spec_l10_d3_non_gnome_url())
}

// Ruby it `it "returns a hash containing url and regex for a GNOME URL" do` at line 41.
pub fn ruby_gnome_spec_l41_d9_returns() bool {
	return gnome_core.gnome_generate_input_values(ruby_gnome_spec_l9_d2_gnome_url()) == ruby_gnome_spec_l11_d4_generated()
}

// Ruby it `it "returns an empty hash for a non-GNOME URL" do` at line 45.
pub fn ruby_gnome_spec_l45_d10_returns() bool {
	return !gnome_core.gnome_generate_input_values(ruby_gnome_spec_l10_d3_non_gnome_url()).present
}

// Ruby let `let(:match_data) do` at line 51.
pub fn ruby_gnome_spec_l51_d11_match_data() GnomeSpecMatchData {
	generated := ruby_gnome_spec_l11_d4_generated()
	mut default_matches := map[string]string{}
	for version in ruby_gnome_spec_l23_d6_matches().default {
		default_matches[version] = version
	}
	base := gnome_core.PageMatchData{
		matches: default_matches
		regex: generated.regex
		url: generated.url
		cached: true
		has_cached: true
	}
	return GnomeSpecMatchData{
		cached: base
		cached_default: gnome_core.PageMatchData{
			...base
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 65.
pub fn ruby_gnome_spec_l65_d12_finds() bool {
	url := ruby_gnome_spec_l9_d2_gnome_url()
	content := ruby_gnome_spec_l17_d5_content()
	direct := gnome_core.gnome_find_versions(gnome_core.GnomeFindRequest{
		url: url
		content: content
	}, gnome_spec_unused_fetcher) or { return false }
	with_block := gnome_core.gnome_find_versions(gnome_core.GnomeFindRequest{
		url: url
		content: content
		has_block: true
		block: gnome_spec_scan_block
	}, gnome_spec_unused_fetcher) or { return false }
	with_explicit_regex := gnome_core.gnome_find_versions(gnome_core.GnomeFindRequest{
		url: url
		regex: ruby_gnome_spec_l11_d4_generated().regex
		content: content
		has_block: true
		block: gnome_spec_scan_block
	}, gnome_spec_unused_fetcher) or { return false }
	expected := ruby_gnome_spec_l51_d11_match_data().cached
	mut all_matches := map[string]string{}
	for version in ruby_gnome_spec_l23_d6_matches().all {
		all_matches[version] = version
	}
	expected_all := gnome_core.PageMatchData{
		...expected
		matches: all_matches
	}
	return gnome_spec_match_data_equal(direct, expected) && gnome_spec_match_data_equal(with_block, expected) && gnome_spec_match_data_equal(with_explicit_regex, expected_all)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 80.
pub fn ruby_gnome_spec_l80_d13_returns() bool {
	actual := gnome_core.gnome_find_versions(gnome_core.GnomeFindRequest{
		url: ruby_gnome_spec_l9_d2_gnome_url()
		content: ''
	}, gnome_spec_unused_fetcher) or { return false }
	return gnome_spec_match_data_equal(actual, ruby_gnome_spec_l51_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Gnome do
// 7:   subject(:gnome) { described_class }
// 8:
// 9:   let(:gnome_url) { "https://download.gnome.org/sources/abc/1.2/abc-1.2.3.tar.xz" }
// 10:   let(:non_gnome_url) { "https://brew.sh/test" }
// 11:   let(:generated) do
// 12:     {
// 13:       url:   "https://download.gnome.org/sources/abc/cache.json",
// 14:       regex: /abc-(\d+(?:\.\d+)*)\.t/i,
// 15:     }
// 16:   end
// 17:   let(:content) do
// 18:     <<~JSON
// 19:       [4, {"abc": {"40.1.0": {"news": "40.1/abc-40.1.0.news", "changes": "40.1/abc-40.1.0.changes", "tar.xz": "40.1/abc-40.1.0.tar.xz", "sha256sum": "40.1/abc-40.1.0.sha256sum"}, "1.2.90": {"news": "1.2/abc-1.2.90.news", "changes": "1.2/abc-1.2.90.changes", "tar.xz": "1.2/abc-1.2.90.tar.xz", "sha256sum": "1.2/abc-1.2.90.sha256sum"}, "1.2.4": {"news": "1.2/abc-1.2.4.news", "changes": "1.2/abc-1.2.4.changes", "tar.xz": "1.2/abc-1.2.4.tar.xz", "sha256sum": "1.2/abc-1.2.4.sha256sum"}, "1.2.3": {"news": "1.2/abc-1.2.3.news", "changes": "1.2/abc-1.2.3.changes", "tar.xz": "1.2/abc-1.2.3.tar.xz", "sha256sum": "1.2/abc-1.2.3.sha256sum"}, "1.1.0": {"news": "1.1/abc-1.1.0.news", "changes": "1.1/abc-1.1.0.changes", "tar.xz": "1.1/abc-1.1.0.tar.xz", "sha256sum": "1.1/abc-1.1.0.sha256sum"}, "1": {"news": "1/abc-1.news", "changes": "1/abc-1.changes", "tar.xz": "1/abc-1.tar.xz", "sha256sum": "1/abc-1.sha256sum"}}}, {"abc": ["1", "1.1.0", "1.2.3", "1.2.4", "1.2.90", "40.1.0"]}, {"1": ["LATEST-IS-1"], "1.1": ["LATEST-IS-1.1.0"], "1.2": ["LATEST-IS-1.2.4"], "40": ["LATEST-IS-40.1.0"], ".": ["cache.json"]}]
// 20:
// 21:     JSON
// 22:   end
// 23:   let(:matches) do
// 24:     {
// 25:       all:     ["40.1.0", "1.2.90", "1.2.4", "1.2.3", "1.1.0", "1"],
// 26:       default: ["40.1.0", "1.2.4", "1.2.3", "1"],
// 27:     }
// 28:   end
// 29:
// 30:   describe "::match?" do
// 31:     it "returns true for a GNOME URL" do
// 32:       expect(gnome.match?(gnome_url)).to be true
// 33:     end
// 34:
// 35:     it "returns false for a non-GNOME URL" do
// 36:       expect(gnome.match?(non_gnome_url)).to be false
// 37:     end
// 38:   end
// 39:
// 40:   describe "::generate_input_values" do
// 41:     it "returns a hash containing url and regex for a GNOME URL" do
// 42:       expect(gnome.generate_input_values(gnome_url)).to eq(generated)
// 43:     end
// 44:
// 45:     it "returns an empty hash for a non-GNOME URL" do
// 46:       expect(gnome.generate_input_values(non_gnome_url)).to eq({})
// 47:     end
// 48:   end
// 49:
// 50:   describe "::find_versions" do
// 51:     let(:match_data) do
// 52:       cached = {
// 53:         matches: matches[:default].to_h { |v| [v, Version.new(v)] },
// 54:         regex:   generated[:regex],
// 55:         url:     generated[:url],
// 56:         cached:  true,
// 57:       }
// 58:
// 59:       {
// 60:         cached:,
// 61:         cached_default: cached.merge({ matches: {} }),
// 62:       }
// 63:     end
// 64:
// 65:     it "finds versions in provided content" do
// 66:       expect(gnome.find_versions(url: gnome_url, content:))
// 67:         .to eq(match_data[:cached])
// 68:
// 69:       # These `strategy` blocks are unnecessary but they are intended to test
// 70:       # using a regex in a `strategy` block.
// 71:       expect(gnome.find_versions(url: gnome_url, content:) do |page, regex|
// 72:         page.scan(regex).map(&:first)
// 73:       end).to eq(match_data[:cached])
// 74:
// 75:       expect(gnome.find_versions(url: gnome_url, regex: generated[:regex], content:) do |page, regex|
// 76:         page.scan(regex).map(&:first)
// 77:       end).to eq(match_data[:cached].merge({ matches: matches[:all].to_h { |v| [v, Version.new(v)] } }))
// 78:     end
// 79:
// 80:     it "returns default match_data when content is blank" do
// 81:       expect(gnome.find_versions(url: gnome_url, content: ""))
// 82:         .to eq(match_data[:cached_default])
// 83:     end
// 84:   end
// 85: end
