module utils

import ruby

// Translated from Homebrew/brew `utils/ast.rb`.
pub struct AstRange {
pub:
	begin_pos int
	end_pos   int
	column    int
}

pub struct AstArgument {
pub:
	value        ruby.Value
	source_range AstRange
}

pub struct AstHashPair {
pub:
	key         string
	key_range   AstRange
	value       ruby.Value
	value_range AstRange
}

pub struct AstStanzaPair {
pub:
	name  string
	value ruby.Value
}

pub struct AstNode {
pub:
	kind         string
	name         string
	source       string
	source_range AstRange
	body_range   AstRange
	arguments    []AstArgument
	hash_pairs   []AstHashPair
	children     []AstNode
	has_receiver bool
}

pub struct FormulaAst {
pub mut:
	contents string
}

pub struct CaskAst {
pub mut:
	contents string
}

struct AstLine {
	start       int
	end         int
	newline_end int
	indent      int
	text        string
}

fn ast_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn ast_symbol(value string) ruby.Value {
	name := value.trim_left(':')
	return ruby.object_value('Symbol', ':${name}')
}

fn ast_lines(source string) []AstLine {
	mut result := []AstLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && (text[indent] == ` ` || text[indent] == `\t`) {
			indent++
		}
		result << AstLine{
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			indent: indent
			text: text
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return result
}

fn ast_code_end(text string) int {
	mut quote := u8(0)
	mut escaped := false
	for index, character in text.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character == `"` || character == `'` {
			quote = character
		} else if character == `#` {
			return index
		}
	}
	return text.len
}

fn ast_bracket_delta(text string) int {
	mut result := 0
	mut quote := u8(0)
	mut escaped := false
	for character in text.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character == `"` || character == `'` {
			quote = character
		} else if character == `[` || character == `{` || character == `(` {
			result++
		} else if character == `]` || character == `}` || character == `)` {
			result--
		} else if character == `#` {
			break
		}
	}
	return result
}

fn ast_name_from_line(trimmed string) (string, bool) {
	mut end := 0
	for end < trimmed.len {
		character := trimmed[end]
		if !(character.is_alnum() || character == `_` || character == `!` || character == `?` || character == `.`) {
			break
		}
		end++
	}
	if end == 0 {
		return '', false
	}
	full := trimmed[..end]
	parts := full.split('.')
	return parts.last(), parts.len > 1
}

