module env

import brew_runtime

// Translated from Homebrew/brew `extend/ENV/std.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil, testing_formula: false,` at line 23.
pub fn ruby_std_l23_d1_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `determine_pkg_config_libdir` at line 74.
pub fn ruby_std_l74_d2_determine_pkg_config_libdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_pkg_config_libdir', ...args)
}

// Ruby method `deparallelize(&block)` at line 87.
pub fn ruby_std_l87_d3_deparallelize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deparallelize', ...args)
}

// Ruby define_method `define_method opt do` at line 102.
pub fn ruby_std_l102_d4_opt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opt', ...args)
}

// Ruby method `determine_cc` at line 109.
pub fn ruby_std_l109_d5_determine_cc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_cc', ...args)
}

// Ruby method `determine_cxx` at line 122.
pub fn ruby_std_l122_d6_determine_cxx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_cxx', ...args)
}

// Ruby define_method `define_method(:"gcc-#{n}") do` at line 129.
pub fn ruby_std_l129_d7_gcc_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gcc-#{n}', ...args)
}

// Ruby method `clang` at line 136.
pub fn ruby_std_l136_d8_clang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clang', ...args)
}

// Ruby method `cxx11` at line 143.
pub fn ruby_std_l143_d9_cxx11(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cxx11', ...args)
}

// Ruby method `libcxx` at line 149.
pub fn ruby_std_l149_d10_libcxx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('libcxx', ...args)
}

// Ruby method `replace_in_cflags(before, after)` at line 156.
pub fn ruby_std_l156_d11_replace_in_cflags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_in_cflags', ...args)
}

// Ruby method `define_cflags(val)` at line 164.
pub fn ruby_std_l164_d12_define_cflags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_cflags', ...args)
}

// Ruby method `set_cpu_flags(flags, map = Hardware::CPU.optimization_flags)` at line 171.
pub fn ruby_std_l171_d13_set_cpu_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_cpu_flags', ...args)
}

// Ruby method `homebrew_extra_pkg_config_paths` at line 183.
pub fn ruby_std_l183_d14_homebrew_extra_pkg_config_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_pkg_config_paths', ...args)
}

// Ruby method `set_cpu_cflags(map = Hardware::CPU.optimization_flags)` at line 188.
pub fn ruby_std_l188_d15_set_cpu_cflags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_cpu_cflags', ...args)
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
