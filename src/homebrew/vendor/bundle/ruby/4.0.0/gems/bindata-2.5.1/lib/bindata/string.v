module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/string.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_shared_instance` at line 59.
pub fn ruby_string_l59_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_shared_instance', ...args)
}

// Ruby method `assign(val)` at line 67.
pub fn ruby_string_l67_d2_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 71.
pub fn ruby_string_l71_d3_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `clamp_to_length(str)` at line 86.
pub fn ruby_string_l86_d4_clamp_to_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clamp_to_length', ...args)
}

// Ruby method `trim_padding(str)` at line 104.
pub fn ruby_string_l104_d5_trim_padding(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trim_padding', ...args)
}

// Ruby method `value_to_binary_string(val)` at line 112.
pub fn ruby_string_l112_d6_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value_to_binary_string', ...args)
}

// Ruby method `read_and_return_value(io)` at line 116.
pub fn ruby_string_l116_d7_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `sensible_default` at line 121.
pub fn ruby_string_l121_d8_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `read_and_return_value(io)` at line 127.
pub fn ruby_string_l127_d9_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 135.
pub fn ruby_string_l135_d10_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
}

// Ruby method `sanitized_pad_byte(byte)` at line 145.
pub fn ruby_string_l145_d11_sanitized_pad_byte(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitized_pad_byte', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # A String is a sequence of bytes.  This is the same as strings in Ruby 1.8.
// 5:   # The issue of character encoding is ignored by this class.
// 6:   #
// 7:   #   require 'bindata'
// 8:   #
// 9:   #   data = "abcdefghij"
// 10:   #
// 11:   #   obj = BinData::String.new(read_length: 5)
// 12:   #   obj.read(data)
// 13:   #   obj #=> "abcde"
// 14:   #
// 15:   #   obj = BinData::String.new(length: 6)
// 16:   #   obj.read(data)
// 17:   #   obj #=> "abcdef"
// 18:   #   obj.assign("abcdefghij")
// 19:   #   obj #=> "abcdef"
// 20:   #   obj.assign("abcd")
// 21:   #   obj #=> "abcd\000\000"
// 22:   #
// 23:   #   obj = BinData::String.new(length: 6, trim_padding: true)
// 24:   #   obj.assign("abcd")
// 25:   #   obj #=> "abcd"
// 26:   #   obj.to_binary_s #=> "abcd\000\000"
// 27:   #
// 28:   #   obj = BinData::String.new(length: 6, pad_byte: 'A')
// 29:   #   obj.assign("abcd")
// 30:   #   obj #=> "abcdAA"
// 31:   #   obj.to_binary_s #=> "abcdAA"
// 32:   #
// 33:   # == Parameters
// 34:   #
// 35:   # String objects accept all the params that BinData::BasePrimitive
// 36:   # does, as well as the following:
// 37:   #
// 38:   # <tt>:read_length</tt>::    The length in bytes to use when reading a value.
// 39:   # <tt>:length</tt>::         The fixed length of the string.  If a shorter
// 40:   #                            string is set, it will be padded to this length.
// 41:   # <tt>:pad_byte</tt>::       The byte to use when padding a string to a
// 42:   #                            set length.  Valid values are Integers and
// 43:   #                            Strings of length 1.  "\0" is the default.
// 44:   # <tt>:pad_front</tt>::      Signifies that the padding occurs at the front
// 45:   #                            of the string rather than the end.  Default
// 46:   #                            is false.
// 47:   # <tt>:trim_padding</tt>::   Boolean, default false.  If set, #value will
// 48:   #                            return the value with all pad_bytes trimmed
// 49:   #                            from the end of the string.  The value will
// 50:   #                            not be trimmed when writing.
// 51:   class String < BinData::BasePrimitive
// 52:     arg_processor :string
// 53:
// 54:     optional_parameters :read_length, :length, :trim_padding, :pad_front, :pad_left
// 55:     default_parameters  pad_byte: "\0"
// 56:     mutually_exclusive_parameters :read_length, :length
// 57:     mutually_exclusive_parameters :length, :value
// 58:
// 59:     def initialize_shared_instance
// 60:       if (has_parameter?(:value) || has_parameter?(:asserted_value)) &&
// 61:           !has_parameter?(:read_length)
// 62:         extend WarnNoReadLengthPlugin
// 63:       end
// 64:       super
// 65:     end
// 66:
// 67:     def assign(val)
// 68:       super(binary_string(val))
// 69:     end
// 70:
// 71:     def snapshot
// 72:       # override to trim padding
// 73:       snap = super
// 74:       snap = clamp_to_length(snap)
// 75:
// 76:       if get_parameter(:trim_padding)
// 77:         trim_padding(snap)
// 78:       else
// 79:         snap
// 80:       end
// 81:     end
// 82:
// 83:     #---------------
// 84:     private
// 85:
// 86:     def clamp_to_length(str)
// 87:       str = binary_string(str)
// 88:
// 89:       len = eval_parameter(:length) || str.length
// 90:       if str.length == len
// 91:         str
// 92:       elsif str.length > len
// 93:         str.slice(0, len)
// 94:       else
// 95:         padding = (eval_parameter(:pad_byte) * (len - str.length))
// 96:         if get_parameter(:pad_front)
// 97:           padding + str
// 98:         else
// 99:           str + padding
// 100:         end
// 101:       end
// 102:     end
// 103:
// 104:     def trim_padding(str)
// 105:       if get_parameter(:pad_front)
// 106:         str.sub(/\A#{eval_parameter(:pad_byte)}*/, "")
// 107:       else
// 108:         str.sub(/#{eval_parameter(:pad_byte)}*\z/, "")
// 109:       end
// 110:     end
// 111:
// 112:     def value_to_binary_string(val)
// 113:       clamp_to_length(val)
// 114:     end
// 115:
// 116:     def read_and_return_value(io)
// 117:       len = eval_parameter(:read_length) || eval_parameter(:length) || 0
// 118:       io.readbytes(len)
// 119:     end
// 120:
// 121:     def sensible_default
// 122:       ""
// 123:     end
// 124:
// 125:     # Warns when reading if :value && no :read_length
// 126:     module WarnNoReadLengthPlugin
// 127:       def read_and_return_value(io)
// 128:         Kernel.warn "#{debug_name} does not have a :read_length parameter - returning empty string"
// 129:         ""
// 130:       end
// 131:     end
// 132:   end
// 133:
// 134:   class StringArgProcessor < BaseArgProcessor
// 135:     def sanitize_parameters!(obj_class, params)
// 136:       params.warn_replacement_parameter(:initial_length, :read_length)
// 137:       params.must_be_integer(:read_length, :length)
// 138:       params.rename_parameter(:pad_left, :pad_front)
// 139:       params.sanitize(:pad_byte) { |byte| sanitized_pad_byte(byte) }
// 140:     end
// 141:
// 142:     #-------------
// 143:     private
// 144:
// 145:     def sanitized_pad_byte(byte)
// 146:       pad_byte = byte.is_a?(Integer) ? byte.chr : byte.to_s
// 147:       if pad_byte.bytesize > 1
// 148:         raise ArgumentError, ":pad_byte must not contain more than 1 byte"
// 149:       end
// 150:       pad_byte
// 151:     end
// 152:   end
// 153: end