fn ast_unescape_string(value string, quote u8) string {
	mut result := ''
	mut escaped := false
	for character in value.bytes() {
		if escaped {
			result += match character {
				`n` { '\n' }
				`t` { '\t' }
				`r` { '\r' }
				else { character.ascii_str() }
			}
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else {
			result += character.ascii_str()
		}
	}
	if escaped {
		result += '\\'
	}
	_ = quote
	return result
}

fn ast_literal_at(source string, start int, limit int) ?AstArgument {
	mut position := start
	for position < limit && source[position].is_space() {
		position++
	}
	if position >= limit {
		return none
	}
	first := source[position]
	if first == `"` || first == `'` {
		mut end := position + 1
		mut escaped := false
		for end < limit {
			character := source[end]
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == first {
				end++
				break
			}
			end++
		}
		return AstArgument{
			value: ruby.string_value(ast_unescape_string(source[position + 1..end - 1], first))
			source_range: AstRange{ begin_pos: position, end_pos: end, column: position }
		}
	}
	if first == `:` && position + 1 < limit {
		mut end := position + 1
		for end < limit && (source[end].is_alnum() || source[end] == `_` || source[end] == `-`) {
			end++
		}
		return AstArgument{
			value: ast_symbol(source[position + 1..end])
			source_range: AstRange{ begin_pos: position, end_pos: end, column: position }
		}
	}
	if first.is_digit() || first == `-` {
		mut end := position + 1
		for end < limit && (source[end].is_digit() || source[end] == `.`) {
			end++
		}
		raw := source[position..end]
		value := if raw.contains('.') {
			ruby.float_value(raw.f64())
		} else {
			ruby.int_value(raw.i64())
		}
		return AstArgument{
			value: value
			source_range: AstRange{ begin_pos: position, end_pos: end, column: position }
		}
	}
	return none
}

fn ast_arguments(source string, argument_start int, argument_end int) ([]AstArgument, []AstHashPair) {
	mut arguments := []AstArgument{}
	mut pairs := []AstHashPair{}
	if argument := ast_literal_at(source, argument_start, argument_end) {
		arguments << argument
	}
	mut position := argument_start
	mut quote := u8(0)
	mut escaped := false
	for position < argument_end {
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
		if character == `"` || character == `'` {
			quote = character
			position++
			continue
		}
		if character.is_letter() || character == `_` {
			key_start := position
			position++
			for position < argument_end && (source[position].is_alnum() || source[position] == `_`) {
				position++
			}
			key_end := position
			if position < argument_end && source[position] == `:` && (position + 1 >= argument_end || source[position + 1] != `:`) {
				if value := ast_literal_at(source, position + 1, argument_end) {
					pairs << AstHashPair{
						key: source[key_start..key_end]
						key_range: AstRange{ begin_pos: key_start, end_pos: key_end, column: key_start }
						value: value.value
						value_range: value.source_range
					}
					position = value.source_range.end_pos
				}
			}
			continue
		}
		position++
	}
	return arguments, pairs
}

fn ast_find_matching_end(lines []AstLine, start_index int, indent int, scope_end int) int {
	mut depth := 0
	for index in start_index .. scope_end {
		trimmed := lines[index].text.trim_space()
		if trimmed == '' || trimmed.starts_with('#') {
			continue
		}
		if lines[index].indent < indent {
			break
		}
		if lines[index].indent == indent {
			if index != start_index && trimmed == 'end' {
				if depth == 0 {
					return index
				}
				depth--
			} else if index != start_index && (trimmed.starts_with('class ') || trimmed.starts_with('def ') || trimmed.ends_with(' do') || trimmed.contains(' do |')) {
				depth++
			}
		}
	}
	return -1
}

fn ast_direct_indent(lines []AstLine, start_index int, end_index int, parent_indent int) int {
	mut result := 1 << 30
	for index in start_index .. end_index {
		line := lines[index]
		trimmed := line.text.trim_space()
		if trimmed == '' || trimmed.starts_with('#') || line.indent <= parent_indent {
			continue
		}
		if line.indent < result {
			result = line.indent
		}
	}
	return if result == 1 << 30 { parent_indent + 2 } else { result }
}

fn ast_parse_scope(source string, lines []AstLine, start_index int, end_index int,
	indent int) []AstNode {
	mut nodes := []AstNode{}
	mut index := start_index
	for index < end_index {
		line := lines[index]
		trimmed := line.text.trim_space()
		if trimmed == '' || trimmed.starts_with('#') || line.indent != indent || trimmed == 'end' {
			index++
			continue
		}
		line_code_end := ast_code_end(line.text)
		code := line.text[..line_code_end].trim_right(' \t')
		code_trimmed := code.trim_space()
		mut kind := 'method_call'
		mut name := ''
		mut has_receiver := false
		mut block := false
		if code_trimmed.starts_with('class ') {
			kind = 'class'
			name = code_trimmed[6..].all_before(' ').trim_space()
			block = true
		} else if code_trimmed.starts_with('def ') {
			kind = 'method_definition'
			name = code_trimmed[4..].all_before('(').all_before(' ').trim_space()
			block = true
		} else {
			name, has_receiver = ast_name_from_line(code_trimmed)
			block = code_trimmed.ends_with(' do') || code_trimmed.contains(' do |')
			if block {
				kind = 'block_call'
			}
		}
		if name == '' {
			index++
			continue
		}
		start := line.start + line.indent
		if block {
			closing_index := ast_find_matching_end(lines, index, indent, end_index)
			if closing_index < 0 {
				panic('unterminated Ruby `${name}` block')
			}
			closing := lines[closing_index]
			end := closing.start + closing.text.index('end') or { closing.end }
			node_end := end + 3
			name_offset := code_trimmed.index(name) or { 0 }
			mut argument_start := start + name_offset + name.len
			mut argument_end := line.start + line_code_end
			do_position := source[argument_start..argument_end].last_index(' do') or {
				argument_end - argument_start
			}
			argument_end = argument_start + do_position
			arguments, pairs := ast_arguments(source, argument_start, argument_end)
			child_indent := ast_direct_indent(lines, index + 1, closing_index, indent)
			children := ast_parse_scope(source, lines, index + 1, closing_index, child_indent)
			nodes << AstNode{
				kind: kind
				name: name
				source: source[start..node_end]
				source_range: AstRange{ begin_pos: start, end_pos: node_end, column: indent }
				body_range: AstRange{
					begin_pos: line.newline_end
					end_pos: closing.start
					column: child_indent
				}
				arguments: arguments
				hash_pairs: pairs
				children: children
				has_receiver: has_receiver
			}
			index = closing_index + 1
			continue
		}
		mut last_index := index
		mut balance := ast_bracket_delta(code)
		mut continuation := code.trim_space().ends_with(',') || code.trim_space().ends_with('\\')
		for last_index + 1 < end_index && (balance > 0 || continuation) {
			last_index++
			next_code_end := ast_code_end(lines[last_index].text)
			next_code := lines[last_index].text[..next_code_end].trim_right(' \t')
			balance += ast_bracket_delta(next_code)
			continuation = next_code.trim_space().ends_with(',') || next_code.trim_space().ends_with('\\')
		}
		last := lines[last_index]
		last_code_end := ast_code_end(last.text)
		end := last.start + last.text[..last_code_end].trim_right(' \t').len
		name_offset := code_trimmed.index(name) or { 0 }
		argument_start := start + name_offset + name.len
		arguments, pairs := ast_arguments(source, argument_start, end)
		nodes << AstNode{
			kind: kind
			name: name
			source: source[start..end]
			source_range: AstRange{ begin_pos: start, end_pos: end, column: indent }
			body_range: AstRange{ begin_pos: end, end_pos: end, column: indent }
			arguments: arguments
			hash_pairs: pairs
			has_receiver: has_receiver
		}
		index = last_index + 1
	}
	return nodes
}

pub fn ast_process_source(source string) (ruby.Value, AstNode) {
	lines := ast_lines(source)
	root_indent := ast_direct_indent(lines, 0, lines.len, -1)
	children := ast_parse_scope(source, lines, 0, lines.len, root_indent)
	if children.len == 0 {
		panic('Unable to parse Ruby source')
	}
	root := if children.len == 1 {
		children[0]
	} else {
		AstNode{
			kind: 'begin'
			name: 'begin'
			source: source
			source_range: AstRange{ begin_pos: 0, end_pos: source.len, column: 0 }
			body_range: AstRange{ begin_pos: 0, end_pos: source.len, column: 0 }
			children: children
		}
	}
	processed := ruby.structured_value('RuboCop::AST::ProcessedSource', source, {
		'source': source
	})
	return processed, root
}

fn ast_range_value(source_range AstRange, source string) ruby.Value {
	return ruby.structured_value('Parser::Source::Range', source, {
		'begin_pos': source_range.begin_pos.str()
		'end_pos':   source_range.end_pos.str()
		'column':    source_range.column.str()
	})
}

fn ast_range_from_value(value ruby.Value) AstRange {
	return AstRange{
		begin_pos: (value.attributes['begin_pos'] or { '0' }).int()
		end_pos: (value.attributes['end_pos'] or { value.repr.len.str() }).int()
		column: (value.attributes['column'] or { '0' }).int()
	}
}

pub fn ast_node_value(node AstNode) ruby.Value {
	mut pairs := map[string]ruby.Value{}
	for pair in node.hash_pairs {
		pairs[pair.key] = pair.value
	}
	argument_nodes := node.arguments.map(ruby.Value{
		type_name: 'Utils::AST::Argument'
		repr: it.value.repr
		map_data: {
			'value': it.value
			'range': ast_range_value(it.source_range, it.value.repr)
		}
		attributes: {
			'begin_pos': it.source_range.begin_pos.str()
			'end_pos':   it.source_range.end_pos.str()
			'column':    it.source_range.column.str()
		}
	})
	hash_pair_nodes := node.hash_pairs.map(ruby.Value{
		type_name: 'Utils::AST::HashPair'
		repr: '${it.key}: ${it.value.repr}'
		map_data: {
			'key':         ruby.string_value(it.key)
			'value':       it.value
			'key_range':   ast_range_value(it.key_range, it.key)
			'value_range': ast_range_value(it.value_range, it.value.repr)
		}
		attributes: {
			'key':         it.key
			'key_begin':   it.key_range.begin_pos.str()
			'key_end':     it.key_range.end_pos.str()
			'value_begin': it.value_range.begin_pos.str()
			'value_end':   it.value_range.end_pos.str()
		}
	})
	return ruby.Value{
		type_name: match node.kind {
			'method_call' { 'RuboCop::AST::SendNode' }
			'block_call' { 'RuboCop::AST::BlockNode' }
			'method_definition' { 'RuboCop::AST::DefNode' }
			else { 'RuboCop::AST::Node' }
		}
		repr: node.source
		array_data: node.children.map(ast_node_value(it))
		map_data: {
			'arguments':       ruby.array_value(argument_nodes)
			'hash_pairs':      ruby.map_value(pairs)
			'hash_pair_nodes': ruby.array_value(hash_pair_nodes)
			'range':           ast_range_value(node.source_range, node.source)
			'body':            ruby.array_value(node.children.map(ast_node_value(it)))
		}
		attributes: {
			'kind':         node.kind
			'name':         node.name
			'begin_pos':    node.source_range.begin_pos.str()
			'end_pos':      node.source_range.end_pos.str()
			'column':       node.source_range.column.str()
			'body_begin':   node.body_range.begin_pos.str()
			'body_end':     node.body_range.end_pos.str()
			'has_receiver': node.has_receiver.str()
		}
	}
}

fn ast_node_from_value(value ruby.Value) AstNode {
	arguments_value := value.map_data['arguments'] or { ruby.array_value([]) }
	argument_values := arguments_value.as_array() or { [] }
	mut arguments := []AstArgument{}
	for argument_value in argument_values {
		if argument_value.type_name == 'Utils::AST::Argument' {
			arguments << AstArgument{
				value: argument_value.map_data['value'] or { argument_value }
				source_range: AstRange{
					begin_pos: (argument_value.attributes['begin_pos'] or { '0' }).int()
					end_pos: (argument_value.attributes['end_pos'] or { '0' }).int()
					column: (argument_value.attributes['column'] or { '0' }).int()
				}
			}
		} else {
			arguments << AstArgument{ value: argument_value }
		}
	}
	hash_pair_values := (value.map_data['hash_pair_nodes'] or { ruby.array_value([]) }).as_array() or {
		[]
	}
	mut hash_pairs := []AstHashPair{}
	for pair_value in hash_pair_values {
		hash_pairs << AstHashPair{
			key: pair_value.attributes['key'] or { '' }
			key_range: AstRange{
				begin_pos: (pair_value.attributes['key_begin'] or { '0' }).int()
				end_pos: (pair_value.attributes['key_end'] or { '0' }).int()
			}
			value: pair_value.map_data['value'] or { ast_nil() }
			value_range: AstRange{
				begin_pos: (pair_value.attributes['value_begin'] or { '0' }).int()
				end_pos: (pair_value.attributes['value_end'] or { '0' }).int()
			}
		}
	}
	begin_pos := (value.attributes['begin_pos'] or { '0' }).int()
	end_pos := (value.attributes['end_pos'] or { value.repr.len.str() }).int()
	column := (value.attributes['column'] or { '0' }).int()
	return AstNode{
		kind: value.attributes['kind'] or { 'method_call' }
		name: value.attributes['name'] or { '' }
		source: value.repr
		source_range: AstRange{ begin_pos: begin_pos, end_pos: end_pos, column: column }
		body_range: AstRange{
			begin_pos: (value.attributes['body_begin'] or { end_pos.str() }).int()
			end_pos: (value.attributes['body_end'] or { end_pos.str() }).int()
			column: column + 2
		}
		arguments: arguments
		hash_pairs: hash_pairs
		children: value.array_data.map(ast_node_from_value(it))
		has_receiver: (value.attributes['has_receiver'] or { 'false' }).bool()
	}
}

pub fn ast_body_children(node ?AstNode) []AstNode {
	value := node or { return [] }
	return if value.kind == 'begin' { value.children.clone() } else { [value] }
}

pub fn ast_ruby_literal(value ruby.Value) string {
	return match value.type_name {
		'String' {
			'"${value.as_string().replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')}"'
		}
		'Symbol' {
			if value.repr.starts_with(':') { value.repr } else { ':${value.repr}' }
		}
		'Integer', 'Float' { value.repr }
		else { value.repr }
	}
}

