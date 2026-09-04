module rubocops

import ruby
import homebrew.rubocops.@shared as conditionals
import homebrew.utils

// Translated from Homebrew/brew `rubocops/lines.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn lines_audit_adapter(args []ruby.Value, audit fn(LinesContext) LinesAnalysis) ruby.Value {
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

// Ruby method `audit_formula(_formula_nodes)` at line 14.
pub fn ruby_lines_l14_d1_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_deprecated_dependencies)
}

// Ruby method `audit_formula(formula_nodes)` at line 36.
pub fn ruby_lines_l36_d2_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_class_inheritance)
}

// Ruby method `audit_formula(_formula_nodes)` at line 52.
pub fn ruby_lines_l52_d3_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_comments)
}

// Ruby method `audit_formula(formula_nodes)` at line 94.
pub fn ruby_lines_l94_d4_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_assert_statements)
}

// Ruby method `audit_formula(formula_nodes)` at line 144.
pub fn ruby_lines_l144_d5_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_option_declarations)
}

// Ruby method `unless_modifier?(node)` at line 214.
pub fn ruby_lines_l214_d6_unless_modifier(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && lines_unless_modifier(args[0].as_string()))
}

// Ruby def_node_search `def_node_search :depends_on_build_with, <<~EOS` at line 222.
pub fn ruby_lines_l222_d7_depends_on_build_with(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(if args.len > 0 {
		lines_depends_on_build_with(args[0].as_string())
	} else {
		[]string{}
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 233.
pub fn ruby_lines_l233_d8_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_mpi)
}

// Ruby method `audit_formula(formula_nodes)` at line 254.
pub fn ruby_lines_l254_d9_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_std_npm_args)
}

// Ruby method `audit_formula(formula_nodes)` at line 292.
pub fn ruby_lines_l292_d10_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_quictls)
}

// Ruby method `audit_formula(formula_nodes)` at line 311.
pub fn ruby_lines_l311_d11_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_pyoxidizer)
}

// Ruby method `audit_formula(formula_nodes)` at line 324.
pub fn ruby_lines_l324_d12_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_libiconv)
}

// Ruby method `audit_formula(formula_nodes)` at line 337.
pub fn ruby_lines_l337_d13_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_full_dependencies)
}

// Ruby method `audit_formula(formula_nodes)` at line 360.
pub fn ruby_lines_l360_d14_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_safe_popen)
}

// Ruby method `audit_formula(formula_nodes)` at line 391.
pub fn ruby_lines_l391_d15_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_shell_variables)
}

// Ruby method `audit_formula(formula_nodes)` at line 421.
pub fn ruby_lines_l421_d16_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_license_arrays)
}

// Ruby method `audit_formula(formula_nodes)` at line 440.
pub fn ruby_lines_l440_d17_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_licenses)
}

// Ruby def_node_matcher `def_node_matcher :license_exception?, <<~EOS` at line 454.
pub fn ruby_lines_l454_d18_license_exception(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && lines_license_exception(args[0].as_string()))
}

// Ruby method `audit_formula(formula_nodes)` at line 464.
pub fn ruby_lines_l464_d19_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_java_versions)
}

// Ruby def_node_search `def_node_search :java_home_method_call, <<~PATTERN` at line 571.
pub fn ruby_lines_l571_d20_java_home_method_call(args ...ruby.Value) ruby.Value {
	return lines_calls_value(if args.len > 0 {
		lines_java_home_calls(args[0].as_string())
	} else {
		[]LinesCall{}
	})
}

// Ruby def_node_search `def_node_search :java_version_assignment, <<~PATTERN` at line 575.
pub fn ruby_lines_l575_d21_java_version_assignment(args ...ruby.Value) ruby.Value {
	return lines_calls_value(if args.len > 1 {
		lines_java_version_assignments(args[0].as_string(), args[1].as_string())
	} else {
		[]LinesCall{}
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 585.
pub fn ruby_lines_l585_d22_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_python_versions)
}

// Ruby method `audit_formula(formula_nodes)` at line 635.
pub fn ruby_lines_l635_d23_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_on_system)
}

// Ruby method `audit_formula(formula_nodes)` at line 678.
pub fn ruby_lines_l678_d24_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_macos_on_linux)
}

// Ruby method `audit_formula(formula_nodes)` at line 690.
pub fn ruby_lines_l690_d25_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_generate_completions)
}

// Ruby def_node_search `def_node_search :correctable_shell_completion_node, <<~EOS` at line 744.
pub fn ruby_lines_l744_d26_correctable_shell_completion_node(args ...ruby.Value) ruby.Value {
	return lines_completion_writes_value(if args.len > 0 {
		lines_shell_completion_writes(args[0].as_string()).filter(it.matched)
	} else {
		[]LinesCompletionWrite{}
	})
}

// Ruby def_node_search `def_node_search :shell_completion_node, <<~EOS` at line 760.
pub fn ruby_lines_l760_d27_shell_completion_node(args ...ruby.Value) ruby.Value {
	return lines_completion_writes_value(if args.len > 0 {
		lines_shell_completion_writes(args[0].as_string())
	} else {
		[]LinesCompletionWrite{}
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 775.
pub fn ruby_lines_l775_d28_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_single_generate_call)
}

// Ruby method `audit_formula(formula_nodes)` at line 842.
pub fn ruby_lines_l842_d29_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_redundant_completion_shells)
}

// Ruby method `audit_formula(formula_nodes)` at line 883.
pub fn ruby_lines_l883_d30_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_miscellaneous)
}

// Ruby method `modifier?(node)` at line 1091.
pub fn ruby_lines_l1091_d31_modifier(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && lines_modifier(args[0].as_string()))
}

// Ruby def_node_search `def_node_search :conditional_dependencies, <<~EOS` at line 1097.
pub fn ruby_lines_l1097_d32_conditional_dependencies(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(if args.len > 0 {
		lines_conditional_dependencies(args[0].as_string())
	} else {
		[]string{}
	})
}

// Ruby def_node_matcher `def_node_matcher :hash_dep, <<~EOS` at line 1105.
pub fn ruby_lines_l1105_d33_hash_dep(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	dependency, options := lines_hash_dep(args[0].as_string())
	return ruby.array_value([ruby.string_value(dependency),
		ruby.string_array_value(options)])
}

// Ruby def_node_matcher `def_node_matcher :destructure_hash, <<~EOS` at line 1109.
pub fn ruby_lines_l1109_d34_destructure_hash(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([]ruby.Value{})
	}
	key, value := lines_destructure_hash(args[0].as_string())
	return ruby.string_array_value([key, value])
}

// Ruby def_node_search `def_node_search :formula_path_strings, <<~EOS` at line 1113.
pub fn ruby_lines_l1113_d35_formula_path_strings(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_array_value([]string{})
	}
	return ruby.string_array_value(lines_formula_path_strings(args[0].as_string(), args[1].as_string()))
}

// Ruby method `audit_formula(formula_nodes)` at line 1124.
pub fn ruby_lines_l1124_d36_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_make_check)
}

// Ruby method `audit_formula(_formula_nodes)` at line 1149.
pub fn ruby_lines_l1149_d37_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_requirements)
}

