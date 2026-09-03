module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/patches.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaPatchesContext {
pub:
	source string
}

pub struct FormulaPatchNode {
pub:
	source    string
	value     string
	kind      string
	begin_pos int
	end_pos   int
}

pub struct FormulaPatchOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
}

struct FormulaPatchEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

pub struct FormulaPatchesAnalysis {
pub:
	offenses  []FormulaPatchOffense
	corrected string
}

struct FormulaPatchFinding {
	offenses []FormulaPatchOffense
	edits    []FormulaPatchEdit
}

struct FormulaPatchRegion {
	begin_pos int
	end_pos   int
}

const formula_patch_types = ['unofficial', 'backport', 'cherry_pick']

fn formula_patch_node_from_argument(call LinesCall, argument string) FormulaPatchNode {
	argument_index := call.source.index(argument) or { call.target.len }
	begin_pos := call.begin_pos + argument_index
	trimmed := argument.trim_space()
	if trimmed.len >= 2 && ((trimmed[0] == `"` && trimmed[trimmed.len - 1] == `"`) || (trimmed[0] == `'` && trimmed[trimmed.len - 1] == `'`)) {
		return FormulaPatchNode{
			source: trimmed
			value: trimmed[1..trimmed.len - 1]
			kind: 'string'
			begin_pos: begin_pos
			end_pos: begin_pos + trimmed.len
		}
	}
	if trimmed.starts_with(':') {
		return FormulaPatchNode{
			source: trimmed
			value: trimmed.trim_left(':')
			kind: 'symbol'
			begin_pos: begin_pos
			end_pos: begin_pos + trimmed.len
		}
	}
	return FormulaPatchNode{
		source: trimmed
		value: trimmed
		kind: 'expression'
		begin_pos: begin_pos
		end_pos: begin_pos + trimmed.len
	}
}

fn formula_patch_regions(source string, header fn(string) bool) []FormulaPatchRegion {
	lines := lines_source_lines(source)
	mut regions := []FormulaPatchRegion{}
	for index, line in lines {
		if !header(lines_code(line.text).trim_space()) {
			continue
		}
		closing := lines_matching_end(lines, index)
		if closing >= 0 {
			regions << FormulaPatchRegion{
				begin_pos: line.start
				end_pos: lines[closing].newline_end
			}
		}
	}
	return regions
}

fn formula_patch_block_header(line string) bool {
	return (line == 'patch do' || line.starts_with('patch ')) && line.ends_with(' do')
}

fn formula_patch_legacy_header(line string) bool {
	return line == 'def patches' || line.starts_with('def patches(')
}

fn formula_patch_in_region(position int, region FormulaPatchRegion) bool {
	return position >= region.begin_pos && position < region.end_pos
}

fn formula_patch_end(source string) bool {
	return lines_source_lines(source).any(it.text == '__END__')
}

fn formula_patch_end_node(source string) ?FormulaPatchNode {
	for line in lines_source_lines(source) {
		if line.text == '__END__' {
			return FormulaPatchNode{
				source: '__END__'
				value: '__END__'
				kind: 'keyword'
				begin_pos: line.start
				end_pos: line.end
			}
		}
	}
	return none
}

fn formula_patch_hex(value string) bool {
	return value != '' && value.bytes().all(it.is_digit() || it in [`a`, `b`, `c`, `d`, `e`, `f`,
		`A`, `B`, `C`, `D`, `E`, `F`])
}

fn formula_patch_hex_or_empty(value string) bool {
	return value == '' || formula_patch_hex(value)
}

fn formula_patch_github_commit_diff(url string) bool {
	if !url.starts_with('https://github.com/') || !url.contains('/commit/') {
		return false
	}
	commit_and_suffix := url.all_after('/commit/')
	commit := commit_and_suffix.all_before('.diff')
	return commit_and_suffix.contains('.diff') && formula_patch_hex_or_empty(commit)
}

