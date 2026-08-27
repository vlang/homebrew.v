module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/headers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `serialize` at line 526.
pub fn ruby_headers_l526_d1_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialize', ...args)
}

// Ruby method `to_h` at line 531.
pub fn ruby_headers_l531_d2_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `serialize` at line 562.
pub fn ruby_headers_l562_d3_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialize', ...args)
}

// Ruby method `to_h` at line 567.
pub fn ruby_headers_l567_d4_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `serialize` at line 596.
pub fn ruby_headers_l596_d5_serialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialize', ...args)
}

// Ruby method `to_h` at line 601.
pub fn ruby_headers_l601_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `flag?(flag)` at line 635.
pub fn ruby_headers_l635_d7_flag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('flag?', ...args)
}

// Ruby method `object?` at line 644.
pub fn ruby_headers_l644_d8_object(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('object?', ...args)
}

// Ruby method `executable?` at line 649.
pub fn ruby_headers_l649_d9_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable?', ...args)
}

// Ruby method `fvmlib?` at line 654.
pub fn ruby_headers_l654_d10_fvmlib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fvmlib?', ...args)
}

// Ruby method `core?` at line 659.
pub fn ruby_headers_l659_d11_core(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core?', ...args)
}

// Ruby method `preload?` at line 664.
pub fn ruby_headers_l664_d12_preload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preload?', ...args)
}

// Ruby method `dylib?` at line 669.
pub fn ruby_headers_l669_d13_dylib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dylib?', ...args)
}

// Ruby method `dylinker?` at line 674.
pub fn ruby_headers_l674_d14_dylinker(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dylinker?', ...args)
}

// Ruby method `bundle?` at line 679.
pub fn ruby_headers_l679_d15_bundle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bundle?', ...args)
}

// Ruby method `dsym?` at line 684.
pub fn ruby_headers_l684_d16_dsym(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsym?', ...args)
}

// Ruby method `kext?` at line 689.
pub fn ruby_headers_l689_d17_kext(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('kext?', ...args)
}

// Ruby method `fileset?` at line 694.
pub fn ruby_headers_l694_d18_fileset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fileset?', ...args)
}

// Ruby method `magic32?` at line 699.
pub fn ruby_headers_l699_d19_magic32(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('magic32?', ...args)
}

// Ruby method `magic64?` at line 704.
pub fn ruby_headers_l704_d20_magic64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('magic64?', ...args)
}

// Ruby method `alignment` at line 709.
pub fn ruby_headers_l709_d21_alignment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alignment', ...args)
}

// Ruby method `to_h` at line 714.
pub fn ruby_headers_l714_d22_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `to_h` at line 738.
pub fn ruby_headers_l738_d23_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `kaslr?` at line 775.
pub fn ruby_headers_l775_d24_kaslr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('kaslr?', ...args)
}

// Ruby method `lzss?` at line 780.
pub fn ruby_headers_l780_d25_lzss(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lzss?', ...args)
}

// Ruby method `lzvn?` at line 785.
pub fn ruby_headers_l785_d26_lzvn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lzvn?', ...args)
}

// Ruby method `to_h` at line 790.
pub fn ruby_headers_l790_d27_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
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
