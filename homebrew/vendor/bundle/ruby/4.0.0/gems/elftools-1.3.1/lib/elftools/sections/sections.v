module sections

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/sections/sections.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SectionKind {
	section
	dynamic
	null_section
	note
	relocation
	string_table
	symbol_table
}

pub fn section_kind(section_type int) SectionKind {
	return match section_type {
		6 { .dynamic }
		0 { .null_section }
		7 { .note }
		4, 9 { .relocation }
		3 { .string_table }
		2, 11 { .symbol_table }
		else { .section }
	}
}

pub fn (kind SectionKind) class_name() string {
	return match kind {
		.section { 'Section' }
		.dynamic { 'DynamicSection' }
		.null_section { 'NullSection' }
		.note { 'NoteSection' }
		.relocation { 'RelocationSection' }
		.string_table { 'StrTabSection' }
		.symbol_table { 'SymTabSection' }
	}
}

// Ruby method `create(header, stream, *args, **kwargs)` at line 24.
pub fn ruby_sections_l24_d1_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Section.create requires a header') }
	section_type := if args[0].type_name == 'Integer' {
		int(args[0].as_int() or { panic(err) })
	} else {
		(args[0].attribute('sh_type') or { '0' }).int()
	}
	kind := section_kind(section_type)
	return brew_runtime.structured_value(kind.class_name(), kind.class_name(), {
		'sh_type': section_type.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: # Require this file to load all sections classes.
// 4:
// 5: require 'elftools/sections/section'
// 6:
// 7: require 'elftools/sections/dynamic_section'
// 8: require 'elftools/sections/note_section'
// 9: require 'elftools/sections/null_section'
// 10: require 'elftools/sections/relocation_section'
// 11: require 'elftools/sections/str_tab_section'
// 12: require 'elftools/sections/sym_tab_section'
// 13:
// 14: module ELFTools
// 15:   # Defines different types of sections in this module.
// 16:   module Sections
// 17:     # Class methods of {Sections::Section}.
// 18:     class << Section
// 19:       # Use different class according to +header.sh_type+.
// 20:       # @param [ELFTools::Structs::ELF_Shdr] header Section header.
// 21:       # @param [#pos=, #read] stream Streaming object.
// 22:       # @return [ELFTools::Sections::Section]
// 23:       #   Return object dependes on +header.sh_type+.
// 24:       def create(header, stream, *args, **kwargs)
// 25:         klass = case header.sh_type
// 26:                 when Constants::SHT_DYNAMIC then DynamicSection
// 27:                 when Constants::SHT_NULL then NullSection
// 28:                 when Constants::SHT_NOTE then NoteSection
// 29:                 when Constants::SHT_RELA, Constants::SHT_REL then RelocationSection
// 30:                 when Constants::SHT_STRTAB then StrTabSection
// 31:                 when Constants::SHT_SYMTAB, Constants::SHT_DYNSYM then SymTabSection
// 32:                 else Section
// 33:                 end
// 34:         klass.new(header, stream, *args, **kwargs)
// 35:       end
// 36:     end
// 37:   end
// 38: end
