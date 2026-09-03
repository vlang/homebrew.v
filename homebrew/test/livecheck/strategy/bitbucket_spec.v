module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as bitbucket_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/bitbucket_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BitbucketSpecMatchData {
pub:
	cached         bitbucket_core.PageMatchData
	cached_default bitbucket_core.PageMatchData
}

fn bitbucket_spec_scan_block(page string,
	provided ?bitbucket_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := bitbucket_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn bitbucket_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached Bitbucket content unexpectedly fetched')
}

fn bitbucket_spec_regex_equal(left ?bitbucket_core.PageMatchRegex,
	right ?bitbucket_core.PageMatchRegex) bool {
	left_value := left or { bitbucket_core.PageMatchRegex{} }
	right_value := right or { bitbucket_core.PageMatchRegex{} }
	return left_value == right_value
}

fn bitbucket_spec_match_data_equal(left bitbucket_core.PageMatchData,
	right bitbucket_core.PageMatchData) bool {
	return left.matches == right.matches && bitbucket_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:bitbucket) { described_class }` at line 7.
pub fn ruby_bitbucket_spec_l7_d1_bitbucket() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Bitbucket')
}

// Ruby let `let(:bitbucket_urls) do` at line 9.
pub fn ruby_bitbucket_spec_l9_d2_bitbucket_urls() map[string]string {
	return {
		'get':       'https://bitbucket.org/abc/def/get/1.2.3.tar.gz'
		'downloads': 'https://bitbucket.org/abc/def/downloads/ghi-1.2.3.tar.gz'
	}
}

// Ruby let `let(:non_bitbucket_url) { "https://brew.sh/test" }` at line 15.
pub fn ruby_bitbucket_spec_l15_d3_non_bitbucket_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 16.
pub fn ruby_bitbucket_spec_l16_d4_generated() map[string]bitbucket_core.BitbucketInputValues {
	return {
		'get':       bitbucket_core.BitbucketInputValues{
			present: true
			url: 'https://bitbucket.org/abc/def/downloads/?tab=tags&iframe=true&spa=0'
			regex: bitbucket_core.PageMatchRegex{
				pattern: '<td[^>]*?class="name"[^>]*?>\\s*v?(\\d+(?:\\.\\d+)+)\\s*?<'
				case_insensitive: true
			}
		}
		'downloads': bitbucket_core.BitbucketInputValues{
			present: true
			url: 'https://bitbucket.org/abc/def/downloads/?iframe=true&spa=0'
			regex: bitbucket_core.PageMatchRegex{
				pattern: 'href=.*?ghi-v?(\\d+(?:\\.\\d+)+)\\.t'
				case_insensitive: true
			}
		}
	}
}

// Ruby let `let(:content) do` at line 29.
pub fn ruby_bitbucket_spec_l29_d5_content() string {
	return '<!DOCTYPE html>\n<html><body><table id="uploaded-files">\n<a href="/abc/def/downloads/ghi-1.2.3.tar.gz">ghi-1.2.3.tar.gz</a>\n<a href="/abc/def/downloads/ghi-1.2.2.tar.gz">ghi-1.2.2.tar.gz</a>\n<a href="/abc/def/downloads/ghi-1.2.1.tar.gz">ghi-1.2.1.tar.gz</a>\n</table></body></html>\n'
}

// Ruby let `let(:matches) { ["1.2.3", "1.2.2", "1.2.1"] }` at line 84.
pub fn ruby_bitbucket_spec_l84_d6_matches() []string {
	return ['1.2.3', '1.2.2', '1.2.1']
}

// Ruby it `it "returns true for a Bitbucket URL" do` at line 87.
pub fn ruby_bitbucket_spec_l87_d7_returns() bool {
	for url in ruby_bitbucket_spec_l9_d2_bitbucket_urls().values() {
		if !bitbucket_core.bitbucket_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-Bitbucket URL" do` at line 92.
pub fn ruby_bitbucket_spec_l92_d8_returns() bool {
	return !bitbucket_core.bitbucket_matches_url(ruby_bitbucket_spec_l15_d3_non_bitbucket_url())
}