fn formula_patch_gitlab_commit_patch(url string) bool {
	if !url.contains('gitlab') || !url.contains('/commit/') || !url.contains('.patch') {
		return false
	}
	commit := url.all_after('/commit/').all_before('.patch')
	return formula_patch_hex_or_empty(commit)
}

fn formula_patch_github_download(url string) bool {
	if !(url.starts_with('http://github.com/') || url.starts_with('https://github.com/')) {
		return false
	}
	path := url.all_after('github.com/')
	parts := path.split('/')
	if parts.len < 4 || parts[0] == '' || parts[1] == '' || parts[2] !in ['commit', 'pull'] {
		return false
	}
	id_and_suffix := parts[3].all_before('?')
	for suffix in ['.patch', '.diff'] {
		if id_and_suffix.ends_with(suffix) && formula_patch_hex_or_empty(id_and_suffix.trim_string_right(suffix)) {
			return true
		}
	}
	return false
}

fn formula_patch_full_index(url string) bool {
	if !url.contains('?full_index=') {
		return false
	}
	value := url.all_after_last('?full_index=')
	return value != '' && value.bytes().all(it.is_alnum() || it == `_`)
}

fn formula_patch_has_github_revision(url string) bool {
	parts := url.split('/')
	for index, part in parts {
		candidate := part.all_before('?')
		if index < parts.len - 1 && candidate.len >= 6 && candidate.len <= 40 && formula_patch_hex(candidate) {
			return true
		}
	}
	return false
}

fn formula_patch_diff_url(url string) bool {
	return (url.starts_with('http://patch-diff.githubusercontent.com/raw/') || url.starts_with('https://patch-diff.githubusercontent.com/raw/')) && url.contains('/pull/') && (url.ends_with('.diff') || url.ends_with('.patch'))
}

fn formula_patch_bitbucket_api_url(url string) ?string {
	if !url.contains('bitbucket.org/') || !url.contains('/commits/') || !url.ends_with('/raw') {
		return none
	}
	path := url.all_after('bitbucket.org/')
	parts := path.split('/')
	if parts.len < 5 || parts[2] != 'commits' || parts[4] != 'raw' || !formula_patch_hex(parts[3]) {
		return none
	}
	return 'https://api.bitbucket.org/2.0/repositories/${parts[0]}/${parts[1]}/diff/${parts[3]}'
}

fn formula_patch_url_finding(node FormulaPatchNode, sha ?FormulaPatchNode) FormulaPatchFinding {
	url := node.value
	mut message := ''
	mut corrected_url := url
	mut reset_sha := false

	if url.starts_with('https://github.com/') && url.all_after('github.com/').split('/').len >= 3 && url.all_after('github.com/').split('/')[2] == 'pull' {
		message = 'Use a commit hash URL rather than an unstable pull request URL: ${url}'
	} else if url.contains('gitlab') && url.contains('/merge_request') {
		message = 'Use a commit hash URL rather than an unstable merge request URL: ${url}'
	} else if formula_patch_github_commit_diff(url) {
		message = 'GitHub patches should end with .patch, not .diff: ${url}'
		corrected_url = corrected_url.replace_once('.diff', '.patch')
		reset_sha = true
	} else if api_url := formula_patch_bitbucket_api_url(url) {
		message = 'Bitbucket patches should use the API URL: ${api_url}'
		corrected_url = api_url
		reset_sha = true
	} else if formula_patch_gitlab_commit_patch(url) {
		message = 'GitLab patches should end with .diff, not .patch: ${url}'
		corrected_url = corrected_url.replace_once('.patch', '.diff')
		reset_sha = true
	} else if formula_patch_github_download(url) && !formula_patch_full_index(url) {
		message = 'GitHub patches should use the full_index parameter: ${url}?full_index=1'
		reset_sha = true
	} else {
		raw_github := url.contains('/raw.github.com/') || url.contains('/raw.githubusercontent.com/') || url.contains('gist.github.com/raw') || (url.contains('gist.github.com/') && url.contains('/raw')) || (url.contains('gist.githubusercontent.com/') && url.contains('/raw'))
		if raw_github && !formula_patch_has_github_revision(url) {
			message = 'GitHub/Gist patches should specify a revision: ${url}'
		} else if formula_patch_diff_url(url) {
			message = 'Use a commit hash URL rather than patch-diff: ${url}'
		} else if url.contains('macports/trunk') {
			message = 'MacPorts patches should specify a revision instead of trunk: ${url}'
		} else if url.starts_with('http://trac.macports.org') {
			message = 'Patches from MacPorts Trac should be https://, not http: ${url}'
			corrected_url = 'https://' + url.all_after('http://')
		} else if url.starts_with('http://bugs.debian.org') {
			message = 'Patches from Debian should be https://, not http: ${url}'
			corrected_url = 'https://' + url.all_after('http://')
		}
	}

	if formula_patch_github_download(url) && !formula_patch_full_index(url) {
		corrected_url += '?full_index=1'
		reset_sha = true
	}
	if message == '' {
		return FormulaPatchFinding{}
	}
	mut edits := []FormulaPatchEdit{}
	if corrected_url != url {
		edits << FormulaPatchEdit{
			begin_pos: node.begin_pos
			end_pos: node.end_pos
			replacement: '"${corrected_url}"'
		}
	}
	if reset_sha {
		if sha_node := sha {
			edits << FormulaPatchEdit{
				begin_pos: sha_node.begin_pos
				end_pos: sha_node.end_pos
				replacement: '""'
			}
		}
	}
	return FormulaPatchFinding{
		offenses: [FormulaPatchOffense{
			begin_pos: node.begin_pos
			end_pos: node.end_pos
			message: message
		}]
		edits: edits
	}
}

