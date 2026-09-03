module patchelf

import brew_runtime
import os

const alt_dt_null = i64(0)
const alt_dt_strtab = i64(5)
const alt_dt_symtab = i64(6)
const alt_dt_strsz = i64(10)
const alt_dt_rpath = i64(15)
const alt_dt_jmprel = i64(23)
const alt_dt_runpath = i64(29)
const alt_dt_hash = i64(4)
const alt_dt_rel = i64(17)
const alt_dt_rela = i64(7)
const alt_dt_gnu_hash = i64(0x6ffffef5)
const alt_dt_versym = i64(0x6ffffff0)
const alt_dt_verneed = i64(0x6ffffffe)
const alt_dt_mips_xhash = i64(0x70000036)
const alt_dt_mips_rld_map_rel = i64(0x70000035)
const alt_et_exec = u16(2)
const alt_et_dyn = u16(3)
const alt_em_mips = u16(8)
const alt_pt_load = u32(1)
const alt_pt_dynamic = u32(2)
const alt_pt_interp = u32(3)
const alt_pt_note = u32(4)
const alt_pt_phdr = u32(6)
const alt_pt_mips_abiflags = u32(0x70000003)
const alt_pt_gnu_property = u32(0x6474e553)
const alt_pf_r = u32(4)
const alt_pf_w = u32(2)
const alt_sht_progbits = u32(1)
const alt_sht_symtab = u32(2)
const alt_sht_nobits = u32(8)
const alt_sht_rel = u32(9)
const alt_sht_dynsym = u32(11)
const alt_sht_note = u32(7)
const alt_sht_rela = u32(4)
const alt_stt_section = u64(3)
const alt_shn_loreserve = u16(0xff00)

pub enum AltEndian {
	little
	big
}

pub struct AltElfHeader {
pub mut:
	e_type      u16
	e_machine   u16
	e_entry     u64
	e_phoff     u64
	e_shoff     u64
	e_flags     u32
	e_ehsize    u16
	e_phentsize u16
	e_phnum     u16
	e_shentsize u16
	e_shnum     u16
	e_shstrndx  u16
}

pub struct AltSectionHeader {
pub mut:
	sh_name      u32
	sh_type      u32
	sh_flags     u64
	sh_addr      u64
	sh_offset    u64
	sh_size      u64
	sh_link      u32
	sh_info      u32
	sh_addralign u64
	sh_entsize   u64
}

pub struct AltSection {
pub:
	name string
pub mut:
	header AltSectionHeader
}

pub struct AltProgramHeader {
pub mut:
	p_type   u32
	p_offset u64
	p_vaddr  u64
	p_paddr  u64
	p_filesz u64
	p_memsz  u64
	p_flags  u32
	p_align  u64
}

pub struct AltSegment {
pub mut:
	header AltProgramHeader
}

pub struct AltDynamicTag {
pub mut:
	d_tag  i64
	d_val  u64
	offset int
}

pub struct AltRunpathTag {
pub mut:
	offset int
	header AltDynamicTag
}

pub struct AltSymbolMeta {
pub:
	num_bytes int
	code      string
	st_info   int
	st_shndx  int
	st_value  int
}

pub struct AltSectionReferences {
pub:
	linkage map[string]string
	info    map[string]string
}

pub type AltBufferOperation = fn(mut []u8, int) !

pub struct AltSaver {
pub:
	in_file   string
	out_file  string
	endian    AltEndian
	elf_class int
pub mut:
	set                 map[string]brew_runtime.Value
	buffer              []u8
	ehdr                AltElfHeader
	segments            []AltSegment
	sections            []AltSection
	original_sections   []AltSection
	section_idx_by_name map[string]int
	replaced_sections   map[string][]u8
	section_alignment   int
}

fn alt_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn alt_alignup(value u64, alignment u64) u64 {
	if alignment == 0 || value & (alignment - 1) == 0 {
		return value
	}
	return value - (value & (alignment - 1)) + alignment
}

fn alt_page_size_for(machine u16) int {
	return if machine in [u16(2), 8, 20, 21, 183, 191, 258] { 0x10000 } else { 0x1000 }
}

fn alt_check(data []u8, offset int, size int, kind string) ! {
	if offset < 0 || size < 0 || offset > data.len || size > data.len - offset {
		return error('truncated ${kind} at offset ${offset}')
	}
}

fn alt_read_uint(data []u8, offset int, size int, endian AltEndian) !u64 {
	alt_check(data, offset, size, 'ELF integer')!
	mut result := u64(0)
	if endian == .little {
		for index in 0 .. size {
			result |= u64(data[offset + index]) << u32(index * 8)
		}
	} else {
		for index in 0 .. size {
			result = (result << 8) | u64(data[offset + index])
		}
	}
	return result
}

fn alt_write_uint(mut data []u8, offset int, size int, endian AltEndian, value u64) ! {
	alt_check(data, offset, size, 'ELF integer')!
	for index in 0 .. size {
		source_index := if endian == .little { index } else { size - index - 1 }
		data[offset + index] = u8((value >> u32(source_index * 8)) & 0xff)
	}
}

fn alt_cstring(data []u8, offset int) !string {
	if offset < 0 || offset >= data.len {
		return error('string offset ${offset} is outside the ELF')
	}
	mut finish := offset
	for finish < data.len && data[finish] != 0 {
		finish++
	}
	return data[offset..finish].bytestr()
}

fn alt_parse_header(data []u8, elf_class int, endian AltEndian) !AltElfHeader {
	size := if elf_class == 32 { 52 } else { 64 }
	alt_check(data, 0, size, 'ELF header')!
	value_size := if elf_class == 32 { 4 } else { 8 }
	phoff_pos := 24 + value_size
	shoff_pos := phoff_pos + value_size
	flags_pos := shoff_pos + value_size
	return AltElfHeader{
		e_type: u16(alt_read_uint(data, 16, 2, endian)!)
		e_machine: u16(alt_read_uint(data, 18, 2, endian)!)
		e_entry: alt_read_uint(data, 24, value_size, endian)!
		e_phoff: alt_read_uint(data, phoff_pos, value_size, endian)!
		e_shoff: alt_read_uint(data, shoff_pos, value_size, endian)!
		e_flags: u32(alt_read_uint(data, flags_pos, 4, endian)!)
		e_ehsize: u16(alt_read_uint(data, flags_pos + 4, 2, endian)!)
		e_phentsize: u16(alt_read_uint(data, flags_pos + 6, 2, endian)!)
		e_phnum: u16(alt_read_uint(data, flags_pos + 8, 2, endian)!)
		e_shentsize: u16(alt_read_uint(data, flags_pos + 10, 2, endian)!)
		e_shnum: u16(alt_read_uint(data, flags_pos + 12, 2, endian)!)
		e_shstrndx: u16(alt_read_uint(data, flags_pos + 14, 2, endian)!)
	}
}

fn alt_parse_section_header(data []u8, offset int, elf_class int, endian AltEndian) !AltSectionHeader {
	size := if elf_class == 32 { 40 } else { 64 }
	alt_check(data, offset, size, 'ELF section header')!
	value_size := if elf_class == 32 { 4 } else { 8 }
	mut cursor := offset + 8
	sh_flags := alt_read_uint(data, cursor, value_size, endian)!
	cursor += value_size
	sh_addr := alt_read_uint(data, cursor, value_size, endian)!
	cursor += value_size
	sh_offset := alt_read_uint(data, cursor, value_size, endian)!
	cursor += value_size
	sh_size := alt_read_uint(data, cursor, value_size, endian)!
	cursor += value_size
	sh_link := u32(alt_read_uint(data, cursor, 4, endian)!)
	sh_info := u32(alt_read_uint(data, cursor + 4, 4, endian)!)
	cursor += 8
	sh_addralign := alt_read_uint(data, cursor, value_size, endian)!
	cursor += value_size
	return AltSectionHeader{
		sh_name: u32(alt_read_uint(data, offset, 4, endian)!)
		sh_type: u32(alt_read_uint(data, offset + 4, 4, endian)!)
		sh_flags: sh_flags
		sh_addr: sh_addr
		sh_offset: sh_offset
		sh_size: sh_size
		sh_link: sh_link
		sh_info: sh_info
		sh_addralign: sh_addralign
		sh_entsize: alt_read_uint(data, cursor, value_size, endian)!
	}
}

fn alt_parse_program_header(data []u8, offset int, elf_class int, endian AltEndian) !AltProgramHeader {
	size := if elf_class == 32 { 32 } else { 56 }
	alt_check(data, offset, size, 'ELF program header')!
	if elf_class == 32 {
		return AltProgramHeader{
			p_type: u32(alt_read_uint(data, offset, 4, endian)!)
			p_offset: alt_read_uint(data, offset + 4, 4, endian)!
			p_vaddr: alt_read_uint(data, offset + 8, 4, endian)!
			p_paddr: alt_read_uint(data, offset + 12, 4, endian)!
			p_filesz: alt_read_uint(data, offset + 16, 4, endian)!
			p_memsz: alt_read_uint(data, offset + 20, 4, endian)!
			p_flags: u32(alt_read_uint(data, offset + 24, 4, endian)!)
			p_align: alt_read_uint(data, offset + 28, 4, endian)!
		}
	}
	return AltProgramHeader{
		p_type: u32(alt_read_uint(data, offset, 4, endian)!)
		p_flags: u32(alt_read_uint(data, offset + 4, 4, endian)!)
		p_offset: alt_read_uint(data, offset + 8, 8, endian)!
		p_vaddr: alt_read_uint(data, offset + 16, 8, endian)!
		p_paddr: alt_read_uint(data, offset + 24, 8, endian)!
		p_filesz: alt_read_uint(data, offset + 32, 8, endian)!
		p_memsz: alt_read_uint(data, offset + 40, 8, endian)!
		p_align: alt_read_uint(data, offset + 48, 8, endian)!
	}
}

fn alt_copy_sections(sections []AltSection) []AltSection {
	return sections.map(AltSection{ name: it.name, header: it.header })
}

pub fn new_alt_saver_from_bytes(in_file string, out_file string, set map[string]brew_runtime.Value,
	data []u8) !&AltSaver {
	if data.len < 6 || data[..4] != [u8(0x7f), `E`, `L`, `F`] {
		return error('invalid ELF magic')
	}
	elf_class := match data[4] {
		1 { 32 }
		2 { 64 }
		else {
			return error('invalid ELF class ${data[4]}')
		}
	}
	endian := match data[5] {
		1 { AltEndian.little }
		2 { AltEndian.big }
		else {
			return error('invalid ELF endian ${data[5]}')
		}
	}
	ehdr := alt_parse_header(data, elf_class, endian)!
	mut headers := []AltSectionHeader{cap: int(ehdr.e_shnum)}
	for index in 0 .. int(ehdr.e_shnum) {
		headers << alt_parse_section_header(data, int(ehdr.e_shoff) + index * int(ehdr.e_shentsize), elf_class, endian)!
	}
	mut sections := []AltSection{cap: headers.len}
	mut strtab := []u8{}
	if int(ehdr.e_shstrndx) < headers.len {
		str_header := headers[int(ehdr.e_shstrndx)]
		alt_check(data, int(str_header.sh_offset), int(str_header.sh_size), 'section string table')!
		strtab = data[int(str_header.sh_offset)..int(str_header.sh_offset + str_header.sh_size)].clone()
	}
	for header in headers {
		name := alt_cstring(strtab, int(header.sh_name)) or { '' }
		sections << AltSection{ name: name, header: header }
	}
	mut segments := []AltSegment{cap: int(ehdr.e_phnum)}
	for index in 0 .. int(ehdr.e_phnum) {
		segments << AltSegment{
			header: alt_parse_program_header(data, int(ehdr.e_phoff) + index * int(ehdr.e_phentsize), elf_class, endian)!
		}
	}
	mut saver := &AltSaver{
		in_file: in_file
		out_file: out_file
		endian: endian
		elf_class: elf_class
		set: set.clone()
		buffer: data.clone()
		ehdr: ehdr
		segments: segments
		sections: sections
		original_sections: alt_copy_sections(sections)
		section_idx_by_name: map[string]int{}
		replaced_sections: map[string][]u8{}
		section_alignment: if elf_class == 32 { 4 } else { 8 }
	}
	saver.update_section_idx()
	return saver
}

pub fn new_alt_saver(in_file string, out_file string, set map[string]brew_runtime.Value) !&AltSaver {
	return new_alt_saver_from_bytes(in_file, out_file, set, os.read_bytes(in_file)!)
}

pub fn alt_fill(fill_byte u8, nbytes int) ![]u8 {
	if nbytes < 0 {
		return error('negative fill size')
	}
	mut result := []u8{len: nbytes}
	mut pending := nbytes
	mut position := 0
	at_once := 0x1000
	for pending >= at_once {
		for index in 0 .. at_once {
			result[position + index] = fill_byte
		}
		position += at_once
		pending -= at_once
	}
	for index in 0 .. pending {
		result[position + index] = fill_byte
	}
	return result
}

pub fn (saver &AltSaver) buf_cstr(offset int) !string {
	return alt_cstring(saver.buffer, offset)
}

pub fn (mut saver AltSaver) buf_move(dst int, src int, count int) ! {
	alt_check(saver.buffer, src, count, 'source buffer range')!
	alt_check(saver.buffer, dst, count, 'destination buffer range')!
	copy := saver.buffer[src..src + count].clone()
	for index, byte in copy {
		saver.buffer[dst + index] = byte
	}
}

pub fn (mut saver AltSaver) with_buf_at(position int, operation AltBufferOperation) ! {
	if position < 0 || position > saver.buffer.len {
		return error('buffer position outside stream')
	}
	operation(mut saver.buffer, position)!
}

pub fn (saver &AltSaver) find_section_idx(name string) ?int {
	if index := saver.section_idx_by_name[name] {
		return index
	}
	return none
}

pub fn (saver &AltSaver) find_section(name string) ?AltSection {
	index := saver.find_section_idx(name) or { return none }
	return saver.sections[index]
}

pub fn (mut saver AltSaver) update_section_idx() {
	saver.section_idx_by_name.clear()
	for index, section in saver.sections {
		saver.section_idx_by_name[section.name] = index
	}
}

pub fn (mut saver AltSaver) buf_grow(new_size int) ! {
	if new_size <= saver.buffer.len {
		return
	}
	if new_size < 0 {
		return error('negative buffer size')
	}
	saver.buffer << []u8{len: new_size - saver.buffer.len}
}

pub fn (saver &AltSaver) dynamic_tags() ![]AltDynamicTag {
	section := saver.find_section('.dynamic') or { return []AltDynamicTag{} }
	if section.header.sh_type == alt_sht_nobits {
		return []AltDynamicTag{}
	}
	entry_size := if saver.elf_class == 32 { 8 } else { 16 }
	mut result := []AltDynamicTag{}
	mut offset := int(section.header.sh_offset)
	end := offset + int(section.header.sh_size)
	for offset + entry_size <= end && offset + entry_size <= saver.buffer.len {
		d_tag_bits := alt_read_uint(saver.buffer, offset, entry_size / 2, saver.endian)!
		d_tag := if saver.elf_class == 32 { i64(i32(u32(d_tag_bits))) } else { i64(d_tag_bits) }
		d_val := alt_read_uint(saver.buffer, offset + entry_size / 2, entry_size / 2, saver.endian)!
		if d_tag == alt_dt_null {
			break
		}
		result << AltDynamicTag{ d_tag: d_tag, d_val: d_val, offset: offset }
		offset += entry_size
	}
	return result
}

fn (mut saver AltSaver) write_dynamic_tag(tag AltDynamicTag) ! {
	entry_size := if saver.elf_class == 32 { 8 } else { 16 }
	alt_write_uint(mut saver.buffer, tag.offset, entry_size / 2, saver.endian, u64(tag.d_tag))!
	alt_write_uint(mut saver.buffer, tag.offset + entry_size / 2, entry_size / 2, saver.endian, tag.d_val)!
}

