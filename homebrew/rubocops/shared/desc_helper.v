module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/desc_helper.rb`.
pub const desc_max_length = 80
pub const desc_article_message = "Description shouldn't start with an article."
pub const desc_capital_message = 'Description should start with a capital letter.'
pub const desc_platform_message = "Description shouldn't contain the platform."
pub const desc_symbol_message = "Description shouldn't contain Unicode emojis or symbols."

const desc_valid_lowercase_words = ['iOS', 'iPhone', 'macOS']

const desc_other_symbol_ranges = [
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

pub struct DescCall {
pub:
	description       string
	begin_pos         int
	end_pos           int
	literal_begin_pos int
	literal_end_pos   int
	content_begin_pos int
	quote             u8 = `"`
	correctable       bool = true
}

pub struct DescProblem {
pub:
	kind              string
	desc_type         string
	name              string
	description       string
	begin_pos         int
	end_pos           int
	message           string
	replacement       string
	literal_begin_pos int
	literal_end_pos   int
}

struct DescMatch {
	begin_pos int
	end_pos   int
	value     string
}

fn desc_type_name(desc_type string) string {
	if desc_type == '' {
		return ''
	}
	return desc_type[..1].to_upper() + desc_type[1..]
}

fn desc_ascii_lower(character u8) u8 {
	return if character >= `A` && character <= `Z` { character + 32 } else { character }
}

fn desc_starts_with_ci(source string, begin_pos int, value string) bool {
	if begin_pos < 0 || begin_pos + value.len > source.len {
		return false
	}
	for index, character in value.bytes() {
		if desc_ascii_lower(source[begin_pos + index]) != desc_ascii_lower(character) {
			return false
		}
	}
	return true
}

fn desc_space_byte(character u8) bool {
	return character in [` `, `\t`, `\n`, `\r`, `\v`, `\f`]
}

fn desc_word_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn desc_ascii_letter(character u8) bool {
	lower := desc_ascii_lower(character)
	return lower >= `a` && lower <= `z`
}

fn desc_article_match(description string) ?DescMatch {
	for article in ['the', 'an', 'a'] {
		if desc_starts_with_ci(description, 0, article) && description.len > article.len && desc_space_byte(description[article.len]) {
			return DescMatch{
				begin_pos: 0
				end_pos: article.len
				value: description[..article.len]
			}
		}
	}
	return none
}

fn desc_command_line_match(description string) ?DescMatch {
	for index := 0; index < description.len; index++ {
		if !desc_starts_with_ci(description, index, 'command') {
			continue
		}
		mut end_pos := index + 'command'.len
		if end_pos < description.len && description[end_pos] == ` ` {
			end_pos++
		}
		if desc_starts_with_ci(description, end_pos, 'line') {
			end_pos += 'line'.len
			return DescMatch{
				begin_pos: index
				end_pos: end_pos
				value: description[index..end_pos]
			}
		}
	}
	return none
}

fn desc_name_match(description string, name string) ?DescMatch {
	compact_name := name.replace('-', '')
	if compact_name == '' {
		return none
	}
	mut cursor := 0
	for index, character in compact_name.bytes() {
		if cursor >= description.len || desc_ascii_lower(description[cursor]) != desc_ascii_lower(character) {
			return none
		}
		cursor++
		if index + 1 < compact_name.len && cursor < description.len && (desc_space_byte(description[cursor]) || description[cursor] == `-`) {
			cursor++
		}
	}
	if cursor < description.len && desc_word_byte(description[cursor]) {
		return none
	}
	return DescMatch{
		begin_pos: 0
		end_pos: cursor
		value: description[..cursor]
	}
}

fn desc_platform_candidate(description string, begin_pos int) ?int {
	if desc_starts_with_ci(description, begin_pos, 'macos') {
		if begin_pos + 'macos'.len < description.len && desc_ascii_lower(description[begin_pos + 'macos'.len]) == `x` {
			return begin_pos + 'macosx'.len
		}
		return begin_pos + 'macos'.len
	}
	if desc_starts_with_ci(description, begin_pos, 'mac') {
		mut end_pos := begin_pos + 'mac'.len
		mut os_begin := end_pos
		if os_begin < description.len && description[os_begin] == ` ` {
			os_begin++
		}
		if desc_starts_with_ci(description, os_begin, 'os') {
			end_pos = os_begin + 'os'.len
			mut x_begin := end_pos
			if x_begin < description.len && description[x_begin] == ` ` {
				x_begin++
			}
			if x_begin < description.len && desc_ascii_lower(description[x_begin]) == `x` {
				end_pos = x_begin + 1
			}
		}
		return end_pos
	}
	if desc_starts_with_ci(description, begin_pos, 'os') {
		mut x_begin := begin_pos + 'os'.len
		if x_begin < description.len && description[x_begin] == ` ` {
			x_begin++
		}
		if x_begin < description.len && desc_ascii_lower(description[x_begin]) == `x` {
			return x_begin + 1
		}
	}
	return none
}

