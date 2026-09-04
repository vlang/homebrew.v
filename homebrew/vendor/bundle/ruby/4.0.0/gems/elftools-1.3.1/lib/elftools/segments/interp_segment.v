module segments

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/interp_segment.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn interpreter_name(data []u8) string {
	if data.len > 0 && data.last() == 0 {
		return data[..data.len - 1].bytestr()
	}
	return data.bytestr()
}

// Ruby method `interp_name` at line 15.
pub fn ruby_interp_segment_l15_d1_interp_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	return ruby.string_value(interpreter_name(args[0].as_string().bytes()))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/segments/segment'
// 4:
// 5: module ELFTools
// 6:   module Segments
// 7:     # For DT_INTERP segment, knows how to get path of
// 8:     # ELF interpreter.
// 9:     class InterpSegment < Segment
// 10:       # Get the path of interpreter.
// 11:       # @return [String] Path to the interpreter.
// 12:       # @example
// 13:       #   interp_segment.interp_name
// 14:       #   #=> '/lib64/ld-linux-x86-64.so.2'
// 15:       def interp_name
// 16:         data[0..-2] # remove last null byte
// 17:       end
// 18:     end
// 19:   end
// 20: end
