module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_class.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(type)` at line 6.
pub fn ruby_typed_class_l6_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `type` at line 10.
pub fn ruby_typed_class_l10_d2_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `build_type` at line 14.
pub fn ruby_typed_class_l14_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 20.
pub fn ruby_typed_class_l20_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `underlying_class` at line 24.
pub fn ruby_typed_class_l24_d5_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('underlying_class', ...args)
}

// Ruby method `valid?(obj)` at line 29.
pub fn ruby_typed_class_l29_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(type)` at line 34.
pub fn ruby_typed_class_l34_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Ruby method `self.type_for_module(mod)` at line 58.
pub fn ruby_typed_class_l58_d8_self_type_for_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.type_for_module', ...args)
}

// Ruby method `initialize` at line 73.
pub fn ruby_typed_class_l73_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `freeze` at line 77.
pub fn ruby_typed_class_l77_d10_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze', ...args)
}

// Ruby method `initialize` at line 88.
pub fn ruby_typed_class_l88_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `freeze` at line 92.
pub fn ruby_typed_class_l92_d12_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedClass < T::Types::Base
// 6:     def initialize(type)
// 7:       @inner_type = type
// 8:     end
// 9:
// 10:     def type
// 11:       @type ||= T::Utils.coerce(@inner_type)
// 12:     end
// 13:
// 14:     def build_type
// 15:       type
// 16:       nil
// 17:     end
// 18:
// 19:     # overrides Base
// 20:     def name
// 21:       "T::Class[#{type.name}]"
// 22:     end
// 23:
// 24:     def underlying_class
// 25:       Class
// 26:     end
// 27:
// 28:     # overrides Base
// 29:     def valid?(obj)
// 30:       Class.===(obj)
// 31:     end
// 32:
// 33:     # overrides Base
// 34:     private def subtype_of_single?(type)
// 35:       case type
// 36:       when TypedClass, TypedModule
// 37:         # treat like generics are erased
// 38:         true
// 39:       when Simple
// 40:         Class <= type.raw_type
// 41:       else
// 42:         false
// 43:       end
// 44:     end
// 45:
// 46:     module Private
// 47:       module Pool
// 48:         CACHE_FROZEN_OBJECTS =
// 49:           begin
// 50:             ObjectSpace::WeakMap.new[1] = 1
// 51:             true # Ruby 2.7 and newer
// 52:           rescue ArgumentError
// 53:             false # Ruby 2.6 and older
// 54:           end
// 55:
// 56:         @cache = ObjectSpace::WeakMap.new
// 57:
// 58:         def self.type_for_module(mod)
// 59:           cached = @cache[mod]
// 60:           return cached if cached
// 61:
// 62:           type = TypedClass.new(mod)
// 63:
// 64:           if CACHE_FROZEN_OBJECTS || (!mod.frozen? && !type.frozen?)
// 65:             @cache[mod] = type
// 66:           end
// 67:           type
// 68:         end
// 69:       end
// 70:     end
// 71:
// 72:     class Untyped < TypedClass
// 73:       def initialize
// 74:         super(T::Types::Untyped::Private::INSTANCE)
// 75:       end
// 76:
// 77:       def freeze
// 78:         build_type # force lazy initialization before freezing the object
// 79:         super
// 80:       end
// 81:
// 82:       module Private
// 83:         INSTANCE = Untyped.new.freeze
// 84:       end
// 85:     end
// 86:
// 87:     class Anything < TypedClass
// 88:       def initialize
// 89:         super(T.anything)
// 90:       end
// 91:
// 92:       def freeze
// 93:         build_type # force lazy initialization before freezing the object
// 94:         super
// 95:       end
// 96:
// 97:       module Private
// 98:         INSTANCE = Anything.new.freeze
// 99:       end
// 100:     end
// 101:   end
// 102: end