pub fn (saver &AltSaver) collect_runpath_tags() !map[string]AltRunpathTag {
	mut result := map[string]AltRunpathTag{}
	for tag in saver.dynamic_tags()! {
		kind := if tag.d_tag == alt_dt_rpath {
			'rpath'
		} else if tag.d_tag == alt_dt_runpath {
			'runpath'
		} else {
			continue
		}
		result[kind] = AltRunpathTag{ offset: tag.offset, header: tag }
	}
	return result
}

pub fn (mut saver AltSaver) resolve_rpath_tag_conflict(mut tags map[string]AltRunpathTag,
	force_rpath bool) !map[string]AltRunpathTag {
	update := if !force_rpath && 'rpath' in tags && 'runpath' !in tags {
		'runpath'
	} else if force_rpath && 'runpath' in tags {
		'rpath'
	} else {
		return tags
	}
	deleted := if update == 'rpath' { 'runpath' } else { 'rpath' }
	mut replacement := tags[deleted]
	replacement.header.d_tag = if update == 'rpath' { alt_dt_rpath } else { alt_dt_runpath }
	saver.write_dynamic_tag(replacement.header)!
	tags[update] = replacement
	tags.delete(deleted)
	return tags
}

pub fn (mut saver AltSaver) replace_section(name string, size int) ![]u8 {
	if size < 0 {
		return error('negative replacement size')
	}
	mut data := if existing := saver.replaced_sections[name] {
		existing.clone()
	} else {
		section := saver.find_section(name) or { return error('section `${name}` not found') }
		alt_check(saver.buffer, int(section.header.sh_offset), int(section.header.sh_size), name)!
		saver.buffer[int(section.header.sh_offset)..int(section.header.sh_offset + section.header.sh_size)].clone()
	}
	if data.len < size {
		data << []u8{len: size - data.len}
	} else if data.len > size {
		data = data[..size].clone()
		data << u8(0)
	}
	saver.replaced_sections[name] = data.clone()
	return data
}

pub fn (mut saver AltSaver) modify_interpreter() {
	if value := saver.set['interpreter'] {
		mut replacement := value.as_string().bytes()
		replacement << u8(0)
		saver.replaced_sections['.interp'] = replacement
	}
}

pub fn (mut saver AltSaver) modify_needed() {
	panic('NotImplementedError: modify_needed')
}

pub fn (mut saver AltSaver) modify_soname() {
	if saver.ehdr.e_type == alt_et_dyn {
		panic('NotImplementedError: modify_soname')
	}
}

pub fn (mut saver AltSaver) modify_rpath_helper(new_rpath string, force_rpath bool) ! {
	dynstr := saver.find_section('.dynstr') or { return error('section `.dynstr` not found') }
	mut tags := saver.collect_runpath_tags()!
	tags = saver.resolve_rpath_tag_conflict(mut tags, force_rpath)!
	mut old_rpath := ''
	mut rpath_offset := -1
	if 'runpath' in tags {
		rpath_offset = int(dynstr.header.sh_offset + tags['runpath'].header.d_val)
	} else if 'rpath' in tags {
		rpath_offset = int(dynstr.header.sh_offset + tags['rpath'].header.d_val)
	}
	if rpath_offset >= 0 {
		old_rpath = saver.buf_cstr(rpath_offset)!
	}
	if old_rpath == new_rpath {
		return
	}
	if rpath_offset >= 0 {
		for index in 0 .. old_rpath.len {
			saver.buffer[rpath_offset + index] = `X`
		}
	}
	if rpath_offset >= 0 && new_rpath.len <= old_rpath.len {
		for index, byte in new_rpath.bytes() {
			saver.buffer[rpath_offset + index] = byte
		}
		saver.buffer[rpath_offset + new_rpath.len] = 0
		return
	}
	mut replacement := saver.replace_section('.dynstr', int(dynstr.header.sh_size) + new_rpath.len + 1)!
	new_index := int(dynstr.header.sh_size)
	for index, byte in new_rpath.bytes() {
		replacement[new_index + index] = byte
	}
	replacement[new_index + new_rpath.len] = 0
	saver.replaced_sections['.dynstr'] = replacement
	for _, item in tags {
		mut tag := item.header
		tag.d_val = u64(new_index)
		saver.write_dynamic_tag(tag)!
	}
	if tags.len == 0 {
		saver.add_dt_rpath(if force_rpath { alt_dt_rpath } else { alt_dt_runpath }, u64(new_index))!
	}
}

pub fn (mut saver AltSaver) modify_rpath() ! {
	saver.modify_rpath_helper((saver.set['rpath'] or { return }).as_string(), true)!
}

pub fn (mut saver AltSaver) modify_runpath() ! {
	saver.modify_rpath_helper((saver.set['runpath'] or { return }).as_string(), false)!
}

pub fn (mut saver AltSaver) add_segment(header AltProgramHeader) {
	saver.segments << AltSegment{ header: header }
	saver.ehdr.e_phnum++
}

pub fn (mut saver AltSaver) add_dt_rpath(d_tag i64, d_val u64) ! {
	tags := saver.dynamic_tags()!
	if tags.len == 0 {
		return error('no dynamic tags')
	}
	entry_size := if saver.elf_class == 32 { 8 } else { 16 }
	dynamic := saver.find_section('.dynamic') or { return error('section `.dynamic` not found') }
	mut replacement := saver.replace_section('.dynamic', int(dynamic.header.sh_size) + entry_size)!
	replacement_size := (tags.len + 1) * entry_size
	copy := replacement[..replacement_size].clone()
	for index, byte in copy {
		replacement[entry_size + index] = byte
	}
	alt_write_uint(mut replacement, 0, entry_size / 2, saver.endian, u64(d_tag))!
	alt_write_uint(mut replacement, entry_size / 2, entry_size / 2, saver.endian, d_val)!
	saver.replaced_sections['.dynamic'] = replacement
}

pub fn (saver &AltSaver) new_section_idx(old_index int) !int {
	if old_index == 0 || old_index >= int(alt_shn_loreserve) {
		return -1
	}
	if old_index < 0 || old_index >= saver.original_sections.len {
		return error('old section index ${old_index} does not exist')
	}
	return saver.find_section_idx(saver.original_sections[old_index].name) or { -1 }
}

pub fn (saver &AltSaver) page_size() int {
	return alt_page_size_for(saver.ehdr.e_machine)
}

fn (mut saver AltSaver) write_header() ! {
	value_size := if saver.elf_class == 32 { 4 } else { 8 }
	phoff_pos := 24 + value_size
	shoff_pos := phoff_pos + value_size
	flags_pos := shoff_pos + value_size
	alt_write_uint(mut saver.buffer, 16, 2, saver.endian, saver.ehdr.e_type)!
	alt_write_uint(mut saver.buffer, 18, 2, saver.endian, saver.ehdr.e_machine)!
	alt_write_uint(mut saver.buffer, 24, value_size, saver.endian, saver.ehdr.e_entry)!
	alt_write_uint(mut saver.buffer, phoff_pos, value_size, saver.endian, saver.ehdr.e_phoff)!
	alt_write_uint(mut saver.buffer, shoff_pos, value_size, saver.endian, saver.ehdr.e_shoff)!
	alt_write_uint(mut saver.buffer, flags_pos, 4, saver.endian, saver.ehdr.e_flags)!
	alt_write_uint(mut saver.buffer, flags_pos + 4, 2, saver.endian, saver.ehdr.e_ehsize)!
	alt_write_uint(mut saver.buffer, flags_pos + 6, 2, saver.endian, saver.ehdr.e_phentsize)!
	alt_write_uint(mut saver.buffer, flags_pos + 8, 2, saver.endian, saver.ehdr.e_phnum)!
	alt_write_uint(mut saver.buffer, flags_pos + 10, 2, saver.endian, saver.ehdr.e_shentsize)!
	alt_write_uint(mut saver.buffer, flags_pos + 12, 2, saver.endian, saver.ehdr.e_shnum)!
	alt_write_uint(mut saver.buffer, flags_pos + 14, 2, saver.endian, saver.ehdr.e_shstrndx)!
}

fn (mut saver AltSaver) write_program_header(offset int, header AltProgramHeader) ! {
	if saver.elf_class == 32 {
		for position, value in [u64(header.p_type), header.p_offset, header.p_vaddr, header.p_paddr,
			header.p_filesz, header.p_memsz, u64(header.p_flags), header.p_align] {
			alt_write_uint(mut saver.buffer, offset + position * 4, 4, saver.endian, value)!
		}
		return
	}
	alt_write_uint(mut saver.buffer, offset, 4, saver.endian, header.p_type)!
	alt_write_uint(mut saver.buffer, offset + 4, 4, saver.endian, header.p_flags)!
	for position, value in [header.p_offset, header.p_vaddr, header.p_paddr, header.p_filesz,
		header.p_memsz, header.p_align] {
		alt_write_uint(mut saver.buffer, offset + 8 + position * 8, 8, saver.endian, value)!
	}
}

fn (mut saver AltSaver) write_section_header(offset int, header AltSectionHeader) ! {
	alt_write_uint(mut saver.buffer, offset, 4, saver.endian, header.sh_name)!
	alt_write_uint(mut saver.buffer, offset + 4, 4, saver.endian, header.sh_type)!
	value_size := if saver.elf_class == 32 { 4 } else { 8 }
	mut cursor := offset + 8
	for value in [header.sh_flags, header.sh_addr, header.sh_offset, header.sh_size] {
		alt_write_uint(mut saver.buffer, cursor, value_size, saver.endian, value)!
		cursor += value_size
	}
	alt_write_uint(mut saver.buffer, cursor, 4, saver.endian, header.sh_link)!
	alt_write_uint(mut saver.buffer, cursor + 4, 4, saver.endian, header.sh_info)!
	cursor += 8
	alt_write_uint(mut saver.buffer, cursor, value_size, saver.endian, header.sh_addralign)!
	alt_write_uint(mut saver.buffer, cursor + value_size, value_size, saver.endian, header.sh_entsize)!
}

pub fn (mut saver AltSaver) sort_phdrs() {
	saver.segments.sort_with_compare(fn (left &AltSegment, right &AltSegment) int {
		if right.header.p_type == alt_pt_phdr {
			return 1
		}
		if left.header.p_type == alt_pt_phdr {
			return -1
		}
		return if left.header.p_paddr < right.header.p_paddr {
			-1
		} else if left.header.p_paddr > right.header.p_paddr { 1 } else { 0 }
	})
}

pub fn (mut saver AltSaver) write_phdrs_to_buf() ! {
	saver.sort_phdrs()
	saver.buf_grow(int(saver.ehdr.e_phoff) + saver.segments.len * int(saver.ehdr.e_phentsize))!
	for index, segment in saver.segments {
		saver.write_program_header(int(saver.ehdr.e_phoff) + index * int(saver.ehdr.e_phentsize), segment.header)!
	}
}

pub fn (saver &AltSaver) meta_sym_pack() AltSymbolMeta {
	if saver.elf_class == 32 {
		return AltSymbolMeta{
			num_bytes: 16
			code: if saver.endian == .little {
				'VVVCCv'} else {
				'NNNCCn'}
			st_info: 3
			st_shndx: 5
			st_value: 1
		}
	}
	return AltSymbolMeta{
		num_bytes: 24
		code: if saver.endian == .little {
			'VCCvQ<Q<'} else {
			'NCCnQ>Q>'}
		st_info: 1
		st_shndx: 3
		st_value: 4
	}
}

pub fn (saver &AltSaver) symbols(header AltSectionHeader) ![][]u64 {
	if header.sh_type !in [alt_sht_symtab, alt_sht_dynsym] {
		return [][]u64{}
	}
	meta := saver.meta_sym_pack()
	mut result := [][]u64{}
	for entry in 0 .. int(header.sh_size) / meta.num_bytes {
		offset := int(header.sh_offset) + entry * meta.num_bytes
		if saver.elf_class == 32 {
			result << [alt_read_uint(saver.buffer, offset, 4, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 4, 4, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 8, 4, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 12, 1, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 13, 1, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 14, 2, saver.endian)!]
		} else {
			result << [alt_read_uint(saver.buffer, offset, 4, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 4, 1, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 5, 1, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 6, 2, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 8, 8, saver.endian)!,
				alt_read_uint(saver.buffer, offset + 16, 8, saver.endian)!]
		}
	}
	return result
}

fn (mut saver AltSaver) write_symbol(header AltSectionHeader, entry int, values []u64) ! {
	meta := saver.meta_sym_pack()
	offset := int(header.sh_offset) + entry * meta.num_bytes
	sizes := if saver.elf_class == 32 { [4, 4, 4, 1, 1, 2] } else { [4, 1, 1, 2, 8, 8] }
	mut cursor := offset
	for index, size in sizes {
		alt_write_uint(mut saver.buffer, cursor, size, saver.endian, values[index])!
		cursor += size
	}
}

pub fn (saver &AltSaver) collect_section_to_section_refs() AltSectionReferences {
	mut linkage := map[string]string{}
	mut info := map[string]string{}
	for section in saver.sections {
		header := section.header
		if header.sh_link != 0 && int(header.sh_link) < saver.sections.len {
			linkage[section.name] = saver.sections[int(header.sh_link)].name
		}
		if header.sh_info != 0 && header.sh_type in [alt_sht_rel, alt_sht_rela] && int(header.sh_info) < saver.sections.len {
			info[section.name] = saver.sections[int(header.sh_info)].name
		}
	}
	return AltSectionReferences{ linkage: linkage, info: info }
}

pub fn (mut saver AltSaver) restore_section_to_section_refs(refs AltSectionReferences) {
	for mut section in saver.sections {
		if section.header.sh_link != 0 {
			if target := refs.linkage[section.name] {
				section.header.sh_link = u32(saver.find_section_idx(target) or { 0 })
			}
		}
		if section.header.sh_info != 0 && section.header.sh_type in [alt_sht_rel, alt_sht_rela] {
			if target := refs.info[section.name] {
				section.header.sh_info = u32(saver.find_section_idx(target) or { 0 })
			}
		}
	}
}

pub fn (mut saver AltSaver) sort_shdrs() {
	if saver.sections.len == 0 {
		return
	}
	refs := saver.collect_section_to_section_refs()
	shstr_offset := saver.sections[int(saver.ehdr.e_shstrndx)].header.sh_offset
	saver.sections.sort_with_compare(fn (left &AltSection, right &AltSection) int {
		return if left.header.sh_offset < right.header.sh_offset {
			-1
		} else if left.header.sh_offset > right.header.sh_offset { 1 } else { 0 }
	})
	saver.update_section_idx()
	saver.restore_section_to_section_refs(refs)
	for index, section in saver.sections {
		if section.header.sh_offset == shstr_offset {
			saver.ehdr.e_shstrndx = u16(index)
		}
	}
}

pub fn (saver &AltSaver) jmprel_section_name() !string {
	for name in ['.rel.plt', '.rela.plt', '.rela.IA_64.pltoff'] {
		if saver.find_section_idx(name) != none {
			return name
		}
	}
	return error('cannot find section corresponding to DT_JMPREL')
}

pub fn (saver &AltSaver) dyn_tag_to_section_name(tag i64) !string {
	return match tag {
		alt_dt_strtab, alt_dt_strsz { '.dynstr' }
		alt_dt_symtab { '.dynsym' }
		alt_dt_hash { '.hash' }
		alt_dt_gnu_hash {
			if saver.find_section_idx('.gnu.hash') != none { '.gnu.hash' } else { '' }
		}
		alt_dt_mips_xhash {
			if saver.ehdr.e_machine == alt_em_mips { '.MIPS.xhash' } else { '' }
		}
		alt_dt_jmprel { saver.jmprel_section_name()! }
		alt_dt_rel {
			if saver.find_section_idx('.rel.dyn') != none {
				'.rel.dyn'
			} else if saver.find_section_idx('.rel.got') != none { '.rel.got' } else { '' }
		}
		alt_dt_rela {
			if saver.find_section_idx('.rela.dyn') != none { '.rela.dyn' } else { '' }
		}
		alt_dt_verneed { '.gnu.version_r' }
		alt_dt_versym { '.gnu.version' }
		else { '' }
	}
}

pub fn (saver &AltSaver) dyn_tag_to_shdr(tag i64) !AltSectionHeader {
	name := saver.dyn_tag_to_section_name(tag)!
	if name == '' {
		return error('dynamic tag has no corresponding section')
	}
	section := saver.find_section(name) or { return error('section `${name}` not found') }
	return section.header
}

