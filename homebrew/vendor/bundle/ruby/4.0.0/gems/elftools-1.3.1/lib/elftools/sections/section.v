module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :header` at line 8.
pub fn ruby_section_l8_d1_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 9.
pub fn ruby_section_l9_d2_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby method `initialize(header, stream, offset_from_vma: nil, strtab: nil, **_kwargs)` at line 22.
pub fn ruby_section_l22_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `type` at line 32.
pub fn ruby_section_l32_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `name` at line 38.
pub fn ruby_section_l38_d5_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `data` at line 44.
pub fn ruby_section_l44_d6_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('data', ...args)
}

// Ruby method `null?` at line 51.
pub fn ruby_section_l51_d7_null(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('null?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/constants'
// 4: module ELFTools
// 5:   module Sections
// 6:     # Base class of sections.
// 7:     class Section
// 8:       attr_reader :header # @return [ELFTools::Structs::ELF_Shdr] Section header.
// 9:       attr_reader :stream # @return [#pos=, #read] Streaming object.
// 10:
// 11:       # Instantiate a {Section} object.
// 12:       # @param [ELFTools::Structs::ELF_Shdr] header
// 13:       #   The section header object.
// 14:       # @param [#pos=, #read] stream
// 15:       #   The streaming object for further dump.
// 16:       # @param [ELFTools::Sections::StrTabSection, Proc] strtab
// 17:       #   The string table object. For fetching section names.
// 18:       #   If +Proc+ if given, it will call at the first
// 19:       #   time access +#name+.
// 20:       # @param [Method] offset_from_vma
// 21:       #   The method to get offset of file, given virtual memory address.
// 22:       def initialize(header, stream, offset_from_vma: nil, strtab: nil, **_kwargs)
// 23:         @header = header
// 24:         @stream = stream
// 25:         @strtab = strtab
// 26:         @offset_from_vma = offset_from_vma
// 27:       end
// 28:
// 29:       # Return +header.sh_type+ in a simpler way.
// 30:       # @return [Integer]
// 31:       #   The type, meaning of types are defined in {Constants::SHT}.
// 32:       def type
// 33:         header.sh_type.to_i
// 34:       end
// 35:
// 36:       # Get name of this section.
// 37:       # @return [String] The name.
// 38:       def name
// 39:         @name ||= @strtab.call.name_at(header.sh_name)
// 40:       end
// 41:
// 42:       # Fetch data of this section.
// 43:       # @return [String] Data.
// 44:       def data
// 45:         stream.pos = header.sh_offset
// 46:         stream.read(header.sh_size)
// 47:       end
// 48:
// 49:       # Is this a null section?
// 50:       # @return [Boolean] No it's not.
// 51:       def null?
// 52:         false
// 53:       end
// 54:     end
// 55:   end
// 56: end
