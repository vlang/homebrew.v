module macho

import ruby
import encoding.binary

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/structure.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum MachoStructureFieldType {
	string
	null_padded_string
	int32
	uint32
	uint64
	view
	lcstr
	two_level_hints_table
	tool_entries
}

pub enum MachoStructureReaderKind {
	plain
	class_value
	masked
	unpacked
	default_value
}

pub enum MachoStructureValueKind {
	signed_integer
	unsigned_integer
	string
	array
	object
	nil_value
}

pub struct MachoStructureValue {
pub:
	kind           MachoStructureValueKind
	signed_value   i64
	unsigned_value u64
	string_value   string
	boundary_value ruby.Value
}

pub struct MachoStructureFieldOptions {
pub:
	size           int
	has_size       bool
	mask           u64
	has_mask       bool
	unpack_format  string
	has_unpack     bool
	default_value  ruby.Value
	has_default    bool
	to_string      bool
	endianness     string
	has_endianness bool
	null_padding   bool
}

pub struct MachoStructureField {
pub:
	name          string
	field_type    MachoStructureFieldType
	index         int
	size          int
	has_size      bool
	format_code   string
	reader_kind   MachoStructureReaderKind
	mask          u64
	unpack_format string
	default_value ruby.Value
}

@[heap]
pub struct MachoStructureDefinition {
pub mut:
	name               string
	fields             []MachoStructureField
	field_indexes      map[string]int
	min_args           int
	to_string_field    string
	format_cache       string
	format_is_cached   bool
	bytesize_cache     int
	bytesize_is_cached bool
}

@[heap]
pub struct MachoStructure {
pub:
	definition &MachoStructureDefinition
	values     []MachoStructureValue
mut:
	cached_values map[string]MachoStructureValue
}

pub fn new_macho_structure_definition(name string) &MachoStructureDefinition {
	return &MachoStructureDefinition{
		name: name
		field_indexes: map[string]int{}
	}
}

pub fn inherit_macho_structure_definition(parent &MachoStructureDefinition, name string) &MachoStructureDefinition {
	return &MachoStructureDefinition{
		name: name
		fields: parent.fields.clone()
		field_indexes: parent.field_indexes.clone()
		min_args: parent.min_args
		to_string_field: parent.to_string_field
	}
}

fn structure_field_type(name string) !MachoStructureFieldType {
	return match name.trim_left(':') {
		'string' { .string }
		'null_padded_string' { .null_padded_string }
		'int32' { .int32 }
		'uint32' { .uint32 }
		'uint64' { .uint64 }
		'view' { .view }
		'lcstr' { .lcstr }
		'two_level_hints_table' { .two_level_hints_table }
		'tool_entries' { .tool_entries }
		else {
			return error('Invalid field type ${name.trim_left(':')}')
		}
	}
}

fn structure_field_base_size(field_type MachoStructureFieldType) ?int {
	return match field_type {
		.int32, .uint32, .lcstr, .tool_entries { 4 }
		.uint64 { 8 }
		.view, .two_level_hints_table { 0 }
		else { none }
	}
}

fn structure_field_format(field_type MachoStructureFieldType) string {
	return match field_type {
		.string { 'a' }
		.null_padded_string { 'Z' }
		.int32 { 'l=' }
		.uint32, .lcstr, .tool_entries { 'L=' }
		.uint64 { 'Q=' }
		.view, .two_level_hints_table { '' }
	}
}

fn structure_class_field(field_type MachoStructureFieldType) bool {
	return field_type in [.lcstr, .tool_entries, .two_level_hints_table]
}

fn structure_no_argument_field(field_type MachoStructureFieldType) bool {
	return field_type == .two_level_hints_table
}

fn specialize_structure_format(format string, endianness string) string {
	modifier := if endianness.trim_left(':') == 'big' { '>' } else { '<' }
	return format.replace('=', modifier)
}