fn desc_platform_match(description string) ?DescMatch {
	for begin_pos := 0; begin_pos < description.len; begin_pos++ {
		if begin_pos > 0 && desc_word_byte(description[begin_pos - 1]) {
			continue
		}
		end_pos := desc_platform_candidate(description, begin_pos) or { continue }
		if end_pos < description.len && desc_word_byte(description[end_pos]) {
			continue
		}
		if desc_starts_with_ci(description[end_pos..], 0, ' virtual machine') {
			continue
		}
		return DescMatch{
			begin_pos: begin_pos
			end_pos: end_pos
			value: description[begin_pos..end_pos]
		}
	}
	return none
}

pub fn desc_is_other_symbol(character rune) bool {
	codepoint := int(character)
	for index := 0; index < desc_other_symbol_ranges.len; index += 2 {
		if codepoint >= desc_other_symbol_ranges[index] && codepoint <= desc_other_symbol_ranges[index + 1] {
			return true
		}
	}
	return false
}

fn desc_symbol_match(description string) ?DescMatch {
	mut byte_pos := 0
	for character in description.runes() {
		width := character.str().len
		if desc_is_other_symbol(character) {
			return DescMatch{
				begin_pos: byte_pos
				end_pos: byte_pos + width
				value: character.str()
			}
		}
		byte_pos += width
	}
	return none
}

fn desc_first_word(description string) string {
	for index, character in description.bytes() {
		if desc_space_byte(character) {
			return description[..index]
		}
	}
	return description
}

fn desc_replace_command_line(description string) string {
	mut corrected := description
	mut search_from := 0
	for search_from < corrected.len {
		found := desc_command_line_match(corrected[search_from..]) or { break }
		begin_pos := search_from + found.begin_pos
		end_pos := search_from + found.end_pos
		corrected = corrected[..begin_pos] + corrected[begin_pos..begin_pos + 1] + 'ommand-line' + corrected[end_pos..]
		search_from = begin_pos + 'command-line'.len
	}
	return corrected
}

fn desc_remove_name(description string, name string) string {
	if name == '' {
		return description
	}
	mut corrected := description
	mut index := 0
	for index + name.len <= corrected.len {
		if desc_starts_with_ci(corrected, index, name) && (index == 0 || !desc_ascii_letter(corrected[index - 1])) && (index + name.len == corrected.len || !desc_ascii_letter(corrected[index + name.len])) {
			corrected = corrected[..index] + corrected[index + name.len..]
			continue
		}
		index++
	}
	return corrected
}

