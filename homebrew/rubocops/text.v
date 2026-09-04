module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/text.rb`.
pub struct FormulaTextContext {
pub:
	source       string
	tap          string
	formula_name string
}

pub struct FormulaTextPathMatch {
pub:
	source    string
	path      string
	begin_pos int
	end_pos   int
}

fn formula_text_lines_context(context FormulaTextContext) LinesContext {
	return LinesContext{
		source: context.source
		tap: context.tap
		formula_name: context.formula_name
	}
}

fn formula_text_line_offense(line LinesLine, start int, end int, message string, replacement string) LinesOffense {
	return LinesOffense{
		begin_pos: line.start + start
		end_pos: line.start + end
		message: message
		replacement: replacement
	}
}

fn formula_text_dependency_calls(context FormulaTextContext) []LinesCall {
	return lines_dependency_calls(formula_text_lines_context(context))
}

fn formula_text_has_dependency(calls []LinesCall, names []string) bool {
	return calls.any(lines_dependency_name(it) in names)
}

fn formula_text_dependency_offenses(calls []LinesCall, names []string, message string) []LinesOffense {
	mut offenses := []LinesOffense{}
	for call in calls {
		if lines_dependency_name(call) in names {
			offenses << lines_offense(call, message, '')
		}
	}
	return offenses
}

fn formula_text_find_definition(source string, name string) ?LinesOffense {
	for line in lines_source_lines(source) {
		trimmed := lines_code(line.text).trim_space()
		if trimmed == 'def ${name}' || trimmed.starts_with('def ${name}(') {
			start := line.text.index('def ${name}') or { continue }
			return LinesOffense{
				begin_pos: line.start + start
				end_pos: line.start + start + 'def ${name}'.len
			}
		}
	}
	return none
}

fn formula_text_direct_xcodebuild_calls(source string) []LinesCall {
	mut calls := []LinesCall{}
	for line_number, line in lines_source_lines(source) {
		code := lines_code(line.text)
		trimmed := code.trim_space()
		if !trimmed.starts_with('xcodebuild ') && !trimmed.starts_with('xcodebuild(') {
			continue
		}
		start := code.index('xcodebuild') or { continue }
		calls << LinesCall{
			target: 'xcodebuild'
			source: code[start..].trim_space()
			begin_pos: line.start + start
			end_pos: line.start + code.len
			line: line_number
		}
	}
	return calls
}

fn formula_text_quoted_end(source string, start int) int {
	if start < 0 || start >= source.len || source[start] !in [`'`, `"`] {
		return -1
	}
	quote := source[start]
	mut escaped := false
	for index := start + 1; index < source.len; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if character == `\\` {
			escaped = true
			continue
		}
		if character == quote {
			return index
		}
	}
	return -1
}

fn formula_text_plus_offenses(source string) []LinesOffense {
	mut offenses := []LinesOffense{}
	path_methods := ['prefix', 'bin', 'include', 'libexec', 'lib', 'sbin', 'share']
	prefix_paths := ['bin', 'include', 'libexec', 'lib', 'sbin', 'share', 'Frameworks']
	for line in lines_source_lines(source) {
		code := lines_code(line.text)
		for method in path_methods {
			mut from := 0
			for from < code.len {
				method_index := code.index_after(method, from) or { break }
				before_ok := method_index == 0 || !lines_identifier_byte(code[method_index - 1])
				mut cursor := method_index + method.len
				if !before_ok {
					from = cursor
					continue
				}
				for cursor < code.len && code[cursor].is_space() {
					cursor++
				}
				if cursor >= code.len || code[cursor] != `+` {
					from = method_index + method.len
					continue
				}
				cursor++
				for cursor < code.len && code[cursor].is_space() {
					cursor++
				}
				if cursor >= code.len || code[cursor] !in [`'`, `"`] {
					from = cursor
					continue
				}
				quoted_end := formula_text_quoted_end(code, cursor)
				if quoted_end < 0 {
					break
				}
				path := code[cursor + 1..quoted_end]
				expression := code[method_index..quoted_end + 1]
				if method == 'prefix' {
					for candidate in prefix_paths {
						if path == candidate || path.starts_with('${candidate}/') || path.starts_with('${candidate} ') {
							offenses << formula_text_line_offense(line, method_index, quoted_end + 1, 'Use `${candidate.to_lower()}` instead of `prefix + "${candidate}"`', '')
							break
						}
					}
				} else if path != '' {
					replacement := '${method}/"${path}"'
					offenses << formula_text_line_offense(line, method_index, quoted_end + 1, 'Use `${replacement}` instead of `${expression}`', replacement)
				}
				from = quoted_end + 1
			}
		}
	}
	return offenses
}

