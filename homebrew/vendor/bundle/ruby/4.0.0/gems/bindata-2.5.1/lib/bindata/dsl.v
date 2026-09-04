module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/dsl.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum DSLParserType {
	struct_type
	array
	buffer
	choice
	delayed_io
	primitive
	section
	skip
}

pub enum DSLEndian {
	big
	little
	big_and_little
}

pub struct DSLParserAbility {
pub:
	converter string
	key       string
	options   []string
}

pub struct DSLHints {
pub:
	endian        ?DSLEndian
	search_prefix []string
}

@[heap]
pub struct DSLClass {
pub:
	name         string
	parser_type  DSLParserType
	method_names []string
mut:
	superclass           &DSLClass = unsafe { nil }
	has_superclass       bool
	parser_state         &DSLParser = unsafe { nil }
	has_parser           bool
	registered           bool = true
	big_endian_class     &DSLClass = unsafe { nil }
	little_endian_class  &DSLClass = unsafe { nil }
	has_endian_classes   bool
	delegate_fields      bool
	registered_types     &Registry = unsafe { nil }
	has_registered_types bool
}

pub struct DSLField {
pub:
	field_type string
	name       ruby.Value
	has_name   bool
	params     map[string]ruby.Value
}

@[heap]
pub struct DSLParser {
pub:
	the_class   &DSLClass
	parser_type DSLParserType
mut:
	endian_value               DSLEndian
	has_endian                 bool
	search_prefixes            []string
	has_search_prefix          bool
	hidden_fields              []string
	fields_value               []DSLField
	has_fields                 bool
	parent_fields_override     []DSLField
	has_parent_fields_override bool
}

@[heap]
pub struct DSLFieldParser {
pub:
	hints      DSLHints
	field_type string
	name       ruby.Value
	has_name   bool
	params     map[string]ruby.Value
}

@[heap]
pub struct DSLFieldValidator {
pub:
	the_class  &DSLClass
	dsl_parser &DSLParser
}

pub type DSLFieldBlock = fn(mut DSLParser) !

fn dsl_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn dsl_symbol_value(value string) ruby.Value {
	return ruby.object_value('Symbol', ':${value}')
}

fn dsl_symbol_name(value ruby.Value) string {
	if value.type_name == 'NilClass' {
		return ''
	}
	return value.as_string().trim_left(':')
}

fn dsl_parser_type_name(parser_type DSLParserType) string {
	return match parser_type {
		.struct_type { 'struct' }
		.array { 'array' }
		.buffer { 'buffer' }
		.choice { 'choice' }
		.delayed_io { 'delayed_io' }
		.primitive { 'primitive' }
		.section { 'section' }
		.skip { 'skip' }
	}
}

pub fn dsl_parser_type_from_name(name string) !DSLParserType {
	return match name.trim_left(':') {
		'struct' { DSLParserType.struct_type }
		'array' { DSLParserType.array }
		'buffer' { DSLParserType.buffer }
		'choice' { DSLParserType.choice }
		'delayed_io' { DSLParserType.delayed_io }
		'primitive' { DSLParserType.primitive }
		'section' { DSLParserType.section }
		'skip' { DSLParserType.skip }
		else {
			return error('unknown parser type ${name.trim_left(':')}')
		}
	}
}

fn dsl_endian_name(endian DSLEndian) string {
	return match endian {
		.big { 'big' }
		.little { 'little' }
		.big_and_little { 'big_and_little' }
	}
}

pub fn dsl_endian_from_name(name string) !DSLEndian {
	return match name.trim_left(':') {
		'big' { DSLEndian.big }
		'little' { DSLEndian.little }
		'big_and_little' { DSLEndian.big_and_little }
		else {
			return error("unknown value for endian '${name.trim_left(':')}'")
		}
	}
}

pub fn dsl_parser_abilities() map[DSLParserType]DSLParserAbility {
	return {
		.struct_type: DSLParserAbility{'to_struct_params', 'struct', ['multiple_fields',
			'optional_fieldnames', 'hidden_fields']}
		.array:       DSLParserAbility{'to_object_params', 'type', ['multiple_fields',
			'optional_fieldnames']}
		.buffer:      DSLParserAbility{'to_object_params', 'type', ['multiple_fields',
			'optional_fieldnames', 'hidden_fields']}
		.choice:      DSLParserAbility{'to_choice_params', 'choices', [
			'multiple_fields',
			'all_or_none_fieldnames',
			'fieldnames_are_values',
		]}
		.delayed_io:  DSLParserAbility{'to_object_params', 'type', ['multiple_fields',
			'optional_fieldnames', 'hidden_fields']}
		.primitive:   DSLParserAbility{'to_struct_params', 'struct', ['multiple_fields',
			'optional_fieldnames']}
		.section:     DSLParserAbility{'to_object_params', 'type', ['multiple_fields',
			'optional_fieldnames']}
		.skip:        DSLParserAbility{'to_object_params', 'until_valid', [
			'multiple_fields',
			'optional_fieldnames',
		]}
	}
}

pub fn new_dsl_class(name string, parser_type DSLParserType) &DSLClass {
	mut registry := new_registered_classes_registry()
	return &DSLClass{
		name: name
		parser_type: parser_type
		method_names: dsl_default_method_names()
		registered_types: &registry
		has_registered_types: true
	}
}

pub fn new_dsl_subclass(name string, mut superclass DSLClass) &DSLClass {
	return &DSLClass{
		name: name
		parser_type: superclass.parser_type
		method_names: dsl_unique_names(dsl_default_method_names(), superclass.method_names)
		superclass: &superclass
		has_superclass: true
		registered_types: superclass.registered_types
		has_registered_types: superclass.has_registered_types
	}
}

pub fn new_dsl_parser(mut the_class DSLClass, parser_type DSLParserType) !&DSLParser {
	if parser_type !in dsl_parser_abilities() {
		return error('unknown parser type ${dsl_parser_type_name(parser_type)}')
	}
	return &DSLParser{
		the_class: &the_class
		parser_type: parser_type
	}
}

pub fn dsl_parser_for_class(mut the_class DSLClass, parser_type ?DSLParserType) !&DSLParser {
	if the_class.has_parser {
		return the_class.parser_state
	}
	actual := parser_type or { the_class.parser_type }
	parser := new_dsl_parser(mut the_class, actual)!
	the_class.parser_state = parser
	the_class.has_parser = true
	return parser
}

fn dsl_class_value(the_class &DSLClass) ruby.Value {
	mut data := map[string]ruby.Value{}
	if the_class.has_superclass {
		data['superclass'] = dsl_class_value(the_class.superclass)
	}
	return ruby.Value{
		type_name: 'BinData::Class'
		repr: the_class.name
		int_data: i64(u64(voidptr(the_class)))
		map_data: data
		attributes: {
			'dsl_class_address': u64(voidptr(the_class)).str()
			'parser_type':       dsl_parser_type_name(the_class.parser_type)
			'method_names':      the_class.method_names.join(',')
			'registered':        the_class.registered.str()
		}
	}
}

pub fn dsl_class_boundary_value(the_class &DSLClass) ruby.Value {
	return dsl_class_value(the_class)
}

fn dsl_class_from_value(value ruby.Value) &DSLClass {
	if address := value.attributes['dsl_class_address'] {
		actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
		return unsafe { &DSLClass(voidptr(actual)) }
	}
	parser_type := dsl_parser_type_from_name(value.attributes['parser_type'] or {
		value.attributes['arg_processor'] or { 'struct' }
	}) or { DSLParserType.struct_type }
	return &DSLClass{
		name: value.repr
		parser_type: parser_type
		method_names: dsl_unique_names(dsl_default_method_names(), (value.attributes['method_names'] or {
			''}).split(',').filter(it.len > 0))
	}
}

pub fn register_dsl_type(mut the_class DSLClass, name string, class_value ruby.Value) {
	if !the_class.has_registered_types {
		mut registry := new_registered_classes_registry()
		the_class.registered_types = &registry
		the_class.has_registered_types = true
	}
	mut registry := the_class.registered_types
	registry.register(name, class_value)
}

fn dsl_default_method_names() []string {
	// These are the Object/Base/Struct methods that Ruby's method_defined?
	// observes before checking Struct::RESERVED.
	return ['object_id', 'class', 'clone', 'dup', 'inspect', 'method', 'methods', 'respond_to?',
		'send', 'field_names', 'assign', 'snapshot', 'read', 'write', 'num_bytes', 'to_binary_s']
}

fn dsl_unique_names(left []string, right []string) []string {
	mut result := left.clone()
	for name in right {
		if name !in result {
			result << name
		}
	}
	return result
}

fn dsl_parser_value(parser &DSLParser) ruby.Value {
	return ruby.Value{
		type_name: 'BinData::DSLMixin::DSLParser'
		repr: '${parser.the_class.name} DSL parser'
		int_data: i64(u64(voidptr(parser)))
		attributes: {
			'dsl_parser_address': u64(voidptr(parser)).str()
			'parser_type':        dsl_parser_type_name(parser.parser_type)
		}
	}
}

