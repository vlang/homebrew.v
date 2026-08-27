module homebrew

import brew_runtime

// Translated from Homebrew/brew `build_environment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*settings)` at line 7.
pub fn ruby_build_environment_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `merge(*args)` at line 12.
pub fn ruby_build_environment_l12_d2_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge', ...args)
}

// Ruby method `<<(option)` at line 18.
pub fn ruby_build_environment_l18_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `std?` at line 24.
pub fn ruby_build_environment_l24_d4_std(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std?', ...args)
}

// Ruby method `inherited(child)` at line 33.
pub fn ruby_build_environment_l33_d5_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Ruby method `env(*settings)` at line 41.
pub fn ruby_build_environment_l41_d6_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env', ...args)
}

// Ruby method `self.keys(env)` at line 66.
pub fn ruby_build_environment_l66_d7_self_keys(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.keys', ...args)
}

// Ruby method `self.dump(env, out = $stdout)` at line 71.
pub fn ruby_build_environment_l71_d8_self_dump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dump', ...args)
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
