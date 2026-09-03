module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/note_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `note_start` at line 16.
pub fn ruby_note_section_l16_d1_note_start(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('NoteSection#note_start requires a header')
	}
	return brew_runtime.int_value((args[0].attribute('sh_offset') or {
		panic('section header has no sh_offset')
	}).i64())
}

// Ruby method `note_total_size` at line 22.
pub fn ruby_note_section_l22_d2_note_total_size(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('NoteSection#note_total_size requires a header')
	}
	return brew_runtime.int_value((args[0].attribute('sh_size') or {
		panic('section header has no sh_size')
	}).i64())
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/note'
// 4: require 'elftools/sections/section'
// 5:
// 6: module ELFTools
// 7:   module Sections
// 8:     # Class of note section.
// 9:     # Note section records notes
// 10:     class NoteSection < Section
// 11:       # Load note related methods.
// 12:       include ELFTools::Note
// 13:
// 14:       # Address offset of notes start.
// 15:       # @return [Integer] The offset.
// 16:       def note_start
// 17:         header.sh_offset
// 18:       end
// 19:
// 20:       # The total size of notes in this section.
// 21:       # @return [Integer] The size.
// 22:       def note_total_size
// 23:         header.sh_size
// 24:       end
// 25:     end
// 26:   end
// 27: end
