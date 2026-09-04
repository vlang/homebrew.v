module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct NilableTypeInfo {
pub:
	is_union_type    bool
	non_nilable_type ruby.Value
}

fn utils_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn coerce_and_check_module_types(value ruby.Value, check_value ruby.Value,
	check_module_type bool) !ruby.Value {
	if value.type_name == 'T::Private::Types::TypeAlias' {
		return value.map_data['aliased_type'] or { return error('TypeAlias has no aliased type') }
	}
	if t_is_type(value) {
		return value
	}
	if value.type_name in ['Class', 'Module'] && check_module_type && t_value_is_a(check_value, value.as_string()) {
		return utils_nil_value()
	}
	return t_coerce_type(value)
}

pub fn check_type_recursive(value ruby.Value, type_value ruby.Value) !ruby.Value {
	coerced := t_coerce_type(type_value)!
	if !t_type_valid(coerced, value, true)! {
		return error('T.check_type_recursive!: Expected type ${t_type_name(coerced)}, got type ${value.type_name}')
	}
	return value
}

pub fn methods_excluding_object(mod ruby.Value) []string {
	ancestor_values := mod.map_data['ancestors'] or { ruby.array_value([]) }
	mut methods := []string{}
	for ancestor in ancestor_values.as_array() or { []ruby.Value{} } {
		if ancestor.attribute('object_ancestor') or { 'false' } == 'true' {
			continue
		}
		for name in ancestor.attribute('instance_methods') or { '' }.split(',') {
			clean_name := name.trim_space()
			if clean_name != '' && clean_name !in methods {
				methods << clean_name
			}
		}
		for name in ancestor.attribute('private_instance_methods') or { '' }.split(',') {
			clean_name := name.trim_space()
			if clean_name != '' && clean_name !in methods {
				methods << clean_name
			}
		}
	}
	return methods
}

pub fn signature_for_method_value(method ruby.Value) ruby.Value {
	return method.map_data['signature'] or { utils_nil_value() }
}

pub fn signature_for_instance_method_value(mod ruby.Value,
	method_name string) ruby.Value {
	methods := mod.map_data['instance_methods'] or { return utils_nil_value() }
	method_map := methods.as_map() or { return utils_nil_value() }
	method := method_map[method_name.trim_string_left(':')] or { return utils_nil_value() }
	return signature_for_method_value(method)
}

pub fn resolve_type_alias(type_value ruby.Value) ruby.Value {
	if type_value.type_name == 'T::Private::Types::TypeAlias' {
		return type_value.map_data['aliased_type'] or { type_value }
	}
	return type_value
}

fn utils_is_nil_type(type_value ruby.Value) bool {
	return type_value.type_name == 'T::Types::Simple' && (type_value.attribute('raw_type') or { type_value.as_string() }) == 'NilClass'
}

pub fn unwrap_nilable_type(type_value ruby.Value) ruby.Value {
	if type_value.type_name !in ['T::Types::Union', 'T::Private::Types::SimplePairUnion'] {
		return utils_nil_value()
	}
	remaining := type_value.array_data.filter(!utils_is_nil_type(it))
	if remaining.len == type_value.array_data.len || remaining.len == 0 {
		return utils_nil_value()
	}
	if remaining.len == 1 {
		return remaining[0]
	}
	return t_union_of_types(remaining[0], remaining[1], remaining[2..])
}

pub fn method_arity(method ruby.Value) int {
	arity := method.attribute('arity') or { '-1' }.int()
	if arity != -1 || method.type_name == 'Proc' {
		return arity
	}
	signature := signature_for_method_value(method)
	if signature.type_name == 'NilClass' {
		return arity
	}
	return signature.attribute('method_arity') or { arity.str() }.int()
}

pub fn string_truncate_middle(value string, start_len int, end_len int,
	ellipsis string) !string {
	if start_len < 0 {
		return error('start_len must be >= 0')
	}
	if end_len < 0 {
		return error('end_len must be >= 0')
	}
	runes := value.runes()
	if runes.len <= start_len + end_len {
		return value
	}
	mut start_end := start_len - ellipsis.runes().len
	if start_end < 0 {
		start_end = runes.len + start_end
	}
	if start_end < 0 {
		start_end = 0
	}
	if start_end > runes.len {
		start_end = runes.len
	}
	start_part := runes[..start_end].string()
	end_part := if end_len == 0 { '' } else { runes[runes.len - end_len..].string() }
	return '${start_part}${ellipsis}${end_part}'
}

