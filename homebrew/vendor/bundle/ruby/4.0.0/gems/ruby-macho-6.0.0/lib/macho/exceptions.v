module macho

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/exceptions.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum MachoErrorKind {
	macho
	modification
	code_signing
	recoverable_modification
	not_a_macho
	truncated_file
	magic
	java_class_file
	zero_architecture
	cpu_type_mismatch
	fat_binary
	macho_binary
	cpu_type
	cpu_subtype
	filetype
	load_command
	load_command_size
	load_command_not_creatable
	load_command_creation_arity
	load_command_not_serializable
	lc_str_malformed
	offset_insertion
	header_pad
	dylib_unknown
	dylib_id_missing
	rpath_unknown
	rpath_exists
	unimplemented
	fat_arch_offset_overflow
	compressed_macho
	decompression
}

@[heap]
pub struct MachoErrorInfo {
pub:
	kind    MachoErrorKind
	message string
mut:
	has_macho_slice bool
	macho_slice     int
}

pub fn new_macho_error(kind MachoErrorKind, message string) &MachoErrorInfo {
	return &MachoErrorInfo{
		kind: kind
		message: message
	}
}

pub fn (error_info &MachoErrorInfo) msg() string {
	return if error_info.has_macho_slice {
		'While modifying Mach-O slice ${error_info.macho_slice}: ${error_info.message}'
	} else {
		error_info.message
	}
}

pub fn (error_info &MachoErrorInfo) code() int {
	return 1
}

pub fn (error_info &MachoErrorInfo) str() string {
	return error_info.msg()
}

pub fn (mut error_info MachoErrorInfo) set_macho_slice(slice ?int) {
	if value := slice {
		error_info.macho_slice = value
		error_info.has_macho_slice = true
	} else {
		error_info.macho_slice = 0
		error_info.has_macho_slice = false
	}
}

fn macho_hex(value i64, width int) string {
	mut encoded := u64(value).hex()
	if encoded.len < width {
		encoded = '0'.repeat(width - encoded.len) + encoded
	}
	return encoded
}

pub fn truncated_file_error() &MachoErrorInfo {
	return new_macho_error(.truncated_file, 'File is too short to be a valid Mach-O')
}

pub fn magic_error(magic i64) &MachoErrorInfo {
	return new_macho_error(.magic, 'Unrecognized Mach-O magic: 0x${macho_hex(magic, 2)}')
}

pub fn java_class_file_error() &MachoErrorInfo {
	return new_macho_error(.java_class_file, 'File is a Java class file')
}

pub fn zero_architecture_error() &MachoErrorInfo {
	return new_macho_error(.zero_architecture, 'Fat file has zero internal architectures')
}

pub fn cpu_type_mismatch_error(fat_cputype i64, fat_cpusubtype i64, macho_cputype i64, macho_cpusubtype i64) &MachoErrorInfo {
	return new_macho_error(.cpu_type_mismatch, 'Mismatch between cputypes >> 0x${macho_hex(fat_cputype, 8)} and 0x${macho_hex(macho_cputype, 8)}\nand/or cpusubtypes >> 0x${macho_hex(fat_cpusubtype, 8)} and 0x${macho_hex(macho_cpusubtype, 8)}')
}

pub fn fat_binary_error() &MachoErrorInfo {
	return new_macho_error(.fat_binary, 'Fat binaries must be loaded with MachO::FatFile')
}

pub fn macho_binary_error() &MachoErrorInfo {
	return new_macho_error(.macho_binary, 'Normal binaries must be loaded with MachO::MachOFile')
}

pub fn cpu_type_error(cputype i64) &MachoErrorInfo {
	return new_macho_error(.cpu_type, 'Unrecognized CPU type: 0x${macho_hex(cputype, 8)}')
}

pub fn cpu_subtype_error(cputype i64, cpusubtype i64) &MachoErrorInfo {
	return new_macho_error(.cpu_subtype, 'Unrecognized CPU sub-type: 0x${macho_hex(cpusubtype, 8)} (for CPU type: 0x${macho_hex(cputype, 8)}')
}

pub fn filetype_error(number i64) &MachoErrorInfo {
	return new_macho_error(.filetype, 'Unrecognized Mach-O filetype code: 0x${macho_hex(number, 2)}')
}

