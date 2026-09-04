module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/sha256_arch_order.rb`.
pub const sha256_arch_order_message = '`sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux'
pub const sha256_arch_order_stanza_prefix = 'sha256 '

pub struct Sha256ArchOrderPair {
pub:
	key            string
	key_source     string
	value_source   string
	begin_pos      int
	end_pos        int
	original_index int
}

pub struct Sha256ArchOrderOffense {
pub:
	begin_pos             int
	end_pos               int
	message               string
	replacement           string
	correction_suppressed bool
}

struct Sha256ArchOrderStanza {
	begin_pos   int
	end_pos     int
	column      int
	pairs       []Sha256ArchOrderPair
	has_comment bool
}

struct Sha256ArchOrderKey {
	key        string
	key_source string
	end_pos    int
}

struct Sha256ArchOrderValueEnd {
	end_pos   int
	next_pos  int
	delimiter u8
}

fn sha256_arch_order_rank(key string) int {
	return match key {
		'arm' { 0 }
		'intel' { 1 }
		'x86_64' { 2 }
		'arm64_linux' { 3 }
		'x86_64_linux' { 4 }
		else { -1 }
	}
}

fn sha256_arch_order_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn sha256_arch_order_key(source string, begin_pos int) ?Sha256ArchOrderKey {
	if begin_pos >= source.len || (!source[begin_pos].is_letter() && source[begin_pos] != `_`) {
		return none
	}
	mut cursor := begin_pos + 1
	for cursor < source.len && sha256_arch_order_identifier_byte(source[cursor]) {
		cursor++
	}
	if cursor >= source.len || source[cursor] != `:` || (cursor + 1 < source.len && source[cursor + 1] == `:`) {
		return none
	}
	key := source[begin_pos..cursor]
	if sha256_arch_order_rank(key) < 0 {
		return none
	}
	return Sha256ArchOrderKey{
		key: key
		key_source: key
		end_pos: cursor + 1
	}
}

fn sha256_arch_order_value_end(source string, begin_pos int, outer_close u8) Sha256ArchOrderValueEnd {
	mut cursor := begin_pos
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
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
			cursor++
			continue
		}
		if character == `#` && round_depth == 0 && square_depth == 0 && brace_depth == 0 {
			return Sha256ArchOrderValueEnd{
				end_pos: cursor
				next_pos: cursor
				delimiter: `#`
			}
		}
		match character {
			`(` { round_depth++ }
			`[` { square_depth++ }
			`{` { brace_depth++ }
			`)` {
				if round_depth > 0 {
					round_depth--
				} else if outer_close == `)` {
					return Sha256ArchOrderValueEnd{
						end_pos: cursor
						next_pos: cursor + 1
						delimiter: `)`
					}
				}
			}
			`]` {
				if square_depth > 0 {
					square_depth--
				}
			}
			`}` {
				if brace_depth > 0 {
					brace_depth--
				} else if outer_close == `}` {
					return Sha256ArchOrderValueEnd{
						end_pos: cursor
						next_pos: cursor + 1
						delimiter: `}`
					}
				}
			}
			`,` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return Sha256ArchOrderValueEnd{
						end_pos: cursor
						next_pos: cursor + 1
						delimiter: `,`
					}
				}
			}
			`\n`, `\r` {
				if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return Sha256ArchOrderValueEnd{
						end_pos: cursor
						next_pos: cursor
						delimiter: character
					}
				}
			}
			else {}
		}
		cursor++
	}
	return Sha256ArchOrderValueEnd{
		end_pos: source.len
		next_pos: source.len
	}
}

fn sha256_arch_order_trim_end(source string, begin_pos int, end_pos int) int {
	mut trimmed_end := end_pos
	for trimmed_end > begin_pos && source[trimmed_end - 1] in [` `, `\t`, `\r`, `\n`] {
		trimmed_end--
	}
	return trimmed_end
}

fn sha256_arch_order_skip_pair_gap(source string, begin_pos int) (int, bool) {
	mut cursor := begin_pos
	mut has_comment := false
	for cursor < source.len {
		for cursor < source.len && source[cursor] in [` `, `\t`, `\r`, `\n`] {
			cursor++
		}
		if cursor >= source.len || source[cursor] != `#` {
			break
		}
		has_comment = true
		for cursor < source.len && source[cursor] != `\n` {
			cursor++
		}
	}
	return cursor, has_comment
}

