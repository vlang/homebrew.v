module homebrew

import brew_runtime

// Translated from Homebrew/brew `pypi_packages.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :package_name` at line 8.
pub fn ruby_pypi_packages_l8_d1_package_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('package_name', ...args)
}

// Ruby attr_reader `attr_reader :extra_packages` at line 11.
pub fn ruby_pypi_packages_l11_d2_extra_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extra_packages', ...args)
}

// Ruby attr_reader `attr_reader :exclude_packages` at line 14.
pub fn ruby_pypi_packages_l14_d3_exclude_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exclude_packages', ...args)
}

// Ruby attr_reader `attr_reader :dependencies` at line 17.
pub fn ruby_pypi_packages_l17_d4_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependencies', ...args)
}

// Ruby method `initialize(` at line 27.
pub fn ruby_pypi_packages_l27_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
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
