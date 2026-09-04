module env

import homebrew
import os
import regex

// Translated from Homebrew/brew `extend/ENV/shared.rb`.
pub const shared_env_cc_flag_vars = ['CFLAGS', 'CXXFLAGS', 'OBJCFLAGS', 'OBJCXXFLAGS']
pub const shared_env_fc_flag_vars = ['FCFLAGS', 'FFLAGS']
pub const shared_env_sanitized_vars = [
	'CDPATH',
	'CLICOLOR_FORCE',
	'CPATH',
	'C_INCLUDE_PATH',
	'CPLUS_INCLUDE_PATH',
	'OBJC_INCLUDE_PATH',
	'CC',
	'CXX',
	'OBJC',
	'OBJCXX',
	'CPP',
	'MAKE',
	'LD',
	'LDSHARED',
	'CFLAGS',
	'CXXFLAGS',
	'OBJCFLAGS',
	'OBJCXXFLAGS',
	'LDFLAGS',
	'CPPFLAGS',
	'MACOSX_DEPLOYMENT_TARGET',
	'SDKROOT',
	'DEVELOPER_DIR',
	'CMAKE_PREFIX_PATH',
	'CMAKE_INCLUDE_PATH',
	'CMAKE_FRAMEWORK_PATH',
	'GOBIN',
	'GOPATH',
	'GOROOT',
	'PERL_MB_OPT',
	'PERL_MM_OPT',
	'LIBRARY_PATH',
	'LD_LIBRARY_PATH',
	'LD_PRELOAD',
	'LD_RUN_PATH',
	'RUSTFLAGS',
]
pub const shared_env_removed_cc_keys = ['CC', 'CXX', 'OBJC', 'OBJCXX', 'LD', 'CPP', 'CFLAGS',
	'CXXFLAGS', 'OBJCFLAGS', 'OBJCXXFLAGS', 'LDFLAGS', 'CPPFLAGS']
pub const shared_env_gnu_gcc_versions = ['8', '9', '10', '11', '12', '13', '14', '15', '16']

pub struct SharedEnvCompiler {
pub:
	name   string
	symbol bool
}

pub struct SharedEnvGccFormula {
pub:
	name              string
	version_suffix    string
	opt_prefix_exists bool
	full_name         string
	opt_bin           string
}

pub struct SharedEnvConfig {
pub:
	default_compiler          string = 'clang'
	oldest_cpu                string = 'native'
	make_jobs                 int = 1
	selected_formula_compiler string
	gfortran_homebrew         ?string
	gfortran_original         ?string
	gcc_formulas              map[string]SharedEnvGccFormula
}

pub struct SharedEnvBuildOptions {
pub:
	formula         ?string
	cc              ?string
	build_bottle    bool
	bottle_arch     ?string
	testing_formula bool
	debug_symbols   bool
}

pub struct SharedEnvRemovedValue {
pub:
	existed bool
	value   string
}

pub struct SharedEnvRemoval {
pub:
	value  string
	regexp bool
}

@[heap]
pub struct SharedEnvState {
pub:
	config SharedEnvConfig
pub mut:
	environment        map[string]string
	formula            ?string
	cc_option          ?string
	build_bottle       bool
	bottle_arch        ?string
	debug_symbols      bool
	testing_formula    bool
	compiler_cache     ?SharedEnvCompiler
	fortran_setup_done bool
	output             []string
	created_paths      []string
}

pub fn new_shared_env(config SharedEnvConfig, environment map[string]string) &SharedEnvState {
	return &SharedEnvState{
		config: config
		environment: environment.clone()
	}
}

pub fn (state &SharedEnvState) to_map() map[string]string {
	return state.environment.clone()
}

pub fn (state &SharedEnvState) value(key string) ?string {
	return state.environment[key]
}

pub fn (mut state SharedEnvState) set_value(key string, value string) {
	state.environment[key] = value
}

pub fn shared_env_setup(mut state SharedEnvState, options SharedEnvBuildOptions) {
	state.formula = options.formula
	state.cc_option = options.cc
	state.build_bottle = options.build_bottle
	state.bottle_arch = options.bottle_arch
	state.debug_symbols = options.debug_symbols
	state.testing_formula = options.testing_formula
	shared_env_reset(mut state)
}

pub fn shared_env_build_bottle(state &SharedEnvState) bool {
	return state.build_bottle
}

pub fn shared_env_debug_symbols(state &SharedEnvState) bool {
	return state.debug_symbols
}

pub fn shared_env_reset(mut state SharedEnvState) {
	for key in shared_env_sanitized_vars {
		state.environment.delete(key)
	}
}

