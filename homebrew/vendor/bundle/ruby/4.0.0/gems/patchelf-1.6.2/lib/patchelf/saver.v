module patchelf

import brew_runtime
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/saver.rb`.
// The original source is retained below until every stub has a typed V body.
const saver_dt_needed = i64(1)
const saver_dt_soname = i64(14)
const saver_dt_loos = i64(0x6000000d)

@[heap]
pub struct Saver {
pub:
	in_file  string
	out_file string
pub mut:
	set map[string]brew_runtime.Value
mut:
	elf               &AltSaver
	working_tags      []AltDynamicTag
	working_dynstr    []u8
	inline_patches    map[int][]u8
	dynamic_dirty     bool
	interpreter_dirty bool
}

fn saver_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn saver_value(saver &Saver) brew_runtime.Value {
	return brew_runtime.structured_value('PatchELF::Saver', 'Saver(${saver.in_file})', {
		'saver_address': u64(voidptr(saver)).str()
		'in_file':       saver.in_file
		'out_file':      saver.out_file
	})
}

fn saver_from_args(args []brew_runtime.Value) &Saver {
	if args.len == 0 {
		panic('PatchELF::Saver method requires a receiver')
	}
	address := args[0].attribute('saver_address') or { panic('invalid PatchELF::Saver receiver') }
	return unsafe { &Saver(voidptr(address.u64())) }
}

fn saver_require(args []brew_runtime.Value, count int, name string) {
	if args.len < count {
		panic('${name} requires ${count} argument(s), including receiver')
	}
}

fn saver_dynstr_bytes(elf &AltSaver) ![]u8 {
	section := elf.find_section('.dynstr') or { return error('section `.dynstr` not found') }
	alt_check(elf.buffer, int(section.header.sh_offset), int(section.header.sh_size), '.dynstr')!
	return elf.buffer[int(section.header.sh_offset)..int(section.header.sh_offset + section.header.sh_size)].clone()
}

pub fn new_saver_from_bytes(in_file string, out_file string, set map[string]brew_runtime.Value,
	data []u8) !&Saver {
	elf := new_alt_saver_from_bytes(in_file, out_file, set, data)!
	return &Saver{
		in_file: in_file
		out_file: out_file
		set: set.clone()
		elf: elf
		working_tags: elf.dynamic_tags()!
		working_dynstr: saver_dynstr_bytes(elf) or { []u8{} }
		inline_patches: map[int][]u8{}
	}
}

pub fn new_saver(in_file string, out_file string, set map[string]brew_runtime.Value) !&Saver {
	return new_saver_from_bytes(in_file, out_file, set, os.read_bytes(in_file)!)
}

fn saver_find_bytes(haystack []u8, needle []u8) ?int {
	if needle.len == 0 {
		return 0
	}
	if needle.len > haystack.len {
		return none
	}
	for start in 0 .. haystack.len - needle.len + 1 {
		if haystack[start..start + needle.len] == needle {
			return start
		}
	}
	return none
}

fn saver_unique(values []string) []string {
	mut result := []string{cap: values.len}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

fn saver_tag_constant(name string) !i64 {
	return match name.trim_string_left(':') {
		'needed' { saver_dt_needed }
		'soname' { saver_dt_soname }
		'rpath' { alt_dt_rpath }
		'runpath' { alt_dt_runpath }
		else {
			return error('unknown dynamic tag `${name}`')
		}
	}
}

fn (saver &Saver) dynstr_name(offset u64) ?string {
	if offset >= u64(saver.working_dynstr.len) {
		return none
	}
	mut finish := int(offset)
	for finish < saver.working_dynstr.len && saver.working_dynstr[finish] != 0 {
		finish++
	}
	return saver.working_dynstr[int(offset)..finish].bytestr()
}

pub fn (mut saver Saver) reg_str_table(str string) int {
	mut terminated := str.bytes()
	terminated << u8(0)
	if index := saver_find_bytes(saver.working_dynstr, terminated) {
		return index
	}
	index := saver.working_dynstr.len
	saver.working_dynstr << terminated
	return index
}

pub fn (saver &Saver) strtab_string() string {
	return saver.working_dynstr.bytestr()
}

fn (saver &Saver) find_working_tag(kind i64) ?int {
	for index, tag in saver.working_tags {
		if tag.d_tag == kind {
			return index
		}
	}
	return none
}

pub fn (mut saver Saver) lazy_dyn(name string) !int {
	tag := AltDynamicTag{
		d_tag: saver_tag_constant(name)!
		d_val: 0
		offset: -1
	}
	saver.working_tags << tag
	saver.dynamic_dirty = true
	return saver.working_tags.len - 1
}

pub fn (mut saver Saver) patch_interpreter() ! {
	value := saver.set['interpreter'] or { return }
	section := saver.elf.find_section('.interp') or { return error('No interpreter found.') }
	mut replacement := value.as_string().bytes()
	replacement << u8(0)
	alt_check(saver.elf.buffer, int(section.header.sh_offset), int(section.header.sh_size), '.interp')!
	old := saver.elf.buffer[int(section.header.sh_offset)..int(section.header.sh_offset + section.header.sh_size)]
	if old == replacement {
		return
	}
	saver.elf.replaced_sections['.interp'] = replacement
	saver.interpreter_dirty = true
}

pub fn (mut saver Saver) patch_soname() ! {
	value := saver.set['soname'] or { return }
	index := saver.find_working_tag(saver_dt_soname) or {
		return error('Entry DT_SONAME not found, not a shared library?')
	}
	mut tag := saver.working_tags[index]
	tag.d_val = u64(saver.reg_str_table(value.as_string()))
	saver.working_tags[index] = tag
	saver.dynamic_dirty = true
}

pub fn (mut saver Saver) patch_runpath(name string) ! {
	clean_name := name.trim_string_left(':')
	value := saver.set[clean_name] or { return }
	kind := saver_tag_constant(clean_name)!
	index := saver.find_working_tag(kind) or { saver.lazy_dyn(clean_name)! }
	mut tag := saver.working_tags[index]
	tag.d_val = u64(saver.reg_str_table(value.as_string()))
	saver.working_tags[index] = tag
	saver.dynamic_dirty = true
}

pub fn (mut saver Saver) patch_needed() ! {
	value := saver.set['needed'] or { return }
	desired := saver_unique(value.as_string_array()!)
	mut original := []string{}
	mut ignored := []int{}
	for index, source_tag in saver.working_tags {
		if source_tag.d_tag != saver_dt_needed {
			continue
		}
		name := saver.dynstr_name(source_tag.d_val) or { '' }
		original << name
		if name !in desired {
			mut tag := source_tag
			tag.d_tag = saver_dt_loos
			saver.working_tags[index] = tag
			ignored << index
		}
	}
	for name in desired {
		if name in original {
			continue
		}
		index := if ignored.len > 0 {
			ignored[0]
		} else {
			saver.lazy_dyn('needed')!
		}
		if ignored.len > 0 {
			ignored.delete(0)
		}
		mut tag := saver.working_tags[index]
		tag.d_tag = saver_dt_needed
		tag.d_val = u64(saver.reg_str_table(name))
		saver.working_tags[index] = tag
	}
	saver.dynamic_dirty = true
}

pub fn (mut saver Saver) malloc_strtab() ! {
	if saver.working_dynstr.len == 0 {
		return
	}
	original := saver_dynstr_bytes(saver.elf) or { []u8{} }
	if original != saver.working_dynstr {
		saver.elf.replaced_sections['.dynstr'] = saver.working_dynstr.clone()
	}
}

pub fn (mut saver Saver) expand_dynamic() ! {
	if !saver.dynamic_dirty {
		return
	}
	entry_size := if saver.elf.elf_class == 32 { 8 } else { 16 }
	mut replacement := []u8{len: (saver.working_tags.len + 1) * entry_size}
	for index, tag in saver.working_tags {
		offset := index * entry_size
		alt_write_uint(mut replacement, offset, entry_size / 2, saver.elf.endian, u64(tag.d_tag))!
		alt_write_uint(mut replacement, offset + entry_size / 2, entry_size / 2, saver.elf.endian, tag.d_val)!
	}
	saver.elf.replaced_sections['.dynamic'] = replacement
}

pub fn (mut saver Saver) patch_dynamic() ! {
	if 'soname' in saver.set {
		saver.patch_soname()!
	}
	if 'runpath' in saver.set {
		saver.patch_runpath('runpath')!
	}
	if 'rpath' in saver.set {
		saver.patch_runpath('rpath')!
	}
	if 'needed' in saver.set {
		saver.patch_needed()!
	}
	saver.malloc_strtab()!
	saver.expand_dynamic()!
}

pub fn (mut saver Saver) inline_patch(offset int, value string) ! {
	if offset < 0 {
		return error('negative patch offset')
	}
	saver.inline_patches[offset] = value.bytes()
}

pub fn (mut saver Saver) patch_out(out_file string) ! {
	saver.elf.rewrite_sections()!
	for offset, value in saver.inline_patches {
		alt_check(saver.elf.buffer, offset, value.len, 'inline patch')!
		for index, byte in value {
			saver.elf.buffer[offset + index] = byte
		}
	}
	if out_file != saver.out_file {
		return error('Saver output path is fixed at initialization')
	}
	saver.elf.patch_out()!
}

pub fn (saver &Saver) section_header(name string) ?AltSectionHeader {
	section := saver.elf.find_section(name) or { return none }
	return section.header
}

pub fn (saver &Saver) dynamic() ?AltSection {
	return saver.elf.find_section('.dynamic')
}

pub fn (mut saver Saver) save() ! {
	saver.patch_interpreter()!
	saver.patch_dynamic()!
	saver.patch_out(saver.out_file)!
	if saver.in_file != '' && os.exists(saver.in_file) {
		metadata := os.stat(saver.in_file)!
		os.chmod(saver.out_file, int(metadata.mode))!
	}
}

// Ruby attr_reader `attr_reader :in_file` at line 22.
pub fn ruby_saver_l22_d1_in_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(saver_from_args(args).in_file)
}

// Ruby attr_reader `attr_reader :out_file` at line 23.
pub fn ruby_saver_l23_d2_out_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(saver_from_args(args).out_file)
}

// Ruby method `initialize(in_file, out_file, set)` at line 29.
pub fn ruby_saver_l29_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	saver_require(args, 3, 'Saver#initialize')
	saver := new_saver(args[0].as_string(), args[1].as_string(), alt_set_from_value(args[2])) or {
		panic(err)
	}
	return saver_value(saver)
}

// Ruby method `save!` at line 46.
pub fn ruby_saver_l46_d4_save(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.save() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_interpreter` at line 62.
pub fn ruby_saver_l62_d5_patch_interpreter(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.patch_interpreter() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_dynamic` at line 97.
pub fn ruby_saver_l97_d6_patch_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.patch_dynamic() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_soname` at line 112.
pub fn ruby_saver_l112_d7_patch_soname(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.patch_soname() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_runpath(sym = :runpath)` at line 120.
pub fn ruby_saver_l120_d8_patch_runpath(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	name := if args.len > 1 { args[1].as_string() } else { 'runpath' }
	saver.patch_runpath(name) or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_needed` at line 128.
pub fn ruby_saver_l128_d9_patch_needed(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.patch_needed() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `lazy_dyn(sym)` at line 157.
pub fn ruby_saver_l157_d10_lazy_dyn(args ...brew_runtime.Value) brew_runtime.Value {
	saver_require(args, 2, 'Saver#lazy_dyn')
	mut saver := saver_from_args(args)
	index := saver.lazy_dyn(args[1].as_string()) or { panic(err) }
	return alt_dynamic_tag_value(saver.working_tags[index])
}

// Ruby method `expand_dynamic!` at line 165.
pub fn ruby_saver_l165_d11_expand_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.expand_dynamic() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `malloc_strtab!` at line 186.
pub fn ruby_saver_l186_d12_malloc_strtab(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	saver.malloc_strtab() or { panic(err) }
	return saver_nil_value()
}

// Ruby method `reg_str_table(str, &block)` at line 215.
pub fn ruby_saver_l215_d13_reg_str_table(args ...brew_runtime.Value) brew_runtime.Value {
	saver_require(args, 2, 'Saver#reg_str_table')
	mut saver := saver_from_args(args)
	return brew_runtime.int_value(saver.reg_str_table(args[1].as_string()))
}

// Ruby method `strtab_string` at line 224.
pub fn ruby_saver_l224_d14_strtab_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(saver_from_args(args).strtab_string())
}

// Ruby method `inline_patch(off, str)` at line 245.
pub fn ruby_saver_l245_d15_inline_patch(args ...brew_runtime.Value) brew_runtime.Value {
	saver_require(args, 3, 'Saver#inline_patch')
	mut saver := saver_from_args(args)
	saver.inline_patch(int(args[1].as_int() or { panic(err) }), args[2].as_string()) or { panic(err) }
	return saver_nil_value()
}

// Ruby method `patch_out(out_file)` at line 250.
pub fn ruby_saver_l250_d16_patch_out(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := saver_from_args(args)
	out_file := if args.len > 1 { args[1].as_string() } else { saver.out_file }
	saver.patch_out(out_file) or { panic(err) }
	return saver_nil_value()
}

// Ruby method `section_header(name)` at line 278.
pub fn ruby_saver_l278_d17_section_header(args ...brew_runtime.Value) brew_runtime.Value {
	saver_require(args, 2, 'Saver#section_header')
	header := saver_from_args(args).section_header(args[1].as_string()) or { return saver_nil_value() }
	return alt_section_header_value(header)
}

// Ruby method `dynamic` at line 285.
pub fn ruby_saver_l285_d18_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	section := saver_from_args(args).dynamic() or { return saver_nil_value() }
	return alt_section_value(section)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/constants'
// 4: require 'elftools/elf_file'
// 5: require 'elftools/structs'
// 6: require 'elftools/util'
// 7: require 'fileutils'
// 8: require 'objspace'
// 9:
// 10: require 'patchelf/helper'
// 11: require 'patchelf/mm'
// 12:
// 13: module PatchELF
// 14:   # To mark a not-using tag
// 15:   IGNORE = ELFTools::Constants::DT_LOOS
// 16:
// 17:   # Internal use only.
// 18:   #
// 19:   # For {Patcher} to do patching things and save to file.
// 20:   # @private
// 21:   class Saver
// 22:     attr_reader :in_file # @return [String] Input filename.
// 23:     attr_reader :out_file # @return [String] Output filename.
// 24:
// 25:     # Instantiate a {Saver} object.
// 26:     # @param [String] in_file
// 27:     # @param [String] out_file
// 28:     # @param [{Symbol => String, Array}] set
// 29:     def initialize(in_file, out_file, set)
// 30:       @in_file = in_file
// 31:       @out_file = out_file
// 32:       @set = set
// 33:       # [{Integer => String}]
// 34:       @inline_patch = {}
// 35:       f = File.open(in_file) # rubocop:disable Style/FileOpen
// 36:       @elf = ELFTools::ELFFile.new(f)
// 37:       @mm = PatchELF::MM.new(@elf)
// 38:       @strtab_extend_requests = []
// 39:       @append_dyn = []
// 40:
// 41:       # Ensure file is closed when the {Saver} object is garbage collected.
// 42:       ObjectSpace.define_finalizer(self, Helper.close_file_proc(f))
// 43:     end
// 44:
// 45:     # @return [void]
// 46:     def save!
// 47:       # In this method we assume all attributes that should exist do exist.
// 48:       # e.g. DT_INTERP, DT_DYNAMIC. These should have been checked in the patcher.
// 49:       patch_interpreter
// 50:       patch_dynamic
// 51:
// 52:       @mm.dispatch!
// 53:
// 54:       FileUtils.cp(in_file, out_file) if out_file != in_file
// 55:       patch_out(@out_file)
// 56:       # Let output file have the same permission as input.
// 57:       FileUtils.chmod(File.stat(in_file).mode, out_file)
// 58:     end
// 59:
// 60:     private
// 61:
// 62:     def patch_interpreter
// 63:       return if @set[:interpreter].nil?
// 64:
// 65:       new_interp = "#{@set[:interpreter]}\x00"
// 66:       old_interp = "#{@elf.segment_by_type(:interp).interp_name}\x00"
// 67:       return if old_interp == new_interp
// 68:
// 69:       # These headers must be found here but not in the proc.
// 70:       seg_header = @elf.segment_by_type(:interp).header
// 71:       sec_header = section_header('.interp')
// 72:
// 73:       patch = proc do |off, vaddr|
// 74:         # Register an inline patching
// 75:         inline_patch(off, new_interp)
// 76:
// 77:         # The patching feature of ELFTools
// 78:         seg_header.p_offset = off
// 79:         seg_header.p_vaddr = seg_header.p_paddr = vaddr
// 80:         seg_header.p_filesz = seg_header.p_memsz = new_interp.size
// 81:
// 82:         if sec_header
// 83:           sec_header.sh_offset = off
// 84:           sec_header.sh_size = new_interp.size
// 85:         end
// 86:       end
// 87:
// 88:       if new_interp.size <= old_interp.size
// 89:         # easy case
// 90:         patch.call(seg_header.p_offset.to_i, seg_header.p_vaddr.to_i)
// 91:       else
// 92:         # hard case, we have to request a new LOAD area
// 93:         @mm.malloc(new_interp.size, &patch)
// 94:       end
// 95:     end
// 96:
// 97:     def patch_dynamic
// 98:       # We never do inline patching on strtab's string.
// 99:       # 1. Search if there's useful string exists
// 100:       #   - only need header patching
// 101:       # 2. Append a new string to the strtab.
// 102:       #   - register strtab extension
// 103:       dynamic.tags # HACK, force @tags to be defined
// 104:       patch_soname if @set[:soname]
// 105:       patch_runpath if @set[:runpath]
// 106:       patch_runpath(:rpath) if @set[:rpath]
// 107:       patch_needed if @set[:needed]
// 108:       malloc_strtab!
// 109:       expand_dynamic!
// 110:     end
// 111:
// 112:     def patch_soname
// 113:       # The tag must exist.
// 114:       so_tag = dynamic.tag_by_type(:soname)
// 115:       reg_str_table(@set[:soname]) do |idx|
// 116:         so_tag.header.d_val = idx
// 117:       end
// 118:     end
// 119:
// 120:     def patch_runpath(sym = :runpath)
// 121:       tag = dynamic.tag_by_type(sym)
// 122:       tag = tag.nil? ? lazy_dyn(sym) : tag.header
// 123:       reg_str_table(@set[sym]) do |idx|
// 124:         tag.d_val = idx
// 125:       end
// 126:     end
// 127:
// 128:     def patch_needed
// 129:       original_needs = dynamic.tags_by_type(:needed)
// 130:       @set[:needed].uniq!
// 131:
// 132:       original = original_needs.map(&:name)
// 133:       replace = @set[:needed]
// 134:
// 135:       # 3 sets:
// 136:       # 1. in original and in needs - remain unchanged
// 137:       # 2. in original but not in needs - remove
// 138:       # 3. not in original and in needs - append
// 139:       append = replace - original
// 140:       remove = original - replace
// 141:
// 142:       ignored_dyns = remove.each_with_object([]) do |name, ignored|
// 143:         dyn = original_needs.find { |n| n.name == name }.header
// 144:         dyn.d_tag = IGNORE
// 145:         ignored << dyn
// 146:       end
// 147:
// 148:       append.zip(ignored_dyns) do |name, ignored_dyn|
// 149:         dyn = ignored_dyn || lazy_dyn(:needed)
// 150:         dyn.d_tag = ELFTools::Constants::DT_NEEDED
// 151:         reg_str_table(name) { |idx| dyn.d_val = idx }
// 152:       end
// 153:     end
// 154:
// 155:     # Create a temp tag header.
// 156:     # @return [ELFTools::Structs::ELF_Dyn]
// 157:     def lazy_dyn(sym)
// 158:       ELFTools::Structs::ELF_Dyn.new(endian: @elf.endian).tap do |dyn|
// 159:         @append_dyn << dyn
// 160:         dyn.elf_class = @elf.elf_class
// 161:         dyn.d_tag = ELFTools::Util.to_constant(ELFTools::Constants::DT, sym)
// 162:       end
// 163:     end
// 164:
// 165:     def expand_dynamic!
// 166:       return if @append_dyn.empty?
// 167:
// 168:       dyn_sec = section_header('.dynamic')
// 169:       total = dynamic.tags.map(&:header)
// 170:       # the last must be a null-tag
// 171:       total = total[0..-2] + @append_dyn + [total.last]
// 172:       bytes = total.first.num_bytes * total.size
// 173:       @mm.malloc(bytes) do |off, vaddr|
// 174:         inline_patch(off, total.map(&:to_binary_s).join)
// 175:         dynamic.header.p_offset = off
// 176:         dynamic.header.p_vaddr = dynamic.header.p_paddr = vaddr
// 177:         dynamic.header.p_filesz = dynamic.header.p_memsz = bytes
// 178:         if dyn_sec
// 179:           dyn_sec.sh_offset = off
// 180:           dyn_sec.sh_addr = vaddr
// 181:           dyn_sec.sh_size = bytes
// 182:         end
// 183:       end
// 184:     end
// 185:
// 186:     def malloc_strtab!
// 187:       return if @strtab_extend_requests.empty?
// 188:
// 189:       strtab = dynamic.tag_by_type(:strtab)
// 190:       # Process registered requests
// 191:       need_size = strtab_string.size + @strtab_extend_requests.reduce(0) { |sum, (str, _)| sum + str.size + 1 }
// 192:       dynstr = section_header('.dynstr')
// 193:       @mm.malloc(need_size) do |off, vaddr|
// 194:         new_str = "#{strtab_string}#{@strtab_extend_requests.map(&:first).join("\x00")}\x00"
// 195:         inline_patch(off, new_str)
// 196:         cur = strtab_string.size
// 197:         @strtab_extend_requests.each do |str, block|
// 198:           block.call(cur)
// 199:           cur += str.size + 1
// 200:         end
// 201:         # Now patching strtab header
// 202:         strtab.header.d_val = vaddr
// 203:         # We also need to patch dynstr to let readelf have correct output.
// 204:         if dynstr
// 205:           dynstr.sh_size = new_str.size
// 206:           dynstr.sh_offset = off
// 207:           dynstr.sh_addr = vaddr
// 208:         end
// 209:       end
// 210:     end
// 211:
// 212:     # @param [String] str
// 213:     # @yieldparam [Integer] idx
// 214:     # @yieldreturn [void]
// 215:     def reg_str_table(str, &block)
// 216:       idx = strtab_string.index("#{str}\x00")
// 217:       # Request string is already exist
// 218:       return yield idx if idx
// 219:
// 220:       # Record the request
// 221:       @strtab_extend_requests << [str, block]
// 222:     end
// 223:
// 224:     def strtab_string
// 225:       return @strtab_string if defined?(@strtab_string)
// 226:
// 227:       # TODO: handle no strtab exists..
// 228:       offset = @elf.offset_from_vma(dynamic.tag_by_type(:strtab).value)
// 229:       # This is a little tricky since no length information is stored in the tag.
// 230:       # We first get the file offset of the string then 'guess' where the end is.
// 231:       @elf.stream.pos = offset
// 232:       @strtab_string = +''
// 233:       loop do
// 234:         c = @elf.stream.read(1)
// 235:         break unless c =~ /\x00|[[:print:]]/
// 236:
// 237:         @strtab_string << c
// 238:       end
// 239:       @strtab_string
// 240:     end
// 241:
// 242:     # This can only be used for patching interpreter's name
// 243:     # or set strings in a malloc-ed area.
// 244:     # i.e. NEVER intend to change the string defined in strtab
// 245:     def inline_patch(off, str)
// 246:       @inline_patch[off] = str
// 247:     end
// 248:
// 249:     # Modify the out_file according to registered patches.
// 250:     def patch_out(out_file)
// 251:       File.open(out_file, 'r+') do |f|
// 252:         if @mm.extended?
// 253:           original_head = @mm.threshold
// 254:           extra = {}
// 255:           # Copy all data after the second load
// 256:           @elf.stream.pos = original_head
// 257:           extra[original_head + @mm.extend_size] = @elf.stream.read # read to end
// 258:           # zero out the 'gap' we created
// 259:           extra[original_head] = "\x00" * @mm.extend_size
// 260:           extra.each do |pos, str|
// 261:             f.pos = pos
// 262:             f.write(str)
// 263:           end
// 264:         end
// 265:         @elf.patches.each do |pos, str|
// 266:           f.pos = @mm.extended_offset(pos)
// 267:           f.write(str)
// 268:         end
// 269:
// 270:         @inline_patch.each do |pos, str|
// 271:           f.pos = pos
// 272:           f.write(str)
// 273:         end
// 274:       end
// 275:     end
// 276:
// 277:     # @return [ELFTools::Sections::Section?]
// 278:     def section_header(name)
// 279:       sec = @elf.section_by_name(name)
// 280:       return if sec.nil?
// 281:
// 282:       sec.header
// 283:     end
// 284:
// 285:     def dynamic
// 286:       @dynamic ||= @elf.segment_by_type(:dynamic)
// 287:     end
// 288:   end
// 289: end
