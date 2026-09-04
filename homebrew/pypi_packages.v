module homebrew

import ruby

// Translated from Homebrew/brew `pypi_packages.rb`.
// The original source is retained below until every stub has a typed V body.

// PypiPackagesConfig contains the keyword arguments accepted by PypiPackages.
// Arrays are copied into the model so callers cannot mutate its state later.
pub struct PypiPackagesConfig {
pub:
	package_name     ?string
	extra_packages   []string
	exclude_packages []string
	dependencies     []string
}

// PypiPackages is the immutable representation of the `pypi_packages` DSL data.
// An empty package name is intentionally different from none: the former tells
// Homebrew to skip the formula's main package while still processing extras.
pub struct PypiPackages {
	package_name_value     ?string
	extra_package_values   []string
	exclude_package_values []string
	dependency_values      []string
}

pub fn new_pypi_packages(config PypiPackagesConfig) PypiPackages {
	return PypiPackages{
		package_name_value: config.package_name
		extra_package_values: config.extra_packages.clone()
		exclude_package_values: config.exclude_packages.clone()
		dependency_values: config.dependencies.clone()
	}
}

pub fn (packages PypiPackages) package_name() ?string {
	return packages.package_name_value
}

pub fn (packages PypiPackages) extra_packages() []string {
	return packages.extra_package_values.clone()
}

pub fn (packages PypiPackages) exclude_packages() []string {
	return packages.exclude_package_values.clone()
}

pub fn (packages PypiPackages) dependencies() []string {
	return packages.dependency_values.clone()
}

