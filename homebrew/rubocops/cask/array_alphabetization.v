module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/array_alphabetization.rb`.
// The original source is retained below until every stub has a typed V body.
pub const array_alphabetization_single_message = 'Avoid single-element arrays by removing the []'
pub const array_alphabetization_order_message = 'The array elements should be ordered alphabetically'

pub struct ArrayAlphabetizationOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct ArrayAlphabetizationCall {
	arguments_start int
	arguments_end   int
}

struct ArrayAlphabetizationPair {
	key_symbol   string
	value_symbol string
	value_start  int
	value_end    int
}

struct ArrayAlphabetizationRange {
	begin_pos int
	end_pos   int
}

fn array_alphabetization_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn array_alphabetization_identifier_character(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn array_alphabetization_skip_string(source string, start int, limit int) int {
	quote := source[start]
	mut cursor := start + 1
	mut escaped := false
	for cursor < limit {
		if escaped {
			escaped = false
		} else if source[cursor] == `\\` {
			escaped = true
		} else if source[cursor] == quote {
			return cursor + 1
		}
		cursor++
	}
	return limit
}

fn array_alphabetization_skip_comment(source string, start int, limit int) int {
	mut cursor := start
	for cursor < limit && source[cursor] != `\n` {
		cursor++
	}
	return cursor
}

fn array_alphabetization_matching_close(source string, start int, limit int) int {
	mut expected := []u8{}
	match source[start] {
		`[` { expected << `]` }
		`{` { expected << `}` }
		`(` { expected << `)` }
		else {
			return start
		}
	}
	mut cursor := start + 1
	for cursor < limit {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, limit)
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, limit)
			continue
		}
		if character == `[` {
			expected << `]`
		} else if character == `{` {
			expected << `}`
		} else if character == `(` {
			expected << `)`
		} else if expected.len > 0 && character == expected[expected.len - 1] {
			expected.delete_last()
			if expected.len == 0 {
				return cursor
			}
		}
		cursor++
	}
	return limit
}

fn array_alphabetization_call_end(source string, method_end int) int {
	mut cursor := method_end
	for cursor < source.len && (source[cursor] == ` ` || source[cursor] == `\t`) {
		cursor++
	}
	if cursor < source.len && source[cursor] == `(` {
		closing := array_alphabetization_matching_close(source, cursor, source.len)
		return if closing < source.len { closing } else { source.len }
	}
	mut expected := []u8{}
	mut last_significant := u8(0)
	for cursor < source.len {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, source.len)
			last_significant = `"`
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, source.len)
			continue
		}
		if character == `\n` {
			if expected.len == 0 && last_significant != `,` {
				return cursor
			}
			cursor++
			continue
		}
		if character == `[` {
			expected << `]`
		} else if character == `{` {
			expected << `}`
		} else if character == `(` {
			expected << `)`
		} else if expected.len > 0 && character == expected[expected.len - 1] {
			expected.delete_last()
		}
		if character != ` ` && character != `\t` && character != `\r` {
			last_significant = character
		}
		cursor++
	}
	return source.len
}

fn array_alphabetization_calls(source string) []ArrayAlphabetizationCall {
	mut calls := []ArrayAlphabetizationCall{}
	mut cursor := 0
	for cursor < source.len {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, source.len)
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, source.len)
			continue
		}
		if !array_alphabetization_identifier_start(character) {
			cursor++
			continue
		}
		start := cursor
		cursor++
		for cursor < source.len && array_alphabetization_identifier_character(source[cursor]) {
			cursor++
		}
		method_name := source[start..cursor]
		if method_name !in ['conflicts_with', 'uninstall', 'zap'] {
			continue
		}
		if start > 0 && source[start - 1] == `:` {
			continue
		}
		mut arguments_start := cursor
		for arguments_start < source.len && (source[arguments_start] == ` ` || source[arguments_start] == `\t`) {
			arguments_start++
		}
		if arguments_start >= source.len || (source[arguments_start] != `(` && source[arguments_start] != `\n` && source[arguments_start] != ` ` && source[arguments_start] != `\t` && !array_alphabetization_identifier_start(source[arguments_start]) && source[arguments_start] != `:` && source[arguments_start] != `'` && source[arguments_start] != `"`) {
			continue
		}
		arguments_end := array_alphabetization_call_end(source, cursor)
		if arguments_start < source.len && source[arguments_start] == `(` {
			arguments_start++
		}
		calls << ArrayAlphabetizationCall{
			arguments_start: arguments_start
			arguments_end: arguments_end
		}
	}
	return calls
}

