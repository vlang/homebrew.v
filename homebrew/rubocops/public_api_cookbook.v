module rubocops

import ruby
import homebrew.rubocops.@shared as api_annotations

// Translated from Homebrew/brew `rubocops/public_api_cookbook.rb`.
pub struct PublicApiCookbookContext {
pub:
	source                    string
	relative_path             string
	formula_cookbook_methods  ?map[string]string
	cask_cookbook_methods     ?map[string]string
	service_cookbook_methods  ?[]string
	formula_cookbook_markdown ?string
}

pub struct PublicApiCookbookOffense {
pub:
	begin_pos int
	end_pos   int
	line      int
	message   string
}

pub struct PublicApiCookbookAnalysis {
pub:
	offenses []PublicApiCookbookOffense
}

struct PublicApiCookbookLine {
	text  string
	start int
	end   int
	line  int
}

struct PublicApiCookbookDefinition {
	name      string
	kind      string
	line      int
	begin_pos int
	end_pos   int
}

fn public_api_cookbook_lines(source string) []PublicApiCookbookLine {
	mut lines := []PublicApiCookbookLine{}
	mut start := 0
	mut number := 1
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		lines << PublicApiCookbookLine{
			text: source[start..newline]
			start: start
			end: newline
			line: number
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
		number++
	}
	return lines
}

fn public_api_definition_name(line string) ?string {
	trimmed := line.trim_space()
	if trimmed.starts_with('def ') {
		return api_annotations.api_annotation_method_name(trimmed)
	}
	return none
}

fn public_api_attribute_names(line string) []string {
	trimmed := line.trim_space()
	mut rest := if trimmed.starts_with('attr_reader ') {
		trimmed.all_after('attr_reader ')
	} else if trimmed.starts_with('attr_accessor ') {
		trimmed.all_after('attr_accessor ')
	} else {
		return []
	}
	if rest.contains('#') {
		rest = rest.all_before('#')
	}
	mut names := []string{}
	for argument in rest.split(',') {
		name := argument.trim_space().trim_left(':')
		if name != '' && name.bytes().all(it.is_alnum() || it in [`_`, `!`, `?`]) {
			names << name
		}
	}
	return names
}

fn public_api_definitions(source string) []PublicApiCookbookDefinition {
	mut definitions := []PublicApiCookbookDefinition{}
	for line in public_api_cookbook_lines(source) {
		trimmed := line.text.trim_space()
		indent := line.text.len - line.text.trim_left(' \t').len
		if name := public_api_definition_name(trimmed) {
			definitions << PublicApiCookbookDefinition{
				name: name
				kind: 'def'
				line: line.line
				begin_pos: line.start + indent
				end_pos: line.end
			}
			continue
		}
		for name in public_api_attribute_names(trimmed) {
			definitions << PublicApiCookbookDefinition{
				name: name
				kind: 'attr'
				line: line.line
				begin_pos: line.start + indent
				end_pos: line.end
			}
		}
	}
	return definitions
}

pub fn public_api_targets(source string) []int {
	lines := public_api_cookbook_lines(source)
	mut targets := []int{}
	for index, line in lines {
		if line.text.trim_space() != '# @api public' {
			continue
		}
		mut in_sig := false
		for offset := 1; offset <= 15; offset++ {
			if index + offset >= lines.len {
				break
			}
			target := lines[index + offset].text.trim_space()
			if target == '' || target.starts_with('#') {
				continue
			}
			is_sig := target.starts_with('sig ') || target.starts_with('sig(') || target.starts_with('sig{') || target.contains('.sig ') || target.contains('.sig(') || target.contains('.sig{') || target.contains('}sig ') || target.contains('}sig(') || target.contains('}sig{')
			if is_sig {
				in_sig = !target.contains('}')
				continue
			}
			if in_sig {
				in_sig = !target.contains('}')
				continue
			}
			targets << lines[index + offset].line
			break
		}
	}
	return targets
}

fn public_api_relevant_names(methods map[string]string, relative_path string) []string {
	mut names := []string{}
	for name, path in methods {
		if path == relative_path {
			names << name
		}
	}
	return names
}

