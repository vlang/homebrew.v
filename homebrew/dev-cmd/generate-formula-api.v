module dev_cmd

import ruby
import os
import x.json2

// Translated from Homebrew/brew `dev-cmd/generate-formula-api.rb`.

pub const generate_formula_api_json_template = '---\nlayout: formula_json\n---\n{{ content }}\n'

pub struct GenerateFormulaApiFormula {
pub:
	name              string
	pkg_version       string
	hash              map[string]ruby.Value
	serialized_by_tag map[string]map[string]ruby.Value
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
	advisory_statuses    map[string]ruby.Value
	advisory_loaded      bool
	advisory_load_error  string
	bottle_tags          []string
}

pub struct GenerateFormulaApiResult {
pub:
	formulae      map[string]map[string]ruby.Value
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

fn generate_formula_api_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
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

fn generate_formula_api_pretty_json(value ruby.Value) string {
	return json2.encode(ruby.json_any_from_value(value), prettify: true)
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
		os.write_file(path, ruby.json_value_to_string(generate_formula_api_string_map_value(options.tap_migrations)))!
		written_files << 'api/formula_tap_migrations.json'
	}

	mut all_formulae := map[string]map[string]ruby.Value{}
	mut formula_definitions := map[string]GenerateFormulaApiFormula{}
	for requested_name in options.formula_names {
		formula := options.formulas[requested_name] or {
			return error("Error while generating data for formula '${requested_name}'.")
		}
		name := formula.name
		mut formula_hash := formula.hash.clone()
		if formula_executables := executables[name] {
			formula_hash['executables'] = ruby.string_array_value(formula_executables)
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
			os.write_file(generate_formula_api_path(root, data_relative_path), '${generate_formula_api_pretty_json(ruby.map_value(formula_hash))}\n')!
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
		mut serialized_formulae := map[string]ruby.Value{}
		for name, formula_hash in all_formulae {
			formula := formula_definitions[name] or {
				return error("Error while generating data for formula '${name}'.")
			}
			serialized := (formula.serialized_by_tag[bottle_tag] or { formula_hash }).clone()
			serialized_formulae[name] = ruby.map_value(serialized)
		}
		json_contents := ruby.map_value({
			'formulae':       ruby.map_value(serialized_formulae)
			'aliases':        generate_formula_api_string_map_value(options.alias_table)
			'renames':        generate_formula_api_string_map_value(options.formula_renames)
			'tap_git_head':   ruby.string_value(options.tap_git_head)
			'tap_migrations': generate_formula_api_string_map_value(options.tap_migrations)
		})
		if !options.dry_run {
			relative_path := 'api/internal/formula.${bottle_tag}.json'
			os.write_file(generate_formula_api_path(root, relative_path), ruby.json_value_to_string(json_contents))!
			written_files << relative_path
		}
	}

	return GenerateFormulaApiResult{
		formulae: all_formulae
		warnings: warnings
		written_files: written_files
	}
}

pub fn generate_formula_api_input_boundary(input &GenerateFormulaApiInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateFormulaApi::Input', '', {
		'generate_formula_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_formula_api_input_from_value(value ruby.Value) &GenerateFormulaApiInput {
	address := value.attributes['generate_formula_api_input_address'] or {
		panic('invalid GenerateFormulaApi input')
	}
	return unsafe { &GenerateFormulaApiInput(voidptr(address.u64())) }
}

fn generate_formula_api_result_value(result GenerateFormulaApiResult) ruby.Value {
	mut formulae := map[string]ruby.Value{}
	for name, hash in result.formulae {
		formulae[name] = ruby.map_value(hash)
	}
	return ruby.map_value({
		'formulae':      ruby.map_value(formulae)
		'warnings':      ruby.string_array_value(result.warnings)
		'written_files': ruby.string_array_value(result.written_files)
	})
}
