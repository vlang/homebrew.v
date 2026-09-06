module tapioca

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
