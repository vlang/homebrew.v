module cask

import ruby
import homebrew.rubocops.@shared as install_steps_shared

// Translated from Homebrew/brew `rubocops/cask/install_steps.rb`.
// The original source is retained below until every stub has a typed V body.
pub const cask_install_steps_legacy_message = 'Casks in official Homebrew taps must use `%s` instead of `%s`.'
pub const cask_install_steps_simple_message = 'Use `%s` for simple file preparation.'
pub const cask_install_steps_brew_ruby_message = 'Install steps must not use `brew ruby` because it enables developer mode.'

const cask_keychain_hashes_source = 'hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }'
const cask_keychain_delete_source = 'hashes.each do |h| system_command "/usr/bin/security", args: ["delete-certificate", "-Z", h], sudo: true end'
const cask_certificate_exists_guard_source = 'next unless cert.exist?'
const cask_certificate_fingerprint_source = 'stdout, * = system_command "/usr/bin/openssl", args: ["x509", "-fingerprint", "-sha256", "-noout", "-in", cert]'
const cask_certificate_hash_source = 'hash = stdout.lines.first.split("=").second.delete(":").strip'
const cask_certificate_hash_delete_source = 'if hashes.include?(hash) system_command "/usr/bin/security", args: ["delete-certificate", "-Z", hash], sudo: true end'

pub struct CaskInstallStepsOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct CaskInstallStepsAnalysis {
pub:
	source    string
	file_path string
	offenses  []CaskInstallStepsOffense
	corrected string
}

struct CaskInstallStepsEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

struct CaskInstallStepsNamedSpan {
	name string
	span install_steps_shared.InstallStepSpan
}

struct CaskInstallStepsPair {
	flight string
	steps  string
}

pub struct CaskInstallStepsNameNode {
pub:
	value   string
	is_str  bool
	is_lvar bool
}

struct CaskInstallStepsPermissionPath {
	path     string
	base     string
	absolute bool
}

fn cask_install_steps_pairs() []CaskInstallStepsPair {
	return [
		CaskInstallStepsPair{'preflight', 'preflight_steps'},
		CaskInstallStepsPair{'postflight', 'postflight_steps'},
		CaskInstallStepsPair{'uninstall_preflight', 'uninstall_preflight_steps'},
		CaskInstallStepsPair{'uninstall_postflight', 'uninstall_postflight_steps'},
	]
}

fn cask_install_steps_direct_stanza(source string, name string) ?install_steps_shared.InstallStepSpan {
	cask_block := install_steps_shared.install_steps_find_block(source, 'cask') or { return none }
	for span in install_steps_shared.install_steps_find_blocks(source, name) {
		if span.begin_pos > cask_block.begin_pos && span.end_pos < cask_block.end_pos && span.indent == cask_block.indent + 2 {
			return span
		}
	}
	return none
}

fn cask_install_steps_apply_edits(source string, edits []CaskInstallStepsEdit) string {
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	mut result := source
	for edit in ordered {
		if edit.begin_pos < 0 || edit.end_pos < edit.begin_pos || edit.end_pos > result.len {
			continue
		}
		result = result[..edit.begin_pos] + edit.replacement + result[edit.end_pos..]
	}
	return result
}

fn cask_install_steps_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn cask_install_steps_string_literal(source string) ?string {
	value := source.trim_space()
	if value.len < 2 || value[0] !in [`"`, `'`] || value[value.len - 1] != value[0] {
		return none
	}
	mut result := ''
	mut index := 1
	for index < value.len - 1 {
		if value[index] == `\\` && index + 1 < value.len - 1 {
			next := value[index + 1]
			result += match next {
				`n` { '\n' }
				`r` { '\r' }
				`t` { '\t' }
				else { next.ascii_str() }
			}
			index += 2
			continue
		}
		result += value[index].ascii_str()
		index++
	}
	return result
}

fn cask_install_steps_quote(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')}"'
}

fn cask_install_steps_split_arguments(source string) []string {
	mut result := []string{}
	mut start := 0
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for index, character in source.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character == `"` || character == `'` {
			quote = character
		} else if character in [`[`, `{`, `(`] {
			depth++
		} else if character in [`]`, `}`, `)`] {
			depth--
		} else if character == `,` && depth == 0 {
			result << source[start..index].trim_space()
			start = index + 1
		}
	}
	if start < source.len || source.trim_space() != '' {
		result << source[start..].trim_space()
	}
	return result.filter(it != '')
}

fn cask_install_steps_statement_rest(source string, method string) string {
	trimmed := source.trim_space()
	if !trimmed.starts_with(method) {
		return ''
	}
	return trimmed[method.len..].trim_space().trim_left('(').trim_right(')')
}

fn cask_install_steps_name_node(source string) ?CaskInstallStepsNameNode {
	trimmed := source.trim_space()
	if value := cask_install_steps_string_literal(trimmed) {
		return CaskInstallStepsNameNode{ value: value, is_str: true }
	}
	if trimmed == 'cert_name' {
		return CaskInstallStepsNameNode{ value: trimmed, is_lvar: true }
	}
	return none
}

