module brew_runtime

// Value is the temporary boundary type used by source-faithful translations whose
// Ruby types have not been made concrete in V yet.
pub struct Value {
pub:
	type_name         string
	repr              string
	bool_data         bool
	int_data          i64
	float_data        f64
	string_array_data []string
	array_data        []Value
	map_data          map[string]Value
	attributes        map[string]string
}

// string_value translates a Ruby String crossing a still-generic boundary.
pub fn string_value(value string) Value {
	return Value{
		type_name: 'String'
		repr:      value
	}
}

// object_value preserves a translated Ruby object's concrete type and string
// representation while callers are migrated from generic boundaries to V types.
pub fn object_value(type_name string, representation string) Value {
	return Value{
		type_name: type_name
		repr:      representation
	}
}

// structured_value carries source-derived object attributes through generic
// adapters until all callers use the object's concrete V type directly.
pub fn structured_value(type_name string, representation string, attributes map[string]string) Value {
	return Value{
		type_name:  type_name
		repr:       representation
		attributes: attributes.clone()
	}
}

// bool_value translates a Ruby boolean crossing a still-generic boundary.
pub fn bool_value(value bool) Value {
	return Value{
		type_name: 'Bool'
		repr:      value.str()
		bool_data: value
	}
}

// int_value translates a Ruby Integer crossing a still-generic boundary.
pub fn int_value(value i64) Value {
	return Value{
		type_name: 'Integer'
		repr:      value.str()
		int_data:  value
	}
}

// float_value translates a Ruby Float crossing a still-generic boundary.
pub fn float_value(value f64) Value {
	return Value{
		type_name:  'Float'
		repr:       value.str()
		float_data: value
	}
}

// string_array_value translates a Ruby Array[String] crossing a still-generic
// boundary.
pub fn string_array_value(value []string) Value {
	return Value{
		type_name:         'Array'
		repr:              value.str()
		string_array_data: value.clone()
	}
}

// array_value translates a heterogeneous Ruby Array crossing a generic
// boundary.
pub fn array_value(value []Value) Value {
	return Value{
		type_name:  'Array'
		repr:       value.map(it.repr).str()
		array_data: value.clone()
	}
}

// map_value translates a heterogeneous Ruby Hash while retaining recursively
// nested boundary values.
pub fn map_value(value map[string]Value) Value {
	return Value{
		type_name: 'Hash'
		repr:      value.str()
		map_data:  value.clone()
	}
}

// as_string returns the Ruby-style string representation carried by a boundary
// value. Objects use the same representation as their translated `to_s` method.
pub fn (value Value) as_string() string {
	return value.repr
}

// as_bool returns a translated Ruby Boolean or reports a type mismatch.
pub fn (value Value) as_bool() !bool {
	if value.type_name != 'Bool' {
		return error('expected Bool, got ${value.type_name}')
	}
	return value.bool_data
}

// as_int returns a translated Ruby Integer or reports a type mismatch.
pub fn (value Value) as_int() !i64 {
	if value.type_name != 'Integer' {
		return error('expected Integer, got ${value.type_name}')
	}
	return value.int_data
}

// as_float returns a translated Ruby numeric value or reports a type mismatch.
pub fn (value Value) as_float() !f64 {
	if value.type_name == 'Float' {
		return value.float_data
	}
	if value.type_name == 'Integer' {
		return f64(value.int_data)
	}
	return error('expected Float or Integer, got ${value.type_name}')
}

// as_string_array returns a translated Ruby Array[String] or reports a type
// mismatch.
pub fn (value Value) as_string_array() ![]string {
	if value.type_name != 'Array' {
		return error('expected Array, got ${value.type_name}')
	}
	return value.string_array_data.clone()
}

// as_array returns a translated heterogeneous Ruby Array.
pub fn (value Value) as_array() ![]Value {
	if value.type_name != 'Array' {
		return error('expected Array, got ${value.type_name}')
	}
	if value.array_data.len > 0 {
		return value.array_data.clone()
	}
	return value.string_array_data.map(string_value(it))
}

// as_map returns a translated heterogeneous Ruby Hash.
pub fn (value Value) as_map() !map[string]Value {
	if value.type_name != 'Hash' {
		return error('expected Hash, got ${value.type_name}')
	}
	return value.map_data.clone()
}

// attribute returns a translated object's named source attribute.
pub fn (value Value) attribute(name string) !string {
	if name !in value.attributes {
		return error('${value.type_name} has no `${name}` attribute')
	}
	return value.attributes[name]
}

// unimplemented_fn marks a Ruby function whose body still needs a typed V
// translation. Keeping the original function name in the panic makes partial ports
// fail at the exact untranslated boundary.
pub fn unimplemented_fn(name string, args ...Value) Value {
	panic('unimplemented Ruby function `${name}` called with ${args.len} argument(s)')
}