// Ruby it `it "returns a hash containing url and regex for a Bitbucket URL" do` at line 98.
pub fn ruby_bitbucket_spec_l98_d9_returns() bool {
	urls := ruby_bitbucket_spec_l9_d2_bitbucket_urls()
	generated := ruby_bitbucket_spec_l16_d4_generated()
	for key, url in urls {
		if bitbucket_core.bitbucket_generate_input_values(url) != generated[key] {
			return false
		}
	}
	return true
}

// Ruby it `it "returns an empty hash for a non-Bitbucket URL" do` at line 103.
pub fn ruby_bitbucket_spec_l103_d10_returns() bool {
	return !bitbucket_core.bitbucket_generate_input_values(ruby_bitbucket_spec_l15_d3_non_bitbucket_url()).present
}

// Ruby let `let(:match_data) do` at line 109.
pub fn ruby_bitbucket_spec_l109_d11_match_data() BitbucketSpecMatchData {
	generated := ruby_bitbucket_spec_l16_d4_generated()['downloads']
	base := bitbucket_core.PageMatchData{
		matches: {
			'1.2.3': '1.2.3'
			'1.2.2': '1.2.2'
			'1.2.1': '1.2.1'
		}
		regex: generated.regex
		url: generated.url
		cached: true
		has_cached: true
	}
	return BitbucketSpecMatchData{
		cached: base
		cached_default: bitbucket_core.PageMatchData{
			...base
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 123.
pub fn ruby_bitbucket_spec_l123_d12_finds() bool {
	request := bitbucket_core.BitbucketFindRequest{
		url: ruby_bitbucket_spec_l9_d2_bitbucket_urls()['downloads']
		content: ruby_bitbucket_spec_l29_d5_content()
	}
	plain := bitbucket_core.bitbucket_find_versions(request, bitbucket_spec_unused_fetcher) or {
		return false
	}
	with_block := bitbucket_core.bitbucket_find_versions(bitbucket_core.BitbucketFindRequest{
		...request
		has_block: true
		block: bitbucket_spec_scan_block
	}, bitbucket_spec_unused_fetcher) or { return false }
	expected := ruby_bitbucket_spec_l109_d11_match_data().cached
	return bitbucket_spec_match_data_equal(plain, expected) && bitbucket_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 134.
pub fn ruby_bitbucket_spec_l134_d13_returns() bool {
	actual := bitbucket_core.bitbucket_find_versions(bitbucket_core.BitbucketFindRequest{
		url: ruby_bitbucket_spec_l9_d2_bitbucket_urls()['downloads']
		content: ''
	}, bitbucket_spec_unused_fetcher) or { return false }
	return bitbucket_spec_match_data_equal(actual, ruby_bitbucket_spec_l109_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Bitbucket do
// 7:   subject(:bitbucket) { described_class }
// 8:
// 9:   let(:bitbucket_urls) do
// 10:     {
// 11:       get:       "https://bitbucket.org/abc/def/get/1.2.3.tar.gz",
// 12:       downloads: "https://bitbucket.org/abc/def/downloads/ghi-1.2.3.tar.gz",
// 13:     }
// 14:   end
// 15:   let(:non_bitbucket_url) { "https://brew.sh/test" }
// 16:   let(:generated) do
// 17:     {
// 18:       get:       {
// 19:         url:   "https://bitbucket.org/abc/def/downloads/?tab=tags&iframe=true&spa=0",
// 20:         regex: /<td[^>]*?class="name"[^>]*?>\s*v?(\d+(?:\.\d+)+)\s*?</im,
// 21:       },
// 22:       downloads: {
// 23:         url:   "https://bitbucket.org/abc/def/downloads/?iframe=true&spa=0",
// 24:         regex: /href=.*?ghi-v?(\d+(?:\.\d+)+)\.t/i,
// 25:       },
// 26:     }
// 27:   end
// 28:   # This example HTML omits table columns for the sake of brevity.
// 29:   let(:content) do
// 30:     <<~HTML
// 31:       <!DOCTYPE html>
// 32:       <html>
// 33:         <head>
// 34:           <meta charset="utf-8">
// 35:           <title>abc / def / Downloads &mdash; Bitbucket</title>
// 36:         </head>
// 37:         <body>
// 38:           <table id="uploaded-files">
// 39:           <thead>
// 40:             <tr>
// 41:               <th class="name">Name</th>
// 42:               <th class="size">Size</th>
// 43:               <th class="date">Date</th>
// 44:             </tr>
// 45:           </thead>
// 46:           <tbody>
// 47:             <tr class="iterable-item" id="download-12345678">
// 48:               <td class="name">
// 49:                 <a href="/abc/def/downloads/ghi-1.2.3.tar.gz">ghi-1.2.3.tar.gz</a>
// 50:               </td>
// 51:               <td class="size">4.5\u00A0MB</td>
// 52:               <td class="date">
// 53:                 <div>
// 54:                   <time datetime="2022-01-23T01:23:45.678901" data-title="true">2022-01-23</time>
// 55:                 </div>
// 56:               </td>
// 57:             </tr>
// 58:             <tr class="iterable-item" id="download-12345677">
// 59:               <td class="name">
// 60:                 <a href="/abc/def/downloads/ghi-1.2.2.tar.gz">ghi-1.2.2.tar.gz</a>
// 61:               </td>
// 62:               <td class="size">3.4\u00A0MB</td>
// 63:               <td class="date">
// 64:                 <div>
// 65:                   <time datetime="2022-01-22T01:22:34.567890" data-title="true">2022-01-22</time>
// 66:                 </div>
// 67:               </td>
// 68:             </tr>
// 69:             <tr class="iterable-item" id="download-12345676">
// 70:               <td class="name">
// 71:                 <a href="/abc/def/downloads/ghi-1.2.1.tar.gz">ghi-1.2.1.tar.gz</a>
// 72:               </td>
// 73:               <td class="size">2.3\u00A0MB</td>
// 74:               <td class="date">
// 75:                 <div>
// 76:                   <time datetime="2022-01-21T01:21:23.456789" data-title="true">2022-01-21</time>
// 77:                 </div>
// 78:               </td>
// 79:             </tr>
// 80:         </body>
// 81:       </html>
// 82:     HTML
// 83:   end
// 84:   let(:matches) { ["1.2.3", "1.2.2", "1.2.1"] }
// 85:
// 86:   describe "::match?" do
// 87:     it "returns true for a Bitbucket URL" do
// 88:       expect(bitbucket.match?(bitbucket_urls[:get])).to be true
// 89:       expect(bitbucket.match?(bitbucket_urls[:downloads])).to be true
// 90:     end
// 91:
// 92:     it "returns false for a non-Bitbucket URL" do
// 93:       expect(bitbucket.match?(non_bitbucket_url)).to be false
// 94:     end
// 95:   end
// 96:
// 97:   describe "::generate_input_values" do
// 98:     it "returns a hash containing url and regex for a Bitbucket URL" do
// 99:       expect(bitbucket.generate_input_values(bitbucket_urls[:get])).to eq(generated[:get])
// 100:       expect(bitbucket.generate_input_values(bitbucket_urls[:downloads])).to eq(generated[:downloads])
// 101:     end
// 102:
// 103:     it "returns an empty hash for a non-Bitbucket URL" do
// 104:       expect(bitbucket.generate_input_values(non_bitbucket_url)).to eq({})
// 105:     end
// 106:   end
// 107:
// 108:   describe "::find_versions" do
// 109:     let(:match_data) do
// 110:       cached = {
// 111:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 112:         regex:   generated[:downloads][:regex],
// 113:         url:     generated[:downloads][:url],
// 114:         cached:  true,
// 115:       }
// 116:
// 117:       {
// 118:         cached:,
// 119:         cached_default: cached.merge({ matches: {} }),
// 120:       }
// 121:     end
// 122:
// 123:     it "finds versions in provided content" do
// 124:       expect(bitbucket.find_versions(url: bitbucket_urls[:downloads], content:))
// 125:         .to eq(match_data[:cached])
// 126:
// 127:       # This `strategy` block is unnecessary but it's intended to test using a
// 128:       # generated regex in a `strategy` block.
// 129:       expect(bitbucket.find_versions(url: bitbucket_urls[:downloads], content:) do |page, regex|
// 130:         page.scan(regex).map(&:first)
// 131:       end).to eq(match_data[:cached])
// 132:     end
// 133:
// 134:     it "returns default match_data when content is blank" do
// 135:       expect(bitbucket.find_versions(url: bitbucket_urls[:downloads], content: ""))
// 136:         .to eq(match_data[:cached_default])
// 137:     end
// 138:   end
// 139: end
