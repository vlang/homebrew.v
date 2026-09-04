module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/os_depends_on.rb`.
pub struct OsDependsOnPair {
pub:
	key           string
	key_is_symbol bool
	value_kind    string
	value         string
	source        string
	begin_pos     int
	end_pos       int
	value_begin   int
	value_end     int
}

pub struct OsDependsOnStanza {
pub:
	id         int
	method     string
	arguments  string
	source     string
	begin_pos  int
	end_pos    int
	line_begin int
	line_end   int
	full_begin int
	parent_id  int = -1
	is_block   bool
	pairs      []OsDependsOnPair
pub mut:
	full_end      int
	full_line_end int
}

pub struct OsDependsOnOffense {
pub:
	begin_pos      int
	end_pos        int
	message        string
	has_correction bool
	replacement    string
}

pub struct OsDependsOnAnalysis {
pub:
	stanzas   []OsDependsOnStanza
	offenses  []OsDependsOnOffense
	corrected string
}

struct OsDependsOnEdit {
mut:
	begin_pos   int
	end_pos     int
	replacement string
}

const os_depends_on_macos_only_stanzas = ['app', 'audio_unit_plugin', 'colorpicker', 'dictionary',
	'input_method', 'internet_plugin', 'keyboard_layout', 'mdimporter', 'pkg', 'prefpane', 'qlplugin',
	'screen_saver', 'service', 'suite', 'vst_plugin', 'vst3_plugin']
const os_depends_on_linux_only_stanzas = ['app_image']
const os_depends_on_platform_blocks = ['on_arm', 'on_intel', 'on_system']
const os_depends_on_macos_dependency_stanzas = ['macos', 'maximum_macos']
const os_depends_on_linux_dependency_stanzas = ['linux']

fn os_depends_on_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn os_depends_on_trim_range(source string, begin_pos int, end_pos int) (int, int) {
	mut start := begin_pos
	mut finish := end_pos
	for start < finish && source[start].is_space() {
		start++
	}
	for finish > start && source[finish - 1].is_space() {
		finish--
	}
	return start, finish
}

fn os_depends_on_code_end(source string, begin_pos int, end_pos int) int {
	mut quote := u8(0)
	mut escaped := false
	for index := begin_pos; index < end_pos; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			continue
		}
		if character in [`'`, `"`] {
			quote = character
		} else if character == `#` {
			_, finish := os_depends_on_trim_range(source, begin_pos, index)
			return finish
		}
	}
	_, finish := os_depends_on_trim_range(source, begin_pos, end_pos)
	return finish
}

fn os_depends_on_split_arguments(source string, begin_pos int, end_pos int) [][2]int {
	mut ranges := [][2]int{}
	mut start := begin_pos
	mut round := 0
	mut square := 0
	mut brace := 0
	mut quote := u8(0)
	mut escaped := false
	for index := begin_pos; index < end_pos; index++ {
		character := source[index]
		if escaped {
			escaped = false
			continue
		}
		if quote != 0 {
			if character == `\\` {
				escaped = true
			} else if character == quote {
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
					part_begin, part_end := os_depends_on_trim_range(source, start, index)
					if part_begin < part_end {
						ranges << [part_begin, part_end]!
					}
					start = index + 1
				}
			}
			else {}
		}
	}
	part_begin, part_end := os_depends_on_trim_range(source, start, end_pos)
	if part_begin < part_end {
		ranges << [part_begin, part_end]!
	}
	return ranges
}

fn os_depends_on_string_content(literal string) string {
	if literal.len < 2 || literal[0] !in [`'`, `"`] || literal[literal.len - 1] != literal[0] {
		return literal
	}
	return literal[1..literal.len - 1]
}

