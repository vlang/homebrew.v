module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/sections.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `section_name` at line 126.
pub fn ruby_sections_l126_d1_section_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('section_name', ...args)
}

// Ruby method `segment_name` at line 131.
pub fn ruby_sections_l131_d2_segment_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('segment_name', ...args)
}

// Ruby method `empty?` at line 136.
pub fn ruby_sections_l136_d3_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `type` at line 141.
pub fn ruby_sections_l141_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `type?(type_sym)` at line 149.
pub fn ruby_sections_l149_d5_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type?', ...args)
}

// Ruby method `attributes` at line 154.
pub fn ruby_sections_l154_d6_attributes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attributes', ...args)
}

// Ruby method `attribute?(attr_sym)` at line 162.
pub fn ruby_sections_l162_d7_attribute(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attribute?', ...args)
}

// Ruby method `flag?(flag)` at line 171.
pub fn ruby_sections_l171_d8_flag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('flag?', ...args)
}

// Ruby method `to_h` at line 180.
pub fn ruby_sections_l180_d9_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `to_h` at line 209.
pub fn ruby_sections_l209_d10_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # Classes and constants for parsing sections in Mach-O binaries.
// 5:   module Sections
// 6:     # type mask
// 7:     SECTION_TYPE_MASK = 0x000000ff
// 8:
// 9:     # attributes mask
// 10:     SECTION_ATTRIBUTES_MASK = 0xffffff00
// 11:
// 12:     # user settable attributes mask
// 13:     SECTION_ATTRIBUTES_USR_MASK = 0xff000000
// 14:
// 15:     # system settable attributes mask
// 16:     SECTION_ATTRIBUTES_SYS_MASK = 0x00ffff00
// 17:
// 18:     # maximum specifiable section alignment, as a power of 2
// 19:     # @note see `MAXSECTALIGN` macro in `cctools/misc/lipo.c`
// 20:     MAX_SECT_ALIGN = 15
// 21:
// 22:     # association of section type symbols to values
// 23:     # @api private
// 24:     SECTION_TYPES = {
// 25:       :S_REGULAR => 0x0,
// 26:       :S_ZEROFILL => 0x1,
// 27:       :S_CSTRING_LITERALS => 0x2,
// 28:       :S_4BYTE_LITERALS => 0x3,
// 29:       :S_8BYTE_LITERALS => 0x4,
// 30:       :S_LITERAL_POINTERS => 0x5,
// 31:       :S_NON_LAZY_SYMBOL_POINTERS => 0x6,
// 32:       :S_LAZY_SYMBOL_POINTERS => 0x7,
// 33:       :S_SYMBOL_STUBS => 0x8,
// 34:       :S_MOD_INIT_FUNC_POINTERS => 0x9,
// 35:       :S_MOD_TERM_FUNC_POINTERS => 0xa,
// 36:       :S_COALESCED => 0xb,
// 37:       :S_GB_ZEROFILE => 0xc,
// 38:       :S_INTERPOSING => 0xd,
// 39:       :S_16BYTE_LITERALS => 0xe,
// 40:       :S_DTRACE_DOF => 0xf,
// 41:       :S_LAZY_DYLIB_SYMBOL_POINTERS => 0x10,
// 42:       :S_THREAD_LOCAL_REGULAR => 0x11,
// 43:       :S_THREAD_LOCAL_ZEROFILL => 0x12,
// 44:       :S_THREAD_LOCAL_VARIABLES => 0x13,
// 45:       :S_THREAD_LOCAL_VARIABLE_POINTERS => 0x14,
// 46:       :S_THREAD_LOCAL_INIT_FUNCTION_POINTERS => 0x15,
// 47:       :S_INIT_FUNC_OFFSETS => 0x16,
// 48:     }.freeze
// 49:
// 50:     # association of section attribute symbols to values
// 51:     # @api private
// 52:     SECTION_ATTRIBUTES = {
// 53:       :S_ATTR_PURE_INSTRUCTIONS => 0x80000000,
// 54:       :S_ATTR_NO_TOC => 0x40000000,
// 55:       :S_ATTR_STRIP_STATIC_SYMS => 0x20000000,
// 56:       :S_ATTR_NO_DEAD_STRIP => 0x10000000,
// 57:       :S_ATTR_LIVE_SUPPORT => 0x08000000,
// 58:       :S_ATTR_SELF_MODIFYING_CODE => 0x04000000,
// 59:       :S_ATTR_DEBUG => 0x02000000,
// 60:       :S_ATTR_SOME_INSTRUCTIONS => 0x00000400,
// 61:       :S_ATTR_EXT_RELOC => 0x00000200,
// 62:       :S_ATTR_LOC_RELOC => 0x00000100,
// 63:     }.freeze
// 64:
// 65:     # association of section flag symbols to values
// 66:     # @api private
// 67:     SECTION_FLAGS = {
// 68:       **SECTION_TYPES,
// 69:       **SECTION_ATTRIBUTES,
// 70:     }.freeze
// 71:
// 72:     # association of section name symbols to names
// 73:     # @api private
// 74:     SECTION_NAMES = {
// 75:       :SECT_TEXT => "__text",
// 76:       :SECT_FVMLIB_INIT0 => "__fvmlib_init0",
// 77:       :SECT_FVMLIB_INIT1 => "__fvmlib_init1",
// 78:       :SECT_DATA => "__data",
// 79:       :SECT_BSS => "__bss",
// 80:       :SECT_COMMON => "__common",
// 81:       :SECT_OBJC_SYMBOLS => "__symbol_table",
// 82:       :SECT_OBJC_MODULES => "__module_info",
// 83:       :SECT_OBJC_STRINGS => "__selector_strs",
// 84:       :SECT_OBJC_REFS => "__selector_refs",
// 85:       :SECT_ICON_HEADER => "__header",
// 86:       :SECT_ICON_TIFF => "__tiff",
// 87:     }.freeze
// 88:
// 89:     # Represents a section of a segment for 32-bit architectures.
// 90:     class Section < MachOStructure
// 91:       # @return [String] the name of the section, including null pad bytes
// 92:       field :sectname, :string, :padding => :null, :size => 16
// 93:
// 94:       # @return [String] the name of the segment's section, including null
// 95:       #  pad bytes
// 96:       field :segname, :string, :padding => :null, :size => 16
// 97:
// 98:       # @return [Integer] the memory address of the section
// 99:       field :addr, :uint32
// 100:
// 101:       # @return [Integer] the size, in bytes, of the section
// 102:       field :size, :uint32
// 103:
// 104:       # @return [Integer] the file offset of the section
// 105:       field :offset, :uint32
// 106:
// 107:       # @return [Integer] the section alignment (power of 2) of the section
// 108:       field :align, :uint32
// 109:
// 110:       # @return [Integer] the file offset of the section's relocation entries
// 111:       field :reloff, :uint32
// 112:
// 113:       # @return [Integer] the number of relocation entries
// 114:       field :nreloc, :uint32
// 115:
// 116:       # @return [Integer] flags for type and attributes of the section
// 117:       field :flags, :uint32
// 118:
// 119:       # @return [void] reserved (for offset or index)
// 120:       field :reserved1, :uint32
// 121:
// 122:       # @return [void] reserved (for count or sizeof)
// 123:       field :reserved2, :uint32
// 124:
// 125:       # @return [String] the section's name
// 126:       def section_name
// 127:         sectname
// 128:       end
// 129:
// 130:       # @return [String] the parent segment's name
// 131:       def segment_name
// 132:         segname
// 133:       end
// 134:
// 135:       # @return [Boolean] whether the section is empty (i.e, {size} is 0)
// 136:       def empty?
// 137:         size.zero?
// 138:       end
// 139:
// 140:       # @return [Integer] the raw numeric type of this section
// 141:       def type
// 142:         flags & SECTION_TYPE_MASK
// 143:       end
// 144:
// 145:       # @example
// 146:       #  puts "this section is regular" if sect.type?(:S_REGULAR)
// 147:       # @param type_sym [Symbol] a section type symbol
// 148:       # @return [Boolean] whether this section is of the given type
// 149:       def type?(type_sym)
// 150:         type == SECTION_TYPES[type_sym]
// 151:       end
// 152:
// 153:       # @return [Integer] the raw numeric attributes of this section
// 154:       def attributes
// 155:         flags & SECTION_ATTRIBUTES_MASK
// 156:       end
// 157:
// 158:       # @example
// 159:       #  puts "pure instructions" if sect.attribute?(:S_ATTR_PURE_INSTRUCTIONS)
// 160:       # @param attr_sym [Symbol] a section attribute symbol
// 161:       # @return [Boolean] whether this section is of the given type
// 162:       def attribute?(attr_sym)
// 163:         !!(attributes & SECTION_ATTRIBUTES[attr_sym])
// 164:       end
// 165:
// 166:       # @deprecated Use {#type?} or {#attribute?} instead.
// 167:       # @example
// 168:       #  puts "this section is regular" if sect.flag?(:S_REGULAR)
// 169:       # @param flag [Symbol] a section flag symbol
// 170:       # @return [Boolean] whether the flag is present in the section's {flags}
// 171:       def flag?(flag)
// 172:         flag = SECTION_FLAGS[flag]
// 173:
// 174:         return false if flag.nil?
// 175:
// 176:         flags & flag == flag
// 177:       end
// 178:
// 179:       # @return [Hash] a hash representation of this {Section}
// 180:       def to_h
// 181:         {
// 182:           "sectname" => sectname,
// 183:           "segname" => segname,
// 184:           "addr" => addr,
// 185:           "size" => size,
// 186:           "offset" => offset,
// 187:           "align" => align,
// 188:           "reloff" => reloff,
// 189:           "nreloc" => nreloc,
// 190:           "flags" => flags,
// 191:           "reserved1" => reserved1,
// 192:           "reserved2" => reserved2,
// 193:         }.merge super
// 194:       end
// 195:     end
// 196:
// 197:     # Represents a section of a segment for 64-bit architectures.
// 198:     class Section64 < Section
// 199:       # @return [Integer] the memory address of the section
// 200:       field :addr, :uint64
// 201:
// 202:       # @return [Integer] the size, in bytes, of the section
// 203:       field :size, :uint64
// 204:
// 205:       # @return [void] reserved
// 206:       field :reserved3, :uint32
// 207:
// 208:       # @return [Hash] a hash representation of this {Section64}
// 209:       def to_h
// 210:         {
// 211:           "reserved3" => reserved3,
// 212:         }.merge super
// 213:       end
// 214:     end
// 215:   end
// 216: end
