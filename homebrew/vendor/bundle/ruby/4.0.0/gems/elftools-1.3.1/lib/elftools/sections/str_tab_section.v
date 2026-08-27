module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/str_tab_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `name_at(offset)` at line 16.
pub fn ruby_str_tab_section_l16_d1_name_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name_at', ...args)
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
