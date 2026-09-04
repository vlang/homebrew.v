module rubocops

import ruby
import homebrew.utils

// Translated from Homebrew/brew `rubocops/dependency_order.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct DependencyOrderNode {
pub:
	method           string
	name             string
	source           string
	tags             []string
	build_with_names []string
	line             int
	column           int
	begin_pos        int
	end_pos          int
}

pub struct DependencyOrderProblem {
pub:
	method           string
	dependency       string
	other_dependency string
	line             int
	other_line       int
	begin_pos        int
	end_pos          int
	message          string
	corrected        string
}

pub struct DependencyOrderAnalysis {
pub:
	problems  []DependencyOrderProblem
	corrected string
}

fn dependency_order_on_system_methods() []string {
	return ['on_intel', 'on_arm', 'on_macos', 'on_linux', 'on_system', 'on_golden_gate', 'on_tahoe',
		'on_sequoia', 'on_sonoma', 'on_ventura', 'on_monterey', 'on_big_sur', 'on_catalina']
}

fn dependency_order_line(source string, position int) int {
	mut line := 1
	limit := if position < source.len { position } else { source.len }
	for character in source[..limit].bytes() {
		if character == `\n` {
			line++
		}
	}
	return line
}

fn dependency_order_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `-`, `!`, `?`]
}

fn dependency_order_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	return position
}

fn dependency_order_decode_quoted(source string, start int) ?(string, int) {
	if start >= source.len || source[start] !in [`'`, `"`] {
		return none
	}
	quote := source[start]
	mut content := []u8{}
	mut position := start + 1
	mut interpolation_depth := 0
	for position < source.len {
		character := source[position]
		if quote == `"` && character == `#` && position + 1 < source.len && source[position + 1] == `{` {
			interpolation_depth++
			content << character
			content << `{`
			position += 2
			continue
		}
		if interpolation_depth > 0 {
			content << character
			if character == `{` {
				interpolation_depth++
			} else if character == `}` {
				interpolation_depth--
			}
			position++
			continue
		}
		if character == quote {
			return content.bytestr(), position + 1
		}
		if character != `\\` || position + 1 >= source.len {
			content << character
			position++
			continue
		}
		next := source[position + 1]
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
				else { content << next }
			}
		}
		position += 2
	}
	return none
}

fn dependency_order_symbol(source string, start int) ?(string, int) {
	if start >= source.len || source[start] != `:` || start + 1 >= source.len {
		return none
	}
	if source[start + 1] in [`'`, `"`] {
		return dependency_order_decode_quoted(source, start + 1)
	}
	if !(source[start + 1].is_letter() || source[start + 1] == `_`) {
		return none
	}
	mut end := start + 2
	for end < source.len && dependency_order_identifier_byte(source[end]) {
		end++
	}
	return source[start + 1..end], end
}

fn dependency_order_constant(source string, start int) ?(string, int) {
	mut position := start
	if position + 1 < source.len && source[position..position + 2] == '::' {
		position += 2
	}
	if position >= source.len || !source[position].is_capital() {
		return none
	}
	mut end := position + 1
	for end < source.len {
		if source[end].is_alnum() || source[end] == `_` {
			end++
			continue
		}
		if end + 2 < source.len && source[end..end + 2] == '::' && source[end + 2].is_capital() {
			end += 3
			continue
		}
		break
	}
	return source[start..end], end
}

fn dependency_order_name_from_call(source string, method string) ?string {
	trimmed := source.trim_left(' \t\r\n')
	if !trimmed.starts_with(method) {
		return none
	}
	if trimmed.len > method.len && dependency_order_identifier_byte(trimmed[method.len]) {
		return none
	}
	mut position := dependency_order_skip_space(trimmed, method.len)
	if position < trimmed.len && trimmed[position] == `(` {
		position = dependency_order_skip_space(trimmed, position + 1)
	}
	if position < trimmed.len && trimmed[position] == `{` {
		position = dependency_order_skip_space(trimmed, position + 1)
	}
	if position >= trimmed.len {
		return none
	}
	if trimmed[position] in [`'`, `"`] {
		name, _ := dependency_order_decode_quoted(trimmed, position) or { return none }
		return name
	}
	if trimmed[position] == `:` {
		name, _ := dependency_order_symbol(trimmed, position) or { return none }
		return name
	}
	if name, end := dependency_order_constant(trimmed, position) {
		_ = end
		return name
	}
	if trimmed[position].is_letter() || trimmed[position] == `_` {
		mut end := position + 1
		for end < trimmed.len && dependency_order_identifier_byte(trimmed[end]) {
			end++
		}
		if end < trimmed.len && trimmed[end] == `:` && (end + 1 >= trimmed.len || trimmed[end + 1] != `:`) {
			return trimmed[position..end]
		}
	}
	return none
}

