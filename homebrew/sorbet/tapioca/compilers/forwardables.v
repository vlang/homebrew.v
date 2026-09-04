module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/forwardables.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.gather_constants` at line 26.
pub fn ruby_forwardables_l26_d1_self_gather_constants(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	return ruby.array_value(forwardables_compiler_gather_constants(forwardables_compiler_input_from_value(args[0])).map(ruby.object_value('Module', it.name)))
}

// Ruby method `decorate` at line 34.
pub fn ruby_forwardables_l34_d2_decorate(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'input and constant are required')
	}
	input := forwardables_compiler_input_from_value(args[0])
	name := args[1].as_string()
	matches := input.modules.filter(it.name == name)
	if matches.len == 0 {
		return ruby.object_value('NameError', 'unknown constant ${name}')
	}
	return tapioca_decoration_value(forwardables_compiler_decoration(matches[0]))
}

// Ruby method `compile_forwardable_method(klass, method, class_method: false)` at line 46.
pub fn ruby_forwardables_l46_d3_compile_forwardable_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'klass and method are required')
	}
	class_method := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	method := forwardables_compile_method(args[0].as_string(), args[1].as_string(), class_method)
	return ruby.map_value({
		'name':         ruby.string_value(method.name)
		'parameters':   ruby.string_array_value(method.parameters)
		'return_type':  ruby.string_value(method.return_type)
		'class_method': ruby.bool_value(method.class_method)
	})
}

// Ruby method `return_type(klass, name)` at line 61.
pub fn ruby_forwardables_l61_d4_return_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'klass and name are required')
	}
	return ruby.string_value(forwardables_compiler_return_type(args[0].as_string(), args[1].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "sorbet/tapioca/utils"
// 6: require "utils/ast"
// 7:
// 8: module Tapioca
// 9:   module Compilers
// 10:     class Forwardables < Tapioca::Dsl::Compiler
// 11:       FORWARDABLE_FILENAME = "forwardable.rb"
// 12:       ARRAY_METHODS = ["to_a", "to_ary"].freeze
// 13:       HASH_METHODS = ["to_h", "to_hash"].freeze
// 14:       STRING_METHODS = ["to_s", "to_str", "to_json"].freeze
// 15:       # Use this to override the default return type of a forwarded method:
// 16:       RETURN_TYPE_OVERRIDES = T.let({
// 17:         "::Cask::Cask" => {
// 18:           "on_system_block_min_os" => "T.nilable(MacOSVersion)",
// 19:           "url"                    => "T.nilable(::Cask::URL)",
// 20:         },
// 21:       }.freeze, T::Hash[String, T::Hash[String, String]])
// 22:
// 23:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 24:
// 25:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 26:       def self.gather_constants
// 27:         Homebrew::Tapioca::Utils.named_objects_with_module(Forwardable).reject do |obj|
// 28:           # Avoid duplicate stubs for forwardables that are defined in vendored gems
// 29:           Object.const_source_location(T.must(obj.name))&.first&.include?("vendor/bundle/ruby")
// 30:         end
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def decorate
// 35:         root.create_path(constant) do |klass|
// 36:           Homebrew::Tapioca::Utils.methods_from_file(constant, FORWARDABLE_FILENAME)
// 37:                                   .each { |method| compile_forwardable_method(klass, method) }
// 38:           Homebrew::Tapioca::Utils.methods_from_file(constant, FORWARDABLE_FILENAME, class_methods: true)
// 39:                                   .each { |method| compile_forwardable_method(klass, method, class_method: true) }
// 40:         end
// 41:       end
// 42:
// 43:       private
// 44:
// 45:       sig { params(klass: RBI::Scope, method: T.any(Method, UnboundMethod), class_method: T::Boolean).void }
// 46:       def compile_forwardable_method(klass, method, class_method: false)
// 47:         name = method.name.to_s
// 48:         return_type = return_type(klass.to_s, name)
// 49:         klass.create_method(
// 50:           name,
// 51:           parameters:   [
// 52:             create_rest_param("args", type: "T.untyped"),
// 53:             create_block_param("block", type: "T.untyped"),
// 54:           ],
// 55:           return_type:,
// 56:           class_method:,
// 57:         )
// 58:       end
// 59:
// 60:       sig { params(klass: String, name: String).returns(String) }
// 61:       def return_type(klass, name)
// 62:         if (override = RETURN_TYPE_OVERRIDES.dig(klass, name)) then override
// 63:         elsif name.end_with?("?") then "T::Boolean"
// 64:         elsif ARRAY_METHODS.include?(name) then "Array"
// 65:         elsif HASH_METHODS.include?(name) then "Hash"
// 66:         elsif STRING_METHODS.include?(name) then "String"
// 67:         else
// 68:           "T.untyped"
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
