module macho

import brew_runtime
import encoding.binary
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/fat_file.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FatFileModificationOptions {
pub:
	strict bool = true
	uniq   bool
	last   bool
}

@[heap]
pub struct FatFile {
pub mut:
	filename     string
	has_filename bool
	options      MachoFileOptions
	header       &MachoHeaderRecord = unsafe { nil }
	fat_archs    []&MachoHeaderRecord
	machos       []&MachoFile
	raw_data     []u8
}

fn fat_file_options_value(options MachoFileOptions) brew_runtime.Value {
	return macho_file_options_value(options)
}

fn fat_file_modification_options_from_value(value brew_runtime.Value) FatFileModificationOptions {
	values := value.as_map() or { return FatFileModificationOptions{} }
	return FatFileModificationOptions{
		strict: (values['strict'] or { brew_runtime.bool_value(true) }).as_bool() or { true }
		uniq: (values['uniq'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		last: (values['last'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
	}
}

fn fat_file_boundary(file &FatFile) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::FatFile', '#<MachO::FatFile>', {
		'fat_file_address': u64(voidptr(file)).str()
	})
}

fn fat_file_from_args(args []brew_runtime.Value) &FatFile {
	if args.len == 0 {
		panic('FatFile method requires a receiver')
	}
	address := (args[0].attribute('fat_file_address') or {
		panic('${args[0].type_name} has no translated FatFile state')
	}).u64()
	return unsafe { &FatFile(voidptr(address)) }
}

fn fat_file_u32(data []u8, offset int) !u32 {
	if offset < 0 || offset + 4 > data.len {
		return truncated_file_error()
	}
	return binary.big_endian_u32_at(data, offset)
}

fn fat_file_u64(data []u8, offset int) !u64 {
	if offset < 0 || offset + 8 > data.len {
		return truncated_file_error()
	}
	return binary.big_endian_u64_at(data, offset)
}

fn fat_arch_bytesize(fat64 bool) int {
	return if fat64 { 32 } else { 20 }
}

fn fat_alignment(align u32) !i64 {
	if align > 62 {
		return error('Fat architecture alignment exponent ${align} is too large')
	}
	return i64(u64(1) << align)
}

fn parse_fat_arch(data []u8, offset int, fat64 bool) !&MachoHeaderRecord {
	bytesize := fat_arch_bytesize(fat64)
	if offset < 0 || offset + bytesize > data.len {
		return truncated_file_error()
	}
	cputype := fat_file_u32(data, offset)!
	cpusubtype := fat_file_u32(data, offset + 4)!
	if fat64 {
		return new_fat_arch64(cputype, cpusubtype, fat_file_u64(data, offset + 8)!, fat_file_u64(data, offset + 16)!, fat_file_u32(data, offset + 24)!, fat_file_u32(data, offset + 28)!)
	}
	return new_fat_arch(cputype, cpusubtype, fat_file_u32(data, offset + 8)!, fat_file_u32(data, offset + 12)!, fat_file_u32(data, offset + 16)!)
}

pub fn new_fat_file_from_machos(machos []&MachoFile, fat64 bool) !&FatFile {
	if machos.len == 0 {
		return error('expected at least one Mach-O')
	}
	mut sorted := machos.clone()
	for index := 1; index < sorted.len; index++ {
		mut cursor := index
		for cursor > 0 && sorted[cursor - 1].calculate_segment_alignment() > sorted[cursor].calculate_segment_alignment() {
			sorted[cursor - 1], sorted[cursor] = sorted[cursor], sorted[cursor - 1]
			cursor--
		}
	}
	header := new_fat_header(if fat64 { fat_magic_64 } else { fat_magic }, u32(sorted.len))
	mut data := header.serialize()!
	mut offset := i64(8 + sorted.len * fat_arch_bytesize(fat64))
	mut pads := []int{cap: sorted.len}
	for macho in sorted {
		alignment := fat_alignment(u32(macho.calculate_segment_alignment()))!
		macho_offset := macho_round(offset, alignment)
		if !fat64 && macho_offset > i64(0xffff_ffff) {
			return fat_arch_offset_overflow_error(macho_offset)
		}
		pads << int(macho_padding_for(offset, alignment))
		arch := if fat64 {
			new_fat_arch64(macho.header.cputype, macho.header.cpusubtype, u64(macho_offset), u64(macho.raw_data.len), u32(macho.calculate_segment_alignment()), 0)
		} else {
			new_fat_arch(macho.header.cputype, macho.header.cpusubtype, u64(macho_offset), u64(macho.raw_data.len), u32(macho.calculate_segment_alignment()))
		}
		data << arch.serialize()!
		offset += macho.raw_data.len + pads.last()
	}
	for index, macho in sorted {
		data << []u8{len: pads[index]}
		data << macho.serialize()
	}
	return new_fat_file_from_bin(data, MachoFileOptions{})
}

pub fn new_fat_file_from_bin(data []u8, options MachoFileOptions) !&FatFile {
	mut file := &FatFile{
		options: options
		raw_data: data.clone()
	}
	file.populate_fields()!
	return file
}

pub fn new_fat_file(filename string, options MachoFileOptions) !&FatFile {
	if !os.is_file(filename) {
		return error('${filename}: no such file')
	}
	data := os.read_bytes(filename)!
	mut file := new_fat_file_from_bin(data, options)!
	file.filename = filename
	file.has_filename = true
	return file
}

pub fn (file &FatFile) serialize() []u8 {
	return file.raw_data.clone()
}

pub fn (file &FatFile) magic_string() string {
	return header_magic_symbol(file.header.magic)
}

pub fn (mut file FatFile) populate_fields() ! {
	file.header = file.populate_fat_header()!
	file.fat_archs = file.populate_fat_archs()!
	file.machos = file.populate_machos()!
}

pub fn (file &FatFile) populate_fat_header() !&MachoHeaderRecord {
	if file.raw_data.len < 8 {
		return truncated_file_error()
	}
	header := new_fat_header(fat_file_u32(file.raw_data, 0)!, fat_file_u32(file.raw_data, 4)!)
	if !macho_magic(header.magic) {
		return magic_error(header.magic)
	}
	if !macho_fat_magic(header.magic) {
		return macho_binary_error()
	}
	if header.nfat_arch > 30 {
		return java_class_file_error()
	}
	if header.nfat_arch == 0 {
		return zero_architecture_error()
	}
	return header
}

pub fn (file &FatFile) populate_fat_archs() ![]&MachoHeaderRecord {
	fat64 := macho_fat_magic64(file.header.magic)
	bytesize := fat_arch_bytesize(fat64)
	table_size := u64(8) + u64(file.header.nfat_arch) * u64(bytesize)
	if table_size > u64(file.raw_data.len) {
		return truncated_file_error()
	}
	mut archs := []&MachoHeaderRecord{cap: int(file.header.nfat_arch)}
	for index in 0 .. int(file.header.nfat_arch) {
		archs << parse_fat_arch(file.raw_data, 8 + index * bytesize, fat64)!
	}
	return archs
}

pub fn (file &FatFile) populate_machos() ![]&MachoFile {
	mut machos := []&MachoFile{cap: file.fat_archs.len}
	for arch in file.fat_archs {
		if arch.offset > u64(file.raw_data.len) || arch.size > u64(file.raw_data.len) - arch.offset {
			return truncated_file_error()
		}
		start := int(arch.offset)
		end := start + int(arch.size)
		macho := new_macho_file_from_bin(file.raw_data[start..end], file.options)!
		machos << macho
		if macho.header.cputype != arch.cputype || macho.header.cpusubtype != arch.cpusubtype {
			return cpu_type_mismatch_error(arch.cputype, arch.cpusubtype, macho.header.cputype, macho.header.cpusubtype)
		}
	}
	return machos
}

pub fn (file &FatFile) canonical_macho() &MachoFile {
	return file.machos[0]
}

pub fn (file &FatFile) dylib_load_commands() []&LoadCommandRecord {
	mut commands := []&LoadCommandRecord{}
	for macho in file.machos {
		commands << macho.dylib_load_commands()
	}
	return commands
}

pub fn (file &FatFile) linked_dylibs() []string {
	mut dylibs := []string{}
	for macho in file.machos {
		for dylib in macho.linked_dylibs() {
			if dylib !in dylibs {
				dylibs << dylib
			}
		}
	}
	return dylibs
}

pub fn (file &FatFile) rpaths() []string {
	mut paths := []string{}
	for macho in file.machos {
		for path in macho.rpaths() {
			if path !in paths {
				paths << path
			}
		}
	}
	return paths
}

fn fat_file_recoverable_error(message string) bool {
	return message.starts_with('Mach-O dylib is missing LC_ID_DYLIB') || message.starts_with('Unknown linked dylib:') || message.starts_with('Unknown rpath:') || message.starts_with('Rpath already exists:')
}

fn fat_file_slice_error(message string, index int) &MachoErrorInfo {
	mut error_info := new_macho_error(.recoverable_modification, message)
	error_info.set_macho_slice(index)
	return error_info
}

pub fn (mut file FatFile) each_macho(options FatFileModificationOptions, operation fn(mut MachoFile) !) ! {
	mut errors := []&MachoErrorInfo{}
	for index, _ in file.machos {
		operation(mut file.machos[index]) or {
			if !fat_file_recoverable_error(err.msg()) {
				return err
			}
			slice_error := fat_file_slice_error(err.msg(), index)
			if options.strict {
				return slice_error
			}
			errors << slice_error
		}
	}
	if errors.len == file.machos.len {
		return errors[0]
	}
}

pub fn (mut file FatFile) repopulate_raw_machos() ! {
	for index, macho in file.machos {
		arch := file.fat_archs[index]
		start := int(arch.offset)
		end := start + int(arch.size)
		mut replaced := []u8{cap: file.raw_data.len - int(arch.size) + macho.raw_data.len}
		replaced << file.raw_data[..start]
		replaced << macho.serialize()
		replaced << file.raw_data[end..]
		file.raw_data = replaced
	}
}

pub fn (mut file FatFile) repopulate_resized_raw_machos() ! {
	fat64 := macho_fat_magic64(file.header.magic)
	arch_bytesize := fat_arch_bytesize(fat64)
	header_size := 8 + file.fat_archs.len * arch_bytesize
	if header_size > file.raw_data.len {
		return truncated_file_error()
	}
	mut header_data := file.raw_data[..header_size].clone()
	mut slices := []u8{}
	mut offset := i64(header_size)
	for index, arch in file.fat_archs {
		macho := file.machos[index]
		alignment := fat_alignment(arch.align)!
		macho_offset := macho_round(offset, alignment)
		if !fat64 && macho_offset > i64(0xffff_ffff) {
			return fat_arch_offset_overflow_error(macho_offset)
		}
		slices << []u8{len: int(macho_offset - offset)}
		slices << macho.serialize()
		arch_offset := 8 + index * arch_bytesize
		if fat64 {
			binary.big_endian_put_u64_at(mut header_data, u64(macho_offset), arch_offset + 8)
			binary.big_endian_put_u64_at(mut header_data, u64(macho.raw_data.len), arch_offset + 16)
		} else {
			binary.big_endian_put_u32_at(mut header_data, u32(macho_offset), arch_offset + 8)
			binary.big_endian_put_u32_at(mut header_data, u32(macho.raw_data.len), arch_offset + 12)
		}
		offset = macho_offset + macho.raw_data.len
	}
	file.raw_data = header_data
	file.raw_data << slices
	file.populate_fields()!
}

pub fn (mut file FatFile) change_dylib_id(new_id string, options FatFileModificationOptions) ! {
	for macho in file.machos {
		if macho.header.filetype != mh_dylib {
			return
		}
	}
	file.each_macho(options, fn [new_id] (mut macho MachoFile) ! {
		macho.change_dylib_id(new_id)!
	})!
	file.repopulate_raw_machos()!
}

pub fn (mut file FatFile) change_install_name(old_name string, new_name string, options FatFileModificationOptions) ! {
	file.each_macho(options, fn [old_name, new_name] (mut macho MachoFile) ! {
		macho.change_install_name(old_name, new_name)!
	})!
	file.repopulate_raw_machos()!
}

pub fn (mut file FatFile) change_rpath(old_path string, new_path string, options FatFileModificationOptions) ! {
	file.each_macho(options, fn [old_path, new_path, options] (mut macho MachoFile) ! {
		macho.change_rpath(old_path, new_path, DeleteRpathOptions{
			uniq: options.uniq
			last: options.last
		})!
	})!
	file.repopulate_raw_machos()!
}

pub fn (mut file FatFile) add_rpath(path string, options FatFileModificationOptions) ! {
	file.each_macho(options, fn [path] (mut macho MachoFile) ! {
		macho.add_rpath(path)!
	})!
	file.repopulate_raw_machos()!
}

pub fn (mut file FatFile) delete_rpath(path string, options FatFileModificationOptions) ! {
	file.each_macho(options, fn [path, options] (mut macho MachoFile) ! {
		macho.delete_rpath(path, DeleteRpathOptions{
			uniq: options.uniq
			last: options.last
		})!
	})!
	file.repopulate_raw_machos()!
}

pub fn (mut file FatFile) codesign(identifier string) ! {
	actual_identifier := if identifier == '' {
		code_signing_identifier(macho_file_code_signing_adapter(file.canonical_macho()), if file.has_filename {
			file.filename
		} else {
			''
		})
	} else {
		identifier
	}
	for index, _ in file.machos {
		file.machos[index].codesign(actual_identifier)!
	}
	file.repopulate_resized_raw_machos()!
}

pub fn (file &FatFile) extract(cputype string) ?&MachoFile {
	name := cputype.trim_string_left(':')
	for macho in file.machos {
		if macho.cputype_symbol() == name {
			return macho
		}
	}
	return none
}

pub fn (file &FatFile) write(filename string) ! {
	os.write_file_array(filename, file.raw_data)!
}

pub fn (file &FatFile) write_initial() ! {
	if !file.has_filename {
		return error('no initial file to write to')
	}
	file.write(file.filename)!
}

pub fn (file &FatFile) to_h() brew_runtime.Value {
	return brew_runtime.map_value({
		'header':    file.header.to_h()
		'fat_archs': brew_runtime.array_value(file.fat_archs.map(it.to_h()))
		'machos':    brew_runtime.array_value(file.machos.map(it.to_h()))
	})
}

// Ruby attr_accessor `attr_accessor :filename` at line 14.
pub fn ruby_fat_file_l14_d1_filename(args ...brew_runtime.Value) brew_runtime.Value {
	file := fat_file_from_args(args)
	return if file.has_filename {
		brew_runtime.string_value(file.filename)
	} else {
		nil_macho_value()
	}
}

// Ruby attr_accessor `attr_accessor :filename` at line 14.
pub fn ruby_fat_file_l14_d2_filename(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('filename= requires a filename') }
	mut file := fat_file_from_args(args)
	file.filename = args[1].as_string()
	file.has_filename = args[1].type_name != 'NilClass'
	return args[1]
}

