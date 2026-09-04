module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/keg_only.rb`.
// The original source is retained below until every stub has a typed V body.
pub const keg_only_allowlist = ['Apple', 'macOS', 'OS', 'Homebrew', 'Xcode', 'GPG', 'GNOME', 'BSD',
	'Firefox']

pub struct KegOnlyArgument {
pub:
	kind      string
	source    string
	content   string
	begin_pos int
	end_pos   int
}

pub struct KegOnlyProblem {
pub:
	kind        string
	reason      string
	first_word  string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

fn keg_only_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn keg_only_decode_string(source string, quote u8) string {
	if source.len < 2 {
		return ''
	}
	mut content := []u8{cap: source.len - 2}
	mut index := 1
	for index < source.len - 1 {
		character := source[index]
		if character != `\\` || index + 1 >= source.len - 1 {
			content << character
			index++
			continue
		}
		next := source[index + 1]
		if quote == `'` {
			if next in [`'`, `\\`] {
				content << next
			} else {
				content << `\\`
				content << next
			}
		} else {
			match next {
				`n` { content << `\n` }
				`r` { content << `\r` }
				`t` { content << `\t` }
				`f` { content << `\f` }
				`v` { content << `\v` }
				`a` { content << u8(7) }
				`b` { content << `\b` }
				else { content << next }
			}
		}
		index += 2
	}
	return content.bytestr()
}

fn keg_only_quoted_end(source string, begin_pos int) int {
	quote := source[begin_pos]
	mut escaped := false
	mut interpolation_depth := 0
	mut index := begin_pos + 1
	for index < source.len {
		character := source[index]
		if escaped {
			escaped = false
			index++
			continue
		}
		if character == `\\` {
			escaped = true
			index++
			continue
		}
		if quote == `"` && character == `#` && index + 1 < source.len && source[index + 1] == `{` {
			interpolation_depth++
			index += 2
			continue
		}
		if interpolation_depth > 0 {
			if character == `{` {
				interpolation_depth++
			} else if character == `}` {
				interpolation_depth--
			}
			index++
			continue
		}
		if character == quote {
			return index + 1
		}
		index++
	}
	return source.len
}

fn keg_only_heredoc_argument(source string, begin_pos int) ?KegOnlyArgument {
	line_end_relative := source[begin_pos..].index_u8(`\n`)
	line_end := if line_end_relative < 0 { source.len } else { begin_pos + line_end_relative }
	marker_source := source[begin_pos..line_end].trim_space().trim_right(')')
	mut marker := marker_source.trim_left('<~-').trim('"\'')
	if marker.contains(' ') || marker.contains('\t') {
		marker = marker.fields()[0]
	}
	if marker == '' || line_end == source.len {
		return none
	}
	mut content_lines := []string{}
	mut cursor := line_end + 1
	for cursor <= source.len {
		newline_relative := source[cursor..].index_u8(`\n`)
		end := if newline_relative < 0 { source.len } else { cursor + newline_relative }
		line := source[cursor..end]
		if line.trim_space() == marker {
			mut indentation := -1
			for content_line in content_lines {
				if content_line.trim_space() == '' {
					continue
				}
				mut spaces := 0
				for spaces < content_line.len && content_line[spaces] in [` `, `\t`] {
					spaces++
				}
				if indentation < 0 || spaces < indentation {
					indentation = spaces
				}
			}
			if indentation < 0 {
				indentation = 0
			}
			mut normalized := []string{cap: content_lines.len}
			for content_line in content_lines {
				normalized << if content_line.len >= indentation {
					content_line[indentation..]
				} else {
					''
				}
			}
			return KegOnlyArgument{
				kind: 'heredoc'
				source: source[begin_pos..line_end]
				content: normalized.join('\n') + '\n'
				begin_pos: begin_pos
				end_pos: line_end
			}
		}
		if newline_relative < 0 {
			break
		}
		content_lines << line
		cursor = end + 1
	}
	return none
}

