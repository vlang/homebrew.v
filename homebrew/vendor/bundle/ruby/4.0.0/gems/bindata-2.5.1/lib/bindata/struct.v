module bindata

import brew_runtime
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/struct.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SanitizedStructField {
pub:
	field_type brew_runtime.Value
	name       string
	has_name   bool
	parameters map[string]brew_runtime.Value
}

@[heap]
pub struct StructFieldObject {
pub:
	definition SanitizedStructField
mut:
	base              &BaseObject
	integer_num_bytes bool
	bit_aligned       bool
	delayed_io        bool
	instantiated      bool
}

@[heap]
pub struct StructObject {
pub:
	type_name string
mut:
	base         &BaseObject
	fields       []&StructFieldObject
	field_names  []string
	named_fields []bool
	hidden       []string
	byte_aligned bool
}

fn struct_reserved_field_names() []string {
	// Hash.instance_methods on Homebrew's portable Ruby 4.0, followed by the
	// exact language and BinData parameter names listed by Struct::RESERVED.
	return ['!', '!=', '!~', '<', '<=', '<=>', '==', '===', '>', '>=', '[]', '[]=', '__id__',
		'__send__', 'alias', 'all?', 'and', 'any?', 'array', 'assoc', 'begin', 'break', 'byte_align',
		'case', 'chain', 'choices', 'chunk', 'chunk_while', 'class', 'clear', 'clone', 'collect',
		'collect_concat', 'compact', 'compact!', 'compare_by_identity', 'compare_by_identity?',
		'copy_on_change', 'count', 'cycle', 'deconstruct_keys', 'def', 'default', 'default=',
		'default_proc', 'default_proc=', 'define_singleton_method', 'defined', 'delete', 'delete_if',
		'detect', 'dig', 'display', 'do', 'drop', 'drop_while', 'dup', 'each', 'each_cons',
		'each_entry', 'each_key', 'each_pair', 'each_slice', 'each_value', 'each_with_index',
		'each_with_object', 'element', 'else', 'elsif', 'empty?', 'end', 'endian', 'ensure', 'entries',
		'enum_for', 'eql?', 'equal?', 'except', 'extend', 'false', 'fetch', 'fetch_values', 'fields',
		'filter', 'filter!', 'filter_map', 'find', 'find_all', 'find_index', 'first', 'flat_map',
		'flatten', 'for', 'freeze', 'frozen?', 'grep', 'grep_v', 'group_by', 'has_key?', 'has_value?',
		'hash', 'hide', 'if', 'in', 'include?', 'index', 'initial_length', 'inject', 'inspect',
		'instance_eval', 'instance_exec', 'instance_of?', 'instance_variable_defined?',
		'instance_variable_get', 'instance_variable_set', 'instance_variables', 'invert', 'is_a?',
		'itself', 'keep_if', 'key', 'key?', 'keys', 'kind_of?', 'lazy', 'length', 'map', 'max',
		'max_by', 'member?', 'merge', 'merge!', 'method', 'methods', 'min', 'min_by', 'minmax',
		'minmax_by', 'module', 'next', 'nil', 'nil?', 'none?', 'not', 'object_id', 'one?', 'onlyif',
		'or', 'partition', 'private_methods', 'protected_methods', 'public_method', 'public_methods',
		'public_send', 'rassoc', 'read_abs_offset', 'read_until', 'redo', 'reduce', 'rehash', 'reject',
		'reject!', 'remove_instance_variable', 'replace', 'rescue', 'respond_to?', 'retry', 'return',
		'reverse_each', 'search_prefix', 'select', 'select!', 'selection', 'self', 'send', 'shift',
		'singleton_class', 'singleton_method', 'singleton_methods', 'size', 'slice', 'slice_after',
		'slice_before', 'slice_when', 'sort', 'sort_by', 'store', 'struct_params', 'sum', 'super',
		'take', 'take_while', 'tally', 'tap', 'then', 'to_a', 'to_enum', 'to_h', 'to_hash', 'to_proc',
		'to_s', 'to_set', 'transform_keys', 'transform_keys!', 'transform_values', 'transform_values!',
		'true', 'type', 'undef', 'uniq', 'unless', 'until', 'update', 'value', 'value?', 'values',
		'values_at', 'when', 'while', 'yield', 'yield_self', 'zip']
}

fn struct_defined_method_names() []string {
	return ['parent', 'new', 'eval_parameter', 'lazy_evaluator', 'get_parameter', 'has_parameter?',
		'read', 'write', 'num_bytes', 'to_binary_s', 'to_hex', 'pretty_print', '=~', 'debug_name',
		'abs_offset', 'rel_offset', 'safe_respond_to?', 'field_names', 'debug_name_of', 'offset_of',
		'do_read', 'do_write', 'do_num_bytes', 'assign', 'snapshot', 'base_field_name',
		'find_obj_for_name', 'instantiate_all_objs', 'instantiate_obj_at',
		'sum_num_bytes_for_all_fields', 'sum_num_bytes_below_index', 'include_obj_for_io?',
		'include_obj?']
}

fn struct_class_methods(object_class brew_runtime.Value) []string {
	mut methods := struct_defined_method_names()
	if encoded := object_class.attributes['method_names'] {
		methods << encoded.split(',').filter(it.len > 0)
	}
	return methods
}

fn struct_array(value brew_runtime.Value) []brew_runtime.Value {
	if value.type_name == 'NilClass' {
		return []
	}
	if value.type_name == 'Array' {
		return value.as_array() or { panic(err) }
	}
	return [value]
}

fn struct_symbol_name(value brew_runtime.Value) string {
	if value.type_name !in ['String', 'Symbol'] {
		panic("undefined method `to_sym' for ${value.type_name}")
	}
	return value.as_string().trim_left(':')
}

fn struct_chomp_underscore(value string) string {
	return if value.ends_with('_') { value[..value.len - 1] } else { value }
}

fn sanitized_struct_field_value(field SanitizedStructField) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedField'
		repr: if field.has_name { field.name } else { 'nil' }
		map_data: {
			'field_type': field.field_type
			'parameters': brew_runtime.map_value(field.parameters)
		}
		attributes: {
			'name':     field.name
			'has_name': field.has_name.str()
		}
	}
}

fn sanitized_struct_fields_value(fields []SanitizedStructField) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedFields'
		repr: fields.map(if it.has_name { it.name } else { 'nil' }).str()
		array_data: fields.map(sanitized_struct_field_value(it))
	}
}

fn sanitized_struct_field_from_value(value brew_runtime.Value) SanitizedStructField {
	type_value := value.map_data['field_type'] or { brew_runtime.object_value('Symbol', ':unknown') }
	params_value := value.map_data['parameters'] or { brew_runtime.map_value({}) }
	return SanitizedStructField{
		field_type: type_value
		name: value.attributes['name'] or { '' }
		has_name: (value.attributes['has_name'] or { 'false' }).bool()
		parameters: params_value.map_data.clone()
	}
}

fn sanitized_struct_fields_from_value(value brew_runtime.Value) []SanitizedStructField {
	if value.type_name == 'BinData::SanitizedFields' {
		return value.array_data.map(sanitized_struct_field_from_value(it))
	}
	return sanitize_raw_struct_fields(value)
}

