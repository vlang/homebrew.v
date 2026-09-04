module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/public_api_documentation.rb`.
pub const public_api_documentation_message = '`@api public` methods must have a descriptive YARD comment, not just the annotation.'
pub const public_api_documentation_missing_include_template = '`%s` contains `@api public` but is missing from `Style/Documentation.Include`.'
pub const public_api_documentation_extra_include_template = '`%s` is included in `Style/Documentation.Include` but does not contain `@api public`.'

pub struct PublicApiSourceComment {
pub:
	text      string
	line      int
	begin_pos int
	end_pos   int
}

pub struct PublicApiDocumentationContext {
pub:
	source                    string
	file_path                 string
	has_file_path             bool
	documentation_include     []string
	has_documentation_include bool
}

pub struct PublicApiDocumentationOffense {
pub:
	kind          string
	comment       string
	line          int
	file_path     string
	relative_path string
	begin_pos     int
	end_pos       int
	message       string
}

struct PublicApiLexerState {
mut:
	quote         u8
	escaped       bool
	percent_open  u8
	percent_close u8
	percent_depth int
	heredoc       string
	block_comment bool
}

fn public_api_paired_delimiter(delimiter u8) u8 {
	return match delimiter {
		`(` { `)` }
		`[` { `]` }
		`{` { `}` }
		`<` { `>` }
		else { delimiter }
	}
}

fn public_api_percent_literal(line string, position int) ?(u8, u8, int) {
	if position + 1 >= line.len || line[position] != `%` {
		return none
	}
	mut delimiter_position := position + 1
	if line[delimiter_position] in [`q`, `Q`, `r`, `w`, `W`, `x`, `i`, `I`, `s`] {
		delimiter_position++
	}
	if delimiter_position >= line.len || line[delimiter_position].is_alnum() || line[delimiter_position] == `_` || line[delimiter_position].is_space() {
		return none
	}
	open := line[delimiter_position]
	return open, public_api_paired_delimiter(open), delimiter_position + 1
}

fn public_api_regex_start(line string, position int) bool {
	if position + 1 < line.len && line[position + 1] == `/` {
		return false
	}
	mut previous := position - 1
	for previous >= 0 && line[previous].is_space() {
		previous--
	}
	return previous < 0 || line[previous] in [`=`, `(`, `[`, `{`, `,`, `:`, `!`, `&`, `|`, `?`,
		`;`]
}

fn public_api_skip_regex(line string, start int) int {
	mut position := start + 1
	mut escaped := false
	mut in_class := false
	for position < line.len {
		character := line[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == `[` {
			in_class = true
		} else if character == `]` {
			in_class = false
		} else if character == `/` && !in_class {
			return position + 1
		}
		position++
	}
	return line.len
}

fn public_api_heredoc_identifier(code string) string {
	mut search_from := 0
	for search_from + 2 <= code.len {
		relative := code[search_from..].index('<<') or { return '' }
		mut position := search_from + relative + 2
		if position < code.len && code[position] in [`-`, `~`] {
			position++
		}
		mut quote := u8(0)
		if position < code.len && code[position] in [`'`, `"`, `\``] {
			quote = code[position]
			position++
		}
		start := position
		if start < code.len && (code[start].is_letter() || code[start] == `_`) {
			for position < code.len && (code[position].is_alnum() || code[position] == `_`) {
				position++
			}
			if quote == 0 || (position < code.len && code[position] == quote) {
				return code[start..position]
			}
		}
		search_from = start + 1
	}
	return ''
}

fn public_api_comment_start(line string, mut state PublicApiLexerState) ?int {
	mut position := 0
	for position < line.len {
		character := line[position]
		if state.percent_depth > 0 {
			if state.escaped {
				state.escaped = false
			} else if character == `\\` {
				state.escaped = true
			} else if state.percent_open != state.percent_close && character == state.percent_open {
				state.percent_depth++
			} else if character == state.percent_close {
				state.percent_depth--
			}
			position++
			continue
		}
		if state.quote != 0 {
			if state.escaped {
				state.escaped = false
			} else if character == `\\` {
				state.escaped = true
			} else if character == state.quote {
				state.quote = 0
			}
			position++
			continue
		}
		if character in [`'`, `"`, `\``] {
			state.quote = character
			position++
			continue
		}
		if character == `%` {
			if open, close, after := public_api_percent_literal(line, position) {
				state.percent_open = open
				state.percent_close = close
				state.percent_depth = 1
				position = after
				continue
			}
		}
		if character == `/` && public_api_regex_start(line, position) {
			position = public_api_skip_regex(line, position)
			continue
		}
		if character == `#` {
			return position
		}
		position++
	}
	return none
}

