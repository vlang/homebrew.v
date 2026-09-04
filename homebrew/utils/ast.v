module utils

import ruby

// Translated from Homebrew/brew `utils/ast.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `body_children(body_node)` at line 20.
pub fn ruby_ast_l20_d1_body_children(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	node := ast_node_from_value(args[0])
	return ruby.array_value(ast_body_children(node).map(ast_node_value(it)))
}

// Ruby method `stanza_text(name, value, indent: nil)` at line 31.
pub fn ruby_ast_l31_d2_stanza_text(args ...ruby.Value) ruby.Value {
	indent := if args.len > 2 && args[2].type_name != 'NilClass' {
		?int(int(args[2].as_int() or { 0 }))
	} else {
		?int(none)
	}
	return ruby.string_value(ast_stanza_text(args[0].as_string(), args[1], indent))
}

// Ruby method `ruby_literal(value)` at line 42.
pub fn ruby_ast_l42_d3_ruby_literal(args ...ruby.Value) ruby.Value {
	return ruby.string_value(ast_ruby_literal(args[0]))
}

// Ruby method `literal_value(node)` at line 47.
pub fn ruby_ast_l47_d4_literal_value(args ...ruby.Value) ruby.Value {
	return ast_literal_value(ast_node_from_value(args[0]))
}

// Ruby method `process_source(source)` at line 55.
pub fn ruby_ast_l55_d5_process_source(args ...ruby.Value) ruby.Value {
	processed, root := ast_process_source(args[0].as_string())
	return ruby.array_value([processed, ast_node_value(root)])
}

// Ruby method `component_match?(component_name:, component_type:, target_name:, target_type: nil)` at line 70.
pub fn ruby_ast_l70_d6_component_match(args ...ruby.Value) ruby.Value {
	target_type := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	return ruby.bool_value(ast_component_match(args[0].as_string(), args[1].as_string(), args[2].as_string(), target_type))
}

// Ruby method `call_node_match?(node, name:, type: nil)` at line 75.
pub fn ruby_ast_l75_d7_call_node_match(args ...ruby.Value) ruby.Value {
	node_type := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	return ruby.bool_value(ast_call_node_match(ast_node_from_value(args[0]), args[1].as_string(), node_type))
}

// Ruby delegate `delegate process: :tree_rewriter` at line 93.
pub fn ruby_ast_l93_d8_process(args ...ruby.Value) ruby.Value {
	return ruby.string_value(ast_formula_from_value(args[0]).contents)
}

// Ruby method `initialize(formula_contents)` at line 96.
pub fn ruby_ast_l96_d9_initialize(args ...ruby.Value) ruby.Value {
	mut formula := unsafe { &FormulaAst(vcalloc(sizeof(FormulaAst))) }
	formula.contents = args[0].as_string()
	_ = ast_formula_children(formula)
	return ast_formula_value(formula)
}

// Ruby method `bottle_block` at line 105.
pub fn ruby_ast_l105_d10_bottle_block(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	node := ast_formula_stanza(formula, 'bottle', 'block_call') or { return ast_nil() }
	return ast_node_value(node)
}

// Ruby method `stanza(name, type: nil)` at line 110.
pub fn ruby_ast_l110_d11_stanza(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	node_type := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	node := ast_formula_stanza(formula, args[1].as_string(), node_type) or { return ast_nil() }
	return ast_node_value(node)
}

// Ruby method `stanzas(name, type: nil)` at line 115.
pub fn ruby_ast_l115_d12_stanzas(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	node_type := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	return ruby.array_value(ast_formula_stanzas(formula, args[1].as_string(), node_type).map(ast_node_value(it)))
}

// Ruby method `resource(name)` at line 120.
pub fn ruby_ast_l120_d13_resource(args ...ruby.Value) ruby.Value {
	return ast_node_value(ast_formula_resource(ast_formula_from_value(args[0]), args[1].as_string()))
}

// Ruby method `replace_stable_stanza_value(name, value)` at line 137.
pub fn ruby_ast_l137_d14_replace_stable_stanza_value(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_replace_stable_value(mut formula, args[1].as_string(), args[2])
	return ast_nil()
}

// Ruby method `replace_stable_stanza_hash_value(name, key, value)` at line 142.
pub fn ruby_ast_l142_d15_replace_stable_stanza_hash_value(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_replace_stable_hash(mut formula, args[1].as_string(), args[2].as_string(), args[3])
	return ast_nil()
}

// Ruby method `stable_stanza?(name)` at line 147.
pub fn ruby_ast_l147_d16_stable_stanza(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	return ruby.bool_value(ast_matching_stanzas(ast_formula_stable_children(formula), args[1].as_string(), none).len > 0)
}

// Ruby method `remove_stable_stanza(name)` at line 152.
pub fn ruby_ast_l152_d17_remove_stable_stanza(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_remove_stable(mut formula, args[1].as_string(), false)
	return ast_nil()
}

// Ruby method `remove_stable_stanzas(name)` at line 157.
pub fn ruby_ast_l157_d18_remove_stable_stanzas(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_remove_stable(mut formula, args[1].as_string(), true)
	return ast_nil()
}

// Ruby method `add_stable_stanzas_after(after_name, new_stanzas)` at line 170.
pub fn ruby_ast_l170_d19_add_stable_stanzas_after(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	parent := ast_formula_stanza(formula, 'stable', 'block_call')
	ast_formula_add_stanzas_after(mut formula, args[1].as_string(), ast_stanza_pairs(args[2]), parent)
	return ast_nil()
}

// Ruby method `replace_resource_stanza_value(resource_name, name, value, old_value: nil)` at line 182.
pub fn ruby_ast_l182_d20_replace_resource_stanza_value(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	old_value := if args.len > 4 && args[4].type_name != 'NilClass' {
		?ruby.Value(args[4])
	} else {
		?ruby.Value(none)
	}
	ast_formula_replace_resource_value(mut formula, args[1].as_string(), args[2].as_string(), args[3], old_value)
	return ast_nil()
}

// Ruby method `resource_stanza?(resource_name, name)` at line 187.
pub fn ruby_ast_l187_d21_resource_stanza(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(ast_formula_resource_stanza_exists(ast_formula_from_value(args[0]), args[1].as_string(), args[2].as_string()))
}

// Ruby method `add_stanzas_after(after_name, new_stanzas, parent: nil)` at line 198.
pub fn ruby_ast_l198_d22_add_stanzas_after(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	parent := if args.len > 3 && args[3].type_name != 'NilClass' {
		?AstNode(ast_node_from_value(args[3]))
	} else {
		?AstNode(none)
	}
	ast_formula_add_stanzas_after(mut formula, args[1].as_string(), ast_stanza_pairs(args[2]), parent)
	return ast_nil()
}