pub fn load_command_error(number i64) &MachoErrorInfo {
	return new_macho_error(.load_command, 'Unrecognized Mach-O load command: 0x${macho_hex(number, 2)}')
}

pub fn load_command_size_error(size i64) &MachoErrorInfo {
	return new_macho_error(.load_command_size, 'Invalid Mach-O load command size: ${size}')
}

pub fn load_command_not_creatable_error(command string) &MachoErrorInfo {
	return new_macho_error(.load_command_not_creatable, 'Load commands of type ${command} cannot be created manually')
}

pub fn load_command_creation_arity_error(command string, expected i64, actual i64) &MachoErrorInfo {
	return new_macho_error(.load_command_creation_arity, 'Expected ${expected} arguments for ${command} creation, got ${actual}')
}

pub fn load_command_not_serializable_error(command string) &MachoErrorInfo {
	return new_macho_error(.load_command_not_serializable, 'Load commands of type ${command} cannot be serialized')
}

pub fn lc_str_malformed_error(command_type string, offset i64) &MachoErrorInfo {
	return new_macho_error(.lc_str_malformed, 'Load command ${command_type} at offset ${offset} contains a malformed string')
}

pub fn offset_insertion_error(offset i64) &MachoErrorInfo {
	return new_macho_error(.offset_insertion, 'Insertion at offset ${offset} is not valid')
}

pub fn header_pad_error(filename string) &MachoErrorInfo {
	return new_macho_error(.header_pad, 'Updated load commands do not fit in the header of ${filename}. ${filename} needs to be relinked, possibly with -headerpad or -headerpad_max_install_names')
}

pub fn dylib_unknown_error(dylib string) &MachoErrorInfo {
	return new_macho_error(.dylib_unknown, 'No such dylib name: ${dylib}')
}

pub fn dylib_id_missing_error() &MachoErrorInfo {
	return new_macho_error(.dylib_id_missing, 'Dylib is missing a dylib ID')
}

pub fn rpath_unknown_error(path string) &MachoErrorInfo {
	return new_macho_error(.rpath_unknown, 'No such runtime path: ${path}')
}

pub fn rpath_exists_error(path string) &MachoErrorInfo {
	return new_macho_error(.rpath_exists, '${path} already exists')
}

pub fn unimplemented_macho_error(thing string) &MachoErrorInfo {
	return new_macho_error(.unimplemented, 'Unimplemented: ${thing}')
}

pub fn fat_arch_offset_overflow_error(offset i64) &MachoErrorInfo {
	return new_macho_error(.fat_arch_offset_overflow, 'Offset ${offset} exceeds the 32-bit width of a fat_arch offset. Consider merging with `fat64: true`')
}

fn macho_error_boundary(error_info &MachoErrorInfo) ruby.Value {
	return ruby.structured_value('MachO::${error_info.kind}', error_info.msg(), {
		'macho_error_address': u64(voidptr(error_info)).str()
		'message':             error_info.message
	})
}

fn macho_error_from_args(args []ruby.Value) &MachoErrorInfo {
	if args.len == 0 {
		panic('MachO error method requires a receiver')
	}
	address := (args[0].attribute('macho_error_address') or {
		panic('${args[0].type_name} has no translated MachO error state')
	}).u64()
	return unsafe { &MachoErrorInfo(voidptr(address)) }
}

fn macho_integer(value ruby.Value) i64 {
	return value.as_int() or { panic(err) }
}

