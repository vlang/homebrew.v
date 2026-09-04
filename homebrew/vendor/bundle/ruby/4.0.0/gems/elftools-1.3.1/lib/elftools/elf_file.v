module elftools

import ruby
import encoding.hex
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/elf_file.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ElfIdentification {
pub:
	elf_class int
	endian    ElfEndian
}

pub struct ElfFileSection {
pub:
	header     ElfSectionStruct
	stream     []u8
	name       string
	has_name   bool
	class_name string
}

pub struct ElfFileSegment {
pub:
	header     ElfProgramStruct
	stream     []u8
	class_name string
}

pub struct ElfFile {
pub:
	stream    []u8
	elf_class int
	endian    ElfEndian
pub mut:
	header_loaded bool
	header_cache  ElfHeader
	section_cache map[int]ElfFileSection
	segment_cache map[int]ElfFileSegment
}

pub fn identify_elf(data []u8) !ElfIdentification {
	if data.len < 4 || data[..4] != [u8(0x7f), `E`, `L`, `F`] {
		magic := if data.len >= 4 { data[..4].bytestr() } else { data.bytestr() }
		return error('Invalid magic number ${magic}')
	}
	if data.len < 5 {
		return error('missing EI_CLASS')
	}
	elf_class := match data[4] {
		1 { 32 }
		2 { 64 }
		else {
			return error('Invalid EI_CLASS "\\x${data[4].hex()}"')
		}
	}
	if data.len < 6 {
		return error('missing EI_DATA')
	}
	endian := match data[5] {
		1 { ElfEndian.little }
		2 { ElfEndian.big }
		else {
			return error('Invalid EI_DATA "\\x${data[5].hex()}"')
		}
	}
	return ElfIdentification{
		elf_class: elf_class
		endian: endian
	}
}

pub fn new_elf_file(data []u8) !ElfFile {
	identification := identify_elf(data)!
	return ElfFile{
		stream: data.clone()
		elf_class: identification.elf_class
		endian: identification.endian
		section_cache: map[int]ElfFileSection{}
		segment_cache: map[int]ElfFileSegment{}
	}
}

pub fn (mut file ElfFile) header() !ElfHeader {
	if !file.header_loaded {
		file.header_cache = read_elf_header(file.stream, file.elf_class, file.endian, 0)!
		file.header_loaded = true
	}
	return file.header_cache
}

fn elf_table_offset(base u64, index int, entry_size u16, stream_size int, kind string) !int {
	if index < 0 {
		return error('${kind} index cannot be negative')
	}
	if base > u64(stream_size) {
		return error('${kind} table is outside the stream')
	}
	relative := u64(index) * u64(entry_size)
	if relative > u64(stream_size) - base {
		return error('${kind} header is outside the stream')
	}
	return int(base + relative)
}

fn section_class_name(section_type u32) string {
	return match section_type {
		6 { 'DynamicSection' }
		0 { 'NullSection' }
		7 { 'NoteSection' }
		4, 9 { 'RelocationSection' }
		3 { 'StrTabSection' }
		2, 11 { 'SymTabSection' }
		else { 'Section' }
	}
}

fn segment_class_name(program_type u32) string {
	return match program_type {
		2 { 'DynamicSegment' }
		3 { 'InterpSegment' }
		1 { 'LoadSegment' }
		4 { 'NoteSegment' }
		else { 'Segment' }
	}
}

fn string_at_file_offset(data []u8, offset u64) ?string {
	if offset >= u64(data.len) {
		return none
	}
	mut finish := int(offset)
	for finish < data.len {
		if data[finish] == 0 {
			return data[int(offset)..finish].bytestr()
		}
		finish++
	}
	return none
}

fn (mut file ElfFile) section_name_at(name_offset u32) ?string {
	header := file.header() or { panic(err) }
	if int(header.e_shstrndx) >= int(header.e_shnum) {
		return none
	}
	strtab_header_offset := elf_table_offset(header.e_shoff, int(header.e_shstrndx), header.e_shentsize, file.stream.len, 'section') or { return none }
	strtab := read_elf_section_struct(file.stream, file.elf_class, file.endian, strtab_header_offset) or { return none }
	if strtab.sh_offset > u64(file.stream.len) || u64(name_offset) > u64(file.stream.len) - strtab.sh_offset {
		return none
	}
	return string_at_file_offset(file.stream, strtab.sh_offset + u64(name_offset))
}

pub fn (mut file ElfFile) create_section(index int) !ElfFileSection {
	header := file.header()!
	if index < 0 || index >= int(header.e_shnum) {
		return error('section index ${index} is outside 0..${header.e_shnum}')
	}
	offset := elf_table_offset(header.e_shoff, index, header.e_shentsize, file.stream.len, 'section')!
	section_header := read_elf_section_struct(file.stream, file.elf_class, file.endian, offset)!
	name := file.section_name_at(section_header.sh_name) or { '' }
	return ElfFileSection{
		header: section_header
		stream: file.stream.clone()
		name: name
		has_name: file.section_name_at(section_header.sh_name) != none
		class_name: section_class_name(section_header.sh_type)
	}
}

pub fn (mut file ElfFile) section_at(index int) ?ElfFileSection {
	header := file.header() or { panic(err) }
	if index < 0 || index >= int(header.e_shnum) {
		return none
	}
	if index !in file.section_cache {
		file.section_cache[index] = file.create_section(index) or { panic(err) }
	}
	return file.section_cache[index]
}

pub fn (mut file ElfFile) each_sections(on_section fn(ElfFileSection)) ![]ElfFileSection {
	header := file.header()!
	mut result := []ElfFileSection{cap: int(header.e_shnum)}
	for index in 0 .. int(header.e_shnum) {
		section := file.section_at(index) or { return error('missing section ${index}') }
		result << section
		on_section(section)
	}
	return result
}