pub fn (mut definition MachoStructureDefinition) add_field(name string, requested_type MachoStructureFieldType, options MachoStructureFieldOptions) ! {
	mut index := definition.field_indexes[name] or { -1 }
	if index < 0 {
		index = definition.fields.len
		definition.field_indexes[name] = index
		if !options.has_default && !structure_no_argument_field(requested_type) {
			definition.min_args++
		}
		definition.fields << MachoStructureField{}
	}
	field_type := if requested_type == .string && options.null_padding {
		MachoStructureFieldType.null_padded_string
	} else {
		requested_type
	}
	mut size := 0
	mut has_size := false
	if base_size := structure_field_base_size(field_type) {
		size = base_size
		has_size = true
	} else if options.has_size {
		size = options.size
		has_size = true
	}
	mut format_code := structure_field_format(field_type)
	if options.has_endianness {
		format_code = specialize_structure_format(format_code, options.endianness)
	}
	if options.has_size {
		format_code += options.size.str()
	}
	reader_kind := if structure_class_field(field_type) {
		MachoStructureReaderKind.class_value
	} else if options.has_mask {
		MachoStructureReaderKind.masked
	} else if options.has_unpack {
		MachoStructureReaderKind.unpacked
	} else if options.has_default {
		MachoStructureReaderKind.default_value
	} else {
		MachoStructureReaderKind.plain
	}
	definition.fields[index] = MachoStructureField{
		name: name
		field_type: field_type
		index: index
		size: size
		has_size: has_size
		format_code: format_code
		reader_kind: reader_kind
		mask: options.mask
		unpack_format: options.unpack_format
		default_value: options.default_value
	}
	if options.to_string {
		definition.to_string_field = name
	}
}

pub fn (mut definition MachoStructureDefinition) define_class_reader(name string, field_type MachoStructureFieldType, index int) ! {
	definition.update_reader(name, index, .class_value, 0, '', ruby.Value{}, field_type)!
}

pub fn (mut definition MachoStructureDefinition) define_mask_reader(name string, index int, mask u64) ! {
	definition.update_reader(name, index, .masked, mask, '', ruby.Value{}, .uint32)!
}

pub fn (mut definition MachoStructureDefinition) define_unpack_reader(name string, index int, unpack_format string) ! {
	definition.update_reader(name, index, .unpacked, 0, unpack_format, ruby.Value{}, .string)!
}

pub fn (mut definition MachoStructureDefinition) define_default_reader(name string, index int, default_value ruby.Value) ! {
	definition.update_reader(name, index, .default_value, 0, '', default_value, .string)!
}

pub fn (mut definition MachoStructureDefinition) define_reader(name string, index int) ! {
	definition.update_reader(name, index, .plain, 0, '', ruby.Value{}, .string)!
}

fn (mut definition MachoStructureDefinition) update_reader(name string, index int, reader_kind MachoStructureReaderKind, mask u64, unpack_format string, default_value ruby.Value, field_type MachoStructureFieldType) ! {
	if index < 0 || index >= definition.fields.len {
		return error('field index ${index} is out of range')
	}
	current := definition.fields[index]
	if current.name != name {
		return error('field ${name} is not at index ${index}')
	}
	definition.fields[index] = MachoStructureField{
		...current
		field_type: if reader_kind == .class_value { field_type } else { current.field_type }
		reader_kind: reader_kind
		mask: mask
		unpack_format: unpack_format
		default_value: default_value
	}
}

pub fn (mut definition MachoStructureDefinition) define_to_string(name string) ! {
	if name !in definition.field_indexes {
		return error('unknown field ${name}')
	}
	definition.to_string_field = name
}

pub fn (mut definition MachoStructureDefinition) format() string {
	if !definition.format_is_cached {
		definition.format_cache = definition.fields.map(it.format_code).join('')
		definition.format_is_cached = true
	}
	return definition.format_cache
}

pub fn (mut definition MachoStructureDefinition) bytesize() !int {
	if !definition.bytesize_is_cached {
		mut total := 0
		for field in definition.fields {
			if !field.has_size {
				return error('field ${field.name} requires a size')
			}
			total += field.size
		}
		definition.bytesize_cache = total
		definition.bytesize_is_cached = true
	}
	return definition.bytesize_cache
}

fn structure_value_from_boundary(value ruby.Value) MachoStructureValue {
	return match value.type_name {
		'Integer' {
			MachoStructureValue{
				kind: .signed_integer
				signed_value: value.int_data
			}
		}
		'String', 'Symbol' {
			MachoStructureValue{
				kind: .string
				string_value: value.repr
			}
		}
		'Array' {
			MachoStructureValue{
				kind: .array
				boundary_value: value
			}
		}
		'NilClass' {
			MachoStructureValue{
				kind: .nil_value
				boundary_value: value
			}
		}
		else {
			MachoStructureValue{
				kind: .object
				boundary_value: value
			}
		}
	}
}

fn signed_structure_value(value i64) MachoStructureValue {
	return MachoStructureValue{
		kind: .signed_integer
		signed_value: value
	}
}