fn os_depends_on_pairs(source string, begin_pos int, end_pos int) []OsDependsOnPair {
	mut pairs := []OsDependsOnPair{}
	for part in os_depends_on_split_arguments(source, begin_pos, end_pos) {
		mut colon := -1
		for index := part[0]; index < part[1]; index++ {
			if source[index] == `:` {
				colon = index
				break
			}
			if !os_depends_on_identifier_byte(source[index]) && !source[index].is_space() {
				break
			}
		}
		if colon < 0 {
			continue
		}
		key := source[part[0]..colon].trim_space()
		if key == '' || !key.bytes().all(os_depends_on_identifier_byte(it)) {
			continue
		}
		value_begin, value_end := os_depends_on_trim_range(source, colon + 1, part[1])
		if value_begin >= value_end {
			continue
		}
		literal := source[value_begin..value_end]
		value_kind := if literal.len >= 2 && literal[0] in [`'`, `"`] && literal[literal.len - 1] == literal[0] {
			'string'
		} else if literal.starts_with(':') {
			'symbol'
		} else {
			'expression'
		}
		value := if value_kind == 'string' {
			os_depends_on_string_content(literal)
		} else if value_kind == 'symbol' {
			literal[1..]
		} else {
			literal
		}
		pairs << OsDependsOnPair{
			key: key
			key_is_symbol: true
			value_kind: value_kind
			value: value
			source: source[part[0]..part[1]]
			begin_pos: part[0]
			end_pos: part[1]
			value_begin: value_begin
			value_end: value_end
		}
	}
	return pairs
}

fn os_depends_on_parse(source string) []OsDependsOnStanza {
	mut stanzas := []OsDependsOnStanza{}
	mut stack := []int{}
	mut line_begin := 0
	for line_begin <= source.len {
		line_break := source.index_after('\n', line_begin) or { source.len }
		line_end := if line_break < source.len { line_break } else { source.len }
		next_line := if line_break < source.len { line_break + 1 } else { source.len + 1 }
		code_begin, _ := os_depends_on_trim_range(source, line_begin, line_end)
		code_end := os_depends_on_code_end(source, code_begin, line_end)
		if code_begin < code_end {
			code := source[code_begin..code_end]
			if code == 'end' || code.starts_with('end ') {
				if stack.len > 0 {
					block_id := stack.pop()
					stanzas[block_id].full_end = code_end
					stanzas[block_id].full_line_end = if line_break < source.len {
						line_break + 1
					} else {
						line_end
					}
				}
			} else {
				mut method_end := code_begin
				for method_end < code_end && os_depends_on_identifier_byte(source[method_end]) {
					method_end++
				}
				if method_end > code_begin {
					method := source[code_begin..method_end]
					is_block := code.ends_with(' do')
					mut arguments_end := code_end
					if is_block {
						arguments_end -= 3
					}
					arguments_begin, arguments_finish := os_depends_on_trim_range(source, method_end, arguments_end)
					id := stanzas.len
					parent_id := if stack.len > 0 { stack.last() } else { -1 }
					stanzas << OsDependsOnStanza{
						id: id
						method: method
						arguments: source[arguments_begin..arguments_finish]
						source: code
						begin_pos: code_begin
						end_pos: code_end
						line_begin: line_begin
						line_end: if line_break < source.len { line_break + 1 } else { line_end }
						full_begin: code_begin
						full_end: code_end
						full_line_end: if line_break < source.len {
							line_break + 1
						} else {
							line_end
						}
						parent_id: parent_id
						is_block: is_block
						pairs: os_depends_on_pairs(source, arguments_begin, arguments_finish)
					}
					if is_block {
						stack << id
					}
				}
			}
		}
		if next_line > source.len {
			break
		}
		line_begin = next_line
	}
	return stanzas
}

fn os_depends_on_bare(stanza OsDependsOnStanza, os string) bool {
	if stanza.method != 'depends_on' {
		return false
	}
	mut arguments := stanza.arguments.trim_space()
	if arguments.starts_with('(') && arguments.ends_with(')') {
		arguments = arguments[1..arguments.len - 1].trim_space()
	}
	return arguments == ':${os}'
}

fn os_depends_on_has_macos_pair(stanza OsDependsOnStanza) bool {
	return stanza.method == 'depends_on' && stanza.pairs.any(it.key in os_depends_on_macos_dependency_stanzas)
}

