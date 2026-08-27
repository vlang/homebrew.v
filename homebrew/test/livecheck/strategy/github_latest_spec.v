module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/github_latest_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:github_latest) { described_class }` at line 7.
pub fn ruby_github_latest_spec_l7_d1_github_latest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_latest', ...args)
}

// Ruby let `let(:github_urls) do` at line 9.
pub fn ruby_github_latest_spec_l9_d2_github_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_urls', ...args)
}

// Ruby let `let(:non_github_url) { "https://brew.sh/test" }` at line 18.
pub fn ruby_github_latest_spec_l18_d3_non_github_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_github_url', ...args)
}

// Ruby let `let(:generated) do` at line 19.
pub fn ruby_github_latest_spec_l19_d4_generated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generated', ...args)
}

// Ruby let `let(:content) do` at line 35.
pub fn ruby_github_latest_spec_l35_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 45.
pub fn ruby_github_latest_spec_l45_d6_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for a GitHub release artifact URL" do` at line 48.
pub fn ruby_github_latest_spec_l48_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for a GitHub tag archive URL" do` at line 52.
pub fn ruby_github_latest_spec_l52_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for a GitHub repository upload URL" do` at line 57.
pub fn ruby_github_latest_spec_l57_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-GitHub URL" do` at line 61.
pub fn ruby_github_latest_spec_l61_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub release artifact URL" do` at line 67.
pub fn ruby_github_latest_spec_l67_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub tag archive URL" do` at line 71.
pub fn ruby_github_latest_spec_l71_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing a url and regex for a GitHub repository upload URL" do` at line 76.
pub fn ruby_github_latest_spec_l76_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty hash for a non-GitHub URL" do` at line 80.
pub fn ruby_github_latest_spec_l80_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:match_data) do` at line 86.
pub fn ruby_github_latest_spec_l86_d15_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby let `let(:brew_regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 100.
pub fn ruby_github_latest_spec_l100_d16_brew_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew_regex', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 102.
pub fn ruby_github_latest_spec_l102_d17_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 109.
pub fn ruby_github_latest_spec_l109_d18_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 129.
pub fn ruby_github_latest_spec_l129_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 134.
pub fn ruby_github_latest_spec_l134_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::GithubLatest do
// 7:   subject(:github_latest) { described_class }
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
// 19:   let(:generated) do
// 20:     {
// 21:       def:  {
// 22:         url:        "https://api.github.com/repos/abc/def/releases/latest",
// 23:         username:   "abc",
// 24:         repository: "def",
// 25:       },
// 26:       brew: {
// 27:         url:        "https://api.github.com/repos/Homebrew/brew/releases/latest",
// 28:         username:   "Homebrew",
// 29:         repository: "brew",
// 30:       },
// 31:     }
// 32:   end
// 33:   # For the sake of brevity, this is a limited subset of the information found
// 34:   # in release objects in a response from the GitHub API.
// 35:   let(:content) do
// 36:     <<~JSON
// 37:       {
// 38:         "tag_name": "1.2.3",
// 39:         "name": "1.2.3",
// 40:         "draft": false,
// 41:         "prerelease": false
// 42:       }
// 43:     JSON
// 44:   end
// 45:   let(:matches) { ["1.2.3"] }
// 46:
// 47:   describe "::match?" do
// 48:     it "returns true for a GitHub release artifact URL" do
// 49:       expect(github_latest.match?(github_urls[:release_asset])).to be true
// 50:     end
// 51:
// 52:     it "returns true for a GitHub tag archive URL" do
// 53:       expect(github_latest.match?(github_urls[:short_tag_archive])).to be true
// 54:       expect(github_latest.match?(github_urls[:long_tag_archive])).to be true
// 55:     end
// 56:
// 57:     it "returns true for a GitHub repository upload URL" do
// 58:       expect(github_latest.match?(github_urls[:repository_upload])).to be true
// 59:     end
// 60:
// 61:     it "returns false for a non-GitHub URL" do
// 62:       expect(github_latest.match?(non_github_url)).to be false
// 63:     end
// 64:   end
// 65:
// 66:   describe "::generate_input_values" do
// 67:     it "returns a hash containing a url and regex for a GitHub release artifact URL" do
// 68:       expect(github_latest.generate_input_values(github_urls[:release_asset])).to eq(generated[:def])
// 69:     end
// 70:
// 71:     it "returns a hash containing a url and regex for a GitHub tag archive URL" do
// 72:       expect(github_latest.generate_input_values(github_urls[:short_tag_archive])).to eq(generated[:def])
// 73:       expect(github_latest.generate_input_values(github_urls[:long_tag_archive])).to eq(generated[:def])
// 74:     end
// 75:
// 76:     it "returns a hash containing a url and regex for a GitHub repository upload URL" do
// 77:       expect(github_latest.generate_input_values(github_urls[:repository_upload])).to eq(generated[:def])
// 78:     end
// 79:
// 80:     it "returns an empty hash for a non-GitHub URL" do
// 81:       expect(github_latest.generate_input_values(non_github_url)).to eq({})
// 82:     end
// 83:   end
// 84:
// 85:   describe "::find_versions" do
// 86:     let(:match_data) do
// 87:       base = {
// 88:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 89:         regex:   Homebrew::Livecheck::Strategy::GithubReleases::DEFAULT_REGEX,
// 90:         url:     generated[:brew][:url],
// 91:       }
// 92:
// 93:       {
// 94:         fetched:        base.merge({ content: }),
// 95:         cached:         base.merge({ cached: true }),
// 96:         cached_default: base.merge({ matches: {}, cached: true }),
// 97:       }
// 98:     end
// 99:
// 100:     let(:brew_regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 101:
// 102:     it "finds versions in fetched content" do
// 103:       allow(GitHub::API).to receive(:open_rest).and_return(content)
// 104:
// 105:       expect(github_latest.find_versions(url: github_urls[:brew_tag_archive]))
// 106:         .to eq(match_data[:fetched])
// 107:     end
// 108:
// 109:     it "finds versions in provided content" do
// 110:       expect(github_latest.find_versions(url: github_urls[:brew_tag_archive], content:))
// 111:         .to eq(match_data[:cached])
// 112:
// 113:       # This `strategy` block is unnecessary but it's intended to test using a
// 114:       # regex in a `strategy` block.
// 115:       expect(
// 116:         github_latest.find_versions(
// 117:           url:     github_urls[:brew_tag_archive],
// 118:           regex:   brew_regex,
// 119:           content:,
// 120:         ) do |json, regex|
// 121:           match = json["tag_name"]&.match(regex)
// 122:           next if match.blank?
// 123:
// 124:           match[1]
// 125:         end,
// 126:       ).to eq(match_data[:cached].merge({ regex: brew_regex }))
// 127:     end
// 128:
// 129:     it "returns default match_data when url is blank" do
// 130:       expect(github_latest.find_versions(url: ""))
// 131:         .to eq({ matches: {}, regex: Homebrew::Livecheck::Strategy::GithubReleases::DEFAULT_REGEX, url: "" })
// 132:     end
// 133:
// 134:     it "returns default match_data when content is blank" do
// 135:       expect(github_latest.find_versions(url: github_urls[:brew_tag_archive], content: ""))
// 136:         .to eq(match_data[:cached_default])
// 137:     end
// 138:   end
// 139: end
