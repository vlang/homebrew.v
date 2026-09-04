module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/desc.rb`.
pub const cask_desc_article_message = "Description shouldn't start with an article."
pub const cask_desc_name_message = "Description shouldn't start with the cask name."
pub const cask_desc_platform_message = "Description shouldn't contain the platform."
pub const cask_desc_symbol_message = "Description shouldn't contain Unicode emojis or symbols."

const cask_desc_max_length = 80
const cask_desc_valid_lowercase_words = ['iOS', 'iPhone', 'macOS']

// Portable Ruby's Other_Symbol (So) ranges. Ruby's `\p{So}` check is represented
// explicitly so this cop does not depend on the still-stubbed shared DescHelper.
const cask_desc_other_symbol_ranges = [
	0x00a6,
	0x00a6,
	0x00a9,
	0x00a9,
	0x00ae,
	0x00ae,
	0x00b0,
	0x00b0,
	0x0482,
	0x0482,
	0x058d,
	0x058e,
	0x060e,
	0x060f,
	0x06de,
	0x06de,
	0x06e9,
	0x06e9,
	0x06fd,
	0x06fe,
	0x07f6,
	0x07f6,
	0x09fa,
	0x09fa,
	0x0b70,
	0x0b70,
	0x0bf3,
	0x0bf8,
	0x0bfa,
	0x0bfa,
	0x0c7f,
	0x0c7f,
	0x0d4f,
	0x0d4f,
	0x0d79,
	0x0d79,
	0x0f01,
	0x0f03,
	0x0f13,
	0x0f13,
	0x0f15,
	0x0f17,
	0x0f1a,
	0x0f1f,
	0x0f34,
	0x0f34,
	0x0f36,
	0x0f36,
	0x0f38,
	0x0f38,
	0x0fbe,
	0x0fc5,
	0x0fc7,
	0x0fcc,
	0x0fce,
	0x0fcf,
	0x0fd5,
	0x0fd8,
	0x109e,
	0x109f,
	0x1390,
	0x1399,
	0x166d,
	0x166d,
	0x1940,
	0x1940,
	0x19de,
	0x19ff,
	0x1b61,
	0x1b6a,
	0x1b74,
	0x1b7c,
	0x2100,
	0x2101,
	0x2103,
	0x2106,
	0x2108,
	0x2109,
	0x2114,
	0x2114,
	0x2116,
	0x2117,
	0x211e,
	0x2123,
	0x2125,
	0x2125,
	0x2127,
	0x2127,
	0x2129,
	0x2129,
	0x212e,
	0x212e,
	0x213a,
	0x213b,
	0x214a,
	0x214a,
	0x214c,
	0x214d,
	0x214f,
	0x214f,
	0x218a,
	0x218b,
	0x2195,
	0x2199,
	0x219c,
	0x219f,
	0x21a1,
	0x21a2,
	0x21a4,
	0x21a5,
	0x21a7,
	0x21ad,
	0x21af,
	0x21cd,
	0x21d0,
	0x21d1,
	0x21d3,
	0x21d3,
	0x21d5,
	0x21f3,
	0x2300,
	0x2307,
	0x230c,
	0x231f,
	0x2322,
	0x2328,
	0x232b,
	0x237b,
	0x237d,
	0x239a,
	0x23b4,
	0x23db,
	0x23e2,
	0x2429,
	0x2440,
	0x244a,
	0x249c,
	0x24e9,
	0x2500,
	0x25b6,
	0x25b8,
	0x25c0,
	0x25c2,
	0x25f7,
	0x2600,
	0x266e,
	0x2670,
	0x2767,
	0x2794,
	0x27bf,
	0x2800,
	0x28ff,
	0x2b00,
	0x2b2f,
	0x2b45,
	0x2b46,
	0x2b4d,
	0x2b73,
	0x2b76,
	0x2bff,
	0x2ce5,
	0x2cea,
	0x2e50,
	0x2e51,
	0x2e80,
	0x2e99,
	0x2e9b,
	0x2ef3,
	0x2f00,
	0x2fd5,
	0x2ff0,
	0x2fff,
	0x3004,
	0x3004,
	0x3012,
	0x3013,
	0x3020,
	0x3020,
	0x3036,
	0x3037,
	0x303e,
	0x303f,
	0x3190,
	0x3191,
	0x3196,
	0x319f,
	0x31c0,
	0x31e5,
	0x31ef,
	0x31ef,
	0x3200,
	0x321e,
	0x322a,
	0x3247,
	0x3250,
	0x3250,
	0x3260,
	0x327f,
	0x328a,
	0x32b0,
	0x32c0,
	0x33ff,
	0x4dc0,
	0x4dff,
	0xa490,
	0xa4c6,
	0xa828,
	0xa82b,
	0xa836,
	0xa837,
	0xa839,
	0xa839,
	0xaa77,
	0xaa79,
	0xfbc3,
	0xfbd2,
	0xfd40,
	0xfd4f,
	0xfd90,
	0xfd91,
	0xfdc8,
	0xfdcf,
	0xfdfd,
	0xfdff,
	0xffe4,
	0xffe4,
	0xffe8,
	0xffe8,
	0xffed,
	0xffee,
	0xfffc,
	0xfffd,
	0x10137,
	0x1013f,
	0x10179,
	0x10189,
	0x1018c,
	0x1018e,
	0x10190,
	0x1019c,
	0x101a0,
	0x101a0,
	0x101d0,
	0x101fc,
	0x10877,
	0x10878,
	0x10ac8,
	0x10ac8,
	0x10ed1,
	0x10ed8,
	0x1173f,
	0x1173f,
	0x11fd5,
	0x11fdc,
	0x11fe1,
	0x11ff1,
	0x16b3c,
	0x16b3f,
	0x16b45,
	0x16b45,
	0x1bc9c,
	0x1bc9c,
	0x1cc00,
	0x1ccef,
	0x1ccfa,
	0x1ccfc,
	0x1cd00,
	0x1ceb3,
	0x1ceba,
	0x1ced0,
	0x1cee0,
	0x1ceef,
	0x1cf50,
	0x1cfc3,
	0x1d000,
	0x1d0f5,
	0x1d100,
	0x1d126,
	0x1d129,
	0x1d164,
	0x1d16a,
	0x1d16c,
	0x1d183,
	0x1d184,
	0x1d18c,
	0x1d1a9,
	0x1d1ae,
	0x1d1ea,
	0x1d200,
	0x1d241,
	0x1d245,
	0x1d245,
	0x1d300,
	0x1d356,
	0x1d800,
	0x1d9ff,
	0x1da37,
	0x1da3a,
	0x1da6d,
	0x1da74,
	0x1da76,
	0x1da83,
	0x1da85,
	0x1da86,
	0x1e14f,
	0x1e14f,
	0x1ecac,
	0x1ecac,
	0x1ed2e,
	0x1ed2e,
	0x1f000,
	0x1f02b,
	0x1f030,
	0x1f093,
	0x1f0a0,
	0x1f0ae,
	0x1f0b1,
	0x1f0bf,
	0x1f0c1,
	0x1f0cf,
	0x1f0d1,
	0x1f0f5,
	0x1f10d,
	0x1f1ad,
	0x1f1e6,
	0x1f202,
	0x1f210,
	0x1f23b,
	0x1f240,
	0x1f248,
	0x1f250,
	0x1f251,
	0x1f260,
	0x1f265,
	0x1f300,
	0x1f3fa,
	0x1f400,
	0x1f6d8,
	0x1f6dc,
	0x1f6ec,
	0x1f6f0,
	0x1f6fc,
	0x1f700,
	0x1f7d9,
	0x1f7e0,
	0x1f7eb,
	0x1f7f0,
	0x1f7f0,
	0x1f800,
	0x1f80b,
	0x1f810,
	0x1f847,
	0x1f850,
	0x1f859,
	0x1f860,
	0x1f887,
	0x1f890,
	0x1f8ad,
	0x1f8b0,
	0x1f8bb,
	0x1f8c0,
	0x1f8c1,
	0x1f900,
	0x1fa57,
	0x1fa60,
	0x1fa6d,
	0x1fa70,
	0x1fa7c,
	0x1fa80,
	0x1fa8a,
	0x1fa8e,
	0x1fac6,
	0x1fac8,
	0x1fac8,
	0x1facd,
	0x1fadc,
	0x1fadf,
	0x1faea,
	0x1faef,
	0x1faf8,
	0x1fb00,
	0x1fb92,
	0x1fb94,
	0x1fbef,
	0x1fbfa,
	0x1fbfa,
]

pub struct CaskDescOffense {
pub:
	cask_name         string
	description       string
	begin_pos         int
	end_pos           int
	message           string
	replacement       string
	literal_begin_pos int
	literal_end_pos   int
}

struct CaskDescLiteral {
	quote     u8
	content   string
	begin_pos int
	end_pos   int
}

struct CaskDescMatch {
	begin_pos int
	end_pos   int
	value     string
}

fn cask_desc_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn cask_desc_ascii_lower(character u8) u8 {
	return if character >= `A` && character <= `Z` { character + 32 } else { character }
}

fn cask_desc_starts_with_ci(source string, begin_pos int, value string) bool {
	if begin_pos < 0 || begin_pos + value.len > source.len {
		return false
	}
	for index, character in value.bytes() {
		if cask_desc_ascii_lower(source[begin_pos + index]) != cask_desc_ascii_lower(character) {
			return false
		}
	}
	return true
}

fn cask_desc_word_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn cask_desc_space_byte(character u8) bool {
	return character in [` `, `\t`, `\n`, `\r`, `\v`, `\f`]
}

fn cask_desc_quoted_literal(source string, begin_pos int) ?CaskDescLiteral {
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
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return CaskDescLiteral{
				quote: quote
				content: source[begin_pos + 1..cursor]
				begin_pos: begin_pos
				end_pos: cursor + 1
			}
		}
		cursor++
	}
	return none
}

fn cask_desc_literal_after(source string, command_start int, command string) ?CaskDescLiteral {
	command_end := command_start + command.len
	if command_end > source.len || !source[command_start..].starts_with(command) || (command_end < source.len && cask_desc_identifier_byte(source[command_end])) {
		return none
	}
	mut cursor := command_end
	for cursor < source.len && source[cursor] in [` `, `\t`] {
		cursor++
	}
	if cursor < source.len && source[cursor] == `(` {
		cursor++
		for cursor < source.len && cask_desc_space_byte(source[cursor]) {
			cursor++
		}
	}
	return cask_desc_quoted_literal(source, cursor)
}

fn cask_desc_source_parts(source string) (string, []CaskDescLiteral) {
	mut cask_name := ''
	mut descriptions := []CaskDescLiteral{}
	mut line_start := 0
	for line_start <= source.len {
		newline := source.index_after('\n', line_start) or { source.len }
		line_end := if newline < source.len { newline } else { source.len }
		mut cursor := line_start
		for cursor < line_end && source[cursor] in [` `, `\t`] {
			cursor++
		}
		if cursor < line_end && source[cursor] != `#` {
			if cask_name == '' {
				if literal := cask_desc_literal_after(source, cursor, 'cask') {
					cask_name = literal.content
				}
			}
			if literal := cask_desc_literal_after(source, cursor, 'desc') {
				descriptions << literal
			}
		}
		if newline >= source.len {
			break
		}
		line_start = newline + 1
	}
	return cask_name, descriptions
}

