module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_enumerable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(type)` at line 9.
pub fn ruby_typed_enumerable_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `type` at line 13.
pub fn ruby_typed_enumerable_l13_d2_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `build_type` at line 17.
pub fn ruby_typed_enumerable_l17_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `underlying_class` at line 22.
pub fn ruby_typed_enumerable_l22_d4_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('underlying_class', ...args)
}

// Ruby method `name` at line 27.
pub fn ruby_typed_enumerable_l27_d5_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 32.
pub fn ruby_typed_enumerable_l32_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 37.
pub fn ruby_typed_enumerable_l37_d7_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 90.
pub fn ruby_typed_enumerable_l90_d8_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `describe_obj(obj)` at line 108.
pub fn ruby_typed_enumerable_l108_d9_describe_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_obj', ...args)
}

// Ruby method `type_from_instances(objs)` at line 113.
pub fn ruby_typed_enumerable_l113_d10_type_from_instances(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_from_instances', ...args)
}

// Ruby method `type_from_instance(obj)` at line 135.
pub fn ruby_typed_enumerable_l135_d11_type_from_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_from_instance', ...args)
}

// Ruby method `initialize` at line 176.
pub fn ruby_typed_enumerable_l176_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `valid?(obj)` at line 180.
pub fn ruby_typed_enumerable_l180_d13_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
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
