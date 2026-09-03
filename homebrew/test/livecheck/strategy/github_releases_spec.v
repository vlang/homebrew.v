module strategy

import brew_runtime
import homebrew.livecheck.strategy as github_strategy

fn github_releases_spec_url(name string) string {
	return match name {
		'release_asset' { 'https://github.com/abc/def/releases/download/1.2.3/ghi-1.2.3.tar.gz' }
		'short_tag_archive' { 'https://github.com/abc/def/archive/v1.2.3.tar.gz' }
		'long_tag_archive' { 'https://github.com/abc/def/archive/refs/tags/1.2.3.tar.gz' }
		'repository_upload' { 'https://github.com/downloads/abc/def/ghi-1.2.3.tar.gz' }
		'brew_tag_archive' { 'https://github.com/Homebrew/brew/archive/1.2.3.tar.gz' }
		else { '' }
	}
}

fn github_releases_spec_content() string {
	return '[{"tag_name":"v1.2.3","name":"v1.2.3","draft":false,"prerelease":false},' + '{"tag_name":"1.2.2","name":"No version title","draft":false,"prerelease":false},' + '{"tag_name":"no-version-tag","name":"No version title","draft":false,"prerelease":false},' + '{"tag_name":"v1.1.2","name":"v1.1.2","draft":false,"prerelease":true},' + '{"tag_name":"v1.1.1","name":"v1.1.1","draft":true,"prerelease":false},' + '{"tag_name":"v1.1.0","name":"v1.1.0","draft":true,"prerelease":true},' + '{"other":"something-else"}]'
}

fn github_releases_spec_digits(value string) bool {
	return value != '' && value.bytes().all(it >= `0` && it <= `9`)
}

fn github_releases_spec_string_block(releases []github_strategy.GithubRelease, match_regex github_strategy.GithubReleasesRegex) github_strategy.GithubReleasesBlockValue {
	return github_strategy.GithubReleasesBlockValue{
		kind: .string_value
		value: '1.2.3'
	}
}

fn github_releases_spec_array_block(releases []github_strategy.GithubRelease, match_regex github_strategy.GithubReleasesRegex) github_strategy.GithubReleasesBlockValue {
	mut values := []string{}
	for release in releases {
		if release.draft || release.prerelease || release.tag_name == '' {
			continue
		}
		mut value := release.tag_name
		if value.len > 1 && value[0] in [`v`, `V`] {
			value = value[1..]
		}
		if value.contains('.') && value.split('.').all(github_releases_spec_digits(it)) {
			values << value
		}
	}
	return github_strategy.GithubReleasesBlockValue{
		kind: .array
		values: values
	}
}

fn github_releases_spec_nil_block(releases []github_strategy.GithubRelease, match_regex github_strategy.GithubReleasesRegex) github_strategy.GithubReleasesBlockValue {
	return github_strategy.GithubReleasesBlockValue{ kind: .nil_value }
}

fn github_releases_spec_invalid_block(releases []github_strategy.GithubRelease, match_regex github_strategy.GithubReleasesRegex) github_strategy.GithubReleasesBlockValue {
	return github_strategy.GithubReleasesBlockValue{ kind: .invalid }
}

fn github_releases_spec_fetch(url string) !string {
	return github_releases_spec_content()
}

fn github_releases_spec_empty_fetch(url string) !string {
	return ''
}

fn github_releases_spec_generated_equal(actual github_strategy.GithubReleasesInputValues, username string, repository string) bool {
	return actual.present && actual.username == username && actual.repository == repository && actual.url == 'https://api.github.com/repos/${username}/${repository}/releases'
}

fn github_releases_spec_matches(actual map[string]string) bool {
	return actual == {
		'1.2.3': '1.2.3'
		'1.2.2': '1.2.2'
	}
}

// Translated from Homebrew/brew `test/livecheck/strategy/github_releases_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:github_releases) { described_class }` at line 7.
pub fn ruby_github_releases_spec_l7_d1_github_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::GithubReleases')
}

// Ruby let `let(:github_urls) do` at line 9.
pub fn ruby_github_releases_spec_l9_d2_github_urls(args ...brew_runtime.Value) brew_runtime.Value {
	mut urls := map[string]brew_runtime.Value{}
	for name in ['release_asset', 'short_tag_archive', 'long_tag_archive', 'repository_upload',
		'brew_tag_archive'] {
		urls[name] = brew_runtime.string_value(github_releases_spec_url(name))
	}
	return brew_runtime.map_value(urls)
}

