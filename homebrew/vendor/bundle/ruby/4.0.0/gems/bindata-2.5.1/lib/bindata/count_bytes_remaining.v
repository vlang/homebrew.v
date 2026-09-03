module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/count_bytes_remaining.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `value_to_binary_string(val)` at line 22.
pub fn ruby_count_bytes_remaining_l22_d1_value_to_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby method `read_and_return_value(io)` at line 26.
pub fn ruby_count_bytes_remaining_l26_d2_read_and_return_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CountBytesRemaining#read_and_return_value requires an IO value')
	}
	remaining := if args[0].type_name == 'Integer' {
		args[0].as_int() or { panic(err) }
	} else {
		(args[0].attribute('num_bytes_remaining') or {
			panic('IO value has no num_bytes_remaining attribute')
		}).i64()
	}
	return brew_runtime.int_value(remaining)
}

// Ruby method `sensible_default` at line 30.
pub fn ruby_count_bytes_remaining_l30_d3_sensible_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(0)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/base_primitive'
// 2:
// 3: module BinData
// 4:   # Counts the number of bytes remaining in the input stream from the current
// 5:   # position to the end of the stream.  This only makes sense for seekable
// 6:   # streams.
// 7:   #
// 8:   #   require 'bindata'
// 9:   #
// 10:   #   class A < BinData::Record
// 11:   #     count_bytes_remaining :bytes_remaining
// 12:   #     string :all_data, read_length: :bytes_remaining
// 13:   #   end
// 14:   #
// 15:   #   obj = A.read("abcdefghij")
// 16:   #   obj.all_data #=> "abcdefghij"
// 17:   #
// 18:   class CountBytesRemaining < BinData::BasePrimitive
// 19:     #---------------
// 20:     private
// 21:
// 22:     def value_to_binary_string(val)
// 23:       ""
// 24:     end
// 25:
// 26:     def read_and_return_value(io)
// 27:       io.num_bytes_remaining
// 28:     end
// 29:
// 30:     def sensible_default
// 31:       0
// 32:     end
// 33:   end
// 34: end
