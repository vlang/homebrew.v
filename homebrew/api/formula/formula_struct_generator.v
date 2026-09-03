module formula

import brew_runtime
import homebrew
import homebrew.api
import homebrew.utils

// Translated from Homebrew/brew `api/formula/formula_struct_generator.rb`.
// The original source is retained below until every stub has a typed V body.
pub const formula_struct_generator_supported_requirements = ['arch', 'linux', 'macos', 'maximum_macos',
	'xcode']

pub struct FormulaStructGeneratorOptions {
pub:
	bottle_tag          string
	paths               api.ApiStructPaths
	no_autobump_reasons []string
}

pub struct FormulaDependenciesResult {
pub:
	dependencies    []brew_runtime.Value
	uses_from_macos []api.ApiStructArgPair
}

fn formula_generator_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn formula_generator_symbol(value string) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', value.trim_string_left(':'))
}

fn formula_generator_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn formula_generator_present(value brew_runtime.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

fn formula_generator_array(value brew_runtime.Value) []brew_runtime.Value {
	return value.as_array() or { []brew_runtime.Value{} }
}

fn formula_generator_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	return value.as_map() or { map[string]brew_runtime.Value{} }
}

fn formula_generator_dig(hash map[string]brew_runtime.Value, keys ...string) brew_runtime.Value {
	if keys.len == 0 {
		return formula_generator_nil()
	}
	mut value := hash[keys[0]] or { return formula_generator_nil() }
	for key in keys[1..] {
		if value.type_name != 'Hash' {
			return formula_generator_nil()
		}
		value = value.map_data[key] or { return formula_generator_nil() }
	}
	return value
}

fn formula_generator_deep_stringify_keys(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Array' {
		return brew_runtime.array_value(formula_generator_array(value).map(formula_generator_deep_stringify_keys(it)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]brew_runtime.Value{}
		for key, item in value.map_data {
			mapped[key.trim_string_left(':')] = formula_generator_deep_stringify_keys(item)
		}
		return brew_runtime.map_value(mapped)
	}
	return value
}

fn formula_generator_to_symbol(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Array' {
		return brew_runtime.array_value(formula_generator_array(value).map(formula_generator_to_symbol(it)))
	}
	return formula_generator_symbol(value.as_string())
}

fn formula_generator_deep_symbolize_values(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Array' {
		return brew_runtime.array_value(formula_generator_array(value).map(formula_generator_deep_symbolize_values(it)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]brew_runtime.Value{}
		for key, item in value.map_data {
			mapped[key] = formula_generator_deep_symbolize_values(item)
		}
		return brew_runtime.map_value(mapped)
	}
	return formula_generator_symbol(value.as_string())
}

fn formula_generator_symbolize_map_values(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name != 'Hash' {
		return value
	}
	mut mapped := map[string]brew_runtime.Value{}
	for key, item in value.map_data {
		mapped[key] = formula_generator_to_symbol(item)
	}
	return brew_runtime.map_value(mapped)
}

pub fn formula_generator_symbolize_dependency_hash(hash map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut symbolized := hash.clone()
	if bounds_value := symbolized['uses_from_macos_bounds'] {
		mut bounds := []brew_runtime.Value{}
		for bound in formula_generator_array(bounds_value) {
			bounds << formula_generator_symbolize_map_values(bound)
		}
		symbolized['uses_from_macos_bounds'] = brew_runtime.array_value(bounds)
	}
	for key, dependencies in symbolized.clone() {
		mut items := []brew_runtime.Value{}
		for dependency in formula_generator_array(dependencies) {
			items << formula_generator_symbolize_map_values(dependency)
		}
		symbolized[key] = brew_runtime.array_value(items)
	}
	return symbolized
}

pub fn formula_generator_process_dependencies(deps_hash map[string]brew_runtime.Value) []brew_runtime.Value {
	mut dependencies := formula_generator_array(deps_hash['dependencies'] or {
		brew_runtime.array_value([])
	})
	for dependency_type in ['build', 'test', 'recommended', 'optional'] {
		key := '${dependency_type}_dependencies'
		for dependency in formula_generator_array(deps_hash[key] or {
			brew_runtime.array_value([])
		}) {
			dependencies << brew_runtime.map_value({
				dependency.as_string(): formula_generator_symbol(dependency_type)
			})
		}
	}
	return dependencies
}

fn formula_generator_macos_symbol(version string) ?string {
	for symbol, value in homebrew.macos_symbol_versions() {
		if value == version {
			return symbol
		}
	}
	return none
}

