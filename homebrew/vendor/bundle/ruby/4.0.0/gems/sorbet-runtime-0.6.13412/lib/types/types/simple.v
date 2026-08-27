module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/simple.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :raw_type` at line 10.
pub fn ruby_simple_l10_d1_raw_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_type', ...args)
}

// Ruby method `initialize(raw_type)` at line 12.
pub fn ruby_simple_l12_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 16.
pub fn ruby_simple_l16_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 21.
pub fn ruby_simple_l21_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 38.
pub fn ruby_simple_l38_d5_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 43.
pub fn ruby_simple_l43_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 48.
pub fn ruby_simple_l48_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `error_message(obj)` at line 63.
pub fn ruby_simple_l63_d8_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error_message', ...args)
}

// Ruby method `to_nilable` at line 79.
pub fn ruby_simple_l79_d9_to_nilable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_nilable', ...args)
}

// Ruby method `self.type_for_module(mod)` at line 97.
pub fn ruby_simple_l97_d10_self_type_for_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.type_for_module', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Validates that an object belongs to the specified class.
// 6:   class Simple < Base
// 7:     NAME_METHOD = Module.instance_method(:name)
// 8:     private_constant(:NAME_METHOD)
// 9:
// 10:     attr_reader :raw_type
// 11:
// 12:     def initialize(raw_type)
// 13:       @raw_type = raw_type
// 14:     end
// 15:
// 16:     def build_type
// 17:       nil
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def name
// 22:       # Memoize to mitigate pathological performance with anonymous modules (https://bugs.ruby-lang.org/issues/11119)
// 23:       #
// 24:       # `name` isn't normally a hot path for types, but it is used in initializing a T::Types::Union,
// 25:       # and so in `T.nilable`, and so in runtime constructions like `x = T.let(nil, T.nilable(Integer))`.
// 26:       #
// 27:       # Care more about back compat than we do about performance here.
// 28:       # Once 2.6 is well in the rear view mirror, we can replace this.
// 29:       # rubocop:disable Performance/BindCall
// 30:       @name ||= (NAME_METHOD.bind(@raw_type).call || @raw_type.name).freeze
// 31:       # rubocop:enable Performance/BindCall
// 32:     end
// 33:
// 34:     # overrides Base
// 35:     #
// 36:     # Identical to valid?; defined directly so the leaf-type hot path (every
// 37:     # element check in a typed collection walk) skips the Base delegator frame.
// 38:     def recursively_valid?(obj)
// 39:       obj.is_a?(@raw_type)
// 40:     end
// 41:
// 42:     # overrides Base
// 43:     def valid?(obj)
// 44:       obj.is_a?(@raw_type)
// 45:     end
// 46:
// 47:     # overrides Base
// 48:     private def subtype_of_single?(other)
// 49:       case other
// 50:       when Simple
// 51:         @raw_type <= other.raw_type
// 52:       when TypedClass, TypedModule
// 53:         # This case is a bit odd--we would have liked to solve this like we do
// 54:         # for `T::Array` et al., but don't for backwards compatibility.
// 55:         # See `type_for_module` below.
// 56:         @raw_type <= other.underlying_class
// 57:       else
// 58:         false
// 59:       end
// 60:     end
// 61:
// 62:     # overrides Base
// 63:     private def error_message(obj)
// 64:       error_message = super(obj)
// 65:       actual_name = obj.class.name
// 66:
// 67:       return error_message unless name == actual_name
// 68:
// 69:       <<~MSG.strip
// 70:         #{error_message}
// 71:
// 72:         The expected type and received object type have the same name but refer to different constants.
// 73:         Expected type is #{name} with object id #{@raw_type.__id__}, but received type is #{actual_name} with object id #{obj.class.__id__}.
// 74:
// 75:         There might be a constant reloading problem in your application.
// 76:       MSG
// 77:     end
// 78:
// 79:     def to_nilable
// 80:       @nilable ||= T::Private::Types::SimplePairUnion.new(
// 81:         self,
// 82:         T::Utils::Nilable::NIL_TYPE,
// 83:       )
// 84:     end
// 85:
// 86:     module Private
// 87:       module Pool
// 88:         CACHE_FROZEN_OBJECTS = begin
// 89:           ObjectSpace::WeakMap.new[1] = 1
// 90:           true # Ruby 2.7 and newer
// 91:                                rescue ArgumentError # Ruby 2.6 and older
// 92:                                  false
// 93:         end
// 94:
// 95:         @cache = ObjectSpace::WeakMap.new
// 96:
// 97:         def self.type_for_module(mod)
// 98:           cached = @cache[mod]
// 99:           return cached if cached
// 100:
// 101:           type = if mod == ::Array
// 102:             TypedArray::Untyped::Private::INSTANCE
// 103:           elsif mod == ::Hash
// 104:             TypedHash::Untyped::Private::INSTANCE
// 105:           elsif mod == ::Enumerable
// 106:             TypedEnumerable::Untyped.new
// 107:           elsif mod == ::Enumerator
// 108:             TypedEnumerator::Untyped.new
// 109:           elsif mod == ::Range
// 110:             TypedRange::Untyped.new
// 111:           elsif !Object.autoload?(:Set) && Object.const_defined?(:Set) && mod == ::Set
// 112:             TypedSet::Untyped.new
// 113:           else
// 114:             # ideally we would have a case mapping from ::Class -> T::Class and
// 115:             # ::Module -> T::Module here but for backwards compatibility we
// 116:             # don't have that, and instead have a special case in subtype_of_single?
// 117:             Simple.new(mod)
// 118:           end
// 119:
// 120:           # Unfortunately, we still need to check if the module is frozen,
// 121:           # since on 2.6 and older WeakMap adds a finalizer to the key that is added
// 122:           # to the map, so that it can clear the map entry when the key is
// 123:           # garbage collected.
// 124:           # For a frozen object, though, adding a finalizer is not a valid
// 125:           # operation, so this still raises if `mod` is frozen.
// 126:           if CACHE_FROZEN_OBJECTS || (!mod.frozen? && !type.frozen?)
// 127:             @cache[mod] = type
// 128:           end
// 129:           type
// 130:         end
// 131:       end
// 132:     end
// 133:   end
// 134: end
