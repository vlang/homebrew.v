module plist

import brew_runtime
import encoding.base64
import encoding.html
import encoding.xml
import os
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/plist-3.7.2/lib/plist/parser.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PTagKind {
	base
	plist
	dict
	key
	string
	array
	integer
	true_value
	false_value
	real
	date
	data
}

pub struct PTagOptions {
pub:
	marshal bool = true
}

@[heap]
pub struct PTag {
pub:
	kind PTagKind
mut:
	text     string
	has_text bool
	children []&PTag
	options  PTagOptions
}

@[heap]
pub struct PlistListener {
mut:
	result  brew_runtime.Value
	open    []&PTag
	options PTagOptions
}

@[heap]
pub struct PlistStreamParser {
pub:
	xml_text string
mut:
	listener &PlistListener
}

fn plist_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn ptag_kind_for_name(name string) !PTagKind {
	return match name.to_lower() {
		'plist' { .plist }
		'dict' { .dict }
		'key' { .key }
		'string' { .string }
		'array' { .array }
		'integer' { .integer }
		'true' { .true_value }
		'false' { .false_value }
		'real' { .real }
		'date' { .date }
		'data' { .data }
		else {
			return error('Unimplemented element. Consider reporting via https://github.com/patsplat/plist/issues')
		}
	}
}

fn ptag_name(kind PTagKind) string {
	return match kind {
		.base { 'PTag' }
		.plist { 'PList' }
		.dict { 'PDict' }
		.key { 'PKey' }
		.string { 'PString' }
		.array { 'PArray' }
		.integer { 'PInteger' }
		.true_value { 'PTrue' }
		.false_value { 'PFalse' }
		.real { 'PReal' }
		.date { 'PDate' }
		.data { 'PData' }
	}
}

fn ptag_options_from_value(value brew_runtime.Value) PTagOptions {
	if value.type_name != 'Hash' {
		return PTagOptions{}
	}
	options := value.as_map() or { return PTagOptions{} }
	return PTagOptions{
		marshal: if 'marshal' in options { options['marshal'].as_bool() or { true } } else { true }
	}
}

fn ptag_options_value(options PTagOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'marshal': brew_runtime.bool_value(options.marshal)
	})
}

pub fn new_ptag(kind PTagKind, options PTagOptions) &PTag {
	return &PTag{
		kind: kind
		options: options
	}
}

pub fn (mut tag PTag) append_text(contents string) {
	if !tag.has_text {
		tag.text = ''
		tag.has_text = true
	}
	tag.text += contents
}

pub fn (mut tag PTag) append_child(child &PTag) {
	tag.children << child
}

fn plist_unescape(value string) string {
	return html.unescape(value, all: true)
}

pub fn (mut tag PTag) to_ruby() !brew_runtime.Value {
	return match tag.kind {
		.base { error('Unimplemented: Plist::PTag#to_ruby') }
		.plist {
			if tag.children.len == 0 {
				plist_nil_value()
			} else {
				mut child := tag.children[0]
				child.to_ruby()!
			}
		}
		.dict {
			mut values := map[string]brew_runtime.Value{}
			mut index := 0
			for index + 1 < tag.children.len {
				mut key_tag := tag.children[index]
				mut value_tag := tag.children[index + 1]
				key := key_tag.to_ruby()!.as_string()
				values[key] = value_tag.to_ruby()!
				index += 2
			}
			brew_runtime.map_value(values)
		}
		.key, .string {
			brew_runtime.string_value(plist_unescape(if tag.has_text { tag.text } else { '' }))
		}
		.array {
			mut values := []brew_runtime.Value{cap: tag.children.len}
			for child_pointer in tag.children {
				mut child := unsafe { child_pointer }
				values << child.to_ruby()!
			}
			brew_runtime.array_value(values)
		}
		.integer { brew_runtime.int_value(tag.text.trim_space().i64()) }
		.true_value { brew_runtime.bool_value(true) }
		.false_value { brew_runtime.bool_value(false) }
		.real { brew_runtime.float_value(tag.text.trim_space().f64()) }
		.date {
			date_text := tag.text.trim_space()
			time.parse_iso8601(date_text)!
			brew_runtime.object_value('DateTime', date_text)
		}
		.data {
			encoded := tag.text.bytes().filter(it !in [` `, `\t`, `\r`, `\n`]).bytestr()
			decoded := base64.decode(encoded)
			// Ruby Marshal payloads are intentionally attempted and rescued by the
			// source. V cannot instantiate Ruby objects, so the rescued StringIO form
			// carries the exact decoded bytes through the typed boundary.
			brew_runtime.object_value('StringIO', decoded.bytestr())
		}
	}
}

