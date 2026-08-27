module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/int.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `define_class(name, nbits, endian, signed)` at line 12.
pub fn ruby_int_l12_d1_define_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_class', ...args)
}

// Ruby define_method `Int.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)` at line 16.
pub fn ruby_int_l16_d2_s_new_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(new_class', ...args)
}

// Ruby method `define_methods(int_class, nbits, endian, signed)` at line 26.
pub fn ruby_int_l26_d3_define_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('define_methods', ...args)
}

// Ruby method `assign(val)` at line 30.
pub fn ruby_int_l30_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `do_num_bytes` at line 35.
pub fn ruby_int_l35_d5_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Ruby method `sensible_default` at line 42.
pub fn ruby_int_l42_d6_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `value_to_binary_string(val)` at line 46.
pub fn ruby_int_l46_d7_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value_to_binary_string', ...args)
}

// Ruby method `read_and_return_value(io)` at line 51.
pub fn ruby_int_l51_d8_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `create_clamp_code(nbits, signed)` at line 60.
pub fn ruby_int_l60_d9_create_clamp_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_clamp_code', ...args)
}

// Ruby method `create_read_code(nbits, endian, signed)` at line 72.
pub fn ruby_int_l72_d10_create_read_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_read_code', ...args)
}

// Ruby method `create_raw_read_code(nbits, endian, signed)` at line 82.
pub fn ruby_int_l82_d11_create_raw_read_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_raw_read_code', ...args)
}

// Ruby method `create_read_unpack_code(nbits, endian, signed)` at line 94.
pub fn ruby_int_l94_d12_create_read_unpack_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_read_unpack_code', ...args)
}

// Ruby method `create_read_assemble_code(nbits, endian)` at line 101.
pub fn ruby_int_l101_d13_create_read_assemble_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_read_assemble_code', ...args)
}

// Ruby method `create_to_binary_s_code(nbits, endian, signed)` at line 115.
pub fn ruby_int_l115_d14_create_to_binary_s_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_to_binary_s_code', ...args)
}

// Ruby method `val_as_packed_words(nbits, endian)` at line 130.
pub fn ruby_int_l130_d15_val_as_packed_words(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('val_as_packed_words', ...args)
}

// Ruby method `create_int2uint_code(nbits)` at line 142.
pub fn ruby_int_l142_d16_create_int2uint_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_int2uint_code', ...args)
}

// Ruby method `create_uint2int_code(nbits)` at line 146.
pub fn ruby_int_l146_d17_create_uint2int_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_uint2int_code', ...args)
}

// Ruby method `bits_per_word(nbits)` at line 150.
pub fn ruby_int_l150_d18_bits_per_word(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bits_per_word', ...args)
}

// Ruby method `pack_directive(nbits, endian, signed)` at line 157.
pub fn ruby_int_l157_d19_pack_directive(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pack_directive', ...args)
}

// Ruby method `need_signed_conversion_code?(nbits, signed)` at line 172.
pub fn ruby_int_l172_d20_need_signed_conversion_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('need_signed_conversion_code?', ...args)
}

