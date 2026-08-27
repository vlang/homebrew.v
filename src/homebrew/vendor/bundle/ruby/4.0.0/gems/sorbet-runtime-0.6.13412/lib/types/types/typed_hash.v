module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `underlying_class` at line 6.
pub fn ruby_typed_hash_l6_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('underlying_class', ...args)
}

// Ruby method `initialize(keys:, values:)` at line 10.
pub fn ruby_typed_hash_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `keys` at line 16.
pub fn ruby_typed_hash_l16_d3_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keys', ...args)
}

// Ruby method `values` at line 21.
pub fn ruby_typed_hash_l21_d4_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('values', ...args)
}

// Ruby method `type` at line 25.
pub fn ruby_typed_hash_l25_d5_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `name` at line 30.
pub fn ruby_typed_hash_l30_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 35.
pub fn ruby_typed_hash_l35_d7_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 40.
pub fn ruby_typed_hash_l40_d8_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `new(...)` at line 44.
pub fn ruby_typed_hash_l44_d9_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new', ...args)
}

// Ruby method `initialize` at line 49.
pub fn ruby_typed_hash_l49_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `valid?(obj)` at line 55.
pub fn ruby_typed_hash_l55_d11_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `freeze` at line 59.
pub fn ruby_typed_hash_l59_d12_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedHash < TypedEnumerable
// 6:     def underlying_class
// 7:       Hash
// 8:     end
// 9:
// 10:     def initialize(keys:, values:)
// 11:       @inner_keys = keys
// 12:       @inner_values = values
// 13:     end
// 14:
// 15:     # Technically we don't need this, but it is a nice api
// 16:     def keys
// 17:       @keys ||= T::Utils.coerce(@inner_keys)
// 18:     end
// 19:
// 20:     # Technically we don't need this, but it is a nice api
// 21:     def values
// 22:       @values ||= T::Utils.coerce(@inner_values)
// 23:     end
// 24:
// 25:     def type
// 26:       @type ||= T::Utils.coerce([keys, values])
// 27:     end
// 28:
// 29:     # overrides Base
// 30:     def name
// 31:       "T::Hash[#{keys.name}, #{values.name}]"
// 32:     end
// 33:
// 34:     # overrides Base
// 35:     def recursively_valid?(obj)
// 36:       obj.is_a?(Hash) && super
// 37:     end
// 38:
// 39:     # overrides Base
// 40:     def valid?(obj)
// 41:       obj.is_a?(Hash)
// 42:     end
// 43:
// 44:     def new(...)
// 45:       Hash.new(...)
// 46:     end
// 47:
// 48:     class Untyped < TypedHash
// 49:       def initialize
// 50:         # Use the INSTANCE constant directly (rather than `T.untyped`) so this
// 51:         # can be built at load time, mirroring TypedArray::Untyped.
// 52:         super(keys: T::Types::Untyped::Private::INSTANCE, values: T::Types::Untyped::Private::INSTANCE)
// 53:       end
// 54:
// 55:       def valid?(obj)
// 56:         obj.is_a?(Hash)
// 57:       end
// 58:
// 59:       def freeze
// 60:         build_type # force lazy initialization before freezing the object
// 61:         super
// 62:       end
// 63:
// 64:       module Private
// 65:         INSTANCE = Untyped.new.freeze
// 66:       end
// 67:     end
// 68:   end
// 69: end
