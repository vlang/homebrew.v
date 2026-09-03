module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/delayed_io.rb`.
// The original source is retained below until every stub has a typed V body.
pub type DelayedReadFn = fn(mut IORead) !brew_runtime.Value

pub type DelayedWriteFn = fn(mut IOWrite, brew_runtime.Value) !

@[heap]
pub struct DelayedIOObject {
mut:
	base         &BaseObject
	child        brew_runtime.Value
	abs_offset   int
	has_offset   bool
	read_io      &IORead = unsafe { nil }
	write_io     &IOWrite = unsafe { nil }
	has_read_io  bool
	has_write_io bool
	read_child   DelayedReadFn = unsafe { nil }
	write_child  DelayedWriteFn = unsafe { nil }
	has_reader   bool
	has_writer   bool
}

fn delayed_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn instantiate_delayed_child(prototype brew_runtime.Value, parent brew_runtime.Value) brew_runtime.Value {
	if prototype.type_name == 'BinData::SanitizedPrototype' {
		mut actual := sanitized_prototype_from_value(prototype)
		return actual.instantiate(delayed_nil_value(), false, parent, true)
	}
	if sanitize_is_base_instance(prototype) {
		return ruby_base_l97_d10_new(prototype, delayed_nil_value(), parent)
	}
	return prototype
}

pub fn new_bindata_delayed_io(parameters map[string]brew_runtime.Value) &DelayedIOObject {
	mut object := &DelayedIOObject{
		base: new_base_object('BinData::DelayedIO', normalized_base_parameters(parameters))
		child: delayed_nil_value()
	}
	object.child = instantiate_delayed_child(object.base.parameters['type'] or { delayed_nil_value() }, delayed_io_boundary_value(object))
	return object
}

pub fn (mut object DelayedIOObject) set_io_callbacks(reader DelayedReadFn, writer DelayedWriteFn) {
	object.read_child = reader
	object.write_child = writer
	object.has_reader = true
	object.has_writer = true
}

fn delayed_io_value(object &DelayedIOObject) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::DelayedIO'
		repr: object.child.repr
		map_data: object.base.parameters
		attributes: {
			'delayed_io_address': u64(voidptr(object)).str()
		}
	}
}

pub fn delayed_io_boundary_value(object &DelayedIOObject) brew_runtime.Value {
	return delayed_io_value(object)
}

fn delayed_io_from_value(value brew_runtime.Value) &DelayedIOObject {
	if address := value.attributes['delayed_io_address'] {
		return unsafe { &DelayedIOObject(voidptr(address.u64())) }
	}
	mut base := base_object_from_value(value)
	return &DelayedIOObject{
		base: base
		child: value.map_data['type'] or { delayed_nil_value() }
	}
}

fn delayed_offset(object &DelayedIOObject) int {
	if object.has_offset {
		return object.abs_offset
	}
	value := object.base.parameters['read_abs_offset'] or { return 0 }
	return int(value.as_int() or { panic('read_abs_offset must evaluate to an integer') })
}

fn delayed_include(object &DelayedIOObject) bool {
	value := object.base.parameters['onlyif'] or { return true }
	return base_value_truthy(value)
}

fn delayed_child_snapshot(object &DelayedIOObject) brew_runtime.Value {
	if 'base_object_address' in object.child.attributes {
		return base_object_from_value(object.child).snapshot()
	}
	return object.child
}

fn delayed_child_num_bytes(object &DelayedIOObject) int {
	if count := object.child.attributes['do_num_bytes'] {
		return count.int()
	}
	return object.child.as_string().len
}

pub fn (mut object DelayedIOObject) read_now() !brew_runtime.Value {
	if !delayed_include(object) {
		return delayed_nil_value()
	}
	if !object.has_read_io {
		return error('read from where?')
	}
	object.read_io.seek_to_abs_offset(delayed_offset(object))!
	object.base.reading = true
	defer { object.base.reading = false }
	if object.has_reader {
		object.child = object.read_child(mut object.read_io)!
	} else {
		count := delayed_child_num_bytes(object)
		object.child = brew_runtime.string_value(object.read_io.readbytes(count)!.bytestr())
	}
	return object.child
}

pub fn (mut object DelayedIOObject) write_now() ! {
	if !delayed_include(object) {
		return
	}
	if !object.has_write_io {
		return error('write to where?')
	}
	object.write_io.seek_to_abs_offset(delayed_offset(object))!
	if object.has_writer {
		object.write_child(mut object.write_io, object.child)!
	} else {
		object.write_io.writebytes(object.child.as_string().bytes())!
	}
}

fn sanitize_delayed_parameters(object_class brew_runtime.Value, values map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := normalized_base_parameters(values)
	for key, value in object_class.map_data {
		result[key] = value
	}
	offset := result['read_abs_offset'] or { return error("parameter 'read_abs_offset' must be specified") }
	if !sanitize_value_converts_to_integer(offset) {
		return error("parameter 'read_abs_offset' must evaluate to an integer")
	}
	if 'type' !in result {
		return error("parameter 'type' must be specified")
	}
	return result
}

fn auto_delayed_values(receiver brew_runtime.Value) []brew_runtime.Value {
	value := ruby_base_l257_d35_top_level_get(receiver, brew_runtime.object_value('Symbol', ':delayed_ios'))
	return if value.type_name == 'Array' {
		value.as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
}

// Ruby method `initialize_instance` at line 63.
pub fn ruby_delayed_io_l63_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('DelayedIO#initialize_instance requires receiver') }
	mut object := delayed_io_from_value(args[0])
	object.child = instantiate_delayed_child(object.base.parameters['type'] or { delayed_nil_value() }, args[0])
	object.has_offset = false
	object.has_read_io = false
	object.has_write_io = false
	return delayed_nil_value()
}

// Ruby method `clear?` at line 70.
pub fn ruby_delayed_io_l70_d2_clear(args ...brew_runtime.Value) brew_runtime.Value {
	object := delayed_io_from_value(args[0])
	return brew_runtime.bool_value((object.child.attributes['clear'] or { 'false' }).bool())
}

// Ruby method `assign(val)` at line 74.
pub fn ruby_delayed_io_l74_d3_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#assign requires value') }
	mut object := delayed_io_from_value(args[0])
	object.child = args[1]
	return args[1]
}

// Ruby method `snapshot` at line 78.
pub fn ruby_delayed_io_l78_d4_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return delayed_child_snapshot(delayed_io_from_value(args[0]))
}

// Ruby method `num_bytes` at line 82.
pub fn ruby_delayed_io_l82_d5_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(delayed_child_num_bytes(delayed_io_from_value(args[0])))
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 86.
pub fn ruby_delayed_io_l86_d6_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#respond_to_missing? requires symbol') }
	object := delayed_io_from_value(args[0])
	return brew_runtime.bool_value(args[1].as_string().trim_left(':') in (object.child.attributes['method_names'] or { '' }).split(','))
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 90.
pub fn ruby_delayed_io_l90_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#method_missing requires symbol') }
	name := args[1].as_string().trim_left(':')
	if name in ['snapshot', 'value', 'to_s'] {
		return delayed_child_snapshot(delayed_io_from_value(args[0]))
	}
	panic('undefined method `${name}` for delayed child')
}

// Ruby method `abs_offset` at line 94.
pub fn ruby_delayed_io_l94_d8_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(delayed_offset(delayed_io_from_value(args[0])))
}

// Ruby method `abs_offset=(offset)` at line 99.
pub fn ruby_delayed_io_l99_d9_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#abs_offset= requires offset') }
	mut object := delayed_io_from_value(args[0])
	object.abs_offset = int(args[1].as_int() or { panic(err) })
	object.has_offset = true
	return args[1]
}

// Ruby method `rel_offset` at line 103.
pub fn ruby_delayed_io_l103_d10_rel_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_delayed_io_l94_d8_abs_offset(...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 107.
pub fn ruby_delayed_io_l107_d11_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#do_read requires IO') }
	mut object := delayed_io_from_value(args[0])
	object.read_io = io_read_from_value(args[1])
	object.has_read_io = true
	return delayed_nil_value()
}

// Ruby method `do_write(io) # :nodoc:` at line 111.
pub fn ruby_delayed_io_l111_d12_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIO#do_write requires IO') }
	mut object := delayed_io_from_value(args[0])
	object.write_io = io_write_from_value(args[1])
	object.has_write_io = true
	return delayed_nil_value()
}