// Ruby attr_reader `attr_reader :options` at line 18.
pub fn ruby_fat_file_l18_d3_options(args ...brew_runtime.Value) brew_runtime.Value {
	return fat_file_options_value(fat_file_from_args(args).options)
}

// Ruby attr_reader `attr_reader :header` at line 21.
pub fn ruby_fat_file_l21_d4_header(args ...brew_runtime.Value) brew_runtime.Value {
	return macho_header_boundary(fat_file_from_args(args).header)
}

// Ruby attr_reader `attr_reader :fat_archs` at line 24.
pub fn ruby_fat_file_l24_d5_fat_archs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(fat_file_from_args(args).fat_archs.map(macho_header_boundary(it)))
}

// Ruby attr_reader `attr_reader :machos` at line 27.
pub fn ruby_fat_file_l27_d6_machos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(fat_file_from_args(args).machos.map(macho_file_boundary(it)))
}

// Ruby method `self.new_from_machos(*machos, fat64: false)` at line 36.
pub fn ruby_fat_file_l36_d7_self_new_from_machos(args ...brew_runtime.Value) brew_runtime.Value {
	mut values := args.clone()
	mut fat64 := false
	if values.len > 0 && values.last().type_name == 'Hash' {
		options := values.last().as_map() or { map[string]brew_runtime.Value{} }
		fat64 = (options['fat64'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
		values = values[..values.len - 1].clone()
	}
	mut machos := []&MachoFile{cap: values.len}
	for value in values {
		machos << macho_file_from_args([value])
	}
	return fat_file_boundary(new_fat_file_from_machos(machos, fat64) or { panic(err) })
}

// Ruby method `self.new_from_bin(bin, **opts)` at line 82.
pub fn ruby_fat_file_l82_d8_self_new_from_bin(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('new_from_bin requires binary data') }
	options := if args.len > 1 {
		macho_file_options_from_value(args[1])
	} else {
		MachoFileOptions{}
	}
	return fat_file_boundary(new_fat_file_from_bin(args[0].as_string().bytes(), options) or { panic(err) })
}

// Ruby method `initialize(filename, **opts)` at line 94.
pub fn ruby_fat_file_l94_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('initialize requires a filename') }
	options := if args.len > 1 {
		macho_file_options_from_value(args[1])
	} else {
		MachoFileOptions{}
	}
	return fat_file_boundary(new_fat_file(args[0].as_string(), options) or { panic(err) })
}

