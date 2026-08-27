module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.coerce_and_check_module_types(val, check_val, check_module_type)` at line 13.
pub fn ruby_utils_l13_d1_self_coerce_and_check_module_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.coerce_and_check_module_types', ...args)
}

// Ruby method `self.coerce(val)` at line 47.
pub fn ruby_utils_l47_d2_self_coerce(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.coerce', ...args)
}

// Ruby method `self.check_type_recursive!(value, type)` at line 55.
pub fn ruby_utils_l55_d3_self_check_type_recursive(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_type_recursive!', ...args)
}

// Ruby method `self.methods_excluding_object(mod)` at line 62.
pub fn ruby_utils_l62_d4_self_methods_excluding_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.methods_excluding_object', ...args)
}

// Ruby method `self.signature_for_method(method)` at line 75.
pub fn ruby_utils_l75_d5_self_signature_for_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.signature_for_method', ...args)
}

// Ruby method `self.signature_for_instance_method(mod, method_name)` at line 82.
pub fn ruby_utils_l82_d6_self_signature_for_instance_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.signature_for_instance_method', ...args)
}

// Ruby method `self.wrap_method_with_call_validation_if_needed(mod, method_sig, original_method)` at line 86.
pub fn ruby_utils_l86_d7_self_wrap_method_with_call_validation_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wrap_method_with_call_validation_if_needed', ...args)
}

// Ruby method `self.run_all_sig_blocks(force_type_init: true)` at line 91.
pub fn ruby_utils_l91_d8_self_run_all_sig_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run_all_sig_blocks', ...args)
}

// Ruby method `self.resolve_alias(type)` at line 96.
pub fn ruby_utils_l96_d9_self_resolve_alias(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.resolve_alias', ...args)
}

// Ruby method `self.unwrap_nilable(type)` at line 107.
pub fn ruby_utils_l107_d10_self_unwrap_nilable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unwrap_nilable', ...args)
}

// Ruby method `self.arity(method)` at line 117.
pub fn ruby_utils_l117_d11_self_arity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.arity', ...args)
}

// Ruby method `self.string_truncate_middle(str, start_len, end_len, ellipsis='...')` at line 142.
pub fn ruby_utils_l142_d12_self_string_truncate_middle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.string_truncate_middle', ...args)
}

// Ruby method `self.lift_enum(enum)` at line 160.
pub fn ruby_utils_l160_d13_self_lift_enum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lift_enum', ...args)
}

// Ruby method `self.get_type_info(prop_type)` at line 182.
pub fn ruby_utils_l182_d14_self_get_type_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.get_type_info', ...args)
}

// Ruby method `self.get_underlying_type(prop_type)` at line 197.
pub fn ruby_utils_l197_d15_self_get_underlying_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.get_underlying_type', ...args)
}

// Ruby method `self.get_underlying_type_object(prop_type)` at line 213.
pub fn ruby_utils_l213_d16_self_get_underlying_type_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.get_underlying_type_object', ...args)
}

// Ruby method `self.is_union_with_nilclass(prop_type)` at line 217.
pub fn ruby_utils_l217_d17_self_is_union_with_nilclass(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.is_union_with_nilclass', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Utils
// 5:   module Private
// 6:     # NOTE: the Module and SimplePairUnion branches of this method are inlined
// 7:     # for speed in several hot paths. The `T.cast` / `T.let` / `T.bind` /
// 8:     # `T.assert_type!` happy paths in `_types.rb` inline the value check and
// 9:     # return early on success; `T::Private::Casts.cast` is only reached after
// 10:     # that check has already failed, so it reproduces the coercion branches but
// 11:     # skips the (now always-false) value check. If you change the behavior
// 12:     # here, update those callers too.
// 13:     def self.coerce_and_check_module_types(val, check_val, check_module_type)
// 14:       # rubocop:disable Style/CaseLikeIf
// 15:       if val.is_a?(T::Types::Base)
// 16:         if val.is_a?(T::Private::Types::TypeAlias)
// 17:           val.aliased_type
// 18:         else
// 19:           val
// 20:         end
// 21:       elsif val.is_a?(Module)
// 22:         if check_module_type && check_val.is_a?(val)
// 23:           nil
// 24:         else
// 25:           T::Types::Simple::Private::Pool.type_for_module(val)
// 26:         end
// 27:       elsif val.is_a?(::Array)
// 28:         T::Types::FixedArray.new(val)
// 29:       elsif val.is_a?(::Hash)
// 30:         T::Types::FixedHash.new(val)
// 31:       elsif val.is_a?(T::Private::Methods::DeclBuilder)
// 32:         T::Private::Methods.finalize_proc(val.decl)
// 33:       elsif val.is_a?(::T::Enum)
// 34:         T::Types::TEnum.new(val)
// 35:       elsif val.is_a?(::String)
// 36:         raise "Invalid String literal for type constraint. Must be an #{T::Types::Base}, a " \
// 37:               "class/module, or an array. Got a String with value `#{val}`."
// 38:       else
// 39:         raise "Invalid value for type constraint. Must be an #{T::Types::Base}, a " \
// 40:               "class/module, or an array. Got a `#{val.class}`."
// 41:       end
// 42:       # rubocop:enable Style/CaseLikeIf
// 43:     end
// 44:   end
// 45:
// 46:   # Used to convert from a type specification to a `T::Types::Base`.
// 47:   def self.coerce(val)
// 48:     Private.coerce_and_check_module_types(val, nil, false)
// 49:   end
// 50:
// 51:   # Dynamically confirm that `value` is recursively a valid value of
// 52:   # type `type`, including recursively through collections. Note that
// 53:   # in some cases this runtime check can be very expensive, especially
// 54:   # with large collections of objects.
// 55:   def self.check_type_recursive!(value, type)
// 56:     T::Private::Casts.cast_recursive(value, type, "T.check_type_recursive!")
// 57:   end
// 58:
// 59:   # Returns the set of all methods (public, protected, private) defined on a module or its
// 60:   # ancestors, excluding Object and its ancestors. Overrides of methods from Object (and its
// 61:   # ancestors) are included.
// 62:   def self.methods_excluding_object(mod)
// 63:     # We can't just do mod.instance_methods - Object.instance_methods, because that would leave out
// 64:     # any methods from Object that are overridden in mod.
// 65:     mod.ancestors.flat_map do |ancestor|
// 66:       # equivalent to checking Object.ancestors.include?(ancestor)
// 67:       next [] if Object <= ancestor
// 68:       ancestor.instance_methods(false) + ancestor.private_instance_methods(false)
// 69:     end.uniq
// 70:   end
// 71:
// 72:   # Returns the signature for the `UnboundMethod`, or nil if it's not sig'd
// 73:   #
// 74:   # @example T::Utils.signature_for_method(x.method(:foo))
// 75:   def self.signature_for_method(method)
// 76:     T::Private::Methods.signature_for_method(method)
// 77:   end
// 78:
// 79:   # Returns the signature for the instance method on the supplied module, or nil if it's not found or not typed.
// 80:   #
// 81:   # @example T::Utils.signature_for_instance_method(MyClass, :my_method)
// 82:   def self.signature_for_instance_method(mod, method_name)
// 83:     T::Private::Methods.signature_for_method(mod.instance_method(method_name))
// 84:   end
// 85:
// 86:   def self.wrap_method_with_call_validation_if_needed(mod, method_sig, original_method)
// 87:     T::Private::Methods::CallValidation.wrap_method_if_needed(mod, method_sig, original_method)
// 88:   end
// 89:
// 90:   # Unwraps all the sigs.
// 91:   def self.run_all_sig_blocks(force_type_init: true)
// 92:     T::Private::Methods.run_all_sig_blocks(force_type_init: force_type_init)
// 93:   end
// 94:
// 95:   # Return the underlying type for a type alias. Otherwise returns type.
// 96:   def self.resolve_alias(type)
// 97:     case type
// 98:     when T::Private::Types::TypeAlias
// 99:       type.aliased_type
// 100:     else
// 101:       type
// 102:     end
// 103:   end
// 104:
// 105:   # Give a type which is a subclass of T::Types::Base, determines if the type is a simple nilable type (union of NilClass and something else).
// 106:   # If so, returns the T::Types::Base of the something else. Otherwise, returns nil.
// 107:   def self.unwrap_nilable(type)
// 108:     case type
// 109:     when T::Types::Union
// 110:       type.unwrap_nilable
// 111:     else
// 112:       nil
// 113:     end
// 114:   end
// 115:
// 116:   # Returns the arity of a method, unwrapping the sig if needed
// 117:   def self.arity(method)
// 118:     arity = method.arity
// 119:     return arity if arity != -1 || method.is_a?(Proc)
// 120:     sig = T::Private::Methods.signature_for_method(method)
// 121:     sig ? sig.method.arity : arity
// 122:   end
// 123:
// 124:   # Elide the middle of a string as needed and replace it with an ellipsis.
// 125:   # Keep the given number of characters at the start and end of the string.
// 126:   #
// 127:   # This method operates on string length, not byte length.
// 128:   #
// 129:   # If the string is shorter than the requested truncation length, return it
// 130:   # without adding an ellipsis. This method may return a longer string than
// 131:   # the original if the characters removed are shorter than the ellipsis.
// 132:   #
// 133:   # @param [String] str
// 134:   #
// 135:   # @param [Fixnum] start_len The length of string before the ellipsis
// 136:   # @param [Fixnum] end_len The length of string after the ellipsis
// 137:   #
// 138:   # @param [String] ellipsis The string to add in place of the elided text
// 139:   #
// 140:   # @return [String]
// 141:   #
// 142:   def self.string_truncate_middle(str, start_len, end_len, ellipsis='...')
// 143:     return str unless str
// 144:
// 145:     raise ArgumentError.new('must provide start_len') unless start_len
// 146:     raise ArgumentError.new('must provide end_len') unless end_len
// 147:
// 148:     raise ArgumentError.new('start_len must be >= 0') if start_len < 0
// 149:     raise ArgumentError.new('end_len must be >= 0') if end_len < 0
// 150:
// 151:     str = str.to_s
// 152:     return str if str.length <= start_len + end_len
// 153:
// 154:     start_part = str[0...start_len - ellipsis.length]
// 155:     end_part = end_len == 0 ? '' : str[-end_len..-1]
// 156:
// 157:     "#{start_part}#{ellipsis}#{end_part}"
// 158:   end
// 159:
// 160:   def self.lift_enum(enum)
// 161:     unless enum.is_a?(T::Types::Enum)
// 162:       raise ArgumentError.new("#{enum.inspect} is not a T.deprecated_enum")
// 163:     end
// 164:
// 165:     classes = T.unsafe(enum.values).map(&:class).uniq
// 166:     if classes.empty?
// 167:       T.untyped
// 168:     elsif classes.length > 1
// 169:       T::Types::Union.new(classes)
// 170:     else
// 171:       T::Types::Simple::Private::Pool.type_for_module(classes.first)
// 172:     end
// 173:   end
// 174:
// 175:   module Nilable
// 176:     # :is_union_type, T::Boolean: whether the type is an T::Types::Union type
// 177:     # :non_nilable_type, Class: if it is an T.nilable type, the corresponding underlying type; otherwise, nil.
// 178:     TypeInfo = Struct.new(:is_union_type, :non_nilable_type)
// 179:
// 180:     NIL_TYPE = T::Utils.coerce(NilClass)
// 181:
// 182:     def self.get_type_info(prop_type)
// 183:       if prop_type.is_a?(T::Types::Union)
// 184:         non_nilable_type = prop_type.unwrap_nilable
// 185:         if non_nilable_type.is_a?(T::Types::Simple)
// 186:           non_nilable_type = non_nilable_type.raw_type
// 187:         end
// 188:         TypeInfo.new(true, non_nilable_type)
// 189:       else
// 190:         TypeInfo.new(false, nil)
// 191:       end
// 192:     end
// 193:
// 194:     # Get the underlying type inside prop_type:
// 195:     #  - if the type is A, the function returns A
// 196:     #  - if the type is T.nilable(A), the function returns A
// 197:     def self.get_underlying_type(prop_type)
// 198:       if prop_type.is_a?(T::Types::Union)
// 199:         non_nilable_type = prop_type.unwrap_nilable
// 200:         if non_nilable_type.is_a?(T::Types::Simple)
// 201:           non_nilable_type = non_nilable_type.raw_type
// 202:         end
// 203:         non_nilable_type || prop_type
// 204:       elsif prop_type.is_a?(T::Types::Simple)
// 205:         prop_type.raw_type
// 206:       else
// 207:         prop_type
// 208:       end
// 209:     end
// 210:
// 211:     # The difference between this function and the above function is that the Sorbet type, like T::Types::Simple
// 212:     # is preserved.
// 213:     def self.get_underlying_type_object(prop_type)
// 214:       T::Utils.unwrap_nilable(prop_type) || prop_type
// 215:     end
// 216:
// 217:     def self.is_union_with_nilclass(prop_type)
// 218:       case prop_type
// 219:       when T::Types::Union
// 220:         prop_type.types.include?(NIL_TYPE)
// 221:       else
// 222:         false
// 223:       end
// 224:     end
// 225:   end
// 226: end
