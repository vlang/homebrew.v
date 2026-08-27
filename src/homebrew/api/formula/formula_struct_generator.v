module formula

import brew_runtime

// Translated from Homebrew/brew `api/formula/formula_struct_generator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `generate_formula_struct_hash(hash, bottle_tag: Homebrew::SimulateSystem.current_tag)` at line 43.
pub fn ruby_formula_struct_generator_l43_d1_generate_formula_struct_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_formula_struct_hash', ...args)
}

// Ruby method `process_dependencies_and_requirements(deps_hash, requirements_array, spec)` at line 203.
pub fn ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_dependencies_and_requirements', ...args)
}

// Ruby method `symbolize_dependency_hash(hash)` at line 223.
pub fn ruby_formula_struct_generator_l223_d3_symbolize_dependency_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbolize_dependency_hash', ...args)
}

// Ruby method `process_dependencies(deps_hash)` at line 251.
pub fn ruby_formula_struct_generator_l251_d4_process_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_dependencies', ...args)
}

// Ruby method `process_requirements(requirements_array, spec)` at line 261.
pub fn ruby_formula_struct_generator_l261_d5_process_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_requirements', ...args)
}

// Ruby method `process_uses_from_macos(deps_hash)` at line 299.
pub fn ruby_formula_struct_generator_l299_d6_process_uses_from_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process_uses_from_macos', ...args)
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