// Ruby method `initialize_from_bin(bin, opts)` at line 111.
pub fn ruby_fat_file_l111_d10_initialize_from_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_fat_file_l82_d8_self_new_from_bin(...args)
}

// Ruby method `serialize` at line 120.
pub fn ruby_fat_file_l120_d11_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(fat_file_from_args(args).serialize().bytestr())
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d12_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_object)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d13_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_execute)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d14_fvmlib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_fvmlib)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d15_core(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_core)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d16_preload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_preload)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d17_dylib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_dylib)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d18_dylinker(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_dylinker)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d19_bundle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_bundle)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d20_dsym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_dsym)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d21_kext(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(fat_file_from_args(args).canonical_macho().header.filetype == mh_kext_bundle)
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d22_filetype(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${fat_file_from_args(args).canonical_macho().filetype_symbol()}')
}

// Ruby def_delegators `def_delegators :canonical_macho, :object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?, :dylinker?, :bundle?, :dsym?, :kext?, :filetype, :dylib_id` at line 148.
pub fn ruby_fat_file_l148_d23_dylib_id(args ...brew_runtime.Value) brew_runtime.Value {
	return if id := fat_file_from_args(args).canonical_macho().dylib_id() {
		brew_runtime.string_value(id)
	} else {
		nil_macho_value()
	}
}

// Ruby def_delegators `def_delegators :header, :magic` at line 154.
pub fn ruby_fat_file_l154_d24_magic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(fat_file_from_args(args).header.magic)
}

