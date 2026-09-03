module segments

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/segment.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElfSegmentHeader {
pub:
	p_type   int
	p_offset i64
	p_filesz i64
	p_flags  int
	p_vaddr  i64
	p_memsz  i64
	p_align  i64
}

pub struct ElfSegment {
pub:
	header ElfSegmentHeader
	stream []u8
}

pub fn (segment ElfSegment) data() ![]u8 {
	start := segment.header.p_offset
	end := start + segment.header.p_filesz
	if start < 0 || end < start || end > segment.stream.len {
		return error('segment data is outside the stream')
	}
	return segment.stream[int(start)..int(end)].clone()
}

pub fn (segment ElfSegment) readable() bool {
	return segment.header.p_flags & 4 == 4
}

pub fn (segment ElfSegment) writable() bool {
	return segment.header.p_flags & 2 == 2
}

pub fn (segment ElfSegment) executable() bool {
	return segment.header.p_flags & 1 == 1
}

fn elf_segment_header(value brew_runtime.Value) ElfSegmentHeader {
	return ElfSegmentHeader{
		p_type: (value.attribute('p_type') or { '0' }).int()
		p_offset: (value.attribute('p_offset') or { '0' }).i64()
		p_filesz: (value.attribute('p_filesz') or { '0' }).i64()
		p_flags: (value.attribute('p_flags') or { '0' }).int()
		p_vaddr: (value.attribute('p_vaddr') or { '0' }).i64()
		p_memsz: (value.attribute('p_memsz') or { '0' }).i64()
		p_align: (value.attribute('p_align') or { '0' }).i64()
	}
}

fn elf_segment_value(segment ElfSegment) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Segments::Segment', 'Segment', {
		'p_type':   segment.header.p_type.str()
		'p_offset': segment.header.p_offset.str()
		'p_filesz': segment.header.p_filesz.str()
		'p_flags':  segment.header.p_flags.str()
		'p_vaddr':  segment.header.p_vaddr.str()
		'p_memsz':  segment.header.p_memsz.str()
		'p_align':  segment.header.p_align.str()
		'stream':   segment.stream.bytestr()
	})
}

fn elf_segment_from_value(value brew_runtime.Value) ElfSegment {
	return ElfSegment{
		header: elf_segment_header(value)
		stream: (value.attribute('stream') or { '' }).bytes()
	}
}

// Ruby attr_reader `attr_reader :header` at line 7.
pub fn ruby_segment_l7_d1_header(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#header requires a receiver')
	}
	header := elf_segment_from_value(args[0]).header
	return brew_runtime.structured_value('ELF_Phdr', '', {
		'p_type':   header.p_type.str()
		'p_offset': header.p_offset.str()
		'p_filesz': header.p_filesz.str()
		'p_flags':  header.p_flags.str()
		'p_vaddr':  header.p_vaddr.str()
		'p_memsz':  header.p_memsz.str()
		'p_align':  header.p_align.str()
	})
}

// Ruby attr_reader `attr_reader :stream` at line 8.
pub fn ruby_segment_l8_d2_stream(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#stream requires a receiver')
	}
	return brew_runtime.string_value(args[0].attribute('stream') or { panic('segment has no stream') })
}

// Ruby method `initialize(header, stream, offset_from_vma: nil)` at line 17.
pub fn ruby_segment_l17_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Segment#initialize requires a header and stream')
	}
	return elf_segment_value(ElfSegment{
		header: elf_segment_header(args[0])
		stream: args[1].as_string().bytes()
	})
}

// Ruby method `type` at line 26.
pub fn ruby_segment_l26_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#type requires a receiver')
	}
	return brew_runtime.int_value(elf_segment_from_value(args[0]).header.p_type)
}

// Ruby method `data` at line 32.
pub fn ruby_segment_l32_d5_data(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#data requires a receiver')
	}
	return brew_runtime.string_value(elf_segment_from_value(args[0]).data() or { panic(err) }.bytestr())
}

// Ruby method `readable?` at line 39.
pub fn ruby_segment_l39_d6_readable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#readable? requires a receiver')
	}
	return brew_runtime.bool_value(elf_segment_from_value(args[0]).readable())
}

// Ruby method `writable?` at line 45.
pub fn ruby_segment_l45_d7_writable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#writable? requires a receiver')
	}
	return brew_runtime.bool_value(elf_segment_from_value(args[0]).writable())
}

// Ruby method `executable?` at line 51.
pub fn ruby_segment_l51_d8_executable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Segment#executable? requires a receiver')
	}
	return brew_runtime.bool_value(elf_segment_from_value(args[0]).executable())
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
