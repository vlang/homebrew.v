module homebrew

import brew_runtime

// Translated from Homebrew/brew `dependencies.rb`.
// The original source is retained below until every stub has a typed V body.

// Dependencies is the ordered Array delegate used by Homebrew. Keeping the
// collection concrete preserves SimpleDelegator's array behaviour without
// obscuring Dependency's typed tags and uses_from_macos metadata.
pub struct Dependencies {
pub mut:
	items []Dependency
}

pub fn new_dependencies(initial ...Dependency) Dependencies {
	return Dependencies{
		items: initial.clone()
	}
}

// add translates the delegated Array#<< operation and returns the updated
// collection, matching the value equality of Ruby's delegated array receiver.
pub fn (mut dependencies Dependencies) add(dependency Dependency) Dependencies {
	dependencies.items << dependency
	return dependencies
}

pub fn (dependencies Dependencies) to_a() []Dependency {
	return dependencies.items.clone()
}

pub fn (dependencies Dependencies) to_ary() []Dependency {
	return dependencies.items.clone()
}

pub fn (dependencies Dependencies) join(separator string) string {
	return dependencies.items.map(it.str()).join(separator)
}

pub fn (dependencies Dependencies) empty() bool {
	return dependencies.items.len == 0
}

pub fn (dependencies Dependencies) equal(other Dependencies) bool {
	if dependencies.items.len != other.items.len {
		return false
	}
	for index, dependency in dependencies.items {
		if !dependency.equal(other.items[index]) {
			return false
		}
	}
	return true
}

pub fn (dependencies Dependencies) optional() []Dependency {
	return dependencies.items.filter(it.optional())
}

pub fn (dependencies Dependencies) recommended() []Dependency {
	return dependencies.items.filter(it.recommended())
}

pub fn (dependencies Dependencies) build() []Dependency {
	return dependencies.items.filter(it.build())
}

pub fn (dependencies Dependencies) required() []Dependency {
	return dependencies.items.filter(it.required())
}

pub fn (dependencies Dependencies) default_dependencies() []Dependency {
	mut defaults := dependencies.build()
	defaults << dependencies.required()
	defaults << dependencies.recommended()
	return defaults
}

// dependency_uses_macos_install_for_system is the typed form of
// UsesFromMacOSDependency#use_macos_install? needed by
// Dependencies#dup_without_system_deps. `macos` represents Ruby's generic
// current macOS simulation, whose effective version is Version::NULL.
pub fn dependency_uses_macos_install_for_system(dependency Dependency, system string) bool {
	if !dependency.uses_from_macos_dependency() {
		return false
	}
	if system != 'macos' && system !in macos_symbol_versions() {
		return false
	}
	since := dependency.macos_bounds['since'] or { return true }
	minimum := macos_version_from_symbol(since) or { return true }
	if system == 'macos' {
		return false
	}
	effective := macos_version_from_symbol(system) or { return false }
	return effective.compare(minimum) >= 0
}

pub fn (dependencies Dependencies) dup_without_system_deps_for_system(system string) Dependencies {
	return new_dependencies(...dependencies.items.filter(!dependency_uses_macos_install_for_system(it, system)))
}

pub fn (dependencies Dependencies) dup_without_system_deps() Dependencies {
	$if macos {
		return dependencies.dup_without_system_deps_for_system('macos')
	} $else {
		return dependencies.dup_without_system_deps_for_system('linux')
	}
}

pub fn (dependencies Dependencies) inspect() string {
	return '#<Dependencies: [${dependencies.items.map(it.inspect()).join(', ')}]>'
}

fn dependencies_boundary_value(dependencies Dependencies) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Dependencies'
		repr: dependencies.inspect()
		array_data: dependencies.items.map(dependency_boundary_value(it))
	}
}

fn dependency_array_boundary_value(dependencies []Dependency) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Array'
		repr: '[${dependencies.map(it.inspect()).join(', ')}]'
		array_data: dependencies.map(dependency_boundary_value(it))
	}
}

fn dependencies_from_boundary(value brew_runtime.Value) Dependencies {
	if value.type_name == 'Dependencies' || value.type_name == 'Array' {
		return new_dependencies(...value.array_data.filter(it.type_name == 'Dependency').map(dependency_from_boundary(it)))
	}
	panic('expected Dependencies, got ${value.type_name}')
}

fn dependencies_boundary_receiver(args []brew_runtime.Value, method string) Dependencies {
	if args.len == 0 {
		panic('Dependencies#${method} requires a receiver')
	}
	return dependencies_from_boundary(args[0])
}

// Ruby method `initialize(*args)` at line 15.
pub fn ruby_dependencies_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 1 && args[0].type_name == 'Array' {
		return dependencies_boundary_value(dependencies_from_boundary(args[0]))
	}
	return dependencies_boundary_value(new_dependencies(...args.filter(it.type_name == 'Dependency').map(dependency_from_boundary(it))))
}

// Ruby alias `alias eql? ==` at line 19.
pub fn ruby_dependencies_l19_d2_eql(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[1].type_name !in ['Dependencies', 'Array'] {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(dependencies_from_boundary(args[0]).equal(dependencies_from_boundary(args[1])))
}

// Ruby method `optional` at line 22.
pub fn ruby_dependencies_l22_d3_optional(args ...brew_runtime.Value) brew_runtime.Value {
	return dependency_array_boundary_value(dependencies_boundary_receiver(args, 'optional').optional())
}

// Ruby method `recommended` at line 27.
pub fn ruby_dependencies_l27_d4_recommended(args ...brew_runtime.Value) brew_runtime.Value {
	return dependency_array_boundary_value(dependencies_boundary_receiver(args, 'recommended').recommended())
}

// Ruby method `build` at line 32.
pub fn ruby_dependencies_l32_d5_build(args ...brew_runtime.Value) brew_runtime.Value {
	return dependency_array_boundary_value(dependencies_boundary_receiver(args, 'build').build())
}

// Ruby method `required` at line 37.
pub fn ruby_dependencies_l37_d6_required(args ...brew_runtime.Value) brew_runtime.Value {
	return dependency_array_boundary_value(dependencies_boundary_receiver(args, 'required').required())
}

// Ruby method `default` at line 42.
pub fn ruby_dependencies_l42_d7_default(args ...brew_runtime.Value) brew_runtime.Value {
	return dependency_array_boundary_value(dependencies_boundary_receiver(args, 'default').default_dependencies())
}

// Ruby method `dup_without_system_deps` at line 47.
pub fn ruby_dependencies_l47_d8_dup_without_system_deps(args ...brew_runtime.Value) brew_runtime.Value {
	dependencies := dependencies_boundary_receiver(args, 'dup_without_system_deps')
	if args.len > 1 {
		return dependencies_boundary_value(dependencies.dup_without_system_deps_for_system(args[1].as_string()))
	}
	return dependencies_boundary_value(dependencies.dup_without_system_deps())
}

// Ruby method `inspect` at line 52.
pub fn ruby_dependencies_l52_d9_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(dependencies_boundary_receiver(args, 'inspect').inspect())
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
