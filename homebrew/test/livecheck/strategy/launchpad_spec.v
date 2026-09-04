module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as launchpad_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/launchpad_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct LaunchpadSpecMatchData {
pub:
	cached         launchpad_core.PageMatchData
	cached_default launchpad_core.PageMatchData
}

fn launchpad_spec_scan_block(page string,
	provided ?launchpad_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := launchpad_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn launchpad_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached Launchpad content unexpectedly fetched')
}

fn launchpad_spec_regex_equal(left ?launchpad_core.PageMatchRegex,
	right ?launchpad_core.PageMatchRegex) bool {
	left_value := left or { launchpad_core.PageMatchRegex{} }
	right_value := right or { launchpad_core.PageMatchRegex{} }
	return left_value == right_value
}

fn launchpad_spec_match_data_equal(left launchpad_core.PageMatchData,
	right launchpad_core.PageMatchData) bool {
	return left.matches == right.matches && launchpad_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:launchpad) { described_class }` at line 7.
pub fn ruby_launchpad_spec_l7_d1_launchpad() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::Launchpad')
}

// Ruby let `let(:launchpad_urls) do` at line 9.
pub fn ruby_launchpad_spec_l9_d2_launchpad_urls() map[string]string {
	return {
		'version_dir':    'https://launchpad.net/abc/1.2/1.2.3/+download/abc-1.2.3.tar.gz'
		'trunk':          'https://launchpad.net/abc/trunk/1.2.3/+download/abc-1.2.3.tar.gz'
		'code_subdomain': 'https://code.launchpad.net/abc/1.2/1.2.3/+download/abc-1.2.3.tar.gz'
	}
}

// Ruby let `let(:non_launchpad_url) { "https://brew.sh/test" }` at line 16.
pub fn ruby_launchpad_spec_l16_d3_non_launchpad_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 17.
pub fn ruby_launchpad_spec_l17_d4_generated() launchpad_core.LaunchpadInputValues {
	return launchpad_core.LaunchpadInputValues{
		present: true
		url: 'https://launchpad.net/abc/'
	}
}

// Ruby let `let(:content) do` at line 24.
pub fn ruby_launchpad_spec_l24_d5_content() string {
	return [
		'<!DOCTYPE html>',
		'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">',
		'  <head>',
		'    <meta charset="UTF-8"/>',
		'    <title>abc in Launchpad</title>',
		'  </head>',
		'  <body>',
		'    <div id="downloads" class="top-portlet downloads">',
		'      <h2>Downloads</h2>',
		'      <div class="version">Latest version is 1.2.3</div>',
		'      <ul>',
		'        <li>',
		'          <a href="https://launchpad.net/abc/trunk/1.2.3/+download/abc-1.2.3.tar.gz" title="abc 1.2.3">abc-1.2.3.tar.gz</a>',
		'        </li>',
		'      </ul>',
		'',
		'      <div class="released">',
		'        released',
		'        <time title="2022-01-23 01:23:45 UTC" datetime="2022-01-23T01:23:45+00:00">on 2022-01-23</time>',
		'      </div>',
		'',
		'      <p class="alternate">',
		'        <a class="sprite info" href="https://launchpad.net/abc/+download">All downloads</a>',
		'      </p>',
		'    </div>',
		'  </body>',
		'</html>',
	].join('\n') + '\n'
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 55.
pub fn ruby_launchpad_spec_l55_d6_matches() []string {
	return ['1.2.3']
}

// Ruby it `it "returns true for a Launchpad URL" do` at line 58.
pub fn ruby_launchpad_spec_l58_d7_returns() bool {
	for url in ruby_launchpad_spec_l9_d2_launchpad_urls().values() {
		if !launchpad_core.launchpad_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-Launchpad URL" do` at line 64.
pub fn ruby_launchpad_spec_l64_d8_returns() bool {
	return !launchpad_core.launchpad_matches_url(ruby_launchpad_spec_l16_d3_non_launchpad_url())
}

// Ruby it `it "returns a hash containing url and regex for an Launchpad URL" do` at line 70.
pub fn ruby_launchpad_spec_l70_d9_returns() bool {
	expected := ruby_launchpad_spec_l17_d4_generated()
	for url in ruby_launchpad_spec_l9_d2_launchpad_urls().values() {
		if launchpad_core.launchpad_generate_input_values(url) != expected {
			return false
		}
	}
	return true
}

// Ruby it `it "returns an empty hash for a non-Launchpad URL" do` at line 76.
pub fn ruby_launchpad_spec_l76_d10_returns() bool {
	return !launchpad_core.launchpad_generate_input_values(ruby_launchpad_spec_l16_d3_non_launchpad_url()).present
}

