module ffi

import brew_runtime

// Translated from Homebrew/brew `os/mac/ffi/native_library.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `use_library(path)` at line 15.
pub fn ruby_native_library_l15_d1_use_library(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_library', ...args)
}

// Ruby method `handle` at line 20.
pub fn ruby_native_library_l20_d2_handle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handle', ...args)
}

// Ruby method `function(name, argument_types, return_type)` at line 25.
pub fn ruby_native_library_l25_d3_function(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('function', ...args)
}

// Ruby method `constant(name, dereference: false)` at line 32.
pub fn ruby_native_library_l32_d4_constant(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('constant', ...args)
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
