module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/structs.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElfStructRecord {
pub:
	kind   string
	endian ElfEndian
pub mut:
	elf_class     int
	offset        int
	fields        map[string]string
	byte_fields   map[string][]u8
	field_offsets map[string]int
	field_sizes   map[string]int
	patches       map[int][]u8
}

pub struct ElfIdent {
pub:
	magic         []u8
	ei_class      u8
	ei_data       u8
	ei_version    u8
	ei_osabi      u8
	ei_abiversion u8
	ei_padding    []u8
}

pub struct ElfHeader {
pub mut:
	state       ElfStructRecord
	e_ident     ElfIdent
	e_type      u16
	e_machine   u16
	e_version   u32
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

pub struct ElfSectionStruct {
pub mut:
	state        ElfStructRecord
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

pub struct ElfProgramStruct {
pub mut:
	state    ElfStructRecord
	p_type   u32
	p_offset u64
	p_vaddr  u64
	p_paddr  u64
	p_filesz u64
	p_memsz  u64
	p_flags  u32
	p_align  u64
}

pub struct ElfSymbolStruct {
pub mut:
	state    ElfStructRecord
	st_name  u32
	st_value u64
	st_size  u64
	st_info  u8
	st_other u8
	st_shndx u16
}

pub struct ElfNoteStruct {
pub mut:
	state    ElfStructRecord
	n_namesz u32
	n_descsz u32
	n_type   u32
}

pub struct ElfDynamicStruct {
pub mut:
	state ElfStructRecord
	d_tag i64
	d_val u64
}

pub struct ElfRelocationStruct {
pub mut:
	state      ElfStructRecord
	r_offset   u64
	r_info     u64
	r_addend   i64
	has_addend bool
}

fn new_struct_record(kind string, elf_class int, endian ElfEndian, offset int) ElfStructRecord {
	return ElfStructRecord{
		kind: kind
		elf_class: elf_class
		endian: endian
		offset: offset
		fields: map[string]string{}
		byte_fields: map[string][]u8{}
		field_offsets: map[string]int{}
		field_sizes: map[string]int{}
		patches: map[int][]u8{}
	}
}

fn (mut record ElfStructRecord) add_integer_field(name string, value string, offset int, size int) {
	record.fields[name] = value
	record.field_offsets[name] = offset
	record.field_sizes[name] = size
}

pub fn pack_elf_integer(value i64, bytes int, endian ElfEndian) ![]u8 {
	if bytes < 0 {
		return error('number of bytes cannot be negative')
	}
	mut little := []u8{len: bytes}
	bits := u64(value)
	for index in 0 .. bytes {
		little[index] = if index < 8 {
			u8((bits >> u32(index * 8)) & 0xff)
		} else if value < 0 {
			u8(0xff)
		} else {
			u8(0)
		}
	}
	if endian == .big {
		little.reverse_in_place()
	}
	return little
}

pub fn (mut record ElfStructRecord) set_integer_field(name string, value i64) ! {
	field_offset := record.field_offsets[name] or { return error('unknown ELF field `${name}`') }
	field_size := record.field_sizes[name] or { return error('unknown ELF field `${name}`') }
	record.patches[field_offset] = pack_elf_integer(value, field_size, record.endian)!
	record.fields[name] = value.str()
}

pub fn (mut header ElfHeader) set_field(name string, value i64) ! {
	header.state.set_integer_field(name, value)!
	match name {
		'e_type' {
			header.e_type = u16(value)
		}
		'e_machine' {
			header.e_machine = u16(value)
		}
		'e_version' {
			header.e_version = u32(value)
		}
		'e_entry' {
			header.e_entry = u64(value)
		}
		'e_phoff' {
			header.e_phoff = u64(value)
		}
		'e_shoff' {
			header.e_shoff = u64(value)
		}
		'e_flags' {
			header.e_flags = u32(value)
		}
		'e_ehsize' {
			header.e_ehsize = u16(value)
		}
		'e_phentsize' {
			header.e_phentsize = u16(value)
		}
		'e_phnum' {
			header.e_phnum = u16(value)
		}
		'e_shentsize' {
			header.e_shentsize = u16(value)
		}
		'e_shnum' {
			header.e_shnum = u16(value)
		}
		'e_shstrndx' {
			header.e_shstrndx = u16(value)
		}
		else {
			return error('unknown ELF header field `${name}`')
		}
	}
}

pub fn (mut header ElfSectionStruct) set_field(name string, value i64) ! {
	header.state.set_integer_field(name, value)!
	match name {
		'sh_name' {
			header.sh_name = u32(value)
		}
		'sh_type' {
			header.sh_type = u32(value)
		}
		'sh_flags' {
			header.sh_flags = u64(value)
		}
		'sh_addr' {
			header.sh_addr = u64(value)
		}
		'sh_offset' {
			header.sh_offset = u64(value)
		}
		'sh_size' {
			header.sh_size = u64(value)
		}
		'sh_link' {
			header.sh_link = u32(value)
		}
		'sh_info' {
			header.sh_info = u32(value)
		}
		'sh_addralign' {
			header.sh_addralign = u64(value)
		}
		'sh_entsize' {
			header.sh_entsize = u64(value)
		}
		else {
			return error('unknown ELF section field `${name}`')
		}
	}
}

pub fn (mut header ElfProgramStruct) set_field(name string, value i64) ! {
	header.state.set_integer_field(name, value)!
	match name {
		'p_type' {
			header.p_type = u32(value)
		}
		'p_offset' {
			header.p_offset = u64(value)
		}
		'p_vaddr' {
			header.p_vaddr = u64(value)
		}
		'p_paddr' {
			header.p_paddr = u64(value)
		}
		'p_filesz' {
			header.p_filesz = u64(value)
		}
		'p_memsz' {
			header.p_memsz = u64(value)
		}
		'p_flags' {
			header.p_flags = u32(value)
		}
		'p_align' {
			header.p_align = u64(value)
		}
		else {
			return error('unknown ELF program field `${name}`')
		}
	}
}

pub fn (mut symbol ElfSymbolStruct) set_field(name string, value i64) ! {
	symbol.state.set_integer_field(name, value)!
	match name {
		'st_name' {
			symbol.st_name = u32(value)
		}
		'st_value' {
			symbol.st_value = u64(value)
		}
		'st_size' {
			symbol.st_size = u64(value)
		}
		'st_info' {
			symbol.st_info = u8(value)
		}
		'st_other' {
			symbol.st_other = u8(value)
		}
		'st_shndx' {
			symbol.st_shndx = u16(value)
		}
		else {
			return error('unknown ELF symbol field `${name}`')
		}
	}
}

pub fn (mut note ElfNoteStruct) set_field(name string, value i64) ! {
	note.state.set_integer_field(name, value)!
	match name {
		'n_namesz' {
			note.n_namesz = u32(value)
		}
		'n_descsz' {
			note.n_descsz = u32(value)
		}
		'n_type' {
			note.n_type = u32(value)
		}
		else {
			return error('unknown ELF note field `${name}`')
		}
	}
}

pub fn (mut dynamic ElfDynamicStruct) set_field(name string, value i64) ! {
	dynamic.state.set_integer_field(name, value)!
	match name {
		'd_tag' {
			dynamic.d_tag = value
		}
		'd_val' {
			dynamic.d_val = u64(value)
		}
		else {
			return error('unknown ELF dynamic field `${name}`')
		}
	}
}

pub fn (mut relocation ElfRelocationStruct) set_field(name string, value i64) ! {
	relocation.state.set_integer_field(name, value)!
	match name {
		'r_offset' {
			relocation.r_offset = u64(value)
		}
		'r_info' {
			relocation.r_info = u64(value)
		}
		'r_addend' {
			if !relocation.has_addend {
				return error('ELF_Rel has no assignable r_addend')
			}
			relocation.r_addend = value
		}
		else {
			return error('unknown ELF relocation field `${name}`')
		}
	}
}

pub fn (record ElfStructRecord) snapshot() map[string]brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for name, value in record.fields {
		result[name] = brew_runtime.int_value(value.i64())
	}
	for name, value in record.byte_fields {
		result[name] = brew_runtime.string_value(value.bytestr())
	}
	return result
}

fn check_struct_range(data []u8, offset int, size int, kind string) ! {
	if offset < 0 || size < 0 || offset > data.len || size > data.len - offset {
		return error('truncated ${kind} at offset ${offset}')
	}
}

fn read_struct_u16(data []u8, offset int, endian ElfEndian) !u16 {
	check_struct_range(data, offset, 2, 'ELF uint16')!
	return if endian == .little {
		u16(data[offset]) | (u16(data[offset + 1]) << 8)
	} else {
		(u16(data[offset]) << 8) | u16(data[offset + 1])
	}
}

fn read_struct_u32(data []u8, offset int, endian ElfEndian) !u32 {
	check_struct_range(data, offset, 4, 'ELF uint32')!
	mut value := u32(0)
	if endian == .little {
		for index in 0 .. 4 {
			value |= u32(data[offset + index]) << u32(index * 8)
		}
	} else {
		for index in 0 .. 4 {
			value = (value << 8) | u32(data[offset + index])
		}
	}
	return value
}

fn read_struct_u64(data []u8, offset int, endian ElfEndian) !u64 {
	check_struct_range(data, offset, 8, 'ELF uint64')!
	mut value := u64(0)
	if endian == .little {
		for index in 0 .. 8 {
			value |= u64(data[offset + index]) << u32(index * 8)
		}
	} else {
		for index in 0 .. 8 {
			value = (value << 8) | u64(data[offset + index])
		}
	}
	return value
}

fn read_struct_i32(data []u8, offset int, endian ElfEndian) !i64 {
	value := read_struct_u32(data, offset, endian)!
	return if value & 0x80000000 != 0 { i64(value) - 0x100000000 } else { i64(value) }
}

fn read_struct_i64(data []u8, offset int, endian ElfEndian) !i64 {
	return i64(read_struct_u64(data, offset, endian)!)
}

pub fn read_elf_header(data []u8, elf_class int, endian ElfEndian, offset int) !ElfHeader {
	size := if elf_class == 32 {
		52
	} else if elf_class == 64 {
		64
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	check_struct_range(data, offset, size, 'ELF header')!
	mut state := new_struct_record('ELF_Ehdr', elf_class, endian, offset)
	state.byte_fields['magic'] = data[offset..offset + 4].clone()
	state.add_integer_field('ei_class', data[offset + 4].str(), 4, 1)
	state.add_integer_field('ei_data', data[offset + 5].str(), 5, 1)
	state.add_integer_field('ei_version', data[offset + 6].str(), 6, 1)
	state.add_integer_field('ei_osabi', data[offset + 7].str(), 7, 1)
	state.add_integer_field('ei_abiversion', data[offset + 8].str(), 8, 1)
	state.byte_fields['ei_padding'] = data[offset + 9..offset + 16].clone()
	e_type := read_struct_u16(data, offset + 16, endian)!
	e_machine := read_struct_u16(data, offset + 18, endian)!
	e_version := read_struct_u32(data, offset + 20, endian)!
	value_size := if elf_class == 32 { 4 } else { 8 }
	e_entry := if elf_class == 32 {
		u64(read_struct_u32(data, offset + 24, endian)!)
	} else {
		read_struct_u64(data, offset + 24, endian)!
	}
	e_phoff_offset := 24 + value_size
	e_phoff := if elf_class == 32 {
		u64(read_struct_u32(data, offset + e_phoff_offset, endian)!)
	} else {
		read_struct_u64(data, offset + e_phoff_offset, endian)!
	}
	e_shoff_offset := e_phoff_offset + value_size
	e_shoff := if elf_class == 32 {
		u64(read_struct_u32(data, offset + e_shoff_offset, endian)!)
	} else {
		read_struct_u64(data, offset + e_shoff_offset, endian)!
	}
	e_flags_offset := e_shoff_offset + value_size
	e_flags := read_struct_u32(data, offset + e_flags_offset, endian)!
	e_ehsize := read_struct_u16(data, offset + e_flags_offset + 4, endian)!
	e_phentsize := read_struct_u16(data, offset + e_flags_offset + 6, endian)!
	e_phnum := read_struct_u16(data, offset + e_flags_offset + 8, endian)!
	e_shentsize := read_struct_u16(data, offset + e_flags_offset + 10, endian)!
	e_shnum := read_struct_u16(data, offset + e_flags_offset + 12, endian)!
	e_shstrndx := read_struct_u16(data, offset + e_flags_offset + 14, endian)!
	state.add_integer_field('e_type', e_type.str(), 16, 2)
	state.add_integer_field('e_machine', e_machine.str(), 18, 2)
	state.add_integer_field('e_version', e_version.str(), 20, 4)
	state.add_integer_field('e_entry', e_entry.str(), 24, value_size)
	state.add_integer_field('e_phoff', e_phoff.str(), e_phoff_offset, value_size)
	state.add_integer_field('e_shoff', e_shoff.str(), e_shoff_offset, value_size)
	state.add_integer_field('e_flags', e_flags.str(), e_flags_offset, 4)
	state.add_integer_field('e_ehsize', e_ehsize.str(), e_flags_offset + 4, 2)
	state.add_integer_field('e_phentsize', e_phentsize.str(), e_flags_offset + 6, 2)
	state.add_integer_field('e_phnum', e_phnum.str(), e_flags_offset + 8, 2)
	state.add_integer_field('e_shentsize', e_shentsize.str(), e_flags_offset + 10, 2)
	state.add_integer_field('e_shnum', e_shnum.str(), e_flags_offset + 12, 2)
	state.add_integer_field('e_shstrndx', e_shstrndx.str(), e_flags_offset + 14, 2)
	return ElfHeader{
		state: state
		e_ident: ElfIdent{
			magic: data[offset..offset + 4].clone()
			ei_class: data[offset + 4]
			ei_data: data[offset + 5]
			ei_version: data[offset + 6]
			ei_osabi: data[offset + 7]
			ei_abiversion: data[offset + 8]
			ei_padding: data[offset + 9..offset + 16].clone()
		}
		e_type: e_type
		e_machine: e_machine
		e_version: e_version
		e_entry: e_entry
		e_phoff: e_phoff
		e_shoff: e_shoff
		e_flags: e_flags
		e_ehsize: e_ehsize
		e_phentsize: e_phentsize
		e_phnum: e_phnum
		e_shentsize: e_shentsize
		e_shnum: e_shnum
		e_shstrndx: e_shstrndx
	}
}

pub fn read_elf_section_struct(data []u8, elf_class int, endian ElfEndian, offset int) !ElfSectionStruct {
	size := if elf_class == 32 {
		40
	} else if elf_class == 64 {
		64
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	check_struct_range(data, offset, size, 'ELF section header')!
	mut state := new_struct_record('ELF_Shdr', elf_class, endian, offset)
	sh_name := read_struct_u32(data, offset, endian)!
	sh_type := read_struct_u32(data, offset + 4, endian)!
	value_size := if elf_class == 32 { 4 } else { 8 }
	mut cursor := 8
	sh_flags := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	cursor += value_size
	sh_addr := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	cursor += value_size
	sh_offset := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	cursor += value_size
	sh_size := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	cursor += value_size
	sh_link := read_struct_u32(data, offset + cursor, endian)!
	sh_info := read_struct_u32(data, offset + cursor + 4, endian)!
	cursor += 8
	sh_addralign := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	cursor += value_size
	sh_entsize := if elf_class == 32 {
		u64(read_struct_u32(data, offset + cursor, endian)!)
	} else {
		read_struct_u64(data, offset + cursor, endian)!
	}
	state.add_integer_field('sh_name', sh_name.str(), 0, 4)
	state.add_integer_field('sh_type', sh_type.str(), 4, 4)
	state.add_integer_field('sh_flags', sh_flags.str(), 8, value_size)
	state.add_integer_field('sh_addr', sh_addr.str(), 8 + value_size, value_size)
	state.add_integer_field('sh_offset', sh_offset.str(), 8 + value_size * 2, value_size)
	state.add_integer_field('sh_size', sh_size.str(), 8 + value_size * 3, value_size)
	state.add_integer_field('sh_link', sh_link.str(), 8 + value_size * 4, 4)
	state.add_integer_field('sh_info', sh_info.str(), 12 + value_size * 4, 4)
	state.add_integer_field('sh_addralign', sh_addralign.str(), 16 + value_size * 4, value_size)
	state.add_integer_field('sh_entsize', sh_entsize.str(), 16 + value_size * 5, value_size)
	return ElfSectionStruct{
		state: state
		sh_name: sh_name
		sh_type: sh_type
		sh_flags: sh_flags
		sh_addr: sh_addr
		sh_offset: sh_offset
		sh_size: sh_size
		sh_link: sh_link
		sh_info: sh_info
		sh_addralign: sh_addralign
		sh_entsize: sh_entsize
	}
}

pub fn read_elf_program_struct(data []u8, elf_class int, endian ElfEndian, offset int) !ElfProgramStruct {
	size := if elf_class == 32 {
		32
	} else if elf_class == 64 {
		56
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	check_struct_range(data, offset, size, 'ELF program header')!
	mut state := new_struct_record(if elf_class == 32 { 'ELF32_Phdr' } else { 'ELF64_Phdr' }, elf_class, endian, offset)
	p_type := read_struct_u32(data, offset, endian)!
	mut p_flags := u32(0)
	mut p_offset := u64(0)
	mut p_vaddr := u64(0)
	mut p_paddr := u64(0)
	mut p_filesz := u64(0)
	mut p_memsz := u64(0)
	mut p_align := u64(0)
	if elf_class == 32 {
		p_offset = read_struct_u32(data, offset + 4, endian)!
		p_vaddr = read_struct_u32(data, offset + 8, endian)!
		p_paddr = read_struct_u32(data, offset + 12, endian)!
		p_filesz = read_struct_u32(data, offset + 16, endian)!
		p_memsz = read_struct_u32(data, offset + 20, endian)!
		p_flags = read_struct_u32(data, offset + 24, endian)!
		p_align = read_struct_u32(data, offset + 28, endian)!
		for name, field_offset in {
			'p_type':   0
			'p_offset': 4
			'p_vaddr':  8
			'p_paddr':  12
			'p_filesz': 16
			'p_memsz':  20
			'p_flags':  24
			'p_align':  28
		} {
			value := match name {
				'p_type' { p_type.str() }
				'p_offset' { p_offset.str() }
				'p_vaddr' { p_vaddr.str() }
				'p_paddr' { p_paddr.str() }
				'p_filesz' { p_filesz.str() }
				'p_memsz' { p_memsz.str() }
				'p_flags' { p_flags.str() }
				else { p_align.str() }
			}
			state.add_integer_field(name, value, field_offset, 4)
		}
	} else {
		p_flags = read_struct_u32(data, offset + 4, endian)!
		p_offset = read_struct_u64(data, offset + 8, endian)!
		p_vaddr = read_struct_u64(data, offset + 16, endian)!
		p_paddr = read_struct_u64(data, offset + 24, endian)!
		p_filesz = read_struct_u64(data, offset + 32, endian)!
		p_memsz = read_struct_u64(data, offset + 40, endian)!
		p_align = read_struct_u64(data, offset + 48, endian)!
		state.add_integer_field('p_type', p_type.str(), 0, 4)
		state.add_integer_field('p_flags', p_flags.str(), 4, 4)
		state.add_integer_field('p_offset', p_offset.str(), 8, 8)
		state.add_integer_field('p_vaddr', p_vaddr.str(), 16, 8)
		state.add_integer_field('p_paddr', p_paddr.str(), 24, 8)
		state.add_integer_field('p_filesz', p_filesz.str(), 32, 8)
		state.add_integer_field('p_memsz', p_memsz.str(), 40, 8)
		state.add_integer_field('p_align', p_align.str(), 48, 8)
	}
	return ElfProgramStruct{
		state: state
		p_type: p_type
		p_offset: p_offset
		p_vaddr: p_vaddr
		p_paddr: p_paddr
		p_filesz: p_filesz
		p_memsz: p_memsz
		p_flags: p_flags
		p_align: p_align
	}
}

pub fn read_elf_symbol_struct(data []u8, elf_class int, endian ElfEndian, offset int) !ElfSymbolStruct {
	size := if elf_class == 32 {
		16
	} else if elf_class == 64 {
		24
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	check_struct_range(data, offset, size, 'ELF symbol')!
	mut state := new_struct_record(if elf_class == 32 { 'ELF32_sym' } else { 'ELF64_sym' }, elf_class, endian, offset)
	st_name := read_struct_u32(data, offset, endian)!
	mut st_value := u64(0)
	mut st_size := u64(0)
	mut st_info := u8(0)
	mut st_other := u8(0)
	mut st_shndx := u16(0)
	if elf_class == 32 {
		st_value = read_struct_u32(data, offset + 4, endian)!
		st_size = read_struct_u32(data, offset + 8, endian)!
		st_info = data[offset + 12]
		st_other = data[offset + 13]
		st_shndx = read_struct_u16(data, offset + 14, endian)!
		state.add_integer_field('st_name', st_name.str(), 0, 4)
		state.add_integer_field('st_value', st_value.str(), 4, 4)
		state.add_integer_field('st_size', st_size.str(), 8, 4)
		state.add_integer_field('st_info', st_info.str(), 12, 1)
		state.add_integer_field('st_other', st_other.str(), 13, 1)
		state.add_integer_field('st_shndx', st_shndx.str(), 14, 2)
	} else {
		st_info = data[offset + 4]
		st_other = data[offset + 5]
		st_shndx = read_struct_u16(data, offset + 6, endian)!
		st_value = read_struct_u64(data, offset + 8, endian)!
		st_size = read_struct_u64(data, offset + 16, endian)!
		state.add_integer_field('st_name', st_name.str(), 0, 4)
		state.add_integer_field('st_info', st_info.str(), 4, 1)
		state.add_integer_field('st_other', st_other.str(), 5, 1)
		state.add_integer_field('st_shndx', st_shndx.str(), 6, 2)
		state.add_integer_field('st_value', st_value.str(), 8, 8)
		state.add_integer_field('st_size', st_size.str(), 16, 8)
	}
	return ElfSymbolStruct{
		state: state
		st_name: st_name
		st_value: st_value
		st_size: st_size
		st_info: st_info
		st_other: st_other
		st_shndx: st_shndx
	}
}

pub fn read_elf_note_struct(data []u8, endian ElfEndian, offset int) !ElfNoteStruct {
	check_struct_range(data, offset, 12, 'ELF note header')!
	mut state := new_struct_record('ELF_Nhdr', 0, endian, offset)
	n_namesz := read_struct_u32(data, offset, endian)!
	n_descsz := read_struct_u32(data, offset + 4, endian)!
	n_type := read_struct_u32(data, offset + 8, endian)!
	state.add_integer_field('n_namesz', n_namesz.str(), 0, 4)
	state.add_integer_field('n_descsz', n_descsz.str(), 4, 4)
	state.add_integer_field('n_type', n_type.str(), 8, 4)
	return ElfNoteStruct{ state: state, n_namesz: n_namesz, n_descsz: n_descsz, n_type: n_type }
}

pub fn read_elf_dynamic_struct(data []u8, elf_class int, endian ElfEndian, offset int) !ElfDynamicStruct {
	size := if elf_class == 32 {
		8
	} else if elf_class == 64 {
		16
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	check_struct_range(data, offset, size, 'ELF dynamic entry')!
	d_tag := if elf_class == 32 {
		read_struct_i32(data, offset, endian)!
	} else {
		read_struct_i64(data, offset, endian)!
	}
	d_val := if elf_class == 32 {
		u64(read_struct_u32(data, offset + 4, endian)!)
	} else {
		read_struct_u64(data, offset + 8, endian)!
	}
	mut state := new_struct_record('ELF_Dyn', elf_class, endian, offset)
	state.add_integer_field('d_tag', d_tag.str(), 0, size / 2)
	state.add_integer_field('d_val', d_val.str(), size / 2, size / 2)
	return ElfDynamicStruct{ state: state, d_tag: d_tag, d_val: d_val }
}

pub fn read_elf_relocation_struct(data []u8, elf_class int, endian ElfEndian, offset int,
	has_addend bool) !ElfRelocationStruct {
	word_size := if elf_class == 32 {
		4
	} else if elf_class == 64 {
		8
	} else {
		return error('unsupported ELF class ${elf_class}')
	}
	size := word_size * if has_addend { 3 } else { 2 }
	check_struct_range(data, offset, size, 'ELF relocation')!
	r_offset := if elf_class == 32 {
		u64(read_struct_u32(data, offset, endian)!)
	} else {
		read_struct_u64(data, offset, endian)!
	}
	r_info := if elf_class == 32 {
		u64(read_struct_u32(data, offset + word_size, endian)!)
	} else {
		read_struct_u64(data, offset + word_size, endian)!
	}
	r_addend := if !has_addend {
		i64(0)
	} else if elf_class == 32 {
		read_struct_i32(data, offset + word_size * 2, endian)!
	} else {
		read_struct_i64(data, offset + word_size * 2, endian)!
	}
	mut state := new_struct_record(if has_addend { 'ELF_Rela' } else { 'ELF_Rel' }, elf_class, endian, offset)
	state.add_integer_field('r_offset', r_offset.str(), 0, word_size)
	state.add_integer_field('r_info', r_info.str(), word_size, word_size)
	if has_addend {
		state.add_integer_field('r_addend', r_addend.str(), word_size * 2, word_size)
	}
	return ElfRelocationStruct{
		state: state
		r_offset: r_offset
		r_info: r_info
		r_addend: r_addend
		has_addend: has_addend
	}
}

fn struct_record_value(record ElfStructRecord) brew_runtime.Value {
	mut attributes := {
		'kind':      record.kind
		'elf_class': record.elf_class.str()
		'offset':    record.offset.str()
		'endian':    record.endian.str()
	}
	for name, value in record.fields {
		attributes[name] = value
	}
	for name, value in record.byte_fields {
		attributes[name] = value.bytestr()
	}
	for offset, value in record.patches {
		attributes['patch:${offset}'] = value.bytestr()
	}
	return brew_runtime.structured_value(record.kind, record.kind, attributes)
}

fn struct_record_from_value(value brew_runtime.Value) ElfStructRecord {
	mut record := new_struct_record(value.attribute('kind') or { value.type_name }, (value.attribute('elf_class') or { '0' }).int(), if value.attribute('endian') or { 'little' } == 'big' {
		.big
	} else {
		.little
	}, (value.attribute('offset') or { '0' }).int())
	for name, field_value in value.attributes {
		if name.starts_with('patch:') {
			record.patches[name.all_after('patch:').int()] = field_value.bytes()
		} else if name !in ['kind', 'elf_class', 'offset', 'endian'] {
			record.fields[name] = field_value
		}
	}
	return record
}

// Ruby attr_accessor `attr_accessor :elf_class` at line 18.
pub fn ruby_structs_l18_d1_elf_class(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFStruct#elf_class requires a receiver') }
	return brew_runtime.int_value((args[0].attribute('elf_class') or { '0' }).i64())
}

// Ruby attr_accessor `attr_accessor :elf_class` at line 18.
pub fn ruby_structs_l18_d2_elf_class(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFStruct#elf_class= requires a receiver and value') }
	record := struct_record_from_value(args[0])
	mut result := struct_record_value(record)
	mut attributes := result.attributes.clone()
	elf_class := args[1].as_int() or { panic(err) }
	attributes['elf_class'] = elf_class.str()
	return brew_runtime.structured_value(result.type_name, result.repr, attributes)
}

// Ruby attr_accessor `attr_accessor :offset` at line 19.
pub fn ruby_structs_l19_d3_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFStruct#offset requires a receiver') }
	return brew_runtime.int_value((args[0].attribute('offset') or { '0' }).i64())
}

// Ruby attr_accessor `attr_accessor :offset` at line 19.
pub fn ruby_structs_l19_d4_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFStruct#offset= requires a receiver and value') }
	record := struct_record_from_value(args[0])
	mut result := struct_record_value(record)
	mut attributes := result.attributes.clone()
	offset := args[1].as_int() or { panic(err) }
	attributes['offset'] = offset.str()
	return brew_runtime.structured_value(result.type_name, result.repr, attributes)
}

// Ruby method `patches` at line 23.
pub fn ruby_structs_l23_d5_patches(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFStruct#patches requires a receiver') }
	record := struct_record_from_value(args[0])
	mut result := map[string]brew_runtime.Value{}
	for offset, value in record.patches {
		result[offset.str()] = brew_runtime.string_value(value.bytestr())
	}
	return brew_runtime.map_value(result)
}

// Ruby alias `alias to_h snapshot` at line 28.
pub fn ruby_structs_l28_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFStruct#to_h requires a receiver') }
	return brew_runtime.map_value(struct_record_from_value(args[0]).snapshot())
}

// Ruby method `new(*args)` at line 34.
pub fn ruby_structs_l34_d7_new(args ...brew_runtime.Value) brew_runtime.Value {
	kind := if args.len > 0 { args[0].as_string() } else { 'ELFStruct' }
	elf_class := if args.len > 1 { int(args[1].as_int() or { panic(err) }) } else { 0 }
	endian := if args.len > 2 && args[2].as_string().trim_left(':') == 'big' {
		ElfEndian.big
	} else {
		ElfEndian.little
	}
	offset := if args.len > 3 { int(args[3].as_int() or { panic(err) }) } else { 0 }
	return struct_record_value(new_struct_record(kind, elf_class, endian, offset))
}

// Ruby define_singleton_method `obj.define_singleton_method(m) do |val|` at line 45.
pub fn ruby_structs_l45_d8_m(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('ELFStruct generated setter requires receiver, field, value, offset, and size')
	}
	mut record := struct_record_from_value(args[0])
	field := args[1].as_string()
	record.field_offsets[field] = int(args[3].as_int() or { panic(err) })
	record.field_sizes[field] = int(args[4].as_int() or { panic(err) })
	record.set_integer_field(field, args[2].as_int() or { panic(err) }) or { panic(err) }
	return struct_record_value(record)
}

// Ruby method `self_endian` at line 56.
pub fn ruby_structs_l56_d9_self_endian(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFStruct.self_endian requires a BinData class name') }
	return brew_runtime.string_value(if args[0].as_string().ends_with('be') {
		':big'
	} else {
		':little'
	})
}

// Ruby method `pack(val, bytes)` at line 64.
pub fn ruby_structs_l64_d10_pack(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFStruct.pack requires a value and byte count') }
	endian := if args.len > 2 && args[2].as_string().trim_left(':') == 'big' {
		ElfEndian.big
	} else {
		ElfEndian.little
	}
	return brew_runtime.string_value(pack_elf_integer(args[0].as_int() or { panic(err) }, int(args[1].as_int() or { panic(err) }), endian) or { panic(err) }.bytestr())
}

// Ruby method `r_addend` at line 206.
pub fn ruby_structs_l206_d11_r_addend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'bindata'
// 4:
// 5: module ELFTools
// 6:   # Define ELF related structures in this module.
// 7:   #
// 8:   # Structures are fetched from https://github.com/torvalds/linux/blob/master/include/uapi/linux/elf.h.
// 9:   # Use gem +bindata+ to have these structures support 32/64 bits and little/big endian simultaneously.
// 10:   module Structs
// 11:     # The base structure to define common methods.
// 12:     class ELFStruct < BinData::Record
// 13:       # DRY. Many fields have different type in different arch.
// 14:       CHOICE_SIZE_T = proc do |t = 'uint'|
// 15:         { selection: :elf_class, choices: { 32 => :"#{t}32", 64 => :"#{t}64" }, copy_on_change: true }
// 16:       end
// 17:
// 18:       attr_accessor :elf_class # @return [Integer] 32 or 64.
// 19:       attr_accessor :offset # @return [Integer] The file offset of this header.
// 20:
// 21:       # Records which fields have been patched.
// 22:       # @return [Hash{Integer => Integer}] Patches.
// 23:       def patches
// 24:         @patches ||= {}
// 25:       end
// 26:
// 27:       # BinData hash(Snapshot) that behaves like HashWithIndifferentAccess
// 28:       alias to_h snapshot
// 29:
// 30:       class << self
// 31:         # Hooks the constructor.
// 32:         #
// 33:         # +BinData::Record+ doesn't allow us to override +#initialize+, so we hack +new+ here.
// 34:         def new(*args)
// 35:           # XXX: The better implementation is +new(*args, **kwargs)+, but we can't do this unless bindata changed
// 36:           # lib/bindata/dsl.rb#override_new_in_class to invoke +new+ with both +args+ and +kwargs+.
// 37:           kwargs = args.last.is_a?(Hash) ? args.last : {}
// 38:           offset = kwargs.delete(:offset)
// 39:           super.tap do |obj|
// 40:             obj.offset = offset
// 41:             obj.field_names.each do |f|
// 42:               m = "#{f}=".to_sym
// 43:               old_method = obj.singleton_method(m)
// 44:               obj.singleton_class.send(:undef_method, m)
// 45:               obj.define_singleton_method(m) do |val|
// 46:                 org = obj.send(f)
// 47:                 obj.patches[org.abs_offset] = ELFStruct.pack(val, org.num_bytes)
// 48:                 old_method.call(val)
// 49:               end
// 50:             end
// 51:           end
// 52:         end
// 53:
// 54:         # Gets the endianness of current class.
// 55:         # @return [:little, :big] The endianness.
// 56:         def self_endian
// 57:           bindata_name[-2..] == 'be' ? :big : :little
// 58:         end
// 59:
// 60:         # Packs an integer to string.
// 61:         # @param [Integer] val
// 62:         # @param [Integer] bytes
// 63:         # @return [String]
// 64:         def pack(val, bytes)
// 65:           raise ArgumentError, "Not supported assign type #{val.class}" unless val.is_a?(Integer)
// 66:
// 67:           number = val & ((1 << (8 * bytes)) - 1)
// 68:           out = []
// 69:           bytes.times do
// 70:             out << (number & 0xff)
// 71:             number >>= 8
// 72:           end
// 73:           out = out.pack('C*')
// 74:           self_endian == :little ? out : out.reverse
// 75:         end
// 76:       end
// 77:     end
// 78:
// 79:     # ELF header structure.
// 80:     class ELF_Ehdr < ELFStruct
// 81:       endian :big_and_little
// 82:       struct :e_ident do
// 83:         string :magic, read_length: 4
// 84:         int8 :ei_class
// 85:         int8 :ei_data
// 86:         int8 :ei_version
// 87:         int8 :ei_osabi
// 88:         int8 :ei_abiversion
// 89:         string :ei_padding, read_length: 7 # no use
// 90:       end
// 91:       uint16 :e_type
// 92:       uint16 :e_machine
// 93:       uint32 :e_version
// 94:       # entry point
// 95:       choice :e_entry, **CHOICE_SIZE_T['uint']
// 96:       choice :e_phoff, **CHOICE_SIZE_T['uint']
// 97:       choice :e_shoff, **CHOICE_SIZE_T['uint']
// 98:       uint32 :e_flags
// 99:       uint16 :e_ehsize # size of this header
// 100:       uint16 :e_phentsize # size of each segment
// 101:       uint16 :e_phnum # number of segments
// 102:       uint16 :e_shentsize # size of each section
// 103:       uint16 :e_shnum # number of sections
// 104:       uint16 :e_shstrndx # index of string table section
// 105:     end
// 106:
// 107:     # Section header structure.
// 108:     class ELF_Shdr < ELFStruct
// 109:       endian :big_and_little
// 110:       uint32 :sh_name
// 111:       uint32 :sh_type
// 112:       choice :sh_flags, **CHOICE_SIZE_T['uint']
// 113:       choice :sh_addr, **CHOICE_SIZE_T['uint']
// 114:       choice :sh_offset, **CHOICE_SIZE_T['uint']
// 115:       choice :sh_size, **CHOICE_SIZE_T['uint']
// 116:       uint32 :sh_link
// 117:       uint32 :sh_info
// 118:       choice :sh_addralign, **CHOICE_SIZE_T['uint']
// 119:       choice :sh_entsize, **CHOICE_SIZE_T['uint']
// 120:     end
// 121:
// 122:     # Program header structure for 32-bit.
// 123:     class ELF32_Phdr < ELFStruct
// 124:       endian :big_and_little
// 125:       uint32 :p_type
// 126:       uint32 :p_offset
// 127:       uint32 :p_vaddr
// 128:       uint32 :p_paddr
// 129:       uint32 :p_filesz
// 130:       uint32 :p_memsz
// 131:       uint32 :p_flags
// 132:       uint32 :p_align
// 133:     end
// 134:
// 135:     # Program header structure for 64-bit.
// 136:     class ELF64_Phdr < ELFStruct
// 137:       endian :big_and_little
// 138:       uint32 :p_type
// 139:       uint32 :p_flags
// 140:       uint64 :p_offset
// 141:       uint64 :p_vaddr
// 142:       uint64 :p_paddr
// 143:       uint64 :p_filesz
// 144:       uint64 :p_memsz
// 145:       uint64 :p_align
// 146:     end
// 147:
// 148:     # Gets the class of program header according to bits.
// 149:     ELF_Phdr = {
// 150:       32 => ELF32_Phdr,
// 151:       64 => ELF64_Phdr
// 152:     }.freeze
// 153:
// 154:     # Symbol structure for 32-bit.
// 155:     class ELF32_sym < ELFStruct
// 156:       endian :big_and_little
// 157:       uint32 :st_name
// 158:       uint32 :st_value
// 159:       uint32 :st_size
// 160:       uint8 :st_info
// 161:       uint8 :st_other
// 162:       uint16 :st_shndx
// 163:     end
// 164:
// 165:     # Symbol structure for 64-bit.
// 166:     class ELF64_sym < ELFStruct
// 167:       endian :big_and_little
// 168:       uint32 :st_name  # Symbol name, index in string tbl
// 169:       uint8 :st_info   # Type and binding attributes
// 170:       uint8 :st_other  # No defined meaning, 0
// 171:       uint16 :st_shndx # Associated section index
// 172:       uint64 :st_value # Value of the symbol
// 173:       uint64 :st_size  # Associated symbol size
// 174:     end
// 175:
// 176:     # Get symbol header class according to bits.
// 177:     ELF_sym = {
// 178:       32 => ELF32_sym,
// 179:       64 => ELF64_sym
// 180:     }.freeze
// 181:
// 182:     # Note header.
// 183:     class ELF_Nhdr < ELFStruct
// 184:       endian :big_and_little
// 185:       uint32 :n_namesz # Name size
// 186:       uint32 :n_descsz # Content size
// 187:       uint32 :n_type   # Content type
// 188:     end
// 189:
// 190:     # Dynamic tag header.
// 191:     class ELF_Dyn < ELFStruct
// 192:       endian :big_and_little
// 193:       choice :d_tag, **CHOICE_SIZE_T['int']
// 194:       # This is an union type named +d_un+ in original source,
// 195:       # simplify it to be +d_val+ here.
// 196:       choice :d_val, **CHOICE_SIZE_T['uint']
// 197:     end
// 198:
// 199:     # Rel header in .rel section.
// 200:     class ELF_Rel < ELFStruct
// 201:       endian :big_and_little
// 202:       choice :r_offset, **CHOICE_SIZE_T['uint']
// 203:       choice :r_info, **CHOICE_SIZE_T['uint']
// 204:
// 205:       # Compatibility with ELF_Rela, both can be used interchangeably
// 206:       def r_addend
// 207:         nil
// 208:       end
// 209:     end
// 210:
// 211:     # Rela header in .rela section.
// 212:     class ELF_Rela < ELFStruct
// 213:       endian :big_and_little
// 214:       choice :r_offset, **CHOICE_SIZE_T['uint']
// 215:       choice :r_info, **CHOICE_SIZE_T['uint']
// 216:       choice :r_addend, **CHOICE_SIZE_T['int']
// 217:     end
// 218:   end
// 219: end
