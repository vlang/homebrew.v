module elftools

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/dynamic.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct DynamicTagHeader {
pub:
	d_tag i64
	d_val i64
}

pub struct DynamicTag {
pub:
	header     DynamicTagHeader
	stream     []u8
	str_offset int
}

pub struct DynamicTable {
pub:
	stream     []u8
	tag_start  int
	elf_class  int = 64
	endian     ElfEndian
	str_offset int
}

pub fn (tag DynamicTag) has_name() bool {
	return tag.header.d_tag in [i64(1), 14, 15, 29]
}

pub fn (tag DynamicTag) name() ?string {
	if !tag.has_name() {
		return none
	}
	return cstring(tag.stream, tag.str_offset + int(tag.header.d_val))
}

pub fn (tag DynamicTag) value() brew_runtime.Value {
	if name := tag.name() {
		return brew_runtime.string_value(name)
	}
	return brew_runtime.int_value(tag.header.d_val)
}

fn read_dynamic_u64(data []u8, offset int, endian ElfEndian) !u64 {
	if offset < 0 || offset + 8 > data.len {
		return error('truncated ELF dynamic tag at offset ${offset}')
	}
	mut result := u64(0)
	match endian {
		.little {
			for index in 0 .. 8 {
				result |= u64(data[offset + index]) << u32(index * 8)
			}
		}
		.big {
			for index in 0 .. 8 {
				result = (result << 8) | u64(data[offset + index])
			}
		}
	}
	return result
}

pub fn (table DynamicTable) tag_at(index int) ?DynamicTag {
	if index < 0 {
		return none
	}
	entry_size := if table.elf_class == 32 { 8 } else { 16 }
	offset := table.tag_start + index * entry_size
	if offset < 0 || offset + entry_size > table.stream.len {
		return none
	}
	header := if table.elf_class == 32 {
		DynamicTagHeader{
			d_tag: i64(i32(read_note_u32(table.stream, offset, table.endian) or { return none }))
			d_val: i64(read_note_u32(table.stream, offset + 4, table.endian) or { return none })
		}
	} else {
		DynamicTagHeader{
			d_tag: i64(read_dynamic_u64(table.stream, offset, table.endian) or { return none })
			d_val: i64(read_dynamic_u64(table.stream, offset + 8, table.endian) or { return none })
		}
	}
	return DynamicTag{
		header: header
		stream: table.stream.clone()
		str_offset: table.str_offset
	}
}

pub fn (table DynamicTable) each_tag(on_tag fn(DynamicTag)) ![]DynamicTag {
	mut tags := []DynamicTag{}
	mut index := 0
	for {
		tag := table.tag_at(index) or { return error('ELF dynamic table has no DT_NULL terminator') }
		tags << tag
		on_tag(tag)
		if tag.header.d_tag == 0 {
			break
		}
		index++
	}
	return tags
}

fn ignore_dynamic_tag(_ DynamicTag) {}

pub fn (table DynamicTable) tags() ![]DynamicTag {
	return table.each_tag(ignore_dynamic_tag)
}

