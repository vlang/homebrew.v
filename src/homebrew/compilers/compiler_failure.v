module compilers

import brew_runtime

// Translated from Homebrew/brew `compilers/compiler_failure.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `type` at line 7.
pub fn ruby_compiler_failure_l7_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `version(val = T.unsafe(nil))` at line 10.
pub fn ruby_compiler_failure_l10_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby alias `build version` at line 17.
pub fn ruby_compiler_failure_l17_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build', ...args)
}

// Ruby method `cause(_); end` at line 21.
pub fn ruby_compiler_failure_l21_cause(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cause', ...args)
}

// Ruby method `self.create(spec, &block)` at line 31.
pub fn ruby_compiler_failure_l31_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Ruby method `fails_with?(compiler)` at line 50.
pub fn ruby_compiler_failure_l50_fails_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails_with?', ...args)
}

// Ruby method `inspect` at line 62.
pub fn ruby_compiler_failure_l62_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby method `initialize(type, version, exact_major_match:, &block)` at line 76.
pub fn ruby_compiler_failure_l76_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `gcc_major(version)` at line 84.
pub fn ruby_compiler_failure_l84_gcc_major(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gcc_major', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Class for checking compiler compatibility for a formula.
// 5: class CompilerFailure
// 6:   sig { returns(Symbol) }
// 7:   attr_reader :type
// 8:
// 9:   sig { params(val: T.any(Integer, String)).returns(Version) }
// 10:   def version(val = T.unsafe(nil))
// 11:     @version = Version.parse(val.to_s) if val
// 12:     @version
// 13:   end
// 14:
// 15:   # Allows Apple compiler `fails_with` statements to keep using `build`
// 16:   # even though `build` and `version` are the same internally.
// 17:   alias build version
// 18:
// 19:   # The cause is no longer used so we need not hold a reference to the string.
// 20:   sig { params(_: String).void }
// 21:   def cause(_); end
// 22:
// 23:   sig {
// 24:     params(
// 25:       spec:  T.any(Symbol, T::Hash[Symbol, String]),
// 26:       block: T.nilable(T.proc.bind(CompilerFailure).void),
// 27:     ).returns(
// 28:       T.attached_class,
// 29:     )
// 30:   }
// 31:   def self.create(spec, &block)
// 32:     # Non-Apple compilers are in the format fails_with compiler => version
// 33:     if spec.is_a?(Hash)
// 34:       compiler, major_version = spec.first
// 35:       raise ArgumentError, "The `fails_with` hash syntax only supports GCC" if compiler != :gcc
// 36:
// 37:       type = compiler
// 38:       # so `fails_with gcc: "7"` simply marks all 7 releases incompatible
// 39:       version = "#{major_version}.999"
// 40:       exact_major_match = true
// 41:     else
// 42:       type = spec
// 43:       version = 9999
// 44:       exact_major_match = false
// 45:     end
// 46:     new(type, version, exact_major_match:, &block)
// 47:   end
// 48:
// 49:   sig { params(compiler: CompilerSelector::Compiler).returns(T::Boolean) }
// 50:   def fails_with?(compiler)
// 51:     version_matched = if type != :gcc
// 52:       version >= compiler.version
// 53:     elsif @exact_major_match
// 54:       gcc_major(version) == gcc_major(compiler.version) && version >= compiler.version
// 55:     else
// 56:       gcc_major(version) >= gcc_major(compiler.version)
// 57:     end
// 58:     type == compiler.type && version_matched
// 59:   end
// 60:
// 61:   sig { returns(String) }
// 62:   def inspect
// 63:     "#<#{self.class.name}: #{type} #{version}>"
// 64:   end
// 65:
// 66:   private
// 67:
// 68:   sig {
// 69:     params(
// 70:       type:              Symbol,
// 71:       version:           T.any(Integer, String),
// 72:       exact_major_match: T::Boolean,
// 73:       block:             T.nilable(T.proc.bind(CompilerFailure).void),
// 74:     ).void
// 75:   }
// 76:   def initialize(type, version, exact_major_match:, &block)
// 77:     @type = type
// 78:     @version = T.let(Version.parse(version.to_s), Version)
// 79:     @exact_major_match = exact_major_match
// 80:     instance_eval(&block) if block
// 81:   end
// 82:
// 83:   sig { params(version: Version).returns(Version) }
// 84:   def gcc_major(version)
// 85:     Version.new(version.major.to_s)
// 86:   end
// 87: end
