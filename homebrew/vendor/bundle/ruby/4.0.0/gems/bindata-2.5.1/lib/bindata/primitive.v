module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/primitive.rb`.
// The original source is retained below until every stub has a typed V body.

pub type PrimitiveGetFn = fn (mut PrimitiveObject) brew_runtime.Value

pub type PrimitiveSetFn = fn (mut PrimitiveObject, brew_runtime.Value)

@[heap]
pub struct PrimitiveObject {
pub:
	type_name string
mut:
	base         &BaseObject
	internal     &StructObject
	get_callback PrimitiveGetFn = unsafe { nil }
	set_callback PrimitiveSetFn = unsafe { nil }
	has_get      bool
	has_set      bool
}

fn primitive_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn primitive_symbol(name string) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${name.trim_left(':')}')
}

fn primitive_struct_class_value() brew_runtime.Value {
	mut accepted := new_accepted_parameters()
	accepted.add_optional(['fields', 'endian', 'search_prefix', 'hide']) or { panic(err) }
	encoded := accepted_parameters_value(accepted)
	mut attributes := encoded.attributes.clone()
	attributes['arg_processor'] = 'struct'
	attributes['parser_type'] = 'struct'
	return brew_runtime.Value{
		type_name: 'BinData::Class'
		repr: 'BinData::Struct'
		int_data: encoded.int_data
		attributes: attributes
	}
}

fn primitive_parameters_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	if value.type_name == 'BinData::SanitizedParameters' {
		return sanitized_parameters_from_value(value).values.clone()
	}
	if value.type_name == 'Hash' {
		return value.as_map() or { panic(err) }
	}
	return value.map_data.clone()
}

fn primitive_struct_parameters(parameters map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	value := parameters['struct_params'] or { brew_runtime.map_value({}) }
	return primitive_parameters_map(value)
}

pub fn new_bindata_primitive(type_name string, parameters map[string]brew_runtime.Value) &PrimitiveObject {
	mut normalized := normalized_base_parameters(parameters)
	struct_parameters := sanitize_struct_parameters(primitive_struct_class_value(), primitive_struct_parameters(normalized)) or {
		panic(err)
	}
	normalized['struct_params'] = brew_runtime.map_value(struct_parameters)
	mut base := new_base_object(type_name, normalized)
	internal := new_struct_object('BinData::Struct', struct_parameters)
	base.method_names = internal.field_names.filter(it.len > 0)
	return &PrimitiveObject{
		type_name: type_name
		base: base
		internal: internal
	}
}

pub fn (mut object PrimitiveObject) set_accessors(getter PrimitiveGetFn, setter PrimitiveSetFn) {
	object.get_callback = getter
	object.set_callback = setter
	object.has_get = true
	object.has_set = true
}

fn primitive_object_value(object &PrimitiveObject) brew_runtime.Value {
	base_value := base_object_value(object.base)
	mut attributes := base_value.attributes.clone()
	attributes['primitive_object_address'] = u64(voidptr(object)).str()
	attributes['struct_object_address'] = u64(voidptr(object.internal)).str()
	return brew_runtime.Value{
		...base_value
		type_name: object.type_name
		repr: primitive_effective_value(object).repr
		attributes: attributes
	}
}

pub fn primitive_boundary_value(object &PrimitiveObject) brew_runtime.Value {
	return primitive_object_value(object)
}

fn primitive_object_from_value(value brew_runtime.Value) &PrimitiveObject {
	if address := value.attributes['primitive_object_address'] {
		return unsafe { &PrimitiveObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	struct_parameters := primitive_struct_parameters(base.parameters)
	return &PrimitiveObject{
		type_name: value.type_name
		base: base
		internal: new_struct_object('BinData::Struct', struct_parameters)
	}
}

fn primitive_field_default(field &StructFieldObject) brew_runtime.Value {
	if value := field.definition.parameters['value'] {
		return value
	}
	if value := field.definition.parameters['initial_value'] {
		return value
	}
	name := field.definition.field_type.as_string().trim_left(':').to_lower()
	if name.starts_with('int') || name.starts_with('uint') || name.starts_with('bit') || name.starts_with('sbit') {
		return brew_runtime.int_value(0)
	}
	if name in ['string', 'stringz', 'rest'] {
		return brew_runtime.string_value('')
	}
	return primitive_nil_value()
}

pub fn (mut object PrimitiveObject) field(name string) brew_runtime.Value {
	index := struct_field_index(object.internal, name.trim_left(':').trim_right('='))
	if index < 0 {
		return primitive_nil_value()
	}
	mut field := instantiate_struct_field(mut object.internal, index)
	if field.base.snapshot_value.type_name == 'NilClass' {
		return primitive_field_default(field)
	}
	return field.base.snapshot_value
}

pub fn (mut object PrimitiveObject) set_field(name string, value brew_runtime.Value) brew_runtime.Value {
	index := struct_field_index(object.internal, name.trim_left(':').trim_right('='))
	if index < 0 {
		panic('undefined internal field `${name}`')
	}
	mut field := instantiate_struct_field(mut object.internal, index)
	field.base.assigned_value = value
	field.base.snapshot_value = value
	field.base.has_assignment = true
	field.base.clear = false
	return value
}

fn primitive_get(mut object PrimitiveObject) brew_runtime.Value {
	if !object.has_get {
		panic('NotImplementedError: Primitive#get must be implemented by a typed subclass')
	}
	return object.get_callback(mut object)
}

fn primitive_set(mut object PrimitiveObject, value brew_runtime.Value) {
	if !object.has_set {
		panic('NotImplementedError: Primitive#set must be implemented by a typed subclass')
	}
	object.set_callback(mut object, value)
}

fn primitive_effective_value(object &PrimitiveObject) brew_runtime.Value {
	if value := object.base.parameters['value'] {
		if !object.base.reading {
			return value
		}
	}
	if object.base.snapshot_value.type_name != 'NilClass' {
		return object.base.snapshot_value
	}
	if value := object.base.parameters['initial_value'] {
		return value
	}
	mut mutable := unsafe { &PrimitiveObject(voidptr(object)) }
	return primitive_get(mut mutable)
}

fn primitive_integer_spec(value brew_runtime.Value) ?IntegerClass {
	mut name := value.as_string().trim_left(':')
	if name.len == 0 {
		return none
	}
	if name[0] >= `a` && name[0] <= `z` {
		name = camelize_registry_name(name.to_lower())
	}
	if name in ['Uint8', 'Int8'] {
		return define_integer_class(name, 8, .little, if name == 'Int8' { .signed } else { .unsigned }) or {
			return none
		}
	}
	return integer_class_for_name(name) or { return none }
}

fn primitive_field_num_bytes(mut object PrimitiveObject, index int) int {
	mut field := instantiate_struct_field(mut object.internal, index)
	if spec := primitive_integer_spec(field.definition.field_type) {
		return spec.nbits / 8
	}
	for key in ['length', 'read_length'] {
		if value := field.definition.parameters[key] {
			if value.type_name == 'Integer' {
				return int(value.int_data)
			}
		}
	}
	value := if field.base.snapshot_value.type_name == 'NilClass' {
		primitive_field_default(field)
	} else {
		field.base.snapshot_value
	}
	return if value.type_name == 'String' { value.as_string().len } else { int(field.base.do_num_bytes) }
}

fn primitive_read_internal(mut object PrimitiveObject, mut reader IORead) ! {
	for index in 0 .. object.internal.fields.len {
		mut field := instantiate_struct_field(mut object.internal, index)
		nbytes := primitive_field_num_bytes(mut object, index)
		value := if spec := primitive_integer_spec(field.definition.field_type) {
			brew_runtime.int_value(integer_from_binary(reader.readbytes(nbytes)!, spec)!)
		} else {
			brew_runtime.string_value(reader.readbytes(nbytes)!.bytestr())
		}
		field.base.snapshot_value = value
		field.base.assigned_value = value
		field.base.binary_value = if value.type_name == 'String' { value.as_string() } else { '' }
		field.base.has_assignment = true
		field.base.clear = false
	}
	object.internal.base.clear = false
}

fn primitive_write_internal(mut object PrimitiveObject, mut writer IOWrite) ! {
	for index in 0 .. object.internal.fields.len {
		mut field := instantiate_struct_field(mut object.internal, index)
		value := if field.base.snapshot_value.type_name == 'NilClass' {
			primitive_field_default(field)
		} else {
			field.base.snapshot_value
		}
		mut bytes := if spec := primitive_integer_spec(field.definition.field_type) {
			integer_to_binary(value.as_int()!, spec)!
		} else {
			value.as_string().bytes()
		}
		nbytes := primitive_field_num_bytes(mut object, index)
		if nbytes > 0 {
			if bytes.len > nbytes {
				bytes = bytes[..nbytes].clone()
			} else if bytes.len < nbytes {
				bytes << []u8{len: nbytes - bytes.len}
			}
		}
		writer.writebytes(bytes)!
		field.base.binary_value = bytes.bytestr()
	}
}

fn primitive_dsl_parameters(object_class brew_runtime.Value) map[string]brew_runtime.Value {
	if _ := object_class.attributes['dsl_class_address'] {
		mut dsl_class := dsl_class_from_value(object_class)
		mut parser := dsl_parser_for_class(mut dsl_class, none) or { return map[string]brew_runtime.Value{} }
		return parser.dsl_params() or { map[string]brew_runtime.Value{} }
	}
	if struct_params := object_class.map_data['struct_params'] {
		return primitive_parameters_map(struct_params)
	}
	return object_class.map_data.clone()
}

fn primitive_sanitized_struct_parameters(object_class brew_runtime.Value) &SanitizedParameters {
	values := sanitize_struct_parameters(primitive_struct_class_value(), primitive_dsl_parameters(object_class)) or {
		panic(err)
	}
	return &SanitizedParameters{
		object_class: primitive_struct_class_value()
		values: values
	}
}

// Ruby method `initialize_instance` at line 71.
pub fn ruby_primitive_l71_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Primitive#initialize_instance requires a receiver')
	}
	mut object := primitive_object_from_value(args[0])
	object.base.snapshot_value = primitive_nil_value()
	object.base.assigned_value = primitive_nil_value()
	object.base.clear = true
	object.internal = new_struct_object('BinData::Struct', primitive_struct_parameters(object.base.parameters))
	return primitive_nil_value()
}

// Ruby method `respond_to?(symbol, include_private = false) # :nodoc:` at line 76.
pub fn ruby_primitive_l76_d2_respond_to(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#respond_to? requires a receiver and symbol')
	}
	object := primitive_object_from_value(args[0])
	name := args[1].as_string().trim_left(':').trim_right('=').trim_right('?')
	return brew_runtime.bool_value(struct_field_index(object.internal, name) >= 0 || name in object.base.method_names)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 80.