pub fn dynamic_tag_constant(value brew_runtime.Value) !i64 {
	if value.type_name == 'Integer' {
		return value.as_int()
	}
	mut name := value.as_string().trim_left(':').to_upper()
	if !name.starts_with('DT_') {
		name = 'DT_${name}'
	}
	constants := {
		'DT_NULL':            i64(0)
		'DT_NEEDED':          i64(1)
		'DT_PLTRELSZ':        i64(2)
		'DT_PLTGOT':          i64(3)
		'DT_HASH':            i64(4)
		'DT_STRTAB':          i64(5)
		'DT_SYMTAB':          i64(6)
		'DT_RELA':            i64(7)
		'DT_RELASZ':          i64(8)
		'DT_RELAENT':         i64(9)
		'DT_STRSZ':           i64(10)
		'DT_SYMENT':          i64(11)
		'DT_INIT':            i64(12)
		'DT_FINI':            i64(13)
		'DT_SONAME':          i64(14)
		'DT_RPATH':           i64(15)
		'DT_SYMBOLIC':        i64(16)
		'DT_REL':             i64(17)
		'DT_RELSZ':           i64(18)
		'DT_RELENT':          i64(19)
		'DT_PLTREL':          i64(20)
		'DT_DEBUG':           i64(21)
		'DT_TEXTREL':         i64(22)
		'DT_JMPREL':          i64(23)
		'DT_BIND_NOW':        i64(24)
		'DT_INIT_ARRAY':      i64(25)
		'DT_FINI_ARRAY':      i64(26)
		'DT_INIT_ARRAYSZ':    i64(27)
		'DT_FINI_ARRAYSZ':    i64(28)
		'DT_RUNPATH':         i64(29)
		'DT_FLAGS':           i64(30)
		'DT_ENCODING':        i64(32)
		'DT_PREINIT_ARRAY':   i64(32)
		'DT_PREINIT_ARRAYSZ': i64(33)
		'DT_SYMTAB_SHNDX':    i64(34)
		'DT_RELRSZ':          i64(35)
		'DT_RELR':            i64(36)
		'DT_RELRENT':         i64(37)
		'DT_GNU_HASH':        i64(0x6ffffef5)
		'DT_VERSYM':          i64(0x6ffffff0)
		'DT_RELACOUNT':       i64(0x6ffffff9)
		'DT_RELCOUNT':        i64(0x6ffffffa)
		'DT_FLAGS_1':         i64(0x6ffffffb)
		'DT_VERDEF':          i64(0x6ffffffc)
		'DT_VERDEFNUM':       i64(0x6ffffffd)
		'DT_VERNEED':         i64(0x6ffffffe)
		'DT_VERNEEDNUM':      i64(0x6fffffff)
		'DT_AUXILIARY':       i64(0x7ffffffd)
		'DT_USED':            i64(0x7ffffffe)
		'DT_FILTER':          i64(0x7ffffffe)
	}
	if name !in constants {
		return error('No constants in DT named "${name}"')
	}
	return constants[name]
}

pub fn (table DynamicTable) tag_by_type(tag_type i64) ?DynamicTag {
	for tag in table.tags() or { return none } {
		if tag.header.d_tag == tag_type {
			return tag
		}
	}
	return none
}

pub fn (table DynamicTable) tags_by_type(tag_type i64) ![]DynamicTag {
	return table.tags()!.filter(it.header.d_tag == tag_type)
}

pub fn (table DynamicTable) string_table_file_offset(offset_from_vma fn(i64) i64) !i64 {
	strtab := table.tag_by_type(5) or { return error('ELF dynamic table has no DT_STRTAB tag') }
	return offset_from_vma(strtab.header.d_val)
}

fn dynamic_table_from_value(value brew_runtime.Value) DynamicTable {
	return DynamicTable{
		stream: (value.attribute('stream') or { '' }).bytes()
		tag_start: (value.attribute('tag_start') or { '0' }).int()
		elf_class: (value.attribute('elf_class') or { '64' }).int()
		endian: elf_endian(value.attribute('endian') or { 'little' })
		str_offset: (value.attribute('str_offset') or { '0' }).int()
	}
}

fn dynamic_tag_value(tag DynamicTag, endian ElfEndian) brew_runtime.Value {
	return brew_runtime.structured_value('ELFTools::Dynamic::Tag', '', {
		'd_tag':      tag.header.d_tag.str()
		'd_val':      tag.header.d_val.str()
		'stream':     tag.stream.bytestr()
		'str_offset': tag.str_offset.str()
		'endian':     endian.str()
	})
}

fn dynamic_tag_from_value(value brew_runtime.Value) DynamicTag {
	return DynamicTag{
		header: DynamicTagHeader{
			d_tag: (value.attribute('d_tag') or { '0' }).i64()
			d_val: (value.attribute('d_val') or { '0' }).i64()
		}
		stream: (value.attribute('stream') or { '' }).bytes()
		str_offset: (value.attribute('str_offset') or { '0' }).int()
	}
}

// Ruby method `each_tags(&block)` at line 21.
pub fn ruby_dynamic_l21_d1_each_tags(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic#each_tags requires a receiver') }
	table := dynamic_table_from_value(args[0])
	return brew_runtime.array_value((table.tags() or { panic(err) }).map(dynamic_tag_value(it, table.endian)))
}

