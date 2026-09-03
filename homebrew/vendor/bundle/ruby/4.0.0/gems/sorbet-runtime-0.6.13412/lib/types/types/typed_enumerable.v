module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_enumerable.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TypedEnumerableType {
pub:
	type_value       brew_runtime.Value
	underlying_class string = 'Enumerable'
	display_prefix   string = 'T::Enumerable'
}

pub fn new_typed_enumerable_type(type_value brew_runtime.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Enumerable', 'T::Enumerable')
}

pub fn new_typed_enumerable_subtype(type_value brew_runtime.Value, underlying_class string,
	display_prefix string) &TypedEnumerableType {
	return &TypedEnumerableType{
		type_value: type_value
		underlying_class: underlying_class
		display_prefix: display_prefix
	}
}

fn enumerable_value_is_a(value brew_runtime.Value, class_name string) bool {
	if value.type_name == class_name {
		return true
	}
	if class_name == 'Enumerable' && value.type_name in ['Array', 'Hash', 'Range', 'Set', 'Enumerator',
		'Enumerator::Lazy', 'Enumerator::Chain'] {
		return true
	}
	ancestors := value.attribute('ancestors') or { return false }
	return ancestors.split(',').map(it.trim_space()).any(it == class_name)
}

fn enumerable_element_name(type_value brew_runtime.Value) string {
	if base_type := base_type_from_value(type_value) {
		return base_type.name() or { type_value.as_string() }
	}
	return type_value.attribute('name') or { type_value.as_string() }
}

fn enumerable_element_valid(type_value brew_runtime.Value, value brew_runtime.Value,
	recursive bool) !bool {
	if base_type := base_type_from_value(type_value) {
		return if recursive { base_type.recursively_valid(value)! } else { base_type.valid(value)! }
	}
	return match type_value.type_name {
		'T::Types::FixedArray' {
			fixed := fixed_array_type_from_value(type_value)
			if recursive { fixed.recursively_valid(value)! } else { fixed.valid(value)! }
		}
		'T::Types::FixedHash' {
			fixed := fixed_hash_type_from_value(type_value)
			if recursive { fixed.recursively_valid(value)! } else { fixed.valid(value)! }
		}
		'T::Types::Enum' { enum_type_from_args([type_value]).valid(value) }
		'T::Types::TEnum' { t_enum_type_from_args([type_value]).valid(value) }
		else {
			expected := type_value.attribute('raw_type') or { type_value.as_string() }
			enumerable_value_is_a(value, expected)
		}
	}
}

pub fn (typed &TypedEnumerableType) build_type() ! {
	if base_type := base_type_from_value(typed.type_value) {
		base_type.build_type()!
	}
}

pub fn (typed &TypedEnumerableType) name() string {
	return '${typed.display_prefix}[${enumerable_element_name(typed.type_value)}]'
}

pub fn (typed &TypedEnumerableType) valid(value brew_runtime.Value) bool {
	return enumerable_value_is_a(value, typed.underlying_class)
}

pub fn (typed &TypedEnumerableType) recursively_valid(value brew_runtime.Value) !bool {
	if !typed.valid(value) {
		return false
	}
	match value.type_name {
		'Array', 'Set' {
			for element in value.array_data {
				if !enumerable_element_valid(typed.type_value, element, true)! {
					return false
				}
			}
			return true
		}
		'Hash' {
			if typed.type_value.type_name != 'T::Types::FixedArray' {
				return false
			}
			pair_type := fixed_array_type_from_value(typed.type_value)
			if pair_type.types.len != 2 {
				return false
			}
			for key, item in value.map_data {
				if !pair_type.types[0].recursively_valid(brew_runtime.string_value(key))! || !pair_type.types[1].recursively_valid(item)! {
					return false
				}
			}
			return true
		}
		'Range' {
			for endpoint in value.array_data {
				if endpoint.type_name != 'NilClass' && !enumerable_element_valid(typed.type_value, endpoint, true)! {
					return false
				}
			}
			return true
		}
		'Enumerator', 'Enumerator::Lazy', 'Enumerator::Chain' {
			return true
		}
		else {
			// Arbitrary Enumerable objects may be expensive, destructive, or unbounded.
			return true
		}
	}
}

fn enumerable_underlying_subtype(left string, right string) bool {
	return left == right || right == 'Enumerable'
}

pub fn (typed &TypedEnumerableType) subtype_of_single(other brew_runtime.Value) !bool {
	if other.type_name.starts_with('T::Types::Typed') {
		other_underlying := other.attribute('underlying_class') or { return false }
		if !enumerable_underlying_subtype(typed.underlying_class, other_underlying) {
			return false
		}
		other_type := other.map_data['type'] or { return false }
		left_base := base_type_from_value(typed.type_value) or {
			return typed.type_value.repr == other_type.repr
		}
		right_base := base_type_from_value(other_type) or { return false }
		return left_base.subtype_of(right_base)! == .yes
	}
	if other.type_name == 'T::Types::Simple' {
		raw_type := other.attribute('raw_type') or { return false }
		return enumerable_underlying_subtype(typed.underlying_class, raw_type)
	}
	return false
}

