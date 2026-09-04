module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_module.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(type)` at line 6.
pub fn ruby_typed_module_l6_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypedModule#initialize requires a type')
	}
	return typed_meta_value(new_typed_meta_type('Module', args[0]))
}

// Ruby method `type` at line 10.
pub fn ruby_typed_module_l10_d2_type(args ...ruby.Value) ruby.Value {
	return typed_meta_from_args(args, 'Module').type_value
}

// Ruby method `build_type` at line 14.
pub fn ruby_typed_module_l14_d3_build_type(args ...ruby.Value) ruby.Value {
	typed_meta_from_args(args, 'Module').build_type() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `name` at line 20.
pub fn ruby_typed_module_l20_d4_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(typed_meta_from_args(args, 'Module').name())
}

// Ruby method `underlying_class` at line 24.
pub fn ruby_typed_module_l24_d5_underlying_class(args ...ruby.Value) ruby.Value {
	typed_meta_from_args(args, 'Module')
	return ruby.object_value('Class', 'Module')
}

// Ruby method `valid?(obj)` at line 29.
pub fn ruby_typed_module_l29_d6_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypedModule#valid? requires an object')
	}
	return ruby.bool_value(typed_meta_from_args(args, 'Module').valid(args[1]))
}

// Ruby method `subtype_of_single?(type)` at line 34.
pub fn ruby_typed_module_l34_d7_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypedModule#subtype_of_single? requires another type')
	}
	return ruby.bool_value(typed_meta_from_args(args, 'Module').subtype_of_single(args[1]))
}

// Ruby method `self.type_for_module(mod)` at line 58.
pub fn ruby_typed_module_l58_d8_self_type_for_module(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypedModule.type_for_module requires a module')
	}
	return typed_meta_for_module('Module', args[0])
}

// Ruby method `initialize` at line 73.
pub fn ruby_typed_module_l73_d9_initialize(args ...ruby.Value) ruby.Value {
	return typed_meta_value(new_typed_meta_type('Module', base_type_boundary_value(base_untyped_type())))
}

// Ruby method `freeze` at line 77.
pub fn ruby_typed_module_l77_d10_freeze(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypedModule::Untyped#freeze requires a receiver')
	}
	typed_meta_from_args(args, 'Module').build_type() or { panic(err) }
	return args[0]
}

// Ruby method `initialize` at line 88.
pub fn ruby_typed_module_l88_d11_initialize(args ...ruby.Value) ruby.Value {
	return typed_meta_value(new_typed_meta_type('Module', base_type_boundary_value(base_anything_type())))
}

// Ruby method `freeze` at line 92.
pub fn ruby_typed_module_l92_d12_freeze(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypedModule::Anything#freeze requires a receiver')
	}
	typed_meta_from_args(args, 'Module').build_type() or { panic(err) }
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedModule < T::Types::Base
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
// 21:       "T::Module[#{type.name}]"
// 22:     end
// 23:
// 24:     def underlying_class
// 25:       Module
// 26:     end
// 27:
// 28:     # overrides Base
// 29:     def valid?(obj)
// 30:       Module.===(obj)
// 31:     end
// 32:
// 33:     # overrides Base
// 34:     private def subtype_of_single?(type)
// 35:       case type
// 36:       when TypedModule
// 37:         # treat like generics are erased
// 38:         true
// 39:       when Simple
// 40:         Module <= type.raw_type
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
// 62:           type = TypedModule.new(mod)
// 63:
// 64:           if CACHE_FROZEN_OBJECTS || (!mod.frozen? && !type.frozen?)
// 65:             @cache[mod] = type
// 66:           end
// 67:           type
// 68:         end
// 69:       end
// 70:     end
// 71:
// 72:     class Untyped < TypedModule
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
// 87:     class Anything < TypedModule
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
