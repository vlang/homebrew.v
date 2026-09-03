module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/buffer.rb`.
// The original source is retained below until every stub has a typed V body.
pub type BufferReadFn = fn(mut BufferIO) !brew_runtime.Value

pub type BufferWriteFn = fn(mut BufferIO, brew_runtime.Value) !

@[heap]
pub struct BufferObject {
pub:
	type_name string
mut:
	base        &BaseObject
	child       brew_runtime.Value
	read_child  BufferReadFn = unsafe { nil }
	write_child BufferWriteFn = unsafe { nil }
	has_reader  bool
	has_writer  bool
}

@[heap]
pub struct BufferIO {
mut:
	chain           &IOChain
	bytes_remaining int
	buf_start       int
	buf_end         int
}

fn buffer_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_bindata_buffer(length int, child brew_runtime.Value) &BufferObject {
	parameters := {
		'length': brew_runtime.int_value(length)
		'type':   child
	}
	return &BufferObject{
		type_name: 'BinData::Buffer'
		base: new_base_object('BinData::Buffer', parameters)
		child: child
	}
}

pub fn (mut object BufferObject) set_io_callbacks(reader BufferReadFn, writer BufferWriteFn) {
	object.read_child = reader
	object.write_child = writer
	object.has_reader = true
	object.has_writer = true
}

fn buffer_object_value(object &BufferObject) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: object.type_name
		repr: object.child.repr
		map_data: object.base.parameters
		attributes: {
			'buffer_object_address': u64(voidptr(object)).str()
		}
	}
}

pub fn buffer_boundary_value(object &BufferObject) brew_runtime.Value {
	return buffer_object_value(object)
}

fn buffer_object_from_value(value brew_runtime.Value) &BufferObject {
	if address := value.attributes['buffer_object_address'] {
		return unsafe { &BufferObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	child := value.map_data['type'] or { value }
	return &BufferObject{
		type_name: if value.type_name.len > 0 { value.type_name } else { 'BinData::Buffer' }
		base: base
		child: child
	}
}

pub fn new_buffer_reader_io(reader &IORead, length int) &BufferIO {
	mut buffer := &BufferIO{
		chain: reader.io
		bytes_remaining: length
	}
	buffer.before_transform()
	return buffer
}

pub fn new_buffer_writer_io(writer &IOWrite, length int) &BufferIO {
	mut buffer := &BufferIO{
		chain: writer.io
		bytes_remaining: length
	}
	buffer.before_transform()
	return buffer
}

pub fn (mut buffer BufferIO) before_transform() {
	buffer.buf_start = buffer.chain.offset()
	buffer.buf_end = buffer.buf_start + buffer.bytes_remaining
}

pub fn (mut buffer BufferIO) num_bytes_remaining() int {
	remaining := buffer.chain.num_bytes_remaining() or { return buffer.bytes_remaining }
	return if remaining < buffer.bytes_remaining { remaining } else { buffer.bytes_remaining }
}

pub fn (buffer &BufferIO) offset() int {
	return buffer.chain.offset()
}

pub fn (mut buffer BufferIO) limited_count(requested ?int) int {
	if count := requested {
		if count > 0 {
			return if count > buffer.bytes_remaining { buffer.bytes_remaining } else { count }
		}
		return 0
	}
	return buffer.bytes_remaining
}

pub fn (mut buffer BufferIO) skip(count int) ! {
	nbytes := buffer.limited_count(count)
	buffer.bytes_remaining -= nbytes
	buffer.chain.skip(nbytes)!
}

pub fn (mut buffer BufferIO) seek_abs(position int) ! {
	if position < buffer.buf_start || position >= buffer.buf_end {
		return error('can not seek to abs_offset outside of buffer')
	}
	buffer.bytes_remaining -= position - buffer.offset()
	buffer.chain.seek_abs(position)!
}

pub fn (mut buffer BufferIO) read(count ?int) !string {
	nbytes := buffer.limited_count(count)
	buffer.bytes_remaining -= nbytes
	return buffer.chain.read(nbytes)!.bytestr()
}

pub fn (mut buffer BufferIO) write(data string) !int {
	nbytes := buffer.limited_count(data.len)
	buffer.bytes_remaining -= nbytes
	return buffer.chain.write(data.bytes()[..nbytes])!
}

pub fn (mut buffer BufferIO) after_read_transform() ! {
	buffer.read(none)!
}

pub fn (mut buffer BufferIO) after_write_transform() ! {
	buffer.write('\0'.repeat(buffer.bytes_remaining))!
}

fn buffer_io_value(buffer &BufferIO) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::Buffer::BufferIO'
		repr: 'BinData::Buffer::BufferIO'
		attributes: {
			'buffer_io_address': u64(voidptr(buffer)).str()
		}
	}
}

fn buffer_io_from_value(value brew_runtime.Value) &BufferIO {
	address := value.attributes['buffer_io_address'] or { panic('expected BufferIO') }
	return unsafe { &BufferIO(voidptr(address.u64())) }
}

fn buffer_length(object &BufferObject) int {
	value := object.base.parameters['length'] or { return 0 }
	return int(value.as_int() or { panic('buffer length must evaluate to an integer') })
}

fn sanitize_buffer_parameters(object_class brew_runtime.Value, values map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := normalized_base_parameters(values)
	for key, value in object_class.map_data {
		result[key] = value
	}
	length := result['length'] or { return error("parameter 'length' must be specified") }
	if !sanitize_value_converts_to_integer(length) {
		return error("parameter 'length' must evaluate to an integer")
	}
	type_value := result['type'] or { return error("parameter 'type' must be specified") }
	if type_value.type_name != 'BinData::SanitizedPrototype' {
		if prototype := new_sanitized_prototype(type_value, map[string]brew_runtime.Value{}, map[string]brew_runtime.Value{}) {
			result['type'] = sanitized_prototype_boundary_value(prototype)
		}
	}
	return result
}

// Ruby method `initialize_instance` at line 62.
pub fn ruby_buffer_l62_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Buffer#initialize_instance requires receiver') }
	mut object := buffer_object_from_value(args[0])
	object.child = object.base.parameters['type'] or { buffer_nil_value() }
	return buffer_nil_value()
}

// Ruby method `raw_num_bytes` at line 67.
pub fn ruby_buffer_l67_d2_raw_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	object := buffer_object_from_value(args[0])
	if value := object.child.attributes['do_num_bytes'] {
		return brew_runtime.int_value(value.i64())
	}
	if object.child.type_name == 'String' {
		return brew_runtime.int_value(object.child.repr.len)
	}
	return brew_runtime.int_value(0)
}

// Ruby method `clear?` at line 71.
pub fn ruby_buffer_l71_d3_clear(args ...brew_runtime.Value) brew_runtime.Value {
	object := buffer_object_from_value(args[0])
	return brew_runtime.bool_value((object.child.attributes['clear'] or { 'false' }).bool())
}

// Ruby method `assign(val)` at line 75.
pub fn ruby_buffer_l75_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Buffer#assign requires value') }
	mut object := buffer_object_from_value(args[0])
	object.child = args[1]
	object.base.clear = false
	return args[1]
}

// Ruby method `snapshot` at line 79.
pub fn ruby_buffer_l79_d5_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return buffer_object_from_value(args[0]).child
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 83.
pub fn ruby_buffer_l83_d6_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Buffer#respond_to_missing? requires symbol') }
	object := buffer_object_from_value(args[0])
	name := args[1].as_string().trim_left(':')
	return brew_runtime.bool_value(name in (object.child.attributes['method_names'] or { '' }).split(','))
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 87.
pub fn ruby_buffer_l87_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Buffer#method_missing requires symbol') }
	name := args[1].as_string().trim_left(':')
	if name in ['snapshot', 'value', 'to_s'] {
		return buffer_object_from_value(args[0]).child
	}
	panic('undefined method `${name}` for buffered child')
}

// Ruby method `do_read(io) # :nodoc:` at line 91.
pub fn ruby_buffer_l91_d8_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Buffer#do_read requires IO') }
	mut object := buffer_object_from_value(args[0])
	mut buffer := new_buffer_reader_io(io_read_from_value(args[1]), buffer_length(object))
	if object.has_reader {
		object.child = object.read_child(mut buffer) or { panic(err) }
	} else {
		object.child = brew_runtime.string_value(buffer.read(none) or { panic(err) })
	}
	buffer.after_read_transform() or { panic(err) }
	return object.child
}