pub fn ruby_primitive_l80_d3_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#method_missing requires a receiver and symbol')
	}
	mut object := primitive_object_from_value(args[0])
	name := args[1].as_string().trim_left(':')
	if name.ends_with('=') && args.len > 2 {
		return object.set_field(name[..name.len - 1], args[2])
	}
	if struct_field_index(object.internal, name.trim_right('?')) >= 0 {
		return object.field(name.trim_right('?'))
	}
	panic('undefined method `${name}` for ${object.type_name}')
}

// Ruby method `assign(val)` at line 88.
pub fn ruby_primitive_l88_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#assign requires a receiver and value')
	}
	if args[1].type_name == 'NilClass' {
		panic("can't set a nil value for ${ruby_base_l206_d25_debug_name(args[0]).as_string()}")
	}
	mut object := primitive_object_from_value(args[0])
	if 'value' !in object.base.parameters {
		object.base.snapshot_value = args[1]
		object.base.assigned_value = args[1]
		object.base.has_assignment = true
		object.base.clear = false
	}
	primitive_set(mut object, primitive_effective_value(object))
	object.base.snapshot_value = primitive_get(mut object)
	object.base.assigned_value = object.base.snapshot_value
	object.base.has_assignment = true
	object.base.clear = false
	return args[1]
}