// Ruby let `let(:non_github_url) { "https://brew.sh/test" }` at line 18.
pub fn ruby_github_releases_spec_l18_d3_non_github_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('https://brew.sh/test')
}

// Ruby let `let(:regex) { Homebrew::Livecheck::Strategy::GithubReleases::DEFAULT_REGEX }` at line 19.
pub fn ruby_github_releases_spec_l19_d4_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Regexp', github_strategy.github_releases_default_pattern)
}

// Ruby let `let(:generated) do` at line 20.
pub fn ruby_github_releases_spec_l20_d5_generated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.map_value({
		'def':  brew_runtime.map_value({
			'url':        brew_runtime.string_value('https://api.github.com/repos/abc/def/releases')
			'username':   brew_runtime.string_value('abc')
			'repository': brew_runtime.string_value('def')
		})
		'brew': brew_runtime.map_value({
			'url':        brew_runtime.string_value('https://api.github.com/repos/Homebrew/brew/releases')
			'username':   brew_runtime.string_value('Homebrew')
			'repository': brew_runtime.string_value('brew')
		})
	})
}

// Ruby let `let(:content) do` at line 38.
pub fn ruby_github_releases_spec_l38_d6_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(github_releases_spec_content())
}

// Ruby let `let(:matches) { ["1.2.3", "1.2.2"] }` at line 83.
pub fn ruby_github_releases_spec_l83_d7_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(['1.2.3', '1.2.2'])
}

// Ruby it `it "returns true for a GitHub release artifact URL" do` at line 86.
pub fn ruby_github_releases_spec_l86_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(github_strategy.github_releases_matches_url(github_releases_spec_url('release_asset')))
}

// Ruby it `it "returns true for a GitHub tag archive URL" do` at line 90.
pub fn ruby_github_releases_spec_l90_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(github_strategy.github_releases_matches_url(github_releases_spec_url('short_tag_archive')) && github_strategy.github_releases_matches_url(github_releases_spec_url('long_tag_archive')))
}

// Ruby it `it "returns true for a GitHub repository upload URL" do` at line 95.
pub fn ruby_github_releases_spec_l95_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(github_strategy.github_releases_matches_url(github_releases_spec_url('repository_upload')))
}

// Ruby it `it "returns false for a non-GitHub URL" do` at line 99.
pub fn ruby_github_releases_spec_l99_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!github_strategy.github_releases_matches_url('https://brew.sh/test'))
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub release artifact URL" do` at line 105.
pub fn ruby_github_releases_spec_l105_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	actual := github_strategy.github_releases_generate_input_values(github_releases_spec_url('release_asset'))
	return brew_runtime.bool_value(github_releases_spec_generated_equal(actual, 'abc', 'def'))
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub tag archive URL" do` at line 109.
pub fn ruby_github_releases_spec_l109_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	short := github_strategy.github_releases_generate_input_values(github_releases_spec_url('short_tag_archive'))
	long := github_strategy.github_releases_generate_input_values(github_releases_spec_url('long_tag_archive'))
	return brew_runtime.bool_value(github_releases_spec_generated_equal(short, 'abc', 'def') && github_releases_spec_generated_equal(long, 'abc', 'def'))
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub repository upload URL" do` at line 114.
pub fn ruby_github_releases_spec_l114_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	actual := github_strategy.github_releases_generate_input_values(github_releases_spec_url('repository_upload'))
	return brew_runtime.bool_value(github_releases_spec_generated_equal(actual, 'abc', 'def'))
}

// Ruby it `it "returns an empty hash for a non-GitHub URL" do` at line 118.
pub fn ruby_github_releases_spec_l118_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!github_strategy.github_releases_generate_input_values('https://brew.sh/test').present)
}

// Ruby it `it "returns an empty array if content is blank" do` at line 124.
pub fn ruby_github_releases_spec_l124_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	empty := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{}) or {
		return brew_runtime.bool_value(false)
	}
	empty_json := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: '[]'
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(empty.len == 0 && empty_json.len == 0)
}

// Ruby it `it "returns an array of version strings when given content" do` at line 129.
pub fn ruby_github_releases_spec_l129_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	versions := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: github_releases_spec_content()
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(versions == ['1.2.3', '1.2.2'])
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 133.
pub fn ruby_github_releases_spec_l133_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	string_result := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: github_releases_spec_content()
		has_block: true
		block: github_releases_spec_string_block
	}) or { return brew_runtime.bool_value(false) }
	array_result := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: github_releases_spec_content()
		has_block: true
		block: github_releases_spec_array_block
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(string_result == ['1.2.3'] && array_result == [
		'1.2.3',
		'1.2.2',
	])
}

