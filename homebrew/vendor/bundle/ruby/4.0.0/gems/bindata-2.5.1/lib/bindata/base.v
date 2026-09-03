module bindata

import brew_runtime
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/base.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct BaseObject {
pub:
	type_name string
mut:
	parameters       map[string]brew_runtime.Value
	parent           brew_runtime.Value
	has_parent       bool
	assigned_value   brew_runtime.Value
	has_assignment   bool
	snapshot_value   brew_runtime.Value
	binary_value     string
	do_num_bytes     f64
	clear            bool = true
	reading          bool
	top_level_values map[string]brew_runtime.Value
	method_names     []string
}

pub struct BaseSeparatedArguments {
pub:
	value      brew_runtime.Value
	has_value  bool
	parameters map[string]brew_runtime.Value
	parent     brew_runtime.Value
	has_parent bool
}

fn base_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn base_value_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

fn base_name(value brew_runtime.Value) string {
	return value.as_string().trim_left(':')
}

fn base_object_value(object &BaseObject) brew_runtime.Value {
	mut attributes := {
		'base_object_address': u64(voidptr(object)).str()
		'clear':               object.clear.str()
	}
	if object.method_names.len > 0 {
		attributes['method_names'] = object.method_names.join(',')
	}
	return brew_runtime.Value{
		type_name: object.type_name
		repr: object.snapshot_value.repr
		int_data: i64(u64(voidptr(object)))
		map_data: object.parameters
		attributes: attributes
	}
}

fn base_object_from_value(value brew_runtime.Value) &BaseObject {
	if address := value.attributes['base_object_address'] {
		actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
		return unsafe { &BaseObject(voidptr(actual)) }
	}
	mut methods := []string{}
	if names := value.attributes['method_names'] {
		methods = names.split(',').filter(it.len > 0)
	}
	return &BaseObject{
		type_name: value.type_name
		parameters: value.map_data.clone()
		snapshot_value: value
		assigned_value: value
		binary_value: value.attributes['binary'] or { '' }
		do_num_bytes: (value.attributes['do_num_bytes'] or { '0' }).f64()
		clear: (value.attributes['clear'] or { 'true' }).bool()
		top_level_values: map[string]brew_runtime.Value{}
		method_names: methods
	}
}

pub fn new_base_object(type_name string, parameters map[string]brew_runtime.Value) &BaseObject {
	nil_value := base_nil_value()
	return &BaseObject{
		type_name: type_name
		parameters: parameters.clone()
		parent: nil_value
		assigned_value: nil_value
		snapshot_value: nil_value
		top_level_values: map[string]brew_runtime.Value{}
	}
}

pub fn base_boundary_value(object &BaseObject) brew_runtime.Value {
	return base_object_value(object)
}

pub fn (object &BaseObject) params() map[string]brew_runtime.Value {
	return object.parameters.clone()
}

pub fn (object &BaseObject) snapshot() brew_runtime.Value {
	return object.snapshot_value
}

pub fn (object &BaseObject) is_clear() bool {
	return object.clear
}

fn values_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	if left.type_name != right.type_name || left.repr != right.repr || left.bool_data != right.bool_data || left.int_data != right.int_data || left.float_data != right.float_data || left.string_array_data != right.string_array_data || left.attributes != right.attributes {
		return false
	}
	if left.array_data.len != right.array_data.len || left.map_data.len != right.map_data.len {
		return false
	}
	for index, item in left.array_data {
		if !values_equal(item, right.array_data[index]) {
			return false
		}
	}
	for key, item in left.map_data {
		other := right.map_data[key] or { return false }
		if !values_equal(item, other) {
			return false
		}
	}
	return true
}

pub fn separate_base_arguments(obj_args []brew_runtime.Value) BaseSeparatedArguments {
	mut args := obj_args.clone()
	mut result := BaseSeparatedArguments{
		value: base_nil_value()
		parameters: map[string]brew_runtime.Value{}
		parent: base_nil_value()
	}
	if args.len > 1 && args.last().type_name.starts_with('BinData::') {
		result = BaseSeparatedArguments{
			...result
			parent: args.pop()
			has_parent: true
		}
	}
	if args.len > 0 && args.last().type_name == 'Hash' {
		result = BaseSeparatedArguments{
			...result
			parameters: args.pop().as_map() or { panic(err) }
		}
	}
	if args.len > 0 {
		result = BaseSeparatedArguments{
			...result
			value: args.pop()
			has_value: true
		}
	}
	return result
}