fn cask_desc_article_match(description string) ?CaskDescMatch {
	for article in ['the', 'an', 'a'] {
		if cask_desc_starts_with_ci(description, 0, article) && description.len > article.len && cask_desc_space_byte(description[article.len]) {
			return CaskDescMatch{ begin_pos: 0, end_pos: article.len, value: description[..article.len] }
		}
	}
	return none
}

fn cask_desc_command_line_match(description string) ?CaskDescMatch {
	for index := 0; index < description.len; index++ {
		if !cask_desc_starts_with_ci(description, index, 'command') {
			continue
		}
		mut end_pos := index + 'command'.len
		if end_pos < description.len && description[end_pos] == ` ` {
			end_pos++
		}
		if cask_desc_starts_with_ci(description, end_pos, 'line') {
			end_pos += 'line'.len
			return CaskDescMatch{
				begin_pos: index
				end_pos: end_pos
				value: description[index..end_pos]
			}
		}
	}
	return none
}

fn cask_desc_name_match(description string, cask_name string) ?CaskDescMatch {
	compact_name := cask_name.replace('-', '')
	if compact_name == '' {
		return none
	}
	mut cursor := 0
	for index, character in compact_name.bytes() {
		if cursor >= description.len || cask_desc_ascii_lower(description[cursor]) != cask_desc_ascii_lower(character) {
			return none
		}
		cursor++
		if index + 1 < compact_name.len && cursor < description.len && (cask_desc_space_byte(description[cursor]) || description[cursor] == `-`) {
			cursor++
		}
	}
	if cursor < description.len && cask_desc_word_byte(description[cursor]) {
		return none
	}
	return CaskDescMatch{ begin_pos: 0, end_pos: cursor, value: description[..cursor] }
}