pub fn dsl_parser_boundary_value(parser &DSLParser) ruby.Value {
	return dsl_parser_value(parser)
}

fn dsl_parser_from_value(value ruby.Value) &DSLParser {
	address := value.attributes['dsl_parser_address'] or { panic('expected DSLParser receiver') }
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &DSLParser(voidptr(actual)) }
}

fn dsl_field_parser_value(parser &DSLFieldParser) ruby.Value {
	return ruby.Value{
		type_name: 'BinData::DSLMixin::DSLFieldParser'
		repr: parser.field_type
		int_data: i64(u64(voidptr(parser)))
		attributes: {
			'dsl_field_parser_address': u64(voidptr(parser)).str()
		}
	}
}

fn dsl_field_parser_from_value(value ruby.Value) &DSLFieldParser {
	address := value.attributes['dsl_field_parser_address'] or { panic('expected DSLFieldParser receiver') }
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &DSLFieldParser(voidptr(actual)) }
}

fn dsl_validator_value(validator &DSLFieldValidator) ruby.Value {
	return ruby.Value{
		type_name: 'BinData::DSLMixin::DSLFieldValidator'
		repr: validator.the_class.name
		int_data: i64(u64(voidptr(validator)))
		attributes: {
			'dsl_validator_address': u64(voidptr(validator)).str()
		}
	}
}

fn dsl_validator_from_value(value ruby.Value) &DSLFieldValidator {
	address := value.attributes['dsl_validator_address'] or { panic('expected DSLFieldValidator receiver') }
	actual := if value.int_data != 0 { u64(value.int_data) } else { address.u64() }
	return unsafe { &DSLFieldValidator(voidptr(actual)) }
}

fn dsl_values(value ruby.Value) []ruby.Value {
	if value.type_name == 'Array' {
		return value.as_array() or { panic(err) }
	}
	if value.type_name == 'NilClass' {
		return []
	}
	return [value]
}

fn dsl_field_names(fields []DSLField) []string {
	return fields.filter(it.has_name).map(dsl_symbol_name(it.name))
}

fn dsl_fields_boundary_value(fields []DSLField) ruby.Value {
	return sanitized_struct_fields_value(fields.map(SanitizedStructField{
		field_type: dsl_symbol_value(it.field_type)
		name: dsl_symbol_name(it.name)
		has_name: it.has_name
		parameters: it.params.clone()
	}))
}

fn dsl_fields_from_boundary(value ruby.Value) []DSLField {
	return sanitized_struct_fields_from_value(value).map(DSLField{
		field_type: dsl_symbol_name(it.field_type)
		name: if it.has_name { dsl_symbol_value(it.name) } else { dsl_nil_value() }
		has_name: it.has_name
		params: it.parameters.clone()
	})
}

fn dsl_prototype(field DSLField) ruby.Value {
	return ruby.array_value([
		dsl_symbol_value(field.field_type),
		ruby.map_value(field.params),
	])
}

pub fn separate_multi_field_arguments(fields []DSLField, obj_args []ruby.Value) BaseSeparatedArguments {
	mut separated := separate_base_arguments(obj_args)
	if !separated.has_value && separated.parameters.len > 0 {
		field_names := dsl_field_names(fields)
		if separated.parameters.keys().any(it.trim_left(':') in field_names) {
			separated = BaseSeparatedArguments{
				...separated
				value: ruby.map_value(separated.parameters)
				has_value: true
				parameters: map[string]ruby.Value{}
			}
		}
	}
	return separated
}

pub fn (parser &DSLParser) option(opt string) bool {
	return opt.trim_left(':') in dsl_parser_abilities()[parser.parser_type].options
}

pub fn (parser &DSLParser) valid_endian(endian DSLEndian) bool {
	return endian in [DSLEndian.big, .little, .big_and_little]
}

pub fn (parser &DSLParser) parent_fields() []DSLField {
	if parser.has_parent_fields_override {
		return parser.parent_fields_override.clone()
	}
	if parser.the_class.has_superclass {
		mut parent := parser.the_class.superclass
		mut parent_parser := dsl_parser_for_class(mut parent, none) or { return [] }
		return parent_parser.fields()
	}
	return []
}

pub fn (mut parser DSLParser) fields() []DSLField {
	if !parser.has_fields {
		parser.fields_value = parser.parent_fields()
		parser.has_fields = true
	}
	return parser.fields_value.clone()
}

pub fn (parser &DSLParser) has_defined_fields() bool {
	return parser.has_fields && parser.fields_value.len > 0
}

pub fn (mut parser DSLParser) get_endian() ?DSLEndian {
	if !parser.has_endian && parser.the_class.has_superclass {
		mut parent := parser.the_class.superclass
		mut parent_parser := dsl_parser_for_class(mut parent, none) or { return none }
		if inherited := parent_parser.get_endian() {
			parser.endian_value = inherited
			parser.has_endian = true
		}
	}
	if parser.has_endian {
		return parser.endian_value
	}
	return none
}

pub fn (mut parser DSLParser) search_prefix(values []string) ![]string {
	if !parser.has_search_prefix {
		if parser.the_class.has_superclass {
			mut parent := parser.the_class.superclass
			mut parent_parser := dsl_parser_for_class(mut parent, none)!
			parser.search_prefixes = parent_parser.search_prefix([])!
		}
		parser.has_search_prefix = true
	}
	mut prefix := values.filter(it.len > 0).map(it.trim_left(':'))
	if prefix.len > 0 {
		if parser.has_defined_fields() {
			return error('search_prefix must be called before defining fields in ${parser.the_class.name}')
		}
		prefix << parser.search_prefixes
		parser.search_prefixes = prefix
	}
	return parser.search_prefixes.clone()
}

pub fn (mut parser DSLParser) hide(values []string) ![]string {
	if !parser.option('hidden_fields') {
		return []
	}
	if parser.hidden_fields.len == 0 && parser.the_class.has_superclass {
		mut parent := parser.the_class.superclass
		mut parent_parser := dsl_parser_for_class(mut parent, none)!
		parser.hidden_fields = parent_parser.hide([])!
	}
	parser.hidden_fields << values.filter(it.len > 0).map(it.trim_left(':'))
	return parser.hidden_fields.clone()
}

pub fn (mut parser DSLParser) hints() !DSLHints {
	endian := parser.get_endian()
	prefixes := parser.search_prefix([])!
	return DSLHints{
		endian: endian
		search_prefix: prefixes
	}
}

fn create_endian_subclasses(mut bnl_class DSLClass) ![]&DSLClass {
	mut be_class := new_dsl_subclass('${bnl_class.name}Be', mut bnl_class)
	mut le_class := new_dsl_subclass('${bnl_class.name}Le', mut bnl_class)
	mut be_parser := dsl_parser_for_class(mut be_class, bnl_class.parser_type)!
	mut le_parser := dsl_parser_for_class(mut le_class, bnl_class.parser_type)!
	be_parser.set_endian(.big)!
	le_parser.set_endian(.little)!
	bnl_class.big_endian_class = be_class
	bnl_class.little_endian_class = le_class
	bnl_class.has_endian_classes = true
	return [be_class, le_class]
}

pub fn make_dsl_class_abstract(mut bnl_class DSLClass) {
	bnl_class.registered = false
}

pub fn class_with_dsl_endian(bnl_class &DSLClass, endian DSLEndian) !&DSLClass {
	if !bnl_class.has_endian_classes {
		return error('${bnl_class.name} has no endian subclasses')
	}
	return match endian {
		.big { bnl_class.big_endian_class }
		.little { bnl_class.little_endian_class }
		.big_and_little {
			return error('big_and_little does not select a concrete class')
		}
	}
}

pub fn fixup_dsl_subclass_hierarchy(mut bnl_class DSLClass) ! {
	if !bnl_class.has_superclass {
		return
	}
	mut parent := bnl_class.superclass
	mut parent_parser := dsl_parser_for_class(mut parent, none)!
	if parent_parser.get_endian() or { return } != .big_and_little {
		return
	}
	if !bnl_class.has_endian_classes || !parent.has_endian_classes {
		return
	}
	mut be_parser := dsl_parser_for_class(mut bnl_class.big_endian_class, none)!
	mut parent_be_parser := dsl_parser_for_class(mut parent.big_endian_class, none)!
	be_parser.parent_fields_override = parent_be_parser.fields()
	be_parser.has_parent_fields_override = true
	mut le_parser := dsl_parser_for_class(mut bnl_class.little_endian_class, none)!
	mut parent_le_parser := dsl_parser_for_class(mut parent.little_endian_class, none)!
	le_parser.parent_fields_override = parent_le_parser.fields()
	le_parser.has_parent_fields_override = true
}