// Ruby method `debug_name_of(child) # :nodoc:` at line 94.
pub fn ruby_primitive_l94_d5_debug_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Primitive#debug_name_of requires a receiver')
	}
	return brew_runtime.string_value('${ruby_base_l206_d25_debug_name(args[0]).as_string()}-internal-')
}

// Ruby method `do_write(io)` at line 98.
pub fn ruby_primitive_l98_d6_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#do_write requires a receiver and IO')
	}
	mut object := primitive_object_from_value(args[0])
	primitive_set(mut object, primitive_effective_value(object))
	mut writer := io_write_from_value(args[1])
	primitive_write_internal(mut object, mut writer) or { panic(err) }
	return primitive_nil_value()
}

// Ruby method `do_num_bytes` at line 103.
pub fn ruby_primitive_l103_d7_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Primitive#do_num_bytes requires a receiver')
	}
	mut object := primitive_object_from_value(args[0])
	primitive_set(mut object, primitive_effective_value(object))
	mut total := 0
	for index in 0 .. object.internal.fields.len {
		total += primitive_field_num_bytes(mut object, index)
	}
	return brew_runtime.int_value(total)
}

// Ruby method `sensible_default` at line 111.
pub fn ruby_primitive_l111_d8_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Primitive#sensible_default requires a receiver')
	}
	mut object := primitive_object_from_value(args[0])
	return primitive_get(mut object)
}

