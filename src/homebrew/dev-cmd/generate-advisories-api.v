module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-advisories-api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 24.
pub fn ruby_generate_advisories_api_l24_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `build(directory)` at line 35.
pub fn ruby_generate_advisories_api_l35_d2_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build', ...args)
}

// Ruby method `parse(path)` at line 77.
pub fn ruby_generate_advisories_api_l77_d3_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse', ...args)
}

// Ruby method `actionable?(record)` at line 84.
pub fn ruby_generate_advisories_api_l84_d4_actionable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('actionable?', ...args)
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
