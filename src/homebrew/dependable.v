module homebrew

import brew_runtime

// Translated from Homebrew/brew `dependable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tags` at line 29.
pub fn ruby_dependable_l29_d1_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tags', ...args)
}

// Ruby method `option_names; end` at line 34.
pub fn ruby_dependable_l34_d2_option_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option_names', ...args)
}

// Ruby method `build?` at line 37.
pub fn ruby_dependable_l37_d3_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build?', ...args)
}

// Ruby method `optional?` at line 42.
pub fn ruby_dependable_l42_d4_optional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('optional?', ...args)
}

// Ruby method `recommended?` at line 47.
pub fn ruby_dependable_l47_d5_recommended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recommended?', ...args)
}

// Ruby method `test?` at line 52.
pub fn ruby_dependable_l52_d6_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test?', ...args)
}

// Ruby method `implicit?` at line 57.
pub fn ruby_dependable_l57_d7_implicit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('implicit?', ...args)
}

// Ruby method `no_linkage?` at line 62.
pub fn ruby_dependable_l62_d8_no_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_linkage?', ...args)
}

// Ruby method `required?` at line 67.
pub fn ruby_dependable_l67_d9_required(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required?', ...args)
}

// Ruby method `option_tags` at line 72.
pub fn ruby_dependable_l72_d10_option_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option_tags', ...args)
}

// Ruby method `options` at line 77.
pub fn ruby_dependable_l77_d11_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby method `prune_from_option?(build)` at line 82.
pub fn ruby_dependable_l82_d12_prune_from_option(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prune_from_option?', ...args)
}

// Ruby method `prune_if_build_and_not_dependent?(dependent, formula = nil)` at line 89.
pub fn ruby_dependable_l89_d13_prune_if_build_and_not_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prune_if_build_and_not_dependent?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "options"
// 5:
// 6: # Shared functions for classes which can be depended upon.
// 7: module Dependable
// 8:   extend T::Helpers
// 9:
// 10:   # Return from an {Dependency.expand} or {Requirement.expand} block to remove
// 11:   # a dependency/requirement and all of its recursive dependencies from the result list.
// 12:   PRUNE = :prune
// 13:   # Return from a {Dependency.expand} block to omit a dependency from the result
// 14:   # list but continue expanding its children.
// 15:   SKIP = :skip
// 16:   # Return from a {Dependency.expand} block to keep a dependency in the result
// 17:   # list but stop recursing into its own dependencies.
// 18:   KEEP_BUT_PRUNE_RECURSIVE_DEPS = :keep_but_prune_recursive_deps
// 19:
// 20:   # `:run` and `:linked` are no longer used but keep them here to avoid their
// 21:   # misuse in future.
// 22:   RESERVED_TAGS = [:build, :optional, :recommended, :run, :test, :linked, :implicit, :no_linkage].freeze
// 23:
// 24:   abstract!
// 25:
// 26:   requires_ancestor { Kernel }
// 27:
// 28:   sig { returns(T::Array[T.any(Symbol, String, T::Array[T.untyped])]) }
// 29:   def tags
// 30:     @tags ||= T.let([], T.nilable(T::Array[T.any(Symbol, String, T::Array[T.untyped])]))
// 31:   end
// 32:
// 33:   sig { abstract.returns(T::Array[String]) }
// 34:   def option_names; end
// 35:
// 36:   sig { returns(T::Boolean) }
// 37:   def build?
// 38:     tags.include? :build
// 39:   end
// 40:
// 41:   sig { returns(T::Boolean) }
// 42:   def optional?
// 43:     tags.include? :optional
// 44:   end
// 45:
// 46:   sig { returns(T::Boolean) }
// 47:   def recommended?
// 48:     tags.include? :recommended
// 49:   end
// 50:
// 51:   sig { returns(T::Boolean) }
// 52:   def test?
// 53:     tags.include? :test
// 54:   end
// 55:
// 56:   sig { returns(T::Boolean) }
// 57:   def implicit?
// 58:     tags.include? :implicit
// 59:   end
// 60:
// 61:   sig { returns(T::Boolean) }
// 62:   def no_linkage?
// 63:     tags.include? :no_linkage
// 64:   end
// 65:
// 66:   sig { returns(T::Boolean) }
// 67:   def required?
// 68:     !build? && !test? && !optional? && !recommended?
// 69:   end
// 70:
// 71:   sig { returns(T::Array[String]) }
// 72:   def option_tags
// 73:     tags.grep(String)
// 74:   end
// 75:
// 76:   sig { returns(Options) }
// 77:   def options
// 78:     Options.create(option_tags)
// 79:   end
// 80:
// 81:   sig { params(build: BuildOptions).returns(T::Boolean) }
// 82:   def prune_from_option?(build)
// 83:     return false if !optional? && !recommended?
// 84:
// 85:     build.without?(self)
// 86:   end
// 87:
// 88:   sig { params(dependent: T.any(Formula, Dependency), formula: T.nilable(Formula)).returns(T::Boolean) }
// 89:   def prune_if_build_and_not_dependent?(dependent, formula = nil)
// 90:     return false unless build?
// 91:
// 92:     if formula
// 93:       dependent != formula
// 94:     else
// 95:       raise "dependent is not a formula or cask dependent" unless dependent.is_a?(Dependency)
// 96:
// 97:       dependent.installed?
// 98:     end
// 99:   end
// 100: end
