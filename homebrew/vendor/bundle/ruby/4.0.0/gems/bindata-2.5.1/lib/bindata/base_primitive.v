module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/base_primitive.rb`.
// The original source is retained below until every stub has a typed V body.
pub type BasePrimitiveBinaryFn = fn(ruby.Value) !string

pub type BasePrimitiveReadFn = fn(mut IORead) !ruby.Value

pub type BasePrimitiveDefaultFn = fn() ruby.Value

pub type BasePrimitiveAssertFn = fn(ruby.Value) ruby.Value

@[heap]
pub struct BasePrimitiveObject {
pub:
	type_name string
mut:
	base            &BaseObject
	value           ruby.Value
	has_value       bool
	value_to_binary BasePrimitiveBinaryFn = unsafe { nil }
	read_value      BasePrimitiveReadFn = unsafe { nil }
	default_value   BasePrimitiveDefaultFn = unsafe { nil }
	assert_callback BasePrimitiveAssertFn = unsafe { nil }
	has_binary      bool
	has_reader      bool
	has_default     bool
	has_assert      bool
}

fn base_primitive_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn new_bindata_base_primitive(type_name string, parameters map[string]ruby.Value) &BasePrimitiveObject {
	return &BasePrimitiveObject{
		type_name: type_name
		base: new_base_object(type_name, normalized_base_parameters(parameters))
		value: base_primitive_nil_value()
	}
}

pub fn (mut object BasePrimitiveObject) set_codec(binary BasePrimitiveBinaryFn, reader BasePrimitiveReadFn, default_value BasePrimitiveDefaultFn) {
	object.value_to_binary = binary
	object.read_value = reader
	object.default_value = default_value
	object.has_binary = true
	object.has_reader = true
	object.has_default = true
}

pub fn (mut object BasePrimitiveObject) set_assert_callback(callback BasePrimitiveAssertFn) {
	object.assert_callback = callback
	object.has_assert = true
}

fn base_primitive_boundary(object &BasePrimitiveObject) ruby.Value {
	base_value := base_object_value(object.base)
	mut attributes := base_value.attributes.clone()
	attributes['base_primitive_address'] = u64(voidptr(object)).str()
	return ruby.Value{
		...base_value
		type_name: object.type_name
		repr: base_primitive_effective_value(object).repr
		attributes: attributes
	}
}

pub fn base_primitive_boundary_value(object &BasePrimitiveObject) ruby.Value {
	return base_primitive_boundary(object)
}

fn base_primitive_from_value(value ruby.Value) &BasePrimitiveObject {
	if address := value.attributes['base_primitive_address'] {
		return unsafe { &BasePrimitiveObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	has_value := value.type_name != 'NilClass' && value.repr != 'nil'
	return &BasePrimitiveObject{
		type_name: value.type_name
		base: base
		value: if has_value { value } else { base_primitive_nil_value() }
		has_value: has_value
	}
}

fn base_primitive_parameter(object &BasePrimitiveObject, name string) ?ruby.Value {
	value := object.base.parameters[name] or { return none }
	return value
}

fn base_primitive_effective_value(object &BasePrimitiveObject) ruby.Value {
	if object.base.reading && object.has_value {
		return object.value
	}
	if value := base_primitive_parameter(object, 'value') {
		return value
	}
	if value := base_primitive_parameter(object, 'asserted_value') {
		return value
	}
	if object.has_value {
		return object.value
	}
	if value := base_primitive_parameter(object, 'initial_value') {
		return value
	}
	if object.has_default {
		return object.default_value()
	}
	return base_primitive_nil_value()
}

fn base_primitive_assign(mut object BasePrimitiveObject, value ruby.Value) ! {
	if value.type_name == 'NilClass' {
		return error("can't set a nil value for ${object.type_name}")
	}
	if 'value' in object.base.parameters {
		return
	}
	if 'asserted_value' in object.base.parameters {
		base_primitive_assert_value(object, value)!
	}
	object.value = value
	object.has_value = true
	object.base.snapshot_value = value
	object.base.assigned_value = value
	object.base.has_assignment = true
	object.base.clear = false
	if 'assert' in object.base.parameters {
		base_primitive_assert(object)!
	}
}

fn base_primitive_assert_value(object &BasePrimitiveObject, current ruby.Value) ! {
	expected := if object.has_assert {
		object.assert_callback(current)
	} else {
		object.base.parameters['asserted_value'] or { return }
	}
	if !values_equal(current, expected) {
		return error("value is '${current.repr}' but expected '${expected.repr}' for ${object.type_name}")
	}
}

fn base_primitive_assert(object &BasePrimitiveObject) ! {
	current := base_primitive_effective_value(object)
	expected := if object.has_assert {
		object.assert_callback(current)
	} else {
		object.base.parameters['assert'] or { return }
	}
	if expected.type_name == 'NilClass' || (expected.type_name == 'Bool' && !expected.bool_data) {
		return error("value '${current.repr}' not as expected for ${object.type_name}")
	}
	if !(expected.type_name == 'Bool' && expected.bool_data) && !values_equal(current, expected) {
		return error("value is '${current.repr}' but expected '${expected.repr}' for ${object.type_name}")
	}
}

fn base_primitive_binary(object &BasePrimitiveObject, value ruby.Value) !string {
	if !object.has_binary {
		return error('NotImplementedError: value_to_binary_string')
	}
	return object.value_to_binary(value)!
}

fn base_primitive_read(mut object BasePrimitiveObject, mut reader IORead) !ruby.Value {
	if !object.has_reader {
		return error('NotImplementedError: read_and_return_value')
	}
	object.base.reading = true
	defer {
		object.base.reading = false
	}
	value := object.read_value(mut reader)!
	object.value = value
	object.has_value = true
	object.base.snapshot_value = value
	object.base.clear = false
	if 'assert' in object.base.parameters {
		base_primitive_assert(object)!
	}
	if 'asserted_value' in object.base.parameters {
		base_primitive_assert_value(object, value)!
	}
	return value
}

fn base_primitive_value_hash(value ruby.Value) i64 {
	mut hash := u64(1469598103934665603)
	for byte in '${value.type_name}\0${value.repr}'.bytes() {
		hash = (hash ^ byte) * 1099511628211
	}
	return i64(hash)
}

fn base_primitive_dispatch(value ruby.Value, method string, method_args []ruby.Value) ruby.Value {
	name := method.trim_left(':')
	return match name {
		'length', 'size' { ruby.int_value(value.as_string().len) }
		'empty?' { ruby.bool_value(value.as_string().len == 0) }
		'negative?' { ruby.bool_value(value.int_data < 0) }
		'abs' {
			ruby.int_value(if value.int_data < 0 { -value.int_data } else { value.int_data })
		}
		'to_s' { ruby.string_value(value.as_string()) }
		'clamp' {
			if method_args.len < 2 { panic('clamp requires a minimum and maximum') }
			ruby.int_value(if value.int_data < method_args[0].int_data {
				method_args[0].int_data
			} else if value.int_data > method_args[1].int_data {
				method_args[1].int_data
			} else {
				value.int_data
			})
		}
		else { panic('undefined method `${name}` for ${value.type_name}') }
	}
}

// Ruby method `initialize_shared_instance` at line 56.
pub fn ruby_base_primitive_l56_d1_initialize_shared_instance(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BasePrimitive#initialize_shared_instance requires a receiver')
	}
	return args[0]
}

// Ruby method `initialize_instance` at line 64.
pub fn ruby_base_primitive_l64_d2_initialize_instance(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('BasePrimitive#initialize_instance requires a receiver')
	}
	mut object := base_primitive_from_value(args[0])
	object.value = base_primitive_nil_value()
	object.has_value = false
	object.base.clear = true
	return base_primitive_nil_value()
}

// Ruby method `clear? # :nodoc:` at line 68.
pub fn ruby_base_primitive_l68_d3_clear(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!base_primitive_from_value(args[0]).has_value)
}

