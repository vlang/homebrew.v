module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/note.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `each_notes` at line 44.
pub fn ruby_note_l44_d1_each_notes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_notes', ...args)
}

// Ruby method `notes` at line 67.
pub fn ruby_note_l67_d2_notes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notes', ...args)
}

// Ruby method `endian` at line 77.
pub fn ruby_note_l77_d3_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('endian', ...args)
}

// Ruby method `create_note(cur)` at line 81.
pub fn ruby_note_l81_d4_create_note(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_note', ...args)
}

// Ruby attr_reader `attr_reader :header` at line 88.
pub fn ruby_note_l88_d5_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 89.
pub fn ruby_note_l89_d6_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby attr_reader `attr_reader :offset` at line 90.
pub fn ruby_note_l90_d7_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offset', ...args)
}

// Ruby method `initialize(header, stream, offset)` at line 97.
pub fn ruby_note_l97_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `name` at line 105.
pub fn ruby_note_l105_d9_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `desc` at line 114.
pub fn ruby_note_l114_d10_desc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('desc', ...args)
}

// Ruby alias `alias description desc` at line 122.
pub fn ruby_note_l122_d11_description(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('description', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/structs'
// 4: require 'elftools/util'
// 5:
// 6: module ELFTools
// 7:   # Since both note sections and note segments refer to notes, this module
// 8:   # defines common methods for {ELFTools::Sections::NoteSection} and
// 9:   # {ELFTools::Segments::NoteSegment}.
// 10:   #
// 11:   # @note
// 12:   #   This module can only be included in {ELFTools::Sections::NoteSection} and
// 13:   #   {ELFTools::Segments::NoteSegment} since some methods here assume some
// 14:   #   attributes already exist.
// 15:   module Note
// 16:     # Since size of {ELFTools::Structs::ELF_Nhdr} will not change no matter in
// 17:     # what endian and what arch, we can do this here. This value should equal
// 18:     # to 12.
// 19:     SIZE_OF_NHDR = Structs::ELF_Nhdr.new(endian: :little).num_bytes
// 20:
// 21:     # Iterate all notes in a note section or segment.
// 22:     #
// 23:     # Structure of notes are:
// 24:     #   +---------------+
// 25:     #   | Note 1 header |
// 26:     #   +---------------+
// 27:     #   |  Note 1 name  |
// 28:     #   +---------------+
// 29:     #   |  Note 1 desc  |
// 30:     #   +---------------+
// 31:     #   | Note 2 header |
// 32:     #   +---------------+
// 33:     #   |      ...      |
// 34:     #   +---------------+
// 35:     #
// 36:     # @note
// 37:     #   This method assume following methods exist:
// 38:     #     stream
// 39:     #     note_start
// 40:     #     note_total_size
// 41:     # @return [Enumerator<ELFTools::Note::Note>, Array<ELFTools::Note::Note>]
// 42:     #   If block is not given, an enumerator will be returned.
// 43:     #   Otherwise, return the array of notes.
// 44:     def each_notes
// 45:       return enum_for(:each_notes) unless block_given?
// 46:
// 47:       @notes_offset_map ||= {}
// 48:       cur = note_start
// 49:       notes = []
// 50:       while cur < note_start + note_total_size
// 51:         stream.pos = cur
// 52:         @notes_offset_map[cur] ||= create_note(cur)
// 53:         note = @notes_offset_map[cur]
// 54:         # name and desc size needs to be 4-bytes align
// 55:         name_size = Util.align(note.header.n_namesz, 2)
// 56:         desc_size = Util.align(note.header.n_descsz, 2)
// 57:         cur += SIZE_OF_NHDR + name_size + desc_size
// 58:         notes << note
// 59:         yield note
// 60:       end
// 61:       notes
// 62:     end
// 63:
// 64:     # Simply +#notes+ to get all notes.
// 65:     # @return [Array<ELFTools::Note::Note>]
// 66:     #   Whole notes.
// 67:     def notes
// 68:       each_notes.to_a
// 69:     end
// 70:
// 71:     private
// 72:
// 73:     # Get the endian.
// 74:     #
// 75:     # @note This method assume method +header+ exists.
// 76:     # @return [Symbol] +:little+ or +:big+.
// 77:     def endian
// 78:       header.class.self_endian
// 79:     end
// 80:
// 81:     def create_note(cur)
// 82:       nhdr = Structs::ELF_Nhdr.new(endian:, offset: stream.pos).read(stream)
// 83:       ELFTools::Note::Note.new(nhdr, stream, cur)
// 84:     end
// 85:
// 86:     # Class of a note.
// 87:     class Note
// 88:       attr_reader :header # @return [ELFTools::Structs::ELF_Nhdr] Note header.
// 89:       attr_reader :stream # @return [#pos=, #read] Streaming object.
// 90:       attr_reader :offset # @return [Integer] Address of this note start, includes note header.
// 91:
// 92:       # Instantiate a {ELFTools::Note::Note} object.
// 93:       # @param [ELF_Nhdr] header The note header.
// 94:       # @param [#pos=, #read] stream Streaming object.
// 95:       # @param [Integer] offset
// 96:       #   Start address of this note, includes the header.
// 97:       def initialize(header, stream, offset)
// 98:         @header = header
// 99:         @stream = stream
// 100:         @offset = offset
// 101:       end
// 102:
// 103:       # Name of this note.
// 104:       # @return [String] The name.
// 105:       def name
// 106:         return @name if defined?(@name)
// 107:
// 108:         stream.pos = @offset + SIZE_OF_NHDR
// 109:         @name = stream.read(header.n_namesz)[0..-2]
// 110:       end
// 111:
// 112:       # Description of this note.
// 113:       # @return [String] The description.
// 114:       def desc
// 115:         return @desc if instance_variable_defined?(:@desc)
// 116:
// 117:         stream.pos = @offset + SIZE_OF_NHDR + Util.align(header.n_namesz, 2)
// 118:         @desc = stream.read(header.n_descsz)
// 119:       end
// 120:
// 121:       # If someone likes to use full name.
// 122:       alias description desc
// 123:     end
// 124:   end
// 125: end
