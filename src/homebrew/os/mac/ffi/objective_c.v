module ffi

import brew_runtime

// Translated from Homebrew/brew `os/mac/ffi/objective_c.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.class_get(name)` at line 15.
pub fn ruby_objective_c_l15_d1_self_class_get(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.class_get', ...args)
}

// Ruby method `self.selector(name)` at line 20.
pub fn ruby_objective_c_l20_d2_self_selector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.selector', ...args)
}

// Ruby method `self.message_send(receiver, selector_name, argument_types, return_type, *arguments)` at line 33.
pub fn ruby_objective_c_l33_d3_self_message_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.message_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/native_library"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module FFI
// 9:       module ObjectiveC
// 10:         extend NativeLibrary
// 11:
// 12:         use_library "/usr/lib/libobjc.A.dylib"
// 13:
// 14:         sig { params(name: String).returns(Fiddle::Pointer) }
// 15:         def self.class_get(name)
// 16:           function("objc_getClass", [Fiddle::TYPE_CONST_STRING], Fiddle::TYPE_VOIDP).call(name)
// 17:         end
// 18:
// 19:         sig { params(name: String).returns(Fiddle::Pointer) }
// 20:         def self.selector(name)
// 21:           function("sel_registerName", [Fiddle::TYPE_CONST_STRING], Fiddle::TYPE_VOIDP).call(name)
// 22:         end
// 23:
// 24:         sig {
// 25:           params(
// 26:             receiver:       Fiddle::Pointer,
// 27:             selector_name:  String,
// 28:             argument_types: T::Array[Integer],
// 29:             return_type:    Integer,
// 30:             arguments:      T.untyped,
// 31:           ).returns(T.untyped)
// 32:         }
// 33:         def self.message_send(receiver, selector_name, argument_types, return_type, *arguments)
// 34:           function("objc_msgSend", [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, *argument_types], return_type)
// 35:             .call(receiver, selector(selector_name), *arguments)
// 36:         end
// 37:       end
// 38:     end
// 39:   end
// 40: end
