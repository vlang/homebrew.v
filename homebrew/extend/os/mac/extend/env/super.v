module env

import brew_runtime
import homebrew.extend.env as base_env

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/super.rb`.
pub type MacSuperenvDiagnosticCheck = fn() !

pub struct MacSuperenvBuildContext {
pub:
	sdk_path             ?string
	sdk_source_xcode     bool
	xcode_prefix         string
	clt_pkg_path         string
	active_developer_dir string
	clt_m4_exists        bool
	gm4_path             string
	macos_version        string
	homebrew_library     string
	xcode_without_clt    bool
	diagnostic_check     ?MacSuperenvDiagnosticCheck
}

pub struct MacSuperenvDeprecationResult {
pub:
	message string
	cccfg   string
}

pub fn mac_superenv_shims_path(homebrew_shims_path string) string {
	return brew_runtime.join_path(homebrew_shims_path, 'mac/super/bin')
}

pub fn mac_superenv_bin(development_tools_installed bool, real_shims_path string) ?string {
	if !development_tools_installed {
		return none
	}
	return real_shims_path
}

pub fn mac_superenv_extra_pkg_config_paths(homebrew_library string,
	macos_version string) []string {
	return ['/usr/lib/pkgconfig',
		brew_runtime.join_path(homebrew_library, 'Homebrew/os/mac/pkgconfig/${macos_version}')]
}

pub fn mac_superenv_libxml2_include_needed(dependencies []base_env.SuperenvDependency,
	sdkroot string, directory base_env.SuperenvPathPredicate) bool {
	if dependencies.any(it.name == 'libxml2') {
		return false
	}
	return !directory(brew_runtime.join_path(sdkroot, 'usr/include/libxml'))
}

pub fn mac_superenv_extra_isystem_paths(sdkroot string, libxml2_needed bool,
	xcode_without_clt bool) []string {
	mut paths := []string{}
	if libxml2_needed {
		paths << brew_runtime.join_path(sdkroot, 'usr/include/libxml2')
	}
	if xcode_without_clt {
		paths << brew_runtime.join_path(sdkroot, 'usr/include/apache2')
	}
	paths << brew_runtime.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers')
	return paths
}

pub fn mac_superenv_extra_library_paths(sdkroot string, compiler string,
	homebrew_prefix string) []string {
	mut paths := []string{}
	if compiler.trim_string_left(':') == 'llvm_clang' {
		paths << brew_runtime.join_path(sdkroot, 'usr/lib')
		paths << brew_runtime.join_path(homebrew_prefix, 'opt/llvm/lib')
	}
	paths << brew_runtime.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries')
	return paths
}

pub fn mac_superenv_extra_cmake_include_paths(sdkroot string, libxml2_needed bool,
	xcode_without_clt bool) []string {
	return mac_superenv_extra_isystem_paths(sdkroot, libxml2_needed, xcode_without_clt)
}

pub fn mac_superenv_extra_cmake_library_paths(sdkroot string) []string {
	return [
		brew_runtime.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries'),
	]
}

pub fn mac_superenv_extra_cmake_framework_paths(sdkroot string,
	xcode_without_clt bool) []string {
	if !xcode_without_clt {
		return []
	}
	return [brew_runtime.join_path(sdkroot, 'System/Library/Frameworks')]
}

fn mac_superenv_version_parts(version string) []int {
	return version.split('.').map(it.int())
}

fn mac_superenv_compare_versions(left string, right string) int {
	left_parts := mac_superenv_version_parts(left)
	right_parts := mac_superenv_version_parts(right)
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

pub fn mac_superenv_determine_cccfg(no_fixup_chains_support bool,
	ld64_version string) string {
	mut value := ''
	if no_fixup_chains_support {
		value += 'f'
	}
	if mac_superenv_compare_versions(ld64_version, '1015.7') >= 0 && mac_superenv_compare_versions(ld64_version, '1022.1') <= 0 {
		value += 'c'
	}
	return value
}

pub fn mac_superenv_setup_build_environment(mut state base_env.SuperenvState,
	options base_env.SuperenvBuildOptions, context MacSuperenvBuildContext,
	exists base_env.SuperenvPathPredicate) ! {
	if check := context.diagnostic_check {
		check()!
	}
	if sdk_path := context.sdk_path {
		state.set_value('HOMEBREW_SDKROOT', sdk_path)
	}
	state.set_value('HOMEBREW_DEVELOPER_DIR', if context.sdk_source_xcode {
		context.xcode_prefix
	} else {
		context.clt_pkg_path
	})
	if !state.dependencies().any(it.name == 'm4') && context.active_developer_dir == context.clt_pkg_path && !context.clt_m4_exists && context.gm4_path != '' {
		state.set_value('M4', context.gm4_path)
	}
	state.setup(options, exists)
	sdkroot := state.value('HOMEBREW_SDKROOT') or { '' }
	libxml_needed := mac_superenv_libxml2_include_needed(state.dependencies(), sdkroot, exists)
	mut pkg_config_paths := []string{}
	if current := state.value('PKG_CONFIG_PATH') {
		pkg_config_paths << current.split(':')
	}
	pkg_config_paths << mac_superenv_extra_pkg_config_paths(context.homebrew_library, context.macos_version).filter(exists(it))
	if pkg_config_paths.len > 0 {
		state.set_value('PKG_CONFIG_PATH', pkg_config_paths.join(':'))
	}
	mut isystem_paths := []string{}
	if current := state.value('HOMEBREW_ISYSTEM_PATHS') {
		isystem_paths << current.split(':')
	}
	isystem_paths << mac_superenv_extra_isystem_paths(sdkroot, libxml_needed, context.xcode_without_clt).filter(exists(it))
	if isystem_paths.len > 0 {
		state.set_value('HOMEBREW_ISYSTEM_PATHS', isystem_paths.join(':'))
	}
	mut library_paths := []string{}
	if current := state.value('HOMEBREW_LIBRARY_PATHS') {
		library_paths << current.split(':')
	}
	library_paths << mac_superenv_extra_library_paths(sdkroot, state.compiler_name(), state.config.prefix).filter(exists(it))
	if library_paths.len > 0 {
		state.set_value('HOMEBREW_LIBRARY_PATHS', library_paths.join(':'))
	}
	if mac_superenv_compare_versions(context.macos_version, '14') >= 0 {
		state.set_value('am_cv_func_iconv_works', 'yes')
	}
	state.set_value('HOMEBREW_PREFER_CLT_PROXIES', '1')
	state.set_value('ZERO_AR_DATE', '1')
}

pub fn mac_superenv_no_weak_imports(mut state base_env.SuperenvState,
	supported bool) MacSuperenvDeprecationResult {
	if supported {
		state.append_cccfg('w')
	}
	return MacSuperenvDeprecationResult{
		message: 'ENV.no_weak_imports is deprecated'
		cccfg: state.value('HOMEBREW_CCCFG') or { '' }
	}
}

pub fn mac_superenv_no_fixup_chains(mut state base_env.SuperenvState,
	supported bool) MacSuperenvDeprecationResult {
	if supported {
		state.append_cccfg('f')
	}
	return MacSuperenvDeprecationResult{
		message: 'ENV.no_fixup_chains is deprecated'
		cccfg: state.value('HOMEBREW_CCCFG') or { '' }
	}
}

// Ruby method `shims_path` at line 16.
pub fn ruby_super_l16_d1_shims_path(homebrew_shims_path string) string {
	return mac_superenv_shims_path(homebrew_shims_path)
}

// Ruby method `bin` at line 21.
pub fn ruby_super_l21_d2_bin(development_tools_installed bool,
	real_shims_path string) ?string {
	return mac_superenv_bin(development_tools_installed, real_shims_path)
}

// Ruby method `homebrew_extra_pkg_config_paths` at line 29.
pub fn ruby_super_l29_d3_homebrew_extra_pkg_config_paths(homebrew_library string,
	macos_version string) []string {
	return mac_superenv_extra_pkg_config_paths(homebrew_library, macos_version)
}

// Ruby method `libxml2_include_needed?` at line 37.
pub fn ruby_super_l37_d4_libxml2_include_needed(dependencies []base_env.SuperenvDependency,
	sdkroot string, directory base_env.SuperenvPathPredicate) bool {
	return mac_superenv_libxml2_include_needed(dependencies, sdkroot, directory)
}

// Ruby method `homebrew_extra_isystem_paths` at line 45.
pub fn ruby_super_l45_d5_homebrew_extra_isystem_paths(sdkroot string, libxml2_needed bool,
	xcode_without_clt bool) []string {
	return mac_superenv_extra_isystem_paths(sdkroot, libxml2_needed, xcode_without_clt)
}

// Ruby method `homebrew_extra_library_paths` at line 54.
pub fn ruby_super_l54_d6_homebrew_extra_library_paths(sdkroot string, compiler string,
	homebrew_prefix string) []string {
	return mac_superenv_extra_library_paths(sdkroot, compiler, homebrew_prefix)
}

// Ruby method `homebrew_extra_cmake_include_paths` at line 65.
pub fn ruby_super_l65_d7_homebrew_extra_cmake_include_paths(sdkroot string,
	libxml2_needed bool, xcode_without_clt bool) []string {
	return mac_superenv_extra_cmake_include_paths(sdkroot, libxml2_needed, xcode_without_clt)
}

// Ruby method `homebrew_extra_cmake_library_paths` at line 74.
pub fn ruby_super_l74_d8_homebrew_extra_cmake_library_paths(sdkroot string) []string {
	return mac_superenv_extra_cmake_library_paths(sdkroot)
}

// Ruby method `homebrew_extra_cmake_frameworks_paths` at line 81.
pub fn ruby_super_l81_d9_homebrew_extra_cmake_frameworks_paths(sdkroot string,
	xcode_without_clt bool) []string {
	return mac_superenv_extra_cmake_framework_paths(sdkroot, xcode_without_clt)
}

// Ruby method `determine_cccfg` at line 88.
pub fn ruby_super_l88_d10_determine_cccfg(no_fixup_chains_support bool,
	ld64_version string) string {
	return mac_superenv_determine_cccfg(no_fixup_chains_support, ld64_version)
}

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 111.
pub fn ruby_super_l111_d11_setup_build_environment(mut state base_env.SuperenvState,
	options base_env.SuperenvBuildOptions, context MacSuperenvBuildContext,
	exists base_env.SuperenvPathPredicate) ! {
	mac_superenv_setup_build_environment(mut state, options, context, exists)!
}

// Ruby method `no_weak_imports` at line 155.
pub fn ruby_super_l155_d12_no_weak_imports(mut state base_env.SuperenvState,
	supported bool) MacSuperenvDeprecationResult {
	return mac_superenv_no_weak_imports(mut state, supported)
}

// Ruby method `no_fixup_chains` at line 164.
pub fn ruby_super_l164_d13_no_fixup_chains(mut state base_env.SuperenvState,
	supported bool) MacSuperenvDeprecationResult {
	return mac_superenv_no_fixup_chains(mut state, supported)
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
