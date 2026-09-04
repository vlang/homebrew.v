module compilers

import ruby
import homebrew

// Translated from Homebrew/brew `compilers/compiler_failure.rb`.
@[heap]
pub struct CompilerFailure {
pub:
	compiler_type     string
	exact_major_match bool
mut:
	failure_version homebrew.Version
}

pub struct Compiler {
pub:
	compiler_type string
	name          string
	version       homebrew.Version
}

pub type CompilerFailureConfigure = fn (mut CompilerFailure) !

pub fn new_compiler_failure(compiler_type string, version string, exact_major_match bool) !&CompilerFailure {
	return &CompilerFailure{
		compiler_type: compiler_type.trim_string_left(':')
		failure_version: homebrew.new_version(version)!
		exact_major_match: exact_major_match
	}
}

pub fn create_symbol_failure(compiler_type string) !&CompilerFailure {
	return new_compiler_failure(compiler_type, '9999', false)
}

pub fn create_gcc_failure(major_version string) !&CompilerFailure {
	return new_compiler_failure('gcc', '${major_version}.999', true)
}

pub fn create_symbol_failure_with(compiler_type string, configure CompilerFailureConfigure) !&CompilerFailure {
	mut failure := create_symbol_failure(compiler_type)!
	configure(mut failure)!
	return failure
}

pub fn create_gcc_failure_with(major_version string, configure CompilerFailureConfigure) !&CompilerFailure {
	mut failure := create_gcc_failure(major_version)!
	configure(mut failure)!
	return failure
}

pub fn (failure &CompilerFailure) version_value() homebrew.Version {
	return failure.failure_version
}

pub fn (mut failure CompilerFailure) set_version(value string) !homebrew.Version {
	failure.failure_version = homebrew.new_version(value)!
	return failure.failure_version
}

pub fn (failure &CompilerFailure) cause(_ string) {}

pub fn gcc_major(version homebrew.Version) homebrew.Version {
	major := version.major() or { return homebrew.null_version() }
	return homebrew.new_version(major.to_s()) or { homebrew.null_version() }
}

pub fn (failure &CompilerFailure) fails_with(compiler Compiler) bool {
	version_matched := if failure.compiler_type != 'gcc' {
		failure.failure_version.compare_to(compiler.version) >= 0
	} else if failure.exact_major_match {
		gcc_major(failure.failure_version).compare_to(gcc_major(compiler.version)) == 0 && failure.failure_version.compare_to(compiler.version) >= 0
	} else {
		gcc_major(failure.failure_version).compare_to(gcc_major(compiler.version)) >= 0
	}
	return failure.compiler_type == compiler.compiler_type && version_matched
}

pub fn (failure &CompilerFailure) inspect() string {
	return '#<CompilerFailure: ${failure.compiler_type} ${failure.failure_version.to_s()}>'
}

fn compiler_failure_version_value(version homebrew.Version) ruby.Value {
	return ruby.structured_value('Version', version.to_s(), {
		'null': version.is_null().str()
	})
}

fn compiler_failure_version_from_value(value ruby.Value) homebrew.Version {
	if (value.attribute('null') or { 'false' }) == 'true' {
		return homebrew.null_version()
	}
	return homebrew.new_version(value.as_string()) or { panic(err) }
}

fn compiler_failure_value(failure &CompilerFailure) ruby.Value {
	return ruby.structured_value('CompilerFailure', failure.inspect(), {
		'compiler_failure_address': u64(voidptr(failure)).str()
		'type':                     failure.compiler_type
		'version':                  failure.failure_version.to_s()
		'exact_major_match':        failure.exact_major_match.str()
	})
}

fn compiler_failure_from_value(value ruby.Value) &CompilerFailure {
	if address := value.attribute('compiler_failure_address') {
		return unsafe { &CompilerFailure(voidptr(address.u64())) }
	}
	return new_compiler_failure(value.attribute('type') or { '' }, value.attribute('version') or {
		'9999'
	}, (value.attribute('exact_major_match') or { 'false' }) == 'true') or { panic(err) }
}

