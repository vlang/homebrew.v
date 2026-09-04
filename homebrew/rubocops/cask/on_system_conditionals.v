module cask

import ruby
import homebrew.rubocops.cask.ast as cask_ast
import homebrew.rubocops.@shared as conditionals
import homebrew.utils

// Translated from Homebrew/brew `rubocops/cask/on_system_conditionals.rb` at
// df30fd34cc7132abfb8dbe3b1d046e3d48a57d00.
pub const on_system_sha_only_message = "Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks"
pub const on_system_identical_version_message = "Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks"
pub const on_system_identical_sha_message = 'sha256 values for different architectures should not be identical.'

const on_system_flight_stanza_names = ['preflight', 'postflight', 'uninstall_preflight',
	'uninstall_postflight']

pub struct CaskOnSystemProblem {
pub:
	kind              string
	begin_pos         int
	end_pos           int
	message           string
	replacement       string
	replacement_begin int
	replacement_end   int
	remove_begin      int
	remove_end        int
}

pub struct CaskOnSystemArchMatch {
pub:
	method        string
	begin_pos     int
	end_pos       int
	column        int
	version_value string
	sha256_value  string
}

struct CaskOnSystemEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

fn on_system_source(args []ruby.Value) string {
	if args.len == 0 {
		return ''
	}
	return args[0].attributes['source'] or { args[0].as_string() }
}

fn on_system_root(source string) ?utils.AstNode {
	_, root := utils.ast_process_source(source)
	if root.kind == 'block_call' && root.name == 'cask' {
		return root
	}
	for child in root.children {
		if child.kind == 'block_call' && child.name == 'cask' {
			return child
		}
	}
	return none
}

fn on_system_string_argument(node utils.AstNode) ?string {
	if node.arguments.len != 1 || node.arguments[0].value.type_name != 'String' {
		return none
	}
	return node.arguments[0].value.as_string()
}

fn on_system_ruby_string_inspect(value string) string {
	escaped := value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
	return '"${escaped}"'
}

fn on_system_sha_match(node utils.AstNode) ?CaskOnSystemArchMatch {
	if node.kind != 'block_call' || node.name !in ['on_arm', 'on_intel'] || node.arguments.len != 0 || node.children.len != 1 {
		return none
	}
	if node.has_receiver {
		return none
	}
	sha_node := node.children[0]
	if sha_node.kind != 'method_call' || sha_node.name != 'sha256' || sha_node.has_receiver {
		return none
	}
	sha := on_system_string_argument(sha_node) or { return none }
	return CaskOnSystemArchMatch{
		method: node.name
		begin_pos: node.source_range.begin_pos
		end_pos: node.source_range.end_pos
		column: node.source_range.column
		sha256_value: sha
	}
}

fn on_system_version_sha_match(node utils.AstNode) ?CaskOnSystemArchMatch {
	if node.kind != 'block_call' || node.name !in ['on_arm', 'on_intel'] || node.arguments.len != 0 || node.children.len != 2 {
		return none
	}
	if node.has_receiver {
		return none
	}
	version_node := node.children[0]
	sha_node := node.children[1]
	if version_node.kind != 'method_call' || version_node.name != 'version' || version_node.has_receiver || sha_node.kind != 'method_call' || sha_node.name != 'sha256' || sha_node.has_receiver {
		return none
	}
	version := on_system_string_argument(version_node) or { return none }
	sha := on_system_string_argument(sha_node) or { return none }
	return CaskOnSystemArchMatch{
		method: node.name
		begin_pos: node.source_range.begin_pos
		end_pos: node.source_range.end_pos
		column: node.source_range.column
		version_value: version
		sha256_value: sha
	}
}

fn on_system_collect_sha_matches(node utils.AstNode, mut matches []CaskOnSystemArchMatch) {
	for child in node.children {
		if matched := on_system_sha_match(child) {
			matches << matched
		}
		on_system_collect_sha_matches(child, mut matches)
	}
}

fn on_system_collect_version_sha_matches(node utils.AstNode, mut matches []CaskOnSystemArchMatch) {
	for child in node.children {
		if matched := on_system_version_sha_match(child) {
			matches << matched
		}
		on_system_collect_version_sha_matches(child, mut matches)
	}
}

pub fn cask_sha256_on_arch_stanzas(source string) []CaskOnSystemArchMatch {
	root := on_system_root(source) or { return []CaskOnSystemArchMatch{} }
	mut matches := []CaskOnSystemArchMatch{}
	on_system_collect_sha_matches(root, mut matches)
	return matches
}

pub fn cask_version_and_sha256_on_arch_stanzas(source string) []CaskOnSystemArchMatch {
	root := on_system_root(source) or { return []CaskOnSystemArchMatch{} }
	mut matches := []CaskOnSystemArchMatch{}
	on_system_collect_version_sha_matches(root, mut matches)
	return matches
}

