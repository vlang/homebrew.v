module cask

import brew_runtime
import homebrew
import homebrew.api

// Translated from Homebrew/brew `api/cask/cask_struct_generator.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct CaskStructGeneratorOptions {
pub:
	bottle_tag   string
	paths        api.ApiStructPaths
	ignore_types bool
}

struct CaskGeneratorLanguageStruct {
	variation map[string]brew_runtime.Value
	cask      api.CaskStruct
}

fn cask_generator_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn cask_generator_symbol(value string) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', value.trim_space().trim_string_left(':'))
}

fn cask_generator_array(value brew_runtime.Value) []brew_runtime.Value {
	return value.as_array() or { []brew_runtime.Value{} }
}

fn cask_generator_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	return value.as_map() or { map[string]brew_runtime.Value{} }
}

fn cask_generator_present(value brew_runtime.Value) bool {
	return match value.type_name {
		'NilClass' { false }
		'Bool' { value.bool_data }
		'String' { value.as_string() != '' }
		'Array' { value.array_data.len > 0 || value.string_array_data.len > 0 }
		'Hash' { value.map_data.len > 0 }
		else { true }
	}
}

fn cask_generator_deep_normalize_keys(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Array' {
		return brew_runtime.array_value(cask_generator_array(value).map(cask_generator_deep_normalize_keys(it)))
	}
	if value.type_name == 'Hash' {
		mut normalized := map[string]brew_runtime.Value{}
		for key, item in value.map_data {
			normalized[key.trim_string_left(':')] = cask_generator_deep_normalize_keys(item)
		}
		return brew_runtime.map_value(normalized)
	}
	return value
}

