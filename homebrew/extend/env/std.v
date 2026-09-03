module env

import brew_runtime
import homebrew
import regex

// Translated from Homebrew/brew `extend/ENV/std.rb`.
// The original source is retained below until every stub has a typed V body.
pub const stdenv_safe_cflags = '-w -pipe'

pub type StdenvAction = fn(mut SharedEnvState) !brew_runtime.Value

pub type StdenvPathPredicate = fn(string) bool

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

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,` at line 23.
pub fn ruby_std_l23_d1_setup_build_environment(mut state SharedEnvState,
	options SharedEnvBuildOptions, config StdenvConfig, exists StdenvPathPredicate) ! {
	stdenv_setup(mut state, options, config, exists)!
}

// Ruby method `determine_pkg_config_libdir` at line 74.
pub fn ruby_std_l74_d2_determine_pkg_config_libdir(config StdenvConfig,
	exists StdenvPathPredicate) ?string {
	return stdenv_determine_pkg_config_libdir(config, exists)
}

// Ruby method `deparallelize(&block)` at line 87.
pub fn ruby_std_l87_d3_deparallelize(mut state SharedEnvState,
	action ?StdenvAction) !SharedEnvRemovedValue {
	return stdenv_deparallelize(mut state, action)
}

// Ruby define_method `define_method opt do` at line 102.
pub fn ruby_std_l102_d4_opt(mut state SharedEnvState, level string) ! {
	stdenv_opt(mut state, level)!
}

// Ruby method `determine_cc` at line 109.
pub fn ruby_std_l109_d5_determine_cc(mut state SharedEnvState,
	config StdenvConfig) !string {
	return stdenv_determine_cc(mut state, config)
}

// Ruby method `determine_cxx` at line 122.
pub fn ruby_std_l122_d6_determine_cxx(mut state SharedEnvState,
	config StdenvConfig) !string {
	return stdenv_determine_cxx(mut state, config)
}

// Ruby define_method `define_method(:"gcc-#{n}") do` at line 129.
pub fn ruby_std_l129_d7_gcc_n(mut state SharedEnvState, config StdenvConfig,
	compiler string) ! {
	stdenv_gcc(mut state, config, compiler)!
}

// Ruby method `clang` at line 136.
pub fn ruby_std_l136_d8_clang(mut state SharedEnvState, config StdenvConfig) ! {
	stdenv_clang(mut state, config)!
}

// Ruby method `cxx11` at line 143.
pub fn ruby_std_l143_d9_cxx11(mut state SharedEnvState) ! {
	stdenv_cxx11(mut state)!
}

// Ruby method `libcxx` at line 149.
pub fn ruby_std_l149_d10_libcxx(mut state SharedEnvState) ! {
	stdenv_libcxx(mut state)!
}

// Ruby method `replace_in_cflags(before, after)` at line 156.
pub fn ruby_std_l156_d11_replace_in_cflags(mut state SharedEnvState, pattern string,
	replacement string) ! {
	stdenv_replace_in_cflags(mut state, pattern, replacement)!
}

// Ruby method `define_cflags(val)` at line 164.
pub fn ruby_std_l164_d12_define_cflags(mut state SharedEnvState, value string) {
	stdenv_define_cflags(mut state, value)
}

// Ruby method `set_cpu_flags(flags, map = Hardware::CPU.optimization_flags)` at line 171.
pub fn ruby_std_l171_d13_set_cpu_flags(mut state SharedEnvState, config StdenvConfig,
	flags []string, values map[string]string) ! {
	stdenv_set_cpu_flags(mut state, config, flags, values)!
}

// Ruby method `homebrew_extra_pkg_config_paths` at line 183.
pub fn ruby_std_l183_d14_homebrew_extra_pkg_config_paths(config StdenvConfig) []string {
	return config.homebrew_extra_pkg.clone()
}

// Ruby method `set_cpu_cflags(map = Hardware::CPU.optimization_flags)` at line 188.
pub fn ruby_std_l188_d15_set_cpu_cflags(mut state SharedEnvState, config StdenvConfig,
	values map[string]string) ! {
	stdenv_set_cpu_cflags(mut state, config, values)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5: require "extend/ENV/shared"
// 6:
// 7: module Stdenv
// 8:   include SharedEnvExtension
// 9:
// 10:   SAFE_CFLAGS_FLAGS = "-w -pipe"
// 11:   private_constant :SAFE_CFLAGS_FLAGS
// 12:
// 13:   sig {
// 14:     params(
// 15:       formula:         T.nilable(Formula),
// 16:       cc:              T.nilable(String),
// 17:       build_bottle:    T.nilable(T::Boolean),
// 18:       bottle_arch:     T.nilable(String),
// 19:       testing_formula: T::Boolean,
// 20:       debug_symbols:   T.nilable(T::Boolean),
// 21:     ).void
// 22:   }
// 23:   def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,
// 24:                               debug_symbols: false)
// 25:     super
// 26:
// 27:     self["HOMEBREW_ENV"] = "std"
// 28:
// 29:     ORIGINAL_PATHS.reverse_each { |p| prepend_path "PATH", p }
// 30:     prepend_path "PATH", HOMEBREW_SHIMS_PATH/"shared"
// 31:
// 32:     # Set the default pkg-config search path, overriding the built-in paths
// 33:     # Anything in PKG_CONFIG_PATH is searched before paths in this variable
// 34:     self["PKG_CONFIG_LIBDIR"] = determine_pkg_config_libdir&.to_s
// 35:
// 36:     self["MAKEFLAGS"] = "-j#{make_jobs}"
// 37:     self["RUSTC_WRAPPER"] = "#{HOMEBREW_SHIMS_PATH}/shared/rustc_wrapper"
// 38:     self["HOMEBREW_RUSTFLAGS"] = Hardware.rustflags_target_cpu(effective_arch)
// 39:
// 40:     if HOMEBREW_PREFIX.to_s != "/usr/local"
// 41:       # /usr/local is already an -isystem and -L directory so we skip it
// 42:       self["CPPFLAGS"] = "-isystem#{HOMEBREW_PREFIX}/include"
// 43:       self["LDFLAGS"] = "-L#{HOMEBREW_PREFIX}/lib"
// 44:       # CMake ignores the variables above
// 45:       self["CMAKE_PREFIX_PATH"] = HOMEBREW_PREFIX.to_s
// 46:     end
// 47:
// 48:     frameworks = HOMEBREW_PREFIX.join("Frameworks")
// 49:     if frameworks.directory?
// 50:       append "CPPFLAGS", "-F#{frameworks}"
// 51:       append "LDFLAGS", "-F#{frameworks}"
// 52:       self["CMAKE_FRAMEWORK_PATH"] = frameworks.to_s
// 53:     end
// 54:
// 55:     # Os is the default Apple uses for all its stuff so let's trust them
// 56:     define_cflags "-Os #{SAFE_CFLAGS_FLAGS}"
// 57:
// 58:     begin
// 59:       send(compiler)
// 60:     rescue CompilerSelectionError
// 61:       # We don't care if our compiler fails to build the formula during `brew test`.
// 62:       raise unless testing_formula
// 63:
// 64:       send(DevelopmentTools.default_compiler)
// 65:     end
// 66:
// 67:     return unless cc&.match?(GNU_GCC_REGEXP)
// 68:
// 69:     gcc_formula = gcc_version_formula(cc)
// 70:     append_path "PATH", gcc_formula.opt_bin.to_s
// 71:   end
// 72:
// 73:   sig { returns(T.nilable(PATH)) }
// 74:   def determine_pkg_config_libdir
// 75:     PATH.new(
// 76:       HOMEBREW_PREFIX/"lib/pkgconfig",
// 77:       HOMEBREW_PREFIX/"share/pkgconfig",
// 78:       homebrew_extra_pkg_config_paths,
// 79:       "/usr/lib/pkgconfig",
// 80:     ).existing
// 81:   end
// 82:
// 83:   # Removes the MAKEFLAGS environment variable, causing make to use a single job.
// 84:   # This is useful for makefiles with race conditions.
// 85:   # When passed a block, MAKEFLAGS is removed only for the duration of the block and is restored after its completion.
// 86:   sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
// 87:   def deparallelize(&block)
// 88:     old = self["MAKEFLAGS"]
// 89:     remove "MAKEFLAGS", /-j\d+/
// 90:     if block
// 91:       begin
// 92:         yield
// 93:       ensure
// 94:         self["MAKEFLAGS"] = old
// 95:       end
// 96:     end
// 97:
// 98:     old
// 99:   end
// 100:
// 101:   %w[O1 O0].each do |opt|
// 102:     define_method opt do
// 103:       send(:remove_from_cflags, /-O./)
// 104:       send(:append_to_cflags, "-#{opt}")
// 105:     end
// 106:   end
// 107:
// 108:   sig { returns(T.any(String, Pathname)) }
// 109:   def determine_cc
// 110:     s = super
// 111:     begin
// 112:       return Formula["llvm"].opt_bin/"clang" if s == "llvm_clang"
// 113:     rescue FormulaUnavailableError
// 114:       # Don't fail and just let callee handle Pathname("llvm_clang")
// 115:     end
// 116:
// 117:     DevelopmentTools.locate(s) || Pathname(s)
// 118:   end
// 119:   private :determine_cc
// 120:
// 121:   sig { returns(Pathname) }
// 122:   def determine_cxx
// 123:     dir, base = Pathname(determine_cc).split
// 124:     dir/base.to_s.sub("gcc", "g++").sub("clang", "clang++")
// 125:   end
// 126:   private :determine_cxx
// 127:
// 128:   GNU_GCC_VERSIONS.each do |n|
// 129:     define_method(:"gcc-#{n}") do
// 130:       super()
// 131:       send(:set_cpu_cflags)
// 132:     end
// 133:   end
// 134:
// 135:   sig { void }
// 136:   def clang
// 137:     super
// 138:     replace_in_cflags(/-Xarch_#{Hardware::CPU.arch_32_bit} (-march=\S*)/, '\1')
// 139:     set_cpu_cflags
// 140:   end
// 141:
// 142:   sig { void }
// 143:   def cxx11
// 144:     append "CXX", "-std=c++11"
// 145:     libcxx
// 146:   end
// 147:
// 148:   sig { void }
// 149:   def libcxx
// 150:     append "CXX", "-stdlib=libc++" if compiler == :clang
// 151:   end
// 152:
// 153:   private
// 154:
// 155:   sig { params(before: Regexp, after: String).void }
// 156:   def replace_in_cflags(before, after)
// 157:     CC_FLAG_VARS.each do |key|
// 158:       self[key] = fetch(key).sub(before, after) if key?(key)
// 159:     end
// 160:   end
// 161:
// 162:   # Convenience method to set all C compiler flags in one shot.
// 163:   sig { params(val: String).void }
// 164:   def define_cflags(val)
// 165:     CC_FLAG_VARS.each { |key| self[key] = val }
// 166:   end
// 167:
// 168:   # Sets architecture-specific flags for every environment variable
// 169:   # given in the list `flags`.
// 170:   sig { params(flags: T::Array[String], map: T::Hash[Symbol, String]).void }
// 171:   def set_cpu_flags(flags, map = Hardware::CPU.optimization_flags)
// 172:     cflags =~ /(-Xarch_#{Hardware::CPU.arch_32_bit} )-march=/
// 173:     xarch = Regexp.last_match(1).to_s
// 174:     remove flags, /(-Xarch_#{Hardware::CPU.arch_32_bit} )?-march=\S*/
// 175:     remove flags, /( -Xclang \S+)+/
// 176:     remove flags, /-mssse3/
// 177:     remove flags, /-msse4(\.\d)?/
// 178:     append flags, xarch unless xarch.empty?
// 179:     append flags, map.fetch(effective_arch)
// 180:   end
// 181:
// 182:   sig { returns(T::Array[Pathname]) }
// 183:   def homebrew_extra_pkg_config_paths
// 184:     []
// 185:   end
// 186:
// 187:   sig { params(map: T::Hash[Symbol, String]).void }
// 188:   def set_cpu_cflags(map = Hardware::CPU.optimization_flags)
// 189:     set_cpu_flags(CC_FLAG_VARS, map)
// 190:   end
// 191: end
// 192:
// 193: require "extend/os/extend/ENV/std"
