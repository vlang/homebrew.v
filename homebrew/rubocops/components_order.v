module rubocops

import ruby
import homebrew.utils

// Translated from Homebrew/brew `rubocops/components_order.rb`.
// The original source is retained below until every stub has a typed V body.
struct ComponentsOrderRule {
pub:
	name string
	kind string
}

pub struct ComponentsOrderOffense {
pub:
	node_name  string
	other_name string
	line       int
	other_line int
	begin_pos  int
	end_pos    int
	message    string
	corrected  string
}

pub struct ComponentsOrderAnalysis {
pub:
	source             string
	present_components [][]utils.AstNode
	offenses           []ComponentsOrderOffense
	corrected          string
}

fn components_order_rule(name string, kind string) ComponentsOrderRule {
	return ComponentsOrderRule{name, kind}
}

fn components_order_formula_precedence() [][]ComponentsOrderRule {
	mut rules := [
		[components_order_rule('include', 'method_call')],
		[components_order_rule('desc', 'method_call')],
		[components_order_rule('homepage', 'method_call')],
		[components_order_rule('url', 'method_call')],
		[components_order_rule('mirror', 'method_call')],
		[components_order_rule('version', 'method_call')],
		[components_order_rule('sha256', 'method_call')],
		[components_order_rule('license', 'method_call')],
		[components_order_rule('revision', 'method_call')],
		[components_order_rule('version_scheme', 'method_call')],
		[components_order_rule('compatibility_version', 'method_call')],
		[components_order_rule('head', 'method_call')],
		[components_order_rule('stable', 'block_call')],
		[components_order_rule('livecheck', 'block_call')],
		[components_order_rule('no_autobump!', 'method_call')],
		[components_order_rule('bottle', 'block_call')],
		[components_order_rule('pour_bottle?', 'block_call')],
		[components_order_rule('head', 'block_call')],
		[components_order_rule('bottle', 'method_call')],
		[components_order_rule('keg_only', 'method_call')],
		[components_order_rule('option', 'method_call')],
		[components_order_rule('deprecated_option', 'method_call')],
		[components_order_rule('deprecate!', 'method_call')],
		[components_order_rule('disable!', 'method_call')],
		[components_order_rule('depends_on', 'method_call')],
		[components_order_rule('uses_from_macos', 'method_call')],
		[components_order_rule('on_macos', 'block_call')],
	]
	for version in ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur',
		'catalina'] {
		rules << [components_order_rule('on_${version}', 'block_call')]
	}
	rules << [components_order_rule('on_system', 'block_call')]
	rules << [components_order_rule('on_linux', 'block_call')]
	rules << [components_order_rule('on_arm', 'block_call')]
	rules << [components_order_rule('on_intel', 'block_call')]
	rules << [components_order_rule('conflicts_with', 'method_call')]
	rules << [components_order_rule('preserve_rpath', 'method_call')]
	rules << [components_order_rule('skip_clean', 'method_call')]
	rules << [components_order_rule('cxxstdlib_check', 'method_call')]
	rules << [components_order_rule('link_overwrite', 'method_call')]
	rules << [components_order_rule('fails_with', 'method_call'),
		components_order_rule('fails_with', 'block_call')]
	rules << [components_order_rule('pypi_packages', 'method_call')]
	rules << [components_order_rule('resource', 'block_call')]
	rules << [components_order_rule('patch', 'method_call'),
		components_order_rule('patch', 'block_call')]
	rules << [components_order_rule('needs', 'method_call')]
	rules << [components_order_rule('allow_network_access!', 'method_call')]
	rules << [components_order_rule('deny_network_access!', 'method_call')]
	rules << [components_order_rule('install', 'method_definition')]
	rules << [components_order_rule('post_install_steps', 'block_call')]
	rules << [components_order_rule('post_install', 'method_definition')]
	rules << [components_order_rule('caveats', 'method_definition')]
	rules << [components_order_rule('plist_options', 'method_call'),
		components_order_rule('plist', 'method_definition')]
	rules << [components_order_rule('test', 'block_call')]
	return rules
}

fn components_order_formula_block_precedence() [][]ComponentsOrderRule {
	return [
		[components_order_rule('depends_on', 'method_call')],
		[components_order_rule('resource', 'block_call')],
		[components_order_rule('patch', 'method_call'), components_order_rule('patch', 'block_call')],
	]
}

fn components_order_on_system_methods() []string {
	mut methods := ['on_intel', 'on_arm', 'on_macos', 'on_linux', 'on_system']
	for version in ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur',
		'catalina'] {
		methods << 'on_${version}'
	}
	return methods
}