fn os_depends_on_has_linux_pair(stanza OsDependsOnStanza) bool {
	return stanza.method == 'depends_on' && stanza.pairs.any(it.key in os_depends_on_linux_dependency_stanzas)
}

fn os_depends_on_is_dependency(stanza OsDependsOnStanza) bool {
	return os_depends_on_bare(stanza, 'macos') || os_depends_on_bare(stanza, 'linux') || os_depends_on_has_macos_pair(stanza) || os_depends_on_has_linux_pair(stanza)
}

fn os_depends_on_is_descendant(stanza OsDependsOnStanza, ancestor int, stanzas []OsDependsOnStanza) bool {
	mut parent := stanza.parent_id
	for parent >= 0 {
		if parent == ancestor {
			return true
		}
		parent = stanzas[parent].parent_id
	}
	return false
}

fn os_depends_on_direct_stanzas(parent int, stanzas []OsDependsOnStanza) []OsDependsOnStanza {
	return stanzas.filter(it.parent_id == parent)
}

fn os_depends_on_platform_stanzas(stanza OsDependsOnStanza, stanzas []OsDependsOnStanza) []OsDependsOnStanza {
	if stanza.method !in os_depends_on_platform_blocks {
		return []
	}
	mut nested := os_depends_on_direct_stanzas(stanza.id, stanzas)
	for child in nested.clone() {
		nested << os_depends_on_platform_stanzas(child, stanzas)
	}
	return nested
}

fn os_depends_on_only_stanza(stanza OsDependsOnStanza, os string) bool {
	if os == 'macos' {
		if stanza.method != 'installer' {
			return stanza.method in os_depends_on_macos_only_stanzas
		}
		return stanza.pairs.any(it.key == 'manual')
	}
	return stanza.method in os_depends_on_linux_only_stanzas
}

fn os_depends_on_cross_platform(top_level []OsDependsOnStanza, stanzas []OsDependsOnStanza, os string) bool {
	other_os := if os == 'macos' { 'linux' } else { 'macos' }
	other_os_block := 'on_${other_os}'
	// `on_system` always spans both operating systems, so it can never imply a bare OS dependency.
	return stanzas.any(it.method == 'on_system') || top_level.any(it.method == other_os_block) || stanzas.any(os_depends_on_only_stanza(it, other_os))
}

fn os_depends_on_stanza_index(method string) int {
	order := ['arch', 'on_arch_conditional', 'os', 'on_system_conditional', 'version', 'sha256',
		'on_arm', 'on_intel', 'on_system', 'on_macos', 'on_linux', 'language', 'url', 'appcast',
		'name', 'desc', 'homepage', 'livecheck', 'no_autobump!', 'deprecate!', 'disable!',
		'auto_updates', 'conflicts_with', 'depends_on', 'container', 'rename', 'suite', 'app',
		'app_image', 'pkg', 'generated_script', 'installer', 'binary', 'command_wrapper', 'manpage',
		'bash_completion', 'fish_completion', 'zsh_completion', 'generate_completions_from_executable',
		'colorpicker', 'dictionary', 'font', 'input_method', 'internet_plugin', 'keyboard_layout',
		'prefpane', 'qlplugin', 'mdimporter', 'screen_saver', 'service', 'audio_unit_plugin',
		'vst_plugin', 'vst3_plugin', 'artifact', 'stage_only', 'preflight_steps', 'preflight',
		'postflight_steps', 'postflight', 'uninstall_preflight_steps', 'uninstall_preflight',
		'uninstall_postflight_steps', 'uninstall_postflight', 'uninstall', 'zap', 'caveats']
	index := order.index(method)
	if index >= 0 {
		return index
	}
	if method.starts_with('on_') {
		return order.index('on_macos')
	}
	return -1
}

fn os_depends_on_apply_edits(source string, edits []OsDependsOnEdit) string {
	mut corrected := source
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	for edit in ordered {
		corrected = corrected[..edit.begin_pos] + edit.replacement + corrected[edit.end_pos..]
	}
	return corrected
}

