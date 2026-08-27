module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/delayed_io.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_instance` at line 63.
pub fn ruby_delayed_io_l63_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `clear?` at line 70.
pub fn ruby_delayed_io_l70_d2_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear?', ...args)
}

// Ruby method `assign(val)` at line 74.
pub fn ruby_delayed_io_l74_d3_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 78.
pub fn ruby_delayed_io_l78_d4_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `num_bytes` at line 82.
pub fn ruby_delayed_io_l82_d5_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('num_bytes', ...args)
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 86.
pub fn ruby_delayed_io_l86_d6_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_missing?', ...args)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 90.
pub fn ruby_delayed_io_l90_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `abs_offset` at line 94.
pub fn ruby_delayed_io_l94_d8_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abs_offset', ...args)
}

// Ruby method `abs_offset=(offset)` at line 99.
pub fn ruby_delayed_io_l99_d9_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abs_offset=', ...args)
}

// Ruby method `rel_offset` at line 103.
pub fn ruby_delayed_io_l103_d10_rel_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rel_offset', ...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 107.
pub fn ruby_delayed_io_l107_d11_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_write(io) # :nodoc:` at line 111.
pub fn ruby_delayed_io_l111_d12_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes # :nodoc:` at line 115.
pub fn ruby_delayed_io_l115_d13_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `include_obj?` at line 119.
pub fn ruby_delayed_io_l119_d14_include_obj(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include_obj?', ...args)
}

// Ruby method `read_now!` at line 125.
pub fn ruby_delayed_io_l125_d15_read_now(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_now!', ...args)
}

// Ruby method `write_now!` at line 137.
pub fn ruby_delayed_io_l137_d16_write_now(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_now!', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 149.
pub fn ruby_delayed_io_l149_d17_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
}

// Ruby method `auto_call_delayed_io` at line 161.
pub fn ruby_delayed_io_l161_d18_auto_call_delayed_io(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('auto_call_delayed_io', ...args)
}

// Ruby alias_method `DelayedIO.send(:alias_method, :initialize_instance_without_record_io, :initialize_instance)` at line 166.
pub fn ruby_delayed_io_l166_d19_initialize_instance_without_record_io(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance_without_record_io', ...args)
}

// Ruby define_method `DelayedIO.send(:define_method, :initialize_instance) do` at line 167.
pub fn ruby_delayed_io_l167_d20_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `initialize_shared_instance` at line 180.
pub fn ruby_delayed_io_l180_d21_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_shared_instance', ...args)
}

// Ruby method `read(io)` at line 185.
pub fn ruby_delayed_io_l185_d22_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read', ...args)
}

// Ruby method `write(io, *_)` at line 189.
pub fn ruby_delayed_io_l189_d23_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write', ...args)
}

// Ruby method `num_bytes` at line 193.
pub fn ruby_delayed_io_l193_d24_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('num_bytes', ...args)
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
