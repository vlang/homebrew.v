module bindata

import brew_runtime
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/array.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ArrayReadMode {
	initial_length
	read_until
	read_until_eof
}

enum ArrayElementKind {
	integer
	bitfield
	string
	nested_array
	generic
}

pub type ArrayInitialValueFn = fn(int) brew_runtime.Value

pub type ArrayReadUntilFn = fn(int, brew_runtime.Value, []brew_runtime.Value) bool

@[heap]
pub struct ArrayElement {
mut:
	base              &BaseObject
	class_value       brew_runtime.Value
	parameters        map[string]brew_runtime.Value
	kind              ArrayElementKind
	integer_spec      IntegerClass
	bitfield_spec     BitFieldClass
	nested            &ArrayObject = unsafe { nil }
	has_nested        bool
	integer_num_bytes bool = true
}

@[heap]
pub struct ArrayObject {
pub:
	type_name string
mut:
	base                    &BaseObject
	element_prototype       brew_runtime.Value
	element_type            brew_runtime.Value
	element_parameters      map[string]brew_runtime.Value
	elements_value          []&ArrayElement
	elements_initialized    bool
	read_mode               ArrayReadMode
	initial_length_value    brew_runtime.Value
	read_until_value        brew_runtime.Value
	initial_value_callback  ArrayInitialValueFn = unsafe { nil }
	has_initial_callback    bool
	read_until_callback     ArrayReadUntilFn = unsafe { nil }
	has_read_until_callback bool
}

fn array_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn array_parameter_parts(value brew_runtime.Value) (brew_runtime.Value, map[string]brew_runtime.Value) {
	if value.type_name == 'BinData::SanitizedPrototype' {
		prototype := sanitized_prototype_from_value(value)
		return prototype.object_class, prototype_object_parameters(prototype)
	}
	if value.type_name == 'Array' {
		parts := value.as_array() or { panic(err) }
		if parts.len == 0 {
			panic("parameter 'type' must specify an object type")
		}
		params := if parts.len > 1 {
			sanitize_map_from_value(parts[1])
		} else {
			map[string]brew_runtime.Value{}
		}
		return parts[0], params
	}
	if sanitize_is_base_instance(value) {
		return value, base_object_from_value(value).params()
	}
	return value, map[string]brew_runtime.Value{}
}

fn array_builtin_class(name string) brew_runtime.Value {
	canonical := name.trim_left(':').to_lower()
	mut accepted := new_accepted_parameters()
	mut processor := 'base'
	mut repr := 'BinData::${canonical[..1].to_upper()}${canonical[1..]}'
	if canonical == 'array' {
		accepted.add_mandatory(['type']) or { panic(err) }
		accepted.add_optional(['initial_length', 'read_until']) or { panic(err) }
		accepted.add_mutually_exclusive(['initial_length', 'read_until']) or { panic(err) }
		processor = 'array'
		repr = 'BinData::Array'
	} else if canonical in ['string', 'stringz', 'rest'] {
		accepted.add_optional(['length', 'read_length', 'initial_length', 'initial_value', 'pad_byte',
			'trim_padding']) or { panic(err) }
		repr = match canonical {
			'stringz' { 'BinData::Stringz' }
			'rest' { 'BinData::Rest' }
			else { 'BinData::String' }
		}
	}
	encoded := accepted_parameters_value(accepted)
	mut attributes := encoded.attributes.clone()
	attributes['arg_processor'] = processor
	attributes['parser_type'] = if canonical == 'array' { 'array' } else { 'primitive' }
	return brew_runtime.Value{
		type_name: 'BinData::Class'
		repr: repr
		int_data: encoded.int_data
		attributes: attributes
	}
}

fn array_sanitize_prototype(value brew_runtime.Value, hints map[string]brew_runtime.Value) !brew_runtime.Value {
	if value.type_name == 'BinData::SanitizedPrototype' {
		return value
	}
	object_type, object_parameters := array_parameter_parts(value)
	if prototype := new_sanitized_prototype(object_type, object_parameters, hints) {
		return sanitized_prototype_boundary_value(prototype)
	}
	canonical := object_type.as_string().trim_left(':').to_lower()
	if canonical !in ['array', 'string', 'stringz', 'rest'] {
		return error(object_type.as_string().trim_left(':'))
	}
	object_class := array_builtin_class(canonical)
	parameters := new_sanitized_parameters(object_parameters, object_class, hints)!
	prototype := &SanitizedPrototype{
		object_type: object_type
		hints: hints.clone()
		factory: array_nil_value()
		object_class: object_class
		object_parameters: parameters
		has_parameters: true
	}
	return sanitized_prototype_boundary_value(prototype)
}

fn array_dsl_parameters(object_class brew_runtime.Value) map[string]brew_runtime.Value {
	if _ := object_class.attributes['dsl_class_address'] {
		mut dsl_class := dsl_class_from_value(object_class)
		mut parser := dsl_parser_for_class(mut dsl_class, none) or {
			return map[string]brew_runtime.Value{}
		}
		return parser.dsl_params() or { map[string]brew_runtime.Value{} }
	}
	mut result := map[string]brew_runtime.Value{}
	for key in ['type', 'initial_length', 'read_until'] {
		if value := object_class.map_data[key] {
			result[key] = value
		}
	}
	return result
}

fn sanitize_array_parameter_map(object_class brew_runtime.Value, values map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut parameters := normalized_base_parameters(values)
	if 'initial_length' !in parameters && 'read_until' !in parameters {
		parameters['initial_length'] = brew_runtime.int_value(0)
	}
	if 'initial_length' in parameters && 'read_until' in parameters {
		return error("params 'initial_length' and 'read_until' are mutually exclusive in ${object_class.repr}")
	}
	for bad_key in ['length', 'read_length'] {
		if bad_key in parameters {
			eprintln(':${bad_key} is not used with ${object_class.repr}.  You probably want to change this to :initial_length')
		}
	}
	if length := parameters['initial_length'] {
		if !sanitize_value_converts_to_integer(length) {
			return error("parameter 'initial_length' in ${object_class.repr} must evaluate to an integer, got ${length.type_name}")
		}
	}
	for key, value in array_dsl_parameters(object_class) {
		parameters[key] = value
	}
	prototype := parameters['type'] or {
		return error("parameter 'type' must be specified in ${object_class.repr}")
	}
	parameters['type'] = array_sanitize_prototype(prototype, map[string]brew_runtime.Value{})!
	return parameters
}

pub fn array_class_value() brew_runtime.Value {
	return array_builtin_class('array')
}

fn array_eval_index_value(value brew_runtime.Value, index int) i64 {
	if value.type_name == 'Integer' {
		return value.int_data
	}
	if value.type_name == 'Float' {
		return i64(value.float_data)
	}
	name := value.as_string().trim_space().trim_left(':')
	if name == 'index' {
		return index
	}
	if name.starts_with('index + ') {
		return i64(index + name.all_after('index + ').int())
	}
	if name.starts_with('index - ') {
		return i64(index - name.all_after('index - ').int())
	}
	if offset := value.attributes['index_offset'] {
		return i64(index + offset.int())
	}
	return value.as_int() or { panic('parameter must evaluate to an integer, got ${value.type_name}') }
}

