module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/os_depends_on.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `on_block(node)` at line 41.
pub fn ruby_os_depends_on_l41_d1_on_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, false, true, ''))
}

// Ruby method `on_send(node)` at line 51.
pub fn ruby_os_depends_on_l51_d2_on_send(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, true, false, ''))
}

// Ruby method `autocorrect_macos_comparison_strings(node)` at line 60.
pub fn ruby_os_depends_on_l60_d3_autocorrect_macos_comparison_strings(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, true, false, ''))
}

// Ruby method `check_redundant_bare_macos(node)` at line 78.
pub fn ruby_os_depends_on_l78_d4_check_redundant_bare_macos(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, true, false, ''))
}

// Ruby method `check_conflicting_os_requirements(node)` at line 91.
pub fn ruby_os_depends_on_l91_d5_check_conflicting_os_requirements(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, true, false, ''))
}

// Ruby method `add_missing_os_dependency(node, os)` at line 107.
pub fn ruby_os_depends_on_l107_d6_add_missing_os_dependency(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	os := os_depends_on_argument_os(args, 1)
	return os_depends_on_analysis_value(analyze_os_depends_on_phases(source, false, true, os))
}

// Ruby method `os_only_stanza?(stanza, os)` at line 159.
pub fn ruby_os_depends_on_l159_d7_os_only_stanza(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	os := os_depends_on_argument_os(args, 1)
	return ruby.bool_value(stanzas.len > 0 && os_depends_on_only_stanza(stanzas[0], os))
}

// Ruby method `cross_platform_cask?(top_level_stanzas, stanzas, os)` at line 178.
pub fn ruby_os_depends_on_l178_d8_cross_platform_cask(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	os := os_depends_on_argument_os(args, 1)
	for cask in stanzas.filter(it.method == 'cask') {
		top_level := os_depends_on_direct_stanzas(cask.id, stanzas)
		mut all_stanzas := top_level.clone()
		for stanza in top_level {
			all_stanzas << os_depends_on_platform_stanzas(stanza, stanzas)
		}
		return ruby.bool_value(os_depends_on_cross_platform(top_level, all_stanzas, os))
	}
	return ruby.bool_value(false)
}

// Ruby method `direct_stanzas(node)` at line 189.
pub fn ruby_os_depends_on_l189_d9_direct_stanzas(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	parent := stanzas.filter(it.method == 'cask')
	parent_id := if parent.len > 0 { parent[0].id } else { -1 }
	return ruby.array_value(os_depends_on_direct_stanzas(parent_id, stanzas).map(os_depends_on_stanza_value(it)))
}

