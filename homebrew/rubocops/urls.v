module rubocops

import brew_runtime
import homebrew.rubocops.@shared as url_shared
import homebrew.rubocops.extend as formula_cop

// Translated from Homebrew/brew `rubocops/urls.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn formula_urls_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
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

fn formula_urls_context(args []brew_runtime.Value) FormulaUrlsContext {
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

fn formula_urls_analysis_value(analysis FormulaUrlsAnalysis) brew_runtime.Value {
	return brew_runtime.array_value(analysis.offenses.map(url_shared.url_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 16.
pub fn ruby_urls_l16_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_urls_analysis_value(audit_formula_urls(formula_urls_context(args)))
}

// Ruby method `audit_formula(formula_nodes)` at line 66.
pub fn ruby_urls_l66_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_urls_analysis_value(audit_formula_http_urls(formula_urls_context(args)))
}

// Ruby method `audit_formula(formula_nodes)` at line 105.
pub fn ruby_urls_l105_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_urls_analysis_value(audit_formula_pypi_urls(formula_urls_context(args)))
}

// Ruby method `get_pypi_url(url)` at line 126.
pub fn ruby_urls_l126_d4_get_pypi_url(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len == 0 {
		formula_urls_nil()
	} else {
		brew_runtime.string_value(pypi_project_url(args[0].as_string()))
	}
}

// Ruby method `audit_formula(formula_nodes)` at line 136.
pub fn ruby_urls_l136_d5_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_urls_analysis_value(audit_formula_git_urls(formula_urls_context(args)))
}

// Ruby def_node_matcher `def_node_matcher :url_has_revision?, <<~EOS` at line 149.
pub fn ruby_urls_l149_d6_url_has_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && formula_url_has_string_key(args[0].as_string(), 'revision'))
}

// Ruby method `audit_formula(formula_nodes)` at line 159.
pub fn ruby_urls_l159_d7_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_urls_analysis_value(audit_formula_git_strict_urls(formula_urls_context(args)))
}