fn normalized_base_parameters(parameters map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut normalized := map[string]brew_runtime.Value{}
	for key, value in parameters {
		normalized[key.trim_left(':')] = value
	}
	return normalized
}

pub fn sanitize_base_parameters(parameters map[string]brew_runtime.Value, object_class brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := normalized_base_parameters(parameters)
	for key, value in result {
		if value.type_name == 'NilClass' {
			return error("parameter '${key}' has nil value in ${object_class.repr}")
		}
	}
	accepted := accepted_parameters_for_plugin(object_class)
	for key, value in accepted.default_values {
		if key !in result {
			result[key] = value
		}
	}
	processor := object_class.attributes['arg_processor'] or { '' }
	if processor in ['struct', 'record'] {
		result = sanitize_struct_parameters(object_class, result)!
	}
	for key in accepted.mandatory_names {
		if key !in result {
			return error("parameter '${key}' must be specified in ${object_class.repr}")
		}
	}
	if result.len >= 2 {
		for pair in accepted.mutually_exclusive_pairs {
			if pair.len >= 2 && pair[0] in result && pair[1] in result {
				return error("params '${pair[0]}' and '${pair[1]}' are mutually exclusive in ${object_class.repr}")
			}
		}
	}
	return result
}

pub fn initialize_base_object(receiver brew_runtime.Value, obj_args []brew_runtime.Value) brew_runtime.Value {
	separated := separate_base_arguments(obj_args)
	parameters := sanitize_base_parameters(separated.parameters, receiver) or { panic(err) }
	processor := receiver.attributes['arg_processor'] or { '' }
	if processor in ['struct', 'record'] {
		return initialize_struct_object(receiver, parameters, separated)
	}
	mut object := new_base_object(receiver.type_name, parameters)
	object.method_names = (receiver.attributes['method_names'] or { '' }).split(',').filter(it.len > 0)
	if separated.has_parent {
		object.parent = separated.parent
		object.has_parent = true
	}
	if separated.has_value && base_value_truthy(separated.value) {
		object.assigned_value = separated.value
		object.snapshot_value = separated.value
		object.has_assignment = true
		object.clear = false
	}
	return base_object_value(object)
}

fn base_arguments_value(separated BaseSeparatedArguments) brew_runtime.Value {
	return brew_runtime.array_value([
		if separated.has_value { separated.value } else { base_nil_value() },
		brew_runtime.map_value(separated.parameters),
		if separated.has_parent { separated.parent } else { base_nil_value() },
	])
}

fn base_top_level(receiver brew_runtime.Value) brew_runtime.Value {
	mut current := receiver
	for {
		object := base_object_from_value(current)
		if !object.has_parent {
			return current
		}
		current = object.parent
	}
	return current
}

fn base_integer_value(value brew_runtime.Value) i64 {
	return if value.type_name == 'Float' { i64(value.float_data) } else { value.int_data }
}

// Ruby method `read(io, *args, &block)` at line 19.
pub fn ruby_base_l19_d1_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base.read requires a class and IO')
	}
	object := initialize_base_object(args[0], args[2..])
	ruby_base_l144_d16_read(object, args[1])
	return object
}

// Ruby method `arg_processor(name = nil)` at line 26.
pub fn ruby_base_l26_d2_arg_processor(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base.arg_processor requires a class')
	}
	if args.len > 1 && args[1].type_name != 'NilClass' {
		name := base_name(args[1]) + '_arg_processor'
		parts := name.split('_').filter(it.len > 0)
		camelized := parts.map(it[..1].to_upper() + it[1..]).join('')
		return brew_runtime.object_value('Symbol', ':${camelized}')
	}
	processor := args[0].attributes['arg_processor'] or {
		if ancestor := args[0].map_data['superclass'] {
			return ruby_base_l26_d2_arg_processor(ancestor)
		}
		'base'
	}
	return brew_runtime.object_value('BinData::ArgProcessor', processor)
}

