module rubocops

import ruby
import homebrew.rubocops.@shared as conditionals
import homebrew.utils

// Translated from Homebrew/brew `rubocops/lines.rb`.
pub struct LinesContext {
pub:
	source                string
	tap                   string
	formula_name          string
	make_check_exception  bool
	runtime_cpu_exception bool
}

pub struct LinesOffense {
pub:
	begin_pos   int
	end_pos     int
	message     string
	replacement string
	remove      bool
}

pub struct LinesAnalysis {
pub:
	offenses  []LinesOffense
	corrected string
}

struct LinesLine {
	start       int
	end         int
	newline_end int
	text        string
}

struct LinesCall {
	target    string
	source    string
	arguments []string
	begin_pos int
	end_pos   int
	line      int
}

fn lines_source_lines(source string) []LinesLine {
	mut result := []LinesLine{}
	mut start := 0
	for start <= source.len {
		newline := source.index_after('\n', start) or { source.len }
		end := if newline < source.len { newline } else { source.len }
		result << LinesLine{
			start: start
			end: end
			newline_end: if newline < source.len { newline + 1 } else { newline }
			text: source[start..end]
		}
		if newline >= source.len {
			break
		}
		start = newline + 1
	}
	return result
}

fn lines_code(text string) string {
	mut quote := u8(0)
	mut escaped := false
	for index, character in text.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			return text[..index]
		}
	}
	return text
}

fn lines_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn lines_target_index(code string, target string) int {
	mut from := 0
	for from <= code.len - target.len {
		index := code.index_after(target, from) or { return -1 }
		before_ok := index == 0 || !lines_identifier_byte(code[index - 1])
		after := index + target.len
		after_ok := after >= code.len || !lines_identifier_byte(code[after])
		if before_ok && after_ok {
			return index
		}
		from = index + target.len
	}
	return -1
}

fn lines_split_arguments(raw string) []string {
	mut source := raw.trim_space()
	if source.starts_with('(') && source.ends_with(')') {
		source = source[1..source.len - 1]
	}
	mut result := []string{}
	mut start := 0
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	for index, character in source.bytes() {
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
			continue
		}
		match character {
			`(` { round++ }
			`)` { round-- }
			`[` { square++ }
			`]` { square-- }
			`{` { brace++ }
			`}` { brace-- }
			`,` {
				if round == 0 && square == 0 && brace == 0 {
					argument := source[start..index].trim_space()
					if argument != '' {
						result << argument
					}
					start = index + 1
				}
			}
			else {}
		}
	}
	argument := source[start..].trim_space()
	if argument != '' {
		result << argument
	}
	return result
}

fn lines_find_calls(source string, target string) []LinesCall {
	mut calls := []LinesCall{}
	for line_number, line in lines_source_lines(source) {
		code := lines_code(line.text).trim_right(' \t')
		index := lines_target_index(code, target)
		if index < 0 {
			continue
		}
		mut end := code.len
		if code[index..].contains(' do') {
			end = index + (code[index..].index(' do') or { code.len - index })
		}
		call_source := code[index..end].trim_space()
		mut raw_arguments := call_source[target.len..].trim_space()
		if raw_arguments.starts_with('(') && raw_arguments.ends_with(')') {
			raw_arguments = raw_arguments[1..raw_arguments.len - 1]
		}
		calls << LinesCall{
			target: target
			source: call_source
			arguments: lines_split_arguments(raw_arguments)
			begin_pos: line.start + index
			end_pos: line.start + end
			line: line_number
		}
	}
	return calls
}

fn lines_find_qualified_method_calls(source string, target string) []LinesCall {
	mut calls := []LinesCall{}
	for line_number, line in lines_source_lines(source) {
		code := lines_code(line.text).trim_right(' \t')
		index := lines_target_index(code, target)
		if index < 0 {
			continue
		}
		mut begin := index
		for begin > 0 && (lines_identifier_byte(code[begin - 1]) || code[begin - 1] in [
			`.`,
			`:`,
		]) {
			begin--
		}
		mut end := index + target.len
		mut arguments := []string{}
		if end < code.len && code[end] == `(` {
			mut depth := 0
			mut quote := u8(0)
			mut escaped := false
			for cursor := end; cursor < code.len; cursor++ {
				character := code[cursor]
				if escaped {
					escaped = false
					continue
				}
				if character == `\\` {
					escaped = true
					continue
				}
				if quote != 0 {
					if character == quote {
						quote = 0
					}
					continue
				}
				if character in [`'`, `"`] {
					quote = character
					continue
				}
				if character == `(` {
					depth++
				} else if character == `)` {
					depth--
					if depth == 0 {
						end = cursor + 1
						break
					}
				}
			}
			arguments = lines_split_arguments(code[index + target.len + 1..end - 1])
		}
		calls << LinesCall{
			target: target
			source: code[begin..end]
			arguments: arguments
			begin_pos: line.start + begin
			end_pos: line.start + end
			line: line_number
		}
	}
	return calls
}

fn lines_unquote(value string) string {
	trimmed := value.trim_space()
	if trimmed.len >= 2 && ((trimmed[0] == `'` && trimmed[trimmed.len - 1] == `'`) || (trimmed[0] == `"` && trimmed[trimmed.len - 1] == `"`)) {
		return trimmed[1..trimmed.len - 1]
	}
	return trimmed
}

fn lines_symbol(value string) string {
	return value.trim_space().trim_left(':')
}

fn lines_offense(call LinesCall, message string, replacement string) LinesOffense {
	return LinesOffense{
		begin_pos: call.begin_pos
		end_pos: call.end_pos
		message: message
		replacement: replacement
	}
}

fn lines_apply_corrections(source string, offenses []LinesOffense) string {
	mut corrected := source
	mut sorted := offenses.filter(it.replacement != '' || it.remove).clone()
	sorted.sort(a.begin_pos > b.begin_pos)
	for offense in sorted {
		corrected = corrected[..offense.begin_pos] + offense.replacement + corrected[offense.end_pos..]
	}
	return corrected
}

fn lines_analysis(context LinesContext, offenses []LinesOffense) LinesAnalysis {
	return LinesAnalysis{
		offenses: offenses
		corrected: lines_apply_corrections(context.source, offenses)
	}
}

fn lines_dependency_calls(context LinesContext) []LinesCall {
	return lines_find_calls(context.source, 'depends_on')
}

fn lines_dependency_name(call LinesCall) string {
	if call.arguments.len == 0 {
		return ''
	}
	first := call.arguments[0]
	if first.contains('=>') {
		return lines_unquote(first.all_before('=>').trim_space()).trim_left(':')
	}
	return lines_unquote(first).trim_left(':')
}

