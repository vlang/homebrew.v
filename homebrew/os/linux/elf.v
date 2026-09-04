module linux

import ruby
import homebrew.os.linux.elf

// Translated from Homebrew/brew `os/linux/elf.rb`.
const elf_magic = [u8(0x7f), `E`, `L`, `F`]
const elf_df_1_nodeflib = u64(0x800)

enum ElfByteOrder {
	little
	big
}

struct ElfProgramHeader {
	program_type    u32
	offset          u64
	virtual_address u64
	file_size       u64
	memory_size     u64
}

pub struct ElfPath {
pub:
	path string
	data []u8
}

pub struct ElfMetadata {
pub:
	path          string
	dylib_id      ?string
	dynamic_elf   bool
	interpreter   ?string
	rpath         ?string
	section_names []string
	needed        []string
	dt_flags_1    ?u64
}

pub struct PatchelfPatcher {
pub:
	path string
}

pub fn new_elf_path(path string) !ElfPath {
	return ElfPath{
		path: path
		data: ruby.read_bytes(path)!
	}
}

pub fn new_elf_path_from_bytes(path string, data []u8) ElfPath {
	return ElfPath{
		path: path
		data: data.clone()
	}
}

pub fn (path ElfPath) read_uint8(offset int) !u8 {
	if offset < 0 || offset >= path.data.len {
		return error('ELF read at offset ${offset} is outside ${path.data.len} bytes')
	}
	return path.data[offset]
}

pub fn (path ElfPath) read_uint16(offset int) !u16 {
	if offset < 0 || offset + 2 > path.data.len {
		return error('ELF read at offset ${offset} is outside ${path.data.len} bytes')
	}
	return u16(path.data[offset]) | (u16(path.data[offset + 1]) << 8)
}

pub fn (path ElfPath) is_elf() bool {
	return path.data.len > 7 && path.data[..4] == elf_magic && path.data[7] in [u8(0), 3]
}

pub fn (path ElfPath) arch() string {
	if !path.is_elf() {
		return 'dunno'
	}
	machine := path.read_uint16(0x12) or { return 'dunno' }
	return match machine {
		0x3 { 'i386' }
		0x3e { 'x86_64' }
		0x14 { 'ppc32' }
		0x15 { 'ppc64' }
		0x28 { 'arm' }
		0xb7 { 'arm64' }
		else { 'dunno' }
	}
}

pub fn (path ElfPath) arch_compatible(wanted_arch string) bool {
	if !path.is_elf() {
		return true
	}
	normalized := if wanted_arch == 'ppc64le' { 'ppc64' } else { wanted_arch }
	return normalized == path.arch()
}

pub fn (path ElfPath) elf_type() string {
	if !path.is_elf() {
		return 'dunno'
	}
	file_type := path.read_uint16(0x10) or { return 'dunno' }
	return match file_type {
		2 { 'executable' }
		3 { 'dylib' }
		else { 'dunno' }
	}
}

pub fn (path ElfPath) is_dylib() bool {
	return path.elf_type() == 'dylib'
}

pub fn (path ElfPath) binary_executable() bool {
	return path.elf_type() == 'executable'
}

fn elf_read_unsigned(data []u8, offset int, size int, order ElfByteOrder) !u64 {
	if offset < 0 || size < 0 || offset + size > data.len {
		return error('truncated ELF integer at offset ${offset}')
	}
	mut value := u64(0)
	if order == .little {
		for index in 0 .. size {
			value |= u64(data[offset + index]) << u32(index * 8)
		}
	} else {
		for index in 0 .. size {
			value = (value << 8) | u64(data[offset + index])
		}
	}
	return value
}

fn elf_region(data []u8, offset u64, size u64) ![]u8 {
	if offset > u64(data.len) || size > u64(data.len) - offset {
		return error('ELF region ${offset}+${size} is outside ${data.len} bytes')
	}
	return data[int(offset)..int(offset + size)]
}

fn elf_cstring(data []u8, offset u64) ?string {
	if offset >= u64(data.len) {
		return none
	}
	mut finish := int(offset)
	for finish < data.len && data[finish] != 0 {
		finish++
	}
	if finish == data.len {
		return none
	}
	return data[int(offset)..finish].bytestr()
}

