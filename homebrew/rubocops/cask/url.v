module cask

import ruby
import homebrew.rubocops.cask.mixin as cask_mixin
import homebrew.rubocops.@shared as url_shared

// Translated from Homebrew/brew `rubocops/cask/url.rb`.
pub const cask_url_block_message = 'Do not use `url "..." do` blocks in Homebrew/homebrew-cask.'
pub const cask_url_argument_message = 'The `url` stanza requires a URL argument.'
pub const cask_url_literal_message = 'Casks in homebrew/cask should use string literal URLs.'
pub const cask_url_http_message = 'Casks in homebrew/cask should not use http:// URLs'
pub const cask_url_keyword_message = 'Keyword URL parameter should be on a new indented line.'

pub struct CaskUrlOffense {
pub:
	kind              string
	url               string
	begin_pos         int
	end_pos           int
	message           string
	has_correction    bool
	replacement_begin int
	replacement_end   int
	replacement       string
}

struct CaskUrlStanza {
	source             string
	begin_pos          int
	end_pos            int
	column             int
	is_block           bool
	has_argument       bool
	argument_kind      string
	argument_source    string
	argument_content   string
	argument_begin     int
	argument_end       int
	argument_line      int
	argument_last_line int
	hash_begin         int
	hash_line          int
	hash_column        int
	has_hash           bool
}

fn cask_url_line_end(source string, begin_pos int) int {
	newline := source[begin_pos..].index_u8(`\n`)
	return if newline < 0 { source.len } else { begin_pos + newline }
}

fn cask_url_code_end(source string, begin_pos int, line_end int) int {
	mut cursor := begin_pos
	mut quote := u8(0)
	mut escaped := false
	for cursor < line_end {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			return cursor
		}
		cursor++
	}
	return line_end
}

fn cask_url_bracket_delta(value string) int {
	mut delta := 0
	mut quote := u8(0)
	mut escaped := false
	for character in value.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			delta++
		} else if character in [`)`, `]`, `}`] {
			delta--
		}
	}
	return delta
}

fn cask_url_statement_end(source string, begin_pos int) int {
	mut line_start := begin_pos
	mut balance := 0
	for line_start < source.len {
		line_end := cask_url_line_end(source, line_start)
		code_end := cask_url_code_end(source, line_start, line_end)
		code := source[line_start..code_end].trim_right(' \t')
		balance += cask_url_bracket_delta(code)
		if balance <= 0 && !code.ends_with(',') {
			return code_end - (source[line_start..code_end].len - code.len)
		}
		if line_end >= source.len {
			return code_end
		}
		line_start = line_end + 1
	}
	return source.len
}

fn cask_url_opens_block(code string) bool {
	trimmed := code.trim_space()
	if trimmed.ends_with(' do') || trimmed.contains(' do |') {
		return true
	}
	for keyword in ['if ', 'unless ', 'case ', 'begin', 'while ', 'until ', 'for ', 'def ', 'class '] {
		if trimmed == keyword.trim_space() || trimmed.starts_with(keyword) {
			return true
		}
	}
	return false
}

fn cask_url_block_end(source string, first_line_end int) int {
	mut depth := 1
	mut line_start := if first_line_end < source.len { first_line_end + 1 } else { source.len }
	for line_start < source.len {
		line_end := cask_url_line_end(source, line_start)
		code_end := cask_url_code_end(source, line_start, line_end)
		code := source[line_start..code_end].trim_right(' \t')
		trimmed := code.trim_space()
		if trimmed == 'end' || trimmed.starts_with('end ') {
			depth--
			if depth == 0 {
				return line_start + code.len
			}
		} else if cask_url_opens_block(trimmed) {
			depth++
		}
		if line_end >= source.len {
			break
		}
		line_start = line_end + 1
	}
	return first_line_end
}

fn cask_url_quoted_end(source string, begin_pos int, limit int) ?int {
	if begin_pos >= limit || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut cursor := begin_pos + 1
	mut escaped := false
	mut interpolation_depth := 0
	for cursor < limit {
		character := source[cursor]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if quote == `"` && character == `#` && cursor + 1 < limit && source[cursor + 1] == `{` {
			interpolation_depth++
			cursor++
		} else if interpolation_depth > 0 && character == `{` {
			interpolation_depth++
		} else if interpolation_depth > 0 && character == `}` {
			interpolation_depth--
		} else if interpolation_depth == 0 && character == quote {
			return cursor + 1
		}
		cursor++
	}
	return none
}