pub fn audit_lines_deprecated_dependencies(context LinesContext) LinesAnalysis {
	direct := ['automake', 'ant', 'autoconf', 'emacs', 'expat', 'libtool', 'mysql', 'perl',
		'postgresql', 'python', 'python3', 'rbenv', 'ruby']
	replacements := {
		'apr':     'apr-util'
		'fortran': 'gcc'
		'gpg':     'gnupg'
		'hg':      'mercurial'
		'mpi':     'open-mpi'
		'python2': 'python'
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		if call.arguments.len == 0 || !call.arguments[0].trim_space().starts_with(':') {
			continue
		}
		dependency := lines_dependency_name(call)
		if dependency in direct {
			offenses << lines_offense(call, ':${dependency} is deprecated. Usage should be "${dependency}".', '')
		} else if dependency in replacements {
			offenses << lines_offense(call, ':${dependency} is deprecated. Usage should be "${replacements[dependency]}".', '')
		} else if dependency == 'tex' {
			offenses << lines_offense(call, ':tex is deprecated.', '')
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_class_inheritance(context LinesContext) LinesAnalysis {
	for line in lines_source_lines(context.source) {
		code := lines_code(line.text).trim_space()
		if !code.starts_with('class ') || !code.contains('<') {
			continue
		}
		left := code.all_before('<')
		right := code.all_after('<')
		if left.ends_with(' ') && right.starts_with(' ') {
			return lines_analysis(context, [])
		}
		formula_class := left.trim_space().all_after('class ')
		parent := right.trim_space().all_before(' ')
		parent_index := line.text.index(parent) or { line.text.len }
		return lines_analysis(context, [LinesOffense{
			begin_pos: line.start + parent_index
			end_pos: line.start + parent_index + parent.len
			message: 'Use a space in class inheritance: class ${formula_class} < ${parent}'
		}])
	}
	return lines_analysis(context, [])
}

pub fn audit_lines_comments(context LinesContext) LinesAnalysis {
	templates := ['# PLEASE REMOVE', '# Documentation:',
		'# if this fails, try separate make/make install steps', '# The URL of the archive',
		'## Naming --', '# if your formula fails when building in parallel',
		'# Remove unrecognized options if warned by configure', '# system "cmake']
	mut offenses := []LinesOffense{}
	for line in lines_source_lines(context.source) {
		comment_index := line.text.index('#') or { continue }
		comment := line.text[comment_index..]
		if templates.any(comment.contains(it)) {
			offenses << LinesOffense{ begin_pos: line.start + comment_index, end_pos: line.end, message: 'Please remove default template comments' }
		}
		dependency_index := comment.index('depends_on') or { -1 }
		if dependency_index >= 0 {
			dependency := comment[dependency_index + 'depends_on'.len..].trim_space()
			if dependency != '' {
				offenses << LinesOffense{ begin_pos: line.start + comment_index, end_pos: line.end, message: 'Commented-out dependency ${dependency}' }
			}
		}
		if context.tap == 'homebrew-core' {
			trimmed := comment.trim_left('# \t')
			mut kind := ''
			if trimmed.starts_with('cite ') && trimmed.contains(':') {
				kind = 'cite'
			}
			if trimmed.starts_with('doi ') && (trimmed.contains("'") || trimmed.contains('"')) {
				kind = 'doi'
			}
			if trimmed.starts_with('tag ') && (trimmed.contains("'") || trimmed.contains('"')) {
				kind = 'tag'
			}
			if kind != '' {
				offenses << LinesOffense{ begin_pos: line.start + comment_index, end_pos: line.end, message: 'Formulae in homebrew/core should not use `${kind}` comments' }
			}
		}
	}
	return lines_analysis(context, offenses)
}

fn lines_matching_end(lines []LinesLine, start int) int {
	indent := lines[start].text.len - lines[start].text.trim_left(' \t').len
	mut depth := 0
	for index := start + 1; index < lines.len; index++ {
		trimmed := lines[index].text.trim_space()
		line_indent := lines[index].text.len - lines[index].text.trim_left(' \t').len
		if line_indent == indent && trimmed == 'end' {
			if depth == 0 {
				return index
			}
			depth--
		} else if line_indent == indent && (trimmed.starts_with('def ') || trimmed.ends_with(' do') || trimmed.contains(' do |') || trimmed.starts_with('if ') || trimmed.starts_with('unless ')) {
			depth++
		}
	}
	return -1
}

fn lines_position_in_named_region(source string, position int, name string, definition bool) bool {
	lines := lines_source_lines(source)
	mut target := 0
	for index, line in lines {
		if position >= line.start && position <= line.end {
			target = index
			break
		}
	}
	for index, line in lines {
		if index > target {
			break
		}
		trimmed := line.text.trim_space()
		matches := if definition {
			trimmed.starts_with('def ${name}')
		} else {
			trimmed == '${name} do' || (trimmed.starts_with('${name}(') && trimmed.ends_with(' do'))
		}
		if matches {
			closing := lines_matching_end(lines, index)
			if closing >= target {
				return true
			}
		}
	}
	return false
}

pub fn audit_lines_assert_statements(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for call in lines_find_calls(context.source, 'assert') {
		if call.source.contains('.include?') && !call.source.contains('!') {
			offenses << lines_offense(call, 'Use `assert_match` instead of `assert ...include?`', '')
		}
		if call.source.contains('.exist?') {
			message := if call.source.contains('!') {
				'Use `refute_path_exists <path_to_file>` instead of `${call.source}`'
			} else {
				'Use `assert_path_exists <path_to_file>` instead of `${call.source}`'
			}
			offenses << lines_offense(call, message, '')
		}
		if call.source.contains('.executable?') && !call.source.contains('!') {
			offenses << lines_offense(call, 'Use `assert_predicate <path_to_file>, :executable?` instead of `${call.source}`', '')
		}
	}
	for target in ['assert_predicate', 'refute_predicate'] {
		for call in lines_find_calls(context.source, target) {
			if call.arguments.len < 2 || call.arguments[1] != ':exist?' {
				continue
			}
			preferred := if target == 'assert_predicate' {
				'assert_path_exists'
			} else {
				'refute_path_exists'
			}
			mut correction := '${preferred} ${call.arguments[0]}'
			if call.arguments.len == 3 {
				correction += ', ${call.arguments[2]}'
			}
			offenses << lines_offense(call, 'Use `${preferred} <path_to_file>` instead of `${call.source}`', correction)
		}
	}
	return lines_analysis(context, offenses)
}

pub fn lines_unless_modifier(source string) bool {
	trimmed := source.trim_space()
	return trimmed.contains(' unless ') && !trimmed.contains('\n')
}

pub fn lines_depends_on_build_with(source string) []string {
	mut result := []string{}
	for call in lines_find_calls(source, 'depends_on') {
		line := lines_source_lines(source)[call.line].text.trim_space()
		if line.contains(' if build.with?') || line.contains(' if build.without?') { result << line }
	}
	return result
}

pub fn audit_lines_option_declarations(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for line in lines_source_lines(context.source) {
		trimmed := line.text.trim_space()
		if trimmed.starts_with('def options') {
			offenses << LinesOffense{ begin_pos: line.start + (line.text.index('def') or { 0 }), end_pos: line.end, message: 'Use new-style option definitions' }
		}
	}
	if context.tap == 'homebrew-core' {
		for method in ['without?', 'with?'] {
			for call in lines_find_calls(context.source, 'build.${method}') {
				offenses << lines_offense(call, 'Formulae in homebrew/core should not use `build.${method}`.', '')
			}
		}
		return lines_analysis(context, offenses)
	}
	for statement in lines_depends_on_build_with(context.source) {
		position := context.source.index(statement) or { 0 }
		condition := statement.all_after(' if ').trim_space()
		offenses << LinesOffense{ begin_pos: position, end_pos: position + statement.len, message: 'Use `:optional` or `:recommended` instead of `if ${condition}`' }
	}
	for method in ['without?', 'with?'] {
		for call in lines_find_calls(context.source, 'build.${method}') {
			line := lines_source_lines(context.source)[call.line].text.trim_space()
			if line.contains(' unless ') {
				correct := if method == 'without?' {
					call.source.replace('out?', '?')
				} else {
					call.source.replace('?', 'out?')
				}
				offenses << lines_offense(call, 'Use `if ${correct}` instead of `unless ${call.source}`', '')
			}
			prefix := context.source[..call.begin_pos].trim_right(' \t')
			if prefix.ends_with('!') {
				other := if method == 'with?' { 'without?' } else { 'with?' }
				offenses << lines_offense(call, 'Instead of negating `build.${method}`, use `build.${other}`', '')
			}
			if call.arguments.len > 0 {
				arg := lines_unquote(call.arguments[0])
				prefix_to_strip := if method == 'without?' { 'without-' } else { 'with-' }
				stripped := arg.trim_left('-')
				if stripped.starts_with(prefix_to_strip) {
					dependency := stripped[prefix_to_strip.len..]
					message := if method == 'without?' {
						'Instead of duplicating `without`, use `build.without? "${dependency}"` to check for "--without-${dependency}"'
					} else {
						'Instead of duplicating `with`, use `build.with? "${dependency}"` to check for \'--with-${dependency}\''
					}
					offenses << lines_offense(call, message, '')
				}
			}
		}
	}
	for call in lines_find_calls(context.source, 'build.include?') {
		offenses << lines_offense(call, '`build.include?` is deprecated', '')
	}
	return lines_analysis(context, offenses)
}

fn audit_lines_dependency_replacement(context LinesContext, dependency string, replacement string,
	message string) LinesAnalysis {
	if context.tap != 'homebrew-core' {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		if lines_dependency_name(call) == dependency {
			offenses << lines_offense(call, message.replace('%source%', call.source), replacement)
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_mpi(context LinesContext) LinesAnalysis {
	return audit_lines_dependency_replacement(context, 'mpich', 'depends_on "open-mpi"', 'Formulae in homebrew/core should use `depends_on "open-mpi"` instead of `%source%`.')
}

pub fn audit_lines_std_npm_args(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for call in lines_find_qualified_method_calls(context.source, 'local_npm_install_args') {
		offenses << lines_offense(call, 'Use `std_npm_args` instead of `local_npm_install_args`.', 'std_npm_args(prefix: false)')
	}
	for call in lines_find_qualified_method_calls(context.source, 'std_npm_install_args') {
		param := if call.arguments.len > 0 { call.arguments[0] } else { 'libexec' }
		replacement := if param == 'libexec' {
			'std_npm_args'
		} else {
			'std_npm_args(prefix: ${param})'
		}
		offenses << lines_offense(call, 'Use `std_npm_args` instead of `std_npm_install_args`.', replacement)
	}
	for call in lines_find_calls(context.source, 'system') {
		if call.arguments.len >= 2 && lines_unquote(call.arguments[0]) == 'npm' && lines_unquote(call.arguments[1]) == 'install' && !call.source.contains('std_npm_args') && !call.source.contains('local_npm_install_args') && !call.source.contains('std_npm_install_args') {
			offenses << lines_offense(call, 'Use `std_npm_args` for npm install', '')
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_quictls(context LinesContext) LinesAnalysis {
	return audit_lines_dependency_replacement(context, 'quictls', 'depends_on "openssl@3"', 'Formulae in homebrew/core should use `depends_on "openssl@3"` instead of `%source%`.')
}

pub fn audit_lines_pyoxidizer(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		if lines_dependency_name(call) == 'pyoxidizer' {
			offenses << lines_offense(call, 'Formulae in homebrew/core should not use `${call.source}`.', '')
			break
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_libiconv(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' || context.formula_name == 'neomutt' {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		if lines_dependency_name(call) == 'libiconv' {
			offenses << lines_offense(call, 'Formulae in homebrew/core should not use `${call.source}`.', '')
			break
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_full_dependencies(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		dependency := lines_dependency_name(call)
		if dependency.ends_with('-full') {
			offenses << lines_offense(call, 'Formulae in homebrew/core should not depend on `${dependency}`.', '')
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_safe_popen(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for command in ['popen_read', 'popen_write'] {
		for call in lines_find_calls(context.source, 'Utils.${command}') {
			if lines_position_in_named_region(context.source, call.begin_pos, 'test', false) {
				continue
			}
			replacement := call.source.replace('Utils.${command}', 'Utils.safe_${command}')
			offenses << lines_offense(call, 'Use `Utils.safe_${command}` instead of `Utils.${command}`', replacement)
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_shell_variables(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for command in ['popen', 'popen_read', 'safe_popen_read', 'popen_write', 'safe_popen_write'] {
		for call in lines_find_calls(context.source, 'Utils.${command}') {
			if call.arguments.len == 0 {
				continue
			}
			value := lines_unquote(call.arguments[0])
			space := value.index(' ') or { value.len }
			assignment := value[..space]
			if !assignment.contains('=') || assignment.starts_with('"') || assignment.starts_with("'") {
				continue
			}
			key := assignment.all_before('=')
			assigned := assignment.all_after('=')
			if key == '' || assigned == '' || key.contains(' ') || assigned.contains(' ') {
				continue
			}
			command_string := if space < value.len { value[space + 1..] } else { '' }
			good := 'Utils.${command}({ "${key}" => "${assigned}" }, "${command_string}")'
			offenses << lines_offense(call, 'Use `${good}` instead of `${call.source}`', good)
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_license_arrays(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for call in lines_find_calls(context.source, 'license') {
		if call.arguments.len > 0 && call.arguments[0].trim_space().starts_with('[') {
			replacement := 'license any_of: ${call.arguments[0]}'
			offenses << lines_offense(call, 'Use `${replacement}` instead of `${call.source}`', replacement)
		}
	}
	return lines_analysis(context, offenses)
}

pub fn lines_license_exception(source string) bool {
	trimmed := source.trim_space()
	value := if trimmed.contains('=>') { trimmed.all_after('=>').trim_space() } else { trimmed }
	return value.starts_with('{') && value.ends_with('}') && value.contains('with:') && !value.contains(',')
}

fn lines_nested_license_hash(source string) bool {
	opening := source.index('[') or { return false }
	closing := source.last_index(']') or { return false }
	if closing <= opening {
		return false
	}
	contents := source[opening + 1..closing]
	return contents.contains('any_of:') || contents.contains('all_of:')
}

pub fn audit_lines_licenses(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for call in lines_find_calls(context.source, 'license') {
		if call.source.contains('\n') || call.arguments.len == 0 {
			continue
		}
		argument := call.arguments[0]
		if (argument.contains('{') && !lines_license_exception(argument)) || lines_nested_license_hash(argument) {
			offenses << lines_offense(call, 'Split nested license declarations onto multiple lines', '')
		}
	}
	return lines_analysis(context, offenses)
}

fn lines_java_dependency(context LinesContext) ?(string, string) {
	mut matches := []string{}
	for call in lines_dependency_calls(context) {
		dependency := lines_dependency_name(call)
		if dependency == 'openjdk' || dependency.starts_with('openjdk@') { matches << dependency }
	}
	if matches.len != 1 {
		return none
	}
	dependency := matches[0]
	mut version := if dependency.contains('@') { dependency.all_after('@') } else { '' }
	if version == '8' {
		version = '1.8'
	}
	return dependency, version
}

pub fn lines_java_home_calls(source string) []LinesCall {
	mut result := []LinesCall{}
	for method in ['java_home', 'java_home_env', 'overridable_java_home_env'] {
		result << lines_find_calls(source, 'Language::Java.${method}')
	}
	return result
}

pub fn lines_java_version_assignments(source string, variable string) []LinesCall {
	mut result := []LinesCall{}
	for line_number, line in lines_source_lines(source) {
		code := lines_code(line.text).trim_space()
		if !code.starts_with('${variable} =') {
			continue
		}
		index := line.text.index(variable) or { 0 }
		value := code.all_after('=').trim_space()
		value_index := code.index(value) or { 0 }
		result << LinesCall{ target: variable, source: value, arguments: [value], begin_pos: line.start + index + value_index, end_pos: line.start + index + value_index + value.len, line: line_number }
	}
	return result
}

pub fn audit_lines_java_versions(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' {
		return lines_analysis(context, [])
	}
	dependency, version := lines_java_dependency(context) or { return lines_analysis(context, []) }
	message := 'Java version argument should match the specified dependency (`${dependency}`)'
	mut offenses := []LinesOffense{}
	mut variables := []string{}
	for call in lines_java_home_calls(context.source) {
		method := call.target.all_after('Language::Java.')
		argument := if call.arguments.len > 0 { call.arguments[0] } else { '' }
		if argument != '' && !argument.starts_with('"') && !argument.starts_with("'") && argument != 'nil' {
			variables << argument
			continue
		}
		java_version := if argument == '' || argument == 'nil' {
			''
		} else {
			lines_unquote(argument)
		}
		if argument == 'nil' && version == '' {
			offenses << lines_offense(call, 'Argument is unnecessary when using unversioned OpenJDK', 'Language::Java.${method}')
			continue
		}
		if java_version == version {
			continue
		}
		mut correction := 'Language::Java.${method}'
		if version != '' {
			correction += '("${version}")'
		}
		offenses << lines_offense(call, message, correction)
	}
	for call in lines_find_calls(context.source, 'bin.write_jar_script') {
		mut java_index := -1
		for index, argument in call.arguments {
			if argument.trim_space().starts_with('java_version:') {
				java_index = index
				break
			}
		}
		if java_index < 0 {
			if version != '' {
				replacement := call.source.trim_right(')') + ', java_version: "${version}"' + if call.source.ends_with(')') {
					')'
				} else {
					''
				}
				offenses << lines_offense(call, message, replacement)
			}
			continue
		}
		pair := call.arguments[java_index]
		value := pair.all_after(':').trim_space()
		if value != '' && !value.starts_with('"') && !value.starts_with("'") && value != 'nil' {
			variables << value
			continue
		}
		java_version := if value == 'nil' { '' } else { lines_unquote(value) }
		if java_version == version {
			continue
		}
		if version == '' {
			pair_offset := call.source.index(pair) or { continue }
			mut begin_offset := pair_offset
			for begin_offset > 0 && call.source[begin_offset - 1] in [` `, `\t`] {
				begin_offset--
			}
			if begin_offset > 0 && call.source[begin_offset - 1] == `,` {
				begin_offset--
			}
			offenses << LinesOffense{
				begin_pos: call.begin_pos + begin_offset
				end_pos: call.begin_pos + pair_offset + pair.len
				message: message
				remove: true
			}
		} else {
			pair_offset := call.source.index(pair) or { continue }
			value_offset := pair.index(value) or { continue }
			offenses << LinesOffense{
				begin_pos: call.begin_pos + pair_offset + value_offset
				end_pos: call.begin_pos + pair_offset + value_offset + value.len
				message: message
				replacement: '"${version}"'
			}
		}
	}
	mut unique_variables := []string{}
	for variable in variables {
		if variable != '' && variable !in unique_variables { unique_variables << variable }
	}
	for variable in unique_variables {
		for assignment in lines_java_version_assignments(context.source, variable) {
			value := assignment.arguments[0]
			java_version := if value.starts_with('"') || value.starts_with("'") {
				lines_unquote(value)
			} else {
				''
			}
			if java_version == version {
				continue
			}
			replacement := if version == '' { 'nil' } else { '"${version}"' }
			offenses << lines_offense(assignment, message, replacement)
		}
	}
	return lines_analysis(context, offenses)
}

struct LinesStringLiteral {
	source    string
	content   string
	begin_pos int
	end_pos   int
}

fn lines_string_literals(source string) []LinesStringLiteral {
	mut result := []LinesStringLiteral{}
	mut index := 0
	for index < source.len {
		if source[index] !in [`'`, `"`] {
			index++
			continue
		}
		quote := source[index]
		start := index
		index++
		mut escaped := false
		for index < source.len {
			if escaped {
				escaped = false
			} else if source[index] == `\\` {
				escaped = true
			} else if source[index] == quote {
				break
			}
			index++
		}
		if index >= source.len {
			break
		}
		result << LinesStringLiteral{ source: source[start..index + 1], content: source[start + 1..index], begin_pos: start, end_pos: index + 1 }
		index++
	}
	return result
}

pub fn audit_lines_python_versions(context LinesContext) LinesAnalysis {
	mut direct := []string{}
	mut hashed := []string{}
	for call in lines_dependency_calls(context) {
		if call.arguments.len == 0 {
			continue
		}
		dependency := lines_dependency_name(call)
		if dependency.starts_with('python@') {
			if call.arguments[0].contains('=>') { hashed << dependency } else { direct << dependency }
		}
	}
	mut dependency := ''
	if direct.len > 0 {
		dependency = direct[0]
	} else if hashed.len == 1 {
		dependency = hashed[0]
	} else {
		return lines_analysis(context, [])
	}
	version := dependency.all_after('@')
	mut offenses := []LinesOffense{}
	for literal in lines_string_literals(context.source) {
		content := literal.content
		mut at := false
		mut candidate := ''
		if content.starts_with('python@') {
			at = true
			candidate = content['python@'.len..]
		} else if content.starts_with('python') {
			candidate = content['python'.len..]
		}
		parts := candidate.split('.')
		if parts.len != 2 || parts.any(it == '' || !it.bytes().all(it.is_digit())) || candidate == version {
			continue
		}
		fix := if at { 'python@${version}' } else { 'python${version}' }
		offenses << LinesOffense{ begin_pos: literal.begin_pos, end_pos: literal.end_pos, message: 'References to `${content}` should match the specified python dependency (`${fix}`)', replacement: '"${fix}"' }
	}
	return lines_analysis(context, offenses)
}

struct LinesRegion {
	source     string
	begin_pos  int
	name       string
	definition bool
}

fn lines_named_regions(source string, methods []string, blocks []string) []LinesRegion {
	lines := lines_source_lines(source)
	mut result := []LinesRegion{}
	for index, line in lines {
		trimmed := line.text.trim_space()
		mut name := ''
		mut definition := false
		if trimmed.starts_with('def ') {
			name = trimmed[4..].all_before('(').all_before(' ').trim_space()
			definition = true
			if name !in methods {
				continue
			}
		} else if trimmed.ends_with(' do') {
			name = trimmed.all_before(' do').all_before('(').trim_space()
			if name !in blocks {
				continue
			}
		} else {
			continue
		}
		closing := lines_matching_end(lines, index)
		if closing < 0 {
			continue
		}
		start := line.start + (line.text.len - line.text.trim_left(' \t').len)
		end := lines[closing].start + (lines[closing].text.index('end') or { 0 }) + 3
		result << LinesRegion{ source: source[start..end], begin_pos: start, name: name, definition: definition }
	}
	return result
}

fn lines_shared_findings(analysis conditionals.OnSystemAnalysis, offset int) []LinesOffense {
	return analysis.findings.map(LinesOffense{ begin_pos: it.begin_pos + offset, end_pos: it.end_pos + offset, message: it.message, replacement: it.replacement })
}

pub fn audit_lines_on_system(context LinesContext) LinesAnalysis {
	methods := ['install', 'post_install']
	blocks := ['service', 'test']
	mut offenses := []LinesOffense{}
	for region in lines_named_regions(context.source, methods, blocks) {
		offenses << lines_shared_findings(conditionals.audit_on_system_blocks(region.source, region.name, region.definition), region.begin_pos)
	}
	if context.tap == 'homebrew-core' {
		offenses << lines_shared_findings(conditionals.audit_arch_conditionals(context.source, methods, blocks), 0)
		offenses << lines_shared_findings(conditionals.audit_base_os_conditionals(context.source, methods, blocks), 0)
		offenses << lines_shared_findings(conditionals.audit_macos_version_conditionals(context.source, methods, blocks, true), 0)
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_macos_on_linux(context LinesContext) LinesAnalysis {
	methods := ['install', 'post_install']
	mut blocks := ['service', 'test', 'on_macos']
	for version in conditionals.on_system_macos_version_options {
		blocks << 'on_${version}'
	}
	return lines_analysis(context, lines_shared_findings(conditionals.audit_macos_references(context.source, methods, blocks), 0))
}

pub struct LinesCompletionWrite {
pub:
	matched         bool
	source          string
	base_name       string
	shell           string
	executable      string
	subcommand      string
	shell_parameter string
	begin_pos       int
	end_pos         int
}

pub fn lines_shell_completion_writes(source string) []LinesCompletionWrite {
	mut result := []LinesCompletionWrite{}
	for line in lines_source_lines(source) {
		code := lines_code(line.text).trim_right(' \t')
		write_index := code.index(').write') or { continue }
		open := code[..write_index].last_index('(') or { continue }
		left := code[open + 1..write_index]
		if !left.contains('_completion/') {
			continue
		}
		shell_name := left.all_before('_completion/')
		base_source := left.all_after('_completion/').trim_space()
		base_name := lines_unquote(base_source).trim_left('_').trim_string_right('.fish')
		start := line.start + open
		call_source := code[open..].trim_space()
		mut completion := LinesCompletionWrite{ source: call_source, base_name: base_name, shell: shell_name, begin_pos: start, end_pos: line.start + code.len }
		rhs := call_source.all_after('.write').trim_space()
		if rhs.starts_with('Utils.safe_popen_read') {
			arguments := lines_split_arguments(rhs['Utils.safe_popen_read'.len..])
			if arguments.len == 3 {
				completion = LinesCompletionWrite{ ...completion, matched: true, executable: arguments[0], subcommand: arguments[1], shell_parameter: lines_unquote(arguments[2]) }
			}
		}
		result << completion
	}
	return result
}

fn lines_delete_suffix(value string, suffix string) string {
	if value.ends_with(suffix) {
		return value[..value.len - suffix.len]
	}
	return value
}

pub fn audit_lines_generate_completions(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for node in lines_shell_completion_writes(context.source) {
		if node.matched && ['bash', 'zsh', 'fish', 'pwsh'].any(node.shell_parameter.contains(it)) {
			mut parameter_format := node.shell_parameter
			for suffix in ['bash', 'zsh', 'fish', 'pwsh'] {
				parameter_format = lines_delete_suffix(parameter_format, suffix)
			}
			mut args := [node.executable, node.subcommand]
			if node.base_name != context.formula_name { args << 'base_name: "${node.base_name}"' }
			args << 'shells: [:${node.shell}]'
			if parameter_format != '' {
				format := if parameter_format == '--' {
					':flag'
				} else if parameter_format == '--shell=' { ':arg' } else { '"${parameter_format}"' }
				args << 'shell_parameter_format: ${format}'
			}
			replacement := 'generate_completions_from_executable(${args.join(', ')})'
			offenses << LinesOffense{ begin_pos: node.begin_pos, end_pos: node.end_pos, message: 'Use `${replacement}` instead of `${node.source}`.', replacement: replacement }
		} else if !node.source.contains('<<~') && !(node.source.contains('{') && node.source.contains('=>')) {
			offenses << LinesOffense{ begin_pos: node.begin_pos, end_pos: node.end_pos, message: 'Use `generate_completions_from_executable` DSL instead of `${node.source}`.' }
		}
	}
	return lines_analysis(context, offenses)
}

struct LinesGenerateCall {
	call     LinesCall
	shells   []string
	commands []string
}

fn lines_generate_calls(source string) []LinesGenerateCall {
	mut result := []LinesGenerateCall{}
	for call in lines_find_calls(source, 'generate_completions_from_executable') {
		mut shells := []string{}
		mut commands := []string{}
		for argument in call.arguments {
			trimmed := argument.trim_space()
			if trimmed.starts_with('shells: [') && trimmed.ends_with(']') {
				shells = lines_split_arguments(trimmed.all_after('[').all_before_last(']')).map(lines_symbol(it))
			} else if !trimmed.contains(': ') || trimmed.starts_with('bin/') || trimmed.starts_with('bin /') || trimmed.starts_with('"') || trimmed.starts_with("'") {
				commands << trimmed
			}
		}
		result << LinesGenerateCall{ call: call, shells: shells, commands: commands }
	}
	return result
}

fn lines_same_strings(left []string, right []string) bool {
	return left == right
}

pub fn audit_lines_single_generate_call(context LinesContext) LinesAnalysis {
	calls := lines_generate_calls(context.source)
	if calls.len <= 1 {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	mut shells := []string{}
	mut candidates := []LinesGenerateCall{}
	for call in calls {
		if call.shells.len == 1 {
			shells << call.shells[0]
			candidates << call
		}
	}
	if candidates.len == 0 {
		return lines_analysis(context, [])
	}
	for index := 0; index + 1 < candidates.len; index++ {
		current := candidates[index]
		if !lines_same_strings(current.commands, candidates[index + 1].commands) {
			if index < shells.len { shells.delete(index) }
			continue
		}
		line := lines_source_lines(context.source)[current.call.line]
		begin_pos := line.start
		end_pos := line.newline_end
		offenses << LinesOffense{ begin_pos: begin_pos, end_pos: end_pos, message: 'Use a single `generate_completions_from_executable` call combining all specified shells.', remove: true }
	}
	if shells.len <= 1 {
		return lines_analysis(context, offenses)
	}
	last := candidates.last()
	mut replacement := last.call.source
	all_default := ['bash', 'zsh', 'fish'].all(it in shells)
	if all_default {
		for argument in last.call.arguments {
			if argument.starts_with('shells:') {
				replacement = replacement.replace(', ${argument}', '').replace('${argument}, ', '').replace(argument, '')
			}
		}
		replacement = replacement.replace('(, ', '(').replace(', )', ')').replace(', , ', ', ')
	} else {
		for argument in last.call.arguments {
			if argument.starts_with('shells:') {
				replacement = replacement.replace(argument, 'shells: [${shells.map(':\${it}').join(', ')}]')
			}
		}
	}
	offenses << lines_offense(last.call, 'Use `${replacement}` instead of `${last.call.source}`.', replacement)
	return lines_analysis(context, offenses)
}

fn lines_string_set_equal(left []string, right []string) bool {
	return left.len == right.len && left.all(it in right) && right.all(it in left)
}

pub fn audit_lines_redundant_completion_shells(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for generated in lines_generate_calls(context.source) {
		if generated.shells.len == 0 {
			continue
		}
		mut format := ''
		mut literal_format := true
		mut shells_argument := ''
		for argument in generated.call.arguments {
			if argument.starts_with('shells:') {
				shells_argument = argument
			}
			if argument.starts_with('shell_parameter_format:') {
				value := argument.all_after(':').trim_space()
				if value.starts_with(':') || value.starts_with('"') || value.starts_with("'") {
					format = lines_unquote(value).trim_left(':')
				} else {
					literal_format = false
				}
			}
		}
		if !literal_format || !lines_string_set_equal(generated.shells, utils.default_completion_shells(format)) {
			continue
		}
		mut replacement := generated.call.source.replace(', ${shells_argument}', '').replace('${shells_argument}, ', '').replace(shells_argument, '')
		replacement = replacement.replace('(, ', '(').replace(', )', ')').replace(', , ', ', ')
		offenses << lines_offense(generated.call, 'Passing the default shells to `generate_completions_from_executable` is redundant', replacement)
	}
	return lines_analysis(context, offenses)
}

fn lines_compiler_name(value string) string {
	mut command := lines_unquote(value).trim_space()
	if command.starts_with('/usr/bin/') {
		command = command['/usr/bin/'.len..]
	}
	name := command.all_before(' ')
	return if name in ['gcc', 'clang', 'cc', 'c89', 'c99', 'g++', 'clang++', 'c++'] {
		name
	} else {
		''
	}
}

fn lines_add_message(mut offenses []LinesOffense, call LinesCall, message string) {
	offenses << lines_offense(call, message, '')
}

pub fn lines_conditional_dependencies(source string) []string {
	mut result := []string{}
	for line in lines_source_lines(source) {
		trimmed := line.text.trim_space()
		if !trimmed.starts_with('depends_on ') {
			continue
		}
		if trimmed.contains(' if build.include?') || trimmed.contains(' if build.with?') || trimmed.contains(' if build.without?') || trimmed.contains(' unless build.include?') || trimmed.contains(' unless build.with?') || trimmed.contains(' unless build.without?') {
			result << trimmed
		}
	}
	return result
}

pub fn lines_hash_dep(source string) (string, []string) {
	trimmed := source.trim_space()
	if !trimmed.contains('=>') {
		return '', []string{}
	}
	return lines_unquote(trimmed.all_before('=>').trim_space()), lines_split_arguments(trimmed.all_after('=>'))
}

pub fn lines_destructure_hash(source string) (string, string) {
	trimmed := source.trim_space()
	if !trimmed.contains('=>') {
		return '', ''
	}
	key := trimmed.all_before('=>').trim_space()
	value := trimmed.all_after('=>').trim_space()
	if !(key.starts_with('"') || key.starts_with("'")) || !value.starts_with(':') {
		return '', ''
	}
	return lines_unquote(key), lines_symbol(value)
}

pub fn lines_formula_path_strings(source string, path_method string) []string {
	mut result := []string{}
	needle := '#{${path_method}}'
	for literal in lines_string_literals(source) {
		if literal.content.contains(needle) { result << literal.content.all_after(needle) }
	}
	return result
}

pub fn lines_modifier(source string) bool {
	trimmed := source.trim_space()
	return !trimmed.contains('\n') && (trimmed.contains(' if ') || trimmed.contains(' unless '))
}

pub fn audit_lines_miscellaneous(context LinesContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for line in lines_source_lines(context.source) {
		code := lines_code(line.text)
		line_indent := line.text.len - line.text.trim_left(' \t').len
		fileutils_index := code.index('FileUtils.') or { -1 }
		if fileutils_index >= 0 {
			method := code[fileutils_index + 'FileUtils.'.len..].all_before('(').all_before(' ').trim_space()
			end := line.start + fileutils_index + 'FileUtils.'.len + method.len
			offenses << LinesOffense{ begin_pos: line.start + fileutils_index, end_pos: end, message: 'No need for `FileUtils.` before `${method}`' }
		}
		if code.contains('inreplace ') && code.contains(' do |') {
			argument := code.all_after(' do |').all_before('|')
			if argument.len > 1 {
				offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: '`inreplace <filenames> do |s|` is preferred over `|${argument}|`.' }
			}
		}
		trimmed := code.trim_space()
		for method in ['rebuild', 'version_scheme'] {
			if trimmed == '${method} 0' {
				offenses << LinesOffense{ begin_pos: line.start + (line.text.index(method) or { 0 }), end_pos: line.end, message: '`${method} 0` should be removed' }
			}
		}
		if trimmed.starts_with('def ') && line_indent == 0 {
			name := trimmed[4..].all_before('(').all_before(' ')
			offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: 'Define method `${name}` in the class body, not at the top-level' }
		}
		for constant, message in {
			'MACOS_VERSION':      'Use `MacOS.version` instead of `MACOS_VERSION`'
			'MACOS_FULL_VERSION': 'Use `MacOS.full_version` instead of `MACOS_FULL_VERSION`'
		} {
			index := code.index(constant) or { -1 }
			if index >= 0 {
				offenses << LinesOffense{ begin_pos: line.start + index, end_pos: line.start + index + constant.len, message: message }
			}
		}
		if code.contains('man+"man') || code.contains("man+'man") {
			index := code.index('man+') or { -1 }
			if index >= 0 {
				raw := code[index + 4..].all_before(' ').trim_space()
				value := lines_unquote(raw)
				if value.len == 4 && value.starts_with('man') && value[3] >= `1` && value[3] <= `8` {
					offenses << LinesOffense{ begin_pos: line.start + index, end_pos: line.start + index + 4 + raw.len, message: '`man+${raw}` should be `${value}`' }
				}
			}
		}
		if code.contains('ENV[') && code.contains('] = ') {
			value_source := code.all_after('] = ').trim_space()
			compiler := lines_compiler_name(value_source)
			if compiler != '' {
				env := if compiler.contains('++') { 'cxx' } else { 'cc' }
				value_index := line.text.index(value_source) or { 0 }
				offenses << LinesOffense{ begin_pos: line.start + value_index, end_pos: line.start + value_index + value_source.len, message: 'Use `#{ENV.${env}}` instead of hard-coding `${compiler}`' }
			}
		}
		if code.contains('version == "HEAD"') || code.contains("version == 'HEAD'") {
			index := code.index('version ==') or { 0 }
			offenses << LinesOffense{ begin_pos: line.start + index, end_pos: line.end, message: 'Use `build.head?` instead of inspecting `version`' }
		}
	}
	for call in lines_find_calls(context.source, 'ARGV') {
		lines_add_message(mut offenses, call, 'Use `build.with?` or `build.without?` instead of `ARGV` to check options')
	}
	for call in lines_find_calls(context.source, 'system') {
		if call.arguments.len == 0 {
			continue
		}
		compiler := lines_compiler_name(call.arguments[0])
		if compiler != '' {
			env := if compiler.contains('++') { 'cxx' } else { 'cc' }
			lines_add_message(mut offenses, call, 'Use `#{ENV.${env}}` instead of hard-coding `${compiler}`')
		}
		command := lines_unquote(call.arguments[0]).trim_space().all_before(' ')
		if command in ['env', 'export'] {
			lines_add_message(mut offenses, call, 'Use `ENV` instead of invoking `${command}` to modify the environment')
		}
		if command in ['otool', 'install_name_tool', 'lipo'] {
			lines_add_message(mut offenses, call, 'Use ruby-macho instead of calling ${call.arguments[0]}')
		}
		if command in ['cp', 'cp_r', 'install', 'ln', 'ln_s', 'mkdir', 'mkdir_p', 'mv', 'remove',
			'rm', 'rm_f', 'rm_r', 'rm_rf', 'rmtree', 'touch'] {
			lines_add_message(mut offenses, call, 'Use the `${command}` Ruby method instead of `${call.source}`')
		}
	}
	for call in lines_find_calls(context.source, 'ENV.[]=') {
		if call.arguments.len >= 2 {
			compiler := lines_compiler_name(call.arguments[1])
			if compiler != '' {
				lines_add_message(mut offenses, call, 'Use `#{ENV.${if compiler.contains('++') {
					'cxx'
				} else {
					'cc'
				}}}` instead of hard-coding `${compiler}`')
			}
		}
	}
	for path in lines_formula_path_strings(context.source, 'share') {
		if path == '/man' || path.starts_with('/man/') {
			offenses << LinesOffense{ message: '`#{share}${path}` should be `#{man}`' }
		}
	}
	for path in lines_formula_path_strings(context.source, 'prefix') {
		mut shortcut := ''
		if path == '/share/info' {
			shortcut = 'info'
		} else if path == '/share/man' {
			shortcut = 'man'
		} else if path.starts_with('/share/man/man') && path.len >= '/share/man/man1'.len {
			shortcut = path['/share/man/'.len..].all_before('/')
		} else {
			first := path.trim_left('/').all_before('/')
			if first in ['bin', 'include', 'libexec', 'lib', 'sbin', 'share', 'Frameworks'] {
				shortcut = first.to_lower()
			}
		}
		if shortcut != '' {
			offenses << LinesOffense{ message: '`#{prefix}${path}` should be `#{${shortcut}}`' }
		}
	}
	for call in lines_dependency_calls(context) {
		if call.arguments.len == 0 {
			continue
		}
		key, value := lines_destructure_hash(call.arguments[0])
		if key != '' && (value.starts_with('lua') || value.starts_with('perl') || value.starts_with('python') || value.starts_with('ruby')) {
			language := value.trim_right('0123456789')
			lines_add_message(mut offenses, call, '${language} modules should be vendored rather than using deprecated `${call.source}`')
		}
		dependency, options := lines_hash_dep(call.arguments[0])
		for option in options {
			for literal in lines_string_literals(option) {
				if literal.content.contains('with-') || literal.content.contains('without-') || literal.content.contains('c++11') {
					lines_add_message(mut offenses, call, "Dependency '${dependency}' should not use option `${literal.content}`")
				}
			}
		}
		if call.source.contains('.new') {
			lines_add_message(mut offenses, call, '`depends_on` can take requirement classes instead of instances')
		}
	}
	for call in lines_find_calls(context.source, 'version.==') {
		if call.arguments.any(lines_unquote(it) == 'HEAD') {
			lines_add_message(mut offenses, call, 'Use `build.head?` instead of inspecting `version`')
		}
	}
	for call in lines_find_calls(context.source, 'ARGV.include?') {
		if call.arguments.any(lines_unquote(it) == '--HEAD') {
			lines_add_message(mut offenses, call, 'Use `if build.head?` instead')
		}
	}
	for statement in lines_conditional_dependencies(context.source) {
		dependency_call := statement.all_before(if statement.contains(' unless ') {
			' unless '
		} else {
			' if '
		})
		dependency := lines_unquote(dependency_call.all_after('depends_on ').trim_space()).trim_left(':')
		condition := statement.all_after(if statement.contains(' unless ') {
			' unless '
		} else {
			' if '
		})
		optional := statement.contains(' if ') && (condition.contains('include?("with-${dependency}")') || condition.contains('include? "with-${dependency}"') || condition.contains('with?("${dependency}")') || condition.contains('with? "${dependency}"'))
		recommended := statement.contains(' unless ') && (condition.contains('include?("without-${dependency}")') || condition.contains('include? "without-${dependency}"') || condition.contains('without?("${dependency}")') || condition.contains('without? "${dependency}"'))
		if optional || recommended {
			message := if optional { 'optional' } else { 'recommended' }
			position := context.source.index(statement) or { 0 }
			offenses << LinesOffense{ begin_pos: position, end_pos: position + statement.len, message: 'Replace `${statement}` with `${dependency_call} => :${message}`' }
		}
	}
	for pair in [['fails_with', 'llvm'], ['needs', 'openmp'], ['skip_clean', 'all']] {
		for call in lines_find_calls(context.source, pair[0]) {
			if call.arguments.len == 0 || lines_symbol(call.arguments[0]) != pair[1] {
				continue
			}
			message := match pair[0] {
				'fails_with' { '`fails_with :llvm` is now a no-op and should be removed' }
				'needs' { '`needs :openmp` should be replaced with `depends_on "gcc"`' }
				else {
					'`skip_clean :all` is deprecated; brew no longer strips symbols. Pass explicit paths to prevent Homebrew from removing empty folders.'
				}
			}
			lines_add_message(mut offenses, call, message)
		}
	}
	for line in lines_source_lines(context.source) {
		if line.text.trim_space().starts_with('def test') && line.text.len > line.text.trim_left(' \t').len {
			offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: 'Use new-style test definitions (`test do`)' }
		}
		if line.text.contains('ENV.runtime_cpu_detection') && !context.runtime_cpu_exception {
			offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: 'Formulae should be verified as having support for runtime hardware detection before using `ENV.runtime_cpu_detection`.' }
		}
		if line.text.contains('ENV["CI"]') && lines_modifier(line.text) {
			offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: 'Don\'t use `ENV["CI"]` for Homebrew CI checks.' }
		}
		if line.text.contains('Dir[') {
			inside := line.text.all_after('Dir[').all_before(']')
			path := lines_unquote(inside)
			if !path.contains_any('*{},') {
				offenses << LinesOffense{ begin_pos: line.start, end_pos: line.end, message: '`Dir(["${path}"])` is unnecessary; just use `${path}`' }
			}
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_make_check(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' || context.formula_name.starts_with('lib') || context.make_check_exception {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_find_calls(context.source, 'system') {
		if call.arguments.len < 2 || lines_unquote(call.arguments[0]) != 'make' {
			continue
		}
		if call.arguments[1..].any(lines_unquote(it) in ['check', 'checks', 'test', 'tests']) {
			lines_add_message(mut offenses, call, 'Formulae in homebrew/core (except e.g. cryptography, libraries) should not run build-time checks')
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_requirements(context LinesContext) LinesAnalysis {
	messages := {
		'java':    'Formulae should depend on a versioned `openjdk` instead of :java'
		'x11':     'Formulae should depend on specific X libraries instead of :x11'
		'osxfuse': 'Formulae should not depend on :osxfuse'
		'tuntap':  'Formulae should not depend on :tuntap'
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		dependency := lines_dependency_name(call)
		if dependency in messages && call.arguments[0].starts_with(':') {
			lines_add_message(mut offenses, call, messages[dependency])
		}
	}
	return lines_analysis(context, offenses)
}

pub fn audit_lines_rust(context LinesContext) LinesAnalysis {
	if context.tap != 'homebrew-core' {
		return lines_analysis(context, [])
	}
	mut offenses := []LinesOffense{}
	for call in lines_dependency_calls(context) {
		if lines_dependency_name(call) != 'rustup' {
			continue
		}
		if call.arguments[0].contains('=>') {
			type_source := call.arguments[0].all_after('=>').trim_space()
			if type_source !in [':build', '[:build, :test]', '[:test, :build]'] {
				continue
			}
			replacement := 'depends_on "rust" => ${type_source}'
			lines_add_message(mut offenses, call, 'Formulae in homebrew/core should use `${replacement}` instead of `${call.source}`.')
			offenses[offenses.len - 1] = LinesOffense{ ...offenses.last(), replacement: replacement }
		} else {
			replacement := 'depends_on "rust"'
			offenses << lines_offense(call, 'Formulae in homebrew/core should use `${replacement}` instead of `${call.source}`.', replacement)
		}
	}
	for call in lines_find_calls(context.source, 'system') {
		if lines_position_in_named_region(context.source, call.begin_pos, 'install', true) && call.arguments.len > 0 && lines_unquote(call.arguments[0]).ends_with('rustup') {
			lines_add_message(mut offenses, call, 'Formula in homebrew/core should not use `rustup` at build-time.')
		}
	}
	return lines_analysis(context, offenses)
}

fn lines_context_from_values(args []ruby.Value) ?LinesContext {
	if args.len == 0 {
		return none
	}
	return LinesContext{
		source: args[0].as_string()
		tap: if args.len > 1 { args[1].as_string() } else { '' }
		formula_name: if args.len > 2 { args[2].as_string() } else { '' }
		make_check_exception: args.len > 3 && args[3].type_name == 'Bool' && args[3].bool_data
		runtime_cpu_exception: args.len > 4 && args[4].type_name == 'Bool' && args[4].bool_data
	}
}

pub fn lines_analysis_value(analysis LinesAnalysis) ruby.Value {
	offenses := analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':   it.begin_pos.str()
		'end_pos':     it.end_pos.str()
		'message':     it.message
		'replacement': it.replacement
		'remove':      it.remove.str()
	}))
	return ruby.map_value({
		'offenses':  ruby.array_value(offenses)
		'corrected': ruby.string_value(analysis.corrected)
	})
}

fn lines_audit_adapter(args []ruby.Value, audit fn (LinesContext) LinesAnalysis) ruby.Value {
	context := lines_context_from_values(args) or { return ruby.object_value('ArgumentError', 'source is required') }
	return lines_analysis_value(audit(context))
}

fn lines_calls_value(calls []LinesCall) ruby.Value {
	return ruby.array_value(calls.map(ruby.structured_value('RuboCop::AST::SendNode', it.source, {
		'target':    it.target
		'arguments': it.arguments.join(', ')
		'begin_pos': it.begin_pos.str()
		'end_pos':   it.end_pos.str()
	})))
}

fn lines_completion_writes_value(nodes []LinesCompletionWrite) ruby.Value {
	return ruby.array_value(nodes.map(ruby.structured_value('RuboCop::AST::SendNode', it.source, {
		'base_name':       it.base_name
		'shell':           it.shell
		'executable':      it.executable
		'subcommand':      it.subcommand
		'shell_parameter': it.shell_parameter
	})))
}
