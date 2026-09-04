module linux

import ruby
import homebrew.os.linux.elf

// Translated from Homebrew/brew `os/linux/elf.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(path)` at line 48.
pub fn ruby_elf_l48_d1_initialize(path string) !ElfPath {
	return new_elf_path(path)
}

// Ruby method `read_uint8(offset)` at line 61.
pub fn ruby_elf_l61_d2_read_uint8(path ElfPath, offset int) !u8 {
	return path.read_uint8(offset)
}

// Ruby method `read_uint16(offset)` at line 66.
pub fn ruby_elf_l66_d3_read_uint16(path ElfPath, offset int) !u16 {
	return path.read_uint16(offset)
}

// Ruby method `elf?` at line 71.
pub fn ruby_elf_l71_d4_elf(path ElfPath) bool {
	return path.is_elf()
}

// Ruby method `arch` at line 82.
pub fn ruby_elf_l82_d5_arch(path ElfPath) string {
	return path.arch()
}

// Ruby method `arch_compatible?(wanted_arch)` at line 97.
pub fn ruby_elf_l97_d6_arch_compatible(path ElfPath, wanted_arch string) bool {
	return path.arch_compatible(wanted_arch)
}

// Ruby method `elf_type` at line 107.
pub fn ruby_elf_l107_d7_elf_type(path ElfPath) string {
	return path.elf_type()
}

// Ruby method `dylib?` at line 118.
pub fn ruby_elf_l118_d8_dylib(path ElfPath) bool {
	return path.is_dylib()
}

// Ruby method `binary_executable?` at line 123.
pub fn ruby_elf_l123_d9_binary_executable(path ElfPath) bool {
	return path.binary_executable()
}

// Ruby method `rpath` at line 130.
pub fn ruby_elf_l130_d10_rpath(path ElfPath) ?string {
	return path.rpath()
}

// Ruby method `rpaths` at line 137.
pub fn ruby_elf_l137_d11_rpaths(path ElfPath) []string {
	return path.rpaths()
}

// Ruby method `interpreter` at line 142.
pub fn ruby_elf_l142_d12_interpreter(path ElfPath) ?string {
	return path.interpreter()
}

// Ruby method `patch!(interpreter: nil, rpath: nil)` at line 147.
pub fn ruby_elf_l147_d13_patch(path ElfPath, interpreter ?string, rpath ?string) ! {
	path.patch(interpreter, rpath)!
}

// Ruby method `dynamic_elf?` at line 154.
pub fn ruby_elf_l154_d14_dynamic_elf(path ElfPath) bool {
	return path.dynamic_elf()
}

// Ruby method `section_names` at line 159.
pub fn ruby_elf_l159_d15_section_names(path ElfPath) []string {
	return path.section_names()
}

// Ruby attr_reader `attr_reader :path` at line 166.
pub fn ruby_elf_l166_d16_path(metadata ElfMetadata) string {
	return metadata.path
}

// Ruby attr_reader `attr_reader :dylib_id` at line 169.
pub fn ruby_elf_l169_d17_dylib_id(metadata ElfMetadata) ?string {
	return metadata.dylib_id
}

// Ruby method `dynamic_elf?` at line 172.
pub fn ruby_elf_l172_d18_dynamic_elf(metadata ElfMetadata) bool {
	return metadata.dynamic_elf
}

// Ruby attr_reader `attr_reader :interpreter` at line 177.
pub fn ruby_elf_l177_d19_interpreter(metadata ElfMetadata) ?string {
	return metadata.interpreter
}

// Ruby attr_reader `attr_reader :rpath` at line 180.
pub fn ruby_elf_l180_d20_rpath(metadata ElfMetadata) ?string {
	return metadata.rpath
}

// Ruby attr_reader `attr_reader :section_names` at line 183.
pub fn ruby_elf_l183_d21_section_names(metadata ElfMetadata) []string {
	return metadata.section_names
}

// Ruby method `initialize(path)` at line 186.
pub fn ruby_elf_l186_d22_initialize(path ElfPath) !ElfMetadata {
	return parse_elf_metadata(path)
}

// Ruby method `dylibs` at line 211.
pub fn ruby_elf_l211_d23_dylibs(metadata ElfMetadata) []string {
	return metadata.dylibs()
}

// Ruby method `find_full_lib_path(basename)` at line 218.
pub fn ruby_elf_l218_d24_find_full_lib_path(metadata ElfMetadata, basename string) string {
	return metadata.find_full_lib_path(basename)
}

// Ruby method `save_using_patchelf_rb(new_interpreter, new_rpath)` at line 271.
pub fn ruby_elf_l271_d25_save_using_patchelf_rb(path ElfPath, new_interpreter ?string,
	new_rpath ?string) ! {
	path.save_using_patchelf(new_interpreter, new_rpath)!
}