fn cask_desc_platform_candidate(description string, begin_pos int) ?int {
	if cask_desc_starts_with_ci(description, begin_pos, 'macos') {
		if begin_pos + 'macos'.len < description.len && cask_desc_ascii_lower(description[begin_pos + 'macos'.len]) == `x` {
			return begin_pos + 'macosx'.len
		}
		return begin_pos + 'macos'.len
	}
	if cask_desc_starts_with_ci(description, begin_pos, 'mac') {
		mut end_pos := begin_pos + 'mac'.len
		mut os_begin := end_pos
		if os_begin < description.len && description[os_begin] == ` ` {
			os_begin++
		}
		if cask_desc_starts_with_ci(description, os_begin, 'os') {
			end_pos = os_begin + 'os'.len
			mut x_begin := end_pos
			if x_begin < description.len && description[x_begin] == ` ` {
				x_begin++
			}
			if x_begin < description.len && cask_desc_ascii_lower(description[x_begin]) == `x` {
				end_pos = x_begin + 1
			}
		}
		return end_pos
	}
	if cask_desc_starts_with_ci(description, begin_pos, 'os') {
		mut x_begin := begin_pos + 'os'.len
		if x_begin < description.len && description[x_begin] == ` ` {
			x_begin++
		}
		if x_begin < description.len && cask_desc_ascii_lower(description[x_begin]) == `x` {
			return x_begin + 1
		}
	}
	return none
}