// Ruby method `magic_string` at line 157.
pub fn ruby_fat_file_l157_d25_magic_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(fat_file_from_args(args).magic_string())
}

// Ruby method `populate_fields` at line 164.
pub fn ruby_fat_file_l164_d26_populate_fields(args ...brew_runtime.Value) brew_runtime.Value {
	mut file := fat_file_from_args(args)
	file.populate_fields() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `dylib_load_commands` at line 172.
pub fn ruby_fat_file_l172_d27_dylib_load_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(fat_file_from_args(args).dylib_load_commands().map(load_command_boundary(it)))
}

// Ruby method `change_dylib_id(new_id, options = {})` at line 187.
pub fn ruby_fat_file_l187_d28_change_dylib_id(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[1].type_name != 'String' { panic('argument must be a String') }
	options := if args.len > 2 {
		fat_file_modification_options_from_value(args[2])
	} else {
		FatFileModificationOptions{}
	}
	mut file := fat_file_from_args(args)
	file.change_dylib_id(args[1].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby alias `alias dylib_id= change_dylib_id` at line 198.
pub fn ruby_fat_file_l198_d29_dylib_id(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_fat_file_l187_d28_change_dylib_id(...args)
}

// Ruby method `linked_dylibs` at line 203.
pub fn ruby_fat_file_l203_d30_linked_dylibs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(fat_file_from_args(args).linked_dylibs())
}

// Ruby method `change_install_name(old_name, new_name, options = {})` at line 222.
pub fn ruby_fat_file_l222_d31_change_install_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('change_install_name requires old and new names') }
	options := if args.len > 3 {
		fat_file_modification_options_from_value(args[3])
	} else {
		FatFileModificationOptions{}
	}
	mut file := fat_file_from_args(args)
	file.change_install_name(args[1].as_string(), args[2].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby alias `alias change_dylib change_install_name` at line 230.
pub fn ruby_fat_file_l230_d32_change_dylib(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_fat_file_l222_d31_change_install_name(...args)
}

// Ruby method `rpaths` at line 235.
pub fn ruby_fat_file_l235_d33_rpaths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(fat_file_from_args(args).rpaths())
}

// Ruby method `change_rpath(old_path, new_path, options = {})` at line 250.
pub fn ruby_fat_file_l250_d34_change_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('change_rpath requires old and new paths') }
	options := if args.len > 3 {
		fat_file_modification_options_from_value(args[3])
	} else {
		FatFileModificationOptions{}
	}
	mut file := fat_file_from_args(args)
	file.change_rpath(args[1].as_string(), args[2].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `add_rpath(path, options = {})` at line 265.
pub fn ruby_fat_file_l265_d35_add_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('add_rpath requires a path') }
	options := if args.len > 2 {
		fat_file_modification_options_from_value(args[2])
	} else {
		FatFileModificationOptions{}
	}
	mut file := fat_file_from_args(args)
	file.add_rpath(args[1].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `delete_rpath(path, options = {})` at line 283.
pub fn ruby_fat_file_l283_d36_delete_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('delete_rpath requires a path') }
	options := if args.len > 2 {
		fat_file_modification_options_from_value(args[2])
	} else {
		FatFileModificationOptions{}
	}
	mut file := fat_file_from_args(args)
	file.delete_rpath(args[1].as_string(), options) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `codesign!(identifier: nil)` at line 294.
pub fn ruby_fat_file_l294_d37_codesign(args ...brew_runtime.Value) brew_runtime.Value {
	identifier := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	mut file := fat_file_from_args(args)
	file.codesign(identifier) or { panic(err) }
	return nil_macho_value()
}

// Ruby method `extract(cputype)` at line 306.
pub fn ruby_fat_file_l306_d38_extract(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('extract requires a CPU type') }
	return if macho := fat_file_from_args(args).extract(args[1].as_string()) {
		macho_file_boundary(macho)
	} else {
		nil_macho_value()
	}
}

// Ruby method `write(filename)` at line 313.
pub fn ruby_fat_file_l313_d39_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('write requires a filename') }
	file := fat_file_from_args(args)
	file.write(args[1].as_string()) or { panic(err) }
	return brew_runtime.int_value(file.raw_data.len)
}

// Ruby method `write!` at line 321.
pub fn ruby_fat_file_l321_d40_write(args ...brew_runtime.Value) brew_runtime.Value {
	file := fat_file_from_args(args)
	file.write_initial() or { panic(err) }
	return brew_runtime.int_value(file.raw_data.len)
}

// Ruby method `to_h` at line 328.
pub fn ruby_fat_file_l328_d41_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return fat_file_from_args(args).to_h()
}

// Ruby method `populate_fat_header` at line 348.
pub fn ruby_fat_file_l348_d42_populate_fat_header(args ...brew_runtime.Value) brew_runtime.Value {
	return macho_header_boundary(fat_file_from_args(args).populate_fat_header() or { panic(err) })
}

