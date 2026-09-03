module types

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_array.rb`.
// The original source is retained below until every stub has a typed V body.
struct TypedArrayPool {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	entries map[string]brew_runtime.Value
}

fn new_typed_array_pool() &TypedArrayPool {
	return &TypedArrayPool{}
}

const typed_array_pool = new_typed_array_pool()

pub fn new_typed_array_type(type_value brew_runtime.Value) &TypedEnumerableType {
	return new_typed_enumerable_subtype(type_value, 'Array', 'T::Array')
}

fn typed_array_value(type_value brew_runtime.Value) brew_runtime.Value {
	return typed_enumerable_value(new_typed_array_type(type_value))
}

pub fn typed_array_for_module(module_value brew_runtime.Value) brew_runtime.Value {
	key := module_value.as_string()
	mut pool := unsafe { &TypedArrayPool(typed_array_pool) }
	pool.mutex.lock()
	defer {
		pool.mutex.unlock()
	}
	if cached := pool.entries[key] {
		return cached
	}
	value := typed_array_value(module_value)
	pool.entries[key] = value
	return value
}

pub fn typed_array_new(args []brew_runtime.Value) !brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	if args[0].type_name != 'Integer' {
		return error('no implicit conversion of ${args[0].type_name} into Integer')
	}
	count := int(args[0].as_int()!)
	if count < 0 {
		return error('negative array size')
	}
	fill := if args.len > 1 { args[1] } else { brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.array_value([]brew_runtime.Value{len: count, init: fill})
}

// Ruby method `name` at line 7.
pub fn ruby_typed_array_l7_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(typed_enumerable_from_args(args).name())
}

// Ruby method `underlying_class` at line 11.
pub fn ruby_typed_array_l11_d2_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	typed_enumerable_from_args(args)
	return brew_runtime.object_value('Class', 'Array')
}

// Ruby method `recursively_valid?(obj)` at line 16.
pub fn ruby_typed_array_l16_d3_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedArray#recursively_valid? requires an object')
	}
	return brew_runtime.bool_value(typed_enumerable_from_args(args).recursively_valid(args[1]) or {
		panic(err)
	})
}

// Ruby method `valid?(obj)` at line 21.
pub fn ruby_typed_array_l21_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedArray#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Array')
}

// Ruby method `new(...)` at line 25.
pub fn ruby_typed_array_l25_d5_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedArray#new requires a receiver')
	}
	typed_enumerable_from_args(args)
	return typed_array_new(args[1..]) or { panic(err) }
}

// Ruby method `self.type_for_module(mod)` at line 40.
pub fn ruby_typed_array_l40_d6_self_type_for_module(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedArray.type_for_module requires a module')
	}
	return typed_array_for_module(args[0])
}

// Ruby method `initialize` at line 55.
pub fn ruby_typed_array_l55_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return typed_array_value(base_type_boundary_value(base_untyped_type()))
}

// Ruby method `valid?(obj)` at line 59.
pub fn ruby_typed_array_l59_d8_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('TypedArray::Untyped#valid? requires an object')
	}
	return brew_runtime.bool_value(args[1].type_name == 'Array')
}

// Ruby method `freeze` at line 63.
pub fn ruby_typed_array_l63_d9_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypedArray::Untyped#freeze requires a receiver')
	}
	typed_enumerable_from_args(args).build_type() or { panic(err) }
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedArray < TypedEnumerable
// 6:     # overrides Base
// 7:     def name
// 8:       "T::Array[#{type.name}]"
// 9:     end
// 10:
// 11:     def underlying_class
// 12:       Array
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def recursively_valid?(obj)
// 17:       obj.is_a?(Array) && super
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def valid?(obj)
// 22:       obj.is_a?(Array)
// 23:     end
// 24:
// 25:     def new(...)
// 26:       Array.new(...)
// 27:     end
// 28:
// 29:     module Private
// 30:       module Pool
// 31:         CACHE_FROZEN_OBJECTS = begin
// 32:           ObjectSpace::WeakMap.new[1] = 1
// 33:           true # Ruby 2.7 and newer
// 34:                                rescue ArgumentError # Ruby 2.6 and older
// 35:                                  false
// 36:         end
// 37:
// 38:         @cache = ObjectSpace::WeakMap.new
// 39:
// 40:         def self.type_for_module(mod)
// 41:           cached = @cache[mod]
// 42:           return cached if cached
// 43:
// 44:           type = TypedArray.new(mod)
// 45:
// 46:           if CACHE_FROZEN_OBJECTS || (!mod.frozen? && !type.frozen?)
// 47:             @cache[mod] = type
// 48:           end
// 49:           type
// 50:         end
// 51:       end
// 52:     end
// 53:
// 54:     class Untyped < TypedArray
// 55:       def initialize
// 56:         super(T::Types::Untyped::Private::INSTANCE)
// 57:       end
// 58:
// 59:       def valid?(obj)
// 60:         obj.is_a?(Array)
// 61:       end
// 62:
// 63:       def freeze
// 64:         build_type # force lazy initialization before freezing the object
// 65:         super
// 66:       end
// 67:
// 68:       module Private
// 69:         INSTANCE = Untyped.new.freeze
// 70:       end
// 71:     end
// 72:   end
// 73: end
