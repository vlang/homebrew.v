module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/relocation_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `rela?` at line 14.
pub fn ruby_relocation_section_l14_d1_rela(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rela?', ...args)
}

// Ruby method `num_relocations` at line 20.
pub fn ruby_relocation_section_l20_d2_num_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('num_relocations', ...args)
}

// Ruby method `relocation_at(n)` at line 31.
pub fn ruby_relocation_section_l31_d3_relocation_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocation_at', ...args)
}

// Ruby method `each_relocations(&block)` at line 45.
pub fn ruby_relocation_section_l45_d4_each_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_relocations', ...args)
}

// Ruby method `relocations` at line 56.
pub fn ruby_relocation_section_l56_d5_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocations', ...args)
}

// Ruby method `create_relocation(n)` at line 62.
pub fn ruby_relocation_section_l62_d6_create_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_relocation', ...args)
}

// Ruby attr_reader `attr_reader :header` at line 78.
pub fn ruby_relocation_section_l78_d7_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 79.
pub fn ruby_relocation_section_l79_d8_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby method `initialize(header, stream)` at line 82.
pub fn ruby_relocation_section_l82_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `r_info_sym` at line 90.
pub fn ruby_relocation_section_l90_d10_r_info_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('r_info_sym', ...args)
}

// Ruby alias `alias symbol_index r_info_sym` at line 93.
pub fn ruby_relocation_section_l93_d11_symbol_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbol_index', ...args)
}

// Ruby method `r_info_type` at line 98.
pub fn ruby_relocation_section_l98_d12_r_info_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('r_info_type', ...args)
}

// Ruby alias `alias type r_info_type` at line 101.
pub fn ruby_relocation_section_l101_d13_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `mask_bit` at line 105.
pub fn ruby_relocation_section_l105_d14_mask_bit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mask_bit', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/constants'
// 4: require 'elftools/sections/section'
// 5: require 'elftools/structs'
// 6:
// 7: module ELFTools
// 8:   module Sections
// 9:     # Class of note section.
// 10:     # Note section records notes
// 11:     class RelocationSection < Section
// 12:       # Is this relocation a RELA or REL type.
// 13:       # @return [Boolean] If is RELA.
// 14:       def rela?
// 15:         header.sh_type == Constants::SHT_RELA
// 16:       end
// 17:
// 18:       # Number of relocations in this section.
// 19:       # @return [Integer] The number.
// 20:       def num_relocations
// 21:         header.sh_size / header.sh_entsize
// 22:       end
// 23:
// 24:       # Acquire the +n+-th relocation, 0-based.
// 25:       #
// 26:       # relocations are lazy loaded.
// 27:       # @param [Integer] n The index.
// 28:       # @return [ELFTools::Relocation, nil]
// 29:       #   The target relocation.
// 30:       #   If +n+ is out of bound, +nil+ is returned.
// 31:       def relocation_at(n)
// 32:         @relocations ||= LazyArray.new(num_relocations, &method(:create_relocation))
// 33:         @relocations[n]
// 34:       end
// 35:
// 36:       # Iterate all relocations.
// 37:       #
// 38:       # All relocations are lazy loading, the relocation
// 39:       # only be created whenever accessing it.
// 40:       # @yieldparam [ELFTools::Relocation] rel A relocation object.
// 41:       # @yieldreturn [void]
// 42:       # @return [Enumerator<ELFTools::Relocation>, Array<ELFTools::Relocation>]
// 43:       #   If block is not given, an enumerator will be returned.
// 44:       #   Otherwise, the whole relocations will be returned.
// 45:       def each_relocations(&block)
// 46:         return enum_for(:each_relocations) unless block_given?
// 47:
// 48:         Array.new(num_relocations) do |i|
// 49:           relocation_at(i).tap(&block)
// 50:         end
// 51:       end
// 52:
// 53:       # Simply use {#relocations} to get all relocations.
// 54:       # @return [Array<ELFTools::Relocation>]
// 55:       #   Whole relocations.
// 56:       def relocations
// 57:         each_relocations.to_a
// 58:       end
// 59:
// 60:       private
// 61:
// 62:       def create_relocation(n)
// 63:         stream.pos = header.sh_offset + n * header.sh_entsize
// 64:         klass = rela? ? Structs::ELF_Rela : Structs::ELF_Rel
// 65:         rel = klass.new(endian: header.class.self_endian, offset: stream.pos)
// 66:         rel.elf_class = header.elf_class
// 67:         rel.read(stream)
// 68:         Relocation.new(rel, stream)
// 69:       end
// 70:     end
// 71:   end
// 72:
// 73:   # A relocation entry.
// 74:   #
// 75:   # Can be either a REL or RELA relocation.
// 76:   # XXX: move this to an independent file?
// 77:   class Relocation
// 78:     attr_reader :header # @return [ELFTools::Structs::ELF_Rel, ELFTools::Structs::ELF_Rela] Rel(a) header.
// 79:     attr_reader :stream # @return [#pos=, #read] Streaming object.
// 80:
// 81:     # Instantiate a {Relocation} object.
// 82:     def initialize(header, stream)
// 83:       @header = header
// 84:       @stream = stream
// 85:     end
// 86:
// 87:     # +r_info+ contains sym and type, use two methods
// 88:     # to access them easier.
// 89:     # @return [Integer] sym infor.
// 90:     def r_info_sym
// 91:       header.r_info >> mask_bit
// 92:     end
// 93:     alias symbol_index r_info_sym
// 94:
// 95:     # +r_info+ contains sym and type, use two methods
// 96:     # to access them easier.
// 97:     # @return [Integer] type infor.
// 98:     def r_info_type
// 99:       header.r_info & ((1 << mask_bit) - 1)
// 100:     end
// 101:     alias type r_info_type
// 102:
// 103:     private
// 104:
// 105:     def mask_bit
// 106:       header.elf_class == 32 ? 8 : 32
// 107:     end
// 108:   end
// 109: end
