module compilers

import ruby
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

fn tapioca_decoration_value(decoration TapiocaDecoration) ruby.Value {
	return ruby.map_value({
		'constant_name': ruby.string_value(decoration.constant_name)
		'kind':          ruby.string_value(decoration.kind)
		'methods':       ruby.array_value(decoration.methods.map(ruby.map_value({
			'name':         ruby.string_value(it.name)
			'return_type':  ruby.string_value(it.return_type)
			'class_method': ruby.bool_value(it.class_method)
			'parameters':   ruby.string_array_value(it.parameters)
		})))
	})
}
