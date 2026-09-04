module cmd

import ruby
import homebrew.options as option_types

// Translated from Homebrew/brew `cmd/options.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 34.
pub fn ruby_options_l34_d1_run(args ...ruby.Value) ruby.Value {
	formula_values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	compact := args.len > 1 && (args[1].as_bool() or { false })
	selection := if args.len > 2 && args[2].as_string() == 'command' {
		OptionsCommandSelection.command
	} else if args.len > 2 && args[2].as_string() == 'none' {
		OptionsCommandSelection.none
	} else {
		OptionsCommandSelection.formulae
	}
	command_values := if args.len > 3 {
		args[3].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	request := OptionsCommandRequest{
		selection: selection
		formulae: formula_values.map(options_formula_from_value(it))
		command_name: if args.len > 4 { args[4].as_string() } else { '' }
		command_options: command_values.map(command_option_from_value(it))
		command_known: args.len <= 5 || (args[5].as_bool() or { false })
		compact: compact
	}
	output := run_options_command(request) or {
		return ruby.object_value(if selection == .none {
			'UsageError'
		} else {
			'RuntimeError'
		}, err.msg())
	}
	return ruby.string_value(output)
}

// Ruby method `puts_options(formulae)` at line 64.
pub fn ruby_options_l64_d2_puts_options(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'puts_options requires formulae')
	}
	formula_values := args[0].as_array() or { []ruby.Value{} }
	compact := args.len > 1 && (args[1].as_bool() or { false })
	return ruby.string_value(render_formula_options(formula_values.map(options_formula_from_value(it)), compact))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "options"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class OptionsCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Show install options specific to <formula>.
// 14:         EOS
// 15:         switch "--compact",
// 16:                description: "Show all options on a single line separated by spaces."
// 17:         switch "--installed",
// 18:                description: "Show options for formulae that are currently installed."
// 19:         switch "--eval-all",
// 20:                description: "Evaluate all available formulae and casks, whether installed or not, to show their " \
// 21:                             "options.",
// 22:                env:         :eval_all,
// 23:                odeprecated: true
// 24:         flag   "--command=",
// 25:                description: "Show options for the specified <command>.",
// 26:                odeprecated: true
// 27:
// 28:         conflicts "--command", "--installed", "--eval-all"
// 29:
// 30:         named_args :formula
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def run
// 35:         eval_all = args.eval_all?
// 36:         eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 37:
// 38:         if eval_all
// 39:           puts_options(Formula.all(eval_all:).sort)
// 40:         elsif args.installed?
// 41:           puts_options(Formula.installed.sort)
// 42:         elsif args.command.present?
// 43:           cmd_options = Commands.command_options(T.must(args.command))
// 44:           odie "Unknown command: brew #{args.command}" if cmd_options.nil?
// 45:
// 46:           if args.compact?
// 47:             puts cmd_options.sort.map(&:first) * " "
// 48:           else
// 49:             cmd_options.sort.each { |option, desc| puts "#{option}\n\t#{desc}" }
// 50:             puts
// 51:           end
// 52:         elsif args.no_named?
// 53:           raise UsageError,
// 54:                 "`brew options` needs a formula, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 55:                 "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 56:         else
// 57:           puts_options args.named.to_formulae
// 58:         end
// 59:       end
// 60:
// 61:       private
// 62:
// 63:       sig { params(formulae: T::Array[Formula]).void }
// 64:       def puts_options(formulae)
// 65:         formulae.each do |f|
// 66:           next if f.options.empty?
// 67:
// 68:           if args.compact?
// 69:             puts f.options.as_flags.sort * " "
// 70:           else
// 71:             puts f.full_name if formulae.length > 1
// 72:             Options.dump_for_formula f
// 73:             puts
// 74:           end
// 75:         end
// 76:       end
// 77:     end
// 78:   end
// 79: end
