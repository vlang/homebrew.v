module dev_cmd

import brew_runtime
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-formula-api.rb`.
// The original source is retained below until every stub has a typed V body.

pub const generate_formula_api_json_template = '---\nlayout: formula_json\n---\n{{ content }}\n'

pub struct GenerateFormulaApiFormula {
pub:
	name              string
	pkg_version       string
	hash              map[string]brew_runtime.Value
	serialized_by_tag map[string]map[string]brew_runtime.Value
}

pub struct GenerateFormulaApiOptions {
pub:
	output_directory     string = '.'
	dry_run              bool
	tap_installed        bool = true
	tap_name             string = 'homebrew/core'
	formula_names        []string
	alias_table          map[string]string
	formula_renames      map[string]string
	tap_git_head         string
	tap_migrations       map[string]string
	formulas             map[string]GenerateFormulaApiFormula
	executables_contents string
	executables_download bool = true
	advisory_statuses    map[string]brew_runtime.Value
	advisory_loaded      bool
	advisory_load_error  string
	bottle_tags          []string
}

pub struct GenerateFormulaApiResult {
pub:
	formulae      map[string]map[string]brew_runtime.Value
	warnings      []string
	written_files []string
}

@[heap]
pub struct GenerateFormulaApiInput {
pub:
	options GenerateFormulaApiOptions
}

fn generate_formula_api_path(root string, relative string) string {
	if root == '' || root == '.' {
		return relative
	}
	return os.join_path(root, relative)
}

fn generate_formula_api_remove(path string) {
	if os.is_dir(path) {
		os.rmdir_all(path) or {}
	} else if os.exists(path) {
		os.rm(path) or {}
	}
}

fn generate_formula_api_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

fn generate_formula_api_executables(contents string) map[string][]string {
	mut executables := map[string][]string{}
	for line in contents.split_into_lines() {
		colon := line.index_u8(`:`)
		if colon < 0 {
			continue
		}
		mut name := line[..colon]
		if open := name.last_index('(') {
			if name.ends_with(')') {
				name = name[..open]
			}
		}
		if name == '' || name in executables {
			continue
		}
		executables[name] = if colon + 1 < line.len { line[colon + 1..].fields() } else { [] }
	}
	return executables
}

fn generate_formula_api_pretty_json(value brew_runtime.Value) string {
	return json2.encode(brew_runtime.json_any_from_value(value), prettify: true)
}

pub fn generate_formula_api_html_template(title string) string {
	return "---\ntitle: '${title}'\nlayout: formula\nredirect_from: /formula-linux/${title}\n---\n{{ content }}\n"
}

pub fn run_generate_formula_api(options GenerateFormulaApiOptions) !GenerateFormulaApiResult {
	if !options.tap_installed {
		return error(options.tap_name)
	}

	root := if options.output_directory == '' { '.' } else { options.output_directory }
	mut written_files := []string{}
	if !options.dry_run {
		for directory in ['_data/formula', 'api/formula', 'formula', 'api/internal'] {
			path := generate_formula_api_path(root, directory)
			generate_formula_api_remove(path)
			os.mkdir_all(path)!
		}
		generate_formula_api_remove(generate_formula_api_path(root, '_data/formula_canonical.json'))
	}

	executables_relative_path := 'api/internal/executables.txt'
	executables_path := generate_formula_api_path(root, executables_relative_path)
	if !options.dry_run {
		if !options.executables_download {
			return error('Failed to download ${executables_relative_path}')
		}
		os.write_file(executables_path, options.executables_contents)!
		written_files << executables_relative_path
	}
	executables_contents := os.read_file(executables_path) or { '' }
	executables := generate_formula_api_executables(executables_contents)

	mut warnings := []string{}
	if options.advisory_load_error != '' {
		first_line := options.advisory_load_error.split_into_lines()[0].trim_space()
		warnings << 'Skipping vulnerabilities field: ${first_line}'
	}

	if !options.dry_run {
		path := generate_formula_api_path(root, 'api/formula_tap_migrations.json')
		os.write_file(path, brew_runtime.json_value_to_string(generate_formula_api_string_map_value(options.tap_migrations)))!
		written_files << 'api/formula_tap_migrations.json'
	}

	mut all_formulae := map[string]map[string]brew_runtime.Value{}
	mut formula_definitions := map[string]GenerateFormulaApiFormula{}
	for requested_name in options.formula_names {
		formula := options.formulas[requested_name] or {
			return error("Error while generating data for formula '${requested_name}'.")
		}
		name := formula.name
		mut formula_hash := formula.hash.clone()
		if formula_executables := executables[name] {
			formula_hash['executables'] = brew_runtime.string_array_value(formula_executables)
		}
		if options.advisory_load_error == '' {
			if status := options.advisory_statuses[name] {
				formula_hash['vulnerabilities'] = status
			}
		}
		all_formulae[name] = formula_hash.clone()
		formula_definitions[name] = formula

		if !options.dry_run {
			data_relative_path := '_data/formula/${name.replace('+', '_')}.json'
			api_relative_path := 'api/formula/${name}.json'
			html_relative_path := 'formula/${name}.html'
			os.write_file(generate_formula_api_path(root, data_relative_path), '${generate_formula_api_pretty_json(brew_runtime.map_value(formula_hash))}\n')!
			os.write_file(generate_formula_api_path(root, api_relative_path), generate_formula_api_json_template)!
			os.write_file(generate_formula_api_path(root, html_relative_path), generate_formula_api_html_template(name))!
			written_files << data_relative_path
			written_files << api_relative_path
			written_files << html_relative_path
		}
	}

	mut canonical := options.formula_renames.clone()
	for alias_name, formula_name in options.alias_table {
		canonical[alias_name] = formula_name
	}
	if !options.dry_run {
		canonical_relative_path := '_data/formula_canonical.json'
		os.write_file(generate_formula_api_path(root, canonical_relative_path), '${generate_formula_api_pretty_json(generate_formula_api_string_map_value(canonical))}\n')!
		written_files << canonical_relative_path
	}

	for bottle_tag in options.bottle_tags {
		mut serialized_formulae := map[string]brew_runtime.Value{}
		for name, formula_hash in all_formulae {
			formula := formula_definitions[name] or {
				return error("Error while generating data for formula '${name}'.")
			}
			serialized := (formula.serialized_by_tag[bottle_tag] or { formula_hash }).clone()
			serialized_formulae[name] = brew_runtime.map_value(serialized)
		}
		json_contents := brew_runtime.map_value({
			'formulae':       brew_runtime.map_value(serialized_formulae)
			'aliases':        generate_formula_api_string_map_value(options.alias_table)
			'renames':        generate_formula_api_string_map_value(options.formula_renames)
			'tap_git_head':   brew_runtime.string_value(options.tap_git_head)
			'tap_migrations': generate_formula_api_string_map_value(options.tap_migrations)
		})
		if !options.dry_run {
			relative_path := 'api/internal/formula.${bottle_tag}.json'
			os.write_file(generate_formula_api_path(root, relative_path), brew_runtime.json_value_to_string(json_contents))!
			written_files << relative_path
		}
	}

	return GenerateFormulaApiResult{
		formulae: all_formulae
		warnings: warnings
		written_files: written_files
	}
}

pub fn generate_formula_api_input_boundary(input &GenerateFormulaApiInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::GenerateFormulaApi::Input', '', {
		'generate_formula_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_formula_api_input_from_value(value brew_runtime.Value) &GenerateFormulaApiInput {
	address := value.attributes['generate_formula_api_input_address'] or {
		panic('invalid GenerateFormulaApi input')
	}
	return unsafe { &GenerateFormulaApiInput(voidptr(address.u64())) }
}

fn generate_formula_api_result_value(result GenerateFormulaApiResult) brew_runtime.Value {
	mut formulae := map[string]brew_runtime.Value{}
	for name, hash in result.formulae {
		formulae[name] = brew_runtime.map_value(hash)
	}
	return brew_runtime.map_value({
		'formulae':      brew_runtime.map_value(formulae)
		'warnings':      brew_runtime.string_array_value(result.warnings)
		'written_files': brew_runtime.string_array_value(result.written_files)
	})
}

// Ruby method `run` at line 35.
pub fn ruby_generate_formula_api_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := generate_formula_api_input_from_value(args[0])
	result := run_generate_formula_api(input.options) or {
		error_type := if !input.options.tap_installed {
			'TapUnavailableError'
		} else if err.msg().starts_with('Failed to download') {
			'FatalError'
		} else {
			'Error'
		}
		return brew_runtime.object_value(error_type, err.msg())
	}
	return generate_formula_api_result_value(result)
}

// Ruby method `load_advisory_database` at line 115.
pub fn ruby_generate_formula_api_l115_d2_load_advisory_database(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := generate_formula_api_input_from_value(args[0]).options
	if options.advisory_load_error != '' {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	if options.advisory_loaded {
		return brew_runtime.object_value('Homebrew::Vulns::AdvisoryDatabase', '#<Homebrew::Vulns::AdvisoryDatabase>')
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `html_template(title)` at line 123.
pub fn ruby_generate_formula_api_l123_d3_html_template(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'title is required')
	}
	return brew_runtime.string_value(generate_formula_api_html_template(args[0].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "api"
// 6: require "executables_db"
// 7: require "fileutils"
// 8: require "formula"
// 9: require "vulns/advisory_database"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class GenerateFormulaApi < AbstractCommand
// 14:       FORMULA_JSON_TEMPLATE = <<~EOS
// 15:         ---
// 16:         layout: formula_json
// 17:         ---
// 18:         {{ content }}
// 19:       EOS
// 20:
// 21:       cmd_args do
// 22:         description <<~EOS
// 23:           Generate `homebrew/core` API data files for <#{HOMEBREW_API_WWW}>.
// 24:           The generated files are written to the current directory.
// 25:         EOS
// 26:         switch "-n", "--dry-run",
// 27:                description: "Generate API data without writing it to files."
// 28:
// 29:         named_args :none
// 30:
// 31:         hide_from_man_page!
// 32:       end
// 33:
// 34:       sig { override.void }
// 35:       def run
// 36:         tap = CoreTap.instance
// 37:         raise TapUnavailableError, tap.name unless tap.installed?
// 38:
// 39:         unless args.dry_run?
// 40:           directories = ["_data/formula", "api/formula", "formula", "api/internal"]
// 41:           FileUtils.rm_rf directories + ["_data/formula_canonical.json"]
// 42:           FileUtils.mkdir_p directories
// 43:         end
// 44:
// 45:         executables_path = Pathname("api/internal/executables.txt")
// 46:         # Use the existing executables database as the API generation source.
// 47:         # It is generated from GitHub Packages metadata, not generated API JSON.
// 48:         if !args.dry_run? &&
// 49:            !Homebrew::API.download_executables_file_from_github_packages!(executables_path)
// 50:           odie "Failed to download #{executables_path}"
// 51:         end
// 52:         executables = ExecutablesDB.new(executables_path.to_s).to_hash
// 53:         advisories = load_advisory_database
// 54:
// 55:         Homebrew.with_no_api_env do
// 56:           tap_migrations_json = JSON.dump(tap.tap_migrations)
// 57:           File.write("api/formula_tap_migrations.json", tap_migrations_json) unless args.dry_run?
// 58:
// 59:           Formulary.enable_factory_cache!
// 60:           Formula.generating_hash!
// 61:
// 62:           all_formulae = {}
// 63:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 64:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 65:             tap.formula_names.each do |name|
// 66:               formula = Formulary.factory(name)
// 67:               name = formula.name
// 68:               all_formulae[name] = formula.to_hash_with_variations
// 69:               all_formulae[name]["executables"] = executables[name] if executables.key?(name)
// 70:               if (vulns = advisories&.status_for(name, formula.pkg_version))
// 71:                 all_formulae[name]["vulnerabilities"] = vulns
// 72:               end
// 73:               json = JSON.pretty_generate(all_formulae[name])
// 74:               html_template_name = html_template(name)
// 75:
// 76:               unless args.dry_run?
// 77:                 File.write("_data/formula/#{name.tr("+", "_")}.json", "#{json}\n")
// 78:                 File.write("api/formula/#{name}.json", FORMULA_JSON_TEMPLATE)
// 79:                 File.write("formula/#{name}.html", html_template_name)
// 80:               end
// 81:             rescue
// 82:               onoe "Error while generating data for formula '#{name}'."
// 83:               raise
// 84:             end
// 85:           end
// 86:
// 87:           canonical_json = JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))
// 88:           File.write("_data/formula_canonical.json", "#{canonical_json}\n") unless args.dry_run?
// 89:
// 90:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 91:             formulae = all_formulae.to_h do |name, hash|
// 92:               hash = Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(hash, bottle_tag:)
// 93:                                                                    .serialize(bottle_tag:)
// 94:               [name, hash]
// 95:             end
// 96:
// 97:             json_contents = {
// 98:               formulae:,
// 99:               aliases:        tap.alias_table,
// 100:               renames:        tap.formula_renames,
// 101:               tap_git_head:   tap.git_head,
// 102:               tap_migrations: tap.tap_migrations,
// 103:             }
// 104:
// 105:             File.write("api/internal/formula.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 106:           end
// 107:         end
// 108:       end
// 109:
// 110:       private
// 111:
// 112:       # An advisory-database or network failure must not break the API build;
// 113:       # the `vulnerabilities` field is omitted and the build proceeds.
// 114:       sig { returns(T.nilable(Homebrew::Vulns::AdvisoryDatabase)) }
// 115:       def load_advisory_database
// 116:         Homebrew::Vulns::AdvisoryDatabase.load
// 117:       rescue Homebrew::Vulns::CachedFeed::Error, ErrorDuringExecution => e
// 118:         opoo "Skipping vulnerabilities field: #{e.message.lines.first&.strip}"
// 119:         nil
// 120:       end
// 121:
// 122:       sig { params(title: String).returns(String) }
// 123:       def html_template(title)
// 124:         <<~EOS
// 125:           ---
// 126:           title: '#{title}'
// 127:           layout: formula
// 128:           redirect_from: /formula-linux/#{title}
// 129:           ---
// 130:           {{ content }}
// 131:         EOS
// 132:       end
// 133:     end
// 134:   end
// 135: end