fn components_order_line(source string, position int) int {
	mut line := 1
	limit := if position < source.len { position } else { source.len }
	for character in source[..limit].bytes() {
		if character == `\n` {
			line++
		}
	}
	return line
}

fn components_order_component_name(node utils.AstNode) string {
	return node.name
}

fn components_order_body(source string) ?utils.AstNode {
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

fn components_order_children(node utils.AstNode) []utils.AstNode {
	return if node.kind == 'begin' || node.kind == 'class' || node.kind == 'block_call' {
		node.children.clone()
	} else {
		[node]
	}
}

fn components_order_find_blocks(node utils.AstNode, name string) []utils.AstNode {
	return components_order_children(node).filter(it.kind == 'block_call' && it.name == name)
}

fn components_order_present(rules [][]ComponentsOrderRule, body utils.AstNode) [][]utils.AstNode {
	children := components_order_children(body)
	mut present := [][]utils.AstNode{}
	for group in rules {
		mut nodes := []utils.AstNode{}
		for rule in group {
			for node in children {
				if node.name == rule.name && node.kind == rule.kind {
					nodes << node
				}
			}
		}
		present << nodes
	}
	return present
}

fn components_order_violation(present [][]utils.AstNode) ?[]utils.AstNode {
	if present.len < 2 {
		return none
	}
	for preceding_index in 0 .. present.len - 1 {
		preceding := present[preceding_index]
		if preceding.len == 0 {
			continue
		}
		for succeeding_index in preceding_index + 1 .. present.len {
			for succeeding in present[succeeding_index] {
				for first in preceding {
					if first.source_range.begin_pos >= succeeding.source_range.begin_pos {
						return [first, succeeding]
					}
				}
			}
		}
	}
	return none
}

fn components_order_state(present [][]utils.AstNode, node utils.AstNode) ?(int, int, []utils.AstNode) {
	for group_index, group in present {
		for node_index, candidate in group {
			if candidate.source_range.begin_pos == node.source_range.begin_pos && candidate.source_range.end_pos == node.source_range.end_pos {
				return group_index, node_index, group
			}
		}
	}
	return none
}

fn components_order_remove_left_space(source string, node utils.AstNode) (int, int) {
	mut start := node.source_range.begin_pos
	for start > 0 && source[start - 1].is_space() {
		start--
	}
	return start, node.source_range.end_pos
}

fn components_order_reorder(source string, present [][]utils.AstNode, node1 utils.AstNode,
	node2 utils.AstNode) string {
	order_index, current_index, preceding := components_order_state(present, node1) or {
		return source
	}
	mut target := node2
	mut insert_after := false
	mut line_breaks := '\n'
	if current_index > 0 {
		target = preceding[current_index - 1]
		insert_after = true
		line_breaks = if target.source.contains('\n') { '\n\n' } else { '\n' }
	} else {
		line_breaks = if order_index > 8 { '\n\n' } else { '\n' }
	}
	indentation := ' '.repeat(target.source_range.column)
	insertion := if insert_after {
		line_breaks + indentation + node1.source
	} else {
		node1.source + line_breaks + indentation
	}
	insertion_position := if insert_after {
		target.source_range.end_pos
	} else {
		target.source_range.begin_pos
	}
	remove_begin, remove_end := components_order_remove_left_space(source, node1)
	mut without := source[..remove_begin] + source[remove_end..]
	adjusted_position := if insertion_position > remove_end {
		insertion_position - (remove_end - remove_begin)
	} else {
		insertion_position
	}
	without = without[..adjusted_position] + insertion + without[adjusted_position..]
	return without
}

fn components_order_swap_outer_inner(source string, outer utils.AstNode) string {
	lines := outer.source.split('\n')
	if lines.len < 2 {
		return source
	}
	mut replacement_lines := []string{}
	replacement_lines << lines[1]
	replacement_lines << lines[0]
	if lines.len > 2 {
		replacement_lines << lines[2..]
	}
	replacement := replacement_lines.join('\n')
	return source[..outer.source_range.begin_pos] + replacement + source[outer.source_range.end_pos..]
}

fn components_order_order_offense(source string, present [][]utils.AstNode, node1 utils.AstNode,
	node2 utils.AstNode) ComponentsOrderOffense {
	line1 := components_order_line(source, node1.source_range.begin_pos)
	line2 := components_order_line(source, node2.source_range.begin_pos)
	name1 := components_order_component_name(node1)
	name2 := components_order_component_name(node2)
	return ComponentsOrderOffense{
		node_name: name1
		other_name: name2
		line: line1
		other_line: line2
		begin_pos: node1.source_range.begin_pos
		end_pos: node1.source_range.end_pos
		message: '`${name1}` (line ${line1}) should be put before `${name2}` (line ${line2})'
		corrected: components_order_reorder(source, present, node1, node2)
	}
}

fn components_order_message_offense(source string, node utils.AstNode, message string,
	corrected string) ComponentsOrderOffense {
	return ComponentsOrderOffense{
		node_name: node.name
		line: components_order_line(source, node.source_range.begin_pos)
		begin_pos: node.source_range.begin_pos
		end_pos: node.source_range.end_pos
		message: message
		corrected: corrected
	}
}

fn components_order_check_order(source string, rules [][]ComponentsOrderRule, body utils.AstNode) ([][]utils.AstNode, ?ComponentsOrderOffense) {
	present := components_order_present(rules, body)
	violating := components_order_violation(present) or { return present, none }
	return present, components_order_order_offense(source, present, violating[0], violating[1])
}

fn components_order_depends_on_node(node utils.AstNode) bool {
	if node.kind == 'method_call' && node.name == 'depends_on' && !node.has_receiver {
		return true
	}
	if node.name == 'if' {
		trimmed := node.source.trim_space()
		return trimmed.contains('depends_on ') || trimmed.contains('depends_on(')
	}
	return false
}

fn components_order_conditional_depends_on(source string, node utils.AstNode) bool {
	if node.name != 'if' {
		return false
	}
	lines := source.split('\n')
	start_line := components_order_line(source, node.source_range.begin_pos) - 1
	if start_line < 0 || start_line >= lines.len {
		return false
	}
	indent := lines[start_line].len - lines[start_line].trim_left(' \t').len
	mut has_depends_on := false
	for index := start_line + 1; index < lines.len; index++ {
		trimmed := lines[index].trim_space()
		line_indent := lines[index].len - lines[index].trim_left(' \t').len
		if line_indent == indent && trimmed == 'end' {
			return has_depends_on
		}
		if line_indent == indent && (trimmed == 'else' || trimmed.starts_with('elsif ')) {
			return false
		}
		if line_indent == indent + 2 && (trimmed.starts_with('depends_on ') || trimmed.starts_with('depends_on(')) {
			has_depends_on = true
		}
	}
	return false
}

fn components_order_direct_method_names(block utils.AstNode) [][]string {
	if !block.source.contains('\n') || !block.source.contains('\n${' '.repeat(block.source_range.column + 2)}if ') {
		mut names := []string{}
		for child in block.children {
			if child.kind != 'method_call' && child.kind != 'block_call' {
				continue
			}
			if child.name == 'patch' || components_order_on_system_methods().contains(child.name) {
				continue
			}
			names << child.name
		}
		return [names]
	}
	lines := block.source.split('\n')
	mut branches := [][]string{cap: 2}
	mut current := []string{}
	mut branch_indent := -1
	for line in lines[1..lines.len - 1] {
		trimmed := line.trim_space()
		if trimmed.starts_with('if ') || trimmed.starts_with('unless ') {
			branch_indent = line.len - line.trim_left(' \t').len + 2
			continue
		}
		if trimmed == 'else' || trimmed.starts_with('elsif ') {
			branches << current
			current = []string{}
			continue
		}
		indent := line.len - line.trim_left(' \t').len
		if branch_indent >= 0 && indent == branch_indent && trimmed != '' && trimmed != 'end' {
			if trimmed.contains(' = ') && !trimmed.starts_with('url ') {
				continue
			}
			name := trimmed.all_before(' ').all_before('(')
			if name != 'patch' && !components_order_on_system_methods().contains(name) {
				current << name
			}
		}
	}
	branches << current
	return branches
}

fn components_order_allowed_resource_methods(names []string) bool {
	return names.len == 0 || names == ['url', 'sha256'] || names == ['url', 'mirror', 'sha256'] || names == [
		'url',
		'version',
		'sha256',
	] || names == ['url', 'mirror', 'version', 'sha256']
}

fn components_order_check_system(source string, block utils.AstNode, mut offenses []ComponentsOrderOffense) {
	children := block.children
	if children.len == 1 && children[0].kind == 'block_call' && !components_order_on_system_methods().contains(children[0].name) && children[0].name != 'fails_with' {
		message := 'Nest `${block.name}` blocks inside `${children[0].name}` blocks when there is only one inner block.'
		offenses << components_order_message_offense(source, block, message, components_order_swap_outer_inner(source, block))
	}
	present, order_offense := components_order_check_order(source, components_order_formula_block_precedence(), block)
	_ = present
	if offense := order_offense {
		offenses << offense
	}
	allowed := ['livecheck', 'keg_only', 'disable!', 'deprecate!', 'depends_on', 'conflicts_with',
		'fails_with', 'resource', 'patch', 'pour_bottle?']
	for child in children {
		if child.kind != 'method_call' && child.kind != 'block_call' {
			continue
		}
		if components_order_depends_on_node(child) || components_order_conditional_depends_on(source, child) || allowed.contains(child.name) || components_order_on_system_methods().contains(child.name) {
			continue
		}
		mut all_allowed := allowed.clone()
		all_allowed << components_order_on_system_methods()
		quoted := all_allowed.map('`${it}`')
		message := '`${block.name}` cannot include `${child.name}`. Only ${quoted[..quoted.len - 1].join(', ')} and ${quoted.last()} are allowed.'
		offenses << components_order_message_offense(source, child, message, source)
	}
}

fn components_order_next_order_correction(source string) ?string {
	body := components_order_body(source) or { return none }
	_, body_offense := components_order_check_order(source, components_order_formula_precedence(), body)
	if offense := body_offense {
		return offense.corrected
	}
	for head in components_order_find_blocks(body, 'head') {
		_, head_offense := components_order_check_order(source, components_order_formula_precedence(), head)
		if offense := head_offense {
			return offense.corrected
		}
	}
	for method in components_order_on_system_methods() {
		blocks := components_order_find_blocks(body, method)
		if blocks.len > 0 {
			_, system_offense := components_order_check_order(source, components_order_formula_block_precedence(), blocks[0])
			if offense := system_offense {
				return offense.corrected
			}
		}
	}
	for resource in components_order_find_blocks(body, 'resource') {
		_, resource_offense := components_order_check_order(source, components_order_formula_precedence(), resource)
		if offense := resource_offense {
			return offense.corrected
		}
	}
	return none
}

fn components_order_complete_correction(source string) string {
	mut corrected := source
	for _ in 0 .. 64 {
		next := components_order_next_order_correction(corrected) or { break }
		if next == corrected {
			break
		}
		corrected = next
	}
	return corrected
}

pub fn analyze_components_order(source string) ComponentsOrderAnalysis {
	body := components_order_body(source) or {
		return ComponentsOrderAnalysis{ source: source, corrected: source }
	}
	mut offenses := []ComponentsOrderOffense{}
	present, body_offense := components_order_check_order(source, components_order_formula_precedence(), body)
	if offense := body_offense {
		offenses << offense
	}
	for head in components_order_find_blocks(body, 'head') {
		_, head_offense := components_order_check_order(source, components_order_formula_precedence(), head)
		if offense := head_offense {
			offenses << offense
		}
	}
	for method in components_order_on_system_methods() {
		blocks := components_order_find_blocks(body, method)
		if blocks.len > 1 {
			offenses << components_order_message_offense(source, blocks[1], 'There can only be one `${method}` block in a formula.', source)
		}
		if blocks.len > 0 {
			components_order_check_system(source, blocks[0], mut offenses)
		}
	}
	for resource in components_order_find_blocks(body, 'resource') {
		_, resource_offense := components_order_check_order(source, components_order_formula_precedence(), resource)
		if offense := resource_offense {
			offenses << offense
		}
		for method in components_order_on_system_methods() {
			blocks := components_order_find_blocks(resource, method)
			for block in blocks {
				for names in components_order_direct_method_names(block) {
					if !components_order_allowed_resource_methods(names) {
						message := '`${method}` blocks within `resource` blocks must contain at least `url` and `sha256` and at most `url`, `mirror`, `version` and `sha256` (in order).'
						offenses << components_order_message_offense(source, block, message, source)
						break
					}
				}
			}
			if blocks.len > 1 {
				offenses << components_order_message_offense(source, resource, 'There can only be one `${method}` block in a resource block.', source)
			}
		}
	}
	corrected := if offenses.len > 0 && offenses[0].corrected != '' {
		if offenses[0].other_name != '' {
			components_order_complete_correction(offenses[0].corrected)
		} else {
			offenses[0].corrected
		}
	} else {
		source
	}
	return ComponentsOrderAnalysis{
		source: source
		present_components: present
		offenses: offenses
		corrected: corrected
	}
}

fn components_order_offense_value(offense ComponentsOrderOffense) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::Offense'
		repr: offense.message
		map_data: {
			'message':    ruby.string_value(offense.message)
			'node':       ruby.string_value(offense.node_name)
			'other':      ruby.string_value(offense.other_name)
			'line':       ruby.int_value(offense.line)
			'other_line': ruby.int_value(offense.other_line)
			'corrected':  ruby.string_value(offense.corrected)
		}
		attributes: {
			'begin_pos': offense.begin_pos.str()
			'end_pos':   offense.end_pos.str()
		}
	}
}

