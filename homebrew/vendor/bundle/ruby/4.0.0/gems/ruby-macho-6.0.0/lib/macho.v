module lib

import ruby
import encoding.binary
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho.rb`.
// The original source is retained below until every stub has a typed V body.
pub const version = '6.0.0'

const top_fat_magic = u32(0xcafe_babe)
const top_fat_magic64 = u32(0xcafe_babf)
const top_mh_magic = u32(0xfeed_face)
const top_mh_cigam = u32(0xcefa_edfe)
const top_mh_magic64 = u32(0xfeed_facf)
const top_mh_cigam64 = u32(0xcffa_edfe)

pub enum MachoFileKind {
	thin
	fat
}

// OpenedMachoFile is the standalone top-level adapter. The complete typed
// MachoFile and FatFile implementations live in the sibling `macho` module;
// V cannot import that module here because the generated vendored module path
// contains dotted version-directory names.
pub struct OpenedMachoFile {
pub:
	filename string
	magic    u32
	kind     MachoFileKind
}

pub struct MachoCodesignPlan {
pub:
	executable string
	arguments  []string
}

fn top_macho_boundary(file &OpenedMachoFile) ruby.Value {
	return ruby.structured_value(if file.kind == .fat {
		'MachO::FatFile'
	} else {
		'MachO::MachOFile'
	}, if file.kind == .fat { '#<MachO::FatFile>' } else { '#<MachO::MachOFile>' }, {
		'filename': file.filename
		'magic':    file.magic.str()
		'kind':     file.kind.str()
	})
}

fn top_macho_magic(magic u32) bool {
	return magic in [top_mh_magic, top_mh_cigam, top_mh_magic64, top_mh_cigam64]
}

fn top_macho_fat_magic(magic u32) bool {
	return magic in [top_fat_magic, top_fat_magic64]
}

fn top_macho_hex(value u32) string {
	mut encoded := u64(value).hex()
	if encoded.len < 2 {
		encoded = '0'.repeat(2 - encoded.len) + encoded
	}
	return encoded
}

pub fn open(filename string) !&OpenedMachoFile {
	if !os.is_file(filename) {
		return error('${filename}: no such file')
	}
	data := os.read_bytes(filename)!
	if data.len < 4 {
		return error('File is too short to be a valid Mach-O')
	}
	magic := binary.big_endian_u32(data[..4])
	if top_macho_fat_magic(magic) {
		return &OpenedMachoFile{
			filename: filename
			magic: magic
			kind: .fat
		}
	}
	if top_macho_magic(magic) {
		return &OpenedMachoFile{
			filename: filename
			magic: magic
			kind: .thin
		}
	}
	return error('Unrecognized Mach-O magic: 0x${top_macho_hex(magic)}')
}

pub fn codesign_plan(filename string) !MachoCodesignPlan {
	if os.user_os() != 'macos' {
		return error('platform ad-hoc codesigning is only available on macOS')
	}
	executable := os.find_abs_path_of_executable('codesign') or {
		return error('the codesign executable is not available')
	}
	return MachoCodesignPlan{
		executable: executable
		arguments: ['--force', '--sign', '-', filename]
	}
}

pub fn codesign(filename string) ! {
	if !os.is_file(filename) {
		return error('${filename}: no such file')
	}
	open(filename) or {
		return error('${filename}: signing failed: ${err.msg()}')
	}
	plan := codesign_plan(filename) or {
		return error('${filename}: signing failed: ${err.msg()}')
	}
	mut command_parts := [os.quoted_path(plan.executable)]
	command_parts << plan.arguments.map(os.quoted_path(it))
	command := command_parts.join(' ')
	result := os.execute(command)
	if result.exit_code != 0 {
		message := result.output.trim_space()
		detail := if message == '' {
			'codesign exited with status ${result.exit_code}'
		} else {
			message
		}
		return error('${filename}: signing failed: ${detail}')
	}
}

// Ruby method `self.open(filename)` at line 27.
pub fn ruby_macho_l27_d1_self_open(args ...ruby.Value) ruby.Value {
	if args.len < 1 {
		panic('open requires a filename')
	}
	return top_macho_boundary(open(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.codesign!(filename)` at line 50.
pub fn ruby_macho_l50_d2_self_codesign(args ...ruby.Value) ruby.Value {
	if args.len < 1 {
		panic('codesign! requires a filename')
	}
	codesign(args[0].as_string()) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require_relative "macho/utils"
// 4: require_relative "macho/structure"
// 5: require_relative "macho/view"
// 6: require_relative "macho/headers"
// 7: require_relative "macho/code_signing"
// 8: require_relative "macho/load_commands"
// 9: require_relative "macho/sections"
// 10: require_relative "macho/macho_file"
// 11: require_relative "macho/fat_file"
// 12: require_relative "macho/exceptions"
// 13: require_relative "macho/tools"
// 14:
// 15: # The primary namespace for ruby-macho.
// 16: module MachO
// 17:   # release version
// 18:   VERSION = "6.0.0"
// 19:
// 20:   # Opens the given filename as a MachOFile or FatFile, depending on its magic.
// 21:   # @param filename [String] the file being opened
// 22:   # @return [MachOFile] if the file is a Mach-O
// 23:   # @return [FatFile] if the file is a Fat file
// 24:   # @raise [ArgumentError] if the given file does not exist
// 25:   # @raise [TruncatedFileError] if the file is too small to have a valid header
// 26:   # @raise [MagicError] if the file's magic is not valid Mach-O magic
// 27:   def self.open(filename)
// 28:     raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 29:     raise TruncatedFileError unless File.stat(filename).size >= 4
// 30:
// 31:     magic = File.open(filename, "rb") { |f| f.read(4) }.unpack1("N")
// 32:
// 33:     if Utils.fat_magic?(magic)
// 34:       file = FatFile.new(filename)
// 35:     elsif Utils.magic?(magic)
// 36:       file = MachOFile.new(filename)
// 37:     else
// 38:       raise MagicError, magic
// 39:     end
// 40:
// 41:     file
// 42:   end
// 43:
// 44:   # Signs a thin or fat Mach-O using an ad-hoc identity.
// 45:   # Necessary after changing signed Mach-O data because the signature covers
// 46:   # the header, load commands and all bytes preceding the signature.
// 47:   # @param filename [String] the file being opened
// 48:   # @return [void]
// 49:   # @raise [CodeSigningError] if the operation fails
// 50:   def self.codesign!(filename)
// 51:     raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 52:
// 53:     file = MachO.open(filename)
// 54:     file.codesign!
// 55:     file.write!
// 56:     nil
// 57:   rescue MachOError => e
// 58:     raise CodeSigningError, "#{filename}: signing failed: #{e.message}"
// 59:   end
// 60: end
