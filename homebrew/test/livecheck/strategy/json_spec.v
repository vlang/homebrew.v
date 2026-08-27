module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/json_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:json) { described_class }` at line 7.
pub fn ruby_json_spec_l7_d1_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json', ...args)
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 9.
pub fn ruby_json_spec_l9_d2_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('http_url', ...args)
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_json_spec_l10_d3_non_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_http_url', ...args)
}

// Ruby let `let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 11.
pub fn ruby_json_spec_l11_d4_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby let `let(:content) do` at line 12.
pub fn ruby_json_spec_l12_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:content_simple) { '{"version":"1.2.3"}' }` at line 40.
pub fn ruby_json_spec_l40_d6_content_simple(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content_simple', ...args)
}

// Ruby let `let(:matches) do` at line 41.
pub fn ruby_json_spec_l41_d7_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for an HTTP URL" do` at line 49.
pub fn ruby_json_spec_l49_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 53.
pub fn ruby_json_spec_l53_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an object when given valid content" do` at line 59.
pub fn ruby_json_spec_l59_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array when given a block but content is blank" do` at line 65.
pub fn ruby_json_spec_l65_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "errors if provided content is not valid JSON" do` at line 69.
pub fn ruby_json_spec_l69_d12_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 74.
pub fn ruby_json_spec_l74_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "allows a nil return from a block" do` at line 88.
pub fn ruby_json_spec_l88_d14_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 92.
pub fn ruby_json_spec_l92_d15_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby let `let(:match_data) do` at line 99.
pub fn ruby_json_spec_l99_d16_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 113.
pub fn ruby_json_spec_l113_d17_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in content using a block" do` at line 122.
pub fn ruby_json_spec_l122_d18_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "errors if a block is not provided" do` at line 139.
pub fn ruby_json_spec_l139_d19_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 144.
pub fn ruby_json_spec_l144_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 149.
pub fn ruby_json_spec_l149_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Json do
// 7:   subject(:json) { described_class }
// 8:
// 9:   let(:http_url) { "https://brew.sh/blog/" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 12:   let(:content) do
// 13:     <<~JSON
// 14:       {
// 15:         "versions": [
// 16:           { "version": "1.1.2" },
// 17:           { "version": "1.1.2b" },
// 18:           { "version": "1.1.2a" },
// 19:           { "version": "1.1.1" },
// 20:           { "version": "1.1.0" },
// 21:           { "version": "1.1.0-rc3" },
// 22:           { "version": "1.1.0-rc2" },
// 23:           { "version": "1.1.0-rc1" },
// 24:           { "version": "1.0.x-last" },
// 25:           { "version": "1.0.3" },
// 26:           { "version": "1.0.3-rc3" },
// 27:           { "version": "1.0.3-rc2" },
// 28:           { "version": "1.0.3-rc1" },
// 29:           { "version": "1.0.2" },
// 30:           { "version": "1.0.2-rc1" },
// 31:           { "version": "1.0.1" },
// 32:           { "version": "1.0.1-rc1" },
// 33:           { "version": "1.0.0" },
// 34:           { "version": "1.0.0-rc1" },
// 35:           { "other": "version is omitted from this object for testing" }
// 36:         ]
// 37:       }
// 38:     JSON
// 39:   end
// 40:   let(:content_simple) { '{"version":"1.2.3"}' }
// 41:   let(:matches) do
// 42:     {
// 43:       content: ["1.1.2", "1.1.1", "1.1.0", "1.0.3", "1.0.2", "1.0.1", "1.0.0"],
// 44:       simple:  ["1.2.3"],
// 45:     }
// 46:   end
// 47:
// 48:   describe "::match?" do
// 49:     it "returns true for an HTTP URL" do
// 50:       expect(json.match?(http_url)).to be true
// 51:     end
// 52:
// 53:     it "returns false for a non-HTTP URL" do
// 54:       expect(json.match?(non_http_url)).to be false
// 55:     end
// 56:   end
// 57:
// 58:   describe "::parse_json" do
// 59:     it "returns an object when given valid content" do
// 60:       expect(json.parse_json(content_simple)).to be_an_instance_of(Hash)
// 61:     end
// 62:   end
// 63:
// 64:   describe "::versions_from_content" do
// 65:     it "returns an empty array when given a block but content is blank" do
// 66:       expect(json.versions_from_content("", regex) { "1.2.3" }).to eq([])
// 67:     end
// 68:
// 69:     it "errors if provided content is not valid JSON" do
// 70:       expect { json.versions_from_content("not valid JSON") { [] } }
// 71:         .to raise_error(RuntimeError, "Content could not be parsed as JSON.")
// 72:     end
// 73:
// 74:     it "returns an array of version strings when given content and a block" do
// 75:       # Returning a string from block
// 76:       expect(json.versions_from_content(content_simple) { |json| json["version"] }).to eq(matches[:simple])
// 77:       expect(json.versions_from_content(content_simple, regex) do |json|
// 78:         json["version"][regex, 1]
// 79:       end).to eq(matches[:simple])
// 80:
// 81:       # Returning an array of strings from block
// 82:       expect(json.versions_from_content(content, regex) do |json, regex|
// 83:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 84:                         .map { |item| item["version"][regex, 1] }
// 85:       end).to eq(matches[:content])
// 86:     end
// 87:
// 88:     it "allows a nil return from a block" do
// 89:       expect(json.versions_from_content(content_simple, regex) { next }).to eq([])
// 90:     end
// 91:
// 92:     it "errors on an invalid return type from a block" do
// 93:       expect { json.versions_from_content(content_simple, regex) { 123 } }
// 94:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 95:     end
// 96:   end
// 97:
// 98:   describe "::find_versions" do
// 99:     let(:match_data) do
// 100:       base = {
// 101:         matches: matches[:content].to_h { |v| [v, Version.new(v)] },
// 102:         regex:,
// 103:         url:     http_url,
// 104:       }
// 105:
// 106:       {
// 107:         fetched:        base.merge({ content: }),
// 108:         cached:         base.merge({ cached: true }),
// 109:         cached_default: base.merge({ matches: {}, cached: true }),
// 110:       }
// 111:     end
// 112:
// 113:     it "finds versions in fetched content" do
// 114:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 115:
// 116:       expect(json.find_versions(url: http_url, regex:) do |json, regex|
// 117:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 118:                         .map { |item| item["version"][regex, 1] }
// 119:       end).to eq(match_data[:fetched])
// 120:     end
// 121:
// 122:     it "finds versions in content using a block" do
// 123:       expect(json.find_versions(url: http_url, regex:, content:) do |json, regex|
// 124:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 125:                         .map { |item| item["version"][regex, 1] }
// 126:       end).to eq(match_data[:cached])
// 127:
// 128:       # NOTE: A regex should be provided using the `#regex` method in a
// 129:       #       `livecheck` block but we're using a regex literal in the
// 130:       #       `strategy` block here simply to ensure this method works as
// 131:       #       expected when a regex isn't provided.
// 132:       expect(json.find_versions(url: http_url, content:) do |json|
// 133:         regex = /^v?(\d+(?:\.\d+)+)$/i
// 134:         json["versions"].select { |item| item["version"]&.match?(regex) }
// 135:                         .map { |item| item["version"][regex, 1] }
// 136:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 137:     end
// 138:
// 139:     it "errors if a block is not provided" do
// 140:       expect { json.find_versions(url: http_url, content:) }
// 141:         .to raise_error(ArgumentError, "Json requires a `strategy` block")
// 142:     end
// 143:
// 144:     it "returns default match_data when url is blank" do
// 145:       expect(json.find_versions(url: "", regex:, content:) { "1.2.3" })
// 146:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 147:     end
// 148:
// 149:     it "returns default match_data when content is blank" do
// 150:       expect(json.find_versions(url: http_url, regex:, content: "") { "1.2.3" })
// 151:         .to eq(match_data[:cached_default])
// 152:     end
// 153:   end
// 154: end
