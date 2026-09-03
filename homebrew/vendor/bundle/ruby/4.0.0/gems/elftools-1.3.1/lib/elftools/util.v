module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/util.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn align_number(number i64, bit int) !i64 {
	if bit < 0 || bit > 62 {
		return error('alignment bit must be between 0 and 62')
	}
	n := i64(u64(1) << u32(bit))
	if number % n == 0 {
		return number
	}
	return (number + n) & ~(n - 1)
}

pub fn constant_value(module_name string, constants map[string]i64, value brew_runtime.Value) !i64 {
	short_name := module_name.trim_string_left('ELFTools::')
	if value.type_name == 'Integer' {
		integer := value.as_int()!
		if integer in constants.values() {
			return integer
		}
		return error('No constants in ${short_name} is ${integer}')
	}
	prefix := short_name.split('::').last()
	mut name := value.as_string().to_upper()
	if !name.starts_with(prefix) {
		name = '${prefix}_${name}'
	}
	if name !in constants {
		return error('No constants in ${short_name} named "${name}"')
	}
	return constants[name]
}

pub fn cstring(data []u8, offset int) ?string {
	if offset < 0 || offset >= data.len {
		return none
	}
	mut result := []u8{}
	for character in data[offset..] {
		if character == 0 {
			return result.bytestr()
		}
		result << character
	}
	return none
}

pub fn select_values_by_type(values []brew_runtime.Value, expected_type string,
	on_match fn(brew_runtime.Value)) []brew_runtime.Value {
	mut selected := []brew_runtime.Value{}
	for value in values {
		actual_type := value.attribute('type') or { value.type_name }
		if actual_type == expected_type {
			on_match(value)
			selected << value
		}
	}
	return selected
}

fn ignore_selected_value(_ brew_runtime.Value) {}

// Ruby method `align(num, bit)` at line 19.
pub fn ruby_util_l19_d1_align(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ELFTools::Util.align requires num and bit')
	}
	return brew_runtime.int_value(align_number(args[0].as_int() or { panic(err) }, int(args[1].as_int() or { panic(err) })) or { panic(err) })
}

// Ruby method `to_constant(mod, val)` at line 36.
pub fn ruby_util_l36_d2_to_constant(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('ELFTools::Util.to_constant requires module name, constants, and value')
	}
	mut constants := map[string]i64{}
	for name, value in args[1].as_map() or { panic(err) } {
		constants[name] = value.as_int() or { panic(err) }
	}
	return brew_runtime.int_value(constant_value(args[0].as_string(), constants, args[2]) or {
		panic(err)
	})
}

// Ruby method `cstring(stream, offset)` at line 61.
pub fn ruby_util_l61_d3_cstring(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ELFTools::Util.cstring requires stream data and offset')
	}
	value := cstring(args[0].as_string().bytes(), int(args[1].as_int() or { panic(err) })) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(value)
}

// Ruby method `select_by_type(enum, type)` at line 88.
pub fn ruby_util_l88_d4_select_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ELFTools::Util.select_by_type requires values and a type')
	}
	return brew_runtime.array_value(select_values_by_type(args[0].as_array() or { panic(err) }, args[1].as_string(), ignore_selected_value))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module ELFTools
// 4:   # Define some util methods.
// 5:   module Util
// 6:     # Class methods.
// 7:     module ClassMethods
// 8:       # Round up the number to be multiple of
// 9:       # +2**bit+.
// 10:       # @param [Integer] num Number to be rounded-up.
// 11:       # @param [Integer] bit How many bit to be aligned.
// 12:       # @return [Integer] See examples.
// 13:       # @example
// 14:       #   align(10, 1) #=> 10
// 15:       #   align(10, 2) #=> 12
// 16:       #   align(10, 3) #=> 16
// 17:       #   align(10, 4) #=> 16
// 18:       #   align(10, 5) #=> 32
// 19:       def align(num, bit)
// 20:         n = 2**bit
// 21:         return num if (num % n).zero?
// 22:
// 23:         (num + n) & ~(n - 1)
// 24:       end
// 25:
// 26:       # Fetch the correct value from module +mod+.
// 27:       #
// 28:       # See {ELFTools::ELFFile#segment_by_type} for how to
// 29:       # use this method.
// 30:       # @param [Module] mod The module defined constant numbers.
// 31:       # @param [Integer, Symbol, String] val
// 32:       #   Desired value.
// 33:       # @return [Integer]
// 34:       #   Currently this method always return a value
// 35:       #   from {ELFTools::Constants}.
// 36:       def to_constant(mod, val)
// 37:         # Ignore the outest name.
// 38:         module_name = mod.name.sub('ELFTools::', '')
// 39:         # if val is an integer, check if exists in mod
// 40:         if val.is_a?(Integer)
// 41:           return val if mod.constants.any? { |c| mod.const_get(c) == val }
// 42:
// 43:           raise ArgumentError, "No constants in #{module_name} is #{val}"
// 44:         end
// 45:         val = val.to_s.upcase
// 46:         prefix = module_name.split('::')[-1]
// 47:         val = "#{prefix}_#{val}" unless val.start_with?(prefix)
// 48:         val = val.to_sym
// 49:         raise ArgumentError, "No constants in #{module_name} named \"#{val}\"" unless mod.const_defined?(val)
// 50:
// 51:         mod.const_get(val)
// 52:       end
// 53:
// 54:       # Read from stream until reach a null-byte.
// 55:       # @param [#pos=, #read] stream Streaming object
// 56:       # @param [Integer] offset Start from here.
// 57:       # @return [String] Result string will never contain null byte.
// 58:       # @example
// 59:       #   Util.cstring(File.open('/bin/cat'), 0)
// 60:       #   #=> "\x7FELF\x02\x01\x01"
// 61:       def cstring(stream, offset)
// 62:         stream.pos = offset
// 63:         # read until "\x00"
// 64:         ret = ''
// 65:         loop do
// 66:           c = stream.read(1)
// 67:           return nil if c.nil? # reach EOF
// 68:           break if c == "\x00"
// 69:
// 70:           ret += c
// 71:         end
// 72:         ret
// 73:       end
// 74:
// 75:       # Select objects from enumerator with +.type+ property
// 76:       # equals to +type+.
// 77:       #
// 78:       # Different from naive +Array#select+ is this method
// 79:       # will yield block whenever find a desired object.
// 80:       #
// 81:       # This method is used to simplify the same logic in methods
// 82:       # {ELFFile#sections_by_type}, {ELFFile#segments_by_type}, etc.
// 83:       # @param [Enumerator] enum An enumerator for further select.
// 84:       # @param [Object] type The type you want.
// 85:       # @return [Array<Object>]
// 86:       #   The return value will be objects in +enum+ with attribute
// 87:       #   +.type+ equals to +type+.
// 88:       def select_by_type(enum, type)
// 89:         enum.select do |obj|
// 90:           if obj.type == type
// 91:             yield obj if block_given?
// 92:             true
// 93:           end
// 94:         end
// 95:       end
// 96:     end
// 97:     extend ClassMethods
// 98:   end
// 99: end