// Ruby method `do_write(io) # :nodoc:` at line 98.
pub fn ruby_buffer_l98_d9_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Buffer#do_write requires IO') }
	mut object := buffer_object_from_value(args[0])
	mut buffer := new_buffer_writer_io(io_write_from_value(args[1]), buffer_length(object))
	if object.has_writer {
		object.write_child(mut buffer, object.child) or { panic(err) }
	} else {
		buffer.write(object.child.as_string()) or { panic(err) }
	}
	buffer.after_write_transform() or { panic(err) }
	return buffer_nil_value()
}

// Ruby method `do_num_bytes # :nodoc:` at line 105.
pub fn ruby_buffer_l105_d10_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(buffer_length(buffer_object_from_value(args[0])))
}

// Ruby method `initialize(length)` at line 112.
pub fn ruby_buffer_l112_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BufferIO#initialize requires length') }
	length := int(args.last().as_int() or { panic(err) })
	if args[0].type_name == 'BinData::IO::Read' {
		return buffer_io_value(new_buffer_reader_io(io_read_from_value(args[0]), length))
	}
	if args[0].type_name == 'BinData::IO::Write' {
		return buffer_io_value(new_buffer_writer_io(io_write_from_value(args[0]), length))
	}
	panic('BufferIO#initialize requires typed IO receiver')
}

