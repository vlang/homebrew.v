module cmd

import ruby
import homebrew.options as option_types

// Translated from Homebrew/brew `cmd/options.rb`.
pub enum OptionsCommandSelection {
	formulae
	command
	none
}

pub struct OptionsFormula {
pub:
	full_name       string
	install_options []option_types.FormulaOption
	has_head        bool
}

pub struct OptionsCommandRequest {
pub:
	selection       OptionsCommandSelection
	formulae        []OptionsFormula
	command_name    string
	command_options []option_types.FormulaOption
	command_known   bool
	compact         bool
}

fn option_collection(items []option_types.FormulaOption) option_types.Options {
	mut collection := option_types.new_options()
	for item in items {
		collection.add(item)
	}
	return collection
}

pub fn render_formula_options(formulae []OptionsFormula, compact bool) string {
	mut output := ''
	for formula in formulae {
		if formula.install_options.len == 0 && !formula.has_head {
			continue
		}
		if compact {
			mut flags := formula.install_options.map(it.flag)
			if formula.has_head {
				flags << '--HEAD'
			}
			flags.sort()
			output += '${flags.join(' ')}\n'
			continue
		}
		if formulae.len > 1 {
			output += '${formula.full_name}\n'
		}
		output += option_types.format_for_formula(option_collection(formula.install_options), formula.has_head)
		output += '\n'
	}
	return output
}

pub fn render_command_options(command_options []option_types.FormulaOption, compact bool) string {
	mut sorted := command_options.clone()
	sorted.sort_with_compare(fn (left &option_types.FormulaOption, right &option_types.FormulaOption) int {
		return left.flag.compare(right.flag)
	})
	if compact {
		return '${sorted.map(it.flag).join(' ')}\n'
	}
	mut output := ''
	for option in sorted {
		output += '${option.flag}\n\t${option.description}\n'
	}
	return '${output}\n'
}

pub fn run_options_command(request OptionsCommandRequest) !string {
	return match request.selection {
		.formulae { render_formula_options(request.formulae, request.compact) }
		.command {
			if !request.command_known {
				return error('Unknown command: brew ${request.command_name}')
			}
			render_command_options(request.command_options, request.compact)
		}
		.none {
			return error('`brew options` needs a formula, `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
		}
	}
}

pub fn options_formula_value(formula OptionsFormula) ruby.Value {
	mut values := []ruby.Value{}
	for option in formula.install_options {
		values << ruby.structured_value('Option', option.flag, {
			'name':        option.name
			'flag':        option.flag
			'description': option.description
		})
	}
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'full_name': formula.full_name
			'has_head':  formula.has_head.str()
		}
		map_data: {
			'options': ruby.array_value(values)
		}
	}
}

fn command_option_from_value(value ruby.Value) option_types.FormulaOption {
	name := value.attribute('name') or { value.as_string().trim_left('-') }
	return option_types.new_option(name, value.attribute('description') or { '' })
}

fn options_formula_from_value(value ruby.Value) OptionsFormula {
	option_values := (value.map_data['options'] or { ruby.array_value([]) }).as_array() or { [] }
	return OptionsFormula{
		full_name: value.attribute('full_name') or { value.as_string() }
		install_options: option_values.map(command_option_from_value(it))
		has_head: (value.attribute('has_head') or { 'false' }) == 'true'
	}
}