fn array_parent_index(object &ArrayObject) int {
	if object.base.has_parent {
		return (object.base.parent.attributes['array_index'] or { '0' }).int()
	}
	return 0
}

fn new_array_object_with_base(mut base BaseObject, parameters map[string]brew_runtime.Value) !&ArrayObject {
	prototype := parameters['type'] or { return error("parameter 'type' must be specified") }
	element_type, element_parameters := array_parameter_parts(prototype)
	mut mode := ArrayReadMode.initial_length
	mut initial_length := parameters['initial_length'] or { brew_runtime.int_value(0) }
	mut read_until := array_nil_value()
	if until := parameters['read_until'] {
		read_until = until
		mode = if until.as_string().trim_left(':') == 'eof' {
			.read_until_eof
		} else {
			.read_until
		}
		initial_length = array_nil_value()
	}
	base.parameters = parameters.clone()
	base.method_names = ['clear?', 'assign', 'snapshot', 'find_index', 'index', 'find_index_of',
		'push', '<<', 'unshift', 'concat', 'insert', '[]', 'slice', 'at', '[]=', 'first', 'last',
		'length', 'size', 'empty?', 'to_ary', 'each', 'debug_name_of', 'offset_of', 'do_write',
		'do_num_bytes']
	return &ArrayObject{
		type_name: if base.type_name.len > 0 { base.type_name } else { 'BinData::Array' }
		base: &base
		element_prototype: prototype
		element_type: element_type
		element_parameters: element_parameters
		read_mode: mode
		initial_length_value: initial_length
		read_until_value: read_until
	}
}

pub fn new_bindata_array(parameters map[string]brew_runtime.Value) !&ArrayObject {
	object_class := array_class_value()
	sanitized := sanitize_array_parameter_map(object_class, parameters)!
	mut base := new_base_object('BinData::Array', sanitized)
	return new_array_object_with_base(mut base, sanitized)!
}

pub fn (mut object ArrayObject) set_initial_value_callback(callback ArrayInitialValueFn) {
	object.initial_value_callback = callback
	object.has_initial_callback = true
}

pub fn (mut object ArrayObject) set_read_until_callback(callback ArrayReadUntilFn) {
	object.read_until_callback = callback
	object.has_read_until_callback = true
	object.read_mode = .read_until
}

fn array_object_value(object &ArrayObject) brew_runtime.Value {
	base_value := base_object_value(object.base)
	mut attributes := base_value.attributes.clone()
	attributes['array_object_address'] = u64(voidptr(object)).str()
	attributes['read_mode'] = object.read_mode.str()
	return brew_runtime.Value{
		...base_value
		type_name: object.type_name
		repr: if object.elements_initialized {
			'[${object.elements_value.len} elements]'
		} else {
			'[]'
		}
		attributes: attributes
	}
}

pub fn array_boundary_value(object &ArrayObject) brew_runtime.Value {
	return array_object_value(object)
}

