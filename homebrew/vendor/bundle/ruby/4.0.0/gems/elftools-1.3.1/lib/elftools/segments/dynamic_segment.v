module segments

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/dynamic_segment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tag_start` at line 15.
pub fn ruby_dynamic_segment_l15_d1_tag_start(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('DynamicSegment#tag_start requires a header') }
	offset := if args[0].type_name == 'Integer' {
		args[0].as_int() or { panic(err) }
	} else {
		(args[0].attribute('p_offset') or { '0' }).i64()
	}
	return ruby.int_value(offset)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/segments/segment'
// 4: require 'elftools/dynamic'
// 5:
// 6: module ELFTools
// 7:   module Segments
// 8:     # Class for dynamic table segment.
// 9:     #
// 10:     # This class knows how to get the list of dynamic tags.
// 11:     class DynamicSegment < Segment
// 12:       include Dynamic # rock!
// 13:       # Get the start address of tags.
// 14:       # @return [Integer] Start address of tags.
// 15:       def tag_start
// 16:         header.p_offset
// 17:       end
// 18:     end
// 19:   end
// 20: end
