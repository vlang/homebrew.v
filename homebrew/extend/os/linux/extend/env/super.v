module env

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/super.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `shims_path` at line 15.
pub fn ruby_super_l15_d1_shims_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shims_path', ...args)
}

// Ruby method `bin` at line 20.
pub fn ruby_super_l20_d2_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bin', ...args)
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 35.
pub fn ruby_super_l35_d3_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `homebrew_extra_paths` at line 60.
pub fn ruby_super_l60_d4_homebrew_extra_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_paths', ...args)
}

// Ruby method `homebrew_extra_isystem_paths` at line 72.
pub fn ruby_super_l72_d5_homebrew_extra_isystem_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_isystem_paths', ...args)
}

// Ruby method `determine_rpath_paths(formula)` at line 84.
pub fn ruby_super_l84_d6_determine_rpath_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_rpath_paths', ...args)
}

// Ruby method `determine_dynamic_linker_path` at line 94.
pub fn ruby_super_l94_d7_determine_dynamic_linker_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_dynamic_linker_path', ...args)
}

// Ruby define_method `define_method("gcc-#{n}") do` at line 102.
pub fn ruby_super_l102_d8_gcc_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gcc-#{n}', ...args)
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
