module homebrew

import ruby

// Translated from Homebrew/brew `cask_dependent.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskDependentArch {
pub:
	kind string
	bits int = 64
}

pub struct CaskDependentDependency {
pub:
	name string
}

pub struct CaskDependentRequirement {
pub:
	kind string
	name string
	cask string
}

pub struct CaskDependentFormula {
pub:
	name                 string
	dependencies         []string
	runtime_dependencies []string
	requirements         []CaskDependentRequirement
}

pub type CaskDependentRuntimeResolver = fn(string, bool, bool) []string

pub struct CaskDependentCask {
pub:
	token                string
	full_name            string
	installed            bool
	formula_dependencies []string
	cask_dependencies    []string
	arch                 []CaskDependentArch
	linux                bool
	macos                bool
	maximum_macos        bool
}

pub struct CaskDependentGraph {
pub:
	formulae         map[string]CaskDependentFormula
	installed_casks  []string
	runtime_resolver ?CaskDependentRuntimeResolver
}

pub struct CaskDependent {
pub:
	cask  CaskDependentCask
	graph CaskDependentGraph
}

pub fn new_cask_dependent(cask CaskDependentCask, graph CaskDependentGraph) CaskDependent {
	return CaskDependent{
		cask: cask
		graph: graph
	}
}

pub fn (dependent CaskDependent) name() string {
	return dependent.cask.token
}

pub fn (dependent CaskDependent) full_name() string {
	return if dependent.cask.full_name != '' {
		dependent.cask.full_name
	} else {
		dependent.cask.token
	}
}

pub fn (dependent CaskDependent) deps() []CaskDependentDependency {
	return dependent.cask.formula_dependencies.map(CaskDependentDependency{
		name: it
	})
}

fn cask_dependent_arch_name(arch CaskDependentArch) string {
	if arch.bits == 64 {
		return if arch.kind == 'intel' { 'x86_64' } else { '${arch.kind}64' }
	}
	if arch.kind == 'intel' && arch.bits == 32 {
		return 'i386'
	}
	return arch.kind
}

pub fn (dependent CaskDependent) requirements() []CaskDependentRequirement {
	mut result := []CaskDependentRequirement{}
	for arch in dependent.cask.arch {
		result << CaskDependentRequirement{
			kind: 'arch'
			name: cask_dependent_arch_name(arch)
		}
	}
	for token in dependent.cask.cask_dependencies {
		result << CaskDependentRequirement{
			kind: 'cask'
			name: token
			cask: token
		}
	}
	if dependent.cask.linux {
		result << CaskDependentRequirement{
			kind: 'linux'
			name: 'linux'
		}
	}
	if dependent.cask.macos {
		result << CaskDependentRequirement{
			kind: 'macos'
			name: 'macos'
		}
	}
	if dependent.cask.maximum_macos {
		result << CaskDependentRequirement{
			kind: 'maximum_macos'
			name: 'macos'
		}
	}
	return result
}

fn cask_dependent_append_formula_dependencies(name string, graph CaskDependentGraph,
	mut visiting []string, mut result []string) {
	if name in visiting || name in result {
		return
	}
	visiting << name
	formula := graph.formulae[name] or {
		CaskDependentFormula{
			name: name
		}
	}
	for child in formula.dependencies {
		cask_dependent_append_formula_dependencies(child, graph, mut visiting, mut result)
	}
	visiting.delete(visiting.index(name))
	if name !in result {
		result << name
	}
}

pub fn (dependent CaskDependent) runtime_dependencies(read_from_tab bool,
	undeclared bool) []CaskDependentDependency {
	mut result := []string{}
	for dependency in dependent.cask.formula_dependencies {
		if dependency !in result {
			result << dependency
		}
		formula := dependent.graph.formulae[dependency] or {
			CaskDependentFormula{
				name: dependency
			}
		}
		runtime := if resolver := dependent.graph.runtime_resolver {
			resolver(dependency, read_from_tab, undeclared)
		} else {
			formula.runtime_dependencies
		}
		for child in runtime {
			if child !in result {
				result << child
			}
		}
	}
	return result.map(CaskDependentDependency{
		name: it
	})
}

pub fn (dependent CaskDependent) recursive_dependencies() []CaskDependentDependency {
	mut names := []string{}
	mut visiting := []string{}
	for dependency in dependent.cask.formula_dependencies {
		cask_dependent_append_formula_dependencies(dependency, dependent.graph, mut visiting, mut names)
	}
	return names.map(CaskDependentDependency{
		name: it
	})
}

fn cask_dependent_requirement_key(requirement CaskDependentRequirement) string {
	return '${requirement.kind}:${requirement.name}:${requirement.cask}'
}

