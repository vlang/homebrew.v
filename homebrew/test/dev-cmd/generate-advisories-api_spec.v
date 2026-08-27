module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/generate-advisories-api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `record(id, formula, source: nil, range_state: nil, schema_version: "1.7.3")` at line 10.
pub fn ruby_generate_advisories_api_spec_l10_d1_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('record', ...args)
}

// Ruby method `write_records(directory, records)` at line 18.
pub fn ruby_generate_advisories_api_spec_l18_d2_write_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_records', ...args)
}

// Ruby it `it "writes grouped, filtered, byte-stable advisory data" do` at line 26.
pub fn ruby_generate_advisories_api_spec_l26_d3_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "fails when the advisories directory is missing" do` at line 62.
pub fn ruby_generate_advisories_api_spec_l62_d4_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "fails on an empty advisories directory rather than writing an empty index" do` at line 72.
pub fn ruby_generate_advisories_api_spec_l72_d5_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "prefixes parse errors with the failing record path" do` at line 84.
pub fn ruby_generate_advisories_api_spec_l84_d6_prefixes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prefixes', ...args)
}

// Ruby it `it "fails on mixed schema versions" do` at line 97.
pub fn ruby_generate_advisories_api_spec_l97_d7_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-advisories-api"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateAdvisoriesApi do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   def record(id, formula, source: nil, range_state: nil, schema_version: "1.7.3")
// 11:     affected = { "package" => { "ecosystem" => "Homebrew", "name" => formula } }
// 12:     affected["ecosystem_specific"] = { "range_state" => range_state } if range_state
// 13:     record = { "schema_version" => schema_version, "id" => id, "affected" => [affected] }
// 14:     record["database_specific"] = { "source" => source } if source
// 15:     record
// 16:   end
// 17:
// 18:   def write_records(directory, records)
// 19:     advisories = directory/"advisories"
// 20:     advisories.mkpath
// 21:     records.each do |filename, body|
// 22:       (advisories/filename).write(JSON.generate(body))
// 23:     end
// 24:   end
// 25:
// 26:   it "writes grouped, filtered, byte-stable advisory data" do
// 27:     mktmpdir do |database|
// 28:       write_records(database, {
// 29:         "z.json" => record("BREW-foo-CVE-2", "foo", source: "matched", range_state: "fixed"),
// 30:         "y.json" => record("BREW-foo-CVE-1", "foo", source: "generated"),
// 31:         "x.json" => record("BREW-foo-CVE-3", "foo", source: "matched"),
// 32:         "w.json" => record("BREW-bar-CVE-1", "bar", source: "matched", range_state: "affected"),
// 33:         "v.json" => record("BREW-baz-CVE-1", "baz", source: "matched"),
// 34:       })
// 35:
// 36:       mktmpdir do |output|
// 37:         output.cd { described_class.new([database.to_s]).run }
// 38:         first_output = (output/"api/advisories.json").read
// 39:         output.cd { described_class.new([database.to_s]).run }
// 40:         second_output = (output/"api/advisories.json").read
// 41:
// 42:         expected = {
// 43:           "meta"       => {
// 44:             "count"                => 3,
// 45:             "skipped_uncomparable" => 2,
// 46:             "schema_version"       => "1.7.3",
// 47:           },
// 48:           "advisories" => {
// 49:             "bar" => [record("BREW-bar-CVE-1", "bar", source: "matched", range_state: "affected")],
// 50:             "foo" => [
// 51:               record("BREW-foo-CVE-1", "foo", source: "generated"),
// 52:               record("BREW-foo-CVE-2", "foo", source: "matched", range_state: "fixed"),
// 53:             ],
// 54:           },
// 55:         }
// 56:         expected_output = "#{JSON.generate(expected)}\n"
// 57:         expect([first_output, second_output]).to eq([expected_output, expected_output])
// 58:       end
// 59:     end
// 60:   end
// 61:
// 62:   it "fails when the advisories directory is missing" do
// 63:     mktmpdir do |database|
// 64:       mktmpdir do |output|
// 65:         expect do
// 66:           output.cd { described_class.new([database.to_s]).run }
// 67:         end.to raise_error(/is not a directory/)
// 68:       end
// 69:     end
// 70:   end
// 71:
// 72:   it "fails on an empty advisories directory rather than writing an empty index" do
// 73:     mktmpdir do |database|
// 74:       (database/"advisories").mkpath
// 75:
// 76:       mktmpdir do |output|
// 77:         expect do
// 78:           output.cd { described_class.new([database.to_s]).run }
// 79:         end.to raise_error(/no advisory records found/)
// 80:       end
// 81:     end
// 82:   end
// 83:
// 84:   it "prefixes parse errors with the failing record path" do
// 85:     mktmpdir do |database|
// 86:       write_records(database, { "good.json" => record("BREW-foo-CVE-1", "foo") })
// 87:       (database/"advisories/bad.json").write("{")
// 88:
// 89:       mktmpdir do |output|
// 90:         expect do
// 91:           output.cd { described_class.new([database.to_s]).run }
// 92:         end.to raise_error(%r{advisories/bad\.json})
// 93:       end
// 94:     end
// 95:   end
// 96:
// 97:   it "fails on mixed schema versions" do
// 98:     mktmpdir do |database|
// 99:       write_records(database, {
// 100:         "a.json" => record("a", "foo", schema_version: "1.7.3"),
// 101:         "b.json" => record("b", "foo", schema_version: "1.8.0"),
// 102:       })
// 103:
// 104:       mktmpdir do |output|
// 105:         expect do
// 106:           output.cd { described_class.new([database.to_s]).run }
// 107:         end.to raise_error(/mixed schema_version.*1\.7\.3.*1\.8\.0/)
// 108:       end
// 109:     end
// 110:   end
// 111: end
