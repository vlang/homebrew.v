module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/sanitize.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SanitizedEndian {
	big
	little
	big_and_little
}

pub struct SanitizerHints {
pub:
	endian        ?SanitizedEndian
	search_prefix []string
}

@[heap]
pub struct SanitizedPrototype {
pub:
	object_type brew_runtime.Value
	hints       map[string]brew_runtime.Value
mut:
	factory           brew_runtime.Value
	has_factory       bool
	object_class      brew_runtime.Value
	object_parameters &SanitizedParameters = unsafe { nil }
	has_parameters    bool
}

@[heap]
pub struct SanitizedField {
pub:
	name      brew_runtime.Value
	has_name  bool
	prototype &SanitizedPrototype
}

@[heap]
pub struct SanitizedFields {
pub:
	hints map[string]brew_runtime.Value
mut:
	fields []&SanitizedField
}

pub struct SanitizedChoiceEntry {
pub:
	key       brew_runtime.Value
	prototype brew_runtime.Value
}

@[heap]
pub struct SanitizedChoices {
mut:
	entries           []SanitizedChoiceEntry
	default_prototype brew_runtime.Value
	has_default       bool
}

@[heap]
pub struct SanitizedParameters {
pub:
	object_class brew_runtime.Value
mut:
	values           map[string]brew_runtime.Value
	warning_messages []string
}

pub type SanitizeValueBlock = fn(brew_runtime.Value) !brew_runtime.Value

pub type SanitizeFieldsBlock = fn(brew_runtime.Value, mut SanitizedFields) !

fn sanitize_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn sanitize_symbol_value(name string) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${name.trim_left(':')}')
}

fn sanitize_key_name(value brew_runtime.Value) string {
	if value.type_name !in ['String', 'Symbol'] {
		panic("undefined method `to_sym' for ${value.type_name}")
	}
	return value.as_string().trim_left(':')
}

fn sanitize_normalized_map(values map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut normalized := map[string]brew_runtime.Value{}
	for key, value in values {
		normalized[key.trim_left(':')] = value
	}
	return normalized
}

fn sanitize_map_from_value(value brew_runtime.Value) map[string]brew_runtime.Value {
	if value.type_name == 'NilClass' {
		return map[string]brew_runtime.Value{}
	}
	return sanitize_normalized_map(value.as_map() or { panic(err) })
}

fn sanitize_values(value brew_runtime.Value) []brew_runtime.Value {
	if value.type_name == 'NilClass' {
		return []
	}
	if value.type_name == 'Array' {
		return value.as_array() or { panic(err) }
	}
	return [value]
}

fn sanitize_value_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr && left.int_data == right.int_data && left.bool_data == right.bool_data
}

fn sanitize_is_parameter(value brew_runtime.Value) bool {
	return value.type_name.starts_with('BinData::Sanitized')
}

fn sanitize_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn sanitize_is_base_instance(value brew_runtime.Value) bool {
	return 'base_object_address' in value.attributes || 'struct_object_address' in value.attributes
}

fn sanitize_is_class(value brew_runtime.Value) bool {
	return value.type_name in ['Class', 'BinData::Class', 'BinData::IntegerClass',
		'BinData::FloatingPointClass', 'BinData::BitFieldClass']
}

fn sanitize_endian_name(value brew_runtime.Value) ?string {
	if value.type_name == 'BinData::SanitizedBigEndian' {
		return 'big'
	}
	if value.type_name == 'BinData::SanitizedLittleEndian' {
		return 'little'
	}
	if endian := value.attributes['endian'] {
		return endian.trim_left(':')
	}
	if value.type_name in ['String', 'Symbol'] {
		return value.as_string().trim_left(':')
	}
	return none
}

fn sanitizer_hints_from_map(hints map[string]brew_runtime.Value) SanitizerHints {
	mut result := SanitizerHints{}
	if value := hints['endian'] {
		if name := sanitize_endian_name(value) {
			result = SanitizerHints{
				...result
				endian: match name {
					'big' { ?SanitizedEndian(SanitizedEndian.big) }
					'little' { ?SanitizedEndian(SanitizedEndian.little) }
					'big_and_little' { ?SanitizedEndian(SanitizedEndian.big_and_little) }
					else { ?SanitizedEndian(none) }
				}
			}
		}
	}
	if prefix := hints['search_prefix'] {
		result = SanitizerHints{
			...result
			search_prefix: sanitize_values(prefix).map(it.as_string().trim_left(':'))
		}
	}
	return result
}

pub fn sanitizer_hints_from_value(value brew_runtime.Value) SanitizerHints {
	return sanitizer_hints_from_map(sanitize_map_from_value(value))
}

fn registry_hints_for_sanitize(hints map[string]brew_runtime.Value) RegistryHints {
	typed := sanitizer_hints_from_map(hints)
	mut endian := ?IntEndian(none)
	if actual := typed.endian {
		endian = match actual {
			.big { ?IntEndian(IntEndian.big) }
			.little { ?IntEndian(IntEndian.little) }
			.big_and_little { ?IntEndian(none) }
		}
	}
	return RegistryHints{
		endian: endian
		search_prefix: typed.search_prefix
	}
}

fn raw_registry_hints(hints map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut raw := hints.clone()
	if value := raw['endian'] {
		if name := sanitize_endian_name(value) {
			raw['endian'] = sanitize_symbol_value(name)
		}
	}
	return raw
}

fn sanitized_endian_value(endian SanitizedEndian) !brew_runtime.Value {
	return match endian {
		.big {
			brew_runtime.structured_value('BinData::SanitizedBigEndian', 'big', {
				'endian': 'big'
			})
		}
		.little {
			brew_runtime.structured_value('BinData::SanitizedLittleEndian', 'little', {
				'endian': 'little'
			})
		}
		.big_and_little { error('endian: :big or endian: :little is required') }
	}
}

pub fn create_sanitized_endian_value(value brew_runtime.Value) !brew_runtime.Value {
	name := sanitize_endian_name(value) or {
		return error("unknown value for endian '${value.as_string()}'")
	}
	return match name {
		'big' { sanitized_endian_value(.big) }
		'little' { sanitized_endian_value(.little) }
		'big_and_little' { sanitized_endian_value(.big_and_little) }
		else { error("unknown value for endian '${value.as_string().trim_left(':')}'") }
	}
}

fn sanitized_prototype_value(prototype &SanitizedPrototype) brew_runtime.Value {
	mut data := {
		'object_type': prototype.object_type
		'hints':       brew_runtime.map_value(prototype.hints)
	}
	if prototype.has_factory {
		data['factory'] = prototype.factory
	}
	if prototype.has_parameters {
		data['parameters'] = sanitized_parameters_value(prototype.object_parameters)
	}
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedPrototype'
		repr: prototype.object_type.repr
		int_data: i64(u64(voidptr(prototype)))
		map_data: data
		attributes: {
			'sanitized_prototype_address': u64(voidptr(prototype)).str()
		}
	}
}

pub fn sanitized_prototype_boundary_value(prototype &SanitizedPrototype) brew_runtime.Value {
	return sanitized_prototype_value(prototype)
}

