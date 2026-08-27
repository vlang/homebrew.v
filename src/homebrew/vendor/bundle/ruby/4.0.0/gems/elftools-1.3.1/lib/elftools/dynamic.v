module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/dynamic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `each_tags(&block)` at line 21.
pub fn ruby_dynamic_l21_d1_each_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_tags', ...args)
}

// Ruby method `tags` at line 36.
pub fn ruby_dynamic_l36_d2_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tags', ...args)
}

// Ruby method `tag_by_type(type)` at line 64.
pub fn ruby_dynamic_l64_d3_tag_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag_by_type', ...args)
}

// Ruby method `tags_by_type(type)` at line 76.
pub fn ruby_dynamic_l76_d4_tags_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tags_by_type', ...args)
}

// Ruby method `tag_at(n)` at line 93.
pub fn ruby_dynamic_l93_d5_tag_at(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag_at', ...args)
}

// Ruby method `endian` at line 108.
pub fn ruby_dynamic_l108_d6_endian(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('endian', ...args)
}

// Ruby method `str_offset` at line 113.
pub fn ruby_dynamic_l113_d7_str_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('str_offset', ...args)
}

// Ruby attr_reader `attr_reader :header` at line 120.
pub fn ruby_dynamic_l120_d8_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :stream` at line 121.
pub fn ruby_dynamic_l121_d9_stream(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stream', ...args)
}

// Ruby method `initialize(header, stream, str_offset)` at line 129.
pub fn ruby_dynamic_l129_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `value` at line 154.
pub fn ruby_dynamic_l154_d11_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `name?` at line 162.
pub fn ruby_dynamic_l162_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name?', ...args)
}

// Ruby method `name` at line 171.
pub fn ruby_dynamic_l171_d13_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module ELFTools
// 4:   # Define common methods for dynamic sections and dynamic segments.
// 5:   #
// 6:   # @note
// 7:   #   This module can only be included by {ELFTools::Sections::DynamicSection}
// 8:   #   and {ELFTools::Segments::DynamicSegment} because methods here assume some
// 9:   #   attributes exist.
// 10:   module Dynamic
// 11:     # Iterate all tags.
// 12:     #
// 13:     # @note
// 14:     #   This method assume the following methods already exist:
// 15:     #     header
// 16:     #     tag_start
// 17:     # @yieldparam [ELFTools::Dynamic::Tag] tag
// 18:     # @return [Enumerator<ELFTools::Dynamic::Tag>, Array<ELFTools::Dynamic::Tag>]
// 19:     #   If block is not given, an enumerator will be returned.
// 20:     #   Otherwise, return array of tags.
// 21:     def each_tags(&block)
// 22:       return enum_for(:each_tags) unless block_given?
// 23:
// 24:       arr = []
// 25:       0.step do |i|
// 26:         tag = tag_at(i).tap(&block)
// 27:         arr << tag
// 28:         break if tag.header.d_tag == ELFTools::Constants::DT_NULL
// 29:       end
// 30:       arr
// 31:     end
// 32:
// 33:     # Use {#tags} to get all tags.
// 34:     # @return [Array<ELFTools::Dynamic::Tag>]
// 35:     #   Array of tags.
// 36:     def tags
// 37:       @tags ||= each_tags.to_a
// 38:     end
// 39:
// 40:     # Get a tag of specific type.
// 41:     # @param [Integer, Symbol, String] type
// 42:     #   Constant value, symbol, or string of type
// 43:     #   is acceptable. See examples for more information.
// 44:     # @return [ELFTools::Dynamic::Tag] The desired tag.
// 45:     # @example
// 46:     #   dynamic = elf.segment_by_type(:dynamic)
// 47:     #   # type as integer
// 48:     #   dynamic.tag_by_type(0) # the null tag
// 49:     #   #=>  #<ELFTools::Dynamic::Tag:0x0055b5a5ecad28 @header={:d_tag=>0, :d_val=>0}>
// 50:     #   dynamic.tag_by_type(ELFTools::Constants::DT_NULL)
// 51:     #   #=>  #<ELFTools::Dynamic::Tag:0x0055b5a5ecad28 @header={:d_tag=>0, :d_val=>0}>
// 52:     #
// 53:     #   # symbol
// 54:     #   dynamic.tag_by_type(:null)
// 55:     #   #=>  #<ELFTools::Dynamic::Tag:0x0055b5a5ecad28 @header={:d_tag=>0, :d_val=>0}>
// 56:     #   dynamic.tag_by_type(:pltgot)
// 57:     #   #=> #<ELFTools::Dynamic::Tag:0x0055d3d2d91b28 @header={:d_tag=>3, :d_val=>6295552}>
// 58:     #
// 59:     #   # string
// 60:     #   dynamic.tag_by_type('null')
// 61:     #   #=>  #<ELFTools::Dynamic::Tag:0x0055b5a5ecad28 @header={:d_tag=>0, :d_val=>0}>
// 62:     #   dynamic.tag_by_type('DT_PLTGOT')
// 63:     #   #=> #<ELFTools::Dynamic::Tag:0x0055d3d2d91b28 @header={:d_tag=>3, :d_val=>6295552}>
// 64:     def tag_by_type(type)
// 65:       type = Util.to_constant(Constants::DT, type)
// 66:       each_tags.find { |tag| tag.header.d_tag == type }
// 67:     end
// 68:
// 69:     # Get tags of specific type.
// 70:     # @param [Integer, Symbol, String] type
// 71:     #   Constant value, symbol, or string of type
// 72:     #   is acceptable. See examples for more information.
// 73:     # @return [Array<ELFTools::Dynamic::Tag>] The desired tags.
// 74:     #
// 75:     # @see #tag_by_type
// 76:     def tags_by_type(type)
// 77:       type = Util.to_constant(Constants::DT, type)
// 78:       each_tags.select { |tag| tag.header.d_tag == type }
// 79:     end
// 80:
// 81:     # Get the +n+-th tag.
// 82:     #
// 83:     # Tags are lazy loaded.
// 84:     # @note
// 85:     #   This method assume the following methods already exist:
// 86:     #     header
// 87:     #     tag_start
// 88:     # @note
// 89:     #   We cannot do bound checking of +n+ here since the only way to get size
// 90:     #   of tags is calling +tags.size+.
// 91:     # @param [Integer] n The index.
// 92:     # @return [ELFTools::Dynamic::Tag] The desired tag.
// 93:     def tag_at(n)
// 94:       return if n.negative?
// 95:
// 96:       @tag_at_map ||= {}
// 97:       return @tag_at_map[n] if @tag_at_map[n]
// 98:
// 99:       dyn = Structs::ELF_Dyn.new(endian:)
// 100:       dyn.elf_class = header.elf_class
// 101:       stream.pos = tag_start + n * dyn.num_bytes
// 102:       dyn.offset = stream.pos
// 103:       @tag_at_map[n] = Tag.new(dyn.read(stream), stream, method(:str_offset))
// 104:     end
// 105:
// 106:     private
// 107:
// 108:     def endian
// 109:       header.class.self_endian
// 110:     end
// 111:
// 112:     # Get the DT_STRTAB's +d_val+ offset related to file.
// 113:     def str_offset
// 114:       # TODO: handle DT_STRTAB not exitsts.
// 115:       @str_offset ||= @offset_from_vma.call(tag_by_type(:strtab).header.d_val.to_i)
// 116:     end
// 117:
// 118:     # A tag class.
// 119:     class Tag
// 120:       attr_reader :header # @return [ELFTools::Structs::ELF_Dyn] The dynamic tag header.
// 121:       attr_reader :stream # @return [#pos=, #read] Streaming object.
// 122:
// 123:       # Instantiate a {ELFTools::Dynamic::Tag} object.
// 124:       # @param [ELF_Dyn] header The dynamic tag header.
// 125:       # @param [#pos=, #read] stream Streaming object.
// 126:       # @param [Method] str_offset
// 127:       #   Call this method to get the string offset related
// 128:       #   to file.
// 129:       def initialize(header, stream, str_offset)
// 130:         @header = header
// 131:         @stream = stream
// 132:         @str_offset = str_offset
// 133:       end
// 134:
// 135:       # Some dynamic have name.
// 136:       TYPE_WITH_NAME = [Constants::DT_NEEDED,
// 137:                         Constants::DT_SONAME,
// 138:                         Constants::DT_RPATH,
// 139:                         Constants::DT_RUNPATH].freeze
// 140:       # Return the content of this tag records.
// 141:       #
// 142:       # For normal tags, this method just return
// 143:       # +header.d_val+. For tags with +header.d_val+
// 144:       # in meaning of string offset (e.g. DT_NEEDED), this method would
// 145:       # return the string it specified.
// 146:       # Tags with type in {TYPE_WITH_NAME} are those tags with name.
// 147:       # @return [Integer, String] The content this tag records.
// 148:       # @example
// 149:       #   dynamic = elf.segment_by_type(:dynamic)
// 150:       #   dynamic.tag_by_type(:init).value
// 151:       #   #=> 4195600 # 0x400510
// 152:       #   dynamic.tag_by_type(:needed).value
// 153:       #   #=> 'libc.so.6'
// 154:       def value
// 155:         name || header.d_val.to_i
// 156:       end
// 157:
// 158:       # Is this tag has a name?
// 159:       #
// 160:       # The criteria here is if this tag's type is in {TYPE_WITH_NAME}.
// 161:       # @return [Boolean] Is this tag has a name.
// 162:       def name?
// 163:         TYPE_WITH_NAME.include?(header.d_tag)
// 164:       end
// 165:
// 166:       # Return the name of this tag.
// 167:       #
// 168:       # Only tags with name would return a name.
// 169:       # Others would return +nil+.
// 170:       # @return [String, nil] The name.
// 171:       def name
// 172:         return nil unless name?
// 173:
// 174:         Util.cstring(stream, @str_offset.call + header.d_val.to_i)
// 175:       end
// 176:     end
// 177:   end
// 178: end
