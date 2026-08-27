module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/weak_constructor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(hash=EMPTY_HASH)` at line 15.
pub fn ruby_weak_constructor_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `construct_props_without_defaults(instance, hash)` at line 37.
pub fn ruby_weak_constructor_l37_d2_construct_props_without_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('construct_props_without_defaults', ...args)
}

// Ruby method `construct_props_with_defaults(instance, hash)` at line 58.
pub fn ruby_weak_constructor_l58_d3_construct_props_with_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('construct_props_with_defaults', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::WeakConstructor
// 5:   include T::Props::Optional
// 6:   extend T::Sig
// 7:
// 8:   # Shared default so zero-arg construction doesn't allocate a fresh Hash;
// 9:   # the construct_props_* methods only ever read from `hash`.
// 10:   EMPTY_HASH = T.let({}.freeze, T::Hash[Symbol, T.untyped])
// 11:   private_constant :EMPTY_HASH
// 12:
// 13:   # checked(:never) - O(runtime object construction)
// 14:   sig { params(hash: T::Hash[Symbol, T.untyped]).void.checked(:never) }
// 15:   def initialize(hash=EMPTY_HASH)
// 16:     decorator = self.class.decorator
// 17:
// 18:     hash_keys_matching_props = decorator.construct_props_with_defaults(self, hash) +
// 19:       decorator.construct_props_without_defaults(self, hash)
// 20:
// 21:     if hash_keys_matching_props < hash.size
// 22:       raise ArgumentError.new("#{self.class}: Unrecognized properties: #{(hash.keys - decorator.props.keys).join(', ')}")
// 23:     end
// 24:   end
// 25: end
// 26:
// 27: module T::Props::WeakConstructor::DecoratorMethods
// 28:   extend T::Sig
// 29:
// 30:   # Set values for all props that have no defaults. Ignore any not present.
// 31:   #
// 32:   # @return [Integer] A count of props that we successfully initialized (which
// 33:   # we'll use to check for any unrecognized input.)
// 34:   #
// 35:   # checked(:never) - O(runtime object construction)
// 36:   sig { params(instance: T::Props::WeakConstructor, hash: T::Hash[Symbol, T.untyped]).returns(Integer).checked(:never) }
// 37:   def construct_props_without_defaults(instance, hash)
// 38:     # Use `each_pair` rather than `count` because, as of Ruby 2.6, the latter delegates to Enumerator
// 39:     # and therefore allocates for each entry.
// 40:     result = 0
// 41:     props_without_defaults&.each_pair do |p, bound_setter|
// 42:       if hash.key?(p)
// 43:         bound_setter.call(instance, hash[p])
// 44:         result += 1
// 45:       end
// 46:     end
// 47:     result
// 48:   end
// 49:
// 50:   # Set values for all props that have defaults. Use the default if and only if
// 51:   # the prop key isn't in the input.
// 52:   #
// 53:   # @return [Integer] A count of props that we successfully initialized (which
// 54:   # we'll use to check for any unrecognized input.)
// 55:   #
// 56:   # checked(:never) - O(runtime object construction)
// 57:   sig { params(instance: T::Props::WeakConstructor, hash: T::Hash[Symbol, T.untyped]).returns(Integer).checked(:never) }
// 58:   def construct_props_with_defaults(instance, hash)
// 59:     # Use `each_pair` rather than `count` because, as of Ruby 2.6, the latter delegates to Enumerator
// 60:     # and therefore allocates for each entry.
// 61:     result = 0
// 62:     props_with_defaults&.each_pair do |p, default_struct|
// 63:       if hash.key?(p)
// 64:         default_struct.bound_setter_proc.call(instance, hash[p])
// 65:         result += 1
// 66:       else
// 67:         default_struct.set_default(instance)
// 68:       end
// 69:     end
// 70:     result
// 71:   end
// 72: end