pub fn ast_literal_value(node AstNode) ruby.Value {
	if node.arguments.len == 0 {
		return ast_nil()
	}
	return node.arguments[0].value
}

pub fn ast_stanza_text(name string, value ruby.Value, indent ?int) string {
	mut text := ''
	if value.type_name == 'String' {
		candidate := value.as_string()
		trimmed := candidate.trim_space()
		if trimmed != '' {
			candidate_name, _ := ast_name_from_line(trimmed)
			if candidate_name == name && (trimmed.contains('\n') || trimmed.starts_with('${name} ') || trimmed.starts_with('${name}\t') || trimmed.starts_with('${name} do')) {
				text = candidate
			}
		}
	}
	if text == '' {
		text = '${name} ${ast_ruby_literal(value)}'
	}
	if indentation := indent {
		mut first_non_newline := 0
		for first_non_newline < text.len && text[first_non_newline] == `\n` {
			first_non_newline++
		}
		if first_non_newline >= text.len || text[first_non_newline] != ` ` {
			prefix := ' '.repeat(indentation)
			text = text.split('\n').map(if it == '' { '' } else { '${prefix}${it}' }).join('\n')
		}
	}
	return text
}

pub fn ast_component_match(component_name string, component_type string, target_name string,
	target_type ?string) bool {
	if component_name != target_name {
		return false
	}
	wanted := target_type or { return true }
	return component_type == wanted
}

