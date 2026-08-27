module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/gnome_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:gnome) { described_class }` at line 7.
pub fn ruby_gnome_spec_l7_d1_gnome(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnome', ...args)
}

// Ruby let `let(:gnome_url) { "https://download.gnome.org/sources/abc/1.2/abc-1.2.3.tar.xz" }` at line 9.
pub fn ruby_gnome_spec_l9_d2_gnome_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnome_url', ...args)
}

// Ruby let `let(:non_gnome_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_gnome_spec_l10_d3_non_gnome_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_gnome_url', ...args)
}

// Ruby let `let(:generated) do` at line 11.
pub fn ruby_gnome_spec_l11_d4_generated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generated', ...args)
}

// Ruby let `let(:content) do` at line 17.
pub fn ruby_gnome_spec_l17_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:matches) do` at line 23.
pub fn ruby_gnome_spec_l23_d6_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for a GNOME URL" do` at line 31.
pub fn ruby_gnome_spec_l31_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-GNOME URL" do` at line 35.
pub fn ruby_gnome_spec_l35_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing url and regex for a GNOME URL" do` at line 41.
pub fn ruby_gnome_spec_l41_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty hash for a non-GNOME URL" do` at line 45.
pub fn ruby_gnome_spec_l45_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:match_data) do` at line 51.
pub fn ruby_gnome_spec_l51_d11_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 65.
pub fn ruby_gnome_spec_l65_d12_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 80.
pub fn ruby_gnome_spec_l80_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Gnome do
// 7:   subject(:gnome) { described_class }
// 8:
// 9:   let(:gnome_url) { "https://download.gnome.org/sources/abc/1.2/abc-1.2.3.tar.xz" }
// 10:   let(:non_gnome_url) { "https://brew.sh/test" }
// 11:   let(:generated) do
// 12:     {
// 13:       url:   "https://download.gnome.org/sources/abc/cache.json",
// 14:       regex: /abc-(\d+(?:\.\d+)*)\.t/i,
// 15:     }
// 16:   end
// 17:   let(:content) do
// 18:     <<~JSON
// 19:       [4, {"abc": {"40.1.0": {"news": "40.1/abc-40.1.0.news", "changes": "40.1/abc-40.1.0.changes", "tar.xz": "40.1/abc-40.1.0.tar.xz", "sha256sum": "40.1/abc-40.1.0.sha256sum"}, "1.2.90": {"news": "1.2/abc-1.2.90.news", "changes": "1.2/abc-1.2.90.changes", "tar.xz": "1.2/abc-1.2.90.tar.xz", "sha256sum": "1.2/abc-1.2.90.sha256sum"}, "1.2.4": {"news": "1.2/abc-1.2.4.news", "changes": "1.2/abc-1.2.4.changes", "tar.xz": "1.2/abc-1.2.4.tar.xz", "sha256sum": "1.2/abc-1.2.4.sha256sum"}, "1.2.3": {"news": "1.2/abc-1.2.3.news", "changes": "1.2/abc-1.2.3.changes", "tar.xz": "1.2/abc-1.2.3.tar.xz", "sha256sum": "1.2/abc-1.2.3.sha256sum"}, "1.1.0": {"news": "1.1/abc-1.1.0.news", "changes": "1.1/abc-1.1.0.changes", "tar.xz": "1.1/abc-1.1.0.tar.xz", "sha256sum": "1.1/abc-1.1.0.sha256sum"}, "1": {"news": "1/abc-1.news", "changes": "1/abc-1.changes", "tar.xz": "1/abc-1.tar.xz", "sha256sum": "1/abc-1.sha256sum"}}}, {"abc": ["1", "1.1.0", "1.2.3", "1.2.4", "1.2.90", "40.1.0"]}, {"1": ["LATEST-IS-1"], "1.1": ["LATEST-IS-1.1.0"], "1.2": ["LATEST-IS-1.2.4"], "40": ["LATEST-IS-40.1.0"], ".": ["cache.json"]}]
// 20:
// 21:     JSON
// 22:   end
// 23:   let(:matches) do
// 24:     {
// 25:       all:     ["40.1.0", "1.2.90", "1.2.4", "1.2.3", "1.1.0", "1"],
// 26:       default: ["40.1.0", "1.2.4", "1.2.3", "1"],
// 27:     }
// 28:   end
// 29:
// 30:   describe "::match?" do
// 31:     it "returns true for a GNOME URL" do
// 32:       expect(gnome.match?(gnome_url)).to be true
// 33:     end
// 34:
// 35:     it "returns false for a non-GNOME URL" do
// 36:       expect(gnome.match?(non_gnome_url)).to be false
// 37:     end
// 38:   end
// 39:
// 40:   describe "::generate_input_values" do
// 41:     it "returns a hash containing url and regex for a GNOME URL" do
// 42:       expect(gnome.generate_input_values(gnome_url)).to eq(generated)
// 43:     end
// 44:
// 45:     it "returns an empty hash for a non-GNOME URL" do
// 46:       expect(gnome.generate_input_values(non_gnome_url)).to eq({})
// 47:     end
// 48:   end
// 49:
// 50:   describe "::find_versions" do
// 51:     let(:match_data) do
// 52:       cached = {
// 53:         matches: matches[:default].to_h { |v| [v, Version.new(v)] },
// 54:         regex:   generated[:regex],
// 55:         url:     generated[:url],
// 56:         cached:  true,
// 57:       }
// 58:
// 59:       {
// 60:         cached:,
// 61:         cached_default: cached.merge({ matches: {} }),
// 62:       }
// 63:     end
// 64:
// 65:     it "finds versions in provided content" do
// 66:       expect(gnome.find_versions(url: gnome_url, content:))
// 67:         .to eq(match_data[:cached])
// 68:
// 69:       # These `strategy` blocks are unnecessary but they are intended to test
// 70:       # using a regex in a `strategy` block.
// 71:       expect(gnome.find_versions(url: gnome_url, content:) do |page, regex|
// 72:         page.scan(regex).map(&:first)
// 73:       end).to eq(match_data[:cached])
// 74:
// 75:       expect(gnome.find_versions(url: gnome_url, regex: generated[:regex], content:) do |page, regex|
// 76:         page.scan(regex).map(&:first)
// 77:       end).to eq(match_data[:cached].merge({ matches: matches[:all].to_h { |v| [v, Version.new(v)] } }))
// 78:     end
// 79:
// 80:     it "returns default match_data when content is blank" do
// 81:       expect(gnome.find_versions(url: gnome_url, content: ""))
// 82:         .to eq(match_data[:cached_default])
// 83:     end
// 84:   end
// 85: end
