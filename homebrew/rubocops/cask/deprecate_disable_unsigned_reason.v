module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/deprecate_disable_unsigned_reason.rb`.
// The original source is retained below until every stub has a typed V body.
pub const deprecate_disable_unsigned_reason_message = 'Use `:fails_gatekeeper_check` instead of `:unsigned` for deprecate!/disable! reason.'

pub struct DeprecateDisableUnsignedReasonOffense {
pub:
	stanza      string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn unsigned_reason_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn unsigned_reason_stanza_at(source string, position int) ?string {
	for stanza in ['deprecate!', 'disable!'] {
		if !source[position..].starts_with(stanza) {
			continue
		}
		if position > 0 && unsigned_reason_identifier_byte(source[position - 1]) {
			continue
		}
		after := position + stanza.len
		if after < source.len && source[after] != ` ` && source[after] != `\t` && source[after] != `(` {
			continue
		}
		return stanza
	}
	return none
}

fn unsigned_reason_value_at(source string, position int, limit int) ?int {
	if !source[position..limit].starts_with('because') {
		return none
	}
	if position > 0 && unsigned_reason_identifier_byte(source[position - 1]) {
		return none
	}
	mut cursor := position + 'because'.len
	if cursor < limit && unsigned_reason_identifier_byte(source[cursor]) {
		return none
	}
	for cursor < limit && (source[cursor] == ` ` || source[cursor] == `\t`) {
		cursor++
	}
	if cursor >= limit || source[cursor] != `:` {
		return none
	}
	cursor++
	for cursor < limit && (source[cursor] == ` ` || source[cursor] == `\t`) {
		cursor++
	}
	if cursor >= limit || !source[cursor..limit].starts_with(':unsigned') {
		return none
	}
	end_pos := cursor + ':unsigned'.len
	if end_pos < limit && unsigned_reason_identifier_byte(source[end_pos]) {
		return none
	}
	return cursor
}

fn unsigned_reason_call_end(source string, start int) int {
	mut cursor := start
	mut depth := 0
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
		} else if character == `#` && depth == 0 {
			return cursor
		} else if character == `(` {
			depth++
		} else if character == `)` && depth > 0 {
			depth--
			if depth == 0 {
				return cursor + 1
			}
		} else if character == `\n` && depth == 0 {
			return cursor
		}
		cursor++
	}
	return source.len
}

pub fn audit_deprecate_disable_unsigned_reason(source string) []DeprecateDisableUnsignedReasonOffense {
	mut offenses := []DeprecateDisableUnsignedReasonOffense{}
	mut position := 0
	for position < source.len {
		line_start := position == 0 || source[position - 1] == `\n`
		if !line_start {
			position++
			continue
		}
		for position < source.len && (source[position] == ` ` || source[position] == `\t`) {
			position++
		}
		stanza := unsigned_reason_stanza_at(source, position) or {
			for position < source.len && source[position] != `\n` {
				position++
			}
			if position < source.len {
				position++
			}
			continue
		}
		call_end := unsigned_reason_call_end(source, position + stanza.len)
		mut cursor := position + stanza.len
		mut quote := u8(0)
		mut escaped := false
		for cursor < call_end {
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
			if character == `#` {
				for cursor < call_end && source[cursor] != `\n` {
					cursor++
				}
				continue
			}
			if character == `'` || character == `"` {
				quote = character
				cursor++
				continue
			}
			value_position := unsigned_reason_value_at(source, cursor, call_end) or {
				cursor++
				continue
			}
			offenses << DeprecateDisableUnsignedReasonOffense{
				stanza: stanza
				begin_pos: value_position
				end_pos: value_position + ':unsigned'.len
				message: deprecate_disable_unsigned_reason_message
				replacement: ':fails_gatekeeper_check'
			}
			cursor = value_position + ':unsigned'.len
		}
		position = if call_end > position { call_end } else { position + 1 }
	}
	return offenses
}

pub fn correct_deprecate_disable_unsigned_reason(source string) string {
	offenses := audit_deprecate_disable_unsigned_reason(source)
	mut corrected := source
	if offenses.len == 0 {
		return corrected
	}
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn deprecate_disable_unsigned_reason_value(offense DeprecateDisableUnsignedReasonOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'stanza':      offense.stanza
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `on_cask_stanza_block(stanza_block)` at line 26.
pub fn ruby_deprecate_disable_unsigned_reason_l26_d1_on_cask_stanza_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_deprecate_disable_unsigned_reason(source)
	return if offenses.len == 0 {
		ruby.object_value('NilClass', 'nil')
	} else {
		deprecate_disable_unsigned_reason_value(offenses[0])
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop checks for use of `because: :unsigned` in `deprecate!`/`disable!`
// 8:       # and replaces it with the preferred `:fails_gatekeeper_check` reason.
// 9:       #
// 10:       # Example
// 11:       #   # bad
// 12:       #   deprecate! date: "2024-01-01", because: :unsigned
// 13:       #   disable! because: :unsigned
// 14:       #
// 15:       #   # good
// 16:       #   deprecate! date: "2024-01-01", because: :fails_gatekeeper_check
// 17:       #   disable! because: :fails_gatekeeper_check
// 18:       class DeprecateDisableUnsignedReason < Base
// 19:         include CaskHelp
// 20:         extend AutoCorrector
// 21:
// 22:         STANZAS_TO_CHECK = [:deprecate!, :disable!].freeze
// 23:         MESSAGE = "Use `:fails_gatekeeper_check` instead of `:unsigned` for deprecate!/disable! reason."
// 24:
// 25:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 26:         def on_cask_stanza_block(stanza_block)
// 27:           stanzas = stanza_block.stanzas.select { |s| STANZAS_TO_CHECK.include?(s.stanza_name) }
// 28:           stanzas.each do |stanza|
// 29:             stanza_node = T.cast(stanza.stanza_node, RuboCop::AST::SendNode)
// 30:             hash_node = stanza_node.last_argument
// 31:             next unless hash_node&.hash_type?
// 32:
// 33:             # find `because: :unsigned` pairs
// 34:             T.cast(hash_node, RuboCop::AST::HashNode).each_pair do |key_node, value_node|
// 35:               next if !key_node.sym_type? || key_node.value != :because
// 36:               next if !value_node.sym_type? || value_node.value != :unsigned
// 37:
// 38:               add_offense(value_node, message: MESSAGE) do |corrector|
// 39:                 corrector.replace(value_node.source_range, ":fails_gatekeeper_check")
// 40:               end
// 41:             end
// 42:           end
// 43:         end
// 44:       end
// 45:     end
// 46:   end
// 47: end
