module cmd

import ruby

// Translated from Homebrew/brew `cmd/postinstall.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PostinstallFormula {
pub:
	name                       string
	post_install_steps_defined bool
	post_install_defined       bool
}

pub struct PostinstallOptions {
pub:
	debug   bool
	quiet   bool
	verbose bool
}

pub struct PostinstallResult {
pub:
	actions  []string
	warnings []string
}

pub fn run_postinstall_command(formulae []PostinstallFormula, options PostinstallOptions) PostinstallResult {
	mut actions := []string{}
	mut warnings := []string{}
	for formula in formulae {
		actions << 'Postinstalling ${formula.name}'
		actions << 'install_etc_var:${formula.name}'
		if formula.post_install_steps_defined || formula.post_install_defined {
			actions << 'FormulaInstaller.new:${formula.name}:debug=${options.debug}:quiet=${options.quiet}:verbose=${options.verbose}'
			actions << 'FormulaInstaller.post_install:${formula.name}'
		} else {
			warnings << '${formula.name}: no `post_install` method was defined in the formula!'
		}
	}
	return PostinstallResult{
		actions: actions
		warnings: warnings
	}
}

pub fn postinstall_formula_to_value(formula PostinstallFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':                       formula.name
		'post_install_steps_defined': formula.post_install_steps_defined.str()
		'post_install_defined':       formula.post_install_defined.str()
	})
}

fn postinstall_formula_from_value(value ruby.Value) PostinstallFormula {
	return PostinstallFormula{
		name: value.attributes['name'] or { value.as_string() }
		post_install_steps_defined: (value.attributes['post_install_steps_defined'] or { 'false' }) == 'true'
		post_install_defined: (value.attributes['post_install_defined'] or { 'false' }) == 'true'
	}
}

pub fn postinstall_result_to_value(result PostinstallResult) ruby.Value {
	return ruby.map_value({
		'actions':  ruby.string_array_value(result.actions)
		'warnings': ruby.string_array_value(result.warnings)
	})
}

// Ruby method `run` at line 19.
pub fn ruby_postinstall_l19_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'at least one installed formula is required')
	}
	values := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	formula_values := values['formulae'] or { ruby.array_value([]ruby.Value{}) }.as_array() or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	if formula_values.len == 0 {
		return ruby.object_value('ArgumentError', 'at least one installed formula is required')
	}
	options := PostinstallOptions{
		debug: if value := values['debug'] { value.as_bool() or { false } } else { false }
		quiet: if value := values['quiet'] { value.as_bool() or { false } } else { false }
		verbose: if value := values['verbose'] { value.as_bool() or { false } } else { false }
	}
	return postinstall_result_to_value(run_postinstall_command(formula_values.map(postinstall_formula_from_value(it)), options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula_installer"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Postinstall < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Rerun the post-install steps for <formula>.
// 13:         EOS
// 14:
// 15:         named_args :installed_formula, min: 1
// 16:       end
// 17:
// 18:       sig { override.void }
// 19:       def run
// 20:         args.named.to_resolved_formulae.each do |f|
// 21:           ohai "Postinstalling #{f}"
// 22:           f.install_etc_var
// 23:           post_install_steps_defined = f.post_install_steps_defined?
// 24:           post_install_defined = f.post_install_defined?
// 25:
// 26:           if post_install_steps_defined || post_install_defined
// 27:             fi = FormulaInstaller.new(f, **{ debug: args.debug?, quiet: args.quiet?, verbose: args.verbose? }.compact)
// 28:             fi.post_install
// 29:           else
// 30:             opoo "#{f}: no `post_install` method was defined in the formula!"
// 31:           end
// 32:         end
// 33:       end
// 34:     end
// 35:   end
// 36: end