fn unsigned_structure_value(value u64) MachoStructureValue {
	return MachoStructureValue{
		kind: .unsigned_integer
		unsigned_value: value
	}
}

fn string_structure_value(value string) MachoStructureValue {
	return MachoStructureValue{
		kind: .string
		string_value: value
	}
}

pub fn (value MachoStructureValue) to_boundary() ruby.Value {
	return match value.kind {
		.signed_integer { ruby.int_value(value.signed_value) }
		.unsigned_integer {
			ruby.Value{
				type_name: 'Integer'
				repr: value.unsigned_value.str()
				int_data: i64(value.unsigned_value)
			}
		}
		.string { ruby.string_value(value.string_value) }
		else { value.boundary_value }
	}
}

fn (value MachoStructureValue) integer() !i64 {
	return match value.kind {
		.signed_integer { value.signed_value }
		.unsigned_integer { i64(value.unsigned_value) }
		else { error('expected Integer field value') }
	}
}

pub fn new_macho_structure(definition &MachoStructureDefinition, values []MachoStructureValue) !&MachoStructure {
	if values.len < definition.min_args {
		return error('Invalid number of arguments')
	}
	return &MachoStructure{
		definition: definition
		values: values.clone()
		cached_values: map[string]MachoStructureValue{}
	}
}

pub fn new_macho_structure_from_values(definition &MachoStructureDefinition, values []ruby.Value) !&MachoStructure {
	return new_macho_structure(definition, values.map(structure_value_from_boundary(it)))
}

fn unpack_numeric(bytes []u8, width int, big_endian bool) u64 {
	if width == 1 {
		return u64(bytes[0])
	}
	if width == 4 {
		return if big_endian {
			u64(binary.big_endian_u32(bytes))
		} else {
			u64(binary.little_endian_u32(bytes))
		}
	}
	return if big_endian { binary.big_endian_u64(bytes) } else { binary.little_endian_u64(bytes) }
}

fn unpack_structure_values(data []u8, format string) ![]MachoStructureValue {
	mut values := []MachoStructureValue{}
	mut format_offset := 0
	mut data_offset := 0
	for format_offset < format.len {
		directive := format[format_offset]
		format_offset++
		if directive in [` `, `\t`, `\r`, `\n`] {
			continue
		}
		mut big_endian := false
		if format_offset < format.len && format[format_offset] in [`>`, `<`, `=`] {
			big_endian = format[format_offset] == `>`
			format_offset++
		}
		mut count := 0
		for format_offset < format.len && format[format_offset] >= `0` && format[format_offset] <= `9` {
			count = count * 10 + int(format[format_offset] - `0`)
			format_offset++
		}
		if count == 0 {
			count = 1
		}
		if directive == `a` || directive == `Z` {
			if data_offset + count > data.len {
				return error('binary string is too short for format ${format}')
			}
			mut slice := data[data_offset..data_offset + count].clone()
			data_offset += count
			if directive == `Z` {
				null_index := slice.index(u8(0))
				if null_index >= 0 {
					slice = slice[..null_index].clone()
				}
			}
			values << string_structure_value(slice.bytestr())
			continue
		}
		width := match directive {
			`C` { 1 }
			`l`, `L` { 4 }
			`Q` { 8 }
			else {
				return error('unsupported unpack directive ${directive.ascii_str()}')
			}
		}
		for _ in 0 .. count {
			if data_offset + width > data.len {
				return error('binary string is too short for format ${format}')
			}
			number := unpack_numeric(data[data_offset..data_offset + width], width, big_endian)
			data_offset += width
			if directive == `l` {
				values << signed_structure_value(i64(i32(u32(number))))
			} else {
				values << unsigned_structure_value(number)
			}
		}
	}
	return values
}

pub fn new_macho_structure_from_binary(mut definition MachoStructureDefinition, endianness string, data []u8) !&MachoStructure {
	format := specialize_structure_format(definition.format(), endianness)
	return new_macho_structure(definition, unpack_structure_values(data, format)!)
}

fn (structure &MachoStructure) raw_value(index int) !MachoStructureValue {
	if index < 0 || index >= structure.values.len {
		return error('field value at index ${index} is missing')
	}
	return structure.values[index]
}

fn unpack_reader_value(value MachoStructureValue, format string) !MachoStructureValue {
	if value.kind != .string {
		return error('unpack reader requires a String field')
	}
	items := unpack_structure_values(value.string_value.bytes(), format)!
	return MachoStructureValue{
		kind: .array
		boundary_value: ruby.array_value(items.map(it.to_boundary()))
	}
}