fn os_depends_on_add_offense(mut offenses []OsDependsOnOffense, mut edits []OsDependsOnEdit,
	begin_pos int, end_pos int, message string, has_correction bool, replacement string) {
	offenses << OsDependsOnOffense{
		begin_pos: begin_pos
		end_pos: end_pos
		message: message
		has_correction: has_correction
		replacement: replacement
	}
	if has_correction {
		edits << OsDependsOnEdit{
			begin_pos: begin_pos
			end_pos: end_pos
			replacement: replacement
		}
	}
}

fn os_depends_on_analyze_sends(stanzas []OsDependsOnStanza, mut offenses []OsDependsOnOffense,
	mut edits []OsDependsOnEdit) {
	for stanza in stanzas.filter(it.method == 'depends_on') {
		for pair in stanza.pairs {
			if pair.key !in os_depends_on_macos_dependency_stanzas || pair.value_kind != 'string' {
				continue
			}
			value := pair.value.trim_space()
			if value.len < 4 || !(value.starts_with('>=') || value.starts_with('<=')) {
				continue
			}
			comparator := value[..2]
			version_part := value[2..].trim_space()
			if !version_part.starts_with(':') || version_part.len < 2 || version_part[1..].bytes().any(it.is_space()) {
				continue
			}
			version := version_part[1..]
			replacement_key := if comparator == '<=' { 'maximum_macos' } else { 'macos' }
			message := 'Use `depends_on ${replacement_key}: :${version}`.'
			os_depends_on_add_offense(mut offenses, mut edits, pair.value_begin, pair.value_end, message, true, '${replacement_key}: :${version}')
			// The Ruby offense covers the string value while its correction replaces the entire pair.
			edits[edits.len - 1].begin_pos = pair.begin_pos
			edits[edits.len - 1].end_pos = pair.end_pos
		}

		if os_depends_on_bare(stanza, 'macos') {
			siblings := stanzas.filter(it.parent_id == stanza.parent_id && it.method == 'depends_on')
			if siblings.any(os_depends_on_has_macos_pair(it)) {
				message := 'Remove redundant `depends_on :macos`.'
				os_depends_on_add_offense(mut offenses, mut edits, stanza.begin_pos, stanza.end_pos, message, true, '')
				edits[edits.len - 1].begin_pos = stanza.line_begin
				edits[edits.len - 1].end_pos = stanza.line_end
			}
		}

		is_linux := os_depends_on_bare(stanza, 'linux')
		is_macos := os_depends_on_has_macos_pair(stanza)
		if !is_linux && !is_macos {
			continue
		}
		siblings := stanzas.filter(it.parent_id == stanza.parent_id && it.method == 'depends_on' && it.id != stanza.id)
		conflicts := if is_linux {
			siblings.any(os_depends_on_bare(it, 'macos') || os_depends_on_has_macos_pair(it))
		} else {
			siblings.any(os_depends_on_bare(it, 'linux'))
		}
		if conflicts {
			os_depends_on_add_offense(mut offenses, mut edits, stanza.begin_pos, stanza.end_pos, '`depends_on` cannot be macOS-only and Linux-only.', false, '')
		}
	}
}

