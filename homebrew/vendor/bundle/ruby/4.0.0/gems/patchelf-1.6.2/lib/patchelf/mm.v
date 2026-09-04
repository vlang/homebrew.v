module patchelf

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/mm.rb`.
// The original source is retained below until every stub has a typed V body.
pub type MemoryAllocationCallback = fn(offset u64, virtual_address u64) !

pub struct MemoryAllocationRequest {
pub:
	size     u64
	callback MemoryAllocationCallback @[required]
}

@[heap]
pub struct MemoryManager {
mut:
	elf          &AltSaver
	requests     []MemoryAllocationRequest
	request_size u64
	was_extended bool
	extend_size  u64
	threshold    u64
}

fn empty_memory_allocation_callback(_ u64, _ u64) ! {}

pub fn new_memory_manager(elf &AltSaver) &MemoryManager {
	return &MemoryManager{
		elf: elf
	}
}

pub fn (manager &MemoryManager) extend_size_value() u64 {
	return manager.extend_size
}

pub fn (manager &MemoryManager) threshold_value() u64 {
	return manager.threshold
}

pub fn (manager &MemoryManager) allocation_sizes() []u64 {
	return manager.requests.map(it.size)
}

pub fn (mut manager MemoryManager) malloc(size i64, callback MemoryAllocationCallback) ![]u64 {
	if size <= 0 {
		return error("malloc's size most be positive.")
	}
	manager.requests << MemoryAllocationRequest{
		size: u64(size)
		callback: callback
	}
	return manager.allocation_sizes()
}

fn (manager &MemoryManager) load_segment_indices() []int {
	mut indices := []int{}
	for index, segment in manager.elf.segments {
		if segment.header.p_type == alt_pt_load {
			indices << index
		}
	}
	return indices
}

fn segment_file_head(segment AltSegment) u64 {
	return segment.header.p_offset
}

fn segment_file_tail(segment AltSegment) u64 {
	return segment.header.p_offset + segment.header.p_filesz
}

fn segment_memory_head(segment AltSegment) u64 {
	return segment.header.p_vaddr
}

fn segment_memory_tail(segment AltSegment) u64 {
	return segment.header.p_vaddr + segment.header.p_memsz
}

fn segment_offset_to_vma(segment AltSegment, offset u64) u64 {
	return segment.header.p_vaddr + (offset - segment.header.p_offset)
}

pub fn (manager &MemoryManager) writable(segment_index int) bool {
	if segment_index < 0 || segment_index >= manager.elf.segments.len {
		return false
	}
	flags := manager.elf.segments[segment_index].header.p_flags
	return flags & alt_pf_r != 0 && flags & alt_pf_w != 0
}

pub fn (manager &MemoryManager) find_gap(check_size bool, memory_gap bool) !int {
	loads := manager.load_segment_indices()
	for position in 1 .. loads.len {
		previous := manager.elf.segments[loads[position - 1]]
		next := manager.elf.segments[loads[position]]
		if !manager.writable(loads[position]) && !manager.writable(loads[position - 1]) {
			continue
		}
		gap := if memory_gap {
			patch_elf_align_down(i64(segment_memory_head(next)), 0x1000) - i64(segment_memory_tail(previous))
		} else {
			i64(segment_file_head(next)) - i64(segment_file_tail(previous))
		}
		if check_size && gap < 0 {
			return error('LOAD segments are out of order.')
		}
		if gap >= i64(manager.request_size) {
			return position
		}
	}
	return error('no suitable LOAD segment gap')
}

pub fn (mut manager MemoryManager) invoke_callbacks(segment_index int, start u64) ! {
	if segment_index < 0 || segment_index >= manager.elf.segments.len {
		return error('LOAD segment index ${segment_index} is out of range')
	}
	segment := manager.elf.segments[segment_index]
	mut current := start
	for request in manager.requests {
		request.callback(current, segment_offset_to_vma(segment, current))!
		current += request.size
	}
}

pub fn (mut manager MemoryManager) extend_backward(segment_index int, size u64) !bool {
	if segment_index < 0 || segment_index >= manager.elf.segments.len {
		return error('LOAD segment index ${segment_index} is out of range')
	}
	start := segment_file_tail(manager.elf.segments[segment_index])
	manager.invoke_callbacks(segment_index, start)!
	mut elf := manager.elf
	elf.segments[segment_index].header.p_filesz += size
	elf.segments[segment_index].header.p_memsz += size
	return true
}

pub fn (mut manager MemoryManager) extend_forward(segment_index int, size u64) !bool {
	if segment_index < 0 || segment_index >= manager.elf.segments.len {
		return error('LOAD segment index ${segment_index} is out of range')
	}
	mut elf := manager.elf
	if elf.segments[segment_index].header.p_offset < size || elf.segments[segment_index].header.p_vaddr < size {
		return error('LOAD segment cannot be extended before the beginning of the file')
	}
	elf.segments[segment_index].header.p_offset -= size
	elf.segments[segment_index].header.p_vaddr -= size
	elf.segments[segment_index].header.p_filesz += size
	elf.segments[segment_index].header.p_memsz += size
	start := segment_file_head(elf.segments[segment_index])
	manager.invoke_callbacks(segment_index, start)!
	return true
}

pub fn (mut manager MemoryManager) fgap_method() !bool {
	position := manager.find_gap(true, false) or {
		if err.msg() == 'LOAD segments are out of order.' {
			return err
		}
		return false
	}
	loads := manager.load_segment_indices()
	if manager.writable(loads[position - 1]) {
		return manager.extend_backward(loads[position - 1], manager.request_size)
	}
	return manager.extend_forward(loads[position], manager.request_size)
}

pub fn (mut manager MemoryManager) shift_attributes() {
	mut elf := manager.elf
	for index in 0 .. elf.sections.len {
		if elf.sections[index].header.sh_offset >= manager.threshold {
			elf.sections[index].header.sh_offset += manager.extend_size
		}
	}
	for index in 0 .. elf.segments.len {
		if elf.segments[index].header.p_offset < manager.threshold {
			continue
		}
		elf.segments[index].header.p_offset += manager.extend_size
		if elf.segments[index].header.p_type == alt_pt_load {
			elf.segments[index].header.p_align = u64(patch_elf_page_size(-1))
		}
	}
	if elf.ehdr.e_shoff >= manager.threshold {
		elf.ehdr.e_shoff += manager.extend_size
	}
}

pub fn (mut manager MemoryManager) mgap_method() !bool {
	position := manager.find_gap(false, true) or { return false }
	loads := manager.load_segment_indices()
	manager.threshold = segment_file_head(manager.elf.segments[loads[position]])
	manager.extend_size = u64(patch_elf_align_up(i64(manager.request_size), 0x1000))
	manager.was_extended = true
	manager.shift_attributes()
	if manager.writable(loads[position - 1]) {
		return manager.extend_backward(loads[position - 1], manager.request_size)
	}
	return manager.extend_forward(loads[position], manager.extend_size)
}

pub fn (manager &MemoryManager) new_load_method() !bool {
	return error('NotImplementedError: PatchELF::MM#new_load_method')
}

pub fn (mut manager MemoryManager) dispatch() !bool {
	if manager.requests.len == 0 {
		return false
	}
	manager.request_size = 0
	for request in manager.requests {
		manager.request_size += request.size
	}
	if manager.load_segment_indices().len == 0 {
		return error('No LOAD segment found, not an executable.')
	}
	if manager.fgap_method()! {
		return true
	}
	if manager.mgap_method()! {
		return true
	}
	return manager.new_load_method()!
}

pub fn (manager &MemoryManager) extended() bool {
	return manager.was_extended
}

pub fn (manager &MemoryManager) extended_offset(offset u64) u64 {
	if !manager.was_extended || offset < manager.threshold {
		return offset
	}
	return offset + manager.extend_size
}

fn memory_manager_value(manager &MemoryManager) ruby.Value {
	return ruby.structured_value('PatchELF::MM', '#<PatchELF::MM>', {
		'memory_manager_address': u64(voidptr(manager)).str()
	})
}

fn memory_manager_from_args(args []ruby.Value) &MemoryManager {
	if args.len == 0 {
		panic('PatchELF::MM method requires a receiver')
	}
	address := args[0].attribute('memory_manager_address') or { panic('invalid PatchELF::MM receiver') }
	return unsafe { &MemoryManager(voidptr(address.u64())) }
}

fn memory_segment_value(index int, segment AltSegment) ruby.Value {
	return ruby.structured_value('ELFTools::Segments::LoadSegment', '#<LoadSegment>', {
		'memory_segment_index': index.str()
		'p_type':               segment.header.p_type.str()
		'p_offset':             segment.header.p_offset.str()
		'p_vaddr':              segment.header.p_vaddr.str()
		'p_filesz':             segment.header.p_filesz.str()
		'p_memsz':              segment.header.p_memsz.str()
		'p_flags':              segment.header.p_flags.str()
	})
}

fn memory_segment_index(value ruby.Value) int {
	if index := value.attribute('memory_segment_index') {
		return index.int()
	}
	return -1
}

fn memory_requests_value(manager &MemoryManager) ruby.Value {
	return ruby.array_value(manager.requests.map(ruby.int_value(i64(it.size))))
}

fn memory_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby attr_reader `attr_reader :extend_size` at line 9.
pub fn ruby_mm_l9_d1_extend_size(args ...ruby.Value) ruby.Value {
	manager := memory_manager_from_args(args)
	if !manager.extended() {
		return memory_nil_value()
	}
	return ruby.int_value(i64(manager.extend_size_value()))
}

// Ruby attr_reader `attr_reader :threshold` at line 10.
pub fn ruby_mm_l10_d2_threshold(args ...ruby.Value) ruby.Value {
	manager := memory_manager_from_args(args)
	if !manager.extended() {
		return memory_nil_value()
	}
	return ruby.int_value(i64(manager.threshold_value()))
}

// Ruby method `initialize(elf)` at line 14.
pub fn ruby_mm_l14_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('PatchELF::MM#initialize requires an ELF file')
	}
	return memory_manager_value(new_memory_manager(alt_saver_from_args(args)))
}

// Ruby method `malloc(size, &block)` at line 27.
pub fn ruby_mm_l27_d4_malloc(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::MM#malloc requires a size')
	}
	mut manager := memory_manager_from_args(args)
	manager.malloc(args[1].as_int() or { panic(err) }, empty_memory_allocation_callback) or {
		panic(err)
	}
	return memory_requests_value(manager)
}

// Ruby method `dispatch!` at line 35.
pub fn ruby_mm_l35_d5_dispatch(args ...ruby.Value) ruby.Value {
	mut manager := memory_manager_from_args(args)
	if manager.requests.len == 0 {
		return memory_nil_value()
	}
	return ruby.bool_value(manager.dispatch() or { panic(err) })
}

// Ruby method `extended?` at line 57.
pub fn ruby_mm_l57_d6_extended(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(memory_manager_from_args(args).extended())
}

// Ruby method `extended_offset(off)` at line 66.
pub fn ruby_mm_l66_d7_extended_offset(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::MM#extended_offset requires an offset')
	}
	return ruby.int_value(i64(memory_manager_from_args(args).extended_offset(u64(args[1].as_int() or {
		panic(err)
	}))))
}

// Ruby method `fgap_method?` at line 75.
pub fn ruby_mm_l75_d8_fgap_method(args ...ruby.Value) ruby.Value {
	mut manager := memory_manager_from_args(args)
	return ruby.bool_value(manager.fgap_method() or { panic(err) })
}

// Ruby method `extend_backward?(seg, size = @request_size)` at line 86.
pub fn ruby_mm_l86_d9_extend_backward(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::MM#extend_backward? requires a segment')
	}
	mut manager := memory_manager_from_args(args)
	index := memory_segment_index(args[1])
	size := if args.len > 2 {
		u64(args[2].as_int() or { panic(err) })
	} else {
		manager.request_size
	}
	return ruby.bool_value(manager.extend_backward(index, size) or { panic(err) })
}

// Ruby method `extend_forward?(seg, size = @request_size)` at line 93.
pub fn ruby_mm_l93_d10_extend_forward(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::MM#extend_forward? requires a segment')
	}
	mut manager := memory_manager_from_args(args)
	index := memory_segment_index(args[1])
	size := if args.len > 2 {
		u64(args[2].as_int() or { panic(err) })
	} else {
		manager.request_size
	}
	return ruby.bool_value(manager.extend_forward(index, size) or { panic(err) })
}

// Ruby method `mgap_method?` at line 102.
pub fn ruby_mm_l102_d11_mgap_method(args ...ruby.Value) ruby.Value {
	mut manager := memory_manager_from_args(args)
	return ruby.bool_value(manager.mgap_method() or { panic(err) })
}

// Ruby method `find_gap(check_sz: true)` at line 122.
pub fn ruby_mm_l122_d12_find_gap(args ...ruby.Value) ruby.Value {
	manager := memory_manager_from_args(args)
	check_size := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	position := manager.find_gap(check_size, false) or { return memory_nil_value() }
	return ruby.int_value(position)
}

// Ruby method `new_load_method` at line 138.
pub fn ruby_mm_l138_d13_new_load_method(args ...ruby.Value) ruby.Value {
	manager := memory_manager_from_args(args)
	manager.new_load_method() or { panic(err) }
	return memory_nil_value()
}

// Ruby method `writable?(seg)` at line 142.
pub fn ruby_mm_l142_d14_writable(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::MM#writable? requires a segment')
	}
	manager := memory_manager_from_args(args)
	return ruby.bool_value(manager.writable(memory_segment_index(args[1])))
}

// Ruby method `shift_attributes` at line 147.
pub fn ruby_mm_l147_d15_shift_attributes(args ...ruby.Value) ruby.Value {
	mut manager := memory_manager_from_args(args)
	manager.shift_attributes()
	return memory_nil_value()
}

// Ruby method `load_segments` at line 170.
pub fn ruby_mm_l170_d16_load_segments(args ...ruby.Value) ruby.Value {
	manager := memory_manager_from_args(args)
	return ruby.array_value(manager.load_segment_indices().map(memory_segment_value(it, manager.elf.segments[it])))
}

// Ruby method `invoke_callbacks(seg, start)` at line 174.
pub fn ruby_mm_l174_d17_invoke_callbacks(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('PatchELF::MM#invoke_callbacks requires a segment and start offset')
	}
	mut manager := memory_manager_from_args(args)
	manager.invoke_callbacks(memory_segment_index(args[1]), u64(args[2].as_int() or {
		panic(err)
	})) or { panic(err) }
	return memory_nil_value()
}

// Ruby method `abnormal_elf(msg)` at line 182.
pub fn ruby_mm_l182_d18_abnormal_elf(args ...ruby.Value) ruby.Value {
	message := if args.len > 1 { args[1].as_string() } else { 'abnormal ELF' }
	panic(message)
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
