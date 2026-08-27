module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/crate_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:crate) { described_class }` at line 7.
pub fn ruby_crate_spec_l7_d1_crate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('crate', ...args)
}

// Ruby let `let(:crate_url) { "https://static.crates.io/crates/example/example-0.1.0.crate" }` at line 9.
pub fn ruby_crate_spec_l9_d2_crate_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('crate_url', ...args)
}

// Ruby let `let(:non_crate_url) { "https://brew.sh/test" }` at line 10.
pub fn ruby_crate_spec_l10_d3_non_crate_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_crate_url', ...args)
}

// Ruby let `let(:regex) { /v?(\d+(?:\.\d+)+)/i }` at line 13.
pub fn ruby_crate_spec_l13_d4_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby let `let(:generated) do` at line 14.
pub fn ruby_crate_spec_l14_d5_generated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generated', ...args)
}

// Ruby let `let(:content) do` at line 19.
pub fn ruby_crate_spec_l19_d6_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:matches) { ["1.0.0", "1.0.1"] }` at line 48.
pub fn ruby_crate_spec_l48_d7_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for a crate URL" do` at line 51.
pub fn ruby_crate_spec_l51_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-crate URL" do` at line 55.
pub fn ruby_crate_spec_l55_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a hash containing url for a crate URL" do` at line 61.
pub fn ruby_crate_spec_l61_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty hash for a non-crate URL" do` at line 65.
pub fn ruby_crate_spec_l65_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:match_data) do` at line 71.
pub fn ruby_crate_spec_l71_d12_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 85.
pub fn ruby_crate_spec_l85_d13_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 93.
pub fn ruby_crate_spec_l93_d14_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in provided content using a block" do` at line 101.
pub fn ruby_crate_spec_l101_d15_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when block doesn't return version information" do` at line 121.
pub fn ruby_crate_spec_l121_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 132.
pub fn ruby_crate_spec_l132_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 137.
pub fn ruby_crate_spec_l137_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Crate do
// 7:   subject(:crate) { described_class }
// 8:
// 9:   let(:crate_url) { "https://static.crates.io/crates/example/example-0.1.0.crate" }
// 10:   let(:non_crate_url) { "https://brew.sh/test" }
// 11:   # This only differs from the `DEFAULT_REGEX` so we can distinguish between a
// 12:   # provided regex and the default strategy regex in testing.
// 13:   let(:regex) { /v?(\d+(?:\.\d+)+)/i }
// 14:   let(:generated) do
// 15:     { url: "https://crates.io/api/v1/crates/example/versions" }
// 16:   end
// 17:   # This is a limited subset of a `versions` response object, for the sake of
// 18:   # testing.
// 19:   let(:content) do
// 20:     <<~JSON
// 21:       {
// 22:         "versions": [
// 23:           {
// 24:             "crate": "example",
// 25:             "created_at": "2023-01-03T00:00:00.000000+00:00",
// 26:             "num": "1.0.2",
// 27:             "updated_at": "2023-01-03T00:00:00.000000+00:00",
// 28:             "yanked": true
// 29:           },
// 30:           {
// 31:             "crate": "example",
// 32:             "created_at": "2023-01-02T00:00:00.000000+00:00",
// 33:             "num": "1.0.1",
// 34:             "updated_at": "2023-01-02T00:00:00.000000+00:00",
// 35:             "yanked": false
// 36:           },
// 37:           {
// 38:             "crate": "example",
// 39:             "created_at": "2023-01-01T00:00:00.000000+00:00",
// 40:             "num": "1.0.0",
// 41:             "updated_at": "2023-01-01T00:00:00.000000+00:00",
// 42:             "yanked": false
// 43:           }
// 44:         ]
// 45:       }
// 46:     JSON
// 47:   end
// 48:   let(:matches) { ["1.0.0", "1.0.1"] }
// 49:
// 50:   describe "::match?" do
// 51:     it "returns true for a crate URL" do
// 52:       expect(crate.match?(crate_url)).to be true
// 53:     end
// 54:
// 55:     it "returns false for a non-crate URL" do
// 56:       expect(crate.match?(non_crate_url)).to be false
// 57:     end
// 58:   end
// 59:
// 60:   describe "::generate_input_values" do
// 61:     it "returns a hash containing url for a crate URL" do
// 62:       expect(crate.generate_input_values(crate_url)).to eq(generated)
// 63:     end
// 64:
// 65:     it "returns an empty hash for a non-crate URL" do
// 66:       expect(crate.generate_input_values(non_crate_url)).to eq({})
// 67:     end
// 68:   end
// 69:
// 70:   describe "::find_versions" do
// 71:     let(:match_data) do
// 72:       base = {
// 73:         matches: matches.to_h { |v| [v, Version.new(v)] },
// 74:         regex:   nil,
// 75:         url:     generated[:url],
// 76:       }
// 77:
// 78:       {
// 79:         fetched:        base.merge({ content: }),
// 80:         cached:         base.merge({ cached: true }),
// 81:         cached_default: base.merge({ matches: {}, cached: true }),
// 82:       }
// 83:     end
// 84:
// 85:     it "finds versions in fetched content" do
// 86:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 87:
// 88:       expect(crate.find_versions(url: crate_url, regex:))
// 89:         .to eq(match_data[:fetched].merge({ regex: }))
// 90:       expect(crate.find_versions(url: crate_url)).to eq(match_data[:fetched])
// 91:     end
// 92:
// 93:     it "finds versions in provided content" do
// 94:       expect(crate.find_versions(url: crate_url, regex:, content:))
// 95:         .to eq(match_data[:cached].merge({ regex: }))
// 96:
// 97:       expect(crate.find_versions(url: crate_url, content:))
// 98:         .to eq(match_data[:cached])
// 99:     end
// 100:
// 101:     it "finds versions in provided content using a block" do
// 102:       expect(crate.find_versions(url: crate_url, regex:, content:) do |json, regex|
// 103:         json["versions"]&.map do |version|
// 104:           next if version["yanked"] == true
// 105:           next if (match = version["num"]&.match(regex)).blank?
// 106:
// 107:           match[1]
// 108:         end
// 109:       end).to eq(match_data[:cached].merge({ regex: }))
// 110:
// 111:       expect(crate.find_versions(url: crate_url, content:) do |json|
// 112:         json["versions"]&.map do |version|
// 113:           next if version["yanked"] == true
// 114:           next if (match = version["num"]&.match(regex)).blank?
// 115:
// 116:           match[1]
// 117:         end
// 118:       end).to eq(match_data[:cached])
// 119:     end
// 120:
// 121:     it "returns default match_data when block doesn't return version information" do
// 122:       no_match_regex = /will_not_match/i
// 123:
// 124:       expect(crate.find_versions(url: crate_url, content: '{"other":true}'))
// 125:         .to eq(match_data[:cached_default])
// 126:       expect(crate.find_versions(url: crate_url, content: '{"versions":[{}]}'))
// 127:         .to eq(match_data[:cached_default])
// 128:       expect(crate.find_versions(url: crate_url, regex: no_match_regex, content:))
// 129:         .to eq(match_data[:cached_default].merge({ regex: no_match_regex }))
// 130:     end
// 131:
// 132:     it "returns default match_data when url is blank" do
// 133:       expect(crate.find_versions(url: ""))
// 134:         .to eq({ matches: {}, regex: nil, url: "" })
// 135:     end
// 136:
// 137:     it "returns default match_data when content is blank" do
// 138:       expect(crate.find_versions(url: crate_url, content: "{}"))
// 139:         .to eq(match_data[:cached_default])
// 140:       expect(crate.find_versions(url: crate_url, content: ""))
// 141:         .to eq(match_data[:cached_default])
// 142:     end
// 143:   end
// 144: end
