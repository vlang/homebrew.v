module env

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/super.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `shims_path` at line 16.
pub fn ruby_super_l16_d1_shims_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shims_path', ...args)
}

// Ruby method `bin` at line 21.
pub fn ruby_super_l21_d2_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bin', ...args)
}

// Ruby method `homebrew_extra_pkg_config_paths` at line 29.
pub fn ruby_super_l29_d3_homebrew_extra_pkg_config_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_pkg_config_paths', ...args)
}

// Ruby method `libxml2_include_needed?` at line 37.
pub fn ruby_super_l37_d4_libxml2_include_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('libxml2_include_needed?', ...args)
}

// Ruby method `homebrew_extra_isystem_paths` at line 45.
pub fn ruby_super_l45_d5_homebrew_extra_isystem_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_isystem_paths', ...args)
}

// Ruby method `homebrew_extra_library_paths` at line 54.
pub fn ruby_super_l54_d6_homebrew_extra_library_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_library_paths', ...args)
}

// Ruby method `homebrew_extra_cmake_include_paths` at line 65.
pub fn ruby_super_l65_d7_homebrew_extra_cmake_include_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_cmake_include_paths', ...args)
}

// Ruby method `homebrew_extra_cmake_library_paths` at line 74.
pub fn ruby_super_l74_d8_homebrew_extra_cmake_library_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_cmake_library_paths', ...args)
}

// Ruby method `homebrew_extra_cmake_frameworks_paths` at line 81.
pub fn ruby_super_l81_d9_homebrew_extra_cmake_frameworks_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_cmake_frameworks_paths', ...args)
}

// Ruby method `determine_cccfg` at line 88.
pub fn ruby_super_l88_d10_determine_cccfg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('determine_cccfg', ...args)
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 111.
pub fn ruby_super_l111_d11_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `no_weak_imports` at line 155.
pub fn ruby_super_l155_d12_no_weak_imports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_weak_imports', ...args)
}