fn enumerable_simple_type_for(value brew_runtime.Value) brew_runtime.Value {
	name := if value.type_name == 'Bool' { 'T::Boolean' } else { value.type_name }
	return base_type_boundary_value(new_simple_base_type(name, ['Object']))
}

pub fn enumerable_type_from_instances(value brew_runtime.Value) brew_runtime.Value {
	if !enumerable_value_is_a(value, 'Enumerable') {
		return enumerable_simple_type_for(value)
	}
	mut objects := []brew_runtime.Value{}
	match value.type_name {
		'Hash' {
			for key, item in value.map_data {
				objects << brew_runtime.string_value(key)
				objects << item
			}
		}
		else {
			objects = value.array_data.clone()
		}
	}
	mut obtained := []&BaseType{}
	for object in objects {
		inferred := enumerable_type_from_instance(object)
		base := base_type_from_value(inferred) or { return base_type_boundary_value(base_untyped_type()) }
		if !union_contains(obtained, base) {
			obtained << base
		}
	}
	return match obtained.len {
		0 { base_type_boundary_value(base_no_return_type()) }
		1 { base_type_boundary_value(obtained[0]) }
		else { base_type_boundary_value(new_union_base_type(obtained)) }
	}
}

pub fn enumerable_type_from_instance(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Bool' {
		return base_type_boundary_value(new_custom_base_type('T::Boolean', 'T::Boolean', [
			'Bool',
		], []))
	}
	if !enumerable_value_is_a(value, 'Enumerable') || value.type_name in ['IO', 'File'] {
		return enumerable_simple_type_for(value)
	}
	prefix := match value.type_name {
		'Array' { 'T::Array' }
		'Hash' { 'T::Hash' }
		'Range' { 'T::Range' }
		'Enumerator::Lazy' { 'T::Enumerator::Lazy' }
		'Enumerator::Chain' { 'T::Enumerator::Chain' }
		'Enumerator' { 'T::Enumerator' }
		'Set' { 'T::Set' }
		else {
			return enumerable_simple_type_for(value)
		}
	}
	if value.type_name == 'Hash' {
		mut keys := []brew_runtime.Value{}
		mut values := []brew_runtime.Value{}
		for key, item in value.map_data {
			keys << brew_runtime.string_value(key)
			values << item
		}
		key_type := enumerable_type_from_instances(brew_runtime.array_value(keys))
		value_type := enumerable_type_from_instances(brew_runtime.array_value(values))
		return brew_runtime.object_value('T::Types::TypedHash', '${prefix}[${enumerable_element_name(key_type)}, ${enumerable_element_name(value_type)}]')
	}
	mut typeable := value.array_data.clone()
	if value.type_name == 'Range' {
		typeable = typeable.filter(it.type_name != 'NilClass')
	}
	element_type := enumerable_type_from_instances(brew_runtime.array_value(typeable))
	return brew_runtime.object_value('T::Types::${value.type_name}', '${prefix}[${enumerable_element_name(element_type)}]')
}

pub fn (typed &TypedEnumerableType) describe_obj(value brew_runtime.Value) string {
	if !enumerable_value_is_a(value, 'Enumerable') {
		return new_custom_base_type('T::Types::TypedEnumerable', typed.name(), [], []).describe_obj(value)
	}
	return enumerable_type_from_instance(value).as_string()
}

fn typed_enumerable_value(typed &TypedEnumerableType) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: match typed.display_prefix {
			'T::Array' { 'T::Types::TypedArray' }
			'T::Hash' { 'T::Types::TypedHash' }
			'T::Range' { 'T::Types::TypedRange' }
			'T::Set' { 'T::Types::TypedSet' }
			'T::Enumerator' { 'T::Types::TypedEnumerator' }
			'T::Enumerator::Lazy' { 'T::Types::TypedEnumeratorLazy' }
			'T::Enumerator::Chain' { 'T::Types::TypedEnumeratorChain' }
			else { 'T::Types::TypedEnumerable' }
		}
		repr: typed.name()
		map_data: {
			'type': typed.type_value
		}
		attributes: {
			'typed_enumerable_address': u64(voidptr(typed)).str()
			'underlying_class':         typed.underlying_class
		}
	}
}

fn typed_enumerable_from_args(args []brew_runtime.Value) &TypedEnumerableType {
	if args.len == 0 {
		panic('TypedEnumerable method requires a receiver')
	}
	address := args[0].attribute('typed_enumerable_address') or {
		panic('invalid TypedEnumerable receiver')
	}
	return unsafe { &TypedEnumerableType(voidptr(address.u64())) }
}

