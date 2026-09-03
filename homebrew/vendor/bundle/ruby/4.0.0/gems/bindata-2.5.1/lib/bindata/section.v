module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/section.rb`.
// The original source is retained below until every stub has a typed V body.

pub type SectionTransformFn = fn ([]u8) []u8

@[heap]
pub struct SectionTransformAdapter {
mut:
	read_callback  SectionTransformFn @[required]
	write_callback SectionTransformFn @[required]
	raw_length     int
}

@[heap]
struct SectionScalar {
mut:
	kind       string
	value      brew_runtime.Value
	read_length int
	clear      bool = true
}

@[heap]
pub struct SectionObject {
pub:
	type_name string
mut:
	base      &BaseObject
	child     brew_runtime.Value
	transform brew_runtime.Value
}

fn section_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_section_transform(read_callback SectionTransformFn, write_callback SectionTransformFn, raw_length int) &SectionTransformAdapter {
	return &SectionTransformAdapter{
		read_callback: read_callback
		write_callback: write_callback
		raw_length: raw_length
	}
}

pub fn section_transform_boundary_value(transform &SectionTransformAdapter) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::IO::Transform'
		repr: 'BinData::IO::Transform'
		int_data: i64(u64(voidptr(transform)))
		attributes: {
			'section_transform_address': u64(voidptr(transform)).str()
			'raw_length': transform.raw_length.str()
		}
	}
}

fn section_transform_from_value(value brew_runtime.Value) ?&SectionTransformAdapter {
	address := value.attributes['section_transform_address'] or { return none }
	return unsafe { &SectionTransformAdapter(voidptr(address.u64())) }
}

fn section_scalar_value(scalar &SectionScalar) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::SectionScalar'
		repr: scalar.value.repr
		int_data: i64(u64(voidptr(scalar)))
		attributes: {
			'section_scalar_address': u64(voidptr(scalar)).str()
			'kind': scalar.kind
			'read_length': scalar.read_length.str()
		}
	}
}

fn section_scalar_from_value(value brew_runtime.Value) ?&SectionScalar {
	address := value.attributes['section_scalar_address'] or { return none }
	return unsafe { &SectionScalar(voidptr(address.u64())) }
}

fn section_type_parts(value brew_runtime.Value) (brew_runtime.Value, map[string]brew_runtime.Value) {
	if value.type_name == 'BinData::SanitizedPrototype' {
		prototype := sanitized_prototype_from_value(value)
		return prototype.object_type, prototype_object_parameters(prototype)
	}
	if value.type_name == 'Array' {
		parts := value.as_array() or { panic(err) }
		if parts.len == 0 {
			panic("parameter 'type' must specify an object type")
		}
		return parts[0], if parts.len > 1 { sanitize_map_from_value(parts[1]) } else { map[string]brew_runtime.Value{} }
	}
	return value, map[string]brew_runtime.Value{}
}

fn section_set_parent(value brew_runtime.Value, parent brew_runtime.Value) {
	if _ := value.attributes['primitive_object_address'] {
		mut object := primitive_object_from_value(value)
		object.base.parent = parent
		object.base.has_parent = true
	} else if _ := value.attributes['array_object_address'] {
		mut object := array_object_from_value(value)
		object.base.parent = parent
		object.base.has_parent = true
	} else if _ := value.attributes['struct_object_address'] {
		mut object := struct_object_from_value(value)
		object.base.parent = parent
		object.base.has_parent = true
	} else if _ := value.attributes['base_object_address'] {
		mut object := base_object_from_value(value)
		object.parent = parent
		object.has_parent = true
	}
}

fn section_instantiate_type(value brew_runtime.Value, parent brew_runtime.Value) brew_runtime.Value {
	if 'base_object_address' in value.attributes || 'section_scalar_address' in value.attributes {
		section_set_parent(value, parent)
		return value
	}
	object_type, parameters := section_type_parts(value)
	name := object_type.as_string().trim_left(':').to_lower()
	if name == 'array' {
		object := new_bindata_array(parameters) or { panic(err) }
		result := array_boundary_value(object)
		section_set_parent(result, parent)
		return result
	}
	if name == 'struct' {
		sanitized := sanitize_struct_parameters(primitive_struct_class_value(), parameters) or { panic(err) }
		result := struct_boundary_value(new_struct_object('BinData::Struct', sanitized))
		section_set_parent(result, parent)
		return result
	}
	read_length := if length := parameters['read_length'] {
		int(length.as_int() or { panic(err) })
	} else if length := parameters['length'] {
		int(length.as_int() or { panic(err) })
	} else if spec := primitive_integer_spec(object_type) {
		spec.nbits / 8
	} else {
		0
	}
	default_value := if _ := primitive_integer_spec(object_type) {
		brew_runtime.int_value(0)
	} else {
		brew_runtime.string_value('')
	}
	return section_scalar_value(&SectionScalar{
		kind: name
		value: default_value
		read_length: read_length
	})
}

pub fn new_bindata_section(parameters map[string]brew_runtime.Value) &SectionObject {
	normalized := normalized_base_parameters(parameters)
	transform := normalized['transform'] or { panic("parameter 'transform' must be specified") }
	type_value := normalized['type'] or { panic("parameter 'type' must be specified") }
	mut base := new_base_object('BinData::Section', normalized)
	mut object := &SectionObject{
		type_name: 'BinData::Section'
		base: base
		child: section_nil_value()
		transform: transform
	}
	parent := section_object_value(object)
	object.child = section_instantiate_type(type_value, parent)
	base.method_names = section_child_method_names(object.child)
	return object
}

fn section_object_value(object &SectionObject) brew_runtime.Value {
	base_value := base_object_value(object.base)
	mut attributes := base_value.attributes.clone()
	attributes['section_object_address'] = u64(voidptr(object)).str()
	return brew_runtime.Value{
		...base_value
		type_name: object.type_name
		repr: section_child_snapshot(object.child).repr
		attributes: attributes
	}
}

pub fn section_boundary_value(object &SectionObject) brew_runtime.Value {
	return section_object_value(object)
}

fn section_object_from_value(value brew_runtime.Value) &SectionObject {
	if address := value.attributes['section_object_address'] {
		return unsafe { &SectionObject(voidptr(address.u64())) }
	}
	return new_bindata_section(base_object_from_value(value).parameters)
}

fn section_child_method_names(child brew_runtime.Value) []string {
	if names := child.attributes['method_names'] {
		return names.split(',').filter(it.len > 0)
	}
	if _ := child.attributes['struct_object_address'] {
		return struct_object_from_value(child).field_names.filter(it.len > 0)
	}
	return if _ := child.attributes['section_scalar_address'] { ['length', 'size'] } else { []string{} }
}

fn section_child_clear(child brew_runtime.Value) bool {
	if scalar := section_scalar_from_value(child) {
		return scalar.clear
	}
	if _ := child.attributes['primitive_object_address'] {
		return primitive_object_from_value(child).base.clear
	}
	if _ := child.attributes['array_object_address'] {
		return ruby_array_l78_d3_clear(child).as_bool() or { false }
	}
	if _ := child.attributes['struct_object_address'] {
		return ruby_struct_l98_d4_clear(child).as_bool() or { false }
	}
	return base_object_from_value(child).clear
}

fn section_child_assign(child brew_runtime.Value, value brew_runtime.Value) brew_runtime.Value {
	if address := child.attributes['section_scalar_address'] {
		mut scalar := unsafe { &SectionScalar(voidptr(address.u64())) }
		scalar.value = value
		scalar.clear = false
		return value
	}
	if _ := child.attributes['primitive_object_address'] {
		return ruby_primitive_l88_d4_assign(child, value)
	}
	if _ := child.attributes['array_object_address'] {
		return ruby_array_l82_d4_assign(child, value)
	}
	if _ := child.attributes['struct_object_address'] {
		return ruby_struct_l102_d5_assign(child, value)
	}
	mut base := base_object_from_value(child)
	base.snapshot_value = value
	base.assigned_value = value
	base.has_assignment = true
	base.clear = false
	return value
}

fn section_child_snapshot(child brew_runtime.Value) brew_runtime.Value {
	if scalar := section_scalar_from_value(child) {
		return scalar.value
	}
	if _ := child.attributes['primitive_object_address'] {
		return primitive_effective_value(primitive_object_from_value(child))
	}
	if _ := child.attributes['array_object_address'] {
		return ruby_array_l90_d5_snapshot(child)
	}
	if _ := child.attributes['struct_object_address'] {
		return ruby_struct_l107_d6_snapshot(child)
	}
	return base_object_from_value(child).snapshot_value
}

fn section_child_num_bytes(child brew_runtime.Value) int {
	if scalar := section_scalar_from_value(child) {
		return if scalar.read_length > 0 { scalar.read_length } else { scalar.value.repr.len }
	}
	value := if _ := child.attributes['primitive_object_address'] {
		ruby_primitive_l103_d7_do_num_bytes(child)
	} else if _ := child.attributes['array_object_address'] {
		ruby_array_l239_d31_do_num_bytes(child)
	} else if _ := child.attributes['struct_object_address'] {
		ruby_struct_l149_d12_do_num_bytes(child)
	} else {
		brew_runtime.int_value(i64(base_object_from_value(child).do_num_bytes))
	}
	return int(if value.type_name == 'Float' { value.float_data } else { f64(value.int_data) })
}

fn section_child_read(child brew_runtime.Value, mut reader IORead) {
	if address := child.attributes['section_scalar_address'] {
		mut scalar := unsafe { &SectionScalar(voidptr(address.u64())) }
		nbytes := if scalar.read_length > 0 { scalar.read_length } else { reader.num_bytes_remaining() or { 0 } }
		bytes := reader.readbytes(nbytes) or { panic(err) }
		if spec := primitive_integer_spec(primitive_symbol(scalar.kind)) {
			scalar.value = brew_runtime.int_value(integer_from_binary(bytes, spec) or { panic(err) })
		} else {
			scalar.value = brew_runtime.string_value(bytes.bytestr())
		}
		scalar.clear = false
		return
	}
	boundary := io_read_boundary_value(reader)
	if _ := child.attributes['primitive_object_address'] {
		ruby_primitive_l115_d9_read_and_return_value(child, boundary)
	} else if _ := child.attributes['array_object_address'] {
		mut array := array_object_from_value(child)
		match array.read_mode {
			.initial_length { ruby_array_l312_d40_do_read(child, boundary) }
			.read_until { ruby_array_l285_d38_do_read(child, boundary) }
			.read_until_eof { ruby_array_l297_d39_do_read(child, boundary) }
		}
	} else if _ := child.attributes['struct_object_address'] {
		ruby_struct_l139_d10_do_read(child, boundary)
	} else {
		ruby_base_l144_d16_read(child, brew_runtime.string_value(reader.read_all_bytes() or { panic(err) }.bytestr()))
	}
}

fn section_child_write(child brew_runtime.Value, mut writer IOWrite) {
	if scalar := section_scalar_from_value(child) {
		mut bytes := if spec := primitive_integer_spec(primitive_symbol(scalar.kind)) {
			integer_to_binary(scalar.value.as_int() or { panic(err) }, spec) or { panic(err) }
		} else {
			scalar.value.as_string().bytes()
		}
		if scalar.read_length > 0 {
			if bytes.len > scalar.read_length {
				bytes = bytes[..scalar.read_length].clone()
			} else if bytes.len < scalar.read_length {
				bytes << []u8{len: scalar.read_length - bytes.len}
			}
		}
		writer.writebytes(bytes) or { panic(err) }
		return
	}
	boundary := io_write_boundary_value(writer)
	if _ := child.attributes['primitive_object_address'] {
		ruby_primitive_l98_d6_do_write(child, boundary)
	} else if _ := child.attributes['array_object_address'] {
		ruby_array_l235_d30_do_write(child, boundary)
	} else if _ := child.attributes['struct_object_address'] {
		ruby_struct_l144_d11_do_write(child, boundary)
	} else {
		writer.writebytes(base_object_from_value(child).binary_value.bytes()) or { panic(err) }
	}
}

fn section_apply_read_transform(transform brew_runtime.Value, data []u8) []u8 {
	if adapter := section_transform_from_value(transform) {
		return adapter.read_callback(data)
	}
	if transform.type_name == 'BinData::Transform::Xor' {
		xor := u8((transform.attributes['xor'] or { '0' }).int())
		return data.map(it ^ xor)
	}
	return data.clone()
}

fn section_apply_write_transform(transform brew_runtime.Value, data []u8) []u8 {
	if adapter := section_transform_from_value(transform) {
		return adapter.write_callback(data)
	}
	return section_apply_read_transform(transform, data)
}

fn section_eval_transform(mut object SectionObject) brew_runtime.Value {
	if callable := lazy_callable_from_value(object.transform) {
		mut evaluator := new_lazy_evaluator(section_object_value(object))
		return callable.callback(mut evaluator)
	}
	return object.transform
}

fn section_sanitize_type(value brew_runtime.Value, hints map[string]brew_runtime.Value) !brew_runtime.Value {
	if value.type_name == 'BinData::SanitizedPrototype' {
		return value
	}
	object_type, parameters := section_type_parts(value)
	if prototype := new_sanitized_prototype(object_type, parameters, hints) {
		return sanitized_prototype_boundary_value(prototype)
	}
	name := object_type.as_string().trim_left(':').to_lower()
	if name !in ['array', 'string', 'stringz', 'rest'] {
		return error(object_type.as_string().trim_left(':'))
	}
	object_class := array_builtin_class(name)
	sanitized := new_sanitized_parameters(parameters, object_class, hints)!
	return sanitized_prototype_boundary_value(&SanitizedPrototype{
		object_type: object_type
		hints: hints.clone()
		factory: section_nil_value()
		object_class: object_class
		object_parameters: sanitized
		has_parameters: true
	})
}

fn section_dsl_parameters(object_class brew_runtime.Value) map[string]brew_runtime.Value {
	if _ := object_class.attributes['dsl_class_address'] {
		mut dsl_class := dsl_class_from_value(object_class)
		mut parser := dsl_parser_for_class(mut dsl_class, none) or { return map[string]brew_runtime.Value{} }
		return parser.dsl_params() or { map[string]brew_runtime.Value{} }
	}
	mut result := map[string]brew_runtime.Value{}
	for key in ['transform', 'type'] {
		if value := object_class.map_data[key] {
			result[key] = value
		}
	}
	return result
}

// Ruby method `initialize_instance` at line 48.
pub fn ruby_section_l48_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Section#initialize_instance requires a receiver')
	}
	mut object := section_object_from_value(args[0])
	type_value := object.base.parameters['type'] or { panic("parameter 'type' must be specified") }
	object.child = section_instantiate_type(type_value, args[0])
	return section_nil_value()
}

// Ruby method `clear?` at line 52.
pub fn ruby_section_l52_d2_clear(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Section#clear? requires a receiver')
	}
	return brew_runtime.bool_value(section_child_clear(section_object_from_value(args[0]).child))
}

// Ruby method `assign(val)` at line 56.
pub fn ruby_section_l56_d3_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Section#assign requires a receiver and value')
	}
	mut object := section_object_from_value(args[0])
	object.base.clear = false
	return section_child_assign(object.child, args[1])
}

// Ruby method `snapshot` at line 60.
pub fn ruby_section_l60_d4_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Section#snapshot requires a receiver')
	}
	return section_child_snapshot(section_object_from_value(args[0]).child)
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 64.
pub fn ruby_section_l64_d5_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Section#respond_to_missing? requires a receiver and symbol')
	}
	object := section_object_from_value(args[0])
	name := args[1].as_string().trim_left(':').trim_right('=').trim_right('?')
	return brew_runtime.bool_value(name in section_child_method_names(object.child))
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 68.
pub fn ruby_section_l68_d6_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Section#method_missing requires a receiver and symbol')
	}
	mut object := section_object_from_value(args[0])
	name := args[1].as_string().trim_left(':')
	if scalar := section_scalar_from_value(object.child) {
		if name in ['length', 'size'] {
			return brew_runtime.int_value(scalar.value.repr.len)
		}
	}
	if _ := object.child.attributes['primitive_object_address'] {
		mut call_args := [object.child, args[1]]
		call_args << args[2..]
		return ruby_primitive_l80_d3_method_missing(...call_args)
	}
	if _ := object.child.attributes['struct_object_address'] {
		if name.ends_with('=') && args.len > 2 {
			return ruby_struct_l158_d14_anonymous(object.child, primitive_symbol(name[..name.len - 1]), args[2])
		}
		return ruby_struct_l213_d23_find_obj_for_name(object.child, primitive_symbol(name))
	}
	panic('undefined method `${name}` for Section child')
}

// Ruby method `do_read(io) # :nodoc:` at line 72.
pub fn ruby_section_l72_d7_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Section#do_read requires a receiver and IO')
	}
	mut object := section_object_from_value(args[0])
	mut reader := io_read_from_value(args[1])
	transform := section_eval_transform(mut object)
	mut raw_length := section_child_num_bytes(object.child)
	if adapter := section_transform_from_value(transform) {
		if adapter.raw_length > 0 {
			raw_length = adapter.raw_length
		}
	}
	raw := reader.readbytes(raw_length) or { panic(err) }
	transformed := section_apply_read_transform(transform, raw)
	mut inner := new_io_read_string(transformed.bytestr())
	section_child_read(object.child, mut inner)
	object.base.clear = false
	return section_nil_value()
}

