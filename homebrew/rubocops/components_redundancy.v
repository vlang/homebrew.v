module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/components_redundancy.rb`.
// The original source is retained below until every stub has a typed V body.
pub const components_redundancy_head_message = '`head` and `head do` should not be simultaneously present'
pub const components_redundancy_bottle_message = '`bottle :modifier` and `bottle do` should not be simultaneously present'
pub const components_redundancy_stable_message = '`stable do` should not be present without a `head` spec'

pub struct ComponentsRedundancyProblem {
pub:
	kind      string
	begin_pos int
	end_pos   int
	message   string
}

struct ComponentsRedundancyLine {
	begin_pos int
	end_pos   int
	indent    int
	text      string
}

struct ComponentsRedundancyBlock {
	name       string
	line_index int
	end_index  int
	indent     int
}

fn components_redundancy_lines(source string) []ComponentsRedundancyLine {
	mut lines := []ComponentsRedundancyLine{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		mut indent := 0
		for indent < line.len && (line[indent] == ` ` || line[indent] == `\t`) {
			indent++
		}
		lines << ComponentsRedundancyLine{
			begin_pos: line_start
			end_pos: line_end
			indent: indent
			text: line[indent..].trim_space()
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return lines
}

fn components_redundancy_method(line ComponentsRedundancyLine) string {
	if line.text == '' || line.text.starts_with('#') || line.text == 'end' {
		return ''
	}
	mut end := 0
	for end < line.text.len && line.text[end] != ` ` && line.text[end] != `\t` && line.text[end] != `(` {
		end++
	}
	return line.text[..end]
}

fn components_redundancy_blocks(lines []ComponentsRedundancyLine) []ComponentsRedundancyBlock {
	mut blocks := []ComponentsRedundancyBlock{}
	for index, line in lines {
		name := components_redundancy_method(line)
		if name !in ['stable', 'head', 'bottle'] || !line.text.contains(' do') {
			continue
		}
		mut end_index := lines.len
		for candidate := index + 1; candidate < lines.len; candidate++ {
			if lines[candidate].text == 'end' && lines[candidate].indent == line.indent {
				end_index = candidate
				break
			}
		}
		blocks << ComponentsRedundancyBlock{
			name: name
			line_index: index
			end_index: end_index
			indent: line.indent
		}
	}
	return blocks
}

fn components_redundancy_problem(kind string, line ComponentsRedundancyLine, message string) ComponentsRedundancyProblem {
	return ComponentsRedundancyProblem{
		kind: kind
		begin_pos: line.begin_pos + line.indent
		end_pos: line.end_pos
		message: message
	}
}

fn components_block_only_methods(lines []ComponentsRedundancyLine, block ComponentsRedundancyBlock, allowed []string) bool {
	mut methods := []string{}
	for index := block.line_index + 1; index < block.end_index; index++ {
		line := lines[index]
		if line.text == '' || line.text.starts_with('#') {
			continue
		}
		if line.indent <= block.indent {
			continue
		}
		method := components_redundancy_method(line)
		if method != '' {
			methods << method
		}
	}
	return methods.len > 0 && methods.all(it in allowed)
}

pub fn audit_components_redundancy(source string) []ComponentsRedundancyProblem {
	lines := components_redundancy_lines(source)
	blocks := components_redundancy_blocks(lines)
	mut body_indent := 1_000_000
	for line in lines {
		if line.text != '' && !line.text.starts_with('#') && !line.text.starts_with('class ') && line.text != 'end' && line.indent < body_indent {
			body_indent = line.indent
		}
	}
	mut direct_methods := map[string][]ComponentsRedundancyLine{}
	for line in lines {
		if line.indent != body_indent || line.text.contains(' do') {
			continue
		}
		method := components_redundancy_method(line)
		if method != '' {
			direct_methods[method] << line
		}
	}
	mut problems := []ComponentsRedundancyProblem{}
	if direct_methods['sha256'].len > 0 {
		for url in direct_methods['url'] {
			if url.text.contains('tag:') && url.text.contains('revision:') {
				problems << components_redundancy_problem('url_tag_revision_sha256', url, 'Do not use both `sha256` and `tag:`/`revision:`.')
			}
		}
	}
	stable_blocks := blocks.filter(it.name == 'stable' && lines[it.line_index].indent == body_indent)
	head_blocks := blocks.filter(it.name == 'head' && lines[it.line_index].indent == body_indent)
	bottle_blocks := blocks.filter(it.name == 'bottle' && lines[it.line_index].indent == body_indent)
	if stable_blocks.len > 0 {
		stable := stable_blocks[0]
		for method in ['url', 'sha256', 'mirror', 'version'] {
			if direct_methods[method].len > 0 {
				problems << components_redundancy_problem('${method}_outside_stable', direct_methods[method][0], '`${method}` should be put inside `stable` block')
			}
		}
		if components_block_only_methods(lines, stable, ['url', 'sha256', 'mirror', 'version']) {
			problems << components_redundancy_problem('stable_only_shorthand', lines[stable.line_index], '`stable do` should not be present with only url/sha256/mirror/version')
		}
	}
	if head_blocks.len > 0 {
		head := head_blocks[0]
		if components_block_only_methods(lines, head, ['url', 'branch']) {
			problems << components_redundancy_problem('head_only_shorthand', lines[head.line_index], '`head do` should not be present with only url/branch')
		}
	}
	if direct_methods['head'].len > 0 && head_blocks.len > 0 {
		problems << components_redundancy_problem('head_and_block', lines[head_blocks[0].line_index], components_redundancy_head_message)
	}
	if direct_methods['bottle'].len > 0 && bottle_blocks.len > 0 {
		problems << components_redundancy_problem('bottle_and_block', lines[bottle_blocks[0].line_index], components_redundancy_bottle_message)
	}
	if direct_methods['head'].len == 0 && head_blocks.len == 0 && stable_blocks.len > 0 {
		problems << components_redundancy_problem('stable_without_head', lines[stable_blocks[0].line_index], components_redundancy_stable_message)
	}
	return problems
}

fn components_redundancy_problem_value(problem ComponentsRedundancyProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':      problem.kind
		'begin_pos': problem.begin_pos.str()
		'end_pos':   problem.end_pos.str()
		'message':   problem.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 24.
pub fn ruby_components_redundancy_l24_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_components_redundancy(source).map(components_redundancy_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop checks if redundant components are present and for other component errors.
// 10:       #
// 11:       # - `url|checksum|mirror|version` should be inside `stable` block
// 12:       # - `head` and `head do` should not be simultaneously present
// 13:       # - `bottle :unneeded`/`:disable` and `bottle do` should not be simultaneously present
// 14:       # - `stable do` should not be present without a `head` spec
// 15:       # - `stable do` should not be present with only `url|checksum|mirror|version`
// 16:       # - `head do` should not be present with only `url|branch`
// 17:       class ComponentsRedundancy < FormulaCop
// 18:         HEAD_MSG = "`head` and `head do` should not be simultaneously present"
// 19:         BOTTLE_MSG = "`bottle :modifier` and `bottle do` should not be simultaneously present"
// 20:         STABLE_MSG = "`stable do` should not be present without a `head` spec"
// 21:         STABLE_BLOCK_METHODS = [:url, :sha256, :mirror, :version].freeze
// 22:
// 23:         sig { override.params(formula_nodes: FormulaNodes).void }
// 24:         def audit_formula(formula_nodes)
// 25:           return if (body_node = formula_nodes.body_node).nil?
// 26:
// 27:           urls = find_method_calls_by_name(body_node, :url)
// 28:
// 29:           urls.each do |url|
// 30:             url.arguments.each do |arg|
// 31:               next if arg.class != RuboCop::AST::HashNode
// 32:
// 33:               url_args = arg.keys.each.map(&:value)
// 34:               if method_called?(body_node, :sha256) && url_args.include?(:tag) && url_args.include?(:revision)
// 35:                 problem "Do not use both `sha256` and `tag:`/`revision:`."
// 36:               end
// 37:             end
// 38:           end
// 39:
// 40:           stable_block = find_block(body_node, :stable)
// 41:           if stable_block
// 42:             STABLE_BLOCK_METHODS.each do |method_name|
// 43:               problem "`#{method_name}` should be put inside `stable` block" if method_called?(body_node, method_name)
// 44:             end
// 45:
// 46:             unless stable_block.body.nil?
// 47:               child_nodes = stable_block.body.begin_type? ? stable_block.body.child_nodes : [stable_block.body]
// 48:               if child_nodes.all? { |n| n.send_type? && STABLE_BLOCK_METHODS.include?(n.method_name) }
// 49:                 problem "`stable do` should not be present with only #{STABLE_BLOCK_METHODS.join("/")}"
// 50:               end
// 51:             end
// 52:           end
// 53:
// 54:           head_block = find_block(body_node, :head)
// 55:           if head_block && !head_block.body.nil?
// 56:             child_nodes = head_block.body.begin_type? ? head_block.body.child_nodes : [head_block.body]
// 57:             shorthand_head_methods = [:url, :branch]
// 58:             if child_nodes.all? { |n| n.send_type? && shorthand_head_methods.include?(n.method_name) }
// 59:               problem "`head do` should not be present with only #{shorthand_head_methods.join("/")}"
// 60:             end
// 61:           end
// 62:
// 63:           problem HEAD_MSG if method_called?(body_node, :head) &&
// 64:                               find_block(body_node, :head)
// 65:
// 66:           problem BOTTLE_MSG if method_called?(body_node, :bottle) &&
// 67:                                 find_block(body_node, :bottle)
// 68:
// 69:           return if method_called?(body_node, :head) ||
// 70:                     find_block(body_node, :head)
// 71:
// 72:           problem STABLE_MSG if stable_block
// 73:         end
// 74:       end
// 75:     end
// 76:   end
// 77: end
