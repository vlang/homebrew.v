module http

import time

// Translated from Homebrew/brew `vendor/gems/mechanize-2.14.0/lib/mechanize/http/content_disposition_parser.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ContentDispositionScanner {
pub:
	input string
pub mut:
	position int
}

pub struct ContentDispositionParameters {
pub mut:
	filename          ?string
	creation_date     ?time.Time
	modification_date ?time.Time
	read_date         ?time.Time
	size              ?i64
	parameters        map[string]string
}

pub struct ContentDisposition {
pub:
	disposition_type  ?string
	filename          ?string
	creation_date     ?time.Time
	modification_date ?time.Time
	read_date         ?time.Time
	size              ?i64
	parameters        map[string]string
}

pub struct ContentDispositionParser {
mut:
	scanner     ContentDispositionScanner
	has_scanner bool
}

pub fn new_content_disposition_scanner(input string) ContentDispositionScanner {
	return ContentDispositionScanner{
		input: input
	}
}

pub fn new_content_disposition_parser() ContentDispositionParser {
	return ContentDispositionParser{}
}

fn (scanner &ContentDispositionScanner) at_end() bool {
	return scanner.position >= scanner.input.len
}

fn (scanner &ContentDispositionScanner) peek_byte() ?u8 {
	if scanner.at_end() {
		return none
	}
	return scanner.input[scanner.position]
}

fn (mut scanner ContentDispositionScanner) scan_ascii_case_insensitive(text string) bool {
	if scanner.position + text.len > scanner.input.len {
		return false
	}
	candidate := scanner.input[scanner.position..scanner.position + text.len].clone()
	if candidate.to_lower() != text.to_lower() {
		return false
	}
	scanner.position += text.len
	return true
}

fn (mut scanner ContentDispositionScanner) scan_byte(character u8) bool {
	if current := scanner.peek_byte() {
		if current == character {
			scanner.position++
			return true
		}
	}
	return false
}

fn (mut scanner ContentDispositionScanner) scan_semicolons() bool {
	start := scanner.position
	for scanner.scan_byte(`;`) {
	}
	return scanner.position > start
}

fn content_disposition_token_byte(character u8) bool {
	if character <= 31 || character >= 127 || character == ` ` {
		return false
	}
	return character !in [`(`, `)`, `<`, `>`, `@`, `,`, `;`, `:`, `\\`, `"`, `/`, `[`, `]`, `?`,
		`=`]
}

fn ruby_decimal_integer(value string) i64 {
	if value.len == 0 {
		return 0
	}
	mut index := 0
	mut negative := false
	if value[0] == `-` || value[0] == `+` {
		negative = value[0] == `-`
		index++
	}
	mut parsed := i64(0)
	mut digits := 0
	for index < value.len && value[index] >= `0` && value[index] <= `9` {
		parsed = parsed * 10 + i64(value[index] - `0`)
		index++
		digits++
	}
	if digits == 0 {
		return 0
	}
	return if negative { -parsed } else { parsed }
}

fn content_disposition_date(value string) ?time.Time {
	if parsed := time.parse_rfc2822(value) {
		return parsed
	}
	if parsed := time.parse_iso8601(value) {
		return parsed
	}
	return none
}

pub fn parse_content_disposition(content_disposition string, header bool) ?ContentDisposition {
	mut parser := new_content_disposition_parser()
	return parser.parse(content_disposition, header)
}

pub fn (mut parser ContentDispositionParser) parse(content_disposition string,
	header bool) ?ContentDisposition {
	if content_disposition.len == 0 {
		return none
	}
	parser.scanner = new_content_disposition_scanner(content_disposition)
	parser.has_scanner = true
	if header {
		if !parser.scanner.scan_ascii_case_insensitive('Content-Disposition') {
			return none
		}
		if !parser.scanner.scan_byte(`:`) {
			return none
		}
		parser.spaces()
	}
	mut disposition_type := parser.rfc_2045_token()
	parser.spaces()
	parser.scanner.scan_semicolons()
	parser.spaces()
	if current := parser.scanner.peek_byte() {
		if current == `=` {
			parser.scanner.position = if header {
				'Content-Disposition:'.len
			} else {
				0
			}
			if header {
				parser.spaces()
			}
			disposition_type = none
		}
	}
	parameters := parser.parse_parameters() or { return none }
	return ContentDisposition{
		disposition_type: disposition_type
		filename: parameters.filename
		creation_date: parameters.creation_date
		modification_date: parameters.modification_date
		read_date: parameters.read_date
		size: parameters.size
		parameters: parameters.parameters.clone()
	}
}

pub fn (mut parser ContentDispositionParser) parse_parameters() ?ContentDispositionParameters {
	if !parser.has_scanner {
		return none
	}
	mut output := ContentDispositionParameters{
		parameters: map[string]string{}
	}
	for {
		parameter_name := parser.rfc_2045_token() or { return none }
		name := parameter_name.to_lower()
		if !parser.scanner.scan_byte(`=`) {
			return none
		}
		match name {
			'filename' {
				output.filename = parser.rfc_2045_value() or { return none }
			}
			'creation-date', 'modification-date', 'read-date' {
				value := parser.rfc_2045_quoted_string() or { return none }
				parsed := content_disposition_date(value) or { return none }
				match name {
					'creation-date' {
						output.creation_date = parsed
					}
					'modification-date' {
						output.modification_date = parsed
					}
					else {
						output.read_date = parsed
					}
				}
			}
			'size' {
				value := parser.rfc_2045_value() or { return none }
				output.size = ruby_decimal_integer(value)
			}
			else {
				output.parameters[name] = parser.rfc_2045_value() or { return none }
			}
		}
		parser.spaces()
		if parser.scanner.at_end() {
			break
		}
		if !parser.scanner.scan_semicolons() {
			return none
		}
		parser.spaces()
	}
	return output
}

