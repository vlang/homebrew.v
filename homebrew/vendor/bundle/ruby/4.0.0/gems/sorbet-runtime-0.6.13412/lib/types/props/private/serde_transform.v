module private

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/serde_transform.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SerdeMode {
	serialize
	deserialize
}

fn serde_mode_from_value(value ruby.Value) SerdeMode {
	name := value.as_string().to_lower()
	return if name.contains('deserialize') { .deserialize } else { .serialize }
}

fn serde_simple_ancestors(type_value ruby.Value) []string {
	mut names := (type_value.attribute('ancestors') or { '' }).split(',').filter(it.len > 0)
	raw := type_value.attribute('raw_type') or { type_value.as_string() }
	if raw !in names {
		names << raw
	}
	return names
}

fn serde_nilable_member(type_value ruby.Value) ?ruby.Value {
	if type_value.type_name != 'T::Types::Union' {
		return none
	}
	has_nil := type_value.array_data.any(it.type_name == 'NilClass' || it.as_string() == 'NilClass')
	if !has_nil {
		return none
	}
	members := type_value.array_data.filter(it.type_name != 'NilClass' && it.as_string() != 'NilClass')
	if members.len == 1 {
		return members[0]
	}
	return none
}

pub fn serde_module_name(type_value ruby.Value) ?string {
	name := type_value.attribute('mangled_name') or {
		type_value.attribute('module_name') or {
			type_value.attribute('name') or { type_value.as_string() }
		}
	}
	if name == '' {
		return none
	}
	return name
}

pub fn handle_serializable_subtype(varname string, type_value ruby.Value,
	mode SerdeMode) !string {
	return match mode {
		.serialize { '${varname}.serialize(strict)' }
		.deserialize {
			'${serde_module_name(type_value) or { return error('anonymous serializable type') }}.from_hash(${varname})'
		}
	}
}

pub fn handle_custom_type(varname string, type_value ruby.Value, mode SerdeMode) !string {
	return match mode {
		.serialize { 'T::Props::CustomType.checked_serialize(${varname})' }
		.deserialize {
			'${serde_module_name(type_value) or { return error('anonymous custom type') }}.deserialize(${varname})'
		}
	}
}

// generate_serde_transform translates the specialized source expression. A
// missing result means the value can cross the serde boundary unchanged.
pub fn generate_serde_transform(type_value ruby.Value, mode SerdeMode,
	varname string) ?string {
	match type_value.type_name {
		'T::Types::TypedArray' {
			inner_type := type_value.map_data['type'] or { return '${varname}.dup' }
			inner := generate_serde_transform(inner_type, mode, 'v') or { return '${varname}.dup' }
			return '${varname}.map {|v| ${inner}}'
		}
		'T::Types::TypedSet' {
			inner_type := type_value.map_data['type'] or { return '${varname}.dup' }
			inner := generate_serde_transform(inner_type, mode, 'v') or { return '${varname}.dup' }
			return 'Set.new(${varname}) {|v| ${inner}}'
		}
		'T::Types::TypedHash' {
			keys := if key_type := type_value.map_data['keys'] {
				generate_serde_transform(key_type, mode, 'k')
			} else {
				none
			}
			values := if value_type := type_value.map_data['values'] {
				generate_serde_transform(value_type, mode, 'v')
			} else {
				none
			}
			if key_transform := keys {
				if value_transform := values {
					return '${varname}.each_with_object({}) {|(k,v),h| h[${key_transform}] = ${value_transform}}'
				}
				return '${varname}.transform_keys {|k| ${key_transform}}'
			}
			if value_transform := values {
				return '${varname}.transform_values {|v| ${value_transform}}'
			}
			return '${varname}.dup'
		}
		'T::Types::Simple' {
			names := serde_simple_ancestors(type_value)
			if names.any(it in ['TrueClass', 'FalseClass', 'NilClass', 'Symbol', 'String']) {
				return none
			}
			if 'Float' in names {
				return if mode == .deserialize { '${varname}.to_f' } else { none }
			}
			if 'Numeric' in names || names.any(it in ['Integer', 'Complex', 'Rational']) {
				return none
			}
			if private_rule_enabled(type_value.map_data, 'serializable_subtype') || 'T::Props::Serializable' in names {
				return handle_serializable_subtype(varname, type_value, mode) or {
					'T::Props::Utils.deep_clone(${varname})'
				}
			}
			if private_rule_enabled(type_value.map_data, 'custom_type') || type_value.attribute('custom_type') or { 'false' } == 'true' {
				return handle_custom_type(varname, type_value, mode) or {
					'T::Props::Utils.deep_clone(${varname})'
				}
			}
			if type_value.attribute('scalar_type') or { 'false' } == 'true' {
				return none
			}
			return 'T::Props::Utils.deep_clone(${varname})'
		}
		'T::Types::Union' {
			if member := serde_nilable_member(type_value) {
				inner := generate_serde_transform(member, mode, varname) or { return none }
				return '${varname}.nil? ? nil : ${inner}'
			}
			for member in type_value.array_data {
				if _ := generate_serde_transform(member, mode, varname) {
					return 'T::Props::Utils.deep_clone(${varname})'
				}
			}
			return none
		}
		'T::Types::Intersection' {
			dynamic := 'T::Props::Utils.deep_clone(${varname})'
			mut known := []string{}
			for member in type_value.array_data {
				key := generate_serde_transform(member, mode, varname) or { '<nil>' }
				if key != dynamic && key !in known {
					known << key
				}
			}
			if known.len != 1 {
				return dynamic
			}
			return if known[0] == '<nil>' { none } else { known[0] }
		}
		'T::Types::Enum' {
			lifted := type_value.map_data['lifted_type'] or {
				type_value.map_data['type'] or { return 'T::Props::Utils.deep_clone(${varname})' }
			}
			return generate_serde_transform(lifted, mode, varname)
		}
		else {
			return 'T::Props::Utils.deep_clone(${varname})'
		}
	}
}