fn cask_generator_merge_variations(input map[string]brew_runtime.Value,
	bottle_tag string) map[string]brew_runtime.Value {
	merged := if bottle_tag == '' {
		homebrew.ruby_api_l194_d4_self_merge_variations(brew_runtime.map_value(input))
	} else {
		homebrew.ruby_api_l194_d4_self_merge_variations(brew_runtime.map_value(input), brew_runtime.string_value(bottle_tag))
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

fn cask_generator_requirement_hash(value brew_runtime.Value) map[string]brew_runtime.Value {
	if value.type_name != 'MacOSRequirement' {
		return cask_generator_map(cask_generator_deep_normalize_keys(value))
	}
	versions := cask_generator_array(value.map_data['versions'] or {
		brew_runtime.array_value([])
	})
	if versions.len == 0 {
		return map[string]brew_runtime.Value{}
	}
	comparator := (value.map_data['comparator'] or {
		brew_runtime.string_value('>=')
	}).as_string()
	return {
		comparator: brew_runtime.array_value(versions)
	}
}

pub fn cask_generator_process_depends_on(depends_on map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut processed := map[string]brew_runtime.Value{}
	for raw_key, raw_value in depends_on {
		key := raw_key.trim_string_left(':')
		if key == 'arch' {
			architectures := cask_generator_array(raw_value)
			kind := if architectures.len > 0 {
				(cask_generator_map(architectures[0])['type'] or {
					brew_runtime.string_value('arm64')
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
			mut symbols := []brew_runtime.Value{}
			for version in versions {
				if symbol := cask_generator_macos_symbol(version.as_string()) {
					symbols << cask_generator_symbol(symbol)
				}
			}
			if symbols.len > 0 {
				processed[key] = brew_runtime.array_value(symbols)
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
				brew_runtime.string_value('${dep_type} :${symbol}')
			}
		}
	}
	return processed
}

pub fn cask_generator_process_artifacts(artifacts []brew_runtime.Value) []api.CaskArtifact {
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
		mut keyword_arguments := map[string]brew_runtime.Value{}
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

pub fn cask_generator_process_url_specs(url_specs map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut processed := map[string]brew_runtime.Value{}
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

fn cask_generator_artifacts_value(artifacts []api.CaskArtifact) brew_runtime.Value {
	mut values := []brew_runtime.Value{}
	for artifact in artifacts {
		values << brew_runtime.array_value([
			cask_generator_symbol(artifact.key),
			brew_runtime.array_value(artifact.args),
			brew_runtime.map_value(artifact.kwargs),
			if artifact.has_block {
				cask_generator_symbol('empty_block')
			} else {
				cask_generator_nil()
			},
		])
	}
	return brew_runtime.array_value(values)
}

pub fn cask_generator_generate_cask_struct_hash(input map[string]brew_runtime.Value,
	options CaskStructGeneratorOptions) api.CaskStruct {
	mut hash := cask_generator_merge_variations(input, options.bottle_tag)
	language_variations := cask_generator_array(hash['language_variations'] or {
		brew_runtime.array_value([])
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
		brew_runtime.map_value(cask_generator_map(conflicts))
	} else {
		cask_generator_nil()
	}
	hash['container_args'] = if container := hash['container'] {
		mut arguments := cask_generator_map(container)
		if container_type := arguments['type'] {
			arguments['type'] = cask_generator_symbol(container_type.as_string())
		}
		brew_runtime.map_value(arguments)
	} else {
		cask_generator_nil()
	}
	if depends_on := hash['depends_on'] {
		hash['depends_on_args'] = brew_runtime.map_value(cask_generator_process_depends_on(cask_generator_map(depends_on)))
	}
	for key in ['deprecate_args', 'disable_args'] {
		if arguments_value := hash[key] {
			if arguments_value.type_name != 'NilClass' {
				mut arguments := cask_generator_map(arguments_value)
				arguments['because'] = homebrew.ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(arguments['because'] or {
					cask_generator_nil()
				}, cask_generator_symbol('cask'))
				hash[key] = brew_runtime.map_value(arguments)
			}
		}
	}
	hash['names'] = hash['name'] or { cask_generator_nil() }
	if artifacts := hash['artifacts'] {
		hash['raw_artifacts'] = cask_generator_artifacts_value(cask_generator_process_artifacts(cask_generator_array(artifacts)))
	}
	hash['raw_caveats'] = hash['caveats'] or { cask_generator_nil() }
	if renames := hash['rename'] {
		mut pairs := []brew_runtime.Value{}
		for operation_value in cask_generator_array(renames) {
			operation := cask_generator_map(operation_value)
			pairs << brew_runtime.array_value([
				operation['from'] or { cask_generator_nil() },
				operation['to'] or { cask_generator_nil() },
			])
		}
		hash['renames'] = brew_runtime.array_value(pairs)
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
		hash['ruby_source_checksum'] = brew_runtime.map_value({
			'sha256': checksum
		})
	}
	if path := hash['ruby_source_path'] {
		if path.type_name != 'NilClass' {
			hash['ruby_source_path'] = brew_runtime.string_value(path.as_string())
		}
	}
	sha256 := brew_runtime.string_value((hash['sha256'] or { cask_generator_nil() }).as_string())
	hash['sha256'] = if sha256.as_string() == 'no_check' {
		cask_generator_symbol('no_check')
	} else {
		sha256
	}
	hash['tap_string'] = hash['tap'] or { cask_generator_nil() }
	hash['url_args'] = brew_runtime.string_array_value([(hash['url'] or {
		cask_generator_nil()
	}).as_string()])
	if url_specs := hash['url_specs'] {
		hash['url_kwargs'] = brew_runtime.map_value(cask_generator_process_url_specs(cask_generator_map(url_specs)))
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
		hash['${predicate}_present'] = brew_runtime.bool_value(cask_generator_present(source))
	}
	cask_struct := api.cask_struct_from_hash(hash, options.paths, options.ignore_types)
	if language_structs.len == 0 {
		return cask_struct
	}
	serialized_cask := cask_struct.serialize()
	mut processed_variations := []brew_runtime.Value{}
	for generated in language_structs {
		mut overrides := map[string]brew_runtime.Value{}
		for key, value in generated.cask.serialize() {
			base_value := serialized_cask[key] or { cask_generator_nil() }
			if !api.api_struct_value_equal(base_value, value) {
				overrides[key] = value
			}
		}
		processed_variations << brew_runtime.map_value({
			'languages': generated.variation['languages'] or { brew_runtime.array_value([]) }
			'default':   brew_runtime.bool_value((generated.variation['default'] or {
				brew_runtime.bool_value(false)
			}).type_name == 'Bool' && (generated.variation['default'] or {
				brew_runtime.bool_value(false)
			}).bool_data)
			'value':     generated.variation['value'] or { cask_generator_nil() }
			'overrides': brew_runtime.map_value(overrides)
		})
	}
	mut serialized_with_languages := serialized_cask.clone()
	serialized_with_languages['language_variations'] = brew_runtime.array_value(processed_variations)
	return api.cask_struct_deserialize(serialized_with_languages, options.paths)
}

// Ruby method `generate_cask_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag, ignore_types: false)` at line 14.
pub fn ruby_cask_struct_generator_l14_d1_generate_cask_struct_hash(hash map[string]brew_runtime.Value,
	options CaskStructGeneratorOptions) api.CaskStruct {
	return cask_generator_generate_cask_struct_hash(hash, options)
}

// Ruby method `process_depends_on(depends_on)` at line 110.
pub fn ruby_cask_struct_generator_l110_d2_process_depends_on(depends_on map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	return cask_generator_process_depends_on(depends_on)
}

// Ruby method `process_artifacts(artifacts)` at line 146.
pub fn ruby_cask_struct_generator_l146_d3_process_artifacts(artifacts []brew_runtime.Value) []api.CaskArtifact {
	return cask_generator_process_artifacts(artifacts)
}

// Ruby method `process_url_specs(url_specs)` at line 165.
pub fn ruby_cask_struct_generator_l165_d4_process_url_specs(url_specs map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	return cask_generator_process_url_specs(url_specs)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module API
// 6:     module Cask
// 7:       # Methods for generating CaskStruct instances from API data.
// 8:       module CaskStructGenerator
// 9:         module_function
// 10:
// 11:         # NOTE: this will be used to load installed cask JSON files,
// 12:         # so it must never fail with older JSON API versions
// 13:         sig { params(hash: T::Hash[String, T.untyped], bottle_tag: Utils::Bottles::Tag, ignore_types: T::Boolean).returns(CaskStruct) }
// 14:         def generate_cask_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag, ignore_types: false)
// 15:           hash = Homebrew::API.merge_variations(hash, bottle_tag:).dup.deep_symbolize_keys.transform_keys(&:to_s)
// 16:           language_variations = T.cast(
// 17:             hash.delete("language_variations"),
// 18:             T.nilable(T::Array[T::Hash[Symbol, T.untyped]]),
// 19:           )
// 20:           language_structs = language_variations&.map do |variation|
// 21:             language_hash = hash.merge(variation.except(:languages, :default, :value).transform_keys(&:to_s))
// 22:             [variation, generate_cask_struct_hash(language_hash, bottle_tag:, ignore_types:)]
// 23:           end
// 24:
// 25:           hash["conflicts_with_args"] = hash["conflicts_with"]&.to_h
// 26:
// 27:           hash["container_args"] = hash["container"]&.to_h do |key, value|
// 28:             next [key, value.to_sym] if key == :type
// 29:
// 30:             [key, value]
// 31:           end
// 32:
// 33:           if (depends_on = hash["depends_on"])
// 34:             hash["depends_on_args"] = process_depends_on(depends_on)
// 35:           end
// 36:
// 37:           if (deprecate_args = hash["deprecate_args"])
// 38:             deprecate_args = deprecate_args.dup
// 39:             deprecate_args[:because] =
// 40:               DeprecateDisable.to_reason_string_or_symbol(deprecate_args[:because], type: :cask)
// 41:             hash["deprecate_args"] = deprecate_args
// 42:           end
// 43:
// 44:           if (disable_args = hash["disable_args"])
// 45:             disable_args = disable_args.dup
// 46:             disable_args[:because] = DeprecateDisable.to_reason_string_or_symbol(disable_args[:because], type: :cask)
// 47:             hash["disable_args"] = disable_args
// 48:           end
// 49:
// 50:           hash["names"] = hash["name"]
// 51:
// 52:           if (artifacts = hash["artifacts"])
// 53:             hash["raw_artifacts"] = process_artifacts(artifacts)
// 54:           end
// 55:
// 56:           hash["raw_caveats"] = hash["caveats"]
// 57:
// 58:           hash["renames"] = hash["rename"]&.map do |operation|
// 59:             [operation[:from], operation[:to]]
// 60:           end
// 61:
// 62:           hash["ruby_source_checksum"] = {
// 63:             sha256: hash.dig("ruby_source_checksum", :sha256),
// 64:           }.compact
// 65:
// 66:           hash["ruby_source_path"] = hash["ruby_source_path"]&.to_s
// 67:
// 68:           hash["sha256"] = hash["sha256"].to_s
// 69:           hash["sha256"] = :no_check if hash["sha256"] == "no_check"
// 70:
// 71:           hash["tap_string"] = hash["tap"]
// 72:
// 73:           hash["url_args"] = [hash["url"].to_s]
// 74:
// 75:           if (url_specs = hash["url_specs"])
// 76:             hash["url_kwargs"] = process_url_specs(url_specs)
// 77:           end
// 78:
// 79:           # Should match CaskStruct::PREDICATES
// 80:           hash["auto_updates_present"] = hash["auto_updates"].present?
// 81:           hash["caveats_present"] = hash["caveats"].present?
// 82:           hash["conflicts_present"] = hash["conflicts_with"].present?
// 83:           hash["container_present"] = hash["container"].present?
// 84:           hash["depends_on_present"] = hash["depends_on_args"].present?
// 85:           hash["deprecate_present"] = hash["deprecate_args"].present?
// 86:           hash["desc_present"] = hash["desc"].present?
// 87:           hash["disable_present"] = hash["disable_args"].present?
// 88:           hash["homepage_present"] = hash["homepage"].present?
// 89:
// 90:           cask_struct = CaskStruct.from_hash(hash, ignore_types:)
// 91:           return cask_struct if language_structs.blank?
// 92:
// 93:           serialised_cask = cask_struct.serialize
// 94:           processed_language_variations = language_structs.map do |variation, language_struct|
// 95:             language_data = language_struct.serialize.reject do |key, value|
// 96:               serialised_cask[key] == value
// 97:             end
// 98:             {
// 99:               languages: T.cast(variation[:languages], T::Array[String]),
// 100:               default:   variation[:default] == true,
// 101:               value:     T.cast(variation[:value], T.nilable(String)),
// 102:               overrides: language_data,
// 103:             }
// 104:           end
// 105:
// 106:           CaskStruct.deserialize(serialised_cask.merge("language_variations" => processed_language_variations))
// 107:         end
// 108:
// 109:         sig { params(depends_on: T::Hash[Symbol, T.untyped]).returns(CaskStruct::DependsOnArgs) }
// 110:         def process_depends_on(depends_on)
// 111:           depends_on.to_h do |key, value|
// 112:             # Arch dependencies are encoded like `{ type: :intel, bits: 64 }`
// 113:             # but `depends_on arch:` only accepts `:intel` or `:arm64`
// 114:             if key == :arch
// 115:               next [:arch, :intel] if value.first[:type].to_sym == :intel
// 116:
// 117:               next [:arch, :arm64]
// 118:             end
// 119:             next [key, :any] if key == :linux
// 120:
// 121:             next [key, value] unless [:macos, :maximum_macos].include?(key)
// 122:
// 123:             value = value.to_h if value.is_a?(MacOSRequirement)
// 124:             dep_type = value.keys.first
// 125:             next [key, :any] unless dep_type
// 126:
// 127:             if dep_type.to_sym == :==
// 128:               version_symbols = value[dep_type].filter_map do |version|
// 129:                 MacOSVersion::SYMBOLS.key(version)
// 130:               end
// 131:               next [key, version_symbols.presence]
// 132:             end
// 133:
// 134:             version_symbol = value[dep_type].first
// 135:             next [key, :any] if version_symbol.blank?
// 136:
// 137:             version_symbol = MacOSVersion::SYMBOLS.key(version_symbol)
// 138:             next [key, version_symbol] if [:>=, :<=].include?(dep_type.to_sym) && version_symbol
// 139:
// 140:             version_dep = "#{dep_type} :#{version_symbol}" if version_symbol
// 141:             [key, version_dep]
// 142:           end.compact
// 143:         end
// 144:
// 145:         sig { params(artifacts: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[CaskStruct::ArtifactArgs]) }
// 146:         def process_artifacts(artifacts)
// 147:           artifacts.map do |artifact|
// 148:             key = T.must(artifact.keys.find { |artifact_key| artifact_key != :target })
// 149:
// 150:             # Pass an empty block to artifacts like postflight that can't be loaded from the API,
// 151:             # but need to be set to something.
// 152:             next [key, [], {}, Homebrew::API::CaskStruct::EMPTY_BLOCK] if artifact[key].nil?
// 153:
// 154:             args = artifact[key]
// 155:             kwargs = if args.last.is_a?(Hash)
// 156:               args.pop
// 157:             else
// 158:               {}
// 159:             end
// 160:             [key, args, kwargs, nil]
// 161:           end
// 162:         end
// 163:
// 164:         sig { params(url_specs: T::Hash[Symbol, T.untyped]).returns(T::Hash[Symbol, T.anything]) }
// 165:         def process_url_specs(url_specs)
// 166:           url_specs.to_h do |key, value|
// 167:             value = case key
// 168:             when :user_agent
// 169:               Utils.convert_to_string_or_symbol(value)
// 170:             when :using
// 171:               value.to_sym
// 172:             else
// 173:               value
// 174:             end
// 175:
// 176:             [key, value]
// 177:           end.compact_blank
// 178:         end
// 179:       end
// 180:     end
// 181:   end
// 182: end