// Ruby method `platform_block_stanzas(stanza)` at line 200.
pub fn ruby_os_depends_on_l200_d10_platform_block_stanzas(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	for stanza in stanzas {
		if stanza.method in os_depends_on_platform_blocks {
			return ruby.array_value(os_depends_on_platform_stanzas(stanza, stanzas).map(os_depends_on_stanza_value(it)))
		}
	}
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `full_stanza_source_range(stanza)` at line 212.
pub fn ruby_os_depends_on_l212_d11_full_stanza_source_range(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	if stanzas.len == 0 {
		return ruby.object_value('Parser::Source::Range', '')
	}
	stanza := stanzas[0]
	return ruby.structured_value('Parser::Source::Range', '${stanza.full_begin}...${stanza.full_end}', {
		'begin_pos': stanza.full_begin.str()
		'end_pos':   stanza.full_end.str()
	})
}

// Ruby method `depends_on_pairs(node)` at line 220.
pub fn ruby_os_depends_on_l220_d12_depends_on_pairs(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	for stanza in stanzas.filter(it.method == 'depends_on') {
		return ruby.array_value(stanza.pairs.map(os_depends_on_pair_value(it)))
	}
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `symbol_key(pair)` at line 229.
pub fn ruby_os_depends_on_l229_d13_symbol_key(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { 'depends_on ${args[0].as_string()}' } else { '' }
	stanzas := os_depends_on_parse(source)
	if stanzas.len == 0 || stanzas[0].pairs.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(stanzas[0].pairs[0].key)
}

// Ruby method `sibling_depends_on_pairs(node)` at line 237.
pub fn ruby_os_depends_on_l237_d14_sibling_depends_on_pairs(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	for stanza in stanzas.filter(it.method == 'depends_on') {
		mut pairs := []OsDependsOnPair{}
		for sibling in stanzas.filter(it.parent_id == stanza.parent_id && it.method == 'depends_on') {
			pairs << sibling.pairs
		}
		return ruby.array_value(pairs.map(os_depends_on_pair_value(it)))
	}
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `sibling_depends_on_calls(node)` at line 242.
pub fn ruby_os_depends_on_l242_d15_sibling_depends_on_calls(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	for stanza in stanzas.filter(it.method == 'depends_on') {
		siblings := stanzas.filter(it.parent_id == stanza.parent_id && it.method == 'depends_on')
		return ruby.array_value(siblings.map(os_depends_on_stanza_value(it)))
	}
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `os_depends_on?(node)` at line 249.
pub fn ruby_os_depends_on_l249_d16_os_depends_on(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	return ruby.bool_value(stanzas.any(os_depends_on_is_dependency(it)))
}

// Ruby method `bare_os_depends_on?(node, os)` at line 260.
pub fn ruby_os_depends_on_l260_d17_bare_os_depends_on(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	os := os_depends_on_argument_os(args, 1)
	return ruby.bool_value(stanzas.any(os_depends_on_bare(it, os)))
}

// Ruby method `top_level_macos_depends_on?(node)` at line 265.
pub fn ruby_os_depends_on_l265_d18_top_level_macos_depends_on(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	return ruby.bool_value(stanzas.any(os_depends_on_has_macos_pair(it)))
}

// Ruby method `top_level_linux_depends_on?(node)` at line 270.
pub fn ruby_os_depends_on_l270_d19_top_level_linux_depends_on(args ...ruby.Value) ruby.Value {
	stanzas := os_depends_on_parse(if args.len > 0 { args[0].as_string() } else { '' })
	return ruby.bool_value(stanzas.any(os_depends_on_has_linux_pair(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/cask/constants/stanza"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Homebrew
// 9:       class OSDependsOn < Base
// 10:         extend AutoCorrector
// 11:         include RangeHelp
// 12:
// 13:         MACOS_ONLY_CASK_STANZAS = [
// 14:           :app,
// 15:           :audio_unit_plugin,
// 16:           :colorpicker,
// 17:           :dictionary,
// 18:           :input_method,
// 19:           :internet_plugin,
// 20:           :keyboard_layout,
// 21:           :mdimporter,
// 22:           :pkg,
// 23:           :prefpane,
// 24:           :qlplugin,
// 25:           :screen_saver,
// 26:           :service,
// 27:           :suite,
// 28:           :vst_plugin,
// 29:           :vst3_plugin,
// 30:         ].freeze
// 31:         LINUX_ONLY_CASK_STANZAS = [:app_image].freeze
// 32:         PLATFORM_BLOCKS = [:on_arm, :on_intel, :on_system].freeze
// 33:
// 34:         CASK_STANZA_ORDER = T.let(RuboCop::Cask::Constants::STANZA_ORDER, T::Array[Symbol])
// 35:         MACOS_DEPENDENCY_STANZAS = [:macos, :maximum_macos].freeze
// 36:         LINUX_DEPENDENCY_STANZAS = [:linux].freeze
// 37:
// 38:         RESTRICT_ON_SEND = [:depends_on].freeze
// 39:
// 40:         sig { params(node: RuboCop::AST::BlockNode).void }
// 41:         def on_block(node)
// 42:           send_node = node.children.first
// 43:           return unless send_node.is_a?(RuboCop::AST::SendNode)
// 44:           return if send_node.method_name != :cask
// 45:
// 46:           add_missing_os_dependency(node, :macos)
// 47:           add_missing_os_dependency(node, :linux)
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::SendNode).void }
// 51:         def on_send(node)
// 52:           autocorrect_macos_comparison_strings(node)
// 53:           check_redundant_bare_macos(node)
// 54:           check_conflicting_os_requirements(node)
// 55:         end
// 56:
// 57:         private
// 58:
// 59:         sig { params(node: RuboCop::AST::SendNode).void }
// 60:         def autocorrect_macos_comparison_strings(node)
// 61:           depends_on_pairs(node).each do |pair|
// 62:             key = symbol_key(pair)
// 63:             next unless MACOS_DEPENDENCY_STANZAS.include?(key)
// 64:             next unless pair.value.str_type?
// 65:
// 66:             match = pair.value.value.match(/\A\s*(?<comparator>>=|<=)\s*:(?<version>\S+)\s*\z/)
// 67:             next unless match
// 68:
// 69:             replacement_key = (match[:comparator] == "<=") ? :maximum_macos : :macos
// 70:             message = "Use `depends_on #{replacement_key}: :#{match[:version]}`."
// 71:             add_offense(pair.value.source_range, message:) do |corrector|
// 72:               corrector.replace(pair.source_range, "#{replacement_key}: :#{match[:version]}")
// 73:             end
// 74:           end
// 75:         end
// 76:
// 77:         sig { params(node: RuboCop::AST::SendNode).void }
// 78:         def check_redundant_bare_macos(node)
// 79:           return unless bare_os_depends_on?(node, :macos)
// 80:           return unless sibling_depends_on_pairs(node).any? do |pair|
// 81:             MACOS_DEPENDENCY_STANZAS.include?(symbol_key(pair))
// 82:           end
// 83:
// 84:           message = "Remove redundant `depends_on :macos`."
// 85:           add_offense(node.source_range, message:) do |corrector|
// 86:             corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
// 87:           end
// 88:         end
// 89:
// 90:         sig { params(node: RuboCop::AST::SendNode).void }
// 91:         def check_conflicting_os_requirements(node)
// 92:           return if !bare_os_depends_on?(node, :linux) && !top_level_macos_depends_on?(node)
// 93:           return unless sibling_depends_on_calls(node).any? do |sibling|
// 94:             next false if sibling == node
// 95:
// 96:             if bare_os_depends_on?(node, :linux)
// 97:               bare_os_depends_on?(sibling, :macos) || top_level_macos_depends_on?(sibling)
// 98:             else
// 99:               bare_os_depends_on?(sibling, :linux)
// 100:             end
// 101:           end
// 102:
// 103:           add_offense(node.source_range, message: "`depends_on` cannot be macOS-only and Linux-only.")
// 104:         end
// 105:
// 106:         sig { params(node: RuboCop::AST::BlockNode, os: Symbol).void }
// 107:         def add_missing_os_dependency(node, os)
// 108:           body = node.body
// 109:           return unless body
// 110:
// 111:           top_level_stanzas = direct_stanzas(body)
// 112:           stanzas = top_level_stanzas.flat_map { |stanza| [stanza, *platform_block_stanzas(stanza)] }
// 113:           return if os_depends_on?(body)
// 114:
// 115:           os_stanza = stanzas.find { |stanza| os_only_stanza?(stanza, os) }
// 116:           return unless os_stanza
// 117:
// 118:           os_name = (os == :macos) ? "macOS" : "Linux"
// 119:           if cross_platform_cask?(top_level_stanzas, stanzas, os)
// 120:             add_offense(
// 121:               os_stanza.source_range,
// 122:               message: "Move this #{os_name}-only stanza into an `on_#{os}` block for cross-platform casks.",
// 123:             )
// 124:             return
// 125:           end
// 126:
// 127:           add_offense(os_stanza.source_range,
// 128:                       message: "Add `depends_on :#{os}` for #{os_name}-only casks.") do |corrector|
// 129:             depends_on_stanza_index = CASK_STANZA_ORDER.index(:depends_on) ||
// 130:                                       raise("unexpected nil value for depends_on stanza index")
// 131:             following_stanza = top_level_stanzas.find do |stanza|
// 132:               stanza_index = CASK_STANZA_ORDER.index(stanza.method_name)
// 133:               stanza_index && stanza_index > depends_on_stanza_index
// 134:             end
// 135:
// 136:             if following_stanza
// 137:               corrector.insert_before(
// 138:                 range_by_whole_lines(following_stanza.source_range, include_final_newline: false),
// 139:                 "  depends_on :#{os}\n\n",
// 140:               )
// 141:             elsif (preceding_stanza = top_level_stanzas.rfind do |stanza|
// 142:               stanza_index = CASK_STANZA_ORDER.index(stanza.method_name)
// 143:               stanza_index && stanza_index <= depends_on_stanza_index
// 144:             end)
// 145:               corrector.insert_after(
// 146:                 range_by_whole_lines(full_stanza_source_range(preceding_stanza), include_final_newline: true),
// 147:                 "\n  depends_on :#{os}\n",
// 148:               )
// 149:             else
// 150:               corrector.insert_before(
// 151:                 range_by_whole_lines(os_stanza.source_range, include_final_newline: false),
// 152:                 "  depends_on :#{os}\n\n",
// 153:               )
// 154:             end
// 155:           end
// 156:         end
// 157:
// 158:         sig { params(stanza: RuboCop::AST::SendNode, os: Symbol).returns(T::Boolean) }
// 159:         def os_only_stanza?(stanza, os)
// 160:           if os == :macos
// 161:             return MACOS_ONLY_CASK_STANZAS.include?(stanza.method_name) if stanza.method_name != :installer
// 162:
// 163:             stanza.arguments.any? do |argument|
// 164:               argument.hash_type? && argument.pairs.any? { |pair| symbol_key(pair) == :manual }
// 165:             end
// 166:           else
// 167:             LINUX_ONLY_CASK_STANZAS.include?(stanza.method_name)
// 168:           end
// 169:         end
// 170:
// 171:         sig {
// 172:           params(
// 173:             top_level_stanzas: T::Array[RuboCop::AST::SendNode],
// 174:             stanzas:           T::Array[RuboCop::AST::SendNode],
// 175:             os:                Symbol,
// 176:           ).returns(T::Boolean)
// 177:         }
// 178:         def cross_platform_cask?(top_level_stanzas, stanzas, os)
// 179:           other_os = (os == :macos) ? :linux : :macos
// 180:           other_os_block = (other_os == :macos) ? :on_macos : :on_linux
// 181:
// 182:           # `on_system` always spans both operating systems, so it can never imply a bare OS dependency.
// 183:           stanzas.any? { |stanza| stanza.method_name == :on_system } ||
// 184:             top_level_stanzas.any? { |stanza| stanza.method_name == other_os_block } ||
// 185:             stanzas.any? { |stanza| os_only_stanza?(stanza, other_os) }
// 186:         end
// 187:
// 188:         sig { params(node: RuboCop::AST::Node).returns(T::Array[RuboCop::AST::SendNode]) }
// 189:         def direct_stanzas(node)
// 190:           (node.begin_type? ? node.child_nodes : [node]).filter_map do |child|
// 191:             if child.send_type?
// 192:               T.cast(child, RuboCop::AST::SendNode)
// 193:             elsif child.block_type?
// 194:               T.cast(child, RuboCop::AST::BlockNode).send_node
// 195:             end
// 196:           end
// 197:         end
// 198:
// 199:         sig { params(stanza: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::SendNode]) }
// 200:         def platform_block_stanzas(stanza)
// 201:           return [] unless PLATFORM_BLOCKS.include?(stanza.method_name)
// 202:
// 203:           block = stanza.parent
// 204:           return [] unless block.is_a?(RuboCop::AST::BlockNode)
// 205:           return [] unless (body = block.body)
// 206:
// 207:           nested_stanzas = direct_stanzas(body)
// 208:           nested_stanzas + nested_stanzas.flat_map { |nested| platform_block_stanzas(nested) }
// 209:         end
// 210:
// 211:         sig { params(stanza: RuboCop::AST::SendNode).returns(Parser::Source::Range) }
// 212:         def full_stanza_source_range(stanza)
// 213:           parent = stanza.parent
// 214:           return parent.source_range if parent.is_a?(RuboCop::AST::BlockNode) && parent.send_node == stanza
// 215:
// 216:           stanza.source_range
// 217:         end
// 218:
// 219:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::PairNode]) }
// 220:         def depends_on_pairs(node)
// 221:           node.arguments.filter_map do |argument|
// 222:             next unless argument.hash_type?
// 223:
// 224:             argument.pairs
// 225:           end.flatten
// 226:         end
// 227:
// 228:         sig { params(pair: RuboCop::AST::PairNode).returns(T.nilable(Symbol)) }
// 229:         def symbol_key(pair)
// 230:           key = pair.key
// 231:           return unless key.sym_type?
// 232:
// 233:           key.value
// 234:         end
// 235:
// 236:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::PairNode]) }
// 237:         def sibling_depends_on_pairs(node)
// 238:           sibling_depends_on_calls(node).flat_map { |sibling| depends_on_pairs(sibling) }
// 239:         end
// 240:
// 241:         sig { params(node: RuboCop::AST::SendNode).returns(T::Array[RuboCop::AST::SendNode]) }
// 242:         def sibling_depends_on_calls(node)
// 243:           parent = node.parent
// 244:           siblings = parent&.begin_type? ? parent.child_nodes : [node]
// 245:           siblings.select { |sibling| sibling.send_type? && sibling.method_name == :depends_on }
// 246:         end
// 247:
// 248:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 249:         def os_depends_on?(node)
// 250:           node.each_node(:send).any? do |send_node|
// 251:             send_node = T.cast(send_node, RuboCop::AST::SendNode)
// 252:             next false if send_node.method_name != :depends_on
// 253:
// 254:             bare_os_depends_on?(send_node, :macos) || bare_os_depends_on?(send_node, :linux) ||
// 255:               top_level_macos_depends_on?(send_node) || top_level_linux_depends_on?(send_node)
// 256:           end
// 257:         end
// 258:
// 259:         sig { params(node: RuboCop::AST::SendNode, os: Symbol).returns(T::Boolean) }
// 260:         def bare_os_depends_on?(node, os)
// 261:           !!(node.first_argument&.sym_type? && node.first_argument.value == os)
// 262:         end
// 263:
// 264:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 265:         def top_level_macos_depends_on?(node)
// 266:           depends_on_pairs(node).any? { |pair| MACOS_DEPENDENCY_STANZAS.include?(symbol_key(pair)) }
// 267:         end
// 268:
// 269:         sig { params(node: RuboCop::AST::SendNode).returns(T::Boolean) }
// 270:         def top_level_linux_depends_on?(node)
// 271:           depends_on_pairs(node).any? { |pair| LINUX_DEPENDENCY_STANZAS.include?(symbol_key(pair)) }
// 272:         end
// 273:       end
// 274:     end
// 275:   end
// 276: end
