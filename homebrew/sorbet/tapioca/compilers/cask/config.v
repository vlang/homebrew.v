module cask

import homebrew.cask as brew_cask

// Translated from Homebrew/brew `sorbet/tapioca/compilers/cask/config.rb`.
pub struct CaskConfigCompilerMethod {
pub:
	name         string
	return_type  string
	class_method bool
}

pub fn cask_config_compiler_methods() []CaskConfigCompilerMethod {
	mut keys := brew_cask.cask_config_defaults().keys()
	if 'appimagedir' !in keys {
		keys << 'appimagedir'
	}
	keys.sort()
	return keys.map(CaskConfigCompilerMethod{
		name: it
		return_type: if it == 'languages' {
			'T::Array[String]'
		} else if it.ends_with('?') {
			'T::Boolean'
		} else {
			'String'
		}
		class_method: false
	})
}
