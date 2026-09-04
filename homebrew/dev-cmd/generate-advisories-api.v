module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/generate-advisories-api.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct GenerateAdvisoriesApiOptions {
pub:
	repository       string
	output_directory string = '.'
}

pub struct GenerateAdvisoriesApiResult {
pub:
	data        map[string]ruby.Value
	output_path string
	contents    string
}

@[heap]
pub struct GenerateAdvisoriesApiInput {
pub:
	options GenerateAdvisoriesApiOptions
}

fn generate_advisories_api_path(root string, relative string) string {
	if root == '' || root == '.' {
		return relative
	}
	return os.join_path(root, relative)
}

fn generate_advisories_api_truthy(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'Bool' { value.bool_data }
		else { true }
	}
}

fn generate_advisories_api_record_id(record map[string]ruby.Value) string {
	return if id := record['id'] { id.as_string() } else { '' }
}

fn generate_advisories_api_sort_records(mut records []map[string]ruby.Value) {
	for index in 1 .. records.len {
		mut cursor := index
		for cursor > 0
			&& generate_advisories_api_record_id(records[cursor]) < generate_advisories_api_record_id(records[cursor - 1]) {
			previous := records[cursor - 1].clone()
			records[cursor - 1] = records[cursor].clone()
			records[cursor] = previous.clone()
			cursor--
		}
	}
}

fn generate_advisories_api_formula_name(record map[string]ruby.Value, path string) !string {
	affected_value := record['affected'] or {
		return error('${path}: missing affected[0].package.name')
	}
	affected := affected_value.as_array() or {
		return error('${path}: missing affected[0].package.name')
	}
	if affected.len == 0 {
		return error('${path}: missing affected[0].package.name')
	}
	affected_entry := affected[0].as_map() or {
		return error('${path}: missing affected[0].package.name')
	}
	package_value := affected_entry['package'] or {
		return error('${path}: missing affected[0].package.name')
	}
	package := package_value.as_map() or {
		return error('${path}: missing affected[0].package.name')
	}
	name := package['name'] or { return error('${path}: missing affected[0].package.name') }
	if name.type_name != 'String' {
		return error('${path}: missing affected[0].package.name')
	}
	return name.as_string()
}

pub fn generate_advisories_api_parse(path string) !map[string]ruby.Value {
	contents := os.read_file(path) or { return error('${path}: ${err.msg()}') }
	value := ruby.parse_json_value(contents) or { return error('${path}: ${err.msg()}') }
	return value.as_map() or { return error('${path}: ${err.msg()}') }
}

pub fn generate_advisories_api_actionable(record map[string]ruby.Value) bool {
	mut source := ''
	if database_specific_value := record['database_specific'] {
		if database_specific := database_specific_value.as_map() {
			if source_value := database_specific['source'] {
				source = source_value.as_string()
			}
		}
	}
	if source != 'matched' {
		return true
	}

	affected_value := record['affected'] or { return false }
	mut affected := []ruby.Value{}
	if affected_value.type_name == 'Array' {
		affected = affected_value.as_array() or { return false }
	} else if affected_value.type_name == 'Hash' {
		affected = [affected_value]
	}
	for entry_value in affected {
		entry := entry_value.as_map() or { continue }
		ecosystem_value := entry['ecosystem_specific'] or { continue }
		ecosystem := ecosystem_value.as_map() or { continue }
		if range_state := ecosystem['range_state'] {
			if generate_advisories_api_truthy(range_state) {
				return true
			}
		}
	}
	return false
}

pub fn generate_advisories_api_build(directory string) !map[string]ruby.Value {
	if !os.is_dir(directory) {
		return error('${directory} is not a directory')
	}
	mut paths := os.ls(directory)!.filter(it.ends_with('.json')).map(os.join_path(directory, it))
	paths.sort()
	if paths.len == 0 {
		return error('no advisory records found in ${directory}')
	}

	mut by_formula := map[string][]map[string]ruby.Value{}
	mut schema_versions := []string{}
	mut skipped_uncomparable := 0
	for path in paths {
		record := generate_advisories_api_parse(path)!
		formula_name := generate_advisories_api_formula_name(record, path)!
		if schema_version := record['schema_version'] {
			if schema_version.type_name != 'NilClass' {
				version := schema_version.as_string()
				if version !in schema_versions {
					schema_versions << version
				}
			}
		}
		if generate_advisories_api_actionable(record) {
			by_formula[formula_name] << record
		} else {
			skipped_uncomparable++
		}
	}
	if schema_versions.len > 1 {
		mut sorted_versions := schema_versions.clone()
		sorted_versions.sort()
		return error('mixed schema_version across advisories: ${sorted_versions}')
	}

	mut formula_names := by_formula.keys()
	formula_names.sort()
	mut advisories := map[string]ruby.Value{}
	mut count := 0
	for formula_name in formula_names {
		mut records := by_formula[formula_name].clone()
		generate_advisories_api_sort_records(mut records)
		count += records.len
		advisories[formula_name] = ruby.array_value(records.map(ruby.map_value(it)))
	}
	schema_version := if schema_versions.len == 0 {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(schema_versions[0])
	}
	return {
		'meta':       ruby.map_value({
			'count':                ruby.int_value(count)
			'skipped_uncomparable': ruby.int_value(skipped_uncomparable)
			'schema_version':       schema_version
		})
		'advisories': ruby.map_value(advisories)
	}
}