pub fn dependency_order_dependency_name(source string) ?string {
	trimmed := source.trim_left(' \t\r\n')
	for method in ['depends_on', 'uses_from_macos'] {
		if name := dependency_order_name_from_call(trimmed, method) {
			return name
		}
	}
	return none
}

fn dependency_order_skip_quoted(source string, start int) int {
	_, end := dependency_order_decode_quoted(source, start) or { return source.len }
	return end
}

fn dependency_order_symbols(source string) []string {
	mut symbols := []string{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `"`] {
			position = dependency_order_skip_quoted(source, position)
			continue
		}
		if character == `#` {
			break
		}
		if character == `:` && (position == 0 || source[position - 1] != `:`) {
			if name, end := dependency_order_symbol(source, position) {
				symbols << name
				position = end
				continue
			}
		}
		if character.is_letter() || character == `_` {
			start := position
			position++
			for position < source.len && dependency_order_identifier_byte(source[position]) {
				position++
			}
			if position < source.len && source[position] == `:` && (position + 1 >= source.len || source[position + 1] != `:`) {
				symbols << source[start..position]
			}
			continue
		}
		position++
	}
	return symbols
}

pub fn dependency_order_build_with_names(source string) []string {
	mut names := []string{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `"`] {
			position = dependency_order_skip_quoted(source, position)
			continue
		}
		if character == `#` {
			break
		}
		if !source[position..].starts_with('build') || (position > 0 && (dependency_order_identifier_byte(source[position - 1]) || source[position - 1] == `.`)) {
			position++
			continue
		}
		mut cursor := position + 'build'.len
		cursor = dependency_order_skip_space(source, cursor)
		if !source[cursor..].starts_with('.with?') {
			position++
			continue
		}
		cursor = dependency_order_skip_space(source, cursor + '.with?'.len)
		if cursor < source.len && source[cursor] == `(` {
			cursor = dependency_order_skip_space(source, cursor + 1)
		}
		if cursor < source.len && source[cursor] in [`'`, `"`] {
			if name, end := dependency_order_decode_quoted(source, cursor) {
				names << name
				position = end
				continue
			}
		} else if cursor < source.len && source[cursor] == `:` {
			if name, end := dependency_order_symbol(source, cursor) {
				names << name
				position = end
				continue
			}
		}
		position++
	}
	return names
}

pub fn dependency_order_depends_on_node(source string) bool {
	trimmed := source.trim_left(' \t\r\n')
	if trimmed.starts_with('depends_on ') || trimmed.starts_with('depends_on(') {
		return true
	}
	body := dependency_order_body(source) or { return false }
	return dependency_order_nodes(source, body, 'depends_on').len == 1
}

pub fn dependency_order_uses_from_macos_node(source string) bool {
	trimmed := source.trim_left(' \t\r\n')
	if trimmed.starts_with('uses_from_macos ') || trimmed.starts_with('uses_from_macos(') {
		return true
	}
	body := dependency_order_body(source) or { return false }
	return dependency_order_nodes(source, body, 'uses_from_macos').len == 1
}

pub fn dependency_order_has_tag(source string, tag string) bool {
	return tag in dependency_order_symbols(source)
}

fn dependency_order_line_end(source string, start int) int {
	return source.index_after('\n', start) or { source.len }
}

fn dependency_order_line_indent(source string, start int, end int) int {
	mut indent := 0
	for start + indent < end && source[start + indent] in [` `, `\t`] {
		indent++
	}
	return indent
}

fn dependency_order_code_on_line(source string, start int, end int) string {
	mut quote := u8(0)
	mut escaped := false
	mut code_end := end
	for position := start; position < end; position++ {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			code_end = position
			break
		}
	}
	return source[start..code_end].trim_right(' \t\r')
}

