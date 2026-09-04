module homebrew

import ruby

// Translated from Homebrew/brew `dependencies.rb`.

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

fn dependencies_boundary_value(dependencies Dependencies) ruby.Value {
	return ruby.Value{
		type_name: 'Dependencies'
		repr: dependencies.inspect()
		array_data: dependencies.items.map(dependency_boundary_value(it))
	}
}

fn dependency_array_boundary_value(dependencies []Dependency) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		repr: '[${dependencies.map(it.inspect()).join(', ')}]'
		array_data: dependencies.map(dependency_boundary_value(it))
	}
}

fn dependencies_from_boundary(value ruby.Value) Dependencies {
	if value.type_name == 'Dependencies' || value.type_name == 'Array' {
		return new_dependencies(...value.array_data.filter(it.type_name == 'Dependency').map(dependency_from_boundary(it)))
	}
	panic('expected Dependencies, got ${value.type_name}')
}

fn dependencies_boundary_receiver(args []ruby.Value, method string) Dependencies {
	if args.len == 0 {
		panic('Dependencies#${method} requires a receiver')
	}
	return dependencies_from_boundary(args[0])
}