pub fn new_plist_listener(options PTagOptions) &PlistListener {
	return &PlistListener{
		result: plist_nil_value()
		options: options
	}
}

pub fn (mut listener PlistListener) tag_start(name string) ! {
	listener.open << new_ptag(ptag_kind_for_name(name)!, listener.options)
}

pub fn (mut listener PlistListener) text(contents string) {
	if listener.open.len > 0 {
		mut last := listener.open[listener.open.len - 1]
		last.append_text(contents)
	}
}

pub fn (mut listener PlistListener) tag_end(_ string) ! {
	if listener.open.len == 0 {
		return error('closing plist tag without an open tag')
	}
	mut last := listener.open.pop()
	if listener.open.len == 0 {
		listener.result = last.to_ruby()!
	} else {
		mut parent := listener.open[listener.open.len - 1]
		parent.append_child(last)
	}
}

fn emit_plist_xml_node(node xml.XMLNode, mut listener PlistListener) ! {
	listener.tag_start(node.name)!
	for child in node.children {
		match child {
			xml.XMLNode { emit_plist_xml_node(child, mut listener)! }
			xml.XMLCData { listener.text(child.text) }
			xml.XMLComment {}
			string { listener.text(child) }
		}
	}
	listener.tag_end(node.name)!
}

pub fn new_plist_stream_parser(data_or_path string, listener &PlistListener) &PlistStreamParser {
	contents := if os.is_file(data_or_path) {
		os.read_file(data_or_path) or { data_or_path }
	} else {
		data_or_path
	}
	return &PlistStreamParser{
		xml_text: contents
		listener: listener
	}
}

fn strip_plist_doctype(contents string) string {
	start := contents.index('<!DOCTYPE') or { return contents }
	end_offset := contents[start..].index('>') or { return contents }
	return contents[..start] + contents[start + end_offset + 1..]
}

pub fn (mut parser PlistStreamParser) parse() ! {
	document := xml.XMLDocument.from_string(strip_plist_doctype(parser.xml_text))!
	emit_plist_xml_node(document.root, mut parser.listener)!
}

pub fn parse_plist_xml(data_or_path string, options PTagOptions) !brew_runtime.Value {
	mut listener := new_plist_listener(options)
	mut parser := new_plist_stream_parser(data_or_path, listener)
	parser.parse()!
	return listener.result
}

pub fn parse_plist_encoding(declaration string) ?string {
	lower := declaration.to_lower()
	marker := 'encoding='
	position := lower.index(marker) or { return none }
	remaining := declaration[position + marker.len..].trim_left(' \t\r\n')
	if remaining.len < 3 || (remaining[0] != `"` && remaining[0] != `'`) {
		return none
	}
	quote := remaining[0]
	end := remaining[1..].index_u8(quote)
	if end < 0 {
		return none
	}
	encoding := remaining[1..1 + end]
	if encoding.to_upper() !in ['UTF-8', 'UTF8', 'US-ASCII', 'ASCII', 'UTF-16', 'ISO-8859-1'] {
		return none
	}
	return encoding
}

fn ptag_boundary(tag &PTag) brew_runtime.Value {
	return brew_runtime.structured_value('Plist::${ptag_name(tag.kind)}', '#<Plist::${ptag_name(tag.kind)}>', {
		'ptag_address': u64(voidptr(tag)).str()
		'ptag_kind':    tag.kind.str()
	})
}

fn ptag_from_value(value brew_runtime.Value) &PTag {
	address := (value.attribute('ptag_address') or { panic('${value.type_name} has no translated PTag state') }).u64()
	return unsafe { &PTag(voidptr(address)) }
}

fn ptag_from_args(args []brew_runtime.Value) &PTag {
	if args.len == 0 {
		panic('PTag method requires a receiver')
	}
	return ptag_from_value(args[0])
}

fn listener_boundary(listener &PlistListener) brew_runtime.Value {
	return brew_runtime.structured_value('Plist::Listener', '#<Plist::Listener>', {
		'plist_listener_address': u64(voidptr(listener)).str()
	})
}

fn listener_from_value(value brew_runtime.Value) &PlistListener {
	address := (value.attribute('plist_listener_address') or { panic('${value.type_name} has no translated Listener state') }).u64()
	return unsafe { &PlistListener(voidptr(address)) }
}