// Ruby method `assign(val)` at line 72.
pub fn ruby_base_primitive_l72_d4_assign(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#assign requires a receiver and value') }
	mut object := base_primitive_from_value(args[0])
	base_primitive_assign(mut object, args[1]) or { panic(err) }
	return args[1]
}

// Ruby method `snapshot` at line 79.
pub fn ruby_base_primitive_l79_d5_snapshot(args ...ruby.Value) ruby.Value {
	return base_primitive_effective_value(base_primitive_from_value(args[0]))
}

// Ruby method `value` at line 83.
pub fn ruby_base_primitive_l83_d6_value(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l79_d5_snapshot(...args)
}

// Ruby method `value=(val)` at line 87.
pub fn ruby_base_primitive_l87_d7_value(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l72_d4_assign(...args)
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 91.
pub fn ruby_base_primitive_l91_d8_respond_to_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#respond_to_missing? requires a symbol') }
	name := args[1].as_string().trim_left(':')
	return ruby.bool_value(name in ['length', 'size', 'empty?', 'negative?', 'abs', 'to_s',
		'clamp'])
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 96.
pub fn ruby_base_primitive_l96_d9_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#method_missing requires a symbol') }
	return base_primitive_dispatch(base_primitive_effective_value(base_primitive_from_value(args[0])), args[1].as_string(), args[2..])
}