// Ruby method `initialize(type)` at line 9.
pub fn ruby_typed_enumerable_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedEnumerable#initialize requires a type')
	}
	return typed_enumerable_value(new_typed_enumerable_type(args[0]))
}

// Ruby method `type` at line 13.
pub fn ruby_typed_enumerable_l13_d2_type(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_from_args(args).type_value
}

// Ruby method `build_type` at line 17.
pub fn ruby_typed_enumerable_l17_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	typed_enumerable_from_args(args).build_type() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `underlying_class` at line 22.
pub fn ruby_typed_enumerable_l22_d4_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Class', typed_enumerable_from_args(args).underlying_class)
}

// Ruby method `name` at line 27.
pub fn ruby_typed_enumerable_l27_d5_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `valid?(obj)` at line 32.
pub fn ruby_typed_enumerable_l32_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#valid? requires an object')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).valid(args[1]))
}

// Ruby method `recursively_valid?(obj)` at line 37.
pub fn ruby_typed_enumerable_l37_d7_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `subtype_of_single?(other)` at line 90.
pub fn ruby_typed_enumerable_l90_d8_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#subtype_of_single? requires another type')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).subtype_of_single(args[1]) or {
		panic(err)
	})
}

// Ruby method `describe_obj(obj)` at line 108.
pub fn ruby_typed_enumerable_l108_d9_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#describe_obj requires an object')
	}
	return brew_runtime.string_value(typed_enumerable_from_args(args).describe_obj(args[1]))
}

// Ruby method `type_from_instances(objs)` at line 113.
pub fn ruby_typed_enumerable_l113_d10_type_from_instances(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#type_from_instances requires objects')
	}
	return enumerable_type_from_instances(args[1])
}

// Ruby method `type_from_instance(obj)` at line 135.
pub fn ruby_typed_enumerable_l135_d11_type_from_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable#type_from_instance requires an object')
	}
	return enumerable_type_from_instance(args[1])
}

// Ruby method `initialize` at line 176.
pub fn ruby_typed_enumerable_l176_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_value(new_typed_enumerable_type(base_type_boundary_value(base_untyped_type())))
}

