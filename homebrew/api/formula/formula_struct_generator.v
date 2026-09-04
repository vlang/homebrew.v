module formula

import ruby
import homebrew
import homebrew.api
import homebrew.utils

// Translated from Homebrew/brew `api/formula/formula_struct_generator.rb`.
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
	dependencies    []ruby.Value
	uses_from_macos []api.ApiStructArgPair
}

fn formula_generator_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn formula_generator_symbol(value string) ruby.Value {
	return ruby.object_value('Symbol', value.trim_string_left(':'))
}

fn formula_generator_truthy(value ruby.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn formula_generator_present(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

fn formula_generator_array(value ruby.Value) []ruby.Value {
	return value.as_array() or { []ruby.Value{} }
}

fn formula_generator_map(value ruby.Value) map[string]ruby.Value {
	return value.as_map() or { map[string]ruby.Value{} }
}

fn formula_generator_dig(hash map[string]ruby.Value, keys ...string) ruby.Value {
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

fn formula_generator_deep_stringify_keys(value ruby.Value) ruby.Value {
	if value.type_name == 'Array' {
		return ruby.array_value(formula_generator_array(value).map(formula_generator_deep_stringify_keys(it)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]ruby.Value{}
		for key, item in value.map_data {
			mapped[key.trim_string_left(':')] = formula_generator_deep_stringify_keys(item)
		}
		return ruby.map_value(mapped)
	}
	return value
}

fn formula_generator_to_symbol(value ruby.Value) ruby.Value {
	if value.type_name == 'Array' {
		return ruby.array_value(formula_generator_array(value).map(formula_generator_to_symbol(it)))
	}
	return formula_generator_symbol(value.as_string())
}

fn formula_generator_deep_symbolize_values(value ruby.Value) ruby.Value {
	if value.type_name == 'Array' {
		return ruby.array_value(formula_generator_array(value).map(formula_generator_deep_symbolize_values(it)))
	}
	if value.type_name == 'Hash' {
		mut mapped := map[string]ruby.Value{}
		for key, item in value.map_data {
			mapped[key] = formula_generator_deep_symbolize_values(item)
		}
		return ruby.map_value(mapped)
	}
	return formula_generator_symbol(value.as_string())
}

fn formula_generator_symbolize_map_values(value ruby.Value) ruby.Value {
	if value.type_name != 'Hash' {
		return value
	}
	mut mapped := map[string]ruby.Value{}
	for key, item in value.map_data {
		mapped[key] = formula_generator_to_symbol(item)
	}
	return ruby.map_value(mapped)
}

pub fn formula_generator_symbolize_dependency_hash(hash map[string]ruby.Value) map[string]ruby.Value {
	mut symbolized := hash.clone()
	if bounds_value := symbolized['uses_from_macos_bounds'] {
		mut bounds := []ruby.Value{}
		for bound in formula_generator_array(bounds_value) {
			bounds << formula_generator_symbolize_map_values(bound)
		}
		symbolized['uses_from_macos_bounds'] = ruby.array_value(bounds)
	}
	for key, dependencies in symbolized.clone() {
		mut items := []ruby.Value{}
		for dependency in formula_generator_array(dependencies) {
			items << formula_generator_symbolize_map_values(dependency)
		}
		symbolized[key] = ruby.array_value(items)
	}
	return symbolized
}

pub fn formula_generator_process_dependencies(deps_hash map[string]ruby.Value) []ruby.Value {
	mut dependencies := formula_generator_array(deps_hash['dependencies'] or {
		ruby.array_value([])
	})
	for dependency_type in ['build', 'test', 'recommended', 'optional'] {
		key := '${dependency_type}_dependencies'
		for dependency in formula_generator_array(deps_hash[key] or {
			ruby.array_value([])
		}) {
			dependencies << ruby.map_value({
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

pub fn formula_generator_process_requirements(requirements_array []ruby.Value,
	spec string) []ruby.Value {
	mut requirements := []ruby.Value{}
	for requirement_value in requirements_array {
		requirement := formula_generator_map(requirement_value)
		specs := formula_generator_array(requirement['specs'] or {
			ruby.array_value([])
		}).map(it.as_string())
		if spec !in specs {
			continue
		}
		name := (requirement['name'] or { continue }).as_string().trim_string_left(':')
		if name !in formula_struct_generator_supported_requirements {
			continue
		}
		mut tags := []ruby.Value{}
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
			ruby.array_value([])
		}) {
			if context.type_name == 'String' {
				tags << formula_generator_symbol(context.as_string())
			} else if context.type_name == 'Hash' {
				mut transformed := map[string]ruby.Value{}
				for key, value in context.map_data {
					transformed[key.trim_string_left(':')] = value
				}
				tags << ruby.map_value(transformed)
			} else {
				tags << context
			}
		}
		if tags.len == 0 {
			requirements << formula_generator_symbol(name)
		} else {
			requirements << ruby.map_value({
				name: ruby.array_value(tags)
			})
		}
	}
	return requirements
}

pub fn formula_generator_process_uses_from_macos(deps_hash map[string]ruby.Value) []api.ApiStructArgPair {
	uses_from_macos := formula_generator_array(deps_hash['uses_from_macos'] or {
		ruby.array_value([])
	})
	bounds_array := formula_generator_array(deps_hash['uses_from_macos_bounds'] or {
		ruby.array_value([])
	})
	mut output := []api.ApiStructArgPair{}
	for index, item in uses_from_macos {
		mut bounds := map[string]ruby.Value{}
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
				first: ruby.map_value(dependency)
				second: ruby.map_value({})
			}
		} else {
			output << api.ApiStructArgPair{
				first: item
				second: ruby.map_value(bounds)
			}
		}
	}
	return output
}

pub fn formula_generator_process_dependencies_and_requirements(deps_hash ?map[string]ruby.Value,
	requirements_array ?[]ruby.Value, spec string) FormulaDependenciesResult {
	mut dependencies := []ruby.Value{}
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

fn formula_generator_arg_pair_value(pair api.ApiStructArgPair) ruby.Value {
	return ruby.array_value([pair.first, pair.second])
}

fn formula_generator_arg_pairs_value(pairs []api.ApiStructArgPair) ruby.Value {
	return ruby.array_value(pairs.map(formula_generator_arg_pair_value(it)))
}

fn formula_generator_compact_map(values map[string]ruby.Value) map[string]ruby.Value {
	mut compact := map[string]ruby.Value{}
	for key, value in values {
		if formula_generator_present(value) {
			compact[key] = value
		}
	}
	return compact
}

fn formula_generator_service_hash(service map[string]ruby.Value,
	paths api.ApiStructPaths) !map[string]ruby.Value {
	mut output := map[string]ruby.Value{}
	if name := service['name'] {
		output['name'] = formula_generator_deep_stringify_keys(name)
	}
	if run := service['run'] {
		if run.type_name == 'String' || run.type_name == 'Pathname' {
			output['run'] = ruby.string_value(homebrew.service_replace_placeholders(run.as_string(), paths.prefix, paths.cellar, paths.home))
		} else if run.type_name == 'Array' {
			output['run'] = ruby.array_value(formula_generator_array(run).map(ruby.string_value(homebrew.service_replace_placeholders(it.as_string(), paths.prefix, paths.cellar, paths.home))))
		} else if run.type_name == 'Hash' {
			mut commands := map[string]ruby.Value{}
			for key, command in run.map_data {
				commands[key.trim_string_left(':')] = if command.type_name == 'Array' {
					ruby.array_value(formula_generator_array(command).map(ruby.string_value(homebrew.service_replace_placeholders(it.as_string(), paths.prefix, paths.cellar, paths.home))))
				} else {
					ruby.string_value(homebrew.service_replace_placeholders(command.as_string(), paths.prefix, paths.cellar, paths.home))
				}
			}
			output['run'] = ruby.map_value(commands)
		} else {
			return error('Unexpected run command: ${run.as_string()}')
		}
	} else {
		return output
	}
	if environment := service['environment_variables'] {
		mut variables := map[string]ruby.Value{}
		for key, value in formula_generator_map(environment) {
			variables[key.trim_string_left(':')] = ruby.string_value(homebrew.service_replace_placeholders(value.as_string(), paths.prefix, paths.cellar, paths.home))
		}
		output['environment_variables'] = ruby.map_value(variables)
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
				output[key] = ruby.string_value(homebrew.service_replace_placeholders(value.as_string(), paths.prefix, paths.cellar, paths.home))
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

fn formula_generator_merge_variations(input map[string]ruby.Value,
	bottle_tag string) map[string]ruby.Value {
	value := if bottle_tag == '' {
		homebrew.ruby_api_l194_d4_self_merge_variations(ruby.map_value(input))
	} else {
		homebrew.ruby_api_l194_d4_self_merge_variations(ruby.map_value(input), ruby.string_value(bottle_tag))
	}
	return formula_generator_map(formula_generator_deep_stringify_keys(value))
}

pub fn formula_generator_generate_formula_struct_hash(input map[string]ruby.Value,
	options FormulaStructGeneratorOptions) !api.FormulaStruct {
	mut hash := formula_generator_merge_variations(input, options.bottle_tag)
	if caveats := hash['caveats'] {
		if formula_generator_truthy(caveats) {
			hash['caveats'] = ruby.string_value(homebrew.replace_formula_placeholders(caveats.as_string(), options.paths.prefix, options.paths.cellar, options.paths.home))
		}
	}
	files := formula_generator_map(formula_generator_dig(hash, 'bottle', 'stable', 'files'))
	mut bottle_checksums := []ruby.Value{}
	for tag, specification_value in files {
		specification := formula_generator_map(specification_value)
		cellar := specification['cellar'] or { return error('key not found: cellar') }
		checksum := specification['sha256'] or { return error('key not found: sha256') }
		bottle_checksums << ruby.map_value({
			'cellar': homebrew.convert_to_string_or_symbol(cellar.as_string())
			tag:      checksum
		})
	}
	hash['bottle_checksums'] = ruby.array_value(bottle_checksums)
	hash['bottle_rebuild'] = formula_generator_dig(hash, 'bottle', 'stable', 'rebuild')
	conflict_names := formula_generator_array(hash['conflicts_with'] or {
		ruby.array_value([])
	})
	conflict_reasons := formula_generator_array(hash['conflicts_with_reasons'] or {
		ruby.array_value([])
	})
	mut conflicts := []ruby.Value{}
	for index, name in conflict_names {
		reason := if index < conflict_reasons.len {
			conflict_reasons[index]
		} else {
			formula_generator_nil()
		}
		arguments := if formula_generator_present(reason) {
			ruby.map_value({
				'because': reason
			})
		} else {
			ruby.map_value({})
		}
		conflicts << ruby.array_value([name, arguments])
	}
	hash['conflicts'] = ruby.array_value(conflicts)
	for key in ['deprecate_args', 'disable_args'] {
		if arguments_value := hash[key] {
			if formula_generator_truthy(arguments_value) {
				mut arguments := formula_generator_map(arguments_value)
				if because := arguments['because'] {
					arguments['because'] = homebrew.ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(because, formula_generator_symbol('formula'))
				}
				hash[key] = ruby.map_value(arguments)
			}
		}
	}
	head_url := formula_generator_dig(hash, 'urls', 'head', 'url')
	mut head_specs := map[string]ruby.Value{}
	head_specs['branch'] = formula_generator_dig(hash, 'urls', 'head', 'branch')
	head_using := formula_generator_dig(hash, 'urls', 'head', 'using')
	if formula_generator_present(head_using) {
		head_specs['using'] = formula_generator_symbol(head_using.as_string())
	}
	hash['head_url_args'] = ruby.array_value([
		if head_url.type_name == 'NilClass' { ruby.string_value('') } else { head_url },
		ruby.map_value(formula_generator_compact_map(head_specs)),
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
			hash['keg_only_args'] = ruby.array_value(arguments)
		}
	}
	license := (hash['license'] or { formula_generator_nil() }).as_string()
	if expression := utils.string_to_spdx_license_expression(license) {
		hash['license'] = ruby.string_value(utils.spdx_license_expression_to_string(expression, false))
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
			hash['no_autobump_args'] = ruby.map_value({
				'because': effective_reason
			})
		}
	}
	if condition := hash['pour_bottle_only_if'] {
		if formula_generator_truthy(condition) {
			hash['pour_bottle_args'] = ruby.map_value({
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
				hash['service_run_args'] = ruby.array_value([])
				hash['service_run_kwargs'] = run
			} else if run.type_name == 'Array' || run.type_name == 'String' {
				hash['service_run_args'] = ruby.array_value([run])
				hash['service_run_kwargs'] = ruby.map_value({})
			} else {
				hash['service_run_args'] = ruby.array_value([])
				hash['service_run_kwargs'] = ruby.map_value({})
			}
			hash['service_name_args'] = service['name'] or { formula_generator_nil() }
			mut service_args := []ruby.Value{}
			for key, value in service {
				if key != 'name' && key != 'run' {
					service_args << ruby.array_value([
						formula_generator_symbol(key),
						value,
					])
				}
			}
			hash['service_args'] = ruby.array_value(service_args)
		}
	}
	hash['stable_checksum'] = formula_generator_dig(hash, 'urls', 'stable', 'checksum')
	stable_url := formula_generator_dig(hash, 'urls', 'stable', 'url')
	mut stable_specs := map[string]ruby.Value{}
	stable_specs['tag'] = formula_generator_dig(hash, 'urls', 'stable', 'tag')
	stable_specs['revision'] = formula_generator_dig(hash, 'urls', 'stable', 'revision')
	stable_using := formula_generator_dig(hash, 'urls', 'stable', 'using')
	if formula_generator_present(stable_using) {
		stable_specs['using'] = formula_generator_symbol(stable_using.as_string())
	}
	hash['stable_url_args'] = ruby.array_value([
		stable_url,
		ruby.map_value(formula_generator_compact_map(stable_specs)),
	])
	hash['stable_version'] = formula_generator_dig(hash, 'versions', 'stable')
	hash['requirements_array'] = hash['requirements'] or { formula_generator_nil() }
	mut stable_dependency_hash := map[string]ruby.Value{}
	for key in ['dependencies', 'build_dependencies', 'test_dependencies', 'recommended_dependencies',
		'optional_dependencies', 'uses_from_macos', 'uses_from_macos_bounds'] {
		stable_dependency_hash[key] = hash[key] or { ruby.array_value([]) }
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
	hash['stable_dependencies'] = ruby.array_value(stable_result.dependencies)
	hash['stable_patches'] = hash['patches'] or { ruby.array_value([]) }
	hash['stable_uses_from_macos'] = formula_generator_arg_pairs_value(stable_result.uses_from_macos)
	hash['head_dependencies'] = ruby.array_value(head_result.dependencies)
	hash['head_uses_from_macos'] = formula_generator_arg_pairs_value(head_result.uses_from_macos)
	hash['bottle_present'] = ruby.bool_value(formula_generator_present(hash['bottle'] or {
		formula_generator_nil()
	}))
	hash['deprecate_present'] = ruby.bool_value(formula_generator_present(hash['deprecate_args'] or {
		formula_generator_nil()
	}))
	hash['disable_present'] = ruby.bool_value(formula_generator_present(hash['disable_args'] or {
		formula_generator_nil()
	}))
	hash['head_present'] = ruby.bool_value(formula_generator_present(formula_generator_dig(hash, 'urls', 'head')))
	hash['keg_only_present'] = ruby.bool_value(formula_generator_present(hash['keg_only_reason'] or {
		formula_generator_nil()
	}))
	hash['no_autobump_present'] = ruby.bool_value(formula_generator_present(hash['no_autobump_message'] or {
		formula_generator_nil()
	}))
	hash['pour_bottle_present'] = ruby.bool_value(formula_generator_present(hash['pour_bottle_only_if'] or {
		formula_generator_nil()
	}))
	hash['service_present'] = ruby.bool_value(formula_generator_present(hash['service'] or {
		formula_generator_nil()
	}))
	hash['service_run_present'] = ruby.bool_value(formula_generator_present(formula_generator_dig(hash, 'service', 'run')))
	hash['service_name_present'] = ruby.bool_value(formula_generator_present(formula_generator_dig(hash, 'service', 'name')))
	hash['stable_present'] = ruby.bool_value(formula_generator_present(formula_generator_dig(hash, 'urls', 'stable')))
	return api.formula_struct_from_hash(hash, options.paths)
}
