module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/buffer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_instance` at line 62.
pub fn ruby_buffer_l62_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `raw_num_bytes` at line 67.
pub fn ruby_buffer_l67_d2_raw_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_num_bytes', ...args)
}

// Ruby method `clear?` at line 71.
pub fn ruby_buffer_l71_d3_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear?', ...args)
}

// Ruby method `assign(val)` at line 75.
pub fn ruby_buffer_l75_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 79.
pub fn ruby_buffer_l79_d5_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `respond_to_missing?(symbol, include_all = false) # :nodoc:` at line 83.
pub fn ruby_buffer_l83_d6_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_missing?', ...args)
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 87.
pub fn ruby_buffer_l87_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 91.
pub fn ruby_buffer_l91_d8_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_write(io) # :nodoc:` at line 98.
pub fn ruby_buffer_l98_d9_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes # :nodoc:` at line 105.
pub fn ruby_buffer_l105_d10_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `initialize(length)` at line 112.
pub fn ruby_buffer_l112_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `before_transform` at line 117.
pub fn ruby_buffer_l117_d12_before_transform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('before_transform', ...args)
}

// Ruby method `num_bytes_remaining` at line 122.
pub fn ruby_buffer_l122_d13_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('num_bytes_remaining', ...args)
}

// Ruby method `skip(n)` at line 128.
pub fn ruby_buffer_l128_d14_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip', ...args)
}

// Ruby method `seek_abs(n)` at line 135.
pub fn ruby_buffer_l135_d15_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('seek_abs', ...args)
}

// Ruby method `read(n)` at line 144.
pub fn ruby_buffer_l144_d16_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read', ...args)
}

// Ruby method `write(data)` at line 151.
pub fn ruby_buffer_l151_d17_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write', ...args)
}

// Ruby method `after_read_transform` at line 161.
pub fn ruby_buffer_l161_d18_after_read_transform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('after_read_transform', ...args)
}

// Ruby method `after_write_transform` at line 165.
pub fn ruby_buffer_l165_d19_after_write_transform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('after_write_transform', ...args)
}

// Ruby method `buffer_limited_n(n)` at line 169.
pub fn ruby_buffer_l169_d20_buffer_limited_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('buffer_limited_n', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 189.
pub fn ruby_buffer_l189_d21_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
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
