module bindata

import ruby
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/float.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum FloatPrecision {
	single
	double
}

pub struct FloatingPointClass {
pub:
	name      string
	precision FloatPrecision
	endian    IntEndian
}

pub fn floating_point_num_bytes(precision FloatPrecision) int {
	return if precision == .single { 4 } else { 8 }
}

pub fn floating_point_pack_code(precision FloatPrecision, endian IntEndian) string {
	return match precision {
		.single {
			if endian == .little { 'e' } else { 'g' }
		}
		.double {
			if endian == .little { 'E' } else { 'G' }
		}
	}
}

pub fn floating_point_read_code(precision FloatPrecision, endian IntEndian) string {
	return "io.readbytes(${floating_point_num_bytes(precision)}).unpack1('${floating_point_pack_code(precision, endian)}')"
}

pub fn floating_point_to_binary_code(precision FloatPrecision, endian IntEndian) string {
	return "[val].pack('${floating_point_pack_code(precision, endian)}')"
}

pub fn floating_point_to_binary(value f64, precision FloatPrecision, endian IntEndian) []u8 {
	nbytes := floating_point_num_bytes(precision)
	bits := if precision == .single { u64(math.f32_bits(f32(value))) } else { math.f64_bits(value) }
	mut result := []u8{len: nbytes}
	for index in 0 .. nbytes {
		shift := if endian == .little { index * 8 } else { (nbytes - index - 1) * 8 }
		result[index] = u8(bits >> u32(shift))
	}
	return result
}

pub fn floating_point_from_binary(data []u8, precision FloatPrecision, endian IntEndian) !f64 {
	nbytes := floating_point_num_bytes(precision)
	if data.len < nbytes {
		return error('floating point input requires ${nbytes} bytes')
	}
	mut bits := u64(0)
	for index in 0 .. nbytes {
		shift := if endian == .little { index * 8 } else { (nbytes - index - 1) * 8 }
		bits |= u64(data[index]) << u32(shift)
	}
	return if precision == .single {
		f64(math.f32_from_bits(u32(bits)))
	} else {
		math.f64_from_bits(bits)
	}
}

fn float_precision_from_value(value ruby.Value) FloatPrecision {
	return if value.as_string().trim_left(':') == 'single' { .single } else { .double }
}

fn floating_point_class_value(spec FloatingPointClass) ruby.Value {
	return ruby.structured_value('BinData::FloatingPointClass', spec.name, {
		'name':      spec.name
		'precision': spec.precision.str()
		'endian':    spec.endian.str()
	})
}

fn floating_point_class_from_value(value ruby.Value) FloatingPointClass {
	if value.type_name == 'BinData::FloatingPointClass' {
		return FloatingPointClass{
			name: value.attribute('name') or { '' }
			precision: if (value.attribute('precision') or { 'double' }) == 'single' {
				.single} else {
				.double}
			endian: if (value.attribute('endian') or { 'little' }) == 'big' {
				.big} else {
				.little}
		}
	}
	return match value.as_string() {
		'FloatLe' { FloatingPointClass{'FloatLe', .single, .little} }
		'FloatBe' { FloatingPointClass{'FloatBe', .single, .big} }
		'DoubleLe' { FloatingPointClass{'DoubleLe', .double, .little} }
		'DoubleBe' { FloatingPointClass{'DoubleBe', .double, .big} }
		else { panic('unknown floating point class `${value.as_string()}`') }
	}
}

// Ruby method `define_methods(float_class, precision, endian)` at line 21.
pub fn ruby_float_l21_d1_define_methods(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('FloatingPoint.define_methods requires a class, precision and endian')
	}
	return floating_point_class_value(FloatingPointClass{
		name: args[0].as_string()
		precision: float_precision_from_value(args[1])
		endian: int_endian_from_value(args[2])
	})
}

// Ruby method `do_num_bytes` at line 23.
pub fn ruby_float_l23_d2_do_num_bytes(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('floating point do_num_bytes requires a receiver')
	}
	return ruby.int_value(floating_point_num_bytes(floating_point_class_from_value(args[0]).precision))
}

// Ruby method `sensible_default` at line 30.
pub fn ruby_float_l30_d3_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.float_value(0.0)
}

// Ruby method `value_to_binary_string(val)` at line 34.
pub fn ruby_float_l34_d4_value_to_binary_string(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('floating point value_to_binary_string requires a receiver and value')
	}
	spec := floating_point_class_from_value(args[0])
	return ruby.string_value(floating_point_to_binary(args[1].as_float() or { panic(err) }, spec.precision, spec.endian).bytestr())
}

// Ruby method `read_and_return_value(io)` at line 38.
pub fn ruby_float_l38_d5_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('floating point read_and_return_value requires a receiver and bytes')
	}
	spec := floating_point_class_from_value(args[0])
	return ruby.float_value(floating_point_from_binary(args[1].as_string().bytes(), spec.precision, spec.endian) or { panic(err) })
}

// Ruby method `create_num_bytes_code(precision)` at line 44.
pub fn ruby_float_l44_d6_create_num_bytes_code(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_num_bytes_code requires precision')
	}
	return ruby.int_value(floating_point_num_bytes(float_precision_from_value(args[0])))
}

// Ruby method `create_read_code(precision, endian)` at line 48.
pub fn ruby_float_l48_d7_create_read_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_read_code requires precision and endian')
	}
	return ruby.string_value(floating_point_read_code(float_precision_from_value(args[0]), int_endian_from_value(args[1])))
}

// Ruby method `create_to_binary_s_code(precision, endian)` at line 55.
pub fn ruby_float_l55_d8_create_to_binary_s_code(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_to_binary_s_code requires precision and endian')
	}
	return ruby.string_value(floating_point_to_binary_code(float_precision_from_value(args[0]), int_endian_from_value(args[1])))
}

// Ruby define_method `FloatingPoint.define_methods(self, :single, :little)` at line 66.
pub fn ruby_float_l66_d9_s_self(args ...ruby.Value) ruby.Value {
	return floating_point_class_value(FloatingPointClass{'FloatLe', .single, .little})
}

// Ruby define_method `FloatingPoint.define_methods(self, :single, :big)` at line 71.
pub fn ruby_float_l71_d10_s_self(args ...ruby.Value) ruby.Value {
	return floating_point_class_value(FloatingPointClass{'FloatBe', .single, .big})
}

// Ruby define_method `FloatingPoint.define_methods(self, :double, :little)` at line 76.
pub fn ruby_float_l76_d11_s_self(args ...ruby.Value) ruby.Value {
	return floating_point_class_value(FloatingPointClass{'DoubleLe', .double, .little})
}

// Ruby define_method `FloatingPoint.define_methods(self, :double, :big)` at line 81.
pub fn ruby_float_l81_d12_s_self(args ...ruby.Value) ruby.Value {
	return floating_point_class_value(FloatingPointClass{'DoubleBe', .double, .big})
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