// Ruby method `#{symbol}(*args, &block)         # def clamp(*args, &block)` at line 100.
pub fn ruby_base_primitive_l100_d10_symbol(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l96_d9_method_missing(...args)
}

// Ruby method `<=>(other)` at line 110.
pub fn ruby_base_primitive_l110_d11_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#<=> requires other') }
	left := base_primitive_effective_value(base_primitive_from_value(args[0]))
	right := args[1]
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		l := left.as_float() or { panic(err) }
		r := right.as_float() or { panic(err) }
		return ruby.int_value(if l < r {
			-1
		} else if l > r { 1 } else { 0 })
	}
	return ruby.int_value(if left.repr < right.repr {
		-1
	} else if left.repr > right.repr { 1 } else { 0 })
}

// Ruby method `eql?(other)` at line 114.
pub fn ruby_base_primitive_l114_d12_eql(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#eql? requires other') }
	return ruby.bool_value(values_equal(args[1], base_primitive_effective_value(base_primitive_from_value(args[0]))))
}

// Ruby method `hash` at line 119.
pub fn ruby_base_primitive_l119_d13_hash(args ...ruby.Value) ruby.Value {
	return ruby.int_value(base_primitive_value_hash(base_primitive_effective_value(base_primitive_from_value(args[0]))))
}

// Ruby method `do_read(io) # :nodoc:` at line 123.
pub fn ruby_base_primitive_l123_d14_do_read(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#do_read requires IO') }
	mut object := base_primitive_from_value(args[0])
	mut reader := io_read_from_value(args[1])
	return base_primitive_read(mut object, mut reader) or { panic(err) }
}

// Ruby method `do_write(io) # :nodoc:` at line 127.
pub fn ruby_base_primitive_l127_d15_do_write(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('BasePrimitive#do_write requires IO') }
	object := base_primitive_from_value(args[0])
	mut writer := io_write_from_value(args[1])
	writer.writebytes(base_primitive_binary(object, base_primitive_effective_value(object)) or { panic(err) }.bytes()) or { panic(err) }
	return base_primitive_nil_value()
}

// Ruby method `do_num_bytes # :nodoc:` at line 131.
pub fn ruby_base_primitive_l131_d16_do_num_bytes(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	return ruby.int_value(base_primitive_binary(object, base_primitive_effective_value(object)) or { panic(err) }.len)
}

// Ruby method `_value` at line 141.
pub fn ruby_base_primitive_l141_d17_value(args ...ruby.Value) ruby.Value {
	return base_primitive_effective_value(base_primitive_from_value(args[0]))
}

// Ruby method `assign(val)` at line 147.
pub fn ruby_base_primitive_l147_d18_assign(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ValuePlugin#assign requires value') }
	return args[1]
}

// Ruby method `_value` at line 151.
pub fn ruby_base_primitive_l151_d19_value(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	if object.base.reading && object.has_value {
		return object.value
	}
	return object.base.parameters['value'] or { base_primitive_nil_value() }
}