fn array_object_from_value(value brew_runtime.Value) &ArrayObject {
	if address := value.attributes['array_object_address'] {
		return unsafe { &ArrayObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	parameters := sanitize_array_parameter_map(array_class_value(), base.parameters) or { panic(err) }
	return new_array_object_with_base(mut base, parameters) or { panic(err) }
}

fn array_type_name(value brew_runtime.Value) string {
	if value.type_name in ['BinData::IntegerClass', 'BinData::BitFieldClass',
		'BinData::FloatingPointClass'] {
		return value.repr
	}
	if value.type_name == 'BinData::Class' {
		return value.repr.all_after_last('::')
	}
	if sanitize_is_base_instance(value) {
		return value.type_name.all_after_last('::')
	}
	return value.as_string().trim_left(':').all_after_last('::')
}

fn array_integer_spec(type_name string) ?IntegerClass {
	mut name := type_name
	if name.len == 0 {
		return none
	}
	if name[0] >= `a` && name[0] <= `z` {
		name = camelize_registry_name(name.to_lower())
	}
	if name in ['Uint8', 'Int8'] {
		return define_integer_class(name, 8, .little, if name == 'Int8' {
			.signed
		} else {
			.unsigned
		}) or {
			return none
		}
	}
	return integer_class_for_name(name) or { return none }
}

fn array_bitfield_spec(type_name string) ?BitFieldClass {
	mut name := type_name
	if name.len == 0 {
		return none
	}
	if name[0] >= `a` && name[0] <= `z` {
		name = camelize_registry_name(name.to_lower())
	}
	return bitfield_class_for_name(name) or { return none }
}

fn array_parent_proxy(object &ArrayObject, index int, offset f64) brew_runtime.Value {
	parent := array_object_value(object)
	mut attributes := parent.attributes.clone()
	attributes['array_index'] = index.str()
	attributes['debug_name'] = 'obj[${index}]'
	attributes['offset'] = i64(math.floor(offset)).str()
	return brew_runtime.Value{
		...parent
		attributes: attributes
	}
}

fn new_array_element(mut object ArrayObject) &ArrayElement {
	type_name := array_type_name(object.element_type)
	mut base := new_base_object(type_name, object.element_parameters)
	mut element := &ArrayElement{
		base: base
		class_value: object.element_type
		parameters: object.element_parameters.clone()
		integer_spec: IntegerClass{}
		bitfield_spec: BitFieldClass{}
	}
	if spec := array_integer_spec(type_name) {
		element.kind = .integer
		element.integer_spec = spec
		base.do_num_bytes = spec.nbits / 8
	} else if spec := array_bitfield_spec(type_name) {
		element.kind = .bitfield
		element.bitfield_spec = spec
		element.integer_num_bytes = false
		nbits := if spec.dynamic {
			int(array_eval_index_value(element.parameters['nbits'] or { brew_runtime.int_value(0) }, object.elements_value.len))
		} else {
			spec.nbits
		}
		base.do_num_bytes = f64(nbits) / 8.0
	} else if type_name.to_lower() in ['string', 'stringz', 'rest'] {
		element.kind = .string
		if length := element.parameters['read_length'] {
			base.do_num_bytes = f64(array_eval_index_value(length, object.elements_value.len))
		} else if length := element.parameters['length'] {
			base.do_num_bytes = f64(array_eval_index_value(length, object.elements_value.len))
		}
	} else if type_name.to_lower() == 'array' {
		element.kind = .nested_array
		mut nested_base := new_base_object('BinData::Array', element.parameters)
		nested := new_array_object_with_base(mut nested_base, element.parameters) or { panic(err) }
		element.nested = nested
		element.has_nested = true
	} else {
		element.kind = .generic
		if num_bytes := element.parameters['num_bytes'] {
			base.do_num_bytes = num_bytes.as_float() or { panic(err) }
		} else if length := element.parameters['length'] {
			base.do_num_bytes = length.as_float() or { panic(err) }
		}
	}
	return element
}

fn array_element_num_bytes(element &ArrayElement) (f64, bool) {
	if element.has_nested {
		return array_sum_num_bytes(element.nested, element.nested.elements_value.len), element.integer_num_bytes
	}
	return element.base.do_num_bytes, element.integer_num_bytes
}

fn array_sum_num_bytes(object &ArrayObject, index int) f64 {
	mut sum := 0.0
	limit := if index < object.elements_value.len { index } else { object.elements_value.len }
	for element_index in 0 .. limit {
		nbytes, integer_bytes := array_element_num_bytes(object.elements_value[element_index])
		sum = if integer_bytes { math.ceil(sum) + nbytes } else { sum + nbytes }
	}
	return sum
}

fn array_sync_parents(mut object ArrayObject) {
	mut offset := 0.0
	for index, mut element in object.elements_value {
		proxy := array_parent_proxy(object, index, offset)
		element.base.parent = proxy
		element.base.has_parent = true
		if element.has_nested {
			element.nested.base.parent = proxy
			element.nested.base.has_parent = true
		}
		nbytes, integer_bytes := array_element_num_bytes(element)
		offset = if integer_bytes { math.ceil(offset) + nbytes } else { offset + nbytes }
	}
}

fn array_initial_length(object &ArrayObject) int {
	if object.read_mode != .initial_length || object.initial_length_value.type_name == 'NilClass' {
		return 0
	}
	length := int(array_eval_index_value(object.initial_length_value, array_parent_index(object)))
	return if length < 0 { 0 } else { length }
}

fn array_ensure_elements(mut object ArrayObject) {
	if object.elements_initialized {
		return
	}
	object.elements_value = []&ArrayElement{}
	object.elements_initialized = true
	for _ in 0 .. array_initial_length(object) {
		object.elements_value << new_array_element(mut object)
	}
	array_sync_parents(mut object)
}

fn array_extend(mut object ArrayObject, maximum_index int) {
	array_ensure_elements(mut object)
	maximum_length := maximum_index + 1
	for object.elements_value.len < maximum_length {
		object.elements_value << new_array_element(mut object)
	}
	array_sync_parents(mut object)
}

fn array_append(mut object ArrayObject) &ArrayElement {
	array_ensure_elements(mut object)
	element := new_array_element(mut object)
	object.elements_value << element
	array_sync_parents(mut object)
	return element
}

fn array_actual_index(length int, index int) int {
	return if index < 0 { length + index } else { index }
}

fn array_initial_snapshot(object &ArrayObject, element &ArrayElement, index int) brew_runtime.Value {
	if object.has_initial_callback {
		return object.initial_value_callback(index)
	}
	if value := element.parameters['initial_value'] {
		if value.type_name in ['Integer', 'Float', 'String', 'Bool'] {
			return value
		}
		return brew_runtime.int_value(array_eval_index_value(value, index))
	}
	return match element.kind {
		.integer, .bitfield { brew_runtime.int_value(0) }
		.string { brew_runtime.string_value('') }
		.nested_array {
			mut nested := element.nested
			array_snapshot(mut nested)
		}
		.generic { array_nil_value() }
	}
}

fn array_element_snapshot(object &ArrayObject, element &ArrayElement, index int) brew_runtime.Value {
	if element.has_nested {
		mut nested := element.nested
		return array_snapshot(mut nested)
	}
	if element.base.clear || element.base.snapshot_value.type_name == 'NilClass' {
		return array_initial_snapshot(object, element, index)
	}
	return element.base.snapshot_value
}

fn array_element_value(object &ArrayObject, element &ArrayElement, index int) brew_runtime.Value {
	snapshot := array_element_snapshot(object, element, index)
	base_value := base_object_value(element.base)
	mut attributes := base_value.attributes.clone()
	attributes['array_element_address'] = u64(voidptr(element)).str()
	attributes['array_index'] = index.str()
	attributes['bit_aligned'] = (element.kind == .bitfield).str()
	return brew_runtime.Value{
		...base_value
		type_name: array_type_name(element.class_value)
		repr: snapshot.repr
		int_data: i64(u64(voidptr(element)))
		array_data: snapshot.array_data
		map_data: snapshot.map_data
		attributes: attributes
	}
}

fn array_element_from_value(value brew_runtime.Value) ?&ArrayElement {
	address := value.attributes['array_element_address'] or { return none }
	return unsafe { &ArrayElement(voidptr(address.u64())) }
}

fn array_snapshot(mut object ArrayObject) brew_runtime.Value {
	array_ensure_elements(mut object)
	mut values := []brew_runtime.Value{cap: object.elements_value.len}
	for index, element in object.elements_value {
		values << array_element_snapshot(object, element, index)
	}
	return brew_runtime.array_value(values)
}

fn array_snapshot_from_pointer(object &ArrayObject) brew_runtime.Value {
	mut mutable_object := unsafe { &ArrayObject(voidptr(u64(voidptr(object)))) }
	return array_snapshot(mut mutable_object)
}

fn array_assign_element(mut object ArrayObject, index int, value brew_runtime.Value) brew_runtime.Value {
	array_extend(mut object, index)
	actual := array_actual_index(object.elements_value.len, index)
	if actual < 0 || actual >= object.elements_value.len {
		panic('index ${index} too small for array')
	}
	mut element := object.elements_value[actual]
	assigned := if nested := array_object_from_boundary(value) {
		array_snapshot_from_pointer(nested)
	} else if sanitize_is_base_instance(value) {
		base_object_from_value(value).snapshot()
	} else {
		value
	}
	if element.kind == .integer {
		clamped := clamp_integer(assigned.as_int() or { panic(err) }, element.integer_spec.nbits, element.integer_spec.signed) or { panic(err) }
		element.base.snapshot_value = brew_runtime.int_value(clamped)
	} else if element.kind == .bitfield {
		nbits := if element.bitfield_spec.dynamic {
			int(array_eval_index_value(element.parameters['nbits'] or { brew_runtime.int_value(0) }, actual))
		} else {
			element.bitfield_spec.nbits
		}
		clamped := clamp_bitfield_integer(assigned.as_int() or { panic(err) }, nbits, element.bitfield_spec.signed) or { panic(err) }
		element.base.snapshot_value = brew_runtime.int_value(clamped)
	} else {
		element.base.snapshot_value = assigned
	}
	element.base.assigned_value = element.base.snapshot_value
	element.base.has_assignment = true
	element.base.clear = false
	return element.base.snapshot_value
}

fn array_object_from_boundary(value brew_runtime.Value) ?&ArrayObject {
	address := value.attributes['array_object_address'] or { return none }
	return unsafe { &ArrayObject(voidptr(address.u64())) }
}

fn array_values_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	return values_equal(left, right)
}

fn array_find_snapshot(mut object ArrayObject, wanted brew_runtime.Value) int {
	array_ensure_elements(mut object)
	for index, element in object.elements_value {
		if array_values_equal(array_element_snapshot(object, element, index), wanted) {
			return index
		}
	}
	return -1
}

fn array_find_identity(mut object ArrayObject, wanted brew_runtime.Value) int {
	array_ensure_elements(mut object)
	if element := array_element_from_value(wanted) {
		for index, candidate in object.elements_value {
			if candidate == element {
				return index
			}
		}
	}
	if address := wanted.attributes['base_object_address'] {
		for index, candidate in object.elements_value {
			if u64(voidptr(candidate.base)) == address.u64() {
				return index
			}
		}
	}
	return -1
}

fn array_slice_start_length(mut object ArrayObject, start int, length int) brew_runtime.Value {
	array_ensure_elements(mut object)
	if length < 0 {
		return array_nil_value()
	}
	actual_start := array_actual_index(object.elements_value.len, start)
	if actual_start < 0 || actual_start > object.elements_value.len {
		return array_nil_value()
	}
	end := if actual_start + length < object.elements_value.len {
		actual_start + length
	} else {
		object.elements_value.len
	}
	mut values := []brew_runtime.Value{cap: end - actual_start}
	for index in actual_start .. end {
		values << array_element_value(object, object.elements_value[index], index)
	}
	return brew_runtime.array_value(values)
}

struct ArrayRange {
	start     int
	finish    int
	exclusive bool
}

fn array_range(value brew_runtime.Value) !ArrayRange {
	if value.type_name != 'Range' {
		return error('expected Range')
	}
	start_value := value.map_data['begin'] or { value.map_data['start'] or { return error('Range has no beginning') } }
	finish_value := value.map_data['end'] or { value.map_data['finish'] or { return error('Range has no end') } }
	return ArrayRange{
		start: int(start_value.as_int()!)
		finish: int(finish_value.as_int()!)
		exclusive: (value.attributes['exclude_end'] or { 'false' }).bool()
	}
}

pub fn array_range_value(start int, finish int, exclusive bool) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Range'
		repr: '${start}${if exclusive { '...' } else { '..' }}${finish}'
		map_data: {
			'begin': brew_runtime.int_value(start)
			'end':   brew_runtime.int_value(finish)
		}
		attributes: {
			'exclude_end': exclusive.str()
		}
	}
}