pub fn cask_keychain_find_certificate_name(source string) ?CaskInstallStepsNameNode {
	normalised := install_steps_shared.install_steps_normalised_source(source)
	prefix := 'stdout, * = system_command "/usr/bin/security", args: ["find-certificate", "-a", "-c", '
	suffix := ', "-Z"], sudo: true'
	if !normalised.starts_with(prefix) || !normalised.ends_with(suffix) {
		return none
	}
	name_source := normalised[prefix.len..normalised.len - suffix.len]
	return cask_install_steps_name_node(name_source)
}

pub fn cask_keychain_delete_sequence_name(nodes []string) ?CaskInstallStepsNameNode {
	if nodes.len != 3 {
		return none
	}
	name := cask_keychain_find_certificate_name(nodes[0]) or { return none }
	if install_steps_shared.install_steps_normalised_source(nodes[1]) != cask_keychain_hashes_source || install_steps_shared.install_steps_normalised_source(nodes[2]) != cask_keychain_delete_source {
		return none
	}
	return name
}

pub fn cask_certificate_path(source string) ?string {
	normalised := install_steps_shared.install_steps_normalised_source(source)
	prefix := 'cert = Pathname('
	suffix := ').expand_path'
	if !normalised.starts_with(prefix) || !normalised.ends_with(suffix) {
		return none
	}
	argument := normalised[prefix.len..normalised.len - suffix.len]
	return cask_install_steps_string_literal(argument)
}

pub fn cask_fingerprint_keychain_step_lines(nodes []string) ?[]string {
	if nodes.len != 7 {
		return none
	}
	path := cask_certificate_path(nodes[0]) or { return none }
	if install_steps_shared.install_steps_normalised_source(nodes[1]) != cask_certificate_exists_guard_source {
		return none
	}
	fingerprint := install_steps_shared.install_steps_normalised_source(nodes[2]).replace('[ ', '[').replace(' ]', ']')
	if fingerprint != cask_certificate_fingerprint_source || install_steps_shared.install_steps_normalised_source(nodes[3]) != cask_certificate_hash_source {
		return none
	}
	name := cask_keychain_find_certificate_name(nodes[4]) or { return none }
	if !name.is_str || install_steps_shared.install_steps_normalised_source(nodes[5]) != cask_keychain_hashes_source || install_steps_shared.install_steps_normalised_source(nodes[6]) != cask_certificate_hash_delete_source {
		return none
	}
	return [
		'delete_keychain_certificates ${cask_install_steps_quote(name.value)},\n${' '.repeat(29)}fingerprint_of: ${cask_install_steps_quote(path)}',
	]
}

fn cask_install_steps_array_strings(source string) ?[]string {
	trimmed := source.trim_space()
	if !trimmed.starts_with('[') || !trimmed.ends_with(']') {
		return none
	}
	parts := cask_install_steps_split_arguments(trimmed[1..trimmed.len - 1])
	if parts.len == 0 {
		return none
	}
	mut values := []string{}
	for part in parts {
		values << cask_install_steps_string_literal(part) or { return none }
	}
	return values
}

fn cask_install_steps_nested_statements(statement string) []string {
	lines := statement.split('\n')
	if lines.len < 3 {
		return []
	}
	closing_indent := lines.last().len - lines.last().trim_left(' \t').len
	mut wrapped_lines := ['sequence do']
	for line in lines[1..] {
		wrapped_lines << if line.len >= closing_indent {
			line[closing_indent..]
		} else {
			line
		}
	}
	wrapped := wrapped_lines.join('\n')
	return install_steps_shared.install_steps_direct_statements(wrapped, 'sequence').map(it.source)
}

pub fn cask_keychain_certificate_step_lines(source string, block_name string) ?[]string {
	direct := install_steps_shared.install_steps_direct_statements(source, block_name)
	nodes := direct.map(it.source)
	if nodes.len == 7 {
		if lines := cask_fingerprint_keychain_step_lines(nodes) {
			return lines
		}
	}
	if name := cask_keychain_delete_sequence_name(nodes) {
		if name.is_str {
			return [
				'delete_keychain_certificates ${cask_install_steps_quote(name.value)}',
			]
		}
	}
	if nodes.len != 1 {
		return none
	}
	first_line := nodes[0].all_before('\n').trim_space()
	marker := '].each do |cert_name|'
	if !first_line.starts_with('[') || !first_line.ends_with(marker) {
		return none
	}
	array_end := first_line.index('].each do |cert_name|') or { return none }
	names := cask_install_steps_array_strings(first_line[..array_end + 1]) or { return none }
	sequence := cask_keychain_delete_sequence_name(cask_install_steps_nested_statements(nodes[0])) or {
		return none
	}
	if !sequence.is_lvar || sequence.value != 'cert_name' {
		return none
	}
	return names.map('delete_keychain_certificates ${cask_install_steps_quote(it)}')
}

fn cask_install_steps_allowed_template(value string) bool {
	return value in ['formula_name', 'name', 'token', 'version', 'version.major',
		'version.major_minor']
}

