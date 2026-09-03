module rubocops

import brew_runtime
import time

// Translated from Homebrew/brew `rubocops/deprecate_disable.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct DeprecateDisableArgumentNode {
pub:
	key       string
	kind      string
	source    string
	content   string
	begin_pos int
	end_pos   int
}

pub struct DeprecateDisableCall {
pub:
	method    string
	source    string
	begin_pos int
	end_pos   int
	arguments []DeprecateDisableArgumentNode
}

pub struct DeprecateDisableOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct DeprecateDisableAnalysis {
pub:
	offenses  []DeprecateDisableOffense
	corrected string
}

struct DeprecateDisableRange {
	begin_pos int
	end_pos   int
}

struct DeprecateDisableEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

fn deprecate_disable_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn deprecate_disable_trim_range(source string, begin_pos int, end_pos int) DeprecateDisableRange {
	mut start := begin_pos
	mut finish := end_pos
	for start < finish && source[start].is_space() {
		start++
	}
	for finish > start && source[finish - 1].is_space() {
		finish--
	}
	return DeprecateDisableRange{
		begin_pos: start
		end_pos: finish
	}
}

fn deprecate_disable_method_definition(source string, begin_pos int) bool {
	line_start := (source[..begin_pos].last_index('\n') or { -1 }) + 1
	prefix := source[line_start..begin_pos].trim_space()
	return prefix == 'def' || prefix.ends_with(' def')
}

fn deprecate_disable_call_end(source string, begin_pos int, parenthesized bool) int {
	mut round := if parenthesized { 1 } else { 0 }
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	mut index := begin_pos
	for index < source.len {
		character := source[index]
		if escaped {
			escaped = false
			index++
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			index++
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			index++
			continue
		}
		if character == `#` && round == 0 && square == 0 && brace == 0 {
			return deprecate_disable_trim_range(source, begin_pos, index).end_pos
		}
		match character {
			`(` { round++ }
			`)` {
				round--
				if parenthesized && round == 0 {
					return index + 1
				}
			}
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`;`, `\n` {
				if !parenthesized && round == 0 && square == 0 && brace == 0 {
					return deprecate_disable_trim_range(source, begin_pos, index).end_pos
				}
			}
			else {}
		}
		index++
	}
	return deprecate_disable_trim_range(source, begin_pos, source.len).end_pos
}

fn deprecate_disable_split_ranges(source string, begin_pos int, end_pos int) []DeprecateDisableRange {
	mut ranges := []DeprecateDisableRange{}
	mut start := begin_pos
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	for index := begin_pos; index < end_pos; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`,` {
				if round == 0 && square == 0 && brace == 0 {
					part := deprecate_disable_trim_range(source, start, index)
					if part.begin_pos < part.end_pos {
						ranges << part
					}
					start = index + 1
				}
			}
			else {}
		}
	}
	part := deprecate_disable_trim_range(source, start, end_pos)
	if part.begin_pos < part.end_pos {
		ranges << part
	}
	return ranges
}

fn deprecate_disable_keyword_colon(source string, part DeprecateDisableRange) int {
	for index := part.begin_pos; index < part.end_pos; index++ {
		character := source[index]
		if character == `:` {
			key := source[part.begin_pos..index].trim_space()
			if key != '' && key.bytes().all(deprecate_disable_identifier_byte(it)) {
				return index
			}
			return -1
		}
		if !deprecate_disable_identifier_byte(character) && !character.is_space() {
			return -1
		}
	}
	return -1
}

fn deprecate_disable_string_content(literal string) string {
	if literal.len < 2 {
		return literal
	}
	quote := literal[0]
	if quote !in [`'`, `"`] || literal[literal.len - 1] != quote {
		return literal
	}
	mut content := []u8{cap: literal.len - 2}
	mut index := 1
	for index < literal.len - 1 {
		if literal[index] == `\\` && index + 1 < literal.len - 1 {
			next := literal[index + 1]
			if quote == `"` {
				match next {
					`n` { content << `\n` }
					`r` { content << `\r` }
					`t` { content << `\t` }
					else { content << next }
				}
			} else if next in [`'`, `\\`] {
				content << next
			} else {
				content << `\\`
				content << next
			}
			index += 2
			continue
		}
		content << literal[index]
		index++
	}
	return content.bytestr()
}