fn ignore_file_section(_ ElfFileSection) {}

pub fn (mut file ElfFile) sections() ![]ElfFileSection {
	return file.each_sections(ignore_file_section)
}

pub fn (mut file ElfFile) section_by_name(name string) ?ElfFileSection {
	header := file.header() or { panic(err) }
	for index in 0 .. int(header.e_shnum) {
		section := file.section_at(index) or { panic('missing section ${index}') }
		if section.has_name && section.name == name {
			return section
		}
	}
	return none
}

pub fn (mut file ElfFile) sections_by_type(section_type u32,
	on_section fn(ElfFileSection)) ![]ElfFileSection {
	mut result := []ElfFileSection{}
	for section in file.sections()! {
		if section.header.sh_type == section_type {
			result << section
			on_section(section)
		}
	}
	return result
}

pub fn (mut file ElfFile) strtab_section() ?ElfFileSection {
	header := file.header() or { panic(err) }
	return file.section_at(int(header.e_shstrndx))
}

pub fn (mut file ElfFile) create_segment(index int) !ElfFileSegment {
	header := file.header()!
	if index < 0 || index >= int(header.e_phnum) {
		return error('segment index ${index} is outside 0..${header.e_phnum}')
	}
	offset := elf_table_offset(header.e_phoff, index, header.e_phentsize, file.stream.len, 'segment')!
	program_header := read_elf_program_struct(file.stream, file.elf_class, file.endian, offset)!
	return ElfFileSegment{
		header: program_header
		stream: file.stream.clone()
		class_name: segment_class_name(program_header.p_type)
	}
}

pub fn (mut file ElfFile) segment_at(index int) ?ElfFileSegment {
	header := file.header() or { panic(err) }
	if index < 0 || index >= int(header.e_phnum) {
		return none
	}
	if index !in file.segment_cache {
		file.segment_cache[index] = file.create_segment(index) or { panic(err) }
	}
	return file.segment_cache[index]
}

pub fn (mut file ElfFile) each_segments(on_segment fn(ElfFileSegment)) ![]ElfFileSegment {
	header := file.header()!
	mut result := []ElfFileSegment{cap: int(header.e_phnum)}
	for index in 0 .. int(header.e_phnum) {
		segment := file.segment_at(index) or { return error('missing segment ${index}') }
		result << segment
		on_segment(segment)
	}
	return result
}

fn ignore_file_segment(_ ElfFileSegment) {}

pub fn (mut file ElfFile) segments() ![]ElfFileSegment {
	return file.each_segments(ignore_file_segment)
}

pub fn (mut file ElfFile) segment_by_type(program_type u32) ?ElfFileSegment {
	header := file.header() or { panic(err) }
	for index in 0 .. int(header.e_phnum) {
		segment := file.segment_at(index) or { panic('missing segment ${index}') }
		if segment.header.p_type == program_type {
			return segment
		}
	}
	return none
}

pub fn (mut file ElfFile) segments_by_type(program_type u32,
	on_segment fn(ElfFileSegment)) ![]ElfFileSegment {
	mut result := []ElfFileSegment{}
	for segment in file.segments()! {
		if segment.header.p_type == program_type {
			result << segment
			on_segment(segment)
		}
	}
	return result
}

pub fn (segment ElfFileSegment) vma_in(vma i64, size i64) bool {
	virtual_address := i64(segment.header.p_vaddr)
	align := i64(segment.header.p_align)
	head := virtual_address & -align
	return vma >= head && vma + size <= virtual_address + i64(segment.header.p_memsz)
}

pub fn (segment ElfFileSegment) vma_to_offset(vma i64) i64 {
	return vma - i64(segment.header.p_vaddr) + i64(segment.header.p_offset)
}

pub fn (mut file ElfFile) offset_from_vma(vma i64, size i64) ?i64 {
	for segment in file.segments_by_type(1, ignore_file_segment) or { panic(err) } {
		if segment.vma_in(vma, size) {
			return segment.vma_to_offset(vma)
		}
	}
	return none
}

pub fn (mut file ElfFile) build_id() ?string {
	section := file.section_by_name('.note.gnu.build-id') or { return none }
	if section.header.sh_offset > u64(file.stream.len) {
		return none
	}
	note := create_elf_note(file.stream, int(section.header.sh_offset), file.endian) or {
		return none
	}
	return hex.encode(note.desc, hex.EncodeParams{})
}

pub fn (mut file ElfFile) machine() !string {
	return machine_name(int(file.header()!.e_machine))
}

pub fn (mut file ElfFile) elf_type() !string {
	return elf_type_name(int(file.header()!.e_type))
}

pub fn (mut file ElfFile) patch_header_field(name string, value i64) ! {
	mut header := file.header()!
	header.set_field(name, value)!
	file.header_cache = header
}

pub fn (mut file ElfFile) patch_section_field(index int, name string, value i64) ! {
	mut section := file.section_at(index) or { return error('missing section ${index}') }
	mut header := section.header
	header.set_field(name, value)!
	section = ElfFileSection{
		...section
		header: header
	}
	file.section_cache[index] = section
}

pub fn (mut file ElfFile) patch_segment_field(index int, name string, value i64) ! {
	mut segment := file.segment_at(index) or { return error('missing segment ${index}') }
	mut header := segment.header
	header.set_field(name, value)!
	segment = ElfFileSegment{
		...segment
		header: header
	}
	file.segment_cache[index] = segment
}

