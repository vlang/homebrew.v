module rubocops

import ruby
import homebrew.utils

// Translated from Homebrew/brew `rubocops/bottle.rb`.
pub const bottle_format_cellar_message = '`cellar` should be a parameter to `sha256`'
pub const bottle_format_sha256_message = '`sha256` should use new syntax'
pub const bottle_tag_indentation_message = 'Align bottle tags'
pub const bottle_digest_indentation_message = 'Align bottle digests'
pub const bottle_order_message = 'ARM bottles should be listed before Intel bottles'

pub struct BottleProblem {
pub:
	kind             string
	begin_pos        int
	end_pos          int
	message          string
	replacement      string
	correction_begin int
	correction_end   int
}

pub struct BottleHashPair {
pub:
	key_source      string
	value_source    string
	key_symbol      string
	value_symbol    string
	begin_pos       int
	end_pos         int
	value_begin_pos int
	value_end_pos   int
}

fn bottle_problem_value(problem BottleProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':             problem.kind
		'begin_pos':        problem.begin_pos.str()
		'end_pos':          problem.end_pos.str()
		'message':          problem.message
		'replacement':      problem.replacement
		'correction_begin': problem.correction_begin.str()
		'correction_end':   problem.correction_end.str()
	})
}

fn bottle_formula_class(node utils.AstNode) bool {
	header := node.source.all_before('\n')
	return header.contains('< Formula') || header.contains('< GithubGistFormula') || header.contains('< ScriptFileFormula') || header.contains('< AmazonWebServicesFormula')
}

fn bottle_direct_nodes(root utils.AstNode) []utils.AstNode {
	if root.kind == 'class' {
		return if bottle_formula_class(root) { root.children.clone() } else { []utils.AstNode{} }
	}
	if root.kind == 'begin' {
		formulae := root.children.filter(it.kind == 'class' && bottle_formula_class(it))
		if formulae.len > 0 {
			return formulae[0].children.clone()
		}
		return root.children.clone()
	}
	return [root]
}

fn bottle_block(source string) ?utils.AstNode {
	if !source.contains('bottle') || !source.contains(' do') {
		return none
	}
	_, root := utils.ast_process_source(source)
	for node in bottle_direct_nodes(root) {
		if node.kind == 'block_call' && node.name == 'bottle' {
			return node
		}
	}
	return none
}

fn bottle_trim_range(source string, begin_pos int, end_pos int) (int, int) {
	mut first := begin_pos
	mut last := end_pos
	for first < last && source[first].is_space() {
		first++
	}
	for last > first && source[last - 1].is_space() {
		last--
	}
	return first, last
}

fn bottle_symbol_source(source string) string {
	trimmed := source.trim_space()
	if trimmed.starts_with(':') {
		value := trimmed[1..]
		if value.len >= 2 && value[0] in [`'`, `"`] && value[value.len - 1] == value[0] {
			return value[1..value.len - 1]
		}
		return value
	}
	return ''
}

fn bottle_label_symbol(source string) string {
	trimmed := source.trim_space()
	if trimmed.len >= 2 && trimmed[0] in [`'`, `"`] && trimmed[trimmed.len - 1] == trimmed[0] {
		return trimmed[1..trimmed.len - 1]
	}
	return trimmed
}

fn bottle_top_level_operator(source string, begin_pos int, end_pos int, operator string) int {
	mut position := begin_pos
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position + operator.len <= end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			position++
			continue
		}
		if round_depth == 0 && square_depth == 0 && brace_depth == 0 && source[position..position + operator.len] == operator {
			return position
		}
		match character {
			`(` { round_depth++ }
			`)` { round_depth-- }
			`[` { square_depth++ }
			`]` { square_depth-- }
			`{` { brace_depth++ }
			`}` { brace_depth-- }
			else {}
		}
		position++
	}
	return -1
}