fn compiler_value(compiler Compiler) ruby.Value {
	return ruby.structured_value('CompilerSelector::Compiler', compiler.name, {
		'type':    compiler.compiler_type
		'name':    compiler.name
		'version': compiler.version.to_s()
		'null':    compiler.version.is_null().str()
	})
}

fn compiler_from_value(value ruby.Value) Compiler {
	return Compiler{
		compiler_type: (value.attribute('type') or { '' }).trim_string_left(':')
		name: value.attribute('name') or { value.as_string() }
		version: if (value.attribute('null') or { 'false' }) == 'true' {
			homebrew.null_version()
		} else {
			homebrew.new_version(value.attribute('version') or { value.as_string() }) or { panic(err) }
		}
	}
}

// Ruby attr_reader `type` at line 7.
pub fn ruby_compiler_failure_l7_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure#type requires a receiver')
	}
	return ruby.object_value('Symbol', compiler_failure_from_value(args[0]).compiler_type)
}

// Ruby method `version(val = T.unsafe(nil))` at line 10.
pub fn ruby_compiler_failure_l10_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure#version requires a receiver')
	}
	mut failure := compiler_failure_from_value(args[0])
	if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		failure.set_version(args[1].as_string()) or { panic(err) }
	}
	return compiler_failure_version_value(failure.version_value())
}

// Ruby alias `build version` at line 17.
pub fn ruby_compiler_failure_l17_build(args ...ruby.Value) ruby.Value {
	return ruby_compiler_failure_l10_version(...args)
}

// Ruby method `cause(_); end` at line 21.
pub fn ruby_compiler_failure_l21_cause(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure#cause requires a receiver')
	}
	compiler_failure_from_value(args[0]).cause(if args.len > 1 { args[1].as_string() } else { '' })
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.create(spec, &block)` at line 31.
pub fn ruby_compiler_failure_l31_self_create(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure.create requires a compiler specification')
	}
	mut failure := if args[0].type_name == 'Hash' {
		if args[0].map_data.len != 1 || 'gcc' !in args[0].map_data {
			panic('The `fails_with` hash syntax only supports GCC')
		}
		create_gcc_failure(args[0].map_data['gcc'].as_string()) or { panic(err) }
	} else {
		create_symbol_failure(args[0].as_string()) or { panic(err) }
	}
	// A translated block supplies the value assigned by `version`/`build`.
	if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		failure.set_version(args[1].as_string()) or { panic(err) }
	}
	return compiler_failure_value(failure)
}

// Ruby method `fails_with?(compiler)` at line 50.
pub fn ruby_compiler_failure_l50_fails_with(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CompilerFailure#fails_with? requires a receiver and compiler')
	}
	return ruby.bool_value(compiler_failure_from_value(args[0]).fails_with(compiler_from_value(args[1])))
}

// Ruby method `inspect` at line 62.
pub fn ruby_compiler_failure_l62_inspect(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure#inspect requires a receiver')
	}
	return ruby.string_value(compiler_failure_from_value(args[0]).inspect())
}

// Ruby method `initialize(type, version, exact_major_match:, &block)` at line 76.
pub fn ruby_compiler_failure_l76_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('CompilerFailure#initialize requires type, version, and exact_major_match')
	}
	failure := new_compiler_failure(args[0].as_string(), args[1].as_string(), args[2].as_bool() or {
		panic(err)
	}) or { panic(err) }
	return compiler_failure_value(failure)
}

// Ruby method `gcc_major(version)` at line 84.
pub fn ruby_compiler_failure_l84_gcc_major(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CompilerFailure#gcc_major requires a version')
	}
	value := args[args.len - 1]
	return compiler_failure_version_value(gcc_major(compiler_failure_version_from_value(value)))
}