pub fn (file &ElfFile) loaded_headers() []ElfStructRecord {
	mut result := []ElfStructRecord{}
	if file.header_loaded {
		result << file.header_cache.state
	}
	for _, section in file.section_cache {
		result << section.header.state
	}
	for _, segment in file.segment_cache {
		result << segment.header.state
	}
	return result
}

pub fn (file &ElfFile) patches() map[int][]u8 {
	mut result := map[int][]u8{}
	for header in file.loaded_headers() {
		for relative_offset, value in header.patches {
			result[header.offset + relative_offset] = value.clone()
		}
	}
	return result
}

pub fn (file &ElfFile) save(filename string) ! {
	mut output := file.stream.clone()
	for position, value in file.patches() {
		if position < 0 || position > output.len || value.len > output.len - position {
			return error('ELF patch at ${position} is outside the stream')
		}
		for index, byte in value {
			output[position + index] = byte
		}
	}
	os.write_file_array(filename, output)!
}

fn elf_header_value(header ElfHeader) ruby.Value {
	mut attributes := struct_record_value(header.state).attributes.clone()
	attributes['magic'] = header.e_ident.magic.bytestr()
	attributes['ei_class'] = header.e_ident.ei_class.str()
	attributes['ei_data'] = header.e_ident.ei_data.str()
	return ruby.structured_value('ELFTools::Structs::ELF_Ehdr', 'ELF_Ehdr', attributes)
}

fn elf_file_section_value(section ElfFileSection) ruby.Value {
	mut attributes := struct_record_value(section.header.state).attributes.clone()
	attributes['name'] = section.name
	attributes['has_name'] = section.has_name.str()
	attributes['stream'] = section.stream.bytestr()
	return ruby.structured_value('ELFTools::Sections::${section.class_name}', section.name, attributes)
}

fn elf_file_segment_value(segment ElfFileSegment) ruby.Value {
	mut attributes := struct_record_value(segment.header.state).attributes.clone()
	attributes['stream'] = segment.stream.bytestr()
	return ruby.structured_value('ELFTools::Segments::${segment.class_name}', segment.class_name, attributes)
}

fn elf_file_value(file ElfFile) ruby.Value {
	return ruby.structured_value('ELFTools::ELFFile', 'ELFFile', {
		'stream':    file.stream.bytestr()
		'elf_class': file.elf_class.str()
		'endian':    file.endian.str()
	})
}

fn elf_file_from_value(value ruby.Value) ElfFile {
	return new_elf_file((value.attribute('stream') or { value.as_string() }).bytes()) or { panic(err) }
}