fn formula_text_interpolation_concat_offenses(source string) []LinesOffense {
	mut offenses := []LinesOffense{}
	mut from := 0
	for from < source.len {
		opening := source.index_after(r'#{', from) or { break }
		closing := source.index_after('}', opening + 2) or { break }
		expression := source[opening + 2..closing]
		if formula_text_interpolated_string_position(source, opening) && expression.contains('+') && (expression.contains('"') || expression.contains("'")) {
			offenses << LinesOffense{
				begin_pos: opening + 2
				end_pos: closing
				message: 'Do not concatenate paths in string interpolation'
			}
		}
		from = closing + 1
	}
	return offenses
}

fn formula_text_code_position(source string, position int) bool {
	line_start := source[..position].last_index('\n') or { -1 }
	mut quote := u8(0)
	mut escaped := false
	for index := line_start + 1; index < position; index++ {
		character := source[index]
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
			return false
		}
	}
	return quote == 0
}

fn formula_text_interpolated_string_position(source string, position int) bool {
	line_start := source[..position].last_index('\n') or { -1 }
	mut quote := u8(0)
	mut escaped := false
	for index := line_start + 1; index < position; index++ {
		character := source[index]
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
			return false
		}
	}
	if quote == `"` {
		return true
	}
	mut heredoc := ''
	for line in lines_source_lines(source) {
		if line.start >= line_start + 1 {
			break
		}
		trimmed := line.text.trim_space()
		if heredoc != '' {
			if trimmed == heredoc {
				heredoc = ''
			}
			continue
		}
		for opener in ['<<~', '<<-'] {
			if opener_index := line.text.index(opener) {
				mut token := line.text[opener_index + opener.len..].trim_space()
				if token.contains(' ') {
					token = token.all_before(' ')
				}
				heredoc = token.trim('"\'')
				break
			}
		}
	}
	return heredoc != ''
}