// pypi_packages_value is the generic boundary adapter used by translated Ruby
// callers which do not yet pass PypiPackages directly.
pub fn pypi_packages_value(packages PypiPackages) ruby.Value {
	package_name := if name := packages.package_name() {
		ruby.string_value(name)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return ruby.Value{
		type_name: 'PypiPackages'
		repr: 'PypiPackages'
		map_data: {
			'package_name':     package_name
			'extra_packages':   ruby.string_array_value(packages.extra_packages())
			'exclude_packages': ruby.string_array_value(packages.exclude_packages())
			'dependencies':     ruby.string_array_value(packages.dependencies())
		}
	}
}

fn pypi_packages_array_from_value(value ruby.Value, field string) ![]string {
	if value.type_name == 'NilClass' {
		return []string{}
	}
	if value.type_name != 'Array' {
		return error('PypiPackages `${field}` must be an Array, got ${value.type_name}')
	}
	if value.array_data.len == 0 {
		return value.string_array_data.clone()
	}
	mut result := []string{cap: value.array_data.len}
	for item in value.array_data {
		if item.type_name != 'String' {
			return error('PypiPackages `${field}` entries must be Strings, got ${item.type_name}')
		}
		result << item.as_string()
	}
	return result
}

pub fn pypi_packages_from_value(value ruby.Value) !PypiPackages {
	if value.type_name != 'PypiPackages' && value.type_name != 'Hash' {
		return error('expected PypiPackages or Hash, got ${value.type_name}')
	}
	mut package_name := ?string(none)
	if raw_name := value.map_data['package_name'] {
		if raw_name.type_name == 'String' {
			package_name = raw_name.as_string()
		} else if raw_name.type_name != 'NilClass' {
			return error('PypiPackages `package_name` must be a String or nil, got ${raw_name.type_name}')
		}
	}
	extra_packages := pypi_packages_array_from_value(value.map_data['extra_packages'] or {
		ruby.string_array_value([]string{})
	}, 'extra_packages')!
	exclude_packages := pypi_packages_array_from_value(value.map_data['exclude_packages'] or {
		ruby.string_array_value([]string{})
	}, 'exclude_packages')!
	dependencies := pypi_packages_array_from_value(value.map_data['dependencies'] or {
		ruby.string_array_value([]string{})
	}, 'dependencies')!
	return new_pypi_packages(PypiPackagesConfig{
		package_name: package_name
		extra_packages: extra_packages
		exclude_packages: exclude_packages
		dependencies: dependencies
	})
}

fn pypi_packages_from_boundary_args(args []ruby.Value) !PypiPackages {
	if args.len == 0 {
		return error('missing PypiPackages receiver')
	}
	return pypi_packages_from_value(args[0])
}

fn pypi_packages_config_from_args(args []ruby.Value) !PypiPackagesConfig {
	if args.len == 0 {
		return PypiPackagesConfig{}
	}
	if args.len == 1 && args[0].type_name == 'Hash' {
		return pypi_packages_from_value(args[0])!.to_config()
	}
	if args.len > 4 {
		return error('PypiPackages initialize accepts at most four arguments')
	}
	mut package_name := ?string(none)
	if args[0].type_name == 'String' {
		package_name = args[0].as_string()
	} else if args[0].type_name != 'NilClass' {
		return error('PypiPackages `package_name` must be a String or nil, got ${args[0].type_name}')
	}
	return PypiPackagesConfig{
		package_name: package_name
		extra_packages: if args.len > 1 {
			pypi_packages_array_from_value(args[1], 'extra_packages')!} else {
			[]string{}}
		exclude_packages: if args.len > 2 {
			pypi_packages_array_from_value(args[2], 'exclude_packages')!} else {
			[]string{}}
		dependencies: if args.len > 3 {
			pypi_packages_array_from_value(args[3], 'dependencies')!} else {
			[]string{}}
	}
}

fn (packages PypiPackages) to_config() PypiPackagesConfig {
	return PypiPackagesConfig{
		package_name: packages.package_name()
		extra_packages: packages.extra_packages()
		exclude_packages: packages.exclude_packages()
		dependencies: packages.dependencies()
	}
}

// Ruby attr_reader `attr_reader :package_name` at line 8.
pub fn ruby_pypi_packages_l8_d1_package_name(args ...ruby.Value) ruby.Value {
	packages := pypi_packages_from_boundary_args(args) or { panic(err) }
	return if name := packages.package_name() {
		ruby.string_value(name)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby attr_reader `attr_reader :extra_packages` at line 11.
pub fn ruby_pypi_packages_l11_d2_extra_packages(args ...ruby.Value) ruby.Value {
	packages := pypi_packages_from_boundary_args(args) or { panic(err) }
	return ruby.string_array_value(packages.extra_packages())
}

// Ruby attr_reader `attr_reader :exclude_packages` at line 14.
pub fn ruby_pypi_packages_l14_d3_exclude_packages(args ...ruby.Value) ruby.Value {
	packages := pypi_packages_from_boundary_args(args) or { panic(err) }
	return ruby.string_array_value(packages.exclude_packages())
}

// Ruby attr_reader `attr_reader :dependencies` at line 17.
pub fn ruby_pypi_packages_l17_d4_dependencies(args ...ruby.Value) ruby.Value {
	packages := pypi_packages_from_boundary_args(args) or { panic(err) }
	return ruby.string_array_value(packages.dependencies())
}

// Ruby method `initialize(` at line 27.
pub fn ruby_pypi_packages_l27_d5_initialize(args ...ruby.Value) ruby.Value {
	config := pypi_packages_config_from_args(args) or { panic(err) }
	return pypi_packages_value(new_pypi_packages(config))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper class for `pypi_packages` DSL.
// 5: # @api internal
// 6: class PypiPackages
// 7:   sig { returns(T.nilable(String)) }
// 8:   attr_reader :package_name
// 9:
// 10:   sig { returns(T::Array[String]) }
// 11:   attr_reader :extra_packages
// 12:
// 13:   sig { returns(T::Array[String]) }
// 14:   attr_reader :exclude_packages
// 15:
// 16:   sig { returns(T::Array[String]) }
// 17:   attr_reader :dependencies
// 18:
// 19:   sig {
// 20:     params(
// 21:       package_name:     T.nilable(String),
// 22:       extra_packages:   T::Array[String],
// 23:       exclude_packages: T::Array[String],
// 24:       dependencies:     T::Array[String],
// 25:     ).void
// 26:   }
// 27:   def initialize(
// 28:     package_name: nil,
// 29:     extra_packages: [],
// 30:     exclude_packages: [],
// 31:     dependencies: []
// 32:   )
// 33:     @package_name = package_name
// 34:     @extra_packages = extra_packages
// 35:     @exclude_packages = exclude_packages
// 36:     @dependencies = dependencies
// 37:   end
// 38: end
