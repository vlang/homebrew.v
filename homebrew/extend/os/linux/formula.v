module linux

// Translated from Homebrew/brew `extend/os/linux/formula.rb`.
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
