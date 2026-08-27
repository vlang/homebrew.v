module api

import brew_runtime

// Translated from Homebrew/brew `test/api/packages_index_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cache_dir) { mktmpdir }` at line 7.
pub fn ruby_packages_index_spec_l7_d1_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby let `let(:target) { cache_dir/"packages.arm64_test.jws.json" }` at line 8.
pub fn ruby_packages_index_spec_l8_d2_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target', ...args)
}

// Ruby let `let(:parsed) do` at line 9.
pub fn ruby_packages_index_spec_l9_d3_parsed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parsed', ...args)
}

// Ruby let `let(:payload) { JSON.generate(parsed) }` at line 22.
pub fn ruby_packages_index_spec_l22_d4_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('payload', ...args)
}

// Ruby method `write_index!` at line 24.
pub fn ruby_packages_index_spec_l24_d5_write_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_index!', ...args)
}

// Ruby method `load_index` at line 29.
pub fn ruby_packages_index_spec_l29_d6_load_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_index', ...args)
}

// Ruby it `it "serves entries and top-level values from a written index" do` at line 33.
pub fn ruby_packages_index_spec_l33_d7_serves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serves', ...args)
}

// Ruby it `it "does not load an index whose source envelope changed" do` at line 49.
pub fn ruby_packages_index_spec_l49_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not load an index built for a different payload" do` at line 56.
pub fn ruby_packages_index_spec_l56_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises on lookups whose recorded offsets do not match the payload" do` at line 62.
pub fn ruby_packages_index_spec_l62_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on lookups remapped to a matching key in another section" do` at line 72.
pub fn ruby_packages_index_spec_l72_d11_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not load an index whose top-level spans do not tile the payload" do` at line 82.
pub fn ruby_packages_index_spec_l82_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::PackagesIndex do
// 7:   let(:cache_dir) { mktmpdir }
// 8:   let(:target) { cache_dir/"packages.arm64_test.jws.json" }
// 9:   let(:parsed) do
// 10:     {
// 11:       "formulae"             => {
// 12:         "foo" => { "desc" => "Foo formula", "stable_version" => "1.0.0" },
// 13:         "bar" => { "desc" => "Bar‑formula", "stable_version" => "0.4.0" },
// 14:       },
// 15:       "casks"                => {
// 16:         "foo" => { "desc" => "Foo cask", "version" => "2.0.0" },
// 17:       },
// 18:       "formula_aliases"      => { "foo-alias" => "foo" },
// 19:       "formula_tap_git_head" => "b871900717ccbb3508ca93fa56e128940b9bd371",
// 20:     }
// 21:   end
// 22:   let(:payload) { JSON.generate(parsed) }
// 23:
// 24:   def write_index!
// 25:     target.write("{}")
// 26:     described_class.write!(target, payload:, parsed:, source_stat: target.stat)
// 27:   end
// 28:
// 29:   def load_index
// 30:     described_class.load(target, payload:, source_stat: target.stat)
// 31:   end
// 32:
// 33:   it "serves entries and top-level values from a written index" do
// 34:     write_index!
// 35:     index = load_index
// 36:
// 37:     expect(index).not_to be_nil
// 38:     expect(index.formula_hash("foo")).to eq parsed.dig("formulae", "foo")
// 39:     expect(index.formula_hash("bar")).to eq parsed.dig("formulae", "bar")
// 40:     expect(index.cask_hash("foo")).to eq parsed.dig("casks", "foo")
// 41:     expect(index.formula_hash("missing")).to be_nil
// 42:     expect(index.formula_names).to eq %w[foo bar]
// 43:     expect(index.cask_name?("foo")).to be true
// 44:     expect(index.top_level_value("formula_aliases")).to eq parsed["formula_aliases"]
// 45:     expect(index.top_level_value("formula_tap_git_head")).to eq parsed["formula_tap_git_head"]
// 46:     expect(index.top_level_value("formulae")).to be_nil
// 47:   end
// 48:
// 49:   it "does not load an index whose source envelope changed" do
// 50:     write_index!
// 51:     FileUtils.touch target, mtime: target.stat.mtime + 1
// 52:
// 53:     expect(load_index).to be_nil
// 54:   end
// 55:
// 56:   it "does not load an index built for a different payload" do
// 57:     write_index!
// 58:
// 59:     expect(described_class.load(target, payload: "#{payload} ", source_stat: target.stat)).to be_nil
// 60:   end
// 61:
// 62:   it "raises on lookups whose recorded offsets do not match the payload" do
// 63:     write_index!
// 64:     index_path = described_class.path_for(target)
// 65:     data = JSON.parse(index_path.read)
// 66:     data["formulae"]["foo"] = data["formulae"]["bar"]
// 67:     index_path.write(JSON.generate(data))
// 68:
// 69:     expect { load_index.formula_hash("foo") }.to raise_error(Homebrew::API::PackagesIndex::Invalid)
// 70:   end
// 71:
// 72:   it "raises on lookups remapped to a matching key in another section" do
// 73:     write_index!
// 74:     index_path = described_class.path_for(target)
// 75:     data = JSON.parse(index_path.read)
// 76:     data["formulae"]["foo"] = data["casks"]["foo"]
// 77:     index_path.write(JSON.generate(data))
// 78:
// 79:     expect { load_index.formula_hash("foo") }.to raise_error(Homebrew::API::PackagesIndex::Invalid)
// 80:   end
// 81:
// 82:   it "does not load an index whose top-level spans do not tile the payload" do
// 83:     write_index!
// 84:     index_path = described_class.path_for(target)
// 85:     data = JSON.parse(index_path.read)
// 86:     data["top_level"]["formulae"][1] = data["payload_bytesize"] - data["top_level"]["formulae"][0] - 1
// 87:     index_path.write(JSON.generate(data))
// 88:
// 89:     expect(load_index).to be_nil
// 90:   end
// 91: end