fn dependency_order_multiline_conditional(source string, ast_node utils.AstNode,
	method string) ?DependencyOrderNode {
	if ast_node.name != 'if' || ast_node.has_receiver || !ast_node.source.trim_space().starts_with('if ') {
		return none
	}
	mut line_start := (source[..ast_node.source_range.begin_pos].last_index('\n') or { -1 }) + 1
	first_end := dependency_order_line_end(source, line_start)
	mut cursor := if first_end < source.len { first_end + 1 } else { source.len }
	mut dependency_source := ''
	mut end_pos := -1
	for cursor < source.len {
		line_end := dependency_order_line_end(source, cursor)
		indent := dependency_order_line_indent(source, cursor, line_end)
		code := dependency_order_code_on_line(source, cursor, line_end)
		trimmed := code.trim_space()
		if indent == ast_node.source_range.column && trimmed == 'end' {
			end_pos = cursor + indent + 'end'.len
			break
		}
		if indent == ast_node.source_range.column && (trimmed == 'else' || trimmed.starts_with('elsif ')) {
			return none
		}
		if trimmed != '' && !trimmed.starts_with('#') {
			if indent != ast_node.source_range.column + 2 || dependency_source != '' {
				return none
			}
			if !(trimmed.starts_with('${method} ') || trimmed.starts_with('${method}(')) {
				return none
			}
			dependency_source = trimmed
		}
		if line_end >= source.len {
			break
		}
		cursor = line_end + 1
	}
	if dependency_source == '' || end_pos < 0 {
		return none
	}
	name := dependency_order_name_from_call(dependency_source, method) or { return none }
	node_source := source[ast_node.source_range.begin_pos..end_pos]
	return DependencyOrderNode{
		method: method
		name: name
		source: node_source
		tags: dependency_order_symbols(node_source)
		build_with_names: dependency_order_build_with_names(node_source)
		line: dependency_order_line(source, ast_node.source_range.begin_pos)
		column: ast_node.source_range.column
		begin_pos: ast_node.source_range.begin_pos
		end_pos: end_pos
	}
}

fn dependency_order_node(source string, ast_node utils.AstNode) ?DependencyOrderNode {
	if ast_node.kind != 'method_call' || ast_node.has_receiver || ast_node.name !in [
		'depends_on',
		'uses_from_macos',
	] {
		return none
	}
	name := dependency_order_name_from_call(ast_node.source, ast_node.name) or { return none }
	return DependencyOrderNode{
		method: ast_node.name
		name: name
		source: ast_node.source
		tags: dependency_order_symbols(ast_node.source)
		build_with_names: dependency_order_build_with_names(ast_node.source)
		line: dependency_order_line(source, ast_node.source_range.begin_pos)
		column: ast_node.source_range.column
		begin_pos: ast_node.source_range.begin_pos
		end_pos: ast_node.source_range.end_pos
	}
}

fn dependency_order_body(source string) ?utils.AstNode {
	mut has_code := false
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed != '' && !trimmed.starts_with('#') {
			has_code = true
			break
		}
	}
	if !has_code {
		return none
	}
	_, root := utils.ast_process_source(source)
	if root.kind == 'class' {
		return utils.AstNode{
			kind: 'begin'
			name: 'begin'
			source: source
			source_range: root.body_range
			body_range: root.body_range
			children: root.children.clone()
		}
	}
	return root
}

fn dependency_order_children(node utils.AstNode) []utils.AstNode {
	return if node.kind in ['begin', 'class', 'block_call'] {
		node.children.clone()
	} else {
		[node]
	}
}

fn dependency_order_nodes(source string, parent utils.AstNode, method string) []DependencyOrderNode {
	mut nodes := []DependencyOrderNode{}
	for child in dependency_order_children(parent) {
		if child.name == method {
			if node := dependency_order_node(source, child) {
				nodes << node
			}
		} else if child.name == 'if' {
			if node := dependency_order_multiline_conditional(source, child, method) {
				nodes << node
			}
		}
	}
	return nodes
}

fn dependency_order_all_nodes(source string, parent utils.AstNode) []DependencyOrderNode {
	mut nodes := []DependencyOrderNode{}
	for child in dependency_order_children(parent) {
		if child.name in ['depends_on', 'uses_from_macos'] {
			if node := dependency_order_node(source, child) {
				nodes << node
			}
		} else if child.name == 'if' {
			if node := dependency_order_multiline_conditional(source, child, 'depends_on') {
				nodes << node
			} else if node := dependency_order_multiline_conditional(source, child, 'uses_from_macos') {
				nodes << node
			}
		}
	}
	return nodes
}

fn dependency_order_find_block(parent utils.AstNode, name string) ?utils.AstNode {
	for child in dependency_order_children(parent) {
		if child.kind == 'block_call' && !child.has_receiver && child.name == name {
			return child
		}
	}
	return none
}