fn on_system_comment_ranges(source string) [][]int {
	mut ranges := [][]int{}
	mut line_start := 0
	for line_start <= source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut quote := u8(0)
		mut escaped := false
		for position := line_start; position < line_end; position++ {
			character := source[position]
			if quote != 0 {
				if escaped {
					escaped = false
				} else if character == `\\` {
					escaped = true
				} else if character == quote {
					quote = 0
				}
			} else if character == `'` || character == `"` {
				quote = character
			} else if character == `#` {
				ranges << [position, line_end]
				break
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return ranges
}

pub fn cask_comments_in_node_ranges(source string, ranges [][]int) bool {
	for comment in on_system_comment_ranges(source) {
		for node_range in ranges {
			if node_range.len >= 2 && node_range[0] <= comment[0] && comment[1] <= node_range[1] {
				return true
			}
		}
	}
	return false
}

fn on_system_whole_line_range(source string, begin_pos int, end_pos int) (int, int) {
	line_start := (source[..begin_pos].last_index('\n') or { -1 }) + 1
	relative_newline := source[end_pos..].index_u8(`\n`)
	line_end := if relative_newline < 0 { source.len } else { end_pos + relative_newline + 1 }
	return line_start, line_end
}

fn on_system_problem_from_shared(finding conditionals.OnSystemFinding, offset int) CaskOnSystemProblem {
	return CaskOnSystemProblem{
		kind: 'conditional'
		begin_pos: offset + finding.begin_pos
		end_pos: offset + finding.end_pos
		message: finding.message
		replacement: finding.replacement
		replacement_begin: offset + finding.begin_pos
		replacement_end: offset + finding.end_pos
	}
}

fn on_system_flight_problems(_source string, root utils.AstNode) []CaskOnSystemProblem {
	mut problems := []CaskOnSystemProblem{}
	for stanza in root.children {
		if stanza.kind != 'block_call' || stanza.name !in on_system_flight_stanza_names {
			continue
		}
		analysis := conditionals.audit_on_system_blocks(stanza.source, stanza.name, false)
		for finding in analysis.findings {
			problems << on_system_problem_from_shared(finding, stanza.source_range.begin_pos)
		}
	}
	return problems
}

fn on_system_arch_conditional_problems(source string) []CaskOnSystemProblem {
	analysis := conditionals.audit_arch_conditionals(source, [], on_system_flight_stanza_names)
	mut problems := analysis.findings.map(on_system_problem_from_shared(it, 0))
	mut line_start := 0
	for line_start <= source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		trimmed := source[line_start..line_end].trim_space()
		for method in ['arch', 'arm?', 'intel?'] {
			target := 'Hardware::CPU.${method}'
			prefix := 'if ${target}'
			if trimmed.starts_with(prefix) && trimmed[prefix.len..].trim_space() != '' {
				position := line_start + (source[line_start..line_end].index(target) or { continue })
				if !conditionals.on_system_node_is_allowed(source, position, [], on_system_flight_stanza_names) {
					problems << CaskOnSystemProblem{
						kind: 'conditional'
						begin_pos: position
						end_pos: position + target.len
						message: 'Instead of `${target}`, use `on_arm` and `on_intel` blocks.'
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return problems
}

fn on_system_macos_conditional_problems(source string) []CaskOnSystemProblem {
	analysis := conditionals.audit_macos_version_conditionals(source, [], on_system_flight_stanza_names, false)
	return analysis.findings.map(on_system_problem_from_shared(it, 0))
}

fn on_system_arch_pair(children []utils.AstNode, versioned bool) ?([]CaskOnSystemArchMatch) {
	mut arm := ?CaskOnSystemArchMatch(none)
	mut intel := ?CaskOnSystemArchMatch(none)
	for child in children {
		matched := if versioned {
			on_system_version_sha_match(child) or { continue }
		} else {
			on_system_sha_match(child) or { continue }
		}
		if matched.method == 'on_arm' {
			arm = matched
		} else {
			intel = matched
		}
	}
	arm_match := arm or { return none }
	intel_match := intel or { return none }
	return [arm_match, intel_match]
}

fn on_system_sha_pair_problems(source string, node utils.AstNode, mut problems []CaskOnSystemProblem) {
	if pair := on_system_arch_pair(node.children, false) {
		arm := pair[0]
		intel := pair[1]
		remove_begin, remove_end := on_system_whole_line_range(source, intel.begin_pos, intel.end_pos)
		has_comments := cask_comments_in_node_ranges(source, [
			[arm.begin_pos, arm.end_pos],
			[intel.begin_pos, intel.end_pos],
		])
		problems << CaskOnSystemProblem{
			kind: 'sha256_arch_blocks'
			begin_pos: arm.begin_pos
			end_pos: arm.end_pos
			message: on_system_sha_only_message
			replacement: if has_comments {
				''
			} else {
				'sha256 arm: ${on_system_ruby_string_inspect(arm.sha256_value)}, intel: ${on_system_ruby_string_inspect(intel.sha256_value)}'
			}
			replacement_begin: arm.begin_pos
			replacement_end: arm.end_pos
			remove_begin: if has_comments { 0 } else { remove_begin }
			remove_end: if has_comments { 0 } else { remove_end }
		}
	}
	for child in node.children {
		on_system_sha_pair_problems(source, child, mut problems)
	}
}

fn on_system_version_pair_problems(source string, node utils.AstNode,
	mut problems []CaskOnSystemProblem) {
	if pair := on_system_arch_pair(node.children, true) {
		arm := pair[0]
		intel := pair[1]
		if arm.version_value == intel.version_value {
			remove_begin, remove_end := on_system_whole_line_range(source, intel.begin_pos, intel.end_pos)
			has_comments := cask_comments_in_node_ranges(source, [
				[arm.begin_pos, arm.end_pos],
				[intel.begin_pos, intel.end_pos],
			])
			sha_source := if arm.sha256_value == intel.sha256_value {
				'sha256 ${on_system_ruby_string_inspect(arm.sha256_value)}'
			} else {
				'sha256 arm: ${on_system_ruby_string_inspect(arm.sha256_value)}, intel: ${on_system_ruby_string_inspect(intel.sha256_value)}'
			}
			indent := ' '.repeat(arm.column)
			problems << CaskOnSystemProblem{
				kind: 'identical_arch_versions'
				begin_pos: arm.begin_pos
				end_pos: arm.end_pos
				message: on_system_identical_version_message
				replacement: if has_comments {
					''
				} else {
					'version ${on_system_ruby_string_inspect(arm.version_value)}\n${indent}${sha_source}'
				}
				replacement_begin: arm.begin_pos
				replacement_end: arm.end_pos
				remove_begin: if has_comments { 0 } else { remove_begin }
				remove_end: if has_comments { 0 } else { remove_end }
			}
		}
	}
	for child in node.children {
		on_system_version_pair_problems(source, child, mut problems)
	}
}

fn on_system_identical_hash_problems(_source string, root utils.AstNode) []CaskOnSystemProblem {
	mut problems := []CaskOnSystemProblem{}
	for stanza in root.children {
		if stanza.kind != 'method_call' || stanza.name != 'sha256' || stanza.has_receiver || stanza.arguments.len != 0 || stanza.hash_pairs.len < 2 {
			continue
		}
		mut arm := ?string(none)
		mut intel := ?string(none)
		for pair in stanza.hash_pairs {
			if pair.value.type_name != 'String' {
				continue
			}
			if pair.key == 'arm' {
				arm = pair.value.as_string()
			} else if pair.key == 'intel' {
				intel = pair.value.as_string()
			}
		}
		arm_sha := arm or { continue }
		intel_sha := intel or { continue }
		if arm_sha == intel_sha {
			problems << CaskOnSystemProblem{
				kind: 'identical_sha256_hash'
				begin_pos: stanza.source_range.begin_pos
				end_pos: stanza.source_range.end_pos
				message: on_system_identical_sha_message
			}
		}
	}
	return problems
}

pub fn audit_cask_on_system_conditionals(source string) []CaskOnSystemProblem {
	root := on_system_root(source) or { return []CaskOnSystemProblem{} }
	mut problems := on_system_flight_problems(source, root)
	problems << on_system_arch_conditional_problems(source)
	problems << on_system_macos_conditional_problems(source)
	on_system_sha_pair_problems(source, root, mut problems)
	on_system_version_pair_problems(source, root, mut problems)
	problems << on_system_identical_hash_problems(source, root)
	return problems
}

pub fn correct_cask_on_system_conditionals(source string) string {
	mut edits := []CaskOnSystemEdit{}
	for problem in audit_cask_on_system_conditionals(source) {
		if problem.replacement != '' {
			edits << CaskOnSystemEdit{
				begin_pos: problem.replacement_begin
				end_pos: problem.replacement_end
				replacement: problem.replacement
			}
		}
		if problem.remove_end > problem.remove_begin {
			edits << CaskOnSystemEdit{
				begin_pos: problem.remove_begin
				end_pos: problem.remove_end
			}
		}
	}
	edits.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for edit in edits {
		corrected = corrected[..edit.begin_pos] + edit.replacement + corrected[edit.end_pos..]
	}
	return corrected
}

fn on_system_problem_value(problem CaskOnSystemProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', problem.message, {
		'kind':              problem.kind
		'begin_pos':         problem.begin_pos.str()
		'end_pos':           problem.end_pos.str()
		'message':           problem.message
		'replacement':       problem.replacement
		'replacement_begin': problem.replacement_begin.str()
		'replacement_end':   problem.replacement_end.str()
		'remove_begin':      problem.remove_begin.str()
		'remove_end':        problem.remove_end.str()
	})
}

fn on_system_problem_values(problems []CaskOnSystemProblem) ruby.Value {
	return ruby.array_value(problems.map(on_system_problem_value(it)))
}

fn on_system_match_value(matched CaskOnSystemArchMatch) ruby.Value {
	return ruby.structured_value('RuboCop::AST::BlockNode', matched.method, {
		'method':        matched.method
		'begin_pos':     matched.begin_pos.str()
		'end_pos':       matched.end_pos.str()
		'column':        matched.column.str()
		'version_value': matched.version_value
		'sha256_value':  matched.sha256_value
	})
}
