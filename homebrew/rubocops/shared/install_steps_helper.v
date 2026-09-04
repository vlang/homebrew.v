module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/install_steps_helper.rb`.
// The original source is retained below until every stub has a typed V body.
pub const install_steps_explicit_bases = ['HOMEBREW_PREFIX', 'HOMEBREW_CELLAR', 'prefix', 'opt_prefix',
	'bin', 'sbin', 'lib', 'libexec', 'share', 'pkgshare', 'var', 'etc', 'pkgetc', 'rack',
	'staged_path', 'appdir', 'caskroom_path', 'temp', 'bash_completion', 'zsh_completion',
	'fish_completion', 'pwsh_completion']

const install_steps_file_methods = ['mkdir', 'mkdir_p', 'touch', 'move', 'mv', 'move_children',
	'move_contents', 'copy', 'remove', 'inreplace', 'symlink', 'ln_s', 'ln_sf']
const install_steps_link_methods = ['link_dir', 'link_children', 'symlink_tree', 'symlink_children']
const install_steps_config_methods = ['write', 'write_file']
const install_steps_service_methods = ['init_data_dir']
const install_steps_rebuild_methods = ['compile_gsettings_schemas', 'gio_querymodules',
	'update_gio_modules_cache', 'gdk_pixbuf_query_loaders', 'update_gdk_pixbuf_loaders_cache',
	'gtk_update_icon_cache', 'update_gtk_icon_cache', 'update_mime_database',
	'update_desktop_database']
const install_steps_keychain_methods = ['delete_keychain_certificate', 'delete_keychain_certificates']
const install_steps_permission_methods = ['set_permissions', 'set_ownership']
const install_steps_command_methods = ['run', 'terminate_process']
const install_steps_macho_methods = ['change_dylib_id']
const install_steps_notice_methods = ['warn']
const install_steps_formula_action_methods = ['configure_gcc_runtime', 'install_gzipped_executable',
	'configure_glibc_runtime', 'configure_clang_system', 'configure_php', 'bootstrap_cpython',
	'bootstrap_pypy']
const install_steps_scope_methods = ['if_path_exists', 'unless_path_exists', 'on_macos', 'on_linux']

pub struct InstallStepPath {
pub:
	path   string
	base   string
	source string
}

pub struct InstallStepSpan {
pub:
	name       string
	begin_pos  int
	end_pos    int
	body_begin int
	body_end   int
	indent     int
	source     string
}

pub struct InstallStepOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

pub struct InstallStepHelperAnalysis {
pub:
	source    string
	offenses  []InstallStepOffense
	corrected string
}

struct InstallStepLine {
	text        string
	start       int
	end         int
	newline_end int
	indent      int
}

pub fn install_steps_allowed_methods() []string {
	mut result := install_steps_file_methods.clone()
	result << install_steps_link_methods
	result << install_steps_config_methods
	result << install_steps_service_methods
	result << install_steps_rebuild_methods
	result << ['set_permissions']
	result << install_steps_command_methods
	result << install_steps_notice_methods
	result << install_steps_macho_methods
	result << install_steps_formula_action_methods
	result << install_steps_scope_methods
	return result
}

pub fn install_steps_cask_allowed_methods() []string {
	mut result := install_steps_file_methods.clone()
	result << install_steps_config_methods
	result << install_steps_keychain_methods
	result << install_steps_permission_methods
	result << install_steps_command_methods
	result << install_steps_macho_methods
	result << install_steps_scope_methods
	return result
}

pub fn install_steps_compatibility_methods() map[string]string {
	return {
		'mkdir':                       'mkdir_p'
		'mv':                          'move'
		'move_children':               'move_contents'
		'ln_s':                        'symlink'
		'ln_sf':                       'symlink'
		'link_dir':                    'symlink_tree'
		'link_children':               'symlink_children'
		'write':                       'write_file'
		'gio_querymodules':            'update_gio_modules_cache'
		'gdk_pixbuf_query_loaders':    'update_gdk_pixbuf_loaders_cache'
		'gtk_update_icon_cache':       'update_gtk_icon_cache'
		'delete_keychain_certificate': 'delete_keychain_certificates'
	}
}

pub fn install_steps_step_block_message(allowed []string) string {
	legacy := install_steps_compatibility_methods()
	canonical := allowed.filter(it !in legacy)
	return 'Steps blocks may only contain install step DSL calls. Prefer canonical calls: ${canonical.map('`\${it}`').join(', ')}.'
}

pub fn install_steps_official_homebrew_tap(path string) bool {
	lower := path.to_lower()
	marker := '/taps/homebrew/homebrew-'
	return lower.starts_with('taps/homebrew/homebrew-') || lower.contains(marker)
}

fn install_steps_lines(source string) []InstallStepLine {
	mut lines := []InstallStepLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		text := source[start..end]
		mut indent := 0
		for indent < text.len && (text[indent] == ` ` || text[indent] == `\t`) {
			indent++
		}
		lines << InstallStepLine{
			text: text
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			indent: indent
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return lines
}

fn install_steps_code(text string) string {
	mut quote := u8(0)
	mut escaped := false
	for index, character in text.bytes() {
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character == `"` || character == `'` {
			quote = character
		} else if character == `#` {
			return text[..index]
		}
	}
	return text
}

fn install_steps_method(trimmed string) string {
	mut start := 0
	if trimmed.starts_with('def ') {
		start = 4
	}
	mut end := start
	for end < trimmed.len {
		character := trimmed[end]
		if !(character.is_alnum() || character == `_` || character == `!` || character == `?`) {
			break
		}
		end++
	}
	return if end > start { trimmed[start..end] } else { '' }
}

fn install_steps_find_end(lines []InstallStepLine, start int) int {
	indent := lines[start].indent
	for index := start + 1; index < lines.len; index++ {
		if lines[index].indent == indent && install_steps_code(lines[index].text).trim_space() == 'end' {
			return index
		}
	}
	return start
}

pub fn install_steps_find_blocks(source string, name string) []InstallStepSpan {
	lines := install_steps_lines(source)
	mut spans := []InstallStepSpan{}
	for index, line in lines {
		trimmed := install_steps_code(line.text).trim_space()
		method := install_steps_method(trimmed)
		is_def := trimmed.starts_with('def ') && method == name
		is_block := method == name && (trimmed.ends_with(' do') || trimmed.contains(' do |'))
		if !is_def && !is_block {
			continue
		}
		if is_def && trimmed.contains('; end') {
			start := line.start + line.indent
			spans << InstallStepSpan{
				name: name
				begin_pos: start
				end_pos: line.end
				body_begin: line.end
				body_end: line.end
				indent: line.indent
				source: source[start..line.end]
			}
			continue
		}
		end_index := install_steps_find_end(lines, index)
		if end_index == index {
			continue
		}
		start := line.start + line.indent
		end_position := lines[end_index].start + line.indent + 3
		spans << InstallStepSpan{
			name: name
			begin_pos: start
			end_pos: end_position
			body_begin: line.newline_end
			body_end: lines[end_index].start
			indent: line.indent
			source: source[start..end_position]
		}
	}
	return spans
}

pub fn install_steps_find_block(source string, name string) ?InstallStepSpan {
	blocks := install_steps_find_blocks(source, name)
	return if blocks.len > 0 { blocks[0] } else { none }
}

fn install_steps_direct_statements_from_span(source string, span InstallStepSpan) []InstallStepSpan {
	lines := install_steps_lines(source)
	mut result := []InstallStepSpan{}
	direct_indent := span.indent + 2
	mut index := 0
	for index < lines.len && lines[index].start < span.body_begin {
		index++
	}
	for index < lines.len && lines[index].start < span.body_end {
		line := lines[index]
		trimmed := install_steps_code(line.text).trim_space()
		if line.indent != direct_indent || trimmed == '' || trimmed.starts_with('#') {
			index++
			continue
		}
		if trimmed == 'else' || trimmed == 'end' || trimmed.starts_with('elsif ') {
			index++
			continue
		}
		mut end_index := index
		if trimmed.ends_with(' do') || trimmed.contains(' do |') || trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('case ') {
			found := install_steps_find_end(lines, index)
			if found > index {
				end_index = found
			}
		} else if heredoc_pos := trimmed.index('<<~') {
			tag := trimmed[heredoc_pos + 3..].all_before(',').trim_space().trim('"\'')
			for cursor := index + 1; cursor < lines.len; cursor++ {
				if lines[cursor].text.trim_space() == tag {
					end_index = cursor
					break
				}
			}
		} else {
			for end_index + 1 < lines.len && lines[end_index + 1].start < span.body_end && lines[end_index + 1].indent > direct_indent {
				end_index++
			}
		}
		begin_position := line.start + line.indent
		end_position := lines[end_index].end
		result << InstallStepSpan{
			name: install_steps_method(trimmed)
			begin_pos: begin_position
			end_pos: end_position
			body_begin: if end_index > index { line.newline_end } else { line.end }
			body_end: if end_index > index { lines[end_index].start } else { line.end }
			indent: direct_indent
			source: source[begin_position..end_position]
		}
		index = end_index + 1
	}
	return result
}

pub fn install_steps_direct_statements(source string, block_name string) []InstallStepSpan {
	span := install_steps_find_block(source, block_name) or { return [] }
	return install_steps_direct_statements_from_span(source, span)
}

fn install_steps_collect_statements(source string, span InstallStepSpan, mut result []InstallStepSpan) {
	for statement in install_steps_direct_statements_from_span(source, span) {
		result << statement
		if statement.name in install_steps_scope_methods {
			child := InstallStepSpan{
				name: statement.name
				begin_pos: statement.begin_pos
				end_pos: statement.end_pos
				body_begin: statement.body_begin
				body_end: statement.body_end
				indent: statement.indent
				source: statement.source
			}
			install_steps_collect_statements(source, child, mut result)
		}
	}
}

pub fn install_steps_all_statements(source string, block_name string) []InstallStepSpan {
	span := install_steps_find_block(source, block_name) or { return [] }
	mut result := []InstallStepSpan{}
	install_steps_collect_statements(source, span, mut result)
	return result
}

pub fn install_steps_normalised_source(source string) string {
	mut pieces := []string{}
	for line in source.split('\n') {
		if line.trim_space().starts_with('#') {
			continue
		}
		pieces << line.trim_space()
	}
	return pieces.join(' ').split_any(' \t\r\n').filter(it != '').join(' ')
}

fn install_steps_unquote(value string) ?string {
	trimmed := value.trim_space().trim('()')
	if trimmed.len < 2 || !((trimmed[0] == `"` && trimmed[trimmed.len - 1] == `"`) || (trimmed[0] == `'` && trimmed[trimmed.len - 1] == `'`)) {
		return none
	}
	return trimmed[1..trimmed.len - 1].replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
}