pub fn handle_big_and_little_endian(mut bnl_class DSLClass) ! {
	make_dsl_class_abstract(mut bnl_class)
	create_endian_subclasses(mut bnl_class)!
	bnl_class.delegate_fields = true
	fixup_dsl_subclass_hierarchy(mut bnl_class)!
}

pub fn (mut parser DSLParser) set_endian(endian DSLEndian) ! {
	if parser.has_defined_fields() {
		return error('endian must be called before defining fields in ${parser.the_class.name}')
	}
	if !parser.valid_endian(endian) {
		return error("unknown value for endian '${dsl_endian_name(endian)}' in ${parser.the_class.name}")
	}
	if endian == .big_and_little && !parser.the_class.has_endian_classes {
		mut the_class := parser.the_class
		handle_big_and_little_endian(mut the_class)!
	}
	parser.endian_value = endian
	parser.has_endian = true
}

pub fn (mut parser DSLParser) set_endian_name(name string) ! {
	endian := dsl_endian_from_name(name) or {
		return error("unknown value for endian '${name.trim_left(':')}' in ${parser.the_class.name}")
	}
	parser.set_endian(endian)!
}

fn dsl_builtin_type_is_registered(name string) bool {
	base := name.trim_left(':').to_lower()
	if base in ['array', 'buffer', 'choice', 'delayed_io', 'section', 'skip', 'struct', 'string',
		'stringz', 'rest', 'float', 'double', 'virtual', 'count_bytes_remaining', 'uint8_array'] {
		return true
	}
	mut dynamic := base
	if dynamic.ends_with('le') || dynamic.ends_with('be') {
		dynamic = dynamic[..dynamic.len - 2]
	}
	if dynamic.starts_with('int') || dynamic.starts_with('uint') {
		digits := if dynamic.starts_with('uint') { dynamic[4..] } else { dynamic[3..] }
		return digits.len > 0 && digits.bytes().all(is_ascii_digit(it))
	}
	if dynamic.starts_with('bit') || dynamic.starts_with('sbit') {
		digits := if dynamic.starts_with('sbit') { dynamic[4..] } else { dynamic[3..] }
		return digits.len > 0 && digits.bytes().all(is_ascii_digit(it))
	}
	return false
}

fn (mut parser DSLParser) type_is_registered(name string) bool {
	if dsl_builtin_type_is_registered(name) {
		return true
	}
	if !parser.the_class.has_registered_types {
		return false
	}
	mut registry := parser.the_class.registered_types
	mut endian_hint := ?IntEndian(none)
	if endian := parser.get_endian() {
		endian_hint = match endian {
			.big { ?IntEndian(IntEndian.big) }
			.little { ?IntEndian(IntEndian.little) }
			.big_and_little { ?IntEndian(none) }
		}
	}
	prefix := parser.search_prefix([]) or { []string{} }
	registry.lookup(name, RegistryHints{
		endian: endian_hint
		search_prefix: prefix
	}) or { return false }
	return true
}

pub fn (mut parser DSLParser) append_field(field_type string, name ruby.Value, has_name bool, params map[string]ruby.Value) ! {
	if !parser.type_is_registered(field_type) {
		return error("unknown type '${field_type}' in ${parser.the_class.name}")
	}
	if !parser.has_fields {
		parser.fields_value = parser.parent_fields()
		parser.has_fields = true
	}
	parser.fields_value << DSLField{
		field_type: field_type
		name: name
		has_name: has_name
		params: params.clone()
	}
}

pub fn new_dsl_field_parser(hints DSLHints, field_type string, args []ruby.Value) &DSLFieldParser {
	name, has_name := dsl_name_from_declaration(args)
	return &DSLFieldParser{
		hints: hints
		field_type: field_type.trim_left(':')
		name: name
		has_name: has_name
		params: dsl_params_from_args(args)
	}
}

pub fn dsl_name_from_declaration(args []ruby.Value) (ruby.Value, bool) {
	if args.len == 0 || args[0].type_name == 'Hash' || (args[0].type_name == 'String' && args[0].as_string() == '') || args[0].type_name == 'NilClass' {
		return dsl_nil_value(), false
	}
	return args[0], true
}

pub fn dsl_params_from_args(args []ruby.Value) map[string]ruby.Value {
	if args.len == 0 {
		return map[string]ruby.Value{}
	}
	if args[0].type_name == 'Hash' {
		return args[0].map_data.clone()
	}
	if args.len > 1 && args[1].type_name == 'Hash' {
		return args[1].map_data.clone()
	}
	return map[string]ruby.Value{}
}

fn nested_parser_type(field_type string) ?DSLParserType {
	return match field_type.trim_left(':') {
		'array' { DSLParserType.array }
		'buffer' { DSLParserType.buffer }
		'choice' { DSLParserType.choice }
		'delayed_io' { DSLParserType.delayed_io }
		'section' { DSLParserType.section }
		'skip' { DSLParserType.skip }
		'struct' { DSLParserType.struct_type }
		else { none }
	}
}

pub fn dsl_params_from_block(hints DSLHints, field_type string, block DSLFieldBlock) !map[string]ruby.Value {
	parser_type := nested_parser_type(field_type) or { return map[string]ruby.Value{} }
	mut nested_class := new_dsl_class('BinData::${dsl_parser_type_name(parser_type)}', parser_type)
	mut nested := dsl_parser_for_class(mut nested_class, parser_type)!
	if endian := hints.endian {
		nested.set_endian(endian)!
	}
	nested.search_prefix(hints.search_prefix)!
	block(mut nested)!
	return nested.dsl_params()!
}

pub fn new_dsl_field_parser_with_block(hints DSLHints, field_type string, args []ruby.Value, block DSLFieldBlock) !&DSLFieldParser {
	mut parser := new_dsl_field_parser(hints, field_type, args)
	block_params := dsl_params_from_block(hints, field_type, block)!
	mut merged := parser.params.clone()
	for key, value in block_params {
		merged[key] = value
	}
	return &DSLFieldParser{
		...parser
		params: merged
	}
}

fn dsl_name_equal(left ruby.Value, right ruby.Value) bool {
	return left.type_name == right.type_name && left.repr == right.repr && left.int_data == right.int_data
}

pub fn new_dsl_field_validator(the_class &DSLClass, parser &DSLParser) &DSLFieldValidator {
	return &DSLFieldValidator{
		the_class: the_class
		dsl_parser: parser
	}
}

pub fn (validator &DSLFieldValidator) option(opt string) bool {
	return validator.dsl_parser.option(opt)
}

pub fn (validator &DSLFieldValidator) fields() []DSLField {
	mut parser := validator.dsl_parser
	return parser.fields()
}

pub fn (validator &DSLFieldValidator) must_not_have_a_name_failed(name ruby.Value, has_name bool) bool {
	return validator.option('no_fieldnames') && has_name
}

pub fn (validator &DSLFieldValidator) must_have_a_name_failed(name ruby.Value, has_name bool) bool {
	return validator.option('mandatory_fieldnames') && !has_name
}

pub fn (validator &DSLFieldValidator) all_or_none_names_failed(name ruby.Value, has_name bool) bool {
	if !validator.option('all_or_none_fieldnames') {
		return false
	}
	fields := validator.fields()
	if fields.len == 0 {
		return false
	}
	all_names_blank := fields.all(!it.has_name)
	no_names_blank := fields.all(it.has_name)
	return (has_name && all_names_blank) || (!has_name && no_names_blank)
}

pub fn dsl_malformed_name(name ruby.Value) bool {
	value := dsl_symbol_name(name)
	if value.len == 0 || !((value[0] >= `a` && value[0] <= `z`) || value[0] == `_`) {
		return true
	}
	return value.bytes()[1..].any(!((it >= `a` && it <= `z`) || (it >= `A` && it <= `Z`) || (it >= `0` && it <= `9`) || it == `_`))
}

pub fn (validator &DSLFieldValidator) duplicate_name(name ruby.Value) bool {
	return validator.fields().any(it.has_name && dsl_name_equal(it.name, name))
}

pub fn (validator &DSLFieldValidator) name_shadows_method(name ruby.Value) bool {
	return dsl_symbol_name(name) in validator.the_class.method_names
}

pub fn (validator &DSLFieldValidator) name_is_reserved(name ruby.Value) bool {
	return dsl_symbol_name(name) in struct_reserved_field_names()
}

pub fn (validator &DSLFieldValidator) ensure_valid_name(name ruby.Value, has_name bool) ! {
	if !has_name || validator.option('fieldnames_are_values') {
		return
	}
	text := dsl_symbol_name(name)
	if dsl_malformed_name(name) {
		return error("field '${text}' is an illegal fieldname")
	}
	if validator.duplicate_name(name) {
		return error("duplicate field '${text}'")
	}
	if validator.name_shadows_method(name) {
		return error("field '${text}' shadows an existing method")
	}
	if validator.name_is_reserved(name) {
		return error("field '${text}' is a reserved name")
	}
}

