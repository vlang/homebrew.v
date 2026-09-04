module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/bits.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BitFieldClass {
pub:
	name    string
	nbits   int
	dynamic bool
	endian  IntEndian
	signed  IntSignedness
}

pub fn define_bitfield_class(name string, nbits int, dynamic bool, endian IntEndian, signed IntSignedness) !BitFieldClass {
	if !dynamic && nbits == 1 && signed == .signed {
		return error('signed bitfield must have more than one bit')
	}
	return BitFieldClass{
		name: name
		nbits: nbits
		dynamic: dynamic
		endian: endian
		signed: signed
	}
}

pub fn bitfield_class_for_name(name string) !BitFieldClass {
	match name {
		'Bit' {
			return define_bitfield_class(name, 0, true, .big, .unsigned)
		}
		'BitLe' {
			return define_bitfield_class(name, 0, true, .little, .unsigned)
		}
		'Sbit' {
			return define_bitfield_class(name, 0, true, .big, .signed)
		}
		'SbitLe' {
			return define_bitfield_class(name, 0, true, .little, .signed)
		}
		else {}
	}
	mut prefix := ''
	mut signed := IntSignedness.unsigned
	if name.starts_with('Sbit') {
		prefix = 'Sbit'
		signed = .signed
	} else if name.starts_with('Bit') {
		prefix = 'Bit'
	} else {
		return error('unknown bitfield class `${name}`')
	}
	endian := if name.ends_with('le') { IntEndian.little } else { IntEndian.big }
	end := if endian == .little { name.len - 2 } else { name.len }
	digits := name[prefix.len..end]
	if digits.len == 0 || digits.bytes().any(it < `0` || it > `9`) {
		return error('unknown bitfield class `${name}`')
	}
	return define_bitfield_class(name, digits.int(), false, endian, signed)
}

pub fn bitfield_params_code(dynamic bool) string {
	return if dynamic { 'mandatory_parameter :nbits' } else { '' }
}

pub fn bitfield_nbits_code(dynamic bool) string {
	return if dynamic { 'nbits = eval_parameter(:nbits)' } else { '' }
}

pub fn bitfield_num_bytes(nbits int) f64 {
	return f64(nbits) / 8.0
}

pub fn bitfield_num_bytes_code(nbits int, dynamic bool) string {
	return if dynamic { 'nbits / 8.0' } else { bitfield_num_bytes(nbits).str() }
}

pub fn bitfield_dynamic_clamp_code(signed IntSignedness) string {
	if signed == .signed {
		max := '(1 << (nbits - 1)) - 1'
		return 'val = val.clamp(-((${max}) + 1), ${max})'
	}
	return 'val = val.clamp(0, (1 << nbits) - 1)'
}

pub fn bitfield_fixed_clamp_code(nbits int, signed IntSignedness) !string {
	if nbits == 1 && signed == .signed {
		return error('signed bitfield must have more than one bit')
	}
	mut clamp := ''
	if signed == .signed {
		max := '(1 << (${nbits} - 1)) - 1'
		clamp = '(val = val.clamp(-((${max}) + 1), ${max}))'
	} else {
		clamp = '(val = val.clamp(0, (1 << ${nbits}) - 1))'
	}
	if nbits == 1 {
		clamp = '(val == true) ? 1 : (not val) ? 0 : ${clamp}'
	}
	return 'val = ${clamp}'
}

pub fn bitfield_clamp_code(nbits int, dynamic bool, signed IntSignedness) !string {
	return if dynamic {
		bitfield_dynamic_clamp_code(signed)
	} else {
		bitfield_fixed_clamp_code(nbits, signed)!
	}
}

pub fn bitfield_int_to_uint_code(nbits int, dynamic bool, signed IntSignedness) string {
	if signed != .signed {
		return ''
	}
	return if dynamic {
		'val &= (1 << nbits) - 1'
	} else {
		'val &= ${decimal_decrement(power_of_two_decimal(nbits))}'
	}
}

pub fn bitfield_uint_to_int_code(nbits int, dynamic bool, signed IntSignedness) string {
	if signed != .signed {
		return ''
	}
	return if dynamic {
		'val -= (1 << nbits) if (val >= (1 << (nbits - 1)))'
	} else {
		'val -= ${power_of_two_decimal(nbits)} if (val >= ${power_of_two_decimal(nbits - 1)})'
	}
}

pub fn clamp_bitfield_integer(value i64, nbits int, signed IntSignedness) !i64 {
	if nbits <= 0 || nbits > 63 {
		return error('nbits must be between 1 and 63')
	}
	if nbits == 1 && signed == .signed {
		return error('signed bitfield must have more than one bit')
	}
	if signed == .signed {
		maximum := i64((u64(1) << u32(nbits - 1)) - 1)
		minimum := -maximum - 1
		return if value < minimum {
			minimum
		} else if value > maximum { maximum } else { value }
	}
	maximum := i64((u64(1) << u32(nbits)) - 1)
	return if value < 0 {
		0
	} else if value > maximum { maximum } else { value }
}