// Ruby method `replace_resource_stanzas(resource_section, replace_existing: true, preserve_livecheck: false)` at line 222.
pub fn ruby_ast_l222_d23_replace_resource_stanzas(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	replace_existing := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	preserve_livecheck := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	result := ast_formula_replace_resources(mut formula, args[1].as_string(), replace_existing, preserve_livecheck) or { return ast_nil() }
	return ast_symbol(result)
}

// Ruby method `replace_bottle_block(bottle_output)` at line 243.
pub fn ruby_ast_l243_d24_replace_bottle_block(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_replace_bottle(mut formula, args[1].as_string())
	return ast_nil()
}

// Ruby method `add_bottle_block(bottle_output)` at line 248.
pub fn ruby_ast_l248_d25_add_bottle_block(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_add_bottle(mut formula, args[1].as_string())
	return ast_nil()
}

// Ruby method `remove_stanza(name, type: nil)` at line 253.
pub fn ruby_ast_l253_d26_remove_stanza(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	node_type := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	ast_formula_remove_stanza(mut formula, args[1].as_string(), node_type)
	return ast_nil()
}

// Ruby method `replace_stanza(name, replacement, type: nil)` at line 261.
pub fn ruby_ast_l261_d27_replace_stanza(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	node_type := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	ast_formula_replace_stanza(mut formula, args[1].as_string(), args[2], node_type)
	return ast_nil()
}

// Ruby method `add_stanza(name, value, type: nil)` at line 269.
pub fn ruby_ast_l269_d28_add_stanza(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	node_type := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	ast_formula_add_stanza(mut formula, args[1].as_string(), args[2], node_type)
	return ast_nil()
}

// Ruby attr_reader `attr_reader :formula_contents` at line 306.
pub fn ruby_ast_l306_d29_formula_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value(ast_formula_from_value(args[0]).contents)
}

// Ruby attr_reader `attr_reader :processed_source` at line 309.
pub fn ruby_ast_l309_d30_processed_source(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	return ruby.structured_value('RuboCop::AST::ProcessedSource', formula.contents, {
		'source': formula.contents
	})
}

// Ruby attr_reader `attr_reader :children` at line 312.
pub fn ruby_ast_l312_d31_children(args ...ruby.Value) ruby.Value {
	return ruby.array_value(ast_formula_children(ast_formula_from_value(args[0])).map(ast_node_value(it)))
}

// Ruby attr_reader `attr_reader :tree_rewriter` at line 315.
pub fn ruby_ast_l315_d32_tree_rewriter(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	return ruby.structured_value('Parser::Source::TreeRewriter', formula.contents, {
		'formula_ast_address': u64(voidptr(formula)).str()
	})
}

// Ruby method `matching_stanzas(nodes, name, type: nil)` at line 318.
pub fn ruby_ast_l318_d33_matching_stanzas(args ...ruby.Value) ruby.Value {
	nodes := (args[1].as_array() or { [] }).map(ast_node_from_value(it))
	node_type := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	return ruby.array_value(ast_matching_stanzas(nodes, args[2].as_string(), node_type).map(ast_node_value(it)))
}

// Ruby method `stable_stanza(name)` at line 323.
pub fn ruby_ast_l323_d34_stable_stanza(args ...ruby.Value) ruby.Value {
	return ast_node_value(ast_formula_stable_stanza(ast_formula_from_value(args[0]), args[1].as_string()))
}

// Ruby method `resource_stanza(resource_name, name, old_value: nil)` at line 337.
pub fn ruby_ast_l337_d35_resource_stanza(args ...ruby.Value) ruby.Value {
	old_value := if args.len > 3 && args[3].type_name != 'NilClass' {
		?ruby.Value(args[3])
	} else {
		?ruby.Value(none)
	}
	return ast_node_value(ast_formula_resource_stanza(ast_formula_from_value(args[0]), args[1].as_string(), args[2].as_string(), old_value))
}

// Ruby method `stable_children` at line 347.
pub fn ruby_ast_l347_d36_stable_children(args ...ruby.Value) ruby.Value {
	return ruby.array_value(ast_formula_stable_children(ast_formula_from_value(args[0])).map(ast_node_value(it)))
}

// Ruby method `replace_stanza_value(stanza_node, value)` at line 356.
pub fn ruby_ast_l356_d37_replace_stanza_value(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_replace_argument(mut formula, ast_node_from_value(args[1]), args[2])
	return ast_nil()
}

// Ruby method `replace_stanza_hash_value(stanza_node, key, value)` at line 365.
pub fn ruby_ast_l365_d38_replace_stanza_hash_value(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_replace_hash(mut formula, ast_node_from_value(args[1]), args[2].as_string(), args[3])
	return ast_nil()
}

// Ruby method `remove_stanza_node(stanza_node)` at line 376.
pub fn ruby_ast_l376_d39_remove_stanza_node(args ...ruby.Value) ruby.Value {
	mut formula := ast_formula_from_value(args[0])
	ast_formula_remove_node(mut formula, ast_node_from_value(args[1]))
	return ast_nil()
}

// Ruby method `source_range_with_trailing_comments(node)` at line 406.
pub fn ruby_ast_l406_d40_source_range_with_trailing_comments(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	node := ast_node_from_value(args[1])
	source_range := ast_source_range_with_trailing_comments(formula.contents, node)
	return ast_range_value(source_range, formula.contents[source_range.begin_pos..source_range.end_pos])
}

// Ruby method `method_definition(name)` at line 425.
pub fn ruby_ast_l425_d41_method_definition(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	node := ast_formula_method(formula, args[1].as_string()) or { return ast_nil() }
	return ast_node_value(node)
}

// Ruby method `resource_stanza_groups(preserve_livecheck: false)` at line 433.
pub fn ruby_ast_l433_d42_resource_stanza_groups(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	preserve := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	groups := ast_formula_resource_groups(formula, preserve)
	return ruby.array_value(groups.map(ruby.array_value(it.map(ast_node_value(it)))))
}

// Ruby method `resource_stanzas_contiguous?(previous_node, current_node)` at line 458.
pub fn ruby_ast_l458_d43_resource_stanzas_contiguous(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(ast_formula_resources_contiguous(ast_formula_from_value(args[0]), ast_node_from_value(args[1]), ast_node_from_value(args[2])))
}

// Ruby method `resource_stanza_group_range(group)` at line 467.
pub fn ruby_ast_l467_d44_resource_stanza_group_range(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	group := (args[1].as_array() or { [] }).map(ast_node_from_value(it))
	source_range := ast_formula_resource_group_range(formula, group)
	return ast_range_value(source_range, formula.contents[source_range.begin_pos..source_range.end_pos])
}

// Ruby method `source_range_with_leading_resource_error_comments(range)` at line 477.
pub fn ruby_ast_l477_d45_source_range_with_leading_resource_error_comments(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	source_range := ast_source_range_with_leading_resource_comments(formula.contents, ast_range_from_value(args[1]))
	return ast_range_value(source_range, formula.contents[source_range.begin_pos..source_range.end_pos])
}