// Ruby method `do_num_bytes # :nodoc:` at line 115.
pub fn ruby_delayed_io_l115_d13_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(0)
}

// Ruby method `include_obj?` at line 119.
pub fn ruby_delayed_io_l119_d14_include_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(delayed_include(delayed_io_from_value(args[0])))
}

// Ruby method `read_now!` at line 125.
pub fn ruby_delayed_io_l125_d15_read_now(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := delayed_io_from_value(args[0])
	return object.read_now() or { panic(err) }
}

// Ruby method `write_now!` at line 137.
pub fn ruby_delayed_io_l137_d16_write_now(args ...brew_runtime.Value) brew_runtime.Value {
	mut object := delayed_io_from_value(args[0])
	object.write_now() or { panic(err) }
	return delayed_nil_value()
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 149.
pub fn ruby_delayed_io_l149_d17_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DelayedIoArgProcessor#sanitize_parameters! requires class and params') }
	object_class := args[args.len - 2]
	params := args.last()
	if params.type_name == 'BinData::SanitizedParameters' {
		mut parameters := sanitized_parameters_from_value(params)
		parameters.values = sanitize_delayed_parameters(object_class, parameters.values) or { panic(err) }
		parameters.sanitize_object_prototype('type') or { panic(err) }
		return sanitized_parameters_boundary_value(parameters)
	}
	return brew_runtime.map_value(sanitize_delayed_parameters(object_class, params.as_map() or { panic(err) }) or { panic(err) })
}

