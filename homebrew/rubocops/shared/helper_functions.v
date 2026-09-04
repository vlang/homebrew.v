module shared

import ruby
import homebrew.utils
import regex

// Translated from Homebrew/brew `rubocops/shared/helper_functions.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct HelperSourceRange {
pub:
	begin_pos int
	end_pos   int
	line      int = 1
	column    int
	buffer    string
}

pub struct HelperNode {
pub:
	identity            int
	kind                string
	name                string
	const_name          string
	source              string
	string_value        string
	literal             ruby.Value
	source_range        HelperSourceRange
	children            []HelperNode
	body                []HelperNode
	arguments           []HelperNode
	receiver            []HelperNode
	has_receiver        bool
	has_parent          bool
	parent_identity     int
	parent_kind         string
	parent_name         string
	parent_const_name   string
	parent_source       string
	parent_source_range HelperSourceRange
}

pub struct HelperProcessedSource {
pub:
	identity int
	source   string
	ast      HelperNode
}

pub struct HelperNodeCollection {
pub:
	identity int
	nodes    []HelperNode
}

pub struct HelperGroupedNodes {
pub:
	identity int
	groups   map[string][]HelperNode
}

pub struct HelperMatch {
pub:
	value     string
	begin_pos int
	end_pos   int
}

pub struct HelperProblem {
pub:
	message     string
	node        ?HelperNode
	replacement ?string
}

pub struct HelperIterationResult {
pub:
	value   []HelperNode
	yielded []HelperNode
}

pub struct HelperCallResult {
pub:
	has_boolean bool
	boolean     bool
	value       []HelperNode
	yielded     []HelperNode
}

pub struct HelperFindResult {
pub:
	found   bool
	yielded []HelperNode
}

pub struct HelperExpectedParameter {
pub:
	is_regex bool
	pattern  string
	value    ruby.Value
}

pub struct HelperFunctionsContext {
pub mut:
	processed_source_identity int
	has_processed_source      bool
	next_collection_identity  int = 1
	descendant_send_cache     map[int]HelperNodeCollection
	grouped_send_cache        map[int]HelperGroupedNodes
	offensive_node            ?HelperNode
	column                    ?int
	length                    ?int
	line_no                   ?int
	source_buf                ?string
	offensive_source_range    ?HelperSourceRange
	problems                  []HelperProblem
}

struct HelperIdentityCounter {
mut:
	value int
}

fn helper_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn helper_source_identity(source string) int {
	mut value := 17
	for character in source.bytes() {
		value = (value * 31 + int(character)) & 0x7fffffff
	}
	return if value == 0 { 1 } else { value }
}

fn helper_kind(kind string) string {
	return match kind {
		'method_call', 'sendnode' { 'send' }
		'block_call', 'blocknode' { 'block' }
		'method_definition', 'defnode' { 'def' }
		'strnode' { 'str' }
		'dstrnode' { 'dstr' }
		'constnode' { 'const' }
		'symbolnode' { 'sym' }
		else { kind }
	}
}

fn helper_receiver_from_ast(node utils.AstNode, buffer string, identity int,
	parent HelperNode) []HelperNode {
	if !node.has_receiver {
		return []
	}
	name_position := node.source.index(node.name) or { return [] }
	prefix := node.source[..name_position].trim_space().trim_right('.')
	if prefix == '' {
		return []
	}
	start := node.source_range.begin_pos + node.source.index(prefix) or { 0 }
	kind := if prefix[0].is_capital() { 'const' } else { 'send' }
	return [HelperNode{
		identity: identity
		kind: kind
		name: if kind == 'send' { prefix } else { '' }
		const_name: if kind == 'const' { prefix } else { '' }
		source: prefix
		string_value: prefix
		source_range: HelperSourceRange{
			begin_pos: start
			end_pos: start + prefix.len
			line: helper_line_for_position(buffer, start)
			column: helper_column_for_position(buffer, start)
			buffer: buffer
		}
		has_parent: true
		parent_identity: parent.identity
		parent_kind: parent.kind
		parent_name: parent.name
		parent_const_name: parent.const_name
		parent_source: parent.source
		parent_source_range: parent.source_range
	}]
}

fn helper_argument_from_ast(argument utils.AstArgument, buffer string, identity int,
	parent HelperNode) HelperNode {
	kind := match argument.value.type_name {
		'String' { 'str' }
		'Symbol' { 'sym' }
		'Array' { 'array' }
		'Hash' { 'hash' }
		else { argument.value.type_name.to_lower() }
	}
	return HelperNode{
		identity: identity
		kind: kind
		source: if argument.source_range.end_pos <= buffer.len {
			buffer[argument.source_range.begin_pos..argument.source_range.end_pos]
		} else {
			argument.value.repr
		}
		string_value: argument.value.repr
		literal: argument.value
		source_range: HelperSourceRange{
			begin_pos: argument.source_range.begin_pos
			end_pos: argument.source_range.end_pos
			line: helper_line_for_position(buffer, argument.source_range.begin_pos)
			column: helper_column_for_position(buffer, argument.source_range.begin_pos)
			buffer: buffer
		}
		has_parent: true
		parent_identity: parent.identity
		parent_kind: parent.kind
		parent_name: parent.name
		parent_const_name: parent.const_name
		parent_source: parent.source
		parent_source_range: parent.source_range
	}
}

fn helper_node_from_ast(node utils.AstNode, buffer string, mut counter HelperIdentityCounter,
	parent ?HelperNode) HelperNode {
	identity := counter.value
	counter.value++
	kind := helper_kind(node.kind)
	range := HelperSourceRange{
		begin_pos: node.source_range.begin_pos
		end_pos: node.source_range.end_pos
		line: helper_line_for_position(buffer, node.source_range.begin_pos)
		column: helper_column_for_position(buffer, node.source_range.begin_pos)
		buffer: buffer
	}
	parent_node := parent or { HelperNode{} }
	mut base := HelperNode{
		identity: identity
		kind: kind
		name: node.name
		const_name: if kind == 'class' || kind == 'const' { node.name } else { '' }
		source: node.source
		source_range: range
		has_receiver: node.has_receiver
		has_parent: parent != none
		parent_identity: parent_node.identity
		parent_kind: parent_node.kind
		parent_name: parent_node.name
		parent_const_name: parent_node.const_name
		parent_source: parent_node.source
		parent_source_range: parent_node.source_range
	}
	receiver := helper_receiver_from_ast(node, buffer, counter.value, base)
	counter.value += receiver.len
	mut arguments := []HelperNode{}
	for argument in node.arguments {
		arguments << helper_argument_from_ast(argument, buffer, counter.value, base)
		counter.value++
	}
	mut body := []HelperNode{}
	for child in node.children {
		body << helper_node_from_ast(child, buffer, mut counter, base)
	}
	mut children := []HelperNode{}
	children << receiver
	children << arguments
	if kind == 'block' {
		children << HelperNode{
			identity: counter.value
			kind: 'send'
			name: node.name
			source: node.source.all_before(' do')
			source_range: range
			arguments: arguments
			receiver: receiver
			has_receiver: receiver.len > 0
			has_parent: true
			parent_identity: identity
			parent_kind: kind
			parent_name: node.name
			parent_source: node.source
			parent_source_range: range
		}
		counter.value++
	}
	children << body
	base = HelperNode{
		...base
		children: children
		body: body
		arguments: arguments
		receiver: receiver
	}
	return base
}

fn helper_line_for_position(source string, position int) int {
	mut line := 1
	limit := if position < source.len { position } else { source.len }
	for character in source[..limit].bytes() {
		if character == `\n` {
			line++
		}
	}
	return line
}

fn helper_column_for_position(source string, position int) int {
	limit := if position < source.len { position } else { source.len }
	line_start := (source[..limit].last_index('\n') or { -1 }) + 1
	return limit - line_start
}