fn deprecate_disable_arguments(source string, begin_pos int, end_pos int) []DeprecateDisableArgumentNode {
	mut arguments := []DeprecateDisableArgumentNode{}
	for part in deprecate_disable_split_ranges(source, begin_pos, end_pos) {
		colon := deprecate_disable_keyword_colon(source, part)
		if colon < 0 {
			continue
		}
		value_range := deprecate_disable_trim_range(source, colon + 1, part.end_pos)
		if value_range.begin_pos >= value_range.end_pos {
			continue
		}
		literal := source[value_range.begin_pos..value_range.end_pos]
		kind := if literal.len >= 2 && literal[0] in [`'`, `"`] && literal[literal.len - 1] == literal[0] {
			'string'
		} else if literal.starts_with(':') {
			'symbol'
		} else {
			'expression'
		}
		content := match kind {
			'string' { deprecate_disable_string_content(literal) }
			'symbol' { literal[1..] }
			else { literal }
		}
		arguments << DeprecateDisableArgumentNode{
			key: source[part.begin_pos..colon].trim_space()
			kind: kind
			source: literal
			content: content
			begin_pos: value_range.begin_pos
			end_pos: value_range.end_pos
		}
	}
	return arguments
}

fn deprecate_disable_find_call(source string, method string) ?DeprecateDisableCall {
	mut quote := u8(0)
	mut escaped := false
	mut comment := false
	for index := 0; index + method.len <= source.len; index++ {
		character := source[index]
		if comment {
			if character == `\n` {
				comment = false
			}
			continue
		}
		if escaped {
			escaped = false
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		if character == `#` {
			comment = true
			continue
		}
		if source[index..index + method.len] != method {
			continue
		}
		if index > 0 && (deprecate_disable_identifier_byte(source[index - 1]) || source[index - 1] in [
			`:`,
			`!`,
			`?`,
		]) {
			continue
		}
		if index + method.len < source.len && deprecate_disable_identifier_byte(source[index + method.len]) {
			continue
		}
		if deprecate_disable_method_definition(source, index) {
			continue
		}
		method_end := index + method.len
		mut arguments_begin := method_end
		for arguments_begin < source.len && source[arguments_begin] in [` `, `\t`, `\r`] {
			arguments_begin++
		}
		parenthesized := arguments_begin < source.len && source[arguments_begin] == `(`
		call_end := deprecate_disable_call_end(source, if parenthesized {
			arguments_begin + 1
		} else {
			arguments_begin
		}, parenthesized)
		arguments_end := if parenthesized && call_end > arguments_begin && source[call_end - 1] == `)` {
			call_end - 1
		} else {
			call_end
		}
		if parenthesized {
			arguments_begin++
		}
		return DeprecateDisableCall{
			method: method
			source: source[index..call_end]
			begin_pos: index
			end_pos: call_end
			arguments: deprecate_disable_arguments(source, arguments_begin, arguments_end)
		}
	}
	return none
}

pub fn deprecate_disable_calls(source string) []DeprecateDisableCall {
	mut calls := []DeprecateDisableCall{}
	for method in ['deprecate!', 'disable!'] {
		if call := deprecate_disable_find_call(source, method) {
			calls << call
		}
	}
	return calls
}

fn deprecate_disable_nodes(source string, key string, accepted_kinds []string) []DeprecateDisableArgumentNode {
	calls := deprecate_disable_calls(source)
	mut nodes := []DeprecateDisableArgumentNode{}
	if calls.len > 0 {
		for call in calls {
			nodes << call.arguments.filter(it.key == key && it.kind in accepted_kinds)
		}
		return nodes
	}
	return deprecate_disable_arguments(source, 0, source.len).filter(it.key == key && it.kind in accepted_kinds)
}

pub fn deprecate_disable_date_nodes(source string) []DeprecateDisableArgumentNode {
	return deprecate_disable_nodes(source, 'date', ['string'])
}

pub fn deprecate_disable_reason_nodes(source string) []DeprecateDisableArgumentNode {
	return deprecate_disable_nodes(source, 'because', ['string', 'symbol'])
}

fn deprecate_disable_number(value string) !int {
	if value == '' || !value.bytes().all(it.is_digit()) {
		return error('invalid date component `${value}`')
	}
	return value.int()
}

fn deprecate_disable_valid_date(year int, month int, day int) bool {
	if year < -4712 || year > 9999 || month < 1 || month > 12 || day < 1 {
		return false
	}
	maximum := time.days_in_month(month, year) or { return false }
	return day <= maximum
}

fn deprecate_disable_ordinal_valid(year int, ordinal int) bool {
	maximum := if time.is_leap_year(year) { 366 } else { 365 }
	return ordinal >= 1 && ordinal <= maximum
}

fn deprecate_disable_iso8601_date(value string) bool {
	if value.len == 10 && value[4] == `-` && value[7] == `-` {
		year := deprecate_disable_number(value[..4]) or { return false }
		month := deprecate_disable_number(value[5..7]) or { return false }
		day := deprecate_disable_number(value[8..]) or { return false }
		return deprecate_disable_valid_date(year, month, day)
	}
	if value.len == 8 && value[2] == `-` && value[5] == `-` {
		year := 2000 + (deprecate_disable_number(value[..2]) or { return false })
		month := deprecate_disable_number(value[3..5]) or { return false }
		day := deprecate_disable_number(value[6..]) or { return false }
		return deprecate_disable_valid_date(year, month, day)
	}
	if value.len == 8 && value.bytes().all(it.is_digit()) {
		year := deprecate_disable_number(value[..4]) or { return false }
		month := deprecate_disable_number(value[4..6]) or { return false }
		day := deprecate_disable_number(value[6..]) or { return false }
		return deprecate_disable_valid_date(year, month, day)
	}
	if value.len == 8 && value[4] == `-` {
		year := deprecate_disable_number(value[..4]) or { return false }
		ordinal := deprecate_disable_number(value[5..]) or { return false }
		return deprecate_disable_ordinal_valid(year, ordinal)
	}
	if value.len == 7 && value.bytes().all(it.is_digit()) {
		year := deprecate_disable_number(value[..4]) or { return false }
		ordinal := deprecate_disable_number(value[4..]) or { return false }
		return deprecate_disable_ordinal_valid(year, ordinal)
	}
	if value.len == 10 && value[4..6] == '-W' && value[8] == `-` {
		week := deprecate_disable_number(value[6..8]) or { return false }
		weekday := deprecate_disable_number(value[9..]) or { return false }
		return week >= 1 && week <= 53 && weekday >= 1 && weekday <= 7
	}
	if value.len == 8 && value[4] == `W` {
		week := deprecate_disable_number(value[5..7]) or { return false }
		weekday := deprecate_disable_number(value[7..]) or { return false }
		return week >= 1 && week <= 53 && weekday >= 1 && weekday <= 7
	}
	return false
}

fn deprecate_disable_month(value string) int {
	needle := value.to_lower()
	months := ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september',
		'october', 'november', 'december']
	for index, month in months {
		if needle == month || (needle.len == 3 && needle == month[..3]) {
			return index + 1
		}
	}
	return 0
}

