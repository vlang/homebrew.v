module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/uint8_array.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct Uint8ArrayParams {
pub:
	initial_length ?int
	read_until     string
}

pub fn sanitize_uint8_array_params(initial_length ?int, read_until string) !Uint8ArrayParams {
	canonical_read_until := read_until.trim_left(':')
	if canonical_read_until.len > 0 && canonical_read_until != 'eof' {
		return error('Parameter :read_until must have a value of :eof')
	}
	if initial_length != none && canonical_read_until.len > 0 {
		return error('Parameters :initial_length and :read_until are mutually exclusive')
	}
	if length := initial_length {
		if length < 0 {
			return error('Parameter :initial_length must not be negative')
		}
		return Uint8ArrayParams{
			initial_length: length
		}
	}
	if canonical_read_until.len > 0 {
		return Uint8ArrayParams{
			read_until: canonical_read_until
		}
	}
	return Uint8ArrayParams{
		initial_length: 0
	}
}

pub fn uint8_array_to_binary_string(value []u8) string {
	return value.bytestr()
}

pub fn read_uint8_array(data []u8, params Uint8ArrayParams) ![]u8 {
	if length := params.initial_length {
		if length > data.len {
			return error('End of file reached while reading ${length} byte(s)')
		}
		return data[..length].clone()
	}
	return data.clone()
}

fn uint8_values(value ruby.Value) []u8 {
	if value.type_name == 'String' {
		return value.as_string().bytes()
	}
	values := value.as_array() or { panic(err) }
	mut result := []u8{cap: values.len}
	for item in values {
		integer := item.as_int() or { panic(err) }
		if integer < 0 || integer > 255 {
			panic('Uint8Array values must be between 0 and 255')
		}
		result << u8(integer)
	}
	return result
}

fn uint8_params(value ruby.Value) Uint8ArrayParams {
	if value.type_name != 'Hash' {
		return sanitize_uint8_array_params(none, '') or { panic(err) }
	}
	params := value.as_map() or { panic(err) }
	initial_length := if 'initial_length' in params {
		?int(int(params['initial_length'].as_int() or { panic(err) }))
	} else {
		none
	}
	read_until := if 'read_until' in params { params['read_until'].as_string() } else { '' }
	return sanitize_uint8_array_params(initial_length, read_until) or { panic(err) }
}

// Ruby method `value_to_binary_string(val)` at line 32.
pub fn ruby_uint8_array_l32_d1_value_to_binary_string(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Uint8Array#value_to_binary_string requires a value')
	}
	return ruby.string_value(uint8_array_to_binary_string(uint8_values(args[0])))
}

// Ruby method `read_and_return_value(io)` at line 36.
pub fn ruby_uint8_array_l36_d2_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Uint8Array#read_and_return_value requires IO data')
	}
	params := if args.len >= 2 {
		uint8_params(args[0])
	} else {
		Uint8ArrayParams{
			read_until: 'eof'
		}
	}
	data := if args.len >= 2 { args[1] } else { args[0] }
	bytes := read_uint8_array(uint8_values(data), params) or { panic(err) }
	return ruby.array_value(bytes.map(ruby.int_value(i64(it))))
}

// Ruby method `sensible_default` at line 46.
pub fn ruby_uint8_array_l46_d3_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `sanitize_parameters!(obj_class, params) # :nodoc:` at line 52.
pub fn ruby_uint8_array_l52_d4_sanitize_parameters(args ...ruby.Value) ruby.Value {
	params_value := if args.len >= 2 {
		args[1]
	} else if args.len == 1 {
		args[0]
	} else {
		ruby.map_value(map[string]ruby.Value{})
	}
	params := uint8_params(params_value)
	mut sanitized := map[string]ruby.Value{}
	if length := params.initial_length {
		sanitized['initial_length'] = ruby.int_value(length)
	}
	if params.read_until.len > 0 {
		sanitized['read_until'] = ruby.string_value(params.read_until)
	}
	return ruby.map_value(sanitized)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # Uint8Array is a specialised type of array that only contains
// 5:   # bytes (Uint8).  It is a faster and more memory efficient version
// 6:   # of `BinData::Array.new(:type => :uint8)`.
// 7:   #
// 8:   #   require 'bindata'
// 9:   #
// 10:   #   obj = BinData::Uint8Array.new(initial_length: 5)
// 11:   #   obj.read("abcdefg") #=> [97, 98, 99, 100, 101]
// 12:   #   obj[2] #=> 99
// 13:   #   obj.collect { |x| x.chr }.join #=> "abcde"
// 14:   #
// 15:   # == Parameters
// 16:   #
// 17:   # Parameters may be provided at initialisation to control the behaviour of
// 18:   # an object.  These params are:
// 19:   #
// 20:   # <tt>:initial_length</tt>:: The initial length of the array.
// 21:   # <tt>:read_until</tt>::     May only have a value of `:eof`.  This parameter
// 22:   #                            instructs the array to read as much data from
// 23:   #                            the stream as possible.
// 24:   class Uint8Array < BinData::BasePrimitive
// 25:     optional_parameters :initial_length, :read_until
// 26:     mutually_exclusive_parameters :initial_length, :read_until
// 27:     arg_processor :uint8_array
// 28:
// 29:     #---------------
// 30:     private
// 31:
// 32:     def value_to_binary_string(val)
// 33:       val.pack("C*")
// 34:     end
// 35:
// 36:     def read_and_return_value(io)
// 37:       if has_parameter?(:initial_length)
// 38:         data = io.readbytes(eval_parameter(:initial_length))
// 39:       else
// 40:         data = io.read_all_bytes
// 41:       end
// 42:
// 43:       data.unpack("C*")
// 44:     end
// 45:
// 46:     def sensible_default
// 47:       []
// 48:     end
// 49:   end
// 50:
// 51:   class Uint8ArrayArgProcessor < BaseArgProcessor
// 52:     def sanitize_parameters!(obj_class, params) # :nodoc:
// 53:       # ensure one of :initial_length and :read_until exists
// 54:       unless params.has_at_least_one_of?(:initial_length, :read_until)
// 55:         params[:initial_length] = 0
// 56:       end
// 57:
// 58:       msg = "Parameter :read_until must have a value of :eof"
// 59:       params.sanitize(:read_until) { |val| raise ArgumentError, msg unless val == :eof }
// 60:     end
// 61:   end
// 62: end