pub fn audit_formula_text(context FormulaTextContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	lines := lines_source_lines(context.source)

	for line in lines {
		trimmed := line.text.trim_space()
		if trimmed == 'require "formula"' || trimmed == "require 'formula'" {
			start := line.text.index('require') or { 0 }
			offenses << LinesOffense{
				begin_pos: line.start + start
				end_pos: line.newline_end
				message: '`${trimmed}` is now unnecessary'
				remove: true
			}
			break
		}
	}

	if plist := formula_text_find_definition(context.source, 'plist') {
		offenses << LinesOffense{
			begin_pos: plist.begin_pos
			end_pos: plist.end_pos
			message: '`def plist` is deprecated. Please use services instead: https://docs.brew.sh/Formula-Cookbook#service-files'
		}
	}

	dependencies := formula_text_dependency_calls(context)
	if formula_text_has_dependency(dependencies, ['openssl', 'openssl@3']) && formula_text_has_dependency(dependencies, [
		'libressl',
	]) {
		offenses << formula_text_dependency_offenses(dependencies, ['libressl'], 'Formulae should not depend on both OpenSSL and LibreSSL (even optionally).')
	}

	if context.tap == 'homebrew-core' {
		offenses << formula_text_dependency_offenses(dependencies, ['veclibfort', 'lapack'], 'Formulae in homebrew/core should use OpenBLAS as the default serial linear algebra library.')
		for call in lines_find_calls(context.source, 'keg_only') {
			if call.source.contains('HOMEBREW_PREFIX') {
				offenses << lines_offense(call, '`keg_only` reason should not include `\$HOMEBREW_PREFIX` as it creates confusing `brew info` output.', '')
			}
		}
	}

	for call in lines_find_calls(context.source, 'require') {
		if call.arguments.len > 0 && lines_unquote(call.arguments[0]) == 'language/go' {
			offenses << lines_offense(call, '`require "language/go"` is no longer necessary or correct', '')
		}
	}
	for call in lines_find_calls(context.source, 'Formula.factory') {
		offenses << lines_offense(call, '`Formula.factory(name)` is deprecated in favour of `Formula[name]`', '')
	}
	for call in lines_find_calls(context.source, 'revision') {
		if call.arguments.len > 0 && call.arguments[0] == '0' {
			offenses << lines_offense(call, '`revision 0` is unnecessary', '')
		}
	}
	for call in lines_find_calls(context.source, 'system') {
		if call.arguments.len == 0 {
			continue
		}
		command := lines_unquote(call.arguments[0])
		if command == 'xcodebuild' {
			offenses << lines_offense(call, "Use `xcodebuild *args` instead of `system 'xcodebuild', *args`", '')
		}
		if lines_position_in_named_region(context.source, call.begin_pos, 'install', true) {
			if command == 'go' && call.arguments.len > 1 && lines_unquote(call.arguments[1]) == 'get' {
				offenses << lines_offense(call, 'Do not use `go get`. Please ask upstream to implement Go vendoring', '')
			}
			if command == 'cargo' && call.arguments.len > 1 && lines_unquote(call.arguments[1]) == 'build' && !call.arguments.any(lines_unquote(it) == '--lib') {
				offenses << lines_offense(call, 'Use `"cargo", "install", *std_cargo_args`', '')
			}
		}
		if command == 'dep' && call.arguments.len > 1 && lines_unquote(call.arguments[1]) == 'ensure' && !call.arguments.any(lines_unquote(it).contains('vendor-only')) && context.formula_name != 'goose' {
			offenses << lines_offense(call, 'Use `"dep", "ensure", "-vendor-only"`', '')
		}
		if call.source.contains('make && make') {
			offenses << lines_offense(call, 'Use separate `make` calls', '')
		}
	}
	if !formula_text_has_dependency(dependencies, ['xcode']) {
		for call in formula_text_direct_xcodebuild_calls(context.source) {
			offenses << lines_offense(call, '`xcodebuild` needs an Xcode dependency', '')
		}
	}
	offenses << formula_text_plus_offenses(context.source)
	offenses << formula_text_interpolation_concat_offenses(context.source)
	return lines_analysis(formula_text_lines_context(context), offenses)
}

pub fn formula_text_path_starts_with(path string, starts_with string, bin bool) bool {
	if !path.starts_with(starts_with) {
		return false
	}
	if path.len == starts_with.len {
		return true
	}
	ending := path[starts_with.len]
	return ending == `/` || ending == ` ` || (bin && ending == `-`)
}

pub fn formula_text_path_starts_with_bin(path string, starts_with string) bool {
	return !path.contains(' ') && formula_text_path_starts_with(path, starts_with, true)
}

fn formula_text_word_array_at(source string, position int) bool {
	before := source[..position]
	opening := before.last_index('%W[') or { return false }
	closing := before.last_index(']') or { -1 }
	return opening > closing
}

pub fn formula_text_interpolated_path_matches(source string, receiver string, starts_with string,
	bin bool) []FormulaTextPathMatch {
	needle := r'#{' + receiver + '}'
	mut matches := []FormulaTextPathMatch{}
	mut from := 0
	for from < source.len {
		interpolation := source.index_after(needle, from) or { break }
		quote_start := source[..interpolation].last_index('"') or { -1 }
		if quote_start < 0 || quote_start + 1 != interpolation || !formula_text_code_position(source, quote_start) {
			from = interpolation + needle.len
			continue
		}
		quote_end := formula_text_quoted_end(source, quote_start)
		if quote_end < interpolation + needle.len {
			from = interpolation + needle.len
			continue
		}
		path := source[interpolation + needle.len..quote_end]
		matched := if bin {
			formula_text_path_starts_with_bin(path, starts_with)
		} else {
			formula_text_path_starts_with(path, starts_with, false)
		}
		if matched {
			matches << FormulaTextPathMatch{
				source: source[quote_start..quote_end + 1]
				path: path
				begin_pos: quote_start
				end_pos: quote_end + 1
			}
		}
		from = quote_end + 1
	}
	return matches
}

