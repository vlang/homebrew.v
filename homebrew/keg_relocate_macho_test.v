module homebrew

import os

fn mach_o_fixture(name string, bytes []u8) string {
	directory := os.join_path(os.vtmp_dir(), 'brew-v-macho')
	os.mkdir_all(directory) or { panic(err) }
	path := os.join_path(directory, name)
	os.write_file_array(path, bytes) or { panic(err) }
	return path
}

fn thin_header(magic []u8, filetype []u8) []u8 {
	mut bytes := []u8{}
	bytes << magic
	bytes << [u8(0x0c), 0x00, 0x00, 0x01] // cputype
	bytes << [u8(0x00), 0x00, 0x00, 0x00] // cpusubtype
	bytes << filetype
	bytes << []u8{len: 16}
	return bytes
}

fn test_thin_mach_o_file_types() {
	// Little-endian 64-bit (MH_CIGAM_64) as produced on arm64.
	executable := mach_o_fixture('executable', thin_header([u8(0xcf), 0xfa, 0xed, 0xfe], [
		u8(0x02),
		0x00,
		0x00,
		0x00,
	]))
	dylib := mach_o_fixture('dylib', thin_header([u8(0xcf), 0xfa, 0xed, 0xfe], [
		u8(0x06),
		0x00,
		0x00,
		0x00,
	]))
	bundle := mach_o_fixture('bundle', thin_header([u8(0xcf), 0xfa, 0xed, 0xfe], [
		u8(0x08),
		0x00,
		0x00,
		0x00,
	]))
	// MH_OBJECT and MH_DSYM are Mach-O but are not relocated by the source.
	object := mach_o_fixture('object', thin_header([u8(0xcf), 0xfa, 0xed, 0xfe], [
		u8(0x01),
		0x00,
		0x00,
		0x00,
	]))
	assert mach_o_relocatable_file(executable)
	assert mach_o_relocatable_file(dylib)
	assert mach_o_relocatable_file(bundle)
	assert !mach_o_relocatable_file(object)
}

fn test_big_endian_thin_mach_o_file() {
	// MH_MAGIC_64 keeps its fields big-endian, so the file type is read that way.
	path := mach_o_fixture('big_endian', thin_header([u8(0xfe), 0xed, 0xfa, 0xcf], [
		u8(0x00),
		0x00,
		0x00,
		0x06,
	]))
	assert mach_o_relocatable_file(path)
}

fn test_fat_mach_o_file_reads_its_slices() {
	slice_offset := 4096
	mut bytes := []u8{}
	bytes << [u8(0xca), 0xfe, 0xba, 0xbe] // FAT_MAGIC
	bytes << [u8(0x00), 0x00, 0x00, 0x01] // nfat_arch = 1
	bytes << [u8(0x01), 0x00, 0x00, 0x0c] // cputype
	bytes << [u8(0x00), 0x00, 0x00, 0x00] // cpusubtype
	bytes << [u8(0x00), 0x00, 0x10, 0x00] // offset = 4096, big-endian
	bytes << [u8(0x00), 0x00, 0x00, 0x20] // size
	bytes << [u8(0x00), 0x00, 0x00, 0x0e] // align
	for bytes.len < slice_offset {
		bytes << 0
	}
	bytes << thin_header([u8(0xcf), 0xfa, 0xed, 0xfe], [u8(0x06), 0x00, 0x00, 0x00])
	assert mach_o_relocatable_file(mach_o_fixture('fat', bytes))
}

fn test_java_class_file_is_not_mach_o() {
	// Java class files share FAT_MAGIC; their version sits where `nfat_arch` does
	// and is always above the 30-slice limit ruby-macho draws.
	mut bytes := [u8(0xca), 0xfe, 0xba, 0xbe]
	bytes << [u8(0x00), 0x00, 0x00, 0x41] // minor/major version = 65
	bytes << []u8{len: 32}
	assert !mach_o_relocatable_file(mach_o_fixture('Example.class', bytes))
}

fn test_non_mach_o_inputs() {
	assert !mach_o_relocatable_file(mach_o_fixture('script', '#!/bin/sh\necho hi\n'.bytes()))
	assert !mach_o_relocatable_file(mach_o_fixture('empty', []u8{}))
	assert !mach_o_relocatable_file(mach_o_fixture('truncated', [u8(0xcf), 0xfa]))
	assert !mach_o_relocatable_file(os.join_path(os.vtmp_dir(), 'brew-v-macho', 'missing'))
}

fn test_zero_slice_fat_file_is_not_mach_o() {
	mut bytes := [u8(0xca), 0xfe, 0xba, 0xbe]
	bytes << [u8(0x00), 0x00, 0x00, 0x00] // nfat_arch = 0
	assert !mach_o_relocatable_file(mach_o_fixture('zero_arch', bytes))
}

fn test_text_description_predicate() {
	assert keg_text_description('POSIX shell script text executable, ASCII text', '/a/b')
	assert keg_text_description('ASCII text', '/a/b')
	assert keg_text_description('', '/a/b/libfoo.la')
	assert !keg_text_description('Mach-O 64-bit executable arm64', '/a/b')
	assert !keg_text_description('', '/a/b')
}
