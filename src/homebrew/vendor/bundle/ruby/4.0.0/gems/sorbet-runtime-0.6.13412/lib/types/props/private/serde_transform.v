module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/serde_transform.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.generate(type, mode, varname)` at line 36.
pub fn ruby_serde_transform_l36_d1_self_generate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate', ...args)
}

// Ruby method `self.handle_serializable_subtype(varname, type, mode)` at line 155.
pub fn ruby_serde_transform_l155_d2_self_handle_serializable_subtype(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.handle_serializable_subtype', ...args)
}

// Ruby method `self.handle_custom_type(varname, type, mode)` at line 168.
pub fn ruby_serde_transform_l168_d3_self_handle_custom_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.handle_custom_type', ...args)
}

// Ruby method `self.module_name(type)` at line 181.
pub fn ruby_serde_transform_l181_d4_self_module_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.module_name', ...args)
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
