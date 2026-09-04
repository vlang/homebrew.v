module shared

import ruby
import homebrew.utils
import regex

// Translated from Homebrew/brew `rubocops/shared/helper_functions.rb`.
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