// Ruby method `_value` at line 158.
pub fn ruby_base_primitive_l158_d20_value(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	if object.has_value {
		return object.value
	}
	return object.base.parameters['initial_value'] or { base_primitive_nil_value() }
}

// Ruby method `assign(val)` at line 165.
pub fn ruby_base_primitive_l165_d21_assign(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l72_d4_assign(...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 170.
pub fn ruby_base_primitive_l170_d22_do_read(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l123_d14_do_read(...args)
}

// Ruby method `assert!` at line 175.
pub fn ruby_base_primitive_l175_d23_assert(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	base_primitive_assert(object) or { panic(err) }
	return base_primitive_nil_value()
}

// Ruby method `assign(val)` at line 194.
pub fn ruby_base_primitive_l194_d24_assign(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('AssertedValuePlugin#assign requires value') }
	object := base_primitive_from_value(args[0])
	base_primitive_assert_value(object, args[1]) or { panic(err) }
	return ruby_base_primitive_l72_d4_assign(...args)
}

// Ruby method `_value` at line 199.
pub fn ruby_base_primitive_l199_d25_value(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	if object.base.reading && object.has_value {
		return object.value
	}
	return object.base.parameters['asserted_value'] or { base_primitive_nil_value() }
}

// Ruby method `asserted_binary_s` at line 208.
pub fn ruby_base_primitive_l208_d26_asserted_binary_s(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	value := object.base.parameters['asserted_value'] or { panic('missing asserted_value') }
	return ruby.string_value(base_primitive_binary(object, value) or { panic(err) })
}

// Ruby method `do_read(io) # :nodoc:` at line 212.
pub fn ruby_base_primitive_l212_d27_do_read(args ...ruby.Value) ruby.Value {
	return ruby_base_primitive_l123_d14_do_read(...args)
}

// Ruby method `assert!` at line 217.
pub fn ruby_base_primitive_l217_d28_assert(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	base_primitive_assert_value(object, base_primitive_effective_value(object)) or { panic(err) }
	return base_primitive_nil_value()
}

// Ruby method `assert_value(current_value)` at line 221.
pub fn ruby_base_primitive_l221_d29_assert_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('assert_value requires current_value') }
	object := base_primitive_from_value(args[0])
	base_primitive_assert_value(object, args[1]) or { panic(err) }
	return base_primitive_nil_value()
}

// Ruby method `value_to_binary_string(val)` at line 235.
pub fn ruby_base_primitive_l235_d30_value_to_binary_string(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('value_to_binary_string requires value') }
	return ruby.string_value(base_primitive_binary(base_primitive_from_value(args[0]), args[1]) or { panic(err) })
}

// Ruby method `read_and_return_value(io)` at line 240.
pub fn ruby_base_primitive_l240_d31_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('read_and_return_value requires IO') }
	mut object := base_primitive_from_value(args[0])
	mut reader := io_read_from_value(args[1])
	if !object.has_reader { panic('NotImplementedError: read_and_return_value') }
	return object.read_value(mut reader) or { panic(err) }
}

