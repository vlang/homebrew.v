module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/empty_arch_argument.rb`.
pub const empty_arch_argument_message_template = 'Remove the empty `%s:` argument from the `arch` stanza.'
pub const empty_arch_stanza_message = 'Remove the `arch` stanza as all its arguments are empty.'

pub struct EmptyArchArgumentOffense {
pub:
	key        string
	begin_pos  int
	end_pos    int
	message    string
	whole_line bool
}

struct EmptyArchPair {
	key       string
	begin_pos int
	end_pos   int
	empty     bool
}

struct EmptyArchStanza {
	line_start    int
	line_end      int
	content_start int
	pairs         []EmptyArchPair
}

fn empty_arch_space(character u8) bool {
	return character == ` ` || character == `\t`
}

fn empty_arch_separator(pair string) ?[]int {
	mut quote := u8(0)
	mut escaped := false
	for index := 0; index < pair.len; index++ {
		character := pair[index]
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
		if character == `'` || character == `"` {
			quote = character
			continue
		}
		if character == `=` && index + 1 < pair.len && pair[index + 1] == `>` {
			return [index, 2]
		}
	}
	quote = 0
	escaped = false
	for index := 0; index < pair.len; index++ {
		character := pair[index]
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
		if character == `'` || character == `"` {
			quote = character
		} else if character == `:` && index > 0 {
			return [index, 1]
		}
	}
	return none
}

fn empty_arch_key(source string) string {
	key := source.trim_space()
	if key.len >= 2 && ((key[0] == `'` && key[key.len - 1] == `'`) || (key[0] == `"` && key[key.len - 1] == `"`)) {
		return key[1..key.len - 1]
	}
	if key.starts_with(':') {
		return key[1..]
	}
	return key
}

fn parse_empty_arch_pair(source string, begin_pos int, end_pos int) EmptyArchPair {
	pair_source := source[begin_pos..end_pos]
	separator := empty_arch_separator(pair_source) or {
		return EmptyArchPair{ begin_pos: begin_pos, end_pos: end_pos }
	}
	value := pair_source[separator[0] + separator[1]..].trim_space()
	return EmptyArchPair{
		key: empty_arch_key(pair_source[..separator[0]])
		begin_pos: begin_pos
		end_pos: end_pos
		empty: value == '""' || value == "''"
	}
}

fn parse_empty_arch_stanza(source string, line_start int, line_end int) ?EmptyArchStanza {
	mut cursor := line_start
	for cursor < line_end && empty_arch_space(source[cursor]) {
		cursor++
	}
	if !source[cursor..line_end].starts_with('arch') {
		return none
	}
	after_method := cursor + 'arch'.len
	if after_method >= line_end || (!empty_arch_space(source[after_method]) && source[after_method] != `(`) {
		return none
	}
	mut content_start := after_method
	if source[content_start] == `(` {
		content_start++
	}
	for content_start < line_end && empty_arch_space(source[content_start]) {
		content_start++
	}
	mut content_end := line_end
	for content_end > content_start && empty_arch_space(source[content_end - 1]) {
		content_end--
	}
	if content_end > content_start && source[content_end - 1] == `)` {
		content_end--
	}
	mut pairs := []EmptyArchPair{}
	mut pair_start := content_start
	mut position := content_start
	mut quote := u8(0)
	mut escaped := false
	mut nesting := 0
	for position <= content_end {
		at_end := position == content_end
		if !at_end {
			character := source[position]
			if quote != 0 {
				if escaped {
					escaped = false
				} else if character == `\\` {
					escaped = true
				} else if character == quote {
					quote = 0
				}
			} else if character == `'` || character == `"` {
				quote = character
			} else if character == `[` || character == `{` || character == `(` {
				nesting++
			} else if (character == `]` || character == `}` || character == `)`) && nesting > 0 {
				nesting--
			}
		}
		if at_end || (source[position] == `,` && quote == 0 && nesting == 0) {
			mut trimmed_start := pair_start
			mut trimmed_end := position
			for trimmed_start < trimmed_end && empty_arch_space(source[trimmed_start]) {
				trimmed_start++
			}
			for trimmed_end > trimmed_start && empty_arch_space(source[trimmed_end - 1]) {
				trimmed_end--
			}
			if trimmed_start < trimmed_end {
				pairs << parse_empty_arch_pair(source, trimmed_start, trimmed_end)
			}
			pair_start = position + 1
		}
		position++
	}
	if pairs.len == 0 {
		return none
	}
	return EmptyArchStanza{
		line_start: line_start
		line_end: line_end
		content_start: content_start
		pairs: pairs
	}
}

fn empty_arch_stanzas(source string) []EmptyArchStanza {
	mut stanzas := []EmptyArchStanza{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if stanza := parse_empty_arch_stanza(source, line_start, line_end) {
			stanzas << stanza
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return stanzas
}

pub fn audit_empty_arch_arguments(source string) []EmptyArchArgumentOffense {
	mut offenses := []EmptyArchArgumentOffense{}
	for stanza in empty_arch_stanzas(source) {
		empty_pairs := stanza.pairs.filter(it.empty)
		if empty_pairs.len == 0 {
			continue
		}
		if empty_pairs.len == stanza.pairs.len {
			mut begin_pos := stanza.line_start
			for begin_pos < stanza.line_end && empty_arch_space(source[begin_pos]) {
				begin_pos++
			}
			offenses << EmptyArchArgumentOffense{
				begin_pos: begin_pos
				end_pos: stanza.line_end
				message: empty_arch_stanza_message
				whole_line: true
			}
			continue
		}
		for pair in empty_pairs {
			offenses << EmptyArchArgumentOffense{
				key: pair.key
				begin_pos: pair.begin_pos
				end_pos: pair.end_pos
				message: empty_arch_argument_message_template.replace('%s', pair.key)
			}
		}
	}
	return offenses
}

pub fn correct_empty_arch_arguments(source string) string {
	stanzas := empty_arch_stanzas(source)
	mut corrected := source
	if stanzas.len == 0 {
		return corrected
	}
	for index := stanzas.len - 1; index >= 0; index-- {
		stanza := stanzas[index]
		empty_pairs := stanza.pairs.filter(it.empty)
		if empty_pairs.len == 0 {
			continue
		}
		if empty_pairs.len == stanza.pairs.len {
			end_pos := if stanza.line_end < corrected.len {
				stanza.line_end + 1
			} else {
				stanza.line_end
			}
			corrected = corrected[..stanza.line_start] + corrected[end_pos..]
			continue
		}
		remaining := stanza.pairs.filter(!it.empty).map(source[it.begin_pos..it.end_pos]).join(', ')
		corrected = corrected[..stanza.content_start] + remaining + corrected[stanza.line_end..]
	}
	return corrected
}

fn empty_arch_offense_value(offense EmptyArchArgumentOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'key':        offense.key
		'begin_pos':  offense.begin_pos.str()
		'end_pos':    offense.end_pos.str()
		'message':    offense.message
		'whole_line': offense.whole_line.str()
	})
}