// Ruby method `before_transform` at line 117.
pub fn ruby_buffer_l117_d12_before_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	buffer.before_transform()
	return buffer_nil_value()
}

// Ruby method `num_bytes_remaining` at line 122.
pub fn ruby_buffer_l122_d13_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	return brew_runtime.int_value(buffer.num_bytes_remaining())
}

// Ruby method `skip(n)` at line 128.
pub fn ruby_buffer_l128_d14_skip(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BufferIO#skip requires count') }
	mut buffer := buffer_io_from_value(args[0])
	buffer.skip(int(args[1].int_data)) or { panic(err) }
	return buffer_nil_value()
}

// Ruby method `seek_abs(n)` at line 135.
pub fn ruby_buffer_l135_d15_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BufferIO#seek_abs requires position') }
	mut buffer := buffer_io_from_value(args[0])
	buffer.seek_abs(int(args[1].int_data)) or { panic(err) }
	return buffer_nil_value()
}

// Ruby method `read(n)` at line 144.
pub fn ruby_buffer_l144_d16_read(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	count := if args.len > 1 && args[1].type_name != 'NilClass' {
		?int(int(args[1].int_data))
	} else {
		?int(none)
	}
	return brew_runtime.string_value(buffer.read(count) or { panic(err) })
}

// Ruby method `write(data)` at line 151.
pub fn ruby_buffer_l151_d17_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BufferIO#write requires data') }
	mut buffer := buffer_io_from_value(args[0])
	return brew_runtime.int_value(buffer.write(args[1].as_string()) or { panic(err) })
}

// Ruby method `after_read_transform` at line 161.
pub fn ruby_buffer_l161_d18_after_read_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	buffer.after_read_transform() or { panic(err) }
	return buffer_nil_value()
}

