module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/options.rb`.
// The original source is retained below until every stub has a typed V body.
pub const options_deprecated_option_message = 'Formulae in homebrew/core should not use `deprecated_option`.'
pub const options_option_message = 'Formulae in homebrew/core should not use `option`.'

pub struct FormulaOptionProblem {
pub:
	method    string
	option    string
	begin_pos int
	end_pos   int
	message   string
}

fn formula_option_call(line string, line_start int) ?FormulaOptionProblem {
	mut cursor := 0
	for cursor < line.len && (line[cursor] == ` ` || line[cursor] == `\t`) {
		cursor++
	}
	mut method := ''
	for candidate in ['deprecated_option', 'option'] {
		if line[cursor..].starts_with(candidate) && (cursor + candidate.len == line.len || line[cursor + candidate.len] == ` ` || line[cursor + candidate.len] == `\t` || line[cursor + candidate.len] == `(`) {
			method = candidate
			break
		}
	}
	if method == '' {
		return none
	}
	mut argument := cursor + method.len
	for argument < line.len && (line[argument] == ` ` || line[argument] == `\t` || line[argument] == `(`) {
		argument++
	}
	mut option := ''
	if argument < line.len && (line[argument] == `'` || line[argument] == `"`) {
		quote := line[argument]
		mut end := argument + 1
		mut escaped := false
		for end < line.len {
			if escaped {
				escaped = false
			} else if line[end] == `\\` {
				escaped = true
			} else if line[end] == quote {
				option = line[argument + 1..end]
				break
			}
			end++
		}
	}
	return FormulaOptionProblem{
		method: method
		option: option
		begin_pos: line_start + cursor
		end_pos: line_start + line.len
	}
}

fn formula_option_special_name(option string) ?string {
	mut without := false
	mut suffix := ''
	if option.starts_with('without-') {
		without = true
		suffix = option['without-'.len..]
	} else if option.starts_with('with-') {
		suffix = option['with-'.len..]
	} else {
		return none
	}
	if suffix !in ['check', 'checks', 'test', 'tests'] {
		return none
	}
	return if without { 'without-test' } else { 'with-test' }
}

pub fn audit_formula_options(source string, formula_tap string, has_optional_or_recommended_check bool) []FormulaOptionProblem {
	mut calls := []FormulaOptionProblem{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		if call := formula_option_call(source[line_start..line_end], line_start) {
			calls << call
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	mut problems := []FormulaOptionProblem{}
	for call in calls {
		if call.method != 'option' {
			continue
		}
		if !call.option.contains('with-') && !call.option.contains('without-') {
			problems << FormulaOptionProblem{
				...call
				message: "Options should begin with `with` or `without`. Migrate '--${call.option}' with `deprecated_option`."
			}
		}
		suggested := formula_option_special_name(call.option) or { continue }
		if !has_optional_or_recommended_check {
			problems << FormulaOptionProblem{
				...call
				message: "Use '--${suggested}' instead of '--${call.option}'. Migrate '--${call.option}' with `deprecated_option`."
			}
		}
	}
	if formula_tap == 'homebrew-core' {
		for call in calls {
			if call.method == 'deprecated_option' {
				problems << FormulaOptionProblem{
					...call
					message: options_deprecated_option_message
				}
			} else if call.method == 'option' {
				problems << FormulaOptionProblem{
					...call
					message: options_option_message
				}
			}
		}
	}
	return problems
}

fn formula_option_problem_value(problem FormulaOptionProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'method':    problem.method
		'option':    problem.option
		'begin_pos': problem.begin_pos.str()
		'end_pos':   problem.end_pos.str()
		'message':   problem.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 15.
pub fn ruby_options_l15_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_tap := if args.len > 1 { args[1].as_string() } else { '' }
	has_check_dependency := if args.len > 2 { args[2].bool_data } else { false }
	return brew_runtime.array_value(audit_formula_options(source, formula_tap, has_check_dependency).map(formula_option_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop audits `option`s in formulae.
// 10:       class Options < FormulaCop
// 11:         DEP_OPTION = "Formulae in homebrew/core should not use `deprecated_option`."
// 12:         OPTION = "Formulae in homebrew/core should not use `option`."
// 13:
// 14:         sig { override.params(formula_nodes: FormulaNodes).void }
// 15:         def audit_formula(formula_nodes)
// 16:           return if (body_node = formula_nodes.body_node).nil?
// 17:
// 18:           option_call_nodes = find_every_method_call_by_name(body_node, :option)
// 19:           option_call_nodes.each do |option_call|
// 20:             option = parameters(option_call).fetch(0)
// 21:             offending_node(option_call)
// 22:             option = string_content(option)
// 23:
// 24:             unless /with(out)?-/.match?(option)
// 25:               problem "Options should begin with `with` or `without`. " \
// 26:                       "Migrate '--#{option}' with `deprecated_option`."
// 27:             end
// 28:
// 29:             next unless option =~ /^with(out)?-(?:checks?|tests)$/
// 30:             next if depends_on?("check", :optional, :recommended)
// 31:
// 32:             problem "Use '--with#{Regexp.last_match(1)}-test' instead of '--#{option}'. " \
// 33:                     "Migrate '--#{option}' with `deprecated_option`."
// 34:           end
// 35:
// 36:           return if formula_tap != "homebrew-core"
// 37:
// 38:           problem DEP_OPTION if method_called_ever?(body_node, :deprecated_option)
// 39:           problem OPTION if method_called_ever?(body_node, :option)
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