// Ruby method `bindata_name` at line 41.
pub fn ruby_base_l41_d3_bindata_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base.bindata_name requires a class')
	}
	return brew_runtime.string_value(underscore_registry_name(args[0].repr))
}

// Ruby method `unregister_self` at line 46.
pub fn ruby_base_l46_d4_unregister_self(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base.unregister_self requires a class')
	}
	if args.len > 1 && args[1].type_name == 'BinData::Registry' {
		return ruby_registry_l34_d3_unregister(args[1], brew_runtime.string_value(args[0].repr))
	}
	return base_nil_value()
}

// Ruby method `register_subclasses # :nodoc:` at line 51.
pub fn ruby_base_l51_d5_register_subclasses(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base.register_subclasses requires a class')
	}
	return args[0]
}

// Ruby define_singleton_method `define_singleton_method(:inherited) do |subclass|` at line 53.
pub fn ruby_base_l53_d6_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base.inherited requires a class and subclass')
	}
	if args.len > 2 && args[2].type_name == 'BinData::Registry' {
		return ruby_registry_l25_d2_register(args[2], brew_runtime.string_value(args[1].repr), args[1])
	}
	return args[1]
}

// Ruby method `initialize(*args)` at line 80.
pub fn ruby_base_l80_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#initialize requires a receiver')
	}
	return initialize_base_object(args[0], args[1..])
}

// Ruby attr_accessor `attr_accessor :parent` at line 88.
pub fn ruby_base_l88_d8_parent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#parent requires a receiver')
	}
	object := base_object_from_value(args[0])
	return if object.has_parent { object.parent } else { base_nil_value() }
}

// Ruby attr_accessor `attr_accessor :parent` at line 88.
pub fn ruby_base_l88_d9_parent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#parent= requires a receiver and parent')
	}
	mut object := base_object_from_value(args[0])
	object.parent = args[1]
	object.has_parent = args[1].type_name != 'NilClass'
	return args[1]
}

// Ruby method `new(value = nil, parent = nil)` at line 97.
pub fn ruby_base_l97_d10_new(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#new requires a prototype')
	}
	prototype := base_object_from_value(args[0])
	mut clone := new_base_object(prototype.type_name, prototype.parameters)
	clone.method_names = prototype.method_names.clone()
	if prototype.has_parent {
		clone.parent = prototype.parent
		clone.has_parent = true
	}
	if args.len > 2 && base_value_truthy(args[2]) {
		clone.parent = args[2]
		clone.has_parent = true
	}
	if args.len > 1 && base_value_truthy(args[1]) {
		clone.assigned_value = args[1]
		clone.snapshot_value = args[1]
		clone.has_assignment = true
		clone.clear = false
	}
	return base_object_value(clone)
}

// Ruby method `eval_parameter(key, overrides = nil)` at line 112.
pub fn ruby_base_l112_d11_eval_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#eval_parameter requires a receiver and key')
	}
	value := ruby_base_l129_d13_get_parameter(args[0], args[1])
	if value.type_name == 'Symbol' {
		name := base_name(value)
		overrides := if args.len > 2 && args[2].type_name == 'Hash' {
			args[2].map_data
		} else {
			map[string]brew_runtime.Value{}
		}
		if result := overrides[name] {
			return result
		}
		object := base_object_from_value(args[0])
		if result := object.parameters[name] {
			return result
		}
	}
	return value
}

// Ruby method `lazy_evaluator # :nodoc:` at line 122.
pub fn ruby_base_l122_d12_lazy_evaluator(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#lazy_evaluator requires a receiver')
	}
	return brew_runtime.Value{
		type_name: 'BinData::LazyEvaluator'
		repr: args[0].repr
		map_data: {
			'parent': args[0]
		}
	}
}

// Ruby method `get_parameter(key)` at line 129.
pub fn ruby_base_l129_d13_get_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#get_parameter requires a receiver and key')
	}
	object := base_object_from_value(args[0])
	return object.parameters[base_name(args[1])] or { base_nil_value() }
}

