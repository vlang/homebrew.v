module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/rest.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `value_to_binary_string(val)` at line 22.
pub fn ruby_rest_l22_d1_value_to_binary_string(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Rest#value_to_binary_string requires a value')
	}
	return args[0]
}

// Ruby method `read_and_return_value(io)` at line 26.
pub fn ruby_rest_l26_d2_read_and_return_value(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Rest#read_and_return_value requires an IO value')
	}
	return if args[0].type_name == 'String' {
		args[0]
	} else {
		ruby.string_value(args[0].attribute('all_bytes') or {
			panic('IO value has no all_bytes attribute')
		})
	}
}

// Ruby method `sensible_default` at line 30.
pub fn ruby_rest_l30_d3_sensible_default(args ...ruby.Value) ruby.Value {
	return ruby.string_value('')
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # Rest will consume the input stream from the current position to the end of
// 5:   # the stream.  This will mainly be useful for debugging and developing.
// 6:   #
// 7:   #   require 'bindata'
// 8:   #
// 9:   #   class A < BinData::Record
// 10:   #     string :a, read_length: 5
// 11:   #     rest   :rest
// 12:   #   end
// 13:   #
// 14:   #   obj = A.read("abcdefghij")
// 15:   #   obj.a #=> "abcde"
// 16:   #   obj.rest #=" "fghij"
// 17:   #
// 18:   class Rest < BinData::BasePrimitive
// 19:     #---------------
// 20:     private
// 21:
// 22:     def value_to_binary_string(val)
// 23:       val
// 24:     end
// 25:
// 26:     def read_and_return_value(io)
// 27:       io.read_all_bytes
// 28:     end
// 29:
// 30:     def sensible_default
// 31:       ""
// 32:     end
// 33:   end
// 34: end