fn array_alphabetization_value_end(source string, start int, limit int) int {
	mut expected := []u8{}
	mut cursor := start
	for cursor < limit {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, limit)
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, limit)
			continue
		}
		if character == `[` {
			expected << `]`
		} else if character == `{` {
			expected << `}`
		} else if character == `(` {
			expected << `)`
		} else if expected.len > 0 && character == expected[expected.len - 1] {
			expected.delete_last()
		} else if expected.len == 0 && (character == `,` || character == `\n` || character == `]` || character == `}` || character == `)`) {
			return cursor
		}
		cursor++
	}
	return limit
}

fn array_alphabetization_direct_symbol(source string, start int, end int) string {
	mut cursor := start
	for cursor < end && source[cursor].is_space() {
		cursor++
	}
	if cursor >= end || source[cursor] != `:` || cursor + 1 >= end || !array_alphabetization_identifier_start(source[cursor + 1]) {
		return ''
	}
	cursor++
	begin := cursor
	for cursor < end && array_alphabetization_identifier_character(source[cursor]) {
		cursor++
	}
	return source[begin..cursor]
}

fn array_alphabetization_make_pair(source string, key_symbol string, value_start int, limit int) ArrayAlphabetizationPair {
	mut start := value_start
	for start < limit && source[start].is_space() {
		start++
	}
	end := array_alphabetization_value_end(source, start, limit)
	return ArrayAlphabetizationPair{
		key_symbol: key_symbol
		value_symbol: array_alphabetization_direct_symbol(source, start, end)
		value_start: start
		value_end: end
	}
}

fn array_alphabetization_pairs(source string, start int, end int) []ArrayAlphabetizationPair {
	mut pairs := []ArrayAlphabetizationPair{}
	mut cursor := start
	for cursor < end {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, end)
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, end)
			continue
		}
		if array_alphabetization_identifier_start(character) {
			identifier_start := cursor
			cursor++
			for cursor < end && array_alphabetization_identifier_character(source[cursor]) {
				cursor++
			}
			mut separator := cursor
			for separator < end && (source[separator] == ` ` || source[separator] == `\t`) {
				separator++
			}
			if separator < end && source[separator] == `:` && (separator + 1 >= end || source[separator + 1] != `:`) {
				pairs << array_alphabetization_make_pair(source, source[identifier_start..cursor], separator + 1, end)
			}
			continue
		}
		if character == `=` && cursor + 1 < end && source[cursor + 1] == `>` {
			mut key_end := cursor
			for key_end > start && source[key_end - 1].is_space() {
				key_end--
			}
			mut key_start := key_end
			for key_start > start && array_alphabetization_identifier_character(source[key_start - 1]) {
				key_start--
			}
			mut key_symbol := ''
			if key_start > start && source[key_start - 1] == `:` {
				key_symbol = source[key_start..key_end]
			}
			pairs << array_alphabetization_make_pair(source, key_symbol, cursor + 2, end)
			cursor += 2
			continue
		}
		cursor++
	}
	return pairs
}

fn array_alphabetization_excluded(pair ArrayAlphabetizationPair) bool {
	excluded := ['signal', 'script', 'early_script', 'args', 'input']
	return pair.key_symbol in excluded || pair.value_symbol in excluded
}

fn array_alphabetization_literal_array(source string, position int, lower_limit int) bool {
	mut cursor := position - 1
	for cursor >= lower_limit && source[cursor].is_space() {
		cursor--
	}
	if cursor < lower_limit {
		return true
	}
	previous := source[cursor]
	return !array_alphabetization_identifier_character(previous) && previous != `]` && previous != `)`
}

fn array_alphabetization_arrays(source string, start int, end int) []ArrayAlphabetizationRange {
	mut arrays := []ArrayAlphabetizationRange{}
	mut cursor := start
	for cursor < end {
		character := source[cursor]
		if character == `'` || character == `"` {
			cursor = array_alphabetization_skip_string(source, cursor, end)
			continue
		}
		if character == `#` {
			cursor = array_alphabetization_skip_comment(source, cursor, end)
			continue
		}
		if character == `[` && array_alphabetization_literal_array(source, cursor, start) {
			closing := array_alphabetization_matching_close(source, cursor, end)
			if closing < end {
				arrays << ArrayAlphabetizationRange{
					begin_pos: cursor
					end_pos: closing + 1
				}
			}
		}
		cursor++
	}
	return arrays
}