fn desc_remove_symbols(description string) string {
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
		if desc_is_other_symbol(character) {
			mut begin_pos := byte_pos
			if begin_pos > 0 && desc_space_byte(corrected[begin_pos - 1]) {
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

pub fn correct_desc_content(description string, name string) string {
	mut correction := description.trim_space()
	if article := desc_article_match(correction) {
		mut remainder := article.end_pos
		for remainder < correction.len && desc_space_byte(correction[remainder]) {
			remainder++
		}
		correction = correction[remainder..]
	}
	first_word := desc_first_word(correction)
	if first_word !in desc_valid_lowercase_words && correction.len > 0 {
		first := correction.runes()[0]
		correction = first.str().to_upper() + correction[first.str().len..]
	}
	correction = desc_replace_command_line(correction)
	correction = desc_remove_name(correction, name)
	correction = desc_remove_symbols(correction).trim_space()
	if correction.ends_with('.') {
		correction = correction[..correction.len - 1]
	}
	return correction
}

fn desc_problem(call DescCall, desc_type string, name string, kind string, found DescMatch,
	message string, correctable bool) DescProblem {
	corrected := correct_desc_content(call.description, name)
	replacement := if correctable && call.correctable && corrected != call.description {
		call.quote.ascii_str() + corrected + call.quote.ascii_str()
	} else {
		''
	}
	return DescProblem{
		kind: kind
		desc_type: desc_type
		name: name
		description: call.description
		begin_pos: call.content_begin_pos + found.begin_pos
		end_pos: call.content_begin_pos + found.end_pos
		message: message
		replacement: replacement
		literal_begin_pos: call.literal_begin_pos
		literal_end_pos: call.literal_end_pos
	}
}

fn desc_call_problem(call DescCall, desc_type string, name string, kind string, message string) DescProblem {
	return DescProblem{
		kind: kind
		desc_type: desc_type
		name: name
		description: call.description
		begin_pos: call.begin_pos
		end_pos: call.end_pos
		message: message
		literal_begin_pos: call.literal_begin_pos
		literal_end_pos: call.literal_end_pos
	}
}

pub fn audit_desc(desc_type string, name string, call DescCall, has_desc bool, missing_begin int,
	missing_end int) []DescProblem {
	if !has_desc {
		return [DescProblem{
			kind: 'missing'
			desc_type: desc_type
			name: name
			begin_pos: missing_begin
			end_pos: missing_end
			message: '${desc_type_name(desc_type)} should have a `desc` (description).'
		}]
	}
	description := call.description
	desc_length := description.runes().len
	if desc_length == 0 {
		return [
			desc_call_problem(call, desc_type, name, 'empty', 'The `desc` (description) should not be an empty string.'),
		]
	}
	mut problems := []DescProblem{}
	mut leading_end := 0
	for leading_end < description.len && desc_space_byte(description[leading_end]) {
		leading_end++
	}
	if leading_end > 0 {
		problems << desc_problem(call, desc_type, name, 'leading_space', DescMatch{
			begin_pos: 0
			end_pos: leading_end
		}, "Description shouldn't have leading spaces.", true)
	}
	mut trailing_begin := description.len
	for trailing_begin > 0 && desc_space_byte(description[trailing_begin - 1]) {
		trailing_begin--
	}
	if trailing_begin < description.len {
		problems << desc_problem(call, desc_type, name, 'trailing_space', DescMatch{
			begin_pos: trailing_begin
			end_pos: description.len
		}, "Description shouldn't have trailing spaces.", true)
	}
	if found := desc_command_line_match(description) {
		first := found.value[..1]
		message := 'Description should use "${first}ommand-line" instead of "${found.value}".'
		problems << desc_problem(call, desc_type, name, 'command_line', found, message, true)
	}
	if found := desc_article_match(description) {
		problems << desc_problem(call, desc_type, name, 'article', found, desc_article_message, true)
	}
	first_word := desc_first_word(description)
	if first_word !in desc_valid_lowercase_words && description[0] >= `a` && description[0] <= `z` {
		problems << desc_problem(call, desc_type, name, 'lowercase', DescMatch{
			begin_pos: 0
			end_pos: 1
			value: description[..1]
		}, desc_capital_message, true)
	}
	if found := desc_name_match(description, name) {
		problems << desc_problem(call, desc_type, name, 'name', found, "Description shouldn't start with the ${desc_type} name.", true)
	}
	if desc_type == 'cask' {
		if found := desc_platform_match(description) {
			if found.value != 'MAC' {
				problems << desc_problem(call, desc_type, name, 'platform', found, desc_platform_message, false)
			}
		}
	}
	if description.ends_with('.') && !description.ends_with('etc.') {
		problems << desc_problem(call, desc_type, name, 'full_stop', DescMatch{
			begin_pos: description.len - 1
			end_pos: description.len
			value: '.'
		}, "Description shouldn't end with a full stop.", true)
	}
	if found := desc_symbol_match(description) {
		problems << desc_problem(call, desc_type, name, 'symbol', found, desc_symbol_message, true)
	}
	if desc_length > desc_max_length {
		message := 'Description is too long. It should be less than ${desc_max_length} characters. The current length is ${desc_length}.'
		problems << desc_call_problem(call, desc_type, name, 'too_long', message)
	}
	return problems
}

fn desc_problem_value(problem DescProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', problem.message, {
		'kind':          problem.kind
		'desc_type':     problem.desc_type
		'name':          problem.name
		'description':   problem.description
		'begin_pos':     problem.begin_pos.str()
		'end_pos':       problem.end_pos.str()
		'message':       problem.message
		'replacement':   problem.replacement
		'literal_begin': problem.literal_begin_pos.str()
		'literal_end':   problem.literal_end_pos.str()
	})
}