fn cask_install_steps_interpolations_allowed(source string) bool {
	mut rest := source
	for {
		start := rest.index('#{') or { return true }
		end := rest.index_after('}', start + 2) or { return false }
		if !cask_install_steps_allowed_template(rest[start + 2..end].trim_space()) {
			return false
		}
		rest = rest[end + 1..]
	}
	return true
}

fn cask_install_steps_permission_path(source string) ?CaskInstallStepsPermissionPath {
	trimmed := source.trim_space().trim('()')
	if trimmed == 'staged_path.to_s' {
		return CaskInstallStepsPermissionPath{ path: '.', base: 'staged_path' }
	}
	if trimmed.len >= 2 && trimmed[0] in [`"`, `'`] && trimmed[trimmed.len - 1] == trimmed[0] {
		raw := trimmed[1..trimmed.len - 1]
		if raw.starts_with('#{') {
			close := raw.index('}') or { return none }
			base_source := raw[2..close]
			base := match base_source {
				'HOMEBREW_PREFIX' { 'homebrew_prefix' }
				'appdir', 'staged_path' { base_source }
				else {
					return none
				}
			}
			rest := raw[close + 1..]
			if !rest.starts_with('/') {
				return none
			}
			path := rest[1..]
			if path == '' || !cask_install_steps_interpolations_allowed(path) {
				return none
			}
			return CaskInstallStepsPermissionPath{ path: path, base: base }
		}
		value := cask_install_steps_string_literal(trimmed) or { return none }
		if !cask_install_steps_interpolations_allowed(value) {
			return none
		}
		absolute := value.starts_with('/') || value.starts_with('~/')
		if !absolute && value.contains('#{') {
			return none
		}
		return CaskInstallStepsPermissionPath{ path: value, absolute: absolute }
	}
	path := install_steps_shared.install_steps_parse_path(trimmed) or { return none }
	return CaskInstallStepsPermissionPath{
		path: path.path
		base: path.base
		absolute: install_steps_shared.install_steps_absolute_path(path)
	}
}

fn cask_install_steps_permission_paths(source string, default_base string) ?(string, string) {
	trimmed := source.trim_space()
	parts := if trimmed.starts_with('[') && trimmed.ends_with(']') {
		cask_install_steps_split_arguments(trimmed[1..trimmed.len - 1])
	} else {
		[trimmed]
	}
	if parts.len == 0 {
		return none
	}
	mut paths := []CaskInstallStepsPermissionPath{}
	for part in parts {
		paths << cask_install_steps_permission_path(part) or { return none }
	}
	has_absolute := paths.any(it.absolute)
	has_relative := paths.any(!it.absolute)
	if has_absolute && has_relative {
		return none
	}
	mut base := ''
	if has_relative {
		mut bases := []string{}
		for path in paths {
			actual := if path.base == '' { default_base } else { path.base }
			if !bases.contains(actual) {
				bases << actual
			}
		}
		if bases.len != 1 {
			return none
		}
		base = bases[0]
	}
	quoted := paths.map(cask_install_steps_quote(it.path))
	path_source := if parts.len == 1 { quoted[0] } else { '[${quoted.join(', ')}]' }
	return path_source, base
}

fn cask_install_steps_option_pair(source string) ?(string, string) {
	trimmed := source.trim_space()
	colon := trimmed.index(':') or { return none }
	key := trimmed[..colon].trim_space()
	value := trimmed[colon + 1..].trim_space()
	if key !in ['user', 'group'] || cask_install_steps_string_literal(value) == none {
		return none
	}
	return key, '${key}: ${value}'
}

fn cask_install_steps_permission_line(source string) ?string {
	trimmed := install_steps_shared.install_steps_normalised_source(source)
	if trimmed.starts_with('set_permissions ') {
		arguments := cask_install_steps_split_arguments(cask_install_steps_statement_rest(trimmed, 'set_permissions'))
		if arguments.len != 2 || cask_install_steps_string_literal(arguments[1]) == none {
			return none
		}
		paths, base := cask_install_steps_permission_paths(arguments[0], 'staged_path') or {
			return none
		}
		keyword := if base != '' && base != 'staged_path' { ', base: :${base}' } else { '' }
		return 'set_permissions ${paths}, ${arguments[1]}${keyword}'
	}
	if trimmed.starts_with('set_ownership ') {
		arguments := cask_install_steps_split_arguments(cask_install_steps_statement_rest(trimmed, 'set_ownership'))
		if arguments.len < 1 || arguments.len > 3 {
			return none
		}
		paths, base := cask_install_steps_permission_paths(arguments[0], 'staged_path') or {
			return none
		}
		mut seen := []string{}
		mut options := []string{}
		for argument in arguments[1..] {
			key, pair := cask_install_steps_option_pair(argument) or { return none }
			if seen.contains(key) {
				return none
			}
			seen << key
			options << pair
		}
		if base != '' && base != 'staged_path' {
			options << 'base: :${base}'
		}
		return 'set_ownership ${paths}${install_steps_shared.install_steps_kwargs(options)}'
	}
	return none
}

