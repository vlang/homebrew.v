module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/checksum.rb`.
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