fn sanitized_prototype_from_value(value brew_runtime.Value) &SanitizedPrototype {
	address := value.attributes['sanitized_prototype_address'] or {
		panic('expected SanitizedPrototype receiver')
	}
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &SanitizedPrototype(voidptr(actual)) }
}

fn prototype_object_parameters(prototype &SanitizedPrototype) map[string]brew_runtime.Value {
	if prototype.has_parameters {
		return prototype.object_parameters.values.clone()
	}
	if sanitize_is_base_instance(prototype.factory) {
		return base_object_from_value(prototype.factory).params()
	}
	return map[string]brew_runtime.Value{}
}

pub fn new_sanitized_prototype(object_type brew_runtime.Value, object_parameters map[string]brew_runtime.Value, hints map[string]brew_runtime.Value) !&SanitizedPrototype {
	raw_hints := raw_registry_hints(hints)
	mut prototype := &SanitizedPrototype{
		object_type: object_type
		hints: hints.clone()
		factory: sanitize_nil_value()
		object_class: sanitize_nil_value()
	}
	if sanitize_is_base_instance(object_type) {
		prototype.factory = object_type
		prototype.has_factory = true
		prototype.object_class = object_type
		return prototype
	}
	mut object_class := object_type
	if !sanitize_is_class(object_type) {
		mut registry := new_registered_classes_registry()
		object_class = registry.lookup(object_type.as_string().trim_left(':'), registry_hints_for_sanitize(raw_hints))!
	}
	prototype.object_class = object_class
	if sanitize_is_base_instance(object_class) {
		prototype.factory = object_class
		prototype.has_factory = true
	} else {
		parameters := new_sanitized_parameters(object_parameters, object_class, hints)!
		prototype.object_parameters = parameters
		prototype.has_parameters = true
	}
	return prototype
}

pub fn (prototype &SanitizedPrototype) has_parameter(name string) bool {
	if prototype.has_factory {
		if sanitize_is_base_instance(prototype.factory) {
			return name.trim_left(':') in base_object_from_value(prototype.factory).params()
		}
		return name.trim_left(':') in prototype.factory.map_data
	}
	return prototype.has_parameters && prototype.object_parameters.has_parameter(name)
}

pub fn (mut prototype SanitizedPrototype) instantiate(value brew_runtime.Value, has_value bool, parent brew_runtime.Value, has_parent bool) brew_runtime.Value {
	if !prototype.has_factory {
		prototype.factory = initialize_base_object(prototype.object_class, [
			brew_runtime.map_value(prototype_object_parameters(prototype)),
		])
		prototype.has_factory = true
	}
	mut args := [prototype.factory]
	if has_value || has_parent {
		args << if has_value { value } else { sanitize_nil_value() }
	}
	if has_parent {
		args << parent
	}
	return ruby_base_l97_d10_new(...args)
}

fn sanitized_field_value(field &SanitizedField) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedField'
		repr: if field.has_name { field.name.repr } else { 'nil' }
		int_data: i64(u64(voidptr(field)))
		map_data: {
			'field_type': field.prototype.object_type
			'parameters': brew_runtime.map_value(prototype_object_parameters(field.prototype))
			'prototype':  sanitized_prototype_value(field.prototype)
		}
		attributes: {
			'sanitized_field_address': u64(voidptr(field)).str()
			'name':                    if field.has_name {
				field.name.as_string().trim_left(':')} else {
				''}
			'has_name':                field.has_name.str()
		}
	}
}

pub fn sanitized_field_boundary_value(field &SanitizedField) brew_runtime.Value {
	return sanitized_field_value(field)
}

fn sanitized_field_from_value(value brew_runtime.Value) &SanitizedField {
	if address := value.attributes['sanitized_field_address'] {
		actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
		return unsafe { &SanitizedField(voidptr(actual)) }
	}
	definition := sanitized_struct_field_from_value(value)
	return new_sanitized_field(if definition.has_name {
		sanitize_symbol_value(definition.name)
	} else {
		sanitize_nil_value()
	}, definition.field_type, definition.parameters, {}) or { panic(err) }
}

pub fn new_sanitized_field(name brew_runtime.Value, field_type brew_runtime.Value, field_parameters map[string]brew_runtime.Value, hints map[string]brew_runtime.Value) !&SanitizedField {
	return &SanitizedField{
		name: name
		has_name: name.type_name != 'NilClass'
		prototype: new_sanitized_prototype(field_type, field_parameters, hints)!
	}
}

pub fn (field &SanitizedField) name_as_symbol() brew_runtime.Value {
	if !field.has_name {
		return sanitize_nil_value()
	}
	return sanitize_symbol_value(field.name.as_string())
}

pub fn (field &SanitizedField) has_parameter(name string) bool {
	return field.prototype.has_parameter(name)
}

pub fn (field &SanitizedField) instantiate(value brew_runtime.Value, has_value bool, parent brew_runtime.Value, has_parent bool) brew_runtime.Value {
	mut prototype := field.prototype
	return prototype.instantiate(value, has_value, parent, has_parent)
}

fn sanitized_fields_value(fields &SanitizedFields) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedFields'
		repr: fields.fields.map(if it.has_name { it.name.repr } else { 'nil' }).str()
		int_data: i64(u64(voidptr(fields)))
		array_data: fields.fields.map(sanitized_field_value(it))
		map_data: {
			'hints': brew_runtime.map_value(fields.hints)
		}
		attributes: {
			'sanitized_fields_address': u64(voidptr(fields)).str()
		}
	}
}

pub fn sanitized_fields_boundary_value(fields &SanitizedFields) brew_runtime.Value {
	return sanitized_fields_value(fields)
}

fn sanitized_fields_from_value(value brew_runtime.Value) &SanitizedFields {
	if address := value.attributes['sanitized_fields_address'] {
		actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
		return unsafe { &SanitizedFields(voidptr(actual)) }
	}
	hints := if encoded := value.map_data['hints'] {
		sanitize_map_from_value(encoded)
	} else {
		map[string]brew_runtime.Value{}
	}
	mut fields := new_sanitized_fields(hints, none)
	for definition in sanitized_struct_fields_from_value(value) {
		fields.add_field(definition.field_type, if definition.has_name {
			sanitize_symbol_value(definition.name)
		} else {
			sanitize_nil_value()
		}, definition.parameters) or { panic(err) }
	}
	return fields
}

pub fn new_sanitized_fields(hints map[string]brew_runtime.Value, base_fields ?&SanitizedFields) &SanitizedFields {
	mut fields := []&SanitizedField{}
	if base := base_fields {
		fields = base.fields.clone()
	}
	return &SanitizedFields{
		hints: hints.clone()
		fields: fields
	}
}

pub fn (mut fields SanitizedFields) add_field(field_type brew_runtime.Value, name brew_runtime.Value, parameters map[string]brew_runtime.Value) ! {
	actual_name := if name.type_name == 'String' && name.as_string() == '' {
		sanitize_nil_value()
	} else {
		name
	}
	fields.fields << new_sanitized_field(actual_name, field_type, parameters, fields.hints)!
}

pub fn (fields &SanitizedFields) raw_fields() []&SanitizedField {
	return fields.fields.clone()
}

pub fn (fields &SanitizedFields) at(index int) ?&SanitizedField {
	actual := if index < 0 { fields.fields.len + index } else { index }
	if actual < 0 || actual >= fields.fields.len {
		return none
	}
	return fields.fields[actual]
}