fn cask_dependent_append_formula_requirements(name string, graph CaskDependentGraph,
	mut visiting []string, mut seen []string, mut result []CaskDependentRequirement) {
	if name in visiting {
		return
	}
	visiting << name
	formula := graph.formulae[name] or {
		CaskDependentFormula{
			name: name
		}
	}
	for child in formula.dependencies {
		cask_dependent_append_formula_requirements(child, graph, mut visiting, mut seen, mut result)
	}
	for requirement in formula.requirements {
		key := cask_dependent_requirement_key(requirement)
		if key !in seen {
			seen << key
			result << requirement
		}
	}
	visiting.delete(visiting.index(name))
}

pub fn (dependent CaskDependent) recursive_requirements() []CaskDependentRequirement {
	mut result := []CaskDependentRequirement{}
	mut seen := []string{}
	mut visiting := []string{}
	for dependency in dependent.cask.formula_dependencies {
		cask_dependent_append_formula_requirements(dependency, dependent.graph, mut visiting, mut seen, mut result)
	}
	for requirement in dependent.requirements() {
		key := cask_dependent_requirement_key(requirement)
		if key !in seen {
			seen << key
			result << requirement
		}
	}
	return result
}

pub fn (dependent CaskDependent) any_version_installed() bool {
	return dependent.cask.installed
}

pub fn (dependent CaskDependent) requirement_satisfied(requirement CaskDependentRequirement) bool {
	return requirement.kind != 'cask' || requirement.cask in dependent.graph.installed_casks
}

fn cask_dependent_requirement_value(requirement CaskDependentRequirement) ruby.Value {
	return ruby.Value{
		type_name: if requirement.kind == 'cask' {
			'CaskDependent::Requirement'} else {
			'${requirement.kind.capitalize()}Requirement'}
		repr: requirement.name
		map_data: {
			'name': ruby.string_value(requirement.name)
			'cask': ruby.string_value(requirement.cask)
			'kind': ruby.string_value(requirement.kind)
		}
	}
}

fn cask_dependent_dependency_value(dependency CaskDependentDependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name': dependency.name
	})
}

pub fn cask_dependent_cask_value(cask CaskDependentCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: if cask.full_name != '' { cask.full_name } else { cask.token }
		map_data: {
			'token':                ruby.string_value(cask.token)
			'full_name':            ruby.string_value(cask.full_name)
			'installed':            ruby.bool_value(cask.installed)
			'formula_dependencies': ruby.string_array_value(cask.formula_dependencies)
			'cask_dependencies':    ruby.string_array_value(cask.cask_dependencies)
			'arch':                 ruby.array_value(cask.arch.map(ruby.map_value({
				'kind': ruby.string_value(it.kind)
				'bits': ruby.int_value(it.bits)
			})))
			'linux':                ruby.bool_value(cask.linux)
			'macos':                ruby.bool_value(cask.macos)
			'maximum_macos':        ruby.bool_value(cask.maximum_macos)
		}
	}
}

fn cask_dependent_cask_from_value(value ruby.Value) !CaskDependentCask {
	if value.type_name != 'Cask::Cask' && value.type_name != 'Hash' {
		return error('expected Cask::Cask, got ${value.type_name}')
	}
	mut arches := []CaskDependentArch{}
	for raw in (value.map_data['arch'] or { ruby.array_value([]) }).as_array()! {
		arches << CaskDependentArch{
			kind: (raw.map_data['kind'] or { ruby.string_value('') }).as_string()
			bits: int((raw.map_data['bits'] or { ruby.int_value(64) }).as_int()!)
		}
	}
	return CaskDependentCask{
		token: (value.map_data['token'] or { ruby.string_value(value.as_string()) }).as_string()
		full_name: (value.map_data['full_name'] or { ruby.string_value(value.as_string()) }).as_string()
		installed: (value.map_data['installed'] or { ruby.bool_value(false) }).as_bool()!
		formula_dependencies: (value.map_data['formula_dependencies'] or { ruby.string_array_value([]) }).as_string_array()!
		cask_dependencies: (value.map_data['cask_dependencies'] or { ruby.string_array_value([]) }).as_string_array()!
		arch: arches
		linux: (value.map_data['linux'] or { ruby.bool_value(false) }).as_bool()!
		macos: (value.map_data['macos'] or { ruby.bool_value(false) }).as_bool()!
		maximum_macos: (value.map_data['maximum_macos'] or { ruby.bool_value(false) }).as_bool()!
	}
}