fn array_alphabetization_elements(source string, array_range ArrayAlphabetizationRange) []ArrayAlphabetizationRange {
	mut elements := []ArrayAlphabetizationRange{}
	mut cursor := array_range.begin_pos + 1
	limit := array_range.end_pos - 1
	mut expected := []u8{}
	mut element_start := -1
	mut element_end := -1
	for cursor <= limit {
		at_end := cursor == limit
		if !at_end {
			character := source[cursor]
			if character == `'` || character == `"` {
				if expected.len == 0 && element_start < 0 {
					element_start = cursor
				}
				cursor = array_alphabetization_skip_string(source, cursor, limit)
				if expected.len == 0 {
					element_end = cursor
				}
				continue
			}
			if character == `#` {
				cursor = array_alphabetization_skip_comment(source, cursor, limit)
				continue
			}
			if character == `[` {
				expected << `]`
			} else if character == `{` {
				expected << `}`
			} else if character == `(` {
				expected << `)`
			} else if expected.len > 0 && character == expected[expected.len - 1] {
				expected.delete_last()
			}
			if expected.len == 0 && character == `,` {
				if element_start >= 0 && element_end >= element_start {
					elements << ArrayAlphabetizationRange{
						begin_pos: element_start
						end_pos: element_end
					}
				}
				element_start = -1
				element_end = -1
				cursor++
				continue
			}
			if !character.is_space() && expected.len == 0 {
				if element_start < 0 {
					element_start = cursor
				}
				element_end = cursor + 1
			} else if expected.len > 0 {
				if element_start < 0 {
					element_start = cursor
				}
				element_end = cursor + 1
			}
		}
		if at_end {
			if element_start >= 0 && element_end >= element_start {
				elements << ArrayAlphabetizationRange{
					begin_pos: element_start
					end_pos: element_end
				}
			}
			break
		}
		cursor++
	}
	return elements
}

fn array_alphabetization_non_comment_line(group string) string {
	for line in group.split('\n') {
		if !line.trim_space().starts_with('#') {
			return line
		}
	}
	panic('Expected non-comment lines to be present')
}

// recursively_find_array_alphabetization_comments combines a sortable line with
// every immediately preceding comment, exactly as the Ruby helper does.
pub fn recursively_find_array_alphabetization_comments(source []string, index int, line string) string {
	if source.len == 0 {
		return line
	}
	previous_index := if index - 1 < 0 { source.len + index - 1 } else { index - 1 }
	if previous_index >= 0 && previous_index < source.len && source[previous_index].trim_space().starts_with('#') {
		return recursively_find_array_alphabetization_comments(source, previous_index, '${source[previous_index]}\n${line}')
	}
	return line
}

// sort_array_alphabetization retains bracket lines in place and sorts all other
// nonblank lines by their first non-comment line, case-insensitively.
pub fn sort_array_alphabetization(source []string) []string {
	mut combined_source := []string{}
	for index, line in source {
		if line.trim_space() == '' || line.trim_space().starts_with('#') {
			continue
		}
		combined_source << recursively_find_array_alphabetization_comments(source, index, line)
	}
	mut to_sort := []string{}
	mut to_keep := []string{}
	for line in combined_source {
		if !line.contains('[') && !line.contains(']') {
			to_sort << line
		} else {
			to_keep << line
		}
	}
	to_sort.sort_with_compare(fn (left &string, right &string) int {
		left_value := array_alphabetization_non_comment_line(*left).trim_space().to_lower()
		right_value := array_alphabetization_non_comment_line(*right).trim_space().to_lower()
		if left_value < right_value {
			return -1
		}
		if left_value > right_value {
			return 1
		}
		return 0
	})
	mut sorted_index := 0
	mut result := []string{cap: combined_source.len}
	for line in combined_source {
		if line in to_keep {
			result << line
		} else {
			if sorted_index >= to_sort.len {
				panic('Expected to_sort to be present')
			}
			result << to_sort[sorted_index]
			sorted_index++
		}
	}
	return result
}

pub fn audit_array_alphabetization(source string) []ArrayAlphabetizationOffense {
	mut offenses := []ArrayAlphabetizationOffense{}
	for call in array_alphabetization_calls(source) {
		for pair in array_alphabetization_pairs(source, call.arguments_start, call.arguments_end) {
			if array_alphabetization_excluded(pair) {
				continue
			}
			for array_range in array_alphabetization_arrays(source, pair.value_start, pair.value_end) {
				elements := array_alphabetization_elements(source, array_range)
				if elements.len == 1 {
					offenses << ArrayAlphabetizationOffense{
						begin_pos: array_range.begin_pos
						end_pos: array_range.end_pos
						message: array_alphabetization_single_message
						replacement: source[elements[0].begin_pos..elements[0].end_pos]
					}
					continue
				}
				if elements.len <= 1 {
					continue
				}
				array_source := source[array_range.begin_pos..array_range.end_pos]
				sorted_array := sort_array_alphabetization(array_source.split('\n')).join('\n')
				if array_source != sorted_array {
					offenses << ArrayAlphabetizationOffense{
						begin_pos: array_range.begin_pos
						end_pos: array_range.end_pos
						message: array_alphabetization_order_message
						replacement: sorted_array
					}
				}
			}
		}
	}
	return offenses
}

