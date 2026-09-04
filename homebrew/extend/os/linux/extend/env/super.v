module env

import ruby
import homebrew.extend.env as base_env
import os

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/super.rb`.
// The original source is retained below until every stub has a typed V body.

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
	rpaths := linux_superenv_rpath_paths(context.formula_lib, state.config.prefix, base_env.ruby_super_l29_d5_run_time_deps(state), exists)
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

// Ruby method `shims_path` at line 15.
pub fn ruby_super_l15_d1_shims_path(args ...ruby.Value) ruby.Value {
	base := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.object_value('Pathname', linux_superenv_shims_path(base))
}

// Ruby method `bin` at line 20.
pub fn ruby_super_l20_d2_bin(args ...ruby.Value) ruby.Value {
	base := if args.len > 0 { args[0].as_string() } else { '' }
	return if path := linux_superenv_bin(base) {
		ruby.object_value('Pathname', path)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 35.
pub fn ruby_super_l35_d3_setup_build_environment(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'environment is required')
	}
	mut state := linux_superenv_state_from_value(args[0])
	context_value := if args.len > 1 { args[1] } else { ruby.Value{} }
	linux_superenv_setup_build_environment(mut state, base_env.SuperenvBuildOptions{}, LinuxSuperenvContext{
		formula_lib: if context_value.attributes['formula_lib'] != '' {
			context_value.attributes['formula_lib']
		} else {
			none
		}
		arm64: context_value.attributes['arm64'] == 'true'
		gcc_version: context_value.attributes['gcc_version'].int()
	}, os.exists)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `homebrew_extra_paths` at line 60.
pub fn ruby_super_l60_d4_homebrew_extra_paths(args ...ruby.Value) ruby.Value {
	base_paths := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	mut formula_bins := map[string]string{}
	if args.len > 1 && args[1].type_name == 'Hash' {
		for name, value in args[1].map_data {
			formula_bins[name] = value.as_string()
		}
	}
	return ruby.string_array_value(linux_superenv_extra_paths(base_paths, formula_bins, os.is_dir))
}

// Ruby method `homebrew_extra_isystem_paths` at line 72.
pub fn ruby_super_l72_d5_homebrew_extra_isystem_paths(args ...ruby.Value) ruby.Value {
	mut dependencies := []base_env.SuperenvDependency{}
	if args.len > 0 {
		for name in args[0].as_string_array() or { [] } {
			dependencies << base_env.SuperenvDependency{ name: name }
		}
	}
	return ruby.string_array_value(linux_superenv_extra_isystem_paths(dependencies, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, if args.len > 2 { args[2].as_string() } else { '' }))
}

// Ruby method `determine_rpath_paths(formula)` at line 84.
pub fn ruby_super_l84_d6_determine_rpath_paths(args ...ruby.Value) ruby.Value {
	formula_lib := if args.len > 0 && args[0].type_name != 'NilClass' {
		?string(args[0].as_string())
	} else {
		none
	}
	prefix := if args.len > 1 { args[1].as_string() } else { '' }
	mut dependencies := []base_env.SuperenvDependency{}
	if args.len > 2 {
		for path in args[2].as_string_array() or { [] } {
			dependencies << base_env.SuperenvDependency{ opt_prefix: os.dir(path) }
		}
	}
	return ruby.string_value(linux_superenv_rpath_paths(formula_lib, prefix, dependencies, os.is_dir).join(':'))
}

// Ruby method `determine_dynamic_linker_path` at line 94.
pub fn ruby_super_l94_d7_determine_dynamic_linker_path(args ...ruby.Value) ruby.Value {
	prefix := if args.len > 0 { args[0].as_string() } else { '' }
	return if path := linux_superenv_dynamic_linker_path(prefix, os.is_readable) {
		ruby.string_value(path)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby define_method `define_method("gcc-#{n}") do` at line 102.
pub fn ruby_super_l102_d8_gcc_n(mut state base_env.SuperenvState, compiler string) {
	base_env.superenv_use_compiler(mut state, compiler)
	state.set_value('CC', 'gcc')
	state.set_value('OBJC', 'gcc')
	state.set_value('CXX', 'g++')
	state.set_value('OBJCXX', 'g++')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Superenv
// 7:       extend T::Helpers
// 8:       include CompilerConstants
// 9:
// 10:       requires_ancestor { SharedEnvExtension }
// 11:       requires_ancestor { ::Superenv }
// 12:
// 13:       module ClassMethods
// 14:         sig { returns(::Pathname) }
// 15:         def shims_path
// 16:           HOMEBREW_SHIMS_PATH/"linux/super/bin"
// 17:         end
// 18:
// 19:         sig { returns(T.nilable(::Pathname)) }
// 20:         def bin
// 21:           shims_path.realpath
// 22:         end
// 23:       end
// 24:
// 25:       sig {
// 26:         params(
// 27:           formula:         T.nilable(Formula),
// 28:           cc:              T.nilable(String),
// 29:           build_bottle:    T.nilable(T::Boolean),
// 30:           bottle_arch:     T.nilable(String),
// 31:           testing_formula: T::Boolean,
// 32:           debug_symbols:   T.nilable(T::Boolean),
// 33:         ).void
// 34:       }
// 35:       def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,
// 36:                                   testing_formula: false, debug_symbols: false)
// 37:         super
// 38:
// 39:         self["HOMEBREW_OPTIMIZATION_LEVEL"] = "O2"
// 40:         self["HOMEBREW_DYNAMIC_LINKER"] = determine_dynamic_linker_path
// 41:         self["HOMEBREW_RPATH_PATHS"] = determine_rpath_paths(formula).to_s
// 42:         m4_path_deps = ["libtool", "bison"]
// 43:         self["M4"] = "#{HOMEBREW_PREFIX}/opt/m4/bin/m4" if deps.any? { m4_path_deps.include?(it.name) }
// 44:         return unless ::Hardware::CPU.arm64?
// 45:
// 46:         # Build jemalloc-sys rust crate on ARM64/AArch64 with support for page sizes up to 64K.
// 47:         self["JEMALLOC_SYS_WITH_LG_PAGE"] = "16"
// 48:
// 49:         # Workaround patchelf.rb bug causing segfaults and preventing bottling on ARM64/AArch64
// 50:         # https://github.com/Homebrew/homebrew-core/issues/163826
// 51:         self["CGO_ENABLED"] = "0"
// 52:
// 53:         # Pointer authentication and BTI are hardening techniques most distros
// 54:         # use by default on their packages. arm64 Linux we're packaging
// 55:         # everything from scratch so the entire dependency tree can have it.
// 56:         append_to_cccfg "b" if ::DevelopmentTools.gcc_version("gcc") >= 9
// 57:       end
// 58:
// 59:       sig { returns(T::Array[::Pathname]) }
// 60:       def homebrew_extra_paths
// 61:         paths = super
// 62:         paths += %w[binutils make].filter_map do |f|
// 63:           bin = ::Formula[f].opt_bin
// 64:           bin if bin.directory?
// 65:         rescue FormulaUnavailableError
// 66:           nil
// 67:         end
// 68:         paths
// 69:       end
// 70:
// 71:       sig { returns(T::Array[::Pathname]) }
// 72:       def homebrew_extra_isystem_paths
// 73:         paths = []
// 74:         # Add paths for GCC headers when building against versioned glibc because we have to use -nostdinc.
// 75:         if deps.any? { |d| d.name.match?(/^glibc@.+$/) }
// 76:           gcc_include_dir = Utils.safe_popen_read(cc, "--print-file-name=include").chomp
// 77:           gcc_include_fixed_dir = Utils.safe_popen_read(cc, "--print-file-name=include-fixed").chomp
// 78:           paths << gcc_include_dir << gcc_include_fixed_dir
// 79:         end
// 80:         paths.map { |p| ::Pathname.new(p) }
// 81:       end
// 82:
// 83:       sig { params(formula: T.nilable(Formula)).returns(PATH) }
// 84:       def determine_rpath_paths(formula)
// 85:         PATH.new(
// 86:           *formula&.lib,
// 87:           "#{HOMEBREW_PREFIX}/opt/gcc/lib/gcc/current",
// 88:           PATH.new(run_time_deps.map { |dep| dep.opt_lib.to_s }).existing,
// 89:           "#{HOMEBREW_PREFIX}/lib",
// 90:         )
// 91:       end
// 92:
// 93:       sig { returns(T.nilable(String)) }
// 94:       def determine_dynamic_linker_path
// 95:         path = "#{HOMEBREW_PREFIX}/lib/ld.so"
// 96:         return unless File.readable? path
// 97:
// 98:         path
// 99:       end
// 100:
// 101:       GNU_GCC_VERSIONS.each do |n|
// 102:         define_method("gcc-#{n}") do
// 103:           T.bind(self, OS::Linux::Superenv)
// 104:           super()
// 105:           self["CC"] = self["OBJC"] = "gcc"
// 106:           self["CXX"] = self["OBJCXX"] = "g++"
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
// 112:
// 113: Superenv.singleton_class.prepend(OS::Linux::Superenv::ClassMethods)
// 114: Superenv.prepend(OS::Linux::Superenv)