// Ruby method `audit_formula(formula_nodes)` at line 1162.
pub fn ruby_lines_l1162_d38_audit_formula(args ...ruby.Value) ruby.Value {
	return lines_audit_adapter(args, audit_lines_rust)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/on_system_conditionals_helper"
// 6: require "utils/shell_completion"
// 7:
// 8: module RuboCop
// 9:   module Cop
// 10:     module FormulaAudit
// 11:       # This cop checks for various miscellaneous Homebrew coding styles.
// 12:       class Lines < FormulaCop
// 13:         sig { override.params(_formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(_formula_nodes)
// 15:           [:automake, :ant, :autoconf, :emacs, :expat, :libtool, :mysql, :perl,
// 16:            :postgresql, :python, :python3, :rbenv, :ruby].each do |dependency|
// 17:             next unless depends_on?(dependency)
// 18:
// 19:             problem ":#{dependency} is deprecated. Usage should be \"#{dependency}\"."
// 20:           end
// 21:
// 22:           { apr: "apr-util", fortran: "gcc", gpg: "gnupg", hg: "mercurial",
// 23:             mpi: "open-mpi", python2: "python" }.each do |requirement, dependency|
// 24:             next unless depends_on?(requirement)
// 25:
// 26:             problem ":#{requirement} is deprecated. Usage should be \"#{dependency}\"."
// 27:           end
// 28:
// 29:           problem ":tex is deprecated." if depends_on?(:tex)
// 30:         end
// 31:       end
// 32:
// 33:       # This cop makes sure that a space is used for class inheritance.
// 34:       class ClassInheritance < FormulaCop
// 35:         sig { override.params(formula_nodes: FormulaNodes).void }
// 36:         def audit_formula(formula_nodes)
// 37:           parent_class_node = formula_nodes.parent_class_node
// 38:           begin_pos = start_column(parent_class_node)
// 39:           end_pos = end_column(formula_nodes.class_node)
// 40:           return if begin_pos-end_pos == 3
// 41:
// 42:           raise "unexpected nil value for @formula_name" unless @formula_name
// 43:
// 44:           problem "Use a space in class inheritance: " \
// 45:                   "class #{@formula_name.capitalize} < #{class_name(parent_class_node)}"
// 46:         end
// 47:       end
// 48:
// 49:       # This cop makes sure that template comments are removed.
// 50:       class Comments < FormulaCop
// 51:         sig { override.params(_formula_nodes: FormulaNodes).void }
// 52:         def audit_formula(_formula_nodes)
// 53:           audit_comments do |comment|
// 54:             [
// 55:               "# PLEASE REMOVE",
// 56:               "# Documentation:",
// 57:               "# if this fails, try separate make/make install steps",
// 58:               "# The URL of the archive",
// 59:               "## Naming --",
// 60:               "# if your formula fails when building in parallel",
// 61:               "# Remove unrecognized options if warned by configure",
// 62:               '# system "cmake',
// 63:             ].each do |template_comment|
// 64:               next unless comment.include?(template_comment)
// 65:
// 66:               problem "Please remove default template comments"
// 67:               break
// 68:             end
// 69:           end
// 70:
// 71:           audit_comments do |comment|
// 72:             # Commented-out depends_on
// 73:             next unless comment =~ /#\s*depends_on\s+(.+)\s*$/
// 74:
// 75:             problem "Commented-out dependency #{Regexp.last_match(1)}"
// 76:           end
// 77:
// 78:           return if formula_tap != "homebrew-core"
// 79:
// 80:           # Citation and tag comments from third-party taps
// 81:           audit_comments do |comment|
// 82:             next if comment !~ /#\s*(cite(?=\s*\w+:)|doi(?=\s*['"])|tag(?=\s*['"]))/
// 83:
// 84:             problem "Formulae in homebrew/core should not use `#{Regexp.last_match(1)}` comments"
// 85:           end
// 86:         end
// 87:       end
// 88:
// 89:       # This cop makes sure that idiomatic `assert_*` statements are used.
// 90:       class AssertStatements < FormulaCop
// 91:         extend AutoCorrector
// 92:
// 93:         sig { override.params(formula_nodes: FormulaNodes).void }
// 94:         def audit_formula(formula_nodes)
// 95:           return if (body_node = formula_nodes.body_node).nil?
// 96:
// 97:           find_every_method_call_by_name(body_node, :assert).each do |method|
// 98:             if method_called_ever?(method, :include?) && !method_called_ever?(method, :!)
// 99:               problem "Use `assert_match` instead of `assert ...include?`"
// 100:             end
// 101:
// 102:             if method_called_ever?(method, :exist?) && !method_called_ever?(method, :!)
// 103:               problem "Use `assert_path_exists <path_to_file>` instead of `#{method.source}`"
// 104:             end
// 105:
// 106:             if method_called_ever?(method, :exist?) && method_called_ever?(method, :!)
// 107:               problem "Use `refute_path_exists <path_to_file>` instead of `#{method.source}`"
// 108:             end
// 109:
// 110:             if method_called_ever?(method, :executable?) && !method_called_ever?(method, :!)
// 111:               problem "Use `assert_predicate <path_to_file>, :executable?` instead of `#{method.source}`"
// 112:             end
// 113:           end
// 114:
// 115:           find_every_method_call_by_name(body_node, :assert_predicate).each do |method|
// 116:             args = parameters(method)
// 117:             next if args.fetch(1).source != ":exist?"
// 118:
// 119:             @offensive_node = method
// 120:             problem "Use `assert_path_exists <path_to_file>` instead of `#{method.source}`" do |corrector|
// 121:               correct = "assert_path_exists #{args.fetch(0).source}"
// 122:               correct += ", #{args.fetch(2).source}" if args.length == 3
// 123:               corrector.replace(@offensive_node.source_range, correct)
// 124:             end
// 125:           end
// 126:
// 127:           find_every_method_call_by_name(body_node, :refute_predicate).each do |method|
// 128:             args = parameters(method)
// 129:             next if args.fetch(1).source != ":exist?"
// 130:
// 131:             @offensive_node = method
// 132:             problem "Use `refute_path_exists <path_to_file>` instead of `#{method.source}`" do |corrector|
// 133:               correct = "refute_path_exists #{args.fetch(0).source}"
// 134:               correct += ", #{args.fetch(2).source}" if args.length == 3
// 135:               corrector.replace(@offensive_node.source_range, correct)
// 136:             end
// 137:           end
// 138:         end
// 139:       end
// 140:
// 141:       # This cop makes sure that `option`s are used idiomatically.
// 142:       class OptionDeclarations < FormulaCop
// 143:         sig { override.params(formula_nodes: FormulaNodes).void }
// 144:         def audit_formula(formula_nodes)
// 145:           return if (body_node = formula_nodes.body_node).nil?
// 146:
// 147:           problem "Use new-style option definitions" if find_method_def(body_node, :options)
// 148:
// 149:           if formula_tap == "homebrew-core"
// 150:             # Use of build.with? implies options, which are forbidden in homebrew/core
// 151:             find_instance_method_call(body_node, :build, :without?) do
// 152:               problem "Formulae in homebrew/core should not use `build.without?`."
// 153:             end
// 154:             find_instance_method_call(body_node, :build, :with?) do
// 155:               problem "Formulae in homebrew/core should not use `build.with?`."
// 156:             end
// 157:
// 158:             return
// 159:           end
// 160:
// 161:           depends_on_build_with(body_node) do |build_with_node|
// 162:             offending_node(build_with_node)
// 163:             problem "Use `:optional` or `:recommended` instead of `if #{build_with_node.source}`"
// 164:           end
// 165:
// 166:           find_instance_method_call(body_node, :build, :without?) do |method|
// 167:             next unless unless_modifier?(method.parent)
// 168:
// 169:             correct = method.source.gsub("out?", "?")
// 170:             problem "Use `if #{correct}` instead of `unless #{method.source}`"
// 171:           end
// 172:
// 173:           find_instance_method_call(body_node, :build, :with?) do |method|
// 174:             next unless unless_modifier?(method.parent)
// 175:
// 176:             correct = method.source.gsub("?", "out?")
// 177:             problem "Use `if #{correct}` instead of `unless #{method.source}`"
// 178:           end
// 179:
// 180:           find_instance_method_call(body_node, :build, :with?) do |method|
// 181:             next unless expression_negated?(method)
// 182:
// 183:             problem "Instead of negating `build.with?`, use `build.without?`"
// 184:           end
// 185:
// 186:           find_instance_method_call(body_node, :build, :without?) do |method|
// 187:             next unless expression_negated?(method)
// 188:
// 189:             problem "Instead of negating `build.without?`, use `build.with?`"
// 190:           end
// 191:
// 192:           find_instance_method_call(body_node, :build, :without?) do |method|
// 193:             arg = parameters(method).fetch(0)
// 194:             next unless (match = regex_match_group(arg, /^-?-?without-(.*)/))
// 195:
// 196:             problem "Instead of duplicating `without`, " \
// 197:                     "use `build.without? \"#{match[1]}\"` to check for \"--without-#{match[1]}\""
// 198:           end
// 199:
// 200:           find_instance_method_call(body_node, :build, :with?) do |method|
// 201:             arg = parameters(method).fetch(0)
// 202:             next unless (match = regex_match_group(arg, /^-?-?with-(.*)/))
// 203:
// 204:             problem "Instead of duplicating `with`, " \
// 205:                     "use `build.with? \"#{match[1]}\"` to check for '--with-#{match[1]}'"
// 206:           end
// 207:
// 208:           find_instance_method_call(body_node, :build, :include?) do
// 209:             problem "`build.include?` is deprecated"
// 210:           end
// 211:         end
// 212:
// 213:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 214:         def unless_modifier?(node)
// 215:           return false unless node.if_type?
// 216:
// 217:           node = T.cast(node, RuboCop::AST::IfNode)
// 218:           node.modifier_form? && node.unless?
// 219:         end
// 220:
// 221:         # Finds `depends_on "foo" if build.with?("bar")` or `depends_on "foo" if build.without?("bar")`
// 222:         def_node_search :depends_on_build_with, <<~EOS
// 223:           (if $(send (send nil? :build) {:with? :without?} str)
// 224:             (send nil? :depends_on str) nil?)
// 225:         EOS
// 226:       end
// 227:
// 228:       # This cop makes sure that formulae depend on `open-mpi` instead of `mpich`.
// 229:       class MpiCheck < FormulaCop
// 230:         extend AutoCorrector
// 231:
// 232:         sig { override.params(formula_nodes: FormulaNodes).void }
// 233:         def audit_formula(formula_nodes)
// 234:           return if (body_node = formula_nodes.body_node).nil?
// 235:
// 236:           # Enforce use of OpenMPI for MPI dependency in core
// 237:           return if formula_tap != "homebrew-core"
// 238:
// 239:           find_method_with_args(body_node, :depends_on, "mpich") do
// 240:             problem "Formulae in homebrew/core should use `depends_on \"open-mpi\"` " \
// 241:                     "instead of `#{T.must(@offensive_node).source}`." do |corrector|
// 242:               corrector.replace(T.must(@offensive_node).source_range, "depends_on \"open-mpi\"")
// 243:             end
// 244:           end
// 245:         end
// 246:       end
// 247:
// 248:       # This cop makes sure that formulae use `std_npm_args` instead of older
// 249:       # `local_npm_install_args` and `std_npm_install_args`.
// 250:       class StdNpmArgs < FormulaCop
// 251:         extend AutoCorrector
// 252:
// 253:         sig { override.params(formula_nodes: FormulaNodes).void }
// 254:         def audit_formula(formula_nodes)
// 255:           return if (body_node = formula_nodes.body_node).nil?
// 256:
// 257:           find_method_with_args(body_node, :local_npm_install_args) do
// 258:             problem "Use `std_npm_args` instead of `#{T.cast(@offensive_node,
// 259:                                                              RuboCop::AST::SendNode).method_name}`." do |corrector|
// 260:               corrector.replace(T.must(@offensive_node).source_range, "std_npm_args(prefix: false)")
// 261:             end
// 262:           end
// 263:
// 264:           find_method_with_args(body_node, :std_npm_install_args) do |method|
// 265:             problem "Use `std_npm_args` instead of `#{T.cast(@offensive_node,
// 266:                                                              RuboCop::AST::SendNode).method_name}`." do |corrector|
// 267:               if (param = parameters(method).fetch(0).source) == "libexec"
// 268:                 corrector.replace(T.must(@offensive_node).source_range, "std_npm_args")
// 269:               else
// 270:                 corrector.replace(T.must(@offensive_node).source_range, "std_npm_args(prefix: #{param})")
// 271:               end
// 272:             end
// 273:           end
// 274:
// 275:           find_every_method_call_by_name(body_node, :system).each do |method|
// 276:             first_param, second_param = parameters(method)
// 277:             next if !node_equals?(first_param, "npm") ||
// 278:                     !node_equals?(second_param, "install") ||
// 279:                     method.source.match(/(std_npm_args|local_npm_install_args|std_npm_install_args)/)
// 280:
// 281:             offending_node(method)
// 282:             problem "Use `std_npm_args` for npm install"
// 283:           end
// 284:         end
// 285:       end
// 286:
// 287:       # This cop makes sure that formulae depend on `openssl` instead of `quictls`.
// 288:       class QuicTLSCheck < FormulaCop
// 289:         extend AutoCorrector
// 290:
// 291:         sig { override.params(formula_nodes: FormulaNodes).void }
// 292:         def audit_formula(formula_nodes)
// 293:           return if (body_node = formula_nodes.body_node).nil?
// 294:
// 295:           # Enforce use of OpenSSL for TLS dependency in core
// 296:           return if formula_tap != "homebrew-core"
// 297:
// 298:           find_method_with_args(body_node, :depends_on, "quictls") do
// 299:             problem "Formulae in homebrew/core should use `depends_on \"openssl@3\"` " \
// 300:                     "instead of `#{T.must(@offensive_node).source}`." do |corrector|
// 301:               corrector.replace(T.must(@offensive_node).source_range, "depends_on \"openssl@3\"")
// 302:             end
// 303:           end
// 304:         end
// 305:       end
// 306:
// 307:       # This cop makes sure that formulae do not depend on `pyoxidizer` at build-time
// 308:       # or run-time.
// 309:       class PyoxidizerCheck < FormulaCop
// 310:         sig { override.params(formula_nodes: FormulaNodes).void }
// 311:         def audit_formula(formula_nodes)
// 312:           return if formula_nodes.body_node.nil?
// 313:           # Disallow use of PyOxidizer as a dependency in core
// 314:           return if formula_tap != "homebrew-core"
// 315:           return unless depends_on?("pyoxidizer")
// 316:
// 317:           problem "Formulae in homebrew/core should not use `#{T.must(@offensive_node).source}`."
// 318:         end
// 319:       end
// 320:
// 321:       # This cop makes sure that formulae do not depend on `libiconv` in homebrew/core.
// 322:       class LibiconvCheck < FormulaCop
// 323:         sig { override.params(formula_nodes: FormulaNodes).void }
// 324:         def audit_formula(formula_nodes)
// 325:           return if formula_nodes.body_node.nil?
// 326:           return if formula_tap != "homebrew-core"
// 327:           return if @formula_name == "neomutt"
// 328:           return unless depends_on?("libiconv")
// 329:
// 330:           problem "Formulae in homebrew/core should not use `#{T.must(@offensive_node).source}`."
// 331:         end
// 332:       end
// 333:
// 334:       # This cop makes sure that formulae do not depend on `*-full` formulae in homebrew/core.
// 335:       class FullDependencyCheck < FormulaCop
// 336:         sig { override.params(formula_nodes: FormulaNodes).void }
// 337:         def audit_formula(formula_nodes)
// 338:           return if (body_node = formula_nodes.body_node).nil?
// 339:           return if formula_tap != "homebrew-core"
// 340:
// 341:           find_every_method_call_by_name(body_node, :depends_on).each do |node|
// 342:             node.each_descendant(:str, :sym) do |dependency_node|
// 343:               dependency = string_content(dependency_node)
// 344:               next if dependency.empty?
// 345:               next unless dependency.end_with?("-full")
// 346:
// 347:               @offensive_node = node
// 348:               problem "Formulae in homebrew/core should not depend on `#{dependency}`."
// 349:               break
// 350:             end
// 351:           end
// 352:         end
// 353:       end
// 354:
// 355:       # This cop makes sure that the safe versions of `popen_*` calls are used.
// 356:       class SafePopenCommands < FormulaCop
// 357:         extend AutoCorrector
// 358:
// 359:         sig { override.params(formula_nodes: FormulaNodes).void }
// 360:         def audit_formula(formula_nodes)
// 361:           return if (body_node = formula_nodes.body_node).nil?
// 362:
// 363:           test = find_block(body_node, :test)
// 364:
// 365:           [:popen_read, :popen_write].each do |unsafe_command|
// 366:             test_methods = []
// 367:
// 368:             unless test.nil?
// 369:               find_instance_method_call(test, "Utils", unsafe_command) do |method|
// 370:                 test_methods << method.source_range
// 371:               end
// 372:             end
// 373:
// 374:             find_instance_method_call(body_node, "Utils", unsafe_command) do |method|
// 375:               unless test_methods.include?(method.source_range)
// 376:                 problem "Use `Utils.safe_#{unsafe_command}` instead of `Utils.#{unsafe_command}`" do |corrector|
// 377:                   corrector.replace(T.must(@offensive_node).loc.selector,
// 378:                                     "safe_#{T.cast(@offensive_node, RuboCop::AST::SendNode).method_name}")
// 379:                 end
// 380:               end
// 381:             end
// 382:           end
// 383:         end
// 384:       end
// 385:
// 386:       # This cop makes sure that environment variables are passed correctly to `popen_*` calls.
// 387:       class ShellVariables < FormulaCop
// 388:         extend AutoCorrector
// 389:
// 390:         sig { override.params(formula_nodes: FormulaNodes).void }
// 391:         def audit_formula(formula_nodes)
// 392:           return if (body_node = formula_nodes.body_node).nil?
// 393:
// 394:           popen_commands = [
// 395:             :popen,
// 396:             :popen_read,
// 397:             :safe_popen_read,
// 398:             :popen_write,
// 399:             :safe_popen_write,
// 400:           ]
// 401:
// 402:           popen_commands.each do |command|
// 403:             find_instance_method_call(body_node, "Utils", command) do |method|
// 404:               next unless (match = regex_match_group(parameters(method).fetch(0), /^([^"' ]+)=([^"' ]+)(?: (.*))?$/))
// 405:
// 406:               good_args = "Utils.#{command}({ \"#{match[1]}\" => \"#{match[2]}\" }, \"#{match[3]}\")"
// 407:
// 408:               problem "Use `#{good_args}` instead of `#{method.source}`" do |corrector|
// 409:                 corrector.replace(method.source_range, good_args)
// 410:               end
// 411:             end
// 412:           end
// 413:         end
// 414:       end
// 415:
// 416:       # This cop makes sure that `license` has the correct format.
// 417:       class LicenseArrays < FormulaCop
// 418:         extend AutoCorrector
// 419:
// 420:         sig { override.params(formula_nodes: FormulaNodes).void }
// 421:         def audit_formula(formula_nodes)
// 422:           return if (body_node = formula_nodes.body_node).nil?
// 423:
// 424:           license_node = find_node_method_by_name(body_node, :license)
// 425:           return unless license_node
// 426:
// 427:           license = parameters(license_node).fetch(0)
// 428:           return unless license.array_type?
// 429:
// 430:           problem "Use `license any_of: #{license.source}` instead of `license #{license.source}`" do |corrector|
// 431:             corrector.replace(license_node.source_range,
// 432:                               "license any_of: #{parameters(license_node).fetch(0).source}")
// 433:           end
// 434:         end
// 435:       end
// 436:
// 437:       # This cop makes sure that nested `license` declarations are split onto multiple lines.
// 438:       class Licenses < FormulaCop
// 439:         sig { override.params(formula_nodes: FormulaNodes).void }
// 440:         def audit_formula(formula_nodes)
// 441:           return if (body_node = formula_nodes.body_node).nil?
// 442:
// 443:           license_node = find_node_method_by_name(body_node, :license)
// 444:           return unless license_node
// 445:           return if license_node.source.include?("\n")
// 446:
// 447:           parameters(license_node).fetch(0).each_descendant(:hash).each do |license_hash|
// 448:             next if license_exception? license_hash
// 449:
// 450:             problem "Split nested license declarations onto multiple lines"
// 451:           end
// 452:         end
// 453:
// 454:         def_node_matcher :license_exception?, <<~EOS
// 455:           (hash (pair (sym :with) str))
// 456:         EOS
// 457:       end
// 458:
// 459:       # This cop makes sure that Java versions are consistent.
// 460:       class JavaVersions < FormulaCop
// 461:         extend AutoCorrector
// 462:
// 463:         sig { override.params(formula_nodes: FormulaNodes).void }
// 464:         def audit_formula(formula_nodes)
// 465:           return if formula_tap != "homebrew-core"
// 466:           return if (body_node = formula_nodes.body_node).nil?
// 467:
// 468:           openjdk_dependency_matches = find_every_method_call_by_name(body_node, :depends_on).filter_map do |method|
// 469:             dep = parameters(method).first
// 470:             dep = dep.keys.first if dep.is_a?(RuboCop::AST::HashNode)
// 471:             string_content(dep).match(/^openjdk(?:@(\d+(?:\.\d+)*))?$/)
// 472:           end
// 473:
// 474:           # Only handle single OpenJDK dependency scenario
// 475:           return if openjdk_dependency_matches.count != 1
// 476:
// 477:           openjdk_dependency_match = openjdk_dependency_matches.fetch(0)
// 478:           openjdk_version = openjdk_dependency_match[1]
// 479:           openjdk_version = "1.8" if openjdk_version == "8"
// 480:           message = "Java version argument should match the specified dependency (`#{openjdk_dependency_match[0]}`)"
// 481:           variables = []
// 482:
// 483:           # e.g. Language::Java.overridable_java_home_env("25")
// 484:           java_home_method_call(body_node) do |java_home_node, method, args|
// 485:             java_version_node = args.first
// 486:             java_version = nil
// 487:
// 488:             case java_version_node
// 489:             when nil
// 490:               java_version = nil
// 491:             when RuboCop::AST::StrNode
// 492:               java_version = string_content(java_version_node)
// 493:             when RuboCop::AST::VarNode
// 494:               variables << java_version_node.name
// 495:               next
// 496:             else
// 497:               next unless java_version_node.nil_type?
// 498:
// 499:               if openjdk_version.nil?
// 500:                 offending_node(java_version_node)
// 501:                 problem "Argument is unnecessary when using unversioned OpenJDK" do |corrector|
// 502:                   corrector.replace(java_home_node.source_range, "Language::Java.#{method}")
// 503:                 end
// 504:               end
// 505:             end
// 506:             next if java_version == openjdk_version
// 507:
// 508:             correct = "Language::Java.#{method}"
// 509:             correct += "(\"#{openjdk_version}\")" if openjdk_version
// 510:             offending_node(java_version_node || java_home_node)
// 511:             problem message do |corrector|
// 512:               corrector.replace(java_home_node.source_range, correct)
// 513:             end
// 514:           end
// 515:
// 516:           # e.g. bin.write_jar_script libexec/"<name>.jar", "<name>", java_version: "25"
// 517:           find_instance_method_call(body_node, :bin, :write_jar_script) do |method|
// 518:             params = parameters(method)
// 519:             next unless (last_param = params.last)
// 520:
// 521:             java_version = nil
// 522:             java_version_node = nil
// 523:             if last_param.is_a?(RuboCop::AST::HashNode)
// 524:               java_version_arg_node = last_param.pairs.find { |pair| pair.key.value == :java_version }
// 525:               java_version_node = java_version_arg_node&.value
// 526:
// 527:               case java_version_node
// 528:               when nil
// 529:                 java_version = nil
// 530:               when RuboCop::AST::StrNode
// 531:                 java_version = string_content(java_version_node)
// 532:               when RuboCop::AST::VarNode
// 533:                 variables << java_version_node.name
// 534:                 next
// 535:               else
// 536:                 next unless java_version_node.nil_type?
// 537:               end
// 538:             end
// 539:             next if openjdk_version == java_version
// 540:
// 541:             offending_node(java_version_node || method)
// 542:             problem message do |corrector|
// 543:               if java_version_node.nil?
// 544:                 corrector.insert_after(last_param.source_range, ", java_version: \"#{openjdk_version}\"")
// 545:               elsif openjdk_version.nil?
// 546:                 range = range_with_surrounding_space(range: last_param.source_range, side: :left)
// 547:                 corrector.remove(range_with_surrounding_comma(range, :left))
// 548:               else
// 549:                 corrector.replace(java_version_node.source_range, "\"#{openjdk_version}\"")
// 550:               end
// 551:             end
// 552:           end
// 553:
// 554:           # e.g. java_version = "25"; Language::Java.overridable_java_home_env(java_version)
// 555:           variables.uniq!
// 556:           variables.each do |variable|
// 557:             java_version_assignment(body_node, variable:) do |java_version_node|
// 558:               java_version = nil
// 559:               java_version = string_content(java_version_node) if java_version_node.str_type?
// 560:               next if java_version == openjdk_version
// 561:
// 562:               correct = openjdk_version ? "\"#{openjdk_version}\"" : "nil"
// 563:               offending_node(java_version_node)
// 564:               problem message do |corrector|
// 565:                 corrector.replace(java_version_node.source_range, correct)
// 566:               end
// 567:             end
// 568:           end
// 569:         end
// 570:
// 571:         def_node_search :java_home_method_call, <<~PATTERN
// 572:           $(send (const (const nil? :Language) :Java) ${:java_home :java_home_env :overridable_java_home_env} $...)
// 573:         PATTERN
// 574:
// 575:         def_node_search :java_version_assignment, <<~PATTERN
// 576:           (lvasgn %variable ${nil | str})
// 577:         PATTERN
// 578:       end
// 579:
// 580:       # This cop makes sure that Python versions are consistent.
// 581:       class PythonVersions < FormulaCop
// 582:         extend AutoCorrector
// 583:
// 584:         sig { override.params(formula_nodes: FormulaNodes).void }
// 585:         def audit_formula(formula_nodes)
// 586:           return if (body_node = formula_nodes.body_node).nil?
// 587:
// 588:           python_formula_node = find_every_method_call_by_name(body_node, :depends_on).find do |dep|
// 589:             string_content(parameters(dep).fetch(0)).start_with? "python@"
// 590:           end
// 591:
// 592:           python_version = if python_formula_node.blank?
// 593:             other_python_nodes = find_every_method_call_by_name(body_node, :depends_on).select do |dep|
// 594:               first_param = parameters(dep).first
// 595:               first_param.instance_of?(RuboCop::AST::HashNode) &&
// 596:                 string_content(first_param.keys.first).start_with?("python@")
// 597:             end
// 598:             return if other_python_nodes.size != 1
// 599:
// 600:             string_content(T.cast(parameters(other_python_nodes.fetch(0)).fetch(0), RuboCop::AST::HashNode).keys.first).split("@").last
// 601:           else
// 602:             string_content(parameters(python_formula_node).fetch(0)).split("@").last
// 603:           end
// 604:
// 605:           find_strings(body_node).each do |str|
// 606:             content = string_content(str)
// 607:
// 608:             next unless (match = content.match(/^python(@)?(\d\.\d+)$/))
// 609:             next if python_version == match[2]
// 610:
// 611:             fix = if match[1]
// 612:               "python@#{python_version}"
// 613:             else
// 614:               "python#{python_version}"
// 615:             end
// 616:
// 617:             offending_node(str)
// 618:             problem "References to `#{content}` should " \
// 619:                     "match the specified python dependency (`#{fix}`)" do |corrector|
// 620:               corrector.replace(str.source_range, "\"#{fix}\"")
// 621:             end
// 622:           end
// 623:         end
// 624:       end
// 625:
// 626:       # This cop makes sure that OS conditionals are consistent.
// 627:       class OnSystemConditionals < FormulaCop
// 628:         include OnSystemConditionalsHelper
// 629:         extend AutoCorrector
// 630:
// 631:         NO_ON_SYSTEM_METHOD_NAMES = [:install, :post_install].freeze
// 632:         NO_ON_SYSTEM_BLOCK_NAMES = [:service, :test].freeze
// 633:
// 634:         sig { override.params(formula_nodes: FormulaNodes).void }
// 635:         def audit_formula(formula_nodes)
// 636:           body_node = formula_nodes.body_node
// 637:
// 638:           NO_ON_SYSTEM_METHOD_NAMES.each do |formula_method_name|
// 639:             method_node = find_method_def(body_node, formula_method_name)
// 640:             audit_on_system_blocks(method_node, formula_method_name) if method_node
// 641:           end
// 642:           NO_ON_SYSTEM_BLOCK_NAMES.each do |formula_block_name|
// 643:             block_node = find_block(body_node, formula_block_name)
// 644:             audit_on_system_blocks(block_node, formula_block_name) if block_node
// 645:           end
// 646:
// 647:           # Don't restrict OS.mac? or OS.linux? usage in taps; they don't care
// 648:           # as much as we do about e.g. formulae.brew.sh generation, often use
// 649:           # platform-specific URLs and we don't want to add DSLs to support
// 650:           # that case.
// 651:           return if formula_tap != "homebrew-core"
// 652:
// 653:           audit_arch_conditionals(body_node,
// 654:                                   allowed_methods: NO_ON_SYSTEM_METHOD_NAMES,
// 655:                                   allowed_blocks:  NO_ON_SYSTEM_BLOCK_NAMES)
// 656:
// 657:           audit_base_os_conditionals(body_node,
// 658:                                      allowed_methods: NO_ON_SYSTEM_METHOD_NAMES,
// 659:                                      allowed_blocks:  NO_ON_SYSTEM_BLOCK_NAMES)
// 660:
// 661:           audit_macos_version_conditionals(body_node,
// 662:                                            allowed_methods:     NO_ON_SYSTEM_METHOD_NAMES,
// 663:                                            allowed_blocks:      NO_ON_SYSTEM_BLOCK_NAMES,
// 664:                                            recommend_on_system: true)
// 665:         end
// 666:       end
// 667:
// 668:       # This cop makes sure the `MacOS` module is not used in Linux-facing formula code.
// 669:       class MacOSOnLinux < FormulaCop
// 670:         include OnSystemConditionalsHelper
// 671:
// 672:         ON_MACOS_BLOCKS = T.let(
// 673:           [:macos, *MACOS_VERSION_OPTIONS].map { |os| :"on_#{os}" }.freeze,
// 674:           T::Array[Symbol],
// 675:         )
// 676:
// 677:         sig { override.params(formula_nodes: FormulaNodes).void }
// 678:         def audit_formula(formula_nodes)
// 679:           audit_macos_references(formula_nodes.body_node,
// 680:                                  allowed_methods: OnSystemConditionals::NO_ON_SYSTEM_METHOD_NAMES,
// 681:                                  allowed_blocks:  OnSystemConditionals::NO_ON_SYSTEM_BLOCK_NAMES + ON_MACOS_BLOCKS)
// 682:         end
// 683:       end
// 684:
// 685:       # This cop makes sure that the `generate_completions_from_executable` DSL is used.
// 686:       class GenerateCompletionsDSL < FormulaCop
// 687:         extend AutoCorrector
// 688:
// 689:         sig { override.params(formula_nodes: FormulaNodes).void }
// 690:         def audit_formula(formula_nodes)
// 691:           install = find_method_def(formula_nodes.body_node, :install)
// 692:           return if install.blank?
// 693:
// 694:           correctable_shell_completion_node(install) do |node, shell, base_name, executable, subcommand,
// 695:                                                         shell_parameter|
// 696:             # generate_completions_from_executable only applicable if shell is passed
// 697:             next unless shell_parameter.match?(/(bash|zsh|fish|pwsh)/)
// 698:
// 699:             base_name = base_name.delete_prefix("_").delete_suffix(".fish")
// 700:             shell = shell.to_s.delete_suffix("_completion").to_sym
// 701:             shell_parameter_stripped = shell_parameter
// 702:                                        .delete_suffix("bash")
// 703:                                        .delete_suffix("zsh")
// 704:                                        .delete_suffix("fish")
// 705:                                        .delete_suffix("pwsh")
// 706:             shell_parameter_format = if shell_parameter_stripped.empty?
// 707:               nil
// 708:             elsif shell_parameter_stripped == "--"
// 709:               :flag
// 710:             elsif shell_parameter_stripped == "--shell="
// 711:               :arg
// 712:             else
// 713:               shell_parameter_stripped
// 714:             end
// 715:
// 716:             replacement_args = %w[]
// 717:             replacement_args << executable.source
// 718:             replacement_args << subcommand.source
// 719:             replacement_args << "base_name: \"#{base_name}\"" if base_name != @formula_name
// 720:             replacement_args << "shells: [:#{shell}]"
// 721:             unless shell_parameter_format.nil?
// 722:               replacement_args << "shell_parameter_format: #{shell_parameter_format.inspect}"
// 723:             end
// 724:
// 725:             @offensive_node = node
// 726:             replacement = "generate_completions_from_executable(#{replacement_args.join(", ")})"
// 727:
// 728:             problem "Use `#{replacement}` instead of `#{@offensive_node.source}`." do |corrector|
// 729:               corrector.replace(@offensive_node.source_range, replacement)
// 730:             end
// 731:           end
// 732:
// 733:           shell_completion_node(install) do |node|
// 734:             next if node.source.include?("<<~") # skip heredoc completion scripts
// 735:             next if node.source.match?(/{.*=>.*}/) # skip commands needing custom ENV variables
// 736:
// 737:             offending_node(node)
// 738:             problem "Use `generate_completions_from_executable` DSL instead of `#{T.must(@offensive_node).source}`."
// 739:           end
// 740:         end
// 741:
// 742:         # match ({bash,zsh,fish}_completion/"_?foo{.fish}?").write
// 743:         # Utils.safe_popen_read(foo, subcommand, shell_parameter)
// 744:         def_node_search :correctable_shell_completion_node, <<~EOS
// 745:           $(send
// 746:           (begin
// 747:             (send
// 748:               (send nil? ${:bash_completion :zsh_completion :fish_completion}) :/
// 749:               (str $_))) :write
// 750:           (send
// 751:             (const nil? :Utils) :safe_popen_read
// 752:             $(send
// 753:               (send nil? :bin) :/
// 754:               (str _))
// 755:             $(str _)
// 756:             (str $_)))
// 757:         EOS
// 758:
// 759:         # matches ({bash,zsh,fish}_completion/"_?foo{.fish}?").write output
// 760:         def_node_search :shell_completion_node, <<~EOS
// 761:           $(send
// 762:             (begin
// 763:               (send
// 764:                 (send nil? {:bash_completion :zsh_completion :fish_completion}) :/
// 765:                 (str _))) :write _)
// 766:         EOS
// 767:       end
// 768:
// 769:       # This cop makes sure that the `generate_completions_from_executable` DSL is used with only
// 770:       # a single, combined call for all shells.
// 771:       class SingleGenerateCompletionsDSLCall < FormulaCop
// 772:         extend AutoCorrector
// 773:
// 774:         sig { override.params(formula_nodes: FormulaNodes).void }
// 775:         def audit_formula(formula_nodes)
// 776:           install = find_method_def(formula_nodes.body_node, :install)
// 777:           return if install.blank?
// 778:
// 779:           methods = find_every_method_call_by_name(install, :generate_completions_from_executable)
// 780:           return if methods.length <= 1
// 781:
// 782:           offenses = []
// 783:           shells = []
// 784:           methods.each do |method|
// 785:             next unless method.source.include?("shells:")
// 786:
// 787:             shell = method.source[/shells: \[(:bash|:zsh|:fish)\]/, 1]
// 788:             next if shell.nil?
// 789:
// 790:             shells << shell
// 791:             offenses << method
// 792:           end
// 793:
// 794:           return if offenses.blank?
// 795:
// 796:           T.must(offenses[0...-1]).each_with_index do |node, i|
// 797:             # commands have to be the same to be combined
// 798:             # send_type? matches `bin/"foo"`, str_type? matches remaining command parts,
// 799:             # the rest are kwargs we need to filter out
// 800:             method_commands = node.arguments.filter { |arg| arg.send_type? || arg.str_type? }
// 801:             next_method_commands = offenses[i + 1].arguments.filter { |arg| arg.send_type? || arg.str_type? }
// 802:             if method_commands != next_method_commands
// 803:               shells.delete_at(i)
// 804:               next
// 805:             end
// 806:
// 807:             @offensive_node = node
// 808:             problem "Use a single `generate_completions_from_executable` " \
// 809:                     "call combining all specified shells." do |corrector|
// 810:               # adjust range by -4 and +1 to also include & remove leading spaces and trailing \n
// 811:               corrector.replace(@offensive_node.source_range.adjust(begin_pos: -4, end_pos: 1), "")
// 812:             end
// 813:           end
// 814:
// 815:           return if shells.length <= 1 # no shells to combine left
// 816:
// 817:           @offensive_node = offenses.fetch(-1)
// 818:           replacement = if (%w[:bash :zsh :fish] - shells).empty?
// 819:             @offensive_node.source
// 820:                            .sub(/shells: \[(:bash|:zsh|:fish)\]/, "")
// 821:                            .sub(", )", ")") # clean up dangling trailing comma
// 822:                            .sub("(, ", "(") # clean up dangling leading comma
// 823:                            .sub(", , ", ", ") # clean up dangling enclosed comma
// 824:           else
// 825:             @offensive_node.source.sub(/shells: \[(:bash|:zsh|:fish)\]/,
// 826:                                        "shells: [#{shells.join(", ")}]")
// 827:           end
// 828:
// 829:           problem "Use `#{replacement}` instead of `#{@offensive_node.source}`." do |corrector|
// 830:             corrector.replace(@offensive_node.source_range, replacement)
// 831:           end
// 832:         end
// 833:       end
// 834:
// 835:       # This cop makes sure that the default shells are not passed to
// 836:       # `generate_completions_from_executable`, as they are the default.
// 837:       class RedundantGenerateCompletionsShells < FormulaCop
// 838:         extend AutoCorrector
// 839:         include RangeHelp
// 840:
// 841:         sig { override.params(formula_nodes: FormulaNodes).void }
// 842:         def audit_formula(formula_nodes)
// 843:           install = find_method_def(formula_nodes.body_node, :install)
// 844:           return if install.blank?
// 845:
// 846:           find_every_method_call_by_name(install, :generate_completions_from_executable).each do |method|
// 847:             kwargs = method.arguments.last
// 848:             next unless kwargs&.hash_type?
// 849:
// 850:             pairs = T.cast(kwargs, RuboCop::AST::HashNode).pairs
// 851:             shells_pair = pairs.find { |pair| pair.key.sym_type? && pair.key.value == :shells }
// 852:             next if shells_pair.nil?
// 853:
// 854:             shells_node = shells_pair.value
// 855:             next unless shells_node.array_type?
// 856:             next unless shells_node.values.all?(&:sym_type?)
// 857:
// 858:             # The default shells depend on `shell_parameter_format`, so skip non-literal values.
// 859:             format_node = pairs.find { |pair| pair.key.sym_type? && pair.key.value == :shell_parameter_format }&.value
// 860:             next if format_node && !format_node.sym_type? && !format_node.str_type?
// 861:
// 862:             shells = shells_node.values.map(&:value)
// 863:             default_shells = ::Utils::ShellCompletion.default_completion_shells(format_node&.value)
// 864:             # Flag only when the passed shells are exactly the defaults for this format.
// 865:             next if (default_shells - shells).any? || (shells - default_shells).any?
// 866:
// 867:             offending_node(shells_pair)
// 868:             problem "Passing the default shells to `generate_completions_from_executable` is redundant" do |corrector|
// 869:               corrector.remove(
// 870:                 range_with_surrounding_comma(
// 871:                   range_with_surrounding_space(range: shells_pair.source_range, side: :left),
// 872:                   :left,
// 873:                 ),
// 874:               )
// 875:             end
// 876:           end
// 877:         end
// 878:       end
// 879:
// 880:       # This cop checks for other miscellaneous style violations.
// 881:       class Miscellaneous < FormulaCop
// 882:         sig { override.params(formula_nodes: FormulaNodes).void }
// 883:         def audit_formula(formula_nodes)
// 884:           return if (body_node = formula_nodes.body_node).nil?
// 885:
// 886:           # FileUtils is included in Formula
// 887:           # encfs modifies a file with this name, so check for some leading characters
// 888:           find_instance_method_call(body_node, "FileUtils", nil) do |method_node|
// 889:             problem "No need for `FileUtils.` before `#{method_node.method_name}`"
// 890:           end
// 891:
// 892:           # Check for long inreplace block vars
// 893:           find_all_blocks(body_node, :inreplace) do |node|
// 894:             block_arg = node.arguments.children.first
// 895:             next if block_arg.source.size <= 1
// 896:
// 897:             problem "`inreplace <filenames> do |s|` is preferred over `|#{block_arg.source}|`."
// 898:           end
// 899:
// 900:           [:rebuild, :version_scheme].each do |method_name|
// 901:             find_method_with_args(body_node, method_name, 0) do
// 902:               problem "`#{method_name} 0` should be removed"
// 903:             end
// 904:           end
// 905:
// 906:           find_instance_call(body_node, "ARGV") do |_method_node|
// 907:             problem "Use `build.with?` or `build.without?` instead of `ARGV` to check options"
// 908:           end
// 909:
// 910:           find_instance_method_call(body_node, :man, :+) do |method|
// 911:             next unless (match = regex_match_group(parameters(method).fetch(0), /^man[1-8]$/))
// 912:
// 913:             problem "`#{method.source}` should be `#{match[0]}`"
// 914:           end
// 915:
// 916:           # Avoid hard-coding compilers
// 917:           find_every_method_call_by_name(body_node, :system).each do |method|
// 918:             param = parameters(method).fetch(0)
// 919:             if (match = regex_match_group(param, %r{^(/usr/bin/)?(gcc|clang|cc|c[89]9)(\s|$)}))
// 920:               problem "Use `\#{ENV.cc}` instead of hard-coding `#{match[2]}`"
// 921:             elsif (match = regex_match_group(param, %r{^(/usr/bin/)?((g|clang|c)\+\+)(\s|$)}))
// 922:               problem "Use `\#{ENV.cxx}` instead of hard-coding `#{match[2]}`"
// 923:             end
// 924:           end
// 925:
// 926:           find_instance_method_call(body_node, "ENV", :[]=) do |method|
// 927:             param = parameters(method).fetch(1)
// 928:             if (match = regex_match_group(param, %r{^(/usr/bin/)?(gcc|clang|cc|c[89]9)(\s|$)}))
// 929:               problem "Use `\#{ENV.cc}` instead of hard-coding `#{match[2]}`"
// 930:             elsif (match = regex_match_group(param, %r{^(/usr/bin/)?((g|clang|c)\+\+)(\s|$)}))
// 931:               problem "Use `\#{ENV.cxx}` instead of hard-coding `#{match[2]}`"
// 932:             end
// 933:           end
// 934:
// 935:           # Prefer formula path shortcuts in strings
// 936:           formula_path_strings(body_node, :share) do |p|
// 937:             next unless (match = regex_match_group(p, %r{^(/(man))/?}))
// 938:
// 939:             problem "`\#{share}#{match[1]}` should be `\#{#{match[2]}}`"
// 940:           end
// 941:
// 942:           formula_path_strings(body_node, :prefix) do |p|
// 943:             if (match = regex_match_group(p, %r{^(/share/(info|man))$}))
// 944:               problem ["`#", "{prefix}", match[1], '` should be `#{', match[2], "}`"].join
// 945:             end
// 946:             if (match = regex_match_group(p, %r{^((/share/man/)(man[1-8]))}))
// 947:               problem ["`#", "{prefix}", match[1], '` should be `#{', match[3], "}`"].join
// 948:             end
// 949:             if (match = regex_match_group(p, %r{^(/(bin|include|libexec|lib|sbin|share|Frameworks))}i))
// 950:               # match[2] must exist because of the previous line
// 951:               problem ["`#", "{prefix}", match[1], '` should be `#{', T.must(match[2]).downcase, "}`"].join
// 952:             end
// 953:           end
// 954:
// 955:           find_every_method_call_by_name(body_node, :depends_on).each do |method|
// 956:             key, value = destructure_hash(parameters(method).fetch(0))
// 957:             next if key.nil? || value.nil?
// 958:             next unless (match = regex_match_group(value, /^(lua|perl|python|ruby)(\d*)/))
// 959:
// 960:             problem "#{match[1]} modules should be vendored rather than using deprecated `#{method.source}`"
// 961:           end
// 962:
// 963:           find_every_method_call_by_name(body_node, :system).each do |method|
// 964:             next unless (match = regex_match_group(parameters(method).fetch(0), /^(env|export)(\s+)?/))
// 965:
// 966:             problem "Use `ENV` instead of invoking `#{match[1]}` to modify the environment"
// 967:           end
// 968:
// 969:           find_every_method_call_by_name(body_node, :depends_on).each do |method|
// 970:             param = parameters(method).fetch(0)
// 971:             dep, option_child_nodes = hash_dep(param)
// 972:             next if dep.nil? || option_child_nodes.empty?
// 973:
// 974:             option_child_nodes.each do |option|
// 975:               find_strings(option).each do |dependency|
// 976:                 next unless (match = regex_match_group(dependency, /(with(out)?-\w+|c\+\+11)/))
// 977:
// 978:                 problem "Dependency '#{string_content(dep)}' should not use option `#{match[0]}`"
// 979:               end
// 980:             end
// 981:           end
// 982:
// 983:           find_instance_method_call(body_node, :version, :==) do |method|
// 984:             next unless parameters_passed?(method, ["HEAD"])
// 985:
// 986:             problem "Use `build.head?` instead of inspecting `version`"
// 987:           end
// 988:
// 989:           find_instance_method_call(body_node, "ARGV", :include?) do |method|
// 990:             next unless parameters_passed?(method, ["--HEAD"])
// 991:
// 992:             problem "Use `if build.head?` instead"
// 993:           end
// 994:
// 995:           find_const(body_node, "MACOS_VERSION") do
// 996:             problem "Use `MacOS.version` instead of `MACOS_VERSION`"
// 997:           end
// 998:
// 999:           find_const(body_node, "MACOS_FULL_VERSION") do
// 1000:             problem "Use `MacOS.full_version` instead of `MACOS_FULL_VERSION`"
// 1001:           end
// 1002:
// 1003:           conditional_dependencies(body_node) do |node, method, param, dep_node|
// 1004:             dep = string_content(dep_node)
// 1005:             if node.if?
// 1006:               if (method == :include? && regex_match_group(param, /^with-#{dep}$/)) ||
// 1007:                  (method == :with? && regex_match_group(param, /^#{dep}$/))
// 1008:                 offending_node(dep_node.parent)
// 1009:                 problem "Replace `#{node.source}` with `#{dep_node.parent.source} => :optional`"
// 1010:               end
// 1011:             elsif node.unless?
// 1012:               if (method == :include? && regex_match_group(param, /^without-#{dep}$/)) ||
// 1013:                  (method == :without? && regex_match_group(param, /^#{dep}$/))
// 1014:                 offending_node(dep_node.parent)
// 1015:                 problem "Replace `#{node.source}` with `#{dep_node.parent.source} => :recommended`"
// 1016:               end
// 1017:             end
// 1018:           end
// 1019:
// 1020:           find_method_with_args(body_node, :fails_with, :llvm) do
// 1021:             problem "`fails_with :llvm` is now a no-op and should be removed"
// 1022:           end
// 1023:
// 1024:           find_method_with_args(body_node, :needs, :openmp) do
// 1025:             problem "`needs :openmp` should be replaced with `depends_on \"gcc\"`"
// 1026:           end
// 1027:
// 1028:           find_method_with_args(body_node, :system, /^(otool|install_name_tool|lipo)/) do
// 1029:             problem "Use ruby-macho instead of calling #{T.must(@offensive_node).source}"
// 1030:           end
// 1031:
// 1032:           problem "Use new-style test definitions (`test do`)" if find_method_def(body_node, :test)
// 1033:
// 1034:           find_method_with_args(body_node, :skip_clean, :all) do
// 1035:             problem "`skip_clean :all` is deprecated; brew no longer strips symbols. " \
// 1036:                     "Pass explicit paths to prevent Homebrew from removing empty folders."
// 1037:           end
// 1038:
// 1039:           if find_method_def(processed_source.ast)
// 1040:             raise "unexpected nil value for @offensive_node" unless @offensive_node
// 1041:
// 1042:             problem "Define method `#{method_name(@offensive_node)}` in the class body, not at the top-level"
// 1043:           end
// 1044:
// 1045:           find_instance_method_call(body_node, "ENV", :runtime_cpu_detection) do
// 1046:             next if tap_style_exception? :runtime_cpu_detection_allowlist
// 1047:
// 1048:             problem "Formulae should be verified as having support for runtime hardware detection before " \
// 1049:                     "using `ENV.runtime_cpu_detection`."
// 1050:           end
// 1051:
// 1052:           find_every_method_call_by_name(body_node, :depends_on).each do |method|
// 1053:             next unless method_called?(method, :new)
// 1054:
// 1055:             problem "`depends_on` can take requirement classes instead of instances"
// 1056:           end
// 1057:
// 1058:           find_instance_method_call(body_node, "ENV", :[]) do |method|
// 1059:             next unless modifier?(method.parent)
// 1060:
// 1061:             param = parameters(method).first
// 1062:             next unless node_equals?(param, "CI")
// 1063:
// 1064:             problem 'Don\'t use `ENV["CI"]` for Homebrew CI checks.'
// 1065:           end
// 1066:
// 1067:           find_instance_method_call(body_node, "Dir", :[]) do |method|
// 1068:             next if parameters(method).size != 1
// 1069:
// 1070:             path = parameters(method).fetch(0)
// 1071:             next unless path.str_type?
// 1072:             next unless (match = regex_match_group(path, /^[^*{},]+$/))
// 1073:
// 1074:             problem "`Dir([\"#{string_content(path)}\"])` is unnecessary; just use `#{match[0]}`"
// 1075:           end
// 1076:
// 1077:           fileutils_methods = Regexp.new(
// 1078:             FileUtils.singleton_methods(false)
// 1079:                      .map { |m| "(?-mix:^#{Regexp.escape(m)}$)" }
// 1080:                      .join("|"),
// 1081:           )
// 1082:           find_every_method_call_by_name(body_node, :system).each do |method|
// 1083:             param = parameters(method).fetch(0)
// 1084:             next unless (match = regex_match_group(param, fileutils_methods))
// 1085:
// 1086:             problem "Use the `#{match}` Ruby method instead of `#{method.source}`"
// 1087:           end
// 1088:         end
// 1089:
// 1090:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 1091:         def modifier?(node)
// 1092:           return false unless node.if_type?
// 1093:
// 1094:           T.cast(node, RuboCop::AST::IfNode).modifier_form?
// 1095:         end
// 1096:
// 1097:         def_node_search :conditional_dependencies, <<~EOS
// 1098:           {$(if (send (send nil? :build) ${:include? :with? :without?} $(str _))
// 1099:               (send nil? :depends_on $({str sym} _)) nil?)
// 1100:
// 1101:            $(if (send (send nil? :build) ${:include? :with? :without?} $(str _)) nil?
// 1102:               (send nil? :depends_on $({str sym} _)))}
// 1103:         EOS
// 1104:
// 1105:         def_node_matcher :hash_dep, <<~EOS
// 1106:           (hash (pair $(str _) $...))
// 1107:         EOS
// 1108:
// 1109:         def_node_matcher :destructure_hash, <<~EOS
// 1110:           (hash (pair $(str _) $(sym _)))
// 1111:         EOS
// 1112:
// 1113:         def_node_search :formula_path_strings, <<~EOS
// 1114:           {(dstr (begin (send nil? %1)) $(str _ ))
// 1115:            (dstr _ (begin (send nil? %1)) $(str _ ))}
// 1116:         EOS
// 1117:       end
// 1118:     end
// 1119:
// 1120:     module FormulaAuditStrict
// 1121:       # This cop makes sure that no build-time checks are performed.
// 1122:       class MakeCheck < FormulaCop
// 1123:         sig { override.params(formula_nodes: FormulaNodes).void }
// 1124:         def audit_formula(formula_nodes)
// 1125:           return if formula_tap != "homebrew-core"
// 1126:
// 1127:           # Avoid build-time checks in homebrew/core
// 1128:           find_every_method_call_by_name(formula_nodes.body_node, :system).each do |method|
// 1129:             next if @formula_name&.start_with?("lib")
// 1130:             next if tap_style_exception? :make_check_allowlist
// 1131:
// 1132:             params = parameters(method)
// 1133:             next unless node_equals?(params[0], "make")
// 1134:
// 1135:             params[1..]&.each do |arg|
// 1136:               next unless regex_match_group(arg, /^(checks?|tests?)$/)
// 1137:
// 1138:               @offensive_node = method
// 1139:               problem "Formulae in homebrew/core (except e.g. cryptography, libraries) " \
// 1140:                       "should not run build-time checks"
// 1141:             end
// 1142:           end
// 1143:         end
// 1144:       end
// 1145:
// 1146:       # This cop ensures that new formulae depending on removed Requirements are not used.
// 1147:       class Requirements < FormulaCop
// 1148:         sig { override.params(_formula_nodes: FormulaNodes).void }
// 1149:         def audit_formula(_formula_nodes)
// 1150:           problem "Formulae should depend on a versioned `openjdk` instead of :java" if depends_on? :java
// 1151:           problem "Formulae should depend on specific X libraries instead of :x11" if depends_on? :x11
// 1152:           problem "Formulae should not depend on :osxfuse" if depends_on? :osxfuse
// 1153:           problem "Formulae should not depend on :tuntap" if depends_on? :tuntap
// 1154:         end
// 1155:       end
// 1156:
// 1157:       # This cop makes sure that formulae build with `rust` instead of `rustup`.
// 1158:       class RustCheck < FormulaCop
// 1159:         extend AutoCorrector
// 1160:
// 1161:         sig { override.params(formula_nodes: FormulaNodes).void }
// 1162:         def audit_formula(formula_nodes)
// 1163:           return if (body_node = formula_nodes.body_node).nil?
// 1164:
// 1165:           # Enforce use of `rust` for rust dependency in core
// 1166:           return if formula_tap != "homebrew-core"
// 1167:
// 1168:           find_method_with_args(body_node, :depends_on, "rustup") do
// 1169:             problem "Formulae in homebrew/core should use `depends_on \"rust\"` " \
// 1170:                     "instead of `#{T.must(@offensive_node).source}`." do |corrector|
// 1171:               corrector.replace(T.must(@offensive_node).source_range, "depends_on \"rust\"")
// 1172:             end
// 1173:           end
// 1174:
// 1175:           [:build, [:build, :test], [:test, :build]].each do |type|
// 1176:             find_method_with_args(body_node, :depends_on, "rustup" => type) do
// 1177:               problem "Formulae in homebrew/core should use `depends_on \"rust\" => #{type}` " \
// 1178:                       "instead of `#{T.must(@offensive_node).source}`." do |corrector|
// 1179:                 corrector.replace(T.must(@offensive_node).source_range, "depends_on \"rust\" => #{type}")
// 1180:               end
// 1181:             end
// 1182:           end
// 1183:
// 1184:           install_node = find_method_def(body_node, :install)
// 1185:           return if install_node.blank?
// 1186:
// 1187:           find_every_method_call_by_name(install_node, :system).each do |method|
// 1188:             param = parameters(method).first
// 1189:             next if param.blank?
// 1190:             # FIXME: Handle Pathname parameters (e.g. `system bin/"rustup"`).
// 1191:             next if regex_match_group(param, /rustup$/).blank?
// 1192:
// 1193:             problem "Formula in homebrew/core should not use `rustup` at build-time."
// 1194:           end
// 1195:         end
// 1196:       end
// 1197:     end
// 1198:   end
// 1199: end