pub fn public_api_source_comments(source string) []PublicApiSourceComment {
	mut comments := []PublicApiSourceComment{}
	mut state := PublicApiLexerState{}
	mut offset := 0
	for line_index, line in source.split('\n') {
		trimmed := line.trim_space()
		if state.heredoc != '' {
			if trimmed == state.heredoc {
				state.heredoc = ''
			}
			offset += line.len + 1
			continue
		}
		if state.block_comment {
			if line.starts_with('=end') {
				state.block_comment = false
			}
			offset += line.len + 1
			continue
		}
		if line.starts_with('=begin') {
			state.block_comment = true
			offset += line.len + 1
			continue
		}
		comment_start := public_api_comment_start(line, mut state) or { line.len }
		if comment_start < line.len {
			comments << PublicApiSourceComment{
				text: source[offset + comment_start..offset + line.len]
				line: line_index + 1
				begin_pos: offset + comment_start
				end_pos: offset + line.len
			}
		}
		heredoc := public_api_heredoc_identifier(line[..comment_start])
		if heredoc != '' {
			state.heredoc = heredoc
		}
		offset += line.len + 1
	}
	return comments
}

pub fn public_api_comment(text string) bool {
	trimmed := text.trim_space()
	return trimmed == '# @api public' || trimmed == '@api public'
}

pub fn public_api_descriptive_comment_preceding(source string, comment_line int) bool {
	lines := source.split('\n')
	mut line_index := comment_line - 2
	for line_index >= 0 {
		if line_index >= lines.len {
			return false
		}
		line := lines[line_index].trim_space()
		if !line.starts_with('#') {
			break
		}
		content := line[1..].trim_space()
		if content == '' || content.starts_with('@') {
			line_index--
			continue
		}
		return true
	}
	return false
}

pub fn public_api_relative_path(file_path string) string {
	needle := '/Library/Homebrew/'
	parts := file_path.split(needle)
	return if parts.len > 1 { parts[parts.len - 1] } else { file_path }
}

fn public_api_ast_or_buffer_range(source string, comments []PublicApiSourceComment) (int, int) {
	mut begin_pos := -1
	mut end_pos := -1
	mut offset := 0
	for line_index, line in source.split('\n') {
		mut code_end := line.len
		for comment in comments {
			if comment.line == line_index + 1 {
				code_end = comment.begin_pos - offset
				break
			}
		}
		mut first := 0
		for first < code_end && line[first].is_space() {
			first++
		}
		mut last := code_end
		for last > first && line[last - 1].is_space() {
			last--
		}
		if first < last {
			if begin_pos < 0 {
				begin_pos = offset + first
			}
			end_pos = offset + last
		}
		offset += line.len + 1
	}
	return if begin_pos < 0 { 0, source.len } else { begin_pos, end_pos }
}

pub fn audit_public_api_documentation(context PublicApiDocumentationContext) []PublicApiDocumentationOffense {
	comments := public_api_source_comments(context.source)
	api_comments := comments.filter(public_api_comment(it.text))
	mut offenses := []PublicApiDocumentationOffense{}
	for comment in api_comments {
		if !public_api_descriptive_comment_preceding(context.source, comment.line) {
			offenses << PublicApiDocumentationOffense{
				kind: 'missing_description'
				comment: comment.text
				line: comment.line
				begin_pos: comment.begin_pos
				end_pos: comment.end_pos
				message: public_api_documentation_message
			}
		}
	}
	if !context.has_documentation_include || !context.has_file_path {
		return offenses
	}
	relative_path := public_api_relative_path(context.file_path)
	included := relative_path in context.documentation_include
	if api_comments.len > 0 && !included {
		comment := api_comments[0]
		offenses << PublicApiDocumentationOffense{
			kind: 'missing_include'
			comment: comment.text
			line: comment.line
			file_path: context.file_path
			relative_path: relative_path
			begin_pos: comment.begin_pos
			end_pos: comment.end_pos
			message: public_api_documentation_missing_include_template.replace('%s', relative_path)
		}
	} else if api_comments.len == 0 && included {
		begin_pos, end_pos := public_api_ast_or_buffer_range(context.source, comments)
		offenses << PublicApiDocumentationOffense{
			kind: 'extra_include'
			file_path: context.file_path
			relative_path: relative_path
			begin_pos: begin_pos
			end_pos: end_pos
			message: public_api_documentation_extra_include_template.replace('%s', relative_path)
		}
	}
	return offenses
}

fn public_api_documentation_offense_value(offense PublicApiDocumentationOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':          offense.kind
		'comment':       offense.comment
		'line':          offense.line.str()
		'file_path':     offense.file_path
		'relative_path': offense.relative_path
		'begin_pos':     offense.begin_pos.str()
		'end_pos':       offense.end_pos.str()
		'message':       offense.message
	})
}