// Ruby method `tags` at line 36.
pub fn ruby_dynamic_l36_d2_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_dynamic_l21_d1_each_tags(...args)
}

// Ruby method `tag_by_type(type)` at line 64.
pub fn ruby_dynamic_l64_d3_tag_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFTools::Dynamic#tag_by_type requires a receiver and type') }
	table := dynamic_table_from_value(args[0])
	tag_type := dynamic_tag_constant(args[1]) or { panic(err) }
	tag := table.tag_by_type(tag_type) or { return brew_runtime.object_value('NilClass', 'nil') }
	return dynamic_tag_value(tag, table.endian)
}

// Ruby method `tags_by_type(type)` at line 76.
pub fn ruby_dynamic_l76_d4_tags_by_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFTools::Dynamic#tags_by_type requires a receiver and type') }
	table := dynamic_table_from_value(args[0])
	tag_type := dynamic_tag_constant(args[1]) or { panic(err) }
	return brew_runtime.array_value((table.tags_by_type(tag_type) or { panic(err) }).map(dynamic_tag_value(it, table.endian)))
}

// Ruby method `tag_at(n)` at line 93.
pub fn ruby_dynamic_l93_d5_tag_at(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ELFTools::Dynamic#tag_at requires a receiver and index') }
	table := dynamic_table_from_value(args[0])
	tag := table.tag_at(int(args[1].as_int() or { panic(err) })) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return dynamic_tag_value(tag, table.endian)
}

// Ruby method `endian` at line 108.
pub fn ruby_dynamic_l108_d6_endian(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic#endian requires a receiver') }
	return brew_runtime.string_value(args[0].attribute('endian') or { 'little' })
}

// Ruby method `str_offset` at line 113.
pub fn ruby_dynamic_l113_d7_str_offset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic#str_offset requires a receiver') }
	if offset := args[0].attribute('str_offset') {
		return brew_runtime.int_value(offset.i64())
	}
	table := dynamic_table_from_value(args[0])
	delta := (args[0].attribute('offset_from_vma_delta') or { '0' }).i64()
	return brew_runtime.int_value(table.string_table_file_offset(fn [delta] (vma i64) i64 {
		return vma + delta
	}) or { panic(err) })
}

// Ruby attr_reader `attr_reader :header` at line 120.
pub fn ruby_dynamic_l120_d8_header(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic::Tag#header requires a receiver') }
	header := dynamic_tag_from_value(args[0]).header
	return brew_runtime.structured_value('ELF_Dyn', '', {
		'd_tag': header.d_tag.str()
		'd_val': header.d_val.str()
	})
}

// Ruby attr_reader `attr_reader :stream` at line 121.
pub fn ruby_dynamic_l121_d9_stream(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic::Tag#stream requires a receiver') }
	return brew_runtime.string_value(args[0].attribute('stream') or { panic('dynamic tag has no stream') })
}

// Ruby method `initialize(header, stream, str_offset)` at line 129.
pub fn ruby_dynamic_l129_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('ELFTools::Dynamic::Tag#initialize requires header, stream, and string offset')
	}
	tag := DynamicTag{
		header: DynamicTagHeader{
			d_tag: (args[0].attribute('d_tag') or { panic('header has no d_tag') }).i64()
			d_val: (args[0].attribute('d_val') or { panic('header has no d_val') }).i64()
		}
		stream: args[1].as_string().bytes()
		str_offset: int(args[2].as_int() or { panic(err) })
	}
	return dynamic_tag_value(tag, .little)
}

// Ruby method `value` at line 154.
pub fn ruby_dynamic_l154_d11_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic::Tag#value requires a receiver') }
	return dynamic_tag_from_value(args[0]).value()
}

// Ruby method `name?` at line 162.
pub fn ruby_dynamic_l162_d12_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic::Tag#name? requires a receiver') }
	return brew_runtime.bool_value(dynamic_tag_from_value(args[0]).has_name())
}

// Ruby method `name` at line 171.
pub fn ruby_dynamic_l171_d13_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ELFTools::Dynamic::Tag#name requires a receiver') }
	name := dynamic_tag_from_value(args[0]).name() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(name)
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