pub fn shared_env_remove_cc_etc(mut state SharedEnvState) map[string]SharedEnvRemovedValue {
	mut removed := map[string]SharedEnvRemovedValue{}
	for key in shared_env_removed_cc_keys {
		if value := state.environment[key] {
			removed[key] = SharedEnvRemovedValue{ existed: true, value: value }
			state.environment.delete(key)
		} else {
			removed[key] = SharedEnvRemovedValue{}
		}
	}
	return removed
}

pub fn shared_env_append(mut state SharedEnvState, keys []string, value string,
	separator string) {
	for key in keys {
		old_value := state.environment[key] or { '' }
		state.environment[key] = if old_value == '' { value } else { old_value + separator + value }
	}
}

pub fn shared_env_prepend(mut state SharedEnvState, keys []string, value string,
	separator string) {
	for key in keys {
		old_value := state.environment[key] or { '' }
		state.environment[key] = if old_value == '' { value } else { value + separator + old_value }
	}
}

pub fn shared_env_append_to_cflags(mut state SharedEnvState, flags string) {
	shared_env_append(mut state, shared_env_cc_flag_vars, flags, ' ')
}

fn shared_env_sub_once(value string, removal SharedEnvRemoval) !string {
	if !removal.regexp {
		return value.replace_once(removal.value, '')
	}
	mut expression := regex.regex_opt(removal.value)!
	return expression.replace_n(value, '', 1)
}

pub fn shared_env_remove(mut state SharedEnvState, keys []string,
	removal ?SharedEnvRemoval) ! {
	selected := removal or { return }
	for key in keys {
		old_value := state.environment[key] or { continue }
		new_value := shared_env_sub_once(old_value, selected)!
		if new_value == '' {
			state.environment.delete(key)
		} else {
			state.environment[key] = new_value
		}
	}
}

pub fn shared_env_remove_from_cflags(mut state SharedEnvState, removal SharedEnvRemoval) ! {
	shared_env_remove(mut state, shared_env_cc_flag_vars, removal)!
}

pub fn shared_env_append_to_cccfg(mut state SharedEnvState, value string) {
	shared_env_append(mut state, ['HOMEBREW_CCCFG'], value, '')
}

pub fn shared_env_append_path(mut state SharedEnvState, key string, path string) {
	mut value := homebrew.new_brew_path(homebrew.path_input(state.environment[key] or { '' }))
	value.append(homebrew.path_input(path))
	state.environment[key] = value.str()
}

pub fn shared_env_append_to_rustflags(mut state SharedEnvState, value string) {
	shared_env_append(mut state, ['HOMEBREW_RUSTFLAGS'], value, ' ')
}

pub fn shared_env_prepend_path(mut state SharedEnvState, key string, path string) {
	if path in ['/usr/bin', '/bin', '/usr/sbin', '/sbin'] {
		return
	}
	mut value := homebrew.new_brew_path(homebrew.path_input(state.environment[key] or { '' }))
	value.prepend(homebrew.path_input(path))
	state.environment[key] = value.str()
}

pub fn shared_env_prepend_create_path(mut state SharedEnvState, key string, path string) ! {
	os.mkdir_all(path)!
	state.created_paths << path
	shared_env_prepend_path(mut state, key, path)
}

pub fn shared_env_fetch_compiler(value string, source string) !SharedEnvCompiler {
	if value in ['gcc', 'clang', 'llvm_clang'] {
		return SharedEnvCompiler{ name: value, symbol: true }
	}
	if value.starts_with('gcc-') && value[4..] in shared_env_gnu_gcc_versions {
		return SharedEnvCompiler{ name: value, symbol: true }
	}
	return error('Invalid value for ${source}: ${value}')
}

fn shared_env_is_versioned_gcc(value string) bool {
	return value.starts_with('gcc-') && value[4..] in shared_env_gnu_gcc_versions
}

pub fn shared_env_gcc_version_formula(state &SharedEnvState,
	name string) !SharedEnvGccFormula {
	if !shared_env_is_versioned_gcc(name) {
		return error('Invalid Homebrew GCC name: ${name}')
	}
	version := name[4..]
	gcc := state.config.gcc_formulas['gcc'] or {
		return error('Homebrew GCC requested, but formula gcc not found!')
	}
	if gcc.version_suffix == version {
		return gcc
	}
	formula_name := 'gcc@${version}'
	return state.config.gcc_formulas[formula_name] or {
		return error('Homebrew GCC requested, but formula ${formula_name} not found!')
	}
}