pub fn sort_dependency_order_nodes_by_type(dependency_nodes []DependencyOrderNode) []DependencyOrderNode {
	mut unsorted := dependency_nodes.clone()
	mut ordered := []DependencyOrderNode{cap: dependency_nodes.len}
	for tag in ['build', 'test'] {
		for dependency in unsorted {
			if tag in dependency.tags {
				ordered << dependency
			}
		}
		unsorted = unsorted.filter(tag !in it.tags)
	}
	for dependency in unsorted {
		if !dependency.tags.any(it in ['build', 'recommended', 'test', 'optional']) {
			ordered << dependency
		}
	}
	unsorted = unsorted.filter(it.tags.any(it in ['build', 'recommended', 'test', 'optional']))
	for tag in ['recommended', 'optional'] {
		for dependency in unsorted {
			if tag in dependency.tags {
				ordered << dependency
			}
		}
		unsorted = unsorted.filter(tag !in it.tags)
	}
	return ordered
}

pub fn sort_dependency_order_conditional(dependency_nodes []DependencyOrderNode) []DependencyOrderNode {
	mut ordered := dependency_nodes.clone()
	for _ in 0 .. ordered.len * ordered.len + 1 {
		mut moved := false
		for position, dependency in ordered {
			if dependency.build_with_names.len == 0 {
				continue
			}
			mut relative_position := -1
			for other_position in position + 1 .. ordered.len {
				if ordered[other_position].name in dependency.build_with_names {
					relative_position = other_position - position - 1
				}
			}
			if relative_position < 0 {
				continue
			}
			item := ordered[position]
			ordered.delete(position)
			ordered.insert(position + relative_position + 1, item)
			moved = true
			break
		}
		if !moved {
			break
		}
	}
	return ordered
}

pub fn ensure_dependency_order(nodes []DependencyOrderNode) []DependencyOrderNode {
	mut alphabetized := []DependencyOrderNode{cap: nodes.len}
	for dependency in nodes {
		mut insertion := alphabetized.len
		for index, existing in alphabetized {
			if dependency.name.to_lower() < existing.name.to_lower() {
				insertion = index
				break
			}
		}
		alphabetized.insert(insertion, dependency)
	}
	return sort_dependency_order_conditional(sort_dependency_order_nodes_by_type(alphabetized))
}

pub fn verify_dependency_order(source string, ordered []DependencyOrderNode) []DependencyOrderProblem {
	mut problems := []DependencyOrderProblem{}
	for index, dependency in ordered {
		mut other := DependencyOrderNode{}
		mut found := false
		mut other_line := 0
		for test_dependency in ordered[index + 1..] {
			other_line = test_dependency.line
			if other_line < dependency.line {
				other = test_dependency
				found = true
			}
		}
		if !found {
			continue
		}
		message := '`dependency "${dependency.name}"` (line ${dependency.line}) should be put before `dependency "${other.name}"` (line ${other_line})'
		problems << DependencyOrderProblem{
			method: dependency.method
			dependency: dependency.name
			other_dependency: other.name
			line: dependency.line
			other_line: other_line
			begin_pos: dependency.begin_pos
			end_pos: dependency.end_pos
			message: message
			corrected: dependency_order_move_before(source, dependency, other)
		}
	}
	return problems
}

fn dependency_order_check_nodes(source string, nodes []DependencyOrderNode) []DependencyOrderProblem {
	return verify_dependency_order(source, ensure_dependency_order(nodes))
}

fn dependency_order_check_scope(source string, parent utils.AstNode, method string) []DependencyOrderProblem {
	return dependency_order_check_nodes(source, dependency_order_nodes(source, parent, method))
}

fn dependency_order_audit_once(source string) []DependencyOrderProblem {
	body := dependency_order_body(source) or { return []DependencyOrderProblem{} }
	mut problems := []DependencyOrderProblem{}
	problems << dependency_order_check_scope(source, body, 'depends_on')
	problems << dependency_order_check_scope(source, body, 'uses_from_macos')
	mut block_names := ['head', 'stable']
	block_names << dependency_order_on_system_methods()
	for block_name in block_names {
		block := dependency_order_find_block(body, block_name) or { continue }
		problems << dependency_order_check_scope(source, block, 'depends_on')
		problems << dependency_order_check_scope(source, block, 'uses_from_macos')
	}
	return problems
}

pub fn audit_dependency_order(source string) []DependencyOrderProblem {
	return dependency_order_audit_once(source)
}

