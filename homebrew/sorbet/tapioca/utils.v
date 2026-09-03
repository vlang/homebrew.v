module tapioca

import brew_runtime

pub struct TapiocaObject {
pub:
	kind          string
	name          string
	attached_kind string
	attached_name string
}

pub struct TapiocaMethod {
pub:
	name         string
	source_file  string
	class_method bool
}

// Translated from Homebrew/brew `sorbet/tapioca/utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.named_object_for(klass)` at line 8.
pub fn ruby_utils_l8_d1_self_named_object_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('RuntimeError', 'named_object_for requires a class')
	}
	object := tapioca_object_from_value(args[0])
	named := tapioca_named_object_for(object) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return tapioca_object_value(named)
}

// Ruby method `self.methods_from_file(mod, file_name, class_methods: false)` at line 24.
pub fn ruby_utils_l24_d2_self_methods_from_file(args ...brew_runtime.Value) brew_runtime.Value {
	methods := if args.len > 0 { tapioca_methods_from_value(args[0]) } else { []TapiocaMethod{} }
	file_name := if args.len > 1 { args[1].as_string() } else { '' }
	class_methods := args.len > 2 && args[2].bool_data
	return brew_runtime.array_value(tapioca_methods_from_file(methods, file_name, class_methods).map(tapioca_method_value(it)))
}

// Ruby method `self.named_objects_with_module(mod)` at line 34.
pub fn ruby_utils_l34_d3_self_named_objects_with_module(args ...brew_runtime.Value) brew_runtime.Value {
	objects := if args.len > 0 {
		args[0].as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}.map(tapioca_object_from_value(it))
	named := tapioca_named_objects_with_module(objects) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.array_value(named.map(tapioca_object_value(it)))
}

pub fn tapioca_named_object_for(object TapiocaObject) !TapiocaObject {
	if object.name != '' {
		return object
	}
	if object.attached_kind == 'Class' || object.attached_kind == 'Module' {
		return TapiocaObject{
			kind: object.attached_kind
			name: object.attached_name
		}
	}
	return error('Unsupported attached object for: ${object.kind}')
}

pub fn tapioca_methods_from_file(methods []TapiocaMethod, file_name string,
	class_methods bool) []TapiocaMethod {
	return methods.filter(it.class_method == class_methods && it.source_file.ends_with(file_name))
}

pub fn tapioca_named_objects_with_module(objects []TapiocaObject) ![]TapiocaObject {
	mut output := []TapiocaObject{}
	mut seen := map[string]bool{}
	for object in objects {
		resolved := match object.kind {
			'Class' { tapioca_named_object_for(object)! }
			'Module' { object }
			else {
				return error('Unsupported object: ${object.kind}')
			}
		}
		key := '${resolved.kind}:${resolved.name}'
		if key !in seen {
			seen[key] = true
			output << resolved
		}
	}
	return output
}

fn tapioca_object_from_value(value brew_runtime.Value) TapiocaObject {
	return TapiocaObject{
		kind: value.type_name
		name: value.attributes['name'] or { value.as_string() }
		attached_kind: value.attributes['attached_kind'] or { '' }
		attached_name: value.attributes['attached_name'] or { '' }
	}
}

fn tapioca_object_value(object TapiocaObject) brew_runtime.Value {
	return brew_runtime.structured_value(object.kind, object.name, {
		'name':          object.name
		'attached_kind': object.attached_kind
		'attached_name': object.attached_name
	})
}

fn tapioca_methods_from_value(value brew_runtime.Value) []TapiocaMethod {
	values := value.as_array() or { return [] }
	return values.map(TapiocaMethod{
		name: it.attributes['name'] or { it.as_string() }
		source_file: it.attributes['source_file'] or { '' }
		class_method: (it.attributes['class_method'] or { 'false' }) == 'true'
	})
}

fn tapioca_method_value(method TapiocaMethod) brew_runtime.Value {
	return brew_runtime.structured_value(if method.class_method {
		'Method'
	} else {
		'UnboundMethod'
	}, method.name, {
		'name':         method.name
		'source_file':  method.source_file
		'class_method': method.class_method.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Tapioca
// 6:     module Utils
// 7:       sig { params(klass: T::Class[T.anything]).returns(T::Module[T.anything]) }
// 8:       def self.named_object_for(klass)
// 9:         return klass if klass.name
// 10:
// 11:         attached_object = klass.attached_object
// 12:         case attached_object
// 13:         when Module then attached_object
// 14:         else raise "Unsupported attached object for: #{klass}"
// 15:         end
// 16:       end
// 17:
// 18:       # @param class_methods [Boolean] whether to get class methods or instance methods
// 19:       # @return the `module` methods that are defined in the given file
// 20:       sig {
// 21:         params(mod: T::Module[T.anything], file_name: String,
// 22:                class_methods: T::Boolean).returns(T::Array[T.any(Method, UnboundMethod)])
// 23:       }
// 24:       def self.methods_from_file(mod, file_name, class_methods: false)
// 25:         methods = if class_methods
// 26:           mod.methods(false).map { mod.method(it) }
// 27:         else
// 28:           mod.instance_methods(false).map { mod.instance_method(it) }
// 29:         end
// 30:         methods.select { it.source_location&.first&.end_with?(file_name) }
// 31:       end
// 32:
// 33:       sig { params(mod: T::Module[T.anything]).returns(T::Array[T::Module[T.anything]]) }
// 34:       def self.named_objects_with_module(mod)
// 35:         ObjectSpace.each_object(mod).map do |obj|
// 36:           case obj
// 37:           when Class then named_object_for(obj)
// 38:           when Module then obj
// 39:           else raise "Unsupported object: #{obj}"
// 40:           end
// 41:         end.uniq
// 42:       end
// 43:     end
// 44:   end
// 45: end