pub fn formula_generator_process_requirements(requirements_array []brew_runtime.Value,
	spec string) []brew_runtime.Value {
	mut requirements := []brew_runtime.Value{}
	for requirement_value in requirements_array {
		requirement := formula_generator_map(requirement_value)
		specs := formula_generator_array(requirement['specs'] or {
			brew_runtime.array_value([])
		}).map(it.as_string())
		if spec !in specs {
			continue
		}
		name := (requirement['name'] or { continue }).as_string().trim_string_left(':')
		if name !in formula_struct_generator_supported_requirements {
			continue
		}
		mut tags := []brew_runtime.Value{}
		if version := requirement['version'] {
			if formula_generator_present(version) {
				match name {
					'arch' { tags << formula_generator_symbol(version.as_string()) }
					'macos', 'maximum_macos' {
						if symbol := formula_generator_macos_symbol(version.as_string()) {
							tags << formula_generator_symbol(symbol)
						}
					}
					else { tags << version }
				}
			}
		}
		for context in formula_generator_array(requirement['contexts'] or {
			brew_runtime.array_value([])
		}) {
			if context.type_name == 'String' {
				tags << formula_generator_symbol(context.as_string())
			} else if context.type_name == 'Hash' {
				mut transformed := map[string]brew_runtime.Value{}
				for key, value in context.map_data {
					transformed[key.trim_string_left(':')] = value
				}
				tags << brew_runtime.map_value(transformed)
			} else {
				tags << context
			}
		}
		if tags.len == 0 {
			requirements << formula_generator_symbol(name)
		} else {
			requirements << brew_runtime.map_value({
				name: brew_runtime.array_value(tags)
			})
		}
	}
	return requirements
}

pub fn formula_generator_process_uses_from_macos(deps_hash map[string]brew_runtime.Value) []api.ApiStructArgPair {
	uses_from_macos := formula_generator_array(deps_hash['uses_from_macos'] or {
		brew_runtime.array_value([])
	})
	bounds_array := formula_generator_array(deps_hash['uses_from_macos_bounds'] or {
		brew_runtime.array_value([])
	})
	mut output := []api.ApiStructArgPair{}
	for index, item in uses_from_macos {
		mut bounds := map[string]brew_runtime.Value{}
		if index < bounds_array.len {
			for key, value in formula_generator_map(bounds_array[index]) {
				bounds[key.trim_string_left(':')] = formula_generator_symbol(value.as_string())
			}
		}
		if item.type_name == 'Hash' {
			mut dependency := formula_generator_map(formula_generator_deep_symbolize_values(item))
			for key, value in bounds {
				dependency[key] = value
			}
			output << api.ApiStructArgPair{
				first: brew_runtime.map_value(dependency)
				second: brew_runtime.map_value({})
			}
		} else {
			output << api.ApiStructArgPair{
				first: item
				second: brew_runtime.map_value(bounds)
			}
		}
	}
	return output
}

pub fn formula_generator_process_dependencies_and_requirements(deps_hash ?map[string]brew_runtime.Value,
	requirements_array ?[]brew_runtime.Value, spec string) FormulaDependenciesResult {
	mut dependencies := []brew_runtime.Value{}
	mut uses_from_macos := []api.ApiStructArgPair{}
	if raw_dependencies := deps_hash {
		if raw_dependencies.len > 0 {
			symbolized := formula_generator_symbolize_dependency_hash(raw_dependencies)
			dependencies = formula_generator_process_dependencies(symbolized)
			uses_from_macos = formula_generator_process_uses_from_macos(symbolized)
		}
	}
	if raw_requirements := requirements_array {
		if raw_requirements.len > 0 {
			dependencies << formula_generator_process_requirements(raw_requirements, spec)
		}
	}
	return FormulaDependenciesResult{
		dependencies: dependencies
		uses_from_macos: uses_from_macos
	}
}

fn formula_generator_arg_pair_value(pair api.ApiStructArgPair) brew_runtime.Value {
	return brew_runtime.array_value([pair.first, pair.second])
}

fn formula_generator_arg_pairs_value(pairs []api.ApiStructArgPair) brew_runtime.Value {
	return brew_runtime.array_value(pairs.map(formula_generator_arg_pair_value(it)))
}

fn formula_generator_compact_map(values map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut compact := map[string]brew_runtime.Value{}
	for key, value in values {
		if formula_generator_present(value) {
			compact[key] = value
		}
	}
	return compact
}

