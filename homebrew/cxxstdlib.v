module homebrew

import ruby

// Translated from Homebrew/brew `cxxstdlib.rb`.
// The original source is retained below until every stub has a typed V body.

// CxxStdlibType translates the two Ruby symbols accepted by CxxStdlib.create.
pub enum CxxStdlibType {
	libstdcxx
	libcxx
}

// CxxStdlib translates Homebrew's combination of compiler and C++ standard
// library. `has_type` preserves Ruby's nilable type attribute.
pub struct CxxStdlib {
pub:
	has_type    bool
	stdlib_type CxxStdlibType
	compiler    string
}

// create_cxxstdlib translates CxxStdlib.create and initialize. An empty type
// symbol represents Ruby nil.
pub fn create_cxxstdlib(type_symbol string, compiler string) !CxxStdlib {
	normalized_type := type_symbol.trim_left(':')
	if normalized_type !in ['', 'libstdcxx', 'libcxx'] {
		return error('Invalid C++ stdlib type: ${type_symbol}')
	}
	return CxxStdlib{
		has_type:    normalized_type != ''
		stdlib_type: if normalized_type == 'libstdcxx' {
			CxxStdlibType.libstdcxx
		} else {
			CxxStdlibType.libcxx
		}
		compiler:    compiler.trim_left(':')
	}
}

// type_symbol translates the nilable Ruby type reader to its symbol spelling.
pub fn (stdlib CxxStdlib) type_symbol() string {
	return if stdlib.has_type { stdlib.stdlib_type.str() } else { '' }
}

// type_string translates the source's cxx-to-c++ suffix substitution.
pub fn (stdlib CxxStdlib) type_string() string {
	type_symbol := stdlib.type_symbol()
	return if type_symbol.ends_with('cxx') {
		type_symbol[..type_symbol.len - 3] + 'c++'
	} else {
		type_symbol
	}
}

// inspect translates CxxStdlib#inspect.
pub fn (stdlib CxxStdlib) inspect() string {
	return '#<CxxStdlib: ${stdlib.compiler} ${stdlib.type_symbol()}>'
}

fn cxxstdlib_boundary_value(stdlib CxxStdlib) ruby.Value {
	return ruby.structured_value('CxxStdlib', stdlib.inspect(), {
		'type':     stdlib.type_symbol()
		'compiler': stdlib.compiler
	})
}

fn cxxstdlib_from_boundary(value ruby.Value) CxxStdlib {
	if value.type_name != 'CxxStdlib' {
		panic('expected CxxStdlib, got ${value.type_name}')
	}
	type_symbol := value.attribute('type') or { panic(err) }
	compiler := value.attribute('compiler') or { panic(err) }
	return create_cxxstdlib(type_symbol, compiler) or { panic(err) }
}

// Ruby method `self.create(type, compiler)` at line 9.
pub fn ruby_cxxstdlib_l9_d1_self_create(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CxxStdlib.create requires type and compiler')
	}
	type_symbol := if args[0].type_name == 'NilClass' { '' } else { args[0].as_string() }
	return cxxstdlib_boundary_value(create_cxxstdlib(type_symbol, args[1].as_string()) or {
		panic(err)
	})
}

// Ruby attr_reader `attr_reader :type` at line 16.
pub fn ruby_cxxstdlib_l16_d2_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CxxStdlib#type requires a receiver')
	}
	type_symbol := cxxstdlib_from_boundary(args[0]).type_symbol()
	return if type_symbol == '' {
		ruby.object_value('NilClass', '')
	} else {
		ruby.object_value('Symbol', type_symbol)
	}
}

// Ruby attr_reader `attr_reader :compiler` at line 19.
pub fn ruby_cxxstdlib_l19_d3_compiler(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CxxStdlib#compiler requires a receiver')
	}
	return ruby.object_value('Symbol', cxxstdlib_from_boundary(args[0]).compiler)
}

// Ruby method `initialize(type, compiler)` at line 22.
pub fn ruby_cxxstdlib_l22_d4_initialize(args ...ruby.Value) ruby.Value {
	return ruby_cxxstdlib_l9_d1_self_create(...args)
}

// Ruby method `type_string` at line 28.
pub fn ruby_cxxstdlib_l28_d5_type_string(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CxxStdlib#type_string requires a receiver')
	}
	return ruby.string_value(cxxstdlib_from_boundary(args[0]).type_string())
}

// Ruby method `inspect` at line 33.
pub fn ruby_cxxstdlib_l33_d6_inspect(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CxxStdlib#inspect requires a receiver')
	}
	return ruby.string_value(cxxstdlib_from_boundary(args[0]).inspect())
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