fn array_slice_range(mut object ArrayObject, range ArrayRange) brew_runtime.Value {
	array_ensure_elements(mut object)
	start := array_actual_index(object.elements_value.len, range.start)
	if start < 0 || start > object.elements_value.len {
		return array_nil_value()
	}
	mut finish := array_actual_index(object.elements_value.len, range.finish)
	if !range.exclusive {
		finish++
	}
	if finish < start {
		finish = start
	}
	return array_slice_start_length(mut object, start, finish - start)
}

fn array_element_read(mut object ArrayObject, mut element ArrayElement, index int, mut reader IORead) ! {
	match element.kind {
		.integer {
			bytes := reader.readbytes(element.integer_spec.nbits / 8)!
			value := integer_from_binary(bytes, element.integer_spec)!
			element.base.snapshot_value = brew_runtime.int_value(value)
		}
		.bitfield {
			nbits := if element.bitfield_spec.dynamic {
				int(array_eval_index_value(element.parameters['nbits'] or { brew_runtime.int_value(0) }, index))
			} else {
				element.bitfield_spec.nbits
			}
			raw := if element.bitfield_spec.endian == .big {
				reader.readbits_big(nbits)!
			} else {
				reader.readbits_little(nbits)!
			}
			element.base.snapshot_value = brew_runtime.int_value(bitfield_unsigned_to_integer(raw, nbits, element.bitfield_spec.signed)!)
		}
		.string {
			nbytes := int(element.base.do_num_bytes)
			if nbytes <= 0 {
				return error('array string element requires read_length')
			}
			element.base.snapshot_value = brew_runtime.string_value(reader.readbytes(nbytes)!.bytestr())
		}
		.nested_array {
			array_do_read(mut element.nested, mut reader)!
			mut nested := element.nested
			element.base.snapshot_value = array_snapshot(mut nested)
		}
		.generic {
			nbytes := int(math.ceil(element.base.do_num_bytes))
			if nbytes <= 0 {
				return error('array element consumes no bytes')
			}
			bytes := reader.readbytes(nbytes)!
			element.base.binary_value = bytes.bytestr()
			element.base.snapshot_value = brew_runtime.string_value(element.base.binary_value)
		}
	}
	element.base.assigned_value = element.base.snapshot_value
	element.base.has_assignment = true
	element.base.clear = false
	object.base.clear = false
}

fn array_element_write(object &ArrayObject, element &ArrayElement, index int, mut writer IOWrite) ! {
	value := array_element_snapshot(object, element, index)
	match element.kind {
		.integer {
			writer.writebytes(integer_to_binary(value.as_int()!, element.integer_spec)!)!
		}
		.bitfield {
			nbits := if element.bitfield_spec.dynamic {
				int(array_eval_index_value(element.parameters['nbits'] or { brew_runtime.int_value(0) }, index))
			} else {
				element.bitfield_spec.nbits
			}
			raw := bitfield_integer_to_unsigned(value.as_int()!, nbits, element.bitfield_spec.signed)!
			if element.bitfield_spec.endian == .big {
				writer.writebits_big(raw, nbits)!
			} else {
				writer.writebits_little(raw, nbits)!
			}
		}
		.string {
			mut bytes := value.as_string().bytes()
			nbytes := int(element.base.do_num_bytes)
			if nbytes > 0 {
				if bytes.len > nbytes {
					bytes = bytes[..nbytes].clone()
				} else if bytes.len < nbytes {
					pad := u8((element.parameters['pad_byte'] or { brew_runtime.int_value(0) }).int_data)
					bytes << []u8{len: nbytes - bytes.len, init: pad}
				}
			}
			writer.writebytes(bytes)!
		}
		.nested_array {
			array_do_write(element.nested, mut writer)!
		}
		.generic {
			writer.writebytes(if element.base.binary_value.len > 0 {
				element.base.binary_value.bytes()
			} else {
				value.as_string().bytes()
			})!
		}
	}
}

fn array_do_write(object &ArrayObject, mut writer IOWrite) ! {
	for index, element in object.elements_value {
		array_element_write(object, element, index, mut writer)!
	}
}

fn array_read_condition(object &ArrayObject, index int) bool {
	if object.has_read_until_callback {
		element := array_element_snapshot(object, object.elements_value[index], index)
		mut values := []brew_runtime.Value{cap: object.elements_value.len}
		for current, candidate in object.elements_value {
			values << array_element_snapshot(object, candidate, current)
		}
		return object.read_until_callback(index, element, values)
	}
	if object.read_until_value.type_name == 'Bool' {
		return object.read_until_value.bool_data
	}
	if expected := object.read_until_value.attributes['element_equals'] {
		return array_element_snapshot(object, object.elements_value[index], index).repr == expected
	}
	return false
}

fn array_do_read(mut object ArrayObject, mut reader IORead) ! {
	match object.read_mode {
		.initial_length {
			array_ensure_elements(mut object)
			for index, mut element in object.elements_value {
				array_element_read(mut object, mut element, index, mut reader)!
			}
		}
		.read_until {
			for {
				mut element := array_append(mut object)
				index := object.elements_value.len - 1
				array_element_read(mut object, mut element, index, mut reader)!
				if array_read_condition(object, index) {
					break
				}
			}
		}
		.read_until_eof {
			for {
				mut element := array_append(mut object)
				index := object.elements_value.len - 1
				array_element_read(mut object, mut element, index, mut reader) or {
					object.elements_value.pop()
					array_sync_parents(mut object)
					break
				}
			}
		}
	}
	object.base.snapshot_value = array_snapshot(mut object)
	object.base.binary_value = ''
	object.base.clear = false
}

