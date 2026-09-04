module env

import ruby
import homebrew
import regex

// Translated from Homebrew/brew `extend/ENV/std.rb`.
pub const stdenv_safe_cflags = '-w -pipe'

pub type StdenvAction = fn (mut SharedEnvState) !ruby.Value

pub type StdenvPathPredicate = fn (string) bool

pub struct StdenvConfig {
pub:
	prefix               string
	shims_path           string
	original_paths       []string
	homebrew_extra_pkg   []string
	frameworks_exists    bool
	rustflags_target_cpu string
	optimization_flags   map[string]string
	arch_32_bit          string = 'i386'
	compiler_locations   map[string]string
	llvm_clang_path      ?string
}

fn stdenv_join_path(left string, right string) string {
	return if left == '' {
		right
	} else {
		'${left.trim_string_right('/')}/${right.trim_string_left('/')}'
	}
}

pub fn stdenv_determine_pkg_config_libdir(config StdenvConfig,
	exists StdenvPathPredicate) ?string {
	mut paths := [
		stdenv_join_path(config.prefix, 'lib/pkgconfig'),
		stdenv_join_path(config.prefix, 'share/pkgconfig'),
	]
	paths << config.homebrew_extra_pkg
	paths << '/usr/lib/pkgconfig'
	mut value := homebrew.new_brew_path(homebrew.path_array_input(paths))
	existing := value.select_paths(exists)
	return if existing.paths.len == 0 { none } else { existing.str() }
}

pub fn stdenv_determine_cc(mut state SharedEnvState, config StdenvConfig) !string {
	name := shared_env_determine_cc(mut state)!
	if name == 'llvm_clang' {
		if llvm := config.llvm_clang_path {
			return llvm
		}
	}
	return config.compiler_locations[name] or { name }
}

pub fn stdenv_determine_cxx(mut state SharedEnvState, config StdenvConfig) !string {
	cc := stdenv_determine_cc(mut state, config)!
	parts := cc.split('/')
	base := parts.last().replace_once('gcc', 'g++').replace_once('clang', 'clang++')
	if parts.len == 1 {
		return base
	}
	return parts[..parts.len - 1].join('/') + '/' + base
}

pub fn stdenv_define_cflags(mut state SharedEnvState, value string) {
	for key in shared_env_cc_flag_vars {
		state.environment[key] = value
	}
}

pub fn stdenv_replace_in_cflags(mut state SharedEnvState, pattern string,
	replacement string) ! {
	mut expression := regex.regex_opt(pattern)!
	for key in shared_env_cc_flag_vars {
		if value := state.environment[key] {
			start, end := expression.find(value)
			if start < 0 || end <= start {
				continue
			}
			mut expanded := replacement
			for group in 1 .. 10 {
				expanded = expanded.replace('\\${group}', expression.get_group_by_id(value, group - 1))
			}
			state.environment[key] = value[..start] + expanded + value[end..]
		}
	}
}

pub fn stdenv_set_cpu_flags(mut state SharedEnvState, config StdenvConfig,
	flags []string, values map[string]string) ! {
	mut xarch := ''
	if cflags := state.environment['CFLAGS'] {
		mut expression := regex.regex_opt('(-Xarch_${config.arch_32_bit} )-march=')!
		start, end := expression.find(cflags)
		if start >= 0 && end > start {
			xarch = cflags[start..].all_before('-march=')
		}
	}
	shared_env_remove(mut state, flags, SharedEnvRemoval{
		value: '(-Xarch_${config.arch_32_bit} )?-march=\\S*'
		regexp: true
	})!
	shared_env_remove(mut state, flags, SharedEnvRemoval{
		value: '( -Xclang \\S+)+'
		regexp: true
	})!
	shared_env_remove(mut state, flags, SharedEnvRemoval{ value: '-mssse3', regexp: true })!
	shared_env_remove(mut state, flags, SharedEnvRemoval{ value: '-msse4(\\.\\d)?', regexp: true })!
	if xarch != '' {
		shared_env_append(mut state, flags, xarch, ' ')
	}
	arch := shared_env_effective_arch(state)
	flag := values[arch] or { return error('key not found: ${arch}') }
	shared_env_append(mut state, flags, flag, ' ')
}

pub fn stdenv_set_cpu_cflags(mut state SharedEnvState, config StdenvConfig,
	values map[string]string) ! {
	stdenv_set_cpu_flags(mut state, config, shared_env_cc_flag_vars, values)!
}