// Ruby method `patchelf_patcher` at line 282.
pub fn ruby_elf_l282_d26_patchelf_patcher(path ElfPath) PatchelfPatcher {
	return path.patchelf_patcher()
}

// Ruby method `metadata` at line 288.
pub fn ruby_elf_l288_d27_metadata(path ElfPath) !ElfMetadata {
	return path.metadata()
}

// Ruby method `dylib_id` at line 294.
pub fn ruby_elf_l294_d28_dylib_id(path ElfPath) ?string {
	return path.dylib_id()
}

// Ruby method `dynamically_linked_libraries(except: :none, resolve_variable_references: true)` at line 299.
pub fn ruby_elf_l299_d29_dynamically_linked_libraries(path ElfPath) []string {
	return path.dynamically_linked_libraries()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/ld"
// 5:
// 6: # {Pathname} extension for dealing with ELF files.
// 7: # @see https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header
// 8: module ELFShim
// 9:   extend T::Helpers
// 10:
// 11:   MAGIC_NUMBER_OFFSET = 0
// 12:   private_constant :MAGIC_NUMBER_OFFSET
// 13:   MAGIC_NUMBER_ASCII = "\x7fELF"
// 14:   private_constant :MAGIC_NUMBER_ASCII
// 15:
// 16:   OS_ABI_OFFSET = 0x07
// 17:   private_constant :OS_ABI_OFFSET
// 18:   OS_ABI_SYSTEM_V = 0
// 19:   private_constant :OS_ABI_SYSTEM_V
// 20:   OS_ABI_LINUX = 3
// 21:   private_constant :OS_ABI_LINUX
// 22:
// 23:   TYPE_OFFSET = 0x10
// 24:   private_constant :TYPE_OFFSET
// 25:   TYPE_EXECUTABLE = 2
// 26:   private_constant :TYPE_EXECUTABLE
// 27:   TYPE_SHARED = 3
// 28:   private_constant :TYPE_SHARED
// 29:
// 30:   ARCHITECTURE_OFFSET = 0x12
// 31:   private_constant :ARCHITECTURE_OFFSET
// 32:   ARCHITECTURE_I386 = 0x3
// 33:   private_constant :ARCHITECTURE_I386
// 34:   ARCHITECTURE_POWERPC = 0x14
// 35:   private_constant :ARCHITECTURE_POWERPC
// 36:   ARCHITECTURE_POWERPC64 = 0x15
// 37:   private_constant :ARCHITECTURE_POWERPC64
// 38:   ARCHITECTURE_ARM = 0x28
// 39:   private_constant :ARCHITECTURE_ARM
// 40:   ARCHITECTURE_X86_64 = 0x3E
// 41:   private_constant :ARCHITECTURE_X86_64
// 42:   ARCHITECTURE_AARCH64 = 0xB7
// 43:   private_constant :ARCHITECTURE_AARCH64
// 44:
// 45:   requires_ancestor { Pathname }
// 46:
// 47:   sig { params(path: T.anything).void }
// 48:   def initialize(path)
// 49:     @elf = T.let(nil, T.nilable(T::Boolean))
// 50:     @arch = T.let(nil, T.nilable(Symbol))
// 51:     @elf_type = T.let(nil, T.nilable(Symbol))
// 52:     @rpath = T.let(nil, T.nilable(String))
// 53:     @interpreter = T.let(nil, T.nilable(String))
// 54:     @dynamic_elf = T.let(nil, T.nilable(T::Boolean))
// 55:     @metadata = T.let(nil, T.nilable(Metadata))
// 56:
// 57:     super
// 58:   end
// 59:
// 60:   sig { params(offset: Integer).returns(Integer) }
// 61:   def read_uint8(offset)
// 62:     read(1, offset).unpack1("C")
// 63:   end
// 64:
// 65:   sig { params(offset: Integer).returns(Integer) }
// 66:   def read_uint16(offset)
// 67:     read(2, offset).unpack1("v")
// 68:   end
// 69:
// 70:   sig { returns(T::Boolean) }
// 71:   def elf?
// 72:     return @elf unless @elf.nil?
// 73:
// 74:     return @elf = false if read(MAGIC_NUMBER_ASCII.size, MAGIC_NUMBER_OFFSET) != MAGIC_NUMBER_ASCII
// 75:
// 76:     # Check that this ELF file is for Linux or System V.
// 77:     # OS_ABI is often set to 0 (System V), regardless of the target platform.
// 78:     @elf = [OS_ABI_LINUX, OS_ABI_SYSTEM_V].include? read_uint8(OS_ABI_OFFSET)
// 79:   end
// 80:
// 81:   sig { returns(Symbol) }
// 82:   def arch
// 83:     return :dunno unless elf?
// 84:
// 85:     @arch ||= case read_uint16(ARCHITECTURE_OFFSET)
// 86:     when ARCHITECTURE_I386 then :i386
// 87:     when ARCHITECTURE_X86_64 then :x86_64
// 88:     when ARCHITECTURE_POWERPC then :ppc32
// 89:     when ARCHITECTURE_POWERPC64 then :ppc64
// 90:     when ARCHITECTURE_ARM then :arm
// 91:     when ARCHITECTURE_AARCH64 then :arm64
// 92:     else :dunno
// 93:     end
// 94:   end
// 95:
// 96:   sig { params(wanted_arch: Symbol).returns(T::Boolean) }
// 97:   def arch_compatible?(wanted_arch)
// 98:     return true unless elf?
// 99:
// 100:     # Treat ppc64le and ppc64 the same
// 101:     wanted_arch = :ppc64 if wanted_arch == :ppc64le
// 102:
// 103:     wanted_arch == arch
// 104:   end
// 105:
// 106:   sig { returns(Symbol) }
// 107:   def elf_type
// 108:     return :dunno unless elf?
// 109:
// 110:     @elf_type ||= case read_uint16(TYPE_OFFSET)
// 111:     when TYPE_EXECUTABLE then :executable
// 112:     when TYPE_SHARED then :dylib
// 113:     else :dunno
// 114:     end
// 115:   end
// 116:
// 117:   sig { returns(T::Boolean) }
// 118:   def dylib?
// 119:     elf_type == :dylib
// 120:   end
// 121:
// 122:   sig { returns(T::Boolean) }
// 123:   def binary_executable?
// 124:     elf_type == :executable
// 125:   end
// 126:
// 127:   # The runtime search path, such as:
// 128:   # "/lib:/usr/lib:/usr/local/lib"
// 129:   sig { returns(T.nilable(String)) }
// 130:   def rpath
// 131:     metadata.rpath
// 132:   end
// 133:
// 134:   # An array of runtime search path entries, such as:
// 135:   # ["/lib", "/usr/lib", "/usr/local/lib"]
// 136:   sig { returns(T::Array[String]) }
// 137:   def rpaths
// 138:     Array(rpath&.split(":"))
// 139:   end
// 140:
// 141:   sig { returns(T.nilable(String)) }
// 142:   def interpreter
// 143:     metadata.interpreter
// 144:   end
// 145:
// 146:   sig { params(interpreter: T.nilable(String), rpath: T.nilable(String)).void }
// 147:   def patch!(interpreter: nil, rpath: nil)
// 148:     return if interpreter.blank? && rpath.blank?
// 149:
// 150:     save_using_patchelf_rb interpreter, rpath
// 151:   end
// 152:
// 153:   sig { returns(T::Boolean) }
// 154:   def dynamic_elf?
// 155:     metadata.dynamic_elf?
// 156:   end
// 157:
// 158:   sig { returns(T::Array[String]) }
// 159:   def section_names
// 160:     metadata.section_names
// 161:   end
// 162:
// 163:   # Helper class for reading metadata from an ELF file.
// 164:   class Metadata
// 165:     sig { returns(ELFShim) }
// 166:     attr_reader :path
// 167:
// 168:     sig { returns(T.nilable(String)) }
// 169:     attr_reader :dylib_id
// 170:
// 171:     sig { returns(T::Boolean) }
// 172:     def dynamic_elf?
// 173:       @dynamic_elf
// 174:     end
// 175:
// 176:     sig { returns(T.nilable(String)) }
// 177:     attr_reader :interpreter
// 178:
// 179:     sig { returns(T.nilable(String)) }
// 180:     attr_reader :rpath
// 181:
// 182:     sig { returns(T::Array[String]) }
// 183:     attr_reader :section_names
// 184:
// 185:     sig { params(path: ELFShim).void }
// 186:     def initialize(path)
// 187:       require "patchelf"
// 188:       patcher = path.patchelf_patcher
// 189:
// 190:       @path = path
// 191:       @dylibs = T.let(nil, T.nilable(T::Array[String]))
// 192:       @dylib_id = T.let(nil, T.nilable(String))
// 193:       @needed = T.let([], T::Array[String])
// 194:
// 195:       dynamic_segment = patcher.elf.segment_by_type(:dynamic)
// 196:       @dynamic_elf = T.let(dynamic_segment.present?, T::Boolean)
// 197:       @dylib_id, @needed = if @dynamic_elf
// 198:         [patcher.soname, patcher.needed]
// 199:       else
// 200:         [nil, []]
// 201:       end
// 202:
// 203:       @interpreter = T.let(patcher.interpreter, T.nilable(String))
// 204:       @rpath = T.let(patcher.runpath || patcher.rpath, T.nilable(String))
// 205:       @section_names = T.let(patcher.elf.sections.map(&:name).compact_blank, T::Array[String])
// 206:
// 207:       @dt_flags_1 = T.let(dynamic_segment&.tag_by_type(:flags_1)&.value, T.nilable(Integer))
// 208:     end
// 209:
// 210:     sig { returns(T::Array[String]) }
// 211:     def dylibs
// 212:       @dylibs ||= @needed.map { |lib| find_full_lib_path(lib).to_s }
// 213:     end
// 214:
// 215:     private
// 216:
// 217:     sig { params(basename: String).returns(::Pathname) }
// 218:     def find_full_lib_path(basename)
// 219:       basename = ::Pathname.new(basename)
// 220:       local_paths = rpath&.split(":")
// 221:
// 222:       # Search for dependencies in the runpath/rpath first
// 223:       local_paths&.each do |local_path|
// 224:         local_path = OS::Linux::Elf.expand_elf_dst(local_path, "ORIGIN", path.parent)
// 225:         candidate = ::Pathname.new(local_path)/basename
// 226:         elf_candidate = ELFPathname.wrap(candidate)
// 227:         return candidate if candidate.exist? && elf_candidate.elf?
// 228:       end
// 229:
// 230:       # Check if DF_1_NODEFLIB is set
// 231:       nodeflib_flag = if @dt_flags_1.nil?
// 232:         false
// 233:       else
// 234:         @dt_flags_1 & ELFTools::Constants::DF::DF_1_NODEFLIB != 0
// 235:       end
// 236:
// 237:       linker_library_paths = OS::Linux::Ld.library_paths
// 238:       linker_system_dirs = OS::Linux::Ld.system_dirs
// 239:
// 240:       # If DF_1_NODEFLIB is set, exclude any library paths that are subdirectories
// 241:       # of the system dirs
// 242:       if nodeflib_flag
// 243:         linker_library_paths = linker_library_paths.reject do |lib_path|
// 244:           linker_system_dirs.any? { |system_dir| Utils::Path.child_of? system_dir, lib_path }
// 245:         end
// 246:       end
// 247:
// 248:       # If not found, search recursively in the paths listed in ld.so.conf (skipping
// 249:       # paths that are subdirectories of the system dirs if DF_1_NODEFLIB is set)
// 250:       linker_library_paths.each do |linker_library_path|
// 251:         candidate = Pathname(linker_library_path)/basename
// 252:         elf_candidate = ELFPathname.wrap(candidate)
// 253:         return candidate if candidate.exist? && elf_candidate.elf?
// 254:       end
// 255:
// 256:       # If not found, search in the system dirs, unless DF_1_NODEFLIB is set
// 257:       unless nodeflib_flag
// 258:         linker_system_dirs.each do |linker_system_dir|
// 259:           candidate = Pathname(linker_system_dir)/basename
// 260:           elf_candidate = ELFPathname.wrap(candidate)
// 261:           return candidate if candidate.exist? && elf_candidate.elf?
// 262:         end
// 263:       end
// 264:
// 265:       basename
// 266:     end
// 267:   end
// 268:   private_constant :Metadata
// 269:
// 270:   sig { params(new_interpreter: T.nilable(String), new_rpath: T.nilable(String)).void }
// 271:   def save_using_patchelf_rb(new_interpreter, new_rpath)
// 272:     patcher = patchelf_patcher
// 273:     patcher.interpreter = new_interpreter if new_interpreter.present?
// 274:     patcher.rpath = new_rpath if new_rpath.present?
// 275:     patcher.save(patchelf_compatible: true)
// 276:   end
// 277:
// 278:   # Don't cache the patcher; it keeps the ELF file open so long as it is alive.
// 279:   # Instead, for read-only access to the ELF file's metadata, fetch it and cache
// 280:   # it with {Metadata}.
// 281:   sig { returns(::PatchELF::Patcher) }
// 282:   def patchelf_patcher
// 283:     require "patchelf"
// 284:     ::PatchELF::Patcher.new to_s, on_error: :silent
// 285:   end
// 286:
// 287:   sig { returns(Metadata) }
// 288:   def metadata
// 289:     @metadata ||= Metadata.new(self)
// 290:   end
// 291:   private :metadata
// 292:
// 293:   sig { returns(T.nilable(String)) }
// 294:   def dylib_id
// 295:     metadata.dylib_id
// 296:   end
// 297:
// 298:   sig { params(except: Symbol, resolve_variable_references: T::Boolean).returns(T::Array[String]) }
// 299:   def dynamically_linked_libraries(except: :none, resolve_variable_references: true)
// 300:     metadata.dylibs
// 301:   end
// 302: end
// 303: require "os/linux/elf/os"
