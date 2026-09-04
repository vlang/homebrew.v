module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/on_system_conditionals_helper.rb`.
// The original source is retained below until every stub has a typed V body.
pub const on_system_arch_options = ['arm', 'intel']
pub const on_system_base_os_options = ['macos', 'linux']
pub const on_system_macos_version_options = ['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura',
	'monterey', 'big_sur', 'catalina']

pub struct OnSystemFinding {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct OnSystemAnalysis {
pub:
	findings  []OnSystemFinding
	corrected string
}

pub struct OnSystemMatch {
pub:
	matched     bool
	source      string
	method      string
	argument    string
	operator    string
	version     string
	else_source string
}

struct OnSystemLine {
	start       int
	end         int
	newline_end int
	indent      int
	text        string
}

struct OnSystemIfNode {
	source      string
	condition   string
	body        string
	else_source string
	begin_pos   int
	end_pos     int
	header_end  int
	unless      bool
	indent      int
	line        int
}

fn on_system_lines(source string) []OnSystemLine {
	mut result := []OnSystemLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && text[indent] in [` `, `\t`] {
			indent++
		}
		result << OnSystemLine{
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

fn on_system_matching_end(lines []OnSystemLine, start int) int {
	indent := lines[start].indent
	mut depth := 0
	for index := start + 1; index < lines.len; index++ {
		trimmed := lines[index].text.trim_space()
		if lines[index].indent == indent && trimmed == 'end' {
			if depth == 0 {
				return index
			}
			depth--
		} else if lines[index].indent == indent && (trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('def ') || trimmed.ends_with(' do') || trimmed.contains(' do |')) {
			depth++
		}
	}
	return -1
}

fn on_system_deindent(source string) string {
	lines := source.trim('\n').split('\n')
	mut minimum := 1 << 30
	for line in lines {
		if line.trim_space() == '' {
			continue
		}
		indent := line.len - line.trim_left(' \t').len
		if indent < minimum {
			minimum = indent
		}
	}
	if minimum == 1 << 30 {
		return ''
	}
	return lines.map(if it.len >= minimum { it[minimum..] } else { it.trim_left(' \t') }).join('\n')
}

fn on_system_if_nodes(source string) []OnSystemIfNode {
	lines := on_system_lines(source)
	mut nodes := []OnSystemIfNode{}
	for index, line in lines {
		trimmed := line.text.trim_space()
		unless := trimmed.starts_with('unless ')
		if !trimmed.starts_with('if ') && !unless {
			continue
		}
		closing := on_system_matching_end(lines, index)
		if closing < 0 {
			continue
		}
		keyword_len := if unless { 7 } else { 3 }
		condition := trimmed[keyword_len..].trim_space()
		mut separator := -1
		for candidate := index + 1; candidate < closing; candidate++ {
			if lines[candidate].indent == line.indent && lines[candidate].text.trim_space() == 'else' {
				separator = candidate
				break
			}
		}
		body_end := if separator >= 0 { lines[separator].start } else { lines[closing].start }
		else_begin := if separator >= 0 { lines[separator].newline_end } else { body_end }
		end_pos := lines[closing].start + (lines[closing].text.index('end') or { 0 }) + 3
		nodes << OnSystemIfNode{
			source: source[line.start + line.indent..end_pos]
			condition: condition
			body: on_system_deindent(source[line.newline_end..body_end])
			else_source: on_system_deindent(source[else_begin..lines[closing].start])
			begin_pos: line.start + line.indent
			end_pos: end_pos
			header_end: line.end
			unless: unless
			indent: line.indent
			line: index
		}
	}
	return nodes
}

fn on_system_region_allowed(source string, position int, allowed_methods []string,
	allowed_blocks []string) bool {
	lines := on_system_lines(source)
	mut target_line := 0
	for index, line in lines {
		if position >= line.start && position <= line.end {
			target_line = index
			break
		}
	}
	for index, line in lines {
		if index > target_line {
			break
		}
		trimmed := line.text.trim_space()
		mut name := ''
		mut allowed := false
		if trimmed.starts_with('def ') {
			name = trimmed[4..].all_before('(').all_before(' ').trim_space()
			allowed = name in allowed_methods
		} else if trimmed.ends_with(' do') || trimmed.contains(' do |') {
			name = trimmed.all_before(' do').all_before('(').all_before(' ').trim_space()
			allowed = name in allowed_blocks
		}
		if allowed {
			closing := on_system_matching_end(lines, index)
			if closing >= target_line {
				return true
			}
		}
	}
	return false
}

fn on_system_apply(source string, findings []OnSystemFinding) string {
	mut corrected := source
	mut sorted := findings.filter(it.replacement != '').clone()
	sorted.sort(a.begin_pos > b.begin_pos)
	for finding in sorted {
		corrected = corrected[..finding.begin_pos] + finding.replacement + corrected[finding.end_pos..]
	}
	return corrected
}

fn on_system_analysis(source string, findings []OnSystemFinding) OnSystemAnalysis {
	return OnSystemAnalysis{ findings: findings, corrected: on_system_apply(source, findings) }
}

fn on_system_operator_for_condition(condition string) string {
	return match condition {
		'or_older' { '<=' }
		'or_newer' { '>=' }
		else { '==' }
	}
}

pub fn audit_on_system_blocks(source string, parent_name string, definition bool) OnSystemAnalysis {
	if !source.contains('on_') {
		return on_system_analysis(source, [])
	}
	mut findings := []OnSystemFinding{}
	mut options := on_system_arch_options.clone()
	options << on_system_base_os_options
	options << on_system_macos_version_options
	options << 'system'
	parent_string := if definition { 'def ${parent_name}' } else { '${parent_name} do' }
	for option in options {
		method := 'on_${option}'
		for line in on_system_lines(source) {
			trimmed := line.text.trim_space()
			if !trimmed.starts_with(method) {
				continue
			}
			mut if_statement := if option in on_system_arch_options {
				'if Hardware::CPU.${option}?'
			} else if option in on_system_base_os_options {
				'if OS.${if option == 'macos' { 'mac' } else { 'linux' }}?'
			} else if option == 'system' {
				'if OS.linux? || MacOS.version'
			} else {
				'if MacOS.version'
			}
			arguments := trimmed[method.len..].all_before(' do').trim_space()
			if option in on_system_macos_version_options {
				condition := lines_symbol_argument(arguments)
				if_statement += ' ${on_system_operator_for_condition(condition)} :${option}'
			} else if option == 'system' {
				macos_index := arguments.index('macos:') or { -1 }
				if macos_index >= 0 {
					macos := lines_symbol_argument(arguments[macos_index + 6..])
					parts := macos.split('_or_')
					base := parts[0]
					condition := if parts.len > 1 { 'or_${parts[1]}' } else { '' }
					if_statement += ' ${on_system_operator_for_condition(condition)} :${base}'
				}
			}
			start := line.start + line.indent
			do_index := line.text.index(' do') or { line.text.len }
			end := line.start + do_index + 3
			findings << OnSystemFinding{
				begin_pos: start
				end_pos: end
				message: 'Instead of using `${line.text.trim_space().all_before(' do')}` in `${parent_string}`, use `${if_statement}`.'
				replacement: if_statement
			}
		}
	}
	return on_system_analysis(source, findings)
}

fn lines_symbol_argument(source string) string {
	trimmed := source.trim_space()
	if !trimmed.contains(':') {
		return ''
	}
	mut result := trimmed.all_after(':')
	result = result.all_before(',').all_before(')').trim_space()
	return result
}

fn on_system_if_problem(node OnSystemIfNode, if_statement string, on_method string,
	else_method string, autocorrect bool) OnSystemFinding {
	mut replacement := ''
	if autocorrect && !node.unless {
		replacement = '${on_method} do\n${node.body}\nend'
		if else_method != '' && node.else_source != '' {
			replacement += '\n${else_method} do\n${node.else_source}\nend'
		}
	}
	return OnSystemFinding{
		begin_pos: node.begin_pos
		end_pos: node.end_pos
		message: 'Instead of `${if_statement}`, use `${on_method} do`.'
		replacement: replacement
	}
}

pub fn audit_arch_conditionals(source string, allowed_methods []string,
	allowed_blocks []string) OnSystemAnalysis {
	if !source.contains('Hardware') {
		return on_system_analysis(source, [])
	}
	mut findings := []OnSystemFinding{}
	for node in on_system_if_nodes(source) {
		for arch in on_system_arch_options {
			condition := 'Hardware::CPU.${arch}?'
			if node.condition == condition && !on_system_region_allowed(source, node.begin_pos, allowed_methods, allowed_blocks) {
				findings << on_system_if_problem(node, 'if ${condition}', 'on_${arch}', if arch == 'arm' {
					'on_intel'
				} else {
					'on_arm'
				}, true)
			}
		}
	}
	for method in ['arch', 'arm?', 'intel?'] {
		target := 'Hardware::CPU.${method}'
		for line in on_system_lines(source) {
			mut from := 0
			for from < line.text.len {
				index := line.text.index_after(target, from) or { break }
				position := line.start + index
				if !line.text.trim_space().starts_with('if ${target}') && !on_system_region_allowed(source, position, allowed_methods, allowed_blocks) {
					findings << OnSystemFinding{ begin_pos: position, end_pos: position + target.len, message: 'Instead of `${target}`, use `on_arm` and `on_intel` blocks.' }
				}
				from = index + target.len
			}
		}
	}
	return on_system_analysis(source, findings)
}

pub fn audit_base_os_conditionals(source string, allowed_methods []string,
	allowed_blocks []string) OnSystemAnalysis {
	if !source.contains('OS') {
		return on_system_analysis(source, [])
	}
	mut findings := []OnSystemFinding{}
	for node in on_system_if_nodes(source) {
		for option in on_system_base_os_options {
			method := if option == 'macos' { 'mac?' } else { 'linux?' }
			condition := 'OS.${method}'
			if node.condition == condition && !on_system_region_allowed(source, node.begin_pos, allowed_methods, allowed_blocks) {
				findings << on_system_if_problem(node, 'if ${condition}', 'on_${option}', if option == 'macos' {
					'on_linux'
				} else {
					'on_macos'
				}, true)
			}
		}
	}
	return on_system_analysis(source, findings)
}

fn on_system_version_condition(condition string) ?(string, string) {
	if !condition.starts_with('MacOS.version ') {
		return none
	}
	rest := condition['MacOS.version '.len..]
	for operator in ['==', '<=', '>=', '<', '>', '!='] {
		if rest.starts_with('${operator} :') {
			return operator, rest[operator.len + 2..].trim_space()
		}
	}
	return none
}

pub fn audit_macos_version_conditionals(source string, allowed_methods []string,
	allowed_blocks []string, recommend_on_system bool) OnSystemAnalysis {
	if !source.contains('MacOS') {
		return on_system_analysis(source, [])
	}
	mut findings := []OnSystemFinding{}
	mut covered := []int{}
	for node in on_system_if_nodes(source) {
		operator, version := on_system_version_condition(node.condition) or { continue }
		if version !in on_system_macos_version_options || on_system_region_allowed(source, node.begin_pos, allowed_methods, allowed_blocks) {
			continue
		}
		mut method := 'on_${version}'
		if recommend_on_system && operator == '<' {
			method = 'on_system'
		} else if recommend_on_system && operator == '<=' {
			method = 'on_system :linux, macos: :${version}_or_older'
		} else if operator == '<=' {
			method = 'on_${version} :or_older'
		} else if operator == '>=' {
			method = 'on_${version} :or_newer'
		}
		autocorrect := node.else_source == '' && operator in ['==', '<=', '>=']
		findings << on_system_if_problem(node, 'if MacOS.version ${operator} :${version}', method, '', autocorrect)
		covered << node.line
	}
	for line_index, line in on_system_lines(source) {
		if line_index in covered {
			continue
		}
		trimmed := line.text.trim_space()
		index := trimmed.index('MacOS.version ') or { continue }
		operator, version := on_system_version_condition(trimmed[index..]) or { continue }
		if version in on_system_macos_version_options && !on_system_region_allowed(source, line.start + line.indent + index, allowed_methods, allowed_blocks) {
			text := 'MacOS.version ${operator} :${version}'
			findings << OnSystemFinding{ begin_pos: line.start + line.indent + index, end_pos: line.start + line.indent + index + text.len, message: 'Instead of `${text}`, use `on_{macos_version}` blocks.' }
		}
	}
	return on_system_analysis(source, findings)
}

pub fn audit_macos_references(source string, allowed_methods []string,
	allowed_blocks []string) OnSystemAnalysis {
	if !source.contains('MacOS') && !source.contains('OS') {
		return on_system_analysis(source, [])
	}
	mut findings := []OnSystemFinding{}
	for module_name in ['MacOS', 'OS::Mac'] {
		for line in on_system_lines(source) {
			mut from := 0
			for from < line.text.len {
				index := line.text.index_after(module_name, from) or { break }
				position := line.start + index
				if !on_system_region_allowed(source, position, allowed_methods, allowed_blocks) {
					findings << OnSystemFinding{ begin_pos: position, end_pos: position + module_name.len, message: "Don't use `${module_name}` where it could be called on Linux." }
				}
				from = index + module_name.len
			}
		}
	}
	return on_system_analysis(source, findings)
}

pub fn on_system_node_is_allowed(source string, position int, allowed_methods []string,
	allowed_blocks []string) bool {
	return on_system_region_allowed(source, position, allowed_methods, allowed_blocks)
}

pub fn on_macos_version_method_matches(source string, method string) []OnSystemMatch {
	mut matches := []OnSystemMatch{}
	for line in on_system_lines(source) {
		trimmed := line.text.trim_space().all_before(' do')
		if trimmed == method || trimmed.starts_with('${method} ') {
			argument := lines_symbol_argument(trimmed[method.len..])
			if argument == '' || argument in ['or_newer', 'or_older'] {
				matches << OnSystemMatch{ matched: true, source: trimmed, method: method, argument: argument }
			}
		}
	}
	return matches
}

pub fn on_system_method_matches(source string) []OnSystemMatch {
	mut matches := []OnSystemMatch{}
	for line in on_system_lines(source) {
		trimmed := line.text.trim_space().all_before(' do')
		if trimmed.starts_with('on_system ') && trimmed.contains(':linux') && trimmed.contains('macos:') {
			matches << OnSystemMatch{ matched: true, source: trimmed, method: 'on_system', argument: lines_symbol_argument(trimmed.all_after('macos:')) }
		}
	}
	return matches
}

pub fn hardware_cpu_matches(source string, method string) []OnSystemMatch {
	target := 'Hardware::CPU.${method}'
	mut matches := []OnSystemMatch{}
	for line in on_system_lines(source) {
		if line.text.contains(target) {
			matches << OnSystemMatch{ matched: true, source: target, method: method }
		}
	}
	return matches
}

pub fn macos_version_comparison_matches(source string, version string) []OnSystemMatch {
	mut matches := []OnSystemMatch{}
	for line in on_system_lines(source) {
		trimmed := line.text.trim_space()
		index := trimmed.index('MacOS.version ') or { continue }
		operator, found_version := on_system_version_condition(trimmed[index..]) or { continue }
		if found_version == version {
			matches << OnSystemMatch{ matched: true, source: 'MacOS.version ${operator} :${version}', operator: operator, version: version }
		}
	}
	return matches
}

pub fn if_arch_matches(source string, arch string) []OnSystemMatch {
	return on_system_if_nodes(source).filter(it.condition == 'Hardware::CPU.${arch}').map(OnSystemMatch{ matched: true, source: it.source, method: arch, else_source: it.else_source })
}

pub fn if_base_os_matches(source string, method string) []OnSystemMatch {
	return on_system_if_nodes(source).filter(it.condition == 'OS.${method}').map(OnSystemMatch{ matched: true, source: it.source, method: method, else_source: it.else_source })
}

pub fn if_macos_version_matches(source string, version string) []OnSystemMatch {
	mut matches := []OnSystemMatch{}
	for node in on_system_if_nodes(source) {
		operator, found_version := on_system_version_condition(node.condition) or { continue }
		if found_version == version {
			matches << OnSystemMatch{ matched: true, source: node.source, operator: operator, version: version, else_source: node.else_source }
		}
	}
	return matches
}

fn on_system_analysis_value(analysis OnSystemAnalysis) ruby.Value {
	findings := analysis.findings.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
	}))
	return ruby.map_value({
		'offenses':  ruby.array_value(findings)
		'corrected': ruby.string_value(analysis.corrected)
	})
}

fn on_system_matches_value(matches []OnSystemMatch) ruby.Value {
	return ruby.array_value(matches.map(ruby.structured_value('RuboCop::AST::Node', it.source, {
		'method':      it.method
		'argument':    it.argument
		'operator':    it.operator
		'version':     it.version
		'else_source': it.else_source
	})))
}

// Ruby method `audit_on_system_blocks(body_node, parent_name)` at line 33.
pub fn ruby_on_system_conditionals_helper_l33_d1_audit_on_system_blocks(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'source and parent name are required')
	}
	definition := args.len > 2 && args[2].type_name == 'Bool' && args[2].bool_data
	return on_system_analysis_value(audit_on_system_blocks(args[0].as_string(), args[1].as_string(), definition))
}

// Ruby method `audit_arch_conditionals(body_node, allowed_methods: [], allowed_blocks: [])` at line 95.
pub fn ruby_on_system_conditionals_helper_l95_d2_audit_arch_conditionals(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'source is required')
	}
	methods := if args.len > 1 { args[1].string_array_data.clone() } else { []string{} }
	blocks := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	return on_system_analysis_value(audit_arch_conditionals(args[0].as_string(), methods, blocks))
}

// Ruby method `audit_base_os_conditionals(body_node, allowed_methods: [], allowed_blocks: [])` at line 126.
pub fn ruby_on_system_conditionals_helper_l126_d3_audit_base_os_conditionals(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'source is required')
	}
	methods := if args.len > 1 { args[1].string_array_data.clone() } else { []string{} }
	blocks := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	return on_system_analysis_value(audit_base_os_conditionals(args[0].as_string(), methods, blocks))
}

// Ruby method `audit_macos_version_conditionals(body_node, allowed_methods: [], allowed_blocks: [],` at line 152.
pub fn ruby_on_system_conditionals_helper_l152_d4_audit_macos_version_conditionals(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'source is required')
	}
	methods := if args.len > 1 { args[1].string_array_data.clone() } else { []string{} }
	blocks := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	recommend := args.len < 4 || args[3].type_name != 'Bool' || args[3].bool_data
	return on_system_analysis_value(audit_macos_version_conditionals(args[0].as_string(), methods, blocks, recommend))
}

// Ruby method `audit_macos_references(body_node, allowed_methods: [], allowed_blocks: [])` at line 194.
pub fn ruby_on_system_conditionals_helper_l194_d5_audit_macos_references(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'source is required')
	}
	methods := if args.len > 1 { args[1].string_array_data.clone() } else { []string{} }
	blocks := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	return on_system_analysis_value(audit_macos_references(args[0].as_string(), methods, blocks))
}

// Ruby method `if_statement_problem(if_node, if_statement_string, on_system_method_string,` at line 219.
pub fn ruby_on_system_conditionals_helper_l219_d6_if_statement_problem(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'if source, statement, and method are required')
	}
	nodes := on_system_if_nodes(args[0].as_string())
	if nodes.len == 0 {
		return on_system_analysis_value(on_system_analysis(args[0].as_string(), []))
	}
	else_method := if args.len > 3 { args[3].as_string() } else { '' }
	autocorrect := args.len < 5 || args[4].type_name != 'Bool' || args[4].bool_data
	finding := on_system_if_problem(nodes[0], args[1].as_string(), args[2].as_string(), else_method, autocorrect)
	return on_system_analysis_value(on_system_analysis(args[0].as_string(), [finding]))
}

// Ruby method `node_is_allowed?(node, allowed_methods: [], allowed_blocks: [])` at line 243.
pub fn ruby_on_system_conditionals_helper_l243_d7_node_is_allowed(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	methods := if args.len > 2 { args[2].string_array_data.clone() } else { []string{} }
	blocks := if args.len > 3 { args[3].string_array_data.clone() } else { []string{} }
	return ruby.bool_value(on_system_node_is_allowed(args[0].as_string(), int(args[1].int_data), methods, blocks))
}

// Ruby def_node_matcher `def_node_matcher :on_macos_version_method_call, <<~PATTERN` at line 265.
pub fn ruby_on_system_conditionals_helper_l265_d8_on_macos_version_method_call(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(on_macos_version_method_matches(args[0].as_string(), args[1].as_string()))
}

// Ruby def_node_matcher `def_node_matcher :on_system_method_call, <<~PATTERN` at line 269.
pub fn ruby_on_system_conditionals_helper_l269_d9_on_system_method_call(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(on_system_method_matches(args[0].as_string()))
}

// Ruby def_node_search `def_node_search :hardware_cpu_search, <<~PATTERN` at line 273.
pub fn ruby_on_system_conditionals_helper_l273_d10_hardware_cpu_search(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(hardware_cpu_matches(args[0].as_string(), args[1].as_string()))
}

// Ruby def_node_search `def_node_search :macos_version_comparison_search, <<~PATTERN` at line 277.
pub fn ruby_on_system_conditionals_helper_l277_d11_macos_version_comparison_search(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(macos_version_comparison_matches(args[0].as_string(), args[1].as_string()))
}

// Ruby def_node_search `def_node_search :if_arch_node_search, <<~PATTERN` at line 281.
pub fn ruby_on_system_conditionals_helper_l281_d12_if_arch_node_search(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(if_arch_matches(args[0].as_string(), args[1].as_string()))
}

// Ruby def_node_search `def_node_search :if_base_os_node_search, <<~PATTERN` at line 285.
pub fn ruby_on_system_conditionals_helper_l285_d13_if_base_os_node_search(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(if_base_os_matches(args[0].as_string(), args[1].as_string()))
}

// Ruby def_node_search `def_node_search :if_macos_version_node_search, <<~PATTERN` at line 289.
pub fn ruby_on_system_conditionals_helper_l289_d14_if_macos_version_node_search(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.array_value([]ruby.Value{})
	}
	return on_system_matches_value(if_macos_version_matches(args[0].as_string(), args[1].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_version"
// 5: require "rubocops/shared/helper_functions"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     # This module performs common checks on `on_{system}` blocks in both formulae and casks.
// 10:     module OnSystemConditionalsHelper
// 11:       extend NodePattern::Macros
// 12:       include HelperFunctions
// 13:
// 14:       ARCH_OPTIONS = [:arm, :intel].freeze
// 15:       BASE_OS_OPTIONS = [:macos, :linux].freeze
// 16:       MACOS_VERSION_OPTIONS = T.let(MacOSVersion::SYMBOLS.keys.freeze, T::Array[Symbol])
// 17:       ON_SYSTEM_OPTIONS = T.let(
// 18:         [*ARCH_OPTIONS, *BASE_OS_OPTIONS, *MACOS_VERSION_OPTIONS, :system].freeze,
// 19:         T::Array[Symbol],
// 20:       )
// 21:       MACOS_MODULE_NAMES = ["MacOS", "OS::Mac"].freeze
// 22:
// 23:       MACOS_VERSION_CONDITIONALS = T.let(
// 24:         {
// 25:           "==" => nil,
// 26:           "<=" => :or_older,
// 27:           ">=" => :or_newer,
// 28:         }.freeze,
// 29:         T::Hash[String, T.nilable(Symbol)],
// 30:       )
// 31:
// 32:       sig { params(body_node: RuboCop::AST::Node, parent_name: Symbol).void }
// 33:       def audit_on_system_blocks(body_node, parent_name)
// 34:         return unless body_node.source.include?("on_")
// 35:
// 36:         parent_string = if body_node.def_type?
// 37:           "def #{parent_name}"
// 38:         else
// 39:           "#{parent_name} do"
// 40:         end
// 41:
// 42:         ON_SYSTEM_OPTIONS.each do |on_system_option|
// 43:           on_system_method = :"on_#{on_system_option}"
// 44:           if_statement_string = if ARCH_OPTIONS.include?(on_system_option)
// 45:             "if Hardware::CPU.#{on_system_option}?"
// 46:           elsif BASE_OS_OPTIONS.include?(on_system_option)
// 47:             "if OS.#{(on_system_option == :macos) ? "mac" : "linux"}?"
// 48:           elsif on_system_option == :system
// 49:             "if OS.linux? || MacOS.version"
// 50:           else
// 51:             "if MacOS.version"
// 52:           end
// 53:
// 54:           find_every_method_call_by_name(body_node, on_system_method).each do |on_system_node|
// 55:             if_conditional = ""
// 56:             if MACOS_VERSION_OPTIONS.include? on_system_option
// 57:               on_macos_version_method_call(on_system_node, on_method: on_system_method) do |on_method_parameters|
// 58:                 if on_method_parameters.empty?
// 59:                   if_conditional = " == :#{on_system_option}"
// 60:                 else
// 61:                   if_condition_operator = MACOS_VERSION_CONDITIONALS.key(on_method_parameters.first)
// 62:                   if_conditional = " #{if_condition_operator} :#{on_system_option}"
// 63:                 end
// 64:               end
// 65:             elsif on_system_option == :system
// 66:               on_system_method_call(on_system_node) do |macos_symbol|
// 67:                 base_os, condition = macos_symbol.to_s.split(/_(?=or_)/).map(&:to_sym)
// 68:                 if_condition_operator = MACOS_VERSION_CONDITIONALS.key(condition)
// 69:                 if_conditional = " #{if_condition_operator} :#{base_os}"
// 70:               end
// 71:             end
// 72:
// 73:             @offensive_node = on_system_node
// 74:             problem "Instead of using `#{on_system_node.source}` in `#{parent_string}`, " \
// 75:                     "use `#{if_statement_string}#{if_conditional}`." do |corrector|
// 76:               block_node = @offensive_node.parent
// 77:               next if block_node.type != :block
// 78:
// 79:               # TODO: could fix corrector to handle this but punting for now.
// 80:               next if block_node.single_line?
// 81:
// 82:               source_range = @offensive_node.source_range.join(@offensive_node.parent.loc.begin)
// 83:               corrector.replace(source_range, "#{if_statement_string}#{if_conditional}")
// 84:             end
// 85:           end
// 86:         end
// 87:       end
// 88:
// 89:       sig {
// 90:         params(
// 91:           body_node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 92:           allowed_blocks: T::Array[Symbol]
// 93:         ).void
// 94:       }
// 95:       def audit_arch_conditionals(body_node, allowed_methods: [], allowed_blocks: [])
// 96:         return unless body_node.source.include?("Hardware")
// 97:
// 98:         ARCH_OPTIONS.each do |arch_option|
// 99:           else_method = (arch_option == :arm) ? :on_intel : :on_arm
// 100:           if_arch_node_search(body_node, arch: :"#{arch_option}?") do |if_node, else_node|
// 101:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 102:
// 103:             if_statement_problem(if_node, "if Hardware::CPU.#{arch_option}?", "on_#{arch_option}",
// 104:                                  else_method:, else_node:)
// 105:           end
// 106:         end
// 107:
// 108:         [:arch, :arm?, :intel?].each do |method|
// 109:           hardware_cpu_search(body_node, method:) do |method_node|
// 110:             # These should already be caught by `if_arch_node_search`
// 111:             next if method_node.parent.source.start_with? "if #{method_node.source}"
// 112:             next if node_is_allowed?(method_node, allowed_methods:, allowed_blocks:)
// 113:
// 114:             offending_node(method_node)
// 115:             problem "Instead of `#{method_node.source}`, use `on_arm` and `on_intel` blocks."
// 116:           end
// 117:         end
// 118:       end
// 119:
// 120:       sig {
// 121:         params(
// 122:           body_node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 123:           allowed_blocks: T::Array[Symbol]
// 124:         ).void
// 125:       }
// 126:       def audit_base_os_conditionals(body_node, allowed_methods: [], allowed_blocks: [])
// 127:         return unless body_node.source.include?("OS")
// 128:
// 129:         BASE_OS_OPTIONS.each do |base_os_option|
// 130:           os_method, else_method = if base_os_option == :macos
// 131:             [:mac?, :on_linux]
// 132:           else
// 133:             [:linux?, :on_macos]
// 134:           end
// 135:           if_base_os_node_search(body_node, base_os: os_method) do |if_node, else_node|
// 136:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 137:
// 138:             if_statement_problem(if_node, "if OS.#{os_method}", "on_#{base_os_option}",
// 139:                                  else_method:, else_node:)
// 140:           end
// 141:         end
// 142:       end
// 143:
// 144:       sig {
// 145:         params(
// 146:           body_node:           RuboCop::AST::Node,
// 147:           allowed_methods:     T::Array[Symbol],
// 148:           allowed_blocks:      T::Array[Symbol],
// 149:           recommend_on_system: T::Boolean,
// 150:         ).void
// 151:       }
// 152:       def audit_macos_version_conditionals(body_node, allowed_methods: [], allowed_blocks: [],
// 153:                                            recommend_on_system: true)
// 154:         return unless body_node.source.include?("MacOS")
// 155:
// 156:         MACOS_VERSION_OPTIONS.each do |macos_version_option|
// 157:           if_macos_version_node_search(body_node, os_version: macos_version_option) do |if_node, operator, else_node|
// 158:             next if node_is_allowed?(if_node, allowed_methods:, allowed_blocks:)
// 159:
// 160:             else_node = T.let(else_node, T.nilable(RuboCop::AST::Node))
// 161:             autocorrect = else_node.blank? && MACOS_VERSION_CONDITIONALS.key?(operator.to_s)
// 162:             on_system_method_string = if recommend_on_system && operator == :<
// 163:               "on_system"
// 164:             elsif recommend_on_system && operator == :<=
// 165:               "on_system :linux, macos: :#{macos_version_option}_or_older"
// 166:             elsif operator != :== && MACOS_VERSION_CONDITIONALS.key?(operator.to_s)
// 167:               "on_#{macos_version_option} :#{MACOS_VERSION_CONDITIONALS[operator.to_s]}"
// 168:             else
// 169:               "on_#{macos_version_option}"
// 170:             end
// 171:
// 172:             if_statement_problem(if_node, "if MacOS.version #{operator} :#{macos_version_option}",
// 173:                                  on_system_method_string, autocorrect:)
// 174:           end
// 175:
// 176:           macos_version_comparison_search(body_node, os_version: macos_version_option) do |method_node|
// 177:             # These should already be caught by `if_macos_version_node_search`
// 178:             next if method_node.parent.source.start_with? "if #{method_node.source}"
// 179:             next if node_is_allowed?(method_node, allowed_methods:, allowed_blocks:)
// 180:
// 181:             offending_node(method_node)
// 182:             problem "Instead of `#{method_node.source}`, use `on_{macos_version}` blocks."
// 183:           end
// 184:         end
// 185:       end
// 186:
// 187:       sig {
// 188:         params(
// 189:           body_node:       RuboCop::AST::Node,
// 190:           allowed_methods: T::Array[Symbol],
// 191:           allowed_blocks:  T::Array[Symbol],
// 192:         ).void
// 193:       }
// 194:       def audit_macos_references(body_node, allowed_methods: [], allowed_blocks: [])
// 195:         return if !body_node.source.include?("MacOS") && !body_node.source.include?("OS")
// 196:
// 197:         MACOS_MODULE_NAMES.each do |macos_module_name|
// 198:           find_const(body_node, macos_module_name) do |node|
// 199:             next if node_is_allowed?(node, allowed_methods:, allowed_blocks:)
// 200:
// 201:             offending_node(node)
// 202:             problem "Don't use `#{macos_module_name}` where it could be called on Linux."
// 203:           end
// 204:         end
// 205:       end
// 206:
// 207:       private
// 208:
// 209:       sig {
// 210:         params(
// 211:           if_node:                 RuboCop::AST::IfNode,
// 212:           if_statement_string:     String,
// 213:           on_system_method_string: String,
// 214:           else_method:             T.nilable(Symbol),
// 215:           else_node:               T.nilable(RuboCop::AST::Node),
// 216:           autocorrect:             T::Boolean,
// 217:         ).void
// 218:       }
// 219:       def if_statement_problem(if_node, if_statement_string, on_system_method_string,
// 220:                                else_method: nil, else_node: nil, autocorrect: true)
// 221:         offending_node(if_node)
// 222:         problem "Instead of `#{if_statement_string}`, use `#{on_system_method_string} do`." do |corrector|
// 223:           next unless autocorrect
// 224:           # TODO: could fix corrector to handle this but punting for now.
// 225:           next if if_node.unless?
// 226:
// 227:           if else_method.present? && else_node.present?
// 228:             corrector.replace(if_node.source_range,
// 229:                               "#{on_system_method_string} do\n#{if_node.body.source}\nend\n" \
// 230:                               "#{else_method} do\n#{else_node.source}\nend")
// 231:           else
// 232:             corrector.replace(if_node.source_range, "#{on_system_method_string} do\n#{if_node.body.source}\nend")
// 233:           end
// 234:         end
// 235:       end
// 236:
// 237:       sig {
// 238:         params(
// 239:           node: RuboCop::AST::Node, allowed_methods: T::Array[Symbol],
// 240:           allowed_blocks: T::Array[Symbol]
// 241:         ).returns(T::Boolean)
// 242:       }
// 243:       def node_is_allowed?(node, allowed_methods: [], allowed_blocks: [])
// 244:         # TODO: check to see if it's legal
// 245:         valid = T.let(false, T::Boolean)
// 246:         node.each_ancestor do |ancestor|
// 247:           valid_method_names = case ancestor.type
// 248:           when :def
// 249:             allowed_methods
// 250:           when :block
// 251:             allowed_blocks
// 252:           else
// 253:             next
// 254:           end
// 255:           next unless valid_method_names.include?(ancestor.method_name)
// 256:
// 257:           valid = true
// 258:           break
// 259:         end
// 260:         return true if valid
// 261:
// 262:         false
// 263:       end
// 264:
// 265:       def_node_matcher :on_macos_version_method_call, <<~PATTERN
// 266:         (send nil? %on_method (sym ${:or_newer :or_older})?)
// 267:       PATTERN
// 268:
// 269:       def_node_matcher :on_system_method_call, <<~PATTERN
// 270:         (send nil? :on_system (sym :linux) (hash (pair (sym :macos) (sym $_))))
// 271:       PATTERN
// 272:
// 273:       def_node_search :hardware_cpu_search, <<~PATTERN
// 274:         (send (const (const nil? :Hardware) :CPU) %method)
// 275:       PATTERN
// 276:
// 277:       def_node_search :macos_version_comparison_search, <<~PATTERN
// 278:         (send (send (const nil? :MacOS) :version) {:== :<= :< :>= :> :!=} (sym %os_version))
// 279:       PATTERN
// 280:
// 281:       def_node_search :if_arch_node_search, <<~PATTERN
// 282:         $(if (send (const (const nil? :Hardware) :CPU) %arch) _ $_)
// 283:       PATTERN
// 284:
// 285:       def_node_search :if_base_os_node_search, <<~PATTERN
// 286:         $(if (send (const nil? :OS) %base_os) _ $_)
// 287:       PATTERN
// 288:
// 289:       def_node_search :if_macos_version_node_search, <<~PATTERN
// 290:         $(if (send (send (const nil? :MacOS) :version) ${:== :<= :< :>= :> :!=} (sym %os_version)) _ $_)
// 291:       PATTERN
// 292:     end
// 293:   end
// 294: end
