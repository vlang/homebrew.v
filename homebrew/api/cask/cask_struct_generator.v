module cask

import ruby
import homebrew
import homebrew.api

// Translated from Homebrew/brew `api/cask/cask_struct_generator.rb`.

pub struct CaskStructGeneratorOptions {
pub:
	bottle_tag   string
	paths        api.ApiStructPaths
	ignore_types bool
}

struct CaskGeneratorLanguageStruct {
	variation map[string]ruby.Value
	cask      api.CaskStruct
}

fn cask_generator_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn cask_generator_symbol(value string) ruby.Value {
	return ruby.object_value('Symbol', value.trim_space().trim_string_left(':'))
}

fn cask_generator_array(value ruby.Value) []ruby.Value {
	return value.as_array() or { []ruby.Value{} }
}

fn cask_generator_map(value ruby.Value) map[string]ruby.Value {
	return value.as_map() or { map[string]ruby.Value{} }
}

fn cask_generator_present(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

fn cask_generator_deep_normalize_keys(value ruby.Value) ruby.Value {
	if value.type_name == 'Array' {
		return ruby.array_value(cask_generator_array(value).map(cask_generator_deep_normalize_keys(it)))
	}
	if value.type_name == 'Hash' {
		mut normalized := map[string]ruby.Value{}
		for key, item in value.map_data {
			normalized[key.trim_string_left(':')] = cask_generator_deep_normalize_keys(item)
		}
		return ruby.map_value(normalized)
	}
	return value
}

fn cask_generator_merge_variations(input map[string]ruby.Value,
	bottle_tag string) map[string]ruby.Value {
	merged := if bottle_tag == '' {
		homebrew.ruby_api_l194_d4_self_merge_variations(ruby.map_value(input))
	} else {
		homebrew.ruby_api_l194_d4_self_merge_variations(ruby.map_value(input), ruby.string_value(bottle_tag))
	}
	return cask_generator_map(cask_generator_deep_normalize_keys(merged))
}

fn cask_generator_macos_symbol(version string) ?string {
	normalized := version.trim_space().trim_string_left(':')
	versions := homebrew.macos_symbol_versions()
	if normalized in versions {
		return normalized
	}
	for symbol, number in versions {
		if number == normalized {
			return symbol
		}
	}
	return none
}

fn cask_generator_requirement_hash(value ruby.Value) map[string]ruby.Value {
	if value.type_name != 'MacOSRequirement' {
		return cask_generator_map(cask_generator_deep_normalize_keys(value))
	}
	versions := cask_generator_array(value.map_data['versions'] or {
		ruby.array_value([])
	})
	if versions.len == 0 {
		return map[string]ruby.Value{}
	}
	comparator := (value.map_data['comparator'] or {
		ruby.string_value('>=')
	}).as_string()
	return {
		comparator: ruby.array_value(versions)
	}
}

pub fn cask_generator_process_depends_on(depends_on map[string]ruby.Value) map[string]ruby.Value {
	mut processed := map[string]ruby.Value{}
	for raw_key, raw_value in depends_on {
		key := raw_key.trim_string_left(':')
		if key == 'arch' {
			architectures := cask_generator_array(raw_value)
			kind := if architectures.len > 0 {
				(cask_generator_map(architectures[0])['type'] or {
					ruby.string_value('arm64')
				}).as_string().trim_string_left(':')
			} else {
				'arm64'
			}
			processed[key] = cask_generator_symbol(if kind == 'intel' { 'intel' } else { 'arm64' })
			continue
		}
		if key == 'linux' {
			processed[key] = cask_generator_symbol('any')
			continue
		}
		if key !in ['macos', 'maximum_macos'] {
			processed[key] = raw_value
			continue
		}
		value := cask_generator_requirement_hash(raw_value)
		if value.len == 0 {
			processed[key] = cask_generator_symbol('any')
			continue
		}
		dep_type := value.keys()[0].trim_string_left(':')
		versions := cask_generator_array(value[value.keys()[0]])
		if dep_type == '==' {
			mut symbols := []ruby.Value{}
			for version in versions {
				if symbol := cask_generator_macos_symbol(version.as_string()) {
					symbols << cask_generator_symbol(symbol)
				}
			}
			if symbols.len > 0 {
				processed[key] = ruby.array_value(symbols)
			}
			continue
		}
		if versions.len == 0 || !cask_generator_present(versions[0]) {
			processed[key] = cask_generator_symbol('any')
			continue
		}
		if symbol := cask_generator_macos_symbol(versions[0].as_string()) {
			processed[key] = if dep_type in ['>=', '<='] {
				cask_generator_symbol(symbol)
			} else {
				ruby.string_value('${dep_type} :${symbol}')
			}
		}
	}
	return processed
}

pub fn cask_generator_process_artifacts(artifacts []ruby.Value) []api.CaskArtifact {
	mut processed := []api.CaskArtifact{}
	for artifact_value in artifacts {
		artifact := cask_generator_map(artifact_value)
		mut key := ''
		for candidate, _ in artifact {
			if candidate.trim_string_left(':') != 'target' {
				key = candidate.trim_string_left(':')
				break
			}
		}
		if key == '' {
			continue
		}
		value := artifact[key] or { artifact[':${key}'] or { cask_generator_nil() } }
		if value.type_name == 'NilClass' {
			processed << api.CaskArtifact{
				key: key
				has_block: true
			}
			continue
		}
		mut arguments := cask_generator_array(value)
		mut keyword_arguments := map[string]ruby.Value{}
		if arguments.len > 0 && arguments.last().type_name == 'Hash' {
			keyword_arguments = cask_generator_map(arguments.last())
			arguments = arguments[..arguments.len - 1].clone()
		}
		processed << api.CaskArtifact{
			key: key
			args: arguments
			kwargs: keyword_arguments
		}
	}
	return processed
}

pub fn cask_generator_process_url_specs(url_specs map[string]ruby.Value) map[string]ruby.Value {
	mut processed := map[string]ruby.Value{}
	for raw_key, raw_value in url_specs {
		key := raw_key.trim_string_left(':')
		value := match key {
			'user_agent' { homebrew.convert_to_string_or_symbol(raw_value.as_string()) }
			'using' { cask_generator_symbol(raw_value.as_string()) }
			else { raw_value }
		}
		if cask_generator_present(value) {
			processed[key] = value
		}
	}
	return processed
}

fn cask_generator_artifacts_value(artifacts []api.CaskArtifact) ruby.Value {
	mut values := []ruby.Value{}
	for artifact in artifacts {
		values << ruby.array_value([
			cask_generator_symbol(artifact.key),
			ruby.array_value(artifact.args),
			ruby.map_value(artifact.kwargs),
			if artifact.has_block {
				cask_generator_symbol('empty_block')
			} else {
				cask_generator_nil()
			},
		])
	}
	return ruby.array_value(values)
}

pub fn cask_generator_generate_cask_struct_hash(input map[string]ruby.Value,
	options CaskStructGeneratorOptions) api.CaskStruct {
	mut hash := cask_generator_merge_variations(input, options.bottle_tag)
	language_variations := cask_generator_array(hash['language_variations'] or {
		ruby.array_value([])
	})
	hash.delete('language_variations')
	mut language_structs := []CaskGeneratorLanguageStruct{}
	for variation_value in language_variations {
		variation := cask_generator_map(variation_value)
		mut language_hash := hash.clone()
		for key, value in variation {
			if key.trim_string_left(':') !in ['languages', 'default', 'value'] {
				language_hash[key.trim_string_left(':')] = value
			}
		}
		language_structs << CaskGeneratorLanguageStruct{
			variation: variation
			cask: cask_generator_generate_cask_struct_hash(language_hash, options)
		}
	}

	hash['conflicts_with_args'] = if conflicts := hash['conflicts_with'] {
		ruby.map_value(cask_generator_map(conflicts))
	} else {
		cask_generator_nil()
	}
	hash['container_args'] = if container := hash['container'] {
		mut arguments := cask_generator_map(container)
		if container_type := arguments['type'] {
			arguments['type'] = cask_generator_symbol(container_type.as_string())
		}
		ruby.map_value(arguments)
	} else {
		cask_generator_nil()
	}
	if depends_on := hash['depends_on'] {
		hash['depends_on_args'] = ruby.map_value(cask_generator_process_depends_on(cask_generator_map(depends_on)))
	}
	for key in ['deprecate_args', 'disable_args'] {
		if arguments_value := hash[key] {
			if arguments_value.type_name != 'NilClass' {
				mut arguments := cask_generator_map(arguments_value)
				arguments['because'] = homebrew.ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(arguments['because'] or {
					cask_generator_nil()
				}, cask_generator_symbol('cask'))
				hash[key] = ruby.map_value(arguments)
			}
		}
	}
	hash['names'] = hash['name'] or { cask_generator_nil() }
	if artifacts := hash['artifacts'] {
		hash['raw_artifacts'] = cask_generator_artifacts_value(cask_generator_process_artifacts(cask_generator_array(artifacts)))
	}
	hash['raw_caveats'] = hash['caveats'] or { cask_generator_nil() }
	if renames := hash['rename'] {
		mut pairs := []ruby.Value{}
		for operation_value in cask_generator_array(renames) {
			operation := cask_generator_map(operation_value)
			pairs << ruby.array_value([
				operation['from'] or { cask_generator_nil() },
				operation['to'] or { cask_generator_nil() },
			])
		}
		hash['renames'] = ruby.array_value(pairs)
	} else {
		hash['renames'] = cask_generator_nil()
	}
	checksum := if checksum_hash := hash['ruby_source_checksum'] {
		cask_generator_map(checksum_hash)['sha256'] or { cask_generator_nil() }
	} else {
		cask_generator_nil()
	}
	if checksum.type_name == 'NilClass' {
		hash.delete('ruby_source_checksum')
	} else {
		hash['ruby_source_checksum'] = ruby.map_value({
			'sha256': checksum
		})
	}
	if path := hash['ruby_source_path'] {
		if path.type_name != 'NilClass' {
			hash['ruby_source_path'] = ruby.string_value(path.as_string())
		}
	}
	sha256 := ruby.string_value((hash['sha256'] or { cask_generator_nil() }).as_string())
	hash['sha256'] = if sha256.as_string() == 'no_check' {
		cask_generator_symbol('no_check')
	} else {
		sha256
	}
	hash['tap_string'] = hash['tap'] or { cask_generator_nil() }
	hash['url_args'] = ruby.string_array_value([(hash['url'] or {
		cask_generator_nil()
	}).as_string()])
	if url_specs := hash['url_specs'] {
		hash['url_kwargs'] = ruby.map_value(cask_generator_process_url_specs(cask_generator_map(url_specs)))
	}
	for predicate, source in {
		'auto_updates': hash['auto_updates'] or { cask_generator_nil() }
		'caveats':      hash['caveats'] or { cask_generator_nil() }
		'conflicts':    hash['conflicts_with'] or { cask_generator_nil() }
		'container':    hash['container'] or { cask_generator_nil() }
		'depends_on':   hash['depends_on_args'] or { cask_generator_nil() }
		'deprecate':    hash['deprecate_args'] or { cask_generator_nil() }
		'desc':         hash['desc'] or { cask_generator_nil() }
		'disable':      hash['disable_args'] or { cask_generator_nil() }
		'homepage':     hash['homepage'] or { cask_generator_nil() }
	} {
		hash['${predicate}_present'] = ruby.bool_value(cask_generator_present(source))
	}
	cask_struct := api.cask_struct_from_hash(hash, options.paths, options.ignore_types)
	if language_structs.len == 0 {
		return cask_struct
	}
	serialized_cask := cask_struct.serialize()
	mut processed_variations := []ruby.Value{}
	for generated in language_structs {
		mut overrides := map[string]ruby.Value{}
		for key, value in generated.cask.serialize() {
			base_value := serialized_cask[key] or { cask_generator_nil() }
			if !api.api_struct_value_equal(base_value, value) {
				overrides[key] = value
			}
		}
		processed_variations << ruby.map_value({
			'languages': generated.variation['languages'] or { ruby.array_value([]) }
			'default':   ruby.bool_value((generated.variation['default'] or {
				ruby.bool_value(false)
			}).type_name == 'Bool' && (generated.variation['default'] or {
				ruby.bool_value(false)
			}).bool_data)
			'value':     generated.variation['value'] or { cask_generator_nil() }
			'overrides': ruby.map_value(overrides)
		})
	}
	mut serialized_with_languages := serialized_cask.clone()
	serialized_with_languages['language_variations'] = ruby.array_value(processed_variations)
	return api.cask_struct_deserialize(serialized_with_languages, options.paths)
}