pub fn (fields &SanitizedFields) field_names() []brew_runtime.Value {
	return fields.fields.map(it.name_as_symbol())
}

pub fn (fields &SanitizedFields) field_named(name string) ?&SanitizedField {
	actual := name.trim_left(':')
	for field in fields.fields {
		if field.has_name && field.name.as_string().trim_left(':') == actual {
			return field
		}
	}
	return none
}

pub fn (fields &SanitizedFields) all_field_names_blank() bool {
	return fields.fields.all(!it.has_name)
}

pub fn (fields &SanitizedFields) no_field_names_blank() bool {
	return fields.fields.all(it.has_name)
}

pub fn (fields &SanitizedFields) any_field_has_parameter(name string) bool {
	return fields.fields.any(it.has_parameter(name))
}

fn sanitized_choices_value(choices &SanitizedChoices) brew_runtime.Value {
	mut data := map[string]brew_runtime.Value{}
	if choices.has_default {
		data['default'] = choices.default_prototype
	}
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedChoices'
		repr: choices.entries.map(it.key.repr).str()
		int_data: i64(u64(voidptr(choices)))
		array_data: choices.entries.map(brew_runtime.array_value([it.key, it.prototype]))
		map_data: data
		attributes: {
			'sanitized_choices_address': u64(voidptr(choices)).str()
		}
	}
}

pub fn sanitized_choices_boundary_value(choices &SanitizedChoices) brew_runtime.Value {
	return sanitized_choices_value(choices)
}

fn sanitized_choices_from_value(value brew_runtime.Value) &SanitizedChoices {
	address := value.attributes['sanitized_choices_address'] or { panic('expected SanitizedChoices receiver') }
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &SanitizedChoices(voidptr(actual)) }
}

fn sanitized_choice_prototype(value brew_runtime.Value, hints map[string]brew_runtime.Value) !brew_runtime.Value {
	if sanitize_is_parameter(value) {
		return value
	}
	parts := if value.type_name == 'Array' {
		value.as_array() or { panic(err) }
	} else {
		[
			value,
		]
	}
	if parts.len == 0 {
		return error('choice prototype must specify an object type')
	}
	parameters := if parts.len > 1 {
		sanitize_map_from_value(parts[1])
	} else {
		map[string]brew_runtime.Value{}
	}
	return sanitized_prototype_value(new_sanitized_prototype(parts[0], parameters, hints)!)
}

fn raw_choice_entries(choices brew_runtime.Value) []SanitizedChoiceEntry {
	mut entries := []SanitizedChoiceEntry{}
	if choices.type_name == 'Hash' {
		for key, value in choices.map_data {
			entries << SanitizedChoiceEntry{
				key: if key.trim_left(':') == 'default' {
					sanitize_symbol_value('default')} else {
					brew_runtime.string_value(key)}
				prototype: value
			}
		}
		return entries
	}
	for index, value in sanitize_values(choices) {
		if value.type_name == 'NilClass' {
			continue
		}
		if value.type_name == 'Array' {
			pair := value.as_array() or { panic(err) }
			if pair.len == 2 && pair[0].type_name !in ['Symbol', 'String'] {
				entries << SanitizedChoiceEntry{
					key: pair[0]
					prototype: pair[1]
				}
				continue
			}
		}
		entries << SanitizedChoiceEntry{
			key: brew_runtime.int_value(index)
			prototype: value
		}
	}
	return entries
}

pub fn new_sanitized_choices(choices brew_runtime.Value, hints map[string]brew_runtime.Value) !&SanitizedChoices {
	mut result := &SanitizedChoices{
		default_prototype: sanitize_nil_value()
	}
	for entry in raw_choice_entries(choices) {
		prototype := sanitized_choice_prototype(entry.prototype, hints)!
		if entry.key.type_name == 'Symbol' && entry.key.as_string().trim_left(':') == 'default' {
			result.default_prototype = prototype
			result.has_default = true
		} else {
			result.entries << SanitizedChoiceEntry{
				key: entry.key
				prototype: prototype
			}
		}
	}
	return result
}

pub fn (choices &SanitizedChoices) get(key brew_runtime.Value) ?brew_runtime.Value {
	for entry in choices.entries {
		if sanitize_value_equal(entry.key, key) {
			return entry.prototype
		}
	}
	if choices.has_default {
		return choices.default_prototype
	}
	return none
}

fn sanitized_parameters_value(parameters &SanitizedParameters) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SanitizedParameters'
		repr: parameters.values.str()
		int_data: i64(u64(voidptr(parameters)))
		string_array_data: parameters.warning_messages.clone()
		map_data: parameters.values
		attributes: {
			'sanitized_parameters_address': u64(voidptr(parameters)).str()
		}
	}
}

pub fn sanitized_parameters_boundary_value(parameters &SanitizedParameters) brew_runtime.Value {
	return sanitized_parameters_value(parameters)
}

fn sanitized_parameters_from_value(value brew_runtime.Value) &SanitizedParameters {
	address := value.attributes['sanitized_parameters_address'] or {
		panic('expected SanitizedParameters receiver')
	}
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &SanitizedParameters(voidptr(actual)) }
}

pub fn sanitize_parameters_value(parameters brew_runtime.Value, object_class brew_runtime.Value) !brew_runtime.Value {
	if parameters.type_name == 'BinData::SanitizedParameters' {
		return parameters
	}
	return sanitized_parameters_value(new_sanitized_parameters(sanitize_map_from_value(parameters), object_class, map[string]brew_runtime.Value{})!)
}

pub fn new_sanitized_parameters(values map[string]brew_runtime.Value, object_class brew_runtime.Value, hints map[string]brew_runtime.Value) !&SanitizedParameters {
	mut merged := sanitize_normalized_map(values)
	if endian := hints['endian'] {
		current := merged['endian'] or { sanitize_nil_value() }
		if sanitize_truthy(endian) && !sanitize_truthy(current) {
			merged['endian'] = endian
		}
	}
	if prefix := hints['search_prefix'] {
		if sanitize_truthy(prefix) && sanitize_values(prefix).len > 0 {
			mut prefixes := sanitize_values(merged['search_prefix'] or { sanitize_nil_value() })
			prefixes << sanitize_values(prefix)
			merged['search_prefix'] = brew_runtime.array_value(prefixes)
		}
	}
	mut parameters := &SanitizedParameters{
		object_class: object_class
		values: merged
	}
	parameters.sanitize_all()!
	return parameters
}

pub fn (parameters &SanitizedParameters) has_parameter(name string) bool {
	return name.trim_left(':') in parameters.values
}

pub fn (parameters &SanitizedParameters) has_at_least_one_of(names []string) bool {
	return names.any(parameters.has_parameter(it))
}

pub fn (mut parameters SanitizedParameters) warn_replacement_parameter(bad_key string, suggested_key string) ?string {
	if !parameters.has_parameter(bad_key) {
		return none
	}
	message := ':${bad_key.trim_left(':')} is not used with ${parameters.object_class.repr}.  You probably want to change this to :${suggested_key.trim_left(':')}'
	parameters.warning_messages << message
	eprintln(message)
	return message
}