// Ruby method `after_write_transform` at line 165.
pub fn ruby_buffer_l165_d19_after_write_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	buffer.after_write_transform() or { panic(err) }
	return buffer_nil_value()
}

// Ruby method `buffer_limited_n(n)` at line 169.
pub fn ruby_buffer_l169_d20_buffer_limited_n(args ...brew_runtime.Value) brew_runtime.Value {
	mut buffer := buffer_io_from_value(args[0])
	count := if args.len > 1 && args[1].type_name != 'NilClass' {
		?int(int(args[1].int_data))
	} else {
		?int(none)
	}
	return brew_runtime.int_value(buffer.limited_count(count))
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 189.
pub fn ruby_buffer_l189_d21_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BufferArgProcessor#sanitize_parameters! requires class and params') }
	object_class := args[args.len - 2]
	params := args.last()
	if params.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params)
		parameters.values = sanitize_buffer_parameters(object_class, parameters.values) or { panic(err) }
		return sanitized_parameters_boundary_value(parameters)
	}
	return brew_runtime.map_value(sanitize_buffer_parameters(object_class, params.as_map() or { panic(err) }) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # A Buffer is conceptually a substream within a data stream.  It has a
// 6:   # defined size and it will always read or write the exact number of bytes to
// 7:   # fill the buffer.  Short reads will skip over unused bytes and short writes
// 8:   # will pad the substream with "\0" bytes.
// 9:   #
// 10:   #   require 'bindata'
// 11:   #
// 12:   #   obj = BinData::Buffer.new(length: 5, type: [:string, {value: "abc"}])
// 13:   #   obj.to_binary_s #=> "abc\000\000"
// 14:   #
// 15:   #
// 16:   #   class MyBuffer < BinData::Buffer
// 17:   #     default_parameter length: 8
// 18:   #
// 19:   #     endian :little
// 20:   #
// 21:   #     uint16 :num1
// 22:   #     uint16 :num2
// 23:   #     # padding occurs here
// 24:   #   end
// 25:   #
// 26:   #   obj = MyBuffer.read("\001\000\002\000\000\000\000\000")
// 27:   #   obj.num1 #=> 1
// 28:   #   obj.num1 #=> 2
// 29:   #   obj.raw_num_bytes #=> 4
// 30:   #   obj.num_bytes #=> 8
// 31:   #
// 32:   #
// 33:   #   class StringTable < BinData::Record
// 34:   #     endian :little
// 35:   #
// 36:   #     uint16 :table_size_in_bytes
// 37:   #     buffer :strings, length: :table_size_in_bytes do
// 38:   #       array read_until: :eof do
// 39:   #         uint8 :len
// 40:   #         string :str, length: :len
// 41:   #       end
// 42:   #     end
// 43:   #   end
// 44:   #
// 45:   #
// 46:   # == Parameters
// 47:   #
// 48:   # Parameters may be provided at initialisation to control the behaviour of
// 49:   # an object.  These params are:
// 50:   #
// 51:   # <tt>:length</tt>::   The number of bytes in the buffer.
// 52:   # <tt>:type</tt>::     The single type inside the buffer.  Use a struct if
// 53:   #                      multiple fields are required.
// 54:   class Buffer < BinData::Base
// 55:     extend DSLMixin
// 56:
// 57:     dsl_parser    :buffer
// 58:     arg_processor :buffer
// 59:
// 60:     mandatory_parameters :length, :type
// 61:
// 62:     def initialize_instance
// 63:       @type = get_parameter(:type).instantiate(nil, self)
// 64:     end
// 65:
// 66:     # The number of bytes used, ignoring the padding imposed by the buffer.
// 67:     def raw_num_bytes
// 68:       @type.num_bytes
// 69:     end
// 70:
// 71:     def clear?
// 72:       @type.clear?
// 73:     end
// 74:
// 75:     def assign(val)
// 76:       @type.assign(val)
// 77:     end
// 78:
// 79:     def snapshot
// 80:       @type.snapshot
// 81:     end
// 82:
// 83:     def respond_to_missing?(symbol, include_all = false) # :nodoc:
// 84:       @type.respond_to?(symbol, include_all) || super
// 85:     end
// 86:
// 87:     def method_missing(symbol, *args, &block) # :nodoc:
// 88:       @type.__send__(symbol, *args, &block)
// 89:     end
// 90:
// 91:     def do_read(io) # :nodoc:
// 92:       buf_len = eval_parameter(:length)
// 93:       io.transform(BufferIO.new(buf_len)) do |transformed_io, _|
// 94:         @type.do_read(transformed_io)
// 95:       end
// 96:     end
// 97:
// 98:     def do_write(io) # :nodoc:
// 99:       buf_len = eval_parameter(:length)
// 100:       io.transform(BufferIO.new(buf_len)) do |transformed_io, _|
// 101:         @type.do_write(transformed_io)
// 102:       end
// 103:     end
// 104:
// 105:     def do_num_bytes # :nodoc:
// 106:       eval_parameter(:length)
// 107:     end
// 108:
// 109:     # Transforms the IO stream to restrict access inside
// 110:     # a buffer of specified length.
// 111:     class BufferIO < IO::Transform
// 112:       def initialize(length)
// 113:         super()
// 114:         @bytes_remaining = length
// 115:       end
// 116:
// 117:       def before_transform
// 118:         @buf_start = offset
// 119:         @buf_end = @buf_start + @bytes_remaining
// 120:       end
// 121:
// 122:       def num_bytes_remaining
// 123:         [@bytes_remaining, super].min
// 124:       rescue IOError
// 125:         @bytes_remaining
// 126:       end
// 127:
// 128:       def skip(n)
// 129:         nbytes = buffer_limited_n(n)
// 130:         @bytes_remaining -= nbytes
// 131:
// 132:         chain_skip(nbytes)
// 133:       end
// 134:
// 135:       def seek_abs(n)
// 136:         if n < @buf_start || n >= @buf_end
// 137:           raise IOError, "can not seek to abs_offset outside of buffer"
// 138:         end
// 139:
// 140:         @bytes_remaining -= (n - offset)
// 141:         chain_seek_abs(n)
// 142:       end
// 143:
// 144:       def read(n)
// 145:         nbytes = buffer_limited_n(n)
// 146:         @bytes_remaining -= nbytes
// 147:
// 148:         chain_read(nbytes)
// 149:       end
// 150:
// 151:       def write(data)
// 152:         nbytes = buffer_limited_n(data.size)
// 153:         @bytes_remaining -= nbytes
// 154:         if nbytes < data.size
// 155:           data = data[0, nbytes]
// 156:         end
// 157:
// 158:         chain_write(data)
// 159:       end
// 160:
// 161:       def after_read_transform
// 162:         read(nil)
// 163:       end
// 164:
// 165:       def after_write_transform
// 166:         write("\x00" * @bytes_remaining)
// 167:       end
// 168:
// 169:       def buffer_limited_n(n)
// 170:         if n.nil?
// 171:           @bytes_remaining
// 172:         elsif n.positive?
// 173:           limit = @bytes_remaining
// 174:           n > limit ? limit : n
// 175: # uncomment if we decide to allow backwards skipping
// 176: #        elsif n.negative?
// 177: #          limit = @bytes_remaining + @buf_start - @buf_end
// 178: #          n < limit ? limit : n
// 179:         else
// 180:           0
// 181:         end
// 182:       end
// 183:     end
// 184:   end
// 185:
// 186:   class BufferArgProcessor < BaseArgProcessor
// 187:     include MultiFieldArgSeparator
// 188:
// 189:     def sanitize_parameters!(obj_class, params)
// 190:       params.merge!(obj_class.dsl_params)
// 191:       params.must_be_integer(:length)
// 192:       params.sanitize_object_prototype(:type)
// 193:     end
// 194:   end
// 195: end
