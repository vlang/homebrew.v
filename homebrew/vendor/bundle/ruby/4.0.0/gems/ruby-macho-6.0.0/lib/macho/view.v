module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/view.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct MachoView {
pub:
	macho_file brew_runtime.Value
	raw_data   string
	endianness string
	offset     i64
}

pub fn new_macho_view(macho_file brew_runtime.Value, raw_data string, endianness string, offset i64) &MachoView {
	return &MachoView{
		macho_file: macho_file
		raw_data: raw_data
		endianness: endianness.trim_string_left(':')
		offset: offset
	}
}

pub fn (view &MachoView) to_h() brew_runtime.Value {
	return brew_runtime.map_value({
		'endianness': brew_runtime.object_value('Symbol', ':${view.endianness}')
		'offset':     brew_runtime.int_value(view.offset)
	})
}

pub fn (view &MachoView) inspect() string {
	identity := (u64(voidptr(view)) * 2).hex()
	return '#<MachO::MachOView:0x${identity} @endianness=:${view.endianness}, @offset=${view.offset}, length=${view.raw_data.len}>'
}

fn macho_view_value(view &MachoView) brew_runtime.Value {
	return brew_runtime.structured_value('MachO::MachOView', view.inspect(), {
		'macho_view_address': u64(voidptr(view)).str()
	})
}

fn macho_view_from_args(args []brew_runtime.Value) &MachoView {
	if args.len == 0 {
		panic('MachOView method requires a receiver')
	}
	address := args[0].attribute('macho_view_address') or { panic('invalid MachOView receiver') }
	return unsafe { &MachoView(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :macho_file` at line 7.
pub fn ruby_view_l7_d1_macho_file(args ...brew_runtime.Value) brew_runtime.Value {
	return macho_view_from_args(args).macho_file
}

// Ruby attr_reader `attr_reader :raw_data` at line 10.
pub fn ruby_view_l10_d2_raw_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(macho_view_from_args(args).raw_data)
}

// Ruby attr_reader `attr_reader :endianness` at line 13.
pub fn ruby_view_l13_d3_endianness(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${macho_view_from_args(args).endianness}')
}

// Ruby attr_reader `attr_reader :offset` at line 16.
pub fn ruby_view_l16_d4_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(macho_view_from_args(args).offset)
}

// Ruby method `initialize(macho_file, raw_data, endianness, offset)` at line 23.
pub fn ruby_view_l23_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('MachOView#initialize requires a MachO file, raw data, endianness, and offset')
	}
	return macho_view_value(new_macho_view(args[0], args[1].as_string(), args[2].as_string(), args[3].as_int() or { panic(err) }))
}

// Ruby method `to_h` at line 31.
pub fn ruby_view_l31_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return macho_view_from_args(args).to_h()
}

// Ruby method `inspect` at line 38.
pub fn ruby_view_l38_d7_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(macho_view_from_args(args).inspect())
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A representation of some unspecified Mach-O data.
// 5:   class MachOView
// 6:     # @return [MachOFile] that this view belongs to
// 7:     attr_reader :macho_file
// 8:
// 9:     # @return [String] the raw Mach-O data
// 10:     attr_reader :raw_data
// 11:
// 12:     # @return [Symbol] the endianness of the data (`:big` or `:little`)
// 13:     attr_reader :endianness
// 14:
// 15:     # @return [Integer] the offset of the relevant data (in {#raw_data})
// 16:     attr_reader :offset
// 17:
// 18:     # Creates a new MachOView.
// 19:     # @param macho_file [MachOFile] the file this view slice is from
// 20:     # @param raw_data [String] the raw Mach-O data
// 21:     # @param endianness [Symbol] the endianness of the data
// 22:     # @param offset [Integer] the offset of the relevant data
// 23:     def initialize(macho_file, raw_data, endianness, offset)
// 24:       @macho_file = macho_file
// 25:       @raw_data = raw_data
// 26:       @endianness = endianness
// 27:       @offset = offset
// 28:     end
// 29:
// 30:     # @return [Hash] a hash representation of this {MachOView}.
// 31:     def to_h
// 32:       {
// 33:         "endianness" => endianness,
// 34:         "offset" => offset,
// 35:       }
// 36:     end
// 37:
// 38:     def inspect
// 39:       "#<#{self.class}:0x#{(object_id << 1).to_s(16)} @endianness=#{@endianness.inspect}, @offset=#{@offset.inspect}, length=#{@raw_data.length}>"
// 40:     end
// 41:   end
// 42: end