fn array_boundary_receiver(args []brew_runtime.Value, method string) &ArrayObject {
	if args.len == 0 {
		panic('Array#${method} requires a receiver')
	}
	return array_object_from_value(args[0])
}

// Ruby method `initialize_shared_instance` at line 61.
pub fn ruby_array_l61_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Array#initialize_shared_instance requires a receiver')
	}
	if object := array_object_from_boundary(args[0]) {
		return array_object_value(object)
	}
	mut base := base_object_from_value(args[0])
	parameters := sanitize_array_parameter_map(array_class_value(), base.parameters) or { panic(err) }
	return array_object_value(new_array_object_with_base(mut base, parameters) or { panic(err) })
}

// Ruby method `initialize_instance` at line 74.
pub fn ruby_array_l74_d2_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'initialize_instance')
	object.elements_value = []&ArrayElement{}
	object.elements_initialized = false
	object.base.clear = true
	object.base.snapshot_value = array_nil_value()
	object.base.binary_value = ''
	return array_nil_value()
}

// Ruby method `clear?` at line 78.
pub fn ruby_array_l78_d3_clear(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'clear?')
	if !object.elements_initialized {
		return brew_runtime.bool_value(true)
	}
	return brew_runtime.bool_value(object.elements_value.all(it.base.clear))
}

// Ruby method `assign(array)` at line 82.
pub fn ruby_array_l82_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#assign requires an array')
	}
	mut object := array_boundary_receiver(args, 'assign')
	if other := array_object_from_boundary(args[1]) {
		if other == object {
			return array_nil_value()
		}
	}
	if args[1].type_name == 'NilClass' {
		panic("can't set a nil value for ${ruby_base_l206_d25_debug_name(args[0]).as_string()}")
	}
	values := if other := array_object_from_boundary(args[1]) {
		array_snapshot_from_pointer(other).as_array() or { panic(err) }
	} else {
		args[1].as_array() or { panic(err) }
	}
	object.elements_value = []&ArrayElement{}
	object.elements_initialized = true
	for value in values {
		array_append(mut object)
		array_assign_element(mut object, object.elements_value.len - 1, value)
	}
	object.base.clear = false
	return array_object_value(object)
}

// Ruby method `snapshot` at line 90.
pub fn ruby_array_l90_d5_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'snapshot')
	return array_snapshot(mut object)
}

// Ruby method `find_index(obj)` at line 94.
pub fn ruby_array_l94_d6_find_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#find_index requires an object')
	}
	mut object := array_boundary_receiver(args, 'find_index')
	index := array_find_snapshot(mut object, if element := array_element_from_value(args[1]) {
		array_element_snapshot(object, element, (args[1].attributes['array_index'] or { '0' }).int())
	} else {
		args[1]
	})
	return if index < 0 { array_nil_value() } else { brew_runtime.int_value(index) }
}

// Ruby alias `alias index find_index` at line 97.
pub fn ruby_array_l97_d7_index(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l94_d6_find_index(...args)
}

// Ruby method `find_index_of(obj)` at line 102.
pub fn ruby_array_l102_d8_find_index_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#find_index_of requires an object')
	}
	mut object := array_boundary_receiver(args, 'find_index_of')
	index := array_find_identity(mut object, args[1])
	return if index < 0 { array_nil_value() } else { brew_runtime.int_value(index) }
}

// Ruby method `push(*args)` at line 106.
pub fn ruby_array_l106_d9_push(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Array#push requires a receiver')
	}
	mut insert_args := [args[0], brew_runtime.int_value(-1)]
	insert_args << args[1..]
	return ruby_array_l122_d13_insert(...insert_args)
}

// Ruby alias `alias << push` at line 110.
pub fn ruby_array_l110_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l106_d9_push(...args)
}

// Ruby method `unshift(*args)` at line 112.
pub fn ruby_array_l112_d11_unshift(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Array#unshift requires a receiver')
	}
	mut insert_args := [args[0], brew_runtime.int_value(0)]
	insert_args << args[1..]
	return ruby_array_l122_d13_insert(...insert_args)
}

// Ruby method `concat(array)` at line 117.
pub fn ruby_array_l117_d12_concat(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#concat requires an array')
	}
	values := if object := array_object_from_boundary(args[1]) {
		array_snapshot_from_pointer(object).as_array() or { panic(err) }
	} else {
		args[1].as_array() or { panic(err) }
	}
	mut insert_args := [args[0], brew_runtime.int_value(-1)]
	insert_args << values
	return ruby_array_l122_d13_insert(...insert_args)
}

// Ruby method `insert(index, *objs)` at line 122.
pub fn ruby_array_l122_d13_insert(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#insert requires an index')
	}
	mut object := array_boundary_receiver(args, 'insert')
	index := int(args[1].as_int() or { panic(err) })
	array_extend(mut object, index - 1)
	length := object.elements_value.len
	abs_index := if index >= 0 { index } else { index + 1 + length }
	if abs_index < 0 || abs_index > length {
		panic('index ${index} too small for array; minimum: ${-length - 1}')
	}
	mut inserted := []&ArrayElement{cap: args.len - 2}
	for _ in args[2..] {
		inserted << new_array_element(mut object)
	}
	mut combined := []&ArrayElement{cap: length + inserted.len}
	combined << object.elements_value[..abs_index]
	combined << inserted
	combined << object.elements_value[abs_index..]
	object.elements_value = combined
	array_sync_parents(mut object)
	for relative, value in args[2..] {
		array_assign_element(mut object, abs_index + relative, value)
	}
	return array_object_value(object)
}

// Ruby method `[](arg1, arg2 = nil)` at line 139.
pub fn ruby_array_l139_d14_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#[] requires an index or range')
	}
	if args[1].type_name == 'Integer' && (args.len < 3 || args[2].type_name == 'NilClass') {
		return ruby_array_l153_d16_slice_index(args[0], args[1])
	}
	if args[1].type_name == 'Integer' && args.len > 2 && args[2].type_name == 'Integer' {
		return ruby_array_l158_d17_slice_start_length(args[0], args[1], args[2])
	}
	if args[1].type_name == 'Range' && (args.len < 3 || args[2].type_name == 'NilClass') {
		return ruby_array_l162_d18_slice_range(args[0], args[1])
	}
	if args[1].type_name != 'Integer' {
		panic("can't convert ${args[1].type_name} into Integer")
	}
	second := if args.len > 2 { args[2].type_name } else { 'NilClass' }
	panic("can't convert ${second} into Integer")
}

// Ruby alias `alias slice []` at line 151.
pub fn ruby_array_l151_d15_slice(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l139_d14_anonymous(...args)
}

// Ruby method `slice_index(index)` at line 153.
pub fn ruby_array_l153_d16_slice_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#slice_index requires an index')
	}
	mut object := array_boundary_receiver(args, 'slice_index')
	index := int(args[1].as_int() or { panic(err) })
	array_extend(mut object, index)
	actual := array_actual_index(object.elements_value.len, index)
	if actual < 0 || actual >= object.elements_value.len {
		return array_nil_value()
	}
	return array_element_value(object, object.elements_value[actual], actual)
}

