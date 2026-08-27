module env

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/std.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `homebrew_extra_pkg_config_paths` at line 13.
pub fn ruby_std_l13_d1_homebrew_extra_pkg_config_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_extra_pkg_config_paths', ...args)
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 30.
pub fn ruby_std_l30_d2_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment', ...args)
}

// Ruby method `remove_macosxsdk(version = nil)` at line 50.
pub fn ruby_std_l50_d3_remove_macosxsdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remove_macosxsdk', ...args)
}

// Ruby method `macosxsdk(version = nil, formula: nil, testing_formula: false)` at line 74.
pub fn ruby_std_l74_d4_macosxsdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macosxsdk', ...args)
}

// Ruby method `libxml2` at line 108.
pub fn ruby_std_l108_d5_libxml2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('libxml2', ...args)
}

// Ruby method `no_weak_imports` at line 115.
pub fn ruby_std_l115_d6_no_weak_imports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_weak_imports', ...args)
}

// Ruby method `no_fixup_chains` at line 122.
pub fn ruby_std_l122_d7_no_fixup_chains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_fixup_chains', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Stdenv
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { SharedEnvExtension }
// 10:       requires_ancestor { ::Stdenv }
// 11:
// 12:       sig { returns(T::Array[::Pathname]) }
// 13:       def homebrew_extra_pkg_config_paths
// 14:         %W[
// 15:           #{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.version}
// 16:         ].map { |p| ::Pathname.new(p) }
// 17:       end
// 18:       private :homebrew_extra_pkg_config_paths
// 19:
// 20:       sig {
// 21:         params(
// 22:           formula:         T.nilable(Formula),
// 23:           cc:              T.nilable(String),
// 24:           build_bottle:    T.nilable(T::Boolean),
// 25:           bottle_arch:     T.nilable(String),
// 26:           testing_formula: T::Boolean,
// 27:           debug_symbols:   T.nilable(T::Boolean),
// 28:         ).void
// 29:       }
// 30:       def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,
// 31:                                   testing_formula: false, debug_symbols: false)
// 32:         super
// 33:
// 34:         append "LDFLAGS", "-Wl,-headerpad_max_install_names"
// 35:
// 36:         # `sed` is strict and errors out when it encounters files with mixed character sets.
// 37:         delete("LC_ALL")
// 38:         self["LC_CTYPE"] = "C"
// 39:
// 40:         # Add `lib` and `include` etc. from the current `macosxsdk` to compiler flags:
// 41:         macosxsdk(formula:, testing_formula:)
// 42:
// 43:         return unless MacOS::Xcode.without_clt?
// 44:
// 45:         append_path "PATH", "#{MacOS::Xcode.prefix}/usr/bin"
// 46:         append_path "PATH", "#{MacOS::Xcode.toolchain_path}/usr/bin"
// 47:       end
// 48:
// 49:       sig { params(version: T.nilable(MacOSVersion)).void }
// 50:       def remove_macosxsdk(version = nil)
// 51:         # Clear all `lib` and `include` dirs from `CFLAGS`, `CPPFLAGS`, `LDFLAGS` that were
// 52:         # previously added by `macosxsdk`.
// 53:         remove_from_cflags(/ ?-mmacosx-version-min=\d+\.\d+/)
// 54:         delete("CPATH")
// 55:         remove "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
// 56:
// 57:         sdk = self["SDKROOT"] || MacOS.sdk_path(version)
// 58:         return unless sdk
// 59:
// 60:         delete("SDKROOT")
// 61:         remove_from_cflags "-isysroot#{sdk}"
// 62:         remove "CPPFLAGS", "-isysroot#{sdk}"
// 63:         remove "LDFLAGS", "-isysroot#{sdk}"
// 64:         if HOMEBREW_PREFIX.to_s == "/usr/local"
// 65:           delete("CMAKE_PREFIX_PATH")
// 66:         else
// 67:           # It was set in `setup_build_environment`, so we have to restore it here.
// 68:           self["CMAKE_PREFIX_PATH"] = HOMEBREW_PREFIX.to_s
// 69:         end
// 70:         remove "CMAKE_FRAMEWORK_PATH", "#{sdk}/System/Library/Frameworks"
// 71:       end
// 72:
// 73:       sig { params(version: T.nilable(MacOSVersion), formula: T.nilable(Formula), testing_formula: T::Boolean).void }
// 74:       def macosxsdk(version = nil, formula: nil, testing_formula: false)
// 75:         # Sets all needed `lib` and `include` dirs to `CFLAGS`, `CPPFLAGS`, `LDFLAGS`.
// 76:         remove_macosxsdk
// 77:         min_version = version || MacOS.version
// 78:         append_to_cflags("-mmacosx-version-min=#{min_version}")
// 79:         self["CPATH"] = "#{HOMEBREW_PREFIX}/include"
// 80:         prepend "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
// 81:
// 82:         sdk = if formula
// 83:           MacOS.sdk_for_formula(formula, version, check_only_runtime_requirements: testing_formula)
// 84:         else
// 85:           MacOS.sdk(version)
// 86:         end
// 87:
// 88:         Homebrew::Diagnostic.checks(:fatal_setup_build_environment_checks)
// 89:         sdk = T.must(sdk).path
// 90:
// 91:         # Extra setup to support Xcode 4.3+ without CLT.
// 92:         self["SDKROOT"] = sdk.to_s
// 93:         # Tell clang/gcc where system include's are:
// 94:         append_path "CPATH", "#{sdk}/usr/include"
// 95:         # The -isysroot is needed, too, because of the Frameworks
// 96:         append_to_cflags "-isysroot#{sdk}"
// 97:         append "CPPFLAGS", "-isysroot#{sdk}"
// 98:         # And the linker needs to find sdk/usr/lib
// 99:         append "LDFLAGS", "-isysroot#{sdk}"
// 100:         # Needed to build cmake itself and perhaps some cmake projects:
// 101:         append_path "CMAKE_PREFIX_PATH", "#{sdk}/usr"
// 102:         append_path "CMAKE_FRAMEWORK_PATH", "#{sdk}/System/Library/Frameworks"
// 103:       end
// 104:
// 105:       # Some configure scripts won't find libxml2 without help.
// 106:       # This is a no-op with macOS SDK 10.15.4 and later.
// 107:       sig { void }
// 108:       def libxml2
// 109:         sdk = self["SDKROOT"] || MacOS.sdk_path
// 110:         # Use the includes from the sdk
// 111:         append "CPPFLAGS", "-I#{sdk}/usr/include/libxml2" unless Pathname("#{sdk}/usr/include/libxml").directory?
// 112:       end
// 113:
// 114:       sig { void }
// 115:       def no_weak_imports
// 116:         # This has little-to-no usage and doesn't make sense to have a special function for.
// 117:         odeprecated "ENV.no_weak_imports"
// 118:         append "LDFLAGS", "-Wl,-no_weak_imports" if no_weak_imports_support?
// 119:       end
// 120:
// 121:       sig { void }
// 122:       def no_fixup_chains
// 123:         # This has little-to-no usage and behaved inconsistently with the superenv equivalent.
// 124:         odeprecated "ENV.no_fixup_chains"
// 125:         append "LDFLAGS", "-Wl,-no_fixup_chains" if no_fixup_chains_support?
// 126:       end
// 127:     end
// 128:   end
// 129: end
// 130:
// 131: Stdenv.prepend(OS::Mac::Stdenv)