fn cask_install_steps_file_write_line(source string) ?string {
	normalised := install_steps_shared.install_steps_normalised_source(source)
	if !normalised.starts_with('File.write ') {
		return none
	}
	arguments := cask_install_steps_split_arguments(normalised['File.write '.len..])
	if arguments.len != 2 || cask_install_steps_string_literal(arguments[1]) == none {
		return none
	}
	path := install_steps_shared.install_steps_parse_path(arguments[0]) or { return none }
	if install_steps_shared.install_steps_relative_path(path) {
		return none
	}
	return 'write_file ${install_steps_shared.install_steps_path_source(path)}, ${arguments[1]}${install_steps_shared.install_steps_path_keywords(path, 'staged_path', 'base')}'
}

fn cask_install_steps_simple_lines(source string, block_name string) ?[]string {
	statements := install_steps_shared.install_steps_direct_statements(source, block_name)
	if statements.len == 0 {
		return none
	}
	mut lines := []string{}
	for statement in statements {
		if permission := cask_install_steps_permission_line(statement.source) {
			lines << permission
			continue
		}
		if write := cask_install_steps_file_write_line(statement.source) {
			lines << write
			continue
		}
		line := install_steps_shared.install_steps_simple_line(statement.source, 'staged_path', 'staged_path', 'staged_path', false) or { return none }
		lines << line
	}
	return lines
}

fn cask_install_steps_keyword_position(source string, keyword string) ?int {
	needle := '${keyword}:'
	mut offset := 0
	for offset < source.len {
		position := source.index_after(needle, offset) or { return none }
		if position == 0 || !(source[position - 1].is_alnum() || source[position - 1] == `_`) {
			return position
		}
		offset = position + needle.len
	}
	return none
}

fn cask_install_steps_compatibility(source string, block_name string) ([]CaskInstallStepsOffense, []CaskInstallStepsEdit) {
	allowed := install_steps_shared.install_steps_cask_allowed_methods()
	replacements := install_steps_shared.install_steps_compatibility_methods()
	mut offenses := []CaskInstallStepsOffense{}
	mut edits := []CaskInstallStepsEdit{}
	for statement in install_steps_shared.install_steps_all_statements(source, block_name) {
		method := statement.name
		if method !in allowed {
			continue
		}
		if method in replacements {
			replacement := replacements[method]
			offenses << CaskInstallStepsOffense{
				begin_pos: statement.begin_pos
				end_pos: statement.begin_pos + method.len
				message: 'Use `${replacement}` instead of legacy install step `${method}`.'
				replacement: replacement
			}
			edits << CaskInstallStepsEdit{
				begin_pos: statement.begin_pos
				end_pos: statement.begin_pos + method.len
				replacement: replacement
			}
		}
		keyword_map := if method in ['move', 'mv'] {
			{
				'force': 'overwrite'
			}
		} else if method in ['symlink', 'ln_s'] {
			{
				'force':     'overwrite'
				'uninstall': 'remove_on_uninstall'
			}
		} else if method == 'ln_sf' {
			{
				'uninstall': 'remove_on_uninstall'
			}
		} else if method in ['delete_keychain_certificate', 'delete_keychain_certificates'] {
			{
				'matching_certificate': 'fingerprint_of'
			}
		} else {
			map[string]string{}
		}
		for keyword, replacement in keyword_map {
			position := cask_install_steps_keyword_position(statement.source, keyword) or { continue }
			begin_pos := statement.begin_pos + position
			offenses << CaskInstallStepsOffense{
				begin_pos: begin_pos
				end_pos: begin_pos + keyword.len
				message: 'Use `${replacement}:` instead of legacy install step keyword `${keyword}:`.'
				replacement: replacement
			}
			edits << CaskInstallStepsEdit{
				begin_pos: begin_pos
				end_pos: begin_pos + keyword.len
				replacement: replacement
			}
		}
		if method == 'ln_sf' {
			edits << CaskInstallStepsEdit{
				begin_pos: statement.end_pos
				end_pos: statement.end_pos
				replacement: ', overwrite: true'
			}
		} else if method == 'write' {
			keyword := if statement.source.contains('overwrite:') {
				', append_newline: true'
			} else {
				', overwrite: false, append_newline: true'
			}
			if statement.source.contains('<<~') {
				first_line_end := statement.source.index('\n') or { statement.source.len }
				edits << CaskInstallStepsEdit{
					begin_pos: statement.begin_pos + first_line_end
					end_pos: statement.begin_pos + first_line_end
					replacement: keyword
				}
			} else {
				edits << CaskInstallStepsEdit{
					begin_pos: statement.end_pos
					end_pos: statement.end_pos
					replacement: keyword
				}
			}
		}
	}
	return offenses, edits
}

