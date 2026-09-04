module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/virtual.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `do_read(io); end` at line 32.
pub fn ruby_virtual_l32_d1_do_read(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `do_write(io); end` at line 34.
pub fn ruby_virtual_l34_d2_do_write(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `do_num_bytes` at line 36.
pub fn ruby_virtual_l36_d3_do_num_bytes(args ...ruby.Value) ruby.Value {
	return ruby.float_value(0.0)
}

// Ruby method `sensible_default` at line 40.
pub fn ruby_virtual_l40_d4_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base'
// 2:
// 3: module BinData
// 4:   # A virtual field is one that is neither read, written nor occupies space in
// 5:   # the data stream.  It is used to make assertions or as a convenient label
// 6:   # for determining offsets or storing values.
// 7:   #
// 8:   #   require 'bindata'
// 9:   #
// 10:   #   class A < BinData::Record
// 11:   #     string  :a, read_length: 5
// 12:   #     string  :b, read_length: 5
// 13:   #     virtual :c, assert: -> { a == b }
// 14:   #   end
// 15:   #
// 16:   #   obj = A.read("abcdeabcde")
// 17:   #   obj.a #=> "abcde"
// 18:   #   obj.c.rel_offset #=> 10
// 19:   #
// 20:   #   obj = A.read("abcdeABCDE") #=> BinData::ValidityError: assertion failed for obj.c
// 21:   #
// 22:   # == Parameters
// 23:   #
// 24:   # Parameters may be provided at initialisation to control the behaviour of
// 25:   # an object.  These params include those for BinData::Base as well as:
// 26:   #
// 27:   # [<tt>:assert</tt>]    Raise an error when reading or assigning if the value
// 28:   #                       of this evaluated parameter is false.
// 29:   # [<tt>:value</tt>]     The virtual object will always have this value.
// 30:   #
// 31:   class Virtual < BinData::BasePrimitive
// 32:     def do_read(io); end
// 33:
// 34:     def do_write(io); end
// 35:
// 36:     def do_num_bytes
// 37:       0.0
// 38:     end
// 39:
// 40:     def sensible_default
// 41:       nil
// 42:     end
// 43:   end
// 44: end