// Ruby method `auto_call_delayed_io` at line 161.
pub fn ruby_delayed_io_l161_d18_auto_call_delayed_io(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('Module', 'BinData::AutoCallDelayedIO')
	}
	mut attributes := args[0].attributes.clone()
	attributes['auto_call_delayed_io'] = 'true'
	return brew_runtime.Value{ ...args[0], attributes: attributes }
}

// Ruby alias_method `DelayedIO.send(:alias_method, :initialize_instance_without_record_io, :initialize_instance)` at line 166.
pub fn ruby_delayed_io_l166_d19_initialize_instance_without_record_io(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_delayed_io_l63_d1_initialize_instance(...args)
}

// Ruby define_method `DelayedIO.send(:define_method, :initialize_instance) do` at line 167.
pub fn ruby_delayed_io_l167_d20_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('DelayedIO#initialize_instance requires receiver') }
	object := delayed_io_from_value(args[0])
	if object.base.has_parent {
		mut values := auto_delayed_values(args[0])
		if !values.any(it.attributes['delayed_io_address'] == args[0].attributes['delayed_io_address']) {
			values << args[0]
			ruby_base_l253_d34_top_level_set(args[0], brew_runtime.object_value('Symbol', ':delayed_ios'), brew_runtime.array_value(values))
		}
	}
	return ruby_delayed_io_l166_d19_initialize_instance_without_record_io(...args)
}

// Ruby method `initialize_shared_instance` at line 180.
pub fn ruby_delayed_io_l180_d21_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('AutoCallDelayedIO#initialize_shared_instance requires receiver') }
	ruby_base_l253_d34_top_level_set(args[0], brew_runtime.object_value('Symbol', ':delayed_ios'), brew_runtime.array_value([]))
	return args[0]
}

// Ruby method `read(io)` at line 185.
pub fn ruby_delayed_io_l185_d22_read(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('AutoCallDelayedIO#read requires IO') }
	result := ruby_base_l144_d16_read(...args)
	for value in auto_delayed_values(args[0]) {
		mut delayed := delayed_io_from_value(value)
		delayed.read_now() or { panic(err) }
	}
	return result
}

