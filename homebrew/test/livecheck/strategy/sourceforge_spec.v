module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as sourceforge_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/sourceforge_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SourceforgeSpecGenerated {
pub:
	typical sourceforge_core.SourceforgeInputValues
	rss     sourceforge_core.SourceforgeInputValues
}

pub struct SourceforgeSpecMatchData {
pub:
	cached         sourceforge_core.PageMatchData
	cached_default sourceforge_core.PageMatchData
}

fn sourceforge_spec_scan_block(page string,
	provided ?sourceforge_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := sourceforge_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn sourceforge_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached SourceForge content unexpectedly fetched')
}

fn sourceforge_spec_regex_equal(left ?sourceforge_core.PageMatchRegex,
	right ?sourceforge_core.PageMatchRegex) bool {
	left_value := left or { sourceforge_core.PageMatchRegex{} }
	right_value := right or { sourceforge_core.PageMatchRegex{} }
	return left_value == right_value
}

fn sourceforge_spec_match_data_equal(left sourceforge_core.PageMatchData,
	right sourceforge_core.PageMatchData) bool {
	return left.matches == right.matches && sourceforge_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:sourceforge) { described_class }` at line 7.
pub fn ruby_sourceforge_spec_l7_d1_sourceforge() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::Sourceforge')
}

// Ruby let `let(:sourceforge_urls) do` at line 9.
pub fn ruby_sourceforge_spec_l9_d2_sourceforge_urls() map[string]string {
	return {
		'typical':       'https://downloads.sourceforge.net/project/abc/def-1.2.3.tar.gz'
		'rss':           'https://sourceforge.net/projects/abc/rss'
		'rss_with_path': 'https://sourceforge.net/projects/abc/rss?path=/def'
	}
}

// Ruby let `let(:non_sourceforge_url) { "https://brew.sh/test" }` at line 16.
pub fn ruby_sourceforge_spec_l16_d3_non_sourceforge_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 17.
pub fn ruby_sourceforge_spec_l17_d4_generated() SourceforgeSpecGenerated {
	match_regex := sourceforge_core.PageMatchRegex{
		pattern: r'url=.*?/abc/files/.*?[-_/](\d+(?:[-.]\d+)+)[-_/%.]'
		case_insensitive: true
	}
	return SourceforgeSpecGenerated{
		typical: sourceforge_core.SourceforgeInputValues{
			present: true
			url: 'https://sourceforge.net/projects/abc/rss'
			has_url: true
			regex: match_regex
		}
		rss: sourceforge_core.SourceforgeInputValues{
			present: true
			regex: match_regex
		}
	}
}

// Ruby let `let(:content) do` at line 28.
pub fn ruby_sourceforge_spec_l28_d5_content() string {
	return '<?xml version="1.0" encoding="utf-8"?>\n<rss><channel><title>abc</title><item><media:content url="https://sourceforge.net/projects/abc/files/def-1.2.3.tar.gz/download" /></item></channel></rss>\n'
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 53.
pub fn ruby_sourceforge_spec_l53_d6_matches() []string {
	return ['1.2.3']
}

// Ruby it `it "returns true for a SourceForge URL" do` at line 56.
pub fn ruby_sourceforge_spec_l56_d7_returns() bool {
	for url in ruby_sourceforge_spec_l9_d2_sourceforge_urls().values() {
		if !sourceforge_core.sourceforge_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-SourceForge URL" do` at line 62.
pub fn ruby_sourceforge_spec_l62_d8_returns() bool {
	return !sourceforge_core.sourceforge_matches_url(ruby_sourceforge_spec_l16_d3_non_sourceforge_url())
}

// Ruby it `it "returns a hash containing url and regex for an Apache URL" do` at line 68.
pub fn ruby_sourceforge_spec_l68_d9_returns() bool {
	urls := ruby_sourceforge_spec_l9_d2_sourceforge_urls()
	generated := ruby_sourceforge_spec_l17_d4_generated()
	return sourceforge_core.sourceforge_generate_input_values(urls['typical']) == generated.typical && sourceforge_core.sourceforge_generate_input_values(urls['rss']) == generated.rss && sourceforge_core.sourceforge_generate_input_values(urls['rss_with_path']) == generated.rss
}

