module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/float.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `define_methods(float_class, precision, endian)` at line 21.
pub fn ruby_float_l21_d1_define_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_methods', ...args)
}

// Ruby method `do_num_bytes` at line 23.
pub fn ruby_float_l23_d2_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `sensible_default` at line 30.
pub fn ruby_float_l30_d3_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `value_to_binary_string(val)` at line 34.
pub fn ruby_float_l34_d4_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value_to_binary_string', ...args)
}

// Ruby method `read_and_return_value(io)` at line 38.
pub fn ruby_float_l38_d5_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `create_num_bytes_code(precision)` at line 44.
pub fn ruby_float_l44_d6_create_num_bytes_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_num_bytes_code', ...args)
}

// Ruby method `create_read_code(precision, endian)` at line 48.
pub fn ruby_float_l48_d7_create_read_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_read_code', ...args)
}

// Ruby method `create_to_binary_s_code(precision, endian)` at line 55.
pub fn ruby_float_l55_d8_create_to_binary_s_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_to_binary_s_code', ...args)
}

// Ruby define_method `FloatingPoint.define_methods(self, :single, :little)` at line 66.
pub fn ruby_float_l66_d9_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Ruby define_method `FloatingPoint.define_methods(self, :single, :big)` at line 71.
pub fn ruby_float_l71_d10_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Ruby define_method `FloatingPoint.define_methods(self, :double, :little)` at line 76.
pub fn ruby_float_l76_d11_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Ruby define_method `FloatingPoint.define_methods(self, :double, :big)` at line 81.
pub fn ruby_float_l81_d12_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # Defines a number of classes that contain a floating point number.
// 5:   # The float is defined by precision and endian.
// 6:
// 7:   module FloatingPoint # :nodoc: all
// 8:     class << self
// 9:       PRECISION = {
// 10:         single: 4,
// 11:         double: 8,
// 12:       }
// 13:
// 14:       PACK_CODE = {
// 15:         [:single, :little] => 'e',
// 16:         [:single, :big]    => 'g',
// 17:         [:double, :little] => 'E',
// 18:         [:double, :big]    => 'G'
// 19:       }
// 20:
// 21:       def define_methods(float_class, precision, endian)
// 22:         float_class.module_eval <<-END
// 23:           def do_num_bytes
// 24:             #{create_num_bytes_code(precision)}
// 25:           end
// 26:
// 27:           #---------------
// 28:           private
// 29:
// 30:           def sensible_default
// 31:             0.0
// 32:           end
// 33:
// 34:           def value_to_binary_string(val)
// 35:             #{create_to_binary_s_code(precision, endian)}
// 36:           end
// 37:
// 38:           def read_and_return_value(io)
// 39:             #{create_read_code(precision, endian)}
// 40:           end
// 41:         END
// 42:       end
// 43:
// 44:       def create_num_bytes_code(precision)
// 45:         PRECISION[precision]
// 46:       end
// 47:
// 48:       def create_read_code(precision, endian)
// 49:         nbytes = PRECISION[precision]
// 50:         unpack = PACK_CODE[[precision, endian]]
// 51:
// 52:         "io.readbytes(#{nbytes}).unpack1('#{unpack}')"
// 53:       end
// 54:
// 55:       def create_to_binary_s_code(precision, endian)
// 56:         pack = PACK_CODE[[precision, endian]]
// 57:
// 58:         "[val].pack('#{pack}')"
// 59:       end
// 60:     end
// 61:   end
// 62:
// 63:
// 64:   # Single precision floating point number in little endian format
// 65:   class FloatLe < BinData::BasePrimitive
// 66:     FloatingPoint.define_methods(self, :single, :little)
// 67:   end
// 68:
// 69:   # Single precision floating point number in big endian format
// 70:   class FloatBe < BinData::BasePrimitive
// 71:     FloatingPoint.define_methods(self, :single, :big)
// 72:   end
// 73:
// 74:   # Double precision floating point number in little endian format
// 75:   class DoubleLe < BinData::BasePrimitive
// 76:     FloatingPoint.define_methods(self, :double, :little)
// 77:   end
// 78:
// 79:   # Double precision floating point number in big endian format
// 80:   class DoubleBe < BinData::BasePrimitive
// 81:     FloatingPoint.define_methods(self, :double, :big)
// 82:   end
// 83: end
