module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/stringz.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct StringzOptions {
pub:
	max_length ?int
	debug_name string = 'BinData::Stringz'
}

pub fn truncate_stringz_after_first_zero(value string) string {
	index := value.index_u8(0)
	return if index < 0 { value } else { value[..index + 1] }
}

pub fn trim_stringz_to(value string, max_length ?int) string {
	if limit := max_length {
		if value.len < limit {
			return value
		}
		mut result := value[..limit]
		if result.len == limit && result.len > 0 {
			mut bytes := result.bytes()
			bytes[bytes.len - 1] = 0
			result = bytes.bytestr()
		}
		return result
	}
	return value
}

pub fn append_stringz_zero_if_needed(value string) string {
	return if value.len == 0 || value[value.len - 1] != 0 { value + '\0' } else { value }
}

pub fn trim_and_zero_terminate_string(value string, options StringzOptions) !string {
	if max_length := options.max_length {
		if max_length < 1 {
			return error('max_length must be >= 1 in ${options.debug_name} (got ${max_length})')
		}
	}
	truncated := truncate_stringz_after_first_zero(value)
	trimmed := trim_stringz_to(truncated, options.max_length)
	return append_stringz_zero_if_needed(trimmed)
}

pub fn stringz_snapshot(value string, options StringzOptions) !string {
	terminated := trim_and_zero_terminate_string(value, options)!
	return terminated[..terminated.len - 1]
}

pub fn read_stringz(data string, options StringzOptions) !string {
	if max_length := options.max_length {
		if max_length < 1 {
			return error('max_length must be >= 1 in ${options.debug_name} (got ${max_length})')
		}
	}
	mut length := 0
	for length < data.len {
		length++
		if data[length - 1] == 0 {
			break
		}
		if max_length := options.max_length {
			if length == max_length {
				break
			}
		}
	}
	if length == data.len && (length == 0 || data[length - 1] != 0) {
		if max_length := options.max_length {
			if length < max_length {
				return error('end of file reached while reading zero terminated string')
			}
		} else {
			return error('end of file reached while reading zero terminated string')
		}
	}
	return trim_and_zero_terminate_string(data[..length], options)
}

fn stringz_options_from_value(value brew_runtime.Value) StringzOptions {
	maximum := if raw := value.attributes['max_length'] { ?int(raw.int()) } else { none }
	fallback_name := if value.repr.len == 0 { 'BinData::Stringz' } else { value.repr }
	return StringzOptions{
		max_length: maximum
		debug_name: value.attributes['debug_name'] or { fallback_name }
	}
}

// Ruby method `assign(val)` at line 30.
pub fn ruby_stringz_l30_d1_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Stringz#assign requires a value')
	}
	return brew_runtime.string_value(args[args.len - 1].as_string())
}

// Ruby method `snapshot` at line 34.
pub fn ruby_stringz_l34_d2_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Stringz#snapshot requires a receiver')
	}
	value := args[0].attributes['value'] or { args[0].as_string() }
	return brew_runtime.string_value(stringz_snapshot(value, stringz_options_from_value(args[0])) or {
		panic(err)
	})
}

// Ruby method `value_to_binary_string(val)` at line 43.
pub fn ruby_stringz_l43_d3_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Stringz#value_to_binary_string requires a receiver and value')
	}
	return brew_runtime.string_value(trim_and_zero_terminate_string(args[1].as_string(), stringz_options_from_value(args[0])) or { panic(err) })
}

// Ruby method `read_and_return_value(io)` at line 47.
pub fn ruby_stringz_l47_d4_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Stringz#read_and_return_value requires a receiver and input')
	}
	return brew_runtime.string_value(read_stringz(args[1].as_string(), stringz_options_from_value(args[0])) or { panic(err) })
}

// Ruby method `sensible_default` at line 63.
pub fn ruby_stringz_l63_d5_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby method `trim_and_zero_terminate(str)` at line 67.
pub fn ruby_stringz_l67_d6_trim_and_zero_terminate(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Stringz#trim_and_zero_terminate requires a receiver and string')
	}
	return brew_runtime.string_value(trim_and_zero_terminate_string(args[1].as_string(), stringz_options_from_value(args[0])) or { panic(err) })
}

// Ruby method `truncate_after_first_zero_byte!(str)` at line 81.
pub fn ruby_stringz_l81_d7_truncate_after_first_zero_byte(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('truncate_after_first_zero_byte! requires a string')
	}
	return brew_runtime.string_value(truncate_stringz_after_first_zero(args[args.len - 1].as_string()))
}

// Ruby method `trim_to!(str, max_length = nil)` at line 85.
pub fn ruby_stringz_l85_d8_trim_to(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('trim_to! requires a string')
	}
	maximum := if args.len > 1 && args[args.len - 1].type_name == 'Integer' {
		?int(args[args.len - 1].as_int() or { panic(err) })
	} else {
		none
	}
	value_index := if maximum == none { args.len - 1 } else { args.len - 2 }
	return brew_runtime.string_value(trim_stringz_to(args[value_index].as_string(), maximum))
}

// Ruby method `append_zero_byte_if_needed!(str)` at line 92.
pub fn ruby_stringz_l92_d9_append_zero_byte_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('append_zero_byte_if_needed! requires a string')
	}
	return brew_runtime.string_value(append_stringz_zero_if_needed(args[args.len - 1].as_string()))
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