// Ruby method `has_parameter?(key)` at line 134.
pub fn ruby_base_l134_d14_has_parameter(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#has_parameter? requires a receiver and key')
	}
	object := base_object_from_value(args[0])
	return brew_runtime.bool_value(base_name(args[1]) in object.parameters)
}

// Ruby method `clear` at line 139.
pub fn ruby_base_l139_d15_clear(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#clear requires a receiver')
	}
	mut object := base_object_from_value(args[0])
	object.assigned_value = base_nil_value()
	object.snapshot_value = base_nil_value()
	object.has_assignment = false
	object.clear = true
	return base_nil_value()
}

// Ruby method `read(io, &block)` at line 144.
pub fn ruby_base_l144_d16_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#read requires a receiver and IO')
	}
	mut object := base_object_from_value(args[0])
	mut top := base_object_from_value(base_top_level(args[0]))
	top.reading = true
	ruby_base_l139_d15_clear(args[0])
	if binary := args[1].map_data['binary'] {
		object.binary_value = binary.as_string()
		object.snapshot_value = binary
		object.assigned_value = binary
		object.has_assignment = true
		object.clear = false
	} else if args[1].type_name == 'String' {
		object.binary_value = args[1].as_string()
		object.snapshot_value = args[1]
		object.assigned_value = args[1]
		object.has_assignment = true
		object.clear = false
	}
	top.reading = false
	return args[0]
}

// Ruby method `write(io, &block)` at line 157.
pub fn ruby_base_l157_d17_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#write requires a receiver and IO')
	}
	return args[0]
}

// Ruby method `num_bytes` at line 169.
pub fn ruby_base_l169_d18_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#num_bytes requires a receiver')
	}
	object := base_object_from_value(args[0])
	value := if object.do_num_bytes > 0 {
		object.do_num_bytes
	} else {
		f64(object.binary_value.len)
	}
	return brew_runtime.int_value(i64(math.ceil(value)))
}

// Ruby method `to_binary_s(&block)` at line 174.
pub fn ruby_base_l174_d19_to_binary_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#to_binary_s requires a receiver')
	}
	return brew_runtime.string_value(base_object_from_value(args[0]).binary_value)
}

// Ruby method `to_hex(&block)` at line 181.
pub fn ruby_base_l181_d20_to_hex(args ...brew_runtime.Value) brew_runtime.Value {
	binary := ruby_base_l174_d19_to_binary_s(...args).as_string()
	return brew_runtime.string_value(binary.bytes().map(it.hex()).join(''))
}

// Ruby method `inspect` at line 186.
pub fn ruby_base_l186_d21_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#inspect requires a receiver')
	}
	return brew_runtime.string_value(base_object_from_value(args[0]).snapshot_value.repr)
}

// Ruby method `to_s` at line 191.
pub fn ruby_base_l191_d22_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_base_l186_d21_inspect(...args)
}

// Ruby method `pretty_print(pp) # :nodoc:` at line 196.
pub fn ruby_base_l196_d23_pretty_print(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#pretty_print requires a receiver and printer')
	}
	return base_object_from_value(args[0]).snapshot_value
}

// Ruby method `=~(other)` at line 201.
pub fn ruby_base_l201_d24_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#=~ requires a receiver and pattern')
	}
	return brew_runtime.bool_value(base_object_from_value(args[0]).snapshot_value.repr.contains(args[1].repr))
}

// Ruby method `debug_name` at line 206.
pub fn ruby_base_l206_d25_debug_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#debug_name requires a receiver')
	}
	object := base_object_from_value(args[0])
	if object.has_parent {
		return struct_debug_name_of_value(object.parent, args[0])
	}
	return brew_runtime.string_value('obj')
}

// Ruby method `abs_offset` at line 212.
pub fn ruby_base_l212_d26_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#abs_offset requires a receiver')
	}
	object := base_object_from_value(args[0])
	if !object.has_parent {
		return brew_runtime.int_value(0)
	}
	parent_offset := ruby_base_l212_d26_abs_offset(object.parent)
	relative := struct_offset_of_value(object.parent, args[0])
	return brew_runtime.int_value(base_integer_value(parent_offset) + base_integer_value(relative))
}