fn sanitize_raw_struct_fields(value brew_runtime.Value) []SanitizedStructField {
	mut fields := []SanitizedStructField{}
	for tuple_value in struct_array(value) {
		tuple := tuple_value.as_array() or { panic(err) }
		if tuple.len == 0 {
			continue
		}
		name_value := if tuple.len > 1 { tuple[1] } else { base_nil_value() }
		has_name := name_value.type_name != 'NilClass' && name_value.as_string().len > 0
		name := if has_name { struct_symbol_name(name_value) } else { '' }
		parameters := if tuple.len > 2 && tuple[2].type_name != 'NilClass' {
			tuple[2].as_map() or { panic(err) }
		} else {
			map[string]brew_runtime.Value{}
		}
		fields << SanitizedStructField{
			field_type: tuple[0]
			name: name
			has_name: has_name
			parameters: normalized_base_parameters(parameters)
		}
	}
	return fields
}

pub fn validate_struct_field_names(object_class brew_runtime.Value, names []string) ! {
	methods := struct_class_methods(object_class)
	reserved := struct_reserved_field_names()
	for name in names {
		if name in methods {
			return error("Rename field '${name}' in ${object_class.repr}, as it shadows an existing method.")
		}
		if name in reserved {
			return error("Rename field '${name}' in ${object_class.repr}, as it is a reserved name.")
		}
		mut occurrence_count := 0
		for candidate in names {
			if candidate == name {
				occurrence_count++
			}
		}
		if occurrence_count != 1 {
			return error("field '${name}' in ${object_class.repr}, is defined multiple times.")
		}
	}
}

fn sanitized_endian(value brew_runtime.Value) !brew_runtime.Value {
	if value.type_name.starts_with('BinData::Sanitized') {
		return value
	}
	endian := value.as_string().trim_left(':')
	if endian == 'big' {
		return brew_runtime.structured_value('BinData::SanitizedBigEndian', 'big', {
			'endian': 'big'
		})
	}
	if endian == 'little' {
		return brew_runtime.structured_value('BinData::SanitizedLittleEndian', 'little', {
			'endian': 'little'
		})
	}
	if endian == 'big_and_little' {
		return error('endian: :big or endian: :little is required')
	}
	return error("unknown value for endian '${value.repr}'")
}

pub fn sanitize_struct_parameters(object_class brew_runtime.Value, parameters map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := parameters.clone()
	if endian := result['endian'] {
		result['endian'] = sanitized_endian(endian)!
	}
	if prefix := result['search_prefix'] {
		mut prefixes := []string{}
		for item in struct_array(prefix) {
			value := struct_chomp_underscore(item.as_string())
			if value.len > 0 {
				prefixes << value
			}
		}
		result['search_prefix'] = brew_runtime.string_array_value(prefixes)
	}
	if fields_value := result['fields'] {
		if fields_value.type_name != 'BinData::SanitizedFields' {
			fields := sanitize_raw_struct_fields(fields_value)
			names := fields.filter(it.has_name).map(it.name)
			validate_struct_field_names(object_class, names)!
			result['fields'] = sanitized_struct_fields_value(fields)
		}
	}
	if hidden := result['hide'] {
		fields := sanitized_struct_fields_from_value(result['fields'] or {
			sanitized_struct_fields_value([])
		})
		names := fields.filter(it.has_name).map(it.name)
		mut hidden_names := []string{}
		for item in struct_array(hidden) {
			name := struct_symbol_name(item)
			if name in names && name !in hidden_names {
				hidden_names << name
			}
		}
		result['hide'] = brew_runtime.string_array_value(hidden_names)
	}
	return result
}

fn field_numeric_bytes(field SanitizedStructField) (f64, bool) {
	if value := field.parameters['num_bytes'] {
		return value.as_float() or { panic(err) }, value.type_name == 'Integer'
	}
	if value := field.parameters['length'] {
		return value.as_float() or { panic(err) }, value.type_name == 'Integer'
	}
	mut type_name := field.field_type.as_string().trim_left(':').to_lower()
	if type_name.ends_with('le') || type_name.ends_with('be') {
		type_name = type_name[..type_name.len - 2]
	}
	mut digit_start := type_name.len
	for index, character in type_name.bytes() {
		if character >= `0` && character <= `9` {
			digit_start = index
			break
		}
	}
	if digit_start < type_name.len {
		bits := type_name[digit_start..].int()
		if bits > 0 {
			if type_name.starts_with('bit') || type_name.starts_with('sbit') {
				return f64(bits) / 8.0, bits % 8 == 0
			}
			return f64(bits / 8), true
		}
	}
	return 0.0, true
}

fn new_struct_field_object(definition SanitizedStructField) &StructFieldObject {
	nbytes, integer_nbytes := field_numeric_bytes(definition)
	mut base := new_base_object(definition.field_type.as_string().trim_left(':'), definition.parameters)
	base.do_num_bytes = nbytes
	return &StructFieldObject{
		definition: definition
		base: base
		integer_num_bytes: integer_nbytes
		bit_aligned: !integer_nbytes
		delayed_io: definition.field_type.as_string().contains('DelayedIO')
	}
}

fn struct_field_value(field &StructFieldObject) brew_runtime.Value {
	base_value := base_object_value(field.base)
	mut attributes := base_value.attributes.clone()
	attributes['struct_field_address'] = u64(voidptr(field)).str()
	attributes['name'] = field.definition.name
	attributes['has_name'] = field.definition.has_name.str()
	attributes['bit_aligned'] = field.bit_aligned.str()
	attributes['delayed_io'] = field.delayed_io.str()
	return brew_runtime.Value{
		...base_value
		attributes: attributes
	}
}

fn struct_field_from_value(value brew_runtime.Value) &StructFieldObject {
	if address := value.attributes['struct_field_address'] {
		return unsafe { &StructFieldObject(voidptr(address.u64())) }
	}
	definition := SanitizedStructField{
		field_type: brew_runtime.object_value('Symbol', value.type_name)
		name: value.attributes['name'] or { '' }
		has_name: (value.attributes['has_name'] or { 'false' }).bool()
		parameters: value.map_data.clone()
	}
	mut field := new_struct_field_object(definition)
	field.base = base_object_from_value(value)
	field.instantiated = true
	return field
}

pub fn new_struct_object(type_name string, parameters map[string]brew_runtime.Value) &StructObject {
	definitions := sanitized_struct_fields_from_value(parameters['fields'] or {
		sanitized_struct_fields_value([])
	})
	mut base := new_base_object(type_name, parameters)
	mut fields := []&StructFieldObject{cap: definitions.len}
	mut names := []string{cap: definitions.len}
	mut named := []bool{cap: definitions.len}
	mut aligned := false
	for definition in definitions {
		field := new_struct_field_object(definition)
		fields << field
		names << definition.name
		named << definition.has_name
		if 'byte_align' in definition.parameters {
			aligned = true
		}
	}
	hidden := if value := parameters['hide'] {
		if value.type_name == 'Array' {
			value.as_array() or { panic(err) }.map(it.as_string())
		} else {
			[]string{}
		}
	} else {
		[]string{}
	}
	base.method_names = names.filter(it.len > 0)
	return &StructObject{
		type_name: type_name
		base: base
		fields: fields
		field_names: names
		named_fields: named
		hidden: hidden
		byte_aligned: aligned
	}
}