// Ruby let `let(:match_data) do` at line 82.
pub fn ruby_launchpad_spec_l82_d11_match_data() LaunchpadSpecMatchData {
	base := launchpad_core.PageMatchData{
		matches: {
			'1.2.3': '1.2.3'
		}
		regex: launchpad_core.PageMatchRegex{
			pattern: launchpad_core.launchpad_default_pattern
		}
		url: ruby_launchpad_spec_l17_d4_generated().url
		cached: true
		has_cached: true
	}
	return LaunchpadSpecMatchData{
		cached: base
		cached_default: launchpad_core.PageMatchData{
			...base
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 96.
pub fn ruby_launchpad_spec_l96_d12_finds() bool {
	url := ruby_launchpad_spec_l9_d2_launchpad_urls()['trunk']
	content := ruby_launchpad_spec_l24_d5_content()
	direct := launchpad_core.launchpad_find_versions(launchpad_core.LaunchpadFindRequest{
		url: url
		content: content
	}, launchpad_spec_unused_fetcher) or { return false }

	// This `strategy` block is unnecessary but it's intended to test using a
	// generated regex in a `strategy` block.
	with_block := launchpad_core.launchpad_find_versions(launchpad_core.LaunchpadFindRequest{
		url: url
		content: content
		has_block: true
		block: launchpad_spec_scan_block
	}, launchpad_spec_unused_fetcher) or { return false }
	expected := ruby_launchpad_spec_l82_d11_match_data().cached
	return launchpad_spec_match_data_equal(direct, expected) && launchpad_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 107.
pub fn ruby_launchpad_spec_l107_d13_returns() bool {
	actual := launchpad_core.launchpad_find_versions(launchpad_core.LaunchpadFindRequest{
		url: ruby_launchpad_spec_l9_d2_launchpad_urls()['trunk']
		content: ''
	}, launchpad_spec_unused_fetcher) or { return false }
	return launchpad_spec_match_data_equal(actual, ruby_launchpad_spec_l82_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Launchpad do
// 7:   subject(:launchpad) { described_class }
// 8:
// 9:   let(:launchpad_urls) do
// 10:     {
// 11:       version_dir:    "https://launchpad.net/abc/1.2/1.2.3/+download/abc-1.2.3.tar.gz",
// 12:       trunk:          "https://launchpad.net/abc/trunk/1.2.3/+download/abc-1.2.3.tar.gz",
// 13:       code_subdomain: "https://code.launchpad.net/abc/1.2/1.2.3/+download/abc-1.2.3.tar.gz",
// 14:     }
// 15:   end
// 16:   let(:non_launchpad_url) { "https://brew.sh/test" }
// 17:   let(:generated) do
// 18:     {
// 19:       url: "https://launchpad.net/abc/",
// 20:     }
// 21:   end
// 22:   # The whitespace in a real response is a bit looser and this has been
// 23:   # reformatted for the sake of brevity.
// 24:   let(:content) do
// 25:     <<~HTML
// 26:       <!DOCTYPE html>
// 27:       <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
// 28:         <head>
// 29:           <meta charset="UTF-8"/>
// 30:           <title>abc in Launchpad</title>
// 31:         </head>
// 32:         <body>
// 33:           <div id="downloads" class="top-portlet downloads">
// 34:             <h2>Downloads</h2>
// 35:             <div class="version">Latest version is 1.2.3</div>
// 36:             <ul>
// 37:               <li>
// 38:                 <a href="https://launchpad.net/abc/trunk/1.2.3/+download/abc-1.2.3.tar.gz" title="abc 1.2.3">abc-1.2.3.tar.gz</a>
// 39:               </li>
// 40:             </ul>
// 41:
// 42:             <div class="released">
// 43:               released
// 44:               <time title="2022-01-23 01:23:45 UTC" datetime="2022-01-23T01:23:45+00:00">on 2022-01-23</time>
// 45:             </div>
// 46:
// 47:             <p class="alternate">
// 48:               <a class="sprite info" href="https://launchpad.net/abc/+download">All downloads</a>
// 49:             </p>
// 50:           </div>
// 51:         </body>
// 52:       </html>
// 53:     HTML
// 54:   end
// 55:   let(:matches) { ["1.2.3"] }
// 56:
// 57:   describe "::match?" do
// 58:     it "returns true for a Launchpad URL" do
// 59:       expect(launchpad.match?(launchpad_urls[:version_dir])).to be true
// 60:       expect(launchpad.match?(launchpad_urls[:trunk])).to be true
// 61:       expect(launchpad.match?(launchpad_urls[:code_subdomain])).to be true
// 62:     end
// 63:
// 64:     it "returns false for a non-Launchpad URL" do
// 65:       expect(launchpad.match?(non_launchpad_url)).to be false
// 66:     end
// 67:   end
// 68:
// 69:   describe "::generate_input_values" do
// 70:     it "returns a hash containing url and regex for an Launchpad URL" do
// 71:       expect(launchpad.generate_input_values(launchpad_urls[:version_dir])).to eq(generated)
// 72:       expect(launchpad.generate_input_values(launchpad_urls[:trunk])).to eq(generated)
// 73:       expect(launchpad.generate_input_values(launchpad_urls[:code_subdomain])).to eq(generated)
// 74:     end
// 75:
// 76:     it "returns an empty hash for a non-Launchpad URL" do
// 77:       expect(launchpad.generate_input_values(non_launchpad_url)).to eq({})
// 78:     end
// 79:   end
// 80:
// 81:   describe "::find_versions" do
// 82:     let(:match_data) do
// 83:       cached = {
// 84:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 85:         regex:   Homebrew::Livecheck::Strategy::Launchpad::DEFAULT_REGEX,
// 86:         url:     generated[:url],
// 87:         cached:  true,
// 88:       }
// 89:
// 90:       {
// 91:         cached:,
// 92:         cached_default: cached.merge({ matches: {} }),
// 93:       }
// 94:     end
// 95:
// 96:     it "finds versions in provided content" do
// 97:       expect(launchpad.find_versions(url: launchpad_urls[:trunk], content:))
// 98:         .to eq(match_data[:cached])
// 99:
// 100:       # This `strategy` block is unnecessary but it's intended to test using a
// 101:       # generated regex in a `strategy` block.
// 102:       expect(launchpad.find_versions(url: launchpad_urls[:trunk], content:) do |page, regex|
// 103:         page.scan(regex).map(&:first)
// 104:       end).to eq(match_data[:cached])
// 105:     end
// 106:
// 107:     it "returns default match_data when content is blank" do
// 108:       expect(launchpad.find_versions(url: launchpad_urls[:trunk], content: ""))
// 109:         .to eq(match_data[:cached_default])
// 110:     end
// 111:   end
// 112: end
