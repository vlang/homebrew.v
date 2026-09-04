module cask

import ruby

// Translated from Homebrew/brew `rubocops/cask/no_overrides.rb`.
pub const no_overrides_message_template = 'Do not use a top-level `%s` stanza as the default. Add it to an `on_{system}` block instead. Use `:or_older` or `:or_newer` to specify a range of macOS versions.'
pub const no_overrides_macos_message = 'Do not use a `depends_on macos:` stanza inside an `on_{system}` block. Add it once to specify the oldest macOS supported by any version in the cask.'

pub struct NoOverridesOffense {
pub:
	stanza      string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct NoOverridesCall {
	name        string
	begin_pos   int
	end_pos     int
	ancestors   []string
	opens_block bool
}

struct NoOverridesAnalysis {
	offenses []NoOverridesOffense
	names    []string
}

fn no_overrides_overridable_methods() []string {
	return ['appcast', 'arch', 'auto_updates', 'container', 'desc', 'homepage', 'os', 'sha256',
		'url', 'version']
}

fn no_overrides_on_system_methods() []string {
	return ['on_arm', 'on_intel', 'on_golden_gate', 'on_tahoe', 'on_sequoia', 'on_sonoma',
		'on_ventura', 'on_monterey', 'on_big_sur', 'on_catalina', 'on_macos', 'on_linux']
}

fn no_overrides_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn no_overrides_identifier_character(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn no_overrides_code_end(source string, line_start int, line_end int) int {
	mut cursor := line_start
	mut quote := u8(0)
	mut escaped := false
	mut interpolation_depth := 0
	for cursor < line_end {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if quote == `"` && character == `#` && cursor + 1 < line_end && source[cursor + 1] == `{` {
				interpolation_depth++
				cursor += 2
				continue
			} else if interpolation_depth > 0 && character == `}` {
				interpolation_depth--
			} else if interpolation_depth == 0 && character == quote {
				quote = 0
			}
		} else if character == `'` || character == `"` {
			quote = character
		} else if character == `#` {
			return cursor
		}
		cursor++
	}
	return line_end
}

fn no_overrides_leading_call(source string, line_start int, line_end int, ancestors []string) ?NoOverridesCall {
	code_end := no_overrides_code_end(source, line_start, line_end)
	mut begin_pos := line_start
	for begin_pos < code_end && (source[begin_pos] == ` ` || source[begin_pos] == `\t`) {
		begin_pos++
	}
	if begin_pos >= code_end || !no_overrides_identifier_start(source[begin_pos]) {
		return none
	}
	mut method_end := begin_pos + 1
	for method_end < code_end && no_overrides_identifier_character(source[method_end]) {
		method_end++
	}
	name := source[begin_pos..method_end]
	if name in ['end', 'else', 'elsif', 'when', 'rescue', 'ensure'] {
		return none
	}
	if method_end < code_end && !source[method_end].is_space() && source[method_end] !in [
		`(`,
		`{`,
	] {
		return none
	}
	mut end_pos := code_end
	for end_pos > method_end && (source[end_pos - 1] == ` ` || source[end_pos - 1] == `\t` || source[end_pos - 1] == `\r`) {
		end_pos--
	}
	code := source[begin_pos..end_pos]
	keyword_block := name in ['if', 'unless', 'case', 'begin', 'while', 'until', 'for', 'def', 'class',
		'module']
	return NoOverridesCall{
		name: name
		begin_pos: begin_pos
		end_pos: end_pos
		ancestors: ancestors.clone()
		opens_block: keyword_block || code.ends_with(' do') || code.contains(' do |')
	}
}

fn no_overrides_macos_value(source string, call NoOverridesCall) ?string {
	if call.name != 'depends_on' {
		return none
	}
	mut cursor := call.begin_pos + call.name.len
	for cursor < call.end_pos {
		if source[cursor] == `'` || source[cursor] == `"` {
			quote := source[cursor]
			cursor++
			mut escaped := false
			for cursor < call.end_pos {
				if escaped {
					escaped = false
				} else if source[cursor] == `\\` {
					escaped = true
				} else if source[cursor] == quote {
					cursor++
					break
				}
				cursor++
			}
			continue
		}
		if source[cursor..call.end_pos].starts_with('macos:') && (cursor == call.begin_pos || !no_overrides_identifier_character(source[cursor - 1])) {
			cursor += 'macos:'.len
			for cursor < call.end_pos && source[cursor].is_space() {
				cursor++
			}
			value_begin := cursor
			mut quote := u8(0)
			mut escaped := false
			mut nesting := 0
			for cursor < call.end_pos {
				character := source[cursor]
				if quote != 0 {
					if escaped {
						escaped = false
					} else if character == `\\` {
						escaped = true
					} else if character == quote {
						quote = 0
					}
				} else if character == `'` || character == `"` {
					quote = character
				} else if character in [`[`, `{`, `(`] {
					nesting++
				} else if character in [`]`, `}`, `)`] {
					if nesting == 0 {
						break
					}
					nesting--
				} else if nesting == 0 && character == `,` {
					break
				}
				cursor++
			}
			mut value_end := cursor
			for value_end > value_begin && source[value_end - 1].is_space() {
				value_end--
			}
			if value_begin < value_end {
				return source[value_begin..value_end]
			}
			return none
		}
		cursor++
	}
	return none
}

fn no_overrides_has_ancestor(call NoOverridesCall, name string) bool {
	return call.ancestors.contains(name)
}

fn no_overrides_root_system(call NoOverridesCall) string {
	if call.ancestors.len == 0 {
		return ''
	}
	// CaskHelp#on_system_methods only selects direct children of the cask block.
	index := if call.ancestors[0] == 'cask' { 1 } else { 0 }
	if index < call.ancestors.len && no_overrides_on_system_methods().contains(call.ancestors[index]) {
		return call.ancestors[index]
	}
	return ''
}

fn no_overrides_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if !result.contains(value) {
			result << value
		}
	}
	return result
}

