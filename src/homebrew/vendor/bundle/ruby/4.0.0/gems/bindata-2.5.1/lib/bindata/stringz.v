module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/stringz.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `assign(val)` at line 30.
pub fn ruby_stringz_l30_d1_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 34.
pub fn ruby_stringz_l34_d2_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `value_to_binary_string(val)` at line 43.
pub fn ruby_stringz_l43_d3_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value_to_binary_string', ...args)
}

// Ruby method `read_and_return_value(io)` at line 47.
pub fn ruby_stringz_l47_d4_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `sensible_default` at line 63.
pub fn ruby_stringz_l63_d5_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `trim_and_zero_terminate(str)` at line 67.
pub fn ruby_stringz_l67_d6_trim_and_zero_terminate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trim_and_zero_terminate', ...args)
}

// Ruby method `truncate_after_first_zero_byte!(str)` at line 81.
pub fn ruby_stringz_l81_d7_truncate_after_first_zero_byte(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('truncate_after_first_zero_byte!', ...args)
}

// Ruby method `trim_to!(str, max_length = nil)` at line 85.
pub fn ruby_stringz_l85_d8_trim_to(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trim_to!', ...args)
}

// Ruby method `append_zero_byte_if_needed!(str)` at line 92.
pub fn ruby_stringz_l92_d9_append_zero_byte_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('append_zero_byte_if_needed!', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # A BinData::Stringz object is a container for a zero ("\0") terminated
// 5:   # string.
// 6:   #
// 7:   # For convenience, the zero terminator is not necessary when setting the
// 8:   # value.  Likewise, the returned value will not be zero terminated.
// 9:   #
// 10:   #   require 'bindata'
// 11:   #
// 12:   #   data = "abcd\x00efgh"
// 13:   #
// 14:   #   obj = BinData::Stringz.new
// 15:   #   obj.read(data)
// 16:   #   obj.snapshot #=> "abcd"
// 17:   #   obj.num_bytes #=> 5
// 18:   #   obj.to_binary_s #=> "abcd\000"
// 19:   #
// 20:   # == Parameters
// 21:   #
// 22:   # Stringz objects accept all the params that BinData::BasePrimitive
// 23:   # does, as well as the following:
// 24:   #
// 25:   # <tt>:max_length</tt>:: The maximum length of the string including the zero
// 26:   #                        byte.
// 27:   class Stringz < BinData::BasePrimitive
// 28:     optional_parameters :max_length
// 29:
// 30:     def assign(val)
// 31:       super(binary_string(val))
// 32:     end
// 33:
// 34:     def snapshot
// 35:       # override to always remove trailing zero bytes
// 36:       result = super
// 37:       trim_and_zero_terminate(result).chomp("\0")
// 38:     end
// 39:
// 40:     #---------------
// 41:     private
// 42:
// 43:     def value_to_binary_string(val)
// 44:       trim_and_zero_terminate(val)
// 45:     end
// 46:
// 47:     def read_and_return_value(io)
// 48:       max_length = eval_parameter(:max_length)
// 49:       str = binary_string("")
// 50:       i = 0
// 51:       ch = nil
// 52:
// 53:       # read until zero byte or we have read in the max number of bytes
// 54:       while ch != "\0" && i != max_length
// 55:         ch = io.readbytes(1)
// 56:         str << ch
// 57:         i += 1
// 58:       end
// 59:
// 60:       trim_and_zero_terminate(str)
// 61:     end
// 62:
// 63:     def sensible_default
// 64:       ""
// 65:     end
// 66:
// 67:     def trim_and_zero_terminate(str)
// 68:       max_length = eval_parameter(:max_length)
// 69:       if max_length && max_length < 1
// 70:         msg = "max_length must be >= 1 in #{debug_name} (got #{max_length})"
// 71:         raise ArgumentError, msg
// 72:       end
// 73:
// 74:       result = binary_string(str)
// 75:       truncate_after_first_zero_byte!(result)
// 76:       trim_to!(result, max_length)
// 77:       append_zero_byte_if_needed!(result)
// 78:       result
// 79:     end
// 80:
// 81:     def truncate_after_first_zero_byte!(str)
// 82:       str.sub!(/([^\0]*\0).*/, '\1')
// 83:     end
// 84:
// 85:     def trim_to!(str, max_length = nil)
// 86:       if max_length
// 87:         str.slice!(max_length..-1)
// 88:         str[-1, 1] = "\0" if str.length == max_length
// 89:       end
// 90:     end
// 91:
// 92:     def append_zero_byte_if_needed!(str)
// 93:       if str.empty? || str[-1, 1] != "\0"
// 94:         str << "\0"
// 95:       end
// 96:     end
// 97:   end
// 98: end
