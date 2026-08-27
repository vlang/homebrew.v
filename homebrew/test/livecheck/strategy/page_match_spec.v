module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/page_match_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:page_match) { described_class }` at line 7.
pub fn ruby_page_match_spec_l7_d1_page_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('page_match', ...args)
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 9.
pub fn ruby_page_match_spec_l9_d2_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('http_url', ...args)
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_page_match_spec_l10_d3_non_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_http_url', ...args)
}

// Ruby let `let(:regex) { %r{href=.*?/homebrew[._-]v?(\d+(?:\.\d+)+)/?["' >]}i }` at line 11.
pub fn ruby_page_match_spec_l11_d4_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby let `let(:content) do` at line 12.
pub fn ruby_page_match_spec_l12_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:matches) { ["2.6.0", "2.5.0", "2.4.0", "2.3.0", "2.2.0", "2.1.0", "2.0.0", "1.9.0"] }` at line 37.
pub fn ruby_page_match_spec_l37_d6_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for an HTTP URL" do` at line 40.
pub fn ruby_page_match_spec_l40_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 44.
pub fn ruby_page_match_spec_l44_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array if content is blank" do` at line 50.
pub fn ruby_page_match_spec_l50_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array if regex is blank" do` at line 54.
pub fn ruby_page_match_spec_l54_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array of version strings when given content" do` at line 58.
pub fn ruby_page_match_spec_l58_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 66.
pub fn ruby_page_match_spec_l66_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "allows a nil return from a block" do` at line 75.
pub fn ruby_page_match_spec_l75_d13_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 79.
pub fn ruby_page_match_spec_l79_d14_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby let `let(:match_data) do` at line 86.
pub fn ruby_page_match_spec_l86_d15_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 100.
pub fn ruby_page_match_spec_l100_d16_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 106.
pub fn ruby_page_match_spec_l106_d17_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 126.
pub fn ruby_page_match_spec_l126_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 131.
pub fn ruby_page_match_spec_l131_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "errors if a regex or `strategy` block is not provided" do` at line 136.
pub fn ruby_page_match_spec_l136_d20_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::PageMatch do
// 7:   subject(:page_match) { described_class }
// 8:
// 9:   let(:http_url) { "https://brew.sh/blog/" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regex) { %r{href=.*?/homebrew[._-]v?(\d+(?:\.\d+)+)/?["' >]}i }
// 12:   let(:content) do
// 13:     <<~HTML
// 14:       <!DOCTYPE html>
// 15:       <html>
// 16:         <head>
// 17:           <meta charset="utf-8">
// 18:           <title>Homebrew — Homebrew</title>
// 19:         </head>
// 20:         <body>
// 21:           <ul class="posts">
// 22:             <li><a href="/2020/12/01/homebrew-2.6.0/" title="2.6.0"><h2>2.6.0</h2><h3>01 Dec 2020</h3></a></li>
// 23:             <li><a href="/2020/11/18/homebrew-tap-with-bottles-uploaded-to-github-releases/" title="Homebrew tap with bottles uploaded to GitHub Releases"><h2>Homebrew tap with bottles uploaded to GitHub Releases</h2><h3>18 Nov 2020</h3></a></li>
// 24:             <li><a href="/2020/09/08/homebrew-2.5.0/" title="2.5.0"><h2>2.5.0</h2><h3>08 Sep 2020</h3></a></li>
// 25:             <li><a href="/2020/06/11/homebrew-2.4.0/" title="2.4.0"><h2>2.4.0</h2><h3>11 Jun 2020</h3></a></li>
// 26:             <li><a href="/2020/05/29/homebrew-2.3.0/" title="2.3.0"><h2>2.3.0</h2><h3>29 May 2020</h3></a></li>
// 27:             <li><a href="/2019/11/27/homebrew-2.2.0/" title="2.2.0"><h2>2.2.0</h2><h3>27 Nov 2019</h3></a></li>
// 28:             <li><a href="/2019/06/14/homebrew-maintainer-meeting/" title="Homebrew Maintainer Meeting"><h2>Homebrew Maintainer Meeting</h2><h3>14 Jun 2019</h3></a></li>
// 29:             <li><a href="/2019/04/04/homebrew-2.1.0/" title="2.1.0"><h2>2.1.0</h2><h3>04 Apr 2019</h3></a></li>
// 30:             <li><a href="/2019/02/02/homebrew-2.0.0/" title="2.0.0"><h2>2.0.0</h2><h3>02 Feb 2019</h3></a></li>
// 31:             <li><a href="/2019/01/09/homebrew-1.9.0/" title="1.9.0"><h2>1.9.0</h2><h3>09 Jan 2019</h3></a></li>
// 32:           </ul>
// 33:         </body>
// 34:       </html>
// 35:     HTML
// 36:   end
// 37:   let(:matches) { ["2.6.0", "2.5.0", "2.4.0", "2.3.0", "2.2.0", "2.1.0", "2.0.0", "1.9.0"] }
// 38:
// 39:   describe "::match?" do
// 40:     it "returns true for an HTTP URL" do
// 41:       expect(page_match.match?(http_url)).to be true
// 42:     end
// 43:
// 44:     it "returns false for a non-HTTP URL" do
// 45:       expect(page_match.match?(non_http_url)).to be false
// 46:     end
// 47:   end
// 48:
// 49:   describe "::versions_from_content" do
// 50:     it "returns an empty array if content is blank" do
// 51:       expect(page_match.versions_from_content("", regex)).to eq([])
// 52:     end
// 53:
// 54:     it "returns an empty array if regex is blank" do
// 55:       expect(page_match.versions_from_content(content, nil)).to eq([])
// 56:     end
// 57:
// 58:     it "returns an array of version strings when given content" do
// 59:       expect(page_match.versions_from_content(content, regex)).to eq(matches)
// 60:
// 61:       # Regexes should use a capture group around the version but a regex
// 62:       # without one should still be handled
// 63:       expect(page_match.versions_from_content(content, /\d+(?:\.\d+)+/i)).to eq(matches)
// 64:     end
// 65:
// 66:     it "returns an array of version strings when given content and a block" do
// 67:       # Returning a string from block
// 68:       expect(page_match.versions_from_content(content, regex) { "1.2.3" }).to eq(["1.2.3"])
// 69:
// 70:       # Returning an array of strings from block
// 71:       expect(page_match.versions_from_content(content, regex) { |page, regex| page.scan(regex).map(&:first) })
// 72:         .to eq(matches)
// 73:     end
// 74:
// 75:     it "allows a nil return from a block" do
// 76:       expect(page_match.versions_from_content(content, regex) { next }).to eq([])
// 77:     end
// 78:
// 79:     it "errors on an invalid return type from a block" do
// 80:       expect { page_match.versions_from_content(content, regex) { 123 } }
// 81:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 82:     end
// 83:   end
// 84:
// 85:   describe "::find_versions" do
// 86:     let(:match_data) do
// 87:       base = {
// 88:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 89:         regex:,
// 90:         url:     http_url,
// 91:       }
// 92:
// 93:       {
// 94:         fetched:        base.merge({ content: }),
// 95:         cached:         base.merge({ cached: true }),
// 96:         cached_default: base.merge({ matches: {}, cached: true }),
// 97:       }
// 98:     end
// 99:
// 100:     it "finds versions in fetched content" do
// 101:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 102:
// 103:       expect(page_match.find_versions(url: http_url, regex:)).to eq(match_data[:fetched])
// 104:     end
// 105:
// 106:     it "finds versions in provided content" do
// 107:       expect(page_match.find_versions(url: http_url, regex:, content:)).to eq(match_data[:cached])
// 108:
// 109:       # NOTE: Ideally, a regex should always be provided to `#find_versions`
// 110:       #       for `PageMatch` but there are currently some `livecheck` blocks in
// 111:       #       casks where `#regex` isn't used and the regex only exists within a
// 112:       #       `strategy` block. This isn't ideal but, for the moment, we allow a
// 113:       #       `strategy` block to act as a substitution for a regex and we need to
// 114:       #       test this scenario to ensure it works.
// 115:       #
// 116:       # Under normal circumstances, a regex should be established in a
// 117:       # `livecheck` block using `#regex` and passed into the `strategy` block
// 118:       # using `do |page, regex|`. Hopefully over time we can address related
// 119:       # issues and get to a point where regexes are always established using
// 120:       # `#regex`.
// 121:       expect(page_match.find_versions(url: http_url, content:) do |page|
// 122:         page.scan(%r{href=.*?/homebrew[._-]v?(\d+(?:\.\d+)+)/?["' >]}i).map(&:first)
// 123:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 124:     end
// 125:
// 126:     it "returns default match_data when url is blank" do
// 127:       expect(page_match.find_versions(url: "", regex:, content:))
// 128:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 129:     end
// 130:
// 131:     it "returns default match_data when content is blank" do
// 132:       expect(page_match.find_versions(url: http_url, regex:, content: ""))
// 133:         .to eq(match_data[:cached_default])
// 134:     end
// 135:
// 136:     it "errors if a regex or `strategy` block is not provided" do
// 137:       expect { page_match.find_versions(url: http_url, content:) }
// 138:         .to raise_error(ArgumentError, "PageMatch requires a regex or `strategy` block")
// 139:     end
// 140:   end
// 141: end
