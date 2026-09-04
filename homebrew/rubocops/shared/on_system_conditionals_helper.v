module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/on_system_conditionals_helper.rb`.
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
