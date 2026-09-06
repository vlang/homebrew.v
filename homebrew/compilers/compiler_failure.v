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

fn compiler_value(compiler Compiler) ruby.Value {
	return ruby.structured_value('CompilerSelector::Compiler', compiler.name, {
		'type':    compiler.compiler_type
		'name':    compiler.name
		'version': compiler.version.to_s()
		'null':    compiler.version.is_null().str()
	})
}