pub fn shared_env_warn_about_non_apple_gcc(state &SharedEnvState, name string) ! {
	formula := shared_env_gcc_version_formula(state, name)!
	if formula.opt_prefix_exists {
		return
	}
	full_name := if formula.full_name != '' { formula.full_name } else { formula.name }
	return error('The requested Homebrew GCC was not installed. You must:\n  brew install ${full_name}')
}

pub fn shared_env_compiler(mut state SharedEnvState) !SharedEnvCompiler {
	if cached := state.compiler_cache {
		return cached
	}
	mut selected := SharedEnvCompiler{}
	if cc := state.cc_option {
		if shared_env_is_versioned_gcc(cc) {
			shared_env_warn_about_non_apple_gcc(state, cc)!
		}
		selected = shared_env_fetch_compiler(cc, '--cc')!
	} else if cc := state.environment['HOMEBREW_CC'] {
		if shared_env_is_versioned_gcc(cc) {
			shared_env_warn_about_non_apple_gcc(state, cc)!
		}
		selected = shared_env_fetch_compiler(cc, 'HOMEBREW_CC')!
		if state.formula != none && state.config.selected_formula_compiler != '' {
			selected = SharedEnvCompiler{ name: state.config.selected_formula_compiler, symbol: true }
		}
	} else if state.formula != none && state.config.selected_formula_compiler != '' {
		selected = SharedEnvCompiler{ name: state.config.selected_formula_compiler, symbol: true }
	} else {
		selected = SharedEnvCompiler{ name: state.config.default_compiler, symbol: true }
	}
	state.compiler_cache = selected
	return selected
}

pub fn shared_env_determine_cc(mut state SharedEnvState) !string {
	compiler := shared_env_compiler(mut state)!
	return compiler.name
}

pub fn shared_env_use_compiler(mut state SharedEnvState, compiler string,
	determined_cxx ?string) ! {
	state.compiler_cache = SharedEnvCompiler{
		name: compiler
		symbol: compiler in ['gcc', 'clang', 'llvm_clang'] || shared_env_is_versioned_gcc(compiler)
	}
	cc := shared_env_determine_cc(mut state)!
	cxx := determined_cxx or { cc.replace('gcc', 'g++').replace('clang', 'clang++') }
	shared_env_set_cc(mut state, cc)
	shared_env_set_cxx(mut state, cxx)
}

pub fn shared_env_set_cc(mut state SharedEnvState, value string) {
	state.environment['CC'] = value
	state.environment['OBJC'] = value
}

pub fn shared_env_set_cxx(mut state SharedEnvState, value string) {
	state.environment['CXX'] = value
	state.environment['OBJCXX'] = value
}

pub fn shared_env_fortran(mut state SharedEnvState) {
	if state.fortran_setup_done {
		return
	}
	state.fortran_setup_done = true
	mut flags := []string{}
	if compiler := state.environment['FC'] {
		state.output << 'Building with an unsupported Fortran compiler'
		if 'F77' !in state.environment {
			state.environment['F77'] = compiler
		}
	} else {
		mut gfortran := ''
		if path := state.config.gfortran_homebrew {
			gfortran = path
			state.output << 'Using Homebrew-provided Fortran compiler'
		} else if path := state.config.gfortran_original {
			gfortran = path
			state.output << 'Using a Fortran compiler found at ${path}'
		}
		if gfortran != '' {
			state.output << 'This may be changed by setting the `\$FC` environment variable.'
			state.environment['FC'] = gfortran
			state.environment['F77'] = gfortran
			flags = shared_env_fc_flag_vars.clone()
		}
	}
	for key in flags {
		if cflags := state.environment['CFLAGS'] {
			state.environment[key] = cflags
		} else {
			state.environment.delete(key)
		}
	}
	shared_env_set_cpu_flags(mut state, flags, {})
}

pub fn shared_env_effective_arch(state &SharedEnvState) string {
	if state.build_bottle {
		if arch := state.bottle_arch {
			return arch
		}
	}
	return state.config.oldest_cpu
}

pub fn shared_env_make_jobs(state &SharedEnvState) int {
	return state.config.make_jobs
}

pub fn shared_env_set_cpu_flags(mut state SharedEnvState, _ []string,
	_ map[string]string) {
	_ = state
}

pub fn shared_env_check_for_compiler_universal_support(state &SharedEnvState) ! {
	if cc := state.environment['HOMEBREW_CC'] {
		if shared_env_is_versioned_gcc(cc) {
			return error("Non-Apple GCC can't build universal binaries")
		}
	}
}
