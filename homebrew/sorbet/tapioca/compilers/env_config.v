module compilers

import ruby
import homebrew

// Translated from Homebrew/brew `sorbet/tapioca/compilers/env_config.rb`.
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
		name := homebrew.env_config_env_method_name(environment_name, entry)
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
