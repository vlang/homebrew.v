module macho

import brew_runtime
import crypto.sha1
import crypto.sha256
import encoding.binary

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/code_signing.rb`.
// The original source is retained below until every stub has a typed V body.
pub const csmagic_requirement = u32(0xfade0c00)
pub const csmagic_requirements = u32(0xfade0c01)
pub const csmagic_code_directory = u32(0xfade0c02)
pub const csmagic_blob_wrapper = u32(0xfade0b01)
pub const csmagic_embedded_signature = u32(0xfade0cc0)
pub const csmagic_detached_signature = u32(0xfade0cc1)
pub const csmagic_embedded_entitlements = u32(0xfade7171)
pub const csmagic_embedded_der_entitlements = u32(0xfade7172)
pub const csmagic_embedded_launch_constraint = u32(0xfade8181)
pub const csmagic_entitlement = csmagic_embedded_entitlements
pub const csmagic_entitlement_der = csmagic_embedded_der_entitlements
pub const csslot_code_directory = u32(0)
pub const csslot_info_slot = u32(1)
pub const csslot_requirements = u32(2)
pub const csslot_entitlements = u32(5)
pub const csslot_der_entitlements = u32(7)
pub const csslot_alternate_code_directories = u32(0x1000)
pub const csslot_signature_slot = u32(0x10000)
pub const cs_hash_type_sha1 = u8(1)
pub const cs_hash_type_sha256 = u8(2)
pub const cs_hash_type_sha256_truncated = u8(3)
pub const cs_hash_type_sha384 = u8(4)
pub const cs_adhoc = u32(0x2)
pub const cs_hard = u32(0x100)
pub const cs_runtime = u32(0x10000)
pub const cs_linker_signed = u32(0x20000)
pub const cs_execseg_main_binary = u64(0x1)
pub const cs_execseg_jit = u64(0x40)
pub const cs_supports_code_limit64 = u32(0x20300)
pub const cs_supports_execseg = u32(0x20400)
pub const cs_supports_runtime = u32(0x20500)
pub const cs_supports_linkage = u32(0x20600)
pub const code_signing_page_size = 4096

fn code_signing_failure(message string) &MachoErrorInfo {
	return new_macho_error(.code_signing, message)
}

pub enum CodeSigningBlobKind {
	blob
	super_blob
	code_directory
}

pub struct BlobIndex {
pub:
	type_  u32
	offset u32
}

@[heap]
pub struct CodeSigningBlob {
pub mut:
	kind                        CodeSigningBlobKind
	magic                       u32
	length                      u32
	raw_data                    []u8
	count                       u32
	indices                     []BlobIndex
	blobs                       []&CodeSigningBlob
	version                     u32
	flags                       u32
	hash_offset                 u32
	ident_offset                u32
	n_special_slots             u32
	n_code_slots                u32
	stored_code_limit           u32
	hash_size                   u8
	hash_type                   u8
	platform                    u8
	page_size                   u8
	scatter_offset              u32
	team_offset                 u32
	code_limit64                u64
	exec_seg_base               u64
	exec_seg_limit              u64
	exec_seg_flags              u64
	runtime                     u32
	pre_encrypt_offset          u32
	linkage_hash_type           u8
	linkage_application_type    u8
	linkage_application_subtype u16
	linkage_offset              u32
	linkage_size                u32
	identifier                  string
}

pub struct CodeDirectoryBuildOptions {
pub:
	identifier       string
	hash_type        u8
	flags            u32
	special_slots    map[u32][]u8
	exec_seg_base    u64
	exec_seg_limit   u64
	exec_seg_flags   u64
	runtime          u32
	calculate_hashes bool = true
}

fn code_signing_u32(data []u8, offset int) !u32 {
	if offset < 0 || offset + 4 > data.len {
		return code_signing_failure('code-signing data is truncated')
	}
	return binary.big_endian_u32(data[offset..offset + 4])
}

fn code_signing_u64(data []u8, offset int) !u64 {
	if offset < 0 || offset + 8 > data.len {
		return code_signing_failure('code-signing data is truncated')
	}
	return binary.big_endian_u64(data[offset..offset + 8])
}

fn code_signing_put_u16(mut data []u8, offset int, value u16) {
	binary.big_endian_put_u16_at(mut data, value, offset)
}

fn code_signing_put_u32(mut data []u8, offset int, value u32) {
	binary.big_endian_put_u32_at(mut data, value, offset)
}

fn code_signing_put_u64(mut data []u8, offset int, value u64) {
	binary.big_endian_put_u64_at(mut data, value, offset)
}

fn code_signing_magic_symbol(magic u32) string {
	return match magic {
		csmagic_requirement { 'CSMAGIC_REQUIREMENT' }
		csmagic_requirements { 'CSMAGIC_REQUIREMENTS' }
		csmagic_code_directory { 'CSMAGIC_CODEDIRECTORY' }
		csmagic_blob_wrapper { 'CSMAGIC_BLOBWRAPPER' }
		csmagic_embedded_signature { 'CSMAGIC_EMBEDDED_SIGNATURE' }
		csmagic_detached_signature { 'CSMAGIC_DETACHED_SIGNATURE' }
		csmagic_embedded_entitlements { 'CSMAGIC_EMBEDDED_ENTITLEMENTS' }
		csmagic_embedded_der_entitlements { 'CSMAGIC_EMBEDDED_DER_ENTITLEMENTS' }
		csmagic_embedded_launch_constraint { 'CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT' }
		else { '' }
	}
}

fn code_signing_hash_symbol(hash_type u8) string {
	return match hash_type {
		cs_hash_type_sha1 { 'CS_HASHTYPE_SHA1' }
		cs_hash_type_sha256 { 'CS_HASHTYPE_SHA256' }
		cs_hash_type_sha256_truncated { 'CS_HASHTYPE_SHA256_TRUNCATED' }
		cs_hash_type_sha384 { 'CS_HASHTYPE_SHA384' }
		else { '' }
	}
}

fn code_signing_digest(hash_type u8, data []u8) ![]u8 {
	return match hash_type {
		cs_hash_type_sha1 { sha1.sum(data) }
		cs_hash_type_sha256 { sha256.sum(data) }
		else { error('key not found: ${hash_type}') }
	}
}

fn parse_code_directory_fields(mut blob CodeSigningBlob) ! {
	if blob.magic != csmagic_code_directory {
		return code_signing_failure('invalid CodeDirectory magic: 0x${blob.magic.hex()}')
	}
	if blob.length < 44 {
		return code_signing_failure('CodeDirectory is truncated')
	}
	blob.version = code_signing_u32(blob.raw_data, 8)!
	blob.flags = code_signing_u32(blob.raw_data, 12)!
	blob.hash_offset = code_signing_u32(blob.raw_data, 16)!
	blob.ident_offset = code_signing_u32(blob.raw_data, 20)!
	blob.n_special_slots = code_signing_u32(blob.raw_data, 24)!
	blob.n_code_slots = code_signing_u32(blob.raw_data, 28)!
	blob.stored_code_limit = code_signing_u32(blob.raw_data, 32)!
	blob.hash_size = blob.raw_data[36]
	blob.hash_type = blob.raw_data[37]
	blob.platform = blob.raw_data[38]
	blob.page_size = blob.raw_data[39]
	mut fixed_size := 44
	if blob.version >= 0x20100 {
		blob.scatter_offset = blob.unpack_uint32(44)!
		fixed_size = 48
	}
	if blob.version >= 0x20200 {
		blob.team_offset = blob.unpack_uint32(48)!
		fixed_size = 52
	}
	if blob.version >= cs_supports_code_limit64 {
		if blob.length < 64 {
			return code_signing_failure('CodeDirectory is truncated')
		}
		blob.code_limit64 = code_signing_u64(blob.raw_data, 56)!
		fixed_size = 64
	}
	if blob.version >= cs_supports_execseg {
		if blob.length < 88 {
			return code_signing_failure('CodeDirectory is truncated')
		}
		blob.exec_seg_base = code_signing_u64(blob.raw_data, 64)!
		blob.exec_seg_limit = code_signing_u64(blob.raw_data, 72)!
		blob.exec_seg_flags = code_signing_u64(blob.raw_data, 80)!
		fixed_size = 88
	}
	if blob.version >= cs_supports_runtime {
		if blob.length < 96 {
			return code_signing_failure('CodeDirectory is truncated')
		}
		blob.runtime = code_signing_u32(blob.raw_data, 88)!
		blob.pre_encrypt_offset = code_signing_u32(blob.raw_data, 92)!
		fixed_size = 96
	}
	if blob.version >= cs_supports_linkage {
		if blob.length < 108 {
			return code_signing_failure('CodeDirectory is truncated')
		}
		blob.linkage_hash_type = blob.raw_data[96]
		blob.linkage_application_type = blob.raw_data[97]
		blob.linkage_application_subtype = binary.big_endian_u16(blob.raw_data[98..100])
		blob.linkage_offset = code_signing_u32(blob.raw_data, 100)!
		blob.linkage_size = code_signing_u32(blob.raw_data, 104)!
		fixed_size = 108
	}
	if blob.ident_offset < u32(fixed_size) || blob.ident_offset >= blob.length {
		return code_signing_failure('CodeDirectory identifier offset is invalid')
	}
	mut terminator := -1
	for index := int(blob.ident_offset); index < int(blob.length); index++ {
		if blob.raw_data[index] == 0 {
			terminator = index
			break
		}
	}
	if terminator < 0 {
		return code_signing_failure('CodeDirectory identifier is unterminated')
	}
	special_bytes := u64(blob.n_special_slots) * u64(blob.hash_size)
	code_bytes := u64(blob.n_code_slots) * u64(blob.hash_size)
	if blob.hash_size == 0 || blob.hash_offset < u32(fixed_size) || u64(blob.hash_offset) < special_bytes || u64(blob.hash_offset) - special_bytes < u64(terminator + 1) || u64(blob.hash_offset) + code_bytes > u64(blob.length) {
		return code_signing_failure('CodeDirectory hash range is invalid')
	}
	blob.identifier = blob.raw_data[int(blob.ident_offset)..terminator].bytestr()
}

fn parse_super_blob_fields(mut blob CodeSigningBlob) ! {
	if blob.magic != csmagic_embedded_signature {
		return code_signing_failure('invalid embedded-signature magic: 0x${blob.magic.hex()}')
	}
	if blob.length < 12 {
		return code_signing_failure('code-signing SuperBlob is truncated')
	}
	blob.count = code_signing_u32(blob.raw_data, 8)!
	index_end := u64(12) + u64(blob.count) * 8
	if index_end > u64(blob.length) {
		return code_signing_failure('code-signing SuperBlob index is truncated')
	}
	for index in 0 .. int(blob.count) {
		offset := 12 + index * 8
		entry := BlobIndex{
			type_: code_signing_u32(blob.raw_data, offset)!
			offset: code_signing_u32(blob.raw_data, offset + 4)!
		}
		if u64(entry.offset) < index_end || u64(entry.offset) + 8 > u64(blob.length) {
			return code_signing_failure('code-signing blob offset is invalid: ${entry.offset}')
		}
		blob.indices << entry
		blob.blobs << parse_code_signing_blob(blob.raw_data[int(entry.offset)..int(blob.length)])!
	}
}

pub fn parse_code_signing_blob(data []u8) !&CodeSigningBlob {
	if data.len < 8 {
		return code_signing_failure('code-signing blob is truncated')
	}
	magic := code_signing_u32(data, 0)!
	length := code_signing_u32(data, 4)!
	if length < 8 || u64(length) > u64(data.len) {
		return code_signing_failure('invalid code-signing blob length: ${length}')
	}
	mut blob := &CodeSigningBlob{
		kind: .blob
		magic: magic
		length: length
		raw_data: data[..int(length)].clone()
	}
	match magic {
		csmagic_code_directory {
			blob.kind = .code_directory
			parse_code_directory_fields(mut blob)!
		}
		csmagic_embedded_signature {
			blob.kind = .super_blob
			parse_super_blob_fields(mut blob)!
		}
		else {}
	}
	return blob
}

pub fn (blob &CodeSigningBlob) serialize() []u8 {
	return blob.raw_data.clone()
}

pub fn (blob &CodeSigningBlob) magic_sym() string {
	return code_signing_magic_symbol(blob.magic)
}

pub fn (blob &CodeSigningBlob) code_limit() u64 {
	return if blob.version >= cs_supports_code_limit64 && blob.code_limit64 > 0 {
		blob.code_limit64
	} else {
		blob.stored_code_limit
	}
}

pub fn (blob &CodeSigningBlob) code_hash(slot int) ?[]u8 {
	if slot < 0 || slot >= int(blob.n_code_slots) {
		return none
	}
	offset := int(blob.hash_offset) + slot * int(blob.hash_size)
	return blob.raw_data[offset..offset + int(blob.hash_size)].clone()
}

pub fn (blob &CodeSigningBlob) hash_type_sym() string {
	return code_signing_hash_symbol(blob.hash_type)
}

pub fn (blob &CodeSigningBlob) special_hash(slot int) ?[]u8 {
	if slot <= 0 || slot > int(blob.n_special_slots) {
		return none
	}
	offset := int(blob.hash_offset) - slot * int(blob.hash_size)
	return blob.raw_data[offset..offset + int(blob.hash_size)].clone()
}

pub fn (blob &CodeSigningBlob) unpack_uint32(offset int) !u32 {
	if int(blob.length) < offset + 4 {
		return code_signing_failure('CodeDirectory is truncated')
	}
	return code_signing_u32(blob.raw_data, offset)
}

pub fn (blob &CodeSigningBlob) blob(slot u32) ?&CodeSigningBlob {
	for index, entry in blob.indices {
		if entry.type_ == slot {
			return blob.blobs[index]
		}
	}
	return none
}

pub fn (blob &CodeSigningBlob) each_blob_index() []BlobIndex {
	return blob.indices.clone()
}

pub fn (blob &CodeSigningBlob) each_blob() []&CodeSigningBlob {
	return blob.blobs.clone()
}

pub fn (blob &CodeSigningBlob) to_h() brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	values['magic'] = brew_runtime.int_value(blob.magic)
	values['magic_sym'] = brew_runtime.string_value(blob.magic_sym())
	values['length'] = brew_runtime.int_value(blob.length)
	if blob.kind == .super_blob {
		values['count'] = brew_runtime.int_value(blob.count)
		values['indices'] = brew_runtime.array_value(blob.indices.map(brew_runtime.map_value({
			'type':   brew_runtime.int_value(it.type_)
			'offset': brew_runtime.int_value(it.offset)
		})))
		values['blobs'] = brew_runtime.array_value(blob.blobs.map(it.to_h()))
	} else if blob.kind == .code_directory {
		values['version'] = brew_runtime.int_value(blob.version)
		values['flags'] = brew_runtime.int_value(blob.flags)
		values['identifier'] = brew_runtime.string_value(blob.identifier)
		values['hash_offset'] = brew_runtime.int_value(blob.hash_offset)
		values['n_special_slots'] = brew_runtime.int_value(blob.n_special_slots)
		values['n_code_slots'] = brew_runtime.int_value(blob.n_code_slots)
		values['code_limit'] = brew_runtime.int_value(i64(blob.code_limit()))
		values['hash_size'] = brew_runtime.int_value(blob.hash_size)
		values['hash_type'] = brew_runtime.int_value(blob.hash_type)
		values['hash_type_sym'] = brew_runtime.string_value(blob.hash_type_sym())
		values['page_size'] = brew_runtime.int_value(blob.page_size)
	}
	return brew_runtime.map_value(values)
}

pub fn build_super_blob(entries map[u32][]u8) []u8 {
	mut slots := entries.keys()
	slots.sort()
	mut offset := 12 + slots.len * 8
	mut data := []u8{len: offset}
	code_signing_put_u32(mut data, 0, csmagic_embedded_signature)
	code_signing_put_u32(mut data, 8, u32(slots.len))
	for index, slot in slots {
		code_signing_put_u32(mut data, 12 + index * 8, slot)
		code_signing_put_u32(mut data, 16 + index * 8, u32(offset))
		data << entries[slot]
		offset += entries[slot].len
	}
	code_signing_put_u32(mut data, 4, u32(offset))
	return data
}

pub fn build_code_directory(source []u8, options CodeDirectoryBuildOptions) ![]u8 {
	hash_size := match options.hash_type {
		cs_hash_type_sha1 { 20 }
		cs_hash_type_sha256 { 32 }
		else {
			return error('key not found: ${options.hash_type}')
		}
	}
	version := if options.runtime == 0 { cs_supports_execseg } else { cs_supports_runtime }
	fixed_size := if options.runtime == 0 { 88 } else { 96 }
	mut identifier := options.identifier.bytes().filter(it != 0)
	identifier << 0
	mut n_special_slots := u32(0)
	for slot in options.special_slots.keys() {
		if slot > n_special_slots {
			n_special_slots = slot
		}
	}
	n_code_slots := (source.len + code_signing_page_size - 1) / code_signing_page_size
	hash_offset := fixed_size + identifier.len + int(n_special_slots) * hash_size
	length := hash_offset + n_code_slots * hash_size
	mut data := []u8{len: fixed_size}
	code_signing_put_u32(mut data, 0, csmagic_code_directory)
	code_signing_put_u32(mut data, 4, u32(length))
	code_signing_put_u32(mut data, 8, version)
	code_signing_put_u32(mut data, 12, options.flags)
	code_signing_put_u32(mut data, 16, u32(hash_offset))
	code_signing_put_u32(mut data, 20, u32(fixed_size))
	code_signing_put_u32(mut data, 24, n_special_slots)
	code_signing_put_u32(mut data, 28, u32(n_code_slots))
	code_signing_put_u32(mut data, 32, if u64(source.len) > u64(0xffff_ffff) {
		u32(0xffff_ffff)
	} else {
		u32(source.len)
	})
	data[36] = u8(hash_size)
	data[37] = options.hash_type
	data[38] = 0
	data[39] = 12
	code_signing_put_u64(mut data, 56, if u64(source.len) > u64(0xffff_ffff) {
		u64(source.len)
	} else {
		u64(0)
	})
	code_signing_put_u64(mut data, 64, options.exec_seg_base)
	code_signing_put_u64(mut data, 72, options.exec_seg_limit)
	code_signing_put_u64(mut data, 80, options.exec_seg_flags)
	if options.runtime != 0 {
		code_signing_put_u32(mut data, 88, options.runtime)
		code_signing_put_u32(mut data, 92, 0)
	}
	data << identifier
	if options.calculate_hashes {
		for slot := int(n_special_slots); slot >= 1; slot-- {
			if u32(slot) in options.special_slots {
				data << code_signing_digest(options.hash_type, options.special_slots[u32(slot)])!
			} else {
				data << []u8{len: hash_size}
			}
		}
		for offset := 0; offset < source.len; offset += code_signing_page_size {
			end := if offset + code_signing_page_size < source.len {
				offset + code_signing_page_size
			} else {
				source.len
			}
			data << code_signing_digest(options.hash_type, source[offset..end])!
		}
	} else {
		data << []u8{len: (int(n_special_slots) + n_code_slots) * hash_size}
	}
	return data
}

pub struct CodeSigningSection {
pub:
	segname  string
	sectname string
	offset   u64
	size     u64
}

pub struct CodeSigningSegment {
pub:
	segname     string
	fileoff     u64
	view_offset int
	sections    []CodeSigningSection
pub mut:
	filesize u64
	vmsize   u64
}

pub struct CodeSigningCommand {
pub:
	kind        string
	view_offset int
	version     u32
	minos       u32
	platform    u32
	uuid        []u8
pub mut:
	dataoff  u32
	datasize u32
}

@[heap]
pub struct CodeSigningMachO {
pub:
	filename          string
	header_size       int = 32
	endianness        string = 'little'
	segment_alignment int = 12
	executable        bool
	magic64           bool = true
pub mut:
	data           []u8
	commands       []CodeSigningCommand
	segments       []CodeSigningSegment
	ncmds          u32
	sizeofcmds     u32
	populate_count int
}

pub struct SigningMetadata {
pub:
	components     map[u32][]u8
	exec_seg_flags u64
	flags          u32
	runtime        u32
}

@[heap]
pub struct AdhocSigner {
pub:
	identifier string
pub mut:
	macho &CodeSigningMachO
}

fn code_signing_round(value int, multiple int) int {
	if multiple <= 0 {
		return value
	}
	return ((value + multiple - 1) / multiple) * multiple
}

fn code_signing_padding_for(value int, multiple int) int {
	return code_signing_round(value, multiple) - value
}

fn code_signing_write_u32(mut data []u8, offset int, value u32, endianness string) ! {
	if offset < 0 || offset + 4 > data.len {
		return error('Mach-O field offset is outside serialized data')
	}
	if endianness == 'big' {
		binary.big_endian_put_u32_at(mut data, value, offset)
	} else {
		binary.little_endian_put_u32_at(mut data, value, offset)
	}
}

fn code_signing_write_u64(mut data []u8, offset int, value u64, endianness string) ! {
	if offset < 0 || offset + 8 > data.len {
		return error('Mach-O field offset is outside serialized data')
	}
	if endianness == 'big' {
		binary.big_endian_put_u64_at(mut data, value, offset)
	} else {
		binary.little_endian_put_u64_at(mut data, value, offset)
	}
}

pub fn new_adhoc_signer(macho &CodeSigningMachO, identifier string) &AdhocSigner {
	return &AdhocSigner{
		macho: macho
		identifier: identifier
	}
}

pub fn default_signing_metadata() SigningMetadata {
	return SigningMetadata{
		components: map[u32][]u8{}
		exec_seg_flags: 0
		flags: cs_adhoc
		runtime: 0
	}
}

pub fn (signer &AdhocSigner) metadata_from(command CodeSigningCommand) !SigningMetadata {
	if command.datasize == 0 {
		return default_signing_metadata()
	}
	if u64(command.dataoff) + u64(command.datasize) > u64(signer.macho.data.len) {
		return error('code-signing blob is truncated')
	}
	super_blob := parse_code_signing_blob(signer.macho.data[int(command.dataoff)..int(command.dataoff + command.datasize)])!
	mut directory_index := -1
	for index, candidate in super_blob.blobs {
		if candidate.kind == .code_directory && candidate.hash_type == cs_hash_type_sha256 {
			directory_index = index
			break
		}
		if candidate.kind == .code_directory && directory_index < 0 {
			directory_index = index
		}
	}
	if directory_index < 0 {
		return default_signing_metadata()
	}
	directory := super_blob.blobs[directory_index]
	if directory.flags & cs_linker_signed != 0 {
		return default_signing_metadata()
	}
	mut components := map[u32][]u8{}
	for slot in [csslot_requirements, csslot_entitlements, csslot_der_entitlements] {
		if component := super_blob.blob(slot) {
			components[slot] = component.serialize()
		}
	}
	return SigningMetadata{
		components: components
		exec_seg_flags: directory.exec_seg_flags
		flags: (directory.flags & ~cs_linker_signed) | cs_adhoc
		runtime: directory.runtime
	}
}

pub fn (mut signer AdhocSigner) remove_signature(command CodeSigningCommand) ! {
	end_offset := u64(command.dataoff) + u64(command.datasize)
	if u64(command.dataoff) > u64(signer.macho.data.len) || end_offset > u64(signer.macho.data.len) {
		return error('LC_CODE_SIGNATURE does not point to the end of the Mach-O')
	}
	trailing := signer.macho.data[int(end_offset)..]
	if trailing.len > 15 || trailing.any(it != 0) {
		return error('LC_CODE_SIGNATURE does not point to the end of the Mach-O')
	}
	signer.macho.data = signer.macho.data[..int(command.dataoff)].clone()
	signer.macho.populate_count++
}

pub fn (mut signer AdhocSigner) add_signature_command() ! {
	view_offset := signer.macho.header_size + int(signer.macho.sizeofcmds)
	mut low_fileoff := signer.macho.data.len
	for segment in signer.macho.segments {
		if segment.fileoff > 0 && segment.filesize > 0 && segment.fileoff < u64(low_fileoff) {
			low_fileoff = int(segment.fileoff)
		}
		for section in segment.sections {
			if section.size > 0 && section.offset < u64(low_fileoff) {
				low_fileoff = int(section.offset)
			}
		}
	}
	if view_offset < signer.macho.header_size || view_offset + 16 > low_fileoff || view_offset + 16 > signer.macho.data.len {
		return error('Updated load commands do not fit in the header of ${signer.macho.filename}. ${signer.macho.filename} needs to be relinked, possibly with -headerpad or -headerpad_max_install_names')
	}
	for index := view_offset; index < view_offset + 16; index++ {
		signer.macho.data[index] = 0
	}
	signer.macho.commands << CodeSigningCommand{
		kind: 'LC_CODE_SIGNATURE'
		view_offset: view_offset
	}
	signer.macho.ncmds++
	signer.macho.sizeofcmds += 16
	code_signing_write_u32(mut signer.macho.data, view_offset, u32(0x1d), signer.macho.endianness)!
	code_signing_write_u32(mut signer.macho.data, view_offset + 4, 16, signer.macho.endianness)!
	if signer.macho.data.len >= 24 {
		code_signing_write_u32(mut signer.macho.data, 16, signer.macho.ncmds, signer.macho.endianness)!
		code_signing_write_u32(mut signer.macho.data, 20, signer.macho.sizeofcmds, signer.macho.endianness)!
	}
}

pub fn (signer &AdhocSigner) hash_types() []u8 {
	mut version := u32(0)
	mut has_version := false
	for command in signer.macho.commands {
		if command.kind == 'LC_VERSION_MIN_MACOSX' {
			version = command.version
			has_version = true
			break
		}
	}
	if !has_version {
		for command in signer.macho.commands {
			if command.kind == 'LC_BUILD_VERSION' && command.platform == 1 {
				version = command.minos
				has_version = true
				break
			}
		}
	}
	return if has_version && version < 0x000a0b04 {
		[cs_hash_type_sha1, cs_hash_type_sha256]
	} else {
		[cs_hash_type_sha256]
	}
}

pub fn code_signing_info_plist(macho &CodeSigningMachO) ?[]u8 {
	for segment in macho.segments {
		for section in segment.sections {
			if section.segname == '__TEXT' && section.sectname == '__info_plist' && section.offset <= u64(macho.data.len) && section.offset + section.size <= u64(macho.data.len) {
				return macho.data[int(section.offset)..int(section.offset + section.size)].clone()
			}
		}
	}
	return none
}

pub fn (signer &AdhocSigner) signature_entries(metadata SigningMetadata, calculate_hashes bool) !map[u32][]u8 {
	mut components := metadata.components.clone()
	if csslot_requirements !in components {
		mut requirement := []u8{len: 12}
		code_signing_put_u32(mut requirement, 0, csmagic_requirements)
		code_signing_put_u32(mut requirement, 4, 12)
		components[csslot_requirements] = requirement
	}
	mut special_slots := components.clone()
	if info := code_signing_info_plist(signer.macho) {
		special_slots[csslot_info_slot] = info
	}
	mut text_fileoff := u64(0)
	mut text_filesize := u64(0)
	for segment in signer.macho.segments {
		if segment.segname == '__TEXT' {
			text_fileoff = segment.fileoff
			text_filesize = segment.filesize
			break
		}
	}
	mut exec_seg_flags := metadata.exec_seg_flags
	if signer.macho.executable {
		exec_seg_flags |= cs_execseg_main_binary
	} else {
		exec_seg_flags &= ~cs_execseg_main_binary
	}
	mut entries := map[u32][]u8{}
	for index, hash_type in signer.hash_types() {
		slot := if index == 0 {
			csslot_code_directory
		} else {
			csslot_alternate_code_directories + u32(index - 1)
		}
		entries[slot] = build_code_directory(signer.macho.data, CodeDirectoryBuildOptions{
			identifier: signer.identifier
			hash_type: hash_type
			flags: metadata.flags
			special_slots: special_slots
			exec_seg_base: text_fileoff
			exec_seg_limit: text_filesize
			exec_seg_flags: exec_seg_flags
			runtime: metadata.runtime
			calculate_hashes: calculate_hashes
		})!
	}
	for slot, component in components {
		entries[slot] = component.clone()
	}
	mut wrapper := []u8{len: 8}
	code_signing_put_u32(mut wrapper, 0, csmagic_blob_wrapper)
	code_signing_put_u32(mut wrapper, 4, 8)
	entries[csslot_signature_slot] = wrapper
	return entries
}

pub fn (mut signer AdhocSigner) update_linkedit_data_command(command_index int, dataoff u32, datasize u32) ! {
	if command_index < 0 || command_index >= signer.macho.commands.len {
		return error('LC_CODE_SIGNATURE command is missing')
	}
	mut command := &signer.macho.commands[command_index]
	code_signing_write_u32(mut signer.macho.data, command.view_offset + 8, dataoff, signer.macho.endianness)!
	code_signing_write_u32(mut signer.macho.data, command.view_offset + 12, datasize, signer.macho.endianness)!
	command.dataoff = dataoff
	command.datasize = datasize
}

pub fn (mut signer AdhocSigner) update_linkedit_segment(segment_index int, final_size u64) ! {
	if segment_index < 0 || segment_index >= signer.macho.segments.len {
		return error('__LINKEDIT segment is missing')
	}
	mut segment := &signer.macho.segments[segment_index]
	if final_size < segment.fileoff {
		return error('__LINKEDIT extends past the end of the Mach-O')
	}
	filesize := final_size - segment.fileoff
	if !signer.macho.magic64 && filesize > u64(0xffff_ffff) {
		return error('__LINKEDIT exceeds its 32-bit filesize')
	}
	if signer.macho.magic64 {
		code_signing_write_u64(mut signer.macho.data, segment.view_offset + 48, filesize, signer.macho.endianness)!
		if filesize > segment.vmsize {
			alignment := u64(1) << u32(signer.macho.segment_alignment)
			new_vmsize := ((filesize + alignment - 1) / alignment) * alignment
			code_signing_write_u64(mut signer.macho.data, segment.view_offset + 32, new_vmsize, signer.macho.endianness)!
			segment.vmsize = new_vmsize
		}
	} else {
		code_signing_write_u32(mut signer.macho.data, segment.view_offset + 36, u32(filesize), signer.macho.endianness)!
		if filesize > segment.vmsize {
			alignment := u64(1) << u32(signer.macho.segment_alignment)
			new_vmsize := ((filesize + alignment - 1) / alignment) * alignment
			code_signing_write_u32(mut signer.macho.data, segment.view_offset + 28, u32(new_vmsize), signer.macho.endianness)!
			segment.vmsize = new_vmsize
		}
	}
	segment.filesize = filesize
}

pub fn (mut signer AdhocSigner) sign() ! {
	mut signature_indices := []int{}
	for index, command in signer.macho.commands {
		if command.kind == 'LC_CODE_SIGNATURE' {
			signature_indices << index
		}
	}
	if signature_indices.len > 1 {
		return error('Mach-O contains multiple LC_CODE_SIGNATURE commands')
	}
	metadata := if signature_indices.len == 1 {
		signer.metadata_from(signer.macho.commands[signature_indices[0]])!
	} else {
		default_signing_metadata()
	}
	if signature_indices.len == 1 && signer.macho.commands[signature_indices[0]].datasize > 0 {
		signer.remove_signature(signer.macho.commands[signature_indices[0]])!
	}
	if signature_indices.len == 0 {
		signer.add_signature_command()!
	}
	mut command_index := -1
	for index, command in signer.macho.commands {
		if command.kind == 'LC_CODE_SIGNATURE' {
			command_index = index
			break
		}
	}
	mut linkedit_indices := []int{}
	for index, segment in signer.macho.segments {
		if segment.segname == '__LINKEDIT' {
			linkedit_indices << index
		}
	}
	if linkedit_indices.len != 1 {
		return error('Mach-O must contain exactly one __LINKEDIT segment')
	}
	signer.macho.data << []u8{len: code_signing_padding_for(signer.macho.data.len, 16)}
	dataoff := signer.macho.data.len
	if u64(dataoff) > u64(0xffff_ffff) {
		return error('code signature offset exceeds LC_CODE_SIGNATURE')
	}
	blank_entries := signer.signature_entries(metadata, false)!
	datasize := code_signing_round(build_super_blob(blank_entries).len, 16)
	signer.update_linkedit_data_command(command_index, u32(dataoff), u32(datasize))!
	signer.update_linkedit_segment(linkedit_indices[0], u64(dataoff + datasize))!
	entries := signer.signature_entries(metadata, true)!
	signature := build_super_blob(entries)
	signer.macho.data << signature
	signer.macho.data << []u8{len: datasize - signature.len}
	signer.macho.populate_count++
}

fn code_signing_basename(path string) string {
	normalized := path.replace('\\', '/')
	return normalized.all_after_last('/')
}

fn code_signing_without_extension(filename string) string {
	last_dot := filename.last_index('.') or { return filename }
	return if last_dot == 0 { filename } else { filename[..last_dot] }
}

fn code_signing_bundle_identifier(plist []u8) ?string {
	text := plist.bytestr()
	mut cursor := 0
	for cursor < text.len {
		key_relative := text[cursor..].index('<key>') or { return none }
		key_start := cursor + key_relative + '<key>'.len
		key_end_relative := text[key_start..].index('</key>') or { return none }
		key_end := key_start + key_end_relative
		cursor = key_end + '</key>'.len
		if text[key_start..key_end].trim_space() != 'CFBundleIdentifier' {
			continue
		}
		string_relative := text[cursor..].index('<string>') or { return none }
		string_start := cursor + string_relative + '<string>'.len
		string_end_relative := text[string_start..].index('</string>') or { return none }
		return text[string_start..string_start + string_end_relative].trim_space()
	}
	return none
}

pub fn code_signing_identifier(macho &CodeSigningMachO, filename string) string {
	if plist := code_signing_info_plist(macho) {
		if identifier := code_signing_bundle_identifier(plist) {
			return identifier
		}
	}
	base := code_signing_basename(if filename == '' { 'adhoc' } else { filename })
	name := code_signing_without_extension(base)
	if name.contains('.') {
		return name
	}
	mut identity := ''
	for command in macho.commands {
		if command.kind == 'LC_UUID' {
			mut uuid_identity := 'UUID'.bytes()
			uuid_identity << command.uuid
			identity = uuid_identity.hex()
			break
		}
	}
	if identity == '' {
		mut signed_region := []u8{}
		base_header_end := if macho.data.len < 28 { macho.data.len } else { 28 }
		signed_region << macho.data[..base_header_end]
		commands_start := if macho.header_size < macho.data.len {
			macho.header_size
		} else {
			macho.data.len
		}
		commands_end := if commands_start + int(macho.sizeofcmds) < macho.data.len {
			commands_start + int(macho.sizeofcmds)
		} else {
			macho.data.len
		}
		signed_region << macho.data[commands_start..commands_end]
		identity = sha1.sum(signed_region).hex()
	}
	return '${name}-${identity}'
}

fn code_signing_blob_boundary(blob &CodeSigningBlob) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::CodeSigning::${blob.kind}', '#<MachO::CodeSigning::${blob.kind}>', {
		'code_signing_blob_address': u64(voidptr(blob)).str()
	})
}

fn code_signing_blob_from_args(args []brew_runtime.Value) &CodeSigningBlob {
	if args.len == 0 {
		panic('code-signing blob method requires a receiver')
	}
	address := (args[0].attribute('code_signing_blob_address') or {
		panic('${args[0].type_name} has no translated code-signing blob state')
	}).u64()
	return unsafe { &CodeSigningBlob(voidptr(address)) }
}

fn code_signing_macho_boundary(macho &CodeSigningMachO) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::MachOFile', macho.filename, {
		'code_signing_macho_address': u64(voidptr(macho)).str()
	})
}

fn code_signing_macho_from_value(value brew_runtime.Value) &CodeSigningMachO {
	address := (value.attribute('code_signing_macho_address') or {
		panic('${value.type_name} has no translated code-signing Mach-O state')
	}).u64()
	return unsafe { &CodeSigningMachO(voidptr(address)) }
}

fn adhoc_signer_boundary(signer &AdhocSigner) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::CodeSigning::AdhocSigner', '#<MachO::CodeSigning::AdhocSigner>', {
		'adhoc_signer_address': u64(voidptr(signer)).str()
	})
}

fn adhoc_signer_from_args(args []brew_runtime.Value) &AdhocSigner {
	if args.len == 0 {
		panic('AdhocSigner method requires a receiver')
	}
	address := (args[0].attribute('adhoc_signer_address') or {
		panic('${args[0].type_name} has no translated AdhocSigner state')
	}).u64()
	return unsafe { &AdhocSigner(voidptr(address)) }
}

fn code_signing_indices_boundary(indices []BlobIndex) brew_runtime.Value {
	return brew_runtime.array_value(indices.map(brew_runtime.map_value({
		'type':   brew_runtime.int_value(it.type_)
		'offset': brew_runtime.int_value(it.offset)
	})))
}

fn code_signing_blobs_boundary(blobs []&CodeSigningBlob) brew_runtime.Value {
	return brew_runtime.array_value(blobs.map(code_signing_blob_boundary(it)))
}

fn code_signing_entries_from_value(value brew_runtime.Value) map[u32][]u8 {
	values := value.as_map() or { panic(err) }
	mut entries := map[u32][]u8{}
	for slot, blob in values {
		entries[u32(slot.u64())] = blob.as_string().bytes()
	}
	return entries
}

fn signing_metadata_boundary(metadata SigningMetadata) brew_runtime.Value {
	mut components := map[string]brew_runtime.Value{}
	for slot, data in metadata.components {
		components[slot.str()] = brew_runtime.string_value(data.bytestr())
	}
	return brew_runtime.map_value({
		'components':     brew_runtime.map_value(components)
		'exec_seg_flags': brew_runtime.int_value(i64(metadata.exec_seg_flags))
		'flags':          brew_runtime.int_value(metadata.flags)
		'runtime':        brew_runtime.int_value(metadata.runtime)
	})
}

fn signing_metadata_from_value(value brew_runtime.Value) SigningMetadata {
	values := value.as_map() or { panic(err) }
	components := code_signing_entries_from_value(values['components'] or {
		brew_runtime.map_value({})
	})
	return SigningMetadata{
		components: components
		exec_seg_flags: u64((values['exec_seg_flags'] or { brew_runtime.int_value(0) }).as_int() or {
			panic(err)})
		flags: u32((values['flags'] or { brew_runtime.int_value(cs_adhoc) }).as_int() or {
			panic(err)})
		runtime: u32((values['runtime'] or { brew_runtime.int_value(0) }).as_int() or {
			panic(err)})
	}
}

fn code_signing_command_boundary(macho &CodeSigningMachO, index int) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::LinkeditDataCommand', '#<LC_CODE_SIGNATURE>', {
		'code_signing_macho_address': u64(voidptr(macho)).str()
		'command_index':              index.str()
	})
}

fn code_signing_command_from_value(value brew_runtime.Value) (&CodeSigningMachO, int) {
	macho := code_signing_macho_from_value(value)
	index := (value.attribute('command_index') or { panic('command has no translated index') }).int()
	return macho, index
}

fn code_signing_segment_boundary(macho &CodeSigningMachO, index int) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::LoadCommands::SegmentCommand', '#<__LINKEDIT>', {
		'code_signing_macho_address': u64(voidptr(macho)).str()
		'segment_index':              index.str()
	})
}

fn code_signing_segment_from_value(value brew_runtime.Value) (&CodeSigningMachO, int) {
	macho := code_signing_macho_from_value(value)
	index := (value.attribute('segment_index') or { panic('segment has no translated index') }).int()
	return macho, index
}

// Ruby attr_reader `attr_reader :magic` at line 83.
pub fn ruby_code_signing_l83_d1_magic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).magic)
}

// Ruby attr_reader `attr_reader :length` at line 86.
pub fn ruby_code_signing_l86_d2_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).length)
}

// Ruby method `self.parse(data)` at line 91.
pub fn ruby_code_signing_l91_d3_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Blob.parse requires data')
	}
	return code_signing_blob_boundary(parse_code_signing_blob(args[args.len - 1].as_string().bytes()) or {
		panic(err)
	})
}

// Ruby method `initialize(data)` at line 105.
pub fn ruby_code_signing_l105_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Blob#initialize requires data')
	}
	return code_signing_blob_boundary(parse_code_signing_blob(args[args.len - 1].as_string().bytes()) or {
		panic(err)
	})
}

// Ruby method `serialize` at line 115.
pub fn ruby_code_signing_l115_d5_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(code_signing_blob_from_args(args).serialize().bytestr())
}

// Ruby method `magic_sym` at line 120.
pub fn ruby_code_signing_l120_d6_magic_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(code_signing_blob_from_args(args).magic_sym())
}

// Ruby method `to_h` at line 125.
pub fn ruby_code_signing_l125_d7_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_blob_from_args(args).to_h()
}

// Ruby attr_reader `attr_reader :count` at line 137.
pub fn ruby_code_signing_l137_d8_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).count)
}

// Ruby attr_reader `attr_reader :indices` at line 140.
pub fn ruby_code_signing_l140_d9_indices(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_indices_boundary(code_signing_blob_from_args(args).indices)
}

// Ruby attr_reader `attr_reader :blobs` at line 143.
pub fn ruby_code_signing_l143_d10_blobs(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_blobs_boundary(code_signing_blob_from_args(args).blobs)
}

// Ruby method `self.build(entries)` at line 148.
pub fn ruby_code_signing_l148_d11_self_build(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SuperBlob.build requires entries')
	}
	return brew_runtime.string_value(build_super_blob(code_signing_entries_from_value(args[args.len - 1])).bytestr())
}

// Ruby method `initialize(data)` at line 163.
pub fn ruby_code_signing_l163_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('SuperBlob#initialize requires data')
	}
	blob := parse_code_signing_blob(args[args.len - 1].as_string().bytes()) or { panic(err) }
	if blob.kind != .super_blob {
		panic('invalid embedded-signature magic: 0x${blob.magic.hex()}')
	}
	return code_signing_blob_boundary(blob)
}

// Ruby method `blob(type)` at line 184.
pub fn ruby_code_signing_l184_d13_blob(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SuperBlob#blob requires a slot type')
	}
	if blob := code_signing_blob_from_args(args).blob(u32(args[1].as_int() or { panic(err) })) {
		return code_signing_blob_boundary(blob)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `each_blob_index(&block)` at line 192.
pub fn ruby_code_signing_l192_d14_each_blob_index(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_indices_boundary(code_signing_blob_from_args(args).each_blob_index())
}

// Ruby method `each_blob(&block)` at line 201.
pub fn ruby_code_signing_l201_d15_each_blob(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_blobs_boundary(code_signing_blob_from_args(args).each_blob())
}

// Ruby method `to_h` at line 208.
pub fn ruby_code_signing_l208_d16_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_blob_from_args(args).to_h()
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d17_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).version)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d18_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).flags)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d19_hash_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).hash_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d20_ident_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).ident_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d21_n_special_slots(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).n_special_slots)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d22_n_code_slots(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).n_code_slots)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d23_hash_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).hash_size)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d24_hash_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).hash_type)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d25_platform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).platform)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d26_page_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).page_size)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d27_scatter_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).scatter_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d28_team_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).team_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d29_code_limit64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(code_signing_blob_from_args(args).code_limit64))
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d30_exec_seg_base(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(code_signing_blob_from_args(args).exec_seg_base))
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d31_exec_seg_limit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(code_signing_blob_from_args(args).exec_seg_limit))
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d32_exec_seg_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(code_signing_blob_from_args(args).exec_seg_flags))
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d33_runtime(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).runtime)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d34_pre_encrypt_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).pre_encrypt_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d35_linkage_hash_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).linkage_hash_type)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d36_linkage_application_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).linkage_application_type)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d37_linkage_application_subtype(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).linkage_application_subtype)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d38_linkage_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).linkage_offset)
}

// Ruby attr_reader `attr_reader :version, :flags, :hash_offset, :ident_offset, :n_special_slots, :n_code_slots, :hash_size, :hash_type, :platform, :page_size, :scatter_offset, :team_offset, :code_limit64, :exec_seg_base, :exec_seg_limit, :exec_seg_flags, :runtime, :pre_encrypt_offset, :linkage_hash_type, :linkage_application_type, :linkage_application_subtype, :linkage_offset, :linkage_size` at line 219.
pub fn ruby_code_signing_l219_d39_linkage_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(code_signing_blob_from_args(args).linkage_size)
}

// Ruby method `self.build(source, identifier:, hash_type:, flags:, special_slots:,` at line 239.
pub fn ruby_code_signing_l239_d40_self_build(args ...brew_runtime.Value) brew_runtime.Value {
	mut start := 0
	if args.len > 0 && args[0].type_name != 'String' {
		start = 1
	}
	if args.len < start + 9 {
		panic('CodeDirectory.build requires source and signing options')
	}
	data := build_code_directory(args[start].as_string().bytes(), CodeDirectoryBuildOptions{
		identifier: args[start + 1].as_string()
		hash_type: u8(args[start + 2].as_int() or { panic(err) })
		flags: u32(args[start + 3].as_int() or { panic(err) })
		special_slots: code_signing_entries_from_value(args[start + 4])
		exec_seg_base: u64(args[start + 5].as_int() or { panic(err) })
		exec_seg_limit: u64(args[start + 6].as_int() or { panic(err) })
		exec_seg_flags: u64(args[start + 7].as_int() or { panic(err) })
		runtime: u32(args[start + 8].as_int() or { panic(err) })
		calculate_hashes: if args.len > start + 9 {
			args[start + 9].as_bool() or { panic(err) }} else {
			true}
	}) or { panic(err) }
	return brew_runtime.string_value(data.bytestr())
}

// Ruby method `initialize(data)` at line 277.
pub fn ruby_code_signing_l277_d41_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CodeDirectory#initialize requires data')
	}
	blob := parse_code_signing_blob(args[args.len - 1].as_string().bytes()) or { panic(err) }
	if blob.kind != .code_directory {
		panic('invalid CodeDirectory magic: 0x${blob.magic.hex()}')
	}
	return code_signing_blob_boundary(blob)
}

// Ruby attr_reader `attr_reader :identifier` at line 331.
pub fn ruby_code_signing_l331_d42_identifier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(code_signing_blob_from_args(args).identifier)
}

// Ruby method `code_limit` at line 334.
pub fn ruby_code_signing_l334_d43_code_limit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(code_signing_blob_from_args(args).code_limit()))
}

// Ruby method `code_hash(slot)` at line 341.
pub fn ruby_code_signing_l341_d44_code_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CodeDirectory#code_hash requires a slot')
	}
	if hash := code_signing_blob_from_args(args).code_hash(int(args[1].as_int() or { panic(err) })) {
		return brew_runtime.string_value(hash.bytestr())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `hash_type_sym` at line 348.
pub fn ruby_code_signing_l348_d45_hash_type_sym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(code_signing_blob_from_args(args).hash_type_sym())
}

// Ruby method `special_hash(slot)` at line 355.
pub fn ruby_code_signing_l355_d46_special_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CodeDirectory#special_hash requires a slot')
	}
	if hash := code_signing_blob_from_args(args).special_hash(int(args[1].as_int() or { panic(err) })) {
		return brew_runtime.string_value(hash.bytestr())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `to_h` at line 362.
pub fn ruby_code_signing_l362_d47_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return code_signing_blob_from_args(args).to_h()
}

// Ruby method `unpack_uint32(offset)` at line 380.
pub fn ruby_code_signing_l380_d48_unpack_uint32(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CodeDirectory#unpack_uint32 requires an offset')
	}
	return brew_runtime.int_value(code_signing_blob_from_args(args).unpack_uint32(int(args[1].as_int() or {
		panic(err)
	})) or { panic(err) })
}

// Ruby method `initialize(macho, identifier)` at line 391.
pub fn ruby_code_signing_l391_d49_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('AdhocSigner#initialize requires a Mach-O and identifier')
	}
	return adhoc_signer_boundary(new_adhoc_signer(code_signing_macho_from_value(args[0]), args[1].as_string()))
}

// Ruby method `sign!` at line 398.
pub fn ruby_code_signing_l398_d50_sign(args ...brew_runtime.Value) brew_runtime.Value {
	mut signer := adhoc_signer_from_args(args)
	signer.sign() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `metadata_from(signature_command)` at line 432.
pub fn ruby_code_signing_l432_d51_metadata_from(args ...brew_runtime.Value) brew_runtime.Value {
	signer := adhoc_signer_from_args(args)
	if args.len < 2 || args[1].type_name == 'NilClass' {
		return signing_metadata_boundary(default_signing_metadata())
	}
	macho, index := code_signing_command_from_value(args[1])
	if macho != signer.macho || index < 0 || index >= macho.commands.len {
		panic('signature command does not belong to this Mach-O')
	}
	return signing_metadata_boundary(signer.metadata_from(macho.commands[index]) or { panic(err) })
}

// Ruby method `default_metadata` at line 452.
pub fn ruby_code_signing_l452_d52_default_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return signing_metadata_boundary(default_signing_metadata())
}

// Ruby method `remove_signature(signature_command)` at line 461.
pub fn ruby_code_signing_l461_d53_remove_signature(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('remove_signature requires an LC_CODE_SIGNATURE command')
	}
	mut signer := adhoc_signer_from_args(args)
	macho, index := code_signing_command_from_value(args[1])
	if macho != signer.macho || index < 0 || index >= macho.commands.len {
		panic('signature command does not belong to this Mach-O')
	}
	signer.remove_signature(macho.commands[index]) or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `add_signature_command` at line 474.
pub fn ruby_code_signing_l474_d54_add_signature_command(args ...brew_runtime.Value) brew_runtime.Value {
	mut signer := adhoc_signer_from_args(args)
	signer.add_signature_command() or { panic(err) }
	return code_signing_command_boundary(signer.macho, signer.macho.commands.len - 1)
}

// Ruby method `signature_entries(metadata, hashes: true)` at line 480.
pub fn ruby_code_signing_l480_d55_signature_entries(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('signature_entries requires metadata')
	}
	signer := adhoc_signer_from_args(args)
	calculate_hashes := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { true }
	entries := signer.signature_entries(signing_metadata_from_value(args[1]), calculate_hashes) or {
		panic(err)
	}
	mut values := map[string]brew_runtime.Value{}
	for slot, data in entries {
		values[slot.str()] = brew_runtime.string_value(data.bytestr())
	}
	return brew_runtime.map_value(values)
}

// Ruby method `hash_types` at line 515.
pub fn ruby_code_signing_l515_d56_hash_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(adhoc_signer_from_args(args).hash_types().map(brew_runtime.int_value(it)))
}

// Ruby method `update_linkedit_data_command(command, dataoff, datasize)` at line 522.
pub fn ruby_code_signing_l522_d57_update_linkedit_data_command(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('update_linkedit_data_command requires command, dataoff and datasize')
	}
	mut signer := adhoc_signer_from_args(args)
	macho, index := code_signing_command_from_value(args[1])
	if macho != signer.macho {
		panic('signature command does not belong to this Mach-O')
	}
	signer.update_linkedit_data_command(index, u32(args[2].as_int() or { panic(err) }), u32(args[3].as_int() or {
		panic(err)
	})) or { panic(err) }
	return code_signing_command_boundary(macho, index)
}

// Ruby method `update_linkedit_segment(segment, final_size)` at line 527.
pub fn ruby_code_signing_l527_d58_update_linkedit_segment(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('update_linkedit_segment requires segment and final size')
	}
	mut signer := adhoc_signer_from_args(args)
	macho, index := code_signing_segment_from_value(args[1])
	if macho != signer.macho {
		panic('segment does not belong to this Mach-O')
	}
	signer.update_linkedit_segment(index, u64(args[2].as_int() or { panic(err) })) or { panic(err) }
	return code_signing_segment_boundary(macho, index)
}

// Ruby method `self.identifier(macho, filename)` at line 548.
pub fn ruby_code_signing_l548_d59_self_identifier(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CodeSigning.identifier requires a Mach-O')
	}
	filename := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	return brew_runtime.string_value(code_signing_identifier(code_signing_macho_from_value(args[0]), filename))
}

// Ruby method `self.info_plist(macho)` at line 576.
pub fn ruby_code_signing_l576_d60_self_info_plist(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CodeSigning.info_plist requires a Mach-O')
	}
	if plist := code_signing_info_plist(code_signing_macho_from_value(args[0])) {
		return brew_runtime.string_value(plist.bytestr())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require "digest/sha1"
// 4: require "digest/sha2"
// 5:
// 6: module MachO
// 7:   # Structures and helpers for embedded Mach-O code signatures.
// 8:   module CodeSigning
// 9:     CSMAGIC_REQUIREMENT = 0xfade0c00
// 10:     CSMAGIC_REQUIREMENTS = 0xfade0c01
// 11:     CSMAGIC_CODEDIRECTORY = 0xfade0c02
// 12:     CSMAGIC_BLOBWRAPPER = 0xfade0b01
// 13:     CSMAGIC_EMBEDDED_SIGNATURE = 0xfade0cc0
// 14:     CSMAGIC_DETACHED_SIGNATURE = 0xfade0cc1
// 15:     CSMAGIC_EMBEDDED_ENTITLEMENTS = 0xfade7171
// 16:     CSMAGIC_EMBEDDED_DER_ENTITLEMENTS = 0xfade7172
// 17:     CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT = 0xfade8181
// 18:     CSMAGIC_ENTITLEMENT = CSMAGIC_EMBEDDED_ENTITLEMENTS
// 19:     CSMAGIC_ENTITLEMENTDER = CSMAGIC_EMBEDDED_DER_ENTITLEMENTS
// 20:
// 21:     CS_MAGICS = {
// 22:       CSMAGIC_REQUIREMENT => :CSMAGIC_REQUIREMENT,
// 23:       CSMAGIC_REQUIREMENTS => :CSMAGIC_REQUIREMENTS,
// 24:       CSMAGIC_CODEDIRECTORY => :CSMAGIC_CODEDIRECTORY,
// 25:       CSMAGIC_BLOBWRAPPER => :CSMAGIC_BLOBWRAPPER,
// 26:       CSMAGIC_EMBEDDED_SIGNATURE => :CSMAGIC_EMBEDDED_SIGNATURE,
// 27:       CSMAGIC_DETACHED_SIGNATURE => :CSMAGIC_DETACHED_SIGNATURE,
// 28:       CSMAGIC_EMBEDDED_ENTITLEMENTS => :CSMAGIC_EMBEDDED_ENTITLEMENTS,
// 29:       CSMAGIC_EMBEDDED_DER_ENTITLEMENTS => :CSMAGIC_EMBEDDED_DER_ENTITLEMENTS,
// 30:       CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT => :CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT,
// 31:     }.freeze
// 32:
// 33:     CSSLOT_CODEDIRECTORY = 0
// 34:     CSSLOT_INFOSLOT = 1
// 35:     CSSLOT_REQUIREMENTS = 2
// 36:     CSSLOT_ENTITLEMENTS = 5
// 37:     CSSLOT_DER_ENTITLEMENTS = 7
// 38:     CSSLOT_ALTERNATE_CODEDIRECTORIES = 0x1000
// 39:     CSSLOT_SIGNATURESLOT = 0x10000
// 40:
// 41:     CS_HASHTYPE_SHA1 = 1
// 42:     CS_HASHTYPE_SHA256 = 2
// 43:     CS_HASHTYPE_SHA256_TRUNCATED = 3
// 44:     CS_HASHTYPE_SHA384 = 4
// 45:
// 46:     CS_HASHTYPES = {
// 47:       CS_HASHTYPE_SHA1 => :CS_HASHTYPE_SHA1,
// 48:       CS_HASHTYPE_SHA256 => :CS_HASHTYPE_SHA256,
// 49:       CS_HASHTYPE_SHA256_TRUNCATED => :CS_HASHTYPE_SHA256_TRUNCATED,
// 50:       CS_HASHTYPE_SHA384 => :CS_HASHTYPE_SHA384,
// 51:     }.freeze
// 52:
// 53:     CS_ADHOC = 0x2
// 54:     CS_HARD = 0x100
// 55:     CS_RUNTIME = 0x10000
// 56:     CS_LINKER_SIGNED = 0x20000
// 57:     CS_EXECSEG_MAIN_BINARY = 0x1
// 58:     CS_EXECSEG_JIT = 0x40
// 59:
// 60:     CS_SUPPORTSCODELIMIT64 = 0x20300
// 61:     CS_SUPPORTSEXECSEG = 0x20400
// 62:     CS_SUPPORTSRUNTIME = 0x20500
// 63:     CS_SUPPORTSLINKAGE = 0x20600
// 64:
// 65:     PAGE_SIZE = 4096
// 66:     PRESERVED_COMPONENT_SLOTS = [
// 67:       CSSLOT_REQUIREMENTS,
// 68:       CSSLOT_ENTITLEMENTS,
// 69:       CSSLOT_DER_ENTITLEMENTS,
// 70:     ].freeze
// 71:
// 72:     HASHES = {
// 73:       CS_HASHTYPE_SHA1 => [Digest::SHA1, 20],
// 74:       CS_HASHTYPE_SHA256 => [Digest::SHA256, 32],
// 75:     }.freeze
// 76:
// 77:     # An entry in a code-signing SuperBlob index.
// 78:     BlobIndex = Struct.new(:type, :offset)
// 79:
// 80:     # A generic code-signing blob.
// 81:     class Blob
// 82:       # @return [Integer] the blob magic
// 83:       attr_reader :magic
// 84:
// 85:       # @return [Integer] the complete blob length
// 86:       attr_reader :length
// 87:
// 88:       # Parses the concrete blob type represented by `data`.
// 89:       # @param data [String] raw blob data
// 90:       # @return [Blob]
// 91:       def self.parse(data)
// 92:         raise CodeSigningError, "code-signing blob is truncated" if data.nil? || data.bytesize < 8
// 93:
// 94:         case data.unpack1("N")
// 95:         when CSMAGIC_CODEDIRECTORY
// 96:           CodeDirectory.new(data)
// 97:         when CSMAGIC_EMBEDDED_SIGNATURE
// 98:           SuperBlob.new(data)
// 99:         else
// 100:           new(data)
// 101:         end
// 102:       end
// 103:
// 104:       # @param data [String] raw blob data
// 105:       def initialize(data)
// 106:         raise CodeSigningError, "code-signing blob is truncated" if data.nil? || data.bytesize < 8
// 107:
// 108:         @magic, @length = data.unpack("N2")
// 109:         raise CodeSigningError, "invalid code-signing blob length: #{length}" if length < 8 || length > data.bytesize
// 110:
// 111:         @raw_data = data.byteslice(0, length).freeze
// 112:       end
// 113:
// 114:       # @return [String] raw blob data
// 115:       def serialize
// 116:         @raw_data
// 117:       end
// 118:
// 119:       # @return [Symbol, nil] the symbolic blob magic
// 120:       def magic_sym
// 121:         CS_MAGICS[magic]
// 122:       end
// 123:
// 124:       # @return [Hash] a hash representation of this blob
// 125:       def to_h
// 126:         {
// 127:           "magic" => magic,
// 128:           "magic_sym" => magic_sym,
// 129:           "length" => length,
// 130:         }
// 131:       end
// 132:     end
// 133:
// 134:     # An embedded-signature SuperBlob.
// 135:     class SuperBlob < Blob
// 136:       # @return [Integer] the number of indexed blobs
// 137:       attr_reader :count
// 138:
// 139:       # @return [Array<BlobIndex>] the blob index
// 140:       attr_reader :indices
// 141:
// 142:       # @return [Array<Blob>] the indexed blobs
// 143:       attr_reader :blobs
// 144:
// 145:       # Builds a SuperBlob containing the given slot/blob pairs.
// 146:       # @param entries [Hash<Integer, String>] blobs keyed by slot
// 147:       # @return [String] serialised SuperBlob data
// 148:       def self.build(entries)
// 149:         entries = entries.sort_by(&:first)
// 150:         offset = 12 + (entries.size * 8)
// 151:         index = +"".b
// 152:         payload = +"".b
// 153:         entries.each do |type, blob|
// 154:           index << [type, offset].pack("N2")
// 155:           payload << blob
// 156:           offset += blob.bytesize
// 157:         end
// 158:
// 159:         [CSMAGIC_EMBEDDED_SIGNATURE, offset, entries.size].pack("N3") + index + payload
// 160:       end
// 161:
// 162:       # @param data [String] raw SuperBlob data
// 163:       def initialize(data)
// 164:         super
// 165:         raise CodeSigningError, "invalid embedded-signature magic: 0x#{magic.to_s(16)}" unless magic == CSMAGIC_EMBEDDED_SIGNATURE
// 166:         raise CodeSigningError, "code-signing SuperBlob is truncated" if length < 12
// 167:
// 168:         @count = serialize.unpack1("N", :offset => 8)
// 169:         raise CodeSigningError, "code-signing SuperBlob index is truncated" if 12 + (count * 8) > length
// 170:
// 171:         @indices = count.times.map do |index|
// 172:           BlobIndex.new(*serialize.unpack("N2", :offset => 12 + (index * 8)))
// 173:         end.freeze
// 174:         @blobs = indices.map do |entry|
// 175:           raise CodeSigningError, "code-signing blob offset is invalid: #{entry.offset}" if entry.offset < 12 + (count * 8) || entry.offset + 8 > length
// 176:
// 177:           Blob.parse(serialize.byteslice(entry.offset, length - entry.offset))
// 178:         end.freeze
// 179:       end
// 180:
// 181:       # Returns the blob stored in `type`, if present.
// 182:       # @param type [Integer] the slot type
// 183:       # @return [Blob, nil]
// 184:       def blob(type)
// 185:         index = indices.index { |entry| entry.type == type }
// 186:         blobs[index] if index
// 187:       end
// 188:
// 189:       # Yields every index entry.
// 190:       # @yieldparam index [BlobIndex]
// 191:       # @return [Enumerator, void]
// 192:       def each_blob_index(&block)
// 193:         return indices.each unless block
// 194:
// 195:         indices.each(&block)
// 196:       end
// 197:
// 198:       # Yields every indexed blob.
// 199:       # @yieldparam blob [Blob]
// 200:       # @return [Enumerator, void]
// 201:       def each_blob(&block)
// 202:         return blobs.each unless block
// 203:
// 204:         blobs.each(&block)
// 205:       end
// 206:
// 207:       # @return [Hash] a hash representation of this SuperBlob
// 208:       def to_h
// 209:         {
// 210:           "count" => count,
// 211:           "indices" => indices.map { |entry| { "type" => entry.type, "offset" => entry.offset } },
// 212:           "blobs" => blobs.map(&:to_h),
// 213:         }.merge super
// 214:       end
// 215:     end
// 216:
// 217:     # A CodeDirectory describing signed code pages and special components.
// 218:     class CodeDirectory < Blob
// 219:       attr_reader :version, :flags, :hash_offset, :ident_offset,
// 220:                   :n_special_slots, :n_code_slots, :hash_size, :hash_type,
// 221:                   :platform, :page_size, :scatter_offset, :team_offset,
// 222:                   :code_limit64, :exec_seg_base, :exec_seg_limit,
// 223:                   :exec_seg_flags, :runtime, :pre_encrypt_offset,
// 224:                   :linkage_hash_type, :linkage_application_type,
// 225:                   :linkage_application_subtype, :linkage_offset, :linkage_size
// 226:
// 227:       # Builds a CodeDirectory for `source`.
// 228:       # @param source [String] bytes before the embedded signature
// 229:       # @param identifier [String] the signing identifier
// 230:       # @param hash_type [Integer] the hash algorithm
// 231:       # @param flags [Integer] CodeDirectory flags
// 232:       # @param special_slots [Hash<Integer, String>] special-slot contents
// 233:       # @param exec_seg_base [Integer] executable segment offset
// 234:       # @param exec_seg_limit [Integer] executable segment size
// 235:       # @param exec_seg_flags [Integer] executable segment flags
// 236:       # @param runtime [Integer] hardened runtime version
// 237:       # @param hashes [Boolean] whether to calculate hashes
// 238:       # @return [String] serialised CodeDirectory data
// 239:       def self.build(source, identifier:, hash_type:, flags:, special_slots:,
// 240:                      exec_seg_base:, exec_seg_limit:, exec_seg_flags:, runtime:, hashes: true)
// 241:         digest, hash_size = HASHES.fetch(hash_type)
// 242:         version = runtime.zero? ? CS_SUPPORTSEXECSEG : CS_SUPPORTSRUNTIME
// 243:         fixed_size = runtime.zero? ? 88 : 96
// 244:         identifier = "#{identifier.b.delete("\x00")}\x00".b
// 245:         n_special_slots = special_slots.keys.max || 0
// 246:         n_code_slots = (source.bytesize + PAGE_SIZE - 1) / PAGE_SIZE
// 247:         hash_offset = fixed_size + identifier.bytesize + (n_special_slots * hash_size)
// 248:         length = hash_offset + (n_code_slots * hash_size)
// 249:         code_limit = [source.bytesize, 0xffffffff].min
// 250:         code_limit64 = source.bytesize > 0xffffffff ? source.bytesize : 0
// 251:
// 252:         data = [CSMAGIC_CODEDIRECTORY, length, version, flags, hash_offset,
// 253:                 fixed_size, n_special_slots, n_code_slots, code_limit].pack("N9")
// 254:         data << [hash_size, hash_type, 0, 12].pack("C4")
// 255:         data << [0, 0, 0, 0].pack("N4")
// 256:         data << [code_limit64, exec_seg_base, exec_seg_limit, exec_seg_flags].pack("Q>4")
// 257:         data << [runtime, 0].pack("N2") unless runtime.zero?
// 258:         data << identifier
// 259:         if hashes
// 260:           n_special_slots.downto(1) do |slot|
// 261:             data << if special_slots.key?(slot)
// 262:               digest.digest(special_slots.fetch(slot))
// 263:             else
// 264:               "\x00" * hash_size
// 265:             end
// 266:           end
// 267:           0.step(source.bytesize - 1, PAGE_SIZE) do |offset|
// 268:             data << digest.digest(source.byteslice(offset, PAGE_SIZE))
// 269:           end
// 270:         else
// 271:           data << Utils.nullpad((n_special_slots + n_code_slots) * hash_size)
// 272:         end
// 273:         data
// 274:       end
// 275:
// 276:       # @param data [String] raw CodeDirectory data
// 277:       def initialize(data)
// 278:         super
// 279:         raise CodeSigningError, "invalid CodeDirectory magic: 0x#{magic.to_s(16)}" unless magic == CSMAGIC_CODEDIRECTORY
// 280:         raise CodeSigningError, "CodeDirectory is truncated" if length < 44
// 281:
// 282:         _, _, @version, @flags, @hash_offset, @ident_offset,
// 283:           @n_special_slots, @n_code_slots, @code_limit = serialize.unpack("N9")
// 284:         @hash_size, @hash_type, @platform, @page_size = serialize.unpack("C4", :offset => 36)
// 285:         fixed_size = 44
// 286:         @scatter_offset = unpack_uint32(44) if version >= 0x20100
// 287:         fixed_size = 48 if version >= 0x20100
// 288:         @team_offset = unpack_uint32(48) if version >= 0x20200
// 289:         fixed_size = 52 if version >= 0x20200
// 290:         if version >= CS_SUPPORTSCODELIMIT64
// 291:           raise CodeSigningError, "CodeDirectory is truncated" if length < 64
// 292:
// 293:           @code_limit64 = serialize.unpack1("Q>", :offset => 56)
// 294:           fixed_size = 64
// 295:         end
// 296:         if version >= CS_SUPPORTSEXECSEG
// 297:           raise CodeSigningError, "CodeDirectory is truncated" if length < 88
// 298:
// 299:           @exec_seg_base, @exec_seg_limit, @exec_seg_flags = serialize.unpack("Q>3", :offset => 64)
// 300:           fixed_size = 88
// 301:         end
// 302:         if version >= CS_SUPPORTSRUNTIME
// 303:           raise CodeSigningError, "CodeDirectory is truncated" if length < 96
// 304:
// 305:           @runtime, @pre_encrypt_offset = serialize.unpack("N2", :offset => 88)
// 306:           fixed_size = 96
// 307:         end
// 308:         if version >= CS_SUPPORTSLINKAGE
// 309:           raise CodeSigningError, "CodeDirectory is truncated" if length < 108
// 310:
// 311:           @linkage_hash_type, @linkage_application_type,
// 312:             @linkage_application_subtype, @linkage_offset,
// 313:             @linkage_size = serialize.unpack("CCnN2", :offset => 96)
// 314:           fixed_size = 108
// 315:         end
// 316:         raise CodeSigningError, "CodeDirectory identifier offset is invalid" if ident_offset < fixed_size || ident_offset >= length
// 317:
// 318:         terminator = serialize.index("\x00", ident_offset)
// 319:         raise CodeSigningError, "CodeDirectory identifier is unterminated" unless terminator && terminator < length
// 320:         if hash_size.zero? ||
// 321:            hash_offset < fixed_size ||
// 322:            hash_offset - (n_special_slots * hash_size) < terminator + 1 ||
// 323:            hash_offset + (n_code_slots * hash_size) > length
// 324:           raise CodeSigningError, "CodeDirectory hash range is invalid"
// 325:         end
// 326:
// 327:         @identifier = serialize.byteslice(ident_offset, terminator - ident_offset)
// 328:       end
// 329:
// 330:       # @return [String] the signing identifier
// 331:       attr_reader :identifier
// 332:
// 333:       # @return [Integer] the number of signed bytes
// 334:       def code_limit
// 335:         version >= CS_SUPPORTSCODELIMIT64 && code_limit64&.positive? ? code_limit64 : @code_limit
// 336:       end
// 337:
// 338:       # Returns a code page hash.
// 339:       # @param slot [Integer] a zero-based page slot
// 340:       # @return [String, nil]
// 341:       def code_hash(slot)
// 342:         return if slot.negative? || slot >= n_code_slots
// 343:
// 344:         serialize.byteslice(hash_offset + (slot * hash_size), hash_size)
// 345:       end
// 346:
// 347:       # @return [Symbol, nil] the symbolic hash type
// 348:       def hash_type_sym
// 349:         CS_HASHTYPES[hash_type]
// 350:       end
// 351:
// 352:       # Returns a special-slot hash.
// 353:       # @param slot [Integer] a positive special-slot number
// 354:       # @return [String, nil]
// 355:       def special_hash(slot)
// 356:         return unless slot.positive? && slot <= n_special_slots
// 357:
// 358:         serialize.byteslice(hash_offset - (slot * hash_size), hash_size)
// 359:       end
// 360:
// 361:       # @return [Hash] a hash representation of this CodeDirectory
// 362:       def to_h
// 363:         {
// 364:           "version" => version,
// 365:           "flags" => flags,
// 366:           "identifier" => identifier,
// 367:           "hash_offset" => hash_offset,
// 368:           "n_special_slots" => n_special_slots,
// 369:           "n_code_slots" => n_code_slots,
// 370:           "code_limit" => code_limit,
// 371:           "hash_size" => hash_size,
// 372:           "hash_type" => hash_type,
// 373:           "hash_type_sym" => hash_type_sym,
// 374:           "page_size" => page_size,
// 375:         }.merge super
// 376:       end
// 377:
// 378:       private
// 379:
// 380:       def unpack_uint32(offset)
// 381:         raise CodeSigningError, "CodeDirectory is truncated" if length < offset + 4
// 382:
// 383:         serialize.unpack1("N", :offset => offset)
// 384:       end
// 385:     end
// 386:
// 387:     # Generates and embeds an ad-hoc signature in one Mach-O slice.
// 388:     class AdhocSigner
// 389:       # @param macho [MachOFile] the slice to sign
// 390:       # @param identifier [String] the signing identifier
// 391:       def initialize(macho, identifier)
// 392:         @macho = macho
// 393:         @identifier = identifier
// 394:       end
// 395:
// 396:       # Embeds a new signature.
// 397:       # @return [void]
// 398:       def sign!
// 399:         signature_commands = @macho[:LC_CODE_SIGNATURE]
// 400:         raise CodeSigningError, "Mach-O contains multiple LC_CODE_SIGNATURE commands" if signature_commands.size > 1
// 401:
// 402:         signature_command = signature_commands.first
// 403:         metadata = metadata_from(signature_command)
// 404:         remove_signature(signature_command) if signature_command&.datasize&.positive?
// 405:         add_signature_command unless signature_command
// 406:
// 407:         signature_command = @macho[:LC_CODE_SIGNATURE].first
// 408:         linkedit_segments = @macho.segments.select { |segment| segment.segname == "__LINKEDIT" }
// 409:         raise CodeSigningError, "Mach-O must contain exactly one __LINKEDIT segment" unless linkedit_segments.one?
// 410:
// 411:         linkedit = linkedit_segments.first
// 412:
// 413:         @macho.serialize << Utils.nullpad(Utils.padding_for(@macho.serialize.bytesize, 16))
// 414:         dataoff = @macho.serialize.bytesize
// 415:         raise CodeSigningError, "code signature offset exceeds LC_CODE_SIGNATURE" if dataoff > 0xffffffff
// 416:
// 417:         entries = signature_entries(metadata, :hashes => false)
// 418:         datasize = Utils.round(SuperBlob.build(entries).bytesize, 16)
// 419:
// 420:         update_linkedit_data_command(signature_command, dataoff, datasize)
// 421:         update_linkedit_segment(linkedit, dataoff + datasize)
// 422:
// 423:         entries = signature_entries(metadata)
// 424:         signature = SuperBlob.build(entries)
// 425:         @macho.serialize << signature << Utils.nullpad(datasize - signature.bytesize)
// 426:         @macho.populate_fields
// 427:         nil
// 428:       end
// 429:
// 430:       private
// 431:
// 432:       def metadata_from(signature_command)
// 433:         return default_metadata unless signature_command&.datasize&.positive?
// 434:
// 435:         superblob = signature_command.superblob
// 436:         code_directory = superblob.blobs.grep(CodeDirectory).find { |blob| blob.hash_type == CS_HASHTYPE_SHA256 } ||
// 437:                          superblob.blobs.grep(CodeDirectory).first
// 438:         return default_metadata unless code_directory
// 439:         return default_metadata if code_directory.flags.anybits?(CS_LINKER_SIGNED)
// 440:
// 441:         components = PRESERVED_COMPONENT_SLOTS.to_h do |slot|
// 442:           [slot, superblob.blob(slot)&.serialize]
// 443:         end.compact
// 444:         {
// 445:           :components => components,
// 446:           :exec_seg_flags => code_directory.exec_seg_flags.to_i,
// 447:           :flags => (code_directory.flags & ~CS_LINKER_SIGNED) | CS_ADHOC,
// 448:           :runtime => code_directory.runtime.to_i,
// 449:         }
// 450:       end
// 451:
// 452:       def default_metadata
// 453:         {
// 454:           :components => {},
// 455:           :exec_seg_flags => 0,
// 456:           :flags => CS_ADHOC,
// 457:           :runtime => 0,
// 458:         }
// 459:       end
// 460:
// 461:       def remove_signature(signature_command)
// 462:         end_offset = signature_command.dataoff + signature_command.datasize
// 463:         trailing_data = @macho.serialize.byteslice(end_offset..).to_s
// 464:         unless signature_command.dataoff <= @macho.serialize.bytesize &&
// 465:                end_offset <= @macho.serialize.bytesize &&
// 466:                trailing_data.bytesize <= 15 && trailing_data.bytes.all?(&:zero?)
// 467:           raise CodeSigningError, "LC_CODE_SIGNATURE does not point to the end of the Mach-O"
// 468:         end
// 469:
// 470:         @macho.serialize.slice!(signature_command.dataoff..)
// 471:         @macho.populate_fields
// 472:       end
// 473:
// 474:       def add_signature_command
// 475:         @macho.add_command(LoadCommands::LoadCommand.create(:LC_CODE_SIGNATURE, 0, 0))
// 476:       rescue ModificationError => e
// 477:         raise CodeSigningError, e.message
// 478:       end
// 479:
// 480:       def signature_entries(metadata, hashes: true)
// 481:         components = metadata.fetch(:components).dup
// 482:         components[CSSLOT_REQUIREMENTS] ||= [CSMAGIC_REQUIREMENTS, 12, 0].pack("N3")
// 483:         special_slots = components.dup
// 484:         if (info_plist = CodeSigning.info_plist(@macho))
// 485:           special_slots[CSSLOT_INFOSLOT] = info_plist
// 486:         end
// 487:
// 488:         text = @macho.segments.find { |segment| segment.segname == "__TEXT" }
// 489:         exec_seg_flags = metadata.fetch(:exec_seg_flags)
// 490:         if @macho.executable?
// 491:           exec_seg_flags |= CS_EXECSEG_MAIN_BINARY
// 492:         else
// 493:           exec_seg_flags &= ~CS_EXECSEG_MAIN_BINARY
// 494:         end
// 495:         source = @macho.serialize
// 496:         entries = {}
// 497:         hash_types.each_with_index do |hash_type, index|
// 498:           entries[index.zero? ? CSSLOT_CODEDIRECTORY : CSSLOT_ALTERNATE_CODEDIRECTORIES + index - 1] =
// 499:             CodeDirectory.build(source,
// 500:                                 :identifier => @identifier,
// 501:                                 :hash_type => hash_type,
// 502:                                 :flags => metadata.fetch(:flags),
// 503:                                 :special_slots => special_slots,
// 504:                                 :exec_seg_base => text&.fileoff.to_i,
// 505:                                 :exec_seg_limit => text&.filesize.to_i,
// 506:                                 :exec_seg_flags => exec_seg_flags,
// 507:                                 :runtime => metadata.fetch(:runtime),
// 508:                                 :hashes => hashes)
// 509:         end
// 510:         components.each { |slot, blob| entries[slot] = blob }
// 511:         entries[CSSLOT_SIGNATURESLOT] = [CSMAGIC_BLOBWRAPPER, 8].pack("N2")
// 512:         entries
// 513:       end
// 514:
// 515:       def hash_types
// 516:         version = @macho[:LC_VERSION_MIN_MACOSX].first&.version
// 517:         build_version = @macho[:LC_BUILD_VERSION].first
// 518:         version ||= build_version.minos if build_version&.platform == 1
// 519:         version && version < 0x000a0b04 ? [CS_HASHTYPE_SHA1, CS_HASHTYPE_SHA256] : [CS_HASHTYPE_SHA256]
// 520:       end
// 521:
// 522:       def update_linkedit_data_command(command, dataoff, datasize)
// 523:         format = Utils.specialize_format("L=", @macho.endianness)
// 524:         @macho.serialize[command.view.offset + 8, 8] = [dataoff, datasize].pack(format * 2)
// 525:       end
// 526:
// 527:       def update_linkedit_segment(segment, final_size)
// 528:         filesize = final_size - segment.fileoff
// 529:         raise CodeSigningError, "__LINKEDIT extends past the end of the Mach-O" if filesize.negative?
// 530:         raise CodeSigningError, "__LINKEDIT exceeds its 32-bit filesize" if @macho.magic32? && filesize > 0xffffffff
// 531:
// 532:         if @macho.magic64?
// 533:           format = Utils.specialize_format("Q=", @macho.endianness)
// 534:           @macho.serialize[segment.view.offset + 48, 8] = [filesize].pack(format)
// 535:           @macho.serialize[segment.view.offset + 32, 8] = [Utils.round(filesize, 2**@macho.segment_alignment)].pack(format) if filesize > segment.vmsize
// 536:         else
// 537:           format = Utils.specialize_format("L=", @macho.endianness)
// 538:           @macho.serialize[segment.view.offset + 36, 4] = [filesize].pack(format)
// 539:           @macho.serialize[segment.view.offset + 28, 4] = [Utils.round(filesize, 2**@macho.segment_alignment)].pack(format) if filesize > segment.vmsize
// 540:         end
// 541:       end
// 542:     end
// 543:
// 544:     # Derives the identifier used by Apple's ad-hoc signer for a bare Mach-O.
// 545:     # @param macho [MachOFile] a Mach-O slice
// 546:     # @param filename [String, nil] its filename
// 547:     # @return [String]
// 548:     def self.identifier(macho, filename)
// 549:       if (match = info_plist(macho)&.match(%r{<key>\s*CFBundleIdentifier\s*</key>\s*<string>\s*([^<]+?)\s*</string>}m))
// 550:         return match[1]
// 551:       end
// 552:
// 553:       filename = File.basename(filename || "adhoc")
// 554:       filename = File.basename(filename, File.extname(filename))
// 555:       return filename if filename.include?(".")
// 556:
// 557:       # Apple hex-encodes either "UUID" plus LC_UUID or, for legacy inputs,
// 558:       # SHA-1 of the base Mach header and load-command region.
// 559:       # https://github.com/apple-oss-distributions/Security/blob/db15acbe6a7f257a859ad9a3bb86097bfe0679d9/OSX/libsecurity_codesigning/lib/machorep.cpp#L232-L264
// 560:       # https://github.com/apple-oss-distributions/Security/blob/db15acbe6a7f257a859ad9a3bb86097bfe0679d9/OSX/libsecurity_codesigning/lib/signer.cpp#L1025-L1047
// 561:       uuid = macho[:LC_UUID].first
// 562:       identity = if uuid
// 563:         ("UUID".b + uuid.uuid.pack("C*")).unpack1("H*")
// 564:       else
// 565:         digest = Digest::SHA1.new
// 566:         digest << macho.serialize.byteslice(0, Headers::MachHeader.bytesize)
// 567:         digest << macho.serialize.byteslice(macho.header.class.bytesize, macho.sizeofcmds)
// 568:         digest.hexdigest
// 569:       end
// 570:       "#{filename}-#{identity}"
// 571:     end
// 572:
// 573:     # Returns an embedded Info.plist, if present.
// 574:     # @param macho [MachOFile] a Mach-O slice
// 575:     # @return [String, nil]
// 576:     def self.info_plist(macho)
// 577:       section = macho.segments.flat_map(&:sections).find do |candidate|
// 578:         candidate.segname == "__TEXT" && candidate.sectname == "__info_plist"
// 579:       end
// 580:       macho.serialize.byteslice(section.offset, section.size) if section
// 581:     end
// 582:   end
// 583: end