fn elf_program_headers(data []u8, elf_class int, order ElfByteOrder) ![]ElfProgramHeader {
	header_size := if elf_class == 32 { 52 } else { 64 }
	if data.len < header_size {
		return error('truncated ELF header')
	}
	phoff := elf_read_unsigned(data, if elf_class == 32 { 28 } else { 32 }, if elf_class == 32 {
		4
	} else {
		8
	}, order)!
	phentsize := int(elf_read_unsigned(data, if elf_class == 32 { 42 } else { 54 }, 2, order)!)
	phnum := int(elf_read_unsigned(data, if elf_class == 32 { 44 } else { 56 }, 2, order)!)
	minimum_entry_size := if elf_class == 32 { 32 } else { 56 }
	if phnum > 0 && phentsize < minimum_entry_size {
		return error('invalid ELF program header size ${phentsize}')
	}
	mut headers := []ElfProgramHeader{cap: phnum}
	for index in 0 .. phnum {
		offset := phoff + u64(index * phentsize)
		_ = elf_region(data, offset, u64(minimum_entry_size))!
		base := int(offset)
		if elf_class == 32 {
			headers << ElfProgramHeader{
				program_type: u32(elf_read_unsigned(data, base, 4, order)!)
				offset: elf_read_unsigned(data, base + 4, 4, order)!
				virtual_address: elf_read_unsigned(data, base + 8, 4, order)!
				file_size: elf_read_unsigned(data, base + 16, 4, order)!
				memory_size: elf_read_unsigned(data, base + 20, 4, order)!
			}
		} else {
			headers << ElfProgramHeader{
				program_type: u32(elf_read_unsigned(data, base, 4, order)!)
				offset: elf_read_unsigned(data, base + 8, 8, order)!
				virtual_address: elf_read_unsigned(data, base + 16, 8, order)!
				file_size: elf_read_unsigned(data, base + 32, 8, order)!
				memory_size: elf_read_unsigned(data, base + 40, 8, order)!
			}
		}
	}
	return headers
}

fn elf_vma_to_offset(vma u64, size u64, headers []ElfProgramHeader) ?u64 {
	for header in headers {
		if header.program_type != 1 || vma < header.virtual_address {
			continue
		}
		relative := vma - header.virtual_address
		if relative <= header.memory_size && size <= header.memory_size - relative {
			return header.offset + relative
		}
	}
	return none
}

fn elf_section_names(data []u8, elf_class int, order ElfByteOrder) ![]string {
	shoff := elf_read_unsigned(data, if elf_class == 32 { 32 } else { 40 }, if elf_class == 32 {
		4
	} else {
		8
	}, order)!
	shentsize := int(elf_read_unsigned(data, if elf_class == 32 { 46 } else { 58 }, 2, order)!)
	shnum := int(elf_read_unsigned(data, if elf_class == 32 { 48 } else { 60 }, 2, order)!)
	shstrndx := int(elf_read_unsigned(data, if elf_class == 32 { 50 } else { 62 }, 2, order)!)
	minimum_entry_size := if elf_class == 32 { 40 } else { 64 }
	if shnum == 0 {
		return []
	}
	if shentsize < minimum_entry_size || shstrndx < 0 || shstrndx >= shnum {
		return error('invalid ELF section header table')
	}
	string_header := shoff + u64(shstrndx * shentsize)
	_ = elf_region(data, string_header, u64(minimum_entry_size))!
	string_base := int(string_header)
	string_offset := elf_read_unsigned(data, string_base + if elf_class == 32 { 16 } else { 24 }, if elf_class == 32 {
		4
	} else {
		8
	}, order)!
	string_size := elf_read_unsigned(data, string_base + if elf_class == 32 { 20 } else { 32 }, if elf_class == 32 {
		4
	} else {
		8
	}, order)!
	strings := elf_region(data, string_offset, string_size)!
	mut names := []string{}
	for index in 0 .. shnum {
		header_offset := shoff + u64(index * shentsize)
		_ = elf_region(data, header_offset, u64(minimum_entry_size))!
		name_offset := elf_read_unsigned(data, int(header_offset), 4, order)!
		if name := elf_cstring(strings, name_offset) {
			if name != '' {
				names << name
			}
		}
	}
	return names
}