// Ruby method `valid?(obj)` at line 180.
pub fn ruby_typed_enumerable_l180_d13_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedEnumerable::Untyped#valid? requires an object')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).valid(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Note: All subclasses of Enumerable should add themselves to the
// 6:   # `case` statement below in `describe_obj` in order to get better
// 7:   # error messages.
// 8:   class TypedEnumerable < Base
// 9:     def initialize(type)
// 10:       @inner_type = type
// 11:     end
// 12:
// 13:     def type
// 14:       @type ||= T::Utils.coerce(@inner_type)
// 15:     end
// 16:
// 17:     def build_type
// 18:       type
// 19:       nil
// 20:     end
// 21:
// 22:     def underlying_class
// 23:       Enumerable
// 24:     end
// 25:
// 26:     # overrides Base
// 27:     def name
// 28:       "T::Enumerable[#{type.name}]"
// 29:     end
// 30:
// 31:     # overrides Base
// 32:     def valid?(obj)
// 33:       obj.is_a?(Enumerable)
// 34:     end
// 35:
// 36:     # overrides Base
// 37:     def recursively_valid?(obj)
// 38:       return false unless obj.is_a?(Enumerable)
// 39:       case obj
// 40:       when Array
// 41:         element_type = type
// 42:         length = obj.count
// 43:         index = 0
// 44:         while index < length
// 45:           return false unless element_type.recursively_valid?(obj[index])
// 46:           index += 1
// 47:         end
// 48:         true
// 49:       when Hash
// 50:         type_ = self.type
// 51:         return false unless type_.is_a?(FixedArray)
// 52:         key_type, value_type = type_.types
// 53:         return false if key_type.nil? || value_type.nil? || type_.types.size > 2
// 54:         obj.each_pair do |key, val|
// 55:           # Some objects (I'm looking at you Rack::Utils::HeaderHash) don't
// 56:           # iterate over a [key, value] array, so we can't just use the type.recursively_valid?(v)
// 57:           return false if !key_type.recursively_valid?(key) || !value_type.recursively_valid?(val)
// 58:         end
// 59:         true
// 60:       when Enumerator::Lazy
// 61:         # Enumerators can be unbounded: see `[:foo, :bar].cycle`
// 62:         true
// 63:       when Enumerator::Chain
// 64:         # Enumerators can be unbounded: see `[:foo, :bar].cycle`
// 65:         true
// 66:       when Enumerator
// 67:         # Enumerators can be unbounded: see `[:foo, :bar].cycle`
// 68:         true
// 69:       when Range
// 70:         # A nil beginning or a nil end does not provide any type information. That is, nil in a range represents
// 71:         # boundlessness, it does not express a type. For example `(nil...nil)` is not a T::Range[NilClass], its a range
// 72:         # of unknown types (T::Range[T.untyped]).
// 73:         # Similarly, `(nil...1)` is not a `T::Range[T.nilable(Integer)]`, it's a boundless range of Integer.
// 74:         (obj.begin.nil? || type.recursively_valid?(obj.begin)) && (obj.end.nil? || type.recursively_valid?(obj.end))
// 75:       when Set
// 76:         obj.each do |item|
// 77:           return false unless type.recursively_valid?(item)
// 78:         end
// 79:
// 80:         true
// 81:       else
// 82:         # We don't check the enumerable since it isn't guaranteed to be
// 83:         # rewindable (e.g. STDIN) and it may be expensive to enumerate
// 84:         # (e.g. an enumerator that makes an HTTP request)"
// 85:         true
// 86:       end
// 87:     end
// 88:
// 89:     # overrides Base
// 90:     private def subtype_of_single?(other)
// 91:       if other.class <= TypedEnumerable &&
// 92:          underlying_class <= other.underlying_class
// 93:         # Enumerables are covariant because they are read only
// 94:         #
// 95:         # Properly speaking, many Enumerable subtypes (e.g. Set)
// 96:         # should be invariant because they are mutable and support
// 97:         # both reading and writing. However, Sorbet treats *all*
// 98:         # Enumerable subclasses as covariant for ease of adoption.
// 99:         type.subtype_of?(other.type)
// 100:       elsif other.class <= Simple
// 101:         underlying_class <= other.raw_type
// 102:       else
// 103:         false
// 104:       end
// 105:     end
// 106:
// 107:     # overrides Base
// 108:     def describe_obj(obj)
// 109:       return super unless obj.is_a?(Enumerable)
// 110:       type_from_instance(obj).name
// 111:     end
// 112:
// 113:     private def type_from_instances(objs)
// 114:       return objs.class unless objs.is_a?(Enumerable)
// 115:       obtained_types = []
// 116:       begin
// 117:         objs.each do |x|
// 118:           obtained_types << type_from_instance(x)
// 119:         end
// 120:       rescue
// 121:         return T.untyped # all we can do is go with the types we have so far
// 122:       end
// 123:       if obtained_types.count > 1
// 124:         # Multiple kinds of bad types showed up, we'll suggest a union
// 125:         # type you might want.
// 126:         Union.new(obtained_types)
// 127:       elsif obtained_types.empty?
// 128:         T.noreturn
// 129:       else
// 130:         # Everything was the same bad type, lets just show that
// 131:         obtained_types.first
// 132:       end
// 133:     end
// 134:
// 135:     private def type_from_instance(obj)
// 136:       if [true, false].include?(obj)
// 137:         return T::Boolean
// 138:       elsif !obj.is_a?(Enumerable)
// 139:         return obj.class
// 140:       end
// 141:
// 142:       case obj
// 143:       when Array
// 144:         T::Array[type_from_instances(obj)]
// 145:       when Hash
// 146:         inferred_key = type_from_instances(obj.keys)
// 147:         inferred_val = type_from_instances(obj.values)
// 148:         T::Hash[inferred_key, inferred_val]
// 149:       when Range
// 150:         # We can't get any information from `NilClass` in ranges (since nil is used to represent boundlessness).
// 151:         typeable_objects = [obj.begin, obj.end].compact
// 152:         if typeable_objects.empty?
// 153:           T::Range[T.untyped]
// 154:         else
// 155:           T::Range[type_from_instances(typeable_objects)]
// 156:         end
// 157:       when Enumerator::Lazy
// 158:         T::Enumerator::Lazy[type_from_instances(obj)]
// 159:       when Enumerator::Chain
// 160:         T::Enumerator::Chain[type_from_instances(obj)]
// 161:       when Enumerator
// 162:         T::Enumerator[type_from_instances(obj)]
// 163:       when Set
// 164:         T::Set[type_from_instances(obj)]
// 165:       when IO
// 166:         # Short circuit for anything IO-like (File, etc.). In these cases,
// 167:         # enumerating the object is a destructive operation and might hang.
// 168:         obj.class
// 169:       else
// 170:         # This is a specialized enumerable type, just return the class.
// 171:         Object.instance_method(:class).bind_call(obj)
// 172:       end
// 173:     end
// 174:
// 175:     class Untyped < TypedEnumerable
// 176:       def initialize
// 177:         super(T::Types::Untyped::Private::INSTANCE)
// 178:       end
// 179:
// 180:       def valid?(obj)
// 181:         obj.is_a?(Enumerable)
// 182:       end
// 183:     end
// 184:   end
// 185: end