fn deprecate_disable_expanded_year(value string) !int {
	year := deprecate_disable_number(value)!
	if value.len == 2 {
		return if year >= 69 { 1900 + year } else { 2000 + year }
	}
	return year
}

fn deprecate_disable_parse_date(value string) !string {
	mut cleaned := value.trim_space().replace(',', ' ')
	for separator in ['-', '/', '.'] {
		cleaned = cleaned.replace(separator, ' ')
	}
	parts := cleaned.fields()
	if parts.len != 3 {
		return error('invalid date `${value}`')
	}
	first_month := deprecate_disable_month(parts[0])
	second_month := deprecate_disable_month(parts[1])
	mut year := 0
	mut month := 0
	mut day := 0
	if first_month > 0 {
		month = first_month
		day = deprecate_disable_number(parts[1])!
		year = deprecate_disable_expanded_year(parts[2])!
	} else if second_month > 0 {
		day = deprecate_disable_number(parts[0])!
		month = second_month
		year = deprecate_disable_expanded_year(parts[2])!
	} else if parts[0].len == 4 {
		year = deprecate_disable_expanded_year(parts[0])!
		month = deprecate_disable_number(parts[1])!
		day = deprecate_disable_number(parts[2])!
	} else {
		day = deprecate_disable_number(parts[0])!
		month = deprecate_disable_number(parts[1])!
		year = deprecate_disable_expanded_year(parts[2])!
	}
	if !deprecate_disable_valid_date(year, month, day) {
		return error('invalid date `${value}`')
	}
	return '${year:04d}-${month:02d}-${day:02d}'
}

