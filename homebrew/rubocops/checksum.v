module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/checksum.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaChecksumProblem {
pub:
	kind        string
	checksum    string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct FormulaChecksumNode {
	checksum  string
	begin_pos int
	end_pos   int
}

fn formula_checksum_nodes(source string) []FormulaChecksumNode {
	mut nodes := []FormulaChecksumNode{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		mut cursor := 0
		for cursor < line.len && (line[cursor] == ` ` || line[cursor] == `\t`) {
			cursor++
		}
		if line[cursor..].starts_with('sha256') {
			after := cursor + 'sha256'.len
			if after == line.len || line[after] == ` ` || line[after] == `\t` || line[after] == `(` {
				mut quote := after
				for quote < line.len && line[quote] != `"` && line[quote] != `'` {
					quote++
				}
				if quote < line.len {
					quote_character := line[quote]
					mut end := quote + 1
					mut escaped := false
					for end < line.len {
						if escaped {
							escaped = false
						} else if line[end] == `\\` {
							escaped = true
						} else if line[end] == quote_character {
							nodes << FormulaChecksumNode{
								checksum: line[quote + 1..end]
								begin_pos: line_start + quote + 1
								end_pos: line_start + end
							}
							break
						}
						end++
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return nodes
}

fn checksum_word_only(checksum string) bool {
	for character in checksum.bytes() {
		if !character.is_alnum() && character != `_` {
			return false
		}
	}
	return true
}

fn checksum_invalid_range(checksum string) ?[]int {
	mut start := -1
	for index, character in checksum.bytes() {
		valid := character.is_digit() || (character >= `a` && character <= `f`) || (character >= `A` && character <= `F`)
		if !valid && start < 0 {
			start = index
		} else if valid && start >= 0 {
			return [start, index]
		}
	}
	if start >= 0 {
		return [start, checksum.len]
	}
	return none
}

pub fn audit_sha256_checksum(checksum string, begin_pos int) []FormulaChecksumProblem {
	if checksum == '' {
		return [FormulaChecksumProblem{
			kind: 'empty'
			checksum: checksum
			begin_pos: begin_pos - 1
			end_pos: begin_pos + 1
			message: '`sha256` is empty'
		}]
	}
	mut problems := []FormulaChecksumProblem{}
	if checksum.len != 64 && checksum_word_only(checksum) {
		problems << FormulaChecksumProblem{
			kind: 'length'
			checksum: checksum
			begin_pos: begin_pos
			end_pos: begin_pos + checksum.len
			message: '`sha256` should be 64 characters'
		}
	}
	if invalid := checksum_invalid_range(checksum) {
		problems << FormulaChecksumProblem{
			kind: 'invalid_characters'
			checksum: checksum
			begin_pos: begin_pos + invalid[0]
			end_pos: begin_pos + invalid[1]
			message: '`sha256` contains invalid characters'
		}
	}
	return problems
}

pub fn audit_formula_checksums(source string) []FormulaChecksumProblem {
	mut problems := []FormulaChecksumProblem{}
	for method in ['md5', 'sha1'] {
		message := if method == 'md5' {
			'MD5 checksums are deprecated, please use SHA-256'
		} else {
			'SHA1 checksums are deprecated, please use SHA-256'
		}
		if position := source.index(method) {
			problems << FormulaChecksumProblem{
				kind: 'deprecated_${method}'
				begin_pos: position
				end_pos: position + method.len
				message: message
			}
		}
	}
	for node in formula_checksum_nodes(source) {
		problems << audit_sha256_checksum(node.checksum, node.begin_pos)
	}
	return problems
}

pub fn audit_formula_checksum_case(source string) []FormulaChecksumProblem {
	mut problems := []FormulaChecksumProblem{}
	for node in formula_checksum_nodes(source) {
		mut uppercase_start := -1
		mut uppercase_end := -1
		for index, character in node.checksum.bytes() {
			if character >= `A` && character <= `F` {
				if uppercase_start < 0 {
					uppercase_start = index
				}
				uppercase_end = index + 1
			} else if uppercase_start >= 0 {
				break
			}
		}
		if uppercase_start >= 0 {
			problems << FormulaChecksumProblem{
				kind: 'uppercase'
				checksum: node.checksum
				begin_pos: node.begin_pos + uppercase_start
				end_pos: node.begin_pos + uppercase_end
				message: '`sha256` should be lowercase'
				replacement: node.checksum.to_lower()
			}
		}
	}
	return problems
}

pub fn correct_formula_checksum_case(source string) string {
	nodes := formula_checksum_nodes(source)
	mut corrected := source
	if nodes.len == 0 {
		return corrected
	}
	for index := nodes.len - 1; index >= 0; index-- {
		node := nodes[index]
		if node.checksum != node.checksum.to_lower() {
			corrected = corrected[..node.begin_pos] + node.checksum.to_lower() + corrected[node.end_pos..]
		}
	}
	return corrected
}

fn formula_checksum_problem_value(problem FormulaChecksumProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'checksum':    problem.checksum
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_checksum_l12_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_formula_checksums(source).map(formula_checksum_problem_value(it)))
}

// Ruby method `audit_sha256(checksum)` at line 27.
pub fn ruby_checksum_l27_d2_audit_sha256(args ...ruby.Value) ruby.Value {
	checksum := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_sha256_checksum(checksum, 0).map(formula_checksum_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 50.
pub fn ruby_checksum_l50_d3_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_formula_checksum_case(source).map(formula_checksum_problem_value(it)))
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
// 9:       # This cop makes sure that deprecated checksums are not used.
// 10:       class Checksum < FormulaCop
// 11:         sig { override.params(formula_nodes: FormulaNodes).void }
// 12:         def audit_formula(formula_nodes)
// 13:           body_node = formula_nodes.body_node
// 14:
// 15:           problem "MD5 checksums are deprecated, please use SHA-256" if method_called_ever?(body_node, :md5)
// 16:
// 17:           problem "SHA1 checksums are deprecated, please use SHA-256" if method_called_ever?(body_node, :sha1)
// 18:
// 19:           sha256_calls = find_every_method_call_by_name(body_node, :sha256)
// 20:           sha256_calls.each do |sha256_call|
// 21:             sha256_node = get_checksum_node(sha256_call)
// 22:             audit_sha256(sha256_node)
// 23:           end
// 24:         end
// 25:
// 26:         sig { params(checksum: T.nilable(RuboCop::AST::Node)).void }
// 27:         def audit_sha256(checksum)
// 28:           return if checksum.nil?
// 29:
// 30:           if regex_match_group(checksum, /^$/)
// 31:             problem "`sha256` is empty"
// 32:             return
// 33:           end
// 34:
// 35:           if string_content(checksum).size != 64 && regex_match_group(checksum, /^\w*$/)
// 36:             problem "`sha256` should be 64 characters"
// 37:           end
// 38:
// 39:           return unless regex_match_group(checksum, /[^a-f0-9]+/i)
// 40:
// 41:           add_offense(T.must(@offensive_source_range), message: "`sha256` contains invalid characters")
// 42:         end
// 43:       end
// 44:
// 45:       # This cop makes sure that checksum strings are lowercase.
// 46:       class ChecksumCase < FormulaCop
// 47:         extend AutoCorrector
// 48:
// 49:         sig { override.params(formula_nodes: FormulaNodes).void }
// 50:         def audit_formula(formula_nodes)
// 51:           sha256_calls = find_every_method_call_by_name(formula_nodes.body_node, :sha256)
// 52:           sha256_calls.each do |sha256_call|
// 53:             checksum = get_checksum_node(sha256_call)
// 54:             next if checksum.nil?
// 55:             next unless regex_match_group(checksum, /[A-F]+/)
// 56:
// 57:             add_offense(@offensive_source_range, message: "`sha256` should be lowercase") do |corrector|
// 58:               correction = T.must(@offensive_node).source.downcase
// 59:               corrector.insert_before(T.must(@offensive_node).source_range, correction)
// 60:               corrector.remove(T.must(@offensive_node).source_range)
// 61:             end
// 62:           end
// 63:         end
// 64:       end
// 65:     end
// 66:   end
// 67: end
