module segments

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/segments/load_segment.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElfLoadSegment {
pub:
	header ElfSegmentHeader
}

pub fn (segment ElfLoadSegment) file_head() i64 {
	return segment.header.p_offset
}

pub fn (segment ElfLoadSegment) size() i64 {
	return segment.header.p_filesz
}

pub fn (segment ElfLoadSegment) file_tail() i64 {
	return segment.file_head() + segment.size()
}

pub fn (segment ElfLoadSegment) mem_head() i64 {
	return segment.header.p_vaddr
}

pub fn (segment ElfLoadSegment) mem_size() i64 {
	return segment.header.p_memsz
}

pub fn (segment ElfLoadSegment) mem_tail() i64 {
	return segment.mem_head() + segment.mem_size()
}

pub fn (segment ElfLoadSegment) offset_in(offset i64, size i64) bool {
	return segment.file_head() <= offset && offset + size < segment.file_tail()
}

pub fn (segment ElfLoadSegment) offset_to_vma(offset i64) i64 {
	return offset - segment.file_head() + segment.header.p_vaddr
}

pub fn (segment ElfLoadSegment) vma_in(vma i64, size i64) bool {
	return vma >= (segment.header.p_vaddr & -segment.header.p_align) && vma + size <= segment.mem_tail()
}

pub fn (segment ElfLoadSegment) vma_to_offset(vma i64) i64 {
	return vma - segment.header.p_vaddr + segment.header.p_offset
}

fn elf_load_segment(value ruby.Value) ElfLoadSegment {
	return ElfLoadSegment{
		header: elf_segment_header(value)
	}
}

// Ruby method `file_head` at line 13.
pub fn ruby_load_segment_l13_d1_file_head(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#file_head requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).file_head())
}

// Ruby method `size` at line 20.
pub fn ruby_load_segment_l20_d2_size(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#size requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).size())
}

// Ruby method `file_tail` at line 27.
pub fn ruby_load_segment_l27_d3_file_tail(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#file_tail requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).file_tail())
}

// Ruby method `mem_head` at line 34.
pub fn ruby_load_segment_l34_d4_mem_head(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#mem_head requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).mem_head())
}

// Ruby method `mem_size` at line 41.
pub fn ruby_load_segment_l41_d5_mem_size(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#mem_size requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).mem_size())
}

// Ruby method `mem_tail` at line 48.
pub fn ruby_load_segment_l48_d6_mem_tail(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('LoadSegment#mem_tail requires a receiver') }
	return ruby.int_value(elf_load_segment(args[0]).mem_tail())
}

// Ruby method `offset_in?(offset, size = 0)` at line 58.
pub fn ruby_load_segment_l58_d7_offset_in(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('LoadSegment#offset_in? requires a receiver and offset') }
	size := if args.len >= 3 { args[2].as_int() or { panic(err) } } else { i64(0) }
	return ruby.bool_value(elf_load_segment(args[0]).offset_in(args[1].as_int() or {
		panic(err)
	}, size))
}

// Ruby method `offset_to_vma(offset)` at line 66.
pub fn ruby_load_segment_l66_d8_offset_to_vma(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('LoadSegment#offset_to_vma requires a receiver and offset') }
	return ruby.int_value(elf_load_segment(args[0]).offset_to_vma(args[1].as_int() or {
		panic(err)
	}))
}

// Ruby method `vma_in?(vma, size = 0)` at line 77.
pub fn ruby_load_segment_l77_d9_vma_in(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('LoadSegment#vma_in? requires a receiver and virtual address') }
	size := if args.len >= 3 { args[2].as_int() or { panic(err) } } else { i64(0) }
	return ruby.bool_value(elf_load_segment(args[0]).vma_in(args[1].as_int() or {
		panic(err)
	}, size))
}

// Ruby method `vma_to_offset(vma)` at line 86.
pub fn ruby_load_segment_l86_d10_vma_to_offset(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('LoadSegment#vma_to_offset requires a receiver and virtual address') }
	return ruby.int_value(elf_load_segment(args[0]).vma_to_offset(args[1].as_int() or {
		panic(err)
	}))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/segments/segment'
// 4:
// 5: module ELFTools
// 6:   module Segments
// 7:     # For DT_LOAD segment.
// 8:     # Able to query between file offset and virtual memory address.
// 9:     class LoadSegment < Segment
// 10:       # Returns the start of this segment.
// 11:       # @return [Integer]
// 12:       #   The file offset.
// 13:       def file_head
// 14:         header.p_offset.to_i
// 15:       end
// 16:
// 17:       # Returns size in file.
// 18:       # @return [Integer]
// 19:       #   The size.
// 20:       def size
// 21:         header.p_filesz.to_i
// 22:       end
// 23:
// 24:       # Returns the end of this segment.
// 25:       # @return [Integer]
// 26:       #   The file offset.
// 27:       def file_tail
// 28:         file_head + size
// 29:       end
// 30:
// 31:       # Returns the start virtual address of this segment.
// 32:       # @return [Integer]
// 33:       #   The vma.
// 34:       def mem_head
// 35:         header.p_vaddr.to_i
// 36:       end
// 37:
// 38:       # Returns size in memory.
// 39:       # @return [Integer]
// 40:       #   The size.
// 41:       def mem_size
// 42:         header.p_memsz.to_i
// 43:       end
// 44:
// 45:       # Returns the end virtual address of this segment.
// 46:       # @return [Integer]
// 47:       #   The vma.
// 48:       def mem_tail
// 49:         mem_head + mem_size
// 50:       end
// 51:
// 52:       # Query if the given file offset located in this segment.
// 53:       # @param [Integer] offset
// 54:       #   File offset.
// 55:       # @param [Integer] size
// 56:       #   Size.
// 57:       # @return [Boolean]
// 58:       def offset_in?(offset, size = 0)
// 59:         file_head <= offset && offset + size < file_tail
// 60:       end
// 61:
// 62:       # Convert file offset into virtual memory address.
// 63:       # @param [Integer] offset
// 64:       #   File offset.
// 65:       # @return [Integer]
// 66:       def offset_to_vma(offset)
// 67:         # XXX: What if file_head is not aligned with p_vaddr (which is invalid according to ELF spec)?
// 68:         offset - file_head + header.p_vaddr
// 69:       end
// 70:
// 71:       # Query if the given virtual memory address located in this segment.
// 72:       # @param [Integer] vma
// 73:       #   Virtual memory address.
// 74:       # @param [Integer] size
// 75:       #   Size.
// 76:       # @return [Boolean]
// 77:       def vma_in?(vma, size = 0)
// 78:         vma >= (header.p_vaddr & -header.p_align) &&
// 79:           vma + size <= mem_tail
// 80:       end
// 81:
// 82:       # Convert virtual memory address into file offset.
// 83:       # @param [Integer] vma
// 84:       #   Virtual memory address.
// 85:       # @return [Integer]
// 86:       def vma_to_offset(vma)
// 87:         vma - header.p_vaddr + header.p_offset
// 88:       end
// 89:     end
// 90:   end
// 91: end