fn deprecate_disable_apply_edits(source string, edits []DeprecateDisableEdit) string {
	mut corrected := source
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	for edit in ordered {
		corrected = corrected[..edit.begin_pos] + edit.replacement + corrected[edit.end_pos..]
	}
	return corrected
}

pub fn analyze_deprecate_disable_dates(source string) !DeprecateDisableAnalysis {
	mut offenses := []DeprecateDisableOffense{}
	mut edits := []DeprecateDisableEdit{}
	for call in deprecate_disable_calls(source) {
		for node in call.arguments.filter(it.key == 'date' && it.kind == 'string') {
			if deprecate_disable_iso8601_date(node.content) {
				continue
			}
			fixed := deprecate_disable_parse_date(node.content)!
			replacement := '"${fixed}"'
			offenses << DeprecateDisableOffense{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				message: 'Use `${fixed}` to comply with ISO 8601'
				replacement: replacement
			}
			edits << DeprecateDisableEdit{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				replacement: replacement
			}
		}
	}
	return DeprecateDisableAnalysis{
		offenses: offenses
		corrected: deprecate_disable_apply_edits(source, edits)
	}
}

pub fn analyze_deprecate_disable_reasons(source string) DeprecateDisableAnalysis {
	mut offenses := []DeprecateDisableOffense{}
	mut edits := []DeprecateDisableEdit{}
	for call in deprecate_disable_calls(source) {
		reasons := call.arguments.filter(it.key == 'because' && it.kind in ['string', 'symbol'])
		if reasons.len == 0 {
			message := if call.method == 'deprecate!' {
				'Add a reason for deprecation: `deprecate! because: "..."`'
			} else {
				'Add a reason for disabling: `disable! because: "..."`'
			}
			offenses << DeprecateDisableOffense{
				begin_pos: call.begin_pos
				end_pos: call.end_pos
				message: message
			}
			continue
		}
		for node in reasons {
			if node.kind == 'symbol' {
				continue
			}
			mut corrected_reason := node.content
			if node.content.starts_with('it ') {
				corrected_reason = corrected_reason[3..]
				offenses << DeprecateDisableOffense{
					begin_pos: node.begin_pos
					end_pos: node.end_pos
					message: 'Do not start the reason with `it`'
					replacement: '"${node.content[3..]}"'
				}
			}
			if node.content.len > 0 && node.content[node.content.len - 1] in [`.`, `!`, `?`] {
				corrected_reason = corrected_reason[..corrected_reason.len - 1]
				offenses << DeprecateDisableOffense{
					begin_pos: node.begin_pos
					end_pos: node.end_pos
					message: 'Do not end the reason with a punctuation mark'
					replacement: '"${node.content[..node.content.len - 1]}"'
				}
			}
			if corrected_reason != node.content {
				edits << DeprecateDisableEdit{
					begin_pos: node.begin_pos
					end_pos: node.end_pos
					replacement: '"${corrected_reason}"'
				}
			}
		}
	}
	return DeprecateDisableAnalysis{
		offenses: offenses
		corrected: deprecate_disable_apply_edits(source, edits)
	}
}

fn deprecate_disable_argument_value(node DeprecateDisableArgumentNode) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::AST::Node', node.source, {
		'key':       node.key
		'kind':      node.kind
		'content':   node.content
		'begin_pos': node.begin_pos.str()
		'end_pos':   node.end_pos.str()
	})
}

