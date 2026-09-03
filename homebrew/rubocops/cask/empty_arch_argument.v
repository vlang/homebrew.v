module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/empty_arch_argument.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn empty_arch_offense_value(offense EmptyArchArgumentOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'key':        offense.key
		'begin_pos':  offense.begin_pos.str()
		'end_pos':    offense.end_pos.str()
		'message':    offense.message
		'whole_line': offense.whole_line.str()
	})
}

// Ruby method `on_send(node)` at line 26.
pub fn ruby_empty_arch_argument_l26_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_empty_arch_arguments(source)
	return if offenses.len == 0 {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		empty_arch_offense_value(offenses[0])
	}
}

// Ruby method `empty_string_value?(pair)` at line 59.
pub fn ruby_empty_arch_argument_l59_d2_empty_string_value(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 { args[0].as_string().trim_space() } else { '' }
	pair := if value.contains(':') || value.contains('=>') { value } else { 'key: ${value}' }
	parsed := parse_empty_arch_pair(pair, 0, pair.len)
	return brew_runtime.bool_value(parsed.empty)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks for empty strings in the `arch` stanza.
// 8:       #
// 9:       # ### Example
// 10:       #
// 11:       # ```ruby
// 12:       # # bad
// 13:       # arch arm: "-arm64", intel: ""
// 14:       #
// 15:       # # good
// 16:       # arch arm: "-arm64"
// 17:       # ```
// 18:       class EmptyArchArgument < Base
// 19:         include RangeHelp
// 20:         extend AutoCorrector
// 21:
// 22:         MSG = "Remove the empty `%<key>s:` argument from the `arch` stanza."
// 23:         MSG_STANZA = "Remove the `arch` stanza as all its arguments are empty."
// 24:
// 25:         sig { params(node: RuboCop::AST::SendNode).void }
// 26:         def on_send(node)
// 27:           return if node.method_name != :arch || node.receiver
// 28:           return unless (hash = node.first_argument)&.hash_type?
// 29:
// 30:           pairs = hash.pairs
// 31:           return if pairs.none? { |pair| empty_string_value?(pair) }
// 32:
// 33:           if pairs.all? { |pair| empty_string_value?(pair) }
// 34:             add_offense(node, message: MSG_STANZA) do |corrector|
// 35:               corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 36:             end
// 37:             return
// 38:           end
// 39:
// 40:           pairs.each_with_index do |pair, index|
// 41:             next unless empty_string_value?(pair)
// 42:
// 43:             key = (pair.key.sym_type? || pair.key.str_type?) ? pair.key.value : pair.key.source
// 44:
// 45:             add_offense(pair, message: format(MSG, key:)) do |corrector|
// 46:               range = if index.zero?
// 47:                 pair.source_range.join(pairs.fetch(1).source_range.begin)
// 48:               else
// 49:                 pairs.fetch(index - 1).source_range.end.join(pair.source_range.end)
// 50:               end
// 51:               corrector.remove(range)
// 52:             end
// 53:           end
// 54:         end
// 55:
// 56:         private
// 57:
// 58:         sig { params(pair: RuboCop::AST::PairNode).returns(T::Boolean) }
// 59:         def empty_string_value?(pair)
// 60:           pair.value.str_type? && pair.value.value.empty?
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
