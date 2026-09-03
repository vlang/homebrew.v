module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/string.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct BinStringOptions {
pub:
	read_length   ?int
	length        ?int
	trim_padding  bool
	pad_front     bool
	pad_byte      string = '\0'
	has_value     bool
	has_assertion bool
}

pub fn validate_bin_string_options(options BinStringOptions) ! {
	if read_length := options.read_length {
		if read_length < 0 {
			return error('read_length must be non-negative')
		}
		if options.length != none {
			return error('read_length and length are mutually exclusive')
		}
	}
	if length := options.length {
		if length < 0 {
			return error('length must be non-negative')
		}
		if options.has_value {
			return error('length and value are mutually exclusive')
		}
	}
	if options.pad_byte.len > 1 {
		return error(':pad_byte must not contain more than 1 byte')
	}
}

pub fn bin_string_warns_without_read_length(options BinStringOptions) bool {
	return (options.has_value || options.has_assertion) && options.read_length == none
}

pub fn clamp_bin_string_to_length(value string, options BinStringOptions) string {
	length := options.length or { value.len }
	if value.len == length {
		return value
	}
	if value.len > length {
		return value[..length]
	}
	padding := options.pad_byte.repeat(length - value.len)
	return if options.pad_front { padding + value } else { value + padding }
}

pub fn trim_bin_string_padding(value string, options BinStringOptions) string {
	if options.pad_byte.len == 0 {
		return value
	}
	mut start := 0
	mut end := value.len
	if options.pad_front {
		for start < end && value[start] == options.pad_byte[0] {
			start++
		}
	} else {
		for end > start && value[end - 1] == options.pad_byte[0] {
			end--
		}
	}
	return value[start..end]
}

pub fn bin_string_snapshot(value string, options BinStringOptions) string {
	clamped := clamp_bin_string_to_length(value, options)
	return if options.trim_padding { trim_bin_string_padding(clamped, options) } else { clamped }
}

pub fn bin_string_binary(value string, options BinStringOptions) string {
	return clamp_bin_string_to_length(value, options)
}

pub fn read_bin_string(data string, options BinStringOptions) !string {
	length := options.read_length or { options.length or { 0 } }
	if data.len < length {
		return error('end of file reached while reading ${length} bytes')
	}
	return data[..length]
}

pub fn sanitize_bin_string_pad_byte(value brew_runtime.Value) !string {
	if value.type_name == 'Integer' {
		byte := value.as_int()!
		if byte < 0 || byte > 255 {
			return error('integer pad_byte must be between 0 and 255')
		}
		return [u8(byte)].bytestr()
	}
	pad_byte := value.as_string()
	if pad_byte.len > 1 {
		return error(':pad_byte must not contain more than 1 byte')
	}
	return pad_byte
}

pub fn sanitize_bin_string_parameters(parameters map[string]brew_runtime.Value) !map[string]brew_runtime.Value {
	mut result := parameters.clone()
	if 'initial_length' in result && 'read_length' !in result {
		result['read_length'] = result['initial_length']
	}
	result.delete('initial_length')
	for name in ['read_length', 'length'] {
		if name in result {
			_ = result[name].as_int()!
		}
	}
	if 'pad_left' in result {
		if 'pad_front' !in result {
			result['pad_front'] = result['pad_left']
		}
		result.delete('pad_left')
	}
	if 'pad_byte' in result {
		result['pad_byte'] = brew_runtime.string_value(sanitize_bin_string_pad_byte(result['pad_byte'])!)
	}
	return result
}

fn bin_string_options_from_value(value brew_runtime.Value) BinStringOptions {
	read_length := if raw := value.attributes['read_length'] { ?int(raw.int()) } else { none }
	length := if raw := value.attributes['length'] { ?int(raw.int()) } else { none }
	return BinStringOptions{
		read_length: read_length
		length: length
		trim_padding: value.attributes['trim_padding'] == 'true'
		pad_front: value.attributes['pad_front'] == 'true'
		pad_byte: value.attributes['pad_byte'] or { '\0' }
		has_value: 'value' in value.attributes
		has_assertion: 'asserted_value' in value.attributes
	}
}