fn deprecate_disable_analysis_value(analysis DeprecateDisableAnalysis) brew_runtime.Value {
	offenses := analysis.offenses.map(brew_runtime.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
	}))
	return brew_runtime.map_value({
		'offenses':  brew_runtime.array_value(offenses)
		'corrected': brew_runtime.string_value(analysis.corrected)
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_deprecate_disable_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return deprecate_disable_analysis_value(analyze_deprecate_disable_dates(source) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	})
}

// Ruby def_node_search `def_node_search :date, <<~EOS` at line 34.
pub fn ruby_deprecate_disable_l34_d2_date(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	return brew_runtime.array_value(deprecate_disable_date_nodes(args[0].as_string()).map(deprecate_disable_argument_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 46.
pub fn ruby_deprecate_disable_l46_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return deprecate_disable_analysis_value(analyze_deprecate_disable_reasons(source))
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 86.
pub fn ruby_deprecate_disable_l86_d4_reason(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	return brew_runtime.array_value(deprecate_disable_reason_nodes(args[0].as_string()).map(deprecate_disable_argument_value(it)))
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
// 9:       # This cop audits `deprecate!` and `disable!` dates.
// 10:       class DeprecateDisableDate < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           body_node = formula_nodes.body_node
// 16:
// 17:           [:deprecate!, :disable!].each do |method|
// 18:             node = find_node_method_by_name(body_node, method)
// 19:
// 20:             next if node.nil?
// 21:
// 22:             date(node) do |date_node|
// 23:               Date.iso8601(string_content(date_node))
// 24:             rescue ArgumentError
// 25:               fixed_date_string = Date.parse(string_content(date_node)).iso8601
// 26:               @offensive_node = date_node
// 27:               problem "Use `#{fixed_date_string}` to comply with ISO 8601" do |corrector|
// 28:                 corrector.replace(date_node.source_range, "\"#{fixed_date_string}\"")
// 29:               end
// 30:             end
// 31:           end
// 32:         end
// 33:
// 34:         def_node_search :date, <<~EOS
// 35:           (pair (sym :date) $str)
// 36:         EOS
// 37:       end
// 38:
// 39:       # This cop audits `deprecate!` and `disable!` reasons.
// 40:       class DeprecateDisableReason < FormulaCop
// 41:         extend AutoCorrector
// 42:
// 43:         PUNCTUATION_MARKS = %w[. ! ?].freeze
// 44:
// 45:         sig { override.params(formula_nodes: FormulaNodes).void }
// 46:         def audit_formula(formula_nodes)
// 47:           body_node = formula_nodes.body_node
// 48:
// 49:           [:deprecate!, :disable!].each do |method|
// 50:             node = find_node_method_by_name(body_node, method)
// 51:
// 52:             next if node.nil?
// 53:
// 54:             reason_found = T.let(false, T::Boolean)
// 55:             reason(node) do |reason_node|
// 56:               reason_found = true
// 57:               next if reason_node.sym_type?
// 58:
// 59:               @offensive_node = reason_node
// 60:               reason_string = string_content(reason_node)
// 61:
// 62:               if reason_string.start_with?("it ")
// 63:                 problem "Do not start the reason with `it`" do |corrector|
// 64:                   corrector.replace(@offensive_node.source_range, "\"#{reason_string[3..]}\"")
// 65:                 end
// 66:               end
// 67:
// 68:               if PUNCTUATION_MARKS.include?(reason_string[-1])
// 69:                 problem "Do not end the reason with a punctuation mark" do |corrector|
// 70:                   corrector.replace(@offensive_node.source_range, "\"#{reason_string.chop}\"")
// 71:                 end
// 72:               end
// 73:             end
// 74:
// 75:             next if reason_found
// 76:
// 77:             case method
// 78:             when :deprecate!
// 79:               problem 'Add a reason for deprecation: `deprecate! because: "..."`'
// 80:             when :disable!
// 81:               problem 'Add a reason for disabling: `disable! because: "..."`'
// 82:             end
// 83:           end
// 84:         end
// 85:
// 86:         def_node_search :reason, <<~EOS
// 87:           (pair (sym :because) ${str sym})
// 88:         EOS
// 89:       end
// 90:     end
// 91:   end
// 92: end
