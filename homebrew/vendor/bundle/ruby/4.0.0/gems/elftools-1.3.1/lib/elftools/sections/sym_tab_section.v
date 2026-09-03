module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/sym_tab_section.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ElfTableEndian {
	little
	big
}

pub struct ElfTableSectionHeader {
pub:
	sh_type    u32
	sh_offset  u64
	sh_size    u64
	sh_link    u32
	sh_entsize u64
	elf_class  int
	endian     ElfTableEndian
}

pub struct ElfSymbolHeader {
pub:
	st_name   u32
	st_value  u64
	st_size   u64
	st_info   u8
	st_other  u8
	st_shndx  u16
	offset    u64
	elf_class int
}

pub struct ElfSymbol {
pub:
	header        ElfSymbolHeader
	stream        []u8
	symstr        []u8
	symstr_offset int
}

pub struct SymTabSection {
pub:
	header        ElfTableSectionHeader
	stream        []u8
	symstr        []u8
	symstr_offset int
}

fn table_endian(value string) ElfTableEndian {
	return if value == 'big' { .big } else { .little }
}

fn table_header_from_value(value brew_runtime.Value) ElfTableSectionHeader {
	return ElfTableSectionHeader{
		sh_type: (value.attribute('sh_type') or { '0' }).u32()
		sh_offset: (value.attribute('sh_offset') or { '0' }).u64()
		sh_size: (value.attribute('sh_size') or { '0' }).u64()
		sh_link: (value.attribute('sh_link') or { '0' }).u32()
		sh_entsize: (value.attribute('sh_entsize') or { '0' }).u64()
		elf_class: (value.attribute('elf_class') or { '64' }).int()
		endian: table_endian(value.attribute('endian') or { 'little' })
	}
}

fn read_table_u16(data []u8, offset int, endian ElfTableEndian) !u16 {
	if offset < 0 || offset + 2 > data.len {
		return error('ELF field is outside the stream')
	}
	return if endian == .little {
		u16(data[offset]) | (u16(data[offset + 1]) << 8)
	} else {
		(u16(data[offset]) << 8) | u16(data[offset + 1])
	}
}

fn read_table_u32(data []u8, offset int, endian ElfTableEndian) !u32 {
	if offset < 0 || offset + 4 > data.len {
		return error('ELF field is outside the stream')
	}
	mut result := u32(0)
	if endian == .little {
		for shift := 0; shift < 32; shift += 8 {
			result |= u32(data[offset + shift / 8]) << shift
		}
	} else {
		for i := 0; i < 4; i++ {
			result = (result << 8) | u32(data[offset + i])
		}
	}
	return result
}

fn read_table_u64(data []u8, offset int, endian ElfTableEndian) !u64 {
	if offset < 0 || offset + 8 > data.len {
		return error('ELF field is outside the stream')
	}
	mut result := u64(0)
	if endian == .little {
		for shift := 0; shift < 64; shift += 8 {
			result |= u64(data[offset + shift / 8]) << shift
		}
	} else {
		for i := 0; i < 8; i++ {
			result = (result << 8) | u64(data[offset + i])
		}
	}
	return result
}

pub fn (section SymTabSection) num_symbols() !int {
	if section.header.sh_entsize == 0 {
		return error('symbol entry size is zero')
	}
	count_u64 := section.header.sh_size / section.header.sh_entsize
	count := int(count_u64)
	if count < 0 || u64(count) != count_u64 {
		return error('symbol count does not fit a V array')
	}
	return count
}