pub fn bitfield_integer_to_unsigned(value i64, nbits int, signed IntSignedness) !u64 {
	clamped := clamp_bitfield_integer(value, nbits, signed)!
	return if signed == .signed {
		u64(clamped) & ((u64(1) << u32(nbits)) - 1)
	} else {
		u64(clamped)
	}
}

pub fn bitfield_unsigned_to_integer(value u64, nbits int, signed IntSignedness) !i64 {
	if nbits <= 0 || nbits > 63 {
		return error('nbits must be between 1 and 63')
	}
	masked := value & ((u64(1) << u32(nbits)) - 1)
	if signed == .signed && masked >= (u64(1) << u32(nbits - 1)) {
		return i64(masked) - i64(u64(1) << u32(nbits))
	}
	return i64(masked)
}

fn bitfield_value(spec BitFieldClass) ruby.Value {
	return ruby.structured_value('BinData::BitFieldClass', spec.name, {
		'name':    spec.name
		'nbits':   spec.nbits.str()
		'dynamic': spec.dynamic.str()
		'endian':  spec.endian.str()
		'signed':  spec.signed.str()
	})
}

fn bitfield_from_value(value ruby.Value) BitFieldClass {
	if value.type_name == 'BinData::BitFieldClass' {
		return define_bitfield_class(value.attribute('name') or { '' }, (value.attribute('nbits') or {
			'0'
		}).int(), (value.attribute('dynamic') or { 'false' }).bool(), if (value.attribute('endian') or {
			'big'}) == 'little' {
			.little
		} else {
			.big
		}, if (value.attribute('signed') or { 'unsigned' }) == 'signed' {
			.signed
		} else {
			.unsigned
		}) or { panic(err) }
	}
	return bitfield_class_for_name(value.as_string()) or { panic(err) }
}

fn bitfield_dynamic_arg(value ruby.Value) bool {
	return value.type_name != 'Integer' && value.as_string().trim_left(':') == 'nbits'
}

fn bitfield_effective_nbits(spec BitFieldClass, args []ruby.Value, index int) int {
	if !spec.dynamic {
		return spec.nbits
	}
	if index >= args.len {
		panic('dynamic bitfield requires nbits')
	}
	return int(args[index].as_int() or { panic(err) })
}

// Ruby method `define_class(name, nbits, endian, signed = :unsigned)` at line 12.
pub fn ruby_bits_l12_d1_define_class(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('BitField.define_class requires name, nbits and endian')
	}
	dynamic := bitfield_dynamic_arg(args[1])
	nbits := if dynamic { 0 } else { int(args[1].as_int() or { panic(err) }) }
	signed := if args.len > 3 { int_signedness_from_value(args[3]) } else { .unsigned }
	return bitfield_value(define_bitfield_class(args[0].as_string(), nbits, dynamic, int_endian_from_value(args[2]), signed) or { panic(err) })
}

// Ruby define_method `BitField.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)` at line 16.
pub fn ruby_bits_l16_d2_s_new_class(args ...ruby.Value) ruby.Value {
	return ruby_bits_l26_d3_define_methods(...args)
}

// Ruby method `define_methods(bit_class, nbits, endian, signed)` at line 26.
pub fn ruby_bits_l26_d3_define_methods(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('BitField.define_methods requires a class, nbits, endian and signedness')
	}
	dynamic := bitfield_dynamic_arg(args[1])
	nbits := if dynamic { 0 } else { int(args[1].as_int() or { panic(err) }) }
	return bitfield_value(define_bitfield_class(args[0].as_string(), nbits, dynamic, int_endian_from_value(args[2]), int_signedness_from_value(args[3])) or { panic(err) })
}

// Ruby method `assign(val)` at line 30.
pub fn ruby_bits_l30_d4_assign(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('bitfield assign requires a receiver and value')
	}
	spec := bitfield_from_value(args[0])
	nbits := bitfield_effective_nbits(spec, args, 2)
	if nbits == 1 && args[1].type_name == 'Bool' {
		return ruby.int_value(if args[1].as_bool() or { panic(err) } { 1 } else { 0 })
	}
	return ruby.int_value(clamp_bitfield_integer(args[1].as_int() or { panic(err) }, nbits, spec.signed) or { panic(err) })
}