// Ruby method `whole_line_range(range, include_following_blank_lines: false)` at line 503.
pub fn ruby_ast_l503_d46_whole_line_range(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	include_blanks := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	source_range := ast_whole_line_range(formula.contents, ast_range_from_value(args[1]), include_blanks)
	return ast_range_value(source_range, formula.contents[source_range.begin_pos..source_range.end_pos])
}

// Ruby method `line_end_pos(position)` at line 518.
pub fn ruby_ast_l518_d47_line_end_pos(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	return ruby.int_value(ast_line_end(formula.contents, int(args[1].as_int() or { 0 })))
}

// Ruby method `process_formula` at line 524.
pub fn ruby_ast_l524_d48_process_formula(args ...ruby.Value) ruby.Value {
	formula := ast_formula_from_value(args[0])
	processed := ruby.structured_value('RuboCop::AST::ProcessedSource', formula.contents, {
		'source': formula.contents
	})
	return ruby.array_value([processed,
		ruby.array_value(ast_formula_children(formula).map(ast_node_value(it)))])
}

// Ruby method `formula_component_before_target?(node, target_name:, target_type: nil)` at line 546.
pub fn ruby_ast_l546_d49_formula_component_before_target(args ...ruby.Value) ruby.Value {
	target_type := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	return ruby.bool_value(ast_formula_component_before_target(ast_node_from_value(args[1]), args[2].as_string(), target_type))
}

// Ruby method `initialize(cask_contents)` at line 568.
pub fn ruby_ast_l568_d50_initialize(args ...ruby.Value) ruby.Value {
	mut cask := unsafe { &CaskAst(vcalloc(sizeof(CaskAst))) }
	cask.contents = args[0].as_string()
	_ = ast_cask_block(cask)
	return ast_cask_value(cask)
}

// Ruby method `process` at line 577.
pub fn ruby_ast_l577_d51_process(args ...ruby.Value) ruby.Value {
	return ruby.string_value(ast_cask_from_value(args[0]).contents)
}

// Ruby method `replace_first_stanza_value(name, value)` at line 582.
pub fn ruby_ast_l582_d52_replace_first_stanza_value(args ...ruby.Value) ruby.Value {
	mut cask := ast_cask_from_value(args[0])
	ast_cask_replace_first(mut cask, args[1].as_string(), args[2])
	return ast_nil()
}

// Ruby method `stanza?(name, within: nil)` at line 590.
pub fn ruby_ast_l590_d53_stanza(args ...ruby.Value) ruby.Value {
	within := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	return ruby.bool_value(ast_cask_stanzas(ast_cask_from_value(args[0]), args[1].as_string(), within).len > 0)
}

// Ruby method `stanza_anywhere?(name, within:)` at line 595.
pub fn ruby_ast_l595_d54_stanza_anywhere(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(ast_cask_stanza_anywhere(ast_cask_from_value(args[0]), args[1].as_string(), args[2].as_string()))
}

// Ruby method `first_stanza_value(name, within: nil)` at line 607.
pub fn ruby_ast_l607_d55_first_stanza_value(args ...ruby.Value) ruby.Value {
	within := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	return ast_cask_first_value(ast_cask_from_value(args[0]), args[1].as_string(), within)
}

// Ruby method `replace_stanza_value(name, old_value, new_value, within: nil)` at line 622.
pub fn ruby_ast_l622_d56_replace_stanza_value(args ...ruby.Value) ruby.Value {
	mut cask := ast_cask_from_value(args[0])
	within := if args.len > 4 && args[4].type_name != 'NilClass' {
		?string(args[4].as_string())
	} else {
		?string(none)
	}
	return ruby.int_value(ast_cask_replace_value(mut cask, args[1].as_string(), args[2], args[3], within))
}

// Ruby method `replace_root_stanza_with_arch_blocks(name, old_value)` at line 644.
pub fn ruby_ast_l644_d57_replace_root_stanza_with_arch_blocks(args ...ruby.Value) ruby.Value {
	mut cask := ast_cask_from_value(args[0])
	ast_cask_replace_root_with_arch(mut cask, args[1].as_string(), args[2])
	return ast_nil()
}

// Ruby method `depends_on_macos?` at line 663.
pub fn ruby_ast_l663_d58_depends_on_macos(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(ast_cask_depends_on_macos(ast_cask_from_value(args[0])))
}

// Ruby attr_reader `attr_reader :cask_contents` at line 677.
pub fn ruby_ast_l677_d59_cask_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value(ast_cask_from_value(args[0]).contents)
}

// Ruby attr_reader `attr_reader :processed_source` at line 680.
pub fn ruby_ast_l680_d60_processed_source(args ...ruby.Value) ruby.Value {
	cask := ast_cask_from_value(args[0])
	return ruby.structured_value('RuboCop::AST::ProcessedSource', cask.contents, {
		'source': cask.contents
	})
}

// Ruby attr_reader `attr_reader :cask_block` at line 683.
pub fn ruby_ast_l683_d61_cask_block(args ...ruby.Value) ruby.Value {
	return ast_node_value(ast_cask_block(ast_cask_from_value(args[0])))
}

// Ruby attr_reader `attr_reader :tree_rewriter` at line 686.
pub fn ruby_ast_l686_d62_tree_rewriter(args ...ruby.Value) ruby.Value {
	cask := ast_cask_from_value(args[0])
	return ruby.structured_value('Parser::Source::TreeRewriter', cask.contents, {
		'cask_ast_address': u64(voidptr(cask)).str()
	})
}

// Ruby method `stanzas(name, within: nil)` at line 689.
pub fn ruby_ast_l689_d63_stanzas(args ...ruby.Value) ruby.Value {
	within := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		?string(none)
	}
	return ruby.array_value(ast_cask_stanzas(ast_cask_from_value(args[0]), args[1].as_string(), within).map(ast_node_value(it)))
}

// Ruby method `top_level_stanzas(name)` at line 707.
pub fn ruby_ast_l707_d64_top_level_stanzas(args ...ruby.Value) ruby.Value {
	return ruby.array_value(ast_cask_top_level_stanzas(ast_cask_from_value(args[0]), args[1].as_string()).map(ast_node_value(it)))
}

// Ruby method `on_system_blocks(name)` at line 714.
pub fn ruby_ast_l714_d65_on_system_blocks(args ...ruby.Value) ruby.Value {
	return ruby.array_value(ast_cask_on_system_blocks(ast_cask_from_value(args[0]), args[1].as_string()).map(ast_node_value(it)))
}

// Ruby method `replace_stanza_argument(stanza_node, value)` at line 721.
pub fn ruby_ast_l721_d66_replace_stanza_argument(args ...ruby.Value) ruby.Value {
	mut cask := ast_cask_from_value(args[0])
	ast_cask_replace_argument(mut cask, ast_node_from_value(args[1]), args[2])
	return ast_nil()
}