fn helper_inline_processed_source(source string, identity int) ?HelperProcessedSource {
	parts := source.split(';').map(it.trim_space()).filter(it != '')
	if parts.len < 3 || !parts[0].starts_with('class ') || parts.last() != 'end' {
		return none
	}
	class_name := parts[0][6..].trim_space()
	mut next_identity := identity * 100 + 1
	mut children := []HelperNode{}
	mut search_start := source.index(';') or { return none }
	for statement in parts[1..parts.len - 1] {
		position := source.index_after(statement, search_start) or { return none }
		name := statement.all_before('(').all_before(' ').trim_space()
		children << HelperNode{
			identity: next_identity
			kind: 'send'
			name: name
			source: statement
			source_range: HelperSourceRange{
				begin_pos: position
				end_pos: position + statement.len
				line: helper_line_for_position(source, position)
				column: helper_column_for_position(source, position)
				buffer: source
			}
			has_parent: true
			parent_identity: identity * 100
			parent_kind: 'class'
			parent_const_name: class_name
			parent_source: source
			parent_source_range: HelperSourceRange{
				begin_pos: 0
				end_pos: source.len
				line: 1
				buffer: source
			}
		}
		next_identity++
		search_start = position + statement.len
	}
	root := HelperNode{
		identity: identity * 100
		kind: 'class'
		const_name: class_name
		source: source
		source_range: HelperSourceRange{
			begin_pos: 0
			end_pos: source.len
			line: 1
			buffer: source
		}
		children: children
		body: children
	}
	return HelperProcessedSource{identity, source, root}
}

pub fn helper_processed_source(source string) !HelperProcessedSource {
	identity := helper_source_identity(source)
	if inline := helper_inline_processed_source(source, identity) {
		return inline
	}
	_, ast := utils.ast_process_source(source)
	mut counter := HelperIdentityCounter{ value: identity * 100 }
	root := helper_node_from_ast(ast, source, mut counter, none)
	return HelperProcessedSource{identity, source, root}
}

pub fn new_helper_functions_context() HelperFunctionsContext {
	return HelperFunctionsContext{}
}

fn helper_parent(node HelperNode) ?HelperNode {
	if !node.has_parent {
		return none
	}
	return HelperNode{
		identity: node.parent_identity
		kind: node.parent_kind
		name: node.parent_name
		const_name: node.parent_const_name
		source: node.parent_source
		source_range: node.parent_source_range
	}
}

fn helper_descendants_by_kind(node HelperNode, kind string) []HelperNode {
	mut result := []HelperNode{}
	for child in node.children {
		if child.kind == kind {
			result << child
		}
		result << helper_descendants_by_kind(child, kind)
	}
	return result
}

fn helper_node_key(node HelperNode) int {
	if node.identity != 0 {
		return node.identity
	}
	return helper_source_identity('${node.kind}:${node.name}:${node.source_range.begin_pos}:${node.source_range.end_pos}:${node.source}')
}

pub fn (mut context HelperFunctionsContext) descendant_send_nodes(processed_source HelperProcessedSource,
	node HelperNode) HelperNodeCollection {
	if !context.has_processed_source || context.processed_source_identity != processed_source.identity {
		context.processed_source_identity = processed_source.identity
		context.has_processed_source = true
		context.descendant_send_cache = map[int]HelperNodeCollection{}
		context.grouped_send_cache = map[int]HelperGroupedNodes{}
	}
	key := helper_node_key(node)
	if key in context.descendant_send_cache {
		return context.descendant_send_cache[key]
	}
	collection := HelperNodeCollection{
		identity: context.next_collection_identity
		nodes: helper_descendants_by_kind(node, 'send')
	}
	context.next_collection_identity++
	context.descendant_send_cache[key] = collection
	return collection
}

pub fn (mut context HelperFunctionsContext) descendant_send_nodes_by_method_name(processed_source HelperProcessedSource,
	node HelperNode) HelperGroupedNodes {
	collection := context.descendant_send_nodes(processed_source, node)
	key := helper_node_key(node)
	if key in context.grouped_send_cache {
		return context.grouped_send_cache[key]
	}
	mut groups := map[string][]HelperNode{}
	for send_node in collection.nodes {
		groups[send_node.name] << send_node
	}
	grouped := HelperGroupedNodes{
		identity: collection.identity
		groups: groups
	}
	context.grouped_send_cache[key] = grouped
	return grouped
}

pub fn helper_string_content(node HelperNode, strip_dynamic bool) string {
	return match node.kind {
		'str' { node.string_value }
		'dstr' {
			mut content := ''
			for child in node.children {
				if child.kind == 'begin' {
					if !strip_dynamic {
						content += child.source
					}
				} else if child.kind == 'str' {
					content += child.string_value
				}
			}
			content
		}
		'send' {
			if node.name == '+' && node.receiver.len > 0 && node.receiver[0].kind in [
				'str',
				'dstr',
			] {
				mut content := helper_string_content(node.receiver[0], false)
				if node.arguments.len > 0 {
					content += helper_string_content(node.arguments[0], false)
				}
				content
			} else {
				''
			}
		}
		'const' { node.const_name }
		'sym' { node.string_value.trim_left(':') }
		else { '' }
	}
}

pub fn helper_line_start_column(node HelperNode) int {
	buffer := node.source_range.buffer
	limit := if node.source_range.begin_pos < buffer.len {
		node.source_range.begin_pos
	} else {
		buffer.len
	}
	return (buffer[..limit].last_index('\n') or { -1 }) + 1
}

pub fn helper_start_column(node HelperNode) int {
	return node.source_range.begin_pos
}

pub fn helper_line_number(node HelperNode) int {
	if node.source_range.line > 0 {
		return node.source_range.line
	}
	return helper_line_for_position(node.source_range.buffer, node.source_range.begin_pos)
}

pub fn helper_source_buffer(node HelperNode) string {
	return node.source_range.buffer
}

pub fn (mut context HelperFunctionsContext) regex_match_group(node HelperNode,
	pattern string) ?HelperMatch {
	string_repr := helper_string_content(node, false)
	mut expression := regex.regex_opt(pattern) or { return none }
	begin_pos, end_pos := expression.find(string_repr)
	if begin_pos < 0 {
		return none
	}
	node_begin_pos := helper_start_column(node)
	line_begin_pos := helper_line_start_column(node)
	column := if node_begin_pos == line_begin_pos {
		node_begin_pos + begin_pos - line_begin_pos
	} else {
		node_begin_pos + begin_pos - line_begin_pos + 1
	}
	value := string_repr[begin_pos..end_pos]
	context.column = column
	context.length = value.len
	context.line_no = helper_line_number(node)
	context.source_buf = helper_source_buffer(node)
	context.offensive_node = node
	context.offensive_source_range = HelperSourceRange{
		begin_pos: line_begin_pos + column
		end_pos: line_begin_pos + column + value.len
		line: helper_line_number(node)
		column: column
		buffer: helper_source_buffer(node)
	}
	return HelperMatch{
		value: value
		begin_pos: begin_pos
		end_pos: end_pos
	}
}

pub fn (mut context HelperFunctionsContext) problem(message string,
	replacement ?string) {
	context.problems << HelperProblem{
		message: message
		node: context.offensive_node
		replacement: replacement
	}
}

pub fn helper_find_strings(node ?HelperNode) []HelperNode {
	value := node or { return [] }
	if value.kind == 'str' {
		return [value]
	}
	return helper_descendants_by_kind(value, 'str')
}

pub fn (mut context HelperFunctionsContext) find_node_method_by_name(node HelperNode,
	method_name string) ?HelperNode {
	for child in node.children {
		if child.kind == 'send' && child.name == method_name {
			context.offensive_node = child
			return child
		}
	}
	context.offensive_node = helper_parent(node)
	return none
}

pub fn (context &HelperFunctionsContext) get_offending_node() ?HelperNode {
	return context.offensive_node
}

pub fn (mut context HelperFunctionsContext) set_offending_node(node HelperNode) HelperNode {
	context.offensive_node = node
	return node
}

pub fn helper_find_method_calls_by_name(node ?HelperNode, method_name string) []HelperNode {
	value := node or { return [] }
	mut nodes := value.children.filter(it.kind == 'send' && it.name == method_name)
	if value.kind == 'send' && value.name == method_name {
		nodes << value
	}
	return nodes
}

pub fn (mut context HelperFunctionsContext) find_every_method_call_by_name(processed_source HelperProcessedSource,
	node ?HelperNode, method_name ?string) []HelperNode {
	value := node or { return [] }
	if name := method_name {
		grouped := context.descendant_send_nodes_by_method_name(processed_source, value)
		return (grouped.groups[name] or { [] }).clone()
	}
	return context.descendant_send_nodes(processed_source, value).nodes
}

