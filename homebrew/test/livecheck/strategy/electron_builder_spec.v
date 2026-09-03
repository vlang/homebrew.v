module strategy

import homebrew.livecheck.strategy as electron_core

// Translated from Homebrew/brew `test/livecheck/strategy/electron_builder_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElectronBuilderSpecMatchData {
pub:
	cached         electron_core.ElectronBuilderMatchData
	cached_default electron_core.ElectronBuilderMatchData
	cached_regex   electron_core.ElectronBuilderMatchData
}

// Ruby subject `subject(:electron_builder) { described_class }` at line 7.
pub fn ruby_electron_builder_spec_l7_d1_electron_builder() string {
	return 'ElectronBuilder'
}

// Ruby let `let(:http_url) { "https://www.example.com/example/latest-mac.yml" }` at line 9.
pub fn ruby_electron_builder_spec_l9_d2_http_url() string {
	return 'https://www.example.com/example/latest-mac.yml'
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_electron_builder_spec_l10_d3_non_http_url() string {
	return 'ftp://brew.sh/'
}

// Ruby let `let(:regex) { /Example[._-]v?(\d+(?:\.\d+)+)[._-]mac\.zip/i }` at line 11.
pub fn ruby_electron_builder_spec_l11_d4_regex() string {
	return r'Example[._-]v?(\d+(?:\.\d+)+)[._-]mac\.zip'
}

// Ruby let `let(:content) do` at line 12.
pub fn ruby_electron_builder_spec_l12_d5_content() string {
	return [
		'version: 1.2.3',
		'files:',
		'  - url: Example-1.2.3-mac.zip',
		'    sha512: MDXR0pxozBJjxxbtUQJOnhiaiiQkryLAwtcVjlnNiz30asm/PtSxlxWKFYN3kV/kl+jriInJrGypuzajTF6XIA==',
		'    size: 92031237',
		'    blockMapSize: 96080',
		'  - url: Example-1.2.3.dmg',
		'    sha512: k6WRDlZEfZGZHoOfUShpHxXZb5p44DRp+FAO2FXNx2kStZvyW9VuaoB7phPMfZpcMKrzfRfncpP8VEM8OB2y9g==',
		'    size: 94972630',
		'path: Example-1.2.3-mac.zip',
		'sha512: MDXR0pxozBJjxxbtUQJOnhiaiiQkryLAwtcVjlnNiz30asm/PtSxlxWKFYN3kV/kl+jriInJrGypuzajTF6XIA==',
		"releaseDate: '2000-01-01T00:00:00.000Z'",
	].join('\n') + '\n'
}

// Ruby let `let(:content_timestamp) do` at line 28.
pub fn ruby_electron_builder_spec_l28_d6_content_timestamp() string {
	return ruby_electron_builder_spec_l12_d5_content().replace("releaseDate: '2000-01-01T00:00:00.000Z'", 'releaseDate: 2000-01-01T00:00:00.000Z')
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 35.
pub fn ruby_electron_builder_spec_l35_d7_matches() []string {
	return ['1.2.3']
}

// Ruby it `it "returns true for a YAML file URL" do` at line 38.
pub fn ruby_electron_builder_spec_l38_d8_returns() bool {
	return electron_core.electron_builder_matches_url(ruby_electron_builder_spec_l9_d2_http_url())
}

// Ruby it `it "returns false for non-YAML URL" do` at line 42.
pub fn ruby_electron_builder_spec_l42_d9_returns() bool {
	return !electron_core.electron_builder_matches_url(ruby_electron_builder_spec_l10_d3_non_http_url())
}

// Ruby let `let(:match_data) do` at line 48.
pub fn ruby_electron_builder_spec_l48_d10_match_data() ElectronBuilderSpecMatchData {
	http_url := ruby_electron_builder_spec_l9_d2_http_url()
	return ElectronBuilderSpecMatchData{
		cached: electron_core.ElectronBuilderMatchData{
			matches: {
				'1.2.3': '1.2.3'
			}
			url: http_url
			cached: true
		}
		cached_default: electron_core.ElectronBuilderMatchData{
			matches: map[string]string{}
			url: http_url
			cached: true
		}
		cached_regex: electron_core.ElectronBuilderMatchData{
			matches: {
				'1.2.3': '1.2.3'
			}
			regex: ruby_electron_builder_spec_l11_d4_regex()
			url: http_url
			cached: true
		}
	}
}

fn electron_builder_spec_equal(left electron_core.ElectronBuilderMatchData,
	right electron_core.ElectronBuilderMatchData) bool {
	left_regex := left.regex or { '' }
	right_regex := right.regex or { '' }
	return left.matches == right.matches && left_regex == right_regex && left.url == right.url && left.cached == right.cached
}

// Ruby it `it "finds versions in content using a block" do` at line 63.
pub fn ruby_electron_builder_spec_l63_d11_finds() bool {
	fixture := ruby_electron_builder_spec_l48_d10_match_data()
	url := ruby_electron_builder_spec_l9_d2_http_url()
	content := ruby_electron_builder_spec_l12_d5_content()
	default_result := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: url
		content: content
	}) or { return false }
	path_result := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: url
		regex: ruby_electron_builder_spec_l11_d4_regex()
		content: content
		selector: .path_regex
	}) or { return false }
	timestamp_result := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: url
		regex: ruby_electron_builder_spec_l11_d4_regex()
		content: ruby_electron_builder_spec_l28_d6_content_timestamp()
		selector: .path_regex
	}) or { return false }
	version_result := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: url
		content: content
		selector: .version_regex
	}) or { return false }
	return electron_builder_spec_equal(default_result, fixture.cached) && electron_builder_spec_equal(path_result, fixture.cached_regex) && electron_builder_spec_equal(timestamp_result, fixture.cached_regex) && electron_builder_spec_equal(version_result, fixture.cached)
}

