module homebrew

import ruby

// Translated from Homebrew/brew `brew_irb_helpers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `f(*args)` at line 13.
pub fn ruby_brew_irb_helpers_l13_d1_f(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula name is required')
	}
	mut factory_args := []int{}
	for argument in args[1..] {
		factory_args << int(argument.as_int() or { 0 })
	}
	return irb_formula_value(irb_formula(args[0].as_string(), factory_args))
}

// Ruby method `c(config: nil)` at line 19.
pub fn ruby_brew_irb_helpers_l19_d2_c(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'cask token is required')
	}
	config := if args.len > 1 { irb_cask_config_from_value(args[1]) } else { map[string]string{} }
	return irb_cask_value(irb_cask(args[0].as_string(), config))
}

pub struct IrbFormula {
pub:
	name         string
	factory_args []int
}

pub struct IrbCask {
pub:
	token  string
	config map[string]string
}

pub fn irb_formula(name string, factory_args []int) IrbFormula {
	return IrbFormula{
		name: name
		factory_args: factory_args.clone()
	}
}

pub fn irb_cask(token string, config map[string]string) IrbCask {
	return IrbCask{
		token: token
		config: config.clone()
	}
}

pub fn irb_formula_value(formula IrbFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':         formula.name
		'factory_args': formula.factory_args.map(it.str()).join(',')
	})
}

pub fn irb_cask_value(cask IrbCask) ruby.Value {
	mut attributes := cask.config.clone()
	attributes['token'] = cask.token
	return ruby.structured_value('Cask::Cask', cask.token, attributes)
}

pub fn irb_cask_config_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return map[string]string{} }
	mut config := map[string]string{}
	for key, entry in values {
		config[key] = entry.as_string()
	}
	return config
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper methods for the Homebrew IRB/PRY shell run by `brew irb`
// 5:
// 6: require "formula"
// 7: require "formulary"
// 8: require "cask/cask_loader"
// 9:
// 10: class String
// 11:   # @!visibility private
// 12:   sig { params(args: Integer).returns(Formula) }
// 13:   def f(*args)
// 14:     Formulary.factory(self, *args)
// 15:   end
// 16:
// 17:   # @!visibility private
// 18:   sig { params(config: T.nilable(T::Hash[Symbol, T.untyped])).returns(Cask::Cask) }
// 19:   def c(config: nil)
// 20:     Cask::CaskLoader.load(self, config: Cask::Config.new(**config))
// 21:   end
// 22: end
// 23: require "brew_irb_helpers/symbol"