fn cask_desc_platform_match(description string) ?CaskDescMatch {
	for begin_pos := 0; begin_pos < description.len; begin_pos++ {
		if begin_pos > 0 && cask_desc_word_byte(description[begin_pos - 1]) {
			continue
		}
		end_pos := cask_desc_platform_candidate(description, begin_pos) or { continue }
		if end_pos < description.len && cask_desc_word_byte(description[end_pos]) {
			continue
		}
		remainder := description[end_pos..]
		if cask_desc_starts_with_ci(remainder, 0, ' virtual machine') {
			continue
		}
		return CaskDescMatch{
			begin_pos: begin_pos
			end_pos: end_pos
			value: description[begin_pos..end_pos]
		}
	}
	return none
}

fn cask_desc_is_other_symbol(character rune) bool {
	codepoint := int(character)
	for index := 0; index < cask_desc_other_symbol_ranges.len; index += 2 {
		if codepoint >= cask_desc_other_symbol_ranges[index] && codepoint <= cask_desc_other_symbol_ranges[index + 1] {
			return true
		}
	}
	return false
}

fn cask_desc_symbol_match(description string) ?CaskDescMatch {
	mut byte_pos := 0
	for character in description.runes() {
		width := character.str().len
		if cask_desc_is_other_symbol(character) {
			return CaskDescMatch{
				begin_pos: byte_pos
				end_pos: byte_pos + width
				value: character.str()
			}
		}
		byte_pos += width
	}
	return none
}