pub fn correct_array_alphabetization(source string) string {
	offenses := audit_array_alphabetization(source)
	mut corrected := source
	for index := offenses.len - 1; index >= 0; index-- {
		offense := offenses[index]
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn array_alphabetization_offense_value(offense ArrayAlphabetizationOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `on_send(node)` at line 11.
pub fn ruby_array_alphabetization_l11_d1_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	offenses := audit_array_alphabetization(source)
	return if offenses.len == 0 {
		ruby.object_value('NilClass', 'nil')
	} else {
		array_alphabetization_offense_value(offenses[0])
	}
}

// Ruby method `sort_array(source)` at line 39.
pub fn ruby_array_alphabetization_l39_d2_sort_array(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	lines := args[0].as_string_array() or { args[0].as_string().split('\n') }
	return ruby.string_array_value(sort_array_alphabetization(lines))
}

// Ruby method `recursively_find_comments(source, index, line)` at line 69.
pub fn ruby_array_alphabetization_l69_d3_recursively_find_comments(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.string_value('')
	}
	lines := args[0].as_string_array() or { args[0].as_string().split('\n') }
	index := int(args[1].as_int() or { 0 })
	return ruby.string_value(recursively_find_array_alphabetization_comments(lines, index, args[2].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class ArrayAlphabetization < Base
// 8:         extend AutoCorrector
// 9:
// 10:         sig { params(node: RuboCop::AST::SendNode).void }
// 11:         def on_send(node)
// 12:           return unless [:conflicts_with, :uninstall, :zap].include?(node.method_name)
// 13:
// 14:           node.each_descendant(:pair).each do |pair|
// 15:             symbols = pair.children.select(&:sym_type?).map(&:value)
// 16:             next if symbols.intersect?([:signal, :script, :early_script, :args, :input])
// 17:
// 18:             pair.each_descendant(:array).each do |array|
// 19:               if array.children.length == 1
// 20:                 add_offense(array, message: "Avoid single-element arrays by removing the []") do |corrector|
// 21:                   corrector.replace(array.source_range, array.children.first.source)
// 22:                 end
// 23:               end
// 24:
// 25:               next if array.children.length <= 1
// 26:
// 27:               sorted_array = sort_array(array.source.split("\n")).join("\n")
// 28:
// 29:               next if array.source == sorted_array
// 30:
// 31:               add_offense(array, message: "The array elements should be ordered alphabetically") do |corrector|
// 32:                 corrector.replace(array.source_range, sorted_array)
// 33:               end
// 34:             end
// 35:           end
// 36:         end
// 37:
// 38:         sig { params(source: T::Array[String]).returns(T::Array[String]) }
// 39:         def sort_array(source)
// 40:           # Combine each comment with the line(s) below so that they remain in the same relative location
// 41:           combined_source = source.each_with_index.filter_map do |line, index|
// 42:             next if line.blank?
// 43:             next if line.strip.start_with?("#")
// 44:
// 45:             next recursively_find_comments(source, index, line)
// 46:           end
// 47:
// 48:           # Separate the lines into those that should be sorted and those that should not
// 49:           # i.e. skip the opening and closing brackets of the array.
// 50:           to_sort, to_keep = combined_source.partition { |line| !line.include?("[") && !line.include?("]") }
// 51:
// 52:           # Sort the lines that should be sorted
// 53:           to_sort.sort! do |a, b|
// 54:             a_non_comment = a.split("\n").reject { |line| line.strip.start_with?("#") }.fetch(0)
// 55:             b_non_comment = b.split("\n").reject { |line| line.strip.start_with?("#") }.fetch(0)
// 56:             a_non_comment.strip.downcase <=> b_non_comment.strip.downcase ||
// 57:               raise("Expected non-comment lines to be present")
// 58:           end
// 59:
// 60:           # Merge the sorted lines and the unsorted lines, preserving the original positions of the unsorted lines
// 61:           combined_source.map do |line|
// 62:             next line if to_keep.include?(line)
// 63:
// 64:             to_sort.shift || raise("Expected to_sort to be present")
// 65:           end
// 66:         end
// 67:
// 68:         sig { params(source: T::Array[String], index: Integer, line: String).returns(String) }
// 69:         def recursively_find_comments(source, index, line)
// 70:           if source.fetch(index - 1).strip.start_with?("#")
// 71:             return recursively_find_comments(source, index - 1, "#{source[index - 1]}\n#{line}")
// 72:           end
// 73:
// 74:           line
// 75:         end
// 76:       end
// 77:     end
// 78:   end
// 79: end