fn keg_only_argument_at(source string, begin_pos int) ?KegOnlyArgument {
	if begin_pos >= source.len {
		return none
	}
	if source[begin_pos..].starts_with('<<') {
		return keg_only_heredoc_argument(source, begin_pos)
	}
	if source[begin_pos] in [`'`, `"`] {
		first_end := keg_only_quoted_end(source, begin_pos)
		if first_end <= begin_pos + 1 || first_end > source.len || source[first_end - 1] != source[begin_pos] {
			return none
		}
		mut content := keg_only_decode_string(source[begin_pos..first_end], source[begin_pos])
		mut expression_end := first_end
		mut cursor := first_end
		for {
			for cursor < source.len && source[cursor] in [` `, `\t`] {
				cursor++
			}
			if cursor >= source.len || source[cursor] != `+` {
				break
			}
			cursor++
			for cursor < source.len && source[cursor] in [` `, `\t`] {
				cursor++
			}
			if cursor >= source.len || source[cursor] !in [`'`, `"`] {
				break
			}
			part_end := keg_only_quoted_end(source, cursor)
			if part_end <= cursor + 1 || part_end > source.len || source[part_end - 1] != source[cursor] {
				break
			}
			content += keg_only_decode_string(source[cursor..part_end], source[cursor])
			expression_end = part_end
			cursor = part_end
		}
		return KegOnlyArgument{
			kind: 'string'
			source: source[begin_pos..expression_end]
			content: content
			begin_pos: begin_pos
			end_pos: expression_end
		}
	}
	mut end_pos := begin_pos
	for end_pos < source.len && keg_only_identifier_byte(source[end_pos]) {
		end_pos++
	}
	if source[begin_pos] == `:` {
		end_pos = begin_pos + 1
		for end_pos < source.len && keg_only_identifier_byte(source[end_pos]) {
			end_pos++
		}
	}
	if end_pos == begin_pos {
		return none
	}
	raw := source[begin_pos..end_pos]
	return KegOnlyArgument{
		kind: if raw.starts_with(':') { 'symbol' } else { 'constant' }
		source: raw
		content: raw.trim_left(':')
		begin_pos: begin_pos
		end_pos: end_pos
	}
}

