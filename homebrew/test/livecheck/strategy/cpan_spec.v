module strategy

import ruby
import homebrew.livecheck
import homebrew.livecheck.strategy as cpan_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/cpan_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CpanSpecMatchData {
pub:
	cached         cpan_core.PageMatchData
	cached_default cpan_core.PageMatchData
}

fn cpan_spec_expected_input(with_subdirectory bool) cpan_core.CpanInputValues {
	prefix := if with_subdirectory { 'brew' } else { 'Brew' }
	path := if with_subdirectory { 'H/HO/HOMEBREW/brew/' } else { 'H/HO/HOMEBREW/' }
	return cpan_core.CpanInputValues{
		present: true
		url: 'https://www.cpan.org/authors/id/${path}'
		regex: cpan_core.PageMatchRegex{
			pattern: 'href=.*?${prefix}[._-]v?(\\d+(?:\\.\\d+)*)\\.t'
			case_insensitive: true
		}
	}
}

fn cpan_spec_scan_block(page string,
	provided ?cpan_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := cpan_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn cpan_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached CPAN content unexpectedly fetched')
}

fn cpan_spec_regex_equal(left ?cpan_core.PageMatchRegex,
	right ?cpan_core.PageMatchRegex) bool {
	if left_value := left {
		right_value := right or { return false }
		return left_value == right_value
	}
	if _ := right {
		return false
	}
	return true
}

fn cpan_spec_match_data_equal(left cpan_core.PageMatchData,
	right cpan_core.PageMatchData) bool {
	return left.matches == right.matches && cpan_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:cpan) { described_class }` at line 7.
pub fn ruby_cpan_spec_l7_d1_cpan() ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Strategy::Cpan')
}

// Ruby let `let(:cpan_urls) do` at line 9.
pub fn ruby_cpan_spec_l9_d2_cpan_urls() map[string]string {
	return {
		'no_subdirectory':       'https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/Brew-v1.2.3.tar.gz'
		'with_subdirectory':     'https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/brew/brew-v1.2.3.tar.gz'
		'no_subdirectory_www':   'https://www.cpan.org/authors/id/H/HO/HOMEBREW/Brew-v1.2.3.tar.gz'
		'with_subdirectory_www': 'https://www.cpan.org/authors/id/H/HO/HOMEBREW/brew/brew-v1.2.3.tar.gz'
	}
}

// Ruby let `let(:non_cpan_url) { "https://brew.sh/test" }` at line 17.
pub fn ruby_cpan_spec_l17_d3_non_cpan_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 18.
pub fn ruby_cpan_spec_l18_d4_generated() map[string]cpan_core.CpanInputValues {
	return {
		'no_subdirectory':   cpan_spec_expected_input(false)
		'with_subdirectory': cpan_spec_expected_input(true)
	}
}

// Ruby let `let(:content) do` at line 31.
pub fn ruby_cpan_spec_l31_d5_content() string {
	return [
		'<html>',
		'<head>',
		'  <title>Index of /authors/id/H/HO/HOMEBREW/</title>',
		'</head>',
		'<body bgcolor="white">',
		'  <h1>Index of /authors/id/H/HO/HOMEBREW/</h1>',
		'  <hr>',
		'  <pre>',
		'    <a href="../">../</a>',
		'    <a href="Brew-1.2.1.meta">Brew-1.2.1.meta</a>                                 01-Jan-2022 01:21               23456',
		'    <a href="Brew-1.2.1.readme">Brew-1.2.1.readme</a>                               01-Jan-2022 01:21                2345',
		'    <a href="Brew-1.2.1.tar.gz">Brew-1.2.1.tar.gz</a>                               01-Jan-2022 01:21             2345678',
		'    <a href="Brew-1.2.2.meta">Brew-1.2.2.meta</a>                                 02-Jan-2022 01:22               34567',
		'    <a href="Brew-1.2.2.readme">Brew-1.2.2.readme</a>                               02-Jan-2022 01:22                3456',
		'    <a href="Brew-1.2.2.tar.gz">Brew-1.2.2.tar.gz</a>                               02-Jan-2022 01:22             3456789',
		'    <a href="Brew-1.2.3.meta">Brew-1.2.3.meta</a>                                 03-Jan-2022 01:23               45678',
		'    <a href="Brew-1.2.3.readme">Brew-1.2.3.readme</a>                               03-Jan-2022 01:23                4567',
		'    <a href="Brew-1.2.3.tar.gz">Brew-1.2.3.tar.gz</a>                               03-Jan-2022 01:23             4567890',
		'    <a href="CHECKSUMS">CHECKSUMS</a>                                          04-Jan-2022 01:24               12345',
		'  </pre>',
		'  <hr>',
		'</body>',
		'</html>',
	].join('\n') + '\n\n'
}

// Ruby let `let(:matches) { ["1.2.3", "1.2.2", "1.2.1"] }` at line 59.
pub fn ruby_cpan_spec_l59_d6_matches() []string {
	return ['1.2.3', '1.2.2', '1.2.1']
}

// Ruby it `it "returns true for a CPAN URL" do` at line 62.
pub fn ruby_cpan_spec_l62_d7_returns() bool {
	for url in ruby_cpan_spec_l9_d2_cpan_urls().values() {
		if !cpan_core.cpan_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-CPAN URL" do` at line 69.