fn os_depends_on_analyze_missing(stanzas []OsDependsOnStanza, os_filter string,
	mut offenses []OsDependsOnOffense, mut edits []OsDependsOnEdit) {
	for cask in stanzas.filter(it.method == 'cask' && it.is_block) {
		if stanzas.any(os_depends_on_is_descendant(it, cask.id, stanzas) && os_depends_on_is_dependency(it)) {
			continue
		}
		top_level := os_depends_on_direct_stanzas(cask.id, stanzas)
		mut all_stanzas := top_level.clone()
		for stanza in top_level {
			all_stanzas << os_depends_on_platform_stanzas(stanza, stanzas)
		}
		for os in ['macos', 'linux'] {
			if os_filter != '' && os_filter != os {
				continue
			}
			matching := all_stanzas.filter(os_depends_on_only_stanza(it, os))
			if matching.len == 0 {
				continue
			}
			os_stanza := matching[0]
			os_name := if os == 'macos' { 'macOS' } else { 'Linux' }
			if os_depends_on_cross_platform(top_level, all_stanzas, os) {
				os_depends_on_add_offense(mut offenses, mut edits, os_stanza.begin_pos, os_stanza.end_pos, 'Move this ${os_name}-only stanza into an `on_${os}` block for cross-platform casks.', false, '')
				continue
			}
			mut insert_at := os_stanza.line_begin
			mut insertion := '  depends_on :${os}\n\n'
			depends_index := os_depends_on_stanza_index('depends_on')
			mut following := []OsDependsOnStanza{}
			for stanza in top_level {
				index := os_depends_on_stanza_index(stanza.method)
				if index > depends_index {
					following << stanza
					break
				}
			}
			if following.len > 0 {
				insert_at = following[0].line_begin
			} else {
				mut preceding := []OsDependsOnStanza{}
				for stanza in top_level {
					index := os_depends_on_stanza_index(stanza.method)
					if index >= 0 && index <= depends_index {
						preceding << stanza
					}
				}
				if preceding.len > 0 {
					insert_at = preceding.last().full_line_end
					insertion = '\n  depends_on :${os}\n'
				}
			}
			os_depends_on_add_offense(mut offenses, mut edits, os_stanza.begin_pos, os_stanza.end_pos, 'Add `depends_on :${os}` for ${os_name}-only casks.', true, insertion)
			edits[edits.len - 1].begin_pos = insert_at
			edits[edits.len - 1].end_pos = insert_at
		}
	}
}

fn analyze_os_depends_on_phases(source string, sends bool, missing bool, os_filter string) OsDependsOnAnalysis {
	stanzas := os_depends_on_parse(source)
	mut offenses := []OsDependsOnOffense{}
	mut edits := []OsDependsOnEdit{}
	if sends {
		os_depends_on_analyze_sends(stanzas, mut offenses, mut edits)
	}
	if missing {
		os_depends_on_analyze_missing(stanzas, os_filter, mut offenses, mut edits)
	}
	return OsDependsOnAnalysis{
		stanzas: stanzas
		offenses: offenses
		corrected: os_depends_on_apply_edits(source, edits)
	}
}

pub fn analyze_os_depends_on(source string) OsDependsOnAnalysis {
	return analyze_os_depends_on_phases(source, true, true, '')
}

fn os_depends_on_stanza_value(stanza OsDependsOnStanza) ruby.Value {
	return ruby.structured_value('RuboCop::AST::SendNode', stanza.source, {
		'id':        stanza.id.str()
		'method':    stanza.method
		'arguments': stanza.arguments
		'begin_pos': stanza.begin_pos.str()
		'end_pos':   stanza.end_pos.str()
		'parent_id': stanza.parent_id.str()
		'is_block':  stanza.is_block.str()
	})
}

fn os_depends_on_pair_value(pair OsDependsOnPair) ruby.Value {
	return ruby.structured_value('RuboCop::AST::PairNode', pair.source, {
		'key':           pair.key
		'key_is_symbol': pair.key_is_symbol.str()
		'value_kind':    pair.value_kind
		'value':         pair.value
		'begin_pos':     pair.begin_pos.str()
		'end_pos':       pair.end_pos.str()
	})
}

fn os_depends_on_analysis_value(analysis OsDependsOnAnalysis) ruby.Value {
	offenses := analysis.offenses.map(ruby.structured_value('RuboCop::Cop::Offense', it.message, {
		'begin_pos':      it.begin_pos.str()
		'end_pos':        it.end_pos.str()
		'message':        it.message
		'has_correction': it.has_correction.str()
		'replacement':    it.replacement
	}))
	return ruby.map_value({
		'offenses':  ruby.array_value(offenses)
		'corrected': ruby.string_value(analysis.corrected)
	})
}

fn os_depends_on_argument_os(args []ruby.Value, index int) string {
	if args.len <= index {
		return 'macos'
	}
	return args[index].as_string().trim_space().trim_left(':')
}