pub fn (validator &DSLFieldValidator) validate_field(name ruby.Value, has_name bool) ! {
	if validator.must_not_have_a_name_failed(name, has_name) {
		return error('field must not have a name')
	}
	if validator.all_or_none_names_failed(name, has_name) {
		return error('fields must either all have names, or none must have names')
	}
	if validator.must_have_a_name_failed(name, has_name) {
		return error('field must have a name')
	}
	validator.ensure_valid_name(name, has_name)!
}

pub fn (mut parser DSLParser) parse_and_append_field(field_type string, args []ruby.Value) ! {
	if parser.the_class.delegate_fields && parser.the_class.has_endian_classes {
		mut the_class := parser.the_class
		mut be_class := the_class.big_endian_class
		mut le_class := the_class.little_endian_class
		mut be_parser := dsl_parser_for_class(mut be_class, none)!
		be_parser.parse_and_append_field(field_type, args)!
		mut le_parser := dsl_parser_for_class(mut le_class, none)!
		le_parser.parse_and_append_field(field_type, args)!
		return
	}
	hints := parser.hints()!
	field := new_dsl_field_parser(hints, field_type, args)
	validator := new_dsl_field_validator(parser.the_class, parser)
	validator.validate_field(field.name, field.has_name) or {
		return error('${err.msg()} in ${parser.the_class.name}')
	}
	parser.append_field(field.field_type, field.name, field.has_name, field.params)!
}

pub fn (mut parser DSLParser) parse_and_append_field_with_block(field_type string, args []ruby.Value, block DSLFieldBlock) ! {
	if parser.the_class.delegate_fields && parser.the_class.has_endian_classes {
		mut the_class := parser.the_class
		mut be_class := the_class.big_endian_class
		mut le_class := the_class.little_endian_class
		mut be_parser := dsl_parser_for_class(mut be_class, none)!
		be_parser.parse_and_append_field_with_block(field_type, args, block)!
		mut le_parser := dsl_parser_for_class(mut le_class, none)!
		le_parser.parse_and_append_field_with_block(field_type, args, block)!
		return
	}
	hints := parser.hints()!
	field := new_dsl_field_parser_with_block(hints, field_type, args, block)!
	validator := new_dsl_field_validator(parser.the_class, parser)
	validator.validate_field(field.name, field.has_name) or {
		return error('${err.msg()} in ${parser.the_class.name}')
	}
	parser.append_field(field.field_type, field.name, field.has_name, field.params)!
}

pub fn (mut parser DSLParser) to_object_params(key string) !map[string]ruby.Value {
	fields := parser.fields()
	return match fields.len {
		0 { map[string]ruby.Value{} }
		1 {
			{
				key:
				dsl_prototype(fields[0])
			}
		}
		else {
			{
				key:
				ruby.array_value([
					dsl_symbol_value('struct'),
					ruby.map_value(parser.to_struct_params()!),
				])
			}
		}
	}
}

pub fn (mut parser DSLParser) to_choice_params(key string) !map[string]ruby.Value {
	fields := parser.fields()
	if fields.len == 0 {
		return map[string]ruby.Value{}
	}
	if fields.all(!it.has_name) {
		return {
			key: ruby.array_value(fields.map(dsl_prototype(it)))
		}
	}
	mut choices := map[string]ruby.Value{}
	for field in fields {
		choices[field.name.repr.trim_left(':')] = dsl_prototype(field)
	}
	return {
		key: ruby.map_value(choices)
	}
}

pub fn (mut parser DSLParser) to_struct_params() !map[string]ruby.Value {
	mut result := {
		'fields': dsl_fields_boundary_value(parser.fields())
	}
	if endian := parser.get_endian() {
		result['endian'] = dsl_symbol_value(dsl_endian_name(endian))
	}
	prefix := parser.search_prefix([])!
	if prefix.len > 0 {
		result['search_prefix'] = ruby.string_array_value(prefix)
	}
	if parser.option('hidden_fields') {
		hidden := parser.hide([])!
		if hidden.len > 0 {
			result['hide'] = ruby.string_array_value(hidden)
		}
	}
	return result
}

pub fn (mut parser DSLParser) dsl_params() !map[string]ruby.Value {
	ability := dsl_parser_abilities()[parser.parser_type]
	return match ability.converter {
		'to_object_params' { parser.to_object_params(ability.key)! }
		'to_choice_params' { parser.to_choice_params(ability.key)! }
		else { parser.to_struct_params()! }
	}
}

fn dsl_hints_value(hints DSLHints) ruby.Value {
	mut values := {
		'search_prefix': ruby.string_array_value(hints.search_prefix)
	}
	if endian := hints.endian {
		values['endian'] = dsl_symbol_value(dsl_endian_name(endian))
	} else {
		values['endian'] = dsl_nil_value()
	}
	return ruby.map_value(values)
}

fn dsl_hints_from_value(value ruby.Value) DSLHints {
	mut result := DSLHints{}
	if endian := value.map_data['endian'] {
		if endian.type_name != 'NilClass' {
			if converted := dsl_endian_from_name(endian.as_string()) {
				result = DSLHints{
					...result
					endian: converted
				}
			}
		}
	}
	if prefix := value.map_data['search_prefix'] {
		result = DSLHints{
			...result
			search_prefix: dsl_values(prefix).map(dsl_symbol_name(it))
		}
	}
	return result
}

fn dsl_ability_value(ability DSLParserAbility) ruby.Value {
	return ruby.array_value([
		dsl_symbol_value(ability.converter),
		dsl_symbol_value(ability.key),
		ruby.string_array_value(ability.options),
	])
}

pub fn dsl_raise_error(parser &DSLParser, message string) ! {
	return error('${message} in ${parser.the_class.name}')
}

// Ruby method `separate_args(obj_class, obj_args)` at line 9.
pub fn ruby_dsl_l9_d1_separate_args(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('separate_args requires an object class and arguments')
	}
	mut the_class := dsl_class_from_value(args[0])
	mut parser := dsl_parser_for_class(mut the_class, none) or { panic(err) }
	separated := separate_multi_field_arguments(parser.fields(), dsl_values(args[1]))
	return base_arguments_value(separated)
}

// Ruby method `parameters_is_value?(obj_class, value, parameters)` at line 20.
pub fn ruby_dsl_l20_d2_parameters_is_value(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('parameters_is_value? requires an object class, value and parameters')
	}
	if args[1].type_name != 'NilClass' || args[2].map_data.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby_dsl_l28_d3_field_names_in_parameters(args[0], args[2])
}

// Ruby method `field_names_in_parameters?(obj_class, parameters)` at line 28.
pub fn ruby_dsl_l28_d3_field_names_in_parameters(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('field_names_in_parameters? requires an object class and parameters')
	}
	mut the_class := dsl_class_from_value(args[0])
	mut parser := dsl_parser_for_class(mut the_class, none) or { panic(err) }
	names := dsl_field_names(parser.fields())
	return ruby.bool_value(args[1].map_data.keys().any(it.trim_left(':') in names))
}

// Ruby method `dsl_parser(parser_type = nil)` at line 38.
pub fn ruby_dsl_l38_d4_dsl_parser(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('dsl_parser requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	parser_type := if args.len > 1 && args[1].type_name != 'NilClass' {
		?DSLParserType(dsl_parser_type_from_name(args[1].as_string()) or { panic(err) })
	} else {
		?DSLParserType(none)
	}
	return dsl_parser_value(dsl_parser_for_class(mut the_class, parser_type) or { panic(err) })
}

// Ruby method `method_missing(symbol, *args, &block) # :nodoc:` at line 45.
pub fn ruby_dsl_l45_d5_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('DSLMixin.method_missing requires a class and symbol')
	}
	mut the_class := dsl_class_from_value(args[0])
	mut parser := dsl_parser_for_class(mut the_class, none) or { panic(err) }
	parser.parse_and_append_field(dsl_symbol_name(args[1]), args[2..]) or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `to_ary; nil; end` at line 50.
pub fn ruby_dsl_l50_d6_to_ary(args ...ruby.Value) ruby.Value {
	return dsl_nil_value()
}

// Ruby method `to_str; nil; end` at line 51.
pub fn ruby_dsl_l51_d7_to_str(args ...ruby.Value) ruby.Value {
	return dsl_nil_value()
}

// Ruby method `initialize(the_class, parser_type)` at line 63.
pub fn ruby_dsl_l63_d8_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('DSLParser.initialize requires a class and parser type')
	}
	mut the_class := dsl_class_from_value(args[0])
	return dsl_parser_value(new_dsl_parser(mut the_class, dsl_parser_type_from_name(args[1].as_string()) or {
		panic(err)
	}) or { panic(err) })
}

// Ruby attr_reader `attr_reader :parser_type` at line 72.
pub fn ruby_dsl_l72_d9_parser_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('parser_type requires a DSLParser')
	}
	return dsl_symbol_value(dsl_parser_type_name(dsl_parser_from_value(args[0]).parser_type))
}

