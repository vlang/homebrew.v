module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/simple_pair_union.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(type_a, type_b)` at line 12.
pub fn ruby_simple_pair_union_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 22.
pub fn ruby_simple_pair_union_l22_d2_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 27.
pub fn ruby_simple_pair_union_l27_d3_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `types` at line 32.
pub fn ruby_simple_pair_union_l32_d4_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('types', ...args)
}

// Ruby method `unwrap_nilable` at line 44.
pub fn ruby_simple_pair_union_l44_d5_unwrap_nilable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unwrap_nilable', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Specialization of Union for the common case of the union of two simple types.
// 5: #
// 6: # This covers e.g. T.nilable(SomeModule), T.any(Integer, Float), and T::Boolean.
// 7: class T::Private::Types::SimplePairUnion < T::Types::Union
// 8:   class DuplicateType < RuntimeError; end
// 9:
// 10:   # @param type_a [T::Types::Simple]
// 11:   # @param type_b [T::Types::Simple]
// 12:   def initialize(type_a, type_b)
// 13:     if type_a == type_b
// 14:       raise DuplicateType.new("#{type_a} == #{type_b}")
// 15:     end
// 16:
// 17:     @raw_a = type_a.raw_type
// 18:     @raw_b = type_b.raw_type
// 19:   end
// 20:
// 21:   # @override Union
// 22:   def recursively_valid?(obj)
// 23:     obj.is_a?(@raw_a) || obj.is_a?(@raw_b)
// 24:   end
// 25:
// 26:   # @override Union
// 27:   def valid?(obj)
// 28:     obj.is_a?(@raw_a) || obj.is_a?(@raw_b)
// 29:   end
// 30:
// 31:   # @override Union
// 32:   def types
// 33:     # We reconstruct the simple types rather than just storing them because
// 34:     # (1) this is normally not a hot path and (2) we want to keep the instance
// 35:     # variable count <= 3 so that we can fit in a 40 byte heap entry along
// 36:     # with object headers.
// 37:     @types ||= [
// 38:       T::Types::Simple::Private::Pool.type_for_module(@raw_a),
// 39:       T::Types::Simple::Private::Pool.type_for_module(@raw_b),
// 40:     ]
// 41:   end
// 42:
// 43:   # overrides Union
// 44:   def unwrap_nilable
// 45:     a_nil = @raw_a.equal?(NilClass)
// 46:     b_nil = @raw_b.equal?(NilClass)
// 47:     if a_nil
// 48:       return types[1]
// 49:     end
// 50:     if b_nil
// 51:       return types[0]
// 52:     end
// 53:     nil
// 54:   end
// 55: end