fn formula_patch_valid_cve(value string) bool {
	parts := value.split('-')
	return parts.len == 3 && parts[0] == 'CVE' && parts[1].len == 4 && parts[1].bytes().all(it.is_digit()) && parts[2].len >= 4 && parts[2].bytes().all(it.is_digit())
}

fn formula_patch_valid_ghsa(value string) bool {
	parts := value.split('-')
	allowed := '23456789cfghjmpqrvwx'
	if parts.len != 4 || parts[0] != 'GHSA' {
		return false
	}
	for group in parts[1..] {
		if group.len != 4 || !group.bytes().all(allowed.contains(it.ascii_str())) {
			return false
		}
	}
	return true
}

fn formula_patch_valid_osv(value string) bool {
	parts := value.split('-')
	return parts.len == 3 && parts[0] == 'OSV' && parts[1].len == 4 && parts[1].bytes().all(it.is_digit()) && parts[2] != '' && parts[2].bytes().all(it.is_digit())
}

fn formula_patch_resolves_finding(node FormulaPatchNode) FormulaPatchFinding {
	if node.kind != 'string' {
		return FormulaPatchFinding{
			offenses: [FormulaPatchOffense{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				message: '`resolves` should be passed identifier strings (CVE/GHSA/OSV id or issue URL)'
			}]
		}
	}
	value := node.value
	if formula_patch_valid_cve(value) || formula_patch_valid_ghsa(value) || formula_patch_valid_osv(value) || value.starts_with('http://') || value.starts_with('https://') {
		return FormulaPatchFinding{}
	}
	upper := value.to_upper()
	mut canonical := ''
	if upper.starts_with('CVE') {
		remainder := upper.all_after('CVE').trim_left('-')
		parts := remainder.split('-')
		if parts.len == 2 && parts[0].len == 4 && parts[0].bytes().all(it.is_digit()) && parts[1].len >= 4 && parts[1].bytes().all(it.is_digit()) {
			canonical = 'CVE-${parts[0]}-${parts[1]}'
		}
	}
	if canonical != '' {
		return FormulaPatchFinding{
			offenses: [FormulaPatchOffense{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				message: '`resolves` should use the canonical CVE format: ${canonical}'
			}]
			edits: [FormulaPatchEdit{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				replacement: '"${canonical}"'
			}]
		}
	}
	return FormulaPatchFinding{
		offenses: [FormulaPatchOffense{
			begin_pos: node.begin_pos
			end_pos: node.end_pos
			message: '`resolves` should be a CVE/GHSA/OSV identifier or issue URL, got: "${value}"'
		}]
	}
}

