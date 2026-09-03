module compilers

import brew_runtime
import homebrew

// Translated from Homebrew/brew `sorbet/tapioca/compilers/env_config.rb`.
// The original source is retained below until every stub has a typed V body.
const env_config_compiler_custom = ['HOMEBREW_BUNDLE_JOBS', 'HOMEBREW_CASK_OPTS',
	'HOMEBREW_DOWNLOAD_CONCURRENCY', 'HOMEBREW_FORBID_PACKAGES_FROM_PATHS', 'HOMEBREW_MAKE_JOBS']

pub fn env_config_compiler_decoration() TapiocaDecoration {
	state := &homebrew.EnvConfigState{}
	entries := homebrew.env_config_entries(state)
	mut environment_names := entries.keys()
	environment_names.sort()
	mut methods := []TapiocaGeneratedMethod{}
	for environment_name in environment_names {
		if environment_name in env_config_compiler_custom {
			continue
		}
		entry := entries[environment_name]
		name := homebrew.ruby_env_config_l801_d1_env_method_name(environment_name, entry)
		return_type := if name.ends_with('?') {
			'T::Boolean'
		} else if entry.has_default && entry.default_value != '' {
			'String'
		} else {
			'T.nilable(::String)'
		}
		methods << TapiocaGeneratedMethod{
			name: name
			return_type: return_type
			class_method: true
		}
	}
	return TapiocaDecoration{
		constant_name: 'Homebrew::EnvConfig'
		kind: 'module'
		methods: methods
	}
}

// Ruby method `self.gather_constants = [Homebrew::EnvConfig]` at line 13.
pub fn ruby_env_config_l13_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value([
		brew_runtime.object_value('Module', 'Homebrew::EnvConfig'),
	])
}

// Ruby method `decorate` at line 16.
pub fn ruby_env_config_l16_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return tapioca_decoration_value(env_config_compiler_decoration())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "env_config"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class EnvConfig < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [Homebrew::EnvConfig]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_module(T.must(constant.name)) do |mod|
// 18:           dynamic_methods = {}
// 19:           Homebrew::EnvConfig::ENVS.each do |env, hash|
// 20:             next if Homebrew::EnvConfig::CUSTOM_IMPLEMENTATIONS.include?(env)
// 21:
// 22:             name = Homebrew::EnvConfig.env_method_name(env, hash)
// 23:             dynamic_methods[name] = hash[:default]
// 24:           end
// 25:
// 26:           dynamic_methods.each do |method, default|
// 27:             return_type = if method.end_with?("?")
// 28:               "T::Boolean"
// 29:             elsif default
// 30:               "String"
// 31:             else
// 32:               "T.nilable(::String)"
// 33:             end
// 34:
// 35:             mod.create_method(method, return_type:, class_method: true)
// 36:           end
// 37:         end
// 38:       end
// 39:     end
// 40:   end
// 41: end