// Ruby method `rel_offset` at line 217.
pub fn ruby_base_l217_d27_rel_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#rel_offset requires a receiver')
	}
	object := base_object_from_value(args[0])
	return if object.has_parent {
		struct_offset_of_value(object.parent, args[0])
	} else {
		brew_runtime.int_value(0)
	}
}

// Ruby method `==(other) # :nodoc:` at line 221.
pub fn ruby_base_l221_d28_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(values_equal(args[1], base_object_from_value(args[0]).snapshot_value))
}

// Ruby method `safe_respond_to?(symbol, include_private = false) # :nodoc:` at line 228.
pub fn ruby_base_l228_d29_safe_respond_to(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#safe_respond_to? requires a receiver and method')
	}
	name := base_name(args[1])
	base_methods := ['parent', 'new', 'eval_parameter', 'lazy_evaluator', 'get_parameter',
		'has_parameter?', 'clear', 'read', 'write', 'num_bytes', 'to_binary_s', 'to_hex', 'inspect',
		'to_s', 'pretty_print', '=~', 'debug_name', 'abs_offset', 'rel_offset', '==',
		'safe_respond_to?', 'base_respond_to?']
	object := base_object_from_value(args[0])
	return brew_runtime.bool_value(name in base_methods || name in object.method_names)
}

// Ruby alias `alias base_respond_to? respond_to?` at line 232.
pub fn ruby_base_l232_d30_base_respond_to(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_base_l228_d29_safe_respond_to(...args)
}

// Ruby method `extract_args(args)` at line 237.
pub fn ruby_base_l237_d31_extract_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#extract_args requires a receiver and argument array')
	}
	separated := separate_base_arguments(args[1].as_array() or { panic(err) })
	sanitized := sanitize_base_parameters(separated.parameters, args[0]) or { panic(err) }
	return base_arguments_value(BaseSeparatedArguments{
		...separated
		parameters: sanitized
	})
}

// Ruby method `start_read` at line 241.
pub fn ruby_base_l241_d32_start_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#start_read requires a receiver')
	}
	mut top := base_object_from_value(base_top_level(args[0]))
	top.reading = true
	result := if args.len > 1 { args[1] } else { base_nil_value() }
	top.reading = false
	return result
}

// Ruby method `reading?` at line 249.
pub fn ruby_base_l249_d33_reading(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#reading? requires a receiver')
	}
	return brew_runtime.bool_value(base_object_from_value(base_top_level(args[0])).reading)
}

// Ruby method `top_level_set(sym, value)` at line 253.
pub fn ruby_base_l253_d34_top_level_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Base#top_level_set requires a receiver, name and value')
	}
	mut top := base_object_from_value(base_top_level(args[0]))
	top.top_level_values[base_name(args[1])] = args[2]
	if base_name(args[1]) == 'in_read' && args[2].type_name == 'Bool' {
		top.reading = args[2].bool_data
	}
	return args[2]
}

// Ruby method `top_level_get(sym)` at line 257.
pub fn ruby_base_l257_d35_top_level_get(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#top_level_get requires a receiver and name')
	}
	top := base_object_from_value(base_top_level(args[0]))
	return top.top_level_values[base_name(args[1])] or { base_nil_value() }
}

// Ruby method `top_level` at line 263.
pub fn ruby_base_l263_d36_top_level(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Base#top_level requires a receiver')
	}
	return base_top_level(args[0])
}

// Ruby method `binary_string(str)` at line 274.
pub fn ruby_base_l274_d37_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Base#binary_string requires a receiver and string')
	}
	return brew_runtime.string_value(args[1].as_string())
}

// Ruby method `extract_args(obj_class, obj_args)` at line 289.
pub fn ruby_base_l289_d38_extract_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('BaseArgProcessor#extract_args requires a receiver, class and argument array')
	}
	separated := separate_base_arguments(args[2].as_array() or { panic(err) })
	sanitized := sanitize_base_parameters(separated.parameters, args[1]) or { panic(err) }
	return base_arguments_value(BaseSeparatedArguments{
		...separated
		parameters: sanitized
	})
}