// Ruby method `whole_line_range(range)` at line 729.
pub fn ruby_ast_l729_d67_whole_line_range(args ...ruby.Value) ruby.Value {
	cask := ast_cask_from_value(args[0])
	source_range := ast_whole_line_range(cask.contents, ast_range_from_value(args[1]), false)
	return ast_range_value(source_range, cask.contents[source_range.begin_pos..source_range.end_pos])
}

// Ruby method `line_end_pos(position)` at line 737.
pub fn ruby_ast_l737_d68_line_end_pos(args ...ruby.Value) ruby.Value {
	cask := ast_cask_from_value(args[0])
	return ruby.int_value(ast_line_end(cask.contents, int(args[1].as_int() or { 0 })))
}

// Ruby method `process_cask` at line 743.
pub fn ruby_ast_l743_d69_process_cask(args ...ruby.Value) ruby.Value {
	cask := ast_cask_from_value(args[0])
	processed := ruby.structured_value('RuboCop::AST::ProcessedSource', cask.contents, {
		'source': cask.contents
	})
	return ruby.array_value([processed, ast_node_value(ast_cask_block(cask))])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ast_constants"
// 5: require "rubocop-ast"
// 6:
// 7: module Utils
// 8:   # Helper functions for editing Ruby files.
// 9:   module AST
// 10:     Node = RuboCop::AST::Node
// 11:     SendNode = RuboCop::AST::SendNode
// 12:     BlockNode = RuboCop::AST::BlockNode
// 13:     DefNode = RuboCop::AST::DefNode
// 14:     ProcessedSource = RuboCop::AST::ProcessedSource
// 15:     TreeRewriter = Parser::Source::TreeRewriter
// 16:
// 17:     module_function
// 18:
// 19:     sig { params(body_node: T.nilable(Node)).returns(T::Array[Node]) }
// 20:     def body_children(body_node)
// 21:       if body_node.blank?
// 22:         []
// 23:       elsif body_node.begin_type?
// 24:         body_node.children.compact
// 25:       else
// 26:         [body_node]
// 27:       end
// 28:     end
// 29:
// 30:     sig { params(name: Symbol, value: T.any(Numeric, String, Symbol), indent: T.nilable(Integer)).returns(String) }
// 31:     def stanza_text(name, value, indent: nil)
// 32:       text = if value.is_a?(String)
// 33:         _, node = process_source(value)
// 34:         value if (node.is_a?(SendNode) || node.is_a?(BlockNode)) && node.method_name == name
// 35:       end
// 36:       text ||= "#{name} #{value.inspect}"
// 37:       text = text.gsub(/^(?!$)/, " " * indent) if indent && !text.match?(/\A\n* +/)
// 38:       text
// 39:     end
// 40:
// 41:     sig { params(value: T.any(Numeric, String, Symbol)).returns(String) }
// 42:     def ruby_literal(value)
// 43:       value.inspect
// 44:     end
// 45:
// 46:     sig { params(node: Node).returns(T.untyped) }
// 47:     def literal_value(node)
// 48:       return node.str_content if node.str_type?
// 49:       return T.unsafe(node).value if node.sym_type? || node.numeric_type?
// 50:
// 51:       nil
// 52:     end
// 53:
// 54:     sig { params(source: String).returns([ProcessedSource, Node]) }
// 55:     def process_source(source)
// 56:       ruby_version = Version.new(HOMEBREW_REQUIRED_RUBY_VERSION).major_minor.to_f
// 57:       processed_source = ProcessedSource.new(source, ruby_version)
// 58:       root_node = processed_source.ast
// 59:       [processed_source, root_node]
// 60:     end
// 61:
// 62:     sig {
// 63:       params(
// 64:         component_name: Symbol,
// 65:         component_type: Symbol,
// 66:         target_name:    Symbol,
// 67:         target_type:    T.nilable(Symbol),
// 68:       ).returns(T::Boolean)
// 69:     }
// 70:     def component_match?(component_name:, component_type:, target_name:, target_type: nil)
// 71:       component_name == target_name && (target_type.nil? || component_type == target_type)
// 72:     end
// 73:
// 74:     sig { params(node: Node, name: Symbol, type: T.nilable(Symbol)).returns(T::Boolean) }
// 75:     def call_node_match?(node, name:, type: nil)
// 76:       node_type = case node
// 77:       when SendNode then :method_call
// 78:       when BlockNode then :block_call
// 79:       else return false
// 80:       end
// 81:
// 82:       component_match?(component_name: node.method_name,
// 83:                        component_type: node_type,
// 84:                        target_name:    name,
// 85:                        target_type:    type)
// 86:     end
// 87:
// 88:     # Helper class for editing formulae.
// 89:     class FormulaAST
// 90:       extend Forwardable
// 91:       include AST
// 92:
// 93:       delegate process: :tree_rewriter
// 94:
// 95:       sig { params(formula_contents: String).void }
// 96:       def initialize(formula_contents)
// 97:         @formula_contents = formula_contents
// 98:         processed_source, children = process_formula
// 99:         @processed_source = T.let(processed_source, ProcessedSource)
// 100:         @children = T.let(children, T::Array[Node])
// 101:         @tree_rewriter = T.let(TreeRewriter.new(processed_source.buffer), TreeRewriter)
// 102:       end
// 103:
// 104:       sig { returns(T.nilable(Node)) }
// 105:       def bottle_block
// 106:         stanza(:bottle, type: :block_call)
// 107:       end
// 108:
// 109:       sig { params(name: Symbol, type: T.nilable(Symbol)).returns(T.nilable(Node)) }
// 110:       def stanza(name, type: nil)
// 111:         stanzas(name, type:).first
// 112:       end
// 113:
// 114:       sig { params(name: Symbol, type: T.nilable(Symbol)).returns(T::Array[Node]) }
// 115:       def stanzas(name, type: nil)
// 116:         matching_stanzas(children, name, type:)
// 117:       end
// 118:
// 119:       sig { params(name: String).returns(BlockNode) }
// 120:       def resource(name)
// 121:         possible_resource_stanzas = if stanza(:stable, type: :block_call).present?
// 122:           # Needed resource block may be either in `stable` or in formula body, hence appending
// 123:           # `children` nodes
// 124:           stable_children + children
// 125:         else
// 126:           children
// 127:         end
// 128:         resource = matching_stanzas(possible_resource_stanzas, :resource, type: :block_call).find do |resource_node|
// 129:           T.cast(resource_node, BlockNode).send_node.first_argument&.str_content == name
// 130:         end
// 131:         raise "Could not find resource '#{name}' block!" if resource.blank?
// 132:
// 133:         T.cast(resource, BlockNode)
// 134:       end
// 135:
// 136:       sig { params(name: Symbol, value: T.any(Numeric, String, Symbol)).void }
// 137:       def replace_stable_stanza_value(name, value)
// 138:         replace_stanza_value(stable_stanza(name), value)
// 139:       end
// 140:
// 141:       sig { params(name: Symbol, key: Symbol, value: T.any(Numeric, String, Symbol)).void }
// 142:       def replace_stable_stanza_hash_value(name, key, value)
// 143:         replace_stanza_hash_value(stable_stanza(name), key, value)
// 144:       end
// 145:
// 146:       sig { params(name: Symbol).returns(T::Boolean) }
// 147:       def stable_stanza?(name)
// 148:         matching_stanzas(stable_children, name).present?
// 149:       end
// 150:
// 151:       sig { params(name: Symbol).void }
// 152:       def remove_stable_stanza(name)
// 153:         remove_stanza_node(stable_stanza(name))
// 154:       end
// 155:
// 156:       sig { params(name: Symbol).void }
// 157:       def remove_stable_stanzas(name)
// 158:         stanza_nodes = matching_stanzas(stable_children, name)
// 159:         raise "Could not find '#{name}' stanza!" if stanza_nodes.empty?
// 160:
// 161:         stanza_nodes.each { |stanza_node| remove_stanza_node(stanza_node) }
// 162:       end
// 163:
// 164:       sig {
// 165:         params(
// 166:           after_name:  Symbol,
// 167:           new_stanzas: T::Array[[Symbol, T.any(Numeric, String, Symbol)]],
// 168:         ).void
// 169:       }
// 170:       def add_stable_stanzas_after(after_name, new_stanzas)
// 171:         add_stanzas_after(after_name, new_stanzas, parent: stanza(:stable, type: :block_call))
// 172:       end
// 173:
// 174:       sig {
// 175:         params(
// 176:           resource_name: String,
// 177:           name:          Symbol,
// 178:           value:         T.any(Numeric, String, Symbol),
// 179:           old_value:     T.nilable(T.any(Numeric, String, Symbol)),
// 180:         ).void
// 181:       }
// 182:       def replace_resource_stanza_value(resource_name, name, value, old_value: nil)
// 183:         replace_stanza_value(resource_stanza(resource_name, name, old_value:), value)
// 184:       end
// 185:
// 186:       sig { params(resource_name: String, name: Symbol).returns(T::Boolean) }
// 187:       def resource_stanza?(resource_name, name)
// 188:         matching_stanzas(body_children(resource(resource_name).body), name).present?
// 189:       end
// 190:
// 191:       sig {
// 192:         params(
// 193:           after_name:  Symbol,
// 194:           new_stanzas: T::Array[[Symbol, T.any(Numeric, String, Symbol)]],
// 195:           parent:      T.nilable(Node),
// 196:         ).void
// 197:       }
// 198:       def add_stanzas_after(after_name, new_stanzas, parent: nil)
// 199:         return if new_stanzas.empty?
// 200:
// 201:         preceding_component = if parent
// 202:           matching_stanzas(body_children(T.cast(parent, BlockNode).body), after_name).last
// 203:         else
// 204:           stanza(after_name)
// 205:         end
// 206:         raise "Could not find '#{after_name}' stanza!" if preceding_component.blank?
// 207:
// 208:         preceding_expr = source_range_with_trailing_comments(preceding_component)
// 209:         text = new_stanzas.map do |stanza_name, value|
// 210:           "\n#{stanza_text(stanza_name, value, indent: preceding_component.source_range.column)}"
// 211:         end.join
// 212:         tree_rewriter.insert_after(preceding_expr, text)
// 213:       end
// 214:
// 215:       sig {
// 216:         params(
// 217:           resource_section:   String,
// 218:           replace_existing:   T::Boolean,
// 219:           preserve_livecheck: T::Boolean,
// 220:         ).returns(T.nilable(Symbol))
// 221:       }
// 222:       def replace_resource_stanzas(resource_section, replace_existing: true, preserve_livecheck: false)
// 223:         resource_section = resource_section.gsub(/^(?!$)/, "  ") unless resource_section.match?(/\A\n* +/)
// 224:
// 225:         if replace_existing
// 226:           groups = resource_stanza_groups(preserve_livecheck:)
// 227:           return :multiple_groups if groups.length > 1
// 228:
// 229:           if (group = groups.first)
// 230:             tree_rewriter.replace(resource_stanza_group_range(group), resource_section)
// 231:             return
// 232:           end
// 233:         end
// 234:
// 235:         install_node = method_definition(:install)
// 236:         raise "Could not find 'install' method!" if install_node.blank?
// 237:
// 238:         tree_rewriter.insert_before(whole_line_range(install_node.source_range), resource_section)
// 239:         nil
// 240:       end
// 241:
// 242:       sig { params(bottle_output: String).void }
// 243:       def replace_bottle_block(bottle_output)
// 244:         replace_stanza(:bottle, bottle_output.chomp, type: :block_call)
// 245:       end
// 246:
// 247:       sig { params(bottle_output: String).void }
// 248:       def add_bottle_block(bottle_output)
// 249:         add_stanza(:bottle, "\n#{bottle_output.chomp}", type: :block_call)
// 250:       end
// 251:
// 252:       sig { params(name: Symbol, type: T.nilable(Symbol)).void }
// 253:       def remove_stanza(name, type: nil)
// 254:         stanza_node = stanza(name, type:)
// 255:         raise "Could not find '#{name}' stanza!" if stanza_node.blank?
// 256:
// 257:         remove_stanza_node(stanza_node)
// 258:       end
// 259:
// 260:       sig { params(name: Symbol, replacement: T.any(Numeric, String, Symbol), type: T.nilable(Symbol)).void }
// 261:       def replace_stanza(name, replacement, type: nil)
// 262:         stanza_node = stanza(name, type:)
// 263:         raise "Could not find '#{name}' stanza!" if stanza_node.blank?
// 264:
// 265:         tree_rewriter.replace(stanza_node.source_range, stanza_text(name, replacement, indent: 2).lstrip)
// 266:       end
// 267:
// 268:       sig { params(name: Symbol, value: T.any(Numeric, String, Symbol), type: T.nilable(Symbol)).void }
// 269:       def add_stanza(name, value, type: nil)
// 270:         preceding_component = if children.length > 1
// 271:           children.reduce do |previous_child, current_child|
// 272:             if formula_component_before_target?(current_child,
// 273:                                                 target_name: name,
// 274:                                                 target_type: type)
// 275:               next current_child
// 276:             else
// 277:               break previous_child
// 278:             end
// 279:           end
// 280:         else
// 281:           children.first
// 282:         end
// 283:         preceding_component = preceding_component.last_argument if preceding_component.is_a?(SendNode)
// 284:
// 285:         preceding_expr = preceding_component.location.expression
// 286:         processed_source.comments.each do |comment|
// 287:           comment_expr = comment.location.expression
// 288:           distance = comment_expr.first_line - preceding_expr.first_line
// 289:           case distance
// 290:           when 0
// 291:             if comment_expr.last_line > preceding_expr.last_line ||
// 292:                comment_expr.end_pos > preceding_expr.end_pos
// 293:               preceding_expr = comment_expr
// 294:             end
// 295:           when 1
// 296:             preceding_expr = comment_expr
// 297:           end
// 298:         end
// 299:
// 300:         tree_rewriter.insert_after(preceding_expr, "\n#{stanza_text(name, value, indent: 2)}")
// 301:       end
// 302:
// 303:       private
// 304:
// 305:       sig { returns(String) }
// 306:       attr_reader :formula_contents
// 307:
// 308:       sig { returns(ProcessedSource) }
// 309:       attr_reader :processed_source
// 310:
// 311:       sig { returns(T::Array[Node]) }
// 312:       attr_reader :children
// 313:
// 314:       sig { returns(TreeRewriter) }
// 315:       attr_reader :tree_rewriter
// 316:
// 317:       sig { params(nodes: T::Array[Node], name: Symbol, type: T.nilable(Symbol)).returns(T::Array[Node]) }
// 318:       def matching_stanzas(nodes, name, type: nil)
// 319:         nodes.select { |child| call_node_match?(child, name:, type:) }
// 320:       end
// 321:
// 322:       sig { params(name: Symbol).returns(Node) }
// 323:       def stable_stanza(name)
// 324:         stanza_node = matching_stanzas(stable_children, name).first
// 325:         raise "Could not find '#{name}' stanza!" if stanza_node.blank?
// 326:
// 327:         stanza_node
// 328:       end
// 329:
// 330:       sig {
// 331:         params(
// 332:           resource_name: String,
// 333:           name:          Symbol,
// 334:           old_value:     T.nilable(T.any(Numeric, String, Symbol)),
// 335:         ).returns(Node)
// 336:       }
// 337:       def resource_stanza(resource_name, name, old_value: nil)
// 338:         stanza_node = matching_stanzas(body_children(resource(resource_name).body), name).find do |node|
// 339:           old_value.nil? || literal_value(T.cast(node, T.any(SendNode, BlockNode)).first_argument) == old_value
// 340:         end
// 341:         raise "Could not find '#{name}' stanza in resource '#{resource_name}'!" if stanza_node.blank?
// 342:
// 343:         stanza_node
// 344:       end
// 345:
// 346:       sig { returns(T::Array[Node]) }
// 347:       def stable_children
// 348:         if (stable_node = stanza(:stable, type: :block_call))
// 349:           body_children(T.cast(stable_node, BlockNode).body)
// 350:         else
// 351:           children
// 352:         end
// 353:       end
// 354:
// 355:       sig { params(stanza_node: Node, value: T.any(Numeric, String, Symbol)).void }
// 356:       def replace_stanza_value(stanza_node, value)
// 357:         stanza_node = T.cast(stanza_node, T.any(SendNode, BlockNode))
// 358:         argument = stanza_node.first_argument
// 359:         raise "Could not find '#{stanza_node.method_name}' stanza value!" if argument.blank?
// 360:
// 361:         tree_rewriter.replace(argument.source_range, ruby_literal(value))
// 362:       end
// 363:
// 364:       sig { params(stanza_node: Node, key: Symbol, value: T.any(Numeric, String, Symbol)).void }
// 365:       def replace_stanza_hash_value(stanza_node, key, value)
// 366:         stanza_node = T.cast(stanza_node, T.any(SendNode, BlockNode))
// 367:         pair = stanza_node.arguments.grep(RuboCop::AST::HashNode).flat_map(&:pairs).find do |hash_pair|
// 368:           literal_value(hash_pair.key) == key
// 369:         end
// 370:         raise "Could not find '#{key}' value in '#{stanza_node.method_name}' stanza!" if pair.blank?
// 371:
// 372:         tree_rewriter.replace(pair.value.source_range, ruby_literal(value))
// 373:       end
// 374:
// 375:       sig { params(stanza_node: Node).void }
// 376:       def remove_stanza_node(stanza_node)
// 377:         # stanza is probably followed by a newline character
// 378:         # try to delete it if so
// 379:         stanza_range = stanza_node.source_range
// 380:         trailing_range = stanza_range.with(begin_pos: stanza_range.end_pos,
// 381:                                            end_pos:   stanza_range.end_pos + 1)
// 382:         if trailing_range.source.chomp.empty?
// 383:           stanza_range = stanza_range.adjust(end_pos: 1)
// 384:
// 385:           # stanza_node is probably indented
// 386:           # since a trailing newline has been removed,
// 387:           # try to delete leading whitespace on line
// 388:           leading_range = stanza_range.with(begin_pos: stanza_range.begin_pos - stanza_range.column,
// 389:                                             end_pos:   stanza_range.begin_pos)
// 390:           if leading_range.source.strip.empty?
// 391:             stanza_range = stanza_range.adjust(begin_pos: -stanza_range.column)
// 392:
// 393:             # if the stanza was preceded by a blank line, it should be removed
// 394:             # that is, if the two previous characters are newlines,
// 395:             # then delete one of them
// 396:             leading_range = stanza_range.with(begin_pos: stanza_range.begin_pos - 2,
// 397:                                               end_pos:   stanza_range.begin_pos)
// 398:             stanza_range = stanza_range.adjust(begin_pos: -1) if leading_range.source.chomp.chomp.empty?
// 399:           end
// 400:         end
// 401:
// 402:         tree_rewriter.remove(stanza_range)
// 403:       end
// 404:
// 405:       sig { params(node: T.any(Node, Parser::Source::Range)).returns(Parser::Source::Range) }
// 406:       def source_range_with_trailing_comments(node)
// 407:         preceding_expr = node.is_a?(Parser::Source::Range) ? node : node.location.expression
// 408:         processed_source.comments.each do |comment|
// 409:           comment_expr = comment.location.expression
// 410:           distance = comment_expr.first_line - preceding_expr.last_line
// 411:           case distance
// 412:           when 0
// 413:             if comment_expr.last_line > preceding_expr.last_line ||
// 414:                comment_expr.end_pos > preceding_expr.end_pos
// 415:               preceding_expr = comment_expr
// 416:             end
// 417:           when 1
// 418:             preceding_expr = comment_expr
// 419:           end
// 420:         end
// 421:         preceding_expr
// 422:       end
// 423:
// 424:       sig { params(name: Symbol).returns(T.nilable(DefNode)) }
// 425:       def method_definition(name)
// 426:         T.cast(
// 427:           children.find { |child| child.def_type? && T.cast(child, DefNode).method_name == name },
// 428:           T.nilable(DefNode),
// 429:         )
// 430:       end
// 431:
// 432:       sig { params(preserve_livecheck: T::Boolean).returns(T::Array[T::Array[BlockNode]]) }
// 433:       def resource_stanza_groups(preserve_livecheck: false)
// 434:         test_node = stanza(:test, type: :block_call)
// 435:         resource_nodes = stanzas(:resource, type: :block_call).filter_map do |node|
// 436:           node = T.cast(node, BlockNode)
// 437:           next if test_node.present? && node.source_range.begin_pos > test_node.source_range.begin_pos
// 438:
// 439:           next if preserve_livecheck &&
// 440:                   matching_stanzas(body_children(node.body), :livecheck, type: :block_call).present?
// 441:
// 442:           node
// 443:         end
// 444:
// 445:         groups = T.let([], T::Array[T::Array[BlockNode]])
// 446:         resource_nodes.each do |resource_node|
// 447:           previous_group = groups.last
// 448:           if previous_group.nil? || !resource_stanzas_contiguous?(previous_group.fetch(-1), resource_node)
// 449:             groups << [resource_node]
// 450:           else
// 451:             previous_group << resource_node
// 452:           end
// 453:         end
// 454:         groups
// 455:       end
// 456:
// 457:       sig { params(previous_node: BlockNode, current_node: BlockNode).returns(T::Boolean) }
// 458:       def resource_stanzas_contiguous?(previous_node, current_node)
// 459:         previous_end = whole_line_range(previous_node.source_range).end_pos
// 460:         current_start = current_node.source_range.begin_pos - current_node.source_range.column
// 461:         formula_contents[previous_end...current_start].to_s.lines.all? do |line|
// 462:           line.strip.empty? || line.strip.start_with?("# RESOURCE-ERROR:")
// 463:         end
// 464:       end
// 465:
// 466:       sig { params(group: T::Array[BlockNode]).returns(Parser::Source::Range) }
// 467:       def resource_stanza_group_range(group)
// 468:         first_range = source_range_with_leading_resource_error_comments(group.fetch(0).source_range)
// 469:         last_range = whole_line_range(group.fetch(-1).source_range, include_following_blank_lines: true)
// 470:         first_range.with(
// 471:           begin_pos: first_range.begin_pos - first_range.column,
// 472:           end_pos:   last_range.end_pos,
// 473:         )
// 474:       end
// 475:
// 476:       sig { params(range: Parser::Source::Range).returns(Parser::Source::Range) }
// 477:       def source_range_with_leading_resource_error_comments(range)
// 478:         loop do
// 479:           line_start = range.begin_pos - range.column
// 480:           previous_comments = processed_source.comments.select do |comment|
// 481:             comment.location.expression.end_pos <= line_start &&
// 482:               comment.text.start_with?("# RESOURCE-ERROR:")
// 483:           end
// 484:           previous_comment = previous_comments.max_by { |comment| comment.location.expression.end_pos }
// 485:           break if previous_comment.blank?
// 486:
// 487:           comment_range = previous_comment.location.expression
// 488:           break unless formula_contents[comment_range.end_pos...line_start].to_s.lines.all? do |line|
// 489:             line.strip.empty?
// 490:           end
// 491:
// 492:           range = T.cast(range.with(begin_pos: comment_range.begin_pos), Parser::Source::Range)
// 493:         end
// 494:         range
// 495:       end
// 496:
// 497:       sig {
// 498:         params(
// 499:           range:                         Parser::Source::Range,
// 500:           include_following_blank_lines: T::Boolean,
// 501:         ).returns(Parser::Source::Range)
// 502:       }
// 503:       def whole_line_range(range, include_following_blank_lines: false)
// 504:         begin_pos = range.begin_pos - range.column
// 505:         end_pos = line_end_pos(range.end_pos)
// 506:         if include_following_blank_lines
// 507:           while end_pos < formula_contents.length
// 508:             next_line_end = line_end_pos(end_pos)
// 509:             break unless formula_contents[end_pos...next_line_end].to_s.strip.empty?
// 510:
// 511:             end_pos = next_line_end
// 512:           end
// 513:         end
// 514:         range.with(begin_pos:, end_pos:)
// 515:       end
// 516:
// 517:       sig { params(position: Integer).returns(Integer) }
// 518:       def line_end_pos(position)
// 519:         newline_pos = formula_contents.index("\n", position)
// 520:         newline_pos ? newline_pos + 1 : formula_contents.length
// 521:       end
// 522:
// 523:       sig { returns([ProcessedSource, T::Array[Node]]) }
// 524:       def process_formula
// 525:         processed_source, root_node = process_source(formula_contents)
// 526:
// 527:         class_node = root_node if root_node.class_type?
// 528:         if root_node.begin_type?
// 529:           nodes = root_node.children.select(&:class_type?)
// 530:           class_node = if nodes.count > 1
// 531:             nodes.find { |n| n.parent_class&.const_name == "Formula" }
// 532:           else
// 533:             nodes.first
// 534:           end
// 535:         end
// 536:
// 537:         raise "Could not find formula class!" if class_node.nil?
// 538:
// 539:         children = body_children(class_node.body)
// 540:         raise "Formula class is empty!" if children.empty?
// 541:
// 542:         [processed_source, children]
// 543:       end
// 544:
// 545:       sig { params(node: Node, target_name: Symbol, target_type: T.nilable(Symbol)).returns(T::Boolean) }
// 546:       def formula_component_before_target?(node, target_name:, target_type: nil)
// 547:         FORMULA_COMPONENT_PRECEDENCE_LIST.each do |components|
// 548:           return false if components.any? do |component|
// 549:             component_match?(component_name: component[:name],
// 550:                              component_type: component[:type],
// 551:                              target_name:,
// 552:                              target_type:)
// 553:           end
// 554:           return true if components.any? do |component|
// 555:             call_node_match?(node, name: component[:name], type: component[:type])
// 556:           end
// 557:         end
// 558:
// 559:         false
// 560:       end
// 561:     end
// 562:
// 563:     # Helper class for editing casks.
// 564:     class CaskAST
// 565:       include AST
// 566:
// 567:       sig { params(cask_contents: String).void }
// 568:       def initialize(cask_contents)
// 569:         @cask_contents = cask_contents
// 570:         processed_source, cask_block = process_cask
// 571:         @processed_source = T.let(processed_source, ProcessedSource)
// 572:         @cask_block = T.let(cask_block, BlockNode)
// 573:         @tree_rewriter = T.let(TreeRewriter.new(processed_source.buffer), TreeRewriter)
// 574:       end
// 575:
// 576:       sig { returns(String) }
// 577:       def process
// 578:         tree_rewriter.process
// 579:       end
// 580:
// 581:       sig { params(name: Symbol, value: T.any(Numeric, String, Symbol)).void }
// 582:       def replace_first_stanza_value(name, value)
// 583:         stanza_node = stanzas(name).first
// 584:         raise "Could not find '#{name}' stanza!" if stanza_node.blank?
// 585:
// 586:         replace_stanza_argument(stanza_node, value)
// 587:       end
// 588:
// 589:       sig { params(name: Symbol, within: T.nilable(Symbol)).returns(T::Boolean) }
// 590:       def stanza?(name, within: nil)
// 591:         stanzas(name, within:).present?
// 592:       end
// 593:
// 594:       sig { params(name: Symbol, within: Symbol).returns(T::Boolean) }
// 595:       def stanza_anywhere?(name, within:)
// 596:         cask_block.each_node(:block).any? do |node|
// 597:           block_node = T.cast(node, BlockNode)
// 598:           next false if block_node.method_name != within || block_node.receiver.present?
// 599:
// 600:           block_node.each_node(:send).any? do |send_node|
// 601:             send_node.method_name == name && send_node.receiver.nil? && send_node.first_argument.present?
// 602:           end
// 603:         end
// 604:       end
// 605:
// 606:       sig { params(name: Symbol, within: T.nilable(Symbol)).returns(T.untyped) }
// 607:       def first_stanza_value(name, within: nil)
// 608:         stanza_node = stanzas(name, within:).first
// 609:         return if stanza_node.blank?
// 610:
// 611:         literal_value(stanza_node.first_argument)
// 612:       end
// 613:
// 614:       sig {
// 615:         params(
// 616:           name:      Symbol,
// 617:           old_value: T.any(Numeric, String, Symbol),
// 618:           new_value: T.any(Numeric, String, Symbol),
// 619:           within:    T.nilable(Symbol),
// 620:         ).returns(Integer)
// 621:       }
// 622:       def replace_stanza_value(name, old_value, new_value, within: nil)
// 623:         replacement_count = T.let(0, Integer)
// 624:         stanzas(name, within:).each do |stanza_node|
// 625:           if literal_value(stanza_node.first_argument) == old_value
// 626:             replace_stanza_argument(stanza_node, new_value)
// 627:             replacement_count += 1
// 628:           end
// 629:
// 630:           stanza_node.arguments.grep(RuboCop::AST::HashNode).each do |hash_node|
// 631:             hash_node.pairs.each do |pair|
// 632:               next if literal_value(pair.value) != old_value
// 633:
// 634:               tree_rewriter.replace(pair.value.source_range, ruby_literal(new_value))
// 635:               replacement_count += 1
// 636:             end
// 637:           end
// 638:         end
// 639:
// 640:         replacement_count
// 641:       end
// 642:
// 643:       sig { params(name: Symbol, old_value: T.any(Numeric, String, Symbol)).void }
// 644:       def replace_root_stanza_with_arch_blocks(name, old_value)
// 645:         stanza_node = top_level_stanzas(name).find do |node|
// 646:           literal_value(node.first_argument) == old_value
// 647:         end
// 648:         return if stanza_node.blank?
// 649:
// 650:         indent = " " * stanza_node.source_range.column
// 651:         replacement = <<~EOS
// 652:           #{indent}on_arm do
// 653:           #{indent}  #{name} #{ruby_literal(old_value)}
// 654:           #{indent}end
// 655:           #{indent}on_intel do
// 656:           #{indent}  #{name} #{ruby_literal(old_value)}
// 657:           #{indent}end
// 658:         EOS
// 659:         tree_rewriter.replace(whole_line_range(stanza_node.source_range), replacement)
// 660:       end
// 661:
// 662:       sig { returns(T::Boolean) }
// 663:       def depends_on_macos?
// 664:         stanzas(:depends_on).any? do |stanza_node|
// 665:           stanza_node.arguments.any? do |argument|
// 666:             literal_value(argument) == :macos ||
// 667:               (argument.hash_type? && T.cast(argument, RuboCop::AST::HashNode).pairs.any? do |pair|
// 668:                 literal_value(pair.key) == :macos
// 669:               end)
// 670:           end
// 671:         end
// 672:       end
// 673:
// 674:       private
// 675:
// 676:       sig { returns(String) }
// 677:       attr_reader :cask_contents
// 678:
// 679:       sig { returns(ProcessedSource) }
// 680:       attr_reader :processed_source
// 681:
// 682:       sig { returns(BlockNode) }
// 683:       attr_reader :cask_block
// 684:
// 685:       sig { returns(TreeRewriter) }
// 686:       attr_reader :tree_rewriter
// 687:
// 688:       sig { params(name: Symbol, within: T.nilable(Symbol)).returns(T::Array[SendNode]) }
// 689:       def stanzas(name, within: nil)
// 690:         if within == :root
// 691:           nodes = body_children(cask_block.body).grep(SendNode)
// 692:         elsif within
// 693:           blocks = on_system_blocks(within)
// 694:           return [] if blocks.blank?
// 695:
// 696:           nodes = blocks.flat_map { |block| body_children(block.body).grep(SendNode) }
// 697:         else
// 698:           nodes = cask_block.each_node(:send)
// 699:         end
// 700:
// 701:         nodes.select do |node|
// 702:           node.method_name == name && node.receiver.nil? && node.first_argument.present?
// 703:         end
// 704:       end
// 705:
// 706:       sig { params(name: Symbol).returns(T::Array[SendNode]) }
// 707:       def top_level_stanzas(name)
// 708:         body_children(cask_block.body).grep(SendNode).select do |node|
// 709:           node.method_name == name && node.receiver.nil? && node.first_argument.present?
// 710:         end
// 711:       end
// 712:
// 713:       sig { params(name: Symbol).returns(T::Array[BlockNode]) }
// 714:       def on_system_blocks(name)
// 715:         body_children(cask_block.body).grep(BlockNode).select do |node|
// 716:           node.method_name == name && node.receiver.nil?
// 717:         end
// 718:       end
// 719:
// 720:       sig { params(stanza_node: SendNode, value: T.any(Numeric, String, Symbol)).void }
// 721:       def replace_stanza_argument(stanza_node, value)
// 722:         argument = stanza_node.first_argument
// 723:         raise "Could not find '#{stanza_node.method_name}' stanza value!" if argument.blank?
// 724:
// 725:         tree_rewriter.replace(argument.source_range, ruby_literal(value))
// 726:       end
// 727:
// 728:       sig { params(range: Parser::Source::Range).returns(Parser::Source::Range) }
// 729:       def whole_line_range(range)
// 730:         range.with(
// 731:           begin_pos: range.begin_pos - range.column,
// 732:           end_pos:   line_end_pos(range.end_pos),
// 733:         )
// 734:       end
// 735:
// 736:       sig { params(position: Integer).returns(Integer) }
// 737:       def line_end_pos(position)
// 738:         newline_pos = cask_contents.index("\n", position)
// 739:         newline_pos ? newline_pos + 1 : cask_contents.length
// 740:       end
// 741:
// 742:       sig { returns([ProcessedSource, BlockNode]) }
// 743:       def process_cask
// 744:         processed_source, root_node = process_source(cask_contents)
// 745:         cask_block = if root_node.block_type? && T.cast(root_node, BlockNode).method_name == :cask
// 746:           T.cast(root_node, BlockNode)
// 747:         elsif root_node.begin_type?
// 748:           root_node.children.find { |node| node.block_type? && node.method_name == :cask }
// 749:         end
// 750:
// 751:         raise "Could not find cask block!" if cask_block.nil?
// 752:
// 753:         [processed_source, T.cast(cask_block, BlockNode)]
// 754:       end
// 755:     end
// 756:   end
// 757: end
