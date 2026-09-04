module tapioca

import ruby

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

fn tapioca_object_from_value(value ruby.Value) TapiocaObject {
	return TapiocaObject{
		kind: value.type_name
		name: value.attributes['name'] or { value.as_string() }
		attached_kind: value.attributes['attached_kind'] or { '' }
		attached_name: value.attributes['attached_name'] or { '' }
	}
}

fn tapioca_object_value(object TapiocaObject) ruby.Value {
	return ruby.structured_value(object.kind, object.name, {
		'name':          object.name
		'attached_kind': object.attached_kind
		'attached_name': object.attached_name
	})
}

fn tapioca_methods_from_value(value ruby.Value) []TapiocaMethod {
	values := value.as_array() or { return [] }
	return values.map(TapiocaMethod{
		name: it.attributes['name'] or { it.as_string() }
		source_file: it.attributes['source_file'] or { '' }
		class_method: (it.attributes['class_method'] or { 'false' }) == 'true'
	})
}

fn tapioca_method_value(method TapiocaMethod) ruby.Value {
	return ruby.structured_value(if method.class_method {
		'Method'
	} else {
		'UnboundMethod'
	}, method.name, {
		'name':         method.name
		'source_file':  method.source_file
		'class_method': method.class_method.str()
	})
}
