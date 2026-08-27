module api

import brew_runtime

// Translated from Homebrew/brew `api/formula_struct.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.from_hash(formula_hash)` at line 12.
pub fn ruby_formula_struct_l12_d1_self_from_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_hash', ...args)
}

// Ruby define_method `define_method(predicate_method_name) do` at line 83.
pub fn ruby_formula_struct_l83_d2_predicate_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('predicate_method_name', ...args)
}

// Ruby method `==(other)` at line 126.
pub fn ruby_formula_struct_l126_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby method `serialize_bottle(bottle_tag: ::Utils::Bottles.tag)` at line 136.
pub fn ruby_formula_struct_l136_d4_serialize_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialize_bottle', ...args)
}

// Ruby method `serialize(bottle_tag: ::Utils::Bottles.tag)` at line 163.
pub fn ruby_formula_struct_l163_d5_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialize', ...args)
}

// Ruby method `self.deserialize(hash, bottle_tag: ::Utils::Bottles.tag)` at line 187.
pub fn ruby_formula_struct_l187_d6_self_deserialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deserialize', ...args)
}

// Ruby method `self.format_arg_pair(args, last:)` at line 241.
pub fn ruby_formula_struct_l241_d7_self_format_arg_pair(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_arg_pair', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "service"
// 5: require "utils/spdx"
// 6: require "install_steps"
// 7:
// 8: module Homebrew
// 9:   module API
// 10:     class FormulaStruct < T::Struct
// 11:       sig { params(formula_hash: T::Hash[String, T.untyped]).returns(FormulaStruct) }
// 12:       def self.from_hash(formula_hash)
// 13:         formula_hash = ::Formula.deep_remove_placeholders(formula_hash)
// 14:         formula_hash = formula_hash.transform_keys(&:to_sym)
// 15:                                    .slice(*decorator.all_props)
// 16:                                    .compact_blank
// 17:         new(**formula_hash)
// 18:       end
// 19:
// 20:       PREDICATES = [
// 21:         :bottle,
// 22:         :deprecate,
// 23:         :disable,
// 24:         :head,
// 25:         :keg_only,
// 26:         :no_autobump,
// 27:         :pour_bottle,
// 28:         :service,
// 29:         :service_run,
// 30:         :service_name,
// 31:         :stable,
// 32:       ].freeze
// 33:
// 34:       SKIP_SERIALIZATION = [
// 35:         # Bottle checksums have special serialization done by the serialize_bottle method
// 36:         :bottle_checksums,
// 37:       ].freeze
// 38:
// 39:       SPECS = [:head, :stable].freeze
// 40:
// 41:       # :any_skip_relocation is the most common in homebrew/core
// 42:       DEFAULT_CELLAR = :any_skip_relocation
// 43:
// 44:       DependsOnArgs = T.type_alias do
// 45:         T.any(
// 46:           # Dependencies
// 47:           T.any(
// 48:             # Formula name: "foo"
// 49:             String,
// 50:             # Formula name and dependency type: { "foo" => :build }
// 51:             T::Hash[String, Symbol],
// 52:           ),
// 53:           # Requirements
// 54:           T.any(
// 55:             # Requirement name: :macos
// 56:             Symbol,
// 57:             # Requirement name and other info: { macos: :build }
// 58:             T::Hash[Symbol, T::Array[T.anything]],
// 59:           ),
// 60:         )
// 61:       end
// 62:
// 63:       UsesFromMacOSArgs = T.type_alias do
// 64:         [
// 65:           T.any(
// 66:             # Formula name: "foo"
// 67:             String,
// 68:             # Formula name and dependency type: { "foo" => :build }
// 69:             # Formula name, dependency type, and version bounds: { "foo" => :build, since: :catalina }
// 70:             T::Hash[T.any(String, Symbol), T.any(Symbol, T::Array[Symbol])],
// 71:           ),
// 72:           # If the first argument is only a name, this argument contains the version bounds: { since: :catalina }
// 73:           T::Hash[Symbol, Symbol],
// 74:         ]
// 75:       end
// 76:
// 77:       PREDICATES.each do |predicate_name|
// 78:         present_method_name = :"#{predicate_name}_present"
// 79:         predicate_method_name = :"#{predicate_name}?"
// 80:
// 81:         const present_method_name, T::Boolean, default: false
// 82:
// 83:         define_method(predicate_method_name) do
// 84:           send(present_method_name)
// 85:         end
// 86:       end
// 87:
// 88:       # Changes to this struct must be mirrored in Homebrew::API::Formula.generate_formula_struct_hash
// 89:       const :aliases, T::Array[String], default: []
// 90:       const :bottle_checksums, T::Array[T::Hash[Symbol, T.any(String, Symbol)]], default: []
// 91:       const :bottle_rebuild, Integer, default: 0
// 92:       const :caveats, T.nilable(String)
// 93:       const :conflicts, T::Array[[String, T::Hash[Symbol, String]]], default: []
// 94:       const :deprecate_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 95:       const :desc, String
// 96:       const :disable_args, T::Hash[Symbol, T.nilable(T.any(String, Symbol))], default: {}
// 97:       const :executables, T::Array[String], default: []
// 98:       const :head_dependencies, T::Array[DependsOnArgs], default: []
// 99:       const :head_url_args, [String, T::Hash[Symbol, T.anything]], default: ["", {}]
// 100:       const :head_uses_from_macos, T::Array[UsesFromMacOSArgs], default: []
// 101:       const :homepage, String
// 102:       const :keg_only_args, T::Array[T.any(String, Symbol)], default: []
// 103:       const :license, SPDX::LicenseExpression
// 104:       const :link_overwrite_paths, T::Array[String], default: []
// 105:       const :no_autobump_args, T::Hash[Symbol, T.any(String, Symbol)], default: {}
// 106:       const :oldnames, T::Array[String], default: []
// 107:       const :post_install_defined, T::Boolean, default: false
// 108:       const :post_install_steps, Homebrew::InstallSteps::Steps, default: []
// 109:       const :pour_bottle_args, T::Hash[Symbol, Symbol], default: {}
// 110:       const :revision, Integer, default: 0
// 111:       const :ruby_source_checksum, String
// 112:       const :service_args, T::Array[[Symbol, BasicObject]], default: []
// 113:       const :service_name_args, T::Hash[Symbol, String], default: {}
// 114:       const :service_run_args, T::Array[Homebrew::Service::RunParam], default: []
// 115:       const :service_run_kwargs, T::Hash[Symbol, Homebrew::Service::RunParam], default: {}
// 116:       const :stable_dependencies, T::Array[DependsOnArgs], default: []
// 117:       const :stable_patches, T::Array[T::Hash[T.any(String, Symbol), T.untyped]], default: []
// 118:       const :stable_checksum, T.nilable(String)
// 119:       const :stable_url_args, [String, T::Hash[Symbol, T.anything]], default: ["", {}]
// 120:       const :stable_uses_from_macos, T::Array[UsesFromMacOSArgs], default: []
// 121:       const :stable_version, String
// 122:       const :version_scheme, Integer, default: 0
// 123:       const :versioned_formulae, T::Array[String], default: []
// 124:
// 125:       sig { params(other: T.anything).returns(T::Boolean) }
// 126:       def ==(other)
// 127:         case other
// 128:         when FormulaStruct
// 129:           serialize == other.serialize
// 130:         else
// 131:           false
// 132:         end
// 133:       end
// 134:
// 135:       sig { params(bottle_tag: ::Utils::Bottles::Tag).returns(T.nilable(T::Hash[String, T.untyped])) }
// 136:       def serialize_bottle(bottle_tag: ::Utils::Bottles.tag)
// 137:         bottle_collector = ::Utils::Bottles::Collector.new
// 138:         bottle_checksums.each do |bottle_info|
// 139:           bottle_info = bottle_info.dup
// 140:           cellar = bottle_info.delete(:cellar) || :any
// 141:           tag = T.must(bottle_info.keys.first)
// 142:           checksum = T.cast(bottle_info.values.first, String)
// 143:
// 144:           bottle_collector.add(
// 145:             ::Utils::Bottles::Tag.from_symbol(tag),
// 146:             checksum: Checksum.new(checksum),
// 147:             cellar:,
// 148:           )
// 149:         end
// 150:         return unless (bottle_spec = bottle_collector.specification_for(bottle_tag))
// 151:
// 152:         tag = (bottle_spec.tag if bottle_spec.tag != bottle_tag)
// 153:         cellar = (bottle_spec.cellar if bottle_spec.cellar != DEFAULT_CELLAR)
// 154:
// 155:         {
// 156:           "bottle_tag"      => tag&.to_sym,
// 157:           "bottle_cellar"   => cellar,
// 158:           "bottle_checksum" => bottle_spec.checksum.to_s,
// 159:         }
// 160:       end
// 161:
// 162:       sig { params(bottle_tag: ::Utils::Bottles::Tag).returns(T::Hash[String, T.untyped]) }
// 163:       def serialize(bottle_tag: ::Utils::Bottles.tag)
// 164:         hash = self.class.decorator.all_props.filter_map do |prop|
// 165:           next if PREDICATES.any? { |predicate| prop == :"#{predicate}_present" }
// 166:           next if SKIP_SERIALIZATION.include?(prop)
// 167:
// 168:           [prop.to_s, send(prop)]
// 169:         end.to_h
// 170:
// 171:         if (bottle_hash = serialize_bottle(bottle_tag:))
// 172:           hash = hash.merge(bottle_hash)
// 173:         end
// 174:
// 175:         hash = ::Utils.deep_stringify_symbols(hash)
// 176:
// 177:         service_args = hash["service_args"]
// 178:         hash = ::Utils.deep_compact_blank(hash)
// 179:
// 180:         # service_args may have falsey values that we don't want to remove, like `keep_alive successful_exit: false`
// 181:         hash["service_args"] = service_args if service_args&.any?
// 182:
// 183:         hash
// 184:       end
// 185:
// 186:       sig { params(hash: T::Hash[String, T.untyped], bottle_tag: ::Utils::Bottles::Tag).returns(FormulaStruct) }
// 187:       def self.deserialize(hash, bottle_tag: ::Utils::Bottles.tag)
// 188:         hash = ::Utils.deep_unstringify_symbols(hash)
// 189:
// 190:         # Items that don't follow the `hash["foo_present"] = hash["foo_args"].present?` pattern are overridden below
// 191:         PREDICATES.each do |name|
// 192:           hash["#{name}_present"] = hash["#{name}_args"].present?
// 193:         end
// 194:
// 195:         if (bottle_checksum = hash["bottle_checksum"])
// 196:           tag = hash.fetch("bottle_tag", bottle_tag.to_sym)
// 197:           cellar = hash.fetch("bottle_cellar", DEFAULT_CELLAR)
// 198:
// 199:           hash["bottle_present"] = true
// 200:           hash["bottle_checksums"] = [{ cellar: cellar, tag => bottle_checksum }]
// 201:         else
// 202:           hash["bottle_present"] = false
// 203:         end
// 204:
// 205:         # *_url_args need to be in [String, Hash] format, but the hash may have been dropped if empty
// 206:         SPECS.each do |key|
// 207:           if (url_args = hash["#{key}_url_args"])
// 208:             hash["#{key}_present"] = true
// 209:             hash["#{key}_url_args"] = format_arg_pair(url_args, last: {})
// 210:           else
// 211:             hash["#{key}_present"] = false
// 212:           end
// 213:
// 214:           next unless (uses_from_macos = hash["#{key}_uses_from_macos"])
// 215:
// 216:           hash["#{key}_uses_from_macos"] = uses_from_macos.map do |args|
// 217:             format_arg_pair(args, last: {})
// 218:           end
// 219:         end
// 220:
// 221:         hash["conflicts"] = if (conflicts = hash["conflicts"])
// 222:           conflicts.map { |conflict| format_arg_pair(conflict, last: {}) }
// 223:         end
// 224:
// 225:         from_hash(hash)
// 226:       end
// 227:
// 228:       # Format argument pairs into proper [first, last] format if serialization has removed some elements.
// 229:       # Pass a default value for last to be used when only one element is present.
// 230:       #
// 231:       #  format_arg_pair(["foo"], last: {})                       # => ["foo", {}]
// 232:       #  format_arg_pair([{ "foo" => :build }], last: {})         # => [{ "foo" => :build }, {}]
// 233:       #  format_arg_pair(["foo", { since: :catalina }], last: {}) # => ["foo", { since: :catalina }]
// 234:       sig {
// 235:         type_parameters(:U, :V)
// 236:           .params(
// 237:             args: T.any([T.type_parameter(:U)], [T.type_parameter(:U), T.type_parameter(:V)]),
// 238:             last: T.type_parameter(:V),
// 239:           ).returns([T.type_parameter(:U), T.type_parameter(:V)])
// 240:       }
// 241:       def self.format_arg_pair(args, last:)
// 242:         args = case args
// 243:         in [elem]
// 244:           [elem, last]
// 245:         in [elem1, elem2]
// 246:           [elem1, elem2]
// 247:         end
// 248:
// 249:         # The case above is exhaustive so args will never be nil, but sorbet cannot infer that.
// 250:         T.must(args)
// 251:       end
// 252:     end
// 253:   end
// 254: end
