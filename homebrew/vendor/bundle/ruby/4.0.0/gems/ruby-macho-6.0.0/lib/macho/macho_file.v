module macho

import ruby
import encoding.binary
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/macho_file.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MachoFileOptions {
pub:
	permissive bool
	decompress bool
}

pub struct DeleteRpathOptions {
pub:
	uniq bool
	last bool
}

@[heap]
pub struct MachoFile {
pub mut:
	filename         string
	has_filename     bool
	options          MachoFileOptions
	endianness       string
	header           &MachoHeaderRecord = unsafe { nil }
	load_commands    []&LoadCommandRecord
	raw_data         []u8
	prelinked_header &MachoHeaderRecord = unsafe { nil }
mut:
	load_commands_by_type map[string][]&LoadCommandRecord
}

fn macho_file_options_from_value(value ruby.Value) MachoFileOptions {
	values := value.as_map() or { return MachoFileOptions{} }
	return MachoFileOptions{
		permissive: (values['permissive'] or { ruby.bool_value(false) }).as_bool() or { false }
		decompress: (values['decompress'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
}

fn macho_file_options_value(options MachoFileOptions) ruby.Value {
	return ruby.map_value({
		'permissive': ruby.bool_value(options.permissive)
		'decompress': ruby.bool_value(options.decompress)
	})
}

fn nil_macho_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn macho_file_boundary(file &MachoFile) ruby.Value {
	return ruby.structured_value('MachO::MachOFile', '#<MachO::MachOFile>', {
		'macho_file_address': u64(voidptr(file)).str()
	})
}

fn macho_file_from_args(args []ruby.Value) &MachoFile {
	if args.len == 0 {
		panic('MachOFile method requires a receiver')
	}
	address := (args[0].attribute('macho_file_address') or {
		panic('${args[0].type_name} has no translated MachOFile state')
	}).u64()
	return unsafe { &MachoFile(voidptr(address)) }
}

fn macho_file_u32(data []u8, offset int, endianness string) !u32 {
	if offset < 0 || offset + 4 > data.len {
		return error('File is too short to contain a 32-bit Mach-O field')
	}
	return if endianness == 'big' {
		binary.big_endian_u32_at(data, offset)
	} else {
		binary.little_endian_u32_at(data, offset)
	}
}

fn macho_file_put_u32(mut data []u8, offset int, value u32, endianness string) ! {
	if offset < 0 || offset + 4 > data.len {
		return error('Mach-O field offset is outside serialized data')
	}
	if endianness == 'big' {
		binary.big_endian_put_u32_at(mut data, value, offset)
	} else {
		binary.little_endian_put_u32_at(mut data, value, offset)
	}
}

fn macho_header_size(header &MachoHeaderRecord) int {
	return if header.kind == .mach_header64 { 32 } else { 28 }
}

pub fn new_macho_file_from_bin(data []u8, options MachoFileOptions) !&MachoFile {
	mut file := &MachoFile{
		options: options
		raw_data: data.clone()
		load_commands_by_type: map[string][]&LoadCommandRecord{}
	}
	file.populate_fields()!
	return file
}

pub fn new_macho_file(filename string, options MachoFileOptions) !&MachoFile {
	if !os.is_file(filename) {
		return error('${filename}: no such file')
	}
	data := os.read_bytes(filename)!
	mut file := new_macho_file_from_bin(data, options)!
	file.filename = filename
	file.has_filename = true
	return file
}

pub fn (file &MachoFile) serialize() []u8 {
	return file.raw_data.clone()
}

pub fn (file &MachoFile) magic_string() string {
	return header_magic_symbol(file.header.magic)
}

pub fn (file &MachoFile) filetype_symbol() string {
	return header_filetype_symbol(file.header.filetype)
}

pub fn (file &MachoFile) cputype_symbol() string {
	return header_cpu_type_symbol(file.header.cputype)
}

pub fn (file &MachoFile) cpusubtype_symbol() string {
	return header_cpu_subtype_symbol(file.header.cputype, file.header.cpusubtype)
}

pub fn (file &MachoFile) command(name string) []&LoadCommandRecord {
	return (file.load_commands_by_type[name.trim_string_left(':')] or { []&LoadCommandRecord{} }).clone()
}

pub fn (mut file MachoFile) clear_memoization_cache() {
	file.load_commands_by_type = map[string][]&LoadCommandRecord{}
}

pub fn (mut file MachoFile) populate_and_check_magic() !u32 {
	if file.raw_data.len < 4 {
		return error('File is too short to contain a valid Mach-O header')
	}
	magic := binary.big_endian_u32(file.raw_data[..4])
	if !macho_magic(magic) {
		return error('Unrecognized Mach-O magic: 0x${magic:08x}')
	}
	if macho_fat_magic(magic) {
		return error('Fat binaries must be loaded with MachO::FatFile')
	}
	file.endianness = if macho_little_magic(magic) { 'little' } else { 'big' }
	return magic
}

pub fn (file &MachoFile) check_cputype(cputype u32) ! {
	if header_cpu_type_symbol(cputype) == '' {
		return error('Unknown CPU type: 0x${cputype:08x}')
	}
}

pub fn (file &MachoFile) check_cpusubtype(cputype u32, cpusubtype u32) ! {
	if header_cpu_subtype_symbol(cputype, cpusubtype & ~cpu_subtype_mask) == '' {
		return error('Unknown CPU subtype: 0x${cpusubtype:08x} for CPU type 0x${cputype:08x}')
	}
}

pub fn (file &MachoFile) check_filetype(filetype u32) ! {
	if header_filetype_symbol(filetype) == '' {
		return error('Unknown Mach-O file type: 0x${filetype:08x}')
	}
}

pub fn (mut file MachoFile) populate_prelinked_kernel_header() ! {
	if !file.options.decompress {
		return error('Compressed Mach-O cannot be loaded without decompression')
	}
	if file.raw_data.len < 384 {
		return error('File is too short to contain a prelinked kernel header')
	}
	data := file.raw_data
	file.prelinked_header = new_prelinked_kernel_header(
		binary.big_endian_u32_at(data, 0),
		binary.big_endian_u32_at(data, 4),
		binary.big_endian_u32_at(data, 8),
		binary.big_endian_u32_at(data, 12),
		binary.big_endian_u32_at(data, 16),
		binary.big_endian_u32_at(data, 20),
		data[24..64].bytestr(),
		data[64..128].bytestr().all_before('\0'),
		data[128..384].bytestr().all_before('\0'),
	)
	if file.prelinked_header.compress_type == comp_type_lzss {
		return error('unsupported compression type: LZSS')
	}
	if file.prelinked_header.compress_type != comp_type_fastlib {
		return error('unknown compression type: 0x${file.prelinked_header.compress_type:x}')
	}
	file.decompress_macho_lzvn()!
}

pub fn (mut file MachoFile) decompress_macho_lzvn() ! {
	return error('LZVN required but a translated lzfse decoder is not installed')
}

pub fn (mut file MachoFile) populate_mach_header() !&MachoHeaderRecord {
	if file.raw_data.len < 28 {
		return error('File is too short to contain a valid Mach-O header')
	}
	first_magic := binary.big_endian_u32(file.raw_data[..4])
	if macho_compressed_magic(first_magic) {
		file.populate_prelinked_kernel_header()!
	}
	magic := file.populate_and_check_magic()!
	endianness := file.endianness
	cputype := macho_file_u32(file.raw_data, 4, endianness)!
	cpusubtype := macho_file_u32(file.raw_data, 8, endianness)! & ~cpu_subtype_mask
	filetype := macho_file_u32(file.raw_data, 12, endianness)!
	ncmds := macho_file_u32(file.raw_data, 16, endianness)!
	sizeofcmds := macho_file_u32(file.raw_data, 20, endianness)!
	flags := macho_file_u32(file.raw_data, 24, endianness)!
	file.check_cputype(cputype)!
	file.check_cpusubtype(cputype, cpusubtype)!
	file.check_filetype(filetype)!
	if macho_magic32(magic) {
		return new_mach_header(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags)
	}
	if file.raw_data.len < 32 {
		return error('File is too short to contain a valid 64-bit Mach-O header')
	}
	return new_mach_header64(magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, macho_file_u32(file.raw_data, 28, endianness)!)
}

pub fn (mut file MachoFile) populate_load_commands() ![]&LoadCommandRecord {
	header_size := macho_header_size(file.header)
	commands_end := header_size + int(file.header.sizeofcmds)
	if commands_end > file.raw_data.len {
		return error('Declared Mach-O load command region is truncated')
	}
	mut offset := header_size
	mut commands := []&LoadCommandRecord{cap: int(file.header.ncmds)}
	file.load_commands_by_type = map[string][]&LoadCommandRecord{}
	for _ in 0 .. int(file.header.ncmds) {
		if offset + 8 > commands_end {
			return error('Declared Mach-O load commands are truncated')
		}
		cmd := macho_file_u32(file.raw_data, offset, file.endianness)!
		cmdsize := macho_file_u32(file.raw_data, offset + 4, file.endianness)!
		if cmdsize % 4 != 0 || cmdsize < 8 || offset + int(cmdsize) > commands_end {
			return error('Invalid Mach-O load command size: ${cmdsize}')
		}
		if load_command_name(cmd) == none && !file.options.permissive {
			return error('Unrecognized Mach-O load command: 0x${cmd:08x}')
		}
		view := new_load_command_view(file.raw_data, offset, file.endianness, file.header.alignment())
		command := new_load_command_from_bin(.load_command, view)!
		if int(cmdsize) < load_command_bytesize(command.kind) {
			return error('Invalid Mach-O load command size: ${cmdsize}')
		}
		commands << command
		name := command.type_symbol() or { '' }
		mut same_type := file.load_commands_by_type[name] or { []&LoadCommandRecord{} }
		same_type << command
		file.load_commands_by_type[name] = same_type
		offset += int(cmdsize)
	}
	segments := commands.filter(it.kind in [.segment, .segment64])
	for mut command in commands {
		command.file_segments = segments.clone()
	}
	return commands
}

pub fn (mut file MachoFile) populate_fields() ! {
	file.clear_memoization_cache()
	file.header = file.populate_mach_header()!
	file.load_commands = file.populate_load_commands()!
}

pub fn (file &MachoFile) dylib_load_commands() []&LoadCommandRecord {
	return file.load_commands.filter(is_dylib_load_command(it.type_symbol() or { '' })).clone()
}

pub fn (file &MachoFile) segments() []&LoadCommandRecord {
	return file.command(if file.header.magic32() { 'LC_SEGMENT' } else { 'LC_SEGMENT_64' })
}

pub fn (file &MachoFile) calculate_segment_alignment() int {
	cpu := file.cputype_symbol()
	if cpu in ['i386', 'x86_64', 'ppc', 'ppc64'] {
		return 12
	}
	if cpu in ['arm', 'arm64'] {
		return 14
	}
	mut current := max_sect_align
	for segment in file.segments() {
		mut alignment := segment.guess_align()
		if file.filetype_symbol() == 'object' {
			alignment = if file.header.magic32() { 2 } else { 3 }
			for section in segment.sections {
				if int(section.align) > alignment {
					alignment = int(section.align)
				}
			}
		}
		if alignment < current {
			current = alignment
		}
	}
	return current
}

pub fn (file &MachoFile) low_fileoff() int {
	mut offset := file.raw_data.len
	for segment in file.segments() {
		fileoff := int(segment.numbers['fileoff'] or { 0 })
		filesize := int(segment.numbers['filesize'] or { 0 })
		nsects := int(segment.numbers['nsects'] or { 0 })
		if nsects == 0 && fileoff > 0 && filesize > 0 && fileoff < offset {
			offset = fileoff
		}
		for section in segment.sections {
			section_type := section.flags & 0xff
			if section.size == 0 || section_type in [u32(1), 12] {
				continue
			}
			if int(section.offset) < offset {
				offset = int(section.offset)
			}
		}
	}
	return offset
}

pub fn (mut file MachoFile) update_ncmds(value u32) ! {
	macho_file_put_u32(mut file.raw_data, 16, value, file.endianness)!
}

pub fn (mut file MachoFile) update_sizeofcmds(value u32) ! {
	macho_file_put_u32(mut file.raw_data, 20, value, file.endianness)!
}

pub fn (mut file MachoFile) insert_command(offset int, command &LoadCommandRecord, repopulate bool) ! {
	context := new_serialization_context(file.endianness, file.header.alignment())
	command_raw := command.serialize(context)!
	new_size := file.header.sizeofcmds + u32(command_raw.len)
	if offset < macho_header_size(file.header) || offset + command_raw.len > file.low_fileoff() {
		return error('Load command offset ${offset} is outside the load command region')
	}
	if macho_header_size(file.header) + int(new_size) > file.low_fileoff() {
		return error('${file.filename}: not enough header padding for the load command')
	}
	file.update_ncmds(file.header.ncmds + 1)!
	file.update_sizeofcmds(new_size)!
	mut expanded := []u8{cap: file.raw_data.len + command_raw.len}
	expanded << file.raw_data[..offset]
	expanded << command_raw
	expanded << file.raw_data[offset..]
	file.raw_data = expanded[..file.raw_data.len].clone()
	if repopulate {
		file.populate_fields()!
	}
}

pub fn (mut file MachoFile) delete_command(command &LoadCommandRecord, repopulate bool) ! {
	offset := command.source_offset()!
	size := int(command.cmdsize)
	if offset < 0 || offset + size > file.raw_data.len {
		return error('Load command range is outside serialized Mach-O')
	}
	new_size := file.header.sizeofcmds - command.cmdsize
	mut reduced := []u8{cap: file.raw_data.len}
	reduced << file.raw_data[..offset]
	reduced << file.raw_data[offset + size..]
	pad_offset := macho_header_size(file.header) + int(new_size)
	mut padded := []u8{cap: file.raw_data.len}
	padded << reduced[..pad_offset]
	padded << []u8{len: size}
	padded << reduced[pad_offset..]
	file.raw_data = padded[..file.raw_data.len].clone()
	file.update_ncmds(file.header.ncmds - 1)!
	file.update_sizeofcmds(new_size)!
	if repopulate {
		file.populate_fields()!
	}
}

pub fn (mut file MachoFile) replace_command(old_command &LoadCommandRecord, new_command &LoadCommandRecord) ! {
	context := new_serialization_context(file.endianness, file.header.alignment())
	new_raw := new_command.serialize(context)!
	new_size := int(file.header.sizeofcmds) + new_raw.len - int(old_command.cmdsize)
	if macho_header_size(file.header) + new_size > file.low_fileoff() {
		return error('${file.filename}: not enough header padding for the load command')
	}
	offset := old_command.source_offset()!
	file.delete_command(old_command, true)!
	file.insert_command(offset, new_command, true)!
}

pub fn (mut file MachoFile) add_command(command &LoadCommandRecord, repopulate bool) ! {
	file.insert_command(macho_header_size(file.header) + int(file.header.sizeofcmds), command, repopulate)!
}

pub fn (file &MachoFile) dylib_id() ?string {
	if file.header.filetype != mh_dylib {
		return none
	}
	commands := file.command('LC_ID_DYLIB')
	if commands.len == 0 {
		return none
	}
	return (commands[0].strings['name'] or { LoadCommandLCStr{} }).value
}

pub fn (mut file MachoFile) change_dylib_id(new_id string) ! {
	if file.header.filetype != mh_dylib {
		return
	}
	commands := file.command('LC_ID_DYLIB')
	if commands.len == 0 {
		return error('Mach-O dylib is missing LC_ID_DYLIB')
	}
	old := commands[0]
	new_command := create_load_command('LC_ID_DYLIB', [
		ruby.string_value(new_id),
		ruby.int_value(old.numbers['timestamp'] or { 0 }),
		ruby.int_value(old.numbers['current_version'] or { 0 }),
		ruby.int_value(old.numbers['compatibility_version'] or { 0 }),
	])!
	file.replace_command(old, new_command)!
}

pub fn (file &MachoFile) linked_dylibs() []string {
	mut result := []string{}
	for command in file.dylib_load_commands() {
		name := (command.strings['name'] or { LoadCommandLCStr{} }).value
		if name !in result {
			result << name
		}
	}
	return result
}

pub fn (mut file MachoFile) change_install_name(old_name string, new_name string) ! {
	for old in file.dylib_load_commands() {
		if (old.strings['name'] or { LoadCommandLCStr{} }).value == old_name {
			new_command := create_load_command(old.type_symbol() or { '' }, [
				ruby.string_value(new_name),
				ruby.int_value(old.numbers['timestamp'] or { 0 }),
				ruby.int_value(old.numbers['current_version'] or { 0 }),
				ruby.int_value(old.numbers['compatibility_version'] or { 0 }),
				ruby.int_value(old.numbers['flags'] or { 0 }),
			])!
			file.replace_command(old, new_command)!
			return
		}
	}
	return error('Unknown linked dylib: ${old_name}')
}

pub fn (file &MachoFile) rpaths() []string {
	return file.command('LC_RPATH').map((it.strings['path'] or { LoadCommandLCStr{} }).value)
}

pub fn (mut file MachoFile) delete_rpath(path string, options DeleteRpathOptions) ! {
	if options.uniq && options.last {
		return error('Cannot set both :uniq and :last to true')
	}
	mut matches := file.command('LC_RPATH').filter((it.strings['path'] or { LoadCommandLCStr{} }).value == path)
	if matches.len == 0 {
		return error('Unknown rpath: ${path}')
	}
	if !options.uniq {
		matches = if options.last { [matches.last()] } else { [matches[0]] }
	}
	for index := matches.len - 1; index >= 0; index-- {
		file.delete_command(matches[index], true)!
	}
}

pub fn (mut file MachoFile) change_rpath(old_path string, new_path string, options DeleteRpathOptions) ! {
	commands := file.command('LC_RPATH').filter((it.strings['path'] or { LoadCommandLCStr{} }).value == old_path)
	if commands.len == 0 {
		return error('Unknown rpath: ${old_path}')
	}
	offset := commands[0].source_offset()!
	new_command := create_load_command('LC_RPATH', [
		ruby.string_value(new_path),
	])!
	file.delete_rpath(old_path, options)!
	file.insert_command(offset, new_command, true)!
}

pub fn (mut file MachoFile) add_rpath(path string) ! {
	if path in file.rpaths() {
		return error('Rpath already exists: ${path}')
	}
	file.add_command(create_load_command('LC_RPATH', [ruby.string_value(path)])!, true)!
}

fn macho_file_code_signing_adapter(file &MachoFile) &CodeSigningMachO {
	mut commands := []CodeSigningCommand{}
	mut segments := []CodeSigningSegment{}
	for command in file.load_commands {
		kind := command.type_symbol() or { '' }
		commands << CodeSigningCommand{
			kind: kind
			view_offset: command.view_offset
			version: u32(command.numbers['version'] or { 0 })
			minos: u32(command.numbers['minos'] or { 0 })
			platform: u32(command.numbers['platform'] or { 0 })
			uuid: command.uuid.clone()
			dataoff: u32(command.numbers['dataoff'] or { 0 })
			datasize: u32(command.numbers['datasize'] or { 0 })
		}
		if command.kind in [.segment, .segment64] {
			segments << CodeSigningSegment{
				segname: (command.strings['segname'] or { LoadCommandLCStr{} }).value
				fileoff: u64(command.numbers['fileoff'] or { 0 })
				view_offset: command.view_offset
				sections: command.sections.map(CodeSigningSection{
					segname: it.segname
					sectname: it.sectname
					offset: it.offset
					size: it.size
				})
				filesize: u64(command.numbers['filesize'] or { 0 })
				vmsize: u64(command.numbers['vmsize'] or { 0 })
			}
		}
	}
	return &CodeSigningMachO{
		filename: file.filename
		header_size: macho_header_size(file.header)
		endianness: file.endianness
		segment_alignment: file.calculate_segment_alignment()
		executable: file.header.filetype == mh_execute
		magic64: file.header.magic64()
		data: file.raw_data.clone()
		commands: commands
		segments: segments
		ncmds: file.header.ncmds
		sizeofcmds: file.header.sizeofcmds
	}
}

pub fn (mut file MachoFile) codesign(identifier string) ! {
	adapter := macho_file_code_signing_adapter(file)
	actual_identifier := if identifier == '' {
		code_signing_identifier(adapter, file.filename)
	} else {
		identifier
	}
	mut signer := new_adhoc_signer(adapter, actual_identifier)
	signer.sign()!
	file.raw_data = adapter.data.clone()
	file.populate_fields()!
}

pub fn (file &MachoFile) write(filename string) ! {
	os.write_file_array(filename, file.raw_data)!
}

pub fn (file &MachoFile) write_initial() ! {
	if !file.has_filename {
		return error('no initial file to write to')
	}
	file.write(file.filename)!
}

pub fn (file &MachoFile) to_h() ruby.Value {
	return ruby.map_value({
		'header':        file.header.to_h()
		'load_commands': ruby.array_value(file.load_commands.map(it.to_h()))
	})
}

fn delete_rpath_options_from_value(value ruby.Value) DeleteRpathOptions {
	values := value.as_map() or { return DeleteRpathOptions{} }
	return DeleteRpathOptions{
		uniq: (values['uniq'] or { ruby.bool_value(false) }).as_bool() or { false }
		last: (values['last'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
}

// Ruby attr_accessor `attr_accessor :filename` at line 16.
pub fn ruby_macho_file_l16_d1_filename(args ...ruby.Value) ruby.Value {
	file := macho_file_from_args(args)
	return if file.has_filename {
		ruby.string_value(file.filename)
	} else {
		nil_macho_value()
	}
}

// Ruby attr_accessor `attr_accessor :filename` at line 16.
pub fn ruby_macho_file_l16_d2_filename(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	if args.len < 2 { panic('filename= requires a filename') }
	file.filename = args[1].as_string()
	file.has_filename = args[1].type_name != 'NilClass'
	return args[1]
}

// Ruby attr_reader `attr_reader :options` at line 19.
pub fn ruby_macho_file_l19_d3_options(args ...ruby.Value) ruby.Value {
	return macho_file_options_value(macho_file_from_args(args).options)
}

// Ruby attr_reader `attr_reader :endianness` at line 22.
pub fn ruby_macho_file_l22_d4_endianness(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${macho_file_from_args(args).endianness}')
}

// Ruby attr_reader `attr_reader :header` at line 26.
pub fn ruby_macho_file_l26_d5_header(args ...ruby.Value) ruby.Value {
	return macho_header_boundary(macho_file_from_args(args).header)
}

// Ruby attr_reader `attr_reader :load_commands` at line 31.
pub fn ruby_macho_file_l31_d6_load_commands(args ...ruby.Value) ruby.Value {
	return ruby.array_value(macho_file_from_args(args).load_commands.map(load_command_boundary(it)))
}

// Ruby method `self.new_from_bin(bin, **opts)` at line 42.
pub fn ruby_macho_file_l42_d7_self_new_from_bin(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('new_from_bin requires binary data') }
	options := if args.len > 1 {
		macho_file_options_from_value(args[1])
	} else {
		MachoFileOptions{}
	}
	return macho_file_boundary(new_macho_file_from_bin(args[0].as_string().bytes(), options) or { panic(err) })
}

// Ruby method `initialize(filename, **opts)` at line 58.
pub fn ruby_macho_file_l58_d8_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('initialize requires a filename') }
	options := if args.len > 1 {
		macho_file_options_from_value(args[1])
	} else {
		MachoFileOptions{}
	}
	return macho_file_boundary(new_macho_file(args[0].as_string(), options) or { panic(err) })
}

// Ruby method `initialize_from_bin(bin, opts)` at line 75.
pub fn ruby_macho_file_l75_d9_initialize_from_bin(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('initialize_from_bin requires binary data') }
	options := if args.len > 1 {
		macho_file_options_from_value(args[1])
	} else {
		MachoFileOptions{}
	}
	return macho_file_boundary(new_macho_file_from_bin(args[0].as_string().bytes(), options) or { panic(err) })
}

// Ruby method `serialize` at line 84.
pub fn ruby_macho_file_l84_d10_serialize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_file_from_args(args).serialize().bytestr())
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d11_magic(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).header.magic)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d12_ncmds(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).header.ncmds)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d13_sizeofcmds(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).header.sizeofcmds)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d14_flags(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).header.flags)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d15_object(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_object)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d16_executable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_execute)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d17_fvmlib(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_fvmlib)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d18_core(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_core)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d19_preload(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_preload)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d20_dylib(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_dylib)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d21_dylinker(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_dylinker)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d22_bundle(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_bundle)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d23_dsym(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_dsym)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d24_kext(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.filetype == mh_kext_bundle)
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d25_magic32(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.magic32())
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d26_magic64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_file_from_args(args).header.magic64())
}