// Ruby method `endian(endian = nil)` at line 74.
pub fn ruby_dsl_l74_d10_endian(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('endian requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	if args.len > 1 && args[1].type_name != 'NilClass' {
		parser.set_endian_name(args[1].as_string()) or { panic(err) }
	}
	if endian := parser.get_endian() {
		return dsl_symbol_value(dsl_endian_name(endian))
	}
	return dsl_nil_value()
}

// Ruby method `search_prefix(*args)` at line 83.
pub fn ruby_dsl_l83_d11_search_prefix(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('search_prefix requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	prefixes := parser.search_prefix(args[1..].filter(it.type_name != 'NilClass').map(dsl_symbol_name(it))) or {
		panic(err)
	}
	return ruby.string_array_value(prefixes)
}

// Ruby method `hide(*args)` at line 98.
pub fn ruby_dsl_l98_d12_hide(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('hide requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	if !parser.option('hidden_fields') {
		return dsl_nil_value()
	}
	return ruby.string_array_value(parser.hide(args[1..].filter(it.type_name != 'NilClass').map(dsl_symbol_name(it))) or {
		panic(err)
	})
}

// Ruby method `fields` at line 109.
pub fn ruby_dsl_l109_d13_fields(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('fields requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	return dsl_fields_boundary_value(parser.fields())
}

// Ruby method `dsl_params` at line 113.
pub fn ruby_dsl_l113_d14_dsl_params(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('dsl_params requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	return ruby.map_value(parser.dsl_params() or { panic(err) })
}

// Ruby method `method_missing(*args, &block)` at line 118.
pub fn ruby_dsl_l118_d15_method_missing(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('DSLParser.method_missing requires a parser and field type')
	}
	mut parser := dsl_parser_from_value(args[0])
	parser.parse_and_append_field(dsl_symbol_name(args[1]), args[2..]) or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `parser_abilities` at line 126.
pub fn ruby_dsl_l126_d16_parser_abilities(args ...ruby.Value) ruby.Value {
	mut abilities := map[string]ruby.Value{}
	for parser_type, ability in dsl_parser_abilities() {
		abilities[dsl_parser_type_name(parser_type)] = dsl_ability_value(ability)
	}
	return ruby.map_value(abilities)
}

// Ruby method `option?(opt)` at line 139.
pub fn ruby_dsl_l139_d17_option(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('option? requires a DSLParser and option')
	}
	return ruby.bool_value(dsl_parser_from_value(args[0]).option(dsl_symbol_name(args[1])))
}

// Ruby method `ensure_hints` at line 143.
pub fn ruby_dsl_l143_d18_ensure_hints(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ensure_hints requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	parser.hints() or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `hints` at line 148.
pub fn ruby_dsl_l148_d19_hints(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('hints requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	return dsl_hints_value(parser.hints() or { panic(err) })
}

// Ruby method `set_endian(endian)` at line 152.
pub fn ruby_dsl_l152_d20_set_endian(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('set_endian requires a DSLParser and endian')
	}
	if args[1].type_name != 'NilClass' {
		mut parser := dsl_parser_from_value(args[0])
		parser.set_endian_name(args[1].as_string()) or { panic(err) }
	}
	return dsl_nil_value()
}

// Ruby method `valid_endian?(endian)` at line 169.
pub fn ruby_dsl_l169_d21_valid_endian(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('valid_endian? requires a DSLParser and endian')
	}
	return ruby.bool_value(args[1].as_string().trim_left(':') in ['big', 'little',
		'big_and_little'])
}

// Ruby method `parent_fields` at line 173.
pub fn ruby_dsl_l173_d22_parent_fields(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('parent_fields requires a DSLParser')
	}
	return dsl_fields_boundary_value(dsl_parser_from_value(args[0]).parent_fields())
}

// Ruby method `fields?` at line 177.
pub fn ruby_dsl_l177_d23_fields(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('fields? requires a DSLParser')
	}
	return ruby.bool_value(dsl_parser_from_value(args[0]).has_defined_fields())
}

// Ruby method `parse_and_append_field(*args, &block)` at line 181.
pub fn ruby_dsl_l181_d24_parse_and_append_field(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('parse_and_append_field requires a DSLParser and type')
	}
	mut parser := dsl_parser_from_value(args[0])
	parser.parse_and_append_field(dsl_symbol_name(args[1]), args[2..]) or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `append_field(type, name, params)` at line 191.
pub fn ruby_dsl_l191_d25_append_field(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('append_field requires a DSLParser, type, name and params')
	}
	mut parser := dsl_parser_from_value(args[0])
	name := args[2]
	parser.append_field(dsl_symbol_name(args[1]), name, name.type_name != 'NilClass' && name.as_string() != '', args[3].map_data) or {
		panic(err)
	}
	return dsl_nil_value()
}

// Ruby method `parent_attribute(attr, default = nil)` at line 197.
pub fn ruby_dsl_l197_d26_parent_attribute(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('parent_attribute requires a DSLParser and attribute')
	}
	parser := dsl_parser_from_value(args[0])
	if !parser.the_class.has_superclass {
		return if args.len > 2 { args[2] } else { dsl_nil_value() }
	}
	mut parent := parser.the_class.superclass
	mut parent_parser := dsl_parser_for_class(mut parent, none) or { panic(err) }
	return match dsl_symbol_name(args[1]) {
		'endian' {
			if endian := parent_parser.get_endian() {
				dsl_symbol_value(dsl_endian_name(endian))
			} else {
				if args.len > 2 { args[2] } else { dsl_nil_value() }
			}
		}
		'search_prefix' {
			ruby.string_array_value(parent_parser.search_prefix([]) or { panic(err) })
		}
		'hide' { ruby.string_array_value(parent_parser.hide([]) or { panic(err) }) }
		'fields' { dsl_fields_boundary_value(parent_parser.fields()) }
		else {
			if args.len > 2 { args[2] } else { dsl_nil_value() }
		}
	}
}

// Ruby method `dsl_raise(exception, msg)` at line 207.
pub fn ruby_dsl_l207_d27_dsl_raise(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('dsl_raise requires a DSLParser, exception and message')
	}
	dsl_raise_error(dsl_parser_from_value(args[0]), args[2].as_string()) or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `to_object_params(key)` at line 214.
pub fn ruby_dsl_l214_d28_to_object_params(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('to_object_params requires a DSLParser and key')
	}
	mut parser := dsl_parser_from_value(args[0])
	return ruby.map_value(parser.to_object_params(dsl_symbol_name(args[1])) or { panic(err) })
}

// Ruby method `to_choice_params(key)` at line 225.
pub fn ruby_dsl_l225_d29_to_choice_params(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('to_choice_params requires a DSLParser and key')
	}
	mut parser := dsl_parser_from_value(args[0])
	return ruby.map_value(parser.to_choice_params(dsl_symbol_name(args[1])) or { panic(err) })
}

// Ruby method `to_struct_params(*_)` at line 237.
pub fn ruby_dsl_l237_d30_to_struct_params(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('to_struct_params requires a DSLParser')
	}
	mut parser := dsl_parser_from_value(args[0])
	return ruby.map_value(parser.to_struct_params() or { panic(err) })
}

// Ruby method `handle(bnl_class)` at line 258.
pub fn ruby_dsl_l258_d31_handle(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('handle requires a big-and-little-endian class')
	}
	mut the_class := dsl_class_from_value(args[0])
	handle_big_and_little_endian(mut the_class) or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `make_class_abstract(bnl_class)` at line 266.