fn cask_install_steps_invalid_interpolation(source string, block_name string) ?CaskInstallStepsOffense {
	for statement in install_steps_shared.install_steps_all_statements(source, block_name) {
		mut offset := 0
		for offset < statement.source.len {
			start := statement.source.index_after('#{', offset) or { break }
			end := statement.source.index_after('}', start + 2) or {
				return CaskInstallStepsOffense{
					begin_pos: statement.begin_pos + start
					end_pos: statement.begin_pos + start + 2
				}
			}
			if !cask_install_steps_allowed_template(statement.source[start + 2..end].trim_space()) {
				return CaskInstallStepsOffense{
					begin_pos: statement.begin_pos + start
					end_pos: statement.begin_pos + end + 1
				}
			}
			offset = end + 1
		}
	}
	return none
}

fn cask_install_steps_offense_value(offense CaskInstallStepsOffense) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::Offense'
		repr: offense.message
		map_data: {
			'message':     ruby.string_value(offense.message)
			'replacement': ruby.string_value(offense.replacement)
		}
		attributes: {
			'begin_pos': offense.begin_pos.str()
			'end_pos':   offense.end_pos.str()
		}
	}
}

fn cask_install_steps_analysis_value(analysis CaskInstallStepsAnalysis) ruby.Value {
	values := analysis.offenses.map(cask_install_steps_offense_value(it))
	return ruby.Value{
		type_name: 'RuboCop::Cop::Cask::InstallSteps::Analysis'
		repr: analysis.source
		array_data: values
		map_data: {
			'offenses':  ruby.array_value(values)
			'corrected': ruby.string_value(analysis.corrected)
		}
	}
}

pub fn analyze_cask_install_steps(source string, file_path string) CaskInstallStepsAnalysis {
	mut offenses := []CaskInstallStepsOffense{}
	mut edits := []CaskInstallStepsEdit{}
	mut steps_stanzas := []CaskInstallStepsNamedSpan{}
	for pair in cask_install_steps_pairs() {
		flight := cask_install_steps_direct_stanza(source, pair.flight) or { continue }
		steps := cask_install_steps_direct_stanza(source, pair.steps)
		mut converted := false
		if steps == none {
			step_lines := cask_keychain_certificate_step_lines(source, pair.flight) or {
				cask_install_steps_simple_lines(source, pair.flight) or { [] }
			}
			if step_lines.len > 0 {
				converted = true
				message := cask_install_steps_simple_message.replace('%s', pair.steps)
				replacement := install_steps_shared.install_steps_block_source(pair.steps, step_lines, flight.indent)
				offenses << CaskInstallStepsOffense{
					begin_pos: flight.begin_pos
					end_pos: flight.end_pos
					message: message
					replacement: replacement
				}
				edits << CaskInstallStepsEdit{
					begin_pos: flight.begin_pos
					end_pos: flight.end_pos
					replacement: replacement
				}
			}
		}
		if install_steps_shared.install_steps_official_homebrew_tap(file_path) && !converted {
			message := cask_install_steps_legacy_message.replace_once('%s', pair.steps).replace_once('%s', pair.flight)
			offenses << CaskInstallStepsOffense{
				begin_pos: flight.begin_pos
				end_pos: flight.end_pos
				message: message
			}
		}
	}
	for pair in cask_install_steps_pairs() {
		if span := cask_install_steps_direct_stanza(source, pair.steps) {
			steps_stanzas << CaskInstallStepsNamedSpan{ name: pair.steps, span: span }
		}
	}
	steps_stanzas.sort(a.span.begin_pos < b.span.begin_pos)
	allowed := install_steps_shared.install_steps_cask_allowed_methods()
	block_message := install_steps_shared.install_steps_step_block_message(allowed)
	for stanza in steps_stanzas {
		compatibility_offenses, compatibility_edits := cask_install_steps_compatibility(source, stanza.name)
		offenses << compatibility_offenses
		edits << compatibility_edits
		if brew := install_steps_shared.install_steps_brew_ruby_offense(source, stanza.name) {
			offenses << CaskInstallStepsOffense{
				begin_pos: brew.begin_pos
				end_pos: brew.end_pos
				message: cask_install_steps_brew_ruby_message
			}
			continue
		}
		if interpolation := cask_install_steps_invalid_interpolation(source, stanza.name) {
			offenses << CaskInstallStepsOffense{
				begin_pos: interpolation.begin_pos
				end_pos: interpolation.end_pos
				message: block_message
			}
			continue
		}
		if invalid := install_steps_shared.install_steps_block_offense_for(source, stanza.name, allowed) {
			offenses << CaskInstallStepsOffense{
				begin_pos: invalid.begin_pos
				end_pos: invalid.end_pos
				message: block_message
			}
		}
	}
	return CaskInstallStepsAnalysis{
		source: source
		file_path: file_path
		offenses: offenses
		corrected: cask_install_steps_apply_edits(source, edits)
	}
}

pub fn audit_cask_install_steps(source string, file_path string) []CaskInstallStepsOffense {
	return analyze_cask_install_steps(source, file_path).offenses
}

pub fn correct_cask_install_steps(source string, file_path string) string {
	return analyze_cask_install_steps(source, file_path).corrected
}