// Ruby def_delegators `def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?, :alignment` at line 122.
pub fn ruby_macho_file_l122_d27_alignment(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).header.alignment())
}

// Ruby method `magic_string` at line 128.
pub fn ruby_macho_file_l128_d28_magic_string(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_file_from_args(args).magic_string())
}

// Ruby method `filetype` at line 133.
pub fn ruby_macho_file_l133_d29_filetype(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${macho_file_from_args(args).filetype_symbol()}')
}

// Ruby method `cputype` at line 138.
pub fn ruby_macho_file_l138_d30_cputype(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${macho_file_from_args(args).cputype_symbol()}')
}

// Ruby method `cpusubtype` at line 143.
pub fn ruby_macho_file_l143_d31_cpusubtype(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':${macho_file_from_args(args).cpusubtype_symbol()}')
}

// Ruby method `command(name)` at line 154.
pub fn ruby_macho_file_l154_d32_command(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('command requires a name') }
	return ruby.array_value(macho_file_from_args(args).command(args[1].as_string()).map(load_command_boundary(it)))
}

// Ruby alias `alias [] command` at line 158.
pub fn ruby_macho_file_l158_d33_anonymous(args ...ruby.Value) ruby.Value {
	return ruby_macho_file_l154_d32_command(...args)
}