fn components_order_analysis_value(analysis ComponentsOrderAnalysis) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::FormulaAudit::ComponentsOrder::Analysis'
		repr: analysis.source
		array_data: analysis.offenses.map(components_order_offense_value(it))
		map_data: {
			'offenses':  ruby.array_value(analysis.offenses.map(components_order_offense_value(it)))
			'corrected': ruby.string_value(analysis.corrected)
		}
	}
}

fn components_order_arg_source(args []ruby.Value) string {
	return if args.len > 0 {
		args[0].as_string()
	} else {
		'class Foo < Formula\nend\n'
	}
}

// Ruby method `initialize(config = nil, options = nil)` at line 18.
pub fn ruby_components_order_l18_d1_initialize(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.Value{
		type_name: 'RuboCop::Cop::FormulaAudit::ComponentsOrder'
		repr: '#<RuboCop::Cop::FormulaAudit::ComponentsOrder>'
		map_data: {
			'present_components': ruby.Value{ type_name: 'NilClass', repr: 'nil' }
			'offensive_nodes':    ruby.Value{ type_name: 'NilClass', repr: 'nil' }
		}
	}
}

// Ruby method `audit_formula(formula_nodes)` at line 25.
pub fn ruby_components_order_l25_d2_audit_formula(args ...ruby.Value) ruby.Value {
	return components_order_analysis_value(analyze_components_order(components_order_arg_source(args)))
}