fn bottle_argument_segments(source string, begin_pos int, end_pos int) [][2]int {
	mut segments := [][2]int{}
	mut segment_begin := begin_pos
	mut position := begin_pos
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut brace_depth := 0
	for position < end_pos {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `"`] {
			quote = character
		} else {
			match character {
				`(` { round_depth++ }
				`)` { round_depth-- }
				`[` { square_depth++ }
				`]` { square_depth-- }
				`{` { brace_depth++ }
				`}` { brace_depth-- }
				`,` {
					if round_depth == 0 && square_depth == 0 && brace_depth == 0 {
						segments << [segment_begin, position]!
						segment_begin = position + 1
					}
				}
				else {}
			}
		}
		position++
	}
	segments << [segment_begin, end_pos]!
	return segments
}

fn bottle_pair(source string, segment [2]int) ?BottleHashPair {
	begin_pos, end_pos := bottle_trim_range(source, segment[0], segment[1])
	if begin_pos >= end_pos {
		return none
	}
	rocket := bottle_top_level_operator(source, begin_pos, end_pos, '=>')
	if rocket >= 0 {
		key_begin, key_end := bottle_trim_range(source, begin_pos, rocket)
		value_begin, value_end := bottle_trim_range(source, rocket + 2, end_pos)
		if key_begin >= key_end || value_begin >= value_end {
			return none
		}
		return BottleHashPair{
			key_source: source[key_begin..key_end]
			value_source: source[value_begin..value_end]
			key_symbol: bottle_symbol_source(source[key_begin..key_end])
			value_symbol: bottle_symbol_source(source[value_begin..value_end])
			begin_pos: begin_pos
			end_pos: end_pos
			value_begin_pos: value_begin
			value_end_pos: value_end
		}
	}
	colon := bottle_top_level_operator(source, begin_pos, end_pos, ':')
	if colon < 0 || (colon + 1 < end_pos && source[colon + 1] == `:`) {
		return none
	}
	key_begin, key_end := bottle_trim_range(source, begin_pos, colon)
	value_begin, value_end := bottle_trim_range(source, colon + 1, end_pos)
	if key_begin >= key_end || value_begin >= value_end {
		return none
	}
	return BottleHashPair{
		key_source: source[key_begin..key_end]
		value_source: source[value_begin..value_end]
		key_symbol: bottle_label_symbol(source[key_begin..key_end])
		begin_pos: begin_pos
		end_pos: end_pos
		value_begin_pos: value_begin
		value_end_pos: value_end
	}
}

fn bottle_sha256_pairs(source string, node utils.AstNode) []BottleHashPair {
	mut begin_pos := node.source_range.begin_pos + 'sha256'.len
	mut end_pos := node.source_range.end_pos
	for begin_pos < end_pos && source[begin_pos].is_space() {
		begin_pos++
	}
	if begin_pos < end_pos && source[begin_pos] == `(` && source[end_pos - 1] == `)` {
		begin_pos++
		end_pos--
	}
	for begin_pos < end_pos && source[begin_pos].is_space() {
		begin_pos++
	}
	if begin_pos < end_pos && source[begin_pos] == `{` && source[end_pos - 1] == `}` {
		begin_pos++
		end_pos--
	}
	mut pairs := []BottleHashPair{}
	for segment in bottle_argument_segments(source, begin_pos, end_pos) {
		if pair := bottle_pair(source, segment) {
			pairs << pair
		}
	}
	return pairs
}

fn bottle_line_column(source string, position int) int {
	return position - ((source[..position].last_index('\n') or { -1 }) + 1)
}

fn bottle_first_argument(source string, node utils.AstNode) string {
	if node.arguments.len > 0 {
		range := node.arguments[0].source_range
		return source[range.begin_pos..range.end_pos]
	}
	mut begin_pos := node.source_range.begin_pos + node.name.len
	for begin_pos < node.source_range.end_pos && source[begin_pos].is_space() {
		begin_pos++
	}
	return source[begin_pos..node.source_range.end_pos].trim_space()
}

