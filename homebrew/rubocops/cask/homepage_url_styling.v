module cask

import brew_runtime
import net.urllib

// Translated from Homebrew/brew `rubocops/cask/homepage_url_styling.rb`.
// The original source is retained below until every stub has a typed V body.
pub const homepage_url_styling_message_template = "'%s' must have a slash after the domain."

pub struct HomepageUrlStylingOffense {
pub:
	cask_name   string
	url         string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct HomepageUrlLiteral {
	source           string
	content          string
	stripped_content string
	begin_pos        int
	end_pos          int
}

fn homepage_url_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn homepage_url_interpolation_end(source string, open_brace int) ?int {
	mut depth := 1
	mut cursor := open_brace + 1
	mut quote := u8(0)
	mut escaped := false
	for cursor < source.len {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			cursor++
			continue
		}
		if character == `'` || character == `"` {
			quote = character
		} else if character == `{` {
			depth++
		} else if character == `}` {
			depth--
			if depth == 0 {
				return cursor + 1
			}
		}
		cursor++
	}
	return none
}

fn homepage_url_quoted_end(source string, begin_pos int) ?int {
	if begin_pos >= source.len || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut cursor := begin_pos + 1
	mut escaped := false
	for cursor < source.len {
		character := source[cursor]
		if escaped {
			escaped = false
			cursor++
			continue
		}
		if character == `\\` {
			escaped = true
			cursor++
			continue
		}
		if quote == `"` && character == `#` && cursor + 1 < source.len && source[cursor + 1] == `{` {
			cursor = homepage_url_interpolation_end(source, cursor + 1) or { return none }
			continue
		}
		if character == quote {
			return cursor + 1
		}
		cursor++
	}
	return none
}

fn homepage_url_decode_string(content string, quote u8) string {
	mut decoded := []u8{cap: content.len}
	mut cursor := 0
	for cursor < content.len {
		if content[cursor] != `\\` || cursor + 1 >= content.len {
			decoded << content[cursor]
			cursor++
			continue
		}
		next := content[cursor + 1]
		if quote == `'` {
			if next == `\\` || next == `'` {
				decoded << next
			} else {
				decoded << `\\`
				decoded << next
			}
		} else {
			match next {
				`n` { decoded << `\n` }
				`r` { decoded << `\r` }
				`t` { decoded << `\t` }
				`f` { decoded << `\f` }
				`v` { decoded << `\v` }
				`a` { decoded << u8(7) }
				`b` { decoded << u8(8) }
				`e` { decoded << u8(27) }
				`\\`, `"`, `/`, `#` { decoded << next }
				else {
					decoded << `\\`
					decoded << next
				}
			}
		}
		cursor += 2
	}
	return decoded.bytestr()
}

fn homepage_url_dynamic_content(content string, quote u8) (bool, string) {
	if quote != `"` {
		return false, homepage_url_decode_string(content, quote)
	}
	mut dynamic := false
	mut static_content := []u8{cap: content.len}
	mut cursor := 0
	mut escaped := false
	for cursor < content.len {
		character := content[cursor]
		if escaped {
			static_content << `\\`
			static_content << character
			escaped = false
			cursor++
			continue
		}
		if character == `\\` {
			escaped = true
			cursor++
			continue
		}
		if character == `#` && cursor + 1 < content.len && content[cursor + 1] == `{` {
			dynamic = true
			cursor = homepage_url_interpolation_end(content, cursor + 1) or { content.len }
			continue
		}
		static_content << character
		cursor++
	}
	if escaped {
		static_content << `\\`
	}
	return dynamic, homepage_url_decode_string(static_content.bytestr(), quote)
}

fn homepage_url_literal(source string, begin_pos int) ?HomepageUrlLiteral {
	end_pos := homepage_url_quoted_end(source, begin_pos)?
	quote := source[begin_pos]
	raw_content := source[begin_pos + 1..end_pos - 1]
	dynamic, stripped_content := homepage_url_dynamic_content(raw_content, quote)
	content := if dynamic { raw_content } else { stripped_content }
	return HomepageUrlLiteral{
		source: source[begin_pos..end_pos]
		content: content
		stripped_content: stripped_content
		begin_pos: begin_pos
		end_pos: end_pos
	}
}

fn homepage_url_line_prefix_is_space(source string, position int) bool {
	line_start := (source[..position].last_index('\n') or { -1 }) + 1
	return source[line_start..position].trim_space() == ''
}

