module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/forwardables.rb`.
pub const forwardable_compiler_array_methods = ['to_a', 'to_ary']
pub const forwardable_compiler_hash_methods = ['to_h', 'to_hash']
pub const forwardable_compiler_string_methods = ['to_s', 'to_str', 'to_json']

pub struct ForwardableCompilerModule {
pub:
	name                string
	source_path         string
	extends_forwardable bool
	instance_methods    []string
	class_methods       []string
}

@[heap]
pub struct ForwardablesCompilerInput {
pub:
	modules []ForwardableCompilerModule
}

pub fn forwardables_compiler_return_type(class_name string, name string) string {
	if class_name == '::Cask::Cask' {
		if name == 'on_system_block_min_os' {
			return 'T.nilable(MacOSVersion)'
		}
		if name == 'url' {
			return 'T.nilable(::Cask::URL)'
		}
	}
	if name.ends_with('?') {
		return 'T::Boolean'
	}
	if name in forwardable_compiler_array_methods {
		return 'Array'
	}
	if name in forwardable_compiler_hash_methods {
		return 'Hash'
	}
	if name in forwardable_compiler_string_methods {
		return 'String'
	}
	return 'T.untyped'
}

pub fn forwardables_compile_method(class_name string, name string,
	class_method bool) TapiocaGeneratedMethod {
	return TapiocaGeneratedMethod{
		name: name
		parameters: ['*args: T.untyped', '&block: T.untyped']
		return_type: forwardables_compiler_return_type(class_name, name)
		class_method: class_method
	}
}

pub fn forwardables_compiler_gather_constants(input &ForwardablesCompilerInput) []ForwardableCompilerModule {
	return input.modules.filter(it.extends_forwardable && !it.source_path.contains('vendor/bundle/ruby'))
}

pub fn forwardables_compiler_decoration(constant_module ForwardableCompilerModule) TapiocaDecoration {
	mut methods := []TapiocaGeneratedMethod{}
	for name in constant_module.instance_methods {
		methods << forwardables_compile_method(constant_module.name, name, false)
	}
	for name in constant_module.class_methods {
		methods << forwardables_compile_method(constant_module.name, name, true)
	}
	return TapiocaDecoration{
		constant_name: constant_module.name
		kind: 'path'
		methods: methods
	}
}

fn forwardables_compiler_input_value(input &ForwardablesCompilerInput) ruby.Value {
	return ruby.structured_value('Tapioca::Compilers::Forwardables::Input', '', {
		'forwardables_compiler_input_address': u64(voidptr(input)).str()
	})
}

fn forwardables_compiler_input_from_value(value ruby.Value) &ForwardablesCompilerInput {
	address := value.attributes['forwardables_compiler_input_address'] or {
		panic('invalid Forwardables compiler input')
	}
	return unsafe { &ForwardablesCompilerInput(voidptr(address.u64())) }
}

pub fn forwardables_compiler_input_boundary(input &ForwardablesCompilerInput) ruby.Value {
	return forwardables_compiler_input_value(input)
}
