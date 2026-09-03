module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/str_tab_section.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn string_table_name_at(data []u8, section_offset int, offset int) !string {
	start := section_offset + offset
	if start < 0 || start > data.len {
		return error('string table offset is outside the stream')
	}
	mut finish := start
	for finish < data.len && data[finish] != 0 {
		finish++
	}
	return data[start..finish].bytestr()
}

// Ruby method `name_at(offset)` at line 16.
pub fn ruby_str_tab_section_l16_d1_name_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('StrTabSection#name_at requires stream data and offset') }
	section_offset := if args.len > 2 { int(args[1].as_int() or { panic(err) }) } else { 0 }
	offset_index := if args.len > 2 { 2 } else { 1 }
	offset := int(args[offset_index].as_int() or { panic(err) })
	return brew_runtime.string_value(string_table_name_at(args[0].as_string().bytes(), section_offset, offset) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/sections/section'
// 4: require 'elftools/util'
// 5:
// 6: module ELFTools
// 7:   module Sections
// 8:     # Class of string table section.
// 9:     # Usually for section .strtab and .dynstr,
// 10:     # which record names.
// 11:     class StrTabSection < Section
// 12:       # Return the section or symbol name.
// 13:       # @param [Integer] offset
// 14:       #   Usually from +shdr.sh_name+ or +sym.st_name+.
// 15:       # @return [String] The name without null bytes.
// 16:       def name_at(offset)
// 17:         Util.cstring(stream, header.sh_offset + offset)
// 18:       end
// 19:     end
// 20:   end
// 21: end
