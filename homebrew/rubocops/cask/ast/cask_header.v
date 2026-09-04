module ast

import ruby

// Translated from Homebrew/brew `rubocops/cask/ast/cask_header.rb`.
pub struct CaskHeader {
pub:
	method_source string
	begin_pos     int
	end_pos       int
	cask_token    string
	hash_source   string
	hash_begin    int
	hash_end      int
}

fn cask_header_expression_end(line string, begin_pos int) int {
	mut quote := u8(0)
	mut escaped := false
	mut depth := 0
	mut cursor := begin_pos
	for cursor < line.len {
		character := line[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
		} else if character in [`'`, `"`] {
			quote = character
		} else if character in [`(`, `[`, `{`] {
			depth++
		} else if character in [`)`, `]`, `}`] && depth > 0 {
			depth--
		} else if depth == 0 && line[cursor..].starts_with(' do') {
			return cursor
		} else if depth == 0 && character == `#` {
			return cursor
		}
		cursor++
	}
	return line.len
}

fn cask_header_quoted_end(source string, begin_pos int, limit int) ?int {
	if begin_pos >= limit || source[begin_pos] !in [`'`, `"`] {
		return none
	}
	quote := source[begin_pos]
	mut escaped := false
	mut cursor := begin_pos + 1
	for cursor < limit {
		if escaped {
			escaped = false
		} else if source[cursor] == `\\` {
			escaped = true
		} else if source[cursor] == quote {
			return cursor + 1
		}
		cursor++
	}
	return none
}

fn cask_header_decode_token(source string) string {
	if source.len < 2 {
		return ''
	}
	quote := source[0]
	mut decoded := []u8{}
	mut escaped := false
	for character in source[1..source.len - 1].bytes() {
		if escaped {
			if quote == `'` && character !in [`'`, `\\`] {
				decoded << `\\`
			}
			decoded << character
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else {
			decoded << character
		}
	}
	if escaped {
		decoded << `\\`
	}
	return decoded.bytestr()
}

pub fn parse_cask_header(source string) ?CaskHeader {
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		indent := line.len - line.trim_left(' \t').len
		if line[indent..].starts_with('cask') {
			after_method := indent + 'cask'.len
			if after_method < line.len && line[after_method] !in [` `, `\t`, `(`] {
				return none
			}
			expression_end := cask_header_expression_end(line, after_method)
			mut argument := after_method
			for argument < expression_end && line[argument] in [` `, `\t`, `(`] {
				argument++
			}
			token_end := cask_header_quoted_end(line, argument, expression_end) or { return none }
			token_source := line[argument..token_end]
			mut extra := token_end
			for extra < expression_end && line[extra] in [` `, `\t`, `,`] {
				extra++
			}
			mut hash_end := expression_end
			for hash_end > extra && line[hash_end - 1].is_space() {
				hash_end--
			}
			hash_source := if extra < hash_end && (line[extra] == `{` || line[extra..hash_end].contains(':')) {
				line[extra..hash_end]
			} else {
				''
			}
			return CaskHeader{
				method_source: line[indent..expression_end].trim_right(' \t')
				begin_pos: line_start + indent
				end_pos: line_start + expression_end
				cask_token: cask_header_decode_token(token_source)
				hash_source: hash_source
				hash_begin: if hash_source == '' { 0 } else { line_start + extra }
				hash_end: if hash_source == '' { 0 } else { line_start + hash_end }
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return none
}

fn cask_header_value(header CaskHeader) ruby.Value {
	return ruby.structured_value('RuboCop::Cask::AST::CaskHeader', header.cask_token, {
		'method_source': header.method_source
		'begin_pos':     header.begin_pos.str()
		'end_pos':       header.end_pos.str()
		'cask_token':    header.cask_token
		'hash_source':   header.hash_source
		'hash_begin':    header.hash_begin.str()
		'hash_end':      header.hash_end.str()
	})
}

fn cask_header_argument(args []ruby.Value) ?CaskHeader {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return parse_cask_header(source)
}