fn struct_object_value(object &StructObject) brew_runtime.Value {
	base_value := base_object_value(object.base)
	mut attributes := base_value.attributes.clone()
	attributes['struct_object_address'] = u64(voidptr(object)).str()
	attributes['byte_aligned'] = object.byte_aligned.str()
	return brew_runtime.Value{
		...base_value
		type_name: object.type_name
		repr: struct_snapshot(object).repr
		attributes: attributes
	}
}

pub fn struct_boundary_value(object &StructObject) brew_runtime.Value {
	return struct_object_value(object)
}

pub fn initialize_struct_object(receiver brew_runtime.Value, parameters map[string]brew_runtime.Value, separated BaseSeparatedArguments) brew_runtime.Value {
	mut object := new_struct_object(receiver.type_name, parameters)
	if separated.has_parent {
		object.base.parent = separated.parent
		object.base.has_parent = true
	}
	if separated.has_value && base_value_truthy(separated.value) {
		struct_assign_map(mut object, separated.value.map_data)
		object.base.assigned_value = separated.value
		object.base.snapshot_value = struct_snapshot(object)
		object.base.has_assignment = true
		object.base.clear = false
	}
	return struct_object_value(object)
}

fn struct_object_from_value(value brew_runtime.Value) &StructObject {
	if address := value.attributes['struct_object_address'] {
		return unsafe { &StructObject(voidptr(address.u64())) }
	}
	mut object := new_struct_object(value.type_name, value.map_data)
	object.base = base_object_from_value(value)
	return object
}

fn instantiate_struct_field(mut object StructObject, index int) &StructFieldObject {
	if index < 0 || index >= object.fields.len {
		panic('index ${index} outside of struct fields')
	}
	mut field := object.fields[index]
	if !field.instantiated {
		field.instantiated = true
		field.base.parent = struct_object_value(object)
		field.base.has_parent = true
	}
	return field
}

fn struct_base_field_name(value brew_runtime.Value) string {
	mut name := value.as_string().trim_left(':')
	if name.ends_with('=') || name.ends_with('?') {
		name = name[..name.len - 1]
	}
	return name
}

fn struct_field_index(object &StructObject, name string) int {
	for index, field_name in object.field_names {
		if object.named_fields[index] && field_name == name {
			return index
		}
	}
	return -1
}

fn struct_field_index_by_value(object &StructObject, value brew_runtime.Value) int {
	if address := value.attributes['struct_field_address'] {
		for index, field in object.fields {
			if u64(voidptr(field)) == address.u64() {
				return index
			}
		}
	}
	return -1
}

fn struct_field_included(field &StructFieldObject) bool {
	if onlyif := field.definition.parameters['onlyif'] {
		return base_value_truthy(onlyif)
	}
	return true
}

fn struct_field_snapshot(field &StructFieldObject) brew_runtime.Value {
	return field.base.snapshot_value
}

fn struct_snapshot(object &StructObject) brew_runtime.Value {
	mut snapshot := map[string]brew_runtime.Value{}
	for index, name in object.field_names {
		if !object.named_fields[index] || name in object.hidden {
			continue
		}
		field := object.fields[index]
		if struct_field_included(field) {
			value := struct_field_snapshot(field)
			if value.type_name != 'NilClass' {
				snapshot[name] = value
			}
		}
	}
	return brew_runtime.Value{
		type_name: 'BinData::Struct::Snapshot'
		repr: snapshot.str()
		map_data: snapshot
	}
}

fn struct_numeric_value(value f64) brew_runtime.Value {
	if value == math.floor(value) {
		return brew_runtime.int_value(i64(value))
	}
	return brew_runtime.float_value(value)
}

fn struct_sum_below(object &StructObject, index int, aligned bool) f64 {
	mut sum := 0.0
	limit := if index < object.fields.len { index } else { object.fields.len }
	for field_index, field in object.fields {
		if !struct_field_included(field) {
			continue
		}
		if aligned && 'byte_align' in field.definition.parameters {
			align := field.definition.parameters['byte_align'].as_int() or { panic(err) }
			if align > 0 {
				integer_sum := i64(math.ceil(sum))
				sum = f64(integer_sum + ((align - (integer_sum % align)) % align))
			}
		}
		if field_index >= limit {
			break
		}
		nbytes := field.base.do_num_bytes
		sum = (if field.integer_num_bytes { math.ceil(sum) } else { sum }) + nbytes
	}
	return sum
}

pub fn struct_offset_of_value(parent brew_runtime.Value, child brew_runtime.Value) brew_runtime.Value {
	if _ := parent.attributes['struct_object_address'] {
		object := struct_object_from_value(parent)
		index := struct_field_index_by_value(object, child)
		if index >= 0 {
			field := object.fields[index]
			offset := struct_sum_below(object, index, object.byte_aligned)
			return brew_runtime.int_value(i64(if field.bit_aligned {
				math.floor(offset)
			} else {
				math.ceil(offset)
			}))
		}
	}
	return brew_runtime.int_value((parent.attributes['offset'] or { '0' }).i64())
}

pub fn struct_debug_name_of_value(parent brew_runtime.Value, child brew_runtime.Value) brew_runtime.Value {
	if _ := parent.attributes['struct_object_address'] {
		object := struct_object_from_value(parent)
		index := struct_field_index_by_value(object, child)
		if index >= 0 {
			debug_name := ruby_base_l206_d25_debug_name(parent).as_string()
			return brew_runtime.string_value('${debug_name}.${object.field_names[index]}')
		}
	}
	return brew_runtime.string_value(parent.attributes['debug_name'] or { parent.repr })
}

fn struct_assign_map(mut object StructObject, values map[string]brew_runtime.Value) {
	for index, name in object.field_names {
		if !object.named_fields[index] {
			continue
		}
		if value := values[name] {
			mut field := instantiate_struct_field(mut object, index)
			field.base.assigned_value = value
			field.base.snapshot_value = value
			field.base.has_assignment = true
			field.base.clear = false
			if value.type_name == 'String' {
				field.base.binary_value = value.as_string()
			}
		}
	}
}

fn struct_clear(mut object StructObject) {
	for mut field in object.fields {
		if field.instantiated {
			field.base.assigned_value = base_nil_value()
			field.base.snapshot_value = base_nil_value()
			field.base.has_assignment = false
			field.base.clear = true
		}
	}
	object.base.clear = true
}

fn struct_binary(object &StructObject, aligned bool) string {
	mut result := ''
	mut offset := 0.0
	for field in object.fields {
		if !struct_field_included(field) {
			continue
		}
		if aligned && 'byte_align' in field.definition.parameters {
			align := field.definition.parameters['byte_align'].as_int() or { panic(err) }
			integer_offset := i64(math.ceil(offset))
			padding := if align > 0 { (align - (integer_offset % align)) % align } else { 0 }
			result += '\0'.repeat(int(padding))
			offset = f64(integer_offset + padding)
		}
		result += field.base.binary_value
		offset = (if field.integer_num_bytes { math.ceil(offset) } else { offset }) + field.base.do_num_bytes
	}
	return result
}