pub fn ast_call_node_match(node AstNode, name string, node_type ?string) bool {
	if node.kind != 'method_call' && node.kind != 'block_call' {
		return false
	}
	return ast_component_match(node.name, node.kind, name, node_type)
}

fn ast_formula_value(formula &FormulaAst) ruby.Value {
	return ruby.structured_value('Utils::AST::FormulaAST', formula.contents, {
		'formula_ast_address': u64(voidptr(formula)).str()
	})
}

fn ast_formula_from_value(value ruby.Value) &FormulaAst {
	address := value.attributes['formula_ast_address'] or { panic('invalid FormulaAST receiver') }
	mut formula := unsafe { &FormulaAst(voidptr(address.u64())) }
	if !formula.contents.contains('class ') && value.repr.contains('class ') {
		formula.contents = value.repr
	}
	return formula
}

fn ast_cask_value(cask &CaskAst) ruby.Value {
	return ruby.structured_value('Utils::AST::CaskAST', cask.contents, {
		'cask_ast_address': u64(voidptr(cask)).str()
	})
}

fn ast_cask_from_value(value ruby.Value) &CaskAst {
	address := value.attributes['cask_ast_address'] or { panic('invalid CaskAST receiver') }
	mut cask := unsafe { &CaskAst(voidptr(address.u64())) }
	if !cask.contents.contains('cask ') && value.repr.contains('cask ') {
		cask.contents = value.repr
	}
	return cask
}

fn ast_replace_range(source string, source_range AstRange, replacement string) string {
	if source_range.begin_pos < 0 || source_range.end_pos < source_range.begin_pos || source_range.end_pos > source.len {
		panic('invalid AST source range')
	}
	return source[..source_range.begin_pos] + replacement + source[source_range.end_pos..]
}

fn ast_formula_class(formula FormulaAst) AstNode {
	_, root := ast_process_source(formula.contents)
	mut classes := if root.kind == 'begin' {
		root.children.filter(it.kind == 'class')
	} else if root.kind == 'class' {
		[root]
	} else {
		[]AstNode{}
	}
	if classes.len == 0 {
		panic('Could not find formula class!')
	}
	if classes.len > 1 {
		for class_node in classes {
			header := class_node.source.all_before('\n')
			if header.contains('< Formula') {
				return class_node
			}
		}
	}
	return classes[0]
}

pub fn ast_formula_children(formula FormulaAst) []AstNode {
	children := ast_formula_class(formula).children
	if children.len == 0 {
		panic('Formula class is empty!')
	}
	return children
}

fn ast_matching_stanzas(nodes []AstNode, name string, node_type ?string) []AstNode {
	return nodes.filter(ast_call_node_match(it, name, node_type))
}

pub fn ast_formula_stanzas(formula FormulaAst, name string, node_type ?string) []AstNode {
	return ast_matching_stanzas(ast_formula_children(formula), name, node_type)
}

pub fn ast_formula_stanza(formula FormulaAst, name string, node_type ?string) ?AstNode {
	nodes := ast_formula_stanzas(formula, name, node_type)
	return if nodes.len == 0 { none } else { nodes[0] }
}