fn bottle_apply_problems(source string, problems []BottleProblem) string {
	mut corrected := source
	for index := problems.len - 1; index >= 0; index-- {
		problem := problems[index]
		has_correction_range := problem.correction_end > problem.end_pos
		begin_pos := if has_correction_range {
			problem.correction_begin
		} else {
			problem.begin_pos
		}
		end_pos := if has_correction_range {
			problem.correction_end
		} else {
			problem.end_pos
		}
		corrected = corrected[..begin_pos] + problem.replacement + corrected[end_pos..]
	}
	return corrected
}

pub fn audit_bottle_format(source string) []BottleProblem {
	block := bottle_block(source) or { return []BottleProblem{} }
	sha256_nodes := block.children.filter(it.kind == 'method_call' && it.name == 'sha256')
	cellar_nodes := block.children.filter(it.kind == 'method_call' && it.name == 'cellar')
	cellar_source := if cellar_nodes.len > 0 {
		bottle_first_argument(source, cellar_nodes[0])
	} else {
		''
	}
	mut problems := []BottleProblem{}
	if sha256_nodes.len > 0 && cellar_nodes.len > 0 {
		cellar := cellar_nodes[0]
		mut remove_end := cellar.source_range.end_pos
		if remove_end < source.len && source[remove_end] == `\r` {
			remove_end++
		}
		if remove_end < source.len && source[remove_end] == `\n` {
			remove_end++
		}
		problems << BottleProblem{
			kind: 'cellar'
			begin_pos: cellar.source_range.begin_pos
			end_pos: cellar.source_range.end_pos
			message: bottle_format_cellar_message
			replacement: ''
			correction_begin: cellar.source_range.begin_pos - bottle_line_column(source, cellar.source_range.begin_pos)
			correction_end: remove_end
		}
	}
	for node in sha256_nodes {
		pairs := bottle_sha256_pairs(source, node)
		if pairs.len != 1 || pairs[0].value_symbol == '' {
			continue
		}
		pair := pairs[0]
		line := if cellar_source != '' {
			'sha256 cellar: ${cellar_source}, ${pair.value_symbol}: ${pair.key_source}'
		} else {
			'sha256 ${pair.value_symbol}: ${pair.key_source}'
		}
		problems << BottleProblem{
			kind: 'sha256'
			begin_pos: node.source_range.begin_pos
			end_pos: node.source_range.end_pos
			message: bottle_format_sha256_message
			replacement: line
		}
	}
	problems.sort_with_compare(fn (left &BottleProblem, right &BottleProblem) int {
		return left.begin_pos - right.begin_pos
	})
	return problems
}

pub fn correct_bottle_format(source string) string {
	return bottle_apply_problems(source, audit_bottle_format(source))
}

pub fn audit_bottle_tag_indentation(source string) []BottleProblem {
	block := bottle_block(source) or { return []BottleProblem{} }
	mut pairs := []BottleHashPair{}
	for node in block.children.filter(it.kind == 'method_call' && it.name == 'sha256') {
		node_pairs := bottle_sha256_pairs(source, node)
		if node_pairs.len > 0 {
			pairs << node_pairs.last()
		}
	}
	mut maximum := 0
	for pair in pairs {
		column := bottle_line_column(source, pair.begin_pos)
		if column > maximum {
			maximum = column
		}
	}
	mut problems := []BottleProblem{}
	for pair in pairs {
		column := bottle_line_column(source, pair.begin_pos)
		if column == maximum {
			continue
		}
		problems << BottleProblem{
			kind: 'tag'
			begin_pos: pair.begin_pos
			end_pos: pair.end_pos
			message: bottle_tag_indentation_message
			replacement: ' '.repeat(maximum - column) + source[pair.begin_pos..pair.end_pos]
		}
	}
	return problems
}

pub fn correct_bottle_tag_indentation(source string) string {
	return bottle_apply_problems(source, audit_bottle_tag_indentation(source))
}

