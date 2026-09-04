module env

import ruby

pub struct MacStdenvConfig {
pub:
	homebrew_library  string
	homebrew_prefix   string
	macos_version     string
	sdk_path          string
	xcode_without_clt bool
	xcode_prefix      string
	xcode_toolchain   string
	preferred_perl    string
}

fn mac_env_append(environment map[string]string, key string, value string) map[string]string {
	mut result := environment.clone()
	result[key] = if result[key] == '' { value } else { '${result[key]} ${value}' }
	return result
}

fn mac_env_prepend(environment map[string]string, key string, value string) map[string]string {
	mut result := environment.clone()
	result[key] = if result[key] == '' { value } else { '${value} ${result[key]}' }
	return result
}

fn mac_env_append_path(environment map[string]string, key string, value string) map[string]string {
	mut result := environment.clone()
	result[key] = if result[key] == '' { value } else { '${result[key]}:${value}' }
	return result
}

fn mac_env_remove_token(environment map[string]string, key string, token string) map[string]string {
	mut result := environment.clone()
	result[key] = result[key].fields().filter(it != token).join(' ')
	return result
}

pub fn mac_stdenv_extra_pkg_config_paths(library string, version string) []string {
	return ['${library}/Homebrew/os/mac/pkgconfig/${version}']
}

pub fn mac_stdenv_remove_macosxsdk(environment map[string]string, prefix string,
	sdk_fallback string) map[string]string {
	mut result := environment.clone()
	result['CFLAGS'] = result['CFLAGS'].fields().filter(!it.starts_with('-mmacosx-version-min=')).join(' ')
	result.delete('CPATH')
	result = mac_env_remove_token(result, 'LDFLAGS', '-L${prefix}/lib')
	sdk := if result['SDKROOT'] != '' { result['SDKROOT'] } else { sdk_fallback }
	if sdk == '' {
		return result
	}
	result.delete('SDKROOT')
	for key in ['CFLAGS', 'CPPFLAGS', 'LDFLAGS'] {
		result = mac_env_remove_token(result, key, '-isysroot${sdk}')
	}
	if prefix == '/usr/local' {
		result.delete('CMAKE_PREFIX_PATH')
	} else {
		result['CMAKE_PREFIX_PATH'] = prefix
	}
	result['CMAKE_FRAMEWORK_PATH'] = result['CMAKE_FRAMEWORK_PATH'].split(':').filter(it != '${sdk}/System/Library/Frameworks').join(':')
	return result
}

pub fn mac_stdenv_macosxsdk(environment map[string]string, prefix string, version string,
	sdk string) map[string]string {
	mut result := mac_stdenv_remove_macosxsdk(environment, prefix, sdk)
	result = mac_env_append(result, 'CFLAGS', '-mmacosx-version-min=${version}')
	result['CPATH'] = '${prefix}/include'
	result = mac_env_prepend(result, 'LDFLAGS', '-L${prefix}/lib')
	result['SDKROOT'] = sdk
	result = mac_env_append_path(result, 'CPATH', '${sdk}/usr/include')
	result = mac_env_append(result, 'CFLAGS', '-isysroot${sdk}')
	result = mac_env_append(result, 'CPPFLAGS', '-isysroot${sdk}')
	result = mac_env_append(result, 'LDFLAGS', '-isysroot${sdk}')
	result = mac_env_append_path(result, 'CMAKE_PREFIX_PATH', '${sdk}/usr')
	result = mac_env_append_path(result, 'CMAKE_FRAMEWORK_PATH', '${sdk}/System/Library/Frameworks')
	return result
}

pub fn mac_stdenv_setup(environment map[string]string, config MacStdenvConfig) map[string]string {
	mut result := mac_setup_shared_build_environment(environment, config.preferred_perl)
	result = mac_env_append(result, 'LDFLAGS', '-Wl,-headerpad_max_install_names')
	result.delete('LC_ALL')
	result['LC_CTYPE'] = 'C'
	result = mac_stdenv_macosxsdk(result, config.homebrew_prefix, config.macos_version, config.sdk_path)
	if config.xcode_without_clt {
		result = mac_env_append_path(result, 'PATH', '${config.xcode_prefix}/usr/bin')
		result = mac_env_append_path(result, 'PATH', '${config.xcode_toolchain}/usr/bin')
	}
	return result
}

pub fn mac_stdenv_libxml2(environment map[string]string, sdk string,
	libxml_directory_exists bool) map[string]string {
	if libxml_directory_exists {
		return environment.clone()
	}
	return mac_env_append(environment, 'CPPFLAGS', '-I${sdk}/usr/include/libxml2')
}

pub fn mac_stdenv_no_weak_imports(environment map[string]string,
	supported bool) map[string]string {
	if !supported {
		return environment.clone()
	}
	return mac_env_append(environment, 'LDFLAGS', '-Wl,-no_weak_imports')
}

pub fn mac_stdenv_no_fixup_chains(environment map[string]string,
	supported bool) map[string]string {
	if !supported {
		return environment.clone()
	}
	return mac_env_append(environment, 'LDFLAGS', '-Wl,-no_fixup_chains')
}

fn mac_std_environment(args []ruby.Value) map[string]string {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return map[string]string{}
	}
	return mac_string_map_from_value(args[0]) or { map[string]string{} }
}

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/std.rb`.
