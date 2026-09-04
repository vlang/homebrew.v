module rubocops

import ruby
import homebrew.rubocops.@shared as url_shared
import homebrew.rubocops.extend as formula_cop

// Translated from Homebrew/brew `rubocops/urls.rb`.
pub struct FormulaUrlsContext {
pub:
	source       string
	formula_tap  string
	formula_name string
	file_path    string
}

pub struct FormulaUrlsAnalysis {
pub:
	offenses  []url_shared.UrlProblem
	corrected string
}

fn formula_urls_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formula_urls_tap(value string) string {
	if value == 'homebrew-core' || value.contains('/homebrew-core/') {
		return 'homebrew-core'
	}
	if value == 'homebrew-cask' || value.contains('/homebrew-cask/') {
		return 'homebrew-cask'
	}
	return value.trim('/')
}

fn formula_urls_context(args []ruby.Value) FormulaUrlsContext {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	mut tap := if args.len > 1 { formula_urls_tap(args[1].as_string()) } else { '' }
	mut formula_name := if args.len > 2 { args[2].as_string() } else { '' }
	file_path := if args.len > 3 { args[3].as_string() } else { '' }
	if tap == '' && file_path != '' {
		tap = formula_cop.formula_cop_tap(file_path) or { '' }
	}
	if formula_name == '' && file_path != '' {
		formula_name = file_path.all_after_last('/').trim_string_right('.rb')
	}
	return FormulaUrlsContext{source, tap, formula_name, file_path}
}

fn formula_urls_collect_calls(node url_shared.HelperNode, name string) []url_shared.HelperNode {
	mut calls := []url_shared.HelperNode{}
	if node.kind == 'send' && node.name == name && !node.has_receiver {
		calls << node
	}
	for child in node.children {
		calls << formula_urls_collect_calls(child, name)
	}
	return calls
}

fn formula_urls_direct_calls(node url_shared.HelperNode, name string) []url_shared.HelperNode {
	mut calls := []url_shared.HelperNode{}
	if node.kind == 'send' && node.name == name && !node.has_receiver {
		calls << node
	}
	for child in node.children {
		if child.kind == 'send' && child.name == name && !child.has_receiver {
			calls << child
		}
	}
	return calls
}

fn formula_urls_parse(source string) ?url_shared.HelperProcessedSource {
	if source.trim_space() == '' {
		return none
	}
	return url_shared.helper_processed_source(source) or { return none }
}

fn formula_urls_node(call url_shared.HelperNode) ?url_shared.UrlAuditNode {
	parameters := url_shared.helper_parameters(call)
	if parameters.len == 0 {
		return none
	}
	argument := parameters[0]
	if argument.kind == 'sym' {
		return none
	}
	return url_shared.UrlAuditNode{
		source: call.source
		content: url_shared.helper_string_content(argument, false)
		begin_pos: call.source_range.begin_pos
		end_pos: call.source_range.end_pos
		argument_begin: argument.source_range.begin_pos
		argument_end: argument.source_range.end_pos
	}
}

fn formula_urls_nodes(calls []url_shared.HelperNode) []url_shared.UrlAuditNode {
	mut nodes := []url_shared.UrlAuditNode{}
	for call in calls {
		if node := formula_urls_node(call) {
			nodes << node
		}
	}
	return nodes
}

fn formula_urls_livecheck_urls(root url_shared.HelperNode) []string {
	mut urls := []string{}
	if root.kind == 'block' && root.name == 'livecheck' && !root.has_receiver {
		calls := formula_urls_collect_calls(root, 'url')
		if calls.len > 0 {
			parameters := url_shared.helper_parameters(calls[0])
			if parameters.len > 0 && parameters[0].kind != 'sym' {
				urls << url_shared.helper_string_content(parameters[0], false)
			}
		}
	}
	for child in root.children {
		urls << formula_urls_livecheck_urls(child)
	}
	return urls
}

fn formula_urls_problem(kind string, node url_shared.UrlAuditNode, message string) url_shared.UrlProblem {
	return url_shared.UrlProblem{
		kind: kind
		url: node.content
		begin_pos: node.begin_pos
		end_pos: node.end_pos
		message: message
	}
}