pub fn ruby_dsl_l266_d32_make_class_abstract(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('make_class_abstract requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	make_dsl_class_abstract(mut the_class)
	return dsl_nil_value()
}

// Ruby method `create_subclasses_with_endian(bnl_class)` at line 270.
pub fn ruby_dsl_l270_d33_create_subclasses_with_endian(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('create_subclasses_with_endian requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	classes := create_endian_subclasses(mut the_class) or { panic(err) }
	return ruby.array_value(classes.map(dsl_class_value(it)))
}

// Ruby method `override_new_in_class(bnl_class)` at line 275.
pub fn ruby_dsl_l275_d34_override_new_in_class(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('override_new_in_class requires a class')
	}
	return args[0]
}

// Ruby define_singleton_method `bnl_class.define_singleton_method(:new) do |*args|` at line 280.
pub fn ruby_dsl_l280_d35_new(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('new requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	mut selected := the_class
	separated := separate_base_arguments(args[1..])
	if endian_value := separated.parameters['endian'] {
		if endian := dsl_endian_from_name(endian_value.as_string()) {
			selected = class_with_dsl_endian(the_class, endian) or { the_class }
		}
	}
	if selected == the_class && the_class.has_endian_classes {
		panic('endian must be specified in ${the_class.name}')
	}
	return initialize_base_object(dsl_class_value(selected), args[1..])
}

// Ruby method `delegate_field_creation(bnl_class)` at line 291.
pub fn ruby_dsl_l291_d36_delegate_field_creation(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('delegate_field_creation requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	the_class.delegate_fields = true
	return dsl_nil_value()
}

// Ruby define_singleton_method `parser.define_singleton_method(:parse_and_append_field) do |*args, &block|` at line 298.
pub fn ruby_dsl_l298_d37_parse_and_append_field(args ...ruby.Value) ruby.Value {
	return ruby_dsl_l181_d24_parse_and_append_field(...args)
}

// Ruby method `fixup_subclass_hierarchy(bnl_class)` at line 304.
pub fn ruby_dsl_l304_d38_fixup_subclass_hierarchy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('fixup_subclass_hierarchy requires a class')
	}
	mut the_class := dsl_class_from_value(args[0])
	fixup_dsl_subclass_hierarchy(mut the_class) or { panic(err) }
	return dsl_nil_value()
}

// Ruby define_singleton_method `be_subclass.dsl_parser.define_singleton_method(:parent_fields) do` at line 316.
pub fn ruby_dsl_l316_d39_parent_fields(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		mut parser := dsl_parser_from_value(args[0])
		parser.parent_fields_override = dsl_fields_from_boundary(args[1])
		parser.has_parent_fields_override = true
	}
	return ruby_dsl_l173_d22_parent_fields(...args[..1])
}

// Ruby define_singleton_method `le_subclass.dsl_parser.define_singleton_method(:parent_fields) do` at line 319.
pub fn ruby_dsl_l319_d40_parent_fields(args ...ruby.Value) ruby.Value {
	return ruby_dsl_l316_d39_parent_fields(...args)
}

// Ruby method `class_with_endian(class_name, endian)` at line 324.
pub fn ruby_dsl_l324_d41_class_with_endian(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('class_with_endian requires a class and endian')
	}
	the_class := dsl_class_from_value(args[0])
	return dsl_class_value(class_with_dsl_endian(the_class, dsl_endian_from_name(args[1].as_string()) or {
		panic(err)
	}) or { panic(err) })
}

// Ruby method `obj_attribute(obj, attr)` at line 332.
pub fn ruby_dsl_l332_d42_obj_attribute(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('obj_attribute requires a class and attribute')
	}
	mut the_class := dsl_class_from_value(args[0])
	mut parser := dsl_parser_for_class(mut the_class, none) or { panic(err) }
	return match dsl_symbol_name(args[1]) {
		'endian' {
			if endian := parser.get_endian() {
				dsl_symbol_value(dsl_endian_name(endian))
			} else {
				dsl_nil_value()
			}
		}
		'search_prefix' {
			ruby.string_array_value(parser.search_prefix([]) or { panic(err) })
		}
		'hide' { ruby.string_array_value(parser.hide([]) or { panic(err) }) }
		'fields' { dsl_fields_boundary_value(parser.fields()) }
		'parser_type' { dsl_symbol_value(dsl_parser_type_name(parser.parser_type)) }
		else { dsl_nil_value() }
	}
}

// Ruby method `initialize(hints, symbol, *args, &block)` at line 340.
pub fn ruby_dsl_l340_d43_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('DSLFieldParser.initialize requires hints and type')
	}
	return dsl_field_parser_value(new_dsl_field_parser(dsl_hints_from_value(args[0]), dsl_symbol_name(args[1]), args[2..]))
}

// Ruby attr_reader `attr_reader :type, :name, :params` at line 347.
pub fn ruby_dsl_l347_d44_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('type requires a DSLFieldParser')
	}
	return dsl_symbol_value(dsl_field_parser_from_value(args[0]).field_type)
}

// Ruby attr_reader `attr_reader :type, :name, :params` at line 347.
pub fn ruby_dsl_l347_d45_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('name requires a DSLFieldParser')
	}
	parser := dsl_field_parser_from_value(args[0])
	return if parser.has_name { parser.name } else { dsl_nil_value() }
}

// Ruby attr_reader `attr_reader :type, :name, :params` at line 347.
pub fn ruby_dsl_l347_d46_params(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('params requires a DSLFieldParser')
	}
	return ruby.map_value(dsl_field_parser_from_value(args[0]).params)
}

// Ruby method `name_from_field_declaration(args)` at line 349.
pub fn ruby_dsl_l349_d47_name_from_field_declaration(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('name_from_field_declaration requires a DSLFieldParser')
	}
	values := if args.len > 1 { dsl_values(args[1]) } else { []ruby.Value{} }
	name, has_name := dsl_name_from_declaration(values)
	return if has_name { name } else { dsl_nil_value() }
}

// Ruby method `params_from_field_declaration(args, &block)` at line 358.
pub fn ruby_dsl_l358_d48_params_from_field_declaration(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('params_from_field_declaration requires a DSLFieldParser')
	}
	values := if args.len > 1 { dsl_values(args[1]) } else { []ruby.Value{} }
	mut params := dsl_params_from_args(values)
	if args.len > 2 && args[2].type_name == 'Hash' {
		for key, value in args[2].map_data {
			params[key] = value
		}
	}
	return ruby.map_value(params)
}

// Ruby method `params_from_args(args)` at line 368.
pub fn ruby_dsl_l368_d49_params_from_args(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('params_from_args requires a DSLFieldParser')
	}
	values := if args.len > 1 { dsl_values(args[1]) } else { []ruby.Value{} }
	return ruby.map_value(dsl_params_from_args(values))
}

// Ruby method `params_from_block(&block)` at line 375.
pub fn ruby_dsl_l375_d50_params_from_block(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('params_from_block requires a DSLFieldParser')
	}
	// Function values do not cross ruby.Value. A translated caller can
	// pass the already evaluated nested DSL parameter hash through this boundary.
	if args.len > 1 && args[1].type_name == 'Hash' {
		return args[1]
	}
	return ruby.map_value({})
}

// Ruby method `initialize(the_class, parser)` at line 401.
pub fn ruby_dsl_l401_d51_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('DSLFieldValidator.initialize requires a class and parser')
	}
	return dsl_validator_value(new_dsl_field_validator(dsl_class_from_value(args[0]), dsl_parser_from_value(args[1])))
}

// Ruby method `validate_field(name)` at line 406.
pub fn ruby_dsl_l406_d52_validate_field(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('validate_field requires a validator and name')
	}
	validator := dsl_validator_from_value(args[0])
	validator.validate_field(args[1], args[1].type_name != 'NilClass') or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `ensure_valid_name(name)` at line 422.
pub fn ruby_dsl_l422_d53_ensure_valid_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ensure_valid_name requires a validator and name')
	}
	validator := dsl_validator_from_value(args[0])
	validator.ensure_valid_name(args[1], args[1].type_name != 'NilClass') or { panic(err) }
	return dsl_nil_value()
}

// Ruby method `must_not_have_a_name_failed?(name)` at line 442.
pub fn ruby_dsl_l442_d54_must_not_have_a_name_failed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('must_not_have_a_name_failed? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).must_not_have_a_name_failed(args[1], args[1].type_name != 'NilClass'))
}

// Ruby method `must_have_a_name_failed?(name)` at line 446.
pub fn ruby_dsl_l446_d55_must_have_a_name_failed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('must_have_a_name_failed? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).must_have_a_name_failed(args[1], args[1].type_name != 'NilClass'))
}

// Ruby method `all_or_none_names_failed?(name)` at line 450.
pub fn ruby_dsl_l450_d56_all_or_none_names_failed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('all_or_none_names_failed? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).all_or_none_names_failed(args[1], args[1].type_name != 'NilClass'))
}

// Ruby method `malformed_name?(name)` at line 461.
pub fn ruby_dsl_l461_d57_malformed_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('malformed_name? requires a validator and name')
	}
	return ruby.bool_value(dsl_malformed_name(args[1]))
}

// Ruby method `duplicate_name?(name)` at line 465.
pub fn ruby_dsl_l465_d58_duplicate_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('duplicate_name? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).duplicate_name(args[1]))
}

// Ruby method `name_shadows_method?(name)` at line 469.
pub fn ruby_dsl_l469_d59_name_shadows_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('name_shadows_method? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).name_shadows_method(args[1]))
}

// Ruby method `name_is_reserved?(name)` at line 473.
pub fn ruby_dsl_l473_d60_name_is_reserved(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('name_is_reserved? requires a validator and name')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).name_is_reserved(args[1]))
}

// Ruby method `fields` at line 477.
pub fn ruby_dsl_l477_d61_fields(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('fields requires a validator')
	}
	return dsl_fields_boundary_value(dsl_validator_from_value(args[0]).fields())
}

