module patchelf

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/mm.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :extend_size` at line 9.
pub fn ruby_mm_l9_d1_extend_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extend_size', ...args)
}

// Ruby attr_reader `attr_reader :threshold` at line 10.
pub fn ruby_mm_l10_d2_threshold(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('threshold', ...args)
}

// Ruby method `initialize(elf)` at line 14.
pub fn ruby_mm_l14_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `malloc(size, &block)` at line 27.
pub fn ruby_mm_l27_d4_malloc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('malloc', ...args)
}

// Ruby method `dispatch!` at line 35.
pub fn ruby_mm_l35_d5_dispatch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dispatch!', ...args)
}

// Ruby method `extended?` at line 57.
pub fn ruby_mm_l57_d6_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extended?', ...args)
}

// Ruby method `extended_offset(off)` at line 66.
pub fn ruby_mm_l66_d7_extended_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extended_offset', ...args)
}

// Ruby method `fgap_method?` at line 75.
pub fn ruby_mm_l75_d8_fgap_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fgap_method?', ...args)
}

// Ruby method `extend_backward?(seg, size = @request_size)` at line 86.
pub fn ruby_mm_l86_d9_extend_backward(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extend_backward?', ...args)
}

// Ruby method `extend_forward?(seg, size = @request_size)` at line 93.
pub fn ruby_mm_l93_d10_extend_forward(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extend_forward?', ...args)
}

// Ruby method `mgap_method?` at line 102.
pub fn ruby_mm_l102_d11_mgap_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mgap_method?', ...args)
}

// Ruby method `find_gap(check_sz: true)` at line 122.
pub fn ruby_mm_l122_d12_find_gap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_gap', ...args)
}

// Ruby method `new_load_method` at line 138.
pub fn ruby_mm_l138_d13_new_load_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_load_method', ...args)
}

// Ruby method `writable?(seg)` at line 142.
pub fn ruby_mm_l142_d14_writable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writable?', ...args)
}

// Ruby method `shift_attributes` at line 147.
pub fn ruby_mm_l147_d15_shift_attributes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift_attributes', ...args)
}

// Ruby method `load_segments` at line 170.
pub fn ruby_mm_l170_d16_load_segments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_segments', ...args)
}

// Ruby method `invoke_callbacks(seg, start)` at line 174.
pub fn ruby_mm_l174_d17_invoke_callbacks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('invoke_callbacks', ...args)
}

// Ruby method `abnormal_elf(msg)` at line 182.
pub fn ruby_mm_l182_d18_abnormal_elf(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abnormal_elf', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'patchelf/helper'
// 4:
// 5: module PatchELF
// 6:   # Memory management, provides malloc/free to allocate LOAD segments.
// 7:   # @private
// 8:   class MM
// 9:     attr_reader :extend_size # @return [Integer] The size extended.
// 10:     attr_reader :threshold # @return [Integer] Where the file start to be extended.
// 11:
// 12:     # Instantiate a {MM} object.
// 13:     # @param [ELFTools::ELFFile] elf
// 14:     def initialize(elf)
// 15:       @elf = elf
// 16:       @request = []
// 17:     end
// 18:
// 19:     # @param [Integer] size
// 20:     # @return [void]
// 21:     # @yieldparam [Integer] off
// 22:     # @yieldparam [Integer] vaddr
// 23:     # @yieldreturn [void]
// 24:     #   One can only do the following things in the block:
// 25:     #   1. Set ELF headers' attributes (with ELFTools)
// 26:     #   2. Invoke {Saver#inline_patch}
// 27:     def malloc(size, &block)
// 28:       raise ArgumentError, 'malloc\'s size most be positive.' if size <= 0
// 29:
// 30:       @request << [size, block]
// 31:     end
// 32:
// 33:     # Let the malloc / free requests be effective.
// 34:     # @return [void]
// 35:     def dispatch!
// 36:       return if @request.empty?
// 37:
// 38:       @request_size = @request.map(&:first).inject(0, :+)
// 39:       # The malloc-ed area must be 'rw-' since the dynamic table will be modified during runtime.
// 40:       # Find all LOADs and calculate their f-gaps and m-gaps.
// 41:       # We prefer f-gap since it doesn't need move the whole binaries.
// 42:       # 1. Find if any f-gap has enough size, and one of the LOAD next to it is 'rw-'.
// 43:       #   - expand (forwardlly), only need to change the attribute of LOAD.
// 44:       # 2. Do 1. again but consider m-gaps instead.
// 45:       #   - expand (forwardlly), need to modify all section headers.
// 46:       # 3. We have to create a new LOAD, now we need to expand the first LOAD for putting new segment header.
// 47:
// 48:       # First of all we check if there're less than two LOADs.
// 49:       abnormal_elf('No LOAD segment found, not an executable.') if load_segments.empty?
// 50:       # TODO: Handle only one LOAD. (be careful if memsz > filesz)
// 51:
// 52:       fgap_method? || mgap_method? || new_load_method
// 53:     end
// 54:
// 55:     # Query if extended.
// 56:     # @return [Boolean]
// 57:     def extended?
// 58:       defined?(@threshold)
// 59:     end
// 60:
// 61:     # Get correct offset after the extension.
// 62:     #
// 63:     # @param [Integer] off
// 64:     # @return [Integer]
// 65:     #   Shifted offset.
// 66:     def extended_offset(off)
// 67:       return off unless defined?(@threshold)
// 68:       return off if off < @threshold
// 69:
// 70:       off + @extend_size
// 71:     end
// 72:
// 73:     private
// 74:
// 75:     def fgap_method?
// 76:       idx = find_gap { |prv, nxt| nxt.file_head - prv.file_tail }
// 77:       return false if idx.nil?
// 78:
// 79:       loads = load_segments
// 80:       # prefer extend backwardly
// 81:       return extend_backward?(loads[idx - 1]) if writable?(loads[idx - 1])
// 82:
// 83:       extend_forward?(loads[idx])
// 84:     end
// 85:
// 86:     def extend_backward?(seg, size = @request_size)
// 87:       invoke_callbacks(seg, seg.file_tail)
// 88:       seg.header.p_filesz += size
// 89:       seg.header.p_memsz += size
// 90:       true
// 91:     end
// 92:
// 93:     def extend_forward?(seg, size = @request_size)
// 94:       seg.header.p_offset -= size
// 95:       seg.header.p_vaddr -= size
// 96:       seg.header.p_filesz += size
// 97:       seg.header.p_memsz += size
// 98:       invoke_callbacks(seg, seg.file_head)
// 99:       true
// 100:     end
// 101:
// 102:     def mgap_method?
// 103:       # |  1  | |  2  |
// 104:       # |  1  |        |  2  |
// 105:       #=>
// 106:       # |  1      | |  2  |
// 107:       # |  1      |    |  2  |
// 108:       idx = find_gap(check_sz: false) { |prv, nxt| PatchELF::Helper.aligndown(nxt.mem_head) - prv.mem_tail }
// 109:       return false if idx.nil?
// 110:
// 111:       loads = load_segments
// 112:       @threshold = loads[idx].file_head
// 113:       @extend_size = PatchELF::Helper.alignup(@request_size)
// 114:       shift_attributes
// 115:       # prefer backward than forward
// 116:       return extend_backward?(loads[idx - 1]) if writable?(loads[idx - 1])
// 117:
// 118:       # NOTE: loads[idx].file_head has been changed in shift_attributes
// 119:       extend_forward?(loads[idx], @extend_size)
// 120:     end
// 121:
// 122:     def find_gap(check_sz: true)
// 123:       loads = load_segments
// 124:       loads.each_with_index do |l, i|
// 125:         next if i.zero?
// 126:         next unless writable?(l) || writable?(loads[i - 1])
// 127:
// 128:         sz = yield(loads[i - 1], l)
// 129:         abnormal_elf('LOAD segments are out of order.') if check_sz && sz.negative?
// 130:         next unless sz >= @request_size
// 131:
// 132:         return i
// 133:       end
// 134:       nil
// 135:     end
// 136:
// 137:     # TODO
// 138:     def new_load_method
// 139:       raise NotImplementedError
// 140:     end
// 141:
// 142:     def writable?(seg)
// 143:       seg.readable? && seg.writable?
// 144:     end
// 145:
// 146:     # For all attributes >= threshold, += offset
// 147:     def shift_attributes
// 148:       # ELFHeader->section_header
// 149:       # Sections:
// 150:       #   all
// 151:       # Segments:
// 152:       #   all
// 153:       # XXX: will be buggy if someday the number of segments can be changed.
// 154:
// 155:       # Bottom-up
// 156:       @elf.each_sections do |sec|
// 157:         sec.header.sh_offset += extend_size if sec.header.sh_offset >= threshold
// 158:       end
// 159:       @elf.each_segments do |seg|
// 160:         next unless seg.header.p_offset >= threshold
// 161:
// 162:         seg.header.p_offset += extend_size
// 163:         # We have to change align of LOAD segment since ld.so checks it.
// 164:         seg.header.p_align = Helper.page_size if seg.is_a?(ELFTools::Segments::LoadSegment)
// 165:       end
// 166:
// 167:       @elf.header.e_shoff += extend_size if @elf.header.e_shoff >= threshold
// 168:     end
// 169:
// 170:     def load_segments
// 171:       @elf.segments_by_type(:load)
// 172:     end
// 173:
// 174:     def invoke_callbacks(seg, start)
// 175:       cur = start
// 176:       @request.each do |sz, block|
// 177:         block.call(cur, seg.offset_to_vma(cur))
// 178:         cur += sz
// 179:       end
// 180:     end
// 181:
// 182:     def abnormal_elf(msg)
// 183:       raise ArgumentError, msg
// 184:     end
// 185:   end
// 186: end