pub fn ast_formula_stable_children(formula FormulaAst) []AstNode {
	if stable := ast_formula_stanza(formula, 'stable', 'block_call') {
		return stable.children
	}
	return ast_formula_children(formula)
}

fn ast_first_string(node AstNode) string {
	if node.arguments.len == 0 || node.arguments[0].value.type_name != 'String' {
		return ''
	}
	return node.arguments[0].value.as_string()
}

pub fn ast_formula_resource(formula FormulaAst, name string) AstNode {
	mut possible := []AstNode{}
	if _ := ast_formula_stanza(formula, 'stable', 'block_call') {
		possible << ast_formula_stable_children(formula)
	}
	possible << ast_formula_children(formula)
	for node in ast_matching_stanzas(possible, 'resource', 'block_call') {
		if ast_first_string(node) == name {
			return node
		}
	}
	panic("Could not find resource '${name}' block!")
}

fn ast_formula_stable_stanza(formula FormulaAst, name string) AstNode {
	nodes := ast_matching_stanzas(ast_formula_stable_children(formula), name, none)
	if nodes.len == 0 {
		panic("Could not find '${name}' stanza!")
	}
	return nodes[0]
}

fn ast_formula_resource_stanza(formula FormulaAst, resource_name string, name string,
	old_value ?ruby.Value) AstNode {
	resource := ast_formula_resource(formula, resource_name)
	for node in ast_matching_stanzas(resource.children, name, none) {
		if old := old_value {
			if ast_value_equal(ast_literal_value(node), old) {
				return node
			}
		} else {
			return node
		}
	}
	panic("Could not find '${name}' stanza in resource '${resource_name}'!")
}

fn ast_value_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name != right.type_name {
		return false
	}
	return match left.type_name {
		'Bool' { left.bool_data == right.bool_data }
		'Integer' { left.int_data == right.int_data }
		'Float' { left.float_data == right.float_data }
		else { left.repr == right.repr }
	}
}

fn ast_formula_replace_argument(mut formula FormulaAst, node AstNode, value ruby.Value) {
	if node.arguments.len == 0 {
		panic("Could not find '${node.name}' stanza value!")
	}
	formula.contents = ast_replace_range(formula.contents, node.arguments[0].source_range, ast_ruby_literal(value))
}

fn ast_formula_replace_hash(mut formula FormulaAst, node AstNode, key string,
	value ruby.Value) {
	for pair in node.hash_pairs {
		if pair.key == key {
			formula.contents = ast_replace_range(formula.contents, pair.value_range, ast_ruby_literal(value))
			return
		}
	}
	panic("Could not find '${key}' value in '${node.name}' stanza!")
}

fn ast_line_start(source string, position int) int {
	if position <= 0 {
		return 0
	}
	previous := source[..position].last_index('\n') or { return 0 }
	return previous + 1
}

fn ast_line_end(source string, position int) int {
	newline := source.index_after('\n', position) or { return source.len }
	return newline + 1
}

fn ast_whole_line_range(source string, source_range AstRange,
	include_following_blank_lines bool) AstRange {
	mut end := ast_line_end(source, source_range.end_pos)
	if include_following_blank_lines {
		for end < source.len {
			next_end := ast_line_end(source, end)
			if source[end..next_end].trim_space() != '' {
				break
			}
			end = next_end
		}
	}
	begin := ast_line_start(source, source_range.begin_pos)
	return AstRange{ begin_pos: begin, end_pos: end, column: 0 }
}

fn ast_source_range_with_trailing_comments(source string, node AstNode) AstRange {
	mut result := node.source_range
	lines := ast_lines(source)
	mut node_last_line := 0
	for index, line in lines {
		if result.end_pos >= line.start && result.end_pos <= line.newline_end {
			node_last_line = index
			break
		}
	}
	for index, line in lines {
		comment_index := ast_code_end(line.text)
		if comment_index >= line.text.len {
			continue
		}
		comment_start := line.start + comment_index
		comment_range := AstRange{ begin_pos: comment_start, end_pos: line.end, column: comment_index }
		distance := index - node_last_line
		if distance == 0 && comment_range.end_pos > result.end_pos {
			result = comment_range
		} else if distance == 1 {
			result = comment_range
			node_last_line = index
		}
	}
	return result
}

fn ast_source_range_with_leading_resource_comments(source string, source_range AstRange) AstRange {
	mut result := source_range
	lines := ast_lines(source)
	for {
		line_start := ast_line_start(source, result.begin_pos)
		mut chosen := ?AstRange(none)
		for line in lines {
			trimmed := line.text.trim_space()
			if line.end <= line_start && trimmed.starts_with('# RESOURCE-ERROR:') {
				candidate := AstRange{ begin_pos: line.start + line.indent, end_pos: line.end, column: line.indent }
				if previous := chosen {
					if candidate.end_pos > previous.end_pos {
						chosen = candidate
					}
				} else {
					chosen = candidate
				}
			}
		}
		comment := chosen or { break }
		if source[comment.end_pos..line_start].split('\n').all(it.trim_space() == '') {
			result = AstRange{ begin_pos: comment.begin_pos, end_pos: result.end_pos, column: comment.column }
		} else {
			break
		}
	}
	return result
}