pub fn keg_only_argument(source string) ?KegOnlyArgument {
	mut line_start := 0
	for line_start < source.len {
		newline_relative := source[line_start..].index_u8(`\n`)
		line_end := if newline_relative < 0 { source.len } else { line_start + newline_relative }
		line := source[line_start..line_end]
		mut cursor := 0
		for cursor < line.len && line[cursor] in [` `, `\t`] {
			cursor++
		}
		if line[cursor..].starts_with('keg_only') {
			after_method := cursor + 'keg_only'.len
			if after_method == line.len || !keg_only_identifier_byte(line[after_method]) {
				mut argument := line_start + after_method
				for argument < source.len && source[argument] in [` `, `\t`] {
					argument++
				}
				if argument < source.len && source[argument] == `(` {
					argument++
					for argument < source.len && source[argument] in [` `, `\t`] {
						argument++
					}
				}
				return keg_only_argument_at(source, argument)
			}
		}
		if newline_relative < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn keg_only_remove_formula_name(reason string, formula_name string) string {
	if formula_name == '' {
		return reason
	}
	position := reason.to_lower().index(formula_name.to_lower()) or { return reason }
	return reason[..position] + reason[position + formula_name.len..]
}

fn keg_only_first_word(reason string) string {
	words := reason.fields()
	return if words.len == 0 { '' } else { words[0] }
}

fn keg_only_downcase_first(reason string) string {
	if reason == '' {
		return reason
	}
	return reason[..1].to_lower() + reason[1..]
}

pub fn audit_formula_keg_only(source string, formula_name string) []KegOnlyProblem {
	argument := keg_only_argument(source) or { return [] }
	mut reason := keg_only_remove_formula_name(argument.content, formula_name)
	first_word := keg_only_first_word(reason)
	mut problems := []KegOnlyProblem{}
	if reason.len > 0 && reason[0] >= `A` && reason[0] <= `Z` && !keg_only_allowlist.any(reason.starts_with(it)) {
		reason = keg_only_downcase_first(reason)
		problems << KegOnlyProblem{
			kind: 'capitalized_reason'
			reason: reason
			first_word: first_word
			begin_pos: argument.begin_pos
			end_pos: argument.end_pos
			message: "'${first_word}' from the `keg_only` reason should be '${first_word.to_lower()}'."
			replacement: '"${reason}"'
		}
	}
	if reason.ends_with('.') {
		problems << KegOnlyProblem{
			kind: 'trailing_period'
			reason: reason
			first_word: first_word
			begin_pos: argument.begin_pos
			end_pos: argument.end_pos
			message: '`keg_only` reason should not end with a period.'
			replacement: '"${reason[..reason.len - 1]}"'
		}
	}
	return problems
}

pub fn correct_formula_keg_only(source string, formula_name string) string {
	argument := keg_only_argument(source) or { return source }
	problems := audit_formula_keg_only(source, formula_name)
	if problems.len == 0 {
		return source
	}
	replacement := problems.last().replacement
	return source[..argument.begin_pos] + replacement + source[argument.end_pos..]
}

pub fn autocorrect_keg_only_reason(reason string) string {
	if reason == '' {
		return ''
	}
	mut corrected := keg_only_downcase_first(reason)
	if corrected.ends_with('.') {
		corrected = corrected[..corrected.len - 1]
	}
	return '"${corrected}"'
}

fn keg_only_problem_value(problem KegOnlyProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'reason':      problem.reason
		'first_word':  problem.first_word
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_keg_only_l14_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_name := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.array_value(audit_formula_keg_only(source, formula_name).map(keg_only_problem_value(it)))
}

// Ruby method `autocorrect(node)` at line 51.
pub fn ruby_keg_only_l51_d2_autocorrect(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	source := args[0].as_string()
	if source.len >= 2 && source[0] in [`'`, `"`] {
		end_pos := keg_only_quoted_end(source, 0)
		if end_pos == source.len && source[end_pos - 1] == source[0] {
			return ruby.string_value(autocorrect_keg_only_reason(keg_only_decode_string(source, source[0])))
		}
	}
	return ruby.string_value(autocorrect_keg_only_reason(source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop makes sure that a `keg_only` reason has the correct format.
// 10:       class KegOnly < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           keg_only_node = find_node_method_by_name(formula_nodes.body_node, :keg_only)
// 16:           return unless keg_only_node
// 17:
// 18:           allowlist = %w[
// 19:             Apple
// 20:             macOS
// 21:             OS
// 22:             Homebrew
// 23:             Xcode
// 24:             GPG
// 25:             GNOME
// 26:             BSD
// 27:             Firefox
// 28:           ].freeze
// 29:
// 30:           reason = parameters(keg_only_node).fetch(0)
// 31:           @offensive_node = reason
// 32:           name = Regexp.new(T.must(@formula_name), Regexp::IGNORECASE)
// 33:           reason = string_content(reason).sub(name, "")
// 34:           first_word = reason.split.fetch(0)
// 35:
// 36:           if /\A[A-Z]/.match?(reason) && !reason.start_with?(*allowlist)
// 37:             problem "'#{first_word}' from the `keg_only` reason should be '#{first_word.downcase}'." do |corrector|
// 38:               reason[0] = T.must(reason[0]).downcase # reason[0] must exist because of the regexp match
// 39:               corrector.replace(@offensive_node.source_range, "\"#{reason}\"")
// 40:             end
// 41:           end
// 42:
// 43:           return unless reason.end_with?(".")
// 44:
// 45:           problem "`keg_only` reason should not end with a period." do |corrector|
// 46:             corrector.replace(@offensive_node.source_range, "\"#{reason.chop}\"")
// 47:           end
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::Node).void }
// 51:         def autocorrect(node)
// 52:           lambda do |corrector|
// 53:             reason = string_content(node)
// 54:             raise "unexpected empty reason" unless reason[0]
// 55:
// 56:             reason[0] = T.must(reason[0]).downcase # reason[0] must exist because of the previous line
// 57:             reason = reason.delete_suffix(".")
// 58:             corrector.replace(node.source_range, "\"#{reason}\"")
// 59:           end
// 60:         end
// 61:       end
// 62:     end
// 63:   end
// 64: end