pub fn audit_bottle_digest_indentation(source string) []BottleProblem {
	block := bottle_block(source) or { return []BottleProblem{} }
	mut pairs := []BottleHashPair{}
	for node in block.children.filter(it.kind == 'method_call' && it.name == 'sha256') {
		node_pairs := bottle_sha256_pairs(source, node)
		if node_pairs.len > 0 {
			pairs << node_pairs.last()
		}
	}
	mut maximum := 0
	for pair in pairs {
		column := bottle_line_column(source, pair.value_begin_pos)
		if column > maximum {
			maximum = column
		}
	}
	mut problems := []BottleProblem{}
	for pair in pairs {
		column := bottle_line_column(source, pair.value_begin_pos)
		if column == maximum {
			continue
		}
		problems << BottleProblem{
			kind: 'digest'
			begin_pos: pair.value_begin_pos
			end_pos: pair.value_end_pos
			message: bottle_digest_indentation_message
			replacement: ' '.repeat(maximum - column) + source[pair.value_begin_pos..pair.value_end_pos]
		}
	}
	return problems
}

pub fn correct_bottle_digest_indentation(source string) string {
	return bottle_apply_problems(source, audit_bottle_digest_indentation(source))
}

pub fn sha256_bottle_tag(source string) ?string {
	if source.trim_space() == '' {
		return none
	}
	_, node := utils.ast_process_source(source)
	mut sha256_node := node
	if node.kind == 'class' || node.kind == 'begin' || node.kind == 'block_call' {
		matches := node.children.filter(it.name == 'sha256')
		if matches.len == 0 {
			return none
		}
		sha256_node = matches[0]
	}
	pairs := bottle_sha256_pairs(source, sha256_node)
	if pairs.len == 0 {
		return none
	}
	pair := pairs.last()
	return if pair.key_symbol != '' {
		pair.key_symbol
	} else if pair.value_symbol != '' {
		pair.value_symbol
	} else {
		none
	}
}

pub fn sha256_order(source string) []string {
	block := bottle_block(source) or {
		if tag := sha256_bottle_tag(source) {
			return [tag]
		}
		return []string{}
	}
	mut tags := []string{}
	for node in block.children.filter(it.kind == 'method_call' && it.name == 'sha256') {
		if tag := sha256_bottle_tag(node.source) {
			tags << tag
		}
	}
	return tags
}

pub fn audit_bottle_order(source string) []BottleProblem {
	block := bottle_block(source) or { return []BottleProblem{} }
	if block.children.len == 0 {
		return []BottleProblem{}
	}
	mut non_sha256 := []utils.AstNode{}
	mut sha256_nodes := []utils.AstNode{}
	for node in block.children {
		if node.name == 'sha256' {
			sha256_nodes << node
		} else {
			non_sha256 << node
		}
	}
	mut arm64_macos := []utils.AstNode{}
	mut intel_macos := []utils.AstNode{}
	mut arm64_linux := []utils.AstNode{}
	mut intel_linux := []utils.AstNode{}
	mut original_tags := []string{}
	for node in sha256_nodes {
		tag := sha256_bottle_tag(node.source) or { continue }
		original_tags << tag
		if tag == 'arm64_linux' {
			arm64_linux << node
		} else if tag.starts_with('arm64') {
			arm64_macos << node
		} else if tag.ends_with('_linux') {
			intel_linux << node
		} else {
			intel_macos << node
		}
	}
	mut ordered_nodes := arm64_macos.clone()
	ordered_nodes << intel_macos
	ordered_nodes << arm64_linux
	ordered_nodes << intel_linux
	mut sorted_tags := []string{}
	for node in ordered_nodes {
		if tag := sha256_bottle_tag(node.source) {
			sorted_tags << tag
		}
	}
	if original_tags == sorted_tags {
		return []BottleProblem{}
	}
	mut lines := ['bottle do']
	for node in non_sha256 {
		lines << '    ${node.source}'
	}
	for node in ordered_nodes {
		lines << '    ${node.source}'
	}
	lines << '  end'
	return [BottleProblem{
		kind: 'order'
		begin_pos: block.source_range.begin_pos
		end_pos: block.source_range.end_pos
		message: bottle_order_message
		replacement: lines.join('\n')
	}]
}

pub fn correct_bottle_order(source string) string {
	return bottle_apply_problems(source, audit_bottle_order(source))
}
