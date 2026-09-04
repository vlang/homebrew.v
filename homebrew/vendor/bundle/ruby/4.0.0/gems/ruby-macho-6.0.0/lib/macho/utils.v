module macho

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TaggedMachoString {
pub:
	key   string
	value string
}

pub struct PackedMachoStrings {
pub:
	payload string
	offsets map[string]i64
}

pub fn macho_round(value i64, round_by i64) i64 {
	mask := round_by - 1
	return (value + mask) & ~mask
}

pub fn macho_padding_for(size i64, alignment i64) i64 {
	return macho_round(size, alignment) - size
}

pub fn macho_nullpad(size i64) !string {
	if size < 0 {
		return error('size < 0: ${size}')
	}
	return []u8{len: int(size)}.bytestr()
}

pub fn macho_specialize_format(format string, endianness string) string {
	modifier := if endianness.trim_string_left(':') == 'big' { '>' } else { '<' }
	return format.replace('=', modifier)
}

pub fn macho_pack_strings(fixed_offset i64, alignment i64, strings []TaggedMachoString) !PackedMachoStrings {
	mut offsets := map[string]i64{}
	mut next_offset := fixed_offset
	mut payload := []u8{}
	for item in strings {
		offsets[item.key] = next_offset
		payload << item.value.bytes()
		payload << u8(0)
		next_offset += item.value.len + 1
	}
	padding := macho_padding_for(fixed_offset + payload.len, alignment)
	payload << macho_nullpad(padding)!.bytes()
	return PackedMachoStrings{
		payload: payload.bytestr()
		offsets: offsets
	}
}

pub fn macho_magic(number u32) bool {
	return number in [fat_magic, fat_magic_64, mh_magic, mh_cigam, mh_magic_64, mh_cigam_64]
}

pub fn macho_fat_magic(number u32) bool {
	return number in [fat_magic, fat_magic_64]
}

pub fn macho_fat_magic32(number u32) bool {
	return number == fat_magic
}

pub fn macho_fat_magic64(number u32) bool {
	return number == fat_magic_64
}

pub fn macho_magic32(number u32) bool {
	return number in [mh_magic, mh_cigam]
}

pub fn macho_magic64(number u32) bool {
	return number in [mh_magic_64, mh_cigam_64]
}

pub fn macho_little_magic(number u32) bool {
	return number in [mh_cigam, mh_cigam_64]
}

pub fn macho_big_magic(number u32) bool {
	return number in [mh_magic, mh_magic_64]
}

pub fn macho_compressed_magic(number u32) bool {
	return number == compressed_magic
}

fn packed_macho_strings_value(packed PackedMachoStrings) ruby.Value {
	mut offsets := map[string]ruby.Value{}
	for key, offset in packed.offsets {
		offsets[key] = ruby.int_value(offset)
	}
	return ruby.array_value([
		ruby.string_value(packed.payload),
		ruby.map_value(offsets),
	])
}

// Ruby method `self.round(value, round)` at line 11.
pub fn ruby_utils_l11_d1_self_round(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MachO::Utils.round requires a value and round')
	}
	return ruby.int_value(macho_round(args[0].as_int() or { panic(err) }, args[1].as_int() or { panic(err) }))
}

// Ruby method `self.padding_for(size, alignment)` at line 23.
pub fn ruby_utils_l23_d2_self_padding_for(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MachO::Utils.padding_for requires a size and alignment')
	}
	return ruby.int_value(macho_padding_for(args[0].as_int() or { panic(err) }, args[1].as_int() or { panic(err) }))
}

// Ruby method `self.nullpad(size)` at line 31.
pub fn ruby_utils_l31_d3_self_nullpad(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachO::Utils.nullpad requires a size')
	}
	return ruby.string_value(macho_nullpad(args[0].as_int() or { panic(err) }) or {
		panic(err)
	})
}

// Ruby method `self.specialize_format(format, endianness)` at line 42.
pub fn ruby_utils_l42_d4_self_specialize_format(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MachO::Utils.specialize_format requires a format and endianness')
	}
	return ruby.string_value(macho_specialize_format(args[0].as_string(), args[1].as_string()))
}

