module homebrew

import brew_runtime

// Translated from Homebrew/brew `cask_dependent.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :cask` at line 21.
pub fn ruby_cask_dependent_l21_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `initialize(cask)` at line 24.
pub fn ruby_cask_dependent_l24_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `name` at line 29.
pub fn ruby_cask_dependent_l29_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `full_name` at line 34.
pub fn ruby_cask_dependent_l34_d4_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_name', ...args)
}

// Ruby method `runtime_dependencies(read_from_tab: true, undeclared: true)` at line 39.
pub fn ruby_cask_dependent_l39_d5_runtime_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runtime_dependencies', ...args)
}

// Ruby method `deps` at line 46.
pub fn ruby_cask_dependent_l46_d6_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps', ...args)
}

// Ruby method `requirements` at line 56.
pub fn ruby_cask_dependent_l56_d7_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requirements', ...args)
}

// Ruby method `recursive_dependencies(&block)` at line 95.
pub fn ruby_cask_dependent_l95_d8_recursive_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_dependencies', ...args)
}

// Ruby method `recursive_requirements(&block)` at line 105.
pub fn ruby_cask_dependent_l105_d9_recursive_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_requirements', ...args)
}

// Ruby method `any_version_installed?` at line 110.
pub fn ruby_cask_dependent_l110_d10_any_version_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_version_installed?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5:
// 6: # An adapter for casks to provide dependency information in a formula-like interface.
// 7: class CaskDependent
// 8:   # Defines a dependency on another cask
// 9:   class Requirement < ::Requirement
// 10:     Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 11:
// 12:     satisfy(build_env: false) do
// 13:       cask_token = cask
// 14:       raise "unexpected nil cask" unless cask_token
// 15:
// 16:       Cask::CaskLoader.load(cask_token).installed?
// 17:     end
// 18:   end
// 19:
// 20:   sig { returns(Cask::Cask) }
// 21:   attr_reader :cask
// 22:
// 23:   sig { params(cask: Cask::Cask).void }
// 24:   def initialize(cask)
// 25:     @cask = cask
// 26:   end
// 27:
// 28:   sig { returns(String) }
// 29:   def name
// 30:     @cask.token
// 31:   end
// 32:
// 33:   sig { returns(String) }
// 34:   def full_name
// 35:     @cask.full_name
// 36:   end
// 37:
// 38:   sig { params(read_from_tab: T::Boolean, undeclared: T::Boolean).returns(T::Array[Dependency]) }
// 39:   def runtime_dependencies(read_from_tab: true, undeclared: true)
// 40:     deps.flat_map do |dep|
// 41:       [dep, *dep.to_installed_formula.runtime_dependencies(read_from_tab:, undeclared:)]
// 42:     end.uniq
// 43:   end
// 44:
// 45:   sig { returns(T::Array[Dependency]) }
// 46:   def deps
// 47:     @deps ||= T.let(
// 48:       @cask.depends_on.formula.map do |f|
// 49:         Dependency.new f
// 50:       end,
// 51:       T.nilable(T::Array[Dependency]),
// 52:     )
// 53:   end
// 54:
// 55:   sig { returns(T::Array[::Requirement]) }
// 56:   def requirements
// 57:     @requirements ||= T.let(
// 58:       begin
// 59:         requirements = []
// 60:         dsl_reqs = @cask.depends_on
// 61:
// 62:         dsl_reqs.arch&.each do |arch|
// 63:           arch = if arch[:bits] == 64
// 64:             if arch[:type] == :intel
// 65:               :x86_64
// 66:             else
// 67:               :"#{arch[:type]}64"
// 68:             end
// 69:           elsif arch[:type] == :intel && arch[:bits] == 32
// 70:             :i386
// 71:           else
// 72:             arch[:type]
// 73:           end
// 74:           requirements << ArchRequirement.new([arch])
// 75:         end
// 76:         dsl_reqs.cask.each do |cask_ref|
// 77:           requirements << CaskDependent::Requirement.new([{ cask: cask_ref }])
// 78:         end
// 79:         requirements << dsl_reqs.linux if dsl_reqs.linux
// 80:         requirements << dsl_reqs.macos if dsl_reqs.macos
// 81:         requirements << dsl_reqs.maximum_macos if dsl_reqs.maximum_macos
// 82:
// 83:         requirements
// 84:       end,
// 85:       T.nilable(T::Array[::Requirement]),
// 86:     )
// 87:   end
// 88:
// 89:   sig {
// 90:     params(
// 91:       block: T.nilable(T.proc.params(arg0: T.any(Formula, CaskDependent, SoftwareSpec),
// 92:                                      arg1: ::Dependency).returns(T.nilable(Symbol))),
// 93:     ).returns(T::Array[::Dependency])
// 94:   }
// 95:   def recursive_dependencies(&block)
// 96:     Dependency.expand(self, &block)
// 97:   end
// 98:
// 99:   sig {
// 100:     params(
// 101:       block: T.nilable(T.proc.params(arg0: T.any(Formula, CaskDependent, SoftwareSpec),
// 102:                                      arg1: ::Requirement).returns(T.nilable(Symbol))),
// 103:     ).returns(Requirements)
// 104:   }
// 105:   def recursive_requirements(&block)
// 106:     Requirement.expand(self, &block)
// 107:   end
// 108:
// 109:   sig { returns(T::Boolean) }
// 110:   def any_version_installed?
// 111:     @cask.installed?
// 112:   end
// 113: end