fn dependency_order_move_before(source string, dependency DependencyOrderNode,
	other DependencyOrderNode) string {
	if other.begin_pos >= dependency.begin_pos || dependency.end_pos > source.len {
		return source
	}
	mut remove_begin := dependency.begin_pos
	for remove_begin > 0 && source[remove_begin - 1].is_space() {
		remove_begin--
	}
	indentation := ' '.repeat(other.column)
	insertion := dependency.source + '\n' + indentation
	return source[..other.begin_pos] + insertion + source[other.begin_pos..remove_begin] + source[dependency.end_pos..]
}

pub fn correct_dependency_order(source string) string {
	mut corrected := source
	for _ in 0 .. 128 {
		problems := dependency_order_audit_once(corrected)
		if problems.len == 0 || problems[0].corrected == corrected {
			break
		}
		corrected = problems[0].corrected
	}
	return corrected
}

pub fn analyze_dependency_order(source string) DependencyOrderAnalysis {
	return DependencyOrderAnalysis{
		problems: dependency_order_audit_once(source)
		corrected: correct_dependency_order(source)
	}
}

fn dependency_order_problem_value(problem DependencyOrderProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', problem.message, {
		'method':           problem.method
		'dependency':       problem.dependency
		'other_dependency': problem.other_dependency
		'line':             problem.line.str()
		'other_line':       problem.other_line.str()
		'begin_pos':        problem.begin_pos.str()
		'end_pos':          problem.end_pos.str()
		'message':          problem.message
		'corrected':        problem.corrected
	})
}

fn dependency_order_node_value(node DependencyOrderNode) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::AST::Node'
		repr: node.source
		string_array_data: node.build_with_names.clone()
		attributes: {
			'method':    node.method
			'name':      node.name
			'tags':      node.tags.join(',')
			'line':      node.line.str()
			'column':    node.column.str()
			'begin_pos': node.begin_pos.str()
			'end_pos':   node.end_pos.str()
		}
	}
}

fn dependency_order_nodes_from_source(source string) []DependencyOrderNode {
	body := dependency_order_body(source) or { return []DependencyOrderNode{} }
	return dependency_order_all_nodes(source, body)
}

fn dependency_order_nodes_from_args(args []ruby.Value) []DependencyOrderNode {
	if args.len == 0 {
		return []DependencyOrderNode{}
	}
	mut sources := []string{}
	if args.len == 1 && args[0].type_name == 'Array' {
		if args[0].array_data.len > 0 {
			sources = args[0].array_data.map(it.as_string())
		} else {
			sources = args[0].string_array_data.clone()
		}
	} else if args.len == 1 && args[0].as_string().contains('\n') {
		return dependency_order_nodes_from_source(args[0].as_string())
	} else {
		sources = args.map(it.as_string())
	}
	joined := sources.join('\n')
	return dependency_order_nodes_from_source(joined)
}

fn dependency_order_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_dependency_order_l17_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_dependency_order(source).map(dependency_order_problem_value(it)))
}

// Ruby method `check_uses_from_macos_nodes_order(parent_node)` at line 32.
pub fn ruby_dependency_order_l32_d2_check_uses_from_macos_nodes_order(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	body := dependency_order_body(source) or { return ruby.array_value([]ruby.Value{}) }
	return ruby.array_value(dependency_order_check_scope(source, body, 'uses_from_macos').map(dependency_order_problem_value(it)))
}

// Ruby method `check_dependency_nodes_order(parent_node)` at line 40.
pub fn ruby_dependency_order_l40_d3_check_dependency_nodes_order(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	body := dependency_order_body(source) or { return ruby.array_value([]ruby.Value{}) }
	return ruby.array_value(dependency_order_check_scope(source, body, 'depends_on').map(dependency_order_problem_value(it)))
}

// Ruby method `ensure_dependency_order(nodes)` at line 48.
pub fn ruby_dependency_order_l48_d4_ensure_dependency_order(args ...ruby.Value) ruby.Value {
	nodes := dependency_order_nodes_from_args(args)
	joined := nodes.map(it.source).join('\n')
	return ruby.array_value(dependency_order_check_nodes(joined, ensure_dependency_order(nodes)).map(dependency_order_problem_value(it)))
}

// Ruby method `sort_dependencies_by_type(dependency_nodes)` at line 64.
pub fn ruby_dependency_order_l64_d5_sort_dependencies_by_type(args ...ruby.Value) ruby.Value {
	return ruby.array_value(sort_dependency_order_nodes_by_type(dependency_order_nodes_from_args(args)).map(dependency_order_node_value(it)))
}

