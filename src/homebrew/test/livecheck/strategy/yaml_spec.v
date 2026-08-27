module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/yaml_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:yaml) { described_class }` at line 7.
pub fn ruby_yaml_spec_l7_d1_yaml(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('yaml', ...args)
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 9.
pub fn ruby_yaml_spec_l9_d2_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('http_url', ...args)
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_yaml_spec_l10_d3_non_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_http_url', ...args)
}

// Ruby let `let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }` at line 11.
pub fn ruby_yaml_spec_l11_d4_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby let `let(:content) do` at line 12.
pub fn ruby_yaml_spec_l12_d5_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:content_simple) { "version: 1.2.3" }` at line 37.
pub fn ruby_yaml_spec_l37_d6_content_simple(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content_simple', ...args)
}

// Ruby let `let(:content_invalid) { ">~" }` at line 40.
pub fn ruby_yaml_spec_l40_d7_content_invalid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content_invalid', ...args)
}

// Ruby let `let(:matches) do` at line 41.
pub fn ruby_yaml_spec_l41_d8_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for an HTTP URL" do` at line 49.
pub fn ruby_yaml_spec_l49_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 53.
pub fn ruby_yaml_spec_l53_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an object when given valid content" do` at line 59.
pub fn ruby_yaml_spec_l59_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array when given a block but content is blank" do` at line 65.
pub fn ruby_yaml_spec_l65_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "errors if provided content is not valid YAML" do` at line 69.
pub fn ruby_yaml_spec_l69_d13_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "returns an array of version strings when given content and a block" do` at line 74.
pub fn ruby_yaml_spec_l74_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "allows a nil return from a block" do` at line 88.
pub fn ruby_yaml_spec_l88_d15_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "errors if a block uses two arguments but a regex is not given" do` at line 92.
pub fn ruby_yaml_spec_l92_d16_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 97.
pub fn ruby_yaml_spec_l97_d17_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby let `let(:match_data) do` at line 104.
pub fn ruby_yaml_spec_l104_d18_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 118.
pub fn ruby_yaml_spec_l118_d19_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in content using a block" do` at line 127.
pub fn ruby_yaml_spec_l127_d20_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "errors if a block is not provided" do` at line 144.
pub fn ruby_yaml_spec_l144_d21_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 149.
pub fn ruby_yaml_spec_l149_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 154.
pub fn ruby_yaml_spec_l154_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Yaml do
// 7:   subject(:yaml) { described_class }
// 8:
// 9:   let(:http_url) { "https://brew.sh/blog/" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regex) { /^v?(\d+(?:\.\d+)+)$/i }
// 12:   let(:content) do
// 13:     <<~YAML
// 14:       versions:
// 15:         - version: 1.1.2
// 16:         - version: 1.1.2b
// 17:         - version: 1.1.2a
// 18:         - version: 1.1.1
// 19:         - version: 1.1.0
// 20:         - version: 1.1.0-rc3
// 21:         - version: 1.1.0-rc2
// 22:         - version: 1.1.0-rc1
// 23:         - version: 1.0.x-last
// 24:         - version: 1.0.3
// 25:         - version: 1.0.3-rc3
// 26:         - version: 1.0.3-rc2
// 27:         - version: 1.0.3-rc1
// 28:         - version: 1.0.2
// 29:         - version: 1.0.2-rc1
// 30:         - version: 1.0.1
// 31:         - version: 1.0.1-rc1
// 32:         - version: 1.0.0
// 33:         - version: 1.0.0-rc1
// 34:         - other: version is omitted from this object for testing
// 35:     YAML
// 36:   end
// 37:   let(:content_simple) { "version: 1.2.3" }
// 38:   # This should produce a `Psych::SyntaxError` (`did not find expected comment
// 39:   # or line break while scanning a block scalar`)
// 40:   let(:content_invalid) { ">~" }
// 41:   let(:matches) do
// 42:     {
// 43:       content: ["1.1.2", "1.1.1", "1.1.0", "1.0.3", "1.0.2", "1.0.1", "1.0.0"],
// 44:       simple:  ["1.2.3"],
// 45:     }
// 46:   end
// 47:
// 48:   describe "::match?" do
// 49:     it "returns true for an HTTP URL" do
// 50:       expect(yaml.match?(http_url)).to be true
// 51:     end
// 52:
// 53:     it "returns false for a non-HTTP URL" do
// 54:       expect(yaml.match?(non_http_url)).to be false
// 55:     end
// 56:   end
// 57:
// 58:   describe "::parse_yaml" do
// 59:     it "returns an object when given valid content" do
// 60:       expect(yaml.parse_yaml(content_simple)).to be_an_instance_of(Hash)
// 61:     end
// 62:   end
// 63:
// 64:   describe "::versions_from_content" do
// 65:     it "returns an empty array when given a block but content is blank" do
// 66:       expect(yaml.versions_from_content("", regex) { "1.2.3" }).to eq([])
// 67:     end
// 68:
// 69:     it "errors if provided content is not valid YAML" do
// 70:       expect { yaml.versions_from_content(content_invalid) { [] } }
// 71:         .to raise_error(RuntimeError, "Content could not be parsed as YAML.")
// 72:     end
// 73:
// 74:     it "returns an array of version strings when given content and a block" do
// 75:       # Returning a string from block
// 76:       expect(yaml.versions_from_content(content_simple) { |yaml| yaml["version"] }).to eq(matches[:simple])
// 77:       expect(yaml.versions_from_content(content_simple, regex) do |yaml|
// 78:         yaml["version"][regex, 1]
// 79:       end).to eq(matches[:simple])
// 80:
// 81:       # Returning an array of strings from block
// 82:       expect(yaml.versions_from_content(content, regex) do |yaml, regex|
// 83:         yaml["versions"].select { |item| item["version"]&.match?(regex) }
// 84:                         .map { |item| item["version"][regex, 1] }
// 85:       end).to eq(matches[:content])
// 86:     end
// 87:
// 88:     it "allows a nil return from a block" do
// 89:       expect(yaml.versions_from_content(content_simple, regex) { next }).to eq([])
// 90:     end
// 91:
// 92:     it "errors if a block uses two arguments but a regex is not given" do
// 93:       expect { yaml.versions_from_content(content_simple) { |yaml, regex| yaml["version"][regex, 1] } }
// 94:         .to raise_error("Two arguments found in `strategy` block but no regex provided.")
// 95:     end
// 96:
// 97:     it "errors on an invalid return type from a block" do
// 98:       expect { yaml.versions_from_content(content_simple, regex) { 123 } }
// 99:         .to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 100:     end
// 101:   end
// 102:
// 103:   describe "::find_versions" do
// 104:     let(:match_data) do
// 105:       base = {
// 106:         matches: matches[:content].to_h { |v| [v, Version.new(v)] },
// 107:         regex:,
// 108:         url:     http_url,
// 109:       }
// 110:
// 111:       {
// 112:         fetched:        base.merge({ content: }),
// 113:         cached:         base.merge({ cached: true }),
// 114:         cached_default: base.merge({ matches: {}, cached: true }),
// 115:       }
// 116:     end
// 117:
// 118:     it "finds versions in fetched content" do
// 119:       allow(Homebrew::Livecheck::Strategy).to receive(:page_content).and_return({ content: })
// 120:
// 121:       expect(yaml.find_versions(url: http_url, regex:) do |yaml, regex|
// 122:         yaml["versions"].select { |item| item["version"]&.match?(regex) }
// 123:                         .map { |item| item["version"][regex, 1] }
// 124:       end).to eq(match_data[:fetched])
// 125:     end
// 126:
// 127:     it "finds versions in content using a block" do
// 128:       expect(yaml.find_versions(url: http_url, regex:, content:) do |yaml, regex|
// 129:         yaml["versions"].select { |item| item["version"]&.match?(regex) }
// 130:                         .map { |item| item["version"][regex, 1] }
// 131:       end).to eq(match_data[:cached])
// 132:
// 133:       # NOTE: A regex should be provided using the `#regex` method in a
// 134:       #       `livecheck` block but we're using a regex literal in the
// 135:       #       `strategy` block here simply to ensure this method works as
// 136:       #       expected when a regex isn't provided.
// 137:       expect(yaml.find_versions(url: http_url, content:) do |yaml|
// 138:         regex = /^v?(\d+(?:\.\d+)+)$/i
// 139:         yaml["versions"].select { |item| item["version"]&.match?(regex) }
// 140:                         .map { |item| item["version"][regex, 1] }
// 141:       end).to eq(match_data[:cached].merge({ regex: nil }))
// 142:     end
// 143:
// 144:     it "errors if a block is not provided" do
// 145:       expect { yaml.find_versions(url: http_url, content:) }
// 146:         .to raise_error(ArgumentError, "Yaml requires a `strategy` block")
// 147:     end
// 148:
// 149:     it "returns default match_data when url is blank" do
// 150:       expect(yaml.find_versions(url: "", regex:, content:) { "1.2.3" })
// 151:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 152:     end
// 153:
// 154:     it "returns default match_data when content is blank" do
// 155:       expect(yaml.find_versions(url: http_url, regex:, content: "") { "1.2.3" })
// 156:         .to eq(match_data[:cached_default])
// 157:     end
// 158:   end
// 159: end