fn elf_constant_value(prefix string, value ruby.Value) !u32 {
	constants := if prefix == 'PT' {
		{
			'PT_NULL':              u32(0)
			'PT_LOAD':              1
			'PT_DYNAMIC':           2
			'PT_INTERP':            3
			'PT_NOTE':              4
			'PT_SHLIB':             5
			'PT_PHDR':              6
			'PT_TLS':               7
			'PT_LOOS':              0x60000000
			'PT_GNU_EH_FRAME':      0x6474e550
			'PT_GNU_STACK':         0x6474e551
			'PT_GNU_RELRO':         0x6474e552
			'PT_GNU_PROPERTY':      0x6474e553
			'PT_GNU_MBIND_HI':      0x6474f554
			'PT_GNU_MBIND_LO':      0x6474e555
			'PT_OPENBSD_RANDOMIZE': 0x65a3dbe6
			'PT_OPENBSD_WXNEEDED':  0x65a3dbe7
			'PT_OPENBSD_BOOTDATA':  0x65a41be6
			'PT_HIOS':              0x6fffffff
			'PT_LOPROC':            0x70000000
			'PT_ARM_ARCHEXT':       0x70000000
			'PT_ARM_EXIDX':         0x70000001
			'PT_MIPS_REGINFO':      0x70000000
			'PT_MIPS_RTPROC':       0x70000001
			'PT_MIPS_OPTIONS':      0x70000002
			'PT_MIPS_ABIFLAGS':     0x70000003
			'PT_AARCH64_ARCHEXT':   0x70000000
			'PT_AARCH64_UNWIND':    0x70000001
			'PT_S390_PGSTE':        0x70000000
			'PT_HIPROC':            0x7fffffff
		}
	} else {
		{
			'SHT_NULL':                    u32(0)
			'SHT_PROGBITS':                1
			'SHT_SYMTAB':                  2
			'SHT_STRTAB':                  3
			'SHT_RELA':                    4
			'SHT_HASH':                    5
			'SHT_DYNAMIC':                 6
			'SHT_NOTE':                    7
			'SHT_NOBITS':                  8
			'SHT_REL':                     9
			'SHT_SHLIB':                   10
			'SHT_DYNSYM':                  11
			'SHT_INIT_ARRAY':              14
			'SHT_FINI_ARRAY':              15
			'SHT_PREINIT_ARRAY':           16
			'SHT_GROUP':                   17
			'SHT_SYMTAB_SHNDX':            18
			'SHT_RELR':                    19
			'SHT_LOOS':                    0x60000000
			'SHT_GNU_INCREMENTAL_INPUTS':  0x6fff4700
			'SHT_GNU_INCREMENTAL_SYMTAB':  0x6fff4701
			'SHT_GNU_INCREMENTAL_RELOCS':  0x6fff4702
			'SHT_GNU_INCREMENTAL_GOT_PLT': 0x6fff4703
			'SHT_GNU_ATTRIBUTES':          0x6ffffff5
			'SHT_GNU_HASH':                0x6ffffff6
			'SHT_GNU_LIBLIST':             0x6ffffff7
			'SHT_SUNW_VERDEF':             0x6ffffffd
			'SHT_GNU_VERDEF':              0x6ffffffd
			'SHT_SUNW_VERNEED':            0x6ffffffe
			'SHT_GNU_VERNEED':             0x6ffffffe
			'SHT_SUNW_VERSYM':             0x6fffffff
			'SHT_GNU_VERSYM':              0x6fffffff
			'SHT_HIOS':                    0x6fffffff
			'SHT_LOPROC':                  0x70000000
			'SHT_SPARC_GOTDATA':           0x70000000
			'SHT_ARM_EXIDX':               0x70000001
			'SHT_ARM_PREEMPTMAP':          0x70000002
			'SHT_ARM_ATTRIBUTES':          0x70000003
			'SHT_ARM_DEBUGOVERLAY':        0x70000004
			'SHT_ARM_OVERLAYSECTION':      0x70000005
			'SHT_X86_64_UNWIND':           0x70000001
			'SHT_MIPS_LIBLIST':            0x70000000
			'SHT_MIPS_MSYM':               0x70000001
			'SHT_MIPS_CONFLICT':           0x70000002
			'SHT_MIPS_GPTAB':              0x70000003
			'SHT_MIPS_UCODE':              0x70000004
			'SHT_MIPS_DEBUG':              0x70000005
			'SHT_MIPS_REGINFO':            0x70000006
			'SHT_MIPS_PACKAGE':            0x70000007
			'SHT_MIPS_PACKSYM':            0x70000008
			'SHT_MIPS_RELD':               0x70000009
			'SHT_MIPS_IFACE':              0x7000000b
			'SHT_MIPS_CONTENT':            0x7000000c
			'SHT_MIPS_OPTIONS':            0x7000000d
			'SHT_MIPS_SHDR':               0x70000010
			'SHT_MIPS_FDESC':              0x70000011
			'SHT_MIPS_EXTSYM':             0x70000012
			'SHT_MIPS_DENSE':              0x70000013
			'SHT_MIPS_PDESC':              0x70000014
			'SHT_MIPS_LOCSYM':             0x70000015
			'SHT_MIPS_AUXSYM':             0x70000016
			'SHT_MIPS_OPTSYM':             0x70000017
			'SHT_MIPS_LOCSTR':             0x70000018
			'SHT_MIPS_LINE':               0x70000019
			'SHT_MIPS_RFDESC':             0x7000001a
			'SHT_MIPS_DELTASYM':           0x7000001b
			'SHT_MIPS_DELTAINST':          0x7000001c
			'SHT_MIPS_DELTACLASS':         0x7000001d
			'SHT_MIPS_DWARF':              0x7000001e
			'SHT_MIPS_DELTADECL':          0x7000001f
			'SHT_MIPS_SYMBOL_LIB':         0x70000020
			'SHT_MIPS_EVENTS':             0x70000021
			'SHT_MIPS_TRANSLATE':          0x70000022
			'SHT_MIPS_PIXIE':              0x70000023
			'SHT_MIPS_XLATE':              0x70000024
			'SHT_MIPS_XLATE_DEBUG':        0x70000025
			'SHT_MIPS_WHIRL':              0x70000026
			'SHT_MIPS_EH_REGION':          0x70000027
			'SHT_MIPS_PDR_EXCEPTION':      0x70000029
			'SHT_MIPS_ABIFLAGS':           0x7000002a
			'SHT_MIPS_XHASH':              0x7000002b
			'SHT_AARCH64_ATTRIBUTES':      0x70000003
			'SHT_CSKY_ATTRIBUTES':         0x70000001
			'SHT_ORDERED':                 0x7fffffff
			'SHT_HIPROC':                  0x7fffffff
			'SHT_LOUSER':                  0x80000000
			'SHT_HIUSER':                  0xffffffff
		}
	}
	if value.type_name == 'Integer' {
		integer := value.as_int()!
		if integer < 0 || integer > 0xffffffff || u32(integer) !in constants.values() {
			return error('No constants in Constants::${prefix} is ${integer}')
		}
		return u32(integer)
	}
	mut name := value.as_string().trim_left(':').to_upper()
	if !name.starts_with('${prefix}_') {
		name = '${prefix}_${name}'
	}
	return constants[name] or { return error('No constants in Constants::${prefix} named "${name}"') }
}

// Ruby attr_reader `attr_reader :stream` at line 13.
pub fn ruby_elf_file_l13_d1_stream(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#stream requires a receiver') }
	return ruby.string_value(elf_file_from_value(args[0]).stream.bytestr())
}

// Ruby attr_reader `attr_reader :elf_class` at line 14.
pub fn ruby_elf_file_l14_d2_elf_class(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#elf_class requires a receiver') }
	return ruby.int_value(elf_file_from_value(args[0]).elf_class)
}

// Ruby attr_reader `attr_reader :endian` at line 15.
pub fn ruby_elf_file_l15_d3_endian(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#endian requires a receiver') }
	return ruby.string_value(':${elf_file_from_value(args[0]).endian}')
}

// Ruby method `initialize(stream)` at line 24.
pub fn ruby_elf_file_l24_d4_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#initialize requires a stream') }
	return elf_file_value(new_elf_file(args[0].as_string().bytes()) or { panic(err) })
}

// Ruby method `header` at line 35.
pub fn ruby_elf_file_l35_d5_header(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#header requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return elf_header_value(file.header() or { panic(err) })
}

// Ruby method `build_id` at line 52.
pub fn ruby_elf_file_l52_d6_build_id(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#build_id requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return if build_id := file.build_id() {
		ruby.string_value(build_id)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `machine` at line 71.
pub fn ruby_elf_file_l71_d7_machine(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#machine requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.string_value(file.machine() or { panic(err) })
}

// Ruby method `elf_type` at line 82.
pub fn ruby_elf_file_l82_d8_elf_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#elf_type requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.string_value(file.elf_type() or { panic(err) })
}

