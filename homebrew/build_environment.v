module homebrew

import ruby

// Translated from Homebrew/brew `build_environment.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(*settings)` at line 7.
pub fn ruby_build_environment_l7_d1_initialize(args ...ruby.Value) ruby.Value {
	return build_environment_boundary_value(new_build_environment(...values_as_settings(args)))
}

// Ruby method `merge(*args)` at line 12.
pub fn ruby_build_environment_l12_d2_merge(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BuildEnvironment#merge requires a receiver')
	}
	mut environment := build_environment_from_boundary(args[0])
	environment.merge(values_as_settings(args[1..]))
	return build_environment_boundary_value(environment)
}

// Ruby method `<<(option)` at line 18.
pub fn ruby_build_environment_l18_d3_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('BuildEnvironment#<< requires a receiver and option')
	}
	mut environment := build_environment_from_boundary(args[0])
	environment.add(args[1].as_string())
	return build_environment_boundary_value(environment)
}

// Ruby method `std?` at line 24.
pub fn ruby_build_environment_l24_d4_std(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BuildEnvironment#std? requires a receiver')
	}
	return ruby.bool_value(build_environment_from_boundary(args[0]).std())
}

// Ruby method `inherited(child)` at line 33.
pub fn ruby_build_environment_l33_d5_inherited(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BuildEnvironment::DSL#inherited requires a child')
	}
	owner := new_build_environment_owner(args[0].as_string())
	return ruby.structured_value('BuildEnvironmentOwner', owner.name, {
		'name':     owner.name
		'settings': ''
	})
}

// Ruby method `env(*settings)` at line 41.
pub fn ruby_build_environment_l41_d6_env(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'BuildEnvironmentOwner' {
		panic('${if args.len > 0 { args[0].as_string() } else { 'object' }} has not been initialized with a BuildEnvironment')
	}
	mut environment := new_build_environment()
	existing := args[0].attribute('settings') or { panic(err) }
	if existing != '' {
		environment.merge(existing.split('\x1f'))
	}
	environment.merge(values_as_settings(args[1..]))
	return build_environment_boundary_value(environment)
}

// Ruby method `self.keys(env)` at line 66.
pub fn ruby_build_environment_l66_d7_self_keys(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		panic('BuildEnvironment.keys requires an environment Hash')
	}
	return ruby.string_array_value(environment_keys(args[0].attributes))
}

// Ruby method `self.dump(env, out = $stdout)` at line 71.
pub fn ruby_build_environment_l71_d8_self_dump(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		panic('BuildEnvironment.dump requires an environment Hash')
	}
	output := dump_build_environment(args[0].attributes).join('\n') + '\n'
	return ruby.object_value('IOWrite', output)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Settings for the build environment.
// 5: class BuildEnvironment
// 6:   sig { params(settings: Symbol).void }
// 7:   def initialize(*settings)
// 8:     @settings = T.let(Set.new(settings), T::Set[Symbol])
// 9:   end
// 10:
// 11:   sig { params(args: T::Enumerable[Symbol]).returns(T.self_type) }
// 12:   def merge(*args)
// 13:     @settings.merge(*args)
// 14:     self
// 15:   end
// 16:
// 17:   sig { params(option: Symbol).returns(T.self_type) }
// 18:   def <<(option)
// 19:     @settings << option
// 20:     self
// 21:   end
// 22:
// 23:   sig { returns(T::Boolean) }
// 24:   def std?
// 25:     @settings.include? :std
// 26:   end
// 27:
// 28:   # DSL for specifying build environment settings.
// 29:   module DSL
// 30:     # Initialise @env for each class which may use this DSL (e.g. each formula subclass).
// 31:     # `env` may never be called and it needs to be initialised before the class is frozen.
// 32:     sig { params(child: T.untyped).void }
// 33:     def inherited(child)
// 34:       super
// 35:       child.instance_eval do
// 36:         @env = T.let(BuildEnvironment.new, T.nilable(BuildEnvironment))
// 37:       end
// 38:     end
// 39:
// 40:     sig { overridable.params(settings: Symbol).returns(T.nilable(BuildEnvironment)) }
// 41:     def env(*settings)
// 42:       env = @env
// 43:       Kernel.raise ArgumentError, "#{self} has not been initialized with a BuildEnvironment" if env.nil?
// 44:
// 45:       env.merge(settings)
// 46:     end
// 47:   end
// 48:
// 49:   KEYS = %w[
// 50:     CC CXX LD OBJC OBJCXX
// 51:     HOMEBREW_CC
// 52:     CFLAGS CXXFLAGS CPPFLAGS LDFLAGS SDKROOT MAKEFLAGS
// 53:     CMAKE_PREFIX_PATH CMAKE_INCLUDE_PATH CMAKE_LIBRARY_PATH CMAKE_FRAMEWORK_PATH
// 54:     MACOSX_DEPLOYMENT_TARGET PKG_CONFIG_PATH PKG_CONFIG_LIBDIR
// 55:     HOMEBREW_DEBUG HOMEBREW_MAKE_JOBS HOMEBREW_VERBOSE
// 56:     all_proxy ftp_proxy http_proxy https_proxy no_proxy
// 57:     HOMEBREW_SVN HOMEBREW_GIT
// 58:     HOMEBREW_SDKROOT
// 59:     MAKE GIT CPP
// 60:     ACLOCAL_PATH PATH CPATH
// 61:     LD_LIBRARY_PATH LD_RUN_PATH LD_PRELOAD LIBRARY_PATH
// 62:   ].freeze
// 63:   private_constant :KEYS
// 64:
// 65:   sig { params(env: T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))]).returns(T::Array[String]) }
// 66:   def self.keys(env)
// 67:     KEYS & env.keys
// 68:   end
// 69:
// 70:   sig { params(env: T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))], out: IO).void }
// 71:   def self.dump(env, out = $stdout)
// 72:     keys = self.keys(env)
// 73:     keys -= %w[CC CXX OBJC OBJCXX] if env["CC"] == env["HOMEBREW_CC"]
// 74:
// 75:     keys.each do |key|
// 76:       value = env.fetch(key)
// 77:
// 78:       string = "#{key}: #{value}"
// 79:       case key
// 80:       when "CC", "CXX", "LD"
// 81:         value = T.cast(value, String)
// 82:         string << " => #{Pathname.new(value).realpath}" if value.present? && File.symlink?(value)
// 83:       end
// 84:       string.freeze
// 85:       out.puts string
// 86:     end
// 87:   end
// 88: end
