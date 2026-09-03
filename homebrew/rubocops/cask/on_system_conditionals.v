module cask

import brew_runtime
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

fn on_system_source(args []brew_runtime.Value) string {
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

fn on_system_problem_value(problem CaskOnSystemProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', problem.message, {
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

fn on_system_problem_values(problems []CaskOnSystemProblem) brew_runtime.Value {
	return brew_runtime.array_value(problems.map(on_system_problem_value(it)))
}

fn on_system_match_value(matched CaskOnSystemArchMatch) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::AST::BlockNode', matched.method, {
		'method':        matched.method
		'begin_pos':     matched.begin_pos.str()
		'end_pos':       matched.end_pos.str()
		'column':        matched.column.str()
		'version_value': matched.version_value
		'sha256_value':  matched.sha256_value
	})
}

// Ruby method `on_cask(cask_block)` at line 38.
pub fn ruby_on_system_conditionals_l38_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return on_system_problem_values(audit_cask_on_system_conditionals(on_system_source(args)))
}

// Ruby attr_reader `attr_reader :cask_block` at line 57.
pub fn ruby_on_system_conditionals_l57_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := on_system_source(args)
	return brew_runtime.structured_value('RuboCop::Cask::AST::CaskBlock', source, {
		'source': source
	})
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas, :cask_body` at line 59.
pub fn ruby_on_system_conditionals_l59_d3_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	source := on_system_source(args)
	block := cask_ast.parse_cask_ast_stanza_block(source, true) or {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	mut values := []brew_runtime.Value{}
	for stanza in cask_ast.cask_ast_block_stanzas(block, false) {
		begin_pos, end_pos := cask_ast.cask_ast_stanza_range(stanza, false)
		values << brew_runtime.structured_value('RuboCop::Cask::AST::Stanza', source[begin_pos..end_pos], {
			'name':      cask_ast.cask_ast_stanza_name(stanza)
			'begin_pos': begin_pos.str()
			'end_pos':   end_pos.str()
		})
	}
	return brew_runtime.array_value(values)
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas, :cask_body` at line 59.
pub fn ruby_on_system_conditionals_l59_d4_cask_body(args ...brew_runtime.Value) brew_runtime.Value {
	source := on_system_source(args)
	root := on_system_root(source) or { return brew_runtime.object_value('NilClass', 'nil') }
	if root.children.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	begin_pos := root.children[0].source_range.begin_pos
	end_pos := root.children.last().source_range.end_pos
	type_name := if root.children.len == 1 {
		'RuboCop::AST::Node'
	} else {
		'RuboCop::AST::BeginNode'
	}
	return brew_runtime.structured_value(type_name, source[begin_pos..end_pos], {
		'begin_pos': begin_pos.str()
		'end_pos':   end_pos.str()
		'source':    source[begin_pos..end_pos]
	})
}

// Ruby method `simplify_sha256_stanzas` at line 62.
pub fn ruby_on_system_conditionals_l62_d5_simplify_sha256_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return on_system_problem_values(audit_cask_on_system_conditionals(on_system_source(args)).filter(it.kind == 'sha256_arch_blocks'))
}

// Ruby method `simplify_arch_version_stanzas` at line 89.
pub fn ruby_on_system_conditionals_l89_d6_simplify_arch_version_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return on_system_problem_values(audit_cask_on_system_conditionals(on_system_source(args)).filter(it.kind == 'identical_arch_versions'))
}

// Ruby method `comments_in_node_ranges?(*nodes)` at line 138.
pub fn ruby_on_system_conditionals_l138_d7_comments_in_node_ranges(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	source := on_system_source(args)
	mut ranges := [][]int{}
	for node in args[1..] {
		ranges << [(node.attributes['begin_pos'] or { '0' }).int(),
			(node.attributes['end_pos'] or { source.len.str() }).int()]
	}
	if ranges.len == 0 {
		ranges << [0, source.len]
	}
	return brew_runtime.bool_value(cask_comments_in_node_ranges(source, ranges))
}

// Ruby method `audit_identical_sha256_across_architectures` at line 150.
pub fn ruby_on_system_conditionals_l150_d8_audit_identical_sha256_across_architectures(args ...brew_runtime.Value) brew_runtime.Value {
	return on_system_problem_values(audit_cask_on_system_conditionals(on_system_source(args)).filter(it.kind == 'identical_sha256_hash'))
}