fn cask_url_decode(content string, quote u8) string {
	mut result := []u8{cap: content.len}
	mut cursor := 0
	for cursor < content.len {
		if content[cursor] != `\\` || cursor + 1 >= content.len {
			result << content[cursor]
			cursor++
			continue
		}
		next := content[cursor + 1]
		if quote == `'` {
			if next in [`\\`, `'`] {
				result << next
			} else {
				result << `\\`
				result << next
			}
		} else {
			match next {
				`n` { result << `\n` }
				`r` { result << `\r` }
				`t` { result << `\t` }
				`\\`, `"`, `#` { result << next }
				else {
					result << `\\`
					result << next
				}
			}
		}
		cursor += 2
	}
	return result.bytestr()
}

fn cask_url_interpolated(content string, quote u8) bool {
	if quote != `"` {
		return false
	}
	mut cursor := 0
	mut escaped := false
	for cursor + 1 < content.len {
		if escaped {
			escaped = false
		} else if content[cursor] == `\\` {
			escaped = true
		} else if content[cursor] == `#` && content[cursor + 1] == `{` {
			return true
		}
		cursor++
	}
	return false
}

fn cask_url_line_number(source string, position int) int {
	mut line := 1
	limit := if position < source.len { position } else { source.len }
	for character in source[..limit].bytes() {
		if character == `\n` {
			line++
		}
	}
	return line
}

fn cask_url_column(source string, position int) int {
	limit := if position < source.len { position } else { source.len }
	return limit - ((source[..limit].last_index('\n') or { -1 }) + 1)
}

fn cask_url_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn cask_url_hash_at(source string, begin_pos int, limit int) bool {
	mut cursor := begin_pos
	if cursor < limit && source[cursor] == `{` {
		return true
	}
	if cursor >= limit || !cask_url_identifier(source[cursor]) {
		return false
	}
	for cursor < limit && cask_url_identifier(source[cursor]) {
		cursor++
	}
	for cursor < limit && source[cursor] in [` `, `\t`] {
		cursor++
	}
	return cursor < limit && source[cursor] == `:`
}

fn cask_url_nonliteral_end(source string, begin_pos int, limit int) int {
	mut cursor := begin_pos
	mut balance := 0
	mut quote := u8(0)
	mut escaped := false
	for cursor < limit {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			balance++
		} else if character in [`)`, `]`, `}`] {
			if balance == 0 {
				break
			}
			balance--
		} else if character == `,` && balance == 0 {
			break
		}
		cursor++
	}
	for cursor > begin_pos && source[cursor - 1] in [` `, `\t`, `\n`, `\r`] {
		cursor--
	}
	return cursor
}

fn cask_url_concat_content(source string, begin_pos int, limit int) string {
	mut cursor := begin_pos
	mut content := ''
	for cursor < limit {
		for cursor < limit && source[cursor] in [` `, `\t`, `\n`, `\r`] {
			cursor++
		}
		if cursor >= limit || source[cursor] !in [`'`, `"`] {
			break
		}
		literal_end := cask_url_quoted_end(source, cursor, limit) or { break }
		content += cask_url_decode(source[cursor + 1..literal_end - 1], source[cursor])
		cursor = literal_end
		for cursor < limit && source[cursor] in [` `, `\t`, `\n`, `\r`] {
			cursor++
		}
		if cursor >= limit || source[cursor] != `+` {
			break
		}
		cursor++
	}
	return content
}

fn cask_url_block_token(source string, begin_pos int, limit int) bool {
	mut cursor := begin_pos
	mut quote := u8(0)
	mut escaped := false
	for cursor + 2 <= limit {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if source[cursor..limit].starts_with(' do') {
			after := cursor + 3
			if after >= limit || source[after] in [` `, `\t`, `|`] {
				return true
			}
		}
		cursor++
	}
	return false
}