pub fn (section SymTabSection) create_symbol(n int) !ElfSymbol {
	count := section.num_symbols()!
	if n < 0 || n >= count {
		return error('symbol index ${n} is outside 0..${count}')
	}
	relative_offset := u64(n) * section.header.sh_entsize
	if section.header.sh_offset > u64(section.stream.len) || relative_offset > u64(section.stream.len) - section.header.sh_offset {
		return error('symbol offset is outside the stream')
	}
	offset_u64 := section.header.sh_offset + relative_offset
	offset := int(offset_u64)
	mut header := ElfSymbolHeader{
		offset: offset_u64
		elf_class: section.header.elf_class
	}
	match section.header.elf_class {
		32 {
			if offset + 16 > section.stream.len {
				return error('ELF32 symbol is outside the stream')
			}
			header = ElfSymbolHeader{
				st_name: read_table_u32(section.stream, offset, section.header.endian)!
				st_value: read_table_u32(section.stream, offset + 4, section.header.endian)!
				st_size: read_table_u32(section.stream, offset + 8, section.header.endian)!
				st_info: section.stream[offset + 12]
				st_other: section.stream[offset + 13]
				st_shndx: read_table_u16(section.stream, offset + 14, section.header.endian)!
				offset: offset_u64
				elf_class: 32
			}
		}
		64 {
			if offset + 24 > section.stream.len {
				return error('ELF64 symbol is outside the stream')
			}
			header = ElfSymbolHeader{
				st_name: read_table_u32(section.stream, offset, section.header.endian)!
				st_info: section.stream[offset + 4]
				st_other: section.stream[offset + 5]
				st_shndx: read_table_u16(section.stream, offset + 6, section.header.endian)!
				st_value: read_table_u64(section.stream, offset + 8, section.header.endian)!
				st_size: read_table_u64(section.stream, offset + 16, section.header.endian)!
				offset: offset_u64
				elf_class: 64
			}
		}
		else {
			return error('unsupported ELF class ${section.header.elf_class}')
		}
	}
	return ElfSymbol{
		header: header
		stream: section.stream.clone()
		symstr: section.symstr.clone()
		symstr_offset: section.symstr_offset
	}
}

pub fn (section SymTabSection) symbol_at(n int) ?ElfSymbol {
	if n < 0 || n >= section.num_symbols() or { panic(err) } {
		return none
	}
	return section.create_symbol(n) or { panic(err) }
}

pub fn (section SymTabSection) each_symbols(on_symbol fn(ElfSymbol)) ![]ElfSymbol {
	mut symbols := []ElfSymbol{cap: section.num_symbols()!}
	for i in 0 .. section.num_symbols()! {
		symbol := section.create_symbol(i)!
		symbols << symbol
		on_symbol(symbol)
	}
	return symbols
}

fn ignore_elf_symbol(_ ElfSymbol) {}

pub fn (section SymTabSection) symbols() ![]ElfSymbol {
	return section.each_symbols(ignore_elf_symbol)
}

pub fn (section SymTabSection) symbol_by_name(name string) ?ElfSymbol {
	for i in 0 .. section.num_symbols() or { panic(err) } {
		symbol := section.create_symbol(i) or { panic(err) }
		if symbol.name() or { panic(err) } == name {
			return symbol
		}
	}
	return none
}

pub fn (symbol ElfSymbol) name() !string {
	start := symbol.symstr_offset + int(symbol.header.st_name)
	if start < 0 || start >= symbol.symstr.len {
		return error('symbol name offset is outside the string table')
	}
	mut finish := start
	for finish < symbol.symstr.len {
		if symbol.symstr[finish] == 0 {
			return symbol.symstr[start..finish].bytestr()
		}
		finish++
	}
	return error('symbol name is not null-terminated')
}

fn sym_tab_section_value(section SymTabSection) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Sections::SymTabSection', 'SymTabSection', {
		'sh_type':       section.header.sh_type.str()
		'sh_offset':     section.header.sh_offset.str()
		'sh_size':       section.header.sh_size.str()
		'sh_link':       section.header.sh_link.str()
		'sh_entsize':    section.header.sh_entsize.str()
		'elf_class':     section.header.elf_class.str()
		'endian':        section.header.endian.str()
		'stream':        section.stream.bytestr()
		'symstr':        section.symstr.bytestr()
		'symstr_offset': section.symstr_offset.str()
	})
}

fn sym_tab_section_from_value(value brew_runtime.Value) SymTabSection {
	return SymTabSection{
		header: table_header_from_value(value)
		stream: (value.attribute('stream') or { '' }).bytes()
		symstr: (value.attribute('symstr') or { '' }).bytes()
		symstr_offset: (value.attribute('symstr_offset') or { '0' }).int()
	}
}