// Ruby method `slice_start_length(start, length)` at line 158.
pub fn ruby_array_l158_d17_slice_start_length(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Array#slice_start_length requires start and length')
	}
	mut object := array_boundary_receiver(args, 'slice_start_length')
	return array_slice_start_length(mut object, int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or { panic(err) }))
}

// Ruby method `slice_range(range)` at line 162.
pub fn ruby_array_l162_d18_slice_range(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#slice_range requires a range')
	}
	mut object := array_boundary_receiver(args, 'slice_range')
	return array_slice_range(mut object, array_range(args[1]) or { panic(err) })
}

// Ruby method `at(index)` at line 169.
pub fn ruby_array_l169_d19_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#at requires an index')
	}
	mut object := array_boundary_receiver(args, 'at')
	array_ensure_elements(mut object)
	actual := array_actual_index(object.elements_value.len, int(args[1].as_int() or { panic(err) }))
	if actual < 0 || actual >= object.elements_value.len {
		return array_nil_value()
	}
	return array_element_value(object, object.elements_value[actual], actual)
}

// Ruby method `[]=(index, value)` at line 174.
pub fn ruby_array_l174_d20_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Array#[]= requires index and value')
	}
	mut object := array_boundary_receiver(args, '[]=')
	return array_assign_element(mut object, int(args[1].as_int() or { panic(err) }), args[2])
}

// Ruby method `first(n = nil)` at line 182.
pub fn ruby_array_l182_d21_first(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'first')
	array_ensure_elements(mut object)
	if args.len < 2 || args[1].type_name == 'NilClass' {
		if object.elements_value.len == 0 {
			return array_nil_value()
		}
		return ruby_array_l153_d16_slice_index(args[0], brew_runtime.int_value(0))
	}
	return ruby_array_l158_d17_slice_start_length(args[0], brew_runtime.int_value(0), args[1])
}

// Ruby method `last(n = nil)` at line 196.
pub fn ruby_array_l196_d22_last(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'last')
	array_ensure_elements(mut object)
	if args.len < 2 || args[1].type_name == 'NilClass' {
		return ruby_array_l153_d16_slice_index(args[0], brew_runtime.int_value(-1))
	}
	mut count := int(args[1].as_int() or { panic(err) })
	if count > object.elements_value.len {
		count = object.elements_value.len
	}
	return ruby_array_l158_d17_slice_start_length(args[0], brew_runtime.int_value(-count), brew_runtime.int_value(count))
}

// Ruby method `length` at line 205.
pub fn ruby_array_l205_d23_length(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'length')
	array_ensure_elements(mut object)
	return brew_runtime.int_value(object.elements_value.len)
}

// Ruby alias `alias size length` at line 208.
pub fn ruby_array_l208_d24_size(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l205_d23_length(...args)
}

// Ruby method `empty?` at line 210.
pub fn ruby_array_l210_d25_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_array_l205_d23_length(...args).int_data == 0)
}

// Ruby method `to_ary` at line 215.
pub fn ruby_array_l215_d26_to_ary(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l219_d27_each(...args)
}

// Ruby method `each` at line 219.
pub fn ruby_array_l219_d27_each(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'each')
	array_ensure_elements(mut object)
	mut values := []brew_runtime.Value{cap: object.elements_value.len}
	for index, element in object.elements_value {
		values << array_element_value(object, element, index)
	}
	return brew_runtime.array_value(values)
}

// Ruby method `debug_name_of(child) # :nodoc:` at line 223.
pub fn ruby_array_l223_d28_debug_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#debug_name_of requires a child')
	}
	mut object := array_boundary_receiver(args, 'debug_name_of')
	index := array_find_identity(mut object, args[1])
	name := ruby_base_l206_d25_debug_name(args[0]).as_string()
	return brew_runtime.string_value('${name}[${if index < 0 { '' } else { index.str() }}]')
}

// Ruby method `offset_of(child) # :nodoc:` at line 228.
pub fn ruby_array_l228_d29_offset_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#offset_of requires a child')
	}
	mut object := array_boundary_receiver(args, 'offset_of')
	index := array_find_identity(mut object, args[1])
	if index < 0 {
		panic('child is not an element of array')
	}
	sum := array_sum_num_bytes(object, index)
	child := object.elements_value[index]
	offset := if child.kind == .bitfield { math.floor(sum) } else { math.ceil(sum) }
	return brew_runtime.int_value(i64(offset))
}

// Ruby method `do_write(io) # :nodoc:` at line 235.
pub fn ruby_array_l235_d30_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#do_write requires IO')
	}
	mut object := array_boundary_receiver(args, 'do_write')
	array_ensure_elements(mut object)
	mut writer := io_write_from_value(args[1])
	array_do_write(object, mut writer) or { panic(err) }
	return array_nil_value()
}

// Ruby method `do_num_bytes # :nodoc:` at line 239.
pub fn ruby_array_l239_d31_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'do_num_bytes')
	array_ensure_elements(mut object)
	sum := array_sum_num_bytes(object, object.elements_value.len)
	return if sum == math.floor(sum) {
		brew_runtime.int_value(i64(sum))
	} else {
		brew_runtime.float_value(sum)
	}
}

// Ruby method `extend_array(max_index)` at line 246.
pub fn ruby_array_l246_d32_extend_array(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#extend_array requires a maximum index')
	}
	mut object := array_boundary_receiver(args, 'extend_array')
	array_extend(mut object, int(args[1].as_int() or { panic(err) }))
	return array_nil_value()
}

// Ruby method `elements` at line 253.
pub fn ruby_array_l253_d33_elements(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l219_d27_each(...args)
}

// Ruby method `append_new_element` at line 257.
pub fn ruby_array_l257_d34_append_new_element(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'append_new_element')
	element := array_append(mut object)
	return array_element_value(object, element, object.elements_value.len - 1)
}

// Ruby method `new_element` at line 263.
pub fn ruby_array_l263_d35_new_element(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := array_boundary_receiver(args, 'new_element')
	array_ensure_elements(mut object)
	element := new_array_element(mut object)
	return array_element_value(object, element, object.elements_value.len)
}

// Ruby method `sum_num_bytes_for_all_elements` at line 267.
pub fn ruby_array_l267_d36_sum_num_bytes_for_all_elements(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l239_d31_do_num_bytes(...args)
}

// Ruby method `sum_num_bytes_below_index(index)` at line 271.
pub fn ruby_array_l271_d37_sum_num_bytes_below_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#sum_num_bytes_below_index requires an index')
	}
	mut object := array_boundary_receiver(args, 'sum_num_bytes_below_index')
	array_ensure_elements(mut object)
	sum := array_sum_num_bytes(object, int(args[1].as_int() or { panic(err) }))
	return if sum == math.floor(sum) {
		brew_runtime.int_value(i64(sum))
	} else {
		brew_runtime.float_value(sum)
	}
}

