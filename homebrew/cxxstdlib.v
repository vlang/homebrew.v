module homebrew

import brew_runtime

// Translated from Homebrew/brew `cxxstdlib.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.create(type, compiler)` at line 9.
pub fn ruby_cxxstdlib_l9_d1_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Ruby attr_reader `attr_reader :type` at line 16.
pub fn ruby_cxxstdlib_l16_d2_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby attr_reader `attr_reader :compiler` at line 19.
pub fn ruby_cxxstdlib_l19_d3_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compiler', ...args)
}

// Ruby method `initialize(type, compiler)` at line 22.
pub fn ruby_cxxstdlib_l22_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `type_string` at line 28.
pub fn ruby_cxxstdlib_l28_d5_type_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_string', ...args)
}

// Ruby method `inspect` at line 33.
pub fn ruby_cxxstdlib_l33_d6_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5:
// 6: # Combination of C++ standard library and compiler.
// 7: class CxxStdlib
// 8:   sig { params(type: T.nilable(Symbol), compiler: T.any(Symbol, String)).returns(CxxStdlib) }
// 9:   def self.create(type, compiler)
// 10:     raise ArgumentError, "Invalid C++ stdlib type: #{type}" if type && [:libstdcxx, :libcxx].exclude?(type)
// 11:
// 12:     CxxStdlib.new(type, compiler)
// 13:   end
// 14:
// 15:   sig { returns(T.nilable(Symbol)) }
// 16:   attr_reader :type
// 17:
// 18:   sig { returns(Symbol) }
// 19:   attr_reader :compiler
// 20:
// 21:   sig { params(type: T.nilable(Symbol), compiler: T.any(Symbol, String)).void }
// 22:   def initialize(type, compiler)
// 23:     @type = type
// 24:     @compiler = T.let(compiler.to_sym, Symbol)
// 25:   end
// 26:
// 27:   sig { returns(String) }
// 28:   def type_string
// 29:     type.to_s.gsub(/cxx$/, "c++")
// 30:   end
// 31:
// 32:   sig { returns(String) }
// 33:   def inspect
// 34:     "#<#{self.class.name}: #{compiler} #{type}>"
// 35:   end
// 36: end
