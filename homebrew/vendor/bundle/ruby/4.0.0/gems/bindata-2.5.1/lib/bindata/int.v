module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/int.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum IntEndian {
	little
	big
}

pub enum IntSignedness {
	unsigned
	signed
}

pub struct IntegerClass {
pub:
	name   string
	nbits  int
	endian IntEndian
	signed IntSignedness
}

pub fn define_integer_class(name string, nbits int, endian IntEndian, signed IntSignedness) !IntegerClass {
	if nbits % 8 != 0 {
		return error('nbits must be divisible by 8')
	}
	return IntegerClass{
		name: name
		nbits: nbits
		endian: endian
		signed: signed
	}
}

pub fn integer_class_for_name(name string) !IntegerClass {
	mut prefix := ''
	mut signed := IntSignedness.unsigned
	if name.starts_with('Uint') {
		prefix = 'Uint'
	} else if name.starts_with('Int') {
		prefix = 'Int'
		signed = .signed
	} else {
		return error('unknown integer class `${name}`')
	}
	endian := if name.ends_with('be') {
		IntEndian.big
	} else if name.ends_with('le') {
		IntEndian.little
	} else {
		return error('unknown integer class `${name}`')
	}
	digits := name[prefix.len..name.len - 2]
	if digits.len == 0 || digits.bytes().any(it < `0` || it > `9`) {
		return error('unknown integer class `${name}`')
	}
	if digits.int() <= 0 {
		return error('unknown integer class `${name}`')
	}
	return define_integer_class(name, digits.int(), endian, signed)
}

fn decimal_double(value string) string {
	mut carry := 0
	mut reversed := []u8{}
	for index := value.len - 1; index >= 0; index-- {
		digit := int(value[index] - `0`) * 2 + carry
		reversed << u8(digit % 10) + `0`
		carry = digit / 10
	}
	if carry > 0 {
		reversed << u8(carry) + `0`
	}
	mut result := []u8{cap: reversed.len}
	for index := reversed.len - 1; index >= 0; index-- {
		result << reversed[index]
	}
	return result.bytestr()
}

fn decimal_decrement(value string) string {
	mut digits := value.bytes()
	mut index := digits.len - 1
	for index >= 0 {
		if digits[index] > `0` {
			digits[index]--
			break
		}
		digits[index] = `9`
		index--
	}
	result := digits.bytestr().trim_left('0')
	return if result.len == 0 { '0' } else { result }
}

fn power_of_two_decimal(nbits int) string {
	mut value := '1'
	for _ in 0 .. nbits {
		value = decimal_double(value)
	}
	return value
}

pub fn integer_clamp_code(nbits int, signed IntSignedness) string {
	if signed == .signed {
		max := '(1 << (${nbits} - 1)) - 1'
		min := '-((${max}) + 1)'
		return 'val = val.clamp(${min}, ${max})'
	}
	return 'val = val.clamp(0, (1 << ${nbits}) - 1)'
}

pub fn integer_bits_per_word(nbits int) int {
	return if nbits % 64 == 0 {
		64
	} else if nbits % 32 == 0 {
		32
	} else if nbits % 16 == 0 {
		16
	} else {
		8
	}
}

pub fn integer_pack_directive(nbits int, endian IntEndian, signed IntSignedness) string {
	word_bits := integer_bits_per_word(nbits)
	nwords := nbits / word_bits
	mut directive := match word_bits {
		8 { 'C' }
		16 { 'S' }
		32 { 'L' }
		64 { 'Q' }
		else { '' }
	}
	if directive != 'C' {
		directive += if endian == .big { '>' } else { '<' }
	}
	mut result := directive.repeat(nwords)
	if signed == .signed && nbits in [8, 16, 32, 64] {
		result = result.to_lower()
	}
	return result
}

pub fn integer_needs_signed_conversion(nbits int, signed IntSignedness) bool {
	return signed == .signed && nbits !in [64, 32, 16]
}

pub fn integer_read_unpack_code(nbits int, endian IntEndian, signed IntSignedness) string {
	return "ints = io.readbytes(${nbits / 8}).unpack('${integer_pack_directive(nbits, endian, signed)}')"
}

pub fn integer_read_assemble_code(nbits int, endian IntEndian) string {
	word_bits := integer_bits_per_word(nbits)
	nwords := nbits / word_bits
	mut parts := []string{cap: nwords}
	for i in 0 .. nwords {
		index := if endian == .big { nwords - 1 - i } else { i }
		shift := word_bits * i
		parts << if shift == 0 { '(ints.at(${index}))' } else { '(ints.at(${index}) << ${shift})' }
	}
	return parts.join(' + ')
}