// Ruby it `it "errors if a block is not provided" do` at line 85.
pub fn ruby_electron_builder_spec_l85_d12_errors() bool {
	electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: ruby_electron_builder_spec_l9_d2_http_url()
		regex: ruby_electron_builder_spec_l11_d4_regex()
		content: ruby_electron_builder_spec_l12_d5_content()
	}) or {
		return err.msg() == 'ElectronBuilder only supports a regex when using a `strategy` block'
	}
	return false
}

// Ruby it `it "returns default match_data when url is blank" do` at line 90.
pub fn ruby_electron_builder_spec_l90_d13_returns() bool {
	mut expected := ruby_electron_builder_spec_l48_d10_match_data().cached_default
	expected = electron_core.ElectronBuilderMatchData{
		...expected
		url: ''
	}
	actual := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: ''
		content: ruby_electron_builder_spec_l12_d5_content()
	}) or { return false }
	return electron_builder_spec_equal(actual, expected)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 95.
pub fn ruby_electron_builder_spec_l95_d14_returns() bool {
	actual := electron_core.electron_builder_find_versions(electron_core.ElectronBuilderRequest{
		url: ruby_electron_builder_spec_l9_d2_http_url()
		content: ''
	}) or { return false }
	return electron_builder_spec_equal(actual, ruby_electron_builder_spec_l48_d10_match_data().cached_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::ElectronBuilder do
// 7:   subject(:electron_builder) { described_class }
// 8:
// 9:   let(:http_url) { "https://www.example.com/example/latest-mac.yml" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regex) { /Example[._-]v?(\d+(?:\.\d+)+)[._-]mac\.zip/i }
// 12:   let(:content) do
// 13:     <<~YAML
// 14:       version: 1.2.3
// 15:       files:
// 16:         - url: Example-1.2.3-mac.zip
// 17:           sha512: MDXR0pxozBJjxxbtUQJOnhiaiiQkryLAwtcVjlnNiz30asm/PtSxlxWKFYN3kV/kl+jriInJrGypuzajTF6XIA==
// 18:           size: 92031237
// 19:           blockMapSize: 96080
// 20:         - url: Example-1.2.3.dmg
// 21:           sha512: k6WRDlZEfZGZHoOfUShpHxXZb5p44DRp+FAO2FXNx2kStZvyW9VuaoB7phPMfZpcMKrzfRfncpP8VEM8OB2y9g==
// 22:           size: 94972630
// 23:       path: Example-1.2.3-mac.zip
// 24:       sha512: MDXR0pxozBJjxxbtUQJOnhiaiiQkryLAwtcVjlnNiz30asm/PtSxlxWKFYN3kV/kl+jriInJrGypuzajTF6XIA==
// 25:       releaseDate: '2000-01-01T00:00:00.000Z'
// 26:     YAML
// 27:   end
// 28:   let(:content_timestamp) do
// 29:     # An electron-builder YAML file may use a timestamp instead of an explicit
// 30:     # string value (with quotes) for `releaseDate`, so we need to make sure that
// 31:     # `ElectronBuilder#versions_from_content` won't encounter an error in this
// 32:     # scenario (e.g. `Tried to load unspecified class: Time`).
// 33:     content.sub(/releaseDate:\s*'([^']+)'/, 'releaseDate: \1')
// 34:   end
// 35:   let(:matches) { ["1.2.3"] }
// 36:
// 37:   describe "::match?" do
// 38:     it "returns true for a YAML file URL" do
// 39:       expect(electron_builder.match?(http_url)).to be true
// 40:     end
// 41:
// 42:     it "returns false for non-YAML URL" do
// 43:       expect(electron_builder.match?(non_http_url)).to be false
// 44:     end
// 45:   end
// 46:
// 47:   describe "::find_versions" do
// 48:     let(:match_data) do
// 49:       cached = {
// 50:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 51:         regex:   nil,
// 52:         url:     http_url,
// 53:         cached:  true,
// 54:       }
// 55:
// 56:       {
// 57:         cached:,
// 58:         cached_default: cached.merge({ matches: {} }),
// 59:         cached_regex:   cached.merge({ regex: }),
// 60:       }
// 61:     end
// 62:
// 63:     it "finds versions in content using a block" do
// 64:       expect(electron_builder.find_versions(url: http_url, content:))
// 65:         .to eq(match_data[:cached])
// 66:
// 67:       expect(electron_builder.find_versions(url: http_url, regex:, content:) do |yaml, regex|
// 68:         yaml["path"][regex, 1]
// 69:       end).to eq(match_data[:cached_regex])
// 70:
// 71:       expect(electron_builder.find_versions(url: http_url, regex:, content: content_timestamp) do |yaml, regex|
// 72:         yaml["path"][regex, 1]
// 73:       end).to eq(match_data[:cached_regex])
// 74:
// 75:       # NOTE: A regex should be provided using the `#regex` method in a
// 76:       #       `livecheck` block but we're using a regex literal in the
// 77:       #       `strategy` block here simply to ensure this method works as
// 78:       #       expected when a regex isn't provided.
// 79:       expect(electron_builder.find_versions(url: http_url, content:) do |yaml|
// 80:         regex = /^v?(\d+(?:\.\d+)+)$/i
// 81:         yaml["version"][regex, 1]
// 82:       end).to eq(match_data[:cached])
// 83:     end
// 84:
// 85:     it "errors if a block is not provided" do
// 86:       expect { electron_builder.find_versions(url: http_url, regex:, content:) }
// 87:         .to raise_error(ArgumentError, "ElectronBuilder only supports a regex when using a `strategy` block")
// 88:     end
// 89:
// 90:     it "returns default match_data when url is blank" do
// 91:       expect(electron_builder.find_versions(url: "", content:))
// 92:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 93:     end
// 94:
// 95:     it "returns default match_data when content is blank" do
// 96:       expect(electron_builder.find_versions(url: http_url, content: ""))
// 97:         .to eq(match_data[:cached_default])
// 98:     end
// 99:   end
// 100: end