// Ruby attr_accessor `attr_accessor :macho_slice` at line 23.
pub fn ruby_exceptions_l23_d1_macho_slice(args ...ruby.Value) ruby.Value {
	error_info := macho_error_from_args(args)
	return if error_info.has_macho_slice {
		ruby.int_value(error_info.macho_slice)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :macho_slice` at line 23.
pub fn ruby_exceptions_l23_d2_macho_slice(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('RecoverableModificationError#macho_slice= requires a value')
	}
	mut error_info := macho_error_from_args(args)
	if args[1].type_name == 'NilClass' {
		error_info.set_macho_slice(none)
	} else {
		error_info.set_macho_slice(int(macho_integer(args[1])))
	}
	return args[1]
}

// Ruby method `to_s` at line 26.
pub fn ruby_exceptions_l26_d3_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macho_error_from_args(args).msg())
}

// Ruby method `initialize` at line 39.
pub fn ruby_exceptions_l39_d4_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(truncated_file_error())
}

// Ruby method `initialize(magic)` at line 47.
pub fn ruby_exceptions_l47_d5_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MagicError#initialize requires magic')
	}
	return macho_error_boundary(magic_error(macho_integer(args[0])))
}

// Ruby method `initialize` at line 54.
pub fn ruby_exceptions_l54_d6_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(java_class_file_error())
}

// Ruby method `initialize` at line 61.
pub fn ruby_exceptions_l61_d7_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(zero_architecture_error())
}

// Ruby method `initialize(fat_cputype, fat_cpusubtype, macho_cputype, macho_cpusubtype)` at line 69.
pub fn ruby_exceptions_l69_d8_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('CPUTypeMismatchError#initialize requires four CPU values')
	}
	return macho_error_boundary(cpu_type_mismatch_error(macho_integer(args[0]), macho_integer(args[1]), macho_integer(args[2]), macho_integer(args[3])))
}

// Ruby method `initialize` at line 83.
pub fn ruby_exceptions_l83_d9_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(fat_binary_error())
}

// Ruby method `initialize` at line 90.
pub fn ruby_exceptions_l90_d10_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(macho_binary_error())
}

// Ruby method `initialize(cputype)` at line 98.
pub fn ruby_exceptions_l98_d11_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('CPUTypeError#initialize requires cputype')
	}
	return macho_error_boundary(cpu_type_error(macho_integer(args[0])))
}

// Ruby method `initialize(cputype, cpusubtype)` at line 107.
pub fn ruby_exceptions_l107_d12_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('CPUSubtypeError#initialize requires cputype and cpusubtype')
	}
	return macho_error_boundary(cpu_subtype_error(macho_integer(args[0]), macho_integer(args[1])))
}

// Ruby method `initialize(num)` at line 116.
pub fn ruby_exceptions_l116_d13_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('FiletypeError#initialize requires number')
	}
	return macho_error_boundary(filetype_error(macho_integer(args[0])))
}

// Ruby method `initialize(num)` at line 124.
pub fn ruby_exceptions_l124_d14_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LoadCommandError#initialize requires number')
	}
	return macho_error_boundary(load_command_error(macho_integer(args[0])))
}

// Ruby method `initialize(size)` at line 132.
pub fn ruby_exceptions_l132_d15_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LoadCommandSizeError#initialize requires size')
	}
	return macho_error_boundary(load_command_size_error(macho_integer(args[0])))
}

// Ruby method `initialize(cmd_sym)` at line 140.
pub fn ruby_exceptions_l140_d16_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LoadCommandNotCreatableError#initialize requires command')
	}
	return macho_error_boundary(load_command_not_creatable_error(args[0].as_string()))
}

// Ruby method `initialize(cmd_sym, expected_arity, actual_arity)` at line 151.
pub fn ruby_exceptions_l151_d17_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('LoadCommandCreationArityError#initialize requires command and arities')
	}
	return macho_error_boundary(load_command_creation_arity_error(args[0].as_string(), macho_integer(args[1]), macho_integer(args[2])))
}

// Ruby method `initialize(cmd_sym)` at line 160.
pub fn ruby_exceptions_l160_d18_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LoadCommandNotSerializableError#initialize requires command')
	}
	return macho_error_boundary(load_command_not_serializable_error(args[0].as_string()))
}

// Ruby method `initialize(lc)` at line 168.
pub fn ruby_exceptions_l168_d19_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LCStrMalformedError#initialize requires load command')
	}
	command := args[0]
	command_type := command.attribute('type') or { command.as_string() }
	offset := (command.attribute('offset') or { '0' }).i64()
	return macho_error_boundary(lc_str_malformed_error(command_type, offset))
}

// Ruby method `initialize(offset)` at line 177.
pub fn ruby_exceptions_l177_d20_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('OffsetInsertionError#initialize requires offset')
	}
	return macho_error_boundary(offset_insertion_error(macho_integer(args[0])))
}

// Ruby method `initialize(filename)` at line 185.
pub fn ruby_exceptions_l185_d21_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('HeaderPadError#initialize requires filename')
	}
	return macho_error_boundary(header_pad_error(args[0].as_string()))
}

// Ruby method `initialize(dylib)` at line 195.
pub fn ruby_exceptions_l195_d22_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('DylibUnknownError#initialize requires dylib')
	}
	return macho_error_boundary(dylib_unknown_error(args[0].as_string()))
}

// Ruby method `initialize` at line 202.
pub fn ruby_exceptions_l202_d23_initialize(args ...ruby.Value) ruby.Value {
	return macho_error_boundary(dylib_id_missing_error())
}

// Ruby method `initialize(path)` at line 210.
pub fn ruby_exceptions_l210_d24_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('RpathUnknownError#initialize requires path')
	}
	return macho_error_boundary(rpath_unknown_error(args[0].as_string()))
}

// Ruby method `initialize(path)` at line 218.
pub fn ruby_exceptions_l218_d25_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('RpathExistsError#initialize requires path')
	}
	return macho_error_boundary(rpath_exists_error(args[0].as_string()))
}

// Ruby method `initialize(thing)` at line 226.
pub fn ruby_exceptions_l226_d26_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('UnimplementedError#initialize requires thing')
	}
	return macho_error_boundary(unimplemented_macho_error(args[0].as_string()))
}

// Ruby method `initialize(offset)` at line 235.
pub fn ruby_exceptions_l235_d27_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('FatArchOffsetOverflowError#initialize requires offset')
	}
	return macho_error_boundary(fat_arch_offset_overflow_error(macho_integer(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A generic Mach-O error in execution.
// 5:   class MachOError < RuntimeError
// 6:   end
// 7:
// 8:   # Raised when a Mach-O file modification fails.
// 9:   class ModificationError < MachOError
// 10:   end
// 11:
// 12:   # Raised when codesigning fails. Certain environments
// 13:   # may want to rescue this to treat it as non-fatal.
// 14:   class CodeSigningError < MachOError
// 15:   end
// 16:
// 17:   # Raised when a Mach-O file modification fails but can be recovered when
// 18:   # operating on multiple Mach-O slices of a fat binary in non-strict mode.
// 19:   class RecoverableModificationError < ModificationError
// 20:     # @return [Integer, nil] The index of the Mach-O slice of a fat binary for
// 21:     #   which modification failed or `nil` if not a fat binary. This is used to
// 22:     #   make the error message more useful.
// 23:     attr_accessor :macho_slice
// 24:
// 25:     # @return [String] The exception message.
// 26:     def to_s
// 27:       s = super.to_s
// 28:       s = "While modifying Mach-O slice #{@macho_slice}: #{s}" if @macho_slice
// 29:       s
// 30:     end
// 31:   end
// 32:
// 33:   # Raised when a file is not a Mach-O.
// 34:   class NotAMachOError < MachOError
// 35:   end
// 36:
// 37:   # Raised when a file is too short to be a valid Mach-O file.
// 38:   class TruncatedFileError < NotAMachOError
// 39:     def initialize
// 40:       super("File is too short to be a valid Mach-O")
// 41:     end
// 42:   end
// 43:
// 44:   # Raised when a file's magic bytes are not valid Mach-O magic.
// 45:   class MagicError < NotAMachOError
// 46:     # @param num [Integer] the unknown number
// 47:     def initialize(magic)
// 48:       super("Unrecognized Mach-O magic: 0x%02<magic>x" % { :magic => magic })
// 49:     end
// 50:   end
// 51:
// 52:   # Raised when a file is a Java classfile instead of a fat Mach-O.
// 53:   class JavaClassFileError < NotAMachOError
// 54:     def initialize
// 55:       super("File is a Java class file")
// 56:     end
// 57:   end
// 58:
// 59:   # Raised when a a fat Mach-O file has zero architectures
// 60:   class ZeroArchitectureError < NotAMachOError
// 61:     def initialize
// 62:       super("Fat file has zero internal architectures")
// 63:     end
// 64:   end
// 65:
// 66:   # Raised when there is a mismatch between the fat arch
// 67:   # and internal slice cputype or cpusubtype.
// 68:   class CPUTypeMismatchError < NotAMachOError
// 69:     def initialize(fat_cputype, fat_cpusubtype, macho_cputype, macho_cpusubtype)
// 70:       # @param cputype_fat [Integer] the CPU type in the fat header
// 71:       # @param cpusubtype_fat [Integer] the CPU subtype in the fat header
// 72:       # @param cputype_macho [Integer] the CPU type in the macho header
// 73:       # @param cpusubtype_macho [Integer] the CPU subtype in the macho header
// 74:       super("Mismatch between cputypes >> 0x%08<fat_cputype>x and 0x%08<macho_cputype>x\n" \
// 75:             "and/or cpusubtypes >> 0x%08<fat_cpusubtype>x and 0x%08<macho_cpusubtype>x" %
// 76:         { :fat_cputype => fat_cputype, :macho_cputype => macho_cputype,
// 77:           :fat_cpusubtype => fat_cpusubtype, :macho_cpusubtype => macho_cpusubtype })
// 78:     end
// 79:   end
// 80:
// 81:   # Raised when a fat binary is loaded with MachOFile.
// 82:   class FatBinaryError < MachOError
// 83:     def initialize
// 84:       super("Fat binaries must be loaded with MachO::FatFile")
// 85:     end
// 86:   end
// 87:
// 88:   # Raised when a Mach-O is loaded with FatFile.
// 89:   class MachOBinaryError < MachOError
// 90:     def initialize
// 91:       super("Normal binaries must be loaded with MachO::MachOFile")
// 92:     end
// 93:   end
// 94:
// 95:   # Raised when the CPU type is unknown.
// 96:   class CPUTypeError < MachOError
// 97:     # @param cputype [Integer] the unknown CPU type
// 98:     def initialize(cputype)
// 99:       super("Unrecognized CPU type: 0x%08<cputype>x" % { :cputype => cputype })
// 100:     end
// 101:   end
// 102:
// 103:   # Raised when the CPU type/sub-type pair is unknown.
// 104:   class CPUSubtypeError < MachOError
// 105:     # @param cputype [Integer] the CPU type of the unknown pair
// 106:     # @param cpusubtype [Integer] the CPU sub-type of the unknown pair
// 107:     def initialize(cputype, cpusubtype)
// 108:       super("Unrecognized CPU sub-type: 0x%08<cpusubtype>x " \
// 109:             "(for CPU type: 0x%08<cputype>x" % { :cputype => cputype, :cpusubtype => cpusubtype })
// 110:     end
// 111:   end
// 112:
// 113:   # Raised when a mach-o file's filetype field is unknown.
// 114:   class FiletypeError < MachOError
// 115:     # @param num [Integer] the unknown number
// 116:     def initialize(num)
// 117:       super("Unrecognized Mach-O filetype code: 0x%02<num>x" % { :num => num })
// 118:     end
// 119:   end
// 120:
// 121:   # Raised when an unknown load command is encountered.
// 122:   class LoadCommandError < MachOError
// 123:     # @param num [Integer] the unknown number
// 124:     def initialize(num)
// 125:       super("Unrecognized Mach-O load command: 0x%02<num>x" % { :num => num })
// 126:     end
// 127:   end
// 128:
// 129:   # Raised when a load command has an invalid size.
// 130:   class LoadCommandSizeError < NotAMachOError
// 131:     # @param size [Integer] the invalid size
// 132:     def initialize(size)
// 133:       super("Invalid Mach-O load command size: #{size}")
// 134:     end
// 135:   end
// 136:
// 137:   # Raised when a load command can't be created manually.
// 138:   class LoadCommandNotCreatableError < MachOError
// 139:     # @param cmd_sym [Symbol] the uncreatable load command's symbol
// 140:     def initialize(cmd_sym)
// 141:       super("Load commands of type #{cmd_sym} cannot be created manually")
// 142:     end
// 143:   end
// 144:
// 145:   # Raised when the number of arguments used to create a load command manually
// 146:   # is wrong.
// 147:   class LoadCommandCreationArityError < MachOError
// 148:     # @param cmd_sym [Symbol] the load command's symbol
// 149:     # @param expected_arity [Integer] the number of arguments expected
// 150:     # @param actual_arity [Integer] the number of arguments received
// 151:     def initialize(cmd_sym, expected_arity, actual_arity)
// 152:       super("Expected #{expected_arity} arguments for #{cmd_sym} creation, " \
// 153:             "got #{actual_arity}")
// 154:     end
// 155:   end
// 156:
// 157:   # Raised when a load command can't be serialized.
// 158:   class LoadCommandNotSerializableError < MachOError
// 159:     # @param cmd_sym [Symbol] the load command's symbol
// 160:     def initialize(cmd_sym)
// 161:       super("Load commands of type #{cmd_sym} cannot be serialized")
// 162:     end
// 163:   end
// 164:
// 165:   # Raised when a load command string is malformed in some way.
// 166:   class LCStrMalformedError < MachOError
// 167:     # @param lc [MachO::LoadCommand] the load command containing the string
// 168:     def initialize(lc)
// 169:       super("Load command #{lc.type} at offset #{lc.view.offset} contains a " \
// 170:             "malformed string")
// 171:     end
// 172:   end
// 173:
// 174:   # Raised when a change at an offset is not valid.
// 175:   class OffsetInsertionError < ModificationError
// 176:     # @param offset [Integer] the invalid offset
// 177:     def initialize(offset)
// 178:       super("Insertion at offset #{offset} is not valid")
// 179:     end
// 180:   end
// 181:
// 182:   # Raised when load commands are too large to fit in the current file.
// 183:   class HeaderPadError < ModificationError
// 184:     # @param filename [String] the filename
// 185:     def initialize(filename)
// 186:       super("Updated load commands do not fit in the header of " \
// 187:             "#{filename}. #{filename} needs to be relinked, possibly with " \
// 188:             "-headerpad or -headerpad_max_install_names")
// 189:     end
// 190:   end
// 191:
// 192:   # Raised when attempting to change a dylib name that doesn't exist.
// 193:   class DylibUnknownError < RecoverableModificationError
// 194:     # @param dylib [String] the unknown shared library name
// 195:     def initialize(dylib)
// 196:       super("No such dylib name: #{dylib}")
// 197:     end
// 198:   end
// 199:
// 200:   # Raised when a dylib is missing an ID
// 201:   class DylibIdMissingError < RecoverableModificationError
// 202:     def initialize
// 203:       super("Dylib is missing a dylib ID")
// 204:     end
// 205:   end
// 206:
// 207:   # Raised when attempting to change an rpath that doesn't exist.
// 208:   class RpathUnknownError < RecoverableModificationError
// 209:     # @param path [String] the unknown runtime path
// 210:     def initialize(path)
// 211:       super("No such runtime path: #{path}")
// 212:     end
// 213:   end
// 214:
// 215:   # Raised when attempting to add an rpath that already exists.
// 216:   class RpathExistsError < RecoverableModificationError
// 217:     # @param path [String] the extant path
// 218:     def initialize(path)
// 219:       super("#{path} already exists")
// 220:     end
// 221:   end
// 222:
// 223:   # Raised whenever unfinished code is called.
// 224:   class UnimplementedError < MachOError
// 225:     # @param thing [String] the thing that is unimplemented
// 226:     def initialize(thing)
// 227:       super("Unimplemented: #{thing}")
// 228:     end
// 229:   end
// 230:
// 231:   # Raised when attempting to create a {FatFile} from one or more {MachOFile}s
// 232:   #  whose offsets will not fit within the resulting 32-bit {Headers::FatArch#offset} fields.
// 233:   class FatArchOffsetOverflowError < MachOError
// 234:     # @param offset [Integer] the offending offset
// 235:     def initialize(offset)
// 236:       super("Offset #{offset} exceeds the 32-bit width of a fat_arch offset. " \
// 237:             "Consider merging with `fat64: true`")
// 238:     end
// 239:   end
// 240:
// 241:   # Raised when attempting to parse a compressed Mach-O without explicitly
// 242:   # requesting decompression.
// 243:   class CompressedMachOError < MachOError
// 244:   end
// 245:
// 246:   # Raised when attempting to decompress a compressed Mach-O without adequate
// 247:   # dependencies, or on other decompression errors.
// 248:   class DecompressionError < MachOError
// 249:   end
// 250: end