// Ruby method `do_read(io)` at line 285.
pub fn ruby_array_l285_d38_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#ReadUntilPlugin#do_read requires IO')
	}
	mut object := array_boundary_receiver(args, 'do_read')
	object.read_mode = .read_until
	mut reader := io_read_from_value(args[1])
	array_do_read(mut object, mut reader) or { panic(err) }
	return array_nil_value()
}

// Ruby method `do_read(io)` at line 297.
pub fn ruby_array_l297_d39_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#ReadUntilEOFPlugin#do_read requires IO')
	}
	mut object := array_boundary_receiver(args, 'do_read')
	object.read_mode = .read_until_eof
	mut reader := io_read_from_value(args[1])
	array_do_read(mut object, mut reader) or { panic(err) }
	return array_nil_value()
}

// Ruby method `do_read(io)` at line 312.
pub fn ruby_array_l312_d40_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Array#InitialLengthPlugin#do_read requires IO')
	}
	mut object := array_boundary_receiver(args, 'do_read')
	object.read_mode = .initial_length
	mut reader := io_read_from_value(args[1])
	array_do_read(mut object, mut reader) or { panic(err) }
	return array_nil_value()
}

// Ruby method `elements` at line 316.
pub fn ruby_array_l316_d41_elements(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_array_l219_d27_each(...args)
}