fn formula_patch_type_finding(node FormulaPatchNode) FormulaPatchFinding {
	if node.kind == 'symbol' && node.value in formula_patch_types {
		return FormulaPatchFinding{}
	}
	return FormulaPatchFinding{
		offenses: [FormulaPatchOffense{
			begin_pos: node.begin_pos
			end_pos: node.end_pos
			message: 'Patch `type` should be one of: :unofficial, :backport, :cherry_pick'
		}]
	}
}

fn formula_patch_apply_edits(source string, edits []FormulaPatchEdit) string {
	mut corrected := source
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	for edit in ordered {
		corrected = corrected[..edit.begin_pos] + edit.replacement + corrected[edit.end_pos..]
	}
	return corrected
}

fn formula_patch_string_nodes(source string, region FormulaPatchRegion) []FormulaPatchNode {
	mut nodes := []FormulaPatchNode{}
	mut index := region.begin_pos
	for index < region.end_pos {
		if source[index] !in [`'`, `"`] {
			index++
			continue
		}
		quote := source[index]
		mut closing := index + 1
		mut escaped := false
		for closing < region.end_pos {
			if escaped {
				escaped = false
				closing++
				continue
			}
			if source[closing] == `\\` {
				escaped = true
				closing++
				continue
			}
			if source[closing] == quote {
				break
			}
			closing++
		}
		if closing >= region.end_pos {
			break
		}
		mut value := source[index + 1..closing]
		if value.contains(r'#{') {
			value = value.all_before(r'#{')
		}
		nodes << FormulaPatchNode{
			source: source[index..closing + 1]
			value: value
			kind: 'string'
			begin_pos: index
			end_pos: closing + 1
		}
		index = closing + 1
	}
	return nodes
}

pub fn audit_formula_patches(context FormulaPatchesContext) FormulaPatchesAnalysis {
	source := context.source
	end_node := formula_patch_end_node(source)
	ruby_source := if node := end_node { source[..node.begin_pos] } else { source }
	mut offenses := []FormulaPatchOffense{}
	mut edits := []FormulaPatchEdit{}
	patch_calls := lines_find_calls(ruby_source, 'patch')
	block_regions := formula_patch_regions(ruby_source, formula_patch_block_header)
	for region in block_regions {
		sha_calls := lines_find_calls(ruby_source, 'sha256').filter(formula_patch_in_region(it.begin_pos, region))
		sha := if sha_calls.len > 0 && sha_calls[0].arguments.len > 0 {
			?FormulaPatchNode(formula_patch_node_from_argument(sha_calls[0], sha_calls[0].arguments[0]))
		} else {
			none
		}
		for call in lines_find_calls(ruby_source, 'url') {
			if !formula_patch_in_region(call.begin_pos, region) || call.arguments.len == 0 {
				continue
			}
			finding := formula_patch_url_finding(formula_patch_node_from_argument(call, call.arguments[0]), sha)
			offenses << finding.offenses
			edits << finding.edits
		}
		for call in lines_find_calls(ruby_source, 'resolves') {
			if !formula_patch_in_region(call.begin_pos, region) {
				continue
			}
			for argument in call.arguments {
				finding := formula_patch_resolves_finding(formula_patch_node_from_argument(call, argument))
				offenses << finding.offenses
				edits << finding.edits
			}
		}
		for call in lines_find_calls(ruby_source, 'type') {
			if !formula_patch_in_region(call.begin_pos, region) {
				continue
			}
			for argument in call.arguments {
				finding := formula_patch_type_finding(formula_patch_node_from_argument(call, argument))
				offenses << finding.offenses
			}
		}
	}

	if !formula_patch_end(source) {
		for call in patch_calls {
			if call.arguments.len > 0 && call.arguments[0].trim_space() == ':DATA' {
				offenses << FormulaPatchOffense{
					begin_pos: call.begin_pos
					end_pos: call.end_pos
					message: 'Patch is missing `__END__`'
				}
			}
		}
	} else if patch_calls.len == 0 {
		if node := end_node {
			offenses << FormulaPatchOffense{
				begin_pos: node.begin_pos
				end_pos: node.end_pos
				message: 'Patch is missing `patch :DATA`'
			}
		}
	}

	for region in formula_patch_regions(ruby_source, formula_patch_legacy_header) {
		lines := lines_source_lines(ruby_source)
		for line in lines {
			if line.start == region.begin_pos {
				start := line.text.index('def patches') or { 0 }
				offenses << FormulaPatchOffense{
					begin_pos: line.start + start
					end_pos: line.start + start + 'def patches'.len
					message: 'Use the `patch` DSL instead of defining a `patches` method'
				}
				break
			}
		}
		for node in formula_patch_string_nodes(source, region) {
			finding := formula_patch_url_finding(node, none)
			offenses << finding.offenses
			edits << finding.edits
		}
	}

	return FormulaPatchesAnalysis{
		offenses: offenses
		corrected: formula_patch_apply_edits(source, edits)
	}
}