pub fn install_steps_parse_path(expression string) ?InstallStepPath {
	mut value := expression.trim_space().trim('()')
	if literal := install_steps_unquote(value) {
		return InstallStepPath{ path: literal }
	}
	slash := value.index('/"') or { value.index("/'") or { return none } }
	base_source := value[..slash].trim_space().trim('()')
	base := match base_source {
		'HOMEBREW_PREFIX' { 'homebrew_prefix' }
		'appdir', 'etc', 'home', 'opt_prefix', 'pkgetc', 'prefix', 'staged_path', 'var' {
			base_source
		}
		else {
			return none
		}
	}
	value = value[slash + 1..]
	path := install_steps_unquote(value) or { return none }
	return InstallStepPath{ path: path, base: base }
}

pub fn install_steps_absolute_path(path InstallStepPath) bool {
	return path.path.starts_with('/') || path.path.starts_with('~/')
}

pub fn install_steps_relative_path(path InstallStepPath) bool {
	return path.base == '' && !install_steps_absolute_path(path)
}

pub fn install_steps_path_source(path InstallStepPath) string {
	if path.source != '' {
		return path.source
	}
	escaped := path.path.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
	return '"${escaped}"'
}

pub fn install_steps_path_keyword(path InstallStepPath, base string, keyword string) string {
	return if path.base == '' || path.base == base { '' } else { '${keyword}: :${path.base}' }
}

pub fn install_steps_path_keywords(path InstallStepPath, base string, keyword string) string {
	value := install_steps_path_keyword(path, base, keyword)
	return if value == '' { '' } else { ', ${value}' }
}

pub fn install_steps_kwargs(kwargs []string) string {
	return if kwargs.len == 0 { '' } else { ', ${kwargs.join(', ')}' }
}

pub fn install_steps_path_parent(path InstallStepPath) ?InstallStepPath {
	clean := path.path.trim_right('/')
	separator := clean.last_index('/') or { return none }
	parent := if separator == 0 { '/' } else { clean[..separator] }
	if parent == '.' || parent == '' {
		return none
	}
	return InstallStepPath{ path: parent, base: path.base }
}

pub fn install_steps_paths_match(path InstallStepPath, other InstallStepPath) bool {
	return path.base == other.base && path.path == other.path
}

pub fn install_steps_explicit_formula_path(path string) bool {
	if path.starts_with('/') || path.starts_with('~') {
		return true
	}
	for token in install_steps_explicit_bases {
		if path.starts_with('{{${token}}}') {
			return true
		}
	}
	return false
}

pub fn install_steps_first_argument(source string) string {
	method := install_steps_method(source.trim_space())
	if method == '' {
		return ''
	}
	mut rest := source.trim_space()[method.len..].trim_space()
	if rest.starts_with('(') {
		rest = rest[1..]
	}
	mut quote := u8(0)
	mut depth := 0
	for index, character in rest.bytes() {
		if quote != 0 {
			if character == quote && (index == 0 || rest[index - 1] != `\\`) {
				quote = 0
			}
			continue
		}
		if character == `"` || character == `'` {
			quote = character
		} else if character == `[` || character == `{` || character == `(` {
			depth++
		} else if character == `]` || character == `}` || character == `)` {
			depth--
		} else if character == `,` && depth == 0 {
			return rest[..index].trim_space()
		}
	}
	return rest.all_before(' do').trim_space().trim_right(')')
}

fn install_steps_allowed_interpolation(source string) bool {
	mut rest := source
	for {
		start := rest.index('#{') or { return true }
		end := rest.index_after('}', start + 2) or { return false }
		value := rest[start + 2..end].trim_space()
		if value !in ['formula_name', 'name', 'token', 'version', 'version.major',
			'version.major_minor'] {
			return false
		}
		rest = rest[end + 1..]
	}
	return true
}

fn install_steps_block_offense(source string, span InstallStepSpan, allowed []string) ?InstallStepOffense {
	for statement in install_steps_direct_statements_from_span(source, span) {
		method := statement.name
		if method == '' || (statement.source.trim_space().contains('.') && statement.source.trim_space().all_before(' ').contains('.')) {
			return InstallStepOffense{ begin_pos: statement.begin_pos, end_pos: statement.end_pos }
		}
		is_scope := method in install_steps_scope_methods
		if method !in allowed || (is_scope && !statement.source.contains(' do')) {
			return InstallStepOffense{ begin_pos: statement.begin_pos, end_pos: statement.end_pos }
		}
		if !install_steps_allowed_interpolation(statement.source) {
			position := statement.source.index('#{') or { 0 }
			return InstallStepOffense{
				begin_pos: statement.begin_pos + position
				end_pos: statement.begin_pos + position + 2
			}
		}
		if is_scope {
			child := InstallStepSpan{
				name: method
				begin_pos: statement.begin_pos
				end_pos: statement.end_pos
				body_begin: statement.body_begin
				body_end: statement.body_end
				indent: statement.indent
				source: statement.source
			}
			if offense := install_steps_block_offense(source, child, allowed) {
				return offense
			}
		}
	}
	return none
}

pub fn install_steps_block_offense_for(source string, block_name string, allowed []string) ?InstallStepOffense {
	span := install_steps_find_block(source, block_name) or { return none }
	return install_steps_block_offense(source, span, allowed)
}

pub fn install_steps_brew_ruby_offense(source string, block_name string) ?InstallStepOffense {
	span := install_steps_find_block(source, block_name) or { return none }
	for statement in install_steps_direct_statements_from_span(source, span) {
		if statement.name == 'run' && statement.source.contains('"{{HOMEBREW_BREW_FILE}}"') && statement.source.contains('args:') && statement.source.contains('["ruby"') {
			position := statement.source.index('"{{HOMEBREW_BREW_FILE}}"') or { 0 }
			return InstallStepOffense{
				begin_pos: statement.begin_pos + position
				end_pos: statement.begin_pos + position + '"{{HOMEBREW_BREW_FILE}}"'.len
			}
		}
		if statement.name in install_steps_scope_methods {
			if offense := install_steps_brew_ruby_offense(statement.source, statement.name) {
				return InstallStepOffense{
					begin_pos: statement.begin_pos + offense.begin_pos
					end_pos: statement.begin_pos + offense.end_pos
				}
			}
		}
	}
	return none
}

pub fn install_steps_indented_lines(step_lines []string, indent int) []string {
	mut result := []string{}
	for step_line in step_lines {
		if step_line.contains('<<~') {
			result << ' '.repeat(indent) + step_line
		} else {
			for line in step_line.split('\n') {
				result << ' '.repeat(indent) + line
			}
		}
	}
	return result
}

pub fn install_steps_block_source(block_name string, step_lines []string, indent int) string {
	mut lines := ['${block_name} do']
	lines << install_steps_indented_lines(step_lines, indent + 2)
	lines << '${' '.repeat(indent)}end'
	return lines.join('\n')
}

pub fn install_steps_append_lines(block_source string, step_lines []string, indent int) string {
	end_position := block_source.last_index('\n${' '.repeat(indent)}end') or { return block_source }
	inserted := install_steps_indented_lines(step_lines, indent + 2).join('\n')
	return block_source[..end_position + 1] + inserted + '\n' + block_source[end_position + 1..]
}

pub fn install_steps_simple_line(source string, default_base string, default_source_base string,
	default_target_base string, rebuild_actions bool) ?string {
	normalised := install_steps_normalised_source(source)
	if rebuild_actions {
		rebuild := {
			'system Formula["glib"].opt_bin/"glib-compile-schemas", HOMEBREW_PREFIX/"share/glib-2.0/schemas"':                   'compile_gsettings_schemas'
			'system Formula["gdk-pixbuf"].opt_bin/"gdk-pixbuf-query-loaders", "--update-cache"':                                 'update_gdk_pixbuf_loaders_cache'
			'system Formula["gtk+3"].opt_bin/"gtk3-update-icon-cache", "-q", "-t", "-f", HOMEBREW_PREFIX/"share/icons/hicolor"': 'update_gtk_icon_cache'
			'system Formula["shared-mime-info"].opt_bin/"update-mime-database", HOMEBREW_PREFIX/"share/mime"':                   'update_mime_database'
			'system Formula["desktop-file-utils"].opt_bin/"update-desktop-database", HOMEBREW_PREFIX/"share/applications"':      'update_desktop_database'
		}
		if normalised in rebuild {
			return rebuild[normalised]
		}
	}
	if normalised.ends_with('.mkpath') {
		expression := normalised[..normalised.len - '.mkpath'.len]
		path := install_steps_parse_path(expression) or { return none }
		if install_steps_relative_path(path) {
			return none
		}
		return 'mkdir_p ${install_steps_path_source(path)}${install_steps_path_keywords(path, default_base, 'base')}'
	}
	if normalised.starts_with('FileUtils.touch ') {
		path := install_steps_parse_path(normalised['FileUtils.touch '.len..]) or { return none }
		if install_steps_relative_path(path) {
			return none
		}
		return 'touch ${install_steps_path_source(path)}${install_steps_path_keywords(path, default_base, 'base')}'
	}
	if normalised.starts_with('FileUtils.mv ') {
		arguments := normalised['FileUtils.mv '.len..].split(', ')
		if arguments.len != 2 {
			return none
		}
		source_path := install_steps_parse_path(arguments[0]) or { return none }
		target_path := install_steps_parse_path(arguments[1]) or { return none }
		if install_steps_relative_path(source_path) || install_steps_relative_path(target_path) {
			return none
		}
		kwargs := [
			install_steps_path_keyword(source_path, default_source_base, 'source_base'),
			install_steps_path_keyword(target_path, default_target_base, 'target_base'),
		].filter(it != '')
		return 'move ${install_steps_path_source(source_path)}, ${install_steps_path_source(target_path)}${install_steps_kwargs(kwargs)}'
	}
	if normalised.starts_with('FileUtils.ln_s ') || normalised.starts_with('FileUtils.ln_sf ') {
		overwrite := normalised.starts_with('FileUtils.ln_sf ')
		prefix := if overwrite { 'FileUtils.ln_sf ' } else { 'FileUtils.ln_s ' }
		arguments := normalised[prefix.len..].split(', ')
		if arguments.len != 2 {
			return none
		}
		source_path := install_steps_parse_path(arguments[0]) or { return none }
		target_path := install_steps_parse_path(arguments[1]) or { return none }
		if install_steps_relative_path(target_path) {
			return none
		}
		source_keyword := if install_steps_relative_path(source_path) {
			'source_base: :relative'
		} else {
			install_steps_path_keyword(source_path, default_source_base, 'source_base')
		}
		mut kwargs := [source_keyword,
			install_steps_path_keyword(target_path, default_target_base, 'target_base')].filter(it != '')
		if overwrite {
			kwargs << 'overwrite: true'
		}
		return 'symlink ${install_steps_path_source(source_path)}, ${install_steps_path_source(target_path)}${install_steps_kwargs(kwargs)}'
	}
	for write_method in ['.atomic_write ', '.write '] {
		if position := normalised.index(write_method) {
			path_expression := normalised[..position]
			content := normalised[position + write_method.len..]
			path := install_steps_parse_path(path_expression) or { return none }
			if install_steps_relative_path(path) || !content.starts_with('"') {
				return none
			}
			return 'write_file ${install_steps_path_source(path)}, ${content}${install_steps_path_keywords(path, default_base, 'base')}'
		}
	}
	return none
}