fn parse_cask_url_stanza(source string, begin_pos int) ?CaskUrlStanza {
	header_end := cask_url_statement_end(source, begin_pos)
	if begin_pos >= header_end || !source[begin_pos..header_end].starts_with('url') {
		return none
	}
	if begin_pos + 3 < header_end && cask_url_identifier(source[begin_pos + 3]) {
		return none
	}
	column := cask_url_column(source, begin_pos)
	mut cursor := begin_pos + 3
	for cursor < header_end && source[cursor] in [` `, `\t`, `\n`, `\r`] {
		cursor++
	}
	if cursor < header_end && source[cursor] == `(` {
		cursor++
		for cursor < header_end && source[cursor] in [` `, `\t`, `\n`, `\r`] {
			cursor++
		}
	}
	is_block := cask_url_block_token(source, cursor, header_end)
	statement_end := if is_block { cask_url_block_end(source, header_end) } else { header_end }
	base := CaskUrlStanza{
		source: source[begin_pos..statement_end]
		begin_pos: begin_pos
		end_pos: statement_end
		column: column
		is_block: is_block
	}
	if is_block {
		return base
	}
	if cursor >= header_end || source[cursor] == `)` {
		return base
	}
	if cask_url_hash_at(source, cursor, statement_end) {
		return CaskUrlStanza{
			...base
			has_argument: true
			argument_kind: 'hash'
			argument_source: source[cursor..statement_end]
			argument_begin: cursor
			argument_end: statement_end
			argument_line: cask_url_line_number(source, cursor)
			argument_last_line: cask_url_line_number(source, statement_end)
			has_hash: true
			hash_begin: cursor
			hash_line: cask_url_line_number(source, cursor)
			hash_column: cask_url_column(source, cursor)
		}
	}
	mut argument_end := cursor
	mut argument_kind := 'send'
	mut argument_content := ''
	if source[cursor] in [`'`, `"`] {
		argument_end = cask_url_quoted_end(source, cursor, statement_end) or { statement_end }
		raw_content := if argument_end > cursor + 1 {
			source[cursor + 1..argument_end - 1]
		} else {
			''
		}
		argument_kind = if cask_url_interpolated(raw_content, source[cursor]) {
			'dstr'
		} else {
			'str'
		}
		argument_content = cask_url_decode(raw_content, source[cursor])
		mut expression_cursor := argument_end
		for expression_cursor < statement_end && source[expression_cursor] in [` `, `\t`, `\n`,
			`\r`] {
			expression_cursor++
		}
		if expression_cursor < statement_end && source[expression_cursor] == `+` {
			argument_end = cask_url_nonliteral_end(source, cursor, statement_end)
			argument_kind = 'send'
			argument_content = cask_url_concat_content(source, cursor, argument_end)
		}
	} else {
		argument_end = cask_url_nonliteral_end(source, cursor, statement_end)
	}
	mut after_argument := argument_end
	for after_argument < statement_end && source[after_argument] in [` `, `\t`, `\n`, `\r`] {
		after_argument++
	}
	mut has_hash := false
	mut hash_begin := 0
	if after_argument < statement_end && source[after_argument] == `,` {
		after_argument++
		for after_argument < statement_end && source[after_argument] in [` `, `\t`, `\n`, `\r`] {
			after_argument++
		}
		if cask_url_hash_at(source, after_argument, statement_end) {
			has_hash = true
			hash_begin = after_argument
		}
	}
	return CaskUrlStanza{
		...base
		has_argument: true
		argument_kind: argument_kind
		argument_source: source[cursor..argument_end]
		argument_content: argument_content
		argument_begin: cursor
		argument_end: argument_end
		argument_line: cask_url_line_number(source, cursor)
		argument_last_line: cask_url_line_number(source, if argument_end > cursor {
			argument_end - 1
		} else {
			argument_end
		})
		has_hash: has_hash
		hash_begin: hash_begin
		hash_line: if has_hash { cask_url_line_number(source, hash_begin) } else { 0 }
		hash_column: if has_hash { cask_url_column(source, hash_begin) } else { 0 }
	}
}

fn cask_url_tap(path string) string {
	valid_tap := fn (name string) bool {
		if !name.starts_with('homebrew-') || name.len == 'homebrew-'.len {
			return false
		}
		return name.bytes().all(it.is_alnum() || it in [`_`, `-`])
	}
	if path.starts_with('/') {
		parts := path.trim_left('/').split('/')
		if parts.len > 0 && valid_tap(parts[0]) {
			return parts[0]
		}
	}
	parts := path.split('/')
	for index, part in parts {
		if index >= 2 && parts[index - 2] == 'Taps' && valid_tap(part) {
			return part
		}
	}
	return ''
}

fn cask_url_offense(kind string, stanza CaskUrlStanza, begin_pos int, end_pos int,
	message string) CaskUrlOffense {
	return CaskUrlOffense{
		kind: kind
		url: stanza.argument_content
		begin_pos: begin_pos
		end_pos: end_pos
		message: message
	}
}