fn formula_generator_service_hash(service map[string]brew_runtime.Value,
	paths api.ApiStructPaths) !map[string]brew_runtime.Value {
	mut output := map[string]brew_runtime.Value{}
	if name := service['name'] {
		output['name'] = formula_generator_deep_stringify_keys(name)
	}
	if run := service['run'] {
		if run.type_name == 'String' || run.type_name == 'Pathname' {
			output['run'] = brew_runtime.string_value(homebrew.service_replace_placeholders(run.as_string(), paths.prefix, paths.cellar, paths.home))
		} else if run.type_name == 'Array' {
			output['run'] = brew_runtime.array_value(formula_generator_array(run).map(brew_runtime.string_value(homebrew.service_replace_placeholders(it.as_string(), paths.prefix, paths.cellar, paths.home))))
		} else if run.type_name == 'Hash' {
			mut commands := map[string]brew_runtime.Value{}
			for key, command in run.map_data {
				commands[key.trim_string_left(':')] = if command.type_name == 'Array' {
					brew_runtime.array_value(formula_generator_array(command).map(brew_runtime.string_value(homebrew.service_replace_placeholders(it.as_string(), paths.prefix, paths.cellar, paths.home))))
				} else {
					brew_runtime.string_value(homebrew.service_replace_placeholders(command.as_string(), paths.prefix, paths.cellar, paths.home))
				}
			}
			output['run'] = brew_runtime.map_value(commands)
		} else {
			return error('Unexpected run command: ${run.as_string()}')
		}
	} else {
		return output
	}
	if environment := service['environment_variables'] {
		mut variables := map[string]brew_runtime.Value{}
		for key, value in formula_generator_map(environment) {
			variables[key.trim_string_left(':')] = brew_runtime.string_value(homebrew.service_replace_placeholders(value.as_string(), paths.prefix, paths.cellar, paths.home))
		}
		output['environment_variables'] = brew_runtime.map_value(variables)
	}
	for key in ['run_type', 'process_type'] {
		if value := service[key] {
			if formula_generator_truthy(value) {
				output[key] = formula_generator_symbol(value.as_string())
			}
		}
	}
	for key in ['working_dir', 'root_dir', 'input_path', 'log_path', 'error_log_path'] {
		if value := service[key] {
			if formula_generator_truthy(value) {
				output[key] = brew_runtime.string_value(homebrew.service_replace_placeholders(value.as_string(), paths.prefix, paths.cellar, paths.home))
			}
		}
	}
	for key in ['interval', 'cron', 'launch_only_once', 'require_root', 'restart_delay',
		'throttle_interval', 'stop_timeout', 'nice', 'macos_legacy_timers'] {
		if value := service[key] {
			if value.type_name != 'NilClass' {
				output[key] = value
			}
		}
	}
	for key in ['sockets', 'keep_alive'] {
		if value := service[key] {
			if formula_generator_truthy(value) {
				output[key] = formula_generator_deep_stringify_keys(value)
			}
		}
	}
	return output
}

fn formula_generator_merge_variations(input map[string]brew_runtime.Value,
	bottle_tag string) map[string]brew_runtime.Value {
	value := if bottle_tag == '' {
		homebrew.ruby_api_l194_d4_self_merge_variations(brew_runtime.map_value(input))
	} else {
		homebrew.ruby_api_l194_d4_self_merge_variations(brew_runtime.map_value(input), brew_runtime.string_value(bottle_tag))
	}
	return formula_generator_map(formula_generator_deep_stringify_keys(value))
}

