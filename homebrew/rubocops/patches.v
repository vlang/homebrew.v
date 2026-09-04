module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/patches.rb`.
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

fn formula_patch_regions(source string, header fn (string) bool) []FormulaPatchRegion {
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

fn formula_patch_analysis_value(analysis FormulaPatchesAnalysis) ruby.Value {
	return ruby.map_value({
		'offenses':  ruby.array_value(analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
			'begin_pos': it.begin_pos.str()
			'end_pos':   it.end_pos.str()
			'message':   it.message
		})))
		'corrected': ruby.string_value(analysis.corrected)
	})
}