// Ruby method `sanitize_parameters!(obj_class, params) # :nodoc:` at line 330.
pub fn ruby_array_l330_d42_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('ArrayArgProcessor#sanitize_parameters! requires parameters')
	}
	object_class := if args.len >= 3 { args[1] } else { array_class_value() }
	params_value := args[args.len - 1]
	if params_value.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params_value)
		if !parameters.has_at_least_one_of(['initial_length', 'read_until']) {
			parameters.values['initial_length'] = brew_runtime.int_value(0)
		}
		parameters.warn_replacement_parameter('length', 'initial_length')
		parameters.warn_replacement_parameter('read_length', 'initial_length')
		parameters.must_be_integer(['initial_length']) or { panic(err) }
		for key, value in array_dsl_parameters(object_class) {
			parameters.values[key] = value
		}
		if raw := parameters.values['type'] {
			parameters.values['type'] = array_sanitize_prototype(raw, parameters.hints()) or { panic(err) }
		}
		return sanitized_parameters_boundary_value(parameters)
	}
	values := params_value.as_map() or { panic(err) }
	return brew_runtime.map_value(sanitize_array_parameter_map(object_class, values) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # An Array is a list of data objects of the same type.
// 6:   #
// 7:   #   require 'bindata'
// 8:   #
// 9:   #   data = "\x03\x04\x05\x06\x07\x08\x09"
// 10:   #
// 11:   #   obj = BinData::Array.new(type: :int8, initial_length: 6)
// 12:   #   obj.read(data) #=> [3, 4, 5, 6, 7, 8]
// 13:   #
// 14:   #   obj = BinData::Array.new(type: :int8,
// 15:   #                            read_until: -> { index == 1 })
// 16:   #   obj.read(data) #=> [3, 4]
// 17:   #
// 18:   #   obj = BinData::Array.new(type: :int8,
// 19:   #                            read_until: -> { element >= 6 })
// 20:   #   obj.read(data) #=> [3, 4, 5, 6]
// 21:   #
// 22:   #   obj = BinData::Array.new(type: :int8,
// 23:   #           read_until: -> { array[index] + array[index - 1] == 13 })
// 24:   #   obj.read(data) #=> [3, 4, 5, 6, 7]
// 25:   #
// 26:   #   obj = BinData::Array.new(type: :int8, read_until: :eof)
// 27:   #   obj.read(data) #=> [3, 4, 5, 6, 7, 8, 9]
// 28:   #
// 29:   # == Parameters
// 30:   #
// 31:   # Parameters may be provided at initialisation to control the behaviour of
// 32:   # an object.  These params are:
// 33:   #
// 34:   # <tt>:type</tt>::           The symbol representing the data type of the
// 35:   #                            array elements.  If the type is to have params
// 36:   #                            passed to it, then it should be provided as
// 37:   #                            <tt>[type_symbol, hash_params]</tt>.
// 38:   # <tt>:initial_length</tt>:: The initial length of the array.
// 39:   # <tt>:read_until</tt>::     While reading, elements are read until this
// 40:   #                            condition is true.  This is typically used to
// 41:   #                            read an array until a sentinel value is found.
// 42:   #                            The variables +index+, +element+ and +array+
// 43:   #                            are made available to any lambda assigned to
// 44:   #                            this parameter.  If the value of this parameter
// 45:   #                            is the symbol :eof, then the array will read
// 46:   #                            as much data from the stream as possible.
// 47:   #
// 48:   # Each data object in an array has the variable +index+ made available
// 49:   # to any lambda evaluated as a parameter of that data object.
// 50:   class Array < BinData::Base
// 51:     extend DSLMixin
// 52:     include Enumerable
// 53:
// 54:     dsl_parser    :array
// 55:     arg_processor :array
// 56:
// 57:     mandatory_parameter :type
// 58:     optional_parameters :initial_length, :read_until
// 59:     mutually_exclusive_parameters :initial_length, :read_until
// 60:
// 61:     def initialize_shared_instance
// 62:       @element_prototype = get_parameter(:type)
// 63:       if get_parameter(:read_until) == :eof
// 64:         extend ReadUntilEOFPlugin
// 65:       elsif has_parameter?(:read_until)
// 66:         extend ReadUntilPlugin
// 67:       elsif has_parameter?(:initial_length)
// 68:         extend InitialLengthPlugin
// 69:       end
// 70:
// 71:       super
// 72:     end
// 73:
// 74:     def initialize_instance
// 75:       @elements = nil
// 76:     end
// 77:
// 78:     def clear?
// 79:       @elements.nil? || elements.all?(&:clear?)
// 80:     end
// 81:
// 82:     def assign(array)
// 83:       return if self.equal?(array)  # prevent self assignment
// 84:       raise ArgumentError, "can't set a nil value for #{debug_name}" if array.nil?
// 85:
// 86:       @elements = []
// 87:       concat(array)
// 88:     end
// 89:
// 90:     def snapshot
// 91:       elements.collect(&:snapshot)
// 92:     end
// 93:
// 94:     def find_index(obj)
// 95:       elements.index(obj)
// 96:     end
// 97:     alias index find_index
// 98:
// 99:     # Returns the first index of +obj+ in self.
// 100:     #
// 101:     # Uses equal? for the comparator.
// 102:     def find_index_of(obj)
// 103:       elements.index { |el| el.equal?(obj) }
// 104:     end
// 105:
// 106:     def push(*args)
// 107:       insert(-1, *args)
// 108:       self
// 109:     end
// 110:     alias << push
// 111:
// 112:     def unshift(*args)
// 113:       insert(0, *args)
// 114:       self
// 115:     end
// 116:
// 117:     def concat(array)
// 118:       insert(-1, *array.to_ary)
// 119:       self
// 120:     end
// 121:
// 122:     def insert(index, *objs)
// 123:       extend_array(index - 1)
// 124:       abs_index = (index >= 0) ? index : index + 1 + length
// 125:
// 126:       # insert elements before...
// 127:       new_elements = objs.map { new_element }
// 128:       elements.insert(index, *new_elements)
// 129:
// 130:       # ...assigning values
// 131:       objs.each_with_index do |obj, i|
// 132:         self[abs_index + i] = obj
// 133:       end
// 134:
// 135:       self
// 136:     end
// 137:
// 138:     # Returns the element at +index+.
// 139:     def [](arg1, arg2 = nil)
// 140:       if arg1.respond_to?(:to_int) && arg2.nil?
// 141:         slice_index(arg1.to_int)
// 142:       elsif arg1.respond_to?(:to_int) && arg2.respond_to?(:to_int)
// 143:         slice_start_length(arg1.to_int, arg2.to_int)
// 144:       elsif arg1.is_a?(Range) && arg2.nil?
// 145:         slice_range(arg1)
// 146:       else
// 147:         raise TypeError, "can't convert #{arg1} into Integer" unless arg1.respond_to?(:to_int)
// 148:         raise TypeError, "can't convert #{arg2} into Integer" unless arg2.respond_to?(:to_int)
// 149:       end
// 150:     end
// 151:     alias slice []
// 152:
// 153:     def slice_index(index)
// 154:       extend_array(index)
// 155:       at(index)
// 156:     end
// 157:
// 158:     def slice_start_length(start, length)
// 159:       elements[start, length]
// 160:     end
// 161:
// 162:     def slice_range(range)
// 163:       elements[range]
// 164:     end
// 165:     private :slice_index, :slice_start_length, :slice_range
// 166:
// 167:     # Returns the element at +index+.  Unlike +slice+, if +index+ is out
// 168:     # of range the array will not be automatically extended.
// 169:     def at(index)
// 170:       elements[index]
// 171:     end
// 172:
// 173:     # Sets the element at +index+.
// 174:     def []=(index, value)
// 175:       extend_array(index)
// 176:       elements[index].assign(value)
// 177:     end
// 178:
// 179:     # Returns the first element, or the first +n+ elements, of the array.
// 180:     # If the array is empty, the first form returns nil, and the second
// 181:     # form returns an empty array.
// 182:     def first(n = nil)
// 183:       if n.nil? && empty?
// 184:         # explicitly return nil as arrays grow automatically
// 185:         nil
// 186:       elsif n.nil?
// 187:         self[0]
// 188:       else
// 189:         self[0, n]
// 190:       end
// 191:     end
// 192:
// 193:     # Returns the last element, or the last +n+ elements, of the array.
// 194:     # If the array is empty, the first form returns nil, and the second
// 195:     # form returns an empty array.
// 196:     def last(n = nil)
// 197:       if n.nil?
// 198:         self[-1]
// 199:       else
// 200:         n = length if n > length
// 201:         self[-n, n]
// 202:       end
// 203:     end
// 204:
// 205:     def length
// 206:       elements.length
// 207:     end
// 208:     alias size length
// 209:
// 210:     def empty?
// 211:       length.zero?
// 212:     end
// 213:
// 214:     # Allow this object to be used in array context.
// 215:     def to_ary
// 216:       collect { |el| el }
// 217:     end
// 218:
// 219:     def each
// 220:       elements.each { |el| yield el }
// 221:     end
// 222:
// 223:     def debug_name_of(child) # :nodoc:
// 224:       index = find_index_of(child)
// 225:       "#{debug_name}[#{index}]"
// 226:     end
// 227:
// 228:     def offset_of(child) # :nodoc:
// 229:       index = find_index_of(child)
// 230:       sum = sum_num_bytes_below_index(index)
// 231:
// 232:       child.bit_aligned? ? sum.floor : sum.ceil
// 233:     end
// 234:
// 235:     def do_write(io) # :nodoc:
// 236:       elements.each { |el| el.do_write(io) }
// 237:     end
// 238:
// 239:     def do_num_bytes # :nodoc:
// 240:       sum_num_bytes_for_all_elements
// 241:     end
// 242:
// 243:     #---------------
// 244:     private
// 245:
// 246:     def extend_array(max_index)
// 247:       max_length = max_index + 1
// 248:       while elements.length < max_length
// 249:         append_new_element
// 250:       end
// 251:     end
// 252:
// 253:     def elements
// 254:       @elements ||= []
// 255:     end
// 256:
// 257:     def append_new_element
// 258:       element = new_element
// 259:       elements << element
// 260:       element
// 261:     end
// 262:
// 263:     def new_element
// 264:       @element_prototype.instantiate(nil, self)
// 265:     end
// 266:
// 267:     def sum_num_bytes_for_all_elements
// 268:       sum_num_bytes_below_index(length)
// 269:     end
// 270:
// 271:     def sum_num_bytes_below_index(index)
// 272:       (0...index).inject(0) do |sum, i|
// 273:         nbytes = elements[i].do_num_bytes
// 274:
// 275:         if nbytes.is_a?(Integer)
// 276:           sum.ceil + nbytes
// 277:         else
// 278:           sum + nbytes
// 279:         end
// 280:       end
// 281:     end
// 282:
// 283:     # Logic for the :read_until parameter
// 284:     module ReadUntilPlugin
// 285:       def do_read(io)
// 286:         loop do
// 287:           element = append_new_element
// 288:           element.do_read(io)
// 289:           variables = { index: self.length - 1, element: self.last, array: self }
// 290:           break if eval_parameter(:read_until, variables)
// 291:         end
// 292:       end
// 293:     end
// 294:
// 295:     # Logic for the read_until: :eof parameter
// 296:     module ReadUntilEOFPlugin
// 297:       def do_read(io)
// 298:         loop do
// 299:           element = append_new_element
// 300:           begin
// 301:             element.do_read(io)
// 302:           rescue EOFError, IOError
// 303:             elements.pop
// 304:             break
// 305:           end
// 306:         end
// 307:       end
// 308:     end
// 309:
// 310:     # Logic for the :initial_length parameter
// 311:     module InitialLengthPlugin
// 312:       def do_read(io)
// 313:         elements.each { |el| el.do_read(io) }
// 314:       end
// 315:
// 316:       def elements
// 317:         if @elements.nil?
// 318:           @elements = []
// 319:           eval_parameter(:initial_length).times do
// 320:             @elements << new_element
// 321:           end
// 322:         end
// 323:
// 324:         @elements
// 325:       end
// 326:     end
// 327:   end
// 328:
// 329:   class ArrayArgProcessor < BaseArgProcessor
// 330:     def sanitize_parameters!(obj_class, params) # :nodoc:
// 331:       # ensure one of :initial_length and :read_until exists
// 332:       unless params.has_at_least_one_of?(:initial_length, :read_until)
// 333:         params[:initial_length] = 0
// 334:       end
// 335:
// 336:       params.warn_replacement_parameter(:length, :initial_length)
// 337:       params.warn_replacement_parameter(:read_length, :initial_length)
// 338:       params.must_be_integer(:initial_length)
// 339:
// 340:       params.merge!(obj_class.dsl_params)
// 341:       params.sanitize_object_prototype(:type)
// 342:     end
// 343:   end
// 344: end