// Ruby method `separate_args(_obj_class, obj_args)` at line 298.
pub fn ruby_base_l298_d39_separate_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('BaseArgProcessor#separate_args requires a receiver, class and argument array')
	}
	return base_arguments_value(separate_base_arguments(args[2].as_array() or { panic(err) }))
}

// Ruby method `sanitize_parameters!(obj_class, obj_params); end` at line 322.
pub fn ruby_base_l322_d40_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('BaseArgProcessor#sanitize_parameters! requires a receiver, class and parameters')
	}
	return args[2]
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/framework'
// 2: require 'bindata/io'
// 3: require 'bindata/lazy'
// 4: require 'bindata/name'
// 5: require 'bindata/params'
// 6: require 'bindata/registry'
// 7: require 'bindata/sanitize'
// 8:
// 9: module BinData
// 10:   # This is the abstract base class for all data objects.
// 11:   class Base
// 12:     extend AcceptedParametersPlugin
// 13:     include Framework
// 14:     include RegisterNamePlugin
// 15:
// 16:     class << self
// 17:       # Instantiates this class and reads from +io+, returning the newly
// 18:       # created data object.  +args+ will be used when instantiating.
// 19:       def read(io, *args, &block)
// 20:         obj = new(*args)
// 21:         obj.read(io, &block)
// 22:         obj
// 23:       end
// 24:
// 25:       # The arg processor for this class.
// 26:       def arg_processor(name = nil)
// 27:         @arg_processor ||= nil
// 28:
// 29:         if name
// 30:           @arg_processor = "#{name}_arg_processor".gsub(/(?:^|_)(.)/) { $1.upcase }.to_sym
// 31:         elsif @arg_processor.is_a? Symbol
// 32:           @arg_processor = BinData.const_get(@arg_processor).new
// 33:         elsif @arg_processor.nil?
// 34:           @arg_processor = superclass.arg_processor
// 35:         else
// 36:           @arg_processor
// 37:         end
// 38:       end
// 39:
// 40:       # The name of this class as used by Records, Arrays etc.
// 41:       def bindata_name
// 42:         RegisteredClasses.underscore_name(name)
// 43:       end
// 44:
// 45:       # Call this method if this class is abstract and not to be used.
// 46:       def unregister_self
// 47:         RegisteredClasses.unregister(name)
// 48:       end
// 49:
// 50:       # Registers all subclasses of this class for use
// 51:       def register_subclasses # :nodoc:
// 52:         singleton_class.send(:undef_method, :inherited)
// 53:         define_singleton_method(:inherited) do |subclass|
// 54:           RegisteredClasses.register(subclass.name, subclass)
// 55:           register_subclasses
// 56:         end
// 57:       end
// 58:
// 59:       private :unregister_self, :register_subclasses
// 60:     end
// 61:
// 62:     # Register all subclasses of this class.
// 63:     register_subclasses
// 64:
// 65:     # Set the initial arg processor.
// 66:     arg_processor :base
// 67:
// 68:     # Creates a new data object.
// 69:     #
// 70:     # Args are optional, but if present, must be in the following order.
// 71:     #
// 72:     # +value+ is a value that is +assign+ed immediately after initialization.
// 73:     #
// 74:     # +parameters+ is a hash containing symbol keys.  Some parameters may
// 75:     # reference callable objects (methods or procs).
// 76:     #
// 77:     # +parent+ is the parent data object (e.g. struct, array, choice) this
// 78:     # object resides under.
// 79:     #
// 80:     def initialize(*args)
// 81:       value, @params, @parent = extract_args(args)
// 82:
// 83:       initialize_shared_instance
// 84:       initialize_instance
// 85:       assign(value) if value
// 86:     end
// 87:
// 88:     attr_accessor :parent
// 89:     protected :parent=
// 90:
// 91:     # Creates a new data object based on this instance.
// 92:     #
// 93:     # This implements the prototype design pattern.
// 94:     #
// 95:     # All parameters will be be duplicated.  Use this method
// 96:     # when creating multiple objects with the same parameters.
// 97:     def new(value = nil, parent = nil)
// 98:       obj = clone
// 99:       obj.parent = parent if parent
// 100:       obj.initialize_instance
// 101:       obj.assign(value) if value
// 102:
// 103:       obj
// 104:     end
// 105:
// 106:     # Returns the result of evaluating the parameter identified by +key+.
// 107:     #
// 108:     # +overrides+ is an optional +parameters+ like hash that allow the
// 109:     # parameters given at object construction to be overridden.
// 110:     #
// 111:     # Returns nil if +key+ does not refer to any parameter.
// 112:     def eval_parameter(key, overrides = nil)
// 113:       value = get_parameter(key)
// 114:       if value.is_a?(Symbol) || value.respond_to?(:arity)
// 115:         lazy_evaluator.lazy_eval(value, overrides)
// 116:       else
// 117:         value
// 118:       end
// 119:     end
// 120:
// 121:     # Returns a lazy evaluator for this object.
// 122:     def lazy_evaluator # :nodoc:
// 123:       @lazy_evaluator ||= LazyEvaluator.new(self)
// 124:     end
// 125:
// 126:     # Returns the parameter referenced by +key+.
// 127:     # Use this method if you are sure the parameter is not to be evaluated.
// 128:     # You most likely want #eval_parameter.
// 129:     def get_parameter(key)
// 130:       @params[key]
// 131:     end
// 132:
// 133:     # Returns whether +key+ exists in the +parameters+ hash.
// 134:     def has_parameter?(key)
// 135:       @params.has_parameter?(key)
// 136:     end
// 137:
// 138:     # Resets the internal state to that of a newly created object.
// 139:     def clear
// 140:       initialize_instance
// 141:     end
// 142:
// 143:     # Reads data into this data object.
// 144:     def read(io, &block)
// 145:       io = BinData::IO::Read.new(io) unless BinData::IO::Read === io
// 146:
// 147:       start_read do
// 148:         clear
// 149:         do_read(io)
// 150:       end
// 151:       block.call(self) if block_given?
// 152:
// 153:       self
// 154:     end
// 155:
// 156:     # Writes the value for this data object to +io+.
// 157:     def write(io, &block)
// 158:       io = BinData::IO::Write.new(io) unless BinData::IO::Write === io
// 159:
// 160:       do_write(io)
// 161:       io.flush
// 162:
// 163:       block.call(self) if block_given?
// 164:
// 165:       self
// 166:     end
// 167:
// 168:     # Returns the number of bytes it will take to write this data object.
// 169:     def num_bytes
// 170:       do_num_bytes.ceil
// 171:     end
// 172:
// 173:     # Returns the string representation of this data object.
// 174:     def to_binary_s(&block)
// 175:       io = BinData::IO.create_string_io
// 176:       write(io, &block)
// 177:       io.string
// 178:     end
// 179:
// 180:     # Returns the hexadecimal string representation of this data object.
// 181:     def to_hex(&block)
// 182:       to_binary_s(&block).unpack1('H*')
// 183:     end
// 184:
// 185:     # Return a human readable representation of this data object.
// 186:     def inspect
// 187:       snapshot.inspect
// 188:     end
// 189:
// 190:     # Return a string representing this data object.
// 191:     def to_s
// 192:       snapshot.to_s
// 193:     end
// 194:
// 195:     # Work with Ruby's pretty-printer library.
// 196:     def pretty_print(pp) # :nodoc:
// 197:       pp.pp(snapshot)
// 198:     end
// 199:
// 200:     # Override and delegate =~ as it is defined in Object.
// 201:     def =~(other)
// 202:       snapshot =~ other
// 203:     end
// 204:
// 205:     # Returns a user friendly name of this object for debugging purposes.
// 206:     def debug_name
// 207:       @parent ? @parent.debug_name_of(self) : 'obj'
// 208:     end
// 209:
// 210:     # Returns the offset (in bytes) of this object with respect to its most
// 211:     # distant ancestor.
// 212:     def abs_offset
// 213:       @parent ? @parent.abs_offset + @parent.offset_of(self) : 0
// 214:     end
// 215:
// 216:     # Returns the offset (in bytes) of this object with respect to its parent.
// 217:     def rel_offset
// 218:       @parent ? @parent.offset_of(self) : 0
// 219:     end
// 220:
// 221:     def ==(other) # :nodoc:
// 222:       # double dispatch
// 223:       other == snapshot
// 224:     end
// 225:
// 226:     # A version of +respond_to?+ used by the lazy evaluator.  It doesn't
// 227:     # reinvoke the evaluator so as to avoid infinite evaluation loops.
// 228:     def safe_respond_to?(symbol, include_private = false) # :nodoc:
// 229:       base_respond_to?(symbol, include_private)
// 230:     end
// 231:
// 232:     alias base_respond_to? respond_to?
// 233:
// 234:     #---------------
// 235:     private
// 236:
// 237:     def extract_args(args)
// 238:       self.class.arg_processor.extract_args(self.class, args)
// 239:     end
// 240:
// 241:     def start_read
// 242:       top_level_set(:in_read, true)
// 243:       yield
// 244:     ensure
// 245:       top_level_set(:in_read, false)
// 246:     end
// 247:
// 248:     # Is this object tree currently being read?  Used by BasePrimitive.
// 249:     def reading?
// 250:       top_level_get(:in_read)
// 251:     end
// 252:
// 253:     def top_level_set(sym, value)
// 254:       top_level.instance_variable_set("@tl_#{sym}", value)
// 255:     end
// 256:
// 257:     def top_level_get(sym)
// 258:       tl = top_level
// 259:       tl.instance_variable_defined?("@tl_#{sym}") &&
// 260:         tl.instance_variable_get("@tl_#{sym}")
// 261:     end
// 262:
// 263:     def top_level
// 264:       if parent.nil?
// 265:         tl = self
// 266:       else
// 267:         tl = parent
// 268:         tl = tl.parent while tl.parent
// 269:       end
// 270:
// 271:       tl
// 272:     end
// 273:
// 274:     def binary_string(str)
// 275:       str.to_s.dup.force_encoding(Encoding::BINARY)
// 276:     end
// 277:   end
// 278:
// 279:   # ArgProcessors process the arguments passed to BinData::Base.new into
// 280:   # the form required to initialise the BinData object.
// 281:   #
// 282:   # Any passed parameters are sanitized so the BinData object doesn't
// 283:   # need to perform error checking on the parameters.
// 284:   class BaseArgProcessor
// 285:     @@empty_hash = Hash.new.freeze
// 286:
// 287:     # Takes the arguments passed to BinData::Base.new and
// 288:     # extracts [value, sanitized_parameters, parent].
// 289:     def extract_args(obj_class, obj_args)
// 290:       value, params, parent = separate_args(obj_class, obj_args)
// 291:       sanitized_params = SanitizedParameters.sanitize(params, obj_class)
// 292:
// 293:       [value, sanitized_params, parent]
// 294:     end
// 295:
// 296:     # Separates the arguments passed to BinData::Base.new into
// 297:     # [value, parameters, parent].  Called by #extract_args.
// 298:     def separate_args(_obj_class, obj_args)
// 299:       args = obj_args.dup
// 300:       value = parameters = parent = nil
// 301:
// 302:       if args.length > 1 && args.last.is_a?(BinData::Base)
// 303:         parent = args.pop
// 304:       end
// 305:
// 306:       if args.length > 0 && args.last.is_a?(Hash)
// 307:         parameters = args.pop
// 308:       end
// 309:
// 310:       if args.length > 0
// 311:         value = args.pop
// 312:       end
// 313:
// 314:       parameters ||= @@empty_hash
// 315:
// 316:       [value, parameters, parent]
// 317:     end
// 318:
// 319:     # Performs sanity checks on the given parameters.
// 320:     # This method converts the parameters to the form expected
// 321:     # by the data object.
// 322:     def sanitize_parameters!(obj_class, obj_params); end
// 323:   end
// 324: end