// Ruby method `check_block_component_order(component_precedence_list, block)` at line 135.
pub fn ruby_components_order_l135_d3_check_block_component_order(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	return ruby.array_value(analysis.offenses.map(components_order_offense_value(it)))
}

// Ruby method `check_on_system_block_content(component_precedence_list, on_system_block)` at line 146.
pub fn ruby_components_order_l146_d4_check_on_system_block_content(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	return ruby.array_value(analysis.offenses.map(components_order_offense_value(it)))
}

// Ruby method `reorder_components(corrector, node1, node2)` at line 194.
pub fn ruby_components_order_l194_d5_reorder_components(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	return ruby.string_value(analysis.corrected)
}

// Ruby method `get_state(node1)` at line 217.
pub fn ruby_components_order_l217_d6_get_state(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	requested_name := if args.len > 1 {
		args[1].attributes['name'] or { args[1].as_string() }
	} else {
		''
	}
	requested_occurrence := if args.len > 2 && args[2].type_name == 'Integer' {
		int(args[2].int_data)
	} else {
		0
	}
	for group_index, group in analysis.present_components {
		mut occurrence := 0
		for node_index, node in group {
			if requested_name != '' && node.name != requested_name {
				continue
			}
			if occurrence != requested_occurrence {
				occurrence++
				continue
			}
			return ruby.array_value([
				ruby.int_value(group_index),
				ruby.int_value(node_index),
				ruby.array_value(group.map(utils.ast_node_value(it))),
			])
		}
	}
	return ruby.Value{ type_name: 'RuntimeError', repr: 'Could not find node1 in present_components' }
}

