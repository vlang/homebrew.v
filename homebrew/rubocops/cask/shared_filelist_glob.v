module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/shared_filelist_glob.rb`.
// The original source is retained below until every stub has a typed V body.
pub const shared_filelist_glob_message = 'Use a glob (*) instead of a specific version (ie. sfl2) for trashing Shared File List paths'

pub struct SharedFilelistGlobOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn shared_filelist_glob_call_end(source string, start int) int {
	mut cursor := start
	mut array_depth := 0
	mut parentheses_depth := 0
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
		} else if character == `#` && array_depth == 0 && parentheses_depth == 0 {
			return cursor
		} else if character == `[` {
			array_depth++
		} else if character == `]` && array_depth > 0 {
			array_depth--
		} else if character == `(` {
			parentheses_depth++
		} else if character == `)` && parentheses_depth > 0 {
			parentheses_depth--
		} else if character == `\n` && array_depth == 0 && parentheses_depth == 0 {
			return cursor
		}
		cursor++
	}
	return source.len
}

fn shared_filelist_glob_trash_array(source string, start int, limit int) ?[]int {
	mut cursor := start
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
			cursor++
			continue
		}
		if character == `'` || character == `"` {
			quote = character
			cursor++
			continue
		}
		if source[cursor..limit].starts_with('trash') {
			before_ok := cursor == start || !(source[cursor - 1].is_alnum() || source[cursor - 1] == `_`)
			mut after := cursor + 'trash'.len
			after_ok := after >= limit || !(source[after].is_alnum() || source[after] == `_`)
			if before_ok && after_ok {
				for after < limit && (source[after] == ` ` || source[after] == `\t`) {
					after++
				}
				if after < limit && source[after] == `:` {
					after++
					for after < limit && (source[after] == ` ` || source[after] == `\t` || source[after] == `\n`) {
						after++
					}
					if after < limit && source[after] == `[` {
						mut depth := 1
						mut end := after + 1
						mut array_quote := u8(0)
						mut array_escaped := false
						for end < limit && depth > 0 {
							array_character := source[end]
							if array_quote != 0 {
								if array_escaped {
									array_escaped = false
								} else if array_character == `\\` {
									array_escaped = true
								} else if array_character == array_quote {
									array_quote = 0
								}
							} else if array_character == `'` || array_character == `"` {
								array_quote = array_character
							} else if array_character == `[` {
								depth++
							} else if array_character == `]` {
								depth--
							}
							end++
						}
						if depth == 0 {
							return [after, end]
						}
					}
				}
			}
		}
		cursor++
	}
	return none
}

pub fn audit_shared_filelist_glob(source string) []SharedFilelistGlobOffense {
	mut offenses := []SharedFilelistGlobOffense{}
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
		if !source[position..].starts_with('zap') || (position + 3 < source.len && source[position + 3].is_alnum()) {
			for position < source.len && source[position] != `\n` {
				position++
			}
			if position < source.len {
				position++
			}
			continue
		}
		call_end := shared_filelist_glob_call_end(source, position + 3)
		array_range := shared_filelist_glob_trash_array(source, position + 3, call_end) or {
			position = if call_end > position { call_end } else { position + 1 }
			continue
		}
		mut cursor := array_range[0] + 1
		for cursor < array_range[1] - 1 {
			if source[cursor] != `"` {
				cursor++
				continue
			}
			item_start := cursor
			cursor++
			mut escaped := false
			for cursor < array_range[1] - 1 {
				if escaped {
					escaped = false
				} else if source[cursor] == `\\` {
					escaped = true
				} else if source[cursor] == `"` {
					break
				}
				cursor++
			}
			if cursor >= array_range[1] - 1 {
				break
			}
			item_end := cursor + 1
			if cursor >= item_start + '.sfl0"'.len && source[cursor - 5..cursor - 1] == '.sfl' && source[cursor - 1].is_digit() {
				offenses << SharedFilelistGlobOffense{
					begin_pos: item_start
					end_pos: item_end
					message: shared_filelist_glob_message
					replacement: source[item_start..cursor - 1] + '*"'
				}
			}
			cursor = item_end
		}
		position = if call_end > position { call_end } else { position + 1 }
	}
	return offenses
}

pub fn correct_shared_filelist_glob(source string) string {
	offenses := audit_shared_filelist_glob(source)
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

fn shared_filelist_glob_value(offense SharedFilelistGlobOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `on_send(node)` at line 11.
pub fn ruby_shared_filelist_glob_l11_d1_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_shared_filelist_glob(source)
	return if offenses.len == 0 {
		ruby.object_value('NilClass', 'nil')
	} else {
		shared_filelist_glob_value(offenses[0])
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class SharedFilelistGlob < Base
// 8:         extend AutoCorrector
// 9:
// 10:         sig { params(node: RuboCop::AST::SendNode).void }
// 11:         def on_send(node)
// 12:           return if node.method_name != :zap
// 13:
// 14:           node.each_descendant(:pair).each do |pair|
// 15:             symbols = pair.children.select(&:sym_type?).map(&:value)
// 16:             next unless symbols.include?(:trash)
// 17:
// 18:             pair.each_descendant(:array).each do |array|
// 19:               regex = /\.sfl\d"$/
// 20:               message = "Use a glob (*) instead of a specific version (ie. sfl2) for trashing Shared File List paths"
// 21:
// 22:               array.children.each do |item|
// 23:                 next unless item.source.match?(regex)
// 24:
// 25:                 corrected_item = item.source.sub(/sfl\d"$/, "sfl*\"")
// 26:
// 27:                 add_offense(item,
// 28:                             message:) do |corrector|
// 29:                   corrector.replace(item, corrected_item)
// 30:                 end
// 31:               end
// 32:             end
// 33:           end
// 34:         end
// 35:       end
// 36:     end
// 37:   end
// 38: end