pub fn (mut saver AltSaver) sync_dyn_tags() ! {
	tags := saver.dynamic_tags()!
	mut table_offset := -1
	for original in tags {
		mut tag := original
		if table_offset < 0 {
			table_offset = tag.offset
		}
		if tag.d_tag == alt_dt_mips_rld_map_rel {
			if rld_map := saver.find_section('.rld_map') {
				dynamic := saver.find_section('.dynamic') or { return error('section `.dynamic` not found') }
				tag.d_val = rld_map.header.sh_addr - u64(tag.offset - table_offset) - dynamic.header.sh_addr
			} else {
				tag.d_val = 0
			}
		} else {
			header := saver.dyn_tag_to_shdr(tag.d_tag) or { continue }
			tag.d_val = if tag.d_tag == alt_dt_strsz { header.sh_size } else { header.sh_addr }
		}
		saver.write_dynamic_tag(tag)!
	}
}

pub fn (mut saver AltSaver) write_shdrs_to_buf() ! {
	if int(saver.ehdr.e_shnum) != saver.sections.len {
		return error('ehdr.e_shnum != sections count')
	}
	saver.sort_shdrs()
	saver.buf_grow(int(saver.ehdr.e_shoff) + saver.sections.len * int(saver.ehdr.e_shentsize))!
	for index, section in saver.sections {
		saver.write_section_header(int(saver.ehdr.e_shoff) + index * int(saver.ehdr.e_shentsize), section.header)!
	}
	saver.sync_dyn_tags()!
}

pub fn (mut saver AltSaver) rewrite_headers(phdr_address u64) ! {
	for mut segment in saver.segments {
		if segment.header.p_type == alt_pt_phdr {
			segment.header.p_offset = saver.ehdr.e_phoff
			segment.header.p_vaddr = phdr_address
			segment.header.p_paddr = phdr_address
			segment.header.p_filesz = u64(saver.ehdr.e_phentsize) * u64(saver.segments.len)
			segment.header.p_memsz = segment.header.p_filesz
			break
		}
	}
	saver.write_phdrs_to_buf()!
	saver.write_shdrs_to_buf()!
	meta := saver.meta_sym_pack()
	for section in saver.sections {
		mut symbols := saver.symbols(section.header)!
		for entry, mut symbol in symbols {
			old_index := int(symbol[meta.st_shndx])
			new_index := saver.new_section_idx(old_index) or { continue }
			if new_index < 0 {
				continue
			}
			symbol[meta.st_shndx] = u64(new_index)
			if symbol[meta.st_info] & 0xf == alt_stt_section {
				symbol[meta.st_value] = saver.sections[new_index].header.sh_addr
			}
			saver.write_symbol(section.header, entry, symbol)!
		}
	}
}

pub fn (saver &AltSaver) replaced_section_indices() ![]int {
	mut indices := []int{}
	mut last_replaced := 0
	for index, section in saver.sections {
		if section.name in saver.replaced_sections {
			last_replaced = index
			indices << index
		}
	}
	if last_replaced == 0 {
		return error('last_replaced = 0')
	}
	if last_replaced + 1 >= saver.sections.len {
		return error('last_replaced + 1 >= sections size')
	}
	return indices
}

pub fn (mut saver AltSaver) start_replacement_shdr() !AltSectionHeader {
	indices := saver.replaced_section_indices()!
	last := indices[indices.len - 1]
	mut result := saver.sections[last + 1].header
	mut previous_name := ''
	for index in 1 .. last + 1 {
		section := saver.sections[index]
		if (section.header.sh_type == alt_sht_progbits && section.name != '.interp') || previous_name == '.dynstr' {
			result = section.header
			break
		} else if section.name !in saver.replaced_sections {
			saver.replace_section(section.name, int(section.header.sh_size))!
		}
		previous_name = section.name
	}
	return result
}

pub fn (mut saver AltSaver) copy_shdrs_to_eof() ! {
	new_offset := saver.buffer.len
	sh_size := int(saver.ehdr.e_shoff) + int(saver.ehdr.e_shnum) * int(saver.ehdr.e_shentsize)
	saver.buf_grow(saver.buffer.len + sh_size)!
	saver.ehdr.e_shoff = u64(new_offset)
	if int(saver.ehdr.e_shnum) != saver.sections.len {
		return error('ehdr.e_shnum != sections size')
	}
	for index in 1 .. saver.sections.len {
		saver.write_section_header(int(saver.ehdr.e_shoff) + index * int(saver.ehdr.e_shentsize), saver.sections[index].header)!
	}
}

pub fn (mut saver AltSaver) overwrite_replaced_sections() ! {
	for name, _ in saver.replaced_sections {
		section := saver.find_section(name) or { continue }
		if section.header.sh_type == alt_sht_nobits {
			continue
		}
		alt_check(saver.buffer, int(section.header.sh_offset), int(section.header.sh_size), name)!
		for index in 0 .. int(section.header.sh_size) {
			saver.buffer[int(section.header.sh_offset) + index] = `X`
		}
	}
}

pub fn (saver &AltSaver) find_or_create_section_header(name string) AltSectionHeader {
	return (saver.find_section(name) or { return AltSectionHeader{} }).header
}

pub fn (saver &AltSaver) phdr_indices_by_type(kind u32) []int {
	mut result := []int{}
	for index, segment in saver.segments {
		if segment.header.p_type == kind {
			result << index
		}
	}
	return result
}

pub fn sync_sec_to_seg(header AltSectionHeader, mut program AltProgramHeader) {
	program.p_offset = header.sh_offset
	program.p_vaddr = header.sh_addr
	program.p_paddr = header.sh_addr
	program.p_filesz = header.sh_size
	program.p_memsz = header.sh_size
}

pub fn (mut saver AltSaver) section_sync_correspondence_segment(name string,
	header AltSectionHeader) {
	kind := match name {
		'.interp' { alt_pt_interp }
		'.dynamic' { alt_pt_dynamic }
		'.MIPS.abiflags' { alt_pt_mips_abiflags }
		'.note.gnu.property' { alt_pt_gnu_property }
		else {
			return
		}
	}
	for index in saver.phdr_indices_by_type(kind) {
		sync_sec_to_seg(header, mut saver.segments[index].header)
	}
}

pub fn section_bounds_within_segment(section_start u64, section_end u64, program_start u64,
	program_end u64) bool {
	return (section_start >= program_start && section_start < program_end) || (section_end > program_start && section_end <= program_end)
}

pub fn (mut saver AltSaver) sync_note_segment(original_offset u64, original_size u64,
	header AltSectionHeader) ! {
	if header.sh_type != alt_sht_note {
		return
	}
	for index in saver.phdr_indices_by_type(alt_pt_note) {
		program := saver.segments[index].header
		section_end := original_offset + original_size
		program_end := program.p_offset + program.p_filesz
		if !section_bounds_within_segment(original_offset, section_end, program.p_offset, program_end) {
			continue
		}
		if program.p_offset != original_offset || program_end != section_end {
			return error('unsupported overlap of SHT_NOTE and PT_NOTE')
		}
		sync_sec_to_seg(header, mut saver.segments[index].header)
	}
}

pub fn (saver &AltSaver) write_section_alignment(mut header AltSectionHeader) {
	if header.sh_type == alt_sht_note && header.sh_addralign <= u64(saver.section_alignment) {
		return
	}
	header.sh_addralign = u64(saver.section_alignment)
}

pub fn (mut saver AltSaver) write_replaced_sections(initial_offset int, start_address u64,
	start_offset int) !int {
	saver.overwrite_replaced_sections()!
	mut names := saver.replaced_sections.keys()
	names.sort()
	mut current := initial_offset
	for name in names {
		data := saver.replaced_sections[name]
		saver.buf_grow(current + data.len)!
		for index, byte in data {
			saver.buffer[current + index] = byte
		}
		mut header := saver.find_or_create_section_header(name)
		original_offset := header.sh_offset
		original_size := header.sh_size
		header.sh_offset = u64(current)
		header.sh_addr = start_address + u64(current - start_offset)
		header.sh_size = u64(data.len)
		saver.write_section_alignment(mut header)
		if index := saver.find_section_idx(name) {
			saver.sections[index].header = header
		}
		saver.section_sync_correspondence_segment(name, header)
		saver.sync_note_segment(original_offset, original_size, header)!
		current += int(alt_alignup(u64(data.len), u64(saver.section_alignment)))
	}
	saver.replaced_sections.clear()
	return current
}

pub fn (saver &AltSaver) sections_at_aligned_offset(offset u64) []AltSection {
	mut result := []AltSection{}
	for section in saver.sections {
		if section.header.sh_offset == alt_alignup(offset, section.header.sh_addralign) {
			result << section
		}
	}
	return result
}

pub fn (mut saver AltSaver) normalize_note_segment_at(program_index int) ![]AltProgramHeader {
	mut program := saver.segments[program_index].header
	start_offset := program.p_offset
	mut current := start_offset
	end_offset := start_offset + program.p_filesz
	mut created := []AltProgramHeader{}
	for current < end_offset {
		mut found := ?AltSection(none)
		for section in saver.sections_at_aligned_offset(current) {
			if section.header.sh_type == alt_sht_note {
				found = section
				break
			}
		}
		section := found or { return error('cannot normalize PT_NOTE segment: non-contiguous SHT_NOTE sections') }
		size := section.header.sh_size
		current = section.header.sh_offset
		if size == 0 || current + size > end_offset {
			return error('cannot normalize PT_NOTE segment: partially mapped SHT_NOTE section')
		}
		mut new_program := program
		new_program.p_offset = current
		new_program.p_vaddr = program.p_vaddr + current - start_offset
		new_program.p_paddr = program.p_paddr + current - start_offset
		new_program.p_filesz = size
		new_program.p_memsz = size
		if current == start_offset {
			program = new_program
			saver.segments[program_index].header = new_program
		} else {
			created << new_program
		}
		current += size
	}
	return created
}

pub fn (mut saver AltSaver) normalize_note_segments() ! {
	mut has_replaced_note := false
	for name, _ in saver.replaced_sections {
		if section := saver.find_section(name) {
			if section.header.sh_type == alt_sht_note {
				has_replaced_note = true
				break
			}
		}
	}
	if !has_replaced_note {
		return
	}
	indices := saver.phdr_indices_by_type(alt_pt_note)
	mut created := []AltProgramHeader{}
	for index in indices {
		program := saver.segments[index].header
		if saver.sections.all(it.header.sh_offset < program.p_offset || it.header.sh_offset >= program.p_offset + program.p_filesz) {
			continue
		}
		created << saver.normalize_note_segment_at(index)!
	}
	for program in created {
		saver.add_segment(program)
	}
}

pub fn (mut saver AltSaver) shift_sections(shift u64, start_offset u64) {
	if saver.ehdr.e_shoff >= start_offset {
		saver.ehdr.e_shoff += shift
	}
	for index in 1 .. saver.sections.len {
		if saver.sections[index].header.sh_offset >= start_offset {
			saver.sections[index].header.sh_offset += shift
		}
	}
}

pub fn (saver &AltSaver) shift_segment_offset(mut program AltProgramHeader, shift u64) {
	program.p_offset += shift
	if program.p_align != 0 && (program.p_vaddr - program.p_offset) % program.p_align != 0 {
		program.p_align = u64(saver.page_size())
	}
}

pub fn shift_segment_virtual_address(mut program AltProgramHeader, shift u64) {
	if program.p_paddr > shift {
		program.p_paddr -= shift
	}
	if program.p_vaddr > shift {
		program.p_vaddr -= shift
	}
}

pub fn (mut saver AltSaver) shift_segments(shift u64, start_offset u64) !(int, u64) {
	mut split_index := -1
	mut split_shift := u64(0)
	for index, mut segment in saver.segments {
		mut start := segment.header.p_offset
		if start <= start_offset && start_offset < start + segment.header.p_filesz && segment.header.p_type == alt_pt_load {
			if split_index != -1 {
				return error('PT_LOAD segments overlapped, unable to shift segments')
			}
			split_index = index
			split_shift = start_offset - start
			segment.header.p_offset = start_offset
			segment.header.p_memsz -= split_shift
			segment.header.p_filesz -= split_shift
			segment.header.p_paddr += split_shift
			segment.header.p_vaddr += split_shift
			start = start_offset
		}
		if start >= start_offset {
			saver.shift_segment_offset(mut segment.header, shift)
		} else {
			shift_segment_virtual_address(mut segment.header, shift)
		}
	}
	if split_index == -1 {
		return error('No PT_LOAD found covers offset 0x${start_offset.hex()}')
	}
	return split_index, split_shift
}

pub fn (mut saver AltSaver) shift_file(extra_pages int, start_offset int, extra_bytes int) ! {
	if start_offset < int(saver.ehdr.e_ehsize) {
		return error('start_offset(${start_offset}) < ehdr.num_bytes')
	}
	old_size := saver.buffer.len
	if old_size <= start_offset {
		return error('old size <= start_offset(${start_offset})')
	}
	shift := extra_pages * saver.page_size()
	saver.buf_grow(old_size + shift)!
	saver.buf_move(start_offset + shift, start_offset, old_size - start_offset)!
	for index in 0 .. shift {
		saver.buffer[start_offset + index] = 0
	}
	saver.ehdr.e_phoff = u64(saver.ehdr.e_ehsize)
	saver.shift_sections(u64(shift), u64(start_offset))
	split_index, split_shift := saver.shift_segments(u64(shift), u64(start_offset))!
	split := saver.segments[split_index].header
	saver.add_segment(AltProgramHeader{
		p_type: alt_pt_load
		p_offset: split.p_offset - split_shift - u64(shift)
		p_vaddr: split.p_vaddr - split_shift - u64(shift)
		p_paddr: split.p_paddr - split_shift - u64(shift)
		p_filesz: split_shift + u64(extra_bytes)
		p_memsz: split_shift + u64(extra_bytes)
		p_flags: alt_pf_r | alt_pf_w
		p_align: u64(saver.page_size())
	})
}

pub fn (mut saver AltSaver) replace_sections_in_the_way_of_phdr() ! {
	note_count := saver.sections.filter(it.header.sh_type == alt_sht_note).len
	if saver.segments.len == 0 {
		return error('no program headers')
	}
	pht_size := int(saver.ehdr.e_ehsize) + (saver.segments.len + note_count + 1) * int(saver.ehdr.e_phentsize)
	for index, section in saver.sections {
		if index == 0 || section.name in saver.replaced_sections {
			continue
		}
		if section.header.sh_offset > u64(pht_size) {
			break
		}
		saver.replace_section(section.name, int(section.header.sh_size))!
	}
}

fn (saver &AltSaver) replacement_space() int {
	mut result := 0
	for _, data in saver.replaced_sections {
		result += int(alt_alignup(u64(data.len), u64(saver.section_alignment)))
	}
	return result
}

pub fn (mut saver AltSaver) rewrite_sections_library() ! {
	mut start_page := u64(0)
	mut first_page := u64(0)
	for segment in saver.segments {
		program := segment.header
		this_page := alt_alignup(program.p_vaddr + program.p_memsz, u64(saver.page_size()))
		if this_page > start_page {
			start_page = this_page
		}
		if program.p_type == alt_pt_phdr {
			first_page = program.p_vaddr - program.p_offset
		}
	}
	saver.replace_sections_in_the_way_of_phdr()!
	needed_space := saver.replacement_space()
	start_offset := int(alt_alignup(u64(saver.buffer.len), u64(saver.page_size())))
	saver.buf_grow(start_offset + needed_space)!
	if u64(start_offset) > start_page && saver.segments.any(it.header.p_type == alt_pt_interp) {
		start_page = u64(start_offset)
	}
	saver.ehdr.e_phoff = u64(saver.ehdr.e_ehsize)
	saver.add_segment(AltProgramHeader{
		p_type: alt_pt_load
		p_offset: u64(start_offset)
		p_vaddr: start_page
		p_paddr: start_page
		p_filesz: u64(needed_space)
		p_memsz: u64(needed_space)
		p_flags: alt_pf_r | alt_pf_w
		p_align: u64(saver.page_size())
	})
	saver.normalize_note_segments()!
	current := saver.write_replaced_sections(start_offset, start_page, start_offset)!
	if current != start_offset + needed_space {
		return error('current offset != start_offset + needed_space')
	}
	saver.rewrite_headers(first_page + saver.ehdr.e_phoff)!
}