pub fn formula_text_share_path_matches(source string, starts_with string) []FormulaTextPathMatch {
	mut matches := []FormulaTextPathMatch{}
	mut from := 0
	for from < source.len {
		share := source.index_after('share/', from) or { break }
		quote_start := share + 'share/'.len
		boundary_ok := share == 0 || (!lines_identifier_byte(source[share - 1]) && source[share - 1] !in [
			`.`,
			`:`,
		])
		if !boundary_ok || !formula_text_code_position(source, share) || quote_start >= source.len || source[quote_start] !in [
			`'`,
			`"`,
		] {
			from = quote_start
			continue
		}
		quote_end := formula_text_quoted_end(source, quote_start)
		if quote_end < 0 {
			break
		}
		path := source[quote_start + 1..quote_end]
		if formula_text_path_starts_with(path, starts_with, false) {
			matches << FormulaTextPathMatch{
				source: source[share..quote_end + 1]
				path: path
				begin_pos: share
				end_pos: quote_end + 1
			}
		}
		from = quote_end + 1
	}
	return matches
}

pub fn audit_formula_text_strict(context FormulaTextContext) LinesAnalysis {
	mut offenses := []LinesOffense{}
	for call in lines_find_calls(context.source, 'env') {
		if call.arguments.len == 0 {
			continue
		}
		mode := lines_symbol(call.arguments[0])
		if mode == 'userpaths' {
			offenses << lines_offense(call, '`env :userpaths` in homebrew/core formulae is deprecated', '')
		}
	}
	for match_ in formula_text_share_path_matches(context.source, context.formula_name) {
		offenses << LinesOffense{
			begin_pos: match_.begin_pos
			end_pos: match_.end_pos
			message: 'Use `pkgshare` instead of `share/"${context.formula_name}"`'
		}
	}
	for match_ in formula_text_interpolated_path_matches(context.source, 'share', '/${context.formula_name}', false) {
		offenses << LinesOffense{
			begin_pos: match_.begin_pos
			end_pos: match_.end_pos
			message: 'Use `#{pkgshare}` instead of `#{share}/${context.formula_name}`'
		}
	}
	for match_ in formula_text_interpolated_path_matches(context.source, 'bin', '/${context.formula_name}', true) {
		if formula_text_word_array_at(context.source, match_.begin_pos) {
			continue
		}
		cmd := match_.path.trim_left('/')
		replacement := 'bin/"${cmd}"'
		offenses << LinesOffense{
			begin_pos: match_.begin_pos
			end_pos: match_.end_pos
			message: 'Use `${replacement}` instead of `${match_.source}`'
			replacement: replacement
		}
	}
	if context.tap == 'homebrew-core' {
		for call in lines_find_calls(context.source, 'env') {
			if call.arguments.len > 0 && lines_symbol(call.arguments[0]) == 'std' {
				offenses << lines_offense(call, '`env :std` in homebrew/core formulae is deprecated', '')
			}
		}
	}
	return lines_analysis(formula_text_lines_context(context), offenses)
}

fn formula_text_context_from_args(args []ruby.Value) ?FormulaTextContext {
	if args.len == 0 {
		return none
	}
	return FormulaTextContext{
		source: args[0].as_string()
		tap: if args.len > 1 { args[1].as_string() } else { '' }
		formula_name: if args.len > 2 { args[2].as_string() } else { '' }
	}
}

fn formula_text_matches_value(matches []FormulaTextPathMatch) ruby.Value {
	return ruby.array_value(matches.map(ruby.structured_value('RuboCop::AST::Node', it.source, {
		'path':      it.path
		'begin_pos': it.begin_pos.str()
		'end_pos':   it.end_pos.str()
	})))
}