fn (mut structure MachoStructure) class_reader_value(field MachoStructureField) !MachoStructureValue {
	mut attributes := {
		'structure_address': u64(voidptr(structure)).str()
		'field':             field.name
	}
	return match field.field_type {
		.lcstr {
			raw := structure.raw_value(field.index)!
			attributes['offset'] = raw.integer()!.str()
			structure_value_from_boundary(ruby.structured_value('MachO::LoadCommands::LoadCommand::LCStr', '#<MachO::LCStr offset=${attributes['offset']}>', attributes))
		}
		.two_level_hints_table {
			attributes['view'] = structure.field_value('view')!.to_boundary().repr
			attributes['htoffset'] = structure.field_value('htoffset')!.integer()!.str()
			attributes['nhints'] = structure.field_value('nhints')!.integer()!.str()
			structure_value_from_boundary(ruby.structured_value('MachO::LoadCommands::TwolevelHintsCommand::TwolevelHintsTable', '#<MachO::TwolevelHintsTable>', attributes))
		}
		.tool_entries {
			raw := structure.raw_value(field.index)!
			attributes['view'] = structure.field_value('view')!.to_boundary().repr
			attributes['count'] = raw.integer()!.str()
			structure_value_from_boundary(ruby.structured_value('MachO::LoadCommands::BuildVersionCommand::ToolEntries', '#<MachO::ToolEntries count=${attributes['count']}>', attributes))
		}
		else {
			return error('field ${field.name} is not a class field')
		}
	}
}

pub fn (mut structure MachoStructure) field_value(name string) !MachoStructureValue {
	index := structure.definition.field_indexes[name] or { return error('unknown field ${name}') }
	field := structure.definition.fields[index]
	if field.reader_kind == .plain {
		return structure.raw_value(index)
	}
	if cached := structure.cached_values[name] {
		return cached
	}
	value := match field.reader_kind {
		.class_value { structure.class_reader_value(field)! }
		.masked {
			raw := structure.raw_value(index)!
			signed_structure_value(raw.integer()! & ~i64(field.mask))
		}
		.unpacked { unpack_reader_value(structure.raw_value(index)!, field.unpack_format)! }
		.default_value {
			if index < structure.values.len {
				structure.values[index]
			} else {
				structure_value_from_boundary(field.default_value)
			}
		}
		.plain { structure.raw_value(index)! }
	}
	structure.cached_values[name] = value
	return value
}

pub fn (mut structure MachoStructure) to_string() !string {
	if structure.definition.to_string_field.len == 0 {
		return '#<${structure.definition.name}>'
	}
	return structure.field_value(structure.definition.to_string_field)!.to_boundary().repr
}

pub fn (mut structure MachoStructure) to_hash() !map[string]ruby.Value {
	mut definition := structure.definition
	return {
		'structure': ruby.map_value({
			'format':   ruby.string_value(definition.format())
			'bytesize': ruby.int_value(definition.bytesize()!)
		})
	}
}

fn macho_structure_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn macho_structure_definition_boundary(definition &MachoStructureDefinition) ruby.Value {
	return ruby.structured_value('Class', definition.name, {
		'macho_structure_definition_address': u64(voidptr(definition)).str()
	})
}

pub fn macho_structure_boundary(structure &MachoStructure) ruby.Value {
	return ruby.structured_value(structure.definition.name, '#<${structure.definition.name}>', {
		'macho_structure_address': u64(voidptr(structure)).str()
	})
}

fn macho_structure_definition_from_value(value ruby.Value) &MachoStructureDefinition {
	address := (value.attribute('macho_structure_definition_address') or { panic(err) }).u64()
	return unsafe { &MachoStructureDefinition(voidptr(address)) }
}

fn macho_structure_from_value(value ruby.Value) &MachoStructure {
	address := (value.attribute('macho_structure_address') or { panic(err) }).u64()
	return unsafe { &MachoStructure(voidptr(address)) }
}

fn structure_field_options_from_value(value ruby.Value) MachoStructureFieldOptions {
	options := value.as_map() or { panic(err) }
	return MachoStructureFieldOptions{
		size: int((options['size'] or { ruby.int_value(0) }).as_int() or { panic(err) })
		has_size: 'size' in options
		mask: u64((options['mask'] or { ruby.int_value(0) }).as_int() or { panic(err) })
		has_mask: 'mask' in options
		unpack_format: (options['unpack'] or { ruby.string_value('') }).as_string()
		has_unpack: 'unpack' in options
		default_value: options['default'] or { macho_structure_nil() }
		has_default: 'default' in options
		to_string: (options['to_s'] or { ruby.bool_value(false) }).as_bool() or { panic(err) }
		endianness: (options['endian'] or { ruby.string_value('') }).as_string()
		has_endianness: 'endian' in options
		null_padding: (options['padding'] or { ruby.string_value('') }).as_string().trim_left(':') == 'null'
	}
}