pub fn cask_dependent_value(dependent CaskDependent) ruby.Value {
	mut formulae := map[string]ruby.Value{}
	for name, formula in dependent.graph.formulae {
		formulae[name] = ruby.map_value({
			'name':                 ruby.string_value(formula.name)
			'dependencies':         ruby.string_array_value(formula.dependencies)
			'runtime_dependencies': ruby.string_array_value(formula.runtime_dependencies)
			'requirements':         ruby.array_value(formula.requirements.map(cask_dependent_requirement_value(it)))
		})
	}
	return ruby.Value{
		type_name: 'CaskDependent'
		repr: dependent.full_name()
		map_data: {
			'cask':            cask_dependent_cask_value(dependent.cask)
			'formulae':        ruby.map_value(formulae)
			'installed_casks': ruby.string_array_value(dependent.graph.installed_casks)
		}
	}
}

fn cask_dependent_requirement_from_value(value ruby.Value) CaskDependentRequirement {
	return CaskDependentRequirement{
		kind: (value.map_data['kind'] or { ruby.string_value('') }).as_string()
		name: (value.map_data['name'] or { ruby.string_value(value.as_string()) }).as_string()
		cask: (value.map_data['cask'] or { ruby.string_value('') }).as_string()
	}
}

pub fn cask_dependent_from_value(value ruby.Value) !CaskDependent {
	if value.type_name == 'Cask::Cask' {
		return new_cask_dependent(cask_dependent_cask_from_value(value)!, CaskDependentGraph{})
	}
	if value.type_name != 'CaskDependent' {
		return error('expected CaskDependent, got ${value.type_name}')
	}
	mut formulae := map[string]CaskDependentFormula{}
	for name, raw in (value.map_data['formulae'] or { ruby.map_value({}) }).map_data {
		formulae[name] = CaskDependentFormula{
			name: (raw.map_data['name'] or { ruby.string_value(name) }).as_string()
			dependencies: (raw.map_data['dependencies'] or { ruby.string_array_value([]) }).as_string_array()!
			runtime_dependencies: (raw.map_data['runtime_dependencies'] or { ruby.string_array_value([]) }).as_string_array()!
			requirements: (raw.map_data['requirements'] or { ruby.array_value([]) }).as_array()!.map(cask_dependent_requirement_from_value(it))
		}
	}
	return new_cask_dependent(
		cask_dependent_cask_from_value(value.map_data['cask'] or { return error('CaskDependent cask is required') })!,
		CaskDependentGraph{
			formulae: formulae
			installed_casks: (value.map_data['installed_casks'] or { ruby.string_array_value([]) }).as_string_array()!
		},
	)
}

fn cask_dependent_receiver(args []ruby.Value) ?CaskDependent {
	if args.len == 0 {
		return none
	}
	return cask_dependent_from_value(args[0]) or { return none }
}

// Ruby attr_reader `attr_reader :cask` at line 21.
pub fn ruby_cask_dependent_l21_d1_cask(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.object_value('NilClass', 'nil') }
	return cask_dependent_cask_value(dependent.cask)
}

// Ruby method `initialize(cask)` at line 24.
pub fn ruby_cask_dependent_l24_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'cask is required')
	}
	cask := cask_dependent_cask_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return cask_dependent_value(new_cask_dependent(cask, CaskDependentGraph{}))
}

// Ruby method `name` at line 29.
pub fn ruby_cask_dependent_l29_d3_name(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.string_value('') }
	return ruby.string_value(dependent.name())
}

// Ruby method `full_name` at line 34.
pub fn ruby_cask_dependent_l34_d4_full_name(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.string_value('') }
	return ruby.string_value(dependent.full_name())
}

// Ruby method `runtime_dependencies(read_from_tab: true, undeclared: true)` at line 39.
pub fn ruby_cask_dependent_l39_d5_runtime_dependencies(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.array_value([]) }
	read_from_tab := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	undeclared := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	return ruby.array_value(dependent.runtime_dependencies(read_from_tab, undeclared).map(cask_dependent_dependency_value(it)))
}

// Ruby method `deps` at line 46.
pub fn ruby_cask_dependent_l46_d6_deps(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(dependent.deps().map(cask_dependent_dependency_value(it)))
}

// Ruby method `requirements` at line 56.
pub fn ruby_cask_dependent_l56_d7_requirements(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(dependent.requirements().map(cask_dependent_requirement_value(it)))
}

// Ruby method `recursive_dependencies(&block)` at line 95.
pub fn ruby_cask_dependent_l95_d8_recursive_dependencies(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(dependent.recursive_dependencies().map(cask_dependent_dependency_value(it)))
}

// Ruby method `recursive_requirements(&block)` at line 105.
pub fn ruby_cask_dependent_l105_d9_recursive_requirements(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.array_value([]) }
	return ruby.array_value(dependent.recursive_requirements().map(cask_dependent_requirement_value(it)))
}

// Ruby method `any_version_installed?` at line 110.
pub fn ruby_cask_dependent_l110_d10_any_version_installed(args ...ruby.Value) ruby.Value {
	dependent := cask_dependent_receiver(args) or { return ruby.bool_value(false) }
	return ruby.bool_value(dependent.any_version_installed())
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
