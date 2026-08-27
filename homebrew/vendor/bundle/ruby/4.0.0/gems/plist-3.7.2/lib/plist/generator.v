module plist

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/plist-3.7.2/lib/plist/generator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `to_plist(envelope = true, options = {})` at line 28.
pub fn ruby_generator_l28_d1_to_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_plist', ...args)
}

// Ruby method `save_plist(filename, options = {})` at line 33.
pub fn ruby_generator_l33_d2_save_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('save_plist', ...args)
}

// Ruby method `self.dump(obj, envelope = true, options = {})` at line 45.
pub fn ruby_generator_l45_d3_self_dump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dump', ...args)
}

// Ruby method `self.save_plist(obj, filename, options = {})` at line 55.
pub fn ruby_generator_l55_d4_self_save_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.save_plist', ...args)
}

// Ruby method `initialize(indent_str)` at line 64.
pub fn ruby_generator_l64_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build(element, level=0)` at line 68.
pub fn ruby_generator_l68_d6_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build', ...args)
}

// Ruby method `tag(type, contents, level, &block)` at line 113.
pub fn ruby_generator_l113_d7_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag', ...args)
}

// Ruby method `data_tag(data, level)` at line 125.
pub fn ruby_generator_l125_d8_data_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('data_tag', ...args)
}

// Ruby method `indent(str, level)` at line 138.
pub fn ruby_generator_l138_d9_indent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('indent', ...args)
}

// Ruby method `element_type(item)` at line 142.
pub fn ruby_generator_l142_d10_element_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('element_type', ...args)
}

// Ruby method `comment_tag(content)` at line 155.
pub fn ruby_generator_l155_d11_comment_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comment_tag', ...args)
}

// Ruby method `self.wrap(contents)` at line 160.
pub fn ruby_generator_l160_d12_self_wrap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.wrap', ...args)
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