pub fn bin_string_options_value(options BinStringOptions, value string) brew_runtime.Value {
	mut attributes := {
		'trim_padding': options.trim_padding.str()
		'pad_front':    options.pad_front.str()
		'pad_byte':     options.pad_byte
		'value':        value
	}
	if read_length := options.read_length {
		attributes['read_length'] = read_length.str()
	}
	if length := options.length {
		attributes['length'] = length.str()
	}
	if options.has_assertion {
		attributes['asserted_value'] = value
	}
	return brew_runtime.structured_value('BinData::String', value, attributes)
}

// Ruby method `initialize_shared_instance` at line 59.
pub fn ruby_string_l59_d1_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('String#initialize_shared_instance requires a receiver')
	}
	options := bin_string_options_from_value(args[0])
	validate_bin_string_options(options) or { panic(err) }
	mut attributes := args[0].attributes.clone()
	attributes['warn_no_read_length'] = bin_string_warns_without_read_length(options).str()
	return brew_runtime.structured_value(args[0].type_name, args[0].repr, attributes)
}

// Ruby method `assign(val)` at line 67.
pub fn ruby_string_l67_d2_assign(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('String#assign requires a value')
	}
	value := if args.len > 1 { args[1] } else { args[0] }
	return brew_runtime.string_value(value.as_string())
}

// Ruby method `snapshot` at line 71.
pub fn ruby_string_l71_d3_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('String#snapshot requires a receiver')
	}
	value := args[0].attributes['value'] or { args[0].as_string() }
	return brew_runtime.string_value(bin_string_snapshot(value, bin_string_options_from_value(args[0])))
}

// Ruby method `clamp_to_length(str)` at line 86.
pub fn ruby_string_l86_d4_clamp_to_length(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('String#clamp_to_length requires a receiver and string')
	}
	return brew_runtime.string_value(clamp_bin_string_to_length(args[1].as_string(), bin_string_options_from_value(args[0])))
}

// Ruby method `trim_padding(str)` at line 104.
pub fn ruby_string_l104_d5_trim_padding(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('String#trim_padding requires a receiver and string')
	}
	return brew_runtime.string_value(trim_bin_string_padding(args[1].as_string(), bin_string_options_from_value(args[0])))
}

// Ruby method `value_to_binary_string(val)` at line 112.
pub fn ruby_string_l112_d6_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('String#value_to_binary_string requires a receiver and value')
	}
	return brew_runtime.string_value(bin_string_binary(args[1].as_string(), bin_string_options_from_value(args[0])))
}

// Ruby method `read_and_return_value(io)` at line 116.
pub fn ruby_string_l116_d7_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('String#read_and_return_value requires a receiver and input')
	}
	return brew_runtime.string_value(read_bin_string(args[1].as_string(), bin_string_options_from_value(args[0])) or { panic(err) })
}

// Ruby method `sensible_default` at line 121.
pub fn ruby_string_l121_d8_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby method `read_and_return_value(io)` at line 127.
pub fn ruby_string_l127_d9_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('WarnNoReadLengthPlugin#read_and_return_value requires a receiver')
	}
	debug_name := args[0].attributes['debug_name'] or { args[0].repr }
	eprintln('${debug_name} does not have a :read_length parameter - returning empty string')
	return brew_runtime.string_value('')
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 135.
pub fn ruby_string_l135_d10_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('StringArgProcessor#sanitize_parameters! requires params')
	}
	params := args[args.len - 1].as_map() or { panic(err) }
	return brew_runtime.map_value(sanitize_bin_string_parameters(params) or { panic(err) })
}

// Ruby method `sanitized_pad_byte(byte)` at line 145.
pub fn ruby_string_l145_d11_sanitized_pad_byte(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('sanitized_pad_byte requires a byte')
	}
	return brew_runtime.string_value(sanitize_bin_string_pad_byte(args[args.len - 1]) or {
		panic(err)
	})
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
