module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/components_redundancy.rb`.
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

fn components_redundancy_problem_value(problem ComponentsRedundancyProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':      problem.kind
		'begin_pos': problem.begin_pos.str()
		'end_pos':   problem.end_pos.str()
		'message':   problem.message
	})
}