pub fn (mut context HelperFunctionsContext) find_every_func_call_by_name(processed_source HelperProcessedSource,
	node ?HelperNode, function_name ?string) []HelperNode {
	return context.find_every_method_call_by_name(processed_source, node, function_name).filter(!it.has_receiver && it.receiver.len == 0)
}

pub fn (mut context HelperFunctionsContext) find_method_with_args(processed_source HelperProcessedSource,
	node ?HelperNode, method_name string, expected []HelperExpectedParameter,
	has_block bool) HelperIterationResult {
	methods := context.find_every_method_call_by_name(processed_source, node, method_name)
	mut yielded := []HelperNode{}
	for method in methods {
		if !context.parameters_passed(method, expected) {
			continue
		}
		if !has_block {
			return HelperIterationResult{}
		}
		yielded << method
	}
	return HelperIterationResult{
		value: methods
		yielded: yielded
	}
}

fn helper_receiver_matches(method HelperNode, instance string) bool {
	if method.receiver.len == 0 {
		return false
	}
	receiver := method.receiver[0]
	return receiver.const_name == instance || (receiver.kind == 'send' && receiver.name == instance)
}

pub fn (mut context HelperFunctionsContext) find_instance_method_call(processed_source HelperProcessedSource,
	node ?HelperNode, instance string, method_name ?string,
	has_block bool) HelperCallResult {
	methods := context.find_every_method_call_by_name(processed_source, node, method_name)
	mut yielded := []HelperNode{}
	for method in methods {
		if !helper_receiver_matches(method, instance) {
			continue
		}
		context.offensive_node = method
		if !has_block {
			return HelperCallResult{
				has_boolean: true
				boolean: true
			}
		}
		yielded << method
	}
	return HelperCallResult{
		value: methods
		yielded: yielded
	}
}

pub fn (mut context HelperFunctionsContext) find_instance_call(processed_source HelperProcessedSource,
	node HelperNode, name string, has_block bool) HelperCallResult {
	methods := context.descendant_send_nodes(processed_source, node).nodes
	mut yielded := []HelperNode{}
	for method in methods {
		if !helper_receiver_matches(method, name) {
			continue
		}
		context.offensive_node = method.receiver[0]
		if !has_block {
			return HelperCallResult{
				has_boolean: true
				boolean: true
			}
		}
		yielded << method
	}
	return HelperCallResult{
		value: methods
		yielded: yielded
	}
}

pub fn (mut context HelperFunctionsContext) find_const(node ?HelperNode, const_name string,
	has_block bool) HelperFindResult {
	value := node or { return HelperFindResult{} }
	for const_node in helper_descendants_by_kind(value, 'const') {
		if const_node.const_name != const_name {
			continue
		}
		context.offensive_node = const_node
		return HelperFindResult{
			found: true
			yielded: if has_block { [const_node] } else { [] }
		}
	}
	return HelperFindResult{}
}

fn helper_value_key(value ruby.Value) string {
	if value.type_name == 'Array' {
		return '[${value.array_data.map(helper_value_key(it)).join(',')}]'
	}
	if value.type_name == 'Hash' {
		mut keys := value.map_data.keys()
		keys.sort()
		return '{${keys.map('\${it}:\${helper_value_key(value.map_data[it])}').join(',')}}'
	}
	return '${value.type_name}:${value.repr}'
}

fn helper_node_literal(node HelperNode) ruby.Value {
	if node.literal.type_name != '' {
		return node.literal
	}
	return match node.kind {
		'str' { ruby.string_value(node.string_value) }
		'sym' { ruby.object_value('Symbol', ':${node.string_value.trim_left(':')}') }
		'array' { ruby.array_value(node.arguments.map(helper_node_literal(it))) }
		'const' { ruby.object_value('Constant', node.const_name) }
		else { ruby.object_value(node.kind, node.source) }
	}
}

pub fn helper_node_equals(node ?HelperNode, value ruby.Value) bool {
	candidate := node or { return false }
	return helper_value_key(helper_node_literal(candidate)) == helper_value_key(value)
}

pub fn (mut context HelperFunctionsContext) find_block(node ?HelperNode,
	block_name string) ?HelperNode {
	value := node or { return none }
	for block_node in value.children {
		if block_node.kind == 'block' && block_node.name == block_name {
			context.offensive_node = block_node
			return block_node
		}
	}
	context.offensive_node = helper_parent(value)
	return none
}

pub fn helper_find_blocks(node ?HelperNode, block_name string) []HelperNode {
	value := node or { return [] }
	return value.children.filter(it.kind == 'block' && it.name == block_name)
}

pub fn (mut context HelperFunctionsContext) find_all_blocks(node ?HelperNode,
	block_name string, has_block bool) HelperIterationResult {
	value := node or { return HelperIterationResult{} }
	blocks := helper_descendants_by_kind(value, 'block').filter(it.name == block_name)
	if !has_block {
		return HelperIterationResult{ value: blocks }
	}
	for block_node in blocks {
		context.set_offending_node(block_node)
	}
	return HelperIterationResult{
		value: blocks
		yielded: blocks
	}
}

pub fn (mut context HelperFunctionsContext) find_method_def(node ?HelperNode,
	method_name ?string) ?HelperNode {
	value := node or { return none }
	for definition in value.children {
		if definition.kind != 'def' {
			continue
		}
		name := helper_method_name(definition) or { '' }
		if requested := method_name {
			if requested != name {
				continue
			}
		}
		context.offensive_node = definition
		return definition
	}
	if value.has_parent {
		context.offensive_node = helper_parent(value)
	}
	return none
}

pub fn (mut context HelperFunctionsContext) block_method_called_in_block(node HelperNode,
	method_name string) bool {
	for call_node in node.body {
		if call_node.kind !in ['block', 'send'] || call_node.name != method_name {
			continue
		}
		context.offensive_node = call_node
		return true
	}
	return false
}

pub fn (mut context HelperFunctionsContext) method_called(node HelperNode,
	method_name string) bool {
	if node.kind == 'send' && node.name == method_name {
		context.set_offending_node(node)
		return true
	}
	for call_node in node.children {
		if call_node.kind == 'send' && call_node.name == method_name {
			context.set_offending_node(call_node)
			return true
		}
	}
	return false
}

pub fn (mut context HelperFunctionsContext) method_called_ever(processed_source HelperProcessedSource,
	node HelperNode, method_name string) bool {
	grouped := context.descendant_send_nodes_by_method_name(processed_source, node)
	calls := grouped.groups[method_name] or { return false }
	if calls.len == 0 {
		return false
	}
	context.offensive_node = calls[0]
	return true
}

pub fn (mut context HelperFunctionsContext) component_precedes(first_node HelperNode,
	next_node HelperNode) bool {
	if helper_line_number(first_node) < helper_line_number(next_node) {
		return false
	}
	context.offensive_node = first_node
	return true
}

pub fn (mut context HelperFunctionsContext) check_precedence(first_nodes []HelperNode,
	next_nodes []HelperNode) ?[]HelperNode {
	for next_node in next_nodes {
		for first_node in first_nodes {
			if context.component_precedes(first_node, next_node) {
				return [first_node, next_node]
			}
		}
	}
	return none
}

pub fn (mut context HelperFunctionsContext) expression_negated(node HelperNode) bool {
	parent := helper_parent(node) or { return false }
	if parent.kind != 'send' || parent.name != '!' {
		return false
	}
	context.set_offending_node(parent)
	return true
}

pub fn helper_parameters(method_node HelperNode) []HelperNode {
	if method_node.kind in ['send', 'block'] {
		return method_node.arguments.clone()
	}
	return []
}

pub fn (mut context HelperFunctionsContext) parameters_passed(method_node HelperNode,
	expected []HelperExpectedParameter) bool {
	method_parameters := helper_parameters(method_node)
	context.offensive_node = method_node
	for given_parameter in expected {
		mut present := false
		for method_parameter in method_parameters {
			if given_parameter.is_regex {
				if context.regex_match_group(method_parameter, given_parameter.pattern) != none {
					present = true
					break
				}
			} else if helper_node_equals(method_parameter, given_parameter.value) {
				present = true
				break
			}
		}
		if !present {
			return false
		}
	}
	return true
}