// Ruby method `on_cask(cask_block)` at line 58.
pub fn ruby_install_steps_l58_d1_on_cask(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { 'cask "foo" do\nend' }
	file_path := if args.len > 1 { args[1].as_string() } else { '' }
	return cask_install_steps_analysis_value(analyze_cask_install_steps(source, file_path))
}

// Ruby method `autocorrect_flight_block?(flight_stanza, steps_block)` at line 96.
pub fn ruby_install_steps_l96_d2_autocorrect_flight_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	file_path := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.bool_value(correct_cask_install_steps(source, file_path) != source)
}

// Ruby method `keychain_certificate_step_lines(body_node)` at line 120.
pub fn ruby_install_steps_l120_d3_keychain_certificate_step_lines(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cask_install_steps_nil()
	}
	block_name := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'preflight' }
	lines := cask_keychain_certificate_step_lines(args[0].as_string(), block_name) or {
		return cask_install_steps_nil()
	}
	return ruby.string_array_value(lines)
}

// Ruby method `keychain_delete_sequence_name(nodes)` at line 151.
pub fn ruby_install_steps_l151_d4_keychain_delete_sequence_name(args ...ruby.Value) ruby.Value {
	nodes := if args.len > 0 && args[0].type_name == 'Array' {
		(args[0].as_array() or { [] }).map(it.as_string())
	} else {
		args.map(it.as_string())
	}
	name := cask_keychain_delete_sequence_name(nodes) or { return cask_install_steps_nil() }
	return if name.is_str {
		ruby.string_value(name.value)
	} else {
		ruby.structured_value('RuboCop::AST::LvarNode', name.value, {
			'name': name.value
		})
	}
}

// Ruby method `fingerprint_keychain_step_lines(nodes)` at line 163.
pub fn ruby_install_steps_l163_d5_fingerprint_keychain_step_lines(args ...ruby.Value) ruby.Value {
	nodes := if args.len > 0 && args[0].type_name == 'Array' {
		(args[0].as_array() or { [] }).map(it.as_string())
	} else {
		args.map(it.as_string())
	}
	lines := cask_fingerprint_keychain_step_lines(nodes) or { return cask_install_steps_nil() }
	return ruby.string_array_value(lines)
}

// Ruby method `keychain_find_certificate_name(node)` at line 189.
pub fn ruby_install_steps_l189_d6_keychain_find_certificate_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cask_install_steps_nil()
	}
	name := cask_keychain_find_certificate_name(args[0].as_string()) or {
		return cask_install_steps_nil()
	}
	return if name.is_str {
		ruby.string_value(name.value)
	} else {
		ruby.structured_value('RuboCop::AST::LvarNode', name.value, {
			'name': name.value
		})
	}
}

// Ruby method `certificate_path(node)` at line 229.
pub fn ruby_install_steps_l229_d7_certificate_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cask_install_steps_nil()
	}
	path := cask_certificate_path(args[0].as_string()) or { return cask_install_steps_nil() }
	return ruby.string_value(path)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/install_steps_helper"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks declarative install step usage.