// Ruby method `do_write(io)` at line 36.
pub fn ruby_bits_l36_d5_do_write(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('bitfield do_write requires a receiver and value')
	}
	spec := bitfield_from_value(args[0])
	nbits := bitfield_effective_nbits(spec, args, 2)
	value := bitfield_integer_to_unsigned(args[1].as_int() or { panic(err) }, nbits, spec.signed) or { panic(err) }
	return ruby.structured_value('BinData::BitWrite', value.str(), {
		'value':  value.str()
		'nbits':  nbits.str()
		'endian': spec.endian.str()
	})
}

// Ruby method `do_num_bytes` at line 43.
pub fn ruby_bits_l43_d6_do_num_bytes(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('bitfield do_num_bytes requires a receiver')
	}
	spec := bitfield_from_value(args[0])
	return ruby.float_value(bitfield_num_bytes(bitfield_effective_nbits(spec, args, 1)))
}

// Ruby method `bit_aligned?` at line 48.
pub fn ruby_bits_l48_d7_bit_aligned(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(true)
}

// Ruby method `read_and_return_value(io)` at line 55.
pub fn ruby_bits_l55_d8_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('bitfield read_and_return_value requires a receiver and unsigned value')
	}
	spec := bitfield_from_value(args[0])
	nbits := bitfield_effective_nbits(spec, args, 2)
	raw := u64(args[1].as_int() or { panic(err) })
	return ruby.int_value(bitfield_unsigned_to_integer(raw, nbits, spec.signed) or {
		panic(err)
	})
}

// Ruby method `sensible_default` at line 62.
pub fn ruby_bits_l62_d9_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.int_value(0)
}

// Ruby method `create_params_code(nbits)` at line 68.
pub fn ruby_bits_l68_d10_create_params_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_params_code requires nbits')
	}
	return ruby.string_value(bitfield_params_code(bitfield_dynamic_arg(args[0])))
}

// Ruby method `create_nbits_code(nbits)` at line 76.
pub fn ruby_bits_l76_d11_create_nbits_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_nbits_code requires nbits')
	}
	return ruby.string_value(bitfield_nbits_code(bitfield_dynamic_arg(args[0])))
}

// Ruby method `create_do_num_bytes_code(nbits)` at line 84.
pub fn ruby_bits_l84_d12_create_do_num_bytes_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_do_num_bytes_code requires nbits')
	}
	dynamic := bitfield_dynamic_arg(args[0])
	if dynamic {
		return ruby.string_value(bitfield_num_bytes_code(0, true))
	}
	return ruby.float_value(bitfield_num_bytes(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `create_clamp_code(nbits, signed)` at line 92.
pub fn ruby_bits_l92_d13_create_clamp_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_clamp_code requires nbits and signedness')
	}
	dynamic := bitfield_dynamic_arg(args[0])
	return ruby.string_value(bitfield_clamp_code(if dynamic {
		0
	} else {
		int(args[0].as_int() or {
			panic(err)
		})
	}, dynamic, int_signedness_from_value(args[1])) or { panic(err) })
}

// Ruby method `create_dynamic_clamp_code(signed)` at line 100.
pub fn ruby_bits_l100_d14_create_dynamic_clamp_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_dynamic_clamp_code requires signedness')
	}
	return ruby.string_value(bitfield_dynamic_clamp_code(int_signedness_from_value(args[0])))
}

// Ruby method `create_fixed_clamp_code(nbits, signed)` at line 112.
pub fn ruby_bits_l112_d15_create_fixed_clamp_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_fixed_clamp_code requires nbits and signedness')
	}
	return ruby.string_value(bitfield_fixed_clamp_code(int(args[0].as_int() or { panic(err) }), int_signedness_from_value(args[1])) or { panic(err) })
}

// Ruby method `create_int2uint_code(nbits, signed)` at line 135.
pub fn ruby_bits_l135_d16_create_int2uint_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_int2uint_code requires nbits and signedness')
	}
	dynamic := bitfield_dynamic_arg(args[0])
	return ruby.string_value(bitfield_int_to_uint_code(if dynamic {
		0
	} else {
		int(args[0].as_int() or {
			panic(err)
		})
	}, dynamic, int_signedness_from_value(args[1])))
}

// Ruby method `create_uint2int_code(nbits, signed)` at line 145.
pub fn ruby_bits_l145_d17_create_uint2int_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_uint2int_code requires nbits and signedness')
	}
	dynamic := bitfield_dynamic_arg(args[0])
	return ruby.string_value(bitfield_uint_to_int_code(if dynamic {
		0
	} else {
		int(args[0].as_int() or {
			panic(err)
		})
	}, dynamic, int_signedness_from_value(args[1])))
}

// Ruby method `const_missing(name)` at line 167.
pub fn ruby_bits_l167_d18_const_missing(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('const_missing requires a class name')
	}
	return bitfield_value(bitfield_class_for_name(args[0].as_string()) or { panic(err) })
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
