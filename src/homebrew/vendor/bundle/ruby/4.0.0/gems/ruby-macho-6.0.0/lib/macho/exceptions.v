module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/exceptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :macho_slice` at line 23.
pub fn ruby_exceptions_l23_d1_macho_slice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macho_slice', ...args)
}

// Ruby attr_accessor `attr_accessor :macho_slice` at line 23.
pub fn ruby_exceptions_l23_d2_macho_slice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macho_slice=', ...args)
}

// Ruby method `to_s` at line 26.
pub fn ruby_exceptions_l26_d3_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `initialize` at line 39.
pub fn ruby_exceptions_l39_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(magic)` at line 47.
pub fn ruby_exceptions_l47_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 54.
pub fn ruby_exceptions_l54_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 61.
pub fn ruby_exceptions_l61_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(fat_cputype, fat_cpusubtype, macho_cputype, macho_cpusubtype)` at line 69.
pub fn ruby_exceptions_l69_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 83.
pub fn ruby_exceptions_l83_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 90.
pub fn ruby_exceptions_l90_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(cputype)` at line 98.
pub fn ruby_exceptions_l98_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(cputype, cpusubtype)` at line 107.
pub fn ruby_exceptions_l107_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(num)` at line 116.
pub fn ruby_exceptions_l116_d13_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(num)` at line 124.
pub fn ruby_exceptions_l124_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(size)` at line 132.
pub fn ruby_exceptions_l132_d15_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(cmd_sym)` at line 140.
pub fn ruby_exceptions_l140_d16_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(cmd_sym, expected_arity, actual_arity)` at line 151.
pub fn ruby_exceptions_l151_d17_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(cmd_sym)` at line 160.
pub fn ruby_exceptions_l160_d18_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(lc)` at line 168.
pub fn ruby_exceptions_l168_d19_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(offset)` at line 177.
pub fn ruby_exceptions_l177_d20_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(filename)` at line 185.
pub fn ruby_exceptions_l185_d21_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(dylib)` at line 195.
pub fn ruby_exceptions_l195_d22_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 202.
pub fn ruby_exceptions_l202_d23_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(path)` at line 210.
pub fn ruby_exceptions_l210_d24_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(path)` at line 218.
pub fn ruby_exceptions_l218_d25_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(thing)` at line 226.
pub fn ruby_exceptions_l226_d26_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(offset)` at line 235.
pub fn ruby_exceptions_l235_d27_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
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