// Ruby method `sensible_default` at line 245.
pub fn ruby_base_primitive_l245_d32_sensible_default(args ...ruby.Value) ruby.Value {
	object := base_primitive_from_value(args[0])
	if !object.has_default { panic('NotImplementedError: sensible_default') }
	return object.default_value()
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2:
// 3: module BinData
// 4:   # A BinData::BasePrimitive object is a container for a value that has a
// 5:   # particular binary representation.  A value corresponds to a primitive type
// 6:   # such as as integer, float or string.  Only one value can be contained by
// 7:   # this object.  This value can be read from or written to an IO stream.
// 8:   #
// 9:   #   require 'bindata'
// 10:   #
// 11:   #   obj = BinData::Uint8.new(initial_value: 42)
// 12:   #   obj #=> 42
// 13:   #   obj.assign(5)
// 14:   #   obj #=> 5
// 15:   #   obj.clear
// 16:   #   obj #=> 42
// 17:   #
// 18:   #   obj = BinData::Uint8.new(value: 42)
// 19:   #   obj #=> 42
// 20:   #   obj.assign(5)
// 21:   #   obj #=> 42
// 22:   #
// 23:   #   obj = BinData::Uint8.new(assert: 3)
// 24:   #   obj.read("\005") #=> BinData::ValidityError: value is '5' but expected '3'
// 25:   #
// 26:   #   obj = BinData::Uint8.new(assert: -> { value < 5 })
// 27:   #   obj.read("\007") #=> BinData::ValidityError: value not as expected
// 28:   #
// 29:   # == Parameters
// 30:   #
// 31:   # Parameters may be provided at initialisation to control the behaviour of
// 32:   # an object.  These params include those for BinData::Base as well as:
// 33:   #
// 34:   # [<tt>:initial_value</tt>]  This is the initial value to use before one is
// 35:   #                            either #read or explicitly set with #value=.
// 36:   # [<tt>:value</tt>]          The object will always have this value.
// 37:   #                            Calls to #value= are ignored when
// 38:   #                            using this param.  While reading, #value
// 39:   #                            will return the value of the data read from the
// 40:   #                            IO, not the result of the <tt>:value</tt> param.
// 41:   # [<tt>:assert</tt>]         Raise an error unless the value read or assigned
// 42:   #                            meets this criteria.  The variable +value+ is
// 43:   #                            made available to any lambda assigned to this
// 44:   #                            parameter.  A boolean return indicates success
// 45:   #                            or failure.  Any other return is compared to
// 46:   #                            the value just read in.
// 47:   # [<tt>:asserted_value</tt>] Equivalent to <tt>:assert</tt> and <tt>:value</tt>.
// 48:   #
// 49:   class BasePrimitive < BinData::Base
// 50:     unregister_self
// 51:
// 52:     optional_parameters :initial_value, :value, :assert, :asserted_value
// 53:     mutually_exclusive_parameters :initial_value, :value
// 54:     mutually_exclusive_parameters :asserted_value, :value, :assert
// 55:
// 56:     def initialize_shared_instance
// 57:       extend InitialValuePlugin  if has_parameter?(:initial_value)
// 58:       extend ValuePlugin         if has_parameter?(:value)
// 59:       extend AssertPlugin        if has_parameter?(:assert)
// 60:       extend AssertedValuePlugin if has_parameter?(:asserted_value)
// 61:       super
// 62:     end
// 63:
// 64:     def initialize_instance
// 65:       @value = nil
// 66:     end
// 67:
// 68:     def clear? # :nodoc:
// 69:       @value.nil?
// 70:     end
// 71:
// 72:     def assign(val)
// 73:       raise ArgumentError, "can't set a nil value for #{debug_name}" if val.nil?
// 74:
// 75:       raw_val = val.respond_to?(:snapshot) ? val.snapshot : val
// 76:       @value = raw_val.dup
// 77:     end
// 78:
// 79:     def snapshot
// 80:       _value
// 81:     end
// 82:
// 83:     def value
// 84:       snapshot
// 85:     end
// 86:
// 87:     def value=(val)
// 88:       assign(val)
// 89:     end
// 90:
// 91:     def respond_to_missing?(symbol, include_all = false) # :nodoc:
// 92:       child = snapshot
// 93:       child.respond_to?(symbol, include_all) || super
// 94:     end
// 95:
// 96:     def method_missing(symbol, *args, &block) # :nodoc:
// 97:       child = snapshot
// 98:       if child.respond_to?(symbol)
// 99:         self.class.class_eval <<-END, __FILE__, __LINE__ + 1
// 100:           def #{symbol}(*args, &block)         # def clamp(*args, &block)
// 101:             snapshot.#{symbol}(*args, &block)  #   snapshot.clamp(*args, &block)
// 102:           end                                  # end
// 103:         END
// 104:         child.__send__(symbol, *args, &block)
// 105:       else
// 106:         super
// 107:       end
// 108:     end
// 109:
// 110:     def <=>(other)
// 111:       snapshot <=> other
// 112:     end
// 113:
// 114:     def eql?(other)
// 115:       # double dispatch
// 116:       other.eql?(snapshot)
// 117:     end
// 118:
// 119:     def hash
// 120:       snapshot.hash
// 121:     end
// 122:
// 123:     def do_read(io) # :nodoc:
// 124:       @value = read_and_return_value(io)
// 125:     end
// 126:
// 127:     def do_write(io) # :nodoc:
// 128:       io.writebytes(value_to_binary_string(_value))
// 129:     end
// 130:
// 131:     def do_num_bytes # :nodoc:
// 132:       value_to_binary_string(_value).length
// 133:     end
// 134:
// 135:     #---------------
// 136:     private
// 137:
// 138:     # The unmodified value of this data object.  Note that #snapshot calls this
// 139:     # method.  This indirection is so that #snapshot can be overridden in
// 140:     # subclasses to modify the presentation value.
// 141:     def _value
// 142:       @value != nil ? @value : sensible_default
// 143:     end
// 144:
// 145:     # Logic for the :value parameter
// 146:     module ValuePlugin
// 147:       def assign(val)
// 148:         # Ignored
// 149:       end
// 150:
// 151:       def _value
// 152:         reading? ? @value : eval_parameter(:value)
// 153:       end
// 154:     end
// 155:
// 156:     # Logic for the :initial_value parameter
// 157:     module InitialValuePlugin
// 158:       def _value
// 159:         @value != nil ? @value : eval_parameter(:initial_value)
// 160:       end
// 161:     end
// 162:
// 163:     # Logic for the :assert parameter
// 164:     module AssertPlugin
// 165:       def assign(val)
// 166:         super(val)
// 167:         assert!
// 168:       end
// 169:
// 170:       def do_read(io) # :nodoc:
// 171:         super(io)
// 172:         assert!
// 173:       end
// 174:
// 175:       def assert!
// 176:         current_value = snapshot
// 177:         expected = eval_parameter(:assert, value: current_value)
// 178:
// 179:         msg =
// 180:           if !expected
// 181:             "value '#{current_value}' not as expected"
// 182:           elsif expected != true && current_value != expected
// 183:             "value is '#{current_value}' but expected '#{expected}'"
// 184:           else
// 185:             nil
// 186:           end
// 187:
// 188:         raise ValidityError, "#{msg} for #{debug_name}" if msg
// 189:       end
// 190:     end
// 191:
// 192:     # Logic for the :asserted_value parameter
// 193:     module AssertedValuePlugin
// 194:       def assign(val)
// 195:         assert_value(val)
// 196:         super(val)
// 197:       end
// 198:
// 199:       def _value
// 200:         reading? ? @value : eval_parameter(:asserted_value)
// 201:       end
// 202:
// 203:       # The asserted value as a binary string.
// 204:       #
// 205:       # Rationale: while reading, +#to_binary_s+ will use the
// 206:       # value read in, rather than the +:asserted_value+.
// 207:       # This feature is used by Skip.
// 208:       def asserted_binary_s
// 209:         value_to_binary_string(eval_parameter(:asserted_value))
// 210:       end
// 211:
// 212:       def do_read(io) # :nodoc:
// 213:         super(io)
// 214:         assert!
// 215:       end
// 216:
// 217:       def assert!
// 218:         assert_value(snapshot)
// 219:       end
// 220:
// 221:       def assert_value(current_value)
// 222:         expected = eval_parameter(:asserted_value, value: current_value)
// 223:         if current_value != expected
// 224:           raise ValidityError,
// 225:                 "value is '#{current_value}' but " \
// 226:                 "expected '#{expected}' for #{debug_name}"
// 227:         end
// 228:       end
// 229:     end
// 230:
// 231:     ###########################################################################
// 232:     # To be implemented by subclasses
// 233:
// 234:     # Return the string representation that +val+ will take when written.
// 235:     def value_to_binary_string(val)
// 236:       raise NotImplementedError
// 237:     end
// 238:
// 239:     # Read a number of bytes from +io+ and return the value they represent.
// 240:     def read_and_return_value(io)
// 241:       raise NotImplementedError
// 242:     end
// 243:
// 244:     # Return a sensible default for this data.
// 245:     def sensible_default
// 246:       raise NotImplementedError
// 247:     end
// 248:
// 249:     # To be implemented by subclasses
// 250:     ###########################################################################
// 251:   end
// 252: end
