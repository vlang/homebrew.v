module dev_cmd

import brew_runtime
import os
import time

// Translated from Homebrew/brew `dev-cmd/generate-internal-api.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct GenerateInternalApiFormula {
pub:
	name              string
	hash              map[string]brew_runtime.Value
	serialized_by_tag map[string]map[string]brew_runtime.Value
}

pub struct GenerateInternalApiCask {
pub:
	token             string
	hash              map[string]brew_runtime.Value
	serialized_by_tag map[string]map[string]brew_runtime.Value
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
	formulae      map[string]map[string]brew_runtime.Value
	casks         map[string]map[string]brew_runtime.Value
	packages      map[string]brew_runtime.Value
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

fn generate_internal_api_string_map(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
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

	mut all_formulae := map[string]map[string]brew_runtime.Value{}
	mut formula_definitions := map[string]GenerateInternalApiFormula{}
	for requested_name in options.formula_names {
		formula := options.formulas[requested_name] or {
			return error("Error while generating data for formula '${requested_name}'.")
		}
		name := formula.name
		mut hash := formula.hash.clone()
		if formula_executables := executables[name] {
			hash['executables'] = brew_runtime.string_array_value(formula_executables)
		}
		all_formulae[name] = hash.clone()
		formula_definitions[name] = formula
	}

	mut all_casks := map[string]map[string]brew_runtime.Value{}
	mut cask_definitions := map[string]GenerateInternalApiCask{}
	for path in options.cask_files {
		cask := options.casks[path] or {
			return error("Error while generating data for cask '${generate_internal_api_stem(path)}'.")
		}
		all_casks[cask.token] = cask.hash.clone()
		cask_definitions[cask.token] = cask
	}

	mut packages := map[string]brew_runtime.Value{}
	for bottle_tag in options.bottle_tags {
		generated_at := if options.generated_at > 0 {
			options.generated_at
		} else {
			time.now().unix()
		}
		mut formulae := map[string]brew_runtime.Value{}
		for name, hash in all_formulae {
			formula := formula_definitions[name] or {
				return error("Error while generating data for formula '${name}'.")
			}
			serialized := (formula.serialized_by_tag[bottle_tag] or { hash }).clone()
			formulae[name] = brew_runtime.map_value(serialized)
		}

		mut casks := map[string]brew_runtime.Value{}
		for token, hash in all_casks {
			cask := cask_definitions[token] or {
				return error("Error while generating data for cask '${token}'.")
			}
			serialized := (cask.serialized_by_tag[bottle_tag] or { hash }).clone()
			casks[token] = brew_runtime.map_value(serialized)
		}

		json_contents := brew_runtime.map_value({
			'metadata':               brew_runtime.map_value({
				'homebrew_version': brew_runtime.string_value(options.homebrew_version)
				'bottle_tag':       brew_runtime.string_value(bottle_tag)
				'generated_at':     brew_runtime.int_value(generated_at)
			})
			'formulae':               brew_runtime.map_value(formulae)
			'casks':                  brew_runtime.map_value(casks)
			'formula_aliases':        generate_internal_api_string_map(options.formula_aliases)
			'formula_renames':        generate_internal_api_string_map(options.formula_renames)
			'cask_renames':           generate_internal_api_string_map(options.cask_renames)
			'formula_tap_git_head':   brew_runtime.string_value(options.formula_tap_git_head)
			'cask_tap_git_head':      brew_runtime.string_value(options.cask_tap_git_head)
			'formula_tap_migrations': generate_internal_api_string_map(options.formula_migrations)
			'cask_tap_migrations':    generate_internal_api_string_map(options.cask_migrations)
		})
		packages[bottle_tag] = json_contents
		if !options.dry_run {
			relative_path := 'api/internal/packages.${bottle_tag}.json'
			os.write_file(generate_internal_api_path(root, relative_path), brew_runtime.json_value_to_string(json_contents))!
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

pub fn generate_internal_api_input_boundary(input &GenerateInternalApiInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::GenerateInternalApi::Input', '', {
		'generate_internal_api_input_address': u64(voidptr(input)).str()
	})
}

fn generate_internal_api_input_from_value(value brew_runtime.Value) &GenerateInternalApiInput {
	address := value.attributes['generate_internal_api_input_address'] or {
		panic('invalid GenerateInternalApi input')
	}
	return unsafe { &GenerateInternalApiInput(voidptr(address.u64())) }
}

fn generate_internal_api_result_value(result GenerateInternalApiResult) brew_runtime.Value {
	mut formulae := map[string]brew_runtime.Value{}
	for name, hash in result.formulae {
		formulae[name] = brew_runtime.map_value(hash)
	}
	mut casks := map[string]brew_runtime.Value{}
	for token, hash in result.casks {
		casks[token] = brew_runtime.map_value(hash)
	}
	return brew_runtime.map_value({
		'formulae':      brew_runtime.map_value(formulae)
		'casks':         brew_runtime.map_value(casks)
		'packages':      brew_runtime.map_value(result.packages)
		'written_files': brew_runtime.string_array_value(result.written_files)
	})
}

// Ruby method `run` at line 28.
pub fn ruby_generate_internal_api_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := generate_internal_api_input_from_value(args[0])
	result := run_generate_internal_api(input.options) or {
		error_type := if !input.options.core_tap_installed || !input.options.cask_tap_installed {
			'TapUnavailableError'
		} else if err.msg().starts_with('Failed to download') {
			'FatalError'
		} else {
			'Error'
		}
		return brew_runtime.object_value(error_type, err.msg())
	}
	return generate_internal_api_result_value(result)
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
// 9: require "cask/cask"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class GenerateInternalApi < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Generate internal API data files for <#{HOMEBREW_API_WWW}>.
// 17:           The generated files are written to the current directory.
// 18:         EOS
// 19:         switch "-n", "--dry-run",
// 20:                description: "Generate internal API data without writing it to files."
// 21:
// 22:         named_args :none
// 23:
// 24:         hide_from_man_page!
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         core_tap = CoreTap.instance
// 30:         cask_tap = CoreCaskTap.instance
// 31:         raise TapUnavailableError, core_tap.name unless core_tap.installed?
// 32:         raise TapUnavailableError, cask_tap.name unless cask_tap.installed?
// 33:
// 34:         unless args.dry_run?
// 35:           FileUtils.rm_rf "api/internal"
// 36:           FileUtils.mkdir_p "api/internal"
// 37:         end
// 38:
// 39:         executables_path = Pathname("api/internal/executables.txt")
// 40:         # Use the existing executables database as the API generation source.
// 41:         # It is generated from GitHub Packages metadata, not generated API JSON.
// 42:         if !args.dry_run? &&
// 43:            !Homebrew::API.download_executables_file_from_github_packages!(executables_path)
// 44:           odie "Failed to download #{executables_path}"
// 45:         end
// 46:         executables = ExecutablesDB.new(executables_path.to_s).to_hash
// 47:
// 48:         Homebrew.with_no_api_env do
// 49:           Formulary.enable_factory_cache!
// 50:           Formula.generating_hash!
// 51:           Cask::Cask.generating_hash!
// 52:
// 53:           all_formulae = {}
// 54:           all_casks = {}
// 55:           latest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 56:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 57:             core_tap.formula_names.each do |name|
// 58:               formula = Formulary.factory(name)
// 59:               name = formula.name
// 60:               all_formulae[name] = formula.to_hash_with_variations
// 61:               all_formulae[name]["executables"] = executables[name] if executables.key?(name)
// 62:             rescue
// 63:               onoe "Error while generating data for formula '#{name}'."
// 64:               raise
// 65:             end
// 66:
// 67:             cask_tap.cask_files.each do |path|
// 68:               cask = Cask::CaskLoader.load(path)
// 69:               name = cask.token
// 70:               all_casks[name] = cask.to_hash_with_variations
// 71:             rescue
// 72:               onoe "Error while generating data for cask '#{path.stem}'."
// 73:               raise
// 74:             end
// 75:           end
// 76:
// 77:           OnSystem::VALID_OS_ARCH_TAGS.each do |bottle_tag|
// 78:             formulae = all_formulae.to_h do |name, hash|
// 79:               hash = Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(hash, bottle_tag:)
// 80:                                                                    .serialize(bottle_tag:)
// 81:               [name, hash]
// 82:             end
// 83:
// 84:             casks = all_casks.to_h do |token, hash|
// 85:               hash = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash, bottle_tag:)
// 86:                                                              .serialize
// 87:               [token, hash]
// 88:             end
// 89:
// 90:             json_contents = {
// 91:               metadata:               {
// 92:                 homebrew_version: HOMEBREW_VERSION,
// 93:                 bottle_tag:       bottle_tag.to_s,
// 94:                 generated_at:     Time.now.to_i,
// 95:               },
// 96:               formulae:,
// 97:               casks:,
// 98:               formula_aliases:        core_tap.alias_table,
// 99:               formula_renames:        core_tap.formula_renames,
// 100:               cask_renames:           cask_tap.cask_renames,
// 101:               formula_tap_git_head:   core_tap.git_head,
// 102:               cask_tap_git_head:      cask_tap.git_head,
// 103:               formula_tap_migrations: core_tap.tap_migrations,
// 104:               cask_tap_migrations:    cask_tap.tap_migrations,
// 105:             }
// 106:
// 107:             File.write("api/internal/packages.#{bottle_tag}.json", JSON.generate(json_contents)) unless args.dry_run?
// 108:           end
// 109:         end
// 110:       end
// 111:     end
// 112:   end
// 113: end