fn listener_from_args(args []brew_runtime.Value) &PlistListener {
	if args.len == 0 {
		panic('Listener method requires a receiver')
	}
	return listener_from_value(args[0])
}

fn stream_parser_boundary(parser &PlistStreamParser) brew_runtime.Value {
	return brew_runtime.structured_value('Plist::StreamParser', '#<Plist::StreamParser>', {
		'plist_stream_parser_address': u64(voidptr(parser)).str()
	})
}

fn stream_parser_from_args(args []brew_runtime.Value) &PlistStreamParser {
	if args.len == 0 {
		panic('StreamParser method requires a receiver')
	}
	address := (args[0].attribute('plist_stream_parser_address') or {
		panic('${args[0].type_name} has no translated StreamParser state')
	}).u64()
	return unsafe { &PlistStreamParser(voidptr(address)) }
}

fn ptag_children_value(children []&PTag) brew_runtime.Value {
	return brew_runtime.array_value(children.map(ptag_boundary(it)))
}

fn ptag_children_from_value(value brew_runtime.Value) []&PTag {
	return (value.as_array() or { panic(err) }).map(ptag_from_value(it))
}

fn ptag_mappings_value() brew_runtime.Value {
	mut mappings := map[string]brew_runtime.Value{}
	for name in ['plist', 'dict', 'key', 'string', 'array', 'integer', 'true', 'false', 'real',
		'date', 'data'] {
		kind := ptag_kind_for_name(name) or { continue }
		mappings[name] = brew_runtime.string_value('Plist::${ptag_name(kind)}')
	}
	return brew_runtime.map_value(mappings)
}

// Ruby method `self.parse_xml(filename_or_xml, options={})` at line 34.
pub fn ruby_parser_l34_d1_self_parse_xml(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Plist.parse_xml requires XML or a filename')
	}
	options := if args.len > 1 { ptag_options_from_value(args[1]) } else { PTagOptions{} }
	return parse_plist_xml(args[0].as_string(), options) or { panic(err) }
}

// Ruby attr_accessor `attr_accessor :result, :open` at line 45.
pub fn ruby_parser_l45_d2_result(args ...brew_runtime.Value) brew_runtime.Value {
	listener := listener_from_args(args)
	return listener.result
}

// Ruby attr_accessor `attr_accessor :result, :open` at line 45.
pub fn ruby_parser_l45_d3_result(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Listener#result= requires a value')
	}
	mut listener := listener_from_args(args)
	listener.result = args[1]
	return args[1]
}

// Ruby attr_accessor `attr_accessor :result, :open` at line 45.
pub fn ruby_parser_l45_d4_open(args ...brew_runtime.Value) brew_runtime.Value {
	listener := listener_from_args(args)
	return ptag_children_value(listener.open)
}

// Ruby attr_accessor `attr_accessor :result, :open` at line 45.
pub fn ruby_parser_l45_d5_open(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Listener#open= requires an Array')
	}
	mut listener := listener_from_args(args)
	listener.open = ptag_children_from_value(args[1])
	return args[1]
}

// Ruby method `initialize(options={})` at line 47.
pub fn ruby_parser_l47_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 { ptag_options_from_value(args[0]) } else { PTagOptions{} }
	return listener_boundary(new_plist_listener(options))
}

// Ruby method `tag_start(name, attributes)` at line 53.
pub fn ruby_parser_l53_d7_tag_start(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Listener#tag_start requires a name')
	}
	mut listener := listener_from_args(args)
	listener.tag_start(args[1].as_string()) or { panic(err) }
	return ptag_children_value(listener.open)
}

// Ruby method `text(contents)` at line 57.
pub fn ruby_parser_l57_d8_text(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Listener#text requires contents')
	}
	mut listener := listener_from_args(args)
	listener.text(args[1].as_string())
	return if listener.open.len > 0 {
		brew_runtime.string_value(listener.open.last().text)
	} else {
		plist_nil_value()
	}
}

// Ruby method `tag_end(name)` at line 64.
pub fn ruby_parser_l64_d9_tag_end(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Listener#tag_end requires a name')
	}
	mut listener := listener_from_args(args)
	listener.tag_end(args[1].as_string()) or { panic(err) }
	return if listener.open.len == 0 {
		listener.result
	} else {
		ptag_children_value(listener.open.last().children)
	}
}

// Ruby method `initialize(plist_data_or_file, listener)` at line 75.
pub fn ruby_parser_l75_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('StreamParser#initialize requires XML/path and listener')
	}
	listener := listener_from_value(args[1])
	return stream_parser_boundary(new_plist_stream_parser(args[0].as_string(), listener))
}