fn homepage_url_literals(source string) []HomepageUrlLiteral {
	mut literals := []HomepageUrlLiteral{}
	mut cursor := 0
	for cursor < source.len {
		if source[cursor] == `#` {
			for cursor < source.len && source[cursor] != `\n` {
				cursor++
			}
			continue
		}
		if source[cursor] == `'` || source[cursor] == `"` {
			cursor = homepage_url_quoted_end(source, cursor) or { source.len }
			continue
		}
		if !source[cursor..].starts_with('homepage') || (cursor > 0 && homepage_url_identifier_byte(source[cursor - 1])) || (cursor + 'homepage'.len < source.len && homepage_url_identifier_byte(source[cursor + 'homepage'.len])) || !homepage_url_line_prefix_is_space(source, cursor) {
			cursor++
			continue
		}
		mut argument := cursor + 'homepage'.len
		for argument < source.len && source[argument] in [` `, `\t`] {
			argument++
		}
		if argument < source.len && source[argument] == `(` {
			argument++
			for argument < source.len && source[argument] in [` `, `\t`, `\n`, `\r`] {
				argument++
			}
		}
		literal := homepage_url_literal(source, argument) or {
			cursor += 'homepage'.len
			continue
		}
		literals << literal
		cursor = literal.end_pos
	}
	return literals
}

fn homepage_url_cask_name(source string) string {
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('cask ') && !trimmed.starts_with('cask(') {
			continue
		}
		mut cursor := 'cask'.len
		for cursor < trimmed.len && trimmed[cursor] in [` `, `\t`, `(`] {
			cursor++
		}
		literal := homepage_url_literal(trimmed, cursor) or { return '' }
		return literal.stripped_content
	}
	return ''
}

fn homepage_url_has_no_path(url string) bool {
	separator := url.index('://') or { return false }
	if separator == 0 || url[..separator].contains('\n') {
		return false
	}
	authority := url[separator + 3..]
	return authority != '' && !authority.contains('/')
}

fn homepage_url_styling_offense(literal HomepageUrlLiteral, cask_name string) ?HomepageUrlStylingOffense {
	if !homepage_url_has_no_path(literal.content) {
		return none
	}
	uri := urllib.parse(literal.stripped_content) or { return none }
	domain := uri.hostname()
	if domain == '' {
		return none
	}
	message := homepage_url_styling_message_template.replace('%s', literal.content)
	return HomepageUrlStylingOffense{
		cask_name: cask_name
		url: literal.content
		begin_pos: literal.begin_pos
		end_pos: literal.end_pos
		message: message
		replacement: literal.source.replace_once('://${domain}', '://${domain}/')
	}
}

pub fn audit_homepage_url_styling(source string) []HomepageUrlStylingOffense {
	cask_name := homepage_url_cask_name(source)
	mut offenses := []HomepageUrlStylingOffense{}
	for literal in homepage_url_literals(source) {
		offense := homepage_url_styling_offense(literal, cask_name) or { continue }
		offenses << offense
	}
	return offenses
}

pub fn correct_homepage_url_styling(source string) string {
	offenses := audit_homepage_url_styling(source)
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn homepage_url_styling_value(offense HomepageUrlStylingOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'cask_name':   offense.cask_name
		'url':         offense.url
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `on_homepage_stanza(stanza)` at line 21.
pub fn ruby_homepage_url_styling_l21_d1_on_homepage_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_homepage_url_styling(source)
	return if offenses.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		homepage_url_styling_value(offenses[0])
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "uri"
// 6: require "rubocops/shared/homepage_helper"
// 7:
// 8: module RuboCop
// 9:   module Cop
// 10:     module Cask
// 11:       # This cop audits the `homepage` URL in casks.
// 12:       class HomepageUrlStyling < Base
// 13:         include OnHomepageStanza
// 14:         include HelperFunctions
// 15:         include HomepageHelper
// 16:         extend AutoCorrector
// 17:
// 18:         MSG_NO_SLASH = "'%<url>s' must have a slash after the domain."
// 19:
// 20:         sig { params(stanza: RuboCop::Cask::AST::Stanza).void }
// 21:         def on_homepage_stanza(stanza)
// 22:           @name = T.let(cask_block&.header&.cask_token, T.nilable(String))
// 23:           desc_call = T.cast(stanza.stanza_node, RuboCop::AST::SendNode)
// 24:           url_node = desc_call.first_argument
// 25:
// 26:           url = if url_node.dstr_type?
// 27:             # Remove quotes from interpolated string.
// 28:             url_node.source[1..-2]
// 29:           else
// 30:             url_node.str_content
// 31:           end
// 32:
// 33:           audit_homepage(:cask, url, desc_call, url_node)
// 34:
// 35:           return unless url&.match?(%r{^.+://[^/]+$})
// 36:
// 37:           domain = URI(string_content(url_node, strip_dynamic: true)).host
// 38:           return if domain.blank?
// 39:
// 40:           # This also takes URLs like 'https://example.org?path'
// 41:           # and 'https://example.org#path' into account.
// 42:           corrected_source = url_node.source.sub("://#{domain}", "://#{domain}/")
// 43:
// 44:           add_offense(url_node.loc.expression, message: format(MSG_NO_SLASH, url:)) do |corrector|
// 45:             corrector.replace(url_node.source_range, corrected_source)
// 46:           end
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
