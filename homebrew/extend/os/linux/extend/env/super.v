module env

import ruby
import homebrew.extend.env as base_env
import os

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/super.rb`.

pub struct LinuxSuperenvContext {
pub:
	formula_lib       ?string
	arm64             bool
	gcc_version       int
	gcc_include_dir   string
	gcc_include_fixed string
}

pub fn linux_superenv_shims_path(homebrew_shims_path string) string {
	return os.join_path(homebrew_shims_path, 'linux', 'super', 'bin')
}

pub fn linux_superenv_bin(homebrew_shims_path string) ?string {
	path := linux_superenv_shims_path(homebrew_shims_path)
	if !os.exists(path) {
		return none
	}
	return os.real_path(path)
}

pub fn linux_superenv_extra_paths(base_paths []string, formula_bins map[string]string,
	exists fn (string) bool) []string {
	mut paths := base_paths.clone()
	for formula_name in ['binutils', 'make'] {
		if bin := formula_bins[formula_name] {
			if exists(bin) {
				paths << bin
			}
		}
	}
	return paths
}

pub fn linux_superenv_extra_isystem_paths(dependencies []base_env.SuperenvDependency,
	gcc_include_dir string, gcc_include_fixed string) []string {
	if !dependencies.any(it.name.starts_with('glibc@') && it.name.len > 'glibc@'.len) {
		return []
	}
	return [gcc_include_dir, gcc_include_fixed].filter(it != '')
}

pub fn linux_superenv_rpath_paths(formula_lib ?string, prefix string,
	run_time_dependencies []base_env.SuperenvDependency, exists fn (string) bool) []string {
	mut paths := []string{}
	if path := formula_lib {
		paths << path
	}
	paths << os.join_path(prefix, 'opt', 'gcc', 'lib', 'gcc', 'current')
	for dependency in run_time_dependencies {
		path := if dependency.opt_prefix != '' {
			os.join_path(dependency.opt_prefix, 'lib')
		} else {
			os.join_path(prefix, 'opt', dependency.name, 'lib')
		}
		if exists(path) {
			paths << path
		}
	}
	paths << os.join_path(prefix, 'lib')
	return paths
}

pub fn linux_superenv_dynamic_linker_path(prefix string, readable fn (string) bool) ?string {
	path := os.join_path(prefix, 'lib', 'ld.so')
	if readable(path) {
		return path
	}
	return none
}

pub fn linux_superenv_setup_build_environment(mut state base_env.SuperenvState,
	options base_env.SuperenvBuildOptions, context LinuxSuperenvContext,
	exists fn (string) bool) {
	state.setup(options, exists)
	state.set_value('HOMEBREW_OPTIMIZATION_LEVEL', 'O2')
	if linker := linux_superenv_dynamic_linker_path(state.config.prefix, exists) {
		state.set_value('HOMEBREW_DYNAMIC_LINKER', linker)
	} else {
		state.remove_value('HOMEBREW_DYNAMIC_LINKER')
	}
	rpaths := linux_superenv_rpath_paths(context.formula_lib, state.config.prefix, base_env.super_run_time_deps(state), exists)
	state.set_value('HOMEBREW_RPATH_PATHS', rpaths.join(':'))
	if state.dependencies().any(it.name in ['libtool', 'bison']) {
		state.set_value('M4', os.join_path(state.config.prefix, 'opt', 'm4', 'bin', 'm4'))
	}
	if !context.arm64 {
		return
	}
	state.set_value('JEMALLOC_SYS_WITH_LG_PAGE', '16')
	state.set_value('CGO_ENABLED', '0')
	if context.gcc_version >= 9 {
		state.append_cccfg('b')
	}
}

pub fn linux_superenv_state_boundary(state &base_env.SuperenvState) ruby.Value {
	return ruby.structured_value('OS::Linux::Superenv', '', {
		'linux_superenv_address': u64(voidptr(state)).str()
	})
}

fn linux_superenv_state_from_value(value ruby.Value) &base_env.SuperenvState {
	address := value.attributes['linux_superenv_address'] or { panic('invalid Linux Superenv') }
	return unsafe { &base_env.SuperenvState(voidptr(address.u64())) }
}
