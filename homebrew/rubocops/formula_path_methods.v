module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/formula_path_methods.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaPathProblem {
pub:
	begin_pos   int
	end_pos     int
	current     string
	preferred   string
	message     string
	replacement string
}

pub struct FormulaPathCandidate {
pub:
	begin_pos    int
	end_pos      int
	source       string
	receiver     string
	method_name  string
	argument     string
	formula_name string
	cask_token   string
	in_formula   bool
	in_cask      bool
	in_service   bool
	in_rescue    bool
}

struct FormulaPathContext {
	kind string
}

fn formula_path_nil() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn formula_path_identifier(character u8) bool {
	return character.is_alnum() || character in [`_`, `?`, `!`]
}

fn formula_path_code_end(line string) int {
	mut quote := u8(0)
	mut escaped := false
	for index, character in line.bytes() {
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
		} else if character == `#` {
			return index
		}
	}
	return line.len
}

fn formula_path_matching_delimiter(source string, open_pos int, limit int) ?int {
	if open_pos >= limit || source[open_pos] !in [`[`, `(`] {
		return none
	}
	open := source[open_pos]
	close := if open == `[` { `]` } else { `)` }
	mut depth := 1
	mut cursor := open_pos + 1
	mut quote := u8(0)
	mut escaped := false
	for cursor < limit {
		character := source[cursor]
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
		} else if character == open {
			depth++
		} else if character == close {
			depth--
			if depth == 0 {
				return cursor
			}
		}
		cursor++
	}
	return none
}

fn formula_path_top_level_arguments(source string) []string {
	mut arguments := []string{}
	mut start := 0
	mut cursor := 0
	mut quote := u8(0)
	mut escaped := false
	mut round_depth := 0
	mut square_depth := 0
	mut curly_depth := 0
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
		} else if character in [`'`, `"`] {
			quote = character
		} else if character == `(` {
			round_depth++
		} else if character == `)` {
			round_depth--
		} else if character == `[` {
			square_depth++
		} else if character == `]` {
			square_depth--
		} else if character == `{` {
			curly_depth++
		} else if character == `}` {
			curly_depth--
		} else if character == `,` && round_depth == 0 && square_depth == 0 && curly_depth == 0 {
			arguments << source[start..cursor].trim_space()
			start = cursor + 1
		}
		cursor++
	}
	last := source[start..].trim_space()
	if last != '' {
		arguments << last
	}
	return arguments
}

