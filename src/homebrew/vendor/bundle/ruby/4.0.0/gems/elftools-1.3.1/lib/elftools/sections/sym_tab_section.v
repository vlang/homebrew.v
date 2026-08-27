module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/sym_tab_section.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(header, stream, section_at: nil, **_kwargs)` at line 21.
pub fn ruby_sym_tab_section_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `num_symbols` at line 32.
pub fn ruby_sym_tab_section_l32_d2_num_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('num_symbols', ...args)
}

// Ruby method `symbol_at(n)` at line 43.
pub fn ruby_sym_tab_section_l43_d3_symbol_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbol_at', ...args)
}

// Ruby method `each_symbols(&block)` at line 59.
pub fn ruby_sym_tab_section_l59_d4_each_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_symbols', ...args)
}

// Ruby method `symbols` at line 70.
pub fn ruby_sym_tab_section_l70_d5_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbols', ...args)
}

// Ruby method `symbol_by_name(name)` at line 78.
pub fn ruby_sym_tab_section_l78_d6_symbol_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symbol_by_name', ...args)
}

// Ruby method `symstr` at line 85.
pub fn ruby_sym_tab_section_l85_d7_symstr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('symstr', ...args)
}

// Ruby method `create_symbol(n)` at line 91.
pub fn ruby_sym_tab_section_l91_d8_create_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_symbol', ...args)
}

// Ruby attr_reader `attr_reader :header` at line 103.
pub fn ruby_sym_tab_section_l103_d9_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 104.
pub fn ruby_sym_tab_section_l104_d10_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby method `initialize(header, stream, symstr: nil)` at line 114.
pub fn ruby_sym_tab_section_l114_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `name` at line 122.
pub fn ruby_sym_tab_section_l122_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
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
