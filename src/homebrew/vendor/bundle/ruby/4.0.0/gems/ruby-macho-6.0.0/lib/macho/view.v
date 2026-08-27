module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/view.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :macho_file` at line 7.
pub fn ruby_view_l7_d1_macho_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macho_file', ...args)
}

// Ruby attr_reader `attr_reader :raw_data` at line 10.
pub fn ruby_view_l10_d2_raw_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_data', ...args)
}

// Ruby attr_reader `attr_reader :endianness` at line 13.
pub fn ruby_view_l13_d3_endianness(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('endianness', ...args)
}

// Ruby attr_reader `attr_reader :offset` at line 16.
pub fn ruby_view_l16_d4_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offset', ...args)
}

// Ruby method `initialize(macho_file, raw_data, endianness, offset)` at line 23.
pub fn ruby_view_l23_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_h` at line 31.
pub fn ruby_view_l31_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `inspect` at line 38.
pub fn ruby_view_l38_d7_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A representation of some unspecified Mach-O data.
// 5:   class MachOView
// 6:     # @return [MachOFile] that this view belongs to
// 7:     attr_reader :macho_file
// 8:
// 9:     # @return [String] the raw Mach-O data
// 10:     attr_reader :raw_data
// 11:
// 12:     # @return [Symbol] the endianness of the data (`:big` or `:little`)
// 13:     attr_reader :endianness
// 14:
// 15:     # @return [Integer] the offset of the relevant data (in {#raw_data})
// 16:     attr_reader :offset
// 17:
// 18:     # Creates a new MachOView.
// 19:     # @param macho_file [MachOFile] the file this view slice is from
// 20:     # @param raw_data [String] the raw Mach-O data
// 21:     # @param endianness [Symbol] the endianness of the data
// 22:     # @param offset [Integer] the offset of the relevant data
// 23:     def initialize(macho_file, raw_data, endianness, offset)
// 24:       @macho_file = macho_file
// 25:       @raw_data = raw_data
// 26:       @endianness = endianness
// 27:       @offset = offset
// 28:     end
// 29:
// 30:     # @return [Hash] a hash representation of this {MachOView}.
// 31:     def to_h
// 32:       {
// 33:         "endianness" => endianness,
// 34:         "offset" => offset,
// 35:       }
// 36:     end
// 37:
// 38:     def inspect
// 39:       "#<#{self.class}:0x#{(object_id << 1).to_s(16)} @endianness=#{@endianness.inspect}, @offset=#{@offset.inspect}, length=#{@raw_data.length}>"
// 40:     end
// 41:   end
// 42: end