pub fn helper_end_column(node HelperNode) int {
	return node.source_range.end_pos
}

pub fn (mut context HelperFunctionsContext) class_name(node HelperNode) ?string {
	context.offensive_node = node
	if node.const_name == '' {
		return none
	}
	return node.const_name
}

pub fn helper_method_name(node HelperNode) ?string {
	if node.kind != 'def' || node.name == '' {
		return none
	}
	return node.name
}

pub fn helper_format_component(node HelperNode) ?string {
	if node.kind in ['send', 'block'] {
		return node.name
	}
	if node.kind == 'def' {
		return helper_method_name(node)
	}
	return none
}

pub fn helper_node_value(node HelperNode) ruby.Value {
	return ruby.Value{
		type_name: match node.kind {
			'send' { 'RuboCop::AST::SendNode' }
			'block' { 'RuboCop::AST::BlockNode' }
			'def' { 'RuboCop::AST::DefNode' }
			'str' { 'RuboCop::AST::StrNode' }
			'const' { 'RuboCop::AST::ConstNode' }
			else { 'RuboCop::AST::Node' }
		}
		repr: node.source
		array_data: node.children.map(helper_node_value(it))
		map_data: {
			'arguments': ruby.array_value(node.arguments.map(helper_node_value(it)))
			'body':      ruby.array_value(node.body.map(helper_node_value(it)))
			'receiver':  ruby.array_value(node.receiver.map(helper_node_value(it)))
			'literal':   node.literal
		}
		attributes: {
			'identity':          node.identity.str()
			'kind':              node.kind
			'name':              node.name
			'const_name':        node.const_name
			'string_value':      node.string_value
			'begin_pos':         node.source_range.begin_pos.str()
			'end_pos':           node.source_range.end_pos.str()
			'line':              node.source_range.line.str()
			'column':            node.source_range.column.str()
			'buffer':            node.source_range.buffer
			'has_receiver':      node.has_receiver.str()
			'has_parent':        node.has_parent.str()
			'parent_identity':   node.parent_identity.str()
			'parent_kind':       node.parent_kind
			'parent_name':       node.parent_name
			'parent_const_name': node.parent_const_name
			'parent_source':     node.parent_source
			'parent_begin_pos':  node.parent_source_range.begin_pos.str()
			'parent_end_pos':    node.parent_source_range.end_pos.str()
			'parent_line':       node.parent_source_range.line.str()
			'parent_column':     node.parent_source_range.column.str()
			'parent_buffer':     node.parent_source_range.buffer
		}
	}
}

fn helper_node_from_value(value ruby.Value) HelperNode {
	if !value.type_name.starts_with('RuboCop::AST::') {
		kind := match value.type_name {
			'String' { 'str' }
			'Symbol' { 'sym' }
			'Array' { 'array' }
			'Hash' { 'hash' }
			else { value.type_name.to_lower() }
		}
		return HelperNode{
			identity: helper_source_identity(helper_value_key(value))
			kind: kind
			source: value.repr
			string_value: value.repr.trim_left(':')
			literal: value
			source_range: HelperSourceRange{
				end_pos: value.repr.len
				line: 1
				buffer: value.repr
			}
		}
	}
	children := value.array_data.map(helper_node_from_value(it))
	arguments_value := value.map_data['arguments'] or { ruby.array_value([]) }
	body_value := value.map_data['body'] or { ruby.array_value([]) }
	receiver_value := value.map_data['receiver'] or { ruby.array_value([]) }
	return HelperNode{
		identity: (value.attributes['identity'] or { '0' }).int()
		kind: helper_kind(value.attributes['kind'] or {
			value.type_name.all_after_last('::').to_lower()
		})
		name: value.attributes['name'] or { '' }
		const_name: value.attributes['const_name'] or { '' }
		source: value.repr
		string_value: value.attributes['string_value'] or { '' }
		literal: value.map_data['literal'] or { ruby.Value{} }
		source_range: HelperSourceRange{
			begin_pos: (value.attributes['begin_pos'] or { '0' }).int()
			end_pos: (value.attributes['end_pos'] or { value.repr.len.str() }).int()
			line: (value.attributes['line'] or { '1' }).int()
			column: (value.attributes['column'] or { '0' }).int()
			buffer: value.attributes['buffer'] or { value.repr }
		}
		children: children
		body: body_value.array_data.map(helper_node_from_value(it))
		arguments: arguments_value.array_data.map(helper_node_from_value(it))
		receiver: receiver_value.array_data.map(helper_node_from_value(it))
		has_receiver: (value.attributes['has_receiver'] or { 'false' }).bool()
		has_parent: (value.attributes['has_parent'] or { 'false' }).bool()
		parent_identity: (value.attributes['parent_identity'] or { '0' }).int()
		parent_kind: value.attributes['parent_kind'] or { '' }
		parent_name: value.attributes['parent_name'] or { '' }
		parent_const_name: value.attributes['parent_const_name'] or { '' }
		parent_source: value.attributes['parent_source'] or { '' }
		parent_source_range: HelperSourceRange{
			begin_pos: (value.attributes['parent_begin_pos'] or { '0' }).int()
			end_pos: (value.attributes['parent_end_pos'] or { '0' }).int()
			line: (value.attributes['parent_line'] or { '1' }).int()
			column: (value.attributes['parent_column'] or { '0' }).int()
			buffer: value.attributes['parent_buffer'] or { '' }
		}
	}
}

fn helper_processed_source_from_values(args []ruby.Value, source_index int,
	node HelperNode) HelperProcessedSource {
	if source_index < args.len && args[source_index].type_name.contains('ProcessedSource') {
		source := args[source_index].attributes['source'] or { args[source_index].repr }
		identity := (args[source_index].attributes['identity'] or { helper_source_identity(source).str() }).int()
		return HelperProcessedSource{identity, source, node}
	}
	source := node.source_range.buffer
	return HelperProcessedSource{helper_source_identity(source), source, node}
}

fn helper_node_array_value(nodes []HelperNode, identity int) ruby.Value {
	return ruby.Value{
		type_name: 'Array'
		repr: nodes.map(it.source).str()
		array_data: nodes.map(helper_node_value(it))
		attributes: {
			'identity': identity.str()
		}
	}
}

fn helper_optional_node_value(node ?HelperNode) ruby.Value {
	value := node or { return helper_nil_value() }
	return helper_node_value(value)
}

fn helper_optional_string_value(value ?string) ruby.Value {
	text := value or { return helper_nil_value() }
	return ruby.string_value(text)
}

fn helper_node_argument(args []ruby.Value, index int) HelperNode {
	if index >= args.len {
		return HelperNode{}
	}
	return helper_node_from_value(args[index])
}

fn helper_nodes_argument(args []ruby.Value, index int) []HelperNode {
	if index >= args.len {
		return []
	}
	return args[index].array_data.map(helper_node_from_value(it))
}

fn helper_expected_arguments(args []ruby.Value, index int) []HelperExpectedParameter {
	if index >= args.len {
		return []
	}
	return args[index].array_data.map(HelperExpectedParameter{
		is_regex: it.type_name == 'Regexp'
		pattern: if it.type_name == 'Regexp' { it.repr } else { '' }
		value: it
	})
}

// Ruby method `self.descendant_send_nodes(processed_source, node)` at line 31.
pub fn ruby_helper_functions_l31_d1_self_descendant_send_nodes(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 1)
	processed_source := helper_processed_source_from_values(args, 0, node)
	mut context := new_helper_functions_context()
	collection := context.descendant_send_nodes(processed_source, node)
	return helper_node_array_value(collection.nodes, collection.identity)
}

// Ruby method `self.descendant_send_nodes_by_method_name(processed_source, node)` at line 45.
pub fn ruby_helper_functions_l45_d2_self_descendant_send_nodes_by_method_name(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 1)
	processed_source := helper_processed_source_from_values(args, 0, node)
	mut context := new_helper_functions_context()
	grouped := context.descendant_send_nodes_by_method_name(processed_source, node)
	mut values := map[string]ruby.Value{}
	for name, nodes in grouped.groups {
		values[name] = helper_node_array_value(nodes, grouped.identity)
	}
	return ruby.map_value(values)
}