fn ast_formula_remove_node(mut formula FormulaAst, node AstNode) {
	mut source_range := node.source_range
	if source_range.end_pos < formula.contents.len && formula.contents[source_range.end_pos..source_range.end_pos + 1].trim_right('\r\n') == '' {
		source_range = AstRange{
			begin_pos: source_range.begin_pos
			end_pos: source_range.end_pos + 1
			column: source_range.column
		}
		line_start := ast_line_start(formula.contents, source_range.begin_pos)
		if formula.contents[line_start..source_range.begin_pos].trim_space() == '' {
			source_range = AstRange{ begin_pos: line_start, end_pos: source_range.end_pos, column: 0 }
			if line_start >= 2 && formula.contents[line_start - 2..line_start] == '\n\n' {
				source_range = AstRange{ begin_pos: line_start - 1, end_pos: source_range.end_pos, column: 0 }
			}
		}
	}
	formula.contents = ast_replace_range(formula.contents, source_range, '')
}

fn ast_formula_precedence() [][]string {
	return [
		['method_call:include'],
		['method_call:desc'],
		['method_call:homepage'],
		['method_call:url'],
		['method_call:mirror'],
		['method_call:version'],
		['method_call:sha256'],
		['method_call:license'],
		['method_call:revision'],
		['method_call:version_scheme'],
		['method_call:compatibility_version'],
		['method_call:head'],
		['block_call:stable'],
		['block_call:livecheck'],
		['method_call:no_autobump!'],
		['block_call:bottle'],
		['block_call:pour_bottle?'],
		['block_call:head'],
		['method_call:bottle'],
		['method_call:keg_only'],
		['method_call:option'],
		['method_call:deprecated_option'],
		['method_call:deprecate!'],
		['method_call:disable!'],
		['method_call:depends_on'],
		['method_call:uses_from_macos'],
		['block_call:on_macos'],
		['block_call:on_system'],
		['block_call:on_linux'],
		['block_call:on_arm'],
		['block_call:on_intel'],
		['method_call:conflicts_with'],
		['method_call:preserve_rpath'],
		['method_call:skip_clean'],
		['method_call:cxxstdlib_check'],
		['method_call:link_overwrite'],
		['method_call:fails_with', 'block_call:fails_with'],
		['method_call:pypi_packages'],
		['block_call:resource'],
		['method_call:patch', 'block_call:patch'],
		['method_call:needs'],
		['method_call:allow_network_access!'],
		['method_call:deny_network_access!'],
		['method_definition:install'],
		['block_call:post_install_steps'],
		['method_definition:post_install'],
		['method_definition:caveats'],
		['method_call:plist_options', 'method_definition:plist'],
		['block_call:test'],
	]
}

fn ast_formula_component_before_target(node AstNode, target_name string,
	target_type ?string) bool {
	for components in ast_formula_precedence() {
		for component in components {
			parts := component.split(':')
			if ast_component_match(parts[1], parts[0], target_name, target_type) {
				return false
			}
		}
		for component in components {
			parts := component.split(':')
			if ast_call_node_match(node, parts[1], parts[0]) || (node.kind == parts[0] && node.name == parts[1]) {
				return true
			}
		}
	}
	return false
}

pub fn ast_formula_replace_stable_value(mut formula FormulaAst, name string,
	value ruby.Value) {
	node := ast_formula_stable_stanza(formula, name)
	ast_formula_replace_argument(mut formula, node, value)
}

pub fn ast_formula_replace_stable_hash(mut formula FormulaAst, name string, key string,
	value ruby.Value) {
	node := ast_formula_stable_stanza(formula, name)
	ast_formula_replace_hash(mut formula, node, key, value)
}

pub fn ast_formula_remove_stable(mut formula FormulaAst, name string, all bool) {
	nodes := ast_matching_stanzas(ast_formula_stable_children(formula), name, none)
	if nodes.len == 0 {
		panic("Could not find '${name}' stanza!")
	}
	to_remove := if all { nodes } else { [nodes[0]] }
	mut ranges := to_remove.map(it.source_range)
	ranges.sort_with_compare(fn (left &AstRange, right &AstRange) int {
		return right.begin_pos - left.begin_pos
	})
	for source_range in ranges {
		node := AstNode{ source_range: source_range }
		ast_formula_remove_node(mut formula, node)
	}
}

fn ast_stanza_pairs(value ruby.Value) []AstStanzaPair {
	mut result := []AstStanzaPair{}
	for item in value.as_array() or { return result } {
		parts := item.as_array() or { continue }
		if parts.len >= 2 {
			result << AstStanzaPair{
				name: parts[0].as_string()
				value: parts[1]
			}
		}
	}
	return result
}

pub fn ast_formula_add_stanzas_after(mut formula FormulaAst, after_name string,
	new_stanzas []AstStanzaPair, parent ?AstNode) {
	if new_stanzas.len == 0 {
		return
	}
	nodes := if parent_node := parent {
		ast_matching_stanzas(parent_node.children, after_name, none)
	} else {
		ast_formula_stanzas(formula, after_name, none)
	}
	if nodes.len == 0 {
		panic("Could not find '${after_name}' stanza!")
	}
	preceding := nodes.last()
	preceding_range := ast_source_range_with_trailing_comments(formula.contents, preceding)
	mut text := ''
	for stanza in new_stanzas {
		text += '\n${ast_stanza_text(stanza.name, stanza.value, preceding.source_range.column)}'
	}
	formula.contents = ast_replace_range(formula.contents, AstRange{
		begin_pos: preceding_range.end_pos
		end_pos: preceding_range.end_pos
	}, text)
}

