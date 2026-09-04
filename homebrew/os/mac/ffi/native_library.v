module ffi

import ruby
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
			base ^ u64(0x9e3779b97f4a7c15)
		} else {
			base
		}
		value: name
		properties: map[string]string{}
	}
	library.constants[key] = pointer
	return pointer
}

fn native_library_value(library &NativeLibrary) ruby.Value {
	return ruby.structured_value('NativeLibrary', library.path, {
		'native_library_address': u64(voidptr(library)).str()
	})
}

fn native_library_from_value(value ruby.Value) &NativeLibrary {
	return unsafe { &NativeLibrary(voidptr(value.attributes['native_library_address'].u64())) }
}

fn native_pointer_value(pointer NativePointer) ruby.Value {
	return ruby.structured_value('Fiddle::Pointer', pointer.value, {
		'address':     pointer.address.str()
		'value':       pointer.value
		'free_symbol': pointer.free_symbol
	})
}

pub fn native_library_boundary(library &NativeLibrary) ruby.Value {
	return native_library_value(library)
}

// Translated from Homebrew/brew `os/mac/ffi/native_library.rb`.
