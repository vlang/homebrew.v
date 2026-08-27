module segments

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/note_segment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `note_start` at line 15.
pub fn ruby_note_segment_l15_d1_note_start(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('note_start', ...args)
}

// Ruby method `note_total_size` at line 21.
pub fn ruby_note_segment_l21_d2_note_total_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('note_total_size', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/note'
// 4: require 'elftools/segments/segment'
// 5:
// 6: module ELFTools
// 7:   module Segments
// 8:     # Class of note segment.
// 9:     class NoteSegment < Segment
// 10:       # Load note related methods.
// 11:       include ELFTools::Note
// 12:
// 13:       # Address offset of notes start.
// 14:       # @return [Integer] The offset.
// 15:       def note_start
// 16:         header.p_offset
// 17:       end
// 18:
// 19:       # The total size of notes in this segment.
// 20:       # @return [Integer] The size.
// 21:       def note_total_size
// 22:         header.p_filesz
// 23:       end
// 24:     end
// 25:   end
// 26: end