// Ruby method `check_order(component_precedence_list, body_node)` at line 230.
pub fn ruby_components_order_l230_d7_check_order(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	return ruby.Value{
		type_name: 'ComponentsOrder::CheckOrder'
		array_data: analysis.offenses.map(components_order_offense_value(it))
		map_data: {
			'present_components': ruby.array_value(analysis.present_components.map(ruby.array_value(it.map(utils.ast_node_value(it)))))
			'offensive_nodes':    ruby.array_value(analysis.offenses.map(components_order_offense_value(it)))
		}
	}
}

// Ruby method `component_problem(component1, component2)` at line 261.
pub fn ruby_components_order_l261_d8_component_problem(args ...ruby.Value) ruby.Value {
	analysis := analyze_components_order(components_order_arg_source(args))
	return if analysis.offenses.len > 0 {
		components_order_offense_value(analysis.offenses[0])
	} else {
		ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby def_node_matcher `def_node_matcher :depends_on_node?, <<~EOS` at line 273.
pub fn ruby_components_order_l273_d9_depends_on_node(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	source := args[0].as_string()
	trimmed_source := source.trim_space()
	if trimmed_source.starts_with('if ') {
		conditional := utils.AstNode{
			kind: 'method_call'
			name: 'if'
			source: source
			source_range: utils.AstRange{ begin_pos: 0, end_pos: source.len, column: 0 }
		}
		return ruby.bool_value(components_order_conditional_depends_on(source, conditional))
	}
	_, node := utils.ast_process_source(source)
	mut candidate := node
	if node.kind == 'class' && node.children.len > 0 {
		candidate = node.children[0]
	}
	return ruby.bool_value(components_order_depends_on_node(candidate))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ast_constants"
// 5: require "rubocops/extend/formula_cop"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop checks for correct order of components in formulae.
// 11:       #
// 12:       # - `component_precedence_list` has component hierarchy in a nested list
// 13:       #   where each sub array contains components' details which are at same precedence level
// 14:       class ComponentsOrder < FormulaCop
// 15:         extend AutoCorrector
// 16:
// 17:         sig { params(config: T.nilable(RuboCop::Config), options: T.nilable(T::Hash[Symbol, T.anything])).void }
// 18:         def initialize(config = nil, options = nil)
// 19:           super
// 20:           @present_components = T.let(nil, T.nilable(T::Array[T::Array[RuboCop::AST::Node]]))
// 21:           @offensive_nodes = T.let(nil, T.nilable(T::Array[RuboCop::AST::Node]))
// 22:         end
// 23:
// 24:         sig { override.params(formula_nodes: FormulaNodes).void }
// 25:         def audit_formula(formula_nodes)
// 26:           return if (body_node = formula_nodes.body_node).nil?
// 27:
// 28:           @present_components, @offensive_nodes = check_order(FORMULA_COMPONENT_PRECEDENCE_LIST, body_node)
// 29:
// 30:           component_problem @offensive_nodes.fetch(0), @offensive_nodes.fetch(1) if @offensive_nodes
// 31:
// 32:           component_precedence_list = [
// 33:             [{ name: :depends_on, type: :method_call }],
// 34:             [{ name: :resource, type: :block_call }],
// 35:             [{ name: :patch, type: :method_call }, { name: :patch, type: :block_call }],
// 36:           ]
// 37:
// 38:           head_blocks = find_blocks(body_node, :head)
// 39:           head_blocks.each do |head_block|
// 40:             check_block_component_order(FORMULA_COMPONENT_PRECEDENCE_LIST, head_block)
// 41:           end
// 42:
// 43:           on_system_methods.each do |on_method|
// 44:             on_method_blocks = find_blocks(body_node, on_method)
// 45:             next if on_method_blocks.empty?
// 46:
// 47:             if on_method_blocks.length > 1
// 48:               @offensive_node = on_method_blocks.second
// 49:               problem "There can only be one `#{on_method}` block in a formula."
// 50:             end
// 51:
// 52:             check_on_system_block_content(component_precedence_list, on_method_blocks.fetch(0))
// 53:           end
// 54:
// 55:           resource_blocks = find_blocks(body_node, :resource)
// 56:           resource_blocks.each do |resource_block|
// 57:             check_block_component_order(FORMULA_COMPONENT_PRECEDENCE_LIST, resource_block)
// 58:
// 59:             on_system_blocks = {}
// 60:
// 61:             on_system_methods.each do |on_method|
// 62:               on_system_blocks[on_method] = find_blocks(resource_block.body, on_method)
// 63:             end
// 64:
// 65:             if on_system_blocks.empty?
// 66:               # Found nothing. Try without .body as depending on the code,
// 67:               # on_{system} might be in .body or not ...
// 68:               on_system_methods.each do |on_method|
// 69:                 on_system_blocks[on_method] = find_blocks(resource_block, on_method)
// 70:               end
// 71:             end
// 72:             next if on_system_blocks.empty?
// 73:
// 74:             @offensive_node = resource_block
// 75:
// 76:             on_system_bodies = T.let([], T::Array[[RuboCop::AST::BlockNode, RuboCop::AST::Node]])
// 77:
// 78:             on_system_blocks.each_value do |blocks|
// 79:               blocks.each do |on_system_block|
// 80:                 on_system_body = on_system_block.body
// 81:                 branches = on_system_body.if_type? ? on_system_body.branches : [on_system_body]
// 82:                 on_system_bodies += branches.map { |branch| [on_system_block, branch] }
// 83:               end
// 84:             end
// 85:
// 86:             message = T.let(nil, T.nilable(String))
// 87:             allowed_methods = [
// 88:               [:url, :sha256],
// 89:               [:url, :mirror, :sha256],
// 90:               [:url, :version, :sha256],
// 91:               [:url, :mirror, :version, :sha256],
// 92:             ]
// 93:             minimum_methods = allowed_methods.first.map { |m| "`#{m}`" }.to_sentence
// 94:             maximum_methods = allowed_methods.last.map { |m| "`#{m}`" }.to_sentence
// 95:
// 96:             on_system_bodies.each do |on_system_block, on_system_body|
// 97:               method_name = on_system_block.method_name
// 98:               child_nodes = on_system_body.begin_type? ? on_system_body.child_nodes : [on_system_body]
// 99:               if child_nodes.all? { |n| n.send_type? || n.block_type? || n.lvasgn_type? }
// 100:                 method_names = child_nodes.filter_map do |node|
// 101:                   next if node.lvasgn_type?
// 102:                   next if node.method_name == :patch
// 103:                   next if on_system_methods.include? node.method_name
// 104:
// 105:                   node.method_name
// 106:                 end
// 107:                 next if method_names.empty? || allowed_methods.include?(method_names)
// 108:               end
// 109:               offending_node(on_system_block)
// 110:               message = "`#{method_name}` blocks within `resource` blocks must contain at least " \
// 111:                         "#{minimum_methods} and at most #{maximum_methods} (in order)."
// 112:               break
// 113:             end
// 114:
// 115:             if message
// 116:               problem message
// 117:               next
// 118:             end
// 119:
// 120:             on_system_blocks.each do |on_method, blocks|
// 121:               if blocks.length > 1
// 122:                 problem "There can only be one `#{on_method}` block in a resource block."
// 123:                 next
// 124:               end
// 125:             end
// 126:           end
// 127:         end
// 128:
// 129:         sig {
// 130:           params(
// 131:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 132:             block:                     RuboCop::AST::BlockNode,
// 133:           ).void
// 134:         }
// 135:         def check_block_component_order(component_precedence_list, block)
// 136:           @present_components, offensive_node = check_order(component_precedence_list, block.body)
// 137:           component_problem(*offensive_node) if offensive_node
// 138:         end
// 139:
// 140:         sig {
// 141:           params(
// 142:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 143:             on_system_block:           RuboCop::AST::BlockNode,
// 144:           ).void
// 145:         }
// 146:         def check_on_system_block_content(component_precedence_list, on_system_block)
// 147:           if on_system_block.body.block_type? && !on_system_methods.include?(on_system_block.body.method_name) &&
// 148:              on_system_block.body.method_name != :fails_with
// 149:             offending_node(on_system_block)
// 150:             problem "Nest `#{on_system_block.method_name}` blocks inside `#{on_system_block.body.method_name}` " \
// 151:                     "blocks when there is only one inner block." do |corrector|
// 152:               original_source = on_system_block.source.split("\n")
// 153:               new_source = [original_source.second, original_source.first, *original_source.drop(2)]
// 154:               corrector.replace(on_system_block.source_range, new_source.join("\n"))
// 155:             end
// 156:           end
// 157:           on_system_allowed_methods = %w[
// 158:             livecheck
// 159:             keg_only
// 160:             disable!
// 161:             deprecate!
// 162:             depends_on
// 163:             conflicts_with
// 164:             fails_with
// 165:             resource
// 166:             patch
// 167:             pour_bottle?
// 168:           ]
// 169:           on_system_allowed_methods += on_system_methods.map(&:to_s)
// 170:           @present_components, offensive_node = check_order(component_precedence_list, on_system_block.body)
// 171:           component_problem(*offensive_node) if offensive_node
// 172:           child_nodes = on_system_block.body.begin_type? ? on_system_block.body.child_nodes : [on_system_block.body]
// 173:           child_nodes.each do |child|
// 174:             valid_node = depends_on_node?(child)
// 175:             # Check for RuboCop::AST::SendNode and RuboCop::AST::BlockNode instances
// 176:             # only, as we are checking the method_name for `patch`, `resource`, etc.
// 177:             method_type = child.send_type? || child.block_type?
// 178:             next unless method_type
// 179:
// 180:             valid_node ||= on_system_allowed_methods.include? child.method_name.to_s
// 181:
// 182:             @offensive_node = child
// 183:             next if valid_node
// 184:
// 185:             problem "`#{on_system_block.method_name}` cannot include `#{child.method_name}`. " \
// 186:                     "Only #{on_system_allowed_methods.map { |m| "`#{m}`" }.to_sentence} are allowed."
// 187:           end
// 188:         end
// 189:
// 190:         # Reorder two nodes in the source, using the corrector instance in autocorrect method.
// 191:         # Components of same type are grouped together when rewriting the source.
// 192:         # Linebreaks are introduced if components are of two different methods/blocks/multilines.
// 193:         sig { params(corrector: RuboCop::Cop::Corrector, node1: RuboCop::AST::Node, node2: RuboCop::AST::Node).void }
// 194:         def reorder_components(corrector, node1, node2)
// 195:           # order_idx : node1's index in component_precedence_list
// 196:           # curr_p_idx: node1's index in preceding_comp_arr
// 197:           # preceding_comp_arr: array containing components of same type
// 198:           order_idx, curr_p_idx, preceding_comp_arr = get_state(node1)
// 199:
// 200:           # curr_p_idx.positive? means node1 needs to be grouped with its own kind
// 201:           if curr_p_idx.positive?
// 202:             node2 = preceding_comp_arr.fetch(curr_p_idx - 1)
// 203:             indentation = " " * (start_column(node2) - line_start_column(node2))
// 204:             line_breaks = node2.multiline? ? "\n\n" : "\n"
// 205:             corrector.insert_after(node2.source_range, line_breaks + indentation + node1.source)
// 206:           else
// 207:             indentation = " " * (start_column(node2) - line_start_column(node2))
// 208:             # No line breaks up to version_scheme, order_idx == 8
// 209:             line_breaks = (order_idx > 8) ? "\n\n" : "\n"
// 210:             corrector.insert_before(node2.source_range, node1.source + line_breaks + indentation)
// 211:           end
// 212:           corrector.remove(range_with_surrounding_space(range: node1.source_range, side: :left))
// 213:         end
// 214:
// 215:         # Returns precedence index and component's index to properly reorder and group during autocorrect.
// 216:         sig { params(node1: RuboCop::AST::Node).returns([Integer, Integer, T::Array[RuboCop::AST::Node]]) }
// 217:         def get_state(node1)
// 218:           T.must(@present_components).each_with_index do |comp, idx|
// 219:             return [idx, T.must(comp.index(node1)), comp] if comp.member?(node1)
// 220:           end
// 221:           raise "Could not find node1 in present_components"
// 222:         end
// 223:
// 224:         sig {
// 225:           params(
// 226:             component_precedence_list: T::Array[T::Array[{ name: Symbol, type: Symbol }]],
// 227:             body_node:                 RuboCop::AST::Node,
// 228:           ).returns(T.nilable([T::Array[T::Array[RuboCop::AST::Node]], T::Array[RuboCop::AST::Node]]))
// 229:         }
// 230:         def check_order(component_precedence_list, body_node)
// 231:           present_components = component_precedence_list.map do |components|
// 232:             components.flat_map do |component|
// 233:               case component[:type]
// 234:               when :method_call
// 235:                 find_method_calls_by_name(body_node, component[:name]).to_a
// 236:               when :block_call
// 237:                 find_blocks(body_node, component[:name]).to_a
// 238:               when :method_definition
// 239:                 find_method_def(body_node, component[:name])
// 240:               end
// 241:             end.compact
// 242:           end
// 243:
// 244:           # Check if each present_components is above rest of the present_components
// 245:           offensive_nodes = T.let(nil, T.nilable(T::Array[RuboCop::AST::Node]))
// 246:           present_components.take(present_components.size - 1).each_with_index do |preceding_component, p_idx|
// 247:             next if preceding_component.empty?
// 248:
// 249:             present_components.drop(p_idx + 1).each do |succeeding_component|
// 250:               next if succeeding_component.empty?
// 251:
// 252:               offensive_nodes = check_precedence(preceding_component, succeeding_component)
// 253:               return [present_components, offensive_nodes] if offensive_nodes
// 254:             end
// 255:           end
// 256:           nil
// 257:         end
// 258:
// 259:         # Method to report and correct component precedence violations.
// 260:         sig { params(component1: RuboCop::AST::Node, component2: RuboCop::AST::Node).void }
// 261:         def component_problem(component1, component2)
// 262:           return if tap_style_exception? :components_order_exceptions
// 263:
// 264:           problem "`#{format_component(component1)}` (line #{line_number(component1)}) " \
// 265:                   "should be put before `#{format_component(component2)}` " \
// 266:                   "(line #{line_number(component2)})" do |corrector|
// 267:             reorder_components(corrector, component1, component2)
// 268:           end
// 269:         end
// 270:
// 271:         # Node pattern method to match
// 272:         # `depends_on` variants.
// 273:         def_node_matcher :depends_on_node?, <<~EOS
// 274:           {(if _ (send nil? :depends_on ...) nil?)
// 275:            (send nil? :depends_on ...)}
// 276:         EOS
// 277:       end
// 278:     end
// 279:   end
// 280: end