fn struct_io_binary(io brew_runtime.Value) string {
	if value := io.map_data['binary'] {
		return value.as_string()
	}
	return io.as_string()
}

fn struct_do_read_boundary(args []brew_runtime.Value, aligned bool) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#do_read requires a receiver and IO')
	}
	mut object := struct_object_from_value(args[0])
	binary := struct_io_binary(args[1])
	mut offset := 0
	for index in 0 .. object.fields.len {
		mut field := instantiate_struct_field(mut object, index)
		included := if aligned {
			struct_field_included(field)
		} else {
			struct_field_included(field) || field.delayed_io
		}
		if !included {
			continue
		}
		if aligned && 'byte_align' in field.definition.parameters {
			align := field.definition.parameters['byte_align'].as_int() or { panic(err) }
			if align > 0 {
				offset += int((align - (i64(offset) % align)) % align)
			}
		}
		nbytes := int(math.ceil(field.base.do_num_bytes))
		end := if offset + nbytes < binary.len { offset + nbytes } else { binary.len }
		if offset <= end && offset < binary.len {
			field.base.binary_value = binary[offset..end]
			field.base.snapshot_value = brew_runtime.string_value(field.base.binary_value)
			field.base.assigned_value = field.base.snapshot_value
			field.base.has_assignment = true
			field.base.clear = false
		}
		offset += nbytes
	}
	object.base.binary_value = binary[..if offset < binary.len { offset } else { binary.len }]
	object.base.clear = false
	return base_nil_value()
}

fn struct_do_write_boundary(args []brew_runtime.Value, aligned bool) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#do_write requires a receiver and IO')
	}
	mut object := struct_object_from_value(args[0])
	for index in 0 .. object.fields.len {
		instantiate_struct_field(mut object, index)
	}
	object.base.binary_value = struct_binary(object, aligned)
	return base_nil_value()
}

// Ruby method `initialize_shared_instance` at line 82.
pub fn ruby_struct_l82_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#initialize_shared_instance requires a receiver')
	}
	if _ := args[0].attributes['struct_object_address'] {
		return args[0]
	}
	return struct_object_value(new_struct_object(args[0].type_name, base_object_from_value(args[0]).parameters))
}

// Ruby method `initialize_instance` at line 90.
pub fn ruby_struct_l90_d2_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#initialize_instance requires a receiver')
	}
	mut object := struct_object_from_value(args[0])
	for mut field in object.fields {
		field.instantiated = false
	}
	return base_nil_value()
}

// Ruby method `clear # :nodoc:` at line 94.
pub fn ruby_struct_l94_d3_clear(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#clear requires a receiver')
	}
	mut object := struct_object_from_value(args[0])
	struct_clear(mut object)
	return base_nil_value()
}

// Ruby method `clear? # :nodoc:` at line 98.
pub fn ruby_struct_l98_d4_clear(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#clear? requires a receiver')
	}
	mut object := struct_object_from_value(args[0])
	for field in object.fields {
		if field.instantiated && !field.base.clear {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby method `assign(val)` at line 102.
pub fn ruby_struct_l102_d5_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#assign requires a receiver and value')
	}
	mut object := struct_object_from_value(args[0])
	struct_clear(mut object)
	values := if args[1].type_name == 'NilClass' {
		map[string]brew_runtime.Value{}
	} else {
		args[1].map_data.clone()
	}
	struct_assign_map(mut object, values)
	object.base.clear = false
	return args[1]
}

// Ruby method `snapshot` at line 107.
pub fn ruby_struct_l107_d6_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#snapshot requires a receiver')
	}
	return struct_snapshot(struct_object_from_value(args[0]))
}

// Ruby method `field_names(include_hidden = false)` at line 119.
pub fn ruby_struct_l119_d7_field_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#field_names requires a receiver')
	}
	object := struct_object_from_value(args[0])
	include_hidden := args.len > 1 && base_value_truthy(args[1])
	mut names := []string{}
	for index, name in object.field_names {
		if object.named_fields[index] && (include_hidden || name !in object.hidden) {
			names << name
		}
	}
	return brew_runtime.string_array_value(names)
}

// Ruby method `debug_name_of(child) # :nodoc:` at line 128.
pub fn ruby_struct_l128_d8_debug_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#debug_name_of requires a receiver and child')
	}
	return struct_debug_name_of_value(args[0], args[1])
}

// Ruby method `offset_of(child) # :nodoc:` at line 133.
pub fn ruby_struct_l133_d9_offset_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#offset_of requires a receiver and child')
	}
	return struct_offset_of_value(args[0], args[1])
}

// Ruby method `do_read(io) # :nodoc:` at line 139.
pub fn ruby_struct_l139_d10_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return struct_do_read_boundary(args, false)
}

// Ruby method `do_write(io) # :nodoc:` at line 144.
pub fn ruby_struct_l144_d11_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return struct_do_write_boundary(args, false)
}

// Ruby method `do_num_bytes # :nodoc:` at line 149.
pub fn ruby_struct_l149_d12_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#do_num_bytes requires a receiver')
	}
	object := struct_object_from_value(args[0])
	return struct_numeric_value(struct_sum_below(object, object.fields.len, object.byte_aligned))
}

// Ruby method `[](key)` at line 154.
pub fn ruby_struct_l154_d13_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#[] requires a receiver and key')
	}
	return ruby_struct_l213_d23_find_obj_for_name(args[0], args[1])
}

// Ruby method `[]=(key, value)` at line 158.
pub fn ruby_struct_l158_d14_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Struct#[]= requires a receiver, key and value')
	}
	mut object := struct_object_from_value(args[0])
	index := struct_field_index(object, struct_base_field_name(args[1]))
	if index >= 0 {
		mut field := instantiate_struct_field(mut object, index)
		field.base.assigned_value = args[2]
		field.base.snapshot_value = args[2]
		field.base.has_assignment = true
		field.base.clear = false
	}
	return args[2]
}

// Ruby method `key?(key)` at line 162.
pub fn ruby_struct_l162_d15_key(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#key? requires a receiver and key')
	}
	index := struct_field_index(struct_object_from_value(args[0]), struct_base_field_name(args[1]))
	return if index >= 0 { brew_runtime.int_value(index) } else { base_nil_value() }
}

// Ruby method `each_pair(include_all = false)` at line 170.
pub fn ruby_struct_l170_d16_each_pair(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#each_pair requires a receiver')
	}
	mut object := struct_object_from_value(args[0])
	include_all := args.len > 1 && base_value_truthy(args[1])
	mut pairs := []brew_runtime.Value{}
	for index, name in object.field_names {
		if object.named_fields[index] || include_all {
			field := instantiate_struct_field(mut object, index)
			name_value := if object.named_fields[index] {
				brew_runtime.object_value('Symbol', ':${name}')
			} else {
				base_nil_value()
			}
			pairs << brew_runtime.array_value([name_value, struct_field_value(field)])
		}
	}
	return brew_runtime.array_value(pairs)
}