// apply_serde_transform is the typed execution counterpart to the generated
// source expression. Dynamic Ruby calls cross the boundary through explicit
// `serialized`/`deserialized` values retained on the translated object.
pub fn apply_serde_transform(value ruby.Value, type_value ruby.Value,
	mode SerdeMode) !ruby.Value {
	if value.type_name == 'NilClass' {
		return value
	}
	match type_value.type_name {
		'T::Types::TypedArray', 'T::Types::TypedSet' {
			inner := type_value.map_data['type'] or { return private_deep_clone(value) }
			mut transformed := []ruby.Value{cap: value.array_data.len}
			for item in value.array_data {
				transformed << apply_serde_transform(item, inner, mode)!
			}
			return ruby.Value{
				...value
				array_data: transformed
			}
		}
		'T::Types::TypedHash' {
			key_type := type_value.map_data['keys'] or { private_nil_value() }
			value_type := type_value.map_data['values'] or { private_nil_value() }
			mut transformed := map[string]ruby.Value{}
			for key, item in value.map_data {
				key_value := ruby.string_value(key)
				new_key := if key_type.type_name == 'NilClass' {
					key
				} else {
					apply_serde_transform(key_value, key_type, mode)!.as_string()
				}
				transformed[new_key] = if value_type.type_name == 'NilClass' {
					private_deep_clone(item)
				} else {
					apply_serde_transform(item, value_type, mode)!
				}
			}
			return ruby.map_value(transformed)
		}
		'T::Types::Simple' {
			names := serde_simple_ancestors(type_value)
			if mode == .deserialize && 'Float' in names {
				return ruby.float_value(value.as_float()!)
			}
			if private_rule_enabled(type_value.map_data, 'serializable_subtype') || 'T::Props::Serializable' in names {
				return if mode == .serialize {
					value.map_data['serialized'] or { return error('${value.type_name} has no serialize result') }
				} else {
					value.map_data['deserialized'] or {
						ruby.Value{
							type_name: serde_module_name(type_value) or { type_value.as_string() }
							repr: value.as_string()
							map_data: value.map_data.clone()
						}
					}
				}
			}
			if private_rule_enabled(type_value.map_data, 'custom_type') || type_value.attribute('custom_type') or { 'false' } == 'true' {
				return if mode == .serialize {
					value.map_data['serialized'] or { return error('${value.type_name} has no custom serialize result') }
				} else {
					value.map_data['deserialized'] or {
						ruby.object_value(serde_module_name(type_value) or {
							type_value.as_string()
						}, value.as_string())
					}
				}
			}
			if generate_serde_transform(type_value, mode, 'value') == none {
				return value
			}
			return private_deep_clone(value)
		}
		'T::Types::Union' {
			if member := serde_nilable_member(type_value) {
				return apply_serde_transform(value, member, mode)
			}
			return private_deep_clone(value)
		}
		'T::Types::Intersection' {
			return private_deep_clone(value)
		}
		'T::Types::Enum' {
			lifted := type_value.map_data['lifted_type'] or {
				type_value.map_data['type'] or { return private_deep_clone(value) }
			}
			return apply_serde_transform(value, lifted, mode)
		}
		else {
			return private_deep_clone(value)
		}
	}
}

fn serde_transform_value(result ?string) ruby.Value {
	return if value := result { ruby.string_value(value) } else { private_nil_value() }
}

