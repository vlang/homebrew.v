module http

import brew_runtime

// Translated from Homebrew/brew `vendor/gems/mechanize-2.14.0/lib/mechanize/http/content_disposition_parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :scanner` at line 24.
pub fn ruby_content_disposition_parser_l24_d1_scanner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scanner', ...args)
}

// Ruby attr_accessor `attr_accessor :scanner` at line 24.
pub fn ruby_content_disposition_parser_l24_d2_scanner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scanner=', ...args)
}

// Ruby method `self.parse content_disposition` at line 32.
pub fn ruby_content_disposition_parser_l32_d3_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parse', ...args)
}

// Ruby method `initialize` at line 40.
pub fn ruby_content_disposition_parser_l40_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `parse content_disposition, header = false` at line 48.
pub fn ruby_content_disposition_parser_l48_d5_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse', ...args)
}

// Ruby method `parse_parameters` at line 86.
pub fn ruby_content_disposition_parser_l86_d6_parse_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_parameters', ...args)
}

// Ruby method `rfc_2045_quoted_string` at line 137.
pub fn ruby_content_disposition_parser_l137_d7_rfc_2045_quoted_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rfc_2045_quoted_string', ...args)
}

// Ruby method `rfc_2045_token` at line 176.
pub fn ruby_content_disposition_parser_l176_d8_rfc_2045_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rfc_2045_token', ...args)
}

// Ruby method `rfc_2045_value` at line 185.
pub fn ruby_content_disposition_parser_l185_d9_rfc_2045_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rfc_2045_value', ...args)
}