pub fn integer_raw_read_code(nbits int, endian IntEndian, signed IntSignedness) string {
	if nbits == 8 {
		return 'io.readbytes(1).ord'
	}
	return '(${integer_read_unpack_code(nbits, endian, signed)} ; ${integer_read_assemble_code(nbits, endian)})'
}

pub fn integer_int_to_uint_code(nbits int) string {
	return 'val &= ${decimal_decrement(power_of_two_decimal(nbits))}'
}

pub fn integer_uint_to_int_code(nbits int) string {
	return '(val >= ${power_of_two_decimal(nbits - 1)}) ? val - ${power_of_two_decimal(nbits)} : val'
}

pub fn integer_read_code(nbits int, endian IntEndian, signed IntSignedness) string {
	read := integer_raw_read_code(nbits, endian, signed)
	if integer_needs_signed_conversion(nbits, signed) {
		return 'val = ${read} ; ${integer_uint_to_int_code(nbits)}'
	}
	return read
}

pub fn integer_packed_words_code(nbits int, endian IntEndian) string {
	word_bits := integer_bits_per_word(nbits)
	nwords := nbits / word_bits
	mask := decimal_decrement(power_of_two_decimal(word_bits))
	mut values := []string{cap: nwords}
	for i in 0 .. nwords {
		shift := word_bits * i
		values << if shift == 0 { 'val' } else { 'val >> ${shift}' }
	}
	if endian == .big {
		values.reverse_in_place()
	}
	return values.map('${it} & ${mask}').join(',')
}

pub fn integer_to_binary_code(nbits int, endian IntEndian, signed IntSignedness) string {
	if nbits == 8 {
		return '(val & 0xff).chr'
	}
	packed := "[${integer_packed_words_code(nbits, endian)}].pack('${integer_pack_directive(nbits, endian, signed)}')"
	if integer_needs_signed_conversion(nbits, signed) {
		return '${integer_int_to_uint_code(nbits)} ; ${packed}'
	}
	return packed
}

pub fn clamp_integer(value i64, nbits int, signed IntSignedness) !i64 {
	if nbits <= 0 || nbits % 8 != 0 {
		return error('nbits must be a positive multiple of 8')
	}
	if signed == .signed {
		if nbits >= 64 {
			return value
		}
		maximum := i64((u64(1) << u32(nbits - 1)) - 1)
		minimum := -maximum - 1
		return if value < minimum {
			minimum
		} else if value > maximum { maximum } else { value }
	}
	if value < 0 {
		return 0
	}
	if nbits < 63 {
		maximum := i64((u64(1) << u32(nbits)) - 1)
		if value > maximum {
			return maximum
		}
	}
	return value
}

pub fn integer_to_binary(value i64, spec IntegerClass) ![]u8 {
	clamped := clamp_integer(value, spec.nbits, spec.signed)!
	mut raw := u64(clamped)
	if spec.nbits < 64 {
		raw &= (u64(1) << u32(spec.nbits)) - 1
	}
	nbytes := spec.nbits / 8
	mut result := []u8{len: nbytes}
	for index in 0 .. nbytes {
		byte_index := if spec.endian == .little { index } else { nbytes - index - 1 }
		result[index] = if byte_index < 8 {
			u8(raw >> u32(byte_index * 8))
		} else if spec.signed == .signed && clamped < 0 {
			0xff
		} else {
			0
		}
	}
	return result
}

pub fn integer_from_binary(data []u8, spec IntegerClass) !i64 {
	nbytes := spec.nbits / 8
	if spec.nbits <= 0 || data.len < nbytes {
		return error('integer input requires ${nbytes} bytes')
	}
	mut raw := u64(0)
	for index in 0 .. nbytes {
		byte_index := if spec.endian == .little { index } else { nbytes - index - 1 }
		if byte_index < 8 {
			raw |= u64(data[index]) << u32(byte_index * 8)
		}
	}
	if spec.nbits > 64 {
		top_byte := if spec.endian == .little { data[nbytes - 1] } else { data[0] }
		negative := spec.signed == .signed && top_byte & 0x80 != 0
		extension := if negative { u8(0xff) } else { u8(0) }
		for index in 0 .. nbytes {
			byte_index := if spec.endian == .little { index } else { nbytes - index - 1 }
			if byte_index >= 8 && data[index] != extension {
				return error('integer does not fit in V i64')
			}
		}
		converted := i64(raw)
		if (negative && converted >= 0) || (!negative && converted < 0) {
			return error('integer does not fit in V i64')
		}
		return converted
	}
	if spec.signed == .signed {
		if spec.nbits == 64 {
			return i64(raw)
		}
		sign_bit := u64(1) << u32(spec.nbits - 1)
		if raw >= sign_bit {
			return i64(raw) - i64(u64(1) << u32(spec.nbits))
		}
	}
	if raw > u64(0x7fff_ffff_ffff_ffff) {
		return error('unsigned integer does not fit in V i64')
	}
	return i64(raw)
}