fn public_api_check_methods(source string, methods map[string]string, cookbook_name string,
	relative_path string, targets []int) []PublicApiCookbookOffense {
	names := public_api_relevant_names(methods, relative_path)
	if names.len == 0 {
		return []
	}
	mut offenses := []PublicApiCookbookOffense{}
	for definition in public_api_definitions(source) {
		if definition.name in names && definition.line !in targets {
			offenses << PublicApiCookbookOffense{
				begin_pos: definition.begin_pos
				end_pos: definition.end_pos
				line: definition.line
				message: 'Method `${definition.name}` is referenced in the ${cookbook_name} but is not annotated with `@api public`.'
			}
		}
	}
	return offenses
}

fn public_api_cask_annotation_method(lines []PublicApiCookbookLine, index int) ?string {
	for offset := 1; offset <= 5; offset++ {
		if index + offset >= lines.len {
			break
		}
		target := lines[index + offset].text.trim_space()
		if target == '' {
			break
		}
		if method := api_annotations.api_annotation_method_name(target) {
			return method
		}
	}
	return none
}

fn public_api_missing_cask_list(source string, relative_path string, cask_methods map[string]string) []PublicApiCookbookOffense {
	if relative_path !in ['cask/dsl.rb', 'cask/cask.rb', 'cask/dsl/version.rb'] {
		return []
	}
	lines := public_api_cookbook_lines(source)
	mut offenses := []PublicApiCookbookOffense{}
	for index, line in lines {
		if line.text.trim_space() != '# @api public' {
			continue
		}
		if method := public_api_cask_annotation_method(lines, index) {
			if method !in cask_methods {
				offenses << PublicApiCookbookOffense{
					begin_pos: line.start + (line.text.index('#') or { 0 })
					end_pos: line.end
					line: line.line
					message: 'Method `${method}` is annotated with `@api public` in `${relative_path}` but is missing from `CASK_COOKBOOK_METHODS`.'
				}
			}
		}
	}
	return offenses
}

pub fn parse_service_block_table(markdown string) []string {
	lines := markdown.split_into_lines()
	mut start := -1
	for index, line in lines {
		if line.starts_with('#### Service block methods') {
			start = index + 1
			break
		}
	}
	if start < 0 {
		return []
	}
	mut methods := []string{}
	for index := start; index < lines.len; index++ {
		line := lines[index]
		if line.starts_with('#') {
			break
		}
		trimmed := line.trim_space()
		if !trimmed.starts_with('|') || !trimmed.contains('`') {
			continue
		}
		after := trimmed.all_after('`')
		if !after.contains('`') {
			continue
		}
		method := after.all_before('`')
		if method != '' && method !in methods {
			methods << method
		}
	}
	return methods
}

fn public_api_rubydoc_methods(markdown string) []string {
	mut methods := []string{}
	mut from := 0
	for from < markdown.len {
		anchor := markdown.index_after('.html#', from) or { break }
		start := anchor + '.html#'.len
		mut finish := markdown.index_after('-instance_method', start) or { -1 }
		class_finish := markdown.index_after('-class_method', start) or { -1 }
		if finish < 0 || (class_finish >= 0 && class_finish < finish) {
			finish = class_finish
		}
		if finish < 0 {
			break
		}
		method := markdown[start..finish]
		if method != '' && method.bytes().all(it.is_alnum() || it in [`_`, `!`, `?`]) && method !in methods {
			methods << method
		}
		from = finish + 1
	}
	return methods
}

fn public_api_constant_offense(source string, constant string, message string) PublicApiCookbookOffense {
	for line in public_api_cookbook_lines(source) {
		if index := line.text.index(constant) {
			return PublicApiCookbookOffense{
				begin_pos: line.start + index
				end_pos: line.end
				line: line.line
				message: message
			}
		}
	}
	return PublicApiCookbookOffense{
		message: message
	}
}

fn public_api_backticked(methods []string) string {
	mut formatted := []string{}
	for method in methods {
		formatted << '`${method}`'
	}
	return formatted.join(', ')
}