// Ruby method `insert_command(offset, lc, options = {})` at line 170.
pub fn ruby_macho_file_l170_d34_insert_command(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('insert_command requires an offset and load command') }
	mut file := macho_file_from_args(args)
	repopulate := if args.len > 3 {
		(args[3].as_map() or { map[string]ruby.Value{} })['repopulate'].as_bool() or { true }
	} else {
		true
	}
	file.insert_command(int(args[1].as_int() or { panic(err) }), load_command_from_args(args[2..3]), repopulate) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `replace_command(old_lc, new_lc)` at line 198.
pub fn ruby_macho_file_l198_d35_replace_command(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('replace_command requires old and new load commands') }
	mut file := macho_file_from_args(args)
	file.replace_command(load_command_from_args(args[1..2]), load_command_from_args(args[2..3])) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `add_command(lc, options = {})` at line 220.
pub fn ruby_macho_file_l220_d36_add_command(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('add_command requires a load command') }
	mut file := macho_file_from_args(args)
	repopulate := if args.len > 2 {
		(args[2].as_map() or { map[string]ruby.Value{} })['repopulate'].as_bool() or { true }
	} else {
		true
	}
	file.add_command(load_command_from_args(args[1..2]), repopulate) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `delete_command(lc, options = {})` at line 234.
