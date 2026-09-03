module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as hackage_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/hackage_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct HackageSpecMatchData {
pub:
	cached         hackage_core.PageMatchData
	cached_default hackage_core.PageMatchData
}

fn hackage_spec_scan_block(page string,
	provided ?hackage_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := hackage_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn hackage_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached Hackage content unexpectedly fetched')
}

fn hackage_spec_regex_equal(left ?hackage_core.PageMatchRegex,
	right ?hackage_core.PageMatchRegex) bool {
	left_value := left or { hackage_core.PageMatchRegex{} }
	right_value := right or { hackage_core.PageMatchRegex{} }
	return left_value == right_value
}

fn hackage_spec_match_data_equal(left hackage_core.PageMatchData,
	right hackage_core.PageMatchData) bool {
	return left.matches == right.matches && hackage_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:hackage) { described_class }` at line 7.
pub fn ruby_hackage_spec_l7_d1_hackage() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Hackage')
}

// Ruby let `let(:hackage_urls) do` at line 9.
pub fn ruby_hackage_spec_l9_d2_hackage_urls() map[string]string {
	return {
		'package':   'https://hackage.haskell.org/package/abc-1.2.3/abc-1.2.3.tar.gz'
		'downloads': 'https://downloads.haskell.org/~abc/1.2.3/abc-1.2.3-src.tar.xz'
	}
}

// Ruby let `let(:non_hackage_url) { "https://brew.sh/test" }` at line 15.
pub fn ruby_hackage_spec_l15_d3_non_hackage_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 16.
pub fn ruby_hackage_spec_l16_d4_generated() hackage_core.HackageInputValues {
	return hackage_core.HackageInputValues{
		present: true
		url: 'https://hackage.haskell.org/package/abc/src/'
		regex: hackage_core.PageMatchRegex{
			pattern: '<h3>abc-(.*?)/?</h3>'
			case_insensitive: true
		}
	}
}

// Ruby let `let(:content) do` at line 22.
pub fn ruby_hackage_spec_l22_d5_content() string {
	return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN">\n<html><head><title>Directory listing for abc-1.2.3 source tarball | Hackage</title></head><body><h3>abc-1.2.3/</h3></body></html>\n'
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 51.
pub fn ruby_hackage_spec_l51_d6_matches() []string {
	return ['1.2.3']
}

// Ruby it `it "returns true for a Hackage URL" do` at line 54.
pub fn ruby_hackage_spec_l54_d7_returns() bool {
	for url in ruby_hackage_spec_l9_d2_hackage_urls().values() {
		if !hackage_core.hackage_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-Hackage URL" do` at line 59.
pub fn ruby_hackage_spec_l59_d8_returns() bool {
	return !hackage_core.hackage_matches_url(ruby_hackage_spec_l15_d3_non_hackage_url())
}

// Ruby it `it "returns a hash containing url and regex for a Hackage URL" do` at line 65.
pub fn ruby_hackage_spec_l65_d9_returns() bool {
	for url in ruby_hackage_spec_l9_d2_hackage_urls().values() {
		if hackage_core.hackage_generate_input_values(url) != ruby_hackage_spec_l16_d4_generated() {
			return false
		}
	}
	return true
}

// Ruby it `it "returns an empty hash for a non-Hackage URL" do` at line 70.
pub fn ruby_hackage_spec_l70_d10_returns() bool {
	return !hackage_core.hackage_generate_input_values(ruby_hackage_spec_l15_d3_non_hackage_url()).present
}