// Ruby method `write(io, *_)` at line 189.
pub fn ruby_delayed_io_l189_d23_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('AutoCallDelayedIO#write requires IO') }
	result := ruby_base_l157_d17_write(...args)
	for value in auto_delayed_values(args[0]) {
		mut delayed := delayed_io_from_value(value)
		delayed.write_now() or { panic(err) }
	}
	return result
}

// Ruby method `num_bytes` at line 193.
pub fn ruby_delayed_io_l193_d24_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(ruby_base_l174_d19_to_binary_s(...args).as_string().len)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2: require 'bindata/dsl'
// 3:
// 4: module BinData
// 5:   # BinData declarations are evaluated in a single pass.
// 6:   # However, some binary formats require multi pass processing.  A common
// 7:   # reason is seeking backwards in the input stream.
// 8:   #
// 9:   # DelayedIO supports multi pass processing.  It works by ignoring the normal
// 10:   # #read or #write calls.  The user must explicitly call the #read_now! or
// 11:   # #write_now! methods to process an additional pass.  This additional pass
// 12:   # must specify the abs_offset of the I/O operation.
// 13:   #
// 14:   #   require 'bindata'
// 15:   #
// 16:   #   obj = BinData::DelayedIO.new(read_abs_offset: 3, type: :uint16be)
// 17:   #   obj.read("\x00\x00\x00\x11\x12")
// 18:   #   obj #=> 0
// 19:   #
// 20:   #   obj.read_now!
// 21:   #   obj #=> 0x1112
// 22:   #
// 23:   #   - OR -
// 24:   #
// 25:   #   obj.read("\x00\x00\x00\x11\x12") { obj.read_now! } #=> 0x1122
// 26:   #
// 27:   #   obj.to_binary_s { obj.write_now! } #=> "\x00\x00\x00\x11\x12"
// 28:   #
// 29:   # You can use the +auto_call_delayed_io+ keyword to cause #read and #write to
// 30:   # automatically perform the extra passes.
// 31:   #
// 32:   #   class ReversePascalString < BinData::Record
// 33:   #     auto_call_delayed_io
// 34:   #
// 35:   #     delayed_io :str, read_abs_offset: 0 do
// 36:   #       string read_length: :len
// 37:   #     end
// 38:   #     count_bytes_remaining :total_size
// 39:   #     skip to_abs_offset: -> { total_size - 1 }
// 40:   #     uint8  :len, value: -> { str.length }
// 41:   #   end
// 42:   #
// 43:   #   s = ReversePascalString.read("hello\x05")
// 44:   #   s.to_binary_s #=> "hello\x05"
// 45:   #
// 46:   #
// 47:   # == Parameters
// 48:   #
// 49:   # Parameters may be provided at initialisation to control the behaviour of
// 50:   # an object.  These params are:
// 51:   #
// 52:   # <tt>:read_abs_offset</tt>::   The abs_offset to start reading at.
// 53:   # <tt>:type</tt>::              The single type inside the delayed io.  Use
// 54:   #                               a struct if multiple fields are required.
// 55:   class DelayedIO < BinData::Base
// 56:     extend DSLMixin
// 57:
// 58:     dsl_parser    :delayed_io
// 59:     arg_processor :delayed_io
// 60:
// 61:     mandatory_parameters :read_abs_offset, :type
// 62:
// 63:     def initialize_instance
// 64:       @type       = get_parameter(:type).instantiate(nil, self)
// 65:       @abs_offset = nil
// 66:       @read_io    = nil
// 67:       @write_io   = nil
// 68:     end
// 69:
// 70:     def clear?
// 71:       @type.clear?
// 72:     end
// 73:
// 74:     def assign(val)
// 75:       @type.assign(val)
// 76:     end
// 77:
// 78:     def snapshot
// 79:       @type.snapshot
// 80:     end
// 81:
// 82:     def num_bytes
// 83:       @type.num_bytes
// 84:     end
// 85:
// 86:     def respond_to_missing?(symbol, include_all = false) # :nodoc:
// 87:       @type.respond_to?(symbol, include_all) || super
// 88:     end
// 89:
// 90:     def method_missing(symbol, *args, &block) # :nodoc:
// 91:       @type.__send__(symbol, *args, &block)
// 92:     end
// 93:
// 94:     def abs_offset
// 95:       @abs_offset || eval_parameter(:read_abs_offset)
// 96:     end
// 97:
// 98:     # Sets the +abs_offset+ to use when writing this object.
// 99:     def abs_offset=(offset)
// 100:       @abs_offset = offset
// 101:     end
// 102:
// 103:     def rel_offset
// 104:       abs_offset
// 105:     end
// 106:
// 107:     def do_read(io) # :nodoc:
// 108:       @read_io = io
// 109:     end
// 110:
// 111:     def do_write(io) # :nodoc:
// 112:       @write_io = io
// 113:     end
// 114:
// 115:     def do_num_bytes # :nodoc:
// 116:       0
// 117:     end
// 118:
// 119:     def include_obj?
// 120:       !has_parameter?(:onlyif) || eval_parameter(:onlyif)
// 121:     end
// 122:
// 123:     # DelayedIO objects aren't read when #read is called.
// 124:     # The reading is delayed until this method is called.
// 125:     def read_now!
// 126:       return unless include_obj?
// 127:       raise IOError, "read from where?" unless @read_io
// 128:
// 129:       @read_io.seek_to_abs_offset(abs_offset)
// 130:       start_read do
// 131:         @type.do_read(@read_io)
// 132:       end
// 133:     end
// 134:
// 135:     # DelayedIO objects aren't written when #write is called.
// 136:     # The writing is delayed until this method is called.
// 137:     def write_now!
// 138:       return unless include_obj?
// 139:       raise IOError, "write to where?" unless @write_io
// 140:
// 141:       @write_io.seek_to_abs_offset(abs_offset)
// 142:       @type.do_write(@write_io)
// 143:     end
// 144:   end
// 145:
// 146:   class DelayedIoArgProcessor < BaseArgProcessor
// 147:     include MultiFieldArgSeparator
// 148:
// 149:     def sanitize_parameters!(obj_class, params)
// 150:       params.merge!(obj_class.dsl_params)
// 151:       params.must_be_integer(:read_abs_offset)
// 152:       params.sanitize_object_prototype(:type)
// 153:     end
// 154:   end
// 155:
// 156:   class Base
// 157:     # Add +auto_call_delayed_io+ keyword to BinData::Base.
// 158:     class << self
// 159:       # The +auto_call_delayed_io+ keyword sets a data object tree to perform
// 160:       # multi pass I/O automatically.
// 161:       def auto_call_delayed_io
// 162:         include AutoCallDelayedIO
// 163:
// 164:         return if DelayedIO.method_defined? :initialize_instance_without_record_io
// 165:
// 166:         DelayedIO.send(:alias_method, :initialize_instance_without_record_io, :initialize_instance)
// 167:         DelayedIO.send(:define_method, :initialize_instance) do
// 168:           if @parent && !defined? @delayed_io_recorded
// 169:             @delayed_io_recorded = true
// 170:             list = top_level_get(:delayed_ios)
// 171:             list << self if list
// 172:           end
// 173:
// 174:           initialize_instance_without_record_io
// 175:         end
// 176:       end
// 177:     end
// 178:
// 179:     module AutoCallDelayedIO
// 180:       def initialize_shared_instance
// 181:         top_level_set(:delayed_ios, [])
// 182:         super
// 183:       end
// 184:
// 185:       def read(io)
// 186:         super(io) { top_level_get(:delayed_ios).each(&:read_now!) }
// 187:       end
// 188:
// 189:       def write(io, *_)
// 190:         super(io) { top_level_get(:delayed_ios).each(&:write_now!) }
// 191:       end
// 192:
// 193:       def num_bytes
// 194:         to_binary_s.size
// 195:       end
// 196:     end
// 197:   end
// 198: end