pub fn ruby_cpan_spec_l69_d8_returns() bool {
	return !cpan_core.cpan_matches_url(ruby_cpan_spec_l17_d3_non_cpan_url())
}

// Ruby it `it "returns a hash containing url and regex for a CPAN URL" do` at line 75.
pub fn ruby_cpan_spec_l75_d9_returns() bool {
	urls := ruby_cpan_spec_l9_d2_cpan_urls()
	generated := ruby_cpan_spec_l18_d4_generated()
	return cpan_core.cpan_generate_input_values(urls['no_subdirectory']) == generated['no_subdirectory'] && cpan_core.cpan_generate_input_values(urls['with_subdirectory']) == generated['with_subdirectory'] && cpan_core.cpan_generate_input_values(urls['no_subdirectory_www']) == generated['no_subdirectory'] && cpan_core.cpan_generate_input_values(urls['with_subdirectory_www']) == generated['with_subdirectory']
}

// Ruby it `it "returns an empty hash for a non-CPAN URL" do` at line 82.
pub fn ruby_cpan_spec_l82_d10_returns() bool {
	return !cpan_core.cpan_generate_input_values(ruby_cpan_spec_l17_d3_non_cpan_url()).present
}

// Ruby let `let(:match_data) do` at line 88.
pub fn ruby_cpan_spec_l88_d11_match_data() CpanSpecMatchData {
	generated := cpan_spec_expected_input(false)
	mut matches := map[string]string{}
	for version in ruby_cpan_spec_l59_d6_matches() {
		matches[version] = version
	}
	return CpanSpecMatchData{
		cached: cpan_core.PageMatchData{
			matches: matches
			regex: generated.regex
			url: generated.url
			cached: true
			has_cached: true
		}
		cached_default: cpan_core.PageMatchData{
			matches: map[string]string{}
			regex: generated.regex
			url: generated.url
			cached: true
			has_cached: true
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 102.
pub fn ruby_cpan_spec_l102_d12_finds() bool {
	url := ruby_cpan_spec_l9_d2_cpan_urls()['no_subdirectory']
	content := ruby_cpan_spec_l31_d5_content()
	direct := cpan_core.cpan_find_versions(cpan_core.CpanFindRequest{
		url: url
		content: content
	}, cpan_spec_unused_fetcher) or { return false }
	// This `strategy` block is unnecessary but it's intended to test using a
	// generated regex in a `strategy` block.
	with_block := cpan_core.cpan_find_versions(cpan_core.CpanFindRequest{
		url: url
		content: content
		has_block: true
		block: cpan_spec_scan_block
	}, cpan_spec_unused_fetcher) or { return false }
	expected := ruby_cpan_spec_l88_d11_match_data().cached
	return cpan_spec_match_data_equal(direct, expected) && cpan_spec_match_data_equal(with_block, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 113.
pub fn ruby_cpan_spec_l113_d13_returns() bool {
	actual := cpan_core.cpan_find_versions(cpan_core.CpanFindRequest{
		url: ruby_cpan_spec_l9_d2_cpan_urls()['no_subdirectory']
		content: ''
	}, cpan_spec_unused_fetcher) or { return false }
	return cpan_spec_match_data_equal(actual, ruby_cpan_spec_l88_d11_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Cpan do
// 7:   subject(:cpan) { described_class }
// 8:
// 9:   let(:cpan_urls) do
// 10:     {
// 11:       no_subdirectory:       "https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/Brew-v1.2.3.tar.gz",
// 12:       with_subdirectory:     "https://cpan.metacpan.org/authors/id/H/HO/HOMEBREW/brew/brew-v1.2.3.tar.gz",
// 13:       no_subdirectory_www:   "https://www.cpan.org/authors/id/H/HO/HOMEBREW/Brew-v1.2.3.tar.gz",
// 14:       with_subdirectory_www: "https://www.cpan.org/authors/id/H/HO/HOMEBREW/brew/brew-v1.2.3.tar.gz",
// 15:     }
// 16:   end
// 17:   let(:non_cpan_url) { "https://brew.sh/test" }
// 18:   let(:generated) do
// 19:     {
// 20:       no_subdirectory:   {
// 21:         url:   "https://www.cpan.org/authors/id/H/HO/HOMEBREW/",
// 22:         regex: /href=.*?Brew[._-]v?(\d+(?:\.\d+)*)\.t/i,
// 23:       },
// 24:       with_subdirectory: {
// 25:         url:   "https://www.cpan.org/authors/id/H/HO/HOMEBREW/brew/",
// 26:         regex: /href=.*?brew[._-]v?(\d+(?:\.\d+)*)\.t/i,
// 27:       },
// 28:     }
// 29:   end
// 30:   # CPAN doesn't specify a DOCTYPE, so it's also omitted here.
// 31:   let(:content) do
// 32:     <<~HTML
// 33:       <html>
// 34:       <head>
// 35:         <title>Index of /authors/id/H/HO/HOMEBREW/</title>
// 36:       </head>
// 37:       <body bgcolor="white">
// 38:         <h1>Index of /authors/id/H/HO/HOMEBREW/</h1>
// 39:         <hr>
// 40:         <pre>
// 41:           <a href="../">../</a>
// 42:           <a href="Brew-1.2.1.meta">Brew-1.2.1.meta</a>                                 01-Jan-2022 01:21               23456
// 43:           <a href="Brew-1.2.1.readme">Brew-1.2.1.readme</a>                               01-Jan-2022 01:21                2345
// 44:           <a href="Brew-1.2.1.tar.gz">Brew-1.2.1.tar.gz</a>                               01-Jan-2022 01:21             2345678
// 45:           <a href="Brew-1.2.2.meta">Brew-1.2.2.meta</a>                                 02-Jan-2022 01:22               34567
// 46:           <a href="Brew-1.2.2.readme">Brew-1.2.2.readme</a>                               02-Jan-2022 01:22                3456
// 47:           <a href="Brew-1.2.2.tar.gz">Brew-1.2.2.tar.gz</a>                               02-Jan-2022 01:22             3456789
// 48:           <a href="Brew-1.2.3.meta">Brew-1.2.3.meta</a>                                 03-Jan-2022 01:23               45678
// 49:           <a href="Brew-1.2.3.readme">Brew-1.2.3.readme</a>                               03-Jan-2022 01:23                4567
// 50:           <a href="Brew-1.2.3.tar.gz">Brew-1.2.3.tar.gz</a>                               03-Jan-2022 01:23             4567890
// 51:           <a href="CHECKSUMS">CHECKSUMS</a>                                          04-Jan-2022 01:24               12345
// 52:         </pre>
// 53:         <hr>
// 54:       </body>
// 55:       </html>
// 56:
// 57:     HTML
// 58:   end
// 59:   let(:matches) { ["1.2.3", "1.2.2", "1.2.1"] }
// 60:
// 61:   describe "::match?" do
// 62:     it "returns true for a CPAN URL" do
// 63:       expect(cpan.match?(cpan_urls[:no_subdirectory])).to be true
// 64:       expect(cpan.match?(cpan_urls[:with_subdirectory])).to be true
// 65:       expect(cpan.match?(cpan_urls[:no_subdirectory_www])).to be true
// 66:       expect(cpan.match?(cpan_urls[:with_subdirectory_www])).to be true
// 67:     end
// 68:
// 69:     it "returns false for a non-CPAN URL" do
// 70:       expect(cpan.match?(non_cpan_url)).to be false
// 71:     end
// 72:   end
// 73:
// 74:   describe "::generate_input_values" do
// 75:     it "returns a hash containing url and regex for a CPAN URL" do
// 76:       expect(cpan.generate_input_values(cpan_urls[:no_subdirectory])).to eq(generated[:no_subdirectory])
// 77:       expect(cpan.generate_input_values(cpan_urls[:with_subdirectory])).to eq(generated[:with_subdirectory])
// 78:       expect(cpan.generate_input_values(cpan_urls[:no_subdirectory_www])).to eq(generated[:no_subdirectory])
// 79:       expect(cpan.generate_input_values(cpan_urls[:with_subdirectory_www])).to eq(generated[:with_subdirectory])
// 80:     end
// 81:
// 82:     it "returns an empty hash for a non-CPAN URL" do
// 83:       expect(cpan.generate_input_values(non_cpan_url)).to eq({})
// 84:     end
// 85:   end
// 86:
// 87:   describe "::find_versions" do
// 88:     let(:match_data) do
// 89:       cached = {
// 90:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 91:         regex:   generated[:no_subdirectory][:regex],
// 92:         url:     generated[:no_subdirectory][:url],
// 93:         cached:  true,
// 94:       }
// 95:
// 96:       {
// 97:         cached:,
// 98:         cached_default: cached.merge({ matches: {} }),
// 99:       }
// 100:     end
// 101:
// 102:     it "finds versions in provided content" do
// 103:       expect(cpan.find_versions(url: cpan_urls[:no_subdirectory], content:))
// 104:         .to eq(match_data[:cached])
// 105:
// 106:       # This `strategy` block is unnecessary but it's intended to test using a
// 107:       # generated regex in a `strategy` block.
// 108:       expect(cpan.find_versions(url: cpan_urls[:no_subdirectory], content:) do |page, regex|
// 109:         page.scan(regex).map(&:first)
// 110:       end).to eq(match_data[:cached])
// 111:     end
// 112:
// 113:     it "returns default match_data when content is blank" do
// 114:       expect(cpan.find_versions(url: cpan_urls[:no_subdirectory], content: ""))
// 115:         .to eq(match_data[:cached_default])
// 116:     end
// 117:   end
// 118: end