fn int_endian_from_value(value ruby.Value) IntEndian {
	return if value.as_string().trim_left(':') == 'big' { .big } else { .little }
}

fn int_signedness_from_value(value ruby.Value) IntSignedness {
	return if value.as_string().trim_left(':') == 'signed' { .signed } else { .unsigned }
}

fn integer_class_value(spec IntegerClass) ruby.Value {
	return ruby.structured_value('BinData::IntegerClass', spec.name, {
		'name':   spec.name
		'nbits':  spec.nbits.str()
		'endian': spec.endian.str()
		'signed': spec.signed.str()
	})
}

fn integer_class_from_value(value ruby.Value) IntegerClass {
	if value.type_name == 'BinData::IntegerClass' {
		return define_integer_class(value.attribute('name') or { '' }, (value.attribute('nbits') or {
			'0'
		}).int(), if (value.attribute('endian') or { 'little' }) == 'big' { .big } else { .little }, if (value.attribute('signed') or { 'unsigned' }) == 'signed' {
			.signed
		} else {
			.unsigned
		}) or {
			panic(err)
		}
	}
	return integer_class_for_name(value.as_string()) or { panic(err) }
}

// Ruby method `define_class(name, nbits, endian, signed)` at line 12.
pub fn ruby_int_l12_d1_define_class(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Int.define_class requires name, nbits, endian and signedness')
	}
	spec := define_integer_class(args[0].as_string(), int(args[1].as_int() or { panic(err) }), int_endian_from_value(args[2]), int_signedness_from_value(args[3])) or { panic(err) }
	return integer_class_value(spec)
}

// Ruby define_method `Int.define_methods(new_class, nbits, endian.to_sym, signed.to_sym)` at line 16.
pub fn ruby_int_l16_d2_s_new_class(args ...ruby.Value) ruby.Value {
	return ruby_int_l26_d3_define_methods(...args)
}

// Ruby method `define_methods(int_class, nbits, endian, signed)` at line 26.
pub fn ruby_int_l26_d3_define_methods(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Int.define_methods requires a class, nbits, endian and signedness')
	}
	return integer_class_value(define_integer_class(args[0].as_string(), int(args[1].as_int() or {
		panic(err)
	}), int_endian_from_value(args[2]), int_signedness_from_value(args[3])) or { panic(err) })
}

// Ruby method `assign(val)` at line 30.
pub fn ruby_int_l30_d4_assign(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('integer assign requires a receiver and value')
	}
	spec := integer_class_from_value(args[0])
	return ruby.int_value(clamp_integer(args[1].as_int() or { panic(err) }, spec.nbits, spec.signed) or { panic(err) })
}

// Ruby method `do_num_bytes` at line 35.
pub fn ruby_int_l35_d5_do_num_bytes(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('integer do_num_bytes requires a receiver')
	}
	return ruby.int_value(integer_class_from_value(args[0]).nbits / 8)
}

// Ruby method `sensible_default` at line 42.
pub fn ruby_int_l42_d6_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.int_value(0)
}

// Ruby method `value_to_binary_string(val)` at line 46.
pub fn ruby_int_l46_d7_value_to_binary_string(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('integer value_to_binary_string requires a receiver and value')
	}
	return ruby.string_value(integer_to_binary(args[1].as_int() or { panic(err) }, integer_class_from_value(args[0])) or { panic(err) }.bytestr())
}

// Ruby method `read_and_return_value(io)` at line 51.
pub fn ruby_int_l51_d8_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('integer read_and_return_value requires a receiver and bytes')
	}
	return ruby.int_value(integer_from_binary(args[1].as_string().bytes(), integer_class_from_value(args[0])) or { panic(err) })
}

// Ruby method `create_clamp_code(nbits, signed)` at line 60.
pub fn ruby_int_l60_d9_create_clamp_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_clamp_code requires nbits and signedness')
	}
	return ruby.string_value(integer_clamp_code(int(args[0].as_int() or { panic(err) }), int_signedness_from_value(args[1])))
}

