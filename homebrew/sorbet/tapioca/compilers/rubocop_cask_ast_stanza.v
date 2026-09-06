module compilers

import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rubocop_cask_ast_stanza.rb`.
pub struct TapiocaGeneratedMethod {
pub:
	name         string
	return_type  string
	class_method bool
	parameters   []string
}

pub struct TapiocaDecoration {
pub:
	constant_name string
	kind          string
	methods       []TapiocaGeneratedMethod
}

pub fn stanza_compiler_decoration(constant_name string) TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'module'
		methods: stanza_constants.stanza_order.map(TapiocaGeneratedMethod{
			name: '${it}?'
			return_type: 'T::Boolean'
			class_method: false
		})
	}
}
