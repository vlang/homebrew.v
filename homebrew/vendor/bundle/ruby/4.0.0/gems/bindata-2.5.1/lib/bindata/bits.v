module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/bits.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `define_class(name, nbits, endian, signed = :unsigned)` at line 12.
pub fn ruby_bits_l12_d1_define_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_class', ...args)
}

// Ruby define_method `BitField.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)` at line 16.
pub fn ruby_bits_l16_d2_s_new_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(new_class', ...args)
}

// Ruby method `define_methods(bit_class, nbits, endian, signed)` at line 26.
pub fn ruby_bits_l26_d3_define_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_methods', ...args)
}

// Ruby method `assign(val)` at line 30.
pub fn ruby_bits_l30_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `do_write(io)` at line 36.
pub fn ruby_bits_l36_d5_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes` at line 43.
pub fn ruby_bits_l43_d6_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `bit_aligned?` at line 48.
pub fn ruby_bits_l48_d7_bit_aligned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bit_aligned?', ...args)
}

// Ruby method `read_and_return_value(io)` at line 55.
pub fn ruby_bits_l55_d8_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `sensible_default` at line 62.
pub fn ruby_bits_l62_d9_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `create_params_code(nbits)` at line 68.
pub fn ruby_bits_l68_d10_create_params_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_params_code', ...args)
}

// Ruby method `create_nbits_code(nbits)` at line 76.
pub fn ruby_bits_l76_d11_create_nbits_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_nbits_code', ...args)
}

// Ruby method `create_do_num_bytes_code(nbits)` at line 84.
pub fn ruby_bits_l84_d12_create_do_num_bytes_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_do_num_bytes_code', ...args)
}

// Ruby method `create_clamp_code(nbits, signed)` at line 92.
pub fn ruby_bits_l92_d13_create_clamp_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_clamp_code', ...args)
}

// Ruby method `create_dynamic_clamp_code(signed)` at line 100.
pub fn ruby_bits_l100_d14_create_dynamic_clamp_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_dynamic_clamp_code', ...args)
}

// Ruby method `create_fixed_clamp_code(nbits, signed)` at line 112.
pub fn ruby_bits_l112_d15_create_fixed_clamp_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_fixed_clamp_code', ...args)
}

// Ruby method `create_int2uint_code(nbits, signed)` at line 135.
pub fn ruby_bits_l135_d16_create_int2uint_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_int2uint_code', ...args)
}

// Ruby method `create_uint2int_code(nbits, signed)` at line 145.
pub fn ruby_bits_l145_d17_create_uint2int_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_uint2int_code', ...args)
}

// Ruby method `const_missing(name)` at line 167.
pub fn ruby_bits_l167_d18_const_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('const_missing', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'bindata/base_primitive'
// 3:
// 4: module BinData
// 5:   # Defines a number of classes that contain a bit based integer.
// 6:   # The integer is defined by endian and number of bits.
// 7:
// 8:   module BitField # :nodoc: all
// 9:     @@mutex = Mutex.new
// 10:
// 11:     class << self
// 12:       def define_class(name, nbits, endian, signed = :unsigned)
// 13:         @@mutex.synchronize do
// 14:           unless BinData.const_defined?(name)
// 15:             new_class = Class.new(BinData::BasePrimitive)
// 16:             BitField.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)
// 17:             RegisteredClasses.register(name, new_class)
// 18:
// 19:             BinData.const_set(name, new_class)
// 20:           end
// 21:         end
// 22:
// 23:         BinData.const_get(name)
// 24:       end
// 25:
// 26:       def define_methods(bit_class, nbits, endian, signed)
// 27:         bit_class.module_eval <<-END
// 28:           #{create_params_code(nbits)}
// 29:
// 30:           def assign(val)
// 31:             #{create_nbits_code(nbits)}
// 32:             #{create_clamp_code(nbits, signed)}
// 33:             super(val)
// 34:           end
// 35:
// 36:           def do_write(io)
// 37:             #{create_nbits_code(nbits)}
// 38:             val = _value
// 39:             #{create_int2uint_code(nbits, signed)}
// 40:             io.writebits(val, #{nbits}, :#{endian})
// 41:           end
// 42:
// 43:           def do_num_bytes
// 44:             #{create_nbits_code(nbits)}
// 45:             #{create_do_num_bytes_code(nbits)}
// 46:           end
// 47:
// 48:           def bit_aligned?
// 49:             true
// 50:           end
// 51:
// 52:           #---------------
// 53:           private
// 54:
// 55:           def read_and_return_value(io)
// 56:             #{create_nbits_code(nbits)}
// 57:             val = io.readbits(#{nbits}, :#{endian})
// 58:             #{create_uint2int_code(nbits, signed)}
// 59:             val
// 60:           end
// 61:
// 62:           def sensible_default
// 63:             0
// 64:           end
// 65:         END
// 66:       end
// 67:
// 68:       def create_params_code(nbits)
// 69:         if nbits == :nbits
// 70:           "mandatory_parameter :nbits"
// 71:         else
// 72:           ""
// 73:         end
// 74:       end
// 75:
// 76:       def create_nbits_code(nbits)
// 77:         if nbits == :nbits
// 78:           "nbits = eval_parameter(:nbits)"
// 79:         else
// 80:           ""
// 81:         end
// 82:       end
// 83:
// 84:       def create_do_num_bytes_code(nbits)
// 85:         if nbits == :nbits
// 86:           "nbits / 8.0"
// 87:         else
// 88:           nbits / 8.0
// 89:         end
// 90:       end
// 91:
// 92:       def create_clamp_code(nbits, signed)
// 93:         if nbits == :nbits
// 94:           create_dynamic_clamp_code(signed)
// 95:         else
// 96:           create_fixed_clamp_code(nbits, signed)
// 97:         end
// 98:       end
// 99:
// 100:       def create_dynamic_clamp_code(signed)
// 101:         if signed == :signed
// 102:           max = "(1 << (nbits - 1)) - 1"
// 103:           min = "-((#{max}) + 1)"
// 104:         else
// 105:           max = "(1 << nbits) - 1"
// 106:           min = "0"
// 107:         end
// 108:
// 109:         "val = val.clamp(#{min}, #{max})"
// 110:       end
// 111:
// 112:       def create_fixed_clamp_code(nbits, signed)
// 113:         if nbits == 1 && signed == :signed
// 114:           raise "signed bitfield must have more than one bit"
// 115:         end
// 116:
// 117:         if signed == :signed
// 118:           max = "(1 << (#{nbits} - 1)) - 1"
// 119:           min = "-((#{max}) + 1)"
// 120:         else
// 121:           min = "0"
// 122:           max = "(1 << #{nbits}) - 1"
// 123:         end
// 124:
// 125:         clamp = "(val = val.clamp(#{min}, #{max}))"
// 126:
// 127:         if nbits == 1
// 128:           # allow single bits to be used as booleans
// 129:           clamp = "(val == true) ? 1 : (not val) ? 0 : #{clamp}"
// 130:         end
// 131:
// 132:         "val = #{clamp}"
// 133:       end
// 134:
// 135:       def create_int2uint_code(nbits, signed)
// 136:         if signed != :signed
// 137:           ""
// 138:         elsif nbits == :nbits
// 139:           "val &= (1 << nbits) - 1"
// 140:         else
// 141:           "val &= #{(1 << nbits) - 1}"
// 142:         end
// 143:       end
// 144:
// 145:       def create_uint2int_code(nbits, signed)
// 146:         if signed != :signed
// 147:           ""
// 148:         elsif nbits == :nbits
// 149:           "val -= (1 << nbits) if (val >= (1 << (nbits - 1)))"
// 150:         else
// 151:           "val -= #{1 << nbits} if (val >= #{1 << (nbits - 1)})"
// 152:         end
// 153:       end
// 154:     end
// 155:   end
// 156:
// 157:   # Create classes for dynamic bitfields
// 158:   {
// 159:     'Bit'    => :big,
// 160:     'BitLe'  => :little,
// 161:     'Sbit'   => [:big, :signed],
// 162:     'SbitLe' => [:little, :signed]
// 163:   }.each_pair { |name, args| BitField.define_class(name, :nbits, *args) }
// 164:
// 165:   # Create classes on demand
// 166:   module BitFieldFactory
// 167:     def const_missing(name)
// 168:       mappings = {
// 169:         /^Bit(\d+)$/    => :big,
// 170:         /^Bit(\d+)le$/  => :little,
// 171:         /^Sbit(\d+)$/   => [:big, :signed],
// 172:         /^Sbit(\d+)le$/ => [:little, :signed]
// 173:       }
// 174:
// 175:       mappings.each_pair do |regex, args|
// 176:         if regex =~ name.to_s
// 177:           nbits = $1.to_i
// 178:           return BitField.define_class(name, nbits, *args)
// 179:         end
// 180:       end
// 181:
// 182:       super(name)
// 183:     end
// 184:   end
// 185:   BinData.extend BitFieldFactory
// 186: end
