module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as gnu_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/gnu_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GnuSpecMatchData {
pub:
	cached         gnu_core.PageMatchData
	cached_default gnu_core.PageMatchData
}

fn gnu_spec_expected_input() gnu_core.GnuInputValues {
	return gnu_core.GnuInputValues{
		present: true
		url: 'https://ftpmirror.gnu.org/gnu/abc/'
		regex: gnu_core.PageMatchRegex{
			pattern: r'href=.*?abc[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)'
			case_insensitive: true
		}
	}
}

fn gnu_spec_scan_block(page string,
	provided ?gnu_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := gnu_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn gnu_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached GNU content unexpectedly fetched')
}

fn gnu_spec_regex_equal(left ?gnu_core.PageMatchRegex,
	right ?gnu_core.PageMatchRegex) bool {
	if left_value := left {
		right_value := right or { return false }
		return left_value == right_value
	}
	if _ := right {
		return false
	}
	return true
}

fn gnu_spec_match_data_equal(left gnu_core.PageMatchData,
	right gnu_core.PageMatchData) bool {
	return left.matches == right.matches && gnu_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:gnu) { described_class }` at line 7.
pub fn ruby_gnu_spec_l7_d1_gnu() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::Gnu')
}

// Ruby let `let(:gnu_urls) do` at line 9.
pub fn ruby_gnu_spec_l9_d2_gnu_urls() map[string]string {
	return {
		'no_version_dir': 'https://ftpmirror.gnu.org/gnu/abc/abc-1.2.3.tar.gz'
		'software_page':  'https://www.gnu.org/software/abc/'
		'subdomain':      'https://abc.gnu.org'
		'savannah':       'https://download.savannah.gnu.org/releases/abc/abc-1.2.3.tar.gz'
	}
}

// Ruby let `let(:non_gnu_url) { "https://brew.sh/test" }` at line 17.
pub fn ruby_gnu_spec_l17_d3_non_gnu_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 18.
pub fn ruby_gnu_spec_l18_d4_generated() map[string]gnu_core.GnuInputValues {
	expected := gnu_spec_expected_input()
	return {
		'no_version_dir': expected
		'software_page':  expected
		'subdomain':      expected
		'savannah':       gnu_core.GnuInputValues{}
	}
}

// Ruby let `let(:content) do` at line 37.
pub fn ruby_gnu_spec_l37_d5_content() string {
	return [
		'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">',
		'<html>',
		'<head>',
		'  <title>Index of /gnu/abc</title>',
		'</head>',
		'<body>',
		'  <h1>Index of /gnu/abc</h1>',
		'  <table>',
		'    <tr>',
		'      <th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th>',
		'      <th><a href="?C=N;O=D">Name</a></th>',
		'      <th><a href="?C=M;O=A">Last modified</a></th>',
		'      <th><a href="?C=S;O=A">Size</a></th>',
		'      <th><a href="?C=D;O=A">Description</a></th>',
		'    </tr>',
		'    <tr>',
		'      <th colspan="5"><hr></th>',
		'    </tr>',
		'    <tr>',
		'      <td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td>',
		'      <td><a href="/gnu/">Parent Directory</a></td>',
		'      <td>&nbsp;</td>',
		'      <td align="right">  - </td>',
		'      <td>&nbsp;</td>',
		'    </tr>',
		'    <tr>',
		'      <td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td>',
		'      <td><a href="abc-1.2.2.tar.gz">abc-1.2.2.tar.gz</a></td>',
		'      <td align="right">2022-01-22 01:22  </td>',
		'      <td align="right">3.4M</td>',
		'      <td>&nbsp;</td>',
		'    </tr>',
		'    <tr>',
		'      <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>',
		'      <td><a href="abc-1.2.2.tar.gz.sig">abc-1.2.2.tar.gz.sig</a></td>',
		'      <td align="right">2022-01-22 01:22  </td>',
		'      <td align="right">345 </td>',
		'      <td>&nbsp;</td>',
		'    </tr>',
		'    <tr>',
		'      <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>',
		'      <td><a href="abc-1.2.3.tar.xz">abc-1.2.3.tar.xz</a></td>',
		'      <td align="right">2022-01-23 01:23  </td>',
		'      <td align="right">4.5M</td>',
		'      <td>&nbsp;</td>',
		'    </tr>',
		'    <tr>',
		'      <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>',
		'      <td><a href="abc-1.2.3.tar.xz.sig">abc-1.2.3.tar.xz.sig</a></td>',
		'      <td align="right">2022-01-23 01:23  </td>',
		'      <td align="right">456 </td>',
		'      <td>&nbsp;</td>',
		'    </tr>',
		'    <tr>',
		'      <th colspan="5"><hr></th>',
		'    </tr>',
		'  </table>',
		'  <address>Apache/2.4.29 (Trisquel_GNU/Linux) Server at ftp.gnu.org Port 443</address>',
		'</body>',
		'</html>',
	].join('\n') + '\n\n'
}

// Ruby let `let(:matches) { ["1.2.2", "1.2.3"] }` at line 102.
pub fn ruby_gnu_spec_l102_d6_matches() []string {
	return ['1.2.2', '1.2.3']
}

// Ruby it `it "returns true for a [non-Savannah] GNU URL" do` at line 105.
pub fn ruby_gnu_spec_l105_d7_returns() bool {
	urls := ruby_gnu_spec_l9_d2_gnu_urls()
	return gnu_core.gnu_matches_url(urls['no_version_dir']) && gnu_core.gnu_matches_url(urls['software_page']) && gnu_core.gnu_matches_url(urls['subdomain'])
}

// Ruby it `it "returns false for a Savannah GNU URL" do` at line 111.
pub fn ruby_gnu_spec_l111_d8_returns() bool {
	return !gnu_core.gnu_matches_url(ruby_gnu_spec_l9_d2_gnu_urls()['savannah'])
}

// Ruby it `it "returns false for a non-GNU URL (not nongnu.org)" do` at line 115.
pub fn ruby_gnu_spec_l115_d9_returns() bool {
	return !gnu_core.gnu_matches_url(ruby_gnu_spec_l17_d3_non_gnu_url())
}

// Ruby it `it "returns a hash containing url and regex for a [non-Savannah] GNU URL" do` at line 121.
pub fn ruby_gnu_spec_l121_d10_returns() bool {
	urls := ruby_gnu_spec_l9_d2_gnu_urls()
	generated := ruby_gnu_spec_l18_d4_generated()
	return gnu_core.gnu_generate_input_values(urls['no_version_dir']) == generated['no_version_dir'] && gnu_core.gnu_generate_input_values(urls['software_page']) == generated['software_page'] && gnu_core.gnu_generate_input_values(urls['subdomain']) == generated['subdomain']
}

// Ruby it `it "returns an empty hash for a Savannah GNU URL" do` at line 127.
pub fn ruby_gnu_spec_l127_d11_returns() bool {
	return gnu_core.gnu_generate_input_values(ruby_gnu_spec_l9_d2_gnu_urls()['savannah']) == ruby_gnu_spec_l18_d4_generated()['savannah']
}

// Ruby it `it "returns an empty hash for a non-GNU URL (not nongnu.org)" do` at line 131.
pub fn ruby_gnu_spec_l131_d12_returns() bool {
	return !gnu_core.gnu_generate_input_values(ruby_gnu_spec_l17_d3_non_gnu_url()).present
}

// Ruby let `let(:match_data) do` at line 137.
pub fn ruby_gnu_spec_l137_d13_match_data() GnuSpecMatchData {
	generated := gnu_spec_expected_input()
	mut matches := map[string]string{}
	for version in ruby_gnu_spec_l102_d6_matches() {
		matches[version] = version
	}
	return GnuSpecMatchData{
		cached: gnu_core.PageMatchData{
			matches: matches
			regex: generated.regex
			url: generated.url
			cached: true
			has_cached: true
		}
		cached_default: gnu_core.PageMatchData{
			matches: map[string]string{}
			regex: generated.regex
			url: generated.url
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 151.
pub fn ruby_gnu_spec_l151_d14_finds() bool {
	url := ruby_gnu_spec_l9_d2_gnu_urls()['no_version_dir']
	content := ruby_gnu_spec_l37_d5_content()
	direct := gnu_core.gnu_find_versions(gnu_core.GnuFindRequest{
		url: url
		content: content
	}, gnu_spec_unused_fetcher) or { return false }
	with_block := gnu_core.gnu_find_versions(gnu_core.GnuFindRequest{
		url: url
		content: content
		has_block: true
		block: gnu_spec_scan_block
	}, gnu_spec_unused_fetcher) or { return false }
	expected := ruby_gnu_spec_l137_d13_match_data().cached
	return gnu_spec_match_data_equal(direct, expected) && gnu_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 162.
pub fn ruby_gnu_spec_l162_d15_returns() bool {
	actual := gnu_core.gnu_find_versions(gnu_core.GnuFindRequest{
		url: ruby_gnu_spec_l9_d2_gnu_urls()['no_version_dir']
		content: ''
	}, gnu_spec_unused_fetcher) or { return false }
	return gnu_spec_match_data_equal(actual, ruby_gnu_spec_l137_d13_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Gnu do
// 7:   subject(:gnu) { described_class }
// 8:
// 9:   let(:gnu_urls) do
// 10:     {
// 11:       no_version_dir: "https://ftpmirror.gnu.org/gnu/abc/abc-1.2.3.tar.gz",
// 12:       software_page:  "https://www.gnu.org/software/abc/",
// 13:       subdomain:      "https://abc.gnu.org",
// 14:       savannah:       "https://download.savannah.gnu.org/releases/abc/abc-1.2.3.tar.gz",
// 15:     }
// 16:   end
// 17:   let(:non_gnu_url) { "https://brew.sh/test" }
// 18:   let(:generated) do
// 19:     {
// 20:       no_version_dir: {
// 21:         url:   "https://ftpmirror.gnu.org/gnu/abc/",
// 22:         regex: %r{href=.*?abc[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)}i,
// 23:       },
// 24:       software_page:  {
// 25:         url:   "https://ftpmirror.gnu.org/gnu/abc/",
// 26:         regex: %r{href=.*?abc[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)}i,
// 27:       },
// 28:       subdomain:      {
// 29:         url:   "https://ftpmirror.gnu.org/gnu/abc/",
// 30:         regex: %r{href=.*?abc[._-]v?(\d+(?:\.\d+)*)(?:\.[a-z]+|/)}i,
// 31:       },
// 32:       savannah:       {},
// 33:     }
// 34:   end
// 35:   # The whitespace in a real response is a bit looser and this has been
// 36:   # reformatted for the sake of brevity.
// 37:   let(:content) do
// 38:     <<~HTML
// 39:       <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
// 40:       <html>
// 41:       <head>
// 42:         <title>Index of /gnu/abc</title>
// 43:       </head>
// 44:       <body>
// 45:         <h1>Index of /gnu/abc</h1>
// 46:         <table>
// 47:           <tr>
// 48:             <th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th>
// 49:             <th><a href="?C=N;O=D">Name</a></th>
// 50:             <th><a href="?C=M;O=A">Last modified</a></th>
// 51:             <th><a href="?C=S;O=A">Size</a></th>
// 52:             <th><a href="?C=D;O=A">Description</a></th>
// 53:           </tr>
// 54:           <tr>
// 55:             <th colspan="5"><hr></th>
// 56:           </tr>
// 57:           <tr>
// 58:             <td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td>
// 59:             <td><a href="/gnu/">Parent Directory</a></td>
// 60:             <td>&nbsp;</td>
// 61:             <td align="right">  - </td>
// 62:             <td>&nbsp;</td>
// 63:           </tr>
// 64:           <tr>
// 65:             <td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td>
// 66:             <td><a href="abc-1.2.2.tar.gz">abc-1.2.2.tar.gz</a></td>
// 67:             <td align="right">2022-01-22 01:22  </td>
// 68:             <td align="right">3.4M</td>
// 69:             <td>&nbsp;</td>
// 70:           </tr>
// 71:           <tr>
// 72:             <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>
// 73:             <td><a href="abc-1.2.2.tar.gz.sig">abc-1.2.2.tar.gz.sig</a></td>
// 74:             <td align="right">2022-01-22 01:22  </td>
// 75:             <td align="right">345 </td>
// 76:             <td>&nbsp;</td>
// 77:           </tr>
// 78:           <tr>
// 79:             <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>
// 80:             <td><a href="abc-1.2.3.tar.xz">abc-1.2.3.tar.xz</a></td>
// 81:             <td align="right">2022-01-23 01:23  </td>
// 82:             <td align="right">4.5M</td>
// 83:             <td>&nbsp;</td>
// 84:           </tr>
// 85:           <tr>
// 86:             <td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td>
// 87:             <td><a href="abc-1.2.3.tar.xz.sig">abc-1.2.3.tar.xz.sig</a></td>
// 88:             <td align="right">2022-01-23 01:23  </td>
// 89:             <td align="right">456 </td>
// 90:             <td>&nbsp;</td>
// 91:           </tr>
// 92:           <tr>
// 93:             <th colspan="5"><hr></th>
// 94:           </tr>
// 95:         </table>
// 96:         <address>Apache/2.4.29 (Trisquel_GNU/Linux) Server at ftp.gnu.org Port 443</address>
// 97:       </body>
// 98:       </html>
// 99:
// 100:     HTML
// 101:   end
// 102:   let(:matches) { ["1.2.2", "1.2.3"] }
// 103:
// 104:   describe "::match?" do
// 105:     it "returns true for a [non-Savannah] GNU URL" do
// 106:       expect(gnu.match?(gnu_urls[:no_version_dir])).to be true
// 107:       expect(gnu.match?(gnu_urls[:software_page])).to be true
// 108:       expect(gnu.match?(gnu_urls[:subdomain])).to be true
// 109:     end
// 110:
// 111:     it "returns false for a Savannah GNU URL" do
// 112:       expect(gnu.match?(gnu_urls[:savannah])).to be false
// 113:     end
// 114:
// 115:     it "returns false for a non-GNU URL (not nongnu.org)" do
// 116:       expect(gnu.match?(non_gnu_url)).to be false
// 117:     end
// 118:   end
// 119:
// 120:   describe "::generate_input_values" do
// 121:     it "returns a hash containing url and regex for a [non-Savannah] GNU URL" do
// 122:       expect(gnu.generate_input_values(gnu_urls[:no_version_dir])).to eq(generated[:no_version_dir])
// 123:       expect(gnu.generate_input_values(gnu_urls[:software_page])).to eq(generated[:software_page])
// 124:       expect(gnu.generate_input_values(gnu_urls[:subdomain])).to eq(generated[:subdomain])
// 125:     end
// 126:
// 127:     it "returns an empty hash for a Savannah GNU URL" do
// 128:       expect(gnu.generate_input_values(gnu_urls[:savannah])).to eq(generated[:savannah])
// 129:     end
// 130:
// 131:     it "returns an empty hash for a non-GNU URL (not nongnu.org)" do
// 132:       expect(gnu.generate_input_values(non_gnu_url)).to eq({})
// 133:     end
// 134:   end
// 135:
// 136:   describe "::find_versions" do
// 137:     let(:match_data) do
// 138:       cached = {
// 139:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 140:         regex:   generated[:no_version_dir][:regex],
// 141:         url:     generated[:no_version_dir][:url],
// 142:         cached:  true,
// 143:       }
// 144:
// 145:       {
// 146:         cached:,
// 147:         cached_default: cached.merge({ matches: {} }),
// 148:       }
// 149:     end
// 150:
// 151:     it "finds versions in provided content" do
// 152:       expect(gnu.find_versions(url: gnu_urls[:no_version_dir], content:))
// 153:         .to eq(match_data[:cached])
// 154:
// 155:       # This `strategy` block is unnecessary but it's intended to test using a
// 156:       # generated regex in a `strategy` block.
// 157:       expect(gnu.find_versions(url: gnu_urls[:no_version_dir], content:) do |page, regex|
// 158:         page.scan(regex).map(&:first)
// 159:       end).to eq(match_data[:cached])
// 160:     end
// 161:
// 162:     it "returns default match_data when content is blank" do
// 163:       expect(gnu.find_versions(url: gnu_urls[:no_version_dir], content: ""))
// 164:         .to eq(match_data[:cached_default])
// 165:     end
// 166:   end
// 167: end