// Ruby it `it "allows a nil return from a block" do` at line 147.
pub fn ruby_github_releases_spec_l147_d19_allows(args ...brew_runtime.Value) brew_runtime.Value {
	versions := github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: github_releases_spec_content()
		has_block: true
		block: github_releases_spec_nil_block
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(versions.len == 0)
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 151.
pub fn ruby_github_releases_spec_l151_d20_errors(args ...brew_runtime.Value) brew_runtime.Value {
	github_strategy.github_releases_versions_from_content(github_strategy.GithubReleasesVersionsRequest{
		content: github_releases_spec_content()
		has_block: true
		block: github_releases_spec_invalid_block
	}) or {
		return brew_runtime.bool_value(err.msg() == 'Return value of a strategy block must be a string or array of strings.')
	}
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:match_data) do` at line 158.
pub fn ruby_github_releases_spec_l158_d21_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut matches := map[string]brew_runtime.Value{}
	for version in ['1.2.3', '1.2.2'] {
		matches[version] = brew_runtime.object_value('Version', version)
	}
	base := {
		'matches': brew_runtime.map_value(matches)
		'regex':   brew_runtime.object_value('Regexp', github_strategy.github_releases_default_pattern)
		'url':     brew_runtime.string_value('https://api.github.com/repos/Homebrew/brew/releases')
	}
	mut fetched := base.clone()
	fetched['content'] = brew_runtime.string_value(github_releases_spec_content())
	mut cached := base.clone()
	cached['cached'] = brew_runtime.bool_value(true)
	mut cached_default := base.clone()
	cached_default['matches'] = brew_runtime.map_value({})
	cached_default['cached'] = brew_runtime.bool_value(true)
	return brew_runtime.map_value({
		'fetched':        brew_runtime.map_value(fetched)
		'cached':         brew_runtime.map_value(cached)
		'cached_default': brew_runtime.map_value(cached_default)
	})
}

// Ruby let `let(:brew_regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 172.
pub fn ruby_github_releases_spec_l172_d22_brew_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Regexp', r'^v?(\d+(?:\.\d+)+)$')
}

// Ruby it `it "finds versions in fetched content" do` at line 174.
pub fn ruby_github_releases_spec_l174_d23_finds(args ...brew_runtime.Value) brew_runtime.Value {
	actual := github_strategy.github_releases_find_versions(github_strategy.GithubReleasesFindRequest{
		url: github_releases_spec_url('brew_tag_archive')
	}, github_releases_spec_fetch) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(github_releases_spec_matches(actual.matches) && actual.url == 'https://api.github.com/repos/Homebrew/brew/releases' && actual.has_content && actual.content == github_releases_spec_content() && !actual.has_cached)
}

// Ruby it `it "finds versions in provided content" do` at line 181.
pub fn ruby_github_releases_spec_l181_d24_finds(args ...brew_runtime.Value) brew_runtime.Value {
	cached := github_strategy.github_releases_find_versions(github_strategy.GithubReleasesFindRequest{
		url: github_releases_spec_url('brew_tag_archive')
		content: github_releases_spec_content()
	}, github_releases_spec_empty_fetch) or { return brew_runtime.bool_value(false) }
	with_block := github_strategy.github_releases_find_versions(github_strategy.GithubReleasesFindRequest{
		url: github_releases_spec_url('brew_tag_archive')
		regex: github_strategy.GithubReleasesRegex{
			pattern: r'^v?(\d+(?:\.\d+)+)$'
		}
		content: github_releases_spec_content()
		has_block: true
		block: github_releases_spec_array_block
	}, github_releases_spec_empty_fetch) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(github_releases_spec_matches(cached.matches) && cached.has_cached && cached.cached && !cached.has_content && github_releases_spec_matches(with_block.matches) && with_block.regex.pattern == r'^v?(\d+(?:\.\d+)+)$')
}

// Ruby it `it "returns default match_data when url is blank" do` at line 208.
pub fn ruby_github_releases_spec_l208_d25_returns(args ...brew_runtime.Value) brew_runtime.Value {
	actual := github_strategy.github_releases_find_versions(github_strategy.GithubReleasesFindRequest{}, github_releases_spec_empty_fetch) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(actual.matches.len == 0 && actual.url == '' && actual.regex.pattern == github_strategy.github_releases_default_pattern && !actual.has_cached && !actual.has_content)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 213.
pub fn ruby_github_releases_spec_l213_d26_returns(args ...brew_runtime.Value) brew_runtime.Value {
	actual := github_strategy.github_releases_find_versions(github_strategy.GithubReleasesFindRequest{
		url: github_releases_spec_url('brew_tag_archive')
		content: ''
	}, github_releases_spec_empty_fetch) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(actual.matches.len == 0 && actual.has_cached && actual.cached && actual.url == 'https://api.github.com/repos/Homebrew/brew/releases' && !actual.has_content)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::GithubReleases do
// 7:   subject(:github_releases) { described_class }
// 8:
// 9:   let(:github_urls) do
// 10:     {
// 11:       release_asset:     "https://github.com/abc/def/releases/download/1.2.3/ghi-1.2.3.tar.gz",
// 12:       short_tag_archive: "https://github.com/abc/def/archive/v1.2.3.tar.gz",
// 13:       long_tag_archive:  "https://github.com/abc/def/archive/refs/tags/1.2.3.tar.gz",
// 14:       repository_upload: "https://github.com/downloads/abc/def/ghi-1.2.3.tar.gz",
// 15:       brew_tag_archive:  "https://github.com/Homebrew/brew/archive/1.2.3.tar.gz",
// 16:     }
// 17:   end
// 18:   let(:non_github_url) { "https://brew.sh/test" }
// 19:   let(:regex) { Homebrew::Livecheck::Strategy::GithubReleases::DEFAULT_REGEX }
// 20:   let(:generated) do
// 21:     {
// 22:       def:  {
// 23:         url:        "https://api.github.com/repos/abc/def/releases",
// 24:         username:   "abc",
// 25:         repository: "def",
// 26:       },
// 27:       brew: {
// 28:         url:        "https://api.github.com/repos/Homebrew/brew/releases",
// 29:         username:   "Homebrew",
// 30:         repository: "brew",
// 31:       },
// 32:     }
// 33:   end
// 34:   # For the sake of brevity, this is a limited subset of the information found
// 35:   # in release objects in a response from the GitHub API. Some of these objects
// 36:   # are somewhat representative of real world scenarios but others are
// 37:   # contrived examples for the sake of exercising code paths.
// 38:   let(:content) do
// 39:     <<~JSON
// 40:       [
// 41:         {
// 42:           "tag_name": "v1.2.3",
// 43:           "name": "v1.2.3",
// 44:           "draft": false,
// 45:           "prerelease": false
// 46:         },
// 47:         {
// 48:           "tag_name": "1.2.2",
// 49:           "name": "No version title",
// 50:           "draft": false,
// 51:           "prerelease": false
// 52:         },
// 53:         {
// 54:           "tag_name": "no-version-tag",
// 55:           "name": "No version title",
// 56:           "draft": false,
// 57:           "prerelease": false
// 58:         },
// 59:         {
// 60:           "tag_name": "v1.1.2",
// 61:           "name": "v1.1.2",
// 62:           "draft": false,
// 63:           "prerelease": true
// 64:         },
// 65:         {
// 66:           "tag_name": "v1.1.1",
// 67:           "name": "v1.1.1",
// 68:           "draft": true,
// 69:           "prerelease": false
// 70:         },
// 71:         {
// 72:           "tag_name": "v1.1.0",
// 73:           "name": "v1.1.0",
// 74:           "draft": true,
// 75:           "prerelease": true
// 76:         },
// 77:         {
// 78:           "other": "something-else"
// 79:         }
// 80:       ]
// 81:     JSON
// 82:   end
// 83:   let(:matches) { ["1.2.3", "1.2.2"] }
// 84:
// 85:   describe "::match?" do
// 86:     it "returns true for a GitHub release artifact URL" do
// 87:       expect(github_releases.match?(github_urls[:release_asset])).to be true
// 88:     end
// 89:
// 90:     it "returns true for a GitHub tag archive URL" do
// 91:       expect(github_releases.match?(github_urls[:short_tag_archive])).to be true
// 92:       expect(github_releases.match?(github_urls[:long_tag_archive])).to be true
// 93:     end
// 94:
// 95:     it "returns true for a GitHub repository upload URL" do
// 96:       expect(github_releases.match?(github_urls[:repository_upload])).to be true
// 97:     end
// 98:
// 99:     it "returns false for a non-GitHub URL" do
// 100:       expect(github_releases.match?(non_github_url)).to be false
// 101:     end
// 102:   end
// 103:
// 104:   describe "::generate_input_values" do
// 105:     it "returns a hash containing a url and regex for a GitHub release artifact URL" do
// 106:       expect(github_releases.generate_input_values(github_urls[:release_asset])).to eq(generated[:def])
// 107:     end
// 108:
// 109:     it "returns a hash containing a url and regex for a GitHub tag archive URL" do
// 110:       expect(github_releases.generate_input_values(github_urls[:short_tag_archive])).to eq(generated[:def])
// 111:       expect(github_releases.generate_input_values(github_urls[:long_tag_archive])).to eq(generated[:def])
// 112:     end
// 113:
// 114:     it "returns a hash containing a url and regex for a GitHub repository upload URL" do
// 115:       expect(github_releases.generate_input_values(github_urls[:repository_upload])).to eq(generated[:def])
// 116:     end
// 117:
// 118:     it "returns an empty hash for a non-GitHub URL" do
// 119:       expect(github_releases.generate_input_values(non_github_url)).to eq({})
// 120:     end
// 121:   end
// 122:
// 123:   describe "::versions_from_content" do
// 124:     it "returns an empty array if content is blank" do
// 125:       expect(github_releases.versions_from_content("", regex)).to eq([])
// 126:       expect(github_releases.versions_from_content("[]", regex)).to eq([])
// 127:     end
// 128:
// 129:     it "returns an array of version strings when given content" do
// 130:       expect(github_releases.versions_from_content(content, regex)).to eq(matches)
// 131:     end
// 132:
// 133:     it "returns an array of version strings when given content and a block" do
// 134:       # Returning a string from block
// 135:       expect(github_releases.versions_from_content(content, regex) { "1.2.3" }).to eq(["1.2.3"])
// 136:
// 137:       # Returning an array of strings from block
// 138:       expect(github_releases.versions_from_content(content, regex) do |json, regex|
// 139:         json.map do |release|
// 140:           next if release["draft"] || release["prerelease"]
// 141:
// 142:           release["tag_name"]&.[](regex, 1)
// 143:         end
// 144:       end).to eq(matches)
// 145:     end
// 146:
// 147:     it "allows a nil return from a block" do
// 148:       expect(github_releases.versions_from_content(content, regex) { next }).to eq([])
// 149:     end
// 150:
// 151:     it "errors on an invalid return type from a block" do
// 152:       expect { github_releases.versions_from_content(content, regex) { 123 } }
// 153:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 154:     end
// 155:   end
// 156:
// 157:   describe "::find_versions" do
// 158:     let(:match_data) do
// 159:       base = {
// 160:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 161:         regex:,
// 162:         url:     generated[:brew][:url],
// 163:       }
// 164:
// 165:       {
// 166:         fetched:        base.merge({ content: }),
// 167:         cached:         base.merge({ cached: true }),
// 168:         cached_default: base.merge({ matches: {}, cached: true }),
// 169:       }
// 170:     end
// 171:
// 172:     let(:brew_regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 173:
// 174:     it "finds versions in fetched content" do
// 175:       allow(GitHub::API).to receive(:open_rest).and_return(content)
// 176:
// 177:       expect(github_releases.find_versions(url: github_urls[:brew_tag_archive]))
// 178:         .to eq(match_data[:fetched])
// 179:     end
// 180:
// 181:     it "finds versions in provided content" do
// 182:       expect(github_releases.find_versions(url: github_urls[:brew_tag_archive], content:))
// 183:         .to eq(match_data[:cached])
// 184:
// 185:       # This `strategy` block is unnecessary but it's intended to test using a
// 186:       # regex in a `strategy` block.
// 187:       expect(
// 188:         github_releases.find_versions(
// 189:           url:     github_urls[:brew_tag_archive],
// 190:           regex:   brew_regex,
// 191:           content:,
// 192:         ) do |json, regex|
// 193:           json.map do |release|
// 194:             next if release["draft"] || release["prerelease"]
// 195:
// 196:             match = release["tag_name"]&.match(regex)
// 197:             next if match.blank?
// 198:
// 199:             match[1]
// 200:           end
// 201:         end,
// 202:       ).to eq(match_data[:cached].merge({
// 203:         matches: ["1.2.3", "1.2.2"].to_h { |v| [v, Version.new(v)] },
// 204:         regex:   brew_regex,
// 205:       }))
// 206:     end
// 207:
// 208:     it "returns default match_data when url is blank" do
// 209:       expect(github_releases.find_versions(url: ""))
// 210:         .to eq({ matches: {}, regex: Homebrew::Livecheck::Strategy::GithubReleases::DEFAULT_REGEX, url: "" })
// 211:     end
// 212:
// 213:     it "returns default match_data when content is blank" do
// 214:       expect(github_releases.find_versions(url: github_urls[:brew_tag_archive], content: ""))
// 215:         .to eq(match_data[:cached_default])
// 216:     end
// 217:   end
// 218: end