pub fn ruby_macho_file_l234_d37_delete_command(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('delete_command requires a load command') }
	mut file := macho_file_from_args(args)
	repopulate := if args.len > 2 {
		(args[2].as_map() or { map[string]ruby.Value{} })['repopulate'].as_bool() or { true }
	} else {
		true
	}
	file.delete_command(load_command_from_args(args[1..2]), repopulate) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `populate_fields` at line 252.
pub fn ruby_macho_file_l252_d38_populate_fields(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	file.populate_fields() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `dylib_load_commands` at line 260.
pub fn ruby_macho_file_l260_d39_dylib_load_commands(args ...ruby.Value) ruby.Value {
	return ruby.array_value(macho_file_from_args(args).dylib_load_commands().map(load_command_boundary(it)))
}

// Ruby method `segments` at line 268.
pub fn ruby_macho_file_l268_d40_segments(args ...ruby.Value) ruby.Value {
	return ruby.array_value(macho_file_from_args(args).segments().map(load_command_boundary(it)))
}

// Ruby method `segment_alignment` at line 280.
pub fn ruby_macho_file_l280_d41_segment_alignment(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).calculate_segment_alignment())
}

// Ruby method `dylib_id` at line 288.
pub fn ruby_macho_file_l288_d42_dylib_id(args ...ruby.Value) ruby.Value {
	return if id := macho_file_from_args(args).dylib_id() {
		ruby.string_value(id)
	} else {
		nil_macho_value()
	}
}

// Ruby method `change_dylib_id(new_id, _options = {})` at line 305.
pub fn ruby_macho_file_l305_d43_change_dylib_id(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'String' { panic('new ID must be a String') }
	mut file := macho_file_from_args(args)
	file.change_dylib_id(args[1].as_string()) or { panic(err) }
	return nil_macho_value()
}

// Ruby alias `alias dylib_id= change_dylib_id` at line 320.
pub fn ruby_macho_file_l320_d44_dylib_id(args ...ruby.Value) ruby.Value {
	return ruby_macho_file_l305_d43_change_dylib_id(...args)
}

// Ruby method `linked_dylibs` at line 324.
pub fn ruby_macho_file_l324_d45_linked_dylibs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(macho_file_from_args(args).linked_dylibs())
}

// Ruby method `change_install_name(old_name, new_name, _options = {})` at line 343.
pub fn ruby_macho_file_l343_d46_change_install_name(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('change_install_name requires old and new names') }
	mut file := macho_file_from_args(args)
	file.change_install_name(args[1].as_string(), args[2].as_string()) or { panic(err) }
	return nil_macho_value()
}

// Ruby alias `alias change_dylib change_install_name` at line 355.
pub fn ruby_macho_file_l355_d47_change_dylib(args ...ruby.Value) ruby.Value {
	return ruby_macho_file_l343_d46_change_install_name(...args)
}

// Ruby method `rpaths` at line 359.
pub fn ruby_macho_file_l359_d48_rpaths(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(macho_file_from_args(args).rpaths())
}

// Ruby method `change_rpath(old_path, new_path, options = {})` at line 374.
pub fn ruby_macho_file_l374_d49_change_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('change_rpath requires old and new paths') }
	mut file := macho_file_from_args(args)
	options := if args.len > 3 {
		delete_rpath_options_from_value(args[3])
	} else {
		DeleteRpathOptions{}
	}
	file.change_rpath(args[1].as_string(), args[2].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `add_rpath(path, _options = {})` at line 395.
pub fn ruby_macho_file_l395_d50_add_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('add_rpath requires a path') }
	mut file := macho_file_from_args(args)
	file.add_rpath(args[1].as_string()) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `delete_rpath(path, options = {})` at line 424.
pub fn ruby_macho_file_l424_d51_delete_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('delete_rpath requires a path') }
	mut file := macho_file_from_args(args)
	options := if args.len > 2 {
		delete_rpath_options_from_value(args[2])
	} else {
		DeleteRpathOptions{}
	}
	file.delete_rpath(args[1].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `codesign!(identifier: nil)` at line 444.
pub fn ruby_macho_file_l444_d52_codesign(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	identifier := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	file.codesign(identifier) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `write(filename)` at line 451.
pub fn ruby_macho_file_l451_d53_write(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('write requires a filename') }
	macho_file_from_args(args).write(args[1].as_string()) or { panic(err) }
	return ruby.int_value(macho_file_from_args(args).raw_data.len)
}

// Ruby method `write!` at line 459.
pub fn ruby_macho_file_l459_d54_write(args ...ruby.Value) ruby.Value {
	macho_file_from_args(args).write_initial() or { panic(err) }
	return ruby.int_value(macho_file_from_args(args).raw_data.len)
}

// Ruby method `to_h` at line 466.
pub fn ruby_macho_file_l466_d55_to_h(args ...ruby.Value) ruby.Value {
	return macho_file_from_args(args).to_h()
}

// Ruby method `clear_memoization_cache` at line 478.
pub fn ruby_macho_file_l478_d56_clear_memoization_cache(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	file.clear_memoization_cache()
	return nil_macho_value()
}

// Ruby method `populate_mach_header` at line 491.
pub fn ruby_macho_file_l491_d57_populate_mach_header(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	return macho_header_boundary(file.populate_mach_header() or { panic(err) })
}

// Ruby method `populate_prelinked_kernel_header` at line 515.
pub fn ruby_macho_file_l515_d58_populate_prelinked_kernel_header(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	file.populate_prelinked_kernel_header() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `decompress_macho_lzvn` at line 532.
pub fn ruby_macho_file_l532_d59_decompress_macho_lzvn(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	file.decompress_macho_lzvn() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `populate_and_check_magic` at line 556.
pub fn ruby_macho_file_l556_d60_populate_and_check_magic(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	return ruby.int_value(file.populate_and_check_magic() or { panic(err) })
}

// Ruby method `check_cputype(cputype)` at line 571.
pub fn ruby_macho_file_l571_d61_check_cputype(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('check_cputype requires a CPU type') }
	macho_file_from_args(args).check_cputype(u32(args[1].as_int() or { panic(err) })) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `check_cpusubtype(cputype, cpusubtype)` at line 579.
pub fn ruby_macho_file_l579_d62_check_cpusubtype(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('check_cpusubtype requires a CPU type and subtype') }
	macho_file_from_args(args).check_cpusubtype(u32(args[1].as_int() or { panic(err) }), u32(args[2].as_int() or { panic(err) })) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `check_filetype(filetype)` at line 588.
pub fn ruby_macho_file_l588_d63_check_filetype(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('check_filetype requires a file type') }
	macho_file_from_args(args).check_filetype(u32(args[1].as_int() or { panic(err) })) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `populate_load_commands` at line 598.
pub fn ruby_macho_file_l598_d64_populate_load_commands(args ...ruby.Value) ruby.Value {
	mut file := macho_file_from_args(args)
	return ruby.array_value((file.populate_load_commands() or { panic(err) }).map(load_command_boundary(it)))
}

// Ruby method `calculate_segment_alignment` at line 643.
pub fn ruby_macho_file_l643_d65_calculate_segment_alignment(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).calculate_segment_alignment())
}

// Ruby method `low_fileoff` at line 669.
pub fn ruby_macho_file_l669_d66_low_fileoff(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_file_from_args(args).low_fileoff())
}

