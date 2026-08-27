module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/structs.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :elf_class` at line 18.
pub fn ruby_structs_l18_d1_elf_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('elf_class', ...args)
}

// Ruby attr_accessor `attr_accessor :elf_class` at line 18.
pub fn ruby_structs_l18_d2_elf_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('elf_class=', ...args)
}

// Ruby attr_accessor `attr_accessor :offset` at line 19.
pub fn ruby_structs_l19_d3_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offset', ...args)
}

// Ruby attr_accessor `attr_accessor :offset` at line 19.
pub fn ruby_structs_l19_d4_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offset=', ...args)
}

// Ruby method `patches` at line 23.
pub fn ruby_structs_l23_d5_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patches', ...args)
}

// Ruby alias `alias to_h snapshot` at line 28.
pub fn ruby_structs_l28_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `new(*args)` at line 34.
pub fn ruby_structs_l34_d7_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new', ...args)
}

// Ruby define_singleton_method `obj.define_singleton_method(m) do |val|` at line 45.
pub fn ruby_structs_l45_d8_m(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('m', ...args)
}

// Ruby method `self_endian` at line 56.
pub fn ruby_structs_l56_d9_self_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self_endian', ...args)
}

// Ruby method `pack(val, bytes)` at line 64.
pub fn ruby_structs_l64_d10_pack(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pack', ...args)
}

// Ruby method `r_addend` at line 206.
pub fn ruby_structs_l206_d11_r_addend(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('r_addend', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'bindata'
// 4:
// 5: module ELFTools
// 6:   # Define ELF related structures in this module.
// 7:   #
// 8:   # Structures are fetched from https://github.com/torvalds/linux/blob/master/include/uapi/linux/elf.h.
// 9:   # Use gem +bindata+ to have these structures support 32/64 bits and little/big endian simultaneously.
// 10:   module Structs
// 11:     # The base structure to define common methods.
// 12:     class ELFStruct < BinData::Record
// 13:       # DRY. Many fields have different type in different arch.
// 14:       CHOICE_SIZE_T = proc do |t = 'uint'|
// 15:         { selection: :elf_class, choices: { 32 => :"#{t}32", 64 => :"#{t}64" }, copy_on_change: true }
// 16:       end
// 17:
// 18:       attr_accessor :elf_class # @return [Integer] 32 or 64.
// 19:       attr_accessor :offset # @return [Integer] The file offset of this header.
// 20:
// 21:       # Records which fields have been patched.
// 22:       # @return [Hash{Integer => Integer}] Patches.
// 23:       def patches
// 24:         @patches ||= {}
// 25:       end
// 26:
// 27:       # BinData hash(Snapshot) that behaves like HashWithIndifferentAccess
// 28:       alias to_h snapshot
// 29:
// 30:       class << self
// 31:         # Hooks the constructor.
// 32:         #
// 33:         # +BinData::Record+ doesn't allow us to override +#initialize+, so we hack +new+ here.
// 34:         def new(*args)
// 35:           # XXX: The better implementation is +new(*args, **kwargs)+, but we can't do this unless bindata changed
// 36:           # lib/bindata/dsl.rb#override_new_in_class to invoke +new+ with both +args+ and +kwargs+.
// 37:           kwargs = args.last.is_a?(Hash) ? args.last : {}
// 38:           offset = kwargs.delete(:offset)
// 39:           super.tap do |obj|
// 40:             obj.offset = offset
// 41:             obj.field_names.each do |f|
// 42:               m = "#{f}=".to_sym
// 43:               old_method = obj.singleton_method(m)
// 44:               obj.singleton_class.send(:undef_method, m)
// 45:               obj.define_singleton_method(m) do |val|
// 46:                 org = obj.send(f)
// 47:                 obj.patches[org.abs_offset] = ELFStruct.pack(val, org.num_bytes)
// 48:                 old_method.call(val)
// 49:               end
// 50:             end
// 51:           end
// 52:         end
// 53:
// 54:         # Gets the endianness of current class.
// 55:         # @return [:little, :big] The endianness.
// 56:         def self_endian
// 57:           bindata_name[-2..] == 'be' ? :big : :little
// 58:         end
// 59:
// 60:         # Packs an integer to string.
// 61:         # @param [Integer] val
// 62:         # @param [Integer] bytes
// 63:         # @return [String]
// 64:         def pack(val, bytes)
// 65:           raise ArgumentError, "Not supported assign type #{val.class}" unless val.is_a?(Integer)
// 66:
// 67:           number = val & ((1 << (8 * bytes)) - 1)
// 68:           out = []
// 69:           bytes.times do
// 70:             out << (number & 0xff)
// 71:             number >>= 8
// 72:           end
// 73:           out = out.pack('C*')
// 74:           self_endian == :little ? out : out.reverse
// 75:         end
// 76:       end
// 77:     end
// 78:
// 79:     # ELF header structure.
// 80:     class ELF_Ehdr < ELFStruct
// 81:       endian :big_and_little
// 82:       struct :e_ident do
// 83:         string :magic, read_length: 4
// 84:         int8 :ei_class
// 85:         int8 :ei_data
// 86:         int8 :ei_version
// 87:         int8 :ei_osabi
// 88:         int8 :ei_abiversion
// 89:         string :ei_padding, read_length: 7 # no use
// 90:       end
// 91:       uint16 :e_type
// 92:       uint16 :e_machine
// 93:       uint32 :e_version
// 94:       # entry point
// 95:       choice :e_entry, **CHOICE_SIZE_T['uint']
// 96:       choice :e_phoff, **CHOICE_SIZE_T['uint']
// 97:       choice :e_shoff, **CHOICE_SIZE_T['uint']
// 98:       uint32 :e_flags
// 99:       uint16 :e_ehsize # size of this header
// 100:       uint16 :e_phentsize # size of each segment
// 101:       uint16 :e_phnum # number of segments
// 102:       uint16 :e_shentsize # size of each section
// 103:       uint16 :e_shnum # number of sections
// 104:       uint16 :e_shstrndx # index of string table section
// 105:     end
// 106:
// 107:     # Section header structure.
// 108:     class ELF_Shdr < ELFStruct
// 109:       endian :big_and_little
// 110:       uint32 :sh_name
// 111:       uint32 :sh_type
// 112:       choice :sh_flags, **CHOICE_SIZE_T['uint']
// 113:       choice :sh_addr, **CHOICE_SIZE_T['uint']
// 114:       choice :sh_offset, **CHOICE_SIZE_T['uint']
// 115:       choice :sh_size, **CHOICE_SIZE_T['uint']
// 116:       uint32 :sh_link
// 117:       uint32 :sh_info
// 118:       choice :sh_addralign, **CHOICE_SIZE_T['uint']
// 119:       choice :sh_entsize, **CHOICE_SIZE_T['uint']
// 120:     end
// 121:
// 122:     # Program header structure for 32-bit.
// 123:     class ELF32_Phdr < ELFStruct
// 124:       endian :big_and_little
// 125:       uint32 :p_type
// 126:       uint32 :p_offset
// 127:       uint32 :p_vaddr
// 128:       uint32 :p_paddr
// 129:       uint32 :p_filesz
// 130:       uint32 :p_memsz
// 131:       uint32 :p_flags
// 132:       uint32 :p_align
// 133:     end
// 134:
// 135:     # Program header structure for 64-bit.
// 136:     class ELF64_Phdr < ELFStruct
// 137:       endian :big_and_little
// 138:       uint32 :p_type
// 139:       uint32 :p_flags
// 140:       uint64 :p_offset
// 141:       uint64 :p_vaddr
// 142:       uint64 :p_paddr
// 143:       uint64 :p_filesz
// 144:       uint64 :p_memsz
// 145:       uint64 :p_align
// 146:     end
// 147:
// 148:     # Gets the class of program header according to bits.
// 149:     ELF_Phdr = {
// 150:       32 => ELF32_Phdr,
// 151:       64 => ELF64_Phdr
// 152:     }.freeze
// 153:
// 154:     # Symbol structure for 32-bit.
// 155:     class ELF32_sym < ELFStruct
// 156:       endian :big_and_little
// 157:       uint32 :st_name
// 158:       uint32 :st_value
// 159:       uint32 :st_size
// 160:       uint8 :st_info
// 161:       uint8 :st_other
// 162:       uint16 :st_shndx
// 163:     end
// 164:
// 165:     # Symbol structure for 64-bit.
// 166:     class ELF64_sym < ELFStruct
// 167:       endian :big_and_little
// 168:       uint32 :st_name  # Symbol name, index in string tbl
// 169:       uint8 :st_info   # Type and binding attributes
// 170:       uint8 :st_other  # No defined meaning, 0
// 171:       uint16 :st_shndx # Associated section index
// 172:       uint64 :st_value # Value of the symbol
// 173:       uint64 :st_size  # Associated symbol size
// 174:     end
// 175:
// 176:     # Get symbol header class according to bits.
// 177:     ELF_sym = {
// 178:       32 => ELF32_sym,
// 179:       64 => ELF64_sym
// 180:     }.freeze
// 181:
// 182:     # Note header.
// 183:     class ELF_Nhdr < ELFStruct
// 184:       endian :big_and_little
// 185:       uint32 :n_namesz # Name size
// 186:       uint32 :n_descsz # Content size
// 187:       uint32 :n_type   # Content type
// 188:     end
// 189:
// 190:     # Dynamic tag header.
// 191:     class ELF_Dyn < ELFStruct
// 192:       endian :big_and_little
// 193:       choice :d_tag, **CHOICE_SIZE_T['int']
// 194:       # This is an union type named +d_un+ in original source,
// 195:       # simplify it to be +d_val+ here.
// 196:       choice :d_val, **CHOICE_SIZE_T['uint']
// 197:     end
// 198:
// 199:     # Rel header in .rel section.
// 200:     class ELF_Rel < ELFStruct
// 201:       endian :big_and_little
// 202:       choice :r_offset, **CHOICE_SIZE_T['uint']
// 203:       choice :r_info, **CHOICE_SIZE_T['uint']
// 204:
// 205:       # Compatibility with ELF_Rela, both can be used interchangeably
// 206:       def r_addend
// 207:         nil
// 208:       end
// 209:     end
// 210:
// 211:     # Rela header in .rela section.
// 212:     class ELF_Rela < ELFStruct
// 213:       endian :big_and_little
// 214:       choice :r_offset, **CHOICE_SIZE_T['uint']
// 215:       choice :r_info, **CHOICE_SIZE_T['uint']
// 216:       choice :r_addend, **CHOICE_SIZE_T['int']
// 217:     end
// 218:   end
// 219: end