// Ruby define_method `Int.define_methods(self, 8, :little, :unsigned)` at line 181.
pub fn ruby_int_l181_d21_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Ruby define_method `Int.define_methods(self, 8, :little, :signed)` at line 186.
pub fn ruby_int_l186_d22_s_self(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s(self', ...args)
}

// Ruby method `const_missing(name)` at line 191.
pub fn ruby_int_l191_d23_const_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('const_missing', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'bindata/base_primitive'
// 3:
// 4: module BinData
// 5:   # Defines a number of classes that contain an integer.  The integer
// 6:   # is defined by endian, signedness and number of bytes.
// 7:
// 8:   module Int # :nodoc: all
// 9:     @@mutex = Mutex.new
// 10:
// 11:     class << self
// 12:       def define_class(name, nbits, endian, signed)
// 13:         @@mutex.synchronize do
// 14:           unless BinData.const_defined?(name)
// 15:             new_class = Class.new(BinData::BasePrimitive)
// 16:             Int.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)
// 17:             RegisteredClasses.register(name, new_class)
// 18:
// 19:             BinData.const_set(name, new_class)
// 20:           end
// 21:         end
// 22:
// 23:         BinData.const_get(name)
// 24:       end
// 25:
// 26:       def define_methods(int_class, nbits, endian, signed)
// 27:         raise "nbits must be divisible by 8" unless (nbits % 8).zero?
// 28:
// 29:         int_class.module_eval <<-END
// 30:           def assign(val)
// 31:             #{create_clamp_code(nbits, signed)}
// 32:             super(val)
// 33:           end
// 34:
// 35:           def do_num_bytes
// 36:             #{nbits / 8}
// 37:           end
// 38:
// 39:           #---------------
// 40:           private
// 41:
// 42:           def sensible_default
// 43:             0
// 44:           end
// 45:
// 46:           def value_to_binary_string(val)
// 47:             #{create_clamp_code(nbits, signed)}
// 48:             #{create_to_binary_s_code(nbits, endian, signed)}
// 49:           end
// 50:
// 51:           def read_and_return_value(io)
// 52:             #{create_read_code(nbits, endian, signed)}
// 53:           end
// 54:         END
// 55:       end
// 56:
// 57:       #-------------
// 58:       private
// 59:
// 60:       def create_clamp_code(nbits, signed)
// 61:         if signed == :signed
// 62:           max = "(1 << (#{nbits} - 1)) - 1"
// 63:           min = "-((#{max}) + 1)"
// 64:         else
// 65:           max = "(1 << #{nbits}) - 1"
// 66:           min = "0"
// 67:         end
// 68:
// 69:         "val = val.clamp(#{min}, #{max})"
// 70:       end
// 71:
// 72:       def create_read_code(nbits, endian, signed)
// 73:         read_str = create_raw_read_code(nbits, endian, signed)
// 74:
// 75:         if need_signed_conversion_code?(nbits, signed)
// 76:           "val = #{read_str} ; #{create_uint2int_code(nbits)}"
// 77:         else
// 78:           read_str
// 79:         end
// 80:       end
// 81:
// 82:       def create_raw_read_code(nbits, endian, signed)
// 83:         # special case 8bit integers for speed
// 84:         if nbits == 8
// 85:           "io.readbytes(1).ord"
// 86:         else
// 87:           unpack_str   = create_read_unpack_code(nbits, endian, signed)
// 88:           assemble_str = create_read_assemble_code(nbits, endian)
// 89:
// 90:           "(#{unpack_str} ; #{assemble_str})"
// 91:         end
// 92:       end
// 93:
// 94:       def create_read_unpack_code(nbits, endian, signed)
// 95:         nbytes         = nbits / 8
// 96:         pack_directive = pack_directive(nbits, endian, signed)
// 97:
// 98:         "ints = io.readbytes(#{nbytes}).unpack('#{pack_directive}')"
// 99:       end
// 100:
// 101:       def create_read_assemble_code(nbits, endian)
// 102:         nwords = nbits / bits_per_word(nbits)
// 103:
// 104:         idx = (0...nwords).to_a
// 105:         idx.reverse! if endian == :big
// 106:
// 107:         parts = (0...nwords).collect do |i|
// 108:                   "(ints.at(#{idx[i]}) << #{bits_per_word(nbits) * i})"
// 109:                 end
// 110:         parts[0] = parts[0].sub(/ << 0\b/, "")  # Remove " << 0" for optimisation
// 111:
// 112:         parts.join(" + ")
// 113:       end
// 114:
// 115:       def create_to_binary_s_code(nbits, endian, signed)
// 116:         # special case 8bit integers for speed
// 117:         return "(val & 0xff).chr" if nbits == 8
// 118:
// 119:         pack_directive = pack_directive(nbits, endian, signed)
// 120:         words          = val_as_packed_words(nbits, endian)
// 121:         pack_str       = "[#{words}].pack('#{pack_directive}')"
// 122:
// 123:         if need_signed_conversion_code?(nbits, signed)
// 124:           "#{create_int2uint_code(nbits)} ; #{pack_str}"
// 125:         else
// 126:           pack_str
// 127:         end
// 128:       end
// 129:
// 130:       def val_as_packed_words(nbits, endian)
// 131:         nwords = nbits / bits_per_word(nbits)
// 132:         mask   = (1 << bits_per_word(nbits)) - 1
// 133:
// 134:         vals = (0...nwords).collect { |i| "val >> #{bits_per_word(nbits) * i}" }
// 135:         vals[0] = vals[0].sub(/ >> 0\b/, "")  # Remove " >> 0" for optimisation
// 136:         vals.reverse! if (endian == :big)
// 137:
// 138:         vals = vals.collect { |val| "#{val} & #{mask}" }  # TODO: "& mask" is needed to work around jruby bug. Remove this line when fixed.
// 139:         vals.join(',')
// 140:       end
// 141:
// 142:       def create_int2uint_code(nbits)
// 143:         "val &= #{(1 << nbits) - 1}"
// 144:       end
// 145:
// 146:       def create_uint2int_code(nbits)
// 147:         "(val >= #{1 << (nbits - 1)}) ? val - #{1 << nbits} : val"
// 148:       end
// 149:
// 150:       def bits_per_word(nbits)
// 151:         (nbits % 64).zero? ? 64 :
// 152:         (nbits % 32).zero? ? 32 :
// 153:         (nbits % 16).zero? ? 16 :
// 154:                               8
// 155:       end
// 156:
// 157:       def pack_directive(nbits, endian, signed)
// 158:         nwords = nbits / bits_per_word(nbits)
// 159:
// 160:         directives = { 8 => 'C', 16 => 'S', 32 => 'L', 64 => 'Q' }
// 161:
// 162:         d = directives[bits_per_word(nbits)]
// 163:         d += ((endian == :big) ? '>' : '<') unless d == 'C'
// 164:
// 165:         if signed == :signed && directives.key?(nbits)
// 166:           (d * nwords).downcase
// 167:         else
// 168:           d * nwords
// 169:         end
// 170:       end
// 171:
// 172:       def need_signed_conversion_code?(nbits, signed)
// 173:         signed == :signed && ![64, 32, 16].include?(nbits)
// 174:       end
// 175:     end
// 176:   end
// 177:
// 178:
// 179:   # Unsigned 1 byte integer.
// 180:   class Uint8 < BinData::BasePrimitive
// 181:     Int.define_methods(self, 8, :little, :unsigned)
// 182:   end
// 183:
// 184:   # Signed 1 byte integer.
// 185:   class Int8 < BinData::BasePrimitive
// 186:     Int.define_methods(self, 8, :little, :signed)
// 187:   end
// 188:
// 189:   # Create classes on demand
// 190:   module IntFactory
// 191:     def const_missing(name)
// 192:       mappings = {
// 193:         /^Uint(\d+)be$/ => [:big,    :unsigned],
// 194:         /^Uint(\d+)le$/ => [:little, :unsigned],
// 195:         /^Int(\d+)be$/  => [:big,    :signed],
// 196:         /^Int(\d+)le$/  => [:little, :signed]
// 197:       }
// 198:
// 199:       mappings.each_pair do |regex, args|
// 200:         if regex =~ name.to_s
// 201:           nbits = $1.to_i
// 202:           if nbits > 0 && (nbits % 8).zero?
// 203:             return Int.define_class(name, nbits, *args)
// 204:           end
// 205:         end
// 206:       end
// 207:
// 208:       super
// 209:     end
// 210:   end
// 211:   BinData.extend IntFactory
// 212: end
