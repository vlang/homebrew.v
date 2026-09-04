module dev_cmd

import ruby
import os
import time

// Translated from Homebrew/brew `dev-cmd/generate-internal-api.rb`.

pub struct GenerateInternalApiFormula {
pub:
	name              string
	hash              map[string]ruby.Value
	serialized_by_tag map[string]map[string]ruby.Value
}

pub struct GenerateInternalApiCask {
pub:
	token             string
	hash              map[string]ruby.Value
	serialized_by_tag map[string]map[string]ruby.Value
}

pub struct GenerateInternalApiOptions {
pub:
	output_directory     string = '.'
	dry_run              bool
	core_tap_installed   bool = true
	core_tap_name        string = 'homebrew/core'
	cask_tap_installed   bool = true
	cask_tap_name        string = 'homebrew/cask'
	formula_names        []string
	cask_files           []string
	formulas             map[string]GenerateInternalApiFormula
	casks                map[string]GenerateInternalApiCask
	formula_aliases      map[string]string
	formula_renames      map[string]string
	cask_renames         map[string]string
	formula_tap_git_head string
	cask_tap_git_head    string
	formula_migrations   map[string]string
	cask_migrations      map[string]string
	executables_contents string
	executables_download bool = true
	bottle_tags          []string
	homebrew_version     string
	generated_at         i64
}

pub struct GenerateInternalApiResult {
pub:
	formulae      map[string]map[string]ruby.Value
	casks         map[string]map[string]ruby.Value
	packages      map[string]ruby.Value
	written_files []string
}

@[heap]
pub struct GenerateInternalApiInput {
pub:
	options GenerateInternalApiOptions
}

fn generate_internal_api_path(root string, relative string) string {
	if root == '' || root == '.' {
		return relative
	}
	return os.join_path(root, relative)
}

fn generate_internal_api_remove(path string) {
	if os.is_dir(path) {
		os.rmdir_all(path) or {}
	} else if os.exists(path) {
		os.rm(path) or {}
	}
}

fn generate_internal_api_string_map(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn generate_internal_api_executables(contents string) map[string][]string {
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

fn generate_internal_api_stem(path string) string {
	name := os.file_name(path)
	dot := name.last_index('.') or { return name }
	return name[..dot]
}

pub fn run_generate_internal_api(options GenerateInternalApiOptions) !GenerateInternalApiResult {
	if !options.core_tap_installed {
		return error(options.core_tap_name)
	}
	if !options.cask_tap_installed {
		return error(options.cask_tap_name)
	}

	root := if options.output_directory == '' { '.' } else { options.output_directory }
	internal_directory := generate_internal_api_path(root, 'api/internal')
	if !options.dry_run {
		generate_internal_api_remove(internal_directory)
		os.mkdir_all(internal_directory)!
	}

	executables_relative_path := 'api/internal/executables.txt'
	executables_path := generate_internal_api_path(root, executables_relative_path)
	mut written_files := []string{}
	if !options.dry_run {
		if !options.executables_download {
			return error('Failed to download ${executables_relative_path}')
		}
		os.write_file(executables_path, options.executables_contents)!
		written_files << executables_relative_path
	}
	executables_contents := os.read_file(executables_path) or { '' }
	executables := generate_internal_api_executables(executables_contents)

	mut all_formulae := map[string]map[string]ruby.Value{}
	mut formula_definitions := map[string]GenerateInternalApiFormula{}
	for requested_name in options.formula_names {
		formula := options.formulas[requested_name] or {
			return error("Error while generating data for formula '${requested_name}'.")
		}
		name := formula.name
		mut hash := formula.hash.clone()
		if formula_executables := executables[name] {
			hash['executables'] = ruby.string_array_value(formula_executables)
		}
		all_formulae[name] = hash.clone()
		formula_definitions[name] = formula
	}

	mut all_casks := map[string]map[string]ruby.Value{}
	mut cask_definitions := map[string]GenerateInternalApiCask{}
	for path in options.cask_files {
		cask := options.casks[path] or {
			return error("Error while generating data for cask '${generate_internal_api_stem(path)}'.")
		}
		all_casks[cask.token] = cask.hash.clone()
		cask_definitions[cask.token] = cask
	}

	mut packages := map[string]ruby.Value{}
	for bottle_tag in options.bottle_tags {
		generated_at := if options.generated_at > 0 {
			options.generated_at
		} else {
			time.now().unix()
		}
		mut formulae := map[string]ruby.Value{}
		for name, hash in all_formulae {
			formula := formula_definitions[name] or {
				return error("Error while generating data for formula '${name}'.")
			}
			serialized := (formula.serialized_by_tag[bottle_tag] or { hash }).clone()
			formulae[name] = ruby.map_value(serialized)
		}

		mut casks := map[string]ruby.Value{}
		for token, hash in all_casks {
			cask := cask_definitions[token] or {
				return error("Error while generating data for cask '${token}'.")
			}
			serialized := (cask.serialized_by_tag[bottle_tag] or { hash }).clone()
			casks[token] = ruby.map_value(serialized)
		}

		json_contents := ruby.map_value({
			'metadata':               ruby.map_value({
				'homebrew_version': ruby.string_value(options.homebrew_version)
				'bottle_tag':       ruby.string_value(bottle_tag)
				'generated_at':     ruby.int_value(generated_at)
			})
			'formulae':               ruby.map_value(formulae)
			'casks':                  ruby.map_value(casks)
			'formula_aliases':        generate_internal_api_string_map(options.formula_aliases)
			'formula_renames':        generate_internal_api_string_map(options.formula_renames)
			'cask_renames':           generate_internal_api_string_map(options.cask_renames)
			'formula_tap_git_head':   ruby.string_value(options.formula_tap_git_head)
			'cask_tap_git_head':      ruby.string_value(options.cask_tap_git_head)
			'formula_tap_migrations': generate_internal_api_string_map(options.formula_migrations)
			'cask_tap_migrations':    generate_internal_api_string_map(options.cask_migrations)
		})
		packages[bottle_tag] = json_contents
		if !options.dry_run {
			relative_path := 'api/internal/packages.${bottle_tag}.json'
			os.write_file(generate_internal_api_path(root, relative_path), ruby.json_value_to_string(json_contents))!
			written_files << relative_path
		}
	}

	return GenerateInternalApiResult{
		formulae: all_formulae
		casks: all_casks
		packages: packages
		written_files: written_files
	}
}

pub fn generate_internal_api_input_boundary(input &GenerateInternalApiInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::GenerateInternalApi::Input', '', {
		'generate_internal_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_internal_api_input_from_value(value ruby.Value) &GenerateInternalApiInput {
	address := value.attributes['generate_internal_api_input_address'] or {
		panic('invalid GenerateInternalApi input')
	}
	return unsafe { &GenerateInternalApiInput(voidptr(address.u64())) }
}

fn generate_internal_api_result_value(result GenerateInternalApiResult) ruby.Value {
	mut formulae := map[string]ruby.Value{}
	for name, hash in result.formulae {
		formulae[name] = ruby.map_value(hash)
	}
	mut casks := map[string]ruby.Value{}
	for token, hash in result.casks {
		casks[token] = ruby.map_value(hash)
	}
	return ruby.map_value({
		'formulae':      ruby.map_value(formulae)
		'casks':         ruby.map_value(casks)
		'packages':      ruby.map_value(result.packages)
		'written_files': ruby.string_array_value(result.written_files)
	})
}
