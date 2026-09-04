module cask

import ruby
import homebrew.rubocops.@shared as install_steps_shared

// Translated from Homebrew/brew `rubocops/cask/install_steps.rb`.
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