fn cask_desc_first_word(description string) string {
	for index, character in description.bytes() {
		if cask_desc_space_byte(character) {
			return description[..index]
		}
	}
	return description
}

fn cask_desc_replace_command_line(description string) string {
	mut corrected := description
	mut search_from := 0
	for search_from < corrected.len {
		match_ := cask_desc_command_line_match(corrected[search_from..]) or { break }
		begin_pos := search_from + match_.begin_pos
		end_pos := search_from + match_.end_pos
		corrected = corrected[..begin_pos] + corrected[begin_pos..begin_pos + 1] + 'ommand-line' + corrected[end_pos..]
		search_from = begin_pos + 'command-line'.len
	}
	return corrected
}

fn cask_desc_remove_name(description string, cask_name string) string {
	if cask_name == '' {
		return description
	}
	mut corrected := description
	mut index := 0
	for index + cask_name.len <= corrected.len {
		if cask_desc_starts_with_ci(corrected, index, cask_name) && (index == 0 || !corrected[index - 1].is_letter()) && (index + cask_name.len == corrected.len || !corrected[index + cask_name.len].is_letter()) {
			corrected = corrected[..index] + corrected[index + cask_name.len..]
			continue
		}
		index++
	}
	return corrected
}

fn cask_desc_remove_symbols(description string) string {
	mut corrected := description
	mut byte_pos := 0
	for byte_pos < corrected.len {
		mut width := 1
		mut character := rune(corrected[byte_pos])
		for candidate in corrected[byte_pos..].runes() {
			character = candidate
			width = candidate.str().len
			break
		}
		if cask_desc_is_other_symbol(character) {
			mut begin_pos := byte_pos
			if begin_pos > 0 && cask_desc_space_byte(corrected[begin_pos - 1]) {
				begin_pos--
			}
			corrected = corrected[..begin_pos] + corrected[byte_pos + width..]
			byte_pos = begin_pos
			continue
		}
		byte_pos += width
	}
	return corrected
}

fn cask_desc_correct_content(description string, cask_name string) string {
	mut correction := description.trim_space()
	if article := cask_desc_article_match(correction) {
		mut remainder := article.end_pos
		for remainder < correction.len && cask_desc_space_byte(correction[remainder]) {
			remainder++
		}
		correction = correction[remainder..]
	}
	first_word := cask_desc_first_word(correction)
	if first_word !in cask_desc_valid_lowercase_words && correction.len > 0 {
		first := correction.runes()[0]
		correction = first.str().to_upper() + correction[first.str().len..]
	}
	correction = cask_desc_replace_command_line(correction)
	correction = cask_desc_remove_name(correction, cask_name)
	correction = cask_desc_remove_symbols(correction).trim_space()
	if correction.ends_with('.') {
		correction = correction[..correction.len - 1]
	}
	return correction
}

fn cask_desc_offense(literal CaskDescLiteral, cask_name string, match_ CaskDescMatch,
	message string, correctable bool) CaskDescOffense {
	corrected := cask_desc_correct_content(literal.content, cask_name)
	replacement := if correctable && corrected != literal.content {
		literal.quote.ascii_str() + corrected + literal.quote.ascii_str()
	} else {
		''
	}
	return CaskDescOffense{
		cask_name: cask_name
		description: literal.content
		begin_pos: literal.begin_pos + 1 + match_.begin_pos
		end_pos: literal.begin_pos + 1 + match_.end_pos
		message: message
		replacement: replacement
		literal_begin_pos: literal.begin_pos
		literal_end_pos: literal.end_pos
	}
}

