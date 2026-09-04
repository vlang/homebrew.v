module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/discontinued.rb`.
// The original source is retained below until every stub has a typed V body.
pub const discontinued_message = 'Use `deprecate!` instead of `caveats { discontinued }`.'

pub struct DiscontinuedOffense {
pub:
	kind        string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct DiscontinuedCaveatsBlock {
	begin_pos  int
	end_pos    int
	body_begin int
	body_end   int
}

fn discontinued_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn discontinued_caveats_blocks(source string) []DiscontinuedCaveatsBlock {
	mut blocks := []DiscontinuedCaveatsBlock{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.trim_space()
		indent := line.len - line.trim_left(' \t').len
		begin_pos := line_start + indent
		if trimmed.starts_with('caveats do') && (trimmed.len == 'caveats do'.len || trimmed['caveats do'.len] in [
			` `,
			`\t`,
			`#`,
		]) {
			mut close_start := if newline < 0 { source.len } else { line_end + 1 }
			for close_start < source.len {
				close_newline := source[close_start..].index_u8(`\n`)
				close_end := if close_newline < 0 {
					source.len
				} else {
					close_start + close_newline
				}
				close_line := source[close_start..close_end]
				close_indent := close_line.len - close_line.trim_left(' \t').len
				if close_indent == indent && close_line.trim_space() == 'end' {
					blocks << DiscontinuedCaveatsBlock{
						begin_pos: begin_pos
						end_pos: close_end
						body_begin: if newline < 0 { line_end } else { line_end + 1 }
						body_end: close_start
					}
					line_start = if close_newline < 0 { close_end } else { close_end + 1 }
					break
				}
				if close_newline < 0 {
					line_start = source.len
					break
				}
				close_start = close_end + 1
			}
			continue
		}
		if trimmed.starts_with('caveats') {
			brace_relative := line.index('{') or { -1 }
			if brace_relative >= 0 {
				close_relative := line.last_index('}') or { -1 }
				if close_relative > brace_relative {
					blocks << DiscontinuedCaveatsBlock{
						begin_pos: begin_pos
						end_pos: line_start + close_relative + 1
						body_begin: line_start + brace_relative + 1
						body_end: line_start + close_relative
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return blocks
}

pub fn find_discontinued_calls(source string, begin_pos int, end_pos int) [][]int {
	mut calls := [][]int{}
	mut cursor := begin_pos
	for cursor < end_pos {
		if source[cursor] == `#` {
			newline := source[cursor..end_pos].index_u8(`\n`)
			cursor = if newline < 0 { end_pos } else { cursor + newline + 1 }
			continue
		}
		if source[cursor] in [`'`, `"`] {
			quote := source[cursor]
			cursor++
			mut escaped := false
			for cursor < end_pos {
				if escaped {
					escaped = false
				} else if source[cursor] == `\\` {
					escaped = true
				} else if source[cursor] == quote {
					cursor++
					break
				}
				cursor++
			}
			continue
		}
		if source[cursor..end_pos].starts_with('discontinued') {
			call_end := cursor + 'discontinued'.len
			before_ok := cursor == begin_pos || !discontinued_identifier(source[cursor - 1])
			after_ok := call_end == end_pos || !discontinued_identifier(source[call_end])
			mut previous := cursor - 1
			for previous >= begin_pos && source[previous].is_space() {
				previous--
			}
			if before_ok && after_ok && (previous < begin_pos || source[previous] != `.`) {
				calls << [cursor, call_end]
				cursor = call_end
				continue
			}
		}
		cursor++
	}
	return calls
}

fn discontinued_significant_body(source string, block DiscontinuedCaveatsBlock) string {
	mut parts := []string{}
	for line in source[block.body_begin..block.body_end].split_into_lines() {
		code := line.all_before('#').trim_space()
		if code != '' {
			parts << code
		}
	}
	return parts.join('\n')
}

pub fn caveats_contains_only_discontinued(source string) bool {
	blocks := discontinued_caveats_blocks(source)
	if blocks.len != 1 {
		return false
	}
	return discontinued_significant_body(source, blocks[0]) == 'discontinued'
}

pub fn audit_cask_discontinued(source string, today string) []DiscontinuedOffense {
	mut offenses := []DiscontinuedOffense{}
	for block in discontinued_caveats_blocks(source) {
		calls := find_discontinued_calls(source, block.body_begin, block.body_end)
		if calls.len == 0 {
			continue
		}
		if discontinued_significant_body(source, block) == 'discontinued' {
			offenses << DiscontinuedOffense{
				kind: 'only_discontinued'
				begin_pos: block.begin_pos
				end_pos: block.end_pos
				message: discontinued_message
				replacement: 'deprecate! date: "${today}", because: :discontinued'
			}
		} else {
			for call in calls {
				offenses << DiscontinuedOffense{
					kind: 'mixed_caveats'
					begin_pos: call[0]
					end_pos: call[1]
					message: discontinued_message
				}
			}
		}
	}
	return offenses
}

pub fn correct_cask_discontinued(source string, today string) string {
	mut offenses := audit_cask_discontinued(source, today).filter(it.replacement != '')
	offenses.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for offense in offenses {
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn discontinued_offense_value(offense DiscontinuedOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':        offense.kind
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `on_cask_stanza_block(stanza_block)` at line 15.
pub fn ruby_discontinued_l15_d1_on_cask_stanza_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	today := if args.len > 1 { args[1].as_string() } else { ruby.today_iso() }
	return ruby.array_value(audit_cask_discontinued(source, today).map(discontinued_offense_value(it)))
}

// Ruby def_node_matcher `def_node_matcher :caveats_contains_only_discontinued?, <<~EOS` at line 30.
pub fn ruby_discontinued_l30_d2_caveats_contains_only_discontinued(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.bool_value(caveats_contains_only_discontinued(source))
}

// Ruby def_node_search `def_node_search :find_discontinued_method_call, <<~EOS` at line 37.
pub fn ruby_discontinued_l37_d3_find_discontinued_method_call(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(find_discontinued_calls(source, 0, source.len).map(fn [source] (call []int) ruby.Value {
		return ruby.structured_value('RuboCop::AST::SendNode', 'discontinued', {
			'begin_pos': call[0].str()
			'end_pos':   call[1].str()
			'source':    source[call[0]..call[1]]
		})
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # This cop corrects `caveats { discontinued }` to `deprecate!`.
// 8:       class Discontinued < Base
// 9:         include CaskHelp
// 10:         extend AutoCorrector
// 11:
// 12:         MESSAGE = "Use `deprecate!` instead of `caveats { discontinued }`."
// 13:
// 14:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 15:         def on_cask_stanza_block(stanza_block)
// 16:           stanza_block.stanzas.select(&:caveats?).each do |stanza|
// 17:             find_discontinued_method_call(stanza.stanza_node) do |node|
// 18:               if caveats_contains_only_discontinued?(node.parent)
// 19:                 add_offense(node.parent, message: MESSAGE) do |corrector|
// 20:                   corrector.replace(node.parent.source_range,
// 21:                                     "deprecate! date: \"#{Date.today}\", because: :discontinued")
// 22:                 end
// 23:               else
// 24:                 add_offense(node, message: MESSAGE)
// 25:               end
// 26:             end
// 27:           end
// 28:         end
// 29:
// 30:         def_node_matcher :caveats_contains_only_discontinued?, <<~EOS
// 31:           (block
// 32:             (send nil? :caveats)
// 33:             (args)
// 34:             (send nil? :discontinued))
// 35:         EOS
// 36:
// 37:         def_node_search :find_discontinued_method_call, <<~EOS
// 38:           $(send nil? :discontinued)
// 39:         EOS
// 40:       end
// 41:     end
// 42:   end
// 43: end
