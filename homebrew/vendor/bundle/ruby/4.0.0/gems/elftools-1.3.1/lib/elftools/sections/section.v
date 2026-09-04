module sections

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/section.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElfSectionHeader {
pub:
	sh_type   int
	sh_name   int
	sh_offset int
	sh_size   int
}

pub struct ElfSection {
pub:
	header        ElfSectionHeader
	stream        []u8
	string_table  []u8
	strtab_offset int
}

pub fn (section ElfSection) section_type() int {
	return section.header.sh_type
}

pub fn (section ElfSection) name() !string {
	return string_table_name_at(section.string_table, section.strtab_offset, section.header.sh_name)
}

pub fn (section ElfSection) data() ![]u8 {
	start := section.header.sh_offset
	end := start + section.header.sh_size
	if start < 0 || end < start || end > section.stream.len {
		return error('section data is outside the stream')
	}
	return section.stream[start..end].clone()
}

fn elf_section_header(value ruby.Value) ElfSectionHeader {
	return ElfSectionHeader{
		sh_type: (value.attribute('sh_type') or { '0' }).int()
		sh_name: (value.attribute('sh_name') or { '0' }).int()
		sh_offset: (value.attribute('sh_offset') or { '0' }).int()
		sh_size: (value.attribute('sh_size') or { '0' }).int()
	}
}

fn elf_section_value(section ElfSection) ruby.Value {
	return ruby.structured_value('ELFTools::Sections::Section', 'Section', {
		'sh_type':       section.header.sh_type.str()
		'sh_name':       section.header.sh_name.str()
		'sh_offset':     section.header.sh_offset.str()
		'sh_size':       section.header.sh_size.str()
		'stream':        section.stream.bytestr()
		'string_table':  section.string_table.bytestr()
		'strtab_offset': section.strtab_offset.str()
	})
}

fn elf_section_from_value(value ruby.Value) ElfSection {
	return ElfSection{
		header: elf_section_header(value)
		stream: (value.attribute('stream') or { '' }).bytes()
		string_table: (value.attribute('string_table') or { '' }).bytes()
		strtab_offset: (value.attribute('strtab_offset') or { '0' }).int()
	}
}

// Ruby attr_reader `attr_reader :header` at line 8.
pub fn ruby_section_l8_d1_header(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Section#header requires a receiver')
	}
	header := elf_section_from_value(args[0]).header
	return ruby.structured_value('ELF_Shdr', '', {
		'sh_type':   header.sh_type.str()
		'sh_name':   header.sh_name.str()
		'sh_offset': header.sh_offset.str()
		'sh_size':   header.sh_size.str()
	})
}

// Ruby attr_reader `attr_reader :stream` at line 9.
pub fn ruby_section_l9_d2_stream(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Section#stream requires a receiver')
	}
	return ruby.string_value(args[0].attribute('stream') or { panic('section has no stream') })
}

// Ruby method `initialize(header, stream, offset_from_vma: nil, strtab: nil, **_kwargs)` at line 22.
pub fn ruby_section_l22_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Section#initialize requires a header and stream')
	}
	section := ElfSection{
		header: elf_section_header(args[0])
		stream: args[1].as_string().bytes()
		string_table: if args.len >= 3 { args[2].as_string().bytes() } else { []u8{} }
		strtab_offset: if args.len >= 4 { int(args[3].as_int() or { panic(err) }) } else { 0 }
	}
	return elf_section_value(section)
}

// Ruby method `type` at line 32.
pub fn ruby_section_l32_d4_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Section#type requires a receiver')
	}
	return ruby.int_value(elf_section_from_value(args[0]).section_type())
}

// Ruby method `name` at line 38.
pub fn ruby_section_l38_d5_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Section#name requires a receiver')
	}
	return ruby.string_value(elf_section_from_value(args[0]).name() or { panic(err) })
}

// Ruby method `data` at line 44.
pub fn ruby_section_l44_d6_data(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Section#data requires a receiver')
	}
	return ruby.string_value(elf_section_from_value(args[0]).data() or { panic(err) }.bytestr())
}

// Ruby method `null?` at line 51.
pub fn ruby_section_l51_d7_null(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(false)
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
