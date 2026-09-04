module cask

import ruby
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

fn cask_config_compiler_decoration_value() ruby.Value {
	return ruby.map_value({
		'constant_name': ruby.string_value('Cask::Config')
		'kind':          ruby.string_value('class')
		'methods':       ruby.array_value(cask_config_compiler_methods().map(ruby.map_value({
			'name':         ruby.string_value(it.name)
			'return_type':  ruby.string_value(it.return_type)
			'class_method': ruby.bool_value(it.class_method)
		})))
	})
}