// Ruby method `num_sections` at line 93.
pub fn ruby_elf_file_l93_d9_num_sections(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#num_sections requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.int_value(file.header() or { panic(err) }.e_shnum)
}

// Ruby method `section_by_name(name)` at line 107.
pub fn ruby_elf_file_l107_d10_section_by_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#section_by_name requires a receiver and name') }
	mut file := elf_file_from_value(args[0])
	section := file.section_by_name(args[1].as_string()) or { return ruby.object_value('NilClass', 'nil') }
	return elf_file_section_value(section)
}

// Ruby method `each_sections(&block)` at line 122.
pub fn ruby_elf_file_l122_d11_each_sections(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#each_sections requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.array_value(file.sections() or { panic(err) }.map(elf_file_section_value(it)))
}

// Ruby method `sections` at line 133.
pub fn ruby_elf_file_l133_d12_sections(args ...ruby.Value) ruby.Value {
	return ruby_elf_file_l122_d11_each_sections(...args)
}

// Ruby method `section_at(n)` at line 144.
pub fn ruby_elf_file_l144_d13_section_at(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#section_at requires a receiver and index') }
	mut file := elf_file_from_value(args[0])
	section := file.section_at(int(args[1].as_int() or { panic(err) })) or { return ruby.object_value('NilClass', 'nil') }
	return elf_file_section_value(section)
}

// Ruby method `sections_by_type(type, &block)` at line 163.
pub fn ruby_elf_file_l163_d14_sections_by_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#sections_by_type requires a receiver and type') }
	mut file := elf_file_from_value(args[0])
	section_type := elf_constant_value('SHT', args[1]) or { panic(err) }
	return ruby.array_value(file.sections_by_type(section_type, ignore_file_section) or {
		panic(err)
	}.map(elf_file_section_value(it)))
}

// Ruby method `strtab_section` at line 173.
pub fn ruby_elf_file_l173_d15_strtab_section(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#strtab_section requires a receiver') }
	mut file := elf_file_from_value(args[0])
	section := file.strtab_section() or { return ruby.object_value('NilClass', 'nil') }
	return elf_file_section_value(section)
}

// Ruby method `num_segments` at line 181.
pub fn ruby_elf_file_l181_d16_num_segments(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#num_segments requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.int_value(file.header() or { panic(err) }.e_phnum)
}

// Ruby method `each_segments(&block)` at line 195.
pub fn ruby_elf_file_l195_d17_each_segments(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#each_segments requires a receiver') }
	mut file := elf_file_from_value(args[0])
	return ruby.array_value(file.segments() or { panic(err) }.map(elf_file_segment_value(it)))
}

// Ruby method `segments` at line 206.
pub fn ruby_elf_file_l206_d18_segments(args ...ruby.Value) ruby.Value {
	return ruby_elf_file_l195_d17_each_segments(...args)
}

// Ruby method `segment_by_type(type)` at line 251.
pub fn ruby_elf_file_l251_d19_segment_by_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#segment_by_type requires a receiver and type') }
	mut file := elf_file_from_value(args[0])
	program_type := elf_constant_value('PT', args[1]) or { panic(err) }
	segment := file.segment_by_type(program_type) or { return ruby.object_value('NilClass', 'nil') }
	return elf_file_segment_value(segment)
}

// Ruby method `segments_by_type(type, &block)` at line 266.
pub fn ruby_elf_file_l266_d20_segments_by_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#segments_by_type requires a receiver and type') }
	mut file := elf_file_from_value(args[0])
	program_type := elf_constant_value('PT', args[1]) or { panic(err) }
	return ruby.array_value(file.segments_by_type(program_type, ignore_file_segment) or {
		panic(err)
	}.map(elf_file_segment_value(it)))
}

// Ruby method `segment_at(n)` at line 278.
pub fn ruby_elf_file_l278_d21_segment_at(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#segment_at requires a receiver and index') }
	mut file := elf_file_from_value(args[0])
	segment := file.segment_at(int(args[1].as_int() or { panic(err) })) or { return ruby.object_value('NilClass', 'nil') }
	return elf_file_segment_value(segment)
}

// Ruby method `offset_from_vma(vma, size = 1)` at line 293.
pub fn ruby_elf_file_l293_d22_offset_from_vma(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#offset_from_vma requires a receiver and address') }
	mut file := elf_file_from_value(args[0])
	size := if args.len > 2 { args[2].as_int() or { panic(err) } } else { i64(1) }
	offset := file.offset_from_vma(args[1].as_int() or { panic(err) }, size) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.int_value(offset)
}

// Ruby method `patches` at line 301.
pub fn ruby_elf_file_l301_d23_patches(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#patches requires a receiver') }
	file := elf_file_from_value(args[0])
	mut result := map[string]ruby.Value{}
	for position, value in file.patches() {
		result[position.str()] = ruby.string_value(value.bytestr())
	}
	return ruby.map_value(result)
}