pub fn ast_formula_replace_resource_value(mut formula FormulaAst, resource_name string,
	name string, value ruby.Value, old_value ?ruby.Value) {
	node := ast_formula_resource_stanza(formula, resource_name, name, old_value)
	ast_formula_replace_argument(mut formula, node, value)
}

pub fn ast_formula_resource_stanza_exists(formula FormulaAst, resource_name string,
	name string) bool {
	resource := ast_formula_resource(formula, resource_name)
	return ast_matching_stanzas(resource.children, name, none).len > 0
}

fn ast_formula_method(formula FormulaAst, name string) ?AstNode {
	for node in ast_formula_children(formula) {
		if node.kind == 'method_definition' && node.name == name {
			return node
		}
	}
	return none
}

fn ast_formula_resource_groups(formula FormulaAst, preserve_livecheck bool) [][]AstNode {
	test_position := if test := ast_formula_stanza(formula, 'test', 'block_call') {
		test.source_range.begin_pos
	} else {
		formula.contents.len + 1
	}
	mut resources := []AstNode{}
	for node in ast_formula_stanzas(formula, 'resource', 'block_call') {
		if node.source_range.begin_pos > test_position {
			continue
		}
		if preserve_livecheck && ast_matching_stanzas(node.children, 'livecheck', 'block_call').len > 0 {
			continue
		}
		resources << node
	}
	mut groups := [][]AstNode{}
	for resource in resources {
		if groups.len == 0 || !ast_formula_resources_contiguous(formula, groups.last().last(), resource) {
			groups << [resource]
		} else {
			groups[groups.len - 1] << resource
		}
	}
	return groups
}

fn ast_formula_resources_contiguous(formula FormulaAst, previous AstNode, current AstNode) bool {
	previous_end := ast_whole_line_range(formula.contents, previous.source_range, false).end_pos
	current_start := ast_line_start(formula.contents, current.source_range.begin_pos)
	return formula.contents[previous_end..current_start].split('\n').all(it.trim_space() == '' || it.trim_space().starts_with('# RESOURCE-ERROR:'))
}

fn ast_formula_resource_group_range(formula FormulaAst, group []AstNode) AstRange {
	if group.len == 0 {
		panic('resource stanza group is empty')
	}
	first := ast_source_range_with_leading_resource_comments(formula.contents, group[0].source_range)
	last := ast_whole_line_range(formula.contents, group.last().source_range, true)
	return AstRange{
		begin_pos: ast_line_start(formula.contents, first.begin_pos)
		end_pos: last.end_pos
		column: 0
	}
}

pub fn ast_formula_replace_resources(mut formula FormulaAst, resource_section string,
	replace_existing bool, preserve_livecheck bool) ?string {
	mut section := resource_section
	mut first_non_newline := 0
	for first_non_newline < section.len && section[first_non_newline] == `\n` {
		first_non_newline++
	}
	if first_non_newline >= section.len || section[first_non_newline] != ` ` {
		section = section.split('\n').map(if it == '' { '' } else { '  ${it}' }).join('\n')
	}
	if replace_existing {
		groups := ast_formula_resource_groups(formula, preserve_livecheck)
		if groups.len > 1 {
			return 'multiple_groups'
		}
		if groups.len == 1 {
			formula.contents = ast_replace_range(formula.contents, ast_formula_resource_group_range(formula, groups[0]), section)
			return none
		}
	}
	install := ast_formula_method(formula, 'install') or { panic("Could not find 'install' method!") }
	range := ast_whole_line_range(formula.contents, install.source_range, false)
	formula.contents = ast_replace_range(formula.contents, AstRange{
		begin_pos: range.begin_pos
		end_pos: range.begin_pos
	}, section)
	return none
}

pub fn ast_formula_remove_stanza(mut formula FormulaAst, name string, node_type ?string) {
	node := ast_formula_stanza(formula, name, node_type) or { panic("Could not find '${name}' stanza!") }
	ast_formula_remove_node(mut formula, node)
}

pub fn ast_formula_replace_stanza(mut formula FormulaAst, name string,
	replacement ruby.Value, node_type ?string) {
	node := ast_formula_stanza(formula, name, node_type) or { panic("Could not find '${name}' stanza!") }
	text := ast_stanza_text(name, replacement, 2).trim_left(' \t')
	formula.contents = ast_replace_range(formula.contents, node.source_range, text)
}

pub fn ast_formula_add_stanza(mut formula FormulaAst, name string, value ruby.Value,
	node_type ?string) {
	children := ast_formula_children(formula)
	mut preceding := children[0]
	if children.len > 1 {
		for current in children[1..] {
			if ast_formula_component_before_target(current, name, node_type) {
				preceding = current
			} else {
				break
			}
		}
	}
	preceding_range := ast_source_range_with_trailing_comments(formula.contents, preceding)
	text := '\n${ast_stanza_text(name, value, 2)}'
	formula.contents = ast_replace_range(formula.contents, AstRange{
		begin_pos: preceding_range.end_pos
		end_pos: preceding_range.end_pos
	}, text)
}

pub fn ast_formula_replace_bottle(mut formula FormulaAst, bottle_output string) {
	ast_formula_replace_stanza(mut formula, 'bottle', ruby.string_value(bottle_output.trim_right('\n')), 'block_call')
}