// 10:       class InstallSteps < Base
// 11:         extend AutoCorrector
// 12:         include CaskHelp
// 13:         include ::RuboCop::Cop::InstallStepsHelper
// 14:
// 15:         INSTALL_STEP_PAIRS = T.let(
// 16:           {
// 17:             preflight:            :preflight_steps,
// 18:             postflight:           :postflight_steps,
// 19:             uninstall_preflight:  :uninstall_preflight_steps,
// 20:             uninstall_postflight: :uninstall_postflight_steps,
// 21:           }.freeze,
// 22:           T::Hash[Symbol, Symbol],
// 23:         )
// 24:         LEGACY_FLIGHT_MSG = "Casks in official Homebrew taps must use `%<steps>s` instead of `%<flight>s`."
// 25:         KEYCHAIN_HASHES_SOURCE =
// 26:           'hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }'
// 27:         KEYCHAIN_DELETE_SOURCE = T.let(
// 28:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 29:             hashes.each do |h|
// 30:               system_command "/usr/bin/security",
// 31:                              args: ["delete-certificate", "-Z", h],
// 32:                              sudo: true
// 33:             end
// 34:           RUBY
// 35:           String,
// 36:         )
// 37:         CERTIFICATE_EXISTS_GUARD_SOURCE = "next unless cert.exist?"
// 38:         CERTIFICATE_FINGERPRINT_SOURCE = T.let(
// 39:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 40:             stdout, * = system_command "/usr/bin/openssl",
// 41:                                        args: ["x509", "-fingerprint", "-sha256", "-noout", "-in", cert]
// 42:           RUBY
// 43:           String,
// 44:         )
// 45:         CERTIFICATE_HASH_SOURCE = 'hash = stdout.lines.first.split("=").second.delete(":").strip'
// 46:         CERTIFICATE_HASH_DELETE_SOURCE = T.let(
// 47:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 48:             if hashes.include?(hash)
// 49:               system_command "/usr/bin/security",
// 50:                              args: ["delete-certificate", "-Z", hash],
// 51:                              sudo: true
// 52:             end
// 53:           RUBY
// 54:           String,
// 55:         )
// 56:
// 57:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 58:         def on_cask(cask_block)
// 59:           stanzas = cask_block.stanzas
// 60:           INSTALL_STEP_PAIRS.each do |flight_block, steps_block|
// 61:             next unless (flight_stanza = stanzas.find { |stanza| stanza.stanza_name == flight_block })
// 62:
// 63:             steps_stanza = stanzas.find { |stanza| stanza.stanza_name == steps_block }
// 64:             converted_flight = autocorrect_flight_block?(flight_stanza, steps_block) if steps_stanza.nil?
// 65:
// 66:             # odeprecated: remove the official-tap scope in the next major or minor release.
// 67:             next unless official_homebrew_tap?(processed_source.file_path)
// 68:             next if converted_flight
// 69:
// 70:             add_offense(flight_stanza.method_node,
// 71:                         message: format(LEGACY_FLIGHT_MSG, steps: steps_block, flight: flight_block))
// 72:           end
// 73:
// 74:           stanzas.each do |stanza|
// 75:             next unless INSTALL_STEP_PAIRS.value?(stanza.stanza_name)
// 76:             next unless stanza.method_node.block_type?
// 77:
// 78:             block_node = T.cast(stanza.method_node, RuboCop::AST::BlockNode)
// 79:             add_compatibility_step_offenses(block_node, allowed_methods: CASK_ALLOWED_STEP_METHODS)
// 80:             if (offense_node = brew_ruby_step_node(block_node))
// 81:               add_offense(offense_node, message: BREW_RUBY_STEP_MSG)
// 82:               next
// 83:             end
// 84:             next unless (offense_node = install_step_block_offense_node(
// 85:               block_node,
// 86:               allowed_methods: CASK_ALLOWED_STEP_METHODS,
// 87:             ))
// 88:
// 89:             add_offense(offense_node, message: step_block_msg(CASK_ALLOWED_STEP_METHODS))
// 90:           end
// 91:         end
// 92:
// 93:         private
// 94:
// 95:         sig { params(flight_stanza: RuboCop::Cask::AST::Stanza, steps_block: Symbol).returns(T::Boolean) }
// 96:         def autocorrect_flight_block?(flight_stanza, steps_block)
// 97:           return false unless flight_stanza.method_node.block_type?
// 98:
// 99:           block_node = T.cast(flight_stanza.method_node, RuboCop::AST::BlockNode)
// 100:           step_lines = keychain_certificate_step_lines(block_node.body) ||
// 101:                        simple_install_step_lines(block_node.body,
// 102:                                                  default_base:        :staged_path,
// 103:                                                  default_source_base: :staged_path,
// 104:                                                  default_target_base: :staged_path,
// 105:                                                  rebuild_actions:     false,
// 106:                                                  permission_actions:  true)
// 107:           return false if step_lines.blank?
// 108:
// 109:           add_offense(block_node.source_range,
// 110:                       message: format(SIMPLE_STEP_CONVERSION_MSG, steps_block:)) do |corrector|
// 111:             corrector.replace(
// 112:               block_node.source_range,
// 113:               install_steps_block_source(steps_block, step_lines, block_node.source_range.column),
// 114:             )
// 115:           end
// 116:           true
// 117:         end
// 118:
// 119:         sig { params(body_node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(T::Array[String])) }
// 120:         def keychain_certificate_step_lines(body_node)
// 121:           direct_nodes = direct_install_step_nodes(body_node)
// 122:           return fingerprint_keychain_step_lines(direct_nodes) if direct_nodes.length == 7
// 123:
// 124:           if (name_node = keychain_delete_sequence_name(direct_nodes))&.str_type?
// 125:             return ["delete_keychain_certificates #{T.cast(name_node, RuboCop::AST::StrNode).str_content.inspect}"]
// 126:           end
// 127:
// 128:           return if body_node.nil? || !body_node.block_type?
// 129:
// 130:           block_node = T.cast(body_node, RuboCop::AST::BlockNode)
// 131:           send_node = block_node.send_node
// 132:           names_node = send_node.receiver
// 133:           return if send_node.method_name != :each || send_node.arguments.present? || !names_node&.array_type?
// 134:
// 135:           block_arguments = block_node.arguments.children
// 136:           return if block_arguments.length != 1 || block_arguments.first&.children != [:cert_name]
// 137:
// 138:           name_nodes = names_node.child_nodes
// 139:           return unless name_nodes.all?(&:str_type?)
// 140:
// 141:           sequence_name_node = keychain_delete_sequence_name(direct_install_step_nodes(block_node.body))
// 142:           return unless sequence_name_node&.lvar_type?
// 143:           return if sequence_name_node.children != [:cert_name]
// 144:
// 145:           name_nodes.map do |name|
// 146:             "delete_keychain_certificates #{T.cast(name, RuboCop::AST::StrNode).str_content.inspect}"
// 147:           end
// 148:         end
// 149:
// 150:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(T.nilable(RuboCop::AST::Node)) }
// 151:         def keychain_delete_sequence_name(nodes)
// 152:           return if nodes.length != 3
// 153:
// 154:           name_node = keychain_find_certificate_name(nodes.fetch(0))
// 155:           return if name_node.nil?
// 156:           return if normalised_install_step_source(nodes.fetch(1)) != KEYCHAIN_HASHES_SOURCE
// 157:           return if normalised_install_step_source(nodes.fetch(2)) != KEYCHAIN_DELETE_SOURCE
// 158:
// 159:           name_node
// 160:         end
// 161:
// 162:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(T.nilable(T::Array[String])) }
// 163:         def fingerprint_keychain_step_lines(nodes)
// 164:           path_node = certificate_path(nodes.fetch(0))
// 165:           return if path_node.nil?
// 166:           return if normalised_install_step_source(nodes.fetch(1)) != CERTIFICATE_EXISTS_GUARD_SOURCE
// 167:
// 168:           fingerprint_source = normalised_install_step_source(nodes.fetch(2))
// 169:                                .gsub(/\[\s+/, "[")
// 170:                                .gsub(/\s+\]/, "]")
// 171:           return if fingerprint_source != CERTIFICATE_FINGERPRINT_SOURCE
// 172:           return if normalised_install_step_source(nodes.fetch(3)) != CERTIFICATE_HASH_SOURCE
// 173:
// 174:           name_node = keychain_find_certificate_name(nodes.fetch(4))
// 175:           return if name_node.nil? || !name_node.str_type?
// 176:           return if normalised_install_step_source(nodes.fetch(5)) != KEYCHAIN_HASHES_SOURCE
// 177:           return if normalised_install_step_source(nodes.fetch(6)) != CERTIFICATE_HASH_DELETE_SOURCE
// 178:
// 179:           name = T.cast(name_node, RuboCop::AST::StrNode).str_content.inspect
// 180:           path = T.cast(path_node, RuboCop::AST::StrNode).str_content.inspect
// 181:           source = <<~RUBY.chomp
// 182:             delete_keychain_certificates #{name},
// 183:                                          fingerprint_of: #{path}
// 184:           RUBY
// 185:           [source]
// 186:         end
// 187:
// 188:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(RuboCop::AST::Node)) }
// 189:         def keychain_find_certificate_name(node)
// 190:           return unless node.masgn_type?
// 191:           return if node.child_nodes.length != 2
// 192:
// 193:           assignment = node.child_nodes.fetch(0)
// 194:           command_node = node.child_nodes.fetch(1)
// 195:           return if normalised_install_step_source(assignment) != "stdout, *"
// 196:           return unless command_node.send_type?
// 197:
// 198:           command = T.cast(command_node, RuboCop::AST::SendNode)
// 199:           return if command.receiver || command.method_name != :system_command || command.arguments.length != 2
// 200:           return unless command.arguments.fetch(0).str_type?
// 201:           return if T.cast(command.arguments.fetch(0), RuboCop::AST::StrNode).str_content != "/usr/bin/security"
// 202:
// 203:           options = command.arguments.fetch(1)
// 204:           return unless options.hash_type?
// 205:
// 206:           pairs = T.cast(options, RuboCop::AST::HashNode).pairs
// 207:           return if pairs.length != 2 || pairs.any? { |pair| !pair.key.sym_type? }
// 208:           return if pairs.map { |pair| pair.key.value } != [:args, :sudo]
// 209:           return unless pairs.fetch(1).value.true_type?
// 210:
// 211:           arguments = pairs.fetch(0).value
// 212:           return unless arguments.array_type?
// 213:
// 214:           values = arguments.child_nodes
// 215:           return if values.length != 5
// 216:
// 217:           fixed_value_nodes = [0, 1, 2, 4].map { |index| values.fetch(index) }
// 218:           return unless fixed_value_nodes.all?(&:str_type?)
// 219:
// 220:           fixed_values = fixed_value_nodes.map do |value|
// 221:             T.cast(value, RuboCop::AST::StrNode).str_content
// 222:           end
// 223:           return if fixed_values != ["find-certificate", "-a", "-c", "-Z"]
// 224:
// 225:           values.fetch(3)
// 226:         end
// 227:
// 228:         sig { params(node: RuboCop::AST::Node).returns(T.nilable(RuboCop::AST::Node)) }
// 229:         def certificate_path(node)
// 230:           return unless node.lvasgn_type?
// 231:           return if node.children.first != :cert
// 232:
// 233:           expand_node = node.child_nodes.first
// 234:           return unless expand_node&.send_type?
// 235:
// 236:           expand = T.cast(expand_node, RuboCop::AST::SendNode)
// 237:           return if expand.method_name != :expand_path || expand.arguments.present?
// 238:           return unless expand.receiver&.send_type?
// 239:
// 240:           pathname = T.cast(expand.receiver, RuboCop::AST::SendNode)
// 241:           return if pathname.receiver || pathname.method_name != :Pathname || pathname.arguments.length != 1
// 242:
// 243:           path = pathname.arguments.fetch(0)
// 244:           path if path.str_type?
// 245:         end
// 246:       end
// 247:     end
// 248:   end
// 249: end