// Ruby def_node_search `def_node_search :sha256_on_arch_stanzas, <<~PATTERN` at line 186.
pub fn ruby_on_system_conditionals_l186_d9_sha256_on_arch_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(cask_sha256_on_arch_stanzas(on_system_source(args)).map(on_system_match_value(it)))
}

// Ruby def_node_search `def_node_search :version_and_sha256_on_arch_stanzas, <<~PATTERN` at line 194.
pub fn ruby_on_system_conditionals_l194_d10_version_and_sha256_on_arch_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(cask_version_and_sha256_on_arch_stanzas(on_system_source(args)).map(on_system_match_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "rubocops/shared/on_system_conditionals_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module Cask
// 10:       # This cop makes sure that OS conditionals are consistent.
// 11:       #
// 12:       # ### Example
// 13:       #
// 14:       # ```ruby
// 15:       # # bad
// 16:       # cask 'foo' do
// 17:       #   if MacOS.version == :tahoe
// 18:       #     sha256 "..."
// 19:       #   end
// 20:       # end
// 21:       #
// 22:       # # good
// 23:       # cask 'foo' do
// 24:       #   on_tahoe do
// 25:       #     sha256 "..."
// 26:       #   end
// 27:       # end
// 28:       # ```
// 29:       class OnSystemConditionals < Base
// 30:         extend Forwardable
// 31:         extend AutoCorrector
// 32:         include OnSystemConditionalsHelper
// 33:         include CaskHelp
// 34:
// 35:         FLIGHT_STANZA_NAMES = [:preflight, :postflight, :uninstall_preflight, :uninstall_postflight].freeze
// 36:
// 37:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 38:         def on_cask(cask_block)
// 39:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 40:
// 41:           toplevel_stanzas.each do |stanza|
// 42:             next unless FLIGHT_STANZA_NAMES.include? stanza.stanza_name
// 43:
// 44:             audit_on_system_blocks(stanza.stanza_node, stanza.stanza_name)
// 45:           end
// 46:
// 47:           audit_arch_conditionals(cask_body, allowed_blocks: FLIGHT_STANZA_NAMES)
// 48:           audit_macos_version_conditionals(cask_body, recommend_on_system: false, allowed_blocks: FLIGHT_STANZA_NAMES)
// 49:           simplify_sha256_stanzas
// 50:           simplify_arch_version_stanzas
// 51:           audit_identical_sha256_across_architectures
// 52:         end
// 53:
// 54:         private
// 55:
// 56:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 57:         attr_reader :cask_block
// 58:
// 59:         def_delegators :cask_block, :toplevel_stanzas, :cask_body
// 60:
// 61:         sig { void }
// 62:         def simplify_sha256_stanzas
// 63:           grouped_nodes = Hash.new { |hash, key| hash[key] = {} }
// 64:
// 65:           sha256_on_arch_stanzas(cask_body) do |node, method, value|
// 66:             arch = method.to_s.delete_prefix("on_").to_sym
// 67:             ast_node = T.cast(node, RuboCop::AST::Node)
// 68:             grouped_nodes[ast_node.parent][arch] = { node: ast_node, value: }
// 69:           end
// 70:
// 71:           grouped_nodes.each_value do |nodes|
// 72:             next if !nodes.key?(:arm) || !nodes.key?(:intel)
// 73:
// 74:             offending_node(nodes[:arm][:node])
// 75:             replacement_string = "sha256 arm: #{nodes[:arm][:value].inspect}, intel: #{nodes[:intel][:value].inspect}"
// 76:             if comments_in_node_ranges?(nodes[:arm][:node], nodes[:intel][:node])
// 77:               problem "Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks"
// 78:               next
// 79:             end
// 80:
// 81:             problem "Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks" do |corrector|
// 82:               corrector.replace(nodes[:arm][:node].source_range, replacement_string)
// 83:               corrector.remove(range_by_whole_lines(nodes[:intel][:node].source_range, include_final_newline: true))
// 84:             end
// 85:           end
// 86:         end
// 87:
// 88:         sig { void }
// 89:         def simplify_arch_version_stanzas
// 90:           grouped_nodes = Hash.new { |hash, key| hash[key] = {} }
// 91:
// 92:           version_and_sha256_on_arch_stanzas(cask_body) do |block_node, arch_method, version_value, sha256_value|
// 93:             arch = arch_method.to_s.delete_prefix("on_").to_sym
// 94:             ast_block_node = T.cast(block_node, RuboCop::AST::Node)
// 95:             grouped_nodes[ast_block_node.parent][arch] = {
// 96:               node:          ast_block_node,
// 97:               version_value:,
// 98:               sha256_value:,
// 99:             }
// 100:           end
// 101:
// 102:           grouped_nodes.each_value do |nodes|
// 103:             next if !nodes.key?(:arm) || !nodes.key?(:intel)
// 104:
// 105:             arm_version = nodes[:arm][:version_value]
// 106:             intel_version = nodes[:intel][:version_value]
// 107:
// 108:             next if arm_version != intel_version
// 109:
// 110:             arm_sha = nodes[:arm][:sha256_value]
// 111:             intel_sha = nodes[:intel][:sha256_value]
// 112:             arm_node = nodes[:arm][:node]
// 113:             intel_node = nodes[:intel][:node]
// 114:
// 115:             indent = " " * arm_node.loc.column
// 116:             version_str = "version #{arm_version.inspect}"
// 117:             sha256_str = if arm_sha == intel_sha
// 118:               "sha256 #{arm_sha.inspect}"
// 119:             else
// 120:               "sha256 arm: #{arm_sha.inspect}, intel: #{intel_sha.inspect}"
// 121:             end
// 122:             replacement = "#{version_str}\n#{indent}#{sha256_str}"
// 123:
// 124:             offending_node(arm_node)
// 125:             if comments_in_node_ranges?(arm_node, intel_node)
// 126:               problem "Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks"
// 127:               next
// 128:             end
// 129:
// 130:             problem "Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks" do |corrector|
// 131:               corrector.replace(arm_node.source_range, replacement)
// 132:               corrector.remove(range_by_whole_lines(intel_node.source_range, include_final_newline: true))
// 133:             end
// 134:           end
// 135:         end
// 136:
// 137:         sig { params(nodes: RuboCop::AST::Node).returns(T::Boolean) }
// 138:         def comments_in_node_ranges?(*nodes)
// 139:           processed_source.comments.any? do |comment|
// 140:             comment_range = comment.loc.expression
// 141:
// 142:             nodes.any? do |node|
// 143:               node_range = node.source_range
// 144:               node_range.begin_pos <= comment_range.begin_pos && comment_range.end_pos <= node_range.end_pos
// 145:             end
// 146:           end
// 147:         end
// 148:
// 149:         sig { void }
// 150:         def audit_identical_sha256_across_architectures
// 151:           sha256_stanzas = toplevel_stanzas.select { |stanza| stanza.stanza_name == :sha256 }
// 152:
// 153:           sha256_stanzas.each do |stanza|
// 154:             sha256_node = stanza.stanza_node
// 155:             next if sha256_node.arguments.count != 1
// 156:             next unless sha256_node.arguments.first.hash_type?
// 157:
// 158:             hash_node = sha256_node.arguments.first
// 159:             arm_sha = T.let(nil, T.nilable(String))
// 160:             intel_sha = T.let(nil, T.nilable(String))
// 161:
// 162:             hash_node.pairs.each do |pair|
// 163:               key = pair.key
// 164:               next unless key.sym_type?
// 165:
// 166:               value = pair.value
// 167:               next unless value.str_type?
// 168:
// 169:               case key.value
// 170:               when :arm
// 171:                 arm_sha = value.value
// 172:               when :intel
// 173:                 intel_sha = value.value
// 174:               end
// 175:             end
// 176:
// 177:             next unless arm_sha
// 178:             next unless intel_sha
// 179:             next if arm_sha != intel_sha
// 180:
// 181:             offending_node(sha256_node)
// 182:             problem "sha256 values for different architectures should not be identical."
// 183:           end
// 184:         end
// 185:
// 186:         def_node_search :sha256_on_arch_stanzas, <<~PATTERN
// 187:           $(block
// 188:             (send nil? ${:on_intel :on_arm})
// 189:             (args)
// 190:             (send nil? :sha256
// 191:               (str $_)))
// 192:         PATTERN
// 193:
// 194:         def_node_search :version_and_sha256_on_arch_stanzas, <<~PATTERN
// 195:           $(block
// 196:             (send nil? ${:on_intel :on_arm})
// 197:             (args)
// 198:             (begin
// 199:               (send nil? :version (str $_))
// 200:               (send nil? :sha256 (str $_))))
// 201:         PATTERN
// 202:       end
// 203:     end
// 204:   end
// 205: end