pub fn (mut parser ContentDispositionParser) rfc_2045_quoted_string() ?string {
	if !parser.has_scanner || !parser.scanner.scan_byte(`"`) {
		return none
	}
	mut text := []u8{}
	for {
		character := parser.scanner.peek_byte() or { return none }
		if character == `"` {
			parser.scanner.position++
			return text.bytestr()
		}
		if character == `\\` {
			parser.scanner.position++
			escaped := parser.scanner.peek_byte() or { return none }
			text << escaped
			parser.scanner.position++
			continue
		}
		if character == `\r` {
			position := parser.scanner.position
			if position + 2 >= parser.scanner.input.len || parser.scanner.input[position + 1] != `\n` || parser.scanner.input[position + 2] !in [
				`\t`,
				` `,
			] {
				return none
			}
			parser.scanner.position += 2
			for parser.scanner.position < parser.scanner.input.len && parser.scanner.input[parser.scanner.position] in [
				`\t`,
				` `,
			] {
				parser.scanner.position++
			}
			text << ` `
			continue
		}
		if character <= 12 || (character >= 14 && character <= 33) || (character >= 35 && character <= 91) || (character >= 93 && character <= 127) {
			text << character
			parser.scanner.position++
			continue
		}
		return none
	}
	return none
}

pub fn (mut parser ContentDispositionParser) rfc_2045_token() ?string {
	if !parser.has_scanner {
		return none
	}
	start := parser.scanner.position
	for !parser.scanner.at_end() {
		character := parser.scanner.peek_byte() or { break }
		if !content_disposition_token_byte(character) {
			break
		}
		parser.scanner.position++
	}
	if parser.scanner.position == start {
		return none
	}
	return parser.scanner.input[start..parser.scanner.position]
}

pub fn (mut parser ContentDispositionParser) rfc_2045_value() ?string {
	if !parser.has_scanner {
		return none
	}
	if character := parser.scanner.peek_byte() {
		if character == `"` {
			return parser.rfc_2045_quoted_string()
		}
	}
	return parser.rfc_2045_token()
}

pub fn (mut parser ContentDispositionParser) spaces() ?string {
	if !parser.has_scanner {
		return none
	}
	start := parser.scanner.position
	for parser.scanner.scan_byte(` `) {
	}
	if parser.scanner.position == start {
		return none
	}
	return parser.scanner.input[start..parser.scanner.position]
}

// Ruby attr_accessor `attr_accessor :scanner` at line 24.
pub fn ruby_content_disposition_parser_l24_d1_scanner(parser &ContentDispositionParser) ?ContentDispositionScanner {
	if !parser.has_scanner {
		return none
	}
	return parser.scanner
}

// Ruby attr_accessor `attr_accessor :scanner` at line 24.
pub fn ruby_content_disposition_parser_l24_d2_scanner(mut parser ContentDispositionParser,
	scanner ContentDispositionScanner) ContentDispositionScanner {
	parser.scanner = scanner
	parser.has_scanner = true
	return scanner
}

// Ruby method `self.parse content_disposition` at line 32.
pub fn ruby_content_disposition_parser_l32_d3_self_parse(content_disposition string) ?ContentDisposition {
	return parse_content_disposition(content_disposition, false)
}

// Ruby method `initialize` at line 40.
pub fn ruby_content_disposition_parser_l40_d4_initialize() ContentDispositionParser {
	return new_content_disposition_parser()
}

// Ruby method `parse content_disposition, header = false` at line 48.
pub fn ruby_content_disposition_parser_l48_d5_parse(mut parser ContentDispositionParser,
	content_disposition string, header bool) ?ContentDisposition {
	return parser.parse(content_disposition, header)
}

// Ruby method `parse_parameters` at line 86.
pub fn ruby_content_disposition_parser_l86_d6_parse_parameters(mut parser ContentDispositionParser) ?ContentDispositionParameters {
	return parser.parse_parameters()
}

// Ruby method `rfc_2045_quoted_string` at line 137.
pub fn ruby_content_disposition_parser_l137_d7_rfc_2045_quoted_string(mut parser ContentDispositionParser) ?string {
	return parser.rfc_2045_quoted_string()
}

// Ruby method `rfc_2045_token` at line 176.
pub fn ruby_content_disposition_parser_l176_d8_rfc_2045_token(mut parser ContentDispositionParser) ?string {
	return parser.rfc_2045_token()
}

// Ruby method `rfc_2045_value` at line 185.
pub fn ruby_content_disposition_parser_l185_d9_rfc_2045_value(mut parser ContentDispositionParser) ?string {
	return parser.rfc_2045_value()
}

// Ruby method `spaces` at line 198.
pub fn ruby_content_disposition_parser_l198_d10_spaces(mut parser ContentDispositionParser) ?string {
	return parser.spaces()
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