fn sanitize_value_converts_to_integer(value brew_runtime.Value) bool {
	return value.type_name in ['Integer', 'Float', 'Symbol', 'Proc', 'Function'] || 'arity' in value.attributes || 'to_int' in value.attributes
}

pub fn (parameters &SanitizedParameters) must_be_integer(names []string) ! {
	for original_name in names {
		name := original_name.trim_left(':')
		if parameter := parameters.values[name] {
			if !sanitize_value_converts_to_integer(parameter) {
				return error("parameter '${name}' in ${parameters.object_class.repr} must evaluate to an integer, got ${parameter.type_name}")
			}
		}
	}
}

pub fn (mut parameters SanitizedParameters) rename_parameter(old_key string, new_key string) ?brew_runtime.Value {
	old_name := old_key.trim_left(':')
	if value := parameters.values[old_name] {
		parameters.values.delete(old_name)
		parameters.values[new_key.trim_left(':')] = value
		return value
	}
	return none
}

pub fn (parameters &SanitizedParameters) needs_sanitizing(key string) bool {
	name := key.trim_left(':')
	return name in parameters.values && !sanitize_is_parameter(parameters.values[name])
}

pub fn (mut parameters SanitizedParameters) sanitize_value(key string, block SanitizeValueBlock) !brew_runtime.Value {
	name := key.trim_left(':')
	if !parameters.needs_sanitizing(name) {
		return sanitize_nil_value()
	}
	parameters.values[name] = block(parameters.values[name])!
	return parameters.values[name]
}

pub fn (mut parameters SanitizedParameters) sanitize_object_prototype(key string) ! {
	name := key.trim_left(':')
	if !parameters.needs_sanitizing(name) {
		return
	}
	parts := sanitize_values(parameters.values[name])
	if parts.len == 0 {
		return error("parameter '${name}' must specify an object type")
	}
	object_parameters := if parts.len > 1 {
		sanitize_map_from_value(parts[1])
	} else {
		map[string]brew_runtime.Value{}
	}
	parameters.values[name] = sanitized_prototype_value(new_sanitized_prototype(parts[0], object_parameters, parameters.hints())!)
}

pub fn (mut parameters SanitizedParameters) sanitize_fields(key string, block SanitizeFieldsBlock) ! {
	name := key.trim_left(':')
	if !parameters.needs_sanitizing(name) {
		return
	}
	mut fields := new_sanitized_fields(parameters.hints(), none)
	block(parameters.values[name], mut fields)!
	parameters.values[name] = sanitized_fields_value(fields)
}

pub fn (mut parameters SanitizedParameters) sanitize_choices(key string, block SanitizeValueBlock) ! {
	name := key.trim_left(':')
	if !parameters.needs_sanitizing(name) {
		return
	}
	choices := block(parameters.values[name])!
	parameters.values[name] = sanitized_choices_value(new_sanitized_choices(choices, parameters.hints())!)
}

pub fn (mut parameters SanitizedParameters) sanitize_endian(key string) ! {
	name := key.trim_left(':')
	if parameters.needs_sanitizing(name) {
		parameters.values[name] = create_sanitized_endian_value(parameters.values[name])!
	}
}

pub fn (parameters &SanitizedParameters) create_sanitized_parameters(values map[string]brew_runtime.Value, object_class brew_runtime.Value) !&SanitizedParameters {
	return new_sanitized_parameters(values, object_class, parameters.hints())
}

pub fn (parameters &SanitizedParameters) hints() map[string]brew_runtime.Value {
	return {
		'endian':        parameters.values['endian'] or { sanitize_nil_value() }
		'search_prefix': parameters.values['search_prefix'] or { sanitize_nil_value() }
	}
}

pub fn (parameters &SanitizedParameters) ensure_no_nil_values() ! {
	for key, value in parameters.values {
		if value.type_name == 'NilClass' {
			return error("parameter '${key}' has nil value in ${parameters.object_class.repr}")
		}
	}
}

pub fn (mut parameters SanitizedParameters) merge_default_parameters() {
	for key, value in accepted_parameters_for_plugin(parameters.object_class).defaults() {
		if key !in parameters.values {
			parameters.values[key] = value
		}
	}
}

pub fn (parameters &SanitizedParameters) ensure_mandatory_parameters_exist() ! {
	for key in accepted_parameters_for_plugin(parameters.object_class).mandatory() {
		if key !in parameters.values {
			return error("parameter '${key}' must be specified in ${parameters.object_class.repr}")
		}
	}
}

pub fn (parameters &SanitizedParameters) ensure_mutual_exclusion_of_parameters() ! {
	if parameters.values.len < 2 {
		return
	}
	for pair in accepted_parameters_for_plugin(parameters.object_class).mutually_exclusive() {
		if pair.len >= 2 && pair[0] in parameters.values && pair[1] in parameters.values {
			return error("params '${pair[0]}' and '${pair[1]}' are mutually exclusive in ${parameters.object_class.repr}")
		}
	}
}

fn sanitize_struct_fields_block(raw brew_runtime.Value, mut fields SanitizedFields) ! {
	for definition in sanitize_raw_struct_fields(raw) {
		fields.add_field(definition.field_type, if definition.has_name {
			sanitize_symbol_value(definition.name)
		} else {
			sanitize_nil_value()
		}, definition.parameters)!
	}
}

fn sanitize_identity_block(value brew_runtime.Value) !brew_runtime.Value {
	return value
}

fn (mut parameters SanitizedParameters) sanitize_struct_processor() ! {
	parameters.sanitize_endian('endian')!
	if parameters.needs_sanitizing('search_prefix') {
		mut prefixes := []string{}
		for prefix in sanitize_values(parameters.values['search_prefix']) {
			trimmed := struct_chomp_underscore(prefix.as_string())
			if trimmed.len > 0 {
				prefixes << trimmed
			}
		}
		parameters.values['search_prefix'] = brew_runtime.string_array_value(prefixes)
	}
	parameters.sanitize_fields('fields', sanitize_struct_fields_block)!
	if fields_value := parameters.values['fields'] {
		fields := sanitized_fields_from_value(fields_value)
		validate_struct_field_names(parameters.object_class, fields.field_names().filter(it.type_name != 'NilClass').map(it.as_string().trim_left(':')))!
	}
	if parameters.needs_sanitizing('hide') {
		fields := if fields_value := parameters.values['fields'] {
			sanitized_fields_from_value(fields_value)
		} else {
			new_sanitized_fields({}, none)
		}
		field_names := fields.field_names().filter(it.type_name != 'NilClass').map(it.as_string().trim_left(':'))
		mut hidden := []string{}
		for value in sanitize_values(parameters.values['hide']) {
			name := sanitize_key_name(value)
			if name in field_names && name !in hidden {
				hidden << name
			}
		}
		parameters.values['hide'] = brew_runtime.string_array_value(hidden)
	}
}

fn (mut parameters SanitizedParameters) sanitize_choice_processor() ! {
	parameters.sanitize_choices('choices', sanitize_identity_block)!
}

fn (mut parameters SanitizedParameters) invoke_arg_processor() ! {
	processor := parameters.object_class.attributes['arg_processor'] or { 'base' }
	match processor {
		'struct', 'record' { parameters.sanitize_struct_processor()! }
		'choice' { parameters.sanitize_choice_processor()! }
		else {}
	}
}

