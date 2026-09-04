module rubocops

import ruby
import homebrew.utils

// Translated from Homebrew/brew `rubocops/dependency_order.rb`.
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
