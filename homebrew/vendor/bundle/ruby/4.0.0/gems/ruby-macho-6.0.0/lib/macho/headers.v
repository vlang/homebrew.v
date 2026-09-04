module macho

import ruby
import encoding.binary

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/headers.rb`.
// The original source is retained below until every stub has a typed V body.
pub const fat_magic = u32(0xcafebabe)
pub const fat_cigam = u32(0xbebafeca)
pub const fat_magic_64 = u32(0xcafebabf)
pub const fat_cigam_64 = u32(0xbfbafeca)
pub const mh_magic = u32(0xfeedface)
pub const mh_cigam = u32(0xcefaedfe)
pub const mh_magic_64 = u32(0xfeedfacf)
pub const mh_cigam_64 = u32(0xcffaedfe)
pub const compressed_magic = u32(0x636f6d70)
pub const comp_type_lzss = u32(0x6c7a7373)
pub const comp_type_fastlib = u32(0x6c7a766e)
pub const cpu_arch_abi64 = u32(0x0100_0000)
pub const cpu_arch_abi64_32 = u32(0x0200_0000)
pub const cpu_type_any = u32(0xffff_ffff)
pub const cpu_type_mc680x0 = u32(0x06)
pub const cpu_type_i386 = u32(0x07)
pub const cpu_type_x86_64 = cpu_type_i386 | cpu_arch_abi64
pub const cpu_type_arm = u32(0x0c)
pub const cpu_type_mc88000 = u32(0x0d)
pub const cpu_type_arm64 = cpu_type_arm | cpu_arch_abi64
pub const cpu_type_arm64_32 = cpu_type_arm | cpu_arch_abi64_32
pub const cpu_type_powerpc = u32(0x12)
pub const cpu_type_powerpc64 = cpu_type_powerpc | cpu_arch_abi64
pub const cpu_subtype_mask = u32(0xff00_0000)
pub const cpu_subtype_lib64 = u32(0x8000_0000)
pub const cpu_subtype_i386 = u32(3)
pub const cpu_subtype_486 = u32(4)
pub const cpu_subtype_486sx = u32(132)
pub const cpu_subtype_586 = u32(5)
pub const cpu_subtype_pent = cpu_subtype_586
pub const cpu_subtype_pentpro = u32(22)
pub const cpu_subtype_pentii_m3 = u32(54)
pub const cpu_subtype_pentii_m5 = u32(86)
pub const cpu_subtype_pentium_4 = u32(10)
pub const cpu_subtype_mc680x0_all = u32(1)
pub const cpu_subtype_mc68030 = cpu_subtype_mc680x0_all
pub const cpu_subtype_mc68040 = u32(2)
pub const cpu_subtype_mc68030_only = u32(3)
pub const cpu_subtype_x86_64_all = cpu_subtype_i386
pub const cpu_subtype_x86_64_h = u32(8)
pub const cpu_subtype_arm_all = u32(0)
pub const cpu_subtype_arm_v4t = u32(5)
pub const cpu_subtype_arm_v6 = u32(6)
pub const cpu_subtype_arm_v5tej = u32(7)
pub const cpu_subtype_arm_xscale = u32(8)
pub const cpu_subtype_arm_v7 = u32(9)
pub const cpu_subtype_arm_v7f = u32(10)
pub const cpu_subtype_arm_v7s = u32(11)
pub const cpu_subtype_arm_v7k = u32(12)
pub const cpu_subtype_arm_v6m = u32(14)
pub const cpu_subtype_arm_v7m = u32(15)
pub const cpu_subtype_arm_v7em = u32(16)
pub const cpu_subtype_arm_v8 = u32(13)
pub const cpu_subtype_arm64_all = u32(0)
pub const cpu_subtype_arm64_v8 = u32(1)
pub const cpu_subtype_arm64_32_v8 = u32(1)
pub const cpu_subtype_arm64e = u32(2)
pub const cpu_subtype_mc88000_all = u32(0)
pub const cpu_subtype_mmax_jpc = cpu_subtype_mc88000_all
pub const cpu_subtype_mc88100 = u32(1)
pub const cpu_subtype_mc88110 = u32(2)
pub const cpu_subtype_powerpc_all = u32(0)
pub const cpu_subtype_powerpc_601 = u32(1)
pub const cpu_subtype_powerpc_602 = u32(2)
pub const cpu_subtype_powerpc_603 = u32(3)
pub const cpu_subtype_powerpc_603e = u32(4)
pub const cpu_subtype_powerpc_603ev = u32(5)
pub const cpu_subtype_powerpc_604 = u32(6)
pub const cpu_subtype_powerpc_604e = u32(7)
pub const cpu_subtype_powerpc_620 = u32(8)
pub const cpu_subtype_powerpc_750 = u32(9)
pub const cpu_subtype_powerpc_7400 = u32(10)
pub const cpu_subtype_powerpc_7450 = u32(11)
pub const cpu_subtype_powerpc_970 = u32(100)
pub const cpu_subtype_powerpc64_all = cpu_subtype_powerpc_all
pub const mh_object = u32(0x1)
pub const mh_execute = u32(0x2)
pub const mh_fvmlib = u32(0x3)
pub const mh_core = u32(0x4)
pub const mh_preload = u32(0x5)
pub const mh_dylib = u32(0x6)
pub const mh_dylinker = u32(0x7)
pub const mh_bundle = u32(0x8)
pub const mh_dylib_stub = u32(0x9)
pub const mh_dsym = u32(0xa)
pub const mh_kext_bundle = u32(0xb)
pub const mh_fileset = u32(0xc)
pub const mh_gpu_execute = u32(0xd)
pub const mh_gpu_dylib = u32(0xe)

pub enum MachoHeaderKind {
	fat_header
	fat_arch
	fat_arch64
	mach_header
	mach_header64
	prelinked_kernel
}

@[heap]
pub struct MachoHeaderRecord {
pub:
	kind              MachoHeaderKind
	magic             u32
	nfat_arch         u32
	cputype           u32
	cpusubtype        u32
	offset            u64
	size              u64
	align             u32
	reserved          u32
	filetype          u32
	ncmds             u32
	sizeofcmds        u32
	flags             u32
	signature         u32
	compress_type     u32
	adler32           u32
	uncompressed_size u32
	compressed_size   u32
	prelink_version   u32
	reserved_bytes    string
	platform_name     string
	root_path         string
}

pub fn new_fat_header(magic u32, architectures u32) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .fat_header
		magic: magic
		nfat_arch: architectures
	}
}

pub fn new_fat_arch(cputype u32, cpusubtype u32, offset u64, size u64, align u32) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .fat_arch
		cputype: cputype
		cpusubtype: cpusubtype & 0x00ff_ffff
		offset: offset
		size: size
		align: align
	}
}

pub fn new_fat_arch64(cputype u32, cpusubtype u32, offset u64, size u64, align u32, reserved u32) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .fat_arch64
		cputype: cputype
		cpusubtype: cpusubtype & 0x00ff_ffff
		offset: offset
		size: size
		align: align
		reserved: reserved
	}
}

pub fn new_mach_header(magic u32, cputype u32, cpusubtype u32, filetype u32, commands u32, command_size u32, flags u32) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .mach_header
		magic: magic
		cputype: cputype
		cpusubtype: cpusubtype & 0x00ff_ffff
		filetype: filetype
		ncmds: commands
		sizeofcmds: command_size
		flags: flags
	}
}

pub fn new_mach_header64(magic u32, cputype u32, cpusubtype u32, filetype u32, commands u32, command_size u32, flags u32, reserved u32) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .mach_header64
		magic: magic
		cputype: cputype
		cpusubtype: cpusubtype & 0x00ff_ffff
		filetype: filetype
		ncmds: commands
		sizeofcmds: command_size
		flags: flags
		reserved: reserved
	}
}

pub fn new_prelinked_kernel_header(signature u32, compress_type u32, adler32 u32, uncompressed_size u32, compressed_size u32, prelink_version u32, reserved string, platform_name string, root_path string) &MachoHeaderRecord {
	return &MachoHeaderRecord{
		kind: .prelinked_kernel
		signature: signature
		compress_type: compress_type
		adler32: adler32
		uncompressed_size: uncompressed_size
		compressed_size: compressed_size
		prelink_version: prelink_version
		reserved_bytes: reserved
		platform_name: platform_name
		root_path: root_path
	}
}

fn put_be_u32(mut bytes []u8, offset int, value u32) {
	binary.big_endian_put_u32_at(mut bytes, value, offset)
}

fn put_be_u64(mut bytes []u8, offset int, value u64) {
	binary.big_endian_put_u64_at(mut bytes, value, offset)
}

pub fn (header &MachoHeaderRecord) serialize() ![]u8 {
	match header.kind {
		.fat_header {
			mut bytes := []u8{len: 8}
			put_be_u32(mut bytes, 0, header.magic)
			put_be_u32(mut bytes, 4, header.nfat_arch)
			return bytes
		}
		.fat_arch {
			mut bytes := []u8{len: 20}
			for index, value in [header.cputype, header.cpusubtype, u32(header.offset),
				u32(header.size), header.align] {
				put_be_u32(mut bytes, index * 4, value)
			}
			return bytes
		}
		.fat_arch64 {
			mut bytes := []u8{len: 32}
			put_be_u32(mut bytes, 0, header.cputype)
			put_be_u32(mut bytes, 4, header.cpusubtype)
			put_be_u64(mut bytes, 8, header.offset)
			put_be_u64(mut bytes, 16, header.size)
			put_be_u32(mut bytes, 24, header.align)
			put_be_u32(mut bytes, 28, header.reserved)
			return bytes
		}
		else {
			return error('header type ${header.kind} has no explicit source serialize method')
		}
	}
}

fn header_magic_symbol(magic u32) string {
	return match magic {
		fat_magic { 'FAT_MAGIC' }
		fat_magic_64 { 'FAT_MAGIC_64' }
		mh_magic { 'MH_MAGIC' }
		mh_cigam { 'MH_CIGAM' }
		mh_magic_64 { 'MH_MAGIC_64' }
		mh_cigam_64 { 'MH_CIGAM_64' }
		else { '' }
	}
}

fn header_cpu_type_symbol(cputype u32) string {
	return match cputype {
		cpu_type_any { 'any' }
		cpu_type_i386 { 'i386' }
		cpu_type_x86_64 { 'x86_64' }
		cpu_type_arm { 'arm' }
		cpu_type_arm64 { 'arm64' }
		cpu_type_arm64_32 { 'arm64_32' }
		cpu_type_powerpc { 'ppc' }
		cpu_type_powerpc64 { 'ppc64' }
		else { '' }
	}
}

fn header_cpu_subtype_symbol(cputype u32, subtype u32) string {
	return match cputype {
		cpu_type_i386 {
			match subtype {
				cpu_subtype_i386 { 'i386' }
				cpu_subtype_486 { 'i486' }
				cpu_subtype_486sx { 'i486SX' }
				cpu_subtype_586 { 'i586' }
				cpu_subtype_pentpro { 'i686' }
				cpu_subtype_pentii_m3 { 'pentIIm3' }
				cpu_subtype_pentii_m5 { 'pentIIm5' }
				cpu_subtype_pentium_4 { 'pentium4' }
				else { '' }
			}
		}
		cpu_type_x86_64 {
			match subtype {
				cpu_subtype_x86_64_all { 'x86_64' }
				cpu_subtype_x86_64_h { 'x86_64h' }
				else { '' }
			}
		}
		cpu_type_arm {
			match subtype {
				cpu_subtype_arm_all { 'arm' }
				cpu_subtype_arm_v4t { 'armv4t' }
				cpu_subtype_arm_v6 { 'armv6' }
				cpu_subtype_arm_v5tej { 'armv5' }
				cpu_subtype_arm_xscale { 'xscale' }
				cpu_subtype_arm_v7 { 'armv7' }
				cpu_subtype_arm_v7f { 'armv7f' }
				cpu_subtype_arm_v7s { 'armv7s' }
				cpu_subtype_arm_v7k { 'armv7k' }
				cpu_subtype_arm_v6m { 'armv6m' }
				cpu_subtype_arm_v7m { 'armv7m' }
				cpu_subtype_arm_v7em { 'armv7em' }
				cpu_subtype_arm_v8 { 'armv8' }
				else { '' }
			}
		}
		cpu_type_arm64 {
			match subtype {
				cpu_subtype_arm64_all { 'arm64' }
				cpu_subtype_arm64_v8 { 'arm64v8' }
				cpu_subtype_arm64e { 'arm64e' }
				else { '' }
			}
		}
		cpu_type_arm64_32 {
			if subtype == cpu_subtype_arm64_32_v8 { 'arm64_32v8' } else { '' }
		}
		cpu_type_powerpc {
			match subtype {
				cpu_subtype_powerpc_all { 'ppc' }
				cpu_subtype_powerpc_601 { 'ppc601' }
				cpu_subtype_powerpc_603 { 'ppc603' }
				cpu_subtype_powerpc_603e { 'ppc603e' }
				cpu_subtype_powerpc_603ev { 'ppc603ev' }
				cpu_subtype_powerpc_604 { 'ppc604' }
				cpu_subtype_powerpc_604e { 'ppc604e' }
				cpu_subtype_powerpc_750 { 'ppc750' }
				cpu_subtype_powerpc_7400 { 'ppc7400' }
				cpu_subtype_powerpc_7450 { 'ppc7450' }
				cpu_subtype_powerpc_970 { 'ppc970' }
				else { '' }
			}
		}
		cpu_type_powerpc64 {
			match subtype {
				cpu_subtype_powerpc64_all { 'ppc64' }
				cpu_subtype_powerpc_970 { 'ppc970_64' }
				else { '' }
			}
		}
		cpu_type_mc680x0 {
			match subtype {
				cpu_subtype_mc680x0_all { 'mc68030' }
				cpu_subtype_mc68040 { 'mc68040' }
				else { '' }
			}
		}
		cpu_type_mc88000 {
			if subtype == cpu_subtype_mc88000_all { 'm88k' } else { '' }
		}
		else { '' }
	}
}

fn header_filetype_symbol(filetype u32) string {
	return match filetype {
		mh_object { 'object' }
		mh_execute { 'execute' }
		mh_fvmlib { 'fvmlib' }
		mh_core { 'core' }
		mh_preload { 'preload' }
		mh_dylib { 'dylib' }
		mh_dylinker { 'dylinker' }
		mh_bundle { 'bundle' }
		mh_dylib_stub { 'dylib_stub' }
		mh_dsym { 'dsym' }
		mh_kext_bundle { 'kext_bundle' }
		mh_fileset { 'fileset' }
		mh_gpu_execute { 'gpu_execute' }
		mh_gpu_dylib { 'gpu_dylib' }
		else { '' }
	}
}

fn header_structure_value(format string, bytesize int) ruby.Value {
	return ruby.map_value({
		'format':   ruby.string_value(format)
		'bytesize': ruby.int_value(bytesize)
	})
}

fn prelinked_reserved_value(reserved string) ruby.Value {
	bytes := reserved.bytes()
	mut words := []ruby.Value{}
	for offset := 0; offset + 4 <= bytes.len && words.len < 10; offset += 4 {
		words << ruby.int_value(binary.big_endian_u32(bytes[offset..offset + 4]))
	}
	return ruby.array_value(words)
}

pub fn (header &MachoHeaderRecord) to_h() ruby.Value {
	mut values := map[string]ruby.Value{}
	match header.kind {
		.fat_header {
			values['magic'] = ruby.int_value(header.magic)
			values['magic_sym'] = ruby.string_value(header_magic_symbol(header.magic))
			values['nfat_arch'] = ruby.int_value(header.nfat_arch)
			values['structure'] = header_structure_value('L>L>', 8)
		}
		.fat_arch, .fat_arch64 {
			values['cputype'] = ruby.int_value(header.cputype)
			values['cputype_sym'] = ruby.string_value(header_cpu_type_symbol(header.cputype))
			values['cpusubtype'] = ruby.int_value(header.cpusubtype)
			values['cpusubtype_sym'] = ruby.string_value(header_cpu_subtype_symbol(header.cputype, header.cpusubtype))
			values['offset'] = ruby.int_value(i64(header.offset))
			values['size'] = ruby.int_value(i64(header.size))
			values['align'] = ruby.int_value(header.align)
			if header.kind == .fat_arch64 {
				values['reserved'] = ruby.int_value(header.reserved)
				values['structure'] = header_structure_value('L>L>Q>Q>L>L>', 32)
			} else {
				values['structure'] = header_structure_value('L>L>L>L>L>', 20)
			}
		}
		.mach_header, .mach_header64 {
			values['magic'] = ruby.int_value(header.magic)
			values['magic_sym'] = ruby.string_value(header_magic_symbol(header.magic))
			values['cputype'] = ruby.int_value(header.cputype)
			values['cputype_sym'] = ruby.string_value(header_cpu_type_symbol(header.cputype))
			values['cpusubtype'] = ruby.int_value(header.cpusubtype)
			values['cpusubtype_sym'] = ruby.string_value(header_cpu_subtype_symbol(header.cputype, header.cpusubtype))
			values['filetype'] = ruby.int_value(header.filetype)
			values['filetype_sym'] = ruby.string_value(header_filetype_symbol(header.filetype))
			values['ncmds'] = ruby.int_value(header.ncmds)
			values['sizeofcmds'] = ruby.int_value(header.sizeofcmds)
			values['flags'] = ruby.int_value(header.flags)
			values['alignment'] = ruby.int_value(header.alignment())
			if header.kind == .mach_header64 {
				values['reserved'] = ruby.int_value(header.reserved)
				values['structure'] = header_structure_value('L=L=L=L=L=L=L=L=', 32)
			} else {
				values['structure'] = header_structure_value('L=L=L=L=L=L=L=', 28)
			}
		}
		.prelinked_kernel {
			values['signature'] = ruby.int_value(header.signature)
			values['compress_type'] = ruby.int_value(header.compress_type)
			values['adler32'] = ruby.int_value(header.adler32)
			values['uncompressed_size'] = ruby.int_value(header.uncompressed_size)
			values['compressed_size'] = ruby.int_value(header.compressed_size)
			values['prelink_version'] = ruby.int_value(header.prelink_version)
			values['reserved'] = prelinked_reserved_value(header.reserved_bytes)
			values['platform_name'] = ruby.string_value(header.platform_name)
			values['root_path'] = ruby.string_value(header.root_path)
			values['structure'] = header_structure_value('L>L>L>L>L>L>a40a64a256', 384)
		}
	}
	return ruby.map_value(values)
}

fn header_flag_value(flag string) ?u32 {
	value := match flag {
		'MH_NOUNDEFS' { u32(0x1) }
		'MH_INCRLINK' { u32(0x2) }
		'MH_DYLDLINK' { u32(0x4) }
		'MH_BINDATLOAD' { u32(0x8) }
		'MH_PREBOUND' { u32(0x10) }
		'MH_SPLIT_SEGS' { u32(0x20) }
		'MH_LAZY_INIT' { u32(0x40) }
		'MH_TWOLEVEL' { u32(0x80) }
		'MH_FORCE_FLAT' { u32(0x100) }
		'MH_NOMULTIDEFS' { u32(0x200) }
		'MH_NOFIXPREBINDING' { u32(0x400) }
		'MH_PREBINDABLE' { u32(0x800) }
		'MH_ALLMODSBOUND' { u32(0x1000) }
		'MH_SUBSECTIONS_VIA_SYMBOLS' { u32(0x2000) }
		'MH_CANONICAL' { u32(0x4000) }
		'MH_WEAK_DEFINES' { u32(0x8000) }
		'MH_BINDS_TO_WEAK' { u32(0x10000) }
		'MH_ALLOW_STACK_EXECUTION' { u32(0x20000) }
		'MH_ROOT_SAFE' { u32(0x40000) }
		'MH_SETUID_SAFE' { u32(0x80000) }
		'MH_NO_REEXPORTED_DYLIBS' { u32(0x100000) }
		'MH_PIE' { u32(0x200000) }
		'MH_DEAD_STRIPPABLE_DYLIB' { u32(0x400000) }
		'MH_HAS_TLV_DESCRIPTORS' { u32(0x800000) }
		'MH_NO_HEAP_EXECUTION' { u32(0x1000000) }
		'MH_APP_EXTENSION_SAFE' { u32(0x2000000) }
		'MH_NLIST_OUTOFSYNC_WITH_DYLDINFO' { u32(0x4000000) }
		'MH_SIM_SUPPORT' { u32(0x8000000) }
		'MH_IMPLICIT_PAGEZERO' { u32(0x10000000) }
		'MH_DYLIB_IN_CACHE' { u32(0x80000000) }
		else {
			return none
		}
	}
	return value
}

pub fn (header &MachoHeaderRecord) flag(flag string) bool {
	value := header_flag_value(flag) or { return false }
	return header.flags & value == value
}

pub fn (header &MachoHeaderRecord) magic32() bool {
	return header.magic in [mh_magic, mh_cigam]
}

pub fn (header &MachoHeaderRecord) magic64() bool {
	return header.magic in [mh_magic_64, mh_cigam_64]
}

pub fn (header &MachoHeaderRecord) alignment() int {
	return if header.magic32() { 4 } else { 8 }
}

fn macho_header_boundary(header &MachoHeaderRecord) ruby.Value {
	return ruby.structured_value('MachO::Headers::${header.kind}', '#<MachO::Headers::${header.kind}>', {
		'macho_header_address': u64(voidptr(header)).str()
	})
}

fn macho_header_from_args(args []ruby.Value) &MachoHeaderRecord {
	if args.len == 0 {
		panic('MachO header method requires a receiver')
	}
	address := (args[0].attribute('macho_header_address') or {
		panic('${args[0].type_name} has no translated MachO header state')
	}).u64()
	return unsafe { &MachoHeaderRecord(voidptr(address)) }
}

// Ruby method `serialize` at line 526.
pub fn ruby_headers_l526_d1_serialize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_header_from_args(args).serialize() or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 531.
pub fn ruby_headers_l531_d2_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Ruby method `serialize` at line 562.
pub fn ruby_headers_l562_d3_serialize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_header_from_args(args).serialize() or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 567.
pub fn ruby_headers_l567_d4_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Ruby method `serialize` at line 596.
pub fn ruby_headers_l596_d5_serialize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_header_from_args(args).serialize() or { panic(err) }.bytestr())
}

// Ruby method `to_h` at line 601.
pub fn ruby_headers_l601_d6_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Ruby method `flag?(flag)` at line 635.
pub fn ruby_headers_l635_d7_flag(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MachHeader#flag? requires a flag')
	}
	return ruby.bool_value(macho_header_from_args(args).flag(args[1].as_string().trim_string_left(':')))
}

// Ruby method `object?` at line 644.
pub fn ruby_headers_l644_d8_object(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 1)
}

// Ruby method `executable?` at line 649.
pub fn ruby_headers_l649_d9_executable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 2)
}

// Ruby method `fvmlib?` at line 654.
pub fn ruby_headers_l654_d10_fvmlib(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 3)
}

// Ruby method `core?` at line 659.
pub fn ruby_headers_l659_d11_core(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 4)
}

// Ruby method `preload?` at line 664.
pub fn ruby_headers_l664_d12_preload(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 5)
}

// Ruby method `dylib?` at line 669.
pub fn ruby_headers_l669_d13_dylib(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 6)
}

// Ruby method `dylinker?` at line 674.
pub fn ruby_headers_l674_d14_dylinker(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 7)
}

// Ruby method `bundle?` at line 679.
pub fn ruby_headers_l679_d15_bundle(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 8)
}

// Ruby method `dsym?` at line 684.
pub fn ruby_headers_l684_d16_dsym(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 10)
}

// Ruby method `kext?` at line 689.
pub fn ruby_headers_l689_d17_kext(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 11)
}

// Ruby method `fileset?` at line 694.
pub fn ruby_headers_l694_d18_fileset(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).filetype == 12)
}

// Ruby method `magic32?` at line 699.
pub fn ruby_headers_l699_d19_magic32(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).magic32())
}

// Ruby method `magic64?` at line 704.
pub fn ruby_headers_l704_d20_magic64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).magic64())
}

// Ruby method `alignment` at line 709.
pub fn ruby_headers_l709_d21_alignment(args ...ruby.Value) ruby.Value {
	return ruby.int_value(macho_header_from_args(args).alignment())
}

// Ruby method `to_h` at line 714.
pub fn ruby_headers_l714_d22_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Ruby method `to_h` at line 738.
pub fn ruby_headers_l738_d23_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Ruby method `kaslr?` at line 775.
pub fn ruby_headers_l775_d24_kaslr(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).prelink_version >= 1)
}

// Ruby method `lzss?` at line 780.
pub fn ruby_headers_l780_d25_lzss(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).compress_type == comp_type_lzss)
}

// Ruby method `lzvn?` at line 785.
pub fn ruby_headers_l785_d26_lzvn(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_header_from_args(args).compress_type == comp_type_fastlib)
}

// Ruby method `to_h` at line 790.
pub fn ruby_headers_l790_d27_to_h(args ...ruby.Value) ruby.Value {
	return macho_header_from_args(args).to_h()
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # Classes and constants for parsing the headers of Mach-O binaries.
// 5:   module Headers
// 6:     # big-endian fat magic
// 7:     # @api private
// 8:     FAT_MAGIC = 0xcafebabe
// 9:
// 10:     # little-endian fat magic
// 11:     # @note This is defined for completeness, but should never appear in ruby-macho code,
// 12:     #  since fat headers are always big-endian.
// 13:     # @api private
// 14:     FAT_CIGAM = 0xbebafeca
// 15:
// 16:     # 64-bit big-endian fat magic
// 17:     FAT_MAGIC_64 = 0xcafebabf
// 18:
// 19:     # 64-bit little-endian fat magic
// 20:     # @note This is defined for completeness, but should never appear in ruby-macho code,
// 21:     #   since fat headers are always big-endian.
// 22:     FAT_CIGAM_64 = 0xbfbafeca
// 23:
// 24:     # 32-bit big-endian magic
// 25:     # @api private
// 26:     MH_MAGIC = 0xfeedface
// 27:
// 28:     # 32-bit little-endian magic
// 29:     # @api private
// 30:     MH_CIGAM = 0xcefaedfe
// 31:
// 32:     # 64-bit big-endian magic
// 33:     # @api private
// 34:     MH_MAGIC_64 = 0xfeedfacf
// 35:
// 36:     # 64-bit little-endian magic
// 37:     # @api private
// 38:     MH_CIGAM_64 = 0xcffaedfe
// 39:
// 40:     # compressed mach-o magic
// 41:     # @api private
// 42:     COMPRESSED_MAGIC = 0x636f6d70 # "comp"
// 43:
// 44:     # a compressed mach-o slice, using LZSS for compression
// 45:     # @api private
// 46:     COMP_TYPE_LZSS = 0x6c7a7373 # "lzss"
// 47:
// 48:     # a compressed mach-o slice, using LZVN ("FastLib") for compression
// 49:     # @api private
// 50:     COMP_TYPE_FASTLIB = 0x6c7a766e # "lzvn"
// 51:
// 52:     # association of magic numbers to string representations
// 53:     # @api private
// 54:     MH_MAGICS = {
// 55:       FAT_MAGIC => "FAT_MAGIC",
// 56:       FAT_MAGIC_64 => "FAT_MAGIC_64",
// 57:       MH_MAGIC => "MH_MAGIC",
// 58:       MH_CIGAM => "MH_CIGAM",
// 59:       MH_MAGIC_64 => "MH_MAGIC_64",
// 60:       MH_CIGAM_64 => "MH_CIGAM_64",
// 61:     }.freeze
// 62:
// 63:     # mask for 64-bit CPU architectures with 64-bit types
// 64:     # @api private
// 65:     CPU_ARCH_ABI64 = 0x01000000
// 66:
// 67:     # mask for 64-bit CPU architectures with 32-bit types (ILP32)
// 68:     # @see https://github.com/Homebrew/ruby-macho/issues/113
// 69:     # @api private
// 70:     CPU_ARCH_ABI64_32 = 0x02000000
// 71:
// 72:     # any CPU (unused?)
// 73:     # @api private
// 74:     CPU_TYPE_ANY = -1
// 75:
// 76:     # m68k compatible CPUs
// 77:     # @api private
// 78:     CPU_TYPE_MC680X0 = 0x06
// 79:
// 80:     # i386 and later compatible CPUs
// 81:     # @api private
// 82:     CPU_TYPE_I386 = 0x07
// 83:
// 84:     # x86_64 (AMD64) compatible CPUs
// 85:     # @api private
// 86:     CPU_TYPE_X86_64 = (CPU_TYPE_I386 | CPU_ARCH_ABI64)
// 87:
// 88:     # 32-bit ARM compatible CPUs
// 89:     # @api private
// 90:     CPU_TYPE_ARM = 0x0c
// 91:
// 92:     # m88k compatible CPUs
// 93:     # @api private
// 94:     CPU_TYPE_MC88000 = 0xd
// 95:
// 96:     # 64-bit ARM compatible CPUs
// 97:     # @api private
// 98:     CPU_TYPE_ARM64 = (CPU_TYPE_ARM | CPU_ARCH_ABI64)
// 99:
// 100:     # 64-bit ARM compatible CPUs (with 32-bit types)
// 101:     # @see https://github.com/Homebrew/ruby-macho/issues/113
// 102:     # @api private
// 103:     CPU_TYPE_ARM64_32 = (CPU_TYPE_ARM | CPU_ARCH_ABI64_32)
// 104:
// 105:     # PowerPC compatible CPUs
// 106:     # @api private
// 107:     CPU_TYPE_POWERPC = 0x12
// 108:
// 109:     # PowerPC64 compatible CPUs
// 110:     # @api private
// 111:     CPU_TYPE_POWERPC64 = (CPU_TYPE_POWERPC | CPU_ARCH_ABI64)
// 112:
// 113:     # association of cpu types to symbol representations
// 114:     # @api private
// 115:     CPU_TYPES = {
// 116:       CPU_TYPE_ANY => :any,
// 117:       CPU_TYPE_I386 => :i386,
// 118:       CPU_TYPE_X86_64 => :x86_64,
// 119:       CPU_TYPE_ARM => :arm,
// 120:       CPU_TYPE_ARM64 => :arm64,
// 121:       CPU_TYPE_ARM64_32 => :arm64_32,
// 122:       CPU_TYPE_POWERPC => :ppc,
// 123:       CPU_TYPE_POWERPC64 => :ppc64,
// 124:     }.freeze
// 125:
// 126:     # mask for CPU subtype capabilities
// 127:     # @api private
// 128:     CPU_SUBTYPE_MASK = 0xff000000
// 129:
// 130:     # 64-bit libraries (undocumented!)
// 131:     # @see http://llvm.org/docs/doxygen/html/Support_2MachO_8h_source.html
// 132:     # @api private
// 133:     CPU_SUBTYPE_LIB64 = 0x80000000
// 134:
// 135:     # the lowest common sub-type for `CPU_TYPE_I386`
// 136:     # @api private
// 137:     CPU_SUBTYPE_I386 = 3
// 138:
// 139:     # the i486 sub-type for `CPU_TYPE_I386`
// 140:     # @api private
// 141:     CPU_SUBTYPE_486 = 4
// 142:
// 143:     # the i486SX sub-type for `CPU_TYPE_I386`
// 144:     # @api private
// 145:     CPU_SUBTYPE_486SX = 132
// 146:
// 147:     # the i586 (P5, Pentium) sub-type for `CPU_TYPE_I386`
// 148:     # @api private
// 149:     CPU_SUBTYPE_586 = 5
// 150:
// 151:     # @see CPU_SUBTYPE_586
// 152:     # @api private
// 153:     CPU_SUBTYPE_PENT = CPU_SUBTYPE_586
// 154:
// 155:     # the Pentium Pro (P6) sub-type for `CPU_TYPE_I386`
// 156:     # @api private
// 157:     CPU_SUBTYPE_PENTPRO = 22
// 158:
// 159:     # the Pentium II (P6, M3?) sub-type for `CPU_TYPE_I386`
// 160:     # @api private
// 161:     CPU_SUBTYPE_PENTII_M3 = 54
// 162:
// 163:     # the Pentium II (P6, M5?) sub-type for `CPU_TYPE_I386`
// 164:     # @api private
// 165:     CPU_SUBTYPE_PENTII_M5 = 86
// 166:
// 167:     # the Pentium 4 (Netburst) sub-type for `CPU_TYPE_I386`
// 168:     # @api private
// 169:     CPU_SUBTYPE_PENTIUM_4 = 10
// 170:
// 171:     # the lowest common sub-type for `CPU_TYPE_MC680X0`
// 172:     # @api private
// 173:     CPU_SUBTYPE_MC680X0_ALL = 1
// 174:
// 175:     # @see CPU_SUBTYPE_MC680X0_ALL
// 176:     # @api private
// 177:     CPU_SUBTYPE_MC68030 = CPU_SUBTYPE_MC680X0_ALL
// 178:
// 179:     # the 040 subtype for `CPU_TYPE_MC680X0`
// 180:     # @api private
// 181:     CPU_SUBTYPE_MC68040 = 2
// 182:
// 183:     # the 030 subtype for `CPU_TYPE_MC680X0`
// 184:     # @api private
// 185:     CPU_SUBTYPE_MC68030_ONLY = 3
// 186:
// 187:     # the lowest common sub-type for `CPU_TYPE_X86_64`
// 188:     # @api private
// 189:     CPU_SUBTYPE_X86_64_ALL = CPU_SUBTYPE_I386
// 190:
// 191:     # the Haskell sub-type for `CPU_TYPE_X86_64`
// 192:     # @api private
// 193:     CPU_SUBTYPE_X86_64_H = 8
// 194:
// 195:     # the lowest common sub-type for `CPU_TYPE_ARM`
// 196:     # @api private
// 197:     CPU_SUBTYPE_ARM_ALL = 0
// 198:
// 199:     # the v4t sub-type for `CPU_TYPE_ARM`
// 200:     # @api private
// 201:     CPU_SUBTYPE_ARM_V4T = 5
// 202:
// 203:     # the v6 sub-type for `CPU_TYPE_ARM`
// 204:     # @api private
// 205:     CPU_SUBTYPE_ARM_V6 = 6
// 206:
// 207:     # the v5 sub-type for `CPU_TYPE_ARM`
// 208:     # @api private
// 209:     CPU_SUBTYPE_ARM_V5TEJ = 7
// 210:
// 211:     # the xscale (v5 family) sub-type for `CPU_TYPE_ARM`
// 212:     # @api private
// 213:     CPU_SUBTYPE_ARM_XSCALE = 8
// 214:
// 215:     # the v7 sub-type for `CPU_TYPE_ARM`
// 216:     # @api private
// 217:     CPU_SUBTYPE_ARM_V7 = 9
// 218:
// 219:     # the v7f (Cortex A9) sub-type for `CPU_TYPE_ARM`
// 220:     # @api private
// 221:     CPU_SUBTYPE_ARM_V7F = 10
// 222:
// 223:     # the v7s ("Swift") sub-type for `CPU_TYPE_ARM`
// 224:     # @api private
// 225:     CPU_SUBTYPE_ARM_V7S = 11
// 226:
// 227:     # the v7k ("Kirkwood40") sub-type for `CPU_TYPE_ARM`
// 228:     # @api private
// 229:     CPU_SUBTYPE_ARM_V7K = 12
// 230:
// 231:     # the v6m sub-type for `CPU_TYPE_ARM`
// 232:     # @api private
// 233:     CPU_SUBTYPE_ARM_V6M = 14
// 234:
// 235:     # the v7m sub-type for `CPU_TYPE_ARM`
// 236:     # @api private
// 237:     CPU_SUBTYPE_ARM_V7M = 15
// 238:
// 239:     # the v7em sub-type for `CPU_TYPE_ARM`
// 240:     # @api private
// 241:     CPU_SUBTYPE_ARM_V7EM = 16
// 242:
// 243:     # the v8 sub-type for `CPU_TYPE_ARM`
// 244:     # @api private
// 245:     CPU_SUBTYPE_ARM_V8 = 13
// 246:
// 247:     # the lowest common sub-type for `CPU_TYPE_ARM64`
// 248:     # @api private
// 249:     CPU_SUBTYPE_ARM64_ALL = 0
// 250:
// 251:     # the v8 sub-type for `CPU_TYPE_ARM64`
// 252:     # @api private
// 253:     CPU_SUBTYPE_ARM64_V8 = 1
// 254:
// 255:     # the v8 sub-type for `CPU_TYPE_ARM64_32`
// 256:     # @api private
// 257:     CPU_SUBTYPE_ARM64_32_V8 = 1
// 258:
// 259:     # the e (A12) sub-type for `CPU_TYPE_ARM64`
// 260:     # @api private
// 261:     CPU_SUBTYPE_ARM64E = 2
// 262:
// 263:     # the lowest common sub-type for `CPU_TYPE_MC88000`
// 264:     # @api private
// 265:     CPU_SUBTYPE_MC88000_ALL = 0
// 266:
// 267:     # @see CPU_SUBTYPE_MC88000_ALL
// 268:     # @api private
// 269:     CPU_SUBTYPE_MMAX_JPC = CPU_SUBTYPE_MC88000_ALL
// 270:
// 271:     # the 100 sub-type for `CPU_TYPE_MC88000`
// 272:     # @api private
// 273:     CPU_SUBTYPE_MC88100 = 1
// 274:
// 275:     # the 110 sub-type for `CPU_TYPE_MC88000`
// 276:     # @api private
// 277:     CPU_SUBTYPE_MC88110 = 2
// 278:
// 279:     # the lowest common sub-type for `CPU_TYPE_POWERPC`
// 280:     # @api private
// 281:     CPU_SUBTYPE_POWERPC_ALL = 0
// 282:
// 283:     # the 601 sub-type for `CPU_TYPE_POWERPC`
// 284:     # @api private
// 285:     CPU_SUBTYPE_POWERPC_601 = 1
// 286:
// 287:     # the 602 sub-type for `CPU_TYPE_POWERPC`
// 288:     # @api private
// 289:     CPU_SUBTYPE_POWERPC_602 = 2
// 290:
// 291:     # the 603 sub-type for `CPU_TYPE_POWERPC`
// 292:     # @api private
// 293:     CPU_SUBTYPE_POWERPC_603 = 3
// 294:
// 295:     # the 603e (G2) sub-type for `CPU_TYPE_POWERPC`
// 296:     # @api private
// 297:     CPU_SUBTYPE_POWERPC_603E = 4
// 298:
// 299:     # the 603ev sub-type for `CPU_TYPE_POWERPC`
// 300:     # @api private
// 301:     CPU_SUBTYPE_POWERPC_603EV = 5
// 302:
// 303:     # the 604 sub-type for `CPU_TYPE_POWERPC`
// 304:     # @api private
// 305:     CPU_SUBTYPE_POWERPC_604 = 6
// 306:
// 307:     # the 604e sub-type for `CPU_TYPE_POWERPC`
// 308:     # @api private
// 309:     CPU_SUBTYPE_POWERPC_604E = 7
// 310:
// 311:     # the 620 sub-type for `CPU_TYPE_POWERPC`
// 312:     # @api private
// 313:     CPU_SUBTYPE_POWERPC_620 = 8
// 314:
// 315:     # the 750 (G3) sub-type for `CPU_TYPE_POWERPC`
// 316:     # @api private
// 317:     CPU_SUBTYPE_POWERPC_750 = 9
// 318:
// 319:     # the 7400 (G4) sub-type for `CPU_TYPE_POWERPC`
// 320:     # @api private
// 321:     CPU_SUBTYPE_POWERPC_7400 = 10
// 322:
// 323:     # the 7450 (G4 "Voyager") sub-type for `CPU_TYPE_POWERPC`
// 324:     # @api private
// 325:     CPU_SUBTYPE_POWERPC_7450 = 11
// 326:
// 327:     # the 970 (G5) sub-type for `CPU_TYPE_POWERPC`
// 328:     # @api private
// 329:     CPU_SUBTYPE_POWERPC_970 = 100
// 330:
// 331:     # any CPU sub-type for CPU type `CPU_TYPE_POWERPC64`
// 332:     # @api private
// 333:     CPU_SUBTYPE_POWERPC64_ALL = CPU_SUBTYPE_POWERPC_ALL
// 334:
// 335:     # association of CPU types/subtype pairs to symbol representations in
// 336:     # (very) roughly descending order of commonness
// 337:     # @see https://opensource.apple.com/source/cctools/cctools-877.8/libstuff/arch.c
// 338:     # @api private
// 339:     CPU_SUBTYPES = {
// 340:       CPU_TYPE_I386 => {
// 341:         CPU_SUBTYPE_I386 => :i386,
// 342:         CPU_SUBTYPE_486 => :i486,
// 343:         CPU_SUBTYPE_486SX => :i486SX,
// 344:         CPU_SUBTYPE_586 => :i586, # also "pentium" in arch(3)
// 345:         CPU_SUBTYPE_PENTPRO => :i686, # also "pentpro" in arch(3)
// 346:         CPU_SUBTYPE_PENTII_M3 => :pentIIm3,
// 347:         CPU_SUBTYPE_PENTII_M5 => :pentIIm5,
// 348:         CPU_SUBTYPE_PENTIUM_4 => :pentium4,
// 349:       }.freeze,
// 350:       CPU_TYPE_X86_64 => {
// 351:         CPU_SUBTYPE_X86_64_ALL => :x86_64,
// 352:         CPU_SUBTYPE_X86_64_H => :x86_64h,
// 353:       }.freeze,
// 354:       CPU_TYPE_ARM => {
// 355:         CPU_SUBTYPE_ARM_ALL => :arm,
// 356:         CPU_SUBTYPE_ARM_V4T => :armv4t,
// 357:         CPU_SUBTYPE_ARM_V6 => :armv6,
// 358:         CPU_SUBTYPE_ARM_V5TEJ => :armv5,
// 359:         CPU_SUBTYPE_ARM_XSCALE => :xscale,
// 360:         CPU_SUBTYPE_ARM_V7 => :armv7,
// 361:         CPU_SUBTYPE_ARM_V7F => :armv7f,
// 362:         CPU_SUBTYPE_ARM_V7S => :armv7s,
// 363:         CPU_SUBTYPE_ARM_V7K => :armv7k,
// 364:         CPU_SUBTYPE_ARM_V6M => :armv6m,
// 365:         CPU_SUBTYPE_ARM_V7M => :armv7m,
// 366:         CPU_SUBTYPE_ARM_V7EM => :armv7em,
// 367:         CPU_SUBTYPE_ARM_V8 => :armv8,
// 368:       }.freeze,
// 369:       CPU_TYPE_ARM64 => {
// 370:         CPU_SUBTYPE_ARM64_ALL => :arm64,
// 371:         CPU_SUBTYPE_ARM64_V8 => :arm64v8,
// 372:         CPU_SUBTYPE_ARM64E => :arm64e,
// 373:       }.freeze,
// 374:       CPU_TYPE_ARM64_32 => {
// 375:         CPU_SUBTYPE_ARM64_32_V8 => :arm64_32v8,
// 376:       }.freeze,
// 377:       CPU_TYPE_POWERPC => {
// 378:         CPU_SUBTYPE_POWERPC_ALL => :ppc,
// 379:         CPU_SUBTYPE_POWERPC_601 => :ppc601,
// 380:         CPU_SUBTYPE_POWERPC_603 => :ppc603,
// 381:         CPU_SUBTYPE_POWERPC_603E => :ppc603e,
// 382:         CPU_SUBTYPE_POWERPC_603EV => :ppc603ev,
// 383:         CPU_SUBTYPE_POWERPC_604 => :ppc604,
// 384:         CPU_SUBTYPE_POWERPC_604E => :ppc604e,
// 385:         CPU_SUBTYPE_POWERPC_750 => :ppc750,
// 386:         CPU_SUBTYPE_POWERPC_7400 => :ppc7400,
// 387:         CPU_SUBTYPE_POWERPC_7450 => :ppc7450,
// 388:         CPU_SUBTYPE_POWERPC_970 => :ppc970,
// 389:       }.freeze,
// 390:       CPU_TYPE_POWERPC64 => {
// 391:         CPU_SUBTYPE_POWERPC64_ALL => :ppc64,
// 392:         # apparently the only exception to the naming scheme
// 393:         CPU_SUBTYPE_POWERPC_970 => :ppc970_64,
// 394:       }.freeze,
// 395:       CPU_TYPE_MC680X0 => {
// 396:         CPU_SUBTYPE_MC680X0_ALL => :m68k,
// 397:         CPU_SUBTYPE_MC68030 => :mc68030,
// 398:         CPU_SUBTYPE_MC68040 => :mc68040,
// 399:       },
// 400:       CPU_TYPE_MC88000 => {
// 401:         CPU_SUBTYPE_MC88000_ALL => :m88k,
// 402:       },
// 403:     }.freeze
// 404:
// 405:     # relocatable object file
// 406:     # @api private
// 407:     MH_OBJECT = 0x1
// 408:
// 409:     # demand paged executable file
// 410:     # @api private
// 411:     MH_EXECUTE = 0x2
// 412:
// 413:     # fixed VM shared library file
// 414:     # @api private
// 415:     MH_FVMLIB = 0x3
// 416:
// 417:     # core dump file
// 418:     # @api private
// 419:     MH_CORE = 0x4
// 420:
// 421:     # preloaded executable file
// 422:     # @api private
// 423:     MH_PRELOAD = 0x5
// 424:
// 425:     # dynamically bound shared library
// 426:     # @api private
// 427:     MH_DYLIB = 0x6
// 428:
// 429:     # dynamic link editor
// 430:     # @api private
// 431:     MH_DYLINKER = 0x7
// 432:
// 433:     # dynamically bound bundle file
// 434:     # @api private
// 435:     MH_BUNDLE = 0x8
// 436:
// 437:     # shared library stub for static linking only, no section contents
// 438:     # @api private
// 439:     MH_DYLIB_STUB = 0x9
// 440:
// 441:     # companion file with only debug sections
// 442:     # @api private
// 443:     MH_DSYM = 0xa
// 444:
// 445:     # x86_64 kexts
// 446:     # @api private
// 447:     MH_KEXT_BUNDLE = 0xb
// 448:
// 449:     # a set of Mach-Os, running in the same userspace, sharing a linkedit.  The kext collection files are an example
// 450:     # of this object type
// 451:     # @api private
// 452:     MH_FILESET = 0xc
// 453:
// 454:     # gpu program
// 455:     # @api private
// 456:     MH_GPU_EXECUTE = 0xd
// 457:
// 458:     # gpu support functions
// 459:     # @api private
// 460:     MH_GPU_DYLIB = 0xe
// 461:
// 462:     # association of filetypes to Symbol representations
// 463:     # @api private
// 464:     MH_FILETYPES = {
// 465:       MH_OBJECT => :object,
// 466:       MH_EXECUTE => :execute,
// 467:       MH_FVMLIB => :fvmlib,
// 468:       MH_CORE => :core,
// 469:       MH_PRELOAD => :preload,
// 470:       MH_DYLIB => :dylib,
// 471:       MH_DYLINKER => :dylinker,
// 472:       MH_BUNDLE => :bundle,
// 473:       MH_DYLIB_STUB => :dylib_stub,
// 474:       MH_DSYM => :dsym,
// 475:       MH_KEXT_BUNDLE => :kext_bundle,
// 476:       MH_FILESET => :fileset,
// 477:       MH_GPU_EXECUTE => :gpu_execute,
// 478:       MH_GPU_DYLIB => :gpu_dylib,
// 479:     }.freeze
// 480:
// 481:     # association of mach header flag symbols to values
// 482:     # @api private
// 483:     MH_FLAGS = {
// 484:       :MH_NOUNDEFS => 0x1,
// 485:       :MH_INCRLINK => 0x2,
// 486:       :MH_DYLDLINK => 0x4,
// 487:       :MH_BINDATLOAD => 0x8,
// 488:       :MH_PREBOUND => 0x10,
// 489:       :MH_SPLIT_SEGS => 0x20,
// 490:       :MH_LAZY_INIT => 0x40,
// 491:       :MH_TWOLEVEL => 0x80,
// 492:       :MH_FORCE_FLAT => 0x100,
// 493:       :MH_NOMULTIDEFS => 0x200,
// 494:       :MH_NOFIXPREBINDING => 0x400,
// 495:       :MH_PREBINDABLE => 0x800,
// 496:       :MH_ALLMODSBOUND => 0x1000,
// 497:       :MH_SUBSECTIONS_VIA_SYMBOLS => 0x2000,
// 498:       :MH_CANONICAL => 0x4000,
// 499:       :MH_WEAK_DEFINES => 0x8000,
// 500:       :MH_BINDS_TO_WEAK => 0x10000,
// 501:       :MH_ALLOW_STACK_EXECUTION => 0x20000,
// 502:       :MH_ROOT_SAFE => 0x40000,
// 503:       :MH_SETUID_SAFE => 0x80000,
// 504:       :MH_NO_REEXPORTED_DYLIBS => 0x100000,
// 505:       :MH_PIE => 0x200000,
// 506:       :MH_DEAD_STRIPPABLE_DYLIB => 0x400000,
// 507:       :MH_HAS_TLV_DESCRIPTORS => 0x800000,
// 508:       :MH_NO_HEAP_EXECUTION => 0x1000000,
// 509:       :MH_APP_EXTENSION_SAFE => 0x2000000,
// 510:       :MH_NLIST_OUTOFSYNC_WITH_DYLDINFO => 0x4000000,
// 511:       :MH_SIM_SUPPORT => 0x8000000,
// 512:       :MH_IMPLICIT_PAGEZERO => 0x10000000,
// 513:       :MH_DYLIB_IN_CACHE => 0x80000000,
// 514:     }.freeze
// 515:
// 516:     # Fat binary header structure
// 517:     # @see MachO::FatArch
// 518:     class FatHeader < MachOStructure
// 519:       # @return [Integer] the magic number of the header (and file)
// 520:       field :magic, :uint32, :endian => :big
// 521:
// 522:       # @return [Integer] the number of fat architecture structures following the header
// 523:       field :nfat_arch, :uint32, :endian => :big
// 524:
// 525:       # @return [String] the serialized fields of the fat header
// 526:       def serialize
// 527:         [magic, nfat_arch].pack(self.class.format)
// 528:       end
// 529:
// 530:       # @return [Hash] a hash representation of this {FatHeader}
// 531:       def to_h
// 532:         {
// 533:           "magic" => magic,
// 534:           "magic_sym" => MH_MAGICS[magic],
// 535:           "nfat_arch" => nfat_arch,
// 536:         }.merge super
// 537:       end
// 538:     end
// 539:
// 540:     # 32-bit fat binary header architecture structure. A 32-bit fat Mach-O has one or more of
// 541:     #  these, indicating one or more internal Mach-O blobs.
// 542:     # @note "32-bit" indicates the fact that this structure stores 32-bit offsets, not that the
// 543:     #  Mach-Os that it points to necessarily *are* 32-bit.
// 544:     # @see MachO::Headers::FatHeader
// 545:     class FatArch < MachOStructure
// 546:       # @return [Integer] the CPU type of the Mach-O
// 547:       field :cputype, :uint32, :endian => :big
// 548:
// 549:       # @return [Integer] the CPU subtype of the Mach-O
// 550:       field :cpusubtype, :uint32, :endian => :big, :mask => CPU_SUBTYPE_MASK
// 551:
// 552:       # @return [Integer] the file offset to the beginning of the Mach-O data
// 553:       field :offset, :uint32, :endian => :big
// 554:
// 555:       # @return [Integer] the size, in bytes, of the Mach-O data
// 556:       field :size, :uint32, :endian => :big
// 557:
// 558:       # @return [Integer] the alignment, as a power of 2
// 559:       field :align, :uint32, :endian => :big
// 560:
// 561:       # @return [String] the serialized fields of the fat arch
// 562:       def serialize
// 563:         [cputype, cpusubtype, offset, size, align].pack(self.class.format)
// 564:       end
// 565:
// 566:       # @return [Hash] a hash representation of this {FatArch}
// 567:       def to_h
// 568:         {
// 569:           "cputype" => cputype,
// 570:           "cputype_sym" => CPU_TYPES[cputype],
// 571:           "cpusubtype" => cpusubtype,
// 572:           "cpusubtype_sym" => CPU_SUBTYPES[cputype][cpusubtype],
// 573:           "offset" => offset,
// 574:           "size" => size,
// 575:           "align" => align,
// 576:         }.merge super
// 577:       end
// 578:     end
// 579:
// 580:     # 64-bit fat binary header architecture structure. A 64-bit fat Mach-O has one or more of
// 581:     #  these, indicating one or more internal Mach-O blobs.
// 582:     # @note "64-bit" indicates the fact that this structure stores 64-bit offsets, not that the
// 583:     #  Mach-Os that it points to necessarily *are* 64-bit.
// 584:     # @see MachO::Headers::FatHeader
// 585:     class FatArch64 < FatArch
// 586:       # @return [Integer] the file offset to the beginning of the Mach-O data
// 587:       field :offset, :uint64, :endian => :big
// 588:
// 589:       # @return [Integer] the size, in bytes, of the Mach-O data
// 590:       field :size, :uint64, :endian => :big
// 591:
// 592:       # @return [void]
// 593:       field :reserved, :uint32, :endian => :big, :default => 0
// 594:
// 595:       # @return [String] the serialized fields of the fat arch
// 596:       def serialize
// 597:         [cputype, cpusubtype, offset, size, align, reserved].pack(self.class.format)
// 598:       end
// 599:
// 600:       # @return [Hash] a hash representation of this {FatArch64}
// 601:       def to_h
// 602:         {
// 603:           "reserved" => reserved,
// 604:         }.merge super
// 605:       end
// 606:     end
// 607:
// 608:     # 32-bit Mach-O file header structure
// 609:     class MachHeader < MachOStructure
// 610:       # @return [Integer] the magic number
// 611:       field :magic, :uint32
// 612:
// 613:       # @return [Integer] the CPU type of the Mach-O
// 614:       field :cputype, :uint32
// 615:
// 616:       # @return [Integer] the CPU subtype of the Mach-O
// 617:       field :cpusubtype, :uint32, :mask => CPU_SUBTYPE_MASK
// 618:
// 619:       # @return [Integer] the file type of the Mach-O
// 620:       field :filetype, :uint32
// 621:
// 622:       # @return [Integer] the number of load commands in the Mach-O
// 623:       field :ncmds, :uint32
// 624:
// 625:       # @return [Integer] the size of all load commands, in bytes, in the Mach-O
// 626:       field :sizeofcmds, :uint32
// 627:
// 628:       # @return [Integer] the header flags associated with the Mach-O
// 629:       field :flags, :uint32
// 630:
// 631:       # @example
// 632:       #  puts "this mach-o has position-independent execution" if header.flag?(:MH_PIE)
// 633:       # @param flag [Symbol] a mach header flag symbol
// 634:       # @return [Boolean] true if `flag` is present in the header's flag section
// 635:       def flag?(flag)
// 636:         flag = MH_FLAGS[flag]
// 637:
// 638:         return false if flag.nil?
// 639:
// 640:         flags & flag == flag
// 641:       end
// 642:
// 643:       # @return [Boolean] whether or not the file is of type `MH_OBJECT`
// 644:       def object?
// 645:         filetype == Headers::MH_OBJECT
// 646:       end
// 647:
// 648:       # @return [Boolean] whether or not the file is of type `MH_EXECUTE`
// 649:       def executable?
// 650:         filetype == Headers::MH_EXECUTE
// 651:       end
// 652:
// 653:       # @return [Boolean] whether or not the file is of type `MH_FVMLIB`
// 654:       def fvmlib?
// 655:         filetype == Headers::MH_FVMLIB
// 656:       end
// 657:
// 658:       # @return [Boolean] whether or not the file is of type `MH_CORE`
// 659:       def core?
// 660:         filetype == Headers::MH_CORE
// 661:       end
// 662:
// 663:       # @return [Boolean] whether or not the file is of type `MH_PRELOAD`
// 664:       def preload?
// 665:         filetype == Headers::MH_PRELOAD
// 666:       end
// 667:
// 668:       # @return [Boolean] whether or not the file is of type `MH_DYLIB`
// 669:       def dylib?
// 670:         filetype == Headers::MH_DYLIB
// 671:       end
// 672:
// 673:       # @return [Boolean] whether or not the file is of type `MH_DYLINKER`
// 674:       def dylinker?
// 675:         filetype == Headers::MH_DYLINKER
// 676:       end
// 677:
// 678:       # @return [Boolean] whether or not the file is of type `MH_BUNDLE`
// 679:       def bundle?
// 680:         filetype == Headers::MH_BUNDLE
// 681:       end
// 682:
// 683:       # @return [Boolean] whether or not the file is of type `MH_DSYM`
// 684:       def dsym?
// 685:         filetype == Headers::MH_DSYM
// 686:       end
// 687:
// 688:       # @return [Boolean] whether or not the file is of type `MH_KEXT_BUNDLE`
// 689:       def kext?
// 690:         filetype == Headers::MH_KEXT_BUNDLE
// 691:       end
// 692:
// 693:       # @return [Boolean] whether or not the file is of type `MH_FILESET`
// 694:       def fileset?
// 695:         filetype == Headers::MH_FILESET
// 696:       end
// 697:
// 698:       # @return [Boolean] true if the Mach-O has 32-bit magic, false otherwise
// 699:       def magic32?
// 700:         Utils.magic32?(magic)
// 701:       end
// 702:
// 703:       # @return [Boolean] true if the Mach-O has 64-bit magic, false otherwise
// 704:       def magic64?
// 705:         Utils.magic64?(magic)
// 706:       end
// 707:
// 708:       # @return [Integer] the file's internal alignment
// 709:       def alignment
// 710:         magic32? ? 4 : 8
// 711:       end
// 712:
// 713:       # @return [Hash] a hash representation of this {MachHeader}
// 714:       def to_h
// 715:         {
// 716:           "magic" => magic,
// 717:           "magic_sym" => MH_MAGICS[magic],
// 718:           "cputype" => cputype,
// 719:           "cputype_sym" => CPU_TYPES[cputype],
// 720:           "cpusubtype" => cpusubtype,
// 721:           "cpusubtype_sym" => CPU_SUBTYPES[cputype][cpusubtype],
// 722:           "filetype" => filetype,
// 723:           "filetype_sym" => MH_FILETYPES[filetype],
// 724:           "ncmds" => ncmds,
// 725:           "sizeofcmds" => sizeofcmds,
// 726:           "flags" => flags,
// 727:           "alignment" => alignment,
// 728:         }.merge super
// 729:       end
// 730:     end
// 731:
// 732:     # 64-bit Mach-O file header structure
// 733:     class MachHeader64 < MachHeader
// 734:       # @return [void]
// 735:       field :reserved, :uint32
// 736:
// 737:       # @return [Hash] a hash representation of this {MachHeader64}
// 738:       def to_h
// 739:         {
// 740:           "reserved" => reserved,
// 741:         }.merge super
// 742:       end
// 743:     end
// 744:
// 745:     # Prelinked kernel/"kernelcache" header structure
// 746:     class PrelinkedKernelHeader < MachOStructure
// 747:       # @return [Integer] the magic number for a compressed header ({COMPRESSED_MAGIC})
// 748:       field :signature, :uint32, :endian => :big
// 749:
// 750:       # @return [Integer] the type of compression used
// 751:       field :compress_type, :uint32, :endian => :big
// 752:
// 753:       # @return [Integer] a checksum for the uncompressed data
// 754:       field :adler32, :uint32, :endian => :big
// 755:
// 756:       # @return [Integer] the size of the uncompressed data, in bytes
// 757:       field :uncompressed_size, :uint32, :endian => :big
// 758:
// 759:       # @return [Integer] the size of the compressed data, in bytes
// 760:       field :compressed_size, :uint32, :endian => :big
// 761:
// 762:       # @return [Integer] the version of the prelink format
// 763:       field :prelink_version, :uint32, :endian => :big
// 764:
// 765:       # @return [void]
// 766:       field :reserved, :string, :size => 40, :unpack => "L>10"
// 767:
// 768:       # @return [void]
// 769:       field :platform_name, :string, :size => 64
// 770:
// 771:       # @return [void]
// 772:       field :root_path, :string, :size => 256
// 773:
// 774:       # @return [Boolean] whether this prelinked kernel supports KASLR
// 775:       def kaslr?
// 776:         prelink_version >= 1
// 777:       end
// 778:
// 779:       # @return [Boolean] whether this prelinked kernel is compressed with LZSS
// 780:       def lzss?
// 781:         compress_type == COMP_TYPE_LZSS
// 782:       end
// 783:
// 784:       # @return [Boolean] whether this prelinked kernel is compressed with LZVN
// 785:       def lzvn?
// 786:         compress_type == COMP_TYPE_FASTLIB
// 787:       end
// 788:
// 789:       # @return [Hash] a hash representation of this {PrelinkedKernelHeader}
// 790:       def to_h
// 791:         {
// 792:           "signature" => signature,
// 793:           "compress_type" => compress_type,
// 794:           "adler32" => adler32,
// 795:           "uncompressed_size" => uncompressed_size,
// 796:           "compressed_size" => compressed_size,
// 797:           "prelink_version" => prelink_version,
// 798:           "reserved" => reserved,
// 799:           "platform_name" => platform_name,
// 800:           "root_path" => root_path,
// 801:         }.merge super
// 802:       end
// 803:     end
// 804:   end
// 805: end