// Ruby method `populate_fat_archs` at line 375.
pub fn ruby_fat_file_l375_d43_populate_fat_archs(args ...brew_runtime.Value) brew_runtime.Value {
	archs := fat_file_from_args(args).populate_fat_archs() or { panic(err) }
	return brew_runtime.array_value(archs.map(macho_header_boundary(it)))
}

// Ruby method `populate_machos` at line 392.
pub fn ruby_fat_file_l392_d44_populate_machos(args ...brew_runtime.Value) brew_runtime.Value {
	machos := fat_file_from_args(args).populate_machos() or { panic(err) }
	return brew_runtime.array_value(machos.map(macho_file_boundary(it)))
}

// Ruby method `repopulate_raw_machos` at line 412.
pub fn ruby_fat_file_l412_d45_repopulate_raw_machos(args ...brew_runtime.Value) brew_runtime.Value {
	mut file := fat_file_from_args(args)
	file.repopulate_raw_machos() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `repopulate_resized_raw_machos` at line 426.
pub fn ruby_fat_file_l426_d46_repopulate_resized_raw_machos(args ...brew_runtime.Value) brew_runtime.Value {
	mut file := fat_file_from_args(args)
	file.repopulate_resized_raw_machos() or { panic(err) }
	return nil_macho_value()
}

// Ruby method `each_macho(options = {})` at line 459.
pub fn ruby_fat_file_l459_d47_each_macho(args ...brew_runtime.Value) brew_runtime.Value {
	panic('FatFile#each_macho requires a Ruby block; use the typed V each_macho callback boundary')
}

// Ruby method `canonical_macho` at line 482.
pub fn ruby_fat_file_l482_d48_canonical_macho(args ...brew_runtime.Value) brew_runtime.Value {
	return macho_file_boundary(fat_file_from_args(args).canonical_macho())
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require "forwardable"
// 4:
// 5: module MachO
// 6:   # Represents a "Fat" file, which contains a header, a listing of available
// 7:   # architectures, and one or more Mach-O binaries.
// 8:   # @see https://en.wikipedia.org/wiki/Mach-O#Multi-architecture_binaries
// 9:   # @see MachOFile
// 10:   class FatFile
// 11:     extend Forwardable
// 12:
// 13:     # @return [String] the filename loaded from, or nil if loaded from a binary string
// 14:     attr_accessor :filename
// 15:
// 16:     # @return [Hash] any parser options that the instance was created with
// 17:     # @note Options specified in a {FatFile} trickle down into the internal {MachOFile}s.
// 18:     attr_reader :options
// 19:
// 20:     # @return [Headers::FatHeader] the file's header
// 21:     attr_reader :header
// 22:
// 23:     # @return [Array<Headers::FatArch>, Array<Headers::FatArch64] an array of fat architectures
// 24:     attr_reader :fat_archs
// 25:
// 26:     # @return [Array<MachOFile>] an array of Mach-O binaries
// 27:     attr_reader :machos
// 28:
// 29:     # Creates a new FatFile from the given (single-arch) Mach-Os
// 30:     # @param machos [Array<MachOFile>] the machos to combine
// 31:     # @param fat64 [Boolean] whether to use {Headers::FatArch64}s to represent each slice
// 32:     # @return [FatFile] a new FatFile containing the give machos
// 33:     # @raise [ArgumentError] if less than one Mach-O is given
// 34:     # @raise [FatArchOffsetOverflowError] if the Mach-Os are too big to be represented
// 35:     #  in a 32-bit {Headers::FatArch} and `fat64` is `false`.
// 36:     def self.new_from_machos(*machos, fat64: false)
// 37:       raise ArgumentError, "expected at least one Mach-O" if machos.empty?
// 38:
// 39:       fa_klass, magic = if fat64
// 40:         [Headers::FatArch64, Headers::FAT_MAGIC_64]
// 41:       else
// 42:         [Headers::FatArch, Headers::FAT_MAGIC]
// 43:       end
// 44:
// 45:       # put the smaller alignments further forwards in fat macho, so that we do less padding
// 46:       machos = machos.sort_by(&:segment_alignment)
// 47:
// 48:       bin = +""
// 49:
// 50:       bin << Headers::FatHeader.new(magic, machos.size).serialize
// 51:       offset = Headers::FatHeader.bytesize + (machos.size * fa_klass.bytesize)
// 52:
// 53:       macho_pads = {}
// 54:
// 55:       machos.each do |macho|
// 56:         macho_offset = Utils.round(offset, 2**macho.segment_alignment)
// 57:
// 58:         raise FatArchOffsetOverflowError, macho_offset if !fat64 && macho_offset > ((2**32) - 1)
// 59:
// 60:         macho_pads[macho] = Utils.padding_for(offset, 2**macho.segment_alignment)
// 61:
// 62:         bin << fa_klass.new(macho.header.cputype, macho.header.cpusubtype,
// 63:                             macho_offset, macho.serialize.bytesize,
// 64:                             macho.segment_alignment).serialize
// 65:
// 66:         offset += (macho.serialize.bytesize + macho_pads[macho])
// 67:       end
// 68:
// 69:       machos.each do |macho| # rubocop:disable Style/CombinableLoops
// 70:         bin << Utils.nullpad(macho_pads[macho])
// 71:         bin << macho.serialize
// 72:       end
// 73:
// 74:       new_from_bin(bin)
// 75:     end
// 76:
// 77:     # Creates a new FatFile instance from a binary string.
// 78:     # @param bin [String] a binary string containing raw Mach-O data
// 79:     # @param opts [Hash] options to control the parser with
// 80:     # @note see {MachOFile#initialize} for currently valid options
// 81:     # @return [FatFile] a new FatFile
// 82:     def self.new_from_bin(bin, **opts)
// 83:       instance = allocate
// 84:       instance.initialize_from_bin(bin, opts)
// 85:
// 86:       instance
// 87:     end
// 88:
// 89:     # Creates a new FatFile from the given filename.
// 90:     # @param filename [String] the fat file to load from
// 91:     # @param opts [Hash] options to control the parser with
// 92:     # @note see {MachOFile#initialize} for currently valid options
// 93:     # @raise [ArgumentError] if the given file does not exist
// 94:     def initialize(filename, **opts)
// 95:       raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 96:
// 97:       @filename = filename
// 98:       @options = opts
// 99:       File.open(@filename, "rb") do |file|
// 100:         @raw_data = file.read(Headers::FatHeader.bytesize)
// 101:         @raw_data ||= ""
// 102:         populate_fat_header
// 103:         @raw_data << file.read.to_s
// 104:       end
// 105:       populate_fields
// 106:     end
// 107:
// 108:     # Initializes a new FatFile instance from a binary string with the given options.
// 109:     # @see new_from_bin
// 110:     # @api private
// 111:     def initialize_from_bin(bin, opts)
// 112:       @filename = nil
// 113:       @options = opts
// 114:       @raw_data = bin
// 115:       populate_fields
// 116:     end
// 117:
// 118:     # The file's raw fat data.
// 119:     # @return [String] the raw fat data
// 120:     def serialize
// 121:       @raw_data
// 122:     end
// 123:
// 124:     # @!method object?
// 125:     #  @return (see MachO::MachOFile#object?)
// 126:     # @!method executable?
// 127:     #  @return (see MachO::MachOFile#executable?)
// 128:     # @!method fvmlib?
// 129:     #  @return (see MachO::MachOFile#fvmlib?)
// 130:     # @!method core?
// 131:     #  @return (see MachO::MachOFile#core?)
// 132:     # @!method preload?
// 133:     #  @return (see MachO::MachOFile#preload?)
// 134:     # @!method dylib?
// 135:     #  @return (see MachO::MachOFile#dylib?)
// 136:     # @!method dylinker?
// 137:     #  @return (see MachO::MachOFile#dylinker?)
// 138:     # @!method bundle?
// 139:     #  @return (see MachO::MachOFile#bundle?)
// 140:     # @!method dsym?
// 141:     #  @return (see MachO::MachOFile#dsym?)
// 142:     # @!method kext?
// 143:     #  @return (see MachO::MachOFile#kext?)
// 144:     # @!method filetype
// 145:     #  @return (see MachO::MachOFile#filetype)
// 146:     # @!method dylib_id
// 147:     #  @return (see MachO::MachOFile#dylib_id)
// 148:     def_delegators :canonical_macho, :object?, :executable?, :fvmlib?,
// 149:                    :core?, :preload?, :dylib?, :dylinker?, :bundle?,
// 150:                    :dsym?, :kext?, :filetype, :dylib_id
// 151:
// 152:     # @!method magic
// 153:     #  @return (see MachO::Headers::FatHeader#magic)
// 154:     def_delegators :header, :magic
// 155:
// 156:     # @return [String] a string representation of the file's magic number
// 157:     def magic_string
// 158:       Headers::MH_MAGICS[magic]
// 159:     end
// 160:
// 161:     # Populate the instance's fields with the raw Fat Mach-O data.
// 162:     # @return [void]
// 163:     # @note This method is public, but should (almost) never need to be called.
// 164:     def populate_fields
// 165:       @header = populate_fat_header
// 166:       @fat_archs = populate_fat_archs
// 167:       @machos = populate_machos
// 168:     end
// 169:
// 170:     # All load commands responsible for loading dylibs in the file's Mach-O's.
// 171:     # @return [Array<LoadCommands::DylibCommand>] an array of DylibCommands
// 172:     def dylib_load_commands
// 173:       machos.flat_map(&:dylib_load_commands)
// 174:     end
// 175:
// 176:     # Changes the file's dylib ID to `new_id`. If the file is not a dylib,
// 177:     #  does nothing.
// 178:     # @example
// 179:     #  file.change_dylib_id('libFoo.dylib')
// 180:     # @param new_id [String] the new dylib ID
// 181:     # @param options [Hash]
// 182:     # @option options [Boolean] :strict (true) if true, fail if one slice fails.
// 183:     #  if false, fail only if all slices fail.
// 184:     # @return [void]
// 185:     # @raise [ArgumentError] if `new_id` is not a String
// 186:     # @see MachOFile#linked_dylibs
// 187:     def change_dylib_id(new_id, options = {})
// 188:       raise ArgumentError, "argument must be a String" unless new_id.is_a?(String)
// 189:       return unless machos.all?(&:dylib?)
// 190:
// 191:       each_macho(options) do |macho|
// 192:         macho.change_dylib_id(new_id, options)
// 193:       end
// 194:
// 195:       repopulate_raw_machos
// 196:     end
// 197:
// 198:     alias dylib_id= change_dylib_id
// 199:
// 200:     # All shared libraries linked to the file's Mach-Os.
// 201:     # @return [Array<String>] an array of all shared libraries
// 202:     # @see MachOFile#linked_dylibs
// 203:     def linked_dylibs
// 204:       # Individual architectures in a fat binary can link to different subsets
// 205:       # of libraries, but at this point we want to have the full picture, i.e.
// 206:       # the union of all libraries used by all architectures.
// 207:       machos.flat_map(&:linked_dylibs).uniq
// 208:     end
// 209:
// 210:     # Changes all dependent shared library install names from `old_name` to
// 211:     # `new_name`. In a fat file, this changes install names in all internal
// 212:     # Mach-Os.
// 213:     # @example
// 214:     #  file.change_install_name('/usr/lib/libFoo.dylib', '/usr/lib/libBar.dylib')
// 215:     # @param old_name [String] the shared library name being changed
// 216:     # @param new_name [String] the new name
// 217:     # @param options [Hash]
// 218:     # @option options [Boolean] :strict (true) if true, fail if one slice fails.
// 219:     #  if false, fail only if all slices fail.
// 220:     # @return [void]
// 221:     # @see MachOFile#change_install_name
// 222:     def change_install_name(old_name, new_name, options = {})
// 223:       each_macho(options) do |macho|
// 224:         macho.change_install_name(old_name, new_name, options)
// 225:       end
// 226:
// 227:       repopulate_raw_machos
// 228:     end
// 229:
// 230:     alias change_dylib change_install_name
// 231:
// 232:     # All runtime paths associated with the file's Mach-Os.
// 233:     # @return [Array<String>] an array of all runtime paths
// 234:     # @see MachOFile#rpaths
// 235:     def rpaths
// 236:       # Can individual architectures have different runtime paths?
// 237:       machos.flat_map(&:rpaths).uniq
// 238:     end
// 239:
// 240:     # Change the runtime path `old_path` to `new_path` in the file's Mach-Os.
// 241:     # @param old_path [String] the old runtime path
// 242:     # @param new_path [String] the new runtime path
// 243:     # @param options [Hash]
// 244:     # @option options [Boolean] :strict (true) if true, fail if one slice fails.
// 245:     #  if false, fail only if all slices fail.
// 246:     # @option options [Boolean] :uniq (false) for each slice: if true, change
// 247:     #  each rpath simultaneously.
// 248:     # @return [void]
// 249:     # @see MachOFile#change_rpath
// 250:     def change_rpath(old_path, new_path, options = {})
// 251:       each_macho(options) do |macho|
// 252:         macho.change_rpath(old_path, new_path, options)
// 253:       end
// 254:
// 255:       repopulate_raw_machos
// 256:     end
// 257:
// 258:     # Add the given runtime path to the file's Mach-Os.
// 259:     # @param path [String] the new runtime path
// 260:     # @param options [Hash]
// 261:     # @option options [Boolean] :strict (true) if true, fail if one slice fails.
// 262:     #  if false, fail only if all slices fail.
// 263:     # @return [void]
// 264:     # @see MachOFile#add_rpath
// 265:     def add_rpath(path, options = {})
// 266:       each_macho(options) do |macho|
// 267:         macho.add_rpath(path, options)
// 268:       end
// 269:
// 270:       repopulate_raw_machos
// 271:     end
// 272:
// 273:     # Delete the given runtime path from the file's Mach-Os.
// 274:     # @param path [String] the runtime path to delete
// 275:     # @param options [Hash]
// 276:     # @option options [Boolean] :strict (true) if true, fail if one slice fails.
// 277:     #  if false, fail only if all slices fail.
// 278:     # @option options [Boolean] :uniq (false) for each slice: if true, delete
// 279:     #  only the first runtime path that matches. if false, delete all duplicate
// 280:     #  paths that match.
// 281:     # @return void
// 282:     # @see MachOFile#delete_rpath
// 283:     def delete_rpath(path, options = {})
// 284:       each_macho(options) do |macho|
// 285:         macho.delete_rpath(path, options)
// 286:       end
// 287:
// 288:       repopulate_raw_machos
// 289:     end
// 290:
// 291:     # Replaces every embedded signature with a pure-Ruby ad-hoc signature.
// 292:     # @param identifier [String, nil] the signing identifier
// 293:     # @return [void]
// 294:     def codesign!(identifier: nil)
// 295:       identifier ||= CodeSigning.identifier(canonical_macho, filename)
// 296:       machos.each { |macho| macho.codesign!(:identifier => identifier) }
// 297:       repopulate_resized_raw_machos
// 298:       nil
// 299:     end
// 300:
// 301:     # Extract a Mach-O with the given CPU type from the file.
// 302:     # @example
// 303:     #  file.extract(:i386) # => MachO::MachOFile
// 304:     # @param cputype [Symbol] the CPU type of the Mach-O being extracted
// 305:     # @return [MachOFile, nil] the extracted Mach-O or nil if no Mach-O has the given CPU type
// 306:     def extract(cputype)
// 307:       machos.select { |macho| macho.cputype == cputype }.first
// 308:     end
// 309:
// 310:     # Write all (fat) data to the given filename.
// 311:     # @param filename [String] the file to write to
// 312:     # @return [void]
// 313:     def write(filename)
// 314:       File.binwrite(filename, @raw_data)
// 315:     end
// 316:
// 317:     # Write all (fat) data to the file used to initialize the instance.
// 318:     # @return [void]
// 319:     # @raise [MachOError] if the instance was initialized without a file
// 320:     # @note Overwrites all data in the file!
// 321:     def write!
// 322:       raise MachOError, "no initial file to write to" if filename.nil?
// 323:
// 324:       File.binwrite(@filename, @raw_data)
// 325:     end
// 326:
// 327:     # @return [Hash] a hash representation of this {FatFile}
// 328:     def to_h
// 329:       {
// 330:         "header" => header.to_h,
// 331:         "fat_archs" => fat_archs.map(&:to_h),
// 332:         "machos" => machos.map(&:to_h),
// 333:       }
// 334:     end
// 335:
// 336:     private
// 337:
// 338:     # Obtain the fat header from raw file data.
// 339:     # @return [Headers::FatHeader] the fat header
// 340:     # @raise [TruncatedFileError] if the file is too small to have a
// 341:     #  valid header
// 342:     # @raise [MagicError] if the magic is not valid Mach-O magic
// 343:     # @raise [MachOBinaryError] if the magic is for a non-fat Mach-O file
// 344:     # @raise [JavaClassFileError] if the file is a Java classfile
// 345:     # @raise [ZeroArchitectureError] if the file has no internal slices
// 346:     #  (i.e., nfat_arch == 0) and the permissive option is not set
// 347:     # @api private
// 348:     def populate_fat_header
// 349:       # the smallest fat Mach-O header is 8 bytes
// 350:       raise TruncatedFileError if @raw_data.size < 8
// 351:
// 352:       fh = Headers::FatHeader.new_from_bin(:big, @raw_data[0, Headers::FatHeader.bytesize])
// 353:
// 354:       raise MagicError, fh.magic unless Utils.magic?(fh.magic)
// 355:       raise MachOBinaryError unless Utils.fat_magic?(fh.magic)
// 356:
// 357:       # Rationale: Java classfiles have the same magic as big-endian fat
// 358:       # Mach-Os. Classfiles encode their version at the same offset as
// 359:       # `nfat_arch` and the lowest version number is 43, so we error out
// 360:       # if a file claims to have over 30 internal architectures. It's
// 361:       # technically possible for a fat Mach-O to have over 30 architectures,
// 362:       # but this is extremely unlikely and in practice distinguishes the two
// 363:       # formats.
// 364:       raise JavaClassFileError if fh.nfat_arch > 30
// 365:
// 366:       # Rationale: return an error if the file has no internal slices.
// 367:       raise ZeroArchitectureError if fh.nfat_arch.zero?
// 368:
// 369:       fh
// 370:     end
// 371:
// 372:     # Obtain an array of fat architectures from raw file data.
// 373:     # @return [Array<Headers::FatArch>] an array of fat architectures
// 374:     # @api private
// 375:     def populate_fat_archs
// 376:       archs = []
// 377:
// 378:       fa_klass = Utils.fat_magic32?(header.magic) ? Headers::FatArch : Headers::FatArch64
// 379:       fa_off   = Headers::FatHeader.bytesize
// 380:       fa_len   = fa_klass.bytesize
// 381:
// 382:       header.nfat_arch.times do |i|
// 383:         archs << fa_klass.new_from_bin(:big, @raw_data[fa_off + (fa_len * i), fa_len])
// 384:       end
// 385:
// 386:       archs
// 387:     end
// 388:
// 389:     # Obtain an array of Mach-O blobs from raw file data.
// 390:     # @return [Array<MachOFile>] an array of Mach-Os
// 391:     # @api private
// 392:     def populate_machos
// 393:       machos = []
// 394:
// 395:       fat_archs.each do |arch|
// 396:         machos << MachOFile.new_from_bin(@raw_data[arch.offset, arch.size], **options)
// 397:
// 398:         # Make sure that each fat_arch and internal slice.
// 399:         # contain matching cputypes and cpusubtypes
// 400:         next if machos.last.header.cputype == arch.cputype &&
// 401:                 machos.last.header.cpusubtype == arch.cpusubtype
// 402:
// 403:         raise CPUTypeMismatchError.new(arch.cputype, arch.cpusubtype, machos.last.header.cputype, machos.last.header.cpusubtype)
// 404:       end
// 405:
// 406:       machos
// 407:     end
// 408:
// 409:     # Repopulate the raw Mach-O data with each internal Mach-O object.
// 410:     # @return [void]
// 411:     # @api private
// 412:     def repopulate_raw_machos
// 413:       machos.each_with_index do |macho, i|
// 414:         arch = fat_archs[i]
// 415:
// 416:         @raw_data[arch.offset, arch.size] = macho.serialize
// 417:       end
// 418:     end
// 419:
// 420:     # Rebuild the fat header and slice layout after internal Mach-Os change size.
// 421:     # {#repopulate_raw_machos} assumes slice lengths are unchanged and writes at
// 422:     # their recorded ranges. Signing appends data, so every architecture's size
// 423:     # and each following aligned offset must be recalculated.
// 424:     # @return [void]
// 425:     # @api private
// 426:     def repopulate_resized_raw_machos
// 427:       fat_arch_class = Utils.fat_magic32?(header.magic) ? Headers::FatArch : Headers::FatArch64
// 428:       header_size = Headers::FatHeader.bytesize + (fat_archs.size * fat_arch_class.bytesize)
// 429:       header_data = @raw_data.byteslice(0, header_size)
// 430:       slices = +"".b
// 431:       offset = header_size
// 432:
// 433:       fat_archs.zip(machos).each_with_index do |(arch, macho), index|
// 434:         macho_offset = Utils.round(offset, 2**arch.align)
// 435:         slices << Utils.nullpad(macho_offset - offset) << macho.serialize
// 436:         arch_offset = Headers::FatHeader.bytesize + (index * fat_arch_class.bytesize)
// 437:         if fat_arch_class == Headers::FatArch
// 438:           raise FatArchOffsetOverflowError, macho_offset if macho_offset > 0xffffffff
// 439:
// 440:           header_data[arch_offset + 8, 8] = [macho_offset, macho.serialize.bytesize].pack("N2")
// 441:         else
// 442:           header_data[arch_offset + 8, 16] = [macho_offset, macho.serialize.bytesize].pack("Q>2")
// 443:         end
// 444:         offset = macho_offset + macho.serialize.bytesize
// 445:       end
// 446:
// 447:       @raw_data = header_data + slices
// 448:       populate_fields
// 449:     end
// 450:
// 451:     # Yield each Mach-O object in the file, rescuing and accumulating errors.
// 452:     # @param options [Hash]
// 453:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 454:     #  with an exception if at least one Mach-O raises an exception. If false,
// 455:     #  only raises an exception if *all* Mach-Os raise exceptions.
// 456:     # @raise [RecoverableModificationError] under the conditions of
// 457:     #  the `:strict` option above.
// 458:     # @api private
// 459:     def each_macho(options = {})
// 460:       strict = options.fetch(:strict, true)
// 461:       errors = []
// 462:
// 463:       machos.each_with_index do |macho, index|
// 464:         yield macho
// 465:       rescue RecoverableModificationError => e
// 466:         e.macho_slice = index
// 467:
// 468:         # Strict mode: Immediately re-raise. Otherwise: Retain, check later.
// 469:         raise e if strict
// 470:
// 471:         errors << e
// 472:       end
// 473:
// 474:       # Non-strict mode: Raise first error if *all* Mach-O slices failed.
// 475:       raise errors.first if errors.size == machos.size
// 476:     end
// 477:
// 478:     # Return a single-arch Mach-O that represents this fat Mach-O for purposes
// 479:     #  of delegation.
// 480:     # @return [MachOFile] the Mach-O file
// 481:     # @api private
// 482:     def canonical_macho
// 483:       machos.first
// 484:     end
// 485:   end
// 486: end