// Ruby method `save(filename)` at line 315.
pub fn ruby_elf_file_l315_d24_save(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#save requires a receiver and filename') }
	file := elf_file_from_value(args[0])
	file.save(args[1].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `loaded_headers` at line 327.
pub fn ruby_elf_file_l327_d25_loaded_headers(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#loaded_headers requires a receiver') }
	mut file := elf_file_from_value(args[0])
	file.header() or { panic(err) }
	return ruby.array_value(file.loaded_headers().map(struct_record_value(it)))
}

// Ruby method `identify` at line 339.
pub fn ruby_elf_file_l339_d26_identify(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('ELFFile#identify requires a stream or receiver') }
	data := if stream := args[0].attribute('stream') {
		stream.bytes()
	} else {
		args[0].as_string().bytes()
	}
	return elf_file_value(new_elf_file(data) or { panic(err) })
}

// Ruby method `create_section(n)` at line 359.
pub fn ruby_elf_file_l359_d27_create_section(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#create_section requires a receiver and index') }
	mut file := elf_file_from_value(args[0])
	return elf_file_section_value(file.create_section(int(args[1].as_int() or { panic(err) })) or {
		panic(err)
	})
}

// Ruby method `create_segment(n)` at line 370.
pub fn ruby_elf_file_l370_d28_create_segment(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('ELFFile#create_segment requires a receiver and index') }
	mut file := elf_file_from_value(args[0])
	return elf_file_segment_value(file.create_segment(int(args[1].as_int() or { panic(err) })) or {
		panic(err)
	})
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/constants'
// 4: require 'elftools/exceptions'
// 5: require 'elftools/lazy_array'
// 6: require 'elftools/sections/sections'
// 7: require 'elftools/segments/segments'
// 8: require 'elftools/structs'
// 9:
// 10: module ELFTools
// 11:   # The main class for using elftools.
// 12:   class ELFFile
// 13:     attr_reader :stream # @return [#pos=, #read] The +File+ object.
// 14:     attr_reader :elf_class # @return [Integer] 32 or 64.
// 15:     attr_reader :endian # @return [Symbol] +:little+ or +:big+.
// 16:
// 17:     # Instantiate an {ELFFile} object.
// 18:     #
// 19:     # @param [#pos=, #read] stream
// 20:     #   The +File+ object to be fetch information from.
// 21:     # @example
// 22:     #   ELFFile.new(File.open('/bin/cat'))
// 23:     #   #=> #<ELFTools::ELFFile:0x00564b106c32a0 @elf_class=64, @endian=:little, @stream=#<File:/bin/cat>>
// 24:     def initialize(stream)
// 25:       @stream = stream
// 26:       # always set binmode if stream is an IO object.
// 27:       @stream.binmode if @stream.respond_to?(:binmode)
// 28:       identify # fetch the most basic information
// 29:     end
// 30:
// 31:     # Return the file header.
// 32:     #
// 33:     # Lazy loading.
// 34:     # @return [ELFTools::Structs::ELF_Ehdr] The header.
// 35:     def header
// 36:       return @header if defined?(@header)
// 37:
// 38:       stream.pos = 0
// 39:       @header = Structs::ELF_Ehdr.new(endian:, offset: stream.pos)
// 40:       @header.elf_class = elf_class
// 41:       @header.read(stream)
// 42:     end
// 43:
// 44:     # Return the BuildID of ELF.
// 45:     # @return [String, nil]
// 46:     #   BuildID in hex form will be returned.
// 47:     #   +nil+ is returned if the .note.gnu.build-id section
// 48:     #   is not found.
// 49:     # @example
// 50:     #   elf.build_id
// 51:     #   #=> '73ab62cb7bc9959ce053c2b711322158708cdc07'
// 52:     def build_id
// 53:       section = section_by_name('.note.gnu.build-id')
// 54:       return nil if section.nil?
// 55:
// 56:       note = section.notes.first
// 57:       return nil if note.nil?
// 58:
// 59:       note.desc.unpack1('H*')
// 60:     end
// 61:
// 62:     # Get machine architecture.
// 63:     #
// 64:     # Mappings of architecture can be found
// 65:     # in {ELFTools::Constants::EM.mapping}.
// 66:     # @return [String]
// 67:     #   Name of architecture.
// 68:     # @example
// 69:     #   elf.machine
// 70:     #   #=> 'Advanced Micro Devices X86-64'
// 71:     def machine
// 72:       ELFTools::Constants::EM.mapping(header.e_machine)
// 73:     end
// 74:
// 75:     # Return the ELF type according to +e_type+.
// 76:     # @return [String] Type in string format.
// 77:     # @example
// 78:     #   ELFFile.new(File.open('spec/files/libc.so.6')).elf_type
// 79:     #   #=> 'DYN'
// 80:     #   ELFFile.new(File.open('spec/files/amd64.elf')).elf_type
// 81:     #   #=> 'EXEC'
// 82:     def elf_type
// 83:       ELFTools::Constants::ET.mapping(header.e_type)
// 84:     end
// 85:
// 86:     #========= method about sections
// 87:
// 88:     # Number of sections in this file.
// 89:     # @return [Integer] The desired number.
// 90:     # @example
// 91:     #   elf.num_sections
// 92:     #   #=> 29
// 93:     def num_sections
// 94:       header.e_shnum
// 95:     end
// 96:
// 97:     # Acquire the section named as +name+.
// 98:     # @param [String] name The desired section name.
// 99:     # @return [ELFTools::Sections::Section, nil] The target section.
// 100:     # @example
// 101:     #   elf.section_by_name('.note.gnu.build-id')
// 102:     #   #=> #<ELFTools::Sections::Section:0x005647b1282428>
// 103:     #   elf.section_by_name('')
// 104:     #   #=> #<ELFTools::Sections::NullSection:0x005647b11da110>
// 105:     #   elf.section_by_name('no such section')
// 106:     #   #=> nil
// 107:     def section_by_name(name)
// 108:       each_sections.find { |sec| sec.name == name }
// 109:     end
// 110:
// 111:     # Iterate all sections.
// 112:     #
// 113:     # All sections are lazy loading, the section
// 114:     # only be created whenever accessing it.
// 115:     # This method is useful for {#section_by_name}
// 116:     # since not all sections need to be created.
// 117:     # @yieldparam [ELFTools::Sections::Section] section A section.
// 118:     # @yieldreturn [void]
// 119:     # @return [Enumerator<ELFTools::Sections::Section>, Array<ELFTools::Sections::Section>]
// 120:     #   As +Array#each+, if block is not given, a enumerator will be returned,
// 121:     #   otherwise, the whole sections will be returned.
// 122:     def each_sections(&block)
// 123:       return enum_for(:each_sections) unless block_given?
// 124:
// 125:       Array.new(num_sections) do |i|
// 126:         section_at(i).tap(&block)
// 127:       end
// 128:     end
// 129:
// 130:     # Simply use {#sections} to get all sections.
// 131:     # @return [Array<ELFTools::Sections::Section>]
// 132:     #   Whole sections.
// 133:     def sections
// 134:       each_sections.to_a
// 135:     end
// 136:
// 137:     # Acquire the +n+-th section, 0-based.
// 138:     #
// 139:     # Sections are lazy loaded.
// 140:     # @param [Integer] n The index.
// 141:     # @return [ELFTools::Sections::Section, nil]
// 142:     #   The target section.
// 143:     #   If +n+ is out of bound, +nil+ is returned.
// 144:     def section_at(n)
// 145:       @sections ||= LazyArray.new(num_sections, &method(:create_section))
// 146:       @sections[n]
// 147:     end
// 148:
// 149:     # Fetch all sections with specific type.
// 150:     #
// 151:     # The available types are listed in {ELFTools::Constants::PT}.
// 152:     # This method accept giving block.
// 153:     # @param [Integer, Symbol, String] type
// 154:     #   The type needed, similar format as {#segment_by_type}.
// 155:     # @yieldparam [ELFTools::Sections::Section] section A section in specific type.
// 156:     # @yieldreturn [void]
// 157:     # @return [Array<ELFTools::Sections::section>] The target sections.
// 158:     # @example
// 159:     #   elf = ELFTools::ELFFile.new(File.open('spec/files/amd64.elf'))
// 160:     #   elf.sections_by_type(:rela)
// 161:     #   #=> [#<ELFTools::Sections::RelocationSection:0x00563cd3219970>,
// 162:     #   #    #<ELFTools::Sections::RelocationSection:0x00563cd3b89d70>]
// 163:     def sections_by_type(type, &block)
// 164:       type = Util.to_constant(Constants::SHT, type)
// 165:       Util.select_by_type(each_sections, type, &block)
// 166:     end
// 167:
// 168:     # Get the string table section.
// 169:     #
// 170:     # This section is acquired by using the +e_shstrndx+
// 171:     # in ELF header.
// 172:     # @return [ELFTools::Sections::StrTabSection] The desired section.
// 173:     def strtab_section
// 174:       section_at(header.e_shstrndx)
// 175:     end
// 176:
// 177:     #========= method about segments
// 178:
// 179:     # Number of segments in this file.
// 180:     # @return [Integer] The desited number.
// 181:     def num_segments
// 182:       header.e_phnum
// 183:     end
// 184:
// 185:     # Iterate all segments.
// 186:     #
// 187:     # All segments are lazy loading, the segment
// 188:     # only be created whenever accessing it.
// 189:     # This method is useful for {#segment_by_type}
// 190:     # since not all segments need to be created.
// 191:     # @yieldparam [ELFTools::Segments::Segment] segment A segment.
// 192:     # @yieldreturn [void]
// 193:     # @return [Array<ELFTools::Segments::Segment>]
// 194:     #   Whole segments will be returned.
// 195:     def each_segments(&block)
// 196:       return enum_for(:each_segments) unless block_given?
// 197:
// 198:       Array.new(num_segments) do |i|
// 199:         segment_at(i).tap(&block)
// 200:       end
// 201:     end
// 202:
// 203:     # Simply use {#segments} to get all segments.
// 204:     # @return [Array<ELFTools::Segments::Segment>]
// 205:     #   Whole segments.
// 206:     def segments
// 207:       each_segments.to_a
// 208:     end
// 209:
// 210:     # Get the first segment with +p_type=type+.
// 211:     # The available types are listed in {ELFTools::Constants::PT}.
// 212:     #
// 213:     # @note
// 214:     #   This method will return the first segment found,
// 215:     #   to found all segments with specific type you can use {#segments_by_type}.
// 216:     # @param [Integer, Symbol, String] type
// 217:     #   See examples for clear usage.
// 218:     # @return [ELFTools::Segments::Segment] The target segment.
// 219:     # @example
// 220:     #   # type as an integer
// 221:     #   elf.segment_by_type(ELFTools::Constants::PT_NOTE)
// 222:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 223:     #
// 224:     #   elf.segment_by_type(4) # PT_NOTE
// 225:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 226:     #
// 227:     #   # type as a symbol
// 228:     #   elf.segment_by_type(:PT_NOTE)
// 229:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 230:     #
// 231:     #   # you can do this
// 232:     #   elf.segment_by_type(:note) # will be transformed into `PT_NOTE`
// 233:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 234:     #
// 235:     #   # type as a string
// 236:     #   elf.segment_by_type('PT_NOTE')
// 237:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 238:     #
// 239:     #   # this is ok
// 240:     #   elf.segment_by_type('note') # will be transformed into `PT_NOTE`
// 241:     #   #=>  #<ELFTools::Segments::NoteSegment:0x005629dda1e4f8>
// 242:     # @example
// 243:     #   elf.segment_by_type(1337)
// 244:     #   # ArgumentError: No constants in Constants::PT is 1337
// 245:     #
// 246:     #   elf.segment_by_type('oao')
// 247:     #   # ArgumentError: No constants in Constants::PT named "PT_OAO"
// 248:     # @example
// 249:     #   elf.segment_by_type(0)
// 250:     #   #=> nil # no such segment exists
// 251:     def segment_by_type(type)
// 252:       type = Util.to_constant(Constants::PT, type)
// 253:       each_segments.find { |seg| seg.header.p_type == type }
// 254:     end
// 255:
// 256:     # Fetch all segments with specific type.
// 257:     #
// 258:     # If you want to find only one segment,
// 259:     # use {#segment_by_type} instead.
// 260:     # This method accept giving block.
// 261:     # @param [Integer, Symbol, String] type
// 262:     #   The type needed, same format as {#segment_by_type}.
// 263:     # @yieldparam [ELFTools::Segments::Segment] segment A segment in specific type.
// 264:     # @yieldreturn [void]
// 265:     # @return [Array<ELFTools::Segments::Segment>] The target segments.
// 266:     def segments_by_type(type, &block)
// 267:       type = Util.to_constant(Constants::PT, type)
// 268:       Util.select_by_type(each_segments, type, &block)
// 269:     end
// 270:
// 271:     # Acquire the +n+-th segment, 0-based.
// 272:     #
// 273:     # Segments are lazy loaded.
// 274:     # @param [Integer] n The index.
// 275:     # @return [ELFTools::Segments::Segment, nil]
// 276:     #   The target segment.
// 277:     #   If +n+ is out of bound, +nil+ is returned.
// 278:     def segment_at(n)
// 279:       @segments ||= LazyArray.new(num_segments, &method(:create_segment))
// 280:       @segments[n]
// 281:     end
// 282:
// 283:     # Get the offset related to file, given virtual memory address.
// 284:     #
// 285:     # This method should work no matter ELF is a PIE or not.
// 286:     # This method refers from (actually equals to) binutils/readelf.c#offset_from_vma.
// 287:     # @param [Integer] vma The virtual address to be queried.
// 288:     # @return [Integer] Related file offset.
// 289:     # @example
// 290:     #   elf = ELFTools::ELFFile.new(File.open('/bin/cat'))
// 291:     #   elf.offset_from_vma(0x401337)
// 292:     #   #=> 4919 # 0x1337
// 293:     def offset_from_vma(vma, size = 1)
// 294:       segments_by_type(:load) do |seg|
// 295:         return seg.vma_to_offset(vma) if seg.vma_in?(vma, size)
// 296:       end
// 297:     end
// 298:
// 299:     # The patch status.
// 300:     # @return [Hash{Integer => String}]
// 301:     def patches
// 302:       patch = {}
// 303:       loaded_headers.each do |header|
// 304:         header.patches.each do |key, val|
// 305:           patch[key + header.offset] = val
// 306:         end
// 307:       end
// 308:       patch
// 309:     end
// 310:
// 311:     # Apply patches and save as +filename+.
// 312:     #
// 313:     # @param [String] filename
// 314:     # @return [void]
// 315:     def save(filename)
// 316:       stream.pos = 0
// 317:       all = stream.read.force_encoding('ascii-8bit')
// 318:       patches.each do |pos, val|
// 319:         all[pos, val.size] = val
// 320:       end
// 321:       File.binwrite(filename, all)
// 322:     end
// 323:
// 324:     private
// 325:
// 326:     # bad idea..
// 327:     def loaded_headers
// 328:       explore = lambda do |obj|
// 329:         return obj if obj.is_a?(::ELFTools::Structs::ELFStruct)
// 330:         return obj.map(&explore) if obj.is_a?(Array)
// 331:
// 332:         obj.instance_variables.map do |s|
// 333:           explore.call(obj.instance_variable_get(s))
// 334:         end
// 335:       end
// 336:       explore.call(self).flatten
// 337:     end
// 338:
// 339:     def identify
// 340:       stream.pos = 0
// 341:       magic = stream.read(4)
// 342:       raise ELFMagicError, "Invalid magic number #{magic.inspect}" unless magic == Constants::ELFMAG
// 343:
// 344:       ei_class = stream.read(1).ord
// 345:       @elf_class = {
// 346:         1 => 32,
// 347:         2 => 64
// 348:       }[ei_class]
// 349:       raise ELFClassError, format('Invalid EI_CLASS "\x%02x"', ei_class) if elf_class.nil?
// 350:
// 351:       ei_data = stream.read(1).ord
// 352:       @endian = {
// 353:         1 => :little,
// 354:         2 => :big
// 355:       }[ei_data]
// 356:       raise ELFDataError, format('Invalid EI_DATA "\x%02x"', ei_data) if endian.nil?
// 357:     end
// 358:
// 359:     def create_section(n)
// 360:       stream.pos = header.e_shoff + n * header.e_shentsize
// 361:       shdr = Structs::ELF_Shdr.new(endian:, offset: stream.pos)
// 362:       shdr.elf_class = elf_class
// 363:       shdr.read(stream)
// 364:       Sections::Section.create(shdr, stream,
// 365:                                offset_from_vma: method(:offset_from_vma),
// 366:                                strtab: method(:strtab_section),
// 367:                                section_at: method(:section_at))
// 368:     end
// 369:
// 370:     def create_segment(n)
// 371:       stream.pos = header.e_phoff + n * header.e_phentsize
// 372:       phdr = Structs::ELF_Phdr[elf_class].new(endian:, offset: stream.pos)
// 373:       phdr.elf_class = elf_class
// 374:       Segments::Segment.create(phdr.read(stream), stream, offset_from_vma: method(:offset_from_vma))
// 375:     end
// 376:   end
// 377: end