pub fn (mut saver AltSaver) rewrite_sections_executable() ! {
	saver.sort_shdrs()
	header := saver.start_replacement_shdr()!
	mut start_offset := int(header.sh_offset)
	start_address := int(header.sh_addr)
	mut first_page := start_address - start_offset
	if start_address % saver.page_size() != start_offset % saver.page_size() {
		return error('start_addr != start_offset (mod PAGE_SIZE)')
	}
	if saver.ehdr.e_shoff < u64(start_offset) {
		saver.copy_shdrs_to_eof()!
	}
	saver.normalize_note_segments()!
	if saver.segments.len == 0 {
		return error('no program headers')
	}
	mut needed_space := int(saver.ehdr.e_ehsize) + saver.segments.len * int(saver.ehdr.e_phentsize) + saver.replacement_space()
	if needed_space > start_offset {
		needed_space += int(saver.ehdr.e_phentsize)
		extra_bytes := needed_space - start_offset
		needed_pages := int(alt_alignup(u64(extra_bytes), u64(saver.page_size()))) / saver.page_size()
		if needed_pages * saver.page_size() > first_page {
			return error('virtual address space underrun')
		}
		saver.shift_file(needed_pages, start_offset, extra_bytes)!
		first_page -= needed_pages * saver.page_size()
		start_offset += needed_pages * saver.page_size()
	}
	mut current := int(saver.ehdr.e_ehsize) + saver.segments.len * int(saver.ehdr.e_phentsize)
	for index in current .. start_offset {
		saver.buffer[index] = 0
	}
	current = saver.write_replaced_sections(current, u64(first_page), 0)!
	if current != needed_space {
		return error('current offset(${current}) != needed_space(${needed_space})')
	}
	saver.rewrite_headers(u64(first_page) + saver.ehdr.e_phoff)!
}

pub fn (mut saver AltSaver) rewrite_sections() ! {
	if saver.replaced_sections.len == 0 {
		return
	}
	match saver.ehdr.e_type {
		alt_et_dyn { saver.rewrite_sections_library()! }
		alt_et_exec { saver.rewrite_sections_executable()! }
		else {
			return error('unknown ELF type')
		}
	}
}

pub fn (mut saver AltSaver) patch_out() ! {
	saver.write_header()!
	os.write_file_array(saver.out_file, saver.buffer)!
}

fn alt_value_truthy(value brew_runtime.Value) bool {
	return value.type_name != 'NilClass' && !(value.type_name == 'Bool' && !value.bool_data)
}

pub fn (mut saver AltSaver) save() ! {
	for method, value in saver.set {
		if !alt_value_truthy(value) {
			continue
		}
		match method.trim_left(':') {
			'interpreter' { saver.modify_interpreter() }
			'needed' { saver.modify_needed() }
			'rpath' { saver.modify_rpath()! }
			'runpath' { saver.modify_runpath()! }
			'soname' { saver.modify_soname() }
			else {
				return error('unknown AltSaver modification `${method}`')
			}
		}
	}
	saver.rewrite_sections()!
	if saver.in_file != saver.out_file && os.exists(saver.in_file) {
		os.cp(saver.in_file, saver.out_file)!
	}
	saver.patch_out()!
	if saver.in_file != '' && os.exists(saver.in_file) {
		metadata := os.stat(saver.in_file)!
		os.chmod(saver.out_file, int(metadata.mode))!
	}
}

fn alt_header_value(header AltElfHeader) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Structs::ELF_Ehdr', 'ELF_Ehdr', {
		'e_type':     header.e_type.str()
		'e_machine':  header.e_machine.str()
		'e_entry':    header.e_entry.str()
		'e_phoff':    header.e_phoff.str()
		'e_shoff':    header.e_shoff.str()
		'e_phnum':    header.e_phnum.str()
		'e_shnum':    header.e_shnum.str()
		'e_shstrndx': header.e_shstrndx.str()
	})
}

fn alt_section_header_value(header AltSectionHeader) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Structs::ELF_Shdr', 'ELF_Shdr', {
		'sh_name':      header.sh_name.str()
		'sh_type':      header.sh_type.str()
		'sh_flags':     header.sh_flags.str()
		'sh_addr':      header.sh_addr.str()
		'sh_offset':    header.sh_offset.str()
		'sh_size':      header.sh_size.str()
		'sh_link':      header.sh_link.str()
		'sh_info':      header.sh_info.str()
		'sh_addralign': header.sh_addralign.str()
		'sh_entsize':   header.sh_entsize.str()
	})
}

fn alt_section_value(section AltSection) brew_runtime.Value {
	mut attributes := alt_section_header_value(section.header).attributes.clone()
	attributes['name'] = section.name
	return brew_runtime.structured_value('ELFTools::Sections::Section', section.name, attributes)
}

fn alt_program_header_value(header AltProgramHeader) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Structs::ELF_Phdr', 'ELF_Phdr', {
		'p_type':   header.p_type.str()
		'p_offset': header.p_offset.str()
		'p_vaddr':  header.p_vaddr.str()
		'p_paddr':  header.p_paddr.str()
		'p_filesz': header.p_filesz.str()
		'p_memsz':  header.p_memsz.str()
		'p_flags':  header.p_flags.str()
		'p_align':  header.p_align.str()
	})
}

fn alt_dynamic_tag_value(tag AltDynamicTag) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Structs::ELF_Dyn', 'ELF_Dyn', {
		'd_tag':  tag.d_tag.str()
		'd_val':  tag.d_val.str()
		'offset': tag.offset.str()
	})
}

fn alt_section_header_from_value(value brew_runtime.Value) AltSectionHeader {
	return AltSectionHeader{
		sh_name: u32((value.attribute('sh_name') or { '0' }).u64())
		sh_type: u32((value.attribute('sh_type') or { '0' }).u64())
		sh_flags: (value.attribute('sh_flags') or { '0' }).u64()
		sh_addr: (value.attribute('sh_addr') or { '0' }).u64()
		sh_offset: (value.attribute('sh_offset') or { '0' }).u64()
		sh_size: (value.attribute('sh_size') or { '0' }).u64()
		sh_link: u32((value.attribute('sh_link') or { '0' }).u64())
		sh_info: u32((value.attribute('sh_info') or { '0' }).u64())
		sh_addralign: (value.attribute('sh_addralign') or { '0' }).u64()
		sh_entsize: (value.attribute('sh_entsize') or { '0' }).u64()
	}
}

fn alt_program_header_from_value(value brew_runtime.Value) AltProgramHeader {
	return AltProgramHeader{
		p_type: u32((value.attribute('p_type') or { '0' }).u64())
		p_offset: (value.attribute('p_offset') or { '0' }).u64()
		p_vaddr: (value.attribute('p_vaddr') or { '0' }).u64()
		p_paddr: (value.attribute('p_paddr') or { '0' }).u64()
		p_filesz: (value.attribute('p_filesz') or { '0' }).u64()
		p_memsz: (value.attribute('p_memsz') or { '0' }).u64()
		p_flags: u32((value.attribute('p_flags') or { '0' }).u64())
		p_align: (value.attribute('p_align') or { '0' }).u64()
	}
}

fn alt_saver_value(saver &AltSaver) brew_runtime.Value {
	return brew_runtime.structured_value('PatchELF::AltSaver', 'AltSaver(${saver.in_file})', {
		'alt_saver_address': u64(voidptr(saver)).str()
		'in_file':           saver.in_file
		'out_file':          saver.out_file
	})
}

fn alt_saver_from_args(args []brew_runtime.Value) &AltSaver {
	if args.len == 0 {
		panic('AltSaver method requires a receiver')
	}
	address := args[0].attribute('alt_saver_address') or { panic('invalid AltSaver receiver') }
	return unsafe { &AltSaver(voidptr(address.u64())) }
}

fn alt_runpath_tags_value(tags map[string]AltRunpathTag) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for name, item in tags {
		result[name] = brew_runtime.structured_value('Hash', name, {
			'offset': item.offset.str()
			'd_tag':  item.header.d_tag.str()
			'd_val':  item.header.d_val.str()
		})
	}
	return brew_runtime.map_value(result)
}

fn alt_runpath_tags_from_value(value brew_runtime.Value) map[string]AltRunpathTag {
	mut result := map[string]AltRunpathTag{}
	for name, item in value.map_data {
		offset := (item.attribute('offset') or { '0' }).int()
		result[name] = AltRunpathTag{
			offset: offset
			header: AltDynamicTag{
				d_tag: (item.attribute('d_tag') or { '0' }).i64()
				d_val: (item.attribute('d_val') or { '0' }).u64()
				offset: offset
			}
		}
	}
	return result
}

fn alt_require(args []brew_runtime.Value, count int, name string) {
	if args.len < count {
		panic('${name} requires ${count} argument(s), including receiver')
	}
}

fn alt_sections_value(sections []AltSection) brew_runtime.Value {
	return brew_runtime.array_value(sections.map(alt_section_value(it)))
}

fn alt_programs_value(programs []AltProgramHeader) brew_runtime.Value {
	return brew_runtime.array_value(programs.map(alt_program_header_value(it)))
}

fn alt_refs_value(refs AltSectionReferences) brew_runtime.Value {
	mut linkage := map[string]brew_runtime.Value{}
	mut info := map[string]brew_runtime.Value{}
	for name, target in refs.linkage {
		linkage[name] = brew_runtime.string_value(target)
	}
	for name, target in refs.info {
		info[name] = brew_runtime.string_value(target)
	}
	return brew_runtime.map_value({
		'linkage': brew_runtime.map_value(linkage)
		'info':    brew_runtime.map_value(info)
	})
}

fn alt_refs_from_value(value brew_runtime.Value) AltSectionReferences {
	mut linkage := map[string]string{}
	mut info := map[string]string{}
	if nested := value.map_data['linkage'] {
		for name, target in nested.map_data {
			linkage[name] = target.as_string()
		}
	}
	if nested := value.map_data['info'] {
		for name, target in nested.map_data {
			info[name] = target.as_string()
		}
	}
	return AltSectionReferences{ linkage: linkage, info: info }
}