// Ruby method `create_read_code(nbits, endian, signed)` at line 72.
pub fn ruby_int_l72_d10_create_read_code(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('create_read_code requires nbits, endian and signedness')
	}
	return ruby.string_value(integer_read_code(int(args[0].as_int() or { panic(err) }), int_endian_from_value(args[1]), int_signedness_from_value(args[2])))
}

// Ruby method `create_raw_read_code(nbits, endian, signed)` at line 82.
pub fn ruby_int_l82_d11_create_raw_read_code(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('create_raw_read_code requires nbits, endian and signedness')
	}
	return ruby.string_value(integer_raw_read_code(int(args[0].as_int() or { panic(err) }), int_endian_from_value(args[1]), int_signedness_from_value(args[2])))
}

// Ruby method `create_read_unpack_code(nbits, endian, signed)` at line 94.
pub fn ruby_int_l94_d12_create_read_unpack_code(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('create_read_unpack_code requires nbits, endian and signedness')
	}
	return ruby.string_value(integer_read_unpack_code(int(args[0].as_int() or { panic(err) }), int_endian_from_value(args[1]), int_signedness_from_value(args[2])))
}

// Ruby method `create_read_assemble_code(nbits, endian)` at line 101.
pub fn ruby_int_l101_d13_create_read_assemble_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_read_assemble_code requires nbits and endian')
	}
	return ruby.string_value(integer_read_assemble_code(int(args[0].as_int() or {
		panic(err)
	}), int_endian_from_value(args[1])))
}

// Ruby method `create_to_binary_s_code(nbits, endian, signed)` at line 115.
pub fn ruby_int_l115_d14_create_to_binary_s_code(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('create_to_binary_s_code requires nbits, endian and signedness')
	}
	return ruby.string_value(integer_to_binary_code(int(args[0].as_int() or { panic(err) }), int_endian_from_value(args[1]), int_signedness_from_value(args[2])))
}

// Ruby method `val_as_packed_words(nbits, endian)` at line 130.
pub fn ruby_int_l130_d15_val_as_packed_words(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('val_as_packed_words requires nbits and endian')
	}
	return ruby.string_value(integer_packed_words_code(int(args[0].as_int() or {
		panic(err)
	}), int_endian_from_value(args[1])))
}

// Ruby method `create_int2uint_code(nbits)` at line 142.
pub fn ruby_int_l142_d16_create_int2uint_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_int2uint_code requires nbits')
	}
	return ruby.string_value(integer_int_to_uint_code(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `create_uint2int_code(nbits)` at line 146.
pub fn ruby_int_l146_d17_create_uint2int_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_uint2int_code requires nbits')
	}
	return ruby.string_value(integer_uint_to_int_code(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `bits_per_word(nbits)` at line 150.
pub fn ruby_int_l150_d18_bits_per_word(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('bits_per_word requires nbits')
	}
	return ruby.int_value(integer_bits_per_word(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `pack_directive(nbits, endian, signed)` at line 157.
pub fn ruby_int_l157_d19_pack_directive(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('pack_directive requires nbits, endian and signedness')
	}
	return ruby.string_value(integer_pack_directive(int(args[0].as_int() or { panic(err) }), int_endian_from_value(args[1]), int_signedness_from_value(args[2])))
}

// Ruby method `need_signed_conversion_code?(nbits, signed)` at line 172.
pub fn ruby_int_l172_d20_need_signed_conversion_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('need_signed_conversion_code? requires nbits and signedness')
	}
	return ruby.bool_value(integer_needs_signed_conversion(int(args[0].as_int() or {
		panic(err)
	}), int_signedness_from_value(args[1])))
}

// Ruby define_method `Int.define_methods(self, 8, :little, :unsigned)` at line 181.
pub fn ruby_int_l181_d21_s_self(args ...ruby.Value) ruby.Value {
	return integer_class_value(define_integer_class('Uint8', 8, .little, .unsigned) or {
		panic(err)
	})
}

// Ruby define_method `Int.define_methods(self, 8, :little, :signed)` at line 186.
pub fn ruby_int_l186_d22_s_self(args ...ruby.Value) ruby.Value {
	return integer_class_value(define_integer_class('Int8', 8, .little, .signed) or { panic(err) })
}

// Ruby method `const_missing(name)` at line 191.
pub fn ruby_int_l191_d23_const_missing(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('const_missing requires a class name')
	}
	return integer_class_value(integer_class_for_name(args[0].as_string()) or { panic(err) })
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