pub fn (mut parameters SanitizedParameters) sanitize_all() ! {
	parameters.ensure_no_nil_values()!
	parameters.merge_default_parameters()
	parameters.invoke_arg_processor()!
	parameters.ensure_mandatory_parameters_exist()!
	parameters.ensure_mutual_exclusion_of_parameters()!
}

// Ruby method `initialize(obj_type, obj_params, hints)` at line 9.
pub fn ruby_sanitize_l9_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedPrototype#initialize requires object type, parameters and hints')
	}
	return sanitized_prototype_value(new_sanitized_prototype(args[0], sanitize_map_from_value(args[1]), sanitize_map_from_value(args[2])) or { panic(err) })
}

// Ruby method `has_parameter?(param)` at line 30.
pub fn ruby_sanitize_l30_d2_has_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedPrototype#has_parameter? requires a receiver and parameter')
	}
	return brew_runtime.bool_value(sanitized_prototype_from_value(args[0]).has_parameter(sanitize_key_name(args[1])))
}

// Ruby method `instantiate(value = nil, parent = nil)` at line 38.
pub fn ruby_sanitize_l38_d3_instantiate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedPrototype#instantiate requires a receiver')
	}
	mut prototype := sanitized_prototype_from_value(args[0])
	return prototype.instantiate(if args.len > 1 { args[1] } else { sanitize_nil_value() }, args.len > 1 && args[1].type_name != 'NilClass', if args.len > 2 {
		args[2]
	} else {
		sanitize_nil_value()
	}, args.len > 2 && args[2].type_name != 'NilClass')
}

// Ruby method `initialize(name, field_type, field_params, hints)` at line 47.
pub fn ruby_sanitize_l47_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('SanitizedField#initialize requires name, type, parameters and hints')
	}
	return sanitized_field_value(new_sanitized_field(args[0], args[1], sanitize_map_from_value(args[2]), sanitize_map_from_value(args[3])) or { panic(err) })
}

// Ruby attr_reader `attr_reader :prototype, :name` at line 52.
pub fn ruby_sanitize_l52_d5_prototype(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedField#prototype requires a receiver')
	}
	return sanitized_prototype_value(sanitized_field_from_value(args[0]).prototype)
}

// Ruby attr_reader `attr_reader :prototype, :name` at line 52.
pub fn ruby_sanitize_l52_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedField#name requires a receiver')
	}
	field := sanitized_field_from_value(args[0])
	return if field.has_name { field.name } else { sanitize_nil_value() }
}

// Ruby method `name_as_sym` at line 54.
pub fn ruby_sanitize_l54_d7_name_as_sym(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedField#name_as_sym requires a receiver')
	}
	return sanitized_field_from_value(args[0]).name_as_symbol()
}

// Ruby method `has_parameter?(param)` at line 58.
pub fn ruby_sanitize_l58_d8_has_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedField#has_parameter? requires a receiver and parameter')
	}
	return brew_runtime.bool_value(sanitized_field_from_value(args[0]).has_parameter(sanitize_key_name(args[1])))
}

// Ruby method `instantiate(value = nil, parent = nil)` at line 62.
pub fn ruby_sanitize_l62_d9_instantiate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedField#instantiate requires a receiver')
	}
	return sanitized_field_from_value(args[0]).instantiate(if args.len > 1 {
		args[1]
	} else {
		sanitize_nil_value()
	}, args.len > 1 && args[1].type_name != 'NilClass', if args.len > 2 {
		args[2]
	} else {
		sanitize_nil_value()
	}, args.len > 2 && args[2].type_name != 'NilClass')
}

// Ruby method `initialize(hints, base_fields = nil)` at line 71.
pub fn ruby_sanitize_l71_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#initialize requires hints')
	}
	base := if args.len > 1 && args[1].type_name != 'NilClass' {
		?&SanitizedFields(sanitized_fields_from_value(args[1]))
	} else {
		?&SanitizedFields(none)
	}
	return sanitized_fields_value(new_sanitized_fields(sanitize_map_from_value(args[0]), base))
}

// Ruby method `add_field(type, name, params)` at line 76.
pub fn ruby_sanitize_l76_d11_add_field(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('SanitizedFields#add_field requires a receiver, type, name and parameters')
	}
	mut fields := sanitized_fields_from_value(args[0])
	fields.add_field(args[1], args[2], sanitize_map_from_value(args[3])) or { panic(err) }
	return sanitized_field_value(fields.fields.last())
}

// Ruby method `raw_fields` at line 82.
pub fn ruby_sanitize_l82_d12_raw_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#raw_fields requires a receiver')
	}
	return brew_runtime.array_value(sanitized_fields_from_value(args[0]).raw_fields().map(sanitized_field_value(it)))
}

// Ruby method `[](idx)` at line 86.
pub fn ruby_sanitize_l86_d13_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedFields#[] requires a receiver and index')
	}
	field := sanitized_fields_from_value(args[0]).at(int(args[1].as_int() or { panic(err) })) or {
		return sanitize_nil_value()
	}
	return sanitized_field_value(field)
}

// Ruby method `empty?` at line 90.
pub fn ruby_sanitize_l90_d14_empty(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#empty? requires a receiver')
	}
	return brew_runtime.bool_value(sanitized_fields_from_value(args[0]).fields.len == 0)
}

// Ruby method `length` at line 94.
pub fn ruby_sanitize_l94_d15_length(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#length requires a receiver')
	}
	return brew_runtime.int_value(sanitized_fields_from_value(args[0]).fields.len)
}

// Ruby method `each(&block)` at line 98.
pub fn ruby_sanitize_l98_d16_each(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_sanitize_l82_d12_raw_fields(...args)
}

// Ruby method `field_names` at line 102.
pub fn ruby_sanitize_l102_d17_field_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#field_names requires a receiver')
	}
	return brew_runtime.array_value(sanitized_fields_from_value(args[0]).field_names())
}

// Ruby method `field_name?(name)` at line 106.
pub fn ruby_sanitize_l106_d18_field_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedFields#field_name? requires a receiver and name')
	}
	field := sanitized_fields_from_value(args[0]).field_named(sanitize_key_name(args[1])) or {
		return sanitize_nil_value()
	}
	return sanitized_field_value(field)
}

// Ruby method `all_field_names_blank?` at line 110.
pub fn ruby_sanitize_l110_d19_all_field_names_blank(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#all_field_names_blank? requires a receiver')
	}
	return brew_runtime.bool_value(sanitized_fields_from_value(args[0]).all_field_names_blank())
}

// Ruby method `no_field_names_blank?` at line 114.
pub fn ruby_sanitize_l114_d20_no_field_names_blank(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedFields#no_field_names_blank? requires a receiver')
	}
	return brew_runtime.bool_value(sanitized_fields_from_value(args[0]).no_field_names_blank())
}

// Ruby method `any_field_has_parameter?(parameter)` at line 118.
pub fn ruby_sanitize_l118_d21_any_field_has_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedFields#any_field_has_parameter? requires a receiver and parameter')
	}
	return brew_runtime.bool_value(sanitized_fields_from_value(args[0]).any_field_has_parameter(sanitize_key_name(args[1])))
}