// Ruby method `parse` at line 96.
pub fn ruby_parser_l96_d11_parse(args ...brew_runtime.Value) brew_runtime.Value {
	mut parser := stream_parser_from_args(args)
	parser.parse() or { panic(err) }
	return plist_nil_value()
}

// Ruby method `parse_encoding_from_xml_declaration(xml_declaration)` at line 135.
pub fn ruby_parser_l135_d12_parse_encoding_from_xml_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return plist_nil_value()
	}
	return if encoding := parse_plist_encoding(args[args.len - 1].as_string()) {
		brew_runtime.string_value(encoding)
	} else {
		plist_nil_value()
	}
}

// Ruby method `self.mappings` at line 151.
pub fn ruby_parser_l151_d13_self_mappings(args ...brew_runtime.Value) brew_runtime.Value {
	return ptag_mappings_value()
}

// Ruby method `self.inherited(sub_class)` at line 155.
pub fn ruby_parser_l155_d14_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return plist_nil_value()
	}
	mut key := args[args.len - 1].as_string().to_lower()
	key = key.trim_string_left('plist::')
	if key != 'plist' {
		key = key.trim_string_left('p')
	}
	ptag_kind_for_name(key) or { panic(err) }
	return brew_runtime.string_value(key)
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d15_text(args ...brew_runtime.Value) brew_runtime.Value {
	tag := ptag_from_args(args)
	return if tag.has_text { brew_runtime.string_value(tag.text) } else { plist_nil_value() }
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d16_text(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('PTag#text= requires a value')
	}
	mut tag := ptag_from_args(args)
	if args[1].type_name == 'NilClass' {
		tag.text = ''
		tag.has_text = false
	} else {
		tag.text = args[1].as_string()
		tag.has_text = true
	}
	return args[1]
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d17_children(args ...brew_runtime.Value) brew_runtime.Value {
	tag := ptag_from_args(args)
	return ptag_children_value(tag.children)
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d18_children(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('PTag#children= requires an Array')
	}
	mut tag := ptag_from_args(args)
	tag.children = ptag_children_from_value(args[1])
	return args[1]
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d19_options(args ...brew_runtime.Value) brew_runtime.Value {
	tag := ptag_from_args(args)
	return ptag_options_value(tag.options)
}

// Ruby attr_accessor `attr_accessor :text, :children, :options` at line 163.
pub fn ruby_parser_l163_d20_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('PTag#options= requires a Hash')
	}
	mut tag := ptag_from_args(args)
	tag.options = ptag_options_from_value(args[1])
	return args[1]
}

// Ruby method `initialize(options)` at line 164.
pub fn ruby_parser_l164_d21_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut kind := PTagKind.base
	mut options := PTagOptions{}
	if args.len > 0 && args[0].type_name == 'String' {
		kind = ptag_kind_for_name(args[0].as_string()) or { PTagKind.base }
		if args.len > 1 {
			options = ptag_options_from_value(args[1])
		}
	} else if args.len > 0 {
		options = ptag_options_from_value(args[0])
	}
	return ptag_boundary(new_ptag(kind, options))
}

// Ruby method `to_ruby` at line 169.
pub fn ruby_parser_l169_d22_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 175.
pub fn ruby_parser_l175_d23_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 181.
pub fn ruby_parser_l181_d24_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 199.
pub fn ruby_parser_l199_d25_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 205.
pub fn ruby_parser_l205_d26_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 211.
pub fn ruby_parser_l211_d27_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 219.
pub fn ruby_parser_l219_d28_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 225.
pub fn ruby_parser_l225_d29_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 231.
pub fn ruby_parser_l231_d30_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 237.
pub fn ruby_parser_l237_d31_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 244.
pub fn ruby_parser_l244_d32_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Ruby method `to_ruby` at line 250.
pub fn ruby_parser_l250_d33_to_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	mut tag := ptag_from_args(args)
	return tag.to_ruby() or { panic(err) }
}