// Ruby method `regex_match_group(node, pattern)` at line 54.
pub fn ruby_helper_functions_l54_d3_regex_match_group(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	matched := context.regex_match_group(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr
	} else {
		''
	}) or {
		return helper_nil_value()
	}
	return ruby.structured_value('MatchData', matched.value, {
		'begin_pos': matched.begin_pos.str()
		'end_pos':   matched.end_pos.str()
	})
}

// Ruby method `line_start_column(node)` at line 82.
pub fn ruby_helper_functions_l82_d4_line_start_column(args ...ruby.Value) ruby.Value {
	return ruby.int_value(helper_line_start_column(helper_node_argument(args, 0)))
}

// Ruby method `start_column(node)` at line 88.
pub fn ruby_helper_functions_l88_d5_start_column(args ...ruby.Value) ruby.Value {
	return ruby.int_value(helper_start_column(helper_node_argument(args, 0)))
}

// Ruby method `line_number(node)` at line 94.
pub fn ruby_helper_functions_l94_d6_line_number(args ...ruby.Value) ruby.Value {
	return ruby.int_value(helper_line_number(helper_node_argument(args, 0)))
}

// Ruby method `source_buffer(node)` at line 100.
pub fn ruby_helper_functions_l100_d7_source_buffer(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Parser::Source::Buffer', helper_source_buffer(helper_node_argument(args, 0)), {
		'source': helper_source_buffer(helper_node_argument(args, 0))
	})
}

// Ruby method `string_content(node, strip_dynamic: false)` at line 106.
pub fn ruby_helper_functions_l106_d8_string_content(args ...ruby.Value) ruby.Value {
	strip_dynamic := args.len > 1 && args[1].type_name == 'Bool' && args[1].bool_data
	return ruby.string_value(helper_string_content(helper_node_argument(args, 0), strip_dynamic))
}

// Ruby method `problem(msg, &block)` at line 140.
pub fn ruby_helper_functions_l140_d9_problem(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	context.problem(if args.len > 0 { args[0].repr } else { '' }, none)
	return helper_nil_value()
}

// Ruby method `find_strings(node)` at line 146.
pub fn ruby_helper_functions_l146_d10_find_strings(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	return helper_node_array_value(helper_find_strings(helper_node_argument(args, 0)), 0)
}

// Ruby method `find_node_method_by_name(node, method_name)` at line 155.
pub fn ruby_helper_functions_l155_d11_find_node_method_by_name(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return helper_optional_node_value(context.find_node_method_by_name(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}))
}

// Ruby method `offending_node(node = nil)` at line 171.
pub fn ruby_helper_functions_l171_d12_offending_node(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return helper_optional_node_value(context.get_offending_node())
	}
	return helper_node_value(context.set_offending_node(helper_node_argument(args, 0)))
}

// Ruby method `find_method_calls_by_name(node, method_name)` at line 181.
pub fn ruby_helper_functions_l181_d13_find_method_calls_by_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	return helper_node_array_value(helper_find_method_calls_by_name(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}), 0)
}

// Ruby method `find_every_method_call_by_name(node, method_name = nil)` at line 198.
pub fn ruby_helper_functions_l198_d14_find_every_method_call_by_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 2, node)
	mut context := new_helper_functions_context()
	name := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].repr.trim_left(':')
	} else {
		none
	}
	return helper_node_array_value(context.find_every_method_call_by_name(processed_source, node, name), 0)
}

// Ruby method `find_every_func_call_by_name(node, func_name = nil)` at line 214.
pub fn ruby_helper_functions_l214_d15_find_every_func_call_by_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 2, node)
	mut context := new_helper_functions_context()
	name := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].repr.trim_left(':')
	} else {
		none
	}
	return helper_node_array_value(context.find_every_func_call_by_name(processed_source, node, name), 0)
}

// Ruby method `find_method_with_args(node, method_name, *args, &_block)` at line 235.
pub fn ruby_helper_functions_l235_d16_find_method_with_args(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 3, node)
	mut context := new_helper_functions_context()
	result := context.find_method_with_args(processed_source, node, if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}, helper_expected_arguments(args, 2), false)
	return helper_node_array_value(result.value, 0)
}

// Ruby method `find_instance_method_call(node, instance, method_name, &_block)` at line 268.
pub fn ruby_helper_functions_l268_d17_find_instance_method_call(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 3, node)
	mut context := new_helper_functions_context()
	method_name := if args.len > 2 && args[2].type_name != 'NilClass' {
		args[2].repr.trim_left(':')
	} else {
		none
	}
	result := context.find_instance_method_call(processed_source, node, if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}, method_name, false)
	return if result.has_boolean {
		ruby.bool_value(result.boolean)
	} else {
		helper_node_array_value(result.value, 0)
	}
}

// Ruby method `find_instance_call(node, name, &_block)` at line 298.
pub fn ruby_helper_functions_l298_d18_find_instance_call(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 2, node)
	mut context := new_helper_functions_context()
	result := context.find_instance_call(processed_source, node, if args.len > 1 {
		args[1].repr
	} else {
		''
	}, false)
	return if result.has_boolean {
		ruby.bool_value(result.boolean)
	} else {
		helper_node_array_value(result.value, 0)
	}
}

// Ruby method `find_const(node, const_name, &_block)` at line 320.
pub fn ruby_helper_functions_l320_d19_find_const(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return helper_nil_value()
	}
	mut context := new_helper_functions_context()
	result := context.find_const(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr
	} else {
		''
	}, false)
	return if result.found { ruby.bool_value(true) } else { helper_nil_value() }
}

// Ruby method `node_equals?(node, var)` at line 335.
pub fn ruby_helper_functions_l335_d20_node_equals(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[0].type_name == 'NilClass' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(helper_node_equals(helper_node_argument(args, 0), args[1]))
}

// Ruby method `find_block(node, block_name)` at line 343.
pub fn ruby_helper_functions_l343_d21_find_block(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return helper_nil_value()
	}
	mut context := new_helper_functions_context()
	return helper_optional_node_value(context.find_block(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}))
}

// Ruby method `find_blocks(node, block_name)` at line 361.
pub fn ruby_helper_functions_l361_d22_find_blocks(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	return helper_node_array_value(helper_find_blocks(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}), 0)
}

// Ruby method `find_all_blocks(node, block_name, &_block)` at line 376.
pub fn ruby_helper_functions_l376_d23_find_all_blocks(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.array_value([])
	}
	mut context := new_helper_functions_context()
	result := context.find_all_blocks(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}, false)
	return helper_node_array_value(result.value, 0)
}

// Ruby method `find_method_def(node, method_name = nil)` at line 394.
pub fn ruby_helper_functions_l394_d24_find_method_def(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return helper_nil_value()
	}
	mut context := new_helper_functions_context()
	name := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].repr.trim_left(':')
	} else {
		none
	}
	return helper_optional_node_value(context.find_method_def(helper_node_argument(args, 0), name))
}

// Ruby method `block_method_called_in_block?(node, method_name)` at line 413.
pub fn ruby_helper_functions_l413_d25_block_method_called_in_block(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.block_method_called_in_block(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}))
}

// Ruby method `method_called?(node, method_name)` at line 427.
pub fn ruby_helper_functions_l427_d26_method_called(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.method_called(helper_node_argument(args, 0), if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}))
}

// Ruby method `method_called_ever?(node, method_name)` at line 443.
pub fn ruby_helper_functions_l443_d27_method_called_ever(args ...ruby.Value) ruby.Value {
	node := helper_node_argument(args, 0)
	processed_source := helper_processed_source_from_values(args, 2, node)
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.method_called_ever(processed_source, node, if args.len > 1 {
		args[1].repr.trim_left(':')
	} else {
		''
	}))
}

// Ruby method `check_precedence(first_nodes, next_nodes)` at line 456.
pub fn ruby_helper_functions_l456_d28_check_precedence(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	pair := context.check_precedence(helper_nodes_argument(args, 0), helper_nodes_argument(args, 1)) or { return helper_nil_value() }
	return helper_node_array_value(pair, 0)
}

