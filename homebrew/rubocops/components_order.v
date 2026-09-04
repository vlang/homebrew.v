module rubocops

import ruby
import homebrew.utils

// Translated from Homebrew/brew `rubocops/components_order.rb`.
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