fn elf_symbol_value(symbol ElfSymbol) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Sections::Symbol', symbol.name() or { '' }, {
		'st_name':       symbol.header.st_name.str()
		'st_value':      symbol.header.st_value.str()
		'st_size':       symbol.header.st_size.str()
		'st_info':       symbol.header.st_info.str()
		'st_other':      symbol.header.st_other.str()
		'st_shndx':      symbol.header.st_shndx.str()
		'offset':        symbol.header.offset.str()
		'elf_class':     symbol.header.elf_class.str()
		'stream':        symbol.stream.bytestr()
		'symstr':        symbol.symstr.bytestr()
		'symstr_offset': symbol.symstr_offset.str()
	})
}

fn elf_symbol_from_value(value brew_runtime.Value) ElfSymbol {
	return ElfSymbol{
		header: ElfSymbolHeader{
			st_name: (value.attribute('st_name') or { '0' }).u32()
			st_value: (value.attribute('st_value') or { '0' }).u64()
			st_size: (value.attribute('st_size') or { '0' }).u64()
			st_info: (value.attribute('st_info') or { '0' }).u8()
			st_other: (value.attribute('st_other') or { '0' }).u8()
			st_shndx: (value.attribute('st_shndx') or { '0' }).u16()
			offset: (value.attribute('offset') or { '0' }).u64()
			elf_class: (value.attribute('elf_class') or { '64' }).int()
		}
		stream: (value.attribute('stream') or { '' }).bytes()
		symstr: (value.attribute('symstr') or { '' }).bytes()
		symstr_offset: (value.attribute('symstr_offset') or { '0' }).int()
	}
}

// Ruby method `initialize(header, stream, section_at: nil, **_kwargs)` at line 21.
pub fn ruby_sym_tab_section_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('SymTabSection#initialize requires a header and stream')
	}
	mut symstr := []u8{}
	mut symstr_offset := 0
	if args.len >= 3 && args[2].type_name != 'NilClass' {
		if stream := args[2].attribute('stream') {
			symstr = stream.bytes()
			symstr_offset = (args[2].attribute('sh_offset') or { '0' }).int()
		} else {
			symstr = args[2].as_string().bytes()
		}
	}
	return sym_tab_section_value(SymTabSection{
		header: table_header_from_value(args[0])
		stream: args[1].as_string().bytes()
		symstr: symstr
		symstr_offset: symstr_offset
	})
}

// Ruby method `num_symbols` at line 32.
pub fn ruby_sym_tab_section_l32_d2_num_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('SymTabSection#num_symbols requires a receiver') }
	return brew_runtime.int_value(sym_tab_section_from_value(args[0]).num_symbols() or { panic(err) })
}

// Ruby method `symbol_at(n)` at line 43.
pub fn ruby_sym_tab_section_l43_d3_symbol_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SymTabSection#symbol_at requires a receiver and index') }
	symbol := sym_tab_section_from_value(args[0]).symbol_at(int(args[1].as_int() or { panic(err) })) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return elf_symbol_value(symbol)
}

// Ruby method `each_symbols(&block)` at line 59.
pub fn ruby_sym_tab_section_l59_d4_each_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('SymTabSection#each_symbols requires a receiver') }
	return brew_runtime.array_value(sym_tab_section_from_value(args[0]).symbols() or {
		panic(err)
	}.map(elf_symbol_value(it)))
}

// Ruby method `symbols` at line 70.
pub fn ruby_sym_tab_section_l70_d5_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_sym_tab_section_l59_d4_each_symbols(...args)
}

// Ruby method `symbol_by_name(name)` at line 78.
pub fn ruby_sym_tab_section_l78_d6_symbol_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SymTabSection#symbol_by_name requires a receiver and name') }
	symbol := sym_tab_section_from_value(args[0]).symbol_by_name(args[1].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return elf_symbol_value(symbol)
}

