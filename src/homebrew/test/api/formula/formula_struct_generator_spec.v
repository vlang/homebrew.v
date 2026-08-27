module formula

import brew_runtime

// Translated from Homebrew/brew `test/api/formula/formula_struct_generator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:raw_dependency_hash) do` at line 7.
pub fn ruby_formula_struct_generator_spec_l7_d1_raw_dependency_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_dependency_hash', ...args)
}

// Ruby let `let(:symbolized_dependency_hash) do` at line 29.
pub fn ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbolized_dependency_hash', ...args)
}

// Ruby let `let(:dependency_args) do` at line 51.
pub fn ruby_formula_struct_generator_spec_l51_d3_dependency_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_args', ...args)
}

// Ruby let `let(:uses_from_macos_args) do` at line 59.
pub fn ruby_formula_struct_generator_spec_l59_d4_uses_from_macos_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses_from_macos_args', ...args)
}

// Ruby let `let(:requirements_array) do` at line 68.
pub fn ruby_formula_struct_generator_spec_l68_d5_requirements_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requirements_array', ...args)
}

// Ruby let `let(:stable_requirements_args) do` at line 80.
pub fn ruby_formula_struct_generator_spec_l80_d6_stable_requirements_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stable_requirements_args', ...args)
}

// Ruby let `let(:head_requirements_args) do` at line 90.
pub fn ruby_formula_struct_generator_spec_l90_d7_head_requirements_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head_requirements_args', ...args)
}

// Ruby specify `specify "::process_dependencies_and_requirements", :aggregate_failures do` at line 100.
pub fn ruby_formula_struct_generator_spec_l100_d8_process_dependencies_and_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_dependencies_and_requirements', ...args)
}

// Ruby specify `specify "::generate_formula_struct_hash falls back to stable deps when head_dependencies is absent" do` at line 138.
pub fn ruby_formula_struct_generator_spec_l138_d9_generate_formula_struct_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::generate_formula_struct_hash', ...args)
}

// Ruby specify `specify "::generate_formula_struct_hash preserves stable patches" do` at line 159.
pub fn ruby_formula_struct_generator_spec_l159_d10_generate_formula_struct_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::generate_formula_struct_hash', ...args)
}

// Ruby specify `specify "::symbolize_dependency_hash" do` at line 179.
pub fn ruby_formula_struct_generator_spec_l179_d11_symbolize_dependency_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::symbolize_dependency_hash', ...args)
}

// Ruby specify `specify "::process_dependencies" do` at line 184.
pub fn ruby_formula_struct_generator_spec_l184_d12_process_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_dependencies', ...args)
}