pub fn formula_generator_generate_formula_struct_hash(input map[string]brew_runtime.Value,
	options FormulaStructGeneratorOptions) !api.FormulaStruct {
	mut hash := formula_generator_merge_variations(input, options.bottle_tag)
	if caveats := hash['caveats'] {
		if formula_generator_truthy(caveats) {
			hash['caveats'] = brew_runtime.string_value(homebrew.replace_formula_placeholders(caveats.as_string(), options.paths.prefix, options.paths.cellar, options.paths.home))
		}
	}
	files := formula_generator_map(formula_generator_dig(hash, 'bottle', 'stable', 'files'))
	mut bottle_checksums := []brew_runtime.Value{}
	for tag, specification_value in files {
		specification := formula_generator_map(specification_value)
		cellar := specification['cellar'] or { return error('key not found: cellar') }
		checksum := specification['sha256'] or { return error('key not found: sha256') }
		bottle_checksums << brew_runtime.map_value({
			'cellar': homebrew.convert_to_string_or_symbol(cellar.as_string())
			tag:      checksum
		})
	}
	hash['bottle_checksums'] = brew_runtime.array_value(bottle_checksums)
	hash['bottle_rebuild'] = formula_generator_dig(hash, 'bottle', 'stable', 'rebuild')
	conflict_names := formula_generator_array(hash['conflicts_with'] or {
		brew_runtime.array_value([])
	})
	conflict_reasons := formula_generator_array(hash['conflicts_with_reasons'] or {
		brew_runtime.array_value([])
	})
	mut conflicts := []brew_runtime.Value{}
	for index, name in conflict_names {
		reason := if index < conflict_reasons.len {
			conflict_reasons[index]
		} else {
			formula_generator_nil()
		}
		arguments := if formula_generator_present(reason) {
			brew_runtime.map_value({
				'because': reason
			})
		} else {
			brew_runtime.map_value({})
		}
		conflicts << brew_runtime.array_value([name, arguments])
	}
	hash['conflicts'] = brew_runtime.array_value(conflicts)
	for key in ['deprecate_args', 'disable_args'] {
		if arguments_value := hash[key] {
			if formula_generator_truthy(arguments_value) {
				mut arguments := formula_generator_map(arguments_value)
				if because := arguments['because'] {
					arguments['because'] = homebrew.ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(because, formula_generator_symbol('formula'))
				}
				hash[key] = brew_runtime.map_value(arguments)
			}
		}
	}
	head_url := formula_generator_dig(hash, 'urls', 'head', 'url')
	mut head_specs := map[string]brew_runtime.Value{}
	head_specs['branch'] = formula_generator_dig(hash, 'urls', 'head', 'branch')
	head_using := formula_generator_dig(hash, 'urls', 'head', 'using')
	if formula_generator_present(head_using) {
		head_specs['using'] = formula_generator_symbol(head_using.as_string())
	}
	hash['head_url_args'] = brew_runtime.array_value([
		if head_url.type_name == 'NilClass' { brew_runtime.string_value('') } else { head_url },
		brew_runtime.map_value(formula_generator_compact_map(head_specs)),
	])
	if keg_only_value := hash['keg_only_reason'] {
		if formula_generator_truthy(keg_only_value) {
			keg_only := formula_generator_map(keg_only_value)
			reason := keg_only['reason'] or { return error('key not found: reason') }
			mut arguments := [
				homebrew.convert_to_string_or_symbol(reason.as_string()),
			]
			if explanation := keg_only['explanation'] {
				if explanation.type_name != 'NilClass' {
					arguments << explanation
				}
			}
			hash['keg_only_args'] = brew_runtime.array_value(arguments)
		}
	}
	license := (hash['license'] or { formula_generator_nil() }).as_string()
	if expression := utils.string_to_spdx_license_expression(license) {
		hash['license'] = brew_runtime.string_value(utils.spdx_license_expression_to_string(expression, false))
	} else {
		hash['license'] = formula_generator_nil()
	}
	hash['link_overwrite_paths'] = hash['link_overwrite'] or { formula_generator_nil() }
	if reason := hash['no_autobump_message'] {
		if formula_generator_truthy(reason) {
			reason_name := reason.as_string().trim_string_left(':')
			effective_reason := if reason_name in options.no_autobump_reasons {
				formula_generator_symbol(reason_name)
			} else {
				reason
			}
			hash['no_autobump_args'] = brew_runtime.map_value({
				'because': effective_reason
			})
		}
	}
	if condition := hash['pour_bottle_only_if'] {
		if formula_generator_truthy(condition) {
			hash['pour_bottle_args'] = brew_runtime.map_value({
				'only_if': formula_generator_symbol(condition.as_string())
			})
		}
	}
	hash['ruby_source_checksum'] = formula_generator_dig(hash, 'ruby_source_checksum', 'sha256')
	if service_value := hash['service'] {
		if formula_generator_truthy(service_value) {
			service := formula_generator_service_hash(formula_generator_map(service_value), options.paths)!
			run := service['run'] or { formula_generator_nil() }
			if run.type_name == 'Hash' {
				hash['service_run_args'] = brew_runtime.array_value([])
				hash['service_run_kwargs'] = run
			} else if run.type_name == 'Array' || run.type_name == 'String' {
				hash['service_run_args'] = brew_runtime.array_value([run])
				hash['service_run_kwargs'] = brew_runtime.map_value({})
			} else {
				hash['service_run_args'] = brew_runtime.array_value([])
				hash['service_run_kwargs'] = brew_runtime.map_value({})
			}
			hash['service_name_args'] = service['name'] or { formula_generator_nil() }
			mut service_args := []brew_runtime.Value{}
			for key, value in service {
				if key != 'name' && key != 'run' {
					service_args << brew_runtime.array_value([
						formula_generator_symbol(key),
						value,
					])
				}
			}
			hash['service_args'] = brew_runtime.array_value(service_args)
		}
	}
	hash['stable_checksum'] = formula_generator_dig(hash, 'urls', 'stable', 'checksum')
	stable_url := formula_generator_dig(hash, 'urls', 'stable', 'url')
	mut stable_specs := map[string]brew_runtime.Value{}
	stable_specs['tag'] = formula_generator_dig(hash, 'urls', 'stable', 'tag')
	stable_specs['revision'] = formula_generator_dig(hash, 'urls', 'stable', 'revision')
	stable_using := formula_generator_dig(hash, 'urls', 'stable', 'using')
	if formula_generator_present(stable_using) {
		stable_specs['using'] = formula_generator_symbol(stable_using.as_string())
	}
	hash['stable_url_args'] = brew_runtime.array_value([
		stable_url,
		brew_runtime.map_value(formula_generator_compact_map(stable_specs)),
	])
	hash['stable_version'] = formula_generator_dig(hash, 'versions', 'stable')
	hash['requirements_array'] = hash['requirements'] or { formula_generator_nil() }
	mut stable_dependency_hash := map[string]brew_runtime.Value{}
	for key in ['dependencies', 'build_dependencies', 'test_dependencies', 'recommended_dependencies',
		'optional_dependencies', 'uses_from_macos', 'uses_from_macos_bounds'] {
		stable_dependency_hash[key] = hash[key] or { brew_runtime.array_value([]) }
	}
	stable_result := formula_generator_process_dependencies_and_requirements(stable_dependency_hash, if requirements := hash['requirements_array'] {
		if requirements.type_name == 'Array' { formula_generator_array(requirements) } else { none }
	} else {
		none
	}, 'stable')
	head_dependency_hash := if value := hash['head_dependencies'] {
		formula_generator_map(value)
	} else {
		stable_dependency_hash
	}
	head_result := formula_generator_process_dependencies_and_requirements(head_dependency_hash, if requirements := hash['requirements_array'] {
		if requirements.type_name == 'Array' { formula_generator_array(requirements) } else { none }
	} else {
		none
	}, 'head')
	hash['stable_dependencies'] = brew_runtime.array_value(stable_result.dependencies)
	hash['stable_patches'] = hash['patches'] or { brew_runtime.array_value([]) }
	hash['stable_uses_from_macos'] = formula_generator_arg_pairs_value(stable_result.uses_from_macos)
	hash['head_dependencies'] = brew_runtime.array_value(head_result.dependencies)
	hash['head_uses_from_macos'] = formula_generator_arg_pairs_value(head_result.uses_from_macos)
	hash['bottle_present'] = brew_runtime.bool_value(formula_generator_present(hash['bottle'] or {
		formula_generator_nil()
	}))
	hash['deprecate_present'] = brew_runtime.bool_value(formula_generator_present(hash['deprecate_args'] or {
		formula_generator_nil()
	}))
	hash['disable_present'] = brew_runtime.bool_value(formula_generator_present(hash['disable_args'] or {
		formula_generator_nil()
	}))
	hash['head_present'] = brew_runtime.bool_value(formula_generator_present(formula_generator_dig(hash, 'urls', 'head')))
	hash['keg_only_present'] = brew_runtime.bool_value(formula_generator_present(hash['keg_only_reason'] or {
		formula_generator_nil()
	}))
	hash['no_autobump_present'] = brew_runtime.bool_value(formula_generator_present(hash['no_autobump_message'] or {
		formula_generator_nil()
	}))
	hash['pour_bottle_present'] = brew_runtime.bool_value(formula_generator_present(hash['pour_bottle_only_if'] or {
		formula_generator_nil()
	}))
	hash['service_present'] = brew_runtime.bool_value(formula_generator_present(hash['service'] or {
		formula_generator_nil()
	}))
	hash['service_run_present'] = brew_runtime.bool_value(formula_generator_present(formula_generator_dig(hash, 'service', 'run')))
	hash['service_name_present'] = brew_runtime.bool_value(formula_generator_present(formula_generator_dig(hash, 'service', 'name')))
	hash['stable_present'] = brew_runtime.bool_value(formula_generator_present(formula_generator_dig(hash, 'urls', 'stable')))
	return api.formula_struct_from_hash(hash, options.paths)
}