// Ruby method `symstr` at line 85.
pub fn ruby_sym_tab_section_l85_d7_symstr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('SymTabSection#symstr requires a receiver') }
	section := sym_tab_section_from_value(args[0])
	return brew_runtime.structured_value('ELFTools::Sections::StrTabSection', 'StrTabSection', {
		'sh_offset': section.symstr_offset.str()
		'sh_link':   section.header.sh_link.str()
		'stream':    section.symstr.bytestr()
	})
}

// Ruby method `create_symbol(n)` at line 91.
pub fn ruby_sym_tab_section_l91_d8_create_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SymTabSection#create_symbol requires a receiver and index') }
	return elf_symbol_value(sym_tab_section_from_value(args[0]).create_symbol(int(args[1].as_int() or {
		panic(err)
	})) or { panic(err) })
}

// Ruby attr_reader `attr_reader :header` at line 103.
pub fn ruby_sym_tab_section_l103_d9_header(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Symbol#header requires a receiver') }
	return brew_runtime.structured_value('ELF_sym', '', {
		'st_name':   args[0].attribute('st_name') or { '0' }
		'st_value':  args[0].attribute('st_value') or { '0' }
		'st_size':   args[0].attribute('st_size') or { '0' }
		'st_info':   args[0].attribute('st_info') or { '0' }
		'st_other':  args[0].attribute('st_other') or { '0' }
		'st_shndx':  args[0].attribute('st_shndx') or { '0' }
		'offset':    args[0].attribute('offset') or { '0' }
		'elf_class': args[0].attribute('elf_class') or { '64' }
	})
}

// Ruby attr_reader `attr_reader :stream` at line 104.
pub fn ruby_sym_tab_section_l104_d10_stream(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Symbol#stream requires a receiver') }
	return brew_runtime.string_value(args[0].attribute('stream') or { panic('symbol has no stream') })
}

// Ruby method `initialize(header, stream, symstr: nil)` at line 114.
pub fn ruby_sym_tab_section_l114_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Symbol#initialize requires a header and stream') }
	mut attributes := args[0].attributes.clone()
	attributes['stream'] = args[1].as_string()
	if args.len >= 3 {
		attributes['symstr'] = args[2].attribute('stream') or { args[2].as_string() }
		attributes['symstr_offset'] = args[2].attribute('sh_offset') or { '0' }
	}
	return brew_runtime.structured_value('ELFTools::Sections::Symbol', '', attributes)
}