pub fn lift_deprecated_enum(enum_value ruby.Value) !ruby.Value {
	if enum_value.type_name != 'T::Types::Enum' {
		return error('${enum_value.as_string()} is not a T.deprecated_enum')
	}
	values := if raw_values := enum_value.map_data['values'] {
		raw_values.as_array() or { enum_value.array_data.clone() }
	} else {
		enum_value.array_data.clone()
	}
	mut classes := []string{}
	for value in values {
		if value.type_name !in classes {
			classes << value.type_name
		}
	}
	if classes.len == 0 {
		return t_untyped_value()
	}
	types := classes.map(t_simple_type(ruby.object_value('Class', it)))
	if types.len == 1 {
		return types[0]
	}
	return t_union_of_types(types[0], types[1], types[2..])
}

pub fn nilable_type_info(type_value ruby.Value) NilableTypeInfo {
	if type_value.type_name !in ['T::Types::Union', 'T::Private::Types::SimplePairUnion'] {
		return NilableTypeInfo{
			non_nilable_type: utils_nil_value()
		}
	}
	mut underlying := unwrap_nilable_type(type_value)
	if underlying.type_name == 'T::Types::Simple' {
		underlying = underlying.map_data['raw_type'] or {
			ruby.object_value('Class', underlying.attribute('raw_type') or {
				underlying.as_string()
			})
		}
	}
	return NilableTypeInfo{
		is_union_type: true
		non_nilable_type: underlying
	}
}

pub fn underlying_nilable_type(type_value ruby.Value) ruby.Value {
	if type_value.type_name in ['T::Types::Union', 'T::Private::Types::SimplePairUnion'] {
		info := nilable_type_info(type_value)
		if info.non_nilable_type.type_name != 'NilClass' {
			return info.non_nilable_type
		}
		return type_value
	}
	if type_value.type_name == 'T::Types::Simple' {
		return type_value.map_data['raw_type'] or {
			ruby.object_value('Class', type_value.attribute('raw_type') or {
				type_value.as_string()
			})
		}
	}
	return type_value
}

pub fn union_with_nilclass(type_value ruby.Value) bool {
	return type_value.type_name in ['T::Types::Union', 'T::Private::Types::SimplePairUnion'] && type_value.array_data.any(utils_is_nil_type(it))
}

fn nilable_type_info_value(info NilableTypeInfo) ruby.Value {
	return ruby.Value{
		type_name: 'T::Utils::Nilable::TypeInfo'
		repr: '#<struct T::Utils::Nilable::TypeInfo>'
		map_data: {
			'is_union_type':    ruby.bool_value(info.is_union_type)
			'non_nilable_type': info.non_nilable_type
		}
	}
}

// Ruby method `self.coerce_and_check_module_types(val, check_val, check_module_type)` at line 13.
pub fn ruby_utils_l13_d1_self_coerce_and_check_module_types(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Utils.coerce_and_check_module_types requires value, checked value, and module check flag')
	}
	return coerce_and_check_module_types(args[0], args[1], args[2].as_bool() or { panic(err.msg()) }) or {
		panic(err.msg())
	}
}

// Ruby method `self.coerce(val)` at line 47.
pub fn ruby_utils_l47_d2_self_coerce(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Utils.coerce requires a type')
	}
	return coerce_and_check_module_types(args[0], utils_nil_value(), false) or { panic(err.msg()) }
}

// Ruby method `self.check_type_recursive!(value, type)` at line 55.
pub fn ruby_utils_l55_d3_self_check_type_recursive(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Utils.check_type_recursive! requires value and type')
	}
	return check_type_recursive(args[0], args[1]) or { panic(err.msg()) }
}

// Ruby method `self.methods_excluding_object(mod)` at line 62.
pub fn ruby_utils_l62_d4_self_methods_excluding_object(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	return ruby.string_array_value(methods_excluding_object(args[0]))
}