fn parse_sha256_arch_order_stanza(source string, method_start int, column int) ?Sha256ArchOrderStanza {
	mut cursor := method_start + 'sha256'.len
	if cursor >= source.len || source[cursor] !in [` `, `\t`, `\r`, `\n`, `(`] {
		return none
	}
	mut outer_close := u8(0)
	if source[cursor] == `(` {
		outer_close = `)`
		cursor++
	}
	for cursor < source.len && source[cursor] in [` `, `\t`, `\r`, `\n`] {
		cursor++
	}
	mut hash_braces := false
	if cursor < source.len && source[cursor] == `{` {
		hash_braces = true
		outer_close = `}`
		cursor++
		for cursor < source.len && source[cursor] in [` `, `\t`, `\r`, `\n`] {
			cursor++
		}
	}
	mut pairs := []Sha256ArchOrderPair{}
	mut has_comment := false
	mut node_end := method_start
	for {
		parsed_key := sha256_arch_order_key(source, cursor) or { return none }
		pair_begin := cursor
		cursor = parsed_key.end_pos
		for cursor < source.len && source[cursor] in [` `, `\t`, `\r`, `\n`] {
			cursor++
		}
		if cursor >= source.len {
			return none
		}
		value_begin := cursor
		value_end := sha256_arch_order_value_end(source, value_begin, outer_close)
		trimmed_end := sha256_arch_order_trim_end(source, value_begin, value_end.end_pos)
		if trimmed_end <= value_begin {
			return none
		}
		pairs << Sha256ArchOrderPair{
			key: parsed_key.key
			key_source: parsed_key.key_source
			value_source: source[value_begin..trimmed_end]
			begin_pos: pair_begin
			end_pos: trimmed_end
			original_index: pairs.len
		}
		node_end = trimmed_end
		if value_end.delimiter == `)` || value_end.delimiter == `}` {
			node_end = value_end.next_pos
			if hash_braces && node_end < source.len {
				mut after_hash := node_end
				for after_hash < source.len && source[after_hash] in [` `, `\t`, `\r`, `\n`] {
					after_hash++
				}
				if after_hash < source.len && source[after_hash] == `)` {
					node_end = after_hash + 1
				}
			}
			break
		}
		if value_end.delimiter != `,` {
			break
		}
		next_cursor, gap_has_comment := sha256_arch_order_skip_pair_gap(source, value_end.next_pos)
		if sha256_arch_order_key(source, next_cursor) == none {
			return none
		}
		has_comment = has_comment || gap_has_comment
		cursor = next_cursor
	}
	if pairs.len == 0 {
		return none
	}
	return Sha256ArchOrderStanza{
		begin_pos: method_start
		end_pos: node_end
		column: column
		pairs: pairs
		has_comment: has_comment
	}
}

fn sha256_arch_order_stanzas(source string) []Sha256ArchOrderStanza {
	mut stanzas := []Sha256ArchOrderStanza{}
	mut line_start := 0
	for line_start < source.len {
		newline_offset := source[line_start..].index_u8(`\n`)
		line_end := if newline_offset < 0 { source.len } else { line_start + newline_offset }
		mut cursor := line_start
		for cursor < line_end && source[cursor] in [` `, `\t`] {
			cursor++
		}
		if cursor < line_end && source[cursor..line_end].starts_with('sha256') {
			method_end := cursor + 'sha256'.len
			if method_end == line_end || !sha256_arch_order_identifier_byte(source[method_end]) {
				if stanza := parse_sha256_arch_order_stanza(source, cursor, cursor - line_start) {
					stanzas << stanza
				}
			}
		}
		if newline_offset < 0 {
			break
		}
		line_start = line_end + 1
	}
	return stanzas
}

fn sha256_arch_order_pairs_sorted(pairs []Sha256ArchOrderPair) []Sha256ArchOrderPair {
	mut sorted := []Sha256ArchOrderPair{cap: pairs.len}
	for pair in pairs {
		pair_rank := sha256_arch_order_rank(pair.key)
		mut insertion := sorted.len
		for index, existing in sorted {
			existing_rank := sha256_arch_order_rank(existing.key)
			if pair_rank < existing_rank || (pair_rank == existing_rank && pair.original_index < existing.original_index) {
				insertion = index
				break
			}
		}
		sorted.insert(insertion, pair)
	}
	return sorted
}

fn sha256_arch_order_pairs_match(left []Sha256ArchOrderPair, right []Sha256ArchOrderPair) bool {
	if left.len != right.len {
		return false
	}
	for index, pair in left {
		if pair.original_index != right[index].original_index {
			return false
		}
	}
	return true
}

pub fn rebuild_sha256_arch_order(column int, pairs []Sha256ArchOrderPair) string {
	mut width := 0
	for pair in pairs {
		if pair.key_source.len > width {
			width = pair.key_source.len
		}
	}
	indent := ' '.repeat(column + sha256_arch_order_stanza_prefix.len)
	mut lines := []string{cap: pairs.len}
	for index, pair in pairs {
		key := '${pair.key_source}:' + ' '.repeat(width + 1 - pair.key_source.len)
		prefix := if index == 0 { sha256_arch_order_stanza_prefix } else { indent }
		lines << prefix + key + pair.value_source
	}
	return lines.join(',\n')
}

pub fn audit_sha256_arch_order(source string) []Sha256ArchOrderOffense {
	mut offenses := []Sha256ArchOrderOffense{}
	for stanza in sha256_arch_order_stanzas(source) {
		sorted := sha256_arch_order_pairs_sorted(stanza.pairs)
		if sha256_arch_order_pairs_match(stanza.pairs, sorted) {
			continue
		}
		offenses << Sha256ArchOrderOffense{
			begin_pos: stanza.begin_pos
			end_pos: stanza.end_pos
			message: sha256_arch_order_message
			replacement: rebuild_sha256_arch_order(stanza.column, sorted)
			correction_suppressed: stanza.has_comment
		}
	}
	return offenses
}

pub fn correct_sha256_arch_order(source string) string {
	offenses := audit_sha256_arch_order(source)
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		if offense.correction_suppressed {
			continue
		}
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn sha256_arch_order_offense_value(offense Sha256ArchOrderOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':             offense.begin_pos.str()
		'end_pos':               offense.end_pos.str()
		'message':               offense.message
		'replacement':           offense.replacement
		'correction_suppressed': offense.correction_suppressed.str()
	})
}