// Ruby let `let(:match_data) do` at line 76.
pub fn ruby_hackage_spec_l76_d11_match_data() HackageSpecMatchData {
	base := hackage_core.PageMatchData{
		matches: {
			'1.2.3': '1.2.3'
		}
		regex: ruby_hackage_spec_l16_d4_generated().regex
		url: ruby_hackage_spec_l16_d4_generated().url
		cached: true
		has_cached: true
	}
	return HackageSpecMatchData{
		cached: base
		cached_default: hackage_core.PageMatchData{
			...base
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 90.
pub fn ruby_hackage_spec_l90_d12_finds() bool {
	request := hackage_core.HackageFindRequest{
		url: ruby_hackage_spec_l9_d2_hackage_urls()['package']
		content: ruby_hackage_spec_l22_d5_content()
	}
	plain := hackage_core.hackage_find_versions(request, hackage_spec_unused_fetcher) or {
		return false
	}
	with_block := hackage_core.hackage_find_versions(hackage_core.HackageFindRequest{
		...request
		has_block: true
		block: hackage_spec_scan_block
	}, hackage_spec_unused_fetcher) or { return false }
	expected := ruby_hackage_spec_l76_d11_match_data().cached
	return hackage_spec_match_data_equal(plain, expected) && hackage_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 101.
pub fn ruby_hackage_spec_l101_d13_returns() bool {
	actual := hackage_core.hackage_find_versions(hackage_core.HackageFindRequest{
		url: ruby_hackage_spec_l9_d2_hackage_urls()['package']
		content: ''
	}, hackage_spec_unused_fetcher) or { return false }
	return hackage_spec_match_data_equal(actual, ruby_hackage_spec_l76_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Hackage do
// 7:   subject(:hackage) { described_class }
// 8:
// 9:   let(:hackage_urls) do
// 10:     {
// 11:       package:   "https://hackage.haskell.org/package/abc-1.2.3/abc-1.2.3.tar.gz",
// 12:       downloads: "https://downloads.haskell.org/~abc/1.2.3/abc-1.2.3-src.tar.xz",
// 13:     }
// 14:   end
// 15:   let(:non_hackage_url) { "https://brew.sh/test" }
// 16:   let(:generated) do
// 17:     {
// 18:       url:   "https://hackage.haskell.org/package/abc/src/",
// 19:       regex: %r{<h3>abc-(.*?)/?</h3>}i,
// 20:     }
// 21:   end
// 22:   let(:content) do
// 23:     <<~HTML
// 24:       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
// 25:       <html xmlns="http://www.w3.org/1999/xhtml">
// 26:       <head>
// 27:         <title>Directory listing for abc-1.2.3 source tarball | Hackage</title>
// 28:       </head>
// 29:       <body>
// 30:         <div id="content">
// 31:           <h2>Directory listing for abc-1.2.3 source tarball</h2>
// 32:           <h3>abc-1.2.3/</h3>
// 33:           <ul class="directory-list">
// 34:             <li>
// 35:               <a href="CHANGELOG">CHANGELOG</a>
// 36:             </li>
// 37:             <li>
// 38:               <a href="abc">abc/</a>
// 39:               <ul class="directory-list">
// 40:                 <li>
// 41:                   <a href="abc/abc.hs">abc.hs</a>
// 42:                 </li>
// 43:               </ul>
// 44:             </li>
// 45:           </ul>
// 46:         </div>
// 47:       </body>
// 48:       </html>
// 49:     HTML
// 50:   end
// 51:   let(:matches) { ["1.2.3"] }
// 52:
// 53:   describe "::match?" do
// 54:     it "returns true for a Hackage URL" do
// 55:       expect(hackage.match?(hackage_urls[:package])).to be true
// 56:       expect(hackage.match?(hackage_urls[:downloads])).to be true
// 57:     end
// 58:
// 59:     it "returns false for a non-Hackage URL" do
// 60:       expect(hackage.match?(non_hackage_url)).to be false
// 61:     end
// 62:   end
// 63:
// 64:   describe "::generate_input_values" do
// 65:     it "returns a hash containing url and regex for a Hackage URL" do
// 66:       expect(hackage.generate_input_values(hackage_urls[:package])).to eq(generated)
// 67:       expect(hackage.generate_input_values(hackage_urls[:downloads])).to eq(generated)
// 68:     end
// 69:
// 70:     it "returns an empty hash for a non-Hackage URL" do
// 71:       expect(hackage.generate_input_values(non_hackage_url)).to eq({})
// 72:     end
// 73:   end
// 74:
// 75:   describe "::find_versions" do
// 76:     let(:match_data) do
// 77:       cached = {
// 78:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 79:         regex:   generated[:regex],
// 80:         url:     generated[:url],
// 81:         cached:  true,
// 82:       }
// 83:
// 84:       {
// 85:         cached:,
// 86:         cached_default: cached.merge({ matches: {} }),
// 87:       }
// 88:     end
// 89:
// 90:     it "finds versions in provided content" do
// 91:       expect(hackage.find_versions(url: hackage_urls[:package], content:))
// 92:         .to eq(match_data[:cached])
// 93:
// 94:       # This `strategy` block is unnecessary but it's intended to test using a
// 95:       # generated regex in a `strategy` block.
// 96:       expect(hackage.find_versions(url: hackage_urls[:package], content:) do |page, regex|
// 97:         page.scan(regex).map(&:first)
// 98:       end).to eq(match_data[:cached])
// 99:     end
// 100:
// 101:     it "returns default match_data when content is blank" do
// 102:       expect(hackage.find_versions(url: hackage_urls[:package], content: ""))
// 103:         .to eq(match_data[:cached_default])
// 104:     end
// 105:   end
// 106: end