// Ruby method `sort_conditional_dependencies!(ordered)` at line 82.
pub fn ruby_dependency_order_l82_d6_sort_conditional_dependencies(args ...ruby.Value) ruby.Value {
	return ruby.array_value(sort_dependency_order_conditional(dependency_order_nodes_from_args(args)).map(dependency_order_node_value(it)))
}

// Ruby method `verify_order_in_source(ordered)` at line 109.
pub fn ruby_dependency_order_l109_d7_verify_order_in_source(args ...ruby.Value) ruby.Value {
	nodes := dependency_order_nodes_from_args(args)
	source := nodes.map(it.source).join('\n')
	return ruby.array_value(verify_dependency_order(source, nodes).map(dependency_order_problem_value(it)))
}

// Ruby def_node_matcher `def_node_matcher :depends_on_node?, <<~EOS` at line 135.
pub fn ruby_dependency_order_l135_d8_depends_on_node(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_depends_on_node(args[0].as_string()))
}

// Ruby def_node_matcher `def_node_matcher :uses_from_macos_node?, <<~EOS` at line 140.
pub fn ruby_dependency_order_l140_d9_uses_from_macos_node(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_uses_from_macos_node(args[0].as_string()))
}

// Ruby def_node_search `def_node_search :buildtime_dependency?, "(sym :build)"` at line 145.
pub fn ruby_dependency_order_l145_d10_buildtime_dependency(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_has_tag(args[0].as_string(), 'build'))
}

// Ruby def_node_search `def_node_search :recommended_dependency?, "(sym :recommended)"` at line 147.
pub fn ruby_dependency_order_l147_d11_recommended_dependency(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_has_tag(args[0].as_string(), 'recommended'))
}

// Ruby def_node_search `def_node_search :test_dependency?, "(sym :test)"` at line 149.
pub fn ruby_dependency_order_l149_d12_test_dependency(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_has_tag(args[0].as_string(), 'test'))
}

// Ruby def_node_search `def_node_search :optional_dependency?, "(sym :optional)"` at line 151.
pub fn ruby_dependency_order_l151_d13_optional_dependency(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && dependency_order_has_tag(args[0].as_string(), 'optional'))
}

// Ruby def_node_search `def_node_search :negate_normal_dependency?, "(sym {:build :recommended :test :optional})"` at line 153.
pub fn ruby_dependency_order_l153_d14_negate_normal_dependency(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	symbols := dependency_order_symbols(args[0].as_string())
	return ruby.bool_value(symbols.any(it in ['build', 'recommended', 'test', 'optional']))
}

// Ruby def_node_search `def_node_search :dependency_name_node, <<~EOS` at line 156.
pub fn ruby_dependency_order_l156_d15_dependency_name_node(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dependency_order_nil_value()
	}
	name := dependency_order_dependency_name(args[0].as_string()) or {
		return dependency_order_nil_value()
	}
	return ruby.object_value('RuboCop::AST::Node', name)
}

// Ruby def_node_search `def_node_search :build_with_dependency_node, <<~EOS` at line 162.
pub fn ruby_dependency_order_l162_d16_build_with_dependency_node(args ...ruby.Value) ruby.Value {
	names := if args.len > 0 {
		dependency_order_build_with_names(args[0].as_string())
	} else {
		[]string{}
	}
	return ruby.array_value(names.map(ruby.object_value('RuboCop::AST::Node', it)))
}

// Ruby method `insert_after!(arr, idx1, idx2)` at line 167.
pub fn ruby_dependency_order_l167_d17_insert_after(args ...ruby.Value) ruby.Value {
	mut values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	idx1 := if args.len > 1 { int(args[1].int_data) } else { -1 }
	idx2 := if args.len > 2 { int(args[2].int_data) } else { -1 }
	if idx1 >= 0 && idx1 < values.len && idx2 >= 0 && idx2 < values.len {
		value := values[idx1]
		values.delete(idx1)
		insertion := if idx2 + 1 <= values.len { idx2 + 1 } else { values.len }
		values.insert(insertion, value)
	}
	return ruby.array_value(values)
}

// Ruby method `build_with_dependency_name(node)` at line 175.
pub fn ruby_dependency_order_l175_d18_build_with_dependency_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dependency_order_nil_value()
	}
	names := dependency_order_build_with_names(args[0].as_string())
	return if names.len == 0 {
		dependency_order_nil_value()
	} else {
		ruby.string_array_value(names)
	}
}