pub fn install_steps_simple_lines(source string, block_name string, default_base string,
	default_source_base string, default_target_base string) ?[]string {
	statements := install_steps_direct_statements(source, block_name)
	if statements.len == 0 {
		return none
	}
	mut result := []string{}
	for statement in statements {
		line := install_steps_simple_line(statement.source, default_base, default_source_base, default_target_base, true) or { return none }
		result << line
	}
	return result
}

fn install_steps_selector_offset(statement InstallStepSpan) int {
	return statement.begin_pos
}

fn install_steps_keyword_position(source string, keyword string) ?int {
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

fn install_steps_compatibility_correction(statement string, method string) string {
	replacements := install_steps_compatibility_methods()
	mut corrected := statement
	if method in replacements {
		corrected = replacements[method] + corrected[method.len..]
	}
	if method in ['move', 'mv', 'symlink', 'ln_s', 'ln_sf'] {
		if corrected.contains('force: true') {
			if corrected.contains('overwrite:') {
				corrected = corrected.replace('overwrite: false', 'overwrite: true')
				corrected = corrected.replace('force: true,\n', '').replace('force: true,', '').replace('force: true', '')
			} else {
				corrected = corrected.replace('force:', 'overwrite:')
			}
		}
		if corrected.contains('force: false') {
			corrected = corrected.replace(',\n               force: false', '').replace(',\n                  force: false', '').replace(', force: false', '').replace('force: false', '')
		}
	}
	if method in ['symlink', 'ln_s', 'ln_sf'] {
		if corrected.contains('uninstall: true') {
			if corrected.contains('remove_on_uninstall:') {
				corrected = corrected.replace('remove_on_uninstall: false', 'remove_on_uninstall: true')
				corrected = corrected.replace('uninstall: true,\n', '').replace('uninstall: true,', '').replace('uninstall: true', '')
			} else {
				corrected = corrected.replace('uninstall:', 'remove_on_uninstall:')
			}
		}
	}
	if method == 'ln_sf' && !corrected.contains('overwrite:') {
		corrected = corrected.trim_right(' \t\n') + ', overwrite: true'
	}
	if method == 'write' {
		if corrected.contains('base:') {
			corrected = corrected.trim_right(' \t\n') + ', overwrite: false, append_newline: true'
		} else {
			corrected = corrected.trim_right(' \t\n') + ', overwrite: false, append_newline: true'
		}
	}
	return corrected.split('\n').filter(it.trim_space() != '').join('\n').replace(',\nend', '\nend')
}

pub fn install_steps_compatibility_analysis(source string, block_name string,
	allowed []string) InstallStepHelperAnalysis {
	mut offenses := []InstallStepOffense{}
	mut corrected := source
	statements := install_steps_direct_statements(source, block_name)
	replacements := install_steps_compatibility_methods()
	for statement in statements {
		method := statement.name
		if method !in allowed {
			continue
		}
		mut statement_offense := false
		if method in replacements {
			offenses << InstallStepOffense{
				begin_pos: install_steps_selector_offset(statement)
				end_pos: install_steps_selector_offset(statement) + method.len
				message: 'Use `${replacements[method]}` instead of legacy install step `${method}`.'
				replacement: replacements[method]
			}
			statement_offense = true
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
		} else {
			map[string]string{}
		}
		for keyword, replacement in keyword_map {
			if position := install_steps_keyword_position(statement.source, keyword) {
				offenses << InstallStepOffense{
					begin_pos: statement.begin_pos + position
					end_pos: statement.begin_pos + position + keyword.len
					message: 'Use `${replacement}:` instead of legacy install step keyword `${keyword}:`.'
					replacement: replacement
				}
				statement_offense = true
			}
		}
		if statement_offense {
			corrected_statement := install_steps_compatibility_correction(statement.source, method)
			corrected = corrected.replace(statement.source, corrected_statement)
		}
	}
	return InstallStepHelperAnalysis{ source: source, offenses: offenses, corrected: corrected }
}

fn install_step_path_value(path InstallStepPath) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::InstallStepsHelper::InstallStepPath'
		repr: install_steps_path_source(path)
		map_data: {
			'path':   ruby.string_value(path.path)
			'base':   ruby.string_value(path.base)
			'source': ruby.string_value(path.source)
		}
	}
}

fn install_step_path_from_value(value ruby.Value) ?InstallStepPath {
	if value.type_name == 'RuboCop::Cop::InstallStepsHelper::InstallStepPath' {
		return InstallStepPath{
			path: (value.map_data['path'] or { ruby.string_value('') }).as_string()
			base: (value.map_data['base'] or { ruby.string_value('') }).as_string()
			source: (value.map_data['source'] or { ruby.string_value('') }).as_string()
		}
	}
	return install_steps_parse_path(value.as_string())
}

fn install_step_offense_value(offense InstallStepOffense) ruby.Value {
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

fn install_step_analysis_value(analysis InstallStepHelperAnalysis) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::InstallStepsHelper::Analysis'
		repr: analysis.source
		array_data: analysis.offenses.map(install_step_offense_value(it))
		map_data: {
			'offenses':  ruby.array_value(analysis.offenses.map(install_step_offense_value(it)))
			'corrected': ruby.string_value(analysis.corrected)
		}
	}
}

fn install_steps_helper_source(args []ruby.Value) string {
	return if args.len > 0 { args[0].as_string() } else { '' }
}

// Ruby method `official_homebrew_tap?(file_path)` at line 116.
pub fn ruby_install_steps_helper_l116_d1_official_homebrew_tap(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(install_steps_official_homebrew_tap(install_steps_helper_source(args)))
}

// Ruby method `step_block_msg(allowed_methods)` at line 121.
pub fn ruby_install_steps_helper_l121_d2_step_block_msg(args ...ruby.Value) ruby.Value {
	allowed := if args.len > 0 && args[0].type_name == 'Array' {
		(args[0].as_array() or { [] }).map(it.as_string())
	} else {
		install_steps_allowed_methods()
	}
	return ruby.string_value(install_steps_step_block_message(allowed))
}

// Ruby method `add_compatibility_step_offenses(block_node, allowed_methods: ALLOWED_STEP_METHODS)` at line 132.
pub fn ruby_install_steps_helper_l132_d3_add_compatibility_step_offenses(args ...ruby.Value) ruby.Value {
	return install_step_analysis_value(install_steps_compatibility_analysis(install_steps_helper_source(args), 'post_install_steps', install_steps_allowed_methods()))
}

// Ruby method `install_step_block_offense_node(block_node, allowed_methods: ALLOWED_STEP_METHODS)` at line 161.
pub fn ruby_install_steps_helper_l161_d4_install_step_block_offense_node(args ...ruby.Value) ruby.Value {
	offense := install_steps_block_offense_for(install_steps_helper_source(args), 'post_install_steps', install_steps_allowed_methods()) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return install_step_offense_value(offense)
}

// Ruby method `brew_ruby_step_node(block_node)` at line 175.
pub fn ruby_install_steps_helper_l175_d5_brew_ruby_step_node(args ...ruby.Value) ruby.Value {
	offense := install_steps_brew_ruby_offense(install_steps_helper_source(args), 'post_install_steps') or { return ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	return install_step_offense_value(offense)
}

// Ruby method `simple_install_step_lines(body_node, default_base:, default_source_base:, default_target_base:,` at line 211.
pub fn ruby_install_steps_helper_l211_d6_simple_install_step_lines(args ...ruby.Value) ruby.Value {
	lines := install_steps_simple_lines(install_steps_helper_source(args), 'post_install', 'var', 'prefix', 'prefix') or { return ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	return ruby.string_array_value(lines)
}

// Ruby method `install_steps_block_source(block_name, step_lines, indent)` at line 226.
pub fn ruby_install_steps_helper_l226_d7_install_steps_block_source(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string().trim_left(':') } else { 'post_install_steps' }
	lines := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	indent := if args.len > 2 { int(args[2].int_data) } else { 0 }
	return ruby.string_value(install_steps_block_source(name, lines, indent))
}

// Ruby method `append_install_step_lines(corrector, block_node, step_lines)` at line 242.
pub fn ruby_install_steps_helper_l242_d8_append_install_step_lines(args ...ruby.Value) ruby.Value {
	lines := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	indent := if args.len > 2 { int(args[2].int_data) } else { 0 }
	return ruby.string_value(install_steps_append_lines(install_steps_helper_source(args), lines, indent))
}

// Ruby method `direct_install_step_nodes(body_node)` at line 252.
pub fn ruby_install_steps_helper_l252_d9_direct_install_step_nodes(args ...ruby.Value) ruby.Value {
	spans := install_steps_direct_statements(install_steps_helper_source(args), 'post_install')
	return ruby.array_value(spans.map(ruby.structured_value('RuboCop::AST::Node', it.source, {
		'name':      it.name
		'begin_pos': it.begin_pos.str()
		'end_pos':   it.end_pos.str()
	})))
}

// Ruby method `normalised_install_step_source(node)` at line 259.
pub fn ruby_install_steps_helper_l259_d10_normalised_install_step_source(args ...ruby.Value) ruby.Value {
	return ruby.string_value(install_steps_normalised_source(install_steps_helper_source(args)))
}

// Ruby method `add_compatibility_step_keyword_offenses(send_node)` at line 266.
pub fn ruby_install_steps_helper_l266_d11_add_compatibility_step_keyword_offenses(args ...ruby.Value) ruby.Value {
	return install_step_analysis_value(install_steps_compatibility_analysis(install_steps_helper_source(args), 'post_install_steps', install_steps_allowed_methods()))
}

// Ruby method `correct_compatibility_step_keyword(corrector, send_node, options, legacy_pair, replacement)` at line 294.
pub fn ruby_install_steps_helper_l294_d12_correct_compatibility_step_keyword(args ...ruby.Value) ruby.Value {
	return ruby.string_value(install_steps_compatibility_analysis(install_steps_helper_source(args), 'post_install_steps', install_steps_allowed_methods()).corrected)
}

// Ruby method `add_compatibility_step_method_corrections(corrector, send_node)` at line 332.
pub fn ruby_install_steps_helper_l332_d13_add_compatibility_step_method_corrections(args ...ruby.Value) ruby.Value {
	return ruby.string_value(install_steps_compatibility_analysis(install_steps_helper_source(args), 'post_install_steps', install_steps_allowed_methods()).corrected)
}

// Ruby method `add_step_keyword(corrector, send_node, keyword)` at line 354.
pub fn ruby_install_steps_helper_l354_d14_add_step_keyword(args ...ruby.Value) ruby.Value {
	keyword := if args.len > 1 { args[1].as_string() } else { 'overwrite: true' }
	return ruby.string_value('${install_steps_helper_source(args).trim_right(' \t\n')}, ${keyword}')
}

// Ruby method `install_step_offense_node(node, allowed_methods)` at line 379.
pub fn ruby_install_steps_helper_l379_d15_install_step_offense_node(args ...ruby.Value) ruby.Value {
	source := 'post_install_steps do\n  ${install_steps_helper_source(args)}\nend'
	offense := install_steps_block_offense_for(source, 'post_install_steps', install_steps_allowed_methods()) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return install_step_offense_value(offense)
}

// Ruby method `invalid_step_argument_node(send_node)` at line 405.
pub fn ruby_install_steps_helper_l405_d16_invalid_step_argument_node(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!install_steps_allowed_interpolation(install_steps_helper_source(args)))
}