// Ruby method `define_field_accessors` at line 187.
pub fn ruby_struct_l187_d17_define_field_accessors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#define_field_accessors requires a receiver')
	}
	object := struct_object_from_value(args[0])
	return brew_runtime.string_array_value(object.field_names.filter(it.len > 0))
}

// Ruby method `define_field_accessors_for(name, index)` at line 194.
pub fn ruby_struct_l194_d18_define_field_accessors_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Struct#define_field_accessors_for requires a receiver, name and index')
	}
	return brew_runtime.object_value('Symbol', ':${struct_base_field_name(args[1])}')
}

// Ruby define_singleton_method `define_singleton_method(name) do` at line 195.
pub fn ruby_struct_l195_d19_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generated field getter requires a receiver and field name')
	}
	return ruby_struct_l213_d23_find_obj_for_name(args[0], args[1])
}

// Ruby define_singleton_method `define_singleton_method("#{name}=") do |*vals|` at line 199.
pub fn ruby_struct_l199_d20_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('generated field setter requires a receiver, field name and value')
	}
	return ruby_struct_l158_d14_anonymous(args[0], args[1], args[2])
}

// Ruby define_singleton_method `define_singleton_method("#{name}?") do` at line 203.
pub fn ruby_struct_l203_d21_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('generated field predicate requires a receiver and field name')
	}
	field := ruby_struct_l213_d23_find_obj_for_name(args[0], args[1])
	return if field.type_name == 'NilClass' {
		brew_runtime.bool_value(false)
	} else {
		ruby_struct_l281_d32_include_obj(args[0], field)
	}
}

// Ruby method `find_index_of(obj)` at line 209.
pub fn ruby_struct_l209_d22_find_index_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#find_index_of requires a receiver and object')
	}
	index := struct_field_index_by_value(struct_object_from_value(args[0]), args[1])
	return if index >= 0 { brew_runtime.int_value(index) } else { base_nil_value() }
}

// Ruby method `find_obj_for_name(name)` at line 213.
pub fn ruby_struct_l213_d23_find_obj_for_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#find_obj_for_name requires a receiver and name')
	}
	mut object := struct_object_from_value(args[0])
	index := struct_field_index(object, struct_base_field_name(args[1]))
	if index < 0 {
		return base_nil_value()
	}
	return struct_field_value(instantiate_struct_field(mut object, index))
}

// Ruby method `base_field_name(name)` at line 221.
pub fn ruby_struct_l221_d24_base_field_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#base_field_name requires a receiver and name')
	}
	return brew_runtime.object_value('Symbol', ':${struct_base_field_name(args[1])}')
}

// Ruby method `instantiate_all_objs` at line 225.
pub fn ruby_struct_l225_d25_instantiate_all_objs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#instantiate_all_objs requires a receiver')
	}
	mut object := struct_object_from_value(args[0])
	for index in 0 .. object.fields.len {
		instantiate_struct_field(mut object, index)
	}
	return args[0]
}

// Ruby method `instantiate_obj_at(index)` at line 229.
pub fn ruby_struct_l229_d26_instantiate_obj_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#instantiate_obj_at requires a receiver and index')
	}
	mut object := struct_object_from_value(args[0])
	return struct_field_value(instantiate_struct_field(mut object, int(args[1].as_int() or {
		panic(err)
	})))
}

// Ruby method `assign_fields(val)` at line 236.
pub fn ruby_struct_l236_d27_assign_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#assign_fields requires a receiver and value')
	}
	mut object := struct_object_from_value(args[0])
	values := if args[1].type_name == 'NilClass' {
		map[string]brew_runtime.Value{}
	} else {
		args[1].map_data.clone()
	}
	struct_assign_map(mut object, values)
	return args[1]
}

// Ruby method `as_stringified_hash(val)` at line 247.
pub fn ruby_struct_l247_d28_as_stringified_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#as_stringified_hash requires a receiver and value')
	}
	if args[1].type_name == 'NilClass' {
		return brew_runtime.map_value({})
	}
	if _ := args[1].attributes['struct_object_address'] {
		return ruby_struct_l107_d6_snapshot(args[1])
	}
	mut normalized := map[string]brew_runtime.Value{}
	for key, value in args[1].map_data {
		normalized[key] = value
	}
	return brew_runtime.Value{
		type_name: 'BinData::Struct::Snapshot'
		repr: normalized.str()
		map_data: normalized
	}
}

// Ruby method `sum_num_bytes_for_all_fields` at line 259.
pub fn ruby_struct_l259_d29_sum_num_bytes_for_all_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Struct#sum_num_bytes_for_all_fields requires a receiver')
	}
	object := struct_object_from_value(args[0])
	return struct_numeric_value(struct_sum_below(object, object.fields.len, object.byte_aligned))
}

// Ruby method `sum_num_bytes_below_index(index)` at line 263.
pub fn ruby_struct_l263_d30_sum_num_bytes_below_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#sum_num_bytes_below_index requires a receiver and index')
	}
	object := struct_object_from_value(args[0])
	return struct_numeric_value(struct_sum_below(object, int(args[1].as_int() or { panic(err) }), false))
}

// Ruby method `include_obj_for_io?(obj)` at line 275.
pub fn ruby_struct_l275_d31_include_obj_for_io(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#include_obj_for_io? requires a receiver and object')
	}
	field := struct_field_from_value(args[1])
	return brew_runtime.bool_value(struct_field_included(field) || field.delayed_io)
}

// Ruby method `include_obj?(obj)` at line 281.
pub fn ruby_struct_l281_d32_include_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Struct#include_obj? requires a receiver and object')
	}
	return brew_runtime.bool_value(struct_field_included(struct_field_from_value(args[1])))
}

// Ruby method `[]=(key, value)` at line 287.
pub fn ruby_struct_l287_d33_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Snapshot#[]= requires a receiver, key and value')
	}
	mut snapshot := args[0].map_data.clone()
	if args[2].type_name != 'NilClass' {
		snapshot[struct_base_field_name(args[1])] = args[2]
	}
	return brew_runtime.Value{
		type_name: 'BinData::Struct::Snapshot'
		repr: snapshot.str()
		map_data: snapshot
	}
}

// Ruby method `respond_to_missing?(symbol, include_all = false)` at line 291.
pub fn ruby_struct_l291_d34_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Snapshot#respond_to_missing? requires a receiver and symbol')
	}
	return brew_runtime.bool_value(struct_base_field_name(args[1]) in args[0].map_data)
}

// Ruby method `method_missing(symbol, *args)` at line 295.
pub fn ruby_struct_l295_d35_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Snapshot#method_missing requires a receiver and symbol')
	}
	return args[0].map_data[struct_base_field_name(args[1])] or { base_nil_value() }
}

// Ruby method `do_read(io)` at line 302.
pub fn ruby_struct_l302_d36_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return struct_do_read_boundary(args, true)
}

// Ruby method `do_write(io)` at line 320.
pub fn ruby_struct_l320_d37_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return struct_do_write_boundary(args, true)
}