fn formula_urls_argument_problem(kind string, node url_shared.UrlAuditNode, message string,
	replacement string) url_shared.UrlProblem {
	return url_shared.UrlProblem{
		kind: kind
		url: node.content
		begin_pos: node.argument_begin
		end_pos: node.argument_end
		message: message
		has_correction: replacement != ''
		replacement_begin: node.argument_begin
		replacement_end: node.argument_end
		replacement: replacement
	}
}

fn formula_urls_binary_match(url string) ?string {
	lower := url.to_lower()
	mut found := ''
	mut found_at := lower.len + 1
	for candidate in ['darwin', 'macos', 'osx'] {
		if position := lower.index(candidate) {
			if position < found_at {
				found = candidate
				found_at = position
			}
		}
	}
	return if found == '' { none } else { found }
}

fn formula_urls_github_remainder(url string) ?string {
	prefix := 'https://github.com/'
	if !url.to_lower().starts_with(prefix) {
		return none
	}
	parts := url[prefix.len..].split('/')
	if parts.len < 3 || parts[0] == '' || parts[1] == '' {
		return none
	}
	if !parts[0].bytes().all(it.is_alnum() || it in [`_`, `-`]) || !parts[1].bytes().all(it.is_alnum() || it in [
		`_`,
		`-`,
		`.`,
	]) {
		return none
	}
	return parts[2..].join('/')
}

fn formula_urls_patch_or_diff(url string) bool {
	value := if url.ends_with('?full_index=1') {
		url[..url.len - '?full_index=1'.len]
	} else {
		url
	}
	// The period in the pinned Ruby regexp is intentionally unescaped, so any
	// single character immediately before the suffix satisfies the exemption.
	return (value.len > 'patch'.len && value.ends_with('patch')) || (value.len > 'diff'.len && value.ends_with('diff'))
}