fn cask_url_correction(kind string, stanza CaskUrlStanza, begin_pos int, end_pos int,
	message string, replacement_begin int, replacement_end int, replacement string) CaskUrlOffense {
	return CaskUrlOffense{
		kind: kind
		url: stanza.argument_content
		begin_pos: begin_pos
		end_pos: end_pos
		message: message
		has_correction: true
		replacement_begin: replacement_begin
		replacement_end: replacement_end
		replacement: replacement
	}
}

fn cask_url_shared_offense(problem url_shared.UrlProblem) CaskUrlOffense {
	return CaskUrlOffense{
		kind: problem.kind
		url: problem.url
		begin_pos: problem.begin_pos
		end_pos: problem.end_pos
		message: problem.message
		has_correction: problem.has_correction
		replacement_begin: problem.replacement_begin
		replacement_end: problem.replacement_end
		replacement: problem.replacement
	}
}

fn audit_parsed_cask_url(stanza CaskUrlStanza, tap string, deprecated_or_disabled bool) []CaskUrlOffense {
	mut offenses := []CaskUrlOffense{}
	if stanza.is_block {
		if tap == 'homebrew-cask' {
			offenses << cask_url_offense('url_block', stanza, stanza.begin_pos, stanza.end_pos, cask_url_block_message)
		}
		return offenses
	}
	if !stanza.has_argument || stanza.argument_kind == 'hash' {
		offenses << cask_url_offense('missing_argument', stanza, stanza.begin_pos, stanza.end_pos, cask_url_argument_message)
		return offenses
	}
	node := url_shared.UrlAuditNode{
		source: stanza.source
		content: stanza.argument_content
		begin_pos: stanza.begin_pos
		end_pos: stanza.end_pos
		argument_begin: stanza.argument_begin
		argument_end: stanza.argument_end
	}
	for problem in url_shared.audit_url_nodes('cask', [node], [], []) {
		offenses << cask_url_shared_offense(problem)
	}
	if tap == 'homebrew-cask' && stanza.argument_kind !in ['str', 'dstr'] {
		offenses << cask_url_offense('string_literal', stanza, stanza.argument_begin, stanza.argument_end, cask_url_literal_message)
	}
	if tap == 'homebrew-cask' && !deprecated_or_disabled && stanza.argument_source.starts_with('"http://') {
		offenses << cask_url_correction('http', stanza, stanza.begin_pos, stanza.end_pos, cask_url_http_message, stanza.begin_pos, stanza.end_pos, stanza.source.replace_once('http://', 'https://'))
	}
	if stanza.has_hash && !(stanza.hash_line > stanza.argument_last_line && stanza.hash_column > stanza.column) {
		offenses << cask_url_correction('keyword_line', stanza, stanza.begin_pos, stanza.end_pos, cask_url_keyword_message, stanza.argument_end, stanza.hash_begin, ',\n${' '.repeat(stanza.column + 2)}')
	}
	return offenses
}

pub fn audit_cask_url(source string, path string) []CaskUrlOffense {
	tap := cask_url_tap(path)
	toplevel := cask_mixin.cask_toplevel_stanzas(source)
	deprecated_or_disabled := toplevel.any(it.name in ['deprecate!', 'disable!'])
	mut offenses := []CaskUrlOffense{}
	for entry in toplevel {
		if entry.name != 'url' {
			continue
		}
		stanza := parse_cask_url_stanza(source, entry.begin_pos) or { continue }
		offenses << audit_parsed_cask_url(stanza, tap, deprecated_or_disabled)
	}
	return offenses
}

pub fn correct_cask_url(source string, path string) string {
	mut corrections := audit_cask_url(source, path).filter(it.has_correction)
	corrections.sort(a.replacement_begin > b.replacement_begin)
	mut corrected := source
	for offense in corrections {
		if offense.replacement_end <= corrected.len {
			corrected = corrected[..offense.replacement_begin] + offense.replacement + corrected[offense.replacement_end..]
		}
	}
	return corrected
}

fn cask_url_offense_value(offense CaskUrlOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':              offense.kind
		'url':               offense.url
		'begin_pos':         offense.begin_pos.str()
		'end_pos':           offense.end_pos.str()
		'message':           offense.message
		'has_correction':    offense.has_correction.str()
		'replacement_begin': offense.replacement_begin.str()
		'replacement_end':   offense.replacement_end.str()
		'replacement':       offense.replacement
	})
}