fn structure_dynamic_reader(args []ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('generated structure reader requires a receiver and field name')
	}
	mut structure := macho_structure_from_value(args[0])
	return structure.field_value(args[1].as_string().trim_left(':')) or { panic(err) }.to_boundary()
}

// Ruby method `initialize(*args)` at line 75.
pub fn ruby_structure_l75_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure.initialize requires a class receiver')
	}
	definition := macho_structure_definition_from_value(args[0])
	return macho_structure_boundary(new_macho_structure_from_values(definition, args[1..]) or {
		panic(err)
	})
}

// Ruby method `to_h` at line 82.
pub fn ruby_structure_l82_d2_to_h(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure#to_h requires a receiver')
	}
	mut structure := macho_structure_from_value(args[0])
	return ruby.map_value(structure.to_hash() or { panic(err) })
}

// Ruby attr_reader `attr_reader :min_args` at line 92.
pub fn ruby_structure_l92_d3_min_args(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure.min_args requires a class receiver')
	}
	return ruby.int_value(macho_structure_definition_from_value(args[0]).min_args)
}

// Ruby method `new_from_bin(endianness, bin)` at line 98.
pub fn ruby_structure_l98_d4_new_from_bin(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('MachOStructure.new_from_bin requires endianness and binary data')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	return macho_structure_boundary(new_macho_structure_from_binary(mut definition, args[1].as_string().trim_left(':'), args[2].as_string().bytes()) or { panic(err) })
}

// Ruby method `format` at line 104.
pub fn ruby_structure_l104_d5_format(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure.format requires a class receiver')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	return ruby.string_value(definition.format())
}

// Ruby method `bytesize` at line 108.
pub fn ruby_structure_l108_d6_bytesize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure.bytesize requires a class receiver')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	return ruby.int_value(definition.bytesize() or { panic(err) })
}

// Ruby method `inherited(subclass) # rubocop:disable Lint/MissingSuper` at line 116.
pub fn ruby_structure_l116_d7_inherited(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure.inherited requires a class receiver')
	}
	parent := macho_structure_definition_from_value(args[0])
	if args.len > 1 && 'macho_structure_definition_address' in args[1].attributes {
		mut subclass := macho_structure_definition_from_value(args[1])
		subclass.fields = parent.fields.clone()
		subclass.field_indexes = parent.field_indexes.clone()
		subclass.min_args = parent.min_args
		subclass.to_string_field = parent.to_string_field
		subclass.format_cache = ''
		subclass.format_is_cached = false
		subclass.bytesize_cache = 0
		subclass.bytesize_is_cached = false
		return args[1]
	}
	name := if args.len > 1 { args[1].as_string() } else { '${parent.name}::Subclass' }
	return macho_structure_definition_boundary(inherit_macho_structure_definition(parent, name))
}

// Ruby method `field(name, type, **options)` at line 144.
pub fn ruby_structure_l144_d8_field(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('MachOStructure.field requires a name and type')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	field_type := structure_field_type(args[2].as_string()) or { panic(err) }
	options := if args.len > 3 {
		structure_field_options_from_value(args[3])
	} else {
		MachoStructureFieldOptions{}
	}
	definition.add_field(args[1].as_string().trim_left(':'), field_type, options) or { panic(err) }
	return macho_structure_nil()
}