// Ruby method `component_precedes?(first_node, next_node)` at line 467.
pub fn ruby_helper_functions_l467_d29_component_precedes(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.component_precedes(helper_node_argument(args, 0), helper_node_argument(args, 1)))
}

// Ruby method `expression_negated?(node)` at line 476.
pub fn ruby_helper_functions_l476_d30_expression_negated(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.expression_negated(helper_node_argument(args, 0)))
}

// Ruby method `parameters(method_node)` at line 485.
pub fn ruby_helper_functions_l485_d31_parameters(args ...ruby.Value) ruby.Value {
	return helper_node_array_value(helper_parameters(helper_node_argument(args, 0)), 0)
}

// Ruby method `parameters_passed?(method_node, params)` at line 497.
pub fn ruby_helper_functions_l497_d32_parameters_passed(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return ruby.bool_value(context.parameters_passed(helper_node_argument(args, 0), helper_expected_arguments(args, 1)))
}

// Ruby method `end_column(node)` at line 513.
pub fn ruby_helper_functions_l513_d33_end_column(args ...ruby.Value) ruby.Value {
	return ruby.int_value(helper_end_column(helper_node_argument(args, 0)))
}

// Ruby method `class_name(node)` at line 519.
pub fn ruby_helper_functions_l519_d34_class_name(args ...ruby.Value) ruby.Value {
	mut context := new_helper_functions_context()
	return helper_optional_string_value(context.class_name(helper_node_argument(args, 0)))
}

// Ruby method `method_name(node)` at line 526.
pub fn ruby_helper_functions_l526_d35_method_name(args ...ruby.Value) ruby.Value {
	return helper_optional_string_value(helper_method_name(helper_node_argument(args, 0)))
}