// Ruby method `self.generate(type, mode, varname)` at line 36.
pub fn ruby_serde_transform_l36_d1_self_generate(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('SerdeTransform.generate requires type, mode, and variable name')
	}
	return serde_transform_value(generate_serde_transform(args[0], serde_mode_from_value(args[1]), args[2].as_string()))
}

// Ruby method `self.handle_serializable_subtype(varname, type, mode)` at line 155.
pub fn ruby_serde_transform_l155_d2_self_handle_serializable_subtype(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('handle_serializable_subtype requires variable, type, and mode')
	}
	return ruby.string_value(handle_serializable_subtype(args[0].as_string(), args[1], serde_mode_from_value(args[2])) or { panic(err) })
}

// Ruby method `self.handle_custom_type(varname, type, mode)` at line 168.
pub fn ruby_serde_transform_l168_d3_self_handle_custom_type(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('handle_custom_type requires variable, type, and mode')
	}
	return ruby.string_value(handle_custom_type(args[0].as_string(), args[1], serde_mode_from_value(args[2])) or { panic(err) })
}

// Ruby method `self.module_name(type)` at line 181.
pub fn ruby_serde_transform_l181_d4_self_module_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('SerdeTransform.module_name requires a type')
	}
	return serde_transform_value(serde_module_name(args[0]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: strict
// 3:
// 4: module T::Props
// 5:   module Private
// 6:     module SerdeTransform
// 7:       extend T::Sig
// 8:
// 9:       class Serialize; end
// 10:       private_constant :Serialize
// 11:       class Deserialize; end
// 12:       private_constant :Deserialize
// 13:       ModeType = T.type_alias { T.any(Serialize, Deserialize) }
// 14:       private_constant :ModeType
// 15:
// 16:       module Mode
// 17:         SERIALIZE = T.let(Serialize.new.freeze, Serialize)
// 18:         DESERIALIZE = T.let(Deserialize.new.freeze, Deserialize)
// 19:       end
// 20:
// 21:       NO_TRANSFORM_TYPES = T.let(
// 22:         [TrueClass, FalseClass, NilClass, Symbol, String].freeze,
// 23:         T::Array[T::Module[T.anything]],
// 24:       )
// 25:       private_constant :NO_TRANSFORM_TYPES
// 26:
// 27:       sig do
// 28:         params(
// 29:           type: T::Types::Base,
// 30:           mode: ModeType,
// 31:           varname: String,
// 32:         )
// 33:         .returns(T.nilable(String))
// 34:         .checked(:never)
// 35:       end
// 36:       def self.generate(type, mode, varname)
// 37:         case type
// 38:         when T::Types::TypedArray
// 39:           inner = generate(type.type, mode, 'v')
// 40:           if inner.nil?
// 41:             "#{varname}.dup"
// 42:           else
// 43:             "#{varname}.map {|v| #{inner}}"
// 44:           end
// 45:         when T::Types::TypedSet
// 46:           inner = generate(type.type, mode, 'v')
// 47:           if inner.nil?
// 48:             "#{varname}.dup"
// 49:           else
// 50:             "Set.new(#{varname}) {|v| #{inner}}"
// 51:           end
// 52:         when T::Types::TypedHash
// 53:           keys = generate(type.keys, mode, 'k')
// 54:           values = generate(type.values, mode, 'v')
// 55:           if keys && values
// 56:             "#{varname}.each_with_object({}) {|(k,v),h| h[#{keys}] = #{values}}"
// 57:           elsif keys
// 58:             "#{varname}.transform_keys {|k| #{keys}}"
// 59:           elsif values
// 60:             "#{varname}.transform_values {|v| #{values}}"
// 61:           else
// 62:             "#{varname}.dup"
// 63:           end
// 64:         when T::Types::Simple
// 65:           raw = type.raw_type
// 66:           if NO_TRANSFORM_TYPES.any? { |cls| raw <= cls }
// 67:             nil
// 68:           elsif raw <= Float
// 69:             case mode
// 70:             when Deserialize then "#{varname}.to_f"
// 71:             when Serialize then nil
// 72:             else T.absurd(mode)
// 73:             end
// 74:           elsif raw <= Numeric
// 75:             nil
// 76:           elsif raw < T::Props::Serializable
// 77:             handle_serializable_subtype(varname, raw, mode)
// 78:           elsif raw.singleton_class < T::Props::CustomType
// 79:             handle_custom_type(varname, T.unsafe(raw), mode)
// 80:           elsif T::Configuration.scalar_types.include?(raw.name)
// 81:             # It's a bit of a hack that this is separate from NO_TRANSFORM_TYPES
// 82:             # and doesn't check inheritance (like `T::Props::CustomType.scalar_type?`
// 83:             # does), but it covers the main use case (pay-server's custom `Boolean`
// 84:             # module) without either requiring `T::Configuration.scalar_types` to
// 85:             # accept modules instead of strings (which produces load-order issues
// 86:             # and subtle behavior changes) or eating the performance cost of doing
// 87:             # an inheritance check by manually crawling a class hierarchy and doing
// 88:             # string comparisons.
// 89:             nil
// 90:           else
// 91:             "T::Props::Utils.deep_clone(#{varname})"
// 92:           end
// 93:         when T::Types::Union
// 94:           non_nil_type = T::Utils.unwrap_nilable(type)
// 95:           if non_nil_type
// 96:             inner = generate(non_nil_type, mode, varname)
// 97:             if inner.nil?
// 98:               nil
// 99:             else
// 100:               "#{varname}.nil? ? nil : #{inner}"
// 101:             end
// 102:           elsif type.types.all? { |t| generate(t, mode, varname).nil? }
// 103:             # Handle, e.g., T::Boolean
// 104:             nil
// 105:           else
// 106:             # We currently deep_clone_object if the type was T.any(Integer, Float).
// 107:             # When we get better support for union types (maybe this specific
// 108:             # union type, because it would be a replacement for
// 109:             # Chalk::ODM::DeprecatedNumemric), we could opt to special case
// 110:             # this union to have no specific serde transform (the only reason
// 111:             # why Float has a special case is because round tripping through
// 112:             # JSON might normalize Floats to Integers)
// 113:             "T::Props::Utils.deep_clone(#{varname})"
// 114:           end
// 115:         when T::Types::Intersection
// 116:           dynamic_fallback = "T::Props::Utils.deep_clone(#{varname})"
// 117:
// 118:           # Transformations for any members of the intersection type where we
// 119:           # know what we need to do and did not have to fall back to the
// 120:           # dynamic deep clone method.
// 121:           #
// 122:           # NB: This deliberately does include `nil`, which means we know we
// 123:           # don't need to do any transforming.
// 124:           inner_known = type.types
// 125:             .map { |t| generate(t, mode, varname) }
// 126:             .reject { |t| t == dynamic_fallback }
// 127:             .uniq
// 128:
// 129:           if inner_known.size != 1
// 130:             # If there were no cases where we could tell what we need to do,
// 131:             # e.g. if this is `T.all(SomethingWeird, WhoKnows)`, just use the
// 132:             # dynamic fallback.
// 133:             #
// 134:             # If there were multiple cases and they weren't consistent, e.g.
// 135:             # if this is `T.all(String, T::Array[Integer])`, the type is probably
// 136:             # bogus/uninhabited, but use the dynamic fallback because we still
// 137:             # don't have a better option, and this isn't the place to raise that
// 138:             # error.
// 139:             dynamic_fallback
// 140:           else
// 141:             # This is probably something like `T.all(String, SomeMarker)` or
// 142:             # `T.all(SomeEnum, T.deprecated_enum(SomeEnum::FOO))` and we should
// 143:             # treat it like String or SomeEnum even if we don't know what to do
// 144:             # with the rest of the type.
// 145:             inner_known.first
// 146:           end
// 147:         when T::Types::Enum
// 148:           generate(T::Utils.lift_enum(type), mode, varname)
// 149:         else
// 150:           "T::Props::Utils.deep_clone(#{varname})"
// 151:         end
// 152:       end
// 153:
// 154:       sig { params(varname: String, type: T::Module[T.anything], mode: ModeType).returns(String).checked(:never) }
// 155:       private_class_method def self.handle_serializable_subtype(varname, type, mode)
// 156:         case mode
// 157:         when Serialize
// 158:           "#{varname}.serialize(strict)"
// 159:         when Deserialize
// 160:           type_name = T.must(module_name(type))
// 161:           "#{type_name}.from_hash(#{varname})"
// 162:         else
// 163:           T.absurd(mode)
// 164:         end
// 165:       end
// 166:
// 167:       sig { params(varname: String, type: T::Module[T.anything], mode: ModeType).returns(String).checked(:never) }
// 168:       private_class_method def self.handle_custom_type(varname, type, mode)
// 169:         case mode
// 170:         when Serialize
// 171:           "T::Props::CustomType.checked_serialize(#{varname})"
// 172:         when Deserialize
// 173:           type_name = T.must(module_name(type))
// 174:           "#{type_name}.deserialize(#{varname})"
// 175:         else
// 176:           T.absurd(mode)
// 177:         end
// 178:       end
// 179:
// 180:       sig { params(type: T::Module[T.anything]).returns(T.nilable(String)).checked(:never) }
// 181:       private_class_method def self.module_name(type)
// 182:         T::Configuration.module_name_mangler.call(type)
// 183:       end
// 184:     end
// 185:   end
// 186: end