fn alt_set_from_value(value brew_runtime.Value) map[string]brew_runtime.Value {
	if value.type_name != 'Hash' {
		return map[string]brew_runtime.Value{}
	}
	return value.map_data.clone()
}

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/alt_saver.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fill(char, nbytes)` at line 24.
pub fn ruby_alt_saver_l24_d1_fill(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'fill')
	character := args[args.len - 2].as_string()
	if character.len == 0 {
		panic('fill requires a non-empty character')
	}
	count := int(args[args.len - 1].as_int() or { panic(err) })
	return brew_runtime.string_value((alt_fill(character.bytes()[0], count) or { panic(err) }).bytestr())
}

// Ruby attr_reader `attr_reader :in_file` at line 48.
pub fn ruby_alt_saver_l48_d2_in_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(alt_saver_from_args(args).in_file)
}

// Ruby attr_reader `attr_reader :out_file` at line 49.
pub fn ruby_alt_saver_l49_d3_out_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(alt_saver_from_args(args).out_file)
}

// Ruby method `initialize(in_file, out_file, set)` at line 56.
pub fn ruby_alt_saver_l56_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'AltSaver#initialize')
	saver := new_alt_saver(args[0].as_string(), args[1].as_string(), alt_set_from_value(args[2])) or {
		panic(err)
	}
	return alt_saver_value(saver)
}

// Ruby method `save!` at line 90.
pub fn ruby_alt_saver_l90_d5_save(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.save() or { panic(err) }
	return alt_nil_value()
}

// Ruby attr_reader `attr_reader :ehdr, :endian, :elf_class` at line 102.
pub fn ruby_alt_saver_l102_d6_ehdr(args ...brew_runtime.Value) brew_runtime.Value {
	return alt_header_value(alt_saver_from_args(args).ehdr)
}

// Ruby attr_reader `attr_reader :ehdr, :endian, :elf_class` at line 102.
pub fn ruby_alt_saver_l102_d7_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(alt_saver_from_args(args).endian.str())
}

// Ruby attr_reader `attr_reader :ehdr, :endian, :elf_class` at line 102.
pub fn ruby_alt_saver_l102_d8_elf_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(alt_saver_from_args(args).elf_class)
}

// Ruby method `old_sections` at line 104.
pub fn ruby_alt_saver_l104_d9_old_sections(args ...brew_runtime.Value) brew_runtime.Value {
	return alt_sections_value(alt_saver_from_args(args).original_sections)
}

// Ruby method `buf_cstr(off)` at line 108.
pub fn ruby_alt_saver_l108_d10_buf_cstr(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'buf_cstr')
	saver := alt_saver_from_args(args)
	return brew_runtime.string_value(saver.buf_cstr(int(args[1].as_int() or { panic(err) })) or {
		panic(err)
	})
}

// Ruby method `buf_move!(dst_idx, src_idx, n_bytes)` at line 121.
pub fn ruby_alt_saver_l121_d11_buf_move(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 4, 'buf_move!')
	mut saver := alt_saver_from_args(args)
	saver.buf_move(int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or { panic(err) }), int(args[3].as_int() or { panic(err) })) or { panic(err) }
	return alt_nil_value()
}

// Ruby method `dynstr` at line 129.
pub fn ruby_alt_saver_l129_d12_dynstr(args ...brew_runtime.Value) brew_runtime.Value {
	saver := alt_saver_from_args(args)
	return alt_section_value(saver.find_section('.dynstr') or { return alt_nil_value() })
}

// Ruby method `each_dynamic_tags` at line 136.
pub fn ruby_alt_saver_l136_d13_each_dynamic_tags(args ...brew_runtime.Value) brew_runtime.Value {
	saver := alt_saver_from_args(args)
	return brew_runtime.array_value((saver.dynamic_tags() or { panic(err) }).map(brew_runtime.array_value([
		alt_dynamic_tag_value(it),
		brew_runtime.int_value(it.offset),
	])))
}

// Ruby method `find_section(sec_name)` at line 159.
pub fn ruby_alt_saver_l159_d14_find_section(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'find_section')
	saver := alt_saver_from_args(args)
	return alt_section_value(saver.find_section(args[1].as_string()) or { return alt_nil_value() })
}

// Ruby method `find_section_idx(sec_name)` at line 166.
pub fn ruby_alt_saver_l166_d15_find_section_idx(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'find_section_idx')
	saver := alt_saver_from_args(args)
	return brew_runtime.int_value(saver.find_section_idx(args[1].as_string()) or {
		return alt_nil_value()
	})
}

// Ruby method `buf_grow!(newsz)` at line 170.
pub fn ruby_alt_saver_l170_d16_buf_grow(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'buf_grow!')
	mut saver := alt_saver_from_args(args)
	saver.buf_grow(int(args[1].as_int() or { panic(err) })) or { panic(err) }
	return alt_nil_value()
}

// Ruby method `modify_interpreter` at line 177.
pub fn ruby_alt_saver_l177_d17_modify_interpreter(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.modify_interpreter()
	return alt_nil_value()
}

// Ruby method `modify_needed` at line 181.
pub fn ruby_alt_saver_l181_d18_modify_needed(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.modify_needed()
	return alt_nil_value()
}

// Ruby method `modify_rpath` at line 187.
pub fn ruby_alt_saver_l187_d19_modify_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.modify_rpath() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `modify_runpath` at line 192.
pub fn ruby_alt_saver_l192_d20_modify_runpath(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.modify_runpath() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `collect_runpath_tags` at line 196.
pub fn ruby_alt_saver_l196_d21_collect_runpath_tags(args ...brew_runtime.Value) brew_runtime.Value {
	saver := alt_saver_from_args(args)
	return alt_runpath_tags_value(saver.collect_runpath_tags() or { panic(err) })
}

// Ruby method `resolve_rpath_tag_conflict(dyn_tags, force_rpath: false)` at line 216.
pub fn ruby_alt_saver_l216_d22_resolve_rpath_tag_conflict(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'resolve_rpath_tag_conflict')
	mut saver := alt_saver_from_args(args)
	force := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	mut tags := alt_runpath_tags_from_value(args[1])
	return alt_runpath_tags_value(saver.resolve_rpath_tag_conflict(mut tags, force) or { panic(err) })
}

// Ruby method `modify_rpath_helper(new_rpath, force_rpath: false)` at line 235.
pub fn ruby_alt_saver_l235_d23_modify_rpath_helper(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'modify_rpath_helper')
	mut saver := alt_saver_from_args(args)
	force := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	saver.modify_rpath_helper(args[1].as_string(), force) or { panic(err) }
	return alt_nil_value()
}

// Ruby method `modify_soname` at line 275.
pub fn ruby_alt_saver_l275_d24_modify_soname(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.modify_soname()
	return alt_nil_value()
}

// Ruby method `add_segment!(**phdr_vals)` at line 282.
pub fn ruby_alt_saver_l282_d25_add_segment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'add_segment!')
	mut saver := alt_saver_from_args(args)
	saver.add_segment(alt_program_header_from_value(args[1]))
	return alt_nil_value()
}

// Ruby method `add_dt_rpath!(d_tag: nil, d_val: nil)` at line 291.
pub fn ruby_alt_saver_l291_d26_add_dt_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'add_dt_rpath!')
	mut saver := alt_saver_from_args(args)
	saver.add_dt_rpath(args[1].as_int() or { panic(err) }, u64(args[2].as_int() or { panic(err) })) or {
		panic(err)
	}
	return alt_nil_value()
}

// Ruby method `new_section_idx(old_shndx)` at line 329.
pub fn ruby_alt_saver_l329_d27_new_section_idx(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'new_section_idx')
	saver := alt_saver_from_args(args)
	index := saver.new_section_idx(int(args[1].as_int() or { panic(err) })) or { panic(err) }
	return if index < 0 { alt_nil_value() } else { brew_runtime.int_value(index) }
}

// Ruby method `page_size` at line 341.
pub fn ruby_alt_saver_l341_d28_page_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(alt_saver_from_args(args).page_size())
}

// Ruby method `patch_out` at line 345.
pub fn ruby_alt_saver_l345_d29_patch_out(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.patch_out() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `replace_section(section_name, size)` at line 355.
pub fn ruby_alt_saver_l355_d30_replace_section(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'replace_section')
	mut saver := alt_saver_from_args(args)
	return brew_runtime.string_value((saver.replace_section(args[1].as_string(), int(args[2].as_int() or { panic(err) })) or { panic(err) }).bytestr())
}

// Ruby method `write_phdrs_to_buf!` at line 375.
pub fn ruby_alt_saver_l375_d31_write_phdrs_to_buf(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.write_phdrs_to_buf() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `write_shdrs_to_buf!` at line 382.
pub fn ruby_alt_saver_l382_d32_write_shdrs_to_buf(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.write_shdrs_to_buf() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `meta_sym_pack` at line 393.
pub fn ruby_alt_saver_l393_d33_meta_sym_pack(args ...brew_runtime.Value) brew_runtime.Value {
	meta := alt_saver_from_args(args).meta_sym_pack()
	return brew_runtime.map_value({
		'num_bytes': brew_runtime.int_value(meta.num_bytes)
		'code':      brew_runtime.string_value(meta.code)
		'st_info':   brew_runtime.int_value(meta.st_info)
		'st_shndx':  brew_runtime.int_value(meta.st_shndx)
		'st_value':  brew_runtime.int_value(meta.st_value)
	})
}

// Ruby method `each_symbol(shdr)` at line 419.
pub fn ruby_alt_saver_l419_d34_each_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'each_symbol')
	saver := alt_saver_from_args(args)
	symbols := saver.symbols(alt_section_header_from_value(args[1])) or { panic(err) }
	mut values := []brew_runtime.Value{}
	for entry, symbol in symbols {
		values << brew_runtime.array_value([
			brew_runtime.array_value(symbol.map(brew_runtime.int_value(i64(it)))),
			brew_runtime.int_value(entry),
		])
	}
	return brew_runtime.array_value(values)
}

// Ruby method `rewrite_headers(phdr_address)` at line 438.
pub fn ruby_alt_saver_l438_d35_rewrite_headers(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'rewrite_headers')
	mut saver := alt_saver_from_args(args)
	saver.rewrite_headers(u64(args[1].as_int() or { panic(err) })) or { panic(err) }
	return alt_nil_value()
}

// Ruby method `rewrite_sections` at line 472.
pub fn ruby_alt_saver_l472_d36_rewrite_sections(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.rewrite_sections() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `replaced_section_indices` at line 485.
pub fn ruby_alt_saver_l485_d37_replaced_section_indices(args ...brew_runtime.Value) brew_runtime.Value {
	saver := alt_saver_from_args(args)
	return brew_runtime.array_value((saver.replaced_section_indices() or { panic(err) }).map(brew_runtime.int_value(it)))
}

// Ruby method `start_replacement_shdr` at line 499.
pub fn ruby_alt_saver_l499_d38_start_replacement_shdr(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	return alt_section_header_value(saver.start_replacement_shdr() or { panic(err) })
}

// Ruby method `copy_shdrs_to_eof` at line 520.
pub fn ruby_alt_saver_l520_d39_copy_shdrs_to_eof(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.copy_shdrs_to_eof() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `rewrite_sections_executable` at line 537.
pub fn ruby_alt_saver_l537_d40_rewrite_sections_executable(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.rewrite_sections_executable() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `replace_sections_in_the_way_of_phdr!` at line 588.
pub fn ruby_alt_saver_l588_d41_replace_sections_in_the_way_of_phdr(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.replace_sections_in_the_way_of_phdr() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `rewrite_sections_library` at line 602.
pub fn ruby_alt_saver_l602_d42_rewrite_sections_library(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.rewrite_sections_library() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `normalize_note_segments` at line 649.
pub fn ruby_alt_saver_l649_d43_normalize_note_segments(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.normalize_note_segments() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `normalize_note_segment(phdr)` at line 668.
pub fn ruby_alt_saver_l668_d44_normalize_note_segment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'normalize_note_segment')
	mut saver := alt_saver_from_args(args)
	target := alt_program_header_from_value(args[1])
	mut index := -1
	for candidate, segment in saver.segments {
		if segment.header.p_type == target.p_type && segment.header.p_offset == target.p_offset {
			index = candidate
			break
		}
	}
	if index < 0 {
		panic('program header not found')
	}
	return alt_programs_value(saver.normalize_note_segment_at(index) or { panic(err) })
}

// Ruby method `sections_at_aligned_offset(offset)` at line 705.
pub fn ruby_alt_saver_l705_d45_sections_at_aligned_offset(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'sections_at_aligned_offset')
	saver := alt_saver_from_args(args)
	return alt_sections_value(saver.sections_at_aligned_offset(u64(args[1].as_int() or { panic(err) })))
}

// Ruby method `shift_sections(shift, start_offset)` at line 718.
pub fn ruby_alt_saver_l718_d46_shift_sections(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'shift_sections')
	mut saver := alt_saver_from_args(args)
	saver.shift_sections(u64(args[1].as_int() or { panic(err) }), u64(args[2].as_int() or { panic(err) }))
	return alt_nil_value()
}

// Ruby method `shift_segment_offset(phdr, shift)` at line 731.
pub fn ruby_alt_saver_l731_d47_shift_segment_offset(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'shift_segment_offset')
	saver := alt_saver_from_args(args)
	mut header := alt_program_header_from_value(args[1])
	saver.shift_segment_offset(mut header, u64(args[2].as_int() or { panic(err) }))
	return alt_program_header_value(header)
}

// Ruby method `shift_segment_virtual_address(phdr, shift)` at line 736.
pub fn ruby_alt_saver_l736_d48_shift_segment_virtual_address(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'shift_segment_virtual_address')
	mut header := alt_program_header_from_value(args[1])
	shift_segment_virtual_address(mut header, u64(args[2].as_int() or { panic(err) }))
	return alt_program_header_value(header)
}

// Ruby method `shift_segments(shift, start_offset)` at line 741.
pub fn ruby_alt_saver_l741_d49_shift_segments(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'shift_segments')
	mut saver := alt_saver_from_args(args)
	index, shift := saver.shift_segments(u64(args[1].as_int() or { panic(err) }), u64(args[2].as_int() or { panic(err) })) or { panic(err) }
	return brew_runtime.array_value([brew_runtime.int_value(index),
		brew_runtime.int_value(i64(shift))])
}

// Ruby method `shift_file(extra_pages, start_offset, extra_bytes)` at line 776.
pub fn ruby_alt_saver_l776_d50_shift_file(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 4, 'shift_file')
	mut saver := alt_saver_from_args(args)
	saver.shift_file(int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or { panic(err) }), int(args[3].as_int() or { panic(err) })) or { panic(err) }
	return alt_nil_value()
}

// Ruby method `sort_phdrs!` at line 806.
pub fn ruby_alt_saver_l806_d51_sort_phdrs(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.sort_phdrs()
	return alt_programs_value(saver.segments.map(it.header))
}

// Ruby method `collect_section_to_section_refs` at line 818.
pub fn ruby_alt_saver_l818_d52_collect_section_to_section_refs(args ...brew_runtime.Value) brew_runtime.Value {
	return alt_refs_value(alt_saver_from_args(args).collect_section_to_section_refs())
}

// Ruby method `restore_section_to_section_refs!(collected)` at line 830.
pub fn ruby_alt_saver_l830_d53_restore_section_to_section_refs(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'restore_section_to_section_refs!')
	mut saver := alt_saver_from_args(args)
	saver.restore_section_to_section_refs(alt_refs_from_value(args[1]))
	return alt_nil_value()
}

// Ruby method `sort_shdrs!` at line 840.
pub fn ruby_alt_saver_l840_d54_sort_shdrs(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.sort_shdrs()
	return alt_sections_value(saver.sections)
}

// Ruby method `jmprel_section_name` at line 853.
pub fn ruby_alt_saver_l853_d55_jmprel_section_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(alt_saver_from_args(args).jmprel_section_name() or { panic(err) })
}

// Ruby method `dyn_tag_to_section_name(d_tag)` at line 863.
pub fn ruby_alt_saver_l863_d56_dyn_tag_to_section_name(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'dyn_tag_to_section_name')
	name := alt_saver_from_args(args).dyn_tag_to_section_name(args[1].as_int() or { panic(err) }) or {
		panic(err)
	}
	return if name == '' { alt_nil_value() } else { brew_runtime.string_value(name) }
}

// Ruby method `dyn_tag_to_shdr(d_tag)` at line 897.
pub fn ruby_alt_saver_l897_d57_dyn_tag_to_shdr(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'dyn_tag_to_shdr')
	header := alt_saver_from_args(args).dyn_tag_to_shdr(args[1].as_int() or { panic(err) }) or {
		return alt_nil_value()
	}
	return alt_section_header_value(header)
}

// Ruby method `sync_dyn_tags!` at line 905.
pub fn ruby_alt_saver_l905_d58_sync_dyn_tags(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.sync_dyn_tags() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `update_section_idx!` at line 931.
pub fn ruby_alt_saver_l931_d59_update_section_idx(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.update_section_idx()
	return alt_nil_value()
}

// Ruby method `with_buf_at(pos)` at line 935.
pub fn ruby_alt_saver_l935_d60_with_buf_at(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'with_buf_at')
	saver := alt_saver_from_args(args)
	position := int(args[1].as_int() or { panic(err) })
	if position < 0 || position > saver.buffer.len {
		panic('buffer position outside stream')
	}
	// A generic boundary has no callable block value. Ruby returns nil when no block is given.
	return alt_nil_value()
}

// Ruby method `sync_sec_to_seg(shdr, phdr)` at line 947.
pub fn ruby_alt_saver_l947_d61_sync_sec_to_seg(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'sync_sec_to_seg')
	mut program := alt_program_header_from_value(args[2])
	sync_sec_to_seg(alt_section_header_from_value(args[1]), mut program)
	return alt_program_header_value(program)
}

// Ruby method `phdrs_by_type(seg_type)` at line 953.
pub fn ruby_alt_saver_l953_d62_phdrs_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'phdrs_by_type')
	saver := alt_saver_from_args(args)
	kind := u32(args[1].as_int() or { panic(err) })
	mut values := []brew_runtime.Value{}
	for index in saver.phdr_indices_by_type(kind) {
		values << brew_runtime.array_value([
			alt_program_header_value(saver.segments[index].header),
			brew_runtime.int_value(index),
		])
	}
	return brew_runtime.array_value(values)
}

// Ruby method `find_or_create_section_header(rsec_name)` at line 966.
pub fn ruby_alt_saver_l966_d63_find_or_create_section_header(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'find_or_create_section_header')
	return alt_section_header_value(alt_saver_from_args(args).find_or_create_section_header(args[1].as_string()))
}

// Ruby method `overwrite_replaced_sections` at line 972.
pub fn ruby_alt_saver_l972_d64_overwrite_replaced_sections(args ...brew_runtime.Value) brew_runtime.Value {
	mut saver := alt_saver_from_args(args)
	saver.overwrite_replaced_sections() or { panic(err) }
	return alt_nil_value()
}

// Ruby method `write_section_alignment(shdr)` at line 985.
pub fn ruby_alt_saver_l985_d65_write_section_alignment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 2, 'write_section_alignment')
	saver := alt_saver_from_args(args)
	mut header := alt_section_header_from_value(args[1])
	saver.write_section_alignment(mut header)
	return alt_section_header_value(header)
}

// Ruby method `section_bounds_within_segment?(s_start, s_end, p_start, p_end)` at line 991.
pub fn ruby_alt_saver_l991_d66_section_bounds_within_segment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 5, 'section_bounds_within_segment?')
	return brew_runtime.bool_value(section_bounds_within_segment(u64(args[1].as_int() or { panic(err) }), u64(args[2].as_int() or { panic(err) }), u64(args[3].as_int() or { panic(err) }), u64(args[4].as_int() or { panic(err) })))
}

// Ruby method `section_sync_correspondence_segment(sec_name, shdr)` at line 998.
pub fn ruby_alt_saver_l998_d67_section_sync_correspondence_segment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 3, 'section_sync_correspondence_segment')
	mut saver := alt_saver_from_args(args)
	saver.section_sync_correspondence_segment(args[1].as_string(), alt_section_header_from_value(args[2]))
	return alt_nil_value()
}

// Ruby method `sync_note_segment(orig_sh_offset, orig_sh_size, shdr)` at line 1021.
pub fn ruby_alt_saver_l1021_d68_sync_note_segment(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 4, 'sync_note_segment')
	mut saver := alt_saver_from_args(args)
	saver.sync_note_segment(u64(args[1].as_int() or { panic(err) }), u64(args[2].as_int() or { panic(err) }), alt_section_header_from_value(args[3])) or {
		panic(err)
	}
	return alt_nil_value()
}

// Ruby method `write_replaced_sections(cur_off, start_addr, start_offset)` at line 1040.
pub fn ruby_alt_saver_l1040_d69_write_replaced_sections(args ...brew_runtime.Value) brew_runtime.Value {
	alt_require(args, 4, 'write_replaced_sections')
	mut saver := alt_saver_from_args(args)
	current := saver.write_replaced_sections(int(args[1].as_int() or { panic(err) }), u64(args[2].as_int() or { panic(err) }), int(args[3].as_int() or { panic(err) })) or {
		panic(err)
	}
	return brew_runtime.int_value(current)
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
// 11:
// 12: # :nodoc:
// 13: module PatchELF
// 14:   # TODO: refactor buf_* methods here
// 15:   # TODO: move all refinements into a separate file / helper file.
// 16:   # refinements for cleaner syntax / speed / memory optimizations
// 17:   module Refinements
// 18:     refine StringIO do
// 19:       # behaves like C memset. Equivalent to calling stream.write(char * nbytes)
// 20:       # the benefit of preferring this over `stream.write(char * nbytes)` is only when data to be written is large.
// 21:       # @param [String] char
// 22:       # @param [Integer] nbytes
// 23:       # @return[void]
// 24:       def fill(char, nbytes)
// 25:         at_once = Helper.page_size
// 26:         pending = nbytes
// 27:
// 28:         if pending > at_once
// 29:           to_write = char * at_once
// 30:           while pending >= at_once
// 31:             write(to_write)
// 32:             pending -= at_once
// 33:           end
// 34:         end
// 35:         write(char * pending) if pending.positive?
// 36:       end
// 37:     end
// 38:   end
// 39:   using Refinements
// 40:
// 41:   # Internal use only.
// 42:   # alternative to +Saver+, that aims to be byte to byte equivalent with NixOS/patchelf.
// 43:   #
// 44:   # *DISCLAIMER*: This differs from +Saver+ in number of ways.  No lazy reading,
// 45:   # inconsistent use of existing internal API(e.g: manual reading of data instead of calling +section.data+)
// 46:   # @private
// 47:   class AltSaver
// 48:     attr_reader :in_file # @return [String] Input filename.
// 49:     attr_reader :out_file # @return [String] Output filename.
// 50:
// 51:     # Instantiate a {AltSaver} object.
// 52:     # the params passed are the same as the ones passed to +Saver+
// 53:     # @param [String] in_file
// 54:     # @param [String] out_file
// 55:     # @param [{Symbol => String, Array}] set
// 56:     def initialize(in_file, out_file, set)
// 57:       @in_file = in_file
// 58:       @out_file = out_file
// 59:       @set = set
// 60:
// 61:       f = File.open(in_file, 'rb') # rubocop:disable Style/FileOpen
// 62:       # the +@buffer+ and +@elf+ both could work on same +StringIO+ stream,
// 63:       # the updating of @buffer in place blocks us from looking up old values.
// 64:       # TODO: cache the values needed later, use same stream for +@buffer+ and +@elf+.
// 65:       # also be sure to update the stream offset passed to Segments::Segment.
// 66:       @elf = ELFTools::ELFFile.new(f)
// 67:       @buffer = StringIO.new(f.tap(&:rewind).read) # StringIO makes easier to work with Bindata
// 68:
// 69:       # Ensure file is closed when the {AltSaver} object is garbage collected.
// 70:       ObjectSpace.define_finalizer(self, Helper.close_file_proc(f))
// 71:
// 72:       @ehdr = @elf.header
// 73:       @endian = @elf.endian
// 74:       @elf_class = @elf.elf_class
// 75:
// 76:       @segments = @elf.segments # usage similar to phdrs
// 77:       @sections = @elf.sections # usage similar to shdrs
// 78:       update_section_idx!
// 79:
// 80:       # {String => String}
// 81:       # section name to its data mapping
// 82:       @replaced_sections = {}
// 83:       @section_alignment = ehdr.e_phoff.num_bytes
// 84:
// 85:       # using the same environment flag as patchelf, makes it easier for debugging
// 86:       Logger.level = ::Logger.const_get(ENV['PATCHELF_DEBUG'] ? :DEBUG : :WARN)
// 87:     end
// 88:
// 89:     # @return [void]
// 90:     def save!
// 91:       @set.each { |mtd, val| send(:"modify_#{mtd}") if val }
// 92:       rewrite_sections
// 93:
// 94:       FileUtils.cp(in_file, out_file) if out_file != in_file
// 95:       patch_out
// 96:       # Let output file have the same permission as input.
// 97:       FileUtils.chmod(File.stat(in_file).mode, out_file)
// 98:     end
// 99:
// 100:     private
// 101:
// 102:     attr_reader :ehdr, :endian, :elf_class
// 103:
// 104:     def old_sections
// 105:       @old_sections ||= @elf.sections
// 106:     end
// 107:
// 108:     def buf_cstr(off)
// 109:       cstr = []
// 110:       with_buf_at(off) do |buf|
// 111:         loop do
// 112:           c = buf.read 1
// 113:           break if c.nil? || c == "\x00"
// 114:
// 115:           cstr.push c
// 116:         end
// 117:       end
// 118:       cstr.join
// 119:     end
// 120:
// 121:     def buf_move!(dst_idx, src_idx, n_bytes)
// 122:       with_buf_at(src_idx) do |buf|
// 123:         to_write = buf.read(n_bytes)
// 124:         buf.seek dst_idx
// 125:         buf.write to_write
// 126:       end
// 127:     end
// 128:
// 129:     def dynstr
// 130:       find_section '.dynstr'
// 131:     end
// 132:
// 133:     # Yields dynamic tag, and its offset in @buffer.
// 134:     # @yieldparam [ELFTools::Structs::ELF_Dyn] dyn
// 135:     # @yieldparam [Integer] offset The offset of this dynamic tag within +@buffer+.
// 136:     def each_dynamic_tags
// 137:       sec = find_section('.dynamic')
// 138:       return if sec.nil? || sec.header.sh_type == ELFTools::Constants::SHT_NOBITS
// 139:
// 140:       shdr = sec.header
// 141:       with_buf_at(shdr.sh_offset) do |buf|
// 142:         dyn = ELFTools::Structs::ELF_Dyn.new(elf_class: elf_class, endian: endian)
// 143:         loop do
// 144:           buf_dyn_offset = buf.tell
// 145:           dyn.clear
// 146:           dyn.read(buf)
// 147:           break if dyn.d_tag == ELFTools::Constants::DT_NULL
// 148:
// 149:           yield dyn, buf_dyn_offset
// 150:           # It's possible the caller may modify @buffer.pos, seek to ensure it points to the next tag.
// 151:           buf.seek(buf_dyn_offset + dyn.num_bytes)
// 152:         end
// 153:       end
// 154:     end
// 155:
// 156:     # the idea of uniquely identifying section by its name has its problems
// 157:     # but this is how patchelf operates and is prone to bugs.
// 158:     # e.g: https://github.com/NixOS/patchelf/issues/197
// 159:     def find_section(sec_name)
// 160:       idx = find_section_idx sec_name
// 161:       return unless idx
// 162:
// 163:       @sections[idx]
// 164:     end
// 165:
// 166:     def find_section_idx(sec_name)
// 167:       @section_idx_by_name[sec_name]
// 168:     end
// 169:
// 170:     def buf_grow!(newsz)
// 171:       bufsz = @buffer.size
// 172:       return if newsz <= bufsz
// 173:
// 174:       @buffer.truncate newsz
// 175:     end
// 176:
// 177:     def modify_interpreter
// 178:       @replaced_sections['.interp'] = "#{@set[:interpreter]}\x00"
// 179:     end
// 180:
// 181:     def modify_needed
// 182:       # due to gsoc time constraints only implementing features used by brew.
// 183:       raise NotImplementedError
// 184:     end
// 185:
// 186:     # not checking for nil as modify_rpath is only called if @set[:rpath]
// 187:     def modify_rpath
// 188:       modify_rpath_helper @set[:rpath], force_rpath: true
// 189:     end
// 190:
// 191:     # not checking for nil as modify_runpath is only called if @set[:runpath]
// 192:     def modify_runpath
// 193:       modify_rpath_helper @set[:runpath]
// 194:     end
// 195:
// 196:     def collect_runpath_tags
// 197:       tags = {}
// 198:       each_dynamic_tags do |dyn, off|
// 199:         case dyn.d_tag
// 200:         when ELFTools::Constants::DT_RPATH
// 201:           tag_type = :rpath
// 202:         when ELFTools::Constants::DT_RUNPATH
// 203:           tag_type = :runpath
// 204:         else
// 205:           next
// 206:         end
// 207:
// 208:         # clone does shallow copy, and for some reason d_tag and d_val can't be pass as argument
// 209:         dyn_rpath = ELFTools::Structs::ELF_Dyn.new(endian: endian, elf_class: elf_class)
// 210:         dyn_rpath.assign({ d_tag: dyn.d_tag.to_i, d_val: dyn.d_val.to_i })
// 211:         tags[tag_type] = { offset: off, header: dyn_rpath }
// 212:       end
// 213:       tags
// 214:     end
// 215:
// 216:     def resolve_rpath_tag_conflict(dyn_tags, force_rpath: false)
// 217:       dyn_runpath, dyn_rpath = dyn_tags.values_at(:runpath, :rpath)
// 218:
// 219:       update_sym =
// 220:         if !force_rpath && dyn_rpath && dyn_runpath.nil?
// 221:           :runpath
// 222:         elsif force_rpath && dyn_runpath
// 223:           :rpath
// 224:         end
// 225:       return unless update_sym
// 226:
// 227:       delete_sym, = %i[rpath runpath] - [update_sym]
// 228:       dyn_tag = dyn_tags[update_sym] = dyn_tags[delete_sym]
// 229:       dyn = dyn_tag[:header]
// 230:       dyn.d_tag = ELFTools::Constants.const_get("DT_#{update_sym.upcase}")
// 231:       with_buf_at(dyn_tag[:offset]) { |buf| dyn.write(buf) }
// 232:       dyn_tags.delete(delete_sym)
// 233:     end
// 234:
// 235:     def modify_rpath_helper(new_rpath, force_rpath: false)
// 236:       shdr_dynstr = dynstr.header
// 237:
// 238:       dyn_tags = collect_runpath_tags
// 239:       resolve_rpath_tag_conflict(dyn_tags, force_rpath: force_rpath)
// 240:       # (:runpath, :rpath) order_matters.
// 241:       resolved_rpath_dyn = dyn_tags.values_at(:runpath, :rpath).compact.first
// 242:
// 243:       old_rpath = ''
// 244:       rpath_off = nil
// 245:       if resolved_rpath_dyn
// 246:         rpath_off = shdr_dynstr.sh_offset + resolved_rpath_dyn[:header].d_val
// 247:         old_rpath = buf_cstr(rpath_off)
// 248:       end
// 249:       return if old_rpath == new_rpath
// 250:
// 251:       with_buf_at(rpath_off) { |b| b.write('X' * old_rpath.size) } if rpath_off
// 252:       if new_rpath.size <= old_rpath.size
// 253:         with_buf_at(rpath_off) { |b| b.write "#{new_rpath}\x00" }
// 254:         return
// 255:       end
// 256:
// 257:       Logger.debug 'rpath is too long, resizing...'
// 258:       new_dynstr = replace_section '.dynstr', shdr_dynstr.sh_size + new_rpath.size + 1
// 259:       new_rpath_strtab_idx = shdr_dynstr.sh_size.to_i
// 260:       new_dynstr[new_rpath_strtab_idx..(new_rpath_strtab_idx + new_rpath.size)] = "#{new_rpath}\x00"
// 261:
// 262:       dyn_tags.each_value do |dyn|
// 263:         dyn[:header].d_val = new_rpath_strtab_idx
// 264:         with_buf_at(dyn[:offset]) { |b| dyn[:header].write(b) }
// 265:       end
// 266:
// 267:       return unless dyn_tags.empty?
// 268:
// 269:       add_dt_rpath!(
// 270:         d_tag: force_rpath ? ELFTools::Constants::DT_RPATH : ELFTools::Constants::DT_RUNPATH,
// 271:         d_val: new_rpath_strtab_idx
// 272:       )
// 273:     end
// 274:
// 275:     def modify_soname
// 276:       return unless ehdr.e_type == ELFTools::Constants::ET_DYN
// 277:
// 278:       # due to gsoc time constraints only implementing features used by brew.
// 279:       raise NotImplementedError
// 280:     end
// 281:
// 282:     def add_segment!(**phdr_vals)
// 283:       new_phdr = ELFTools::Structs::ELF_Phdr[elf_class].new(endian: endian, **phdr_vals)
// 284:       # nil = no reference to stream; we only want @segments[i].header
// 285:       new_segment = ELFTools::Segments::Segment.new(new_phdr, nil)
// 286:       @segments.push new_segment
// 287:       ehdr.e_phnum += 1
// 288:       nil
// 289:     end
// 290:
// 291:     def add_dt_rpath!(d_tag: nil, d_val: nil)
// 292:       dyn_num_bytes = nil
// 293:       dt_null_idx = 0
// 294:       each_dynamic_tags do |dyn|
// 295:         dyn_num_bytes ||= dyn.num_bytes
// 296:         dt_null_idx += 1
// 297:       end
// 298:
// 299:       if dyn_num_bytes.nil?
// 300:         Logger.error 'no dynamic tags'
// 301:         return
// 302:       end
// 303:
// 304:       # allot for new dt_runpath
// 305:       shdr_dynamic = find_section('.dynamic').header
// 306:       new_dynamic_data = replace_section '.dynamic', shdr_dynamic.sh_size + dyn_num_bytes
// 307:
// 308:       # consider DT_NULL when copying
// 309:       replacement_size = (dt_null_idx + 1) * dyn_num_bytes
// 310:
// 311:       # make space for dt_runpath tag at the top, shift data by one tag position
// 312:       new_dynamic_data[dyn_num_bytes..(replacement_size + dyn_num_bytes)] = new_dynamic_data[0..replacement_size]
// 313:
// 314:       dyn_rpath = ELFTools::Structs::ELF_Dyn.new endian: endian, elf_class: elf_class
// 315:       dyn_rpath.d_tag = d_tag
// 316:       dyn_rpath.d_val = d_val
// 317:
// 318:       zi = StringIO.new
// 319:       dyn_rpath.write zi
// 320:       zi.rewind
// 321:       new_dynamic_data[0...dyn_num_bytes] = zi.read
// 322:     end
// 323:
// 324:     # given a index into old_sections table
// 325:     # returns the corresponding section index in @sections
// 326:     #
// 327:     # raises ArgumentError if old_shndx can't be found in old_sections
// 328:     # TODO: handle case of non existing section in (new) @sections.
// 329:     def new_section_idx(old_shndx)
// 330:       return if old_shndx == ELFTools::Constants::SHN_UNDEF || old_shndx >= ELFTools::Constants::SHN_LORESERVE
// 331:
// 332:       raise ArgumentError if old_shndx >= old_sections.count
// 333:
// 334:       old_sec = old_sections[old_shndx]
// 335:       raise PatchError, "old_sections[#{shndx}] is nil" if old_sec.nil?
// 336:
// 337:       # TODO: handle case of non existing section in (new) @sections.
// 338:       find_section_idx(old_sec.name)
// 339:     end
// 340:
// 341:     def page_size
// 342:       Helper.page_size(ehdr.e_machine)
// 343:     end
// 344:
// 345:     def patch_out
// 346:       with_buf_at(0) { |b| ehdr.write(b) }
// 347:
// 348:       File.open(out_file, 'wb') do |f|
// 349:         @buffer.rewind
// 350:         f.write @buffer.read
// 351:       end
// 352:     end
// 353:
// 354:     # size includes NUL byte
// 355:     def replace_section(section_name, size)
// 356:       data = @replaced_sections[section_name]
// 357:       unless data
// 358:         shdr = find_section(section_name).header
// 359:         # avoid calling +section.data+ as the @buffer contents may vary from
// 360:         # the stream provided to section at initialization.
// 361:         # ideally, calling section.data should work, however avoiding it to prevent
// 362:         # future traps.
// 363:         with_buf_at(shdr.sh_offset) { |b| data = b.read shdr.sh_size }
// 364:       end
// 365:       rep_data = if data.size == size
// 366:                    data
// 367:                  elsif data.size < size
// 368:                    data.ljust(size, "\x00")
// 369:                  else
// 370:                    "#{data[0...size]}\x00"
// 371:                  end
// 372:       @replaced_sections[section_name] = rep_data
// 373:     end
// 374:
// 375:     def write_phdrs_to_buf!
// 376:       sort_phdrs!
// 377:       with_buf_at(ehdr.e_phoff) do |buf|
// 378:         @segments.each { |seg| seg.header.write(buf) }
// 379:       end
// 380:     end
// 381:
// 382:     def write_shdrs_to_buf!
// 383:       raise PatchError, 'ehdr.e_shnum != @sections.count' if ehdr.e_shnum != @sections.count
// 384:
// 385:       sort_shdrs!
// 386:       with_buf_at(ehdr.e_shoff) do |buf|
// 387:         @sections.each { |section| section.header.write(buf) }
// 388:       end
// 389:       sync_dyn_tags!
// 390:     end
// 391:
// 392:     # data for manual packing and unpacking of symbols in symtab sections.
// 393:     def meta_sym_pack
// 394:       return @meta_sym_pack if @meta_sym_pack
// 395:
// 396:       # resort to manual packing and unpacking of data,
// 397:       # as using bindata is painfully slow :(
// 398:       if elf_class == 32
// 399:         sym_num_bytes = 16 # u32 u32 u32 u8 u8 u16
// 400:         pack_code = endian == :little ? 'VVVCCv' : 'NNNCCn'
// 401:         pack_st_info = 3
// 402:         pack_st_shndx = 5
// 403:         pack_st_value = 1
// 404:       else # 64
// 405:         sym_num_bytes = 24 # u32 u8 u8 u16 u64 u64
// 406:         pack_code = endian == :little ? 'VCCvQ<Q<' : 'NCCnQ>Q>'
// 407:         pack_st_info = 1
// 408:         pack_st_shndx = 3
// 409:         pack_st_value = 4
// 410:       end
// 411:
// 412:       @meta_sym_pack = {
// 413:         num_bytes: sym_num_bytes, code: pack_code,
// 414:         st_info: pack_st_info, st_shndx: pack_st_shndx, st_value: pack_st_value
// 415:       }
// 416:     end
// 417:
// 418:     # yields +symbol+, +entry+
// 419:     def each_symbol(shdr)
// 420:       return unless [ELFTools::Constants::SHT_SYMTAB, ELFTools::Constants::SHT_DYNSYM].include?(shdr.sh_type)
// 421:
// 422:       pack_code, sym_num_bytes = meta_sym_pack.values_at(:code, :num_bytes)
// 423:
// 424:       with_buf_at(shdr.sh_offset) do |buf|
// 425:         num_symbols = shdr.sh_size / sym_num_bytes
// 426:         num_symbols.times do |entry|
// 427:           sym = buf.read(sym_num_bytes).unpack(pack_code)
// 428:           sym_modified = yield sym, entry
// 429:
// 430:           if sym_modified
// 431:             buf.seek buf.tell - sym_num_bytes
// 432:             buf.write sym.pack(pack_code)
// 433:           end
// 434:         end
// 435:       end
// 436:     end
// 437:
// 438:     def rewrite_headers(phdr_address)
// 439:       # there can only be a single program header table according to ELF spec
// 440:       @segments.find { |seg| seg.header.p_type == ELFTools::Constants::PT_PHDR }&.tap do |seg|
// 441:         phdr = seg.header
// 442:         phdr.p_offset = ehdr.e_phoff.to_i
// 443:         phdr.p_vaddr = phdr.p_paddr = phdr_address.to_i
// 444:         phdr.p_filesz = phdr.p_memsz = phdr.num_bytes * @segments.count # e_phentsize * e_phnum
// 445:       end
// 446:       write_phdrs_to_buf!
// 447:       write_shdrs_to_buf!
// 448:
// 449:       pack = meta_sym_pack
// 450:       @sections.each do |sec|
// 451:         each_symbol(sec.header) do |sym, entry|
// 452:           old_shndx = sym[pack[:st_shndx]]
// 453:
// 454:           begin
// 455:             new_index = new_section_idx(old_shndx)
// 456:           rescue ArgumentError
// 457:             Logger.warn "entry #{entry} in symbol table refers to a non existing section, skipping"
// 458:           end
// 459:           next unless new_index
// 460:
// 461:           sym[pack[:st_shndx]] = new_index
// 462:
// 463:           # right 4 bits in the st_info field is st_type
// 464:           if (sym[pack[:st_info]] & 0xF) == ELFTools::Constants::STT_SECTION
// 465:             sym[pack[:st_value]] = @sections[new_index].header.sh_addr.to_i
// 466:           end
// 467:           true
// 468:         end
// 469:       end
// 470:     end
// 471:
// 472:     def rewrite_sections
// 473:       return if @replaced_sections.empty?
// 474:
// 475:       case ehdr.e_type
// 476:       when ELFTools::Constants::ET_DYN
// 477:         rewrite_sections_library
// 478:       when ELFTools::Constants::ET_EXEC
// 479:         rewrite_sections_executable
// 480:       else
// 481:         raise PatchError, 'unknown ELF type'
// 482:       end
// 483:     end
// 484:
// 485:     def replaced_section_indices
// 486:       return enum_for(:replaced_section_indices) unless block_given?
// 487:
// 488:       last_replaced = 0
// 489:       @sections.each_with_index do |sec, idx|
// 490:         if @replaced_sections[sec.name]
// 491:           last_replaced = idx
// 492:           yield last_replaced
// 493:         end
// 494:       end
// 495:       raise PatchError, 'last_replaced = 0' if last_replaced.zero?
// 496:       raise PatchError, 'last_replaced + 1 >= @sections.size' if last_replaced + 1 >= @sections.size
// 497:     end
// 498:
// 499:     def start_replacement_shdr
// 500:       last_replaced = replaced_section_indices.max
// 501:       start_replacement_hdr = @sections[last_replaced + 1].header
// 502:
// 503:       prev_sec_name = ''
// 504:       (1..last_replaced).each do |idx|
// 505:         sec = @sections[idx]
// 506:         shdr = sec.header
// 507:         if (sec.type == ELFTools::Constants::SHT_PROGBITS && sec.name != '.interp') || prev_sec_name == '.dynstr'
// 508:           start_replacement_hdr = shdr
// 509:           break
// 510:         elsif @replaced_sections[sec.name].nil?
// 511:           Logger.debug " replacing section #{sec.name} which is in the way"
// 512:           replace_section(sec.name, shdr.sh_size)
// 513:         end
// 514:         prev_sec_name = sec.name
// 515:       end
// 516:
// 517:       start_replacement_hdr
// 518:     end
// 519:
// 520:     def copy_shdrs_to_eof
// 521:       shoff_new = @buffer.size
// 522:       # honestly idk why `ehdr.e_shoff` is considered when we are only moving shdrs.
// 523:       sh_size = ehdr.e_shoff + (ehdr.e_shnum * ehdr.e_shentsize)
// 524:       buf_grow! @buffer.size + sh_size
// 525:       ehdr.e_shoff = shoff_new
// 526:       raise PatchError, 'ehdr.e_shnum != @sections.size' if ehdr.e_shnum != @sections.size
// 527:
// 528:       with_buf_at(ehdr.e_shoff + @sections.first.header.num_bytes) do |buf| # skip writing to NULL section
// 529:         @sections.each_with_index do |sec, idx|
// 530:           next if idx.zero?
// 531:
// 532:           sec.header.write buf
// 533:         end
// 534:       end
// 535:     end
// 536:
// 537:     def rewrite_sections_executable
// 538:       sort_shdrs!
// 539:       shdr = start_replacement_shdr
// 540:       start_offset = shdr.sh_offset.to_i
// 541:       start_addr = shdr.sh_addr.to_i
// 542:       first_page = start_addr - start_offset
// 543:
// 544:       Logger.debug "first reserved offset/addr is 0x#{start_offset.to_s 16}/0x#{start_addr.to_s 16}"
// 545:
// 546:       unless start_addr % page_size == start_offset % page_size
// 547:         raise PatchError, 'start_addr != start_offset (mod PAGE_SIZE)'
// 548:       end
// 549:
// 550:       Logger.debug "first page is 0x#{first_page.to_i.to_s 16}"
// 551:
// 552:       copy_shdrs_to_eof if ehdr.e_shoff < start_offset
// 553:
// 554:       normalize_note_segments
// 555:
// 556:       seg_num_bytes = @segments.first.header.num_bytes
// 557:       needed_space = (
// 558:         ehdr.num_bytes +
// 559:         (@segments.count * seg_num_bytes) +
// 560:         @replaced_sections.sum { |_, str| Helper.alignup(str.size, @section_alignment) }
// 561:       )
// 562:
// 563:       if needed_space > start_offset
// 564:         needed_space += seg_num_bytes # new load segment is required
// 565:
// 566:         extra_bytes = needed_space - start_offset
// 567:         needed_pages = Helper.alignup(extra_bytes, page_size) / page_size
// 568:         Logger.debug "needed pages is #{needed_pages}"
// 569:         raise PatchError, 'virtual address space underrun' if needed_pages * page_size > first_page
// 570:
// 571:         shift_file(needed_pages, start_offset, extra_bytes)
// 572:
// 573:         first_page -= needed_pages * page_size
// 574:         start_offset += needed_pages * page_size
// 575:       end
// 576:       Logger.debug "needed space is #{needed_space}"
// 577:
// 578:       cur_off = ehdr.num_bytes + (@segments.count * seg_num_bytes)
// 579:       Logger.debug "clearing first #{start_offset - cur_off} bytes"
// 580:       with_buf_at(cur_off) { |buf| buf.fill("\x00", start_offset - cur_off) }
// 581:
// 582:       cur_off = write_replaced_sections cur_off, first_page, 0
// 583:       raise PatchError, "cur_off(#{cur_off}) != needed_space" if cur_off != needed_space
// 584:
// 585:       rewrite_headers first_page + ehdr.e_phoff
// 586:     end
// 587:
// 588:     def replace_sections_in_the_way_of_phdr!
// 589:       num_notes = @sections.count { |sec| sec.type == ELFTools::Constants::SHT_NOTE }
// 590:       pht_size = ehdr.num_bytes + ((@segments.count + num_notes + 1) * @segments.first.header.num_bytes)
// 591:
// 592:       # replace sections that may overlap with expanded program header table
// 593:       @sections.each_with_index do |sec, idx|
// 594:         shdr = sec.header
// 595:         next if idx.zero? || @replaced_sections[sec.name]
// 596:         break if shdr.sh_offset > pht_size
// 597:
// 598:         replace_section sec.name, shdr.sh_size
// 599:       end
// 600:     end
// 601:
// 602:     def rewrite_sections_library
// 603:       start_page = 0
// 604:       first_page = 0
// 605:       @segments.each do |seg|
// 606:         phdr = seg.header
// 607:         this_page = Helper.alignup(phdr.p_vaddr + phdr.p_memsz, page_size)
// 608:         start_page = [start_page, this_page].max
// 609:         first_page = phdr.p_vaddr - phdr.p_offset if phdr.p_type == ELFTools::Constants::PT_PHDR
// 610:       end
// 611:
// 612:       Logger.debug "Last page is 0x#{start_page.to_s 16}"
// 613:       Logger.debug "First page is 0x#{first_page.to_s 16}"
// 614:       replace_sections_in_the_way_of_phdr!
// 615:       needed_space = @replaced_sections.sum { |_, str| Helper.alignup(str.size, @section_alignment) }
// 616:       Logger.debug "needed space = #{needed_space}"
// 617:
// 618:       start_offset = Helper.alignup(@buffer.size, page_size)
// 619:       buf_grow! start_offset + needed_space
// 620:
// 621:       # executable shared object
// 622:       if start_offset > start_page && @segments.any? { |seg| seg.header.p_type == ELFTools::Constants::PT_INTERP }
// 623:         Logger.debug(
// 624:           "shifting new PT_LOAD segment by #{start_offset - start_page} bytes to work around a Linux kernel bug"
// 625:         )
// 626:         start_page = start_offset
// 627:       end
// 628:
// 629:       ehdr.e_phoff = ehdr.num_bytes
// 630:       add_segment!(
// 631:         p_type: ELFTools::Constants::PT_LOAD,
// 632:         p_offset: start_offset,
// 633:         p_vaddr: start_page,
// 634:         p_paddr: start_page,
// 635:         p_filesz: needed_space,
// 636:         p_memsz: needed_space,
// 637:         p_flags: ELFTools::Constants::PF_R | ELFTools::Constants::PF_W,
// 638:         p_align: page_size
// 639:       )
// 640:
// 641:       normalize_note_segments
// 642:
// 643:       cur_off = write_replaced_sections start_offset, start_page, start_offset
// 644:       raise PatchError, 'cur_off != start_offset + needed_space' if cur_off != start_offset + needed_space
// 645:
// 646:       rewrite_headers(first_page + ehdr.e_phoff)
// 647:     end
// 648:
// 649:     def normalize_note_segments
// 650:       return if @replaced_sections.none? do |rsec_name, _|
// 651:         find_section(rsec_name)&.type == ELFTools::Constants::SHT_NOTE
// 652:       end
// 653:
// 654:       new_phdrs = []
// 655:
// 656:       phdrs_by_type(ELFTools::Constants::PT_NOTE) do |phdr|
// 657:         # Binaries produced by older patchelf versions may contain empty PT_NOTE segments.
// 658:         next if @sections.none? do |sec|
// 659:           sec.header.sh_offset >= phdr.p_offset && sec.header.sh_offset < phdr.p_offset + phdr.p_filesz
// 660:         end
// 661:
// 662:         new_phdrs += normalize_note_segment(phdr)
// 663:       end
// 664:
// 665:       new_phdrs.each { |phdr| add_segment!(**phdr.snapshot) }
// 666:     end
// 667:
// 668:     def normalize_note_segment(phdr)
// 669:       start_off = phdr.p_offset.to_i
// 670:       curr_off = start_off
// 671:       end_off = start_off + phdr.p_filesz
// 672:
// 673:       new_phdrs = []
// 674:
// 675:       while curr_off < end_off
// 676:         section = sections_at_aligned_offset(curr_off).find { |sec| sec.type == ELFTools::Constants::SHT_NOTE }
// 677:         raise PatchError, 'cannot normalize PT_NOTE segment: non-contiguous SHT_NOTE sections' if section.nil?
// 678:
// 679:         size = section.header.sh_size.to_i
// 680:         curr_off = section.header.sh_offset.to_i
// 681:
// 682:         if size.zero? || curr_off + size > end_off
// 683:           raise PatchError, 'cannot normalize PT_NOTE segment: partially mapped SHT_NOTE section'
// 684:         end
// 685:
// 686:         new_phdr = ELFTools::Structs::ELF_Phdr[elf_class].new(endian: endian, **phdr.snapshot)
// 687:         new_phdr.p_offset = curr_off
// 688:         new_phdr.p_vaddr = phdr.p_vaddr + (curr_off - start_off)
// 689:         new_phdr.p_paddr = phdr.p_paddr + (curr_off - start_off)
// 690:         new_phdr.p_filesz = size
// 691:         new_phdr.p_memsz = size
// 692:
// 693:         if curr_off == start_off
// 694:           phdr.assign(new_phdr)
// 695:         else
// 696:           new_phdrs << new_phdr
// 697:         end
// 698:
// 699:         curr_off += size
// 700:       end
// 701:
// 702:       new_phdrs
// 703:     end
// 704:
// 705:     def sections_at_aligned_offset(offset)
// 706:       return to_enum(__method__, offset) unless block_given?
// 707:
// 708:       @sections.each do |sec|
// 709:         shdr = sec.header
// 710:
// 711:         aligned_offset = Helper.alignup(offset, shdr.sh_addralign)
// 712:         next if shdr.sh_offset != aligned_offset
// 713:
// 714:         yield sec
// 715:       end
// 716:     end
// 717:
// 718:     def shift_sections(shift, start_offset)
// 719:       ehdr.e_shoff += shift if ehdr.e_shoff >= start_offset
// 720:
// 721:       @sections.each_with_index do |sec, i|
// 722:         next if i.zero? # dont touch NULL section
// 723:
// 724:         shdr = sec.header
// 725:         next if shdr.sh_offset < start_offset
// 726:
// 727:         shdr.sh_offset += shift
// 728:       end
// 729:     end
// 730:
// 731:     def shift_segment_offset(phdr, shift)
// 732:       phdr.p_offset += shift
// 733:       phdr.p_align = page_size if phdr.p_align != 0 && (phdr.p_vaddr - phdr.p_offset) % phdr.p_align != 0
// 734:     end
// 735:
// 736:     def shift_segment_virtual_address(phdr, shift)
// 737:       phdr.p_paddr -= shift if phdr.p_paddr > shift
// 738:       phdr.p_vaddr -= shift if phdr.p_vaddr > shift
// 739:     end
// 740:
// 741:     def shift_segments(shift, start_offset)
// 742:       split_index = -1
// 743:       split_shift = 0
// 744:
// 745:       @segments.each_with_index do |seg, idx|
// 746:         phdr = seg.header
// 747:         p_start = phdr.p_offset
// 748:
// 749:         if (p_start...(p_start + phdr.p_filesz)).cover?(start_offset) && phdr.p_type == ELFTools::Constants::PT_LOAD
// 750:           raise PatchError, 'PT_LOAD segments overlapped, unable to shift segments' if split_index != -1
// 751:
// 752:           split_index = idx
// 753:           split_shift = start_offset - p_start
// 754:
// 755:           phdr.p_offset = start_offset
// 756:           phdr.p_memsz -= split_shift
// 757:           phdr.p_filesz -= split_shift
// 758:           phdr.p_paddr += split_shift
// 759:           phdr.p_vaddr += split_shift
// 760:
// 761:           p_start = start_offset
// 762:         end
// 763:
// 764:         if p_start >= start_offset
// 765:           shift_segment_offset(phdr, shift)
// 766:         else
// 767:           shift_segment_virtual_address(phdr, shift)
// 768:         end
// 769:       end
// 770:
// 771:       raise PatchError, "No PT_LOAD found covers offset 0x#{start_offset.to_s(16)}" if split_index == -1
// 772:
// 773:       [split_index, split_shift]
// 774:     end
// 775:
// 776:     def shift_file(extra_pages, start_offset, extra_bytes)
// 777:       raise PatchError, "start_offset(#{start_offset}) < ehdr.num_bytes" if start_offset < ehdr.num_bytes
// 778:
// 779:       oldsz = @buffer.size
// 780:       raise PatchError, "oldsz <= start_offset(#{start_offset})" if oldsz <= start_offset
// 781:
// 782:       shift = extra_pages * page_size
// 783:       buf_grow!(oldsz + shift)
// 784:       buf_move!(start_offset + shift, start_offset, oldsz - start_offset)
// 785:       with_buf_at(start_offset) { |buf| buf.write "\x00" * shift }
// 786:
// 787:       ehdr.e_phoff = ehdr.num_bytes
// 788:
// 789:       shift_sections(shift, start_offset)
// 790:
// 791:       split_index, split_shift = shift_segments(shift, start_offset)
// 792:
// 793:       split_phdr = @segments[split_index].header
// 794:       add_segment!(
// 795:         p_type: ELFTools::Constants::PT_LOAD,
// 796:         p_offset: split_phdr.p_offset - split_shift - shift,
// 797:         p_vaddr: split_phdr.p_vaddr - split_shift - shift,
// 798:         p_paddr: split_phdr.p_paddr - split_shift - shift,
// 799:         p_filesz: split_shift + extra_bytes,
// 800:         p_memsz: split_shift + extra_bytes,
// 801:         p_flags: ELFTools::Constants::PF_R | ELFTools::Constants::PF_W,
// 802:         p_align: page_size
// 803:       )
// 804:     end
// 805:
// 806:     def sort_phdrs!
// 807:       pt_phdr = ELFTools::Constants::PT_PHDR
// 808:       @segments.sort! do |me, you|
// 809:         next  1 if you.header.p_type == pt_phdr
// 810:         next -1 if me.header.p_type == pt_phdr
// 811:
// 812:         me.header.p_paddr.to_i <=> you.header.p_paddr.to_i
// 813:       end
// 814:     end
// 815:
// 816:     # section headers may contain sh_info and sh_link values that are
// 817:     # references to another section
// 818:     def collect_section_to_section_refs
// 819:       rel_syms = [ELFTools::Constants::SHT_REL, ELFTools::Constants::SHT_RELA]
// 820:       # Translate sh_link, sh_info mappings to section names.
// 821:       @sections.each_with_object({ linkage: {}, info: {} }) do |s, collected|
// 822:         hdr = s.header
// 823:         collected[:linkage][s.name] = @sections[hdr.sh_link].name if hdr.sh_link.nonzero?
// 824:         collected[:info][s.name] = @sections[hdr.sh_info].name if hdr.sh_info.nonzero? && rel_syms.include?(hdr.sh_type)
// 825:       end
// 826:     end
// 827:
// 828:     # @param collected
// 829:     # this must be the value returned by +collect_section_to_section_refs+
// 830:     def restore_section_to_section_refs!(collected)
// 831:       rel_syms = [ELFTools::Constants::SHT_REL, ELFTools::Constants::SHT_RELA]
// 832:       linkage, info = collected.values_at(:linkage, :info)
// 833:       @sections.each do |sec|
// 834:         hdr = sec.header
// 835:         hdr.sh_link = find_section_idx(linkage[sec.name]) if hdr.sh_link.nonzero?
// 836:         hdr.sh_info = find_section_idx(info[sec.name]) if hdr.sh_info.nonzero? && rel_syms.include?(hdr.sh_type)
// 837:       end
// 838:     end
// 839:
// 840:     def sort_shdrs!
// 841:       return if @sections.empty?
// 842:
// 843:       section_dep_values = collect_section_to_section_refs
// 844:       shstrtab = @sections[ehdr.e_shstrndx].header
// 845:       @sections.sort! { |me, you| me.header.sh_offset.to_i <=> you.header.sh_offset.to_i }
// 846:       update_section_idx!
// 847:       restore_section_to_section_refs!(section_dep_values)
// 848:       @sections.each_with_index do |sec, idx|
// 849:         ehdr.e_shstrndx = idx if sec.header.sh_offset == shstrtab.sh_offset
// 850:       end
// 851:     end
// 852:
// 853:     def jmprel_section_name
// 854:       sec_name = %w[.rel.plt .rela.plt .rela.IA_64.pltoff].find { |s| find_section(s) }
// 855:       raise PatchError, 'cannot find section corresponding to DT_JMPREL' unless sec_name
// 856:
// 857:       sec_name
// 858:     end
// 859:
// 860:     # Given a +dyn.d_tag+, returns the section name it must be synced to.
// 861:     # Returns +nil+ when given tag maps to no section, or when its okay to skip if section is not found.
// 862:     # @return [String?]
// 863:     def dyn_tag_to_section_name(d_tag)
// 864:       case d_tag
// 865:       when ELFTools::Constants::DT_STRTAB, ELFTools::Constants::DT_STRSZ
// 866:         '.dynstr'
// 867:       when ELFTools::Constants::DT_SYMTAB
// 868:         '.dynsym'
// 869:       when ELFTools::Constants::DT_HASH
// 870:         '.hash'
// 871:       when ELFTools::Constants::DT_GNU_HASH
// 872:         # return nil if not found, patchelf claims no problem in skipping
// 873:         find_section('.gnu.hash')&.name
// 874:       when ELFTools::Constants::DT_MIPS_XHASH
// 875:         return if ehdr.e_machine != ELFTools::Constants::EM_MIPS
// 876:
// 877:         '.MIPS.xhash'
// 878:       when ELFTools::Constants::DT_JMPREL
// 879:         jmprel_section_name
// 880:       when ELFTools::Constants::DT_REL
// 881:         # regarding .rel.got, NixOS/patchelf says
// 882:         # "no idea if this makes sense, but it was needed for some program"
// 883:         #
// 884:         # return nil if not found, patchelf claims no problem in skipping
// 885:         %w[.rel.dyn .rel.got].find { |s| find_section(s) }
// 886:       when ELFTools::Constants::DT_RELA
// 887:         # return nil if not found, patchelf claims no problem in skipping
// 888:         find_section('.rela.dyn')&.name
// 889:       when ELFTools::Constants::DT_VERNEED
// 890:         '.gnu.version_r'
// 891:       when ELFTools::Constants::DT_VERSYM
// 892:         '.gnu.version'
// 893:       end
// 894:     end
// 895:
// 896:     # @return [ELFTools::Structs::ELF_Shdr?]
// 897:     def dyn_tag_to_shdr(d_tag)
// 898:       sec_name = dyn_tag_to_section_name(d_tag)
// 899:       return if sec_name.nil?
// 900:
// 901:       find_section(sec_name)&.header
// 902:     end
// 903:
// 904:     # updates dyn tags by syncing it with @section values
// 905:     def sync_dyn_tags!
// 906:       # Position of the fist dynamic tag.
// 907:       dyn_table_offset = nil
// 908:       each_dynamic_tags do |dyn, buf_off|
// 909:         dyn_table_offset ||= buf_off
// 910:
// 911:         if dyn.d_tag == ELFTools::Constants::DT_MIPS_RLD_MAP_REL
// 912:           rld_map = find_section('.rld_map')
// 913:           dyn.d_val = if rld_map
// 914:                         rld_map.header.sh_addr.to_i - (buf_off - dyn_table_offset) -
// 915:                           find_section('.dynamic').header.sh_addr.to_i
// 916:                       else
// 917:                         Logger.warn 'DT_MIPS_RLD_MAP_REL entry is present, but .rld_map section is not'
// 918:                         0
// 919:                       end
// 920:         else
// 921:           shdr = dyn_tag_to_shdr(dyn.d_tag)
// 922:           next if shdr.nil?
// 923:
// 924:           dyn.d_val = dyn.d_tag == ELFTools::Constants::DT_STRSZ ? shdr.sh_size.to_i : shdr.sh_addr.to_i
// 925:         end
// 926:
// 927:         with_buf_at(buf_off) { |wbuf| dyn.write(wbuf) }
// 928:       end
// 929:     end
// 930:
// 931:     def update_section_idx!
// 932:       @section_idx_by_name = @sections.map.with_index { |sec, idx| [sec.name, idx] }.to_h
// 933:     end
// 934:
// 935:     def with_buf_at(pos)
// 936:       return unless block_given?
// 937:
// 938:       opos = @buffer.tell
// 939:       @buffer.seek pos
// 940:       yield @buffer
// 941:       @buffer.seek opos
// 942:       nil
// 943:     end
// 944:
// 945:     # Some sections have their corresponding segment.
// 946:     # Use this utility when a section is being patched so its segment should be updated with the same values.
// 947:     def sync_sec_to_seg(shdr, phdr)
// 948:       phdr.p_offset = shdr.sh_offset.to_i
// 949:       phdr.p_vaddr = phdr.p_paddr = shdr.sh_addr.to_i
// 950:       phdr.p_filesz = phdr.p_memsz = shdr.sh_size.to_i
// 951:     end
// 952:
// 953:     def phdrs_by_type(seg_type)
// 954:       return unless seg_type
// 955:
// 956:       @segments.each_with_index do |seg, idx|
// 957:         next unless (phdr = seg.header).p_type == seg_type
// 958:
// 959:         yield phdr, idx
// 960:       end
// 961:     end
// 962:
// 963:     # Returns a blank shdr if the section doesn't exist.
// 964:     #
// 965:     # @return [ELFTools::Structs::ELF_Shdr]
// 966:     def find_or_create_section_header(rsec_name)
// 967:       shdr = find_section(rsec_name)&.header
// 968:       shdr ||= ELFTools::Structs::ELF_Shdr.new(endian: endian, elf_class: elf_class)
// 969:       shdr
// 970:     end
// 971:
// 972:     def overwrite_replaced_sections
// 973:       # the original source says this has to be done separately to
// 974:       # prevent clobbering the previously written section contents.
// 975:       @replaced_sections.each_key do |rsec_name|
// 976:         shdr = find_section(rsec_name)&.header
// 977:         next unless shdr
// 978:
// 979:         next if shdr.sh_type == ELFTools::Constants::SHT_NOBITS
// 980:
// 981:         with_buf_at(shdr.sh_offset) { |b| b.fill('X', shdr.sh_size) }
// 982:       end
// 983:     end
// 984:
// 985:     def write_section_alignment(shdr)
// 986:       return if shdr.sh_type == ELFTools::Constants::SHT_NOTE && shdr.sh_addralign <= @section_alignment
// 987:
// 988:       shdr.sh_addralign = @section_alignment
// 989:     end
// 990:
// 991:     def section_bounds_within_segment?(s_start, s_end, p_start, p_end)
// 992:       (s_start >= p_start && s_start < p_end) || (s_end > p_start && s_end <= p_end)
// 993:     end
// 994:
// 995:     # Used when patching sections.
// 996:     # For sections with a correspondence segment, update the segment values.
// 997:     # @return [void]
// 998:     def section_sync_correspondence_segment(sec_name, shdr)
// 999:       seg_type = {
// 1000:         '.interp' => ELFTools::Constants::PT_INTERP,
// 1001:         '.dynamic' => ELFTools::Constants::PT_DYNAMIC,
// 1002:         '.MIPS.abiflags' => ELFTools::Constants::PT_MIPS_ABIFLAGS,
// 1003:         '.note.gnu.property' => ELFTools::Constants::PT_GNU_PROPERTY
// 1004:       }[sec_name]
// 1005:       return if seg_type.nil?
// 1006:
// 1007:       phdrs_by_type(seg_type) { |phdr| sync_sec_to_seg(shdr, phdr) }
// 1008:     end
// 1009:
// 1010:     # Similar to +section_sync_correspondence_segment+ but dedicate for note sections as it is allowed to have multiple
// 1011:     # note segments.
// 1012:     # This function searches all note segments and only sync the one matched with the section values before patching.
// 1013:     #
// 1014:     # NOTE: This function is no-op if +shdr+ does not have section type +ELFTools::Constants::SHT_NOTE+.
// 1015:     #
// 1016:     # @param [Integer] orig_sh_offset The original section offset value.
// 1017:     # @param [Integer] orig_sh_size The original section size value.
// 1018:     # @param [ELFTools::Structs::ELF_Shdr] shdr The section header with values after patched.
// 1019:     #
// 1020:     # @return [void]
// 1021:     def sync_note_segment(orig_sh_offset, orig_sh_size, shdr)
// 1022:       return if shdr.sh_type != ELFTools::Constants::SHT_NOTE
// 1023:
// 1024:       phdrs_by_type(ELFTools::Constants::PT_NOTE) do |phdr|
// 1025:         s_start = orig_sh_offset
// 1026:         s_end = s_start + orig_sh_size
// 1027:         p_start = phdr.p_offset
// 1028:         p_end = p_start + phdr.p_filesz
// 1029:
// 1030:         # Skip if no overlap.
// 1031:         next unless section_bounds_within_segment?(s_start, s_end, p_start, p_end)
// 1032:
// 1033:         # Only support exact matches.
// 1034:         raise PatchError, 'unsupported overlap of SHT_NOTE and PT_NOTE' unless [p_start, p_end] == [s_start, s_end]
// 1035:
// 1036:         sync_sec_to_seg(shdr, phdr)
// 1037:       end
// 1038:     end
// 1039:
// 1040:     def write_replaced_sections(cur_off, start_addr, start_offset)
// 1041:       overwrite_replaced_sections
// 1042:
// 1043:       # the sort is necessary, the strategy in ruby and Cpp to iterate map/hash
// 1044:       # is different, patchelf v0.10 iterates the replaced_sections sorted by
// 1045:       # keys.
// 1046:       @replaced_sections.sort.each do |rsec_name, rsec_data|
// 1047:         shdr = find_or_create_section_header(rsec_name)
// 1048:
// 1049:         Logger.debug <<~DEBUG
// 1050:           rewriting section '#{rsec_name}'
// 1051:           from offset 0x#{shdr.sh_offset.to_i.to_s 16}(size #{shdr.sh_size})
// 1052:             to offset 0x#{cur_off.to_i.to_s 16}(size #{rsec_data.size})
// 1053:         DEBUG
// 1054:
// 1055:         with_buf_at(cur_off) { |b| b.write rsec_data }
// 1056:
// 1057:         orig_sh_offset = shdr.sh_offset.to_i
// 1058:         orig_sh_size = shdr.sh_size.to_i
// 1059:
// 1060:         shdr.sh_offset = cur_off
// 1061:         shdr.sh_addr = start_addr + (cur_off - start_offset)
// 1062:         shdr.sh_size = rsec_data.size
// 1063:
// 1064:         write_section_alignment(shdr)
// 1065:         section_sync_correspondence_segment(rsec_name, shdr)
// 1066:         sync_note_segment(orig_sh_offset, orig_sh_size, shdr)
// 1067:
// 1068:         cur_off += Helper.alignup(rsec_data.size, @section_alignment)
// 1069:       end
// 1070:       @replaced_sections.clear
// 1071:
// 1072:       cur_off
// 1073:     end
// 1074:   end
// 1075: end