// Ruby method `generate_formula_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag)` at line 43.
pub fn ruby_formula_struct_generator_l43_d1_generate_formula_struct_hash(hash map[string]brew_runtime.Value,
	options FormulaStructGeneratorOptions) !api.FormulaStruct {
	return formula_generator_generate_formula_struct_hash(hash, options)
}

// Ruby method `process_dependencies_and_requirements(deps_hash, requirements_array, spec)` at line 203.
pub fn ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(deps_hash ?map[string]brew_runtime.Value,
	requirements_array ?[]brew_runtime.Value, spec string) FormulaDependenciesResult {
	return formula_generator_process_dependencies_and_requirements(deps_hash, requirements_array, spec)
}

// Ruby method `symbolize_dependency_hash(hash)` at line 223.
pub fn ruby_formula_struct_generator_l223_d3_symbolize_dependency_hash(hash map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	return formula_generator_symbolize_dependency_hash(hash)
}

// Ruby method `process_dependencies(deps_hash)` at line 251.
pub fn ruby_formula_struct_generator_l251_d4_process_dependencies(deps_hash map[string]brew_runtime.Value) []brew_runtime.Value {
	return formula_generator_process_dependencies(deps_hash)
}

// Ruby method `process_requirements(requirements_array, spec)` at line 261.
pub fn ruby_formula_struct_generator_l261_d5_process_requirements(requirements_array []brew_runtime.Value,
	spec string) []brew_runtime.Value {
	return formula_generator_process_requirements(requirements_array, spec)
}