fn formula_path_contexts(source string, position int) []FormulaPathContext {
	mut contexts := []FormulaPathContext{}
	mut line_start := 0
	for line_start < position {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if line_end > position {
			break
		}
		trimmed := source[line_start..line_end].trim_space()
		if trimmed == 'end' || trimmed.starts_with('end ') {
			if contexts.len > 0 {
				contexts.delete_last()
			}
		} else {
			mut kind := ''
			if trimmed.starts_with('class ') && trimmed.contains('< Formula') {
				kind = 'formula'
			} else if trimmed.starts_with('cask ') && trimmed.contains(' do') {
				kind = 'cask'
			} else if trimmed == 'service do' || trimmed.starts_with('service do ') {
				kind = 'service'
			} else if trimmed == 'begin' {
				kind = 'begin'
			} else if trimmed.starts_with('class ') || trimmed.starts_with('module ') || trimmed.starts_with('def ') || trimmed.starts_with('case ') || trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('while ') || trimmed.starts_with('until ') || trimmed.starts_with('for ') || trimmed.ends_with(' do') || (trimmed.contains(' do |') && !trimmed.contains(' end')) {
				kind = 'other'
			}
			if kind != '' {
				contexts << FormulaPathContext{
					kind: kind
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return contexts
}

fn formula_path_inside_rescue(source string, position int) bool {
	mut block_kinds := []string{}
	mut block_starts := []int{}
	mut rescued_begins := map[int]bool{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		trimmed := source[line_start..line_end].trim_space()
		if trimmed == 'rescue' || trimmed.starts_with('rescue ') {
			for index := block_kinds.len - 1; index >= 0; index-- {
				if block_kinds[index] == 'begin' {
					rescued_begins[block_starts[index]] = true
					break
				}
			}
		} else if trimmed == 'end' || trimmed.starts_with('end ') {
			if block_kinds.len > 0 {
				kind := block_kinds.last()
				start := block_starts.last()
				block_kinds.delete_last()
				block_starts.delete_last()
				if kind == 'begin' && start < position && position < line_end && rescued_begins[start] {
					return true
				}
			}
		} else {
			mut kind := ''
			if trimmed == 'begin' {
				kind = 'begin'
			} else if trimmed.starts_with('class ') || trimmed.starts_with('module ') || trimmed.starts_with('def ') || trimmed.starts_with('case ') || trimmed.starts_with('if ') || trimmed.starts_with('unless ') || trimmed.starts_with('while ') || trimmed.starts_with('until ') || trimmed.starts_with('for ') || trimmed.ends_with(' do') || (trimmed.contains(' do |') && !trimmed.contains(' end')) {
				kind = 'other'
			}
			if kind != '' {
				block_kinds << kind
				block_starts << line_start
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return false
}

fn formula_path_method_end(source string, start int, limit int) int {
	mut cursor := start
	for cursor < limit && formula_path_identifier(source[cursor]) {
		cursor++
	}
	return cursor
}

fn formula_path_candidate_at(source string, start int, limit int) ?FormulaPathCandidate {
	contexts := formula_path_contexts(source, start)
	in_formula := contexts.any(it.kind == 'formula')
	in_cask := contexts.any(it.kind == 'cask')
	in_service := contexts.any(it.kind == 'service')
	mut receiver := ''
	mut method_name := ''
	mut argument := ''
	mut formula_name := ''
	mut cask_token := ''
	mut end_pos := 0
	mut receiver_end := 0
	mut kind := ''

	formula_prefix := if source[start..limit].starts_with('::Formula[') {
		'::Formula['
	} else {
		'Formula['
	}
	if source[start..limit].starts_with(formula_prefix) {
		open_pos := start + formula_prefix.len - 1
		close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
		formula_name = source[open_pos + 1..close_pos].trim_space()
		receiver_end = close_pos + 1
		kind = 'formula'
	} else {
		formulary_prefix := if source[start..limit].starts_with('::Formulary.factory(') {
			'::Formulary.factory('
		} else {
			'Formulary.factory('
		}
		if source[start..limit].starts_with(formulary_prefix) {
			open_pos := start + formulary_prefix.len - 1
			close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
			arguments := formula_path_top_level_arguments(source[open_pos + 1..close_pos])
			if arguments.len != 1 {
				return none
			}
			formula_name = arguments[0]
			receiver_end = close_pos + 1
			kind = 'formula'
		} else {
			cask_prefix := if source[start..limit].starts_with('::Cask::Cask.new(') {
				'::Cask::Cask.new('
			} else {
				'Cask::Cask.new('
			}
			if source[start..limit].starts_with(cask_prefix) {
				open_pos := start + cask_prefix.len - 1
				close_pos := formula_path_matching_delimiter(source, open_pos, limit) or { return none }
				arguments := formula_path_top_level_arguments(source[open_pos + 1..close_pos])
				if arguments.len == 0 {
					return none
				}
				cask_token = arguments[0]
				receiver_end = close_pos + 1
				kind = 'cask'
			} else if source[start..limit].starts_with('Utils::Path.') || source[start..limit].starts_with('::Utils::Path.') {
				prefix := if source[start..limit].starts_with('::') {
					'::Utils::Path.'
				} else {
					'Utils::Path.'
				}
				method_start := start + prefix.len
				method_end := formula_path_method_end(source, method_start, limit)
				method_name = source[method_start..method_end]
				if method_end >= limit || source[method_end] != `(` {
					return none
				}
				close_pos := formula_path_matching_delimiter(source, method_end, limit) or { return none }
				argument = source[method_end + 1..close_pos].trim_space()
				receiver = source[start..method_start - 1]
				end_pos = close_pos + 1
				kind = 'utils'
			}
		}
	}

	if kind == '' {
		return none
	}
	if kind in ['formula', 'cask'] {
		if receiver_end >= limit || source[receiver_end] != `.` {
			return none
		}
		method_start := receiver_end + 1
		end_pos = formula_path_method_end(source, method_start, limit)
		if end_pos == method_start {
			return none
		}
		method_name = source[method_start..end_pos]
		receiver = source[start..receiver_end]
	}
	return FormulaPathCandidate{
		begin_pos: start
		end_pos: end_pos
		source: source[start..end_pos]
		receiver: receiver
		method_name: method_name
		argument: argument
		formula_name: formula_name
		cask_token: cask_token
		in_formula: in_formula
		in_cask: in_cask
		in_service: in_service
		in_rescue: formula_path_inside_rescue(source, start)
	}
}

pub fn formula_path_candidates(source string) []FormulaPathCandidate {
	mut candidates := []FormulaPathCandidate{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		code_end := line_start + formula_path_code_end(line)
		mut cursor := line_start
		mut quote := u8(0)
		mut escaped := false
		for cursor < code_end {
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
			if character in [`'`, `"`] {
				quote = character
				cursor++
				continue
			}
			if cursor > line_start && formula_path_identifier(source[cursor - 1]) {
				cursor++
				continue
			}
			if candidate := formula_path_candidate_at(source, cursor, code_end) {
				candidates << candidate
				cursor = candidate.end_pos
				continue
			}
			cursor++
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return candidates
}

fn formula_path_is_string_literal(value string) bool {
	trimmed := value.trim_space()
	return trimmed.len >= 2 && trimmed[0] in [`'`, `"`] && trimmed[trimmed.len - 1] == trimmed[0]
}

pub fn preferred_formula_path_call(candidate FormulaPathCandidate) ?string {
	if candidate.method_name == 'any_version_installed?' {
		if candidate.in_rescue {
			return none
		}
		if candidate.formula_name != '' && formula_path_is_string_literal(candidate.formula_name) {
			helper_receiver := if candidate.in_formula || candidate.in_cask {
				''
			} else {
				'Utils::Path.'
			}
			return '${helper_receiver}formula_any_version_installed?(${candidate.formula_name})'
		}
		if candidate.cask_token != '' {
			return 'Cask::Caskroom.cask_installed?(${candidate.cask_token})'
		}
		return none
	}
	if candidate.method_name == 'installed?' && candidate.cask_token != '' {
		return 'Cask::Caskroom.cask_installed?(${candidate.cask_token})'
	}
	if candidate.method_name == 'installed_version' && candidate.cask_token != '' {
		return 'Cask::Caskroom.cask_installed_version(${candidate.cask_token})'
	}
	scoped_helpers := ['formula_any_version_installed?', 'formula_opt_bin', 'formula_opt_include',
		'formula_opt_lib', 'formula_opt_libexec', 'formula_opt_prefix']
	if candidate.receiver in ['Utils::Path', '::Utils::Path'] && candidate.method_name in scoped_helpers {
		if candidate.in_service {
			return '${candidate.method_name}(${candidate.argument})'
		}
		return none
	}
	if candidate.in_rescue || candidate.formula_name == '' {
		return none
	}
	helper := match candidate.method_name {
		'opt_bin' { 'formula_opt_bin' }
		'opt_lib' { 'formula_opt_lib' }
		'opt_libexec' { 'formula_opt_libexec' }
		'opt_include' { 'formula_opt_include' }
		'opt_prefix' { 'formula_opt_prefix' }
		else {
			return none
		}
	}
	helper_receiver := if candidate.in_formula || candidate.in_cask { '' } else { 'Utils::Path.' }
	return '${helper_receiver}${helper}(${candidate.formula_name})'
}

pub fn audit_formula_path_methods(source string) []FormulaPathProblem {
	mut problems := []FormulaPathProblem{}
	for candidate in formula_path_candidates(source) {
		preferred := preferred_formula_path_call(candidate) or { continue }
		problems << FormulaPathProblem{
			begin_pos: candidate.begin_pos
			end_pos: candidate.end_pos
			current: candidate.source
			preferred: preferred
			message: 'Use `${preferred}` instead of `${candidate.source}`.'
			replacement: preferred
		}
	}
	return problems
}

pub fn correct_formula_path_methods(source string) string {
	mut problems := audit_formula_path_methods(source)
	problems.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for problem in problems {
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
	}
	return corrected
}

fn formula_path_problem_value(problem FormulaPathProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', problem.message, {
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'current':     problem.current
		'preferred':   problem.preferred
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby def_node_matcher `def_node_matcher :formula_lookup_name_node, <<~PATTERN` at line 40.
pub fn ruby_formula_path_methods_l40_d1_formula_lookup_name_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	candidate := formula_path_candidates(source).filter(it.receiver.ends_with('Formula[${it.formula_name}]'))
	if candidate.len == 0 {
		return formula_path_nil()
	}
	return brew_runtime.string_value(candidate[0].formula_name)
}

// Ruby def_node_matcher `def_node_matcher :formula_path_name_node, <<~PATTERN` at line 44.
pub fn ruby_formula_path_methods_l44_d2_formula_path_name_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	candidates := formula_path_candidates(source).filter(it.formula_name != '')
	if candidates.len == 0 {
		return formula_path_nil()
	}
	return brew_runtime.string_value(candidates[0].formula_name)
}

// Ruby def_node_matcher `def_node_matcher :cask_new_token_node, <<~PATTERN` at line 51.
pub fn ruby_formula_path_methods_l51_d3_cask_new_token_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	candidates := formula_path_candidates(source).filter(it.cask_token != '')
	if candidates.len == 0 {
		return formula_path_nil()
	}
	return brew_runtime.string_value(candidates[0].cask_token)
}

// Ruby def_node_matcher `def_node_matcher :formula_class?, <<~PATTERN` at line 55.
pub fn ruby_formula_path_methods_l55_d4_formula_class(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(source.trim_space().starts_with('class ') && source.trim_space().contains('< Formula'))
}

// Ruby def_node_matcher `def_node_matcher :utils_path?, <<~PATTERN` at line 59.
pub fn ruby_formula_path_methods_l59_d5_utils_path(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(source.trim_space() in ['Utils::Path', '::Utils::Path'])
}

// Ruby def_node_matcher `def_node_matcher :cask_block?, <<~PATTERN` at line 63.
pub fn ruby_formula_path_methods_l63_d6_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	trimmed := source.trim_space()
	return brew_runtime.bool_value(trimmed.starts_with('cask ') && trimmed.contains(' do'))
}

// Ruby def_node_matcher `def_node_matcher :service_block?, <<~PATTERN` at line 67.
pub fn ruby_formula_path_methods_l67_d7_service_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(source.trim_space().starts_with('service do'))
}

// Ruby method `on_send(node)` at line 72.
pub fn ruby_formula_path_methods_l72_d8_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_formula_path_methods(source).map(formula_path_problem_value(it)))
}

// Ruby method `preferred_method_call(node)` at line 84.
pub fn ruby_formula_path_methods_l84_d9_preferred_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	candidates := formula_path_candidates(source)
	if candidates.len == 0 {
		return formula_path_nil()
	}
	preferred := preferred_formula_path_call(candidates[0]) or { return formula_path_nil() }
	return brew_runtime.string_value(preferred)
}

// Ruby method `formula_helper_method_call(helper_method, formula_name, node)` at line 123.
pub fn ruby_formula_path_methods_l123_d10_formula_helper_method_call(args ...brew_runtime.Value) brew_runtime.Value {
	helper := if args.len > 0 { args[0].as_string() } else { '' }
	formula_name := if args.len > 1 { args[1].as_string() } else { '' }
	context := if args.len > 2 { args[2].as_string() } else { '' }
	receiver := if context in ['formula', 'cask'] { '' } else { 'Utils::Path.' }
	return brew_runtime.string_value('${receiver}${helper}(${formula_name})')
}

// Ruby method `formula_or_cask_dsl?(node)` at line 129.
pub fn ruby_formula_path_methods_l129_d11_formula_or_cask_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	candidates := formula_path_candidates(source)
	return brew_runtime.bool_value(candidates.len > 0 && (candidates[0].in_formula || candidates[0].in_cask))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Checks for formula instances created only to build stable opt paths.
// 8:       class FormulaPathMethods < Base
// 9:         extend AutoCorrector
// 10:
// 11:         FORMULA_OPT_HELPERS = T.let({
// 12:           opt_bin:     "formula_opt_bin",
// 13:           opt_lib:     "formula_opt_lib",
// 14:           opt_libexec: "formula_opt_libexec",
// 15:           opt_include: "formula_opt_include",
// 16:           opt_prefix:  "formula_opt_prefix",
// 17:         }.freeze, T::Hash[Symbol, String])
// 18:         SCOPED_FORMULA_HELPERS = [
// 19:           :formula_any_version_installed?,
// 20:           :formula_opt_bin,
// 21:           :formula_opt_include,
// 22:           :formula_opt_lib,
// 23:           :formula_opt_libexec,
// 24:           :formula_opt_prefix,
// 25:         ].freeze
// 26:
// 27:         MSG = "Use `%<preferred>s` instead of `%<current>s`."
// 28:         RESTRICT_ON_SEND = T.let([
// 29:           :any_version_installed?,
// 30:           :installed?,
// 31:           :installed_version,
// 32:           :opt_bin,
// 33:           :opt_include,
// 34:           :opt_lib,
// 35:           :opt_libexec,
// 36:           :opt_prefix,
// 37:           *SCOPED_FORMULA_HELPERS,
// 38:         ].freeze, T::Array[Symbol])
// 39:
// 40:         def_node_matcher :formula_lookup_name_node, <<~PATTERN
// 41:           (send (const {nil? cbase} :Formula) :[] $_)
// 42:         PATTERN
// 43:
// 44:         def_node_matcher :formula_path_name_node, <<~PATTERN
// 45:           {
// 46:             (send (const {nil? cbase} :Formula) :[] $_)
// 47:             (send (const {nil? cbase} :Formulary) :factory $_)
// 48:           }
// 49:         PATTERN
// 50:
// 51:         def_node_matcher :cask_new_token_node, <<~PATTERN
// 52:           (send (const (const {nil? cbase} :Cask) :Cask) :new $_ ...)
// 53:         PATTERN
// 54:
// 55:         def_node_matcher :formula_class?, <<~PATTERN
// 56:           (class _ (const {nil? cbase} :Formula) ...)
// 57:         PATTERN
// 58:
// 59:         def_node_matcher :utils_path?, <<~PATTERN
// 60:           (const (const {nil? cbase} :Utils) :Path)
// 61:         PATTERN
// 62:
// 63:         def_node_matcher :cask_block?, <<~PATTERN
// 64:           (block (send nil? :cask ...) ...)
// 65:         PATTERN
// 66:
// 67:         def_node_matcher :service_block?, <<~PATTERN
// 68:           (block (send nil? :service) ...)
// 69:         PATTERN
// 70:
// 71:         sig { params(node: RuboCop::AST::SendNode).void }
// 72:         def on_send(node)
// 73:           preferred = preferred_method_call(node)
// 74:           return unless preferred
// 75:
// 76:           add_offense(node, message: format(MSG, preferred:, current: node.source)) do |corrector|
// 77:             corrector.replace(node.loc.expression, preferred)
// 78:           end
// 79:         end
// 80:
// 81:         private
// 82:
// 83:         sig { params(node: RuboCop::AST::SendNode).returns(T.nilable(String)) }
// 84:         def preferred_method_call(node)
// 85:           case node.method_name
// 86:           when :any_version_installed?
// 87:             return if node.each_ancestor.any?(&:rescue_type?)
// 88:
// 89:             formula_lookup_name_node(node.receiver) do |formula_name|
// 90:               return unless formula_name.str_type?
// 91:
// 92:               return formula_helper_method_call("formula_any_version_installed?", formula_name, node)
// 93:             end
// 94:             cask_new_token_node(node.receiver) do |cask_token|
// 95:               return "Cask::Caskroom.cask_installed?(#{cask_token.source})"
// 96:             end
// 97:           when :installed?
// 98:             cask_new_token_node(node.receiver) do |cask_token|
// 99:               return "Cask::Caskroom.cask_installed?(#{cask_token.source})"
// 100:             end
// 101:           when :installed_version
// 102:             cask_new_token_node(node.receiver) do |cask_token|
// 103:               return "Cask::Caskroom.cask_installed_version(#{cask_token.source})"
// 104:             end
// 105:           when *SCOPED_FORMULA_HELPERS
// 106:             receiver = node.receiver
// 107:             return unless receiver
// 108:             return unless utils_path?(receiver)
// 109:             return unless node.each_ancestor.any? { |ancestor| service_block?(ancestor) }
// 110:
// 111:             return "#{node.method_name}(#{node.arguments.map(&:source).join(", ")})"
// 112:           else
// 113:             return if node.each_ancestor.any?(&:rescue_type?)
// 114:
// 115:             formula_path_name_node(node.receiver) do |formula_name|
// 116:               return formula_helper_method_call(FORMULA_OPT_HELPERS.fetch(node.method_name), formula_name, node)
// 117:             end
// 118:           end
// 119:           nil
// 120:         end
// 121:
// 122:         sig { params(helper_method: String, formula_name: RuboCop::AST::Node, node: RuboCop::AST::Node).returns(String) }
// 123:         def formula_helper_method_call(helper_method, formula_name, node)
// 124:           helper_receiver = "Utils::Path." unless formula_or_cask_dsl?(node)
// 125:           "#{helper_receiver}#{helper_method}(#{formula_name.source})"
// 126:         end
// 127:
// 128:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 129:         def formula_or_cask_dsl?(node)
// 130:           node.each_ancestor.any? { |ancestor| formula_class?(ancestor) || cask_block?(ancestor) }
// 131:         end
// 132:       end
// 133:     end
// 134:   end
// 135: end
