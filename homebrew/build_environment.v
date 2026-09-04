module homebrew

import ruby

// Translated from Homebrew/brew `build_environment.rb`.
const build_environment_keys = ['CC', 'CXX', 'LD', 'OBJC', 'OBJCXX', 'HOMEBREW_CC', 'CFLAGS',
	'CXXFLAGS', 'CPPFLAGS', 'LDFLAGS', 'SDKROOT', 'MAKEFLAGS', 'CMAKE_PREFIX_PATH',
	'CMAKE_INCLUDE_PATH', 'CMAKE_LIBRARY_PATH', 'CMAKE_FRAMEWORK_PATH', 'MACOSX_DEPLOYMENT_TARGET',
	'PKG_CONFIG_PATH', 'PKG_CONFIG_LIBDIR', 'HOMEBREW_DEBUG', 'HOMEBREW_MAKE_JOBS', 'HOMEBREW_VERBOSE',
	'all_proxy', 'ftp_proxy', 'http_proxy', 'https_proxy', 'no_proxy', 'HOMEBREW_SVN', 'HOMEBREW_GIT',
	'HOMEBREW_SDKROOT', 'MAKE', 'GIT', 'CPP', 'ACLOCAL_PATH', 'PATH', 'CPATH', 'LD_LIBRARY_PATH',
	'LD_RUN_PATH', 'LD_PRELOAD', 'LIBRARY_PATH']

pub struct BuildEnvironment {
pub mut:
	settings []string
}

pub fn new_build_environment(settings ...string) BuildEnvironment {
	mut environment := BuildEnvironment{}
	environment.merge(settings)
	return environment
}

pub fn (mut environment BuildEnvironment) merge(settings []string) BuildEnvironment {
	for raw_setting in settings {
		setting := raw_setting.trim_left(':')
		if setting !in environment.settings {
			environment.settings << setting
		}
	}
	return environment
}

pub fn (mut environment BuildEnvironment) add(option string) BuildEnvironment {
	return environment.merge([option])
}

pub fn (environment BuildEnvironment) std() bool {
	return 'std' in environment.settings
}

pub struct BuildEnvironmentOwner {
pub:
	name string
mut:
	environment BuildEnvironment
}

pub fn new_build_environment_owner(name string) BuildEnvironmentOwner {
	return BuildEnvironmentOwner{
		name: name
		environment: new_build_environment()
	}
}

pub fn (mut owner BuildEnvironmentOwner) env(settings ...string) BuildEnvironment {
	owner.environment.merge(settings)
	return owner.environment
}

pub fn environment_keys(environment map[string]string) []string {
	mut keys := []string{}
	for key in build_environment_keys {
		if key in environment {
			keys << key
		}
	}
	return keys
}

pub fn dump_build_environment(environment map[string]string) []string {
	mut keys := environment_keys(environment)
	if environment['CC'] == environment['HOMEBREW_CC'] {
		for compiler_key in ['CC', 'CXX', 'OBJC', 'OBJCXX'] {
			index := keys.index(compiler_key)
			if index >= 0 {
				keys.delete(index)
			}
		}
	}
	mut lines := []string{}
	for key in keys {
		value := environment[key]
		mut line := '${key}: ${value}'
		if key in ['CC', 'CXX', 'LD'] && value != '' && ruby.is_link(value) {
			line += ' => ${ruby.real_path(value)}'
		}
		lines << line
	}
	return lines
}

fn build_environment_boundary_value(environment BuildEnvironment) ruby.Value {
	return ruby.structured_value('BuildEnvironment', environment.settings.join(','), {
		'settings': environment.settings.join('\x1f')
	})
}

fn build_environment_from_boundary(value ruby.Value) BuildEnvironment {
	if value.type_name != 'BuildEnvironment' {
		panic('expected BuildEnvironment, got ${value.type_name}')
	}
	settings := value.attribute('settings') or { panic(err) }
	return if settings == '' {
		new_build_environment()
	} else {
		new_build_environment(...settings.split('\x1f'))
	}
}

fn values_as_settings(values []ruby.Value) []string {
	mut settings := []string{}
	for value in values {
		if value.type_name == 'Array' {
			settings << (value.as_string_array() or { panic(err) })
		} else {
			settings << value.as_string()
		}
	}
	return settings
}