// Ruby method `format_component(component_node)` at line 532.
pub fn ruby_helper_functions_l532_d36_format_component(args ...ruby.Value) ruby.Value {
	return helper_optional_string_value(helper_format_component(helper_node_argument(args, 0)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop"
// 5:
// 6: require_relative "../../warnings"
// 7: Warnings.ignore :parser_syntax do
// 8:   require "parser/current"
// 9: end
// 10:
// 11: module RuboCop
// 12:   module Cop
// 13:     # Helper functions for cops.
// 14:     module HelperFunctions
// 15:       include RangeHelp
// 16:
// 17:       @processed_source = T.let(nil, T.nilable(RuboCop::ProcessedSource))
// 18:       @descendant_send_nodes = T.let(
// 19:         {}.compare_by_identity,
// 20:         T::Hash[RuboCop::AST::Node, T::Array[RuboCop::AST::SendNode]],
// 21:       )
// 22:       @descendant_send_nodes_by_method_name = T.let(
// 23:         {}.compare_by_identity,
// 24:         T::Hash[RuboCop::AST::Node, T::Hash[Symbol, T::Array[RuboCop::AST::SendNode]]],
// 25:       )
// 26:
// 27:       sig {
// 28:         params(processed_source: RuboCop::ProcessedSource, node: RuboCop::AST::Node)
// 29:           .returns(T::Array[RuboCop::AST::SendNode])
// 30:       }
// 31:       def self.descendant_send_nodes(processed_source, node)
// 32:         unless @processed_source.equal?(processed_source)
// 33:           @processed_source = processed_source
// 34:           @descendant_send_nodes.clear
// 35:           @descendant_send_nodes_by_method_name.clear
// 36:         end
// 37:
// 38:         @descendant_send_nodes[node] ||= node.each_descendant(:send).to_a
// 39:       end
// 40:
// 41:       sig {
// 42:         params(processed_source: RuboCop::ProcessedSource, node: RuboCop::AST::Node)
// 43:           .returns(T::Hash[Symbol, T::Array[RuboCop::AST::SendNode]])
// 44:       }
// 45:       def self.descendant_send_nodes_by_method_name(processed_source, node)
// 46:         descendant_send_nodes(processed_source, node)
// 47:         @descendant_send_nodes_by_method_name[node] ||=
// 48:           @descendant_send_nodes.fetch(node).group_by(&:method_name)
// 49:       end
// 50:
// 51:       # Checks for regex match of pattern in the node and
// 52:       # sets the appropriate instance variables to report the match.
// 53:       sig { params(node: RuboCop::AST::Node, pattern: T.any(Regexp, String)).returns(T.nilable(MatchData)) }
// 54:       def regex_match_group(node, pattern)
// 55:         string_repr = string_content(node).encode("UTF-8", invalid: :replace)
// 56:         match_object = string_repr.match(pattern)
// 57:         return unless match_object
// 58:
// 59:         node_begin_pos = start_column(node)
// 60:         line_begin_pos = line_start_column(node)
// 61:         @column = T.let(
// 62:           if node_begin_pos == line_begin_pos
// 63:             node_begin_pos + match_object.begin(0) - line_begin_pos
// 64:           else
// 65:             node_begin_pos + match_object.begin(0) - line_begin_pos + 1
// 66:           end,
// 67:           T.nilable(Integer),
// 68:         )
// 69:         @length = T.let(match_object.to_s.length, T.nilable(Integer))
// 70:         @line_no = T.let(line_number(node), T.nilable(Integer))
// 71:         @source_buf = T.let(source_buffer(node), T.nilable(Parser::Source::Buffer))
// 72:         @offensive_node = T.let(node, T.nilable(RuboCop::AST::Node))
// 73:         @offensive_source_range = T.let(
// 74:           source_range(@source_buf, @line_no, @column, @length),
// 75:           T.nilable(Parser::Source::Range),
// 76:         )
// 77:         match_object
// 78:       end
// 79:
// 80:       # Returns the begin position of the node's line in source code.
// 81:       sig { params(node: RuboCop::AST::Node).returns(Integer) }
// 82:       def line_start_column(node)
// 83:         node.source_range.source_buffer.line_range(node.loc.line).begin_pos
// 84:       end
// 85:
// 86:       # Returns the begin position of the node in source code.
// 87:       sig { params(node: RuboCop::AST::Node).returns(Integer) }
// 88:       def start_column(node)
// 89:         node.source_range.begin_pos
// 90:       end
// 91:
// 92:       # Returns the line number of the node.
// 93:       sig { params(node: RuboCop::AST::Node).returns(Integer) }
// 94:       def line_number(node)
// 95:         node.loc.line
// 96:       end
// 97:
// 98:       # Source buffer is required as an argument to report style violations.
// 99:       sig { params(node: RuboCop::AST::Node).returns(Parser::Source::Buffer) }
// 100:       def source_buffer(node)
// 101:         node.source_range.source_buffer
// 102:       end
// 103:
// 104:       # Returns the string representation if node is of type str(plain) or dstr(interpolated) or const.
// 105:       sig { params(node: RuboCop::AST::Node, strip_dynamic: T::Boolean).returns(String) }
// 106:       def string_content(node, strip_dynamic: false)
// 107:         case node.type
// 108:         when :str
// 109:           node.str_content
// 110:         when :dstr
// 111:           content = ""
// 112:           node.each_child_node(:str, :begin) do |child|
// 113:             content += if child.begin_type?
// 114:               strip_dynamic ? "" : child.source
// 115:             else
// 116:               child.str_content
// 117:             end
// 118:           end
// 119:           content
// 120:         when :send
// 121:           send_node = T.cast(node, RuboCop::AST::SendNode)
// 122:           if send_node.method?(:+) && (send_node.receiver.str_type? || send_node.receiver.dstr_type?)
// 123:             content = string_content(node.receiver)
// 124:             arg = send_node.arguments.first
// 125:             content += string_content(arg) if arg
// 126:             content
// 127:           else
// 128:             ""
// 129:           end
// 130:         when :const
// 131:           node.const_name
// 132:         when :sym
// 133:           node.children.first.to_s
// 134:         else
// 135:           ""
// 136:         end
// 137:       end
// 138:
// 139:       sig { params(msg: String, block: T.nilable(T.proc.params(corrector: RuboCop::Cop::Corrector).void)).void }
// 140:       def problem(msg, &block)
// 141:         add_offense(@offensive_node, message: msg, &block)
// 142:       end
// 143:
// 144:       # Returns all string nodes among the descendants of given node.
// 145:       sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T::Array[RuboCop::AST::Node]) }
// 146:       def find_strings(node)
// 147:         return [] if node.nil?
// 148:         return [node] if node.str_type?
// 149:
// 150:         node.each_descendant(:str).to_a
// 151:       end
// 152:
// 153:       # Returns method_node matching method_name.
// 154:       sig { params(node: RuboCop::AST::Node, method_name: Symbol).returns(T.nilable(RuboCop::AST::Node)) }
// 155:       def find_node_method_by_name(node, method_name)
// 156:         return if node.nil?
// 157:
// 158:         node.each_child_node(:send) do |method_node|
// 159:           next if method_node.method_name != method_name
// 160:
// 161:           @offensive_node = method_node
// 162:           return method_node
// 163:         end
// 164:         # If not found then, parent node becomes the offensive node
// 165:         @offensive_node = node.parent
// 166:         nil
// 167:       end
// 168:
// 169:       # Gets/sets the given node as the offending node when required in custom cops.
// 170:       sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(RuboCop::AST::Node)) }
// 171:       def offending_node(node = nil)
// 172:         return @offensive_node if node.nil?
// 173:
// 174:         @offensive_node = node
// 175:       end
// 176:
// 177:       # Returns an array of method call nodes matching method_name inside node with depth first order (child nodes).
// 178:       sig {
// 179:         params(node: T.nilable(RuboCop::AST::Node), method_name: Symbol).returns(T::Array[RuboCop::AST::SendNode])
// 180:       }
// 181:       def find_method_calls_by_name(node, method_name)
// 182:         return [] if node.nil?
// 183:
// 184:         nodes = node.each_child_node(:send).select { |method_node| method_name == method_node.method_name }
// 185:
// 186:         # The top level node can be a method
// 187:         nodes << node if node.is_a?(RuboCop::AST::SendNode) && node.method_name == method_name
// 188:
// 189:         nodes
// 190:       end
// 191:
// 192:       # Returns an array of method call nodes matching method_name in every descendant of node.
// 193:       # Returns every method call if no method_name is passed.
// 194:       sig {
// 195:         params(node: T.nilable(RuboCop::AST::Node), method_name: T.nilable(Symbol))
// 196:           .returns(T::Array[RuboCop::AST::SendNode])
// 197:       }
// 198:       def find_every_method_call_by_name(node, method_name = nil)
// 199:         return [] if node.nil?
// 200:         return HelperFunctions.descendant_send_nodes(processed_source, node) if method_name.nil?
// 201:
// 202:         HelperFunctions.descendant_send_nodes_by_method_name(processed_source, node).fetch(method_name, [])
// 203:       end
// 204:
// 205:       # Returns array of function call nodes matching func_name in every descendant of node.
// 206:       #
// 207:       # - matches function call: `foo(*args, **kwargs)`
// 208:       # - does not match method calls: `foo.bar(*args, **kwargs)`
// 209:       # - returns every function call if no func_name is passed
// 210:       sig {
// 211:         params(node: T.nilable(RuboCop::AST::Node), func_name: T.nilable(Symbol))
// 212:           .returns(T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)])
// 213:       }
// 214:       def find_every_func_call_by_name(node, func_name = nil)
// 215:         return [] if node.nil?
// 216:
// 217:         nodes = if func_name.nil?
// 218:           HelperFunctions.descendant_send_nodes(processed_source, node)
// 219:         else
// 220:           HelperFunctions.descendant_send_nodes_by_method_name(processed_source, node).fetch(func_name, [])
// 221:         end
// 222:         nodes.select { |func_node| func_node.receiver.nil? }
// 223:       end
// 224:
// 225:       # Given a method_name and arguments, yields to a block with
// 226:       # matching method passed as a parameter to the block.
// 227:       sig {
// 228:         params(
// 229:           node:        T.nilable(RuboCop::AST::Node),
// 230:           method_name: Symbol,
// 231:           args:        Object,
// 232:           _block:      T.nilable(T.proc.params(method: RuboCop::AST::Node).void),
// 233:         ).returns(T::Array[RuboCop::AST::SendNode])
// 234:       }
// 235:       def find_method_with_args(node, method_name, *args, &_block)
// 236:         methods = find_every_method_call_by_name(node, method_name)
// 237:         methods.each do |method|
// 238:           next unless parameters_passed?(method, args)
// 239:           return [] unless block_given?
// 240:
// 241:           yield method
// 242:         end
// 243:       end
// 244:
// 245:       # Matches a method with a receiver. Yields to a block with matching method node.
// 246:       #
// 247:       # ### Examples
// 248:       #
// 249:       # Match `Formula.factory(name)`.
// 250:       #
// 251:       # ```ruby
// 252:       # find_instance_method_call(node, "Formula", :factory)
// 253:       # ```
// 254:       #
// 255:       # Match `build.head?`.
// 256:       #
// 257:       # ```ruby
// 258:       # find_instance_method_call(node, :build, :head?)
// 259:       # ```
// 260:       sig {
// 261:         params(
// 262:           node:        T.nilable(RuboCop::AST::Node),
// 263:           instance:    T.any(String, Symbol),
// 264:           method_name: T.nilable(Symbol),
// 265:           _block:      T.nilable(T.proc.params(method: RuboCop::AST::SendNode).void),
// 266:         ).returns(T.anything)
// 267:       }
// 268:       def find_instance_method_call(node, instance, method_name, &_block)
// 269:         methods = find_every_method_call_by_name(node, method_name)
// 270:         methods.each do |method|
// 271:           next if method.receiver.nil?
// 272:           next if method.receiver.const_name != instance &&
// 273:                   !(method.receiver.send_type? && method.receiver.method_name == instance)
// 274:
// 275:           @offensive_node = method
// 276:           return true unless block_given?
// 277:
// 278:           yield method
// 279:         end
// 280:       end
// 281:
// 282:       # Matches receiver part of method. Yields to a block with parent node of receiver.
// 283:       #
// 284:       # ### Example
// 285:       #
// 286:       # Match `ARGV.<whatever>()`.
// 287:       #
// 288:       # ```ruby
// 289:       # find_instance_call(node, "ARGV")
// 290:       # ```
// 291:       sig {
// 292:         params(
// 293:           node:   RuboCop::AST::Node,
// 294:           name:   String,
// 295:           _block: T.nilable(T.proc.params(method: RuboCop::AST::Node).void),
// 296:         ).returns(T.anything)
// 297:       }
// 298:       def find_instance_call(node, name, &_block)
// 299:         HelperFunctions.descendant_send_nodes(processed_source, node).each do |method_node|
// 300:           next if method_node.receiver.nil?
// 301:           next if method_node.receiver.const_name != name &&
// 302:                   !(method_node.receiver.send_type? && method_node.receiver.method_name == name)
// 303:
// 304:           @offensive_node = method_node.receiver
// 305:           return true unless block_given?
// 306:
// 307:           yield method_node
// 308:         end
// 309:       end
// 310:
// 311:       # Find CONSTANTs in the source.
// 312:       # If block given, yield matching nodes.
// 313:       sig {
// 314:         params(
// 315:           node:       T.nilable(RuboCop::AST::Node),
// 316:           const_name: String,
// 317:           _block:     T.nilable(T.proc.params(const: RuboCop::AST::Node).void),
// 318:         ).returns(T.anything)
// 319:       }
// 320:       def find_const(node, const_name, &_block)
// 321:         return if node.nil?
// 322:
// 323:         node.each_descendant(:const) do |const_node|
// 324:           next if const_node.const_name != const_name
// 325:
// 326:           @offensive_node = const_node
// 327:           yield const_node if block_given?
// 328:           return true
// 329:         end
// 330:         nil
// 331:       end
// 332:
// 333:       # To compare node with appropriate Ruby variable.
// 334:       sig { params(node: T.nilable(RuboCop::AST::Node), var: Object).returns(T::Boolean) }
// 335:       def node_equals?(node, var)
// 336:         node == Parser::CurrentRuby.parse(var.inspect)
// 337:       end
// 338:
// 339:       # Returns a block named block_name inside node.
// 340:       sig {
// 341:         params(node: T.nilable(RuboCop::AST::Node), block_name: Symbol).returns(T.nilable(RuboCop::AST::BlockNode))
// 342:       }
// 343:       def find_block(node, block_name)
// 344:         return if node.nil?
// 345:
// 346:         node.each_child_node(:block) do |block_node|
// 347:           next if block_node.method_name != block_name
// 348:
// 349:           @offensive_node = block_node
// 350:           return block_node
// 351:         end
// 352:         # If not found then, parent node becomes the offensive node
// 353:         @offensive_node = node.parent
// 354:         nil
// 355:       end
// 356:
// 357:       # Returns an array of block nodes named block_name inside node.
// 358:       sig {
// 359:         params(node: T.nilable(RuboCop::AST::Node), block_name: Symbol).returns(T::Array[RuboCop::AST::BlockNode])
// 360:       }
// 361:       def find_blocks(node, block_name)
// 362:         return [] if node.nil?
// 363:
// 364:         node.each_child_node(:block).select { |block_node| block_name == block_node.method_name }
// 365:       end
// 366:
// 367:       # Returns an array of block nodes of any depth below node in AST.
// 368:       # If a block is given then yields matching block node to the block!
// 369:       sig {
// 370:         params(
// 371:           node:       T.nilable(RuboCop::AST::Node),
// 372:           block_name: Symbol,
// 373:           _block:     T.nilable(T.proc.params(block: RuboCop::AST::BlockNode).void),
// 374:         ).returns(T::Array[RuboCop::AST::BlockNode])
// 375:       }
// 376:       def find_all_blocks(node, block_name, &_block)
// 377:         return [] if node.nil?
// 378:
// 379:         blocks = node.each_descendant(:block).select { |block_node| block_name == block_node.method_name }
// 380:         return blocks unless block_given?
// 381:
// 382:         blocks.each do |block_node|
// 383:           offending_node(block_node)
// 384:           yield block_node
// 385:         end
// 386:       end
// 387:
// 388:       # Returns a method definition node with method_name.
// 389:       # Returns first method def if method_name is nil.
// 390:       sig {
// 391:         params(node: T.nilable(RuboCop::AST::Node), method_name: T.nilable(Symbol))
// 392:           .returns(T.nilable(RuboCop::AST::Node))
// 393:       }
// 394:       def find_method_def(node, method_name = nil)
// 395:         return if node.nil?
// 396:
// 397:         node.each_child_node(:def) do |def_node|
// 398:           def_method_name = method_name(def_node)
// 399:           next if method_name != def_method_name && method_name.present?
// 400:
// 401:           @offensive_node = def_node
// 402:           return def_node
// 403:         end
// 404:         return if node.parent.nil?
// 405:
// 406:         # If not found then, parent node becomes the offensive node
// 407:         @offensive_node = node.parent
// 408:         nil
// 409:       end
// 410:
// 411:       # Check if a block method is called inside a block.
// 412:       sig { params(node: RuboCop::AST::BlockNode, method_name: Symbol).returns(T::Boolean) }
// 413:       def block_method_called_in_block?(node, method_name)
// 414:         node.body.each_child_node do |call_node|
// 415:           next if !call_node.block_type? && !call_node.send_type?
// 416:           next if call_node.method_name != method_name
// 417:
// 418:           @offensive_node = call_node
// 419:           return true
// 420:         end
// 421:         false
// 422:       end
// 423:
// 424:       # Check if method_name is called among the direct children nodes in the given node.
// 425:       # Check if the node itself is the method.
// 426:       sig { params(node: RuboCop::AST::Node, method_name: Symbol).returns(T::Boolean) }
// 427:       def method_called?(node, method_name)
// 428:         if node.is_a?(RuboCop::AST::SendNode) && node.method_name == method_name
// 429:           offending_node(node)
// 430:           return true
// 431:         end
// 432:         node.each_child_node(:send) do |call_node|
// 433:           next if call_node.method_name != method_name
// 434:
// 435:           offending_node(call_node)
// 436:           return true
// 437:         end
// 438:         false
// 439:       end
// 440:
// 441:       # Check if method_name is called among every descendant node of given node.
// 442:       sig { params(node: RuboCop::AST::Node, method_name: Symbol).returns(T::Boolean) }
// 443:       def method_called_ever?(node, method_name)
// 444:         call_node = HelperFunctions.descendant_send_nodes_by_method_name(processed_source, node)[method_name]&.first
// 445:         return false unless call_node
// 446:
// 447:         @offensive_node = call_node
// 448:         true
// 449:       end
// 450:
// 451:       # Checks for precedence; returns the first pair of precedence-violating nodes.
// 452:       sig {
// 453:         params(first_nodes: T::Array[RuboCop::AST::Node], next_nodes: T::Array[RuboCop::AST::Node])
// 454:           .returns(T.nilable([RuboCop::AST::Node, RuboCop::AST::Node]))
// 455:       }
// 456:       def check_precedence(first_nodes, next_nodes)
// 457:         next_nodes.each do |each_next_node|
// 458:           first_nodes.each do |each_first_node|
// 459:             return [each_first_node, each_next_node] if component_precedes?(each_first_node, each_next_node)
// 460:           end
// 461:         end
// 462:         nil
// 463:       end
// 464:
// 465:       # If first node does not precede next_node, sets appropriate instance variables for reporting.
// 466:       sig { params(first_node: RuboCop::AST::Node, next_node: RuboCop::AST::Node).returns(T::Boolean) }
// 467:       def component_precedes?(first_node, next_node)
// 468:         return false if line_number(first_node) < line_number(next_node)
// 469:
// 470:         @offensive_node = first_node
// 471:         true
// 472:       end
// 473:
// 474:       # Check if negation is present in the given node.
// 475:       sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 476:       def expression_negated?(node)
// 477:         return false unless node.parent&.send_type?
// 478:         return false unless node.parent.method_name.equal?(:!)
// 479:
// 480:         !!offending_node(node.parent)
// 481:       end
// 482:
// 483:       # Returns the array of arguments of the method_node.
// 484:       sig { params(method_node: RuboCop::AST::Node).returns(T::Array[RuboCop::AST::Node]) }
// 485:       def parameters(method_node)
// 486:         if method_node.is_a?(RuboCop::AST::SendNode) || method_node.is_a?(RuboCop::AST::BlockNode)
// 487:           method_node.arguments
// 488:         else
// 489:           []
// 490:         end
// 491:       end
// 492:
// 493:       # Returns true if the given parameters are present in method call
// 494:       # and sets the method call as the offending node.
// 495:       # Params can be string, symbol, array, hash, matching regex.
// 496:       sig { params(method_node: RuboCop::AST::Node, params: T::Array[Object]).returns(T::Boolean) }
// 497:       def parameters_passed?(method_node, params)
// 498:         method_params = parameters(method_node)
// 499:         @offensive_node = method_node
// 500:         params.all? do |given_param|
// 501:           method_params.any? do |method_param|
// 502:             if given_param.instance_of?(Regexp)
// 503:               regex_match_group(method_param, given_param)
// 504:             else
// 505:               node_equals?(method_param, given_param)
// 506:             end
// 507:           end
// 508:         end
// 509:       end
// 510:
// 511:       # Returns the ending position of the node in source code.
// 512:       sig { params(node: RuboCop::AST::Node).returns(Integer) }
// 513:       def end_column(node)
// 514:         node.source_range.end_pos
// 515:       end
// 516:
// 517:       # Returns the class node's name, or nil if not a class node.
// 518:       sig { params(node: RuboCop::AST::Node).returns(T.nilable(String)) }
// 519:       def class_name(node)
// 520:         @offensive_node = node
// 521:         node.const_name
// 522:       end
// 523:
// 524:       # Returns the method name for a def node.
// 525:       sig { params(node: RuboCop::AST::Node).returns(T.nilable(Symbol)) }
// 526:       def method_name(node)
// 527:         node.children[0] if node.def_type?
// 528:       end
// 529:
// 530:       # Returns printable component name.
// 531:       sig { params(component_node: RuboCop::AST::Node).returns(T.nilable(Symbol)) }
// 532:       def format_component(component_node)
// 533:         if component_node.is_a?(RuboCop::AST::SendNode) || component_node.is_a?(RuboCop::AST::BlockNode)
// 534:           component_node.method_name
// 535:         elsif component_node.def_type?
// 536:           method_name(component_node)
// 537:         end
// 538:       end
// 539:     end
// 540:   end
// 541: end
