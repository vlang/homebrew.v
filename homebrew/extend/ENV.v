module extend

import ruby

// Translated from Homebrew/brew `extend/ENV.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum EnvironmentExtension {
	stdenv
	superenv
}

pub struct BuildEnvironmentOptions {
pub:
	env           ?string
	cc            ?string
	build_bottle  bool
	bottle_arch   ?string
	debug_symbols ?bool
}

pub type BuildEnvironmentSetup = fn(environment map[string]string, extension EnvironmentExtension, options BuildEnvironmentOptions) !map[string]string

pub type BuildEnvironmentBlock = fn(environment map[string]string) !ruby.Value

pub fn activate_environment_extensions(env ?string, superenv_bin ?string) EnvironmentExtension {
	if requested := env {
		if requested == 'std' {
			return .stdenv
		}
	}
	if _ := superenv_bin {
		return .superenv
	}
	return .stdenv
}

// with_build_environment passes a temporary, configured copy to the callback.
// The caller's map is value-isolated, matching Ruby's ensure-based restoration.
pub fn with_build_environment(environment map[string]string, options BuildEnvironmentOptions,
	superenv_bin ?string, setup BuildEnvironmentSetup,
	block BuildEnvironmentBlock) !ruby.Value {
	extension := activate_environment_extensions(options.env, superenv_bin)
	temporary := setup(environment.clone(), extension, options)!
	return block(temporary)
}

// Ruby method `activate_extensions!(env: nil)` at line 25.
pub fn ruby_env_l25_d1_activate_extensions(env ?string, superenv_bin ?string) EnvironmentExtension {
	return activate_environment_extensions(env, superenv_bin)
}

// Ruby method `with_build_environment(env: nil, cc: nil, build_bottle: false, bottle_arch: nil, debug_symbols: false, &_block)` at line 43.
pub fn ruby_env_l43_d2_with_build_environment(environment map[string]string,
	options BuildEnvironmentOptions, superenv_bin ?string, setup BuildEnvironmentSetup,
	block BuildEnvironmentBlock) !ruby.Value {
	return with_build_environment(environment, options, superenv_bin, setup, block)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5: require "diagnostic"
// 6: require "extend/ENV/sensitive"
// 7: require "extend/ENV/shared"
// 8: require "extend/ENV/std"
// 9: require "extend/ENV/super"
// 10:
// 11: # <!-- vale off -->
// 12: # @!parse
// 13: #   # `ENV` is not actually a class, but this makes YARD happy
// 14: #   # @see https://rubydoc.info/stdlib/core/ENV
// 15: #   #   <code>ENV</code> core documentation
// 16: #   # @see Superenv
// 17: #   # @see Stdenv
// 18: #   class ENV; end
// 19: # <!-- vale on -->
// 20:
// 21: module EnvActivation
// 22:   include EnvSensitive
// 23:
// 24:   sig { params(env: T.nilable(String)).void }
// 25:   def activate_extensions!(env: nil)
// 26:     if superenv?(env)
// 27:       extend(Superenv)
// 28:     else
// 29:       extend(Stdenv)
// 30:     end
// 31:   end
// 32:
// 33:   sig {
// 34:     type_parameters(:U).params(
// 35:       env:           T.nilable(String),
// 36:       cc:            T.nilable(String),
// 37:       build_bottle:  T::Boolean,
// 38:       bottle_arch:   T.nilable(String),
// 39:       debug_symbols: T.nilable(T::Boolean),
// 40:       _block:        T.proc.returns(T.type_parameter(:U)),
// 41:     ).returns(T.type_parameter(:U))
// 42:   }
// 43:   def with_build_environment(env: nil, cc: nil, build_bottle: false, bottle_arch: nil, debug_symbols: false, &_block)
// 44:     old_env = to_hash.dup
// 45:     tmp_env = to_hash.dup.extend(EnvActivation)
// 46:     T.cast(tmp_env, EnvActivation).activate_extensions!(env:)
// 47:     T.cast(tmp_env, T.any(Superenv, Stdenv))
// 48:      .setup_build_environment(cc:, build_bottle:, bottle_arch:,
// 49:                               debug_symbols:)
// 50:     replace(tmp_env)
// 51:
// 52:     begin
// 53:       yield
// 54:     ensure
// 55:       replace(old_env)
// 56:     end
// 57:   end
// 58: end
// 59:
// 60: ENV.extend(EnvActivation)