// Ruby method `initialize(choices, hints)` at line 125.
pub fn ruby_sanitize_l125_d22_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedChoices#initialize requires choices and hints')
	}
	return sanitized_choices_value(new_sanitized_choices(args[0], sanitize_map_from_value(args[1])) or {
		panic(err)
	})
}

// Ruby method `[](key)` at line 143.
pub fn ruby_sanitize_l143_d23_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedChoices#[] requires a receiver and key')
	}
	return sanitized_choices_from_value(args[0]).get(args[1]) or { sanitize_nil_value() }
}

// Ruby method `endian` at line 150.
pub fn ruby_sanitize_l150_d24_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return sanitize_symbol_value('big')
}

// Ruby method `endian` at line 156.
pub fn ruby_sanitize_l156_d25_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return sanitize_symbol_value('little')
}

// Ruby method `sanitize(parameters, the_class)` at line 179.
pub fn ruby_sanitize_l179_d26_sanitize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters.sanitize requires parameters and class')
	}
	return sanitize_parameters_value(args[0], args[1]) or { panic(err) }
}

// Ruby method `initialize(parameters, the_class, hints)` at line 188.
pub fn ruby_sanitize_l188_d27_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedParameters#initialize requires parameters, class and hints')
	}
	return sanitized_parameters_value(new_sanitized_parameters(sanitize_map_from_value(args[0]), args[1], sanitize_map_from_value(args[2])) or { panic(err) })
}

// Ruby alias `alias has_parameter? key?` at line 204.
pub fn ruby_sanitize_l204_d28_has_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#has_parameter? requires a receiver and key')
	}
	return brew_runtime.bool_value(sanitized_parameters_from_value(args[0]).has_parameter(sanitize_key_name(args[1])))
}

// Ruby method `has_at_least_one_of?(*keys)` at line 206.
pub fn ruby_sanitize_l206_d29_has_at_least_one_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#has_at_least_one_of? requires a receiver')
	}
	return brew_runtime.bool_value(sanitized_parameters_from_value(args[0]).has_at_least_one_of(args[1..].map(sanitize_key_name(it))))
}

// Ruby method `warn_replacement_parameter(bad_key, suggested_key)` at line 214.
pub fn ruby_sanitize_l214_d30_warn_replacement_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedParameters#warn_replacement_parameter requires a receiver and two keys')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.warn_replacement_parameter(sanitize_key_name(args[1]), sanitize_key_name(args[2]))
	return sanitize_nil_value()
}

// Ruby method `must_be_integer(*keys)` at line 230.
pub fn ruby_sanitize_l230_d31_must_be_integer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#must_be_integer requires a receiver')
	}
	sanitized_parameters_from_value(args[0]).must_be_integer(args[1..].map(sanitize_key_name(it))) or {
		panic(err)
	}
	return sanitize_nil_value()
}

// Ruby method `rename_parameter(old_key, new_key)` at line 244.
pub fn ruby_sanitize_l244_d32_rename_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedParameters#rename_parameter requires a receiver and two keys')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	return parameters.rename_parameter(sanitize_key_name(args[1]), sanitize_key_name(args[2])) or {
		sanitize_nil_value()
	}
}

// Ruby method `sanitize_object_prototype(key)` at line 250.
pub fn ruby_sanitize_l250_d33_sanitize_object_prototype(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#sanitize_object_prototype requires a receiver and key')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.sanitize_object_prototype(sanitize_key_name(args[1])) or { panic(err) }
	return parameters.values[sanitize_key_name(args[1])] or { sanitize_nil_value() }
}

// Ruby method `sanitize_fields(key, &block)` at line 256.
pub fn ruby_sanitize_l256_d34_sanitize_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#sanitize_fields requires a receiver and key')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.sanitize_fields(sanitize_key_name(args[1]), sanitize_struct_fields_block) or { panic(err) }
	return parameters.values[sanitize_key_name(args[1])] or { sanitize_nil_value() }
}

// Ruby method `sanitize_choices(key, &block)` at line 264.
pub fn ruby_sanitize_l264_d35_sanitize_choices(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#sanitize_choices requires a receiver and key')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.sanitize_choices(sanitize_key_name(args[1]), sanitize_identity_block) or { panic(err) }
	return parameters.values[sanitize_key_name(args[1])] or { sanitize_nil_value() }
}

// Ruby method `sanitize_endian(key)` at line 270.
pub fn ruby_sanitize_l270_d36_sanitize_endian(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#sanitize_endian requires a receiver and key')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.sanitize_endian(sanitize_key_name(args[1])) or { panic(err) }
	return parameters.values[sanitize_key_name(args[1])] or { sanitize_nil_value() }
}

// Ruby method `sanitize(key, &block)` at line 274.
pub fn ruby_sanitize_l274_d37_sanitize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#sanitize requires a receiver and key')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	key := sanitize_key_name(args[1])
	if !parameters.needs_sanitizing(key) {
		return sanitize_nil_value()
	}
	parameters.values[key] = if args.len > 2 { args[2] } else { parameters.values[key] }
	return parameters.values[key]
}

// Ruby method `create_sanitized_params(params, the_class)` at line 280.
pub fn ruby_sanitize_l280_d38_create_sanitized_params(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedParameters#create_sanitized_params requires a receiver, parameters and class')
	}
	return sanitized_parameters_value(sanitized_parameters_from_value(args[0]).create_sanitized_parameters(sanitize_map_from_value(args[1]), args[2]) or { panic(err) })
}

// Ruby method `hints` at line 284.
pub fn ruby_sanitize_l284_d39_hints(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#hints requires a receiver')
	}
	return brew_runtime.map_value(sanitized_parameters_from_value(args[0]).hints())
}

// Ruby method `sanitize!` at line 291.
pub fn ruby_sanitize_l291_d40_sanitize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#sanitize! requires a receiver')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.sanitize_all() or { panic(err) }
	return args[0]
}

// Ruby method `needs_sanitizing?(key)` at line 301.
pub fn ruby_sanitize_l301_d41_needs_sanitizing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#needs_sanitizing? requires a receiver and key')
	}
	return brew_runtime.bool_value(sanitized_parameters_from_value(args[0]).needs_sanitizing(sanitize_key_name(args[1])))
}

// Ruby method `ensure_no_nil_values` at line 305.
pub fn ruby_sanitize_l305_d42_ensure_no_nil_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#ensure_no_nil_values requires a receiver')
	}
	sanitized_parameters_from_value(args[0]).ensure_no_nil_values() or { panic(err) }
	return sanitize_nil_value()
}

// Ruby method `merge_default_parameters!` at line 314.
pub fn ruby_sanitize_l314_d43_merge_default_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#merge_default_parameters! requires a receiver')
	}
	mut parameters := sanitized_parameters_from_value(args[0])
	parameters.merge_default_parameters()
	return args[0]
}

// Ruby method `ensure_mandatory_parameters_exist` at line 320.
pub fn ruby_sanitize_l320_d44_ensure_mandatory_parameters_exist(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#ensure_mandatory_parameters_exist requires a receiver')
	}
	sanitized_parameters_from_value(args[0]).ensure_mandatory_parameters_exist() or { panic(err) }
	return sanitize_nil_value()
}