fn no_overrides_calls(source string) []NoOverridesCall {
	mut calls := []NoOverridesCall{}
	mut ancestors := []string{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut content_start := line_start
		for content_start < line_end && (source[content_start] == ` ` || source[content_start] == `\t`) {
			content_start++
		}
		code_end := no_overrides_code_end(source, line_start, line_end)
		trimmed := source[content_start..code_end].trim_space()
		if trimmed == 'end' || trimmed.starts_with('end ') {
			if ancestors.len > 0 {
				ancestors.delete_last()
			}
		} else if call := no_overrides_leading_call(source, line_start, line_end, ancestors) {
			calls << call
			if call.opens_block {
				ancestors << call.name
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return calls
}

fn no_overrides_analyze(source string) NoOverridesAnalysis {
	calls := no_overrides_calls(source)
	mut top_level := []NoOverridesCall{}
	mut block_calls := []NoOverridesCall{}
	mut macos_versions := []string{}
	for call in calls {
		if call.ancestors.len == 1 && call.ancestors[0] == 'cask' {
			top_level << call
		}
		root_system := no_overrides_root_system(call)
		if root_system != '' {
			// The Ruby method's first traversal intentionally gathers every nested
			// `depends_on macos:` value before its livecheck/send exclusions.
			if macos := no_overrides_macos_value(source, call) {
				macos_versions << macos
			}
		}
		if root_system == '' || no_overrides_has_ancestor(call, 'livecheck') || call.name == 'livecheck' || no_overrides_on_system_methods().contains(call.name) || call.name in [
			'if',
			'unless',
			'case',
			'begin',
			'while',
			'until',
			'for',
			'def',
			'class',
			'module',
		] {
			continue
		}
		block_calls << call
	}
	allow_macos_depends := macos_versions.len > 1 && no_overrides_unique(macos_versions).len > 1
	mut offenses := []NoOverridesOffense{}
	mut names := []string{}
	for call in block_calls {
		if call.name == 'depends_on' {
			if _ := no_overrides_macos_value(source, call) {
				root := no_overrides_root_system(call)
				if root != 'on_macos' && !allow_macos_depends {
					offenses << NoOverridesOffense{
						stanza: call.name
						begin_pos: call.begin_pos
						end_pos: call.end_pos
						message: no_overrides_macos_message
					}
				}
			}
		}
		if !names.contains(call.name) {
			names << call.name
		}
	}
	for stanza in top_level {
		if no_overrides_overridable_methods().contains(stanza.name) && names.contains(stanza.name) {
			offenses << NoOverridesOffense{
				stanza: stanza.name
				begin_pos: stanza.begin_pos
				end_pos: stanza.end_pos
				message: no_overrides_message_template.replace('%s', stanza.name)
			}
		}
	}
	return NoOverridesAnalysis{
		offenses: offenses
		names: names
	}
}

pub fn audit_no_overrides(source string) []NoOverridesOffense {
	return no_overrides_analyze(source).offenses
}

// NoOverrides does not extend RuboCop's AutoCorrector at the pinned revision.
pub fn correct_no_overrides(source string) string {
	return source
}

fn no_overrides_offense_value(offense NoOverridesOffense) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', offense.message, {
		'stanza':      offense.stanza
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

fn no_overrides_node_ancestry(node ruby.Value) []string {
	path := if 'ancestry' in node.attributes {
		node.attributes['ancestry']
	} else {
		node.as_string()
	}
	return path.split('>').map(it.trim_space()).filter(it != '')
}

fn no_overrides_single_livecheck_node(node ruby.Value) bool {
	path := no_overrides_node_ancestry(node)
	return path.len >= 2 && path[path.len - 2] == 'livecheck'
}

fn no_overrides_multi_livecheck_node(node ruby.Value) bool {
	path := no_overrides_node_ancestry(node)
	return path.len >= 3 && path[path.len - 2] == 'begin' && path[path.len - 3] == 'livecheck'
}