// Ruby method `do_write(io) # :nodoc:` at line 78.
pub fn ruby_section_l78_d8_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Section#do_write requires a receiver and IO')
	}
	mut object := section_object_from_value(args[0])
	mut stream := new_binary_string_io('')
	mut inner := new_io_write(stream)
	section_child_write(object.child, mut inner)
	inner.flush() or { panic(err) }
	transform := section_eval_transform(mut object)
	bytes := section_apply_write_transform(transform, stream.value().bytes())
	mut writer := io_write_from_value(args[1])
	writer.writebytes(bytes) or { panic(err) }
	object.base.binary_value = bytes.bytestr()
	return section_nil_value()
}

// Ruby method `do_num_bytes # :nodoc:` at line 84.
pub fn ruby_section_l84_d9_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Section#do_num_bytes requires a receiver')
	}
	mut stream := new_binary_string_io('')
	mut writer := new_io_write(stream)
	ruby_section_l78_d8_do_write(args[0], io_write_boundary_value(writer))
	writer.flush() or { panic(err) }
	return brew_runtime.int_value(stream.value().len)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 92.
pub fn ruby_section_l92_d10_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SectionArgProcessor#sanitize_parameters! requires parameters')
	}
	object_class := if args.len >= 3 { args[1] } else { brew_runtime.map_value({}) }
	params_value := args[args.len - 1]
	if params_value.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params_value)
		for key, value in section_dsl_parameters(object_class) {
			parameters.values[key] = value
		}
		if type_value := parameters.values['type'] {
			parameters.values['type'] = section_sanitize_type(type_value, parameters.hints()) or { panic(err) }
		}
		return sanitized_parameters_boundary_value(parameters)
	}
	mut values := params_value.as_map() or { panic(err) }
	for key, value in section_dsl_parameters(object_class) {
		values[key] = value
	}
	if type_value := values['type'] {
		values['type'] = section_sanitize_type(type_value, {}) or { panic(err) }
	}
	return brew_runtime.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # A Section is a layer on top of a stream that transforms the underlying