// Ruby method `ensure_mutual_exclusion_of_parameters` at line 329.
pub fn ruby_sanitize_l329_d45_ensure_mutual_exclusion_of_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#ensure_mutual_exclusion_of_parameters requires a receiver')
	}
	sanitized_parameters_from_value(args[0]).ensure_mutual_exclusion_of_parameters() or { panic(err) }
	return sanitize_nil_value()
}

// Ruby method `create_sanitized_endian(endian)` at line 340.
pub fn ruby_sanitize_l340_d46_create_sanitized_endian(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#create_sanitized_endian requires a receiver and endian')
	}
	return create_sanitized_endian_value(args[1]) or { panic(err) }
}

// Ruby method `create_sanitized_choices(choices)` at line 352.
pub fn ruby_sanitize_l352_d47_create_sanitized_choices(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SanitizedParameters#create_sanitized_choices requires a receiver and choices')
	}
	return sanitized_choices_value(new_sanitized_choices(args[1], sanitized_parameters_from_value(args[0]).hints()) or {
		panic(err)
	})
}

// Ruby method `create_sanitized_fields` at line 356.
pub fn ruby_sanitize_l356_d48_create_sanitized_fields(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SanitizedParameters#create_sanitized_fields requires a receiver')
	}
	return sanitized_fields_value(new_sanitized_fields(sanitized_parameters_from_value(args[0]).hints(), none))
}

