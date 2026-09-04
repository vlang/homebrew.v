module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/install_steps_helper.rb`.
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