pub fn audit_formula_urls(context FormulaUrlsContext) FormulaUrlsAnalysis {
	processed := formula_urls_parse(context.source) or {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	urls := formula_urls_nodes(formula_urls_collect_calls(processed.ast, 'url'))
	mirrors := formula_urls_nodes(formula_urls_collect_calls(processed.ast, 'mirror'))
	livecheck_urls := formula_urls_livecheck_urls(processed.ast)
	mut offenses := url_shared.audit_url_nodes('formula', urls, mirrors, livecheck_urls)
	if context.formula_tap == 'homebrew-core' {
		for node in urls {
			matched := formula_urls_binary_match(node.content) or { continue }
			if context.formula_name.contains(matched) || formula_urls_patch_or_diff(node.content) {
				continue
			}
			if remainder := formula_urls_github_remainder(node.content) {
				if formula_urls_binary_match(remainder) == none {
					continue
				}
			}
			if context.file_path != '' && (formula_cop.formula_cop_style_exception(context.file_path, 'not_a_binary_url_prefix_allowlist', context.formula_name) || formula_cop.formula_cop_style_exception(context.file_path, 'binary_bootstrap_formula_urls_allowlist', context.formula_name)) {
				continue
			}
			offenses << formula_urls_problem('binary_package', node, '${node.content} looks like a binary package, not a source archive; homebrew/core is source-only.')
		}
	}
	return FormulaUrlsAnalysis{
		offenses: offenses
		corrected: url_shared.correct_url_problems(context.source, offenses)
	}
}

pub fn audit_formula_http_urls(context FormulaUrlsContext) FormulaUrlsAnalysis {
	processed := formula_urls_parse(context.source) or {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	if context.formula_tap != 'homebrew-core' || formula_urls_collect_calls(processed.ast, 'deprecate!').len > 0 || formula_urls_collect_calls(processed.ast, 'disable!').len > 0 {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	livecheck_urls := formula_urls_livecheck_urls(processed.ast)
	mut offenses := []url_shared.UrlProblem{}
	for node in formula_urls_nodes(formula_urls_collect_calls(processed.ast, 'url')) {
		if !node.content.starts_with('http://') || node.content in livecheck_urls {
			continue
		}
		argument_source := context.source[node.argument_begin..node.argument_end]
		offenses << formula_urls_argument_problem('http', node, 'Formulae in homebrew/core should not use http:// URLs', argument_source.replace_once('http://', 'https://'))
	}
	return FormulaUrlsAnalysis{
		offenses: offenses
		corrected: url_shared.correct_url_problems(context.source, offenses)
	}
}

pub fn pypi_project_url(url string) string {
	package_file := url.all_after_last('/')
	mut package_name := package_file
	if separator := package_file.last_index('-') {
		suffix := package_file[separator + 1..]
		if suffix != '' && suffix.bytes().all(it.is_digit() || (it >= `a` && it <= `z`) || it == `.`) {
			package_name = package_file[..separator]
		}
	}
	return 'https://pypi.org/project/${package_name}/#files'
}

pub fn audit_formula_pypi_urls(context FormulaUrlsContext) FormulaUrlsAnalysis {
	processed := formula_urls_parse(context.source) or {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	mut nodes := formula_urls_nodes(formula_urls_collect_calls(processed.ast, 'url'))
	nodes << formula_urls_nodes(formula_urls_collect_calls(processed.ast, 'mirror'))
	mut offenses := []url_shared.UrlProblem{}
	for node in nodes {
		if node.content.starts_with('http://pypi.python.org/') || node.content.starts_with('https://pypi.python.org/') || node.content.starts_with('http://files.pythonhosted.org/packages/source/') || node.content.starts_with('https://files.pythonhosted.org/packages/source/') {
			offenses << formula_urls_problem('pypi', node, 'Use the "Source" URL found on the PyPI downloads page (${pypi_project_url(node.content)})')
		}
	}
	return FormulaUrlsAnalysis{
		offenses: offenses
		corrected: context.source
	}
}

fn formula_urls_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	return position
}

fn formula_urls_quoted_value(source string, start int) bool {
	position := formula_urls_skip_space(source, start)
	return position < source.len && source[position] in [`'`, `\"`]
}

pub fn formula_url_has_string_key(source string, key string) bool {
	mut position := 0
	mut quote := u8(0)
	mut escaped := false
	for position < source.len {
		character := source[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `\"`] {
			quote = character
			position++
			continue
		}
		if character == `#` {
			newline := source[position..].index_u8(`\n`)
			if newline < 0 {
				break
			}
			position += newline + 1
			continue
		}
		if source[position..].starts_with(key) {
			before_ok := position == 0 || !(source[position - 1].is_alnum() || source[position - 1] == `_` || source[position - 1] == `:`)
			after := position + key.len
			if before_ok && after < source.len && source[after] == `:` && formula_urls_quoted_value(source, after + 1) {
				return true
			}
		}
		if character == `:` && position + 1 < source.len && source[position + 1..].starts_with(key) {
			after_key := position + 1 + key.len
			if after_key == source.len || !(source[after_key].is_alnum() || source[after_key] == `_`) {
				mut after := formula_urls_skip_space(source, after_key)
				if after + 1 < source.len && source[after..].starts_with('=>') {
					after = formula_urls_skip_space(source, after + 2)
					if formula_urls_quoted_value(source, after) {
						return true
					}
				}
			}
		}
		position++
	}
	return false
}

fn audit_formula_git_key(context FormulaUrlsContext, key string, strict bool) FormulaUrlsAnalysis {
	processed := formula_urls_parse(context.source) or {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	if context.formula_tap != 'homebrew-core' {
		return FormulaUrlsAnalysis{ corrected: context.source }
	}
	mut offenses := []url_shared.UrlProblem{}
	for node in formula_urls_nodes(formula_urls_direct_calls(processed.ast, 'url')) {
		if !node.content.ends_with('.git') || formula_url_has_string_key(node.source, key) {
			continue
		}
		prefix := if strict { 'tag' } else { 'revision' }
		offenses << formula_urls_problem('git_${prefix}', node, 'Formulae in homebrew/core should specify a ${prefix} for Git URLs')
	}
	return FormulaUrlsAnalysis{
		offenses: offenses
		corrected: context.source
	}
}

pub fn audit_formula_git_urls(context FormulaUrlsContext) FormulaUrlsAnalysis {
	return audit_formula_git_key(context, 'revision', false)
}

pub fn audit_formula_git_strict_urls(context FormulaUrlsContext) FormulaUrlsAnalysis {
	return audit_formula_git_key(context, 'tag', true)
}

fn formula_urls_analysis_value(analysis FormulaUrlsAnalysis) ruby.Value {
	return ruby.array_value(analysis.offenses.map(url_shared.url_problem_value(it)))
}
