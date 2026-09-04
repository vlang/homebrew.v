module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rubocop.rb`.
pub struct RubocopCompilerMethod {
pub:
	name   string
	source string
}

pub struct RubocopCompilerModule {
pub:
	name           string
	source_path    string
	has_rbi        bool
	includes_macro bool
	methods        []RubocopCompilerMethod
}

@[heap]
pub struct RubocopCompilerInput {
pub:
	modules []RubocopCompilerModule
}

pub fn rubocop_compiler_gather_constants(input &RubocopCompilerInput) []RubocopCompilerModule {
	mut gathered := []RubocopCompilerModule{}
	for constant_module in input.modules {
		if !constant_module.includes_macro || constant_module.source_path.contains('/vendor/bundle/ruby/') || constant_module.has_rbi {
			continue
		}
		mut uses_dsl := false
		for method in constant_module.methods {
			if method.source.trim_space().starts_with('def_node_') {
				uses_dsl = true
				break
			}
		}
		if uses_dsl {
			gathered << constant_module
		}
	}
	return gathered
}

pub fn rubocop_compiler_decoration(constant_module RubocopCompilerModule) TapiocaDecoration {
	mut methods := []TapiocaGeneratedMethod{}
	for method in constant_module.methods {
		source := method.source.trim_space()
		if source.starts_with('def_node_matcher') {
			methods << TapiocaGeneratedMethod{
				name: method.name
				parameters: ['node: RuboCop::AST::Node', '**kwargs: T.untyped', '&block: T.untyped']
				return_type: 'T.untyped'
			}
		} else if source.starts_with('def_node_search') {
			methods << TapiocaGeneratedMethod{
				name: method.name
				parameters: ['node: RuboCop::AST::Node', '*pattern: T.any(String, Symbol)',
					'**kwargs: T.untyped', '&block: T.untyped']
				return_type: if method.name.ends_with('?') { 'T::Boolean' } else { 'T.untyped' }
			}
		}
	}
	return TapiocaDecoration{
		constant_name: constant_module.name
		kind: 'path'
		methods: methods
	}
}

fn rubocop_compiler_input_value(input &RubocopCompilerInput) ruby.Value {
	return ruby.structured_value('Tapioca::Compilers::RuboCop::Input', '', {
		'rubocop_compiler_input_address': u64(voidptr(input)).str()
	})
}

fn rubocop_compiler_input_from_value(value ruby.Value) &RubocopCompilerInput {
	address := value.attributes['rubocop_compiler_input_address'] or {
		panic('invalid RuboCop compiler input')
	}
	return unsafe { &RubocopCompilerInput(voidptr(address.u64())) }
}

pub fn rubocop_compiler_input_boundary(input &RubocopCompilerInput) ruby.Value {
	return rubocop_compiler_input_value(input)
}
