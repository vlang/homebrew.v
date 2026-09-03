module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/relocation_section.rb`.
// The original source is retained below until every stub has a typed V body.
const sht_rela = u32(4)

pub struct ElfRelocationHeader {
pub:
	r_offset   u64
	r_info     u64
	r_addend   i64
	has_addend bool
	offset     u64
	elf_class  int
}

pub struct ElfRelocation {
pub:
	header ElfRelocationHeader
	stream []u8
}

pub struct RelocationSection {
pub:
	header ElfTableSectionHeader
	stream []u8
}

pub fn (section RelocationSection) is_rela() bool {
	return section.header.sh_type == sht_rela
}

pub fn (section RelocationSection) num_relocations() !int {
	if section.header.sh_entsize == 0 {
		return error('relocation entry size is zero')
	}
	count_u64 := section.header.sh_size / section.header.sh_entsize
	count := int(count_u64)
	if count < 0 || u64(count) != count_u64 {
		return error('relocation count does not fit a V array')
	}
	return count
}

fn signed_table_u32(value u32) i64 {
	return if value & 0x80000000 != 0 { i64(value) - 0x100000000 } else { i64(value) }
}

fn signed_table_u64(value u64) i64 {
	return i64(value)
}

pub fn (section RelocationSection) create_relocation(n int) !ElfRelocation {
	count := section.num_relocations()!
	if n < 0 || n >= count {
		return error('relocation index ${n} is outside 0..${count}')
	}
	relative_offset := u64(n) * section.header.sh_entsize
	if section.header.sh_offset > u64(section.stream.len) || relative_offset > u64(section.stream.len) - section.header.sh_offset {
		return error('relocation offset is outside the stream')
	}
	offset_u64 := section.header.sh_offset + relative_offset
	offset := int(offset_u64)
	mut header := ElfRelocationHeader{
		offset: offset_u64
		elf_class: section.header.elf_class
		has_addend: section.is_rela()
	}
	match section.header.elf_class {
		32 {
			record_size := if section.is_rela() { 12 } else { 8 }
			if offset + record_size > section.stream.len {
				return error('ELF32 relocation is outside the stream')
			}
			header = ElfRelocationHeader{
				r_offset: read_table_u32(section.stream, offset, section.header.endian)!
				r_info: read_table_u32(section.stream, offset + 4, section.header.endian)!
				r_addend: if section.is_rela() {
					signed_table_u32(read_table_u32(section.stream, offset + 8, section.header.endian)!)} else {
					0}
				has_addend: section.is_rela()
				offset: offset_u64
				elf_class: 32
			}
		}
		64 {
			record_size := if section.is_rela() { 24 } else { 16 }
			if offset + record_size > section.stream.len {
				return error('ELF64 relocation is outside the stream')
			}
			header = ElfRelocationHeader{
				r_offset: read_table_u64(section.stream, offset, section.header.endian)!
				r_info: read_table_u64(section.stream, offset + 8, section.header.endian)!
				r_addend: if section.is_rela() {
					signed_table_u64(read_table_u64(section.stream, offset + 16, section.header.endian)!)} else {
					0}
				has_addend: section.is_rela()
				offset: offset_u64
				elf_class: 64
			}
		}
		else {
			return error('unsupported ELF class ${section.header.elf_class}')
		}
	}
	return ElfRelocation{
		header: header
		stream: section.stream.clone()
	}
}

pub fn (section RelocationSection) relocation_at(n int) ?ElfRelocation {
	if n < 0 || n >= section.num_relocations() or { panic(err) } {
		return none
	}
	return section.create_relocation(n) or { panic(err) }
}

pub fn (section RelocationSection) each_relocations(on_relocation fn(ElfRelocation)) ![]ElfRelocation {
	mut relocations := []ElfRelocation{cap: section.num_relocations()!}
	for i in 0 .. section.num_relocations()! {
		relocation := section.create_relocation(i)!
		relocations << relocation
		on_relocation(relocation)
	}
	return relocations
}

fn ignore_elf_relocation(_ ElfRelocation) {}

pub fn (section RelocationSection) relocations() ![]ElfRelocation {
	return section.each_relocations(ignore_elf_relocation)
}

pub fn (relocation ElfRelocation) mask_bit() int {
	return if relocation.header.elf_class == 32 { 8 } else { 32 }
}

pub fn (relocation ElfRelocation) r_info_sym() u64 {
	return relocation.header.r_info >> relocation.mask_bit()
}

pub fn (relocation ElfRelocation) r_info_type() u64 {
	return relocation.header.r_info & ((u64(1) << relocation.mask_bit()) - 1)
}

fn relocation_section_from_value(value brew_runtime.Value) RelocationSection {
	return RelocationSection{
		header: table_header_from_value(value)
		stream: (value.attribute('stream') or { '' }).bytes()
	}
}

fn relocation_header_value(header ElfRelocationHeader) brew_runtime.Value {
	return brew_runtime.structured_value('ELF_Relocation', '', {
		'r_offset':   header.r_offset.str()
		'r_info':     header.r_info.str()
		'r_addend':   header.r_addend.str()
		'has_addend': header.has_addend.str()
		'offset':     header.offset.str()
		'elf_class':  header.elf_class.str()
	})
}

fn relocation_value(relocation ElfRelocation) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Relocation', 'Relocation', {
		'r_offset':   relocation.header.r_offset.str()
		'r_info':     relocation.header.r_info.str()
		'r_addend':   relocation.header.r_addend.str()
		'has_addend': relocation.header.has_addend.str()
		'offset':     relocation.header.offset.str()
		'elf_class':  relocation.header.elf_class.str()
		'stream':     relocation.stream.bytestr()
	})
}

fn relocation_from_value(value brew_runtime.Value) ElfRelocation {
	return ElfRelocation{
		header: ElfRelocationHeader{
			r_offset: (value.attribute('r_offset') or { '0' }).u64()
			r_info: (value.attribute('r_info') or { '0' }).u64()
			r_addend: (value.attribute('r_addend') or { '0' }).i64()
			has_addend: (value.attribute('has_addend') or { 'false' }).bool()
			offset: (value.attribute('offset') or { '0' }).u64()
			elf_class: (value.attribute('elf_class') or { '64' }).int()
		}
		stream: (value.attribute('stream') or { '' }).bytes()
	}
}

// Ruby method `rela?` at line 14.
pub fn ruby_relocation_section_l14_d1_rela(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('RelocationSection#rela? requires a receiver') }
	return brew_runtime.bool_value(relocation_section_from_value(args[0]).is_rela())
}

// Ruby method `num_relocations` at line 20.
pub fn ruby_relocation_section_l20_d2_num_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('RelocationSection#num_relocations requires a receiver') }
	return brew_runtime.int_value(relocation_section_from_value(args[0]).num_relocations() or {
		panic(err)
	})
}

// Ruby method `relocation_at(n)` at line 31.
pub fn ruby_relocation_section_l31_d3_relocation_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('RelocationSection#relocation_at requires a receiver and index') }
	relocation := relocation_section_from_value(args[0]).relocation_at(int(args[1].as_int() or {
		panic(err)
	})) or { return brew_runtime.object_value('NilClass', 'nil') }
	return relocation_value(relocation)
}

// Ruby method `each_relocations(&block)` at line 45.
pub fn ruby_relocation_section_l45_d4_each_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('RelocationSection#each_relocations requires a receiver') }
	return brew_runtime.array_value(relocation_section_from_value(args[0]).relocations() or {
		panic(err)
	}.map(relocation_value(it)))
}

// Ruby method `relocations` at line 56.
pub fn ruby_relocation_section_l56_d5_relocations(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_relocation_section_l45_d4_each_relocations(...args)
}

// Ruby method `create_relocation(n)` at line 62.
pub fn ruby_relocation_section_l62_d6_create_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('RelocationSection#create_relocation requires a receiver and index') }
	return relocation_value(relocation_section_from_value(args[0]).create_relocation(int(args[1].as_int() or {
		panic(err)
	})) or { panic(err) })
}

// Ruby attr_reader `attr_reader :header` at line 78.
pub fn ruby_relocation_section_l78_d7_header(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Relocation#header requires a receiver') }
	return relocation_header_value(relocation_from_value(args[0]).header)
}

// Ruby attr_reader `attr_reader :stream` at line 79.
pub fn ruby_relocation_section_l79_d8_stream(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Relocation#stream requires a receiver') }
	return brew_runtime.string_value(relocation_from_value(args[0]).stream.bytestr())
}

// Ruby method `initialize(header, stream)` at line 82.
pub fn ruby_relocation_section_l82_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Relocation#initialize requires a header and stream') }
	mut attributes := args[0].attributes.clone()
	attributes['stream'] = args[1].as_string()
	return brew_runtime.structured_value('ELFTools::Relocation', 'Relocation', attributes)
}

// Ruby method `r_info_sym` at line 90.
pub fn ruby_relocation_section_l90_d10_r_info_sym(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Relocation#r_info_sym requires a receiver') }
	return brew_runtime.int_value(relocation_from_value(args[0]).r_info_sym())
}

// Ruby alias `alias symbol_index r_info_sym` at line 93.
pub fn ruby_relocation_section_l93_d11_symbol_index(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_relocation_section_l90_d10_r_info_sym(...args)
}

// Ruby method `r_info_type` at line 98.
pub fn ruby_relocation_section_l98_d12_r_info_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Relocation#r_info_type requires a receiver') }
	return brew_runtime.int_value(relocation_from_value(args[0]).r_info_type())
}

// Ruby alias `alias type r_info_type` at line 101.
pub fn ruby_relocation_section_l101_d13_type(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_relocation_section_l98_d12_r_info_type(...args)
}

// Ruby method `mask_bit` at line 105.
pub fn ruby_relocation_section_l105_d14_mask_bit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Relocation#mask_bit requires a receiver') }
	return brew_runtime.int_value(relocation_from_value(args[0]).mask_bit())
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