pub fn ast_formula_add_bottle(mut formula FormulaAst, bottle_output string) {
	ast_formula_add_stanza(mut formula, 'bottle', ruby.string_value('\n${bottle_output.trim_right('\n')}'), 'block_call')
}

fn ast_cask_block(cask CaskAst) AstNode {
	_, root := ast_process_source(cask.contents)
	if root.kind == 'block_call' && root.name == 'cask' {
		return root
	}
	if root.kind == 'begin' {
		for node in root.children {
			if node.kind == 'block_call' && node.name == 'cask' {
				return node
			}
		}
	}
	panic('Could not find cask block!')
}

fn ast_recursive_nodes(nodes []AstNode, kind string) []AstNode {
	mut result := []AstNode{}
	for node in nodes {
		if node.kind == kind {
			result << node
		}
		result << ast_recursive_nodes(node.children, kind)
	}
	return result
}

pub fn ast_cask_on_system_blocks(cask CaskAst, name string) []AstNode {
	return ast_cask_block(cask).children.filter(it.kind == 'block_call' && it.name == name && !it.has_receiver)
}

pub fn ast_cask_top_level_stanzas(cask CaskAst, name string) []AstNode {
	return ast_cask_block(cask).children.filter(it.kind == 'method_call' && it.name == name && !it.has_receiver && (it.arguments.len > 0 || it.hash_pairs.len > 0))
}

pub fn ast_cask_stanzas(cask CaskAst, name string, within ?string) []AstNode {
	mut nodes := []AstNode{}
	if scope := within {
		if scope == 'root' {
			nodes = ast_cask_block(cask).children.filter(it.kind == 'method_call')
		} else {
			blocks := ast_cask_on_system_blocks(cask, scope)
			for block in blocks {
				nodes << block.children.filter(it.kind == 'method_call')
			}
		}
	} else {
		nodes = ast_recursive_nodes(ast_cask_block(cask).children, 'method_call')
	}
	return nodes.filter(it.name == name && !it.has_receiver && (it.arguments.len > 0 || it.hash_pairs.len > 0))
}

pub fn ast_cask_stanza_anywhere(cask CaskAst, name string, within string) bool {
	for block in ast_recursive_nodes(ast_cask_block(cask).children, 'block_call') {
		if block.name != within || block.has_receiver {
			continue
		}
		if ast_recursive_nodes(block.children, 'method_call').any(it.name == name && !it.has_receiver && it.arguments.len > 0) {
			return true
		}
	}
	return false
}

fn ast_cask_replace_argument(mut cask CaskAst, node AstNode, value ruby.Value) {
	if node.arguments.len == 0 {
		panic("Could not find '${node.name}' stanza value!")
	}
	cask.contents = ast_replace_range(cask.contents, node.arguments[0].source_range, ast_ruby_literal(value))
}

pub fn ast_cask_replace_first(mut cask CaskAst, name string, value ruby.Value) {
	nodes := ast_cask_stanzas(cask, name, none)
	if nodes.len == 0 {
		panic("Could not find '${name}' stanza!")
	}
	ast_cask_replace_argument(mut cask, nodes[0], value)
}

pub fn ast_cask_first_value(cask CaskAst, name string, within ?string) ruby.Value {
	nodes := ast_cask_stanzas(cask, name, within)
	if nodes.len == 0 || nodes[0].arguments.len == 0 {
		return ast_nil()
	}
	return nodes[0].arguments[0].value
}

pub fn ast_cask_replace_value(mut cask CaskAst, name string, old_value ruby.Value,
	new_value ruby.Value, within ?string) int {
	mut count := 0
	// Reparse after each edit so all byte ranges continue to refer to the current source.
	for {
		mut replacement := ?AstRange(none)
		for node in ast_cask_stanzas(cask, name, within) {
			if node.arguments.len > 0 && ast_value_equal(node.arguments[0].value, old_value) {
				replacement = node.arguments[0].source_range
				break
			}
			for pair in node.hash_pairs {
				if ast_value_equal(pair.value, old_value) {
					replacement = pair.value_range
					break
				}
			}
			if replacement != none {
				break
			}
		}
		range := replacement or { break }
		cask.contents = ast_replace_range(cask.contents, range, ast_ruby_literal(new_value))
		count++
	}
	return count
}

pub fn ast_cask_replace_root_with_arch(mut cask CaskAst, name string,
	old_value ruby.Value) {
	for node in ast_cask_top_level_stanzas(cask, name) {
		if !ast_value_equal(ast_literal_value(node), old_value) {
			continue
		}
		indent := ' '.repeat(node.source_range.column)
		literal := ast_ruby_literal(old_value)
		replacement := '${indent}on_arm do\n${indent}  ${name} ${literal}\n${indent}end\n${indent}on_intel do\n${indent}  ${name} ${literal}\n${indent}end\n'
		range := ast_whole_line_range(cask.contents, node.source_range, false)
		cask.contents = ast_replace_range(cask.contents, range, replacement)
		return
	}
}

pub fn ast_cask_depends_on_macos(cask CaskAst) bool {
	for node in ast_cask_stanzas(cask, 'depends_on', none) {
		if node.arguments.any(it.value.type_name == 'Symbol' && it.value.repr == ':macos') || node.hash_pairs.any(it.key == 'macos') {
			return true
		}
	}
	return false
}