// Ruby it `it "returns an empty hash for a non-Apache URL" do` at line 74.
pub fn ruby_sourceforge_spec_l74_d10_returns() bool {
	return !sourceforge_core.sourceforge_generate_input_values(ruby_sourceforge_spec_l16_d3_non_sourceforge_url()).present
}

// Ruby let `let(:match_data) do` at line 80.
pub fn ruby_sourceforge_spec_l80_d11_match_data() SourceforgeSpecMatchData {
	base := sourceforge_core.PageMatchData{
		matches: {
			'1.2.3': '1.2.3'
		}
		regex: ruby_sourceforge_spec_l17_d4_generated().typical.regex
		url: ruby_sourceforge_spec_l17_d4_generated().typical.url
		cached: true
		has_cached: true
	}
	return SourceforgeSpecMatchData{
		cached: base
		cached_default: sourceforge_core.PageMatchData{
			...base
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 94.
pub fn ruby_sourceforge_spec_l94_d12_finds() bool {
	url := ruby_sourceforge_spec_l9_d2_sourceforge_urls()['typical']
	content := ruby_sourceforge_spec_l28_d5_content()
	plain := sourceforge_core.sourceforge_find_versions(sourceforge_core.SourceforgeFindRequest{
		url: url
		content: content
	}, sourceforge_spec_unused_fetcher) or { return false }
	with_block := sourceforge_core.sourceforge_find_versions(sourceforge_core.SourceforgeFindRequest{
		url: url
		content: content
		has_block: true
		block: sourceforge_spec_scan_block
	}, sourceforge_spec_unused_fetcher) or { return false }
	expected := ruby_sourceforge_spec_l80_d11_match_data().cached
	return sourceforge_spec_match_data_equal(plain, expected) && sourceforge_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 105.
pub fn ruby_sourceforge_spec_l105_d13_returns() bool {
	actual := sourceforge_core.sourceforge_find_versions(sourceforge_core.SourceforgeFindRequest{
		url: ruby_sourceforge_spec_l9_d2_sourceforge_urls()['typical']
		content: ''
	}, sourceforge_spec_unused_fetcher) or { return false }
	return sourceforge_spec_match_data_equal(actual, ruby_sourceforge_spec_l80_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Sourceforge do
// 7:   subject(:sourceforge) { described_class }
// 8:
// 9:   let(:sourceforge_urls) do
// 10:     {
// 11:       typical:       "https://downloads.sourceforge.net/project/abc/def-1.2.3.tar.gz",
// 12:       rss:           "https://sourceforge.net/projects/abc/rss",
// 13:       rss_with_path: "https://sourceforge.net/projects/abc/rss?path=/def",
// 14:     }
// 15:   end
// 16:   let(:non_sourceforge_url) { "https://brew.sh/test" }
// 17:   let(:generated) do
// 18:     {
// 19:       typical: {
// 20:         url:   "https://sourceforge.net/projects/abc/rss",
// 21:         regex: %r{url=.*?/abc/files/.*?[-_/](\d+(?:[-.]\d+)+)[-_/%.]}i,
// 22:       },
// 23:       rss:     {
// 24:         regex: %r{url=.*?/abc/files/.*?[-_/](\d+(?:[-.]\d+)+)[-_/%.]}i,
// 25:       },
// 26:     }
// 27:   end
// 28:   let(:content) do
// 29:     <<~XML
// 30:       <?xml version="1.0" encoding="utf-8"?>
// 31:       <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:files="https://sourceforge.net/api/files.rdf#" xmlns:media="http://video.search.yahoo.com/mrss/" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:sf="https://sourceforge.net/api/sfelements.rdf#" version="2.0">
// 32:         <channel xmlns:files="https://sourceforge.net/api/files.rdf#" xmlns:media="http://video.search.yahoo.com/mrss/" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:sf="https://sourceforge.net/api/sfelements.rdf#">
// 33:           <title>abc</title>
// 34:           <link>https://sourceforge.net</link>
// 35:           <description><![CDATA[Files from abc Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.]]></description>
// 36:           <pubDate>Sun, 24 Jan 2022 01:24:56 UT</pubDate>
// 37:           <managingEditor>noreply@sourceforge.net (SourceForge.net)</managingEditor>
// 38:           <docs>http://blogs.law.harvard.edu/tech/rss</docs>
// 39:           <item>
// 40:             <title><![CDATA[/abc/def-1.2.3.tar.gz]]></title>
// 41:             <link>https://sourceforge.net/projects/abc/files/def-1.2.3.tar.gz/download</link>
// 42:             <guid>https://sourceforge.net/projects/abc/files/def-1.2.3.tar.gz/download</guid>
// 43:             <pubDate>Mon, 23 Jan 2022 01:23:45 UT</pubDate>
// 44:             <description><![CDATA[/abc/def-1.2.3.tar.gz]]></description>
// 45:             <files:sf-file-id xmlns:files="https://sourceforge.net/api/files.rdf#">537951</files:sf-file-id>
// 46:             <files:extra-info xmlns:files="https://sourceforge.net/api/files.rdf#">POSIX tar archive</files:extra-info>
// 47:             <media:content xmlns:media="http://video.search.yahoo.com/mrss/" type="application/x-gzip" url="https://sourceforge.net/projects/abc/files/def-1.2.3.tar.gz/download" filesize="123456"><media:hash algo="md5">01234567890abcdef01234567890abcd</media:hash></media:content>
// 48:           </item>
// 49:         </channel>
// 50:       </rss>
// 51:     XML
// 52:   end
// 53:   let(:matches) { ["1.2.3"] }
// 54:
// 55:   describe "::match?" do
// 56:     it "returns true for a SourceForge URL" do
// 57:       expect(sourceforge.match?(sourceforge_urls[:typical])).to be true
// 58:       expect(sourceforge.match?(sourceforge_urls[:rss])).to be true
// 59:       expect(sourceforge.match?(sourceforge_urls[:rss_with_path])).to be true
// 60:     end
// 61:
// 62:     it "returns false for a non-SourceForge URL" do
// 63:       expect(sourceforge.match?(non_sourceforge_url)).to be false
// 64:     end
// 65:   end
// 66:
// 67:   describe "::generate_input_values" do
// 68:     it "returns a hash containing url and regex for an Apache URL" do
// 69:       expect(sourceforge.generate_input_values(sourceforge_urls[:typical])).to eq(generated[:typical])
// 70:       expect(sourceforge.generate_input_values(sourceforge_urls[:rss])).to eq(generated[:rss])
// 71:       expect(sourceforge.generate_input_values(sourceforge_urls[:rss_with_path])).to eq(generated[:rss])
// 72:     end
// 73:
// 74:     it "returns an empty hash for a non-Apache URL" do
// 75:       expect(sourceforge.generate_input_values(non_sourceforge_url)).to eq({})
// 76:     end
// 77:   end
// 78:
// 79:   describe "::find_versions" do
// 80:     let(:match_data) do
// 81:       cached = {
// 82:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 83:         regex:   generated[:typical][:regex],
// 84:         url:     generated[:typical][:url],
// 85:         cached:  true,
// 86:       }
// 87:
// 88:       {
// 89:         cached:,
// 90:         cached_default: cached.merge({ matches: {} }),
// 91:       }
// 92:     end
// 93:
// 94:     it "finds versions in provided content" do
// 95:       expect(sourceforge.find_versions(url: sourceforge_urls[:typical], content:))
// 96:         .to eq(match_data[:cached])
// 97:
// 98:       # This `strategy` block is unnecessary but it's intended to test using a
// 99:       # generated regex in a `strategy` block.
// 100:       expect(sourceforge.find_versions(url: sourceforge_urls[:typical], content:) do |page, regex|
// 101:         page.scan(regex).map(&:first)
// 102:       end).to eq(match_data[:cached])
// 103:     end
// 104:
// 105:     it "returns default match_data when content is blank" do
// 106:       expect(sourceforge.find_versions(url: sourceforge_urls[:typical], content: ""))
// 107:         .to eq(match_data[:cached_default])
// 108:     end
// 109:   end
// 110: end
