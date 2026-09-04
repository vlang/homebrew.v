module elftools

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/constants.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn machine_name(value int) string {
	return match value {
		0 { 'None' }
		3, 6 { 'Intel 80386' }
		7 { 'Intel 80860' }
		8 { 'MIPS R3000' }
		20 { 'PowerPC' }
		21 { 'PowerPC64' }
		40 { 'ARM' }
		50 { 'Intel IA-64' }
		62 { 'Advanced Micro Devices X86-64' }
		183 { 'AArch64' }
		else { '<unknown>: 0x${value.hex()}' }
	}
}

pub fn elf_type_name(value int) string {
	return match value {
		0 { 'NONE' }
		1 { 'REL' }
		2 { 'EXEC' }
		3 { 'DYN' }
		4 { 'CORE' }
		else { '<unknown>' }
	}
}

// Ruby method `self.mapping(val)` at line 427.
pub fn ruby_constants_l427_d1_self_mapping(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ELFTools::Constants::EM.mapping requires a value')
	}
	return ruby.string_value(machine_name(int(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.mapping(type)` at line 454.
pub fn ruby_constants_l454_d2_self_mapping(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ELFTools::Constants::ET.mapping requires a value')
	}
	return ruby.string_value(elf_type_name(int(args[0].as_int() or { panic(err) })))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module ELFTools
// 4:   # Define constants from elf.h.
// 5:   # Mostly refer from https://github.com/torvalds/linux/blob/master/include/uapi/linux/elf.h
// 6:   # and binutils/elfcpp/elfcpp.h.
// 7:   module Constants
// 8:     # ELF magic header
// 9:     ELFMAG = "\x7FELF"
// 10:
// 11:     # Values of `d_un.d_val' in the DT_FLAGS and DT_FLAGS_1 entry.
// 12:     module DF
// 13:       DF_ORIGIN       = 0x00000001 # Object may use DF_ORIGIN
// 14:       DF_SYMBOLIC     = 0x00000002 # Symbol resolutions starts here
// 15:       DF_TEXTREL      = 0x00000004 # Object contains text relocations
// 16:       DF_BIND_NOW     = 0x00000008 # No lazy binding for this object
// 17:       DF_STATIC_TLS   = 0x00000010 # Module uses the static TLS model
// 18:
// 19:       DF_1_NOW        = 0x00000001 # Set RTLD_NOW for this object.
// 20:       DF_1_GLOBAL     = 0x00000002 # Set RTLD_GLOBAL for this object.
// 21:       DF_1_GROUP      = 0x00000004 # Set RTLD_GROUP for this object.
// 22:       DF_1_NODELETE   = 0x00000008 # Set RTLD_NODELETE for this object.
// 23:       DF_1_LOADFLTR   = 0x00000010 # Trigger filtee loading at runtime.
// 24:       DF_1_INITFIRST  = 0x00000020 # Set RTLD_INITFIRST for this object
// 25:       DF_1_NOOPEN     = 0x00000040 # Set RTLD_NOOPEN for this object.
// 26:       DF_1_ORIGIN     = 0x00000080 # $ORIGIN must be handled.
// 27:       DF_1_DIRECT     = 0x00000100 # Direct binding enabled.
// 28:       DF_1_TRANS      = 0x00000200 # :nodoc:
// 29:       DF_1_INTERPOSE  = 0x00000400 # Object is used to interpose.
// 30:       DF_1_NODEFLIB   = 0x00000800 # Ignore default lib search path.
// 31:       DF_1_NODUMP     = 0x00001000 # Object can't be dldump'ed.
// 32:       DF_1_CONFALT    = 0x00002000 # Configuration alternative created.
// 33:       DF_1_ENDFILTEE  = 0x00004000 # Filtee terminates filters search.
// 34:       DF_1_DISPRELDNE = 0x00008000 # Disp reloc applied at build time.
// 35:       DF_1_DISPRELPND = 0x00010000 # Disp reloc applied at run-time.
// 36:       DF_1_NODIRECT   = 0x00020000 # Object has no-direct binding.
// 37:       DF_1_IGNMULDEF  = 0x00040000 # :nodoc:
// 38:       DF_1_NOKSYMS    = 0x00080000 # :nodoc:
// 39:       DF_1_NOHDR      = 0x00100000 # :nodoc:
// 40:       DF_1_EDITED     = 0x00200000 # Object is modified after built.
// 41:       DF_1_NORELOC    = 0x00400000 # :nodoc:
// 42:       DF_1_SYMINTPOSE = 0x00800000 # Object has individual interposers.
// 43:       DF_1_GLOBAUDIT  = 0x01000000 # Global auditing required.
// 44:       DF_1_SINGLETON  = 0x02000000 # Singleton symbols are used.
// 45:       DF_1_STUB       = 0x04000000 # :nodoc:
// 46:       DF_1_PIE        = 0x08000000 # Object is a position-independent executable.
// 47:       DF_1_KMOD       = 0x10000000 # :nodoc:
// 48:       DF_1_WEAKFILTER = 0x20000000 # :nodoc:
// 49:       DF_1_NOCOMMON   = 0x40000000 # :nodoc:
// 50:     end
// 51:     include DF
// 52:
// 53:     # Dynamic table types, records in +d_tag+.
// 54:     module DT
// 55:       DT_NULL                       = 0 # marks the end of the _DYNAMIC array
// 56:       DT_NEEDED                     = 1 # libraries need to be linked by loader
// 57:       DT_PLTRELSZ                   = 2 # total size of relocation entries
// 58:       DT_PLTGOT                     = 3 # address of procedure linkage table or global offset table
// 59:       DT_HASH                       = 4 # address of symbol hash table
// 60:       DT_STRTAB                     = 5 # address of string table
// 61:       DT_SYMTAB                     = 6 # address of symbol table
// 62:       DT_RELA                       = 7 # address of a relocation table
// 63:       DT_RELASZ                     = 8 # total size of the {DT_RELA} table
// 64:       DT_RELAENT                    = 9 # size of each entry in the {DT_RELA} table
// 65:       DT_STRSZ                      = 10 # total size of {DT_STRTAB}
// 66:       DT_SYMENT                     = 11 # size of each entry in {DT_SYMTAB}
// 67:       DT_INIT                       = 12 # where the initialization function is
// 68:       DT_FINI                       = 13 # where the termination function is
// 69:       DT_SONAME                     = 14 # the shared object name
// 70:       DT_RPATH                      = 15 # has been superseded by {DT_RUNPATH}
// 71:       DT_SYMBOLIC                   = 16 # has been superseded by the DF_SYMBOLIC flag
// 72:       DT_REL                        = 17 # similar to {DT_RELA}
// 73:       DT_RELSZ                      = 18 # total size of the {DT_REL} table
// 74:       DT_RELENT                     = 19 # size of each entry in the {DT_REL} table
// 75:       DT_PLTREL                     = 20 # type of relocation entry, either {DT_REL} or {DT_RELA}
// 76:       DT_DEBUG                      = 21 # for debugging
// 77:       DT_TEXTREL                    = 22 # has been superseded by the DF_TEXTREL flag
// 78:       DT_JMPREL                     = 23 # address of relocation entries associated solely with procedure linkage table
// 79:       DT_BIND_NOW                   = 24 # if the loader needs to do relocate now, superseded by the DF_BIND_NOW flag
// 80:       DT_INIT_ARRAY                 = 25 # address init array
// 81:       DT_FINI_ARRAY                 = 26 # address of fini array
// 82:       DT_INIT_ARRAYSZ               = 27 # total size of init array
// 83:       DT_FINI_ARRAYSZ               = 28 # total size of fini array
// 84:       DT_RUNPATH                    = 29 # path of libraries for searching
// 85:       DT_FLAGS                      = 30 # flags
// 86:       DT_ENCODING                   = 32 # just a lower bound
// 87:       DT_PREINIT_ARRAY              = 32 # pre-initialization functions array
// 88:       DT_PREINIT_ARRAYSZ            = 33 # pre-initialization functions array size (bytes)
// 89:       DT_SYMTAB_SHNDX               = 34 # address of the +SHT_SYMTAB_SHNDX+ section associated with {DT_SYMTAB} table
// 90:       DT_RELRSZ                     = 35 # :nodoc:
// 91:       DT_RELR                       = 36 # :nodoc:
// 92:       DT_RELRENT                    = 37 # :nodoc:
// 93:
// 94:       # Values between {DT_LOOS} and {DT_HIOS} are reserved for operating system-specific semantics.
// 95:       DT_LOOS                       = 0x6000000d
// 96:       DT_HIOS                       = 0x6ffff000 # see {DT_LOOS}
// 97:
// 98:       # Values between {DT_VALRNGLO} and {DT_VALRNGHI} use the +d_un.d_val+ field of the dynamic structure.
// 99:       DT_VALRNGLO                   = 0x6ffffd00
// 100:       DT_VALRNGHI                   = 0x6ffffdff # see {DT_VALRNGLO}
// 101:
// 102:       # Values between {DT_ADDRRNGLO} and {DT_ADDRRNGHI} use the +d_un.d_ptr+ field of the dynamic structure.
// 103:       DT_ADDRRNGLO                  = 0x6ffffe00
// 104:       DT_GNU_HASH                   = 0x6ffffef5 # the gnu hash
// 105:       DT_TLSDESC_PLT                = 0x6ffffef6 # :nodoc:
// 106:       DT_TLSDESC_GOT                = 0x6ffffef7 # :nodoc:
// 107:       DT_GNU_CONFLICT               = 0x6ffffef8 # :nodoc:
// 108:       DT_GNU_LIBLIST                = 0x6ffffef9 # :nodoc:
// 109:       DT_CONFIG                     = 0x6ffffefa # :nodoc:
// 110:       DT_DEPAUDIT                   = 0x6ffffefb # :nodoc:
// 111:       DT_AUDIT                      = 0x6ffffefc # :nodoc:
// 112:       DT_PLTPAD                     = 0x6ffffefd # :nodoc:
// 113:       DT_MOVETAB                    = 0x6ffffefe # :nodoc:
// 114:       DT_SYMINFO                    = 0x6ffffeff # :nodoc:
// 115:       DT_ADDRRNGHI                  = 0x6ffffeff # see {DT_ADDRRNGLO}
// 116:
// 117:       DT_VERSYM                     = 0x6ffffff0 # section address of .gnu.version
// 118:       DT_RELACOUNT                  = 0x6ffffff9 # relative relocation count
// 119:       DT_RELCOUNT                   = 0x6ffffffa # relative relocation count
// 120:       DT_FLAGS_1                    = 0x6ffffffb # flags
// 121:       DT_VERDEF                     = 0x6ffffffc # address of version definition table
// 122:       DT_VERDEFNUM                  = 0x6ffffffd # number of entries in {DT_VERDEF}
// 123:       DT_VERNEED                    = 0x6ffffffe # address of version dependency table
// 124:       DT_VERNEEDNUM                 = 0x6fffffff # number of entries in {DT_VERNEED}
// 125:
// 126:       # Values between {DT_LOPROC} and {DT_HIPROC} are reserved for processor-specific semantics.
// 127:       DT_LOPROC                     = 0x70000000
// 128:
// 129:       DT_PPC_GOT                    = 0x70000000 # global offset table
// 130:       DT_PPC_OPT                    = 0x70000001 # whether various optimisations are possible
// 131:
// 132:       DT_PPC64_GLINK                = 0x70000000 # start of the .glink section
// 133:       DT_PPC64_OPD                  = 0x70000001 # start of the .opd section
// 134:       DT_PPC64_OPDSZ                = 0x70000002 # size of the .opd section
// 135:       DT_PPC64_OPT                  = 0x70000003 # whether various optimisations are possible
// 136:
// 137:       DT_SPARC_REGISTER             = 0x70000000 # index of an +STT_SPARC_REGISTER+ symbol within the {DT_SYMTAB} table
// 138:
// 139:       DT_MIPS_RLD_VERSION           = 0x70000001 # 32 bit version number for runtime linker interface
// 140:       DT_MIPS_TIME_STAMP            = 0x70000002 # time stamp
// 141:       DT_MIPS_ICHECKSUM             = 0x70000003 # checksum of external strings and common sizes
// 142:       DT_MIPS_IVERSION              = 0x70000004 # index of version string in string table
// 143:       DT_MIPS_FLAGS                 = 0x70000005 # 32 bits of flags
// 144:       DT_MIPS_BASE_ADDRESS          = 0x70000006 # base address of the segment
// 145:       DT_MIPS_MSYM                  = 0x70000007 # :nodoc:
// 146:       DT_MIPS_CONFLICT              = 0x70000008 # address of +.conflict+ section
// 147:       DT_MIPS_LIBLIST               = 0x70000009 # address of +.liblist+ section
// 148:       DT_MIPS_LOCAL_GOTNO           = 0x7000000a # number of local global offset table entries
// 149:       DT_MIPS_CONFLICTNO            = 0x7000000b # number of entries in the +.conflict+ section
// 150:       DT_MIPS_LIBLISTNO             = 0x70000010 # number of entries in the +.liblist+ section
// 151:       DT_MIPS_SYMTABNO              = 0x70000011 # number of entries in the +.dynsym+ section
// 152:       DT_MIPS_UNREFEXTNO            = 0x70000012 # index of first external dynamic symbol not referenced locally
// 153:       DT_MIPS_GOTSYM                = 0x70000013 # index of first dynamic symbol in global offset table
// 154:       DT_MIPS_HIPAGENO              = 0x70000014 # number of page table entries in global offset table
// 155:       DT_MIPS_RLD_MAP               = 0x70000016 # address of run time loader map, used for debugging
// 156:       DT_MIPS_DELTA_CLASS           = 0x70000017 # delta C++ class definition
// 157:       DT_MIPS_DELTA_CLASS_NO        = 0x70000018 # number of entries in {DT_MIPS_DELTA_CLASS}
// 158:       DT_MIPS_DELTA_INSTANCE        = 0x70000019 # delta C++ class instances
// 159:       DT_MIPS_DELTA_INSTANCE_NO     = 0x7000001a # number of entries in {DT_MIPS_DELTA_INSTANCE}
// 160:       DT_MIPS_DELTA_RELOC           = 0x7000001b # delta relocations
// 161:       DT_MIPS_DELTA_RELOC_NO        = 0x7000001c # number of entries in {DT_MIPS_DELTA_RELOC}
// 162:       DT_MIPS_DELTA_SYM             = 0x7000001d # delta symbols that Delta relocations refer to
// 163:       DT_MIPS_DELTA_SYM_NO          = 0x7000001e # number of entries in {DT_MIPS_DELTA_SYM}
// 164:       DT_MIPS_DELTA_CLASSSYM        = 0x70000020 # delta symbols that hold class declarations
// 165:       DT_MIPS_DELTA_CLASSSYM_NO     = 0x70000021 # number of entries in {DT_MIPS_DELTA_CLASSSYM}
// 166:       DT_MIPS_CXX_FLAGS             = 0x70000022 # flags indicating information about C++ flavor
// 167:       DT_MIPS_PIXIE_INIT            = 0x70000023 # :nodoc:
// 168:       DT_MIPS_SYMBOL_LIB            = 0x70000024 # address of +.MIPS.symlib+
// 169:       DT_MIPS_LOCALPAGE_GOTIDX      = 0x70000025 # GOT index of the first PTE for a segment
// 170:       DT_MIPS_LOCAL_GOTIDX          = 0x70000026 # GOT index of the first PTE for a local symbol
// 171:       DT_MIPS_HIDDEN_GOTIDX         = 0x70000027 # GOT index of the first PTE for a hidden symbol
// 172:       DT_MIPS_PROTECTED_GOTIDX      = 0x70000028 # GOT index of the first PTE for a protected symbol
// 173:       DT_MIPS_OPTIONS               = 0x70000029 # address of +.MIPS.options+
// 174:       DT_MIPS_INTERFACE             = 0x7000002a # address of +.interface+
// 175:       DT_MIPS_DYNSTR_ALIGN          = 0x7000002b # :nodoc:
// 176:       DT_MIPS_INTERFACE_SIZE        = 0x7000002c # size of the +.interface+ section
// 177:       DT_MIPS_RLD_TEXT_RESOLVE_ADDR = 0x7000002d # size of +rld_text_resolve+ function stored in the GOT
// 178:       DT_MIPS_PERF_SUFFIX           = 0x7000002e # default suffix of DSO to be added by rld on +dlopen()+ calls
// 179:       DT_MIPS_COMPACT_SIZE          = 0x7000002f # size of compact relocation section (O32)
// 180:       DT_MIPS_GP_VALUE              = 0x70000030 # GP value for auxiliary GOTs
// 181:       DT_MIPS_AUX_DYNAMIC           = 0x70000031 # address of auxiliary +.dynamic+
// 182:       DT_MIPS_PLTGOT                = 0x70000032 # address of the base of the PLTGOT
// 183:       DT_MIPS_RWPLT                 = 0x70000034 # base of a writable PLT
// 184:       DT_MIPS_RLD_MAP_REL           = 0x70000035 # relative offset of run time loader map
// 185:       DT_MIPS_XHASH                 = 0x70000036 # GNU-style hash table with xlat
// 186:
// 187:       DT_AUXILIARY                  = 0x7ffffffd # :nodoc:
// 188:       DT_USED                       = 0x7ffffffe # :nodoc:
// 189:       DT_FILTER                     = 0x7ffffffe # :nodoc:
// 190:
// 191:       DT_HIPROC                     = 0x7fffffff # see {DT_LOPROC}
// 192:     end
// 193:     include DT
// 194:
// 195:     # These constants define the various ELF target machines.
// 196:     module EM
// 197:       EM_NONE            = 0      # none
// 198:       EM_M32             = 1      # AT&T WE 32100
// 199:       EM_SPARC           = 2      # SPARC
// 200:       EM_386             = 3      # Intel 80386
// 201:       EM_68K             = 4      # Motorola 68000
// 202:       EM_88K             = 5      # Motorola 88000
// 203:       EM_486             = 6      # Intel 80486
// 204:       EM_860             = 7      # Intel 80860
// 205:       EM_MIPS            = 8      # MIPS R3000 (officially, big-endian only)
// 206:       EM_S370            = 9      # IBM System/370
// 207:
// 208:       # Next two are historical and binaries and
// 209:       # modules of these types will be rejected by Linux.
// 210:       EM_MIPS_RS3_LE     = 10     # MIPS R3000 little-endian
// 211:       EM_MIPS_RS4_BE     = 10     # MIPS R4000 big-endian
// 212:
// 213:       EM_PARISC          = 15     # HPPA
// 214:       EM_VPP500          = 17     # Fujitsu VPP500 (also some older versions of PowerPC)
// 215:       EM_SPARC32PLUS     = 18     # Sun's "v8plus"
// 216:       EM_960             = 19     # Intel 80960
// 217:       EM_PPC             = 20     # PowerPC
// 218:       EM_PPC64           = 21     # PowerPC64
// 219:       EM_S390            = 22     # IBM S/390
// 220:       EM_SPU             = 23     # Cell BE SPU
// 221:       EM_V800            = 36     # NEC V800 series
// 222:       EM_FR20            = 37     # Fujitsu FR20
// 223:       EM_RH32            = 38     # TRW RH32
// 224:       EM_RCE             = 39     # Motorola M*Core
// 225:       EM_ARM             = 40     # ARM 32 bit
// 226:       EM_SH              = 42     # SuperH
// 227:       EM_SPARCV9         = 43     # SPARC v9 64-bit
// 228:       EM_TRICORE         = 44     # Siemens Tricore embedded processor
// 229:       EM_ARC             = 45     # ARC Cores
// 230:       EM_H8_300          = 46     # Renesas H8/300
// 231:       EM_H8_300H         = 47     # Renesas H8/300H
// 232:       EM_H8S             = 48     # Renesas H8S
// 233:       EM_H8_500          = 49     # Renesas H8/500H
// 234:       EM_IA_64           = 50     # HP/Intel IA-64
// 235:       EM_MIPS_X          = 51     # Stanford MIPS-X
// 236:       EM_COLDFIRE        = 52     # Motorola Coldfire
// 237:       EM_68HC12          = 53     # Motorola M68HC12
// 238:       EM_MMA             = 54     # Fujitsu Multimedia Accelerator
// 239:       EM_PCP             = 55     # Siemens PCP
// 240:       EM_NCPU            = 56     # Sony nCPU embedded RISC processor
// 241:       EM_NDR1            = 57     # Denso NDR1 microprocessor
// 242:       EM_STARCORE        = 58     # Motorola Star*Core processor
// 243:       EM_ME16            = 59     # Toyota ME16 processor
// 244:       EM_ST100           = 60     # STMicroelectronics ST100 processor
// 245:       EM_TINYJ           = 61     # Advanced Logic Corp. TinyJ embedded processor
// 246:       EM_X86_64          = 62     # AMD x86-64
// 247:       EM_PDSP            = 63     # Sony DSP Processor
// 248:       EM_PDP10           = 64     # Digital Equipment Corp. PDP-10
// 249:       EM_PDP11           = 65     # Digital Equipment Corp. PDP-11
// 250:       EM_FX66            = 66     # Siemens FX66 microcontroller
// 251:       EM_ST9PLUS         = 67     # STMicroelectronics ST9+ 8/16 bit microcontroller
// 252:       EM_ST7             = 68     # STMicroelectronics ST7 8-bit microcontroller
// 253:       EM_68HC16          = 69     # Motorola MC68HC16 Microcontroller
// 254:       EM_68HC11          = 70     # Motorola MC68HC11 Microcontroller
// 255:       EM_68HC08          = 71     # Motorola MC68HC08 Microcontroller
// 256:       EM_68HC05          = 72     # Motorola MC68HC05 Microcontroller
// 257:       EM_SVX             = 73     # Silicon Graphics SVx
// 258:       EM_ST19            = 74     # STMicroelectronics ST19 8-bit cpu
// 259:       EM_VAX             = 75     # Digital VAX
// 260:       EM_CRIS            = 76     # Axis Communications 32-bit embedded processor
// 261:       EM_JAVELIN         = 77     # Infineon Technologies 32-bit embedded cpu
// 262:       EM_FIREPATH        = 78     # Element 14 64-bit DSP processor
// 263:       EM_ZSP             = 79     # LSI Logic's 16-bit DSP processor
// 264:       EM_MMIX            = 80     # Donald Knuth's educational 64-bit processor
// 265:       EM_HUANY           = 81     # Harvard's machine-independent format
// 266:       EM_PRISM           = 82     # SiTera Prism
// 267:       EM_AVR             = 83     # Atmel AVR 8-bit microcontroller
// 268:       EM_FR30            = 84     # Fujitsu FR30
// 269:       EM_D10V            = 85     # Mitsubishi D10V
// 270:       EM_D30V            = 86     # Mitsubishi D30V
// 271:       EM_V850            = 87     # Renesas V850
// 272:       EM_M32R            = 88     # Renesas M32R
// 273:       EM_MN10300         = 89     # Matsushita MN10300
// 274:       EM_MN10200         = 90     # Matsushita MN10200
// 275:       EM_PJ              = 91     # picoJava
// 276:       EM_OPENRISC        = 92     # OpenRISC 32-bit embedded processor
// 277:       EM_ARC_COMPACT     = 93     # ARC International ARCompact processor
// 278:       EM_XTENSA          = 94     # Tensilica Xtensa Architecture
// 279:       EM_VIDEOCORE       = 95     # Alphamosaic VideoCore processor
// 280:       EM_TMM_GPP         = 96     # Thompson Multimedia General Purpose Processor
// 281:       EM_NS32K           = 97     # National Semiconductor 32000 series
// 282:       EM_TPC             = 98     # Tenor Network TPC processor
// 283:       EM_SNP1K           = 99     # Trebia SNP 1000 processor
// 284:       EM_ST200           = 100    # STMicroelectronics ST200 microcontroller
// 285:       EM_IP2K            = 101    # Ubicom IP2022 micro controller
// 286:       EM_MAX             = 102    # MAX Processor
// 287:       EM_CR              = 103    # National Semiconductor CompactRISC
// 288:       EM_F2MC16          = 104    # Fujitsu F2MC16
// 289:       EM_MSP430          = 105    # TI msp430 micro controller
// 290:       EM_BLACKFIN        = 106    # ADI Blackfin Processor
// 291:       EM_SE_C33          = 107    # S1C33 Family of Seiko Epson processors
// 292:       EM_SEP             = 108    # Sharp embedded microprocessor
// 293:       EM_ARCA            = 109    # Arca RISC Microprocessor
// 294:       EM_UNICORE         = 110    # Microprocessor series from PKU-Unity Ltd. and MPRC of Peking University
// 295:       EM_EXCESS          = 111    # eXcess: 16/32/64-bit configurable embedded CPU
// 296:       EM_DXP             = 112    # Icera Semiconductor Inc. Deep Execution Processor
// 297:       EM_ALTERA_NIOS2    = 113    # Altera Nios II soft-core processor
// 298:       EM_CRX             = 114    # National Semiconductor CRX
// 299:       EM_XGATE           = 115    # Motorola XGATE embedded processor
// 300:       EM_C116            = 116    # Infineon C16x/XC16x processor
// 301:       EM_M16C            = 117    # Renesas M16C series microprocessors
// 302:       EM_DSPIC30F        = 118    # Microchip Technology dsPIC30F Digital Signal Controller
// 303:       EM_CE              = 119    # Freescale Communication Engine RISC core
// 304:       EM_M32C            = 120    # Freescale Communication Engine RISC core
// 305:       EM_TSK3000         = 131    # Altium TSK3000 core
// 306:       EM_RS08            = 132    # Freescale RS08 embedded processor
// 307:       EM_SHARC           = 133    # Analog Devices SHARC family of 32-bit DSP processors
// 308:       EM_ECOG2           = 134    # Cyan Technology eCOG2 microprocessor
// 309:       EM_SCORE7          = 135    # Sunplus S+core7 RISC processor
// 310:       EM_DSP24           = 136    # New Japan Radio (NJR) 24-bit DSP Processor
// 311:       EM_VIDEOCORE3      = 137    # Broadcom VideoCore III processor
// 312:       EM_LATTICEMICO32   = 138    # RISC processor for Lattice FPGA architecture
// 313:       EM_SE_C17          = 139    # Seiko Epson C17 family
// 314:       EM_TI_C6000        = 140    # The Texas Instruments TMS320C6000 DSP family
// 315:       EM_TI_C2000        = 141    # The Texas Instruments TMS320C2000 DSP family
// 316:       EM_TI_C5500        = 142    # The Texas Instruments TMS320C55x DSP family
// 317:       EM_TI_ARP32        = 143    # Texas Instruments Application Specific RISC Processor, 32bit fetch
// 318:       EM_TI_PRU          = 144    # Texas Instruments Programmable Realtime Unit
// 319:       EM_MMDSP_PLUS      = 160    # STMicroelectronics 64bit VLIW Data Signal Processor
// 320:       EM_CYPRESS_M8C     = 161    # Cypress M8C microprocessor
// 321:       EM_R32C            = 162    # Renesas R32C series microprocessors
// 322:       EM_TRIMEDIA        = 163    # NXP Semiconductors TriMedia architecture family
// 323:       EM_QDSP6           = 164    # QUALCOMM DSP6 Processor
// 324:       EM_8051            = 165    # Intel 8051 and variants
// 325:       EM_STXP7X          = 166    # STMicroelectronics STxP7x family
// 326:       EM_NDS32           = 167    # Andes Technology compact code size embedded RISC processor family
// 327:       EM_ECOG1           = 168    # Cyan Technology eCOG1X family
// 328:       EM_ECOG1X          = 168    # Cyan Technology eCOG1X family
// 329:       EM_MAXQ30          = 169    # Dallas Semiconductor MAXQ30 Core Micro-controllers
// 330:       EM_XIMO16          = 170    # New Japan Radio (NJR) 16-bit DSP Processor
// 331:       EM_MANIK           = 171    # M2000 Reconfigurable RISC Microprocessor
// 332:       EM_CRAYNV2         = 172    # Cray Inc. NV2 vector architecture
// 333:       EM_RX              = 173    # Renesas RX family
// 334:       EM_METAG           = 174    # Imagination Technologies Meta processor architecture
// 335:       EM_MCST_ELBRUS     = 175    # MCST Elbrus general purpose hardware architecture
// 336:       EM_ECOG16          = 176    # Cyan Technology eCOG16 family
// 337:       EM_CR16            = 177    # National Semiconductor CompactRISC 16-bit processor
// 338:       EM_ETPU            = 178    # Freescale Extended Time Processing Unit
// 339:       EM_SLE9X           = 179    # Infineon Technologies SLE9X core
// 340:       EM_L1OM            = 180    # Intel L1OM
// 341:       EM_K1OM            = 181    # Intel K1OM
// 342:       EM_AARCH64         = 183    # ARM 64 bit
// 343:       EM_AVR32           = 185    # Atmel Corporation 32-bit microprocessor family
// 344:       EM_STM8            = 186    # STMicroeletronics STM8 8-bit microcontroller
// 345:       EM_TILE64          = 187    # Tilera TILE64 multicore architecture family
// 346:       EM_TILEPRO         = 188    # Tilera TILEPro
// 347:       EM_MICROBLAZE      = 189    # Xilinx MicroBlaze
// 348:       EM_CUDA            = 190    # NVIDIA CUDA architecture
// 349:       EM_TILEGX          = 191    # Tilera TILE-Gx
// 350:       EM_CLOUDSHIELD     = 192    # CloudShield architecture family
// 351:       EM_COREA_1ST       = 193    # KIPO-KAIST Core-A 1st generation processor family
// 352:       EM_COREA_2ND       = 194    # KIPO-KAIST Core-A 2nd generation processor family
// 353:       EM_ARC_COMPACT2    = 195    # Synopsys ARCompact V2
// 354:       EM_OPEN8           = 196    # Open8 8-bit RISC soft processor core
// 355:       EM_RL78            = 197    # Renesas RL78 family
// 356:       EM_VIDEOCORE5      = 198    # Broadcom VideoCore V processor
// 357:       EM_78K0R           = 199    # Renesas 78K0R
// 358:       EM_56800EX         = 200    # Freescale 56800EX Digital Signal Controller (DSC)
// 359:       EM_BA1             = 201    # Beyond BA1 CPU architecture
// 360:       EM_BA2             = 202    # Beyond BA2 CPU architecture
// 361:       EM_XCORE           = 203    # XMOS xCORE processor family
// 362:       EM_MCHP_PIC        = 204    # Microchip 8-bit PIC(r) family
// 363:       EM_INTELGT         = 205    # Intel Graphics Technology
// 364:       EM_KM32            = 210    # KM211 KM32 32-bit processor
// 365:       EM_KMX32           = 211    # KM211 KMX32 32-bit processor
// 366:       EM_KMX16           = 212    # KM211 KMX16 16-bit processor
// 367:       EM_KMX8            = 213    # KM211 KMX8 8-bit processor
// 368:       EM_KVARC           = 214    # KM211 KVARC processor
// 369:       EM_CDP             = 215    # Paneve CDP architecture family
// 370:       EM_COGE            = 216    # Cognitive Smart Memory Processor
// 371:       EM_COOL            = 217    # Bluechip Systems CoolEngine
// 372:       EM_NORC            = 218    # Nanoradio Optimized RISC
// 373:       EM_CSR_KALIMBA     = 219    # CSR Kalimba architecture family
// 374:       EM_Z80             = 220    # Zilog Z80
// 375:       EM_VISIUM          = 221    # Controls and Data Services VISIUMcore processor
// 376:       EM_FT32            = 222    # FTDI Chip FT32 high performance 32-bit RISC architecture
// 377:       EM_MOXIE           = 223    # Moxie processor family
// 378:       EM_AMDGPU          = 224    # AMD GPU architecture
// 379:       EM_LANAI           = 244    # Lanai 32-bit processor
// 380:       EM_CEVA            = 245    # CEVA Processor Architecture Family
// 381:       EM_CEVA_X2         = 246    # CEVA X2 Processor Family
// 382:       EM_BPF             = 247    # Linux BPF - in-kernel virtual machine
// 383:       EM_GRAPHCORE_IPU   = 248    # Graphcore Intelligent Processing Unit
// 384:       EM_IMG1            = 249    # Imagination Technologies
// 385:       EM_NFP             = 250    # Netronome Flow Processor (NFP)
// 386:       EM_VE              = 251    # NEC Vector Engine
// 387:       EM_CSKY            = 252    # C-SKY processor family
// 388:       EM_ARC_COMPACT3_64 = 253    # Synopsys ARCv2.3 64-bit
// 389:       EM_MCS6502         = 254    # MOS Technology MCS 6502 processor
// 390:       EM_ARC_COMPACT3    = 255    # Synopsys ARCv2.3 32-bit
// 391:       EM_KVX             = 256    # Kalray VLIW core of the MPPA processor family
// 392:       EM_65816           = 257    # WDC 65816/65C816
// 393:       EM_LOONGARCH       = 258    # LoongArch
// 394:       EM_KF32            = 259    # ChipON KungFu32
// 395:       EM_U16_U8CORE      = 260    # LAPIS nX-U16/U8
// 396:       EM_TACHYUM         = 261    # Tachyum
// 397:       EM_56800EF         = 262    # NXP 56800EF Digital Signal Controller (DSC)
// 398:
// 399:       EM_FRV             = 0x5441 # Fujitsu FR-V
// 400:
// 401:       # This is an interim value that we will use until the committee comes up with a final number.
// 402:       EM_ALPHA           = 0x9026
// 403:
// 404:       # Bogus old m32r magic number, used by old tools.
// 405:       EM_CYGNUS_M32R     = 0x9041
// 406:       # This is the old interim value for S/390 architecture
// 407:       EM_S390_OLD        = 0xA390
// 408:       # Also Panasonic/MEI MN10300, AM33
// 409:       EM_CYGNUS_MN10300  = 0xbeef
// 410:
// 411:       # Return the architecture name according to +val+.
// 412:       # Used by {ELFTools::ELFFile#machine}.
// 413:       #
// 414:       # Only supports famous archs.
// 415:       # @param [Integer] val Value of +e_machine+.
// 416:       # @return [String]
// 417:       #   Name of architecture.
// 418:       # @example
// 419:       #   mapping(3)
// 420:       #   #=> 'Intel 80386'
// 421:       #   mapping(6)
// 422:       #   #=> 'Intel 80386'
// 423:       #   mapping(62)
// 424:       #   #=> 'Advanced Micro Devices X86-64'
// 425:       #   mapping(1337)
// 426:       #   #=> '<unknown>: 0x539'
// 427:       def self.mapping(val)
// 428:         case val
// 429:         when EM_NONE then 'None'
// 430:         when EM_386, EM_486 then 'Intel 80386'
// 431:         when EM_860 then 'Intel 80860'
// 432:         when EM_MIPS then 'MIPS R3000'
// 433:         when EM_PPC then 'PowerPC'
// 434:         when EM_PPC64 then 'PowerPC64'
// 435:         when EM_ARM then 'ARM'
// 436:         when EM_IA_64 then 'Intel IA-64'
// 437:         when EM_AARCH64 then 'AArch64'
// 438:         when EM_X86_64 then 'Advanced Micro Devices X86-64'
// 439:         else format('<unknown>: 0x%x', val)
// 440:         end
// 441:       end
// 442:     end
// 443:     include EM
// 444:
// 445:     # This module defines ELF file types.
// 446:     module ET
// 447:       ET_NONE = 0 # no file type
// 448:       ET_REL  = 1 # relocatable file
// 449:       ET_EXEC = 2 # executable file
// 450:       ET_DYN  = 3 # shared object
// 451:       ET_CORE = 4 # core file
// 452:       # Return the type name according to +e_type+ in ELF file header.
// 453:       # @return [String] Type in string format.
// 454:       def self.mapping(type)
// 455:         case type
// 456:         when Constants::ET_NONE then 'NONE'
// 457:         when Constants::ET_REL then 'REL'
// 458:         when Constants::ET_EXEC then 'EXEC'
// 459:         when Constants::ET_DYN then 'DYN'
// 460:         when Constants::ET_CORE then 'CORE'
// 461:         else '<unknown>'
// 462:         end
// 463:       end
// 464:     end
// 465:     include ET
// 466:
// 467:     # Program header permission flags, records bitwise OR value in +p_flags+.
// 468:     module PF
// 469:       PF_X = 1 # executable
// 470:       PF_W = 2 # writable
// 471:       PF_R = 4 # readable
// 472:     end
// 473:     include PF
// 474:
// 475:     # Program header types, records in +p_type+.
// 476:     module PT
// 477:       PT_NULL              = 0          # null segment
// 478:       PT_LOAD              = 1          # segment to be load
// 479:       PT_DYNAMIC           = 2          # dynamic tags
// 480:       PT_INTERP            = 3          # interpreter, same as .interp section
// 481:       PT_NOTE              = 4          # same as .note* section
// 482:       PT_SHLIB             = 5          # reserved
// 483:       PT_PHDR              = 6          # where program header starts
// 484:       PT_TLS               = 7          # thread local storage segment
// 485:
// 486:       PT_LOOS              = 0x60000000 # OS-specific
// 487:       PT_GNU_EH_FRAME      = 0x6474e550 # for exception handler
// 488:       PT_GNU_STACK         = 0x6474e551 # permission of stack
// 489:       PT_GNU_RELRO         = 0x6474e552 # read only after relocation
// 490:       PT_GNU_PROPERTY      = 0x6474e553 # GNU property
// 491:       PT_GNU_MBIND_HI      = 0x6474f554 # Mbind segments (upper bound)
// 492:       PT_GNU_MBIND_LO      = 0x6474e555 # Mbind segments (lower bound)
// 493:       PT_OPENBSD_RANDOMIZE = 0x65a3dbe6 # Fill with random data
// 494:       PT_OPENBSD_WXNEEDED  = 0x65a3dbe7 # Program does W^X violations
// 495:       PT_OPENBSD_BOOTDATA  = 0x65a41be6 # Section for boot arguments
// 496:       PT_HIOS              = 0x6fffffff # OS-specific
// 497:
// 498:       # Values between {PT_LOPROC} and {PT_HIPROC} are reserved for processor-specific semantics.
// 499:       PT_LOPROC            = 0x70000000
// 500:
// 501:       PT_ARM_ARCHEXT       = 0x70000000 # platform architecture compatibility information
// 502:       PT_ARM_EXIDX         = 0x70000001 # exception unwind tables
// 503:
// 504:       PT_MIPS_REGINFO      = 0x70000000 # register usage information
// 505:       PT_MIPS_RTPROC       = 0x70000001 # runtime procedure table
// 506:       PT_MIPS_OPTIONS      = 0x70000002 # +.MIPS.options+ section
// 507:       PT_MIPS_ABIFLAGS     = 0x70000003 # +.MIPS.abiflags+ section
// 508:
// 509:       PT_AARCH64_ARCHEXT   = 0x70000000 # platform architecture compatibility information
// 510:       PT_AARCH64_UNWIND    = 0x70000001 # exception unwind tables
// 511:
// 512:       PT_S390_PGSTE        = 0x70000000 # 4k page table size
// 513:
// 514:       PT_HIPROC            = 0x7fffffff # see {PT_LOPROC}
// 515:     end
// 516:     include PT
// 517:
// 518:     # Special indices to section. These are used when there is no valid index to section header.
// 519:     # The meaning of these values is left upto the embedding header.
// 520:     module SHN
// 521:       SHN_UNDEF           = 0      # undefined section
// 522:       SHN_LORESERVE       = 0xff00 # start of reserved indices
// 523:
// 524:       # Values between {SHN_LOPROC} and {SHN_HIPROC} are reserved for processor-specific semantics.
// 525:       SHN_LOPROC          = 0xff00
// 526:
// 527:       SHN_MIPS_ACOMMON    = 0xff00 # defined and allocated common symbol
// 528:       SHN_MIPS_TEXT       = 0xff01 # defined and allocated text symbol
// 529:       SHN_MIPS_DATA       = 0xff02 # defined and allocated data symbol
// 530:       SHN_MIPS_SCOMMON    = 0xff03 # small common symbol
// 531:       SHN_MIPS_SUNDEFINED = 0xff04 # small undefined symbol
// 532:
// 533:       SHN_X86_64_LCOMMON  = 0xff02 # large common symbol
// 534:
// 535:       SHN_HIPROC          = 0xff1f # see {SHN_LOPROC}
// 536:
// 537:       # Values between {SHN_LOOS} and {SHN_HIOS} are reserved for operating system-specific semantics.
// 538:       SHN_LOOS            = 0xff20
// 539:       SHN_HIOS            = 0xff3f # see {SHN_LOOS}
// 540:       SHN_ABS             = 0xfff1 # specifies absolute values for the corresponding reference
// 541:       SHN_COMMON          = 0xfff2 # symbols defined relative to this section are common symbols
// 542:       SHN_XINDEX          = 0xffff # escape value indicating that the actual section header index is too large to fit
// 543:       SHN_HIRESERVE       = 0xffff # end of reserved indices
// 544:     end
// 545:     include SHN
// 546:
// 547:     # Section flag mask types, records in +sh_flag+.
// 548:     module SHF
// 549:       SHF_WRITE = (1 << 0) # Writable
// 550:       SHF_ALLOC = (1 << 1) # Occupies memory during execution
// 551:       SHF_EXECINSTR = (1 << 2) # Executable
// 552:       SHF_MERGE = (1 << 4) # Might be merged
// 553:       SHF_STRINGS = (1 << 5) # Contains nul-terminated strings
// 554:       SHF_INFO_LINK = (1 << 6) # `sh_info' contains SHT index
// 555:       SHF_LINK_ORDER = (1 << 7) # Preserve order after combining
// 556:       SHF_OS_NONCONFORMING = (1 << 8) # Non-standard OS specific handling required
// 557:       SHF_GROUP = (1 << 9) # Section is member of a group.
// 558:       SHF_TLS = (1 << 10) # Section hold thread-local data.
// 559:       SHF_COMPRESSED = (1 << 11) # Section with compressed data.
// 560:       SHF_MASKOS = 0x0ff00000 # OS-specific.
// 561:       SHF_MASKPROC = 0xf0000000 # Processor-specific
// 562:       SHF_GNU_RETAIN = (1 << 21) # Not to be GCed by linker.
// 563:       SHF_GNU_MBIND = (1 << 24) # Mbind section
// 564:       SHF_ORDERED = (1 << 30) # Special ordering requirement
// 565:       SHF_EXCLUDE = (1 << 31) # Section is excluded unless referenced or allocated (Solaris).
// 566:     end
// 567:     include SHF
// 568:
// 569:     # Section header types, records in +sh_type+.
// 570:     module SHT
// 571:       SHT_NULL                    = 0 # null section
// 572:       SHT_PROGBITS                = 1 # information defined by program itself
// 573:       SHT_SYMTAB                  = 2 # symbol table section
// 574:       SHT_STRTAB                  = 3 # string table section
// 575:       SHT_RELA                    = 4 # relocation with addends
// 576:       SHT_HASH                    = 5 # symbol hash table
// 577:       SHT_DYNAMIC                 = 6 # information of dynamic linking
// 578:       SHT_NOTE                    = 7 # section for notes
// 579:       SHT_NOBITS                  = 8 # section occupies no space
// 580:       SHT_REL                     = 9 # relocation
// 581:       SHT_SHLIB                   = 10 # reserved
// 582:       SHT_DYNSYM                  = 11 # symbols for dynamic
// 583:       SHT_INIT_ARRAY              = 14 # array of initialization functions
// 584:       SHT_FINI_ARRAY              = 15 # array of termination functions
// 585:       SHT_PREINIT_ARRAY           = 16 # array of functions that are invoked before all other initialization functions
// 586:       SHT_GROUP                   = 17 # section group
// 587:       SHT_SYMTAB_SHNDX            = 18 # indices for SHN_XINDEX entries
// 588:       SHT_RELR                    = 19 # RELR relative relocations
// 589:
// 590:       # Values between {SHT_LOOS} and {SHT_HIOS} are reserved for operating system-specific semantics.
// 591:       SHT_LOOS                    = 0x60000000
// 592:       SHT_GNU_INCREMENTAL_INPUTS  = 0x6fff4700 # incremental build data
// 593:       SHT_GNU_INCREMENTAL_SYMTAB  = 0x6fff4701 # incremental build data
// 594:       SHT_GNU_INCREMENTAL_RELOCS  = 0x6fff4702 # incremental build data
// 595:       SHT_GNU_INCREMENTAL_GOT_PLT = 0x6fff4703 # incremental build data
// 596:       SHT_GNU_ATTRIBUTES          = 0x6ffffff5 # object attributes
// 597:       SHT_GNU_HASH                = 0x6ffffff6 # GNU style symbol hash table
// 598:       SHT_GNU_LIBLIST             = 0x6ffffff7 # list of prelink dependencies
// 599:       SHT_SUNW_verdef             = 0x6ffffffd # versions defined by file
// 600:       SHT_GNU_verdef              = 0x6ffffffd # versions defined by file
// 601:       SHT_SUNW_verneed            = 0x6ffffffe # versions needed by file
// 602:       SHT_GNU_verneed             = 0x6ffffffe # versions needed by file
// 603:       SHT_SUNW_versym             = 0x6fffffff # symbol versions
// 604:       SHT_GNU_versym              = 0x6fffffff # symbol versions
// 605:       SHT_HIOS                    = 0x6fffffff # see {SHT_LOOS}
// 606:
// 607:       # Values between {SHT_LOPROC} and {SHT_HIPROC} are reserved for processor-specific semantics.
// 608:       SHT_LOPROC                  = 0x70000000
// 609:
// 610:       SHT_SPARC_GOTDATA           = 0x70000000 # :nodoc:
// 611:
// 612:       SHT_ARM_EXIDX               = 0x70000001 # exception index table
// 613:       SHT_ARM_PREEMPTMAP          = 0x70000002 # BPABI DLL dynamic linking pre-emption map
// 614:       SHT_ARM_ATTRIBUTES          = 0x70000003 # object file compatibility attributes
// 615:       SHT_ARM_DEBUGOVERLAY        = 0x70000004 # support for debugging overlaid programs
// 616:       SHT_ARM_OVERLAYSECTION      = 0x70000005 # support for debugging overlaid programs
// 617:
// 618:       SHT_X86_64_UNWIND           = 0x70000001 # x86_64 unwind information
// 619:
// 620:       SHT_MIPS_LIBLIST            = 0x70000000 # set of dynamic shared objects
// 621:       SHT_MIPS_MSYM               = 0x70000001 # :nodoc:
// 622:       SHT_MIPS_CONFLICT           = 0x70000002 # list of symbols whose definitions conflict with shared objects
// 623:       SHT_MIPS_GPTAB              = 0x70000003 # global pointer table
// 624:       SHT_MIPS_UCODE              = 0x70000004 # microcode information
// 625:       SHT_MIPS_DEBUG              = 0x70000005 # register usage information
// 626:       SHT_MIPS_REGINFO            = 0x70000006 # section contains register usage information
// 627:       SHT_MIPS_PACKAGE            = 0x70000007 # :nodoc:
// 628:       SHT_MIPS_PACKSYM            = 0x70000008 # :nodoc:
// 629:       SHT_MIPS_RELD               = 0x70000009 # :nodoc:
// 630:       SHT_MIPS_IFACE              = 0x7000000b # interface information
// 631:       SHT_MIPS_CONTENT            = 0x7000000c # description of contents of another section
// 632:       SHT_MIPS_OPTIONS            = 0x7000000d # miscellaneous options
// 633:       SHT_MIPS_SHDR               = 0x70000010 # :nodoc:
// 634:       SHT_MIPS_FDESC              = 0x70000011 # :nodoc:
// 635:       SHT_MIPS_EXTSYM             = 0x70000012 # :nodoc:
// 636:       SHT_MIPS_DENSE              = 0x70000013 # :nodoc:
// 637:       SHT_MIPS_PDESC              = 0x70000014 # :nodoc:
// 638:       SHT_MIPS_LOCSYM             = 0x70000015 # :nodoc:
// 639:       SHT_MIPS_AUXSYM             = 0x70000016 # :nodoc:
// 640:       SHT_MIPS_OPTSYM             = 0x70000017 # :nodoc:
// 641:       SHT_MIPS_LOCSTR             = 0x70000018 # :nodoc:
// 642:       SHT_MIPS_LINE               = 0x70000019 # :nodoc:
// 643:       SHT_MIPS_RFDESC             = 0x7000001a # :nodoc:
// 644:       SHT_MIPS_DELTASYM           = 0x7000001b # delta C++ symbol table
// 645:       SHT_MIPS_DELTAINST          = 0x7000001c # delta C++ instance table
// 646:       SHT_MIPS_DELTACLASS         = 0x7000001d # delta C++ class table
// 647:       SHT_MIPS_DWARF              = 0x7000001e # DWARF debugging section
// 648:       SHT_MIPS_DELTADECL          = 0x7000001f # delta C++ declarations
// 649:       SHT_MIPS_SYMBOL_LIB         = 0x70000020 # list of libraries the binary depends on
// 650:       SHT_MIPS_EVENTS             = 0x70000021 # events section
// 651:       SHT_MIPS_TRANSLATE          = 0x70000022 # :nodoc:
// 652:       SHT_MIPS_PIXIE              = 0x70000023 # :nodoc:
// 653:       SHT_MIPS_XLATE              = 0x70000024 # address translation table
// 654:       SHT_MIPS_XLATE_DEBUG        = 0x70000025 # SGI internal address translation table
// 655:       SHT_MIPS_WHIRL              = 0x70000026 # intermediate code
// 656:       SHT_MIPS_EH_REGION          = 0x70000027 # C++ exception handling region info
// 657:       SHT_MIPS_PDR_EXCEPTION      = 0x70000029 # runtime procedure descriptor table exception information
// 658:       SHT_MIPS_ABIFLAGS           = 0x7000002a # ABI related flags
// 659:       SHT_MIPS_XHASH              = 0x7000002b # GNU style symbol hash table with xlat
// 660:
// 661:       SHT_AARCH64_ATTRIBUTES      = 0x70000003 # :nodoc:
// 662:
// 663:       SHT_CSKY_ATTRIBUTES         = 0x70000001 # object file compatibility attributes
// 664:
// 665:       SHT_ORDERED                 = 0x7fffffff # :nodoc:
// 666:
// 667:       SHT_HIPROC                  = 0x7fffffff # see {SHT_LOPROC}
// 668:
// 669:       # Values between {SHT_LOUSER} and {SHT_HIUSER} are reserved for application programs.
// 670:       SHT_LOUSER                  = 0x80000000
// 671:       SHT_HIUSER                  = 0xffffffff # see {SHT_LOUSER}
// 672:     end
// 673:     include SHT
// 674:
// 675:     # Symbol binding from Sym st_info field.
// 676:     module STB
// 677:       STB_LOCAL      = 0 # Local symbol
// 678:       STB_GLOBAL     = 1 # Global symbol
// 679:       STB_WEAK       = 2 # Weak symbol
// 680:       STB_NUM        = 3 # Number of defined types.
// 681:       STB_LOOS       = 10 # Start of OS-specific
// 682:       STB_GNU_UNIQUE = 10 # Unique symbol.
// 683:       STB_HIOS       = 12 # End of OS-specific
// 684:       STB_LOPROC     = 13 # Start of processor-specific
// 685:       STB_HIPROC     = 15 # End of processor-specific
// 686:     end
// 687:     include STB
// 688:
// 689:     # Symbol types from Sym st_info field.
// 690:     module STT
// 691:       STT_NOTYPE         = 0 # Symbol type is unspecified
// 692:       STT_OBJECT         = 1 # Symbol is a data object
// 693:       STT_FUNC           = 2 # Symbol is a code object
// 694:       STT_SECTION        = 3 # Symbol associated with a section
// 695:       STT_FILE           = 4 # Symbol's name is file name
// 696:       STT_COMMON         = 5 # Symbol is a common data object
// 697:       STT_TLS            = 6 # Symbol is thread-local data object
// 698:       STT_NUM            = 7 # Deprecated.
// 699:       STT_RELC           = 8 # Complex relocation expression
// 700:       STT_SRELC          = 9 # Signed Complex relocation expression
// 701:
// 702:       # GNU extension: symbol value points to a function which is called
// 703:       # at runtime to determine the final value of the symbol.
// 704:       STT_GNU_IFUNC      = 10
// 705:
// 706:       STT_LOOS           = 10 # Start of OS-specific
// 707:       STT_HIOS           = 12 # End of OS-specific
// 708:       STT_LOPROC         = 13 # Start of processor-specific
// 709:       STT_HIPROC         = 15 # End of processor-specific
// 710:
// 711:       # The section type that must be used for register symbols on
// 712:       # Sparc. These symbols initialize a global register.
// 713:       STT_SPARC_REGISTER = 13
// 714:
// 715:       # ARM: a THUMB function. This is not defined in ARM ELF Specification but
// 716:       # used by the GNU tool-chain.
// 717:       STT_ARM_TFUNC      = 13
// 718:       STT_ARM_16BIT      = 15 # ARM: a THUMB label.
// 719:     end
// 720:     include STT
// 721:   end
// 722: end