fn formula_patch_analysis_value(analysis FormulaPatchesAnalysis) brew_runtime.Value {
	return brew_runtime.map_value({
		'offenses':  brew_runtime.array_value(analysis.offenses.map(brew_runtime.structured_value('RuboCop::Cop::Offense', it.message, {
			'begin_pos': it.begin_pos.str()
			'end_pos':   it.end_pos.str()
			'message':   it.message
		})))
		'corrected': brew_runtime.string_value(analysis.corrected)
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_patches_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'source is required')
	}
	return formula_patch_analysis_value(audit_formula_patches(FormulaPatchesContext{
		source: args[0].as_string()
	}))
}

// Ruby method `patch_problems(patch_url_node, sha256_node)` at line 58.
pub fn ruby_patches_l58_d2_patch_problems(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return formula_patch_analysis_value(FormulaPatchesAnalysis{})
	}
	url := args[0].as_string()
	node := FormulaPatchNode{
		source: '"${url}"'
		value: url
		kind: 'string'
		end_pos: url.len + 2
	}
	sha := if args.len > 1 {
		?FormulaPatchNode(FormulaPatchNode{
			source: args[1].as_string()
			value: args[1].as_string()
			kind: 'string'
		})
	} else {
		none
	}
	finding := formula_patch_url_finding(node, sha)
	return formula_patch_analysis_value(FormulaPatchesAnalysis{
		offenses: finding.offenses
		corrected: if finding.edits.len > 0 {
			finding.edits[0].replacement} else {
			node.source}
	})
}

// Ruby method `resolves_problems(node)` at line 143.
pub fn ruby_patches_l143_d3_resolves_problems(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return formula_patch_analysis_value(FormulaPatchesAnalysis{})
	}
	node := FormulaPatchNode{
		source: args[0].as_string()
		value: args[0].as_string().trim('"\'')
		kind: if args[0].type_name == 'String' { 'string' } else { 'expression' }
		end_pos: args[0].as_string().len
	}
	finding := formula_patch_resolves_finding(node)
	return formula_patch_analysis_value(FormulaPatchesAnalysis{
		offenses: finding.offenses
		corrected: if finding.edits.len > 0 {
			finding.edits[0].replacement} else {
			node.source}
	})
}

// Ruby method `type_problems(node)` at line 168.
pub fn ruby_patches_l168_d4_type_problems(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return formula_patch_analysis_value(FormulaPatchesAnalysis{})
	}
	raw := args[0].as_string()
	node := FormulaPatchNode{
		source: raw
		value: raw.trim_left(':')
		kind: if raw.starts_with(':') { 'symbol' } else { 'expression' }
		end_pos: raw.len
	}
	finding := formula_patch_type_finding(node)
	return formula_patch_analysis_value(FormulaPatchesAnalysis{
		offenses: finding.offenses
		corrected: raw
	})
}