// Ruby method `process_uses_from_macos(deps_hash)` at line 299.
pub fn ruby_formula_struct_generator_l299_d6_process_uses_from_macos(deps_hash map[string]brew_runtime.Value) []api.ApiStructArgPair {
	return formula_generator_process_uses_from_macos(deps_hash)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "deprecate_disable"
// 5:
// 6: module Homebrew
// 7:   module API
// 8:     module Formula
// 9:       # Methods for generating FormulaStruct instances from API data.
// 10:       module FormulaStructGenerator
// 11:         module_function
// 12:
// 13:         # `:codesign` and custom requirement classes are not supported.
// 14:         API_SUPPORTED_REQUIREMENTS = [:arch, :linux, :macos, :maximum_macos, :xcode].freeze
// 15:         private_constant :API_SUPPORTED_REQUIREMENTS
// 16:
// 17:         DependencyHash = T.type_alias do
// 18:           T::Hash[
// 19:             # Keys are strings of the dependency type (e.g. "dependencies", "build_dependencies")
// 20:             String,
// 21:             # Values are arrays of either:
// 22:             T::Array[
// 23:               T.any(
// 24:                 # Formula name: "foo"
// 25:                 String,
// 26:                 # Hash like { "foo" => :build } or { "foo" => [:build, :test] }
// 27:                 T::Hash[
// 28:                   String,
// 29:                   T.any(Symbol, T::Array[Symbol]),
// 30:                 ],
// 31:                 # Hash like { since: :catalina } for uses_from_macos_bounds
// 32:                 T::Hash[Symbol, Symbol],
// 33:               ),
// 34:             ],
// 35:           ]
// 36:         end
// 37:
// 38:         RequirementsArray = T.type_alias do
// 39:           T::Array[T::Hash[String, T.untyped]]
// 40:         end
// 41:
// 42:         sig { params(hash: T::Hash[String, T.untyped], bottle_tag: Utils::Bottles::Tag).returns(FormulaStruct) }
// 43:         def generate_formula_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag)
// 44:           hash = Homebrew::API.merge_variations(hash, bottle_tag:).dup.deep_stringify_keys
// 45:
// 46:           if (caveats = hash["caveats"])
// 47:             hash["caveats"] = Formulary.replace_placeholders(caveats)
// 48:           end
// 49:
// 50:           hash["bottle_checksums"] = begin
// 51:             files = hash.dig("bottle", "stable", "files") || {}
// 52:             files.map do |tag, bottle_spec|
// 53:               {
// 54:                 cellar: Utils.convert_to_string_or_symbol(bottle_spec.fetch("cellar")),
// 55:                 tag.to_sym => bottle_spec.fetch("sha256"),
// 56:               }
// 57:             end
// 58:           end
// 59:
// 60:           hash["bottle_rebuild"] = hash.dig("bottle", "stable", "rebuild")
// 61:
// 62:           conflicts_with = hash["conflicts_with"] || []
// 63:           conflicts_with_reasons = hash["conflicts_with_reasons"] || []
// 64:           hash["conflicts"] = conflicts_with.zip(conflicts_with_reasons).map do |name, reason|
// 65:             if reason.present?
// 66:               [name, { because: reason }]
// 67:             else
// 68:               [name, {}]
// 69:             end
// 70:           end
// 71:
// 72:           if (deprecate_args = hash["deprecate_args"])
// 73:             deprecate_args = deprecate_args.dup.transform_keys(&:to_sym)
// 74:             deprecate_args[:because] =
// 75:               DeprecateDisable.to_reason_string_or_symbol(deprecate_args[:because], type: :formula)
// 76:             hash["deprecate_args"] = deprecate_args
// 77:           end
// 78:
// 79:           if (disable_args = hash["disable_args"])
// 80:             disable_args = disable_args.dup.transform_keys(&:to_sym)
// 81:             disable_args[:because] =
// 82:               DeprecateDisable.to_reason_string_or_symbol(disable_args[:because], type: :formula)
// 83:             hash["disable_args"] = disable_args
// 84:           end
// 85:
// 86:           hash["head_url_args"] = begin
// 87:             # Fall back to "" to satisfy the type checker. If the head URL is missing, head_present will be false.
// 88:             url = hash.dig("urls", "head", "url") || ""
// 89:             specs = {
// 90:               branch: hash.dig("urls", "head", "branch"),
// 91:               using:  hash.dig("urls", "head", "using")&.to_sym,
// 92:             }.compact_blank
// 93:             [url, specs]
// 94:           end
// 95:
// 96:           if (keg_only_hash = hash["keg_only_reason"])
// 97:             reason = Utils.convert_to_string_or_symbol(keg_only_hash.fetch("reason"))
// 98:             explanation = keg_only_hash["explanation"]
// 99:             hash["keg_only_args"] = [reason, explanation].compact
// 100:           end
// 101:
// 102:           hash["license"] = SPDX.string_to_license_expression(hash["license"])
// 103:
// 104:           hash["link_overwrite_paths"] = hash["link_overwrite"]
// 105:
// 106:           if (reason = hash["no_autobump_message"])
// 107:             reason = reason.to_sym if NO_AUTOBUMP_REASONS_LIST.key?(reason.to_sym)
// 108:             hash["no_autobump_args"] = { because: reason }
// 109:           end
// 110:
// 111:           if (condition = hash["pour_bottle_only_if"])
// 112:             hash["pour_bottle_args"] = { only_if: condition.to_sym }
// 113:           end
// 114:
// 115:           hash["ruby_source_checksum"] = hash.dig("ruby_source_checksum", "sha256")
// 116:
// 117:           if (service_hash = hash["service"])
// 118:             service_hash = Homebrew::Service.from_hash(service_hash)
// 119:
// 120:             hash["service_run_args"], hash["service_run_kwargs"] = case (run = service_hash[:run])
// 121:             when Hash
// 122:               [[], run]
// 123:             when Array, String
// 124:               [[run], {}]
// 125:             else
// 126:               [[], {}]
// 127:             end
// 128:
// 129:             hash["service_name_args"] = service_hash[:name]
// 130:
// 131:             hash["service_args"] = service_hash.filter_map do |key, arg|
// 132:               [key.to_sym, arg] if key != :name && key != :run
// 133:             end
// 134:           end
// 135:
// 136:           hash["stable_checksum"] = hash.dig("urls", "stable", "checksum")
// 137:
// 138:           hash["stable_url_args"] = begin
// 139:             url = hash.dig("urls", "stable", "url")
// 140:             specs = {
// 141:               tag:      hash.dig("urls", "stable", "tag"),
// 142:               revision: hash.dig("urls", "stable", "revision"),
// 143:               using:    hash.dig("urls", "stable", "using")&.to_sym,
// 144:             }.compact_blank
// 145:             [url, specs]
// 146:           end
// 147:
// 148:           hash["stable_version"] = hash.dig("versions", "stable")
// 149:
// 150:           # Do dependency processing last because it's more involved and depends on other fields
// 151:           hash["requirements_array"] = hash["requirements"]
// 152:
// 153:           stable_dependency_hash = {
// 154:             "dependencies"             => hash["dependencies"] || [],
// 155:             "build_dependencies"       => hash["build_dependencies"] || [],
// 156:             "test_dependencies"        => hash["test_dependencies"] || [],
// 157:             "recommended_dependencies" => hash["recommended_dependencies"] || [],
// 158:             "optional_dependencies"    => hash["optional_dependencies"] || [],
// 159:             "uses_from_macos"          => hash["uses_from_macos"] || [],
// 160:             "uses_from_macos_bounds"   => hash["uses_from_macos_bounds"] || [],
// 161:           }
// 162:
// 163:           stable_dependencies, stable_uses_from_macos = process_dependencies_and_requirements(
// 164:             stable_dependency_hash,
// 165:             hash["requirements_array"],
// 166:             :stable,
// 167:           )
// 168:
// 169:           # hash["head_dependencies"] is always present unless the stable and head deps are identical
// 170:           head_dependency_hash = hash["head_dependencies"] || stable_dependency_hash
// 171:           head_dependencies, head_uses_from_macos = process_dependencies_and_requirements(
// 172:             head_dependency_hash,
// 173:             hash["requirements_array"],
// 174:             :head,
// 175:           )
// 176:
// 177:           hash["stable_dependencies"] = stable_dependencies
// 178:           hash["stable_patches"] = hash["patches"] || []
// 179:           hash["stable_uses_from_macos"] = stable_uses_from_macos
// 180:           hash["head_dependencies"] = head_dependencies
// 181:           hash["head_uses_from_macos"] = head_uses_from_macos
// 182:
// 183:           # Should match FormulaStruct::PREDICATES
// 184:           hash["bottle_present"] = hash["bottle"].present?
// 185:           hash["deprecate_present"] = hash["deprecate_args"].present?
// 186:           hash["disable_present"] = hash["disable_args"].present?
// 187:           hash["head_present"] = hash.dig("urls", "head").present?
// 188:           hash["keg_only_present"] = hash["keg_only_reason"].present?
// 189:           hash["no_autobump_present"] = hash["no_autobump_message"].present?
// 190:           hash["pour_bottle_present"] = hash["pour_bottle_only_if"].present?
// 191:           hash["service_present"] = hash["service"].present?
// 192:           hash["service_run_present"] = hash.dig("service", "run").present?
// 193:           hash["service_name_present"] = hash.dig("service", "name").present?
// 194:           hash["stable_present"] = hash.dig("urls", "stable").present?
// 195:
// 196:           FormulaStruct.from_hash(hash)
// 197:         end
// 198:
// 199:         sig {
// 200:           params(deps_hash: T.nilable(DependencyHash), requirements_array: T.nilable(RequirementsArray), spec: Symbol)
// 201:             .returns([T::Array[FormulaStruct::DependsOnArgs], T::Array[FormulaStruct::UsesFromMacOSArgs]])
// 202:         }
// 203:         def process_dependencies_and_requirements(deps_hash, requirements_array, spec)
// 204:           deps, uses_from_macos = if deps_hash.present?
// 205:             deps_hash = symbolize_dependency_hash(deps_hash)
// 206:             [process_dependencies(deps_hash), process_uses_from_macos(deps_hash)]
// 207:           else
// 208:             [[], []]
// 209:           end
// 210:
// 211:           requirements = if requirements_array.present?
// 212:             process_requirements(requirements_array, spec)
// 213:           else
// 214:             []
// 215:           end
// 216:
// 217:           [deps + requirements, uses_from_macos]
// 218:         end
// 219:
// 220:         # Convert from { "dependencies" => ["foo", { "bar" => "build" }, { "baz" => ["build", "test"] }] }
// 221:         #           to { "dependencies" => ["foo", { "bar" => :build }, { "baz" => [:build, :test] }] }
// 222:         sig { params(hash: DependencyHash).returns(DependencyHash) }
// 223:         def symbolize_dependency_hash(hash)
// 224:           hash = hash.dup
// 225:
// 226:           if (uses_from_macos_bounds = hash["uses_from_macos_bounds"])
// 227:             uses_from_macos_bounds =
// 228:               T.cast(uses_from_macos_bounds, T::Array[T::Hash[T.any(String, Symbol), T.any(String, Symbol)]])
// 229:             hash["uses_from_macos_bounds"] = uses_from_macos_bounds.map do |bound|
// 230:               bound.to_h { |key, value| [key.to_sym, value.to_sym] }
// 231:             end
// 232:           end
// 233:
// 234:           hash.transform_values do |deps|
// 235:             deps.map do |dep|
// 236:               next dep unless dep.is_a?(Hash)
// 237:
// 238:               dep.transform_values do |types|
// 239:                 case types
// 240:                 when Array
// 241:                   types.map(&:to_sym)
// 242:                 else
// 243:                   types.to_sym
// 244:                 end
// 245:               end
// 246:             end
// 247:           end
// 248:         end
// 249:
// 250:         sig { params(deps_hash: DependencyHash).returns(T::Array[FormulaStruct::DependsOnArgs]) }
// 251:         def process_dependencies(deps_hash)
// 252:           dependencies = deps_hash.fetch("dependencies", [])
// 253:           dependencies + [:build, :test, :recommended, :optional].filter_map do |type|
// 254:             deps_hash["#{type}_dependencies"]&.map do |dep|
// 255:               { dep => type }
// 256:             end
// 257:           end.flatten(1)
// 258:         end
// 259:
// 260:         sig { params(requirements_array: RequirementsArray, spec: Symbol).returns(T::Array[FormulaStruct::DependsOnArgs]) }
// 261:         def process_requirements(requirements_array, spec)
// 262:           requirements_array.filter_map do |req|
// 263:             next unless req["specs"].include?(spec.to_s)
// 264:
// 265:             req_name = req["name"].to_sym
// 266:             next if API_SUPPORTED_REQUIREMENTS.exclude?(req_name)
// 267:
// 268:             req_version = case req_name
// 269:             when :arch
// 270:               req["version"]&.to_sym
// 271:             when :macos, :maximum_macos
// 272:               MacOSVersion::SYMBOLS.key(req["version"])
// 273:             else
// 274:               req["version"]
// 275:             end
// 276:
// 277:             req_tags = []
// 278:             req_tags << req_version if req_version.present?
// 279:             req_tags += req.fetch("contexts", []).map do |tag|
// 280:               case tag
// 281:               when String
// 282:                 tag.to_sym
// 283:               when Hash
// 284:                 tag.deep_transform_keys(&:to_sym)
// 285:               else
// 286:                 tag
// 287:               end
// 288:             end
// 289:
// 290:             if req_tags.empty?
// 291:               req_name
// 292:             else
// 293:               { req_name => req_tags }
// 294:             end
// 295:           end
// 296:         end
// 297:
// 298:         sig { params(deps_hash: DependencyHash).returns(T::Array[FormulaStruct::UsesFromMacOSArgs]) }
// 299:         def process_uses_from_macos(deps_hash)
// 300:           uses_from_macos = deps_hash.fetch("uses_from_macos", [])
// 301:
// 302:           uses_from_macos_bounds = deps_hash.fetch("uses_from_macos_bounds", [])
// 303:           uses_from_macos_bounds = T.cast(uses_from_macos_bounds, T::Array[T::Hash[Symbol, Symbol]])
// 304:
// 305:           uses_from_macos.zip(uses_from_macos_bounds).map do |entry, bounds|
// 306:             bounds ||= {}
// 307:             bounds = bounds.transform_keys(&:to_sym).transform_values(&:to_sym)
// 308:
// 309:             if entry.is_a?(Hash)
// 310:               # The key is the dependency name, the value is the dep type. Only the type should be a symbol
// 311:               entry = entry.deep_transform_values(&:to_sym)
// 312:               # When passing both a dep type and bounds, uses_from_macos expects them both in the first argument
// 313:               entry = entry.merge(bounds)
// 314:               [entry, {}]
// 315:             else
// 316:               [entry, bounds]
// 317:             end
// 318:           end
// 319:         end
// 320:       end
// 321:     end
// 322:   end
// 323: end
