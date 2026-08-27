module homebrew

import brew_runtime

// Translated from Homebrew/brew `dependencies.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args)` at line 15.
pub fn ruby_dependencies_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby alias `alias eql? ==` at line 19.
pub fn ruby_dependencies_l19_d2_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `optional` at line 22.
pub fn ruby_dependencies_l22_d3_optional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional', ...args)
}

// Ruby method `recommended` at line 27.
pub fn ruby_dependencies_l27_d4_recommended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recommended', ...args)
}

// Ruby method `build` at line 32.
pub fn ruby_dependencies_l32_d5_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build', ...args)
}

// Ruby method `required` at line 37.
pub fn ruby_dependencies_l37_d6_required(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required', ...args)
}

// Ruby method `default` at line 42.
pub fn ruby_dependencies_l42_d7_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Ruby method `dup_without_system_deps` at line 47.
pub fn ruby_dependencies_l47_d8_dup_without_system_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dup_without_system_deps', ...args)
}

// Ruby method `inspect` at line 52.
pub fn ruby_dependencies_l52_d9_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "delegate"
// 5: require "dependency"
// 6: require "requirement"
// 7:
// 8: # A collection of dependencies.
// 9: class Dependencies < SimpleDelegator
// 10:   extend T::Generic
// 11:
// 12:   Elem = type_member(:out) { { fixed: Dependency } }
// 13:
// 14:   sig { params(args: Dependency).void }
// 15:   def initialize(*args)
// 16:     super(args)
// 17:   end
// 18:
// 19:   alias eql? ==
// 20:
// 21:   sig { returns(T::Array[Dependency]) }
// 22:   def optional
// 23:     __getobj__.select(&:optional?)
// 24:   end
// 25:
// 26:   sig { returns(T::Array[Dependency]) }
// 27:   def recommended
// 28:     __getobj__.select(&:recommended?)
// 29:   end
// 30:
// 31:   sig { returns(T::Array[Dependency]) }
// 32:   def build
// 33:     __getobj__.select(&:build?)
// 34:   end
// 35:
// 36:   sig { returns(T::Array[Dependency]) }
// 37:   def required
// 38:     __getobj__.select(&:required?)
// 39:   end
// 40:
// 41:   sig { returns(T::Array[Dependency]) }
// 42:   def default
// 43:     build + required + recommended
// 44:   end
// 45:
// 46:   sig { returns(Dependencies) }
// 47:   def dup_without_system_deps
// 48:     self.class.new(*__getobj__.reject { |dep| dep.uses_from_macos? && dep.use_macos_install? })
// 49:   end
// 50:
// 51:   sig { returns(String) }
// 52:   def inspect
// 53:     "#<#{self.class.name}: #{__getobj__}>"
// 54:   end
// 55: end
// 56: require "dependencies/requirements"
