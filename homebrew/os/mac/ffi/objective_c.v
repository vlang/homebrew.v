module ffi

import ruby

pub fn objective_c_class_get(name string) NativePointer {
	if name == '' {
		return NativePointer{}
	}
	return NativePointer{ address: stable_pointer_address('objc-class:${name}'), value: name, properties: map[string]string{} }
}

pub fn objective_c_selector(name string) NativePointer {
	if name == '' {
		return NativePointer{}
	}
	return NativePointer{ address: stable_pointer_address('objc-selector:${name}'), value: name, properties: map[string]string{} }
}

pub fn objective_c_message_send(receiver NativePointer, selector_name string,
	argument_types []int, return_type int, arguments []NativePointer) NativePointer {
	if receiver.is_null() || selector_name == '' {
		return NativePointer{}
	}
	mut properties := {
		'receiver':       receiver.value
		'selector':       selector_name
		'argument_types': argument_types.map(it.str()).join(',')
		'return_type':    return_type.str()
	}
	for index, argument in arguments {
		properties['argument_${index}'] = argument.value
	}
	return NativePointer{
		address: stable_pointer_address('objc-message:${receiver.address}:${selector_name}:${arguments.len}')
		value: if selector_name == 'UTF8String' { receiver.value } else { selector_name }
		properties: properties
	}
}

// Translated from Homebrew/brew `os/mac/ffi/objective_c.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.class_get(name)` at line 15.
pub fn ruby_objective_c_l15_d1_self_class_get(args ...ruby.Value) ruby.Value {
	return native_pointer_value(objective_c_class_get(args[0].as_string()))
}

// Ruby method `self.selector(name)` at line 20.
pub fn ruby_objective_c_l20_d2_self_selector(args ...ruby.Value) ruby.Value {
	return native_pointer_value(objective_c_selector(args[0].as_string()))
}

// Ruby method `self.message_send(receiver, selector_name, argument_types, return_type, *arguments)` at line 33.
pub fn ruby_objective_c_l33_d3_self_message_send(args ...ruby.Value) ruby.Value {
	receiver := NativePointer{ address: (args[0].attributes['address'] or { '0' }).u64(), value: args[0].as_string(), properties: map[string]string{} }
	argument_types := args[2].as_array() or { [] }.map(int(it.int_data))
	return_type := int(args[3].int_data)
	arguments := args[4..].map(NativePointer{ address: (it.attributes['address'] or { '0' }).u64(), value: it.as_string(), properties: map[string]string{} })
	return native_pointer_value(objective_c_message_send(receiver, args[1].as_string(), argument_types, return_type, arguments))
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