// Ruby method `read_and_return_value(io)` at line 115.
pub fn ruby_primitive_l115_d9_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#read_and_return_value requires a receiver and IO')
	}
	mut object := primitive_object_from_value(args[0])
	mut reader := io_read_from_value(args[1])
	primitive_read_internal(mut object, mut reader) or { panic(err) }
	value := primitive_get(mut object)
	object.base.snapshot_value = value
	object.base.assigned_value = value
	object.base.has_assignment = true
	object.base.clear = false
	return value
}

// Ruby method `get` at line 125.
pub fn ruby_primitive_l125_d10_get(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Primitive#get requires a receiver')
	}
	mut object := primitive_object_from_value(args[0])
	return primitive_get(mut object)
}

// Ruby method `set(v)` at line 130.
pub fn ruby_primitive_l130_d11_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Primitive#set requires a receiver and value')
	}
	mut object := primitive_object_from_value(args[0])
	primitive_set(mut object, args[1])
	return args[1]
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 139.
pub fn ruby_primitive_l139_d12_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PrimitiveArgProcessor#sanitize_parameters! requires parameters')
	}
	object_class := if args.len >= 3 { args[1] } else { brew_runtime.map_value({}) }
	params_value := args[args.len - 1]
	struct_params := primitive_sanitized_struct_parameters(object_class)
	if params_value.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params_value)
		parameters.values['struct_params'] = sanitized_parameters_boundary_value(struct_params)
		return sanitized_parameters_boundary_value(parameters)
	}
	mut values := params_value.as_map() or { panic(err) }
	values['struct_params'] = sanitized_parameters_boundary_value(struct_params)
	return brew_runtime.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2: require 'bindata/dsl'
