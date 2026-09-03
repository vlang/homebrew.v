module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `test/dev-cmd/generate-advisories-api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub fn generate_advisories_api_spec_record(id string, formula string, source string,
	range_state string, schema_version string) map[string]brew_runtime.Value {
	mut affected := {
		'package': brew_runtime.map_value({
			'ecosystem': brew_runtime.string_value('Homebrew')
			'name':      brew_runtime.string_value(formula)
		})
	}
	if range_state != '' {
		affected['ecosystem_specific'] = brew_runtime.map_value({
			'range_state': brew_runtime.string_value(range_state)
		})
	}
	mut record := {
		'schema_version': brew_runtime.string_value(schema_version)
		'id':             brew_runtime.string_value(id)
		'affected':       brew_runtime.array_value([brew_runtime.map_value(affected)])
	}
	if source != '' {
		record['database_specific'] = brew_runtime.map_value({
			'source': brew_runtime.string_value(source)
		})
	}
	return record
}

pub fn generate_advisories_api_spec_write_records(directory string,
	records map[string]brew_runtime.Value) !bool {
	advisories := os.join_path(directory, 'advisories')
	os.mkdir_all(advisories)!
	for filename, body in records {
		os.write_file(os.join_path(advisories, filename), brew_runtime.json_value_to_string(body))!
	}
	return true
}

fn generate_advisories_api_spec_directory(root string, name string) string {
	return os.join_path(root, name)
}

pub fn generate_advisories_api_spec_writes(root string) !bool {
	database := generate_advisories_api_spec_directory(root, 'writes-database')
	output := generate_advisories_api_spec_directory(root, 'writes-output')
	os.mkdir_all(output)!
	generate_advisories_api_spec_write_records(database, {
		'z.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-2', 'foo', 'matched', 'fixed', '1.7.3'))
		'y.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-1', 'foo', 'generated', '', '1.7.3'))
		'x.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-3', 'foo', 'matched', '', '1.7.3'))
		'w.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-bar-CVE-1', 'bar', 'matched', 'affected', '1.7.3'))
		'v.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-baz-CVE-1', 'baz', 'matched', '', '1.7.3'))
	})!
	options := GenerateAdvisoriesApiOptions{
		repository: database
		output_directory: output
	}
	first := run_generate_advisories_api(options)!
	first_output := os.read_file(first.output_path)!
	second := run_generate_advisories_api(options)!
	second_output := os.read_file(second.output_path)!
	expected := brew_runtime.map_value({
		'meta':       brew_runtime.map_value({
			'count':                brew_runtime.int_value(3)
			'skipped_uncomparable': brew_runtime.int_value(2)
			'schema_version':       brew_runtime.string_value('1.7.3')
		})
		'advisories': brew_runtime.map_value({
			'bar': brew_runtime.array_value([
				brew_runtime.map_value(generate_advisories_api_spec_record('BREW-bar-CVE-1', 'bar', 'matched', 'affected', '1.7.3')),
			])
			'foo': brew_runtime.array_value([
				brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-1', 'foo', 'generated', '', '1.7.3')),
				brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-2', 'foo', 'matched', 'fixed', '1.7.3')),
			])
		})
	})
	expected_output := '${brew_runtime.json_value_to_string(expected)}\n'
	return first_output == expected_output && second_output == expected_output
}

pub fn generate_advisories_api_spec_missing_directory(root string) !bool {
	database := generate_advisories_api_spec_directory(root, 'missing-database')
	output := generate_advisories_api_spec_directory(root, 'missing-output')
	os.mkdir_all(database)!
	os.mkdir_all(output)!
	run_generate_advisories_api(GenerateAdvisoriesApiOptions{
		repository: database
		output_directory: output
	}) or { return err.msg().contains('is not a directory') }
	return false
}

pub fn generate_advisories_api_spec_empty_directory(root string) !bool {
	database := generate_advisories_api_spec_directory(root, 'empty-database')
	output := generate_advisories_api_spec_directory(root, 'empty-output')
	os.mkdir_all(os.join_path(database, 'advisories'))!
	os.mkdir_all(output)!
	run_generate_advisories_api(GenerateAdvisoriesApiOptions{
		repository: database
		output_directory: output
	}) or { return err.msg().contains('no advisory records found') }
	return false
}

pub fn generate_advisories_api_spec_parse_error(root string) !bool {
	database := generate_advisories_api_spec_directory(root, 'parse-database')
	output := generate_advisories_api_spec_directory(root, 'parse-output')
	os.mkdir_all(output)!
	generate_advisories_api_spec_write_records(database, {
		'good.json': brew_runtime.map_value(generate_advisories_api_spec_record('BREW-foo-CVE-1', 'foo', '', '', '1.7.3'))
	})!
	bad_path := os.join_path(database, 'advisories', 'bad.json')
	os.write_file(bad_path, '{')!
	run_generate_advisories_api(GenerateAdvisoriesApiOptions{
		repository: database
		output_directory: output
	}) or {
		return err.msg().contains(os.join_path('advisories', 'bad.json'))
	}
	return false
}

pub fn generate_advisories_api_spec_mixed_versions(root string) !bool {
	database := generate_advisories_api_spec_directory(root, 'mixed-database')
	output := generate_advisories_api_spec_directory(root, 'mixed-output')
	os.mkdir_all(output)!
	generate_advisories_api_spec_write_records(database, {
		'a.json': brew_runtime.map_value(generate_advisories_api_spec_record('a', 'foo', '', '', '1.7.3'))
		'b.json': brew_runtime.map_value(generate_advisories_api_spec_record('b', 'foo', '', '', '1.8.0'))
	})!
	run_generate_advisories_api(GenerateAdvisoriesApiOptions{
		repository: database
		output_directory: output
	}) or {
		return err.msg().contains('mixed schema_version') && err.msg().contains('1.7.3')
			&& err.msg().contains('1.8.0')
	}
	return false
}

// Ruby method `record(id, formula, source: nil, range_state: nil, schema_version: "1.7.3")` at line 10.
pub fn ruby_generate_advisories_api_spec_l10_d1_record(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'id and formula are required')
	}
	source := if args.len > 2 { args[2].as_string() } else { '' }
	range_state := if args.len > 3 { args[3].as_string() } else { '' }
	schema_version := if args.len > 4 { args[4].as_string() } else { '1.7.3' }
	return brew_runtime.map_value(generate_advisories_api_spec_record(args[0].as_string(), args[1].as_string(), source, range_state, schema_version))
}

// Ruby method `write_records(directory, records)` at line 18.
pub fn ruby_generate_advisories_api_spec_l18_d2_write_records(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'directory and records are required')
	}
	records := args[1].as_map() or { return brew_runtime.object_value('TypeError', err.msg()) }
	generate_advisories_api_spec_write_records(args[0].as_string(), records) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.map_value(records)
}

// Ruby it `it "writes grouped, filtered, byte-stable advisory data" do` at line 26.
pub fn ruby_generate_advisories_api_spec_l26_d3_writes(root string) !bool {
	return generate_advisories_api_spec_writes(root)
}

// Ruby it `it "fails when the advisories directory is missing" do` at line 62.
pub fn ruby_generate_advisories_api_spec_l62_d4_fails(root string) !bool {
	return generate_advisories_api_spec_missing_directory(root)
}

// Ruby it `it "fails on an empty advisories directory rather than writing an empty index" do` at line 72.
pub fn ruby_generate_advisories_api_spec_l72_d5_fails(root string) !bool {
	return generate_advisories_api_spec_empty_directory(root)
}

// Ruby it `it "prefixes parse errors with the failing record path" do` at line 84.
pub fn ruby_generate_advisories_api_spec_l84_d6_prefixes(root string) !bool {
	return generate_advisories_api_spec_parse_error(root)
}

// Ruby it `it "fails on mixed schema versions" do` at line 97.
pub fn ruby_generate_advisories_api_spec_l97_d7_fails(root string) !bool {
	return generate_advisories_api_spec_mixed_versions(root)
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
