module env

import homebrew
import os
import regex

// Translated from Homebrew/brew `extend/ENV/shared.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :bottle_arch` at line 40.
pub fn ruby_shared_l40_d1_bottle_arch(state &SharedEnvState) ?string {
	return state.bottle_arch
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,` at line 52.
pub fn ruby_shared_l52_d2_setup_build_environment(mut state SharedEnvState,
	options SharedEnvBuildOptions) {
	shared_env_setup(mut state, options)
}

// Ruby method `build_bottle? = @build_bottle == true` at line 64.
pub fn ruby_shared_l64_d3_build_bottle(state &SharedEnvState) bool {
	return shared_env_build_bottle(state)
}

// Ruby method `debug_symbols? = @debug_symbols == true` at line 67.
pub fn ruby_shared_l67_d4_debug_symbols(state &SharedEnvState) bool {
	return shared_env_debug_symbols(state)
}

// Ruby method `reset` at line 70.
pub fn ruby_shared_l70_d5_reset(mut state SharedEnvState) {
	shared_env_reset(mut state)
}

// Ruby method `remove_cc_etc` at line 76.
pub fn ruby_shared_l76_d6_remove_cc_etc(mut state SharedEnvState) map[string]SharedEnvRemovedValue {
	return shared_env_remove_cc_etc(mut state)
}

// Ruby method `append_to_cflags(newflags)` at line 82.
pub fn ruby_shared_l82_d7_append_to_cflags(mut state SharedEnvState, flags string) {
	shared_env_append_to_cflags(mut state, flags)
}

// Ruby method `remove_from_cflags(val)` at line 87.
pub fn ruby_shared_l87_d8_remove_from_cflags(mut state SharedEnvState,
	removal SharedEnvRemoval) ! {
	shared_env_remove_from_cflags(mut state, removal)!
}

// Ruby method `append_to_cccfg(value)` at line 92.
pub fn ruby_shared_l92_d9_append_to_cccfg(mut state SharedEnvState, value string) {
	shared_env_append_to_cccfg(mut state, value)
}

// Ruby method `append(keys, value, separator = " ")` at line 97.
pub fn ruby_shared_l97_d10_append(mut state SharedEnvState, keys []string, value string,
	separator string) {
	shared_env_append(mut state, keys, value, separator)
}

// Ruby method `prepend(keys, value, separator = " ")` at line 110.
pub fn ruby_shared_l110_d11_prepend(mut state SharedEnvState, keys []string, value string,
	separator string) {
	shared_env_prepend(mut state, keys, value, separator)
}

// Ruby method `append_path(key, path)` at line 123.
pub fn ruby_shared_l123_d12_append_path(mut state SharedEnvState, key string, path string) {
	shared_env_append_path(mut state, key, path)
}

// Ruby method `append_to_rustflags(rustflags)` at line 128.
pub fn ruby_shared_l128_d13_append_to_rustflags(mut state SharedEnvState, value string) {
	shared_env_append_to_rustflags(mut state, value)
}

// Ruby method `prepend_path(key, path)` at line 140.
pub fn ruby_shared_l140_d14_prepend_path(mut state SharedEnvState, key string, path string) {
	shared_env_prepend_path(mut state, key, path)
}

// Ruby method `prepend_create_path(key, path)` at line 147.
pub fn ruby_shared_l147_d15_prepend_create_path(mut state SharedEnvState, key string,
	path string) ! {
	shared_env_prepend_create_path(mut state, key, path)!
}

// Ruby method `remove(keys, value)` at line 154.
pub fn ruby_shared_l154_d16_remove(mut state SharedEnvState, keys []string,
	removal ?SharedEnvRemoval) ! {
	shared_env_remove(mut state, keys, removal)!
}

// Ruby method `cc` at line 171.
pub fn ruby_shared_l171_d17_cc(state &SharedEnvState) ?string {
	return state.value('CC')
}

// Ruby method `cxx` at line 176.
pub fn ruby_shared_l176_d18_cxx(state &SharedEnvState) ?string {
	return state.value('CXX')
}

// Ruby method `cflags` at line 181.
pub fn ruby_shared_l181_d19_cflags(state &SharedEnvState) ?string {
	return state.value('CFLAGS')
}

// Ruby method `cxxflags` at line 186.
pub fn ruby_shared_l186_d20_cxxflags(state &SharedEnvState) ?string {
	return state.value('CXXFLAGS')
}

// Ruby method `cppflags` at line 191.
pub fn ruby_shared_l191_d21_cppflags(state &SharedEnvState) ?string {
	return state.value('CPPFLAGS')
}

// Ruby method `ldflags` at line 196.
pub fn ruby_shared_l196_d22_ldflags(state &SharedEnvState) ?string {
	return state.value('LDFLAGS')
}

// Ruby method `fc` at line 201.
pub fn ruby_shared_l201_d23_fc(state &SharedEnvState) ?string {
	return state.value('FC')
}

// Ruby method `fflags` at line 206.
pub fn ruby_shared_l206_d24_fflags(state &SharedEnvState) ?string {
	return state.value('FFLAGS')
}

// Ruby method `fcflags` at line 211.
pub fn ruby_shared_l211_d25_fcflags(state &SharedEnvState) ?string {
	return state.value('FCFLAGS')
}

// Ruby method `compiler` at line 222.
pub fn ruby_shared_l222_d26_compiler(mut state SharedEnvState) !SharedEnvCompiler {
	return shared_env_compiler(mut state)
}

// Ruby method `determine_cc` at line 247.
pub fn ruby_shared_l247_d27_determine_cc(mut state SharedEnvState) !string {
	return shared_env_determine_cc(mut state)
}

// Ruby define_method `define_method(compiler) do` at line 258.
pub fn ruby_shared_l258_d28_compiler(mut state SharedEnvState, compiler string,
	determined_cxx ?string) ! {
	shared_env_use_compiler(mut state, compiler, determined_cxx)!
}

// Ruby method `fortran` at line 267.
pub fn ruby_shared_l267_d29_fortran(mut state SharedEnvState) {
	shared_env_fortran(mut state)
}

// Ruby method `effective_arch` at line 298.
pub fn ruby_shared_l298_d30_effective_arch(state &SharedEnvState) string {
	return shared_env_effective_arch(state)
}

// Ruby method `gcc_version_formula(name)` at line 307.
pub fn ruby_shared_l307_d31_gcc_version_formula(state &SharedEnvState,
	name string) !SharedEnvGccFormula {
	return shared_env_gcc_version_formula(state, name)
}

// Ruby method `warn_about_non_apple_gcc(name)` at line 321.
pub fn ruby_shared_l321_d32_warn_about_non_apple_gcc(state &SharedEnvState, name string) ! {
	shared_env_warn_about_non_apple_gcc(state, name)!
}

// Ruby method `permit_arch_flags; end` at line 340.
pub fn ruby_shared_l340_d33_permit_arch_flags(_ &SharedEnvState) {
}

// Ruby method `make_jobs` at line 343.
pub fn ruby_shared_l343_d34_make_jobs(state &SharedEnvState) int {
	return shared_env_make_jobs(state)
}

// Ruby method `refurbish_args; end` at line 348.
pub fn ruby_shared_l348_d35_refurbish_args(_ &SharedEnvState) {
}

// Ruby method `set_cpu_flags(_flags, _map = {}); end` at line 353.
pub fn ruby_shared_l353_d36_set_cpu_flags(mut state SharedEnvState, flags []string,
	values map[string]string) {
	shared_env_set_cpu_flags(mut state, flags, values)
}

// Ruby method `cc=(val)` at line 356.
pub fn ruby_shared_l356_d37_cc(mut state SharedEnvState, value string) {
	shared_env_set_cc(mut state, value)
}

// Ruby method `cxx=(val)` at line 361.
pub fn ruby_shared_l361_d38_cxx(mut state SharedEnvState, value string) {
	shared_env_set_cxx(mut state, value)
}

// Ruby method `homebrew_cc` at line 366.
pub fn ruby_shared_l366_d39_homebrew_cc(state &SharedEnvState) ?string {
	return state.value('HOMEBREW_CC')
}

// Ruby method `fetch_compiler(value, source)` at line 371.
pub fn ruby_shared_l371_d40_fetch_compiler(value string,
	source string) !SharedEnvCompiler {
	return shared_env_fetch_compiler(value, source)
}

// Ruby method `check_for_compiler_universal_support` at line 383.
pub fn ruby_shared_l383_d41_check_for_compiler_universal_support(state &SharedEnvState) ! {
	shared_env_check_for_compiler_universal_support(state)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5: require "development_tools"
// 6:
// 7: # Homebrew extends Ruby's `ENV` to make our code more readable.
// 8: # Implemented in {SharedEnvExtension} and either {Superenv} or
// 9: # {Stdenv} (depending on the build mode).
// 10: # @see Superenv
// 11: # @see Stdenv
// 12: # @see https://www.rubydoc.info/stdlib/Env Ruby's ENV API
// 13: module SharedEnvExtension
// 14:   extend T::Helpers
// 15:   include CompilerConstants
// 16:   include Utils::Output::Mixin
// 17:
// 18:   requires_ancestor { Sorbet::Private::Static::ENVClass }
// 19:
// 20:   CC_FLAG_VARS = %w[CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS].freeze
// 21:   private_constant :CC_FLAG_VARS
// 22:
// 23:   FC_FLAG_VARS = %w[FCFLAGS FFLAGS].freeze
// 24:   private_constant :FC_FLAG_VARS
// 25:
// 26:   SANITIZED_VARS = %w[
// 27:     CDPATH CLICOLOR_FORCE
// 28:     CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH
// 29:     CC CXX OBJC OBJCXX CPP MAKE LD LDSHARED
// 30:     CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS LDFLAGS CPPFLAGS
// 31:     MACOSX_DEPLOYMENT_TARGET SDKROOT DEVELOPER_DIR
// 32:     CMAKE_PREFIX_PATH CMAKE_INCLUDE_PATH CMAKE_FRAMEWORK_PATH
// 33:     GOBIN GOPATH GOROOT PERL_MB_OPT PERL_MM_OPT
// 34:     LIBRARY_PATH LD_LIBRARY_PATH LD_PRELOAD LD_RUN_PATH
// 35:     RUSTFLAGS
// 36:   ].freeze
// 37:   private_constant :SANITIZED_VARS
// 38:
// 39:   sig { returns(T.nilable(String)) }
// 40:   attr_reader :bottle_arch
// 41:
// 42:   sig {
// 43:     params(
// 44:       formula:         T.nilable(Formula),
// 45:       cc:              T.nilable(String),
// 46:       build_bottle:    T.nilable(T::Boolean),
// 47:       bottle_arch:     T.nilable(String),
// 48:       testing_formula: T::Boolean,
// 49:       debug_symbols:   T.nilable(T::Boolean),
// 50:     ).void
// 51:   }
// 52:   def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,
// 53:                               debug_symbols: false)
// 54:     @formula = T.let(formula, T.nilable(Formula))
// 55:     @cc = T.let(cc, T.nilable(String))
// 56:     @build_bottle = T.let(build_bottle, T.nilable(T::Boolean))
// 57:     @bottle_arch = T.let(bottle_arch, T.nilable(String))
// 58:     @debug_symbols = T.let(debug_symbols, T.nilable(T::Boolean))
// 59:     @testing_formula = T.let(testing_formula, T.nilable(T::Boolean))
// 60:     reset
// 61:   end
// 62:
// 63:   sig { returns(T::Boolean) }
// 64:   def build_bottle? = @build_bottle == true
// 65:
// 66:   sig { returns(T::Boolean) }
// 67:   def debug_symbols? = @debug_symbols == true
// 68:
// 69:   sig { void }
// 70:   def reset
// 71:     SANITIZED_VARS.each { |k| delete(k) }
// 72:   end
// 73:   private :reset
// 74:
// 75:   sig { returns(T::Hash[String, T.nilable(String)]) }
// 76:   def remove_cc_etc
// 77:     keys = %w[CC CXX OBJC OBJCXX LD CPP CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS LDFLAGS CPPFLAGS]
// 78:     keys.to_h { |key| [key, delete(key)] }
// 79:   end
// 80:
// 81:   sig { params(newflags: String).void }
// 82:   def append_to_cflags(newflags)
// 83:     append(CC_FLAG_VARS, newflags)
// 84:   end
// 85:
// 86:   sig { params(val: T.any(Regexp, String)).void }
// 87:   def remove_from_cflags(val)
// 88:     remove CC_FLAG_VARS, val
// 89:   end
// 90:
// 91:   sig { params(value: String).void }
// 92:   def append_to_cccfg(value)
// 93:     append("HOMEBREW_CCCFG", value, "")
// 94:   end
// 95:
// 96:   sig { params(keys: T.any(String, T::Array[String]), value: T.untyped, separator: String).void }
// 97:   def append(keys, value, separator = " ")
// 98:     value = value.to_s
// 99:     Array(keys).each do |key|
// 100:       old_value = self[key]
// 101:       self[key] = if old_value.blank?
// 102:         value
// 103:       else
// 104:         old_value + separator + value
// 105:       end
// 106:     end
// 107:   end
// 108:
// 109:   sig { params(keys: T.any(String, T::Array[String]), value: T.untyped, separator: String).void }
// 110:   def prepend(keys, value, separator = " ")
// 111:     value = value.to_s
// 112:     Array(keys).each do |key|
// 113:       old_value = self[key]
// 114:       self[key] = if old_value.blank?
// 115:         value
// 116:       else
// 117:         value + separator + old_value
// 118:       end
// 119:     end
// 120:   end
// 121:
// 122:   sig { params(key: String, path: T.any(String, Pathname)).void }
// 123:   def append_path(key, path)
// 124:     self[key] = PATH.new(self[key]).append(path).to_s
// 125:   end
// 126:
// 127:   sig { params(rustflags: String).void }
// 128:   def append_to_rustflags(rustflags)
// 129:     append("HOMEBREW_RUSTFLAGS", rustflags)
// 130:   end
// 131:
// 132:   # Prepends a directory to `PATH`.
// 133:   # Is the formula struggling to find the pkgconfig file? Point it to it.
// 134:   # This is done automatically for keg-only formulae.
// 135:   # <pre>ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["glib"].opt_lib}/pkgconfig"</pre>
// 136:   # Prepending a system path such as /usr/bin is a no-op so that requirements
// 137:   # don't accidentally override superenv shims or formulae's `bin` directories.
// 138:   # <pre>ENV.prepend_path "PATH", which("emacs").dirname</pre>
// 139:   sig { params(key: String, path: T.any(String, Pathname)).void }
// 140:   def prepend_path(key, path)
// 141:     return if %w[/usr/bin /bin /usr/sbin /sbin].include? path.to_s
// 142:
// 143:     self[key] = PATH.new(self[key]).prepend(path).to_s
// 144:   end
// 145:
// 146:   sig { params(key: String, path: T.any(String, Pathname)).void }
// 147:   def prepend_create_path(key, path)
// 148:     path = Pathname(path)
// 149:     path.mkpath
// 150:     prepend_path key, path
// 151:   end
// 152:
// 153:   sig { params(keys: T.any(String, T::Array[String]), value: T.untyped).void }
// 154:   def remove(keys, value)
// 155:     return if value.nil?
// 156:
// 157:     Array(keys).each do |key|
// 158:       old_value = self[key]
// 159:       next if old_value.nil?
// 160:
// 161:       new_value = old_value.sub(value, "")
// 162:       if new_value.empty?
// 163:         delete(key)
// 164:       else
// 165:         self[key] = new_value
// 166:       end
// 167:     end
// 168:   end
// 169:
// 170:   sig { returns(T.nilable(String)) }
// 171:   def cc
// 172:     self["CC"]
// 173:   end
// 174:
// 175:   sig { returns(T.nilable(String)) }
// 176:   def cxx
// 177:     self["CXX"]
// 178:   end
// 179:
// 180:   sig { returns(T.nilable(String)) }
// 181:   def cflags
// 182:     self["CFLAGS"]
// 183:   end
// 184:
// 185:   sig { returns(T.nilable(String)) }
// 186:   def cxxflags
// 187:     self["CXXFLAGS"]
// 188:   end
// 189:
// 190:   sig { returns(T.nilable(String)) }
// 191:   def cppflags
// 192:     self["CPPFLAGS"]
// 193:   end
// 194:
// 195:   sig { returns(T.nilable(String)) }
// 196:   def ldflags
// 197:     self["LDFLAGS"]
// 198:   end
// 199:
// 200:   sig { returns(T.nilable(String)) }
// 201:   def fc
// 202:     self["FC"]
// 203:   end
// 204:
// 205:   sig { returns(T.nilable(String)) }
// 206:   def fflags
// 207:     self["FFLAGS"]
// 208:   end
// 209:
// 210:   sig { returns(T.nilable(String)) }
// 211:   def fcflags
// 212:     self["FCFLAGS"]
// 213:   end
// 214:
// 215:   # Outputs the current compiler.
// 216:   # <pre># Do something only for the system clang
// 217:   # if ENV.compiler == :clang
// 218:   #   # modify CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS in one go:
// 219:   #   ENV.append_to_cflags "-I ./missing/includes"
// 220:   # end</pre>
// 221:   sig { returns(T.any(Symbol, String)) }
// 222:   def compiler
// 223:     @compiler ||= T.let(nil, T.nilable(T.any(Symbol, String)))
// 224:     @compiler ||= if (cc = @cc)
// 225:       warn_about_non_apple_gcc(cc) if cc.match?(GNU_GCC_REGEXP)
// 226:
// 227:       fetch_compiler(cc, "--cc")
// 228:     elsif (cc = homebrew_cc)
// 229:       warn_about_non_apple_gcc(cc) if cc.match?(GNU_GCC_REGEXP)
// 230:
// 231:       compiler = fetch_compiler(cc, "HOMEBREW_CC")
// 232:
// 233:       if @formula
// 234:         compilers = [compiler] + CompilerSelector.compilers
// 235:         compiler = CompilerSelector.select_for(@formula, compilers, testing_formula: @testing_formula == true)
// 236:       end
// 237:
// 238:       compiler
// 239:     elsif @formula
// 240:       CompilerSelector.select_for(@formula, testing_formula: @testing_formula == true)
// 241:     else
// 242:       DevelopmentTools.default_compiler
// 243:     end
// 244:   end
// 245:
// 246:   sig { returns(T.any(String, Pathname)) }
// 247:   def determine_cc
// 248:     case (cc = compiler)
// 249:     when Symbol
// 250:       COMPILER_SYMBOL_MAP.invert.fetch(cc)
// 251:     else
// 252:       cc
// 253:     end
// 254:   end
// 255:   private :determine_cc
// 256:
// 257:   COMPILERS.each do |compiler|
// 258:     define_method(compiler) do
// 259:       @compiler = T.let(compiler, T.nilable(T.any(Symbol, String)))
// 260:
// 261:       send(:cc=, send(:determine_cc))
// 262:       send(:cxx=, send(:determine_cxx))
// 263:     end
// 264:   end
// 265:
// 266:   sig { void }
// 267:   def fortran
// 268:     # Ignore repeated calls to this function as it will misleadingly warn about
// 269:     # building with an alternative Fortran compiler without optimization flags,
// 270:     # despite it often being the Homebrew-provided one set up in the first call.
// 271:     return if @fortran_setup_done
// 272:
// 273:     @fortran_setup_done = T.let(true, T.nilable(TrueClass))
// 274:
// 275:     flags = []
// 276:
// 277:     if fc
// 278:       opoo "Building with an unsupported Fortran compiler"
// 279:       self["F77"] ||= fc
// 280:     else
// 281:       if (gfortran = which("gfortran", (HOMEBREW_PREFIX/"bin").to_s))
// 282:         ohai "Using Homebrew-provided Fortran compiler"
// 283:       elsif (gfortran = which("gfortran", PATH.new(ORIGINAL_PATHS)))
// 284:         ohai "Using a Fortran compiler found at #{gfortran}"
// 285:       end
// 286:       if gfortran
// 287:         puts "This may be changed by setting the `$FC` environment variable."
// 288:         self["FC"] = self["F77"] = gfortran.to_s
// 289:         flags = FC_FLAG_VARS
// 290:       end
// 291:     end
// 292:
// 293:     flags.each { |key| self[key] = cflags }
// 294:     set_cpu_flags(flags)
// 295:   end
// 296:
// 297:   sig { returns(Symbol) }
// 298:   def effective_arch
// 299:     if @build_bottle && @bottle_arch
// 300:       @bottle_arch.to_sym
// 301:     else
// 302:       Hardware.oldest_cpu
// 303:     end
// 304:   end
// 305:
// 306:   sig { params(name: String).returns(Formula) }
// 307:   def gcc_version_formula(name)
// 308:     version = name[GNU_GCC_REGEXP, 1]
// 309:     gcc_version_name = "gcc@#{version}"
// 310:
// 311:     gcc = Formulary.factory("gcc")
// 312:     if gcc.respond_to?(:version_suffix) && T.unsafe(gcc).version_suffix == version
// 313:       gcc
// 314:     else
// 315:       Formulary.factory(gcc_version_name)
// 316:     end
// 317:   end
// 318:   private :gcc_version_formula
// 319:
// 320:   sig { params(name: String).void }
// 321:   def warn_about_non_apple_gcc(name)
// 322:     begin
// 323:       gcc_formula = gcc_version_formula(name)
// 324:     rescue FormulaUnavailableError => e
// 325:       raise <<~EOS
// 326:         Homebrew GCC requested, but formula #{e.name} not found!
// 327:       EOS
// 328:     end
// 329:
// 330:     return if gcc_formula.opt_prefix.exist?
// 331:
// 332:     raise <<~EOS
// 333:       The requested Homebrew GCC was not installed. You must:
// 334:         brew install #{gcc_formula.full_name}
// 335:     EOS
// 336:   end
// 337:   private :warn_about_non_apple_gcc
// 338:
// 339:   sig { void }
// 340:   def permit_arch_flags; end
// 341:
// 342:   sig { returns(Integer) }
// 343:   def make_jobs
// 344:     Homebrew::EnvConfig.make_jobs.to_i
// 345:   end
// 346:
// 347:   sig { void }
// 348:   def refurbish_args; end
// 349:
// 350:   private
// 351:
// 352:   sig { params(_flags: T::Array[String], _map: T::Hash[Symbol, String]).void }
// 353:   def set_cpu_flags(_flags, _map = {}); end
// 354:
// 355:   sig { params(val: T.any(String, Pathname)).void }
// 356:   def cc=(val)
// 357:     self["CC"] = self["OBJC"] = val.to_s
// 358:   end
// 359:
// 360:   sig { params(val: T.any(String, Pathname)).void }
// 361:   def cxx=(val)
// 362:     self["CXX"] = self["OBJCXX"] = val.to_s
// 363:   end
// 364:
// 365:   sig { returns(T.nilable(String)) }
// 366:   def homebrew_cc
// 367:     self["HOMEBREW_CC"]
// 368:   end
// 369:
// 370:   sig { params(value: String, source: String).returns(Symbol) }
// 371:   def fetch_compiler(value, source)
// 372:     COMPILER_SYMBOL_MAP.fetch(value) do |other|
// 373:       case other
// 374:       when GNU_GCC_REGEXP
// 375:         other.to_sym
// 376:       else
// 377:         raise "Invalid value for #{source}: #{other}"
// 378:       end
// 379:     end
// 380:   end
// 381:
// 382:   sig { void }
// 383:   def check_for_compiler_universal_support
// 384:     raise "Non-Apple GCC can't build universal binaries" if homebrew_cc&.match?(GNU_GCC_REGEXP)
// 385:   end
// 386: end
// 387:
// 388: require "extend/os/extend/ENV/shared"