// Ruby method `option?(opt)` at line 481.
pub fn ruby_dsl_l481_d62_option(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('option? requires a validator and option')
	}
	return ruby.bool_value(dsl_validator_from_value(args[0]).option(dsl_symbol_name(args[1])))
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   # Extracts args for Records and Buffers.
// 3:   #
// 4:   # Foo.new(bar: "baz) is ambiguous as to whether :bar is a value or parameter.
// 5:   #
// 6:   # BaseArgExtractor always assumes :bar is parameter.  This extractor correctly
// 7:   # identifies it as value or parameter.
// 8:   module MultiFieldArgSeparator
// 9:     def separate_args(obj_class, obj_args)
// 10:       value, parameters, parent = super(obj_class, obj_args)
// 11:
// 12:       if parameters_is_value?(obj_class, value, parameters)
// 13:         value = parameters
// 14:         parameters = {}
// 15:       end
// 16:
// 17:       [value, parameters, parent]
// 18:     end
// 19:
// 20:     def parameters_is_value?(obj_class, value, parameters)
// 21:       if value.nil? && !parameters.empty?
// 22:         field_names_in_parameters?(obj_class, parameters)
// 23:       else
// 24:         false
// 25:       end
// 26:     end
// 27:
// 28:     def field_names_in_parameters?(obj_class, parameters)
// 29:       field_names = obj_class.fields.field_names
// 30:       param_keys = parameters.keys
// 31:
// 32:       !(field_names & param_keys).empty?
// 33:     end
// 34:   end
// 35:
// 36:   # BinData classes that are part of the DSL must be extended by this.
// 37:   module DSLMixin
// 38:     def dsl_parser(parser_type = nil)
// 39:       @dsl_parser ||= begin
// 40:         parser_type ||= superclass.dsl_parser.parser_type
// 41:         DSLParser.new(self, parser_type)
// 42:       end
// 43:     end
// 44:
// 45:     def method_missing(symbol, *args, &block) # :nodoc:
// 46:       dsl_parser.__send__(symbol, *args, &block)
// 47:     end
// 48:
// 49:     # Assert object is not an array or string.
// 50:     def to_ary; nil; end
// 51:     def to_str; nil; end
// 52:
// 53:     # A DSLParser parses and accumulates field definitions of the form
// 54:     #
// 55:     #   type name, params
// 56:     #
// 57:     # where:
// 58:     #   * +type+ is the under_scored name of a registered type
// 59:     #   * +name+ is the (possible optional) name of the field
// 60:     #   * +params+ is a hash containing any parameters
// 61:     #
// 62:     class DSLParser
// 63:       def initialize(the_class, parser_type)
// 64:         raise "unknown parser type #{parser_type}" unless parser_abilities[parser_type]
// 65:
// 66:         @the_class      = the_class
// 67:         @parser_type    = parser_type
// 68:         @validator      = DSLFieldValidator.new(the_class, self)
// 69:         @endian         = nil
// 70:       end
// 71:
// 72:       attr_reader :parser_type
// 73:
// 74:       def endian(endian = nil)
// 75:         if endian
// 76:           set_endian(endian)
// 77:         elsif @endian.nil?
// 78:           set_endian(parent_attribute(:endian))
// 79:         end
// 80:         @endian
// 81:       end
// 82:
// 83:       def search_prefix(*args)
// 84:         @search_prefix ||= parent_attribute(:search_prefix, []).dup
// 85:
// 86:         prefix = args.collect(&:to_sym).compact
// 87:         unless prefix.empty?
// 88:           if fields?
// 89:             dsl_raise SyntaxError, "search_prefix must be called before defining fields"
// 90:           end
// 91:
// 92:           @search_prefix = prefix.concat(@search_prefix)
// 93:         end
// 94:
// 95:         @search_prefix
// 96:       end
// 97:
// 98:       def hide(*args)
// 99:         if option?(:hidden_fields)
// 100:           @hide ||= parent_attribute(:hide, []).dup
// 101:
// 102:           hidden = args.collect(&:to_sym).compact
// 103:           @hide.concat(hidden)
// 104:
// 105:           @hide
// 106:         end
// 107:       end
// 108:
// 109:       def fields
// 110:         @fields ||= SanitizedFields.new(hints, parent_fields)
// 111:       end
// 112:
// 113:       def dsl_params
// 114:         abilities = parser_abilities[@parser_type]
// 115:         send(abilities.at(0), abilities.at(1))
// 116:       end
// 117:
// 118:       def method_missing(*args, &block)
// 119:         ensure_hints
// 120:         parse_and_append_field(*args, &block)
// 121:       end
// 122:
// 123:       #-------------
// 124:       private
// 125:
// 126:       def parser_abilities
// 127:         @abilities ||= {
// 128:           struct:     [:to_struct_params, :struct,      [:multiple_fields, :optional_fieldnames, :hidden_fields]],
// 129:           array:      [:to_object_params, :type,        [:multiple_fields, :optional_fieldnames]],
// 130:           buffer:     [:to_object_params, :type,        [:multiple_fields, :optional_fieldnames, :hidden_fields]],
// 131:           choice:     [:to_choice_params, :choices,     [:multiple_fields, :all_or_none_fieldnames, :fieldnames_are_values]],
// 132:           delayed_io: [:to_object_params, :type,        [:multiple_fields, :optional_fieldnames, :hidden_fields]],
// 133:           primitive:  [:to_struct_params, :struct,      [:multiple_fields, :optional_fieldnames]],
// 134:           section:    [:to_object_params, :type,        [:multiple_fields, :optional_fieldnames]],
// 135:           skip:       [:to_object_params, :until_valid, [:multiple_fields, :optional_fieldnames]]
// 136:         }
// 137:       end
// 138:
// 139:       def option?(opt)
// 140:         parser_abilities[@parser_type].at(2).include?(opt)
// 141:       end
// 142:
// 143:       def ensure_hints
// 144:         endian
// 145:         search_prefix
// 146:       end
// 147:
// 148:       def hints
// 149:         { endian: endian, search_prefix: search_prefix }
// 150:       end
// 151:
// 152:       def set_endian(endian)
// 153:         if endian
// 154:           if fields?
// 155:             dsl_raise SyntaxError, "endian must be called before defining fields"
// 156:           end
// 157:           if !valid_endian?(endian)
// 158:             dsl_raise ArgumentError, "unknown value for endian '#{endian}'"
// 159:           end
// 160:
// 161:           if endian == :big_and_little
// 162:             DSLBigAndLittleEndianHandler.handle(@the_class)
// 163:           end
// 164:
// 165:           @endian = endian
// 166:         end
// 167:       end
// 168:
// 169:       def valid_endian?(endian)
// 170:         [:big, :little, :big_and_little].include?(endian)
// 171:       end
// 172:
// 173:       def parent_fields
// 174:         parent_attribute(:fields)
// 175:       end
// 176:
// 177:       def fields?
// 178:         defined?(@fields) && !@fields.empty?
// 179:       end
// 180:
// 181:       def parse_and_append_field(*args, &block)
// 182:         parser = DSLFieldParser.new(hints, *args, &block)
// 183:         begin
// 184:           @validator.validate_field(parser.name)
// 185:           append_field(parser.type, parser.name, parser.params)
// 186:         rescue Exception => e
// 187:           dsl_raise e.class, e.message
// 188:         end
// 189:       end
// 190:
// 191:       def append_field(type, name, params)
// 192:         fields.add_field(type, name, params)
// 193:       rescue BinData::UnRegisteredTypeError => e
// 194:         raise TypeError, "unknown type '#{e.message}'"
// 195:       end
// 196:
// 197:       def parent_attribute(attr, default = nil)
// 198:         parent = @the_class.superclass
// 199:         parser = parent.respond_to?(:dsl_parser) ? parent.dsl_parser : nil
// 200:         if parser&.respond_to?(attr)
// 201:           parser.send(attr)
// 202:         else
// 203:           default
// 204:         end
// 205:       end
// 206:
// 207:       def dsl_raise(exception, msg)
// 208:         backtrace = caller
// 209:         backtrace.shift while %r{bindata/dsl.rb}.match?(backtrace.first)
// 210:
// 211:         raise exception, "#{msg} in #{@the_class}", backtrace
// 212:       end
// 213:
// 214:       def to_object_params(key)
// 215:         case fields.length
// 216:         when 0
// 217:           {}
// 218:         when 1
// 219:           { key => fields[0].prototype }
// 220:         else
// 221:           { key => [:struct, to_struct_params] }
// 222:         end
// 223:       end
// 224:
// 225:       def to_choice_params(key)
// 226:         if fields.empty?
// 227:           {}
// 228:         elsif fields.all_field_names_blank?
// 229:           { key => fields.collect(&:prototype) }
// 230:         else
// 231:           choices = {}
// 232:           fields.each { |f| choices[f.name] = f.prototype }
// 233:           { key => choices }
// 234:         end
// 235:       end
// 236:
// 237:       def to_struct_params(*_)
// 238:         result = { fields: fields }
// 239:         if !endian.nil?
// 240:           result[:endian] = endian
// 241:         end
// 242:         if !search_prefix.empty?
// 243:           result[:search_prefix] = search_prefix
// 244:         end
// 245:         if option?(:hidden_fields) && !hide.empty?
// 246:           result[:hide] = hide
// 247:         end
// 248:
// 249:         result
// 250:       end
// 251:     end
// 252:
// 253:     # Handles the :big_and_little endian option.
// 254:     # This option creates two subclasses, each handling
// 255:     # :big or :little endian.
// 256:     class DSLBigAndLittleEndianHandler
// 257:       class << self
// 258:         def handle(bnl_class)
// 259:           make_class_abstract(bnl_class)
// 260:           create_subclasses_with_endian(bnl_class)
// 261:           override_new_in_class(bnl_class)
// 262:           delegate_field_creation(bnl_class)
// 263:           fixup_subclass_hierarchy(bnl_class)
// 264:         end
// 265:
// 266:         def make_class_abstract(bnl_class)
// 267:           bnl_class.send(:unregister_self)
// 268:         end
// 269:
// 270:         def create_subclasses_with_endian(bnl_class)
// 271:           instance_eval "class ::#{bnl_class}Be < ::#{bnl_class}; endian :big; end"
// 272:           instance_eval "class ::#{bnl_class}Le < ::#{bnl_class}; endian :little; end"
// 273:         end
// 274:
// 275:         def override_new_in_class(bnl_class)
// 276:           endian_classes = {
// 277:             big:    class_with_endian(bnl_class, :big),
// 278:             little: class_with_endian(bnl_class, :little)
// 279:           }
// 280:           bnl_class.define_singleton_method(:new) do |*args|
// 281:             if self == bnl_class
// 282:               _, options, _ = arg_processor.separate_args(self, args)
// 283:               delegate = endian_classes[options[:endian]]
// 284:               return delegate.new(*args) if delegate
// 285:             end
// 286:
// 287:             super(*args)
// 288:           end
// 289:         end
// 290:
// 291:         def delegate_field_creation(bnl_class)
// 292:           endian_classes = {
// 293:             big:    class_with_endian(bnl_class, :big),
// 294:             little: class_with_endian(bnl_class, :little)
// 295:           }
// 296:
// 297:           parser = bnl_class.dsl_parser
// 298:           parser.define_singleton_method(:parse_and_append_field) do |*args, &block|
// 299:             endian_classes[:big].send(*args, &block)
// 300:             endian_classes[:little].send(*args, &block)
// 301:           end
// 302:         end
// 303:
// 304:         def fixup_subclass_hierarchy(bnl_class)
// 305:           parent = bnl_class.superclass
// 306:           return if obj_attribute(parent, :endian) != :big_and_little
// 307:
// 308:           be_subclass = class_with_endian(bnl_class, :big)
// 309:           be_parent   = class_with_endian(parent, :big)
// 310:           be_fields   = obj_attribute(be_parent, :fields)
// 311:
// 312:           le_subclass = class_with_endian(bnl_class, :little)
// 313:           le_parent   = class_with_endian(parent, :little)
// 314:           le_fields   = obj_attribute(le_parent, :fields)
// 315:
// 316:           be_subclass.dsl_parser.define_singleton_method(:parent_fields) do
// 317:             be_fields
// 318:           end
// 319:           le_subclass.dsl_parser.define_singleton_method(:parent_fields) do
// 320:             le_fields
// 321:           end
// 322:         end
// 323:
// 324:         def class_with_endian(class_name, endian)
// 325:           hints = {
// 326:             endian: endian,
// 327:             search_prefix: class_name.dsl_parser.search_prefix
// 328:           }
// 329:           RegisteredClasses.lookup(class_name, hints)
// 330:         end
// 331:
// 332:         def obj_attribute(obj, attr)
// 333:           obj.dsl_parser.send(attr)
// 334:         end
// 335:       end
// 336:     end
// 337:
// 338:     # Extracts the details from a field declaration.
// 339:     class DSLFieldParser
// 340:       def initialize(hints, symbol, *args, &block)
// 341:         @hints  = hints
// 342:         @type   = symbol
// 343:         @name   = name_from_field_declaration(args)
// 344:         @params = params_from_field_declaration(args, &block)
// 345:       end
// 346:
// 347:       attr_reader :type, :name, :params
// 348:
// 349:       def name_from_field_declaration(args)
// 350:         name, _ = args
// 351:         if name == "" || name.is_a?(Hash)
// 352:           nil
// 353:         else
// 354:           name
// 355:         end
// 356:       end
// 357:
// 358:       def params_from_field_declaration(args, &block)
// 359:         params = params_from_args(args)
// 360:
// 361:         if block_given?
// 362:           params.merge(params_from_block(&block))
// 363:         else
// 364:           params
// 365:         end
// 366:       end
// 367:
// 368:       def params_from_args(args)
// 369:         name, params = args
// 370:         params = name if name.is_a?(Hash)
// 371:
// 372:         params || {}
// 373:       end
// 374:
// 375:       def params_from_block(&block)
// 376:         bindata_classes = {
// 377:           array:      BinData::Array,
// 378:           buffer:     BinData::Buffer,
// 379:           choice:     BinData::Choice,
// 380:           delayed_io: BinData::DelayedIO,
// 381:           section:    BinData::Section,
// 382:           skip:       BinData::Skip,
// 383:           struct:     BinData::Struct
// 384:         }
// 385:
// 386:         if bindata_classes.include?(@type)
// 387:           parser = DSLParser.new(bindata_classes[@type], @type)
// 388:           parser.endian(@hints[:endian])
// 389:           parser.search_prefix(*@hints[:search_prefix])
// 390:           parser.instance_eval(&block)
// 391:
// 392:           parser.dsl_params
// 393:         else
// 394:           {}
// 395:         end
// 396:       end
// 397:     end
// 398:
// 399:     # Validates a field defined in a DSLMixin.
// 400:     class DSLFieldValidator
// 401:       def initialize(the_class, parser)
// 402:         @the_class = the_class
// 403:         @dsl_parser = parser
// 404:       end
// 405:
// 406:       def validate_field(name)
// 407:         if must_not_have_a_name_failed?(name)
// 408:           raise SyntaxError, "field must not have a name"
// 409:         end
// 410:
// 411:         if all_or_none_names_failed?(name)
// 412:           raise SyntaxError, "fields must either all have names, or none must have names"
// 413:         end
// 414:
// 415:         if must_have_a_name_failed?(name)
// 416:           raise SyntaxError, "field must have a name"
// 417:         end
// 418:
// 419:         ensure_valid_name(name)
// 420:       end
// 421:
// 422:       def ensure_valid_name(name)
// 423:         if name && !option?(:fieldnames_are_values)
// 424:           if malformed_name?(name)
// 425:             raise SyntaxError, "field '#{name}' is an illegal fieldname"
// 426:           end
// 427:
// 428:           if duplicate_name?(name)
// 429:             raise SyntaxError, "duplicate field '#{name}'"
// 430:           end
// 431:
// 432:           if name_shadows_method?(name)
// 433:             raise SyntaxError, "field '#{name}' shadows an existing method"
// 434:           end
// 435:
// 436:           if name_is_reserved?(name)
// 437:             raise SyntaxError, "field '#{name}' is a reserved name"
// 438:           end
// 439:         end
// 440:       end
// 441:
// 442:       def must_not_have_a_name_failed?(name)
// 443:         option?(:no_fieldnames) && !name.nil?
// 444:       end
// 445:
// 446:       def must_have_a_name_failed?(name)
// 447:         option?(:mandatory_fieldnames) && name.nil?
// 448:       end
// 449:
// 450:       def all_or_none_names_failed?(name)
// 451:         if option?(:all_or_none_fieldnames) && !fields.empty?
// 452:           all_names_blank = fields.all_field_names_blank?
// 453:           no_names_blank = fields.no_field_names_blank?
// 454:
// 455:           (!name.nil? && all_names_blank) || (name.nil? && no_names_blank)
// 456:         else
// 457:           false
// 458:         end
// 459:       end
// 460:
// 461:       def malformed_name?(name)
// 462:         !/^[a-z_]\w*$/.match?(name.to_s)
// 463:       end
// 464:
// 465:       def duplicate_name?(name)
// 466:         fields.field_name?(name)
// 467:       end
// 468:
// 469:       def name_shadows_method?(name)
// 470:         @the_class.method_defined?(name)
// 471:       end
// 472:
// 473:       def name_is_reserved?(name)
// 474:         BinData::Struct::RESERVED.include?(name.to_sym)
// 475:       end
// 476:
// 477:       def fields
// 478:         @dsl_parser.fields
// 479:       end
// 480:
// 481:       def option?(opt)
// 482:         @dsl_parser.send(:option?, opt)
// 483:       end
// 484:     end
// 485:   end
// 486: end