fn cask_desc_audit_literal(literal CaskDescLiteral, cask_name string) []CaskDescOffense {
	mut offenses := []CaskDescOffense{}
	description := literal.content
	if description == '' {
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: 0
			end_pos: 0
		}, 'The `desc` (description) should not be an empty string.', false)
		return offenses
	}
	mut leading_end := 0
	for leading_end < description.len && cask_desc_space_byte(description[leading_end]) {
		leading_end++
	}
	if leading_end > 0 {
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: 0
			end_pos: leading_end
		}, "Description shouldn't have leading spaces.", true)
	}
	mut trailing_begin := description.len
	for trailing_begin > 0 && cask_desc_space_byte(description[trailing_begin - 1]) {
		trailing_begin--
	}
	if trailing_begin < description.len {
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: trailing_begin
			end_pos: description.len
		}, "Description shouldn't have trailing spaces.", true)
	}
	if match_ := cask_desc_command_line_match(description) {
		first := match_.value[..1]
		message := 'Description should use "${first}ommand-line" instead of "${match_.value}".'
		offenses << cask_desc_offense(literal, cask_name, match_, message, true)
	}
	if match_ := cask_desc_article_match(description) {
		offenses << cask_desc_offense(literal, cask_name, match_, cask_desc_article_message, true)
	}
	first_word := cask_desc_first_word(description)
	if first_word !in cask_desc_valid_lowercase_words && description[0] >= `a` && description[0] <= `z` {
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: 0
			end_pos: 1
			value: description[..1]
		}, 'Description should start with a capital letter.', true)
	}
	if match_ := cask_desc_name_match(description, cask_name) {
		offenses << cask_desc_offense(literal, cask_name, match_, cask_desc_name_message, true)
	}
	if match_ := cask_desc_platform_match(description) {
		if match_.value != 'MAC' {
			offenses << cask_desc_offense(literal, cask_name, match_, cask_desc_platform_message, false)
		}
	}
	if description.ends_with('.') && !description.ends_with('etc.') {
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: description.len - 1
			end_pos: description.len
			value: '.'
		}, "Description shouldn't end with a full stop.", true)
	}
	if match_ := cask_desc_symbol_match(description) {
		offenses << cask_desc_offense(literal, cask_name, match_, cask_desc_symbol_message, true)
	}
	if description.runes().len > cask_desc_max_length {
		message := 'Description is too long. It should be less than ${cask_desc_max_length} characters. The current length is ${description.runes().len}.'
		offenses << cask_desc_offense(literal, cask_name, CaskDescMatch{
			begin_pos: 0
			end_pos: description.len
		}, message, false)
	}
	return offenses
}

pub fn audit_cask_desc(source string) []CaskDescOffense {
	cask_name, descriptions := cask_desc_source_parts(source)
	mut offenses := []CaskDescOffense{}
	for literal in descriptions {
		offenses << cask_desc_audit_literal(literal, cask_name)
	}
	return offenses
}

pub fn correct_cask_desc(source string) string {
	offenses := audit_cask_desc(source)
	mut corrected := source
	mut corrected_literals := map[int]bool{}
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		if offense.replacement == '' || corrected_literals[offense.literal_begin_pos] {
			continue
		}
		corrected = corrected[..offense.literal_begin_pos] + offense.replacement + corrected[offense.literal_end_pos..]
		corrected_literals[offense.literal_begin_pos] = true
	}
	return corrected
}

fn cask_desc_value(offense CaskDescOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'cask_name':   offense.cask_name
		'description': offense.description
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}
