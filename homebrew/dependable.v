module homebrew

import ruby

// Translated from Homebrew/brew `dependable.rb`.
// The original source is retained below until every stub has a typed V body.

pub const dependable_prune = 'prune'
pub const dependable_skip = 'skip'
pub const dependable_keep_but_prune_recursive_deps = 'keep_but_prune_recursive_deps'
pub const dependable_reserved_tags = ['build', 'optional', 'recommended', 'run', 'test', 'linked',
	'implicit', 'no_linkage']

pub fn (dependency Dependency) option_names() []string {
	parts := dependency.name.split('/')
	if parts.len >= 3 {
		return [parts[2..].join('/')]
	}
	return [dependency.name]
}

pub fn (dependency Dependency) build() bool {
	return dependency.has_symbol_tag('build')
}

pub fn (dependency Dependency) optional() bool {
	return dependency.has_symbol_tag('optional')
}

pub fn (dependency Dependency) recommended() bool {
	return dependency.has_symbol_tag('recommended')
}

pub fn (dependency Dependency) test() bool {
	return dependency.has_symbol_tag('test')
}

pub fn (dependency Dependency) implicit() bool {
	return dependency.has_symbol_tag('implicit')
}

pub fn (dependency Dependency) no_linkage() bool {
	return dependency.has_symbol_tag('no_linkage')
}

pub fn (dependency Dependency) required() bool {
	return !dependency.build() && !dependency.test() && !dependency.optional()
		&& !dependency.recommended()
}

pub fn (dependency Dependency) option_tags() []string {
	return dependency.tags.filter(it.kind == .option).map(it.value)
}

pub fn (dependency Dependency) options() Options {
	return new_options(...dependency.option_tags())
}

pub fn (dependency Dependency) prune_from_option(build BuildOptions) bool {
	if !dependency.optional() && !dependency.recommended() {
		return false
	}
	return build.without_dependable(dependency)
}

pub fn (dependency Dependency) prune_if_build_and_not_formula(dependent_name string, formula_name string) bool {
	return dependency.build() && dependent_name != formula_name
}

pub fn (dependency Dependency) prune_if_build_and_dependency_installed(installed bool) bool {
	return dependency.build() && installed
}

// Ruby method `tags` at line 29.
pub fn ruby_dependable_l29_d1_tags(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'tags')
	return ruby.string_array_value(dependency.tags.map(it.boundary_string()))
}

// Ruby method `option_names; end` at line 34.
pub fn ruby_dependable_l34_d2_option_names(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(dependable_boundary_receiver(args, 'option_names').option_names())
}

// Ruby method `build?` at line 37.
pub fn ruby_dependable_l37_d3_build(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'build?').build())
}

// Ruby method `optional?` at line 42.
pub fn ruby_dependable_l42_d4_optional(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'optional?').optional())
}

// Ruby method `recommended?` at line 47.
pub fn ruby_dependable_l47_d5_recommended(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'recommended?').recommended())
}

// Ruby method `test?` at line 52.
pub fn ruby_dependable_l52_d6_test(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'test?').test())
}

// Ruby method `implicit?` at line 57.
pub fn ruby_dependable_l57_d7_implicit(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'implicit?').implicit())
}

// Ruby method `no_linkage?` at line 62.
pub fn ruby_dependable_l62_d8_no_linkage(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'no_linkage?').no_linkage())
}

// Ruby method `required?` at line 67.
pub fn ruby_dependable_l67_d9_required(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(dependable_boundary_receiver(args, 'required?').required())
}

// Ruby method `option_tags` at line 72.
pub fn ruby_dependable_l72_d10_option_tags(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(dependable_boundary_receiver(args, 'option_tags').option_tags())
}

// Ruby method `options` at line 77.
pub fn ruby_dependable_l77_d11_options(args ...ruby.Value) ruby.Value {
	options := dependable_boundary_receiver(args, 'options').options()
	return ruby.object_value('Options', options.inspect())
}

// Ruby method `prune_from_option?(build)` at line 82.
pub fn ruby_dependable_l82_d12_prune_from_option(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Dependable#prune_from_option? requires a receiver and BuildOptions')
	}
	dependency := dependency_from_boundary(args[0])
	build := build_options_from_boundary(args[1])
	return ruby.bool_value(dependency.prune_from_option(build))
}

// Ruby method `prune_if_build_and_not_dependent?(dependent, formula = nil)` at line 89.
pub fn ruby_dependable_l89_d13_prune_if_build_and_not_dependent(args ...ruby.Value) ruby.Value {
	dependency := dependable_boundary_receiver(args, 'prune_if_build_and_not_dependent?')
	if !dependency.build() {
		return ruby.bool_value(false)
	}
	if args.len > 2 && args[2].type_name != 'NilClass' {
		return ruby.bool_value(dependency.prune_if_build_and_not_formula(args[1].as_string(),
			args[2].as_string()))
	}
	if args.len > 1 && args[1].type_name == 'Dependency' {
		dependent := dependency_from_boundary(args[1])
		return ruby.bool_value(dependent.installed_with_formulary(DependencyMinimum{},
			default_formulary_lookup_config()))
	}
	panic('dependent is not a formula or cask dependent')
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