// Ruby specify `specify "::process_uses_from_macos" do` at line 189.
pub fn ruby_formula_struct_generator_spec_l189_d13_process_uses_from_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_uses_from_macos', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::Formula::FormulaStructGenerator do
// 7:   let(:raw_dependency_hash) do
// 8:     {
// 9:       "dependencies"           => [
// 10:         "foo",
// 11:         { "bar" => "build" },
// 12:         { "baz" => ["build", "test"] },
// 13:       ],
// 14:       "uses_from_macos"        => [
// 15:         "abc",
// 16:         { "def" => "build" },
// 17:         { "ghi" => ["build", "test"] },
// 18:         "jkl",
// 19:       ],
// 20:       "uses_from_macos_bounds" => [
// 21:         {},
// 22:         { "since" => "catalina" },
// 23:         {},
// 24:         { "since" => "catalina" },
// 25:       ],
// 26:     }
// 27:   end
// 28:
// 29:   let(:symbolized_dependency_hash) do
// 30:     {
// 31:       "dependencies"           => [
// 32:         "foo",
// 33:         { "bar" => :build },
// 34:         { "baz" => [:build, :test] },
// 35:       ],
// 36:       "uses_from_macos"        => [
// 37:         "abc",
// 38:         { "def" => :build },
// 39:         { "ghi" => [:build, :test] },
// 40:         "jkl",
// 41:       ],
// 42:       "uses_from_macos_bounds" => [
// 43:         {},
// 44:         { since: :catalina },
// 45:         {},
// 46:         { since: :catalina },
// 47:       ],
// 48:     }
// 49:   end
// 50:
// 51:   let(:dependency_args) do
// 52:     [
// 53:       "foo",
// 54:       { "bar" => :build },
// 55:       { "baz" => [:build, :test] },
// 56:     ]
// 57:   end
// 58:
// 59:   let(:uses_from_macos_args) do
// 60:     [
// 61:       ["abc", {}],
// 62:       [{ "def" => :build, since: :catalina }, {}],
// 63:       [{ "ghi" => [:build, :test] }, {}],
// 64:       ["jkl", { since: :catalina }],
// 65:     ]
// 66:   end
// 67:
// 68:   let(:requirements_array) do
// 69:     [
// 70:       { "name" => "linux", "specs" => ["head"] },
// 71:       { "name" => "codesign", "specs" => ["stable", "head"] },
// 72:       { "name" => "arch", "version" => "arm64", "specs" => ["stable", "head"] },
// 73:       { "name" => "macos", "version" => "14", "specs" => ["stable"] },
// 74:       { "name" => "maximum_macos", "version" => "13", "specs" => ["stable", "head"], "contexts" => ["build"] },
// 75:       { "name" => "xcode", "specs" => ["stable", "head"] },
// 76:       { "name" => "xcode", "version" => "11.2", "specs" => ["stable", "head"], "contexts" => ["build", "test"] },
// 77:     ]
// 78:   end
// 79:
// 80:   let(:stable_requirements_args) do
// 81:     [
// 82:       { arch: [:arm64] },
// 83:       { macos: [:sonoma] },
// 84:       { maximum_macos: [:ventura, :build] },
// 85:       :xcode,
// 86:       { xcode: ["11.2", :build, :test] },
// 87:     ]
// 88:   end
// 89:
// 90:   let(:head_requirements_args) do
// 91:     [
// 92:       :linux,
// 93:       { arch: [:arm64] },
// 94:       { maximum_macos: [:ventura, :build] },
// 95:       :xcode,
// 96:       { xcode: ["11.2", :build, :test] },
// 97:     ]
// 98:   end
// 99:
// 100:   specify "::process_dependencies_and_requirements", :aggregate_failures do
// 101:     expect(
// 102:       described_class.process_dependencies_and_requirements(
// 103:         raw_dependency_hash, requirements_array, :stable
// 104:       ),
// 105:     ).to eq [dependency_args + stable_requirements_args, uses_from_macos_args]
// 106:
// 107:     expect(
// 108:       described_class.process_dependencies_and_requirements(
// 109:         raw_dependency_hash, requirements_array, :head
// 110:       ),
// 111:     ).to eq [dependency_args + head_requirements_args, uses_from_macos_args]
// 112:
// 113:     expect(
// 114:       described_class.process_dependencies_and_requirements(
// 115:         raw_dependency_hash, nil, :head
// 116:       ),
// 117:     ).to eq [dependency_args, uses_from_macos_args]
// 118:
// 119:     expect(
// 120:       described_class.process_dependencies_and_requirements(
// 121:         nil, requirements_array, :stable
// 122:       ),
// 123:     ).to eq [stable_requirements_args, []]
// 124:
// 125:     expect(
// 126:       described_class.process_dependencies_and_requirements(
// 127:         nil, requirements_array, :head
// 128:       ),
// 129:     ).to eq [head_requirements_args, []]
// 130:
// 131:     expect(
// 132:       described_class.process_dependencies_and_requirements(
// 133:         nil, nil, :stable
// 134:       ),
// 135:     ).to eq [[], []]
// 136:   end
// 137:
// 138:   specify "::generate_formula_struct_hash falls back to stable deps when head_dependencies is absent" do
// 139:     hash = {
// 140:       "desc"                     => "Test formula",
// 141:       "homepage"                 => "https://example.com",
// 142:       "license"                  => "MIT",
// 143:       "ruby_source_checksum"     => { "sha256" => "abc123" },
// 144:       "versions"                 => { "stable" => "1.0.0" },
// 145:       "urls"                     => { "stable" => { "url" => "https://example.com/foo-1.0.tar.gz" } },
// 146:       "dependencies"             => ["foo"],
// 147:       "recommended_dependencies" => [],
// 148:       "optional_dependencies"    => [],
// 149:       "uses_from_macos"          => [],
// 150:       "uses_from_macos_bounds"   => [],
// 151:     }
// 152:
// 153:     struct = described_class.generate_formula_struct_hash(hash)
// 154:
// 155:     expect(struct.head_dependencies).not_to be_empty
// 156:     expect(struct.head_dependencies).to eq struct.stable_dependencies
// 157:   end
// 158:
// 159:   specify "::generate_formula_struct_hash preserves stable patches" do
// 160:     hash = {
// 161:       "desc"                 => "Test formula",
// 162:       "homepage"             => "https://example.com",
// 163:       "license"              => "MIT",
// 164:       "ruby_source_checksum" => { "sha256" => "abc123" },
// 165:       "versions"             => { "stable" => "1.0.0" },
// 166:       "urls"                 => { "stable" => { "url" => "https://example.com/foo-1.0.tar.gz" } },
// 167:       "patches"              => [
// 168:         {
// 169:           "strip"  => "p1",
// 170:           "url"    => "https://example.com/foo.patch",
// 171:           "sha256" => "def456",
// 172:         },
// 173:       ],
// 174:     }
// 175:
// 176:     expect(described_class.generate_formula_struct_hash(hash).stable_patches).to eq hash["patches"]
// 177:   end
// 178:
// 179:   specify "::symbolize_dependency_hash" do
// 180:     output = described_class.symbolize_dependency_hash(raw_dependency_hash)
// 181:     expect(output).to eq symbolized_dependency_hash
// 182:   end
// 183:
// 184:   specify "::process_dependencies" do
// 185:     output = described_class.process_dependencies(symbolized_dependency_hash)
// 186:     expect(output).to eq dependency_args
// 187:   end
// 188:
// 189:   specify "::process_uses_from_macos" do
// 190:     output = described_class.process_uses_from_macos(symbolized_dependency_hash)
// 191:     expect(output).to eq uses_from_macos_args
// 192:   end
// 193: end