// Ruby method `sum_num_bytes_below_index(index)` at line 338.
pub fn ruby_struct_l338_d38_sum_num_bytes_below_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ByteAlignPlugin#sum_num_bytes_below_index requires a receiver and index')
	}
	object := struct_object_from_value(args[0])
	return struct_numeric_value(struct_sum_below(object, int(args[1].as_int() or { panic(err) }), true))
}

// Ruby method `bytes_to_align(obj, rel_offset)` at line 356.
pub fn ruby_struct_l356_d39_bytes_to_align(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('ByteAlignPlugin#bytes_to_align requires a receiver, object and offset')
	}
	field := struct_field_from_value(args[1])
	align := field.definition.parameters['byte_align'] or { return brew_runtime.int_value(0) }
	actual := align.as_int() or { panic(err) }
	offset := args[2].as_int() or { panic(err) }
	return brew_runtime.int_value(if actual > 0 { (actual - (offset % actual)) % actual } else { 0 })
}

// Ruby method `align_obj?(obj)` at line 361.
pub fn ruby_struct_l361_d40_align_obj(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ByteAlignPlugin#align_obj? requires a receiver and object')
	}
	return brew_runtime.bool_value('byte_align' in struct_field_from_value(args[1]).definition.parameters)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 368.
pub fn ruby_struct_l368_d41_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('StructArgProcessor#sanitize_parameters! requires a receiver, class and parameters')
	}
	return brew_runtime.map_value(sanitize_struct_parameters(args[1], args[2].map_data) or {
		panic(err)
	})
}

// Ruby method `sanitize_endian(params)` at line 378.
pub fn ruby_struct_l378_d42_sanitize_endian(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StructArgProcessor#sanitize_endian requires a receiver and parameters')
	}
	mut parameters := args[1].map_data.clone()
	if value := parameters['endian'] {
		parameters['endian'] = sanitized_endian(value) or { panic(err) }
	}
	return brew_runtime.map_value(parameters)
}

// Ruby method `sanitize_search_prefix(params)` at line 382.
pub fn ruby_struct_l382_d43_sanitize_search_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StructArgProcessor#sanitize_search_prefix requires a receiver and parameters')
	}
	mut parameters := args[1].map_data.clone()
	if prefix := parameters['search_prefix'] {
		mut prefixes := []string{}
		for item in struct_array(prefix) {
			value := struct_chomp_underscore(item.as_string())
			if value.len > 0 {
				prefixes << value
			}
		}
		parameters['search_prefix'] = brew_runtime.string_array_value(prefixes)
	}
	return brew_runtime.map_value(parameters)
}

// Ruby method `sanitize_fields(obj_class, params)` at line 392.
pub fn ruby_struct_l392_d44_sanitize_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('StructArgProcessor#sanitize_fields requires a receiver, class and parameters')
	}
	mut parameters := args[2].map_data.clone()
	if fields_value := parameters['fields'] {
		fields := sanitized_struct_fields_from_value(fields_value)
		validate_struct_field_names(args[1], fields.filter(it.has_name).map(it.name)) or {
			panic(err)
		}
		parameters['fields'] = sanitized_struct_fields_value(fields)
	}
	return brew_runtime.map_value(parameters)
}

// Ruby method `sanitize_hide(params)` at line 403.
pub fn ruby_struct_l403_d45_sanitize_hide(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StructArgProcessor#sanitize_hide requires a receiver and parameters')
	}
	mut parameters := args[1].map_data.clone()
	if hidden := parameters['hide'] {
		fields := sanitized_struct_fields_from_value(parameters['fields'] or {
			sanitized_struct_fields_value([])
		})
		field_names := fields.filter(it.has_name).map(it.name)
		mut selected := []string{}
		for value in struct_array(hidden) {
			name := struct_symbol_name(value)
			if name in field_names && name !in selected {
				selected << name
			}
		}
		parameters['hide'] = brew_runtime.string_array_value(selected)
	}
	return brew_runtime.map_value(parameters)
}

// Ruby method `sanitized_field_names(sanitized_fields)` at line 412.
pub fn ruby_struct_l412_d46_sanitized_field_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StructArgProcessor#sanitized_field_names requires a receiver and fields')
	}
	return brew_runtime.string_array_value(sanitized_struct_fields_from_value(args[1]).filter(it.has_name).map(it.name))
}

// Ruby method `hidden_field_names(hidden)` at line 416.
pub fn ruby_struct_l416_d47_hidden_field_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StructArgProcessor#hidden_field_names requires a receiver and hidden fields')
	}
	return brew_runtime.string_array_value(struct_array(args[1]).map(struct_symbol_name(it)))
}

// Ruby method `ensure_field_names_are_valid(obj_class, field_names)` at line 420.
pub fn ruby_struct_l420_d48_ensure_field_names_are_valid(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('StructArgProcessor#ensure_field_names_are_valid requires a receiver, class and names')
	}
	names := args[2].as_array() or { panic(err) }.map(struct_symbol_name(it))
	validate_struct_field_names(args[1], names) or { panic(err) }
	return brew_runtime.string_array_value(names)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/delayed_io'