// Ruby method `def_class_reader(name, type, idx)` at line 196.
pub fn ruby_structure_l196_d9_def_class_reader(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('def_class_reader requires a name, type, and index')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_class_reader(args[1].as_string().trim_left(':'), structure_field_type(args[2].as_string()) or {
		panic(err)
	}, int(args[3].as_int() or { panic(err) })) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(name) do` at line 199.
pub fn ruby_structure_l199_d10_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby define_method `define_method(name) do` at line 206.
pub fn ruby_structure_l206_d11_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby define_method `define_method(name) do` at line 213.
pub fn ruby_structure_l213_d12_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby method `def_mask_reader(name, idx, mask)` at line 227.
pub fn ruby_structure_l227_d13_def_mask_reader(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('def_mask_reader requires a name, index, and mask')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_mask_reader(args[1].as_string().trim_left(':'), int(args[2].as_int() or {
		panic(err)
	}), u64(args[3].as_int() or { panic(err) })) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(name) do` at line 228.
pub fn ruby_structure_l228_d14_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby method `def_unpack_reader(name, idx, unpack)` at line 241.
pub fn ruby_structure_l241_d15_def_unpack_reader(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('def_unpack_reader requires a name, index, and format')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_unpack_reader(args[1].as_string().trim_left(':'), int(args[2].as_int() or {
		panic(err)
	}), args[3].as_string()) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(name) do` at line 242.
pub fn ruby_structure_l242_d16_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby method `def_default_reader(name, idx, default)` at line 255.
pub fn ruby_structure_l255_d17_def_default_reader(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('def_default_reader requires a name, index, and default')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_default_reader(args[1].as_string().trim_left(':'), int(args[2].as_int() or {
		panic(err)
	}), args[3]) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(name) do` at line 256.
pub fn ruby_structure_l256_d18_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby method `def_reader(name, idx)` at line 268.
pub fn ruby_structure_l268_d19_def_reader(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('def_reader requires a name and index')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_reader(args[1].as_string().trim_left(':'), int(args[2].as_int() or {
		panic(err)
	})) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(name) do` at line 269.
pub fn ruby_structure_l269_d20_name(args ...ruby.Value) ruby.Value {
	return structure_dynamic_reader(args)
}

// Ruby method `def_to_s(name)` at line 277.
pub fn ruby_structure_l277_d21_def_to_s(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('def_to_s requires a field name')
	}
	mut definition := macho_structure_definition_from_value(args[0])
	definition.define_to_string(args[1].as_string().trim_left(':')) or { panic(err) }
	return macho_structure_nil()
}

// Ruby define_method `define_method(:to_s) do` at line 278.
pub fn ruby_structure_l278_d22_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('MachOStructure#to_s requires a receiver')
	}
	mut structure := macho_structure_from_value(args[0])
	return ruby.string_value(structure.to_string() or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A general purpose pseudo-structure. Described in detail in machostructure-dsl-docs.md.
// 5:   # @abstract
// 6:   class MachOStructure
// 7:     # Constants used for parsing MachOStructure fields
// 8:     module Fields
// 9:       # 1. All fields with empty strings and zeros aren't used
// 10:       #    to calculate the format and sizeof variables.
// 11:       # 2. All fields with nil should provide those values manually
// 12:       #    via the :size parameter.
// 13:
// 14:       # association of field types to byte size
// 15:       # @api private
// 16:       BYTE_SIZE = {
// 17:         # Binary slices
// 18:         :string => nil,
// 19:         :null_padded_string => nil,
// 20:         :int32 => 4,
// 21:         :uint32 => 4,
// 22:         :uint64 => 8,
// 23:         # Classes
// 24:         :view => 0,
// 25:         :lcstr => 4,
// 26:         :two_level_hints_table => 0,
// 27:         :tool_entries => 4,
// 28:       }.freeze
// 29:
// 30:       # association of field types with ruby format codes
// 31:       # Binary format codes can be found here:
// 32:       # https://docs.ruby-lang.org/en/2.6.0/String.html#method-i-unpack
// 33:       #
// 34:       # The equals sign is used to manually change endianness using
// 35:       # the Utils#specialize_format() method.
// 36:       # @api private
// 37:       FORMAT_CODE = {
// 38:         # Binary slices
// 39:         :string => "a",
// 40:         :null_padded_string => "Z",
// 41:         :int32 => "l=",
// 42:         :uint32 => "L=",
// 43:         :uint64 => "Q=",
// 44:         # Classes
// 45:         :view => "",
// 46:         :lcstr => "L=",
// 47:         :two_level_hints_table => "",
// 48:         :tool_entries => "L=",
// 49:       }.freeze
// 50:
// 51:       # A list of classes that must get initialized
// 52:       # To add a new class append it here and add the init method to the def_class_reader method
// 53:       # @api private
// 54:       CLASSES_TO_INIT = %i[lcstr tool_entries two_level_hints_table].freeze
// 55:
// 56:       # A list of fields that don't require arguments in the initializer
// 57:       # Used to calculate MachOStructure#min_args
// 58:       # @api private
// 59:       NO_ARG_REQUIRED = %i[two_level_hints_table].freeze
// 60:     end
// 61:
// 62:     # map of field names to indices
// 63:     @field_idxs = {}
// 64:
// 65:     # array of fields sizes
// 66:     @size_list = []
// 67:
// 68:     # array of field format codes
// 69:     @fmt_list = []
// 70:
// 71:     # minimum number of required arguments
// 72:     @min_args = 0
// 73:
// 74:     # @param args [Array[Value]] list of field parameters
// 75:     def initialize(*args)
// 76:       raise ArgumentError, "Invalid number of arguments" if args.size < self.class.min_args
// 77:
// 78:       @values = args
// 79:     end
// 80:
// 81:     # @return [Hash] a hash representation of this {MachOStructure}.
// 82:     def to_h
// 83:       {
// 84:         "structure" => {
// 85:           "format" => self.class.format,
// 86:           "bytesize" => self.class.bytesize,
// 87:         },
// 88:       }
// 89:     end
// 90:
// 91:     class << self
// 92:       attr_reader :min_args
// 93:
// 94:       # @param endianness [Symbol] either `:big` or `:little`
// 95:       # @param bin [String] the string to be unpacked into the new structure
// 96:       # @return [MachO::MachOStructure] the resulting structure
// 97:       # @api private
// 98:       def new_from_bin(endianness, bin)
// 99:         format = Utils.specialize_format(self.format, endianness)
// 100:
// 101:         new(*bin.unpack(format))
// 102:       end
// 103:
// 104:       def format
// 105:         @format ||= @fmt_list.join
// 106:       end
// 107:
// 108:       def bytesize
// 109:         @bytesize ||= @size_list.sum
// 110:       end
// 111:
// 112:       private
// 113:
// 114:       # @param subclass [Class] subclass type
// 115:       # @api private
// 116:       def inherited(subclass) # rubocop:disable Lint/MissingSuper
// 117:         # Clone all class instance variables
// 118:         field_idxs = @field_idxs.dup
// 119:         size_list = @size_list.dup
// 120:         fmt_list = @fmt_list.dup
// 121:         min_args = @min_args.dup
// 122:
// 123:         # Add those values to the inheriting class
// 124:         subclass.class_eval do
// 125:           @field_idxs = field_idxs
// 126:           @size_list = size_list
// 127:           @fmt_list = fmt_list
// 128:           @min_args = min_args
// 129:         end
// 130:       end
// 131:
// 132:       # @param name [Symbol] name of internal field
// 133:       # @param type [Symbol] type of field in terms of binary size
// 134:       # @param options [Hash] set of additional options
// 135:       # Expected options
// 136:       #   :size [Integer] size in bytes
// 137:       #   :mask [Integer] bitmask
// 138:       #   :unpack [String] string format
// 139:       #   :default [Value] default value
// 140:       #   :to_s [Boolean] flag for generating #to_s
// 141:       #   :endian [Symbol] optionally specify :big or :little endian
// 142:       #   :padding [Symbol] optionally specify :null padding
// 143:       # @api private
// 144:       def field(name, type, **options)
// 145:         raise ArgumentError, "Invalid field type #{type}" unless Fields::FORMAT_CODE.key?(type)
// 146:
// 147:         # Get field idx for size_list and fmt_list
// 148:         idx = if @field_idxs.key?(name)
// 149:           @field_idxs[name]
// 150:         else
// 151:           @min_args += 1 unless options.key?(:default) || Fields::NO_ARG_REQUIRED.include?(type)
// 152:           @field_idxs[name] = @field_idxs.size
// 153:           @size_list << nil
// 154:           @fmt_list << nil
// 155:           @field_idxs.size - 1
// 156:         end
// 157:
// 158:         # Update string type if padding is specified
// 159:         type = :null_padded_string if type == :string && options[:padding] == :null
// 160:
// 161:         # Add to size_list and fmt_list
// 162:         @size_list[idx] = Fields::BYTE_SIZE[type] || options[:size]
// 163:         @fmt_list[idx] = if options[:endian]
// 164:           Utils.specialize_format(Fields::FORMAT_CODE[type], options[:endian])
// 165:         else
// 166:           Fields::FORMAT_CODE[type]
// 167:         end
// 168:         @fmt_list[idx] += options[:size].to_s if options.key?(:size)
// 169:
// 170:         # Generate methods
// 171:         if Fields::CLASSES_TO_INIT.include?(type)
// 172:           def_class_reader(name, type, idx)
// 173:         elsif options.key?(:mask)
// 174:           def_mask_reader(name, idx, options[:mask])
// 175:         elsif options.key?(:unpack)
// 176:           def_unpack_reader(name, idx, options[:unpack])
// 177:         elsif options.key?(:default)
// 178:           def_default_reader(name, idx, options[:default])
// 179:         else
// 180:           def_reader(name, idx)
// 181:         end
// 182:
// 183:         def_to_s(name) if options[:to_s]
// 184:       end
// 185:
// 186:       #
// 187:       # Method Generators
// 188:       #
// 189:
// 190:       # Generates a reader method for classes that need to be initialized.
// 191:       # These classes are defined in the Fields::CLASSES_TO_INIT array.
// 192:       # @param name [Symbol] name of internal field
// 193:       # @param type [Symbol] type of field in terms of binary size
// 194:       # @param idx [Integer] the index of the field value in the @values array
// 195:       # @api private
// 196:       def def_class_reader(name, type, idx)
// 197:         case type
// 198:         when :lcstr
// 199:           define_method(name) do
// 200:             instance_variable_defined?("@#{name}") ||
// 201:               instance_variable_set("@#{name}", LoadCommands::LoadCommand::LCStr.new(self, @values[idx]))
// 202:
// 203:             instance_variable_get("@#{name}")
// 204:           end
// 205:         when :two_level_hints_table
// 206:           define_method(name) do
// 207:             instance_variable_defined?("@#{name}") ||
// 208:               instance_variable_set("@#{name}", LoadCommands::TwolevelHintsCommand::TwolevelHintsTable.new(view, htoffset, nhints))
// 209:
// 210:             instance_variable_get("@#{name}")
// 211:           end
// 212:         when :tool_entries
// 213:           define_method(name) do
// 214:             instance_variable_defined?("@#{name}") ||
// 215:               instance_variable_set("@#{name}", LoadCommands::BuildVersionCommand::ToolEntries.new(view, @values[idx]))
// 216:
// 217:             instance_variable_get("@#{name}")
// 218:           end
// 219:         end
// 220:       end
// 221:
// 222:       # Generates a reader method for fields that need to be bitmasked.
// 223:       # @param name [Symbol] name of internal field
// 224:       # @param idx [Integer] the index of the field value in the @values array
// 225:       # @param mask [Integer] the bitmask
// 226:       # @api private
// 227:       def def_mask_reader(name, idx, mask)
// 228:         define_method(name) do
// 229:           instance_variable_defined?("@#{name}") ||
// 230:             instance_variable_set("@#{name}", @values[idx] & ~mask)
// 231:
// 232:           instance_variable_get("@#{name}")
// 233:         end
// 234:       end
// 235:
// 236:       # Generates a reader method for fields that need further unpacking.
// 237:       # @param name [Symbol] name of internal field
// 238:       # @param idx [Integer] the index of the field value in the @values array
// 239:       # @param unpack [String] the format code used for further binary unpacking
// 240:       # @api private
// 241:       def def_unpack_reader(name, idx, unpack)
// 242:         define_method(name) do
// 243:           instance_variable_defined?("@#{name}") ||
// 244:             instance_variable_set("@#{name}", @values[idx].unpack(unpack))
// 245:
// 246:           instance_variable_get("@#{name}")
// 247:         end
// 248:       end
// 249:
// 250:       # Generates a reader method for fields that have default values.
// 251:       # @param name [Symbol] name of internal field
// 252:       # @param idx [Integer] the index of the field value in the @values array
// 253:       # @param default [Value] the default value
// 254:       # @api private
// 255:       def def_default_reader(name, idx, default)
// 256:         define_method(name) do
// 257:           instance_variable_defined?("@#{name}") ||
// 258:             instance_variable_set("@#{name}", @values.size > idx ? @values[idx] : default)
// 259:
// 260:           instance_variable_get("@#{name}")
// 261:         end
// 262:       end
// 263:
// 264:       # Generates an attr_reader like method for a field.
// 265:       # @param name [Symbol] name of internal field
// 266:       # @param idx [Integer] the index of the field value in the @values array
// 267:       # @api private
// 268:       def def_reader(name, idx)
// 269:         define_method(name) do
// 270:           @values[idx]
// 271:         end
// 272:       end
// 273:
// 274:       # Generates the to_s method based on the named field.
// 275:       # @param name [Symbol] name of the field
// 276:       # @api private
// 277:       def def_to_s(name)
// 278:         define_method(:to_s) do
// 279:           send(name).to_s
// 280:         end
// 281:       end
// 282:     end
// 283:   end
// 284: end