fn public_api_check_service_list(source string, markdown string, service_methods []string) []PublicApiCookbookOffense {
	table := parse_service_block_table(markdown)
	mut table_sorted := table.clone()
	mut list_sorted := service_methods.clone()
	table_sorted.sort()
	list_sorted.sort()
	if table_sorted == list_sorted {
		return []
	}
	mut differences := []string{}
	missing_list := table.filter(it !in service_methods)
	missing_table := service_methods.filter(it !in table)
	mut sorted_missing_list := missing_list.clone()
	mut sorted_missing_table := missing_table.clone()
	sorted_missing_list.sort()
	sorted_missing_table.sort()
	if sorted_missing_list.len > 0 {
		differences << 'missing from the list: ' + public_api_backticked(sorted_missing_list)
	}
	if sorted_missing_table.len > 0 {
		differences << 'not in the cookbook table: ' + public_api_backticked(sorted_missing_table)
	}
	message := '`SERVICE_COOKBOOK_METHODS` is out of sync with the Formula Cookbook\'s "Service block methods" table: ${differences.join('; ')}.'
	return [public_api_constant_offense(source, 'SERVICE_COOKBOOK_METHODS', message)]
}

fn public_api_check_service_methods(source string, relative_path string, targets []int,
	service_methods []string) []PublicApiCookbookOffense {
	if relative_path != 'service.rb' {
		return []
	}
	mut offenses := []PublicApiCookbookOffense{}
	for definition in public_api_definitions(source).filter(it.kind == 'def') {
		annotated := definition.line in targets
		if definition.name in service_methods && !annotated {
			offenses << PublicApiCookbookOffense{
				begin_pos: definition.begin_pos
				end_pos: definition.end_pos
				line: definition.line
				message: 'Method `${definition.name}` is referenced in the Formula Cookbook but is not annotated with `@api public`.'
			}
		} else if annotated && definition.name !in service_methods {
			offenses << PublicApiCookbookOffense{
				begin_pos: definition.begin_pos
				end_pos: definition.end_pos
				line: definition.line
				message: 'Method `${definition.name}` is annotated with `@api public` in `service.rb` but is missing from the Formula Cookbook\'s "Service block methods" table.'
			}
		}
	}
	return offenses
}

pub fn audit_public_api_cookbook(context PublicApiCookbookContext) PublicApiCookbookAnalysis {
	formula_methods := (context.formula_cookbook_methods or {
		api_annotations.formula_cookbook_methods()
	}).clone()
	cask_methods := (context.cask_cookbook_methods or {
		api_annotations.cask_cookbook_methods()
	}).clone()
	service_methods := (context.service_cookbook_methods or {
		api_annotations.service_cookbook_methods()
	}).clone()
	markdown := context.formula_cookbook_markdown or { '' }
	mut offenses := []PublicApiCookbookOffense{}
	if context.relative_path == 'rubocops/shared/api_annotation_helper.rb' {
		mut missing_formula := public_api_rubydoc_methods(markdown).filter(it !in formula_methods)
		missing_formula.sort()
		if missing_formula.len > 0 {
			message := 'Formula Cookbook references methods missing from `FORMULA_COOKBOOK_METHODS`: ${public_api_backticked(missing_formula)}.'
			offenses << public_api_constant_offense(context.source, 'FORMULA_COOKBOOK_METHODS', message)
		}
		offenses << public_api_check_service_list(context.source, markdown, service_methods)
		return PublicApiCookbookAnalysis{
			offenses: offenses
		}
	}
	targets := public_api_targets(context.source)
	offenses << public_api_check_methods(context.source, formula_methods, 'Formula Cookbook', context.relative_path, targets)
	offenses << public_api_check_methods(context.source, cask_methods, 'Cask Cookbook', context.relative_path, targets)
	offenses << public_api_check_service_methods(context.source, context.relative_path, targets, service_methods)
	offenses << public_api_missing_cask_list(context.source, context.relative_path, cask_methods)
	return PublicApiCookbookAnalysis{
		offenses: offenses
	}
}

fn public_api_analysis_value(analysis PublicApiCookbookAnalysis) ruby.Value {
	return ruby.map_value({
		'offenses': ruby.array_value(analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
			'begin_pos': it.begin_pos.str()
			'end_pos':   it.end_pos.str()
			'line':      it.line.str()
			'message':   it.message
		})))
	})
}
