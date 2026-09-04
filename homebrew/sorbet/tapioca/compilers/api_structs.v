module compilers

import ruby
import homebrew.api

// Translated from Homebrew/brew `sorbet/tapioca/compilers/api_structs.rb`.
pub fn api_structs_compiler_decoration(constant_name string) TapiocaDecoration {
	predicates := if constant_name.ends_with('CaskStruct') {
		api.cask_struct_predicate_names
	} else {
		api.formula_struct_predicate_names
	}
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'class'
		methods: predicates.map(TapiocaGeneratedMethod{
			name: '${it}?'
			return_type: 'T::Boolean'
			class_method: false
		})
	}
}
