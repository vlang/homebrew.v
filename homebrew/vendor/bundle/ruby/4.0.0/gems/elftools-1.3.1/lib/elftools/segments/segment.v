module segments

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/segment.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :header` at line 7.
pub fn ruby_segment_l7_d1_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 8.
pub fn ruby_segment_l8_d2_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby method `initialize(header, stream, offset_from_vma: nil)` at line 17.
pub fn ruby_segment_l17_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `type` at line 26.
pub fn ruby_segment_l26_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `data` at line 32.
pub fn ruby_segment_l32_d5_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('data', ...args)
}

// Ruby method `readable?` at line 39.
pub fn ruby_segment_l39_d6_readable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('readable?', ...args)
}

// Ruby method `writable?` at line 45.
pub fn ruby_segment_l45_d7_writable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writable?', ...args)
}

// Ruby method `executable?` at line 51.
pub fn ruby_segment_l51_d8_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module ELFTools
// 4:   module Segments
// 5:     # Base class of segments.
// 6:     class Segment
// 7:       attr_reader :header # @return [ELFTools::Structs::ELF32_Phdr, ELFTools::Structs::ELF64_Phdr] Program header.
// 8:       attr_reader :stream # @return [#pos=, #read] Streaming object.
// 9:
// 10:       # Instantiate a {Segment} object.
// 11:       # @param [ELFTools::Structs::ELF32_Phdr, ELFTools::Structs::ELF64_Phdr] header
// 12:       #   Program header.
// 13:       # @param [#pos=, #read] stream
// 14:       #   Streaming object.
// 15:       # @param [Method] offset_from_vma
// 16:       #   The method to get offset of file, given virtual memory address.
// 17:       def initialize(header, stream, offset_from_vma: nil)
// 18:         @header = header
// 19:         @stream = stream
// 20:         @offset_from_vma = offset_from_vma
// 21:       end
// 22:
// 23:       # Return +header.p_type+ in a simpler way.
// 24:       # @return [Integer]
// 25:       #   The type, meaning of types are defined in {Constants::PT}.
// 26:       def type
// 27:         header.p_type
// 28:       end
// 29:
// 30:       # The content in this segment.
// 31:       # @return [String] The content.
// 32:       def data
// 33:         stream.pos = header.p_offset
// 34:         stream.read(header.p_filesz)
// 35:       end
// 36:
// 37:       # Is this segment readable?
// 38:       # @return [Boolean] True or false.
// 39:       def readable?
// 40:         (header.p_flags & 4) == 4
// 41:       end
// 42:
// 43:       # Is this segment writable?
// 44:       # @return [Boolean] True or false.
// 45:       def writable?
// 46:         (header.p_flags & 2) == 2
// 47:       end
// 48:
// 49:       # Is this segment executable?
// 50:       # @return [Boolean] True or false.
// 51:       def executable?
// 52:         (header.p_flags & 1) == 1
// 53:       end
// 54:     end
// 55:   end
// 56: end
