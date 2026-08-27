module cask

import brew_runtime

// Translated from Homebrew/brew `api/cask/cask_struct_generator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `generate_cask_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag, ignore_types: false)` at line 14.
pub fn ruby_cask_struct_generator_l14_d1_generate_cask_struct_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_cask_struct_hash', ...args)
}

// Ruby method `process_depends_on(depends_on)` at line 110.
pub fn ruby_cask_struct_generator_l110_d2_process_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_depends_on', ...args)
}

// Ruby method `process_artifacts(artifacts)` at line 146.
pub fn ruby_cask_struct_generator_l146_d3_process_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_artifacts', ...args)
}

// Ruby method `process_url_specs(url_specs)` at line 165.
pub fn ruby_cask_struct_generator_l165_d4_process_url_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_url_specs', ...args)
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