// Ruby method `indented_install_step_lines(step_lines, indent)` at line 413.
pub fn ruby_install_steps_helper_l413_d17_indented_install_step_lines(args ...ruby.Value) ruby.Value {
	lines := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	indent := if args.len > 1 { int(args[1].int_data) } else { 0 }
	return ruby.string_array_value(install_steps_indented_lines(lines, indent))
}

// Ruby method `allowed_step_argument_node?(node)` at line 424.
pub fn ruby_install_steps_helper_l424_d18_allowed_step_argument_node(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space()
	if source == '' {
		return ruby.bool_value(false)
	}
	allowed_type := source in ['true', 'false', 'nil'] || source.starts_with('"') || source.starts_with("'") || source.starts_with(':') || source.starts_with('[') || source.starts_with('{') || source[0].is_digit()
	return ruby.bool_value(allowed_type && install_steps_allowed_interpolation(source))
}

// Ruby method `allowed_step_template_node?(node)` at line 432.
pub fn ruby_install_steps_helper_l432_d19_allowed_step_template_node(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space().trim('{}')
	return ruby.bool_value(source in ['formula_name', 'name', 'token', 'version',
		'version.major', 'version.major_minor'])
}

// Ruby method `simple_install_step_line(node, default_base:, default_source_base:, default_target_base:, rebuild_actions:,` at line 464.
pub fn ruby_install_steps_helper_l464_d20_simple_install_step_line(args ...ruby.Value) ruby.Value {
	line := install_steps_simple_line(install_steps_helper_source(args), 'var', 'prefix', 'prefix', true) or { return ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	return ruby.string_value(line)
}

// Ruby method `mkdir_step_line(path, default_base)` at line 536.
pub fn ruby_install_steps_helper_l536_d21_mkdir_step_line(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if install_steps_relative_path(path) {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'var' }
	return ruby.string_value('mkdir_p ${install_steps_path_source(path)}${install_steps_path_keywords(path, base, 'base')}')
}

// Ruby method `touch_step_line(path, default_base)` at line 549.
pub fn ruby_install_steps_helper_l549_d22_touch_step_line(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if install_steps_relative_path(path) {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'var' }
	return ruby.string_value('touch ${install_steps_path_source(path)}${install_steps_path_keywords(path, base, 'base')}')
}

// Ruby method `move_step_line(source, target, default_source_base, default_target_base)` at line 564.
pub fn ruby_install_steps_helper_l564_d23_move_step_line(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	source := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	target := install_step_path_from_value(args[1]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if install_steps_relative_path(source) || install_steps_relative_path(target) {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	source_base := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'prefix' }
	target_base := if args.len > 3 { args[3].as_string().trim_left(':') } else { 'prefix' }
	kwargs := [install_steps_path_keyword(source, source_base, 'source_base'),
		install_steps_path_keyword(target, target_base, 'target_base')].filter(it != '')
	return ruby.string_value('move ${install_steps_path_source(source)}, ${install_steps_path_source(target)}${install_steps_kwargs(kwargs)}')
}

// Ruby method `symlink_step_line(overwrite, source, target, default_source_base, default_target_base)` at line 584.
pub fn ruby_install_steps_helper_l584_d24_symlink_step_line(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	overwrite := args[0].bool_data
	source := install_step_path_from_value(args[1]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	target := install_step_path_from_value(args[2]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if install_steps_relative_path(target) {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	source_base := if args.len > 3 { args[3].as_string().trim_left(':') } else { 'prefix' }
	target_base := if args.len > 4 { args[4].as_string().trim_left(':') } else { 'prefix' }
	mut kwargs := [if install_steps_relative_path(source) {
		'source_base: :relative'
	} else {
		install_steps_path_keyword(source, source_base, 'source_base')
	}, install_steps_path_keyword(target, target_base, 'target_base')].filter(it != '')
	if overwrite {
		kwargs << 'overwrite: true'
	}
	return ruby.string_value('symlink ${install_steps_path_source(source)}, ${install_steps_path_source(target)}${install_steps_kwargs(kwargs)}')
}

// Ruby method `write_step_line(path, content_node, default_base)` at line 609.
pub fn ruby_install_steps_helper_l609_d25_write_step_line(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if install_steps_relative_path(path) {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'var' }
	return ruby.string_value('write_file ${install_steps_path_source(path)}, ${args[1].as_string()}${install_steps_path_keywords(path, base, 'base')}')
}

// Ruby method `write_content_source(content_node, kwargs)` at line 621.
pub fn ruby_install_steps_helper_l621_d26_write_content_source(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	kwargs := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	return ruby.string_value('${args[0].as_string()}${install_steps_kwargs(kwargs)}')
}

// Ruby method `set_permissions_step_line(send_node, default_base)` at line 641.
pub fn ruby_install_steps_helper_l641_d27_set_permissions_step_line(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space()
	rest := source.trim_string_left('set_permissions ').split(', ')
	if rest.len != 2 || !rest[1].starts_with('"') {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := install_steps_parse_path(rest[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'staged_path' }
	return ruby.string_value('set_permissions ${install_steps_path_source(path)}, ${rest[1]}${install_steps_path_keywords(path, base, 'base')}')
}

// Ruby method `set_ownership_step_line(send_node, default_base)` at line 659.
pub fn ruby_install_steps_helper_l659_d28_set_ownership_step_line(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space()
	rest := source.trim_string_left('set_ownership ')
	path_expression := rest.all_before(',')
	path := install_steps_parse_path(path_expression) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return ruby.string_value('set_ownership ${install_steps_path_source(path)}${rest[path_expression.len..]}')
}

// Ruby method `permission_paths_source(node, default_base)` at line 689.
pub fn ruby_install_steps_helper_l689_d29_permission_paths_source(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if install_steps_absolute_path(path) {
		''
	} else if path.base != '' {
		path.base
	} else if args.len > 1 {
		args[1].as_string().trim_left(':')
	} else {
		'staged_path'
	}
	return ruby.array_value([
		ruby.string_value(install_steps_path_source(path)),
		ruby.string_value(base),
	])
}

// Ruby method `cask_permission_path(node)` at line 714.
pub fn ruby_install_steps_helper_l714_d30_cask_permission_path(args ...ruby.Value) ruby.Value {
	if install_steps_helper_source(args).trim_space() == 'staged_path.to_s' {
		return install_step_path_value(InstallStepPath{ path: '.', base: 'staged_path' })
	}
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return install_step_path_value(path)
}

// Ruby method `dstr_permission_path(node)` at line 726.
pub fn ruby_install_steps_helper_l726_d31_dstr_permission_path(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space()
	if source.len < 2 || !source.starts_with('"') || !source.ends_with('"') {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	content := source[1..source.len - 1]
	mut base := ''
	mut path := content
	for template, candidate in {
		'#{HOMEBREW_PREFIX}': 'homebrew_prefix'
		'#{appdir}':          'appdir'
		'#{staged_path}':     'staged_path'
	} {
		if path.starts_with(template + '/') {
			base = candidate
			path = path[template.len + 1..]
		}
	}
	if base == '' && !path.starts_with('/') && !path.starts_with('~/') {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	if !install_steps_allowed_interpolation(source) && base == '' {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return install_step_path_value(InstallStepPath{ path: path, base: base, source: source })
}

// Ruby method `interpolated_path_base(node)` at line 766.
pub fn ruby_install_steps_helper_l766_d32_interpolated_path_base(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space().trim('{}')
	base := match source {
		'HOMEBREW_PREFIX' { 'homebrew_prefix' }
		'appdir', 'staged_path' { source }
		else { '' }
	}
	return if base == '' {
		ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	} else {
		ruby.object_value('Symbol', ':${base}')
	}
}

// Ruby method `install_step_path_keywords_for_base(base, default_base)` at line 781.
pub fn ruby_install_steps_helper_l781_d33_install_step_path_keywords_for_base(args ...ruby.Value) ruby.Value {
	base := if args.len > 0 { args[0].as_string().trim_left(':') } else { '' }
	default_base := if args.len > 1 { args[1].as_string().trim_left(':') } else { '' }
	return ruby.string_value(if base != '' && base != default_base {
		', base: :${base}'
	} else {
		''
	})
}

// Ruby method `fileutils_or_no_receiver?(send_node)` at line 786.
pub fn ruby_install_steps_helper_l786_d34_fileutils_or_no_receiver(args ...ruby.Value) ruby.Value {
	trimmed := install_steps_helper_source(args).trim_space()
	selector := trimmed.all_before(' ')
	return ruby.bool_value(!selector.contains('.') || selector.starts_with('FileUtils.'))
}

// Ruby method `install_step_path(node)` at line 792.
pub fn ruby_install_steps_helper_l792_d35_install_step_path(args ...ruby.Value) ruby.Value {
	path := install_steps_parse_path(install_steps_helper_source(args)) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return install_step_path_value(path)
}

// Ruby method `install_step_path_base(node)` at line 810.
pub fn ruby_install_steps_helper_l810_d36_install_step_path_base(args ...ruby.Value) ruby.Value {
	source := install_steps_helper_source(args).trim_space()
	base := match source {
		'HOMEBREW_PREFIX' { 'homebrew_prefix' }
		'appdir', 'etc', 'home', 'opt_prefix', 'pkgetc', 'prefix', 'staged_path', 'var' { source }
		else { '' }
	}
	return if base == '' {
		ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	} else {
		ruby.object_value('Symbol', ':${base}')
	}
}

// Ruby method `relative_install_step_path?(path)` at line 823.
pub fn ruby_install_steps_helper_l823_d37_relative_install_step_path(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(install_steps_relative_path(path))
}

// Ruby method `absolute_install_step_path?(path)` at line 828.
pub fn ruby_install_steps_helper_l828_d38_absolute_install_step_path(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or { return ruby.bool_value(false) }
	return ruby.bool_value(install_steps_absolute_path(path))
}

// Ruby method `install_step_path_source(path)` at line 833.
pub fn ruby_install_steps_helper_l833_d39_install_step_path_source(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or { return ruby.string_value('') }
	return ruby.string_value(install_steps_path_source(path))
}

// Ruby method `install_step_path_keywords(path, base:, keyword:)` at line 838.
pub fn ruby_install_steps_helper_l838_d40_install_step_path_keywords(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or { return ruby.string_value('') }
	base := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'var' }
	keyword := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'base' }
	return ruby.string_value(install_steps_path_keywords(path, base, keyword))
}

// Ruby method `install_step_path_keyword(path, base:, keyword:)` at line 844.
pub fn ruby_install_steps_helper_l844_d41_install_step_path_keyword(args ...ruby.Value) ruby.Value {
	path := install_step_path_from_value(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'var' }
	keyword := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'base' }
	value := install_steps_path_keyword(path, base, keyword)
	return if value == '' {
		ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	} else {
		ruby.string_value(value)
	}
}

// Ruby method `install_step_kwargs(kwargs)` at line 851.
pub fn ruby_install_steps_helper_l851_d42_install_step_kwargs(args ...ruby.Value) ruby.Value {
	kwargs := if args.len > 0 { args[0].as_string_array() or { [] } } else { [] }
	return ruby.string_value(install_steps_kwargs(kwargs))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module InstallStepsHelper
// 7:       OFFICIAL_HOMEBREW_TAP_PATH_REGEX = %r{(?:\A|/)Taps/homebrew/homebrew-[\w-]+/}i
// 8:       FILE_PREPARATION_STEP_METHODS =
// 9:         [:mkdir, :mkdir_p, :touch, :move, :mv, :move_children, :move_contents, :copy, :remove, :inreplace,
// 10:          :symlink,
// 11:          :ln_s, :ln_sf].freeze
// 12:       LINK_STEP_METHODS = [:link_dir, :link_children, :symlink_tree, :symlink_children].freeze
// 13:       CONFIG_WRITE_STEP_METHODS = [:write, :write_file].freeze
// 14:       SERVICE_DATA_STEP_METHODS = [:init_data_dir].freeze
// 15:       REBUILD_ACTION_STEP_METHODS =
// 16:         [:compile_gsettings_schemas, :gio_querymodules, :update_gio_modules_cache, :gdk_pixbuf_query_loaders,
// 17:          :update_gdk_pixbuf_loaders_cache, :gtk_update_icon_cache, :update_gtk_icon_cache,
// 18:          :update_mime_database, :update_desktop_database].freeze
// 19:       KEYCHAIN_STEP_METHODS = [:delete_keychain_certificate, :delete_keychain_certificates].freeze
// 20:       PERMISSION_STEP_METHODS = [:set_permissions, :set_ownership].freeze
// 21:       COMMAND_STEP_METHODS = [:run, :terminate_process].freeze
// 22:       MACHO_STEP_METHODS = [:change_dylib_id].freeze
// 23:       NOTICE_STEP_METHODS = [:warn].freeze
// 24:       FORMULA_ACTION_STEP_METHODS =
// 25:         [:configure_gcc_runtime, :install_gzipped_executable, :configure_glibc_runtime,
// 26:          :configure_clang_system, :configure_php, :bootstrap_cpython, :bootstrap_pypy].freeze
// 27:       STEP_SCOPE_METHODS = [:if_path_exists, :unless_path_exists, :on_macos, :on_linux].freeze
// 28:       COMPATIBILITY_STEP_METHOD_REPLACEMENTS = T.let(
// 29:         {
// 30:           mkdir:                       :mkdir_p,
// 31:           mv:                          :move,
// 32:           move_children:               :move_contents,
// 33:           ln_s:                        :symlink,
// 34:           ln_sf:                       :symlink,
// 35:           link_dir:                    :symlink_tree,
// 36:           link_children:               :symlink_children,
// 37:           write:                       :write_file,
// 38:           gio_querymodules:            :update_gio_modules_cache,
// 39:           gdk_pixbuf_query_loaders:    :update_gdk_pixbuf_loaders_cache,
// 40:           gtk_update_icon_cache:       :update_gtk_icon_cache,
// 41:           delete_keychain_certificate: :delete_keychain_certificates,
// 42:         }.freeze,
// 43:         T::Hash[Symbol, Symbol],
// 44:       )
// 45:       COMPATIBILITY_STEP_METHODS = T.let(COMPATIBILITY_STEP_METHOD_REPLACEMENTS.keys.freeze, T::Array[Symbol])
// 46:       COMPATIBILITY_STEP_KEYWORD_REPLACEMENTS = T.let(
// 47:         {
// 48:           move:                         { force: :overwrite }.freeze,
// 49:           mv:                           { force: :overwrite }.freeze,
// 50:           symlink:                      { force: :overwrite, uninstall: :remove_on_uninstall }.freeze,
// 51:           ln_s:                         { force: :overwrite, uninstall: :remove_on_uninstall }.freeze,
// 52:           ln_sf:                        { uninstall: :remove_on_uninstall }.freeze,
// 53:           delete_keychain_certificate:  { matching_certificate: :fingerprint_of }.freeze,
// 54:           delete_keychain_certificates: { matching_certificate: :fingerprint_of }.freeze,
// 55:         }.freeze,
// 56:         T::Hash[Symbol, T::Hash[Symbol, Symbol]],
// 57:       )
// 58:       ALLOWED_STEP_METHODS = T.let(
// 59:         [*FILE_PREPARATION_STEP_METHODS, *LINK_STEP_METHODS, *CONFIG_WRITE_STEP_METHODS, *SERVICE_DATA_STEP_METHODS,
// 60:          *REBUILD_ACTION_STEP_METHODS, :set_permissions, *COMMAND_STEP_METHODS, *NOTICE_STEP_METHODS,
// 61:          *MACHO_STEP_METHODS, *FORMULA_ACTION_STEP_METHODS, *STEP_SCOPE_METHODS].freeze,
// 62:         T::Array[Symbol],
// 63:       )
// 64:       CASK_ALLOWED_STEP_METHODS = T.let(
// 65:         [*FILE_PREPARATION_STEP_METHODS, *CONFIG_WRITE_STEP_METHODS, *KEYCHAIN_STEP_METHODS,
// 66:          *PERMISSION_STEP_METHODS, *COMMAND_STEP_METHODS, *MACHO_STEP_METHODS, *STEP_SCOPE_METHODS].freeze,
// 67:         T::Array[Symbol],
// 68:       )
// 69:
// 70:       # `dstr` covers heredocs such as `write` content; interpolation is limited
// 71:       # to known template values below.
// 72:       ALLOWED_STEP_ARGUMENT_NODE_TYPES = [:array, :dstr, :hash, :int, :nil, :pair, :regexp, :regopt, :str,
// 73:                                           :sym].freeze
// 74:
// 75:       STEP_BLOCK_MSG = T.let(
// 76:         "Steps blocks may only contain install step DSL calls. Prefer canonical calls: " \
// 77:         "#{(ALLOWED_STEP_METHODS - COMPATIBILITY_STEP_METHODS).map { |method| "`#{method}`" }.join(", ")}.".freeze,
// 78:         String,
// 79:       )
// 80:       BREW_RUBY_STEP_MSG = "Install steps must not use `brew ruby` because it enables developer mode."
// 81:       LEGACY_STEP_METHOD_MSG = "Use `%<replacement>s` instead of legacy install step `%<method>s`."
// 82:       LEGACY_STEP_KEYWORD_MSG = "Use `%<replacement>s:` instead of legacy install step keyword `%<keyword>s:`."
// 83:       SIMPLE_STEP_CONVERSION_MSG = "Use `%<steps_block>s` for simple file preparation."
// 84:       REBUILD_ACTION_STEP_LINES = T.let(
// 85:         T.let([
// 86:           [
// 87:             "system Formula[\"glib\"].opt_bin/\"glib-compile-schemas\", " \
// 88:             "HOMEBREW_PREFIX/\"share/glib-2.0/schemas\"",
// 89:             "compile_gsettings_schemas",
// 90:           ],
// 91:           [
// 92:             "system Formula[\"gdk-pixbuf\"].opt_bin/\"gdk-pixbuf-query-loaders\", " \
// 93:             "\"--update-cache\"",
// 94:             "update_gdk_pixbuf_loaders_cache",
// 95:           ],
// 96:           [
// 97:             "system Formula[\"gtk+3\"].opt_bin/\"gtk3-update-icon-cache\", " \
// 98:             "\"-q\", \"-t\", \"-f\", HOMEBREW_PREFIX/\"share/icons/hicolor\"",
// 99:             "update_gtk_icon_cache",
// 100:           ],
// 101:           [
// 102:             "system Formula[\"shared-mime-info\"].opt_bin/\"update-mime-database\", " \
// 103:             "HOMEBREW_PREFIX/\"share/mime\"",
// 104:             "update_mime_database",
// 105:           ],
// 106:           [
// 107:             "system Formula[\"desktop-file-utils\"].opt_bin/\"update-desktop-database\", " \
// 108:             "HOMEBREW_PREFIX/\"share/applications\"",
// 109:             "update_desktop_database",
// 110:           ],
// 111:         ], T::Array[[String, String]]).to_h.freeze,
// 112:         T::Hash[String, String],
// 113:       )
// 114:
// 115:       sig { params(file_path: String).returns(T::Boolean) }
// 116:       def official_homebrew_tap?(file_path)
// 117:         file_path.match?(OFFICIAL_HOMEBREW_TAP_PATH_REGEX)
// 118:       end
// 119:
// 120:       sig { params(allowed_methods: T::Array[Symbol]).returns(String) }
// 121:       def step_block_msg(allowed_methods)
// 122:         "Steps blocks may only contain install step DSL calls. Prefer canonical calls: " \
// 123:           "#{(allowed_methods - COMPATIBILITY_STEP_METHODS).map { |method| "`#{method}`" }.join(", ")}."
// 124:       end
// 125:
// 126:       sig {
// 127:         params(
// 128:           block_node:      RuboCop::AST::BlockNode,
// 129:           allowed_methods: T::Array[Symbol],
// 130:         ).void
// 131:       }
// 132:       def add_compatibility_step_offenses(block_node, allowed_methods: ALLOWED_STEP_METHODS)
// 133:         block_node.each_descendant(:send) do |node|
// 134:           send_node = T.cast(node, RuboCop::AST::SendNode)
// 135:           method = send_node.method_name
// 136:           next if send_node.receiver || !allowed_methods.include?(method)
// 137:
// 138:           if (replacement = COMPATIBILITY_STEP_METHOD_REPLACEMENTS[method])
// 139:             add_offense(send_node.loc.selector,
// 140:                         message: Kernel.format(LEGACY_STEP_METHOD_MSG, method:, replacement:)) do |corrector|
// 141:               corrector.replace(send_node.loc.selector, replacement.to_s)
// 142:               add_compatibility_step_method_corrections(corrector, send_node)
// 143:             end
// 144:           end
// 145:           add_compatibility_step_keyword_offenses(send_node)
// 146:         end
// 147:       end
// 148:
// 149:       class InstallStepPath < T::Struct
// 150:         const :path, String
// 151:         const :base, T.nilable(Symbol)
// 152:         const :source, T.nilable(String), default: nil
// 153:       end
// 154:
// 155:       sig {
// 156:         params(
// 157:           block_node:      T.nilable(RuboCop::AST::BlockNode),
// 158:           allowed_methods: T::Array[Symbol],
// 159:         ).returns(T.nilable(RuboCop::AST::Node))
// 160:       }
// 161:       def install_step_block_offense_node(block_node, allowed_methods: ALLOWED_STEP_METHODS)
// 162:         return if block_node.nil?
// 163:         return if (body = block_node.body).nil?
// 164:
// 165:         direct_nodes = body.begin_type? ? body.child_nodes : [body]
// 166:         direct_nodes.each do |node|
// 167:           offense_node = install_step_offense_node(node, allowed_methods)
// 168:           return offense_node if offense_node
// 169:         end
// 170:
// 171:         nil
// 172:       end
// 173:
// 174:       sig { params(block_node: T.nilable(RuboCop::AST::BlockNode)).returns(T.nilable(RuboCop::AST::Node)) }
// 175:       def brew_ruby_step_node(block_node)
// 176:         return if block_node.nil?
// 177:
// 178:         block_node.each_descendant(:send).each do |node|
// 179:           send_node = T.cast(node, RuboCop::AST::SendNode)
// 180:           next if send_node.receiver.present? || send_node.method_name != :run
// 181:
// 182:           command = send_node.first_argument
// 183:           next unless command&.str_type?
// 184:           next if command.str_content != "{{HOMEBREW_BREW_FILE}}"
// 185:
// 186:           options = send_node.arguments.last
// 187:           next unless options&.hash_type?
// 188:
// 189:           args = T.cast(options, RuboCop::AST::HashNode).pairs.find do |pair|
// 190:             pair.key.sym_type? && pair.key.value == :args
// 191:           end&.value
// 192:           next unless args&.array_type?
// 193:
// 194:           first_arg = args.child_nodes.first
// 195:           return command if first_arg&.str_type? && first_arg.str_content == "ruby"
// 196:         end
// 197:
// 198:         nil
// 199:       end
// 200:
// 201:       sig {
// 202:         params(
// 203:           body_node:           T.nilable(RuboCop::AST::Node),
// 204:           default_base:        Symbol,
// 205:           default_source_base: Symbol,
// 206:           default_target_base: Symbol,
// 207:           rebuild_actions:     T::Boolean,
// 208:           permission_actions:  T::Boolean,
// 209:         ).returns(T.nilable(T::Array[String]))
// 210:       }
// 211:       def simple_install_step_lines(body_node, default_base:, default_source_base:, default_target_base:,
// 212:                                     rebuild_actions: true, permission_actions: false)
// 213:         return if body_node.nil?
// 214:
// 215:         direct_nodes = body_node.begin_type? ? body_node.child_nodes : [body_node]
// 216:         step_lines = direct_nodes.map do |node|
// 217:           simple_install_step_line(node, default_base:, default_source_base:, default_target_base:, rebuild_actions:,
// 218:                                    permission_actions:)
// 219:         end
// 220:         return if step_lines.any?(&:nil?)
// 221:
// 222:         T.cast(step_lines, T::Array[String])
// 223:       end
// 224:
// 225:       sig { params(block_name: Symbol, step_lines: T::Array[String], indent: Integer).returns(String) }
// 226:       def install_steps_block_source(block_name, step_lines, indent)
// 227:         block_indent = " " * indent
// 228:         [
// 229:           "#{block_name} do",
// 230:           *indented_install_step_lines(step_lines, indent + 2),
// 231:           "#{block_indent}end",
// 232:         ].join("\n")
// 233:       end
// 234:
// 235:       sig {
// 236:         params(
// 237:           corrector:  RuboCop::Cop::Corrector,
// 238:           block_node: RuboCop::AST::BlockNode,
// 239:           step_lines: T::Array[String],
// 240:         ).void
// 241:       }
// 242:       def append_install_step_lines(corrector, block_node, step_lines)
// 243:         block_indent = block_node.source_range.column
// 244:         step_source = indented_install_step_lines(step_lines, block_indent + 2).join("\n")
// 245:         corrector.insert_before(
// 246:           block_node.loc.end,
// 247:           "#{step_source.delete_prefix(" " * block_indent)}\n#{" " * block_indent}",
// 248:         )
// 249:       end
// 250:
// 251:       sig { params(body_node: T.nilable(RuboCop::AST::Node)).returns(T::Array[RuboCop::AST::Node]) }
// 252:       def direct_install_step_nodes(body_node)
// 253:         return [] if body_node.nil?
// 254:
// 255:         body_node.begin_type? ? body_node.child_nodes : [body_node]
// 256:       end
// 257:
// 258:       sig { params(node: RuboCop::AST::Node).returns(String) }
// 259:       def normalised_install_step_source(node)
// 260:         node.source.lines.reject { |line| line.lstrip.start_with?("#") }.join.gsub(/\s+/, " ").strip
// 261:       end
// 262:
// 263:       private
// 264:
// 265:       sig { params(send_node: RuboCop::AST::SendNode).void }
// 266:       def add_compatibility_step_keyword_offenses(send_node)
// 267:         replacements = COMPATIBILITY_STEP_KEYWORD_REPLACEMENTS[send_node.method_name]
// 268:         return if replacements.nil?
// 269:
// 270:         options = send_node.last_argument
// 271:         return unless options&.hash_type?
// 272:
// 273:         options = T.cast(options, RuboCop::AST::HashNode)
// 274:         options.pairs.each do |pair|
// 275:           next unless pair.key.sym_type?
// 276:           next unless (replacement = replacements[pair.key.value])
// 277:
// 278:           message = Kernel.format(LEGACY_STEP_KEYWORD_MSG, keyword: pair.key.value, replacement:)
// 279:           add_offense(pair.key.source_range, message:) do |corrector|
// 280:             correct_compatibility_step_keyword(corrector, send_node, options, pair, replacement)
// 281:           end
// 282:         end
// 283:       end
// 284:
// 285:       sig {
// 286:         params(
// 287:           corrector:   RuboCop::Cop::Corrector,
// 288:           send_node:   RuboCop::AST::SendNode,
// 289:           options:     RuboCop::AST::HashNode,
// 290:           legacy_pair: RuboCop::AST::PairNode,
// 291:           replacement: Symbol,
// 292:         ).void
// 293:       }
// 294:       def correct_compatibility_step_keyword(corrector, send_node, options, legacy_pair, replacement)
// 295:         if replacement == :fingerprint_of
// 296:           corrector.replace(legacy_pair.key.source_range, replacement.to_s)
// 297:           return
// 298:         end
// 299:         return if !legacy_pair.value.true_type? && !legacy_pair.value.false_type?
// 300:
// 301:         canonical_pair = options.pairs.find do |pair|
// 302:           pair != legacy_pair && pair.key.sym_type? && pair.key.value == replacement
// 303:         end
// 304:         if legacy_pair.value.true_type? && canonical_pair.nil?
// 305:           corrector.replace(legacy_pair.key.source_range, replacement.to_s)
// 306:           return
// 307:         end
// 308:
// 309:         if legacy_pair.value.true_type? && canonical_pair && !canonical_pair.value.true_type?
// 310:           corrector.replace(canonical_pair.value.source_range, "true")
// 311:         end
// 312:         pairs = options.pairs
// 313:         index = pairs.index(legacy_pair)
// 314:         return if index.nil?
// 315:
// 316:         range = if (next_pair = pairs[index + 1])
// 317:           legacy_pair.source_range.begin.join(next_pair.source_range.begin)
// 318:         elsif (previous_pair = pairs[index - 1]) && index.positive?
// 319:           previous_pair.source_range.end.join(legacy_pair.source_range.end)
// 320:         else
// 321:           send_node.arguments.fetch(-2).source_range.end.join(legacy_pair.source_range.end)
// 322:         end
// 323:         corrector.remove(range)
// 324:       end
// 325:
// 326:       sig {
// 327:         params(
// 328:           corrector: RuboCop::Cop::Corrector,
// 329:           send_node: RuboCop::AST::SendNode,
// 330:         ).void
// 331:       }
// 332:       def add_compatibility_step_method_corrections(corrector, send_node)
// 333:         case send_node.method_name
// 334:         when :ln_sf
// 335:           add_step_keyword(corrector, send_node, "overwrite: true")
// 336:         when :write
// 337:           options = send_node.last_argument
// 338:           overwrite = options&.hash_type? && T.cast(options, RuboCop::AST::HashNode).pairs.any? do |pair|
// 339:             pair.key.sym_type? && pair.key.value == :overwrite
// 340:           end
// 341:           keyword = "append_newline: true"
// 342:           keyword = "overwrite: false, #{keyword}" unless overwrite
// 343:           add_step_keyword(corrector, send_node, keyword)
// 344:         end
// 345:       end
// 346:
// 347:       sig {
// 348:         params(
// 349:           corrector: RuboCop::Cop::Corrector,
// 350:           send_node: RuboCop::AST::SendNode,
// 351:           keyword:   String,
// 352:         ).void
// 353:       }
// 354:       def add_step_keyword(corrector, send_node, keyword)
// 355:         options = send_node.last_argument
// 356:         if options&.hash_type?
// 357:           options = T.cast(options, RuboCop::AST::HashNode)
// 358:           if (pair = options.pairs.last)
// 359:             corrector.insert_after(pair.source_range, ", #{keyword}")
// 360:           else
// 361:             corrector.replace(options, keyword)
// 362:           end
// 363:         elsif (argument = send_node.last_argument)
// 364:           range = if argument.loc.respond_to?(:heredoc_end) && argument.loc.heredoc_end
// 365:             argument.loc.expression
// 366:           else
// 367:             argument.source_range
// 368:           end
// 369:           corrector.insert_after(range, ", #{keyword}")
// 370:         end
// 371:       end
// 372:
// 373:       sig {
// 374:         params(
// 375:           node:            RuboCop::AST::Node,
// 376:           allowed_methods: T::Array[Symbol],
// 377:         ).returns(T.nilable(RuboCop::AST::Node))
// 378:       }
// 379:       def install_step_offense_node(node, allowed_methods)
// 380:         if node.block_type?
// 381:           block_node = T.cast(node, RuboCop::AST::BlockNode)
// 382:           send_node = block_node.send_node
// 383:           return node if send_node.receiver.present? || !STEP_SCOPE_METHODS.include?(send_node.method_name)
// 384:           return node unless allowed_methods.include?(send_node.method_name)
// 385:
// 386:           invalid_argument = invalid_step_argument_node(send_node)
// 387:           return invalid_argument if invalid_argument
// 388:
// 389:           direct_install_step_nodes(block_node.body).each do |child|
// 390:             offense_node = install_step_offense_node(child, allowed_methods)
// 391:             return offense_node if offense_node
// 392:           end
// 393:           return
// 394:         end
// 395:         return node unless node.send_type?
// 396:
// 397:         send_node = T.cast(node, RuboCop::AST::SendNode)
// 398:         return node if send_node.receiver.present? || !allowed_methods.include?(send_node.method_name)
// 399:         return node if STEP_SCOPE_METHODS.include?(send_node.method_name)
// 400:
// 401:         invalid_step_argument_node(send_node)
// 402:       end
// 403:
// 404:       sig { params(send_node: RuboCop::AST::SendNode).returns(T.nilable(RuboCop::AST::Node)) }
// 405:       def invalid_step_argument_node(send_node)
// 406:         invalid_argument_node = send_node.each_descendant.find do |descendant|
// 407:           !allowed_step_argument_node?(descendant)
// 408:         end
// 409:         T.cast(invalid_argument_node, T.nilable(RuboCop::AST::Node))
// 410:       end
// 411:
// 412:       sig { params(step_lines: T::Array[String], indent: Integer).returns(T::Array[String]) }
// 413:       def indented_install_step_lines(step_lines, indent)
// 414:         step_lines.flat_map do |step_line|
// 415:           if step_line.include?("<<~")
// 416:             ["#{" " * indent}#{step_line}"]
// 417:           else
// 418:             step_line.lines(chomp: true).map { |line| "#{" " * indent}#{line}" }
// 419:           end
// 420:         end
// 421:       end
// 422:
// 423:       sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 424:       def allowed_step_argument_node?(node)
// 425:         return true if node.false_type? || node.true_type?
// 426:         return true if ALLOWED_STEP_ARGUMENT_NODE_TYPES.include?(node.type)
// 427:
// 428:         allowed_step_template_node?(node)
// 429:       end
// 430:
// 431:       sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 432:       def allowed_step_template_node?(node)
// 433:         if node.begin_type?
// 434:           return false if node.child_nodes.length != 1
// 435:
// 436:           return allowed_step_template_node?(node.child_nodes.first)
// 437:         end
// 438:         return false unless node.send_type?
// 439:
// 440:         send_node = T.cast(node, RuboCop::AST::SendNode)
// 441:         return false if send_node.arguments.present?
// 442:         return [:formula_name, :name, :token, :version].include?(send_node.method_name) if send_node.receiver.nil?
// 443:
// 444:         return false unless (receiver = send_node.receiver)&.send_type?
// 445:
// 446:         receiver_node = T.cast(receiver, RuboCop::AST::SendNode)
// 447:         return false if receiver_node.receiver.present?
// 448:         return false if receiver_node.arguments.present?
// 449:         return false if receiver_node.method_name != :version
// 450:
// 451:         [:major, :major_minor].include?(send_node.method_name)
// 452:       end
// 453:
// 454:       sig {
// 455:         params(
// 456:           node:                RuboCop::AST::Node,
// 457:           default_base:        Symbol,
// 458:           default_source_base: Symbol,
// 459:           default_target_base: Symbol,
// 460:           rebuild_actions:     T::Boolean,
// 461:           permission_actions:  T::Boolean,
// 462:         ).returns(T.nilable(String))
// 463:       }
// 464:       def simple_install_step_line(node, default_base:, default_source_base:, default_target_base:, rebuild_actions:,
// 465:                                    permission_actions:)
// 466:         return unless node.send_type?
// 467:
// 468:         send_node = T.cast(node, RuboCop::AST::SendNode)
// 469:         if rebuild_actions && send_node.receiver.nil? && send_node.method_name == :system
// 470:           return REBUILD_ACTION_STEP_LINES[send_node.source.gsub(/\s+/, " ")]
// 471:         end
// 472:
// 473:         if send_node.method_name == :mkpath && send_node.arguments.empty? && send_node.receiver
// 474:           path = install_step_path(send_node.receiver)
// 475:           return mkdir_step_line(path, default_base)
// 476:         end
// 477:
// 478:         if [:write, :atomic_write].include?(send_node.method_name)
// 479:           if send_node.receiver&.const_type? && send_node.receiver&.const_name == "File"
// 480:             return if send_node.method_name != :write || send_node.arguments.length != 2
// 481:
// 482:             return write_step_line(
// 483:               install_step_path(send_node.arguments.fetch(0)),
// 484:               send_node.arguments.fetch(1),
// 485:               default_base,
// 486:             )
// 487:           end
// 488:
// 489:           return if send_node.receiver.nil? || send_node.arguments.length != 1
// 490:
// 491:           return write_step_line(install_step_path(send_node.receiver), send_node.arguments.fetch(0), default_base)
// 492:         end
// 493:
// 494:         if permission_actions && send_node.receiver.nil?
// 495:           case send_node.method_name
// 496:           when :set_permissions
// 497:             return set_permissions_step_line(send_node, default_base)
// 498:           when :set_ownership
// 499:             return set_ownership_step_line(send_node, default_base)
// 500:           end
// 501:         end
// 502:
// 503:         return unless fileutils_or_no_receiver?(send_node)
// 504:
// 505:         case send_node.method_name
// 506:         when :mkdir, :mkdir_p
// 507:           return if send_node.arguments.length != 1
// 508:
// 509:           mkdir_step_line(install_step_path(send_node.arguments.first), default_base)
// 510:         when :touch
// 511:           return if send_node.arguments.length != 1
// 512:
// 513:           touch_step_line(install_step_path(send_node.arguments.first), default_base)
// 514:         when :mv
// 515:           return if send_node.arguments.length != 2
// 516:
// 517:           move_step_line(install_step_path(send_node.arguments.fetch(0)),
// 518:                          install_step_path(send_node.arguments.fetch(1)),
// 519:                          default_source_base, default_target_base)
// 520:         when :ln_s, :ln_sf
// 521:           return if send_node.arguments.length != 2
// 522:
// 523:           symlink_step_line(send_node.method_name == :ln_sf,
// 524:                             install_step_path(send_node.arguments.fetch(0)),
// 525:                             install_step_path(send_node.arguments.fetch(1)),
// 526:                             default_source_base, default_target_base)
// 527:         end
// 528:       end
// 529:
// 530:       sig {
// 531:         params(
// 532:           path:         T.nilable(InstallStepPath),
// 533:           default_base: Symbol,
// 534:         ).returns(T.nilable(String))
// 535:       }
// 536:       def mkdir_step_line(path, default_base)
// 537:         return if path.nil? || relative_install_step_path?(path)
// 538:
// 539:         "mkdir_p #{install_step_path_source(path)}" \
// 540:           "#{install_step_path_keywords(path, base: default_base, keyword: :base)}"
// 541:       end
// 542:
// 543:       sig {
// 544:         params(
// 545:           path:         T.nilable(InstallStepPath),
// 546:           default_base: Symbol,
// 547:         ).returns(T.nilable(String))
// 548:       }
// 549:       def touch_step_line(path, default_base)
// 550:         return if path.nil? || relative_install_step_path?(path)
// 551:
// 552:         "touch #{install_step_path_source(path)}#{install_step_path_keywords(path, base:    default_base,
// 553:                                                                                    keyword: :base)}"
// 554:       end
// 555:
// 556:       sig {
// 557:         params(
// 558:           source:              T.nilable(InstallStepPath),
// 559:           target:              T.nilable(InstallStepPath),
// 560:           default_source_base: Symbol,
// 561:           default_target_base: Symbol,
// 562:         ).returns(T.nilable(String))
// 563:       }
// 564:       def move_step_line(source, target, default_source_base, default_target_base)
// 565:         return if source.nil? || target.nil?
// 566:         return if relative_install_step_path?(source) || relative_install_step_path?(target)
// 567:
// 568:         kwargs = [
// 569:           install_step_path_keyword(source, base: default_source_base, keyword: :source_base),
// 570:           install_step_path_keyword(target, base: default_target_base, keyword: :target_base),
// 571:         ].compact
// 572:         "move #{install_step_path_source(source)}, #{install_step_path_source(target)}#{install_step_kwargs(kwargs)}"
// 573:       end
// 574:
// 575:       sig {
// 576:         params(
// 577:           overwrite:           T::Boolean,
// 578:           source:              T.nilable(InstallStepPath),
// 579:           target:              T.nilable(InstallStepPath),
// 580:           default_source_base: Symbol,
// 581:           default_target_base: Symbol,
// 582:         ).returns(T.nilable(String))
// 583:       }
// 584:       def symlink_step_line(overwrite, source, target, default_source_base, default_target_base)
// 585:         return if source.nil? || target.nil?
// 586:         return if relative_install_step_path?(target)
// 587:
// 588:         source_keyword = if relative_install_step_path?(source)
// 589:           "source_base: :relative"
// 590:         else
// 591:           install_step_path_keyword(source, base: default_source_base, keyword: :source_base)
// 592:         end
// 593:         kwargs = [
// 594:           source_keyword,
// 595:           install_step_path_keyword(target, base: default_target_base, keyword: :target_base),
// 596:           ("overwrite: true" if overwrite),
// 597:         ].compact
// 598:         "symlink #{install_step_path_source(source)}, #{install_step_path_source(target)}" \
// 599:           "#{install_step_kwargs(kwargs)}"
// 600:       end
// 601:
// 602:       sig {
// 603:         params(
// 604:           path:         T.nilable(InstallStepPath),
// 605:           content_node: RuboCop::AST::Node,
// 606:           default_base: Symbol,
// 607:         ).returns(T.nilable(String))
// 608:       }
// 609:       def write_step_line(path, content_node, default_base)
// 610:         return if path.nil? || relative_install_step_path?(path)
// 611:
// 612:         kwargs = [
// 613:           install_step_path_keyword(path, base: default_base, keyword: :base),
// 614:         ].compact
// 615:         return unless (content_source = write_content_source(content_node, kwargs))
// 616:
// 617:         "write_file #{install_step_path_source(path)}, #{content_source}"
// 618:       end
// 619:
// 620:       sig { params(content_node: RuboCop::AST::Node, kwargs: T::Array[String]).returns(T.nilable(String)) }
// 621:       def write_content_source(content_node, kwargs)
// 622:         return unless content_node.str_type?
// 623:         unless content_node.loc.respond_to?(:heredoc_end)
// 624:           return "#{content_node.source}#{install_step_kwargs(kwargs)}"
// 625:         end
// 626:
// 627:         heredoc_end = content_node.loc.heredoc_end
// 628:         return "#{content_node.source}#{install_step_kwargs(kwargs)}" if heredoc_end.nil?
// 629:
// 630:         "#{content_node.loc.expression.source}#{install_step_kwargs(kwargs)}" \
// 631:           "#{::Parser::Source::Range.new(content_node.loc.expression.source_buffer,
// 632:                                          content_node.loc.expression.end_pos, heredoc_end.end_pos).source}"
// 633:       end
// 634:
// 635:       sig {
// 636:         params(
// 637:           send_node:    RuboCop::AST::SendNode,
// 638:           default_base: Symbol,
// 639:         ).returns(T.nilable(String))
// 640:       }
// 641:       def set_permissions_step_line(send_node, default_base)
// 642:         return if send_node.arguments.length != 2
// 643:
// 644:         permissions_node = send_node.arguments.fetch(1)
// 645:         return unless permissions_node.str_type?
// 646:         return unless (paths = permission_paths_source(send_node.arguments.fetch(0), default_base))
// 647:
// 648:         path_source, base = paths
// 649:         "set_permissions #{path_source}, #{permissions_node.source}" \
// 650:           "#{install_step_path_keywords_for_base(base, default_base)}"
// 651:       end
// 652:
// 653:       sig {
// 654:         params(
// 655:           send_node:    RuboCop::AST::SendNode,
// 656:           default_base: Symbol,
// 657:         ).returns(T.nilable(String))
// 658:       }
// 659:       def set_ownership_step_line(send_node, default_base)
// 660:         return unless [1, 2].include?(send_node.arguments.length)
// 661:         return unless (paths = permission_paths_source(send_node.arguments.fetch(0), default_base))
// 662:
// 663:         kwargs = T.let([], T::Array[String])
// 664:         if send_node.arguments.length == 2
// 665:           options = send_node.arguments.fetch(1)
// 666:           return unless options.hash_type?
// 667:
// 668:           pairs = T.cast(options, RuboCop::AST::HashNode).pairs
// 669:           return if pairs.empty?
// 670:           return unless pairs.all? do |pair|
// 671:             pair.key.sym_type? && [:user, :group].include?(pair.key.value) && pair.value.str_type?
// 672:           end
// 673:           return if pairs.map { |pair| pair.key.value }.uniq.length != pairs.length
// 674:
// 675:           kwargs.concat(pairs.map(&:source))
// 676:         end
// 677:
// 678:         path_source, base = paths
// 679:         kwargs << "base: :#{base}" if base && base != default_base
// 680:         "set_ownership #{path_source}#{install_step_kwargs(kwargs)}"
// 681:       end
// 682:
// 683:       sig {
// 684:         params(
// 685:           node:         RuboCop::AST::Node,
// 686:           default_base: Symbol,
// 687:         ).returns(T.nilable([String, T.nilable(Symbol)]))
// 688:       }
// 689:       def permission_paths_source(node, default_base)
// 690:         path_nodes = node.array_type? ? node.child_nodes : [node]
// 691:         return if path_nodes.empty?
// 692:
// 693:         paths = path_nodes.filter_map { |path_node| cask_permission_path(path_node) }
// 694:         return if paths.length != path_nodes.length
// 695:
// 696:         absolute_paths, relative_paths = paths.partition { |path| absolute_install_step_path?(path) }
// 697:         return if absolute_paths.present? && relative_paths.present?
// 698:
// 699:         base = if relative_paths.present?
// 700:           bases = relative_paths.map { |path| path.base || default_base }.uniq
// 701:           return if bases.length != 1
// 702:
// 703:           bases.fetch(0)
// 704:         end
// 705:         source = if node.array_type?
// 706:           "[#{paths.map { |path| install_step_path_source(path) }.join(", ")}]"
// 707:         else
// 708:           install_step_path_source(paths.fetch(0))
// 709:         end
// 710:         [source, base]
// 711:       end
// 712:
// 713:       sig { params(node: RuboCop::AST::Node).returns(T.nilable(InstallStepPath)) }
// 714:       def cask_permission_path(node)
// 715:         path = install_step_path(node)
// 716:         return path if path
// 717:         if normalised_install_step_source(node) == "staged_path.to_s"
// 718:           return InstallStepPath.new(path: ".", base: :staged_path)
// 719:         end
// 720:         return unless node.dstr_type?
// 721:
// 722:         dstr_permission_path(T.cast(node, RuboCop::AST::DstrNode))
// 723:       end
// 724:
// 725:       sig { params(node: RuboCop::AST::DstrNode).returns(T.nilable(InstallStepPath)) }
// 726:       def dstr_permission_path(node)
// 727:         children = node.child_nodes
// 728:         return if children.empty?
// 729:
// 730:         base = interpolated_path_base(children.first)
// 731:         children = children.drop(1) if base
// 732:         return if children.empty? || !children.first.str_type?
// 733:
// 734:         first_content = T.cast(children.first, RuboCop::AST::StrNode).str_content
// 735:         if base
// 736:           return unless first_content.start_with?("/")
// 737:
// 738:           first_content = first_content.delete_prefix("/")
// 739:         elsif !first_content.start_with?("/", "~/")
// 740:           return
// 741:         end
// 742:
// 743:         path = +first_content
// 744:         source = +first_content.dump.delete_prefix('"').delete_suffix('"')
// 745:         valid_children = children.drop(1).all? do |child|
// 746:           if child.str_type?
// 747:             content = T.cast(child, RuboCop::AST::StrNode).str_content
// 748:             path << content
// 749:             source << content.dump.delete_prefix('"').delete_suffix('"')
// 750:             true
// 751:           elsif child.begin_type? && allowed_step_template_node?(child)
// 752:             interpolation = "\#{#{child.source}}"
// 753:             path << interpolation
// 754:             source << interpolation
// 755:             true
// 756:           else
// 757:             false
// 758:           end
// 759:         end
// 760:         return unless valid_children
// 761:
// 762:         InstallStepPath.new(path:, base:, source: "\"#{source}\"")
// 763:       end
// 764:
// 765:       sig { params(node: RuboCop::AST::Node).returns(T.nilable(Symbol)) }
// 766:       def interpolated_path_base(node)
// 767:         return unless node.begin_type?
// 768:         return if node.child_nodes.length != 1
// 769:
// 770:         value = node.child_nodes.first
// 771:         return :homebrew_prefix if value.const_type? && value.const_name == "HOMEBREW_PREFIX"
// 772:         return unless value.send_type?
// 773:
// 774:         send_node = T.cast(value, RuboCop::AST::SendNode)
// 775:         return if send_node.receiver || send_node.arguments.present?
// 776:
// 777:         send_node.method_name if [:appdir, :staged_path].include?(send_node.method_name)
// 778:       end
// 779:
// 780:       sig { params(base: T.nilable(Symbol), default_base: Symbol).returns(String) }
// 781:       def install_step_path_keywords_for_base(base, default_base)
// 782:         (base && base != default_base) ? ", base: :#{base}" : ""
// 783:       end
// 784:
// 785:       sig { params(send_node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 786:       def fileutils_or_no_receiver?(send_node)
// 787:         receiver = send_node.receiver
// 788:         receiver.nil? || (receiver.const_type? && receiver.const_name == "FileUtils")
// 789:       end
// 790:
// 791:       sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(InstallStepPath)) }
// 792:       def install_step_path(node)
// 793:         return if node.nil?
// 794:         return install_step_path(node.child_nodes.first) if node.begin_type? && node.child_nodes.length == 1
// 795:
// 796:         return InstallStepPath.new(path: T.cast(node, RuboCop::AST::StrNode).str_content, base: nil) if node.str_type?
// 797:         return unless node.send_type?
// 798:
// 799:         send_node = T.cast(node, RuboCop::AST::SendNode)
// 800:         return if send_node.method_name != :/ || send_node.arguments.length != 1
// 801:
// 802:         path_node = send_node.arguments.first
// 803:         return unless path_node&.str_type?
// 804:         return unless (base = install_step_path_base(send_node.receiver))
// 805:
// 806:         InstallStepPath.new(path: T.cast(path_node, RuboCop::AST::StrNode).str_content, base:)
// 807:       end
// 808:
// 809:       sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(Symbol)) }
// 810:       def install_step_path_base(node)
// 811:         return if node.nil?
// 812:         return :homebrew_prefix if node.const_type? && node.const_name == "HOMEBREW_PREFIX"
// 813:         return unless node.send_type?
// 814:
// 815:         send_node = T.cast(node, RuboCop::AST::SendNode)
// 816:         return if send_node.receiver
// 817:
// 818:         base = send_node.method_name
// 819:         base if [:appdir, :etc, :home, :opt_prefix, :pkgetc, :prefix, :staged_path, :var].include?(base)
// 820:       end
// 821:
// 822:       sig { params(path: InstallStepPath).returns(T::Boolean) }
// 823:       def relative_install_step_path?(path)
// 824:         path.base.nil? && !absolute_install_step_path?(path)
// 825:       end
// 826:
// 827:       sig { params(path: InstallStepPath).returns(T::Boolean) }
// 828:       def absolute_install_step_path?(path)
// 829:         path.path.start_with?("/", "~/")
// 830:       end
// 831:
// 832:       sig { params(path: InstallStepPath).returns(String) }
// 833:       def install_step_path_source(path)
// 834:         path.source || path.path.inspect
// 835:       end
// 836:
// 837:       sig { params(path: InstallStepPath, base: Symbol, keyword: Symbol).returns(String) }
// 838:       def install_step_path_keywords(path, base:, keyword:)
// 839:         keyword_source = install_step_path_keyword(path, base:, keyword:)
// 840:         keyword_source ? ", #{keyword_source}" : ""
// 841:       end
// 842:
// 843:       sig { params(path: InstallStepPath, base: Symbol, keyword: Symbol).returns(T.nilable(String)) }
// 844:       def install_step_path_keyword(path, base:, keyword:)
// 845:         return if path.base.nil? || path.base == base
// 846:
// 847:         "#{keyword}: :#{path.base}"
// 848:       end
// 849:
// 850:       sig { params(kwargs: T::Array[String]).returns(String) }
// 851:       def install_step_kwargs(kwargs)
// 852:         kwargs.empty? ? "" : ", #{kwargs.join(", ")}"
// 853:       end
// 854:     end
// 855:   end
// 856: end
