module linux

// Translated from Homebrew/brew `extend/os/linux/formula.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct LinuxFormulaGlobalDependencyFacts {
pub:
	name                     string
	aliases                  []string
	versioned_formulae_names []string
	needs_build_formulae     bool
	needs_libc_formula       bool
	gcc_dependency           ?string
	glibc_dependency         ?string
}

pub struct LinuxFormulaState {
pub mut:
	global_deps_initialized bool
	global_deps             []string
	related_formula_names   []string
}

pub fn linux_formula_shared_library(name string, version ?string) string {
	value := version or { '' }
	suffix := if value == '*' || (name == '*' && value == '') {
		'{,.*}'
	} else if value != '' {
		'.${value}'
	} else {
		''
	}
	return '${name}.so${suffix}'
}

pub fn linux_formula_add_global_deps(mut state LinuxFormulaState,
	facts LinuxFormulaGlobalDependencyFacts) []string {
	if !state.global_deps_initialized {
		mut related_formula_names := [facts.name]
		if facts.needs_build_formulae || facts.needs_libc_formula {
			for candidate in facts.aliases {
				if candidate !in related_formula_names {
					related_formula_names << candidate
				}
			}
			for candidate in facts.versioned_formulae_names {
				if candidate !in related_formula_names {
					related_formula_names << candidate
				}
			}
		}
		state.related_formula_names = related_formula_names.clone()
		// The dependency collector has already evaluated the related names when it
		// supplies these optional results. Preserve the source's GCC-then-glibc order.
		if dependency := facts.gcc_dependency {
			state.global_deps << dependency
		}
		if dependency := facts.glibc_dependency {
			state.global_deps << dependency
		}
		state.global_deps_initialized = true
	}
	return state.global_deps.clone()
}

pub fn linux_formula_std_cabal_v2_args(base_args []string, arm bool) []string {
	mut arguments := base_args.clone()
	if arm {
		arguments << '--ghc-option=-pie'
	}
	return arguments
}

pub fn linux_formula_std_swift_args(base_args []string) []string {
	mut arguments := ['--static-swift-stdlib', '-Xswiftc', '-use-ld=ld']
	arguments << base_args
	return arguments
}

// Ruby method `shared_library(name, version = nil)` at line 12.
pub fn ruby_formula_l12_d1_shared_library(name string, version ?string) string {
	return linux_formula_shared_library(name, version)
}

// Ruby method `loader_path` at line 22.
pub fn ruby_formula_l22_d2_loader_path() string {
	return '\$ORIGIN'
}

// Ruby method `deuniversalize_machos(*targets); end` at line 27.
pub fn ruby_formula_l27_d3_deuniversalize_machos(_ []string) {
}

// Ruby method `add_global_deps_to_spec(spec)` at line 30.
pub fn ruby_formula_l30_d4_add_global_deps_to_spec(mut state LinuxFormulaState,
	facts LinuxFormulaGlobalDependencyFacts) []string {
	return linux_formula_add_global_deps(mut state, facts)
}

// Ruby method `valid_platform?` at line 48.
pub fn ruby_formula_l48_d5_valid_platform(supports_linux bool) bool {
	return supports_linux
}

// Ruby method `std_cabal_v2_args(installdir: bin)` at line 53.
pub fn ruby_formula_l53_d6_std_cabal_v2_args(base_args []string, arm bool) []string {
	return linux_formula_std_cabal_v2_args(base_args, arm)
}

// Ruby method `std_swift_args` at line 60.
pub fn ruby_formula_l60_d7_std_swift_args(base_args []string) []string {
	return linux_formula_std_swift_args(base_args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Formula
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::Formula }
// 10:
// 11:       sig { params(name: String, version: T.nilable(T.any(String, Integer))).returns(String) }
// 12:       def shared_library(name, version = nil)
// 13:         suffix = if version == "*" || (name == "*" && version.blank?)
// 14:           "{,.*}"
// 15:         elsif version.present?
// 16:           ".#{version}"
// 17:         end
// 18:         "#{name}.so#{suffix}"
// 19:       end
// 20:
// 21:       sig { returns(String) }
// 22:       def loader_path
// 23:         "$ORIGIN"
// 24:       end
// 25:
// 26:       sig { params(targets: T.nilable(T.any(::Pathname, String))).void }
// 27:       def deuniversalize_machos(*targets); end
// 28:
// 29:       sig { params(spec: SoftwareSpec).void }
// 30:       def add_global_deps_to_spec(spec)
// 31:         @global_deps ||= T.let(nil, T.nilable(T::Array[Dependency]))
// 32:         @global_deps ||= begin
// 33:           dependency_collector = spec.dependency_collector
// 34:           related_formula_names = Set[name]
// 35:           if ::DevelopmentTools.needs_build_formulae? || ::DevelopmentTools.needs_libc_formula?
// 36:             related_formula_names.merge(aliases)
// 37:             related_formula_names.merge(versioned_formulae_names)
// 38:           end
// 39:           [
// 40:             dependency_collector.gcc_dep_if_needed(related_formula_names),
// 41:             dependency_collector.glibc_dep_if_needed(related_formula_names),
// 42:           ].compact.freeze
// 43:         end
// 44:         @global_deps.each { |dep| spec.dependency_collector.add(dep) }
// 45:       end
// 46:
// 47:       sig { returns(T::Boolean) }
// 48:       def valid_platform?
// 49:         supports_linux?
// 50:       end
// 51:
// 52:       sig { params(installdir: T.any(String, ::Pathname, FalseClass)).returns(T::Array[String]) }
// 53:       def std_cabal_v2_args(installdir: bin)
// 54:         args = super
// 55:         args << "--ghc-option=-pie" if ::Hardware::CPU.arm?
// 56:         args
// 57:       end
// 58:
// 59:       sig { returns(T::Array[String]) }
// 60:       def std_swift_args
// 61:         # Use ld shim to help find Homebrew-installed libraries
// 62:         ["--static-swift-stdlib", "-Xswiftc", "-use-ld=ld"].concat(super)
// 63:       end
// 64:     end
// 65:   end
// 66: end
// 67:
// 68: Formula.prepend(OS::Linux::Formula)