// Ruby method `spaces` at line 198.
pub fn ruby_content_disposition_parser_l198_d10_spaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('spaces', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # coding: BINARY
// 3:
// 4: require 'strscan'
// 5: require 'time'
// 6:
// 7: class Mechanize::HTTP
// 8:   ContentDisposition = Struct.new :type, :filename, :creation_date,
// 9:     :modification_date, :read_date, :size, :parameters
// 10: end
// 11:
// 12: ##
// 13: # Parser Content-Disposition headers that loosely follows RFC 2183.
// 14: #
// 15: # Beyond RFC 2183, this parser allows:
// 16: #
// 17: # * Missing disposition-type
// 18: # * Multiple semicolons
// 19: # * Whitespace around semicolons
// 20: # * Dates in ISO 8601 format
// 21:
// 22: class Mechanize::HTTP::ContentDispositionParser
// 23:
// 24:   attr_accessor :scanner # :nodoc:
// 25:
// 26:   @parser = nil
// 27:
// 28:   ##
// 29:   # Parses the disposition type and params in the +content_disposition+
// 30:   # string.  The "Content-Disposition:" must be removed.
// 31:
// 32:   def self.parse content_disposition
// 33:     @parser ||= self.new
// 34:     @parser.parse content_disposition
// 35:   end
// 36:
// 37:   ##
// 38:   # Creates a new parser Content-Disposition headers
// 39:
// 40:   def initialize
// 41:     @scanner = nil
// 42:   end
// 43:
// 44:   ##
// 45:   # Parses the +content_disposition+ header.  If +header+ is set to true the
// 46:   # "Content-Disposition:" portion will be parsed
// 47:
// 48:   def parse content_disposition, header = false
// 49:     return nil if content_disposition.empty?
// 50:
// 51:     @scanner = StringScanner.new content_disposition
// 52:
// 53:     if header then
// 54:       return nil unless @scanner.scan(/Content-Disposition/i)
// 55:       return nil unless @scanner.scan(/:/)
// 56:       spaces
// 57:     end
// 58:
// 59:     type = rfc_2045_token
// 60:     @scanner.scan(/;+/)
// 61:
// 62:     if @scanner.peek(1) == '=' then
// 63:       @scanner.pos = 0
// 64:       type = nil
// 65:     end
// 66:
// 67:     disposition = Mechanize::HTTP::ContentDisposition.new type
// 68:
// 69:     spaces
// 70:
// 71:     return nil unless parameters = parse_parameters
// 72:
// 73:     disposition.filename          = parameters.delete 'filename'
// 74:     disposition.creation_date     = parameters.delete 'creation-date'
// 75:     disposition.modification_date = parameters.delete 'modification-date'
// 76:     disposition.read_date         = parameters.delete 'read-date'
// 77:     disposition.size              = parameters.delete 'size'
// 78:     disposition.parameters        = parameters
// 79:
// 80:     disposition
// 81:   end
// 82:
// 83:   ##
// 84:   # Extracts disposition-param and returns a Hash.
// 85:
// 86:   def parse_parameters
// 87:     parameters = {}
// 88:
// 89:     while true do
// 90:       return nil unless param = rfc_2045_token
// 91:       param.downcase!
// 92:       return nil unless @scanner.scan(/=/)
// 93:
// 94:       value = case param
// 95:               when /^filename$/ then
// 96:                 rfc_2045_value
// 97:               when /^(creation|modification|read)-date$/ then
// 98:                 date = rfc_2045_quoted_string
// 99:
// 100:                 begin
// 101:                   Time.rfc822 date
// 102:                 rescue ArgumentError
// 103:                   begin
// 104:                     Time.iso8601 date
// 105:                   rescue ArgumentError
// 106:                     nil
// 107:                   end
// 108:                 end
// 109:               when /^size$/ then
// 110:                 rfc_2045_value.to_i(10)
// 111:               else
// 112:                 rfc_2045_value
// 113:               end
// 114:
// 115:       return nil unless value
// 116:
// 117:       parameters[param] = value
// 118:
// 119:       spaces
// 120:
// 121:       break if @scanner.eos? or not @scanner.scan(/;+/)
// 122:
// 123:       spaces
// 124:     end
// 125:
// 126:     parameters
// 127:   end
// 128:
// 129:   ##
// 130:   #   quoted-string = <"> *(qtext/quoted-pair) <">
// 131:   #   qtext         = <any CHAR excepting <">, "\" & CR,
// 132:   #                    and including linear-white-space
// 133:   #   quoted-pair   = "\" CHAR
// 134:   #
// 135:   # Parses an RFC 2045 quoted-string
// 136:
// 137:   def rfc_2045_quoted_string
// 138:     return nil unless @scanner.scan(/"/)
// 139:
// 140:     text = String.new
// 141:
// 142:     while true do
// 143:       chunk = @scanner.scan(/[\000-\014\016-\041\043-\133\135-\177]+/) # not \r "
// 144:
// 145:       if chunk then
// 146:         text << chunk
// 147:
// 148:         if @scanner.peek(1) == '\\' then
// 149:           @scanner.get_byte
// 150:           return nil if @scanner.eos?
// 151:           text << @scanner.get_byte
// 152:         elsif @scanner.scan(/\r\n[\t ]+/) then
// 153:           text << " "
// 154:         end
// 155:       else
// 156:         if '\\"' == @scanner.peek(2) then
// 157:           @scanner.skip(/\\/)
// 158:           text << @scanner.get_byte
// 159:         elsif '"' == @scanner.peek(1) then
// 160:           @scanner.get_byte
// 161:           break
// 162:         else
// 163:           return nil
// 164:         end
// 165:       end
// 166:     end
// 167:
// 168:     text
// 169:   end
// 170:
// 171:   ##
// 172:   #   token := 1*<any (US-ASCII) CHAR except SPACE, CTLs, or tspecials>
// 173:   #
// 174:   # Parses an RFC 2045 token
// 175:
// 176:   def rfc_2045_token
// 177:     @scanner.scan(/[^\000-\037\177()<>@,;:\\"\/\[\]?= ]+/)
// 178:   end
// 179:
// 180:   ##
// 181:   #   value := token / quoted-string
// 182:   #
// 183:   # Parses an RFC 2045 value
// 184:
// 185:   def rfc_2045_value
// 186:     if @scanner.peek(1) == '"' then
// 187:       rfc_2045_quoted_string
// 188:     else
// 189:       rfc_2045_token
// 190:     end
// 191:   end
// 192:
// 193:   ##
// 194:   #   1*SP
// 195:   #
// 196:   # Parses spaces
// 197:
// 198:   def spaces
// 199:     @scanner.scan(/ +/)
// 200:   end
// 201:
// 202: end