pub fn parse_elf_metadata(path ElfPath) !ElfMetadata {
	if !path.is_elf() {
		return error('${path.path} is not a Linux/System V ELF file')
	}
	if path.data.len < 6 {
		return error('truncated ELF identification')
	}
	elf_class := match path.data[4] {
		1 { 32 }
		2 { 64 }
		else {
			return error('invalid ELF class ${path.data[4]}')
		}
	}
	order := match path.data[5] {
		1 { ElfByteOrder.little }
		2 { ElfByteOrder.big }
		else {
			return error('invalid ELF byte order ${path.data[5]}')
		}
	}
	headers := elf_program_headers(path.data, elf_class, order)!
	mut interpreter := ?string(none)
	mut dynamic_found := false
	mut dynamic_offset := u64(0)
	mut dynamic_size := u64(0)
	for header in headers {
		if header.program_type == 3 {
			bytes := elf_region(path.data, header.offset, header.file_size)!
			trimmed := if bytes.len > 0 && bytes.last() == 0 {
				bytes[..bytes.len - 1]
			} else {
				bytes
			}
			interpreter = trimmed.bytestr()
		} else if header.program_type == 2 {
			dynamic_found = true
			dynamic_offset = header.offset
			dynamic_size = header.file_size
		}
	}
	mut needed_offsets := []u64{}
	mut soname_offset := ?u64(none)
	mut runpath_offset := ?u64(none)
	mut rpath_offset := ?u64(none)
	mut string_vma := ?u64(none)
	mut flags_1 := ?u64(none)
	if dynamic_found {
		entry_size := if elf_class == 32 { 8 } else { 16 }
		value_size := if elf_class == 32 { 4 } else { 8 }
		_ = elf_region(path.data, dynamic_offset, dynamic_size)!
		mut cursor := dynamic_offset
		for cursor + u64(entry_size) <= dynamic_offset + dynamic_size {
			tag := elf_read_unsigned(path.data, int(cursor), value_size, order)!
			value := elf_read_unsigned(path.data, int(cursor) + value_size, value_size, order)!
			if tag == 0 {
				break
			}
			match tag {
				1 { needed_offsets << value }
				5 {
					string_vma = value
				}
				14 {
					soname_offset = value
				}
				15 {
					rpath_offset = value
				}
				29 {
					runpath_offset = value
				}
				0x6ffffffb {
					flags_1 = value
				}
				else {}
			}
			cursor += u64(entry_size)
		}
	}
	mut needed := []string{}
	mut dylib_id := ?string(none)
	mut rpath := ?string(none)
	if string_address := string_vma {
		if string_offset := elf_vma_to_offset(string_address, 1, headers) {
			for offset in needed_offsets {
				if name := elf_cstring(path.data, string_offset + offset) {
					needed << name
				}
			}
			if offset := soname_offset {
				dylib_id = elf_cstring(path.data, string_offset + offset)
			}
			if offset := runpath_offset {
				rpath = elf_cstring(path.data, string_offset + offset)
			} else if offset := rpath_offset {
				rpath = elf_cstring(path.data, string_offset + offset)
			}
		}
	}
	return ElfMetadata{
		path: path.path
		dylib_id: dylib_id
		dynamic_elf: dynamic_found
		interpreter: interpreter
		rpath: rpath
		section_names: elf_section_names(path.data, elf_class, order)!
		needed: needed
		dt_flags_1: flags_1
	}
}

pub fn (path ElfPath) metadata() !ElfMetadata {
	return parse_elf_metadata(path)
}

pub fn (path ElfPath) rpath() ?string {
	metadata := path.metadata() or { return none }
	return metadata.rpath
}

pub fn (path ElfPath) rpaths() []string {
	value := path.rpath() or { return [] }
	return value.split(':')
}

pub fn (path ElfPath) interpreter() ?string {
	metadata := path.metadata() or { return none }
	return metadata.interpreter
}

pub fn (path ElfPath) dynamic_elf() bool {
	metadata := path.metadata() or { return false }
	return metadata.dynamic_elf
}

pub fn (path ElfPath) section_names() []string {
	metadata := path.metadata() or { return [] }
	return metadata.section_names
}