// 3: require 'bindata/struct'
// 4:
// 5: module BinData
// 6:   # A Primitive is a declarative way to define a new BinData data type.
// 7:   # The data type must contain a primitive value only, i.e numbers or strings.
// 8:   # For new data types that contain multiple values see BinData::Record.
// 9:   #
// 10:   # To define a new data type, set fields as if for Record and add a
// 11:   # #get and #set method to extract / convert the data between the fields
// 12:   # and the #value of the object.
// 13:   #
// 14:   #    require 'bindata'
// 15:   #
// 16:   #    class PascalString < BinData::Primitive
// 17:   #      uint8  :len,  value: -> { data.length }
// 18:   #      string :data, read_length: :len
// 19:   #
// 20:   #      def get
// 21:   #        self.data
// 22:   #      end
// 23:   #
// 24:   #      def set(v)
// 25:   #        self.data = v
// 26:   #      end
// 27:   #    end
// 28:   #
// 29:   #    ps = PascalString.new(initial_value: "hello")
// 30:   #    ps.to_binary_s #=> "\005hello"
// 31:   #    ps.read("\003abcde")
// 32:   #    ps #=> "abc"
// 33:   #
// 34:   #    # Unsigned 24 bit big endian integer
// 35:   #    class Uint24be < BinData::Primitive
// 36:   #      uint8 :byte1
// 37:   #      uint8 :byte2
// 38:   #      uint8 :byte3
// 39:   #
// 40:   #      def get
// 41:   #        (self.byte1 << 16) | (self.byte2 << 8) | self.byte3
// 42:   #      end
// 43:   #
// 44:   #      def set(v)
// 45:   #        v = 0 if v < 0
// 46:   #        v = 0xffffff if v > 0xffffff
// 47:   #
// 48:   #        self.byte1 = (v >> 16) & 0xff
// 49:   #        self.byte2 = (v >>  8) & 0xff
// 50:   #        self.byte3 =  v        & 0xff
// 51:   #      end
// 52:   #    end
// 53:   #
// 54:   #    u24 = Uint24be.new
// 55:   #    u24.read("\x12\x34\x56")
// 56:   #    "0x%x" % u24 #=> 0x123456
// 57:   #
// 58:   # == Parameters
// 59:   #
// 60:   # Primitive objects accept all the parameters that BinData::BasePrimitive do.
// 61:   #
// 62:   class Primitive < BasePrimitive
// 63:     extend DSLMixin
// 64:
// 65:     unregister_self
// 66:     dsl_parser    :primitive
// 67:     arg_processor :primitive
// 68:
// 69:     mandatory_parameter :struct_params
// 70:
// 71:     def initialize_instance
// 72:       super
// 73:       @struct = BinData::Struct.new(get_parameter(:struct_params), self)
// 74:     end
// 75:
// 76:     def respond_to?(symbol, include_private = false) # :nodoc:
// 77:       @struct.respond_to?(symbol, include_private) || super
// 78:     end
// 79:
// 80:     def method_missing(symbol, *args, &block) # :nodoc:
// 81:       if @struct.respond_to?(symbol)
// 82:         @struct.__send__(symbol, *args, &block)
// 83:       else
// 84:         super
// 85:       end
// 86:     end
// 87:
// 88:     def assign(val)
// 89:       super(val)
// 90:       set(_value)
// 91:       @value = get
// 92:     end
// 93:
// 94:     def debug_name_of(child) # :nodoc:
// 95:       debug_name + "-internal-"
// 96:     end
// 97:
// 98:     def do_write(io)
// 99:       set(_value)
// 100:       @struct.do_write(io)
// 101:     end
// 102:
// 103:     def do_num_bytes
// 104:       set(_value)
// 105:       @struct.do_num_bytes
// 106:     end
// 107:
// 108:     #---------------
// 109:     private
// 110:
// 111:     def sensible_default
// 112:       get
// 113:     end
// 114:
// 115:     def read_and_return_value(io)
// 116:       @struct.do_read(io)
// 117:       get
// 118:     end
// 119:
// 120:     ###########################################################################
// 121:     # To be implemented by subclasses
// 122:
// 123:     # Extracts the value for this data object from the fields of the
// 124:     # internal struct.
// 125:     def get
// 126:       raise NotImplementedError
// 127:     end
// 128:
// 129:     # Sets the fields of the internal struct to represent +v+.
// 130:     def set(v)
// 131:       raise NotImplementedError
// 132:     end
// 133:
// 134:     # To be implemented by subclasses
// 135:     ###########################################################################
// 136:   end
// 137:
// 138:   class PrimitiveArgProcessor < BaseArgProcessor
// 139:     def sanitize_parameters!(obj_class, params)
// 140:       params[:struct_params] = params.create_sanitized_params(obj_class.dsl_params, BinData::Struct)
// 141:     end
// 142:   end
// 143: end