// Ruby method `dependency_name(dependency_node)` at line 182.
pub fn ruby_dependency_order_l182_d19_dependency_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return dependency_order_nil_value()
	}
	name := dependency_order_dependency_name(args[0].as_string()) or {
		return dependency_order_nil_value()
	}
	return ruby.string_value(name)
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
// 9:       # This cop checks for correct order of `depends_on` in formulae.
// 10:       #
// 11:       # precedence order:
// 12:       # build-time > test > normal > recommended > optional
// 13:       class DependencyOrder < FormulaCop
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:
// 20:           check_dependency_nodes_order(body_node)
// 21:           check_uses_from_macos_nodes_order(body_node)
// 22:           ([:head, :stable] + on_system_methods).each do |block_name|
// 23:             block = find_block(body_node, block_name)
// 24:             next unless block
// 25:
// 26:             check_dependency_nodes_order(block.body)
// 27:             check_uses_from_macos_nodes_order(block.body)
// 28:           end
// 29:         end
// 30:
// 31:         sig { params(parent_node: T.nilable(RuboCop::AST::Node)).void }
// 32:         def check_uses_from_macos_nodes_order(parent_node)
// 33:           return if parent_node.nil?
// 34:
// 35:           dependency_nodes = parent_node.each_child_node.select { |x| uses_from_macos_node?(x) }
// 36:           ensure_dependency_order(dependency_nodes)
// 37:         end
// 38:
// 39:         sig { params(parent_node: T.nilable(RuboCop::AST::Node)).void }
// 40:         def check_dependency_nodes_order(parent_node)
// 41:           return if parent_node.nil?
// 42:
// 43:           dependency_nodes = parent_node.each_child_node.select { |x| depends_on_node?(x) }
// 44:           ensure_dependency_order(dependency_nodes)
// 45:         end
// 46:
// 47:         sig { params(nodes: T::Array[RuboCop::AST::Node]).void }
// 48:         def ensure_dependency_order(nodes)
// 49:           name_node_pairs = nodes.filter_map do |node|
// 50:             name = dependency_name(node)
// 51:             next unless name
// 52:
// 53:             [name, node]
// 54:           end
// 55:           name_node_pairs.sort_by! { |name, _| name.downcase }
// 56:           ordered = sort_dependencies_by_type(name_node_pairs.map { |_, node| node })
// 57:           sort_conditional_dependencies!(ordered)
// 58:           verify_order_in_source(ordered)
// 59:         end
// 60:
// 61:         # Separate dependencies according to precedence order:
// 62:         # build-time > test > normal > recommended > optional
// 63:         sig { params(dependency_nodes: T::Array[RuboCop::AST::Node]).returns(T::Array[RuboCop::AST::Node]) }
// 64:         def sort_dependencies_by_type(dependency_nodes)
// 65:           unsorted_deps = dependency_nodes.to_a
// 66:           ordered = []
// 67:           ordered.concat(unsorted_deps.select { |dep| buildtime_dependency? dep })
// 68:           unsorted_deps -= ordered
// 69:           ordered.concat(unsorted_deps.select { |dep| test_dependency? dep })
// 70:           unsorted_deps -= ordered
// 71:           ordered.concat(unsorted_deps.reject { |dep| negate_normal_dependency? dep })
// 72:           unsorted_deps -= ordered
// 73:           ordered.concat(unsorted_deps.select { |dep| recommended_dependency? dep })
// 74:           unsorted_deps -= ordered
// 75:           ordered.concat(unsorted_deps.select { |dep| optional_dependency? dep })
// 76:         end
// 77:
// 78:         # `depends_on :apple if build.with? "foo"` should always be defined
// 79:         #  after `depends_on :foo`.
// 80:         # This method reorders the dependencies array according to the above rule.
// 81:         sig { params(ordered: T::Array[RuboCop::AST::Node]).returns(T::Array[RuboCop::AST::Node]) }
// 82:         def sort_conditional_dependencies!(ordered)
// 83:           length = ordered.size
// 84:           idx = 0
// 85:           while idx < length
// 86:             idx1 = T.let(nil, T.nilable(Integer))
// 87:             idx2 = T.let(nil, T.nilable(Integer))
// 88:             ordered.each_with_index do |dep, pos|
// 89:               idx = pos+1
// 90:               match_nodes = build_with_dependency_name(dep)
// 91:               next if match_nodes.blank?
// 92:
// 93:               idx1 = pos
// 94:               ordered.drop(idx1+1).each_with_index do |dep2, pos2|
// 95:                 next unless match_nodes.index(dependency_name(dep2))
// 96:
// 97:                 idx2 = pos2 if idx2.nil? || pos2 > idx2
// 98:               end
// 99:               break if idx2
// 100:             end
// 101:             insert_after!(ordered, idx1, idx2 + idx1) if idx1 &&idx2
// 102:           end
// 103:           ordered
// 104:         end
// 105:
// 106:         # Verify actual order of sorted `depends_on` nodes in source code;
// 107:         # raise RuboCop problem otherwise.
// 108:         sig { params(ordered: T::Array[RuboCop::AST::Node]).void }
// 109:         def verify_order_in_source(ordered)
// 110:           ordered.each_with_index do |node_1, idx|
// 111:             l1 = line_number(node_1)
// 112:             l2 = T.let(nil, T.nilable(Integer))
// 113:             node_2 = T.let(nil, T.nilable(RuboCop::AST::Node))
// 114:             ordered.drop(idx + 1).each do |test_node|
// 115:               l2 = line_number(test_node)
// 116:               node_2 = test_node if l2 < l1
// 117:             end
// 118:             next unless node_2
// 119:
// 120:             offending_node(node_1)
// 121:
// 122:             problem "`dependency \"#{dependency_name(node_1)}\"` (line #{l1}) should be put before " \
// 123:                     "`dependency \"#{dependency_name(node_2)}\"` (line #{l2})" do |corrector|
// 124:               indentation = " " * (start_column(node_2) - line_start_column(node_2))
// 125:               line_breaks = "\n"
// 126:               corrector.insert_before(node_2.source_range,
// 127:                                       node_1.source + line_breaks + indentation)
// 128:               corrector.remove(range_with_surrounding_space(range: node_1.source_range, side: :left))
// 129:             end
// 130:           end
// 131:         end
// 132:
// 133:         # Node pattern method to match
// 134:         # `depends_on` variants.
// 135:         def_node_matcher :depends_on_node?, <<~EOS
// 136:           {(if _ (send nil? :depends_on ...) nil?)
// 137:            (send nil? :depends_on ...)}
// 138:         EOS
// 139:
// 140:         def_node_matcher :uses_from_macos_node?, <<~EOS
// 141:           {(if _ (send nil? :uses_from_macos ...) nil?)
// 142:            (send nil? :uses_from_macos ...)}
// 143:         EOS
// 144:
// 145:         def_node_search :buildtime_dependency?, "(sym :build)"
// 146:
// 147:         def_node_search :recommended_dependency?, "(sym :recommended)"
// 148:
// 149:         def_node_search :test_dependency?, "(sym :test)"
// 150:
// 151:         def_node_search :optional_dependency?, "(sym :optional)"
// 152:
// 153:         def_node_search :negate_normal_dependency?, "(sym {:build :recommended :test :optional})"
// 154:
// 155:         # Node pattern method to extract `name` in `depends_on :name` or `uses_from_macos :name`
// 156:         def_node_search :dependency_name_node, <<~EOS
// 157:           {(send nil? {:depends_on :uses_from_macos} {(hash (pair $_ _) ...) $({str sym dstr} ...) $(const nil? _)} ...)
// 158:            (if _ (send nil? :depends_on {(hash (pair $_ _)) $({str sym dstr} ...) $(const nil? _)}) nil?)}
// 159:         EOS
// 160:
// 161:         # Node pattern method to extract `name` in `build.with? :name`
// 162:         def_node_search :build_with_dependency_node, <<~EOS
// 163:           (send (send nil? :build) :with? $({str sym} _))
// 164:         EOS
// 165:
// 166:         sig { params(arr: T::Array[RuboCop::AST::Node], idx1: Integer, idx2: Integer).void }
// 167:         def insert_after!(arr, idx1, idx2)
// 168:           arr.insert(
// 169:             idx2+1,
// 170:             arr.delete_at(idx1) || raise("unexpected nil value for arr.delete_at(idx1)"),
// 171:           )
// 172:         end
// 173:
// 174:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(T::Array[String])) }
// 175:         def build_with_dependency_name(node)
// 176:           match_nodes = build_with_dependency_node(node)
// 177:           match_nodes = match_nodes.to_a.compact
// 178:           match_nodes.map { |n| string_content(n) } unless match_nodes.empty?
// 179:         end
// 180:
// 181:         sig { params(dependency_node: RuboCop::AST::Node).returns(T.nilable(String)) }
// 182:         def dependency_name(dependency_node)
// 183:           match_node = dependency_name_node(dependency_node).to_a.first
// 184:           string_content(match_node) if match_node
// 185:         end
// 186:       end
// 187:     end
// 188:   end
// 189: end
