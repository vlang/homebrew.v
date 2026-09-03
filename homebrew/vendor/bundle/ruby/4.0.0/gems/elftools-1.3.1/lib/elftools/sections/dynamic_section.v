module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/dynamic_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tag_start` at line 17.
pub fn ruby_dynamic_section_l17_d1_tag_start(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('DynamicSection#tag_start requires a header') }
	offset := if args[0].type_name == 'Integer' {
		args[0].as_int() or { panic(err) }
	} else {
		(args[0].attribute('sh_offset') or { '0' }).i64()
	}
	return brew_runtime.int_value(offset)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/dynamic'
// 4: require 'elftools/sections/section'
// 5:
// 6: module ELFTools
// 7:   module Sections
// 8:     # Class for dynamic table section.
// 9:     #
// 10:     # This section should always be named .dynamic.
// 11:     # This class knows how to get the list of dynamic tags.
// 12:     class DynamicSection < Section
// 13:       include ELFTools::Dynamic
// 14:
// 15:       # Get the start address of tags.
// 16:       # @return [Integer] Start address of tags.
// 17:       def tag_start
// 18:         header.sh_offset
// 19:       end
// 20:     end
// 21:   end
// 22: end