// Ruby method `self.pack_strings(fixed_offset, alignment, strings = {})` at line 53.
pub fn ruby_utils_l53_d5_self_pack_strings(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MachO::Utils.pack_strings requires a fixed offset and alignment')
	}
	mut strings := []TaggedMachoString{}
	if args.len > 2 {
		for key, value in args[2].as_map() or { panic(err) } {
			strings << TaggedMachoString{
				key: key
				value: value.as_string()
			}
		}
	}
	return packed_macho_strings_value(macho_pack_strings(args[0].as_int() or { panic(err) }, args[1].as_int() or { panic(err) }, strings) or { panic(err) })
}

// Ruby method `self.magic?(num)` at line 72.
pub fn ruby_utils_l72_d6_self_magic(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_magic(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.fat_magic?(num)` at line 79.
pub fn ruby_utils_l79_d7_self_fat_magic(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_fat_magic(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.fat_magic32?(num)` at line 86.
pub fn ruby_utils_l86_d8_self_fat_magic32(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_fat_magic32(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.fat_magic64?(num)` at line 93.
pub fn ruby_utils_l93_d9_self_fat_magic64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_fat_magic64(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.magic32?(num)` at line 100.
pub fn ruby_utils_l100_d10_self_magic32(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_magic32(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.magic64?(num)` at line 107.
pub fn ruby_utils_l107_d11_self_magic64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_magic64(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.little_magic?(num)` at line 114.
pub fn ruby_utils_l114_d12_self_little_magic(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_little_magic(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.big_magic?(num)` at line 121.
pub fn ruby_utils_l121_d13_self_big_magic(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_big_magic(u32(args[0].as_int() or { panic(err) })))
}

// Ruby method `self.compressed_magic?(num)` at line 128.
pub fn ruby_utils_l128_d14_self_compressed_magic(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(macho_compressed_magic(u32(args[0].as_int() or { panic(err) })))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A collection of utility functions used throughout ruby-macho.
// 5:   module Utils
// 6:     # Rounds a value to the next multiple of the given round.
// 7:     # @param value [Integer] the number being rounded
// 8:     # @param round [Integer] the number being rounded with
// 9:     # @return [Integer] the rounded value
// 10:     # @see http://www.opensource.apple.com/source/cctools/cctools-870/libstuff/rnd.c
// 11:     def self.round(value, round)
// 12:       round -= 1
// 13:       value += round
// 14:       value &= ~round
// 15:       value
// 16:     end
// 17:
// 18:     # Returns the number of bytes needed to pad the given size to the given
// 19:     #  alignment.
// 20:     # @param size [Integer] the unpadded size
// 21:     # @param alignment [Integer] the number to alignment the size with
// 22:     # @return [Integer] the number of pad bytes required
// 23:     def self.padding_for(size, alignment)
// 24:       round(size, alignment) - size
// 25:     end
// 26:
// 27:     # Returns a string of null bytes of the requested (non-negative) size
// 28:     # @param size [Integer] the size of the nullpad
// 29:     # @return [String] the null string (or empty string, for `size = 0`)
// 30:     # @raise [ArgumentError] if a non-positive nullpad is requested
// 31:     def self.nullpad(size)
// 32:       raise ArgumentError, "size < 0: #{size}" if size.negative?
// 33:
// 34:       "\x00" * size
// 35:     end
// 36:
// 37:     # Converts an abstract (native-endian) String#unpack format to big or
// 38:     #  little.
// 39:     # @param format [String] the format string being converted
// 40:     # @param endianness [Symbol] either `:big` or `:little`
// 41:     # @return [String] the converted string
// 42:     def self.specialize_format(format, endianness)
// 43:       modifier = endianness == :big ? ">" : "<"
// 44:       format.tr("=", modifier)
// 45:     end
// 46:
// 47:     # Packs tagged strings into an aligned payload.
// 48:     # @param fixed_offset [Integer] the baseline offset for the first packed
// 49:     #  string
// 50:     # @param alignment [Integer] the alignment value to use for packing
// 51:     # @param strings [Hash] the labeled strings to pack
// 52:     # @return [Array<String, Hash>] the packed string and labeled offsets
// 53:     def self.pack_strings(fixed_offset, alignment, strings = {})
// 54:       offsets = {}
// 55:       next_offset = fixed_offset
// 56:       payload = +""
// 57:
// 58:       strings.each do |key, string|
// 59:         offsets[key] = next_offset
// 60:         payload << string
// 61:         payload << Utils.nullpad(1)
// 62:         next_offset += string.bytesize + 1
// 63:       end
// 64:
// 65:       payload << Utils.nullpad(padding_for(fixed_offset + payload.bytesize, alignment))
// 66:       [payload.freeze, offsets]
// 67:     end
// 68:
// 69:     # Compares the given number to valid Mach-O magic numbers.
// 70:     # @param num [Integer] the number being checked
// 71:     # @return [Boolean] whether `num` is a valid Mach-O magic number
// 72:     def self.magic?(num)
// 73:       Headers::MH_MAGICS.key?(num)
// 74:     end
// 75:
// 76:     # Compares the given number to valid Fat magic numbers.
// 77:     # @param num [Integer] the number being checked
// 78:     # @return [Boolean] whether `num` is a valid Fat magic number
// 79:     def self.fat_magic?(num)
// 80:       [Headers::FAT_MAGIC, Headers::FAT_MAGIC_64].include? num
// 81:     end
// 82:
// 83:     # Compares the given number to valid 32-bit Fat magic numbers.
// 84:     # @param num [Integer] the number being checked
// 85:     # @return [Boolean] whether `num` is a valid 32-bit fat magic number
// 86:     def self.fat_magic32?(num)
// 87:       num == Headers::FAT_MAGIC
// 88:     end
// 89:
// 90:     # Compares the given number to valid 64-bit Fat magic numbers.
// 91:     # @param num [Integer] the number being checked
// 92:     # @return [Boolean] whether `num` is a valid 64-bit fat magic number
// 93:     def self.fat_magic64?(num)
// 94:       num == Headers::FAT_MAGIC_64
// 95:     end
// 96:
// 97:     # Compares the given number to valid 32-bit Mach-O magic numbers.
// 98:     # @param num [Integer] the number being checked
// 99:     # @return [Boolean] whether `num` is a valid 32-bit magic number
// 100:     def self.magic32?(num)
// 101:       [Headers::MH_MAGIC, Headers::MH_CIGAM].include? num
// 102:     end
// 103:
// 104:     # Compares the given number to valid 64-bit Mach-O magic numbers.
// 105:     # @param num [Integer] the number being checked
// 106:     # @return [Boolean] whether `num` is a valid 64-bit magic number
// 107:     def self.magic64?(num)
// 108:       [Headers::MH_MAGIC_64, Headers::MH_CIGAM_64].include? num
// 109:     end
// 110:
// 111:     # Compares the given number to valid little-endian magic numbers.
// 112:     # @param num [Integer] the number being checked
// 113:     # @return [Boolean] whether `num` is a valid little-endian magic number
// 114:     def self.little_magic?(num)
// 115:       [Headers::MH_CIGAM, Headers::MH_CIGAM_64].include? num
// 116:     end
// 117:
// 118:     # Compares the given number to valid big-endian magic numbers.
// 119:     # @param num [Integer] the number being checked
// 120:     # @return [Boolean] whether `num` is a valid big-endian magic number
// 121:     def self.big_magic?(num)
// 122:       [Headers::MH_MAGIC, Headers::MH_MAGIC_64].include? num
// 123:     end
// 124:
// 125:     # Compares the given number to the known magic number for a compressed Mach-O slice.
// 126:     # @param num [Integer] the number being checked
// 127:     # @return [Boolean] whether `num` is a valid compressed header magic number
// 128:     def self.compressed_magic?(num)
// 129:       num == Headers::COMPRESSED_MAGIC
// 130:     end
// 131:   end
// 132: end