// 3:
// 4: module BinData
// 5:   class Base
// 6:     optional_parameter :onlyif, :byte_align  # Used by Struct
// 7:   end
// 8:
// 9:   # A Struct is an ordered collection of named data objects.
// 10:   #
// 11:   #    require 'bindata'
// 12:   #
// 13:   #    class Tuple < BinData::Record
// 14:   #      int8  :x
// 15:   #      int8  :y
// 16:   #      int8  :z
// 17:   #    end
// 18:   #
// 19:   #    obj = BinData::Struct.new(hide: :a,
// 20:   #                              fields: [ [:int32le, :a],
// 21:   #                                        [:int16le, :b],
// 22:   #                                        [:tuple, :s] ])
// 23:   #    obj.field_names   =># [:b, :s]
// 24:   #
// 25:   #
// 26:   # == Parameters
// 27:   #
// 28:   # Parameters may be provided at initialisation to control the behaviour of
// 29:   # an object.  These params are:
// 30:   #
// 31:   # <tt>:fields</tt>::   An array specifying the fields for this struct.
// 32:   #                      Each element of the array is of the form [type, name,
// 33:   #                      params].  Type is a symbol representing a registered
// 34:   #                      type.  Name is the name of this field.  Params is an
// 35:   #                      optional hash of parameters to pass to this field
// 36:   #                      when instantiating it.  If name is "" or nil, then
// 37:   #                      that field is anonymous and behaves as a hidden field.
// 38:   # <tt>:hide</tt>::     A list of the names of fields that are to be hidden
// 39:   #                      from the outside world.  Hidden fields don't appear
// 40:   #                      in #snapshot or #field_names but are still accessible
// 41:   #                      by name.
// 42:   # <tt>:endian</tt>::   Either :little or :big.  This specifies the default
// 43:   #                      endian of any numerics in this struct, or in any
// 44:   #                      nested data objects.
// 45:   # <tt>:search_prefix</tt>::  Allows abbreviated type names.  If a type is
// 46:   #                            unrecognised, then each prefix is applied until
// 47:   #                            a match is found.
// 48:   #
// 49:   # == Field Parameters
// 50:   #
// 51:   # Fields may have have extra parameters as listed below:
// 52:   #
// 53:   # [<tt>:onlyif</tt>]     Used to indicate a data object is optional.
// 54:   #                        if +false+, this object will not be included in any
// 55:   #                        calls to #read, #write, #num_bytes or #snapshot.
// 56:   # [<tt>:byte_align</tt>] This field's rel_offset must be a multiple of
// 57:   #                        <tt>:byte_align</tt>.
// 58:   class Struct < BinData::Base
// 59:     arg_processor :struct
// 60:
// 61:     mandatory_parameter :fields
// 62:     optional_parameters :endian, :search_prefix, :hide
// 63:
// 64:     # These reserved words may not be used as field names
// 65:     RESERVED =
// 66:       Hash[*
// 67:         (Hash.instance_methods +
// 68:          %w[alias and begin break case class def defined do else elsif
// 69:             end ensure false for if in module next nil not or redo
// 70:             rescue retry return self super then true undef unless until
// 71:             when while yield] +
// 72:          %w[array element index value] +
// 73:          %w[type initial_length read_until] +
// 74:          %w[fields endian search_prefix hide onlyif byte_align] +
// 75:          %w[choices selection copy_on_change] +
// 76:          %w[read_abs_offset struct_params])
// 77:         .collect(&:to_sym)
// 78:         .uniq.collect { |key| [key, true] }
// 79:         .flatten
// 80:       ]
// 81:
// 82:     def initialize_shared_instance
// 83:       fields = get_parameter(:fields)
// 84:       @field_names = fields.field_names.freeze
// 85:       extend ByteAlignPlugin if fields.any_field_has_parameter?(:byte_align)
// 86:       define_field_accessors
// 87:       super
// 88:     end
// 89:
// 90:     def initialize_instance
// 91:       @field_objs = []
// 92:     end
// 93:
// 94:     def clear # :nodoc:
// 95:       @field_objs.each { |f| f.nil? || f.clear }
// 96:     end
// 97:
// 98:     def clear? # :nodoc:
// 99:       @field_objs.all? { |f| f.nil? || f.clear? }
// 100:     end
// 101:
// 102:     def assign(val)
// 103:       clear
// 104:       assign_fields(val)
// 105:     end
// 106:
// 107:     def snapshot
// 108:       snapshot = Snapshot.new
// 109:       field_names.each do |name|
// 110:         obj = find_obj_for_name(name)
// 111:         snapshot[name] = obj.snapshot if include_obj?(obj)
// 112:       end
// 113:       snapshot
// 114:     end
// 115:
// 116:     # Returns a list of the names of all fields accessible through this
// 117:     # object.  +include_hidden+ specifies whether to include hidden names
// 118:     # in the listing.
// 119:     def field_names(include_hidden = false)
// 120:       if include_hidden
// 121:         @field_names.compact
// 122:       else
// 123:         hidden = get_parameter(:hide) || []
// 124:         @field_names.compact - hidden
// 125:       end
// 126:     end
// 127:
// 128:     def debug_name_of(child) # :nodoc:
// 129:       field_name = @field_names[find_index_of(child)]
// 130:       "#{debug_name}.#{field_name}"
// 131:     end
// 132:
// 133:     def offset_of(child) # :nodoc:
// 134:       instantiate_all_objs
// 135:       sum = sum_num_bytes_below_index(find_index_of(child))
// 136:       child.bit_aligned? ? sum.floor : sum.ceil
// 137:     end
// 138:
// 139:     def do_read(io) # :nodoc:
// 140:       instantiate_all_objs
// 141:       @field_objs.each { |f| f.do_read(io) if include_obj_for_io?(f) }
// 142:     end
// 143:
// 144:     def do_write(io) # :nodoc:
// 145:       instantiate_all_objs
// 146:       @field_objs.each { |f| f.do_write(io) if include_obj_for_io?(f) }
// 147:     end
// 148:
// 149:     def do_num_bytes # :nodoc:
// 150:       instantiate_all_objs
// 151:       sum_num_bytes_for_all_fields
// 152:     end
// 153:
// 154:     def [](key)
// 155:       find_obj_for_name(key)
// 156:     end
// 157:
// 158:     def []=(key, value)
// 159:       find_obj_for_name(key)&.assign(value)
// 160:     end
// 161:
// 162:     def key?(key)
// 163:       @field_names.index(base_field_name(key))
// 164:     end
// 165:
// 166:     # Calls the given block for each field_name-field_obj pair.
// 167:     #
// 168:     # Does not include anonymous or hidden fields unless
// 169:     # +include_all+ is true.
// 170:     def each_pair(include_all = false)
// 171:       instantiate_all_objs
// 172:
// 173:       pairs = @field_names.zip(@field_objs).select do |name, _obj|
// 174:         name || include_all
// 175:       end
// 176:
// 177:       if block_given?
// 178:         pairs.each { |el| yield(el) }
// 179:       else
// 180:         pairs.each
// 181:       end
// 182:     end
// 183:
// 184:     #---------------
// 185:     private
// 186:
// 187:     def define_field_accessors
// 188:       get_parameter(:fields).each_with_index do |field, i|
// 189:         name = field.name_as_sym
// 190:         define_field_accessors_for(name, i) if name
// 191:       end
// 192:     end
// 193:
// 194:     def define_field_accessors_for(name, index)
// 195:       define_singleton_method(name) do
// 196:         instantiate_obj_at(index) if @field_objs[index].nil?
// 197:         @field_objs[index]
// 198:       end
// 199:       define_singleton_method("#{name}=") do |*vals|
// 200:         instantiate_obj_at(index) if @field_objs[index].nil?
// 201:         @field_objs[index].assign(*vals)
// 202:       end
// 203:       define_singleton_method("#{name}?") do
// 204:         instantiate_obj_at(index) if @field_objs[index].nil?
// 205:         include_obj?(@field_objs[index])
// 206:       end
// 207:     end
// 208:
// 209:     def find_index_of(obj)
// 210:       @field_objs.index { |el| el.equal?(obj) }
// 211:     end
// 212:
// 213:     def find_obj_for_name(name)
// 214:       index = @field_names.index(base_field_name(name))
// 215:       if index
// 216:         instantiate_obj_at(index)
// 217:         @field_objs[index]
// 218:       end
// 219:     end
// 220:
// 221:     def base_field_name(name)
// 222:       name.to_s.sub(/(=|\?)\z/, "").to_sym
// 223:     end
// 224:
// 225:     def instantiate_all_objs
// 226:       @field_names.each_index { |i| instantiate_obj_at(i) }
// 227:     end
// 228:
// 229:     def instantiate_obj_at(index)
// 230:       if @field_objs[index].nil?
// 231:         field = get_parameter(:fields)[index]
// 232:         @field_objs[index] = field.instantiate(nil, self)
// 233:       end
// 234:     end
// 235:
// 236:     def assign_fields(val)
// 237:       src = as_stringified_hash(val)
// 238:
// 239:       @field_names.compact.each do |name|
// 240:         obj = find_obj_for_name(name)
// 241:         if obj && src.key?(name)
// 242:           obj.assign(src[name])
// 243:         end
// 244:       end
// 245:     end
// 246:
// 247:     def as_stringified_hash(val)
// 248:       if BinData::Struct === val
// 249:         val
// 250:       elsif val.nil?
// 251:         {}
// 252:       else
// 253:         hash = Snapshot.new
// 254:         val.each_pair { |k, v| hash[k] = v }
// 255:         hash
// 256:       end
// 257:     end
// 258:
// 259:     def sum_num_bytes_for_all_fields
// 260:       sum_num_bytes_below_index(@field_objs.length)
// 261:     end
// 262:
// 263:     def sum_num_bytes_below_index(index)
// 264:       (0...index).inject(0) do |sum, i|
// 265:         obj = @field_objs[i]
// 266:         if include_obj?(obj)
// 267:           nbytes = obj.do_num_bytes
// 268:           (nbytes.is_a?(Integer) ? sum.ceil : sum) + nbytes
// 269:         else
// 270:           sum
// 271:         end
// 272:       end
// 273:     end
// 274:
// 275:     def include_obj_for_io?(obj)
// 276:       # Used by #do_read and #do_write, to ensure the stream is passed to
// 277:       # DelayedIO objects for delayed processing.
// 278:       include_obj?(obj) || DelayedIO === obj
// 279:     end
// 280:
// 281:     def include_obj?(obj)
// 282:       !obj.has_parameter?(:onlyif) || obj.eval_parameter(:onlyif)
// 283:     end
// 284:
// 285:     # A hash that can be accessed via attributes.
// 286:     class Snapshot < ::Hash # :nodoc:
// 287:       def []=(key, value)
// 288:         super unless value.nil?
// 289:       end
// 290:
// 291:       def respond_to_missing?(symbol, include_all = false)
// 292:         key?(symbol) || super
// 293:       end
// 294:
// 295:       def method_missing(symbol, *args)
// 296:         key?(symbol) ? self[symbol] : super
// 297:       end
// 298:     end
// 299:
// 300:     # Align fields to a multiple of :byte_align
// 301:     module ByteAlignPlugin
// 302:       def do_read(io)
// 303:         offset = 0
// 304:         instantiate_all_objs
// 305:         @field_objs.each do |f|
// 306:           next unless include_obj?(f)
// 307:
// 308:           if align_obj?(f)
// 309:             nbytes = bytes_to_align(f, offset.ceil)
// 310:             offset = offset.ceil + nbytes
// 311:             io.readbytes(nbytes)
// 312:           end
// 313:
// 314:           f.do_read(io)
// 315:           nbytes = f.do_num_bytes
// 316:           offset = (nbytes.is_a?(Integer) ? offset.ceil : offset) + nbytes
// 317:         end
// 318:       end
// 319:
// 320:       def do_write(io)
// 321:         offset = 0
// 322:         instantiate_all_objs
// 323:         @field_objs.each do |f|
// 324:           next unless include_obj?(f)
// 325:
// 326:           if align_obj?(f)
// 327:             nbytes = bytes_to_align(f, offset.ceil)
// 328:             offset = offset.ceil + nbytes
// 329:             io.writebytes("\x00" * nbytes)
// 330:           end
// 331:
// 332:           f.do_write(io)
// 333:           nbytes = f.do_num_bytes
// 334:           offset = (nbytes.is_a?(Integer) ? offset.ceil : offset) + nbytes
// 335:         end
// 336:       end
// 337:
// 338:       def sum_num_bytes_below_index(index)
// 339:         sum = 0
// 340:         @field_objs.each_with_index do |obj, i|
// 341:           next unless include_obj?(obj)
// 342:
// 343:           if align_obj?(obj)
// 344:             sum = sum.ceil + bytes_to_align(obj, sum.ceil)
// 345:           end
// 346:
// 347:           break if i >= index
// 348:
// 349:           nbytes = obj.do_num_bytes
// 350:           sum = (nbytes.is_a?(Integer) ? sum.ceil : sum) + nbytes
// 351:         end
// 352:
// 353:         sum
// 354:       end
// 355:
// 356:       def bytes_to_align(obj, rel_offset)
// 357:         align = obj.eval_parameter(:byte_align)
// 358:         (align - (rel_offset % align)) % align
// 359:       end
// 360:
// 361:       def align_obj?(obj)
// 362:         obj.has_parameter?(:byte_align)
// 363:       end
// 364:     end
// 365:   end
// 366:
// 367:   class StructArgProcessor < BaseArgProcessor
// 368:     def sanitize_parameters!(obj_class, params)
// 369:       sanitize_endian(params)
// 370:       sanitize_search_prefix(params)
// 371:       sanitize_fields(obj_class, params)
// 372:       sanitize_hide(params)
// 373:     end
// 374:
// 375:     #-------------
// 376:     private
// 377:
// 378:     def sanitize_endian(params)
// 379:       params.sanitize_endian(:endian)
// 380:     end
// 381:
// 382:     def sanitize_search_prefix(params)
// 383:       params.sanitize(:search_prefix) do |sprefix|
// 384:         search_prefix = Array(sprefix).collect do |prefix|
// 385:           prefix.to_s.chomp("_")
// 386:         end
// 387:
// 388:         search_prefix - [""]
// 389:       end
// 390:     end
// 391:
// 392:     def sanitize_fields(obj_class, params)
// 393:       params.sanitize_fields(:fields) do |fields, sanitized_fields|
// 394:         fields.each do |ftype, fname, fparams|
// 395:           sanitized_fields.add_field(ftype, fname, fparams)
// 396:         end
// 397:
// 398:         field_names = sanitized_field_names(sanitized_fields)
// 399:         ensure_field_names_are_valid(obj_class, field_names)
// 400:       end
// 401:     end
// 402:
// 403:     def sanitize_hide(params)
// 404:       params.sanitize(:hide) do |hidden|
// 405:         field_names  = sanitized_field_names(params[:fields])
// 406:         hfield_names = hidden_field_names(hidden)
// 407:
// 408:         hfield_names & field_names
// 409:       end
// 410:     end
// 411:
// 412:     def sanitized_field_names(sanitized_fields)
// 413:       sanitized_fields.field_names.compact
// 414:     end
// 415:
// 416:     def hidden_field_names(hidden)
// 417:       (hidden || []).collect(&:to_sym)
// 418:     end
// 419:
// 420:     def ensure_field_names_are_valid(obj_class, field_names)
// 421:       reserved_names = BinData::Struct::RESERVED
// 422:
// 423:       field_names.each do |name|
// 424:         if obj_class.method_defined?(name)
// 425:           raise NameError.new("Rename field '#{name}' in #{obj_class}, " \
// 426:                               "as it shadows an existing method.", name)
// 427:         end
// 428:         if reserved_names.include?(name)
// 429:           raise NameError.new("Rename field '#{name}' in #{obj_class}, " \
// 430:                               "as it is a reserved name.", name)
// 431:         end
// 432:         if field_names.count(name) != 1
// 433:           raise NameError.new("field '#{name}' in #{obj_class}, " \
// 434:                               "is defined multiple times.", name)
// 435:         end
// 436:       end
// 437:     end
// 438:   end
// 439: end