// Ruby method `self.signature_for_method(method)` at line 75.
pub fn ruby_utils_l75_d5_self_signature_for_method(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return utils_nil_value()
	}
	return signature_for_method_value(args[0])
}

// Ruby method `self.signature_for_instance_method(mod, method_name)` at line 82.
pub fn ruby_utils_l82_d6_self_signature_for_instance_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return utils_nil_value()
	}
	return signature_for_instance_method_value(args[0], args[1].as_string())
}

// Ruby method `self.wrap_method_with_call_validation_if_needed(mod, method_sig, original_method)` at line 86.
pub fn ruby_utils_l86_d7_self_wrap_method_with_call_validation_if_needed(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Utils.wrap_method_with_call_validation_if_needed requires module, signature, and method')
	}
	return ruby.Value{
		type_name: 'T::Private::Methods::CallValidation::WrapPlan'
		repr: args[2].as_string()
		map_data: {
			'module':          args[0]
			'signature':       args[1]
			'original_method': args[2]
		}
	}
}

// Ruby method `self.run_all_sig_blocks(force_type_init: true)` at line 91.
pub fn ruby_utils_l91_d8_self_run_all_sig_blocks(args ...ruby.Value) ruby.Value {
	force := if args.len > 0 { args[0].as_bool() or { true } } else { true }
	return ruby.structured_value('T::Private::Methods::RunAllSigBlocks', 'nil', {
		'force_type_init': force.str()
	})
}

// Ruby method `self.resolve_alias(type)` at line 96.
pub fn ruby_utils_l96_d9_self_resolve_alias(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return utils_nil_value()
	}
	return resolve_type_alias(args[0])
}

// Ruby method `self.unwrap_nilable(type)` at line 107.
pub fn ruby_utils_l107_d10_self_unwrap_nilable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return utils_nil_value()
	}
	return unwrap_nilable_type(args[0])
}

// Ruby method `self.arity(method)` at line 117.
pub fn ruby_utils_l117_d11_self_arity(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Utils.arity requires a method')
	}
	return ruby.int_value(i64(method_arity(args[0])))
}

// Ruby method `self.string_truncate_middle(str, start_len, end_len, ellipsis='...')` at line 142.
pub fn ruby_utils_l142_d12_self_string_truncate_middle(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return if args.len == 0 { utils_nil_value() } else { args[0] }
	}
	if args.len < 2 || args[1].type_name == 'NilClass' {
		panic('must provide start_len')
	}
	if args.len < 3 || args[2].type_name == 'NilClass' {
		panic('must provide end_len')
	}
	ellipsis := if args.len > 3 { args[3].as_string() } else { '...' }
	return ruby.string_value(string_truncate_middle(args[0].as_string(), int(args[1].as_int() or { panic(err.msg()) }), int(args[2].as_int() or { panic(err.msg()) }), ellipsis) or { panic(err.msg()) })
}

// Ruby method `self.lift_enum(enum)` at line 160.
pub fn ruby_utils_l160_d13_self_lift_enum(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Utils.lift_enum requires an enum')
	}
	return lift_deprecated_enum(args[0]) or { panic(err.msg()) }
}

// Ruby method `self.get_type_info(prop_type)` at line 182.
pub fn ruby_utils_l182_d14_self_get_type_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nilable_type_info_value(NilableTypeInfo{ non_nilable_type: utils_nil_value() })
	}
	return nilable_type_info_value(nilable_type_info(args[0]))
}

// Ruby method `self.get_underlying_type(prop_type)` at line 197.
pub fn ruby_utils_l197_d15_self_get_underlying_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return utils_nil_value()
	}
	return underlying_nilable_type(args[0])
}

// Ruby method `self.get_underlying_type_object(prop_type)` at line 213.
pub fn ruby_utils_l213_d16_self_get_underlying_type_object(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return utils_nil_value()
	}
	unwrapped := unwrap_nilable_type(args[0])
	return if unwrapped.type_name == 'NilClass' { args[0] } else { unwrapped }
}

// Ruby method `self.is_union_with_nilclass(prop_type)` at line 217.
pub fn ruby_utils_l217_d17_self_is_union_with_nilclass(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && union_with_nilclass(args[0]))
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