fn elf_dirname(path string) string {
	trimmed := path.trim_right('/')
	separator := trimmed.last_index('/') or { return '.' }
	return if separator == 0 { '/' } else { trimmed[..separator] }
}

fn elf_path_is_elf(path string) bool {
	candidate := new_elf_path(path) or { return false }
	return candidate.is_elf()
}

fn elf_child_of(child string, parent string) bool {
	trimmed_parent := parent.trim_right('/')
	return child == trimmed_parent || child.starts_with('${trimmed_parent}/')
}

pub fn (metadata ElfMetadata) find_full_lib_path_in(basename string, library_paths []string,
	system_dirs []string) string {
	if rpath := metadata.rpath {
		for local_path in rpath.split(':') {
			expanded := elf.expand_elf_dst(local_path, 'ORIGIN', elf_dirname(metadata.path))
			candidate := ruby.join_path(expanded, basename)
			if ruby.path_exists(candidate) && elf_path_is_elf(candidate) {
				return candidate
			}
		}
	}
	nodeflib := if flags := metadata.dt_flags_1 { flags & elf_df_1_nodeflib != 0 } else { false }
	mut linker_library_paths := library_paths.clone()
	if nodeflib {
		mut non_system_paths := []string{}
		for path in linker_library_paths {
			if !system_dirs.any(elf_child_of(path, it)) {
				non_system_paths << path
			}
		}
		linker_library_paths = non_system_paths.clone()
	}
	for directory in linker_library_paths {
		candidate := ruby.join_path(directory, basename)
		if ruby.path_exists(candidate) && elf_path_is_elf(candidate) {
			return candidate
		}
	}
	if !nodeflib {
		for directory in system_dirs {
			candidate := ruby.join_path(directory, basename)
			if ruby.path_exists(candidate) && elf_path_is_elf(candidate) {
				return candidate
			}
		}
	}
	return basename
}

pub fn (metadata ElfMetadata) find_full_lib_path(basename string) string {
	return metadata.find_full_lib_path_in(basename, ld_library_paths('ld.so.conf', true), ld_system_dirs(true))
}

pub fn (metadata ElfMetadata) dylibs_in(library_paths []string, system_dirs []string) []string {
	mut libraries := []string{cap: metadata.needed.len}
	for needed in metadata.needed {
		libraries << metadata.find_full_lib_path_in(needed, library_paths, system_dirs)
	}
	return libraries
}

pub fn (metadata ElfMetadata) dylibs() []string {
	mut libraries := []string{cap: metadata.needed.len}
	for needed in metadata.needed {
		libraries << metadata.find_full_lib_path(needed)
	}
	return libraries
}

pub fn (patcher PatchelfPatcher) save(new_interpreter ?string, new_rpath ?string) ! {
	mut arguments := []string{}
	if interpreter_value := new_interpreter {
		if interpreter_value != '' {
			arguments << '--set-interpreter'
			arguments << interpreter_value
		}
	}
	if rpath_value := new_rpath {
		if rpath_value != '' {
			arguments << '--set-rpath'
			arguments << rpath_value
		}
	}
	if arguments.len == 0 {
		return
	}
	arguments << patcher.path
	program := ruby.find_executable('patchelf') or {
		return error('patchelf is required to patch ${patcher.path}')
	}
	result := ruby.run_command(program, arguments)
	if result.exit_code != 0 {
		return error('patchelf failed for ${patcher.path}: ${result.output.trim_space()}')
	}
}

pub fn (path ElfPath) patchelf_patcher() PatchelfPatcher {
	return PatchelfPatcher{
		path: path.path
	}
}

pub fn (path ElfPath) save_using_patchelf(new_interpreter ?string, new_rpath ?string) ! {
	path.patchelf_patcher().save(new_interpreter, new_rpath)!
}

pub fn (path ElfPath) patch(new_interpreter ?string, new_rpath ?string) ! {
	if (new_interpreter or { '' }) == '' && (new_rpath or { '' }) == '' {
		return
	}
	path.save_using_patchelf(new_interpreter, new_rpath)!
}

pub fn (path ElfPath) dylib_id() ?string {
	metadata := path.metadata() or { return none }
	return metadata.dylib_id
}

pub fn (path ElfPath) dynamically_linked_libraries() []string {
	metadata := path.metadata() or { return [] }
	return metadata.dylibs()
}
