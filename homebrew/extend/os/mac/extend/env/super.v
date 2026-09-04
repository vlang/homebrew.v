module env

import ruby
import homebrew.extend.env as base_env

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/super.rb`.
pub type MacSuperenvDiagnosticCheck = fn () !

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
	return ruby.join_path(homebrew_shims_path, 'mac/super/bin')
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
		ruby.join_path(homebrew_library, 'Homebrew/os/mac/pkgconfig/${macos_version}')]
}

pub fn mac_superenv_libxml2_include_needed(dependencies []base_env.SuperenvDependency,
	sdkroot string, directory base_env.SuperenvPathPredicate) bool {
	if dependencies.any(it.name == 'libxml2') {
		return false
	}
	return !directory(ruby.join_path(sdkroot, 'usr/include/libxml'))
}

pub fn mac_superenv_extra_isystem_paths(sdkroot string, libxml2_needed bool,
	xcode_without_clt bool) []string {
	mut paths := []string{}
	if libxml2_needed {
		paths << ruby.join_path(sdkroot, 'usr/include/libxml2')
	}
	if xcode_without_clt {
		paths << ruby.join_path(sdkroot, 'usr/include/apache2')
	}
	paths << ruby.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers')
	return paths
}

pub fn mac_superenv_extra_library_paths(sdkroot string, compiler string,
	homebrew_prefix string) []string {
	mut paths := []string{}
	if compiler.trim_string_left(':') == 'llvm_clang' {
		paths << ruby.join_path(sdkroot, 'usr/lib')
		paths << ruby.join_path(homebrew_prefix, 'opt/llvm/lib')
	}
	paths << ruby.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries')
	return paths
}

pub fn mac_superenv_extra_cmake_include_paths(sdkroot string, libxml2_needed bool,
	xcode_without_clt bool) []string {
	return mac_superenv_extra_isystem_paths(sdkroot, libxml2_needed, xcode_without_clt)
}

pub fn mac_superenv_extra_cmake_library_paths(sdkroot string) []string {
	return [
		ruby.join_path(sdkroot, 'System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries'),
	]
}

pub fn mac_superenv_extra_cmake_framework_paths(sdkroot string,
	xcode_without_clt bool) []string {
	if !xcode_without_clt {
		return []
	}
	return [ruby.join_path(sdkroot, 'System/Library/Frameworks')]
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