// Ruby method `inline_patch_problems(patch)` at line 176.
pub fn ruby_patches_l176_d5_inline_patch_problems(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return formula_patch_analysis_value(audit_formula_patches(FormulaPatchesContext{
		source: source
	}))
}

// Ruby def_node_search `def_node_search :patch_data?, <<~AST` at line 183.
pub fn ruby_patches_l183_d6_patch_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && lines_find_calls(args[0].as_string(), 'patch').any(it.arguments.len > 0 && it.arguments[0].trim_space() == ':DATA'))
}

// Ruby method `patch_end?` at line 188.
pub fn ruby_patches_l188_d7_patch_end(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && formula_patch_end(args[0].as_string()))
}

// Ruby method `offending_patch_end_node(node)` at line 193.
pub fn ruby_patches_l193_d8_offending_patch_end_node(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		if node := formula_patch_end_node(args[0].as_string()) {
			return brew_runtime.structured_value('Parser::Source::Range', node.source, {
				'begin_pos':   node.begin_pos.str()
				'end_pos':     node.end_pos.str()
				'line_length': '7'
			})
		}
	}
	return brew_runtime.object_value('NilClass', 'nil')
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
// 9:       # This cop audits `patch`es in formulae.
// 10:       class Patches < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         # Keep in sync with `Patch::TYPES` in `Library/Homebrew/patch.rb`.
// 14:         PATCH_TYPES = [:unofficial, :backport, :cherry_pick].freeze
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           node = formula_nodes.node
// 19:           @full_source_content = T.let(source_buffer(node).source, T.nilable(String))
// 20:
// 21:           return if (body_node = formula_nodes.body_node).nil?
// 22:
// 23:           external_patches = find_all_blocks(body_node, :patch)
// 24:           external_patches.each do |patch_block|
// 25:             find_every_method_call_by_name(patch_block, :url).each do |url_node|
// 26:               url_string = parameters(url_node).fetch(0)
// 27:               sha256_node = find_every_method_call_by_name(patch_block, :sha256).first
// 28:               sha256_string = parameters(sha256_node).first if sha256_node
// 29:               patch_problems(url_string, sha256_string)
// 30:             end
// 31:             find_every_method_call_by_name(patch_block, :resolves).each do |resolves_node|
// 32:               parameters(resolves_node).each { |arg| resolves_problems(arg) }
// 33:             end
// 34:             find_every_method_call_by_name(patch_block, :type).each do |type_node|
// 35:               parameters(type_node).each { |arg| type_problems(arg) }
// 36:             end
// 37:           end
// 38:
// 39:           inline_patches = find_every_method_call_by_name(body_node, :patch)
// 40:           inline_patches.each { |patch| inline_patch_problems(patch) }
// 41:
// 42:           if inline_patches.empty? && patch_end?
// 43:             offending_patch_end_node(node)
// 44:             add_offense(@offense_source_range, message: "Patch is missing `patch :DATA`")
// 45:           end
// 46:
// 47:           patches_node = find_method_def(body_node, :patches)
// 48:           return if patches_node.nil?
// 49:
// 50:           legacy_patches = find_strings(patches_node)
// 51:           problem "Use the `patch` DSL instead of defining a `patches` method"
// 52:           legacy_patches.each { |p| patch_problems(p, nil) }
// 53:         end
// 54:
// 55:         private
// 56:
// 57:         sig { params(patch_url_node: RuboCop::AST::Node, sha256_node: T.nilable(RuboCop::AST::Node)).void }
// 58:         def patch_problems(patch_url_node, sha256_node)
// 59:           patch_url = string_content(patch_url_node)
// 60:
// 61:           if regex_match_group(patch_url_node, %r{https://github.com/[^/]*/[^/]*/pull})
// 62:             problem "Use a commit hash URL rather than an unstable pull request URL: #{patch_url}"
// 63:           end
// 64:
// 65:           if regex_match_group(patch_url_node, %r{.*gitlab.*/merge_request.*})
// 66:             problem "Use a commit hash URL rather than an unstable merge request URL: #{patch_url}"
// 67:           end
// 68:
// 69:           if regex_match_group(patch_url_node, %r{https://github.com/[^/]*/[^/]*/commit/[a-fA-F0-9]*\.diff})
// 70:             problem "GitHub patches should end with .patch, not .diff: #{patch_url}" do |corrector|
// 71:               # Replace .diff with .patch, keeping either the closing quote or query parameter start
// 72:               correct = patch_url_node.source.sub(/\.diff(["?])/, '.patch\1')
// 73:               corrector.replace(patch_url_node.source_range, correct)
// 74:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 75:             end
// 76:           end
// 77:
// 78:           bitbucket_regex = %r{bitbucket\.org/([^/]+)/([^/]+)/commits/([a-f0-9]+)/raw}i
// 79:           if regex_match_group(patch_url_node, bitbucket_regex)
// 80:             owner, repo, commit = patch_url_node.source.match(bitbucket_regex).captures
// 81:             correct_url = "https://api.bitbucket.org/2.0/repositories/#{owner}/#{repo}/diff/#{commit}"
// 82:             problem "Bitbucket patches should use the API URL: #{correct_url}" do |corrector|
// 83:               corrector.replace(patch_url_node.source_range, %Q("#{correct_url}"))
// 84:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 85:             end
// 86:           end
// 87:
// 88:           # Only .diff passes `--full-index` to `git diff` and there is no documented way
// 89:           # to get .patch to behave the same for GitLab.
// 90:           if regex_match_group(patch_url_node, %r{.*gitlab.*/commit/[a-fA-F0-9]*\.patch})
// 91:             problem "GitLab patches should end with .diff, not .patch: #{patch_url}" do |corrector|
// 92:               # Replace .patch with .diff, keeping either the closing quote or query parameter start
// 93:               correct = patch_url_node.source.sub(/\.patch(["?])/, '.diff\1')
// 94:               corrector.replace(patch_url_node.source_range, correct)
// 95:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 96:             end
// 97:           end
// 98:
// 99:           gh_patch_param_pattern = %r{https?://github\.com/.+/.+/(?:commit|pull)/[a-fA-F0-9]*.(?:patch|diff)}
// 100:           if regex_match_group(patch_url_node, gh_patch_param_pattern) && !patch_url.match?(/\?full_index=\w+$/)
// 101:             problem "GitHub patches should use the full_index parameter: #{patch_url}?full_index=1" do |corrector|
// 102:               correct = patch_url_node.source.sub(/"$/, '?full_index=1"')
// 103:               corrector.replace(patch_url_node.source_range, correct)
// 104:               corrector.replace(sha256_node.source_range, '""') if sha256_node
// 105:             end
// 106:           end
// 107:
// 108:           gh_patch_patterns = Regexp.union([%r{/raw\.github\.com/},
// 109:                                             %r{/raw\.githubusercontent\.com/},
// 110:                                             %r{gist\.github\.com/raw},
// 111:                                             %r{gist\.github\.com/.+/raw},
// 112:                                             %r{gist\.githubusercontent\.com/.+/raw}])
// 113:           if regex_match_group(patch_url_node, gh_patch_patterns) && !patch_url.match?(%r{/[a-fA-F0-9]{6,40}/})
// 114:             problem "GitHub/Gist patches should specify a revision: #{patch_url}"
// 115:           end
// 116:
// 117:           gh_patch_diff_pattern =
// 118:             %r{https?://patch-diff\.githubusercontent\.com/raw/(.+)/(.+)/pull/(.+)\.(?:diff|patch)}
// 119:           if regex_match_group(patch_url_node, gh_patch_diff_pattern)
// 120:             problem "Use a commit hash URL rather than patch-diff: #{patch_url}"
// 121:           end
// 122:
// 123:           if regex_match_group(patch_url_node, %r{macports/trunk})
// 124:             problem "MacPorts patches should specify a revision instead of trunk: #{patch_url}"
// 125:           end
// 126:
// 127:           if regex_match_group(patch_url_node, %r{^http://trac\.macports\.org})
// 128:             problem "Patches from MacPorts Trac should be https://, not http: #{patch_url}" do |corrector|
// 129:               corrector.replace(patch_url_node.source_range,
// 130:                                 patch_url_node.source.sub(%r{\A"http://}, '"https://'))
// 131:             end
// 132:           end
// 133:
// 134:           return unless regex_match_group(patch_url_node, %r{^http://bugs\.debian\.org})
// 135:
// 136:           problem "Patches from Debian should be https://, not http: #{patch_url}" do |corrector|
// 137:             corrector.replace(patch_url_node.source_range,
// 138:                               patch_url_node.source.sub(%r{\A"http://}, '"https://'))
// 139:           end
// 140:         end
// 141:
// 142:         sig { params(node: RuboCop::AST::Node).void }
// 143:         def resolves_problems(node)
// 144:           unless node.str_type?
// 145:             offending_node(node)
// 146:             problem "`resolves` should be passed identifier strings (CVE/GHSA/OSV id or issue URL)"
// 147:             return
// 148:           end
// 149:
// 150:           value = string_content(node)
// 151:           return if value.match?(/\ACVE-\d{4}-\d{4,}\z/)
// 152:           return if value.match?(/\AGHSA(-[23456789cfghjmpqrvwx]{4}){3}\z/)
// 153:           return if value.match?(/\AOSV-\d{4}-\d+\z/)
// 154:           return if value.match?(%r{\Ahttps?://})
// 155:
// 156:           offending_node(node)
// 157:           if (m = value.match(/\ACVE-?(\d{4})-(\d{4,})\z/i))
// 158:             corrected = "CVE-#{m[1]}-#{m[2]}"
// 159:             problem "`resolves` should use the canonical CVE format: #{corrected}" do |corrector|
// 160:               corrector.replace(node.source_range, corrected.inspect)
// 161:             end
// 162:           else
// 163:             problem "`resolves` should be a CVE/GHSA/OSV identifier or issue URL, got: #{value.inspect}"
// 164:           end
// 165:         end
// 166:
// 167:         sig { params(node: RuboCop::AST::Node).void }
// 168:         def type_problems(node)
// 169:           return if node.sym_type? && PATCH_TYPES.include?(T.cast(node, RuboCop::AST::SymbolNode).value)
// 170:
// 171:           offending_node(node)
// 172:           problem "Patch `type` should be one of: #{PATCH_TYPES.map(&:inspect).join(", ")}"
// 173:         end
// 174:
// 175:         sig { params(patch: RuboCop::AST::Node).void }
// 176:         def inline_patch_problems(patch)
// 177:           return if !patch_data?(patch) || patch_end?
// 178:
// 179:           offending_node(patch)
// 180:           problem "Patch is missing `__END__`"
// 181:         end
// 182:
// 183:         def_node_search :patch_data?, <<~AST
// 184:           (send nil? :patch (:sym :DATA))
// 185:         AST
// 186:
// 187:         sig { returns(T::Boolean) }
// 188:         def patch_end?
// 189:           /^__END__$/.match?(@full_source_content)
// 190:         end
// 191:
// 192:         sig { params(node: RuboCop::AST::Node).void }
// 193:         def offending_patch_end_node(node)
// 194:           @offensive_node = T.let(node, T.nilable(RuboCop::AST::Node))
// 195:           @source_buf = T.let(source_buffer(node), T.nilable(Parser::Source::Buffer))
// 196:           @line_no = T.let(node.loc.last_line + 1, T.nilable(Integer))
// 197:           @column = T.let(0, T.nilable(Integer))
// 198:           @length = T.let(7, T.nilable(Integer)) # "__END__".size
// 199:           @offense_source_range = T.let(
// 200:             source_range(@source_buf, @line_no, @column, @length),
// 201:             T.nilable(Parser::Source::Range),
// 202:           )
// 203:         end
// 204:       end
// 205:     end
// 206:   end
// 207: end
