module compilers

import brew_runtime

// Translated from Homebrew/brew `compilers/compiler_selector.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.select_for(formula, compilers = nil, testing_formula: false)` at line 23.
pub fn ruby_compiler_selector_l23_self_select_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.select_for', ...args)
}

// Ruby method `self.compilers` at line 34.
pub fn ruby_compiler_selector_l34_self_compilers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.compilers', ...args)
}

// Ruby attr_reader `formula` at line 39.
pub fn ruby_compiler_selector_l39_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby attr_reader `failures` at line 42.
pub fn ruby_compiler_selector_l42_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('failures', ...args)
}

// Ruby attr_reader `versions` at line 45.
pub fn ruby_compiler_selector_l45_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versions', ...args)
}

// Ruby attr_reader `compilers` at line 48.
pub fn ruby_compiler_selector_l48_compilers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compilers', ...args)
}

// Ruby method `initialize(formula, versions, compilers)` at line 57.
pub fn ruby_compiler_selector_l57_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `compiler` at line 65.
pub fn ruby_compiler_selector_l65_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compiler', ...args)
}

// Ruby method `self.preferred_gcc` at line 71.
pub fn ruby_compiler_selector_l71_self_preferred_gcc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.preferred_gcc', ...args)
}

// Ruby method `gnu_gcc_versions` at line 78.
pub fn ruby_compiler_selector_l78_gnu_gcc_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnu_gcc_versions', ...args)
}

// Ruby method `find_compiler(&_block)` at line 87.
pub fn ruby_compiler_selector_l87_find_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_compiler', ...args)
}

// Ruby method `fails_with?(compiler)` at line 106.
pub fn ruby_compiler_selector_l106_fails_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails_with?', ...args)
}

// Ruby method `compiler_version(name)` at line 111.
pub fn ruby_compiler_selector_l111_compiler_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compiler_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Class for selecting a compiler for a formula.
// 5: class CompilerSelector
// 6:   include CompilerConstants
// 7:
// 8:   class Compiler < T::Struct
// 9:     const :type, Symbol
// 10:     const :name, T.any(String, Symbol)
// 11:     const :version, Version
// 12:   end
// 13:
// 14:   COMPILER_PRIORITY = T.let({
// 15:     clang: [:clang, :llvm_clang, :gnu],
// 16:     gcc:   [:gnu, :gcc, :llvm_clang, :clang],
// 17:   }.freeze, T::Hash[Symbol, T::Array[Symbol]])
// 18:
// 19:   sig {
// 20:     params(formula: T.any(Formula, SoftwareSpec), compilers: T.nilable(T::Array[Symbol]), testing_formula: T::Boolean)
// 21:       .returns(T.any(String, Symbol))
// 22:   }
// 23:   def self.select_for(formula, compilers = nil, testing_formula: false)
// 24:     if compilers.nil? && DevelopmentTools.default_compiler == :clang
// 25:       deps = formula.deps.filter_map do |dep|
// 26:         dep.name if dep.required? || (testing_formula && dep.test?) || (!testing_formula && dep.build?)
// 27:       end
// 28:       compilers = [:clang, :gnu, :llvm_clang] if deps.none?("llvm") && deps.any?(/^gcc(@\d+)?$/)
// 29:     end
// 30:     new(formula, DevelopmentTools, compilers || self.compilers).compiler
// 31:   end
// 32:
// 33:   sig { returns(T::Array[Symbol]) }
// 34:   def self.compilers
// 35:     COMPILER_PRIORITY.fetch(DevelopmentTools.default_compiler)
// 36:   end
// 37:
// 38:   sig { returns(T.any(Formula, SoftwareSpec)) }
// 39:   attr_reader :formula
// 40:
// 41:   sig { returns(T::Array[CompilerFailure]) }
// 42:   attr_reader :failures
// 43:
// 44:   sig { returns(T.class_of(DevelopmentTools)) }
// 45:   attr_reader :versions
// 46:
// 47:   sig { returns(T::Array[Symbol]) }
// 48:   attr_reader :compilers
// 49:
// 50:   sig {
// 51:     params(
// 52:       formula:   T.any(Formula, SoftwareSpec),
// 53:       versions:  T.class_of(DevelopmentTools),
// 54:       compilers: T::Array[Symbol],
// 55:     ).void
// 56:   }
// 57:   def initialize(formula, versions, compilers)
// 58:     @formula = formula
// 59:     @failures = T.let(formula.compiler_failures, T::Array[CompilerFailure])
// 60:     @versions = versions
// 61:     @compilers = compilers
// 62:   end
// 63:
// 64:   sig { returns(T.any(String, Symbol)) }
// 65:   def compiler
// 66:     find_compiler { |c| return c.name unless fails_with?(c) }
// 67:     raise CompilerSelectionError, formula
// 68:   end
// 69:
// 70:   sig { returns(String) }
// 71:   def self.preferred_gcc
// 72:     "gcc"
// 73:   end
// 74:
// 75:   private
// 76:
// 77:   sig { returns(T::Array[String]) }
// 78:   def gnu_gcc_versions
// 79:     # prioritize gcc version provided by gcc formula.
// 80:     v = Formulary.factory(CompilerSelector.preferred_gcc).version.to_s.slice(/\d+/)
// 81:     GNU_GCC_VERSIONS - [v] + [v] # move the version to the end of the list
// 82:   rescue FormulaUnavailableError
// 83:     GNU_GCC_VERSIONS
// 84:   end
// 85:
// 86:   sig { params(_block: T.proc.params(arg0: Compiler).void).void }
// 87:   def find_compiler(&_block)
// 88:     compilers.each do |compiler|
// 89:       case compiler
// 90:       when :gnu
// 91:         gnu_gcc_versions.reverse_each do |v|
// 92:           executable = "gcc-#{v}"
// 93:           version = compiler_version(executable)
// 94:           yield Compiler.new(type: :gcc, name: executable, version:) unless version.null?
// 95:         end
// 96:       when :llvm
// 97:         next # no-op. DSL supported, compiler is not.
// 98:       else
// 99:         version = compiler_version(compiler)
// 100:         yield Compiler.new(type: compiler, name: compiler, version:) unless version.null?
// 101:       end
// 102:     end
// 103:   end
// 104:
// 105:   sig { params(compiler: Compiler).returns(T::Boolean) }
// 106:   def fails_with?(compiler)
// 107:     failures.any? { |failure| failure.fails_with?(compiler) }
// 108:   end
// 109:
// 110:   sig { params(name: T.any(String, Symbol)).returns(Version) }
// 111:   def compiler_version(name)
// 112:     case name.to_s
// 113:     when "gcc", GNU_GCC_REGEXP
// 114:       versions.gcc_version(name.to_s)
// 115:     else
// 116:       versions.public_send(:"#{name}_build_version")
// 117:     end
// 118:   end
// 119: end
