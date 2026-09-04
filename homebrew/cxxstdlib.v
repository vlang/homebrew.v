module homebrew

import ruby

// Translated from Homebrew/brew `cxxstdlib.rb`.

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
		has_type: normalized_type != ''
		stdlib_type: if normalized_type == 'libstdcxx' {
			CxxStdlibType.libstdcxx
		} else {
			CxxStdlibType.libcxx
		}
		compiler: compiler.trim_left(':')
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