// Original Ruby source (line-for-line):
// 1: # encoding: utf-8
// 2:
// 3: # = plist
// 4: #
// 5: # Copyright 2006-2010 Ben Bleything and Patrick May
// 6: # Distributed under the MIT License
// 7: #
// 8:
// 9: # Plist parses Mac OS X xml property list files into ruby data structures.
// 10: #
// 11: # === Load a plist file
// 12: # This is the main point of the library:
// 13: #
// 14: #   r = Plist.parse_xml(filename_or_xml)
// 15: module Plist
// 16:   # Raised when an element is not implemented
// 17:   class UnimplementedElementError < RuntimeError; end
// 18:
// 19:   # Note that I don't use these two elements much:
// 20:   #
// 21:   #  + Date elements are returned as DateTime objects.
// 22:   #  + Data elements are implemented as Tempfiles
// 23:   #
// 24:   # Plist.parse_xml will blow up if it encounters a Date element.
// 25:   # If you encounter such an error, or if you have a Date element which
// 26:   # can't be parsed into a Time object, please create an issue
// 27:   # attaching your plist file at https://github.com/patsplat/plist/issues
// 28:   # so folks can implement the proper support.
// 29:   #
// 30:   # By default, <data> will be assumed to be a marshaled Ruby object and
// 31:   # interpreted with <tt>Marshal.load</tt>. Pass <tt>marshal: false</tt>
// 32:   # to disable this behavior and return the raw binary data as an IO
// 33:   # object instead.
// 34:   def self.parse_xml(filename_or_xml, options={})
// 35:     listener = Listener.new(options)
// 36:     # parser = REXML::Parsers::StreamParser.new(File.new(filename), listener)
// 37:     parser = StreamParser.new(filename_or_xml, listener)
// 38:     parser.parse
// 39:     listener.result
// 40:   end
// 41:
// 42:   class Listener
// 43:     # include REXML::StreamListener
// 44:
// 45:     attr_accessor :result, :open
// 46:
// 47:     def initialize(options={})
// 48:       @result = nil
// 49:       @open   = []
// 50:       @options = { :marshal => true }.merge(options).freeze
// 51:     end
// 52:
// 53:     def tag_start(name, attributes)
// 54:       @open.push PTag.mappings[name].new(@options)
// 55:     end
// 56:
// 57:     def text(contents)
// 58:       if @open.last
// 59:         @open.last.text ||= ''.dup
// 60:         @open.last.text.concat(contents)
// 61:       end
// 62:     end
// 63:
// 64:     def tag_end(name)
// 65:       last = @open.pop
// 66:       if @open.empty?
// 67:         @result = last.to_ruby
// 68:       else
// 69:         @open.last.children.push last
// 70:       end
// 71:     end
// 72:   end
// 73:
// 74:   class StreamParser
// 75:     def initialize(plist_data_or_file, listener)
// 76:       if plist_data_or_file.respond_to? :read
// 77:         @xml = plist_data_or_file.read
// 78:       elsif File.exist? plist_data_or_file
// 79:         @xml = File.read(plist_data_or_file)
// 80:       else
// 81:         @xml = plist_data_or_file
// 82:       end
// 83:
// 84:       @listener = listener
// 85:     end
// 86:
// 87:     TEXT = /([^<]+)/
// 88:     CDATA = /<!\[CDATA\[(.*?)\]\]>/
// 89:     XMLDECL_PATTERN = /<\?xml\s+(.*?)\?>*/m
// 90:     DOCTYPE_PATTERN = /\s*<!DOCTYPE\s+(.*?)(\[|>)/m
// 91:     COMMENT_START = /\A<!--/
// 92:     COMMENT_END = /.*?-->/m
// 93:     UNIMPLEMENTED_ERROR = 'Unimplemented element. ' \
// 94:       'Consider reporting via https://github.com/patsplat/plist/issues'
// 95:
// 96:     def parse
// 97:       plist_tags = PTag.mappings.keys.join('|')
// 98:       start_tag  = /<(#{plist_tags})([^>]*)>/i
// 99:       end_tag    = /<\/(#{plist_tags})[^>]*>/i
// 100:
// 101:       require 'strscan'
// 102:
// 103:       @scanner = StringScanner.new(@xml)
// 104:       until @scanner.eos?
// 105:         if @scanner.scan(COMMENT_START)
// 106:           @scanner.scan(COMMENT_END)
// 107:         elsif @scanner.scan(XMLDECL_PATTERN)
// 108:           encoding = parse_encoding_from_xml_declaration(@scanner[1])
// 109:           next if encoding.nil?
// 110:
// 111:           # use the specified encoding for the rest of the file
// 112:           next unless String.method_defined?(:force_encoding)
// 113:           @scanner.string = @scanner.rest.force_encoding(encoding)
// 114:         elsif @scanner.scan(DOCTYPE_PATTERN)
// 115:           next
// 116:         elsif @scanner.scan(start_tag)
// 117:           @listener.tag_start(@scanner[1], nil)
// 118:           if (@scanner[2] =~ /\/$/)
// 119:             @listener.tag_end(@scanner[1])
// 120:           end
// 121:         elsif @scanner.scan(TEXT)
// 122:           @listener.text(@scanner[1])
// 123:         elsif @scanner.scan(CDATA)
// 124:           @listener.text(@scanner[1])
// 125:         elsif @scanner.scan(end_tag)
// 126:           @listener.tag_end(@scanner[1])
// 127:         else
// 128:           raise UnimplementedElementError.new(UNIMPLEMENTED_ERROR)
// 129:         end
// 130:       end
// 131:     end
// 132:
// 133:     private
// 134:
// 135:     def parse_encoding_from_xml_declaration(xml_declaration)
// 136:       return unless defined?(Encoding)
// 137:
// 138:       xml_encoding = xml_declaration.match(/(?:\A|\s)encoding=(?:"(.*?)"|'(.*?)')(?:\s|\Z)/)
// 139:
// 140:       return if xml_encoding.nil?
// 141:
// 142:       begin
// 143:         Encoding.find(xml_encoding[1])
// 144:       rescue ArgumentError
// 145:         nil
// 146:       end
// 147:     end
// 148:   end
// 149:
// 150:   class PTag
// 151:     def self.mappings
// 152:       @mappings ||= {}
// 153:     end
// 154:
// 155:     def self.inherited(sub_class)
// 156:       key = sub_class.to_s.downcase
// 157:       key.gsub!(/^plist::/, '')
// 158:       key.gsub!(/^p/, '')  unless key == "plist"
// 159:
// 160:       mappings[key] = sub_class
// 161:     end
// 162:
// 163:     attr_accessor :text, :children, :options
// 164:     def initialize(options)
// 165:       @children = []
// 166:       @options = options
// 167:     end
// 168:
// 169:     def to_ruby
// 170:       raise "Unimplemented: " + self.class.to_s + "#to_ruby on #{self.inspect}"
// 171:     end
// 172:   end
// 173:
// 174:   class PList < PTag
// 175:     def to_ruby
// 176:       children.first.to_ruby if children.first
// 177:     end
// 178:   end
// 179:
// 180:   class PDict < PTag
// 181:     def to_ruby
// 182:       dict = {}
// 183:       key = nil
// 184:
// 185:       children.each do |c|
// 186:         if key.nil?
// 187:           key = c.to_ruby
// 188:         else
// 189:           dict[key] = c.to_ruby
// 190:           key = nil
// 191:         end
// 192:       end
// 193:
// 194:       dict
// 195:     end
// 196:   end
// 197:
// 198:   class PKey < PTag
// 199:     def to_ruby
// 200:       CGI.unescapeHTML(text || '')
// 201:     end
// 202:   end
// 203:
// 204:   class PString < PTag
// 205:     def to_ruby
// 206:       CGI.unescapeHTML(text || '')
// 207:     end
// 208:   end
// 209:
// 210:   class PArray < PTag
// 211:     def to_ruby
// 212:       children.collect do |c|
// 213:         c.to_ruby
// 214:       end
// 215:     end
// 216:   end
// 217:
// 218:   class PInteger < PTag
// 219:     def to_ruby
// 220:       text.to_i
// 221:     end
// 222:   end
// 223:
// 224:   class PTrue < PTag
// 225:     def to_ruby
// 226:       true
// 227:     end
// 228:   end
// 229:
// 230:   class PFalse < PTag
// 231:     def to_ruby
// 232:       false
// 233:     end
// 234:   end
// 235:
// 236:   class PReal < PTag
// 237:     def to_ruby
// 238:       text.to_f
// 239:     end
// 240:   end
// 241:
// 242:   require 'date'
// 243:   class PDate < PTag
// 244:     def to_ruby
// 245:       DateTime.parse(text)
// 246:     end
// 247:   end
// 248:
// 249:   class PData < PTag
// 250:     def to_ruby
// 251:       # unpack("m")[0] is equivalent to Base64.decode64
// 252:       data = text.gsub(/\s+/, '').unpack("m")[0] unless text.nil?
// 253:       begin
// 254:         return Marshal.load(data) if options[:marshal]
// 255:       rescue Exception
// 256:       end
// 257:       io = StringIO.new
// 258:       io.write data
// 259:       io.rewind
// 260:       io
// 261:     end
// 262:   end
// 263: end