// Ruby method `create_sanitized_object_prototype(obj_type, obj_params)` at line 360.
pub fn ruby_sanitize_l360_d49_create_sanitized_object_prototype(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('SanitizedParameters#create_sanitized_object_prototype requires a receiver, type and parameters')
	}
	return sanitized_prototype_value(new_sanitized_prototype(args[1], sanitize_map_from_value(args[2]), sanitized_parameters_from_value(args[0]).hints()) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/registry'
// 2:
// 3: module BinData
// 4:
// 5:   # Subclasses of this are sanitized
// 6:   class SanitizedParameter; end
// 7:
// 8:   class SanitizedPrototype < SanitizedParameter
// 9:     def initialize(obj_type, obj_params, hints)
// 10:       raw_hints = hints.dup
// 11:       if raw_hints[:endian].respond_to?(:endian)
// 12:         raw_hints[:endian] = raw_hints[:endian].endian
// 13:       end
// 14:       obj_params ||= {}
// 15:
// 16:       if BinData::Base === obj_type
// 17:         obj_class = obj_type
// 18:       else
// 19:         obj_class = RegisteredClasses.lookup(obj_type, raw_hints)
// 20:       end
// 21:
// 22:       if BinData::Base === obj_class
// 23:         @factory = obj_class
// 24:       else
// 25:         @obj_class  = obj_class
// 26:         @obj_params = SanitizedParameters.new(obj_params, @obj_class, hints)
// 27:       end
// 28:     end
// 29:
// 30:     def has_parameter?(param)
// 31:       if defined? @factory
// 32:         @factory.has_parameter?(param)
// 33:       else
// 34:         @obj_params.has_parameter?(param)
// 35:       end
// 36:     end
// 37:
// 38:     def instantiate(value = nil, parent = nil)
// 39:       @factory ||= @obj_class.new(@obj_params)
// 40:
// 41:       @factory.new(value, parent)
// 42:     end
// 43:   end
// 44:   #----------------------------------------------------------------------------
// 45:
// 46:   class SanitizedField < SanitizedParameter
// 47:     def initialize(name, field_type, field_params, hints)
// 48:       @name      = name
// 49:       @prototype = SanitizedPrototype.new(field_type, field_params, hints)
// 50:     end
// 51:
// 52:     attr_reader :prototype, :name
// 53:
// 54:     def name_as_sym
// 55:       @name&.to_sym
// 56:     end
// 57:
// 58:     def has_parameter?(param)
// 59:       @prototype.has_parameter?(param)
// 60:     end
// 61:
// 62:     def instantiate(value = nil, parent = nil)
// 63:       @prototype.instantiate(value, parent)
// 64:     end
// 65:   end
// 66:   #----------------------------------------------------------------------------
// 67:
// 68:   class SanitizedFields < SanitizedParameter
// 69:     include Enumerable
// 70:
// 71:     def initialize(hints, base_fields = nil)
// 72:       @hints = hints
// 73:       @fields =  base_fields ? base_fields.raw_fields : []
// 74:     end
// 75:
// 76:     def add_field(type, name, params)
// 77:       name = nil if name == ""
// 78:
// 79:       @fields << SanitizedField.new(name, type, params, @hints)
// 80:     end
// 81:
// 82:     def raw_fields
// 83:       @fields.dup
// 84:     end
// 85:
// 86:     def [](idx)
// 87:       @fields[idx]
// 88:     end
// 89:
// 90:     def empty?
// 91:       @fields.empty?
// 92:     end
// 93:
// 94:     def length
// 95:       @fields.length
// 96:     end
// 97:
// 98:     def each(&block)
// 99:       @fields.each(&block)
// 100:     end
// 101:
// 102:     def field_names
// 103:       @fields.collect(&:name_as_sym)
// 104:     end
// 105:
// 106:     def field_name?(name)
// 107:       @fields.detect { |f| f.name_as_sym == name.to_sym }
// 108:     end
// 109:
// 110:     def all_field_names_blank?
// 111:       @fields.all? { |f| f.name.nil? }
// 112:     end
// 113:
// 114:     def no_field_names_blank?
// 115:       @fields.all? { |f| f.name != nil }
// 116:     end
// 117:
// 118:     def any_field_has_parameter?(parameter)
// 119:       @fields.any? { |f| f.has_parameter?(parameter) }
// 120:     end
// 121:   end
// 122:   #----------------------------------------------------------------------------
// 123:
// 124:   class SanitizedChoices < SanitizedParameter
// 125:     def initialize(choices, hints)
// 126:       @choices = {}
// 127:       choices.each_pair do |key, val|
// 128:         if SanitizedParameter === val
// 129:           prototype = val
// 130:         else
// 131:           type, param = val
// 132:           prototype = SanitizedPrototype.new(type, param, hints)
// 133:         end
// 134:
// 135:         if key == :default
// 136:           @choices.default = prototype
// 137:         else
// 138:           @choices[key] = prototype
// 139:         end
// 140:       end
// 141:     end
// 142:
// 143:     def [](key)
// 144:       @choices[key]
// 145:     end
// 146:   end
// 147:   #----------------------------------------------------------------------------
// 148:
// 149:   class SanitizedBigEndian < SanitizedParameter
// 150:     def endian
// 151:       :big
// 152:     end
// 153:   end
// 154:
// 155:   class SanitizedLittleEndian < SanitizedParameter
// 156:     def endian
// 157:       :little
// 158:     end
// 159:   end
// 160:   #----------------------------------------------------------------------------
// 161:
// 162:   # BinData objects are instantiated with parameters to determine their
// 163:   # behaviour.  These parameters must be sanitized to ensure their values
// 164:   # are valid.  When instantiating many objects with identical parameters,
// 165:   # such as an array of records, there is much duplicated sanitizing.
// 166:   #
// 167:   # The purpose of the sanitizing code is to eliminate the duplicated
// 168:   # validation.
// 169:   #
// 170:   # SanitizedParameters is a hash-like collection of parameters.  Its purpose
// 171:   # is to recursively sanitize the parameters of an entire BinData object chain
// 172:   # at a single time.
// 173:   class SanitizedParameters < Hash
// 174:     # Memoized constants
// 175:     BIG_ENDIAN    = SanitizedBigEndian.new
// 176:     LITTLE_ENDIAN = SanitizedLittleEndian.new
// 177:
// 178:     class << self
// 179:       def sanitize(parameters, the_class)
// 180:         if SanitizedParameters === parameters
// 181:           parameters
// 182:         else
// 183:           SanitizedParameters.new(parameters, the_class, {})
// 184:         end
// 185:       end
// 186:     end
// 187:
// 188:     def initialize(parameters, the_class, hints)
// 189:       parameters.each_pair { |key, value| self[key.to_sym] = value }
// 190:
// 191:       @the_class = the_class
// 192:
// 193:       if hints[:endian]
// 194:         self[:endian] ||= hints[:endian]
// 195:       end
// 196:
// 197:       if hints[:search_prefix] && !hints[:search_prefix].empty?
// 198:         self[:search_prefix] = Array(self[:search_prefix]).concat(Array(hints[:search_prefix]))
// 199:       end
// 200:
// 201:       sanitize!
// 202:     end
// 203:
// 204:     alias has_parameter? key?
// 205:
// 206:     def has_at_least_one_of?(*keys)
// 207:       keys.each do |key|
// 208:         return true if has_parameter?(key)
// 209:       end
// 210:
// 211:       false
// 212:     end
// 213:
// 214:     def warn_replacement_parameter(bad_key, suggested_key)
// 215:       if has_parameter?(bad_key)
// 216:         Kernel.warn ":#{bad_key} is not used with #{@the_class}.  " \
// 217:                     "You probably want to change this to :#{suggested_key}"
// 218:       end
// 219:     end
// 220:
// 221: #    def warn_renamed_parameter(old_key, new_key)
// 222: #      val = delete(old_key)
// 223: #      if val
// 224: #        self[new_key] = val
// 225: #        Kernel.warn ":#{old_key} has been renamed to :#{new_key} in #{@the_class}.  " \
// 226: #        "Using :#{old_key} is now deprecated and will be removed in the future"
// 227: #      end
// 228: #    end
// 229:
// 230:     def must_be_integer(*keys)
// 231:       keys.each do |key|
// 232:         if has_parameter?(key)
// 233:           parameter = self[key]
// 234:           unless Symbol === parameter ||
// 235:                  parameter.respond_to?(:arity) ||
// 236:                  parameter.respond_to?(:to_int)
// 237:             raise ArgumentError, "parameter '#{key}' in #{@the_class} must " \
// 238:                                  "evaluate to an integer, got #{parameter.class}"
// 239:           end
// 240:         end
// 241:       end
// 242:     end
// 243:
// 244:     def rename_parameter(old_key, new_key)
// 245:       if has_parameter?(old_key)
// 246:         self[new_key] = delete(old_key)
// 247:       end
// 248:     end
// 249:
// 250:     def sanitize_object_prototype(key)
// 251:       sanitize(key) do |obj_type, obj_params|
// 252:         create_sanitized_object_prototype(obj_type, obj_params)
// 253:       end
// 254:     end
// 255:
// 256:     def sanitize_fields(key, &block)
// 257:       sanitize(key) do |fields|
// 258:         sanitized_fields = create_sanitized_fields
// 259:         yield(fields, sanitized_fields)
// 260:         sanitized_fields
// 261:       end
// 262:     end
// 263:
// 264:     def sanitize_choices(key, &block)
// 265:       sanitize(key) do |obj|
// 266:         create_sanitized_choices(yield(obj))
// 267:       end
// 268:     end
// 269:
// 270:     def sanitize_endian(key)
// 271:       sanitize(key) { |endian| create_sanitized_endian(endian) }
// 272:     end
// 273:
// 274:     def sanitize(key, &block)
// 275:       if needs_sanitizing?(key)
// 276:         self[key] = yield(self[key])
// 277:       end
// 278:     end
// 279:
// 280:     def create_sanitized_params(params, the_class)
// 281:       SanitizedParameters.new(params, the_class, hints)
// 282:     end
// 283:
// 284:     def hints
// 285:       { endian: self[:endian], search_prefix: self[:search_prefix] }
// 286:     end
// 287:
// 288:     #---------------
// 289:     private
// 290:
// 291:     def sanitize!
// 292:       ensure_no_nil_values
// 293:       merge_default_parameters!
// 294:
// 295:       @the_class.arg_processor.sanitize_parameters!(@the_class, self)
// 296:
// 297:       ensure_mandatory_parameters_exist
// 298:       ensure_mutual_exclusion_of_parameters
// 299:     end
// 300:
// 301:     def needs_sanitizing?(key)
// 302:       has_parameter?(key) && !self[key].is_a?(SanitizedParameter)
// 303:     end
// 304:
// 305:     def ensure_no_nil_values
// 306:       each do |key, value|
// 307:         if value.nil?
// 308:           raise ArgumentError,
// 309:                 "parameter '#{key}' has nil value in #{@the_class}"
// 310:         end
// 311:       end
// 312:     end
// 313:
// 314:     def merge_default_parameters!
// 315:       @the_class.default_parameters.each do |key, value|
// 316:         self[key] = value unless has_parameter?(key)
// 317:       end
// 318:     end
// 319:
// 320:     def ensure_mandatory_parameters_exist
// 321:       @the_class.mandatory_parameters.each do |key|
// 322:         unless has_parameter?(key)
// 323:           raise ArgumentError,
// 324:                   "parameter '#{key}' must be specified in #{@the_class}"
// 325:         end
// 326:       end
// 327:     end
// 328:
// 329:     def ensure_mutual_exclusion_of_parameters
// 330:       return if length < 2
// 331:
// 332:       @the_class.mutually_exclusive_parameters.each do |key1, key2|
// 333:         if has_parameter?(key1) && has_parameter?(key2)
// 334:           raise ArgumentError, "params '#{key1}' and '#{key2}' " \
// 335:                                "are mutually exclusive in #{@the_class}"
// 336:         end
// 337:       end
// 338:     end
// 339:
// 340:     def create_sanitized_endian(endian)
// 341:       if endian == :big
// 342:         BIG_ENDIAN
// 343:       elsif endian == :little
// 344:         LITTLE_ENDIAN
// 345:       elsif endian == :big_and_little
// 346:         raise ArgumentError, "endian: :big or endian: :little is required"
// 347:       else
// 348:         raise ArgumentError, "unknown value for endian '#{endian}'"
// 349:       end
// 350:     end
// 351:
// 352:     def create_sanitized_choices(choices)
// 353:       SanitizedChoices.new(choices, hints)
// 354:     end
// 355:
// 356:     def create_sanitized_fields
// 357:       SanitizedFields.new(hints)
// 358:     end
// 359:
// 360:     def create_sanitized_object_prototype(obj_type, obj_params)
// 361:       SanitizedPrototype.new(obj_type, obj_params, hints)
// 362:     end
// 363:   end
// 364:   #----------------------------------------------------------------------------
// 365: end
