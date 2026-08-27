module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/uint8_array.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `value_to_binary_string(val)` at line 32.
pub fn ruby_uint8_array_l32_d1_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value_to_binary_string', ...args)
}

// Ruby method `read_and_return_value(io)` at line 36.
pub fn ruby_uint8_array_l36_d2_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_and_return_value', ...args)
}

// Ruby method `sensible_default` at line 46.
pub fn ruby_uint8_array_l46_d3_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sensible_default', ...args)
}

// Ruby method `sanitize_parameters!(obj_class, params) # :nodoc:` at line 52.
pub fn ruby_uint8_array_l52_d4_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sanitize_parameters!', ...args)
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