pub fn stdenv_use_compiler(mut state SharedEnvState, config StdenvConfig,
	compiler string) ! {
	state.compiler_cache = SharedEnvCompiler{
		name: compiler
		symbol: compiler in ['gcc', 'clang', 'llvm_clang']
	}
	cc := stdenv_determine_cc(mut state, config)!
	cxx := stdenv_determine_cxx(mut state, config)!
	shared_env_set_cc(mut state, cc)
	shared_env_set_cxx(mut state, cxx)
}

pub fn stdenv_setup(mut state SharedEnvState, options SharedEnvBuildOptions,
	config StdenvConfig, exists StdenvPathPredicate) ! {
	shared_env_setup(mut state, options)
	state.environment['HOMEBREW_ENV'] = 'std'
	for index := config.original_paths.len - 1; index >= 0; index-- {
		shared_env_prepend_path(mut state, 'PATH', config.original_paths[index])
	}
	shared_env_prepend_path(mut state, 'PATH', stdenv_join_path(config.shims_path, 'shared'))
	if pkg_config := stdenv_determine_pkg_config_libdir(config, exists) {
		state.environment['PKG_CONFIG_LIBDIR'] = pkg_config
	} else {
		state.environment.delete('PKG_CONFIG_LIBDIR')
	}
	state.environment['MAKEFLAGS'] = '-j${state.config.make_jobs}'
	state.environment['RUSTC_WRAPPER'] = stdenv_join_path(config.shims_path, 'shared/rustc_wrapper')
	state.environment['HOMEBREW_RUSTFLAGS'] = config.rustflags_target_cpu
	if config.prefix != '/usr/local' {
		state.environment['CPPFLAGS'] = '-isystem${config.prefix}/include'
		state.environment['LDFLAGS'] = '-L${config.prefix}/lib'
		state.environment['CMAKE_PREFIX_PATH'] = config.prefix
	}
	frameworks := stdenv_join_path(config.prefix, 'Frameworks')
	if config.frameworks_exists {
		shared_env_append(mut state, ['CPPFLAGS'], '-F${frameworks}', ' ')
		shared_env_append(mut state, ['LDFLAGS'], '-F${frameworks}', ' ')
		state.environment['CMAKE_FRAMEWORK_PATH'] = frameworks
	}
	stdenv_define_cflags(mut state, '-Os ${stdenv_safe_cflags}')
	compiler := shared_env_compiler(mut state) or {
		if !options.testing_formula {
			return err
		}
		SharedEnvCompiler{ name: state.config.default_compiler, symbol: true }
	}
	stdenv_use_compiler(mut state, config, compiler.name)!
	if cc := options.cc {
		if shared_env_is_versioned_gcc(cc) {
			formula := shared_env_gcc_version_formula(state, cc)!
			shared_env_append_path(mut state, 'PATH', formula.opt_bin)
		}
	}
}

pub fn stdenv_deparallelize(mut state SharedEnvState,
	action ?StdenvAction) !SharedEnvRemovedValue {
	old := state.environment['MAKEFLAGS'] or { '' }
	had_old := 'MAKEFLAGS' in state.environment
	shared_env_remove(mut state, ['MAKEFLAGS'], SharedEnvRemoval{
		value: '-j\\d+'
		regexp: true
	})!
	if block := action {
		defer {
			if had_old {
				state.environment['MAKEFLAGS'] = old
			} else {
				state.environment.delete('MAKEFLAGS')
			}
		}
		block(mut state)!
	}
	return SharedEnvRemovedValue{
		existed: had_old
		value: old
	}
}

pub fn stdenv_opt(mut state SharedEnvState, level string) ! {
	shared_env_remove_from_cflags(mut state, SharedEnvRemoval{
		value: '-O.'
		regexp: true
	})!
	shared_env_append_to_cflags(mut state, '-${level}')
}

pub fn stdenv_clang(mut state SharedEnvState, config StdenvConfig) ! {
	stdenv_use_compiler(mut state, config, 'clang')!
	stdenv_replace_in_cflags(mut state, '-Xarch_${config.arch_32_bit} (-march=\\S*)', '\\1')!
	stdenv_set_cpu_cflags(mut state, config, config.optimization_flags)!
}

pub fn stdenv_gcc(mut state SharedEnvState, config StdenvConfig,
	compiler string) ! {
	stdenv_use_compiler(mut state, config, compiler)!
	stdenv_set_cpu_cflags(mut state, config, config.optimization_flags)!
}

pub fn stdenv_libcxx(mut state SharedEnvState) ! {
	compiler := shared_env_compiler(mut state)!
	if compiler.name == 'clang' {
		shared_env_append(mut state, ['CXX'], '-stdlib=libc++', ' ')
	}
}

pub fn stdenv_cxx11(mut state SharedEnvState) ! {
	shared_env_append(mut state, ['CXX'], '-std=c++11', ' ')
	stdenv_libcxx(mut state)!
}
