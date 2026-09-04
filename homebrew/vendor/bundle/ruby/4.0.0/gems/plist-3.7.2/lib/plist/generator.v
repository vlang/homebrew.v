module plist

import ruby
import encoding.base64
import os
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/plist-3.7.2/lib/plist/generator.rb`.
// The original source is retained below until every stub has a typed V body.
pub const default_indent = '\t'

pub struct EmitOptions {
pub:
	indent string = default_indent
}

@[heap]
pub struct PlistBuilder {
pub:
	indent_str string
}

fn emit_options_from_value(value ruby.Value) EmitOptions {
	if value.type_name != 'Hash' {
		return EmitOptions{}
	}
	options := value.as_map() or { return EmitOptions{} }
	if 'indent' !in options {
		return EmitOptions{}
	}
	indent_value := options['indent']
	return EmitOptions{
		indent: ruby_string_for_plist(indent_value)
	}
}

fn ruby_string_for_plist(value ruby.Value) string {
	return match value.type_name {
		'NilClass' { '' }
		'Bool' { value.bool_data.str() }
		else { value.as_string() }
	}
}

fn escape_plist_html(contents string) string {
	// CGI.escapeHTML escapes ampersands first so newly introduced entities are
	// not escaped a second time.
	return contents.replace('&', '&amp;').replace("'", '&#39;').replace('"', '&quot;').replace('>', '&gt;').replace('<', '&lt;')
}

fn plist_date_text(element ruby.Value) !string {
	input := element.as_string()
	if element.type_name == 'Time' {
		parsed := time.parse_iso8601(input)!
		utc := if parsed.is_utc() { parsed } else { parsed.local_to_utc() }
		return '${utc.year:04d}-${utc.month:02d}-${utc.day:02d}T${utc.hour:02d}:${utc.minute:02d}:${utc.second:02d}Z'
	}
	// Date and DateTime use strftime directly in the Ruby source; unlike Time,
	// a DateTime offset is not converted to UTC before the trailing Z is emitted.
	wall_clock := if input.len >= 19 { input[..19] } else { input }
	parsed := time.parse_iso8601(wall_clock)!
	return '${parsed.year:04d}-${parsed.month:02d}-${parsed.day:02d}T${parsed.hour:02d}:${parsed.minute:02d}:${parsed.second:02d}Z'
}

fn ruby_marshal_payload(element ruby.Value) !string {
	if payload := element.attribute('ruby_marshal_data') {
		return payload
	}
	// Ruby's Marshal.dump(nil) is stable and nil otherwise reaches the source's
	// fallback branch. Other Ruby objects need their original Marshal byte stream,
	// which a generic Value deliberately cannot reconstruct from `to_s` alone.
	if element.type_name == 'NilClass' {
		return [u8(4), 8, `0`].bytestr()
	}
	return error('cannot Marshal.dump ${element.type_name} without ruby_marshal_data')
}

pub fn new_plist_builder(indent_str string) &PlistBuilder {
	return &PlistBuilder{
		indent_str: indent_str
	}
}

pub fn (builder &PlistBuilder) indent(contents string, level int) string {
	return builder.indent_str.repeat(level) + contents
}

pub fn (builder &PlistBuilder) tag(tag_type string, contents string, has_contents bool, level int) string {
	if !has_contents || contents == '' {
		return builder.indent('<${tag_type}/>\n', level)
	}
	return builder.indent('<${tag_type}>${contents}</${tag_type}>\n', level)
}

pub fn (builder &PlistBuilder) container_tag(tag_type string, contents string, level int) string {
	return builder.indent('<${tag_type}>\n', level) + contents + builder.indent('</${tag_type}>\n', level)
}

pub fn (builder &PlistBuilder) data_tag(data string, level int) string {
	encoded := base64.encode_str(data)
	mut lines := []string{}
	mut offset := 0
	for offset < encoded.len {
		end := if offset + 68 < encoded.len { offset + 68 } else { encoded.len }
		lines << builder.indent(encoded[offset..end], level)
		offset = end
	}
	return builder.container_tag('data', lines.join('\n') + '\n', level)
}

pub fn (builder &PlistBuilder) element_type(item ruby.Value) !string {
	return match item.type_name {
		'String', 'Symbol' { 'string' }
		'Integer' { 'integer' }
		'Float' { 'real' }
		else { error("Don't know about this data type... something must be wrong!") }
	}
}

pub fn (_ &PlistBuilder) comment_tag(content string) string {
	return '<!-- ${content} -->\n'
}

pub fn (builder &PlistBuilder) build(element ruby.Value, level int) !string {
	if node := element.attribute('to_plist_node') {
		return node
	}
	return match element.type_name {
		'Array' {
			values := element.as_array()!
			if values.len == 0 {
				builder.tag('array', '', false, level)
			} else {
				mut contents := ''
				for value in values {
					contents += builder.build(value, level + 1)!
				}
				builder.container_tag('array', contents, level)
			}
		}
		'Hash' {
			values := element.as_map()!
			if values.len == 0 {
				builder.tag('dict', '', false, level)
			} else {
				mut keys := values.keys()
				keys.sort()
				mut contents := ''
				for key in keys {
					contents += builder.tag('key', escape_plist_html(key), true, level + 1)
					contents += builder.build(values[key], level + 1)!
				}
				builder.container_tag('dict', contents, level)
			}
		}
		'Bool' { builder.tag(element.bool_data.str(), '', false, level) }
		'Time', 'Date', 'DateTime' { builder.tag('date', plist_date_text(element)!, true, level) }
		'String', 'Symbol', 'Integer', 'Float' {
			builder.tag(builder.element_type(element)!, escape_plist_html(ruby_string_for_plist(element)), true, level)
		}
		'IO', 'StringIO' { builder.data_tag(element.as_string(), level) }
		else {
			payload := ruby_marshal_payload(element)!
			builder.comment_tag('The <data> element below contains a Ruby object which has been serialized with Marshal.dump.') + builder.data_tag(payload, level)
		}
	}
}

pub fn wrap_plist(contents string) string {
	return '<?xml version="1.0" encoding="UTF-8"?>\n' + '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' + '<plist version="1.0">\n' + contents + '</plist>\n'
}

pub fn dump_plist(object ruby.Value, envelope bool, options EmitOptions) !string {
	builder := new_plist_builder(options.indent)
	output := builder.build(object, 0)!
	return if envelope { wrap_plist(output) } else { output }
}

pub fn save_plist_file(object ruby.Value, filename string, options EmitOptions) !int {
	contents := dump_plist(object, true, options)!
	os.write_file(filename, contents)!
	return contents.len
}

fn plist_builder_boundary(builder &PlistBuilder) ruby.Value {
	return ruby.structured_value('Plist::Emit::PlistBuilder', '#<Plist::Emit::PlistBuilder>', {
		'plist_builder_address': u64(voidptr(builder)).str()
	})
}

fn plist_builder_from_args(args []ruby.Value) &PlistBuilder {
	if args.len == 0 {
		panic('PlistBuilder method requires a receiver')
	}
	address := (args[0].attribute('plist_builder_address') or {
		panic('${args[0].type_name} has no translated PlistBuilder state')
	}).u64()
	return unsafe { &PlistBuilder(voidptr(address)) }
}

// Ruby method `to_plist(envelope = true, options = {})` at line 28.
pub fn ruby_generator_l28_d1_to_plist(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('to_plist requires a receiver')
	}
	envelope := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { true }
	options := if args.len > 2 { emit_options_from_value(args[2]) } else { EmitOptions{} }
	return ruby.string_value(dump_plist(args[0], envelope, options) or { panic(err) })
}

// Ruby method `save_plist(filename, options = {})` at line 33.
pub fn ruby_generator_l33_d2_save_plist(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('save_plist requires a receiver and filename')
	}
	options := if args.len > 2 { emit_options_from_value(args[2]) } else { EmitOptions{} }
	return ruby.int_value(save_plist_file(args[0], args[1].as_string(), options) or {
		panic(err)
	})
}

// Ruby method `self.dump(obj, envelope = true, options = {})` at line 45.
pub fn ruby_generator_l45_d3_self_dump(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Plist::Emit.dump requires an object')
	}
	envelope := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { true }
	options := if args.len > 2 { emit_options_from_value(args[2]) } else { EmitOptions{} }
	return ruby.string_value(dump_plist(args[0], envelope, options) or { panic(err) })
}

// Ruby method `self.save_plist(obj, filename, options = {})` at line 55.
pub fn ruby_generator_l55_d4_self_save_plist(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Plist::Emit.save_plist requires an object and filename')
	}
	options := if args.len > 2 { emit_options_from_value(args[2]) } else { EmitOptions{} }
	return ruby.int_value(save_plist_file(args[0], args[1].as_string(), options) or {
		panic(err)
	})
}

// Ruby method `initialize(indent_str)` at line 64.
pub fn ruby_generator_l64_d5_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('PlistBuilder.initialize requires an indent string')
	}
	return plist_builder_boundary(new_plist_builder(ruby_string_for_plist(args[0])))
}

// Ruby method `build(element, level=0)` at line 68.
pub fn ruby_generator_l68_d6_build(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PlistBuilder.build requires an element')
	}
	builder := plist_builder_from_args(args)
	level := if args.len > 2 { int(args[2].as_int() or { panic(err) }) } else { 0 }
	return ruby.string_value(builder.build(args[1], level) or { panic(err) })
}

// Ruby method `tag(type, contents, level, &block)` at line 113.
pub fn ruby_generator_l113_d7_tag(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('PlistBuilder.tag requires type, contents, and level')
	}
	builder := plist_builder_from_args(args)
	tag_type := ruby_string_for_plist(args[1])
	level := int(args[3].as_int() or { panic(err) })
	if args.len > 4 {
		return ruby.string_value(builder.container_tag(tag_type, args[4].as_string(), level))
	}
	has_contents := args[2].type_name != 'NilClass'
	return ruby.string_value(builder.tag(tag_type, ruby_string_for_plist(args[2]), has_contents, level))
}

// Ruby method `data_tag(data, level)` at line 125.
pub fn ruby_generator_l125_d8_data_tag(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('PlistBuilder.data_tag requires data and level')
	}
	builder := plist_builder_from_args(args)
	return ruby.string_value(builder.data_tag(args[1].as_string(), int(args[2].as_int() or {
		panic(err)
	})))
}

// Ruby method `indent(str, level)` at line 138.
pub fn ruby_generator_l138_d9_indent(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('PlistBuilder.indent requires a string and level')
	}
	builder := plist_builder_from_args(args)
	return ruby.string_value(builder.indent(args[1].as_string(), int(args[2].as_int() or {
		panic(err)
	})))
}

// Ruby method `element_type(item)` at line 142.
pub fn ruby_generator_l142_d10_element_type(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PlistBuilder.element_type requires an item')
	}
	builder := plist_builder_from_args(args)
	return ruby.string_value(builder.element_type(args[1]) or { panic(err) })
}

// Ruby method `comment_tag(content)` at line 155.
pub fn ruby_generator_l155_d11_comment_tag(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PlistBuilder.comment_tag requires content')
	}
	builder := plist_builder_from_args(args)
	return ruby.string_value(builder.comment_tag(args[1].as_string()))
}

// Ruby method `self.wrap(contents)` at line 160.
pub fn ruby_generator_l160_d12_self_wrap(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Plist::Emit.wrap requires contents')
	}
	return ruby.string_value(wrap_plist(args[0].as_string()))
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
// 9: module Plist
// 10:   # === Create a plist
// 11:   # You can dump an object to a plist in one of two ways:
// 12:   #
// 13:   # * <tt>Plist::Emit.dump(obj)</tt>
// 14:   # * <tt>obj.to_plist</tt>
// 15:   #   * This requires that you mixin the <tt>Plist::Emit</tt> module, which is already done for +Array+ and +Hash+.
// 16:   #
// 17:   # The following Ruby classes are converted into native plist types:
// 18:   #   Array, Bignum, Date, DateTime, Fixnum, Float, Hash, Integer, String, Symbol, Time, true, false
// 19:   # * +Array+ and +Hash+ are both recursive; their elements will be converted into plist nodes inside the <array> and <dict> containers (respectively).
// 20:   # * +IO+ (and its descendants) and +StringIO+ objects are read from and their contents placed in a <data> element.
// 21:   # * User classes may implement +to_plist_node+ to dictate how they should be serialized; otherwise the object will be passed to <tt>Marshal.dump</tt> and the result placed in a <data> element.
// 22:   #
// 23:   # For detailed usage instructions, refer to USAGE[link:files/docs/USAGE.html] and the methods documented below.
// 24:   module Emit
// 25:     DEFAULT_INDENT = "\t"
// 26:
// 27:     # Helper method for injecting into classes.  Calls <tt>Plist::Emit.dump</tt> with +self+.
// 28:     def to_plist(envelope = true, options = {})
// 29:       Plist::Emit.dump(self, envelope, options)
// 30:     end
// 31:
// 32:     # Helper method for injecting into classes.  Calls <tt>Plist::Emit.save_plist</tt> with +self+.
// 33:     def save_plist(filename, options = {})
// 34:       Plist::Emit.save_plist(self, filename, options)
// 35:     end
// 36:
// 37:     # The following Ruby classes are converted into native plist types:
// 38:     #   Array, Bignum, Date, DateTime, Fixnum, Float, Hash, Integer, String, Symbol, Time
// 39:     #
// 40:     # Write us (via RubyForge) if you think another class can be coerced safely into one of the expected plist classes.
// 41:     #
// 42:     # +IO+ and +StringIO+ objects are encoded and placed in <data> elements; other objects are <tt>Marshal.dump</tt>'ed unless they implement +to_plist_node+.
// 43:     #
// 44:     # The +envelope+ parameters dictates whether or not the resultant plist fragment is wrapped in the normal XML/plist header and footer.  Set it to false if you only want the fragment.
// 45:     def self.dump(obj, envelope = true, options = {})
// 46:       options = { :indent => DEFAULT_INDENT }.merge(options)
// 47:
// 48:       output = PlistBuilder.new(options[:indent]).build(obj)
// 49:       output = wrap(output) if envelope
// 50:
// 51:       output
// 52:     end
// 53:
// 54:     # Writes the serialized object's plist to the specified filename.
// 55:     def self.save_plist(obj, filename, options = {})
// 56:       File.open(filename, 'wb') do |f|
// 57:         f.write(obj.to_plist(true, options))
// 58:       end
// 59:     end
// 60:
// 61:     private
// 62:
// 63:     class PlistBuilder
// 64:       def initialize(indent_str)
// 65:         @indent_str = indent_str.to_s
// 66:       end
// 67:
// 68:       def build(element, level=0)
// 69:         if element.respond_to? :to_plist_node
// 70:           element.to_plist_node
// 71:         else
// 72:           case element
// 73:           when Array
// 74:             if element.empty?
// 75:               tag('array', nil, level)
// 76:             else
// 77:               tag('array', nil, level) {
// 78:                 element.collect {|e| build(e, level + 1) }.join
// 79:               }
// 80:             end
// 81:           when Hash
// 82:             if element.empty?
// 83:               tag('dict', nil, level)
// 84:             else
// 85:               tag('dict', '', level) do
// 86:                 element.sort_by{|k,v| k.to_s }.collect do |k,v|
// 87:                   tag('key', CGI.escapeHTML(k.to_s), level + 1) +
// 88:                   build(v, level + 1)
// 89:                 end.join
// 90:               end
// 91:             end
// 92:           when true, false
// 93:             tag(element, nil, level)
// 94:           when Time
// 95:             tag('date', element.utc.strftime('%Y-%m-%dT%H:%M:%SZ'), level)
// 96:           when Date # also catches DateTime
// 97:             tag('date', element.strftime('%Y-%m-%dT%H:%M:%SZ'), level)
// 98:           when String, Symbol, Integer, Float
// 99:             tag(element_type(element), CGI.escapeHTML(element.to_s), level)
// 100:           when IO, StringIO
// 101:             data = element.tap(&:rewind).read
// 102:             data_tag(data, level)
// 103:           else
// 104:             data = Marshal.dump(element)
// 105:             comment_tag('The <data> element below contains a Ruby object which has been serialized with Marshal.dump.') +
// 106:             data_tag(data, level)
// 107:           end
// 108:         end
// 109:       end
// 110:
// 111:       private
// 112:
// 113:       def tag(type, contents, level, &block)
// 114:         if block_given?
// 115:           indent("<#{type}>\n", level) +
// 116:           block.call +
// 117:           indent("</#{type}>\n", level)
// 118:         elsif contents.to_s.empty?
// 119:           indent("<#{type}/>\n", level)
// 120:         else
// 121:           indent("<#{type}>#{contents.to_s}</#{type}>\n", level)
// 122:         end
// 123:       end
// 124:
// 125:       def data_tag(data, level)
// 126:         # note that apple plists are wrapped at a different length then
// 127:         # what ruby's pack wraps by default.
// 128:         tag('data', nil, level) do
// 129:           [data].pack("m") # equivalent to Base64.encode64(data)
// 130:                 .gsub(/\s+/, '')
// 131:                 .scan(/.{1,68}/o)
// 132:                 .collect { |line| indent(line, level) }
// 133:                 .join("\n")
// 134:                 .concat("\n")
// 135:         end
// 136:       end
// 137:
// 138:       def indent(str, level)
// 139:         @indent_str.to_s * level + str
// 140:       end
// 141:
// 142:       def element_type(item)
// 143:         case item
// 144:         when String, Symbol
// 145:           'string'
// 146:         when Integer
// 147:           'integer'
// 148:         when Float
// 149:           'real'
// 150:         else
// 151:           raise "Don't know about this data type... something must be wrong!"
// 152:         end
// 153:       end
// 154:
// 155:       def comment_tag(content)
// 156:         return "<!-- #{content} -->\n"
// 157:       end
// 158:     end
// 159:
// 160:     def self.wrap(contents)
// 161:       output =  '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
// 162:       output << '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' + "\n"
// 163:       output << '<plist version="1.0">' + "\n"
// 164:       output << contents
// 165:       output << '</plist>' + "\n"
// 166:
// 167:       output
// 168:     end
// 169:   end
// 170: end
// 171:
// 172: class Array #:nodoc:
// 173:   include Plist::Emit
// 174: end
// 175:
// 176: class Hash #:nodoc:
// 177:   include Plist::Emit
// 178: end