// Ruby method `no_fixup_chains` at line 164.
pub fn ruby_super_l164_d13_no_fixup_chains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_fixup_chains', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Superenv
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { SharedEnvExtension }
// 12:       requires_ancestor { ::Superenv }
// 13:
// 14:       module ClassMethods
// 15:         sig { returns(::Pathname) }
// 16:         def shims_path
// 17:           HOMEBREW_SHIMS_PATH/"mac/super/bin"
// 18:         end
// 19:
// 20:         sig { returns(T.nilable(::Pathname)) }
// 21:         def bin
// 22:           return unless ::DevelopmentTools.installed?
// 23:
// 24:           shims_path.realpath
// 25:         end
// 26:       end
// 27:
// 28:       sig { returns(T::Array[::Pathname]) }
// 29:       def homebrew_extra_pkg_config_paths
// 30:         %W[
// 31:           /usr/lib/pkgconfig
// 32:           #{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.version}
// 33:         ].map { |p| ::Pathname.new(p) }
// 34:       end
// 35:
// 36:       sig { returns(T::Boolean) }
// 37:       def libxml2_include_needed?
// 38:         return false if deps.any? { |d| d.name == "libxml2" }
// 39:         return false if ::Pathname.new("#{self["HOMEBREW_SDKROOT"]}/usr/include/libxml").directory?
// 40:
// 41:         true
// 42:       end
// 43:
// 44:       sig { returns(T::Array[::Pathname]) }
// 45:       def homebrew_extra_isystem_paths
// 46:         paths = []
// 47:         paths << "#{self["HOMEBREW_SDKROOT"]}/usr/include/libxml2" if libxml2_include_needed?
// 48:         paths << "#{self["HOMEBREW_SDKROOT"]}/usr/include/apache2" if MacOS::Xcode.without_clt?
// 49:         paths << "#{self["HOMEBREW_SDKROOT"]}/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers"
// 50:         paths.map { |p| ::Pathname.new(p) }
// 51:       end
// 52:
// 53:       sig { returns(T::Array[::Pathname]) }
// 54:       def homebrew_extra_library_paths
// 55:         paths = []
// 56:         if compiler == :llvm_clang
// 57:           paths << "#{self["HOMEBREW_SDKROOT"]}/usr/lib"
// 58:           paths << Utils::Path.formula_opt_lib("llvm")
// 59:         end
// 60:         paths << "#{self["HOMEBREW_SDKROOT"]}/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries"
// 61:         paths.map { |p| ::Pathname.new(p) }
// 62:       end
// 63:
// 64:       sig { returns(T::Array[::Pathname]) }
// 65:       def homebrew_extra_cmake_include_paths
// 66:         paths = []
// 67:         paths << "#{self["HOMEBREW_SDKROOT"]}/usr/include/libxml2" if libxml2_include_needed?
// 68:         paths << "#{self["HOMEBREW_SDKROOT"]}/usr/include/apache2" if MacOS::Xcode.without_clt?
// 69:         paths << "#{self["HOMEBREW_SDKROOT"]}/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers"
// 70:         paths.map { |p| ::Pathname.new(p) }
// 71:       end
// 72:
// 73:       sig { returns(T::Array[::Pathname]) }
// 74:       def homebrew_extra_cmake_library_paths
// 75:         %W[
// 76:           #{self["HOMEBREW_SDKROOT"]}/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries
// 77:         ].map { |p| ::Pathname.new(p) }
// 78:       end
// 79:
// 80:       sig { returns(T::Array[::Pathname]) }
// 81:       def homebrew_extra_cmake_frameworks_paths
// 82:         paths = []
// 83:         paths << "#{self["HOMEBREW_SDKROOT"]}/System/Library/Frameworks" if MacOS::Xcode.without_clt?
// 84:         paths.map { |p| ::Pathname.new(p) }
// 85:       end
// 86:
// 87:       sig { returns(String) }
// 88:       def determine_cccfg
// 89:         s = +""
// 90:         # Pass `-no_fixup_chains` whenever the linker is invoked with `-undefined dynamic_lookup`.
// 91:         # See: https://github.com/python/cpython/issues/97524
// 92:         #      https://github.com/pybind/pybind11/pull/4301
// 93:         s << "f" if no_fixup_chains_support?
// 94:         # Pass `-ld_classic` whenever the linker is invoked with `-dead_strip_dylibs`
// 95:         # on `ld` versions that don't properly handle that option.
// 96:         s << "c" if ::DevelopmentTools.ld64_version.between?("1015.7", "1022.1")
// 97:         s.freeze
// 98:       end
// 99:
// 100:       # @private
// 101:       sig {
// 102:         params(
// 103:           formula:         T.nilable(Formula),
// 104:           cc:              T.nilable(String),
// 105:           build_bottle:    T.nilable(T::Boolean),
// 106:           bottle_arch:     T.nilable(String),
// 107:           testing_formula: T::Boolean,
// 108:           debug_symbols:   T.nilable(T::Boolean),
// 109:         ).void
// 110:       }
// 111:       def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,
// 112:                                   testing_formula: false, debug_symbols: false)
// 113:         sdk = formula ? MacOS.sdk_for_formula(formula) : MacOS.sdk
// 114:         is_xcode_sdk = sdk&.source == :xcode
// 115:
// 116:         Homebrew::Diagnostic.checks(:fatal_setup_build_environment_checks)
// 117:         self["HOMEBREW_SDKROOT"] = sdk.path.to_s if sdk
// 118:
// 119:         self["HOMEBREW_DEVELOPER_DIR"] = if is_xcode_sdk
// 120:           MacOS::Xcode.prefix.to_s
// 121:         else
// 122:           MacOS::CLT::PKG_PATH
// 123:         end
// 124:
// 125:         # This is a workaround for the missing `m4` in Xcode CLT 15.3, which was
// 126:         # reported in FB13679972. Apple has fixed this in Xcode CLT 16.0.
// 127:         # See https://github.com/Homebrew/homebrew-core/issues/165388
// 128:         if deps.none? { |d| d.name == "m4" } &&
// 129:            MacOS.active_developer_dir == MacOS::CLT::PKG_PATH &&
// 130:            !File.exist?("#{MacOS::CLT::PKG_PATH}/usr/bin/m4") &&
// 131:            (gm4 = ::DevelopmentTools.locate("gm4").to_s).present?
// 132:           self["M4"] = gm4
// 133:         end
// 134:
// 135:         super
// 136:
// 137:         # On macOS Sonoma and later, iconv() is generally present and working,
// 138:         # but has a minor regression that defeats the test implemented in gettext's
// 139:         # configure script (and used by many gettext dependents).
// 140:         # All reported bugs were fixed in Sonoma patch releases, though some new bugs
// 141:         # were revealed since then (and unfortunately very rarely actually reported to Apple).
// 142:         # Using brewed libiconv is a disruptive option that requires rebuilding most dependents,
// 143:         # so is never accepted apart from a select few leaf formulae that are worse impacted.
// 144:         ENV["am_cv_func_iconv_works"] = "yes" if MacOS.version >= "14"
// 145:
// 146:         # The tools in /usr/bin proxy to the active developer directory.
// 147:         # This means we can use them for any combination of CLT and Xcode.
// 148:         self["HOMEBREW_PREFER_CLT_PROXIES"] = "1"
// 149:
// 150:         # Deterministic timestamping.
// 151:         self["ZERO_AR_DATE"] = "1"
// 152:       end
// 153:
// 154:       sig { void }
// 155:       def no_weak_imports
// 156:         # This has little-to-no usage and doesn't make sense to have a special function for.
// 157:         # When removing this function, also cleanup related usage in the `cc` shim
// 158:         # and remove `no_weak_imports_support?`.
// 159:         odeprecated "ENV.no_weak_imports"
// 160:         append_to_cccfg "w" if no_weak_imports_support?
// 161:       end
// 162:
// 163:       sig { void }
// 164:       def no_fixup_chains
// 165:         # This function has been no-op for quite some time as it's set by default.
// 166:         # Unlike above, do not touch the `cc` shim or the support method when removing this.
// 167:         odeprecated "ENV.no_fixup_chains"
// 168:         append_to_cccfg "f" if no_fixup_chains_support?
// 169:       end
// 170:     end
// 171:   end
// 172: end
// 173:
// 174: Superenv.singleton_class.prepend(OS::Mac::Superenv::ClassMethods)
// 175: Superenv.prepend(OS::Mac::Superenv)