// Ruby method `update_ncmds(ncmds)` at line 693.
pub fn ruby_macho_file_l693_d67_update_ncmds(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('update_ncmds requires a count') }
	mut file := macho_file_from_args(args)
	file.update_ncmds(u32(args[1].as_int() or { panic(err) })) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `update_sizeofcmds(size)` at line 703.
pub fn ruby_macho_file_l703_d68_update_sizeofcmds(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('update_sizeofcmds requires a size') }
	mut file := macho_file_from_args(args)
	file.update_sizeofcmds(u32(args[1].as_int() or { panic(err) })) or { panic(err) }
	return nil_macho_value()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require "forwardable"
// 4:
// 5: module MachO
// 6:   # Represents a Mach-O file, which contains a header and load commands
// 7:   # as well as binary executable instructions. Mach-O binaries are
// 8:   # architecture specific.
// 9:   # @see https://en.wikipedia.org/wiki/Mach-O
// 10:   # @see FatFile
// 11:   class MachOFile
// 12:     extend Forwardable
// 13:
// 14:     # @return [String, nil] the filename loaded from, or nil if loaded from a binary
// 15:     #  string
// 16:     attr_accessor :filename
// 17:
// 18:     # @return [Hash] any parser options that the instance was created with
// 19:     attr_reader :options
// 20:
// 21:     # @return [Symbol] the endianness of the file, :big or :little
// 22:     attr_reader :endianness
// 23:
// 24:     # @return [Headers::MachHeader] if the Mach-O is 32-bit
// 25:     # @return [Headers::MachHeader64] if the Mach-O is 64-bit
// 26:     attr_reader :header
// 27:
// 28:     # @return [Array<LoadCommands::LoadCommand>] an array of the file's load
// 29:     #  commands
// 30:     # @note load commands are provided in order of ascending offset.
// 31:     attr_reader :load_commands
// 32:
// 33:     # Creates a new instance from a binary string.
// 34:     # @param bin [String] a binary string containing raw Mach-O data
// 35:     # @param opts [Hash] options to control the parser with
// 36:     # @option opts [Boolean] :permissive whether to ignore unknown load commands
// 37:     # @option opts [Boolean] :decompress whether to decompress, if capable
// 38:     # @return [MachOFile] a new MachOFile
// 39:     # @note The `:decompress` option relies on non-default dependencies. Compression
// 40:     #  is only used in niche Mach-Os, so leaving this disabled is a reasonable default for
// 41:     #  virtually all normal uses.
// 42:     def self.new_from_bin(bin, **opts)
// 43:       instance = allocate
// 44:       instance.initialize_from_bin(bin, opts)
// 45:
// 46:       instance
// 47:     end
// 48:
// 49:     # Creates a new instance from data read from the given filename.
// 50:     # @param filename [String] the Mach-O file to load from
// 51:     # @param opts [Hash] options to control the parser with
// 52:     # @option opts [Boolean] :permissive whether to ignore unknown load commands
// 53:     # @option opts [Boolean] :decompress whether to decompress, if capable
// 54:     # @raise [ArgumentError] if the given file does not exist
// 55:     # @note The `:decompress` option relies on non-default dependencies. Compression
// 56:     #  is only used in niche Mach-Os, so leaving this disabled is a reasonable default for
// 57:     #  virtually all normal uses.
// 58:     def initialize(filename, **opts)
// 59:       raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 60:
// 61:       @filename = filename
// 62:       @options = opts
// 63:       File.open(@filename, "rb") do |file|
// 64:         @raw_data = file.read(Headers::MachHeader.bytesize)
// 65:         @raw_data ||= ""
// 66:         populate_mach_header if !opts.fetch(:decompress, false) || !Utils.compressed_magic?(@raw_data.unpack1("N"))
// 67:         @raw_data << file.read.to_s
// 68:       end
// 69:       populate_fields
// 70:     end
// 71:
// 72:     # Initializes a new MachOFile instance from a binary string with the given options.
// 73:     # @see MachO::MachOFile.new_from_bin
// 74:     # @api private
// 75:     def initialize_from_bin(bin, opts)
// 76:       @filename = nil
// 77:       @options = opts
// 78:       @raw_data = bin
// 79:       populate_fields
// 80:     end
// 81:
// 82:     # The file's raw Mach-O data.
// 83:     # @return [String] the raw Mach-O data
// 84:     def serialize
// 85:       @raw_data
// 86:     end
// 87:
// 88:     # @!method magic
// 89:     #  @return (see MachO::Headers::MachHeader#magic)
// 90:     # @!method ncmds
// 91:     #  @return (see MachO::Headers::MachHeader#ncmds)
// 92:     # @!method sizeofcmds
// 93:     #  @return (see MachO::Headers::MachHeader#sizeofcmds)
// 94:     # @!method flags
// 95:     #  @return (see MachO::Headers::MachHeader#flags)
// 96:     # @!method object?
// 97:     #  @return (see MachO::Headers::MachHeader#object?)
// 98:     # @!method executable?
// 99:     #  @return (see MachO::Headers::MachHeader#executable?)
// 100:     # @!method fvmlib?
// 101:     #  @return (see MachO::Headers::MachHeader#fvmlib?)
// 102:     # @!method core?
// 103:     #  @return (see MachO::Headers::MachHeader#core?)
// 104:     # @!method preload?
// 105:     #  @return (see MachO::Headers::MachHeader#preload?)
// 106:     # @!method dylib?
// 107:     #  @return (see MachO::Headers::MachHeader#dylib?)
// 108:     # @!method dylinker?
// 109:     #  @return (see MachO::Headers::MachHeader#dylinker?)
// 110:     # @!method bundle?
// 111:     #  @return (see MachO::Headers::MachHeader#bundle?)
// 112:     # @!method dsym?
// 113:     #  @return (see MachO::Headers::MachHeader#dsym?)
// 114:     # @!method kext?
// 115:     #  @return (see MachO::Headers::MachHeader#kext?)
// 116:     # @!method magic32?
// 117:     #  @return (see MachO::Headers::MachHeader#magic32?)
// 118:     # @!method magic64?
// 119:     #  @return (see MachO::Headers::MachHeader#magic64?)
// 120:     # @!method alignment
// 121:     #  @return (see MachO::Headers::MachHeader#alignment)
// 122:     def_delegators :header, :magic, :ncmds, :sizeofcmds, :flags, :object?,
// 123:                    :executable?, :fvmlib?, :core?, :preload?, :dylib?,
// 124:                    :dylinker?, :bundle?, :dsym?, :kext?, :magic32?, :magic64?,
// 125:                    :alignment
// 126:
// 127:     # @return [String] a string representation of the file's magic number
// 128:     def magic_string
// 129:       Headers::MH_MAGICS[magic]
// 130:     end
// 131:
// 132:     # @return [Symbol] a string representation of the Mach-O's filetype
// 133:     def filetype
// 134:       Headers::MH_FILETYPES[header.filetype]
// 135:     end
// 136:
// 137:     # @return [Symbol] a symbol representation of the Mach-O's CPU type
// 138:     def cputype
// 139:       Headers::CPU_TYPES[header.cputype]
// 140:     end
// 141:
// 142:     # @return [Symbol] a symbol representation of the Mach-O's CPU subtype
// 143:     def cpusubtype
// 144:       Headers::CPU_SUBTYPES[header.cputype][header.cpusubtype]
// 145:     end
// 146:
// 147:     # All load commands of a given name.
// 148:     # @example
// 149:     #  file.command("LC_LOAD_DYLIB")
// 150:     #  file[:LC_LOAD_DYLIB]
// 151:     # @param [String, Symbol] name the load command ID
// 152:     # @return [Array<LoadCommands::LoadCommand>] an array of load commands
// 153:     #  corresponding to `name`
// 154:     def command(name)
// 155:       @load_commands_by_type.fetch(name.to_sym, []).dup
// 156:     end
// 157:
// 158:     alias [] command
// 159:
// 160:     # Inserts a load command at the given offset.
// 161:     # @param offset [Integer] the offset to insert at
// 162:     # @param lc [LoadCommands::LoadCommand] the load command to insert
// 163:     # @param options [Hash]
// 164:     # @option options [Boolean] :repopulate (true) whether or not to repopulate
// 165:     #  the instance fields
// 166:     # @raise [OffsetInsertionError] if the offset is not in the load command region
// 167:     # @raise [HeaderPadError] if the new command exceeds the header pad buffer
// 168:     # @note Calling this method with an arbitrary offset in the load command region
// 169:     # **will leave the object in an inconsistent state**.
// 170:     def insert_command(offset, lc, options = {})
// 171:       context = LoadCommands::LoadCommand::SerializationContext.context_for(self)
// 172:       cmd_raw = lc.serialize(context)
// 173:       fileoff = offset + cmd_raw.bytesize
// 174:
// 175:       raise OffsetInsertionError, offset if offset < header.class.bytesize || fileoff > low_fileoff
// 176:
// 177:       new_sizeofcmds = sizeofcmds + cmd_raw.bytesize
// 178:
// 179:       raise HeaderPadError, @filename if header.class.bytesize + new_sizeofcmds > low_fileoff
// 180:
// 181:       # update Mach-O header fields to account for inserted load command
// 182:       update_ncmds(ncmds + 1)
// 183:       update_sizeofcmds(new_sizeofcmds)
// 184:
// 185:       @raw_data.insert(offset, cmd_raw)
// 186:       @raw_data.slice!(header.class.bytesize + new_sizeofcmds, cmd_raw.bytesize)
// 187:
// 188:       populate_fields if options.fetch(:repopulate, true)
// 189:     end
// 190:
// 191:     # Replace a load command with another command in the Mach-O, preserving location.
// 192:     # @param old_lc [LoadCommands::LoadCommand] the load command being replaced
// 193:     # @param new_lc [LoadCommands::LoadCommand] the load command being added
// 194:     # @return [void]
// 195:     # @raise [HeaderPadError] if the new command exceeds the header pad buffer
// 196:     # @see #insert_command
// 197:     # @note This is public, but methods like {#dylib_id=} should be preferred.
// 198:     def replace_command(old_lc, new_lc)
// 199:       context = LoadCommands::LoadCommand::SerializationContext.context_for(self)
// 200:       cmd_raw = new_lc.serialize(context)
// 201:       new_sizeofcmds = sizeofcmds + cmd_raw.bytesize - old_lc.cmdsize
// 202:
// 203:       raise HeaderPadError, @filename if header.class.bytesize + new_sizeofcmds > low_fileoff
// 204:
// 205:       delete_command(old_lc)
// 206:       insert_command(old_lc.view.offset, new_lc)
// 207:     end
// 208:
// 209:     # Appends a new load command to the Mach-O.
// 210:     # @param lc [LoadCommands::LoadCommand] the load command being added
// 211:     # @param options [Hash]
// 212:     # @option f [Boolean] :repopulate (true) whether or not to repopulate
// 213:     #  the instance fields
// 214:     # @return [void]
// 215:     # @see #insert_command
// 216:     # @note This is public, but methods like {#add_rpath} should be preferred.
// 217:     #  Setting `repopulate` to false **will leave the instance in an
// 218:     #  inconsistent state** unless {#populate_fields} is called **immediately**
// 219:     #  afterwards.
// 220:     def add_command(lc, options = {})
// 221:       insert_command(header.class.bytesize + sizeofcmds, lc, options)
// 222:     end
// 223:
// 224:     # Delete a load command from the Mach-O.
// 225:     # @param lc [LoadCommands::LoadCommand] the load command being deleted
// 226:     # @param options [Hash]
// 227:     # @option options [Boolean] :repopulate (true) whether or not to repopulate
// 228:     #  the instance fields
// 229:     # @return [void]
// 230:     # @note This is public, but methods like {#delete_rpath} should be preferred.
// 231:     #  Setting `repopulate` to false **will leave the instance in an
// 232:     #  inconsistent state** unless {#populate_fields} is called **immediately**
// 233:     #  afterwards.
// 234:     def delete_command(lc, options = {})
// 235:       @raw_data.slice!(lc.view.offset, lc.cmdsize)
// 236:
// 237:       # update Mach-O header fields to account for deleted load command
// 238:       update_ncmds(ncmds - 1)
// 239:       update_sizeofcmds(sizeofcmds - lc.cmdsize)
// 240:
// 241:       # pad the space after the load commands to preserve offsets
// 242:       @raw_data.insert(header.class.bytesize + sizeofcmds - lc.cmdsize, Utils.nullpad(lc.cmdsize))
// 243:
// 244:       populate_fields if options.fetch(:repopulate, true)
// 245:     end
// 246:
// 247:     # Populate the instance's fields with the raw Mach-O data.
// 248:     # @return [void]
// 249:     # @note This method is public, but should (almost) never need to be called.
// 250:     #  The exception to this rule is when methods like {#add_command} and
// 251:     #  {#delete_command} have been called with `repopulate = false`.
// 252:     def populate_fields
// 253:       clear_memoization_cache
// 254:       @header = populate_mach_header
// 255:       @load_commands = populate_load_commands
// 256:     end
// 257:
// 258:     # All load commands responsible for loading dylibs.
// 259:     # @return [Array<LoadCommands::DylibCommand>] an array of DylibCommands
// 260:     def dylib_load_commands
// 261:       @dylib_load_commands ||= load_commands.select { |lc| LoadCommands::DYLIB_LOAD_COMMANDS.include?(lc.type) }
// 262:       @dylib_load_commands.dup
// 263:     end
// 264:
// 265:     # All segment load commands in the Mach-O.
// 266:     # @return [Array<LoadCommands::SegmentCommand>] if the Mach-O is 32-bit
// 267:     # @return [Array<LoadCommands::SegmentCommand64>] if the Mach-O is 64-bit
// 268:     def segments
// 269:       if magic32?
// 270:         command(:LC_SEGMENT)
// 271:       else
// 272:         command(:LC_SEGMENT_64)
// 273:       end
// 274:     end
// 275:
// 276:     # The segment alignment for the Mach-O. Guesses conservatively.
// 277:     # @return [Integer] the alignment, as a power of 2
// 278:     # @note This is **not** the same as {#alignment}!
// 279:     # @note See `get_align` and `get_align_64` in `cctools/misc/lipo.c`
// 280:     def segment_alignment
// 281:       @segment_alignment ||= calculate_segment_alignment
// 282:     end
// 283:
// 284:     # The Mach-O's dylib ID, or `nil` if not a dylib.
// 285:     # @example
// 286:     #  file.dylib_id # => 'libBar.dylib'
// 287:     # @return [String, nil] the Mach-O's dylib ID
// 288:     def dylib_id
// 289:       return unless dylib?
// 290:
// 291:       dylib_id_cmd = command(:LC_ID_DYLIB).first
// 292:
// 293:       dylib_id_cmd.name.to_s
// 294:     end
// 295:
// 296:     # Changes the Mach-O's dylib ID to `new_id`. Does nothing if not a dylib.
// 297:     # @example
// 298:     #  file.change_dylib_id("libFoo.dylib")
// 299:     # @param new_id [String] the dylib's new ID
// 300:     # @param _options [Hash]
// 301:     # @return [void]
// 302:     # @raise [ArgumentError] if `new_id` is not a String
// 303:     # @note `_options` is currently unused and is provided for signature
// 304:     #  compatibility with {MachO::FatFile#change_dylib_id}
// 305:     def change_dylib_id(new_id, _options = {})
// 306:       raise ArgumentError, "new ID must be a String" unless new_id.is_a?(String)
// 307:       return unless dylib?
// 308:
// 309:       old_lc = command(:LC_ID_DYLIB).first
// 310:       raise DylibIdMissingError unless old_lc
// 311:
// 312:       new_lc = LoadCommands::LoadCommand.create(:LC_ID_DYLIB, new_id,
// 313:                                                 old_lc.timestamp,
// 314:                                                 old_lc.current_version,
// 315:                                                 old_lc.compatibility_version)
// 316:
// 317:       replace_command(old_lc, new_lc)
// 318:     end
// 319:
// 320:     alias dylib_id= change_dylib_id
// 321:
// 322:     # All shared libraries linked to the Mach-O.
// 323:     # @return [Array<String>] an array of all shared libraries
// 324:     def linked_dylibs
// 325:       # Some linkers produce multiple `LC_LOAD_DYLIB` load commands for the same
// 326:       # library, but at this point we're really only interested in a list of
// 327:       # unique libraries this Mach-O file links to, thus: `uniq`. (This is also
// 328:       # for consistency with `FatFile` that merges this list across all archs.)
// 329:       @linked_dylibs ||= dylib_load_commands.map { |lc| lc.name.to_s }.uniq
// 330:       @linked_dylibs.dup
// 331:     end
// 332:
// 333:     # Changes the shared library `old_name` to `new_name`
// 334:     # @example
// 335:     #  file.change_install_name("abc.dylib", "def.dylib")
// 336:     # @param old_name [String] the shared library's old name
// 337:     # @param new_name [String] the shared library's new name
// 338:     # @param _options [Hash]
// 339:     # @return [void]
// 340:     # @raise [DylibUnknownError] if no shared library has the old name
// 341:     # @note `_options` is currently unused and is provided for signature
// 342:     #  compatibility with {MachO::FatFile#change_install_name}
// 343:     def change_install_name(old_name, new_name, _options = {})
// 344:       old_lc = dylib_load_commands.find { |d| d.name.to_s == old_name }
// 345:       raise DylibUnknownError, old_name if old_lc.nil?
// 346:
// 347:       new_lc = LoadCommands::LoadCommand.create(old_lc.type, new_name,
// 348:                                                 old_lc.timestamp,
// 349:                                                 old_lc.current_version,
// 350:                                                 old_lc.compatibility_version)
// 351:
// 352:       replace_command(old_lc, new_lc)
// 353:     end
// 354:
// 355:     alias change_dylib change_install_name
// 356:
// 357:     # All runtime paths searched by the dynamic linker for the Mach-O.
// 358:     # @return [Array<String>] an array of all runtime paths
// 359:     def rpaths
// 360:       @rpaths ||= command(:LC_RPATH).map { |lc| lc.path.to_s }
// 361:       @rpaths.dup
// 362:     end
// 363:
// 364:     # Changes the runtime path `old_path` to `new_path`
// 365:     # @example
// 366:     #  file.change_rpath("/usr/lib", "/usr/local/lib")
// 367:     # @param old_path [String] the old runtime path
// 368:     # @param new_path [String] the new runtime path
// 369:     # @param options [Hash]
// 370:     # @option options [Boolean] :uniq (false) if true, change duplicate
// 371:     #  rpaths simultaneously.
// 372:     # @return [void]
// 373:     # @raise [RpathUnknownError] if no such old runtime path exists
// 374:     def change_rpath(old_path, new_path, options = {})
// 375:       old_lc = command(:LC_RPATH).find { |r| r.path.to_s == old_path }
// 376:       raise RpathUnknownError, old_path if old_lc.nil?
// 377:
// 378:       new_lc = LoadCommands::LoadCommand.create(:LC_RPATH, new_path)
// 379:
// 380:       delete_rpath(old_path, options)
// 381:       insert_command(old_lc.view.offset, new_lc)
// 382:     end
// 383:
// 384:     # Add the given runtime path to the Mach-O.
// 385:     # @example
// 386:     #  file.rpaths # => ["/lib"]
// 387:     #  file.add_rpath("/usr/lib")
// 388:     #  file.rpaths # => ["/lib", "/usr/lib"]
// 389:     # @param path [String] the new runtime path
// 390:     # @param _options [Hash]
// 391:     # @return [void]
// 392:     # @raise [RpathExistsError] if the runtime path already exists
// 393:     # @note `_options` is currently unused and is provided for signature
// 394:     #  compatibility with {MachO::FatFile#add_rpath}
// 395:     def add_rpath(path, _options = {})
// 396:       raise RpathExistsError, path if rpaths.include?(path)
// 397:
// 398:       rpath_cmd = LoadCommands::LoadCommand.create(:LC_RPATH, path)
// 399:       add_command(rpath_cmd)
// 400:     end
// 401:
// 402:     # Delete the given runtime path from the Mach-O.
// 403:     # @example
// 404:     #  file1.rpaths # => ["/lib", "/usr/lib", "/lib"]
// 405:     #  file1.delete_rpath("/lib")
// 406:     #  file1.rpaths # => ["/usr/lib", "/lib"]
// 407:     #  file2.rpaths # => ["foo", "foo"]
// 408:     #  file2.delete_rpath("foo", :uniq => true)
// 409:     #  file2.rpaths # => []
// 410:     #  file3.rpaths # => ["foo", "bar", "foo"]
// 411:     #  file3.delete_rpath("foo", :last => true)
// 412:     #  file3.rpaths # => ["foo", "bar"]
// 413:     # @param path [String] the runtime path to delete
// 414:     # @param options [Hash]
// 415:     # @option options [Boolean] :uniq (false) if true, also delete
// 416:     #  duplicates of the requested path. If false, delete the first
// 417:     #  instance (by offset) of the requested path, unless :last is true.
// 418:     #  Incompatible with :last.
// 419:     # @option options [Boolean] :last (false) if true, delete the last
// 420:     #  instance (by offset) of the requested path. Incompatible with :uniq.
// 421:     # @return void
// 422:     # @raise [RpathUnknownError] if no such runtime path exists
// 423:     # @raise [ArgumentError] if both :uniq and :last are true
// 424:     def delete_rpath(path, options = {})
// 425:       uniq = options.fetch(:uniq, false)
// 426:       last = options.fetch(:last, false)
// 427:       raise ArgumentError, "Cannot set both :uniq and :last to true" if uniq && last
// 428:
// 429:       search_method = uniq || last ? :select : :find
// 430:       rpath_cmds = command(:LC_RPATH).public_send(search_method) { |r| r.path.to_s == path }
// 431:       rpath_cmds = rpath_cmds.last if last
// 432:
// 433:       # Cast rpath_cmds into an Array so we can handle the uniq and non-uniq cases the same way
// 434:       rpath_cmds = Array(rpath_cmds)
// 435:       raise RpathUnknownError, path if rpath_cmds.empty?
// 436:
// 437:       # delete the commands in reverse order, offset descending.
// 438:       rpath_cmds.reverse_each { |cmd| delete_command(cmd) }
// 439:     end
// 440:
// 441:     # Replaces the embedded signature with a pure-Ruby ad-hoc signature.
// 442:     # @param identifier [String, nil] the signing identifier
// 443:     # @return [void]
// 444:     def codesign!(identifier: nil)
// 445:       CodeSigning::AdhocSigner.new(self, identifier || CodeSigning.identifier(self, filename)).sign!
// 446:     end
// 447:
// 448:     # Write all Mach-O data to the given filename.
// 449:     # @param filename [String] the file to write to
// 450:     # @return [void]
// 451:     def write(filename)
// 452:       File.binwrite(filename, @raw_data)
// 453:     end
// 454:
// 455:     # Write all Mach-O data to the file used to initialize the instance.
// 456:     # @return [void]
// 457:     # @raise [MachOError] if the instance was initialized without a file
// 458:     # @note Overwrites all data in the file!
// 459:     def write!
// 460:       raise MachOError, "no initial file to write to" if @filename.nil?
// 461:
// 462:       File.binwrite(@filename, @raw_data)
// 463:     end
// 464:
// 465:     # @return [Hash] a hash representation of this {MachOFile}
// 466:     def to_h
// 467:       {
// 468:         "header" => header.to_h,
// 469:         "load_commands" => load_commands.map(&:to_h),
// 470:       }
// 471:     end
// 472:
// 473:     private
// 474:
// 475:     # Clears all memoized values. Called when the file is repopulated.
// 476:     # @return [void]
// 477:     # @api private
// 478:     def clear_memoization_cache
// 479:       @linked_dylibs = nil
// 480:       @rpaths = nil
// 481:       @dylib_load_commands = nil
// 482:       @load_commands_by_type = nil
// 483:       @segment_alignment = nil
// 484:     end
// 485:
// 486:     # The file's Mach-O header structure.
// 487:     # @return [Headers::MachHeader] if the Mach-O is 32-bit
// 488:     # @return [Headers::MachHeader64] if the Mach-O is 64-bit
// 489:     # @raise [TruncatedFileError] if the file is too small to have a valid header
// 490:     # @api private
// 491:     def populate_mach_header
// 492:       # the smallest Mach-O header is 28 bytes
// 493:       raise TruncatedFileError if @raw_data.size < 28
// 494:
// 495:       magic = @raw_data[0..3].unpack1("N")
// 496:       populate_prelinked_kernel_header if Utils.compressed_magic?(magic)
// 497:
// 498:       magic = populate_and_check_magic
// 499:       mh_klass = Utils.magic32?(magic) ? Headers::MachHeader : Headers::MachHeader64
// 500:       mh = mh_klass.new_from_bin(endianness, @raw_data[0, mh_klass.bytesize])
// 501:
// 502:       check_cputype(mh.cputype)
// 503:       check_cpusubtype(mh.cputype, mh.cpusubtype)
// 504:       check_filetype(mh.filetype)
// 505:
// 506:       mh
// 507:     end
// 508:
// 509:     # Read a compressed Mach-O header and check its validity, as well as whether we're able
// 510:     # to parse it.
// 511:     # @return [void]
// 512:     # @raise [CompressedMachOError] if we weren't asked to perform decompression
// 513:     # @raise [DecompressionError] if decompression is impossible or fails
// 514:     # @api private
// 515:     def populate_prelinked_kernel_header
// 516:       raise CompressedMachOError unless options.fetch(:decompress, false)
// 517:
// 518:       @plh = Headers::PrelinkedKernelHeader.new_from_bin :big, @raw_data[0, Headers::PrelinkedKernelHeader.bytesize]
// 519:
// 520:       raise DecompressionError, "unsupported compression type: LZSS" if @plh.lzss?
// 521:       raise DecompressionError, "unknown compression type: 0x#{plh.compress_type.to_s 16}" unless @plh.lzvn?
// 522:
// 523:       decompress_macho_lzvn
// 524:     end
// 525:
// 526:     # Attempt to decompress a Mach-O file from the data specified in a prelinked kernel header.
// 527:     # @return [void]
// 528:     # @raise [DecompressionError] if decompression is impossible or fails
// 529:     # @api private
// 530:     # @note This method rewrites the internal state of {MachOFile} to pretend as if it was never
// 531:     #  compressed to begin with, allowing all other APIs to transparently act on compressed Mach-Os.
// 532:     def decompress_macho_lzvn
// 533:       begin
// 534:         require "lzfse"
// 535:       rescue LoadError
// 536:         raise DecompressionError, "LZVN required but the optional 'lzfse' gem is not installed"
// 537:       end
// 538:
// 539:       # From this point onwards, the internal buffer of this MachOFile refers to the decompressed
// 540:       # contents specified by the prelinked kernel header.
// 541:       begin
// 542:         @raw_data = LZFSE.lzvn_decompress @raw_data.slice(Headers::PrelinkedKernelHeader.bytesize, @plh.compressed_size)
// 543:         # Sanity checks.
// 544:         raise DecompressionError if @raw_data.size != @plh.uncompressed_size
// 545:         # TODO: check the adler32 CRC in @plh
// 546:       rescue LZFSE::DecodeError
// 547:         raise DecompressionError, "LZVN decompression failed"
// 548:       end
// 549:     end
// 550:
// 551:     # Read just the file's magic number and check its validity.
// 552:     # @return [Integer] the magic
// 553:     # @raise [MagicError] if the magic is not valid Mach-O magic
// 554:     # @raise [FatBinaryError] if the magic is for a Fat file
// 555:     # @api private
// 556:     def populate_and_check_magic
// 557:       magic = @raw_data[0..3].unpack1("N")
// 558:
// 559:       raise MagicError, magic unless Utils.magic?(magic)
// 560:       raise FatBinaryError if Utils.fat_magic?(magic)
// 561:
// 562:       @endianness = Utils.little_magic?(magic) ? :little : :big
// 563:
// 564:       magic
// 565:     end
// 566:
// 567:     # Check the file's CPU type.
// 568:     # @param cputype [Integer] the CPU type
// 569:     # @raise [CPUTypeError] if the CPU type is unknown
// 570:     # @api private
// 571:     def check_cputype(cputype)
// 572:       raise CPUTypeError, cputype unless Headers::CPU_TYPES.key?(cputype)
// 573:     end
// 574:
// 575:     # Check the file's CPU type/subtype pair.
// 576:     # @param cpusubtype [Integer] the CPU subtype
// 577:     # @raise [CPUSubtypeError] if the CPU sub-type is unknown
// 578:     # @api private
// 579:     def check_cpusubtype(cputype, cpusubtype)
// 580:       # Only check sub-type w/o capability bits (see `populate_mach_header`).
// 581:       raise CPUSubtypeError.new(cputype, cpusubtype) unless Headers::CPU_SUBTYPES[cputype].key?(cpusubtype)
// 582:     end
// 583:
// 584:     # Check the file's type.
// 585:     # @param filetype [Integer] the file type
// 586:     # @raise [FiletypeError] if the file type is unknown
// 587:     # @api private
// 588:     def check_filetype(filetype)
// 589:       raise FiletypeError, filetype unless Headers::MH_FILETYPES.key?(filetype)
// 590:     end
// 591:
// 592:     # All load commands in the file.
// 593:     # @return [Array<LoadCommands::LoadCommand>] an array of load commands
// 594:     # @raise [TruncatedFileError] if the declared load command data is incomplete
// 595:     # @raise [LoadCommandError] if an unknown load command is encountered
// 596:     # @raise [LoadCommandSizeError] if a load command's size is invalid
// 597:     # @api private
// 598:     def populate_load_commands
// 599:       permissive = options.fetch(:permissive, false)
// 600:       offset = header.class.bytesize
// 601:       load_commands_end = offset + sizeofcmds
// 602:       raise TruncatedFileError if load_commands_end > @raw_data.bytesize
// 603:
// 604:       load_commands = []
// 605:       @load_commands_by_type = Hash.new { |h, k| h[k] = [] }
// 606:
// 607:       header.ncmds.times do
// 608:         raise TruncatedFileError if offset + LoadCommands::LoadCommand.bytesize > load_commands_end
// 609:
// 610:         fmt = Utils.specialize_format("L=", endianness)
// 611:         cmd = @raw_data.slice(offset, 4).unpack1(fmt)
// 612:         cmdsize = @raw_data.slice(offset + 4, 4).unpack1(fmt)
// 613:         raise LoadCommandSizeError, cmdsize if cmdsize % 4 != 0 || offset + cmdsize > load_commands_end
// 614:
// 615:         cmd_sym = LoadCommands::LOAD_COMMANDS[cmd]
// 616:
// 617:         raise LoadCommandError, cmd unless cmd_sym || permissive
// 618:
// 619:         # If we're here, then either cmd_sym represents a valid load
// 620:         # command *or* we're in permissive mode.
// 621:         klass = if (klass_str = LoadCommands::LC_STRUCTURES[cmd_sym])
// 622:           LoadCommands.const_get klass_str
// 623:         else
// 624:           LoadCommands::LoadCommand
// 625:         end
// 626:
// 627:         raise LoadCommandSizeError, cmdsize if cmdsize < klass.bytesize
// 628:
// 629:         view = MachOView.new(self, @raw_data, endianness, offset)
// 630:         command = klass.new_from_bin(view)
// 631:
// 632:         load_commands << command
// 633:         @load_commands_by_type[command.type] << command
// 634:         offset += command.cmdsize
// 635:       end
// 636:
// 637:       load_commands
// 638:     end
// 639:
// 640:     # Calculate the segment alignment for the Mach-O. Guesses conservatively.
// 641:     # @return [Integer] the alignment, as a power of 2
// 642:     # @api private
// 643:     def calculate_segment_alignment
// 644:       # special cases: 12 for x86/64/PPC/PP64, 14 for ARM/ARM64
// 645:       return 12 if %i[i386 x86_64 ppc ppc64].include?(cputype)
// 646:       return 14 if %i[arm arm64].include?(cputype)
// 647:
// 648:       cur_align = Sections::MAX_SECT_ALIGN
// 649:
// 650:       segments.each do |segment|
// 651:         if filetype == :object
// 652:           # start with the smallest alignment, and work our way up
// 653:           align = magic32? ? 2 : 3
// 654:           segment.sections.each do |section|
// 655:             align = section.align unless section.align <= align
// 656:           end
// 657:         else
// 658:           align = segment.guess_align
// 659:         end
// 660:         cur_align = align if align < cur_align
// 661:       end
// 662:
// 663:       cur_align
// 664:     end
// 665:
// 666:     # The low file offset (offset to first section data).
// 667:     # @return [Integer] the offset
// 668:     # @api private
// 669:     def low_fileoff
// 670:       offset = @raw_data.size
// 671:
// 672:       segments.each do |seg|
// 673:         offset = seg.fileoff if seg.nsects.zero? && seg.fileoff.positive? &&
// 674:                                 seg.filesize.positive? && seg.fileoff < offset
// 675:
// 676:         seg.sections.each do |sect|
// 677:           next if sect.empty?
// 678:           next if sect.type?(:S_ZEROFILL)
// 679:           next if sect.type?(:S_THREAD_LOCAL_ZEROFILL)
// 680:           next unless sect.offset < offset
// 681:
// 682:           offset = sect.offset
// 683:         end
// 684:       end
// 685:
// 686:       offset
// 687:     end
// 688:
// 689:     # Updates the number of load commands in the raw data.
// 690:     # @param ncmds [Integer] the new number of commands
// 691:     # @return [void]
// 692:     # @api private
// 693:     def update_ncmds(ncmds)
// 694:       fmt = Utils.specialize_format("L=", endianness)
// 695:       ncmds_raw = [ncmds].pack(fmt)
// 696:       @raw_data[16..19] = ncmds_raw
// 697:     end
// 698:
// 699:     # Updates the size of all load commands in the raw data.
// 700:     # @param size [Integer] the new size, in bytes
// 701:     # @return [void]
// 702:     # @api private
// 703:     def update_sizeofcmds(size)
// 704:       fmt = Utils.specialize_format("L=", endianness)
// 705:       size_raw = [size].pack(fmt)
// 706:       @raw_data[20..23] = size_raw
// 707:     end
// 708:   end
// 709: end
