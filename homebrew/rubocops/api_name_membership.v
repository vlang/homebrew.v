module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/api_name_membership.rb`.
pub const api_name_membership_message_template = 'Use `Homebrew::API.%s` instead of scanning `Homebrew::API.%s`.'

pub struct ApiNameMembershipMatch {
pub:
	api         string
	list        string
	argument    string
	method      string
	begin_pos   int
	end_pos     int
	predicate   string
	message     string
	replacement string
}

fn api_name_membership_identifier_byte(character u8) bool {
	return character.is_alnum() || character == `_`
}

fn api_name_membership_argument_end(source string, start int) ?int {
	mut cursor := start
	mut depth := 1
	mut quote := u8(0)
	mut escaped := false
	for cursor < source.len {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			cursor++
			continue
		}
		if character == `'` || character == `"` {
			quote = character
		} else if character == `(` || character == `[` || character == `{` {
			depth++
		} else if character == `)` || character == `]` || character == `}` {
			depth--
			if depth == 0 {
				return cursor
			}
		}
		cursor++
	}
	return none
}

fn api_name_membership_has_top_level_comma(argument string) bool {
	mut depth := 0
	mut quote := u8(0)
	mut escaped := false
	for character in argument.bytes() {
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
		if character == `'` || character == `"` {
			quote = character
		} else if character == `(` || character == `[` || character == `{` {
			depth++
		} else if character == `)` || character == `]` || character == `}` {
			depth--
		} else if character == `,` && depth == 0 {
			return true
		}
	}
	return false
}

pub fn match_api_name_membership(source string, start int) ?ApiNameMembershipMatch {
	if start < 0 || start >= source.len {
		return none
	}
	mut api := ''
	if source[start..].starts_with('::Homebrew::API.') {
		api = '::Homebrew::API'
	} else if source[start..].starts_with('Homebrew::API.') {
		api = 'Homebrew::API'
	} else {
		return none
	}
	if start > 0 && api_name_membership_identifier_byte(source[start - 1]) {
		return none
	}
	mut cursor := start + api.len + 1
	mut list := ''
	mut predicate := ''
	if source[cursor..].starts_with('formula_names') {
		list = 'formula_names'
		predicate = 'formula_name?'
	} else if source[cursor..].starts_with('cask_tokens') {
		list = 'cask_tokens'
		predicate = 'cask_token?'
	} else {
		return none
	}
	cursor += list.len
	if cursor >= source.len || source[cursor] != `.` {
		return none
	}
	cursor++
	mut method := ''
	if source[cursor..].starts_with('include?(') {
		method = 'include?'
	} else if source[cursor..].starts_with('exclude?(') {
		method = 'exclude?'
	} else {
		return none
	}
	cursor += method.len + 1
	argument_end := api_name_membership_argument_end(source, cursor) or { return none }
	argument := source[cursor..argument_end]
	if argument.trim_space() == '' || api_name_membership_has_top_level_comma(argument) {
		return none
	}
	message := api_name_membership_message_template.replace_once('%s', predicate).replace_once('%s', list)
	replacement := '${if method == 'exclude?' { '!' } else { '' }}${api}.${predicate}(${argument})'
	return ApiNameMembershipMatch{
		api: api
		list: list
		argument: argument
		method: method
		begin_pos: start
		end_pos: argument_end + 1
		predicate: predicate
		message: message
		replacement: replacement
	}
}

pub fn audit_api_name_memberships(source string) []ApiNameMembershipMatch {
	mut matches := []ApiNameMembershipMatch{}
	mut cursor := 0
	for cursor < source.len {
		if source[cursor..].starts_with('Homebrew::API.') || source[cursor..].starts_with('::Homebrew::API.') {
			if membership := match_api_name_membership(source, cursor) {
				matches << membership
				cursor = membership.end_pos
				continue
			}
		}
		cursor++
	}
	return matches
}

pub fn correct_api_name_memberships(source string) string {
	matches := audit_api_name_memberships(source)
	mut corrected := source
	if matches.len == 0 {
		return corrected
	}
	for index := matches.len - 1; index >= 0; index-- {
		membership := matches[index]
		corrected = corrected[..membership.begin_pos] + membership.replacement + corrected[membership.end_pos..]
	}
	return corrected
}

fn api_name_membership_value(membership ApiNameMembershipMatch, type_name string) ruby.Value {
	return ruby.structured_value(type_name, membership.replacement, {
		'api':         membership.api
		'list':        membership.list
		'argument':    membership.argument
		'method':      membership.method
		'predicate':   membership.predicate
		'message':     membership.message
		'replacement': membership.replacement
	})
}