// 6:   # data.  This allows BinData to process a stream that has multiple
// 7:   # encodings.  e.g.  Some data data is compressed or encrypted.
// 8:   #
// 9:   #   require 'bindata'
// 10:   #
// 11:   #   class XorTransform < BinData::IO::Transform
// 12:   #      def initialize(xor)
// 13:   #        super()
// 14:   #        @xor = xor
// 15:   #      end
// 16:   #
// 17:   #      def read(n)
// 18:   #        chain_read(n).bytes.map { |byte| (byte ^ @xor).chr }.join
// 19:   #      end
// 20:   #
// 21:   #      def write(data)
// 22:   #        chain_write(data.bytes.map { |byte| (byte ^ @xor).chr }.join)
// 23:   #      end
// 24:   #   end
// 25:   #
// 26:   #   obj = BinData::Section.new(transform: -> { XorTransform.new(0xff) },
// 27:   #                              type: [:string, read_length: 5])
// 28:   #
// 29:   #   obj.read("\x97\x9A\x93\x93\x90") #=> "hello"
// 30:   #
// 31:   #
// 32:   # == Parameters
// 33:   #
// 34:   # Parameters may be provided at initialisation to control the behaviour of
// 35:   # an object.  These params are:
// 36:   #
// 37:   # <tt>:transform</tt>:: A callable that returns a new BinData::IO::Transform.
// 38:   # <tt>:type</tt>::      The single type inside the buffer.  Use a struct if
// 39:   #                       multiple fields are required.
// 40:   class Section < BinData::Base
// 41:     extend DSLMixin
// 42:
// 43:     dsl_parser    :section
// 44:     arg_processor :section
// 45:
// 46:     mandatory_parameters :transform, :type
// 47:
// 48:     def initialize_instance
// 49:       @type = get_parameter(:type).instantiate(nil, self)
// 50:     end
// 51:
// 52:     def clear?
// 53:       @type.clear?
// 54:     end
// 55:
// 56:     def assign(val)
// 57:       @type.assign(val)
// 58:     end
// 59:
// 60:     def snapshot
// 61:       @type.snapshot
// 62:     end
// 63:
// 64:     def respond_to_missing?(symbol, include_all = false) # :nodoc:
// 65:       @type.respond_to?(symbol, include_all) || super
// 66:     end
// 67:
// 68:     def method_missing(symbol, *args, &block) # :nodoc:
// 69:       @type.__send__(symbol, *args, &block)
// 70:     end
// 71:
// 72:     def do_read(io) # :nodoc:
// 73:       io.transform(eval_parameter(:transform)) do |transformed_io, _raw_io|
// 74:         @type.do_read(transformed_io)
// 75:       end
// 76:     end
// 77:
// 78:     def do_write(io) # :nodoc:
// 79:       io.transform(eval_parameter(:transform)) do |transformed_io, _raw_io|
// 80:         @type.do_write(transformed_io)
// 81:       end
// 82:     end
// 83:
// 84:     def do_num_bytes # :nodoc:
// 85:       to_binary_s.size
// 86:     end
// 87:   end
// 88:
// 89:   class SectionArgProcessor < BaseArgProcessor
// 90:     include MultiFieldArgSeparator
// 91:
// 92:     def sanitize_parameters!(obj_class, params)
// 93:       params.merge!(obj_class.dsl_params)
// 94:       params.sanitize_object_prototype(:type)
// 95:     end
// 96:   end
// 97: end
