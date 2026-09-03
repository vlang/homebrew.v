module macho

import brew_runtime
import encoding.binary

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/load_commands.rb`.
// The original source is retained below for source-level parity auditing.
pub const lc_req_dyld = u32(0x8000_0000)
pub const dylib_use_marker = u32(0x1a74_1800)
pub const max_section_alignment = 15

pub enum LoadCommandKind {
	load_command
	uuid
	segment
	segment64
	dylib
	dylib_use
	dylinker
	prebound_dylib
	thread
	routines
	routines64
	sub_framework
	sub_umbrella
	sub_client
	sub_library
	symtab
	dysymtab
	twolevel_hints
	prebind_cksum
	rpath
	target_triple
	linkedit_data
	encryption_info
	encryption_info64
	version_min
	build_version
	dyld_info
	linker_option
	entry_point
	source_version
	symseg
	ident
	fvmfile
	fvmlib
	note
	fileset_entry
}

@[heap]
pub struct LoadCommandRecord {
pub mut:
	kind           LoadCommandKind
	cmd            u32
	cmdsize        u32
	has_view       bool
	raw_data       []u8
	view_offset    int
	endianness     string = 'little'
	file_alignment int = 4
	numbers        map[string]i64
	strings        map[string]LoadCommandLCStr
	uuid           []u8
	sections       []LoadCommandSection
	hints          []TwolevelHint
	tools          []BuildTool
	file_segments  []&LoadCommandRecord
}

pub struct LoadCommandView {
pub:
	raw_data   []u8
	offset     int
	endianness string = 'little'
	alignment  int = 4
	segments   []&LoadCommandRecord
}

pub struct LoadCommandLCStr {
pub:
	value  string
	offset int
}

pub struct SerializationContext {
pub:
	endianness string
	alignment  int
}

pub struct LoadCommandSection {
pub:
	is_64     bool
	sectname  string
	segname   string
	addr      u64
	size      u64
	offset    u32
	align     u32
	reloff    u32
	nreloc    u32
	flags     u32
	reserved1 u32
	reserved2 u32
	reserved3 u32
}

pub struct TwolevelHint {
pub:
	isub_image u32
	itoc       u32
}

pub struct TwolevelHintsTable {
pub:
	hints []TwolevelHint
}

pub struct BuildTool {
pub:
	tool    u32
	version u32
}

pub struct BuildToolEntries {
pub:
	tools []BuildTool
}

pub struct CodeSigningSuperBlob {
pub:
	data []u8
}

pub fn new_load_command(kind LoadCommandKind, cmd u32) &LoadCommandRecord {
	return &LoadCommandRecord{
		kind: kind
		cmd: cmd
		numbers: map[string]i64{}
		strings: map[string]LoadCommandLCStr{}
	}
}

pub fn new_load_command_view(raw_data []u8, offset int, endianness string, alignment int) &LoadCommandView {
	return &LoadCommandView{
		raw_data: raw_data.clone()
		offset: offset
		endianness: normalize_lc_endianness(endianness)
		alignment: alignment
	}
}

fn normalize_lc_symbol(value string) string {
	return value.trim_string_left(':')
}

fn normalize_lc_endianness(value string) string {
	return if normalize_lc_symbol(value) == 'big' { 'big' } else { 'little' }
}

fn load_command_name(cmd u32) ?string {
	return match cmd {
		0x1 { 'LC_SEGMENT' }
		0x2 { 'LC_SYMTAB' }
		0x3 { 'LC_SYMSEG' }
		0x4 { 'LC_THREAD' }
		0x5 { 'LC_UNIXTHREAD' }
		0x6 { 'LC_LOADFVMLIB' }
		0x7 { 'LC_IDFVMLIB' }
		0x8 { 'LC_IDENT' }
		0x9 { 'LC_FVMFILE' }
		0xa { 'LC_PREPAGE' }
		0xb { 'LC_DYSYMTAB' }
		0xc { 'LC_LOAD_DYLIB' }
		0xd { 'LC_ID_DYLIB' }
		0xe { 'LC_LOAD_DYLINKER' }
		0xf { 'LC_ID_DYLINKER' }
		0x10 { 'LC_PREBOUND_DYLIB' }
		0x11 { 'LC_ROUTINES' }
		0x12 { 'LC_SUB_FRAMEWORK' }
		0x13 { 'LC_SUB_UMBRELLA' }
		0x14 { 'LC_SUB_CLIENT' }
		0x15 { 'LC_SUB_LIBRARY' }
		0x16 { 'LC_TWOLEVEL_HINTS' }
		0x17 { 'LC_PREBIND_CKSUM' }
		lc_req_dyld | 0x18 { 'LC_LOAD_WEAK_DYLIB' }
		0x19 { 'LC_SEGMENT_64' }
		0x1a { 'LC_ROUTINES_64' }
		0x1b { 'LC_UUID' }
		lc_req_dyld | 0x1c { 'LC_RPATH' }
		0x1d { 'LC_CODE_SIGNATURE' }
		0x1e { 'LC_SEGMENT_SPLIT_INFO' }
		lc_req_dyld | 0x1f { 'LC_REEXPORT_DYLIB' }
		0x20 { 'LC_LAZY_LOAD_DYLIB' }
		0x21 { 'LC_ENCRYPTION_INFO' }
		0x22 { 'LC_DYLD_INFO' }
		lc_req_dyld | 0x22 { 'LC_DYLD_INFO_ONLY' }
		lc_req_dyld | 0x23 { 'LC_LOAD_UPWARD_DYLIB' }
		0x24 { 'LC_VERSION_MIN_MACOSX' }
		0x25 { 'LC_VERSION_MIN_IPHONEOS' }
		0x26 { 'LC_FUNCTION_STARTS' }
		0x27 { 'LC_DYLD_ENVIRONMENT' }
		lc_req_dyld | 0x28 { 'LC_MAIN' }
		0x29 { 'LC_DATA_IN_CODE' }
		0x2a { 'LC_SOURCE_VERSION' }
		0x2b { 'LC_DYLIB_CODE_SIGN_DRS' }
		0x2c { 'LC_ENCRYPTION_INFO_64' }
		0x2d { 'LC_LINKER_OPTION' }
		0x2e { 'LC_LINKER_OPTIMIZATION_HINT' }
		0x2f { 'LC_VERSION_MIN_TVOS' }
		0x30 { 'LC_VERSION_MIN_WATCHOS' }
		0x31 { 'LC_NOTE' }
		0x32 { 'LC_BUILD_VERSION' }
		lc_req_dyld | 0x33 { 'LC_DYLD_EXPORTS_TRIE' }
		lc_req_dyld | 0x34 { 'LC_DYLD_CHAINED_FIXUPS' }
		lc_req_dyld | 0x35 { 'LC_FILESET_ENTRY' }
		0x36 { 'LC_ATOM_INFO' }
		0x37 { 'LC_FUNCTION_VARIANTS' }
		0x38 { 'LC_FUNCTION_VARIANT_FIXUPS' }
		0x39 { 'LC_TARGET_TRIPLE' }
		0x3a { 'LC_LAZY_LOAD_DYLIB_INFO' }
		else { none }
	}
}

fn load_command_constant(name string) ?u32 {
	needle := normalize_lc_symbol(name)
	for cmd in [u32(0x1), 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf,
		0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, lc_req_dyld | 0x18, 0x19, 0x1a, 0x1b,
		lc_req_dyld | 0x1c, 0x1d, 0x1e, lc_req_dyld | 0x1f, 0x20, 0x21, 0x22, lc_req_dyld | 0x22,
		lc_req_dyld | 0x23, 0x24, 0x25, 0x26, 0x27, lc_req_dyld | 0x28, 0x29, 0x2a, 0x2b, 0x2c,
		0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, lc_req_dyld | 0x33, lc_req_dyld | 0x34,
		lc_req_dyld | 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a] {
		if (load_command_name(cmd) or { '' }) == needle {
			return cmd
		}
	}
	return none
}

fn is_dylib_load_command(name string) bool {
	return normalize_lc_symbol(name) in ['LC_LOAD_DYLIB', 'LC_LOAD_WEAK_DYLIB', 'LC_REEXPORT_DYLIB',
		'LC_LAZY_LOAD_DYLIB', 'LC_LOAD_UPWARD_DYLIB']
}

fn is_creatable_load_command(name string) bool {
	normalized := normalize_lc_symbol(name)
	return is_dylib_load_command(normalized) || normalized in ['LC_ID_DYLIB', 'LC_RPATH',
		'LC_LOAD_DYLINKER', 'LC_CODE_SIGNATURE']
}

fn load_command_kind_for(cmd u32, name_offset u32, timestamp u32) LoadCommandKind {
	return match cmd {
		0x1 { LoadCommandKind.segment }
		0x2 { LoadCommandKind.symtab }
		0x3 { LoadCommandKind.symseg }
		0x4, 0x5 { LoadCommandKind.thread }
		0x6, 0x7 { LoadCommandKind.fvmlib }
		0x8 { LoadCommandKind.ident }
		0x9 { LoadCommandKind.fvmfile }
		0xb { LoadCommandKind.dysymtab }
		0xc, lc_req_dyld | 0x18 {
			if timestamp == dylib_use_marker && name_offset == 28 {
				LoadCommandKind.dylib_use
			} else {
				LoadCommandKind.dylib
			}
		}
		0xd, lc_req_dyld | 0x1f, 0x20, lc_req_dyld | 0x23 { LoadCommandKind.dylib }
		0xe, 0xf, 0x27 { LoadCommandKind.dylinker }
		0x10 { LoadCommandKind.prebound_dylib }
		0x11 { LoadCommandKind.routines }
		0x12 { LoadCommandKind.sub_framework }
		0x13 { LoadCommandKind.sub_umbrella }
		0x14 { LoadCommandKind.sub_client }
		0x15 { LoadCommandKind.sub_library }
		0x16 { LoadCommandKind.twolevel_hints }
		0x17 { LoadCommandKind.prebind_cksum }
		0x19 { LoadCommandKind.segment64 }
		0x1a { LoadCommandKind.routines64 }
		0x1b { LoadCommandKind.uuid }
		lc_req_dyld | 0x1c { LoadCommandKind.rpath }
		0x1d, 0x1e, 0x26, 0x29, 0x2b, 0x2e, lc_req_dyld | 0x33, lc_req_dyld | 0x34, 0x36, 0x37, 0x38, 0x3a {
			LoadCommandKind.linkedit_data
		}
		0x21 { LoadCommandKind.encryption_info }
		0x22, lc_req_dyld | 0x22 { LoadCommandKind.dyld_info }
		0x24, 0x25, 0x2f, 0x30 { LoadCommandKind.version_min }
		lc_req_dyld | 0x28 { LoadCommandKind.entry_point }
		0x2a { LoadCommandKind.source_version }
		0x2c { LoadCommandKind.encryption_info64 }
		0x2d { LoadCommandKind.linker_option }
		0x31 { LoadCommandKind.note }
		0x32 { LoadCommandKind.build_version }
		lc_req_dyld | 0x35 { LoadCommandKind.fileset_entry }
		0x39 { LoadCommandKind.target_triple }
		else { LoadCommandKind.load_command }
	}
}

pub fn (command &LoadCommandRecord) type_symbol() ?string {
	return load_command_name(command.cmd)
}

pub fn (command &LoadCommandRecord) serializable() bool {
	return is_creatable_load_command(command.type_symbol() or { return false })
}

pub fn (command &LoadCommandRecord) source_offset() !int {
	if !command.has_view {
		return error('viewless load command has no source offset')
	}
	return command.view_offset
}

pub fn (value LoadCommandLCStr) str() string {
	return value.value
}

pub fn (value LoadCommandLCStr) int() int {
	return value.offset
}

pub fn (value LoadCommandLCStr) to_h() brew_runtime.Value {
	return brew_runtime.map_value({
		'string': brew_runtime.string_value(value.value)
		'offset': brew_runtime.int_value(value.offset)
	})
}

pub fn new_load_command_lcstr(command &LoadCommandRecord, value brew_runtime.Value) !LoadCommandLCStr {
	if !command.has_view {
		return LoadCommandLCStr{ value: value.as_string() }
	}
	offset := int(value.as_int()!)
	return load_command_lcstr_from_offset(command, offset)
}

fn load_command_lcstr_from_offset(command &LoadCommandRecord, offset int) !LoadCommandLCStr {
	fixed_size := load_command_bytesize(command.kind)
	if offset < fixed_size || offset >= int(command.cmdsize) {
		return error('Load command ${command.type_symbol() or { '' }} at offset ${command.view_offset} contains a malformed string')
	}
	start := command.view_offset + offset
	end := command.view_offset + int(command.cmdsize)
	if start < 0 || end > command.raw_data.len || start >= end {
		return error('Load command ${command.type_symbol() or { '' }} at offset ${command.view_offset} contains a malformed string')
	}
	mut null_index := -1
	for index in start .. end {
		if command.raw_data[index] == 0 {
			null_index = index
			break
		}
	}
	if null_index < 0 {
		return error('Load command ${command.type_symbol() or { '' }} at offset ${command.view_offset} contains a malformed string')
	}
	return LoadCommandLCStr{
		value: command.raw_data[start..null_index].bytestr()
		offset: offset
	}
}

pub fn new_serialization_context(endianness string, alignment int) SerializationContext {
	return SerializationContext{
		endianness: normalize_lc_endianness(endianness)
		alignment: alignment
	}
}

fn get_lc_u32(data []u8, offset int, endianness string) !u32 {
	if offset < 0 || offset + 4 > data.len {
		return error('File is too short to contain a 32-bit load command field')
	}
	return if endianness == 'big' {
		binary.big_endian_u32_at(data, offset)
	} else {
		binary.little_endian_u32_at(data, offset)
	}
}

fn get_lc_u64(data []u8, offset int, endianness string) !u64 {
	if offset < 0 || offset + 8 > data.len {
		return error('File is too short to contain a 64-bit load command field')
	}
	return if endianness == 'big' {
		binary.big_endian_u64_at(data, offset)
	} else {
		binary.little_endian_u64_at(data, offset)
	}
}

fn put_lc_u32(mut data []u8, offset int, value u32, endianness string) {
	if endianness == 'big' {
		binary.big_endian_put_u32_at(mut data, value, offset)
	} else {
		binary.little_endian_put_u32_at(mut data, value, offset)
	}
}

fn put_lc_u64(mut data []u8, offset int, value u64, endianness string) {
	if endianness == 'big' {
		binary.big_endian_put_u64_at(mut data, value, offset)
	} else {
		binary.little_endian_put_u64_at(mut data, value, offset)
	}
}

fn padded_lc_string_payload(fixed_size int, alignment int, value string) []u8 {
	mut bytes := value.bytes()
	bytes << u8(0)
	effective_alignment := if alignment > 0 { alignment } else { 1 }
	for (fixed_size + bytes.len) % effective_alignment != 0 {
		bytes << u8(0)
	}
	return bytes
}

fn load_command_bytesize(kind LoadCommandKind) int {
	return match kind {
		.load_command, .thread, .ident { 8 }
		.uuid { 24 }
		.segment { 56 }
		.segment64 { 72 }
		.dylib { 24 }
		.dylib_use { 28 }
		.dylinker, .sub_framework, .sub_umbrella, .sub_client, .sub_library, .prebind_cksum, .rpath, .target_triple, .linker_option {
			12
		}
		.prebound_dylib, .encryption_info, .fvmlib { 20 }
		.routines { 40 }
		.routines64 { 72 }
		.symtab, .encryption_info64, .build_version, .entry_point { 24 }
		.dysymtab { 80 }
		.twolevel_hints, .linkedit_data, .version_min, .source_version, .symseg, .fvmfile {
			16
		}
		.dyld_info { 48 }
		.note { 40 }
		.fileset_entry { 32 }
	}
}

fn read_fixed_lc_string(data []u8, offset int, size int) string {
	mut end := offset
	for end < offset + size && end < data.len && data[end] != 0 {
		end++
	}
	return if offset >= 0 && offset <= end && end <= data.len {
		data[offset..end].bytestr()
	} else {
		''
	}
}

fn parse_load_command_section(command &LoadCommandRecord, offset int, is_64 bool) !LoadCommandSection {
	endian := command.endianness
	if is_64 {
		return LoadCommandSection{
			is_64: true
			sectname: read_fixed_lc_string(command.raw_data, offset, 16)
			segname: read_fixed_lc_string(command.raw_data, offset + 16, 16)
			addr: get_lc_u64(command.raw_data, offset + 32, endian)!
			size: get_lc_u64(command.raw_data, offset + 40, endian)!
			offset: get_lc_u32(command.raw_data, offset + 48, endian)!
			align: get_lc_u32(command.raw_data, offset + 52, endian)!
			reloff: get_lc_u32(command.raw_data, offset + 56, endian)!
			nreloc: get_lc_u32(command.raw_data, offset + 60, endian)!
			flags: get_lc_u32(command.raw_data, offset + 64, endian)!
			reserved1: get_lc_u32(command.raw_data, offset + 68, endian)!
			reserved2: get_lc_u32(command.raw_data, offset + 72, endian)!
			reserved3: get_lc_u32(command.raw_data, offset + 76, endian)!
		}
	}
	return LoadCommandSection{
		sectname: read_fixed_lc_string(command.raw_data, offset, 16)
		segname: read_fixed_lc_string(command.raw_data, offset + 16, 16)
		addr: get_lc_u32(command.raw_data, offset + 32, endian)!
		size: get_lc_u32(command.raw_data, offset + 36, endian)!
		offset: get_lc_u32(command.raw_data, offset + 40, endian)!
		align: get_lc_u32(command.raw_data, offset + 44, endian)!
		reloff: get_lc_u32(command.raw_data, offset + 48, endian)!
		nreloc: get_lc_u32(command.raw_data, offset + 52, endian)!
		flags: get_lc_u32(command.raw_data, offset + 56, endian)!
		reserved1: get_lc_u32(command.raw_data, offset + 60, endian)!
		reserved2: get_lc_u32(command.raw_data, offset + 64, endian)!
	}
}

pub fn (section LoadCommandSection) to_h() brew_runtime.Value {
	mut values := {
		'sectname':  brew_runtime.string_value(section.sectname)
		'segname':   brew_runtime.string_value(section.segname)
		'addr':      brew_runtime.int_value(i64(section.addr))
		'size':      brew_runtime.int_value(i64(section.size))
		'offset':    brew_runtime.int_value(section.offset)
		'align':     brew_runtime.int_value(section.align)
		'reloff':    brew_runtime.int_value(section.reloff)
		'nreloc':    brew_runtime.int_value(section.nreloc)
		'flags':     brew_runtime.int_value(section.flags)
		'reserved1': brew_runtime.int_value(section.reserved1)
		'reserved2': brew_runtime.int_value(section.reserved2)
	}
	if section.is_64 {
		values['reserved3'] = brew_runtime.int_value(section.reserved3)
	}
	return brew_runtime.map_value(values)
}

fn load_command_number(command &LoadCommandRecord, name string) i64 {
	return command.numbers[name] or { 0 }
}

fn set_lc_u32(mut command LoadCommandRecord, name string, offset int) ! {
	command.numbers[name] = i64(get_lc_u32(command.raw_data, command.view_offset + offset, command.endianness)!)
}

fn set_lc_u64(mut command LoadCommandRecord, name string, offset int) ! {
	command.numbers[name] = i64(get_lc_u64(command.raw_data, command.view_offset + offset, command.endianness)!)
}

fn set_lc_string(mut command LoadCommandRecord, name string, field_offset int) ! {
	offset := int(get_lc_u32(command.raw_data, command.view_offset + field_offset, command.endianness)!)
	command.strings[name] = load_command_lcstr_from_offset(command, offset)!
}

pub fn new_load_command_from_bin(kind LoadCommandKind, view &LoadCommandView) !&LoadCommandRecord {
	endian := normalize_lc_endianness(view.endianness)
	cmd := get_lc_u32(view.raw_data, view.offset, endian)!
	cmdsize := get_lc_u32(view.raw_data, view.offset + 4, endian)!
	if cmdsize < 8 || view.offset < 0 || view.offset + int(cmdsize) > view.raw_data.len {
		return error('Invalid Mach-O load command size: ${cmdsize}')
	}
	name_offset := if cmdsize >= 12 {
		get_lc_u32(view.raw_data, view.offset + 8, endian)!
	} else {
		u32(0)
	}
	timestamp := if cmdsize >= 16 {
		get_lc_u32(view.raw_data, view.offset + 12, endian)!
	} else {
		u32(0)
	}
	actual_kind := if kind == .load_command {
		load_command_kind_for(cmd, name_offset, timestamp)
	} else {
		kind
	}
	mut command := &LoadCommandRecord{
		kind: actual_kind
		cmd: cmd
		cmdsize: cmdsize
		has_view: true
		raw_data: view.raw_data.clone()
		view_offset: view.offset
		endianness: endian
		file_alignment: view.alignment
		numbers: map[string]i64{}
		strings: map[string]LoadCommandLCStr{}
		file_segments: view.segments.clone()
	}
	base := view.offset
	match actual_kind {
		.uuid {
			if base + 24 > view.raw_data.len {
				return error('File is too short to contain LC_UUID')
			}
			command.uuid = view.raw_data[base + 8..base + 24].clone()
		}
		.segment, .segment64 {
			command.strings['segname'] = LoadCommandLCStr{ value: read_fixed_lc_string(view.raw_data, base + 8, 16) }
			is_64 := actual_kind == .segment64
			if is_64 {
				for name, offset in {
					'vmaddr':   24
					'vmsize':   32
					'fileoff':  40
					'filesize': 48
				} {
					set_lc_u64(mut command, name, offset)!
				}
				for name, offset in {
					'maxprot':  56
					'initprot': 60
					'nsects':   64
					'flags':    68
				} {
					set_lc_u32(mut command, name, offset)!
				}
			} else {
				for name, offset in {
					'vmaddr':   24
					'vmsize':   28
					'fileoff':  32
					'filesize': 36
					'maxprot':  40
					'initprot': 44
					'nsects':   48
					'flags':    52
				} {
					set_lc_u32(mut command, name, offset)!
				}
			}
			section_size := if is_64 { 80 } else { 68 }
			section_start := base + load_command_bytesize(actual_kind)
			for index in 0 .. int(load_command_number(command, 'nsects')) {
				command.sections << parse_load_command_section(command, section_start + index * section_size, is_64)!
			}
		}
		.dylib, .dylib_use {
			set_lc_string(mut command, 'name', 8)!
			for name, offset in {
				'timestamp':             12
				'current_version':       16
				'compatibility_version': 20
			} {
				set_lc_u32(mut command, name, offset)!
			}
			if actual_kind == .dylib_use { set_lc_u32(mut command, 'flags', 24)! }
		}
		.dylinker { set_lc_string(mut command, 'name', 8)! }
		.prebound_dylib {
			set_lc_string(mut command, 'name', 8)!
			set_lc_u32(mut command, 'nmodules', 12)!
			set_lc_u32(mut command, 'linked_modules', 16)!
		}
		.routines, .routines64 {
			names := ['init_address', 'init_module', 'reserved1', 'reserved2', 'reserved3',
				'reserved4', 'reserved5', 'reserved6']
			width := if actual_kind == .routines64 { 8 } else { 4 }
			for index, name in names {
				if width == 8 {
					set_lc_u64(mut command, name, 8 + index * width)!
				} else {
					set_lc_u32(mut command, name, 8 + index * width)!
				}
			}
		}
		.sub_framework { set_lc_string(mut command, 'umbrella', 8)! }
		.sub_umbrella { set_lc_string(mut command, 'sub_umbrella', 8)! }
		.sub_client { set_lc_string(mut command, 'sub_client', 8)! }
		.sub_library { set_lc_string(mut command, 'sub_library', 8)! }
		.symtab {
			for name, offset in {
				'symoff':  8
				'nsyms':   12
				'stroff':  16
				'strsize': 20
			} {
				set_lc_u32(mut command, name, offset)!
			}
		}
		.dysymtab {
			names := ['ilocalsym', 'nlocalsym', 'iextdefsym', 'nextdefsym', 'iundefsym', 'nundefsym',
				'tocoff', 'ntoc', 'modtaboff', 'nmodtab', 'extrefsymoff', 'nextrefsyms',
				'indirectsymoff', 'nindirectsyms', 'extreloff', 'nextrel', 'locreloff', 'nlocrel']
			for index, name in names {
				set_lc_u32(mut command, name, 8 + index * 4)!
			}
		}
		.twolevel_hints {
			set_lc_u32(mut command, 'htoffset', 8)!
			set_lc_u32(mut command, 'nhints', 12)!
			command.hints = new_twolevel_hints_table(view, int(load_command_number(command, 'htoffset')), int(load_command_number(command, 'nhints')))!.hints
		}
		.prebind_cksum { set_lc_u32(mut command, 'cksum', 8)! }
		.rpath { set_lc_string(mut command, 'path', 8)! }
		.target_triple { set_lc_string(mut command, 'triple', 8)! }
		.linkedit_data {
			set_lc_u32(mut command, 'dataoff', 8)!
			set_lc_u32(mut command, 'datasize', 12)!
		}
		.encryption_info, .encryption_info64 {
			for name, offset in {
				'cryptoff':  8
				'cryptsize': 12
				'cryptid':   16
			} {
				set_lc_u32(mut command, name, offset)!
			}
			if actual_kind == .encryption_info64 { set_lc_u32(mut command, 'pad', 20)! }
		}
		.version_min {
			set_lc_u32(mut command, 'version', 8)!
			set_lc_u32(mut command, 'sdk', 12)!
		}
		.build_version {
			for name, offset in {
				'platform': 8
				'minos':    12
				'sdk':      16
				'ntools':   20
			} {
				set_lc_u32(mut command, name, offset)!
			}
			command.tools = new_build_tool_entries(view, int(load_command_number(command, 'ntools')))!.tools
		}
		.dyld_info {
			names := ['rebase_off', 'rebase_size', 'bind_off', 'bind_size', 'weak_bind_off',
				'weak_bind_size', 'lazy_bind_off', 'lazy_bind_size', 'export_off', 'export_size']
			for index, name in names {
				set_lc_u32(mut command, name, 8 + index * 4)!
			}
		}
		.linker_option { set_lc_u32(mut command, 'count', 8)! }
		.entry_point {
			set_lc_u64(mut command, 'entryoff', 8)!
			set_lc_u64(mut command, 'stacksize', 16)!
		}
		.source_version { set_lc_u64(mut command, 'version', 8)! }
		.symseg {
			set_lc_u32(mut command, 'offset', 8)!
			set_lc_u32(mut command, 'size', 12)!
		}
		.fvmfile {
			set_lc_string(mut command, 'name', 8)!
			set_lc_u32(mut command, 'header_addr', 12)!
		}
		.fvmlib {
			set_lc_string(mut command, 'name', 8)!
			set_lc_u32(mut command, 'minor_version', 12)!
			set_lc_u32(mut command, 'header_addr', 16)!
		}
		.note {
			command.strings['data_owner'] = LoadCommandLCStr{ value: read_fixed_lc_string(view.raw_data, base + 8, 16) }
			set_lc_u64(mut command, 'offset', 24)!
			set_lc_u64(mut command, 'size', 32)!
		}
		.fileset_entry {
			set_lc_u64(mut command, 'vmaddr', 8)!
			set_lc_u64(mut command, 'fileoff', 16)!
			set_lc_string(mut command, 'entry_id', 24)!
			set_lc_u32(mut command, 'reserved', 28)!
		}
		else {}
	}
	return command
}

pub fn create_load_command(command_symbol string, args []brew_runtime.Value) !&LoadCommandRecord {
	name := normalize_lc_symbol(command_symbol)
	if !is_creatable_load_command(name) {
		return error('Load commands of type ${name} cannot be created manually')
	}
	cmd := load_command_constant(name) or { return error('Unrecognized Mach-O load command: ${name}') }
	mut required := 0
	mut kind := LoadCommandKind.load_command
	if name == 'LC_RPATH' {
		kind, required = .rpath, 1
	} else if name == 'LC_LOAD_DYLINKER' {
		kind, required = .dylinker, 1
	} else if name == 'LC_CODE_SIGNATURE' {
		kind, required = .linkedit_data, 2
	} else {
		kind, required = .dylib, 4
		if name in ['LC_LOAD_DYLIB', 'LC_LOAD_WEAK_DYLIB'] && args.len > 4 && u32(args[1].as_int()!) == dylib_use_marker {
			kind, required = .dylib_use, 5
		}
	}
	if args.len < required {
		return error('Expected ${required} arguments for ${name} creation, got ${args.len}')
	}
	mut command := new_load_command(kind, cmd)
	match kind {
		.rpath {
			command.strings['path'] = LoadCommandLCStr{ value: args[0].as_string() }
		}
		.dylinker {
			command.strings['name'] = LoadCommandLCStr{ value: args[0].as_string() }
		}
		.linkedit_data {
			command.numbers['dataoff'] = args[0].as_int()!
			command.numbers['datasize'] = args[1].as_int()!
		}
		.dylib, .dylib_use {
			command.strings['name'] = LoadCommandLCStr{ value: args[0].as_string() }
			command.numbers['timestamp'] = args[1].as_int()!
			command.numbers['current_version'] = args[2].as_int()!
			command.numbers['compatibility_version'] = args[3].as_int()!
			if kind == .dylib_use {
				command.numbers['flags'] = args[4].as_int()!
			}
		}
		else {}
	}
	return command
}

pub fn (command &LoadCommandRecord) flag(flag string) bool {
	name := normalize_lc_symbol(flag)
	if command.kind == .dylib_use {
		value := match name {
			'DYLIB_USE_WEAK_LINK' { u32(0x1) }
			'DYLIB_USE_REEXPORT' { u32(0x2) }
			'DYLIB_USE_UPWARD' { u32(0x4) }
			'DYLIB_USE_DELAYED_INIT' { u32(0x8) }
			else {
				return false
			}
		}
		return u32(load_command_number(command, 'flags')) & value == value
	}
	if command.kind == .dylib {
		return match command.type_symbol() or { '' } {
			'LC_LOAD_WEAK_DYLIB' { name == 'DYLIB_USE_WEAK_LINK' }
			'LC_REEXPORT_DYLIB' { name == 'DYLIB_USE_REEXPORT' }
			'LC_LOAD_UPWARD_DYLIB' { name == 'DYLIB_USE_UPWARD' }
			else { false }
		}
	}
	if command.kind in [.segment, .segment64] {
		value := match name {
			'SG_HIGHVM' { u32(0x1) }
			'SG_FVMLIB' { u32(0x2) }
			'SG_NORELOC' { u32(0x4) }
			'SG_PROTECTED_VERSION_1' { u32(0x8) }
			'SG_READ_ONLY' { u32(0x10) }
			else {
				return false
			}
		}
		return u32(load_command_number(command, 'flags')) & value == value
	}
	return false
}

pub fn (command &LoadCommandRecord) guess_align() int {
	vmaddr := u64(load_command_number(command, 'vmaddr'))
	if vmaddr == 0 {
		return max_section_alignment
	}
	mut align := 0
	mut segment_alignment := u64(1)
	for segment_alignment & vmaddr == 0 {
		segment_alignment <<= 1
		align++
	}
	if align < 2 {
		return 2
	}
	if align > max_section_alignment {
		return max_section_alignment
	}
	return align
}

pub fn (command &LoadCommandRecord) uuid_string() string {
	if command.uuid.len != 16 {
		return ''
	}
	mut hexes := []string{cap: 16}
	for elem in command.uuid {
		hexes << '${elem:02x}'
	}
	return hexes[0..4].join('') + '-' + hexes[4..6].join('') + '-' + hexes[6..8].join('') + '-' + hexes[8..10].join('') + '-' + hexes[10..16].join('')
}

pub fn packed_version_string(value u32) string {
	return '${value >> 16}.${(value >> 8) & 0xff}.${value & 0xff}'
}

pub fn packed_source_version_string(value u64) string {
	return '${value >> 40}.${(value >> 30) & 0x3ff}.${(value >> 20) & 0x3ff}.${(value >> 10) & 0x3ff}.${value & 0x3ff}'
}

pub fn new_twolevel_hint(blob u32) TwolevelHint {
	return TwolevelHint{ isub_image: blob >> 24, itoc: blob & 0x00ff_ffff }
}

pub fn (hint TwolevelHint) to_h() brew_runtime.Value {
	return brew_runtime.map_value({
		'isub_image': brew_runtime.int_value(hint.isub_image)
		'itoc':       brew_runtime.int_value(hint.itoc)
	})
}

pub fn new_twolevel_hints_table(view &LoadCommandView, table_offset int, count int) !TwolevelHintsTable {
	mut hints := []TwolevelHint{cap: count}
	for index in 0 .. count {
		blob := get_lc_u32(view.raw_data, table_offset + index * 4, normalize_lc_endianness(view.endianness))!
		hints << new_twolevel_hint(blob)
	}
	return TwolevelHintsTable{ hints: hints }
}

pub fn (tool BuildTool) to_h() brew_runtime.Value {
	return brew_runtime.map_value({
		'tool':    brew_runtime.int_value(tool.tool)
		'version': brew_runtime.int_value(tool.version)
	})
}

pub fn new_build_tool_entries(view &LoadCommandView, count int) !BuildToolEntries {
	mut tools := []BuildTool{cap: count}
	for index in 0 .. count {
		offset := view.offset + 24 + index * 8
		tools << BuildTool{
			tool: get_lc_u32(view.raw_data, offset, normalize_lc_endianness(view.endianness))!
			version: get_lc_u32(view.raw_data, offset + 4, normalize_lc_endianness(view.endianness))!
		}
	}
	return BuildToolEntries{ tools: tools }
}

pub fn (command &LoadCommandRecord) serialize(context SerializationContext) ![]u8 {
	if !command.serializable() {
		return error('Load commands of type ${command.type_symbol() or { '' }} cannot be serialized')
	}
	endian := normalize_lc_endianness(context.endianness)
	fixed_size := load_command_bytesize(command.kind)
	mut bytes := []u8{}
	match command.kind {
		.dylib, .dylib_use, .dylinker, .rpath {
			key := if command.kind == .rpath { 'path' } else { 'name' }
			text := (command.strings[key] or { LoadCommandLCStr{} }).value
			payload := padded_lc_string_payload(fixed_size, context.alignment, text)
			bytes = []u8{len: fixed_size + payload.len}
			put_lc_u32(mut bytes, 0, command.cmd, endian)
			put_lc_u32(mut bytes, 4, u32(bytes.len), endian)
			put_lc_u32(mut bytes, 8, u32(fixed_size), endian)
			if command.kind in [.dylib, .dylib_use] {
				put_lc_u32(mut bytes, 12, u32(load_command_number(command, 'timestamp')), endian)
				put_lc_u32(mut bytes, 16, u32(load_command_number(command, 'current_version')), endian)
				put_lc_u32(mut bytes, 20, u32(load_command_number(command, 'compatibility_version')), endian)
				if command.kind == .dylib_use {
					put_lc_u32(mut bytes, 24, u32(load_command_number(command, 'flags')), endian)
				}
			}
			copy(mut bytes[fixed_size..], payload)
		}
		.linkedit_data {
			bytes = []u8{len: 16}
			put_lc_u32(mut bytes, 0, command.cmd, endian)
			put_lc_u32(mut bytes, 4, 16, endian)
			put_lc_u32(mut bytes, 8, u32(load_command_number(command, 'dataoff')), endian)
			put_lc_u32(mut bytes, 12, u32(load_command_number(command, 'datasize')), endian)
		}
		else {
			bytes = []u8{len: 8}
			put_lc_u32(mut bytes, 0, command.cmd, endian)
			put_lc_u32(mut bytes, 4, u32(fixed_size), endian)
		}
	}
	return bytes
}

pub fn (command &LoadCommandRecord) superblob() !CodeSigningSuperBlob {
	if command.type_symbol() or { '' } != 'LC_CODE_SIGNATURE' {
		return error('${command.type_symbol() or { '' }} does not contain a code signature')
	}
	offset := int(load_command_number(command, 'dataoff'))
	size := int(load_command_number(command, 'datasize'))
	if offset < 0 || size < 0 || offset + size > command.raw_data.len {
		return error('code signature range lies outside the Mach-O data')
	}
	return CodeSigningSuperBlob{ data: command.raw_data[offset..offset + size].clone() }
}

pub fn (command &LoadCommandRecord) matching_segment() ?&LoadCommandRecord {
	fileoff := load_command_number(command, 'fileoff')
	for segment in command.file_segments {
		if segment.kind == .segment64 && load_command_number(segment, 'fileoff') == fileoff {
			return segment
		}
	}
	return none
}

fn lc_view_to_h(command &LoadCommandRecord) brew_runtime.Value {
	if !command.has_view {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.map_value({
		'offset':     brew_runtime.int_value(command.view_offset)
		'endianness': brew_runtime.string_value(command.endianness)
		'size':       brew_runtime.int_value(command.raw_data.len)
	})
}

fn add_lc_number(mut values map[string]brew_runtime.Value, command &LoadCommandRecord, name string) {
	values[name] = brew_runtime.int_value(load_command_number(command, name))
}

fn add_lc_string(mut values map[string]brew_runtime.Value, command &LoadCommandRecord, name string, nested bool) {
	value := command.strings[name] or { LoadCommandLCStr{} }
	values[name] = if nested { value.to_h() } else { brew_runtime.string_value(value.value) }
}

fn load_command_structure_format(kind LoadCommandKind) string {
	return match kind {
		.load_command, .thread, .ident { 'L=L=' }
		.uuid { 'L=L=C16' }
		.segment { 'L=L=a16L=L=L=L=l=l=L=L=' }
		.segment64 { 'L=L=a16Q=Q=Q=Q=l=l=L=L=' }
		.dylib { 'L=L=L=L=L=L=' }
		.dylib_use { 'L=L=L=L=L=L=L=' }
		.dylinker, .sub_framework, .sub_umbrella, .sub_client, .sub_library, .rpath, .target_triple {
			'L=L=L='
		}
		.prebound_dylib { 'L=L=L=L=L=' }
		.routines { 'L=L=L=L=L=L=L=L=L=L=' }
		.routines64 { 'L=L=Q=Q=Q=Q=Q=Q=Q=Q=' }
		.symtab { 'L=L=L=L=L=L=' }
		.dysymtab { 'L=L=' + 'L='.repeat(18) }
		.twolevel_hints { 'L=L=L=L=' }
		.prebind_cksum, .linker_option { 'L=L=L=' }
		.linkedit_data, .version_min, .symseg, .fvmfile { 'L=L=L=L=' }
		.encryption_info { 'L=L=L=L=L=' }
		.encryption_info64, .build_version { 'L=L=L=L=L=L=' }
		.dyld_info { 'L=L=' + 'L='.repeat(10) }
		.entry_point { 'L=L=Q=Q=' }
		.source_version { 'L=L=Q=' }
		.fvmlib { 'L=L=L=L=L=' }
		.note { 'L=L=a16Q=Q=' }
		.fileset_entry { 'L=L=Q=Q=L=L=' }
	}
}

pub fn (command &LoadCommandRecord) to_h() brew_runtime.Value {
	mut values := {
		'view':      lc_view_to_h(command)
		'cmd':       brew_runtime.int_value(command.cmd)
		'cmdsize':   brew_runtime.int_value(command.cmdsize)
		'type':      if symbol := command.type_symbol() {
			brew_runtime.string_value(symbol)
		} else {
			brew_runtime.object_value('NilClass', 'nil')
		}
		'structure': brew_runtime.map_value({
			'format':   brew_runtime.string_value(load_command_structure_format(command.kind))
			'bytesize': brew_runtime.int_value(load_command_bytesize(command.kind))
		})
	}
	match command.kind {
		.uuid {
			values['uuid'] = brew_runtime.array_value(command.uuid.map(brew_runtime.int_value(it)))
			values['uuid_string'] = brew_runtime.string_value(command.uuid_string())
		}
		.segment, .segment64 {
			add_lc_string(mut values, command, 'segname', false)
			for name in ['vmaddr', 'vmsize', 'fileoff', 'filesize', 'maxprot', 'initprot', 'nsects',
				'flags'] {
				add_lc_number(mut values, command, name)
			}
			values['sections'] = brew_runtime.array_value(command.sections.map(it.to_h()))
		}
		.dylib, .dylib_use {
			add_lc_string(mut values, command, 'name', true)
			for name in ['timestamp', 'current_version', 'compatibility_version'] {
				add_lc_number(mut values, command, name)
			}
			if command.kind == .dylib_use { add_lc_number(mut values, command, 'flags') }
		}
		.dylinker { add_lc_string(mut values, command, 'name', true) }
		.prebound_dylib {
			add_lc_string(mut values, command, 'name', true)
			for name in ['nmodules', 'linked_modules'] {
				add_lc_number(mut values, command, name)
			}
		}
		.routines, .routines64 {
			for name in ['init_address', 'init_module', 'reserved1', 'reserved2', 'reserved3',
				'reserved4', 'reserved5', 'reserved6'] {
				add_lc_number(mut values, command, name)
			}
		}
		.sub_framework { add_lc_string(mut values, command, 'umbrella', true) }
		.sub_umbrella { add_lc_string(mut values, command, 'sub_umbrella', true) }
		.sub_client { add_lc_string(mut values, command, 'sub_client', true) }
		.sub_library { add_lc_string(mut values, command, 'sub_library', true) }
		.symtab {
			for name in ['symoff', 'nsyms', 'stroff', 'strsize'] {
				add_lc_number(mut values, command, name)
			}
		}
		.dysymtab {
			for name in ['ilocalsym', 'nlocalsym', 'iextdefsym', 'nextdefsym', 'iundefsym',
				'nundefsym', 'tocoff', 'ntoc', 'modtaboff', 'nmodtab', 'extrefsymoff', 'nextrefsyms',
				'indirectsymoff', 'nindirectsyms', 'extreloff', 'nextrel', 'locreloff', 'nlocrel'] {
				add_lc_number(mut values, command, name)
			}
		}
		.twolevel_hints {
			add_lc_number(mut values, command, 'htoffset')
			add_lc_number(mut values, command, 'nhints')
			values['table'] = brew_runtime.array_value(command.hints.map(it.to_h()))
		}
		.prebind_cksum { add_lc_number(mut values, command, 'cksum') }
		.rpath { add_lc_string(mut values, command, 'path', true) }
		.target_triple { add_lc_string(mut values, command, 'triple', true) }
		.linkedit_data {
			add_lc_number(mut values, command, 'dataoff')
			add_lc_number(mut values, command, 'datasize')
		}
		.encryption_info, .encryption_info64 {
			for name in ['cryptoff', 'cryptsize', 'cryptid'] {
				add_lc_number(mut values, command, name)
			}
			if command.kind == .encryption_info64 { add_lc_number(mut values, command, 'pad') }
		}
		.version_min {
			add_lc_number(mut values, command, 'version')
			values['version_string'] = brew_runtime.string_value(packed_version_string(u32(load_command_number(command, 'version'))))
			add_lc_number(mut values, command, 'sdk')
			values['sdk_string'] = brew_runtime.string_value(packed_version_string(u32(load_command_number(command, 'sdk'))))
		}
		.build_version {
			add_lc_number(mut values, command, 'platform')
			add_lc_number(mut values, command, 'minos')
			values['minos_string'] = brew_runtime.string_value(packed_version_string(u32(load_command_number(command, 'minos'))))
			add_lc_number(mut values, command, 'sdk')
			values['sdk_string'] = brew_runtime.string_value(packed_version_string(u32(load_command_number(command, 'sdk'))))
			values['tool_entries'] = brew_runtime.array_value(command.tools.map(it.to_h()))
		}
		.dyld_info {
			for name in ['rebase_off', 'rebase_size', 'bind_off', 'bind_size', 'weak_bind_off',
				'weak_bind_size', 'lazy_bind_off', 'lazy_bind_size', 'export_off', 'export_size'] {
				add_lc_number(mut values, command, name)
			}
		}
		.linker_option { add_lc_number(mut values, command, 'count') }
		.entry_point {
			add_lc_number(mut values, command, 'entryoff')
			add_lc_number(mut values, command, 'stacksize')
		}
		.source_version {
			add_lc_number(mut values, command, 'version')
			values['version_string'] = brew_runtime.string_value(packed_source_version_string(u64(load_command_number(command, 'version'))))
		}
		.symseg {
			add_lc_number(mut values, command, 'offset')
			add_lc_number(mut values, command, 'size')
		}
		.fvmfile {
			add_lc_string(mut values, command, 'name', true)
			add_lc_number(mut values, command, 'header_addr')
		}
		.fvmlib {
			add_lc_string(mut values, command, 'name', true)
			add_lc_number(mut values, command, 'minor_version')
			add_lc_number(mut values, command, 'header_addr')
		}
		.note {
			add_lc_string(mut values, command, 'data_owner', false)
			add_lc_number(mut values, command, 'offset')
			add_lc_number(mut values, command, 'size')
		}
		.fileset_entry {
			add_lc_number(mut values, command, 'vmaddr')
			add_lc_number(mut values, command, 'fileoff')
			add_lc_string(mut values, command, 'entry_id', false)
			add_lc_number(mut values, command, 'reserved')
		}
		else {}
	}
	return brew_runtime.map_value(values)
}

fn load_command_boundary(command &LoadCommandRecord) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::${command.kind}', command.type_symbol() or { '' }, {
		'load_command_address': u64(voidptr(command)).str()
	})
}

fn load_command_from_args(args []brew_runtime.Value) &LoadCommandRecord {
	if args.len == 0 { panic('load command method requires a receiver') }
	address := (args[0].attribute('load_command_address') or { panic('${args[0].type_name} has no translated load command state') }).u64()
	return unsafe { &LoadCommandRecord(voidptr(address)) }
}

fn lcstr_boundary(value &LoadCommandLCStr) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::LoadCommand::LCStr', value.value, {
		'load_command_lcstr_offset': value.offset.str()
	})
}

fn context_boundary(context &SerializationContext) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::SerializationContext', context.endianness, {
		'load_command_context_address': u64(voidptr(context)).str()
	})
}

fn context_from_value(value brew_runtime.Value) &SerializationContext {
	address := (value.attribute('load_command_context_address') or { panic('${value.type_name} has no translated serialization context') }).u64()
	return unsafe { &SerializationContext(voidptr(address)) }
}

fn view_boundary(view &LoadCommandView, kind LoadCommandKind) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::View', '#<MachO::View>', {
		'load_command_view_address': u64(voidptr(view)).str()
		'load_command_kind':         kind.str()
	})
}

fn view_from_value(value brew_runtime.Value) &LoadCommandView {
	address := (value.attribute('load_command_view_address') or { panic('${value.type_name} has no translated load command view') }).u64()
	return unsafe { &LoadCommandView(voidptr(address)) }
}

fn kind_from_value(value brew_runtime.Value) LoadCommandKind {
	name := value.attribute('load_command_kind') or { return .load_command }
	return match name {
		'uuid' { .uuid }
		'segment' { .segment }
		'segment64' { .segment64 }
		'dylib' { .dylib }
		'dylib_use' { .dylib_use }
		'dylinker' { .dylinker }
		'prebound_dylib' { .prebound_dylib }
		'thread' { .thread }
		'routines' { .routines }
		'routines64' { .routines64 }
		'sub_framework' { .sub_framework }
		'sub_umbrella' { .sub_umbrella }
		'sub_client' { .sub_client }
		'sub_library' { .sub_library }
		'symtab' { .symtab }
		'dysymtab' { .dysymtab }
		'twolevel_hints' { .twolevel_hints }
		'prebind_cksum' { .prebind_cksum }
		'rpath' { .rpath }
		'target_triple' { .target_triple }
		'linkedit_data' { .linkedit_data }
		'encryption_info' { .encryption_info }
		'encryption_info64' { .encryption_info64 }
		'version_min' { .version_min }
		'build_version' { .build_version }
		'dyld_info' { .dyld_info }
		'linker_option' { .linker_option }
		'entry_point' { .entry_point }
		'source_version' { .source_version }
		'symseg' { .symseg }
		'ident' { .ident }
		'fvmfile' { .fvmfile }
		'fvmlib' { .fvmlib }
		'note' { .note }
		'fileset_entry' { .fileset_entry }
		else { .load_command }
	}
}

fn hints_table_boundary(table &TwolevelHintsTable) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::TwolevelHintsTable', '#<TwolevelHintsTable>', {
		'load_command_hints_address': u64(voidptr(table)).str()
	})
}

fn hints_table_from_args(args []brew_runtime.Value) &TwolevelHintsTable {
	if args.len == 0 { panic('TwolevelHintsTable method requires a receiver') }
	return unsafe { &TwolevelHintsTable(voidptr((args[0].attribute('load_command_hints_address') or { panic(err) }).u64())) }
}

fn hint_boundary(hint &TwolevelHint) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::TwolevelHint', '#<TwolevelHint>', {
		'load_command_hint_address': u64(voidptr(hint)).str()
	})
}

fn hint_from_args(args []brew_runtime.Value) &TwolevelHint {
	if args.len == 0 { panic('TwolevelHint method requires a receiver') }
	return unsafe { &TwolevelHint(voidptr((args[0].attribute('load_command_hint_address') or { panic(err) }).u64())) }
}

fn tools_boundary(entries &BuildToolEntries) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::ToolEntries', '#<ToolEntries>', {
		'load_command_tools_address': u64(voidptr(entries)).str()
	})
}

fn tools_from_args(args []brew_runtime.Value) &BuildToolEntries {
	if args.len == 0 { panic('ToolEntries method requires a receiver') }
	return unsafe { &BuildToolEntries(voidptr((args[0].attribute('load_command_tools_address') or { panic(err) }).u64())) }
}

fn tool_boundary(tool &BuildTool) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::Tool', '#<Tool>', {
		'load_command_tool_address': u64(voidptr(tool)).str()
	})
}

fn tool_from_args(args []brew_runtime.Value) &BuildTool {
	if args.len == 0 { panic('Tool method requires a receiver') }
	return unsafe { &BuildTool(voidptr((args[0].attribute('load_command_tool_address') or { panic(err) }).u64())) }
}

// Ruby method `self.new_from_bin(view)` at line 240.
pub fn ruby_load_commands_l240_d1_self_new_from_bin(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('LoadCommand.new_from_bin requires a view') }
	return load_command_boundary(new_load_command_from_bin(kind_from_value(args[0]), view_from_value(args[0])) or { panic(err) })
}

// Ruby method `self.create(cmd_sym, *args)` at line 250.
pub fn ruby_load_commands_l250_d2_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('LoadCommand.create requires a command symbol') }
	return load_command_boundary(create_load_command(args[0].as_string(), args[1..]) or { panic(err) })
}

// Ruby method `serializable?` at line 272.
pub fn ruby_load_commands_l272_d3_serializable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(load_command_from_args(args).serializable())
}

// Ruby method `serialize(context)` at line 281.
pub fn ruby_load_commands_l281_d4_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('LoadCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `offset` at line 290.
pub fn ruby_load_commands_l290_d5_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(load_command_from_args(args).source_offset() or { panic(err) })
}

// Ruby method `type` at line 296.
pub fn ruby_load_commands_l296_d6_type(args ...brew_runtime.Value) brew_runtime.Value {
	return if symbol := load_command_from_args(args).type_symbol() {
		brew_runtime.string_value(symbol)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby alias `alias to_sym type` at line 300.
pub fn ruby_load_commands_l300_d7_to_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_load_commands_l296_d6_type(...args)
}

// Ruby method `to_s` at line 304.
pub fn ruby_load_commands_l304_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(load_command_from_args(args).type_symbol() or { '' })
}

// Ruby method `to_h` at line 310.
pub fn ruby_load_commands_l310_d9_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `initialize(lc, lc_str)` at line 332.
pub fn ruby_load_commands_l332_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('LCStr#initialize requires a load command and string or offset') }
	value := new_load_command_lcstr(load_command_from_args(args[..1]), args[1]) or { panic(err) }
	return brew_runtime.structured_value('MachO::LoadCommands::LoadCommand::LCStr', value.value, {
		'load_command_lcstr_offset': value.offset.str()
	})
}

// Ruby method `to_s` at line 353.
pub fn ruby_load_commands_l353_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('LCStr#to_s requires a receiver') }
	return brew_runtime.string_value(args[0].as_string())
}

// Ruby method `to_i` at line 359.
pub fn ruby_load_commands_l359_d12_to_i(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('LCStr#to_i requires a receiver') }
	return brew_runtime.int_value((args[0].attribute('load_command_lcstr_offset') or { panic(err) }).int())
}

// Ruby method `to_h` at line 364.
pub fn ruby_load_commands_l364_d13_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('LCStr#to_h requires a receiver') }
	return brew_runtime.map_value({
		'string': brew_runtime.string_value(args[0].as_string())
		'offset': brew_runtime.int_value((args[0].attribute('load_command_lcstr_offset') or { panic(err) }).int())
	})
}

// Ruby attr_reader `attr_reader :endianness` at line 376.
pub fn ruby_load_commands_l376_d14_endianness(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(context_from_value(args[0]).endianness)
}

// Ruby attr_reader `attr_reader :alignment` at line 380.
pub fn ruby_load_commands_l380_d15_alignment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(context_from_value(args[0]).alignment)
}

// Ruby method `self.context_for(macho)` at line 385.
pub fn ruby_load_commands_l385_d16_self_context_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('SerializationContext.context_for requires a Mach-O') }
	if args[0].attributes['load_command_context_address'] or { '' } != '' {
		old := context_from_value(args[0])
		context := &SerializationContext{ endianness: old.endianness, alignment: old.alignment }
		return context_boundary(context)
	}
	endianness := args[0].attribute('endianness') or { panic('Mach-O has no endianness') }
	alignment := (args[0].attribute('alignment') or { panic('Mach-O has no alignment') }).int()
	context := &SerializationContext{ endianness: normalize_lc_endianness(endianness), alignment: alignment }
	return context_boundary(context)
}

// Ruby method `initialize(endianness, alignment)` at line 392.
pub fn ruby_load_commands_l392_d17_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SerializationContext#initialize requires endianness and alignment') }
	context := &SerializationContext{
		endianness: normalize_lc_endianness(args[0].as_string())
		alignment: int(args[1].as_int() or { panic(err) })
	}
	return context_boundary(context)
}

// Ruby method `uuid_string` at line 407.
pub fn ruby_load_commands_l407_d18_uuid_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(load_command_from_args(args).uuid_string())
}

// Ruby method `to_s` at line 418.
pub fn ruby_load_commands_l418_d19_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(load_command_from_args(args).uuid_string())
}

// Ruby method `to_h` at line 423.
pub fn ruby_load_commands_l423_d20_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `sections` at line 464.
pub fn ruby_load_commands_l464_d21_sections(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(load_command_from_args(args).sections.map(it.to_h()))
}

// Ruby method `flag?(flag)` at line 485.
pub fn ruby_load_commands_l485_d22_flag(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SegmentCommand#flag? requires a flag') }
	return brew_runtime.bool_value(load_command_from_args(args).flag(args[1].as_string()))
}

// Ruby method `guess_align` at line 496.
pub fn ruby_load_commands_l496_d23_guess_align(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(load_command_from_args(args).guess_align())
}

// Ruby method `to_h` at line 514.
pub fn ruby_load_commands_l514_d24_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `flag?(flag)` at line 567.
pub fn ruby_load_commands_l567_d25_flag(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DylibCommand#flag? requires a flag') }
	return brew_runtime.bool_value(load_command_from_args(args).flag(args[1].as_string()))
}

// Ruby method `serialize(context)` at line 584.
pub fn ruby_load_commands_l584_d26_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DylibCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 595.
pub fn ruby_load_commands_l595_d27_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby alias `alias marker timestamp` at line 611.
pub fn ruby_load_commands_l611_d28_marker(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(load_command_number(load_command_from_args(args), 'timestamp'))
}

// Ruby method `self.new_from_bin(view)` at line 619.
pub fn ruby_load_commands_l619_d29_self_new_from_bin(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('DylibUseCommand.new_from_bin requires a view') }
	return load_command_boundary(new_load_command_from_bin(.load_command, view_from_value(args[0])) or { panic(err) })
}

// Ruby method `flag?(flag)` at line 634.
pub fn ruby_load_commands_l634_d30_flag(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DylibUseCommand#flag? requires a flag') }
	return brew_runtime.bool_value(load_command_from_args(args).flag(args[1].as_string()))
}

// Ruby method `serialize(context)` at line 646.
pub fn ruby_load_commands_l646_d31_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DylibUseCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 657.
pub fn ruby_load_commands_l657_d32_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `serialize(context)` at line 676.
pub fn ruby_load_commands_l676_d33_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DylinkerCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 686.
pub fn ruby_load_commands_l686_d34_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 707.
pub fn ruby_load_commands_l707_d35_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 752.
pub fn ruby_load_commands_l752_d36_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 803.
pub fn ruby_load_commands_l803_d37_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 817.
pub fn ruby_load_commands_l817_d38_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 831.
pub fn ruby_load_commands_l831_d39_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 845.
pub fn ruby_load_commands_l845_d40_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 868.
pub fn ruby_load_commands_l868_d41_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 936.
pub fn ruby_load_commands_l936_d42_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 974.
pub fn ruby_load_commands_l974_d43_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby attr_reader `attr_reader :hints` at line 986.
pub fn ruby_load_commands_l986_d44_hints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(hints_table_from_args(args).hints.map(it.to_h()))
}

// Ruby method `initialize(view, htoffset, nhints)` at line 992.
pub fn ruby_load_commands_l992_d45_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('TwolevelHintsTable#initialize requires view, offset, and count') }
	table := new_twolevel_hints_table(view_from_value(args[0]), int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or { panic(err) })) or { panic(err) }
	state := &TwolevelHintsTable{ hints: table.hints.clone() }
	return hints_table_boundary(state)
}

// Ruby attr_reader `attr_reader :isub_image` at line 1003.
pub fn ruby_load_commands_l1003_d46_isub_image(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(hint_from_args(args).isub_image)
}

// Ruby attr_reader `attr_reader :itoc` at line 1006.
pub fn ruby_load_commands_l1006_d47_itoc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(hint_from_args(args).itoc)
}

// Ruby method `initialize(blob)` at line 1010.
pub fn ruby_load_commands_l1010_d48_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('TwolevelHint#initialize requires a blob') }
	hint := new_twolevel_hint(u32(args[0].as_int() or { panic(err) }))
	state := &TwolevelHint{ isub_image: hint.isub_image, itoc: hint.itoc }
	return hint_boundary(state)
}

// Ruby method `to_h` at line 1016.
pub fn ruby_load_commands_l1016_d49_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return hint_from_args(args).to_h()
}

// Ruby method `to_h` at line 1033.
pub fn ruby_load_commands_l1033_d50_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `serialize(context)` at line 1050.
pub fn ruby_load_commands_l1050_d51_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('RpathCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 1060.
pub fn ruby_load_commands_l1060_d52_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1074.
pub fn ruby_load_commands_l1074_d53_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `serialize(context)` at line 1097.
pub fn ruby_load_commands_l1097_d54_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('LinkeditDataCommand#serialize requires a context') }
	return brew_runtime.string_value(load_command_from_args(args).serialize(*context_from_value(args[1])) or { panic(err) }.bytestr())
}

// Ruby method `superblob` at line 1107.
pub fn ruby_load_commands_l1107_d55_superblob(args ...brew_runtime.Value) brew_runtime.Value {
	blob := load_command_from_args(args).superblob() or { panic(err) }
	return brew_runtime.object_value('MachO::CodeSigning::SuperBlob', blob.data.bytestr())
}

// Ruby method `to_h` at line 1114.
pub fn ruby_load_commands_l1114_d56_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1135.
pub fn ruby_load_commands_l1135_d57_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1151.
pub fn ruby_load_commands_l1151_d58_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `version_string` at line 1170.
pub fn ruby_load_commands_l1170_d59_version_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packed_version_string(u32(load_command_number(load_command_from_args(args), 'version'))))
}

// Ruby method `sdk_string` at line 1181.
pub fn ruby_load_commands_l1181_d60_sdk_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packed_version_string(u32(load_command_number(load_command_from_args(args), 'sdk'))))
}

// Ruby method `to_h` at line 1191.
pub fn ruby_load_commands_l1191_d61_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `minos_string` at line 1219.
pub fn ruby_load_commands_l1219_d62_minos_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packed_version_string(u32(load_command_number(load_command_from_args(args), 'minos'))))
}

// Ruby method `sdk_string` at line 1230.
pub fn ruby_load_commands_l1230_d63_sdk_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packed_version_string(u32(load_command_number(load_command_from_args(args), 'sdk'))))
}

// Ruby method `to_h` at line 1240.
pub fn ruby_load_commands_l1240_d64_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby attr_reader `attr_reader :tools` at line 1255.
pub fn ruby_load_commands_l1255_d65_tools(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(tools_from_args(args).tools.map(it.to_h()))
}

// Ruby method `initialize(view, ntools)` at line 1260.
pub fn ruby_load_commands_l1260_d66_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ToolEntries#initialize requires view and count') }
	entries := new_build_tool_entries(view_from_value(args[0]), int(args[1].as_int() or { panic(err) })) or { panic(err) }
	state := &BuildToolEntries{ tools: entries.tools.clone() }
	return tools_boundary(state)
}

// Ruby attr_reader `attr_reader :tool` at line 1271.
pub fn ruby_load_commands_l1271_d67_tool(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(tool_from_args(args).tool)
}

// Ruby attr_reader `attr_reader :version` at line 1274.
pub fn ruby_load_commands_l1274_d68_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(tool_from_args(args).version)
}

// Ruby method `initialize(tool, version)` at line 1279.
pub fn ruby_load_commands_l1279_d69_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Tool#initialize requires tool and version') }
	tool := BuildTool{ tool: u32(args[0].as_int() or { panic(err) }), version: u32(args[1].as_int() or { panic(err) }) }
	state := &BuildTool{ tool: tool.tool, version: tool.version }
	return tool_boundary(state)
}

// Ruby method `to_h` at line 1285.
pub fn ruby_load_commands_l1285_d70_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return tool_from_args(args).to_h()
}

// Ruby method `to_h` at line 1330.
pub fn ruby_load_commands_l1330_d71_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1353.
pub fn ruby_load_commands_l1353_d72_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1369.
pub fn ruby_load_commands_l1369_d73_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `version_string` at line 1385.
pub fn ruby_load_commands_l1385_d74_version_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(packed_source_version_string(u64(load_command_number(load_command_from_args(args), 'version'))))
}

// Ruby method `to_h` at line 1396.
pub fn ruby_load_commands_l1396_d75_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1414.
pub fn ruby_load_commands_l1414_d76_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1438.
pub fn ruby_load_commands_l1438_d77_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1459.
pub fn ruby_load_commands_l1459_d78_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1481.
pub fn ruby_load_commands_l1481_d79_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `to_h` at line 1507.
pub fn ruby_load_commands_l1507_d80_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return load_command_from_args(args).to_h()
}

// Ruby method `segment` at line 1517.
pub fn ruby_load_commands_l1517_d81_segment(args ...brew_runtime.Value) brew_runtime.Value {
	return if segment := load_command_from_args(args).matching_segment() {
		load_command_boundary(segment)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # Classes and constants for parsing load commands in Mach-O binaries.
// 5:   module LoadCommands
// 6:     # load commands added after OS X 10.1 need to be bitwise ORed with
// 7:     # LC_REQ_DYLD to be recognized by the dynamic linker (dyld)
// 8:     # @api private
// 9:     LC_REQ_DYLD = 0x80000000
// 10:
// 11:     # association of load commands to symbol representations
// 12:     # @api private
// 13:     LOAD_COMMANDS = {
// 14:       0x1 => :LC_SEGMENT,
// 15:       0x2 => :LC_SYMTAB,
// 16:       0x3 => :LC_SYMSEG,
// 17:       0x4 => :LC_THREAD,
// 18:       0x5 => :LC_UNIXTHREAD,
// 19:       0x6 => :LC_LOADFVMLIB,
// 20:       0x7 => :LC_IDFVMLIB,
// 21:       0x8 => :LC_IDENT,
// 22:       0x9 => :LC_FVMFILE,
// 23:       0xa => :LC_PREPAGE,
// 24:       0xb => :LC_DYSYMTAB,
// 25:       0xc => :LC_LOAD_DYLIB,
// 26:       0xd => :LC_ID_DYLIB,
// 27:       0xe => :LC_LOAD_DYLINKER,
// 28:       0xf => :LC_ID_DYLINKER,
// 29:       0x10 => :LC_PREBOUND_DYLIB,
// 30:       0x11 => :LC_ROUTINES,
// 31:       0x12 => :LC_SUB_FRAMEWORK,
// 32:       0x13 => :LC_SUB_UMBRELLA,
// 33:       0x14 => :LC_SUB_CLIENT,
// 34:       0x15 => :LC_SUB_LIBRARY,
// 35:       0x16 => :LC_TWOLEVEL_HINTS,
// 36:       0x17 => :LC_PREBIND_CKSUM,
// 37:       (LC_REQ_DYLD | 0x18) => :LC_LOAD_WEAK_DYLIB,
// 38:       0x19 => :LC_SEGMENT_64,
// 39:       0x1a => :LC_ROUTINES_64,
// 40:       0x1b => :LC_UUID,
// 41:       (LC_REQ_DYLD | 0x1c) => :LC_RPATH,
// 42:       0x1d => :LC_CODE_SIGNATURE,
// 43:       0x1e => :LC_SEGMENT_SPLIT_INFO,
// 44:       (LC_REQ_DYLD | 0x1f) => :LC_REEXPORT_DYLIB,
// 45:       0x20 => :LC_LAZY_LOAD_DYLIB,
// 46:       0x21 => :LC_ENCRYPTION_INFO,
// 47:       0x22 => :LC_DYLD_INFO,
// 48:       (LC_REQ_DYLD | 0x22) => :LC_DYLD_INFO_ONLY,
// 49:       (LC_REQ_DYLD | 0x23) => :LC_LOAD_UPWARD_DYLIB,
// 50:       0x24 => :LC_VERSION_MIN_MACOSX,
// 51:       0x25 => :LC_VERSION_MIN_IPHONEOS,
// 52:       0x26 => :LC_FUNCTION_STARTS,
// 53:       0x27 => :LC_DYLD_ENVIRONMENT,
// 54:       (LC_REQ_DYLD | 0x28) => :LC_MAIN,
// 55:       0x29 => :LC_DATA_IN_CODE,
// 56:       0x2a => :LC_SOURCE_VERSION,
// 57:       0x2b => :LC_DYLIB_CODE_SIGN_DRS,
// 58:       0x2c => :LC_ENCRYPTION_INFO_64,
// 59:       0x2d => :LC_LINKER_OPTION,
// 60:       0x2e => :LC_LINKER_OPTIMIZATION_HINT,
// 61:       0x2f => :LC_VERSION_MIN_TVOS,
// 62:       0x30 => :LC_VERSION_MIN_WATCHOS,
// 63:       0x31 => :LC_NOTE,
// 64:       0x32 => :LC_BUILD_VERSION,
// 65:       (LC_REQ_DYLD | 0x33) => :LC_DYLD_EXPORTS_TRIE,
// 66:       (LC_REQ_DYLD | 0x34) => :LC_DYLD_CHAINED_FIXUPS,
// 67:       (LC_REQ_DYLD | 0x35) => :LC_FILESET_ENTRY,
// 68:       0x36 => :LC_ATOM_INFO,
// 69:       0x37 => :LC_FUNCTION_VARIANTS,
// 70:       0x38 => :LC_FUNCTION_VARIANT_FIXUPS,
// 71:       0x39 => :LC_TARGET_TRIPLE,
// 72:       0x3a => :LC_LAZY_LOAD_DYLIB_INFO,
// 73:     }.freeze
// 74:
// 75:     # association of symbol representations to load command constants
// 76:     # @api private
// 77:     LOAD_COMMAND_CONSTANTS = LOAD_COMMANDS.invert.freeze
// 78:
// 79:     # load commands responsible for loading dylibs
// 80:     # @api private
// 81:     DYLIB_LOAD_COMMANDS = %i[
// 82:       LC_LOAD_DYLIB
// 83:       LC_LOAD_WEAK_DYLIB
// 84:       LC_REEXPORT_DYLIB
// 85:       LC_LAZY_LOAD_DYLIB
// 86:       LC_LOAD_UPWARD_DYLIB
// 87:     ].freeze
// 88:
// 89:     # load commands that can be created manually via {LoadCommand.create}
// 90:     # @api private
// 91:     CREATABLE_LOAD_COMMANDS = DYLIB_LOAD_COMMANDS + %i[
// 92:       LC_ID_DYLIB
// 93:       LC_RPATH
// 94:       LC_LOAD_DYLINKER
// 95:       LC_CODE_SIGNATURE
// 96:     ].freeze
// 97:
// 98:     # association of load command symbols to string representations of classes
// 99:     # @api private
// 100:     LC_STRUCTURES = {
// 101:       :LC_SEGMENT => "SegmentCommand",
// 102:       :LC_SYMTAB => "SymtabCommand",
// 103:       # "obsolete"
// 104:       :LC_SYMSEG => "SymsegCommand",
// 105:       # seems obsolete, but not documented as such
// 106:       :LC_THREAD => "ThreadCommand",
// 107:       :LC_UNIXTHREAD => "ThreadCommand",
// 108:       # "obsolete"
// 109:       :LC_LOADFVMLIB => "FvmlibCommand",
// 110:       # "obsolete"
// 111:       :LC_IDFVMLIB => "FvmlibCommand",
// 112:       # "obsolete"
// 113:       :LC_IDENT => "IdentCommand",
// 114:       # "reserved for internal use only"
// 115:       :LC_FVMFILE => "FvmfileCommand",
// 116:       # "reserved for internal use only", no public struct
// 117:       :LC_PREPAGE => "LoadCommand",
// 118:       :LC_DYSYMTAB => "DysymtabCommand",
// 119:       :LC_LOAD_DYLIB => "DylibUseCommand",
// 120:       :LC_ID_DYLIB => "DylibCommand",
// 121:       :LC_LOAD_DYLINKER => "DylinkerCommand",
// 122:       :LC_ID_DYLINKER => "DylinkerCommand",
// 123:       :LC_PREBOUND_DYLIB => "PreboundDylibCommand",
// 124:       :LC_ROUTINES => "RoutinesCommand",
// 125:       :LC_SUB_FRAMEWORK => "SubFrameworkCommand",
// 126:       :LC_SUB_UMBRELLA => "SubUmbrellaCommand",
// 127:       :LC_SUB_CLIENT => "SubClientCommand",
// 128:       :LC_SUB_LIBRARY => "SubLibraryCommand",
// 129:       :LC_TWOLEVEL_HINTS => "TwolevelHintsCommand",
// 130:       :LC_PREBIND_CKSUM => "PrebindCksumCommand",
// 131:       :LC_LOAD_WEAK_DYLIB => "DylibUseCommand",
// 132:       :LC_SEGMENT_64 => "SegmentCommand64",
// 133:       :LC_ROUTINES_64 => "RoutinesCommand64",
// 134:       :LC_UUID => "UUIDCommand",
// 135:       :LC_RPATH => "RpathCommand",
// 136:       :LC_CODE_SIGNATURE => "LinkeditDataCommand",
// 137:       :LC_SEGMENT_SPLIT_INFO => "LinkeditDataCommand",
// 138:       :LC_REEXPORT_DYLIB => "DylibCommand",
// 139:       :LC_LAZY_LOAD_DYLIB => "DylibCommand",
// 140:       :LC_ENCRYPTION_INFO => "EncryptionInfoCommand",
// 141:       :LC_DYLD_INFO => "DyldInfoCommand",
// 142:       :LC_DYLD_INFO_ONLY => "DyldInfoCommand",
// 143:       :LC_LOAD_UPWARD_DYLIB => "DylibCommand",
// 144:       :LC_VERSION_MIN_MACOSX => "VersionMinCommand",
// 145:       :LC_VERSION_MIN_IPHONEOS => "VersionMinCommand",
// 146:       :LC_FUNCTION_STARTS => "LinkeditDataCommand",
// 147:       :LC_DYLD_ENVIRONMENT => "DylinkerCommand",
// 148:       :LC_MAIN => "EntryPointCommand",
// 149:       :LC_DATA_IN_CODE => "LinkeditDataCommand",
// 150:       :LC_SOURCE_VERSION => "SourceVersionCommand",
// 151:       :LC_DYLIB_CODE_SIGN_DRS => "LinkeditDataCommand",
// 152:       :LC_ENCRYPTION_INFO_64 => "EncryptionInfoCommand64",
// 153:       :LC_LINKER_OPTION => "LinkerOptionCommand",
// 154:       :LC_LINKER_OPTIMIZATION_HINT => "LinkeditDataCommand",
// 155:       :LC_VERSION_MIN_TVOS => "VersionMinCommand",
// 156:       :LC_VERSION_MIN_WATCHOS => "VersionMinCommand",
// 157:       :LC_NOTE => "NoteCommand",
// 158:       :LC_BUILD_VERSION => "BuildVersionCommand",
// 159:       :LC_DYLD_EXPORTS_TRIE => "LinkeditDataCommand",
// 160:       :LC_DYLD_CHAINED_FIXUPS => "LinkeditDataCommand",
// 161:       :LC_FILESET_ENTRY => "FilesetEntryCommand",
// 162:       :LC_ATOM_INFO => "LinkeditDataCommand",
// 163:       :LC_FUNCTION_VARIANTS => "LinkeditDataCommand",
// 164:       :LC_FUNCTION_VARIANT_FIXUPS => "LinkeditDataCommand",
// 165:       :LC_TARGET_TRIPLE => "TargetTripleCommand",
// 166:       :LC_LAZY_LOAD_DYLIB_INFO => "LinkeditDataCommand",
// 167:     }.freeze
// 168:
// 169:     # association of segment name symbols to names
// 170:     # @api private
// 171:     SEGMENT_NAMES = {
// 172:       :SEG_PAGEZERO => "__PAGEZERO",
// 173:       :SEG_TEXT => "__TEXT",
// 174:       :SEG_TEXT_EXEC => "__TEXT_EXEC",
// 175:       :SEG_DATA => "__DATA",
// 176:       :SEG_DATA_CONST => "__DATA_CONST",
// 177:       :SEG_OBJC => "__OBJC",
// 178:       :SEG_OBJC_CONST => "__OBJC_CONST",
// 179:       :SEG_ICON => "__ICON",
// 180:       :SEG_LINKEDIT => "__LINKEDIT",
// 181:       :SEG_LINKINFO => "__LINKINFO",
// 182:       :SEG_UNIXSTACK => "__UNIXSTACK",
// 183:       :SEG_IMPORT => "__IMPORT",
// 184:       :SEG_KLD => "__KLD",
// 185:       :SEG_KLDDATA => "__KLDDATA",
// 186:       :SEG_HIB => "__HIB",
// 187:       :SEG_VECTORS => "__VECTORS",
// 188:       :SEG_LAST => "__LAST",
// 189:       :SEG_LASTDATA_CONST => "__LASTDATA_CONST",
// 190:       :SEG_PRELINK_TEXT => "__PRELINK_TEXT",
// 191:       :SEG_PRELINK_INFO => "__PRELINK_INFO",
// 192:       :SEG_CTF => "__CTF",
// 193:       :SEG_AUTH => "__AUTH",
// 194:       :SEG_AUTH_CONST => "__AUTH_CONST",
// 195:     }.freeze
// 196:
// 197:     # association of segment flag symbols to values
// 198:     # @api private
// 199:     SEGMENT_FLAGS = {
// 200:       :SG_HIGHVM => 0x1,
// 201:       :SG_FVMLIB => 0x2,
// 202:       :SG_NORELOC => 0x4,
// 203:       :SG_PROTECTED_VERSION_1 => 0x8,
// 204:       :SG_READ_ONLY => 0x10,
// 205:     }.freeze
// 206:
// 207:     # association of dylib use flag symbols to values
// 208:     # @api private
// 209:     DYLIB_USE_FLAGS = {
// 210:       :DYLIB_USE_WEAK_LINK => 0x1,
// 211:       :DYLIB_USE_REEXPORT => 0x2,
// 212:       :DYLIB_USE_UPWARD => 0x4,
// 213:       :DYLIB_USE_DELAYED_INIT => 0x8,
// 214:     }.freeze
// 215:
// 216:     # the marker used to denote a newer style dylib use command.
// 217:     # the value is the timestamp 24 January 1984 18:12:16
// 218:     # @api private
// 219:     DYLIB_USE_MARKER = 0x1a741800
// 220:
// 221:     # The top-level Mach-O load command structure.
// 222:     #
// 223:     # This is the most generic load command -- only the type ID and size are
// 224:     # represented. Used when a more specific class isn't available or isn't implemented.
// 225:     class LoadCommand < MachOStructure
// 226:       # @return [MachO::MachOView, nil] the raw view associated with the load command,
// 227:       #  or nil if the load command was created via {create}.
// 228:       field :view, :view
// 229:
// 230:       # @return [Integer] the load command's type ID
// 231:       field :cmd, :uint32
// 232:
// 233:       # @return [Integer] the size of the load command, in bytes
// 234:       field :cmdsize, :uint32
// 235:
// 236:       # Instantiates a new LoadCommand given a view into its origin Mach-O
// 237:       # @param view [MachO::MachOView] the load command's raw view
// 238:       # @return [LoadCommand] the new load command
// 239:       # @api private
// 240:       def self.new_from_bin(view)
// 241:         bin = view.raw_data.slice(view.offset, bytesize)
// 242:         format = Utils.specialize_format(self.format, view.endianness)
// 243:
// 244:         new(view, *bin.unpack(format))
// 245:       end
// 246:
// 247:       # Creates a new (viewless) command corresponding to the symbol provided
// 248:       # @param cmd_sym [Symbol] the symbol of the load command being created
// 249:       # @param args [Array] the arguments for the load command being created
// 250:       def self.create(cmd_sym, *args)
// 251:         raise LoadCommandNotCreatableError, cmd_sym unless CREATABLE_LOAD_COMMANDS.include?(cmd_sym)
// 252:
// 253:         klass = LoadCommands.const_get LC_STRUCTURES[cmd_sym]
// 254:         cmd = LOAD_COMMAND_CONSTANTS[cmd_sym]
// 255:
// 256:         # cmd will be filled in, view and cmdsize will be left unpopulated
// 257:         klass_arity = klass.min_args - 3
// 258:
// 259:         # macOS 15 introduces a new dylib load command that adds a flags field to the end.
// 260:         # It uses the same commands with it dynamically being created if the dylib has a flags field
// 261:         if klass == DylibUseCommand && (args[1] != DYLIB_USE_MARKER || args.size <= DylibCommand.min_args - 3)
// 262:           klass = DylibCommand
// 263:           klass_arity = klass.min_args - 3
// 264:         end
// 265:
// 266:         raise LoadCommandCreationArityError.new(cmd_sym, klass_arity, args.size) if klass_arity > args.size
// 267:
// 268:         klass.new(nil, cmd, nil, *args)
// 269:       end
// 270:
// 271:       # @return [Boolean] whether the load command can be serialized
// 272:       def serializable?
// 273:         CREATABLE_LOAD_COMMANDS.include?(LOAD_COMMANDS[cmd])
// 274:       end
// 275:
// 276:       # @param context [SerializationContext] the context
// 277:       #  to serialize into
// 278:       # @return [String, nil] the serialized fields of the load command, or nil
// 279:       #  if the load command can't be serialized
// 280:       # @api private
// 281:       def serialize(context)
// 282:         raise LoadCommandNotSerializableError, LOAD_COMMANDS[cmd] unless serializable?
// 283:
// 284:         format = Utils.specialize_format(self.class.format, context.endianness)
// 285:         [cmd, self.class.bytesize].pack(format)
// 286:       end
// 287:
// 288:       # @return [Integer] the load command's offset in the source file
// 289:       # @deprecated use {#view} instead
// 290:       def offset
// 291:         view.offset
// 292:       end
// 293:
// 294:       # @return [Symbol, nil] a symbol representation of the load command's
// 295:       #  type ID, or nil if the ID doesn't correspond to a known load command class
// 296:       def type
// 297:         LOAD_COMMANDS[cmd]
// 298:       end
// 299:
// 300:       alias to_sym type
// 301:
// 302:       # @return [String] a string representation of the load command's
// 303:       #  identifying number
// 304:       def to_s
// 305:         type.to_s
// 306:       end
// 307:
// 308:       # @return [Hash] a hash representation of this load command
// 309:       # @note Children should override this to include additional information.
// 310:       def to_h
// 311:         {
// 312:           "view" => view.to_h,
// 313:           "cmd" => cmd,
// 314:           "cmdsize" => cmdsize,
// 315:           "type" => type,
// 316:         }.merge super
// 317:       end
// 318:
// 319:       # Represents a Load Command string. A rough analogue to the lc_str
// 320:       # struct used internally by OS X. This class allows ruby-macho to
// 321:       # pretend that strings stored in LCs are immediately available without
// 322:       # explicit operations on the raw Mach-O data.
// 323:       class LCStr
// 324:         # @param lc [LoadCommand] the load command
// 325:         # @param lc_str [Integer, String] the offset to the beginning of the
// 326:         #  string, or the string itself if not being initialized with a view.
// 327:         # @raise [MachO::LCStrMalformedError] if the string is malformed
// 328:         # @todo devise a solution such that the `lc_str` parameter is not
// 329:         #  interpreted differently depending on `lc.view`. The current behavior
// 330:         #  is a hack to allow viewless load command creation.
// 331:         # @api private
// 332:         def initialize(lc, lc_str)
// 333:           view = lc.view
// 334:
// 335:           if view
// 336:             raise LCStrMalformedError, lc if lc_str < lc.class.bytesize || lc_str >= lc.cmdsize
// 337:
// 338:             lc_str_abs = view.offset + lc_str
// 339:             lc_end = view.offset + lc.cmdsize - 1
// 340:             raw_string = view.raw_data.slice(lc_str_abs..lc_end)
// 341:             @string, null_byte, _padding = raw_string.partition("\x00")
// 342:
// 343:             raise LCStrMalformedError, lc if null_byte.empty?
// 344:
// 345:             @string_offset = lc_str
// 346:           else
// 347:             @string = lc_str
// 348:             @string_offset = 0
// 349:           end
// 350:         end
// 351:
// 352:         # @return [String] a string representation of the LCStr
// 353:         def to_s
// 354:           @string
// 355:         end
// 356:
// 357:         # @return [Integer] the offset to the beginning of the string in the
// 358:         #  load command
// 359:         def to_i
// 360:           @string_offset
// 361:         end
// 362:
// 363:         # @return [Hash] a hash representation of this {LCStr}.
// 364:         def to_h
// 365:           {
// 366:             "string" => to_s,
// 367:             "offset" => to_i,
// 368:           }
// 369:         end
// 370:       end
// 371:
// 372:       # Represents the contextual information needed by a load command to
// 373:       # serialize itself correctly into a binary string.
// 374:       class SerializationContext
// 375:         # @return [Symbol] the endianness of the serialized load command
// 376:         attr_reader :endianness
// 377:
// 378:         # @return [Integer] the constant alignment value used to pad the
// 379:         #  serialized load command
// 380:         attr_reader :alignment
// 381:
// 382:         # @param macho [MachO::MachOFile] the file to contextualize
// 383:         # @return [SerializationContext] the
// 384:         #  resulting context
// 385:         def self.context_for(macho)
// 386:           new(macho.endianness, macho.alignment)
// 387:         end
// 388:
// 389:         # @param endianness [Symbol] the endianness of the context
// 390:         # @param alignment [Integer] the alignment of the context
// 391:         # @api private
// 392:         def initialize(endianness, alignment)
// 393:           @endianness = endianness
// 394:           @alignment = alignment
// 395:         end
// 396:       end
// 397:     end
// 398:
// 399:     # A load command containing a single 128-bit unique random number
// 400:     # identifying an object produced by static link editor. Corresponds to
// 401:     # LC_UUID.
// 402:     class UUIDCommand < LoadCommand
// 403:       # @return [Array<Integer>] the UUID
// 404:       field :uuid, :string, :size => 16, :unpack => "C16"
// 405:
// 406:       # @return [String] a string representation of the UUID
// 407:       def uuid_string
// 408:         hexes = uuid.map { |elem| "%02<elem>x" % { :elem => elem } }
// 409:         segs = [
// 410:           hexes[0..3].join, hexes[4..5].join, hexes[6..7].join,
// 411:           hexes[8..9].join, hexes[10..15].join
// 412:         ]
// 413:
// 414:         segs.join("-")
// 415:       end
// 416:
// 417:       # @return [String] an alias for uuid_string
// 418:       def to_s
// 419:         uuid_string
// 420:       end
// 421:
// 422:       # @return [Hash] returns a hash representation of this {UUIDCommand}
// 423:       def to_h
// 424:         {
// 425:           "uuid" => uuid,
// 426:           "uuid_string" => uuid_string,
// 427:         }.merge super
// 428:       end
// 429:     end
// 430:
// 431:     # A load command indicating that part of this file is to be mapped into
// 432:     # the task's address space. Corresponds to LC_SEGMENT.
// 433:     class SegmentCommand < LoadCommand
// 434:       # @return [String] the name of the segment
// 435:       field :segname, :string, :padding => :null, :size => 16, :to_s => true
// 436:
// 437:       # @return [Integer] the memory address of the segment
// 438:       field :vmaddr, :uint32
// 439:
// 440:       # @return [Integer] the memory size of the segment
// 441:       field :vmsize, :uint32
// 442:
// 443:       # @return [Integer] the file offset of the segment
// 444:       field :fileoff, :uint32
// 445:
// 446:       # @return [Integer] the amount to map from the file
// 447:       field :filesize, :uint32
// 448:
// 449:       # @return [Integer] the maximum VM protection
// 450:       field :maxprot, :int32
// 451:
// 452:       # @return [Integer] the initial VM protection
// 453:       field :initprot, :int32
// 454:
// 455:       # @return [Integer] the number of sections in the segment
// 456:       field :nsects, :uint32
// 457:
// 458:       # @return [Integer] any flags associated with the segment
// 459:       field :flags, :uint32
// 460:
// 461:       # All sections referenced within this segment.
// 462:       # @return [Array<MachO::Sections::Section>] if the Mach-O is 32-bit
// 463:       # @return [Array<MachO::Sections::Section64>] if the Mach-O is 64-bit
// 464:       def sections
// 465:         klass = case self
// 466:         when SegmentCommand64
// 467:           MachO::Sections::Section64
// 468:         when SegmentCommand
// 469:           MachO::Sections::Section
// 470:         end
// 471:
// 472:         offset = view.offset + self.class.bytesize
// 473:         length = nsects * klass.bytesize
// 474:
// 475:         bins = view.raw_data[offset, length]
// 476:         bins.unpack("a#{klass.bytesize}" * nsects).map do |bin|
// 477:           klass.new_from_bin(view.endianness, bin)
// 478:         end
// 479:       end
// 480:
// 481:       # @example
// 482:       #  puts "this segment relocated in/to it" if sect.flag?(:SG_NORELOC)
// 483:       # @param flag [Symbol] a segment flag symbol
// 484:       # @return [Boolean] true if `flag` is present in the segment's flag field
// 485:       def flag?(flag)
// 486:         flag = SEGMENT_FLAGS[flag]
// 487:
// 488:         return false if flag.nil?
// 489:
// 490:         flags & flag == flag
// 491:       end
// 492:
// 493:       # Guesses the alignment of the segment.
// 494:       # @return [Integer] the guessed alignment, as a power of 2
// 495:       # @note See `guess_align` in `cctools/misc/lipo.c`
// 496:       def guess_align
// 497:         return Sections::MAX_SECT_ALIGN if vmaddr.zero?
// 498:
// 499:         align = 0
// 500:         segalign = 1
// 501:
// 502:         while segalign.nobits?(vmaddr)
// 503:           segalign <<= 1
// 504:           align += 1
// 505:         end
// 506:
// 507:         return 2 if align < 2
// 508:         return Sections::MAX_SECT_ALIGN if align > Sections::MAX_SECT_ALIGN
// 509:
// 510:         align
// 511:       end
// 512:
// 513:       # @return [Hash] a hash representation of this {SegmentCommand}
// 514:       def to_h
// 515:         {
// 516:           "segname" => segname,
// 517:           "vmaddr" => vmaddr,
// 518:           "vmsize" => vmsize,
// 519:           "fileoff" => fileoff,
// 520:           "filesize" => filesize,
// 521:           "maxprot" => maxprot,
// 522:           "initprot" => initprot,
// 523:           "nsects" => nsects,
// 524:           "flags" => flags,
// 525:           "sections" => sections.map(&:to_h),
// 526:         }.merge super
// 527:       end
// 528:     end
// 529:
// 530:     # A load command indicating that part of this file is to be mapped into
// 531:     # the task's address space. Corresponds to LC_SEGMENT_64.
// 532:     class SegmentCommand64 < SegmentCommand
// 533:       # @return [Integer] the memory address of the segment
// 534:       field :vmaddr, :uint64
// 535:
// 536:       # @return [Integer] the memory size of the segment
// 537:       field :vmsize, :uint64
// 538:
// 539:       # @return [Integer] the file offset of the segment
// 540:       field :fileoff, :uint64
// 541:
// 542:       # @return [Integer] the amount to map from the file
// 543:       field :filesize, :uint64
// 544:     end
// 545:
// 546:     # A load command representing some aspect of shared libraries, depending
// 547:     # on filetype. Corresponds to LC_ID_DYLIB, LC_LOAD_DYLIB,
// 548:     # LC_LOAD_WEAK_DYLIB, and LC_REEXPORT_DYLIB.
// 549:     class DylibCommand < LoadCommand
// 550:       # @return [LCStr] the library's path
// 551:       #  name as an LCStr
// 552:       field :name, :lcstr, :to_s => true
// 553:
// 554:       # @return [Integer] the library's build time stamp
// 555:       field :timestamp, :uint32
// 556:
// 557:       # @return [Integer] the library's current version number
// 558:       field :current_version, :uint32
// 559:
// 560:       # @return [Integer] the library's compatibility version number
// 561:       field :compatibility_version, :uint32
// 562:
// 563:       # @example
// 564:       #  puts "this dylib is weakly loaded" if dylib_command.flag?(:DYLIB_USE_WEAK_LINK)
// 565:       # @param flag [Symbol] a dylib use command flag symbol
// 566:       # @return [Boolean] true if `flag` applies to this dylib command
// 567:       def flag?(flag)
// 568:         case cmd
// 569:         when LOAD_COMMAND_CONSTANTS[:LC_LOAD_WEAK_DYLIB]
// 570:           flag == :DYLIB_USE_WEAK_LINK
// 571:         when LOAD_COMMAND_CONSTANTS[:LC_REEXPORT_DYLIB]
// 572:           flag == :DYLIB_USE_REEXPORT
// 573:         when LOAD_COMMAND_CONSTANTS[:LC_LOAD_UPWARD_DYLIB]
// 574:           flag == :DYLIB_USE_UPWARD
// 575:         else
// 576:           false
// 577:         end
// 578:       end
// 579:
// 580:       # @param context [SerializationContext]
// 581:       #  the context
// 582:       # @return [String] the serialized fields of the load command
// 583:       # @api private
// 584:       def serialize(context)
// 585:         format = Utils.specialize_format(self.class.format, context.endianness)
// 586:         string_payload, string_offsets = Utils.pack_strings(self.class.bytesize,
// 587:                                                             context.alignment,
// 588:                                                             :name => name.to_s)
// 589:         cmdsize = self.class.bytesize + string_payload.bytesize
// 590:         [cmd, cmdsize, string_offsets[:name], timestamp, current_version,
// 591:          compatibility_version].pack(format) + string_payload
// 592:       end
// 593:
// 594:       # @return [Hash] a hash representation of this {DylibCommand}
// 595:       def to_h
// 596:         {
// 597:           "name" => name.to_h,
// 598:           "timestamp" => timestamp,
// 599:           "current_version" => current_version,
// 600:           "compatibility_version" => compatibility_version,
// 601:         }.merge super
// 602:       end
// 603:     end
// 604:
// 605:     # The newer format of load command representing some aspect of shared libraries,
// 606:     # depending on filetype. Corresponds to LC_LOAD_DYLIB or LC_LOAD_WEAK_DYLIB.
// 607:     class DylibUseCommand < DylibCommand
// 608:       # @return [Integer] any flags associated with this dylib use command
// 609:       field :flags, :uint32
// 610:
// 611:       alias marker timestamp
// 612:
// 613:       # Instantiates a new DylibCommand or DylibUseCommand.
// 614:       # macOS 15 and later use a new format for dylib commands (DylibUseCommand),
// 615:       # which is determined based on a special timestamp and the name offset.
// 616:       # @param view [MachO::MachOView] the load command's raw view
// 617:       # @return [DylibCommand] the new dylib load command
// 618:       # @api private
// 619:       def self.new_from_bin(view)
// 620:         dylib_command = DylibCommand.new_from_bin(view)
// 621:
// 622:         if dylib_command.timestamp == DYLIB_USE_MARKER &&
// 623:            dylib_command.name.to_i == DylibUseCommand.bytesize
// 624:           super
// 625:         else
// 626:           dylib_command
// 627:         end
// 628:       end
// 629:
// 630:       # @example
// 631:       #  puts "this dylib is weakly loaded" if dylib_command.flag?(:DYLIB_USE_WEAK_LINK)
// 632:       # @param flag [Symbol] a dylib use command flag symbol
// 633:       # @return [Boolean] true if `flag` applies to this dylib command
// 634:       def flag?(flag)
// 635:         flag = DYLIB_USE_FLAGS[flag]
// 636:
// 637:         return false if flag.nil?
// 638:
// 639:         flags & flag == flag
// 640:       end
// 641:
// 642:       # @param context [SerializationContext]
// 643:       #  the context
// 644:       # @return [String] the serialized fields of the load command
// 645:       # @api private
// 646:       def serialize(context)
// 647:         format = Utils.specialize_format(self.class.format, context.endianness)
// 648:         string_payload, string_offsets = Utils.pack_strings(self.class.bytesize,
// 649:                                                             context.alignment,
// 650:                                                             :name => name.to_s)
// 651:         cmdsize = self.class.bytesize + string_payload.bytesize
// 652:         [cmd, cmdsize, string_offsets[:name], marker, current_version,
// 653:          compatibility_version, flags].pack(format) + string_payload
// 654:       end
// 655:
// 656:       # @return [Hash] a hash representation of this {DylibUseCommand}
// 657:       def to_h
// 658:         {
// 659:           "flags" => flags,
// 660:         }.merge super
// 661:       end
// 662:     end
// 663:
// 664:     # A load command representing some aspect of the dynamic linker, depending
// 665:     # on filetype. Corresponds to LC_ID_DYLINKER, LC_LOAD_DYLINKER, and
// 666:     # LC_DYLD_ENVIRONMENT.
// 667:     class DylinkerCommand < LoadCommand
// 668:       # @return [LCStr] the dynamic linker's
// 669:       #  path name as an LCStr
// 670:       field :name, :lcstr, :to_s => true
// 671:
// 672:       # @param context [SerializationContext]
// 673:       #  the context
// 674:       # @return [String] the serialized fields of the load command
// 675:       # @api private
// 676:       def serialize(context)
// 677:         format = Utils.specialize_format(self.class.format, context.endianness)
// 678:         string_payload, string_offsets = Utils.pack_strings(self.class.bytesize,
// 679:                                                             context.alignment,
// 680:                                                             :name => name.to_s)
// 681:         cmdsize = self.class.bytesize + string_payload.bytesize
// 682:         [cmd, cmdsize, string_offsets[:name]].pack(format) + string_payload
// 683:       end
// 684:
// 685:       # @return [Hash] a hash representation of this {DylinkerCommand}
// 686:       def to_h
// 687:         {
// 688:           "name" => name.to_h,
// 689:         }.merge super
// 690:       end
// 691:     end
// 692:
// 693:     # A load command used to indicate dynamic libraries used in prebinding.
// 694:     # Corresponds to LC_PREBOUND_DYLIB.
// 695:     class PreboundDylibCommand < LoadCommand
// 696:       # @return [LCStr] the library's path
// 697:       #  name as an LCStr
// 698:       field :name, :lcstr, :to_s => true
// 699:
// 700:       # @return [Integer] the number of modules in the library
// 701:       field :nmodules, :uint32
// 702:
// 703:       # @return [Integer] a bit vector of linked modules
// 704:       field :linked_modules, :uint32
// 705:
// 706:       # @return [Hash] a hash representation of this {PreboundDylibCommand}
// 707:       def to_h
// 708:         {
// 709:           "name" => name.to_h,
// 710:           "nmodules" => nmodules,
// 711:           "linked_modules" => linked_modules,
// 712:         }.merge super
// 713:       end
// 714:     end
// 715:
// 716:     # A load command used to represent threads.
// 717:     # @note cctools-870 and onwards have all fields of thread_command commented
// 718:     # out except the common ones (cmd, cmdsize)
// 719:     class ThreadCommand < LoadCommand
// 720:     end
// 721:
// 722:     # A load command containing the address of the dynamic shared library
// 723:     # initialization routine and an index into the module table for the module
// 724:     # that defines the routine. Corresponds to LC_ROUTINES.
// 725:     class RoutinesCommand < LoadCommand
// 726:       # @return [Integer] the address of the initialization routine
// 727:       field :init_address, :uint32
// 728:
// 729:       # @return [Integer] the index into the module table that the init routine
// 730:       #  is defined in
// 731:       field :init_module, :uint32
// 732:
// 733:       # @return [void]
// 734:       field :reserved1, :uint32
// 735:
// 736:       # @return [void]
// 737:       field :reserved2, :uint32
// 738:
// 739:       # @return [void]
// 740:       field :reserved3, :uint32
// 741:
// 742:       # @return [void]
// 743:       field :reserved4, :uint32
// 744:
// 745:       # @return [void]
// 746:       field :reserved5, :uint32
// 747:
// 748:       # @return [void]
// 749:       field :reserved6, :uint32
// 750:
// 751:       # @return [Hash] a hash representation of this {RoutinesCommand}
// 752:       def to_h
// 753:         {
// 754:           "init_address" => init_address,
// 755:           "init_module" => init_module,
// 756:           "reserved1" => reserved1,
// 757:           "reserved2" => reserved2,
// 758:           "reserved3" => reserved3,
// 759:           "reserved4" => reserved4,
// 760:           "reserved5" => reserved5,
// 761:           "reserved6" => reserved6,
// 762:         }.merge super
// 763:       end
// 764:     end
// 765:
// 766:     # A load command containing the address of the dynamic shared library
// 767:     # initialization routine and an index into the module table for the module
// 768:     # that defines the routine. Corresponds to LC_ROUTINES_64.
// 769:     class RoutinesCommand64 < RoutinesCommand
// 770:       # @return [Integer] the address of the initialization routine
// 771:       field :init_address, :uint64
// 772:
// 773:       # @return [Integer] the index into the module table that the init routine
// 774:       #  is defined in
// 775:       field :init_module, :uint64
// 776:
// 777:       # @return [void]
// 778:       field :reserved1, :uint64
// 779:
// 780:       # @return [void]
// 781:       field :reserved2, :uint64
// 782:
// 783:       # @return [void]
// 784:       field :reserved3, :uint64
// 785:
// 786:       # @return [void]
// 787:       field :reserved4, :uint64
// 788:
// 789:       # @return [void]
// 790:       field :reserved5, :uint64
// 791:
// 792:       # @return [void]
// 793:       field :reserved6, :uint64
// 794:     end
// 795:
// 796:     # A load command signifying membership of a subframework containing the name
// 797:     # of an umbrella framework. Corresponds to LC_SUB_FRAMEWORK.
// 798:     class SubFrameworkCommand < LoadCommand
// 799:       # @return [LCStr] the umbrella framework name as an LCStr
// 800:       field :umbrella, :lcstr, :to_s => true
// 801:
// 802:       # @return [Hash] a hash representation of this {SubFrameworkCommand}
// 803:       def to_h
// 804:         {
// 805:           "umbrella" => umbrella.to_h,
// 806:         }.merge super
// 807:       end
// 808:     end
// 809:
// 810:     # A load command signifying membership of a subumbrella containing the name
// 811:     # of an umbrella framework. Corresponds to LC_SUB_UMBRELLA.
// 812:     class SubUmbrellaCommand < LoadCommand
// 813:       # @return [LCStr] the subumbrella framework name as an LCStr
// 814:       field :sub_umbrella, :lcstr, :to_s => true
// 815:
// 816:       # @return [Hash] a hash representation of this {SubUmbrellaCommand}
// 817:       def to_h
// 818:         {
// 819:           "sub_umbrella" => sub_umbrella.to_h,
// 820:         }.merge super
// 821:       end
// 822:     end
// 823:
// 824:     # A load command signifying a sublibrary of a shared library. Corresponds
// 825:     # to LC_SUB_LIBRARY.
// 826:     class SubLibraryCommand < LoadCommand
// 827:       # @return [LCStr] the sublibrary name as an LCStr
// 828:       field :sub_library, :lcstr, :to_s => true
// 829:
// 830:       # @return [Hash] a hash representation of this {SubLibraryCommand}
// 831:       def to_h
// 832:         {
// 833:           "sub_library" => sub_library.to_h,
// 834:         }.merge super
// 835:       end
// 836:     end
// 837:
// 838:     # A load command signifying a shared library that is a subframework of
// 839:     # an umbrella framework. Corresponds to LC_SUB_CLIENT.
// 840:     class SubClientCommand < LoadCommand
// 841:       # @return [LCStr] the subclient name as an LCStr
// 842:       field :sub_client, :lcstr, :to_s => true
// 843:
// 844:       # @return [Hash] a hash representation of this {SubClientCommand}
// 845:       def to_h
// 846:         {
// 847:           "sub_client" => sub_client.to_h,
// 848:         }.merge super
// 849:       end
// 850:     end
// 851:
// 852:     # A load command containing the offsets and sizes of the link-edit 4.3BSD
// 853:     # "stab" style symbol table information. Corresponds to LC_SYMTAB.
// 854:     class SymtabCommand < LoadCommand
// 855:       # @return [Integer] the symbol table's offset
// 856:       field :symoff, :uint32
// 857:
// 858:       # @return [Integer] the number of symbol table entries
// 859:       field :nsyms, :uint32
// 860:
// 861:       # @return [Integer] the string table's offset
// 862:       field :stroff, :uint32
// 863:
// 864:       # @return [Integer] the string table size in bytes
// 865:       field :strsize, :uint32
// 866:
// 867:       # @return [Hash] a hash representation of this {SymtabCommand}
// 868:       def to_h
// 869:         {
// 870:           "symoff" => symoff,
// 871:           "nsyms" => nsyms,
// 872:           "stroff" => stroff,
// 873:           "strsize" => strsize,
// 874:         }.merge super
// 875:       end
// 876:     end
// 877:
// 878:     # A load command containing symbolic information needed to support data
// 879:     # structures used by the dynamic link editor. Corresponds to LC_DYSYMTAB.
// 880:     class DysymtabCommand < LoadCommand
// 881:       # @return [Integer] the index to local symbols
// 882:       field :ilocalsym, :uint32
// 883:
// 884:       # @return [Integer] the number of local symbols
// 885:       field :nlocalsym, :uint32
// 886:
// 887:       # @return [Integer] the index to externally defined symbols
// 888:       field :iextdefsym, :uint32
// 889:
// 890:       # @return [Integer] the number of externally defined symbols
// 891:       field :nextdefsym, :uint32
// 892:
// 893:       # @return [Integer] the index to undefined symbols
// 894:       field :iundefsym, :uint32
// 895:
// 896:       # @return [Integer] the number of undefined symbols
// 897:       field :nundefsym, :uint32
// 898:
// 899:       # @return [Integer] the file offset to the table of contents
// 900:       field :tocoff, :uint32
// 901:
// 902:       # @return [Integer] the number of entries in the table of contents
// 903:       field :ntoc, :uint32
// 904:
// 905:       # @return [Integer] the file offset to the module table
// 906:       field :modtaboff, :uint32
// 907:
// 908:       # @return [Integer] the number of entries in the module table
// 909:       field :nmodtab, :uint32
// 910:
// 911:       # @return [Integer] the file offset to the referenced symbol table
// 912:       field :extrefsymoff, :uint32
// 913:
// 914:       # @return [Integer] the number of entries in the referenced symbol table
// 915:       field :nextrefsyms, :uint32
// 916:
// 917:       # @return [Integer] the file offset to the indirect symbol table
// 918:       field :indirectsymoff, :uint32
// 919:
// 920:       # @return [Integer] the number of entries in the indirect symbol table
// 921:       field :nindirectsyms, :uint32
// 922:
// 923:       # @return [Integer] the file offset to the external relocation entries
// 924:       field :extreloff, :uint32
// 925:
// 926:       # @return [Integer] the number of external relocation entries
// 927:       field :nextrel, :uint32
// 928:
// 929:       # @return [Integer] the file offset to the local relocation entries
// 930:       field :locreloff, :uint32
// 931:
// 932:       # @return [Integer] the number of local relocation entries
// 933:       field :nlocrel, :uint32
// 934:
// 935:       # @return [Hash] a hash representation of this {DysymtabCommand}
// 936:       def to_h
// 937:         {
// 938:           "ilocalsym" => ilocalsym,
// 939:           "nlocalsym" => nlocalsym,
// 940:           "iextdefsym" => iextdefsym,
// 941:           "nextdefsym" => nextdefsym,
// 942:           "iundefsym" => iundefsym,
// 943:           "nundefsym" => nundefsym,
// 944:           "tocoff" => tocoff,
// 945:           "ntoc" => ntoc,
// 946:           "modtaboff" => modtaboff,
// 947:           "nmodtab" => nmodtab,
// 948:           "extrefsymoff" => extrefsymoff,
// 949:           "nextrefsyms" => nextrefsyms,
// 950:           "indirectsymoff" => indirectsymoff,
// 951:           "nindirectsyms" => nindirectsyms,
// 952:           "extreloff" => extreloff,
// 953:           "nextrel" => nextrel,
// 954:           "locreloff" => locreloff,
// 955:           "nlocrel" => nlocrel,
// 956:         }.merge super
// 957:       end
// 958:     end
// 959:
// 960:     # A load command containing the offset and number of hints in the two-level
// 961:     # namespace lookup hints table. Corresponds to LC_TWOLEVEL_HINTS.
// 962:     class TwolevelHintsCommand < LoadCommand
// 963:       # @return [Integer] the offset to the hint table
// 964:       field :htoffset, :uint32
// 965:
// 966:       # @return [Integer] the number of hints in the hint table
// 967:       field :nhints, :uint32
// 968:
// 969:       # @return [TwolevelHintsTable]
// 970:       #  the hint table
// 971:       field :table, :two_level_hints_table
// 972:
// 973:       # @return [Hash] a hash representation of this {TwolevelHintsCommand}
// 974:       def to_h
// 975:         {
// 976:           "htoffset" => htoffset,
// 977:           "nhints" => nhints,
// 978:           "table" => table.hints.map(&:to_h),
// 979:         }.merge super
// 980:       end
// 981:
// 982:       # A representation of the two-level namespace lookup hints table exposed
// 983:       # by a {TwolevelHintsCommand} (`LC_TWOLEVEL_HINTS`).
// 984:       class TwolevelHintsTable
// 985:         # @return [Array<TwolevelHint>] all hints in the table
// 986:         attr_reader :hints
// 987:
// 988:         # @param view [MachO::MachOView] the view into the current Mach-O
// 989:         # @param htoffset [Integer] the offset of the hints table
// 990:         # @param nhints [Integer] the number of two-level hints in the table
// 991:         # @api private
// 992:         def initialize(view, htoffset, nhints)
// 993:           format = Utils.specialize_format("L=#{nhints}", view.endianness)
// 994:           raw_table = view.raw_data[htoffset, nhints * 4]
// 995:           blobs = raw_table.unpack(format)
// 996:
// 997:           @hints = blobs.map { |b| TwolevelHint.new(b) }
// 998:         end
// 999:
// 1000:         # An individual two-level namespace lookup hint.
// 1001:         class TwolevelHint
// 1002:           # @return [Integer] the index into the sub-images
// 1003:           attr_reader :isub_image
// 1004:
// 1005:           # @return [Integer] the index into the table of contents
// 1006:           attr_reader :itoc
// 1007:
// 1008:           # @param blob [Integer] the 32-bit number containing the lookup hint
// 1009:           # @api private
// 1010:           def initialize(blob)
// 1011:             @isub_image = blob >> 24
// 1012:             @itoc = blob & 0x00FFFFFF
// 1013:           end
// 1014:
// 1015:           # @return [Hash] a hash representation of this {TwolevelHint}
// 1016:           def to_h
// 1017:             {
// 1018:               "isub_image" => isub_image,
// 1019:               "itoc" => itoc,
// 1020:             }
// 1021:           end
// 1022:         end
// 1023:       end
// 1024:     end
// 1025:
// 1026:     # A load command containing the value of the original checksum for prebound
// 1027:     # files, or zero. Corresponds to LC_PREBIND_CKSUM.
// 1028:     class PrebindCksumCommand < LoadCommand
// 1029:       # @return [Integer] the checksum or 0
// 1030:       field :cksum, :uint32
// 1031:
// 1032:       # @return [Hash] a hash representation of this {PrebindCksumCommand}
// 1033:       def to_h
// 1034:         {
// 1035:           "cksum" => cksum,
// 1036:         }.merge super
// 1037:       end
// 1038:     end
// 1039:
// 1040:     # A load command representing an rpath, which specifies a path that should
// 1041:     # be added to the current run path used to find @rpath prefixed dylibs.
// 1042:     # Corresponds to LC_RPATH.
// 1043:     class RpathCommand < LoadCommand
// 1044:       # @return [LCStr] the path to add to the run path as an LCStr
// 1045:       field :path, :lcstr, :to_s => true
// 1046:
// 1047:       # @param context [SerializationContext] the context
// 1048:       # @return [String] the serialized fields of the load command
// 1049:       # @api private
// 1050:       def serialize(context)
// 1051:         format = Utils.specialize_format(self.class.format, context.endianness)
// 1052:         string_payload, string_offsets = Utils.pack_strings(self.class.bytesize,
// 1053:                                                             context.alignment,
// 1054:                                                             :path => path.to_s)
// 1055:         cmdsize = self.class.bytesize + string_payload.bytesize
// 1056:         [cmd, cmdsize, string_offsets[:path]].pack(format) + string_payload
// 1057:       end
// 1058:
// 1059:       # @return [Hash] a hash representation of this {RpathCommand}
// 1060:       def to_h
// 1061:         {
// 1062:           "path" => path.to_h,
// 1063:         }.merge super
// 1064:       end
// 1065:     end
// 1066:
// 1067:     # A load command containing the target triple used when compiling the binary.
// 1068:     # Corresponds to LC_TARGET_TRIPLE.
// 1069:     class TargetTripleCommand < LoadCommand
// 1070:       # @return [LCStr] the target triple used when compiling the binary
// 1071:       field :triple, :lcstr, :to_s => true
// 1072:
// 1073:       # @return [Hash] a hash representation of this {TargetTripleCommand}
// 1074:       def to_h
// 1075:         {
// 1076:           "triple" => triple.to_h,
// 1077:         }.merge super
// 1078:       end
// 1079:     end
// 1080:
// 1081:     # A load command representing the offsets and sizes of a blob of data in
// 1082:     # the __LINKEDIT segment. Corresponds to LC_CODE_SIGNATURE,
// 1083:     # LC_SEGMENT_SPLIT_INFO, LC_FUNCTION_STARTS, LC_DATA_IN_CODE,
// 1084:     # LC_DYLIB_CODE_SIGN_DRS, LC_LINKER_OPTIMIZATION_HINT, LC_DYLD_EXPORTS_TRIE,
// 1085:     # LC_DYLD_CHAINED_FIXUPS, LC_ATOM_INFO, LC_FUNCTION_VARIANTS,
// 1086:     # LC_FUNCTION_VARIANT_FIXUPS, or LC_LAZY_LOAD_DYLIB_INFO.
// 1087:     class LinkeditDataCommand < LoadCommand
// 1088:       # @return [Integer] offset to the data in the __LINKEDIT segment
// 1089:       field :dataoff, :uint32
// 1090:
// 1091:       # @return [Integer] size of the data in the __LINKEDIT segment
// 1092:       field :datasize, :uint32
// 1093:
// 1094:       # @param context [SerializationContext] the context
// 1095:       # @return [String] the serialized fields of the load command
// 1096:       # @api private
// 1097:       def serialize(context)
// 1098:         raise LoadCommandNotSerializableError, type unless serializable?
// 1099:
// 1100:         format = Utils.specialize_format(self.class.format, context.endianness)
// 1101:         [cmd, self.class.bytesize, dataoff, datasize].pack(format)
// 1102:       end
// 1103:
// 1104:       # The embedded signature referenced by this command.
// 1105:       # @return [CodeSigning::SuperBlob]
// 1106:       # @raise [CodeSigningError] if this is not an LC_CODE_SIGNATURE command
// 1107:       def superblob
// 1108:         raise CodeSigningError, "#{type} does not contain a code signature" unless type == :LC_CODE_SIGNATURE
// 1109:
// 1110:         CodeSigning::SuperBlob.new(view.raw_data.byteslice(dataoff, datasize))
// 1111:       end
// 1112:
// 1113:       # @return [Hash] a hash representation of this {LinkeditDataCommand}
// 1114:       def to_h
// 1115:         {
// 1116:           "dataoff" => dataoff,
// 1117:           "datasize" => datasize,
// 1118:         }.merge super
// 1119:       end
// 1120:     end
// 1121:
// 1122:     # A load command representing the offset to and size of an encrypted
// 1123:     # segment. Corresponds to LC_ENCRYPTION_INFO.
// 1124:     class EncryptionInfoCommand < LoadCommand
// 1125:       # @return [Integer] the offset to the encrypted segment
// 1126:       field :cryptoff, :uint32
// 1127:
// 1128:       # @return [Integer] the size of the encrypted segment
// 1129:       field :cryptsize, :uint32
// 1130:
// 1131:       # @return [Integer] the encryption system, or 0 if not encrypted yet
// 1132:       field :cryptid, :uint32
// 1133:
// 1134:       # @return [Hash] a hash representation of this {EncryptionInfoCommand}
// 1135:       def to_h
// 1136:         {
// 1137:           "cryptoff" => cryptoff,
// 1138:           "cryptsize" => cryptsize,
// 1139:           "cryptid" => cryptid,
// 1140:         }.merge super
// 1141:       end
// 1142:     end
// 1143:
// 1144:     # A load command representing the offset to and size of an encrypted
// 1145:     # segment. Corresponds to LC_ENCRYPTION_INFO_64.
// 1146:     class EncryptionInfoCommand64 < EncryptionInfoCommand
// 1147:       # @return [Integer] 64-bit padding value
// 1148:       field :pad, :uint32
// 1149:
// 1150:       # @return [Hash] a hash representation of this {EncryptionInfoCommand64}
// 1151:       def to_h
// 1152:         {
// 1153:           "pad" => pad,
// 1154:         }.merge super
// 1155:       end
// 1156:     end
// 1157:
// 1158:     # A load command containing the minimum OS version on which the binary
// 1159:     # was built to run. Corresponds to LC_VERSION_MIN_MACOSX and
// 1160:     # LC_VERSION_MIN_IPHONEOS.
// 1161:     class VersionMinCommand < LoadCommand
// 1162:       # @return [Integer] the version X.Y.Z packed as x16.y8.z8
// 1163:       field :version, :uint32
// 1164:
// 1165:       # @return [Integer] the SDK version X.Y.Z packed as x16.y8.z8
// 1166:       field :sdk, :uint32
// 1167:
// 1168:       # A string representation of the binary's minimum OS version.
// 1169:       # @return [String] a string representing the minimum OS version.
// 1170:       def version_string
// 1171:         binary = "%032<version>b" % { :version => version }
// 1172:         segs = [
// 1173:           binary[0..15], binary[16..23], binary[24..31]
// 1174:         ].map { |s| s.to_i(2) }
// 1175:
// 1176:         segs.join(".")
// 1177:       end
// 1178:
// 1179:       # A string representation of the binary's SDK version.
// 1180:       # @return [String] a string representing the SDK version.
// 1181:       def sdk_string
// 1182:         binary = "%032<sdk>b" % { :sdk => sdk }
// 1183:         segs = [
// 1184:           binary[0..15], binary[16..23], binary[24..31]
// 1185:         ].map { |s| s.to_i(2) }
// 1186:
// 1187:         segs.join(".")
// 1188:       end
// 1189:
// 1190:       # @return [Hash] a hash representation of this {VersionMinCommand}
// 1191:       def to_h
// 1192:         {
// 1193:           "version" => version,
// 1194:           "version_string" => version_string,
// 1195:           "sdk" => sdk,
// 1196:           "sdk_string" => sdk_string,
// 1197:         }.merge super
// 1198:       end
// 1199:     end
// 1200:
// 1201:     # A load command containing the minimum OS version on which
// 1202:     # the binary was built for its platform.
// 1203:     # Corresponds to LC_BUILD_VERSION.
// 1204:     class BuildVersionCommand < LoadCommand
// 1205:       # @return [Integer]
// 1206:       field :platform, :uint32
// 1207:
// 1208:       # @return [Integer] the minimum OS version X.Y.Z packed as x16.y8.z8
// 1209:       field :minos, :uint32
// 1210:
// 1211:       # @return [Integer] the SDK version X.Y.Z packed as x16.y8.z8
// 1212:       field :sdk, :uint32
// 1213:
// 1214:       # @return [ToolEntries] tool entries
// 1215:       field :tool_entries, :tool_entries
// 1216:
// 1217:       # A string representation of the binary's minimum OS version.
// 1218:       # @return [String] a string representing the minimum OS version.
// 1219:       def minos_string
// 1220:         binary = "%032<minos>b" % { :minos => minos }
// 1221:         segs = [
// 1222:           binary[0..15], binary[16..23], binary[24..31]
// 1223:         ].map { |s| s.to_i(2) }
// 1224:
// 1225:         segs.join(".")
// 1226:       end
// 1227:
// 1228:       # A string representation of the binary's SDK version.
// 1229:       # @return [String] a string representing the SDK version.
// 1230:       def sdk_string
// 1231:         binary = "%032<sdk>b" % { :sdk => sdk }
// 1232:         segs = [
// 1233:           binary[0..15], binary[16..23], binary[24..31]
// 1234:         ].map { |s| s.to_i(2) }
// 1235:
// 1236:         segs.join(".")
// 1237:       end
// 1238:
// 1239:       # @return [Hash] a hash representation of this {BuildVersionCommand}
// 1240:       def to_h
// 1241:         {
// 1242:           "platform" => platform,
// 1243:           "minos" => minos,
// 1244:           "minos_string" => minos_string,
// 1245:           "sdk" => sdk,
// 1246:           "sdk_string" => sdk_string,
// 1247:           "tool_entries" => tool_entries.tools.map(&:to_h),
// 1248:         }.merge super
// 1249:       end
// 1250:
// 1251:       # A representation of the tool versions exposed
// 1252:       # by a {BuildVersionCommand} (`LC_BUILD_VERSION`).
// 1253:       class ToolEntries
// 1254:         # @return [Array<Tool>] all tools
// 1255:         attr_reader :tools
// 1256:
// 1257:         # @param view [MachO::MachOView] the view into the current Mach-O
// 1258:         # @param ntools [Integer] the number of tools
// 1259:         # @api private
// 1260:         def initialize(view, ntools)
// 1261:           format = Utils.specialize_format("L=#{ntools * 2}", view.endianness)
// 1262:           raw_table = view.raw_data[view.offset + 24, ntools * 8]
// 1263:           blobs = raw_table.unpack(format).each_slice(2).to_a
// 1264:
// 1265:           @tools = blobs.map { |b| Tool.new(*b) }
// 1266:         end
// 1267:
// 1268:         # An individual tool.
// 1269:         class Tool
// 1270:           # @return [Integer] the enum for the tool
// 1271:           attr_reader :tool
// 1272:
// 1273:           # @return [Integer] the tool's version number
// 1274:           attr_reader :version
// 1275:
// 1276:           # @param tool [Integer] 32-bit integer
// 1277:           # @param version [Integer] 32-bit integer
// 1278:           # @api private
// 1279:           def initialize(tool, version)
// 1280:             @tool = tool
// 1281:             @version = version
// 1282:           end
// 1283:
// 1284:           # @return [Hash] a hash representation of this {Tool}
// 1285:           def to_h
// 1286:             {
// 1287:               "tool" => tool,
// 1288:               "version" => version,
// 1289:             }
// 1290:           end
// 1291:         end
// 1292:       end
// 1293:     end
// 1294:
// 1295:     # A load command containing the file offsets and sizes of the new
// 1296:     # compressed form of the information dyld needs to load the image.
// 1297:     # Corresponds to LC_DYLD_INFO and LC_DYLD_INFO_ONLY.
// 1298:     class DyldInfoCommand < LoadCommand
// 1299:       # @return [Integer] the file offset to the rebase information
// 1300:       field :rebase_off, :uint32
// 1301:
// 1302:       # @return [Integer] the size of the rebase information
// 1303:       field :rebase_size, :uint32
// 1304:
// 1305:       # @return [Integer] the file offset to the binding information
// 1306:       field :bind_off, :uint32
// 1307:
// 1308:       # @return [Integer] the size of the binding information
// 1309:       field :bind_size, :uint32
// 1310:
// 1311:       # @return [Integer] the file offset to the weak binding information
// 1312:       field :weak_bind_off, :uint32
// 1313:
// 1314:       # @return [Integer] the size of the weak binding information
// 1315:       field :weak_bind_size, :uint32
// 1316:
// 1317:       # @return [Integer] the file offset to the lazy binding information
// 1318:       field :lazy_bind_off, :uint32
// 1319:
// 1320:       # @return [Integer] the size of the lazy binding information
// 1321:       field :lazy_bind_size, :uint32
// 1322:
// 1323:       # @return [Integer] the file offset to the export information
// 1324:       field :export_off, :uint32
// 1325:
// 1326:       # @return [Integer] the size of the export information
// 1327:       field :export_size, :uint32
// 1328:
// 1329:       # @return [Hash] a hash representation of this {DyldInfoCommand}
// 1330:       def to_h
// 1331:         {
// 1332:           "rebase_off" => rebase_off,
// 1333:           "rebase_size" => rebase_size,
// 1334:           "bind_off" => bind_off,
// 1335:           "bind_size" => bind_size,
// 1336:           "weak_bind_off" => weak_bind_off,
// 1337:           "weak_bind_size" => weak_bind_size,
// 1338:           "lazy_bind_off" => lazy_bind_off,
// 1339:           "lazy_bind_size" => lazy_bind_size,
// 1340:           "export_off" => export_off,
// 1341:           "export_size" => export_size,
// 1342:         }.merge super
// 1343:       end
// 1344:     end
// 1345:
// 1346:     # A load command containing linker options embedded in object files.
// 1347:     # Corresponds to LC_LINKER_OPTION.
// 1348:     class LinkerOptionCommand < LoadCommand
// 1349:       # @return [Integer] the number of strings
// 1350:       field :count, :uint32
// 1351:
// 1352:       # @return [Hash] a hash representation of this {LinkerOptionCommand}
// 1353:       def to_h
// 1354:         {
// 1355:           "count" => count,
// 1356:         }.merge super
// 1357:       end
// 1358:     end
// 1359:
// 1360:     # A load command specifying the offset of main(). Corresponds to LC_MAIN.
// 1361:     class EntryPointCommand < LoadCommand
// 1362:       # @return [Integer] the file (__TEXT) offset of main()
// 1363:       field :entryoff, :uint64
// 1364:
// 1365:       # @return [Integer] if not 0, the initial stack size.
// 1366:       field :stacksize, :uint64
// 1367:
// 1368:       # @return [Hash] a hash representation of this {EntryPointCommand}
// 1369:       def to_h
// 1370:         {
// 1371:           "entryoff" => entryoff,
// 1372:           "stacksize" => stacksize,
// 1373:         }.merge super
// 1374:       end
// 1375:     end
// 1376:
// 1377:     # A load command specifying the version of the sources used to build the
// 1378:     # binary. Corresponds to LC_SOURCE_VERSION.
// 1379:     class SourceVersionCommand < LoadCommand
// 1380:       # @return [Integer] the version packed as a24.b10.c10.d10.e10
// 1381:       field :version, :uint64
// 1382:
// 1383:       # A string representation of the sources used to build the binary.
// 1384:       # @return [String] a string representation of the version
// 1385:       def version_string
// 1386:         binary = "%064<version>b" % { :version => version }
// 1387:         segs = [
// 1388:           binary[0..23], binary[24..33], binary[34..43], binary[44..53],
// 1389:           binary[54..63]
// 1390:         ].map { |s| s.to_i(2) }
// 1391:
// 1392:         segs.join(".")
// 1393:       end
// 1394:
// 1395:       # @return [Hash] a hash representation of this {SourceVersionCommand}
// 1396:       def to_h
// 1397:         {
// 1398:           "version" => version,
// 1399:           "version_string" => version_string,
// 1400:         }.merge super
// 1401:       end
// 1402:     end
// 1403:
// 1404:     # An obsolete load command containing the offset and size of the (GNU style)
// 1405:     # symbol table information. Corresponds to LC_SYMSEG.
// 1406:     class SymsegCommand < LoadCommand
// 1407:       # @return [Integer] the offset to the symbol segment
// 1408:       field :offset, :uint32
// 1409:
// 1410:       # @return [Integer] the size of the symbol segment in bytes
// 1411:       field :size, :uint32
// 1412:
// 1413:       # @return [Hash] a hash representation of this {SymsegCommand}
// 1414:       def to_h
// 1415:         {
// 1416:           "offset" => offset,
// 1417:           "size" => size,
// 1418:         }.merge super
// 1419:       end
// 1420:     end
// 1421:
// 1422:     # An obsolete load command containing a free format string table. Each
// 1423:     # string is null-terminated and the command is zero-padded to a multiple of
// 1424:     # 4. Corresponds to LC_IDENT.
// 1425:     class IdentCommand < LoadCommand
// 1426:     end
// 1427:
// 1428:     # An obsolete load command containing the path to a file to be loaded into
// 1429:     # memory. Corresponds to LC_FVMFILE.
// 1430:     class FvmfileCommand < LoadCommand
// 1431:       # @return [LCStr] the pathname of the file being loaded
// 1432:       field :name, :lcstr, :to_s => true
// 1433:
// 1434:       # @return [Integer] the virtual address being loaded at
// 1435:       field :header_addr, :uint32
// 1436:
// 1437:       # @return [Hash] a hash representation of this {FvmfileCommand}
// 1438:       def to_h
// 1439:         {
// 1440:           "name" => name.to_h,
// 1441:           "header_addr" => header_addr,
// 1442:         }.merge super
// 1443:       end
// 1444:     end
// 1445:
// 1446:     # An obsolete load command containing the path to a library to be loaded
// 1447:     # into memory. Corresponds to LC_LOADFVMLIB and LC_IDFVMLIB.
// 1448:     class FvmlibCommand < LoadCommand
// 1449:       # @return [LCStr] the library's target pathname
// 1450:       field :name, :lcstr, :to_s => true
// 1451:
// 1452:       # @return [Integer] the library's minor version number
// 1453:       field :minor_version, :uint32
// 1454:
// 1455:       # @return [Integer] the library's header address
// 1456:       field :header_addr, :uint32
// 1457:
// 1458:       # @return [Hash] a hash representation of this {FvmlibCommand}
// 1459:       def to_h
// 1460:         {
// 1461:           "name" => name.to_h,
// 1462:           "minor_version" => minor_version,
// 1463:           "header_addr" => header_addr,
// 1464:         }.merge super
// 1465:       end
// 1466:     end
// 1467:
// 1468:     # A load command containing an owner name and offset/size for an arbitrary data region.
// 1469:     # Corresponds to LC_NOTE.
// 1470:     class NoteCommand < LoadCommand
// 1471:       # @return [String] the name of the owner for this note
// 1472:       field :data_owner, :string, :padding => :null, :size => 16, :to_s => true
// 1473:
// 1474:       # @return [Integer] the offset, within the file, of the note
// 1475:       field :offset, :uint64
// 1476:
// 1477:       # @return [Integer] the size, in bytes, of the note
// 1478:       field :size, :uint64
// 1479:
// 1480:       # @return [Hash] a hash representation of this {NoteCommand}
// 1481:       def to_h
// 1482:         {
// 1483:           "data_owner" => data_owner,
// 1484:           "offset" => offset,
// 1485:           "size" => size,
// 1486:         }.merge super
// 1487:       end
// 1488:     end
// 1489:
// 1490:     # A load command containing a description of a Mach-O that is a constituent of a fileset.
// 1491:     # Each entry is further described by its own Mach header.
// 1492:     # Corresponds to LC_FILESET_ENTRY.
// 1493:     class FilesetEntryCommand < LoadCommand
// 1494:       # @return [Integer] the virtual memory address of the entry
// 1495:       field :vmaddr, :uint64
// 1496:
// 1497:       # @return [Integer] the file offset of the entry
// 1498:       field :fileoff, :uint64
// 1499:
// 1500:       # @return [LCStr] the entry's ID
// 1501:       field :entry_id, :lcstr, :to_s => true
// 1502:
// 1503:       # @return [void]
// 1504:       field :reserved, :uint32
// 1505:
// 1506:       # @return [Hash] a hash representation of this {FilesetEntryCommand}
// 1507:       def to_h
// 1508:         {
// 1509:           "vmaddr" => vmaddr,
// 1510:           "fileoff" => fileoff,
// 1511:           "entry_id" => entry_id,
// 1512:           "reserved" => reserved,
// 1513:         }.merge super
// 1514:       end
// 1515:
// 1516:       # @return [SegmentCommand64, nil] the matching segment command or nil if nothing matches
// 1517:       def segment
// 1518:         view.macho_file.command(:LC_SEGMENT_64).select { |cmd| cmd.fileoff == fileoff }.first
// 1519:       end
// 1520:     end
// 1521:   end
// 1522: end