// Ruby method `name` at line 122.
pub fn ruby_sym_tab_section_l122_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Symbol#name requires a receiver') }
	return brew_runtime.string_value(elf_symbol_from_value(args[0]).name() or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/sections/section'
// 4:
// 5: module ELFTools
// 6:   module Sections
// 7:     # Class of symbol table section.
// 8:     # Usually for section .symtab and .dynsym,
// 9:     # which will refer to symbols in ELF file.
// 10:     class SymTabSection < Section
// 11:       # Instantiate a {SymTabSection} object.
// 12:       # There's a +section_at+ lambda for {SymTabSection}
// 13:       # to easily fetch other sections.
// 14:       # @param [ELFTools::Structs::ELF_Shdr] header
// 15:       #   See {Section#initialize} for more information.
// 16:       # @param [#pos=, #read] stream
// 17:       #   See {Section#initialize} for more information.
// 18:       # @param [Proc] section_at
// 19:       #   The method for fetching other sections by index.
// 20:       #   This lambda should be {ELFTools::ELFFile#section_at}.
// 21:       def initialize(header, stream, section_at: nil, **_kwargs)
// 22:         @section_at = section_at
// 23:         # For faster #symbol_by_name
// 24:         super
// 25:       end
// 26:
// 27:       # Number of symbols.
// 28:       # @return [Integer] The number.
// 29:       # @example
// 30:       #   symtab.num_symbols
// 31:       #   #=> 75
// 32:       def num_symbols
// 33:         header.sh_size / header.sh_entsize
// 34:       end
// 35:
// 36:       # Acquire the +n+-th symbol, 0-based.
// 37:       #
// 38:       # Symbols are lazy loaded.
// 39:       # @param [Integer] n The index.
// 40:       # @return [ELFTools::Sections::Symbol, nil]
// 41:       #   The target symbol.
// 42:       #   If +n+ is out of bound, +nil+ is returned.
// 43:       def symbol_at(n)
// 44:         @symbols ||= LazyArray.new(num_symbols, &method(:create_symbol))
// 45:         @symbols[n]
// 46:       end
// 47:
// 48:       # Iterate all symbols.
// 49:       #
// 50:       # All symbols are lazy loading, the symbol
// 51:       # only be created whenever accessing it.
// 52:       # This method is useful for {#symbol_by_name}
// 53:       # since not all symbols need to be created.
// 54:       # @yieldparam [ELFTools::Sections::Symbol] sym A symbol object.
// 55:       # @yieldreturn [void]
// 56:       # @return [Enumerator<ELFTools::Sections::Symbol>, Array<ELFTools::Sections::Symbol>]
// 57:       #   If block is not given, an enumerator will be returned.
// 58:       #   Otherwise return array of symbols.
// 59:       def each_symbols(&block)
// 60:         return enum_for(:each_symbols) unless block_given?
// 61:
// 62:         Array.new(num_symbols) do |i|
// 63:           symbol_at(i).tap(&block)
// 64:         end
// 65:       end
// 66:
// 67:       # Simply use {#symbols} to get all symbols.
// 68:       # @return [Array<ELFTools::Sections::Symbol>]
// 69:       #   The whole symbols.
// 70:       def symbols
// 71:         each_symbols.to_a
// 72:       end
// 73:
// 74:       # Get symbol by its name.
// 75:       # @param [String] name
// 76:       #   The name of symbol.
// 77:       # @return [ELFTools::Sections::Symbol] Desired symbol.
// 78:       def symbol_by_name(name)
// 79:         each_symbols.find { |symbol| symbol.name == name }
// 80:       end
// 81:
// 82:       # Return the symbol string section.
// 83:       # Lazy loaded.
// 84:       # @return [ELFTools::Sections::StrTabSection] The string table section.
// 85:       def symstr
// 86:         @symstr ||= @section_at.call(header.sh_link)
// 87:       end
// 88:
// 89:       private
// 90:
// 91:       def create_symbol(n)
// 92:         stream.pos = header.sh_offset + n * header.sh_entsize
// 93:         sym = Structs::ELF_sym[header.elf_class].new(endian: header.class.self_endian, offset: stream.pos)
// 94:         sym.read(stream)
// 95:         Symbol.new(sym, stream, symstr: method(:symstr))
// 96:       end
// 97:     end
// 98:
// 99:     # Class of symbol.
// 100:     #
// 101:     # XXX: Should this class be defined in an independent file?
// 102:     class Symbol
// 103:       attr_reader :header # @return [ELFTools::Structs::ELF32_sym, ELFTools::Structs::ELF64_sym] Section header.
// 104:       attr_reader :stream # @return [#pos=, #read] Streaming object.
// 105:
// 106:       # Instantiate a {ELFTools::Sections::Symbol} object.
// 107:       # @param [ELFTools::Structs::ELF32_sym, ELFTools::Structs::ELF64_sym] header
// 108:       #   The symbol header.
// 109:       # @param [#pos=, #read] stream The streaming object.
// 110:       # @param [ELFTools::Sections::StrTabSection, Proc] symstr
// 111:       #   The symbol string section.
// 112:       #   If +Proc+ is given, it will be called at the first time
// 113:       #   access {Symbol#name}.
// 114:       def initialize(header, stream, symstr: nil)
// 115:         @header = header
// 116:         @stream = stream
// 117:         @symstr = symstr
// 118:       end
// 119:
// 120:       # Return the symbol name.
// 121:       # @return [String] The name.
// 122:       def name
// 123:         @name ||= @symstr.call.name_at(header.st_name)
// 124:       end
// 125:     end
// 126:   end
// 127: end