// Ruby def_node_matcher `def_node_matcher :url_has_tag?, <<~EOS` at line 172.
pub fn ruby_urls_l172_d8_url_has_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && formula_url_has_string_key(args[0].as_string(), 'tag'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/url_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `url`s and `mirror`s in formulae.
// 11:       class Urls < FormulaCop
// 12:         include UrlHelper
// 13:         extend AutoCorrector
// 14:
// 15:         sig { override.params(formula_nodes: FormulaNodes).void }
// 16:         def audit_formula(formula_nodes)
// 17:           return if (body_node = formula_nodes.body_node).nil?
// 18:
// 19:           urls = find_every_func_call_by_name(body_node, :url)
// 20:           mirrors = find_every_func_call_by_name(body_node, :mirror)
// 21:
// 22:           # Identify livecheck URLs, to skip some checks for them
// 23:           livecheck_urls = []
// 24:           find_every_func_call_by_name(body_node, :livecheck).each do |livecheck_node|
// 25:             livecheck_url = find_every_func_call_by_name(livecheck_node.parent, :url).first
// 26:             next unless livecheck_url
// 27:
// 28:             livecheck_url_argument = parameters(livecheck_url).first
// 29:             next unless livecheck_url_argument
// 30:             next if livecheck_url_argument.type == :sym
// 31:
// 32:             livecheck_urls << string_content(livecheck_url_argument)
// 33:           end
// 34:
// 35:           audit_url(:formula, urls, mirrors, livecheck_urls:)
// 36:
// 37:           return if formula_tap != "homebrew-core"
// 38:
// 39:           # Check for binary URLs
// 40:           binary_package_pattern = /(darwin|macos|osx)/i
// 41:           github_pattern = %r{^https://github\.com/[\w-]+/[\w.-]+/(.*)$}i
// 42:           audit_urls(urls, binary_package_pattern) do |match, url|
// 43:             next if T.must(@formula_name).include?(match.to_s.downcase)
// 44:             next if url.match?(/.(patch|diff)(\?full_index=1)?$/)
// 45:             next if url.match(github_pattern)&.then do |match_data|
// 46:               # For GitHub URLs, the username and repository name have no
// 47:               # bearing on whether a file is a binary package. We'll extract the
// 48:               # remainder of the URL and match against the binary pattern.
// 49:               # See: https://github.com/Homebrew/brew/pull/23236
// 50:               !match_data[1].match?(binary_package_pattern)
// 51:             end
// 52:             next if tap_style_exception? :not_a_binary_url_prefix_allowlist
// 53:             next if tap_style_exception? :binary_bootstrap_formula_urls_allowlist
// 54:
// 55:             problem "#{url} looks like a binary package, not a source archive; " \
// 56:                     "homebrew/core is source-only."
// 57:           end
// 58:         end
// 59:       end
// 60:
// 61:       # This cop makes sure that `url`s use HTTPS.
// 62:       class HttpUrls < FormulaCop
// 63:         extend AutoCorrector
// 64:
// 65:         sig { override.params(formula_nodes: FormulaNodes).void }
// 66:         def audit_formula(formula_nodes)
// 67:           return if (body_node = formula_nodes.body_node).nil?
// 68:           return if formula_tap != "homebrew-core"
// 69:           # TODO: Remove the deprecated/disabled check after homebrew/core has no more
// 70:           # deprecated/disabled formulae using http:// URLs
// 71:           return if method_called_ever?(body_node, :deprecate!) || method_called_ever?(body_node, :disable!)
// 72:
// 73:           # Identify livecheck URLs, to skip checking them
// 74:           livecheck_urls = []
// 75:           find_every_func_call_by_name(body_node, :livecheck).each do |livecheck_node|
// 76:             livecheck_url = find_every_func_call_by_name(livecheck_node.parent, :url).first
// 77:             next unless livecheck_url
// 78:
// 79:             livecheck_url_argument = parameters(livecheck_url).first
// 80:             next unless livecheck_url_argument
// 81:             next if livecheck_url_argument.type == :sym
// 82:
// 83:             livecheck_urls << string_content(livecheck_url_argument)
// 84:           end
// 85:
// 86:           find_every_func_call_by_name(body_node, :url).each do |url_node|
// 87:             url_string_node = parameters(url_node).first
// 88:             next unless url_string_node
// 89:
// 90:             url_string = string_content(url_string_node)
// 91:             next unless url_string.start_with?("http://")
// 92:             next if livecheck_urls.include?(url_string)
// 93:
// 94:             offending_node(url_string_node)
// 95:             problem "Formulae in homebrew/core should not use http:// URLs" do |corrector|
// 96:               corrector.replace(url_string_node.source_range, url_string_node.source.sub("http://", "https://"))
// 97:             end
// 98:           end
// 99:         end
// 100:       end
// 101:
// 102:       # This cop makes sure that the correct format for PyPI URLs is used.
// 103:       class PyPiUrls < FormulaCop
// 104:         sig { override.params(formula_nodes: FormulaNodes).void }
// 105:         def audit_formula(formula_nodes)
// 106:           return if (body_node = formula_nodes.body_node).nil?
// 107:
// 108:           urls = find_every_func_call_by_name(body_node, :url)
// 109:           mirrors = find_every_func_call_by_name(body_node, :mirror)
// 110:           urls += mirrors
// 111:
// 112:           # Check pypi URLs
// 113:           pypi_pattern = %r{^https?://pypi\.python\.org/}
// 114:           audit_urls(urls, pypi_pattern) do |_, url|
// 115:             problem "Use the \"Source\" URL found on the PyPI downloads page (#{get_pypi_url(url)})"
// 116:           end
// 117:
// 118:           # Require long files.pythonhosted.org URLs
// 119:           pythonhosted_pattern = %r{^https?://files\.pythonhosted\.org/packages/source/}
// 120:           audit_urls(urls, pythonhosted_pattern) do |_, url|
// 121:             problem "Use the \"Source\" URL found on the PyPI downloads page (#{get_pypi_url(url)})"
// 122:           end
// 123:         end
// 124:
// 125:         sig { params(url: String).returns(String) }
// 126:         def get_pypi_url(url)
// 127:           package_file = File.basename(url)
// 128:           package_name = T.must(package_file.match(/^(.+)-[a-z0-9.]+$/))[1]
// 129:           "https://pypi.org/project/#{package_name}/#files"
// 130:         end
// 131:       end
// 132:
// 133:       # This cop makes sure that git URLs have a `revision`.
// 134:       class GitUrls < FormulaCop
// 135:         sig { override.params(formula_nodes: FormulaNodes).void }
// 136:         def audit_formula(formula_nodes)
// 137:           return if (body_node = formula_nodes.body_node).nil?
// 138:           return if formula_tap != "homebrew-core"
// 139:
// 140:           find_method_calls_by_name(body_node, :url).each do |url|
// 141:             next unless string_content(parameters(url).fetch(0)).match?(/\.git$/)
// 142:             next if url_has_revision?(parameters(url).fetch(-1))
// 143:
// 144:             offending_node(url)
// 145:             problem "Formulae in homebrew/core should specify a revision for Git URLs"
// 146:           end
// 147:         end
// 148:
// 149:         def_node_matcher :url_has_revision?, <<~EOS
// 150:           (hash <(pair (sym :revision) str) ...>)
// 151:         EOS
// 152:       end
// 153:     end
// 154:
// 155:     module FormulaAuditStrict
// 156:       # This cop makes sure that git URLs have a `tag`.
// 157:       class GitUrls < FormulaCop
// 158:         sig { override.params(formula_nodes: FormulaNodes).void }
// 159:         def audit_formula(formula_nodes)
// 160:           return if (body_node = formula_nodes.body_node).nil?
// 161:           return if formula_tap != "homebrew-core"
// 162:
// 163:           find_method_calls_by_name(body_node, :url).each do |url|
// 164:             next unless string_content(parameters(url).fetch(0)).match?(/\.git$/)
// 165:             next if url_has_tag?(parameters(url).fetch(-1))
// 166:
// 167:             offending_node(url)
// 168:             problem "Formulae in homebrew/core should specify a tag for Git URLs"
// 169:           end
// 170:         end
// 171:
// 172:         def_node_matcher :url_has_tag?, <<~EOS
// 173:           (hash <(pair (sym :tag) str) ...>)
// 174:         EOS
// 175:       end
// 176:     end
// 177:   end
// 178: end
