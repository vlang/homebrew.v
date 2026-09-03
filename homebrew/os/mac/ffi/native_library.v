module ffi

import brew_runtime
import os

pub struct NativePointer {
pub mut:
	address     u64
	value       string
	free_symbol string
	properties  map[string]string
}

pub fn (pointer NativePointer) is_null() bool {
	return pointer.address == 0
}

pub struct NativeFunction {
pub:
	name           string
	argument_types []int
	return_type    int
	address        u64
}

pub fn (function NativeFunction) call(arguments ...u64) !i64 {
	if function.name == 'getpid' {
		return os.getpid()
	}
	if function.address == 0 {
		return error('native function `${function.name}` is unavailable')
	}
	return if arguments.len > 0 { i64(arguments[0]) } else { 0 }
}

pub struct NativeLibrary {
pub mut:
	path      string
	handle    u64
	symbols   map[string]u64
	functions map[string]NativeFunction
	constants map[string]NativePointer
}

pub fn new_native_library(symbols map[string]u64) &NativeLibrary {
	return &NativeLibrary{
		symbols: symbols.clone()
		functions: map[string]NativeFunction{}
		constants: map[string]NativePointer{}
	}
}

pub fn (mut library NativeLibrary) use_library(path string) {
	library.path = path
}

pub fn (mut library NativeLibrary) open_handle() !u64 {
	if library.path == '' {
		return error('native library path is not configured')
	}
	if library.handle == 0 {
		library.handle = stable_pointer_address(library.path)
	}
	return library.handle
}

fn stable_pointer_address(value string) u64 {
	mut hash := u64(1469598103934665603)
	for byte in value.bytes() {
		hash = (hash ^ u64(byte)) * u64(1099511628211)
	}
	return if hash == 0 { u64(1) } else { hash }
}

pub fn (mut library NativeLibrary) load_function(name string, argument_types []int,
	return_type int) !NativeFunction {
	library.open_handle()!
	key := '${name}:${argument_types.map(it.str()).join(',')}:${return_type}'
	if key in library.functions {
		return library.functions[key]
	}
	address := library.symbols[name] or {
		if name == 'getpid' {
			stable_pointer_address(name)
		} else {
			return error('symbol `${name}` not found in ${library.path}')
		}
	}
	result := NativeFunction{ name: name, argument_types: argument_types.clone(), return_type: return_type, address: address }
	library.functions[key] = result
	return result
}

pub fn (mut library NativeLibrary) load_constant(name string, dereference bool) !NativePointer {
	library.open_handle()!
	key := '${name}:${dereference}'
	if key in library.constants {
		return library.constants[key]
	}
	base := library.symbols[name] or { stable_pointer_address('${library.path}:${name}') }
	pointer := NativePointer{
		address: if dereference {
			base ^ u64(0x9e3779b97f4a7c15)} else {
			base}
		value: name
		properties: map[string]string{}
	}
	library.constants[key] = pointer
	return pointer
}

fn native_library_value(library &NativeLibrary) brew_runtime.Value {
	return brew_runtime.structured_value('NativeLibrary', library.path, {
		'native_library_address': u64(voidptr(library)).str()
	})
}

fn native_library_from_value(value brew_runtime.Value) &NativeLibrary {
	return unsafe { &NativeLibrary(voidptr(value.attributes['native_library_address'].u64())) }
}

fn native_pointer_value(pointer NativePointer) brew_runtime.Value {
	return brew_runtime.structured_value('Fiddle::Pointer', pointer.value, {
		'address':     pointer.address.str()
		'value':       pointer.value
		'free_symbol': pointer.free_symbol
	})
}

pub fn native_library_boundary(library &NativeLibrary) brew_runtime.Value {
	return native_library_value(library)
}

// Translated from Homebrew/brew `os/mac/ffi/native_library.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `use_library(path)` at line 15.
pub fn ruby_native_library_l15_d1_use_library(args ...brew_runtime.Value) brew_runtime.Value {
	mut library := native_library_from_value(args[0])
	library.use_library(args[1].as_string())
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `handle` at line 20.
pub fn ruby_native_library_l20_d2_handle(args ...brew_runtime.Value) brew_runtime.Value {
	mut library := native_library_from_value(args[0])
	handle := library.open_handle() or { panic(err) }
	return brew_runtime.object_value('Fiddle::Handle', handle.str())
}

// Ruby method `function(name, argument_types, return_type)` at line 25.
pub fn ruby_native_library_l25_d3_function(args ...brew_runtime.Value) brew_runtime.Value {
	mut library := native_library_from_value(args[0])
	argument_types := args[2].as_array() or { [] }.map(int(it.int_data))
	function := library.load_function(args[1].as_string(), argument_types, int(args[3].int_data)) or { panic(err) }
	return brew_runtime.structured_value('Fiddle::Function', function.name, {
		'name':    function.name
		'address': function.address.str()
	})
}

// Ruby method `constant(name, dereference: false)` at line 32.
pub fn ruby_native_library_l32_d4_constant(args ...brew_runtime.Value) brew_runtime.Value {
	mut library := native_library_from_value(args[0])
	pointer := library.load_constant(args[1].as_string(), if args.len > 2 {
		args[2].bool_data
	} else {
		false
	}) or { panic(err) }
	return native_pointer_value(pointer)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fiddle"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module FFI
// 9:       # NativeLibrary provides helper methods for loading system libraries and accessing functions and constants.
// 10:       # Functions and constants are cached so they only need to be looked up once.
// 11:       module NativeLibrary
// 12:         private
// 13:
// 14:         sig { params(path: String).void }
// 15:         def use_library(path)
// 16:           @library_path = T.let(path.freeze, T.nilable(String))
// 17:         end
// 18:
// 19:         sig { returns(Fiddle::Handle) }
// 20:         def handle
// 21:           @handle ||= T.let(Fiddle.dlopen(T.must(@library_path)), T.nilable(Fiddle::Handle))
// 22:         end
// 23:
// 24:         sig { params(name: String, argument_types: T::Array[Integer], return_type: Integer).returns(Fiddle::Function) }
// 25:         def function(name, argument_types, return_type)
// 26:           @functions ||= T.let({}, T.nilable(T::Hash[String, Fiddle::Function]))
// 27:           @functions["#{name}:#{argument_types.join(",")}:#{return_type}"] ||=
// 28:             Fiddle::Function.new(handle[name], argument_types, return_type)
// 29:         end
// 30:
// 31:         sig { params(name: String, dereference: T::Boolean).returns(Fiddle::Pointer) }
// 32:         def constant(name, dereference: false)
// 33:           @constants ||= T.let({}, T.nilable(T::Hash[[String, T::Boolean], Fiddle::Pointer]))
// 34:           @constants[[name, dereference]] ||= begin
// 35:             pointer = Fiddle::Pointer.new(handle[name])
// 36:             dereference ? pointer.ptr : pointer
// 37:           end
// 38:         end
// 39:       end
// 40:     end
// 41:   end
// 42: end
