module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/hackage_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:hackage) { described_class }` at line 7.
pub fn ruby_hackage_spec_l7_d1_hackage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hackage', ...args)
}

// Ruby let `let(:hackage_urls) do` at line 9.
pub fn ruby_hackage_spec_l9_d2_hackage_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hackage_urls', ...args)
}

// Ruby let `let(:non_hackage_url) { "https://brew.sh/test" }` at line 15.
pub fn ruby_hackage_spec_l15_d3_non_hackage_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_hackage_url', ...args)
}

// Ruby let `let(:generated) do` at line 16.
pub fn ruby_hackage_spec_l16_d4_generated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generated', ...args)
}

// Ruby let `let(:content) do` at line 22.
pub fn ruby_hackage_spec_l22_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:matches) { ["1.2.3"] }` at line 51.
pub fn ruby_hackage_spec_l51_d6_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for a Hackage URL" do` at line 54.
pub fn ruby_hackage_spec_l54_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-Hackage URL" do` at line 59.
pub fn ruby_hackage_spec_l59_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing url and regex for a Hackage URL" do` at line 65.
pub fn ruby_hackage_spec_l65_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty hash for a non-Hackage URL" do` at line 70.
pub fn ruby_hackage_spec_l70_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:match_data) do` at line 76.
pub fn ruby_hackage_spec_l76_d11_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 90.
pub fn ruby_hackage_spec_l90_d12_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 101.
pub fn ruby_hackage_spec_l101_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
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