pub fn run_generate_advisories_api(options GenerateAdvisoriesApiOptions) !GenerateAdvisoriesApiResult {
	data := generate_advisories_api_build(os.join_path(options.repository, 'advisories'))!
	api_directory := generate_advisories_api_path(options.output_directory, 'api')
	os.mkdir_all(api_directory)!
	output_path := os.join_path(api_directory, 'advisories.json')
	contents := '${ruby.json_value_to_string(ruby.map_value(data))}\n'
	os.write_file(output_path, contents)!
	return GenerateAdvisoriesApiResult{
		data: data
		output_path: output_path
		contents: contents
	}
}

pub fn generate_advisories_api_input_boundary(input &GenerateAdvisoriesApiInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateAdvisoriesApi::Input', '', {
		'generate_advisories_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_advisories_api_input_from_value(value ruby.Value) !&GenerateAdvisoriesApiInput {
	address := value.attributes['generate_advisories_api_input_address'] or {
		return error('invalid GenerateAdvisoriesApi input')
	}
	return unsafe { &GenerateAdvisoriesApiInput(voidptr(address.u64())) }
}

fn generate_advisories_api_result_value(result GenerateAdvisoriesApiResult) ruby.Value {
	return ruby.map_value({
		'data':        ruby.map_value(result.data)
		'output_path': ruby.string_value(result.output_path)
		'contents':    ruby.string_value(result.contents)
	})
}

// Ruby method `run` at line 24.
pub fn ruby_generate_advisories_api_l24_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := generate_advisories_api_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := run_generate_advisories_api(input.options) or {
		return ruby.object_value('Error', err.msg())
	}
	return generate_advisories_api_result_value(result)
}

// Ruby method `build(directory)` at line 35.
pub fn ruby_generate_advisories_api_l35_d2_build(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'directory is required')
	}
	result := generate_advisories_api_build(args[0].as_string()) or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.map_value(result)
}

// Ruby method `parse(path)` at line 77.
pub fn ruby_generate_advisories_api_l77_d3_parse(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	result := generate_advisories_api_parse(args[0].as_string()) or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.map_value(result)
}

// Ruby method `actionable?(record)` at line 84.
pub fn ruby_generate_advisories_api_l84_d4_actionable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'record is required')
	}
	record := args[0].as_map() or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.bool_value(generate_advisories_api_actionable(record))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "json"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class GenerateAdvisoriesApi < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Generate advisory API data for <#{HOMEBREW_API_WWW}> from a checkout of
// 14:           <https://github.com/Homebrew/advisory-database>.
// 15:           The generated file is written to the current directory.
// 16:         EOS
// 17:
// 18:         named_args :directory, number: 1
// 19:
// 20:         hide_from_man_page!
// 21:       end
// 22:
// 23:       sig { override.void }
// 24:       def run
// 25:         repository = Pathname(T.must(args.named.first))
// 26:         result = build(repository/"advisories")
// 27:         FileUtils.mkdir_p "api"
// 28:         File.write("api/advisories.json", "#{JSON.generate(result)}\n")
// 29:       end
// 30:
// 31:       private
// 32:
// 33:       # Kept in step with AdvisoryIndex in Homebrew/advisory-database.
// 34:       sig { params(directory: Pathname).returns(T::Hash[String, T.untyped]) }
// 35:       def build(directory)
// 36:         raise "#{directory} is not a directory" unless directory.directory?
// 37:
// 38:         paths = directory.glob("*.json").sort
// 39:         # An empty result here means a bad checkout or path, not an empty
// 40:         # corpus; publishing it would wipe the client view of every advisory.
// 41:         raise "no advisory records found in #{directory}" if paths.empty?
// 42:
// 43:         by_formula = T.let({}, T::Hash[String, T::Array[T::Hash[String, T.untyped]]])
// 44:         schema_versions = T.let([], T::Array[T.nilable(String)])
// 45:         skipped_uncomparable = 0
// 46:
// 47:         paths.each do |path|
// 48:           record = parse(path)
// 49:           formula_name = record.dig("affected", 0, "package", "name")
// 50:           raise "#{path}: missing affected[0].package.name" unless formula_name.is_a?(String)
// 51:
// 52:           schema_versions << record["schema_version"]
// 53:           if actionable?(record)
// 54:             (by_formula[formula_name] ||= []) << record
// 55:           else
// 56:             skipped_uncomparable += 1
// 57:           end
// 58:         end
// 59:
// 60:         versions = schema_versions.compact.uniq
// 61:         if versions.size > 1
// 62:           raise "mixed schema_version across advisories: #{versions.sort.inspect}"
// 63:         end
// 64:
// 65:         {
// 66:           "meta"       => {
// 67:             "count"                => by_formula.each_value.sum(&:size),
// 68:             "skipped_uncomparable" => skipped_uncomparable,
// 69:             "schema_version"       => versions.first,
// 70:           },
// 71:           "advisories" => by_formula.transform_values { |records| records.sort_by { |record| record.fetch("id") } }
// 72:                                     .sort.to_h,
// 73:         }
// 74:       end
// 75:
// 76:       sig { params(path: Pathname).returns(T::Hash[String, T.untyped]) }
// 77:       def parse(path)
// 78:         JSON.parse(path.read)
// 79:       rescue JSON::ParserError => e
// 80:         raise "#{path}: #{e.message}"
// 81:       end
// 82:
// 83:       sig { params(record: T::Hash[String, T.untyped]).returns(T::Boolean) }
// 84:       def actionable?(record)
// 85:         database_specific = record["database_specific"] || {}
// 86:         return true if database_specific["source"] != "matched"
// 87:
// 88:         Array(record["affected"]).any? do |affected|
// 89:           affected.dig("ecosystem_specific", "range_state")
// 90:         end
// 91:       end
// 92:     end
// 93:   end
// 94: end
